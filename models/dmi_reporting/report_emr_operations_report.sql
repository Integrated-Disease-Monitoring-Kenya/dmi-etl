

with daily_reporting as (

    select
        date_key,
        facility_key,
        count(*) as cases_reported
    from {{ ref('fct_emr_case_case') }}
    where date_key is not null
      and facility_key is not null
      and illness_case_id is not null
    group by 1, 2

)

select
    r.date_key,
    d.date,

    r.facility_key,
    f.facility_code::text as mfl_code,
    f.facility_name,
    f.county,
    f.sub_county as subcounty,

    r.cases_reported,
    1 as reporting_facility_count,
    0 as silent_day_flag

from daily_reporting r

left join {{ ref('dim_date') }} d
    on r.date_key = d.date_key

left join {{ ref('dim_emr_facility') }} f
    on r.facility_key = f.facility_key