-- \copy paths below are /csv/*.csv -- refresh.sh binds $CSV_HOST
-- (/net/beegfs/groups/care-nlp-db/carenlp/scripts) at /csv inside the
-- Apptainer container; the full host path is NOT otherwise reachable
-- from in there (confirmed 2026-09-24 -- a prior 2026-09-04 note here
-- claiming the whole tree was reachable regardless of binds was wrong,
-- or the cluster's Apptainer config changed since). These CSVs live in
-- that same $CSV_HOST folder.

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

\copy meta.name_mapping (original_name, translated_name) FROM '/csv/file_name_mapping-copy.csv' WITH (FORMAT csv, HEADER true)

-- Load column names: same trick, different default
ALTER TABLE meta.name_mapping ALTER COLUMN entity_type SET DEFAULT 'column';

\copy meta.name_mapping (original_name, translated_name, note) FROM '/csv/column_mapping.csv' WITH (FORMAT csv, HEADER true)

ALTER TABLE meta.name_mapping ALTER COLUMN entity_type DROP DEFAULT;
