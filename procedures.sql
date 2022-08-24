-- pakiet do populacji tablic

CREATE OR REPLACE PACKAGE populate AS
    PROCEDURE pop_przedmioty;
    PROCEDURE pop_klasy;
    PROCEDURE pop_uczniowie;
    PROCEDURE obsadz_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN);
    PROCEDURE przydziel_godz (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_klasa VARCHAR2);
    PROCEDURE pop_przedmiot_uczen;
    PROCEDURE pop_oceny;
    PROCEDURE pop_srednia_ocen;
    PROCEDURE pop_ocena_koncowa;
END populate;
/
CREATE OR REPLACE PACKAGE BODY populate AS

    PROCEDURE pop_przedmioty IS
            TYPE tabela_przedmiotow IS TABLE OF VARCHAR2(30);
    
            przedmioty tabela_przedmiotow :=
            tabela_przedmiotow('matematyka', 'polski', 'angielski', 'historia', 'niemiecki',
            'geografia', 'wychowanie_fizyczne', 'biologia', 'chemia', 'fizyka', 'informatyka');
            
            przedmiot VARCHAR2(30);
        BEGIN
            FOR i IN przedmioty.FIRST .. przedmioty.LAST LOOP
                FOR k IN 1 .. 4 LOOP
                    przedmiot := przedmioty(i) || '_' || k;
                    
					EXECUTE IMMEDIATE
                    'INSERT INTO przedmioty (nazwa_przedmiotu)
                        VALUES (:przedmiot)'
						USING IN przedmiot;
                    
                    INSERT INTO przedmioty (nazwa_przedmiotu, rozszerzenie)
                        VALUES             (przedmiot       , 'R');
                END LOOP;
            END LOOP;
        END;
    
    PROCEDURE pop_klasy IS 
            TYPE tabela_klas IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(1);
    
            klasy tabela_klas :=
            tabela_klas('a' => 'mat-fiz', 
                        'b' => 'biol-chem', 
                        'c' => 'ekonomiczna', 
                        'd' => 'humanistyczna');
            v_klasa VARCHAR2(2);
        BEGIN 
            FOR i IN ASCII('a') .. ASCII('d') LOOP
                FOR k IN 1 .. 4 LOOP
                    v_klasa := k || CHR(i);
                    
                    INSERT INTO klasy (id_klasy, nazwa_kierunku)
                        VALUES        (v_klasa   , klasy(CHR(i)));
                END LOOP;
            END LOOP;
        END;

    PROCEDURE pop_uczniowie IS
            v_data_rozpoczecia DATE;
            v_data_zakonczenia DATE;
        BEGIN
            FOR j IN 1..36 LOOP
                FOR i IN 1..10 LOOP
                    SELECT data_rozpoczecia   , data_zakonczenia 
					INTO   v_data_rozpoczecia , v_data_zakonczenia
                    FROM grupy
                    WHERE id_grupy = j;
					

                    INSERT INTO uczniowie (id_dane_osobowe     , data_rozpoczecia_nauki , data_zakonczenia_nauki , id_grupy)
                        VALUES             (i + ( j - 1 ) * 10  , v_data_rozpoczecia    , v_data_zakonczenia    , j);


                END LOOP;
            END LOOP;
        END;

    PROCEDURE obsadz_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN) IS 
            v_nazwa varchar2(30);
            v_id INTEGER;
        BEGIN
            FOR i IN 1 .. 4 LOOP
                v_nazwa := in_przedmiot || '_' || i;
                SELECT id_przedmiotu INTO v_id 
				FROM przedmioty 
				WHERE nazwa_przedmiotu = v_nazwa AND rozszerzenie IS NULL;
                INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                  VALUES                         (in_nauczyciel    , v_id);
            END LOOP;
            
            IF in_rozszerzenie THEN
                FOR i IN 1 .. 4 LOOP
                    v_nazwa := in_przedmiot || '_' || i;
                    SELECT id_przedmiotu INTO v_id 
					FROM przedmioty 
					WHERE nazwa_przedmiotu = v_nazwa AND rozszerzenie IS NOT NULL;
                    INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                      VALUES                         (in_nauczyciel    , v_id);
                END LOOP;
            END IF;
        END;

    PROCEDURE przydziel_godz (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_klasa VARCHAR2) IS 
            id_naucz_przed INTEGER;
            id_przed_klasa INTEGER;
            ilosc_godzin   INTEGER;

            v_klasa          INTEGER := SUBSTR(in_klasa, 0, 1);
            v_id_przed       INTEGER;
        BEGIN

            SELECT id_przedmioty_klasy, ilosc_godzin_przedmiotu, id_przedmiotu 
			INTO   id_przed_klasa     , ilosc_godzin           , v_id_przed
            FROM przedmioty_klasy
            WHERE id_klasy = in_klasa AND id_przedmiotu IN (SELECT id_przedmiotu
                                                        FROM przedmioty
                                                        WHERE nazwa_przedmiotu LIKE in_przedmiot || '_' || v_klasa);

            SELECT id_nauczyciel_przedmiot INTO id_naucz_przed
            FROM nauczyciel_przedmiot
            WHERE id_nauczyciela = in_nauczyciel AND id_przedmiotu = v_id_przed;

            INSERT INTO przydzielone_godziny (id_nauczyciel_przedmiot, id_przedmioty_klasy, ilosc_przydzielonych_godzin)
                VALUES                       (id_naucz_przed         , id_przed_klasa     , ilosc_godzin);
        END;
    
    PROCEDURE pop_przedmiot_uczen IS 
            c1 SYS_REFCURSOR;

            id_uczen     INTEGER;
            id_przedmiot INTEGER;
            id_klasy     CHAR(2); 

            v_polecenie VARCHAR2(500) := ' as stala,   p.id_przedmiotu 
                                        FROM przedmioty_klasy pk
                                        RIGHT JOIN przedmioty p     ON p.id_przedmiotu = pk.id_przedmiotu
                                        WHERE id_klasy ';
            vsql        VARCHAR2(2000);
        BEGIN

            FOR i IN 1..360 LOOP
                
			    SELECT id_klasy INTO id_klasy 
                FROM grupy  
                JOIN uczniowie USING (id_grupy)
                WHERE id_dane_osobowe = i;


                IF LPAD(id_klasy,1)=1 THEN
                vsql := 'SELECT ' ||i ||v_polecenie|| '= ''' || id_klasy || '''  ';

                ELSIF LPAD(id_klasy,1)=2 THEN 
                vsql := 'SELECT ' || i ||v_polecenie|| 'in  (''' || id_klasy || ''', ''' ||
                                    to_char(TO_NUMBER(SUBSTR(id_klasy,1,1))-1 || SUBSTR(id_klasy,2,1)) || ''') '; 

                ELSIF LPAD(id_klasy,1)=3 THEN
                vsql := 'SELECT ' || i ||v_polecenie|| 'in  (''' || id_klasy || ''', ''' ||
                                    TO_CHAR(TO_NUMBER(SUBSTR(id_klasy,1,1))-1 || SUBSTR(id_klasy,2,1)) || ''', ''' ||
                                    TO_CHAR(TO_NUMBER(SUBSTR(id_klasy,1,1))-2 || SUBSTR(id_klasy,2,1)) || ''') '; 

                ELSIF LPAD(id_klasy,1)=4 THEN
                vsql := 'SELECT ' || i ||v_polecenie|| 'in  (''' || id_klasy || ''', ''' ||
                                    TO_CHAR(TO_NUMBER(SUBSTR(id_klasy,1,1))-1 || SUBSTR(id_klasy,2,1)) || ''',''' ||
                                    TO_CHAR(to_number(SUBSTR(id_klasy,1,1))-2 || SUBSTR(id_klasy,2,1)) || ''',''' ||
                                    TO_CHAR(to_number(SUBSTR(id_klasy,1,1))-3 || SUBSTR(id_klasy,2,1)) ||  ''') '; 

                END IF;    
                OPEN c1 FOR vsql; 

                LOOP
                    FETCH c1 INTO
                        id_uczen, id_przedmiot;
                    EXIT WHEN c1%notfound;
                    
					INSERT INTO przedmioty_uczen (id_ucznia, id_przedmiotu) 
                    VALUES (id_uczen, id_przedmiot);

                END LOOP;

                CLOSE c1;
            END LOOP;
        END;


    PROCEDURE pop_oceny IS 
            v_rok_przedmiot      INTEGER;
            v_ostatnia_klasa     INTEGER;
            v_rozpoczecie_nauki  DATE; 

            v_data_rozpoczecia   DATE;
            v_data_zakonczenia   DATE;

        BEGIN
        dbms_random.seed(11);
            FOR i IN 1..10050 LOOP
			    
				SELECT  to_number(substr(p.nazwa_przedmiotu, - 1, 1))   , to_number(substr(g.id_klasy, 1, 1))   , g.data_rozpoczecia
                INTO    v_rok_przedmiot                                 , v_ostatnia_klasa                      , v_rozpoczecie_nauki 
                FROM przedmioty_uczen   p_u
                LEFT JOIN przedmioty    p   ON p.id_przedmiotu = p_u.id_przedmiotu
                LEFT JOIN uczniowie     u   ON u.id_ucznia     = p_u.id_ucznia
                LEFT JOIN grupy         g   ON g.id_grupy      = u.id_grupy
                WHERE p_u.id_przedmioty_uczen = i;
				
                FOR n IN 1..4 LOOP
                    IF v_rok_przedmiot = n THEN
					    SELECT  data_rozpoczecia    , data_zakonczenia 
                        INTO    v_data_rozpoczecia  , v_data_zakonczenia
                        FROM rok_szkolny
                        WHERE id_rs = (SELECT id_rs + n - 1 
                                        FROM rok_szkolny
                                        WHERE data_rozpoczecia = v_rozpoczecie_nauki);
						
                        FOR j IN 1..5 LOOP
                            INSERT INTO oceny   (id_przedmioty_uczen, ocena, timestamp_oceny) 
                                VALUES          (
                                    i,
                                    round(dbms_random.value(2, 12)) / 2,
                                    (to_date(v_data_rozpoczecia, 'DD/MM/YY HH24:MI:SS') 
                                    + dbms_random.value(0, to_date(v_data_zakonczenia, 'DD/MM/YY HH24:MI:SS') 
                                    - to_date(v_data_rozpoczecia, 'DD/MM/YY HH24:MI:SS')))
                                    );
                        END LOOP;
                    END IF;
                END LOOP;
            END LOOP;
        END;
     
     
    PROCEDURE pop_srednia_ocen IS
        BEGIN
            UPDATE przedmioty_uczen pu
                SET
                srednia_ocen = ( SELECT AVG(ocena)
                                 FROM oceny o
                                 WHERE o.id_przedmioty_uczen = pu.id_przedmioty_uczen );
        END;
        
     
     PROCEDURE pop_ocena_koncowa IS
         BEGIN
            UPDATE przedmioty_uczen pu
                SET
                ocena_koncowa = ( SELECT AVG(ocena)
                                 FROM oceny o
                                 WHERE o.id_przedmioty_uczen = pu.id_przedmioty_uczen );
        END;
        
        
END populate;
/

--przed koncem roku szkolnego



--wpisanie oceny jednostkowej 

CREATE OR REPLACE PACKAGE pckge_uczniowie AS

    PROCEDURE wpisanie_oceny (in_pesel INTEGER, in_nazwa_przedmiotu VARCHAR2, in_ocena INTEGER);
    PROCEDURE wpisanie_oceny_koncowej (in_pesel INTEGER, in_nazwa_przedmiotu VARCHAR2, in_ocena INTEGER);
    PROCEDURE aktual_data_zakonczenia_uczen (in_pesel INTEGER, in_data_zakonczenia DATE);
    PROCEDURE zmiana_kierunku (in_pesel INTEGER, in_nowy_kierunek VARCHAR2);

END pckge_uczniowie;
/

CREATE OR REPLACE PACKAGE BODY pckge_uczniowie AS

    PROCEDURE wpisanie_oceny (in_pesel INTEGER, in_nazwa_przedmiotu VARCHAR2, in_ocena INTEGER) IS
            check_data_zakonczenia  DATE;
            check_pesel             INTEGER;
            check_przedmiot         przedmioty.nazwa_przedmiotu%TYPE;
            v_id_przedmioty_uczen   INTEGER;
        BEGIN
            IF in_ocena NOT IN ( 1, 1.5, 2, 2.5, 3, 3.5 , 4, 4.5 , 5, 5.5, 6 ) THEN
                DBMS_OUTPUT.PUT_LINE('Prosze wpisac ocene w skali 1-6 (z polowkami).');
                RETURN;
            END IF;

            BEGIN
                EXECUTE IMMEDIATE
                'SELECT  d.pesel         , u.data_zakonczenia_nauki
                FROM uczniowie    u
                JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
                JOIN grupy        g ON g.id_grupy        = u.id_grupy
                WHERE pesel = ' ||in_pesel||' 
                AND rola LIKE ''%u%'' '
                INTO    check_pesel     , check_data_zakonczenia;

            EXCEPTION
                WHEN no_data_found THEN
                    dbms_output.put_line('Brak ucznia o takim peselu w bazie. ');
                    RETURN;
            END;

            IF check_data_zakonczenia IS NOT NULL THEN
                dbms_output.put_line('Uczeń już nie uczy się w szkole. ');
                RETURN;
            END IF;
            
            BEGIN
                EXECUTE IMMEDIATE
                'SELECT     nazwa_przedmiotu    , id_przedmioty_uczen
                FROM uczniowie u
                JOIN dane_osobowe          d  ON d.id_dane_osobowe = u.id_dane_osobowe
                JOIN grupy                 g  ON g.id_grupy        = u.id_grupy
                LEFT JOIN przedmioty_uczen pu ON pu.id_ucznia      = u.id_ucznia
                JOIN przedmioty            p  ON p.id_przedmiotu   = pu.id_przedmiotu
                WHERE substr(nazwa_przedmiotu, length(nazwa_przedmiotu), 1) = substr(g.id_klasy, 1, 1)
                AND pesel = ' ||in_pesel||'
                AND rola LIKE ''%u%''
                AND nazwa_przedmiotu = ( lower('''||in_nazwa_przedmiotu||''') || ''_'' || substr(g.id_klasy, 1, 1) )' -- Å¼eby nie musiec wpisywac numerka w nazwie
                INTO        check_przedmiot     , v_id_przedmioty_uczen;

            EXCEPTION
                WHEN no_data_found THEN
                    dbms_output.put_line('Niepoprawna nazwa przedmiotu. ');
                    RETURN;
            END;

        INSERT INTO oceny (id_przedmioty_uczen    ,ocena     ,timestamp_oceny)
               VALUES     (v_id_przedmioty_uczen  ,in_ocena  ,systimestamp   );
            
            DBMS_OUTPUT.PUT_LINE('Uczniowi o peselu: '|| in_pesel || ' wpisano ocenę: '|| in_ocena|| ' z przedmiotu: '|| in_nazwa_przedmiotu);

        EXECUTE IMMEDIATE
            'UPDATE przedmioty_uczen
            SET
                srednia_ocen = ( SELECT AVG(ocena)
                                FROM oceny 
                                WHERE id_przedmioty_uczen = '||v_id_przedmioty_uczen|| ')
                    WHERE id_przedmioty_uczen = '||v_id_przedmioty_uczen ;  
        END;


    PROCEDURE wpisanie_oceny_koncowej (in_pesel INTEGER, in_nazwa_przedmiotu VARCHAR2, in_ocena INTEGER) IS
            check_data_zakonczenia  DATE;
            check_pesel             INTEGER;
            check_przedmiot         przedmioty.nazwa_przedmiotu%TYPE;
            v_id_przedmioty_uczen   INTEGER;
        BEGIN
            IF in_ocena NOT IN ( 1, 2, 3, 4, 5, 6 ) THEN
                dbms_output.put_line('Prosze wpisac pelna ocene w skali 1-6.');
                RETURN;
            END IF;

            BEGIN
                EXECUTE IMMEDIATE
                'SELECT  d.pesel         , u.data_zakonczenia_nauki
                FROM uczniowie    u
                JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
                JOIN grupy        g ON g.id_grupy        = u.id_grupy
                WHERE pesel = ' ||in_pesel||' 
                AND rola LIKE ''%u%'' '
                INTO    check_pesel     , check_data_zakonczenia;

            EXCEPTION
                WHEN no_data_found THEN
                    dbms_output.put_line('Brak ucznia o takim peselu w bazie. ');
                    RETURN;
            END;

            IF check_data_zakonczenia IS NOT NULL THEN
                dbms_output.put_line('Uczeń już nie uczy się w danej szkole. ');
                RETURN;
            END IF;
            
            BEGIN
                EXECUTE IMMEDIATE
                'SELECT  nazwa_przedmiotu    , id_przedmioty_uczen           
                FROM uczniowie u
                JOIN dane_osobowe           d  ON d.id_dane_osobowe = u.id_dane_osobowe
                JOIN grupy                  g  ON g.id_grupy        = u.id_grupy
                LEFT JOIN przedmioty_uczen  pu ON pu.id_ucznia      = u.id_ucznia
                JOIN przedmioty             p  ON p.id_przedmiotu   = pu.id_przedmiotu
                WHERE substr(nazwa_przedmiotu, length(nazwa_przedmiotu), 1) = substr(g.id_klasy, 1, 1)
                AND pesel = in_pesel
                AND rola LIKE ''%u%''
                AND nazwa_przedmiotu = ( lower('||in_nazwa_przedmiotu||')||''_''|| substr(g.id_klasy, 1, 1) )' -- Å¼eby nie musiec wpisywac numerka w nazwie
                INTO  check_przedmiot     , v_id_przedmioty_uczen;
                
            EXCEPTION
                WHEN no_data_found THEN
                    dbms_output.put_line('Niepoprawna nazwa przedmiotu. ');
                    RETURN;
            END;

            EXECUTE IMMEDIATE 'UPDATE przedmioty_uczen
                                SET ocena_koncowa = ' || in_ocena || ' 
                                WHERE id_przedmioty_uczen = ' || v_id_przedmioty_uczen;
        END;



    PROCEDURE aktual_data_zakonczenia_uczen (in_pesel INTEGER, in_data_zakonczenia DATE) IS
            check_data_rozpoczecia  DATE;
            check_data_zakonczenia  DATE;
            check_pesel             INTEGER;
        BEGIN
            BEGIN
                EXECUTE IMMEDIATE
                'SELECT  d.pesel     , u.data_rozpoczecia_nauki  , u.data_zakonczenia_nauki             
                FROM uczniowie    u
                JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
                WHERE pesel = '||in_pesel||' AND rola like ''%u%'''
                INTO    check_pesel , check_data_rozpoczecia    , check_data_zakonczenia;

            EXCEPTION
                WHEN no_data_found 
                THEN dbms_output.put_line('Brak ucznia o takim peselu. ');
                    RETURN;
            END;

            IF check_data_zakonczenia IS NOT NULL 
                THEN dbms_output.put_line('Uczeń już nie uczy się w danej szkole. ');
                RETURN;
            ELSIF check_data_rozpoczecia > in_data_zakonczenia 
            THEN dbms_output.put_line('Data zakonczenia nie moze być wcześniejsza niż data rozpoczęcia nauki. Prosze wpisac poprawna datę.');
                RETURN;
            END IF;

            EXECUTE IMMEDIATE 
            'UPDATE uczniowie
            SET data_zakonczenia_nauki = :in_data_zakonczenia
            WHERE id_dane_osobowe = (SELECT id_dane_osobowe 
                                    FROM dane_osobowe 
                                    WHERE pesel = '||in_pesel||')'
            USING IN in_data_zakonczenia, in_pesel;
            
            dbms_output.put_line('Uczniowi o peselu: ' || in_pesel || ' wpisano datę zakończenia nauki: ' || in_data_zakonczenia || '.');
        END;

    PROCEDURE zmiana_kierunku (in_pesel INTEGER, in_nowy_kierunek VARCHAR2) IS
            check_data_zakonczenia  DATE;
            check_pesel             INTEGER;
            
            v_stara_klasa           VARCHAR2(2); 
            v_id_ucznia             INTEGER;
            v_nowa_klasa            VARCHAR2(2); 
            v_id_przedmiotu         INTEGER; 
                    
            out_nowa_grupa          INTEGER;
                
            c1                      SYS_REFCURSOR; 
            
        BEGIN
            BEGIN
                EXECUTE IMMEDIATE
                'SELECT  u.id_ucznia,  d.pesel     , u.data_zakonczenia_nauki   , g.id_klasy
                FROM uczniowie    u
                JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
                JOIN grupy        g ON g.id_grupy = u.id_grupy
                WHERE pesel = '||in_pesel||' AND rola like ''%u%'''
                INTO    v_id_ucznia,  check_pesel  , check_data_zakonczenia    , v_stara_klasa;

            EXCEPTION
                WHEN no_data_found 
                THEN dbms_output.put_line('Brak ucznia o takim peselu. ');
                    RETURN;
            END;

            IF check_data_zakonczenia IS NOT NULL 
                THEN dbms_output.put_line('Uczeń już nie uczy się w danej szkole. ');
                RETURN;
                
            ELSIF lower(substr(v_stara_klasa,2,1)) = lower(in_nowy_kierunek)
            THEN dbms_output.put_line('Nowy kierunek nie może być taki sam jak wcześniejszy. Prosze wpisac poprawny nowy kierunek. ');
                RETURN;
            END IF;

            EXECUTE IMMEDIATE
            'SELECT g.id_grupy    , g.id_klasy 
            FROM grupy g
            JOIN klasy k on  g.id_klasy = k.id_klasy 
            WHERE k.id_klasy like lower(substr('''||v_stara_klasa||''',1,1))||lower('''||in_nowy_kierunek||''')'
            INTO    out_nowa_grupa, v_nowa_klasa; 

            EXECUTE IMMEDIATE 'UPDATE uczniowie
                                SET id_grupy = '||out_nowa_grupa||
                                'WHERE id_dane_osobowe = (SELECT id_dane_osobowe 
                                                            FROM dane_osobowe 
                                                            WHERE pesel = ' || in_pesel || ')';
                                
            dbms_output.put_line('Uczniowi o peselu: ' || in_pesel || ' zmieniono klase z : ' || v_stara_klasa || ' na '||substr(v_stara_klasa,1,1)||lower(in_nowy_kierunek));

            OPEN c1 FOR 'SELECT ' || v_id_ucznia || ',   p.id_przedmiotu 
                                            FROM przedmioty_klasy pk
                                            RIGHT JOIN przedmioty p     ON p.id_przedmiotu = pk.id_przedmiotu
                                            WHERE id_klasy = '''||v_nowa_klasa||'''  ';
            LOOP
                FETCH c1 INTO v_id_ucznia, v_id_przedmiotu;
                EXIT WHEN c1%notfound;
                
                INSERT  INTO przedmioty_uczen ( id_ucznia   , id_przedmiotu     ) 
                        VALUES                ( v_id_ucznia , v_id_przedmiotu   );
            END LOOP;
            CLOSE c1;

        END;

END pckge_uczniowie;
/

CREATE OR REPLACE PACKAGE po_koncu_roku AS  
PROCEDURE dodaj_date_zakonczenia_grup;
PROCEDURE dodaj_rok_szkolny;
PROCEDURE zdanie;
PROCEDURE nowy_rocznik (in_ile_klas INTEGER);
PROCEDURE niezdanie;
PROCEDURE wpisanie_nowych_przedmiotow_grupa;
END po_koncu_roku;
/
CREATE OR REPLACE PACKAGE BODY po_koncu_roku AS

    PROCEDURE dodaj_date_zakonczenia_grup IS
        c1 SYS_REFCURSOR;
        c2 SYS_REFCURSOR;
        
        v_data_zakonczenia  DATE;
        v_id_grupy          INTEGER;
        v_id_ucznia         INTEGER;
    BEGIN
        SELECT MAX(data_zakonczenia) INTO v_data_zakonczenia
        FROM rok_szkolny;

        OPEN c1 FOR 'SELECT id_grupy
                    FROM grupy 
                    WHERE id_klasy like ''4%''
                    AND data_zakonczenia is null';

        LOOP        
            FETCH c1 INTO v_id_grupy;
            EXIT WHEN c1%notfound;
            UPDATE grupy
            SET data_zakonczenia= v_data_zakonczenia 
            WHERE id_grupy = v_id_grupy;
                
            OPEN c2 FOR 'SELECT id_ucznia FROM uczniowie u
                        WHERE id_grupy = ' || v_id_grupy || ' AND data_zakonczenia_nauki is null
                        MINUS
                        SELECT u.id_ucznia FROM uczniowie u 
                        LEFT JOIN przedmioty_uczen pu on pu.id_ucznia = u.id_ucznia
                        WHERE id_grupy = ' || v_id_grupy || ' AND data_zakonczenia_nauki is null
                        AND pu.ocena_koncowa =1 '; -- lista uczniÃ³w dla grup ktore powinny konczyc minus lista uczniow ktorzy maja  1. 
            LOOP
                FETCH c2 INTO v_id_ucznia;
                EXIT WHEN c2%notfound;
                
                UPDATE uczniowie
                SET data_zakonczenia_nauki = v_data_zakonczenia
                WHERE id_ucznia = v_id_ucznia;

            END LOOP;

            CLOSE c2;
        END LOOP;

        CLOSE c1;
        dbms_output.put_line('Wpisano datę zakończenia dla klas 4: '||v_data_zakonczenia);
    END;

    PROCEDURE dodaj_rok_szkolny 
    IS
        v_original_terr         VARCHAR2(200);
        out_data_rozpoczecia    DATE;
        out_data_zakonczenia    DATE;
    BEGIN
        v_original_terr := sys_context('USERENV', 'NLS_TERRITORY');
        
        EXECUTE IMMEDIATE 
        'ALTER SESSION 
        SET NLS_territory= ''Poland'' ';
        
        SELECT trunc(MAX(data_rozpoczecia) + 366, 'mm')
          INTO out_data_rozpoczecia
          FROM rok_szkolny;

        IF      to_char(out_data_rozpoczecia, 'd') = 6 THEN out_data_rozpoczecia := out_data_rozpoczecia + 2;
        ELSIF   to_char(out_data_rozpoczecia, 'd') = 7 THEN out_data_rozpoczecia := out_data_rozpoczecia + 1;
        END IF;

        out_data_zakonczenia := to_date('3006' || to_char(out_data_rozpoczecia, 'yyyy') + 1, 'ddmmyyyy');
        out_data_zakonczenia := out_data_zakonczenia - to_char(out_data_zakonczenia, 'd') + 5;
         
        INSERT INTO rok_szkolny    (data_rozpoczecia       , data_zakonczenia)
                    values          (out_data_rozpoczecia  , out_data_zakonczenia);
            
        dbms_output.put_line('Wpisano rok zaczynajacy się: ' || out_data_rozpoczecia || ' oraz kończacy sie: ' || out_data_zakonczenia);
         
        EXECUTE IMMEDIATE 
        'ALTER SESSION 
        SET NLS_territory='''|| v_original_terr ||'''';
    END;

PROCEDURE zdanie 
IS
        CURSOR c1 IS
        SELECT id_grupy
          FROM grupy
         WHERE data_zakonczenia IS NULL;

        v_id_klasy VARCHAR2(2);
        
    BEGIN
        FOR w IN c1 LOOP
            SELECT to_number(substr(id_klasy, 1, 1)) + 1 || to_char(substr(id_klasy, 2, 1)) INTO v_id_klasy              
            FROM grupy
            WHERE id_grupy = w.id_grupy;

            UPDATE grupy
            SET id_klasy = v_id_klasy
            WHERE id_grupy = w.id_grupy;
        END LOOP;
    END;


PROCEDURE nowy_rocznik (
    in_ile_klas     INTEGER
) IS
    out_data_rozpoczecia  DATE;
    out_id_wychowawcy     INTEGER;
    v_id_klasy            VARCHAR2(2);
    
    c1                    SYS_REFCURSOR;
    vsql                  VARCHAR2(20000) := 
    'SELECT * FROM(
            SELECT n.id_nauczyciela
            FROM nauczyciele n 
            LEFT JOIN grupy  g ON g.id_wychowawcy = n.id_nauczyciela
            WHERE  n.data_zakonczenia_pracy IS NULL AND (g.id_grupy IS NULL OR data_zakonczenia is not null) 
            MINUS
            SELECT n.id_nauczyciela
            FROM nauczyciele n 
            LEFT JOIN grupy  g on g.id_wychowawcy = n.id_nauczyciela
            WHERE n.data_zakonczenia_pracy is null and  data_zakonczenia is null and id_grupy is not null
            )
        order by dbms_random.random()';
BEGIN
    
    SELECT MAX(data_rozpoczecia) INTO out_data_rozpoczecia
    FROM rok_szkolny;

    OPEN c1 FOR 'SELECT id_klasy 
    FROM klasy 
    WHERE id_klasy like ''1%'' 
    fetch first ' || in_ile_klas || ' rows only';

    LOOP
        FETCH c1 INTO v_id_klasy;
        EXIT WHEN c1%notfound;
        
        EXECUTE IMMEDIATE 
        vsql || ' fetch first row only '
          INTO out_id_wychowawcy;
          
        INSERT INTO grupy (id_klasy      ,  data_rozpoczecia     ,     id_wychowawcy)
        values      (v_id_klasy ,  out_data_rozpoczecia, out_id_wychowawcy);     
    END LOOP;
    CLOSE c1;
    
    dbms_output.put_line('Stworzono '||in_ile_klas||' nowe klasy.'); 
END;

PROCEDURE niezdanie IS

        cursor c1 is
        Select * FROM (
        SELECT distinct pu.id_ucznia as id_ucznia 
        , max(substr( nazwa_przedmiotu, length(nazwa_przedmiotu), 1)) as niezdana_klasa
        , substr(id_klasy,2,1) as kierunek, id_klasy
          FROM przedmioty_uczen         pu
          LEFT JOIN uczniowie           u ON u.id_ucznia        = pu.id_ucznia
          LEFT JOIN przedmioty          p ON p.id_przedmiotu    = pu.id_przedmiotu
          JOIN grupy                    g ON g.id_grupy         = u.id_grupy
         WHERE ocena_koncowa = 1
           AND u.data_zakonczenia_nauki IS NULL 
           GROUP BY pu.id_ucznia, substr(id_klasy,2,1), id_klasy) 
           WHERE (niezdana_klasa=substr(id_klasy,1,1)-1 AND niezdana_klasa <>4)
           OR (niezdana_klasa= 4 AND niezdana_klasa=substr(id_klasy,1,1));

        v_id_nowa_grupa INTEGER;
        
    BEGIN
        FOR w IN c1 LOOP    
        
            SELECT id_grupy INTO v_id_nowa_grupa
            FROM grupy 
            WHERE id_klasy = w.niezdana_klasa || w.kierunek;

            UPDATE uczniowie
            SET id_grupy = v_id_nowa_grupa
            WHERE id_ucznia = w.id_ucznia;
        END LOOP;       
        
        dbms_output.put_line('Przeniesiono uczniów, którzy niezdali, o klasę niżej. ');
    END;    


    PROCEDURE wpisanie_nowych_przedmiotow_grupa IS

        CURSOR c1 IS
        SELECT id_ucznia
          FROM uczniowie
         WHERE data_zakonczenia_nauki IS NULL;

        c2 SYS_REFCURSOR;
        
        v_id_ucznia     INTEGER;
        v_id_przedmiotu INTEGER;
        v_id_klasy      CHAR(2);
    BEGIN
        FOR w IN c1 LOOP
            
            SELECT g.id_klasy INTO v_id_klasy 
            FROM grupy        g
            JOIN uczniowie    u ON u.id_grupy = g.id_grupy
            WHERE id_ucznia = w.id_ucznia;

            OPEN c2 FOR 'SELECT ' || w.id_ucznia || ',   p.id_przedmiotu 
                                        FROM przedmioty_klasy pk
                                        RIGHT JOIN przedmioty p    ON p.id_przedmiotu = pk.id_przedmiotu
                                        WHERE id_klasy = ''' || v_id_klasy || '''  ';
            LOOP
                FETCH c2 INTO
                    v_id_ucznia, v_id_przedmiotu;
                EXIT WHEN c2%notfound;
                
                INSERT INTO przedmioty_uczen ( id_ucznia      , id_przedmiotu) 
                        VALUES               (v_id_ucznia      , v_id_przedmiotu);
            END LOOP;
            CLOSE c2;
        END LOOP;
    END;
END po_koncu_roku;
/

CREATE OR REPLACE PROCEDURE dodaj_osobe 
    (
          in_imie           dane_osobowe.imie%TYPE
        , in_nazwisko       dane_osobowe.nazwisko%TYPE
        , in_numer_telefonu dane_osobowe.numer_telefonu%TYPE
        , in_email          dane_osobowe.email%TYPE
        , in_adres          dane_osobowe.adres_zamieszkania%TYPE
        , in_data_urodzenia VARCHAR2
        , in_pesel          dane_osobowe.pesel%TYPE
        , in_rola           dane_osobowe.rola%TYPE
    ) IS
        check_pesel             INTEGER;
        check_numer_telefonu    dane_osobowe.numer_telefonu%TYPE;
        check_email             dane_osobowe.email%TYPE;
        check_adres             dane_osobowe.adres_zamieszkania%TYPE;
        check_rola              dane_osobowe.rola%TYPE;
    BEGIN

        BEGIN
        SELECT pesel       , numer_telefonu       , email       , adres_zamieszkania , rola
		  INTO check_pesel , check_numer_telefonu , check_email , check_adres        , check_rola
              FROM dane_osobowe
         WHERE pesel = in_pesel;

        EXCEPTION
            WHEN no_data_found THEN null; 
        END; 

        IF in_rola NOT IN ( 'k', 'u', 'n' ) 
        THEN dbms_output.put_line('Niepoprawna rola. Prosze wybrać literę k, u lub n.');
        RETURN;
        END IF;
        
        IF check_pesel IS NOT NULL THEN
            IF regexp_substr(check_rola, '' || in_rola || '{1}') IS NULL THEN
                EXECUTE IMMEDIATE
                'UPDATE dane_osobowe
                SET rola = ''rola'||in_rola||'''
                WHERE pesel = '||in_pesel;
                dbms_output.put_line('Dodano role do istniejacego rekordu');
                
            ELSE dbms_output.put_line('Osoba o identycznych danych istnieje juz w bazie.');
            END IF;

            IF check_numer_telefonu <> in_numer_telefonu THEN
                UPDATE dane_osobowe
                SET numer_telefonu = in_numer_telefonu
                WHERE pesel = in_pesel;
                dbms_output.put_line('Zaktualizowano numer telefonu.');
            END IF;

            IF check_email <> in_email THEN
                UPDATE dane_osobowe
                SET email = in_email
                WHERE pesel = in_pesel;
                dbms_output.put_line('Zaktualizowano adres email');
            END IF;

            IF check_adres <> in_adres THEN
                UPDATE dane_osobowe
                SET adres_zamieszkania = in_adres
                WHERE pesel = in_pesel;
                dbms_output.put_line('Zaktualizowano adres zamieszkania');
            END IF;
            RETURN;
            
        ELSE 
        INSERT INTO dane_osobowe ( imie    , nazwisko      , numer_telefonu     , email     , adres_zamieszkania , data_urodzenia                          , pesel    , rola) 
         VALUES                  ( in_imie , in_nazwisko   , in_numer_telefonu  , in_email  , in_adres           , to_date(in_data_urodzenia,'dd-mm-yyyy') , in_pesel , in_rola);
        dbms_output.put_line('Dodano dane nowej osoby.'); 
        END IF;

    END;
