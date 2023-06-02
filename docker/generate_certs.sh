#!/bin/bash -xe

sudo chmod o+rwx config
sudo mkdir config/ssl
sudo chmod o+rwx config/ssl
sudo mkdir ldap var_ldap
sudo chmod 777 ldap
sudo chmod 777 var_ldap
sudo < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32} >config/passfile
sed -i s/'${PASSWORD}'/$(cat config/passfile)/g config/dex.conf
echo "LDAP_SEARCH_BIND_PASSWORD=$(cat config/passfile)" >> .env
POSTGRES_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env
echo "PASSWORD=$POSTGRES_PASSWORD" >> .env
sudo chmod 444 config/passfile 
sudo docker run -v ./config:/config --name micropki --rm docker.io/aescanero/micropki:0.1.2-linux-amd64 \
  cert new --cafile "/config/ca.crt" --cakeyfile "/config/ca.key" \
  --certfile "/config/ldap.crt" --certkeyfile "/config/ldap.key" \
  --hosts *,*.disasterproject.com,localhost,127.0.0.1
sudo docker run -v ./config:/config --name micropki --rm docker.io/aescanero/micropki:0.1.2-linux-amd64 \
  cert new --cafile "/config/ca.crt" --cakeyfile "/config/ca.key" \
  --certfile "/config/ssl/self.cert" --certkeyfile "/config/ssl/self-ssl.key" \
  --hosts *,*.disasterproject.com,localhost,127.0.0.1
#sudo chmod o-w config