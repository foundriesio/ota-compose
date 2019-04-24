#!/bin/sh -ex

cd $(dirname $(readlink -f $0))

docker-compose -f docker-compose.yml -f uptane.yml down
docker volume rm ota-compose_ota-ce-db
docker volume rm ota-compose_treehub-objects
docker volume rm ota-compose_tuf-targets

rm -f .secrets
