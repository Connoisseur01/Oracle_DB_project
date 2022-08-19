-- pakiet do populacji tablic

CREATE OR REPLACE PACKAGE populate AS
    PROCEDURE pop_przedmioty;
    PROCEDURE pop_klasy;
    PROCEDURE pop_uczniowie;
    PROCEDURE obsadz_nauczyciela (nauczyciel INTEGER, przedmiot VARCHAR2, rozszerzenie BOOLEAN);
    PROCEDURE przydziel_godz (id_naucz INTEGER, przedmiot VARCHAR2, id_klas VARCHAR2);
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
                    
                    INSERT INTO przedmioty (nazwa_przedmiotu)
                        VALUES (przedmiot);
                    
                    INSERT INTO przedmioty (nazwa_przedmiotu, rozszerzenie)
                        VALUES (przedmiot, 'R');
                END LOOP;
            END LOOP;
        END;
    
    PROCEDURE pop_klasy IS 
            TYPE tabela_klas IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(1);
    
            klasy tabela_klas :=
            tabela_klas('a' => 'mat-fiz', 
                        'b' => 'biol-hem', 
                        'c' => 'ekonomiczna', 
                        'd' => 'humanistyczna');
            klasa VARCHAR2(2);
        BEGIN 
            FOR i IN ASCII('a') .. ASCII('d') LOOP
                FOR k IN 1 .. 4 LOOP
                    klasa := k || CHR(i);
                    
                    INSERT INTO klasy (id_klasy, nazwa_kierunku)
                        VALUES (klasa, klasy(CHR(i)));
                END LOOP;
            END LOOP;
        END;

    PROCEDURE pop_uczniowie IS
            data_rozp DATE;
            data_zakon DATE;
        BEGIN
            FOR j IN 1..36 LOOP
                FOR i IN 1..10 LOOP
                    SELECT data_rozpoczecia, data_zakonczenia INTO data_rozp, data_zakon
                    FROM grupy
                    WHERE id_grupy = j;

                    INSERT INTO uczniowie (id_dane_osobowe, data_rozpoczecia_nauki, data_zakonczenia_nauki, id_grupy)
                        VALUES ( i + ( j - 1 ) * 10, data_rozp, data_zakon, j);

                END LOOP;
            END LOOP;
        END;

    PROCEDURE obsadz_nauczyciela (nauczyciel INTEGER, przedmiot VARCHAR2, rozszerzenie BOOLEAN) IS 
            p varchar2(30);
            id INTEGER;
        BEGIN
            FOR i IN 1 .. 4 LOOP
                p := przedmiot || '_' || i;
                SELECT id_przedmiotu INTO id FROM przedmioty WHERE nazwa_przedmiotu = p AND rozszerzenie IS NULL;
                INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                VALUES (nauczyciel, id);
            END LOOP;
            
            IF rozszerzenie THEN
                FOR i IN 1 .. 4 LOOP
                    p := przedmiot || '_' || i;
                    SELECT id_przedmiotu INTO id FROM przedmioty WHERE nazwa_przedmiotu = p AND rozszerzenie IS NOT NULL;
                    INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                    VALUES (nauczyciel, id);
                END LOOP;
            END IF;
        END;

    PROCEDURE przydziel_godz (id_naucz INTEGER, przedmiot VARCHAR2, id_klas VARCHAR2) IS 
            id_naucz_przed INTEGER;
            id_przed_klasa INTEGER;
            ilosc_godzin INTEGER;

            klasa INTEGER := SUBSTR(id_klas, 0, 1);
            id_przed INTEGER;
        BEGIN

            SELECT id_przedmioty_klasy, ilosc_godzin_przedmiotu, id_przedmiotu INTO id_przed_klasa, ilosc_godzin, id_przed
            FROM przedmioty_klasy
            WHERE id_klasy = id_klas AND id_przedmiotu IN (SELECT id_przedmiotu
                                                        FROM przedmioty
                                                        WHERE nazwa_przedmiotu LIKE przedmiot || '_' || klasa);

            SELECT id_nauczyciel_przedmiot INTO id_naucz_przed
            FROM nauczyciel_przedmiot
            WHERE id_nauczyciela = id_naucz AND id_przedmiotu = id_przed;

            INSERT INTO przydzielone_godziny (id_nauczyciel_przedmiot, id_przedmioty_klasy, ilosc_przydzielonych_godzin)
                VALUES (id_naucz_przed, id_przed_klasa, ilosc_godzin);
        END;
    
    PROCEDURE pop_przedmiot_uczen IS 
            c1 SYS_REFCURSOR;

            id_uczen INTEGER;
            id_przedmiot INTEGER;
            id_klasy CHAR(2); 

            v_polecenie VARCHAR2(500) := ' as stala,   p.id_przedmiotu 
                                        FROM przedmioty_klasy pk
                                        RIGHT JOIN przedmioty p     ON p.id_przedmiotu = pk.id_przedmiotu
                                        WHERE id_klasy ';
            vsql VARCHAR2(2000);
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
            v_rok_przedmiot 		INTEGER;
            v_ostatnia_klasa 		INTEGER;
            v_rozpoczecie_nauki 	DATE; 

            v_data_rozpoczecia 		DATE;
            v_data_zakonczenia 		DATE;

        BEGIN
        dbms_random.seed(11);
            FOR i IN 1..10050 LOOP
                SELECT 	to_number(substr(p.nazwa_przedmiotu, - 1, 1))	, to_number(substr(g.id_klasy, 1, 1))	, g.data_rozpoczecia 
                INTO 	v_rok_przedmiot									, v_ostatnia_klasa						, v_rozpoczecie_nauki
                FROM przedmioty_uczen 	p_u
                LEFT JOIN przedmioty 	p 	ON p.id_przedmiotu = p_u.id_przedmiotu
                LEFT JOIN uczniowie 	u 	ON u.id_ucznia = p_u.id_ucznia
                LEFT JOIN grupy 		g 	ON g.id_grupy = u.id_grupy
                WHERE p_u.id_przedmioty_uczen = i;

                FOR n IN 1..4 LOOP
                    IF v_rok_przedmiot = n THEN
                        SELECT	data_rozpoczecia	, data_zakonczenia 
                        INTO 	v_data_rozpoczecia	, v_data_zakonczenia
                        FROM rok_szkolny
                        WHERE id_rs = (SELECT id_rs + n - 1 
                                        FROM rok_szkolny
                                        WHERE data_rozpoczecia = v_rozpoczecie_nauki);

                        FOR j IN 1..5 LOOP
                            INSERT INTO oceny 	(id_przedmioty_uczen, ocena, timestamp_oceny) 
                                VALUES 			(
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
	        EXECUTE IMMEDIATE
		    'UPDATE przedmioty_uczen pu
		        SET
			    srednia_ocen = ( SELECT AVG(ocena)
			                     FROM oceny o
			                     WHERE o.id_przedmioty_uczen = pu.id_przedmioty_uczen )';
	    END;
        
     
     PROCEDURE pop_ocena_koncowa IS
	     BEGIN
	        EXECUTE IMMEDIATE
		    'UPDATE przedmioty_uczen pu
		        SET
			    ocena_koncowa = ( SELECT AVG(ocena)
			                     FROM oceny o
			                     WHERE o.id_przedmioty_uczen = pu.id_przedmioty_uczen )';
	    END;
        
        
END populate;
/

--przed koncem roku szkolnego



--wpisanie oceny jednostkowej 

CREATE OR REPLACE PROCEDURE proc_wpisanie_oceny (in_pesel INTEGER, in_nazwa_przedmiotu VARCHAR2, in_ocena INTEGER) IS
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
            JOIN grupy        g ON g.id_grupy = u.id_grupy
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
            'SELECT     nazwa_przedmiotu    , id_przedmioty_uczen
            FROM uczniowie u
            JOIN dane_osobowe          d ON d.id_dane_osobowe = u.id_dane_osobowe
            JOIN grupy                 g ON g.id_grupy = u.id_grupy
            LEFT JOIN przedmioty_uczen pu ON pu.id_ucznia = u.id_ucznia
            JOIN przedmioty            p ON p.id_przedmiotu = pu.id_przedmiotu
            WHERE substr(nazwa_przedmiotu, length(nazwa_przedmiotu), 1) = substr(g.id_klasy, 1, 1) --zeby znaleźć przedmiot tylko z obecnej klasy 
            AND pesel = ' ||in_pesel||'
            AND rola LIKE ''%u%''
            AND nazwa_przedmiotu = ( lower('''||in_nazwa_przedmiotu||''') || ''_'' || substr(g.id_klasy, 1, 1) )' -- żeby nie musiec wpisywac numerka w nazwie
            INTO        check_przedmiot     , v_id_przedmioty_uczen;

        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Niepoprawna nazwa przedmiotu. ');
                RETURN;
        END;

        EXECUTE IMMEDIATE 'INSERT INTO oceny (id_przedmioty_uczen   , ocena             , timestamp_oceny)
                            VALUES ( '||v_id_przedmioty_uczen||'    , '|| in_ocena || ' , :systimestamp )'
                            USING systimestamp;
        
        DBMS_OUTPUT.PUT_LINE('Uczniowi o peselu: '|| in_pesel || ' wpisano ocenę: '|| in_ocena|| ' z przedmiotu: '|| in_nazwa_przedmiotu);

    EXECUTE IMMEDIATE
        'UPDATE przedmioty_uczen
           SET
            srednia_ocen = ( SELECT AVG(ocena)
                               FROM oceny 
                              WHERE id_przedmioty_uczen = '||v_id_przedmioty_uczen|| ')
                WHERE id_przedmioty_uczen = '||v_id_przedmioty_uczen ;  
    END;
/

--wpisanie oceny koncowej

CREATE OR REPLACE PROCEDURE proc_wpisanie_oceny_koncowej (in_pesel INTEGER, in_nazwa_przedmiotu VARCHAR2, in_ocena INTEGER) IS
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
            JOIN grupy        g ON g.id_grupy = u.id_grupy
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
            JOIN dane_osobowe     		d  ON d.id_dane_osobowe = u.id_dane_osobowe
            JOIN grupy            		g  ON g.id_grupy = u.id_grupy
            LEFT JOIN przedmioty_uczen 	pu ON pu.id_ucznia = u.id_ucznia
            JOIN przedmioty       		p  ON p.id_przedmiotu = pu.id_przedmiotu
            WHERE substr(nazwa_przedmiotu, length(nazwa_przedmiotu), 1) = substr(g.id_klasy, 1, 1) --zeby znaleźć przedmiot tylko z obecnej klasy 
            AND pesel = in_pesel
            AND rola LIKE ''%u%''
            AND nazwa_przedmiotu = ( lower('||in_nazwa_przedmiotu||')||''_''|| substr(g.id_klasy, 1, 1) )' -- żeby nie musiec wpisywac numerka w nazwie
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

/

--po końcu roku szkolnego

CREATE OR REPLACE PACKAGE po_koncu_roku AS  
PROCEDURE proc_dodaj_date_zakonczenia_grup;
PROCEDURE proc_dodaj_rok_szkolny;
PROCEDURE proc_zdanie;
PROCEDURE proc_nowy_rocznik (in_ile_klas INTEGER);
PROCEDURE proc_niezdanie;
PROCEDURE proc_wpisanie_nowych_przedmiotow_grupa;
END po_koncu_roku;
/
CREATE OR REPLACE PACKAGE BODY po_koncu_roku AS

    PROCEDURE proc_dodaj_date_zakonczenia_grup IS
        c1 SYS_REFCURSOR;
        c2 SYS_REFCURSOR;
        
        v_data_zakonczenia  DATE;
        v_id_grupy          INTEGER;
        v_id_ucznia         INTEGER;
    BEGIN
    EXECUTE IMMEDIATE
        'SELECT MAX(data_zakonczenia)
         FROM rok_szkolny'
          INTO v_data_zakonczenia;

        OPEN c1 FOR 'SELECT id_grupy
                    FROM grupy 
                    WHERE id_klasy like ''4%''
                    and data_zakonczenia is null';

        LOOP        
            FETCH c1 INTO v_id_grupy;
            EXIT WHEN c1%notfound;
            EXECUTE IMMEDIATE 'UPDATE grupy
                                SET data_zakonczenia= :v_data_zakonczenia 
                                WHERE id_grupy = ' || v_id_grupy
                USING IN v_data_zakonczenia;
                
            OPEN c2 FOR 'SELECT id_ucznia FROM uczniowie u
                        WHERE id_grupy = ' || v_id_grupy || ' and data_zakonczenia_nauki is null
                        MINUS
                        SELECT u.id_ucznia FROM uczniowie u 
                        left join przedmioty_uczen pu on pu.id_ucznia = u.id_ucznia
                        WHERE id_grupy = ' || v_id_grupy || ' and data_zakonczenia_nauki is null
                        and pu.ocena_koncowa =1 '; -- lista uczniów dla grup ktore powinny konczyc minus lista uczniow ktorzy maja  1. 
            LOOP
                FETCH c2 INTO v_id_ucznia;
                EXIT WHEN c2%notfound;
                
                EXECUTE IMMEDIATE
                'UPDATE uczniowie
                   SET
                    data_zakonczenia_nauki = :v_data_zakonczenia
                 WHERE id_ucznia = '||v_id_ucznia
                 USING v_data_zakonczenia;

            END LOOP;

            CLOSE c2;
        END LOOP;

        CLOSE c1;
        dbms_output.put_line('Wpisano datę zakończenia dla klas 4: '||v_data_zakonczenia);
    END;

    PROCEDURE proc_dodaj_rok_szkolny 
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
        
        EXECUTE IMMEDIATE 
        'INSERT INTO rok_szkolny    (data_rozpoczecia       , data_zakonczenia)
                    values          (:out_data_rozpoczecia  , :out_data_zakonczenia)'
            USING                     out_data_rozpoczecia  , out_data_zakonczenia;
            
        dbms_output.put_line('Wpisano rok zaczynajacy się: ' || out_data_rozpoczecia || ' oraz konczacy sie: ' || out_data_zakonczenia);
        
        EXECUTE IMMEDIATE 
        'ALTER SESSION 
        SET NLS_territory='''|| v_original_terr ||'''';
    END;

PROCEDURE proc_zdanie 
IS
        CURSOR c1 IS
        SELECT id_grupy
          FROM grupy
         WHERE data_zakonczenia IS NULL;

        v_id_klasy VARCHAR2(2);
        
    BEGIN
        FOR w IN c1 LOOP
        EXECUTE IMMEDIATE
            'SELECT to_number(substr(id_klasy, 1, 1)) + 1 || to_char(substr(id_klasy, 2, 1))              
             FROM grupy
             WHERE id_grupy = '||w.id_grupy
             INTO v_id_klasy;

            EXECUTE IMMEDIATE 
            'UPDATE grupy
                SET id_klasy = '''|| v_id_klasy ||'''
                 WHERE id_grupy = ' || w.id_grupy;
        END LOOP;
    END;


PROCEDURE proc_nowy_rocznik (
    in_ile_klas 	INTEGER
) IS
    out_data_rozpoczecia  DATE;
    out_id_wychowawcy     INTEGER;
    v_id_klasy            VARCHAR2(2);
	
    c1                    SYS_REFCURSOR;
    vsql                  VARCHAR2(20000) := 
	'SELECT * FROM(
            SELECT id_nauczyciela
            FROM nauczyciele n 
            LEFT JOIN grupy g ON g.id_wychowawcy = n.id_nauczyciela
            WHERE  n.data_zakonczenia_pracy IS NULL AND (g.id_grupy IS NULL OR data_zakonczenia is not null) 
            MINUS
            SELECT id_nauczyciela
            FROM nauczyciele n 
            left join grupy g on g.id_wychowawcy = n.id_nauczyciela
            WHERE n.data_zakonczenia_pracy is null and  data_zakonczenia is null and id_grupy is not null
            )
        order by dbms_random.random()';
