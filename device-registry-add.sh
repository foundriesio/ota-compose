#!/bin/sh -e

this=$(readlink -f $0)
data="${CREDS_DATA-$(dirname $this)/creds-data}"
keys=$data/server_keys

[ -d $keys ] || (echo "ERROR: Server keys don't exist. Please initialize first"; exit 1)

if [ -z "$INDOCKER" ] ; then
	cd $keys/devices

	export DEVICE_UUID=${DEVICE_UUID:-$(uuidgen | tr "[:upper:]" "[:lower:]")}
	export DEVICE_ID=${DEVICE_ID:-${DEVICE_UUID}}
	mkdir $DEVICE_UUID
	cd $DEVICE_UUID

	echo "=$(date) Creating device certs"
	openssl ecparam -genkey -name prime256v1 | openssl ec -out pkey.ec.pem
	openssl pkcs8 -topk8 -nocrypt -in pkey.ec.pem -out pkey.pem
	openssl req -new -config ../../conf/client.cnf -key pkey.pem -out device.csr
	openssl x509 -req -days 365 -in device.csr \
		-extfile ../../conf/client.ext -CAkey ../ca.key -CA ../ca.crt -CAcreateserial -out client.pem
	cat client.pem ../ca.crt > device.chain.pem
	ln -s ../../server_ca.pem root.crt
	openssl x509 -in client.pem -text -noout

	cat >device-registry-data.json <<EOF
	{
		"deviceUuid": "$DEVICE_UUID",
		"uuid": "$DEVICE_UUID",
		"deviceId": "$DEVICE_ID",
		"deviceName": "$DEVICE_ID",
		"deviceType": "Other",
		"credentials": "$(cat client.pem | awk 1 ORS='\\n')"
	}
EOF

	echo "Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v $this:$this \
		-v `pwd`:`pwd` \
		-e INDOCKER=1 \
		-w `pwd` \
		hub.foundries.io/aktualizr $this

fi

echo "=$(date) Installing prereqs"
apk add --no-cache curl jq zip | sed 's/^/|  /'
apk upgrade libcurl

echo "=$(date) Adding device to registry"
curl -v -X PUT \
	-H "Content-type: application/json" \
	-d @./device-registry-data.json \
	http://device-registry:9001/api/v1/devices
echo
echo "=$(date) Device creds located at `pwd`"
