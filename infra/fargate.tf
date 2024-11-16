resource "aws_eks_fargate_profile" "fargate-demo-01" {
  cluster_name           = aws_eks_cluster.eks-demo-cluster-01.name
  fargate_profile_name   = "fargate-uae-terraform-managed"
  pod_execution_role_arn = aws_iam_role.eks-fargate-demo-profile-role-01.arn
  subnet_ids = [
    aws_subnet.eks-demo-private-01.id,
    aws_subnet.eks-demo-private-02.id
  ]

  selector {
    namespace = "staging"
  }

  selector {
    namespace = "production"
  }

}
