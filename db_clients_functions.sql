CREATE OR REPLACE FUNCTION montant_ttc ( montant_ht numeric, tva numeric default 20.6 )
RETURNS numeric
LANGUAGE 'plpgsql'
STABLE
AS $$
BEGIN
    RETURN montant_ht * (1 + (tva / 100  )) ;
END ;
$$ ;

CREATE OR REPLACE FUNCTION montant_facture (id_facture text)
RETURNS numeric
LANGUAGE 'plpgsql'
AS $$
DECLARE
  somme_ttc numeric ;
BEGIN
  RAISE NOTICE 'ID Facture : % ' , id_facture ;
  SELECT montant_ttc(sum (lf_montant)) into somme_ttc
    FROM lignes_factures
    WHERE fact_nu = id_facture ;
 RAISE NOTICE 'Somme : % ' , somme_ttc ;
RETURN somme_ttc ;
END ;
$$ ;
