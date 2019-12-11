THIS TEXT WILL CAUSE ERROR WHEN RUN AS A SCRIPT

/* safety comment:)
-- continue on error
WHENEVER SQLERROR CONTINUE;
DROP INDEX IDX_ML_FEATURES_TIME;
DROP INDEX IDX_ML_FEATURES_CONTEX_T;
DROP TABLE ML_FEATURES;
-- exit on error from now on
*/
WHENEVER SQLERROR EXIT FAILURE;


--define station name as a variable
var station varchar2(5);
exec :station := 'LPAZ';

var retimelimit number;
exec :retimelimit := 10;


CREATE TABLE ML_FEATURES
( 
  ARID              NUMBER(10,0) NOT NULL,
  STA               VARCHAR2(8) NOT NULL,  
  TIME              FLOAT(53)  NOT NULL,  
  IPHASE            VARCHAR2(8), -- iwt
  CLASS_IPHASE     VARCHAR2(8),
  PHASE             VARCHAR2(8),  -- phase as in LEB assoc
  CLASS_PHASE      VARCHAR2(8) NOT NULL, -- phase faimly - N, regP, regS and T (telP, telS..)
  RETIME            FLOAT(24) NOT NULL,
  SOURCE            VARCHAR2(1), -- A - automatic phase family type remained after association, H - automatic phase family changed by analyst, M - manually added by analysts
  PER               FLOAT(24), ---arrival features follow
  SLOW              FLOAT(24), 
  RECT              FLOAT(24), ---apma features follow       
  PLANS             FLOAT(24),         
  INANG1            FLOAT(24),         
  INANG3            FLOAT(24),           
  HMXMN             FLOAT(24),         
  HVRATP            FLOAT(24),         
  HVRAT             FLOAT(24),         
  NAB               FLOAT(24),---contextual features follow
  TAB               FLOAT(24),
  HTOV1             FLOAT(24),---amp3c features follow   
  HTOV2             FLOAT(24),
  HTOV3             FLOAT(24),
  HTOV4             FLOAT(24),
  HTOV5             FLOAT(24),
  CONSTRAINT ML_FEATURE_PK PRIMARY KEY (ARID)
) ENABLE PRIMARY KEY USING INDEX;

--create index on time of ML_FEATURES
CREATE INDEX IDX_ML_FEATURES_TIME ON ML_FEATURES(TIME);
CREATE INDEX IDX_ML_FEATURES_STA ON ML_FEATURES(STA);

ALTER INDEX IDX_ML_FEATURES_TIME REBUILD;
ALTER INDEX IDX_ML_FEATURES_STA REBUILD;

