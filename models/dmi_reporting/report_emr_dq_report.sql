select
    dq.date_key,
    d.date,
    dq.facility_key,
    f.facility_code,
    f.facility_name,
    f.county,
    f.sub_county as subcounty,
    dq.dq_variable,
    dq.complete_count,
    dq.expected_count,
    dq.completeness_pct

from {{ ref('fct_emr_dq_completness') }} dq

left join {{ ref('dim_date') }} d
    on dq.date_key = d.date_key

left join {{ ref('dim_emr_facility') }} f
    on dq.facility_key = f.facility_key