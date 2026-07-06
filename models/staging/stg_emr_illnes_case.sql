select
    id::uuid as illness_case_id,
    nullif(trim(case_unique_id), '') as case_unique_id,
    nullif(trim(hospital_id_number), '') as hospital_id_number,

    subject_id::uuid as subject_id,
    emr_id::uuid as emr_id,
    nullif(trim(visit_unique_id), '') as visit_unique_id,

    -- hospital_id_number is the facility/MFL identifier.
    -- Keep as text because some values are non-numeric e.g. IRC-GH01.
    nullif(trim(hospital_id_number), '') as mfl_code,

    interview_date::timestamp as interview_datetime,
    interview_date::date as interview_date,
    admission_date::date as admission_date,
    outpatient_date::date as outpatient_date,

    created_at::timestamp as created_at,
    created_at::date as created_date,
    updated_at::timestamp as updated_at,
    load_date::timestamp as load_date,

    nullif(initcap(trim(final_outcome)), '') as final_outcome,
    final_outcome_date::timestamp as final_outcome_datetime,
    final_outcome_date::date as final_outcome_date,

    coalesce(nullif(lower(trim(status)), ''), 'unknown') as status,

    case when admission_date is not null then 1 else 0 end as admitted_flag,

    case
        when created_at is not null and interview_date is not null
        then created_at::date - interview_date::date
    end as days_to_capture,

    case
        when final_outcome_date is not null and interview_date is not null
        then final_outcome_date::date - interview_date::date
    end as days_to_outcome

from {{ source('central_raw_palladium', 'illness_case') }}