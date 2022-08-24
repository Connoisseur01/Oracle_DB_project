PROMPT podaj klasę: &&klasa
PROMPT podaj przedmiot: &&przedmiot

EXECUTE raporty.wypisz_oceny_per_przedmiot_klasa(in_id_klasy=>'&klasa', in_przedmiot=>'&przedmiot')

UNDEFINE klasa
UNDEFINE przedmiot

@@menu.sql