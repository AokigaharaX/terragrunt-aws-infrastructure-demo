locals {
  env           = "DEV"
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
    name                  = "${local.env}-SM-DB-DEM0-2-API"
    secret_string         = "-"
    description           = "${local.env}-SM-DB-DEM0-2-API"
    ignore_secret_changes = true
    tags                  = local.service_tags
  }
}

unit "eks-pod-identity" {
  source = "${local.infra_catalog}/demo-2-api/eks-pod-identity?ref=main"
  path   = "eks-pod-identity"

  values = {
    name = "${local.env}-ROLE-SVC-DEMO-2-API"
    tags = local.service_tags
    common_secrets_arns = [
      "arn:aws:secretsmanager:ap-southeast-1:${get_aws_account_id()}:secret:DEV-SM-SHARE-1",
      "arn:aws:secretsmanager:ap-southeast-1:${get_aws_account_id()}:secret:DEV-SM-SHARE-2"
    ]
    pod-identity-association = {
      cluster_name    = "DEV-EKS-CLUSTER"
      namespace       = "my-namespace"
      service_account = "demo-2-api-service-account"
    }
  }
}

unit "route53" {
  source = "${local.infra_catalog}/route53/records?ref=main"
  path   = "route53"

  values = {
    zone_name = "dev.example.com"
    records = [
      {
        name = "demo-2-api"
        type = "A"
        alias = {
          name    = "some-istio.elb.ap-southeast-1.amazonaws.com"
          zone_id = "xxxxx"
        }
      }
    ]
  }
}