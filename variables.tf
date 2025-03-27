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