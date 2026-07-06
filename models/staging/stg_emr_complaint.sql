select
    id::uuid as complaint_record_id,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(complaint_id), '') as complaint_id,
    coalesce(nullif(initcap(trim(complaint)), ''), 'Missing/Unknown') as complaint_name,
    onset_date::date as onset_date,
    duration::integer as duration,
    coalesce(voided, false) as voided
from {{ source('central_raw_palladium', 'complaint') }}
