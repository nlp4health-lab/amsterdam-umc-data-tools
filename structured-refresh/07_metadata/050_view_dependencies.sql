DROP TABLE IF EXISTS meta.view_dependencies CASCADE;

CREATE TABLE meta.view_dependencies (
    view_schema     text NOT NULL DEFAULT 'public',
    view_name       text NOT NULL,
    source_schema   text NOT NULL DEFAULT 'public',
    source_table    text NOT NULL,

    PRIMARY KEY (view_schema, view_name, source_schema, source_table)
);

INSERT INTO meta.view_dependencies (view_schema, view_name, source_schema, source_table)
SELECT view_schema, view_name, table_schema, table_name
FROM information_schema.view_table_usage
ON CONFLICT DO NOTHING;