COMMENT ON COLUMN ML_FEATURES.ARID IS 'arrival id';
COMMENT ON COLUMN ML_FEATURES.STA IS 'station';
COMMENT ON COLUMN ML_FEATURES.TIME IS 'arrival time (sec)';
COMMENT ON COLUMN ML_FEATURES.IPHASE IS 'initial wave type guessed by StaPro';
COMMENT ON COLUMN ML_FEATURES.CLASS_IPHASE IS 'phase family class for iwt: N - noise; regP - reg P; regS - reg S; tele - teleseismic';
COMMENT ON COLUMN ML_FEATURES.PHASE IS 'final phase assigned by an analyst';
COMMENT ON COLUMN ML_FEATURES.CLASS_PHASE IS 'phase family class for final phase assigned by an analyst: N - noise; regP - reg P; regS - reg S; tele - teleseismic';
COMMENT ON COLUMN ML_FEATURES.RETIME IS 'retiming in sec';
COMMENT ON COLUMN ML_FEATURES.SOURCE IS 'A - automatic and arrival.iphase in the same phase family as assoc.phase, H - automatic and arrival.iphase not in the same phase family as assoc.phase, M - manually added by analyst';
COMMENT ON COLUMN ML_FEATURES.PER IS 'signal period';
COMMENT ON COLUMN ML_FEATURES.SLOW IS 'signal slowness';
COMMENT ON COLUMN ML_FEATURES.RECT IS 'signal rectilinearity';
COMMENT ON COLUMN ML_FEATURES.PLANS IS 'signal planarity';
COMMENT ON COLUMN ML_FEATURES.INANG1 IS 'long axis incidence angle';
COMMENT ON COLUMN ML_FEATURES.INANG3 IS 'short-axis incidence angle';
COMMENT ON COLUMN ML_FEATURES.HMXMN IS 'ration of maximum to minimum horizontal amplitude';
COMMENT ON COLUMN ML_FEATURES.HVRATP IS 'ratio of horizontal to vertical power';
COMMENT ON COLUMN ML_FEATURES.HVRAT IS 'HVRATP measured at the time of the maximum three-component amplitude';
COMMENT ON COLUMN ML_FEATURES.NAB IS 'difference between the number of arrivals before and after the arrival within 60 seconds (+-60) divided by 10';
COMMENT ON COLUMN ML_FEATURES.TAB IS 'mean time difference between the arrival and those before and after it within 60 seconds (+-60) divided by 100';
COMMENT ON COLUMN ML_FEATURES.HTOV1 IS 'horozintal to vertical power ratio in an octave frequencey band centered at 0.25Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV2 IS 'horozintal to vertical power ratio in an octave frequencey band centered at 0.5Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV3 IS 'horozintal to vertical power ratio in an octave frequencey band centered at 1Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV4 IS 'horozintal to vertical power ratio in an octave frequencey band centered at 2Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV5 IS 'horozintal to vertical power ratio in an octave frequencey band centered at 4Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV5 IS 'horozintal to vertical power ratio in an octave frequencey band centered at 4Hz';


--------------------------------------------------------------------------------------------------------------------------------
----- regional S phases
--------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'regS' "class_iphase", ass.phase "phase", 'regS' "class_phase", abs(r.time - larr.time) "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival r join idcx.apma ap on r.arid=ap.arid join leb.assoc ass on ass.arid=r.arid join leb.arrival larr on larr.arid=r.arid
where r.sta=:station and r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and ass.phase in  ('Sn', 'Lg', 'Rg') and abs(r.time - larr.time) <= :retimelimit
order by r.time; --3,462 rows inserted.


-------- regional S where phase from automatic where iphase was not in  ('Sn', 'Lg', 'Rg')
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", NULL "class_iphase", ass.phase "phase", 'regS' "class_phase", abs(r.time - larr.time) "retime", 'H' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival r join idcx.apma ap on r.arid=ap.arid join leb.assoc ass on ass.arid=r.arid join leb.arrival larr on larr.arid=r.arid
where r.sta=:station and r.iphase not in  ('Sn', 'Lg', 'Rg', 'Sx') and ass.phase in  ('Sn', 'Lg', 'Rg') and abs(r.time - larr.time) <= :retimelimit
order by r.time; --231 rows inserted.


------ regional S manually added by analysts - arid not existing in idcx.arrival
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", NULL "class_iphase", ass.phase "phase", 'regS' "class_phase", 0 "retime", 'M' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from leb.arrival r 
join leb.assoc ass on ass.arid=r.arid
join leb.apma ap on r.arid=ap.arid 
join leb.amp3c a1 on r.arid=a1.arid 
join leb.amp3c a2 on r.arid=a2.arid 
join leb.amp3c a3 on r.arid=a3.arid 
join leb.amp3c a4 on r.arid=a4.arid 
join leb.amp3c a5 on r.arid=a5.arid 
where r.sta=:station 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and ass.phase in  ('Sn', 'Lg', 'Rg')
and r.arid not in (select distinct arid from idcx.arrival)
order by r.time; --2,098 rows inserted.

commit;

select count(*) from ml_features where class_phase='regS' and sta=:station; --5791

