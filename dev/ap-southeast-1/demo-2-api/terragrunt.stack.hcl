stack "demo-2-api" {
  source = "${get_terragrunt_dir()}/../../../stacks/demo-2-api"
  path   = "demo-2-api"
  values = {
    env = "DEV"
  }
}