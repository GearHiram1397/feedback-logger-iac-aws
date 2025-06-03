# Provider
provider "aws" {
  region = var.aws_region
}

# VPC
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "4.0.2"
  name               = "feedback-logger-vpc"
  cidr               = var.vpc_cidr
  azs                = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets     = var.public_subnets
  enable_nat_gateway = false
  enable_vpn_gateway = false
}

# ECR Repository
resource "aws_ecr_repository" "feedback_logger" {
  name = "feedback-logger-repo"
}

# IAM Roles for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "feedback-logger-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "feedback-logger-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "feedback-logger"
      image     = var.ecr_image_url
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
      environment = [
        { name = "PORT", value = "3000" },
        { name = "API_SECRET", value = var.api_secret }
      ]
    }
  ])
}

# Security Group for ECS Service
resource "aws_security_group" "ecs_service" {
  name        = "feedback-logger-sg"
  description = "Allow HTTP access to ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
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

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "feedback-logger-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]
}
