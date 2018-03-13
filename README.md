# tiddlywiki

Dockerised TiddlyWiki 5 server inside Google Compute Engine.

***This is very much a work in progress still.
I am using it as an exercise to learn Terraform.
Expect to see frequent and unstable code chanes.***

See https://nicolaw.uk/gcloud and https://nicolaw.uk/gcp for tangentally
related notes on Google Cloud Platform.

## Quickstart

Deploy directly to GCE instance using Terraform:

```bash
ssh-add ~/.ssh/google_compute_engine
make apply \
  GOOGLE_PROJECT=mywiki-123456 \
  EMAIL=jdoe@mywiki.com DOMAIN=mywiki.com \
  TW_USERNAME=jdoe TW_PASSWORD=password1234 \
  GIT_USERNAME=jdoe GIT_SSH_KEY=~/.ssh/id_rsa \
  GIT_REPOSITORY=git@github.com:jdoe/mywiki.git
```

Test locally using Docker Compose:

```bash
make test \
  EMAIL=jdoe@mywiki.com DOMAIN=mywiki.com \
  TW_USERNAME=jdoe TW_PASSWORD=password1234
```

The following TCP ports should be exposed for your web browser:

| Port    | Example URL            | Permissions | Description |
| ------- | ---------------------- | ----------- | ----------- |
| tcp/80  | http://mywiki.com      | None        | HTTP automatically redirects to HTTPS |
| tcp/443 | https://mywiki.com     | Read-only   | HTTPS TiddlyWiki (PUT and DELETE writes are silently ignored, responding with HTTP 405 response codes) |
| tcp/444 | https://mywiki.com:444 | Read-write  | HTTPS TiddlyWiki (password protected with basic digest authentication) |

## Design Overview

```
                                                                      |\_/|
                                                                     / @ @ \
                                                 End-user browsing  ( ^ º ^ )
                                                 https://mywiki.com  `>>x<<´
                                                                     /  O  \

                                                                        +
+--[Google Compute Engine]----------------------------------------------|------------------------------------+
|                                                                       |                                    |
|  +--[Container-Optimized OS VM Instance]------------------------------|---------------------------------+  |
|  |                                                                    |                                 |  |
|  |  +--[Docker]-----------+  +--[Docker]-----------+  +--[Docker]-----|-----+  +--[Docker]-----------+  |  |
|  |  |                     |  |                     |  |               |     |  |                     |  |  |
|  |  | Scheduled automation|  |  TiddlyWiki NodeJS  |  |  Apache       v     |  |  LetsEncrypt SSL    |  |  |
|  |  | tasks push backups  |  |  exposes tcp/8080   |  |  exposes            |  |  certificate        |  |  |
|  |  | to Git, & generate  |  |  to Apache.         |  |  tcp/80,443,444     |  |  generation         |  |  |
|  |  | static wiki page    |  |                     |  |  to the Internet.   |  |     automation and  |  |  |
|  |  | renderings.      <-------+                <-------+                <-------+   renewal.        |  |  |
|  |  |                 +   |  |                     |  |                     |  |                     |  |  |
|  |  +-----------------|---+  +---------------------+  +---------------------+  +---------------------+  |  |
|  |                    |                                                                                 |  |
|  +--------------------|---------------------------------------------------------------------------------+  |
|                       |                                                                                    |
+-----------------------|------------------------------------------------------------------------------------+
                        |
