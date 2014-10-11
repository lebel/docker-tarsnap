#!/bin/sh

if [ -e /config/main.cf ]; then
  cp /config/main.cf /etc/postfix/main.cf
fi

(crontab -l 2>/dev/null; echo "@daily /helpers/tarsnap.cron") | crontab -

if [ -e /config/authorized_keys ]; then
  cp /config/authorized_keys /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
fi

# make sure MAILTO is respected

if [ -e /helpers/tarsnap.cron ]; then
  sed -i -e "s;\$MAILTO;$MAILTO;g" /helpers/tarsnap.cron
fi
