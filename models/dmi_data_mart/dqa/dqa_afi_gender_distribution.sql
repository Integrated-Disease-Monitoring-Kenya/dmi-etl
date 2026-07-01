{% set start_date = var('start_date', '2017-05-29') %}
{% set end_date = var('end_date', '2026-05-07') %}

with raw_counts as (

    select
        case
            when gender in ('1') then 'Male'
            when gender in ('2') then 'Female'
            else 'Unknown'
        end as gender,
   

        count(distinct case
            when consent = '1'
            then "Unique_ID"
        end) as raw_value

    from {{ source('central_raw_afi', 'afi_surveillance_table') }}

    where screening_interviewdate between '{{ start_date }}' and '{{ end_date }}'

    group by 1

),

staging_counts as (

    select
        case
            when gender in ('1') then 'Male'
            when gender in ('2') then 'Female'
            else 'Unknown'
        end as gender,


          count(distinct case
            when consent = '1'
            then "Unique_ID"
        end) as staging_value

    from {{ ref('stg_afi_surveillance') }}

    where screening_date between '{{ start_date }}' and '{{ end_date }}'

    group by 1

),

reporting_counts as (

    select
        gender,
        sum(enrolled) as reporting_value
    from {{ ref('aggregate_afi_surveillance_cascade_report') }}
    where date between '{{ start_date }}' and '{{ end_date }}'
    group by gender

),

powerbi_counts as (

    select *
    from (
        values
            ('Male'::text, 11267::bigint),
            ('Female'::text, 8785::bigint)
    ) as p(gender, powerbi_value)

),

comparison as (

    select
        p.gender,
        coalesce(r.raw_value, 0) as raw_value,
        coalesce(s.staging_value, 0) as staging_value,
        coalesce(rep.reporting_value, 0) as reporting_value,
        p.powerbi_value

    from powerbi_counts p

    left join raw_counts r
        on r.gender = p.gender

    left join staging_counts s
        on s.gender = p.gender

    left join reporting_counts rep
        on rep.gender = p.gender

)

select
    gender,

    raw_value,
    staging_value,
    reporting_value,
    powerbi_value,

    raw_value - staging_value as raw_vs_staging_variance,

    staging_value - reporting_value
        as staging_vs_reporting_variance,

    reporting_value - powerbi_value
        as reporting_vs_powerbi_variance,

    case
        when raw_value = staging_value
         and staging_value = reporting_value
         and reporting_value = powerbi_value
        then 'PASS'
        else 'FAIL'
    end as dqa_status

from comparison