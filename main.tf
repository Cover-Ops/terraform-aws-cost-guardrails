# CoverOps Marketplace kit: AWS cost guardrails.
# The mandatory tags, a monthly budget with alerts, and cost-anomaly alerts.
# Apache 2.0.

locals {
  # The mandatory tags. Pass them to your provider's default_tags (see README)
  # so everything you create carries them.
  tags = merge(var.extra_tags, {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCentre  = var.cost_centre
    ManagedBy   = "terraform"
    Kit         = "coverops/aws-cost-guardrails"
  })
  name = "${var.project}-${var.environment}"
  # One AWS-services monitor per account: reuse it if the account already has one.
  anomaly_monitor_arn = coalesce(var.anomaly_monitor_arn, one(aws_ce_anomaly_monitor.services[*].arn))
}

resource "aws_budgets_budget" "monthly" {
  name         = "${local.name}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }

  tags = local.tags
}

resource "aws_ce_anomaly_monitor" "services" {
  count             = var.anomaly_monitor_arn == null ? 1 : 0
  name              = "${local.name}-services"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
  tags              = local.tags
}

resource "aws_ce_anomaly_subscription" "email" {
  name             = "${local.name}-anomalies"
  frequency        = "DAILY"
  monitor_arn_list = [local.anomaly_monitor_arn]

  dynamic "subscriber" {
    for_each = toset(var.alert_emails)
    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [tostring(var.anomaly_threshold_usd)]
    }
  }

  tags = local.tags
}
