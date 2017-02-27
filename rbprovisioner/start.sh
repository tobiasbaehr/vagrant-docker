#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

__DIR__="$(cd "$(dirname "${0}")"; pwd)"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

export VAGRANTDOCKER="/vagrant"
export RBLIB="${VAGRANTDOCKER}/rbprovisioner"
export DOCKERFILES="${VAGRANTDOCKER}/dockerfiles"
export PROJECTLIST="${VAGRANTDOCKER}/projects.txt"
export BLACKLIST="${VAGRANTDOCKER}/blacklist.txt"
export CRANEVERSION="1.5.1"
export DATADIR="/data"
export YADDPROJECTS="${DATADIR}/user/yaddprojects"
export DOTDRUSH="${DATADIR}/user/.drush"

start_provisioner() {
  script="$RBLIB/provision.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}"
  fi
}

prestart() {
  git >/dev/null 2>&1 || apt-get install -y git-core >/dev/null 2>&1

  if [ ! -d "$DATADIR/www" ];then
    mkdir -p $DATADIR/www
    chown vagrant: $DATADIR/www
  fi
  if [ ! -e /var/www ];then
    ln -s $DATADIR/www /var/www
    chown vagrant: /var/www
  fi
  if [ ! -d $YADDPROJECTS ];then
    mkdir -p $YADDPROJECTS
    chown vagrant: $YADDPROJECTS
  fi

  if [ ! -d $DOTDRUSH ];then
    mkdir -p $DOTDRUSH
  fi
  if [ ! -f $DATADIR/user/.gitconfig ];then
    mkdir -p "$DATADIR/user"
    cp $RBLIB/git/.gitconfig $DATADIR/user/.gitconfig
  fi
  chown -R vagrant: $DATADIR/user/
}

run_updates() {
  script="$RBLIB/update.sh"
  if [ -f "${script}" ];then
    chmod +x "${script}"
    exec "${script}" "$@"
  fi
}

main () {
  local autoupdate=${1:-""}
  if [ ! -z "${autoupdate}" ];then
    run_updates ${autoupdate}
  else
    prestart
    start_provisioner
  fi
}

main "$@"
