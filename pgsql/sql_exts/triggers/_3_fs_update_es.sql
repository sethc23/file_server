CREATE OR REPLACE FUNCTION fs_update_es()
  RETURNS trigger AS
$BODY$
#!/bin/bash

/home/ub2/SERVER2/file_server/ws_elasticsearch.bash "$@"
    
$BODY$
LANGUAGE plsh;