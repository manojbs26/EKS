module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true

  tags = {
    cluster = "demo"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
}
resource "aws_s3_bucket" "remote-state" {
    bucket = "terraform-state-file-26072024"
    force_destroy = true 
}

resource "aws_s3_bucket_versioning" "s3-versioning" {
    bucket = aws_s3_bucket.remote-state.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "remote-statelock" {
    name = "dynamodb-statelock"
    billing_mode = "PROVISIONED"
    read_capacity = 20
    write_capacity = 20
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
