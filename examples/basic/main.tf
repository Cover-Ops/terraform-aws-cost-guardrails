# Cost guardrails for a startup's staging account in Hyderabad.
locals {
  project     = "acme"
  environment = "staging"
  owner       = "platform@acme.example"
}

provider "aws" {
  region = "ap-south-2"

  # The same mandatory tags on everything else you create with this provider.
  default_tags {
    tags = {
      Project     = local.project
      Environment = local.environment
      Owner       = local.owner
      CostCentre  = "engineering"
      ManagedBy   = "terraform"
    }
  }
}

module "cost_guardrails" {
  source = "../.."
  # After publishing: source = "github.com/Cover-Ops/terraform-aws-cost-guardrails?ref=v0.1.0"

  project            = local.project
  environment        = local.environment
  owner              = local.owner
  monthly_budget_usd = 500
  alert_emails       = ["platform@acme.example"]
}
