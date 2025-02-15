FROM webdevops/php-nginx:8.2-alpine

ENV WEB_DOCUMENT_ROOT=/app/public \
    DB_HOST=mariadb \
    DB_PORT=3306 \
    DB_NAME=glpidb \
    DB_USER=glpiuser \
    DB_PASSWORD=glpipass \
    LDAP_TRUSTED_CERTIFICATES=none \
    REDIS_HOST=${REDIS_HOST} \
    REDIS_PORT=${REDIS_PORT} \
    REDIS_PASS=${REDIS_PASS} \
    REDIS_DB=${REDIS_DB}

RUN wget -O /glpi.tgz https://github.com/glpi-project/glpi/releases/download/10.0.18/glpi-10.0.18.tgz

COPY init.sh /opt/docker/
RUN chmod +x /opt/docker/init.sh
CMD /opt/docker/init.sh ; /opt/docker/bin/service.d/supervisor.sh
