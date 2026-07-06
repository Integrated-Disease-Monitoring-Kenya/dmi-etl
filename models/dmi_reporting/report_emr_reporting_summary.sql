{{ config(materialized='table') }}

with reported as (

    select
        year,
        month,

        county,
        subcounty,

        facility_key,
        facility_name,

        count(distinct date) as reporting_days,
        sum(flagged_cases) as total_flagged_cases,
        sum(distinct_patients) as total_distinct_patients

    from {{ ref('report_emr_syndrome_weekly_report') }}

    group by
        year,
        month,
        county,
        subcounty,
        facility_key,
        facility_name

)

select

    year,
    month,

    county,
    subcounty,

    facility_key,
    facility_name,

    1 as reported_flag,

    reporting_days,

    total_flagged_cases,

    total_distinct_patients,

    case
        when reporting_days >= 7 then 1
        else 0
    end as consistent_7day_flag

from reported