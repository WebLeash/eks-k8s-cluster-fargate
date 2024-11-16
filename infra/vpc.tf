# VPC-01
resource "aws_vpc" "eks-demo-vpc-01" {
  cidr_block = "10.0.0.0/16"

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "uae-eks-cluster-terraform-managed"
  }
}

# Public Subnet in AZ 1
resource "aws_subnet" "eks-demo-public-01" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "me-central-1a"
  vpc_id                  = aws_vpc.eks-demo-vpc-01.id
  map_public_ip_on_launch = true
  tags = {
    Name                     = "eks-uae-public-01"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnet in AZ 1
resource "aws_subnet" "eks-demo-private-01" {
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "me-central-1a"
  vpc_id                  = aws_vpc.eks-demo-vpc-01.id
  map_public_ip_on_launch = false
  tags = {
    Name                              = "eks-uae-private-01"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Public Subnet in AZ 2
resource "aws_subnet" "eks-demo-public-02" {
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "me-central-1b"
  vpc_id                  = aws_vpc.eks-demo-vpc-01.id
  map_public_ip_on_launch = true
  tags = {
    Name                     = "eks-uae-public-02"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnet in AZ 2
resource "aws_subnet" "eks-demo-private-02" {
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "me-central-1b"
  vpc_id                  = aws_vpc.eks-demo-vpc-01.id
  map_public_ip_on_launch = false
  tags = {
    Name                              = "eks-uae-private-02"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# EIP
resource "aws_eip" "demo-eip-01" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.eks-demo-internet-gateway-01]
  tags = {
    Name = "uae-eks-eip-01-terraform-managed"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks-demo-internet-gateway-01" {
  vpc_id = aws_vpc.eks-demo-vpc-01.id
  tags = {
    Name = "eks-uae-internet-gateway-terraform-managed"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "eks-demo-internet-nat" {
  allocation_id = aws_eip.demo-eip-01.id
  subnet_id     = aws_subnet.eks-demo-public-01.id

  tags = {
    Name = "eks-uae-net-gateway-terraform-managed"
  }

  depends_on = [aws_internet_gateway.eks-demo-internet-gateway-01]
}

# Public Route Table
resource "aws_route_table" "eks-demo-public" {
  vpc_id = aws_vpc.eks-demo-vpc-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-demo-internet-gateway-01.id
  }

  tags = {
    Name = "eks-uae-public-terraform-managed"
  }
}

# Private Route Table
resource "aws_route_table" "eks-demo-private" {
  vpc_id = aws_vpc.eks-demo-vpc-01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-demo-internet-nat.id
  }

  tags = {
    Name = "eks-uae-private-terraform-managed"
  }
}

# Route Table Associations
resource "aws_route_table_association" "private-me-central-1a" {
  subnet_id      = aws_subnet.eks-demo-private-01.id
  route_table_id = aws_route_table.eks-demo-private.id
}

resource "aws_route_table_association" "private-me-central-1b" {
  subnet_id      = aws_subnet.eks-demo-private-02.id
  route_table_id = aws_route_table.eks-demo-private.id
}

resource "aws_route_table_association" "public-me-central-1a" {
  subnet_id      = aws_subnet.eks-demo-public-01.id
  route_table_id = aws_route_table.eks-demo-public.id
}

resource "aws_route_table_association" "public-me-central-1b" {
  subnet_id      = aws_subnet.eks-demo-public-02.id
  route_table_id = aws_route_table.eks-demo-public.id
}
