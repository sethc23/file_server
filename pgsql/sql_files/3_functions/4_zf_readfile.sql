CREATE OR REPLACE FUNCTION zf_readfile(fpath text) 
    RETURNS text AS $BODY$
    with open(fpath,'r') as f: return f.read()
    $BODY$ LANGUAGE PLPYTHONU;