#!/usr/bin/env bash
VERSION="aws-rotate-iam-keys_$1_source.changes"

# make the homebrew zip file
zip -r aws-rotate-iam-keys_$VERSION src

cd src
DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" dch -i --distribution bionic --force-distribution



DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" debuild -S -sa
cd ..
dput ppa:rhyeal/aws-rotate-iam-keys $VERSION
