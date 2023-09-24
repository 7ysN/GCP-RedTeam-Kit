#!/bin/bash

sudo apt update
sudo apt install jq -y
sudo apt install apt-transport-https ca-certificates gnupg curl sudo -y
rm -f /etc/apt/sources.list.d/google-cloud-sdk.list ; echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt update
sudo apt install google-cloud-cli -y
chmod +x ./GCP_ServiceAccountsEnum.sh
chmod +x ./GCP_ComputeInstancesEnum.sh
