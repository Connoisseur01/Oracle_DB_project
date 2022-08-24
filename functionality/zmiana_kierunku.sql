ACCEPT pesel PROMPT "podaj pesel ucznia: "
ACCEPT nowy_kierunek PROMPT "podaj literę klasy do której uczeń ma być przepisany (np. dla '1a' będzie to 'a'): "

EXECUTE pckge_uczniowie.zmiana_kierunku(in_pesel=>&pesel,in_nowy_kierunek=>'&nowy_kierunek');

@@menu.sql