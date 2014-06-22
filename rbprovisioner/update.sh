#!/usr/bin/env bash
#set -o errexit
#set -x

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

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
  if [ ! -d "${RBHOME}/.git" ];then
    # set up a trap to delete the temp dir when the script exits
    unset temp_dir
    trap '[[ -d "$temp_dir" ]] && rm -rf "$temp_dir"' EXIT
    # create the temp dir
    declare -r temp_dir=$(mktemp -dt dockerfiles.XXXXXX)
    git clone https://github.com/reinblau/vagrant-docker.git "${temp_dir}"
    mv "${temp_dir}/.git" "${RBHOME}/.git"
    #$(cd ${RBHOME};git pull)
    echo
    echo "Restarting provisioning"
    echo "------------------------------------"
    echo
    exec "${RBHOME}/start.sh" --run
  fi
}

update_crane() {
  rm /usr/local/bin/crane 2> /dev/null || true
}

update_dockerfiles() {
  subdirs="$DOCKERFILES/*"
  for dir in "${subdirs}"
    do
      gitdir="${dir}/.git"
      if [ -d "${gitdir}" ];then
        $(cd "${gitdir}" && git pull)
      fi
  done
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
  update_run "dockerfiles"
  echo
  echo "Starting provisioning"
  echo "------------------------------------"
  echo
  exec "${RBHOME}/start.sh" --run
}

main
