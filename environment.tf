terraform {
  required_version = ">= 0.12.5"

  backend "s3" {
    bucket  = "9806362800-terraform-states"
    key     = "VMagent/VMagent-us-west-1.state"
    region  = "us-west-1"
    encrypt = true
    access_key = "AKIAQ2E5XNIUFJGKXHHQ"
    secret_key = "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"
  }
}

provider "aws" {
  region = "us-west-1"
  access_key = "AKIAQ2E5XNIUFJGKXHHQ"
  secret_key = "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"
}