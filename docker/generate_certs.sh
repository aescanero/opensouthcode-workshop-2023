#!/bin/bash

sudo chown o+rwx config
sudo docker run -v ./config:/config --name micropki --rm -it docker.io/aescanero/micropki:0.1.2-linux-amd64 \
  cert new --cafile "/config/ca.crt" --cakeyfile "/config/ca.key" \
  --certfile "/config/ldap.crt" --certkeyfile "/config/ldap.key" \
  --hosts *,*.disasterproject.com,localhost,127.0.0.1
sudo docker run -v ./config:/config --name micropki --rm -it docker.io/aescanero/micropki:0.1.2-linux-amd64 \
  cert new --cafile "/config/ca.crt" --cakeyfile "/config/ca.key" \
  --certfile "/config/nginx.crt" --certkeyfile "/config/nginx.key" \
  --hosts *,*.disasterproject.com,localhost,127.0.0.1
#sudo chown o-w config