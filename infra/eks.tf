# EKS Cluster
resource "aws_eks_cluster" "eks-demo-cluster-01" {
  name     = "eks-uae-cluster-terraform"
  version  = "1.28"
  role_arn = aws_iam_role.eks-demo-cluster-admin-role-01.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.eks-demo-public-01.id,
      aws_subnet.eks-demo-public-02.id
    ]
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-demo-cluster-01-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-demo-cluster-01-AmazonEKSVPCResourceController
  ]
  tags = {
    demo = "uae-terraform-managed"
  }
}
