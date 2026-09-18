-- The \copy paths below (/net/beegfs/groups/care-nlp-db/carenlp/scripts/*.csv)
-- are reachable from inside the Apptainer container psql runs in (confirmed
-- 2026-09-04 -- that whole tree is accessible regardless of $CSV_HOST/the
-- refresh.sh bind mounts), so these load correctly as absolute paths.

DROP TABLE IF EXISTS meta.name_mapping CASCADE;

CREATE TABLE meta.name_mapping (
    entity_type      text NOT NULL,
    original_name    text NOT NULL,
    translated_name  text NOT NULL,
    note             text,
    PRIMARY KEY (entity_type, original_name)
);

-- Load table names: set the default, copy, then drop the default again
ALTER TABLE meta.name_mapping ALTER COLUMN entity_type SET DEFAULT 'table';

\copy meta.name_mapping (original_name, translated_name) FROM '/net/beegfs/groups/care-nlp-db/carenlp/scripts/file_name_mapping-copy.csv' WITH (FORMAT csv, HEADER true)

-- Load column names: same trick, different default
ALTER TABLE meta.name_mapping ALTER COLUMN entity_type SET DEFAULT 'column';

\copy meta.name_mapping (original_name, translated_name, note) FROM '/net/beegfs/groups/care-nlp-db/carenlp/scripts/column_mapping.csv' WITH (FORMAT csv, HEADER true)

ALTER TABLE meta.name_mapping ALTER COLUMN entity_type DROP DEFAULT;
