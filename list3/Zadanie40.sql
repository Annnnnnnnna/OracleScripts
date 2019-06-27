SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE nowaBanda(numerBandy bandy.nr_bandy%TYPE, nazwaBandy bandy.nazwa%TYPE, terenBandy bandy.teren%TYPE)--nazwa oraz parametry procedury
IS
blad STRING(100):='';
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
        WHEN blednyNumerBandy THEN DBMS_OUTPUT.PUT_LINE('Numer Bandy musi byc wiekszy od 0');
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



ROLLBACK;