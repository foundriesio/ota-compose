#!/bin/sh -e

## Try and determine if things are healthy

this=$(readlink -f $0)

if [ -z "$INDOCKER" ] ; then
	echo "Calling via docker with proper tooling"
	exec docker run -it --rm \
		--network ota-compose_default \
		-v$this:$this \
		-e INDOCKER=1 \
		-e OSTREE_DATA=$OSTREE_DATA \
		hub.foundries.io/aktualizr $this
fi

failed=0
function health() {
	echo "=$(date) Checking health of $1"
	status=$(wget -O- http://$1:9001/health)
	echo $status
	if ! echo $status | grep OK >/dev/null 2>&1 ; then
		failed=1
	fi
}

health treehub
health tuf-keyserver-daemon
health tuf-keyserver
health tuf-reposerver

exit $failed
