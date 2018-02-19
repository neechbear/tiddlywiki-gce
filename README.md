# tiddlywiki

Google Compute Engine based TiddlyWiki 5 Server.

See https://nicolaw.uk/gcloud.

```bash
gcloud compute instances create $INSTANCE_NAME \
  --image "$(latest_image cos-stable)" \
  --image-project cos-cloud \
  --zone europe-west4-b \
  --machine-type f1-micro \
  --tags http-server,https-server \
  --metadata-from-file user-data=cloud-config.yaml
```

