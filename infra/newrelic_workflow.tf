resource "newrelic_notification_destination" "mypage_webhook_destination" {
  account_id = local.newrelic.account_id
  name       = "servicenow_webhook"
  type       = "WEBHOOK"

  property {
    key   = "url"
    value = local.newrelic.servicenow_endpoint_url
  }

  auth_basic {
    user     = local.newrelic.servicenow_username
    password = local.newrelic.servicenow_password
  }
}

resource "newrelic_notification_channel" "webhook_channel" {
  name           = "servicenow-channel-webhook"
  type           = "WEBHOOK"
  destination_id = newrelic_notification_destination.mypage_webhook_destination.id
  product        = "IINT"

  property {
    key   = "payload"
    value = <<EOT
            {
            "account_id": {{nrAccountId}},
            "account_name": {{json accumulations.tag.account.[0]}},
            "node": {{ json accumulations.tag.ci }},
            "closed_violations_count": {{closedIncidentsCount}},
            "open_violations_count": {{openIncidentsCount}},
            "condition_description": "{{escape accumulations.conditionDescription.[0]}}",
            "condition_family_id": {{accumulations.conditionFamilyId.[0]}},
            "condition_name": "{{escape accumulations.conditionName.[0]}}",
            "current_state": {{json state}},
            "details": {{json issueTitle}},
            "duration": {{#if issueDurationMs}}{{issueDurationMs}}{{else}}0{{/if}},
            "event_type": "INCIDENT",
            "incident_acknowledge_url": {{json issueAckUrl}},
            "incident_id": {{json issueId}},
            "incident_url": {{json issuePageUrl}},
            "metadata": {
                {{#if locationStatusesObject}}"location_statuses": {{json locationStatusesObject}},{{/if}}
                {{#if accumulations.metadata_entity_type}}"entity.type": {{json accumulations.metadata_entity_type.[0]}},{{/if}}
                {{#if accumulations.metadata_entity_name}}"entity.name": {{json accumulations.metadata_entity_name.[0]}},{{/if}}
                "section": "metadata"
            },
            "owner": {{json owner}},
            "policy_name": {{json accumulations.policyName.[0]}},
            "policy_url": {{json policyUrl}},
            "runbook_url": {{json accumulations.runbookUrl.[0]}},
            "severity": {{json priority}},
            "targets": [
                {
                    "id": "{{labels.targetId.[0]}}",
                    "name": "{{#if accumulations.targetName}}{{escape accumulations.targetName.[0]}}{{else if entitiesData.entities}}{{escape entitiesData.entities.[0].name}}{{else}}N/A{{/if}}",
                    "link": "{{issuePageUrl}}",
                    "product": "{{accumulations.conditionProduct.[0]}}",
                    "type": "{{#if entitiesData.types.[0]}}{{entitiesData.types.[0]}}{{else}}N/A{{/if}}",
                    "labels": { {{#each accumulations.rawTag}}"{{escape @key}}": {{#if this.[0]}}{{json this.[0]}}{{else}}"empty"{{/if}}{{#unless @last}},{{/unless}}{{/each}}
                    }
                }
            ],
            "timestamp": {{updatedAt}},
            "violation_callback_url": {{json issuePageUrl}},
            "violation_chart_url": {{json violationChartUrl}}
            }
EOT
  }
}

resource "newrelic_workflow" "mypage_workflow" {
  name                  = "servicenow_workflow"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "filter-name"
    type = "FILTER"

    predicate {
      attribute = "accumulations.tag.node"
      operator  = "EXACTLY_MATCHES"
      values    = [local.newrelic.servicenow_tag_key]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.webhook_channel.id
  }
}
