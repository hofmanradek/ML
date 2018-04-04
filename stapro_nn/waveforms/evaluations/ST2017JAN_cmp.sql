

select count(*) from st_e_tables.runsp20172now_arrival;

desc idcx.arrival;

select max(time) from idcx.arrival;

select count(*) from st_e_tables.runsp20172now_arrival a where a.arid in (select arid from idcx.arrival) and a.time < 1512024670;

select * from st_e_tables.runsp20172now_arrival a where a.arid not in (select arid from idcx.arrival);
    

select count(*) from st_e_tables.runsp20172now_arrival a, idcx.arrival b where a.arid = b.arid and a.time < 1512024670 and a.iphase != b.iphase;
select b.arid, a.iphase, b.iphase, b.lddate from st_e_tables.runsp20172now_arrival a, idcx.arrival b where a.arid = b.arid and a.time < 1512024670 and a.iphase != b.iphase;

    
    --and 
    --a.iphase != b.iphase;
    
select * from  st_e_tables.runsp20172now_arrival where arid=119747406;

select count(*) from st_e_tables.runSP2017JAN_arrival; --4206
select count(*) from st_e_tables.runSP2017JAN_arrival a where a.arid in (select arid from idcx.arrival);  
select count(*) from st_e_tables.runSP2017JAN_arrival a where a.arid in (select arid from idcx.arrival);  
    
select b.arid, a.iphase, b.iphase, b.lddate from st_e_tables.runSP2017JAN_arrival a, idcx.arrival b where a.arid = b.arid and a.iphase != b.iphase;
select count(*) from st_e_tables.runSP2017JAN_arrival a, idcx.arrival b where a.arid = b.arid and a.iphase != b.iphase; --1505
    
desc reb.assoc;    
    
    
select * from idcx.arrival where arid = 128050405;

------
--counts
------------------------------------------------------------------------------------------------------------------------------------
--S -42
select count(*) from st_e_tables.runSP2017JAN_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and

--P -47
select count(*) from st_e_tables.runSP2017JAN_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') ; --r.iphase in ('Pn', 'Pg', 'Px')  and

--T -216
select count(*) from st_e_tables.runSP2017JAN_arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and


--N - 3901
select count(*) from st_e_tables.runSP2017JAN_arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1482969600 and 1485993600);

-- total 4206

desc reb.assoc;

----------------------
-- NEW WEIGHTS
------------------------------------------------------------------------------------------------------------------------------------
--S -15/42 0.357
select count(*) from st_e_tables.runSP2017JAN_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx');

--P -36/47 0.766
select count(*) from st_e_tables.runSP2017JAN_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg')
and e.iphase in ('Pn', 'Pg', 'Px');

--T -118/216 0.546
select count(*) from st_e_tables.runSP2017JAN_arrival e, reb.assoc a 
where e.arid=a.arid
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx');


--N - 2970/3901 0.761
select count(*) from st_e_tables.runSP2017JAN_arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1483227663.17 and 1485820309.67) and 
e.iphase='N';

--total 0.7463


---to see times

select min(time), max(time) from st_e_tables.runSP2017JAN_arrival;

-------------
-- OLD WEIGHTS
-- just counts
-------------------------------------------------------------------------
--S 42
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--P -47
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--T -216
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--N - 3901
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1482969600 and 1485993600)
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';
------
-- old weights precision
--------------------------------

--S 16/42  0.381
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx')
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--P -36/47 0.766
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.iphase in ('Pn', 'Pg', 'Px')
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--T -121/216  0.56
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--N - 1974/3901 0.506
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1482969600 and 1485993600)
and e.iphase='N'
and e.time between 1483227663.17 and 1485820309.67 and e.sta='URZ';

--total 0.51

