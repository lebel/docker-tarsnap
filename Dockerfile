FROM phusion/baseimage:0.9.15
MAINTAINER David Lebel <lebel@lebel.org>
ENV DEBIAN_FRONTEND noninteractive
ENV TARSNAP_VERSION 1.0.35

# Set correct environment variables
ENV HOME /root

# VOLUMEs
VOLUME ["/config", "/data"]

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN apt-get update -q && \
apt-get install bsd-mailx postfix -yq && \
apt-get install build-essential wget libssl-dev zlib1g-dev e2fslibs-dev -yq && \
wget https://www.tarsnap.com/download/tarsnap-autoconf-1.0.35.tgz -O /tmp/tarsnap.tar.gz && \
mkdir /tmp/tarsnap && \
tar -C /tmp/tarsnap -xvf /tmp/tarsnap.tar.gz --strip-components 1 && \
cd /tmp/tarsnap && ./configure --prefix=/usr --sysconfdir=/etc && make install

# insert a configured tarsnap.conf
ADD tarsnap.conf /etc/tarsnap.conf

# add various tarsnap's helpers in /helpers
ADD helpers/ /helpers

# Add startup.sh to the my_init.d initialisation.
ADD startup.sh /etc/my_init.d/00_startup.sh

# Add postfix to runit
RUN mkdir /etc/service/postfix
ADD postfix.sh /etc/service/postfix/run
RUN chmod +x /etc/service/postfix/run

# clean up
RUN apt-get autoremove -yq && apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
