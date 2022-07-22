-- drop existing tables --

DROP TABLE dane_osobowe CASCADE CONSTRAINTS;
DROP TABLE grupy CASCADE CONSTRAINTS;
DROP TABLE klasy CASCADE CONSTRAINTS;
DROP TABLE nauczyciel_przedmiot CASCADE CONSTRAINTS;
DROP TABLE nauczyciele CASCADE CONSTRAINTS;
DROP TABLE oceny CASCADE CONSTRAINTS; 
DROP TABLE przedmioty CASCADE CONSTRAINTS;
DROP TABLE przedmioty_klasy CASCADE CONSTRAINTS;
DROP TABLE przedmioty_uczen CASCADE CONSTRAINTS;
DROP TABLE przydzielone_godziny CASCADE CONSTRAINTS; 
DROP TABLE uczniowie CASCADE CONSTRAINTS; 

-- create tables with primary keys --

CREATE TABLE dane_osobowe (
    id_dane_osobowe    INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    imie               VARCHAR2(60) NOT NULL,
    nazwisko           VARCHAR2(120) NOT NULL,
    numer_telefonu     VARCHAR2(20) NOT NULL,
    email  		       VARCHAR2(50) NOT NULL,
    adres_zamieszkania VARCHAR2(255),
    data_urodzenia     DATE,
    pesel              INTEGER
);

ALTER TABLE dane_osobowe ADD CONSTRAINT dane_osobowe_pk PRIMARY KEY ( id_dane_osobowe );

CREATE TABLE grupy (
    id_grupy         INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_klasy         VARCHAR2(2 CHAR) NOT NULL,
    data_rozpoczecia DATE NOT NULL,
    data_zakonczenia DATE,
    id_wychowawcy 	 INTEGER NOT NULL
);

ALTER TABLE grupy ADD CONSTRAINT grupy_pk PRIMARY KEY ( id_grupy );

