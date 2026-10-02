-- =====================================================================
-- populate_meta_catalog.sql  (unified)
--
-- Single, complete population script for meta.catalog: all 59 amc_core
-- tables + all 40 amc_views views (99 objects total).
--
-- primary_key values are sourced directly from core.rtf's actual
-- PRIMARY KEY constraints (single-column or composite).
--
-- Run once to create the column, then any number of times to refresh
-- =====================================================================

-- ---------------------------------------------------------------------
-- amc_core tables (59)
-- ---------------------------------------------------------------------

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_core', 'admission_partial_traject', 'table',
    'Sub-segments -subtrajects- of a hospital admission trajectory -traject- (partial legs of an admission, e.g. transfers).',
    'Reconstructing detailed subtraject movement within a single hospital admission traject. Length-of-stay analysis for specialized stays, such as ICU. To select ICU stays within a hospital admission by filtering workplace ILIKE ''%ICU%'' OR workplace ILIKE ''%INTENSIVE%''',
    ARRAY['pseudo_id','patient_contact_id','admission_partial_traject_id', 'admission_traject_id'],
    '[{"column": "admission_traject_admission_date", "is_primary": false, "note": ""}, {"column": "admission_traject_admission_date_time", "is_primary": false, "note": "hospital admission start, not subtraject "}, {"column": "admission_traject_discharge_date", "is_primary": false, "note": "0.12% with dates > 2025. Marking ongoing stays, corrected -future dates set as null- in corrected_admission_traject_discharge_date"}, {"column": "admission_traject_discharge_date_time", "is_primary": false, "note": "0.12% with dates > 2025. Marking ongoing stays, corrected -future dates set as null- in corrected_admission_traject_discharge_date_time"}, {"column": "corrected_end_date", "is_primary": false, "note": "0.02% null marking ongoing subtrajects at the time of extraction. Discharge date from the subtraject."}, {"column": "corrected_end_date_time", "is_primary": false, "note": "0.02% null marking ongoing subtrajects at the time of extraction. Discharge date time from the subtraject."}, {"column": "corrected_end_time", "is_primary": false, "note": "0.02% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "end_date", "is_primary": false, "note": "corrected; impact note: 0.03% with year after 2025 marking ongoing subtrajects at time of extraction. Corrected and future dates set as null in corrected_end_date"}, {"column": "end_date_time", "is_primary": false, "note": ""}, {"column": "end_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "start_date", "is_primary": false, "note": "start date of subtraject"}, {"column": "start_date_time", "is_primary": true, "note": "start date of subtraject. 0% nulls."}, {"column": "start_time", "is_primary": false, "note": ""},{"column": "corrected_admission_traject_discharge_date_time", "is_primary": false, "note": "corrected traject discharge date time, future dates set as null."}, {"column": "corrected_admission_traject_discharge_date", "is_primary": false, "note": "correct traject discharge date, future dates set as null."}]'::jsonb,
    'Date quality: subtraject and trajects discharge dates have some future dates indicating ongoing stays at the time of extraction. Use corrected columns. Can also check ongoing_partial_stay flag. || Known issues :  end_date: 0.02% far-future (9999-12-31) ‚open stays -> Exclude from ICU LOS calculations using the corrected columns.',
    'When there the other table can join by patient_contact_id, but with the ones that do not have it, such as the measurement tables, the join can be done by pseudo_id and start_date_time and corrected_end_date_time ranges.',
    ARRAY['admission_partial_traject_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_core', 'admission_traject', 'table',
    'One row per hospital admission trajectory (admission to discharge) per patient.',
    'Core source for admission/discharge dates and length-of-stay analysis for whole hospital stays',
    ARRAY['pseudo_id','patient_contact_id','admission_traject_id'],
    '[{"column": "admission_date", "is_primary": false, "note": ""}, {"column": "admission_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "admission_time", "is_primary": false, "note": ""}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "discharge_date", "is_primary": false, "note": "0.03% with dates > 2025. Marking ongoing stays, corrected -future dates set as null- in corrected_discharge_date"}, {"column": "discharge_moment", "is_primary": false, "note": "0.03% with dates > 2025. Marking ongoing stays, corrected -future dates set as null- in corrected_discharge_moment."}, {"column": "discharge_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""},{"column": "corrected_discharge_moment", "is_primary": false, "note": "corrected discharge date time, future dates set as null."}, {"column": "corrected_discharge_date", "is_primary": false, "note": "corrected discharge date, future dates set as null."}]'::jsonb,
    'Date quality: discharge_date: discharge dates have some future dates indicating ongoing stays at the time of extraction. Use corrected columns. Can also check ongoing_stay flag. || Known issues : patient_contact_id: contact_id not in patient_contact master table -> Use pseudo_id as primary join | discharge_date: 0.03% far-future (9999-12-31) ‚open stays -> Exclude from LOS calculations; use corrected discharge date columns.',
    'When there the other table can join by patient_contact_id, but with the ones that do not have it, such as the measurement tables, the join can be done by pseudo_id and start_date_time and corrected_end_date_time ranges.',
    ARRAY['admission_traject_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_core', 'adverse_event', 'table',
    'Registered adverse events (e.g. incidents, complications) linked to a research projects.',
    'Adverse event / patient safety reporting and incidence analysis from research projects.',
    ARRAY['pseudo_id','adverse_event_id'],
    '[{"column": "course_date", "is_primary": true, "note": "reliable, 0% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "research_project_start_date", "is_primary": false, "note": ""}, {"column": "solution_date", "is_primary": false, "note": "39.93% null."}]'::jsonb,
    'Date quality: solution_date: 39.93% null Ongoing adverse events without solution date.',
    'Join by pseudo_id and course_date range, or by patient_contact_id and course_date range.',
    ARRAY['adverse_event_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'death_registration', 'table',
    'Patient death registration records, including date/time of death on a per-known-source basis. Not reliable for survival analysis, as some deaths are not registered or are registered late.',
    'Mortality analysis estimation but use with caution, not reliable',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "date_transfer_mortuary", "is_primary": false, "note": "to correct; 65.82% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}, {"column": "time_transfer_mortuary", "is_primary": false, "note": "80.18% null"}]'::jsonb,
    'Date quality: date_transfer_mortuary: to correct; 65.82% null || Known issues : pseudo_id: Multiple death registrations per patient -> Deduplicate: DISTINCT ON (pseudo_id) ORDER BY pseudo_id, meet_date. Manually review patients with date gaps > 1 day | meet_date / admission_date: 0.74% dead patients.',
    'Join by patient_contact_id or pseudo_id and meet_date range. Use DISTINCT ON (pseudo_id) ORDER BY pseudo_id, meet_date to deduplicate multiple death registrations per patient.',
    ARRAY['patient_contact_id','meet_time']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ecg_measurement', 'table',
    'ECG -electrocardiogram- exam records (one row per ECG performed).',
    'Identifying and timing ECG exams performed for a patient.',
    ARRAY['pseudo_id', 'ecg_measurement_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "ecg_decrease_date", "is_primary": false, "note": "4% with dates before 2000"}, {"column": "ecg_decrease_date_time", "is_primary": true, "note": "4% with dates before 2000"}, {"column": "ecg_decrease_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Known issues : ecg_decrease_date: 4.04% dates pre-2000 -> min year 1996. Exclude rows by filtering by the flag abnormal_decrease_date_time.',
    'Join by pseudo_id and date ranges.',
    ARRAY['pseudo_id','ecg_measurement_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ecg_measurement_test_feature', 'table',
    'Individual measured features/parameters from an ECG exam (long format).',
    'Detailed ECG waveform/parameter analysis linked to v_ecg_measurements_long.',
    ARRAY['pseudo_id', 'ecg_measurement_id'],
    '[{"column": "ecg_change_date_time", "is_primary": false, "note": "38.87% null and 7% of abnormal_date_flag before 2000."}, {"column": "ecg_decrease_date", "is_primary": false, "note": ""}, {"column": "ecg_decrease_date_time", "is_primary": true, "note": "0% null - it has 4% abnormal_decrease_date_time before 2000. Created a flag column."}, {"column": "ecg_decrease_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Date quality: ecg_change_date_time: 38.87% null and 7% of abnormal_date_flag before 2000. || Known issues : ecg_decrease_date_time: 4.04% dates pre-2000. Exclude rows by filtering by the flag abnormal_date_flag.',
    'Join by pseudo_id and date ranges.',
    ARRAY['pseudo_id','ecg_measurement_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'echo_measurement_heart_center_extra_check', 'table',
    'Echocardiography exam records. Replaces echo_measurement_heart, retired when its CSV dropped out of the source extract (2026-09-11) -- 456 of 457 columns are identical by name; mv_e_f_slope was renamed to e_f_slope.',
    'Analyzing echo exams; sparse table.',
    ARRAY['pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "end_time_of_examination", "is_primary": false, "note": "100% null"}, {"column": "examination_date", "is_primary": false, "note": "impact note: just 1 row"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Date quality: end_time_of_examination: 100% null',
    'Join by pseudo_id and date ranges.',
    ARRAY['id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'family_history', 'table',
    'Registered family medical history entries for a patient.',
    'Hereditary/familial risk factor analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "registration_date", "is_primary": true, "note": "reliable, 0% null"}]'::jsonb,
    NULL,
    'Join by patient_contact_id or pseudo_id and registration_date range.',
    ARRAY['family_history_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_bronchoscopy', 'table',
    'ICU procedure notes specific to bronchoscopy interventions.',
    'ICU bronchoscopy procedure timing and detail lookup.',
    ARRAY['pseudo_id','patient_contact_id','order_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['patient_contact_id','order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_central_venous_catheter', 'table',
    'ICU procedure notes for central venous catheter placement.',
    'ICU CVC procedure timing, sedation start/end tracking.',
    ARRAY['pseudo_id','patient_contact_id', 'order_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "end_procedure", "is_primary": false, "note": "future dates in 1 row, corrected with flag end_procedure_quality_issue, filter out; 17.62% null"}, {"column": "end_sedation", "is_primary": false, "note": "95.78% null"}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "start_procedure", "is_primary": false, "note": "4.16% null"}, {"column": "start_sedation", "is_primary": false, "note": "92.03% null"}]'::jsonb,
    'Date quality: end_procedure: future dates in 1 row, corrected with flag end_procedure_quality_issue, filter out; 17.62% null | end_sedation: 95.78% null | start_sedation: 92.03% null',
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_electric_cardioversion', 'table',
    'ICU procedure notes for electrical cardioversion interventions.',
    'ICU cardioversion procedure timing and detail lookup.',
    ARRAY['pseudo_id','patient_contact_id', 'order_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "end_procedure", "is_primary": false, "note": "15.71% null"}, {"column": "end_sedation", "is_primary": false, "note": "76.56% null"}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "start_procedure", "is_primary": false, "note": "2.99% null"}, {"column": "start_sedation", "is_primary": false, "note": "61.85% null"}]'::jsonb,
    'Date quality: end_procedure: 15.71% null | end_sedation: 76.56% null | start_sedation: 61.85% null',
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_icarus', 'table',
    'ICU procedure notes from the ICARUS system/module (ICU ultrasound procedures notes).',
    'ICU ultrasound procedure timing and notes (ICARUS-sourced).',
    ARRAY['pseudo_id','patient_contact_id', 'order_id'],
    '[{"column": "date_time_authorization", "is_primary": false, "note": "26.27% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Date quality: date_time_authorization: 26.27% null',
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['patient_contact_id','order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_intubation', 'table',
    'ICU procedure notes for intubation interventions.',
    'ICU intubation procedure timing lookup.',
    ARRAY['pseudo_id','patient_contact_id', 'order_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;


INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_thorax_drain', 'table',
    'ICU procedure notes for thorax (chest) drain placement.',
    'ICU thorax drain procedure timing and sedation tracking.',
    ARRAY['order_id','pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "end_sedation", "is_primary": false, "note": "91.15% null"}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "start_procedure", "is_primary": false, "note": "5.13% null"}, {"column": "start_sedation", "is_primary": false, "note": "85.55% null"}]'::jsonb,
    'Date quality: end_sedation: 91.15% null | start_procedure: 5.13% null | start_sedation: 85.55% null',
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ic_procedure_note_tracheostomy', 'table',
    'ICU procedure notes for tracheostomy interventions.',
    'ICU tracheostomy procedure timing lookup.',
    ARRAY['order_id','pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "intervention_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or procedures tables.',
    ARRAY['order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'imaging_study_order', 'table',
    'Imaging study orders (radiology requests) placed for a patient.',
    'Imaging utilization analysis, order-to-exam turnaround.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "end_date", "is_primary": false, "note": "what do past dates mean?; 16.15% null"}, {"column": "end_moment", "is_primary": false, "note": "many nulls; 16.15% null"}, {"column": "end_time", "is_primary": false, "note": "pre-epic some past dates; 16.15% null"}, {"column": "final_report_date_time", "is_primary": false, "note": "13.07% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "start_date", "is_primary": false, "note": "46.58% null"}, {"column": "start_moment", "is_primary": true, "note": "46.58% null"}, {"column": "start_time", "is_primary": false, "note": "46.58% null"}]'::jsonb,
    'Date quality: end_date: past dates; 16.15% null | end_moment: many nulls; 16.15% null | end_time: pre-epic some past dates; 16.15% null | final_report_date_time: 13.07% null | start_date: 46.58% null | start_moment: 46.58% null | start_time: 46.58% null || Known issues : start_date: 8.69% dates pre-2000',
    'Join by patient_contact_id, or pseudo_id and start_moment range.',
    ARRAY['imaging_study_order_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'lab_result', 'table',
    'Individual laboratory test results (numeric and/or text), one row per result.',
    'Core source for lab-based cohort definitions, trend analysis; very high volume table.',
    ARRAY['pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "material_decrease_date", "is_primary": false, "note": ""}, {"column": "material_decrease_date_time", "is_primary": false, "note": ""}, {"column": "material_decrease_time", "is_primary": false, "note": ""}, {"column": "result_date", "is_primary": true, "note": "0.26% null"}, {"column": "result_date_time", "is_primary": false, "note": "0.26% null"}, {"column": "result_time", "is_primary": false, "note": "0.26% null"}]'::jsonb,
    'Known issues : material_decrease_date: 6.95% dates pre-2000 -> Use result_date as temporal anchor (only 0.04% abnormal) | result_date: 0.04% dates pre-2000 -> Safe to use as primary temporal anchor; filter obvious outliers if needed | result_numeric: NULL numeric result -> Use result_text for these records; not a data error | (pseudo_id, sample_id, determination_code): Duplicate natural key with different result values 0.0001% -> Flag glucose strip vs lab glucose separately. Exact duplicates safe to remove with DISTINCT |  result_date / material_decrease_date: Result date before collection date -> Safe to ignore for most analyses 0.1%',
    'Join by pseudo_id and result_date range.',
    ARRAY['lab_result_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_blood_pressure', 'table',
    'Individual blood pressure measurements (systolic/diastolic).',
    'Vital sign trend analysis; feeds v_vital_signs_long / v_icu_vital_signs_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "impact note: only 7 rows"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment','demand_observation']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_blood_pressure_average', 'table',
    'Averaged blood pressure measurements (e.g. per shift/period).',
    'Aggregated blood pressure trend analysis.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "impact note: only 1 row"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment','blood_pressure_average']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_bmi', 'table',
    'Calculated/recorded BMI measurements.',
    'Nutritional status and BMI trend analysis.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment','bmi']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_chadsvasc_score', 'table',
    'CHA2DS2-VASc stroke risk score measurements.',
    'Cardiovascular/stroke risk scoring analysis.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_diurese', 'table',
    'Diuresis (urine output) measurements.',
    'Fluid balance/renal function monitoring; feeds v_fluid_balance_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_doss_score', 'table',
    'DOSS (Delirium Observation Screening Scale) score measurements.',
    'Delirium screening / ICU cognitive status monitoring; feeds v_scores.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_fluid_assessment_diuresis', 'table',
    'Fluid balance assessment entries specific to diuresis.',
    'Fluid balance monitoring; feeds v_fluid_balance_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_fluid_balance_assessment_emesis', 'table',
    'Fluid balance assessment entries for emesis (vomiting) output.',
    'Fluid balance monitoring; feeds v_fluid_balance_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_fluid_balance_assessment_feces', 'table',
    'Fluid balance assessment entries for fecal output.',
    'Fluid balance monitoring; feeds v_fluid_balance_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_fluid_balance_out', 'table',
    'General fluid balance ''output'' measurements (all output types combined).',
    'Fluid balance monitoring; very high-volume table, feeds v_fluid_balance_long.',
    ARRAY['pseudo_id','patient_contact_id','lda_observation_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "impact note: only 7"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['measurement_moisture_out_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_fluid_balance_stomach_retention', 'table',
    'Fluid balance assessment entries for gastric/stomach retention.',
    'Fluid balance monitoring; feeds v_fluid_balance_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_fluid_in', 'table',
    'Fluid intake measurements (all input types).',
    'Fluid balance monitoring; very high-volume table, feeds v_fluid_balance_long.',
    ARRAY['pseudo_id','patient_contact_id','lda_observation_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['measurement_moisture_at_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_heart_frequency', 'table',
    'Heart rate measurements.',
    'Vital sign trend analysis; feeds v_vital_signs_long / v_icu_vital_signs_long; very high volume.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "impact note: only 5 rows"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment','heart_rate']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_height', 'table',
    'Patient height measurements.',
    'Growth/anthropometric tracking, BMI calculation input.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "maybe truly meaning that height last known"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    'Date quality: measurement_moment: maybe truly meaning that height last known',
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_nephrology_cntv_medication', 'table',
    'Medication measurements/settings during continuous nephrology treatment (CNVT/CRRT).',
    'ICU renal replacement therapy medication tracking; feeds v_nephrology_treatments.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_nephrology_cnvt_settings', 'table',
    'Device/treatment settings during continuous nephrology treatment (CNVT/CRRT).',
    'ICU renal replacement therapy settings tracking; feeds v_nephrology_treatments.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_nephrology_hemodialysis', 'table',
    'Hemodialysis session measurements.',
    'Renal replacement therapy tracking; feeds v_nephrology_treatments.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_nephrology_peritoneal_dialysis', 'table',
    'Peritoneal dialysis session measurements.',
    'Renal replacement therapy tracking; feeds v_nephrology_treatments.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_o2_saturation', 'table',
    'Oxygen saturation (SpO2) measurements.',
    'Vital sign trend analysis; feeds v_vital_signs_long / v_icu_vital_signs_long.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment','o2saturation']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_snaq_score', 'table',
    'SNAQ (Short Nutritional Assessment Questionnaire) score measurements.',
    'Nutritional risk screening analysis; feeds v_scores.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_vital_signs_data', 'table',
    'Combined/generic vital signs measurements not covered by an individual measurement table.',
    'Fallback vital signs source; feeds v_vital_signs_long together with individual tables.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "could be recovered through patient_contact"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    'Date quality: measurement_moment: could be recovered through patient_contact but not with 100% certainty. || Known issues : meet_date: 0.01% dates pre-2000',
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['measurement_vital_signs_data_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'measurement_weight', 'table',
    'Patient body weight measurements.',
    'Growth/anthropometric tracking, BMI/fluid balance calculation input.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "measurement_moment", "is_primary": true, "note": "reliable, 0% null"}, {"column": "meet_date", "is_primary": false, "note": ""}, {"column": "meet_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and measurement_moment range.',
    ARRAY['patient_contact_id','measurement_moment']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'medical_diagnosis', 'table',
    'Registered medical diagnoses linked to a patient contact/encounter.',
    'Diagnosis-based cohort definition; feeds v_diagnoses_longitudinal. Note: contact_id unreliable for outpatient rows (see known_issues).',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "diagnosis_contact_date", "is_primary": false, "note": "0.01% null"}, {"column": "diagnosis_registration_moment", "is_primary": true, "note": "0.01% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Known issues : diagnosis_contact_date: 5.95% dates pre-2000 | patient_contact_id: contact_id not in patient_contact master -> Join via pseudo_id as primary key. contact_id unreliable for this table',
    'Join by patient_contact_id, or pseudo_id and diagnosis_registration_moment range.',
    ARRAY['medical_diagnosis_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'medical_history', 'table',
    'Patient medical history entries (past conditions/procedures reported).',
    'Historical condition context for a patient; feeds v_medical_history.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "indication_determination_date", "is_primary": true, "note": "100% null"}, {"column": "indication_determination_date_raw", "is_primary": false, "note": "39.9% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "registration_date", "is_primary": false, "note": ""}]'::jsonb,
    'Date quality: indication_determination_date: 100% null | indication_determination_date_raw: 39.9% null',
    'Join by patient_contact_id, or pseudo_id and indication_determination_date range.',
    ARRAY['medical_history_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'medication_administration', 'table',
    'Individual medication administration events (drug actually given).',
    'Medication exposure analysis; feeds v_medications. High volume, partial ATC coverage.',
    ARRAY['pseudo_id','rule_id','patient_contact_id','admission_traject_id'],
    '[{"column": "administration_date", "is_primary": false, "note": "to correct; corrected version available: corrected_administration_date"}, {"column": "administration_date_time", "is_primary": false, "note": "corrected version available: corrected_administration_date_time"}, {"column": "administration_time", "is_primary": false, "note": "the corrected column to be used as main"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "corrected_administration_date", "is_primary": false, "note": "corrected version of administration_date"}, {"column": "corrected_administration_date_time", "is_primary": true, "note": "corrected version of administration_date_time -- future/implausible dates set to NULL"}]'::jsonb,
    'Date quality: administration_date: to correct | administration_time: the corrected column to be used as main || Known issues : [B12/LOW] administration_date: 0.01% far-future dates (max 2404-07-27) -> Flag and exclude from date-windowed analyses | atc_code: NULL ATC code -> Flag; cannot classify by drug class. Report unclassified proportion | [F04/MEDIUM] administration_date / start_date: Administration dated before prescription start -> Flag but retain — real clinical events. Do not auto-exclude from ICU analyses | [H02/MEDIUM] rule_id: Administration with no matching prescription -> Cannot enrich with ATC hierarchy or dose info. Flag in output; retain for completeness || Quality flag column(s) available: ongoing_medication_administration',
    'Join by rule_id with medication prescription table, patient_contact_id or admission_traject_id and corrected_administration_date_time range with other tables',
    ARRAY['medication_administration_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'medication_atc', 'table',
    'ATC (Anatomical Therapeutic Chemical) code reference/lookup table for medications.',
    'Lookup table to resolve ATC codes/classes for medication tables; not date-tracked.',
    ARRAY[]::text[],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Lookup table: join to medication_administration / medication_prescription on ATC code (not date-based).',
    ARRAY['atc_code']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'medication_prescription', 'table',
    'Individual medication prescription/order events.',
    'Medication ordering analysis; feeds v_medications.',
    ARRAY['rule_id','pseudo_id','patient_contact_id'],
    '[{"column": "corrected_stop_date", "is_primary": false, "note": "11.08% null"}, {"column": "corrected_stop_date_time", "is_primary": false, "note": "11.08% null"}, {"column": "corrected_stop_time", "is_primary": false, "note": "11.08% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "prescription_date", "is_primary": false, "note": ""}, {"column": "prescription_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "prescription_time", "is_primary": false, "note": "8.89% null"}, {"column": "start_date", "is_primary": false, "note": "6.42% null"}, {"column": "start_date_time", "is_primary": false, "note": "future dates indicating future prescription; 6.42% null"}, {"column": "start_time", "is_primary": false, "note": "6.42% null"}, {"column": "stop_date", "is_primary": false, "note": "a small portion with future dates, indication ongoing medication. 11.08% null; corrected version available: corrected_stop_date"}, {"column": "stop_date_time", "is_primary": false, "note": "11.08% null; corrected version available: corrected_stop_date_time"}, {"column": "stop_time", "is_primary": false, "note": "11.08% null; corrected version available: corrected_stop_time"}, {"column": "corrected_stop_date", "is_primary": false, "note": "corrected version of stop_date"}, {"column": "corrected_stop_time", "is_primary": false, "note": "corrected version of stop_time"}, {"column": "corrected_stop_date_time", "is_primary": false, "note": "corrected version of stop_date_time"}]'::jsonb,
    'Date quality: rely on prescription_date_time rather than start/end dates. | Known issues : start_date: 0.01% dates pre-2000 or far future -> Filter obvious outliers; small volume | atc_code: 14% NULL ATC code | Quality flag column(s) available: ongoing_medication for stop dates in the future (0.45%) set to null in the corrected stop date.',
    'Join by patient_contact_id or rule_id (with medication administration table), or pseudo_id and prescription_date_time range.',
    ARRAY['rule_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ok_procedure_performed', 'table',
    'Operating room (OK) procedures actually performed.',
    'Surgical procedure analysis; source for v_procedures matching against billing.',
    ARRAY['pseudo_id','subtraject_id','care_traject_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "intervention_executed_date", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "session_start_date", "is_primary": false, "note": "1.63% null"}, {"column": "session_start_date_time", "is_primary": false, "note": "10.11% null"}]'::jsonb,
    'Date quality: session_start_date_time: 10.11% null',
    'Join by care_traject_id/subtraject_id, or pseudo_id and intervention_executed_date range.',
    ARRAY['ok_procedure_performed_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'ok_procedure_planned', 'table',
    'Operating room (OK) procedures planned/scheduled.',
    'Surgical scheduling analysis; used to match against v_procedures_billing.',
    ARRAY['pseudo_id','care_traject_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "session_planned_start_date", "is_primary": true, "note": "18.96% null"}]'::jsonb,
    'Date quality: session_planned_start_date: 18.96% null',
    'Join by care_traject_id/subtraject_id, or pseudo_id and session_planned_start_date range.',
    ARRAY['ok_procedure_planned_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_appointment', 'table',
    'Patient appointment records (outpatient scheduling).',
    'Appointment scheduling/no-show analysis; feeds v_appointments.',
    ARRAY['pseudo_id','patient_contact_id','appointment_relocated_to_patient_contact_id','order_id'],
    '[{"column": "appointment_date", "is_primary": false, "note": ""}, {"column": "appointment_end_moment", "is_primary": false, "note": ""}, {"column": "appointment_made_at_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "appointment_start_moment", "is_primary": false, "note": "to correct"}, {"column": "appointment_time", "is_primary": false, "note": ""}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "order_date", "is_primary": false, "note": "unreliable"}, {"column": "order_time", "is_primary": false, "note": "17.84% null"}]'::jsonb,
    'Date quality: appointment_start_moment: to correct | order_date: unreliable | order_time: 17.84% null || Known issues : patient_contact_id: contact_id not in patient_contact master -> Use pseudo_id as primary join',
    'Join by patient_contact_id, pseudo_id and date range, or order_id to measurements or procedures tables.',
    ARRAY['patient_contact_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_appointment_line', 'table',
    'Line-level detail for patient appointments (e.g. multiple activities per appointment).',
    'Detailed appointment content analysis; feeds v_appointments.',
    ARRAY['pseudo_id','patient_contact_id','appointment_relocated_to_patient_contact_id','order_id'],
    '[{"column": "appointment_date", "is_primary": false, "note": ""}, {"column": "appointment_end_moment", "is_primary": false, "note": "impact note: end moment unreliable"}, {"column": "appointment_made_at_date_time", "is_primary": true, "note": "impact note: start moment more reliable and appointment date"}, {"column": "appointment_start_moment", "is_primary": false, "note": "to correct"}, {"column": "appointment_time", "is_primary": false, "note": ""}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "order_date", "is_primary": false, "note": ""}, {"column": "order_time", "is_primary": false, "note": "16.73% null"}]'::jsonb,
    'Date quality: appointment_start_moment: with 0.002% dates < 2000. appointment_made_at_date_time is more reliable.| order_time: 16.73% null || Known issues : patient_contact_id: contact_id not in patient_contact master -> Use pseudo_id as primary join',
    'Join by patient_contact_id, pseudo_id and time range, or order_id to measurements or procedures tables.',
    ARRAY['appointment_line_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_contact', 'table',
    'Patient contact/encounter master table (each row is one clinical contact).',
    'Core encounter table; primary join target for contact_id-based joins across amc_core; feeds v_encounters / v_contact_id_registry.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "abnormal_date", "is_primary": false, "note": ""}, {"column": "cancellation_date", "is_primary": false, "note": "92.75% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "patient_contact_date", "is_primary": false, "note": "how to correct?; 0.56% null"}, {"column": "patient_contact_date_time", "is_primary": true, "note": "0.56% null"}, {"column": "patient_contact_time", "is_primary": false, "note": "0.56% null"}]'::jsonb,
    'Date quality: cancellation_date: 92.75% null | patient_contact_date: how to correct? || Known issues : patient_contact_date: 2.61% dates pre-2000 or far future  || Quality flag column(s) available: abnormal_date',
    'Join by patient_contact_id, or pseudo_id and patient_contact_date_time range.',
    ARRAY['patient_contact_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

-- patient_note_contains_sensitive_information's catalog row was removed
-- here when the table was retired (2026-09-11 extract: its CSV is gone
-- from the source, confirmed no replacement) -- see
-- archive/460_patient_note_contains_sensitive_information.sql.

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_note_patient_contact', 'table',
    'Clinical free-text notes linked to a patient contact.',
    'Primary source for clinical NLP work; feeds v_notes. Known date reliability issue (~45% pre-2000, see known_issues).',
    ARRAY['pseudo_id','patient_note_id','note_contact_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "entry_instant_local_dttm", "is_primary": true, "note": "27.05% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "note_file_time_local_dttm", "is_primary": false, "note": "44.51% null"}, {"column": "note_made_at_date_time", "is_primary": false, "note": "unreliable"}, {"column": "note_made_at_time", "is_primary": false, "note": "44.51% null"}, {"column": "note_made_on_date", "is_primary": false, "note": "unreliable"}, {"column": "patient_contact_date_time", "is_primary": false, "note": "unreliable"}]'::jsonb,
    'Date quality: entry_instant_local_dttm: 27.05% null | note_file_time_local_dttm: 44.51% null | note_made_at_date_time: unreliable | note_made_at_time: 44.51% null | note_made_on_date: unreliable | patient_contact_date_time: unreliable || Known issues : note_made_on_date: Date value unreliable — 45% pre-2000 | patient_contact_id: contact_id not in patient_contact master -> Use where present; fallback to pseudo_id + note_made_on_date',
    'Join by patient_contact_id, or pseudo_id and entry_instant_local_dttm range.',
    ARRAY['note_contact_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_not_traceable', 'table',
    'Registry of patients with demographics and death data.',
    'Cohort eligibility filtering; check before including a patient in a study extract.',
    ARRAY['pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Known issues : Ghost patient - no events in any domain 0.19% -> Exclude from all cohort analyses | Quality flag column available: has_any_quality_issue (aggregate -- true if this patient has any quality-flag column set true anywhere in 04_quality_flags). death_date_time is the direct source of truth for death timing.',
    'Join by pseudo_id.',
    ARRAY['pseudo_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_questionnaire', 'table',
    'Patient-completed questionnaire responses.',
    'PROM/questionnaire-based outcome analysis; feeds v_questionnaires_long.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "reply_date", "is_primary": false, "note": ""}, {"column": "reply_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "reply_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by patient_contact_id, or pseudo_id and reply_date_time range.',
    ARRAY['patient_questionnaire_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'patient_social', 'table',
    'Patient social history / social determinants entries.',
    'Social context analysis for a patient.',
    ARRAY['pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Join by pseudo_id.',
    ARRAY['pseudo_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'problem_list', 'table',
    'Active/historical patient problem list entries.',
    'Longitudinal condition tracking outside formal diagnosis coding.',
    ARRAY['patient_contact_id','pseudo_id'],
    '[{"column": "close_date", "is_primary": false, "note": "corrected version available: corrected_close_date"}, {"column": "corrected_close_date", "is_primary": false, "note": "past dates?; 90.02% null"}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "observation_date", "is_primary": true, "note": "reliable, 0% null"}, {"column": "patient_contact_date", "is_primary": false, "note": "0.05% null"}, {"column": "patient_contact_date_time", "is_primary": false, "note": "0.05% null"}, {"column": "registration_date", "is_primary": false, "note": ""}, {"column": "corrected_close_date", "is_primary": false, "note": "corrected version of close_date"}]'::jsonb,
    'Date quality: corrected_close_date: past dates 1%; 90.02% null || Known issues : close_date: Date value unreliable — 90% future (9999-12-31) -> marking ongoing problems. Use corrected_close_date with Null and patient_problem_status flag. | observation_date: 1.41% dates pre-2000 -> Filter >= ''2000-01-01'' for temporal analyses',
    'Join by patient_contact_id, or pseudo_id and observation_date range.',
    ARRAY['patient_contact_id','problem_list_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'procedures', 'table',
    'Billing/administrative record of clinical procedures/interventions performed.',
    'Very high-volume procedures source; feeds v_procedures_billing and (matched) v_procedures.',
    ARRAY['pseudo_id','patient_contact_id','subtraject_id','order_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "intervention_date", "is_primary": true, "note": "reliable, 0% null"}, {"column": "issue_dt", "is_primary": false, "note": ""}]'::jsonb,
    'Known issues : patient_contact_id: contact_id not in patient_contact master -> Fallback to pseudo_id + intervention_date | patient_contact_id: NULL contact_id -> Fallback to pseudo_id + intervention_date for joins; use contact_id only where present | intervention_code: NULL intervention code -> Filter to coded procedures for code-based analyses',
    'Join by patient_contact_id, pseudo_id and time range, or order_id to appointment or measurement tables.',
    ARRAY['pseudo_id','intervention_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'seh_trajectory', 'table',
    'Emergency department (SEH) visit trajectory records.',
    'ED visit timing and throughput analysis.',
    ARRAY['pseudo_id','patient_contact_id','admission_traject_id'],
    '[{"column": "corrected_seh_departure_date", "is_primary": false, "note": ""}, {"column": "corrected_seh_departure_date_time", "is_primary": false, "note": ""}, {"column": "corrected_seh_departure_moment", "is_primary": false, "note": ""}, {"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "patient_arrived_at_seh_date_time", "is_primary": false, "note": "0.17% null"}, {"column": "seh_admission_date", "is_primary": false, "note": ""}, {"column": "seh_admission_date_time", "is_primary": true, "note": "reliable, 0% null"}, {"column": "seh_admission_moment", "is_primary": false, "note": ""}, {"column": "seh_departure_date", "is_primary": false, "note": "corrected; corrected version available: corrected_seh_departure_date"}, {"column": "seh_departure_date_time", "is_primary": false, "note": "corrected version available: corrected_seh_departure_date_time"}, {"column": "seh_departure_moment", "is_primary": false, "note": "corrected version available: corrected_seh_departure_moment"}, {"column": "urgent_contact_created_date_time", "is_primary": false, "note": "0.19% null"}, {"column": "corrected_seh_departure_date_time", "is_primary": false, "note": "corrected version of seh_departure_date_time"}, {"column": "corrected_seh_departure_date", "is_primary": false, "note": "corrected version of seh_departure_date"}, {"column": "corrected_seh_departure_moment", "is_primary": false, "note": "corrected version of seh_departure_moment"}]'::jsonb,
    'Date quality: seh_departure_date: corrected || Known issues : seh_departure_date: 0.004% far-future — open ED trajectories -> use corrected_seh_departure_date | patient_contact_id: contact_id not in patient_contact master -> Use pseudo_id + seh_admission_date for joins || Quality flag column(s) available: ongoing_seh_stay',
    'Join by patient_contact_id or admission_traject_id and seh_admission_date_time range.',
    ARRAY['seh_traject_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'surgery_history', 'table',
    'Historical surgery records reported for a patient (patient-reported or past-system history).',
    'Surgical history context distinct from current OK/procedures tables.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "procedure_end_date", "is_primary": false, "note": "15.08% null"}, {"column": "procedure_start_date", "is_primary": false, "note": "15.08% null"}, {"column": "registration_date", "is_primary": true, "note": ""}]'::jsonb,
    'Date quality: procedure_end_date: 15.08% null | procedure_start_date: 15.08% null || Known issues : procedure_start_date: 2.03% dates pre-2000 -> Retain for history; exclude from time-windowed queries',
    'Join by patient_contact_id, or pseudo_id.',
    ARRAY['surgery_history_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues, join_recommendations, primary_key
) VALUES (
    'amc_core', 'tobacco_use', 'table',
    'Registered tobacco use status entries for a patient.',
    'Smoking status/risk factor analysis; feeds v_patient_profile.',
    ARRAY['pseudo_id'],
    '[{"column": "dcm_refreshed_date_time", "is_primary": false, "note": ""}, {"column": "issue_dt", "is_primary": false, "note": ""}, {"column": "registration_date", "is_primary": true, "note": ""}, {"column": "start_date", "is_primary": false, "note": ""}, {"column": "stop_date", "is_primary": false, "note": ""}]'::jsonb,
    'Known issues : start_date: Date value unreliable — 99% pre-2000 -> Use registration_date',
    'Join by patient_contact_id, or pseudo_id.',
    ARRAY['tobacco_use_id']
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

-- ---------------------------------------------------------------------
-- amc_views views (39)
-- ---------------------------------------------------------------------

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_patient_profile', 'view',
    'Patient-level demographic/status profile: traceability, social history, tobacco use, death status.',
    'Cohort demographic lookup and inclusion/exclusion filtering (e.g. exclude non-traceable patients).',
    ARRAY['pseudo_id','patient_contact_id'],
    '[]'::jsonb,
    'No single canonical event date - this is a patient-level profile view, not an event view.',
    'Sources: death_registration, patient_not_traceable, patient_social, tobacco_use',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_stays', 'view',
    'Unified hospital/ED stay periods combining admission trajectories and SEH (ED) visits.',
    'Length-of-stay analysis, defining episode boundaries for a patient.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "start_datetime", "is_primary": true, "note": "start_datetime is the canonical stay-start anchor; end_datetime may be NULL for ongoing stays."}, {"column": "end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: admission_partial_traject, admission_traject, seh_trajectory',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_appointments', 'view',
    'Outpatient appointments combined with their line-level activity detail.',
    'Appointment scheduling / attendance / no-show analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "appointment_made_at_date_time", "is_primary": true, "note": "appointment_made_at_date_time is when the appointment was scheduled, not the appointment itself; use appointment_date for the actual appointment date."}, {"column": "appointment_date", "is_primary": false, "note": ""}, {"column": "appointment_start_moment", "is_primary": false, "note": ""}, {"column": "appointment_end_moment", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: patient_appointment, patient_appointment_line',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_encounters', 'view',
    'Unified patient encounters/contacts across admissions, appointments, and ED visits.',
    'General-purpose encounter timeline; join target for contact-scoped clinical data.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "start_datetime", "is_primary": true, "note": "start_datetime is the canonical encounter-start anchor across admission/ED/appointment sources."}, {"column": "end_datetime", "is_primary": false, "note": ""}, {"column": "appointment_made_at_date_time", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: admission_traject, patient_appointment, patient_contact, seh_trajectory',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_contact_id_registry', 'view',
    'Registry mapping contact IDs across admission, appointment and ED source tables to a unified contact identifier.',
    'Resolving/standardizing contact_id references before joining across source tables.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "contact_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: admission_partial_traject, admission_traject, patient_appointment, patient_appointment_line, patient_contact, seh_trajectory',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_medical_history', 'view',
    'Combined medical/family/surgical history entries per patient.',
    'Past-condition context for a patient outside the active diagnosis list.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "start_date", "is_primary": true, "note": "start_date is the canonical anchor; end_date may be NULL for ongoing/unresolved history items."}, {"column": "end_date", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: family_history, medical_history, patient_contact, surgery_history',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_diagnoses_longitudinal', 'view',
    'Longitudinal diagnosis events combining formal diagnoses and problem list entries.',
    'Diagnosis-based cohort definition and condition timeline construction.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "registration_datetime", "is_primary": true, "note": "registration_datetime is the canonical anchor; observation_date/close_date are context fields."}, {"column": "observation_date", "is_primary": false, "note": ""}, {"column": "close_date", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: medical_diagnosis, problem_list',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_medications', 'view',
    'Unified medication administrations and prescriptions with ATC classification.',
    'Medication exposure analysis across ordering and administration.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "event_datetime", "is_primary": true, "note": "event_datetime is the canonical anchor combining administration and prescription timing."}, {"column": "start_datetime", "is_primary": false, "note": ""}, {"column": "stop_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: medication_administration, medication_atc, medication_prescription, patient_contact',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_procedures', 'view',
    'Unified clinical procedures combining ICU procedure notes, OK (operating room) records, and general procedures, cross-matched against billing.',
    'Primary source for clinical procedure analysis (not billing-only).',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "procedure_datetime", "is_primary": true, "note": "procedure_datetime is the canonical anchor; procedure_end_datetime may be NULL for point-in-time procedures."}, {"column": "procedure_end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: ic_procedure_note_bronchoscopy, ic_procedure_note_central_venous_catheter, ic_procedure_note_electric_cardioversion, ic_procedure_note_icarus, ic_procedure_note_intubation, ic_procedure_note_thorax_drain, ic_procedure_note_tracheostomy, ok_procedure_performed, ok_procedure_planned, procedures',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_procedures_billing', 'view',
    'Billing-oriented procedure records from amc_core.procedures, matched against OK performed/planned records.',
    'Billing/administrative procedure analysis; use v_procedures instead for clinical analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "procedure_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: ok_procedure_performed, ok_procedure_planned, procedures',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_vital_signs_long', 'view',
    'Long-format vital sign measurements (BP, heart rate, SpO2, weight, height, BMI, etc.), deduplicated across source tables.',
    'Time-series vital signs analysis during a stay/contact.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: measurement_blood_pressure, measurement_blood_pressure_average, measurement_bmi, measurement_heart_frequency, measurement_height, measurement_o2_saturation, measurement_vital_signs_data, measurement_weight',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_labs_long', 'view',
    'Long-format laboratory results derived from amc_core.lab_result.',
    'Lab trend analysis, lab-based cohort criteria.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: lab_result',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_scores', 'view',
    'Long-format clinical scores (CHA2DS2-VASc, DOSS, SNAQ).',
    'Clinical risk-scoring / screening trend analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "score_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: measurement_chadsvasc_score, measurement_doss_score, measurement_snaq_score',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_fluid_balance_long', 'view',
    'Long-format fluid balance measurements (intake and multiple output types) combined.',
    'Fluid balance monitoring, especially in ICU context.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: measurement_diurese, measurement_fluid_assessment_diuresis, measurement_fluid_balance_assessment_emesis, measurement_fluid_balance_assessment_feces, measurement_fluid_balance_out, measurement_fluid_balance_stomach_retention, measurement_fluid_in',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_nephrology_treatments', 'view',
    'Combined renal replacement therapy records (CRRT/CNVT, hemodialysis, peritoneal dialysis).',
    'Renal replacement therapy utilization and treatment timeline analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "treatment_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: measurement_nephrology_cntv_medication, measurement_nephrology_cnvt_settings, measurement_nephrology_hemodialysis, measurement_nephrology_peritoneal_dialysis',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_notes', 'view',
    'Unified clinical free-text notes.',
    'Primary source for clinical NLP pipelines and text-based analyses; use v_notes_metadata for note-level metadata. Previously included a has_sensitive_information_flag column, removed when its source table (patient_note_contains_sensitive_information) was retired (2026-09-11 extract).',
    ARRAY['pseudo_id','patient_contact_id', 'note_contact_id', 'note_contact_sequential_number', 'patient_note_id'],
    '[{"column": "note_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: amc_notes, amc_notes_metadata, patient_note_patient_contact',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_measurements', 'view',
    'Unified measurement events combining vitals, labs, scores, fluid balance, and nephrology treatments.',
    'Broad measurement timeline across measurement domains.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_fluid_balance_long, v_labs_long, v_nephrology_treatments, v_scores, v_vital_signs_long',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_clinical_timeline', 'view',
    'Master longitudinal event timeline unifying encounters, diagnoses, medications, procedures, notes, and measurements.',
    'Single source for constructing a full patient clinical timeline (non-ICU).',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "event_datetime", "is_primary": true, "note": "event_datetime is the canonical anchor across all unified clinical event types."}, {"column": "event_end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_appointments, v_diagnoses_longitudinal, v_encounters, v_fluid_balance_long, v_imaging_study_orders, v_labs_long, v_medical_history, v_medications, v_nephrology_treatments, v_notes, v_procedures, v_scores, v_stays, v_vital_signs_long',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_adverse_events', 'view',
    'Adverse events reshaped into the standard event view format.',
    'Adverse event timeline analysis / patient safety reporting.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "event_datetime", "is_primary": true, "note": "event_datetime is the canonical anchor."}, {"column": "event_end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: adverse_event',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_imaging_study_orders', 'view',
    'Imaging study orders reshaped into the standard event view format.',
    'Imaging order timeline and turnaround analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "imaging_start_datetime", "is_primary": true, "note": "imaging_start_datetime is the canonical anchor."}, {"column": "imaging_end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: imaging_study_order',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_ecg_exams', 'view',
    'ECG exam headers joined with basic exam-level features.',
    'Identifying and timing ECG exams for a patient.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "ecg_datetime", "is_primary": true, "note": "ecg_datetime is the canonical anchor (see amc_core.ecg_measurement known_issues re: pre-1996 dates)."}, {"column": "ecg_date", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: ecg_measurement, ecg_measurement_test_feature',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_ecg_measurements_long', 'view',
    'Long-format individual ECG measured features/parameters.',
    'Detailed ECG parameter trend analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: ecg_measurement, v_ecg_exams',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_questionnaires_long', 'view',
    'Long-format patient questionnaire responses.',
    'PROM/questionnaire outcome analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "questionnaire_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: patient_questionnaire',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_echo_heart_exams', 'view',
    'Echocardiography exam headers.',
    'Identifying and timing echo exams for a patient; sparse table upstream.',
    ARRAY['pseudo_id'],
    '[{"column": "examination_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: echo_measurement_heart_center_extra_check',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_echo_heart_measurements_long', 'view',
    'Long-format individual echocardiography measured parameters.',
    'Detailed echo parameter trend analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: echo_measurement_heart_center_extra_check',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_patient_profile', 'view',
    'ICU-scoped patient demographic/status profile.',
    'ICU cohort demographic lookup, mirrors v_patient_profile restricted to ICU stays.',
    ARRAY['pseudo_id'],
    '[]'::jsonb,
    'No single canonical event date - this is a patient-level profile view, not an event view.',
    'Sources: admission_partial_traject, patient_not_traceable, patient_social, tobacco_use',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_stays', 'view',
    'ICU stay periods derived from admission trajectory + partial trajectory (ward-level) data.',
    'Defining ICU episode boundaries (distinct from general hospital stay in v_stays).',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "icu_start_datetime", "is_primary": true, "note": "icu_start_datetime is the canonical ICU-episode anchor, distinct from hospital_admission_datetime."}, {"column": "icu_end_datetime", "is_primary": false, "note": ""}, {"column": "hospital_admission_datetime", "is_primary": false, "note": ""}, {"column": "hospital_discharge_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: admission_partial_traject, admission_traject, patient_contact, patient_not_traceable',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_diagnoses_longitudinal', 'view',
    'Diagnoses restricted to ICU stay periods.',
    'ICU-specific diagnosis timeline analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "registration_datetime", "is_primary": true, "note": "Inherited from v_diagnoses_longitudinal (registration_datetime); also carries icu_start_datetime/icu_end_datetime as ICU-window bounds."}]'::jsonb,
    NULL,
    'Sources: v_diagnoses_longitudinal, v_icu_stays',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_medical_history', 'view',
    'Medical history restricted/linked to ICU stay periods.',
    'ICU-specific historical condition context.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "start_date", "is_primary": true, "note": "Inherited from v_medical_history (start_date)."}, {"column": "end_date", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_medical_history',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_procedures', 'view',
    'Procedures restricted to ICU stay periods.',
    'ICU-specific procedure timeline analysis.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "procedure_datetime", "is_primary": true, "note": "Inherited from v_procedures (procedure_datetime); also carries icu_start_datetime/icu_end_datetime as ICU-window bounds."}, {"column": "procedure_end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_procedures',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_medications', 'view',
    'Medications restricted to ICU stay periods.',
    'ICU-specific medication exposure analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "event_datetime", "is_primary": true, "note": "Inherited from v_medications (event_datetime)."}, {"column": "start_datetime", "is_primary": false, "note": ""}, {"column": "stop_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_medications',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_notes', 'view',
    'Clinical notes restricted to ICU stay periods.',
    'ICU-specific NLP source, with corrected note timestamp.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "corrected_note_datetime", "is_primary": true, "note": "corrected_note_datetime is a cleaned version of the underlying note date (see amc_core.patient_note_patient_contact known date-quality issues)."}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_notes',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_vital_signs_long', 'view',
    'Vital sign measurements restricted to ICU stay periods.',
    'ICU vital sign trend analysis.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_vital_signs_long',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_labs_long', 'view',
    'Lab results restricted to ICU stay periods.',
    'ICU lab trend analysis.',
    ARRAY['pseudo_id','patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_labs_long',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_scores', 'view',
    'Clinical scores restricted to ICU stay periods.',
    'ICU-specific risk/screening score analysis.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "score_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_scores',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_fluid_balance_long', 'view',
    'Fluid balance measurements restricted to ICU stay periods.',
    'ICU fluid balance monitoring.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_fluid_balance_long, v_icu_stays',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_nephrology_treatments', 'view',
    'Renal replacement therapy records restricted to ICU stay periods.',
    'ICU renal replacement therapy analysis.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "treatment_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_stays, v_nephrology_treatments',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_clinical_timeline', 'view',
    'Master longitudinal event timeline unifying all ICU-scoped views (stays, notes, vitals, labs, meds, procedures, scores, fluid balance, nephrology).',
    'Single source for constructing a full ICU patient clinical timeline.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "event_datetime", "is_primary": true, "note": "event_datetime is the canonical anchor across all unified ICU-scoped event types."}, {"column": "event_end_datetime", "is_primary": false, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_fluid_balance_long, v_icu_labs_long, v_icu_nephrology_treatments, v_icu_notes, v_icu_procedures, v_icu_scores, v_icu_stays, v_icu_vital_signs_long',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_icu_measurements', 'view',
    'Unified ICU-scoped measurement events combining vitals, labs, scores, fluid balance, and nephrology treatments.',
    'Broad ICU measurement timeline across measurement domains.',
    ARRAY['pseudo_id','original_patient_contact_id','icu_patient_contact_id'],
    '[{"column": "measurement_datetime", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Sources: v_icu_fluid_balance_long, v_icu_labs_long, v_icu_nephrology_treatments, v_icu_scores, v_icu_vital_signs_long',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

INSERT INTO meta.catalog (
    schema_name, object_name, object_type, description, possible_uses,
    identifier_columns, date_columns, known_issues,join_recommendations, primary_key
) VALUES (
    'amc_views', 'v_last_note_per_patient', 'view',
    'Most recent clinical note per patient (by date_note, then patient_note_id as a tiebreak).',
    'Quick access to a patient''s latest note without deduplicating v_notes yourself.',
    ARRAY['pseudo_id', 'patient_note_id'],
    '[{"column": "date_note", "is_primary": true, "note": ""}]'::jsonb,
    NULL,
    'Source: amc_notes. One row per pseudo_id (DISTINCT ON), already deduplicated to the most recent note -- no need to re-filter for "most recent" logic yourself.',
    NULL  -- views have no primary key
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    object_type = EXCLUDED.object_type,
    description = EXCLUDED.description,
    possible_uses = EXCLUDED.possible_uses,
    identifier_columns = EXCLUDED.identifier_columns,
    date_columns = EXCLUDED.date_columns,
    known_issues = EXCLUDED.known_issues,
    join_recommendations = EXCLUDED.join_recommendations,
    primary_key = EXCLUDED.primary_key;

UPDATE meta.catalog
SET
    identifier_columns = (
        SELECT array_agg(DISTINCT c)
        FROM unnest(
            identifier_columns || ARRAY['probable_contact_id', 'probable_partial_traject_id']
        ) AS c
    ),
    known_issues = COALESCE(known_issues || ' || ', '') ||
        'probable_contact_id / probable_partial_traject_id: derived by matching pseudo_id + COALESCE(result_date_time, material_decrease_date_time) against amc_core.admission_partial_traject stay windows. '
        || 'Only ~29% (48.7M/167.8M) match -- verified as expected, not a bug: ~28% of unmatched rows belong to patients with no inpatient stay at all (pure outpatient labs); '
        || 'most of the remaining ~43% are labs drawn outside all recorded ward-stay windows for a patient who WAS admitted at some other time (interim outpatient activity, or pre-admission/ED workup labs -- admission_partial_traject only covers ward-level segments, not the SEH/ED window in seh_trajectory). '
        || 'Match is intentionally strict (no time buffer); for pre-/post-admission context, widen the window manually at query time, e.g. BETWEEN start_date_time - interval ''30 minutes'' AND end_time + interval ''30 minutes''.',
    join_recommendations = COALESCE(join_recommendations || ' || ', '') ||
        'For inpatient-context labs, join directly on probable_contact_id / probable_partial_traject_id (indexed) rather than re-deriving via date-range against admission_partial_traject.'
WHERE schema_name = 'amc_core' AND object_name = 'lab_result';

-- verify
SELECT identifier_columns, known_issues, join_recommendations
FROM meta.catalog
WHERE schema_name = 'amc_core' AND object_name = 'lab_result';
