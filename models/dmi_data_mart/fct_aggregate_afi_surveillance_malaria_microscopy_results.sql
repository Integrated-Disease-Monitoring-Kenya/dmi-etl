WITH malaria_microscopy_results AS (
   SELECT
     mm.PID,
     mm.site::INT AS mflcode,
     mm.gender,
     mm.calculated_age_days,
     mm.enr_interviewdate,
     mm.screening_date,
     CASE WHEN mm."Final_Result" = '1' THEN 1 
          WHEN mm."Final_Result" = '2' THEN 2 
          ELSE NULL END AS final_result,
     mm.read1_result,
     mm.read2_result, 
       CASE WHEN  mm.consent= 1 then 1 else 0 end as enrolled
   FROM {{ ref('stg_afi_surveillance') }} AS mm
   WHERE mm.consent = 1 and  mm.read1_result is not null and mm.read2_result is not null
)

SELECT 
  COALESCE(gender.gender_key, 'unset') AS gender_key,
  COALESCE(age_group.age_group_key, 'unset') AS age_group_key,
  COALESCE(epi_week.epi_week_key, 'unset') AS epi_week_key,
  COALESCE(facility.facility_key, 'unset') AS facility_key,
  COALESCE(date.date_key, 'unset') AS date_key,
  COALESCE(finalresult.lab_result_key, 'unset') AS lab_final_result_key,
  COALESCE(read1result.lab_result_key, 'unset') AS lab_read1_result_key,
  COALESCE(read2result.lab_result_key, 'unset') AS lab_read2_result_key,
  enrolled AS enrolled,
  PID,
  screening_date,
  current_date AS load_date

FROM malaria_microscopy_results

LEFT JOIN {{ ref('dim_gender') }} AS gender 
  ON gender.code = malaria_microscopy_results.gender

LEFT JOIN {{ ref('dim_age_group_afi') }} AS age_group 
  ON malaria_microscopy_results.calculated_age_days >= age_group.start_age_days 
  AND malaria_microscopy_results.calculated_age_days < age_group.end_age_days

LEFT JOIN {{ ref('dim_epi_week') }} AS epi_week 
  ON malaria_microscopy_results.enr_interviewdate BETWEEN epi_week.start_of_week AND epi_week.end_of_week 

LEFT JOIN {{ ref('dim_facility') }} AS facility 
  ON facility.mfl_code = malaria_microscopy_results.mflcode

LEFT JOIN {{ ref('dim_date') }} AS date 
  ON date.date = malaria_microscopy_results.enr_interviewdate

LEFT JOIN {{ ref('dim_lab_result') }} AS finalresult 
  ON finalresult.code = malaria_microscopy_results.final_result :: int

  LEFT JOIN {{ ref('dim_lab_result') }} AS read1result 
  ON read1result.code = malaria_microscopy_results.read1_result :: int

  LEFT JOIN {{ ref('dim_lab_result') }} AS read2result 
  ON read2result.code = malaria_microscopy_results.read2_result :: int