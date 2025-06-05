#!/bin/bash

# Script to configure frontend with API Gateway URL
# Usage: ./scripts/configure-frontend.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Configuring frontend with API Gateway URL...${NC}"

# Get the API Gateway URL from Terraform output
API_URL=$(terraform output -raw api_invoke_url 2>/dev/null)

if [ -z "$API_URL" ]; then
    echo -e "${RED}Error: Could not get API Gateway URL from Terraform output.${NC}"
    echo -e "${YELLOW}Make sure you have deployed the infrastructure first with 'terraform apply'${NC}"
    exit 1
fi

echo -e "${GREEN}Found API Gateway URL: $API_URL${NC}"

# Create a temporary script file that will be injected into the HTML
cat > frontend/config.js << EOF
// Auto-generated configuration file
// This file is created by the deployment script and should not be edited manually
window.API_ENDPOINT = "$API_URL";
EOF

echo -e "${GREEN}✅ Frontend configuration complete!${NC}"
echo -e "${YELLOW}config.js created with API endpoint: $API_URL${NC}"
echo -e "${YELLOW}Make sure to include this script in your HTML file before script.js${NC}" 