--LISTA 4
SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
 
DROP TABLE KocuryObject;
DROP TABLE ElitaO;
DROP TABLE PlebsO;
DROP TABLE IncydentyO;
DROP TABLE KontoO;
DROP TYPE KontoT;
DROP TYPE ElitaT;
DROP TYPE PlebsT;
DROP TYPE IncydentyT;
DROP TYPE KocuryType;
 
select * from KocuryType;
select * from ElitaO;
select * from PlebsO;
select * from IncydentyO;
select * from KontoO;
select * from KontoT;
select * from ElitaT;
select * from PlebsT;
select * from incydentyt;
select * from kocuryt;
 
--Kocury
CREATE OR REPLACE TYPE KocuryType AS OBJECT
(
    imie VARCHAR2(15),
    plec VARCHAR2(1),
    pseudo VARCHAR2(15),
    funkcja VARCHAR2(10),
    szef REF KocuryType,
    w_stadku_od DATE,
    przydzial_myszy NUMBER(3),
    myszy_extra NUMBER(3),
    nr_bandy NUMBER(2),
    MEMBER FUNCTION dane_kota RETURN VARCHAR2,
    MEMBER FUNCTION calkowity_przydzial_myszy RETURN NUMBER,
    MAP MEMBER FUNCTION ilosc_myszy_dni_w_stadku RETURN NUMBER
);

CREATE TABLE KocuryObject OF KocuryType
(
    CONSTRAINT PS_KOT_PK PRIMARY KEY (pseudo)
);
 
SELECT  imie "IMIE",
        funkcja "FUNKCJA",
        przydzial_myszy "PRZYDZIAL MYSZY"
FROM    KocuryO  
WHERE   przydzial_myszy >= ALL(
            SELECT  2 * przydzial_myszy
            FROM    KocuryO NATURAL JOIN Bandy
            WHERE   teren IN ('SAD','CALOSC'));
 
--Incydenty
CREATE OR REPLACE TYPE IncydentyT AS OBJECT
(
    nr_incydentu NUMBER,
    kot REF KocuryT,
    imie_wroga VARCHAR2(15),
    data_incydentu DATE,
    opis_incydentu VARCHAR2(50),
    MEMBER FUNCTION data_opis_incydentu RETURN VARCHAR2
);
/
 
CREATE TABLE IncydentyO OF IncydentyT
(
    kot SCOPE IS KocuryO CONSTRAINT i_kot_nn NOT NULL,
    imie_wroga CONSTRAINT i_imie_wroga_nn NOT NULL,
    CONSTRAINT in_zlozony_pk PRIMARY KEY (nr_incydentu)
);
/
 
 
--Plebs
CREATE OR REPLACE TYPE PlebsT AS OBJECT
(
    nr_kota NUMBER(3),
    kot     REF KocuryT,
    MAP MEMBER FUNCTION nr_kota_sortowanie RETURN NUMBER,
    MEMBER FUNCTION szef_kota_z_plebsu RETURN VARCHAR2
);
/
 
 
CREATE TABLE PlebsO OF PlebsT
(
    kot SCOPE IS KocuryO CONSTRAINT pl_kot_nn NOT NULL,
    CONSTRAINT nr_kot_pk PRIMARY KEY (nr_kota)
);
 
 
--Elita
CREATE OR REPLACE TYPE ElitaT AS OBJECT
(
    nr_kota NUMBER(3),
    kot     REF KocuryT,
    sluga   REF PlebsT,
    MEMBER FUNCTION ile_myszy RETURN NUMBER
);
/
 
CREATE TABLE ElitaO OF ElitaT
(
    kot SCOPE IS KocuryO CONSTRAINT el_kot_nn NOT NULL,
    sluga SCOPE IS PlebsO CONSTRAINT el_sluga_nn NOT NULL,
    CONSTRAINT nr_kota_e_pk PRIMARY KEY (nr_kota)
);
 
 
--Konto
CREATE OR REPLACE TYPE KontoT AS OBJECT
(
    nr_myszy            NUMBER(5),
    kot_elita           REF ElitaT,
    data_wprowadzenia   DATE,
    data_usuniecia      DATE,
    MEMBER FUNCTION ile_od_wyplaty RETURN VARCHAR2
 
);
/
 
