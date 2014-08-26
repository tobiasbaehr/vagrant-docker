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
export BLACKLIST="${VAGRANTDOCKER}/blacklist.txt"
export SSHDIR="${VAGRANTDOCKER}/.ssh/"
export CRANEVERSION="0.8.1"
export DATADIR="/data"
export YADDPROJECTS="${DATADIR}/user/yaddprojects"
export DOTDRUSH="${DATADIR}/user/.drush"
export SSHKEY=${SSHKEY:-""}

if [[ -f $SSHDIR/id_rsa ]];then
  export SSHKEY=$SSHDIR/id_rsa
elif [[ -f $SSHDIR/id_rsa-cert ]];then
  export SSHKEY=$SSHDIR/id_rsa-cert
elif [[ -f $SSHDIR/id_dsa ]];then
  export SSHKEY=$SSHDIR/id_dsa
elif [[ -f $SSHDIR/id_dsa-cert ]];then
  export SSHKEY=$SSHDIR/id_dsa-cert
fi

start_provisioner() {
  script="$RBLIB/provision.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}

prestart() {
  git > /dev/null 2>&1 || apt-get install -y git-core > /dev/null 2>&1

  if [ ! -e /var/www ];then
    ln -s $DATADIR/www /var/www
    chown vagrant:vagrant /var/www
  fi
  if [ ! -d $YADDPROJECTS ];then
    mkdir -p $YADDPROJECTS
    chown vagrant:vagrant $YADDPROJECTS
  fi

  if [ ! -d $DOTDRUSH ];then
    mkdir -p $DOTDRUSH
    chown vagrant:vagrant $DOTDRUSH
  fi

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
