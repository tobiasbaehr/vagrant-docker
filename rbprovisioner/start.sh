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
export CRANEVERSION="1.0.0"
export DATADIR="/data"
export YADDPROJECTS="${DATADIR}/user/yaddprojects"
export DOTDRUSH="${DATADIR}/user/.drush"
export SSHDIR="${DATADIR}/user/.ssh/"
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

  if [ ! -d "$DATADIR/www" ];then
    mkdir -p $DATADIR/www
  fi
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

}

run_updates() {
  script="$RBLIB/update.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}" "$@"
  fi
}


main () {
  local update=${1:-""}
  local force=${2:-""}
  if [ ! -z "${update}" ] && [ "${update}" == '--update' ];then
    run_updates "$force"
  else
    prestart
    start_provisioner
  fi
}

main "$@"