/

CREATE OR REPLACE PROCEDURE aktual_dane_osob (in_pesel INTEGER, in_kolumna VARCHAR2, in_aktualizacja VARCHAR2) IS
        check_pesel     INTEGER; 
        check_kolumna   VARCHAR2(40);
        
        check_constraint_violated EXCEPTION;
        PRAGMA exception_init ( check_constraint_violated, -2290 );
        
    BEGIN
        BEGIN
        SELECT pesel INTO check_pesel
        FROM dane_osobowe 
        WHERE pesel = in_pesel;
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Osoba o takim peselu nie istnieje w bazie.');
                RETURN;
        END;        
    
        BEGIN
            SELECT column_name INTO check_kolumna
            FROM user_tab_columns
            WHERE table_name like 'DANE_OSOBOWE' 
			AND column_name  like  upper(in_kolumna);
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Nie ma takiego pola w tabeli DANE_OSOBOWE. ');
                RETURN;
        END; 
    BEGIN     
        EXECUTE IMMEDIATE 
        'UPDATE dane_osobowe 
        SET '||in_kolumna||' = '''||in_aktualizacja||'''
        WHERE pesel = '||in_pesel; 
        dbms_output.put_line( 'Zaktualizowano pole '||in_kolumna||' o wartość: '||in_aktualizacja|| ' dla osoby o peselu: '|| in_pesel||'.');
               
    EXCEPTION
            WHEN check_constraint_violated 
                THEN dbms_output.put_line('Constraints violation');
            WHEN OTHERS 
                THEN dbms_output.put_line('Inny blad - ' || sqlcode || ' : ' || sqlerrm);
    END;
