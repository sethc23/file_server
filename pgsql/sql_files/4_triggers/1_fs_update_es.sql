CREATE OR REPLACE FUNCTION fs_update_es()
    RETURNS trigger AS
    $BODY$
    #!/bin/bash

    /home/ub2/SERVER2/file_server/ws_elasticsearch.bash "$@"

    $BODY$
    LANGUAGE plshu;

CREATE TRIGGER copy_gmail_update_to_es
    BEFORE UPDATE ON gmail
    FOR EACH ROW
    WHEN (      OLD.orig_msg IS DISTINCT FROM NEW.orig_msg
          OR    OLD.all_mail_uid IS DISTINCT FROM NEW.all_mail_uid
          OR    OLD.g_msg_id IS DISTINCT FROM NEW.g_msg_id
          OR    OLD.msg_id IS DISTINCT FROM NEW.msg_id)
    EXECUTE PROCEDURE fs_update_es();
    
CREATE TRIGGER copy_gmail_insert_to_es
    BEFORE INSERT ON gmail
    FOR EACH ROW
    EXECUTE PROCEDURE fs_update_es();

CREATE TRIGGER copy_file_idx_update_to_es
    BEFORE UPDATE ON file_idx
    FOR EACH ROW
    WHEN (      OLD.src_db IS DISTINCT FROM NEW.src_db
          OR    OLD.src_uid IS DISTINCT FROM NEW.src_uid
          OR    OLD._key IS DISTINCT FROM NEW._key
          OR    OLD._filetype IS DISTINCT FROM NEW._filetype
          OR    OLD._info IS DISTINCT FROM NEW._info
          OR    OLD._run_ocr IS DISTINCT FROM NEW._run_ocr
          OR    OLD._metadata IS DISTINCT FROM NEW._metadata
          OR    OLD._content IS DISTINCT FROM NEW._content
         )
    EXECUTE PROCEDURE fs_update_es();
    
CREATE TRIGGER copy_file_idx_insert_to_es
    BEFORE INSERT ON file_idx
    FOR EACH ROW
    EXECUTE PROCEDURE fs_update_es();
