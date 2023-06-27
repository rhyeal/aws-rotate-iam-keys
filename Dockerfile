FROM ubuntu:jammy

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  devscripts build-essential dh-make debhelper libdistro-info-perl
