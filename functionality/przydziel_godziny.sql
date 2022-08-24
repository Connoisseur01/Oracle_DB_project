PROMPT podaj numer id nauczyciela:
DEFINE id_nauczyciela = &id_nauczyciela
PROMPT podaj nazwe przedmiotu (bez numeru):
DEFINE nazwa_przedmiotu = '&przedmiot'
PROMPT podaj id_klasy:
DEFINE id_klasy = '&klasa'

EXECUTE przydziel_godziny (in_nauczyciel => &id_nauczyciela, in_przedmiot => '&nazwa_przedmiotu', in_klasa => '&id_klasy')

UNDEFINE id_nauczyciela
UNDEFINE nazwa_przedmiotu
UNDEFINE id_klasy