--------------------------------------------------------------------------------------------------------------------------------
----- regional P phases automatic
--------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'regP' "class_iphase", ass.phase "phase", 'regP' "class_phase", abs(r.time - larr.time) "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival r join idcx.apma ap on r.arid=ap.arid join leb.assoc ass on ass.arid=r.arid join leb.arrival larr on larr.arid=r.arid
where r.sta=:station and r.iphase in ('Pn', 'Pg', 'Px') and ass.phase in ('Pn', 'Pg') and abs(r.time - larr.time) <= :retimelimit
order by r.time; --2,661 rows inserted.

-------- regional P where phase from automatic where iphase was not in ('Pn', 'Pg')
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", NULL "class_iphase", ass.phase "phase", 'regP' "class_phase", abs(r.time - larr.time) "retime", 'H' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival r join idcx.apma ap on r.arid=ap.arid join leb.assoc ass on ass.arid=r.arid join leb.arrival larr on larr.arid=r.arid
where r.sta=:station and r.iphase not in ('Pn', 'Pg', 'Px') and ass.phase in ('Pn', 'Pg') and abs(r.time - larr.time) <= :retimelimit
order by r.time; --3519


------ regional P manual added by analysts - arid not existing in idcx.arrival
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", NULL "class_iphase", ass.phase "phase", 'regP' "class_phase", 0 "retime", 'M' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from leb.arrival r 
join leb.assoc ass on ass.arid=r.arid
join leb.apma ap on r.arid=ap.arid 
join leb.amp3c a1 on r.arid=a1.arid 
join leb.amp3c a2 on r.arid=a2.arid 
join leb.amp3c a3 on r.arid=a3.arid 
join leb.amp3c a4 on r.arid=a4.arid 
join leb.amp3c a5 on r.arid=a5.arid 
where r.sta=:station 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and ass.phase in ('Pn', 'Pg')
and r.arid not in (select distinct arid from idcx.arrival)
order by r.time; --1795 rows inserted.


select count(*) from ml_features where class_phase='regP' and sta=:station and source='H'; --11830

--------------------------------------------------------------------------------------------------------------------------------
----- T teleseismic phases (both P and S)
--------------------------------------------------------------------------------------------------------------------------------

insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'T' "class_iphase", ass.phase "phase", 'T' "class_phase", abs(r.time - larr.time) "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival r join idcx.apma ap on r.arid=ap.arid join leb.assoc ass on ass.arid=r.arid join leb.arrival larr on larr.arid=r.arid
where r.sta=:station 
and r.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx') 
and ass.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and abs(r.time - larr.time) <= :retimelimit
order by r.time; --1,156 rows inserted.

-------- T where phase from automatic where iphase was not in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", NULL "class_iphase", ass.phase "phase", 'T' "class_phase", abs(r.time - larr.time) "retime", 'H' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival r join idcx.apma ap on r.arid=ap.arid join leb.assoc ass on ass.arid=r.arid join leb.arrival larr on larr.arid=r.arid
where r.sta=:station 
and r.iphase not in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and ass.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and abs(r.time - larr.time) <= :retimelimit
order by r.time; --14,309 rows inserted.


------ T manual added by analysts - arid not existing in idcx.arrival
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", NULL "class_iphase", ass.phase "phase", 'T' "class_phase", 0 "retime", 'M' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from leb.arrival r 
join leb.assoc ass on ass.arid=r.arid
join leb.apma ap on r.arid=ap.arid 
join leb.amp3c a1 on r.arid=a1.arid 
join leb.amp3c a2 on r.arid=a2.arid 
join leb.amp3c a3 on r.arid=a3.arid 
join leb.amp3c a4 on r.arid=a4.arid 
join leb.amp3c a5 on r.arid=a5.arid 
where r.sta=:station 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and ass.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and r.arid not in (select distinct arid from idcx.arrival)
order by r.time; --3,409 rows inserted. 