END;
/

CREATE OR REPLACE PROCEDURE usun_dane_osob (in_pesel INTEGER) IS
        check_pesel INTEGER;
    BEGIN
        BEGIN
            SELECT pesel INTO check_pesel
            FROM dane_osobowe
            WHERE pesel = in_pesel;
              
        EXCEPTION
            WHEN no_data_found 
                THEN dbms_output.put_line('Osoba o takim peselu nie istnieje w bazie.');
                RETURN;
        END; 

        DELETE FROM dane_osobowe 
        WHERE pesel = in_pesel;
        dbms_output.put_line('Wszystkie dane osoby o peselu: ' || in_pesel || ' zostaly usuniete z bazy.');
        END;
/

-- nauczyciele

CREATE OR REPLACE PACKAGE pckge_nauczyciele AS

PROCEDURE zmiana_wychowawcy (in_id_klasy VARCHAR2, in_id_wychowawcy INTEGER);
FUNCTION policz_godziny_nauczyciela(in_nauczyciel INTEGER) RETURN INTEGER;
PROCEDURE przydziel_godziny (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_klasa VARCHAR2);
PROCEDURE usun_przedmiot_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN);
PROCEDURE usun_przydzielone_godz (in_przedmiot VARCHAR2, in_klasa VARCHAR2);
PROCEDURE zakoncz_prace (in_nauczyciel INTEGER, in_data_zakonczenia VARCHAR2);
PROCEDURE zmien_max_godz (in_nauczyciel INTEGER, in_max_godz INTEGER);
PROCEDURE obsadz_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN);

