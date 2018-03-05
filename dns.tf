# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

resource "google_dns_record_set" "tiddlywiki_a_host" {
  name = "${var.domain}."
  type = "A"
  ttl  = 60
  managed_zone = "${replace("${var.domain}",".","-")}"
  rrdatas = ["${google_compute_instance.tiddlywiki.network_interface.0.access_config.0.assigned_nat_ip}"]
}