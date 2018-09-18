#!/usr/bin/env bash

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' jq|grep "install ok installed")
echo Checking for jq: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "You need jq installed to run this script. Please install it."
  sudo apt-get install jq
fi

PROFILE=$1

if [[ -z "$1" ]]; then
	PROFILE=default
fi

CURRENT_KEY_ID=$(aws iam list-access-keys --output json --profile $PROFILE | jq '.AccessKeyMetadata[0].AccessKeyId' | tr -d '"')

echo $CURRENT_KEY_ID
echo "Making new access key"
RESPONSE=$(aws iam create-access-key --profile $PROFILE | jq .AccessKey)
ACCESS_KEY=$(echo $RESPONSE | jq '.AccessKeyId' | tr -d '"')
SECRET=$(echo $RESPONSE | jq '.SecretAccessKey' | tr -d '"')
aws iam delete-access-key --access-key-id $CURRENT_KEY_ID
aws configure set aws_access_key_id $ACCESS_KEY --profile $PROFILE
aws configure set aws_secret_access_key $SECRET --profile $PROFILE
echo "Made new key $ACCESS_KEY"

echo "Key rotated"
exit 0
