provider "google" {
  project = "ritu-pro"
  region  = "northamerica-south1"  # Replace with your desired region
}
resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "vm_instance" {
  name         =  "vm1"
  machine_type = "e2-micro"  # Replace with your desired machine type
  zone         = "northamerica-south1-a"  # Replace with your desired zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # Replace with your desired image
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral external IP
    }
  }
metadata = {
    ssh-keys = "reethu2302:${tls_private_key.my_ssh_key.public_key_openssh}"
  }
}
output "private_key" {
  value     = tls_private_key.my_ssh_key.private_key_pem
  sensitive = true
}
output "instance_private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

