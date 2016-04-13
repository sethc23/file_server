-- DROP TABLE IF EXISTS file_idx;

CREATE TABLE file_idx (
    src_db              TEXT,
    src_uid             INTEGER,
    _key                TEXT,
    _filetype           TEXT,
    _info               JSONB,
    _run_ocr            BOOLEAN DEFAULT FALSE,
    _metadata           JSONB
);