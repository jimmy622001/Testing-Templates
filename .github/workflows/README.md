# GitHub Workflows for Testing

This directory contains GitHub Actions workflows for automated testing of our AWS EKS infrastructure against all six pillars of the AWS Well-Architected Framework.

## Available Workflows

1. **Compliance Tests** (`compliance-tests.yml`)
   - Runs terraform-compliance and checkov to validate infrastructure against best practices
   - Can be run against any environment (dev/prod/dr)
   - Generates compliance reports as artifacts
   - **Covers**: Operational Excellence pillar

2. **Disaster Recovery Tests** (`dr-tests.yml`)
   - Tests disaster recovery capabilities and measures RPO/RTO metrics
   - Supports network disruption testing
   - Configurable timeout and target metrics
   - **Covers**: Reliability pillar

3. **Security Tests** (`security-tests.yml`)
   - Runs security scanning tools (detect-secrets, tfsec)
   - Identifies potential security vulnerabilities
   - Generates detailed reports
   - **Covers**: Security pillar

4. **Performance & Cost Tests** (`performance-cost-tests.yml`)
   - Tests resource sizing and performance under load
   - Identifies cost optimization opportunities
   - Analyzes autoscaling configurations
   - Finds unused resources
   - **Covers**: Performance Efficiency and Cost Optimization pillars

5. **Sustainability Tests** (`sustainability-tests.yml`)
   - Analyzes carbon footprint of infrastructure
   - Validates resource utilization efficiency
   - Checks for sustainable AWS practices
   - Recommends energy-efficient alternatives
   - **Covers**: Sustainability pillar

## AWS Well-Architected Framework Coverage

These workflows collectively test all six pillars of the AWS Well-Architected Framework:

1. **Operational Excellence**: Covered by Compliance Testing workflow
2. **Security**: Covered by Security Testing workflow
3. **Reliability**: Covered by DR Testing workflow
4. **Performance Efficiency**: Covered by Performance & Cost Testing workflow
5. **Cost Optimization**: Covered by Performance & Cost Testing workflow
6. **Sustainability**: Covered by Sustainability Testing workflow

## How to Use

### Manual Execution
All workflows can be triggered manually from the GitHub Actions tab with configurable parameters.

### Automatic Triggers
Workflows are automatically triggered on relevant path changes:
- Compliance tests: When infrastructure code changes
- DR tests: When DR-related configurations change
- Security tests: When any code changes in the repository
- Performance & Cost tests: Weekly (Monday at midnight)
- Sustainability tests: Monthly (1st of the month)

## Workflow Parameters

Each workflow has configurable parameters to customize the testing behavior:

- **Environment**: Target environment (dev/prod/dr)
- **AWS Region(s)**: Regions to test against
- **Test Options**: Various test-specific options
- **Reporting Options**: Control report generation and format

## Required Secrets

To run these workflows, you need to set up the following GitHub secrets:

- `AWS_ACCESS_KEY_ID`: AWS access key with appropriate permissions
- `AWS_SECRET_ACCESS_KEY`: Corresponding AWS secret access key
- `INFRACOST_API_KEY`: Required for cost optimization tests (get at https://www.infracost.io/)

## Known Issues and Troubleshooting

### Package Installation Issues

Some workflows may encounter issues with package installation:

- **tfsec-python**: This package doesn't exist on PyPI. The workflows have been updated to use the Go-based `tfsec` tool instead.
- **detect-secrets**: Sometimes requires specific Python versions. Consider using Python 3.9+ for best compatibility.

### Directory Structure Issues

The workflows expect an `environments` directory structure with subdirectories for each environment (e.g., `environments/dev`, `environments/prod`). If these directories don't exist:

1. The workflows will attempt to create them automatically
2. Sample `testing.tf` and `variables.tf` files will be generated

### AWS Credentials Issues

If you see errors about AWS credentials, ensure:

1. The GitHub secrets are properly configured
2. The credentials have sufficient permissions for the actions being performed
3. The credentials are valid and not expired

## Using Test Results

Test results are stored as artifacts in each workflow run and can be downloaded for further analysis.

## Additional Information

For detailed information on testing methodology and frameworks, refer to the main testing documentation in the `modules/testing` directory.