END pckge_nauczyciele;
/

CREATE OR REPLACE PACKAGE BODY pckge_nauczyciele AS

PROCEDURE zmiana_wychowawcy (in_id_klasy VARCHAR2, in_id_wychowawcy INTEGER) IS

        v_id_grupy         INTEGER;
        
        check_grupa_daty   DATE;
        check_nauczyciele  INTEGER;
        check_wychowawcy   INTEGER;
    BEGIN
        BEGIN
            SELECT  id_grupy       , data_zakonczenia
            INTO  v_id_grupy , check_grupa_daty
            FROM grupy
            WHERE data_zakonczenia is null 
            AND id_klasy = lower(in_id_klasy);

        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Brak klasy o podanym id');
                RETURN;
        END;

        IF check_grupa_daty IS NOT NULL THEN 
            dbms_output.put_line('Klasa już skończyła szkole');
            RETURN;
        END IF;
        
        BEGIN
            SELECT id_nauczyciela INTO check_nauczyciele
            FROM nauczyciele
            WHERE id_nauczyciela = in_id_wychowawcy
            AND data_zakonczenia_pracy IS NOT NULL;

        EXCEPTION
            WHEN no_data_found THEN 
                dbms_output.put_line('Brak nauczyciela o podanym id.'); 
                RETURN; 
        END;
        
        BEGIN
        SELECT id_wychowawcy INTO check_wychowawcy
        FROM grupy
        WHERE data_zakonczenia IS NULL
           AND id_wychowawcy = in_id_wychowawcy;
           
        EXCEPTION
            WHEN no_data_found THEN null; 
        END;        
     
        IF check_wychowawcy IS NOT NULL THEN 
            dbms_output.put_line('Nauczyciel jest obecnie wychowawca innej klasy. Prosze wybrac innego nauczyciela');
            RETURN;
        END IF;       
        
        UPDATE grupy
        SET id_wychowawcy = in_id_wychowawcy 
        WHERE id_grupy = v_id_grupy;
                
        dbms_output.put_line('Wpisano nauczyciela o id: '||in_id_wychowawcy||' jako wychowawce klasy '||lower(in_id_klasy)||'. ');
    END;

