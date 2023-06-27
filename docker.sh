#!/bin/bash

set -e
set -x

docker build -t aws-rotate-iam-keys .

# note: cannot use xargs --no-run-if-empty, GNU extension, not included on MacOS
for image in $(docker images -q --filter "dangling=true" --filter "label=name=aws-rotate-iam-keys"); do
  docker rmi $image
done

docker run -it --rm --cap-add=NET_ADMIN --device /dev/net/tun \
  -v "${PWD}":/root/aws-rotate-iam-keys -w /root/aws-rotate-iam-keys \
  $@ aws-rotate-iam-keys
