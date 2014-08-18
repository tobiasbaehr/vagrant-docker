#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

if [[ -d $DOCKERFILES/public ]]  && [[ ! -d $DOCKERFILES/reinblau ]]; then
  mv $DOCKERFILES/public $DOCKERFILES/reinblau
fi

rmdir $DOCKERFILES/company 2> /dev/null
rmdir $DOCKERFILES/custom 2> /dev/null

rm $VAGRANTDOCKER/ssh_config.txt 2> /dev/null
