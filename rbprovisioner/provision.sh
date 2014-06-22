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

proxy () {
  docker run -d --name="nginx-proxy" -v "/var/run/docker.sock:/tmp/docker.sock" -p "80:80" jwilder/nginx-proxy 2> /dev/null || docker restart nginx-proxy 2> /dev/null || true
  #crane lift --manifest="${__DIR__}/crane.yml" 2> /dev/null || true
}

require() {
  cp "${__DIR__}/require.sh" /usr/local/bin/rbrequire

  chmod +x /usr/local/bin/rbrequire
}

main () {
  verify_bash
  docker_install
  crane_install
  proxy
  require
  rbrequire foo
}

main
