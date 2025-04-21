data "aws_route53_zone" "mogki" {
  name = "mogki.com"
}

resource "aws_acm_certificate" "wildcard_mogki" {
  domain_name               = "mogki.com"
  subject_alternative_names = ["*.mogki.com"]
  validation_method         = "DNS"

  tags = {
    Name = "mogki-com-wildcard"
  }

  lifecycle {
    create_before_destroy = true
  }
}
