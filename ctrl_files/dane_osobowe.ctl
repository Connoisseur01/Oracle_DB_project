load data
infile 'csv\dane_osobowe.csv'
append into table dane_osobowe
fields terminated by ','
(imie,nazwisko,numer_telefonu,email,adres_zamieszkania,data_urodzenia date "DDMMYYYY" ,pesel)
