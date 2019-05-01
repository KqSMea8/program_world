--https://github.com/jkstill/oracle-script-lib/tree/master/sql

--1 数据定义语言DDL
--定义和管理数据库中的各种对象 包括创建数据库 数据表 视图
Create 创建对象
Alter	修改对象
Drop	删除对象


----Data Definition Language 数据库定义语言


CREATE TABLE <table_name>(
column1 DATATYPE [NOT NULL] [PRIMARY KEY],
column2 DATATYPE [NOT NULL],
...
[constraint <约束名> 约束类型 (要约束的字段)
... ] ）
说明：　
DATATYPE --是Oracle的数据类型,可以查看附录。
NUT NULL --可不可以允许资料有空的（尚未有资料填入）。
PRIMARY KEY --是本表的主键。
constraint --是对表里的字段添加约束.(约束类型有
            Check,Unique,Primary key,not null,Foreign key)。

示例:
create table stu(
s_id number(8) PRIMARY KEY,
s_name varchar2(20) not null,
s_sex varchar2(8),
clsid number(8),
constraint u_1 unique(s_name),
constraint c_1 check (s_sex in ('MALE','FEMALE'))
);


CREATE TABLE <table_name> as <SELECT 语句>
示例:
--(需注意的是复制表不能复制表的约束) 包含数据
create table test as select * from emp;

--如果只复制表的结构不复制表的数据则:
create table test as select * from emp where 1=2;


修改表

1.向表中添加新字段
ALTER TABLE <table_name> ADD (字段1 类型 [NOT NULL],
字段2 类型 [NOT NULL]
.... );

2.修改表中字段
ALTER TABLE <table_name> modify(字段1 类型,
字段2 类型
.... );

3 .删除表中字段
ALTER TABLE <table_name> drop(字段1,
字段2
.... );

4 .修改表的名称
RENAME <table_name> to <new table_name>;

5 .对已经存在的表添加约束
ALTER TABLE <table_name> ADD CONSTRAINT <constraint_name> 约束类型 (针对的字段名);
示例：
Alter table emp add constraint S_F Foreign key (deptno) references dept(deptno);

6 .对表里的约束禁用;
ALTER TABLE <table_name> DISABLE CONSTRAINT <constraint_name>;

7 .对表里的约束重新启用;
ALTER TABLE <table_name> ENABLE CONSTRAINT <constraint_name>;

8 .删除表中约束
ALTER TABLE <table_name> DROP CONSTRAINT <constraint_name>;
示例:
ALTER TABLE emp drop CONSTRAINT <Primary key>;



-- ascii.sql
-- generate a simple ascii table
-- 0-9, A-Z, a-z
-- Jared Still 2016-11-04 still@pythian.com jkstill@gmail.com
--

select level dec, to_char(level,'XX') hex, chr(level) chr
from dual
where
	( level between ascii('A') and ascii('Z'))
	or ( level between ascii('a') and ascii('z'))
	or ( level between ascii('0') and ascii('9'))
connect by level < ascii('z')+1
order by level
/



--1.java技术 0
--  3.java基础 1
--  4.JSP 技术 1
      --5.servlet 4
--2.net 技术 0

/*分类表*/
CREATE TABLE luntan_kind(
kindId INTEGER PRIMARY KEY, --分类ID 主键
kindName VARCHAR2(50 CHAR) NOT NULL,--分类名称
parentKindId  INT NULL --父分类ID
);
INSERT INTO luntan_kind(kindId,kindName) VALUES(1,'java技术');
SELECT * FROM luntan_kind;


/*用户表*/
CREATE TABLE luntan_user(
lgName Varchar2(20) PRIMARY KEY,
lgPass VARCHAR2(32) NOT NULL,
sex NUMBER(1) default(1) NOT NULL,
head VARCHAR2(50) DEFAULT('1.gif') NOT NULL,--数据库保存图片的名字
register_time DATE DEFAULT(SYSDATE) NOT NULL
);

/*帖子表*/
CREATE TABLE luntan_tip(
tId NUMBER PRIMARY KEY,--帖子ID 主键
title varchar2(50) NOT NULL, --标题
tcontent VARCHAR2(4000) NOT NULL,--内容
lgName Varchar2(20) NOT NULL CONSTRAINT Fk_lgName REFERENCES luntan_user(lgName),--发帖人 关联用户表的用户
createTime DATE DEFAULT(SYSDATE) NOT NULL,--发帖时间
modifyTime DATE DEFAULT(SYSDATE) NOT NULL, --修改时间
kindId INTEGER NOT NULL CONSTRAINT FK_kindId REFERENCES luntan_kind(kindId) --分类 引用分类表的分类ID
);

/*删除约束*/
ALTER TABLE luntan_tip DROP CONSTRAINT Fk_lgName;
ALTER TABLE luntan_tip DROP CONSTRAINT FK_kindId;
INSERT INTO luntan_tip VALUES(1,'abc','dfasd','abc',DEFAULT,DEFAULT,250);
INSERT INTO luntan_tip VALUES(1,'abc','dfasd','abc',DEFAULT,DEFAULT,250);
DELETE FROM luntan_tip;

INSERT INTO luntan_user VALUES('chenghong','123',0,'2.gif',DEFAULT);
INSERT INTO luntan_user VALUES('likeqiang','123',1,'3.gif',DEFAULT);
INSERT INTO luntan_kind VALUES(1,'java技术'，0);

INSERT INTO luntan_tip VALUES(1,'111dd','fasfd','likeqiang',DEFAULT,DEFAULT,1);
INSERT INTO luntan_tip VALUES(2,'111dd','fasfd','likeqiang',DEFAULT,DEFAULT,1);
INSERT INTO luntan_tip VALUES(3,'111dd','fasfd','chenghong',DEFAULT,DEFAULT,1);
INSERT INTO luntan_tip VALUES(4,'111dd','fasfd','chenghong',DEFAULT,DEFAULT,1);
INSERT INTO luntan_tip VALUES(5,'111dd','fasfd','chenghong',DEFAULT,DEFAULT,1);

ROLLBACK;

SELECT * FROM luntan_user WHERE lgname NOT IN (SELECT lgname FROM luntan_tip);

SELECT COUNT(*) FROM luntan_tip GROUP BY lgName;

SELECT * FROM (SELECT ROWNUM rn,luntan_user.* FROM luntan_tip WHERE rn=3);

SELECT * FROM(SELECT ROWNUM rn,luntan_tip.* FROM luntan_tip)  WHERE rn BETWEEN 3 AND 5;

SELECT * FROM luntan_tip

/*按发帖人降序排列后 查询3到5行记录*/


SELECT *
  FROM (SELECT ROWNUM RN, CCC.*
           FROM (SELECT * FROM LUNTAN_TIP ORDER BY LGNAME DESC) CCC)
 WHERE RN BETWEEN 3 AND 5


/*连接查询*/
SELECT * FROM LUNTAN_TIP CROSS JOIN luntan_kind;








--1. SQL语句执行步骤
--
语法分析> 语义分析> 视图转换 >表达式转换> 选择优化器 >选择连接方式 >选择连接顺序 >选择数据的搜索路径 >运行“执行计划”


--2. 选用适合的Oracle优化器
--
--RULE（基于规则）  COST（基于成本）  CHOOSE（选择性）

--3. 访问Table的方式
--
--全表扫描
--
--  全表扫描就是顺序地访问表中每条记录，ORACLE采用一次读入多个数据块(database block)的方式优化全表扫描。


--通过ROWID访问表
--  ROWID包含了表中记录的物理位置信息，O
--RACLE采用索引实现了数据和存放数据的物理位置(ROWID)之间的联系，通常索引提供了快速访问ROWID的方法，
--因此那些基于索引列的查询就可以得到性能上的提高。


--4. 共享 SQL 语句
--Oracle提供对执行过的SQL语句进行高速缓冲的机制。被解析过并且确定了执行路径的SQL语句存放在SGA的共享池中。
--Oracle执行一个SQL语句之前每次先从SGA共享池中查找是否有缓冲的SQL语句，如果有则直接执行该SQL语句。
--可以通过适当调整SGA共享池大小来达到提高Oracle执行性能的目的。


--5. 选择最有效率的表名顺序
--ORACLE的解析器按照从右到左的顺序处理FROM子句中的表名，因此FROM子句中写在最后的表(基础表 driving table)将被最先处理。
--当ORACLE处理多个表时，会运用排序及合并的方式连接它们。

--首先，扫描第一个表(FROM子句中最后的那个表)并对记录进行派序，然后扫描第二个表(FROM子句中最后第二个表)，
--最后将所有从第二个表中检索出的记录与第一个表中合适记录进行合并。
--只在基于规则的优化器中有效。

--举例：
--
--表 TAB1 16,384 条记录
--
--表 TAB2 1 条记录
--
   /*选择TAB2作为基础表 (最好的方法)*/
  select count(*) from tab1,tab2   执行时间0.96秒

   /*选择TAB2作为基础表 (不佳的方法)*/
  select count(*) from tab2,tab1   执行时间26.09秒


--如果有3个以上的表连接查询, 那就需要选择交叉表(intersection table)作为基础表, 交叉表是指那个被其他表所引用的表。

SELECT * FROM LOCATION L, CATEGORY C, EMP E
WHERE E.EMP_NO BETWEEN 1000 AND 2000
     AND E.CAT_NO = C.CAT_NO
     AND E.LOCN = L.LOCN

--将比下列SQL更有效率
SELECT * FROM EMP E, LOCATION L, CATEGORY C
WHERE E.CAT_NO = C.CAT_NO
     AND E.LOCN = L.LOCN
     AND E.EMP_NO BETWEEN 1000 AND 2000

--6. Where子句中的连接顺序
--Oracle采用自下而上的顺序解析WHERE子句。 根据这个原理,表之间的连接必须写在其他WHERE条件之前，那些可以过滤掉最大数量记录的条件必须写在WHERE子句的末尾。
--

--/*低效,执行时间156.3秒*/
--SELECT …
--  FROM EMP E
--WHERE  SAL > 50000
--     AND  JOB = ‘MANAGER’
--     AND  25 < (SELECT COUNT(*) FROM EMP
--                         WHERE MGR = E.EMPNO)


--/*高效,执行时间10.6秒*/
--SELECT …
--  FROM EMP E
--WHERE 25 < (SELECT COUNT(*) FROM EMP
--                        WHERE MGR=E.EMPNO)
--     AND SAL > 50000
--     AND JOB = ‘MANAGER’

--7. SELECT子句中避免使用“*”
--
--Oracle在解析SQL语句的时候，对于“*”将通过查询数据库字典来将其转换成对应的列名。
--如果在Select子句中需要列出所有的Column时，建议列出所有的Column名称，而不是简单的用“*”来替代，这样可以减少多于的数据库查询开销。
--8. 减少访问数据库的次数
--
--当执行每条SQL语句时, ORACLE在内部执行了许多工作：  解析SQL语句 > 估算索引的利用率 > 绑定变量 > 读数据块等等
--
--由此可见, 减少访问数据库的次数 , 就能实际上减少ORACLE的工作量。
--
--9. 整个简单无关联的数据库访问
--
--如果有几个简单的数据库查询语句，你可以把它们整合到一个查询中（即使它们之间没有关系），以减少多于的数据库IO开销。
--
--虽然采取这种方法，效率得到提高，但是程序的可读性大大降低，所以还是要权衡之间的利弊。
--
--10. 使用Truncate而非Delete
--
--Delete表中记录的时候，Oracle会在Rollback段中保存删除信息以备恢复。Truncate删除表中记录的时候不保存删除信息，不能恢复。因此Truncate删除记录比Delete快，而且占用资源少。
--删除表中记录的时候，如果不需要恢复的情况之下应该尽量使用Truncate而不是Delete。
--Truncate仅适用于删除全表的记录。
--11. 尽量多使用COMMIT
--
--只要有可能,在程序中尽量多使用COMMIT, 这样程序的性能得到提高,需求也会因为COMMIT所释放的资源而减少。
--
--COMMIT所释放的资源：
--
--回滚段上用于恢复数据的信息.
--被程序语句获得的锁
--redo log buffer 中的空间
--ORACLE为管理上述3种资源中的内部花费
--12. 计算记录条数
--
--Select count(*) from tablename;
--Select count(1) from tablename;
--Select max(rownum) from tablename;
-- 一般认为，在没有索引的情况之下，第一种方式最快。 如果有索引列，使用索引列当然最快。
--
--13. 用Where子句替换Having子句
--
--避免使用HAVING子句，HAVING 只会在检索出所有记录之后才对结果集进行过滤。这个处理需要排序、总计等操作。 如果能通过WHERE子句限制记录的数目，就能减少这方面的开销。
--
--14. 减少对表的查询操作
--
--在含有子查询的SQL语句中，要注意减少对表的查询操作。
--
--低效：

--SELECT TAB_NAME  FROM TABLES
--WHERE TAB_NAME =（SELECT TAB_NAME
--                           FROM TAB_COLUMNS
--                         WHERE VERSION = 604）
--     AND DB_VER =（SELECT DB_VER
--                           FROM TAB_COLUMNS
--                         WHERE VERSION = 604）

--高效：
--SELECT TAB_NAME  FROM TABLES
--WHERE （TAB_NAME，DB_VER）=
--             （SELECT TAB_NAME，DB_VER
--                  FROM TAB_COLUMNS
--                WHERE VERSION = 604）
--15. 使用表的别名（Alias）
--
--当在SQL语句中连接多个表时, 请使用表的别名并把别名前缀于每个Column上.这样一来,就可以减少解析的时间并减少那些由Column歧义引起的语法错误。
--
--Column歧义指的是由于SQL中不同的表具有相同的Column名,当SQL语句中出现这个Column时,SQL解析器无法判断这个Column的归属。
--
--16. 用EXISTS替代IN
--
--在许多基于基础表的查询中，为了满足一个条件 ，往往需要对另一个表进行联接。在这种情况下，使用EXISTS(或NOT EXISTS)通常将提高查询的效率。
--
--低效：
--
--SELECT * FROM EMP (基础表)
--WHERE EMPNO > 0
--      AND DEPTNO IN (SELECT DEPTNO
--                          FROM DEPT
--                        WHERE LOC = ‘MELB’)
--高效：
--

--SELECT * FROM EMP (基础表)
--WHERE EMPNO > 0
--     AND EXISTS (SELECT ‘X’
--                      FROM DEPT
--                    WHERE DEPT.DEPTNO = EMP.DEPTNO
--                                 AND LOC = ‘MELB’)

--17. 用NOT EXISTS替代NOT IN
--
--在子查询中，NOT IN子句将执行一个内部的排序和合并，对子查询中的表执行一个全表遍历，因此是非常低效的。
--
--为了避免使用NOT IN，可以把它改写成外连接（Outer Joins）或者NOT EXISTS。
--
--低效：
--
--SELECT …
--  FROM EMP
--WHERE DEPT_NO NOT IN （SELECT DEPT_NO
--                              FROM DEPT
--                          WHERE DEPT_CAT=’A’）
--高效：
--

--SELECT ….
--  FROM EMP E
--WHERE NOT EXISTS （SELECT ‘X’
--                       FROM DEPT D
--                    WHERE D.DEPT_NO = E.DEPT_NO
--                                  AND DEPT_CAT = ‘A’）

--18. 用表连接替换EXISTS
--
--通常来说 ，采用表连接的方式比EXISTS更有效率 。
--
--低效：
--

--SELECT ENAME
--   FROM EMP E
--WHERE EXISTS （SELECT ‘X’
--                  FROM DEPT
--              WHERE DEPT_NO = E.DEPT_NO
--                           AND DEPT_CAT = ‘A’）

--高效：
--
--SELECT ENAME
--   FROM DEPT D，EMP E
--WHERE E.DEPT_NO = D.DEPT_NO
--     AND DEPT_CAT = ‘A’
--19. 用EXISTS替换DISTINCT
--
--当提交一个包含对多表信息（比如部门表和雇员表）的查询时，避免在SELECT子句中使用DISTINCT。 一般可以考虑用EXIST替换。
--
--EXISTS 使查询更为迅速，因为RDBMS核心模块将在子查询的条件一旦满足后，立刻返回结果。
--
--低效：
--
--SELECT DISTINCT DEPT_NO，DEPT_NAME
--       FROM DEPT D，EMP E
--    WHERE D.DEPT_NO = E.DEPT_NO
--高效：
--
--SELECT DEPT_NO，DEPT_NAME
--      FROM DEPT D
--    WHERE EXISTS （SELECT ‘X’
--                  FROM EMP E
--                WHERE E.DEPT_NO = D.DEPT_NO
--20. 识别低效的SQL语句
--
--下面的SQL工具可以找出低效SQL ：
--

--SELECT EXECUTIONS, DISK_READS, BUFFER_GETS,
--   ROUND ((BUFFER_GETS-DISK_READS)/BUFFER_GETS, 2) Hit_radio,
--   ROUND (DISK_READS/EXECUTIONS, 2) Reads_per_run,
--   SQL_TEXT
--FROM   V$SQLAREA
--WHERE  EXECUTIONS>0
--AND     BUFFER_GETS > 0
--AND (BUFFER_GETS-DISK_READS)/BUFFER_GETS < 0.8
--ORDER BY 4 DESC

--另外也可以使用SQL Trace工具来收集正在执行的SQL的性能状态数据，包括解析次数，执行次数，CPU使用时间等 。
--
--21. 用Explain Plan分析SQL语句
--
--EXPLAIN PLAN 是一个很好的分析SQL语句的工具, 它甚至可以在不执行SQL的情况下分析语句. 通过分析, 我们就可以知道ORACLE是怎么样连接表, 使用什么方式扫描表(索引扫描或全表扫描)以及使用到的索引名称。
--
--22. SQL PLUS的TRACE
--

--SQL> list
--  1  SELECT *
--  2  FROM dept, emp
--  3* WHERE emp.deptno = dept.deptno
--SQL> set autotrace traceonly /*traceonly 可以不显示执行结果*/
--SQL> /
--14 rows selected.
--Execution Plan
------------------------------------------------------------
--   0      SELECT STATEMENT Optimizer=CHOOSE
--   1    0   NESTED LOOPS
--   2    1     TABLE ACCESS (FULL) OF 'EMP'
--   3    1     TABLE ACCESS (BY INDEX ROWID) OF 'DEPT'
--   4    3       INDEX (UNIQUE SCAN) OF 'PK_DEPT' (UNIQUE)

--23. 用索引提高效率
--
--（1）特点
--
--优点： 提高效率 主键的唯一性验证
--
--代价： 需要空间存储 定期维护
--
--重构索引：
--
--ALTER INDEX <INDEXNAME> REBUILD <TABLESPACENAME>
--（2）Oracle对索引有两种访问模式
--
--索引唯一扫描 (Index Unique Scan)
--索引范围扫描 (Index Range Scan)
--（3）基础表的选择
--
--基础表(Driving Table)是指被最先访问的表(通常以全表扫描的方式被访问)。 根据优化器的不同，SQL语句中基础表的选择是不一样的。
--如果你使用的是CBO (COST BASED OPTIMIZER)，优化器会检查SQL语句中的每个表的物理大小，索引的状态，然后选用花费最低的执行路径。
--如果你用RBO (RULE BASED OPTIMIZER)， 并且所有的连接条件都有索引对应，在这种情况下，基础表就是FROM 子句中列在最后的那个表。
--（4）多个平等的索引
--
--当SQL语句的执行路径可以使用分布在多个表上的多个索引时，ORACLE会同时使用多个索引并在运行时对它们的记录进行合并，检索出仅对全部索引有效的记录。
--在ORACLE选择执行路径时，唯一性索引的等级高于非唯一性索引。然而这个规则只有当WHERE子句中索引列和常量比较才有效。如果索引列和其他表的索引类相比较。这种子句在优化器中的等级是非常低的。
--如果不同表中两个相同等级的索引将被引用，FROM子句中表的顺序将决定哪个会被率先使用。 FROM子句中最后的表的索引将有最高的优先级。
--如果相同表中两个相同等级的索引将被引用，WHERE子句中最先被引用的索引将有最高的优先级。
--（5）等式比较优先于范围比较
--
--DEPTNO上有一个非唯一性索引，EMP_CAT也有一个非唯一性索引。
--
--SELECT ENAME
--     FROM EMP
--     WHERE DEPTNO > 20
--     AND EMP_CAT = ‘A’;
--这里只有EMP_CAT索引被用到,然后所有的记录将逐条与DEPTNO条件进行比较. 执行路径如下:
--
--TABLE ACCESS BY ROWID ON EMP
--
--INDEX RANGE SCAN ON CAT_IDX
--
--即使是唯一性索引，如果做范围比较，其优先级也低于非唯一性索引的等式比较。
--
--（6）不明确的索引等级
--
--当ORACLE无法判断索引的等级高低差别，优化器将只使用一个索引,它就是在WHERE子句中被列在最前面的。
--
--DEPTNO上有一个非唯一性索引，EMP_CAT也有一个非唯一性索引。
--
--SELECT ENAME
--     FROM EMP
--     WHERE DEPTNO > 20
--     AND EMP_CAT > ‘A’;
--这里, ORACLE只用到了DEPT_NO索引. 执行路径如下:
--
--TABLE ACCESS BY ROWID ON EMP
--
--INDEX RANGE SCAN ON DEPT_IDX
--
--（7）强制索引失效
--
--如果两个或以上索引具有相同的等级，你可以强制命令ORACLE优化器使用其中的一个(通过它,检索出的记录数量少) 。
--
--SELECT ENAME
--FROM EMP
--WHERE EMPNO = 7935
--AND DEPTNO + 0 = 10    /*DEPTNO上的索引将失效*/
--AND EMP_TYPE || ‘’ = ‘A’  /*EMP_TYPE上的索引将失效*/
--（8）避免在索引列上使用计算
--
--WHERE子句中，如果索引列是函数的一部分。优化器将不使用索引而使用全表扫描。
--
--低效：
--
--SELECT …
--  FROM DEPT
--WHERE SAL * 12 > 25000;
--高效：
--
--SELECT …
--  FROM DEPT
--WHERE SAL  > 25000/12;
--（9）自动选择索引
--
--如果表中有两个以上（包括两个）索引，其中有一个唯一性索引，而其他是非唯一性索引。在这种情况下，ORACLE将使用唯一性索引而完全忽略非唯一性索引。
--
--SELECT ENAME
--  FROM EMP
--WHERE EMPNO = 2326
--     AND DEPTNO  = 20 ;
--这里，只有EMPNO上的索引是唯一性的，所以EMPNO索引将用来检索记录。
--
--TABLE ACCESS BY ROWID ON EMP
--
--INDEX UNIQUE SCAN ON EMP_NO_IDX
--
--（10）避免在索引列上使用NOT
--
--通常，我们要避免在索引列上使用NOT，NOT会产生在和在索引列上使用函数相同的影响。当ORACLE遇到NOT，它就会停止使用索引转而执行全表扫描。
--
--低效: (这里，不使用索引)
--
--   SELECT …
--     FROM DEPT
--   WHERE NOT DEPT_CODE = 0
--高效：(这里，使用了索引)
--
-- SELECT …
--   FROM DEPT
-- WHERE DEPT_CODE > 0
--24. 用 >= 替代 >
--
--如果DEPTNO上有一个索引
--
--高效:
--
--SELECT *
--     FROM EMP
--   WHERE DEPTNO >=4
--低效：
--
--SELECT *
--     FROM EMP
--   WHERE DEPTNO >3
--两者的区别在于，前者DBMS将直接跳到第一个DEPT等于4的记录，而后者将首先定位到DEPTNO等于3的记录并且向前扫描到第一个DEPT大于3的记录.
--
--25. 用Union替换OR（适用于索引列）
--
--通常情况下，用UNION替换WHERE子句中的OR将会起到较好的效果。对索引列使用OR将造成全表扫描。 注意，以上规则只针对多个索引列有效。
--
--高效：
--

--SELECT LOC_ID , LOC_DESC , REGION
--     FROM LOCATION
--   WHERE LOC_ID = 10
--   UNION
--   SELECT LOC_ID , LOC_DESC , REGION
--     FROM LOCATION
--   WHERE REGION = “MELBOURNE”

--低效：
--
--SELECT LOC_ID , LOC_DESC , REGION
--     FROM LOCATION
--   WHERE LOC_ID = 10 OR REGION = “MELBOURNE”
--26. 用IN替换OR
--
--低效：
--
--SELECT….
--  FROM LOCATION
--WHERE LOC_ID = 10
--       OR  LOC_ID = 20
--       OR  LOC_ID = 30
--高效：
--
--SELECT…
--  FROM LOCATION
--WHERE LOC_IN IN （10，20，30）
--实际的执行效果还须检验，在ORACLE8i下， 两者的执行路径似乎是相同的。
--
--27. 避免在索引列上使用is null和is not null
--
--避免在索引中使用任何可以为空的列，ORACLE将无法使用该索引。
--
--低效：（索引失效）
--
--SELECT …
--  FROM DEPARTMENT
--WHERE DEPT_CODE IS NOT NULL;
--高效：（索引有效）
--
--SELECT …
--  FROM DEPARTMENT
--WHERE DEPT_CODE >=0;
--28. 总是使用索引的第一个列
--
--如果索引是建立在多个列上， 只有在它的第一个列(leading column)被where子句引用时， 优化器才会选择使用该索引。
--

--SQL> create index multindex on multiindexusage(inda,indb);
--Index created.
--
--SQL> select * from  multiindexusage where indb = 1;
--Execution Plan
------------------------------------------------------------
--   0      SELECT STATEMENT Optimizer=CHOOSE
--   1    0   TABLE ACCESS (FULL) OF 'MULTIINDEXUSAGE‘

--很明显, 当仅引用索引的第二个列时,优化器使用了全表扫描而忽略了索引。
--
--29. 使用UNION ALL替代UNION
--
--当SQL语句需要UNION两个查询结果集合时，这两个结果集合会以UNION-ALL的方式被合并，然后在输出最终结果前进行排序。如果用UNION ALL替代UNION，这样排序就不是必要了，效率就会因此得到提高。
--
--由于UNION ALL的结果没有经过排序，而且不过滤重复的记录，因此是否进行替换需要根据业务需求而定。
--
--30. 对UNION的优化
--
--由于UNION会对查询结果进行排序，而且过滤重复记录，因此其执行效率没有UNION ALL高。 UNION操作会使用到SORT_AREA_SIZE内存块，因此对这块内存的优化也非常重要。
--
--可以使用下面的SQL来查询排序的消耗量 ：
--
--select substr（name，1，25）  "Sort Area Name"，
--       substr（value，1，15）   "Value"
--from v$sysstat
--where name like 'sort%'
--31. 避免改变索引列的类型
--
--当比较不同数据类型的数据时， ORACLE自动对列进行简单的类型转换。
--

--/*假设EMP_TYPE是一个字符类型的索引列.*/
--SELECT …
--  FROM EMP
-- WHERE EMP_TYPE = 123
--
--/*这个语句被ORACLE转换为:*/
--SELECT …
--  FROM EMP
-- WHERE TO_NUMBER(EMP_TYPE)=123

--因为内部发生的类型转换，这个索引将不会被用到。
--
--几点注意：
--
--当比较不同数据类型的数据时，ORACLE自动对列进行简单的类型转换。
--如果在索引列上面进行了隐式类型转换，在查询的时候将不会用到索引。
--注意当字符和数值比较时，ORACLE会优先转换数值类型到字符类型。
--为了避免ORACLE对SQL进行隐式的类型转换，最好把类型转换用显式表现出来。
--32. 使用提示（Hints）
--
--FULL hint 告诉ORACLE使用全表扫描的方式访问指定表。
--ROWID hint 告诉ORACLE使用TABLE ACCESS BY ROWID的操作访问表。
--CACHE hint 来告诉优化器把查询结果数据保留在SGA中。
--INDEX Hint 告诉ORACLE使用基于索引的扫描方式。
--其他的Oracle Hints
--
--ALL_ROWS
--FIRST_ROWS
--RULE
--USE_NL
--USE_MERGE
--USE_HASH 等等。
--这是一个很有技巧性的工作。建议只针对特定的，少数的SQL进行hint的优化。
--
--33. 几种不能使用索引的WHERE子句
--
--（1）下面的例子中，‘!=’ 将不使用索引 ，索引只能告诉你什么存在于表中，而不能告诉你什么不存在于表中。
--
--不使用索引：
--
-- SELECT ACCOUNT_NAME
--      FROM TRANSACTION
--   WHERE AMOUNT !=0；
--使用索引：
--
--SELECT ACCOUNT_NAME
--      FROM TRANSACTION
--    WHERE AMOUNT > 0；
--（2）下面的例子中，‘||’是字符连接函数。就象其他函数那样，停用了索引。
--
--不使用索引：
--
--SELECT ACCOUNT_NAME，AMOUNT
--  FROM TRANSACTION
--WHERE ACCOUNT_NAME||ACCOUNT_TYPE=’AMEXA’；
--使用索引：

SELECT ACCOUNT_NAME，AMOUNT
  FROM TRANSACTION
WHERE ACCOUNT_NAME = ‘AMEX’
     AND ACCOUNT_TYPE=’ A’；
--（3）下面的例子中，‘+’是数学函数。就象其他数学函数那样，停用了索引。
--
--不使用索引：
--
--SELECT ACCOUNT_NAME，AMOUNT
--  FROM TRANSACTION
--WHERE AMOUNT + 3000 >5000；
--使用索引：
--
--SELECT ACCOUNT_NAME，AMOUNT
--FROM TRANSACTION
--WHERE AMOUNT > 2000 ；
--（4）下面的例子中，相同的索引列不能互相比较，这将会启用全表扫描。
--
--不使用索引：
--
--SELECT ACCOUNT_NAME, AMOUNT
--FROM TRANSACTION
--WHERE ACCOUNT_NAME = NVL(:ACC_NAME, ACCOUNT_NAME)
--使用索引：
--
SELECT ACCOUNT_NAME，AMOUNT
FROM TRANSACTION
WHERE ACCOUNT_NAME LIKE NVL(:ACC_NAME, ’%’)
--34. 连接多个扫描
--
--如果对一个列和一组有限的值进行比较，优化器可能执行多次扫描并对结果进行合并连接。
--
--举例：
--
--SELECT *
--      FROM LODGING
--    WHERE MANAGER IN (‘BILL GATES’, ’KEN MULLER’)
--优化器可能将它转换成以下形式：
--
    SELECT *
      FROM LODGING
    WHERE MANAGER = ‘BILL GATES’
           OR MANAGER = ’KEN MULLER’
--35. CBO下使用更具选择性的索引
--
--基于成本的优化器（CBO，Cost-Based Optimizer）对索引的选择性进行判断来决定索引的使用是否能提高效率。
--如果检索数据量超过30%的表中记录数，使用索引将没有显著的效率提高。
--在特定情况下，使用索引也许会比全表扫描慢。而通常情况下，使用索引比全表扫描要块几倍乃至几千倍！
--36. 避免使用耗费资源的操作
--
--带有DISTINCT，UNION，MINUS，INTERSECT，ORDER BY的SQL语句会启动SQL引擎执行耗费资源的排序（SORT）功能。DISTINCT需要一次排序操作，而其他的至少需要执行两次排序。
--通常，带有UNION，MINUS，INTERSECT的SQL语句都可以用其他方式重写。






--37. 优化GROUP BY
--
--提高GROUP BY语句的效率，可以通过将不需要的记录在GROUP BY之前过滤掉。
--
--低效：
--
-- SELECT JOB ，AVG（SAL）
--    FROM EMP
--  GROUP BY JOB
--HAVING JOB = ‘PRESIDENT’
--         OR JOB = ‘MANAGER’
--高效：
--
SELECT JOB，AVG（SAL）
   FROM EMP
WHERE JOB = ‘PRESIDENT’
        OR JOB = ‘MANAGER’
GROUP BY JOB

--38. 使用日期
--
--当使用日期时，需要注意如果有超过5位小数加到日期上，这个日期会进到下一天!
--

SELECT TO_DATE（‘01-JAN-93’+.99999）
  FROM DUAL
--Returns：
--’01-JAN-93 23:59:59’

SELECT TO_DATE（‘01-JAN-93’+.999999）
  FROM DUAL
--Returns：
--’02-JAN-93 00:00:00’

--39. 使用显示游标(CURSORS)
--使用隐式的游标，将会执行两次操作。第一次检索记录，第二次检查TOO MANY ROWS 这个exception。而显式游标不执行第二次操作。


--40. 分离表和索引
--
--总是将你的表和索引建立在不同的表空间内（TABLESPACES）。
--决不要将不属于ORACLE内部系统的对象存放到SYSTEM表空间里。
--确保数据表空间和索引表空间置于不同的硬盘上。


系统性能
并发访问 用户感到延迟 体验度
web应用充斥的时代
设计系统时  用户的体验度

--什么情况下要优化？
劣质SQL：对系统性能带来严重负面影响的SQL
1.运行时间超长
2、引发严重的等待事件  等待时间过长
	更强调事务交互时产生的等待造成的不良影响
并发

一个人去银行用存折取钱
另一个人也去银行用卡取钱

如果sql编写不当 会造成两个人互相等待  死锁

3.不能满足压力测试 模拟实际环境
通过大数据大并发来测试系统的抗压能力

春运 查询考试成绩
劣质SQL系统设计的问题　

4.消耗大量的系统资源
CPU
IO
物理存储的读取
内存

--优化技巧

a. 应尽量避免在 where 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描。

b. 应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如： select id from t where num=10 or num=20 可以这样查询： select id from t where num=10 union all select id from t where num=20

c. in 和 not in 也要慎用，否则会导致全表扫描，如： select id from t where num in(1,2,3) 对于连续的数值，能用 between 就不要用 in 了： select id from t where num between 1 and 3

d. 下面的查询也将导致全表扫描： select id from t where name like ‘%abc%’

e. 如果在 where 子句中使用参数，也会导致全表扫描。因为SQL只有在运行时才会解析局部变量，但优化程序不能将访问计划的选择推迟到运行时；它必须在编译时进行选择。然而，如果在编译时建立访问计划，变量的值还是未知的，因而无法作为索引选择的输入项。如下面语句将进行全表扫描： select id from t where num=@num 可以改为强制查询使用索引： select id from t with(index(索引名)) where num=@num

f. 应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如： select id from t where num/2=100 应改为: select id from t where num=100*2

g. 应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如： select id from t where substring(name,1,3)=’abc’–name以abc开头的id select id from t where datediff(day,createdate,’2005-11-30′)=0–‘2005-11-30’生成的id 应改为: select id from t where name like ‘abc%’ select id from t where createdate>=’2005-11-30′ and createdate<’2005-12-1′

h. 不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。

i. 不要写一些没有意义的查询，如需要生成一个空表结构： select col1,col2 into #t from t where 1=0 这类代码不会返回任何结果集，但是会消耗系统资源的，应改成这样： create table #t(…)

j. 很多时候用 exists 代替 in 是一个好的选择： select num from a where num in(select num from b) 用下面的语句替换： select num from a where exists(select 1 from b where num=a.num)

k. 任何地方都不要使用 select * from t ，用具体的字段列表代替“*”，不要返回用不到的任何字段。

l. 尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写。

m. 尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理。

n. 尽量避免大事务操作，提高系统并发能力。




　SELECT *
　　FROM (SELECT a.*, ROWNUM NUM
　　FROM (SELECT *
　　FROM b
　　WHERE 1 = 1
　　AND type = '10'
　　AND s_cd = '1000'
　　AND name LIKE '%xxx%'
　　ORDER BY (SELECT NVL(TO_NUMBER(REPLACE(TRANSLATE(des, REPLACE(TRANSLATE(des, '0123456789', '##########'), '#', ''), RPAD('#', 20, '#')), '#', '')), '0')
　　FROM b_PRICE B
　　WHERE max_price = '1'
　　AND B.id = b.id),
　　name) a)
　　WHERE NUM > 1 AND NUM <= 20
　　这个ORDER BY需要全表扫描才能得到所需数据，而且函数嵌套了多层，不好处理。因为上面这个替换语句的目的是只保留字符串中的数字，于是笔者给他提供了一个正则：
　
　ORDER BY regexp_replace(des, '[^0-9]', '')
　　这个语句确认结果后，把语句改成了10.1节中讲过的样式：


　　SELECT *
　　FROM (SELECT a.*, rownum num
　　FROM (SELECT a.*
　　FROM b a
　　INNER JOIN b_price b ON (b.id = a.id)
　　WHERE 1 = 1
　　AND b.max_price = '1'
　　AND a.type = '10'
　　AND a.s_cd = '1000'
　　AND a.name LIKE '%xxx%'
　　ORDER BY regexp_replace(des, '[^0-9]', '')) a
　　WHERE num <= 20)
　　WHERE num > 1;
--　　注意上面两个分页条件的位置，这样更改后，把过滤列与regexp_replace(des, '[^0-9]', '')一起放在组合索引里，优化就到此结束

-----------并行----------

  --并行处理,添加定时任务
  PROCEDURE proc_multi_task_exec(p_interface_name          IN   VARCHAR2,
                                 p_scheduler_start_date    IN   DATE)
  AS
    v_job_num                 NUMBER(20,0);
  BEGIN
    dbms_job.submit(
                      job => v_job_num,
                      what => p_interface_name,
                      next_date => p_scheduler_start_date
                   );
    COMMIT;
  END proc_multi_task_exec;
CREATE OR REPLACE PACKAGE lar_comm_logger_pkg IS
  /*插入日志*/
  PROCEDURE proc_insert_pol_ben_log(p_proc_date    IN DATE,
                                    p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_process_name IN pol_ben_log.process_name%TYPE,
                                    p_remark       IN pol_ben_log.remark%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE);

  /*更新日志*/
  PROCEDURE proc_update_pol_ben_log(p_proc_date    IN DATE,
                                    p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_remark       IN pol_ben_log.remark%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE);

  /*清理日志*/
  PROCEDURE proc_delete_pol_ben_log(p_proc_date    IN DATE,
                                    p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE);
  /*插入错误以及异常日志*/
  PROCEDURE proc_insert_pala_trace_log(v_log_date       IN DATE,
                                       v_log_type       IN lar_pala_trace_log.log_type%TYPE,
                                       v_pkg_name       IN lar_pala_trace_log.pkg_name%TYPE,
                                       v_interface_name IN lar_pala_trace_log.interface_name%TYPE,
                                       p_remark         IN lar_pala_trace_log.remark%TYPE,
                                       v_description    IN lar_pala_trace_log.description%TYPE,
                                       p_lbs_brch       IN lar_pala_trace_log.lbs_brch%TYPE);
  /*插入审计日志*/
  PROCEDURE proc_insert_trace_log(p_log_type       IN lar_pala_trace_log.log_type%TYPE,
                                  p_pkg_name       IN lar_pala_trace_log.pkg_name%TYPE,
                                  p_interface_name IN lar_pala_trace_log.interface_name%TYPE,
                                  p_description    IN lar_pala_trace_log.description%TYPE,
                                  p_lbs_brch       IN lar_pala_trace_log.lbs_brch%TYPE,
                                  p_remark         IN lar_pala_trace_log.remark%TYPE,
                                  p_id             OUT lar_pala_trace_log.id_lar_pala_trace_log%TYPE);

  /*更新审计日志*/
  PROCEDURE proc_update_trace_log(p_id     IN lar_pala_trace_log.id_lar_pala_trace_log%TYPE,
                                  p_remark IN lar_pala_trace_log.remark%TYPE);

  /*插入日志返回ID*/
  PROCEDURE proc_insert_pol_ben_log_re(p_process_code IN pol_ben_log.process_code%TYPE,
                                       p_process_name IN pol_ben_log.process_name%TYPE,
                                       p_remark       IN pol_ben_log.remark%TYPE,
                                       p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE,
                                       p_data_type    IN pol_ben_log.data_type%TYPE,
                                       p_id           OUT pol_ben_log.id_pol_ben_log%TYPE);

  /*根据ID更新日志*/
  PROCEDURE proc_update_pol_ben_log_re(p_id     IN pol_ben_log.id_pol_ben_log%TYPE,
                                       p_remark IN pol_ben_log.remark%TYPE);

END lar_comm_logger_pkg;
CREATE OR REPLACE PACKAGE BODY lar_comm_logger_pkg IS
  /* 插入日志*/
  PROCEDURE proc_insert_pol_ben_log(p_proc_date    IN DATE,
                                    p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_process_name IN pol_ben_log.process_name%TYPE,
                                    p_remark       IN pol_ben_log.remark%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE) IS
  BEGIN
    INSERT INTO pol_ben_log
      (proc_date, process_code, process_name, remark, lbs_brch)
    VALUES
      (p_proc_date, p_process_code, p_process_name, p_remark, p_lbs_brch);
    COMMIT;
  END proc_insert_pol_ben_log;

  /*更新日志*/
  PROCEDURE proc_update_pol_ben_log(p_proc_date    IN DATE,
                                    p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_remark       IN pol_ben_log.remark%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE) IS
  BEGIN
    UPDATE pol_ben_log
       SET remark = p_remark, updated_date = SYSDATE
     WHERE proc_date = p_proc_date
       AND process_code = p_process_code
       AND lbs_brch = p_lbs_brch
       AND remark IS NULL;

    COMMIT;
  END proc_update_pol_ben_log;

  /*清理日志*/
  PROCEDURE proc_delete_pol_ben_log(p_proc_date    IN DATE,
                                    p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE) IS
  v_delete_count varchar2(10);
  v_delete_switch  varchar2(10);
  BEGIN
--判断是否删除日志开关
  SELECT COUNT(*)
    INTO v_delete_count
    FROM LAR_ACTION_CONTROL_PALA T
   WHERE T.ACTION_NAME = 'is_pol_ben_log_del';
  IF v_delete_count > 0 THEN
    SELECT ACTION_VALUE
    	INTO v_delete_switch
    	FROM LAR_ACTION_CONTROL_PALA T
  		 WHERE T.ACTION_NAME = 'is_pol_ben_log_del';
         IF v_delete_switch='Y' THEN
		    delete from pol_ben_log
		     WHERE proc_date = p_proc_date
		       AND process_code = p_process_code
		       AND lbs_brch = p_lbs_brch;
		   	   COMMIT;
		 END IF;
  ELSE
    delete from pol_ben_log
		     WHERE proc_date = p_proc_date
		       AND process_code = p_process_code
		       AND lbs_brch = p_lbs_brch;
		   	   COMMIT;
  END IF;
  END proc_delete_pol_ben_log;

  /*插入错误以及异常日志*/
  PROCEDURE proc_insert_pala_trace_log(v_log_date    IN DATE,
                                    v_log_type IN lar_pala_trace_log.log_type%TYPE,
                                    v_pkg_name IN lar_pala_trace_log.pkg_name%TYPE,
                                    v_interface_name IN lar_pala_trace_log.interface_name%TYPE,
                                    p_remark       IN lar_pala_trace_log.remark%TYPE,
                                    v_description  IN lar_pala_trace_log.description%TYPE,
                                    p_lbs_brch     IN lar_pala_trace_log.lbs_brch%TYPE) IS
  BEGIN
      INSERT INTO LAR_PALA_TRACE_LOG
        (LOG_DATE, LOG_TYPE, PKG_NAME, INTERFACE_NAME, REMARK, DESCRIPTION, LBS_BRCH)
      VALUES
        (SYSDATE, v_log_type, v_pkg_name, v_interface_name, p_remark, v_description, p_lbs_brch);
    COMMIT;
  END proc_insert_pala_trace_log;

  /*插入审计日志*/
  PROCEDURE proc_insert_trace_log(p_log_type       IN lar_pala_trace_log.log_type%TYPE,
                                  p_pkg_name       IN lar_pala_trace_log.pkg_name%TYPE,
                                  p_interface_name IN lar_pala_trace_log.interface_name%TYPE,
                                  p_description    IN lar_pala_trace_log.description%TYPE,
                                  p_lbs_brch       IN lar_pala_trace_log.lbs_brch%TYPE,
                                  p_remark         IN lar_pala_trace_log.remark%TYPE,
                                  p_id             OUT lar_pala_trace_log.id_lar_pala_trace_log%TYPE) IS
  v_sqlerrm varchar2(510);
  BEGIN
    INSERT INTO lar_pala_trace_log a
      (log_date, log_type, pkg_name, interface_name, description, lbs_brch, remark)
    VALUES
      (SYSDATE,
       p_log_type,
       p_pkg_name,
       p_interface_name,
       p_description,
       p_lbs_brch,
       p_remark)
    RETURNING id_lar_pala_trace_log INTO p_id;
    COMMIT;
		EXCEPTION
	    WHEN OTHERS THEN
	    v_sqlerrm := SQLERRM;
	    INSERT INTO lar_pala_trace_log a
	      (log_date, log_type, pkg_name, interface_name, description, lbs_brch, remark)
	    VALUES
	      (SYSDATE,'ERROR','lar_comm_logger_pkg','proc_insert_trace_log','插入审计日志','','出现异常:' || substr(v_sqlerrm, 1, 400));
	    COMMIT;
  END proc_insert_trace_log;

  /*更新审计日志*/
  PROCEDURE proc_update_trace_log(p_id     IN lar_pala_trace_log.id_lar_pala_trace_log%TYPE,
                                  p_remark IN lar_pala_trace_log.remark%TYPE) IS
  v_sqlerrm varchar2(510);
  BEGIN
    UPDATE lar_pala_trace_log
       SET remark = substr(remark || '-' || p_remark,1,300), updated_date = SYSDATE
     WHERE id_lar_pala_trace_log = p_id;
    COMMIT;
  	EXCEPTION
	    WHEN OTHERS THEN
	    v_sqlerrm := SQLERRM;
	    INSERT INTO lar_pala_trace_log a
	      (log_date, log_type, pkg_name, interface_name, description, lbs_brch, remark)
	    VALUES
	      (SYSDATE,'ERROR','lar_comm_logger_pkg','proc_update_trace_log','更新审计日志','','出现异常:' || substr(v_sqlerrm, 1, 400));
	    COMMIT;
  END proc_update_trace_log;
   /*插入日志返回ID*/
  PROCEDURE proc_insert_pol_ben_log_re( p_process_code IN pol_ben_log.process_code%TYPE,
                                    p_process_name IN pol_ben_log.process_name%TYPE,
                                    p_remark       IN pol_ben_log.remark%TYPE,
                                    p_lbs_brch     IN pol_ben_log.lbs_brch%TYPE,
                                    p_data_type     IN pol_ben_log.data_type%TYPE,
                                    p_id           OUT pol_ben_log.id_pol_ben_log%TYPE) IS
  v_sqlerrm varchar2(510);
  v_proc_date DATE;
  BEGIN
  v_proc_date:=lar_pol_comm_pkg.get_kettle_proc_date(p_process_code);

     INSERT INTO pol_ben_log

      (proc_date, process_code, process_name, remark, lbs_brch,data_type)
    VALUES
      (v_proc_date, p_process_code, p_process_name, p_remark, p_lbs_brch,p_data_type)
    RETURNING id_pol_ben_log INTO p_id;
    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
      v_sqlerrm := SQLERRM;
      INSERT INTO lar_pala_trace_log a
        (log_date, log_type, pkg_name, interface_name, description, lbs_brch, remark)
      VALUES
        (SYSDATE,'ERROR','lar_comm_logger_pkg','proc_insert_pol_ben_log_re','插入日志返回ID','','出现异常:' || substr(v_sqlerrm, 1, 400));
      COMMIT;
  END proc_insert_pol_ben_log_re;

  /*根据ID更新日志*/
  PROCEDURE proc_update_pol_ben_log_re(p_id     IN pol_ben_log.id_pol_ben_log%TYPE,
                                  p_remark IN pol_ben_log.remark%TYPE) IS
  v_sqlerrm varchar2(510);
  BEGIN
    UPDATE pol_ben_log
       SET remark = substr(p_remark,1,300), updated_date = SYSDATE
     WHERE id_pol_ben_log = p_id;
    COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
      v_sqlerrm := SQLERRM;
      INSERT INTO lar_pala_trace_log a
        (log_date, log_type, pkg_name, interface_name, description, lbs_brch, remark)
      VALUES
        (SYSDATE,'ERROR','lar_comm_logger_pkg','proc_update_pol_ben_log_re','根据ID更新日志','','出现异常:' || substr(v_sqlerrm, 1, 400));
      COMMIT;
  END proc_update_pol_ben_log_re;
END lar_comm_logger_pkg;


oracle 中的not Exists与Not in的性能巨大差异
Not Exists与Not in的作用同样是排除数据,在oracle 中使用not in并不象mysql中的执行那么快,如(
select jt1.doc_num --单据号码
      ,oalc.description school_name --学校名称
      ,oalc2.description system_name --系名称
      ,oalc.description class_name --班级名称
  from java_table1            jt1
      ,java_table_description oalc
      ,java_table_description oalc2
      ,java_table_description oalc3
where oalc.lookup_type(+) = 'JAVA_SCHOOL_NAME'
   and jt1.school_id = oalc.lookup_code(+)
   and oalc2.lookup_type(+) = 'JAVA_SYSTEM_NAME'
   and jt1.system_id = oalc2.lookup_code(+)
   and oalc3.lookup_type(+) = 'JAVA_CLASS_NAME'
   and jt1.class_id = oalc3.lookup_code(+)
   and not exists
(select jt2.header_id
          from java_table2 jt2 jt1.header_id = jt2.header_id))

与

select jt1.doc_num --单据号码
      ,oalc.description school_name --学校名称
      ,oalc2.description system_name --系名称
      ,oalc.description class_name --班级名称
  from java_table1            jt1
      ,java_table_description oalc
      ,java_table_description oalc2
      ,java_table_description oalc3
where oalc.lookup_type(+) = 'JAVA_SCHOOL_NAME'
   and jt1.school_id = oalc.lookup_code(+)
   and oalc2.lookup_type(+) = 'JAVA_SYSTEM_NAME'
   and jt1.system_id = oalc2.lookup_code(+)
   and oalc3.lookup_type(+) = 'JAVA_CLASS_NAME'
   and jt1.class_id = oalc3.lookup_code(+)
   and jt1.header_id not in (select jt2.header_id from java_table2 jt2)

当jt2表中的数据比较大时,就会出现巨大的差异,以上只能是我的个人理解与测试结果(java_table1 视图测试

数据量为36749,java_table2 为300条),如有其它可相互讨论


--替代优化

1、用>=替代>
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id>=10
  与
  select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id>9
  执行时>=会比>执行得要快

2、用UNION替换OR (适用于索引列)
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=10
  union
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=2
   上面语句可有效避免全表查询
   select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=10
  or ui.student_id=2
  如果坚持要用OR, 可以把返回记录最少的索引列写在最前面

3、用in 代替or
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=10
  or ui.student_id=20
  or ui.student_id=30
  改成
  select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id in (10,20,30)
  执行会更有效率

4、 Union All 与Union
Union All重复输出两个结果集合中相同记录
如果两个并集中数据都不一样.那么使用Union All 与Union是没有区别的,
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=10
  union All
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=2
  与
  select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=10
  union
select ui.user_name
  from user_info ui--员工信息表
  where ui.student_id=2
但Union All会比Union要执行得快

5、分离表和索引
总是将你的表和索引建立在另外的表空间内
决不要将这些对象存放到SYSTEM表空间里

--一些优化技巧
1、计算表的记录数时
select count(si.student_id)
from Student_info si(student_id为索引)
与
select count(*) from Student_info si
执行时.上面的语句明显会比下面没有用索引统计的语句要快

2.使用函数提高SQL执行速度
当出现复杂的查询sql语名,可以考虑使用函数来提高速度
查询学生信息并查询学生(李明)个人信息与的数学成绩排名
如
select di.description student_name
      ,(select res.order_num--排名
         from result res
        where res.student_id = di.student_id
        order by result_math) order_num
  from description_info di
      ,student_info     si --学生信息表
where si.student_id = di.lookup_code(+)
   and di.lookup_type(+) = 'STUDENT_ID'
   and di.description = '李明'

而且我们将上面order_num排名写成一个fuction时
create or replace package body order_num_pkg is
function order_num(p_student_id number) return_number is
  v_return_number number;
begin
  select res.order_num --排名
    into v_return_number
    from result res
   where res.student_id = di.student_id
   order by result_math;
  return v_return_number;
exception
  when others then
    null;
    return null;
end;
end order_num_pkg;
执行
select di.description student_name
      ,order_num_pkg.order_num(di.student_id) order_num
  from description_info di
      ,student_info     si --学生信息表
where si.student_id = di.lookup_code(+)
   and di.lookup_type(+) = 'STUDENT_ID'
   and di.description = '李明'
执行查询时的速度也会有所提高

3.减少访问数据库的次数
执行次数的减少(当要查询出student_id=100的学生和student_id=20的学生信息时)
select address_id
from student_info si --学生信息表
where si.student_id=100
与
select address_id
from student_info si --学生信息表
where si.student_id=20
都进行查询.这样的效率是很低的
而进行
(
select si.address_id,si2.address_id
from student_info si --学生信息表
,student_info si2
where si.student_id=100
and si2.student_id=20
与
select decode(si.student_id,100,address_id)
   ,decode(si.student_id,20,address_id)
from student_info si
)
执行速度是提高了,但可读性反而差了..
所以这种写法个人并不太推荐

4、用Exists(Not Exists)代替In(Not In)
   在执行当中使用Exists或者Not Exists可以高效的进行查询
5、Exists取代Distinct取唯一值的
   取出关联表部门对员工时,这时取出员工部门时,出现多条..
select distinct di.dept_name
  from departments_info di --部门表
      ,user_info        ui --员工信息表
where ui.dept_no = di.dept_no
   可以修改成
  select di.dept_name
    from departments_info di --部门表
   where  exists (select 'X'
            from user_info ui --员工信息表
           where di.dept_no = ui.dept_no)

6、用表连接代替Exists
 通过表的关联来代替exists会使执行更有效率
select ui.user_name
  from user_info ui--员工信息表
where exists (select 'x '
          from departments_info di--部门表
         where di.dept_no = ui.dept_no
           and ui.dept_cat = 'IT');
执行是比较快,但还可以使用表的连接取得更快的查询效率
   select ui.user_name
    from departments_info di
        ,user_info        ui --员工信息表
   where ui.dept_no = di.dept_no
     and ui.department_type_code = 'IT'


a. 应尽量避免在 where 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描。

b. 应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如： select id from t where num=10 or num=20 可以这样查询： select id from t where num=10 union all select id from t where num=20

c. in 和 not in 也要慎用，否则会导致全表扫描，如： select id from t where num in(1,2,3) 对于连续的数值，能用 between 就不要用 in 了： select id from t where num between 1 and 3

d. 下面的查询也将导致全表扫描： select id from t where name like ‘%abc%’

e. 如果在 where 子句中使用参数，也会导致全表扫描。因为SQL只有在运行时才会解析局部变量，但优化程序不能将访问计划的选择推迟到运行时；它必须在编译时进行选择。然而，如果在编译时建立访问计划，变量的值还是未知的，因而无法作为索引选择的输入项。如下面语句将进行全表扫描： select id from t where num=@num 可以改为强制查询使用索引： select id from t with(index(索引名)) where num=@num

f. 应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如： select id from t where num/2=100 应改为: select id from t where num=100*2

g. 应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如： select id from t where substring(name,1,3)=’abc’–name以abc开头的id select id from t where datediff(day,createdate,’2005-11-30′)=0–‘2005-11-30’生成的id 应改为: select id from t where name like ‘abc%’ select id from t where createdate>=’2005-11-30′ and createdate<’2005-12-1′

h. 不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。

i. 不要写一些没有意义的查询，如需要生成一个空表结构： select col1,col2 into #t from t where 1=0 这类代码不会返回任何结果集，但是会消耗系统资源的，应改成这样： create table #t(…)

j. 很多时候用 exists 代替 in 是一个好的选择： select num from a where num in(select num from b) 用下面的语句替换： select num from a where exists(select 1 from b where num=a.num)

k. 任何地方都不要使用 select * from t ，用具体的字段列表代替“*”，不要返回用不到的任何字段。

l. 尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写。

m. 尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理。

n. 尽量避免大事务操作，提高系统并发能力。

1.表名顺序优化

(1) 基础表放下面,当两表进行关联时数据量少的表的表名放右边
表或视图:
Student_info   (30000条数据)
Description_info (30条数据)
select *
  from description_info di
      ,student_info     si --学生信息表
where si.student_id = di.lookup_code(+)
   and di.lookup_type(+) = 'STUDENT_ID'
与
select *
  from student_info     si--学生信息表
      ,description_info di
where si.student_id = di.lookup_code(+)
   and di.lookup_type(+) = 'STUDENT_ID'
以student_info作为基础表,你会发现运行的速度会有很大的差距。


(2) 当出现多个表时,关联表被称之为交叉表,交叉表作为基础表
select *
  from description_info di
    ,description_info di2
      ,student_info     si --学生信息表
where si.student_id = di.lookup_code(+)
   and di.lookup_type(+) = 'STUDENT_ID'
   and si.school_id = di.lookup_code(+)
   and di.lookup_type(+) = 'SCHOOL_ID'
与
select *
  from student_info     si--学生信息表
      ,description_info di
      ,description_info di2
where si.student_id = di.lookup_code(+)
   and di.lookup_type(+) = 'STUDENT_ID'
   and si.school_id = di.lookup_code(+)
   and di.lookup_type(+) = 'SCHOOL_ID'
以student_info作为基础表,你会发现运行的速度会有很大的差距,
当基础表放在后面,这样的执行速度会明显快很多。

2.where执行顺序

where执行会从至下往上执行
select *
from student_info si --学生信息表
where si.school_id=10 --学院ID
and  si.system_id=100--系ID
摆放where子句时,把能过滤大量数据的条件放在最下边

3. is null 和is not null

当要过滤列为空数据或不为空的数据时使用
select *
from student_info si --学生信息表
where si.school_id is null(当前列中的null为少数时用is not null,否则is null)

4.使用表别名

当查询时出现多个表时,查询时加上别名,
避免出现减少解析的时间字段歧义引起的语法错误。

5. where执行速度比having快

尽可能的使用where代替having
select  from student_info si
group by si.student_id
having si.system_id!=100
  and si.school_id!=10
(select  from student_info si
wehre si.system_id!=100
and si.school_id!=10
group by si.student_id)

6.  * 号引起的执行效率

尽量减少使用select * 来进行查询,当你查询使用*,
数据库会进行解析并将*转换为全部列。

查询表中的记录总数的语法就是SELECT COUNT(*) FROM TABLE_NAME。这可能是最经常使用的一类SQL语句。

根据执行时间的长短进行判断偶然性比较大，本文以没种方法逻辑读的多少来进行判断。

由于包括查询重写（需要的相对较多的执行计划的分析）和索引压缩（属于CPU密集型，消耗CPU资源较多），仅仅用逻辑读来衡量各种方法的优劣肯定不会很准确，

但是考虑到表中的数据量比较大，而且我们以SQL的第二次执行结果为准，所以，其他方面的影响还是可以忽略的。

另外一个前提就是结果的准确性，查询USER_TABLES的NUM_ROWS列等类似的方法不在本文讨论范畴之内。


最后，由于ORACLE的缓存和共享池的机制，SQL语句逻辑读一般从第二次执行才稳定下来，

出于篇幅的考虑，下面所有的SELECT COUNT(*) FROM T的结果都是该SQL语句第二次执行的结果。



如果存在一个查询语句为SELECT COUNT(*)的物化视图，则最快的方式一定是扫描这张物化视图。



SQL> CREATE TABLE T (ID NUMBER NOT NULL, NAME VARCHAR2(30), TYPE VARCHAR2(18));

表已创建。

SQL> INSERT INTO T SELECT ROWNUM, OBJECT_NAME, OBJECT_TYPE FROM DBA_OBJECTS;

已创建30931行。

SQL> COMMIT;

提交完成。

SQL> CREATE MATERIALIZED VIEW LOG ON T WITH ROWID INCLUDING NEW VALUES;

实体化视图日志已创建。

SQL> CREATE MATERIALIZED VIEW MV_T REFRESH FAST ON COMMIT ENABLE QUERY REWRITE AS
2 SELECT COUNT(*) FROM T;

实体化视图已创建。

SQL> ALTER SESSION SET QUERY_REWRITE_ENABLED = TRUE;

会话已更改。

SQL> EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'T')

