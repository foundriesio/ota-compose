#!/bin/sh -e

this=$(readlink -f $0)
add_build="$(dirname $this)/tufrepo-add-build.sh"

[ -z "$PLATFORM" ] && (echo "Missing \$PLATFORM"; exit 1)
[ -z "$RELEASE" ] && (echo "Missing \$RELEASE"; exit 1)

data="${CREDS_DATA-$(dirname $this)/../creds-data}"

if ! which garage-push >/dev/null 2>&1; then
	echo "Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v$this:$this \
		-v$add_build:$add_build \
		-v $data:$data \
		-e PLATFORM=$PLATFORM \
		-e RELEASE=$RELEASE \
		-e CREDS_DATA=$data \
		hub.foundries.io/aktualizr $this
fi

echo "=$(date) Finding LMP build"
build=$(wget -O- https://api.foundries.io/updates/${RELEASE}/ | grep /products/lmp/ | cut -d/ -f4)
run="https://api.foundries.io/projects/lmp/builds/$build/runs/supported-$PLATFORM"
if [ "$PLATFORM" != "raspberrypi3-64" ] ; then
	run="https://api.foundries.io/projects/lmp/builds/$build/runs/other-$PLATFORM"
fi

echo "=$(date) Finding OSTREE sha of build $run"
sha=$(wget -O- ${run}/other/ostree.sha.txt)

echo "=$(date) Downloading $ostree with sha: $sha"
ostree=${run}/other/${PLATFORM}-ostree_repo.tar.bz2
wget -O /tmp/ostree.tar.bz2 $ostree
cd /tmp
tar -xf ostree.tar.bz2

echo "=$(date) Uploading OSTree to TreeHub"
garage-push --repo ostree_repo --credentials $data/credentials.zip \
	--ref $(ostree refs --repo ostree_repo)

BUILD=$RELEASE HWID=$PLATFORM OSTREE_HASH=$sha ${add_build}
