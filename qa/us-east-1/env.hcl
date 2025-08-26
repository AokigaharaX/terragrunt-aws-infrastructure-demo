locals {
  region      = "us-east-1"
  environment = "QA"
  common_tags = {
    Provisioner = "Terraform"
    Project     = "DevOps"
    Environment = local.environment
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket       = "demo-iac-terraform-state"
    key          = "infrastructure/${lower(local.environment)}/${local.region}/${replace(path_relative_to_include(), ".terragrunt-stack/", "")}/terraform.tfstate"
    region       = local.region
    encrypt      = true
    use_lockfile = true
  }
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}
