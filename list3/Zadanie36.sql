SET SERVEROUTPUT ON;
DECLARE
sumaPrzydzialow NUMBER:=0;
zmian NUMBER:=0;
podwyzka NUMBER:=0;
przydzial KOCURY.PRZYDZIAL_MYSZY%TYPE;
CURSOR odMinPrzydzialu IS 
SELECT 
    PSEUDO,
    (SELECT MAX_MYSZY FROM FUNKCJE F WHERE K.FUNKCJA = F.FUNKCJA) maxFunkcji
    FROM KOCURY K
    ORDER BY 2;
    
kot odMinPrzydzialu%ROWTYPE;
BEGIN
   <<petla>>LOOP
        OPEN odMinPrzydzialu;
            LOOP
                FETCH odMinPrzydzialu INTO kot;
                SELECT SUM(PRZYDZIAL_MYSZY) INTO sumaPrzydzialow FROM KOCURY;
                EXIT WHEN odMinPrzydzialu%NOTFOUND;
                        IF sumaPrzydzialow <= 1050
                            THEN
                                SELECT PRZYDZIAL_MYSZY INTO przydzial FROM KOCURY WHERE pseudo = kot.pseudo;
                                IF kot.maxFunkcji < ROUND(1.1*przydzial)
                                     THEN podwyzka:=kot.maxFunkcji-przydzial;
                                ELSE podwyzka:=ROUND(0.1*przydzial);
                                END IF;
                                IF podwyzka != 0 
                                THEN zmian:=zmian+1;
                                END IF;
                            UPDATE Kocury SET PRZYDZIAL_MYSZY = PRZYDZIAL_MYSZY + podwyzka
                            WHERE pseudo = kot.pseudo;
                        ELSE 
                            DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || sumaPrzydzialow||' Zmian - ' || zmian);
                            EXIT petla;
                        END IF;
           END LOOP;
        CLOSE odMinPrzydzialu;
    END LOOP;
END;

SELECT 
    imie, 
    NVL(przydzial_myszy,0) "Myszki po podwyzce" 
    FROM Kocury;

ROLLBACK;