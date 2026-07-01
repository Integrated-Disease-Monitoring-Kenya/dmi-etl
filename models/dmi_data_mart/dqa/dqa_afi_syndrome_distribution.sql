{% set start_date = var('start_date', '2017-05-29') %}
{% set end_date = var('end_date', '2026-05-07') %}

with raw_counts as (

    select
        proposed_combined_case,
        count(*) as raw_value

    from {{ source('central_raw_afi', 'afi_surveillance_table') }}

    where screening_interviewdate between '{{ start_date }}' and '{{ end_date }}'
      and proposed_combined_case in (
            'ILI',
            'SARI',
            'IUF/ILI',
            'IUF/SARI',
            'IUF'
      )

    group by 1

),

staging_counts as (

    select
        proposed_combined_case,
        count(*) as staging_value

    from {{ ref('stg_afi_surveillance') }}

    where screening_date between '{{ start_date }}' and '{{ end_date }}'
      and proposed_combined_case in (
            'ILI',
            'SARI',
            'IUF/ILI',
            'IUF/SARI',
            'IUF'
      )

    group by 1

),

reporting_counts as (

    select
        case_classification as proposed_combined_case,
        count(*) as reporting_value

    from {{ ref('aggregate_afi_surveillance_syndromes_report') }}

    where date between '{{ start_date }}' and '{{ end_date }}'
      and case_classification in (
            'ILI',
            'SARI',
            'IUF/ILI',
            'IUF/SARI',
            'IUF'
      )

    group by 1

),

powerbi_counts as (

    select *
    from (
        values
            ('ILI'::text, 0::bigint),
            ('SARI'::text, 0::bigint),
            ('IUF/ILI'::text, 0::bigint),
            ('IUF/SARI'::text, 0::bigint),
            ('IUF'::text, 0::bigint)

    ) as p(proposed_combined_case, powerbi_value)

),

comparison as (

    select
        p.proposed_combined_case,

        coalesce(r.raw_value, 0) as raw_value,
        coalesce(s.staging_value, 0) as staging_value,
        coalesce(rep.reporting_value, 0) as reporting_value,
        p.powerbi_value

    from powerbi_counts p

    left join raw_counts r
        on r.proposed_combined_case = p.proposed_combined_case

    left join staging_counts s
        on s.proposed_combined_case = p.proposed_combined_case

    left join reporting_counts rep
        on rep.proposed_combined_case = p.proposed_combined_case

)

select
    proposed_combined_case,

    raw_value,
    staging_value,
    reporting_value,
    powerbi_value,

    raw_value - staging_value
        as raw_vs_staging_variance,

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