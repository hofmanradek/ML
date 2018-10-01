---------------------------------------PART RUN ON ST_E_TABLES---
--drop table SP2017EGU_ARRIVAL;

select count(*) from RUNSP17JAEGU_ARRIVAL;
create table SP2017EGU_ARRIVAL as (select * from RUNSP17JAEGU_ARRIVAL); --4302
select count(*) from SP2017EGU_ARRIVAL;

insert into SP2017EGU_ARRIVAL (select * from RUNSP17FEMAEGU_arrival); --7005

insert into SP2017EGU_ARRIVAL (select * from RUNSP17APNOEGU_arrival); --24480


select count(*) from SP2017EGU_ARRIVAL;
commit;
---------------------------------------PART RUN ON ST_E_ACCESS------;

select min(time), max(time) from st_e_tables.SP2017EGU_ARRIVAL;

--1483227663.17 and 1512017079.745;



-------------------------------------------------------------------------
-------------------------------------------------------------------------

select count(*) from st_e_tables.SP2017EGU_ARRIVAL; --35787

------
--counts
------------------------------------------------------------------------------------------------------------------------------------
--S -356
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and

--P -357
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') ; --r.iphase in ('Pn', 'Pg', 'Px')  and

--T -1781
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and


--N - 33293
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1483227663.17 and 1512017079.745);

-- total 35787

desc reb.assoc;

----------------------
-- NEW WEIGHTS
------------------------------------------------------------------------------------------------------------------------------------
--S -235/356 0.66
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx');

--P -280/357 0.7843
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg')
and e.iphase in ('Pn', 'Pg', 'Px');

--T -843/1781 0.4733
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e, reb.assoc a 
where e.arid=a.arid
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx');


--N - 24465/33293 0.7348
select count(*) from st_e_tables.SP2017EGU_ARRIVAL e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1483227663.17 and 1512017079.745) and 
e.iphase='N';

--total 0.72157


---to see times

select min(time), max(time) from st_e_tables.SP2017EGU_ARRIVAL;

-------------
-- OLD WEIGHTS
-- just counts - to be sure it is correct
-------------------------------------------------------------------------
--S 356
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';

--P -357
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';

--T -  1781
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';

--N - 33293
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1483227663.17 and 1512017079.745)
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';
------
-- old weights precision
--------------------------------

--S 172/356  0.4831
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx')
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';
 
--P  272/357  0.7619
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.iphase in ('Pn', 'Pg', 'Px')
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';

--T - 824/1781 0.4626
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';

--N - 16359/33282  0.4915
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1483227663.17 and 1512017079.745)
and e.iphase='N'
and e.time between 1483227663.17 and 1512017079.745 and e.sta='URZ';

--total 0.4927