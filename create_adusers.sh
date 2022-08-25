#!/bin/bash

randomChar() {
    s=abcdefghijklmnopqrstuvxwyz
    p=$(( $RANDOM % 26))
    echo -n ${s:$p:1}
}

randomNum() {
    echo -n $(( $RANDOM % 10 ))
}

randomCharUpper() {
    s=ABCDEFGHIJKLMNOPQRSTUVWXYZ
    p=$(( $RANDOM % 26))
    echo -n ${s:$p:1}
}


azureUserName=$(az account show --query user.name -o tsv)
domain=$(cut -d "@" -f 2 <<< $azureUserName)

webdevpassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 
apidevpassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 

echo "Creating webdev and apidev users..."
az ad user create --display-name api-dev --password $apidevpassword --user-principal-name apidev@$domain

az ad user create --display-name web-dev --password $webdevpassword --user-principal-name webdev@$domain
