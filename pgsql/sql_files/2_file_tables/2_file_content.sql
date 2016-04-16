-- DROP TABLE IF EXISTS file_content;

CREATE TABLE file_content (
    src_db              TEXT,
    src_uid             INTEGER,
    pg_num              INTEGER
    plain_text          TEXT,
    html_text           TEXT
);