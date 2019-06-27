
SET SERVEROUTPUT ON;

DECLARE
    pseudonim KOCURY.PSEUDO%TYPE;
    przydzial KOCURY.PRZYDZIAL_MYSZY%TYPE;
    imie KOCURY.IMIE%TYPE;
    miesiac NUMBER;
BEGIN
SELECT PSEUDO,PRZYDZIAL_MYSZY, IMIE, TO_CHAR(EXTRACT(month from W_STADKU_OD)) INTO pseudonim, przydzial, imie, miesiac
    FROM KOCURY
    WHERE PSEUDO ='&pseudonim';
    IF przydzial*12 > 700 THEN
        DBMS_OUTPUT.PUT_LINE(imie ||' calkowity roczny przydzial > 700');
    ELSIF imie like '%A%' THEN
        DBMS_OUTPUT.PUT_LINE(imie ||' imie zawiera litere A');
    ELSIF miesiac = 1 THEN
        DBMS_OUTPUT.PUT_LINE(imie ||' styczen jest miesiacem przystapienia do stada');
    ELSE
        DBMS_OUTPUT.PUT_LINE(imie ||' nie odpowiada kryteriom');
    END IF;
END;
    

