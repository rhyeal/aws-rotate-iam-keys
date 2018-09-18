#!/usr/bin/env bash
VERSION=$1

cd src
dch -i

debuild -S -sa
cd ..
dput ppa:rhyeal/aws-rotate-iam-keys aws-rotate-iam-keys_$VERSION_source.changes
