#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

update_os() {
  echo
  echo "Updating OS"
  echo "------------------------------------"
  echo
  apt-get update -q
  apt-get upgrade -yq
  apt-get dist-upgrade -yq
  apt-get autoclean -yq
  echo "------------------------------------"
  echo
}

update_self() {
  if [ ! -d "${VAGRANTDOCKER}/.git" ];then
    echo
    echo "Installing vagrant-docker as git repository"
    echo "------------------------------------"
    echo
    # set up a trap to delete the temp dir when the script exits
    unset temp_dir
    trap '[[ -d "$temp_dir" ]] && rm -rf "$temp_dir"' EXIT
    # create the temp dir
    declare -r temp_dir=$(mktemp -dt dockerfiles.XXXXXX)
    git clone https://github.com/reinblau/vagrant-docker.git "${temp_dir}"
    mv "${temp_dir}/.git" "${VAGRANTDOCKER}/.git"
    touch "${VAGRANTDOCKER}/.autocreated"
  elif [ -f "${VAGRANTDOCKER}/.autocreated" ] ;then
    echo
    echo "Self-update of vagrant-docker"
    echo "------------------------------------"
    OUT=$(cd ${VAGRANTDOCKER} && git reset --hard > /dev/null && git pull)
    echo $OUT
    echo
    echo "Restarting provisioner"
    echo "------------------------------------"
    echo
    exec "${RBLIB}/start.sh" --restart
  fi
}

update_crane() {
  echo
  echo "Checking version of crane"
  echo "------------------------------------"
  local current_version=$(crane version)
  if [ "${current_version}" != "${CRANEVERSION}" ];then
    echo "Remove current version (${current_version}) of crane"
    echo "------------------------------------"
    echo
    rm /usr/local/bin/crane 2> /dev/null || true
  else
    echo "Found ${current_version} of crane"
    echo "------------------------------------"
    echo
  fi
}

update_dockerfiles() {
  local subdirs="$DOCKERFILES/*/"
  local gitdir=""
  for dir in ${subdirs}
    do
      gitdir="${dir}.git/"
      local dir_basename="$(echo "$(basename ${dir})")"
      if [[ -f $BLACKLIST ]] && grep ${dir_basename} $BLACKLIST > /dev/null ;then
        continue
      fi

      if [[ -d $gitdir ]];then
        echo
        echo "Updating ${dir}"
        echo "------------------------------------"
        echo
        OUT=$(cd "${dir}" && git reset --hard > /dev/null && git pull)
        echo $OUT
        echo "------------------------------------"
        echo
      fi
  done
}

update_dockerimages() {
  local projects=""
  if [[ -f $PROJECTLIST ]];then
    for project in $(cat "$PROJECTLIST")
      do
      if [[ -f $BLACKLIST ]] && grep ${project} $BLACKLIST > /dev/null ;then
        continue
      fi
      projects="$DOCKERFILES/*/$project/"
      for project_dir in ${projects}
        do
          if [[ -f "$project_dir/crane.yml" ]];then
            echo
            echo "Updating docker image for ${project}"
            echo "------------------------------------"
            echo
            OUT=$(cd $project_dir && crane provision)
            echo $OUT
            echo "------------------------------------"
            echo
          fi
      done
    done
  fi
}

update_run () {
  local type=$1
  local lastUpDir=/root/rblastupdate/
  if [[ ! -d $lastUpDir ]];then
    mkdir $lastUpDir
  fi
  local lastUpFile="$lastUpDir${type}"
  local lastUpTime=0
  local now=$(date +"%s")

  if [ ! -f "${lastUpFile}" ];then
    lastUpTime="${now}"
    echo "${lastUpTime}" > "${lastUpFile}"
  else
    lastUpTime=$(cat "${lastUpFile}")
  fi
  local duration="60 * 60 * 24"
  local next=$((${lastUpTime} + ${duration}));

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
  update_run "dockerimages"
  echo
  echo "Starting provisioner"
  echo "------------------------------------"
  echo
  exec "${RBLIB}/start.sh" --run
}

main
