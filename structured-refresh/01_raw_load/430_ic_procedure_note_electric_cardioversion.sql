--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_electric_cardioversion;

CREATE TABLE amc_raw.ic_procedure_note_electric_cardioversion (
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
  svt_without_anti_coagulation TEXT,
  crash_cart_with_defibrillator TEXT,
  defibrillator_on_synchronous_mode TEXT,
  waters_set_of_ambu_balloon TEXT,
  suction_system_with_yankauer TEXT,
  sedativa_and_algetics TEXT,
  vasoactivia_noradrenaline_atropine TEXT,
  preoxygenation100percent_oxygenation TEXT,
  tube_feeding_and_insulin_discontinuation TEXT,
  timeout_executed TEXT,
  analgesics TEXT,
  sedation TEXT,
  patient_sedated TEXT,
  level_sedation TEXT,
  level_sedation_regular_sedation TEXT,
  level_sedation_all_anesthesia TEXT,
  level_sedation_anxiolysis TEXT,
  level_sedation_deep_sedation TEXT,
  monitoring_vital_data_during_sedation TEXT,
  start_sedation TEXT,
  end_sedation TEXT,
  patient_sober TEXT,
  procedural_rhythm TEXT,
  supine TEXT,
  thorax_ontblood TEXT,
  type_electrodes TEXT,
  location_electrodes TEXT,
  indication TEXT,
  number_attempts TEXT,
  attempt1_pulseform TEXT,
  attempt1_mode TEXT,
  attempt1_shock_joules TEXT,
  attempt1_result TEXT,
  attempt2_pulseform TEXT,
  attempt2_mode TEXT,
  attempt2_shock_joules TEXT,
  attempt2_result TEXT,
  attempt3_pulseform TEXT,
  attempt3_mode TEXT,
  attempt3_shock_joules TEXT,
  attempt3_result TEXT,
  attempt4_pulseform TEXT,
  attempt4_mode TEXT,
  attempt4_shock_joules TEXT,
  attempt4_result TEXT,
  rhythm_post_intervention TEXT,
  complications TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_electric_cardioversion

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_electric_cardioversion;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_date_time,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_electric_cardioversion;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_date_time
FROM amc_raw.ic_procedure_note_electric_cardioversion;

-- 4) Check duplicates by order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_electric_cardioversion
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
FROM amc_raw.ic_procedure_note_electric_cardioversion;

