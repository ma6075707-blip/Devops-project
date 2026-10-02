# -------------------------
# VPC Outputs
# -------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.devsecops.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.devsecops.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.devsecops.id
}

output "public_subnet_az1_id" {
  description = "Public subnet AZ-1 ID"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet AZ-2 ID"
  value       = aws_subnet.public_az2.id
}

output "private_subnet_az1_id" {
  description = "Private subnet AZ-1 ID"
  value       = aws_subnet.private_az1.id
}

output "private_subnet_az2_id" {
  description = "Private subnet AZ-2 ID"
  value       = aws_subnet.private_az2.id
}

output "nat_gateway_az1_id" {
  description = "NAT Gateway AZ-1 ID"
  value       = aws_nat_gateway.az1.id
}

output "nat_gateway_az2_id" {
  description = "NAT Gateway AZ-2 ID"
  value       = aws_nat_gateway.az2.id
}

# -------------------------
# EKS Outputs
# -------------------------

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_node_group_name" {
  description = "EKS node group name"
  value       = module.eks.node_group_name
}