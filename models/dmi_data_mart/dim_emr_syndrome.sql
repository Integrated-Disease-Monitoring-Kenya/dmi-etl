select distinct
    {{ dbt_utils.surrogate_key([
        'condition_id',
        'syndrome_name'
    ]) }} as syndrome_key,

    condition_id,
    syndrome_name

from {{ ref('stg_emr_flagged_condition') }}

where syndrome_name is not null