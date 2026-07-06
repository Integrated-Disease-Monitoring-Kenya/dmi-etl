select
    id::uuid as flagged_condition_id,
    nullif(trim(case_id), '') as case_id,
    nullif(trim(condition_id), '') as condition_id,
    case
        when lower(trim(condition_name)) in ('ili', 'influenza like illness', 'influenza-like illness') then 'ILI'
        when lower(trim(condition_name)) in ('sari', 'severe acute respiratory infection') then 'SARI'
        when lower(trim(condition_name)) in ('afi', 'acute febrile illness') then 'AFI'
        when lower(trim(condition_name)) in ('awd', 'acute watery diarrhoea', 'acute watery diarrhea') then 'AWD'
        when lower(trim(condition_name)) in ('ahf', 'acute haemorrhagic fever', 'acute hemorrhagic fever') then 'AHF'
        when lower(trim(condition_name)) like '%jaundice%' then 'Jaundice'
        when lower(trim(condition_name)) = 'afp' or lower(trim(condition_name)) like '%acute flaccid%' then 'AFP'
        when lower(trim(condition_name)) like '%rash%' then 'Rash'
        when lower(trim(condition_name)) like '%neuro%' then 'Neurological'
        else coalesce(nullif(initcap(trim(condition_name)), ''), 'Unknown')
    end as syndrome_name,
    coalesce(voided, false) as voided
from {{ source('central_raw_palladium', 'flagged_condition') }}
