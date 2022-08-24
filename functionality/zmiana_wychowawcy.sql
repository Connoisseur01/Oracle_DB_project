PROMPT podaj klasę, dla której chcesz zmienić wychowawcę: &&klasa 
PROMPT podaj id nauczyciela, który ma być nowym wychowawcą klasy &klasa: &&id_wychowawcy 

EXECUTE pckge_nauczyciele.zmiana_wychowawcy(in_id_klasy=>'&klasa',in_id_wychowawcy=>&id_wychowawcy)

UNDEFINE klasa
UNDEFINE id_wychowawcy

@@menu.sql