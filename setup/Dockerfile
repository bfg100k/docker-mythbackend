FROM dheaps/mythbackend:latest

# Add files
COPY files /root/

# install xrdp
RUN apt-get install \
	xrdp -y && \
	mv /root/xrdp.ini /etc/xrdp/xrdp.ini && \
# clean up
	apt-get clean && \
	/tmp/* /var/tmp/* \
	/usr/share/man /usr/share/groff /usr/share/info \
	/usr/share/lintian /usr/share/linda /var/cache/man && \
	(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
	(( find /usr/share/doc -empty|xargs rmdir || true ))

CMD ["/root/dockerentry.sh"]