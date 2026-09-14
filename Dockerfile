FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

# hollywood lives in the "universe" component, which is enabled by default on
# the official Ubuntu image. plocate replaces mlocate, which was dropped in
# Ubuntu 23.10+, and still provides the locate/updatedb commands.
RUN \
  apt-get update -qq && \
  apt-cache policy hollywood && \
  ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo $TZ > /etc/timezone && \
  apt-get install -qqy tzdata plocate hollywood && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  updatedb

ENTRYPOINT [ "hollywood" ]
