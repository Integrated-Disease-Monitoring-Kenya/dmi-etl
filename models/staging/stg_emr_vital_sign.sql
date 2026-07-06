-- models/staging/raw_emr/stg_emr_vital_sign.sql

select
    id::uuid as vital_sign_id,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(vital_sign_id), '') as source_vital_sign_id,

    temperature::double precision as temperature,
    nullif(trim(temperature_mode), '') as temperature_mode,

    respiratory_rate::integer as respiratory_rate,
    oxygen_saturation::integer as oxygen_saturation,
    nullif(trim(oxygen_saturation_mode), '') as oxygen_saturation_mode,

    coalesce(voided, false) as voided,

    case
        when vital_sign_date is not null
        then vital_sign_date::timestamp::date
        else null
    end as vital_sign_date

from {{ source('central_raw_palladium', 'vital_sign') }}