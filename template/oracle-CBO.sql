SQL Trace工具来收集正在执行的SQL的性能状态数据，包括解析次数，执行次数，CPU使用时间等


TABLE ACCESS FULL(全表扫描)
TABLE ACCESS BY ROWID(通过rowid的表存取)
TABLE ACCESS BY INDEX SCAN(索引扫描)
INDEX UNIQUE SCAN（索引唯一扫描）
INDEX RANGE SCAN（索引范围扫描）
INDEX FULL SCAN（索引全扫描）
INDEX FAST FULL SCAN（索引快速扫描）
INDEX SKIP SCAN（索引跳跃扫描）

1、Create a Cursor 创建游标

2、Parse the Statement 分析语句

3、Describe Results of a Query 描述查询的结果集

4、Define Output of a Query 定义查询的输出数据

5、Bind Any Variables 绑定变量

6、Parallelize the Statement 并行执行语句

7、Run the Statement 运行语句

8、Fetch Rows of a Query 取查询出来的行

9、Close the Cursor 关闭游标

Select *from ur_user_info where phone_no like ‘10%’；
Select count(*) from tab1,tab2;

select .. from

emp e

where 25 < (select count(*) from emp where mgr=e.empno)

and sal > 50000

and job = 'manager';
Select name from user_info where name=’%A’;

select tab_name from tables where (tab_name,db_ver) =

( select tab_name,db_ver) from tab_columns where version =604)

Select..from location where loc_in in (10,20,30);

Delete from ur_user_info a

Where a.rowid>(select min(b.rowid)

From ur_user_info b

Where b. uid=a. uid);

select ..

from dept

where sal  > 25000/12;

select user_no,user_name,address

from user_files

where to_number(user_no) = 109204421


