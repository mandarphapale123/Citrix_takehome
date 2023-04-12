terraform {
  required_version = ">= 0.12.5"

  backend "s3" {
    bucket  = "Enter your bucket name"
    key     = "VMagent/VMagent-us-west-1.state"
    region  = "us-west-1"
    encrypt = true
    access_key = "Enter your aws account access_key"
    secret_key = "Enter your aws account secret_key"
  }
}

provider "aws" {
  region = "us-west-1"
  access_key = "Enter your aws account access_key"
  secret_key = "Enter your aws account secret_key"
}