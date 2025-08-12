provider "google" {
  project = "ritu-pro"
  region  = "northamerica-south1"  # Replace with your desired region
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
}

output "instance_private_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

