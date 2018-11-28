
create role slardiere login ;

grant select on table prestations,intervention to slardiere ;

create table intervention
(
  login text,
  prest_id integer references prestations (prest_id),
  primary key ( login, prest_id )
);



insert into intervention select 'slardiere', prest_id from prestations where cl_nom = 'SPLFBC' ;

ALTER TABLE prestations ENABLE ROW LEVEL SECURITY;


CREATE POLICY intervention_p
ON prestations
FOR SELECT
USING ((cl_nom) IN ( SELECT cl_nom FROM intervention i where i.prest_id=prestations.prest_id and i.login = current_user ));
-- drop policy intervention_p ON prestations  ;
