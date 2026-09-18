--===========================================================================

DROP TABLE IF EXISTS amc_core.ic_procedure_note_bronchoscopy CASCADE;

CREATE TABLE amc_core.ic_procedure_note_bronchoscopy (
  patient_contact_id text NOT NULL,
  order_id text NOT NULL,

  pseudo_id text,
  hospital_location text,
  intervention_date_time timestamptz,
  intervention_name text,

  start_procedure text,
  informed_consent text,
  correct_patient text,
  correct_procedure text,
  correct_side text,
  relevant_comorbidity_medication_coagulation_status_allergies text,
  complications_discussed text,
  thrombocytes_higher_than50in_biopsy text,

  waters_set_of_ambu_balloon_connected_and_verified text,
  respirator_at_volume_controlled_with100proc_oxygen text,
  pulse_oximetry_with_qr_tone text,
  two_guedels text,
  broncohoscope_and_tower text,
  growdown_system_and_pot_order text,
  minimum_two_reverse_venous_access text,

  sedation_and_analgesia text,
  vasoactiva text,
  stop_supplementation_stop_insulin text,
  stop_heparin text,
  suction_stomach_throat_mouth text,
  time_out_executed text,

  indication text,
  local_anaesthesia_used text,
  sedation text,
  start_sedation text,
  end_sedation text,
  monitoring_vital_data_during_sedation text,

  level_sedation text,
  level_sedation_all_anesthesia text,
  level_sedation_anxiolysis text,
  level_sedation_deep_sedation text,
  level_sedation_regular_sedation text,

  patient_sedated text,
  local_anaesthesia text,
  analgesics text,
  anesthetic_total_ml text,

  bronchoscope text,
  bronchoscope_number text,
  video_image_documentation text,

  introduction text,
  vocal_cords text,
  trachea text,
  bronchial_tree text,
  location_deviation text,

  intervention text,
  material_submitted_for text,
  complications text,
  end_procedure text,
  tolerance_patient_for_intervention text,
  intervention_remarks text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, order_id)
);

INSERT INTO amc_core.ic_procedure_note_bronchoscopy
SELECT
  patient_contact_id,
  order_id,

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  NULLIF(intervention_date_time, '')::timestamptz,
  NULLIF(intervention_name, ''),

  NULLIF(start_procedure, ''),
  NULLIF(informed_consent, ''),
  NULLIF(correct_patient, ''),
  NULLIF(correct_procedure, ''),
  NULLIF(correct_side, ''),
  NULLIF(relevant_comorbidity_medication_coagulation_status_allergies, ''),
  NULLIF(complications_discussed, ''),
  NULLIF(thrombocytes_higher_than50in_biopsy, ''),

  NULLIF(waters_set_of_ambu_balloon_connected_and_verified, ''),
  NULLIF(respirator_at_volume_controlled_with100proc_oxygen, ''),
  NULLIF(pulse_oximetry_with_qr_tone, ''),
  NULLIF(two_guedels, ''),
  NULLIF(broncohoscope_and_tower, ''),
  NULLIF(growdown_system_and_pot_order, ''),
  NULLIF(minimum_two_reverse_venous_access, ''),

  NULLIF(sedation_and_analgesia, ''),
  NULLIF(vasoactiva, ''),
  NULLIF(stop_supplementation_stop_insulin, ''),
  NULLIF(stop_heparin, ''),
  NULLIF(suction_stomach_throat_mouth, ''),
  NULLIF(time_out_executed, ''),

  NULLIF(indication, ''),
  NULLIF(local_anaesthesia_used, ''),
  NULLIF(sedation, ''),
  NULLIF(start_sedation, ''),
  NULLIF(end_sedation, ''),
  NULLIF(monitoring_vital_data_during_sedation, ''),

  NULLIF(level_sedation, ''),
  NULLIF(level_sedation_all_anesthesia, ''),
  NULLIF(level_sedation_anxiolysis, ''),
  NULLIF(level_sedation_deep_sedation, ''),
  NULLIF(level_sedation_regular_sedation, ''),

  NULLIF(patient_sedated, ''),
  NULLIF(local_anaesthesia, ''),
  NULLIF(analgesics, ''),
  NULLIF(anesthetic_total_ml, ''),

  NULLIF(bronchoscope, ''),
  NULLIF(bronchoscope_number, ''),
  NULLIF(video_image_documentation, ''),

  NULLIF(introduction, ''),
  NULLIF(vocal_cords, ''),
  NULLIF(trachea, ''),
  NULLIF(bronchial_tree, ''),
  NULLIF(location_deviation, ''),

  NULLIF(intervention, ''),
  NULLIF(material_submitted_for, ''),
  NULLIF(complications, ''),
  NULLIF(end_procedure, ''),
  NULLIF(tolerance_patient_for_intervention, ''),
  NULLIF(intervention_remarks, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ic_procedure_note_bronchoscopy

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(order_id, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_bronch_pseudo_id
  ON amc_core.ic_procedure_note_bronchoscopy(pseudo_id);


