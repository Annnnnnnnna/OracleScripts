SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER numerBandy
BEFORE INSERT ON BANDY
FOR EACH ROW
BEGIN
SELECT 
    MAX(nr_Bandy)+1 into :new.nr_bandy
FROM BANDY;
END;

 
SET AUTOCOMMIT OFF;
 
BEGIN
  nowaBanda(8, 'Jagody', 'polanka');
END;
/
SELECT * FROM Bandy;
ROLLBACK;
SET AUTOCOMMIT ON;