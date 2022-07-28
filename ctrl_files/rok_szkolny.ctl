load data
infile 'csv\rok_szkolny.csv'
append into table rok_szkolny
fields terminated by ','
TRAILING NULLCOLS
(data_rozpoczecia date "DDMMYYYY", data_zakonczenia date "DDMMYYYY")