module "vpc" {
  source       = "./modules/vpc"
  environment  = var.environment
  cluster_name = "twitter-clone-eks-${var.environment}"
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "twitter-clone-app-${var.environment}"
}

module "ecr_frontend" {
  source          = "./modules/ecr"
  repository_name = "twitter-clone-frontend-${var.environment}"
}

module "ecr_backend" {
  source          = "./modules/ecr"
  repository_name = "twitter-clone-backend-${var.environment}"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = "twitter-clone-eks-${var.environment}"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
  environment  = var.environment
}

module "rds" {
  source                    = "./modules/rds"
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id = module.eks.cluster_security_group_id
}

module "elasticache" {
  source                    = "./modules/elasticache"
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id = module.eks.cluster_security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_frontend_repository_url" {
  value = module.ecr_frontend.repository_url
}

output "ecr_backend_repository_url" {
  value = module.ecr_backend.repository_url
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}
