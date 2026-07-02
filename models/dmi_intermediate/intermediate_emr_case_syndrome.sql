
select
    c.illness_case_id,
    c.case_unique_id,

    c.date_key,
    c.epi_week_key,
    c.week_number,
    c.epi_year,

    c.mfl_code,
    c.facility_key,
    c.facility_name,
    c.county,
    c.subcounty,

    c.subject_id,
    c.patient_hash,
    c.sex,
    c.dob,
    c.age,
    c.age_group_key,
    c.age_group,

    c.emr_id,
    c.emr_key,
    c.emr_name,

    fc.flagged_condition_id,
    fc.condition_id,
    fc.syndrome_name

from {{ ref('intermediate_emr_case_enriched') }} c

inner join {{ ref('stg_emr_flagged_condition') }} fc
    on fc.case_id = c.case_unique_id

where coalesce(fc.voided, false) = false
  and fc.syndrome_name is not null