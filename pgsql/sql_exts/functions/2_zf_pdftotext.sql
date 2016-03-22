CREATE OR REPLACE FUNCTION zf_pdftotext(text)
  RETURNS text AS
$BODY$
#!/bin/bash
pdftotext -q -nopgbrk $1 -
$BODY$
LANGUAGE PLSHU;