select count(*) from ml_features where class_phase='T' and sta=:station; --18874


--------------------------------------------------------------------------------------------------------------------------------
----- N phases - identified as N by automatic and not associated by analysts
--------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES 
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'N' "class_iphase", NULL, 'N' "class_phase", 0 "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from idcx.arrival r 
join idcx.apma  ap on r.arid=ap.arid 
join idcx.amp3c a1 on r.arid=a1.arid 
join idcx.amp3c a2 on r.arid=a2.arid 
join idcx.amp3c a3 on r.arid=a3.arid 
join idcx.amp3c a4 on r.arid=a4.arid 
join idcx.amp3c a5 on r.arid=a5.arid
where r.sta=:station 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and r.iphase='N' 
and r.arid not in (select distinct arid from leb.assoc)
order by r.time; --142,271 rows inserted.


------------------------------------------------------------------------------------------------------------------------------------------
---inser not associated which are not N
----------------------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES 
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'N' "class_iphase", NULL, 'N' "class_phase", 0 "retime", 'Z' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from idcx.arrival r 
join idcx.apma  ap on r.arid=ap.arid 
join idcx.amp3c a1 on r.arid=a1.arid 
join idcx.amp3c a2 on r.arid=a2.arid 
join idcx.amp3c a3 on r.arid=a3.arid 
join idcx.amp3c a4 on r.arid=a4.arid 
join idcx.amp3c a5 on r.arid=a5.arid
where r.sta=:station 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and r.iphase!='N' 
and r.arid not in (select distinct arid from leb.assoc where r.sta=:station)
order by r.time; --816905rows inserted.

select count(*) from ml_features where class_phase = 'N' and sta=:station; --1149981

