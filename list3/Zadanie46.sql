
DROP TABLE WYKROCZENIA_PRZEDZIALOW;
CREATE TABLE WYKROCZENIA_PRZEDZIALOW (--tablica moniturajaca niestandardowe przydzialy myszy
  kto VARCHAR2(20),
  kiedy DATE DEFAULT SYSDATE,
  komu VARCHAR2(15),
  operacja VARCHAR2(15)
);

SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER blokadaFunkcji
FOR INSERT OR UPDATE ON KOCURY
COMPOUND TRIGGER 
    f_min NUMBER := 0;
    f_max NUMBER := 0;
    a_operacja STRING(20);
    a_pseudo STRING(20);
    blad NUMBER(1) := 0;
    wstaw VARCHAR2(1000); 
 BEFORE EACH ROW 
 IS 
 BEGIN 
    IF INSERTING THEN
        a_operacja := 'WSTAWIANIE';
    END IF;
    
    IF UPDATING THEN
        a_operacja := 'AKTUALIZACJA';
    END IF;
    
    SELECT min_myszy, max_myszy INTO f_min, f_max FROM FUNKCJE WHERE FUNKCJE.funkcja = :new.funkcja;
    DBMS_OUTPUT.put_line('FUNKCJA' || :new.funkcja);
    IF :new.przydzial_myszy < f_min THEN
        a_pseudo := :new.pseudo;
        blad := 1;
        IF UPDATING THEN
            wstaw := 'INSERT INTO WYKROCZENIA_PRZEDZIALOW(kto, komu, operacja) VALUES (:login_user, :a_pseudo, :a_operacja)';
            EXECUTE IMMEDIATE wstaw USING LOGIN_USER, a_pseudo, a_operacja;
        END IF;
        DBMS_OUTPUT.put_line('Przydzial myszy za maly');
        :new.przydzial_myszy := f_min;
    END IF;
    IF :new.przydzial_myszy > f_max THEN
        a_pseudo := :new.pseudo;
        blad := 1;
        IF UPDATING THEN
            wstaw := 'INSERT INTO WYKROCZENIA_PRZEDZIALOW(kto, komu, operacja) VALUES (:login_user, :a_pseudo, :a_operacja)';
            EXECUTE IMMEDIATE wstaw USING LOGIN_USER, a_pseudo, a_operacja;
        END IF;
        :new.przydzial_myszy := f_max;
        DBMS_OUTPUT.put_line('Przydzial myszy za duzy');
    END IF;
END BEFORE EACH ROW;
    
    AFTER STATEMENT 
    IS 
    BEGIN
        IF INSERTING AND blad = 1 THEN
           wstaw := 'INSERT INTO WYKROCZENIA_PRZEDZIALOW(kto, komu, operacja) VALUES (:login_user, :a_pseudo, :a_operacja)';
            EXECUTE IMMEDIATE wstaw USING LOGIN_USER, a_pseudo, a_operacja;
        END IF;            
    END AFTER STATEMENT;

END;

SET AUTOCOMMIT OFF;

SELECT * FROM WYKROCZENIA_PRZEDZIALOW;

SELECT * FROM FUNKCJE;
SELECT * FROM KOCURY;

BEGIN
INSERT INTO Kocury VALUES ('JAGODA','M','MALINAA','DZIELCZY','TYGRYS','2011-11-11',79,NULL,3);
END;

BEGIN 
DELETE FROM KOCURY WHERE pseudo = 'MALINAA';
END;

ROLLBACK;