FUNCTION policz_godziny_nauczyciela(in_nauczyciel INTEGER) RETURN INTEGER AS
        v_ilosc_godz INTEGER;
    BEGIN
        SELECT SUM(ilosc_przydzielonych_godzin) INTO v_ilosc_godz 
        FROM przydzielone_godziny
        WHERE id_nauczyciel_przedmiot IN (SELECT id_nauczyciel_przedmiot
                                        FROM nauczyciel_przedmiot
                                        WHERE id_nauczyciela = in_nauczyciel);
        RETURN v_ilosc_godz;
    END;

PROCEDURE przydziel_godziny (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_klasa VARCHAR2) AS
        v_przedmiot_klasa INTEGER;
        v_ilosc_godzin    INTEGER;
        v_max_godz        INTEGER;
        przekroczono_max_godz EXCEPTION;
        v_nazwa           VARCHAR2(30) := lower(in_przedmiot) || '_' || SUBSTR(in_klasa, 1, 1);
    BEGIN
        SELECT id_przedmioty_klasy, ilosc_godzin_przedmiotu
        INTO v_przedmiot_klasa, v_ilosc_godzin
        FROM przedmioty_klasy 
        WHERE id_klasy = in_klasa AND id_przedmiotu IN (SELECT id_przedmiotu 
		                                              FROM przedmioty 
													  WHERE nazwa_przedmiotu = v_nazwa);

        SELECT max_godz_tyg INTO v_max_godz
        FROM nauczyciele
        WHERE id_nauczyciela = in_nauczyciel;
         

        IF v_max_godz < (v_ilosc_godzin + policz_godziny_nauczyciela(in_nauczyciel)) THEN
            RAISE przekroczono_max_godz;
        END IF;

        UPDATE przydzielone_godziny
        SET id_nauczyciel_przedmiot = in_nauczyciel
        WHERE id_przedmioty_klasy = v_przedmiot_klasa;

    EXCEPTION
        WHEN przekroczono_max_godz THEN
            DBMS_OUTPUT.PUT_LINE('nie mozna przekroczyc maksymalnej liczby godzin!');
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowa nazwa przedmiotu lub id klasy!');
        WHEN OTHERS THEN
            RAISE;
    END; 

