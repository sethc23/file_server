CREATE OR REPLACE FUNCTION update_es_on_pgsql_insert_update()
    RETURNS TRIGGER AS $funct$

    from traceback                      import format_exc       as tb_format_exc
    from sys                            import exc_info         as sys_exc_info

    try:
        import json,uuid
        from subprocess import Popen as sub_popen
        from subprocess import PIPE as sub_PIPE

        def run_cmd(cmd):
            p = sub_popen(cmd,stdout=sub_PIPE,shell=True,executable='/bin/bash')
            (_out,_err) = p.communicate()
            assert _err is None
            return _out.rstrip('\n')

        LOG_T =  'logger -i --priority info --tag "update_es_on_pgsql_insert_update" -- "%s"'

        run_cmd(LOG_T % "STARTING update_es_on_pgsql_insert_update")


        if TD.has_key('OLD'):
            is_diff=TD['OLD']==TD['NEW']
            run_cmd(LOG_T % 'DIFF ? -- '+is_diff)
        else:
            run_cmd(LOG_T % 'DIFF ? -- NO OLD')

        run_cmd(LOG_T % "Event: %(event)s" % TD)
        run_cmd(LOG_T % "Trigger Name: %(name)s" % TD)
        run_cmd(LOG_T % "Table: %(table_name)s" % TD)
        msg = "Keys: "+str(TD.keys())
        run_cmd(LOG_T % msg)

        if TD['event']=='UPDATE':
            chk=TD['old']==TD['new']
            msg = "TD['old']==TD['new'] = "+ str(chk)
            run_cmd(LOG_T % msg)


            for k,v in TD['new'].iteritems():
                chk=TD['old'][k]==TD['new'][k]
                msg = "chk: old."+k+"==new."+k+" --> "+str(chk)
                run_cmd(LOG_T % msg)
                msg = 'KEY: (%s) -- A:B -- %s:%s' % (k,TD['old'][k],v)
                run_cmd(LOG_T % msg)

        uuid = uuid.uuid4().hex
        fpath='/tmp/%s' % uuid

        with open(fpath,'w') as f:
            f.write(json.dumps(TD["new"],ensure_ascii=False))

        table,row_uid=TD["table_name"],TD['new']['uid']
        cmd = "/home/ub2/SERVER2/file_server/ws_elasticsearch.bash %s %s %s %s" % (table,row_uid,uuid,fpath)
        run_cmd(cmd)



    except plpy.SPIError:
        plpy.log('fps_gmail_update FAILED')
        plpy.log(tb_format_exc())
        plpy.log(sys_exc_info()[0])
        return

    $funct$ 
    language "plpythonu";


-- GMAIL -- update_es_on_gmail_insert_update
CREATE TRIGGER update_es_on_gmail_insert_update_trigger
    BEFORE INSERT OR UPDATE
    OF orig_msg
    ON gmail
    FOR EACH ROW
    EXECUTE PROCEDURE update_es_on_pgsql_insert_update();

-- FILE_IDX -- update_es_on_file_idx_insert_update
CREATE TRIGGER update_es_on_file_idx_insert_update_trigger
    BEFORE INSERT OR UPDATE 
    OF _info,_metadata
    ON file_idx
    FOR EACH ROW
    EXECUTE PROCEDURE update_es_on_pgsql_insert_update();

-- FILE_CONTENT -- update_es_on_file_content_insert_update
CREATE TRIGGER update_es_on_file_content_insert_update_trigger
    BEFORE INSERT OR UPDATE 
    OF plain_text,html_text
    ON file_content
    FOR EACH ROW
    EXECUTE PROCEDURE update_es_on_pgsql_insert_update();