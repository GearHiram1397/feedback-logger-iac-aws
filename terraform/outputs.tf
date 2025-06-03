output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.app.name
}

output "public_subnets" {
  description = "Public Subnets"
  value       = module.vpc.public_subnets
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.feedback_logger.repository_url
} 
