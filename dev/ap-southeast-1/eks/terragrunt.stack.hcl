unit "eks" {
  source = "git::https://github.com/AokigaharaX/terragrunt-aws-catalog-demo.git///units/eks?ref=main"
  path   = "eks"

  values = {
    cluster_name               = "DEV-EKS-CLUSTER"
    kubernetes_version         = "1.32"
    cluster_encryption_key_arn = "arn:aws:kms:ap-southeast-1:${get_aws_account_id()}:key/7062469b-ec26-49ad-9b0a-d2c23d68d2b2"
    cluster_iam_role_arn       = "arn:aws:iam::${get_aws_account_id()}:role/DEV-EKS-ROLE"
    node_role_arn              = "arn:aws:iam::${get_aws_account_id()}:role/DEV-AmazonEKSAutoNodeRole"
    vpc_id                     = "vpc-xxx"
    subnet_ids = [
      "subnet-xxx1",
      "subnet-xxx2",
      "subnet-xxx3",
      "subnet-xxx4"
    ]
    cluster_additional_sg_ids = [
      "sg-xxx1",
      "sg-xxx2",
      "sg-xxx3"
    ]
    tags = {
      AutoMode = "true"
    }
  }
}