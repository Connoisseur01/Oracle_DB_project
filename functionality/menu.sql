PROMPT ********************** nauczyciele **********************
PROMPT [1] obsadz nauczyciela
PROMPT [2] przydziel godziny nauczycielowi
PROMPT [3] usun przedmiot z listy nauczanych przez nauczyciela
PROMPT [4] usun przydzielone godziny nauczyciela
PROMPT [5] zakoncz prace nauczyciela
PROMPT [6] zmien maksymalna ilosc godzin pracy nauczyciela w tygodniu
PROMPT *********************************************************
PROMPT [7] wyjdz
ACCEPT opcja PROMPT "wybierz opcje: "

COLUMN script NEW_VALUE v_script

SELECT CASE '&opcja'
       WHEN '1' THEN 'obsadz_nauczyciela.sql'
       WHEN '2' THEN 'przydziel_godziny.sql'
       WHEN '3' THEN 'usun_przedmiot_nauczyciela.sql'
       WHEN '4' THEN 'usun_przydzielone_godz.sql'
       WHEN '5' THEN 'zakoncz_prace.sql'
       WHEN '6' THEN 'zmien_max_godz.sql'
       WHEN '7' THEN RETURN;
       else 'menu.sql'
       END AS script
FROM dual;

@@&v_script
