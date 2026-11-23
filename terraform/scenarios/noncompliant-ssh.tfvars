# Expected: FAIL on network (SSH open to the internet, not the Irish admin network).
aws_region            = "eu-west-1"
replica_region        = "eu-west-1"
instance_type         = "t3.micro"
imds_http_tokens      = "required"
ebs_encrypted         = true
admin_ssh_cidr        = "0.0.0.0/0"
open_all_ports        = false
associate_public_ip   = false
backup_copy_vault_arn = ""
