ACCEPT id_nauczyciela PROMPT "podaj id_nauczyciela: "
ACCEPT max_godz PROMPT "podaj nowa maxymalna liczbe godzin w tygodniu:"

EXECUTE pckge_nauczyciele.zmien_max_godz (in_nauczyciel => &id_nauczyciela, in_max_godz => &max_godz);

@@menu.sql