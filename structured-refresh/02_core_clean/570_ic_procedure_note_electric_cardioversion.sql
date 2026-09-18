--===========================================================================
DROP TABLE IF EXISTS amc_core.ic_procedure_note_electric_cardioversion CASCADE;

CREATE TABLE amc_core.ic_procedure_note_electric_cardioversion (
  order_id text PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  intervention_date_time timestamptz,
  intervention_name text,

  start_procedure timestamptz,
  informed_consent text,
  correct_patient text,
  correct_procedure text,
  correct_side text,
  relevant_comorbidity_medication_coagulation_status_allergies text,
  complications_discussed text,

  svt_without_anti_coagulation text,
  crash_cart_with_defibrillator text,
  defibrillator_on_synchronous_mode text,
  waters_set_of_ambu_balloon text,
  suction_system_with_yankauer text,
  sedativa_and_algetics text,
  vasoactivia_noradrenaline_atropine text,
  preoxygenation100percent_oxygenation text,
  tube_feeding_and_insulin_discontinuation text,

  timeout_executed text,
  analgesics text,
  sedation text,
  patient_sedated text,

  level_sedation text,
  level_sedation_regular_sedation text,
  level_sedation_all_anesthesia text,
  level_sedation_anxiolysis text,
  level_sedation_deep_sedation text,
  monitoring_vital_data_during_sedation text,

  start_sedation timestamptz,
  end_sedation timestamptz,
  end_procedure timestamptz,

  patient_sober text,

  procedural_rhythm text,
  supine text,
  thorax_ontblood text,
  type_electrodes text,
  location_electrodes text,
  indication text,

  number_attempts_raw text,
  number_attempts numeric,

  attempt1_pulseform text,
  attempt1_mode text,
  attempt1_shock_joules_raw text,
  attempt1_shock_joules numeric,
  attempt1_result text,

  attempt2_pulseform text,
  attempt2_mode text,
  attempt2_shock_joules_raw text,
  attempt2_shock_joules numeric,
  attempt2_result text,

  attempt3_pulseform text,
  attempt3_mode text,
  attempt3_shock_joules_raw text,
  attempt3_shock_joules numeric,
  attempt3_result text,

  attempt4_pulseform text,
  attempt4_mode text,
  attempt4_shock_joules_raw text,
  attempt4_shock_joules numeric,
  attempt4_result text,

  rhythm_post_intervention text,
  complications text,
  tolerance_patient_for_intervention text,
  intervention_remarks text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date
);

