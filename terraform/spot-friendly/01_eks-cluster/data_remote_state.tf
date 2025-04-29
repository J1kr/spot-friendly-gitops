# base의 VPC 리소스를 가져온다
data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "j1-tfstate-eks"
    key    = "base/terraform.tfstate"
    region = var.aws_region
  }
}