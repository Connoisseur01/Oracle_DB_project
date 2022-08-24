ACCEPT klasa PROMPT "podaj klasę: "
ACCEPT przedmiot PROMPT "podaj przedmiot: "

EXECUTE raporty.wypisz_oceny_per_przedmiot_klasa(in_id_klasy => '&klasa', in_przedmiot => '&przedmiot');

@@menu.sql