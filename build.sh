#!/bin/bash
#BUILDPROXY=http://consul.service.lab.consul:3142 ./build.sh
#BUILDPROXY=http://192.168.1.25:3142 ./build.sh
set -x
proxyarg=""
[[ -n "$BUILDPROXY" ]] && proxyarg="--build-arg=HTTP_PROXY=$BUILDPROXY"

pushd postgres
docker build ${proxyarg} -t onec64/postgres:9.6 .
popd

pushd core-32bit
./update.sh xenial
popd

pushd base
./build.sh
popd

pushd onec
./update.sh 8.3.10.2466
#8.3.7.2027 8.3.8.2322 8.3.9.2170
popd

docker rmi -f $(docker images | grep "^<none>" | awk '{print $3}')

time docker save onec64/postgres:9.6 | lzma -z > onec64_postgres_9.6.tar.xz
#time docker save onec64/postgres:9.6 | gzip -c > onec64_postgres:9.6.tar.gz
#time docker save onec64/postgres:9.6 | xz --threads=0 > onec64_postgres:9.6.tar.gz0
#time docker save onec64/postgres:9.6 | xz --threads=2 > onec64_postgres:9.6.tar.gz2
time docker save onec32/server:8.3.10.2466 | lzma -z > onec32_server_8.3.10.2466.tar.xz
time docker save onec32/client:8.3.10.2466 | lzma -z > onec32_client_8.3.10.2466.tar.xz
