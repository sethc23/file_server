CREATE OR REPLACE FUNCTION fs_es_file_idx_insert()
  RETURNS trigger AS
$BODY$

        local cj = require"cjson"
        require"pl"
        local df = Date.Format()

        _t=trigger
        
        local d = {}
        local _uid = ""
        for k,v in pairs(_t.relation["attributes"]) do
            d[k]=tostring(_t.row[k])
            if k=="uid" then _uid=tostring(_t.row[k]) end
            if k=="last_updated" then
                local d_str = tostring(_t.row[k])
                local dt = df:parse(d_str)        
                d[k]=tostring(dt.time)
            end
        end
        local tbl_name = _t.relation["name"]
        log(tbl_name)
            
        local cmd = [[echo 'GET /json?file_idx=]] .. cj.encode(d) ..
                      "&uid=" .. _uid .. [[' | socat - tcp:0.0.0.0:12501,reuseaddr,nonblock]]
        os.execute("echo '"..cmd.."' >> /tmp/tmp")
        os.execute(cmd)

$BODY$
LANGUAGE plluau;