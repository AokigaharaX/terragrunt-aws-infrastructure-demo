locals {
  region      = "us-east-1"
  environment = "QA"
  common_tags = {
    Provisioner = "Terraform"
    Project     = "DevOps"
    Environment = local.environment
  }
  # remove all ".terragrunt-stack/" from the path
  clean_path = replace(path_relative_to_include(), ".terragrunt-stack/", "")
  # unit (e.g. "vpc")
  unit_name = basename(local.clean_path)
  # stack name (e.g. "configuration-center-api")
  stack_name = basename(dirname(local.clean_path))
  stack_path = "${local.stack_name}/${local.unit_name}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket       = "demo-iac-terraform-state"
    key          = "infrastructure/${lower(local.environment)}/${local.region}/${local.stack_path}/terraform.tfstate"
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
