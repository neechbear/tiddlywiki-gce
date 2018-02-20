.PHONY: deploy test

INSTANCE_NAME := tiddlywiki
ZONE := europe-west1-d
MACHINE_TYPE := f1-micro
COMPUTE_IMAGE = $(shell gcloud compute images list --sort-by ~NAME --format json --filter "cos-stable" | jq -r '.[0].name')

test:
	docker run \
		--rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$$PWD:/rootfs/$$PWD" \
		-w "/rootfs/$$PWD" \
		--env-file env-file \
	  docker/compose:1.19.0 up --build --force-recreate

deploy:
	gcloud compute instances create $(INSTANCE_NAME) \
		--image "$(COMPUTE_IMAGE)" \
		--image-project cos-cloud \
		--zone $(ZONE) \
		--machine-type $(MACHINE_TYPE) \
		--tags http-server,https-server \
		--metadata-from-file user-data=cloud-config.yaml
