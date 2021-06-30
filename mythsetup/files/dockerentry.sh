#!/bin/bash

# Set timezone
echo "Set correct timezone"
echo "TZ = $TZ"
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "Update timezone"
  echo $TZ > /etc/timezone && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
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
mkdir -p /home/mythtv/.mythtv
if [ -f "/var/lib/mythtv/.mythtv/config.xml" ]; then
  echo "Copying config file that was set in home"
  cp /var/lib/mythtv/.mythtv/config.xml /home/mythtv/.mythtv/config.xml
else
  echo "Setting config from environment variables"
  cat << EOF > /home/mythtv/.mythtv/config.xml
<Configuration>
  <Database>
    <PingHost>1</PingHost>
    <Host>${DATABASE_HOST}</Host>
    <UserName>${DATABASE_USER}</UserName>
    <Password>${DATABASE_PWD}</Password>
    <DatabaseName>${DATABASE_NAME}</DatabaseName>
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
fi
cp /home/mythtv/.mythtv/config.xml /usr/share/mythtv/config.xml
cp /home/mythtv/.mythtv/config.xml /etc/mythtv/config.xml

for f in /var/lib/mythtv/.mythtv/*.xmltv; do
    [ -e "$f" ] && echo "Copying XMLTV config file that was set in home" && 
    cp /var/lib/mythtv/.mythtv/*.xmltv /home/mythtv/.mythtv/
    break
done

# Prepare X
if [ -f "/home/mythtv/.Xauthority" ]; then
  echo ".Xauthority file appears to in place"
else
  touch /home/mythtv/.Xauthority
  chown mythtv /home/mythtv/.Xauthority
fi

# check folders
if [ -d "/var/lib/mythtv/banners" ]; then
  echo "mythtv folders appear to be set"
else
  mkdir -p /var/lib/mythtv/banners /var/lib/mythtv/channels /var/lib/mythtv/coverart  /var/lib/mythtv/db_backups  /var/lib/mythtv/fanart  /var/lib/mythtv/livetv  /var/lib/mythtv/recordings  /var/lib/mythtv/screenshots  /var/lib/mythtv/streaming  /var/lib/mythtv/trailers  /var/lib/mythtv/videos
fi

chown -R mythtv:users /var/lib/mythtv/banners /var/lib/mythtv/channels /var/lib/mythtv/coverart  /var/lib/mythtv/db_backups  /var/lib/mythtv/fanart  /var/lib/mythtv/livetv  /var/lib/mythtv/recordings  /var/lib/mythtv/screenshots  /var/lib/mythtv/streaming  /var/lib/mythtv/trailers  /var/lib/mythtv/videos

#persist the channel icons in the external volume
su mythtv -c "ln -s /var/lib/mythtv/channels/ /home/mythtv/.mythtv/"


#Does the MythTV Database Exist?
if [ "xpwd" != "x$DATABASE_ROOT_PWD" ]; then
	echo "Check if mythconverg database exists"
	output=$(mysql -s -N -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${DATABASE_NAME}'" information_schema)
	echo "  Query result = ${output}"
	if [[ -z "${output}" ]]; then
	  echo "Creating database(s)."
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME}"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "CREATE USER '${DATABASE_USER}' IDENTIFIED BY '${DATABASE_PWD}'"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "GRANT ALL ON ${DATABASE_NAME}.* TO '${DATABASE_USER}' IDENTIFIED BY '${DATABASE_PWD}'"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "GRANT CREATE TEMPORARY TABLES ON ${DATABASE_NAME}.* TO '${DATABASE_USER}' IDENTIFIED BY '${DATABASE_PWD}'"
	  mysql -h ${DATABASE_HOST} -P ${DATABASE_PORT} -u ${DATABASE_ROOT} -p${DATABASE_ROOT_PWD} -e "ALTER DATABASE ${DATABASE_NAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"
	else
	  echo "Database already exists"
	fi
fi

#Set up ssh
if [ ! -f /etc/ssh/.keys_generated ] && \
     ! grep -q '^[[:space:]]*HostKey[[:space:]]' /etc/ssh/sshd_config; then
  rm /etc/ssh/ssh_host*
  ssh-keygen -A
  touch /etc/ssh/.keys_generated
fi
mkdir -p /var/run/sshd

wait $APP_PID
exit 0