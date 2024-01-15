locals {
  create_origin_access_identity = var.create_origin_access_identity && length(keys(var.origin_access_identities)) > 0
  http_version                  = "http2"
  is_ipv6_enabled               = true
  price_class                   = "PriceClass_All"
  wait_for_deployment           = true
  minimum_protocol_version      = "TLSv1.2_2021"
}

resource "aws_cloudfront_origin_access_identity" "this" {
  for_each = local.create_origin_access_identity ? var.origin_access_identities : {}

  comment = each.value

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_cloudfront_origin_request_policy" "this" {
  count = length(var.origin_request_policy) !=0 ? 1 : 0

  name    = var.origin_request_policy["origin_request_policy_name"]
  comment = lookup(var.origin_request_policy, "origin_request_policy_description", null)

  cookies_config {
    cookie_behavior = var.origin_request_policy["cookie_behavior"]

    dynamic "cookies" {
      for_each = lookup(var.origin_request_policy, "cookies_items", null) == null ? [] : [
        var.origin_request_policy["cookies_items"]
      ]
      content {
        items = split(",",cookies.value)
      }
    }
  }

  headers_config {
    header_behavior = var.origin_request_policy["header_behavior"]

    dynamic "headers" {
      for_each = lookup(var.origin_request_policy, "header_items", null) == null ? [] : [
        var.origin_request_policy["header_items"]
      ]
      content{
        items = split(",",headers.value)
      }
    }
  }

  query_strings_config {
    query_string_behavior = var.origin_request_policy["query_string_behavior"]

    dynamic "query_strings" {
      for_each = lookup(var.origin_request_policy, "query_string_items", null) == null ? [] : [
        var.origin_request_policy["query_string_items"]
      ]
      content {
        items = split(",",query_strings.value)
      }
    }
  }
}

resource "aws_cloudfront_distribution" "this" {
  count = var.create_distribution ? 1 : 0

  aliases             = var.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = local.http_version
  is_ipv6_enabled     = local.is_ipv6_enabled
  price_class         = local.price_class
  wait_for_deployment = local.wait_for_deployment
  web_acl_id          = var.waf_web_acl_id
  tags                = var.tags

  dynamic "origin" {
    for_each = var.origin

    content {
      domain_name         = origin.value.domain_name
      origin_id           = lookup(origin.value, "origin_id", origin.key)
      origin_path         = lookup(origin.value, "origin_path", "")
      connection_attempts = lookup(origin.value, "connection_attempts", null)
      connection_timeout  = lookup(origin.value, "connection_timeout", null)

      dynamic "custom_origin_config" {
        for_each = length(lookup(origin.value, "custom_origin_config", "")) == 0 ? [] : [
          lookup(origin.value, "custom_origin_config", "")
        ]

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", null)
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", null)
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_header", [])

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "origin_shield" {
        for_each = length(keys(lookup(origin.value, "origin_shield", {}))) == 0 ? [] : [
          lookup(origin.value, "origin_shield", {})
        ]

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.origin_group

    content {
      origin_id = lookup(origin_group.value, "origin_id", origin_group.key)

      failover_criteria {
        status_codes = origin_group.value["failover_status_codes"]
      }

      member {
        origin_id = origin_group.value["primary_member_origin_id"]
      }

      member {
        origin_id = origin_group.value["secondary_member_origin_id"]
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = [var.default_cache_behavior]
    iterator = i

    content {
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      allowed_methods           = lookup(i.value, "allowed_methods", [
        "GET", "HEAD", "OPTIONS"
      ])
      cached_methods            = lookup(i.value, "cached_methods", [
        "GET", "HEAD"
      ])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)
      trusted_key_groups        = lookup(i.value, "trusted_key_groups", null)
      cache_policy_id           = lookup(i.value, "cache_policy_id", null) == null ? null : data.aws_cloudfront_cache_policy.this[0].id
      origin_request_policy_id  = length(var.origin_request_policy) == 0 ? null : aws_cloudfront_origin_request_policy.this[0].id
      realtime_log_config_arn   = lookup(i.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(i.value, "use_forwarded_values", false) && length(var.origin_request_policy) == 0 ? [true] : []

        content {
          query_string            = lookup(i.value, "query_string", false)
          query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
          headers                 = lookup(i.value, "headers", [])

          cookies {
            forward           = lookup(i.value, "cookies_forward", "none")
            whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.key
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(i.value, "function_association", [])
        iterator = f

        content {
          event_type   = f.key
          function_arn = f.value.function_arn
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior

    content {
      path_pattern           = ordered_cache_behavior.value["path_pattern"]
      target_origin_id       = ordered_cache_behavior.value["target_origin_id"]
      viewer_protocol_policy = ordered_cache_behavior.value["viewer_protocol_policy"]

      allowed_methods           = lookup(ordered_cache_behavior.value, "allowed_methods", [
        "GET", "HEAD", "OPTIONS"
      ])
      cached_methods            = lookup(ordered_cache_behavior.value, "cached_methods", [
        "GET", "HEAD"
      ])
      compress                  = lookup(ordered_cache_behavior.value, "compress", null)
      field_level_encryption_id = lookup(ordered_cache_behavior.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(ordered_cache_behavior.value, "smooth_streaming", null)
      trusted_signers           = lookup(ordered_cache_behavior.value, "trusted_signers", null)
      trusted_key_groups        = lookup(ordered_cache_behavior.value, "trusted_key_groups", null)

      cache_policy_id          = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
      origin_request_policy_id = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      realtime_log_config_arn  = lookup(ordered_cache_behavior.value, "realtime_log_config_arn", null)

      min_ttl     = lookup(ordered_cache_behavior.value, "min_ttl", null)
      default_ttl = lookup(ordered_cache_behavior.value, "default_ttl", null)
      max_ttl     = lookup(ordered_cache_behavior.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(ordered_cache_behavior.value, "use_forwarded_values", true) ? [
          true
        ] : []

        content {
          query_string            = lookup(ordered_cache_behavior.value, "query_string", false)
          query_string_cache_keys = lookup(ordered_cache_behavior.value, "query_string_cache_keys", [])
          headers                 = lookup(ordered_cache_behavior.value, "headers", [])

          cookies {
            forward           = lookup(ordered_cache_behavior.value, "cookies_forward", "none")
            whitelisted_names = lookup(ordered_cache_behavior.value, "cookies_whitelisted_names", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(ordered_cache_behavior.value, "lambda_function_association", [])

        content {
          event_type   = lambda_function_association.key
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lookup(lambda_function_association.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        for_each = lookup(ordered_cache_behavior.value, "function_association", [])

        content {
          event_type   = function_association.key
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = local.minimum_protocol_version
    ssl_support_method       = "sni-only"
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_code            = custom_error_response.value["error_code"]
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = lookup(geo_restriction.value, "restriction_type", "none")
        locations        = lookup(geo_restriction.value, "locations", [])
      }
    }
  }
}
