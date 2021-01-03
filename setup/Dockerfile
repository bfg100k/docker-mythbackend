FROM dheaps/mythbackend:latest

# Add files
COPY files /root/

EXPOSE 5900

ENV VNC_PASS=1234

# install RDP environment 
RUN apt-get install -y --no-install-recommends x11vnc xvfb supervisor && \
    mkdir ~/.vnc  && \
    echo /usr/bin/mythtv-setup >> ~/.bashrc && \
    chmod 700 /root/dockerentry.sh && \
#    apt-get install -y --no-install-recommends mate-desktop-environment && \
#	mv /root/xrdp.ini /etc/xrdp/xrdp.ini && \
# install HD Homerun Utilities
	apt-get install -y --no-install-recommends \
	hdhomerun-config hdhomerun-config-gui && \
# clean up
	apt-get clean && \
	rm -rf /tmp/* /var/tmp/* \
	/usr/share/man /usr/share/groff /usr/share/info \
	/usr/share/lintian /usr/share/linda /var/cache/man && \
	(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
	(( find /usr/share/doc -empty|xargs rmdir || true ))

CMD ["/root/dockerentry.sh"]
