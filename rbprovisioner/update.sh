#!/usr/bin/env bash
#set -o errexit
#set -x

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

verify_bash() {
  if [ -z "${BASH_SOURCE}" ];then
    echo "Do not run the script via sh. Use bash do to this." >&2
    exit 1
  fi
}

# Check if we have root powers
if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo" >&2
    exit 1
fi

update_os() {
  apt-get update -q
  apt-get upgrade -yq
  apt-get autoclean -yq
}

update_self() {
  echo
  echo "Self-update"
  echo "------------------------------------"
  echo
  git > /dev/null 2>&1 || apt-get install -y git-core > /dev/null 2>&1
  if [ ! -d "${RBHOME}/.git" ];then
    rm -rf /tmp/vagrant-docker > /dev/null 2>&1
    git clone https://github.com/reinblau/vagrant-docker.git /tmp/vagrant-docker
    #mv /tmp/vagrant-docker/.git "${RBHOME}/.git"
    #$(cd ${RBHOME};git pull)
  fi
  echo
  echo "Restarting provisioning"
  echo "------------------------------------"
  echo
  exec "${RBHOME}/start.sh" --run
}

update_crane() {
  rm /usr/local/bin/crane 2> /dev/null || true
}

update_run () {
  local type=$1
  local lastUpFile="/root/.${type}.lastupdate"
  local lastUpTime=0
  local now=$(date +"%s")

  if [ ! -f "${lastUpFile}" ];then
    lastUpTime="${now}"
  else
    lastUpTime=$(cat "${lastUpFile}")
  fi
  local next=$((${lastUpTime} + 24 * 60 * 60 * 7));

  if [ "${next}" -le "${now}" ];then
    update_"${type}"
    echo "${now}" > "${lastUpFile}"
  fi
}

main () {
  update_run "self"
  update_run "os"
  update_run "crane"
}

main "$@"
