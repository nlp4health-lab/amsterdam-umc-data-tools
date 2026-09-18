--===========================================================================
DROP TABLE IF EXISTS amc_core.medication_atc CASCADE;

CREATE TABLE amc_core.medication_atc (
  atc_code text PRIMARY KEY,

  atc_name text,
  atc_label text,

  atc_name_niv1 text,
  atc_code_niv1 text,

  atc_name_niv2 text,
  atc_code_niv2 text,

  atc_name_niv3 text,
  atc_code_niv3 text,

  atc_name_niv4 text,
  atc_code_niv4 text,

  atc_name_niv5 text,
  atc_code_niv5 text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date
);

INSERT INTO amc_core.medication_atc (
  atc_code,
  atc_name,
  atc_label,
  atc_name_niv1,
  atc_code_niv1,
  atc_name_niv2,
  atc_code_niv2,
  atc_name_niv3,
  atc_code_niv3,
  atc_name_niv4,
  atc_code_niv4,
  atc_name_niv5,
  atc_code_niv5,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(atc_code, ''),
  NULLIF(atc_name, ''),
  NULLIF(atc_label, ''),

  NULLIF(atc_name_niv1, ''),
  NULLIF(atc_code_niv1, ''),

  NULLIF(atc_name_niv2, ''),
  NULLIF(atc_code_niv2, ''),

  NULLIF(atc_name_niv3, ''),
  NULLIF(atc_code_niv3, ''),

  NULLIF(atc_name_niv4, ''),
  NULLIF(atc_code_niv4, ''),

  NULLIF(atc_name_niv5, ''),
  NULLIF(atc_code_niv5, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.medication_atc

WHERE NULLIF(atc_code, '') IS NOT NULL;

