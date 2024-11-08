resource "aws_eks_cluster" "cmc-eks-cluster" {
  name = "${var.project_name}-eks"
  role_arn = var.cmc_role_eks
  vpc_config {
    security_group_ids = ["${aws_security_group.cmc-sg-cluster.id}"]
    subnet_ids = [ 
        var.public_subnet_1a,
        var.public_subnet_1b,
        var.private_subnet_1a,
        var.private_subnet_1b
     ]
  }
  depends_on = [ var.cmc-att-amazoneEKSClusterPolicy ]
}

resource "aws_security_group" "cmc-sg-cluster" {
  name        = "eks-sg-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-eks"
  }
}

resource "aws_eks_node_group" "cmc_private_node" {
  cluster_name = aws_eks_cluster.cmc-eks-cluster.name
  node_group_name = "${var.project_name}-private-nodes"
  node_role_arn = var.cmc_role_nodes
  subnet_ids = [ 
    var.private_subnet_1a,
    var.private_subnet_1b
   ]
  capacity_type = "ON_DEMAND"
  instance_types = ["t3.small"]
  scaling_config {
    desired_size = 1
    max_size = 4
    min_size = 1
  }
  update_config {
    max_unavailable = 1
  }
  labels = {
    role = "general"
  }
  depends_on = [ 
    var.cmc-att-amazoneEKSCNIPolicy,
    var.cmc-att-amazoneEKSWorkerNodePolicy,
    var.mc-att-AmazonEC2ContainerRegistryFullAccess,
   ]
  tags = {
    Name = "${var.project_name}-sg-eks"
  }
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.cmc-eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cmc-eks-openid" {
  client_id_list = ["sts.amazoneaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.cmc-eks-cluster.identity[0].oidc[0].issuer
}
data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    condition {
      test = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cmc-eks-openid.url, "https://","")}:sub"
      values = ["system:serviceaccount:default:duclm3"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.cmc-eks-openid.arn]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "${var.project_name}-test-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
  })
}




resource "aws_iam_role_policy_attachment" "test_attach" {
  role = aws_iam_role.test_oidc.name
  policy_arn = aws_iam_policy.test-policy.arn
}

