#!/bin/bash
#
# Script Name: download_bulk_jamf_scripts.sh
# Description: This script automates the download of scripts from Jamf Pro by utilizing bearer token authentication. 
#              It reads script IDs from a CSV file, then retrieves and saves each script to a specified output directory.
#
# Features:
# - Secure Bearer Token Authentication: Requests and uses a bearer token to securely authenticate with the Jamf Pro API.
# - CSV Input: Reads script IDs from a specified CSV file, allowing for efficient management and downloading of multiple scripts.
# - Output Directory: Saves downloaded scripts to a designated output directory, organizing them by their script names.
# - Error Handling: Includes error handling to manage token request failures and unsuccessful script retrievals.
#
# Usage:
# 1. Update the script with your Jamf Pro API credentials, URL, and output directory.
# 2. Ensure the `jq` utility is installed at the specified path or adjust the path to fit your environment.
# 3. Prepare a CSV file containing the script IDs to be downloaded.
# 4. Execute the script or deploy it via a management system like Jamf Pro.
#
# Note:
# - For security reasons, avoid hardcoding sensitive information like API credentials directly in the script.
# - Consider using environment variables or secure vaults for managing sensitive data.
#
# Author: Muhammad Hasib
# Dated: 13-08-2024


# Variables
jq=/usr/local/Management/Scripts/jq-osx-amd64
jamfProdAPIUser="xxxx"
jamfProdAPIPass='xxxx'
jamfProdURL="https://xxx"
outputDir="/Path/to/output/directory" # Directory to save the downloaded scripts

# Ensure the output directory exists
mkdir -p "$outputDir"

echo "Requesting bearer token..."
jamfTokenCurl=$(curl -s -u "$jamfProdAPIUser":"$jamfProdAPIPass" "$jamfProdURL"/api/v1/auth/token -X POST)
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
done < "/path/to/input.csv" # Directory to input the CSF file

echo "Starting to download scripts..."

# Process each script ID
for id2 in "${scriptIDs[@]}"; do
  echo "Downloading Script ID: $id2"
  response=$(curl -s -X "GET" "$jamfProdURL/JSSResource/scripts/id/$id2" -H "accept: application/json" -H "Authorization: Bearer ${jamfBearerToken}")
  
  # Extract script name and content
  scriptName=$(echo "$response" | $jq -r '.script.name')
  scriptContent=$(echo "$response" | $jq -r '.script.script_contents')

  # Check if the script was retrieved successfully
  if [ -n "$scriptName" ] && [ -n "$scriptContent" ]; then
    echo "$scriptContent" > "$outputDir/$scriptName.sh"
    echo "Successfully downloaded Script ID: $id2 as $scriptName.sh"
  else
    echo "Failed to download Script ID: $id2"
  fi
done

echo "Completed downloading all scripts."
exit 0
