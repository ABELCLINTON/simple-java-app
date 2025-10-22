#####################
# Variables
#####################
variable "aws_account_id" {}
variable "aws_region" {}
variable "ecr_repo" {}
variable "image_tag" {
  default = "${BUILD_NUMBER}"
}

#####################
# ECS Task Definition
#####################
resource "aws_ecs_task_definition" "task" {
  family                   = "fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}
