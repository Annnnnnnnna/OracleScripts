SET SERVEROUTPUT ON;

DECLARE
CURSOR kursorFunkcje IS
    SELECT DISTINCT funkcja
    FROM KOCURY;
CURSOR kursorBandy IS
    SELECT DISTINCT nr_bandy, nazwa
    FROM KOCURY LEFT JOIN BANDY USING (Nr_bandy)
    ORDER by 2;
CURSOR kursorPlec IS
    SELECT DISTINCT plec, 
    DECODE(plec,'D','Kotka','Kocor')tekst
    FROM KOCURY
    ORDER BY 1;
counter NUMBER;

BEGIN
  DBMS_OUTPUT.PUT(RPAD('NAZWA BANDY', 20) || RPAD('PLEC', 7) || RPAD('ILE', 4));
  FOR funkcja IN kursorFunkcje 
  LOOP
      DBMS_OUTPUT.PUT(LPAD(funkcja.funkcja, 10));
  END LOOP;
    DBMS_OUTPUT.PUT_LINE(LPAD('SUMA', 10));
    DBMS_OUTPUT.PUT(LPAD(' ', 20, '-') || LPAD(' ', 7, '-') || LPAD(' ', 5, '-'));
  FOR funkcja IN kursorFunkcje LOOP
      DBMS_OUTPUT.PUT(LPAD(' ', 10, '-'));
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(LPAD(' ', 10, '-'));
  
  FOR banda IN kursorBandy 
  LOOP
  DBMS_OUTPUT.PUT(RPAD(banda.nazwa, 20));
    FOR plec IN kursorPlec 
    LOOP 
        SELECT count(*) into counter
        FROM KOCURY
        WHERE nr_bandy = banda.nr_bandy AND plec = plec.plec;
        IF plec.tekst = 'Kotka' THEN
        DBMS_OUTPUT.PUT(LPAD(plec.tekst, 6) || LPAD(counter, 5)|| ' ');
        ELSE 
        DBMS_OUTPUT.PUT(LPAD(plec.tekst, 26)|| LPAD(counter, 5)|| ' ');
        END IF;
            FOR funkcja In kursorFunkcje
            LOOP
            SELECT SUM( CASE
            WHEN funkcja = funkcja.funkcja THEN NVL(przydzial_myszy,0) + NVL(myszy_extra,0)
            ELSE 0
            END) into counter
            FROM KOCURY
            WHERE nr_bandy=banda.nr_bandy AND plec=plec.plec;
            DBMS_OUTPUT.PUT(LPAD(counter || ' ',10));
            END LOOP;
            
            SELECT SUM (NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) into counter
            FROM KOCURY
            WHERE nr_bandy=banda.nr_bandy AND plec=plec.plec;
            DBMS_OUTPUT.PUT_LINE(LPAD(counter || ' ',10));
    END LOOP;
  END LOOP;
    DBMS_OUTPUT.PUT('Z' || LPAD(' ', 19, '-') || LPAD(' ', 7, '-') || LPAD(' ', 5, '-'));
  FOR funkcja IN kursorFunkcje LOOP
        DBMS_OUTPUT.PUT(LPAD(' ', 10, '-'));
  END LOOP;
    DBMS_OUTPUT.PUT_LINE(LPAD(' ', 10, '-'));
    DBMS_OUTPUT.PUT(RPAD('ZJADA RAZEM', 20) || LPAD(' ', 7) || LPAD(' ', 5));
    
        FOR funkcja in kursorFunkcje
        LOOP
        SELECT SUM (NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) into counter
        FROM KOCURY 
        WHERE funkcja = funkcja.funkcja;
        DBMS_OUTPUT.PUT(LPAD(counter|| ' ',10));
        END LOOP;
        
        SELECT SUM (NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) into counter
        FROM KOCURY;
        DBMS_OUTPUT.PUT_LINE(LPAD(counter|| ' ',10));
END;

