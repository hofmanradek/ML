
#get 3C stations
select * from static.affiliation a, static.site s where a.sta=a.net and a.sta=s.sta and s.statype='ss' and s.offdate < 0 and a.sta not in (select sta from static.affiliation where NET='CUR_HYD') and a.sta in (select sta from static.affiliation where NET='CUR_PRI' or NET='CUR_AUX') order by a.sta;

# how many associated phases do we have in 2 years for all 3C stations in the leb
select count(*) from leb.assoc where sta in (select a.sta from static.affiliation a, static.site s where a.sta=a.net and a.sta=s.sta and s.statype='ss' and s.offdate < 0 and a.sta not in (select sta from static.affiliation where NET='CUR_HYD') and a.sta in (select sta from static.affiliation where NET='CUR_PRI' or NET='CUR_AUX')) and lddate > sysdate - 730;

  COUNT(*)
----------
    731172

# how many associated phases do we have in 2 years for all 3C stations in the leb
select sta, count(*) as num from leb.assoc where sta in (select a.sta from static.affiliation a, static.site s where a.sta=a.net and a.sta=s.sta and s.statype='ss' and s.offdate < 0 and a.sta not in (select sta from static.affiliation where NET='CUR_HYD') and a.sta in (select sta from static.affiliation where NET='CUR_PRI' or NET='CUR_AUX')) and lddate > sysdate - 730 group by sta order by num desc;
STA	      NUM
------ ----------
STKA	    24963
DZM	    17736
LPAZ	    15247
URZ	    15006
CTA	    14253
PMG	    13828
SIJI	    13561
VNDA	    12613
KLR	    12552
PLCA	    12047
AAK	    12011
MSVF	    11281
INK	    10864
KBZ	    10825
FITZ	    10623
CPUP	    10370
AKTO	    10145
KRVT	     9823
BOSA	     9743
RPZ	     9676
BATI	     9633
LVC	     9595
KAPI	     9315
JKA	     9310
QSPA	     9189
SIV	     8984
ULM	     8865
HNR	     8816
AFI	     8544
GUMO	     8535
MAW	     8401
ARU	     8295
BDFB	     8074
KDAK	     8070
NRIK	     7777
SCHQ	     7651
DBIC	     7627
JNU	     7358
JHJ	     7147
DAV	     7147
SEY	     7053
JOW	     7035
ELK	     6824
ANMO	     6784
DAVOX	     6783
JCJ	     6607
MA2	     6476
TIXI	     6221
YAK	     6160
SNAA	     6149
YBH	     5980
MLR	     5973
KEST	     5891
IDI	     5830
SHEM	     5809
VRAC	     5695
ROSC	     5680
EIL	     5479
NEW	     5463
SDV	     5451
NNA	     5349
DLBC	     5299
GNI	     5239
TKL	     5233
BELG	     5184
CMIG	     5131
PFO	     4941
ATAH	     4860
RAO	     4857
WSAR	     4728
LEM	     4673
RAR	     4655
PPT	     4466
KIRV	     4436
MDT	     4333
PALK	     4274
CFA	     4093
RES	     4044
SUR	     4032
KMBO	     4032
JTS	     3893
MDP	     3857
LBTB	     3833
BBB	     3758
FRB	     3442
ASF	     3391
LSZ	     3359
TSUM	     3357
SJG	     3338
SADO	     3249
LPIG	     3183
SFJD	     3089
NWAO	     3022
PSI	     2993
MBAR	     2801
PMSA	     2800
OBN	     2793
BORG	     2723
RPN	     2699
TEIG	     2493
JAY	     2481
VAE	     2365
RCBR	     2305
JMIC	     2017
TGY	     2014
PCRV	     1945
ATD	     1841
BRDH	     1803
OPO	     1643
MATP	     1606
USHA	     1159
KOWA	     1043
BBTS	      980
PTGA	      748
APG	      410
TLY	       29

116 rows selected.

# types of phases and their number across all 3C stations
select phase, count(*) as num from leb.assoc where sta in (select a.sta from static.affiliation a, static.site s where a.sta=a.net and a.sta=s.sta and s.statype='ss' and s.offdate < 0 and a.sta not in (select sta from static.affiliation where NET='CUR_HYD') and a.sta in (select sta from static.affiliation where NET='CUR_PRI' or NET='CUR_AUX')) and lddate > sysdate - 730 group by phase order by num desc;

