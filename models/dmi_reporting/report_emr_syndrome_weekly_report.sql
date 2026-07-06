with weekly as (

    select
        fs.epi_week_key,
        fs.epi_year,
        fs.week_number,
        fs.year,
        fs.month,
        fs.date,

        fs.facility_key,
        fs.facility_name,
        fs.county,
        fs.subcounty,

        fs.condition_id,
        fs.syndrome_name,

        count(distinct fs.case_unique_id) as flagged_cases,
        count(distinct fs.patient_hash) as distinct_patients

    from {{ ref('fct_emr_flagged_syndrome') }} fs

    where fs.epi_week_key is not null
      and fs.facility_key is not null
      and fs.syndrome_name is not null
      and fs.case_unique_id is not null

    group by
        fs.year,
        fs.month,
        fs.date,
        fs.epi_week_key,
        fs.epi_year,
        fs.week_number,
        fs.facility_key,
        fs.facility_name,
        fs.county,
        fs.subcounty,
        fs.condition_id,
        fs.syndrome_name

),

final as (

    select
        *,

        avg(flagged_cases) over (
            partition by facility_key, syndrome_name
            order by epi_year, week_number
            rows between 3 preceding and 1 preceding
        ) as moving_avg_3wk

    from weekly

)

select
    *,

    case
        when moving_avg_3wk is not null
         and flagged_cases > moving_avg_3wk * 2
        then 1
        else 0
    end as threshold_flag

from final