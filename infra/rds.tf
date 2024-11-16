resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.eks-demo-private-01.id, aws_subnet.eks-demo-private-02.id] # Use both private subnets

  tags = {
    Name = "rds-subnet-group-new-terraform-managed"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "uae-staging"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.4"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username = var.rds_master_username_staging # Use the variable for username
  password = var.rds_master_password_staging # Use the variable for password

  skip_final_snapshot = true
}

resource "aws_db_instance" "rds_instance_prod" {
  identifier             = "uae-production"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.4"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username = var.rds_username_master_prod # Use the variable for username
  password = var.rds_password_master_prod # Use the variable for password

  skip_final_snapshot = true
}


resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.eks-demo-vpc-01.id

  # Allow inbound MySQL (port 3306) traffic from the ECS security group
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  }

  # Allow inbound PostgreSQL (port 5432) traffic from the EKS security group
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.2.0/24"]
  }

  # Allow all outbound traffic (though RDS typically doesn't initiate outbound connections)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group-terraform-managed"
  }
}

#-------  output --------
#-------------------------

output "rds_endpoint" {
  value       = aws_db_instance.rds_instance.address
  description = "The endpoint of the RDS instance."
}
output "rds_endpoint_prod" {
  value       = aws_db_instance.rds_instance_prod.address
  description = "The endpoint of the RDS PROD instance."
}

# Write the output to a file in your Terraform script
resource "null_resource" "write_staging_rds_info" {
  provisioner "local-exec" {
    command = "echo staging '${aws_db_instance.rds_instance.address}' >> rds_endpoint.txt"
  }

  triggers = {
    always_run = "${timestamp()}" # This will always trigger the provisioner to run
  }
  depends_on = [aws_db_instance.rds_instance]
}

# Write the production RDS endpoint to a file
resource "null_resource" "write_prod_rds_info" {
  provisioner "local-exec" {
    command = "echo production '${aws_db_instance.rds_instance_prod.address}' >> rds_endpoint.txt"
  }

  triggers = {
    always_run = "${timestamp()}" # This will always trigger the provisioner to run
  }
  depends_on = [aws_db_instance.rds_instance_prod]
}
