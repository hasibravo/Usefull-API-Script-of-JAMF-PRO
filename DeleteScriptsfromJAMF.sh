#!/bin/bash
#
# Script Name: delete_Scripts_from_Jamf.sh
# Description: This script automates the deletion of scripts from Jamf Pro using a bearer token for authentication. 
#              It reads script IDs from a CSV file and deletes each corresponding script from the Jamf Pro server.
#
# Author: Muhammad Hasib
#
# Features:
# - Secure Bearer Token Authentication: Retrieves and uses a bearer token to securely authenticate API requests.
# - CSV Input: Reads script IDs from a specified CSV file, enabling bulk deletion of multiple scripts.
# - Error Handling: Includes checks to handle token request failures and unsuccessful script deletions.
#
# Usage:
# 1. Update the script with your Jamf Pro API credentials and URL.
# 2. Ensure the `jq` utility is installed at the specified path or adjust the path accordingly.
# 3. Prepare a CSV file containing the script IDs that need to be deleted.
# 4. Execute the script or deploy it via a management system like Jamf Pro.
#
# Note:
# - For security, avoid hardcoding sensitive information like API credentials directly in the script.
# - Consider using environment variables or secure vaults for managing sensitive data.
#
# Script to delete scripts from Jamf Pro

# Variables
jq=/usr/local/Management/Scripts/jq-osx-amd64
jamfProdAPIUser="xxxx"
jamfProdAPIPass='xxxx3'
jamfProdURL="https://xxx.jamfcloud.com"

echo "Requesting bearer token..."
jamfTokenCurl=$(curl -s -u "$jamfProdAPIUser":"$jamfProdAPIPass" "$jamfProdURL/api/v1/auth/token" -X POST)
jamfBearerToken=$(echo "$jamfTokenCurl" | $jq -r .token)

if [ -z "$jamfBearerToken" ]; then
  echo "Failed to obtain bearer token. Exiting."
  exit 1
else
  echo "Bearer token obtained successfully."
fi

# Read all script IDs from the file
scriptIDs=()
while IFS= read -r id1; do
  # Remove spaces from the ID
  id1=$(echo $id1 | tr -d '[:space:]')
  scriptIDs+=($id1)
done < "/Users/mh286/Downloads/Deletescriptids.csv"

echo "Starting to delete scripts..."

# Process each script ID
for id2 in "${scriptIDs[@]}"; do
  echo "Deleting Script ID: $id2"
  response=$(curl -s -X "DELETE" "$jamfProdURL/JSSResource/scripts/id/$id2" -H "Authorization: Bearer ${jamfBearerToken}")
  
  if [ $? -eq 0 ]; then
    echo "Successfully deleted Script ID: $id2"
  else
    echo "Failed to delete Script ID: $id2"
  fi
done

echo "Completed deleting all scripts."
exit 0
