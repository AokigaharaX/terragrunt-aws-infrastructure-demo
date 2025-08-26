locals {
  env           = "DEV"
  infra_catalog = "git::https://github.com/AokigaharaX/terragrunt-aws-catalog-demo.git///units"
  service_tags = {
    "Service" : "demo-api"
  }
}

unit "s3" {
  source = "${local.infra_catalog}/s3?ref=main"
  path   = "s3"

  values = {
    bucket_name   = "${lower(local.env)}-s3-demo-lambda-package"
    force_destroy = true
    tags = merge(local.service_tags, {
      "Project" : "DevOps-Shared"
    })
  }
}

unit "efs" {
  source = "${local.infra_catalog}/efs?ref=main"
  path   = "efs"

  values = {
    name = "${local.env}-EFS-DEMO-API-DATA"
    mount_target = {
      "ap-southeast-1a" = {
        subnet_id = "subnet-064638d1c7af1ee82"
      }
      "ap-southeast-1b" = {
        subnet_id = "subnet-0ae321ca94fc0df91"
      }
    }
    security_group_vpc_id = "vpc-06a2bbb02f091383e"
    security_group_rules = {
      vpc = {
        description = "NFS ingress from VPC private subnets"
        cidr_blocks = [
          "172.10.1.0/24",
          "172.10.3.0/24",
          "172.10.4.0/24",
          "172.10.5.0/24"
        ]
      }
      egress = {
        type        = "egress"
        description = "Allow all outbound traffic"
        protocol    = "all"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    access_points = {
      demo = {
        name = "${local.env}_DEMO_API_EFS"
        posix_user = {
          gid = 1001
          uid = 1001
        }
        root_directory = {
          path = "/lambda"
          creation_info = {
            owner_gid   = 1001
            owner_uid   = 1001
            permissions = "755"
          }
        }
      }
    }
    tags = local.service_tags
  }
}

unit "ecr" {
  source = "${local.infra_catalog}/ecr?ref=main"
  path   = "ecr"

  values = {
    repo_name = "demo-api"
    tags      = local.service_tags
  }
}

unit "lambda_layer" {
  source = "${local.infra_catalog}/demo-api/lambda_layer?ref=main"
  path   = "lambda_layer"
}

unit "lambda_function" {
  source = "${local.infra_catalog}/demo-api/lambda_function?ref=main"
  path   = "lambda_function"

  values = {
    function_name = "${local.env}-LAMBDA-DEMO-API"
    description   = "Lambda function for demo"
    handler       = "maxmind_db.lambda_handler"
    environment_variables = {
      ENVIRONMENT    = "${local.env}"
      MY_SECRET_NAME = "${local.env}-SM-DEMO-API"
    }
    subnets = [
      "subnet-xxxx1",
      "subnet-xxxx2"
    ]
    security_group_ids = [
      "sg-xxxx"
    ]
    mountpoint_path        = "/mnt/efs-fg"
    license_key_secret_arn = "arn:aws:secretsmanager:ap-southeast-1:get:secret:DEV-SM-DEMO-API"
    tags = merge(
      local.service_tags,
      {
        OutputDestination = "EFS"
        ScheduleType      = "rate"
        Schedule          = "24 hours"
      }
    )
  }
}

unit "scheduler" {
  source = "${local.infra_catalog}/demo-api/scheduler?ref=main"
  path   = "scheduler"

  values = {
    name = "${local.env}-EB-DEMO-API-LAMBDA"
  }
}

unit "eks-pod-identity" {
  source = "${local.infra_catalog}/eks-pod-identity/efs?ref=main"
  path   = "eks-pod-identity"

  values = {
    name             = "${local.env}-ROLE-DEMO-API"
    policy_name      = "${local.env}-POLICY-DEMO-API-EFS-CSI"
    eks_cluster_name = "${local.env}-EKS-CLUSTER"
    tags             = local.service_tags
  }
}