PL/SQL 过程已成功完成。

SQL> SET AUTOT ON
SQL> SELECT COUNT(*) FROM T;

COUNT(*)
----------
30931

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT Optimizer=CHOOSE (Cost=2 Card=82 Bytes=1066)
1 0 TABLE ACCESS (FULL) OF 'MV_T' (Cost=2 Card=82 Bytes=1066)

Statistics
----------------------------------------------------------
0 recursive calls
0 db block gets
3 consistent gets
0 physical reads
0 redo size
378 bytes sent via SQL*Net to client
503 bytes received via SQL*Net from client
2 SQL*Net roundtrips to/from client
0 sorts (memory)
0 sorts (disk)
1 rows processed

根据上面的查询可以看出，扫描物化视图，只需3个逻辑读就可以了。
但是，物化视图对系统的限制比较多。
首先要创建物化视图日志，还要在SYSTEM或SESSION级设置参数，必须使用CBO等很多的条件，限制了物化视图的使用，
而且最重要的是，一般情况下不会存在一个单纯查询全表记录数的物化视图，而一般建立的物化视图是为了加快一些更加复杂的表连接或聚集的查询的。
因此，即使存在物化视图，也不会直接得到结果，一般是对物化视图上的结果进行再次计算。

如果不考虑物化视图，那么得到记录总数的最快的方法一定是BITMAP索引扫描。
BITMAP索引的机制使得BITMAP索引回答COUNT(*)之类的查询具有最快的响应速度和最小的逻辑读。
至于BITMAP索引的机制，这里就不重复描述了，还是看看BITMAP索引的表现吧：

