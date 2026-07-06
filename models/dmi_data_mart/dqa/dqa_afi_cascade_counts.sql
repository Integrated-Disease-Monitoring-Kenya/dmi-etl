{% set start_date = var('start_date', '2017-05-29') %}
{% set end_date = var('end_date', '2026-05-07') %}

with raw_counts as (

    select
        count(distinct "Unique_ID") as screened,
        count(distinct case 
    when eligible = '1' 
     and not (eligible = '1' and consent = '6')
    then "Unique_ID"
end) as eligible,

        count(distinct case
            when consent = '1'
            then "Unique_ID"
        end) as enrolled,

        count(case
            when proposed_combined_case <> 'DNS'
              or sampled = '1'
            then proposed_combined_case
        end) as eligible_sampling,

        count(case
            when sampled = '1'
            then sampled
        end) as sampled

    from {{ source('central_raw_afi', 'afi_surveillance_table') }}

    where screening_interviewdate between '{{ start_date }}' and '{{ end_date }}'

),

staging_counts as (

    select
        count(distinct "Unique_ID") as screened,

        count(distinct case 
    when eligible = '1' 
     and not (eligible = '1' and consent = '6')
    then "Unique_ID"
end) as eligible,

        count(distinct case
            when consent = '1'
            then "Unique_ID"
        end) as enrolled,

        count(case
            when proposed_combined_case <> 'DNS'
              or sampled = '1'
            then proposed_combined_case
        end) as eligible_sampling,

        count(case
            when sampled = '1'
            then sampled
        end) as sampled

    from {{ ref('stg_afi_surveillance') }}

    where screening_date between '{{ start_date }}' and '{{ end_date }}'

),

reporting_counts as (

    select
        sum(screened) as screened,
        sum(eligible) as eligible,
        sum(enrolled) as enrolled,
        sum(eligible_sampling) as eligible_sampling,
        sum(sampled) as sampled

    from {{ ref('aggregate_afi_surveillance_cascade_report') }}

    where date between '{{ start_date }}' and '{{ end_date }}'

),

powerbi_counts as (
    select *
    from (
        values
            ('screened'::text, 186565::bigint),
            ('eligible'::text, 24673::bigint),
            ('enrolled'::text, 19991::bigint),
            ('eligible_sampling'::text, 16770::bigint),
            ('sampled'::text, 11490::bigint)
    ) as p(indicator, powerbi_value)

),

comparison as (

    select
        'screened' as indicator,
        r.screened as raw_value,
        s.screened as staging_value,
        rep.screened as reporting_value
    from raw_counts r
    cross join staging_counts s
    cross join reporting_counts rep

    union all

    select
        'eligible',
        r.eligible,
        s.eligible,
        rep.eligible
    from raw_counts r
    cross join staging_counts s
    cross join reporting_counts rep

    union all

    select
        'enrolled',
        r.enrolled,
        s.enrolled,
        rep.enrolled
    from raw_counts r
    cross join staging_counts s
    cross join reporting_counts rep

    union all

    select
        'eligible_sampling',
        r.eligible_sampling,
        s.eligible_sampling,
        rep.eligible_sampling
    from raw_counts r
    cross join staging_counts s
    cross join reporting_counts rep

    union all

    select
        'sampled',
        r.sampled,
        s.sampled,
        rep.sampled
    from raw_counts r
    cross join staging_counts s
    cross join reporting_counts rep

)

select
    c.indicator,

    c.raw_value,
    c.staging_value,
    c.reporting_value,
    p.powerbi_value,

    c.raw_value - c.staging_value as raw_vs_staging_variance,

    c.staging_value - c.reporting_value
        as staging_vs_reporting_variance,

    c.reporting_value - p.powerbi_value
        as reporting_vs_powerbi_variance,

    case
        when c.raw_value = c.staging_value
         and c.staging_value = c.reporting_value
         and c.reporting_value = p.powerbi_value
        then 'PASS'
        else 'FAIL'
    end as dqa_status

from comparison c

left join powerbi_counts p
    on c.indicator = p.indicator