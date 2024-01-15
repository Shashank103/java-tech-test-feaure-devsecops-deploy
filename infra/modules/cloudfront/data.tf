data "aws_route53_zone" "this" {
  zone_id      = var.zone_id
  name         = var.zone_name
  private_zone = var.private_zone
}

data "aws_cloudfront_cache_policy" "this" {
  count = lookup(var.default_cache_behavior, "cache_policy_id", null) != null ? 1 : 0

  name = lookup(var.default_cache_behavior, "cache_policy_id", null)
}
