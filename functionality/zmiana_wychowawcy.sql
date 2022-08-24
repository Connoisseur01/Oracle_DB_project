ACCEPT klasa PROMPT "podaj klase, dla ktorej chcesz zmienic wychowawce: "
ACCEPT id_wychowawcy PROMPT "podaj id nauczyciela, ktory ma byc nowym wychowawca "

EXECUTE pckge_nauczyciele.zmiana_wychowawcy(in_id_klasy => '&klasa', in_id_wychowawcy => &id_wychowawcy);

@@menu.sql