ACCEPT pesel PROMPT "podaj pesel ucznia: "
ACCEPT nazwa_przedmiotu "podaj nazwe przedmiotu: "
ACCEPT ocena podaj "wpisywana ocene: "

EXECUTE pckge_uczniowie.wpisanie_oceny(in_pesel => &pesel, in_nazwa_przedmiotu => '&nazwa_przedmiotu', in_ocena => &ocena);

@@menu.sql