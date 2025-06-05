#!/bin/bash

# Comprehensive deployment script for Travel Contact Form
# This script handles the entire deployment process with security checks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars not found. Please copy terraform.tfvars.example and configure it."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Validate configuration
validate_config() {
    print_status "Validating configuration..."
    
    # Check if sensitive values are still placeholders
    if grep -q "your-verified-email@yourdomain.com" terraform.tfvars; then
        print_error "Please update email addresses in terraform.tfvars"
        exit 1
    fi
    
    if grep -q "your-unique-bucket-name" terraform.tfvars; then
        print_error "Please update bucket name in terraform.tfvars"
        exit 1
    fi
    
    print_success "Configuration validated!"
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure..."
    
    # Initialize terraform
    terraform init
    
    # Plan deployment
    terraform plan
    
    # Ask for confirmation
    read -p "Do you want to apply these changes? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled."
        exit 0
    fi
    
    # Apply changes
    terraform apply -auto-approve
    
    print_success "Infrastructure deployed!"
}

# Configure frontend
configure_frontend() {
    print_status "Configuring frontend..."
    
    # Run the frontend configuration script
    ./scripts/configure-frontend.sh
    
    # Re-apply to upload the config file
    terraform apply -auto-approve -target=aws_s3_object.config_file
    
    print_success "Frontend configured!"
}

# Main deployment process
main() {
    echo -e "${BLUE}🚀 Starting Travel Contact Form Deployment${NC}"
    echo "============================================="
    
    check_prerequisites
    validate_config
    deploy_infrastructure
    configure_frontend
    
    echo "============================================="
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo
    echo "Your travel contact form is now live at:"
    terraform output website_endpoint
    echo
    echo "API Gateway URL:"
    terraform output api_invoke_url
}

# Run main function
main "$@" 