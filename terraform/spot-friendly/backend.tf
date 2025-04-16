terraform {
  backend "s3" {
    bucket = "j1-tfstate-eks"        # 미리 생성 필요
    key    = "karpenter/terraform.tfstate"
    region = "ap-northeast-2"
  }
}