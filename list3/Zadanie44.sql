SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE pakiet44 AS
PROCEDURE nowaBanda
    (numerBandy bandy.nr_bandy%TYPE,
    nazwaBandy bandy.nazwa%TYPE,
    terenBandy bandy.teren%TYPE);
 FUNCTION obliczPodatek(pseudonimKotka KOCURY.PSEUDO%TYPE) return NUMBER;
END pakiet44;
/
CREATE OR REPLACE PACKAGE BODY pakiet44
AS
    PROCEDURE nowaBanda--the beginning of the procedure from task 40
        (numerBandy bandy.nr_bandy%TYPE,
        nazwaBandy bandy.nazwa%TYPE,
        terenBandy bandy.teren%TYPE)
    IS
        blad STRING(1000):='';
        blednyNumerBandy EXCEPTION;
        wartoscIstnieje EXCEPTION;
        counter NUMBER:=0;
    BEGIN
        IF numerBandy <= 0 THEN
            RAISE blednyNumerBandy;
        END IF;
        blad := '';
        SELECT COUNT(NR_BANDY) into counter FROM BANDY WHERE nr_bandy = numerBandy;
        IF counter > 0 THEN
            blad:=TO_CHAR(numerBandy);
        END IF;
    
        SELECT COUNT(NR_BANDY) into counter FROM BANDY WHERE nazwa = nazwaBandy;
        IF counter > 0 THEN
            IF LENGTH(blad) > 0 THEN
                blad:= blad ||', '|| nazwaBandy;
            ELSE
                blad:= nazwaBandy;
            END IF;
        END IF;
    
        SELECT COUNT(NR_BANDY) into counter FROM BANDY WHERE teren = terenBandy;
        IF counter > 0 THEN
            IF LENGTH(blad) > 0 THEN
                blad:= blad ||', '|| terenBandy;
            ELSE
                blad:= terenBandy;
            END IF;
        END IF;
    
        IF LENGTH(blad) > 0 THEN
            RAISE wartoscIstnieje;
        END IF;
     
        INSERT INTO BANDY VALUES (numerBandy, nazwaBandy, terenBandy, null);
    
        EXCEPTION
            WHEN wartoscIstnieje THEN DBMS_OUTPUT.PUT_LINE(blad||': juz istnieje');
            WHEN blednyNumerBandy THEN DBMS_OUTPUT.PUT_LINE('Numer Bandy musi być wiekszy od 0');
            WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
        END;--the ending of the procedure from task 40
        
    FUNCTION obliczPodatek(pseudonimKotka KOCURY.PSEUDO%TYPE) RETURN NUMBER
    IS
        podatek NUMBER:=0;
        counter NUMBER:=0;
    BEGIN
        
        SELECT CEIL(0.05*(NVL(PRZYDZIAL_MYSZY,0)+ NVL(MYSZY_EXTRA,0))) into podatek--zwykly podatek 5%
        FROM KOCURY 
        WHERE pseudo = pseudonimKotka;
        
        SELECT COUNT(*) into counter--czy ma podwadnych
        FROM KOCURY WHERE szef = pseudonimKotka;
        
        IF counter <= 0 THEN 
        podatek := podatek +2;--dodanie 2 myszy do podatku
        END IF;
        
        SELECT COUNT(*) into counter--zliczenie wrogow
        FROM WROGOWIE_KOCUROW 
        WHERE pseudo = pseudonimKotka;
        
        IF counter <= 0 THEN
            podatek := podatek + 1;--jesli nie ma podatek+1
        END IF;
        
        SELECT COUNT(*) into counter--podatek okreslany przez wykonawce zadania
        FROM KOCURY WHERE pseudo = pseudonimKotka AND plec='M';
        
        IF counter > 0 THEN
        podatek := podatek + 1;
        END IF;
        
        RETURN podatek;
    END obliczPodatek;
END pakiet44;

SELECT pseudo,
pakiet44.obliczPodatek(pseudo) "Podatek"
FROM KOCURY;

ROLLBACK;


