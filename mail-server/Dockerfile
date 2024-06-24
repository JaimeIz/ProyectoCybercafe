FROM ghcr.io/docker-mailserver/docker-mailserver:latest

ENV ADMIN_MAIL_USER=${MAIL_USER:-admin@example.com}
ENV ADMIN_MAIL_PASS=${MAIL_PASS:-changeme}

# RUN mkdir -p /tmp/docker-mailserver \
#     touch /tmp/docker-mailserver/postfix-accounts.cf \
#     echo "${MAIL_USER}|$(doveadm pw -s SHA512-CRYPT -u ${MAIL_USER} -p ${MAIL_PASS})" >>docker-data/dms/config/postfix-accounts.cf