SQL> DROP MATERIALIZED VIEW MV_T;

实体化视图已删除。

SQL> DROP MATERIALIZED VIEW LOG ON T;

实体化视图日志已删除。

SQL> CREATE BITMAP INDEX IND_B_T_TYPE ON T (TYPE);

索引已创建。

SQL> EXEC DBMS_STATS.GATHER_INDEX_STATS(USER, 'IND_B_T_TYPE')

PL/SQL 过程已成功完成。

SQL> SELECT COUNT(*) FROM T;

COUNT(*)
----------
30931

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT Optimizer=CHOOSE (Cost=2 Card=1)
1 0 SORT (AGGREGATE)
2 1 BITMAP CONVERSION (COUNT)
3 2 BITMAP INDEX (FAST FULL SCAN) OF 'IND_B_T_TYPE'

Statistics
----------------------------------------------------------
0 recursive calls
0 db block gets
5 consistent gets
0 physical reads
0 redo size
378 bytes sent via SQL*Net to client
503 bytes received via SQL*Net from client
2 SQL*Net roundtrips to/from client
0 sorts (memory)
0 sorts (disk)
1 rows processed

可以看到，BITMAP索引的表现十分出色，只需5个逻辑读就可以得到结果。

可惜的是，BITMAP索引比较适合在数据仓库中使用，
而对于OLTP环境，BITMAP索引的锁粒度将给整个系统带来严重的灾难。
因此，对于OLTP系统，BITMAP索引也是不合适的。

