ACCEPT pesel PROMPT "podaj pesel ucznia: "

EXECUTE raporty.wypisz_oceny_ucznia(in_pesel=> &pesel);

@@menu.sql