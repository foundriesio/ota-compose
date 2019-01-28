#!/bin/sh -e

[ -z "$BUILD" ] && (echo "Missing \$BUILD"; exit 1)
[ -z "$OSTREE_HASH" ] && (echo "Missing \$OSTREE_HASH"; exit 1)
[ -z "$HWID" ] && (echo "Missing \$HWID"; exit 1)

this=$(readlink -f $0)
data="${NOTARY_DATA-$(dirname $this)/notary-data}"
collection="${NOTARY_COLLECTION-hub.foundries.io/lmp}"

[ -d $data ] || (echo "$data does not exist"; exit 1)

if ! which garage-push >/dev/null 2>&1; then
	echo "Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v $this:$this \
		-v $(dirname $this)/notary/fixtures:/fixtures \
		-v $data:$data \
		--workdir $data \
		-e NOTARY_DATA=$data \
		-e NOTARY_COLLECTION=$collection \
		-e BUILD=$BUILD \
		-e OSTREE_HASH=$OSTREE_HASH \
		-e HWID=$HWID \
		hub.foundries.io/aktualizr $this
fi

cat >/tmp/custom.json <<EOF
{
	"hardwareIds": ["$HWID"],
	"targetFormat": "OSTREE",
	"version": "BUILD"
}
EOF
$data/notary -v -d $data/trust --tlscacert /fixtures/root-ca.crt -s https://notary-server \
	addhash hub.foundries.io/lmp $BUILD-$HWID 0 --sha256 $OSTREE_HASH \
	--custom /tmp/custom.json -p

