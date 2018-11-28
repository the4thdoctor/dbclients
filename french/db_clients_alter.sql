
-- Exemples de modifications possibles des tables

-- Ajouter un booléen de confirmation de clients
ALTER TABLE clients ADD COLUMN actif BOOL DEFAULT true ;


-- Modifier les colonnes date de prestation pour un daterange

-- Créer une règle interdisant la suppression d'un client
CREATE RULE suppr_clients AS
   ON DELETE TO clients
   DO INSTEAD UPDATE clients SET actif = false WHERE cl_nom = OLD.cl_nom ;
