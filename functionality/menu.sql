PROMPT ********************** nauczyciele **********************
PROMPT [1]  obsadz nauczyciela
PROMPT [2]  przydziel godziny nauczycielowi
PROMPT [3]  usun przedmiot z listy nauczanych przez nauczyciela
PROMPT [4]  usun przydzielone godziny nauczyciela
PROMPT [5]  zakoncz prace nauczyciela
PROMPT [6]  zmien maksymalna ilosc godzin pracy nauczyciela w tygodniu
PROMPT [7]  zmien wychowawce
PROMPT **********************  uczniowie  **********************
PROMPT [8]  aktualizuj date zakonczenia nauki
PROMPT [9]  wpisz ocene koncowa
PROMPT [10] wpisz ocene
PROMPT [11] zmiana kierunku
PROMPT **********************   raporty   **********************
PROMPT [12] wypisz oceny per przedmiot_klasa
PROMPT [13] wypisz oceny ucznia
PROMPT [14] wyswietl klasy
PROMPT *********************************************************
PROMPT [15] wyjdz
ACCEPT opcja PROMPT "wybierz opcje: "

COLUMN script NEW_VALUE v_script

SELECT CASE '&opcja'
       WHEN '1'  THEN 'obsadz_nauczyciela.sql'
       WHEN '2'  THEN 'przydziel_godziny.sql'
       WHEN '3'  THEN 'usun_przedmiot_nauczyciela.sql'
       WHEN '4'  THEN 'usun_przydzielone_godz.sql'
       WHEN '5'  THEN 'zakoncz_prace.sql'
       WHEN '6'  THEN 'zmien_max_godz.sql'
       WHEN '7'  THEN 'zmiana_wychowawcy.sql'
       WHEN '8'  THEN 'aktual_data_zakonczenia_uczen.sql'
       WHEN '9'  THEN 'wpisanie_oceny_koncowej.sql'
       WHEN '10' THEN 'wpisanie_oceny.sql'
       WHEN '11' THEN 'zmiana_kierunku.sql'
       WHEN '12' THEN 'wypisz_oceny_per_przedmiot_klasa.sql'
       WHEN '13' THEN 'wypisz_oceny_ucznia.sql'
       WHEN '14' THEN 'wyswietl_klasy.sql'
       WHEN '15' THEN RETURN;
       ELSE 'menu.sql'
       END AS script
FROM dual;

@@&v_script
