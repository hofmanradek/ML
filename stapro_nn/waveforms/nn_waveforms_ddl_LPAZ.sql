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


CREATE TABLE ML_FEATURES
( 
  ARID              NUMBER(10,0) NOT NULL,
  STA               VARCHAR2(8) NOT NULL,  
  TIME              FLOAT(53)  NOT NULL,  
  IPHASE            VARCHAR2(8), -- iwt
  CPHASE            VARCHAR2(8) NOT NULL, -- phase faimly - N, regP, regS and T (telP, telS..)
  PHASE             VARCHAR2(8),  -- phase as in LEB assoc
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

COMMENT ON COLUMN ML_FEATURES.ARID IS 'arrival id';
COMMENT ON COLUMN ML_FEATURES.STA IS 'station';
COMMENT ON COLUMN ML_FEATURES.TIME IS 'arrival time (sec)';
COMMENT ON COLUMN ML_FEATURES.IPHASE IS 'initial wave type guessed by StaPro';
COMMENT ON COLUMN ML_FEATURES.PHASE IS 'phase assigned by analyst';
COMMENT ON COLUMN ML_FEATURES.CPHASE IS 'phase family class for iwt: N - noise; P - reg P; S - reg S; T - teleseismic PS';
COMMENT ON COLUMN ML_FEATURES.RETIME IS 'retiming ni sec';
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
COMMENT ON COLUMN ML_FEATURES.HTOV1 IS 'horozintal to vertical power ratio in an octave frequencey band centered as 0.25Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV2 IS 'horozintal to vertical power ratio in an octave frequencey band centered as 0.5Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV3 IS 'horozintal to vertical power ratio in an octave frequencey band centered as 1Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV4 IS 'horozintal to vertical power ratio in an octave frequencey band centered as 2Hz';
COMMENT ON COLUMN ML_FEATURES.HTOV5 IS 'horozintal to vertical power ratio in an octave frequencey band centered as 4Hz';


--------------------------------------------------------------------------------------------------------------------------------
----- regional S phases
--------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'S' "cphase", ass.phase "phase", abs(r.time - larr.time) "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival@extadb r join idcx.apma@extadb ap on r.arid=ap.arid join leb.assoc@extadb ass on ass.arid=r.arid join leb.arrival@extadb larr on larr.arid=r.arid
where r.sta='LPAZ' and r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and ass.phase in  ('Sn', 'Lg', 'Rg') and abs(r.time - larr.time) <= 4
order by r.time; --174


-------- regional S where phase from automatic where iphase was not in  ('Sn', 'Lg', 'Rg')
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'S' "cphase", ass.phase "phase", abs(r.time - larr.time) "retime", 'H' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival@extadb r join idcx.apma@extadb ap on r.arid=ap.arid join leb.assoc@extadb ass on ass.arid=r.arid join leb.arrival@extadb larr on larr.arid=r.arid
where r.sta='LPAZ' and r.iphase not in  ('Sn', 'Lg', 'Rg', 'Sx') and ass.phase in  ('Sn', 'Lg', 'Rg') and abs(r.time - larr.time) <= 4
order by r.time; --465


------ regional S manually added by analysts - arid not existing in idcx.arrival
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'S' "cphase", ass.phase "phase", 0 "retime", 'M' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from leb.arrival@extadb r 
join leb.assoc@extadb ass on ass.arid=r.arid
join leb.apma@extadb ap on r.arid=ap.arid 
join leb.amp3c@extadb a1 on r.arid=a1.arid 
join leb.amp3c@extadb a2 on r.arid=a2.arid 
join leb.amp3c@extadb a3 on r.arid=a3.arid 
join leb.amp3c@extadb a4 on r.arid=a4.arid 
join leb.amp3c@extadb a5 on r.arid=a5.arid 
where r.sta='LPAZ' 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and ass.phase in  ('Sn', 'Lg', 'Rg')
and r.arid not in (select distinct arid from idcx.arrival@extadb)
order by r.time; --652


select count(*) from ml_features where cphase='S'; --1291

--------------------------------------------------------------------------------------------------------------------------------
----- regional P phases automatic
--------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'P' "cphase", ass.phase "phase", abs(r.time - larr.time) "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival@extadb r join idcx.apma@extadb ap on r.arid=ap.arid join leb.assoc@extadb ass on ass.arid=r.arid join leb.arrival@extadb larr on larr.arid=r.arid
where r.sta='LPAZ' and r.iphase in ('Pn', 'Pg', 'Px') and ass.phase in ('Pn', 'Pg') and abs(r.time - larr.time) <= 4
order by r.time; --2512

-------- regional P where phase from automatic where iphase was not in ('Pn', 'Pg')
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'P' "cphase", ass.phase "phase", abs(r.time - larr.time) "retime", 'H' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival@extadb r join idcx.apma@extadb ap on r.arid=ap.arid join leb.assoc@extadb ass on ass.arid=r.arid join leb.arrival@extadb larr on larr.arid=r.arid
where r.sta='LPAZ' and r.iphase not in ('Pn', 'Pg', 'Px') and ass.phase in ('Pn', 'Pg') and abs(r.time - larr.time) <= 4
order by r.time; --4149

------------------it gets 6661 in total if we do not want that it was reg P even before

------ regional P manual added by analysts - arid not existing in idcx.arrival
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'P' "cphase", ass.phase "phase", 0 "retime", 'M' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from leb.arrival@extadb r 
join leb.assoc@extadb ass on ass.arid=r.arid
join leb.apma@extadb ap on r.arid=ap.arid 
join leb.amp3c@extadb a1 on r.arid=a1.arid 
join leb.amp3c@extadb a2 on r.arid=a2.arid 
join leb.amp3c@extadb a3 on r.arid=a3.arid 
join leb.amp3c@extadb a4 on r.arid=a4.arid 
join leb.amp3c@extadb a5 on r.arid=a5.arid 
where r.sta='LPAZ' 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and ass.phase in ('Pn', 'Pg')
and r.arid not in (select distinct arid from idcx.arrival@extadb)
order by r.time; --574


select count(*) from ml_features where cphase='P'; --7235

--------------------------------------------------------------------------------------------------------------------------------
----- T teleseismic phases (both P and S)
--------------------------------------------------------------------------------------------------------------------------------

insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'T' "cphase", ass.phase "phase", abs(r.time - larr.time) "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival@extadb r join idcx.apma@extadb ap on r.arid=ap.arid join leb.assoc@extadb ass on ass.arid=r.arid join leb.arrival@extadb larr on larr.arid=r.arid
where r.sta='LPAZ' 
and r.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx') 
and ass.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and abs(r.time - larr.time) <= 4
order by r.time; --54,966 rows inserted.

-------- T where phase from automatic where iphase was not in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'T' "cphase", ass.phase "phase", abs(r.time - larr.time) "retime", 'H' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab",
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.25) as htov1,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=0.5) as htov2,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=1) as htov3,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=2) as htov4,
(select htov from idcx.amp3c@extadb where  arid=r.arid and cfreq=4) as htov5
from idcx.arrival@extadb r join idcx.apma@extadb ap on r.arid=ap.arid join leb.assoc@extadb ass on ass.arid=r.arid join leb.arrival@extadb larr on larr.arid=r.arid
where r.sta='LPAZ' 
and r.iphase not in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and ass.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and abs(r.time - larr.time) <= 4
order by r.time; --23,143

