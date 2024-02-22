

#!/bin/bash

set -e

ENV="${1:-dev}";
if [ $# > 0 ]; then shift; fi

ARGS="$@"
UPFILE="./serverless.${ENV}.yml"

if [ ! -f "$UPFILE" ]; then
  echo "ERROR: File '$UPFILE' not found!" >&2
  exit 1
fi

yes | cp -f $UPFILE serverless.yml
trap 'rm -f serverless.yml .serverless' EXIT

echo "$ sls ${ARGS}"
echo ""

sls "$@"
