----------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_imaging_study_orders;

CREATE VIEW amc_views.v_imaging_study_orders AS

SELECT
    iso.pseudo_id,
    iso.patient_contact_id,

    iso.imaging_study_order_id::text AS imaging_event_id,
    iso.accession_number,

    iso.start_moment AS imaging_start_datetime,
    iso.end_moment AS imaging_end_datetime,
    iso.final_report_date_time,

    iso.imaging_study_status,
    iso.is_cancelled,

    iso.order_assignment,
    iso.requesting_workplace,
    iso.executive_workplace,

    iso.hospital_location_code,
    iso.hospital_location,

    iso.source,
    'imaging_study_order' AS source_table

FROM amc_core.imaging_study_order iso;
