terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.33.0"
    }
  }
}

provider "newrelic" {
  account_id = local.newrelic.account_id
  api_key    = local.newrelic.api_key
  region     = "US"
}
