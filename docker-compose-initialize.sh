#!/bin/sh -e

here=$(dirname $(readlink -f $0))

echo "=$(date) Initalizing docker-compose secrets"

[ -f $here/.secrets ] && (echo "Secrets already defined at $here/.secrets"; exit 1)

cat >$here/.secrets <<EOF
# needed by mariadb container
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 16)

# needed by ota-ce containers
DB_MIGRATE=true
DB_USER=ota-ce
DB_PASSWORD=

# used by tuf-keyserver
DB_ENCRYPTION_SALT=$(openssl rand -base64 8)
DB_ENCRYPTION_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w64 | head -n1)
EOF
chmod 440 $here/.secrets
