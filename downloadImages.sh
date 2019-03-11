#!/usr/bin/env bash

rm -rf assets
mkdir assets
cd assets
for id in {1..100}
do
    wget "https://picsum.photos/200/300?image=$id"
    mv "300?image=$id" "$id.png"
done
ll