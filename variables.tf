variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name for the S3 bucket (must be globally unique)"
  type        = string
}

variable "create_cloudfront" {
  description = "Whether to create a CloudFront distribution in front of the S3 bucket"
  type        = bool
  default     = false
}

# Backend-related variables
variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table to store contact form submissions"
  type        = string
  default     = "travel_contact_form_submissions"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "from_email_address" {
  description = "Email address used to send confirmation emails"
  type        = string
}

variable "to_email_address" {
  description = "Email address to receive contact form submissions"
  type        = string
}

variable "api_stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
  default     = "v1"
}