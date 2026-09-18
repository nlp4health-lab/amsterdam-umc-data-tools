DROP TABLE IF EXISTS meta.data_dictionary CASCADE;

CREATE TABLE meta.data_dictionary (
    table_name    text NOT NULL,
    column_name   text NOT NULL,
    data_type     text,
    description   text,
    PRIMARY KEY (table_name, column_name)
);

COMMENT ON TABLE meta.data_dictionary IS 'Column-level data dictionary: table name, column name, data type, and a short description for every column across amc_core.';

-- ---------------------------------------------------------------------
-- Load. The original script's path (/data/data_dictionary.csv) was wrong --
-- the CSV actually lives alongside the other 07_metadata CSVs (confirmed
-- 2026-09-04 via a real directory listing on the cluster:
-- /net/beegfs/groups/care-nlp-db/carenlp/scripts/), same tree
-- 060_name_mapping.sql already loads from and confirmed reachable inside
-- the Apptainer container regardless of $CSV_HOST/refresh.sh's bind mounts.
-- ---------------------------------------------------------------------
\copy meta.data_dictionary (table_name, column_name, data_type, description) FROM '/net/beegfs/groups/care-nlp-db/carenlp/scripts/data_dictionary.csv' WITH (FORMAT csv, HEADER true)

-- quick check
SELECT count(*) AS rows_loaded FROM meta.data_dictionary;
