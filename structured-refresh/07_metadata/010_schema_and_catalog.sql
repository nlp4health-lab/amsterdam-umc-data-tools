-- metadata schema and tables
CREATE SCHEMA IF NOT EXISTS meta;

DROP TABLE IF EXISTS meta.catalog CASCADE;

CREATE TABLE meta.catalog (
    schema_name              text NOT NULL DEFAULT 'public',
    object_name               text NOT NULL,
    object_type               text NOT NULL CHECK (object_type IN ('table','view')),
    description                text,
    possible_uses              text,
    identifier_columns         text[]  DEFAULT '{}',
    has_standardized_codes     boolean DEFAULT false,
    code_systems                text,
    date_columns                jsonb   DEFAULT '[]',
    known_issues                text,
    join_recommendations        text,
    last_reviewed_at            date,
    primary_key                 text[],
    PRIMARY KEY (schema_name, object_name)
);

INSERT INTO meta.catalog (schema_name, object_name, object_type)
SELECT
    table_schema,
    table_name,
    CASE table_type
        WHEN 'VIEW' THEN 'view'
        ELSE 'table'
    END
FROM information_schema.tables
WHERE table_schema IN ('amc_core', 'amc_views')
ON CONFLICT (schema_name, object_name) DO NOTHING;

-- Quick check: see what just got registered vs. what's still undocumented
SELECT
    object_type,
    object_name,
    description IS NOT NULL AS has_description
FROM meta.catalog
ORDER BY object_type, object_name;
