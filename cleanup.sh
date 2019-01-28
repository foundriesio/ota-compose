#!/bin/sh -ex

cd $(dirname $(readlink -f $0))

docker-compose down
docker volume rm ota-compose_notary-db
docker volume rm ota-compose_treehub-db
docker volume rm ota-compose_treehub-objects
