# AWS cost guardrails

A CoverOps Marketplace kit. The cost part of the landing zone, on its own: the mandatory tags, a monthly budget with alerts, and cost-anomaly alerts. Use it in an account that already has its security basics, or once per environment. Terraform ≥ 1.6 or OpenTofu ≥ 1.6, AWS provider 6.x. Apache 2.0.

> Status: **v0.1.0, tested on 2026-11-12**: applied, re-planned with no changes and destroyed on a sandbox AWS account (ap-south-1), nothing left behind. Run `terraform plan` before you apply it to your account.

## What it creates

| Resource | Why | Cost |
|---|---|---|
| AWS Budget (monthly, USD) with alerts at 80% actual and 100% forecast | You hear about overspend before the invoice | Free (budgets without actions) |
| Cost Anomaly Detection monitor for all AWS services (or your existing one) | Finds unusual spend in any service | Free |
| Daily anomaly email subscription | Spikes reach your inbox within a day | Free |

**Estimated monthly cost: ₹0** (estimate, at AWS list prices).

## Mandatory tags
The kit's `tags` output is `Project`, `Environment`, `Owner`, `CostCentre`, `ManagedBy` and `Kit`. Put the same tags in your provider's `default_tags` (see the example) so everything you create carries them. The CoverOps Platform reads these tags to say who owns each rupee.

## Use

```hcl
module "cost_guardrails" {
  source = "github.com/Cover-Ops/terraform-aws-cost-guardrails?ref=v0.1.0"

  project            = "acme"
  environment        = "staging"
  owner              = "platform@acme.example"
  monthly_budget_usd = 500
  alert_emails       = ["platform@acme.example"]
}
```

Full example: [`examples/basic`](examples/basic).

## Inputs

| Name | Description | Default |
|---|---|---|
| `project` | Short product/company name (lowercase, digits, hyphens) | required |
| `environment` | `production`, `staging` or `development` | required |
| `owner` | Team or email that answers for spend | required |
| `cost_centre` | Budget line for the CostCentre tag | `engineering` |
| `monthly_budget_usd` | Monthly budget in USD | required |
| `alert_emails` | Who gets budget and anomaly emails | required |
| `anomaly_threshold_usd` | Alert when an anomaly's impact reaches this | `25` |
| `anomaly_monitor_arn` | Reuse an existing AWS-services anomaly monitor | `null` (create one) |
| `extra_tags` | More tags on everything | `{}` |

## Outputs
`tags`, `budget_name`, `anomaly_monitor_arn`.

## Good to know
- The budget covers the whole account, not just one project. Budgets are in USD because AWS bills in USD.
- An account can have only one AWS-services anomaly monitor, and newer accounts get one from AWS automatically. If `apply` fails on the monitor, pass its ARN (Billing → Cost Anomaly Detection → Cost monitors) as `anomaly_monitor_arn`. Using the kit twice in one account? Pass the first one's `anomaly_monitor_arn` output to the second.
- Alert emails need no confirmation, but check spam the first time.
- Already using the landing zone kit? It includes all of this. Use one, or set `enable_cost_guardrails = false` on the landing zone: both use the same budget and anomaly names.

## Support
Open an issue on GitHub. Want Coverops engineers to apply it for you? ₹14,999 + GST per kit, or the fee back if it doesn't apply cleanly: marketplace.coverops.dev.
