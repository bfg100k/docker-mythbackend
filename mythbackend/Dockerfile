FROM bfg100k/mythtv:base

# Expose ports
EXPOSE 5000 6543 6544

# set volumes
VOLUME /var/lib/mythtv /var/log/mythtv

# Add files
COPY files /root/

# install mythtv-backend and utilities
RUN apt-get install -y --no-install-recommends mythtv-backend xmltv && \
# add tv_grab_file
wget ‐‐directory-prefix=/usr/bin https://raw.githubusercontent.com/b-jesch/tv_grab_file/master/tv_grab_file && \
chmod a+rx /usr/bin/tv_grab_file && \
# clean up
	apt-get clean && \
	rm -rf /tmp/* /var/tmp/* \
	/usr/share/man /usr/share/groff /usr/share/info \
	/usr/share/lintian /usr/share/linda /var/cache/man && \
	(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
	(( find /usr/share/doc -empty|xargs rmdir || true ))
	
# set mythtv to uid and gid
RUN usermod -u ${USER_ID} mythtv && \
	usermod -g ${GROUP_ID} mythtv && \
# create/place required files/folders
	mkdir -p /home/mythtv/.mythtv /var/lib/mythtv /var/log/mythtv /root/.mythtv && \
# set a password for user mythtv and add to required groups
	echo "mythtv:mythtv" | chpasswd && \
	usermod -s /bin/bash -d /home/mythtv -a -G users,mythtv mythtv && \
# set permissions for files/folders
	chown -R mythtv:users /var/lib/mythtv /var/log/mythtv

CMD ["/root/dockerentry.sh"]