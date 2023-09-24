echo "\e[5;32mRunning Setup... \e[0m"
sudo apt update  2>/dev/null &&
sudo apt install jq -y 2>/dev/null &&
sudo apt install apt-transport-https ca-certificates gnupg curl sudo -y 2>/dev/null &&
rm -f /etc/apt/sources.list.d/google-cloud-sdk.list ; echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 2>/dev/null &&
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 2>/dev/null &&
sudo apt update 2>/dev/null &&
sudo apt install google-cloud-cli -y 2>/dev/null &&
chmod +x ./GCP_ServiceAccountsEnum.sh 2>/dev/null &&
chmod +x ./GCP_ComputeInstancesEnum.sh 2>/dev/null &&
clear &&
echo "\e[1;36m[+] Type \e[1;33m'gcloud version' \e[1;36mto verify gcloud is installed\e[0m"
