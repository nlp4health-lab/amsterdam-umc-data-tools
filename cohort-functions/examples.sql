-- =====================================================================
-- cohort-functions/examples.sql
-- A few realistic cohort queries combining cohort_functions.* calls.
-- Run these by hand (\i cohort-functions/examples.sql, or paste
-- individual queries) -- not a script that does anything on its own.
-- =====================================================================

-- Example 1: heart failure, primary diagnosis only, any time.
SELECT pseudo_id
FROM cohort_functions.cohort_by_diagnosis_code('I50%', true);

-- Example 2: patients with any lab or medication activity in a
-- specific quarter.
SELECT pseudo_id
FROM cohort_functions.cohort_active_in_range(
    ARRAY['lab', 'medication'], '2024-01-01', '2024-03-31'
);

-- Example 3 ("lab meeting" case): heart failure (primary diagnosis),
-- restricted to patients with a hospital stay (admission, ward segment,
-- or ED visit) active during the same window as the diagnosis date
-- bound.
SELECT pseudo_id
FROM cohort_functions.cohort_by_diagnosis_code(
    'I50%', true, '2023-01-01', '2024-01-01'
)
INTERSECT
SELECT pseudo_id
FROM cohort_functions.cohort_active_in_range(
    ARRAY['stay'], '2023-01-01', '2024-01-01'
);

-- Example 4: heart failure patients, searched by clinical term instead
-- of ICD code.
SELECT pseudo_id
FROM cohort_functions.cohort_by_diagnosis_text('hartfalen', true);

-- Example 5: patients tested for troponin in a specific month.
SELECT pseudo_id
FROM cohort_functions.cohort_by_lab_test('troponine', '2024-01-01', '2024-01-31');

-- Example 6: full timeline detail for a cohort you've already built --
-- every stay and lab event, in one export-ready result.
SELECT *
FROM cohort_functions.timeline_for_cohort(
    ARRAY(SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code(
        'I50%', true, '2023-01-01', '2024-01-01'
    )),
    ARRAY['stay', 'lab'],
    '2023-01-01', '2024-01-01'
);

-- Example 7: structured + unstructured combined -- heart failure
-- patients (coded diagnosis) whose notes also mention delirium, a
-- concept that may never have been formally coded as its own
-- diagnosis. Neither function alone can answer this; INTERSECT is all
-- that's needed to combine them.
SELECT pseudo_id
FROM cohort_functions.cohort_by_diagnosis_code('I50%', true)
INTERSECT
SELECT pseudo_id
FROM cohort_functions.cohort_by_note_text('delier');

-- Example 8: export a cohort's pseudo_id list to CSV -- opens directly
-- in Excel/Sheets. \copy runs client-side (your machine, not the
-- server), so the file lands wherever you ran psql from.
\copy (SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code('I50%', true)) TO 'cohort.csv' WITH (FORMAT csv, HEADER true)

-- Example 9: export the same cohort as one JSON array, via a wrapping
-- json_agg.
\copy (SELECT json_agg(t) FROM (SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code('I50%', true)) t) TO 'cohort.json'

-- Example 10: export timeline_for_cohort's full detail as JSONL (one
-- JSON object per line, via row_to_json) -- the more useful shape for
-- row detail than a single JSON array, e.g. for feeding a downstream
-- pipeline one event at a time.
\copy (
  SELECT row_to_json(t) FROM (
    SELECT * FROM cohort_functions.timeline_for_cohort(
      ARRAY(SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code('I50%', true)),
      ARRAY['stay', 'lab']
    )
  ) t
) TO 'cohort_timeline.jsonl'
