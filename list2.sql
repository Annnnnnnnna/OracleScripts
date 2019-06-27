--17
SELECT 
pseudo "POLUJE W POLU",
przydzial_myszy "PRZYDZIAL MYSZY",
nazwa "BANDA"
FROM Kocury K JOIN Bandy B ON K.NR_BANDY=B.NR_BANDY
WHERE (teren='POLE' OR teren='CALOSC') 
AND przydzial_myszy>50;

--18
SELECT K2.IMIE, K2.W_STADKU_OD "POLUJE OD"
FROM Kocury K1 JOIN Kocury K2 ON K1.imie='JACEK' AND k2.w_stadku_od <K1.w_stadku_od
order by K2.w_stadku_od desc;

--19
--a
SELECT K1.IMIE, K1.FUNKCJA, NVL(K2.IMIE, ' ') "SZEF 1", NVL(K3.IMIE, ' ') "SZEF 2", NVL(K4.IMIE, ' ') "SZEF 3"
FROM KOCURY K1
    LEFT JOIN KOCURY K2 ON K1.SZEF = K2.PSEUDO
    LEFT JOIN KOCURY K3 ON K2.SZEF = K3.PSEUDO
    LEFT JOIN KOCURY K4 ON K3.SZEF = K4.PSEUDO
WHERE K1.FUNKCJA IN('KOT','MILUSIA');

--b version from the boss to the subordinate
SELECT IMIE, FUNKCJA, NVL(SZEF1, ' ')"SZEF 1", NVL(SZEF2, ' ') "SZEF 2", NVL(SZEF3, ' ')"SZEF 3"
FROM (SELECT IMIE, FUNKCJA , CONNECT_BY_ROOT IMIE AS IMIE_SZEFA, CONCAT('Szef ', LEVEL-1) AS ETYKIETA_SZEFA
      FROM KOCURY
      WHERE LEVEL != 1 AND FUNKCJA IN ('KOT', 'MILUSIA')
      CONNECT BY PRIOR PSEUDO=SZEF)
      PIVOT
    (
    Min(IMIE_SZEFA)
    FOR ETYKIETA_SZEFA
    IN ('Szef 1' "SZEF1", 'Szef 2' "SZEF2", 'Szef 3' "SZEF3")
    );
   --b version from the subordinate to the boss
SELECT Imie, Funkcja, NVL(SZEF1, ' ')"SZEF 1", NVL(SZEF2, ' ') "SZEF 2", NVL(SZEF3, ' ')"SZEF 3"
FROM (SELECT CONNECT_BY_ROOT IMIE Imie, CONNECT_BY_ROOT FUNKCJA  Funkcja, IMIE AS IMIE_SZEFA, CONCAT('Szef ', LEVEL-1) AS ETYKIETA_SZEFA
      FROM KOCURY
      WHERE LEVEL != 1
      CONNECT BY PRIOR SZEF=PSEUDO
      start with  FUNKCJA IN ('KOT', 'MILUSIA') )
      PIVOT
    (
    Min(IMIE_SZEFA)
    FOR ETYKIETA_SZEFA
    IN ('Szef 1' "SZEF1", 'Szef 2' "SZEF2", 'Szef 3' "SZEF3")
    );
--c
SELECT  CONNECT_BY_ROOT IMIE "Imie" ,CONNECT_BY_ROOT funkcja "Funkcja", SUBSTR(SYS_CONNECT_BY_PATH(RPAD(IMIE, 10,' ' ), '| '), 13)|| '|' "Imiona kolejnych szef�w"
FROM KOCURY
WHERE IMIE = 'MRUCZEK'
CONNECT BY PRIOR SZEF = PSEUDO
START WITH FUNKCJA IN('KOT', 'MILUSIA');


--20
SELECT K.imie "Imie kotki",B.nazwa "Nazwa bandy",W.imie_wroga "Imie wroga",
W.stopien_wrogosci"Ocena wroga",
WK.data_incydentu "Data inc."
from Kocury K 
JOIN bandy B ON K.nr_bandy=b.nr_bandy
join wrogowie_kocurow WK ON k.pseudo=WK.pseudo
join wrogowie W ON WK.imie_wroga=W.imie_wroga
WHERE wk.data_incydentu>'2007-01-01' and K.plec='D';

