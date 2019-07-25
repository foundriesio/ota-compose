#!/bin/sh -e

here="$(dirname $(readlink -f $0))"
scripts="${here}/scripts"
CREDS_DATA="${CREDS_DATA-${here}/creds-data}"

[ -z "$RELEASE" ] && (echo "Missing initial data: \$RELEASE"; exit 1)
[ -z "$PLATFORM" ] && (echo "Missing initial data: \$PLATFORM"; exit 1)

${scripts}/docker-compose-initialize.sh

if [ -n "$UPTANE" ] ; then
	[ -z "$SERVER_NAME" ] && (echo "Missing initial data: \$SERVER_NAME"; exit 1)
	./scripts/device-registry-initialize.sh
	cat >$here/docker-compose.sh <<EOF
#!/bin/sh -e
exec docker-compose -p otacompose -f docker-compose.yml -f uptane.yml \$*
EOF
else
	cat >$here/docker-compose.sh <<EOF
#!/bin/sh -e
exec docker-compose -p otacompose -f docker-compose.yml \$*
EOF
fi
chmod +x ./docker-compose.sh

${here}/docker-compose.sh up -d

echo "= Waiting for OTA Connect to be ready, streaming logs while waiting"
./docker-compose.sh logs -f &
pid=$!
while true; do
	sleep 30s
	${scripts}/docker-compose-health.sh && break
done
kill $pid

echo "= Initializing TUF repo"
[ -d ${CREDS_DATA} ] || mkdir -p ${CREDS_DATA}
${scripts}/tufrepo-initialize.sh
${CREDS_DATA}/mk-credentials-zip

${scripts}/add-lmp-release.sh
