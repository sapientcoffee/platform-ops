resource "google_compute_network" "default" {
  provider                = google-beta
  project                 = module.workstation_project.project_id
  name                    = "workstation-cluster"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  provider      = google-beta
  project                 = module.workstation_project.project_id
  name          = "workstation-cluster"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.name
}

resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  project                 = module.workstation_project.project_id
  workstation_cluster_id = "workstation-cluster"
  network                = google_compute_network.default.id
  subnetwork             = google_compute_subnetwork.default.id
  location               = "us-central1"

  labels = {
    "label" = "key"
  }

  annotations = {
    label-one = "value-one"
  }

  private_cluster_config {
    enable_private_endpoint = false
  }
}

resource "google_workstations_workstation_config" "default" {
  provider               = google-beta
  project                = module.workstation_project.project_id
  workstation_config_id  = "workstation-config"
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = "us-central1"

  host {
    gce_instance {
      machine_type                = "n2d-standard-4"
      boot_disk_size_gb           = 35
      disable_public_ip_addresses = false
      shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm        = true
      }
      confidential_instance_config {
        enable_confidential_compute = true
      }
    }
  }

  persistent_directories {
    mount_path = "/home"
    gce_pd {
      size_gb        = 200
      reclaim_policy = "DELETE"
    }
  }
}

resource "google_workstations_workstation" "default" {
  provider               = google-beta
  project                = module.workstation_project.project_id
  workstation_id         = "work-station"
  workstation_config_id  = google_workstations_workstation_config.default.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = "us-central1"

  labels = {
    "label" = "key"
  }

  annotations = {
    label-one = "value-one"
  }
}
