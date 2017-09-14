
CREATE OR REPLACE FUNCTION trg_prest_create_clients()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $BODY$
begin

  -- Vérification d'usage
  IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'prestations'
  THEN
    -- le client existe ?
    perform 1 from clients where cl_nom = new.cl_nom;
    if not found then -- non, alors on le crée
      INSERT INTO clients ( cl_nom ) VALUES ( new.cl_nom );
    end if ;
  END IF ;

RETURN new ;
end;
$BODY$
;

CREATE TRIGGER prestations_create_clients
BEFORE INSERT on prestations
FOR EACH ROW
EXECUTE PROCEDURE trg_prest_create_clients();
