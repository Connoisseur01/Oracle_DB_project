LOAD DATA
INFILE 'csv\przedmioty_klasy.csv'
INSERT INTO TABLE przedmioty_klasy
FIELDS TERMINATED BY ','
(
id_klasy,
id_przedmiotu,
ilosc_godzin_przedmiotu
)