#!/bin/bash

#extract the secret name
SECRET=$(sudo kubectl get secrets -n dragonchain | grep -o 'd\-[a-z0-9-]*\-secrets')

#extract the hmac-id and hmac-key
HMAC_ID=$(sudo kubectl get secret -n dragonchain $SECRET -o json | jq -r .data.SecretString | base64 -d | jq '.["hmac-id"]' | grep -o '[^"]*')
HMAC_KEY=$(sudo kubectl get secret -n dragonchain $SECRET -o json | jq -r .data.SecretString | base64 -d | jq '.["hmac-key"]' | grep -o '[^"]*')

#extract the pod name
POD_NAME=$(kubectl get pod -n dragonchain -l app.kubernetes.io/component=webserver | tail -1 | awk '{print $1}')

#extract the public id
PUBLIC_ID=$(sudo kubectl exec -n dragonchain $POD_NAME -- python3 -c "from dragonchain.lib.keys import get_public_id; print(get_public_id())")

npm list -g qrcode-terminal || npm install -g qrcode-terminal

qrcode-terminal "{public-id: \"$PUBLIC_ID\", access-id: \"$HMAC_ID\", access-key: \"$HMAC_KEY\"}"

echo
echo

echo -e "\e[93mYOUR CREDENTIALS:\e[0m"
echo "{public-id: \"$PUBLIC_ID\", access-id: \"$HMAC_ID\", access-key: \"$HMAC_KEY\"}"
echo
