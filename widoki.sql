  --1 grupy -- wychowawca grupy , obecna klasa, rozszerzenie klasy 
--2 uczniowie -- id_ucznia na imie i nazwisko 
--3 nauczyciele -- id na imie i nazwisko 
--4 przedmioty -- id na nazwy 
--5 przedmioty klasy --||-- + może rozszerzenie 
--6  przydzielone godziny / nauczyciel przedmiot -- imie nazwisko nauczyciela + nazwa przedmiotów
-- rozszerzenie  - nie R tylko slowo albo tak albo coś 
--7  przedmiot_uczen -- jaki przedmiot , jaka klasa , jaki 

--powyżej done--

--8 .  not done -- oceny 

--1
CREATE OR REPLACE VIEW v_klasy AS
SELECT g.id_klasy "Klasa", INITCAP(k.nazwa_kierunku) "Nazwa kierunku"
, to_char(g.data_rozpoczecia, 'YYYY') || '/' || ( to_number(to_char(g.data_rozpoczecia, 'YYYY')) + 4 ) "Rocznik"
, CASE WHEN data_zakonczenia IS NULL THEN 'Aktywna'
       ELSE 'Zakonczona'  
	   END AS "Status"
,d.imie ||' ' ||d.nazwisko AS "Imie i nazwisko wychowawcy"
  FROM grupy             g
  LEFT JOIN nauczyciele  n ON n.id_nauczyciela  = g.id_wychowawcy
  LEFT JOIN dane_osobowe d ON d.id_dane_osobowe = n.id_dane_osobowe
  LEFT JOIN klasy        k ON k.id_klasy        = g.id_klasy
 ORDER BY g.data_rozpoczecia DESC, g.id_klasy;
 
 
 --2 
 
 Create or replace view v_uczniowie AS
 SELECT  u.id_ucznia "Id_ucznia", d.imie "Imię", d.nazwisko "Nazwisko"
 , data_rozpoczecia_nauki "Data rozpoczecia nauki"
 , data_zakonczenia_nauki "Data zakończenia nauki"
 , g.id_klasy "Id klasy"
 , k.nazwa_kierunku   "Kierunek",
 CASE WHEN data_zakonczenia_nauki IS NULL THEN 'Aktywny'
       ELSE 'Zakonczony'  
	   END AS "Status"
 FROM uczniowie u 
LEFT JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
LEFT JOIN grupy        g ON g.id_grupy = u.id_grupy 
LEFT JOIN klasy         k ON k.id_klasy        = g.id_klasy
 ORDER BY g.data_rozpoczecia DESC, g.id_klasy;
 
 
 --3
 CREATE OR REPLACE VIEW v_nauczyciele AS 
 SELECT id_nauczyciela, d.imie "Imię nauczyciela" , d.nazwisko "Nazwisko nauczyciela",
  CASE WHEN n.data_zakonczenia_pracy  IS NULL THEN 'Aktywny'
       ELSE 'Zakonczony'  
	   END AS "Status",
	   n.data_rozpoczecia_pracy "Data_rozpoczecia_pracy", 
       n.data_zakonczenia_pracy "Data_zakonczenia_pracy",
	   n.max_godz_tyg "Maksymalne godziny tygodniowo",
 g.id_klasy "Wychowawstwo", k.nazwa_kierunku "Kierunek klasy"
FROM nauczyciele n 
LEFT JOIN dane_osobowe d ON d.id_dane_osobowe = n.id_nauczyciela
LEFT join (SELECT * FROM grupy WHERE data_zakonczenia is null) g ON g.id_wychowawcy = n.id_nauczyciela
LEFT JOIN klasy k ON k.id_klasy = g.id_klasy
ORDER BY d.nazwisko;


-- 4. przedmioty 
CREATE OR REPLACE VIEW v_przedmioty AS 
SELECT id_przedmiotu "Id przedmiotu",
INITCAP(SUBSTR(nazwa_przedmiotu,1, LENGTH(nazwa_przedmiotu)-2)) "Przedmiot",
SUBSTR(nazwa_przedmiotu, LENGTH(nazwa_przedmiotu),1) "Uczony w klasie:", 
CASE WHEN rozszerzenie ='R' THEN 'Tak' ELSE 'Nie'
END AS "Rozszerzenie?"
FROM przedmioty; 

