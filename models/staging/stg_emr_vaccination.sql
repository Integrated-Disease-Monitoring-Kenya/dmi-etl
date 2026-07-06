select
    id::uuid as vaccination_uuid,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(vaccination_id), '') as vaccination_id,
    nullif(trim(vaccination), '') as vaccination,

    case
        when doses is not null then doses::integer
        else null
    end as doses,

    coalesce(verified, false) as verified,
    coalesce(voided, false) as voided

from {{ source('central_raw_palladium', 'vaccination') }}