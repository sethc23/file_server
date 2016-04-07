#!/bin/bash
# $0 script
# $1 _orig
# $2 _ocr

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
_uuid=$(echo $_fname | sed -r 's/(.*)\.pdf$/\1/')

DEBUG="TRUE"

if [[ -n "$DEBUG" ]]; then
    echo "--<<"
    echo "SCRIPT: $0" >> /tmp/pgsql
    echo "_orig = $_orig" >> /tmp/pgsql
    echo "_ocr = $_ocr" >> /tmp/pgsql
    echo "_fname = $_fname">> /tmp/pgsql
    echo "_uuid = $_uuid" >> /tmp/pgsql
    echo "CMD = 'GET /send?uuid=$_uuid&filename=$_fname&filepath=$_ocr'" >> /tmp/pgsql
    echo ">>--"
fi

echo "GET /send?uuid=$_uuid&filename=$_fname&filepath=$_ocr" | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock,shut-down
