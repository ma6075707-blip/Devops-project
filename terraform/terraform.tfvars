aws_region = "eu-west-1"

vpc_cidr = "10.0.0.0/16"

vpc_name = "devsecops-vpc"

az1 = "eu-west-1a"
az2 = "eu-west-1b"

public_subnet_az1_cidr = "10.0.1.0/24"

public_subnet_az2_cidr = "10.0.2.0/24"

private_subnet_az1_cidr = "10.0.11.0/24"

private_subnet_az2_cidr = "10.0.12.0/24"

# -------------------------
# EKS
# -------------------------

eks_cluster_name = "devsecops-eks"

eks_node_instance_type = "t3.medium"

eks_desired_size = 2

eks_min_size = 2

eks_max_size = 4