SET SERVEROUTPUT ON
DECLARE 
    l_przelozonych NUMBER := '&liczba';
    l_max NUMBER := 1;
    aktualny_kot kocury%ROWTYPE;
    aktualny_poziom NUMBER := 1;
BEGIN       
    SELECT MAX(level - 1) INTO l_max
    FROM Kocury
    CONNECT BY PRIOR pseudo = szef
    START WITH szef IS NULL;
    
    IF l_max > l_przelozonych THEN
    l_max := l_przelozonych;
    END IF;
    
    DBMS_OUTPUT.PUT(RPAD('Imie', 10));
    FOR i IN 1..l_max LOOP
        DBMS_OUTPUT.PUT('  |  ' || RPAD('Szef ' || i, 10));
    END LOOP;
      DBMS_OUTPUT.PUT_LINE(' ');
      
    FOR kot IN (SELECT * FROM Kocury WHERE funkcja IN ('KOT', 'MILUSIA'))
    LOOP
        aktualny_kot :=  kot;
        aktualny_poziom := 1;
        DBMS_OUTPUT.PUT(RPAD(aktualny_kot.imie, 10));
        WHILE aktualny_poziom <= l_max LOOP
            IF aktualny_kot.szef IS NULL THEN
                DBMS_OUTPUT.PUT('  |  ' || RPAD(' ', 10));
            ELSE
                SELECT * INTO aktualny_kot FROM Kocury WHERE pseudo=aktualny_kot.szef;
                DBMS_OUTPUT.put('  |  ' || RPAD(aktualny_kot.imie, 10));
            END IF;
            aktualny_poziom := aktualny_poziom + 1;    
        END LOOP;
      DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END;