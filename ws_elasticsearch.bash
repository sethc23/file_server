#!/bin/bash

tbls[1]="gmail"
keys[1]="orig_msg all_mail_uid g_msg_id msg_id last_updated uid"   # gmail

tbls[2]="file_idx"
keys[2]="src_db src_uid _key _filetype _info _run_ocr _metadata last_updated uid _content" # file_idx

_tbl=""

i=${#tbls[@]}
while [ $i -gt 0 ]; do
    if [ ${tbls[$i]} = "$PLSH_TG_TABLE_NAME" ]; then
        _tbl=${tbls[$i]}
        _keys=()
        pt=1
        for i in ${keys[$i]}; do 
            _keys[$pt]=$i
            let pt=pt+1
        done
        break
    fi
    let i=i-1
done

if [ -z "$_tbl" ]; then exit 1; fi

key_arr=""
val_arr=""
pt=1
re='^[0-9]+$'
for arg do
    
    k=${_keys[$pt]}
    echo "$k" >> /tmp/tmp2
    if [ -n "$arg" ]; then
        key_arr="$key_arr"'"'"$k"'",'
        if [ $k = "uid" ]; then _uid="$arg"; fi
        if [ $k = "last_updated" ]; then arg=$(python -c "from dateutil import parser as DU; print(DU.parse(\"$arg\").strftime('%s'))"); fi

        if [ ${arg::1} = "{" ] || ( [[ $arg =~ $re ]] && [ $arg -lt 2147483647 ] ); then
           val_arr="$val_arr$arg,"
        else
           val_arr="$val_arr\"$arg\","
        fi

    fi
    let pt=pt+1
done

key_arr=${key_arr::-1}
val_arr=${val_arr::-1}
_arr="[[$key_arr],[$val_arr]]"

uuid=`uuidgen -r`
fpath="/tmp/$uuid"
printf '%s\n' "$_arr" | jq 'transpose | map({ key: .[0], value: .[1] }) | from_entries' > "$fpath"
echo "GET /send_json_file?tbl=$_tbl&uid=$_uid&uuid=$uuid&filepath=$fpath" | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock
