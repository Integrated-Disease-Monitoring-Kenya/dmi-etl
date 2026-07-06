

with base as (

    select
        c.*,

        -- Subject
     
        s.patient_hash,
        s.nupi_hash,
        s.patient_unique_id,
        s.sex,
        s.dob,
        s.address,
        s.county as subject_county,
        s.subcounty as subject_subcounty,

        -- EMR
        e.emr_key,
        e.emr_name,

        -- Facility
        f.facility_key,
        f.facility_name,
        f.county as facility_county,
        f.sub_county as facility_subcounty,
        f.ward,

        -- Reporting geography
        coalesce(f.county, s.county, 'Unknown') as county,
        coalesce(f.sub_county, s.subcounty, 'Unknown') as subcounty,

        -- Age
        case
            when s.dob is not null
             and c.interview_date is not null
            then date_part('year', age(c.interview_date, s.dob))::int
        end as age,

        -- Date Dimension
        d.date_key,
        d.date,
        d.year,
        d.month

    from {{ ref('stg_emr_illnes_case') }} c

    left join {{ ref('stg_emr_subject') }} s
        on c.case_unique_id = s.case_id

    left join {{ ref('dim_emr') }} e
        on c.emr_id = e.emr_id

    left join {{ ref('dim_emr_facility') }} f
        on c.mfl_code = f.facility_code::text

    left join {{ ref('dim_date') }} d
        on d.date = c.interview_date

)

select
    b.*,

    -- Age Group Dimension
    ag.age_group_key,
    ag.age_group,

    -- Epidemiological Week Dimension
    ew.epi_week_key,
    ew.week_number,
    ew.year as epi_year,
    ew.start_of_week,
    ew.end_of_week,

    current_date as load_date_new

from base b

left join {{ ref('dim_age_group_emr') }} ag
    on b.age between ag.min_age and ag.max_age

left join {{ ref('dim_epi_week') }} ew
    on b.interview_date between ew.start_of_week and ew.end_of_week