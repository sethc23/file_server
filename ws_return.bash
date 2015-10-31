#!/bin/bash
# $0 script
# $1 _orig
# $2 _ocr

_orig=$1
_ocr=$2
_fname=$(echo $_ocr | sed -r 's/(.*)\/([^\/]+)$/\2/')
_uuid=$(echo $_fname | sed -r 's/(.*)\.pdf$/\1/')

echo "GET /send?uuid=$_uuid&filename=$_fname&filepath=$_ocr" | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock,shut-down
