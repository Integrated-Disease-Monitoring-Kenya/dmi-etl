select distinct
    {{ dbt_utils.surrogate_key([
        'test_name',
        'unit'
    ]) }} as lab_test_key,

    test_name,
    unit

from {{ ref('stg_emr_lab') }}