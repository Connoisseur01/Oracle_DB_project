PROMPT podaj pesel ucznia: &&pesel
PROMPT podaj nazwe przedmiotu: &&nazwa_przedmiotu
PROMPT podaj wpisywana ocenę: &&ocena 

EXECUTE pckge_uczniowie.wpisanie_oceny(in_pesel=>&pesel,in_nazwa_przedmiotu=>'&nazwa_przedmiotu',in_ocena=>&ocena)

UNDEFINE pesel
UNDEFINE nazwa_przedmiotu
UNDEFINE ocena 