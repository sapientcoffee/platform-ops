output "instance_name" {
  value = google_compute_instance.developer_desktop.name
}

output "external_ip" {
  value = google_compute_instance.developer_desktop.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.developer_desktop.name} --zone ${var.zone}"
}
