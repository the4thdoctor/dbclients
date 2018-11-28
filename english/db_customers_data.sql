-- Transaction which generates a data set for the database customers

begin ;

INSERT INTO customers
values ('MonPay' ,'8, rue de la soupe, 83120 Douby Sur Var' ) --,'t')
       ,('Société Particulière' ,'93, avenue Alponse Douillard, 95320 La Crue') --,'t')
       ,('SPLFBC' ,'Cité Oudrot, 57110 Loupsse') --,'t')
       ,('ENVREDS' ,'rue des affranchis, 31560 Ruhet') --,'t')
       ,('La Côtée', '7 impasse des Marsouins, 56501 Languidec') --,'t')
       ,('Enrier', 'Zone des Rutauts, 60120 Fyrec') --,'t')
       ,('S.T.E.R.E.G', '2 rue des Incas, 25340 St-Anois') --,'t')
       ,('FREC-TIS', 'Le bourg, 15230 Adurac') --,'t')
;

INSERT INTO contacts
values ('Damien' , 'Testet'  , '0409443135'  , 'dtestet@monpay.biz'  , 'MonPay' )
      ,('Thérèse' , 'Androt'  , '0409443154'  , 'tandrot@monpay.biz'  , 'MonPay' )
      ,('Damien' , 'Lendrot'  , '0109323132'  , 'dlandrot@sp.com.biz'  , 'Société Particulière' )
      ,('Sophie' , 'Estère'  , '0109323138'  , 'sestere@sp.com.biz'  , 'Société Particulière' )
      ,('Vincent' , 'Aspic'  , '0309653176'  , 'vaspic@splfbc.fr'  , 'SPLFBC' )
      ,('Caroline' , 'Lenpuis'  , '0309653143'  , 'clenpuis@splfbc.fr'  , 'SPLFBC' )
      ,('Antoine' , 'Ramier'  , '0509323198'  , 'aramier@envreds.org'  , 'ENVREDS' )
      ,('Astrid' , 'Neliera'  , '0509323943'  , 'aneliera@envreds.org'  , 'ENVREDS' )
      ,('Joachim' , 'Deruche'  , '0243659165'  , 'jderuche@la-cotee.coop'  , 'La Côtée' )
      ,('Anne' , 'Lordet'  , '0243659143'  , 'alordet@la-cotee.coop'  , 'La Côtée' )
      ,('Henry' , 'Passeda'  , '0512658303'  , 'hpasseda@enrier.fr'  , 'Enrier' )
      ,('Véronique' , 'Leto'  , '0512658305'  , 'vleto@enrier.fr'  , 'Enrier' )
      ,('Charles' , 'D''Herrier'  , '0354219420'  , 'cdherrier@stereg.fr'  , 'S.T.E.R.E.G' )
      ,('Madelaine' , 'Hercot'  , '0354219420'  , 'mhercot@stereg.fr'  , 'S.T.E.R.E.G' )
      ,('Piotr' , 'Zurca'  , '0554016279'  , 'pzurca@frec-tis.com'  , 'FREC-TIS' )
      ,('Clémence' , 'Dechanville'  , '0554016279'  , 'cdechanville@frec-tis.com'  , 'FREC-TIS' )
;

INSERT INTO jobs
with dates as (
  select
    cus_name, x + ( (random() * 10)::int * '1d'::interval ) as date_start
  from
    customers,
    generate_series('1970-01-01'::date, current_date, '1w'::interval) x
),
datesf as (
  select
    cus_name,
    date_start,
    date_start + (random() * 5)::int * '1d'::interval as date_end  from dates
),
jobs as (
  select
    *
  from (values ('Maintenance'),('Delivery'),('Removal'),('Other'),('Consultation')) as t -- ,('Formation')
),
datas as (
select row_number() over () as id, column1 as intitule,
    'Insert the job  description' as description,
    upper(substring(column1 from 1 for 1)) as type, date_start, date_end,
    case when random() < 0.1 then 'f'::boolean else 't'::boolean end, cus_name
    from datesf, jobs
    order by random()
)
select * from datas order by id
;

INSERT INTO invoices
with dates as (
select distinct x + ( (random() * 10)::int * '1d'::interval ) as inv_date, cus_name
   from customers, generate_series('1970-01-01'::date, current_date, '1mon'::interval) x
   order by 1, 2
   )
select ltrim(to_char( row_number() over (), '00000') || upper(substring(cus_name from 1 for 1))) as num,
       inv_date, inv_date + '1mon'::interval + (random()*10)*'1d'::interval as date_paid,
       case when random() < 0.5 then 'C' else 'V' end  as average_pay, cus_name
       from dates
;

INSERT INTO invoice_details
with invoices as (
select inv_num, cus_name, inv_date, lag( inv_date ) over (partition by cus_name order by inv_date ) dprev from invoices
)
select inv_num, job_id, job_description,
       (case when job_description = 'Maintenance' then 600
             when job_description = 'Consultation' then 700 else 400 end) - ( (current_date - job_date_end::date) / 250) as amount, 1
    from jobs join invoices on job_date_end > dprev and job_date_end < inv_date and invoices.cus_name = jobs.cus_name
;
/*
-- REFRESH MATERIALIZED VIEW facturation ;
*/
commit;
