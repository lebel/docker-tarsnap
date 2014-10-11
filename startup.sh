#!/bin/sh

if [ -e /config/main.cf ]; then
  cp /config/main.cf /etc/postfix/main.cf
fi

(crontab -l 2>/dev/null; echo "@daily /helpers/tarsnap.cron") | crontab -

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
