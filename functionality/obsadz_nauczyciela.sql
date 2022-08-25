ACCEPT id_nauczyciela PROMPT "podaj id nauczyciela: "
ACCEPT nazwa_przedmiotu PROMPT "podaj nazwe przedmiotu: "
ACCEPT rozszerzenie PROMPT "czy przedmiot jest rozszerzony? [T/N] : "

DECLARE
    v_rozszerzenie BOOLEAN;
BEGIN
    IF upper('&rozszerzenie') = 'T' THEN
        v_rozszerzenie := true;
    ELSIF upper('&rozszerzenie') = 'N' THEN
        v_rozszerzenie := false;
    ELSE
        DBMS_OUTPUT.PUT_LINE('niepoprawne dane');
        RETURN;
    END IF;
    pckge_nauczyciele.obsadz_nauczyciela (in_nauczyciel => &id_nauczyciela, in_przedmiot => '&nazwa_przedmiotu', in_rozszerzenie => v_rozszerzenie);
END;
/

@@menu.sql