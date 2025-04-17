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

resource "aws_route53_record" "wildcard_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_mogki.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.mogki.zone_id
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_validation" {
  certificate_arn         = aws_acm_certificate.wildcard_mogki.arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_validation : record.fqdn]
}