--21
SELECT B.nazwa "Nazwa bandy", COUNT(distinct (wk.pseudo)) "Koty z wrogami"
FROM Bandy B Join kocury K ON B.nr_bandy=K.nr_bandy
JOIN wrogowie_kocurow WK on K.pseudo=WK.pseudo
GROUP BY B.NAZWA;

--22
SELECT F.funkcja "Funkcja", WK.pseudo "Pseudonim kota", COUNT(wk.pseudo) "Liczba wrogow"
FROM kocury K join Funkcje F ON K.FUNKCJA=F.FUNKCJA
JOIN wrogowie_kocurow WK on K.pseudo=WK.pseudo
GROUP BY  WK.pseudo,F.funkcja
having count(wk.pseudo)>1;

--23
SELECT imie, 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) "DAWKA ROCZNA", 'powy�ej 864' "DAWKA" FROM Kocury WHERE  12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))>864 AND MYSZY_EXTRA IS NOT NULL
UNION
SELECT imie, 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) "DAWKA ROCZNA", '864' "DAWKA" FROM Kocury WHERE  12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))=864 AND MYSZY_EXTRA IS NOT NULL
UNION
SELECT imie, 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) "DAWKA ROCZNA", 'poni�ej 864' "DAWKA" FROM Kocury WHERE  12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))<864 AND MYSZY_EXTRA IS NOT NULL
ORDER BY "DAWKA ROCZNA" desc;

--24 z operatorem zbiorowym
SELECT NR_BANDY , NAZWA, TEREN FROM BANDY
MINUS
SELECT K.NR_BANDY , NAZWA, TEREN FROM KOCURY K JOIN BANDY B ON K.NR_BANDY=B.NR_BANDY;

--24 bez opertatora
SELECT B.NR_BANDY , NAZWA, TEREN 
FROM BANDY B left JOIN KOCURY K ON K.NR_BANDY=B.NR_BANDY
Where K.NR_BANDY IS NULL;

--25 version with MAX
SELECT K2.IMIE,K2.FUNKCJA, K2.przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury K1 JOIN Kocury K2 ON K1.funkcja='MILUSIA'and K1.pseudo<>K2.pseudo
join Bandy B ON K1.NR_BANDY=B.NR_BANDY and (teren='SAD' or teren='CALOSC')
GROUP BY K2.IMIE,K2.FUNKCJA,K2.przydzial_myszy
having (3*MAX(K1.PRZYDZIAL_MYSZY))<=K2.PRZYDZIAL_MYSZY;
--25 version without MAX
SELECT
  IMIE ,
  FUNKCJA ,
  PRZYDZIAL_MYSZY "PRZYDZIAL MYSZY"
FROM
  KOCURY
WHERE
  PRZYDZIAL_MYSZY >= 3 * (
    SELECT PRZYDZIAL_MYSZY FROM
      (SELECT * FROM KOCURY ORDER BY PRZYDZIAL_MYSZY DESC) K
    LEFT JOIN BANDY ON K.NR_BANDY = BANDY.NR_BANDY
    WHERE FUNKCJA='MILUSIA' AND (TEREN='SAD' OR TEREN='CALOSC') AND ROWNUM=1--pobieramy 1 wartosc czyli max
);
--25 version3
SELECT  imie "IMIE",
        funkcja "FUNKCJA",
        przydzial_myszy "PRZYDZIAL MYSZY"
FROM    Kocury  
WHERE   przydzial_myszy >= ALL(
            SELECT  3 * przydzial_myszy 
            FROM    Kocury K JOIN Bandy B on K.nr_bandy=B.nr_bandy
            WHERE   teren IN ('SAD','CALOSC') AND funkcja = 'MILUSIA'
        );
        
--26 
SELECT
  funkcja  "Funkcja",
  ROUND(AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))) "Srednio najw. i najm. myszy"
FROM
  KOCURY
