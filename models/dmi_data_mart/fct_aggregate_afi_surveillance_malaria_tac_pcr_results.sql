WITH malaria_tac_pcr_results AS (
   SELECT
     tac_mm.PID,
     tac_mm.site::INT AS mflcode,
     tac_mm.gender,
     tac_mm.calculated_age_days,
     tac_mm.enr_interviewdate,
     tac_mm.screening_date,
       CASE WHEN tac_mm."TacResult" = 'Positive' THEN 1 
          WHEN tac_mm."TacResult" = 'Negative' THEN 2 
          ELSE NULL END AS tac_result,
   CASE WHEN tac_mm."TACmalariaResult" = 'Positive' THEN 1 
          WHEN tac_mm."TACmalariaResult" = 'Negative' THEN 2 
          ELSE NULL END AS tac_malaria_result,
       CASE WHEN  tac_mm.consent= 1 then 1 else 0 end as enrolled
   FROM {{ ref('stg_afi_surveillance') }} AS tac_mm
   WHERE tac_mm.consent = 1 and  tac_mm."TacResult" is not null 
)
SELECT 
  COALESCE(gender.gender_key, 'unset') AS gender_key,
  COALESCE(age_group.age_group_key, 'unset') AS age_group_key,
  COALESCE(epi_week.epi_week_key, 'unset') AS epi_week_key,
  COALESCE(facility.facility_key, 'unset') AS facility_key,
  COALESCE(result_tac.lab_result_key, 'unset') AS tac_result_key,
  COALESCE(result_tac_malaria.lab_result_key, 'unset') AS tac_malaria_result_key,
  COALESCE(date.date_key, 'unset') AS date_key,
  screening_date,
  enrolled AS enrolled,
  PID,
  current_date AS load_date
FROM malaria_tac_pcr_results
LEFT JOIN {{ ref('dim_gender') }} AS gender 
  ON gender.code = malaria_tac_pcr_results.gender
LEFT JOIN {{ ref('dim_age_group_afi') }} AS age_group 
  ON malaria_tac_pcr_results.calculated_age_days >= age_group.start_age_days 
  AND malaria_tac_pcr_results.calculated_age_days < age_group.end_age_days
LEFT JOIN {{ ref('dim_epi_week') }} AS epi_week 
  ON malaria_tac_pcr_results.enr_interviewdate BETWEEN epi_week.start_of_week AND epi_week.end_of_week 
LEFT JOIN {{ ref('dim_facility') }} AS facility 
  ON facility.mfl_code = malaria_tac_pcr_results.mflcode
LEFT JOIN {{ ref('dim_date') }} AS date 
  ON date.date = malaria_tac_pcr_results.enr_interviewdate
LEFT JOIN {{ ref('dim_lab_result') }} AS result_tac 
  ON result_tac.code = malaria_tac_pcr_results.tac_result :: int
LEFT JOIN {{ ref('dim_lab_result') }} AS result_tac_malaria 
  ON result_tac_malaria.code = malaria_tac_pcr_results.tac_malaria_result:: int
 