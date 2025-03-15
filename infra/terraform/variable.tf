variable "my_ip" {
  description = "Your public IP for SSH and app access"
  type        = string
  default     = "1.1.1.1"  # Allow all (temp for testing)
}
variable "redis_host" { default = "" }
variable "redis_password" { default = "" }