GROUP BY FUNKCJA
HAVING AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) IN (
  (
    SELECT MAX((AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))))
    FROM KOCURY
    WHERE FUNKCJA != 'SZEFUNIO'
    GROUP BY FUNKCJA
  ),
  (
    SELECT MIN((AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))))--min
    FROM KOCURY
    WHERE FUNKCJA != 'SZEFUNIO'
    GROUP BY FUNKCJA
  )
);

--zadanie 27
--a
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) "Zjada"
FROM Kocury K
WHERE &n >= (SELECT COUNT (DISTINCT NVL(przydzial_myszy,0)+NVL(myszy_extra,0))
            FROM Kocury
            WHERE NVL(K.przydzial_myszy,0) + NVL(K.myszy_extra,0) <= 
                NVL(przydzial_myszy,0) + NVL(myszy_extra,0));
                
                
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) "Zjada"
FROM Kocury K
WHERE 6 >= (SELECT COUNT (DISTINCT NVL(przydzial_myszy,0)+NVL(myszy_extra,0))
            FROM Kocury k2
            WHERE NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0) >= 
                NVL(K.przydzial_myszy,0) + NVL(K.myszy_extra,0));

--b
SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0) "ZJADA"
FROM KOCURY
WHERE NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0) IN
    (SELECT *
     FROM  (SELECT DISTINCT (NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0)) "ZJADA2"
            FROM KOCURY
            ORDER BY "ZJADA2" DESC)
    WHERE ROWNUM <=6)
ORDER BY "ZJADA" DESC;

--c
SELECT K1.PSEUDO, NVL(K1.PRZYDZIAL_MYSZY, 0)+NVL(K1.MYSZY_EXTRA, 0) "ZJADA"
FROM KOCURY K1, KOCURY K2
WHERE  NVL(K1.PRZYDZIAL_MYSZY, 0)+NVL(K1.MYSZY_EXTRA, 0) <= NVL(K2.PRZYDZIAL_MYSZY, 0)+NVL(K2.MYSZY_EXTRA, 0)
GROUP BY K1.PSEUDO, NVL(K1.PRZYDZIAL_MYSZY, 0)+NVL(K1.MYSZY_EXTRA, 0)
HAVING COUNT(DISTINCT NVL(K2.PRZYDZIAL_MYSZY, 0)+NVL(K2.MYSZY_EXTRA, 0)) <=6
ORDER BY "ZJADA" DESC;

--d
SELECT PSEUDO, "ZJADA"
FROM (SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0) "ZJADA",
        DENSE_RANK() OVER (ORDER BY NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0)DESC)N
        FROM KOCURY)
WHERE N <=6;

--28
SELECT      EXTRACT(YEAR FROM w_stadku_od) || '' "Rok",
            COUNT(pseudo) "Liczba wystapien"
FROM        Kocury
GROUP BY    EXTRACT(YEAR FROM w_stadku_od)
HAVING      COUNT(pseudo) IN (
                (
                    SELECT * FROM
                        (SELECT      DISTINCT COUNT(pseudo)
                         FROM        Kocury
                         GROUP BY    EXTRACT(YEAR FROM w_stadku_od)
                         HAVING      COUNT(pseudo) > (
                                        SELECT      AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od)))
                                        FROM        Kocury
                                        GROUP BY    EXTRACT(YEAR FROM w_stadku_od)
                                    )
                         ORDER BY    COUNT(pseudo))
                    WHERE       ROWNUM = 1
                ),
                (
                    SELECT * FROM
                        (SELECT      DISTINCT COUNT(pseudo)
                         FROM        Kocury
                         GROUP BY    EXTRACT(YEAR FROM w_stadku_od)
                         HAVING      COUNT(pseudo) < (
                                        SELECT      AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od)))
                                        FROM        Kocury
                                        GROUP BY    EXTRACT(YEAR FROM w_stadku_od)
                                    )
                         ORDER BY    COUNT(pseudo) DESC)
                    WHERE       ROWNUM = 1
                 )
            )
UNION
SELECT      'Srednia',
            ROUND(AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))), 7)
FROM        Kocury
GROUP BY    EXTRACT(YEAR FROM w_stadku_od)
ORDER BY    2;

