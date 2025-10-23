variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region for ECS deployment"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repo" {
  description = "Name of the ECR repository"
  type        = string
  default     = "terra-ecr"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
