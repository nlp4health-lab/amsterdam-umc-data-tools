--============================================================
DROP TABLE IF EXISTS amc_raw.ic_procedure_note_icarus;

CREATE TABLE amc_raw.ic_procedure_note_icarus (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  intervention_date_time TEXT,
  order_id TEXT,
  intervention_name TEXT,
  start_procedure TEXT,
  date_time_authorization TEXT,
  informed_consent TEXT,
  complications_discussed TEXT,
  time_out_executed TEXT,
  indication TEXT,
  certified_echographer TEXT,
  conclusion TEXT,
  lung_sliding_left TEXT,
  lung_sliding_right TEXT,
  plaps_left TEXT,
  plaps_right TEXT,
  blue_profile TEXT,
  lung_aeration_score_right_field1 TEXT,
  lung_aeration_score_right_field2 TEXT,
  lung_aeration_score_right_field3 TEXT,
  lung_aeration_score_right_field4 TEXT,
  lung_aeration_score_right_field5 TEXT,
  lung_aeration_score_right_field6 TEXT,
  lung_aeration_score_right_field8 TEXT,
  lung_aeration_score_left_field1 TEXT,
  lung_aeration_score_lefts_field2 TEXT,
  lung_aeration_score_left_field3 TEXT,
  lung_aeration_score_left_field4 TEXT,
  lung_aeration_score_left_field5 TEXT,
  lung_aeration_score_left_field6 TEXT,
  lung_aeration_score_left_field8 TEXT,
  lung_aeration_total_score TEXT,
  left_atrium TEXT,
  right_atrium TEXT,
  left_ventricle TEXT,
  right_ventricle TEXT,
  left_ventricular_function TEXT,
  lvot_diameter_mm TEXT,
  lvot_vti TEXT,
  heart_rate_bpm TEXT,
  cardiac_output_with_vti_liter_per_minute TEXT,
  right_ventricular_function TEXT,
  tapered_mm TEXT,
  mitral_insufficiency TEXT,
  tricuspid_insufficiency TEXT,
  cvd_mm_hg TEXT,
  cvd_source TEXT,
  rsvp TEXT,
  ti_speed TEXT,
  ti_gradient TEXT,
  pericardial_effusion TEXT,
  suspicion_tamponande TEXT,
  vci_measured_cm TEXT,
  vci_collapse_percentage TEXT,
  filling_status TEXT,
  end_procedure TEXT,
  tolerance_patient_for_intervention TEXT,
  intervention_remarks TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ic_procedure_note_icarus

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ic_procedure_note_icarus;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_date_time IS NULL OR intervention_date_time = '') AS null_intervention_date_time,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.ic_procedure_note_icarus;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id,
  count(DISTINCT NULLIF(intervention_date_time,'')) AS distinct_intervention_date_time
FROM amc_raw.ic_procedure_note_icarus;

-- 4) Check duplicates by order_id
SELECT
  order_id,
  count(*) AS n
FROM amc_raw.ic_procedure_note_icarus
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
FROM amc_raw.ic_procedure_note_icarus;

