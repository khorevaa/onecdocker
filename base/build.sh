#!/bin/bash

set -eo pipefail

dir="$(dirname $0)"

echo "######################"
echo "#                    #"
echo "#  Build script for  #"
echo "#    baseimage onec  #"
echo "#                    #"
echo "######################"

proxyarg=""
[[ -n "$BUILDPROXY" ]] && proxyarg="--build-arg=HTTP_PROXY=$BUILDPROXY"

function rmi {
    image="$1"
    if [[ -z $image ]]; then
        echo "Error!"
        exit 1
    fi

    nb=$(docker images $image |wc -l)
    if [[ $nb -eq 2 ]]; then
        docker rmi --force $image
    fi
}

#popd core-32bit
#./update.sh xenial
#pushd

echo "############################"
echo "##                         #"
echo "##     base image i386     #"
echo "##                         #"
echo "############################"
echo ""

echo ""
echo "Removing old images... "

#rmi onec/32bit/baseimage:latest
#rmi onec/baseimage:latest

echo "Building baseimage i368"
docker build ${proxyarg} -f Dockerfile.i386 -t onec32/baseimage:latest .

echo "Building baseimage for client i386"
docker build ${proxyarg} -f Dockerfileclient.i386 -t onec32/baseclient:latest .

#--no-cache
echo "Building baseimage amd64"
#docker build -q -f Dockerfile.amd64 -t onec64/baseimage:latest .


echo ""
echo "Done!"
echo ""
echo ""