PROCEDURE usun_przedmiot_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN) AS
        check_count INTEGER;
        brak_danych EXCEPTION;
        v_nazwa       VARCHAR2(50) := lower(in_przedmiot) || '%';
    BEGIN
        SELECT COUNT(*) INTO check_count
        FROM nauczyciel_przedmiot
        WHERE id_nauczyciela = in_nauczyciel 
		AND id_przedmiotu IN (SELECT id_przedmiotu 
		                      FROM przedmioty 
							  WHERE nazwa_przedmiotu LIKE v_nazwa); 

        IF  check_count = 0 THEN
            RAISE brak_danych;
        END IF;

        IF in_rozszerzenie THEN
            DELETE nauczyciel_przedmiot 
            WHERE id_nauczyciela = in_nauczyciel  
            AND id_przedmiotu IN (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu LIKE v_nazwa  AND rozszerzenie IS NOT NULL); 
        ELSE
            DELETE nauczyciel_przedmiot 
            WHERE id_nauczyciela = in_nauczyciel  
            AND id_przedmiotu IN (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu LIKE v_nazwa AND rozszerzenie IS NULL);
        END IF;

    EXCEPTION
        WHEN brak_danych THEN
            DBMS_OUTPUT.PUT_LINE('Nieprawidłowa nazwa przedmiotu lub id nauczyciela!');
        WHEN others THEN
            RAISE;
    END;

