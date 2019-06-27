
SET SERVEROUTPUT ON;

DECLARE
  liczba NUMBER;
  funkcjaKota Funkcje.funkcja%TYPE;
BEGIN
  SELECT COUNT(pseudo), MIN(funkcja) INTO liczba, funkcjaKota
  FROM Kocury
  WHERE funkcja = '&nazwa_funkcji';
  IF liczba > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || funkcjaKota);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota pelniacego funkcje ');
  END IF;
END;

   
      
    