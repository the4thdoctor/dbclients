SET plprofiler.enabled TO true;
SET plprofiler.collect_interval TO 10;
select fact_num, cl_nom, montant_facture( fact_num )  from factures order by random() limit 1;
