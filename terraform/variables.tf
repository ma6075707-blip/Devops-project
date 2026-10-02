variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "az1" {
  description = "First Availability Zone"
  type        = string
}

variable "az2" {
  description = "Second Availability Zone"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "Public subnet CIDR for AZ-1"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "Public subnet CIDR for AZ-2"
  type        = string
}

variable "private_subnet_az1_cidr" {
  description = "Private subnet CIDR for AZ-1"
  type        = string
}

variable "private_subnet_az2_cidr" {
  description = "Private subnet CIDR for AZ-2"
  type        = string
}

# -------------------------
# EKS
# -------------------------

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_node_instance_type" {
  description = "EKS worker node instance type"
  type        = string
}

variable "eks_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
}

variable "eks_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
}