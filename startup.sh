#!/bin/sh

# replace the tarsnap.conf in /etc from the one in /config on 
# startup.

if [ -e /config/tarsnap.conf ]; then
  cp /config/tarsnap.conf /etc/tarsnap.conf
fi

# Since we have a postfix running inside this container, it might
# be possible the user has a specific main.cf to be used instead
# of the default one.

if [ -e /config/main.cf ]; then
  cp /config/main.cf /etc/postfix/main.cf
fi

# if /config/crontab exists, use it, otherwise, use the @daily

if [ -e /config/crontab ]; then
  (crontab -l 2>/dev/null; cat /config/crontab) | crontab -
else
  (crontab -l 2>/dev/null; echo "@daily /helpers/tarsnap.cron") | crontab -
if

# if you want to log into your container, use a /config/authorized_keys
# that contains valid key to get into the root account.

if [ -e /config/authorized_keys ]; then
  cp /config/authorized_keys /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
fi

# abort if MAILTO and INCLUDE isn't provided.

if [ -z "$INCLUDE" ] || [ -z "$MAILTO" ]; then 
   echo "You need to provide both MAILTO and INCLUDE when starting"
   echo "this container."
   exit 1
fi

# fill MAILTO and INCLUDE into helpers scripts.

sed -i -e "s;INCLUDE;$INCLUDE;g" -e "s;MAILTO;$MAILTO;g" /helpers/*
