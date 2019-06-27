SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE zadanie42 
AS
przydzialTygrysa NUMBER:=0;
nagrodaTygrysa NUMBER:=0;
karaTygrysa NUMBER:=0;
END zadanie42;
/
CREATE OR REPLACE TRIGGER przedAktualizacja
BEFORE UPDATE ON KOCURY
BEGIN
  SELECT przydzial_myszy INTO zadanie42.przydzialTygrysa FROM Kocury WHERE pseudo = 'TYGRYS';
END;
/
CREATE OR REPLACE TRIGGER przedAktualizacjaDlaKazdego
BEFORE UPDATE OF przydzial_myszy ON KOCURY
FOR EACH ROW WHEN (OLD.funkcja = 'MILUSIA')
DECLARE
minimalny NUMBER;
maksymalny NUMBER;
podwyzka NUMBER:=0;
BEGIN
    SELECT max_myszy, min_myszy into maksymalny, minimalny
    FROM FUNKCJE WHERE funkcja= :new.funkcja;

    podwyzka:= :new.przydzial_myszy - :old.przydzial_myszy;

    IF podwyzka <= 0 THEN
        :new.przydzial_myszy := :old.przydzial_myszy;
        DBMS_OUTPUT.PUT_LINE('Proba zmniejszenia przydzialu myszy kota: ' || :new.pseudo);
    END IF;

    IF podwyzka >= 0.1 * zadanie42.przydzialTygrysa THEN
        zadanie42.nagrodaTygrysa := zadanie42.nagrodaTygrysa + 1;
    END IF;
    
    IF podwyzka < 0.1 * zadanie42.przydzialTygrysa THEN
        zadanie42.karaTygrysa := zadanie42.karaTygrysa + 1;
        :new.przydzial_myszy := :old.przydzial_myszy + (0.1 *  zadanie42.przydzialTygrysa);
        :new.myszy_extra := :old.myszy_extra + 5;
    END IF;
    
    IF :new.przydzial_myszy < minimalny THEN
        :new.przydzial_myszy := minimalny;
    ELSIF :new.przydzial_myszy > maksymalny THEN
        :new.przydzial_myszy := maksymalny;
    END IF;
END;
/
CREATE OR REPLACE TRIGGER poAktualizacjiDlaKazdego
AFTER UPDATE OF przydzial_myszy ON KOCURY
DECLARE 
    kara NUMBER :=0;
    nagroda NUMBER :=0;
BEGIN
  IF zadanie42.karaTygrysa > 0 THEN
    kara := zadanie42.karaTygrysa;
    zadanie42.karaTygrysa := 0; 
    DBMS_OUTPUT.put_line('kara');
    UPDATE Kocury SET
    przydzial_myszy = przydzial_myszy  * ( 1 - (0.1 * kara))
    WHERE pseudo = 'TYGRYS';
  END IF;
   
 IF zadanie42.nagrodaTygrysa > 0 THEN
    nagroda := zadanie42.nagrodaTygrysa;
    zadanie42.nagrodaTygrysa := 0; 
    DBMS_OUTPUT.put_line('nagroda');
    UPDATE Kocury SET
      myszy_extra = myszy_extra + nagroda*5
    WHERE pseudo = 'TYGRYS';
  END IF;
END;

ALTER TABLE KOCURY DISABLE ALL TRIGGERS;
--ALTER TRIGGER poAktualizacji ENABLE;
BEGIN
UPDATE KOCURY SET przydzial_myszy = 30 WHERE imie = 'SONIA' OR imie = 'BELA';
END;

ROLLBACK;

SELECT * FROM KOCURY  WHERE imie = 'SONIA' OR imie = 'BELA' OR pseudo='TYGRYS';