-----------not done FINALLY
/*
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'N' "class_iphase", NULL "phase", 'N' "class_phase", 0 "retime", 'Z' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from idcx.arrival r 
join idcx.apma  ap on r.arid=ap.arid 
join idcx.amp3c a1 on r.arid=a1.arid 
join idcx.amp3c a2 on r.arid=a2.arid 
join idcx.amp3c a3 on r.arid=a3.arid 
join idcx.amp3c a4 on r.arid=a4.arid 
join idcx.amp3c a5 on r.arid=a5.arid
where r.sta=:station 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and r.arid not in (select distinct arid from leb.assoc)
and r.arid not in (select distinct arid from ml_features)
and r.time between 1451606400 and 1512000000
order by r.time; --NOT DONE FINALLY

commit;

select count(*) from ml_features where cphase='N' and sta=:station;
*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
select sta, class_phase "class phase", count(class_phase) "#" from ml_features where source in ('A') and class_phase in ('regP', 'regS', 'T', 'N') and retime<=10 group by class_phase, sta order by sta, class_phase;
select sta, class_phase "class phase", count(class_phase) "#" from ml_features where source in ('A', 'M') and class_phase in ('regP', 'regS', 'T', 'N') and retime<=10 group by class_phase, sta order by sta, class_phase;
select sta, class_phase "class phase", count(class_phase) "#" from ml_features where source in ('A', 'H', 'M') and class_phase in ('regP', 'regS', 'T', 'N') and retime<=10 group by class_phase, sta order by sta, class_phase;


---------------------------------------------------------------------------------------------------
---- CALCULATE CONTEXTUAL FEATURES
---------------------------------------------------------------------------------------------------
-- now we in a standalone table compute contextual features related to number of arrivals before and after given arrival in a 60s window


WHENEVER SQLERROR CONTINUE;
DROP INDEX IDX_ML_FEATURES_CONTEX_T;
DROP TABLE ML_FEATURES_CONTEXTUAL;
WHENEVER SQLERROR EXIT FAILURE;

select count(*) from ML_FEATURES_CONTEXTUAL;



---created auxiliaty table
CREATE TABLE ML_FEATURES_CONTEXTUAL
( 
  ARID              NUMBER(10,0) NOT NULL,
  TIME              FLOAT  NOT NULL,  
  NAFTER            NUMBER,
  NBEFORE           NUMBER,
  TAFTER            NUMBER,
  TBEFORE           NUMBER,
  NAB               FLOAT, 
  TAB               FLOAT,
  CONSTRAINT ML_FEATURE_CONTEXTUAL_PK PRIMARY KEY (ARID)
) ENABLE PRIMARY KEY USING INDEX;


CREATE INDEX IDX_ML_FEATURES_CONTEX_T ON ML_FEATURES_CONTEXTUAL(TIME);
ALTER INDEX IDX_ML_FEATURES_CONTEX_T REBUILD;

insert into ML_FEATURES_CONTEXTUAL
select a.arid, a.time,
       (select count(arid) from idcx.arrival where time between a.time and a.time+60 and sta=:station and arid!=a.arid) "NAFTER",
       (select count(arid) from idcx.arrival where time between a.time-60 and a.time and sta=:station and arid!=a.arid) "NBEFORE",
       (select sum(a.time-time) from idcx.arrival where time between a.time and a.time+60 and sta=:station and arid!=a.arid) "TAFTER",
       (select sum(time-a.time) from idcx.arrival where time between a.time-60 and a.time and sta=:station and arid!=a.arid) "TBEFORE",
       --NULL, NULL, NULL,
       NULL,
       NULL
from ML_features a where a.sta=:station and a.class_phase in ('regS', 'regP', 'T', 'N'); --32,640 rows inserted.
--from ML_features a where a.sta=:station and a.class_phase in ('N'); --142,271 rows inserted.

commit;


-- populate them
UPDATE ML_FEATURES_CONTEXTUAL SET NAB = (NAFTER-NBEFORE)/10. where arid in (select arid from ml_features where sta=:station);
UPDATE ML_FEATURES_CONTEXTUAL SET TAB =  (NVL(abs(TAFTER)/NULLIF(NAFTER,0.), 0.) - NVL(abs(TBEFORE)/NULLIF(NBEFORE,0.), 0.))/100.0 where arid in (select arid from ml_features where sta=:station);
commit;

select * from ML_FEATURES_CONTEXTUAL where arid=122995432;
select * from ML_FEATURES where arid=122995432;
select count(*) from ml_features where sta=:station;
select count(*) from ml_features_contextual;

-- now we plug the contextual features into to feature table
UPDATE ML_FEATURES a SET (a.NAB, a.TAB) = (SELECT b.NAB, b.TAB from ML_FEATURES_CONTEXTUAL b WHERE a.arid=b.arid) where a.sta=:station;
--174,911 rows updated.



-- check size of tables...
select segment_name, bytes/1024/1024||' MB' from user_segments where segment_type='TABLE' and segment_name like 'ML%';
select sum(bytes)/1024/1024||' MB' from user_segments;

-- sanity check
select phase, count(phase) 
from ML_FEATURES 
where (per is NULL) 
      or (slow is NULL) 
      or (rect is NULL) 
      or (plans is NULL) 
      or (inang1 is NULL) 
      or (inang3 is NULL) 
      or (hmxmn is NULL) 
      or (hvratp is NULL) 
      or (hvrat is NULL) 
      or (nab is NULL) 
      or (tab is NULL) 
      or (htov1 is NULL) 
      or (htov2 is NULL) 
      or (htov3 is NULL) 
      or (htov4 is NULL) 
      or (htov5 is NULL)       
group by phase;


delete from ML_FEATURES where (htov1 is NULL) or (htov2 is NULL) or (htov3 is NULL) or (htov4 is NULL) or (htov5 is NULL);
-- 372 rows deleted.

delete from ML_FEATURES where (HVRAT <= 0) or (HVRATP <= 0) or (HMXMN <= 0) or (htov1 <= 0) or (htov2 <= 0) or (htov3 <= 0) or (htov4 <= 0) or (htov5 <= 0);

commit;
--------------------------------------------
-- SOME VERIFICATION OF CONTEXTUAL FATURES
-- let's manually compute some values...




----------------------------POPULATE CLASS_IPHASE column

UPDATE ML_FEATURES SET CLASS_IPHASE = 'regS' where IPHASE in ('Sn', 'Lg', 'Rg', 'Sx'); 
--UPDATE ML_FEATURES SET CLASS_IPHASE = 'regS' where IPHASE in ('LR'); 
UPDATE ML_FEATURES SET CLASS_IPHASE = 'regP' where IPHASE in ('Pn', 'Pg', 'Px'); 
UPDATE ML_FEATURES SET CLASS_IPHASE = 'T' where IPHASE in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx');
UPDATE ML_FEATURES SET CLASS_IPHASE = 'N' where IPHASE='N'; 

commit;














---------------------------------------------------------------------------------------------------------------------------------
------ ML_WAVEFORMS TABLE
---------------------------------------------------------------------------------------------------------------------------------

-- prepare sequence and triggers for generating IDs of waveforms



WHENEVER SQLERROR CONTINUE; -- continue on error

DROP SEQUENCE SEQ_WAVEFORM_ID;
DROP TABLE ML_WAVEFORMS;

WHENEVER SQLERROR EXIT FAILURE; -- exit on error from now on 

-- sequence for waveform id
CREATE SEQUENCE SEQ_WAVEFORM_ID START WITH 1000 INCREMENT BY 1 NOCACHE NOCYCLE;

-- table to keep waveforms in
CREATE TABLE ML_WAVEFORMS
(
  WAVEFORMID        NUMBER(10,0) NOT NULL,
  ARID              NUMBER(10,0) NOT NULL,
  STA               VARCHAR2(8) NOT NULL,
  CHAN              VARCHAR2(8) NOT NULL,  
  SAMPRATE          FLOAT(24),
  STARTTIME         FLOAT(53),
  ENDTIME           FLOAT(53),
  NSAMP             NUMBER(8),
  CALIB             FLOAT(24),
  SAMPLES           varchar2(3200), --calibrated up to 400 4byte float samples in hex representation - because of DB encoding..
  CONSTRAINT ML_WAVEFORM_PK PRIMARY KEY (WAVEFORMID),
  CONSTRAINT FK_ML_FEATURE FOREIGN KEY (ARID) REFERENCES ML_FEATURES (ARID)
) ENABLE PRIMARY KEY USING INDEX;


COMMENT ON COLUMN ML_WAVEFORMS.WAVEFORMID IS 'waveform id';
COMMENT ON COLUMN ML_WAVEFORMS.ARID IS 'arrival id';
COMMENT ON COLUMN ML_WAVEFORMS.STA IS 'station';
COMMENT ON COLUMN ML_WAVEFORMS.CHAN IS 'channel';
COMMENT ON COLUMN ML_WAVEFORMS.SAMPRATE IS 'sampling rate';
COMMENT ON COLUMN ML_WAVEFORMS.STARTIME IS 'start time of stored waveform';
COMMENT ON COLUMN ML_WAVEFORMS.ENDTIME IS 'end time of stored waveform';
COMMENT ON COLUMN ML_WAVEFORMS.NSAMP IS 'number of samples stored';
COMMENT ON COLUMN ML_WAVEFORMS.CALIB IS 'calibration value';
COMMENT ON COLUMN ML_WAVEFORMS.SAMPLES IS 'calibrated samples of given channel as 4byte floats in hexa';

-- use in a trigger to autoincrement the sequence
CREATE OR REPLACE TRIGGER WAVEFORM_ID_INCREMENT
BEFORE INSERT ON ML_WAVEFORMS
FOR EACH ROW
BEGIN
  SELECT SEQ_WAVEFORM_ID.NEXTVAL
  INTO   :new.WAVEFORMID
  FROM   dual;
END;
/


--we prepare rows where waveforms will be filled later by a python code
INSERT INTO ML_WAVEFORMS (ARID, STA, CHAN, SAMPRATE, STARTTIME, ENDTIME, NSAMP, CALIB, SAMPLES)
(SELECT a.ARID, a.STA, b.CHAN, NULL, NULL, NULL, NULL, NULL, NULL 
from ML_FEATURES a
join static.sitechan b on a.sta=b.sta
where b.sta='LPAZ' 
and b.chan in ('BHE','BHN','BHZ'));

/*
SELECT DISTINCT i.chan 
FROM static.stanet s 
JOIN static.sitechan i 
ON s.sta=i.sta 
WHERE i.chan IN ('BDF','BH1','BH2','BHE','BHN','BHZ','EDH','EDE','EHN',
                 'EHZ','HHE','HHN','HHZ','MH1','MH2','MHE','MHN','MHZ',
                 'SH1','SH2','SHE','SHN','SHZ') AND 
s.net='LPAZ' 
ORDER BY i.chan;
*/

