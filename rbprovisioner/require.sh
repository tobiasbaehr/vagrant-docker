#!/usr/bin/env bash
set -o errexit
set -o nounset

require=${1:-""}
if [ -z "${require}" ];then
  echo "Missing require parameter" >&2
  exit 1
fi

subdirs="$DOCKERFILES/*/"

for dir in ${subdirs}
do
  runfile="${dir}${require}/run.sh"
  if [ -f "${runfile}" ];then
    echo "Executing ${runfile}"
    bash "${runfile}"
    if [ $? -ne 0 ];then
       echo "Could not start ${require}." >&2
       exit 1
    fi
    exit 0
  fi
done
echo "Unknown require ${require} parameter" >&2
exit 1
