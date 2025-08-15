### INFO
The Docker Image for Non-Interactive Deploy the GLPI with Docker\Docker-Compose\Kubernetes. This image based on "webdevops/php-nginx:8.4-alpine"

### GitHub
https://github.com/IT-REVKO-LLC/glpi

### Quick start (persistent configuration)
##### Cretate folders for mariadb and glpi storage
```mkdir -p /mnt/docker/mariadb && mkdir -p /mnt/docker/glpi```
##### Clone repo and start containers via docker-compose
```git clone https://github.com/IT-REVKO-LLC/glpi && docker-compose up -d```

And then we can enter to GLPI by ```http://docker-host-ip```
### Environment variables
| Variable                  | Description                                          | Default     |
|---------------------------|------------------------------------------------------|-------------|
| WEB_DOCUMENT_ROOT         | Path to web root(needed by webdevops/php:8.4-alpine) | /app/public |
| DB_HOST                   | Hostname for DataBase                                | mariadb     |
| DB_PORT                   | Port number for DataBase                             | 3306        |
| DB_NAME                   | Name of DataBase                                     | glpidb      |
| DB_USER                   | Name of User for Database                            | glpiuser    |
| DB_PASSWORD               | Pass of user for DataBase                            | glpipass    |
| LDAP_TRUSTED_CERTIFICATES | Trusted TLS certificate of your AD\LDAP server       | none        |
| REDIS_HOST                | Hostname for Redis                                   | -           |
| REDIS_PORT                | Port number for Redis                                | -           |
| REDIS_PASS                | Password for connection to Redis                     | -           |
| REDIS_PASS                | Redis DB Number                                      | -           |
