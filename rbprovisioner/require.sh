#!/usr/bin/env bash
set -o errexit
set -o nounset

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

start_project() {
  local project=${1:-""}
  if [[ -z $project ]];then
    echo "Missing value for --project=NAME parameter" >&2
    exit 1
  fi
  subdirs="$DOCKERFILES/*/"

  for dir in ${subdirs}
  do
    runfile="${dir}${project}/run.sh"
    if [ -f "${runfile}" ];then
      echo "Executing ${runfile}"
      bash "${runfile}"
      if [ $? -ne 0 ];then
         echo "Could not start ${project}." >&2
         exit 1
      fi
      return
    fi
  done
  echo "Unknown project ${project} (--project)" >&2
  exit 1
}

require_ssh_config() {
  echo "Checking required ssh-key."
  if [[ -z ${SSHKEY} ]];then
    mkdir -p ${SSHDIR}
    echo "Can not find your ssh-key in this directory ${SSHDIR}. The project requires your ssh-key." >&2
    exit 1
  fi
}

require_git_config() {
  echo "Checking required .gitconfig file."
  if [ ! -f $DATADIR/user/.gitconfig ];then
    echo "Copy required .gitconfig file."
    mkdir -p "$DATADIR/user"
    cp $RBLIB/git/.gitconfig $DATADIR/user/.gitconfig
    chown vagrant: $DATADIR/user/.gitconfig
  fi
}

main() {
  if [[ $# == 0 ]];then
    echo "$__FILE__ requires at least one option" >&2
    exit 1
  fi

  for i in "$@"
  do
  case $i in
      --project=*)
      project="${i#*=}"
      start_project $project
      shift
      ;;
      --gitconfig)
      require_git_config
      shift
      ;;
      --sshconfig)
      require_ssh_config
      shift
      ;;
      *)
      # unknown option
      ;;
  esac
  done
}


main "$@"
