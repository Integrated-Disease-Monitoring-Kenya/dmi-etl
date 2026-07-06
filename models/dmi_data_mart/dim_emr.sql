
select
    {{ dbt_utils.surrogate_key(['"ID"']) }} as emr_key,
    "ID"::uuid as emr_id,
    nullif(trim("Emr Name"), '') as emr_name,
    coalesce("Voided", false) as voided,
    "Created At"::timestamp as created_at,
    "Updated At"::timestamp as updated_at
from {{ ref('emr_list') }}