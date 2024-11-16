# Addons
resource "aws_eks_addon" "eks-demo-addon-coredns" {
  cluster_name  = aws_eks_cluster.eks-demo-cluster-01.name
  addon_name    = "coredns"
  addon_version = "v1.10.1-eksbuild.4"
  # addon_version               = "v1.11.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "eks-demo-addon-kube-proxy" {
  cluster_name  = aws_eks_cluster.eks-demo-cluster-01.name
  addon_name    = "kube-proxy"
  addon_version = "v1.28.2-eksbuild.2"
  #  addon_version               = "v1.11.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "eks-demo-addon-vpc-cni" {
  cluster_name  = aws_eks_cluster.eks-demo-cluster-01.name
  addon_name    = "vpc-cni"
  addon_version = "v1.15.1-eksbuild.1"
  # addon_version               = "v1.15.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}
