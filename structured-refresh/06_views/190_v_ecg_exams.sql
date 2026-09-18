DROP VIEW IF EXISTS amc_views.v_ecg_exams;

CREATE VIEW amc_views.v_ecg_exams AS

SELECT
    e.pseudo_id,
    e.probable_contact_id AS patient_contact_id,
    e.probable_partial_traject_id,

    e.ecg_measurement_id,

    COALESCE(
        f.ecg_decrease_date_time,
        e.ecg_decrease_date_time
    ) AS ecg_datetime,

    COALESCE(
        f.ecg_decrease_date,
        e.ecg_decrease_date
    ) AS ecg_date,

    COALESCE(
        f.ecg_decrease_time,
        e.ecg_decrease_time
    ) AS ecg_time,

    f.ecg_change_date_time,

    f.test_code,
    f.site_code,

    f.test_status,
    f.test_status_code,
    f.test_status_abbreviation,

    f.test_type_description,
    f.test_type_code,
    f.test_type_abbreviation,

    f.priority,
    f.priority_code,
    f.priority_abbreviation,

    COALESCE(f.workplace_muse, e.workplace_muse) AS workplace_muse,
    f.workplace_muse_abbreviation,
    f.workplace_muse_code,

    f.ecg_cartnumber,
    f.ecg_decrease_device,
    f.ecg_decrease_software_version,
    f.ecg_analysis_software_version,

    e.source AS ecg_measurement_source,
    f.source AS ecg_test_feature_source,

    e.dcm_refreshed_date_time,
    COALESCE(f.issue_dt, e.issue_dt) AS issue_dt,

    'ecg_measurement' AS source_table

FROM amc_core.ecg_measurement e

LEFT JOIN amc_core.ecg_measurement_test_feature f
    ON f.pseudo_id = e.pseudo_id
   AND f.ecg_measurement_id = e.ecg_measurement_id;
