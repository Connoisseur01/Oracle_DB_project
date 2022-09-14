ACCEPT nazwa_przedmiotu PROMPT "podaj nazwe przedmiotu: "
ACCEPT klasa PROMPT "podaj klase: "

EXECUTE raporty.pokaz_wolnych_nauczycieli (in_przedmiot => &nazwa_przedmiotu, in_klasa => &klasa);

@@menu.sql