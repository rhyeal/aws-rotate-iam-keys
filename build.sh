#!/usr/bin/env bash

echo "Preparing dist directory..."
rm -rf dist
mkdir -p dist
cp -r src/** dist/
cd dist

CODENAME=$(grep ^UBUNTU_CODENAME= /etc/os-release | cut -f2 -d=)
export VERSION=$(grep ^VERSION= bin/aws-rotate-iam-keys | head -n1 | cut -f2 -d= | tr -d \"\')

echo "Building version $VERSION..."

echo "Updating Debian changelog..."
DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" \
  debchange -v $VERSION --distribution $CODENAME --force-distribution "See release notes on GitHub"

echo "Building Debian binary package..."
# tmp dir for case-insensitive filesystems - cannot rename debian to DEBIAN
mkdir tmp
cp -Rp debian tmp/DEBIAN
cd tmp
envsubst '$VERSION' < DEBIAN/control-debian > DEBIAN/control
dpkg-deb --build . ../../aws-rotate-iam-keys.${VERSION}.deb
cd ../
rm -rf tmp

echo "Building Ubuntu source package..."
envsubst '$VERSION' < debian/control-ubuntu > debian/control
DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" debuild -S -sa -us -uc

echo "Copying changelog back to src..."
cd ..
cp dist/debian/changelog src/debian/changelog

echo "Deleting dist directory..."
rm -rf dist
