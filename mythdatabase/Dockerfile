FROM dheaps/mythbackend:latest

# Install mythtv-database
RUN apt-get install -y mythtv-database && \
# clean up
	apt-get clean && \
	/tmp/* /var/tmp/* \
	/usr/share/man /usr/share/groff /usr/share/info \
	/usr/share/lintian /usr/share/linda /var/cache/man && \
	(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
	(( find /usr/share/doc -empty|xargs rmdir || true ))

CMD ["/bin/bash"]