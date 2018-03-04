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
if [ -f "/home/mythtv/.mythtv/config.xml" ]; then
  echo "Copying config file that was set in home"
  cp /home/mythtv/.mythtv/config.xml /root/config.xml
  cp /home/mythtv/.mythtv/config.xml /root/.mythtv/config.xml
  cp /home/mythtv/.mythtv/config.xml /usr/share/mythtv/config.xml
  cp /home/mythtv/.mythtv/config.xml /etc/mythtv/config.xml
else
  cat << EOF > /root/config.xml
<Configuration>
  <LocalHostName>MythTV-Server</LocalHostName>
  <Database>
    <PingHost>1</PingHost>
    <Host>${DATABASE_HOST}</Host>
    <UserName>${DATABASE_USER}</UserName>
    <Password>${DATABASE_PASS}</Password>
    <DatabaseName>mythconverg</DatabaseName>
    <Port>${DATABASE_PORT}</Port>
  </Database>
  <WakeOnLAN>
    <Enabled>0</Enabled>
    <SQLReconnectWaitTime>0</SQLReconnectWaitTime>
    <SQLConnectRetry>5</SQLConnectRetry>
    <Command>echo 'WOLsqlServerCommand not set'</Command>
  </WakeOnLAN>
</Configuration>
EOF
  mkdir -p /home/mythtv/.mythtv
  cp /root/config.xml /root/.mythtv/config.xml
  cp /root/config.xml /usr/share/mythtv/config.xml
  cp /root/config.xml /etc/mythtv/config.xml
  cp /root/config.xml /home/mythtv/.mythtv/config.xml
fi

echo "starting mythweb"
CMD /usr/sbin/apache2ctl -D FOREGROUND