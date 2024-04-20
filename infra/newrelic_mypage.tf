resource "newrelic_synthetics_monitor" "mypage_monitor" {
  status           = "ENABLED"
  name             = local.newrelic.application
  period           = "EVERY_DAY"
  uri              = local.newrelic.monitor_uri
  type             = "BROWSER"
  locations_public = ["AWS_AP_SOUTHEAST_2"]

  treat_redirect_as_failure = true
  validation_string         = "success"
  bypass_head_request       = true
  verify_ssl                = true

  tag {
    key    = local.newrelic.servicenow_tag
    values = [local.newrelic.servicenow_tag_key]
  }
}

resource "newrelic_alert_policy" "mypage_policy" {
  name                = "${local.newrelic.application}_policy"
  incident_preference = "PER_CONDITION"
}

resource "newrelic_nrql_alert_condition" "mypage_alert" {
  account_id                   = local.newrelic.account_id
  policy_id                    = newrelic_alert_policy.mypage_policy.id
  type                         = "static"
  name                         = "Alert for ${local.newrelic.application}"
  enabled                      = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "SELECT filter(count(*), WHERE result = 'FAILED') AS 'Failures' FROM SyntheticCheck WHERE entityGuid IN ('${newrelic_synthetics_monitor.mypage_monitor.id}') FACET monitorName"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "static"
  fill_value         = 0
  aggregation_window = 300
  aggregation_method = "event_flow"
  aggregation_delay  = 120
  slide_by           = 30
}

resource "newrelic_entity_tags" "mypage_alert_condition_entity_tags" {
  guid = newrelic_nrql_alert_condition.mypage_alert.entity_guid

  tag {
    key    = local.newrelic.servicenow_tag
    values = ["${local.newrelic.servicenow_tag_key} web"]
  }
}

resource "newrelic_nrql_alert_condition" "high_cpu" {
  account_id                   = local.newrelic.account_id
  policy_id                    = newrelic_alert_policy.mypage_policy.id
  type                         = "static"
  name                         = "Alert for ${local.newrelic.application} High CPU"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "SELECT average(`host.cpuPercent`) FROM Metric FACET entity.guid, host.hostname"
  }

  critical {
    operator              = "below"
    threshold             = 85
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "static"
  fill_value         = 0
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 120
}

resource "newrelic_entity_tags" "high_cpu_alert_condition_entity_tags" {
  guid = newrelic_nrql_alert_condition.high_cpu.entity_guid

  tag {
    key    = local.newrelic.servicenow_tag
    values = ["${local.newrelic.servicenow_tag_key}"]
  }
}
