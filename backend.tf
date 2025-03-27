# DynamoDB Table for storing contact form submissions
resource "aws_dynamodb_table" "contact_form_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "email"
    projection_type    = "ALL"
    write_capacity     = 0
    read_capacity      = 0
  }

  tags = {
    Name        = "TravelContactFormTable"
    Environment = var.environment
  }
}

# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "travel_contact_form_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to access DynamoDB and SES
resource "aws_iam_policy" "lambda_policy" {
  name        = "travel_contact_form_lambda_policy"
  description = "Policy for Lambda to access DynamoDB and SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = [
          aws_dynamodb_table.contact_form_table.arn,
          "${aws_dynamodb_table.contact_form_table.arn}/index/*"
        ]
      },
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda function for processing contact form submissions
resource "aws_lambda_function" "contact_form_lambda" {
  filename         = "${path.module}/lambda/contact_form_lambda.zip"
  function_name    = "travel_contact_form_processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10
  memory_size      = 128
  source_code_hash = filebase64sha256("${path.module}/lambda/contact_form_lambda.zip")

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.contact_form_table.name
      FROM_EMAIL_ADDRESS  = var.from_email_address
      TO_EMAIL_ADDRESS    = var.to_email_address
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "contact_form_api" {
  name        = "travel-contact-form-api"
  description = "API for travel contact form"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "contact_form_resource" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  parent_id   = aws_api_gateway_rest_api.contact_form_api.root_resource_id
  path_part   = "submit"
}

# API Gateway Method
resource "aws_api_gateway_method" "contact_form_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "contact_form_integration" {
  rest_api_id             = aws_api_gateway_rest_api.contact_form_api.id
  resource_id             = aws_api_gateway_resource.contact_form_resource.id
  http_method             = aws_api_gateway_method.contact_form_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form_lambda.invoke_arn
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_form_api.execution_arn}/*/${aws_api_gateway_method.contact_form_method.http_method}${aws_api_gateway_resource.contact_form_resource.path}"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "contact_form_deployment" {
  depends_on = [
    aws_api_gateway_integration.contact_form_integration,
    aws_api_gateway_integration.options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  
  # Use SHA1 of the API resource configurations as a trigger for redeployment
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact_form_resource.id,
      aws_api_gateway_method.contact_form_method.id,
      aws_api_gateway_integration.contact_form_integration.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage (separate from deployment as recommended)
resource "aws_api_gateway_stage" "contact_form_stage" {
  deployment_id = aws_api_gateway_deployment.contact_form_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  stage_name    = var.api_stage_name
}

# API Gateway CORS Configuration
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.contact_form_api.id
  resource_id             = aws_api_gateway_resource.contact_form_resource.id
  http_method             = aws_api_gateway_method.options_method.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = aws_api_gateway_method.options_method.http_method
  status_code   = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = aws_api_gateway_method.options_method.http_method
  status_code   = aws_api_gateway_method_response.options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

# SES Email Identity verification
resource "aws_ses_email_identity" "sender_email" {
  email = var.from_email_address
}

# Output the API Gateway Invoke URL
output "api_invoke_url" {
  value = "${aws_api_gateway_stage.contact_form_stage.invoke_url}${aws_api_gateway_resource.contact_form_resource.path}"
  description = "URL to invoke the API Gateway"
}