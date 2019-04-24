This is a minimal docker-compose deployment capable of supporting
[aktualizr "lite" mode](https://github.com/advancedtelematic/aktualizr/issues/1056).
The motivation for this is twofold:

 * Its nice to have some simple to setup/teardown for testing
 * In some cases, this is all people need for their actual backend
   service

## Getting Started

~~~
# For a TUF only deployment:
$ RELEASE=43 PLATFORM=intel-corei7-64 ./provision

# Deployment with full Uptane
$ RELEASE=43 PLATFORM=intel-corei7-64 SERVER_NAME=<ota-ce.example.com> UPTANE=1 ./provision.sh

~~~

When you get sick of it or want to try from scratch run:
~~~
$ ./cleanup.sh
~~~
