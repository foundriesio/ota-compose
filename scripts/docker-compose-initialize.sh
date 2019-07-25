#!/bin/sh -e

secrets="$(dirname $(readlink -f $0))/../.secrets"

echo "=$(date) Initalizing docker-compose secrets"

[ -f $secrets ] && (echo "Secrets already defined at $secrets"; exit 1)

cat >$secrets <<EOF
# needed by mariadb container
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 16)

# needed by ota-ce containers
DB_MIGRATE=true
DB_USER=ota-ce
DB_PASSWORD=

# used by tuf-keyserver
DB_ENCRYPTION_SALT=$(openssl rand -base64 8)
DB_ENCRYPTION_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w64 | head -n1)

# used by web ui if enabled
JWT_SECRET=$(openssl rand -base64 32)
PLAY_CRYPTO_SECRET=$(openssl rand -base64 32)
EOF
chmod 440 $secrets
