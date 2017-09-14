--- chart step x=2
explain select
  sum(montant_ht),
  extract(year from fact_date )
from facturation 
group by  extract(year from fact_date )
order by 2
;
