# README #

terragrunt-aws-infrastructure-demo

### What is this repository for? ###

* Demo infrastructure for dev/qa
* Terragrunt Stacks

### Notes
Units implementations are managed in infrastructure catalog: [Infrastructure Catalog](https://github.com/AokigaharaX/terragrunt-aws-catalog-demo)

### Plan, apply and destroy etc. ###
* Perform the following at the directory where there's `terragrunt.stack.hcl`
```
terragrunt stack run --non-interactive plan -- [-destroy]
terragrunt stack run --non-interactive apply
```
* Perform the following to generate the DAG
```
terragrunt dag graph  | dot -Tpng > graph.png
```
