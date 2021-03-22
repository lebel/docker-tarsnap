FROM phusion/baseimage:master-amd64
MAINTAINER David Lebel <lebel@lebel.org>
ENV DEBIAN_FRONTEND noninteractive
ENV TARSNAP_VERSION 1.0.39

# Set correct environment variables
ENV HOME /root

# VOLUMEs
VOLUME ["/config", "/data"]

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN curl -o tarsnap-deb-packaging-key.asc https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc && \
        apt-key add tarsnap-deb-packaging-key.asc && \
        echo "deb http://pkg.tarsnap.com/deb/$(lsb_release -s -c) ./" | tee -a /etc/apt/sources.list.d/tarsnap.list
RUN apt-get update -q && \
    apt-get install bsd-mailx postfix tarsnap -yq

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
RUN apt-get --purge remove logrotate -yq && apt-get autoremove -yq && apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
