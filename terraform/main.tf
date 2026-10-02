terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  profile = "user-terraform"
  region  = var.aws_region
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "devsecops" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "devsecops" {
  vpc_id = aws_vpc.devsecops.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# -------------------------
# Public Subnet AZ-1
# -------------------------

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.devsecops.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-az1"
  }
}

# -------------------------
# Public Subnet AZ-2
# -------------------------

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.devsecops.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-az2"
  }
}

# -------------------------
# Private Subnet AZ-1
# -------------------------

resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.devsecops.id
  cidr_block        = var.private_subnet_az1_cidr
  availability_zone = var.az1

  tags = {
    Name = "${var.vpc_name}-private-az1"
  }
}

# -------------------------
# Private Subnet AZ-2
# -------------------------

resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.devsecops.id
  cidr_block        = var.private_subnet_az2_cidr
  availability_zone = var.az2

  tags = {
    Name = "${var.vpc_name}-private-az2"
  }
}

# -------------------------
# Elastic IP for NAT AZ-1
# -------------------------

resource "aws_eip" "nat_az1" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-az1"
  }
}

# -------------------------
# Elastic IP for NAT AZ-2
# -------------------------

resource "aws_eip" "nat_az2" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-az2"
  }
}

# -------------------------
# NAT Gateway AZ-1
# -------------------------

resource "aws_nat_gateway" "az1" {
  allocation_id = aws_eip.nat_az1.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name = "${var.vpc_name}-nat-az1"
  }

  depends_on = [
    aws_internet_gateway.devsecops
  ]
}

# -------------------------
# NAT Gateway AZ-2
# -------------------------

resource "aws_nat_gateway" "az2" {
  allocation_id = aws_eip.nat_az2.id
  subnet_id     = aws_subnet.public_az2.id

  tags = {
    Name = "${var.vpc_name}-nat-az2"
  }

  depends_on = [
    aws_internet_gateway.devsecops
  ]
}

# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devsecops.id

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# -------------------------
# Public Internet Route
# -------------------------

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devsecops.id
}

# -------------------------
# Public Route Associations
# -------------------------

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Private Route Table AZ-1
# -------------------------

resource "aws_route_table" "private_az1" {
  vpc_id = aws_vpc.devsecops.id

  tags = {
    Name = "${var.vpc_name}-private-rt-az1"
  }
}

# -------------------------
# Private Route AZ-1
# -------------------------

resource "aws_route" "private_az1_internet" {
  route_table_id         = aws_route_table.private_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az1.id
}

# -------------------------
# Private Route Association AZ-1
# -------------------------

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private_az1.id
}

# -------------------------
# Private Route Table AZ-2
# -------------------------

resource "aws_route_table" "private_az2" {
  vpc_id = aws_vpc.devsecops.id

  tags = {
    Name = "${var.vpc_name}-private-rt-az2"
  }
}

# -------------------------
# Private Route AZ-2
# -------------------------

resource "aws_route" "private_az2_internet" {
  route_table_id         = aws_route_table.private_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2.id
}

# -------------------------
# Private Route Association AZ-2
# -------------------------

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private_az2.id
}

# -------------------------
# EKS Module
# -------------------------

module "eks" {
  source = "./eks"

  cluster_name = var.eks_cluster_name

  vpc_id = aws_vpc.devsecops.id

  private_subnet_ids = [
    aws_subnet.private_az1.id,
    aws_subnet.private_az2.id
  ]

  node_instance_type = var.eks_node_instance_type

  desired_size = var.eks_desired_size
  min_size     = var.eks_min_size
  max_size     = var.eks_max_size
}