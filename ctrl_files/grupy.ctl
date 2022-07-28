load data
infile 'csv\grupy.csv'
append into table grupy
fields terminated by ','
trailing nullcols
(id_klasy, data_rozpoczecia date "DDMMYYYY", data_zakonczenia date "DDMMYYYY", id_wychowawcy)
