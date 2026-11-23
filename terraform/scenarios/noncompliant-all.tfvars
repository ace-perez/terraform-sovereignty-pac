# Expected: FAIL on every policy except supply_chain.
aws_region            = "eu-west-1"
replica_region        = "us-east-1"
instance_type         = "m5.4xlarge"
imds_http_tokens      = "optional"
ebs_encrypted         = false
admin_ssh_cidr        = "0.0.0.0/0"
open_all_ports        = true
associate_public_ip   = true
backup_copy_vault_arn = "arn:aws:backup:us-east-1:111122223333:backup-vault:dr-us-east-1"
