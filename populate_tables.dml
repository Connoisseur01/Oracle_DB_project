-- wylacz klucze obce

BEGIN
  FOR c IN
    (SELECT constraint_name, table_name
   FROM user_constraints
   WHERE status = 'ENABLED' AND constraint_type = 'R')
  LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' DISABLE CONSTRAINT ' || c.constraint_name;
  END LOOP;
END;
/


-- dane osobowe 

host sqlldr userid = szkola/szkola@XEPDB1 control = 'ctrl_files\dane_osobowe.ctl' log = track.log;

-- nauczyciele

host sqlldr userid = szkola/szkola@XEPDB1 control = 'ctrl_files\nauczyciele.ctl' log = track.log;

-- przedmioty

EXECUTE populate.pop_przedmioty;

-- klasy --

EXECUTE populate.pop_klasy;

--przedmioty_klasy

host sqlldr userid = szkola/szkola@XEPDB1 control = 'ctrl_files\przedmioty_klasy.ctl' log = track.log;

--grupy

host sqlldr userid = szkola/szkola@XEPDB1 control = 'ctrl_files\grupy.ctl' log = track.log;

--uczniowie

EXECUTE populate.pop_uczniowie;

-- nauczyciel_przedmiot
--matematyka

EXECUTE populate.obsadz_nauczyciela(7, 'matematyka', true);
EXECUTE populate.obsadz_nauczyciela(19, 'matematyka', true);
EXECUTE populate.obsadz_nauczyciela(26, 'matematyka', false);

--polski

EXECUTE populate.obsadz_nauczyciela(13, 'polski', true);
EXECUTE populate.obsadz_nauczyciela(10, 'polski', false);

--historia

EXECUTE populate.obsadz_nauczyciela(3, 'historia', true);
EXECUTE populate.obsadz_nauczyciela(8, 'historia', false);

--fizyka

EXECUTE populate.obsadz_nauczyciela(4, 'fizyka', true);

--angielski

EXECUTE populate.obsadz_nauczyciela(1, 'angielski', true);
EXECUTE populate.obsadz_nauczyciela(9, 'angielski', true);

-- wf

EXECUTE populate.obsadz_nauczyciela(14, 'wychowanie_fizyczne', false);
EXECUTE populate.obsadz_nauczyciela(30, 'wychowanie_fizyczne', false);

--biologia

EXECUTE populate.obsadz_nauczyciela(17, 'biologia', true);

--chemia

EXECUTE populate.obsadz_nauczyciela(20, 'chemia', true);

--geografia

EXECUTE populate.obsadz_nauczyciela(23, 'geografia', true);

--niemiecki

EXECUTE populate.obsadz_nauczyciela(27, 'niemiecki', true);

--informatyka

EXECUTE populate.obsadz_nauczyciela(15, 'informatyka', true);
    
-- byli nauczyciele

EXECUTE populate.obsadz_nauczyciela(2, 'polski', true);
EXECUTE populate.obsadz_nauczyciela(11, 'biologia', true);
EXECUTE populate.obsadz_nauczyciela(12, 'informatyka', true);
EXECUTE populate.obsadz_nauczyciela(16, 'historia', false);
EXECUTE populate.obsadz_nauczyciela(22, 'polski', true);
EXECUTE populate.obsadz_nauczyciela(24, 'wychowanie_fizyczne', false);
EXECUTE populate.obsadz_nauczyciela(28, 'fizyka', true);
EXECUTE populate.obsadz_nauczyciela(29, 'matematyka', false);
EXECUTE populate.obsadz_nauczyciela(31, 'niemiecki', true);
EXECUTE populate.obsadz_nauczyciela(32, 'angielski', false);
EXECUTE populate.obsadz_nauczyciela(33, 'angielski', true);
EXECUTE populate.obsadz_nauczyciela(34, 'historia', false);
EXECUTE populate.obsadz_nauczyciela(36, 'informatyka', false);
EXECUTE populate.obsadz_nauczyciela(37, 'polski', false);
EXECUTE populate.obsadz_nauczyciela(5, 'fizyka', true);
EXECUTE populate.obsadz_nauczyciela(35, 'fizyka', true);
EXECUTE populate.obsadz_nauczyciela(18, 'biologia', false);
EXECUTE populate.obsadz_nauczyciela(21, 'chemia', true);
EXECUTE populate.obsadz_nauczyciela(25, 'geografia', false);
EXECUTE populate.obsadz_nauczyciela(6, 'informatyka', true);

-- przydzielone godziny --


    --matematyka --

    -- mat-fiz
