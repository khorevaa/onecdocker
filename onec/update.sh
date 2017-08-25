#!/bin/bash
set -e
set -x 

cd "$(dirname "$BASH_SOURCE")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

function untar {
	tar xvf ./dist/$1/deb.tar.gz -C $2/
	tar xvf ./dist/$1/client.deb32.tar.gz -C $2/ 
}

for v in "${versions[@]}"; do
	if [ -f $v/Dockerfile ]; then 
		echo "dont copy"
	else
		mkdir $v
		cp -R ./base/* $v
	fi
	if [ -f ./dist/$v/deb.tar.gz ]; then 
		echo "/dist/$v/deb.tar.gz exist" 
	else
		mkdir ./dist/$v
		./download.sh $v ./dist/$v
		#untar $v $v/conf/distr/ 
	fi
done

proxyarg=""
[[ -n "$BUILDPROXY" ]] && proxyarg="--build-arg=HTTP_PROXY=$BUILDPROXY"


for v in "${versions[@]}"; do
	if [ ! -f "$v/Dockerfile" ]; then
		echo >&2 "warning: $v/Dockerfile does not exist; skipping $v"
		continue
	fi
	CID=$(docker run -d -v "$(pwd)"/dist/"$v"/:/usr/share/nginx/html:ro nginx:alpine)
	#docker ps 
	docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$CID"
	IPADDR=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$CID")
	#docker build \
    #	--build-arg WEBHOST="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$CID")" \

	( set -x; docker build ${proxyarg} --build-arg WEBHOST="$IPADDR" -f $v/Dockerfile -t "onec32/server:$v" "$v" )
	( set -x; docker build ${proxyarg} --build-arg WEBHOST="$IPADDR" -f $v/Dockerfile.client -t "onec32/client:$v" "$v" )
	echo "$CID"
	docker stop "$CID" && docker rm "$CID"
	sleep 2
	
done
