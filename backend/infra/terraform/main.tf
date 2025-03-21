terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.25.0"  # Latest as of Mar 2025
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

