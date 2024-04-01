locals {
  newrelic = {
    account_id              = "overwrite-me", # NewRelic account number
    application             = "mypage_monitor",
    api_key                 = "overwrite-me", # NewRelic account api key
    servicenow_webhook_link = "overwrite-me", # ServiceNow instance server api webhook uri
    monitor_uri             = "overwrite-me", # The link of the service be monitored by NewRlic synthetic
    servicenow_tag          = "ci",
    servicenow_tag_key      = "MyPage"
    servicenow_endpoint_url = "overwrite-me" # ServiceNow instance server api webhook uri 
    servicenow_username     = "overwrite-me" # ServiceNow username for api webhook 
    servicenow_password     = "overwrite-me" # ServiceNow user password for api webhook 
  }
}
