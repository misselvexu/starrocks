CREATE TABLE `t0` (
  `t0_c0` int(11) NULL COMMENT "",
  `t0_c1` string
) ENGINE=OLAP
DUPLICATE KEY(`t0_c0`)
DISTRIBUTED BY HASH(`t0_c0`) BUCKETS 1
PROPERTIES ( "replication_num" = "1");

CREATE TABLE `t1` (
  `t1_c0` int(11) NULL COMMENT "",
  `t1_c1` string
) ENGINE=OLAP
DUPLICATE KEY(`t1_c0`)
DISTRIBUTED BY HASH(`t1_c0`) BUCKETS 1
PROPERTIES ( "replication_num" = "1");

-- step 1
create materialized view mv1  
distributed by hash(t0_c0) 
refresh realtime 
as 
select t0_c0, t1_c1
from t0
join t1 on t0_c0 = t1_c0;

select * from mv1;
insert into t0 values (1, 'star');
explain insert into t0 values (1, 'star');
select * from mv1;

drop materialized view mv1;

-- step 2
-- correct view-update output columns
create materialized view mv2
distributed by hash(t0_c0) 
refresh realtime 
as 
select t0_c0, t0_c1, t1_c0, t1_c1
from t0
join t1 on t0_c0 = t1_c0;

drop materialized view mv2;

-- step 3
-- support projection and select in MV
create materialized view mv3
distributed by hash(mv3_c0) 
refresh realtime 
as 
select t0_c0 + 1 as mv3_c0, t0_c1, t1_c0, t1_c1
from t0
join t1 on t0_c0 = t1_c0
where t0_c1 = 'star';

drop materialized view mv3;

-- step 4
-- infer primary key
create materialized view mv4
refresh realtime 
as 
select t0_c0, t0_c1
from t0
join t1 on t0_c0 = t1_c0;

drop materialized view mv4;



-- cleanup
drop table t0;
drop table t1;