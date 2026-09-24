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

-- ---------------------------------------------------------------------
-- Load. The CSV lives alongside the other 07_metadata CSVs
-- (/net/beegfs/groups/care-nlp-db/carenlp/scripts/, i.e. $CSV_HOST),
-- same folder 060_name_mapping.sql loads from. refresh.sh binds that
-- folder at /csv inside the Apptainer container -- the full host path
-- is NOT otherwise reachable from in there (a prior note here claiming
-- it was, "regardless of binds", was wrong -- confirmed 2026-09-24 via
-- a real failed run: 060's identical absolute-path \copy errored with
-- "No such file or directory" even though the file exists at that path
-- on the host).
--
-- CSV gained is_primary_key/references columns 2026-09-22 (full recheck
-- against the live schema: types, retired/renamed tables and columns,
-- keys). Re-upload the updated CSV to that cluster path before this
-- script is next run there.
-- ---------------------------------------------------------------------
\copy meta.data_dictionary (table_name, column_name, data_type, is_primary_key, "references", description) FROM '/csv/data_dictionary.csv' WITH (FORMAT csv, HEADER true)

-- quick check
SELECT count(*) AS rows_loaded FROM meta.data_dictionary;
