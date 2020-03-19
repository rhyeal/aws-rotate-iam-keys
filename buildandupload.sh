#!/usr/bin/env bash
export VERSION=$1

# set up the website files and upload them to AWS S3
PROFILE=${2:-default}
echo $PROFILE

# version swap the website
envsubst < website/index.template.html > website/index.html
aws s3 sync ./website s3://aws-rotate-iam-keys.com --delete --acl public-read --profile $PROFILE
aws s3 cp ./Windows/aws-rotate-iam-keys.ps1 s3://aws-rotate-iam-keys.com/aws-rotate-iam-keys.ps1 --acl public-read --profile $PROFILE
rm website/index.html

# make the dist folder
mkdir -p dist
# copy in the src and swap the versions
cp -r src/** dist/
sed "s/<<VERSION>>/$VERSION/g" src/bin/aws-rotate-iam-keys > dist/bin/aws-rotate-iam-keys

CHANGES="aws-rotate-iam-keys_${VERSION}_source.changes"
# make the homebrew zip file
zip -r aws-rotate-iam-keys_${VERSION}.zip dist

cd dist

# make the changelog
DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" dch -v $VERSION --distribution bionic --force-distribution

mv debian DEBIAN
envsubst < DEBIAN/control-debian > DEBIAN/control

# make the Debian .deb
dpkg-deb --build . ../aws-rotate-iam-keys.${VERSION}.deb

rm DEBIAN/control
mv DEBIAN debian
envsubst < debian/control-ubuntu > debian/control

DEBEMAIL="Adam Link <aws-rotate-iam-keys@rhyeal.com>" DEBFULLNAME="Adam Link" debuild -S -sa -us -uc
cd ..
dput ppa:rhyeal/aws-rotate-iam-keys $CHANGES
cp dist/debian/changelog src/debian/changelog
rm -rf dist

# update the readme
export WIN_MD5=$(md5sum Windows/aws-rotate-iam-keys.ps1)
export LINUX_MD5=$(md5sum aws-rotate-iam-keys.$VERSION.deb | cut -c 1-32)
envsubst < README.template.md > README.md
