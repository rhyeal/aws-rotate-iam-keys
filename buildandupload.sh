#!/usr/bin/env bash
export VERSION=$1
CHANGES="aws-rotate-iam-keys_$1_source.changes"
# make the homebrew zip file
zip -r aws-rotate-iam-keys_$VERSION.zip src

cd src

# make the changelog
DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" dch -v $VERSION --distribution bionic --force-distribution

mv debian DEBIAN
envsubst < DEBIAN/control-debian > DEBIAN/control

# make the Debian .deb
dpkg-deb --build . ../aws-rotate-iam-keys.$VERSION.deb

rm DEBIAN/control
mv DEBIAN debian
envsubst < debian/control-ubuntu > debian/control

DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" debuild -S -sa
cd ..
dput ppa:rhyeal/aws-rotate-iam-keys $CHANGES
rm src/debian/control