+--[Git Repository]-----|------+
|                       |      |
|  Upstream Git repo    v      |
|  provides versioned          |
|  backup store of TiddlyWiki  |
|  pages and static content.   |
|                              |
+------------------------------+
```

## Makefile Variables

#### DOMAIN

Defaults to `localhost.localdomain`.

This value is used by the `letsencrypt` container to automatically generate SSL
certificates.

#### EMAIL

Defaults to `webmaster@localhost.localdomain`.

This value is used by the `letsencypt` container to automatically generate SSL
certificates.

#### TW_USERNAME

Defaults to `anonymous`.

#### TW_PASSWORD

When deploying to Google Compute Platform, Terraform will provide a default
random password if one is not provided.

#### LETSENCRYPT_DATA

Defaults to `/home/tiddlywiki/letsencrypt`.

When deploying locally to a test Docker containers, you may wish to specify a
custom bind location. The `letsencrypt`, `automation` and `apache` containers
will bind a volume to this path, to read and write Let's Encrypt SSL
certificate.

### Remote Git Repository

The following variables are only required to replicate tiddlers data to a remote
upstream Git repository as a backing store.

Upon startup, any existing tiddler data will be fetched from the Git repository.

#### GIT_REPOSITORY

Remote Git repository to replicte tiddlers data to.

Examples:

* `git@github.com:jdoe/mywiki.git`
* `https://github.com/jdoe/mywiki.git`
* `git@gitlab.com:jdoe/mywiki.git`
* `https://gitlab.com/jdoe/mywiki.git`

#### GIT_USERNAME

Username to login to the remote Git repository.

#### GIT_PASSWORD

Password to login to the remote Git repository.

#### GIT_SSH_KEY

Path and filename of the SSH private key to login to the remote Git repository.

This is not necessary when `GIT_PASSWORD` is specified.

### Google Compute Platform

The following variables are only required when deploying to Google Compute
Platform.

#### GOOGLE_PROJECT

Defaults to `$GOOGLE_PROJECT` environment variable.

#### GOOGLE_REGION

Defaults to `$GOOGLE_REGION` environment variable.

#### GOOGLE_ZONE

Defaults to `$GOOGLE_ZONE` environment variable.

#### INSTANCE_NAME

Name of Google Compute Engine VM instance to be deployed. Terraform will provide
a default name matching the pattern `tiddlywiki-??????` if one is not provided.

#### MACHINE_TYPE

Defaults to `f1-micro`.

## Terraform

Placeholder.