------------------it gets 6661 in total if we do not want that it was reg P even before

------ T manual added by analysts - arid not existing in idcx.arrival
insert into ML_FEATURES
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'T' "cphase", ass.phase "phase", 0 "retime", 'M' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from leb.arrival@extadb r 
join leb.assoc@extadb ass on ass.arid=r.arid
join leb.apma@extadb ap on r.arid=ap.arid 
join leb.amp3c@extadb a1 on r.arid=a1.arid 
join leb.amp3c@extadb a2 on r.arid=a2.arid 
join leb.amp3c@extadb a3 on r.arid=a3.arid 
join leb.amp3c@extadb a4 on r.arid=a4.arid 
join leb.amp3c@extadb a5 on r.arid=a5.arid 
where r.sta='LPAZ' 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and ass.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and r.arid not in (select distinct arid from idcx.arrival@extadb)
order by r.time; --9,906 


select count(*) from ml_features where cphase='T'; --88015


--------------------------------------------------------------------------------------------------------------------------------
----- N phases - identified as N by autiomatic and not associated by analysts
--------------------------------------------------------------------------------------------------------------------------------
insert into ML_FEATURES 
select r.arid "arid", r.sta "sta", r.time "time", r.iphase "iphase", 'N' "cphase", NULL "phase", 0 "retime", 'A' "source", r.per "per", r.slow "slow", ap.rect "rect", ap.plans "plans",
       ap.inang1 "inang1", ap.inang3 "inang3", ap.hmxmn "hmxmn", ap.hvratp "hvratp", ap.hvrat "hvrat", NULL "nab", NULL "tab", a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from idcx.arrival@extadb r 
