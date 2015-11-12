#!/usr/bin/env bash
#set -o errexit
#set -x
set -o nounset

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

docker_install () {
  # Install Docker
  echo
  echo "Checking Docker availability"
  echo "------------------------------------"
  if [ ! -f /usr/bin/docker ];
      then
      echo "Installing Docker from get.docker.com"
      echo "------------------------------------"
      echo
      curl -sSL https://get.docker.com/ | sh
  else
      service docker status 2> /dev/null | service docker start
      echo
      echo "Docker found at /usr/bin/docker:"
      echo "------------------------------------"
      docker version
      echo "------------------------------------"
      echo
  fi
}

crane_install() {
  if [[ ! -f /usr/local/bin/crane ]];then
      echo
      echo "Installing crane"
      echo "------------------------------------"
      echo
      export VERSION=$CRANEVERSION
      bash -c "`curl -sL https://raw.githubusercontent.com/michaelsauter/crane/master/download.sh`" && sudo mv crane /usr/local/bin/crane
  fi
}

cleanup_images() {
  local images=$(docker images -f "dangling=true" -q)
  if [[ ! -z $images ]];then
    echo
    echo "Remove not tagged images"
    echo "------------------------------------"
    echo
    OUT=$(docker rmi $images)
    echo $OUT
    echo "------------------------------------"
    echo
  fi
}

cleanup_containers() {
  local containers="$(docker ps --filter "status=exited" -qa)"
  if [[ ! -z $containers ]];then
    echo
    echo "Clean up exited container"
    echo "------------------------------------"
    echo
    docker rm $containers 2> /dev/null
    echo "------------------------------------"
    echo
  fi
}

require_install() {
  cp "${__DIR__}/require.sh" /usr/local/bin/rbrequire
  chmod +x /usr/local/bin/rbrequire
}

proxy_start () {
  mkdir -p $DATADIR/nginx-proxy/conf.d
  cp ${__DIR__}/proxy/nginx_custom.conf $DATADIR/nginx-proxy/conf.d
  OUT=$(docker rm -f nginx-proxy 2> /dev/null)
  echo "Starting nginx proxy"
  OUT=$(docker run -d --name="nginx-proxy" -v "/var/run/docker.sock:/tmp/docker.sock:ro" -v "/data/nginx-proxy/conf.d/nginx_custom.conf:/etc/nginx/conf.d/nginx_custom.conf:ro" -p "80:80" -p "443:443" jwilder/nginx-proxy)
  echo "------------------------------------"
  echo
}

public_install() {
  if [ ! -d "$DOCKERFILES/reinblau/.git" ];then
    echo
    echo "Installing Reinblau dockerfiles into $DOCKERFILES/reinblau/"
    echo "------------------------------------"
    echo
    # set up a trap to delete the temp dir when the script exits
    unset temp_dir
    temp_dir=${temp_dir:-""}
    trap '[[ -d "$temp_dir" ]] && rm -rf "$temp_dir"' EXIT
    mkdir -p "$DOCKERFILES/reinblau/"
    # create the temp dir
    declare -r temp_dir=$(mktemp -dt dockerfiles.XXXXXX)
    git clone https://github.com/reinblau/dockerfiles.git "${temp_dir}"
    shopt -s dotglob
    mv ${temp_dir}/* "$DOCKERFILES/reinblau/"
  fi
}

commander_install() {
  cp "${__DIR__}/commander.sh" /usr/local/bin/rbcommander
  chmod +x /usr/local/bin/rbcommander
}

updater_install() {
  cp "${__DIR__}/rbupdate.sh" /usr/local/bin/rbupdate
  chmod +x /usr/local/bin/rbupdate
}

projects_start() {
  if [[ -f $PROJECTLIST ]];then
    for project in $(cat "$PROJECTLIST")
    do
      echo "Starting project ${project}"
      echo "------------------------------------"
      echo
      rbrequire --project="${project}"
      local ec=$?
      echo "------------------------------------"
      echo
      if [ $ec -ne 0 ];then
        echo "Can not start ${project}." >&2
        exit 1
      fi
    done
  fi
}

collect_vhost() {
  declare -a vhosts=()
  for ContainerID in $(docker ps -q)
  do
    local IFS=','
    local VIRTUAL_HOST=${VIRTUAL_HOST:-""}
    local envs=$(echo "$(docker inspect --format='{{json .Config.Env}}' "${ContainerID}")" | cut -d "[" -f 2 | cut -d "]" -f 1)
    for conf in ${envs}
    do
      if echo "${conf}" | grep VIRTUAL_HOST > /dev/null ;then
        vhosts+=($(echo "${conf}" | cut -d '"' -f 2 | cut -d '=' -f 2))
      fi
    done
  done
  vhosts=${vhosts:-""}
  if [ ! -z "${vhosts}" ];then
    echo "${vhosts[@]}" > ${VAGRANTDOCKER}/vhosts.txt
  fi
}

main () {
  docker_install
  crane_install
  require_install
  updater_install
  proxy_start
  public_install
  commander_install
  projects_start
  collect_vhost
  cleanup_containers
  cleanup_images
}

main
