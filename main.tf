# 1. Custom VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "iac-lab-vpc" }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id
  tags   = { Name = "iac-lab-igw" }
}

# 3. Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "iac-lab-public-subnet" }
}

# 4. Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }
  tags = { Name = "iac-lab-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. Security Group (SSH & HTTP)
resource "aws_security_group" "web_sg" {
  name        = "iac-web-sg"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. SSH Key Pair

resource "aws_key_pair" "deployer" {
  key_name   = "iac-lab-key"
  public_key = file(pathexpand(var.public_key_path))
}

# 7. EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = { Name = "iac-web-server" }
}
