SET SERVEROUTPUT ON;

DECLARE
numerBandy BANDY.NR_BANDY%TYPE:=&numer_bandy;
nazwaBandy BANDY.NAZWA%TYPE:='&nazwa_bandy';
terenBandy BANDY.TEREN%TYPE:='&teren_bandy';
blad STRING(100);
blednyNumerBandy EXCEPTION;
wartoscIstnieje EXCEPTION;
counter NUMBER;
BEGIN
    
    IF numerBandy <= 0 THEN
        RAISE blednyNumerBandy;
    END IF;
    blad := '';
    SELECT COUNT(NR_BANDY) into counter FROM BANDY WHERE nr_bandy = numerBandy;
    IF counter > 0 THEN
        blad:=numerBandy;
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