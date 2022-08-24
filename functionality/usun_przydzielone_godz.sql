ACCEPT nazwa_przedmiotu PROMPT "podaj nazwe przedmiotu : "
ACCEPT id_klasy PROMPT "podaj id_klasy: "

EXECUTE pckge_nauczyciele.usun_przydzielone_godz (in_przedmiot => &nazwa_przedmiotu, in_klasa => &id_klasy);

@@menu.sql