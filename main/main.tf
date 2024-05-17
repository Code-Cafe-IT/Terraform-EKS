provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

module "aws_vpc" {
  source = "../module/vpc"
  vpc_id = var.vpc_id
  project_name = var.project_name
  public_subnet_1a = var.public_subnet_1a
  public_subnet_1b = var.public_subnet_1b
  private_subnet_1a = var.private_subnet_1a
  private_subnet_1b = var.private_subnet_1b
}
module "aws_role" {
  source = "../module/iam"
  project_name = var.project_name
}

module "aws-eks" {
  source = "../module/eks"
  project_name = var.project_name
  vpc_id = module.aws_vpc.vpc_id
  cmc_role_eks = module.aws_role.eks-role-eks
  cmc_role_nodes = module.aws_role.eks-role-nodes
  public_subnet_1b = module.aws_vpc.public_subnet_1a
  public_subnet_1a = module.aws_vpc.public_subnet_1b
  private_subnet_1a = module.aws_vpc.private_subnet_1a
  private_subnet_1b = module.aws_vpc.private_subnet_1b
  cmc-att-amazoneEKSWorkerNodePolicy = module.aws_role.cmc-att-amazoneEKSWorkerNodePolicy
  cmc-att-amazoneEKSCNIPolicy =module.aws_role.cmc-att-amazoneEKSCNIPolicy
  mc-att-AmazonEC2ContainerRegistryFullAccess = module.aws_role.cmc-att-AmazonEC2ContainerRegistryFullAccess
  cmc-att-amazoneEKSClusterPolicy = module.aws_role.cmc-att-amazoneEKSClusterPolicy
}