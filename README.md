This is a minimal docker-compose deployment capable of supporting
[aktualizr "lite" mode](https://github.com/advancedtelematic/aktualizr/issues/1056).
The motivation for this is twofold:

 * Its nice to have some simple to setup/teardown for testing
 * In some cases, this is all people need for their actual backend
   service

## Getting Started

~~~
# Step 0: create secret creds needed for all services
$ ./docker-compose-initialize.sh

# Step 1: start up the service
$ docker-compose up
or docker-compose -f docker-compose.yml -f uptane.yml up # for uptane support

# Step 2: wait for things to be "healthy" (about 1 minute):
# if you are running uptane then set UPTANE=1 when running:
$ ./docker-compose-health.sh

# Step 3: generate the TUF credentials
# if you are running uptane then set UPTANE=1 when running:
$ ./tufrepo-initialize.sh
$ ./creds-data/mk-credentials-zip   # creates credentials.zip

# Step 4: populate the ostree server with some data
$ ./populate-faux-data.sh

# Step 5: sign the hash in TUF
$ BUILD=XX OSTREE_HASH=XX HWID=XX ./tufrepo-add-build.sh
~~~

When you get sick of it or want to try from scratch run:
~~~
$ ./cleanup.sh
~~~
