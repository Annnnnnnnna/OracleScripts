SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER zadanie42b
FOR UPDATE ON Kocury
WHEN (OLD.funkcja = 'MILUSIA')
COMPOUND TRIGGER 
    przydzial_tygrysa NUMBER:= 0;
    nagroda_tygrysa NUMBER := 0;
    kara_tygrysa NUMBER :=0;
   
    BEFORE STATEMENT IS 
    BEGIN
        SELECT przydzial_myszy  INTO przydzial_tygrysa FROM KOCURY WHERE pseudo = 'TYGRYS';
        DBMS_OUTPUT.put_line('przydzial tygrysa ' || przydzial_tygrysa);
    END BEFORE STATEMENT;
   
  BEFORE EACH ROW IS
    f_min NUMBER := 0;
    f_max NUMBER := 0;
    roznica NUMBER := 0;
    BEGIN 
        SELECT min_myszy, max_myszy INTO f_min, f_max
    FROM Funkcje WHERE funkcja = :new.funkcja;
    
    roznica  := :new.przydzial_myszy - :old.przydzial_myszy;
    IF roznica <= 0 THEN
       :new.przydzial_myszy := :old.przydzial_myszy;
    END IF;
    
    IF roznica > (0.1 *  przydzial_tygrysa) THEN
        nagroda_tygrysa :=  nagroda_tygrysa + 1;
    END IF;
    
    IF roznica < 0.1 *  przydzial_tygrysa THEN
        kara_tygrysa := kara_tygrysa + 1;
        :new.przydzial_myszy := :old.przydzial_myszy + (0.1 *  przydzial_tygrysa);
        :new.myszy_extra := :old.myszy_extra + 5;
    END IF;
    
     IF :new.przydzial_myszy < f_min THEN
        :new.przydzial_myszy := f_min;
    ELSIF :new.przydzial_myszy > f_max THEN
        :new.przydzial_myszy := f_max;
    END IF;
  END BEFORE EACH ROW;
   
  AFTER STATEMENT IS
    kara NUMBER :=0;
    nagroda NUMBER :=0;  
  BEGIN
     IF kara_tygrysa > 0 THEN
    kara := kara_tygrysa;
    kara_tygrysa := 0; 
    UPDATE Kocury SET
      przydzial_myszy = przydzial_tygrysa  * ( 1 - (0.1 * kara))
    WHERE pseudo = 'TYGRYS';
  END IF;
   
 IF nagroda_tygrysa > 0 THEN
    nagroda := nagroda_tygrysa;
    nagroda_tygrysa := 0; 
    UPDATE Kocury SET
      myszy_extra = myszy_extra + nagroda*5
    WHERE pseudo = 'TYGRYS';
  END IF;
  END AFTER STATEMENT;
END zadanie42b;



SET AUTOCOMMIT OFF;--by moc cofnac zmiany

BEGIN
UPDATE KOCURY SET przydzial_myszy = 30 WHERE imie = 'SONIA' OR imie = 'BELA';
END;

SELECT * FROM KOCURY  WHERE imie = 'SONIA' OR imie = 'BELA' OR pseudo='TYGRYS';
ROLLBACK;