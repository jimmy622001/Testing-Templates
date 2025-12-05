# Terraform Environments

This directory contains environment-specific Terraform configurations.

## Directory Structure

- **dev/**: Development environment configurations
- **prod/**: Production environment configurations

## Environment Setup

Each environment should contain the following files:

- **main.tf**: Main Terraform configuration for this environment
- **variables.tf**: Variable definitions specific to this environment
- **outputs.tf**: Output definitions for this environment
- **testing.tf**: Testing configuration for this environment
- **providers.tf**: Provider configuration for this environment
- **terraform.tfvars**: Variable values for this environment (gitignored)

## Usage

To initialize and apply an environment:

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Testing

Each environment supports testing through the GitHub Actions workflows. The testing configurations are defined in `testing.tf` in each environment directory.

For more information on the testing frameworks and methodologies, see the `modules/testing` directory and the `.github/workflows` directory.