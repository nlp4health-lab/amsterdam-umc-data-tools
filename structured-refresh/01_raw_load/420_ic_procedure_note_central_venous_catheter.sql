--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_central_venous_catheter;

CREATE TABLE amc_raw.ic_procedure_note_central_venous_catheter (
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
  maximum5persons_present_with_hat_and_mask TEXT,
  severe_coagulation_disorders TEXT,
  v_jugularis_catheter_increased_icp TEXT,
  v_subclavia_catheter_increased_icp TEXT,
  v_femoralis_catheter_higher_infection_risk TEXT,
  cvvh_catheter_at_vena_subclavia TEXT,
  ultrasound_device TEXT,
  work_table TEXT,
  central_line_and_insertion_set_according_to_protocol TEXT,
  sedation_and_analgesia TEXT,
  minimum_two_venous_accessions TEXT,
  heparin_discontinued_1hour_beforehand TEXT,
  time_out_executed TEXT,
  indication TEXT,
  local_anaesthesia TEXT,
  patient_sedated TEXT,
  sedation TEXT,
  level_sedation TEXT,
  level_sedation_all_anesthesia TEXT,
  level_sedation_anxiolysis TEXT,
  level_sedation_regular_sedation TEXT,
  level_sedation_deep_sedation TEXT,
  monitoring_vital_data_during_sedation TEXT,
  start_sedation TEXT,
  analgesics TEXT,
  anesthesia_method TEXT,
  anesthetic_total_ml TEXT,
  pace_threshold_volt TEXT,
  number_cm_inserted TEXT,
  pace_setting_volt TEXT,
  sense_threshold_mv TEXT,
  sense_setting_mv TEXT,
  procedure_prep TEXT,
  patient_position TEXT,
  catheter_type1 TEXT,
  catheter_type2 TEXT,
  location TEXT,
  substantiation_location TEXT,
  catheter_size_fr TEXT,
  catheter_size_cm TEXT,
  catheter_length_cm TEXT,
  depth TEXT,
  ultrasound_guided_puncture TEXT,
  number_attempts TEXT,
  successfully_introduced TEXT,
  picc_line_type TEXT,
  picc_line_location TEXT,
  picc_line_left_right TEXT,
  ecmo_location TEXT,
  ecmo_function TEXT,
  ecmo_maat TEXT,
  ecmo_length TEXT,
  sepsis_peripheral_infusion TEXT,
  infection_infection TEXT,
  fixation TEXT,
  control_post_procedure TEXT,
  end_sedation TEXT,
  complications TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_central_venous_catheter

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_central_venous_catheter;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_date_time,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_central_venous_catheter;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_date_time
FROM amc_raw.ic_procedure_note_central_venous_catheter;

-- 4) Check duplicates by order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_central_venous_catheter
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
FROM amc_raw.ic_procedure_note_central_venous_catheter;

