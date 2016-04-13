CREATE OR REPLACE FUNCTION zf_queue_ocr(text)
  RETURNS text AS
$BODY$
#!/bin/bash
echo "printf 'working_RIGHT?' | socat - udp-sendto:0.0.0.0:32191" | batch
atq
$BODY$
  LANGUAGE plsh;