#!/bin/sh -e

cd /opt/treehub/lib
cp=$(echo $(ls /opt/treehub/lib/ ) | tr ' ', ':')

java -cp $cp com.advancedtelematic.treehub.Boot
