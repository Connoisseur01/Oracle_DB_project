PROMPT podaj pesel ucznia: &&pesel
PROMPT podaj literę klasy do której uczeń ma być przepisany (np. dla "1a" będzie to "a"): &&nowy_kierunek 

EXECUTE pckge_uczniowie.zmiana_kierunku(in_pesel=>&pesel,in_nowy_kierunek=>'&nowy_kierunek')

UNDEFINE pesel
UNDEFINE nowy_kierunek

@@menu.sql