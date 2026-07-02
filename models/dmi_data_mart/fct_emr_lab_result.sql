

select
    c.illness_case_id,
    c.case_unique_id,

    d.date_key,

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

    l.lab_record_id,
    l.order_id,
    l.test_name,
    l.unit,
    l.test_result_raw,
    l.test_result_category,
    l.numeric_result,
    l.lab_date,

    case
        when l.test_result_category = 'Positive' then 1
        else 0
    end as positive_count,

    case
        when l.test_result_category = 'Missing' then 1
        else 0
    end as missing_result_flag,

    1 as lab_count

from {{ ref('intermediate_emr_case_enriched') }} c

left join {{ ref('stg_emr_lab') }} l
    on l.case_id = c.case_unique_id
   and coalesce(l.voided, false) = false

left join {{ ref('dim_date') }} d
    on d.date = coalesce(l.lab_date::date, c.interview_date)