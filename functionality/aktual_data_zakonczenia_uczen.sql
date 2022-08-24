ACCEPT pesel PROMPT "podaj pesel ucznia: "
ACCEPT data PROMPT "podaj date zakonczenia nauki (format DD-MM-RRRR): "

EXECUTE pckge_uczniowie.aktual_data_zakonczenia_uczen(in_pesel => &pesel, in_data_zakonczenia => '&data');

@@menu.sql