不考虑BITMAP索引，那么速度最快的应该是普通索引的快速全扫了，比如主键列。

SQL> DROP INDEX IND_B_T_TYPE;

索引已丢弃。

SQL> ALTER TABLE T ADD CONSTRAINT PK_T PRIMARY KEY (ID);

表已更改。

SQL> SELECT COUNT(*) FROM T;

COUNT(*)
----------
30931

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT Optimizer=CHOOSE (Cost=4 Card=1)
1 0 SORT (AGGREGATE)
2 1 INDEX (FAST FULL SCAN) OF 'PK_T' (UNIQUE) (Cost=4 Card=30931)

Statistics
----------------------------------------------------------
0 recursive calls
0 db block gets
69 consistent gets
0 physical reads
0 redo size
378 bytes sent via SQL*Net to client
503 bytes received via SQL*Net from client
2 SQL*Net roundtrips to/from client
0 sorts (memory)
0 sorts (disk)
1 rows processed

主键的快速全扫只需69个逻辑读。但是由于主键这里用的是ROWNUM，也就是说是主键的值是从1到30931，Oracle存储这些NUMBER类型则需要2到4位不等。
如果建立一个常数索引，则在存储空间上要节省一些。而在执行索引快速全扫时，就能减少一些逻辑读。

SQL> CREATE INDEX IND_T_CON ON T(1);

