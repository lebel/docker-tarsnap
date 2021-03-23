FROM alpine:latest
MAINTAINER David Lebel <lebel@nobiaze.ca>

# Set correct environment variables
ENV HOME /root

# VOLUMEs
VOLUME ["/config", "/data"]

# add various tarsnap's helpers in /helpers
ADD helpers/ /helpers

# Activate the various services
RUN set -x \
    && apk add --update --no-cache openrc \
    # Disable getty's
    && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
    && sed -i \
        # Change subsystem type to "docker"
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        # Allow all variables through
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        # Start crashed services
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        # Define extra dependencies for services
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        /etc/rc.conf \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
            /etc/init.d/hwclock \
            /etc/init.d/hwdrivers \
            /etc/init.d/modules \
            /etc/init.d/modules-load \
            /etc/init.d/modloop \
    # Can't do cgroups
    && sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh

RUN apk add tarsnap postfix dcron heirloom-mailx

# insert a configured tarsnap.conf
ADD tarsnap.conf /etc/tarsnap

RUN rc-update add postfix default; \
    rc-update add dcron default; \
    rc-update add local default

# Configure postfix

RUN postconf -e myhostname=moya.lan; \
    postconf -e mydomain=lebel.org; \
    postconf -e relayhost=smtp.lan; \
    postconf -e smtp_use_tls=no; \
    postconf -e smtpd_use_tls=no; \
    postconf -e myorigin='$mydomain'; \
    postconf -e inet_protocols='all'; \
    postconf -e inet_interfaces='all'; \
    postconf -e mynetworks_style='host'

ADD startup.sh /etc/local.d/startup.start

RUN ln -s /helpers/tarsnap.cron /etc/periodic/daily/tarsnap.cron

WORKDIR /etc/init.d
CMD ["/sbin/init"]
