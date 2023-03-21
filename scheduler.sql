BEGIN
    DBMS_SCHEDULER.create_program(
        program_name => 'SDL_DODAJ_DATE_ZAKONCZENIA_GRUP',
        program_action => 'PO_KONCU_ROKU.DODAJ_DATE_ZAKONCZENIA_GRUP',
        program_type => 'STORED_PROCEDURE',
        number_of_arguments => 0,
        comments => NULL,
        enabled => FALSE);
    DBMS_SCHEDULER.ENABLE(name=>'SDL_DODAJ_DATE_ZAKONCZENIA_GRUP');   
	
    DBMS_SCHEDULER.create_program(
        program_name => 'SDL_DODAJ_ROK_SZKOLNY',
        program_action => 'PO_KONCU_ROKU.DODAJ_ROK_SZKOLNY',
        program_type => 'STORED_PROCEDURE',
        number_of_arguments => 0,
        comments => NULL,
        enabled => FALSE);
    DBMS_SCHEDULER.ENABLE(name=>'SDL_DODAJ_ROK_SZKOLNY'); 
	
    DBMS_SCHEDULER.create_program(
        program_name => 'SDL_ZDANIE',
        program_action => 'PO_KONCU_ROKU.ZDANIE',
        program_type => 'STORED_PROCEDURE',
        number_of_arguments => 0,
        comments => NULL,
        enabled => FALSE);
    DBMS_SCHEDULER.ENABLE(name=>'SDL_ZDANIE'); 

    DBMS_SCHEDULER.create_program(
        program_name => 'SDL_NOWY_ROCZNIK',
        program_action => 'PO_KONCU_ROKU.NOWY_ROCZNIK',
        program_type => 'STORED_PROCEDURE',
        number_of_arguments => 0,
        comments => NULL,
        enabled => FALSE);
    DBMS_SCHEDULER.ENABLE(name=>'SDL_NOWY_ROCZNIK'); 	
	
    DBMS_SCHEDULER.create_program(
        program_name => 'SDL_NIEZDANIE',
        program_action => 'PO_KONCU_ROKU.NIEZDANIE',
        program_type => 'STORED_PROCEDURE',
        number_of_arguments => 0,
        comments => NULL,
        enabled => FALSE);
    DBMS_SCHEDULER.ENABLE(name=>'SDL_NIEZDANIE'); 
	
    DBMS_SCHEDULER.create_program(
        program_name => 'SDL_WPISANIE_NOWYCH_PRZEDMIOTOW_GRUPA',
        program_action => 'PO_KONCU_ROKU.WPISANIE_NOWYCH_PRZEDMIOTOW_GRUPA',
        program_type => 'STORED_PROCEDURE',
        number_of_arguments => 0,
        comments => NULL,
        enabled => FALSE);
    DBMS_SCHEDULER.ENABLE(name=>'SDL_WPISANIE_NOWYCH_PRZEDMIOTOW_GRUPA'); 
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_CHAIN (
   chain_name          => 'po_koncu_roku_chain',
   rule_set_name       => NULL,
   evaluation_interval => NULL,
   comments            => 'lancuch procedur wykonywanych na koniec roku szkolnego.');
END;
/

BEGIN
  DBMS_SCHEDULER.DEFINE_CHAIN_STEP (
   chain_name      =>  'po_koncu_roku_chain',
   step_name       =>  'step1',
   program_name    =>  'SDL_DODAJ_DATE_ZAKONCZENIA_GRUP');
  DBMS_SCHEDULER.DEFINE_CHAIN_STEP (
   chain_name      =>  'po_koncu_roku_chain',
   step_name       =>  'step2',
   program_name    =>  'SDL_DODAJ_ROK_SZKOLNY');
  DBMS_SCHEDULER.DEFINE_CHAIN_STEP (
   chain_name      =>  'po_koncu_roku_chain',
   step_name       =>  'step3',
   program_name    =>  'SDL_ZDANIE');  
  DBMS_SCHEDULER.DEFINE_CHAIN_STEP (
   chain_name      =>  'po_koncu_roku_chain',
   step_name       =>  'step4',
   program_name    =>  'SDL_NOWY_ROCZNIK');   
  DBMS_SCHEDULER.DEFINE_CHAIN_STEP (
   chain_name      =>  'po_koncu_roku_chain',
   step_name       =>  'step5',
   program_name    =>  'SDL_NIEZDANIE');      
  DBMS_SCHEDULER.DEFINE_CHAIN_STEP (
   chain_name      =>  'po_koncu_roku_chain',
   step_name       =>  'step6',
   program_name    =>  'SDL_WPISANIE_NOWYCH_PRZEDMIOTOW_GRUPA');  
END;
/

BEGIN
   DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => 'TRUE',
        action => 'START "STEP1"'
        );  
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP1" SUCCEEDED',
        action => 'START "STEP2"'
        );   
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP2" SUCCEEDED',
        action => 'START "STEP3"'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP3" SUCCEEDED',
        action => 'START "STEP4"'
        );  
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP4" SUCCEEDED',
        action => 'START "STEP5"'
        );  		
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP5" SUCCEEDED',
        action => 'START "STEP6"'
        );  
END;
/

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP1" FAILED',
        action => 'END'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP2" FAILED',
        action => 'END'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP3" FAILED',
        action => 'END'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP4" FAILED',
        action => 'END'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP5" FAILED',
        action => 'END'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP6" FAILED',
        action => 'END'
        ); 
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"PO_KONCU_ROKU_CHAIN"',
        condition => '"STEP6" SUCCEEDED',
        action => 'END'
        );   
END;
/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"JOB_KONIEC_ROKU"',
            job_type => 'CHAIN',
            job_action => '"PO_KONCU_ROKU_CHAIN"',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=YEARLY;BYDATE=0630;BYTIME=160000',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => '');
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"JOB_KONIEC_ROKU"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"JOB_KONIEC_ROKU"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);   
    DBMS_SCHEDULER.enable(
             name => '"JOB_KONIEC_ROKU"');
END;
/
BEGIN
      DBMS_SCHEDULER.enable(name=>'"PO_KONCU_ROKU_CHAIN"');
END;


