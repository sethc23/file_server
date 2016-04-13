CREATE OR REPLACE FUNCTION zf_pdftotext(text)
  RETURNS text AS
$BODY$
#!/bin/bash
pdftotext -q -nopgbrk $1 -
$BODY$
LANGUAGE PLSHU;

-- "/home/ub2/SERVER2/file_server/2ac6b14a-bc70-41f2-aaf2-bb5879e83dd11"

CREATE OR REPLACE FUNCTION zf_readfile(fpath text) 
    RETURNS text AS $BODY$
    with open(fpath,'r') as f: return f.read()
    $BODY$ LANGUAGE PLPYTHONU;