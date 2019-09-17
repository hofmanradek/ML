--statistics 


select sta, class_phase, count(class_phase) from ml_features where retime=0 group by sta, class_phase order by sta, class_phase;



select sta, source, class_phase, count(class_phase) from ml_features where sta='URZ' and retime=0 group by sta, source, class_phase order by sta, class_phase, source;




select sta, class_phase, count(class_phase) from ml_features where sta='URZ' group by sta, class_phase order by sta, class_phase;

select source, count(source) from ml_features where class_iphase != class_phase and sta='URZ' group by source;


select arid from (select arid from ml_features where sta='URZ' order by arid desc) where rownum < 10;
/*
129348861
129348856
129347964
129347963
129347663
129347662
129347660
129344652
129342256
*/



select count(*) from idcx.arrival@extadb where arid > (select max(arid) from ml_features where sta='URZ') and sta='URZ'; --142

select count(*) from idcx.arrival@extadb where arid > (select max(arid) from ml_features where sta='LPAZ') and sta='LPAZ'; --0



select * from ml_features sample(1) where sta='URZ' and class_phase='regS'; --110

select count(*) from ml_features where sta='URZ' and class_phase='regS'; --11208





SET COLSEP ',';

select * from ml_features where rownum < 10;

select count(*) from ml_features where class_iphase != class_phase and sta='URZ'; --24022
select count(*) from ml_features where source='H' and sta='URZ'; --24022




select count(*) from (select distinct(f.arid) from ML_FEATURES f join ML_WAVEFORMS w on f.arid=w.arid where f.sta='LPAZ' and f.class_phase='N' and w.samples is null and w.calib is null);
select count(*) from (select distinct(f.arid) from ML_FEATURES f join ML_WAVEFORMS w on f.arid=w.arid where f.sta='LPAZ' and f.class_phase='N' and w.samples is not null and w.calib is not null);


-- check size of tables...
select segment_name, bytes/1024/1024||' MB' from user_segments where segment_type='TABLE' and segment_name like 'ML%';
select sum(bytes)/1024/1024||' MB' from user_segments;


select distinct class_phase from ml_features;

select distinct f.class_phase from ml_features f, ml_waveforms w where f.arid = w.arid and w.samples is not null and f.sta='LPAZ';
select distinct f.class_phase from ml_features f, ml_waveforms w where f.arid = w.arid and w.samples is not null and f.sta='URZ';
