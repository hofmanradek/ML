-- new URZ weights deployed to OPS 10/12/2018
SET SERVEROUTPUT ON;

DECLARE
    total_num NUMBER DEFAULT 0;
    
    --assoc_num NUMBER DEFAULT 0;
    assoc_auto_num NUMBER DEFAULT 0;
    
    --counts
    assoc_num_S NUMBER DEFAULT 0;
    assoc_num_P NUMBER DEFAULT 0;
    assoc_num_T NUMBER DEFAULT 0;

    --correct counts
    assoc_corr_num_S NUMBER DEFAULT 0;
    assoc_corr_num_P NUMBER DEFAULT 0;
    assoc_corr_num_T NUMBER DEFAULT 0;
    assoc_N_phase_num NUMBER DEFAULT 0;
    total_correct NUMBER DEFAULT 0;
    
    --assoc_correct NUMBER DEFAULT 0;
    assoc_auto_correct NUMBER DEFAULT 0;
    total_prec FLOAT;
    assoc_prec FLOAT;
    str_   varchar(10000 char);
PROCEDURE nn_stats(start_date DATE, end_date DATE, title VARCHAR2, station VARCHAR2)
AS
BEGIN

    
    EXECUTE IMMEDIATE 'DROP TABLE EVAL_OPS';
    
    str_ := '
        CREATE TABLE EVAL_OPS
        AS (
            --associated
            SELECT er.arid as arid_odb, er.time as time_odb, er.azimuth as azi_odb, er.iphase as iphase_odb, ea.phase as assoc_phase
            FROM idcx.arrival@extadb er, leb.assoc@extadb ea
            WHERE er.sta='''||station||'''
                AND er.lddate >= to_date('''||to_char(start_date,'yy-mm-dd')||''', ''yy-mm-dd'') 
                AND er.lddate  < to_date('''||to_char(end_date,'yy-mm-dd')||''', ''yy-mm-dd'') 
                AND ea.lddate >= to_date('''||to_char(start_date,'yy-mm-dd')||''', ''yy-mm-dd'') 
                AND ea.lddate  < to_date('''||to_char(end_date,'yy-mm-dd')||''', ''yy-mm-dd'') 
                AND ea.arid=er.arid
      
            UNION 
            SELECT er.arid as arid_odb, er.time as time_odb, er.azimuth as azi_odb, er.iphase as iphase_odb , null as assoc_phase
            FROM idcx.arrival@extadb er
            WHERE er.sta='''||station||'''
                AND er.lddate >= to_date('''||to_char(start_date,'yy-mm-dd')||''', ''yy-mm-dd'') 
                AND er.lddate  < to_date('''||to_char(end_date,'yy-mm-dd')||''', ''yy-mm-dd'') 
                AND er.arid not in (select arid from leb.assoc@extadb where sta='''||station||''' AND lddate >= to_date('''||to_char(start_date,'yy-mm-dd')||''', ''yy-mm-dd'')
                                                                                                  AND lddate  < to_date('''||to_char(end_date,'yy-mm-dd')||''', ''yy-mm-dd'')
                
                )
            )';            
    EXECUTE IMMEDIATE str_;
    str_ := '                   
       ALTER TABLE EVAL_OPS
        ADD (class_iphase_dev varchar2(5),
             class_iphase_odb varchar2(5),
             class_phase_odb  varchar2(5))';
         
    EXECUTE IMMEDIATE str_;
    
    str_ := '
       ALTER TABLE EVAL_OPS
        ADD (ncls_iphase_dev number,
             ncls_iphase_odb number,
             ncls_phase_odb  number)';
         
    EXECUTE IMMEDIATE str_;     
        
    str_ := '
       begin
        UPDATE EVAL_OPS SET CLASS_IPHASE_ODB = ''regS'', ncls_iphase_odb=2  where IPHASE_ODB in (''Sn'', ''Lg'', ''Rg'', ''Sx''); 
        UPDATE EVAL_OPS SET CLASS_IPHASE_ODB = ''regP'', ncls_iphase_odb=1  where IPHASE_ODB in (''Pn'', ''Pg'', ''Px''); 
        UPDATE EVAL_OPS SET CLASS_IPHASE_ODB = ''T'',    ncls_iphase_odb=3  where IPHASE_ODB in (''P'', ''PKP'', ''PKPbc'', ''PcP'', ''PKPab'', ''pP'', ''PP'', ''PKKPbc'', ''ScP'', ''SKPbc'', ''PKhKP'', ''PKiKP'', ''PKP2'', ''Pdiff'', ''SKP'', ''pPKP'', ''PKKPab'', ''pPKPbc'', ''PKKP'', ''SKKPbc'', ''PKP2bc'', ''P3KPbc'', ''sP'', ''SKPab'', ''P4KPbc'', ''PKP2ab'', ''pPKPab'', ''P3KP'', ''SKKP'', ''SKiKP'', ''SKKPab'', ''SKKS'', ''P4KP'', ''SP'', ''S'', ''ScS'', ''SS'', ''Sdiff'', ''pPcP'', ''sPKP'', ''tx'');
        UPDATE EVAL_OPS SET CLASS_IPHASE_ODB = ''N'',    ncls_iphase_odb=0  where IPHASE_ODB in (''N'');
        
        UPDATE EVAL_OPS SET CLASS_PHASE_ODB = ''regS'', ncls_phase_odb=2  where assoc_phase in (''Sn'', ''Lg'', ''Rg'', ''Sx''); 
        UPDATE EVAL_OPS SET CLASS_PHASE_ODB = ''regP'', ncls_phase_odb=1  where assoc_phase in (''Pn'', ''Pg'', ''Px''); 
        UPDATE EVAL_OPS SET CLASS_PHASE_ODB = ''T'',    ncls_phase_odb=3  where assoc_phase in (''P'', ''PKP'', ''PKPbc'', ''PcP'', ''PKPab'', ''pP'', ''PP'', ''PKKPbc'', ''ScP'', ''SKPbc'', ''PKhKP'', ''PKiKP'', ''PKP2'', ''Pdiff'', ''SKP'', ''pPKP'', ''PKKPab'', ''pPKPbc'', ''PKKP'', ''SKKPbc'', ''PKP2bc'', ''P3KPbc'', ''sP'', ''SKPab'', ''P4KPbc'', ''PKP2ab'', ''pPKPab'', ''P3KP'', ''SKKP'', ''SKiKP'', ''SKKPab'', ''SKKS'', ''P4KP'', ''SP'', ''S'', ''ScS'', ''SS'', ''Sdiff'', ''pPcP'', ''sPKP'', ''tx'');
        UPDATE EVAL_OPS SET CLASS_PHASE_ODB = ''N'',    ncls_phase_odb=0  where assoc_phase is null;        
       end;';  -- 747 vs. 784 - some arrivals are missing, probably those retimed by analysts
    EXECUTE IMMEDIATE str_;

    

    select count(*) INTO total_num  from EVAL_OPS; --25331
    select count(*) INTO assoc_auto_num from EVAL_OPS where assoc_phase is not null and class_iphase_odb is not null; -- automatic detection which were associated

    --counts
    select count(*) INTO assoc_num_S from EVAL_OPS where CLASS_PHASE_ODB='regS' and assoc_phase is not null; --
    select count(*) INTO assoc_num_P from EVAL_OPS where CLASS_PHASE_ODB='regP' and assoc_phase is not null; 
    select count(*) INTO assoc_num_T from EVAL_OPS where CLASS_PHASE_ODB='T' and assoc_phase is not null; -- 


    --correct counts    
    select count(*) INTO assoc_corr_num_S from EVAL_OPS where class_iphase_odb='regS' and CLASS_PHASE_ODB='regS' and assoc_phase is not null; -- 
    select count(*) INTO assoc_corr_num_P from EVAL_OPS where class_iphase_odb='regP' and CLASS_PHASE_ODB='regP' and assoc_phase is not null; 
    select count(*) INTO assoc_corr_num_T from EVAL_OPS where class_iphase_odb='T' and CLASS_PHASE_ODB='T' and assoc_phase is not null; --

    select count(*) INTO total_correct from EVAL_OPS where class_iphase_odb = class_phase_odb; -- 14552/25331 correct => 57.447396470727563
    select count(*) INTO assoc_auto_correct from EVAL_OPS where class_iphase_odb = class_phase_odb and assoc_phase is not null; -- 2246/3525 cor => 63.71%
    
    -- N phase rate
    select count(*) INTO assoc_N_phase_num from EVAL_OPS where class_iphase_odb='N' and assoc_phase is not null; -- 314/3525 8.9%
        
    --DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    --DBMS_OUTPUT.PUT_LINE(station||'   '||title);
    --DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    --DBMS_OUTPUT.PUT_LINE('Total phases          '||total_num);    
    ----DBMS_OUTPUT.PUT_LINE('Total associated (A+M)'||assoc_num);    
    --DBMS_OUTPUT.PUT_LINE('Total associated  A   '||assoc_auto_num);  
    --DBMS_OUTPUT.PUT_LINE('  + count regS              '||assoc_num_S);
    --DBMS_OUTPUT.PUT_LINE('  + count regP              '||assoc_num_P);
    --DBMS_OUTPUT.PUT_LINE('  + count T                 '||assoc_num_T);
    
    
    --DBMS_OUTPUT.PUT_LINE('Correct associated     '||assoc_auto_correct||'  ('||round(assoc_auto_correct/assoc_auto_num*100, 2)||'%)');  
    --DBMS_OUTPUT.PUT_LINE('  + correct regS              '||assoc_corr_num_S||'  ('||round(assoc_corr_num_S/assoc_num_S*100, 2)||'%)');
    --DBMS_OUTPUT.PUT_LINE('  + correct regP              '||assoc_corr_num_P||'  ('||round(assoc_corr_num_P/assoc_num_P*100, 2)||'%)');
    --DBMS_OUTPUT.PUT_LINE('  + correct T                 '||assoc_corr_num_T||'  ('||round(assoc_corr_num_T/assoc_num_T*100, 2)||'%)');
    --DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    --DBMS_OUTPUT.PUT_LINE(to_char(start_date,'yy')||'  Accuracy all          '||round(total_correct/total_num*100, 2)||'%');    
    --DBMS_OUTPUT.PUT_LINE('Accuracy associated   '||round(assoc_auto_correct/assoc_auto_num*100, 2)||'%');    
    --DBMS_OUTPUT.PUT_LINE('N phase rate          '||round(assoc_N_phase_num/assoc_auto_num*100, 2)||'%');    
    --DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(station||'   '||title||'  Total phases          '||total_num);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(to_char(start_date,'yy')||'  Accuracy all          '||round(total_correct/total_num*100, 2)||'%');    
    DBMS_OUTPUT.PUT_LINE('Correct associated     '||assoc_auto_correct||'  ('||round(assoc_auto_correct/assoc_auto_num*100, 2)||'%)');  
    
END;



BEGIN
    --nn_stats(DATE '2018-03-13', DATE '2018-12-13', 'Old Weights', 'URZ');
    --nn_stats(DATE '2018-12-14', DATE '2019-09-30', 'New Weights', 'URZ');
    /*
    nn_stats(DATE '2010-01-01', DATE '2010-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2011-01-01', DATE '2011-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2012-01-01', DATE '2012-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2013-01-01', DATE '2013-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2014-01-01', DATE '2014-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2015-01-01', DATE '2015-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2016-01-01', DATE '2016-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2017-01-01', DATE '2017-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2018-01-01', DATE '2018-12-31', 'Old Weights', 'JCJ');
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'JCJ');    
    */
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'PPT'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'ULM'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'SCHQ'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'ROSC'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'LPAZ'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'BDFB'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'CPUP'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'PLCA'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'DBIC'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'KEST'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'BOSA'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'KMBO'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'KBZ'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'THR'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'NRIK'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'LZDM'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'STKA'); 
    nn_stats(DATE '2019-01-01', DATE '2019-12-31', 'Old Weights', 'URZ'); 
END;


