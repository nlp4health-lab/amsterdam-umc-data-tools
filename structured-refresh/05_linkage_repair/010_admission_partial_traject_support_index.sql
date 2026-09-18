-- Supporting index for every date-range probable_contact_id match in this
-- stage -- created once here rather than repeated in each of the 5
-- per-table files below, since all 5 join against admission_partial_traject
-- the same way (pseudo_id + start_date_time).
CREATE INDEX IF NOT EXISTS idx_admission_partial_traject_pseudo_start
    ON amc_core.admission_partial_traject (pseudo_id, start_date_time);
