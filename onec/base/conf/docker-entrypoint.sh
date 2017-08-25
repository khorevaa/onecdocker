#!/bin/bash
set -e

echo "$1"
#echo "$0"

if [ "$PRERUN_SLEEP" ]; then
    echo "sleep $PRERUN_SLEEP"
    sleep "$PRERUN_SLEEP"
fi

mkdir -p $RDATA/logs/{dumps,tsg,log}
if test -f /opt/1C/v8.3/x86_64/1cestart; then
	oneC_root=/opt/1C/v8.3/x86_64;
else
	oneC_root=/opt/1C/v8.3/i386;
fi

ONECUSER="${ONEC_RUN_USER:-usr1cv8}"
ONECGROUP="${ONEC_RUN_GROUP:-grp1cv8}"

function setTimezone {
    if [ "$TIMEZONE" ]; then 
        TZ="$TIMEZONE"
    else 
        TZ="Europe/Kiev"
    fi

    #https://github.com/sameersbn/docker-gitlab/issues/77#issuecomment-46346176
    if [ -n ${TZ} ] && [ -f /usr/share/zoneinfo/${TZ} ]; then
        ln -sf /usr/share/zoneinfo/${TZ}  /etc/localtime
    fi

    #echo "$timezone" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
    echo "set default timezone to $TZ"
}

function setUSBService {
    if [ "$AKSUBS_TCP_SERVICE" ]; then 
        cmd=`python /distr/getipbyhostname.py $AKSUBS_TCP_SERVICE`
        gosu socat UNIX-LISTEN:/tmp/.aksusb,reuseaddr,fork TCP4:"$cmd" </dev/null &
        echo "set usb key to $AKSUBS_TCP_SERVICE"

    fi
}

function setEncoding {
    onecencoding="${ONECENCODING:-RU}"
    # if [ "ONECENCODING" ]; then 
    #     onecencoding="$ONECENCODING"
    # else
    #     onecencoding="${ONECENCODING:-RU}"
    # fi
    echo "SystemLanguage=$onecencoding" | tee -a $oneC_root/conf/conf.cfg
    echo "set 1C encoding to $onecencoding"
}

