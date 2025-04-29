terraform {
  backend "s3" {
    bucket = "j1-tfstate-eks"
    key    = "alarms/terraform.tfstate"
    region = "ap-northeast-2"
  }
}