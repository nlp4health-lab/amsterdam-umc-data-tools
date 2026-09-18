-----------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_scores;

CREATE VIEW amc_views.v_scores AS

SELECT
    cs.pseudo_id,
    cs.patient_contact_id,
    cs.measurement_moment::timestamptz AS score_datetime,
    cs.meet_date,
    cs.meet_time,
    'CHA2DS2-VASc' AS score_name,
    cs.chadsvasc_score AS score_value,
    NULL::text AS score_category,
    cs.hospital_location,
    'measurement_chadsvasc_score' AS source_table,
    'chadsvasc_score' AS source_column
FROM amc_core.measurement_chadsvasc_score cs
WHERE cs.chadsvasc_score IS NOT NULL

UNION ALL

SELECT
    ds.pseudo_id,
    ds.patient_contact_id,
    ds.measurement_moment::timestamptz AS score_datetime,
    ds.meet_date,
    ds.meet_time,
    'DOSS total' AS score_name,
    ds.dos_total AS score_value,
    NULL::text AS score_category,
    ds.hospital_location,
    'measurement_doss_score' AS source_table,
    'dos_total' AS source_column
FROM amc_core.measurement_doss_score ds
WHERE ds.dos_total IS NOT NULL

UNION ALL

SELECT
    ds.pseudo_id,
    ds.patient_contact_id,
    ds.measurement_moment::timestamptz AS score_datetime,
    ds.meet_date,
    ds.meet_time,
    'DOSS average 24h' AS score_name,
    ds.doss_average24h AS score_value,
    NULL::text AS score_category,
    ds.hospital_location,
    'measurement_doss_score' AS source_table,
    'doss_average24h' AS source_column
FROM amc_core.measurement_doss_score ds
WHERE ds.doss_average24h IS NOT NULL

UNION ALL

SELECT
    ds.pseudo_id,
    ds.patient_contact_id,
    ds.measurement_moment::timestamptz AS score_datetime,
    ds.meet_date,
    ds.meet_time,
    'DOSS average 24h 07:30-07:30' AS score_name,
    ds.doss_average24uur0730to0730 AS score_value,
    NULL::text AS score_category,
    ds.hospital_location,
    'measurement_doss_score' AS source_table,
    'doss_average24uur0730to0730' AS source_column
FROM amc_core.measurement_doss_score ds
WHERE ds.doss_average24uur0730to0730 IS NOT NULL

UNION ALL

SELECT
    ss.pseudo_id,
    ss.patient_contact_id,
    ss.measurement_moment::timestamptz AS score_datetime,
    ss.meet_date,
    ss.meet_time,
    'SNAQ' AS score_name,
    ss.score AS score_value,
    NULL::text AS score_category,
    ss.hospital_location,
    'measurement_snaq_score' AS source_table,
    'score' AS source_column
FROM amc_core.measurement_snaq_score ss
WHERE ss.score IS NOT NULL;
