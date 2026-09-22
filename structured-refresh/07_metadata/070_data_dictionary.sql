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
-- Load. The original script's path (/data/data_dictionary.csv) was wrong --
-- the CSV actually lives alongside the other 07_metadata CSVs (confirmed
-- 2026-09-04 via a real directory listing on the cluster:
-- /net/beegfs/groups/care-nlp-db/carenlp/scripts/), same tree
-- 060_name_mapping.sql already loads from and confirmed reachable inside
-- the Apptainer container regardless of $CSV_HOST/refresh.sh's bind mounts.
--
-- CSV gained is_primary_key/references columns 2026-09-22 (full recheck
-- against the live schema: types, retired/renamed tables and columns,
-- keys). Re-upload the updated CSV to that cluster path before this
-- script is next run there.
-- ---------------------------------------------------------------------
\copy meta.data_dictionary (table_name, column_name, data_type, is_primary_key, "references", description) FROM '/net/beegfs/groups/care-nlp-db/carenlp/scripts/data_dictionary.csv' WITH (FORMAT csv, HEADER true)

-- quick check
SELECT count(*) AS rows_loaded FROM meta.data_dictionary;
