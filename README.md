# Travel Contact Form - Serverless AWS Application

A complete serverless travel contact form built with AWS services and Terraform. Features a modern responsive frontend with a robust backend that automatically processes submissions, stores data, and sends email notifications.

## ✨ Features

- **Responsive Design**: Mobile-friendly contact form with real-time validation
- **Serverless Backend**: Handles thousands of submissions without server management
- **Email Automation**: Sends confirmation emails to customers and notifications to business
- **Data Storage**: Secure DynamoDB storage with proper indexing
- **Infrastructure as Code**: Complete Terraform deployment for easy management
- **Security First**: No hardcoded values, proper IAM roles, and input validation

## 🏗️ Architecture

### Frontend

- **S3 Static Website**: Hosts HTML, CSS, and JavaScript files
- **CloudFront (Optional)**: Global CDN for performance and HTTPS

### Backend

- **API Gateway**: REST API endpoint for form submissions
- **Lambda Function**: Processes submissions and handles email logic
- **DynamoDB**: Stores contact form data with email indexing
- **SES**: Automated email delivery system

## 📋 Prerequisites

Before you begin, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0+
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- AWS account with SES email verification completed
- Basic knowledge of AWS services and Terraform

## 📁 Project Structure

```
travel-contact-form/
├── main.tf                     # S3 website infrastructure
├── backend.tf                  # API Gateway, Lambda, DynamoDB, SES
├── variables.tf                # Variable definitions
├── terraform.tfvars.example    # Configuration template
├── frontend/
│   ├── index.html              # Contact form HTML
│   ├── styles.css              # Responsive CSS styling
│   └── script.js               # Form validation and submission
├── lambda/
│   ├── index.js                # Lambda function code
│   ├── package.json            # Node.js dependencies
│   └── contact_form_lambda.zip # Deployment package
├── scripts/
│   ├── deploy.sh               # Automated deployment
│   └── configure-frontend.sh   # Dynamic API configuration
└── package_lambda.sh           # Lambda packaging script
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repository-url>
cd travel-contact-form
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Your Environment

Edit `terraform.tfvars` with your specific values:

```hcl
aws_region = "us-east-1"
bucket_name = "your-unique-bucket-name-2024"
create_cloudfront = false

# Backend configuration
dynamodb_table_name = "travel-contact-submissions"
environment = "production"
from_email_address = "noreply@yourdomain.com"    # Must be verified in SES
to_email_address = "contact@yourdomain.com"      # Must be verified in SES
api_stage_name = "v1"
```

### 3. Verify SES Email Addresses

**Critical Step**: Before deployment, verify your email addresses in AWS SES:

1. Open AWS SES Console in your chosen region
2. Go to "Verified identities"
3. Add and verify both `from_email_address` and `to_email_address`
4. Wait for verification emails and confirm both addresses

### 4. Deploy with One Command

```bash
./scripts/deploy.sh
```

The deployment script will:

- Validate your configuration
- Deploy all AWS infrastructure
- Configure the frontend with your API Gateway URL
- Upload all files to S3

### 5. Manual Deployment (Alternative)

```bash
# Initialize and deploy infrastructure
terraform init
terraform plan
terraform apply

# Configure frontend with API endpoint
./scripts/configure-frontend.sh
terraform apply
```

## 🌐 Accessing Your Application

After successful deployment, Terraform will output:

```bash
website_endpoint = "your-bucket-name.s3-website-us-east-1.amazonaws.com"
api_invoke_url = "https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/v1/submit"
```

Visit the `website_endpoint` URL to see your live contact form!

## 🧪 Testing

### Test the Form Manually

1. Open your website URL
2. Fill out the contact form
3. Submit and verify you receive confirmation emails

### Test the API Directly

```bash
curl -X POST "$(terraform output -raw api_invoke_url)" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "your-verified-email@domain.com",
    "destination": "Paris",
    "travelers": "2",
    "message": "Test submission"
  }'
```

## 🛠️ Customization

### Form Fields

Modify `frontend/index.html` to add/remove form fields. Update the corresponding JavaScript validation in `frontend/script.js`.

### Styling

Edit `frontend/styles.css` to customize the visual design and responsive behavior.

### Email Templates

Update the email templates in `lambda/index.js` to match your brand and communication style.

### Business Logic

Extend the Lambda function in `lambda/index.js` to add custom processing, integrations, or data transformations.

## 💰 Cost Optimization

This serverless architecture is extremely cost-effective:

- **S3**: ~$0.023 per GB/month for storage
- **Lambda**: 1M free requests/month, then $0.20 per 1M requests
- **DynamoDB**: 25GB free tier, then pay-per-request pricing
- **API Gateway**: 1M free requests/month, then $3.50 per million
- **SES**: 62,000 free emails/month, then $0.10 per 1,000 emails

Expected monthly cost for most small businesses: **Under $5**

## 🔒 Security Features

- **No Hardcoded Secrets**: All sensitive values use Terraform variables
- **Input Validation**: Both frontend and backend validate all inputs
- **CORS Protection**: Properly configured cross-origin resource sharing
- **IAM Least Privilege**: Lambda function has minimal required permissions
- **Encryption**: DynamoDB data encrypted at rest
- **Email Verification**: SES requires verified sender addresses

## 🚨 Troubleshooting

### Common Issues

**"Email address not verified" error:**

- Verify both sender and recipient emails in AWS SES console
- Check SES sandbox mode limitations

**API Gateway CORS errors:**

- Ensure API Gateway has been deployed after infrastructure changes
- Check browser network tab for specific CORS headers

**Form not submitting:**

- Verify the `config.js` file was generated and uploaded
- Check browser console for JavaScript errors
- Confirm API Gateway URL is accessible

**Terraform deployment errors:**

- Ensure AWS credentials are properly configured
- Verify S3 bucket name is globally unique
- Check IAM permissions for Terraform operations

## 🧹 Cleanup

To remove all AWS resources and avoid charges:

```bash
terraform destroy
```

This will permanently delete:

- S3 bucket and all files
- API Gateway and Lambda function
- DynamoDB table and all data
- All associated IAM roles and policies

## 📊 Monitoring

### CloudWatch Logs

Monitor your application through these log groups:

- `/aws/lambda/travel_contact_form_processor`
- `/aws/apigateway/travel-contact-form-api`

### Key Metrics to Watch

- Lambda function duration and errors
- API Gateway request count and latency
- DynamoDB read/write capacity usage
- SES bounce and complaint rates

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

Need help? Here's how to get assistance:

1. **Check the troubleshooting section** above for common issues
2. **Review AWS documentation** for service-specific questions
3. **Open an issue** in this repository for bugs or feature requests
4. **AWS Support** for infrastructure and billing questions

---

**Built with ❤️ for the travel industry** - Making customer contact forms that actually work!
