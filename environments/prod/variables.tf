variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "DR AWS region"
  type        = string
  default     = "us-west-2"
}

variable "enable_network_disruption_test" {
  description = "Enable network disruption testing"
  type        = bool
  default     = false  # Be careful with disruption tests in production
}

variable "test_timeout_minutes" {
  description = "Maximum test duration in minutes"
  type        = number
  default     = 15
}

variable "target_rpo_seconds" {
  description = "Target Recovery Point Objective in seconds"
  type        = number
  default     = 60  # Stricter RPO for production
}

variable "target_rto_minutes" {
  description = "Target Recovery Time Objective in minutes"
  type        = number
  default     = 5   # Stricter RTO for production
}