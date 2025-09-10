provider "google" {
  project = "ritu-pro"
  region  = "northamerica-south1"
}

resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "vm_instance" {
  name         = "vm1"
  machine_type = "e2-micro"
  zone         = "northamerica-south1-a"

  # VULNERABILITY: No encryption on boot disk
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      # MISSING: disk_encryption_key = ...
    }
  }

  # VULNERABILITY: Service account with too many permissions
  service_account {
    email  = "default"  # Using default service account
    scopes = ["cloud-platform"]  # Overly permissive scope
  }

  # VULNERABILITY: No shielded VM enabled
  shielded_instance_config {
    enable_secure_boot          = false  # Should be true
    enable_vtpm                 = false  # Should be true  
    enable_integrity_monitoring = false  # Should be true
  }

  network_interface {
    network = "default"

    access_config {
      # VULNERABILITY: Public IP with no restrictions
      # Ephemeral external IP - will be flagged as public exposure
    }
  }

  # VULNERABILITY: Weak metadata SSH key configuration
  metadata = {
    ssh-keys = "reethu2302:${tls_private_key.my_ssh_key.public_key_openssh}"
    # VULNERABILITY: Enable legacy metadata endpoints
    enable-oslogin = "FALSE"  # Should be TRUE for security
  }

  # VULNERABILITY: No deletion protection
  deletion_protection = false  # Should be true for production

  # VULNERABILITY: No labels for cost tracking/security
  # labels = {}  # Missing labels
}

# VULNERABILITY: No firewall rules to restrict access
resource "google_compute_firewall" "allow_all" {
  name    = "allow-all-traffic"
  network = "default"

  allow {
    protocol = "all"  # Too permissive - allows all protocols
    ports    = []     # No port restrictions
  }

  # Allow from anywhere
  source_ranges = ["0.0.0.0/0"]  # Public internet access

  # No target tags or service accounts specified
}

# VULNERABILITY: Output sensitive data without proper protection
output "private_key" {
  value     = tls_private_key.my_ssh_key.private_key_pem
  sensitive = false  # Should be true - exposing private key in plain text
}

output "instance_public_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
  # VULNERABILITY: Exposing public IP without need
}

# VULNERABILITY: No logging/monitoring enabled
# Missing: Cloud Logging, Monitoring, etc.

# VULNERABILITY: No backup/DR configuration
# Missing: Snapshot policies, backup configurations
