/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_disk" "developer_home" {
  name  = "developer-home-disk"
  type  = "pd-ssd"
  zone  = var.zone
  size  = var.disk_size_gb
  labels = {
    environment = "dev"
  }
}

resource "google_compute_instance" "developer_desktop" {
  name         = "antigravity-desktop"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 50
    }
  }

  attached_disk {
    source      = google_compute_disk.developer_home.id
    device_name = "sdb"
  }

  network_interface {
    network = "default"
    access_config {
      # Include this block to give the VM an external IP
    }
  }

  metadata_startup_script = file("${path.module}/../../scripts/startup.sh")

  service_account {
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = var.preemptible
    automatic_restart = !var.preemptible
  }
}
