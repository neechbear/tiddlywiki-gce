# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

GOOGLE_PROJECT ?=
GOOGLE_REGION ?= europe-west1
GOOGLE_ZONE ?= $(GOOGLE_REGION)-d

INSTANCE_NAME :=
MACHINE_TYPE := f1-micro

DOCKER_COMPOSE_VER := 1.19.0

DOMAIN :=
EMAIL :=
LETSENCRYPT_DATA := /home/tiddlywiki/letsencrypt
GIT_REPOSITORY :=
GIT_USERNAME :=
GIT_SSH_KEY := id_rsa
TW_USERNAME := anonymous
TW_PASSWORD := letmein

CP := cp

TERRAFORM_TARGETS := apply destroy plan refresh
.PHONY: $(TERRAFORM_TARGETS) test clean check_clean help automation/id_rsa

.DEFAULT_GOAL := help

-include secret.mk

help:
	@echo "Available targets:"
	@echo "  make help"
	@echo "  make test"
	@echo "  make apply"
	@echo "  make destroy"
	@echo "  make plan"
	@echo "  make refresh"
	@echo "  make clean"

check_clean:
	@echo "Terraform plugins and workspace state will be permanently destroyed!"
	@echo -n "Are you sure? [y/N] " && read ans && [ "$$ans" = "y" ]

clean: check_clean
	$(RM) -R .terraform terraform.tfstate terraform.tfstate.backup

automation/id_rsa: $(GIT_SSH_KEY)
	$(CP) $< $@

$(TERRAFORM_TARGETS): automation/id_rsa
	@:$(call check_defined, GOOGLE_PROJECT, Google Cloud project ID)
	@:$(call check_defined, INSTANCE_NAME, Google Cloud compute instance VM name)
	terraform $@ \
		-var=project="$(GOOGLE_PROJECT)" \
		-var=region="$(GOOGLE_REGION)" \
		-var=zone="$(GOOGLE_ZONE)" \
		-var=name="$(INSTANCE_NAME)" \
		-var=machine_type="$(MACHINE_TYPE)" \
		-var=domain="$(DOMAIN)" \
		-var=email="$(EMAIL)" \
		-var=letsencrypt_data="$(LETSENCRYPT_DATA)" \
		-var=git_repository="$(GIT_REPOSITORY)" \
		-var=git_username="$(GIT_USERNAME)" \
		-var=tw_username="$(TW_USERNAME)" \
		-var=tw_password="$(TW_PASSWORD)"

.terraform/plugins/*/terraform-provider-template_v*:
.terraform/plugins/*/terraform-provider-google_v*:
	terraform init

test: automation/id_rsa
	docker run \
		--rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$$PWD:/rootfs/$$PWD" \
		-w "/rootfs/$$PWD" \
		--env-file env-file \
	  docker/compose:$(DOCKER_COMPOSE_VER) up --build --force-recreate

check_defined = \
  $(strip $(foreach 1,$1, \
    $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
  $(if $(value $1),, \
    $(error Undefined $1$(if $2, ($2))$(if $(value @), \
      required by target `$@')))