where to_number (substr(a.order_no, instr(b.order_no, '.') - 1)

= to_number (substr(a.order_no, instr(b.order_no, '.') - 1)

select count(decode(dept_no, 0020, 'x', null)) d0020_count,

count(decode(dept_no, 0030, 'x', null)) d0030_count,

sum(decode(dept_no, 0020, sal, null)) d0020_sal,

sum(decode(dept_no, 0030, sal, null)) d0030_sal

from emp

where ename like 'smith%';


select tab_name

from tables

where  (tab_name,db_ver)

= ( select tab_name,db_ver)

from tab_columns

where version = 604);

SELECT … FROM DEPT WHERE SAL > 25000/12;


   SELECT *

   FROM EMP

WHERE DEPTNO >3;

select * from employee where salary<3000 or salary>3000;


select count(key)from tab where key> 0

select count(*) from tab1,tab2 ;

SELECT * FROM LOCATION L, CATEGORY C, EMP E
WHERE E.EMP_NO BETWEEN 1000 AND 2000
AND E.CAT_NO = C.CAT_NO
AND E.LOCN = L.LOCN;


/*高效,执行时间10.6秒*/
SELECT …
FROM EMP E
WHERE 25 < (SELECT COUNT(*) FROM EMP
                     WHERE MGR=E.EMPNO)
  AND SAL > 50000
  AND JOB = ‘MANAGER’;

SELECT TAB_NAME  FROM TABLES
WHERE （TAB_NAME，DB_VER）=
             （SELECT TAB_NAME，DB_VER
                  FROM TAB_COLUMNS
                WHERE VERSION = 604）;


 SELECT * FROM EMP (基础表)
 WHERE EMPNO > 0
      AND EXISTS (SELECT ‘X’
                       FROM DEPT
                     WHERE DEPT.DEPTNO = EMP.DEPTNO
                                  AND LOC = ‘MELB’);

SELECT ….
FROM EMP E
WHERE NOT EXISTS （SELECT ‘X’
                     FROM DEPT D
                  WHERE D.DEPT_NO = E.DEPT_NO
                                AND DEPT_CAT = ‘A’）;


SELECT ENAME
   FROM DEPT D，EMP E
WHERE E.DEPT_NO = D.DEPT_NO
     AND DEPT_CAT = ‘A’ ;


     SELECT DEPT_NO，DEPT_NAME
           FROM DEPT D
         WHERE EXISTS （SELECT ‘X’
                       FROM EMP E
                     WHERE E.DEPT_NO = D.DEPT_NO;


SELECT *
 FROM dept, emp
  3* WHERE emp.deptno = dept.deptno;

 set autotrace traceonly; /*traceonly 可以不显示执行结果*/

ALTER INDEX <INDEXNAME> REBUILD <TABLESPACENAME>;

SELECT ENAME
     FROM EMP
     WHERE DEPTNO > 20
     AND EMP_CAT = ‘A’;



SELECT ENAME
     FROM EMP
     WHERE DEPTNO > 20
     AND EMP_CAT > ‘A’;


SELECT …
  FROM DEPT
WHERE SAL  > 25000/12;


SELECT ENAME
  FROM EMP
WHERE EMPNO = 2326
     AND DEPTNO  = 20 ;

SELECT …
   FROM DEPT
 WHERE DEPT_CODE > 0;

SELECT *
     FROM EMP
   WHERE DEPTNO >=4;


SELECT LOC_ID , LOC_DESC , REGION
     FROM LOCATION
   WHERE LOC_ID = 10
   UNION
   SELECT LOC_ID , LOC_DESC , REGION
     FROM LOCATION
   WHERE REGION = “MELBOURNE”;



  SELECT…
    FROM LOCATION
  WHERE LOC_IN IN （10，20，30）;

   SELECT …
     FROM DEPARTMENT
   WHERE DEPT_CODE >=0;

--如果索引是建立在多个列上， 只有在它的第一个列(leading column)被where子句引用时， 优化器才会选择使用该索引。
select * from  multiindexusage where indb = 1;

--可以使用下面的SQL来查询排序的消耗量

select substr（name，1，25）  "Sort Area Name"，
       substr（value，1，15）   "Value"
from v$sysstat
where name like 'sort%';


SELECT ACCOUNT_NAME
      FROM TRANSACTION
    WHERE AMOUNT > 0；


SELECT ACCOUNT_NAME，AMOUNT
  FROM TRANSACTION
WHERE ACCOUNT_NAME = ‘AMEX’
     AND ACCOUNT_TYPE=’ A’；


SELECT ACCOUNT_NAME，AMOUNT
FROM TRANSACTION
WHERE AMOUNT > 2000 ；


SELECT ACCOUNT_NAME，AMOUNT
FROM TRANSACTION
WHERE ACCOUNT_NAME LIKE NVL(:ACC_NAME, ’%’);

    SELECT *
      FROM LODGING
    WHERE MANAGER = ‘BILL GATES’
           OR MANAGER = ’KEN MULLER’;



SELECT JOB，AVG（SAL）
   FROM EMP
WHERE JOB = ‘PRESIDENT’
        OR JOB = ‘MANAGER’
GROUP BY JOB;


 select count(*) from tab1,tab2;

SELECT * FROM LOCATION L, CATEGORY C, EMP E
WHERE E.EMP_NO BETWEEN 1000 AND 2000
     AND E.CAT_NO = C.CAT_NO
     AND E.LOCN = L.LOCN;

SELECT …
  FROM EMP E
WHERE 25 < (SELECT COUNT(*) FROM EMP
                        WHERE MGR=E.EMPNO)
     AND SAL > 50000
     AND JOB = ‘MANAGER’









drop table t_tab1;

create table t_tab1 as

SELECT t.owner,

t.object_name,

t.object_type,

t.created,

t.last_ddl_time

FROM dba_objects t;

analyze table t_tab1 compute statistics;

create index idx01_t_tab1 on t_tab1(last_ddl_time);--普通索引

set autotrace trace;

SELECT * FROM t_tab1 t where t.last_ddl_time is null;

drop index idx01_t_tab1;

create index idx01_t_tab1 on t_tab1(last_ddl_time,1);--加了个常量

set autotrace trace;

SELECT * FROM t_tab1 t where t.last_ddl_time is null;


drop table t_tab1 purge;

create table t_tab1 as

SELECT t.owner,

t.object_name,

t.object_type,

t.OBJECT_ID,

t.created,

t.last_ddl_time

FROM dba_objects t;

CREATE INDEX IDX01_T_TAB1 ON T_TAB1(object_name);

analyze table t_tab1 compute statistics;

set autot trace

SELECT * FROM t_tab1 t where t.object_name like '%20121231';

drop index IDX01_T_TAB1;

CREATE INDEX IDX02_T_TAB1 ON T_TAB1(reverse(object_name));

analyze table t_tab1 compute statistics;

SELECT * FROM t_tab1 t where reverse(t.object_name) like reverse('%20121231');




