--===========================================================================
DROP TABLE IF EXISTS amc_core.ic_procedure_note_tracheostomy CASCADE;

CREATE TABLE amc_core.ic_procedure_note_tracheostomy (
  order_id text PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
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

  known_difficult_airway text,
  cervical_or_high_thoracic_vertebral_fracture_or_instability text,
  anatomical_abnormalities_neck_or_neck text,
  increased_intracranial_pressure text,
  severe_oxygenationstroornis_pee_phogerd_dan10 text,
  severe_coagulation_disorders text,

  preoxygenation100percent_oxygenation text,
  sedation_and_neuromuscular_blockade text,
  vasoactiva text,

  respirator_at_volume_controlled_with100proc_oxygen text,
  intubation_equipment_reserve_tube text,
  trachea_cannula_insertion_kit text,
  bronchoscope_inclusion_guedels_suction_scissors text,
  minimum_two_venous_accessions text,

  tube_feeding_and_insulin_discontinuation text,
  suction_stomach_throat_nose_cavity text,

  time_out_executed text,
  indication text,
  relative_contraindications text,

  sedation text,
  neuromuscular_blockade text,

  method text,
  note text,

  tracheacanule_type text,
  trachea_cannula_size text,

  echo_guided text,
  bronchoscopy_conducted text,

  number_attempts_raw text,
  number_attempts numeric,

  position_tracheostoma text,
  control_depth text,

  distance_to_carina_cm numeric,

  successful_placement text,
  complications text,

  end_procedure text,
  tolerance_patient_for_intervention text,
  intervention_remarks text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

-- NOTE: no INSERT exists for this table yet (pre-existing gap in the
-- original tables_raw_to_core.sql, carried forward by the migration).
-- amc_core.ic_procedure_note_tracheostomy will be created but stays
-- empty on every refresh until this is written. Raw data is available
-- at amc_raw.ic_procedure_note_tracheostomy (01_raw_load/470_...).

