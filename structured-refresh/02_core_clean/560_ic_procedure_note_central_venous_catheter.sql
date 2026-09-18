--===========================================================================
DROP TABLE IF EXISTS amc_core.ic_procedure_note_central_venous_catheter CASCADE;

CREATE TABLE amc_core.ic_procedure_note_central_venous_catheter (
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

  maximum5persons_present_with_hat_and_mask text,
  severe_coagulation_disorders text,

  v_jugularis_catheter_increased_icp text,
  v_subclavia_catheter_increased_icp text,
  v_femoralis_catheter_higher_infection_risk text,
  cvvh_catheter_at_vena_subclavia text,

  ultrasound_device text,
  work_table text,
  central_line_and_insertion_set_according_to_protocol text,

  sedation_and_analgesia text,
  minimum_two_venous_accessions text,
  heparin_discontinued_1hour_beforehand text,
  time_out_executed text,

  indication text,
  local_anaesthesia text,
  patient_sedated text,
  sedation text,

  level_sedation text,
  level_sedation_all_anesthesia text,
  level_sedation_anxiolysis text,
  level_sedation_regular_sedation text,
  level_sedation_deep_sedation text,
  monitoring_vital_data_during_sedation text,

  start_sedation timestamptz,
  end_sedation timestamptz,
  analgesics text,
  anesthesia_method text,

  anesthetic_total_ml numeric,

  pace_threshold_volt numeric,
  number_cm_inserted numeric,
  pace_setting_volt numeric,
  sense_threshold_mv numeric,
  sense_setting_mv numeric,

  procedure_prep text,
  patient_position text,

  catheter_type1 text,
  catheter_type2 text,
  location text,
  substantiation_location text,

  catheter_size_fr text,
  catheter_size_cm numeric,
  catheter_length_cm numeric,
  depth numeric,

  ultrasound_guided_puncture text,

  number_attempts_raw text,
  number_attempts numeric,

  successfully_introduced text,

  picc_line_type text,
  picc_line_location text,
  picc_line_left_right text,

  ecmo_location text,
  ecmo_function text,
  ecmo_maat_raw text,
  ecmo_maat numeric,
  ecmo_length_raw text,
  ecmo_length numeric,
  sepsis_peripheral_infusion text,
  infection_infection text,

  fixation text,
  control_post_procedure text,

  complications text,
  end_procedure timestamptz,
  tolerance_patient_for_intervention text,
  intervention_remarks text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.ic_procedure_note_central_venous_catheter (
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
  maximum5persons_present_with_hat_and_mask,
  severe_coagulation_disorders,
  v_jugularis_catheter_increased_icp,
  v_subclavia_catheter_increased_icp,
  v_femoralis_catheter_higher_infection_risk,
  cvvh_catheter_at_vena_subclavia,
  ultrasound_device,
  work_table,
  central_line_and_insertion_set_according_to_protocol,
  sedation_and_analgesia,
  minimum_two_venous_accessions,
  heparin_discontinued_1hour_beforehand,
  time_out_executed,
  indication,
  local_anaesthesia,
  patient_sedated,
  sedation,
  level_sedation,
  level_sedation_all_anesthesia,
  level_sedation_anxiolysis,
  level_sedation_regular_sedation,
  level_sedation_deep_sedation,
  monitoring_vital_data_during_sedation,
  start_sedation,
  end_sedation,
  analgesics,
  anesthesia_method,
  anesthetic_total_ml,
  pace_threshold_volt,
  number_cm_inserted,
  pace_setting_volt,
  sense_threshold_mv,
  sense_setting_mv,
  procedure_prep,
  patient_position,
  catheter_type1,
  catheter_type2,
  location,
  substantiation_location,
  catheter_size_fr,
  catheter_size_cm,
  catheter_length_cm,
  depth,
  ultrasound_guided_puncture,
  number_attempts_raw,
  number_attempts,
  successfully_introduced,
  picc_line_type,
  picc_line_location,
  picc_line_left_right,
  ecmo_location,
  ecmo_function,
  ecmo_maat_raw, ecmo_maat,
  ecmo_length_raw, ecmo_length,
  sepsis_peripheral_infusion,
  infection_infection,
  fixation,
  control_post_procedure,
  complications,
  end_procedure,
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

  NULLIF(maximum5persons_present_with_hat_and_mask, ''),
  NULLIF(severe_coagulation_disorders, ''),

  NULLIF(v_jugularis_catheter_increased_icp, ''),
  NULLIF(v_subclavia_catheter_increased_icp, ''),
  NULLIF(v_femoralis_catheter_higher_infection_risk, ''),
  NULLIF(cvvh_catheter_at_vena_subclavia, ''),

  NULLIF(ultrasound_device, ''),
  NULLIF(work_table, ''),
  NULLIF(central_line_and_insertion_set_according_to_protocol, ''),

  NULLIF(sedation_and_analgesia, ''),
  NULLIF(minimum_two_venous_accessions, ''),
  NULLIF(heparin_discontinued_1hour_beforehand, ''),
  NULLIF(time_out_executed, ''),

  NULLIF(indication, ''),
  NULLIF(local_anaesthesia, ''),
  NULLIF(patient_sedated, ''),
  NULLIF(sedation, ''),

  NULLIF(level_sedation, ''),
  NULLIF(level_sedation_all_anesthesia, ''),
  NULLIF(level_sedation_anxiolysis, ''),
  NULLIF(level_sedation_regular_sedation, ''),
  NULLIF(level_sedation_deep_sedation, ''),
  NULLIF(monitoring_vital_data_during_sedation, ''),

  NULLIF(start_sedation, '')::timestamptz,
  NULLIF(end_sedation, '')::timestamptz,
  NULLIF(analgesics, ''),
  NULLIF(anesthesia_method, ''),

  CASE WHEN trim(anesthetic_total_ml) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(anesthetic_total_ml)::numeric END,

  CASE WHEN trim(pace_threshold_volt) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(pace_threshold_volt)::numeric END,

  CASE WHEN trim(number_cm_inserted) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(number_cm_inserted)::numeric END,

  CASE WHEN trim(pace_setting_volt) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(pace_setting_volt)::numeric END,

  CASE WHEN trim(sense_threshold_mv) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(sense_threshold_mv)::numeric END,

  CASE WHEN trim(sense_setting_mv) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(sense_setting_mv)::numeric END,

  NULLIF(procedure_prep, ''),
  NULLIF(patient_position, ''),

  NULLIF(catheter_type1, ''),
  NULLIF(catheter_type2, ''),
  NULLIF(location, ''),
  NULLIF(substantiation_location, ''),
  NULLIF(catheter_size_fr, ''),

  CASE WHEN trim(catheter_size_cm) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(catheter_size_cm)::numeric END,

  CASE WHEN trim(catheter_length_cm) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(catheter_length_cm)::numeric END,

  CASE WHEN trim(depth) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(depth)::numeric END,

  NULLIF(ultrasound_guided_puncture, ''),

  NULLIF(number_attempts, ''),

  CASE
    WHEN trim(number_attempts) ~ '^\d+$'
      THEN trim(number_attempts)::numeric
    WHEN trim(number_attempts) ~ '^(\d+)\s+of\s+meer$'
      THEN regexp_replace(trim(number_attempts), '^(\d+).*$', '\1')::numeric
  END,

  NULLIF(successfully_introduced, ''),

  NULLIF(picc_line_type, ''),
  NULLIF(picc_line_location, ''),
  NULLIF(picc_line_left_right, ''),

  NULLIF(ecmo_location, ''),
  NULLIF(ecmo_function, ''),

  NULLIF(ecmo_maat, ''),

  CASE WHEN trim(ecmo_maat) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(ecmo_maat)::numeric END,
  NULLIF(ecmo_length, ''),

  CASE WHEN trim(ecmo_length) ~ '^[-+]?[0-9]*\.?[0-9]+$'
    THEN trim(ecmo_length)::numeric END,

  NULLIF(sepsis_peripheral_infusion, ''),
  NULLIF(infection_infection, ''),

  NULLIF(fixation, ''),
  NULLIF(control_post_procedure, ''),

  NULLIF(complications, ''),
  NULLIF(end_procedure, '')::timestamptz,
  NULLIF(tolerance_patient_for_intervention, ''),
  NULLIF(intervention_remarks, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ic_procedure_note_central_venous_catheter

WHERE NULLIF(order_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_cvc_contact
  ON amc_core.ic_procedure_note_central_venous_catheter(patient_contact_id);

