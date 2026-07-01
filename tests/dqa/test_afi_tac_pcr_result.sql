select *
from {{ ref('dqa_afi_tac_pcr_result') }}
where coalesce(raw_vs_staging_variance, 0) <> 0
   or coalesce(staging_vs_reporting_variance, 0) <> 0
   or coalesce(reporting_vs_powerbi_variance, 0) <> 0