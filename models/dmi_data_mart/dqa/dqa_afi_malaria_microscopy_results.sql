{% set start_date = var('start_date', '2017-05-29') %}
{% set end_date = var('end_date', '2026-05-07') %}

with raw_counts as (

    select
        case
            when "Final_Result" = '1' then 'Positive'
            when "Final_Result" = '2' then 'Negative'
        end as final_result,

        count(*) as raw_value

    from {{ source('central_raw_afi', 'afi_surveillance_table') }}

    where enr_interviewdate between '{{ start_date }}' and '{{ end_date }}'
      and consent = '1'
      and read1_result is not null
      and read2_result is not null
      and "Final_Result" in ('1', '2')

    group by 1

),

staging_counts as (

    select
        case
            when "Final_Result" = '1' then 'Positive'
            when "Final_Result" = '2' then 'Negative'
        end as final_result,

        count(*) as staging_value

    from {{ ref('stg_afi_surveillance') }}

    where enr_interviewdate between '{{ start_date }}' and '{{ end_date }}'
      and consent = 1
      and read1_result is not null
      and read2_result is not null
      and "Final_Result" in ('1', '2')

    group by 1

),

reporting_counts as (

    select
        final_resultresult as final_result,
        count(*) as reporting_value

    from {{ ref('aggregate_afi_surveillance_malaria_microscopy_report') }}

    where screening_date between '{{ start_date }}' and '{{ end_date }}'
      and final_resultresult in ('Positive', 'Negative')

    group by 1

),

powerbi_counts as (

    select *
    from (
        values
            ('Positive'::text, 842::bigint),
            ('Negative'::text, 7091::bigint)

    ) as p(final_result, powerbi_value)

),

comparison as (

    select
        p.final_result,

        coalesce(r.raw_value, 0) as raw_value,
        coalesce(s.staging_value, 0) as staging_value,
        coalesce(rep.reporting_value, 0) as reporting_value,
        p.powerbi_value

    from powerbi_counts p

    left join raw_counts r
        on r.final_result = p.final_result

    left join staging_counts s
        on s.final_result = p.final_result

    left join reporting_counts rep
        on rep.final_result = p.final_result

)

select
    final_result,

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