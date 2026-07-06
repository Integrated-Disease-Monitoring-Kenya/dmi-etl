
select
    {{ dbt_utils.surrogate_key(['"Mfl Code"']) }} as facility_key,

    "Mfl Code"::integer as facility_code,
    nullif(trim("Facility"), '') as facility_name,
    nullif(trim("County"), '') as county,
    nullif(trim("Sub County"), '') as sub_county,
    nullif(trim("Emr Site"), '') as emr_site,
    nullif(trim("Keph Level"), '') as keph_level,
    nullif(trim("Partner"), '') as partner

from {{ ref('facility_wide_implementing_list') }}