CREATE TABLE klasy (
    id_klasy       VARCHAR2(2 CHAR) NOT NULL,
    nazwa_kierunku VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE klasy ADD CONSTRAINT klasy_pk PRIMARY KEY ( id_klasy );

CREATE TABLE nauczyciel_przedmiot (
    id_nauczyciel_przedmiot INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_nauczyciela          INTEGER NOT NULL,
    id_przedmiotu           INTEGER NOT NULL
);

ALTER TABLE nauczyciel_przedmiot ADD CONSTRAINT nauczyciel_przedmiot_pk PRIMARY KEY ( id_nauczyciel_przedmiot );

CREATE TABLE nauczyciele (
    id_nauczyciela         INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_dane_osobowe        INTEGER NOT NULL,
    data_rozpoczecia_pracy DATE NOT NULL,
    data_zakonczenia_pracy DATE,
    max_godz_tyg           INTEGER DEFAULT 40 
);

ALTER TABLE nauczyciele ADD CONSTRAINT nauczyciele_pk PRIMARY KEY ( id_nauczyciela );

CREATE TABLE oceny (
    id_oceny                 INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_pary_przedmioty_uczen INTEGER NOT NULL,
    ocena                    NUMBER(2,1) NOT NULL,
    timestamp_oceny          TIMESTAMP NOT NULL,
	
	CONSTRAINT zakres_oceny CHECK (ocena IN (1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6))
);

ALTER TABLE oceny ADD CONSTRAINT oceny_pk PRIMARY KEY ( id_oceny );

CREATE TABLE przedmioty (
    id_przedmiotu    INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    nazwa_przedmiotu VARCHAR2(100) NOT NULL,
    rozszerzenie     CHAR(1 CHAR),
	
	CONSTRAINT sprawdz_rozszerzenie CHECK ( rozszerzenie = 'R' )
);

ALTER TABLE przedmioty ADD CONSTRAINT przedmioty_pk PRIMARY KEY ( id_przedmiotu );

CREATE TABLE przedmioty_klasy (
    id_przedmioty_klasy     INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_klasy                VARCHAR2(2) NOT NULL,
    id_przedmiotu           INTEGER NOT NULL,
    ilosc_godzin_przedmiotu INTEGER NOT NULL
);

ALTER TABLE przedmioty_klasy ADD CONSTRAINT przedmioty_klasy_pk PRIMARY KEY ( id_przedmioty_klasy );

CREATE TABLE przedmioty_uczen (
    id_pary_przedmioty_uczen INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_ucznia                INTEGER NOT NULL,
    id_przedmiotu            INTEGER NOT NULL,
    ocena_koncowa            INTEGER	,
	
	CONSTRAINT zakres_oceny_koncowej CHECK (ocena_koncowa IN (1,2,3,4,5,6))
);

ALTER TABLE przedmioty_uczen ADD CONSTRAINT przedmioty_uczen_pk PRIMARY KEY ( id_pary_przedmioty_uczen );

CREATE TABLE przydzielone_godziny (
    id_przydzielonych_godzin    INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_nauczyciel_przedmiot     INTEGER NOT NULL,
    id_przedmioty_klasy         INTEGER NOT NULL,
    ilosc_przydzielonych_godzin INTEGER NOT NULL
);

ALTER TABLE przydzielone_godziny ADD CONSTRAINT przydzielone_godziny_pk PRIMARY KEY ( id_przydzielonych_godzin );

CREATE TABLE uczniowie (
    id_ucznia              INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_dane_osobowe        INTEGER NOT NULL,
    data_rozpoczecia_nauki DATE NOT NULL,
    data_zakonczenia_nauki DATE,
    id_grupy               INTEGER NOT NULL
);

ALTER TABLE uczniowie ADD CONSTRAINT uczniowie_pk PRIMARY KEY ( id_ucznia );

-- add foraign keys --

ALTER TABLE grupy
    ADD CONSTRAINT grupy_klasy_fk FOREIGN KEY ( id_klasy )
        REFERENCES klasy ( id_klasy );

ALTER TABLE grupy
    ADD CONSTRAINT grupy_nauczyciele_fk FOREIGN KEY ( id_wychowawcy )
        REFERENCES nauczyciele ( id_nauczyciela );

ALTER TABLE nauczyciel_przedmiot
    ADD CONSTRAINT naucz_przedmiot_naucz_fk FOREIGN KEY ( id_nauczyciela )
        REFERENCES nauczyciele ( id_nauczyciela );

ALTER TABLE nauczyciel_przedmiot
    ADD CONSTRAINT naucz_przedmiot_przedmioty_fk FOREIGN KEY ( id_przedmiotu )
        REFERENCES przedmioty ( id_przedmiotu );

ALTER TABLE nauczyciele
    ADD CONSTRAINT nauczyciele_dane_osobowe_fk FOREIGN KEY ( id_dane_osobowe )
        REFERENCES dane_osobowe ( id_dane_osobowe )
		ON DELETE CASCADE; -- np usuniecie jak ktos chce przez rodo 

ALTER TABLE oceny
    ADD CONSTRAINT oceny_przedmioty_uczen_fk FOREIGN KEY ( id_pary_przedmioty_uczen )
        REFERENCES przedmioty_uczen ( id_pary_przedmioty_uczen );

ALTER TABLE przedmioty_klasy
    ADD CONSTRAINT przedmioty_klasy_klasy_fk FOREIGN KEY ( id_klasy )
        REFERENCES klasy ( id_klasy );

ALTER TABLE przedmioty_klasy
    ADD CONSTRAINT przedmioty_klasy_przedmioty_fk FOREIGN KEY ( id_przedmiotu )
        REFERENCES przedmioty ( id_przedmiotu );

ALTER TABLE przedmioty_uczen
    ADD CONSTRAINT przedmioty_uczen_przedmioty_fk FOREIGN KEY ( id_przedmiotu )
        REFERENCES przedmioty ( id_przedmiotu );

ALTER TABLE przedmioty_uczen
    ADD CONSTRAINT przedmioty_uczen_uczen_fk FOREIGN KEY ( id_ucznia )
        REFERENCES uczniowie ( id_ucznia );

ALTER TABLE przydzielone_godziny
    ADD CONSTRAINT przydz_godz_naucz_przed_fk FOREIGN KEY ( id_nauczyciel_przedmiot )
        REFERENCES nauczyciel_przedmiot ( id_nauczyciel_przedmiot )
		ON DELETE SET NULL;

ALTER TABLE przydzielone_godziny
    ADD CONSTRAINT przydz_godz_przed_klasy_fk FOREIGN KEY ( id_przedmioty_klasy )
        REFERENCES przedmioty_klasy ( id_przedmioty_klasy );

ALTER TABLE uczniowie
    ADD CONSTRAINT uczniowie_grupy_fk FOREIGN KEY ( id_grupy )
        REFERENCES grupy ( id_grupy );


ALTER TABLE uczniowie
    ADD CONSTRAINT uczniowie_dane_osobowe_fk FOREIGN KEY ( id_dane_osobowe )
        REFERENCES dane_osobowe ( id_dane_osobowe )
		ON DELETE CASCADE; -- np usuniecie jak ktos chce przez rodo 