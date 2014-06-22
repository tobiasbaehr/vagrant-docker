#!/usr/bin/env bash
#set -o errexit
#set -x

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

docker_install () {
  # Install Docker

  if [ ! -f /usr/bin/docker ];
      then
      echo
      echo "Installing Docker from get.docker.io"
      echo "------------------------------------"
      echo
      curl -s get.docker.io | sh 2>&1 | egrep -i -v "Ctrl|docker installed"
      echo 'DOCKER_OPTS="-r=true ${DOCKER_OPTS}"' >> /etc/default/docker
      service docker restart
      else
      echo
      echo "Docker found at /usr/bin/docker:"
      echo "------------------------------------"
      echo
      docker version
  fi
}

crane_install() {
  if [ ! -f /usr/local/bin/crane ];then
      echo
      echo "Installing crane"
      echo "------------------------------------"
      echo
      bash -c "`curl -sL https://raw.githubusercontent.com/michaelsauter/crane/master/download.sh`" && sudo mv crane /usr/local/bin/crane
  fi
}

cleanup() {
  local images=$(docker images -f "dangling=true" -q)
  if [ ! -z "${images}" ];then
    docker rmi "${images}" > /dev/null
  fi
}

require_install() {
  cp "${__DIR__}/require.sh" /usr/local/bin/rbrequire
  chmod +x /usr/local/bin/rbrequire
}

proxy_start () {
  docker run -d --name="nginx-proxy" -v "/var/run/docker.sock:/tmp/docker.sock" -p "80:80" jwilder/nginx-proxy 2> /dev/null || docker restart nginx-proxy > /dev/null 2>&1 || true
}

public_install() {
  if [ ! -d "$DOCKERFILES/public/.git" ];then
    echo
    echo "Installing Reinblau dockerfiles into $DOCKERFILES/public/"
    echo "------------------------------------"
    echo
    # set up a trap to delete the temp dir when the script exits
    unset temp_dir
    trap '[[ -d "$temp_dir" ]] && rm -rf "$temp_dir"' EXIT
    # create the temp dir
    declare -r temp_dir=$(mktemp -dt dockerfiles.XXXXXX)
    git clone https://github.com/reinblau/dockerfiles.git "${temp_dir}"
    shopt -s dotglob
    mv ${temp_dir}/* "$DOCKERFILES/public/"
  fi
}

main () {
  docker_install
  crane_install
  require_install
  proxy_start
  public_install
}

main
