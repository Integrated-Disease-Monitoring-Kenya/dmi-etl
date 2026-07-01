
select
    id::uuid as lab_record_id,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(order_id), '') as order_id,
    coalesce(nullif(initcap(trim(test_name)), ''), 'Unknown Test') as test_name,
    nullif(trim(test_result), '') as test_result_raw,
    case
        when lower(trim(test_result)) in ('positive', 'pos', 'detected', 'reactive') then 'Positive'
        when lower(trim(test_result)) in ('negative', 'neg', 'not detected', 'non-reactive') then 'Negative'
        when lower(trim(test_result)) in ('indeterminate', 'inconclusive') then 'Indeterminate'
        when nullif(trim(test_result), '') is null then 'Missing'
        when trim(test_result) ~ '^-?[0-9]+(\.[0-9]+)?$' then 'Numeric'
        else 'Other'
    end as test_result_category,
    case when trim(test_result) ~ '^-?[0-9]+(\.[0-9]+)?$' then test_result::numeric end as numeric_result,
    nullif(trim(unit), '') as unit,
    case when trim(upper_limit) ~ '^-?[0-9]+(\.[0-9]+)?$' then upper_limit::numeric end as upper_limit,
    case when trim(lower_limit) ~ '^-?[0-9]+(\.[0-9]+)?$' then lower_limit::numeric end as lower_limit,
    lab_date::timestamp as lab_datetime,
    lab_date::date as lab_date,
    coalesce(voided, false) as voided
from {{ source('central_raw_palladium', 'lab') }}