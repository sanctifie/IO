# Domaine personnalisé OPTIONNEL : créé seulement si var.domain est renseigné
# (exige une zone Route 53 et un certificat ACM "ISSUED" pour ce domaine dans la même région).
locals {
  use_domain = var.domain != ""
}

data "aws_acm_certificate" "ssl_certificate" {
  count    = local.use_domain ? 1 : 0
  domain   = var.domain
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "domain" {
  count                    = local.use_domain ? 1 : 0
  domain_name              = var.domain
  regional_certificate_arn = data.aws_acm_certificate.ssl_certificate[0].arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_route53_zone" "zone" {
  count = local.use_domain ? 1 : 0
  name  = var.domain
}

# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "a_record" {
  count   = local.use_domain ? 1 : 0
  name    = aws_api_gateway_domain_name.domain[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone[0].id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain[0].regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  count       = local.use_domain ? 1 : 0
  api_id      = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.domain[0].domain_name
}