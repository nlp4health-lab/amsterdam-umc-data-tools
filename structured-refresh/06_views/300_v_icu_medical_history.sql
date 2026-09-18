-------------------------------------------------------------------------------------------------------
-- ICU Medical History includes medical history items (medical, surgical, family history) for patients with an ICU stay, regardless of whether the history item was registered during the ICU stay or not. This allows for a more comprehensive view of the patient's medical background in the context of their ICU admission.
DROP VIEW IF EXISTS amc_views.v_icu_medical_history;

CREATE VIEW amc_views.v_icu_medical_history AS

SELECT
    h.*
FROM amc_views.v_medical_history h
WHERE EXISTS (
    SELECT 1
    FROM amc_views.v_icu_stays icu
    WHERE icu.pseudo_id = h.pseudo_id
);
