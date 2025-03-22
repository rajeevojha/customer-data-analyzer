variable "my_ip" {
  description = "Your public IP for SSH and app access"
  type        = string
  default     = "0.0.0.0"  # Allow all (temp for testing)
}

variable "api_url" {
  description = "api url created during bla bla bl"
  type        = string
  default     = "not set"  
}
locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("../../../.env")) : tuple[0] => tuple[1] }
}
