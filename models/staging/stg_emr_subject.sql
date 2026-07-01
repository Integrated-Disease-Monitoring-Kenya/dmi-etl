
select
    id::uuid as subject_id,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(patient_unique_id), '') as patient_unique_id,
    md5(coalesce(nullif(trim(patient_unique_id), ''), id::text)) as patient_hash,
    md5(coalesce(nullif(trim(nupi), ''), 'missing')) as nupi_hash,
    case
        when lower(trim(sex)) in ('m', 'male') then 'Male'
        when lower(trim(sex)) in ('f', 'female') then 'Female'
        else 'Unknown'
    end as sex,
     nullif(trim(address), '') as address,
    nullif(initcap(trim(county)), '') as county,
    nullif(initcap(trim(sub_county)), '') as subcounty,
   
 case
    when nullif(trim(date_of_birth), '') is not null
    then split_part(trim(date_of_birth), 'T', 1)::date
    else null
end as dob
from {{ source('central_raw_palladium', 'subject') }}
