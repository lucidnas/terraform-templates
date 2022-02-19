# ECS Cluster for an Alloy App


# Trust policy to allow ECS task to assume execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-app-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Trust policy to allow ECS task definition (container) to assume role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-app-ecsTaskRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attaching default execution policy to allow task to perform ECS standard operations
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attaching default S3 Managed IAM policy to allow task to read bucket
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


resource "aws_ecs_cluster" "this" {
  name = "${var.name}-app-cluster-${var.environment}"
  tags = {
    Name        = "${var.name}-app-cluster"
    Environment = var.environment
  }
}

# Creates a log group for the cluster
resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.name}-app-log-group"
  retention_in_days = 1
} 

resource "aws_ecs_task_definition" "this" {
  requires_compatibilities = ["FARGATE"] # Selected fargate for a serverless experience
  network_mode             = "awsvpc" # Selected so that each container has it's own network interface
  cpu                      = 1024 
  memory                   = 2048
  container_definitions    = <<EOF
  [
    {
      "name": "${var.name}-app-container",
      "image": "public.ecr.aws/ubuntu/grafana",
      "cpu": 1024,
      "memory": 2048,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.region}",
          "awslogs-group": "${var.name}-app-log-group",
          "awslogs-stream-prefix": "${var.name}"
        }
      }
    }
  ]
  EOF
  family                   = "${var.name}-app-family" # Task definition versions
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.name}-app-sg"
  description = "Allow VPC Traffic"
  vpc_id      =  module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["grafana-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-app-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = 1
  
  network_configuration { # Required since VPC mode is awsvpc in task definition
    subnets = module.vpc.private_subnets
    security_groups = [module.security_group.security_group_id]
  }
  launch_type = "FARGATE"
}
