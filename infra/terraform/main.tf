terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.25.0"  # Latest as of Mar 2025
    }
  }
}
provider "google" {
  project = "carbide-ether-452420-i7"  # From GCP Console > Project Info
  region  = "us-west1"
}
provider "aws" {
  region = "us-west-1"
}
output "rollcall" {
  value = local.envs["REDIS_HOST"]
}
