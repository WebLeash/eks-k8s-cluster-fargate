# Outputs
output "endpoint" {
  value = aws_eks_cluster.eks-demo-cluster-01.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-demo-cluster-01.certificate_authority[0].data
}

output "vpc_id" {
  value = aws_vpc.eks-demo-vpc-01.id
}

output "subnet_ids" {
  value = [
    aws_subnet.eks-demo-public-01.id,
    aws_subnet.eks-demo-public-02.id,
    aws_subnet.eks-demo-private-01.id,
    aws_subnet.eks-demo-private-02.id
  ]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.eks-demo-internet-gateway-01.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.eks-demo-internet-nat.id
}

output "cluster_arn" {
  value = aws_eks_cluster.eks-demo-cluster-01.arn
}

output "nat_gateway_elastic_ip" {
  value       = aws_nat_gateway.eks-demo-internet-nat.allocation_id
  description = "Elastic IP associated with the NAT Gateway"
}

output "nat_gateway_ip_address" {
  value       = aws_eip.demo-eip-01.public_ip
  description = "Public IP address of the Elastic IP associated with the NAT Gateway"
}