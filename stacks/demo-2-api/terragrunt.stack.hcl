locals {
  infra_catalog = "git::https://github.com/AokigaharaX/terragrunt-aws-catalog-demo.git///units"
  service_tags = {
    "Service" : "demo-2-api"
  }
}

unit "ecr" {
  source = "${local.infra_catalog}/ecr?ref=main"
  path   = "ecr"

  values = {
    repo_name = "demo-2-api"
    tags      = local.service_tags
  }
}

unit "secrets-manager" {
  source = "${local.infra_catalog}/secrets-manager?ref=main"
  path   = "secrets-manager"

  values = {
    name                  = "${values.env}-SM-DB-DEMO-2-API"
    secret_string         = "-"
    description           = "${values.env}-SM-DB-DEMO-2-API"
    ignore_secret_changes = true
    tags                  = local.service_tags
  }
}

unit "eks-pod-identity" {
  source = "${local.infra_catalog}/demo-2-api/eks-pod-identity?ref=main"
  path   = "eks-pod-identity"

  values = {
    name = "${values.env}-ROLE-SVC-DEMO-2-API"
    tags = local.service_tags
    common_secrets_arns = [
      "arn:aws:secretsmanager:us-east-1:${get_aws_account_id()}:secret:${values.env}-SM-SHARE-1",
      "arn:aws:secretsmanager:us-east-1:${get_aws_account_id()}:secret:${values.env}-SM-SHARE-2"
    ]
    pod-identity-association = {
      cluster_name    = "${values.env}-EKS-CLUSTER"
      namespace       = "my-namespace"
      service_account = "demo-2-api-api-service-account"
    }
  }
}

unit "target_group" {
  source = "${local.infra_catalog}/target-group?ref=main"
  path   = "target-group"

  values = {
    name              = "${values.env}-TG-DEMO-2-API"
    vpc_id            = "vpc-xxx"
    health_check_path = "/actuator/health"
    listener_arn      = "arn:aws:elasticloadbalancing:us-east-1:${get_aws_account_id()}:listener/app/${values.env}-ALB-TEST/xxxxx/xxxxx"
    priority          = 30
    host_headers = [
      "demo-2-api.${values.env}.example.com"
    ]
    tags = local.service_tags
  }
}

unit "route53" {
  source = "${local.infra_catalog}/route53/records?ref=main"
  path   = "route53"

  values = {
    zone_name = "${lower(values.env)}.example.com"
    records = [
      {
        name = "demo-2-api"
        type = "A"
        alias = {
          name    = "dualstack.internal-${values.env}-ALB-DEMO-2-API-xxx.us-east-1.elb.amazonaws.com"
          zone_id = "XXX"
        }
      }
    ]
  }
}