EXECUTE populate.przydziel_godz(7, 'matematyka', '1a');
EXECUTE populate.przydziel_godz(7, 'matematyka', '2a');
EXECUTE populate.przydziel_godz(7, 'matematyka', '3a');
EXECUTE populate.przydziel_godz(7, 'matematyka', '4a');

    -- biol-hem
EXECUTE populate.przydziel_godz(26, 'matematyka', '1b');
EXECUTE populate.przydziel_godz(26, 'matematyka', '2b');
EXECUTE populate.przydziel_godz(26, 'matematyka', '3b');
EXECUTE populate.przydziel_godz(26, 'matematyka', '4b');

    -- ekonomiczna
EXECUTE populate.przydziel_godz(19, 'matematyka', '1c');
EXECUTE populate.przydziel_godz(19, 'matematyka', '2c');
EXECUTE populate.przydziel_godz(19, 'matematyka', '3c');
EXECUTE populate.przydziel_godz(19, 'matematyka', '4c');

    -- humanistyczna
EXECUTE populate.przydziel_godz(26, 'matematyka', '1d');
EXECUTE populate.przydziel_godz(26, 'matematyka', '2d');
EXECUTE populate.przydziel_godz(26, 'matematyka', '3d');
EXECUTE populate.przydziel_godz(26, 'matematyka', '4d');

    -- polski

    -- mat-fiz
EXECUTE populate.przydziel_godz(10, 'polski', '1a');
EXECUTE populate.przydziel_godz(10, 'polski', '2a');
EXECUTE populate.przydziel_godz(10, 'polski', '3a');
EXECUTE populate.przydziel_godz(10, 'polski', '4a');

    -- biol-hem
EXECUTE populate.przydziel_godz(10, 'polski', '1b');
EXECUTE populate.przydziel_godz(10, 'polski', '2b');
EXECUTE populate.przydziel_godz(10, 'polski', '3b');
EXECUTE populate.przydziel_godz(10, 'polski', '4b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(10, 'polski', '1c');
EXECUTE populate.przydziel_godz(10, 'polski', '2c');
EXECUTE populate.przydziel_godz(13, 'polski', '3c');
EXECUTE populate.przydziel_godz(13, 'polski', '4c');

    -- humanistyczna
EXECUTE populate.przydziel_godz(13, 'polski', '1d');
EXECUTE populate.przydziel_godz(13, 'polski', '2d');
EXECUTE populate.przydziel_godz(13, 'polski', '3d');
EXECUTE populate.przydziel_godz(13, 'polski', '4d');

    --historia

    --mat-fiz
EXECUTE populate.przydziel_godz(8, 'historia', '1a');
EXECUTE populate.przydziel_godz(8, 'historia', '2a');
EXECUTE populate.przydziel_godz(8, 'historia', '3a');
EXECUTE populate.przydziel_godz(8, 'historia', '4a');

    --biol-hem
EXECUTE populate.przydziel_godz(8, 'historia', '1b');
EXECUTE populate.przydziel_godz(8, 'historia', '2b');
EXECUTE populate.przydziel_godz(8, 'historia', '3b');
EXECUTE populate.przydziel_godz(8, 'historia', '4b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(8, 'historia', '1c');
EXECUTE populate.przydziel_godz(8, 'historia', '2c');
EXECUTE populate.przydziel_godz(8, 'historia', '3c');
EXECUTE populate.przydziel_godz(8, 'historia', '4c');

    --humanistyczna
EXECUTE populate.przydziel_godz(3, 'historia', '1d');
EXECUTE populate.przydziel_godz(3, 'historia', '2d');
EXECUTE populate.przydziel_godz(3, 'historia', '3d');
EXECUTE populate.przydziel_godz(3, 'historia', '4d');
    
    -- fizyka

    --mat-fiz
EXECUTE populate.przydziel_godz(4, 'fizyka', '1a');
EXECUTE populate.przydziel_godz(4, 'fizyka', '2a');
EXECUTE populate.przydziel_godz(4, 'fizyka', '3a');
EXECUTE populate.przydziel_godz(4, 'fizyka', '4a');

    --biol-hem
EXECUTE populate.przydziel_godz(4, 'fizyka', '1b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(4, 'fizyka', '1c');

    --humanistyczna
EXECUTE populate.przydziel_godz(4, 'fizyka', '1d');
    
    
    --angielski

    --mat-fiz
EXECUTE populate.przydziel_godz(1, 'angielski', '1a');
EXECUTE populate.przydziel_godz(1, 'angielski', '2a');
EXECUTE populate.przydziel_godz(1, 'angielski', '3a');
EXECUTE populate.przydziel_godz(1, 'angielski', '4a');

    --biol-hem
EXECUTE populate.przydziel_godz(1, 'angielski', '1b');
EXECUTE populate.przydziel_godz(1, 'angielski', '2b');
EXECUTE populate.przydziel_godz(1, 'angielski', '3b');
EXECUTE populate.przydziel_godz(1, 'angielski', '4b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(9, 'angielski', '1c');
EXECUTE populate.przydziel_godz(9, 'angielski', '2c');
EXECUTE populate.przydziel_godz(9, 'angielski', '3c');
EXECUTE populate.przydziel_godz(9, 'angielski', '4c');

    -- humanistyczna
EXECUTE populate.przydziel_godz(1, 'angielski', '1d');
EXECUTE populate.przydziel_godz(1, 'angielski', '2d');
EXECUTE populate.przydziel_godz(1, 'angielski', '3d');
EXECUTE populate.przydziel_godz(1, 'angielski', '4d');
    
    --wf

    --mat-fiz
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '1a');
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '2a');
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '3a');
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '4a');

    --biol-hem
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '1b');
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '2b');
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '3b');
EXECUTE populate.przydziel_godz(14, 'wychowanie_fizyczne', '4b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '1c');
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '2c');
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '3c');
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '4c');

    -- humanistyczna
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '1d');
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '2d');
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '3d');
EXECUTE populate.przydziel_godz(30, 'wychowanie_fizyczne', '4d');
    
    --biologia

    --mat-fiz
