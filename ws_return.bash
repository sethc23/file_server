#!/bin/bash
# $0 script
# $1 _orig
# $2 _ocr

_orig=$1
_ocr=$2
_fname=$(echo $_ocr | sed -r 's/(.*)\/([^\/]+)$/\2/')
_uuid=$(echo $_fname | sed -r 's/(.*)\.pdf$/\1/')

LOG_TAG="ws_return.bash"
logger -i --priority info --tag $LOG_TAG -- "args: $@"

GET_REQ="GET /send?uuid=$_uuid&filename=$_fname&filepath=$_ocr"

logger -i --priority info --tag $LOG_TAG -- "GET_REQ: $GET_REQ"

echo $GET_REQ | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock,shut-down
