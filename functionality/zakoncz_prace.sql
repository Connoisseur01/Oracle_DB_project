ACCEPT id_nauczyciela PROMPT "podaj id nauczyciela: "
ACCEPT data_zakonczenia PROMPT "podaj date zakonczenia pracy w formacie (DD-MM-RRRR): "

EXECUTE pckge_nauczyciele.zakoncz_prace (in_nauczyciel => &id_nauczyciela, in_data_zakonczenia => '&data_zakonczenia');

@@menu.sql