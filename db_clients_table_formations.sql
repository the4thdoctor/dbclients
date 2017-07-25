begin;
create table formations  (
	f_nb_stagiaires int,
	f_id_plandecours text,
	f_type_formation varchar(5) check ( f_type_formation in ('intra','inter') )
) inherits ( prestations ) ;

-- DROP FK lignes_factures_prestations

ALTER TABLE lignes_factures DROP CONSTRAINT lignes_factures_prest_id_fkey ;

INSERT INTO formations
with dates as (
select cl_nom, x + ( (random() * 10)::int * '1d'::interval ) as date_debut
     from clients, generate_series('1970-01-01'::date, current_date, '2mon'::interval) x
),
datesf as (
select cl_nom, date_debut, date_debut + (random() * 5)::int * '1d'::interval as date_fin  from dates
),
prest as (
select * from (values ('Formation')) as t
),
datas as (
select (select max(prest_id) id from prestations) +  row_number() over () as id, column1 as intitule,
    'Entrer ici la description de la formation' as description,
    upper(substring(column1 from 1 for 1)) as type, date_debut, date_fin,
    case when random() < 0.1 then 'f'::boolean else 't'::boolean end, cl_nom,
    (random() + 80 )::int as nb_stagiaires,
    case when random() < 0.5 then 1 else 2 end,
    case when random() < 0.9 then 'intra'::text else 'inter'::text end
    from datesf, prest
    order by random()
)
select * from datas order by id
;

INSERT INTO factures
select ltrim(to_char( row_number() over (), '00000') ||'_F_'|| upper(substring(cl_nom from 1 for 1))) as num,
       fact_date, fact_date + '1mon'::interval + (random()*10)*'1d'::interval as date_paiement,
       case when random() < 0.5 then 'C' else 'V' end  as moyen_paiement, cl_nom
       from (
           select distinct x + ( (random() * 10)::int * '1d'::interval ) as fact_date, cl_nom
              from clients, generate_series('1970-01-01'::date, current_date, '6mon'::interval) x
           ) as y
;

INSERT INTO lignes_factures
select fact_num, prest_id, prest_intitule, 500 as montant, 1
    from formations join
    (select fact_num, cl_nom,
      fact_date, lag( fact_date ) over (partition by cl_nom order by fact_date ) dprev
      from factures where fact_num ~ '_F_') as facts
    on prest_date_fin > dprev and prest_date_fin < fact_date
    and facts.cl_nom = formations.cl_nom
    where prest_intitule = 'Formation'
;


REFRESH MATERIALIZED VIEW facturation ;

--rollback;
commit;
