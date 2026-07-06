

with expected as (

    select
        facility_key,
        facility_name,
        county,
        sub_county,
        1 as expected_flag
    from {{ ref('dim_emr_implementing_facility') }}
    where facility_key is not null

),

reported as (

    select
        year,
        month,
        facility_key,
        max(facility_name) as facility_name,
        max(county) as county,
        max(subcounty) as sub_county,
        count(distinct date) as reporting_days,
        sum(flagged_cases) as total_flagged_cases,
        sum(distinct_patients) as total_distinct_patients
    from {{ ref('report_emr_syndrome_weekly_report') }}
    where facility_key is not null
    group by year, month, facility_key

)

select
    r.year,
    r.month,

    coalesce(r.county, e.county) as county,
    coalesce(r.sub_county, e.sub_county) as sub_county,
    e.facility_key,
    coalesce(r.facility_name, e.facility_name) as facility_name,

    e.expected_flag,

    case
        when r.facility_key is not null then 1
        else 0
    end as reported_flag,

    coalesce(r.reporting_days, 0) as reporting_days,
    coalesce(r.total_flagged_cases, 0) as total_flagged_cases,
    coalesce(r.total_distinct_patients, 0) as total_distinct_patients,

    case
        when coalesce(r.reporting_days, 0) >= 7 then 1
        else 0
    end as consistent_7day_flag,

    case
        when r.facility_key is null then 1
        else 0
    end as silent_flag

from expected e
left join reported r
    on e.facility_key = r.facility_key