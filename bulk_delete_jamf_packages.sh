#!/bin/bash
# 
# Script Name: bulk_delete_jamf_packages.sh
# Description: This script automates the bulk deletion of packages in Jamf Pro by utilizing bearer token authentication. 
#              It reads package IDs from a CSV file, then deletes each package from the Jamf Pro server.
#
# 
# Features:
# - Secure Bearer Token Authentication: Requests and uses a bearer token to securely authenticate with the Jamf Pro API.
# - CSV Input: Reads package IDs from a specified CSV file, allowing for efficient management and updates of packages to be deleted.
# add the file path in the script "/Path/to/file.csv"
# - Error Handling: Includes error handling to manage token request failures and unsuccessful package deletions.
#
# Usage:
# 1. Update the script with your Jamf Pro API credentials and URL.
# 2. Ensure the jq utility is installed at the specified path or adjust the path to fit your environment.
# 3. Prepare a CSV file containing the package IDs to be deleted.
# 4. Execute the script or deploy it via a management system like Jamf Pro.
# 
# Note:
# - For security reasons, avoid hardcoding sensitive information like API credentials directly in the script.
# - Consider using environment variables or secure vaults for managing sensitive data.
#
# Author: Muhammad Hasib
# Dated: 13-08-2024


jq=/usr/local/Management/Scripts/jq-osx-amd64
jamfProdAPIUser="xxxx"
jamfProdAPIPass='xxxx'
jamfProdURL="https://xx.jamfcloud.com"

echo "Requesting bearer token..."
jamfTokenCurl=$(curl -s -u "$jamfProdAPIUser":"$jamfProdAPIPass" "$jamfProdURL"/api/v1/auth/token -X POST)
jamfBearerToken=$(echo "$jamfTokenCurl" | $jq -r .token)

if [ -z "$jamfBearerToken" ]; then
  echo "Failed to obtain bearer token. Exiting."
  exit 1
else
  echo "Bearer token obtained successfully."
fi

# Read all policy IDs from the file
policyIDs=()
while IFS= read -r id1; do
  # Remove spaces from the ID
  id1=$(echo $id1 | tr -d '[:space:]')
  policyIDs+=($id1)
done < "/Users/mh286/Downloads/Pakages1.csv"

echo "Starting to process Package IDs..."

# Process each policy ID
for id2 in "${policyIDs[@]}"; do
  echo "Deleting Package ID: $id2"
  response=$(curl -s -X "DELETE" "https://uon.jamfcloud.com/JSSResource/packages/id/$id2" -H 'accept: application/xml' -H "Authorization: Bearer ${jamfBearerToken}")
  if [ $? -eq 0 ]; then
    echo "Successfully deleted Package ID: $id2"
  else
    echo "Failed to delete Package ID: $id2"
  fi
#  echo "Waiting for 1 seconds before proceeding to the next Package....-"
#  sleep 1
done

echo "Completed processing all Package IDs."
exit 0

