CREATE OR REPLACE FUNCTION fs_process_files_in_file_idx()
  RETURNS trigger AS
$BODY$

    from subprocess                         import Popen            as sub_popen
    from subprocess                         import PIPE             as sub_PIPE
    from traceback                      import format_exc       as tb_format_exc
    from sys                            import exc_info         as sys_exc_info

    def txt_log(msg):
        with open('/tmp/tmp','a+') as f:
            f.write(msg+'\n')

    def upd_pdf(f_path):
        cmd = ';'.join([  'pdfinfo -meta %s | jq -sRcMj \'[ splits("\\n")? | split(":") as $i | \
                                { ($i[0]?) : ( $i[1] | sub("( )+"; ""; "sl") ) } ]\' \
                                | jq -cMj \'add\'' % f_path,
                           'echo "<BREAK>"',
                           'pdftotext -q -nopgbrk -layout %s -' % f_path,
                           'echo "<BREAK>"'
                       ])
        (_out,_err)                 =   sub_popen(cmd,stdout=sub_PIPE,shell=True).communicate()
        assert _err is None
        res = _out.split('<BREAK>')
        TD["new"]["_metadata"] = "'" + str(res[0].strip('\n[]')) + "'"
        _content = res[1].strip('\n')
        if _content:
            TD["new"]["_content"] = "'" + str(_content) + "'"
        else:
            TD["new"]["_run_ocr"] = True
        return TD["new"]

    def upd_from_ocr_pdf(f_path):
        cmd = 'pdftotext -q -nopgbrk -raw %s -' % ('%s_ocr.pdf' % f_path)
        (_out,_err)                 =   sub_popen(cmd,stdout=sub_PIPE,shell=True).communicate()
        assert _err is None
        if _out:
            TD["new"]["_content"] = _out
        return TD["new"]

    def upd_db(TD,orig):
        T = TD["new"]
        _repl = ' '.join(['%s=%s,' % (it,'%('+it+')s') for it in T.keys() if T[it]!=orig[it]])
        qry = "update file_idx set "+_repl[:-1]+' where uid='+str(T['uid'])
#         plpy.log(qry % T)
        plpy.execute(qry % T)
    
    try:
        orig = dict(zip(TD["new"].keys(),TD["new"].values()))
        base_dir = '/home/ub2/ARCHIVE/gmail_attachments/'
        f_key = TD["new"]["_key"]
        f_name = f_key
        f_path = base_dir + f_name
        f_type = TD["new"]["_filetype"]
        f_meta = TD["new"]["_metadata"]
        f_ocr = TD["new"]["_run_ocr"]

        # FIRST PASS -- ATTEMPT TO EXTRACT
        if f_type=='pdf' and not f_meta:
#             plpy.log("FIRST_PASS")
            TD["new"] = upd_pdf(f_path)
            if TD["new"]["_run_ocr"]==True:

                cmd = [ 'echo "GET /send?uuid=%s' % f_key,
                        '&filename=%s' % f_name,
                        '&filepath=%s' % f_path,
                        '" | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock,shut-down'
                        ]
                (_out,_err) = sub_popen(''.join(cmd),stdout=sub_PIPE,shell=True).communicate()
                assert _err is None


        # SECOND PASS -- EXTRACT FROM OCR PDF
        elif f_meta and not f_ocr:
#             plpy.log("SECOND_PASS")
            TD["new"] = upd_from_ocr_pdf(f_path)

        if TD["new"]!=orig:
            upd_db(TD,orig)

    except plpy.SPIError:
        plpy.log('fps_gmail_update FAILED')
        plpy.log(tb_format_exc())
        plpy.log(sys_exc_info()[0])
        return


$BODY$
LANGUAGE plpythonu;