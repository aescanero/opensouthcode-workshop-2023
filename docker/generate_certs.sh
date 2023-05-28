#!/bin/bash

sudo chmod o+rwx config
sudo mkdir config/ssl
sudo chmod o+rwx config/ssl
sudo chmod 777 ldap
sudo chmod 777 var_ldap
sudo < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32} >config/passfile 
sudo docker run -v ./config:/config --name micropki --rm -it docker.io/aescanero/micropki:0.1.2-linux-amd64 \
  cert new --cafile "/config/ca.crt" --cakeyfile "/config/ca.key" \
  --certfile "/config/ldap.crt" --certkeyfile "/config/ldap.key" \
  --hosts *,*.disasterproject.com,localhost,127.0.0.1
sudo docker run -v ./config:/config --name micropki --rm -it docker.io/aescanero/micropki:0.1.2-linux-amd64 \
  cert new --cafile "/config/ca.crt" --cakeyfile "/config/ca.key" \
  --certfile "/config/ssl/self.cert" --certkeyfile "/config/ssl/self-ssl.key" \
  --hosts *,*.disasterproject.com,localhost,127.0.0.1
#sudo chmod o-w config