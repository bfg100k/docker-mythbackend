#!/bin/bash

# Set timezone
echo "Set correct timezone"
echo "TZ = $TZ"
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "Update timezone"
  echo $TZ > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
else
  echo "Timezone is already correct"
fi

# Fix the config
if [ -f "/home/mythtv/mythweb.conf" ]; then
  echo "Copying config file that was set in home"
  cp /home/mythtv/mythweb.conf /etc/apache2/sites-available/
fi

echo "starting mythweb"
/usr/sbin/apache2ctl -D FOREGROUND