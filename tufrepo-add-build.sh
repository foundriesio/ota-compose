#!/bin/sh -e

[ -z "$BUILD" ] && (echo "Missing \$BUILD"; exit 1)
[ -z "$OSTREE_HASH" ] && (echo "Missing \$OSTREE_HASH"; exit 1)
[ -z "$HWID" ] && (echo "Missing \$HWID"; exit 1)

this=$(readlink -f $0)
data="${CREDS_DATA-$(dirname $this)/creds-data}"

[ -d $data ] || (echo "$data does not exist"; exit 1)

if ! which garage-push >/dev/null 2>&1; then
	echo "Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v $this:$this \
		-v $data:$data \
		--workdir $data \
		-e CREDS_DATA=$data \
		-e BUILD=$BUILD \
		-e OSTREE_HASH=$OSTREE_HASH \
		-e HWID=$HWID \
		hub.foundries.io/aktualizr $this
fi

tufrepo=$(mktemp -u -d)
otarepo=$(mktemp -u -d)

echo "=$(date) Initializing local TUF repository"
garage-sign init --repo ${tufrepo} --home-dir ${otarepo} --credentials $CREDS_DATA/credentials.zip

echo "=$(date) Pulling TUF targets from the remote TUF repository"
garage-sign targets pull --repo ${tufrepo} --home-dir ${otarepo}

echo "=$(date) Adding OSTree target to the local TUF repository"
garage-sign targets add --repo ${tufrepo} --home-dir ${otarepo} --name $BUILD-$HWID \
	--format OSTREE --version $BUILD --length 0  \
	--sha256 $OSTREE_HASH --hardwareids $HWID

echo "=$(date) Signing local TUF targets"
garage-sign targets sign --repo ${tufrepo} --home-dir ${otarepo} --key-name targets

echo "=$(date) Publishing local TUF targets to the remote TUF repository"
garage-sign targets push --repo ${tufrepo} --home-dir ${otarepo}

echo "=$(date) Verifying remote OSTree + TUF repositories"
garage-check --ref $OSTREE_HASH --credentials $CREDS_DATA/credentials.zip || /bin/bash
