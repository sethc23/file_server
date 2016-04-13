CREATE OR REPLACE FUNCTION fs_update_file_idx_on_gmail_update() 
  RETURNS trigger AS
$BODY$

    T = {'gmail_uid' : TD["new"]["uid"]}

    enumerate_attachments = """
            WITH upd AS (
                SELECT
                    'gmail' src_db,
                    uid src_uid,
                    _key,
                    REGEXP_REPLACE(((_json->_key)::JSONB->'name')::TEXT,E'"(.*)\\\\.([^\\.]+)"',E'\\\\2','g') _filetype,
                    (_json->_key)::JSONB _info
                FROM  (
                    SELECT 
                        JSON_OBJECT_KEYS(JSON_ARRAY_ELEMENTS(_att::JSON)::JSON) _key,
                        JSON_ARRAY_ELEMENTS(_att::JSON)::JSON _json,
                        uid
                    FROM

                        (
                        SELECT 
                            _attachments _att,uid
                        FROM (
                            SELECT 
                                orig_msg->'attachments' _attachments,
                                uid
                            FROM GMAIL
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
                lower(u._filetype),
                u._info
            FROM 
                upd u,
                (SELECT ARRAY_AGG(_key) all_keys FROM file_idx) s1
            WHERE all_keys IS NULL
            OR NOT u._key = ANY(all_keys);
          """ % T
    
    plpy.execute(enumerate_attachments)
    
$BODY$
LANGUAGE plpythonu;