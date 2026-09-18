--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_tracheostomy;

CREATE TABLE amc_raw.ic_procedure_note_tracheostomy (
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
  known_difficult_airway TEXT,
  cervical_or_high_thoracic_vertebral_fracture_or_instability TEXT,
  anatomical_abnormalities_neck_or_neck TEXT,
  increased_intracranial_pressure TEXT,
  severe_oxygenationstroornis_pee_phogerd_dan10 TEXT,
  severe_coagulation_disorders TEXT,
  preoxygenation100percent_oxygenation TEXT,
  sedation_and_neuromuscular_blockade TEXT,
  vasoactiva TEXT,
  respirator_at_volume_controlled_with100proc_oxygen TEXT,
  intubation_equipment_reserve_tube TEXT,
  trachea_cannula_insertion_kit TEXT,
  bronchoscope_inclusion_guedels_suction_scissors TEXT,
  minimum_two_venous_accessions TEXT,
  tube_feeding_and_insulin_discontinuation TEXT,
  suction_stomach_throat_nose_cavity TEXT,
  time_out_executed TEXT,
  indication TEXT,
  relative_contraindications TEXT,
  sedation TEXT,
  neuromuscular_blockade TEXT,
  method TEXT,
  note TEXT,
  tracheacanule_type TEXT,
  trachea_cannula_size TEXT,
  echo_guided TEXT,
  bronchoscopy_conducted TEXT,
  number_attempts TEXT,
  position_tracheostoma TEXT,
  control_depth TEXT,
  distance_to_carina_cm TEXT,
  successful_placement TEXT,
  complications TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_tracheostomy

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_tracheostomy;

-- Null identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_dt,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_tracheostomy;

-- Identifier cardinality
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_dt
FROM amc_raw.ic_procedure_note_tracheostomy;

-- Duplicate order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_tracheostomy
WHERE order_id IS NOT NULL AND order_id <> ''
GROUP BY order_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

-- Check composite uniqueness
SELECT
  count(*) AS n_rows,
  count(DISTINCT (
    coalesce(NULLIF(patient_contact_id,''),'') || '|' ||
    coalesce(NULLIF(intervention_date_time,''),'')
  )) AS distinct_contact_intervention_dt
FROM amc_raw.ic_procedure_note_tracheostomy;

