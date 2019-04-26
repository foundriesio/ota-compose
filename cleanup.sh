#!/bin/sh -ex

cd $(dirname $(readlink -f $0))

docker-compose -p otacompose -f docker-compose.yml -f uptane.yml down
docker volume rm otacompose_ota-ce-db
docker volume rm otacompose_treehub-objects
docker volume rm otacompose_tuf-targets

rm -f .secrets
