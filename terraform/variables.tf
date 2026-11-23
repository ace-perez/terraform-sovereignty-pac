# Switches flipped by scenarios/*.tfvars; defaults are compliant. No validation
# blocks on purpose: Sentinel, outside this code, is what catches bad values.

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "atul00206134"
}

variable "aws_region" {
  description = "Default AWS region for the provider. Ireland is eu-west-1."
  type        = string
  default     = "eu-west-1"
}

variable "offline_plan" {
  description = "Plan-only lab mode: skip AWS credential and account checks so no real AWS account is needed."
  type        = bool
  default     = true
}

variable "replica_region" {
  description = "Region of the S3 replication target bucket (AWS provider v6 per-resource region)."
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type for the application server."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Placeholder AMI ID. Plan-only mode cannot look AMIs up, so a fixed ID is used."
  type        = string
  default     = "ami-0123456789abcdef0"
}

variable "imds_http_tokens" {
  description = "IMDS token setting: \"required\" means IMDSv2 only."
  type        = string
  default     = "required"
}

variable "ebs_encrypted" {
  description = "Encrypt the root and data EBS volumes."
  type        = bool
  default     = true
}

variable "admin_ssh_cidr" {
  description = "Network allowed to SSH in. 203.0.113.0/24 (RFC 5737 documentation range) stands in for the Irish office VPN."
  type        = string
  default     = "203.0.113.0/24"
}

variable "open_all_ports" {
  description = "Adds an allow-everything ingress rule from the internet. Only used by the non-compliant scenario."
  type        = bool
  default     = false
}

variable "associate_public_ip" {
  description = "Give the instance a public IP address."
  type        = bool
  default     = false
}

variable "backup_copy_vault_arn" {
  description = "Optional backup copy target vault ARN. Empty string means no copy."
  type        = string
  default     = ""
}
