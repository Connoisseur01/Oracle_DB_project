ACCEPT pesel PROMPT "podaj pesel ucznia: "
ACCEPT nazwa_przedmiotu PROMPT "podaj nazwe przedmiotu: "
ACCEPT ocena PROMPT "podaj wpisywana ocene(oceny calkowite): "

EXECUTE pckge_uczniowie.wpisanie_oceny_koncowej(in_pesel => &pesel, in_nazwa_przedmiotu => '&nazwa_przedmiotu', in_ocena => &ocena);

@@menu.sql