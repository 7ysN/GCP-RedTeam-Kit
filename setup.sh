#!/bin/bash

sudo apt update
sudo apt install apt-transport-https ca-certificates gnupg curl sudo
rm -f /etc/apt/sources.list.d/google-cloud-sdk.list ; echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt install google-cloud-cli