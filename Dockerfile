FROM dheaps/mythbackend:mythbuntu

# Expose ports
EXPOSE 5000 6543 6544

# set volumes
VOLUME /var/lib/mythtv /var/lib/mythtv

# Add files
COPY files /root/

# install mythtv-backend and utilities
RUN apt-get install -y --no-install-recommends mythtv-backend mythtv-transcode-utils mythtv-status iputils-ping unzip xmltv hdhomerun-config && \
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

CMD ["/root/dockerentry.sh"]