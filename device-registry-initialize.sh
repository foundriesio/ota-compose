#!/bin/sh -e

this=$(readlink -f $0)
data="${CREDS_DATA-$(dirname $this)/creds-data}"
keys=$data/server_keys

[ -d $keys ] && (echo "ERROR: Server keys already exist at $keys"; exit 1)

[ -z $SERVER_NAME ] && (echo "ERROR: SERVER_NAME must be set"; exit 1)

mkdir -p $keys
cd $keys

mkdir $keys/conf
cat >$keys/conf/client.cnf <<EOF
[req]
prompt = no
distinguished_name = dn
req_extensions = ext

[dn]
OU=default
CN=\$ENV::DEVICE_UUID

[ext]
keyUsage=critical, digitalSignature
extendedKeyUsage=critical, clientAuth
EOF

cat >$keys/conf/server_ca.cnf <<EOF
[req]
prompt = no
distinguished_name = dn
x509_extensions = ext

[dn]
CN = ota-server-CA

[ext]
basicConstraints=CA:TRUE
keyUsage = keyCertSign
extendedKeyUsage = critical, serverAuth
EOF

cat >$keys/conf/server.cnf <<EOF
[req]
prompt = no
distinguished_name = dn
req_extensions = ext

[dn]
CN=ota-gateway

[ext]
keyUsage=critical, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage=critical, serverAuth
subjectAltName=DNS:\$ENV::SERVER_NAME
EOF

cat >$keys/conf/server.ext <<EOF
keyUsage=critical, digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage=critical, serverAuth
subjectAltName=DNS:\$ENV::SERVER_NAME
EOF
cat >$keys/conf/client.ext <<EOF
keyUsage=critical, digitalSignature
extendedKeyUsage=critical, clientAuth
EOF

echo "=$(date) Creating server CA"
openssl ecparam -genkey -name prime256v1 | openssl ec -out ca.key
openssl req -new -x509 -days 3650 -config conf/server_ca.cnf -key ca.key -out server_ca.pem

echo "=$(date) Creating server Key"
openssl ecparam -genkey -name prime256v1 | openssl ec -out server.key
openssl req -new -key server.key -config conf/server.cnf -out server.csr
openssl x509 -req -days 3650 -in server.csr -CAcreateserial \
	-extfile conf/server.ext -CAkey ca.key -CA server_ca.pem -out server.crt
cat server.crt server_ca.pem > server.chain.pem
rm server.csr
chmod go+r server.key   # needed so nginx container can read the file

mkdir devices
cd devices
echo "=$(date) Creating devices CA"
openssl ecparam -genkey -name prime256v1 | openssl ec -out ca.key
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