--29
--a
SELECT K1.IMIE,  NVL(K1.PRZYDZIAL_MYSZY, 0) + NVL(K1.MYSZY_EXTRA, 0) "ZJADA",
    AVG(NVL(K2.PRZYDZIAL_MYSZY, 0)+NVL(K2.MYSZY_EXTRA, 0)) "SREDNIA BANDY"
FROM  KOCURY K1 join KOCURY K2 on K1.NR_BANDY = K2.NR_BANDY
where  K1.PLEC = 'M' 
GROUP BY K1.IMIE,  NVL(K1.PRZYDZIAL_MYSZY, 0) + NVL(K1.MYSZY_EXTRA, 0) ,K1.NR_BANDY
HAVING  NVL(K1.PRZYDZIAL_MYSZY, 0) + NVL(K1.MYSZY_EXTRA, 0) < AVG(NVL(K2.PRZYDZIAL_MYSZY, 0)+NVL(K2.MYSZY_EXTRA, 0));

--b
SELECT K1.IMIE,  NVL(K1.PRZYDZIAL_MYSZY, 0) + NVL(K1.MYSZY_EXTRA, 0) "ZJADA",  K1.NR_BANDY, SREDNIA "SREDNIA BANDY"
FROM  KOCURY K1
JOIN ( SELECT AVG(NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0)) SREDNIA, NR_BANDY NumerBandy
            FROM KOCURY GROUP BY NR_BANDY)
        ON K1.NR_BANDY = NumerBandy
WHERE  NVL(K1.PRZYDZIAL_MYSZY, 0) + NVL(K1.MYSZY_EXTRA, 0) < SREDNIA  AND plec = 'M'; 

--c
SELECT K.imie,NVL(K.PRZYDZIAL_MYSZY, 0)+NVL(K.MYSZY_EXTRA, 0)"ZJADA",K.nr_bandy "NR BANDY",(SELECT AVG(NVL(przydzial_myszy,0)+NVL(MYSZY_EXTRA, 0))
                    FROM Kocury
                    WHERE nr_bandy=K.nr_bandy ) "SREDNIA BANDY"
FROM Kocury K
WHERE plec='M'and NVL(K.PRZYDZIAL_MYSZY, 0)+NVL(K.MYSZY_EXTRA, 0)<=(SELECT AVG(NVL(przydzial_myszy,0)+NVL(MYSZY_EXTRA, 0))
                    FROM Kocury
                    WHERE nr_bandy=K.nr_bandy);

--30
SELECT IMIE, W_STADKU_OD || '<--- Najstarszy w bandzie ' || NAZWA "Wstapil do stadka"
FROM (SELECT IMIE, NR_BANDY Kocury_NR_B, W_STADKU_OD, RANK() OVER (PARTITION BY NR_BANDY ORDER BY W_STADKU_OD)POZYCJA
      FROM KOCURY)
     JOIN BANDY B ON Kocury_NR_B =  B.NR_BANDY
WHERE POZYCJA = 1
UNION
SELECT IMIE, W_STADKU_OD || '<--- Najmlodszy w bandzie ' || NAZWA "Wstapil do stadka"
FROM (SELECT IMIE, NR_BANDY Kocury_NR_B, W_STADKU_OD, RANK() OVER (PARTITION BY NR_BANDY ORDER BY W_STADKU_OD DESC)POZYCJA
      FROM KOCURY)
     JOIN BANDY B ON Kocury_NR_B =  B.NR_BANDY   
WHERE POZYCJA = 1
UNION
SELECT IMIE, W_STADKU_OD||'' "Wstapil do stadka"
FROM KOCURY
WHERE IMIE NOT IN (SELECT IMIE
                        FROM (SELECT IMIE,  W_STADKU_OD, RANK() OVER (PARTITION BY NR_BANDY ORDER BY W_STADKU_OD)POZYCJA  FROM KOCURY)
                        WHERE POZYCJA = 1
                        UNION
                        SELECT IMIE
                        FROM (SELECT IMIE,  W_STADKU_OD, RANK() OVER (PARTITION BY NR_BANDY ORDER BY W_STADKU_OD DESC)POZYCJA  FROM KOCURY)
                        WHERE POZYCJA = 1);
                        
