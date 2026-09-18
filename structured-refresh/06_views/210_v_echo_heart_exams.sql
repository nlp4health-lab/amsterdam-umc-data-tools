DROP VIEW IF EXISTS amc_views.v_echo_heart_exams;

CREATE VIEW amc_views.v_echo_heart_exams AS

SELECT
    e.pseudo_id,
    e.probable_contact_id AS patient_contact_id,
    e.probable_partial_traject_id,
    e.id::text AS echo_exam_id,
    e.accession_number,

    e.examination_date::timestamptz AS examination_datetime,
    e.examination_date,
    e.end_time_of_examination,

    e.examination_type,
    e.examination_status,
    e.indication,
    e.summary,
    e.other,

    e.hospital_location,

    e.bmi,
    e.bsa,

    e.lvef_out_summary,

    e.source,
    e.dcm_refreshed_date_time,
    e.issue_dt,

    'echo_measurement_heart_center_extra_check' AS source_table

-- echo_measurement_heart was retired in favor of this table when its CSV
-- disappeared from the source extract (2026-09-11) -- every column this
-- view uses exists here under the same name; see
-- archive/580_echo_measurement_heart.sql for the retired definition.
FROM amc_core.echo_measurement_heart_center_extra_check e;