function setPermissions {
    
    if test -f $RDATA/conf/logcfg.xml; then
        mkdir -p $oneC_root/conf
        cp -R $RDATA/conf/* $oneC_root/conf/
    else 
        mkdir -p $oneC_root/conf
        cp -R /distr/onecconf/* $oneC_root/conf/
    fi

    chown $ONECUSER:$ONECGROUP -v -R "$oneC_root/conf/"
    chmod -R o+r "$oneC_root/conf/"
    chmod -R g+r "$oneC_root/conf/"
    chmod -R g+w "$RDATA/logs/"
    chown $ONECUSER:$ONECGROUP -R "$RDATA/logs"
    mkdir -p $RDATA/cluster
    chown $ONECUSER:$ONECGROUP -R "$RDATA/cluster" 
}

setTimezone

if [ "$1" = 'ragent' ]; then
	setUSBService
    setPermissions
    setEncoding

    echo "run ragent"
    chown -R $ONECUSER "$RDATA"
    if [ "$SRV1CV8_PORT" ]; then 
            port="$SRV1CV8_PORT"
    else
            port="1540"
    fi

    if [ "$SRV1CV8_REGPORT" ]; then 
            rport="$SRV1CV8_REGPORT"
    else
            rport="1541"
    fi

    if [ "$SRV1CV8_RANGE" ]; then 
            range="$SRV1CV8_RANGE"
    else
            range="1560:1591"
    fi

    if [ "$SRV1CV8_SECLEV" ]; then 
            seclev="$SRV1CV8_SECLEV"
    else
            seclev="0"
    fi

    if [ "$SRV1CV8_DEBUG" ]; then
        if [ "$SRV1CV8DEBUG_PWD" ]; then 
                pwd="-debugServerPwd $SRV1CV8DEBUG_PWD"
        else
                pwd=
        fi 
        debug="-debug -http -debugServerAddr ${SRV1CV8DEBUG_ADDR:-0.0.0.0} -debugServerPort ${SRV1CV8DEBUG_PORT:-1550} ${pwd}"
        echo "gosu usr1cv8 $oneC_root/dbgs --daemon --addr=${SRV1CV8DEBUG_ADDR:-0.0.0.0} --port=${SRV1CV8DEBUG_PORT:-1550} --notify=/tmp/dbsg.txt $pwd"
        gosu $ONECUSER $oneC_root/dbgs --daemon --addr=${SRV1CV8DEBUG_ADDR:-0.0.0.0} --port=${SRV1CV8DEBUG_PORT:-1550} --notify=/tmp/dbsg.txt ${pwd}
        sleep 4
        #echo "test"
        #cat /tmp/dbsg.txt
    else
        debug=""
    fi

    if [ "$SRV1CV8RAS_PORT" ]; then 
            rasport="$SRV1CV8RAS_PORT"
    else
            rasport="1545"
    fi

    mkdir -p $RDATA/cluster
    echo "gosu $ONECUSER $oneC_root/ragent -port $port -regport $rport -range $range -d $RDATA/cluster -seclev $seclev $debug"
    #chown usr1cv8:1000 -v -R "$RDATA" 
    gosu $ONECUSER $oneC_root/ras cluster --port="$rasport" --daemon "localhost:${SRV1CV8_PORT:-1540}"
    ps aux | grep 1C
    exec gosu $ONECUSER $oneC_root/ragent -port "$port" -regport "$rport" -d "$RDATA/cluster" -range "$range" -seclev "$seclev" $debug

elif [ "$1" = 'cserver' ]; then
	setUSBService
    setPermissions
    setEncoding

    echo "is server repo run"
    
    APACHERUNUSER="${APACHE_RUN_USER:-www-data}"
    cp /distr/001-repo.conf /etc/apache2/sites-available/
    
    ln -s /etc/apache2/sites-available/001-repo.conf /etc/apache2/sites-enabled/
    
    mkdir -p /var/www/r
    cp /distr/repo.1ccr /var/www/r/repo.1ccr
    chown $APACHERUNUSER:www-data /var/www/r
    adduser $APACHERUNUSER $ONECGROUP
	
    /usr/sbin/apachectl -k start
    gosu usr1cv8 linux32 /opt/1C/v8.3/i386/crserver -d $REPODATA
elif [ "$1" = 'apache' ]; then
    
    setUSBService
    setPermissions
    setEncoding
    
    a2enmod headers
    sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' /etc/apache2/envvars
    
    APACHERUNUSER="${APACHE_RUN_USER:-www-data}"

    echo "is apache run "
    adduser $APACHERUNUSER $ONECGROUP
    
    python /distr/web/walk.py -p ${DESCRIPTORS} -r /etc/apache2/sites-enabled/ -o /var/www/ -d ${DESCRIPTORS}
    /usr/sbin/apachectl -k start
    watchmedo shell-command --patterns="*.vrd" --recursive --command='python /distr/web/render.py -p ${watch_src_path} -e ${watch_event_type} -r /etc/apache2/sites-enabled/ -o /var/www/ -d ${DESCRIPTORS} && apachectl -k graceful' ${DESCRIPTORS} 
    #gosu www-data /usr/sbin/apache2 -D FOREGROUND
elif [ "$1" = 'client' ]; then
    setUSBService
    setPermissions
    setEncoding

    echo "client"
    /distr/clientsupervisor.sh
elif [ "$1" = 'clientragent' ]; then
    exec /distr/docker-entrypoint.sh ragent
    /distr/clientsupervisor.sh

elif [ "$1" = 'clientX' ]; then
    echo "clientX"
elif [ "$1" = 'debug' ]; then 
    setUSBService
    setPermissions
    setEncoding

    if [ "$SRV1CV8DEBUG_PORT" ]; then 
            port="$SRV1CV8DEBUG_PORT"
    else
            port="1550"
    fi

    if [ "$SRV1CV8DEBUG_ADDR" ]; then 
        addr="$SRV1CV8DEBUG_ADDR"
    else 
        addr="0.0.0.0"
    fi


    if [ "$SRV1CV8DEBUG_PWD" ]; then 
            pwd="-pwd $SRV1CV8DEBUG_PWD"
    else
            pwd=""
    fi
    #/opt/1C/v8.3/i386/dbgs --daemon --addr=0.0.0.0 --port=1550 --notify=/tmp/llog.txt -pwd 
    echo "gosu $ONECGROUP $oneC_root/dbgs --addr=$addr --port=$port --notify=/tmp/dbsg.txt $pwd"
    exec gosu $ONECUSER $oneC_root/dbgs --addr="$addr" --port="$port" --notify=/tmp/dbsg.txt "$pwd"

else
    exec "$@"
fi
