select
    id::uuid as diagnosis_record_id,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(diagnosis_id), '') as diagnosis_id,
    coalesce(nullif(initcap(trim(diagnosis)), ''), 'Missing/Unknown') as diagnosis_text,
    diagnosis_date::timestamp as diagnosis_datetime,
    diagnosis_date::date as diagnosis_date,
    coalesce(nullif(upper(trim(system)), ''), 'UNKNOWN') as system,
    nullif(trim(system_code), '') as system_code,
    coalesce(voided, false) as voided
from {{ source('central_raw_palladium', 'diagnosis') }}
