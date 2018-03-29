#poste.io:1.0.7 is based on ubuntu zesty (/etc/debian_verson = stretch/sid)
FROM analogic/poste.io:1.0.7

#disable clamav
RUN touch /etc/services.d/clamd/down
RUN sed -i'' 's/^virus\/clamdscan/#virus\/clamdscan/' /etc/qpsmtpd/plugins
RUN rm /etc/logrotate.d/clamav-daemon
RUN rm /etc/cron.hourly/freshclam

#disable POP3
RUN echo 'protocols = $protocols' > /usr/share/dovecot/protocols.d/pop3d.protocol

#increase file size for spamassassin from 500K to 5M
RUN sed -i 's/500_000/5_000_000/g' /opt/qpsmtpd/plugins/spamassassin

#daily update bayes database
COPY sa-learn.sh /opt/sa-learn/sa-learn.sh
COPY sa-learn-cron /etc/cron.daily/sa-learn-cron

#increase scores of bayes_99 and _999 filter, adapt X-Spam headers
COPY local.cf /etc/spamassassin/local.cf

#symlink nano
RUN ln -s /bin/nano /bin/vi
