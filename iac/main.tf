provider "aws" {
  region = "eu-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "ml-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags = {
    Name = "ml-vpc"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "ml-cluster"
  cluster_version = "1.32"
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.xlarge"]
      desired_size   = 1
      max_size       = 1
      min_size       = 1
    }
  }

  tags = {
    Environment = "test"
  }
}
