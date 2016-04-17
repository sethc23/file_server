#!/bin/bash -l
# $0 script
# $1 _orig
# $2 _ocr

 LOG_TAG="ws_return.bash"
# logger -i --priority info --tag $LOG_TAG -- "env: "$(env|sort)
logger -i --priority info --tag $LOG_TAG -- "args0: $0"
logger -i --priority info --tag $LOG_TAG -- "args1: $1"
logger -i --priority info --tag $LOG_TAG -- "args2: $2"
# logger -i --priority info --tag $LOG_TAG -- "args3: $3"

THIS_FILE=$(echo "$0" | sed -r 's/.*[\/]([^\/]+)/\1/g')

_orig=$1
_ocr=$2
for i in "$@"; do    
    case $i in
        --debug)
        DEBUG="True"
        ;;
    esac
done
_fname=$(echo $_ocr | sed -r 's/(.*)\/([^\/]+)$/\2/')
_uuid=$(echo $_fname | sed -r 's/(.*)\.pdf$/\1/' | sed -r 's/(.*)_ocr$/\1/')

logger -i --priority info --tag $LOG_TAG -- "_uuid: $_uuid"
# DEBUG="TRUE"

# if [[ -n "$DEBUG" ]]; then
#     echo "--<<"  >> /tmp/pgsql
#     echo "SCRIPT: $0" >> /tmp/pgsql
#     echo "_orig = $_orig" >> /tmp/pgsql
#     echo "_ocr = $_ocr" >> /tmp/pgsql
#     echo "_fname = $_fname">> /tmp/pgsql
#     echo "_uuid = $_uuid" >> /tmp/pgsql
#     echo "CMD = 'GET /send?uuid=$_uuid&filename=$_fname&filepath=$_ocr'" >> /tmp/pgsql
#     echo ">>--" >> /tmp/pgsql
# fi

# echo "GET /send?uuid=$_uuid&filename=$_fname&filepath=$_ocr" | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock,shut-down >> $LOG_FILE 2>&1
#-lp"$THIS_FILE" 

WS_URL="http://localhost:12501"
UPDATE_INFO="uuid=$_uuid&filename=$_fname&filepath=$_ocr"
DEST_INFO="data_type=file&service_dest=pgsql"
GET_URL="$WS_URL/send?$UPDATE_INFO&$DEST_INFO"
# GET_URL="GET /send?$SERVICES_INFO&$UPDATE_INFO&$DEST_INFO"
# echo $GET_URL | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock
logger -i --priority info --tag $LOG_TAG -- "GET_URL: $GET_URL"
curl -s $GET_URL
