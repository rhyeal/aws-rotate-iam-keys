#!/usr/bin/env bash

set -e

VERSION=$(grep ^VERSION= src/bin/aws-rotate-iam-keys | head -n1 | cut -f2 -d= | tr -d \"\')
echo "Uploading version $VERSION..."

echo "Select AWS profile..."
PROFILES=$(grep '^\[profile' ~/.aws/config | awk '{print $NF}' | sed 's/]//' | sort)
select PROFILE in default $PROFILES; do break; done

echo "Updating S3 website..."
aws s3 sync ./website s3://aws-rotate-iam-keys.com --delete --acl public-read --profile $PROFILE

echo "Copying Powershell script to S3..."
# FIXME: Is this necessary? Just download from GitHub?
aws s3 cp ./Windows/aws-rotate-iam-keys.ps1 s3://aws-rotate-iam-keys.com/aws-rotate-iam-keys.ps1 --acl public-read --profile $PROFILE

echo "Uploading Ubuntu package to PPA..."
dput ppa:rhyeal/aws-rotate-iam-keys aws-rotate-iam-keys_${VERSION}_source.changes
