--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_thorax_drain;

CREATE TABLE amc_raw.ic_procedure_note_thorax_drain (
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
  severe_coagulation_disorders TEXT,
  sedation_and_analgesia TEXT,
  thorax_suction_drainage_set TEXT,
  sterile_gloves_coat_cloths_chlorhexide_at_alcohol70percent TEXT,
  non_soluble_suture TEXT,
  wound_care_kit TEXT,
  kelly_clip TEXT,
  thoracic_drain_of_pneumocath TEXT,
  lolale_anesthetics_puller_syringe_green_needle TEXT,
  pneumothorax_insertion_kit TEXT,
  tiewraps_and_tightening_gun TEXT,
  minimum_two_venous_accessions TEXT,
  determine_position_thoraxdrain_and_position_patint TEXT,
  pulse_oximetry TEXT,
  time_out_executed TEXT,
  indications TEXT,
  indication_hemoneumothorax TEXT,
  indication_clap_lung TEXT,
  indication_pleural_effusion TEXT,
  indication_chylothorax TEXT,
  indication_hemothorax TEXT,
  indication_emypeem TEXT,
  indication_stress_pneumothorax TEXT,
  sedation TEXT,
  start_sedation TEXT,
  end_sedation TEXT,
  anesthesia_method TEXT,
  local_anaesthesia TEXT,
  anesthetic_total_ml TEXT,
  patient_sedated TEXT,
  level_sedation TEXT,
  level_sedation_all_anesthesia TEXT,
  level_sedation_anxiolysis TEXT,
  level_sedation_regular_sedation TEXT,
  level_sedation_deep_sedation TEXT,
  monitoring_vital_data_during_sedation TEXT,
  analgesics TEXT,
  preparation TEXT,
  thoraxdrain_location TEXT,
  orientation_drain TEXT,
  size_scalpel TEXT,
  type_drain TEXT,
  size_drain_french TEXT,
  catheter_size TEXT,
  method_dissection TEXT,
  echo_guided TEXT,
  aspect_drainage TEXT,
  quantity_drainage TEXT,
  suture TEXT,
  bandage TEXT,
  radiographic_findings TEXT,
  radiographic_findings_repositioned TEXT,
  radio_findings_good_position TEXT,
  complications TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_thorax_drain

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_thorax_drain;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_date_time,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_thorax_drain;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_date_time
FROM amc_raw.ic_procedure_note_thorax_drain;

-- 4) Check duplicates by order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_thorax_drain
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
FROM amc_raw.ic_procedure_note_thorax_drain;

