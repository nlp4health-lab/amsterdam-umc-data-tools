---------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_notes;

-- patient_note_contains_sensitive_information was retired (2026-09-11
-- extract: its CSV is gone from the source, confirmed no replacement) --
-- this view's has_sensitive_information_flag column, which used to read
-- from it, was removed along with it; see
-- archive/460_patient_note_contains_sensitive_information.sql for the
-- retired definition.
CREATE VIEW amc_views.v_notes AS

SELECT
    n.pseudo_id,
    n.patient_note_id,

    pnpc.patient_contact_id,
    pnpc.note_contact_id,
    pnpc.note_contact_sequential_number,

    n.date_note,
    pnpc.note_made_at_date_time AS note_datetime,
    pnpc.note_file_time_local_dttm,
    pnpc.entry_instant_local_dttm,

    n.patient_note_category,
    pnpc.patient_contact_patient_note_category,
    pnpc.note_status,
    pnpc.is_confidential,

    n.caregiver_type,
    pnpc.healthcare_provider_specialty,
    pnpc.healthcare_provider_sub_specialty,

    pnpc.hospital_location,
    pnpc.hospital_location_code,

    m.char_length,
    m.word_length,
    m.token_length,
    m.source_file,

    n.note_text

FROM amc_core.amc_notes n

LEFT JOIN amc_core.amc_notes_metadata m
    ON m.note_id = n.patient_note_id

LEFT JOIN amc_core.patient_note_patient_contact pnpc
    ON pnpc.patient_note_id = n.patient_note_id;