COMMIT;


select count(*) from ML_FEATURES;
select count(*) from ML_WAVEFORMS;

select count(*) from ML_WAVEFORMS where samples is not null;

select arid from ML_WAVEFORMS where samples is not null ORDER BY ARID desc;
select count(*) from ML_WAVEFORMS where samples is not null ORDER BY ARID desc;

select count(*) from ML_FEATURES where cphase='S';


PURGE TABLE ML_WAVEFORMS;


alter table
   ML_WAVEFORMS
modify
(
   samples   varchar2(4000)
);


desc ML_WAVEFORMS;


select count(*) from ml_features where cphase='S';
select count(*) from ml_features where cphase='P';
select count(*) from ml_features where cphase='T';
select count(*) from ml_features where cphase='N';

select * from ml_features where arid=77189604;
select * from ml_waveforms where arid=77189604;


---------------------------COPY OF ML_FEATURES WITHOUT Px, Sx and tx
create table ML_FEATURES_BCK as (select * from ML_FEATURES);
select count(*) from ML_FEATURES_BCK; 
COMMIT;



select count(*) from ml_features where iphase in ('Px', 'Sx', 'tx');
select a.arid, a.phase, i.iphase from idcx.arrival i join leb.assoc a on i.arid=a.arid where i.iphase in ('Px', 'Sx', 'tx');

