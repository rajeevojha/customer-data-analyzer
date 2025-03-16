variable "my_ip" {
  description = "Your public IP for SSH and app access"
  type        = string
  default     = "1.1.1.1"  # Allow all (temp for testing)
}
locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("../../.env")) : tuple[0] => tuple[1] }
}
