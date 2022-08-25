ACCEPT imie PROMPT "podaj imie: "
ACCEPT nazwisko PROMPT "podaj nazwisko: "
ACCEPT numer PROMPT "podaj numer telefonu: "
ACCEPT email PROMPT "podaj email: "
ACCEPT adres PROMPT "podaj adres zamiezkania: "
ACCEPT data PROMPT "podaj date urodzenia: "
ACCEPT pesel PROMPT "podaj numer pesel: "
ACCEPT rola PROMPT "podaj role ('u' -> uczen, 'n' -> nauczyciel, 'k' -> kandydat): "

EXECUTE dodaj_osobe 
    (     in_imie            => &imie
        , in_nazwisko        => &nazwisko
        , in_numer_telefonu  => &numer
        , in_email           => &email
        , in_adres           => &adres
        , in_data_urodzenia  => &data
        , in_pesel           => &pesel
        , in_rola            => &rola
    ); 

@@menu.sql