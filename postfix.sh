#!/bin/sh
exec 2>&1
service postfix start
sleep 5
exec tail -F /var/log/mail.log
