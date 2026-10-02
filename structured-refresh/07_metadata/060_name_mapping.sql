-- \copy paths below are /csv/*.csv -- refresh.sh binds $CSV_HOST


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