BEGIN
    
    EXECUTE IMMEDIATE
    'SELECT MAX(data_rozpoczecia)
      FROM rok_szkolny'
      INTO out_data_rozpoczecia;

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
          
        EXECUTE IMMEDIATE 
        'INSERT INTO grupy (id_klasy      ,  data_rozpoczecia     ,     id_wychowawcy)
        values      ('''||v_id_klasy||''' ,  :out_data_rozpoczecia, '|| out_id_wychowawcy || ')'
            USING out_data_rozpoczecia;     
    END LOOP;
    CLOSE c1;
    
    dbms_output.put_line('Stworzono '||in_ile_klas||' nowe klasy.'); 
END;

PROCEDURE proc_niezdanie IS

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
           OR (niezdana_klasa= 4 AND niezdana_klasa=substr(id_klasy,1,1))
           ;

        v_id_nowa_grupa INTEGER;
		
    BEGIN
        FOR w IN c1 LOOP    
        
            EXECUTE IMMEDIATE
            'SELECT id_grupy  
            FROM grupy 
            WHERE id_klasy = '''||w.niezdana_klasa||w.kierunek||''''
            INTO v_id_nowa_grupa;

            EXECUTE IMMEDIATE
            'UPDATE uczniowie
               SET
                id_grupy = '||v_id_nowa_grupa||
             'WHERE id_ucznia = '||w.id_ucznia;
        END LOOP;       
        
        dbms_output.put_line('Przeniesiono uczniów, którzy niezdali, o klasę niżej. ');
    END;    


    PROCEDURE proc_wpisanie_nowych_przedmiotow_grupa IS

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
            
            EXECUTE IMMEDIATE
            'SELECT g.id_klasy 
              FROM grupy        g
              JOIN uczniowie    u ON u.id_grupy = g.id_grupy
             WHERE id_ucznia = '||w.id_ucznia
             INTO v_id_klasy;

            OPEN c2 FOR 'SELECT ' || w.id_ucznia || ',   p.id_przedmiotu 
                                        FROM przedmioty_klasy pk
                                        RIGHT JOIN przedmioty p     ON p.id_przedmiotu = pk.id_przedmiotu
                                        WHERE id_klasy = ''' || v_id_klasy || '''  ';
            LOOP
                FETCH c2 INTO
                    v_id_ucznia, v_id_przedmiotu;
                EXIT WHEN c2%notfound;
                
                EXECUTE IMMEDIATE
                'INSERT INTO przedmioty_uczen ( id_ucznia      , id_przedmiotu) 
                        VALUES (             '||v_id_ucznia||' , '||v_id_przedmiotu||' )';
            END LOOP;
            CLOSE c2;
        END LOOP;
    END;
