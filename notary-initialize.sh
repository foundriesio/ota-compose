#!/bin/sh -e


this=$(readlink -f $0)
data="${NOTARY_DATA-$(dirname $this)/notary-data}"
collection="${NOTARY_COLLECTION-hub.foundries.io/lmp}"

[ -d $data ] || mkdir $data

if ! which garage-push >/dev/null 2>&1; then
	echo "=$(date) Generating root key compatible with aktualizr"
	# ed25519 is the only type supported by both Notary and aktualizr
	openssl genpkey -algorithm ed25519 -outform PEM -out $data/root-pkey -aes256

	echo "=$(date) Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v $this:$this \
		-v $(dirname $this)/notary/fixtures:/fixtures \
		-v $data:$data \
		--workdir $data \
		-e NOTARY_DATA=$data \
		-e NOTARY_COLLECTION=$collection \
		hub.foundries.io/aktualizr $this
fi

if [ ! -f $data/notary ] ; then
	echo "=$(date) Downloading the notary client"
	wget -O $data/notary https://github.com/theupdateframework/notary/releases/download/v0.6.1/notary-Linux-amd64
	chmod +x $data/notary
fi

$data/notary -v -d $data/trust --tlscacert /fixtures/root-ca.crt -s https://notary-server \
	--rootkey $data/root-pkey \
	init $collection
