-- drop existing tables --

DECLARE
    PROCEDURE drop_if_exists (table_name VARCHAR2) IS
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || table_name || ' CASCADE CONSTRAINTS';
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN
                RAISE;
                END IF;
        END;
BEGIN
    drop_if_exists ('dane_osobowe');
    drop_if_exists ('grupy');
    drop_if_exists ('klasy');
    drop_if_exists ('nauczyciel_przedmiot');
    drop_if_exists ('nauczyciele');
    drop_if_exists ('oceny'); 
    drop_if_exists ('przedmioty');
    drop_if_exists ('przedmioty_klasy');
    drop_if_exists ('przedmioty_uczen');
    drop_if_exists ('przydzielone_godziny');
    drop_if_exists ('uczniowie');
    drop_if_exists ('rok_szkolny');
END;
/

-- create tables --

CREATE TABLE dane_osobowe (
    id_dane_osobowe    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imie               VARCHAR2(60) NOT NULL,
    nazwisko           VARCHAR2(120) NOT NULL,
    numer_telefonu     VARCHAR2(20) NOT NULL,
    email  		       VARCHAR2(50) NOT NULL,
    adres_zamieszkania VARCHAR2(255),
    data_urodzenia     DATE,
    pesel              VARCHAR2(11) NOT NULL,
	rola               VARCHAR2(3), 
    CONSTRAINT sprawdz_telefon CHECK (REGEXP_LIKE(numer_telefonu, '(^[+][[:digit:]]{1,4})?[[:digit:]]{9,}')),
    CONSTRAINT sprawdz_mail CHECK (REGEXP_LIKE(email, '^([a-zA-Z0-9_.-]*)@([a-zA-Z0-9_.-]*).([a-zA-Z]{2,5})$')),
	CONSTRAINT sprawdz_role CHECK (rola in ('k', 'n', 'ku', 'kn', 'kun'))
);

CREATE TABLE nauczyciele (
    id_nauczyciela         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_dane_osobowe        INTEGER NOT NULL,
    data_rozpoczecia_pracy DATE NOT NULL,
    data_zakonczenia_pracy DATE,
    max_godz_tyg           INTEGER DEFAULT 40, 
    CONSTRAINT nauczyciele_dane_osobowe_fk FOREIGN KEY (id_dane_osobowe) 
        REFERENCES dane_osobowe (id_dane_osobowe) ON DELETE CASCADE
);

CREATE TABLE klasy (
    id_klasy       VARCHAR2(2 CHAR) PRIMARY KEY,
    nazwa_kierunku VARCHAR2(50 CHAR) NOT NULL
);

CREATE TABLE przedmioty (
    id_przedmiotu    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa_przedmiotu VARCHAR2(100) NOT NULL,
    rozszerzenie     CHAR(1 CHAR),
	CONSTRAINT sprawdz_rozszerzenie CHECK ( rozszerzenie = 'R' )
);

CREATE TABLE grupy (
    id_grupy         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_klasy         VARCHAR2(2 CHAR) NOT NULL,
    data_rozpoczecia DATE NOT NULL,
    data_zakonczenia DATE,
    id_wychowawcy 	 INTEGER NOT NULL,
    CONSTRAINT grupy_klasy_fk FOREIGN KEY ( id_klasy ) 
        REFERENCES klasy ( id_klasy ),
    CONSTRAINT grupy_nauczyciele_fk FOREIGN KEY ( id_wychowawcy ) 
        REFERENCES nauczyciele ( id_nauczyciela )
);

CREATE TABLE uczniowie (
    id_ucznia              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_dane_osobowe        INTEGER NOT NULL,
    data_rozpoczecia_nauki DATE NOT NULL,
    data_zakonczenia_nauki DATE,
    id_grupy               INTEGER NOT NULL,
    CONSTRAINT uczniowie_grupy_fk FOREIGN KEY ( id_grupy )
        REFERENCES grupy ( id_grupy ),
    CONSTRAINT uczniowie_dane_osobowe_fk FOREIGN KEY ( id_dane_osobowe )
        REFERENCES dane_osobowe ( id_dane_osobowe )
		ON DELETE CASCADE
);

CREATE TABLE nauczyciel_przedmiot (
    id_nauczyciel_przedmiot INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_nauczyciela          INTEGER NOT NULL,
    id_przedmiotu           INTEGER NOT NULL,
    CONSTRAINT naucz_przedmiot_naucz_fk FOREIGN KEY ( id_nauczyciela ) 
        REFERENCES nauczyciele ( id_nauczyciela ),
    CONSTRAINT naucz_przedmiot_przedmioty_fk FOREIGN KEY ( id_przedmiotu ) 
        REFERENCES przedmioty ( id_przedmiotu )
);

CREATE TABLE przedmioty_uczen (
    id_przedmioty_uczen INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_ucznia                INTEGER NOT NULL,
    id_przedmiotu            INTEGER NOT NULL,
	srednia_ocen             NUMBER(3,2),
    ocena_koncowa            INTEGER	,
	CONSTRAINT zakres_oceny_koncowej CHECK (ocena_koncowa IN (1,2,3,4,5,6)),

    CONSTRAINT przedmioty_uczen_przedmioty_fk FOREIGN KEY ( id_przedmiotu )
        REFERENCES przedmioty ( id_przedmiotu ),
    CONSTRAINT przedmioty_uczen_uczen_fk FOREIGN KEY ( id_ucznia )
        REFERENCES uczniowie ( id_ucznia )
);

CREATE TABLE oceny (
    id_oceny                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_przedmioty_uczen      INTEGER NOT NULL,
    ocena                    NUMBER(2,1) NOT NULL,
    timestamp_oceny          TIMESTAMP NOT NULL,
	CONSTRAINT zakres_oceny CHECK (ocena IN (1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6)),
    CONSTRAINT oceny_przedmioty_uczen_fk FOREIGN KEY ( id_przedmioty_uczen ) 
        REFERENCES przedmioty_uczen ( id_przedmioty_uczen )
);

CREATE TABLE przedmioty_klasy (
    id_przedmioty_klasy     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_klasy                VARCHAR2(2) NOT NULL,
    id_przedmiotu           INTEGER NOT NULL,
    ilosc_godzin_przedmiotu INTEGER NOT NULL,
    CONSTRAINT przedmioty_klasy_klasy_fk FOREIGN KEY ( id_klasy )
        REFERENCES klasy ( id_klasy ),
    CONSTRAINT przedmioty_klasy_przedmioty_fk FOREIGN KEY ( id_przedmiotu )
        REFERENCES przedmioty ( id_przedmiotu )
);

CREATE TABLE przydzielone_godziny (
    id_przydzielonych_godzin    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_nauczyciel_przedmiot     INTEGER,
    id_przedmioty_klasy         INTEGER NOT NULL,
    ilosc_przydzielonych_godzin INTEGER NOT NULL,
    CONSTRAINT przydz_godz_naucz_przed_fk FOREIGN KEY ( id_nauczyciel_przedmiot )
        REFERENCES nauczyciel_przedmiot ( id_nauczyciel_przedmiot )
		ON DELETE SET NULL,
    CONSTRAINT przydz_godz_przed_klasy_fk FOREIGN KEY ( id_przedmioty_klasy )
        REFERENCES przedmioty_klasy ( id_przedmioty_klasy )
);

CREATE TABLE rok_szkolny (
    id_rs                   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data_rozpoczecia        DATE NOT NULL , 
    data_zakonczenia        DATE
);