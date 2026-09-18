--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_intubation;

CREATE TABLE amc_raw.ic_procedure_note_intubation (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  intervention_date_time TEXT,
  order_id TEXT,
  intervention_name TEXT,
  start_procedure TEXT,
  informed_consent TEXT,
  complications_discussed TEXT,
  time_out_executed TEXT,
  correct_patient TEXT,
  correct_procedure TEXT,
  correct_side TEXT,
  relevant_comorbidity_medication_coagulation_status_allergies TEXT,
  expected_difficult_intubation TEXT,
  sedation TEXT,
  muscle_relaxants TEXT,
  local_anaesthesia_total_ml TEXT,
  local_anaesthesia TEXT,
  inductor TEXT,
  neuromuscular_blockade TEXT,
  vasoactivia_noradrenaline_atropine TEXT,
  watset_and_or_ambuballoon TEXT,
  respirator_on_controlled_mode TEXT,
  puseoximetry_noise_activated TEXT,
  capnographer_connected_and_functional TEXT,
  suction_system_with_yankauer TEXT,
  laryngoscope_including_evt_videolaryngoscopy TEXT,
  ventilation_mask_guedell TEXT,
  tubes_stilet_blue_voerder TEXT,
  laryngeal_mask TEXT,
  tube_fixation_plaster TEXT,
  indications TEXT,
  intubation_method TEXT,
  patient_status TEXT,
  preoxygenation TEXT,
  laryngoscope_blade TEXT,
  tubemate_mm TEXT,
  type_tube TEXT,
  number_attempts TEXT,
  ventilation_between_attempts_means TEXT,
  burp TEXT,
  view_of_larynx_by_direct_laryngoscopy TEXT,
  control_intubation TEXT,
  breath_noise TEXT,
  cuff_inflated TEXT,
  tube_fused_with TEXT,
  tube_depth_to_lip_cm TEXT,
  tube_depth_to_teeth_cm TEXT,
  control_photo_assessed_by TEXT,
  findings_xthorax TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_intubation

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_intubation;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_date_time,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_intubation;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_date_time
FROM amc_raw.ic_procedure_note_intubation;

-- 4) Check duplicates by order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_intubation
WHERE order_id IS NOT NULL AND order_id <> ''
GROUP BY order_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

-- 5) Check whether patient_contact_id + intervention_date_time looks unique
SELECT
  count(*) AS n_rows,
  count(DISTINCT (
    coalesce(NULLIF(patient_contact_id,''),'') || '|' ||
    coalesce(NULLIF(intervention_date_time,''),'')
  )) AS distinct_contact_intervention_dt
FROM amc_raw.ic_procedure_note_intubation;

