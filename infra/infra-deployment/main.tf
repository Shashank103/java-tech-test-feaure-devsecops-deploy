module "ecr" {
  source        = "../modules/ecr"
  ecr_repo_name = var.ecr_repo_name
}

module "vpc" {
  source              = "../modules/vpc"
  account_environment = var.account_environment
  availability_zones  = var.availability_zones
  team_name           = var.team_name
}

module "security-group" {
  source              = "../modules/security-group"
  account_environment = var.account_environment
  team_name           = var.team_name
  vpc_id              = module.vpc.vpc_id
}

module "network" {
  source              = "../modules/network"
  account_environment = var.account_environment
  team_name           = var.team_name
  public-subnet-1_id  = module.vpc.public-subnet-1
  public-subnet-2_id  = module.vpc.public-subnet-2
  private-subnet-1_id = module.vpc.private-subnet-1
  private-subnet-2_id = module.vpc.private-subnet-2
  vpc_id              = module.vpc.vpc_id
}

module "iam" {
  source              = "../modules/iam"
  account_environment = var.account_environment
  team_name           = var.team_name
}

module "alb" {
  source              = "../modules/alb"
  account_environment = var.account_environment
  team_name           = var.team_name
  public-subnet-1_id  = module.vpc.public-subnet-1
  public-subnet-2_id  = module.vpc.public-subnet-2
  vpc_id              = module.vpc.vpc_id
  alb_security_group  = module.security-group.alb_security_group_id
}

module "ecs-cluster" {
  source              = "../modules/ecs-cluster"
  account_environment = var.account_environment
  team_name           = var.team_name
}

module "ecs-service" {
  source              = "../modules/ecs-service"
  account_environment = var.account_environment
  team_name           = var.team_name
  ecs_cluster_id      = module.ecs-cluster.ecs_cluster_id
  ecs_role            = module.iam.iam_role_arn
  image_name          = var.image_name
  port                = var.port
  private_subnets     = [module.vpc.private-subnet-1, module.vpc.private-subnet-2]
  region              = var.region
  replicas            = var.replicas
  service_tg_arn      = module.alb.target_group_arn
  task_family_name    = var.task_family_name
  application_sg      = module.security-group.service-sg
}

#module "cloudfront" {
#  source              = "../modules/cloudfront"
#  create_route53_record = true
#  zone_name             = "xyz232429"
#  record                = "abc.com"
#
#  cf_environment = "devl"
#  aliases = [
#    "abc.test.com"
#  ]
#
#  origin = {
#    alb = {
#      domain_name = "abc.test.com"
#      custom_origin_config = {
#        http_port              = 80
#        https_port             = 443
#        origin_protocol_policy = "https-only"
#        origin_ssl_protocols   = ["TLSv1.2"]
#      }
#    }
#  }
#
#  default_cache_behavior = {
#    path_pattern           = "*"
#    target_origin_id       = "alb"
#    viewer_protocol_policy = "redirect-to-https"
#
#    default_ttl = 86400
#    min_ttl     = 0
#    max_ttl     = 31536000
#
#    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "DELETE", "PATCH"]
#    cached_methods  = ["GET", "HEAD", "OPTIONS"]
#    compress        = true
#    query_string    = true
#
#    use_forwarded_values = true
#    headers              = ["*"]
#    cookies_forward      = "all"
#  }
#
#  ordered_cache_behavior = {
#    403 = {
#      path_pattern           = "/4xx-errors/*"
#      target_origin_id       = "s3"
#      viewer_protocol_policy = "redirect-to-https"
#
#      default_ttl = 86400
#      min_ttl     = 10
#      max_ttl     = 31536000
#
#      allowed_methods = ["GET", "HEAD", "OPTIONS"]
#      cached_methods  = ["GET", "HEAD", "OPTIONS"]
#      compress        = true
#      query_string    = true
#    }
#
#    504 = {
#      path_pattern           = "/5xx-errors/*"
#      target_origin_id       = "s3"
#      viewer_protocol_policy = "redirect-to-https"
#
#      default_ttl = 86400
#      min_ttl     = 10
#      max_ttl     = 31536000
#
#      allowed_methods = ["GET", "HEAD", "OPTIONS"]
#      cached_methods  = ["GET", "HEAD", "OPTIONS"]
#      compress        = true
#      query_string    = true
#    }
#  }
#  acm_certificate_arn = "arnofacmcertificate"
#}