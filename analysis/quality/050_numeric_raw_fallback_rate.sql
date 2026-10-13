-- =====================================================================
-- Data quality check: how often the "_raw" fallback columns from the
-- type-safety audit actually get used -- i.e. how often a numeric/int
-- column's source value existed but failed to parse as a number.
--
-- 47 columns (across 15 tables) got a `<column>_raw text` sibling
-- during the type-safety audit specifically because CaRe_NLP source
-- data sometimes puts non-numeric text in what's supposed to be a
-- numeric field. The cast itself (structured-refresh/02_core_clean)
-- is: `<raw> = NULLIF(source, '')`, `<column> = CASE WHEN <raw>
-- matches a numeric regex THEN <raw>::numeric END` -- so `<raw> IS NOT
-- NULL AND <column> IS NULL` means the source had *something* there,
-- but it didn't parse as a number. That's a genuine parse failure, not
-- just a normally-empty field (an empty/NULL source leaves both <raw>
-- and <column> NULL, and isn't counted here).
--
-- Excludes medical_history.indication_determination_date_raw -- that
-- one's sibling is a date column, a different, already-covered
-- concern (see 010/020 in this folder), not a numeric one.
--
-- Usage: run in psql / any Postgres client against carenlp_db. Each
-- row of the result = one (table, column) pair.
-- =====================================================================

SELECT
    table_name,
    column_name,
    total_rows,
    raw_has_value,
    parse_failures,
    ROUND(100.0 * parse_failures / NULLIF(raw_has_value, 0), 2) AS pct_of_raw_values_unparseable
FROM (

    SELECT
        'patient_note_patient_contact'::text AS table_name,
        'note_contact_sequential_number'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE note_contact_sequential_number_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE note_contact_sequential_number_raw IS NOT NULL AND note_contact_sequential_number IS NULL) AS parse_failures
    FROM amc_core.patient_note_patient_contact

    UNION ALL

    SELECT
        'patient_appointment'::text AS table_name,
        'age_in_years_at_moment_appointment'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE age_in_years_at_moment_appointment_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE age_in_years_at_moment_appointment_raw IS NOT NULL AND age_in_years_at_moment_appointment IS NULL) AS parse_failures
    FROM amc_core.patient_appointment

    UNION ALL

    SELECT
        'patient_appointment_line'::text AS table_name,
        'age_in_years_at_moment_appointment'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE age_in_years_at_moment_appointment_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE age_in_years_at_moment_appointment_raw IS NOT NULL AND age_in_years_at_moment_appointment IS NULL) AS parse_failures
    FROM amc_core.patient_appointment_line

    UNION ALL

    SELECT
        'measurement_vital_signs_data'::text AS table_name,
        'vital_data_bmi_calculation'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE vital_data_bmi_calculation_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE vital_data_bmi_calculation_raw IS NOT NULL AND vital_data_bmi_calculation IS NULL) AS parse_failures
    FROM amc_core.measurement_vital_signs_data

    UNION ALL

    SELECT
        'measurement_vital_signs_data'::text AS table_name,
        'vital_data_pulse_rate'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE vital_data_pulse_rate_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE vital_data_pulse_rate_raw IS NOT NULL AND vital_data_pulse_rate IS NULL) AS parse_failures
    FROM amc_core.measurement_vital_signs_data

    UNION ALL

    SELECT
        'procedures'::text AS table_name,
        'age_in_years_at_moment_of_intervention'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE age_in_years_at_moment_of_intervention_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE age_in_years_at_moment_of_intervention_raw IS NOT NULL AND age_in_years_at_moment_of_intervention IS NULL) AS parse_failures
    FROM amc_core.procedures

    UNION ALL

    SELECT
        'ok_procedure_performed'::text AS table_name,
        'child_age_in_weeks_at_moment_of_session'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE child_age_in_weeks_at_moment_of_session_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE child_age_in_weeks_at_moment_of_session_raw IS NOT NULL AND child_age_in_weeks_at_moment_of_session IS NULL) AS parse_failures
    FROM amc_core.ok_procedure_performed

    UNION ALL

    SELECT
        'ok_procedure_planned'::text AS table_name,
        'child_age_in_weeks_at_moment_of_session'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE child_age_in_weeks_at_moment_of_session_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE child_age_in_weeks_at_moment_of_session_raw IS NOT NULL AND child_age_in_weeks_at_moment_of_session IS NULL) AS parse_failures
    FROM amc_core.ok_procedure_planned

    UNION ALL

    SELECT
        'measurement_fluid_assessment_diuresis'::text AS table_name,
        'bladderscan_ml'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE bladderscan_ml_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE bladderscan_ml_raw IS NOT NULL AND bladderscan_ml IS NULL) AS parse_failures
    FROM amc_core.measurement_fluid_assessment_diuresis

    UNION ALL

    SELECT
        'measurement_fluid_balance_stomach_retention'::text AS table_name,
        'stomach_retention'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE stomach_retention_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE stomach_retention_raw IS NOT NULL AND stomach_retention IS NULL) AS parse_failures
    FROM amc_core.measurement_fluid_balance_stomach_retention

    UNION ALL

    SELECT
        'measurement_fluid_balance_stomach_retention'::text AS table_name,
        'air_retention'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE air_retention_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE air_retention_raw IS NOT NULL AND air_retention IS NULL) AS parse_failures
    FROM amc_core.measurement_fluid_balance_stomach_retention

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'citrate_doses_set'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE citrate_doses_set_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE citrate_doses_set_raw IS NOT NULL AND citrate_doses_set IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'citrate_flowrate'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE citrate_flowrate_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE citrate_flowrate_raw IS NOT NULL AND citrate_flowrate IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'citrate_volume'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE citrate_volume_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE citrate_volume_raw IS NOT NULL AND citrate_volume IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'calcium_doses_set'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE calcium_doses_set_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE calcium_doses_set_raw IS NOT NULL AND calcium_doses_set IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'calcium_flowrate'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE calcium_flowrate_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE calcium_flowrate_raw IS NOT NULL AND calcium_flowrate IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'calcium_volume'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE calcium_volume_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE calcium_volume_raw IS NOT NULL AND calcium_volume IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'anticoagulation_continuousu_volume_total'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE anticoagulation_continuousu_volume_total_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE anticoagulation_continuousu_volume_total_raw IS NOT NULL AND anticoagulation_continuousu_volume_total IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'measurement_nephrology_cntv_medication'::text AS table_name,
        'anticoagulation_bolus_volume_total'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE anticoagulation_bolus_volume_total_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE anticoagulation_bolus_volume_total_raw IS NOT NULL AND anticoagulation_bolus_volume_total IS NULL) AS parse_failures
    FROM amc_core.measurement_nephrology_cntv_medication

    UNION ALL

    SELECT
        'patient_questionnaire'::text AS table_name,
        'age_in_years_at_reply'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE age_in_years_at_reply_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE age_in_years_at_reply_raw IS NOT NULL AND age_in_years_at_reply IS NULL) AS parse_failures
    FROM amc_core.patient_questionnaire

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field1'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field1_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field1_raw IS NOT NULL AND lung_aeration_score_right_field1 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field2'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field2_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field2_raw IS NOT NULL AND lung_aeration_score_right_field2 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field3'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field3_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field3_raw IS NOT NULL AND lung_aeration_score_right_field3 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field4'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field4_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field4_raw IS NOT NULL AND lung_aeration_score_right_field4 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field5'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field5_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field5_raw IS NOT NULL AND lung_aeration_score_right_field5 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field6'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field6_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field6_raw IS NOT NULL AND lung_aeration_score_right_field6 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_right_field8'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field8_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_right_field8_raw IS NOT NULL AND lung_aeration_score_right_field8 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_left_field1'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field1_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field1_raw IS NOT NULL AND lung_aeration_score_left_field1 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_lefts_field2'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_lefts_field2_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_lefts_field2_raw IS NOT NULL AND lung_aeration_score_lefts_field2 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_left_field3'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field3_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field3_raw IS NOT NULL AND lung_aeration_score_left_field3 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_left_field4'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field4_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field4_raw IS NOT NULL AND lung_aeration_score_left_field4 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_left_field5'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field5_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field5_raw IS NOT NULL AND lung_aeration_score_left_field5 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_left_field6'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field6_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field6_raw IS NOT NULL AND lung_aeration_score_left_field6 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_icarus'::text AS table_name,
        'lung_aeration_score_left_field8'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field8_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE lung_aeration_score_left_field8_raw IS NOT NULL AND lung_aeration_score_left_field8 IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_icarus

    UNION ALL

    SELECT
        'ic_procedure_note_intubation'::text AS table_name,
        'tubemate_mm'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE tubemate_mm_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE tubemate_mm_raw IS NOT NULL AND tubemate_mm IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_intubation

    UNION ALL

    SELECT
        'ic_procedure_note_intubation'::text AS table_name,
        'number_attempts'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL AND number_attempts IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_intubation

    UNION ALL

    SELECT
        'ic_procedure_note_tracheostomy'::text AS table_name,
        'number_attempts'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL AND number_attempts IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_tracheostomy

    UNION ALL

    SELECT
        'ic_procedure_note_thorax_drain'::text AS table_name,
        'size_scalpel'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE size_scalpel_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE size_scalpel_raw IS NOT NULL AND size_scalpel IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_thorax_drain

    UNION ALL

    SELECT
        'ic_procedure_note_thorax_drain'::text AS table_name,
        'size_drain_french'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE size_drain_french_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE size_drain_french_raw IS NOT NULL AND size_drain_french IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_thorax_drain

    UNION ALL

    SELECT
        'ic_procedure_note_central_venous_catheter'::text AS table_name,
        'number_attempts'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL AND number_attempts IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_central_venous_catheter

    UNION ALL

    SELECT
        'ic_procedure_note_central_venous_catheter'::text AS table_name,
        'ecmo_maat'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE ecmo_maat_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE ecmo_maat_raw IS NOT NULL AND ecmo_maat IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_central_venous_catheter

    UNION ALL

    SELECT
        'ic_procedure_note_central_venous_catheter'::text AS table_name,
        'ecmo_length'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE ecmo_length_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE ecmo_length_raw IS NOT NULL AND ecmo_length IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_central_venous_catheter

    UNION ALL

    SELECT
        'ic_procedure_note_electric_cardioversion'::text AS table_name,
        'number_attempts'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE number_attempts_raw IS NOT NULL AND number_attempts IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_electric_cardioversion

    UNION ALL

    SELECT
        'ic_procedure_note_electric_cardioversion'::text AS table_name,
        'attempt1_shock_joules'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE attempt1_shock_joules_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE attempt1_shock_joules_raw IS NOT NULL AND attempt1_shock_joules IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_electric_cardioversion

    UNION ALL

    SELECT
        'ic_procedure_note_electric_cardioversion'::text AS table_name,
        'attempt2_shock_joules'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE attempt2_shock_joules_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE attempt2_shock_joules_raw IS NOT NULL AND attempt2_shock_joules IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_electric_cardioversion

    UNION ALL

    SELECT
        'ic_procedure_note_electric_cardioversion'::text AS table_name,
        'attempt3_shock_joules'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE attempt3_shock_joules_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE attempt3_shock_joules_raw IS NOT NULL AND attempt3_shock_joules IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_electric_cardioversion

    UNION ALL

    SELECT
        'ic_procedure_note_electric_cardioversion'::text AS table_name,
        'attempt4_shock_joules'::text AS column_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (WHERE attempt4_shock_joules_raw IS NOT NULL) AS raw_has_value,
        COUNT(*) FILTER (WHERE attempt4_shock_joules_raw IS NOT NULL AND attempt4_shock_joules IS NULL) AS parse_failures
    FROM amc_core.ic_procedure_note_electric_cardioversion

) sub
ORDER BY pct_of_raw_values_unparseable DESC NULLS LAST;
