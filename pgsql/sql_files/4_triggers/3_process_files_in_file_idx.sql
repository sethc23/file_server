
-- 3. AFTER file_idx INSERT/UPDATE, IDENTIFY/INITIATE FILE PROCESSING

CREATE OR REPLACE FUNCTION process_files_in_file_idx()
    RETURNS TRIGGER AS $funct$

    from subprocess                         import Popen            as sub_popen
    from subprocess                         import PIPE             as sub_PIPE
    from traceback                      import format_exc       as tb_format_exc
    from sys                            import exc_info         as sys_exc_info

    GMAIL_ATTACHMENTS_DIR="/home/ub2/ARCHIVE/gmail_attachments"
    BASE_DIR="/home/ub2/SERVER2/file_server"

    def run_cmd(cmd):
        p = sub_popen(cmd,stdout=sub_PIPE,shell=True,executable='/bin/bash')
        (_out,_err) = p.communicate()
        assert _err is None
        return _out.rstrip('\n')

    def get_metadata(f_path):
        cmd = 'pdfinfo -meta %s | jq -sRcMj \'[ splits("\\n")? | split(":") as $i | \
                                { ($i[0]?) : ( $i[1] | sub("( )+"; ""; "sl") ) } ]\' \
                                | jq -cMj \'add\'' % f_path

        (_out,_err)                 =   sub_popen(cmd,stdout=sub_PIPE,shell=True).communicate()
        assert _err is None
        return _out.strip('\n[]')

    try:

        LOG_T =  'logger -i --priority info --tag "process_files_in_file_idx" -- "%s"'
        run_cmd(LOG_T % "STARTING process_files_in_file_idx")
        
        f_key = TD["new"]["_key"]
        f_path = GMAIL_ATTACHMENTS_DIR + f_key
        row_uid = TD["new"]["uid"]

        run_cmd(LOG_T % "fpath: "+f_path)

        if TD["new"]["_filetype"]=='pdf' and not TD["new"]["_metadata"]:
            _metadata = get_metadata(f_path)
            qry = "UPDATE file_idx SET _metadata = '%s' WHERE uid=%s"
            run_cmd( qry % (_metadata,row_uid) )
                
        cmd = BASE_DIR + "/fs_ocr_to_pgsql %s %s %s &"
        run_cmd( cmd % (row_uid,f_key,GMAIL_ATTACHMENTS_DIR) )

    except plpy.SPIError:
        plpy.log('fps_gmail_update FAILED')
        plpy.log(tb_format_exc())
        plpy.log(sys_exc_info()[0])
        return

    $funct$ 
    language "plpythonu";

CREATE TRIGGER process_files_in_file_idx_trigger
    AFTER INSERT
    ON file_idx
    FOR EACH ROW
    EXECUTE PROCEDURE process_files_in_file_idx();