FOLDER_WEB=/app

# Extracting glpi
tar zxf /glpi.tgz -C ${FOLDER_WEB} --strip-components=1 --skip-old-files && chown 1000:1000 -R ${FOLDER_WEB}

# Removing install.php because of not needed
rm -rf ${FOLDER_WEB}/install/install.php

# Adding php settings
echo "session.cookie_httponly = On" >> /opt/docker/etc/php/php.webdevops.ini
sed -i '1d' /opt/docker/etc/nginx/vhost.common.d/10-php.conf
sed -i '1 i\location ~ ^/index\.php$ {' /opt/docker/etc/nginx/vhost.common.d/10-php.conf

if [[ -z "$REDIS_HOST" || -z "$REDIS_PORT" || -z "$REDIS_PASS" || -z "$REDIS_DB" ]]; then echo "REDIS isn't used or settings were set incorrect";
else
    REDIS_IS_USED=true
    echo "session.save_handler = redis" >> /opt/docker/etc/php/php.webdevops.ini
    echo "session.save_path = \"tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASS}&database=${REDIS_DB}\"" >> /opt/docker/etc/php/php.webdevops.ini
    echo "REDIS settings for PHP session is successfully updated.";
fi

#Add trusted certificates to "ldap-truststore"
if [ "$LDAP_TRUSTED_CERTIFICATES" != 'none' ]; then
    echo "Adding certificates to truststore..."
    echo "TLS_CACERT /etc/openldap/my-certificates/extra.pem" >> /etc/openldap/ldap.conf
    mkdir /etc/openldap/my-certificates
    echo "$LDAP_TRUSTED_CERTIFICATES" | base64 -d >> /etc/openldap/my-certificates/extra.pem
fi


# Check that the database is available
echo "Waiting for database to be ready..."
while ! nc -w 1 $DB_HOST $DB_PORT; do
    # Show some progress
    echo -n '.';
    sleep 1;
done
echo -e "\n\nGreat, "$DB_HOST" is ready!"
# Give it another 3 seconds.
sleep 3;


#Checking for other containers starting
echo "Waiting for other containers starting..."
while [ -f "${FOLDER_WEB}/files/glpi_is_starting" ]; do
    echo '.';
    sleep 1;
done
echo -e "\nGreat, the current container is ready to start!\n";
touch ${FOLDER_WEB}/files/glpi_is_starting

# Installation
if [ "${REDIS_IS_USED}" == "true" ]; then
    cd ${FOLDER_WEB} && php bin/console glpi:cache:configure --dsn=redis://${REDIS_PASS}@${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB} --no-interaction --allow-superuser
fi

#Checking for GLPI is installed and update\check DB if needed
if [ -f "${FOLDER_WEB}/files/glpi_is_installed" ]; then
    echo "GLPI is already installed."
    cd ${FOLDER_WEB} && php bin/console db:configure --db-host=${DB_HOST} --db-port=${DB_PORT} --db-name=${DB_NAME} --db-user=${DB_USER} --db-password=${DB_PASSWORD} --no-interaction --allow-superuser
    cp ${FOLDER_WEB}/files/glpicrypt.key ${FOLDER_WEB}${FOLDER_GLPI}/config/glpicrypt.key
    if [ "$(php bin/console db:check_schema_integrity --check-all-migrations --allow-superuser | grep OK.)" ]; then
        echo "Database schema is OK."
        php bin/console glpi:maintenance:enable --allow-superuser
        php bin/console db:update --no-interaction --skip-db-checks --allow-superuser
        if [ "$(php bin/console db:check_schema_integrity --check-all-migrations --allow-superuser | grep OK.)" ]; then
            php bin/console glpi:maintenance:disable --allow-superuser
            echo "DB is ready."
        else
            php bin/console glpi:maintenance:disable --allow-superuser
            rm -rf ${FOLDER_WEB}/files/glpi_is_starting
            echo "DB is corrupted. Please check and fix DB, run it in glpi-webroot directory: php bin/console db:check_schema_integrity --check-all-migrations"
            exit 1
        fi
    fi
else
    cd ${FOLDER_WEB} && php bin/console db:install --db-host=${DB_HOST} --db-port=${DB_PORT} --db-name=${DB_NAME} --db-user=${DB_USER} --db-password=${DB_PASSWORD} --no-interaction --allow-superuser
    touch ${FOLDER_WEB}/files/glpi_is_installed
    cp ${FOLDER_WEB}/config/glpicrypt.key ${FOLDER_WEB}/files/glpicrypt.key

    echo "GLPI is successfully installed."
fi

#Remove lock file
rm -rf ${FOLDER_WEB}/files/glpi_is_starting