--31
CREATE VIEW FIRST_VIEW AS
SELECT NAZWA, AVG(NVL(PRZYDZIAL_MYSZY, 0)) "SRED_SPOZ",MAX(NVL(PRZYDZIAL_MYSZY, 0))"MAX_SPOZ",
    MIN(NVL(PRZYDZIAL_MYSZY, 0))"MIN_SPOZ",COUNT(IMIE)"LICZBA", COUNT(MYSZY_EXTRA)"KOTY_Z_DOD"
FROM KOCURY K JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
GROUP BY NAZWA

SELECT PSEUDO, IMIE, FUNKCJA, NVL(PRZYDZIAL_MYSZY, 0) "PRZYDZIAL MYSZY", 'OD ' ||MIN_SPOZ ||' DO ' ||MAX_SPOZ "GRANICE SPOZYCIA", W_STADKU_OD "LOWI OD"
FROM KOCURY K 
    JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY  
    JOIN FIRST_VIEW FV ON B.NAZWA = FV.NAZWA
WHERE PSEUDO = '&PSEUDO';

--32
UPDATE KOCURY K
SET PRZYDZIAL_MYSZY = NVL(PRZYDZIAL_MYSZY, 0)+(CASE PLEC
                       WHEN 'D' THEN(SELECT MIN(NVL(PRZYDZIAL_MYSZY,0)*0.1)
                                                                    FROM KOCURY)
                       WHEN 'M' THEN 10
                       END),
    MYSZY_EXTRA = (NVL(MYSZY_EXTRA, 0) + ROUND(0.15*(SELECT NVL(AVG(NVL(MYSZY_EXTRA, 0)), 0) 
                                                    FROM KOCURY
                                                    WHERE NR_BANDY =K.NR_BANDY)))
WHERE PSEUDO IN (SELECT PSEUDO
                 FROM (SELECT PSEUDO, NR_BANDY K_NR_B, RANK() OVER (PARTITION BY NR_BANDY ORDER BY W_STADKU_OD) POZYCJA
                       FROM KOCURY)
                 JOIN BANDY B ON K_NR_B =  B.NR_BANDY   
                 WHERE POZYCJA <4 AND NAZWA IN( 'CZARNI RYCERZE', 'LACIACI MYSLIWI'));
                                      

SELECT PSEUDO, PLEC, nvl(PRZYDZIAL_MYSZY,0), nvl(MYSZY_EXTRA,0)
FROM KOCURY
WHERE PSEUDO IN (SELECT PSEUDO
                 FROM (SELECT PSEUDO, NR_BANDY K_NR_B, RANK() OVER (PARTITION BY NR_BANDY ORDER BY W_STADKU_OD) POZYCJA
                       FROM KOCURY)
                 JOIN BANDY B ON K_NR_B =  B.NR_BANDY   
                 WHERE POZYCJA <4 AND NAZWA IN( 'CZARNI RYCERZE', 'LACIACI MYSLIWI'));
ROLLBACK ; 

