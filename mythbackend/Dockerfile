FROM ubuntu:latest
# updated from an0t8/mythtv-server

# Set correct environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME="/root"
ENV TERM=xterm
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# These should be set at runtime.
ENV USER_ID=99
ENV GROUP_ID=100
ENV DATABASE_HOST=mysql
ENV DATABASE_PORT=3306
ENV DATABASE_ROOT=root
ENV DATABASE_ROOT_PWD=pwd
ENV DATABASE_USER=mythtv
ENV DATABASE_PWD=mythtv

# Expose ports
# Don't directly expose ports, leave that to config
# EXPOSE 5000 6543 6544

# set volumes
VOLUME /home/mythtv /var/lib/mythtv/db_backups

# Add files
COPY files /root/

# add repositories
RUN apt-get update -qq && \
	apt-get install -y locales && \
# chfn workaround - Known issue within Dockers
	ln -s -f /bin/true /usr/bin/chfn && \
# set the locale
	locale-gen en_US.UTF-8 && \
# prepare apt 
	apt-get install -y software-properties-common --no-install-recommends && \
	apt-add-repository ppa:mythbuntu/0.29 -y && \
	apt-get update -qq && \
# install mythtv-backend and utilities
	apt-get install -y --no-install-recommends mythtv-backend mythtv-transcode-utils mythtv-status iputils-ping unzip xmltv hdhomerun-config && \
# install mythnuv2mkv
	apt-get install -y perl mplayer mencoder wget imagemagick \
	libmp3lame0 x264 faac faad mkvtoolnix vorbis-tools gpac && \
	mv /root/mythnuv2mkv.sh /usr/bin/ && \
	chmod +x /usr/bin/mythnuv2mkv.sh && \
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