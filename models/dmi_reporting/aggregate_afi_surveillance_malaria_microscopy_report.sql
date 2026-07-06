SELECT 
PID,
gender.gender_2  as gender,
facility.facility_name,
age_group.age_group_category,
epi_week.week_number,
date.year,
date.month,

finalresult.lab_result as final_resultresult,
read1result.lab_result as read1_result,
read2result.lab_result as read2_result,
malaria_microscopy_results.screening_date,
malaria_microscopy_results.enrolled,

cast(current_date as date) as load_date
FROM 
{{ ref('fct_aggregate_afi_surveillance_malaria_microscopy_results') }} as malaria_microscopy_results


left join {{ ref('dim_gender') }} as gender on gender.gender_key = malaria_microscopy_results.gender_key 
left join {{ ref('dim_age_group_afi') }} as age_group on age_group.age_group_key = malaria_microscopy_results.age_group_key
left join {{ ref('dim_facility') }} as facility on facility.facility_key = malaria_microscopy_results.facility_key
left join {{ ref('dim_epi_week')}} as epi_week on epi_week.epi_week_key = malaria_microscopy_results.epi_week_key
left join {{ ref('dim_date') }} as date on date.date_key = malaria_microscopy_results.date_key

  left join {{ ref('dim_lab_result') }} as finalresult on finalresult.lab_result_key = malaria_microscopy_results.lab_final_result_key

  left join {{ ref('dim_lab_result') }} as read1result  on read1result.lab_result_key = malaria_microscopy_results.lab_read1_result_key

  left join {{ ref('dim_lab_result') }} as read2result  on read2result.lab_result_key = malaria_microscopy_results.lab_read2_result_key