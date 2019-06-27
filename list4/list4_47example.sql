--example

SELECT k.GetDisplayName() "Kocur", k.ZjadaRazem() "Zjada Razem" ,VALUE(k).func.nazwa "Funkcja"
FROM ObjKocury k;


SELECT k.GetDisplayName() "Kocur"
FROM ObjKocury k
WHERE VALUE(k).func.nazwa =(SELECT VALUE(k2).func.nazwa
FROM ObjKocury k2
WHERE k2.ByPseudo()='LOLA')
AND k.ByPseudo()!='LOLA';



SELECT
  k.GetWlasciciel().getDisplayName() "Kocur",
  COUNT(*) "Myszy na koncie"
FROM
  ObjKonto k
WHERE k.data_usuniecia IS NULL
GROUP BY k.GetWlasciciel().getDisplayName()
ORDER BY "Myszy na koncie" DESC;


--17
SELECT 
pseudo "POLUJE W POLU",
przydzial_myszy "PRZYDZIAL MYSZY",
nazwa "BANDA"
FROM Kocury K JOIN Bandy B ON K.NR_BANDY=B.NR_BANDY
WHERE (teren='POLE' OR teren='CALOSC') 
AND przydzial_myszy>50;

--version2
Select  k.ByPseudo() "POLUJE W POLU",
k.przydzial_myszy  "PRZYDZIAL MYSZY",
VALUE(k).band.nazwa "BANDA"
From ObjKocury k
where( VALUE(k).band.teren='POLE' OR  VALUE(k).band.teren='CALOSC') and k.przydzial_myszy >50;

----25
SELECT  imie "IMIE",
        funkcja "FUNKCJA",
        przydzial_myszy "PRZYDZIAL MYSZY"
FROM    Kocury  
WHERE   przydzial_myszy >= ALL(
            SELECT  3 * przydzial_myszy 
            FROM    Kocury K JOIN Bandy B on K.nr_bandy=B.nr_bandy
            WHERE   teren IN ('SAD','CALOSC') AND funkcja = 'MILUSIA'
        );
        
--25 version2     
SELECT  k.imie "IMIE",
        VALUE(k).func.nazwa "FUNKCJA",
        k.przydzial_myszy "PRZYDZIAL MYSZY"
FROM    ObjKocury k 
WHERE   k.przydzial_myszy >= ALL(
            SELECT  3 * k2.przydzial_myszy 
            FROM    ObjKocury k2  
            WHERE   VALUE(k).band.teren IN ('SAD','CALOSC') AND  VALUE(k).func.nazwa = 'MILUSIA'
        );
        
--35
set serveroutput on

DECLARE
  crpm NUMBER;
  imie ObjKocury.imie%TYPE;
  miesiac NUMBER;
  bylo BOOLEAN DEFAULT FALSE;
BEGIN
  SELECT
    k.imie,
    12 * k.ZjadaRazem(),
    k.IleMiesiecyWStadku()
  INTO
    imie, crpm, miesiac
  FROM ObjKocury k
  WHERE pseudo='&pseudo_kota';
  IF crpm > 700 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''calkowity roczny przydzial myszy >700''');
    bylo := TRUE;
  END IF;
  IF imie LIKE '%A%' THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''imi? zawiera litere A''');  
    bylo := TRUE;
  END IF;
  IF miesiac = 1 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''stycze? jest miesiacem przystapienia do stada''');    
    bylo := TRUE;
  END IF;
  IF NOT bylo THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''nie odpowiada kryteriom''');      
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''nie odpowiada kryteriom''');    
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--37

DECLARE
  bylo BOOLEAN DEFAULT FALSE;
  empty_rezult EXCEPTION;
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
    EXIT WHEN nr > 5;
  END LOOP;
  IF NOT bylo THEN RAISE empty_rezult; END IF;
EXCEPTION
  WHEN empty_rezult THEN DBMS_OUTPUT.PUT_LINE('Straszny blad! Nie ma kotow');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;


--36

DECLARE
sumaPrzydzialow NUMBER:=0;
zmian NUMBER:=0;
podwyzka NUMBER:=0;
przydzial ObjKocury.PRZYDZIAL_MYSZY%TYPE;
CURSOR odMinPrzydzialu IS
SELECT
    PSEUDO,
    (SELECT MAX_MYSZY FROM FUNKCJE F WHERE K.FUNKCJA = F.FUNKCJA) maxBandy
    FROM ObjKocury K
    ORDER BY 2;
   
kot odMinPrzydzialu%ROWTYPE;
BEGIN
    <<petla>>LOOP
        OPEN odMinPrzydzialu;
            LOOP
                FETCH odMinPrzydzialu INTO kot;
                SELECT SUM(przydzial_myszy) INTO sumaPrzydzialow FROM ObjKocury;
                EXIT WHEN odMinPrzydzialu%NOTFOUND;
                        IF sumaPrzydzialow <= 1050
                            THEN
                                SELECT PRZYDZIAL_MYSZY INTO przydzial FROM ObjKocury WHERE pseudo = kot.pseudo;
                                IF kot.maxBandy < ROUND(1.1*przydzial)
                                     THEN podwyzka:=kot.maxBandy-przydzial;
                                ELSE podwyzka:=ROUND(0.1*przydzial);
                                END IF;
                                IF podwyzka != 0
                                THEN zmian:=zmian+1;
                                END IF;
                            UPDATE ObjKocury SET przydzial_myszy = PRZYDZIAL_MYSZY + podwyzka
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
    FROM KocuryR;
 
rollback;

