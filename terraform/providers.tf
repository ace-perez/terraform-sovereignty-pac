provider "aws" {
  region = var.aws_region

  # Plan-only mode with dummy credentials: an apply cannot reach AWS.
  skip_credentials_validation = var.offline_plan # skip the STS GetCallerIdentity check
  skip_requesting_account_id  = var.offline_plan # do not look up the AWS account ID
  skip_metadata_api_check     = var.offline_plan # do not ask the EC2 metadata endpoint for credentials

  # DataClassification is deliberately not a default tag: each data resource declares it.
  default_tags {
    tags = {
      Organisation = "ATUL0012345"
      Jurisdiction = "IE"
      ManagedBy    = "terraform"
    }
  }
}
