--------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_medications;

CREATE VIEW amc_views.v_icu_medications AS

SELECT
    m.*
FROM amc_views.v_medications m
WHERE EXISTS (
    SELECT 1
    FROM amc_views.v_icu_stays icu
    WHERE icu.pseudo_id = m.pseudo_id
);
