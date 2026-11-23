terraform {
  # Any 1.17.x; supply_chain enforces the same at plan time.
  required_version = "~> 1.17.0"

  # HCP Terraform connection: see cloud.tf.

  required_providers {
    aws = {
      # registry.terraform.io/hashicorp/aws, the only approved source.
      source = "hashicorp/aws"
      # 6.x adds the per-resource "region" the sovereignty policy checks. Lock file pins the build.
      version = "~> 6.0"
    }
  }
}