```
$ make apply \
    GOOGLE_PROJECT="mywiki-12345" \
    GIT_USERNAME="jdoe" \
    GIT_REPOSITORY="git@github.com:jdoe/mywiki.git"
make[1]: Entering directory '/usr/local/src/tiddlywiki-gce'
terraform apply -auto-approve \
  -var=project="mywiki-12345" \
  -var=region="europe-west1" \
  -var=zone="europe-west1-d" \
  -var=name="" \
  -var=machine_type="f1-micro" \
  -var=domain="" \
  -var=email="" \
  -var=tw_username="anonymous" \
  -var=tw_password="" \
  -var=git_repository="git@github.com:jdoe/mywiki.git" \
  -var=git_username="jdoe" \
  -var=git_password="" \
  -var=letsencrypt_data="/home/tiddlywiki/letsencrypt"
random_string.password: Creating...
  length:  "" => "12"
  lower:   "" => "true"
  number:  "" => "true"
  result:  "" => "<computed>"
  special: "" => "true"
  upper:   "" => "true"
random_string.name: Creating...
  length:  "" => "6"
  lower:   "" => "true"
  number:  "" => "true"
  result:  "" => "<computed>"
  special: "" => "false"
  upper:   "" => "false"
random_string.name: Creation complete after 0s (ID: w3kvgm)
random_string.password: Creation complete after 0s (ID: p?O&>n7msCBY)
google_compute_firewall.allow-ssh-trusted: Creating...
  allow.#:                  "" => "1"
  allow.802338340.ports.#:  "" => "1"
  allow.802338340.ports.0:  "" => "22"
  allow.802338340.protocol: "" => "tcp"
  destination_ranges.#:     "" => "<computed>"
  direction:                "" => "<computed>"
  name:                     "" => "allow-ssh-trusted"
  network:                  "" => "default"
  priority:                 "" => "1000"
  project:                  "" => "<computed>"
  self_link:                "" => "<computed>"
  source_ranges.#:          "" => "1"
  source_ranges.1080289494: "" => "0.0.0.0/0"
  target_tags.#:            "" => "1"
  target_tags.538119224:    "" => "trusted-ssh"
google_compute_firewall.allow-http: Creating...
  allow.#:                   "" => "1"
  allow.1855828684.ports.#:  "" => "3"
  allow.1855828684.ports.0:  "" => "80"
  allow.1855828684.ports.1:  "" => "443"
  allow.1855828684.ports.2:  "" => "444"
  allow.1855828684.protocol: "" => "tcp"
  destination_ranges.#:      "" => "<computed>"
  direction:                 "" => "<computed>"
  name:                      "" => "allow-http"
  network:                   "" => "default"
  priority:                  "" => "1000"
  project:                   "" => "<computed>"
  self_link:                 "" => "<computed>"
  source_ranges.#:           "" => "1"
  source_ranges.1449289291:  "" => "0.0.0.0/0"
  target_tags.#:             "" => "1"
  target_tags.923935385:     "" => "http-server"
data.template_file.environment: Refreshing state...
google_compute_instance.tiddlywiki: Creating...
  boot_disk.#:                                         "" => "1"
  boot_disk.0.auto_delete:                             "" => "true"
  boot_disk.0.device_name:                             "" => "<computed>"
  boot_disk.0.disk_encryption_key_sha256:              "" => "<computed>"
  boot_disk.0.initialize_params.#:                     "" => "1"
  boot_disk.0.initialize_params.0.image:               "" =>
"cos-cloud/cos-stable"
  boot_disk.0.initialize_params.0.size:                "" => "<computed>"
  boot_disk.0.initialize_params.0.type:                "" => "<computed>"
  can_ip_forward:                                      "" => "false"
  cpu_platform:                                        "" => "<computed>"
  create_timeout:                                      "" => "4"
  guest_accelerator.#:                                 "" => "<computed>"
  instance_id:                                         "" => "<computed>"
  label_fingerprint:                                   "" => "<computed>"
  machine_type:                                        "" => "f1-micro"
  metadata.%:                                          "" => "2"
  metadata.ssh-keys:                                   "" => "tiddlywiki:ssh-rsa AAAMahnamahnabadeebedebemahnamahnabadebedeemahnamahnabadeebedebebadebebadebedeedeede-dede-de-deMahmamanamahnamahnamwompmwompmamomomanamomahnamahnabadeebedebemahnamahnabadebedeemahnamahnabadeebedebebedebebadebedebede-dede-de-demahnamahna jdoe@laptop

  metadata.user-data:                                  "" => "#cloud-config\n\nusers:\n- name: tiddlywiki\n  uid: 2000\n  homedir: /home/tiddlywiki\n\nwrite_files:\n- path: /etc/systemd/system/tiddlywiki.service\n  permissions: 0644\n  owner: root\n content: |\n    [Unit]\n    Description=TiddlyWiki\n    \n    [Service]\n EnvironmentFile=/home/tiddlywiki/systemd/tiddlywiki.env\n WorkingDirectory=/home/tiddlywiki/docker\n    ExecStart=/usr/bin/docker run --name=docker-compose \\\n                                  --rm --env-file env-file \\\n                                  -v /var/run/docker.sock:/var/run/docker.sock \\\n -v \"/home/tiddlywiki/docker:/rootfs/home/tiddlywiki/docker\" \\\n -w \"/rootfs/home/tiddlywiki/docker\" \\\n docker/compose:1.19.0 \\\n                                  up --build --force-recreate\n    ExecStop=/usr/bin/docker stop docker-compose\n ExecStopPost=/usr/bin/docker rm docker-compose\n    RestartSec=5\n Restart=always\n\nruncmd:\n- mkdir /home/tiddlywiki/systemd\n- mkdir /home/tiddlywiki/letsencrypt\n- mkdir /home/tiddlywiki/docker\n- mkdir /home/tiddlywiki/docker/apache\n- mkdir /home/tiddlywiki/docker/automation\n- mkdir /home/tiddlywiki/docker/letsencrypt\n- mkdir /home/tiddlywiki/docker/tiddlywiki\n- chown -R tiddlywiki /home/tiddlywiki\n- chgrp -R tiddlywiki /home/tiddlywiki\n- systemctl daemon-reload\n- systemctl start tiddlywiki.service || true\n"
  metadata_fingerprint:                                "" => "<computed>"
  name:                                                "" => "tiddlywiki-w3kvgm"
  network_interface.#:                                 "" => "1"
  network_interface.0.access_config.#:                 "" => "1"
  network_interface.0.access_config.0.assigned_nat_ip: "" => "<computed>"
  network_interface.0.access_config.0.nat_ip:          "" => "<computed>"
  network_interface.0.address:                         "" => "<computed>"
  network_interface.0.name:                            "" => "<computed>"
  network_interface.0.network:                         "" => "default"
  network_interface.0.network_ip:                      "" => "<computed>"
  network_interface.0.subnetwork_project:              "" => "<computed>"
  project:                                             "" => "<computed>"
  scheduling.#:                                        "" => "1"
  scheduling.0.automatic_restart:                      "" => "true"
  scheduling.0.on_host_maintenance:                    "" => "MIGRATE"
  scheduling.0.preemptible:                            "" => "false"
  self_link:                                           "" => "<computed>"
  tags.#:                                              "" => "3"
  tags.1936433573:                                     "" => "https-server"
  tags.538119224:                                      "" => "trusted-ssh"
  tags.988335155:                                      "" => "http-server"
  tags_fingerprint:                                    "" => "<computed>"
  zone:                                                "" => "europe-west1-d"
google_compute_firewall.allow-ssh-trusted: Still creating... (10s elapsed)
google_compute_firewall.allow-http: Still creating... (10s elapsed)
google_compute_instance.tiddlywiki: Still creating... (10s elapsed)
google_compute_firewall.allow-http: Creation complete after 12s (ID: allow-http)
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_firewall.allow-ssh-trusted: Creation complete after 14s (ID: allow-ssh-trusted)
google_compute_instance.tiddlywiki: Still creating... (20s elapsed)
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_instance.tiddlywiki: Provisioning with 'file'...
google_compute_instance.tiddlywiki: Creation complete after 29s (ID: tiddlywiki-w3kvgm)

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

password = p?O&>n7msCBY
private_ip = 10.34.2.21
public_ip = 35.205.29.117
rw_url = https://anonymous:p%3FO%26%3En7msCBY@35.205.29.117:444
url = https://35.205.29.117
username = anonymous
make[1]: Leaving directory '/usr/local/src/tiddlywiki-gce'
```