--33
--a
SELECT DECODE("PLEC", 'Kocur', ' ', NAZWA) "NAZWA BANDY", "PLEC",  "ILE",  "SZEFUNIO",  "BANDZIOR",  "LOWCZY",  "LAPACZ",  "KOT",  "MILUSIA",  "DZIELCZY", "SUMA"
FROM  (SELECT NAZWA, DECODE(PLEC, 'D', 'Kotka', 'Kocur') "PLEC", TO_CHAR(COUNT(PSEUDO)) "ILE",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) "SZEFUNIO",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) "BANDZIOR",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   "LOWCZY",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   "LAPACZ",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))      "KOT",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))  "MILUSIA",
      TO_CHAR(SUM(DECODE(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) "DZIELCZY",
      TO_CHAR(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))                                 "SUMA"
      FROM  KOCURY K
      JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
      GROUP BY  NAZWA, PLEC

      UNION
      SELECT '-----------------','------','----','---------', '---------','---------','---------','---------','---------', '---------', '-------'
      FROM DUAL

      UNION
      SELECT 'ZJADA RAZEM', ' ', ' ',
      TO_CHAR(SUM(DECODE(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),--jesli dobra funkcja sumuje i zwraca zjada inaczej 0
      TO_CHAR(SUM(DECODE(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),
      TO_CHAR(SUM(DECODE(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),
      TO_CHAR(SUM(DECODE(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),
      TO_CHAR(SUM(DECODE(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),
      TO_CHAR(SUM(DECODE(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),
      TO_CHAR(SUM(DECODE(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))),
      TO_CHAR(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))
      FROM KOCURY)
ORDER BY NAZWA, PLEC DESC;

--b
SELECT DECODE(PlecK, 'Kotka', ' ', NAZWAB) BANDA, PlecK "PLEC",LICZ "LICZBA", SZEF "SZEFUNIO", BAN "BANDZIOR", LOW "LOWCZY", LAP "LAPACZ", KOT, MIL "MILUSIA", DZIEL "DZIELCZY", SUMA
FROM(SELECT  CASE GROUPING(NAZWA)
             WHEN 1 THEN 'ZJADA RAZEM' 
             ELSE NAZWA
             END AS NAZWAB,
             
             CASE GROUPING(NAZWA) 
             WHEN 1 THEN ' '
             ELSE PlecK 
             END AS PlecK,
             CASE GROUPING(PlecK)
             WHEN 1 
             THEN ' '
             ELSE
        TO_CHAR(MAX(LICZ))
        END AS LICZ,
        
        COALESCE(SUM(SZEF), 0) SZEF, COALESCE(SUM(BAN), 0) BAN, COALESCE(SUM(LOW), 0) LOW, COALESCE(SUM(LAP), 0) LAP,
        COALESCE(SUM(KOT), 0) KOT,  COALESCE(SUM(MIL), 0) MIL,  COALESCE(SUM(DZIEL), 0) DZIEL, SUM(SUMA)AS SUMA
     FROM (SELECT NAZWA, DECODE(PLEC, 'M', 'Kocur','D', 'Kotka')AS PlecK,COUNT(PLEC) OVER (PARTITION BY NAZWA, PLEC) AS LICZ, NVL(przydzial_myszy,0)+NVL(myszy_extra,0)AS MYSZY_CALK,
                FUNKCJA, SUM(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) OVER (PARTITION BY NAZWA, PLEC) AS SUMA
           FROM KOCURY  K JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
           GROUP BY NAZWA, PLEC, NVL(przydzial_myszy,0)+NVL(myszy_extra,0), FUNKCJA )
           PIVOT
          (SUM (MYSZY_CALK)
           FOR FUNKCJA IN ('SZEFUNIO' AS SZEF,  'BANDZIOR' AS BAN,'LOWCZY' AS LOW, 'LAPACZ' AS LAP, 'KOT' AS KOT, 'MILUSIA' AS MIL, 'DZIELCZY' AS DZIEL))
    GROUP BY  ROLLUP(NAZWA, PlecK)
    HAVING GROUPING(NAZWA) = 1  OR (GROUPING(NAZWA) + GROUPING(PlecK) = 0))
ORDER BY NAZWAB, PlecK;


--33 version 2
SELECT      DECODE(plec, 'Kotka', ' ', nazwa) nazwa,
            plec,
            ile,
            szefunio,
            bandzior,
            lowczy,
            lapacz,
            kot,
            milusia,
            dzielczy,
            suma
FROM        (
                SELECT      nazwa,
                            DECODE(plec, 'M', 'Kocor', 'Kotka') plec,
                            TO_CHAR(COUNT(pseudo)) ile,
                            TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) szefunio,
                            TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) bandzior,
                            TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) lowczy,
                            TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) lapacz,
                            TO_CHAR(SUM(DECODE(funkcja, 'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) kot,
                            TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) milusia,
                            TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) dzielczy,
                            TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) suma
                FROM        Kocury NATURAL JOIN Bandy
                GROUP BY    nazwa, plec
                UNION
                SELECT 'Z--------------', '------', '--------', '---------', '---------', '--------', '--------', '--------', '--------', '--------', '--------'
                FROM DUAL
                UNION
                SELECT      'Zjada razem' nazwa,
                            ' ' plec,
                            TO_CHAR(COUNT(pseudo)) ile,
                            TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) szefunio,
                            TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) bandzior,
                            TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) lowczy,
                            TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) lapacz,
                            TO_CHAR(SUM(DECODE(funkcja, 'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) kot,
                            TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) milusia,
                            TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) dzielczy,
                            TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) suma
                FROM        Kocury NATURAL JOIN Bandy
                ORDER BY 1, 2
            );
           
--
SELECT      DECODE(plec, 'Kotka', ' ', nazwa) nazwa,
            plec,
            ile,
            szefunio,
            bandzior,
            lowczy,
            lapacz,
            kot,
            milusia,
            dzielczy,
            suma
FROM        (
    (
        SELECT  TO_CHAR(nazwa) nazwa,
                DECODE(plec, 'M', 'Kocor', 'Kotka') plec,
                TO_CHAR(ile) ile,
                TO_CHAR(NVL(szefunio, 0)) szefunio,
                TO_CHAR(NVL(bandzior, 0)) bandzior,
                TO_CHAR(NVL(lowczy, 0)) lowczy,
                TO_CHAR(NVL(lapacz, 0)) lapacz,
                TO_CHAR(NVL(kot, 0)) kot,
                TO_CHAR(NVL(milusia, 0)) milusia,
                TO_CHAR(NVL(dzielczy, 0)) dzielczy,
                TO_CHAR(NVL(suma, 0)) suma
        FROM (
            SELECT      nazwa,
                        plec,
                        funkcja,
                        NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) liczba
            FROM        Kocury NATURAL JOIN Bandy
            GROUP BY    nazwa, plec, funkcja, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
        )
        PIVOT (
           SUM(liczba) FOR funkcja IN (
            'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz,
            'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy
            )
        ) JOIN (
            SELECT      b1.nazwa n,
                        k1.plec p,
                        COUNT(pseudo) ile,
                        SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma
            FROM        Kocury k1 INNER JOIN Bandy b1 ON b1.nr_bandy = k1.nr_bandy
            WHERE       b1.nazwa = nazwa AND k1.plec = plec
            GROUP BY    b1.nazwa, k1.plec
        ) ON n = nazwa AND p = plec
    )
    UNION
    (
        SELECT 'Z--------------', '------', '--------', '---------', '---------', '--------', '--------', '--------', '--------', '--------', '--------'
        FROM DUAL
    )
    UNION
    (
        SELECT  'Zjada razem' nazwa,
                ' ' plec,
                TO_CHAR(ile) ile,
                TO_CHAR(NVL(szefunio, 0)) szefunio,
                TO_CHAR(NVL(bandzior, 0)) bandzior,
                TO_CHAR(NVL(lowczy, 0)) lowczy,
                TO_CHAR(NVL(lapacz, 0)) lapacz,
                TO_CHAR(NVL(kot, 0)) kot,
                TO_CHAR(NVL(milusia, 0)) milusia,
                TO_CHAR(NVL(dzielczy, 0)) dzielczy,
                TO_CHAR(NVL(suma, 0)) suma
        FROM (
            SELECT      funkcja,
                        NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) liczba
            FROM        Kocury NATURAL JOIN Bandy
        )
        PIVOT (
           SUM(liczba) FOR funkcja IN (
            'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz,
            'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy
            )
        ) CROSS JOIN (
            SELECT      COUNT(pseudo) ile,
                        SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma
            FROM        Kocury k1 INNER JOIN Bandy b1 ON b1.nr_bandy = k1.nr_bandy
        )
    )
    ORDER BY    1, 2
);
 
SELECT K.pseudo, nr_bandy
FROM Kocury K LEFT JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
WHERE plec='M' AND nr_bandy IN
        (SELECT nr_bandy
        FROM Kocury K
        WHERE plec = 'M'
        GROUP BY nr_bandy
        HAVING AVG(NVL(przydzial_myszy,0))>55) AND WK.pseudo IS NULL;