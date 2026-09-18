-- patient_not_traceable: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_patient_not_traceable_is_deceased
  ON amc_core.patient_not_traceable(is_deceased);
