#!/bin/bash
#set -x

if [ -z "$V8USER" ]
then
    echo "USERNAME not set"
    exit 1
fi

if [ -z "$V8PASSW" ]
then
    echo "PASSWORD not set"
    exit 1
fi

V8VERSION="$1"
DOWNLOADIR="$2"
RPM="$3"

if [ -z "$V8VERSION" ]
then
    echo "VERSION not set"
    exit 1
fi

SRC=$(curl -c /tmp/cookies.txt -s -L https://releases.1c.ru)
ACTION=$(echo "$SRC" | grep -oP '(?<=form id="loginForm" action=")[^"]+(?=")') 
LT=$(echo "$SRC" | grep -oP '(?<=input type="hidden" name="lt" value=")[^"]+(?=")')
EXECUTION=$(echo "$SRC" | grep -oP '(?<=input type="hidden" name="execution" value=")[^"]+(?=")')

curl -s -L \
    -o /dev/null \
    -b /tmp/cookies.txt \
    -c /tmp/cookies.txt \
    --data-urlencode "inviteCode=" \
    --data-urlencode "lt=$LT" \
    --data-urlencode "execution=$EXECUTION" \
    --data-urlencode "_eventId=submit" \
    --data-urlencode "username=$V8USER" \
    --data-urlencode "password=$V8PASSW" \
    https://login.1c.ru"$ACTION"

if ! grep -q "onec_security" /tmp/cookies.txt
then
    echo "Auth failed"
    exit 1
fi

texttodownload="Скачать дистрибутив"
texttodownload="Завантажити дистрибутив"


echo curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$V8VERSION" \
    --data-urlencode "path=Platform\\${V8VERSION//./_}\\client.deb32.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Завантажити дистрибутив)'


CLIENTLINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$V8VERSION" \
    --data-urlencode "path=Platform\\${V8VERSION//./_}\\client.deb32.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Завантажити дистрибутив)')
echo $CLIENTLINK

SERVERINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$V8VERSION" \
    --data-urlencode "path=Platform\\${V8VERSION//./_}\\deb.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Завантажити дистрибутив)')    

mkdir -p $DOWNLOADIR

#curl --fail -b /tmp/cookies.txt -o $DOWNLOADIR./client.deb32.tar.gz -L "$CLIENTLINK"
#curl --fail -b /tmp/cookies.txt -o $DOWNLOADIR./client.deb32.tar.gz -L "$CLIENTLINK"

#curl --fail -b /tmp/cookies.txt -o $DOWNLOADIR./deb.tar.gz -L "$SERVERINK"
#curl -C --fail -b /tmp/cookies.txt -o $DOWNLOADIR./deb.tar.gz -L "$SERVERINK"

wget --continue --load-cookies /tmp/cookies.txt -O $DOWNLOADIR/deb.tar.gz "$SERVERINK"
wget --continue --load-cookies /tmp/cookies.txt -O $DOWNLOADIR/client.deb32.tar.gz "$CLIENTLINK"

if [ -z "$RPM" ]

CLIENTLINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$V8VERSION" \
    --data-urlencode "path=Platform\\${V8VERSION//./_}\\client.rpm64.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Завантажити дистрибутив)')

SERVERINK=$(curl -s -G \
    -b /tmp/cookies.txt \
    --data-urlencode "nick=Platform83" \
    --data-urlencode "ver=$V8VERSION" \
    --data-urlencode "path=Platform\\${V8VERSION//./_}\\rpm64.tar.gz" \
    https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Завантажити дистрибутив)')    


    wget --continue --load-cookies /tmp/cookies.txt -O $DOWNLOADIR/rpm64.tar.gz "$SERVERINK"
    wget --continue --load-cookies /tmp/cookies.txt -O $DOWNLOADIR/client.rpm64.tar.gz "$CLIENTLINK"

then
    echo ""
    #exit 1
fi
 

# if [ -f $DOWNLOADIR/client.deb32.tar.gz ]; then
#     #tar xvf $DOWNLOADIR./client.deb32.tar.gz -C $DOWNLOADIR/
#     #rm $DOWNLOADIR./client.deb32.tar.gz
# fi 

# if [ -f $DOWNLOADIR/deb.tar.gz ]; then
#     #tar xvf $DOWNLOADIR./deb.tar.gz -C $DOWNLOADIR/
#     #rm $DOWNLOADIR./deb.tar.gz
# fi 

rm /tmp/cookies.txt