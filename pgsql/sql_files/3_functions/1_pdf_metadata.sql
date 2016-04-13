-- DROP FUNCTION IF EXISTS zf_pdf_metadata( TEXT ) CASCADE;
CREATE FUNCTION zf_pdf_metadata( text )
RETURNS TEXT as E'
#!/bin/bash
pdfinfo -meta $1 | jq -s -R -c -M -j \\'[ splits("\n")? | split(":") as $i | 
{ ($i[0]?) : ( $i[1] | sub("( )+"; ""; "sl") ) } ]\\'
' LANGUAGE PLSHU;