CREATE TABLE KontoO OF KontoT
(
    kot_elita SCOPE IS ElitaO CONSTRAINT ko_kot_e_nn NOT NULL,
    data_wprowadzenia DEFAULT SYSDATE,
    CONSTRAINT nr_konto_ord_pk PRIMARY KEY (nr_myszy)  
);
 
 
--------Body
--Kocury
CREATE OR REPLACE TYPE BODY KocuryT AS
 MEMBER FUNCTION calkowity_przydzial_myszy RETURN NUMBER IS
    BEGIN
        RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;
    MEMBER FUNCTION dane_kota RETURN VARCHAR2 IS
    BEGIN
        RETURN imie || ' (' || pseudo || ') ' || ' - ' || funkcja;
    END;
    MAP MEMBER FUNCTION ilosc_myszy_dni_w_stadku RETURN NUMBER IS
    BEGIN
        RETURN SYSDATE - w_stadku_od;
    END;
END;
/
 
--Incydenty
CREATE OR REPLACE TYPE BODY IncydentyT AS
    MEMBER FUNCTION data_opis_incydentu RETURN VARCHAR2 IS
    BEGIN
        RETURN data_incydentu || ' - ' || opis_incydentu;
    END;
END;
/
 
--Plebs
CREATE OR REPLACE TYPE BODY PlebsT AS
    MAP MEMBER FUNCTION nr_kota_sortowanie RETURN NUMBER IS
    BEGIN
        RETURN nr_kota;
    END;
 
    MEMBER FUNCTION szef_kota_z_plebsu RETURN VARCHAR2 IS szef_plebs VARCHAR2(15);
    BEGIN
        SELECT e.kot.pseudo
        INTO szef_plebs
        FROM ElitaO e
        WHERE DEREF(e.sluga) = SELF;
        RETURN szef_plebs;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 'Brak szefa';
    END;
END;
/
 
--Elita
CREATE OR REPLACE TYPE BODY ElitaT AS
    MEMBER FUNCTION ile_myszy RETURN NUMBER IS
        ilosc_myszy NUMBER;
    BEGIN
        SELECT  COUNT(*)
        INTO    ilosc_myszy
        FROM    KontoO K
        WHERE   DEREF(K.kot_elita) = SELF;
        RETURN  ilosc_myszy;
    END;
END;
/
 
 
--Konta
CREATE OR REPLACE TYPE BODY KontoT AS
    MEMBER FUNCTION ile_od_wyplaty RETURN VARCHAR2 IS
    BEGIN  
        RETURN SYSDATE - data_usuniecia;
    END;
END;
/
 
-------------------------------------INSERTY-----------------------------------------
--Kocury
INSERT INTO KocuryO
    SELECT 'MRUCZEK', 'M', 'TYGRYS', 'SZEFUNIO', NULL, '2002-01-01', 103, 33, 1 FROM Dual;
 
INSERT INTO KocuryO
    SELECT 'CHYTRY', 'M', 'BOLEK', 'DZIELCZY', REF(k), '2002-05-05', 50, NULL, 1 FROM KocuryO k WHERE k.pseudo = 'TYGRYS' UNION
    SELECT 'KOREK', 'M', 'ZOMBI', 'BANDZIOR', REF(k), '2004-03-16', 75, 13, 3 FROM KocuryO k WHERE k.pseudo = 'TYGRYS' UNION
    SELECT 'BOLEK', 'M', 'LYSY', 'BANDZIOR', REF(k), '2006-08-15', 72, 21, 2 FROM KocuryO k WHERE k.pseudo = 'TYGRYS' UNION
    SELECT 'RUDA', 'D', 'MALA', 'MILUSIA', REF(k), '2006-09-17', 22, 42, 1 FROM KocuryO k WHERE k.pseudo = 'TYGRYS' UNION
    SELECT 'PUCEK', 'M', 'RAFA', 'LOWCZY', REF(k), '2006-10-15', 65, NULL, 4 FROM KocuryO k WHERE k.pseudo = 'TYGRYS' UNION
    SELECT 'MICKA', 'D', 'LOLA', 'MILUSIA', REF(k), '2009-10-14', 25, 47, 1 FROM KocuryO k WHERE k.pseudo = 'TYGRYS';
 
