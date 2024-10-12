select per.name from 
(SELECT DISTINCT ps.period_name name ,ps.start_date fecha
from gl_period_statuses ps 
where 1=1
and ps.application_id = 101
and ps.ledger_id = :p_ledger
and ps.closing_status in ('O','C')
--and ps.ADJUSTMENT_PERIOD_FLAG = 'N'
order by ps.start_date desc) per