## Screencast Demonstration

![Terminal screen capture exmaple of make test](https://i.imgur.com/4uXLEkR.gif)

## TODO

* Prestuff `/recipes/default/tiddlers.json` and `/status` over HTTP2 connections
  for improved client load time performance.
* Make push of Tiddlers to Git more robust on merge conflicts.
* Make LetsEncrypt functionality a little more robust.
* Maybe merge letsencrypt and apache images, because currently certbot has no
  way to restart Apache once a certificate is generated or renewed.
* Improve Terraform configuration (I'm still learning Terraform).
  * Build and deliver Docker images to Google Cloud registry using the docker
    provider.
  * Automatically point DNS at the GCE VM instance using the Google Cloud
    provider with managed DNS.
  * Automatically create a Git source repository in Google Cloud.
* Maybe replace Apache with Nginx for better protection against slowloris?
* Maybe merge tiddlywiki and automation images, but retain seperate containers.
* Improve the way that `htdocs/static-a`, `htdocs/static-b` and `htdocs/static`
  end up being persisted to Git. (Multiple copies is a little sub-optimal).
* Maybe add refresh timer to systemd unit
  https://gist.github.com/Luzifer/7c54c8b0b61da450d10258f0abd3c917
  https://gist.github.com/mosquito/b23e1c1e5723a7fd9e6568e5cf91180f
  https://www.freedesktop.org/software/systemd/man/systemd.time.html
* Tidy up the shell scripts in the containers. They're *nasty*. I was being
  sloppy because they're using busybox ash instead of bash,.. but that's no
  excuse!

## License

MIT License

Copyright (c) 2018 Nicola Worthington

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
