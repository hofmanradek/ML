

select min(time), max(time) from st_e_tables.RUNSP17APNOEGU_arrival;
--1491003987.545 and 1512017079.745

--1491003987.545 and 1512017079.745


select count(*) from st_e_tables.RUNSP17APNOEGU_arrival; --24480

------
--counts
------------------------------------------------------------------------------------------------------------------------------------
--S -240
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and

--P -241
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') ; --r.iphase in ('Pn', 'Pg', 'Px')  and

--T -1218
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP'); --r.iphase in  ('Sn', 'Lg', 'Rg', 'Sx') and


--N - 22781
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1491003987.545 and 1512017079.745);

-- total 24480

desc reb.assoc;

----------------------
-- NEW WEIGHTS
------------------------------------------------------------------------------------------------------------------------------------
--S -172/240 0.717
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx');

--P -189/241 0.784
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg')
and e.iphase in ('Pn', 'Pg', 'Px');

--T -560/1218 0.46
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e, reb.assoc a 
where e.arid=a.arid
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx');


--N - 16717/22781 0.734
select count(*) from st_e_tables.RUNSP17APNOEGU_arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1491003987.545 and 1512017079.745) and 
e.iphase='N';

--total 0.721


---to see times

select min(time), max(time) from st_e_tables.RUNSP17APNOEGU_arrival;

-------------
-- OLD WEIGHTS
-- just counts
-------------------------------------------------------------------------
--S 240
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--P -241
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--T -  1218
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--N - 22781
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1491003987.545 and 1512017079.745)
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';
------
-- old weights precision
--------------------------------

--S 122/240 0.508
select count(*) from IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Sn', 'Lg', 'Rg')
and e.iphase in  ('Sn', 'Lg', 'Rg', 'Sx')
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--P -183/241  0.759
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid 
and a.phase in  ('Pn', 'Pg') 
and e.iphase in ('Pn', 'Pg', 'Px')
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--T -547/1218  0.449
select count(*) from  IDCX.arrival e, reb.assoc a 
where e.arid=a.arid --('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and a.phase in  ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP')
and e.iphase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP', 'S', 'ScS', 'SS', 'Sdiff', 'pPcP', 'sPKP', 'tx')
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--N - 10983/22781 0.4821
select count(*) from  IDCX.arrival e--, reb.assoc a 
where e.arid not in (select arid from reb.assoc where sta='URZ' and time between 1491003987.545 and 1512017079.745)
and e.iphase='N'
and e.time between 1491003987.545 and 1512017079.745 and e.sta='URZ';

--total 0.4835
