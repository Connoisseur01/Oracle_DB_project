CREATE OR REPLACE PACKAGE populate AS
    PROCEDURE pop_przedmioty;
    PROCEDURE pop_klasy;
    PROCEDURE pop_uczniowie;
    PROCEDURE obsadz_nauczyciela (nauczyciel INTEGER, przedmiot VARCHAR2, rozszerzenie BOOLEAN);
    PROCEDURE przydziel_godz (id_naucz INTEGER, przedmiot VARCHAR2, id_klas VARCHAR2);
    PROCEDURE pop_przedmiot_uczen;
    PROCEDURE pop_oceny;
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
            
            v_polecenie VARCHAR2(200) := ' as stala,   p.id_przedmiotu 
                                        FROM przedmioty_klasy pk
                                        RIGHT JOIN przedmioty p 	ON p.id_przedmiotu = pk.id_przedmiotu
                                        WHERE id_klasy ';
            vsql VARCHAR2(2000);
        BEGIN 
            FOR i IN 1..360 LOOP
	
                SELECT id_klasy INTO id_klasy
                FROM grupy  
                JOIN uczniowie USING (id_grupy)
                WHERE id_dane_osobowe = i;


                IF LPAD(id_klasy,1)=1 THEN
                vsql := 'SELECT ' ||i || '= ''' || id_klasy || '''  ';

                ELSIF LPAD(id_klasy,1)=2 THEN 
                vsql := 'SELECT ' || i || 'in  (''' || id_klasy || ''', ''' ||
                                    to_char(TO_NUMBER(SUBSTR(id_klasy,1,1))-1 || SUBSTR(id_klasy,2,1)) || ''') '; 

                ELSIF LPAD(id_klasy,1)=3 THEN
                vsql := 'SELECT ' || i || 'in  (''' || id_klasy || ''', ''' ||
                                    TO_CHAR(TO_NUMBER(SUBSTR(id_klasy,1,1))-1 || SUBSTR(id_klasy,2,1)) || ''', ''' ||
                                    TO_CHAR(TO_NUMBER(SUBSTR(id_klasy,1,1))-2 || SUBSTR(id_klasy,2,1)) || ''') '; 
                        
                ELSIF LPAD(id_klasy,1)=4 THEN
                vsql := 'SELECT ' || i || 'in  (''' || id_klasy || ''', ''' ||
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
END populate;
/