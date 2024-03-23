terraform {
  required_version = "~> 0.13.0"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.33.0"
    }
  }
}

provider "newrelic" {
  account_id = local.newrelic.newrelic_account_id
  region = "US"
}
