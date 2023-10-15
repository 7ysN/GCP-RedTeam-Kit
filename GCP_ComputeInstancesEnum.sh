# Set The Project Name
echo -n "\e[5;31m[!] Enter Project Name: \e[0m"
read project

# Current User
gcloud auth list --quiet  2>/dev/null| grep '^\*' | awk '{print $2}' > CurrentUsername.txt
for currentUser in $(cat CurrentUsername.txt); 
	do 
		echo "\e[0;36m[+] Current Username: \e[1;32m$currentUser \e[0m"; 
	done
# List all Compute Instances in the Project
gcloud compute instances list --project $project --format="table[box,title='Compute Instances'](NAME,ZONE,INTERNAL_IP,EXTERNAL_IP,STATUS)"

# Select a Compute Instance
echo "\n\e[1;33mSelect a Compute Instance to inspect:\e[0m"
gcloud compute instances list --project $project --format="table[no-heading](name,zone)"  2>/dev/null | awk '{print $1}' | nl
read -p "Enter The Number of The Instance You Want To Inspect: " selected_instance_num
instance_name=$(gcloud compute instances list --project $project --format="table[no-heading](name,zone)" | awk -v num="$selected_instance_num" 'NR==num {print $1}')
zone=$(gcloud compute instances list --project $project --format="table[no-heading](name,zone)" | awk -v num="$selected_instance_num" 'NR==num {print $2}')
if [ -z "$instance_name" ]; then
  echo "\e[0;31m[-] Invalid Choise. \e[0m"
  exit 1
fi

# Get the IAM Policy of the Selected Compute Instance
echo " "
echo "\e[1;33mIAM Policy of the Selected Compute Instance ($instance_name):\e[0m"
echo "\e[1;36m[+] $instance_name:\e[0m"
gcloud compute instances get-iam-policy "$instance_name" --zone "$zone" --project $project --format=json  | jq -r '.bindings[] | "\u250F" + "─" * 100 + "\u2513\n User: \(.members[])\n Role: \(.role)\n\u2517" + "─" * 100 + "\u251B"' 2>/dev/null
	
# Compute Instaces Describe - Check for SSH Private Keys
echo " "
echo "\e[1;33mCompute Instances Information \e[1;31m(Check for PRIVATE SSH Keys!)\e[1;33m: \e[0m"
echo "\e[1;36m[+] $instance_name:\e[0m"
gcloud compute instances describe $instance_name --zone $zone --project $project --format=json | jq -r '{
"Compute Name": .name,
"External IP Address": .networkInterfaces[0].accessConfigs[0].natIP,
"Internal IP Address": .networkInterfaces[0].networkIP,
"Attached Service Account": .serviceAccounts[0].email,
"Tags": .tags.items}'
gcloud compute instances describe $instance_name --zone $zone --project $project --format=json | jq -r '.metadata.items[] | select(.key == "private-ssh-key") | .value' 2>/dev/null

# Append the private key to Private_Key.ssh
private_key=$(gcloud compute instances describe $instance_name --zone $zone --project $project --format=json | jq -r '.metadata.items[] | select(.key == "private-ssh-key") | .value' 2>/dev/null)
if [ -z "$private_key" ]; then
  echo " "
  echo "\e[0;31m[-] No Private Keys were found. \e[0m"
  echo " "
else
  echo "-----BEGIN OPENSSH PRIVATE KEY-----" >> Private_Key.ssh
  echo "$private_key" | fold -w 70 >> Private_Key.ssh
  echo "-----END OPENSSH PRIVATE KEY-----" >> Private_Key.ssh
  chmod 600 ./Private_Key.ssh
  echo "\e[0;36m[+] File Created: \e[1;31mPrivate_Key.ssh \e[0m"
  echo " "
fi

# Describe Compute Project Info (Searching for SSH Public Keys)
echo "\e[1;33mCompute Project Info \e[1;31m(Check for PUBLIC SSH Keys!)\e[1;33m: \e[0m"
gcloud compute project-info describe --project $project --format=json | jq -r '{
  commonInstanceMetadata: .commonInstanceMetadata | del(.items),
  items: .commonInstanceMetadata.items[] | {key: .key, value: .value},
  "Creation Timestamp": .creationTimestamp,
  "Default Service Account": .defaultServiceAccount,
  "Project Name": .name
   }' 2>/dev/null
public_keys=$(gcloud compute project-info describe --project $project --format=json | jq -r '.commonInstanceMetadata.items[] | select(.key == "ssh-keys") | .value' 2>/dev/null)
if [ "$public_keys" == "null" ] 2>/dev/null; then 
  echo " "
  echo "\e[0;31m[-] No Public Keys were found. \e[0m"
else
  echo "$public_keys" >> Public_Key.pub
  echo " "
  echo "\e[0;36m[+] File Created: \e[1;31mPublic_Key.pub \e[0m"
fi
echo " "

# Firewall Rules
echo "\e[1;33mFirewall Rules: \e[0m"
gcloud compute firewall-rules list --format=json --project $project | jq -r 'map("\u250F" + "─" * 60 + "\u2513\n" +
  " Protocol: " + (.allowed[0].IPProtocol // "N/A") + "\n" +
  " Port: " + (if .allowed[0].ports then .allowed[0].ports[] else "N/A" end) + "\n" +
  " Description: " + (.description // "N/A") + "\n" +
  " Direction: " + (.direction // "N/A") + "\n" +
  " Name: " + (.name // "N/A") + "\n" +
  " CIDR: " + (if .sourceRanges then .sourceRanges[] else "N/A" end) + "\n" +
  " Tags: " + (if .targetTags then .targetTags[] else "N/A" end) + "\n" +
  "\u2517" + "─" * 60 + "\u251B") | join("\n\n")' 2>/dev/null

# Clean Garbage
rm -f ./CurrentUsername.txt