INSERT INTO KocuryO
    SELECT 'SONIA', 'D', 'PUSZYSTA', 'MILUSIA', REF(k), '2010-11-18', 20, 35, 3 FROM KocuryO k WHERE k.pseudo = 'ZOMBI' UNION
    SELECT 'PUNIA', 'D', 'KURKA', 'LOWCZY', REF(k), '2008-01-01', 61, NULL, 3 FROM KocuryO k WHERE k.pseudo = 'ZOMBI' UNION
    SELECT 'JACEK', 'M', 'PLACEK', 'LOWCZY', REF(k), '2008-12-01', 67, NULL, 2 FROM KocuryO k WHERE k.pseudo = 'LYSY' UNION
    SELECT 'BARI', 'M', 'RURA', 'LAPACZ', REF(k), '2009-09-01', 56, NULL, 2 FROM KocuryO k WHERE k.pseudo = 'LYSY' UNION
    SELECT 'ZUZIA', 'D', 'SZYBKA', 'LOWCZY', REF(k), '2006-07-21', 65, NULL, 2 FROM KocuryO k WHERE k.pseudo = 'LYSY' UNION
    SELECT 'BELA', 'D', 'LASKA', 'MILUSIA', REF(k), '2008-02-01', 24, 28, 2 FROM KocuryO k WHERE k.pseudo = 'LYSY' UNION
    SELECT 'LATKA', 'D', 'UCHO', 'KOT', REF(k), '2011-01-01', 40, NULL, 4 FROM KocuryO k WHERE k.pseudo = 'RAFA' UNION
    SELECT 'DUDEK', 'M', 'MALY', 'KOT', REF(k), '2011-05-15', 40, NULL, 4 FROM KocuryO k WHERE k.pseudo = 'RAFA' UNION
    SELECT 'KSAWERY', 'M', 'MAN', 'LAPACZ', REF(k), '2008-07-12', 51, NULL, 4 FROM KocuryO k WHERE k.pseudo = 'RAFA' UNION
    SELECT 'MELA', 'D', 'DAMA', 'LAPACZ', REF(k), '2008-11-01', 51, NULL, 4 FROM KocuryO k WHERE k.pseudo = 'RAFA';
 
INSERT INTO KocuryO
    SELECT 'LUCEK', 'M', 'ZERO', 'KOT', REF(k), '2010-03-01', 43, NULL, 3 FROM KocuryO k WHERE k.pseudo = 'KURKA';
 
select * from KocuryO;
 
 
--Incydenty
INSERT INTO IncydentyO
    SELECT 1,REF(K),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY' FROM KocuryO K WHERE K.pseudo='TYGRYS' UNION
    SELECT 2,REF(K),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY' FROM KocuryO K WHERE K.pseudo='ZOMBI' UNION
    SELECT 3,REF(K),'KAZIO','2005-03-29','POSZCZUL BURKIEM' FROM KocuryO K WHERE K.pseudo='BOLEK' UNION
    SELECT 4,REF(K),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI' FROM KocuryO K WHERE K.pseudo='SZYBKA' UNION
    SELECT 5,REF(K),'CHYTRUSEK','2007-03-07','ZALECAL SIE' FROM KocuryO K WHERE K.pseudo='MALA' UNION
    SELECT 6,REF(K),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA' FROM KocuryO K WHERE K.pseudo='TYGRYS' UNION
    SELECT 7,REF(K),'DZIKI BILL','2007-11-10','ODGRYZL UCHO' FROM KocuryO K WHERE K.pseudo='BOLEK' UNION
    SELECT 8,REF(K),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA' FROM KocuryO K WHERE K.pseudo='LASKA' UNION
    SELECT 9,REF(K),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK' FROM KocuryO K WHERE K.pseudo='LASKA' UNION
    SELECT 10,REF(K),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY' FROM KocuryO K WHERE K.pseudo='DAMA' UNION
    SELECT 11,REF(K),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL' FROM KocuryO K WHERE K.pseudo='MAN' UNION
    SELECT 12,REF(K),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA'FROM KocuryO K WHERE K.pseudo='LYSY' UNION
    SELECT 13,REF(K),'DZIKI BILL','2009-09-03','ODGRYZL OGON' FROM KocuryO K WHERE K.pseudo='RURA' UNION
    SELECT 14,REF(K),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA' FROM KocuryO K WHERE K.pseudo='PLACEK' UNION
    SELECT 15,REF(K),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI' FROM KocuryO K WHERE K.pseudo='PUSZYSTA' UNION
    SELECT 16,REF(K),'BUREK','2010-12-14','POGONIL' FROM KocuryO K WHERE K.pseudo='KURKA' UNION
    SELECT 17,REF(K),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA' FROM KocuryO K WHERE K.pseudo='MALY' UNION
    SELECT 18,REF(K),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI' FROM KocuryO K WHERE K.pseudo='UCHO';
 
