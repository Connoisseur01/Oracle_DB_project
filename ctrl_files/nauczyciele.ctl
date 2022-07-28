load data
infile 'csv\nauczyciele.csv'
append into table nauczyciele
fields terminated by ','
TRAILING NULLCOLS
(id_dane_osobowe,data_rozpoczecia_pracy date "DDMMYYYY", data_zakonczenia_pracy date "DDMMYYYY",max_godz_tyg)
