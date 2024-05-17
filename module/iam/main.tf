resource "aws_iam_role" "cmc_role_eks" {
  name = "${var.project_name}-role-eks"
  assume_role_policy = <<POLICY
  {
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "eks",
			"Effect": "Allow",
			"Principal": {
                "Service": "eks.amazonaws.com"
            },
			"Action": "sts:AssumeRole"
		}
	]
}
  POLICY
}

resource "aws_iam_role" "cmc_role_nodes" {
  name = "${var.project_name}-eks-nodes-groups"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cmc-att-amazoneEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.cmc_role_nodes.name
}

resource "aws_iam_role_policy_attachment" "cmc-att-amazoneEKSCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.cmc_role_nodes.name
}
resource "aws_iam_role_policy_attachment" "cmc-att-AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role = aws_iam_role.cmc_role_nodes.name
}


resource "aws_iam_role_policy_attachment" "cmc-att-amazoneEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cmc_role_eks.name
}

