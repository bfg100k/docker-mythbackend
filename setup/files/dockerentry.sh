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

# Create Mythtv users
echo "Update mythtv user ids and groups"
echo "USER_ID=$USER_ID"
echo "GROUP_ID=$GROUP_ID"

USERID=${USER_ID:-99}
GROUPID=${GROUP_ID:-100}

echo "USERID=$USERID"
echo "GROUPID=$GROUPID"
groupmod -g $GROUPID users
usermod -u $USERID mythtv
usermod -g $GROUPID mythtv
usermod -d /home/mythtv mythtv
usermod -a -G mythtv,users,adm,sudo mythtv
chown -R mythtv:mythtv /home/mythtv/

# set permissions for files/folders
chown -R mythtv:users /var/lib/mythtv /var/log/mythtv

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

# Prepare X
if [ -f "/home/mythtv/.Xauthority" ]; then
  echo ".Xauthority file appears to in place"
else
  touch /home/mythtv/.Xauthority
fi

if [ ! -f "/home/mythtv/Desktop/Kill-Mythtv-Backend.desktop" ]; then
  mkdir -p /home/mythtv/Desktop
  cp /root/Kill-Mythtv-Backend.desktop /home/mythtv/Desktop/Kill-Mythtv-Backend.desktop
else
  echo "kill switch is set"
fi

if [ ! -f "/home/mythtv/Desktop/hdhr.desktop" ]; then
  cp /usr/share/applications/hdhr.desktop /home/mythtv/Desktop/hdhr.desktop
else
  echo "Hdhomerun Config is set"
fi

if [ ! -f "/home/mythtv/Desktop/mythtv-setup.desktop" ]; then
  cp /root/mythtv-setup.desktop /home/mythtv/Desktop/mythtv-setup.desktop
else
  echo "setup desktop icon is set"
fi

# check folders
if [ -d "/var/lib/mythtv/banners" ]; then
  echo "mythtv folders appear to be set"
else
  mkdir -p /var/lib/mythtv/banners  /var/lib/mythtv/coverart  /var/lib/mythtv/db_backups  /var/lib/mythtv/fanart  /var/lib/mythtv/livetv  /var/lib/mythtv/recordings  /var/lib/mythtv/screenshots  /var/lib/mythtv/streaming  /var/lib/mythtv/trailers  /var/lib/mythtv/videos
fi

chown -R mythtv:users /var/lib/mythtv/banners  /var/lib/mythtv/coverart  /var/lib/mythtv/db_backups  /var/lib/mythtv/fanart  /var/lib/mythtv/livetv  /var/lib/mythtv/recordings  /var/lib/mythtv/screenshots  /var/lib/mythtv/streaming  /var/lib/mythtv/trailers  /var/lib/mythtv/videos

#Does the MythTV Database Exist?
if [ "xpwd" != "x$DATABASE_ROOT_PWD"]; then
	echo "Check if mythconverg database exists"
	output=$(mysql -s -N -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'mythconverg'" information_schema)
	echo "  Query result = ${output}"
	if [[ -z "${output}" ]]; then
	  echo "Creating database(s)."
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "CREATE DATABASE IF NOT EXISTS mythconverg"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "CREATE USER 'mythtv' IDENTIFIED BY 'mythtv'"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "GRANT ALL ON mythconverg.* TO 'mythtv' IDENTIFIED BY 'mythtv'"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "GRANT CREATE TEMPORARY TABLES ON mythconverg.* TO 'mythtv' IDENTIFIED BY 'mythtv'"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "ALTER DATABASE mythconverg DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
	else
	  echo "Database already exists"
	fi
fi

# Bring up RDP
mkdir -p /var/run/sshd
mkdir -p /root/.vnc

/usr/bin/supervisord -c /root/supervisor-files/rdp-supervisord.conf & >/dev/null 2>&1

#Bring up the backend
chown -R mythtv:users /var/log/mythtv

echo "Checking whether database(s) are ready"
until [ "$( mysqladmin -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u${DATABASE_USER} -p${DATABASE_PWD} status 2>&1 >/dev/null | grep -ci error:)" = "0" ]
do
echo "waiting....."
sleep 2s
done
echo "start backend"
exec su - mythtv -c /usr/bin/mythbackend --syslog local7