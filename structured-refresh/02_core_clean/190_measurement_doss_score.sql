--===========================================================================

DROP TABLE IF EXISTS amc_core.measurement_doss_score CASCADE;

CREATE TABLE amc_core.measurement_doss_score (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  dos_total numeric,
  doss_average24h numeric,
  doss_average24uur0730to0730 numeric,

  sink text,
  derived text,
  attention text,
  no_question text,
  non_fitting_answers text,
  slow_respond text,
  elsewhere text,
  daily text,
  reminder text,
  picking_behaviour text,
  drip_plugging text,
  quickly_emotional text,
  seeing_or_hearing_things text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_doss_score (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  dos_total,
  doss_average24h,
  doss_average24uur0730to0730,
  sink,
  derived,
  attention,
  no_question,
  non_fitting_answers,
  slow_respond,
  elsewhere,
  daily,
  reminder,
  picking_behaviour,
  drip_plugging,
  quickly_emotional,
  seeing_or_hearing_things,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  patient_contact_id,
  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,

  CASE
    WHEN trim(dos_total) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(dos_total)::numeric
    ELSE NULL
  END,

  CASE
    WHEN trim(doss_average24h) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(doss_average24h)::numeric
    ELSE NULL
  END,

  CASE
    WHEN trim(doss_average24uur0730to0730) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(doss_average24uur0730to0730)::numeric
    ELSE NULL
  END,

  NULLIF(sink, ''),
  NULLIF(derived, ''),
  NULLIF(attention, ''),
  NULLIF(no_question, ''),
  NULLIF(non_fitting_answers, ''),
  NULLIF(slow_respond, ''),
  NULLIF(elsewhere, ''),
  NULLIF(daily, ''),
  NULLIF(reminder, ''),
  NULLIF(picking_behaviour, ''),
  NULLIF(drip_plugging, ''),
  NULLIF(quickly_emotional, ''),
  NULLIF(seeing_or_hearing_things, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_doss_score

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_doss_pseudo_id
  ON amc_core.measurement_doss_score(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_doss_contact_id
  ON amc_core.measurement_doss_score(patient_contact_id); 


