# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

variable "trusted_cidr" {
  default = ["0.0.0.0/0"]
  type    = list(string)
}

resource "google_compute_firewall" "allow-ssh-trusted" {
  name    = "allow-ssh-trusted-${local.name}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.trusted_cidr
  target_tags   = ["trusted-ssh"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http-${local.name}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "444"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

