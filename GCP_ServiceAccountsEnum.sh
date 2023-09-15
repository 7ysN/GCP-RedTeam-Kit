					######################################
					##  GCP Red Team Enumeration Kit    ##
					##  Subject: Service Accounts	    ##
					##  Auditor: Yuval Saban	    ##					
					######################################


# Set The Project Name
echo -n "\e[5;31m[!] Enter Project Name: \e[0m"
read project

# Current User
gcloud auth list --quiet  2>/dev/null| grep '^\*' | awk '{print $2}' > CurrentUsername.txt
for currentUser in $(cat CurrentUsername.txt); 
	do 
		echo "\e[0;36m[+] Current Username: \e[1;32m$currentUser \e[0m"; 
	done

# List all Service Account
echo " "
echo "\e[1;33mService Accounts: \e[0m"
gcloud iam service-accounts list --project $project |grep -oE '[[:alnum:].+-]+@[[:alnum:].+-]+' | tee ServiceAccounts.txt

# Get The IAM Policy of the Project
echo " "
echo "\e[1;33mIAM Policy of the Project: \e[0m"
gcloud projects get-iam-policy $project 

# Get the IAM Roles of the Service Accounts (Project Level) 
echo " "
echo "\e[1;33mRoles (Project Level): \e[0m"
for serviceAccount in $(cat ServiceAccounts.txt); 
	do 
		echo "\e[1;36m[+] $serviceAccount \e[0m"; 
		gcloud projects get-iam-policy $project --flatten="bindings[].members" --filter="bindings.members=serviceaccount:$serviceAccount" --format="value(bindings.role)"; 
	done
	
# Custom Roles Describe
echo " "
echo "\e[1;33mCustom Roles Describe: \e[0m"
for serviceAccount in $(cat ServiceAccounts.txt); 
	do
    		echo "\e[1;36m[+] $serviceAccount \e[0m"
    		gcloud projects get-iam-policy cgcrts-staging --flatten="bindings[].members" --filter="bindings.members=serviceaccount:$serviceAccount" --format="value(bindings.role)"
	done | grep -v "[+]" | awk -F/ '{print $NF}'| sort | uniq > CustomRoles.txt

for CRole in $(cat CustomRoles.txt); 
	do
    		gcloud iam roles describe $CRole --project cgcrts-staging 2>/dev/null
    		echo " "
	done

# Enumerate Permissions on specific Service Accounts
echo "\e[1;33mIAM Service Accounts Policies: \e[0m"
for serviceAccount in $(cat ServiceAccounts.txt); 
	do 
		echo "\e[1;36m[+] $serviceAccount \e[0m"; 
		gcloud iam service-accounts get-iam-policy $serviceAccount --project $project; 
	done

# Clean Garbage
rm ./CustomRoles.txt
rm ./CurrentUsername.txt
rm ./ServiceAccounts.txt
	
	