#!/usr/bin/env bash
set -o errexit
#set -x
set -o nounset

if [ ! -L /data/user/.ssh ] && [ -d /data/user/.ssh ];then
  if [ -f /data/user/.ssh/authorized_keys ];then
    cat /data/user/.ssh/authorized_keys >> /home/vagrant/.ssh/authorized_keys
    rm /data/user/.ssh/authorized_keys
  fi
  mv /data/user/.ssh/* /home/vagrant/.ssh/
  rmdir /data/user/.ssh/
  ln -s /home/vagrant/.ssh/ /data/user/.ssh
fi
