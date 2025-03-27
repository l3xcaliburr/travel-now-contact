# Travel Contact Form - Static S3 Website

This project deploys a static travel contact form website to AWS S3 with optional CloudFront distribution using Terraform.

## Infrastructure Components

- **S3 Bucket**: Hosts the static website files (HTML, CSS, JavaScript)
- **Website Configuration**: Configures the S3 bucket for static website hosting
- **Public Access**: Sets appropriate permissions for public web access
- **CloudFront (Optional)**: CDN for improved performance and HTTPS support

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed (v1.0.0+)
- AWS CLI installed and configured with appropriate credentials
- The static website files (index.html, styles.css, script.js)

## Project Structure

```
.
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── terraform.tfvars  # Variable values
├── files/            # Directory for static website files
│   ├── index.html
│   ├── styles.css
│   └── script.js
└── README.md
```

## Deployment Instructions

1. **Prepare your environment**:

   Create a `files` directory and place your static website files in it:

   ```bash
   mkdir -p files
   cp /path/to/your/index.html files/
   cp /path/to/your/styles.css files/
   cp /path/to/your/script.js files/
   ```

2. **Update the configuration**:

   Edit `terraform.tfvars` with your desired settings:

   ```
   aws_region = "us-east-1"  # Your preferred AWS region
   bucket_name = "your-unique-bucket-name"  # Must be globally unique
   create_cloudfront = false  # Set to true if you want CloudFront
   ```

3. **Initialize Terraform**:

   ```bash
   terraform init
   ```

4. **Review the execution plan**:

   ```bash
   terraform plan
   ```

5. **Apply the configuration**:

   ```bash
   terraform apply
   ```

6. **Access your website**:

   After successful deployment, Terraform will output the S3 website endpoint URL and CloudFront distribution domain name (if enabled).

## Cleaning Up

To destroy all resources created by this Terraform configuration:

```bash
terraform destroy
```

## Next Steps

To complete the integration with your API Gateway, Lambda, DynamoDB, and SES components:

1. Update the JavaScript code to point to your API Gateway endpoint
2. Deploy the backend infrastructure components
3. Configure CORS settings on your API Gateway to allow requests from your S3 website

## Security Considerations

- For production deployments, consider enabling CloudFront with HTTPS
- Review the S3 bucket policy to ensure it meets your security requirements
- Consider implementing additional security measures such as CORS configuration and input validation