PROCEDURE usun_przydzielone_godz (in_przedmiot VARCHAR2, in_klasa VARCHAR2) AS
        v_przedmiot_klasa      INTEGER;
        v_ilosc_godzin         INTEGER;
        nauczyciel_przedmiot   INTEGER;
        check_rozszerzenie     VARCHAR2(1);
        v_nazwa                VARCHAR2(30) := lower(in_przedmiot) || '_' || SUBSTR(in_klasa, 1, 1);
    BEGIN
        SELECT rozszerzenie INTO check_rozszerzenie
        FROM przedmioty_klasy
        JOIN przedmioty USING (id_przedmiotu)
        WHERE id_klasy = in_klasa AND id_przedmiotu IN (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu = v_nazwa);

        SELECT id_przedmioty_klasy INTO v_przedmiot_klasa
        FROM przedmioty_klasy 
        WHERE id_klasy = in_klasa 
        AND id_przedmiotu = (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu = v_nazwa AND rozszerzenie = check_rozszerzenie);
        
        SELECT ilosc_przydzielonych_godzin INTO v_ilosc_godzin
        FROM przydzielone_godziny
        WHERE id_przedmioty_klasy = v_przedmiot_klasa;

        UPDATE przydzielone_godziny
        SET id_nauczyciel_przedmiot = NULL
        WHERE id_przedmioty_klasy = v_przedmiot_klasa;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowa nazwa przedmiotu lub id klasy!');
        WHEN OTHERS THEN
            RAISE;
    END;

PROCEDURE zakoncz_prace (in_nauczyciel INTEGER, in_data_zakonczenia VARCHAR2) AS
        V_data_rozpoczecia           DATE;
        niepoprawna_data             EXCEPTION;
        nauczyciel_jest_wychowawca   EXCEPTION;
        v_grupa                      INTEGER;
    BEGIN
        SELECT data_rozpoczecia_pracy INTO v_data_rozpoczecia
        FROM nauczyciele 
        WHERE id_nauczyciela = in_nauczyciel;

        IF to_date(in_data_zakonczenia, 'DD-MM-RRRR') <  v_data_rozpoczecia THEN
            RAISE niepoprawna_data;
        END IF;

        SELECT COUNT(id_grupy) INTO v_grupa
        FROM grupy
        WHERE id_wychowawcy = in_nauczyciel AND data_zakonczenia > SYSDATE;

        IF v_grupa <> 0 THEN
            RAISE nauczyciel_jest_wychowawca;
        END IF;
        
        UPDATE przydzielone_godziny
        SET ilosc_przydzielonych_godzin = 0
        WHERE id_nauczyciel_przedmiot IN (SELECT id_nauczyciel_przedmiot FROM nauczyciel_przedmiot WHERE id_nauczyciela = in_nauczyciel);

        UPDATE nauczyciele
        SET data_zakonczenia_pracy = to_date(in_data_zakonczenia, 'DD-MM-RRRR'),
            max_godz_tyg = NULL
        WHERE id_nauczyciela = in_nauczyciel;

    EXCEPTION
        WHEN niepoprawna_data THEN
            DBMS_OUTPUT.PUT_LINE('Data zakonczenia nie moze byc mniejsza od daty rozpoczecia!');
        WHEN nauczyciel_jest_wychowawca THEN
            DBMS_OUTPUT.PUT_LINE('Nauczyciel jest aktualnie wychowawcą!');
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nieprawidlowe id nauczyciela!');
        WHEN OTHERS THEN
            RAISE;
    END;

PROCEDURE zmien_max_godz (in_nauczyciel INTEGER, in_max_godz INTEGER) AS
        nieprawidlowe_godziny   EXCEPTION;
        nauczyciel_nie_istnieje EXCEPTION;
    BEGIN
        IF in_max_godz < policz_godziny_nauczyciela(in_nauczyciel) THEN
            RAISE nieprawidlowe_godziny;
        END IF;

        UPDATE nauczyciele
        SET max_godz_tyg = in_max_godz
        WHERE id_nauczyciela = in_nauczyciel;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE nauczyciel_nie_istnieje;
        END IF;

    EXCEPTION
        WHEN nieprawidlowe_godziny THEN
            DBMS_OUTPUT.PUT_LINE('liczba maksymalnych godzin nie moce byc mniejsza niÅ¼ liczba przydzielonych godzin!');
        WHEN nauczyciel_nie_istnieje THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowe id nauczyciela!');
        WHEN OTHERS THEN
            RAISE;
    END;

PROCEDURE obsadz_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN) AS 
            v_id       INTEGER;
            v_nazwa    VARCHAR2(30) := in_przedmiot || '%';
            v_stmt VARCHAR2(400) := 'SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu LIKE :p ';
            cur      SYS_REFCURSOR;
        BEGIN
            IF in_rozszerzenie THEN
                v_stmt := v_stmt || 'AND rozszerzenie IS NOT NULL';
            ELSE
                v_stmt := v_stmt || 'AND rozszerzenie IS NULL';
            END IF;

            OPEN cur FOR v_stmt USING v_nazwa;

            LOOP
                FETCH cur INTO v_id;
                EXIT WHEN cur%NOTFOUND;

                INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                    VALUES (in_nauczyciel, v_id);
            END LOOP;

            CLOSE cur;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('nieprawidlowe dane!');
            WHEN OTHERS THEN
                RAISE;
        END;

END pckge_nauczyciele;
/

CREATE OR REPLACE PACKAGE raporty AS 
PROCEDURE pokaz_wolnych_nauczycieli(in_przedmiot VARCHAR2, in_klasa VARCHAR2); 
PROCEDURE wyswietl_klasy;
PROCEDURE wypisz_oceny_ucznia( in_pesel INTEGER );
PROCEDURE wypisz_oceny_per_przedmiot_klasa(in_id_klasy  VARCHAR2, in_przedmiot VARCHAR2) ;
END raporty;
/

CREATE OR REPLACE PACKAGE BODY raporty AS

PROCEDURE pokaz_wolnych_nauczycieli (in_przedmiot VARCHAR2, in_klasa VARCHAR2) AS
        v_godziny            INTEGER;
        check_rozszerzenie VARCHAR2(1);
        v_nazwa VARCHAR2(50) := in_przedmiot || SUBSTR(in_klasa, 1, 1);
    BEGIN
        SELECT ilosc_godzin_przedmiotu, rozszerzenie INTO v_godziny, check_rozszerzenie
        FROM przedmioty_klasy
        JOIN przedmioty USING (id_przedmiotu)
        WHERE id_klasy = in_klasa AND id_przedmiotu IN (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu = v_nazwa);
         
        DECLARE
            CURSOR cur IS
                SELECT id_nauczyciela, imie, nazwisko, max_godz_tyg
                FROM nauczyciel_przedmiot
                JOIN nauczyciele  USING (id_nauczyciela)
                JOIN dane_osobowe USING (id_dane_osobowe)
                Join przedmioty   USING (id_przedmiotu)
                WHERE nazwa_przedmiotu = in_przedmiot
                AND rozszerzenie = check_rozszerzenie
                AND (max_godz_tyg - policz_godziny_nauczyciela(id_nauczyciela)) >= v_godziny;
        BEGIN
            DBMS_OUTPUT.PUT_LINE('dostepni nauczyciele:');
            DBMS_OUTPUT.PUT_LINE('id_nauczyciela. imie nazwisko');

            FOR rec IN cur LOOP
                    dbms_output.put_line(rec.id_nauczyciela || '. ' || rec.imie || ' ' || rec.nazwisko);
            END LOOP;
        END;
    END;
    
PROCEDURE wyswietl_klasy IS
    CURSOR c1 IS
    SELECT g.id_grupy, g.id_klasy, d.imie, d.nazwisko, k.nazwa_kierunku, g.data_rozpoczecia
      FROM grupy        g
      LEFT JOIN klasy        k ON k.id_klasy        = g.id_klasy
      LEFT JOIN nauczyciele  n ON n.id_nauczyciela  = g.id_wychowawcy
      LEFT JOIN dane_osobowe d ON d.id_dane_osobowe = n.id_dane_osobowe
     WHERE data_zakonczenia IS NULL
     ORDER BY id_klasy;

    c2                SYS_REFCURSOR;
    
    v_imie_ucznia     dane_osobowe.imie%TYPE;
    v_nazwisko_ucznia dane_osobowe.nazwisko%TYPE;
