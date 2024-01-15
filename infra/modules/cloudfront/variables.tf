variable "create_distribution" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = true
}

variable "create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = false
}

variable "origin_access_identities" {
  description = "Map of CloudFront origin access identities (value as a comment)"
  type        = map(string)
  default     = {}
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}


variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = null
}

variable "origin" {
  description = "One or more origins for this distribution (multiples allowed)."
  type        = any
  default     = null
}

variable "origin_group" {
  description = "One or more origin_group for this distribution (multiples allowed)."
  type        = any
  default     = {}
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN configuration for this distribution"
  type        = string
}

variable "geo_restriction" {
  description = "The restriction configuration for this distribution (geo_restrictions)"
  type        = any
  default     = {}
}

variable "custom_error_response" {
  description = "One or more custom error response elements"
  type        = any
  default     = {}
}

variable "default_cache_behavior" {
  description = "The default cache behavior for this distribution"
  type        = any
  default     = null
}

variable "ordered_cache_behavior" {
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type        = any
  default     = []
}

variable "create_monitoring_subscription" {
  description = "If enabled, the resource for monitoring subscription will created."
  type        = bool
  default     = false
}

variable "realtime_metrics_subscription_status" {
  description = "A flag that indicates whether additional CloudWatch metrics are enabled for a given CloudFront distribution. Valid values are `Enabled` and `Disabled`."
  type        = string
  default     = "Enabled"
}

### Route53
variable "create_route53_record" {
  description = "Whether to create DNS records"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "ID of DNS zone"
  type        = string
  default     = null
}

variable "zone_name" {
  description = "Name of DNS zone"
  type        = string
  default     = null
}

variable "private_zone" {
  description = "Whether Route53 zone is private or public"
  type        = bool
  default     = false
}

variable "record" {
  description = "List of maps of DNS records"
  type        = string
  default     = null
}

variable "waf_web_acl_id" {
  description = "WAF Web ACL Id"
  type        = string
  default     = null
}

variable "cf_environment" {
  description = "Environment Name"
  type        = string
}

variable "enable_origin_request_policy" {
  description = "Enable the origin request policy"
  type        = bool
  default     = false
}

variable "origin_request_policy_name" {
  description = "Unique name to identify the origin request policy"
  type        = string
  default     = null
}

variable "origin_request_policy_description" {
  description = "Comment to describe the origin request policy"
  type        = string
  default     = null
}

variable "cookie_behavior" {
  description = "Determines whether any cookies in viewer requests are included in the origin request key and automatically included in requests that CloudFront sends to the origin."
  type        = string
  default     = null
}

variable "cookies_items" {
  description = "Object that contains a list of cookie names"
  type        = list(string)
  default     = null
}

variable "header_behavior" {
  description = "Determines whether any HTTP headers are included in the origin request key and automatically included in requests that CloudFront sends to the origin."
  type        = string
  default     = null
}

variable "header_items" {
  description = "Object that contains a list of header names"
  type        = list(string)
  default     = null
}

variable "query_string_behavior" {
  description = "Determines whether any URL query strings in viewer requests are included in the origin request key and automatically included in requests that CloudFront sends to the origin."
  type        = string
  default     = null
}

variable "query_string_items" {
  description = "Object that contains a list of query string names"
  type        = list(string)
  default     = null
}

variable "origin_request_policy" {
  description = "Parameters to configure origin request policy"
  type        = map(any)
  default     = {}

  validation {
    condition     = length(var.origin_request_policy) == 0 || contains(["none", "whitelist", "all", "allExcept"], lookup(var.origin_request_policy, "cookie_behavior", ""))
    error_message = "Invalid value for cookie_behavior"
  }
  validation {
    condition     = length(var.origin_request_policy) == 0 || contains(["none", "whitelist", "allViewer", "allViewerAndWhitelistCloudFront", "allExcept"], lookup(var.origin_request_policy, "header_behavior", ""))
    error_message = "Invalid value for header_behavior"
  }
  validation {
    condition     = length(var.origin_request_policy) == 0 || contains(["none", "whitelist", "all", "allExcept"], lookup(var.origin_request_policy, "query_string_behavior", ""))
    error_message = "Invalid value for query_string_behavior"
  }
}

variable "cache_policy_id" {
  description = "Cache policy ID. "
  type        = string
  default     = null
}