PHASE		NUM
-------- ----------
LR	     292362
P	     230291
Pn	      60764
Sn	      38302
S	      37035
PKP	      18089
Lg	      13375
PKPbc	      11656
Pg	       4593
PcP	       3861
PKPab	       3393
pP	       2525
PP	       2344
PKKPbc	       2169
ScP	       2129
SKPbc	       1828
PKhKP	       1515
PKiKP		973
PKP2		574
Pdiff		514
SKP		336
pPKP		326
PKKPab		311
pPKPbc		289
PKKP		270
SKKPbc		256
ScS		224
PKP2bc		184
P3KPbc		152
sP		 85
SKPab		 79
P4KPbc		 73
PKP2ab		 59
Rg		 51
pPcP		 36
pPKPab		 34
T		 30
P3KP		 21
SKKP		 20
SKiKP		 11
SS		  6
Sdiff		  5
SKKPab		  4
sPKP		  2
SKKS		  2
SP		  1
P4KP		  1
I		  1

# types of phases and their number for LPAZ for the last 2 years
select phase, count(*) as num from leb.assoc where sta='LPAZ' and lddate > sysdate - 730 group by phase order by num desc;
PHASE		NUM
-------- ----------
P	       6023
LR	       2475
PKPbc	       1992
S	       1219
PKP	       1208
Pn		958
PKPab		406
Sn		137
Lg		120
PKhKP		 92
PP		 90
PKKPbc		 87
PcP		 79
SKPbc		 50
pP		 47
PKiKP		 36
ScP		 30
pPKPbc		 27
Pg		 22
pPKP		 16
Pdiff		 16
SKP		 15
PKP2		 13
PKKPab		  9
ScS		  9
P3KPbc		  9
SKKPbc		  9
PKKP		  7
pPKPab		  5
SKPab		  5
pPcP		  2
SKKS		  1
P3KP		  1
PKP2bc		  1

Components of the training dataset: Query1+Query2+Query3+Query4  - will need to adjust time period because some types of data are underrepresented



#Query1: get arids for all regional P phases from leb.assoc that are not retimed by more than 2 seconds (for LPAZ and for roughly the last 2 years)
select a.arid from leb.assoc l, leb.arrival la, idcx.arrival a where a.arid=l.arid and l.arid=la.arid and abs(a.time - la.time) <= 2 and l.phase in ('Pn', 'Pg') and l.sta='LPAZ' and l.lddate > sysdate - 730;   

542 rows selected.

#Query1: plug the arids from before into Radek query to form part 1 of the training dataset
select r.sta, r.arid, r.time, r.iphase, r.per, ap.rect, ap.plans, ap.inang1, ap.inang3, ap.hmxmn, ap.hvratp, ap.hvrat, a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from 
     reb.arrival r join reb.apma ap on r.arid=ap.arid 
join reb.amp3c a1 on r.arid=a1.arid 
join reb.amp3c a2 on r.arid=a2.arid 
join reb.amp3c a3 on r.arid=a3.arid 
join reb.amp3c a4 on r.arid=a4.arid 
join reb.amp3c a5 on r.arid=a5.arid 
where r.sta='LPAZ' and a1.cfreq=0.25 and a2.cfreq=0.5 and a3.cfreq=1 and a4.cfreq=2 and a5.cfreq=4
and r.arid in (select a.arid from leb.assoc l, leb.arrival la, idcx.arrival a where a.arid=l.arid and l.arid=la.arid and abs(a.time - la.time) <= 2 and l.phase in ('Pn', 'Pg') and l.sta='LPAZ')
order by r.time

454 rows selected 

#Query2: Station LPAZ - arids for all regional S phases from leb.assoc that are not retimed by more than 2 seconds - this is part of the training dataset. May need to take more than 2 years
select a.arid from leb.assoc l, leb.arrival la, idcx.arrival a where a.arid=l.arid and l.arid=la.arid and abs(a.time - la.time) <= 2 and l.phase in ('Sn', 'Lg', 'Rg') and l.sta='LPAZ' and l.lddate > sysdate - 730;   

40 rows selected.

#plug into Radek query for part 2 of the training dataset
select r.sta, r.arid, r.time, r.iphase, r.per, ap.rect, ap.plans, ap.inang1, ap.inang3, ap.hmxmn, ap.hvratp, ap.hvrat, a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from 
     reb.arrival r join reb.apma ap on r.arid=ap.arid 
