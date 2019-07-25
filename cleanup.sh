#!/bin/sh -ex

cd $(dirname $(readlink -f $0))

docker-compose -p otacompose -f docker-compose.yml -f uptane.yml down
rm -rf data/* creds-data
rm -f .secrets
