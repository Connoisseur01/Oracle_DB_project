ACCEPT pesel PROMPT "podaj pesel osoby ktorej dane aktualizujesz: "
ACCEPT kolumna PROMPT "nazwa zmienianej kolumny: "
ACCEPT aktualizacja PROMPT "nowe dane: "

EXECUTE aktual_dane_osob (in_pesel => &pesel, in_kolumna => &kolumna, in_aktualizacja => &aktualizacja);

@@menu.sql