END po_koncu_roku;
/

CREATE OR REPLACE PROCEDURE proc_dodaj_osobe 
    (
          in_imie           dane_osobowe.imie%TYPE
        , in_nazwisko       dane_osobowe.nazwisko%TYPE
        , in_numer_telefonu dane_osobowe.numer_telefonu%TYPE
        , in_email          dane_osobowe.email%TYPE
        , in_adres          dane_osobowe.adres_zamieszkania%TYPE
        , in_data_urodzenia dane_osobowe.data_urodzenia%TYPE
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
        EXECUTE IMMEDIATE 
            'SELECT     pesel       , numer_telefonu        , email         , adres_zamieszkania    , rola
              FROM dane_osobowe
             WHERE pesel = '||in_pesel
                INTO    check_pesel , check_numer_telefonu  , check_email   , check_adres           , check_rola;

        EXCEPTION
            WHEN no_data_found THEN null; 
        END; 

        IF in_rola NOT IN ( 'k', 'u', 'n' ) 
        THEN dbms_output.put_line('Niepoprawna rola. Prosze wybrać k, u lub n.');
        RETURN;
        END IF;
        
        IF check_pesel IS NOT NULL THEN
            IF regexp_substr(check_rola, '' || in_rola || '{1}') IS NULL THEN
                EXECUTE IMMEDIATE
                'UPDATE dane_osobowe
                SET rola = ''rola'||in_rola||'''
                WHERE pesel = '||in_pesel;
                dbms_output.put_line('Dodano role do istniejacego rekordu');
                
            ELSE dbms_output.put_line('Osoba o identycznych danych istnieje już w bazie.');
            END IF;

            IF check_numer_telefonu <> in_numer_telefonu THEN
                EXECUTE IMMEDIATE
                'UPDATE dane_osobowe
                SET numer_telefonu = '||in_numer_telefonu||
                'WHERE pesel = '||in_pesel;
                dbms_output.put_line('Zaktualizowano numer telefonu.');
            END IF;

            IF check_email <> in_email THEN
                EXECUTE IMMEDIATE
                'UPDATE dane_osobowe
                SET email = :in_email
                WHERE pesel = '||in_pesel
                USING in in_email;
                dbms_output.put_line('Zaktualizowano adres email');
            END IF;

            IF check_adres <> in_adres THEN
                EXECUTE IMMEDIATE
                'UPDATE dane_osobowe
                SET adres_zamieszkania = :in_adres
                WHERE pesel = '||in_pesel
                USING in_email;
                dbms_output.put_line('Zaktualizowano adres zamieszkania');
            END IF;
            RETURN;
            
        ELSE 
        EXECUTE IMMEDIATE
        'INSERT INTO dane_osobowe ( imie    , nazwisko      , numer_telefonu     , email     , adres_zamieszkania , data_urodzenia      , pesel     , rola) 
        VALUES (                    :in_imie, :in_nazwisko  , :in_numer_telefonu , :in_email , :in_adres          , :in_data_urodzenia  , :in_pesel , :in_rola) '
        USING IN                    in_imie , in_nazwisko   , in_numer_telefonu  , in_email  , in_adres           , in_data_urodzenia   , in_pesel  , in_rola; 

        END IF;

    END;
/

CREATE OR REPLACE PROCEDURE proc_aktual_dane_osob (in_pesel INTEGER, in_kolumna VARCHAR2, in_aktualizacja VARCHAR2) IS
        check_pesel     INTEGER; 
        check_kolumna   VARCHAR2(40);
        
        check_constraint_violated EXCEPTION;
        PRAGMA exception_init ( check_constraint_violated, -2290 );
        
    BEGIN
        BEGIN
        EXECUTE IMMEDIATE 'SELECT pesel 
                            FROM dane_osobowe 
                            WHERE pesel = '||in_pesel 
                INTO check_pesel;
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Osoba o takim peselu nie istnieje w bazie.');
                RETURN;
        END;        
    
        BEGIN
            EXECUTE IMMEDIATE 'SELECT column_name 
                                FROM user_tab_columns
                                WHERE table_name like ''DANE_OSOBOWE'' and 
                                column_name  like  upper(''' || in_kolumna || ''')'
                    INTO check_kolumna;
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Nie ma takiego pola w tabeli DANE_OSOBOWE. ');
                RETURN;
        END; 
    BEGIN     
        EXECUTE IMMEDIATE 'UPDATE dane_osobowe 
                        SET '||in_kolumna||' = '''||in_aktualizacja||'''
                       WHERE pesel = '||in_pesel ; 
        dbms_output.put_line( 'Zaktualizowano pole '||in_kolumna||' o wartość '||in_aktualizacja|| ' dla osoby o peselu: '|| in_pesel||'.');
               
    EXCEPTION
            WHEN check_constraint_violated 
                THEN dbms_output.put_line('Constraints violation');
            WHEN OTHERS 
                THEN dbms_output.put_line('Inny blad - ' || sqlcode || ' : ' || sqlerrm);
    END;
END;
/

CREATE OR REPLACE PROCEDURE proc_usun_dane_osob (in_pesel INTEGER) IS
        check_pesel INTEGER;
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE 
            'SELECT pesel FROM dane_osobowe
             WHERE pesel = ' || in_pesel
              INTO check_pesel;
              
        EXCEPTION
            WHEN no_data_found 
                THEN dbms_output.put_line('Osoba o takim peselu nie istnieje w bazie.');
                RETURN;
        END; 

        EXECUTE IMMEDIATE 
        'delete FROM dane_osobowe 
        WHERE pesel = ' || in_pesel;
        dbms_output.put_line('Wszystkie dane osoby o peselu: ' || in_pesel || ' zostaly usuniete z bazy.');
        END;
/

CREATE OR REPLACE PROCEDURE proc_aktual_data_zakonczenia_uczen (in_pesel INTEGER, in_data_zakonczenia DATE) 
    IS
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
        WHERE id_dane_osobowe = (SELECT id_dane_osobowe FROM dane_osobowe WHERE pesel = '||in_pesel||')'
        USING IN in_data_zakonczenia, in_pesel;
        
        dbms_output.put_line('Uczniowi o peselu: ' || in_pesel || ' wpisano datę zakończenia nauki: ' || in_data_zakonczenia || '.');
    END;
/

CREATE OR REPLACE PROCEDURE proc_zmiana_kierunku (in_pesel INTEGER, in_nowy_kierunek VARCHAR2) IS
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
        'SELECT g.id_grupy        , g.id_klasy 
        FROM grupy g
        JOIN klasy k on  g.id_klasy = k.id_klasy 
        WHERE k.id_klasy like lower(substr('''||v_stara_klasa||''',1,1))||lower('''||in_nowy_kierunek||''')'
		INTO    out_nowa_grupa    , v_nowa_klasa; 

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
/
-- nauczyciele

CREATE OR REPLACE PROCEDURE proc_zmiana_wychowawcy (in_id_klasy VARCHAR2, in_id_wychowawcy INTEGER) IS

        v_id_grupy         INTEGER;
		
        check_grupa_daty   DATE;
        check_nauczyciele  INTEGER;
        check_wychowawcy   INTEGER;
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE
            'SELECT  id_grupy       , data_zakonczenia
            FROM grupy
            WHERE data_zakonczenia is null 
			AND id_klasy = '''||lower(in_id_klasy)||''''
            INTO  v_id_grupy , check_grupa_daty;

        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('Brak klasy o podanym id');
                RETURN;
        END;

        IF check_grupa_daty IS NOT NULL THEN 
            dbms_output.put_line('Klasa już skończyla szkole');
            RETURN;
        END IF;
        
        BEGIN
            EXECUTE IMMEDIATE
            'SELECT id_nauczyciela
            FROM nauczyciele
            WHERE id_nauczyciela = '||in_id_wychowawcy||'
            AND data_zakonczenia_pracy IS NOT NULL'
            INTO check_nauczyciele;

        EXCEPTION
            WHEN no_data_found THEN 
                dbms_output.put_line('Brak nauczyciela o podanym id.'); 
                RETURN; 
        END;
        
        BEGIN
        EXECUTE IMMEDIATE
        'SELECT id_wychowawcy
          FROM grupy
         WHERE data_zakonczenia IS NULL
           AND id_wychowawcy = '||in_id_wychowawcy
           INTO check_wychowawcy;
           
        EXCEPTION
            WHEN no_data_found THEN null; 
        END;        
     
        IF check_wychowawcy IS NOT NULL THEN 
            dbms_output.put_line('Nauczyciel jest obecnie wychowawca innej klasy. Prosze wybrac innego nauczyciela');
            RETURN;
        END IF;       
        
        EXECUTE IMMEDIATE 
        'UPDATE grupy
        SET id_wychowawcy = '||in_id_wychowawcy||' 
        WHERE id_grupy = '||v_id_grupy ;
                
        dbms_output.put_line('Wpisano nauczyciela o id: '||in_id_wychowawcy||' jako wychowawce klasy '||lower(in_id_klasy)||'. ');
    END;
/

CREATE OR REPLACE PROCEDURE obsadz_nauczyciela (nauczyciel INTEGER, przedmiot VARCHAR2, rozszerzenie BOOLEAN) AS 
            id INTEGER;
            nazwa VARCHAR2(30);
            sql_stmt VARCHAR2(400) := 'SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu LIKE '':p'' ';
            c SYS_REFCURSOR;
        BEGIN
            nazwa := przedmiot || '%';
            IF rozszerzenie THEN
                sql_stmt := sql_stmt || 'AND rozszerzenie IS NOT NULL';
            ELSE
                sql_stmt := sql_stmt || 'AND rozszerzenie IS NULL';
            END IF;

            OPEN c FOR sql_stmt USING nazwa;

            LOOP
                FETCH c INTO id;
                EXIT WHEN c%NOTFOUND;

                INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                    VALUES (nauczyciel, id);
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('nieprawidlowe dane!');
                RETURN;
            WHEN OTHERS THEN
                RAISE;
        END;
/

CREATE OR REPLACE FUNCTION policz_godziny_nauczyciela(in_nauczyciel INTEGER) RETURN INTEGER AS
        ilosc_godz INTEGER;
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT SUM(ilosc_przydzielonych_godzin) 
        FROM przydzielone_godziny
        WHERE id_nauczyciel_przedmiot IN (SELECT id_nauczyciel_przedmiot
                                        FROM nauczyciel_przedmiot
                                        WHERE id_nauczyciela = :nauczyciel)'
        INTO ilosc_godz USING in_nauczyciel ;
        RETURN ilosc_godz;
    END;
/

CREATE OR REPLACE PROCEDURE przydziel_godziny (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_klasa VARCHAR2) AS
        przedmiot_klasa INTEGER;
        ilosc_godzin INTEGER;
        max_godz INTEGER;
        przekroczono_max_godz EXCEPTION; 
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT id_przedmioty_klasy, ilosc_godzin_przedmiotu 
        FROM przedmioty_klasy 
        WHERE id_klasy = :klasa AND id_przedmiotu IN (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu LIKE '':p'')'
        INTO przedmiot_klasa, ilosc_godzin USING in_klasa, in_przedmiot || '%';

        EXECUTE IMMEDIATE
        'SELECT max_godz_tyg
        FROM nauczyciele
        WHERE id_nauczyciela = :nauczyciel'
        INTO max_godz USING in_nauczyciel;

        IF max_godz < (ilosc_godzin + policz_godziny_nauczyciela(in_nauczyciel)) THEN
            RAISE przekroczono_max_godz;
        END IF;

        EXECUTE IMMEDIATE
        'UPDATE przydzielone_godziny
        SET id_nauczyciel_przedmiot = :nauczyciel
        WHERE id_przedmioty_klasy = :przedmiot_klasa'
        USING in_nauczyciel, przedmiot_klasa;

    EXCEPTION
        WHEN przekroczono_max_godz THEN
            DBMS_OUTPUT.PUT_LINE('nie mozna przekroczyc maksymalnej liczby godzin!');
            RETURN;
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowa nazwa przedmiotu lub id klasy!');
            RETURN;
        WHEN OTHERS THEN
            RAISE;
    END; 
/

CREATE OR REPLACE PROCEDURE usun_przedmiot_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN) AS
        check_count INTEGER;
        brak_danych EXCEPTION;
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT COUNT(*) into v_count
        FROM nauczyciel_przedmiot
        WHERE id_nauczyciela = in_nauczyciel AND przedmiot LIKE '':p'''
        INTO check_count USING in_przedmiot || '%';  

        IF  check_count = 0 THEN
            RAISE brak_danych;
        END IF;

        IF in_rozszerzenie THEN
            EXECUTE IMMEDIATE
            'DELETE nauczyciel_przedmiot 
            WHERE id_nauczyciela = ' || in_nauczyciel || ' AND przedmiot LIKE ''' || in_przedmiot || '''% AND rozszerzenie IS NOT NULL';
        ELSE
            EXECUTE IMMEDIATE
            'DELETE nauczyciel_przedmiot 
            WHERE id_nauczyciela = ' || in_nauczyciel || ' AND przedmiot LIKE ''' || in_przedmiot || '''% AND rozszerzenie IS NULL';
        END IF;

    EXCEPTION
        WHEN brak_danych THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowa nazwa przedmiotu lub id nauczyciela!');
            RETURN;
        WHEN others THEN
            RAISE;
    END;
/

CREATE OR REPLACE PROCEDURE usun_przydzielone_godz (in_przedmiot VARCHAR2, in_klasa VARCHAR2) AS
        przedmiot_klasa INTEGER;
        ilosc_godzin INTEGER;
        nauczyciel_przedmiot INTEGER;
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT id_przedmioty_klasy
        FROM przedmioty_klasy 
        WHERE id_klasy = :klasa AND id_przedmiotu = (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu = :przedmiot)'
        INTO przedmiot_klasa USING in_klasa, in_przedmiot;
        
        EXECUTE IMMEDIATE
        'SELECT ilosc_przydzielonych_godzin
        FROM przydzielone_godziny
        WHERE id_przedmioty_klasy = :przedmiot_klasa'
        INTO ilosc_godzin USING przedmiot_klasa;

        EXECUTE IMMEDIATE
        'UPDATE przydzielone_godziny
        SET id_nauczyciel_przedmiot = NULL
        WHERE id_przedmioty_klasy = :przedmiot_klasa'
        USING przedmiot_klasa;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowa nazwa przedmiotu lub id klasy!');
            RETURN;
        WHEN OTHERS THEN
            RAISE;
    END;
/

CREATE OR REPLACE PROCEDURE zakoncz_prace (in_nauczyciel INTEGER, in_data_zakonczenia DATE) AS
        data_rozpoczecia DATE;
        niepoprawna_data EXCEPTION;
        nauczyciel_jest_wychowawca EXCEPTION;
        grupa INTEGER := -1;
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT data_rozpoczecia_pracy INTO data_rozpoczecia
        FROM nauczyciele 
        WHERE id_nauczyciela = :nauczyciel'
        INTO data_rozpoczecia USING in_nauczyciel;

        IF in_data_zakonczenia <  data_rozpoczecia THEN
            RAISE niepoprawna_data;
        END IF;

        EXECUTE IMMEDIATE
        'SELECT id_grupy INTO grupa
        FROM grupy
        WHERE id_wychowawcy = :nauczyciel AND data_zakonczenia > SYSDATE'
        INTO grupa USING in_nauczyciel;

        IF grupa <> -1 THEN
            RAISE nauczyciel_jest_wychowawca;
        END IF;
        
        EXECUTE IMMEDIATE
        'UPDATE przydzielone_godziny
        SET ilosc_przydzielonych_godzin = NULL
        WHERE id_nauczyciel_przedmiot IN (SELECT id_nauczyciel_przedmiot FROM nauczyciel_przedmiot WHERE id_nauczyciela = :nauczyciel)'
        USING in_nauczyciel;

        EXECUTE IMMEDIATE
        'UPDATE nauczyciele
        SET data_zakonczenia_pracy = :data_zakonczenia,
            max_godz_tyg = NULL
        WHERE id_nauczyciela = :nauczyciel'
        USING in_data_zakonczenia, in_nauczyciel;

    EXCEPTION
        WHEN niepoprawna_data THEN
            DBMS_OUTPUT.PUT_LINE('data zakonczenia nie moze byc mniejsza od daty rozpoczecia!');
            RETURN;
        WHEN nauczyciel_jest_wychowawca THEN
            DBMS_OUTPUT.PUT_LINE('nauczyciel jest aktualnie wychowawcą!');
            RETURN;
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowe id nauczyciela!');
            RETURN;
        WHEN OTHERS THEN
            RAISE;
    END;
/

CREATE OR REPLACE PROCEDURE zmien_max_godz (in_nauczyciel INTEGER, in_max_godz INTEGER) AS
        nieprawidlowe_godziny EXCEPTION;
        nauczyciel_nie_istnieje EXCEPTION;
    BEGIN
        IF in_max_godz < policz_godziny_nauczyciela(in_nauczyciel) THEN
            RAISE nieprawidlowe_godziny;
        END IF;

        EXECUTE IMMEDIATE
        'UPDATE nauczyciele
        SET max_godz_tyg = :max_godz
        WHERE id_nauczyciela = :nauczyciel'
        USING in_max_godz, in_nauczyciel;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE nauczyciel_nie_istnieje;
        END IF;

    EXCEPTION
        WHEN nieprawidlowe_godziny THEN
            DBMS_OUTPUT.PUT_LINE('liczba maksymalnych godzin nie może być mniejsza niż liczba przydzielonych godzin!');
            RETURN;
        WHEN nauczyciel_nie_istnieje THEN
            DBMS_OUTPUT.PUT_LINE('nieprawidlowe id nauczyciela!');
        WHEN OTHERS THEN
            RAISE;
    END;
/

CREATE OR REPLACE PROCEDURE obsadz_nauczyciela (in_nauczyciel INTEGER, in_przedmiot VARCHAR2, in_rozszerzenie BOOLEAN) AS 
            id INTEGER;
            nazwa VARCHAR2(30);
            sql_stmt VARCHAR2(400) := 'SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu LIKE '':p'' ';
            c SYS_REFCURSOR;
        BEGIN
            nazwa := in_przedmiot || '%';
            IF in_rozszerzenie THEN
                sql_stmt := sql_stmt || 'AND rozszerzenie IS NOT NULL';
            ELSE
                sql_stmt := sql_stmt || 'AND rozszerzenie IS NULL';
            END IF;

            OPEN c FOR sql_stmt USING nazwa;

            LOOP
                FETCH c INTO id;
                EXIT WHEN c%NOTFOUND;

                INSERT INTO nauczyciel_przedmiot (id_nauczyciela, id_przedmiotu)
                    VALUES (in_nauczyciel, id);
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('nieprawidlowe dane!');
                RETURN;
            WHEN OTHERS THEN
                RAISE;
        END;
/

CREATE OR REPLACE PROCEDURE pokaz_wolnych_nauczycieli (in_przedmiot VARCHAR2, in_klasa VARCHAR2) AS
        godziny INTEGER;
        check_rozszerzenie VARCHAR2(1);
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT ilosc_godzin_przedmiotu, rozszerzenie 
        FROM przedmioty_klasy
        JOIN przedmioty USING (id_przedmiotu)
        WHERE id_klasy = :klasa AND id_przedmiotu IN (SELECT id_przedmiotu FROM przedmioty WHERE nazwa_przedmiotu = :przedmiot)'
        INTO godziny, check_rozszerzenie USING in_klasa, in_przedmiot;

        DECLARE
            CURSOR cur IS
                SELECT id_nauczyciela, imie, nazwisko, max_godz_tyg
                FROM nauczyciel_przedmiot
                JOIN nauczyciele USING (id_nauczyciela)
                JOIN dane_osobowe USING (id_dane_osobowe)
                Join przedmioty USING (id_przedmiotu)
                WHERE nazwa_przedmiotu = in_przedmiot
                AND rozszerzenie = check_rozszerzenie;
        BEGIN
            DBMS_OUTPUT.PUT_LINE('dostepni nauczyciele:');
            DBMS_OUTPUT.PUT_LINE('id_nauczyciela. imie nazwisko');

            FOR rec IN cur LOOP
                IF (rec.max_godz_tyg - policz_godziny_nauczyciela(rec.id_nauczyciela)) >= godziny THEN
                    dbms_output.put_line(rec.id_nauczyciela || '. ' || rec.imie || ' ' || rec.nazwisko);
                END IF;
            END LOOP;
        END;
    END;