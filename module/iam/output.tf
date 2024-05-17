output "eks-role-eks" {
  value = aws_iam_role.cmc_role_eks.arn
}

output "eks-role-nodes" {
  value = aws_iam_role.cmc_role_nodes.arn
}

output "cmc-att-amazoneEKSWorkerNodePolicy" {
  value = aws_iam_role_policy_attachment.cmc-att-amazoneEKSWorkerNodePolicy
}
output "cmc-att-amazoneEKSCNIPolicy" {
  value = aws_iam_role_policy_attachment.cmc-att-amazoneEKSCNIPolicy
}
output "cmc-att-AmazonEC2ContainerRegistryFullAccess" {
  value = aws_iam_role_policy_attachment.cmc-att-AmazonEC2ContainerRegistryFullAccess
}
output "cmc-att-amazoneEKSClusterPolicy" {
  value = aws_iam_role_policy_attachment.cmc-att-amazoneEKSClusterPolicy
}


