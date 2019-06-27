DROP TABLE Dodatki_extra;
CREATE TABLE Dodatki_extra (
 id_dodatku NUMBER(2) GENERATED BY DEFAULT ON NULL AS IDENTITY
  CONSTRAINT dodatki_id PRIMARY KEY,
 pseudo VARCHAR2(15) CONSTRAINT dx_fk_k REFERENCES Kocury(pseudo),
 dod_extra NUMBER(3) NOT NULL
);

--SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER poAktualizacji
AFTER UPDATE ON KOCURY
FOR EACH ROW
DECLARE 
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF :new.przydzial_myszy > :old.przydzial_myszy
    AND :new.funkcja = 'MILUSIA'
    AND LOGIN_USER != 'TYGRYS' THEN
        EXECUTE IMMEDIATE '
        DECLARE
        CURSOR kursorMilusie IS
          SELECT pseudo FROM Kocury WHERE funkcja = ''MILUSIA'';
        BEGIN
        FOR milusia in kursorMilusie
        LOOP
        INSERT INTO Dodatki_extra(pseudo, dod_extra)
        values (milusia.pseudo, -10);
        END LOOP;
        END;';
        COMMIT;
    END IF;
END;

UPDATE KOCURY SET przydzial_myszy = 30  WHERE pseudo='PUSZYSTA';

ROLLBACK;

SELECT * FROM DODATKI_EXTRA;

