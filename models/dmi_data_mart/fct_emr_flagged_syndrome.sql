select
    illness_case_id,
    case_unique_id,

    date_key,
    epi_week_key,
    week_number,
    epi_year,
    year,
    month,
    date,

    facility_key,
    facility_name,
    county,
    subcounty,

    subject_id,
    patient_hash,
    sex,
    dob,
    age,
    age_group_key,
    age_group,

    emr_id,
    emr_key,
    emr_name,

    flagged_condition_id,
    condition_id,
    syndrome_name,

    1 as flagged_count

from {{ ref('intermediate_emr_case_syndrome') }}
where syndrome_name is not null