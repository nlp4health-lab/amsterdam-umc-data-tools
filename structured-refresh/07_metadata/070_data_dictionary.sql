DROP TABLE IF EXISTS meta.data_dictionary CASCADE;

CREATE TABLE meta.data_dictionary (
    table_name      text NOT NULL,
    column_name     text NOT NULL,
    data_type       text,
    is_primary_key  boolean DEFAULT false,
    "references"    text,
    description     text,
    PRIMARY KEY (table_name, column_name)
);

COMMENT ON TABLE meta.data_dictionary IS 'Column-level data dictionary: table name, column name, data type, primary-key flag, FK reference (schema.table(column), blank if none), and a short description for every column across amc_core.';

\copy meta.data_dictionary (table_name, column_name, data_type, is_primary_key, "references", description) FROM '/csv/data_dictionary.csv' WITH (FORMAT csv, HEADER true)

-- quick check
SELECT count(*) AS rows_loaded FROM meta.data_dictionary;
