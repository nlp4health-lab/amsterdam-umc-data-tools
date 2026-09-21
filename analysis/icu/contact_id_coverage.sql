-- =============================================================================
-- ICU COHORT — patient_contact_id COVERAGE CHECK
-- =============================================================================
-- Question: for ICU patients, how many records in each table carry a
-- patient_contact_id, and of those, how many actually resolve to a row
-- in patient_contact (i.e. are usable for contact-level joins)?
--
-- This tells you whether contact_id is a viable secondary join key
-- for ICU-specific analyses, beyond the pseudo_id + date window approach.
--
-- Three numbers per table:
--   total_rows          = all rows for ICU patients
--   rows_with_contact   = rows where patient_contact_id is not null/empty
--   rows_contact_valid  = rows where contact_id exists in patient_contact
--   valid_pct           = % of rows_with_contact that are valid
-- =============================================================================

\pset format csv
\pset tuples_only off
\set ON_ERROR_CONTINUE on

\o /net/beegfs/users/P014993/results-icu/contact_id_coverage.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL
    AND end_date_time   > start_date_time
)

SELECT source_table, total_rows, rows_with_contact_id,
       rows_contact_valid,
       ROUND(100.0 * rows_with_contact_id / NULLIF(total_rows, 0), 1)       AS pct_has_contact_id,
       ROUND(100.0 * rows_contact_valid   / NULLIF(rows_with_contact_id, 0), 1) AS pct_contact_valid
