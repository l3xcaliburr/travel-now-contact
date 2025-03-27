#!/bin/bash

# Script to create the Lambda deployment package

# Ensure we're in the project root directory
cd "$(dirname "$0")"

# Create lambda directory if it doesn't exist
mkdir -p lambda

# Navigate to the lambda directory
cd lambda

# Install dependencies
npm install

# Create a zip file with all necessary files
zip -r contact_form_lambda.zip index.js node_modules package.json

echo "Lambda package created at lambda/contact_form_lambda.zip"