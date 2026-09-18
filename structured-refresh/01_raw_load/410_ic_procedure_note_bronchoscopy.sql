--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_bronchoscopy;

CREATE TABLE amc_raw.ic_procedure_note_bronchoscopy (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  intervention_date_time TEXT,
  order_id TEXT,
  intervention_name TEXT,
  start_procedure TEXT,
  informed_consent TEXT,
  correct_patient TEXT,
  correct_procedure TEXT,
  correct_side TEXT,
  relevant_comorbidity_medication_coagulation_status_allergies TEXT,
  complications_discussed TEXT,
  thrombocytes_higher_than50in_biopsy TEXT,
  waters_set_of_ambu_balloon_connected_and_verified TEXT,
  respirator_at_volume_controlled_with100proc_oxygen TEXT,
  pulse_oximetry_with_qr_tone TEXT,
  two_guedels TEXT,
  broncohoscope_and_tower TEXT,
  growdown_system_and_pot_order TEXT,
  minimum_two_reverse_venous_access TEXT,
  sedation_and_analgesia TEXT,
  vasoactiva TEXT,
  stop_supplementation_stop_insulin TEXT,
  stop_heparin TEXT,
  suction_stomach_throat_mouth TEXT,
  time_out_executed TEXT,
  indication TEXT,
  local_anaesthesia_used TEXT,
  sedation TEXT,
  start_sedation TEXT,
  end_sedation TEXT,
  monitoring_vital_data_during_sedation TEXT,
  level_sedation TEXT,
  level_sedation_all_anesthesia TEXT,
  level_sedation_anxiolysis TEXT,
  level_sedation_deep_sedation TEXT,
  level_sedation_regular_sedation TEXT,
  patient_sedated TEXT,
  local_anaesthesia TEXT,
  analgesics TEXT,
  anesthetic_total_ml TEXT,
  bronchoscope TEXT,
  bronchoscope_number TEXT,
  video_image_documentation TEXT,
  introduction TEXT,
  vocal_cords TEXT,
  trachea TEXT,
  bronchial_tree TEXT,
  location_deviation TEXT,
  intervention TEXT,
  material_submitted_for TEXT,
  complications TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_bronchoscopy

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_bronchoscopy;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_date_time,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_bronchoscopy;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_date_time
FROM amc_raw.ic_procedure_note_bronchoscopy;

-- 4) Check duplicates by order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_bronchoscopy
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
FROM amc_raw.ic_procedure_note_bronchoscopy;

