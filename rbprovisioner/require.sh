#!/usr/bin/env bash
#set -o errexit
set -x

service="$1"

subdirs="$DOCKERFILES/*"
for dir in "${subdirs}"
  do
    runfile="${dir}/${service}/run.sh"
    if [ -f "${runfile}" ];then
      exec "${runfile}"
      if [ $? -ne 0 ];then
        echo "Could not resolve ${service}" >&2
        exit $?
      fi
    fi
done
echo "Unknown service ${service}" >&2
exit 1
