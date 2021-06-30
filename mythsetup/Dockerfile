FROM bfg100k/mythtv:mythbackend

# Add files
COPY files /root/

ENV SSH_PORT=22

# install RDP environment 
RUN apt-get install -y --no-install-recommends openssh-server x11-utils xauth xterm && \
    sed -i -e "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config && \
	echo "mythtv:mythtv" | chpasswd && \
    chmod 700 /root/dockerentry.sh && \
# clean up
	apt-get clean && \
	rm -rf /tmp/* /var/tmp/* \
	/usr/share/man /usr/share/groff /usr/share/info \
	/usr/share/lintian /usr/share/linda /var/cache/man && \
	(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
	(( find /usr/share/doc -empty|xargs rmdir || true ))

EXPOSE $SSH_PORT

CMD ["/root/dockerentry.sh"]
