# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

variable "project" {}
variable "region" {}

provider "google" {  
  # credentials = "${file("credentials.json")}"
  project = "${var.project}"
  region = "${var.region}"
}
