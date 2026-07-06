select
    c.illness_case_id,
    c.case_unique_id,
    c.date_key,
    c.epi_week_key,
    c.week_number,
    c.epi_year,
    c.facility_key,
    c.facility_name,
    c.county,
    c.subcounty,
    c.subject_id,
    c.patient_hash,
    c.sex,
    c.dob,
    c.age,
    c.age_group_key,
    c.age_group,
    c.emr_id,
    c.emr_key,
    c.emr_name,
    co.complaint_record_id,
    co.complaint_id,
    co.complaint_name,
    co.onset_date,
    co.duration,
    case
        when co.complaint_name = 'Missing/Unknown' then 1
        else 0
    end as missing_complaint_flag,
    1 as complaint_count
from {{ ref('intermediate_emr_case_enriched') }} c

left join {{ ref('stg_emr_complaint') }} co
    on co.case_id = c.case_unique_id
   and coalesce(co.voided, false) = false