
\c postgres
drop database customers ;
create database customers ;
\c customers



CREATE TABLE customers (
	cus_name varchar(20) PRIMARY KEY ,
	cus_adress text
) ;

CREATE TABLE contacts (
	con_name text,
	con_surname text,
	con_telephone text,
	con_email text,
	ct_position text,
	cus_name text REFERENCES customers ( cus_name )
) ;

CREATE TABLE jobs (
	job_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--	prest_id serial PRIMARY KEY,
        job_name text,
	job_description text ,
	job_type text,
	job_date_start timestamptz,
	job_date_end timestamptz,
	job_confirm boolean,
	cus_name text REFERENCES customers ( cus_name )
) ;

CREATE TABLE invoices (
	inv_num text primary key ,
	inv_date timestamptz,
	inv_date_paid timestamptz,
	fact_average_pay text,
	cus_name text references customers ( cus_name )
) ;

CREATE TABLE invoice_details (
	inv_num text REFERENCES invoices ( inv_num ) ,
	job_id integer UNIQUE REFERENCES jobs ( job_id ),
	invdet_name text,
	invdet_amount numeric(10,3),
	invdet_quantity numeric ,
        PRIMARY KEY ( inv_num, job_id )
) ;


-- Populate the database
\i db_customers_data.sql


CREATE OR REPLACE VIEW invoiceview AS
	SELECT
		i.inv_num,
		i.inv_date,
		i.inv_date_paid,
		i.cus_name,
		sum(d.invdet_amount * d.invdet_quantity) as amount_bt -- ,
		FROM
			invoices i
			JOIN invoice_details d USING ( inv_num )
			LEFT JOIN jobs j USING (job_id)
    GROUP BY
			i.inv_num,
			i.inv_date,
			i.inv_date_paid,
			i.cus_name
		ORDER BY
			substring(inv_num from '..$') ASC
		;

/*
CREATE INDEX prest_date_idx ON prestations ( prest_date_debut , prest_date_fin  )  ;

CREATE INDEX prest_date_deb_idx ON prestations ( prest_date_debut ) WHERE prest_confirm ;

CREATE MATERIALIZED VIEW facturation AS
	SELECT f.fact_num, f.fact_date, f.fact_date_paiement, f.cl_nom,
		sum(l.lf_montant * l.lf_qte) as montant_HT -- ,
		FROM factures f JOIN lignes_factures l USING ( fact_num )
                LEFT JOIN prestations p ON l.prest_id=p.prest_id
                GROUP BY f.fact_num, f.fact_date, f.fact_date_paiement, f.cl_nom
		ORDER BY substring(fact_num from '..$') ASC ;


-- \i db_customers_table_formations.sql

-- \i db_customers_alter.sql

-- VACUUM ANALYSE;
*/