EXECUTE populate.przydziel_godz(17, 'biologia', '1a');

    --biol-hem
EXECUTE populate.przydziel_godz(17, 'biologia', '1b');
EXECUTE populate.przydziel_godz(17, 'biologia', '2b');
EXECUTE populate.przydziel_godz(17, 'biologia', '3b');
EXECUTE populate.przydziel_godz(17, 'biologia', '4b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(17, 'biologia', '1c');

    --humanistyczna
EXECUTE populate.przydziel_godz(17, 'biologia', '1d');
    
    --chemia

    --mat-fiz
EXECUTE populate.przydziel_godz(20, 'chemia', '1a');

    --biol-hem
EXECUTE populate.przydziel_godz(20, 'chemia', '1b');
EXECUTE populate.przydziel_godz(20, 'chemia', '2b');
EXECUTE populate.przydziel_godz(20, 'chemia', '3b');
EXECUTE populate.przydziel_godz(20, 'chemia', '4b');

    -- ekonomiczna
EXECUTE populate.przydziel_godz(20, 'chemia', '1c');

    --humanistyczna
EXECUTE populate.przydziel_godz(20, 'chemia', '1d');
    
    -- geografia

    --mat-fiz
EXECUTE populate.przydziel_godz(23, 'geografia', '1a');

    --biol-hem
EXECUTE populate.przydziel_godz(23, 'geografia', '1b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(23, 'geografia', '1c');
EXECUTE populate.przydziel_godz(23, 'geografia', '2c');
EXECUTE populate.przydziel_godz(23, 'geografia', '3c');
EXECUTE populate.przydziel_godz(23, 'geografia', '4c');

    --humanistyczna
EXECUTE populate.przydziel_godz(23, 'geografia', '1d');
    
    --niemiecki

    -- mat-fiz
EXECUTE populate.przydziel_godz(27, 'niemiecki', '1a');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '2a');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '3a');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '4a');

    -- biol-hem
EXECUTE populate.przydziel_godz(27, 'niemiecki', '1b');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '2b');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '3b');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '4b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(27, 'niemiecki', '1c');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '2c');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '3c');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '4c');

    --humanistyczna
EXECUTE populate.przydziel_godz(27, 'niemiecki', '1d');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '2d');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '3d');
EXECUTE populate.przydziel_godz(27, 'niemiecki', '4d');
    
    --informatyka

    --mat-fiz
EXECUTE populate.przydziel_godz(15, 'informatyka', '1a');
EXECUTE populate.przydziel_godz(15, 'informatyka', '2a');
EXECUTE populate.przydziel_godz(15, 'informatyka', '3a');
EXECUTE populate.przydziel_godz(15, 'informatyka', '4a');

    --biol-hem
EXECUTE populate.przydziel_godz(15, 'informatyka', '1b');

    --ekonomiczna
EXECUTE populate.przydziel_godz(15, 'informatyka', '1c');

    --humanistyczna
EXECUTE populate.przydziel_godz(15, 'informatyka', '1d');


-- przedmiot-uczen

EXECUTE populate.pop_przedmiot_uczen;

-- wlacz klucze obce

BEGIN
  FOR c IN
    (SELECT constraint_name, table_name
   FROM user_constraints
   WHERE status = 'DISABLED' AND constraint_type = 'R')
  LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' ENABLE CONSTRAINT ' || c.constraint_name;
  END LOOP;
END;
/