join idcx.apma@extadb  ap on r.arid=ap.arid 
join idcx.amp3c@extadb a1 on r.arid=a1.arid 
join idcx.amp3c@extadb a2 on r.arid=a2.arid 
join idcx.amp3c@extadb a3 on r.arid=a3.arid 
join idcx.amp3c@extadb a4 on r.arid=a4.arid 
join idcx.amp3c@extadb a5 on r.arid=a5.arid
where r.sta='LPAZ' 
and a1.cfreq=0.25 
and a2.cfreq=0.5 
and a3.cfreq=1 
and a4.cfreq=2 
and a5.cfreq=4 
and r.iphase='N' 
and r.arid not in (select distinct arid from leb.assoc@extadb)
order by r.time; --309,840


select count(*) from ml_features where cphase='N'; --88015


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
select cphase "class phase", count(cphase) "#" from ml_features where source in ('A') and cphase in ('P', 'S', 'T', 'N') and retime<2 group by cphase;
select cphase "class phase", count(cphase) "#" from ml_features where source in ('A', 'M') and cphase in ('P', 'S', 'T', 'N') and retime<2 group by cphase;
select cphase "class phase", count(cphase) "#" from ml_features where source in ('A', 'H', 'M') and cphase in ('P', 'S', 'T', 'N') and retime<=0 group by cphase;


---------------------------------------------------------------------------------------------------
---- CALCULATE CONTEXTUAL FEATURES
---------------------------------------------------------------------------------------------------
-- now we in a standalone table compute contextual features related to number of arrivals before and after given arrival in a 60s window


WHENEVER SQLERROR CONTINUE;
DROP INDEX IDX_ML_FEATURES_CONTEX_T;
DROP TABLE ML_FEATURES_CONTEXTUAL;
WHENEVER SQLERROR EXIT FAILURE;

---created auxiliaty table
CREATE TABLE ML_FEATURES_CONTEXTUAL
( 
  ARID              NUMBER(10,0) NOT NULL,
  TIME              FLOAT(53)  NOT NULL,  
  NAFTER            NUMBER(8),
  NBEFORE           NUMBER(8),
  TAFTER            NUMBER(8),
  TBEFORE           NUMBER(8),
  CONSTRAINT ML_FEATURE_CONTEXTUAL_PK PRIMARY KEY (ARID)
) ENABLE PRIMARY KEY USING INDEX;

CREATE INDEX IDX_ML_FEATURES_CONTEX_T ON ML_FEATURES_CONTEXTUAL(TIME);

insert into ML_FEATURES_CONTEXTUAL
select a.arid, a.time,
       (select count(arid) from ML_FEATURES where abs(a.time-time)<=60 and time>a.time) "NAFTER",
       (select count(arid) from ML_FEATURES where abs(a.time-time)<=60 and time<a.time) "NBEFORE",
       (select sum(abs(time-a.time)) from ML_FEATURES where abs(a.time-time)<=60 and time>a.time) "TAFTER",
       (select sum(abs(time-a.time)) from ML_FEATURES where abs(a.time-time)<=60 and time<a.time) "TBEFORE"
from ML_features a;

--add columns for NAB and TAB
ALTER TABLE
   ML_FEATURES_CONTEXTUAL
ADD(
   NAB FLOAT(24), 
   TAB FLOAT(24)
);

-- populate them
UPDATE ML_FEATURES_CONTEXTUAL SET NAB = (NAFTER-NBEFORE)/10;
UPDATE ML_FEATURES_CONTEXTUAL SET TAB =  (NVL(TAFTER/NULLIF(NAFTER,0), 0) - NVL(TBEFORE/NULLIF(NBEFORE,0), 0))/100;

-- now we plug the contextual features into to feature table
UPDATE ML_FEATURES a SET (a.NAB, a.TAB) = (SELECT b.NAB, b.TAB from ML_FEATURES_CONTEXTUAL b WHERE a.arid=b.arid);
--406,381 rows updated.


-- check size of tables...
select segment_name, bytes/1024/1024||' MB' from user_segments where segment_type='TABLE' and segment_name like 'ML%';
select sum(bytes)/1024/1024||' MB' from user_segments;

-- sanity check
select cphase, count(cphase) 
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
group by cphase;
-- 84 rows returned, all from automatic
/*
CPHASE   COUNT(CPHASE)
-------- -------------
P                    7
T                   76
S                    1
*/

delete from ML_FEATURES where (htov1 is NULL) or (htov2 is NULL) or (htov3 is NULL) or (htov4 is NULL) or (htov5 is NULL);
-- 84 rows deleted

-- grant select to public
GRANT SELECT ON HOFMAN.ML_FEATURES TO PUBLIC;


--------------------------------------------
-- SOME VERIFICATION OF CONTEXTUAL FATURES
-- let's manually compute some values...

