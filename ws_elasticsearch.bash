#!/bin/bash
# $0    script
# $1    table
# $2    row uid
# $2    uuid
# $3    jpath

TABLE="$1"
ROW_UID="$2"
UUID="$3"
JPATH="$4"

source /home/ub2/SERVER2/file_server/fs_env

# UUID=$(uuidgen -r)
# JPATH="/tmp/$UUID"

LOG_TAG="ws_elasticsearch.bash"
# logger -i --priority info --tag $LOG_TAG -- "env: "$(env|sort)
logger -i --priority info --tag $LOG_TAG -- "args0: $0"
logger -i --priority info --tag $LOG_TAG -- "args1: $1"
logger -i --priority info --tag $LOG_TAG -- "args2: $2"
logger -i --priority info --tag $LOG_TAG -- "args3: $3"
# logger -i --priority info --tag $LOG_TAG -- "args4: $4"
# logger -i --priority info --tag $LOG_TAG -- "args5: $5"
# logger -i --priority info --tag $LOG_TAG -- "args6: $6"
logger -i --priority info --tag $LOG_TAG -- "JPATH: $JPATH"



# CHECK
# CHECK=$(diff --suppress-common-lines --side-by-side --text --ignore-all-space --minimal \
# <(echo $b | jq '.') <(echo $a | jq '.') | \
# grep -v last_updated | wc -l)

# TABLE="$PLSH_TG_TABLE_NAME"

# OLD
    # tbls[1]="gmail"
    # keys[1]="orig_msg all_mail_uid g_msg_id msg_id last_updated uid"                    # gmail

    # tbls[2]="file_idx"
    # keys[2]="src_db src_uid _key _filetype _info _run_ocr _metadata last_updated uid"   # file_idx

    # tbls[3]="file_content"
    # keys[3]="src_db src_uid pg_num plain_text html_text last_updated uid"               # file_content

    # i=${#tbls[@]}
    # while [[ $i -gt 0 ]]; do
    #     logger -i --priority info --tag $LOG_TAG -- "iter \$\{tbls[\$i]\}: $${tbls[$i]}"
    #     if [ ${tbls[$i]} = "$PLSH_TG_TABLE_NAME" ]; then
    #         TABLE=${tbls[$i]}
    #         logger -i --priority info --tag $LOG_TAG -- "TABLE: $TABLE"
    #         _keys=()
    #         pt=1
    #         for i in ${keys[$i]}; do 
    #             _keys[$pt]=$i
    #             let pt=pt+1
    #         done
    #         break
    #     fi
    #     let i=i-1
    # done

# [[ -z "$TABLE" ]]                   &&      exit 1
# [[ "$TABLE" = "gmail" ]]            &&      ROW_UID="$6"
# [[ "$TABLE" = "file_idx" ]]         &&      ROW_UID="$9"
# [[ "$TABLE" = "file_content" ]]     &&      ROW_UID="$6"

# logger -i --priority info --tag $LOG_TAG -- "ROW_UID: $ROW_UID"

# QUERY="SELECT * FROM $TABLE WHERE uid=$ROW_UID;"
# POST_URL="http://localhost:12501/query"
# echo "{\"qry\": \"$QUERY\"}" | curl -s -d @- $POST_URL | jq -Mc '.[]' > $JPATH

# logger -i --priority info --tag $LOG_TAG -- "QRY: $QUERY"
# logger -i --priority info --tag $LOG_TAG -- "QRY RESULTS:" $(echo "{\"qry\": \"$QUERY\"}" | curl -s -d @- $POST_URL)
# echo "{\"qry\": \"SELECT * FROM gmail WHERE uid=178293;\"}" | curl -s -d @- "http://localhost:12501/query" | jq '.[]' 

reformat_json_field(){
    cat $JPATH | jq -M -c --argjson a "$(cat $JPATH | jq '.'"$1" | jq -r '.' | jq -M -c '.')" '.'"$1"'=$a' > /tmp/$SH_UUID
    mv /tmp/$SH_UUID $JPATH
    }

SH_UUID=$(uuidgen -r)"_SH"
if [[ "$TABLE" = "gmail" ]]; then
    reformat_json_field "orig_msg"
elif [[ "$TABLE" = "file_idx" ]]; then
    reformat_json_field "_info"
    reformat_json_field "_metadata"
fi

UPDATE_INFO="tbl=$TABLE&uid=$ROW_UID&uuid=$UUID&filepath=$JPATH"
DEST_INFO="data_type=json&service_dest=es"
GET_URL="$WS_URL/send?$SERVICES_INFO&$UPDATE_INFO&$DEST_INFO"
# GET_URL="GET /send?$SERVICES_INFO&$UPDATE_INFO&$DEST_INFO"
# echo $GET_URL | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock
logger -i --priority info --tag $LOG_TAG -- "GET_URL: $GET_URL"
curl -s $GET_URL

# if [[ "$TABLE" = "gmail" ]]; then
#     QUERY="SELECT update_file_idx_by_gmail_insert_update( $ROW_UID );"
#     POST_URL="http://localhost:12501/query"
#     echo "{\"qry\": \"$QUERY\"}" | curl -s -d @- $POST_URL
# fi


logger -i --priority info --tag $LOG_TAG -- " -- END -- "

# OLD
    # key_arr=""
    # val_arr=""
    # pt=1
    # re='^[0-9]+$'
    # _json='{}'
    # for arg do
        
    #     k=${_keys[$pt]}
        
    #     logger -i --priority info --tag $LOG_TAG -- "\$k: $k"

    #     if [ -n "$arg" ]; then
    #         key_arr="$key_arr"'"'"$k"'",'
    #         if [ $k = "uid" ]; then _uid="$arg"; fi
    #         if [ $k = "last_updated" ]; then arg=$(python -c "from dateutil import parser as DU; print(DU.parse(\"$arg\").strftime('%s'))"); fi

    #         if [ ${arg::1} = "{" ] || ( [[ $arg =~ $re ]] && [ $arg -lt 2147483647 ] ); then
    #            val_arr="$val_arr$arg,"
    #         else
    #            val_arr="$val_arr\"$arg\","
    #         fi
    #         logger -i --priority info --tag $LOG_TAG -- "\$arg: $arg"
    #         logger -i --priority info --tag $LOG_TAG -- "\$val_arr: $val_arr"
    #     fi
    #     new_json=$(echo "$arg" | jq -MRc . | jq -Msc '.[]' | jq --arg a "$k" -M -s -c '. as $val |  {($a):$val[]}')
    #     logger -i --priority info --tag $LOG_TAG -- "\$new_json: $new_json"
    #     # _json=$(jq --arg j "$_json" --arg n "$new_json" -M -c -n '$j * $n')
    #     _json=$(jq -Mcn "$(jq --arg j $_json -rRMcn '$j') * $(jq --arg n $new_json -rRMcn '$n')")
    #     logger -i --priority info --tag $LOG_TAG -- "\$_json: $_json"
    #     let pt=pt+1
    # done

    # key_arr=${key_arr::-1}
    # val_arr=${val_arr::-1}
    # _arr="[[$key_arr],[$val_arr]]"

    # uuid=`uuidgen -r`
    # fpath="/tmp/$uuid"

    # logger -i --priority info --tag $LOG_TAG -- "RESULTS: $_arr"
    # echo $_arr | jq -R -c -M 'transpose | map({ key: .[0], value: .[1] }) | from_entries' > "$fpath"
