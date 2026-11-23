# Expected: FAIL on sovereignty (everything in us-east-1, sensitive data leaves Ireland).
aws_region            = "us-east-1"
replica_region        = "us-east-1"
instance_type         = "t3.micro"
imds_http_tokens      = "required"
ebs_encrypted         = true
admin_ssh_cidr        = "203.0.113.0/24"
open_all_ports        = false
associate_public_ip   = false
backup_copy_vault_arn = ""
