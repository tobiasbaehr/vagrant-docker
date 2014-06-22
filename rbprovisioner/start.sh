#!/usr/bin/env bash
#set -o errexit
#set -x

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

export RBHOME="/vagrant/rbprovisioner"
export DOCKERFILES="/vagrant/dockerfiles"

start_provisioner() {
  script="$RBHOME/provision.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}

prestart() {
  git > /dev/null 2>&1 || apt-get install -y git-core > /dev/null 2>&1
  script="$RBHOME/update.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}


main () {
  if [ -z "$1" ];then
    prestart
  else
    start_provisioner
  fi
}

main "$@"
