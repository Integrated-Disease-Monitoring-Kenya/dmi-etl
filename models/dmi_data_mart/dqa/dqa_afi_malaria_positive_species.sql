{% set start_date = var('start_date', '2017-05-29') %}
{% set end_date = var('end_date', '2026-05-07') %}

with raw_counts as (

    select
        case
            when malariares = '1' then 'P.falciparum'
            when malariares = '2' then 'Pan malaria'
            when malariares = '3' then 'Mixed species'
        end as malaria_pos_category,

        count(*) as raw_value

    from {{ source('central_raw_afi', 'afi_surveillance_table') }}

    where screening_interviewdate between '{{ start_date }}' and '{{ end_date }}'
      and malariardtres = '1'
      and malariares in ('1', '2', '3')

    group by 1

),

staging_counts as (

    select
        case
            when malariares = '1' then 'P.falciparum'
            when malariares = '2' then 'Pan malaria'
            when malariares = '3' then 'Mixed species'
        end as malaria_pos_category,

        count(*) as staging_value

    from {{ ref('stg_afi_surveillance') }}

    where screening_date between '{{ start_date }}' and '{{ end_date }}'
      and malariardtres = '1'
      and malariares in ('1', '2', '3')

    group by 1

),

reporting_counts as (

    select
        malaria_pos_category,
        count(*) as reporting_value

    from {{ ref('aggregate_afi_surveillance_malaria_rdt_report') }}

    where screening_date between '{{ start_date }}' and '{{ end_date }}'
      and result = 'Positive'
      and malaria_pos_category in (
            'P.falciparum',
            'Pan malaria',
            'Mixed species'
      )

    group by 1

),

powerbi_counts as (

    select *
    from (
        values
            ('P.falciparum'::text, 1338::bigint),
            ('Pan malaria'::text, 101::bigint),
            ('Mixed species'::text, 859::bigint)

    ) as p(malaria_pos_category, powerbi_value)

),

comparison as (

    select
        p.malaria_pos_category,

        coalesce(r.raw_value, 0) as raw_value,
        coalesce(s.staging_value, 0) as staging_value,
        coalesce(rep.reporting_value, 0) as reporting_value,
        p.powerbi_value

    from powerbi_counts p

    left join raw_counts r
        on r.malaria_pos_category = p.malaria_pos_category

    left join staging_counts s
        on s.malaria_pos_category = p.malaria_pos_category

    left join reporting_counts rep
        on rep.malaria_pos_category = p.malaria_pos_category

)

select
    malaria_pos_category,

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