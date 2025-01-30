# Step 1: Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Allow traffic from app layer EC2 to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.app_sg.id]  # Reference to App Layer Security Group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Step 2: Create the RDS Subnet Group (Private Subnet)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]  # Ensure private subnet ID is correct

  tags = {
    Name = "RDS Subnet Group"
  }
}

# Step 3: Store the RDS Password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds-password"
  description = "RDS PostgreSQL Password"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({ password = "your-secure-password" })  # Replace with a secure password
}

# Step 4: Create the RDS PostgreSQL Instance
resource "aws_db_instance" "rds_postgresql" {
  identifier             = "my-postgresql-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20  # Adjust storage size based on requirements
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username = "admin"
  password = jsondecode(aws_secretsmanager_secret_version.rds_password_version.secret_string)["password"]
  db_name  = "mydb"

  backup_retention_period = 7
  multi_az                = false
  tags = {
    Name = "PostgreSQL DB Instance"
  }

  publicly_accessible = false  # The database is not publicly accessible
  storage_encrypted  = true    # Encrypt the storage for added security
}

# Optional: Create a VPC for the database and application layers (if not already created)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Optional: Create Subnet for the private subnet (RDS layer)
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"  # Ensure this subnet is private
  availability_zone       = "ca-central-1a"  # Adjust for your region
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet"
  }
}