join reb.amp3c a1 on r.arid=a1.arid 
join reb.amp3c a2 on r.arid=a2.arid 
join reb.amp3c a3 on r.arid=a3.arid 
join reb.amp3c a4 on r.arid=a4.arid 
join reb.amp3c a5 on r.arid=a5.arid 
where r.sta='LPAZ' and a1.cfreq=0.25 and a2.cfreq=0.5 and a3.cfreq=1 and a4.cfreq=2 and a5.cfreq=4
and r.arid in (select a.arid from reb.assoc l, reb.arrival la, idcx.arrival a where a.arid=l.arid and l.arid=la.arid and abs(a.time - la.time) <= 2 and l.phase in ('Sn', 'Lg', 'Rg') and l.sta='LPAZ' and l.lddate > sysdate - 730) 
order by r.time

19 rows selected

#Query3: select all teleseismic P phases from leb.assoc that are not retimed by more than 2 seconds (for LPAZ and for roughly the last 2 years)
select a.arid from leb.assoc l, leb.arrival la, idcx.arrival a where a.arid=l.arid and l.arid=la.arid and abs(a.time - la.time) <= 2 and l.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP') and l.sta='LPAZ' and l.lddate > sysdate - 730;   

6830 rows selected.

#Plug into Radek s query to from part 3 of the dataset
select r.sta, r.arid, r.time, r.iphase, r.per, ap.rect, ap.plans, ap.inang1, ap.inang3, ap.hmxmn, ap.hvratp, ap.hvrat, a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from 
     reb.arrival r join reb.apma ap on r.arid=ap.arid 
join reb.amp3c a1 on r.arid=a1.arid 
join reb.amp3c a2 on r.arid=a2.arid 
join reb.amp3c a3 on r.arid=a3.arid 
join reb.amp3c a4 on r.arid=a4.arid 
join reb.amp3c a5 on r.arid=a5.arid 
where r.sta='LPAZ' and a1.cfreq=0.25 and a2.cfreq=0.5 and a3.cfreq=1 and a4.cfreq=2 and a5.cfreq=4
and r.arid in (select a.arid from leb.assoc l, leb.arrival la, idcx.arrival a where a.arid=l.arid and l.arid=la.arid and abs(a.time - la.time) <= 2 and l.phase in ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc', 'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP', 'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP', 'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP') and l.sta='LPAZ') 
order by r.time 

6632 rows selected

#Query4: arids all arrivals automatically categorized as noise that do not get associated by analysts (for LPAZ and for roughly the last 2 years) - should go into the training dataset
select a.arid from idcx.arrival a where a.iphase='N' and a.sta='LPAZ' and a.lddate > sysdate - 730 and a.arid not in (select distinct arid from leb.assoc);

34560 rows selected.

#form part 4 of the training dataset
select r.sta, r.arid, r.time, r.iphase, r.per, ap.rect, ap.plans, ap.inang1, ap.inang3, ap.hmxmn, ap.hvratp, ap.hvrat, a1.htov "htov1", a2.htov "htov2", a3.htov "htov3", a4.htov "htov4", a5.htov "htov5" 
from 
     idcx.arrival r join idcx.apma ap on r.arid=ap.arid 
join idcx.amp3c a1 on r.arid=a1.arid 
join idcx.amp3c a2 on r.arid=a2.arid 
join idcx.amp3c a3 on r.arid=a3.arid 
join idcx.amp3c a4 on r.arid=a4.arid 
join idcx.amp3c a5 on r.arid=a5.arid
where r.sta='LPAZ' and a1.cfreq=0.25 and a2.cfreq=0.5 and a3.cfreq=1 and a4.cfreq=2 and a5.cfreq=4 and 
r.iphase='N' and r.lddate > sysdate - 730 and r.arid not in (select distinct arid from leb.assoc)
order by r.time

34547 rows selected

# to what do arrivals automatically categorized as noise at LPAZ get changed, when analysts do associate them? 

#select all arrivals automatically categorized as noise that do get changed to another phase by analysts (for LPAZ and for roughly the last 2 years)
select la.phase, count(*) from leb.assoc la, idcx.arrival a where a.iphase='N' and la.arid=a.arid and a.sta='LPAZ' and a.lddate > sysdate - 730 and a.arid in (select distinct arid from leb.assoc) group by la.phase;

PHASE	   COUNT(*)
-------- ----------
pPKP		  1
ScS		  2
PKP		 32
Sn		 18
pP		  4
PKPab		 32
P		 68
Pn		  6
PcP		  4
PKPbc		 37
PKKPbc		  4
pPKPbc		  2
PKKP		  1
S		280
PP		  5
Lg		  8
SKP		  1

17 rows selected. 

select amp.arid, count(amp.cfreq) from reb.amp3c amp, reb.assoc ass where ass.sta='LPAZ' and ass.arid=amp.arid group by amp.arid