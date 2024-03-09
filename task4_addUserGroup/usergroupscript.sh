#!/bin/bash

sudo adduser sameh
sudo groupadd hussien
sudo usermod -aG hussien sameh
if [ $(getent passwd sameh) -a $(getent group hussien) ];then
sudo cat /etc/passwd | grep sameh 
sudo cat /etc/group | grep hussien
fi