SELECT * FROM IncydentyO;
 
--Plebs
 
INSERT INTO PlebsO
    SELECT 1, REF(K) FROM KocuryO K WHERE K.pseudo='SZYBKA' UNION
    SELECT 2, REF(K) FROM KocuryO K WHERE K.pseudo='BOLEK' UNION
    SELECT 3, REF(K) FROM KocuryO K WHERE K.pseudo='LASKA' UNION
    SELECT 4, REF(K) FROM KocuryO K WHERE K.pseudo='MAN' UNION
    SELECT 5, REF(K) FROM KocuryO K WHERE K.pseudo='DAMA' UNION
    SELECT 6, REF(K) FROM KocuryO K WHERE K.pseudo='PLACEK' UNION
    SELECT 7, REF(K) FROM KocuryO K WHERE K.pseudo='RURA' UNION
    SELECT 8, REF(K) FROM KocuryO K WHERE K.pseudo='ZERO' UNION
    SELECT 9, REF(K) FROM KocuryO K WHERE K.pseudo='PUSZYSTA' UNION
    SELECT 10, REF(K) FROM KocuryO K WHERE K.pseudo='UCHO';
 
--Elita
 
INSERT INTO ElitaO
    SELECT 1, REF(K), REF(P) FROM KocuryO K LEFT JOIN PlebsO P ON P.nr_kota = 1 WHERE K.pseudo = 'TYGRYS' UNION
    SELECT 2, REF(K), REF(P) FROM KocuryO K LEFT JOIN PlebsO P ON P.nr_kota = 2 WHERE K.pseudo = 'ZOMBI' UNION
    SELECT 3, REF(K), REF(P) FROM KocuryO K LEFT JOIN PlebsO P ON P.nr_kota = 3 WHERE K.pseudo = 'LYSY' UNION
    SELECT 4, REF(K), REF(P) FROM KocuryO K LEFT JOIN PlebsO P ON P.nr_kota = 4 WHERE K.pseudo = 'RAFA';
 
INSERT INTO ElitaO VALUES (ElitaT(1, (SELECT REF(kot) FROM KocuryO kot WHERE kot.pseudo='TYGRYS'), (SELECT REF(sluga) FROM PlebsO sluga WHERE sluga.id=1)));
INSERT INTO ElitaO VALUES (ElitaT(2, (SELECT REF(kot) FROM KocuryO kot WHERE kot.pseudo='ZOMBI'), (SELECT REF(sluga) FROM PlebsO sluga WHERE sluga.id=2)));
INSERT INTO ElitaO VALUES (ElitaT(3, (SELECT REF(kot) FROM KocuryO kot WHERE kot.pseudo='LYSY'), (SELECT REF(sluga) FROM PlebsO sluga WHERE sluga.id=3)));
INSERT INTO ElitaO VALUES (ElitaT(4, (SELECT REF(kot) FROM KocuryO kot WHERE kot.pseudo='RAFA'), (SELECT REF(sluga) FROM PlebsO sluga WHERE sluga.id=4)));
 
INSERT INTO ElitaO
SELECT      ROWNUM,
            REF(k),
            REF(p)
FROM        KocuryO k
LEFT JOIN   PlebsO p ON p.nr_kota = ROWNUM
WHERE       k.calkowity_przydzial_myszy > 70;
 
INSERT INTO ElitaO
    SELECT      ROWNUM, REF(k), REF(p)
    FROM        KocuryO k
    LEFT JOIN   PlebsO p ON p.nr_kota = (8-ROWNUM)
    WHERE       w_stadku_od<'2007-01-01';
 
 
select k.calkowity_przydzial_myszy() from kocuryo k;
 
--Konto
INSERT INTO KontoO
    SELECT 1, REF(E), SYSDATE, NULL FROM ElitaO E WHERE E.nr_kota = 1 UNION
    SELECT 2, REF(E), SYSDATE, NULL FROM ElitaO E WHERE E.nr_kota = 2 UNION
    SELECT 3, REF(E), SYSDATE, NULL FROM ElitaO E WHERE E.nr_kota = 3 UNION
    SELECT 4, REF(E), SYSDATE, NULL FROM ElitaO E WHERE E.nr_kota = 4 UNION
    SELECT 5, REF(E), SYSDATE, NULL FROM ElitaO E WHERE E.nr_kota = 1 UNION
    SELECT 6, REF(E), SYSDATE, NULL FROM ElitaO E WHERE E.nr_kota = 1;