select count(*) from idcx.arrival i join leb.assoc a on i.arid=a.arid where i.iphase in ('Px', 'Sx', 'tx') and sta='LPAZ'; --206876
select count(*) from idcx.arrival i join leb.assoc a on i.arid=a.arid where i.iphase in ('Px', 'Sx', 'tx') and i.sta='LPAZ' and a.phase in ('Pn', 'Pg', 'Sn', 'Lg', 'Rg', 'P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP'); --7830
select distinct source from ML_FEATURES where iphase in ('Px', 'Sx', 'tx') and sta='LPAZ'; --7809


UPDATE ML_FEATURES SET source='A' where iphase in ('Px', 'Sx', 'tx');


select * from ml_features where arid=64923837;


select count(i.arid) from leb.arrival i, leb.assoc a where i.arid=a.arid and a.phase != i.iphase and i.sta='LPAZ' and a.arid not in (select arid from idcx.arrival where sta='LPAZ');
select * from leb.arrival i, idcx.arrival a where i.arid=a.arid and a.iphase != i.iphase and i.sta='LPAZ';

select distinct iphase from ml_features where source in ('A', 'H');
select distinct iphase from ml_features where source in ('M');



select cphase, count(cphase) from ml_features where sta=:station and source in ('A','M') group by cphase ;

select cphase, count(cphase) from ml_features where sta='LPAZ' and source in ('A','M','H') group by cphase ;

commit;


