
-- Exemples de modifications possibles des tables

-- Ajouter un booléen de confirmation de clients
ALTER TABLE clients ADD COLUMN actif BOOL DEFAULT true ;


-- Modifier les colonnes date de prestation pour un daterange
alter table prestations add column prest_dates daterange ;
update prestations set prest_dates = daterange( prest_date_debut::date, prest_date_fin::date) ;
alter table prestations drop column prest_date_debut, drop column prest_date_fin ;
create index on prestations using gist ( prest_dates ) ;

-- DROP INDEX prest_date_idx;
-- DROP INDEX prest_date_deb_idx;

-- Créer une règle interdisant la suppression d'un client
CREATE RULE suppr_clients AS
   ON DELETE TO clients
   DO INSTEAD UPDATE clients SET actif = false WHERE cl_nom = OLD.cl_nom ;
