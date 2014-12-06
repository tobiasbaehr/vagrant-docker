#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

if [[ -d /vagrant/.ssh/ ]] && [[ -z $SSHKEY ]];then
  printf "Move %s to %s\n" /vagrant/.ssh/ $SSHDIR
  mv /vagrant/.ssh/ $SSHDIR
fi