COLUMN TIME FORMAT 999999999999.999;
select * from (select * from ML_FEATURES_CONTEXTUAL order by time desc) where rownum < 20;
/*
      ARID              TIME     NAFTER    NBEFORE     TAFTER    TBEFORE        NAB        TAB
---------- ----------------- ---------- ---------- ---------- ---------- ---------- ----------
 128382825    1513195304.075          0          0                                0          0
 128381008    1513193417.300          0          0                                0          0
 128200431    1512565263.525          0          0                                0          0
 128200430    1512565161.850          0          2                    24       -0.2      -0.12
 128200429    1512565156.650          1          1          5         13          0      -0.08
 128200428    1512565143.525          2          0         31                    .2       .155
*/

-- let's pick an arrival where only before arrivals exist
--arid=128200430
--time=

--arrivals before within 60 sec
select b.arid, b.time, b.cphase, b.source from ML_FEATURES a, ML_FEATURES b where a.arid=128200430 and abs(a.time-b.time)<=60 and b.time < a.time;
/*
      ARID              TIME CPHASE   S
---------- ----------------- -------- -
 128200428    1512565143.525 N        A
 128200429    1512565156.650 N        A
*/

--arrivals after within 60 sec
select b.arid, b.time, b.cphase, b.source from ML_FEATURES a, ML_FEATURES b where a.arid=128200430 and abs(a.time-b.time)<=60 and b.time > a.time;
--no rows selected

/*
NBEFORE=2
NAFTER =0
TBEFORE = abs(2*1512565161.850 - 1512565143.525 - 1512565156.650) = 23.524999618530273

NAB = (NAFTER-NBEFORE)/10 = -0.2 OK
TAB = (TAFTER/NAFTER - TBEFORE/NBEFORE)/100 = -0.11762 ~ -0.12 OK
*/


-- let's pick an arrival where both before and after arrivals exist
--arid = 128200429    
--time = 1512565156.650
--arrivals before within 60 sec
select b.arid, b.time, b.cphase, b.source from ML_FEATURES a, ML_FEATURES b where a.arid=128200429 and abs(a.time-b.time)<=60 and b.time < a.time;
/*
      ARID              TIME CPHASE   S
---------- ----------------- -------- -
 128200428    1512565143.525 N        A
*/

--arrivals after within 60 sec
select b.arid, b.time, b.cphase, b.source from ML_FEATURES a, ML_FEATURES b where a.arid=128200429 and abs(a.time-b.time)<=60 and b.time > a.time;
/*
      ARID              TIME CPHASE   S
---------- ----------------- -------- -
 128200430    1512565161.850 N        A
*/

/*
NBEFORE=1
NAFTER =1
TBEFORE = abs(1512565156.650 - 1512565143.525) = 13.125
TAFTER = abs(1512565156.650 - 1512565161.850) = 5.2

NAB = (NAFTER-NBEFORE)/10 = 0 OK
TAB = (TAFTER/NAFTER - TBEFORE/NBEFORE)/100 = -0.07925 ~ -0.08 OK
*/


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
join static.sitechan@extadb b on a.sta=b.sta
where b.sta='LPAZ' 
and b.chan in ('BHE','BHN','BHZ'));

/*
SELECT DISTINCT i.chan 
FROM static.stanet@extadb s 
JOIN static.sitechan@extadb i 
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


---------------------------COPY OFL ML_FEATURES WITHOUT Px, Sx and tx
create table ML_FEATURES_BCK as (select * from ML_FEATURES);
select count(*) from ML_FEATURES_BCK; 
COMMIT;



select count(*) from ml_features where iphase in ('Px', 'Sx', 'tx');
select a.arid, a.phase, i.iphase from idcx.arrival@extadb i join leb.assoc@extadb a on i.arid=a.arid where i.iphase in ('Px', 'Sx', 'tx');

select count(*) from idcx.arrival@extadb i join leb.assoc@extadb a on i.arid=a.arid where i.iphase in ('Px', 'Sx', 'tx') and sta='LPAZ'; --206876
select count(*) from idcx.arrival@extadb i join leb.assoc@extadb a on i.arid=a.arid where i.iphase in ('Px', 'Sx', 'tx') and i.sta='LPAZ' and a.phase in ('Pn', 'Pg', 'Sn', 'Lg', 'Rg', 'P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP'); --7830
select distinct source from ML_FEATURES where iphase in ('Px', 'Sx', 'tx') and sta='LPAZ'; --7809


UPDATE ML_FEATURES SET source='A' where iphase in ('Px', 'Sx', 'tx');


select * from ml_features where arid=64923837;
select count(*) from ml_features where cphase=''