BEGIN
    FOR w IN c1 LOOP
        dbms_output.put_line('Klasa: ' || w.id_klasy || ', ' || w.nazwa_kierunku);
        dbms_output.put_line('Rocznik: ' || to_char(w.data_rozpoczecia, 'yyyy') || '/' ||(to_number(to_char(w.data_rozpoczecia, 'yyyy')) + 4));
        dbms_output.put_line('Wychowawca: ' || w.imie || ' ' || w.nazwisko);
        dbms_output.put_line('----------------------');

        OPEN c2 FOR 'select imie, nazwisko from uczniowie u
        left join dane_osobowe d on d.id_dane_osobowe = u.id_dane_osobowe 
        where id_grupy = ' || w.id_grupy;

        LOOP
            FETCH c2 INTO
                v_imie_ucznia, v_nazwisko_ucznia;
            EXIT WHEN c2%notfound;
            dbms_output.put_line(c2%rowcount || '. ' || v_imie_ucznia || ' ' || v_nazwisko_ucznia);
        END LOOP;

        CLOSE c2;
        dbms_output.new_line;
    END LOOP;
END;

PROCEDURE wypisz_oceny_ucznia (in_pesel INTEGER	) IS

		CURSOR c1 IS
		SELECT p.nazwa_przedmiotu, pu.srednia_ocen, pu.ocena_koncowa, pu.id_przedmioty_uczen
		  FROM uczniowie        u
		  LEFT JOIN przedmioty_uczen pu ON pu.id_ucznia = u.id_ucznia
		  LEFT JOIN przedmioty       p  ON p.id_przedmiotu = pu.id_przedmiotu
		  LEFT JOIN grupy            g  ON g.id_grupy = u.id_grupy
		  LEFT JOIN dane_osobowe     d  ON d.id_dane_osobowe = u.id_dane_osobowe
		 WHERE substr(p.nazwa_przedmiotu, length(p.nazwa_przedmiotu), 1) = substr(g.id_klasy, 1, 1)
		   AND d.pesel = in_pesel;

		c2       SYS_REFCURSOR;
		
		v_ocena                NUMBER;
		v_imie                 dane_osobowe.imie%TYPE;
		v_nazwisko             dane_osobowe.nazwisko%TYPE;
		v_id_klasy             grupy.id_klasy%TYPE;
		check_pesel            INTEGER;
		check_data_zakonczenia DATE;
	BEGIN
		BEGIN
			SELECT  d.pesel         , u.data_zakonczenia_nauki 
            INTO    check_pesel    , check_data_zakonczenia
            FROM uczniowie    u
            JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
            JOIN grupy        g ON g.id_grupy        = u.id_grupy
            WHERE pesel = in_pesel 
            AND rola LIKE '%u%';
			
		EXCEPTION
			WHEN no_data_found THEN
				dbms_output.put_line('Brak ucznia o takim peselu w bazie. ');
				RETURN;
		END;

		IF check_data_zakonczenia IS NOT NULL 
		THEN dbms_output.put_line('Uczeń już nie uczy się w danej szkole. Pokazano oceny z ostatniej klasy ucznia.');
		END IF;
		 
		SELECT  imie, nazwisko, g.id_klasy INTO v_imie, v_nazwisko, v_id_klasy
        FROM uczniowie         u
        LEFT JOIN dane_osobowe d ON d.id_dane_osobowe = u.id_dane_osobowe
        LEFT JOIN grupy        g ON g.id_grupy        = u.id_grupy
        WHERE pesel =  in_pesel;
		  
		dbms_output.put_line(v_imie || ' ' || v_nazwisko || ' klasa ' || v_id_klasy);
		dbms_output.put_line('Lista przedmiotów i ocen ');
		dbms_output.put('------------------------');
		
		FOR w IN c1 LOOP
			dbms_output.new_line;
			dbms_output.put(rpad(initcap(substr(w.nazwa_przedmiotu, 1, length(w.nazwa_przedmiotu) - 2)) || ': ', 21, ' '));

			OPEN c2 FOR 'SELECT ocena
                     FROM oceny
                     WHERE id_przedmioty_uczen = ' || w.id_przedmioty_uczen;

			LOOP
				FETCH c2 INTO v_ocena;
				EXIT WHEN c2%notfound;
				dbms_output.put(v_ocena || '; ');
			END LOOP;
			CLOSE c2;
			
			dbms_output.put('Średnia ocen: ' || w.srednia_ocen || ' Ocena koncowa: ' || w.ocena_koncowa);
		END LOOP;
	END;

	PROCEDURE wypisz_oceny_per_przedmiot_klasa (in_id_klasy VARCHAR2, in_przedmiot  VARCHAR2) IS

		CURSOR c1 IS
		SELECT imie, nazwisko, g.id_klasy, id_przedmioty_uczen
		  FROM uczniowie             u
		  LEFT JOIN dane_osobowe     d  ON d.id_dane_osobowe = u.id_dane_osobowe
		  LEFT JOIN grupy            g  ON g.id_grupy        = u.id_grupy
		  LEFT JOIN klasy            k  ON k.id_klasy        = g.id_klasy
		  LEFT JOIN przedmioty_klasy pk ON pk.id_klasy       = k.id_klasy
		  LEFT JOIN przedmioty       p  ON p.id_przedmiotu   = pk.id_przedmiotu
		  LEFT JOIN przedmioty_uczen pu ON pu.id_ucznia      = u.id_ucznia AND pu.id_przedmiotu = p.id_przedmiotu
		 WHERE g.id_klasy = lower(in_id_klasy)
		   AND nazwa_przedmiotu = lower(in_przedmiot || '_' || substr(in_id_klasy, 1, 1))
		 ORDER BY nazwisko;

		c2   SYS_REFCURSOR;
		
		v_ocena         NUMBER;
		check_klasy     VARCHAR2(2);
		check_przedmiot VARCHAR2(25);
	BEGIN
		BEGIN
			SELECT id_klasy INTO check_klasy
			FROM grupy
			WHERE data_zakonczenia IS NULL
		        AND id_klasy = lower(in_id_klasy);
				
		EXCEPTION
			WHEN no_data_found THEN
				dbms_output.put_line('Niepoprawna klasa. ');
				RETURN;
		END;

		BEGIN
		
			SELECT p.nazwa_przedmiotu INTO check_przedmiot
			FROM przedmioty_klasy pk
			LEFT JOIN grupy            g ON g.id_klasy = pk.id_klasy
			LEFT JOIN przedmioty       p ON pk.id_przedmiotu = p.id_przedmiotu
			WHERE data_zakonczenia IS NULL
			  AND pk.id_klasy = lower(in_id_klasy)
			  AND nazwa_przedmiotu = lower(in_przedmiot || '_' || substr(in_id_klasy, 1, 1));

		EXCEPTION
			WHEN no_data_found THEN
				dbms_output.put_line('Niepoprawna nazwa przedmiotu. ');
				RETURN;
		END;

		dbms_output.put_line('Klasa: ' || in_id_klasy || ', Przedmiot: ' || initcap(in_przedmiot));

		FOR w IN c1 LOOP
			dbms_output.new_line;
			dbms_output.put(rpad(w.nazwisko || ', ' || w.imie || ': ', 25, ' '));

			OPEN c2 FOR 'select ocena
                     from oceny
                     where id_przedmioty_uczen = ' || w.id_przedmioty_uczen;
			LOOP
				FETCH c2 INTO v_ocena;
				EXIT WHEN c2%notfound;
				dbms_output.put(v_ocena || '; ');
			END LOOP;
			CLOSE c2;
			
		END LOOP;
	END;
END raporty;    
