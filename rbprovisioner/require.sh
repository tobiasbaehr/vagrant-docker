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
      *)
      # unknown option
      ;;
  esac
  done
}


main "$@"
