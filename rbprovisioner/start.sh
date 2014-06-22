#!/usr/bin/env bash
#set -o errexit
set -x

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

export RBHOME="/vagrant/rbprovisioner"
if [ -z $DOCKERFILES ];then
  export DOCKERFILES="/vagrant/dockerfiles"
fi

verify_bash() {
  if [ -z "${BASH_SOURCE}" ];then
    echo "Do not run the script via sh. Use bash do to this." >&2
    exit 1
  fi
}

check_user() {
  # Check if we have root powers
  if [ `whoami` != root ]; then
      echo "Please run this script as root or using sudo" >&2
      exit 1
  fi
}

start_provisioner() {
  script="$RBHOME/provision.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}

main () {
  verify_bash
  check_user
  start_provisioner
  if [ -z ${1} ];then
    exec "${RBHOME}/update.sh"
    exit
  fi
}

main "$@"