索引已创建。

SQL> SELECT COUNT(*) FROM T;

COUNT(*)
----------
30931

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT Optimizer=CHOOSE (Cost=4 Card=1)
1 0 SORT (AGGREGATE)
2 1 INDEX (FAST FULL SCAN) OF 'IND_T_CON' (NON-UNIQUE) (Cost=4 Card=30931)

Statistics
----------------------------------------------------------
0 recursive calls
0 db block gets
66 consistent gets
0 physical reads
0 redo size
378 bytes sent via SQL*Net to client
503 bytes received via SQL*Net from client
2 SQL*Net roundtrips to/from client
0 sorts (memory)
0 sorts (disk)
1 rows processed

果然，扫描常数索引比扫描主键的逻辑读更小一些。
考虑到NUMBER类型中，1的存储需要两位，而0的存储只需一位，那么用0代替1创建常数索引，应该效果更好。

SQL> CREATE INDEX IND_T_CON_0 ON T(0);

索引已创建。

SQL> SELECT /*+ INDEX(T IND_T_CON_0) */ COUNT(*) FROM T;

COUNT(*)
----------
30931

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT Optimizer=CHOOSE (Cost=26 Card=1)
1 0 SORT (AGGREGATE)
2 1 INDEX (FULL SCAN) OF 'IND_T_CON_0' (NON-UNIQUE) (Cost=26 Card=30931)

