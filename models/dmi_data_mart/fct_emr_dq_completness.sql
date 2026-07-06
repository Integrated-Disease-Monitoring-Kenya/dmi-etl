

with case_vars as (

    select
        facility_key,
        date_key,
        'diagnosis' as dq_variable,
        sum(
            case
                when diagnosis_text is not null
                 and diagnosis_text <> 'Missing/Unknown'
                then 1 else 0
            end
        ) as complete_count,
        count(*) as expected_count
    from {{ ref('fct_emr_case_diagnosis') }}
    group by 1, 2, 3

    union all

    select
        facility_key,
        date_key,
        'outcome' as dq_variable,
        sum(case when final_outcome is not null then 1 else 0 end) as complete_count,
        count(*) as expected_count
    from {{ ref('fct_emr_case_case') }}
    group by 1, 2, 3

    union all

    select
        facility_key,
        date_key,
        'outcome_date' as dq_variable,
        sum(case when final_outcome_date is not null then 1 else 0 end) as complete_count,
        count(*) as expected_count
    from {{ ref('fct_emr_case_case') }}
    group by 1, 2, 3

    union all

    select
        facility_key,
        date_key,
        'admission_date' as dq_variable,
        sum(case when admission_date is not null then 1 else 0 end) as complete_count,
        count(*) as expected_count
    from {{ ref('fct_emr_case_case') }}
    group by 1, 2, 3

)

select
    {{ dbt_utils.surrogate_key([
        'facility_key',
        'date_key',
        'dq_variable'
    ]) }} as dq_completeness_key,

    facility_key,
    date_key,
    dq_variable,
    complete_count,
    expected_count,

    case
        when expected_count > 0
        then round(complete_count::numeric / expected_count, 4)
        else null
    end as completeness_pct

from case_vars