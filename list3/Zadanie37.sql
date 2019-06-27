SET SERVEROUTPUT ON
DECLARE
 liczba NUMBER:=0;
 BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim    Zjada');
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    FOR kot IN (SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EXTRA,0) przydzial
                            FROM KOCURY
                            ORDER BY 2 DESC
                            FETCH FIRST 5 ROWS ONLY)
    LOOP
    liczba:=liczba+1;
    DBMS_OUTPUT.PUT_LINE(RPAD(liczba,4, ' ')||RPAD(kot.PSEUDO,11, ' ')|| LPAD(TO_CHAR(kot.przydzial),6, ' '));
    END LOOP; 
 END;
 
 
DECLARE
  bylo BOOLEAN DEFAULT FALSE;--bez gdy rows dziala
  empty_rezult EXCEPTION;--bez gdy rows dziaa
  liczba NUMBER:=0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
  DBMS_OUTPUT.PUT_LINE('------------------------');
  
  FOR kot IN (
    SELECT
      k.pseudo,
      k.ZjadaRazem() zjada
    FROM ObjKocury k 
    ORDER BY zjada DESC
  ) LOOP
    bylo := TRUE;
    DBMS_OUTPUT.PUT_LINE(RPAD(liczba,4, ' ')||RPAD(kot.pseudo,11, ' ')|| LPAD(TO_CHAR(kot.zjada),6, ' '));
    liczba:=liczba+1;
    EXIT WHEN nr = 5;
  END LOOP;
  IF NOT bylo THEN RAISE empty_rezult; END IF;
EXCEPTION
  WHEN empty_rezult THEN DBMS_OUTPUT.PUT_LINE('Straszny blad! Nie ma kotow');--i tego
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;


