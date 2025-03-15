resource "google_service_account" "vm_access" {
  account_id   = "vm-access"
  display_name = "VM Storage Access"
}

resource "google_project_iam_member" "storage_viewer" {
  project = "carbide-ether-452420-i7"
  role    = "roles/storage.objectViewer"  # For gsutil cp
  member  = "serviceAccount:${google_service_account.vm_access.email}"
}
resource "google_compute_network" "vpc" {
  name                    = "training-vpc"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet" {
  name          = "training-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = "us-west1"
}

# GCP Firewall
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges =  ["${var.my_ip}/32"] # Or your IP for security
}

#resource "google_secret_manager_secret" "redis_host" {
  
#  secret_id = "redis-host"
#  replication {
#    automatic = true
#  }
#  depends_on = [google_project_service.secretmanager]
#}
#resource "google_secret_manager_secret_version" "redis_host_version" {
#   
#  secret = google_secret_manager_secret.redis_host.id
#  secret_data = var.redis_host
#}
#resource "google_secret_manager_secret" "redis_password" {
#  secret_id = "redis-password"
#  replication {
#    automatic = true
#  }
#}
#resource "google_secret_manager_secret_version" "redis_password_version" {
#  secret = google_secret_manager_secret.redis_password.id
#  secret_data = var.redis_password
#}
# GCP VM

resource "google_compute_instance" "app" {
  name         = "training-gcp"
  machine_type = "e2-medium"
  zone         = "us-west1-b"
  boot_disk {
    initialize_params { image = "ubuntu-2204-lts" }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  service_account {
    email  = google_service_account.vm_access.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  } 
  metadata_startup_script = <<-EOF
                         #!/bin/bash
                         rm -f /home/ubuntu/app
                         mkdir -p /home/ubuntu/app
      git clone https://github.com/rajeevojha/customer-data-analyzer.git /home/ubuntu/app 2>/tmp/git-error
                         cd /home/ubuntu/app/scripts || echo "cd failed" >>/tmp/git-error
                         cp /home/ubuntu/app/node/gcp/app.js /home/ubuntu/app.js
                         cd /home/ubuntu/app/scripts
                         chmod +x install.sh gcp-section.sh run.ssh
                         bash   ./install.sh 2>/tmp/install-error
                         bash   ./gcp-section.sh 2>/tmp/gcp-error
                            chown ubuntu:ubuntu -R /home/ubuntu/app
                            chmod -R 777 /home/ubuntu/app
echo 'REDIS_HOST=${local.envs["REDIS_HOST"]}' >> /home/ubuntu/app/.env
echo 'REDIS_PASSWORD=${local.envs["REDIS_PASSWORD"]}' >> /home/ubuntu/app/.env
                         chmod 600 /home/ubuntu/app/.env
                         bash ./run.sh 2>/tmp/run-error
                         EOF
  metadata = {
    "ssh-keys" = "ubuntu:${file("~/.ssh/cloudg9.pub")}"
  }
}


output "gcp_public_ip" {
  value = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}
