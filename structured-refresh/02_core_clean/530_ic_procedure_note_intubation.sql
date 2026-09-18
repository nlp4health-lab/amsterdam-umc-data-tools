--===========================================================================
DROP TABLE IF EXISTS amc_core.ic_procedure_note_intubation CASCADE;

CREATE TABLE amc_core.ic_procedure_note_intubation (
  order_id text PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  intervention_date_time timestamptz,
  intervention_name text,

  start_procedure text,
  informed_consent text,
  complications_discussed text,
  time_out_executed text,

  correct_patient text,
  correct_procedure text,
  correct_side text,
  relevant_comorbidity_medication_coagulation_status_allergies text,

  expected_difficult_intubation text,
  sedation text,
  muscle_relaxants text,

  local_anaesthesia_total_ml numeric,
  local_anaesthesia text,
  inductor text,
  neuromuscular_blockade text,
  vasoactivia_noradrenaline_atropine text,

  watset_and_or_ambuballoon text,
  respirator_on_controlled_mode text,
  puseoximetry_noise_activated text,
  capnographer_connected_and_functional text,
  suction_system_with_yankauer text,
  laryngoscope_including_evt_videolaryngoscopy text,
  ventilation_mask_guedell text,
  tubes_stilet_blue_voerder text,
  laryngeal_mask text,
  tube_fixation_plaster text,

  indications text,
  intubation_method text,
  patient_status text,
  preoxygenation text,

  laryngoscope_blade text,
  tubemate_mm_raw text,
  tubemate_mm numeric,
  type_tube text,

  number_attempts_raw text,
  number_attempts numeric,
  ventilation_between_attempts_means text,
  burp text,
  view_of_larynx_by_direct_laryngoscopy text,

  control_intubation text,
  breath_noise text,
  cuff_inflated text,
  tube_fused_with text,

  tube_depth_to_lip_cm numeric,
  tube_depth_to_teeth_cm numeric,

  control_photo_assessed_by text,
  findings_xthorax text,

  end_procedure text,
  tolerance_patient_for_intervention text,
  intervention_remarks text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.ic_procedure_note_intubation (
  order_id,
  pseudo_id,
  patient_contact_id,
  hospital_location,
  intervention_date_time,
  intervention_name,
  start_procedure,
  informed_consent,
  complications_discussed,
  time_out_executed,
  correct_patient,
  correct_procedure,
  correct_side,
  relevant_comorbidity_medication_coagulation_status_allergies,
  expected_difficult_intubation,
  sedation,
  muscle_relaxants,
  local_anaesthesia_total_ml,
  local_anaesthesia,
  inductor,
  neuromuscular_blockade,
  vasoactivia_noradrenaline_atropine,
  watset_and_or_ambuballoon,
  respirator_on_controlled_mode,
  puseoximetry_noise_activated,
  capnographer_connected_and_functional,
  suction_system_with_yankauer,
  laryngoscope_including_evt_videolaryngoscopy,
  ventilation_mask_guedell,
  tubes_stilet_blue_voerder,
  laryngeal_mask,
  tube_fixation_plaster,
  indications,
  intubation_method,
  patient_status,
  preoxygenation,
  laryngoscope_blade,
  tubemate_mm_raw, tubemate_mm,
  type_tube,
  number_attempts_raw,
  number_attempts,
  ventilation_between_attempts_means,
  burp,
  view_of_larynx_by_direct_laryngoscopy,
  control_intubation,
  breath_noise,
  cuff_inflated,
  tube_fused_with,
  tube_depth_to_lip_cm,
  tube_depth_to_teeth_cm,
  control_photo_assessed_by,
  findings_xthorax,
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

  NULLIF(start_procedure, ''),
  NULLIF(informed_consent, ''),
  NULLIF(complications_discussed, ''),
  NULLIF(time_out_executed, ''),

  NULLIF(correct_patient, ''),
  NULLIF(correct_procedure, ''),
  NULLIF(correct_side, ''),
  NULLIF(relevant_comorbidity_medication_coagulation_status_allergies, ''),

  NULLIF(expected_difficult_intubation, ''),
  NULLIF(sedation, ''),
  NULLIF(muscle_relaxants, ''),

  CASE WHEN trim(local_anaesthesia_total_ml) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
    THEN trim(local_anaesthesia_total_ml)::numeric END,

  NULLIF(local_anaesthesia, ''),
  NULLIF(inductor, ''),
  NULLIF(neuromuscular_blockade, ''),
  NULLIF(vasoactivia_noradrenaline_atropine, ''),

  NULLIF(watset_and_or_ambuballoon, ''),
  NULLIF(respirator_on_controlled_mode, ''),
  NULLIF(puseoximetry_noise_activated, ''),
  NULLIF(capnographer_connected_and_functional, ''),
  NULLIF(suction_system_with_yankauer, ''),
  NULLIF(laryngoscope_including_evt_videolaryngoscopy, ''),
  NULLIF(ventilation_mask_guedell, ''),
  NULLIF(tubes_stilet_blue_voerder, ''),
  NULLIF(laryngeal_mask, ''),
  NULLIF(tube_fixation_plaster, ''),

  NULLIF(indications, ''),
  NULLIF(intubation_method, ''),
  NULLIF(patient_status, ''),
  NULLIF(preoxygenation, ''),

  NULLIF(laryngoscope_blade, ''),

  NULLIF(tubemate_mm, ''),

  CASE WHEN trim(tubemate_mm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
    THEN trim(tubemate_mm)::numeric END,

  NULLIF(type_tube, ''),

  NULLIF(number_attempts, '') AS number_attempts_raw,

  CASE
    WHEN trim(number_attempts) ~ '^\d+$'
      THEN trim(number_attempts)::numeric
    WHEN trim(number_attempts) ~ '^(\d+)\s+of\s+meer$'
      THEN regexp_replace(trim(number_attempts), '^(\d+).*$', '\1')::numeric
  END,

  NULLIF(ventilation_between_attempts_means, ''),
  NULLIF(burp, ''),
  NULLIF(view_of_larynx_by_direct_laryngoscopy, ''),

  NULLIF(control_intubation, ''),
  NULLIF(breath_noise, ''),
  NULLIF(cuff_inflated, ''),
  NULLIF(tube_fused_with, ''),

  CASE WHEN trim(tube_depth_to_lip_cm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
    THEN trim(tube_depth_to_lip_cm)::numeric END,

  CASE WHEN trim(tube_depth_to_teeth_cm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
    THEN trim(tube_depth_to_teeth_cm)::numeric END,

  NULLIF(control_photo_assessed_by, ''),
  NULLIF(findings_xthorax, ''),

  NULLIF(end_procedure, ''),
  NULLIF(tolerance_patient_for_intervention, ''),
  NULLIF(intervention_remarks, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ic_procedure_note_intubation

WHERE NULLIF(order_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_intubation_contact
  ON amc_core.ic_procedure_note_intubation(patient_contact_id);