Statistics
----------------------------------------------------------
0 recursive calls
0 db block gets
58 consistent gets
0 physical reads
0 redo size
378 bytes sent via SQL*Net to client
503 bytes received via SQL*Net from client
2 SQL*Net roundtrips to/from client
0 sorts (memory)
0 sorts (disk)
1 rows processed

由于常数索引中所有节点值都相同，如果压缩一下的话，应该还能减少逻辑读。

SQL> DROP INDEX IND_T_CON_0;

索引已丢弃。

SQL> CREATE INDEX IND_T_CON_COMPRESS ON T(0) COMPRESS;

索引已创建。

SQL> SELECT /*+ INDEX(T IND_T_CON_COMPRESS) */ COUNT(*) FROM T;

COUNT(*)
----------
30931

Execution Plan
----------------------------------------------------------
0 SELECT STATEMENT Optimizer=CHOOSE (Cost=26 Card=1)
1 0 SORT (AGGREGATE)
2 1 INDEX (FULL SCAN) OF 'IND_T_CON_COMPRESS' (NON-UNIQUE) (Cost=26 Card=30931)

Statistics
----------------------------------------------------------
0 recursive calls
0 db block gets
49 consistent gets
0 physical reads
0 redo size
378 bytes sent via SQL*Net to client
503 bytes received via SQL*Net from client
2 SQL*Net roundtrips to/from client
0 sorts (memory)
0 sorts (disk)
1 rows processed

和预计的一样，经过压缩，索引扫描的逻辑读进一步减少，现在和最初的主键扫描相比，逻辑读已经减少了30%。

如果只为了得到COUNT(*)，那么压缩过的常数索引是最佳选择，不过这个索引对其他查询是没有任何帮助的，
因此，实际中的用处不大。