FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

RUN \
  apt-get update -qq && \
  apt-get install -qqy tzdata mlocate hollywood && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  dpkg-reconfigure tzdata && \
  updatedb

CMD ["hollywood"]