INSERT INTO amc_core.ic_procedure_note_electric_cardioversion (
  order_id,
  pseudo_id,
  patient_contact_id,
  hospital_location,
  intervention_date_time,
  intervention_name,
  start_procedure,
  informed_consent,
  correct_patient,
  correct_procedure,
  correct_side,
  relevant_comorbidity_medication_coagulation_status_allergies,
  complications_discussed,
  svt_without_anti_coagulation,
  crash_cart_with_defibrillator,
  defibrillator_on_synchronous_mode,
  waters_set_of_ambu_balloon,
  suction_system_with_yankauer,
  sedativa_and_algetics,
  vasoactivia_noradrenaline_atropine,
  preoxygenation100percent_oxygenation,
  tube_feeding_and_insulin_discontinuation,
  timeout_executed,
  analgesics,
  sedation,
  patient_sedated,
  level_sedation,
  level_sedation_regular_sedation,
  level_sedation_all_anesthesia,
  level_sedation_anxiolysis,
  level_sedation_deep_sedation,
  monitoring_vital_data_during_sedation,
  start_sedation,
  end_sedation,
  end_procedure,
  patient_sober,
  procedural_rhythm,
  supine,
  thorax_ontblood,
  type_electrodes,
  location_electrodes,
  indication,
  number_attempts_raw,
  number_attempts,
  attempt1_pulseform,
  attempt1_mode,
  attempt1_shock_joules_raw, attempt1_shock_joules,
  attempt1_result,
  attempt2_pulseform,
  attempt2_mode,
  attempt2_shock_joules_raw, attempt2_shock_joules,
  attempt2_result,
  attempt3_pulseform,
  attempt3_mode,
  attempt3_shock_joules_raw, attempt3_shock_joules,
  attempt3_result,
  attempt4_pulseform,
  attempt4_mode,
  attempt4_shock_joules_raw, attempt4_shock_joules,
  attempt4_result,
  rhythm_post_intervention,
  complications,
  tolerance_patient_for_intervention,
  intervention_remarks,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(order_id, ''),
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(intervention_date_time, '')::timestamptz,
  NULLIF(intervention_name, ''),

  NULLIF(start_procedure, '')::timestamptz,

  NULLIF(informed_consent, ''),
  NULLIF(correct_patient, ''),
  NULLIF(correct_procedure, ''),
  NULLIF(correct_side, ''),
  NULLIF(relevant_comorbidity_medication_coagulation_status_allergies, ''),
  NULLIF(complications_discussed, ''),

  NULLIF(svt_without_anti_coagulation, ''),
  NULLIF(crash_cart_with_defibrillator, ''),
  NULLIF(defibrillator_on_synchronous_mode, ''),
  NULLIF(waters_set_of_ambu_balloon, ''),
  NULLIF(suction_system_with_yankauer, ''),
  NULLIF(sedativa_and_algetics, ''),
  NULLIF(vasoactivia_noradrenaline_atropine, ''),
  NULLIF(preoxygenation100percent_oxygenation, ''),
  NULLIF(tube_feeding_and_insulin_discontinuation, ''),

  NULLIF(timeout_executed, ''),
  NULLIF(analgesics, ''),
  NULLIF(sedation, ''),
  NULLIF(patient_sedated, ''),

  NULLIF(level_sedation, ''),
  NULLIF(level_sedation_regular_sedation, ''),
  NULLIF(level_sedation_all_anesthesia, ''),
  NULLIF(level_sedation_anxiolysis, ''),
  NULLIF(level_sedation_deep_sedation, ''),
  NULLIF(monitoring_vital_data_during_sedation, ''),

  NULLIF(start_sedation, '')::timestamptz,
  NULLIF(end_sedation, '')::timestamptz,
  NULLIF(end_procedure, '')::timestamptz,

  NULLIF(patient_sober, ''),

  NULLIF(procedural_rhythm, ''),
  NULLIF(supine, ''),
  NULLIF(thorax_ontblood, ''),
  NULLIF(type_electrodes, ''),
  NULLIF(location_electrodes, ''),
  NULLIF(indication, ''),

  NULLIF(number_attempts, ''),

  CASE
    WHEN trim(number_attempts) ~ '^\d+$'
      THEN trim(number_attempts)::numeric
    WHEN trim(number_attempts) ~ '^(\d+)\s+of\s+meer$'
      THEN regexp_replace(trim(number_attempts), '^(\d+).*$', '\1')::numeric
  END,

  NULLIF(attempt1_pulseform, ''),
  NULLIF(attempt1_mode, ''),
  NULLIF(attempt1_shock_joules, ''),

  CASE WHEN trim(attempt1_shock_joules) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(attempt1_shock_joules)::numeric END,
  NULLIF(attempt1_result, ''),

  NULLIF(attempt2_pulseform, ''),
  NULLIF(attempt2_mode, ''),
  NULLIF(attempt2_shock_joules, ''),

  CASE WHEN trim(attempt2_shock_joules) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(attempt2_shock_joules)::numeric END,
  NULLIF(attempt2_result, ''),

  NULLIF(attempt3_pulseform, ''),
  NULLIF(attempt3_mode, ''),
  NULLIF(attempt3_shock_joules, ''),

  CASE WHEN trim(attempt3_shock_joules) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(attempt3_shock_joules)::numeric END,
  NULLIF(attempt3_result, ''),

  NULLIF(attempt4_pulseform, ''),
  NULLIF(attempt4_mode, ''),
  NULLIF(attempt4_shock_joules, ''),

  CASE WHEN trim(attempt4_shock_joules) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(attempt4_shock_joules)::numeric END,
  NULLIF(attempt4_result, ''),

  NULLIF(rhythm_post_intervention, ''),
  NULLIF(complications, ''),
  NULLIF(tolerance_patient_for_intervention, ''),
  NULLIF(intervention_remarks, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.ic_procedure_note_electric_cardioversion

WHERE NULLIF(order_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_cardioversion_contact
  ON amc_core.ic_procedure_note_electric_cardioversion(patient_contact_id);

