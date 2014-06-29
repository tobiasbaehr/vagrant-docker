#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

export VAGRANTDOCKER="/vagrant"
export RBLIB="${VAGRANTDOCKER}/rbprovisioner"
export DOCKERFILES="${VAGRANTDOCKER}/dockerfiles"
export PROJECTLIST="${VAGRANTDOCKER}/projects.txt"
export CRANEVERSION="v0.8.0"

start_provisioner() {
  script="$RBLIB/provision.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}

prestart() {
  git > /dev/null 2>&1 || apt-get install -y git-core > /dev/null 2>&1
  script="$RBLIB/update.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}


main () {
  local update=${1:-""}
  if [ -z "${update}" ];then
    prestart
  else
    start_provisioner
  fi
}

main "$@"
