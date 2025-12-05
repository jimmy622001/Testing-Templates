variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
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
  default     = false
}

variable "test_timeout_minutes" {
  description = "Maximum test duration in minutes"
  type        = number
  default     = 30
}

variable "target_rpo_seconds" {
  description = "Target Recovery Point Objective in seconds"
  type        = number
  default     = 300
}

variable "target_rto_minutes" {
  description = "Target Recovery Time Objective in minutes"
  type        = number
  default     = 15
}