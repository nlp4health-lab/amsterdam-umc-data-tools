----------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_labs_long;

CREATE VIEW amc_views.v_labs_long AS

SELECT
    lr.pseudo_id,
    lr.probable_contact_id AS patient_contact_id,
    lr.probable_partial_traject_id,
    lr.sample_id AS source_record_id,
    lr.result_date_time AS measurement_datetime,

    'labs' AS measurement_domain,

    lr.determination AS measurement_name,
    lr.determination_code AS measurement_code,

    lr.result_numeric AS value_numeric,
    lr.result_text AS value_text,
    lr.result_unit AS unit,

    lr.normalvalue_below,
    lr.normalvalue_upper_limit,

    lr.material_type,
    lr.sampling_location,
    lr.requesting_workplace_abbreviation AS requesting_workplace,

    'lab_result' AS source_table

FROM amc_core.lab_result lr;
