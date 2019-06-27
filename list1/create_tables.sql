CREATE TABLE Funkcje
(funkcja  varchar2(10) CONSTRAINT fun_pk PRIMARY KEY,
min_myszy NUMBER(3) CONSTRAINT min_m_ch CHECK(min_myszy >5),
max_myszy NUMBER(3) CONSTRAINT max_200_ch CHECK(200>max_myszy),
CONSTRAINT ch_min_max CHECK(max_myszy>=min_myszy)
);

CREATE TABLE Wrogowie
(imie_wroga varchar2(15) constraint wro_pk PRIMARY KEY,
stopien_wrogosci NUMBER(2) CONSTRAINT stw_ch CHECK(10>=stopien_wrogosci AND stopien_wrogosci>0),
gatunek VARCHAR2(15),
lapowka VARCHAR2(20)
);

CREATE TABLE Bandy
(nr_bandy NUMBER(2) constraint nrb_pk PRIMARY KEY,
nazwa VARCHAR2(20) CONSTRAINT n_nn NOT NULL,
teren VARCHAR2(15)CONSTRAINT t_u UNIQUE,
szef_bandy VARCHAR2(15) CONSTRAINT sz_b_u UNIQUE
);

CREATE TABLE Kocury
(imie VARCHAR2(15) CONSTRAINT i_nn NOT NULL,
plec varchar2(1) CONSTRAINT plec_ch CHECK (plec IN('M','D')),
pseudo VARCHAR2(15) CONSTRAINT pseu_pk PRIMARY KEY,
funkcja VARCHAR2(10) CONSTRAINT do_fun_re
REFERENCES Funkcje(funkcja),
szef VARCHAR2(15) CONSTRAINT do_koc_re references Kocury(pseudo),
w_stadku_od DATE DEFAULT SYSDATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2) CONSTRAINT do_ban_re references Bandy(nr_bandy)
);

ALTER TABLE Bandy ADD CONSTRAINT do_bn_re foreign KEY (szef_bandy)
references Kocury(pseudo);


CREATE TABLE Wrogowie_Kocurow
(pseudo VARCHAR2(15) CONSTRAINT do_koc_ref references Kocury(pseudo),
imie_wroga VARCHAR2(15) CONSTRAINT do_wro_ref references Wrogowie(imie_wroga),
data_incydentu DATE CONSTRAINT di_nn NOT NULL,
opis_incydentu VARCHAR2(20),
CONSTRAINT wro_koc_pk PRIMARY KEY(pseudo,imie_wroga)
);

