#!/bin/sh -e

this=$(readlink -f $0)
data="${OSTREE_DATA-$(dirname $this)/ostree-data}"

[ -d $data ] || mkdir $data

if ! which garage-push >/dev/null 2>&1; then
	echo "Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v$this:$this \
		-v $data:$data \
		--workdir $data \
		-e OSTREE_DATA=$OSTREE_DATA \
		hub.foundries.io/aktualizr $this
fi

apk add --no-cache zip

if [ ! -f $data/credentials.zip ] ; then
	echo "=$(date) Creating TreeHub credentials"
	cat >treehub.json <<EOF
{
	"no_auth": true,
	"ostree": {
		"server": "http://treehub:9001/api/v3/"
	}
}
EOF
	zip credentials.zip treehub.json
	rm treehub.json
fi

echo "=$(date) Creating ostree under $data"
ostree --repo=$data/repo init --mode=archive-z2
mkdir $data/tree
echo "Hello world!" > $data/tree/hello.txt
ostree --repo=$data/repo commit --branch=foo $data/tree/
sha=$(ostree --repo=$data/repo rev-parse foo)

echo "=$(date) Uploading OSTree to TreeHub"
garage-push --repo $data/repo --credentials $data/credentials.zip --ref foo
