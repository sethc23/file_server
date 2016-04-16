
-- 2. AFTER gmail INSERT/UPDATE, UPDATE file_idx

CREATE OR REPLACE FUNCTION update_file_idx_on_gmail_insert_update()
    RETURNS TRIGGER AS $funct$

    from subprocess import Popen as sub_popen
    from subprocess import PIPE as sub_PIPE

    def run_cmd(cmd):
        p = sub_popen(cmd,stdout=sub_PIPE,shell=True,executable='/bin/bash')
        (_out,_err) = p.communicate()
        assert _err is None
        return _out.rstrip('\n')

    LOG_T =  'logger -i --priority info --tag "update_file_idx_on_gmail_insert_update" -- "%s"'

    run_cmd(LOG_T % "STARTING update_file_idx_on_gmail_insert_update")

    T = {'gmail_uid' : TD["new"]["uid"]}

    enumerate_attachments = """
            WITH upd AS (
                SELECT
                    'gmail' src_db,
                    uid src_uid,
                    _key,
                    REGEXP_REPLACE(((_json->_key)::JSONB->'name')::TEXT,
                                   E'"(.*)\\\\.([^\\.]+)"',
                                   E'\\\\2','g') _filetype,
                    (_json->_key)::JSONB _info
                FROM  (
                    SELECT 
                        json_object_keys(json_array_elements(_att::json)::json) _key,
                        json_array_elements(_att::json)::json _json,
                        uid
                    FROM

                        (
                        SELECT 
                            _attachments _att,uid
                        FROM (
                            SELECT 
                                orig_msg->'attachments' _attachments,
                                uid
                            FROM gmail
                            WHERE 
                            JSON_ARRAY_LENGTH((orig_msg->'attachments')::JSON) > 0
                            AND uid = %(gmail_uid)s
                        ) f1
                    ) f2
                ) f3
            )
            INSERT INTO file_idx (
                src_db,
                src_uid,
                _key,
                _filetype,
                _info
                )
            SELECT 
                u.src_db,
                u.src_uid,
                u._key,
                LOWER(u._filetype),
                u._info
            FROM 
                upd u,
                (select ARRAY_AGG(_key) all_keys FROM file_idx) s1
            WHERE all_keys IS NULL
            OR NOT u._key = ANY(all_keys);

          """ % T

    plpy.execute(enumerate_attachments)

    $funct$ 
    language "plpythonu";

CREATE TRIGGER update_file_idx_on_gmail_insert_update_trigger
    AFTER INSERT OR UPDATE
    OF orig_msg
    ON gmail
    FOR EACH ROW
    EXECUTE PROCEDURE update_file_idx_on_gmail_insert_update();
