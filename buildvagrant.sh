#!/bin/bash

vagrant up
vagrant ssh -c "cd /vagrant && chmod +x ./build.sh && ./build.sh"
vagrant ssh -c "docker rmi -f onec/32bit/baseclient:latest"
vagrant ssh -c "docker rmi -f onec/32bit/baseimage:latest"
#vagrant ssh -c "docker rmi -f onec/32bit/baseimage:latest"
vagrant ssh -c "docker rmi -f ubuntu32:latest"
vagrant halt

VAGRANT_VAGRANTFILE=Vagrantfile.prod  vagrant up
#VAGRANT_VAGRANTFILE=Vagrantfile.prod  vagrant package --base "ubuntu1604" --output onecubuntu1604
VAGRANT_VAGRANTFILE=Vagrantfile.prod  vagrant package --output ./package1.box
vagrant box add --name "onecbase" --force ./package1.box