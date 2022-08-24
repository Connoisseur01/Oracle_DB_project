PROMPT podaj pesel ucznia: &&pesel
PROMPT podaj datę zakończenia nauki (format dd-mm-yyyy): &&data

EXECUTE pckge_uczniowie.aktual_data_zakonczenia_uczen(in_pesel=>&pesel,in_data_zakonczenia=>'&data')

UNDEFINE pesel
UNDEFINE data