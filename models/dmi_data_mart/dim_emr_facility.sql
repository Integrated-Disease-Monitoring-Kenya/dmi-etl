
select
    {{ dbt_utils.surrogate_key(['"Code"']) }} as facility_key,

    "Code"::integer as facility_code,
    nullif(trim("Facility Name"), '') as facility_name,
    nullif(trim("Province"), '') as province,
    nullif(trim("County"), '') as county,
    nullif(trim("Sub County"), '') as sub_county,
    nullif(trim("Ward"), '') as ward

from {{ ref('facility_list') }}