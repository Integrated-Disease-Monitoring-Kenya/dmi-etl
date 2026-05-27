select *
from {{ ref('dqa_afi_cascade_counts') }}
where coalesce(raw_vs_staging_variance, 0) <> 0
   or coalesce(reporting_vs_powerbi_variance, 0) <> 0