FROM (

    -- admission_traject
    SELECT 'admission_traject' AS source_table,
        COUNT(*)                                                             AS total_rows,
        COUNT(*) FILTER (WHERE at_.patient_contact_id IS NOT NULL
                           AND at_.patient_contact_id <> '')                AS rows_with_contact_id,
        COUNT(*) FILTER (WHERE at_.patient_contact_id IS NOT NULL
                           AND at_.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = at_.patient_contact_id)) AS rows_contact_valid
    FROM amc_core.admission_traject at_
    INNER JOIN icu_patients ip ON at_.pseudo_id = ip.pseudo_id

    UNION ALL

    -- admission_partial_traject (the ICU ward stays themselves)
    SELECT 'admission_partial_traject',
        COUNT(*),
        COUNT(*) FILTER (WHERE apt.patient_contact_id IS NOT NULL AND apt.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE apt.patient_contact_id IS NOT NULL AND apt.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = apt.patient_contact_id))
    FROM amc_core.admission_partial_traject apt
    INNER JOIN icu_patients ip ON apt.pseudo_id = ip.pseudo_id

    UNION ALL

    -- medical_diagnosis (known 36% orphan globally — check ICU subset)
    SELECT 'medical_diagnosis',
        COUNT(*),
        COUNT(*) FILTER (WHERE md.patient_contact_id IS NOT NULL AND md.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE md.patient_contact_id IS NOT NULL AND md.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = md.patient_contact_id))
    FROM amc_core.medical_diagnosis md
    INNER JOIN icu_patients ip ON md.pseudo_id = ip.pseudo_id

    UNION ALL

    -- medication_prescription
    SELECT 'medication_prescription',
        COUNT(*),
        COUNT(*) FILTER (WHERE mp.patient_contact_id IS NOT NULL AND mp.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mp.patient_contact_id IS NOT NULL AND mp.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mp.patient_contact_id))
    FROM amc_core.medication_prescription mp
    INNER JOIN icu_patients ip ON mp.pseudo_id = ip.pseudo_id

    UNION ALL

    -- medication_administration
    SELECT 'medication_administration',
        COUNT(*),
        COUNT(*) FILTER (WHERE ma.patient_contact_id IS NOT NULL AND ma.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE ma.patient_contact_id IS NOT NULL AND ma.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = ma.patient_contact_id))
    FROM amc_core.medication_administration ma
    INNER JOIN icu_patients ip ON ma.pseudo_id = ip.pseudo_id

    UNION ALL

    -- procedures (known 46% null globally)
    SELECT 'procedures',
        COUNT(*),
        COUNT(*) FILTER (WHERE pr.patient_contact_id IS NOT NULL AND pr.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE pr.patient_contact_id IS NOT NULL AND pr.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = pr.patient_contact_id))
    FROM amc_core.procedures pr
    INNER JOIN icu_patients ip ON pr.pseudo_id = ip.pseudo_id

    UNION ALL

    -- lab_result (no patient_contact_id column — pseudo_id + date only)
    -- included as a reference row to confirm
    SELECT 'lab_result (no contact_id column)',
        COUNT(*), 0, 0
    FROM amc_core.lab_result lr
    INNER JOIN icu_patients ip ON lr.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_blood_pressure
    SELECT 'measurement_blood_pressure',
        COUNT(*),
        COUNT(*) FILTER (WHERE mbp.patient_contact_id IS NOT NULL AND mbp.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mbp.patient_contact_id IS NOT NULL AND mbp.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mbp.patient_contact_id))
    FROM amc_core.measurement_blood_pressure mbp
    INNER JOIN icu_patients ip ON mbp.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_heart_frequency
    SELECT 'measurement_heart_frequency',
        COUNT(*),
        COUNT(*) FILTER (WHERE mhf.patient_contact_id IS NOT NULL AND mhf.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mhf.patient_contact_id IS NOT NULL AND mhf.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mhf.patient_contact_id))
    FROM amc_core.measurement_heart_frequency mhf
    INNER JOIN icu_patients ip ON mhf.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_o2_saturation
    SELECT 'measurement_o2_saturation',
        COUNT(*),
        COUNT(*) FILTER (WHERE mo2.patient_contact_id IS NOT NULL AND mo2.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mo2.patient_contact_id IS NOT NULL AND mo2.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mo2.patient_contact_id))
    FROM amc_core.measurement_o2_saturation mo2
    INNER JOIN icu_patients ip ON mo2.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_vital_signs_data
    SELECT 'measurement_vital_signs_data',
        COUNT(*),
        COUNT(*) FILTER (WHERE vs.patient_contact_id IS NOT NULL AND vs.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE vs.patient_contact_id IS NOT NULL AND vs.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = vs.patient_contact_id))
    FROM amc_core.measurement_vital_signs_data vs
    INNER JOIN icu_patients ip ON vs.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_bmi
    SELECT 'measurement_bmi',
        COUNT(*),
        COUNT(*) FILTER (WHERE mb.patient_contact_id IS NOT NULL AND mb.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mb.patient_contact_id IS NOT NULL AND mb.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mb.patient_contact_id))
    FROM amc_core.measurement_bmi mb
    INNER JOIN icu_patients ip ON mb.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_diurese
    SELECT 'measurement_diurese',
        COUNT(*),
        COUNT(*) FILTER (WHERE md.patient_contact_id IS NOT NULL AND md.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE md.patient_contact_id IS NOT NULL AND md.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = md.patient_contact_id))
    FROM amc_core.measurement_diurese md
    INNER JOIN icu_patients ip ON md.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_fluid_in
    SELECT 'measurement_fluid_in',
        COUNT(*),
        COUNT(*) FILTER (WHERE mfi.patient_contact_id IS NOT NULL AND mfi.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mfi.patient_contact_id IS NOT NULL AND mfi.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mfi.patient_contact_id))
    FROM amc_core.measurement_fluid_in mfi
    INNER JOIN icu_patients ip ON mfi.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_fluid_balance_out
    SELECT 'measurement_fluid_balance_out',
        COUNT(*),
        COUNT(*) FILTER (WHERE mfo.patient_contact_id IS NOT NULL AND mfo.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE mfo.patient_contact_id IS NOT NULL AND mfo.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = mfo.patient_contact_id))
    FROM amc_core.measurement_fluid_balance_out mfo
    INNER JOIN icu_patients ip ON mfo.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_nephrology_cnvt_settings
    SELECT 'measurement_nephrology_cnvt_settings',
        COUNT(*),
        COUNT(*) FILTER (WHERE nc.patient_contact_id IS NOT NULL AND nc.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE nc.patient_contact_id IS NOT NULL AND nc.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = nc.patient_contact_id))
    FROM amc_core.measurement_nephrology_cnvt_settings nc
    INNER JOIN icu_patients ip ON nc.pseudo_id = ip.pseudo_id

    UNION ALL

    -- measurement_doss_score
    SELECT 'measurement_doss_score',
        COUNT(*),
        COUNT(*) FILTER (WHERE ds.patient_contact_id IS NOT NULL AND ds.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE ds.patient_contact_id IS NOT NULL AND ds.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = ds.patient_contact_id))
    FROM amc_core.measurement_doss_score ds
    INNER JOIN icu_patients ip ON ds.pseudo_id = ip.pseudo_id

    UNION ALL

    -- patient_note_patient_contact
    SELECT 'patient_note_patient_contact',
        COUNT(*),
        COUNT(*) FILTER (WHERE nn.patient_contact_id IS NOT NULL AND nn.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE nn.patient_contact_id IS NOT NULL AND nn.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = nn.patient_contact_id))
    FROM amc_core.patient_note_patient_contact nn
    INNER JOIN icu_patients ip ON nn.pseudo_id = ip.pseudo_id

    UNION ALL

    -- imaging_study_order
    SELECT 'imaging_study_order',
        COUNT(*),
        COUNT(*) FILTER (WHERE iso.patient_contact_id IS NOT NULL AND iso.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE iso.patient_contact_id IS NOT NULL AND iso.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = iso.patient_contact_id))
    FROM amc_core.imaging_study_order iso
    INNER JOIN icu_patients ip ON iso.pseudo_id = ip.pseudo_id

    UNION ALL

    -- ic_procedure_note_bronchoscopy
    SELECT 'ic_procedure_note_bronchoscopy',
        COUNT(*),
        COUNT(*) FILTER (WHERE icb.patient_contact_id IS NOT NULL AND icb.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE icb.patient_contact_id IS NOT NULL AND icb.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = icb.patient_contact_id))
    FROM amc_core.ic_procedure_note_bronchoscopy icb
    INNER JOIN icu_patients ip ON icb.pseudo_id = ip.pseudo_id

    UNION ALL

    -- ic_procedure_note_intubation
    SELECT 'ic_procedure_note_intubation',
        COUNT(*),
        COUNT(*) FILTER (WHERE ici.patient_contact_id IS NOT NULL AND ici.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE ici.patient_contact_id IS NOT NULL AND ici.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = ici.patient_contact_id))
    FROM amc_core.ic_procedure_note_intubation ici
    INNER JOIN icu_patients ip ON ici.pseudo_id = ip.pseudo_id

    UNION ALL

    -- ic_procedure_note_icarus
    SELECT 'ic_procedure_note_icarus',
        COUNT(*),
        COUNT(*) FILTER (WHERE icr.patient_contact_id IS NOT NULL AND icr.patient_contact_id <> ''),
        COUNT(*) FILTER (WHERE icr.patient_contact_id IS NOT NULL AND icr.patient_contact_id <> ''
                           AND EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                                       WHERE pc.patient_contact_id = icr.patient_contact_id))
    FROM amc_core.ic_procedure_note_icarus icr
    INNER JOIN icu_patients ip ON icr.pseudo_id = ip.pseudo_id

) sub
ORDER BY pct_contact_valid DESC NULLS LAST;

\o
\echo 'Done. Check contact_id_coverage.csv'
