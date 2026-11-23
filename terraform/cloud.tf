# Runs execute in HCP Terraform, where Sentinel checks every plan before apply.
terraform {
  cloud {
    # HCP Europe: plans, state and policy results are stored in the EU.
    hostname     = "app.eu.terraform.io"
    organization = "ATUL00206134"

    workspaces {
      name = "sovereignty-pac"
    }
  }
}
