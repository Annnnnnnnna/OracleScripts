SET SERVEROUTPUT ON;

DECLARE
numerBandy bandy.nr_bandy%TYPE:=&numer;
nazwaBandy bandy.nazwa%TYPE:='&nazwa'; 
terenBandy bandy.teren%TYPE:='&teren';
BEGIN
nowaBanda(numerBandy, nazwaBandy, terenBandy);
END;

ROLLBACK;