This is a minimal docker-compose deployment capable of supporting
[aktualizr "lite" mode](https://github.com/advancedtelematic/aktualizr/issues/1056).
The motivation for this is twofold:

 * Its nice to have some simple to setup/teardown for testing
 * In some cases, this is all people need for their actual backend
   service

## Getting Started

~~~
# Step 1: start up the service
$ docker-compose up

# Step 2: populate the ostree server with some data
$ ./populate-faux-data.sh

# Step 3: sign the hash in TUF
$ BUILD=XX OSTREE_HASH=XX HWID=XX ./notary-add-build.sh
~~~
