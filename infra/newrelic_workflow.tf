resource "newrelic_workflow" "mypage_servicenow_webhook_workflow" {
  account_id            = local.newrelic.account_id
  name                  = ""
  enabled               = true
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = ""
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [
        # Add alert conditions (policies) here.
      ]
    }
  }
}