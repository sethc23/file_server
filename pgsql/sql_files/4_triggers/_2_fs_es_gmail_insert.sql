CREATE OR REPLACE FUNCTION fs_es_gmail_insert()
  RETURNS trigger AS
$BODY$#!/bin/bash

    _arr='[["orig_msg","all_mail_uid","g_msg_id","msg_id","last_updated","uid"],['
    for arg do
        if [ -z "$arg" ]; then
            _arr="$_arr\"$arg\","
        elif [ ${arg::1} = "{" ]; then
            _arr="$_arr$arg,"
        else
            _arr="$_arr\"$arg\","
        fi
        _uid="$arg"
    done
    _arr=${_arr::-1}"]]"
    
    _json=$(printf '%s
' "$_arr" | jq -Mc 'transpose | map({ key: .[0], value: .[1] }) | from_entries')
    echo "GET /json?gmail=$_json&uid=$_uid" | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock

$BODY$
LANGUAGE PLSHU;