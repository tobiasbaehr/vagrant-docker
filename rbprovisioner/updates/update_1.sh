#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

if [[ -d $DOCKERFILES/public ]]  && [[ ! -d $DOCKERFILES/reinblau ]]; then
  mv $DOCKERFILES/public $DOCKERFILES/reinblau
fi

rm $VAGRANTDOCKER/ssh_config.txt 2> /dev/null
