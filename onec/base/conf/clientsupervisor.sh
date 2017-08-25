#!/bin/bash

mkdir -p /var/run/sshd
mkdir -p /opt/serverdata/logs/{dumps,tsg}

# create an ubuntu user
# PASS=`pwgen -c -n -1 10`
PASS=ubuntu
# echo "Username: ubuntu Password: $PASS"
id -u ubuntu &>/dev/null || useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
echo "ubuntu:$PASS" | chpasswd
sed -i 's/^.sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
adduser ubuntu sudo
adduser www-data grp1cv8
adduser ubuntu grp1cv8


gosu ubuntu mkdir -p /home/ubuntu/.vnc
gosu ubuntu mkdir -p /home/ubuntu/.fluxbox

if test -f /home/ubuntu/.1cv8/1C/1cv8/1cv8cmn.pfl; then
    echo "1c.pfl found, skip"
else 
    echo "mkdir /home/ubuntu/.1cv8/1C/1cv8/"
    mkdir -p /home/ubuntu/.1cv8/1C/1cv8/
    #ls /home/ubuntu/.1cv8
    echo "cp /distr/1cv8pfl/*.pfl /home/ubuntu/.1cv8/1C/1cv8/"
    cp /distr/1cv8pfl/1cv8cmn.pfl /home/ubuntu/.1cv8/1C/1cv8/
    cp /distr/1cv8pfl/*.pfl /home/ubuntu/.1cv8/1C/1cv8/
    chown -R ubuntu /home/ubuntu/.1cv8/
fi

if test -f /home/ubuntu/.1C/1cestart/ibases.v8i; then
    echo "ibases found, skip"
else 
    mkdir -p /home/ubuntu/.1C/1cestart/
    #ls /home/ubuntu/.1cv8
    cp /distr/1cestart/1cestart.cfg /home/ubuntu/.1C/1cestart/1cestart.cfg
    cp /distr/1cestart/ibases.v8i /home/ubuntu/.1C/1cestart/ibases.v8i
    chown -R ubuntu /home/ubuntu/.1C/
fi


if test -f /home/ubuntu/.fluxbox/menu; then
    echo ""
else 
    echo "cp fluxbox 1C menu"
    cp /distr/fluxbox/menu /home/ubuntu/.fluxbox/menu
    chown -R ubuntu /home/ubuntu/.fluxbox/menu
fi

# if [ "$AKSUBS_TCP_SERVICE" ]; then 
#   rm -fr /etc/supervisor/conf.d/supervisor-socat.conf
#   cmd=`python /distr/getipbyhostname.py $AKSUBS_TCP_SERVICE`
#   cmdsocat="socat UNIX-LISTEN:/tmp/.aksusb,reuseaddr,fork TCP4:$cmd"
#   echo $cmdsocat
#   cat <<EOF >> /etc/supervisor/conf.d/supervisor-socat.conf
# [program:AKSUBS_TCP]
# command=$cmdsocat
# numprocs=1
# autostart=true
# autorestart=true
# EOF

# fi

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
