resource "aws_route53_record" "www" {
  count = var.create_route53_record && (var.zone_id != null || var.zone_name != null) ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.record != "" ? "${var.record}.${data.aws_route53_zone.this[0].name}" : data.aws_route53_zone.this[0].name
  type    = "A"

  alias {
    name                   = element(concat(aws_cloudfront_distribution.this.*.domain_name, [""]), 0)
    zone_id                = element(concat(aws_cloudfront_distribution.this.*.hosted_zone_id, [""]), 0)
    evaluate_target_health = true
  }
}
