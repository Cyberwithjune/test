terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.26.0"
    }
  }
}

provider "google" {
  # Configuration options
project = "red-studio-419223"
region = "asia-northeast2"
zone = "asia-northeast2-a"
credentials = "red-studio-419223-9822c4dc56cf.json"
}

# VPC Network
resource "google_compute_network" "good_vpc_network" {
  name = "good-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "good_vpc_subnet" {
  name          = "good-subnet"
  ip_cidr_range = "10.172.12.0/24"
  region        = "asia-northeast2"
  network       = google_compute_network.good_vpc_network.id
}

# External IP
resource "google_compute_address" "good_vpc_external_ip" {
  name         = "good-external-ip"
  address_type = "EXTERNAL"
  region       = "asia-northeast2"
  
}

# VM
resource "google_compute_instance" "good_vpc_vm" {
  name         = "good-vm"
  machine_type = "e2-micro"
  zone         = "asia-northeast2-a"
  metadata = {
    startup-script = "apt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>I WILL SURVIVE ARMAGEDDON</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }

    
  }

   network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/red-studio-419223/regions/asia-northeast2/subnetworks/default"
  }
 tags = ["http-server"]

  }
# Output
output "vpc_info" {
  value = google_compute_network.good_vpc_network.name
  
}

output "subnet_info" {
  value = google_compute_subnetwork.good_vpc_subnet.name
  
}
output "external_ip_info" {
  value = google_compute_address.good_vpc_external_ip.address
  
}
output "internal_ip_info" {
  value = google_compute_instance.good_vpc_vm.network_interface.0.network_ip
  
}
output "vm_info" {
  value = google_compute_instance.good_vpc_vm.name
  
}

