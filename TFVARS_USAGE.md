# Managing Terraform Variables and Sensitive Values

This document explains how to properly manage Terraform variables, especially sensitive ones, in this project.

## Variable Files Structure

We use `.tfvars` files to manage environment-specific and sensitive values:

1. **terraform.tfvars** - Primary variable values (not committed to Git)
2. **dev.tfvars** - Development environment specific values
3. **prod.tfvars** - Production environment specific values

## Setup Instructions

1. Copy the example files to create your actual variable files:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   cp dev.tfvars.example dev.tfvars
   cp prod.tfvars.example prod.tfvars
   ```

2. Edit the files and add your actual values.

3. For sensitive values (like API keys, passwords, etc.), consider using:
   - AWS SSM Parameter Store
   - AWS Secrets Manager
   - Terraform Cloud variable sets
   - Environment variables (for CI/CD pipelines)

## Using Variable Files

Apply Terraform configurations with the appropriate variable file:

```bash
# For development environment
terraform apply -var-file=terraform.tfvars -var-file=dev.tfvars

# For production environment
terraform apply -var-file=terraform.tfvars -var-file=prod.tfvars
```

## Best Practices for Sensitive Values

1. **Never commit `.tfvars` files containing sensitive data**. Our `.gitignore` is configured to exclude these files.

2. **Use AWS SSM or Secrets Manager** for truly sensitive values:
   ```hcl
   data "aws_ssm_parameter" "db_password" {
     name = "/app/database/password"
     with_decryption = true
   }
   ```

3. **Use environment variables** for CI/CD pipelines:
   ```bash
   export TF_VAR_notification_email="your-email@example.com"
   terraform apply
   ```

4. **Document required variables** in README files and through example `.tfvars` files.

5. **Regularly scan for leaked secrets** using tools like `detect-secrets`.

## Scanning for Secrets

Run the following command to scan for accidentally committed secrets:

```bash
detect-secrets scan > .secrets.baseline
detect-secrets scan --baseline .secrets.baseline
```

## Security Testing

We use the following tools for security testing:

- **checkov**: For static analysis of Terraform code
  ```bash
  checkov -d . --framework terraform
  ```

- **terraform-compliance**: For compliance testing
  ```bash
  terraform-compliance -p terraform_plan.out -f features/
  ```