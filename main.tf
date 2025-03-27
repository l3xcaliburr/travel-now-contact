provider "aws" {
  region = var.aws_region
}

# S3 bucket for static website hosting
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "website_bucket_ownership" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Bucket public access block configuration 
# This must be applied BEFORE the bucket policy to ensure public policies are allowed
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket ACL
resource "aws_s3_bucket_acl" "website_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket_ownership,
    aws_s3_bucket_public_access_block.website_bucket_public_access,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  depends_on = [
    aws_s3_bucket_public_access_block.website_bucket_public_access,
  ]
  
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })
}

# Upload static website frontend
resource "aws_s3_object" "html_file" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/frontend/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/frontend/index.html")
}

resource "aws_s3_object" "css_file" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "styles.css"
  source       = "${path.module}/frontend/styles.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/frontend/styles.css")
}

resource "aws_s3_object" "js_file" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "script.js"
  source       = "${path.module}/frontend/script.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/frontend/script.js")
}

# Optional: Create a CloudFront distribution for CDN and HTTPS
resource "aws_cloudfront_distribution" "website_distribution" {
  count = var.create_cloudfront ? 1 : 0
  
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Outputs
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
  description = "S3 static website endpoint"
}

output "cloudfront_domain_name" {
  value = var.create_cloudfront ? aws_cloudfront_distribution.website_distribution[0].domain_name : null
  description = "CloudFront distribution domain name (if enabled)"
}