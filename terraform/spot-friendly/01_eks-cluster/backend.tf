terraform {
  backend "s3" {
    bucket = "j1-tfstate-eks"        # 미리 생성 필요
    key    = "eks/terraform.tfstate"
    region = "ap-northeast-2"
  }
}