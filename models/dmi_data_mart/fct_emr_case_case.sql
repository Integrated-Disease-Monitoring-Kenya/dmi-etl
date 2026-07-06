

select
    illness_case_id as case_key,
    illness_case_id,
    case_unique_id,

    date_key,
    epi_week_key,

    facility_key,
    subject_id,
    emr_key,
    age_group_key,

    patient_hash,
    sex,
    dob,
    age,

    interview_date,
    created_date,
    admission_date,
    outpatient_date,
    final_outcome_date,

    status,
    final_outcome,

    admitted_flag,
    days_to_capture,
    days_to_outcome,

    facility_name,
    county,
    subcounty,
    emr_name,

    1 as case_count

from {{ ref('intermediate_emr_case_enriched') }}

where illness_case_id is not null