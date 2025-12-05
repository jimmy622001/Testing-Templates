# Testing modules for dev environment

/*
# Disaster Recovery (Reliability) Testing Module
module "dr_testing" {
  source = "../../modules/testing/dr_testing"
  
  environment = var.environment
  primary_region = var.primary_region
  dr_region = var.dr_region
  enable_network_disruption_test = var.enable_network_disruption_test
  test_timeout_minutes = var.test_timeout_minutes
  target_rpo_seconds = var.target_rpo_seconds
  target_rto_minutes = var.target_rto_minutes
}
*/

/*
# Security Testing Module
module "security_testing" {
  source = "../../modules/testing/security_testing"
  
  environment = var.environment
  enable_continuous_scanning = true
  notification_email = "security@example.com"
}
*/

/*
# Performance Efficiency Testing Module
module "performance_testing" {
  source = "../../modules/testing/performance_efficiency"
  
  environment = var.environment
  enable_load_testing = true
  target_response_time_ms = 200
}
*/

/*
# Cost Optimization Testing Module
module "cost_optimization" {
  source = "../../modules/testing/cost_optimization"
  
  environment = var.environment
  budget_threshold = 100
}
*/