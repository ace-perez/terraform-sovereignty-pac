# ---------------------------------------------------------------------------
# Key management: one customer-managed key for sensitive data, held in Ireland.
# ---------------------------------------------------------------------------
resource "aws_kms_key" "sensitive" {
  description             = "Key for sensitive data held in Ireland"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    DataClassification = "sensitive"
  }
}

# ---------------------------------------------------------------------------
# Compute: approved type, IMDSv2 only, encrypted root volume, no public IP.
# ---------------------------------------------------------------------------
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = var.associate_public_ip

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.imds_http_tokens
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = var.ebs_encrypted
    kms_key_id  = var.ebs_encrypted ? aws_kms_key.sensitive.arn : null
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name               = "${var.name_prefix}-app"
    DataClassification = "internal"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_subnet.private.availability_zone
  size              = 10
  type              = "gp3"
  encrypted         = var.ebs_encrypted
  kms_key_id        = var.ebs_encrypted ? aws_kms_key.sensitive.arn : null

  tags = {
    Name               = "${var.name_prefix}-data"
    DataClassification = "sensitive"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.app.id
}

# ---------------------------------------------------------------------------
# Sensitive records: S3 bucket from a local (trusted) module, plus a replica.
# ---------------------------------------------------------------------------
module "sensitive_bucket" {
  source = "./modules/secure_bucket"

  bucket_name    = "${var.name_prefix}-sensitive-records"
  kms_key_arn    = aws_kms_key.sensitive.arn
  classification = "sensitive"
}

# Replica uses a per-resource region (AWS v6): a provider-only check would miss it.
resource "aws_s3_bucket" "replica" {
  region = var.replica_region
  bucket = "${var.name_prefix}-sensitive-records-replica"

  tags = {
    DataClassification = "sensitive"
    Purpose            = "replication-target"
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  region = var.replica_region
  bucket = aws_s3_bucket.replica.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  name = "${var.name_prefix}-s3-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication" {
  name = "${var.name_prefix}-s3-replication"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
        Resource = [module.sensitive_bucket.bucket_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
        Resource = ["${module.sensitive_bucket.bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"]
        Resource = ["${aws_s3_bucket.replica.arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey"]
        Resource = [aws_kms_key.sensitive.arn]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "sensitive" {
  bucket = module.sensitive_bucket.bucket_id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-sensitive-records"
    status = "Enabled"

    filter {}

    delete_marker_replication {
      status = "Disabled"
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.sensitive.arn
      }
    }
  }

  depends_on = [module.sensitive_bucket, aws_s3_bucket_versioning.replica]
}

# ---------------------------------------------------------------------------
# Backups: vault and daily plan. Copy actions are where data can leave Ireland.
# ---------------------------------------------------------------------------
resource "aws_backup_vault" "primary" {
  name        = "${var.name_prefix}-primary"
  kms_key_arn = aws_kms_key.sensitive.arn

  tags = {
    DataClassification = "sensitive"
  }
}

resource "aws_backup_plan" "daily" {
  name = "${var.name_prefix}-daily"

  rule {
    rule_name         = "daily-35-day-retention"
    target_vault_name = aws_backup_vault.primary.name
    schedule          = "cron(0 3 * * ? *)"

    lifecycle {
      delete_after = 35
    }

    dynamic "copy_action" {
      for_each = var.backup_copy_vault_arn == "" ? [] : [var.backup_copy_vault_arn]

      content {
        destination_vault_arn = copy_action.value

        lifecycle {
          delete_after = 35
        }
      }
    }
  }
}
