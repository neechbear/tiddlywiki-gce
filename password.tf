# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

resource "random_string" "password" {
  length = 12
  special = true
}
