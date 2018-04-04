select min(time), max(time) from st_e_tables.RUNSP2017FEBMAR_arrival;
--1485908654.02 and 1491004884.82

select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival; --7005

------
--counts
------------------------------------------------------------------------------------------------------------------------------------
--S -70
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and

--P -66
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') ; --r.iphase in ('Pn', 'Pg', 'Px')  and

--T -345
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and


--N - 6524
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1485908654.02 and 1491004884.82);

-- total 7005

desc reb.assoc;

----------------------
-- NEW WEIGHTS
------------------------------------------------------------------------------------------------------------------------------------
--S -40/70
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx');

--P -53/66
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg')
and e.iphase in ('Pn', 'Pg', 'Px');

--T -160/345
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e, reb.assoc a 
where e.arid=a.arid
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx');


--N - 5011/6524 0.768
select count(*) from st_e_tables.RUNSP2017FEBMAR_arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1485908654.02 and 1491004884.82) and 
e.iphase='N';

--total 0.7514


---to see times

select min(time), max(time) from st_e_tables.RUNSP2017FEBMAR_arrival;

-------------
-- OLD WEIGHTS
-- just counts
-------------------------------------------------------------------------
--S 70
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--P -66
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--T -  345
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--N - 6524
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1485908654.02 and 1491004884.82)
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';
------
-- old weights precision
--------------------------------

--S 31/70
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx')
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--P -51/66 
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.iphase in ('Pn', 'Pg', 'Px')
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--T -154/345  
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--N - 3362/6524 0.51532
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1485908654.02 and 1491004884.82)
and e.iphase='N'
and e.time between 1485908654.02 and 1491004884.82 and e.sta='URZ';

--total 0.5136
