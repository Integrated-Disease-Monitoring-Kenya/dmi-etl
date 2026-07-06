select
    id::uuid as risk_factor_uuid,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(risk_factor_id), '') as risk_factor_id,
    nullif(trim(condition), '') as risk_factor,
    coalesce(voided, false) as voided

from {{ source('central_raw_palladium', 'risk_factor') }}