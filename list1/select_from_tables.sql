ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SELECT imie_wroga "WROG",
opis_incydentu "PRZEWINA"
FROM Wrogowie_Kocurow
WHERE EXTRACT(YEAR FROM data_incydentu)=2009;

SELECT imie,
funkcja,
w_stadku_od "Z NAMI OD"
FROM Kocury
WHERE plec='D' AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';

SELECT imie_wroga "WROG",
gatunek,
stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

SELECT imie||' zwany '||pseudo||' (fun. '||funkcja||') lowi myszki w bandzie '||nr_bandy||' od '||w_stadku_od "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec='M'
ORDER BY w_stadku_od desc, pseudo;

SELECT pseudo,
REGEXP_REPLACE(
REGEXP_REPLACE(pseudo, 'L', '%', 1, 1), 'A', '#', 1, 1) "Po wymianie A na # oraz L na %"
FROM KOCURY
WHERE INSTR(pseudo, 'A') != 0 AND INSTR(pseudo, 'L') != 0;
--pseudo LIKE '%A%L%' or pseudo LIKE '%L%A%';

SELECT imie,
w_stadku_od "W stadku",
ROUND(NVL(przydzial_myszy,0) / 1.1) "Zjadal",
ADD_MONTHS(w_stadku_od,6) "Podwyzka",
przydzial_myszy "Zjada"
FROM Kocury
WHERE EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9
AND MONTHS_BETWEEN(SYSDATE, W_STADKU_OD) >= 96;

SELECT imie,
NVL(przydzial_myszy,0) * 3 "MYSZY KWRTALNIE",
NVL(myszy_extra,0)*3 "KWARTALNE DODATKI"
FROM Kocury
WHERE przydzial_myszy>2*NVL(myszy_extra,0)
AND przydzial_myszy>=55;

SELECT imie,
CASE 
WHEN 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))>660
THEN TO_CHAR(12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))
WHEN 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))=660
THEN 'Limit'
ELSE 'Ponizej 660'
END "Zjada rocznie"
FROM KOCURY;

-- 23 paüdziernik
SELECT pseudo,
w_stadku_od "W STADKU",
CASE
WHEN EXTRACT(DAY FROM w_stadku_od) < 16
THEN
    CASE
    WHEN NEXT_DAY(LAST_DAY('2017-10-23') - 7, 'úroda') > '2017-10-23'
    THEN NEXT_DAY(LAST_DAY('2017-10-23') - 7, 'úroda')
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-23', 1)) - 7, 'úroda')
    END
ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-23', 1)) - 7, 'úroda')
END "WYPLATA"
FROM Kocury;

-- 26 paüdziernik
SELECT pseudo,
w_stadku_od "W STADKU",
CASE
WHEN EXTRACT(DAY FROM w_stadku_od) < 16
THEN
    CASE
    WHEN NEXT_DAY(LAST_DAY('2017-10-26') - 7, 'úroda') > '2017-10-26'
    THEN NEXT_DAY(LAST_DAY('2017-10-26') - 7, 'úroda')
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-26', 1)) - 7, 'úroda')
    END
ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-26', 1)) - 7, 'úroda')
END "WYPLATA"
FROM Kocury;

SELECT CASE COUNT(pseudo)
WHEN 1 
THEN pseudo||' - Unikalny'
ELSE pseudo||' - nieunikalny'
END "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;

SELECT CASE COUNT(szef)
WHEN 1 
THEN szef||' - Unikalny'
ELSE szef||' - nieunikalny'
END "Unikalnosc atr. PSEUDO"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef;

SELECT pseudo "Pseudonim",
COUNT(imie_wroga)"Liczba wrogow" 
FROM WROGOWIE_KOCUROW
GROUP BY pseudo
HAVING COUNT(imie_wroga)>=2;

SELECT 'Liczba kotow=  '|| COUNT(*)||' lowi jako '||funkcja||' i zjada max. '|| MAX(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))||' myszy miesiecznie' " "
FROM Kocury
WHERE plec!='M' 
AND funkcja!='szefuniu'
GROUP BY funkcja
Having avg(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))>50;

SELECT 
nr_bandy "Nr bandy",plec "Plec", MIN(NVL(przydzial_myszy,0)) "Minimalny przydzial"
FROM Kocury
GROUP BY nr_bandy,plec;

SELECT level "Poziom", 
pseudo "Pseudonim",
funkcja "Funkcja",
nr_bandy "Nr bandy"
FROM Kocury
WHERE plec='M'
CONNECT BY PRIOR pseudo=szef
START WITH funkcja='BANDZIOR';

SELECT 
LPAD(level - 1, (level - 1) * 4 + 1, '===>') ||'        ' || imie "Hierarchia",
NVL(szef,'Sam sobie panem')"Pseudo szefa",
funkcja "Funkcja"
FROM Kocury
WHERE NVL(MYSZY_EXTRA, 0) > 0
CONNECT BY PRIOR pseudo=szef
START WITH szef IS NULL;

SELECT
LPAD(' ',(level - 1)*4)||pseudo "Droga sluzbowa"
FROM KOCURY
CONNECT BY PRIOR szef=pseudo
START WITH PLEC = 'M'
AND MONTHS_BETWEEN(SYSDATE, W_STADKU_OD) > 96
AND NVL(MYSZY_EXTRA, 0) = 0;


