ACCEPT id_nauczyciela PROMPT "podaj numer id nauczyciela: "
ACCEPT nazwa_przedmiotu PROMPT "podaj nazwe przedmiotu (bez numeru): "
ACCEPT id_klasy PROMPT "podaj id_klasy: "

EXECUTE pckge_nauczyciele.przydziel_godziny (in_nauczyciel => &id_nauczyciela, in_przedmiot => '&nazwa_przedmiotu', in_klasa => '&id_klasy');

@@menu.sql