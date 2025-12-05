# AWS Testing Templates

This repository contains reusable testing modules, pipelines, and documentation for AWS infrastructure. These templates can be used as a foundation for implementing comprehensive testing strategies in AWS environments.

## Repository Structure

- `modules/testing/`: Core testing modules
  - `security_testing/`: Security validation and compliance testing
  - `dr_testing/`: Disaster recovery and failover testing
  - `cost_optimization/`: Cost efficiency and resource utilization testing
  - `operational_excellence/`: Operational best practices validation
  - `performance_efficiency/`: Performance benchmarking and load testing
  - `playbooks/`: Testing methodology documentation
  - `runbooks/`: Step-by-step procedures for test execution

- `pipelines/testing/`: CI/CD pipelines for automated testing
  - `security-Jenkinsfile`: Pipeline for security testing
  - `dr-Jenkinsfile`: Pipeline for DR testing
  - `compliance-Jenkinsfile`: Pipeline for compliance validation

- `terraform-compliance/`: BDD-style compliance tests for Terraform
  - `features/`: Compliance test definitions

## Getting Started

1. Copy the relevant modules to your AWS infrastructure project
2. Update module configurations to match your environment
3. Integrate testing pipelines with your CI/CD system
4. Execute tests according to the guidance in the playbooks and runbooks
5. Install the required security scanning tools:

```bash
pip install detect-secrets checkov terraform-compliance
```

## GitHub Actions Workflows

This repository includes GitHub Actions workflows for automated testing:

- **Security Testing**: `.github/workflows/security-tests.yml`
- **DR Testing**: `.github/workflows/dr-tests.yml`
- **Compliance Testing**: `.github/workflows/compliance-tests.yml`
- **Performance/Cost Testing**: `.github/workflows/performance-cost-tests.yml`
- **Sustainability Testing**: `.github/workflows/sustainability-tests.yml`

### Workflow Structure

The workflows follow the project structure with environments (`dev`, `prod`) and create any necessary directories and files if they don't exist. Workflows can be triggered manually or on specific events like pushes to certain files.

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`: AWS access key with appropriate permissions
- `AWS_SECRET_ACCESS_KEY`: Corresponding AWS secret access key

For details on using the workflows, see [.github/workflows/README.md](.github/workflows/README.md).

## Managing Variables and Secrets

We use `.tfvars` files to manage environment-specific and sensitive values. See [TFVARS_USAGE.md](TFVARS_USAGE.md) for detailed instructions.

1. Copy the example variable files to create your actual variable files:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   cp dev.tfvars.example dev.tfvars
   cp prod.tfvars.example prod.tfvars
   ```

2. Edit the files with your actual values.

3. Never commit `.tfvars` files containing real values to version control - they are excluded in `.gitignore`.

### Security Scanning

Run security scans on your Terraform code before deployment:

```bash
# Scan for secrets
detect-secrets scan > .secrets.baseline

# Run Terraform static analysis
checkov -d . --framework terraform

# Compliance testing (requires a plan file)
terraform plan -out=tfplan
terraform-compliance -p tfplan -f features/
```

## Module Details

### Security Testing

Validates security configurations, compliance with best practices, and identifies vulnerabilities in AWS resources.

```bash
cd modules/testing/security_testing
terraform init
terraform apply -var="environment=dev"
```

### Disaster Recovery Testing

Validates failover mechanisms, recovery procedures, and measures RTO/RPO metrics.

```bash
cd modules/testing/dr_testing
terraform init
terraform apply -var="environment=dev" -var="primary_region=us-east-1" -var="dr_region=us-west-2"
```

### Cost Optimization Testing

Identifies cost-saving opportunities and validates resource utilization efficiency.

```bash
cd modules/testing/cost_optimization
terraform init
terraform apply -var="environment=dev"
```

### Operational Excellence Testing

Validates operational best practices, monitoring configurations, and alert mechanisms.

```bash
cd modules/testing/operational_excellence
terraform init
terraform apply -var="environment=dev"
```

### Performance Efficiency Testing

Benchmarks performance under various load conditions and validates scalability.

```bash
cd modules/testing/performance_efficiency
terraform init
terraform apply -var="environment=dev"
```

## Documentation

- `modules/testing/README.md`: Overview of testing modules
- `modules/testing/USAGE.md`: Detailed usage instructions
- `modules/testing/testing_overview.md`: Testing strategy and approach
- `modules/testing/playbooks/`: Testing playbooks for different scenarios
- `modules/testing/runbooks/`: Step-by-step procedures for test execution

## Pipeline Integration

These testing modules can be integrated with your CI/CD pipelines. Example Jenkins pipelines are provided in the `pipelines/testing/` directory.

## Customization

Each testing module contains variable definitions that can be customized to match your specific environment requirements. Refer to the `variables.tf` file in each module directory for available configuration options.