--5. 
CREATE OR REPLACE VIEW v_przedmioty_klasy AS
SELECT pk.id_przedmioty_klasy "Id przedmioty klasy", INITCAP(SUBSTR(nazwa_przedmiotu,1, LENGTH(nazwa_przedmiotu)-2)) "Przedmiot", 
k.id_klasy "Id_klasy", k.nazwa_kierunku "Kierunek",
CASE WHEN rozszerzenie ='R' THEN 'Tak' ELSE 'Nie'
END AS "Rozszerzenie?", pk.ilosc_godzin_przedmiotu
FROM przedmioty_klasy pk 
LEFT JOIN przedmioty p ON p.id_przedmiotu = pk.id_przedmiotu
LEFT JOIN klasy k ON k.id_klasy =pk.id_klasy
ORDER BY 1;

--6. 
CREATE OR REPLACE VIEW v_przydzielone_godziny AS
SELECT pg.id_przydzielonych_godzin "Id przydzielonych godzin", d.imie "Imie nauczyciela", d.nazwisko "Nazwisko nauczyciela" , 
INITCAP(SUBSTR(p.nazwa_przedmiotu,1, LENGTH(nazwa_przedmiotu)-2)) "Przedmiot"
, 
CASE WHEN rozszerzenie ='R' THEN 'Tak' ELSE 'Nie'
END AS "Rozszerzenie?",

k.id_klasy "Klasa",
 pg.ilosc_przydzielonych_godzin "Przydzielone godziny"
FROM przydzielone_godziny pg
LEFT JOIN nauczyciel_przedmiot np ON np.id_nauczyciel_przedmiot = pg.id_nauczyciel_przedmiot
LEFT JOIN nauczyciele n ON n.id_nauczyciela=np.id_nauczyciela
  LEFT JOIN dane_osobowe d ON d.id_dane_osobowe = n.id_nauczyciela
  
  LEFT join przedmioty_klasy pk ON pk.id_przedmioty_klasy = pg.id_przedmioty_klasy
  LEFT JOIN przedmioty p ON p.id_przedmiotu = pk.id_przedmiotu
  LEFT JOIN klasy k ON k.id_klasy = pk.id_klasy
  ORDER BY id_przydzielonych_godzin;

--7. przedmiot uczen 

CREATE OR REPLACE VIEW v_przedmioty_uczen AS
SELECT pu.id_przedmioty_uczen "Id przedmioty uczen", d.imie "Imie ucznia", d.nazwisko "Nazwisko ucznia", 
INITCAP(SUBSTR(p.nazwa_przedmiotu,1, LENGTH(nazwa_przedmiotu)-2)) "Przedmiot",
CASE WHEN rozszerzenie ='R' THEN 'Tak' ELSE 'Nie'
END AS "Rozszerzenie?", SUBSTR(p.nazwa_przedmiotu, LENGTH(nazwa_przedmiotu),1) "Uczony w klasie:",
Case WHEN SUBSTR(g.id_klasy,1,1) = SUBSTR(p.nazwa_przedmiotu, LENGTH(nazwa_przedmiotu),1) THEN 'Tak' ELSE 'Nie' END AS "W obecnej klasie:"
FROM przedmioty_uczen pu
LEFT JOIN uczniowie u ON u.id_ucznia = pu.id_ucznia
LEFT JOIN dane_osobowe d ON d.id_dane_osobowe  = u. id_dane_osobowe
LEFT JOIN przedmioty p ON p.id_przedmiotu = pu.id_przedmiotu 
LEFT JOIN grupy g ON g.id_grupy = u.id_grupy;

-- oceny

CREATE OR REPLACE VIEW v_oceny AS
SELECT imie "imie ucznia", nazwisko "nazwisko ucznia",id_klasy "klasa", SUBSTR(nazwa_przedmiotu, 1, LENGTH(nazwa_przedmiotu) - 2) "przedmiot",
CASE WHEN rozszerzenie = 'R' THEN 'rozszerzenie' ELSE 'podstawa' END as "Rozszerzenie?", ocena, to_char(timestamp_oceny, 'DD-MM-RRRR hh24:mi') "data wystawienia"
FROM oceny
JOIN przedmioty_uczen USING (id_przedmioty_uczen)
JOIN przedmioty USING (id_przedmiotu)
JOIN uczniowie USING (id_ucznia)
JOIN dane_osobowe USING (id_dane_osobowe)
JOIN grupy USING (id_grupy)
ORDER BY id_klasy ASC, nazwisko ASC, imie ASC,nazwa_przedmiotu ASC, timestamp_oceny DESC;

