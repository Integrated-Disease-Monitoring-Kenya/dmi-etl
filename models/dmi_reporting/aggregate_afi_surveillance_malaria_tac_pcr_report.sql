SELECT 
PID,
gender.gender_2  as gender,
facility.facility_name,
age_group.age_group_category,
epi_week.week_number,
date.year,
date.month,
tac_result.lab_result as tac_result,
tac_malaria_result.lab_result as tac_malaria_result,
malaria_tac_pcr_results.enrolled,
malaria_tac_pcr_results.screening_date,
cast(current_date as date) as load_date
FROM 
{{ ref('fct_aggregate_afi_surveillance_malaria_tac_pcr_results') }} as malaria_tac_pcr_results


left join {{ ref('dim_gender') }} as gender on gender.gender_key = malaria_tac_pcr_results.gender_key 
left join {{ ref('dim_age_group_afi') }} as age_group on age_group.age_group_key = malaria_tac_pcr_results.age_group_key
left join {{ ref('dim_facility') }} as facility on facility.facility_key = malaria_tac_pcr_results.facility_key
left join {{ ref('dim_epi_week')}} as epi_week on epi_week.epi_week_key = malaria_tac_pcr_results.epi_week_key
left join {{ ref('dim_date') }} as date on date.date_key = malaria_tac_pcr_results.date_key
left join {{ ref('dim_lab_result') }} as tac_result on tac_result.lab_result_key = malaria_tac_pcr_results.tac_result_key
left join {{ ref('dim_lab_result') }} as tac_malaria_result  on tac_malaria_result.lab_result_key = malaria_tac_pcr_results.tac_malaria_result_key

