









--任一  所有
 BEGIN
     /*计算计量单元级别-新单类别*/
     <!--向pol_init_measu_unit插入数据-->
     DECLARE
     v_result_code NUMBER(2);
     v_message varchar2(300);
     v_limit  number(10);
     CURSOR tmp_cur IS
     with category_flag_tmp as
     (
         SELECT region_sid,plan_code,
         1 as flag,
         case when C02=0 then
         1 else 0
         end flag11
         FROM (
         SELECT region_sid,plan_code,SUM(D41) D41,SUM(C02) C02
         FROM (
         SELECT plan_code,region_sid,
         CASE WHEN property='D41' THEN 1 ELSE 0 END D41,
         CASE WHEN property='C02' THEN 1 ELSE 0 END C02
         FROM PLAN_PROPERTY_TABLE
         ) GROUP BY plan_Code,region_sid  )
         WHERE D41>=1


         union


         SELECT region_sid, plan_code,2 as flag,0 as flag11 FROM (
         SELECT region_sid,plan_code,SUM(C20) C20,SUM(C03) c03,SUM(D41) d41
         FROM (
         SELECT plan_code,region_sid,
         CASE WHEN property='C20' THEN 1 ELSE 0 END c20,
         CASE WHEN property='C03' THEN 1 ELSE 0 END c03,
         CASE WHEN property='D41' THEN 1 ELSE 0 END D41
         FROM PLAN_PROPERTY_TABLE
         ) GROUP BY plan_Code,region_sid  )
         WHERE c20>=1 AND c03>=1 AND d41=0
     )

     select

         p.polno,
         p.brno,
         p.plan_code,
         p.deptno,
         p.tot_modal_prem,
         p.fcd,
         p.ben_sts,
         p.eff_date,
         p.first_eff_date,
         p.old_polno,
         p.channel_mode,
         p.sno,
         p.is_paa,
         p.currency_code,
         p.came_bonus_charac,
         p.region_sid,
         p.group_code,
         p.rank_paa_flag,
         p.rank,

         p.src_code,
         case
         when
         p.cnt1 > 0 and p.cnt11=p.cnt then '1'
         when
         p.cnt2 = p.cnt then '2'
         else
         /*新契约*/
         '3'
         end new_pol_category,

         p.pk_serial,
         p.start_time,
         p.end_time,
         p.prod_type_code,
         p.vfa_conseq_code,
         p.major_risk_conseq_code,
         p.prod_risk_prop_code

     from
     (
         SELECT a.*,
         COUNT(1) OVER(PARTITION BY a.polno,a.rank,a.region_sid ) cnt,
         SUM(CASE WHEN b.flag=1 THEN 1 ELSE 0 END ) OVER(PARTITION BY a.polno,a.rank,a.region_sid) cnt1,
         SUM(CASE WHEN b.flag11=1 THEN 1 ELSE 0 END ) OVER(PARTITION BY a.polno,a.rank,a.region_sid) cnt11,
         SUM(CASE WHEN b.flag=2 THEN 1 ELSE 0 END ) OVER(PARTITION BY a.polno,a.rank,a.region_sid) cnt2
         FROM act_cg_measu_unit_tmp  a
         LEFT JOIN category_flag_tmp b
         ON a.plan_code=b.plan_code AND a.region_sid=b.region_sid
     ) p;


     TYPE type_category_tmp IS TABLE OF tmp_cur%ROWTYPE INDEX BY PLS_INTEGER;
     v_act_cg_pol_init_category_tmp type_category_tmp;

     BEGIN
     v_limit := 10000;
     OPEN tmp_cur;

     pkg_truncate.truncate_table('ACTDATA','act_cg_pol_init_category_tmp','',v_result_code,v_message);
     IF nvl(v_result_code,9)<![CDATA[<>]]>0 THEN
     LOOP
     DELETE FROM act_cg_pol_init_category_tmp where rownum<![CDATA[<=]]>v_limit;
     IF SQL%ROWCOUNT=0 THEN
     EXIT;
     END IF;
     COMMIT;
     END LOOP;
     COMMIT;
     END IF;

     LOOP
     v_act_cg_pol_init_category_tmp.delete;
     FETCH tmp_cur BULK COLLECT
     INTO v_act_cg_pol_init_category_tmp LIMIT v_limit;
     EXIT WHEN v_act_cg_pol_init_category_tmp.count = 0;
     BEGIN
     FORALL idx IN v_act_cg_pol_init_category_tmp.first .. v_act_cg_pol_init_category_tmp.last
     INSERT INTO act_cg_pol_init_category_tmp(
     polno,
     brno,
     plan_code,
     deptno,
     tot_modal_prem,
     fcd,
     ben_sts,
     eff_date,
     first_eff_date,
     old_polno,
     channel_mode,
     sno,
     is_paa,
     currency_code,
     came_bonus_charac,
     region_sid,
     group_code,
     rank_paa_flag,
     rank,
     src_code,
     new_pol_category,
     pk_serial,
     start_time,
     end_time,
     prod_type_code,
     vfa_conseq_code,
     major_risk_conseq_code,
     prod_risk_prop_code
     ) VALUES (
     v_act_cg_pol_init_category_tmp (idx).polno,
     v_act_cg_pol_init_category_tmp (idx).brno,
     v_act_cg_pol_init_category_tmp (idx).plan_code,
     v_act_cg_pol_init_category_tmp (idx).deptno,
     v_act_cg_pol_init_category_tmp (idx).tot_modal_prem,
     v_act_cg_pol_init_category_tmp (idx).fcd,
     v_act_cg_pol_init_category_tmp (idx).ben_sts,
     v_act_cg_pol_init_category_tmp (idx).eff_date,
     v_act_cg_pol_init_category_tmp (idx).first_eff_date,
     v_act_cg_pol_init_category_tmp (idx).old_polno,
     v_act_cg_pol_init_category_tmp (idx).channel_mode,
     v_act_cg_pol_init_category_tmp (idx).sno,
     v_act_cg_pol_init_category_tmp (idx).is_paa,
     v_act_cg_pol_init_category_tmp (idx).currency_code,
     v_act_cg_pol_init_category_tmp (idx).came_bonus_charac,
     v_act_cg_pol_init_category_tmp (idx).region_sid,
     v_act_cg_pol_init_category_tmp (idx).group_code,
     v_act_cg_pol_init_category_tmp (idx).rank_paa_flag,
     v_act_cg_pol_init_category_tmp (idx).rank,
     v_act_cg_pol_init_category_tmp (idx).src_code,
     v_act_cg_pol_init_category_tmp (idx).new_pol_category,
     v_act_cg_pol_init_category_tmp (idx).pk_serial,
     v_act_cg_pol_init_category_tmp (idx).start_time,
     v_act_cg_pol_init_category_tmp (idx).end_time,
     v_act_cg_pol_init_category_tmp (idx).prod_type_code,
     v_act_cg_pol_init_category_tmp (idx).vfa_conseq_code,
     v_act_cg_pol_init_category_tmp (idx).major_risk_conseq_code,
     v_act_cg_pol_init_category_tmp (idx).prod_risk_prop_code
     );
     END;
     COMMIT;
     END LOOP;
     COMMIT;
     CLOSE tmp_cur;
     END;
     END;






alter table tablename add (column datatype [default value][null/not null],….);

alter table tablename modify (column datatype [default value][null/not null],….);

alter table tablename drop (column);

ALTER TABLE table_name RENAME TO new_table_name;

ALTER TABLE table_name RENAME COLUMN supplier_name to sname;

alter table TABLE_NAME rename column FIELD_NAME to NEW_FIELD_NAME;

comment  on  column  表名.字段名   is  '注释内容';

comment on table 表名  is  '注释内容';

 select p.*,
            case
              when c.ispaa is null then
               '新契约'
              else
               c.ispaa
            end new_pol_category

       from pol_init_endorse_is_newpol p
       left join (select polno, rank, '保证续保' as ispaa
                    from pol_init_endorse_is_newpol
                   where is_paa = '保证续保'
                   group by polno, rank

                  union all

                  select a.polno, a.rank, 'PAA' as ispaa
                    from (select polno, rank, count(plan_code) as cnt
                            from pol_init_endorse_is_newpol
                           where is_paa = 'PAA'
                           group by polno, rank) a,
                         (select polno, rank, count(plan_code) as cnt
                            from pol_init_endorse_is_newpol
                           group by polno, rank) b
                   where a.polno = b.polno
                     and a.rank = b.rank
                     and a.cnt = b.cnt

                  ) c
         on p.polno = c.polno
        and p.rank = c.rank;







Oracle查询优化改写  技巧与案例
https://blog.csdn.net/jgmydsai/article/category/2239703
============================================
null 不支持运算
select * from dept where 1>=null;
no rows selected


select replace('abcde','a',NULL) AS str FROM dual;

bcde
1 row selected

select greatest(1,null) from dual;

GREATEST(1,NULL)
NULL
1 row selected


select coalesce(c1,c2,c3,c4,c5,c6) AS c FROM V;
返回第一个不为null的值


select * from emp
where (deptno=10 or comm is not null or (sal<=2000 and deptno =20));

select 'TRUNCATE TABLE' || owner || '.' || table_name || ';' AS 清空表 FROM all_tables WHERE owner = 'SCOTT';


select ename,sal,
CASE
    WHEN sal <= 2000 THEN '过低'
    WHEN sal >= 4000 THEN '过高'
    ELSE 'OK'
END AS Status
FROM emp
WHERE  deptno = 10;

SELECT 档次，count(*) AS 人数
FROM  (
    select (
    CASE
    WHEN sal <= 1000 THEN '0000-1000'
    WHEN sal <= 2000 THEN '0000-1000'
    WHEN sal <= 3000 THEN '0000-1000'
    WHEN sal <= 4000 THEN '0000-1000'
    WHEN sal <= 5000 THEN '0000-1000'
    ELSE '好高'
    END) AS 档次,
    ename,
    sal
    FROM emp)
GROUP BY 档次
ORDER BY 1 ;



select * from emp where rownum <=2;


select * from (select rownum AS sn,emp.* FROM emp where rownum<=2) where sn = 2;

--随机
select empno,ename
From
(selecct empno,ename from emp order by dbms_random.value())
where rownum <=3 ;


select * from v where vname like '\BCE%' ESCAPE '\';

“ORDER BY3 ASC”，意思是按第三列排序。

SELECT * FROM v WHERE vname LIKE '_\BCE%' ESCAPE '\'

SELECT * FROM v WHERE vname LIKE '_\\BCE%' ESCAPE '\';

select empno,deptno,sal,ename,job from emp order by 2 ASC,3 DESC;

select last_name as 名称,phone_number as 号码,salary AS 工资，
substr(phone_number,-4) as 尾号
FROM hr.employee
WHERE rownum <= 5
ORDER By 4;



select translate ('ab 你好 bcadefg','abcdefg','1234567')
as new_str from dual;

select translate ('ab 你好 bcadefg','abcdefg','')
as new_str from dual;

NULL


select translate('ab你好bcadefg','labcdefg','1')
as new_Str from dual;



select data,translate(data,'-0123456789','-') as ename


空值在前

select ename,sal,comm from emp order by 3 nulls first ;



select ename,sal,comm from emp order by 3 nulls last;

select empno,ename,sal
from emp
where deptno = 30
order by case when sal >= 1000 and sal <2000 then 1 else 2 end,3;


select '' as c1 from dual;

null


select 'a' as c1 from dual union all select '' as c1 from dual;


------------

操作多个表
3.1	UNION ALL与空字符串
-------------------
通过第1章的案例可以看到，我们多次使用了 UNION ALL。UNION ALL通常用于合 并多个数据集。
看下面的语句：
SELECT empno AS 编码，ename AS 名称，nvl (mgr, deptno) AS 上级编码 FROM emp WHERE empno = 7788 UNION ALL
SELECT deptno AS 编码，dname AS 名称，NULL AS 上级编码
FROM dept
Oracle查询优化改写技巧与案例
WHERE deptno = 10;
编码名称	上级编码
7788 SCOTT	7566
10 ACCOUNTING
2 rows selected
可以看到，当其中一个数据集列不够时，可以用null来填充该列的值，而空字符串在 Oracle中常常相当于null：
SQL> select '	'as cl from dual;
Cl
null
已选择1行。
为什么不说空字符串等价于null呢？看下面的示例:
SELECT empno AS 编码，ename AS 名称，	nvl (mgr, deptno) AS 上级编码
FROM emp
WHERE empno = 7788
UNION ALL
SELECT deptno AS 编码，dname AS 名称,	''AS上级编码
FROM dept
WHERE deptno = 10;
QRA-01790:表达式必须具有与对应表达式相同的数据类型
可以看到，空字符串本身是varChar2类型，这与mill可以是任何类型不同，当然，它 们也就不等价。
SQL> select * a' as cl from dual union all select 11 as cl from dual;
Cl
a
null
已选择2行。
3.2	UNION 与〇R
当在条件里有or时，经常会改写为UNION,例如，我们在表emp中建立下面两个索引。
第3章操作多个表
create	index	idx_	emp—empno	on emp(empno);
create	index	idx_	_emp_ename	on emp(ename);
然后执行下面的查询:
SELECT empno, ename FROM emp WHERE empno = 7788 OR ename =	'SCOTT';
EMPNO ENAME
7788 SCOTT
1 row selected
如果改写为UNION ALL，则结果就是错的:
SELECT empno, ename	FROM	emp	WHERE	empno =	7788
UNION ALL
SELECT empno, ename	FROM	emp	WHERE	ename =	1 SCOTT';
EMPNO ENAME
7788 SCOTT *
7788 SCOTT
2 rows selected
因为原语句中用的条件是or,是两个结果的合集而非并集，所以一般改写时需要改为
UNION来去掉重复的数据。
SELECT empno, ename	FROM	emp	WHERE	empno =	7788
UNION
SELECT empno, ename	FROM	emp	WHERE	ename =	1 SCOTT';
EMPNO ENAME
7788 SCOTT
1 row selected
这样两个语句分别可以用empno及ename上的索引。 我们对比一下PLAN。 更改前（为了消除bitmap convert的影响，先设置参数。）
SQL> alter session set "_b_tree_bitmap_plans'f = false;
Session altered
explain plan for SELECT empno, ename FROM emp WHERE empno = 7788 OR ename = 'SCOTT1;
select * from table(dbms_xplan.display);
Oracle查询优化改写技巧与案例
PLAN_	_TABLE_OUTPUT
Plan	hash value: 3956160 932
1 Id	| Operation | Name I	Rows |	Bytes	I Cost	(%CPU)| Time J
1 0 j* 1	I SELECT STATEMENT 丨 | I TABLE ACCESS FULL| EMP	1 1 1 1	20 ：| ： 1 20 |	3 3	(0)| 00:00:01 1 (0)丨 00:00:01 |
Predicate Information (identified by operation id):
1 一 filter (，'ElyiPN〇"=7788 OR nENAME"=' SCOTT ') Note
-dynamic sampling used for this statement (level=2)
17 rows selected
这时是 FULL TABLE。 更改后的PLAN
EXPLAIN PLAN FOR SELECT empno, ename FROM emp WHERE empno = 77 88 UNION
SELECT empno, ename FROM emp WHERE ename = 1 SCOTT'; select * from table(dbms_xplan.display);
PLAN TABLE OUTPUT
Plan	hash value: 4087002652
1 Id	I Operation	1 Name	I Rows		I Bytes	I Cost	(%C
I 0	| SELECT STATEMENT	..丨”	1	2	1 40	1 6	(
| 1	I SORT UNIQUE	1	1	2	| 40	1 6	(
1 2	I UNION-ALL	1	1		I
I 3	| TABLE ACCESS BY INDEX	ROWID| EMP			1 1	20 I	2
I * 4	| INDEX RANGE SCAN	I IDX EMP	EMPNO		1 1	1	1
I： 5	| TABLE ACCESS BY INDEX	R〇WID| EMP			1 1	20 |	2
I * 6	| INDEX RANGE SCAN	I IDX一EMP_	_ENAME		1 1	1	1
Predicate Information (identified by operation id):
第3章操作多个表
4	- access (”EMPN〇’，=7788)
6 - access ("ENAME"=• SCOTT” Note
-dynamic sampling used for this statement (level=2)
23 rows selected
可以看到，更改后分别用了两列中的索引。 但在改写时，UNION的去重功能有时会被忽略，从而使数据出现错误，如下面的语句。
SELECT empno, deptno FROM emp WHERE mgr = 7698 ORDER BY 1;
EMPNO DEPTNO
7499	30
7521	30
7654	30
7844	30
7900	*	30
5 rows selected
SELECT empno, deptno FROM emp WHERE job = 1 SALESMAN1 ORDER BY 1; EMPNO DEPTNO
7499	30
7521	30
7654	30
7844	30
4	rows selected
两个条件中有4行数据是重复的，使用or连接两个条件将得到5行数据：
SELECT deptno FROM emp WHERE mgr = 7698 OR job = 1 SALESMAN1 ORDER BY 1; DEPTNO
30
30
30
30
30
5 rows selected
Oracle查询优化改写技巧与案例
而用UNION改后
SELECT deptno FROM	emp	WHERE	mgr =	7698
UNION
SELECT deptno FROM	emp	WHERE	job =	'SALESMAN';
DEPTNO
30
1 row selected
只剩下了一行数据，结果显然不对。 以上实验可以看出： ①不仅两个数据集间重复的数据会被去重，而且单个数据集里重复的数据也会被去 重。 ②有重复数据的数据集用UNION后得到的数据与预期会不一致。 用UNION ALL来模拟UNION语句的过程，•语句如下：
SELECT	DISTINCT deptno
FROM	(SELECT deptno FROM emp WHERE mgr	=7698
	UNION ALL
	SELECT deptno FROM emp WHERE job =	:'SALESMAN')
ORDER	BY 1;
其实，就是合并一去重一排序这三步，那么对结果的影响也就可想而知了。 既然如此，像这种数据还可以用UNION改写吗？答案是肯定的。 我们只需在去重前加入一个可以唯一标识各行的列即可。 例如，在这里可以加入“empno”，再利用UNION,效果如下：
SELECT empno,deptno		FROM	emp	WHERE	mgr =	7788
UNION
SELECT empno,	deptno	FROM	emp	WHERE	j ob =	'SALESMAN';
EMPNO	DEPTNO
7499	30
7521	30
7654	30
7844	30
7876	20
5 rows selected
• 28 •
第3章.操作多个表
加入唯一列empno后，既保证了正确的去重，又防止了不该发生的去重。在此基础上, 再嵌套一层就是想要的结果。
SELECT deptno FROM (
SELECT empno,deptno FROM UNION
SELECT empno,deptno FROM )
ORDER BY 1;
DEPTNO
emp WHERE mgr = 7 698
emp WHERE job
'SALESMAN1
30
30
30
30
30
5 rows selected
除了用唯一列、主键列外，还可以使用rowid。
SELECT deptno FROM (
SELECT ROWID,deptno FROM emp WHERE mgr = 7698 UNION
SELECT ROWID,deptno FROM emp WHERE job = 'SALESMAN1 )
ORDER BY 1;
如果数据不是取自表，而是取自VIEW,且没有唯一列，那么应怎么处理呢？
CREATE	OR REPLACE VIEW v AS
SELECT	e.deptno, e.mgr, e.job,	d.dname
FROM	emp e
INNER	JOIN dept d ON d.deptno	=e.deptno;
select	rowid from v
QRA-01445:无法从不带保留关键字的表的连接视图中选择R0WID或采样
• 29 •
Oracle查询优化改写技巧与案例
我们可以增加rownum来当作唯一列。
WITH e AS (SELECT ROWNUM AS sn,deptno,mgr,job FROM v)
SELECT deptno FROM (
SELECT sn,deptno FROM e WHERE mgr = 7 698 UNION
SELECT sn,deptno FROM e WHERE job = 'SALESMAN1 )
ORDER BY 1;
这里用了 with语句，你可以把with语句的作用理解为：临时创建一个在查询期间存 在的VIEW(e)，这个VIEW仅在查询期间存在，查询结束后就消失（之所以强调这一点， 是因为有人问：为什么这个with语句执行完之后，用se丨ect * frome不能查询数据）。 上面这句就相当于：
SQL>	CREATE OR REPLACE VIEW e AS
2 .	(SELECT ROWNUM AS sn,deptno,mgr,job	FROM v);
View	created
SQL>	SELECT deptno
2	FROM
3	(
4	SELECT sn,deptno FROM e WHERE mgr =	7698
5	UNION
6	SELECT sn,deptno FROM e WHERE job =	'SALESMAN
7	)
8	ORDER BY 1;
DEPTNO
	30
	30
	30
30
30
5	rows selected
SQL> drop VIEW e; View dropped
第3章操作多个表
3^3组合相关的行
相对于查询单表中的数据来说，平时更常见的需求是要在多个表中返回数据。比如,
显示部门10的员工编码、姓名及所在部门名称和工作地址。
SQL> SELECT e.empno, e.ename		,d.dname,		d. loc
FROM emp e
INNER JOIN	dept d ON (e.	deptno = d.		.deptno)
WHERE e.deptno = 10;
EMPNO ENAME	DNAME	LOC
7782 CLARK '	ACCOUNTING	NEW	YORK
7839 KING	ACCOUNTING	NEW	YORK
7934 MILLER	ACCOUNTING	NEW	YORK
3 row selected
另有写法如下：
SQL> SELECT e.empno, e.ename, d.dname, d.loc FROM emp e, dept d WHERE e.deptno = d.deptno AND e.deptno = 10;
其中，JOIN的写法是SQL-92的标准，当有多个表关联时，JOIN方式的写法能更清 楚地看清各表之间的关系，因此.建议大家写查询语句时优先使用JOIN的写法。
3^4 IN、EXISTS 和 INNER JOIN
下面先创建一个表emp2。
DROP TABLE emp2 PURGE;
CREATE TABLE emp2 AS
SELECT ename, job, sal, coiran FROM emp WHERE job = * CLERK *;
要求返回与表 emp2(empno,job,sal)中数据相匹配的 emp(empno，ename，job,sal，deptno) 信息。 有丨N、EXISTS、INNER JOIN三种写法。为了加强理解，请大家看一下三种写法及 其PLAN (此处用的是Oracle丨lg)。
Oracle查询优化改写技巧与'案例
IN写法
SQL>EXPLAIN PLAN FOR SELECT empno, ename, job, sal, deptno FROM emp
WHERE (ename, job, sal) IN (SELECT ename, job, sal FROM emp2); Explained
SQL〉 select * from table(dbms_xplan.display());
PLAN TABLE OUTPUT
Plan	hash value: 4039873364
1 Id	1 Operation 丨	Name |	Rows |	Bytes I	1 Cost	(%CPU)丨 Time
i o	| SELECT STATEMENT |	1	4 I	320 |	6	(0) |	00:00:01
I* i	I HASH JOIN SEMI |	1	4 f	320 1	6	(0) 1	00:00:01
1 2	| TABLE ACCESS FULL|	EMP	! 14	I 742 |	3	(0) 1	00:00:0：
1 3	I TABLE ACCESS FULL|	EMP2	1 4	I 108 |	1 3	(0)	I 00:00:0：
Predicate Information (identified by operation id):
1 - access (,,ENAME,, = ^ENAME,, AND "JOB"="J〇B" AND "SAL” = "SAL") Note
一 dynamic sampling used for this statement (level-2)
19	rows selected
EXISTS写法
SQL> EXPLAIN PLAN FOR SELECT empno, ename, job, sal, deptno FROM emp a WHERE EXISTS (SELECT NULL FROM emp2 b WHERE b.ename = a.ename AND b.job = a.job AND b.sal = a.sal);
Explained
SQL> select ★ from table(dbms_xplan.display());
PLAN TABLE OUTPUT
Plan hash value: 4039873364
I Id 丨 Operation	丨	Name	丨	Rows	|	Bytes	|	Cost	(%CPU)	|	Time
第3章操作多个表
I 0 I	SELECT STATEMENT |	1	4 I	320 I	6 (0)1	00:00:01 |
1* 1	I HASH JOIN SEMI |	1	4 I	320 I	6 (0) |	00:00:01 |
1 2 |	TABLE ACCESS FULL|	EMP |	14 |	742 |	3 (0)	1 00:00:01 I
1 3 |	TABLE ACCESS FULL|	EMP2 |	4丨	1 108 |	3 (0)	I 00:00:01 |
Predicate Information (identified by operation id):
1 一 access ("B" • "ENAME" = "A" • "ENAME" AND "B" • " JOB"="A" • JOB" AND "B" • "SAL" = "A" •’rSAL")
Note
-dynamic sampling used for this statement (level=2) 20 rows selected
因为子查询的JOIN列(emp2.ename，emp2.job，emp2.sal)没有重复行，所以这个查询可 以直接改为INNER JOIN。
SQL> EXPLAIN PLAN FOR SELECT a.empnof a.ename, a.job, a.sal/ a.deptno FROM emp a
INNER JOIN emp 2 b ON (b. ename = a. ename AND b .job = a. job AND b. sal =
a.sal);
Explained
SQL> select * from table(dbras_xplan.display());
PLAN TABLE OUTPUT
Plan hash value: 166525280
I Id | Operation	丨	Name	I	Rows	丨	Bytes	丨	Cost	(%CPU)	I	Time
I 0 I SELECT STATEMENT |	|	4	|	320	|	6	(0)| 00:00:01 |
I *	1|	HASH	JOIN	|	,|	4	[	320	|	6	(0)	I	00:00:01	]
J	2 |	TABLE ACCESS FULL| EMP2	|	4	|	108 [	3	(0)| 00:00:01	|
I	3 |	TABLE ACCESS FULL| EMP	|	14	|	742 |	3	(0)| 00:00:01	|
Predicate Information (identified by operation id):
1 一 access ("B"."ENAME" = "A". "ENAME" AND "B" • •• JOB"="A" • •• JOB" AND "B" • "SAL" = "A" • "SAL")
Note
Oracle查询优化改写技巧1或案例
—dynamic sampling used for this statement (level=2)
20	rows selected
或许与大家想象的不一样，以上三个PLAN中JOIN写法利用了 HASH JOIN (哈希连 接），其他两种运用的都是HASH JOIN SEMI(哈希半连接），说明在这个语句中的IN与EXISTS 效率是一样的。所以，在不知哪种写法高效时应査看PLAN,而不是去记固定的结论。
3^5 INNER JOIN、LEFT JOIN、RIGHT JOIN 禾口 FULL JOIN 角军析
有很多人对这几种连接方式，特别是LEFT JOIN与RIGHT JOIN分不清，下面通过
案例来解析一下。 首先建立两个测试用表。
DROP TABLE L PURGE; DROP TABLE R PURGE; /*左表*/
CREATE	TABLE	L	AS
SELECT	rleft_	_1丨	'AS	str,	’ '1	'AS	v FROM dual UNION
SELECT	Tleft_	2'	i ,	'AS	V	FROM	dual UNION ALL
SELECT		_3'	1 , '3'	1 AS	V	FROM	dual UNION ALL
SELECT	* lef t_	_4'	丨，M ,	1 AS	V	FROM	dual;
/*右表*/
CREATE	TABLE	R	AS
SELECT	1 rig,ht_	_3'	AS	str,	'3，	AS	v,	1	AS	status	FROM	dual	UNION	ALL
SELECT	'right_	_4 '	AS	str,	'4'	AS	v, 0		AS	status	FROM	dual	UNION	ALL
SELECT	1 right_	_5'	AS	str,	•5,	AS	v,	0	AS	status	FROM	dual	UNION	ALL
SELECT	fright_	_6'	AS	str,	'6'	AS	v,	0	AS	status	FROM	dual;
1. INNER JOIN 的特点
该方式返回两表相匹配的数据，左表的“1、2”，以及右表的“5、6”都没有显示。 JOIN写法
SELECT 1.str AS left—str, r.str AS right_str FROM 1
INNER JOIN r ON l.v = r.v ORDER BY 1, 2;
第3章操作多个表
| LEFT_STR		R 丨 GHT_STR j
left_3		right」
lefl_4		right_4
加WHERE条件后的写法
SELECT 1.str AS left_str, r.str AS FROM 1, r WHERE l.v = r.v ORDER BY 1, 2; 2. LEFT JOIN 的特点	right_str
该方式的左表为主表，左表返回所有的数据，右表中只返回与左表匹配的数据，“5、 6”都没有显示。 JOIN写法
SELECT 1.str AS left_str, r.str AS right_str FROM 1
LEFT JOIN r ON l.v = r.v ORDER BY 1, 2;
I LEFT_STR	RIGHT_STR j

lefl_2
left_3	right一3
left一4	right一4.
加(+)后的写法
SELECT l.str AS left_str, r.str AS	right一str
FROM 1, r
WHERE l.v = r.v⑴
ORDER BY 1, 2;
3.	RIGHT JOIN 的特点
该方式的右表为主表，左表中只返回与右表匹配的数据“3、4”，而“1、2”都没有 显示，右表返回所有的数据。
Oracle查询优化改写技巧与案例
JOIN写法
SELECT 1.str AS left_str, r.str AS right_str FROM 1
RIGHT JOIN r ON l.v = r.v ORDER BY 1, 2;
LEFT—STR	R!GHT_STR I
left_3	right一3
left一4	right一4
	right_5
	right_6
加(+)后的写法
SELECT 1.str AS left_str, r.str AS	right一str
FROM 1, r
WHERE l.v(+) = r.v
ORDER BY 1, 2;
4.	FULL JOIN 的特点
该方式的左右表均返回所有的数据，但只有相匹配的数据显示在同一行，非匹配的行 只显示一个表的数据。
JOIN写法
SELECT	1. str AS left_	—str, r.str AS right_str
FROM	1
FULL	JOIN r ON r.v	=l.v
ORDER	BY 1, 2;
j LEFT—STR	RIGHT—STR j
left」
lefl_2
left_3	right_3
left_4	right_4
	right一5
	right一6
注意：FULL JO丨N无(+)的写法。
第3章操作多个表
3.6自关联
表emp中有一个字段mgr,其中是主管的编码（对应于emp.empno),如：
(EMPNO： 7698, ENAME： BLAKE) ->(MGR： 7839)-> (EMPNO： 7839，ENAME： KING),说明BLAKE的主管就是KING。
EMPNO 1		MGR _|
	KING J
75^		7839
" 7788		7566
' 7876	ADk^S	7788
" 7902	FORDN.	7566
7369	SMITH—、	〈7902;
7698	m aVf	.^7839
如何根据这个信息返回主管的姓名呢？这里用到的就是自关联。也就是两次查询表 emp,分别取不同的别名，这样就可以当作是两个表，后面的任务就是将这两个表和JOIN 连接起来就可以。
为了便于理解，这里用汉字作为别名，并把相关列一起返回。
SELECT员工.empno AS职工编码，
员工.ename AS职工姓名，
员工.j ob AS工作，
员工.mgr AS员工表_主管编码，
主管.empno AS主管表_主管编码，
主管.ename AS主管姓^
FROM emp 员工
LEFT JOIN emp 主管 ON (员工.mgr =主管.empno)
ORDER BY 1;
可以理解为我们是在两个不同的数据集中取数据。
CREATE OR	REPLACE	VIEW员工AS	SELECT	* FROM	emp;
CREATE OR	REPLACE	VIEW主管AS	SELECT	* FROM	emp;
SELECT员工.empno AS职工编码, 员工.ename AS职工姓名，
Oracle查询优化改写技巧4案例
员工.j ob AS工作,
员工.mgr AS员工表_主管编码，
主管.empno AS主管表_主管编码，
主管.ename AS主管姓^
FROM员工
LEFT JOIN 主管 ON (员工.mgr =主管.empno) ORDER BY 1;
1职工编码	职工姓名	工 作	员工表_主管编码	主管表一主管编码	主管姓名 |
7369	SMITH	CLERK	7902	7902	FORD
7499	ALLEN	SALESMAN	7698	7698	BLAKE
7521	WARD	SALESMAN	7698	7698	BLAKE
7566	JONES	MANAGER	7839	7839	KING
7654	MARTIN	SALESMAN	7698	7698	BLAKE
7698	BLAKE	MANAGER	7839	7839	KING
7782	CLARK	MANAGER	7839	7839	KING
7788	SCOTT	ANALYST	7566	7566	JONES
7839	KING	PRESIDENT
7844	TURNER	SALESMAN	7698	7698	BLAKE
7876	ADAMS	CLERK	7788	7788	SCOTT
7900	JAMES	CLERK	7698	7698	BLAKE
7902	FORD	ANALYST	7566	7566	JONES
7934	MILLER	CLERK	7782	7782	CLARK
3.7 NOTIN、NOT EXISTS 和 LEFT JOIN
有些单位的部门（如40)中一个员工也没有，只是设了一个部门名字，如下列语句:
select count(*) from emp where deptno = 40;
COUNT(*)
0
1 row selected
如何通过关联查询把这些信息査出来？同样有三种写法：NOT IN、NOT EXISTS和
第3章操作多个表
LEFT JOIN。
语句及PLAN如下（版本为11.2.0.4.0)。
环境：
alter table dept add constraints pk_dept primary key (deptno);
NOT IN用法：
EXPLAIN PLAN FOR SELECT *
FROM dept
WHERE deptno NOT IN (SELECT emp. deptno FROM emp WHERE emp. deptno 工S NOT NULL); SELECT ★ FROM TABLE(dbms_xplan.display());
PLAN TABLE OUTPUT
Plan hash value: 1353548327
1 Id	Operation	I Name |	Rows |	Bytes |	Cost (%CPU)|		Ti
1 o	SELECT STATEMENT	1	1 4	172	6	(17) I	00
1 1	MERGE JOIN ANTI	1	4	172	6	(17) |	00
1 2	TABLE ACCESS BY INDEX ROWIDI DEPT		1 4	1 120	1 2	(0) |	00
1 3	INDEX FULL SCAN	| PK—DEPT	1 4	1	I 1	(0) |	00
1 * ^	I SORT UNIQUE	I	14	182	4	(25)丨	00
I* 5	TABLE ACCESS FULL	I EMP	1 14	1 182	1 3	(0)丨	00
Predicate Information (identified by operation id):
4	一 access("DEPTNO"="EMP"■"DEPTNO”）
filter (,,DEPTNOf, = ,,EMP,f. "DEPTNO")
5	- filter("EMP"."DEPTNO" IS NOT NULL)
Note
-dynamic sampling used for this statement (level=2) 23 rows selected
NOT EXISTS 用法：
EXPLAIN PLAN FOR SELECT *
FROM dept
Oracle查询优化改写技巧S•案例
WHERE NOT EXISTS (SELECT NULL FROM emp WHERE emp.deptno = dept•deptno); select * from table(dbms_xplan.display());
PLAN TABLE OUTPUT
Plan	hash value: 1353548327
1 Id	1 Operation	I Name |	Rows | Bytes |	Cost	%CPU)|	Ti
I 0	I SELECT STATEMENT	I	I 4 | 172	1 6	(17) |	00
I 1	1 MERGE JOIN ANTI	I	A | 172	6	(17)丨	00
1 2	1 TABLE ACCESS BY INDEX	ROWID| DEPT	I 4 丨 120	1 2	(0) 1	00
I 3	I INDEX FULL SCAN	I PK DEPT	1 4 I	I 1	(0) I	00
| * 4	I SORT UNIQUE	1	14 | 182	4	(25)丨	00
1 5	1 TABLE ACCESS FULL	I EMP	1 14 丨 182	1 3	(0) |	00
Predicate Information (identified by operation id):
4	- access < "EMP” . "DEPTNOf,="DEPT" . "DEPTNO'*) filter("EMP"."DEPTNO"="DEPT"•"DEPTNO")
Note
-dynamic sampling used for this statement (level=2)
22 rows selected
LEFT JOIN 用法： 根据前面介绍过的左联知识，LEFT JOIN取出的是左表中所有的数据，其中与右表不 匹配的就表示左表NOT IN右表。
I left_str —	RIGHT STR
left_l
left_2
lerc一j	right」
left一4	right_4
所以本节中LEFT JOIN加上条件IS NULL,就是LEFT JOIN的写法:
EXPLAIN PLAN FOR SELECT dept.*
第3章操作多个表
FROM dept
LEFT JOIN emp ON emp.deptno = dept.deptno WHERE emp.deptno IS NULL;
select ★ from table(dbms_xplan.display());
PLAN TABLE OUTPUT
Plan	hash value: 1353548327
1 Id	| Operation 丨 Name 丨 Rows |		Bytes |	Cost	(%CPU)|	Ti
1 0	I SELECT STATEMENT 丨 |	4	I 172	1 6	(17) I	00
| 1	1 MERGE JOIN ANTI \ |	4	| 172	1' 6	(17)丨	00
1 2	I TABLE ACCESS BY INDEX ROWIDI DEPT |	4	1 120	1 2	(0) |	00
I 3	I INDEX FULL SCAN | PK一DEPT	4	1	1	(0) I	00
I* 4	| SORT UNIQUE | |	14	182	4	(25) |	00
1 5	I TABLE ACCESS FULL | EMP I	14	1 182	1 3	(0)丨	00
Predicate Information (identified by operation id):
4	- access<"EMP"."DEPTNO"="DEPT"."DEPTNO”） filter ("EMP" . •• DEPTNO" = •’DEPT" .,fDEPTNO")
Note
-dynamic sampling used for this statement (level=2)
22 rows selected
三个PLAN应用的都是MERGE ■JOIN ANTI,说明这三种方法的效率一样。
如果想改写，那么就要对比改写前后的PLAN,根据PLAN来判断并测试哪种方法的 效率高，而不能凭借某些结论来碰运气。
3.8外连接中的条件不要乱放
对于3.5节中介绍的左联语句，见下面的数据。
SELECT l.str AS left_str, r.str AS right_str, r.status FROM 1
LEFT JOIN r ON l.v = r.v
ORDER BY 1, 2；
Oracle查询优化改写技巧1芬案例
1 LEFT-STR	RIGHT_STR	STATUS I
lefl_l
left_2
left_3	right_3	1
left_4	right_4	0
对于其中的L表，四条数据都返回了。而对于R表，我们需要只显示其中的status = 1, 也就是r.v=4的部分。 结果应为：
LEFT STR RIGHT STR
left-1
left_2
left_3 right_3 left_4
4	row selected
对于这种需求，会有人直接在上面的语句中加入条件status= 1,写出如下语句。 LEFT JOIN 用法：
SELECT 1.str AS left_str, r.str AS right_str, r.status FROM 1
LEFT JOIN r ON l.v = r.v WHERE r.status = 1 ORDER BY 1, 2;
(+)用法：
SELECT l.str AS left一str, r.str AS right—str, r.status FROM 1, r WHERE l.v = r.v(+)
AND r.status = 1 ORDER BY 1, 2;
这样查询的结果为：
LEFT STR RIGHT STR STATUS
left_3 right一3	1
1	row selected
第3章操作多个表
而此时的PLAN为：
SQL> select * from table(dbms_xplan.display);
PLAN_TABLE_OUTPUT
Plan hash value: 688663707
1 Id	Operation 1	Name	1 Rows |	Bytes	Cost	(%CPU)|	Time
1 o	SELECT STATEMENT |		I 1	36	7	(15) |	00:00:01
1 1	SORT ORDER BY |		I 1	36	7	(15)丨	00:00:01
| * 2	HASH JOIN |		| 1	| 36	6	(0) |	00:00:01
I* 3	TABLE ACCESS FULL|	R	| 1	I 25	3	(0) |	00:00:01
1 4	TABLE ACCESS FULL |	L	I 4	| 44	3	(0) I	00:00:01
Predicate Information (identified by operation id):
2	- access ("Ln • "V"=，’R" • "V”>
3	- filter(MRH.nSTATUSM=l)
Note
-dynamic sampling used for this statement (level=2)
已选择21行。 很明显，与我们期望得到的结果不一致，这是很多人在写查询或更改查询时常遇到的 一种错误。问题就在于所加条件的位置及写法，正确的写法分别如下。 LEFT JOIN 用法：
SELECT 1.str AS left一str, r.str AS right—str, r.status
FROM 1
LEFT JOIN r ON (l.v = r.v AND r.status = 1)
ORDER BY 1, 2；
(+)用法：
SELECT l.str AS left_str, r.str AS right一str, r.status
Oracle查询优化改写技巧与案例
FROM 1, r WHERE l.v = r.v(+)
AND r•status ( + > = 1 ORDER BY 1, 2;
以上两种写法中，JOIN的方式明显更容易辨别，这也是本书反复建议使用JOIN的原因。 语句也可以像下面这样写，先过滤，再用JOIN,这样会更加清晰。
SELECT l.str AS left一str, r.str AS right_str, r.status FROM 1
LEFT JOIN (SELECT * FROM r WHERE r.status = l)r ON (l.v = r.v)
ORDER BY 1, 2;
看一下现在的PLAN:
SQL> select * from table(dbms_xplan.display);
PLAN TABLE OUTPUT
Plan	hash value: 2310059642
1 Id	1 Operation 1	Name	I Rows	Bytes|Cost	(%CPU)|	Time
| 0	I SELECT STATEMENT |		| 4 '	144 丨 7	(15)丨	00:00:01
1 1	I SORT ORDER BY |		| 4	144 | 7	(15) I	00:00:01
I * 2	I HASH JOIN OUTER |		1 4	144 | 6	(0) |	00:00:01
| 3	I TABLE ACCESS FULL|	L	I 4	44丨 3	(0)[	00:00:01
| * 4	I TABLE ACCESS FULL	R	| 1	25 | 3	(0)丨	00:00:01
Predicate Information (identified by operation id):
2	- access ("L" • ”v-f R" • "V" ( + ))
4	- filter("R"."STATUS"<+)=l)
Note
-dynamic sampling used for this statement (level=2)
己选择21行。
第3章操作多个表
发现多了一个“OUTER”关键字，这表示前面已经不是LEFT JOIN 了，现在这个 才是。
3.9检测两个表中的数据及对应数据的条数是否相同
我们首先建立视图如下：
CREATE OR REPLACE VIEW v AS SELECT * FROM emp WHERE deptno != 10 UNION ALL
SELECT * FROM emp WHERE ename = 1 SCOTT';
要求用査询找出视图V与表emp中不同的数据。 注意：视图V中员工“WARD”有两行数据，而emp表中只有一条数据。
SQL> SELECT rownum,empno,ename FROM v WHERE ename = * SCOTT*; ROWNUM	EMPNO	ENAME
1	7788 SCOTT
2	7788 SCOTT
2	rows selected
SQL〉SELECT rownum,empno,ename FROM EMP WHERE ename = * SCOTT1; ROWNUM	EMPNO ENAME
1	7788	SCOTT
1 row selected
比较两个数据集的不同时，通常用类似下面的FULL JOIN语句。
SELECT	v.empno,	V,	.ename	t b ■ Grnpn o,	b.ename
FROM	V
FULL	JOIN emp	b	ON (b,	.empno = v.	empno)
WHERE	(v.empno	IS NULL		OR b.empno IS NULL);
但是这种语句在这个案例中查不到SCOTT的区别。 EMPNO ENAME	EMPNO	ENAME
7782 CLARK
Oracle查询优化改写技巧•案例
3	rows selected
7839 KING 7934 MILLER
这时我们就要对数据进行处理，增加一列显示相同数据的条数，再进行比较。
SELECT v.empno, v.ename, v.cnt, emp.empno, emp.ename, emp.cnt
FROM (SELECT empno, ename, COUNT(*) AS cnt FROM v GROUP BY empno, ename) v FULL JOIN (SELECT empno, ename, COUNT(*) AS cnt FROM emp GROUP BY empno, ename) emp
ON (emp.empno = v.empno AND emp.cnt = v.cnt)
WHERE (v.empno IS NULL OR emp.empno IS NULL);
正确结果如下：
EMPNO ENAME	CNT	EMPNO	ENAME	CNT
7788 SCOTT
5	rows selected
7782	CLARK	1
7839	KING	1
7788	SCOTT	1
7934	MILLER	1
3J0 聚集与内连接
首先建立案例用表如下:
CREATE	TABLE	emp	一bonus	(empno	INT ,	received DATE ,		TYPE	工NT)
INSERT	INTO	emp_	bonus	VALUES(	7934,	DATE	f2005-5-17	、1	)；
INSERT	INTO	emp	bonus	VALUES(	7934,	DATE	,2005-2-15	•, 2	)；
INSERT	INTO	emp_	bonus	VALUES(	7839,	DATE	*2005-2-15	、3	)；
INSERT	INTO	emp	bonus	VALUES(	7782,	DATE	,2005-2-15	1	)；
员工的奖金根据TYPE计算，TYPE=1的奖金为员工工资的10%, TYPE=2的奖金为 员工工资的20%, TYPE=3的奖金为员工工资的30%。 现要求返回上述员工（也就是部门10的所有员工）的工资及奖金。 读者或许会马上想到前面讲到的jO丨N语句，先关联，然后对结果做聚集。 那么在做聚集之前，我们先看一下关联后的结果。
第3章操作多个表
SELECT	e.deptno,
e.empno,
e.ename,
e.sal,
	(e.sal * CASE
	WHEN eb.type = 1	THEN
	0.1
	WHEN eb.type = 2	THEN
	0.2
	WHEN eb.type = 3	THEN
	0.3
END) AS bonus
FROM	emp e
INNER	JOIN emp bonus efc	> ON (e.empno	=eb.	.empno)
WHERE	e.deptno = 10
ORDER	BY 1, 2;
DEPTNO	EMPNO ENAME	SAL	BONUS
10	7782 CLARK	2450.00	245
10	7839 KING	5000.00	1500
10	7934 MILLER	1300.00	130
10	7934 MILLER	1300.00	260
4 row	selected
对这样的关联结果进行聚集后的数据如下：
SELECT	e.deptno,
	SUM(e.sal) AS total_sal,
	SUM(e.sal ★ CASE
	WHEN eb.type	=1 THEN
	0.1
	WHEN eb.type	=2 THEN
	0.2
	WHEN eb.type	=3 THEN
	0.3
	END) AS total_bonus
FROM	emp e
INNER	JOIN emp_bonus et	丨 ON (e.empno	=eb.	,empno)
WHERE	e.deptno = 10
GROUP	BY e.deptno;
Oracle查询优化改写技巧与案例
DEPTNO T0TAL_SAL	TOTAL_	_BONUS
10 10050 1 row selected	2135
这里出现的奖金总额没错，		工资总额为10050,而实际工资总额应为8750:
SQL> SELECT SUM(sal) AS TOTAL_SAL		total sal FROM emp WHERE deptno = 10;
8750 1 row selected
关联后返回的结果多了 10050-8750=1300,原因正如前面显示的一样，员工的MILLER 工资重复计算了两次。 对于这种问题，我们应该先对emp_bonus做聚集操作，然后关联emp表。 下面分步演示一下。 未汇总前，有两条7934:
SELECT eb.empno,
(CASE
WHEN eb.type = 1 THEN 0.1
WHEN eb.type = 2 THEN
0.2
WHEN eb.type = 3 THEN 0.3
END) AS rate FROM emp_bonus eb ORDER BY 1, 2;
EMPNO	RATE
7782	0.1
7839	0.3
7934	0.1
7934	0.2
4	row selected
把emp_bonus按empno分类汇总，汇总后会只有一条7934,再与emp关联就没问题了。
SELECT eb.empno,
SUM(CASE
第3章操作多个表
		WHEN eb.type =	1	THEN
		0.1
		WHEN eb.type =	2	THEN
		0.2
		WHEN eb.type =	3	THEN
		0.3
		END) AS rate
FROM	emp_bonus eb
GROUP	BY	empno
ORDER	BY	lr 2;
EMPNO		RATE
7782		0.1
7 8 39		0.3
7934		0.3
这是最终的正确语句，先把奖金按员工（empno)汇总，再与员工表关联。
SELECT e.deptno.
SUM(e.sal).	AS total sal,
SUM(e.sal ★	eb2.rate) AS total—		bonus
FROM emp e
INNER JOIN (SELECT eb.empno,
SUM(CASE
	WHEN eb.type	=	1 THEN
	0.1
	WHEN eb.type	=	2 THEN
	0.2
	WHEN eb.type	=	3 THEN
	0.3
	END) AS rate
FROM	emp_bonus eb
GROUP	BY eb.empno) eb2	ON eb2.empno = e.empno
WHERE e.deptno =	10
GROUP BY e.deptno;
DEPTNO TOTAL一SAL	TOTAL一BONUS
10 8750	2135
1 row selected
这样结果就对了。
• 49 •
Oracle查询优化改写技巧与案例
^11 聚集与外连接
如果我们要分别返回所有部门的工资及奖金怎么办？因上述奖金数据中只含部门10, 那么改为LEFT JOIN就可以。
SELECT e.deptno,
SUM(e.sal) AS total_sal,
SUM(e.sal * eb2.rate) AS total bonus
FROM	emp e
LEFT	JOIN (SELECT eb.empno, SUM(CASE
	WHEN eb.type 0.1	=1 THEN
	WHEN eb.type 0.2	=2 THEN
	WHEN eb.type 0.3 END) AS rate FROM emp_bonus eb	=3 THEN
	GROUP BY eb.empno) eb2	ON eb2.empno = e.empno
GROUP	BY e.deptno
ORDER	BY 1;
DEPTNO	TOTAL一SAL TOTAL一BONUS
10	8750 2135
20	10875
30	9400
3 row	selected
先做聚集操作，然后外连接。
3.12从多个表中返回丢失的数据
首先，我们在表emp中增加一行deptno为空的数据如下：
INSERT INTO emp
(empno, ename, job, mgr, hiredate, sal, comm, deptno)
第3章操作多个表
SELECT 1111,	1YODA'r 'JEDI1, NULL, hiredate, sal, comm, NULL
FROM emp WHERE ename = 'KING*;
这时如果用下面的语句关联查询，就会发现分别少了 emp=llll和deptno=40的数据。
SELECT emp•empno, emp•ename, dept•deptnor dept•dname FROM emp
INNER JOIN dept ON dept.deptno = emp.deptno;
EMPNO	ENAME	DEPTNO	DNAME j
7369	SMITH	20	RESEARCH
7499	ALLEN	30	SALES
7521	WARD	30	SALES
7566	JONES	20	RESEARCH
7654	MARTIN	30	SALES
7698	BLAKE	30	SALES
7782	CLARK	10	ACCOUNTING
7788	SCOTT	20	RESEARCH
7839	KING	10	ACCOUNTING
7844	TURNER	30	SALES
7876	ADAMS	20	RESEARCH
7900	JAMES	30	SALES
7902	FORD	20	RESEARCH
7934	MILLER	10	ACCOUNTING
如果需要返回这两条数据怎么办？下面介绍两种方法。 一种就是前面介绍的FULL JOIN：
SELECT emp.empno, emp.ename, dept.deptno, dept.dname
FROM emp
FULL JOIN dept ON dept.deptno = emp.deptno;
Oracle査询优化改写技巧与案例
EMPNO	ENAME	DEPTNO	DNAME
7369	SMITH	20	RESEARCH
7499	ALLEN	30	SALES
7521	WARD	30	SALES
7566	JONES	20	RESEARCH
7654	MARTIN	30	SALES
7698	BLAKE	30	SALES
7782	CLARK	10	ACCOUNTING
7788	SCOTT	20	RESEARCH
7839	KING	10	ACCOUNTING
7844	TURNER	30	SALES
7876	ADAMS	20	RESEARCH
7900	JAMES	30	SALES
7902	FORD	20	RESEARCH
7934	MILLER	10	ACCOUNTING
1111	YODA
		40	OPERATIONS
另一种就是UNION ALL：
SELECT	emp.	empno	,emp.ename, dept	.deptno, dept.	,dname
FROM	emp
LEFT	JOIN	dept	ON dept.deptno =	emp.deptno
UNION ALL
SELECT	emp.	empno	,emp.ename, dept	• deptno, dept.	.dname
FROM	emp
RIGHT	JOIN	dept	ON dept.deptno =	emp.deptno
WHERE	emp.	empno	IS NULL;
在此不建议使用UNION,因为UNION会去掉重复数据，如果表或视图中包含重复数 据，会被UNION去掉（如前面3.2节所述场景）。
之所以会介绍这种写法，是因为在Oracle 10g中有时会被CBO把语句转成类似的这 种方式，这样査询就可能会变慢。我们需要用HINT(/*+NATIVE_FULL—OUTER—JOIN */) 来屏蔽这种不好的转换。 相关内容详见作者的 BLOG : http://blog.csdn.net/jgmydsai/article/details/13774253。
第3章操作多个表
3.13 多表查询时的空值处理
要求返回所有比“ALLEN”提成低的员工:
SELECT	d.. ©nartiG f	a•comm
FROM	emp a
WHERE	a.comm <	(SELECT b.comm FROM emp b WHERE b.ename = 'ALLEN');
ENAME		COMM
TURNER		0
1 row	selected
这种结果显然不对，因为SCOTT就没有提成，这些数据应该显示出来。 原因就在于，与空值比较后结果还是为空，需要先转换才行：
SELECT	a.ename, a.comm
FROM	emp a
WHERE	coalesce(a.comm, 0) < (SELECT b.comm FROM emp b WHERE b.ename =
1ALLEN *)；
ENAME	COMM
SMITH
JONES
BLAKE
CLARK
SCOTT
KING
TURNER	0
ADAMS
JAMES
FORD
MILLER
11 rows selected
SCOTT终于出来了，我们来看另一个问题，在3.7节中介绍的语句:
SELECT * FROM dept WHERE deptno NOT IN (SELECT emp.deptno FROM emp WHERE emp.deptno IS NOT NULL);
Oracle查询优化改写技巧Q案例
如果不加WHERE emp.deptno IS NOT NULL会出现什么情况呢？我们来做如下实验：
SQL> UPDATE emp SET deptno = NULL WHERE empno = 7788;
1 row updated
SQL> SELECT COUNT(*) FROM dept WHERE deptno NOT IN (SELECT emp.deptno FROM emp);
COUNT(*)
0
1 row selected
如你所见，返回了 0行，这是因为在Oracle中如果子查询(SELECT emp.deptno FROM emp)中包含空值，NOTIN (空值）返回为空。 必须加入条件 “WHERE emp.deptno IS NOT NULL”。
SQL> SELECT * FROM dept WHERE deptno NOT IN (SELECT emp. deptno FROM emp WHERE emp.deptno IS NOT NULL);
DEPTNO DNAME	LOC
40 OPERATIONS BOSTON
1	row selected
%
第4章
插入、更新与删除
4.1	插入新记录
我们先建立测试表，各列都有默认值。
CREATE TABLE TEST(
cl VARCHAR2(10)	DEFAULT	•默认
c2 VARCHAR2(10)	DEFAULT	f默认2丨，
c3 VARCHAR2(10)	DEFAULT	•默认
c4 DATE DEFAULT )；	SYSDATE
新增数据如下：
INSERT INTO TEST (cl, c2, c3) VALUES (DEFAULT, NULL,，手输值•）；
Oracle查询优化改写技巧与案例
SQL〉	SELECT * FROM	TEST;
ci	C2	C3	C4
默认1		手输值	2013-11-22
1 row	selected
大家注意以下几点：
①如果INSERT语句中没有含默认值的列，则会添加默认值，如C4列。
②如果包含有默认值的列，需要用DEFAULT关键字，才会添加默认值，如C1列。
③如果已显示设定了	NULL或其他值，则不会再生成默认值，如C2、C3列。
建立表时，有时明明设定了默认值，可生成的数据还是NULL,原因在于我们在代码 中不知不觉地加入了 NULL。
4.2	阻止对某几列插入
或许有读者已注意到，我们建立的表中C4列默认值为SYSDATE,这种列一般是为了 记录数据生成的时间，不允许手动录入。那么系统控制不到位，或因管理不到位，经常会 有手动录入的情况发生，怎么办？
我们可以建立一个不包括C4列的VIEW,新增数据时通过这个VIEW就可以。
CREATE OR REPLACE VIEW v		_test AS SELECT cl,c2,c3 FROM TEST;
INSERT INTO v_	test(cl,c2,	r C3)	VALUES ( •手输 cl • ,NULL,'不能改 c4 ’）；
SQL〉 SELECT *	FROM TEST;
Cl C2	C3		C4
默认1	手输值		2013-11-22
手输Cl	不能改c4		2013-11-22
2 row selected
注意，通过VIEW新增数据，不能再使用关键字DEFAULT。
INSERT INTO v_test (cl, c2,c3) VALUES (default, NULL,，不能改 c4 ' > ORA-32575:对手正在修改的视图，不支持显式列默认设置
第4章捶入、更新与删除
4^3 复制表的定义及数据
我们可以用以下语句复制表TEST:
CREATE TABLE test2 AS SELECT * FROM TEST;
也可以先复制表的定义，再新增数据：
CREATE TABLE test2 AS SELECT * FROM TEST WHERE 1=2;
注意：复制的表不包含默认值等约束信息，使用这种方式复制表后，需要重建默认 值及索引和约束等信息。
SQL> Name	DESC test2; Type Nullable Default Comments
Cl	VARCHAR2(10)	Y
C2	VARCHAR2(10)	Y
C3	VARCHAR2(10)	Y
C4	DATE Y
复制表定义后就可以新增数据了:
INSERT INTO test2	SELECT *	FROM TEST;
SQL> SELECT * FROM	test2;
Cl C2	C3	C4
默认1	手输值	2013-11-22
手输cl	不能改c4	2013-11-22
2 row selected
4A 用WITH CHECK OPTION限制数据录入
当约束条件比较简单时，可以直接加在表中，如工资必须大于0:
SQL> alter table emp add constraints ch_sal check(sal > 0); Table altered
但有些复杂或特殊的约束条件是不能这样放在表里的，如雇佣日期大于当前日期:
Oracle查询优化改写技巧1V•案例
alter table emp add constraints ch一hiredate check(hiredate >= sysdate) ORA-02436:日期或系统变量在CHECK约束in牛中指定错误
这时我们可以使用加了 WITH CHECK OPTION关键字的VIEW来达到目的。 下面的示例中，我们限制了不符合内联视图条件的数据（SYSDATE+ 1):
SQL> INSERT	INTO
(SELECT	empno, ename, hiredate
FROM	emp
WHERE	hiredate <= SYSDATE WITH CHECK OPTION)
VALUES
(9999,	'test *, SYSDATE + 1);
INSERT INTO
(SELECT empno, ename, hiredate
FROM emp
WHERE hiredate <= SYSDATE WITH CHECK OPTION)
VALUES
(9999, 'test', SYSDATE + 1)
QRA-01402:视图 WITH CHECK OPTION where 子句违规
语句（SELECT empno, ename, hiredate FROM emp WHERE hiredate <= SYSDATE WITH CHECK OPTION)被当作一个视图处理。
因为里面有关键字“WITH CHECK OPTION”，所以INSERT的数据不符合其中的条 件（hiredate <= SYSDATE)时，就不允许利用 INSERT。
当规则较复杂，无法用约束实现时，这种限制方式就比较有用。
4^5	多表插入语句
多表插入语句分为以下四种：
①无条件INSERT。
②有条件INSERT	ALL。
③转置INSERT。
④有条件INSERT	FIRSTo 首先建立两个测试用表：
CREATE TABLE empl AS SELECT empno,ename,job FROM emp WHERE 1=2;
CREATE TABLE emp2 AS SELECT empno,ename,deptno FROM emp WHERE 1=2;
• 58 •
第4章插入、更新与删除
无条件INSERT:
INSERT ALL
INTO empl(empno.		ename, job) VALUES (empno, ename, job)
INTO emp2(empno.		ename, deptno) VALUES (empno, ename, deptno)
SELECT empno, ename, job, deptno FROM emp WHERE deptno IN (10, 20);
SQL> select * from		empl;
EMPNO	ENAME	JOB *
7369	SMITH	CLERK
7566	JONES	MANAGER
7782	CLARK	MANAGER
7788	SCOTT	ANALYST
7839	KING	PRESIDENT
7876	ADAMS	CLERK
7902	FORD	ANALYST
7934	MILLER	CLERK
8 rows selected
SQL> select * from		emp 2 ;
EMPNO	ENAME	DEPTNO
7369	SMITH	20
7566	JONES	20
7782	CLARK	10
7788	SCOTT	20
7839	KING	10
7876	ADAMS	20
7902	FORD	20
7934	MILLER	10
8 rows selected
因为没有加条件，所以会同时向两个表中插入数据，且两个表中插入的条数一样。 有条件 INSERT ALL:
delete empl; delete emp2;
INSERT ALL WHEN job IN ('SALESMAN *, 'MANAGER') THEN INTO empl(empno, ename, job) VALUES (empno, ename, job)
WHEN deptno IN (*20*,*30') THEN
INTO emp2(empno, ename, deptno) VALUES (empno, ename, deptno)
Oracle査询优化改写技巧与案例
SELECT empno,		ename, job, deptno FROM emp;
SQL>	select *	from empl;
EMPNO	ENAME	JOB
7499	ALLEN	SALESMAN
7521	WARD	SALESMAN
7566	JONES	MANAGER
7 654	MARTIN	SALESMAN
7698	BLAKE	MANAGER
7782	CLARK	MANAGER
784 4	TURNER	SALESMAN
7 rows selected
SQL>	select *	from emp2;
EMPNO	ENAME	DEPTNO
7369	SMITH	20
7499	ALLEN	30
7521	WARD	30
7566	JONES	20
7654	MARTIN	30
7 698	BLAKE	30
7788	SCOTT	20
7844	TURNER	30
7876	ADAMS	20
7900	JAMES	30
7902	FORD	20
11 rows selected
当增加条件后，就会按条件插入。如EMPNO=7654等数据在两个表中都有。 INSERT FIRST 就不一样：
delete	empl;
delete	emp 2;
/*有条件INSERT		FIRST*/
INSERT	FIRST
WHEN	job IN	('SALESMAN•,1MANAGER') THEN
INTO	empl(empno, ename,		job) VALUES (empnof ename, job)
WHEN	deptno	IN <，20', ’30	')THEN
INTO	emp2(empnof ename,		deptno) VALUES (empno, ename, deptno)
第4章插入、更新与删除
SELECT empno,		ename, job, deptno FROM emp;
SQL>	select *	from empl;
EMPNO	ENAME	JOB
7499	ALLEN	SALESMAN
7521	WARD	SALESMAN
7566	JONES	MANAGER
7654	MARTIN	SALESMAN
7698	BLAKE	MANAGER
7782	CLARK	MANAGER
7844	TURNER	SALESMAN
7 rows selected
SQL> ’	select ★	from emp2;
EMPNO	ENAME	DEPTNO
7369	SMITH	20
7788	SCOTT	20
7876	ADAMS	20
7900	JAMES	30
7902	FORD	20
5 row	selected
INSERT FIRST语句中，当第一个表符合条件后，第二个表将不再插入对应的行，表 emp2中不再有与表empl相同的数据“EMPNO=7654”，这就是INSERT FIRST与INSERT ALL的不同之处。 转置INSERT与其说是一个分类，不如算作“INSERT ALL”的一个用法。
DROP TABLE		Tl;
DROP TABLE		t2;
CREATE	TABLE t2 (d VARCHAR2(10),des VARCHAR2(50));
CREATE	TABLE tl AS
SELECT	*熊样，精神不佳		' AS dl.
	•骓样,	温驯听话，	AS d2 ,
	•狗样,	神气活现’	AS d3.
	1鸟样，	向往明天'	AS d4f
	•花样,	愿你快乐像花儿一样'AS d5
FROM	dual,	r
/*转置	INSERT */
INSERT	ALL
Oracle查询优化改写技巧与案例
熊样，精神不佳 猫样，温驯听话 狗样，神气活现 鸟样，向往明天 花样，愿你快乐像花儿一样
INTO	t2(d,des)	VALUES (•周一,	,dl)
INTO	t2 (d, des)	VALUES (•周二,	,d2)
INTO	t2(d,des)	VALUES ('周三，	,d3)
INTO	t2(d,des)	VALUES (•周四，	,d4)
INTO	t2(d,des)	VALUES (•周五,	,d5)
SELECT	dl, d2, d3,	d4,d5 FROM tl	r
5	rows selected
可以看到，转置INSERT的实质就是把不同列的数据插入到同一表的不同行中。 转置INSERT的等价语句如下：
4J6用其他表中的值更新
我们对表emp新增字段dname，然后把dept.dname更新至emp中：
ALTER TABLE emp ADD dname VARCHAR2(50) default 1 noname';
为了便于讲解，在此只更新部门（10:ACCOUNTING，20:RESEARCH)的数据。其他未 更新的部门（如30:SALES)名称应该保持为ioname'不变。
初学Oracle的人常把语句直接写为：
UPDATE emp
SET emp.dname =
(SELECT dept.dname
INSERT	INTO	t2(d,des)
SELECT	'周一		FROM	tl	UNION	ALL
SELECT	'周二	',d2	FROM	tl	UNION	ALL
SELECT	'周二	• ,d3	FROM	tl	UNION	ALL
SELECT	，周四	',d4	FROM	tl	UNION	ALL
SELECT	•周五	• ,d5	FROM	tl；
1 二三四五 周周周周周
FROM dept
第4章插入、更新与删除
WHERE dept.deptno = emp.deptno
AND dept.dname IN (1ACCOUNTING 1,	»RESEARCH'))；
SQL> select empno,ename,deptno,dname from emp;
! EMPNO	ENAME	DEPTNO	DNAME j
7369	SMITH	20	RESEARCH
7499	ALLEN	30
7521	WARD	30
7566	JONES	20	RESEARCH
7654	MARTIN	30
7698	BLAKE	30
7782	CLARK	10	ACCOUNTING
7788	SCOTT	20	RESEARCH
7839	KING	10	ACCOUNTING
7844	TURNER	30
7876	ADAMS	20	RESEARCH
7900	JAMES	30
7902	FORD	20	RESEARCH
7934	MILLER	10	ACCOUNTING
SQL> rollback;
Rollback complete
可以看到，这个语句是对全表做更新，而不是需求所说的部门（lOiACCOUNTINCi 20:RESEARCH),而且因为部门（30:SALES)没有匹配到的数据，dname均被更新为NULL值。 可以想象，在生产环境中，大量的数据被清空或改错是多严重的行为！原因在于该语 句中少了必要的过滤条件。
以上UPDATE语句的结果及错误用查询语句描述如下:
SELECT deptno	i
dname AS old		_dname.
(SELECT	dept	.dname
FROM	dept
WHERE	dept •	•deptno =	emp.deptno
AND	dept.	dname IN	(1ACCOUNTING', 1 RESEARCH')	)AS new—dnamef
CASE
Oracle查询优化改写技巧Si•案例
WHEN emp.deptno NOT IN (10, 20) THEN •不该被更新的行•
END AS des FROM emp;
DEPTNO	OLD—DNAME	NEW_DNAME	DES
20	noname	RESEARCH
30	noname		不该被更新的行
30	noname		不该被更新的行
20	noname	RESEARCH
30	noname		不该被更新的行
30	noname		不该被更新的行
10	noname	ACCOUNTING
20	noname	RESEARCH
10	noname	ACCOUNTING
30	noname		不该被更新的行
20	noname	RESEARCH
30	noname		不该被更新的行
20	noname	RESEARCH
10	noname	ACCOUNTING
正确的思路是要加上限定条件:
SELECT deptno,
dname AS old dname,
(SELECT dept.dname
FROM dept
WHERE dept.deptno =	emp.deptno
AND dept.dname IN	(1ACCOUNTING，， •RESEARCH•>) AS new_dname,
CASE
WHEN emp.deptno NOT	IN (10, 20) THEN
*不该被更新的行*
END AS des
FROM emp
WHERE EXISTS (SELECT dept.	dname
FROM dept
WHERE dept.deptno =	emp.deptno
第4章插入、更新与删除
AND dept.dname IN ('ACCOUNTING',	'RESEARCH1))；
DEPTNO	OLD一DNAME	NEW_DNAME	DES
10	noname	ACCOUNTING
10	noname	ACCOUNTING
10	noname	ACCOUNTING
20	noname	RESEARCH
20	noname	RESEARCH
20	noname	RESEARCH
20	noname	RESEARCH
20	noname	RESEARCH
同样，正确的UPDATE语句应如下:
UPDATE	emp
SET	emp.dname =
	(SELECT	dept.dname
	FROM	dept
	WHERE	dept.deptno = emp.deptno
	AND	dept.dname IN「ACCOUNTING、	'RESEARCH*))
WHERE	EXISTS	(SELECT dept.dname
	FROM	dept
	WHERE	dept.deptno = emp.deptno
	AND	dept.dname IN (1 ACCOUNTING1,	• RESEARCH'))；
SQL> select empno,ename,deptno,dname from			emp;
EMPNO	ENAME	DEPTNO	DNAME 1
7369	SMITH	20	RESEARCH
7499	ALLEN	30	noname
7521	WARD	30	noname
7566	JONES	20	RESEARCH
7654	MARTIN	30	noname
7698	BLAKE	30	noname
7782	CLARK	10	ACCOUNTING
7788	SCOTT	20	RESEARCH
Oracle査询优化改写技巧l-i案例
续表
j EMPNO	ENAME	DEPTNO	DNAME
7839	KING	10	ACCOUNTING
7844	TURNER	30	noname
7876	ADAMS	20	RESEARCH
7900	JAMES	30	noname
7902	FORD	20	RESEARCH
7934	MILLER	10	ACCOUNTING
SQL> rollback;
Rollback complete
除10、20两个部门之外，其他dname均应保持原值“noname”。 更新数据除了上述方法外，还可以使用可更新VffiW:
UPDATE (SELECT emp.dname, dept.dname AS new_dname FROM emp
INNER JOIN dept ON dept.deptno = emp.deptno WHERE dept.dname IN (•ACCOUNTING1,	'RESEARCH’))
SET dname = new_dname;
使用这个语句或许会遇到下面这个错误：
ORA-01779:无法修改与非键值保存表对应的列
这时在表dept中增加唯一索引或主键，再执行上述语句即可。
SQL> alter table dept add constraints pk—dept primary key (deptno);
Table altered
第三种方法是用MERGE改写：
MERGE INTO emp
USING (SELECT dname, deptno FROM dept WHERE dept.dname IN「ACCOUNTING、 'RESEARCH*)) dept
ON (dept.deptno = emp.deptno)
WHEN MATCHED THEN
UPDATE SET emp.dname = dept.dname;
在此建议大家在做多表关联更新时使用或更改为这种方式，因为MERGE INTO语句 只访问了一次DEPT。
第4章插入、更新与删除
□0:00:01
00:00:01
00:00:01
00:00:01
00:00:01
4.7合并记录
前面介绍了 MERGE INTO的好处，那么怎么使用MERGE INTO呢？下面用注释及等 价改写的方式来介绍。 首先建立测试用表：
DROP TABLE bonuses;
CREATE TABLE bonuses (employee_id NUMBER, INSERT INTO bonuses (employee一id)
(SELECT e.employee一id
bonus NUMBER DEFAULT 100),
FROM WHERE GROUP SELECT * commit;
hr.employees er oe.orders o e.employee_id = o.sales_rep_id BY e.employee_id);
FROM bonuses ORDER BY employee_id;
NESTED LOOPS SEHI TABLE ACCESS FULL INDEX UNIQUE SCAN FILTER
TABLE ACCESS BY INDEX ROWID INDEX UNIQUE SCAN
而UPDATE语句则访问了两次DEPT。
•Ian	hash value: 65291Q719
Id	| Operation	| Name	| Rows	| Bytes |	Cost (%CPU)| Time |
UPDATE STATEMENT UPDATE
19	(43)| 00:00:01
Oracle查询优化改写技巧与案例
语句及解释如下：
MERGE INTO bonuses d
USING (SELECT employee一id, salary, department」d FROM hr.employees WHERE department_id =80) s ON (d.employee_id = s.employee_id)
/*匹配条件 d.employee一id = s • employee—id ★/
WHEN MATCHED THEN/*当d表中存在与S对&数据时进行更新或删除* /
UPDATE
SET d.bonus = d.bonus + s.salary * 0.01 /★WHERE只能出现一次，如果在这里加了 WHERE，DELETE后面的WHERE就无效*/
DELETE
WHERE (s . salary > 8000) /*删除时，只更新 s . salary>8000 时的数据 V WHEN NOT MATCHED THEN/*当d表中不存在与S对应的数据时进行新增*/
INSERT
(d.employee_id/ d.bonus)
VALUES
(s.employee_id, s.salary * 0.01)
WHERE (s. salary <= 8000) /*新增时，只更新s. salary <= 8000时的数据，注意这里 与前面不同，是d表中不存在对应数据时才新增*/;
这里有以下几个要点：
①语句是MERGE丨NTO	bonuses,所以在这个语句里只能更改bonuses的数据，不能 改USING后面那些表的数据。
②更新、删除、插入这三个操作是同时进行的，不分先后。
③在MERGE	INTO语句里不能更新jOIN列。
④注意上面的注释：当有DELETE语句时，UPDATE后面不能有WHERE过滤条件。 这时UPDATE的范围是：匹配到的数据减去删除的数据。在本例中就是范围(d.employee_id =s.employee_id)减去范围（s.salary > 8000)。
我们可以来做一个实验，注意：要在测试环境里做这个实验。 首先为了记录MERGE INTO进行了哪些操作，下面以SYSDBA身份开启 SUPPLEMENTAL LOG：
ALTER DATABASE ADD SUPPLEMENTAL LOG data;
然后执行前面的MERGE语句，MERGE语句执行并提交后，下面来看产生了哪些动 作：
第4章插入、更新与删除
SELECT undo一sql
FROM flashback一transaction_query WHERE table一owner = USER
AND table_name = upper('bonuses')
AND commit一timestamp >= SYSDATE - 1 ORDER BY 1;
大家可以看一下UNDO_SQL的相关内容，撤销动作与执行动作相反(
执 行	撤 销
insert		delete
delete		insert
update		update
根据上面的查询结果可以看到，MERGE语句己执行:
/*8条	insert*/
delete	from "TEST"."BONUSES"	where	ROWID =	fAAATfEAAGAAAAFfAAJ
delete	from "TEST"."BONUSES"	where	ROWID =	1AAATfEAAGAAAAFfAAK
delete	from "TEST"."BONUSES"	where	ROWID =	,AAATfEAAGAAAAFfAAL
delete	from "TEST"."BONUSES"	where	ROWID =	1AAAT fEAAGAAAAFfAAM
delete	from "TEST"•"BONUSES"	where	ROWID =	rAAATfEAAGAAAAFfAAN
delete	from "TEST"•"BONUSES"	where	ROWID =	’AAATfEAAGAAAAFfAAO
delete	from "TEST"•"BONUSES”	where	ROWID =	1AAATfEAAGAAAAFfAAP
delete	from "TEST"."BONUSES"	where	ROWID =	'AAATfEAAGAAAAFfAAQ
/*3 条 delete*/
insert into "TEST"."BONUSES"("EMPLOYEE—ID", insert into ’’TEST” • "BONUSES" ("EMPLOYEE—ID", insert into "TEST"•"BONUSES”（HEMPLOYEE_ID", /★6 条 update*/
"BONUS") values (•156，，，100•) "BONUS") values (’158•,•100 *) "BONUS") values ('163','100')
update	»fTESTt.	"BONUSES"	set	H BONUS'* =	'1001	where	ROWID=	1AAATfEAAGAAAAFfAAA
update	"TEST'，	MBONUSES"	set	"BONUSn =	f100f	where	ROWID=	•AAATfEAAGAAAAFfAAB
update	’’TEST"	"BONUSES"	set	"BONUS” =	，100,	where	ROWID=	'AAAT fEAAGAAAAFfAAC
update	，fTEST"	"BONUSES"	set	••BONUS"=	•lOO'	where	ROWID =	1AAATfEAAGAAAAFfAAE
update	"TEST"	•, BONUSES"	set	"BONUS"=	,100'	where	ROWID=	'AAATfEAAGAAAAFfAAH
update	’’TEST"	11 BONUSES"	set	••BONUS’’ =	•100，	where	ROWID=	'AAATfEAAGAAAAFfAAI
该MERGE语句就相当于同时执行以下三条DML语句:
DELETE bonuses d WHERE EXISTS (SELECT null FROM hr.employees s
Oracle查询优化改写技巧4案例
WHERE	s.department_id	=80
AND	s.salary > 8000
AND	d.employee id =	s.employee	id);
:bonuses d
d.bonus =
(SELECT	d.bonus + s.salary * .01
FROM	hr.employees s
WHERE	s.department id	==80
AND	d.employee id =	s.employee	id)
EXISTS	(SELECT d.bonus	+ s.salary	* .01
FROM	hr.employees s
WHERE	s.department id	=80
AND	s.salary <= 8000
AND	d. employee」d =	s.employee	id);
INSERT INTO bonuses d (d.employee_id, d.bonus)
SELECT s.employee_id, s.salary * .01 FROM hr.employees s WHERE s . department」d = 80 AND s.salary <=8000 AND NOT EXISTS
(SELECT NULL FROM bonuses d WHERE d•employee—id = s.employee一id);
4^8删除违反参照完整性的记录
首先建立测试环境。注意，如果前面未创建dept的主键，则需要先创建。 alter table dept add constraints pk_dept primary key (deptno);
在emp表中增加一条数据（要另外复制一张emp表，不要直接用SCOTT.EMP):
INSERT INTO emp(empno,ename,job,mgr,hiredate,sal,comm,deptno)
SELECT 9999 AS empno,ename,job,mgr,hiredate^ sal,comm,99 AS deptno FROM emp WHERE ROWNUM <=1;
当我们增加如下外键时，会因数据违反完整性而报错：
alter TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept(deptno);
ORA-02298:无法验证（TEST • FK_EMP_DEPT)-未找到父项关键字
第4章插入、更新与删除
这种提示在处理业务时会经常遇到，是因为子表中的数据（DEPTNO:99)与主表不一 致（主表中没有DEPTNO:99)引起的。
这时就要处理违反完整性的数据，要根据情况选择在主表中加入数据，或删除子表中 的数据。下面选择删除子表中的数据（注意，删除前后要核对数据后再提交，严格地说， 应该要先备份表中的数据，再做删除操作）：
delete from emp where not exists (
select null from dept where dept.deptno = emp.deptno);
1	row deleted
删除子表行或新增主表行后数据就一致了，重新执行上面的外键语句即可：
ALTER TABLE emp ADD CONSTRAINT fk一emp一dept FOREIGN KEY (deptno) REFERENCES dept(deptno);
Table altered
4^9删除名称重复的记录
因是手动录入程序，所以经常会产生重复的数据，这时就需要删除多余的数据，示例 如下：
create	table dupes (id integer, name varchar(10)
INSERT	INTO	dupes	VALUES	(1,	'NAPOLEON*);
INSERT	INTO	dupes	VALUES	(2,	fDYNAMITE1);
INSERT	INTO	dupes	VALUES	(3,	•DYNAMITE” ;
INSERT	INTO	dupes	VALUES	(4,	'SHE	SELLS *);
INSERT	INTO	dupes	VALUES	(5,	'SEA	SHELLS *);
INSERT	INTO	dupes	VALUES	(6,	*SEA	SHELLS•);
INSERT	INTO	dupes	VALUES	(7,	*SEA	SHELLS')；
可以看到，（'DYNAMITE'、’SEA SHELLS')中这两个人的数据重复，现在要求表中 name重复的数据只保留一行，其他的删除。
删除数据有好几种方法，下面只介绍三种方法（处理数据需谨慎，要确认更改结果后 再提交）：
Oracle查询优化改写技巧与案例
方法一：通过name相同、id不同的方式来判断。
DELETE
FROM dupes a
WHERE EXISTS (SELECT NULL FROM dupes b WHERE b.name = a.name AND b.id > a. id);
利用这种方式删除数据时需要建组合索引： create index idx_name_id on dupes(name,id);
方法二：用ROWID来代替其中的id。
DELETE
FROM dupes a
WHERE EXISTS (SELECT /*十 hash_sj */ NULL FROM dupes b WHERE b.name = a.name AND b.rowid > a.rowid);
因为不需要关联id列，我们只需要建立单列索引： create index idx_name on dupes(name);
方法三：通过分析函数根据name分组生成序号，然后删除序号大于1的数据。 我们也可以用分析函数取出重复的数据后删除。下面先看生成的序号：
SQL> SELECT ROWID AS rid,
2	NAME,
3	row_number() over(PARTITION BY NAME ORDER BY id) AS seq
4	FROM dupes
5 ORDER BY 2, 3；
RID NAME		SEQ
AAAVojAAEAAAH/UAAB	DYNAMITE	1
AAAVojAAEAAAH/UAAC	DYNAMITE	2
AAAVojAAEAAAH/UAAA	NAPOLEON	1
AAAVojAAEAAAH/UAAE	SEA SHELLS	1
AAAVojAAEAAAH/UAAF	SEA SHELLS	2
AAAVojAAEAAAH/UAAG	SEA SHELLS	3
AAAVojAAEAAAH/UAAD	SHE SELLS	1
7 rows selected
取出序号后，再删除seq>l的语句就可以:
DELETE
FROM dupes WHERE ROWID IN (SELECT rid
第4章插入、更新与删除
FROM
WHERE
(SELECT ROWID AS rid,
row—number () over (PARTITION BY NAME ORDER BY id) AS seq FROM dupes) seq > 1);
当然，还有其他写法，读者可继续研宂=
5
第5章
使用字符串
5J 遍历字符串
有时会要求把字符串拆分为单个字符，如:
CREATE OR REPLACE VIEW v AS
SELECT •天天向上，AS 汉字，*TTXS' AS 首拼 FROM dual;
为了核对表中保存的“首拼”是否正确，需要把字符串拆分为下面的样式:
	' .翁::■ ■- '
天	T
天	T
第5章使用字符串
续表

向	X
上	S
在拆分之前，我们先看一个CONNECT BY子句:
SQL> SELECT LEVEL FROM dual CONNECT BY LEVEL <= 4; LEVEL
1
2
3
4
4 rows selected
其中，CONNECT BY是树形查询中的一个子句，后面的LEVEL是一个“伪列”，表 示树形中的级别层次，通过LEVEL <=4循环4次，就生成了 4行上面所示的数据。
那么我们就可以通过CONNECT BY子句把V循环显示4行，并给出定位标识LEVEL:
SQL> SELECT v •汉字，v •首拼，LEVEL FROM v CONNECT BY LEVEL <= length (v.汉字> ; 汉字 首拼	LEVEL
天天向上TTXS	1
天天向上TTXS	2
天天向上TTXS	3
天天向上TTXS	4
4 rows selected
根据上面的数据，就可以通过函数substr(v.汉字，level,?)得到需要的结果：
SELECT V •汉字，
V.首拼，
LEVEL,
• substr(v.	,汉字，	LEVEL,	1)	AS汉字拆分，
substr(v _	.首拼，	LEVEL,	1)	AS首拼拆分，
'substr('	"• 1 1	v.汉字	1 1	,",• |丨 LEVEL | |	、1)1 AS fun
FROM v
CONNECT BY LEVEL <=		length (v.汉字）;
Oracle查询优化改写技巧与案例
j 汉 字：	首拼	LEVEL	&字拆分	首拼拆分	FUN I
天天向上	TTXS	1	天	T	substr('天天向上、1,1)
天天向上	TTXS	2	天	T	substr(•天天向上•，2，1)
天天向上	TTXS	3	向	X	substif 天天向上'，3, 1)
天天向上	TTXS	4	上	S	substr('天天向上’，4，1)
为了方便理解，我们同时显示了 LEVEL的值及每一行实际执行的substr语句。
5.2字符串文字中包含引号
常常有人写SQL时不知道在字符串内的单引号怎么写，其实只要把一个单引号换成 两个单引号表示就可以。
SQL> select	1g'1 day mate' qmarks from dual union all
2 select	1 beavers	''teeth' from dual union all
3 select	i i » »	from dual;
QMARKS
g * day mate
beavers' teeth i
3 rows selected
另外，Oracle 10g开始引入了 q-quote特性，允许按照指定的规则，也就是Q或q开头
(如果是national character literals,则是N或n放在Q或q之前），字符串前后使用界定符 使用规则很简单：
①q-quote界定符可以是除了	TAB、空格、回车外的任何单字节或多字节字符。
②界定符可以是[]、{}>	<>、(),而且必须成对出现。 q-quote的写法就比较明确了。
SQL> select q* [g'day mate]' qmarks from dual union all
2	select q1[beavers1 teeth]' from dual union all
3	select q1[1]'	from	dual;
QMARKS
g1day mate beavers * teeth
第5章使用字符串
3	rows selected
5^3 计算字符在字符串中出现的次数
字符串'CLARK,KING,MILLER’被逗号分隔成了三个子串，现要求用SQL计算其中的 子串个数，对于这种问题，我们一般计算其中的逗号个数后加1就可以。 下面来看怎么计算逗号的个数。 为了方便引用，首先建立一个VIEW:
CREATE OR REPLACE VIEW v AS
SELECT 1 CLARK,KING,MILLER' AS str FROM dual;
Oracle llg给出了新函数REGEXP_COUNT,我们可以直接引用。
SELECT regexp_count(str, *	,1) + 1 AS cnt FROM v;
CNT
3
1 row selected
若没有REGEXP_COUNT的版本怎么办？我们用REGEXP_REPLACE迂回求值即可: SELECT length(regexp_replace(strf '[A,]1)) + 1 AS cnt FROM v;
还可以使用前面介绍的translate:
SELECT length(translate(str, ', * 丨丨 str, ',')) + 1 AS cnt FROM v;
如果分隔符有一个以上，那就要把计算出来的长度再除以分隔符长度。
CREATE OR REPLACE VIEW v AS	.
SELECT *10$#CLARK$#MANAGER' AS str FROM dual;
错误的写法：
SELECT length(translate(str, '$#'	||	str,	•$#'))	+	1	AS	cnt	FROM	v;
CNT
5
1 row selected
正确的写法:
Oracle查询优化改写技巧与案例
SELECT length (translate (str, ' $#' | 丨 str, •$#•)) / length (•$#•) + 1 AS cnt FROM v;
CNT
3
1	row selected
用regexp_count就可以不用考虑长度：
SELECT regexp—count(str, f\$# f) + 1 AS cnt FROM v; CNT
3
1	row selected
可能有人注意到，第二个参数里多了一个“\”。这是因为是通配符，需要用“\” 转义。
5.4从字符串中删除不需要的字符
若员工姓名中有元音字母（AEIOU),现在要求把这些元音字母都去掉，很多人都用 如下语句：
SELECT ename,
REPLACE(translate(ename, 'AEIOU',	'aaaaa1),	1	a',	")	strippedl
FROM emp .
WHERE deptno = 10;
ENAME	STRIPPEDl
CLARK	CLRK
KING	KNG
MILLER	MLLR
3	rows selected
这里面先把元音字母替换成|as然后把^去掉。 其实用前面介绍的TRANSLATE的一个用法就可以，根本不需要嵌套:
SELECT ename, translate(ename, 11AEIOU',	'11) strippedl
FROM emp WHERE deptno - 10/
第5章使用字符串
是不是要方便得多？ 当然，也可以用更简便的正则函数REGEXP_REPLACE，直接把□内列举的字符替换 为空：
SELECT ename,
regexp_replace(ename, 1[AEIOU]1> AS strippedl FROM emp;	*
正则表达式 regexp replace 与 replace 对应，regexp_replace(ename，'[AEIOU]’)相当于同 时执行了多个replace()函数：
replace(replace(replace(replace(replace(ename, 'A'), *E'), *1'), '0')r 'U1)
^5将字符和数字数据分离
建立测试用表如下：
drop table dept2 purge; create table dept2 as
select dname 丨丨 deptno as data from dept;
SQL> select data from dept2;
DATA
ACCCXJNTINGIO RESEARCH20 SALES30 OPERATIONS40
4	rows selected
从上面可知，dname中只有字母，而deptno中只有数字，你能从data中还原出dname 与deptno吗？答案是肯定的，可以使用如下正则表达式：
SELECT regexp—replace(data, '[0-9]',	1') dname,
regexp—replace(data, '[^0-9]',	'') deptno
FROM dept2;
DNAME
DEPTNO
ACCOUNTING
RESEARCH
10
20
Oracle查询优化改写技巧与案例
SALES	30
OPERATIONS	4 0
4 rows selected
我们前面讲过regexp_replace(data, '[0-9]',")就是多次的replace，[0-9]是一种表不方 式，代表[0123456789],还可以表示为[[:digit:]]。那么把这些数据替换之后剩下的就是那 些字母了，得到的结果就是ename。
第二个表达式regexp—replace(data，'[A0-9]',")中多了一个符号“A”，这个符号表不否定 的意思，代表[0-9]的外集，也就是除[0123456789]外的所有字符，在本节案例中就是那些 字母。把字母都替换掉之后，剩下就是sal 了。
要注意“A”的位置：在方括号内，所有的字符之前。 如果不是在方括号内（如直接写为'Ahell’），则表示字符串的开始位置。 如果还不习惯使用正则表达式，则可以使用第2章介绍的translate:
SELECT translate(data, 'a0123456789'		,'a')	dname.
translate(data, '012345678 9' |		1 data,	'0123456789') deptno
FROM dept2;
DNAME	DEPTNO
ACCOUNTING	10
RESEARCH	20
SALES	30
OPERATIONS	40
4 rows selected
5.6查询只包含字母或数字型的数据
CREATE	OR REPLACE VIEW v AS
SELECT	'123' as	data FROM dual UNION ALL
SELECT	•abc' FROM dual UNION ALL
SELECT	f123abc'	FROM dual UNION ALL
SELECT	'^0123'	FROM dual UNION ALL
SELECT	，alb2c3'	FROM dual UNION ALL
SELECT	'a^cS#'	,FROM dual UNION ALL
SELECT	'3$' FROM dual UNION ALL
第5章使用字符串
SELECT 'a 2' FROM dual;
上述语句中，有些数据包含了空格、逗号、$等字符。现在要求返回其中只有字母及 数据的行（见粗体部分）。
如果直接按需求字面意思来写，可以用正则表达式。
SQL> SELECT data FROM v WHERE regexp_like(data,	'A[0-9a-zA-Z]+$f);
DATA
123
abc
123abc
abcl23
alb2c3
5 rows selected
首先和前面的对应方式一样，regexp—like对应普通的like。
regexp_like(data, '[ABC]')就相当于（like '%A%' or like '%B%* or like '%C%')；而 regexp_like(data, '[0-9a-zA-Z]+')就相当于(like ’％数字％’ or like ’％小写字母％' or like '%大 写字母％')。
注意：是前后都有“％”的模糊查询。______________________________
我们知道，“A”不在方括号里时表示字符串开始，这里还有一个“$”，该符号在方括 号外面，表示字符串的结束。
我们通过具体查询来对比说明:
CREATE	OR REPLACE VIEW v AS
SELECT	'A*	as data FROM dual UNION ALL
SELECT	fABr	FROM dual UNION ALL
SELECT	'BA1	FROM dual UNION ALL
SELECT	'BAC	1 FROM dual;
用regexp_like对应普通的like来对比就是：
① regexp_like(data, 'A’)对应普通的 like '%A%'=
SQL> select * from v where regexp一like(data, 'A'); DATA
A
AB
Oracle查询优化改写技巧4案例
BA BAC 4 rows selected
②前面加 “A” regexp_like(data，'AA')对应普通的 like’A%’,		没有了前模糊查询。
SQL> select * from v where regexp一 DATA	like{data, 'AA');
A AB 2 rows selected
③后面加 regexp_like(data，对应普通的丨ike'%A、		没有了后模糊査询。
SQL> select * from v where regexp DATA	like(data, 'A$');
A BA 2 rows selected
④前后各加上 “ A$” regexp_like(data, ’	AAS')对应普通的like'A’，变成了精确査询。
SQL> select * from v where regexp— DATA A 1 row selected	like (data, ' "'AS 1)	/
另一个概念是“+”与’+'表示匹配前面的子表达式一次或多次；$表示匹配前 面的子表达式零次或多次。 我们用另一个例子来理清这几个关系。
CREATE OR REPLACE VIEW v AS
SELECT 1167' AS str FROM dual union all
SELECT '12345671 AS str FROM dual;
SQL> select * from v; STR
167
1234567
2 rows selected
第5章使用字符串
regexp_like(str,' 16+')加号前的子表达式是“6”，至少匹配6—次，也就相当于（like '\6%' or like'166%' or..),等价于 like •16%’。
regexp_like(str,' 16+')加号前的子表达式也是“6”，至少匹配6零次，也就相当于（like •1%'or 丨ike 丨 16%’or..),等价于 like'P/o'o
所以这两个条件的结果分别为：
SQL> SELECT * FROM v WHERE regexp_like(strr'16+1);
STR
167
1	row selected
SQL> SELECT * FROM v WHERE regexp一like(str,•16**);
STR
167
1234567
2	rows selected
那么当“A$”组合之后呢？我们再来看一个例子：
DROP TABLE TEST PURGE;
CREATE TABLE TEST AS SELECT *
FROM (WITH xO AS (SELECT LEVEL AS Iv FROM dual CONNECT BY LEVEL <= 3) SELECT REPLACE(sys_connect—by一path(lv, ', T) /	*,')	AS	s
FROM xO
CONNECT BY nocycle PRIOR lv <> lv) where length(s) <= 2; insert into TEST values(null);
SQL> select * from test;
s
1
12
13
2
21
Oracle查询优化改写技巧与案例
23
3
31
32
null
己选择10行。
看了刚刚讲述的“ + 的区别，那么下面这两句结果有没有区别呢？
SELECT *	FROM	TEST	WHERE	regexp_	—like (s,'	,A[12]+$');
SELECT *	FROM	TEST	WHERE	regexp_	like(s,	,/N [12] *$');
可能很多人都认为这两句的结果应该不一样，我们来运行一下：
SQL> SELECT * FROM TEST WHERE regexp一like(s,*A[12]+$');
1
12
2
21
4	rows selected
SQL> SELECT * FROM TEST WHERE regexp一like(s,*A[12]*$');
1
12
2
21
4	rows selected
是否有些意外？我们来看两个表达式对应的like应该是什么。 regexp_like(s，'A[l2]+$’)对应的是
(s LIKE T OR s LIKE，2’ OR s LIKE ’11’ OR s LIKE ’22’ OR s LIKE '12’ OR s LIKE '21') 而 regexp_like(s/A[12]*$’)对应的是
(s LIKE T OR s LIKE ,2' OR s LIKE '11' OR s LIKE ’22’ OR s LIKE '12' OR s LIKE '21'
OR s LIKE •’)
第5章使用字符串
因为可以匹配零次，所以多了一个条件OR s LIKE”，但我们在前面讲过，在这 种条件里，空字符串等价于NULL。而NULL是不能用LIKE来比较的，所以这个条件不
会返回值。
SQL> SELECT count (*) FROM TEST WHERE s LIKE •	1 i . r
COUNT(★)
0
1 row selected
那么最终结果就是这两个语句返回的结果一样。
5.7提取姓名的大写首字母缩写
本例要求返回下面VIEW中的大写字母，中间加显示为
CREATE OR REPLACE VIEW v AS
SELECT 'Michael Hartstein' AS al FROM dual;
我们可以利用regexpjreplace的分组替换功能：
SQL>	SELECT regexp_replace (v.al,	1([[：upper:]])(.*)([[:upper:]])(.*)',
T\l.\3»)	AS sx FROM v;
SX
M.H
1 row	selected
括号（）将子表达式分组为一个替换单元、量词单元或后向引用单元。
在这个查询中，我们用()把字符串分成了四个组，其中第1、3组中是大写字母，然后 通过后向引用（'\丨.\3')就分别取到了两个组的大写字母，并在中间增加了字符“.”。
我们把各组的结果都显示出来，对比一下：
/* 将字符串拆分为 <1)大写（[[:upper:]]>, (2> 小写 <•*>, (3>大写（[[:upper:]]>, (4) 小写（.*)四个部分，取其（1>(3> */
SELECT regexp_replace(v.al, ' ([[:upper:]]) (.*) ([[:upper:]]) (.*) ', '\1.\3') AS sx,
"分拆，显示（1) ★/
，I '	||	regexp_replace	(v.al,	,	(	[	[: upper: ] ] ) (. *) ( [ [: upper: ]])(•”、
,\1*)	|I •I' AS al,
Oracle查询优化改写技巧与案例
/★分拆,显示（2)两端加竖线是为了显示空格位置*/
'I	'	I (	regexp_replace (v.al,	1 ([ [:upper: ] ]) (• ★) ( [ [:upper: ] ] ) (• *)',
'\2')	|| •丨'AS a2,
/*分拆，显示(3) */
'I	1	II	regexp_replace(v.al,	' ([[:upper:]]) (•★) ([[:upper:]]) (• ”	T,
’\3_> 丨丨•丨 » AS a3,
/★分拆，显示(4) ★/
'I	'	I I	regexp_replace (v.al,	*([[:upper ••]])(.*)([[ :upper :]]>(•”	1,
'\4')	| |	'	|	'	AS	a4
FROM v
结果如下:
sx	At		^2	A3	A4
M.H	|M|	jichael |		|H|	|artstein|
正则表达式([[:upper:]])(.*)([[:upper:]])(.*)把字符串分成了四个部分，如下所示:
([[:upper:]])	(■*)	([[-.upper:]])	(.*)
|M|	jichael |	|H|	|artstein|
取其中的第一组与第三组拼接，就是所需结果。
也可以用前面介绍的translate函数。 第一步，先把字符串转换为小写，这样就得到了 translate所需的参数2。
SELECT al, lower(al) AS a2 FROM v; A1	A2
Michael Hartstein michael hartstein
1	row selected
第二步，把空格替换为小写字母（上面得到的a2)置空就是我们需要的数据。
SELECT translate(al, 1 1	|| a2r '.') AS a3
FROM (SELECT al, lower(al) AS a2 FROM v);
A3
M.H
1 row selected
5^8	按字符串中的数值排序
第5章使用字符串
首先建立如下VIEW,要求按其中的数字排序:
CREATE OR REPLACE VIEW v AS SELECT dname M * 1 丨丨 deptno | 丨，，丨丨 loc AS data FROM dept order by dname;
SQL> select * from v; DATA
ACCOUNTING 10 NEW YORK OPERATIONS 4 0 BOSTON RESEARCH 20 DALLAS SALES 30 CHICAGO 4 rows selected
我们可以用正则表达式替换非数字字符，语句如下：
SELECT data, to_number(regexp_replace(data, 1 FROM v ORDER BY 2;	丨[-0-9]•,	''))AS deptno
DATA DEPTNO ACCOUNTING 10 NEW YORK 10 RESEARCH 20 DALLAS 20 SALES 30 CHICAGO 30 OPERATIONS 40 BOSTON 40 4 rows selected
也可以用translate函数，直接替换掉非数字字符：
SELECT data, to_number(translate(data, '0123456789' deptno FROM v ORDER BY 2;	I I data,	'0123456789•)) AS
DATA DEPTNO ACCOUNTING 10 NEW YORK 10
Oracle查询优化改写技巧4案例
RESEARCH 20 DALLAS	20
SALES 30 CHICAGO	30
OPERATIONS 40 BOSTON	40
4	rows selected
5^9根据表中的行创建一个分隔列表
本例要求将emp表中的ename用逗号间隔合并在一起显示。如：CLARK，KING， MILLER。
可能很多人已使用过wmsys.wm_concat函数，但wmsys.wm_concat是一个非公开函 数，具有不确定性（返回值原来是varchar, Oracle 11.2下就成了 clob)。从Oracle 11.2开 始就有了分析函数listagg。为了便于理解，下面将它与普通函数做一个类比：
SELECT deptno,
SUM(sal) AS total_	_sal,
listagg(ename, 1,	1) within GROUP(ORDER BY ename) AS totoal_ename
FROM emp
GROUP BY deptno;
DEPTNO	TOTAL_SAL	TOTOAL_ENAME
10	8750	CLARK，KJNQMILLER
20	10875	AD AMS,FORD,JONES,SCOTT,SMITH
30	9400	ALLEN,BLAKE,JAMES,MARTIN,TURNER, WARD
如上结果所示，同sum—样，listagg在这里起汇总的作用。sum数值结果加在一起, 而listagg是把字符串结果连在一起。
5.10提取第/7个分隔的子串
首先建立如下VIEW:
CREATE OR REPLACE VIEW v AS
SELECT listagg(ename, ，，，） within GROUP(ORDER BY ename) AS NAME FROM emp WHERE deptno IN (10, 20)
GROUP BY deptno;
第5章使用字符串
SQL> select * from v; NAME
CLARK, KING, MILLER
ADAMS,FORD,JONES,SCOTT,SMITH
2	rows selected
上面各行中的字符串用逗号分隔，现要求将其中的第二个子串larry与gina取出来。 没有正则表达式之前需要找到逗号的对应位置，然后对字符串进行截取：
SELECT NAME,
第二个逗号后的位置， 第三个逗号的位置，
长度，substr(NAME,第二个逗号后的位置，长度）AS子串 FROM (SELECT NAME,
instr(src.name,	i i r f	I,	2)	+ 1 AS第二个逗号后的位置，
instr(src.name,	f i •	1/	(2	+ 1) ) AS第三个逗号的位置，
Instr(src.name,	i i r /	1,	(2 •	f 1)) - instr(src.name,','	r 1, 2)
FROM (SELECT ||	NAME	1 I	i i	AS NAME FROM v) src) x;
NAME	第二个逗号后的位置	第三个逗号的位置	长度	子串
,CLARK,KING,MTLLER,	8	12	4	KING
,ADAMS,FORD.JONES,SCOTT,SMITH,	8	12	4	FORD
如果上面的语句不易理解，那么与下面各字符的位置对比一下就清楚了。
»	C	L	A	R	K	,	K	I	N	G	,	M	I	L	L	E	R	»
1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	IB	19
而用正则函数regexp_substr就要简单得多:
SELECT	regexp_substr(v.name,'	[Af] + \ 1, 2) AS 子串 FROM v;
子串
KING
FORD
2 rows	selected
参数2:	在方括号里表示否的意思，+表示匹配1次以上，•[△，]+•表示匹配不包含
逗号的多个字符，也就是本节VIEW中的各个子串。
Oracle查询优化改写技巧4案例
参数3: 1表示从第一个字符开始。
参数4: 2表示第二个能匹配’[']+'的字符串，也就是K丨NG与FORD。
5.11	分解IP地址
本例要求把丨P地址“192.168.1.118”中的各段取出来，用5.10节学到的方法，参数4 分别取1、2、3、4即可：
SELECT regexp_substr (v.ip, *['] + •, 1, 1) a, regexp_substr(v.ip,	1 [八•] + *,	1,	2)	b,
regexp_substr(v.ip,	•[八.]+*,	1,	3)	c,
regexp_substr(v.ip,	* [A . ] + 1,	1,	4)	d
FROM (SELECT '192.168.1.118» AS ip FROM dual) v;
这是分拆字符常用的语句。
5.12将分隔数据转换为多值IN列表
假设前端传入了一个字符串列表（如：CLARK,K丨NG,MILLER),要求根据这个串查 询数据：
SELECT * FROM emp WHERE ename IN (...)；
直接把’CLARK^KINQMILLER•带入肯定是查询不到数据的。
SQL> SELECT * FROM emp WHERE ename IN (•CLARK,KING,MILLER*>;
未选定行
我们需要做转换。这是正则表达式的优势。
为了便于调用，我们先建一个视图：
CREATE OR REPLACE VIEW v AS
SELECT 'CLARK,KING,MILLER1 AS emps FROM dual;
结合前面所讲的知识，正则表达式如下:
第5章使用字符串
SELECT regexp_substr (v.emps,'[〜].1, 1, LEVEL) AS ename,
LEVEL,
* regexp一subs tr (,, • | | v.emps || ***, ■，['] + ,，，1, ' II to_char (LEVEL) ||	')1 AS reg
FROM v
CONNECT BY LEVEL <= (length(translate(v.emps,','丨丨 v.emps, ',*)) + 1);
ENAME	LEVEL	REG
CLARK	1	regexp_substr('CLARK,lCINaMILLER', '[A,]+', 1，1)
KING	2	•[、]+•，1，2)
MILLER	3	regexp一substifCLARK’ICINCiMlLLER,, •[']+•，I, 3)
为了便于理解，我们多显示了伪列level,及每行对应的正则表达式[a，]+,表示对应 一个不包含逗号的字符串，最后一个参数表示分别取第1、2、3三个串。
那么结合这个语句就可以达到本例的需求。
var v_emps varchar2;
exec :v_emps := 1 CLARK,KING,MILLER*;
SELECT * FROM emp WHERE ename IN (
SELECT regexp_substr{:v_emps, *[^/]+'/ 1, LEVEL) AS ename FROM dual
CONNECT BY LEVEL <= (length (translate (: v_emps,','丨 | :v_emps, ', 1) ) + 1) )；
EMPNO ENAME JOB	MGR	HIREDATE	SAL	COMM EPTNO
7782	CLARK	MANAGER	7839 1981-6-9	2450	10
7839	KING	PRESIDENT	1981-11-17	5000	10
7934	MILLER	CLERK	7782 1982-1-23	1300	10
3	row selected
5.13按字母顺序排列字符串
本例将emp.ename中的内容按字母顺序重新排序，如ADAMS—AADMS。对于这种 问题，大家可以回忆前面介绍的两个内容。 ①把ename拆分为单个字母显示。
②把多行数据合并为一行显示。
Oracle查询优化改写技巧与案例
下面先处理一行数据，为了便于理解，后面的内容采用变量的方式。
1.拆分
拆分操作在5.1节己讲过，语句如下：
VAR v_ename VARCHAR2(50);
EXEC :v_ename := 1 ADAMS 1;
SELECT :v_ename AS ename, substr(:v_ename, LEVEL, 1) AS c FROM dual
CONNECT BY LEVEL <= length(:v_ename);
ENAME	C
ADAMS	A
ADAMS	D
ADAMS	A
ADAMS	M
ADAMS	S
5	rows selected v ename
ADAMS
2.用listagg合并
这一步操作的内容见5.9节’在上面语句的基础上增加listagg即可：
VAR v_ename VARCHAR2(50);
EXEC :v_ename := 'ADAMS';
SELECT :v_ename AS ename,
listagg(substr(:v_ename, LEVEL, 1)) within GROUP(ORDER BY (:v_ename, LEVEL, 1)) AS new_name FROM dual
CONNECT BY LEVEL <= length(:v_ename)
GROUP BY :v—ename;
ENAME	NEW	NAME
ADAMS	AADMS
substr
1 row selected
第5章使用字符串
v ename
ADAMS
3.处理全表数据
下面进一步处理全表数据，可以把前面的语句改为标量子查询
SELECT ename, (SELECT listagg (substr (ename, LEVEL, 1) ) within GROUP (ORDER BY substr(ename, LEVEL, 1))
或许有人会注意到，在上面的数据中有很多字母是重复的，如我们举例用的字符串 ADAMS —AADMS,排序后就有两个“A”。对于这种数据，如果要去重怎么办？ 我们在标量子查询里加一个group by即可（注意：把“substr(ename，LEVEL, 1)”当 作一个整体比较容易理解）》
SELECT ename,
(SELECT listagg(MIN(substr(ename, LEVEL, 1))) within GROUP(ORDER BY MIN(substr(ename, LEVEL, 1)))
FROM dual CONNECT BY LEVEL <= length(ename)
FROM dual
CONNECT BY LEVEL <= length(ename)) AS new一name FROM emp;
ENAME	NEW	NAME
SMITH
ALLEN
WARD
JONES
MARTIN
BLAKE
CLARK
SCOTT
KING
TURNER
ADAMS
JAMES
FORD
HIMST
AELLN
ADRW
EJNOS
AIMNRT
ABEKL
ACKLR
COSTT
GIKN
ENRRTU
AADMS
AEJMS
DFOR
MILLER EILLMR 14 rows selected
Oracle查询优化改写技巧与案例
GROUP BY substr(ename, LEVEL, 1)) AS new_name FROM emp;
ENAME	NEW	NAME
SMITH	HIMST
ALLEN	AELN
WARD	ADRW
JONES	EJNOS
MARTIN	AIMNRT
BLAKE	ABEKL
CLARK	ACKLR
SCOTT	COST
KING	GIKN
TURNER	ENRTU
ADAMS	ADMS
JAMES	AEJMS
FORD	DFOR
MILLER	EILMR
14 rows selected
5.14判别可作为数值的字符串
本例测试数据如下：
CREATE OR REPLACE VIEW v AS
SELECT REPLACE(mixed, ，	，，	'') AS mixed
FROM (SELECT substr(ename, 1, 2)	||	CAST(deptno AS CHAR(4))	||
substr(ename, 3, 2) AS mixed FROM emp WHERE deptno = 10 UNION ALL
SELECT CAST(empno AS CHAR(4)) AS mixed FROM emp WHERE deptno = 20 UNION ALL
SELECT ename AS mixed FROM emp WHERE deptno = 30) x;
SQL〉 select * from v;
MIXED
CL10AR
KI10NG
第5章使用字符串
MI10LL
7369
7566
7788
7876
7902
ALLEN
WARD
MARTIN
BLAKE
TURNER
JAMES
14 rows selected
要求返回mixed包含数值的行，并只显示mixed中的数字，见上面粗体字部分。
SELECT to_number(CASE
WHEN REPLACE(translate(mixed, ■0123456789*, 19999999999'), '9') IS NOT NULL THEN
REPLACE(translate(mixed, REPLACE(translate(mixed, ’0123456789*,	'9999999999')r '9'), rpad(.#’， length(mixed),	*#')),	*#')
ELSE mixed END) mixed
FROM v
WHERE instr(translate(mixed, '01234567891,	19999999999'),	19') >0;
这个语句比较复杂，在日常的工作中除了自己写查询外，还常常会维护更改他人写的 语句，所以读懂复杂的语句是很有必要的。 下面就教大家怎么看复杂的语句。 我们以其中的“CL10AR”为例，把这个查询分拆查看。 ①替换数字为9,结果为CL99AR。
translate(mixed, '0123456789'，'9999999999')
SQL> SELECT translate(1CL10AR' , '0123456789' , 1 9999999999*) AS mixedl FROM dual;
MIXED1
CL99AR
1 row selected
Oracle查询优化改写技巧与案例
②去掉mixedl中的数字，结果为CLARo REPLACE(translate(mixed, ’0123456789’，丨9999999999’)，，9，）
SQL> SELECT REPLACE('CL99AR■,	• 9”	丨 AS mixed2 FROM dual;
MIXED2
CLAR
1 row selected
③替换mixed中的字符为#，结果为##10##。 translate(mixed, REPLACE(translate(mixed, ’0123456789’，，9999999999f)，，9，)，rpad(’#，，
length(mixed),f#'))
SQL> select rpad(’#*, length('CL10AR'),	*#’） from dual;
RPAD(，#，，LENGTH('CL10AR,), •#1)
######
1 row selected
用前面得到的“CLAR ”和刚刚得到的“######”进行替换。
SQL> SELECT translate(，CL1OAR，，'CLAR', '###### f)	丨 AS mixed2 FROM dual;
MIXED2
##10##
1 row selected
④替换掉#,得到10。
SQL> SELECT REPLACE('##10##',		I AS mixed2 FROM dual;
MIXED2
10
1 row selected
⑤判断结果是否为空，因为全数字经过这一系列的替换后，结果会为空，所以需要 处理。
SQL> SELECT REPLACE(translate ( ' 7369 ' , '0123456789', '9999999999' ), '9') as mixed2 FROM dual;
MIXED2
第5章使用字符串
null
已选择1行。
以上对“CL10AR”的处理过程用表格解析如下：
	CLIOAR—	-—.
	CL9SAR^	SELECT translate(		CLIOAR'r •01234S67891, r99999999991) AS mixedl FROM dual;
	CLAR^	SELECT REPLACE (1CL99AR • ^ AS mlxed2 FROM dual/
CL10AR.	、		select rpsdCt'r lsngth (,CL10AR*) , 't*) fron dual
##10##	SEEg； trarislatei_CLinAK			J CLARJ.' mmr ) AS miXed2 FROM dual.
10	SELECT REPLACE (, ##i0##\			#5) AS mixed2 FROM dual.
把各步骤的结果分五列显示如下:
SELECT mixed,
AS mixedl FROM dual;
'91) AS mixed2r ###### dual;
"SELECT translate('CL10AR', '0123456789 *, *9999999999') 第一步，替换数字为9，结果为CL99AR ★/
translate(mixed, '0123456789', * 9999999999') AS mixedl, /*SELECT REPLACE('CL99AR’，	*9') AS mixed2 FROM dual;
第二步，去掉mixedl中的数字，结果为CLAR ★/
REPLACE(translate(mixed,•0123456789',	'9999999999'),
/* select rpad (• # *, length (1CL10AR *) ,	•#•) from dual 生成串
SELECT translate<，CL10AR，, *CLAR*,*######*) AS mixed2 FROM
第三步，替换mixed中的字符为#,结果为##10## ★/ translate(mixed, REPLACE(translate(mixed,*0123456789*,
'99999999991),	'9')f rpad('# f, length(mixed),	•#	*)) AS mixed3,
/★SELECT REPLACE(1##10##*,	'#') AS mixed2 FROM dual;
第四步，替换掉#,结果为10 ★/
REPLACE(translate(mixed, REPLACE(translate(mixed, 101234567891, f 9999999999*) , *9”，rpad (, # 1, length (mixed) , ’#')),，#•) AS mixed4.
Oracle查询优化改写技巧Si案例
/*第五步，用case when做空值判断，因为这种替换方式会把数字替换为空*/ to_nuinber (CASE
WHEN REPLACE(translate(mixed, '0123456789', •9999999999'), •9*) IS NOT NULL THEN
REPLACE(translate(mixed, REPLACE(translate(mixed, ,0123456789*,	19999999999»),	*9,),	rpad(,#•, length(mixed),	■#')),	'#	')
ELSE mixed END) mixedS
FROM v
WHERE instr(translate(mixed, '0123456789 *, '99999999991), '9') >0;
MIXED	MIXED1	MIXED2	MIXED3	MIXED4	MIXED5 I
CL 1 OAR	CL99AR	CLAR	##10##	10	10
KJ10NG	KJ99NG	KING	m\om	10	10
M110LL	MI99LL	MILL	mom	10	10
7369	9999				7369
7566	9999				7566
7788	9999				7788
7876	9999				7876
7902	9999				7902
语句分析完后就可以优化，这个查询把过程处理得比较复杂，其实用前面介绍的 translate函数，只需要一步就可以得到结果：
SQL> SELECT mixed,
2	translate(mixed, '01234567891 || mixed, 101234567891) AS mixedl
3	FROM v;
MIXED	MIXED1
CL10AR	10
KI10NG	10
MI10LL	10
7369	7369
7566	7566
7788	7788
7876	7876
7902	7 902
第5章使用字符串
ALLEN
WARD
MARTIN
BLAKE
TURNER
JAMES
14 rows selected
加上过滤条件就是：
SQL> SELECT	1 to_number(mixed) as mixed
2 FROM	(SELECT translate (mixed, '0123456789'	I I mixed, '0123456789') AS
mixed
3	FROM v)
4 WHERE	mixed IS NOT NULL;
MIXED
10
10
10
7369
7566
7788
7876
7902
8 rows selected
也可以用正则表达式直接替换其中的非数字字符。
SQL> SELECT to_number(mixed) AS mixed
2	FROM (SELECT regexp_replace(mixed, '[^0-9] *,	'*) AS mixed FROM v)
3 WHERE mixed IS NOT NULL;
MIXED
10
10
10
7369
7566
7788
7876
7902
8 rows selected
e
第6章
使用数字
6.1常用聚集函数
SELECT deptno,
AVG(sal)	AS平均值，
MIN(sal)	AS最小值，
MAX(sal)	AS最大值，
SUM(sal)	工资合计，
COUNT(*)	总行数，
COUNT (comm)获得提成的人数，
AVG(comm)	错误的人均提成算法，
AVG (coalesce (comm, 0))正确的人均提成/*需要把空值转换为Q*/
FROM emp
GROUP BY deptno;
• 100 •
第6章使用数字
DEPTNO	平均值	最小值	最大值	工资合计	总行数	获得提成的人数	错误的人均提成算法	正确的人均提成
30	1566.666667	950	2850	9400	6	4	550	366.6666667
20	2175	800	3000	10875	5	0		0
10	2916.666667	1300	5000	8750	3	0		0
聚集函数需要注意的一点就是：聚集函数会忽略空值，这对sum等来说没什么影响， 但对avg、count来说就可能会出现预料之外的结果。所以要根据需求决定是否把空值转为
零。
注意，当表中没有数据时，不加group by会返回一行数据，但加了 group by会没有 数据返回。
建立空表：
SQL> create table emp2 as select * from scott.emp where 1=2;
表已创建。
没有 group by：
SQL> select count (★) as cnt, sum (sal) as sum一sal from emp2 where deptno = 10;
CNT SUM_SAL
0	null
己选择1行。
有 group by：
SQL> select count(*) as cnt,sum(sal) as sum一sal from emp2 where deptno = 10 group by deptno;
未选定行
因此，当你在错误的地点错误地增加了 group by, Oracle就会报错。 没有group by时，输出正常：
SQL> DECLARE
2	v 一sal emp2.sal%TYPE;
3	BEGIN
4	SELECT SUM(sal) INTO v_sal FROM emp2 WHERE deptno = 10;
• 101 •
Oracle查询优化改写技巧与案例
5	dbms_output.put_line(1v_sal='	I|	v_sal);
6	END;
7	/ v_sal=
PL/SQL procedure successfully completed 有GROUP BY时，执行报错：
SQL> DECLARE
2	v_sal emp2.sal%TYPE;
3	BEGIN
4	SELECT SUM (sal) INTO v一sal FROM emp2 WHERE deptno = 10 GROUP BY deptno;
5	dbms_output,put_line('v_sal='	||	v_sal);
6	END;
7	/
DECLARE
v_sal emp2.sal%TYPE;
BEGIN
SELECT SUM(sal) INTO v一sal FROM emp2 WHERE deptno =10 GROUP BY deptno; dbms_output.put_line('v_sal=' I I v_sal);
END;
ORA-01403:未找到任何数据 ORA-O6512:在 line 4
0^ 生成累计和
公司为了查看用人成本，需要对员工的工资进行累加，以便査看员工人数与工资支出 之间的对应关系。 首先，按进入公司的先后顺序（人员编码：empno)来累加查看。
SELECT empno AS 编号， ename AS 姓名， sal AS人工成本，
SUM (sal) over (ORDER BY empno) AS 成本累计 FROM emp WHERE deptno = 30 ORDER BY empno;
• 102 •
第6章使用数字
编 号	姓 名	人工成本	成本累计
7499	ALLEN	1600	1600
7521	WARD	1250	2850
7654	MARTIN	1250	4100
7698	BLAKE	2850	6950
7844	TURNER	1500	8450
7900	JAMES	950	9400
通过上面粗体标识的部分可以看到，分析函数“SUM(sal) over(ORDER BY empno)” 的结果（4丨00)是排序“over(ORDER BY empno)”后第一行到当前行的所有工资 (1600+1250+1250)之和。
我们先看一下该语句的PLAN:
SELECT * FROM TABLE (dbms_xplan .display_cursor (NULL, 0, f ALL -NOTE -ALIAS 1 ))；
丨lan hash value: 3237489*Mi
I Id | Operation 0	]	tJaae	|	Rows	|	*Bytes	|	Coat	(%CPtJ)	|	Tiaie	|
I 0 | SELECT STATEMENT	|	|	|	|.	2.	(100)	J	|
I 1 | WINDOW BUFFER	|.	I	5	|	85	|	2	(0)	|	00:00:01	|
|	.2	|	TA3LE	ACCESS	BY	INDEX	ROWIDI	EMP	J	5	|	85	!	*	2	(0)| 00:00:01 |
|*	3	|	INDEX	RANGE	SCAN	|	IDX_DEPTNO_EMPNG	*	I	5 1	j	1	(0)	|	00:00:02	|
predicate Iaformacion (idencified by operation id):
3 - access ("I>EPTHO"=*30)	o
.uon Projection XnforroacioR (identified by operation id):
1	- (#keys=l) "EMPNO- [NDM3ER, 22] , "EMP"	, wDEPTNO" INUMBER, 22).
"ENAME"【VARCHAR2,10】，"SAL”【NDM3ER, 22】，SDM(”SAL"} OVER ( ORDER 3Y *rEMPHO" RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW >【22】
2	- "EMPH.ROWIDIROWIDr10), "EMPNO"[NUMBER,22]r "ENAME”[VARCHAR2,101,
"SAL” [WDMBfR,22】，”DEPTjNO"|?fDMBER, 22 J	a
3	- HEMP".ROWID[ROHIDfiQ], "DEPpiO1*【NUMBER, 22 】，"EMPNO" [NUMBER, 221
大家请看上面Id=l的语句：
SUM(sal) over(ORDER BY empno)
转换成了如下语句：
SUM (ff SAL") OVER (ORDER BY "EMPNO" RANGE BETWEEN UNBOUNDED PRECEDING AND
• 103 •
Oracle查询优化改写技巧4案例
CURRENT ROW )
这个语句前面的SUM("SAL’’)容易理解，就是对sal求和。后面分为以下三部分：
①	ORDER BY "EMPNO” ：按 EMPNO 排序。
②RANGE:表示这是一个范围开窗。
③	BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW： BETWEEN… AND…子句，表示区间从UNBOUNDED PRECEDING (第一行）到CURRENT ROW (当
前行）。 为了形象地说明这一点，我们用listagg模拟出每一行是哪些值相加。
SELECT empno AS 编号r ename AS 姓名， sal AS人工成本，
	SUM(sal) over(ORDER BY		empno) AS成本累计，
	(SELECT	listagg(sal, 1	+?) within GROUP(ORDER
	FROM	emp b
	WHERE	b.deptno = 30
	AND	b. empno <= a.empno)计算公式
FROM	emp a
WHERE	deptno	=30
ORDER	BY empno;
j		姓名」			累计一	计算城 」
	7499	ALLEN		1600	1600	1600 …
	7521	WARD		1250	2850	1600+1250 …
	7654	MARTIN		1250	4100	1600+1250+1250 …
	7698	BLAKE		2850	6950	11600+1250+1250+2850 | …
7844		TURNER	1500		8450	1600+1250+1250+2850+1500
7900		JAMES	950		9400	1600+1250+1250+2850+1500+950 …
F面是分析函数简写、rows开窗、range开窗、标量方式的累加方法对比，及标量方 式的解释。
SELECT empno,
sal,
SUM(sal)	over(ORDER	BY	empno)	AS简写，
SUM(sal)	over(ORDER	BY	empno	rows BETWEEN	unbounded	preceding	AND
CURRENT ROW) AS row 开窗，
SUM(sal)	over(ORDER	BY	empno	RANGE BETWEEN	unbounded	preceding	AND
• 104 •
第6章使用数字
CURRENT ROW) AS range 开窗，
(SELECT SUM (sal) FROM emp b WHERE b. empno <= a.empno) AS 标量，
'(SELECT SUM (sal) FROM emp b WHERE b.empno <= ' I I a.empno | I *) ' AS
标量解释
FROM emp a WHERE deptno = 30 ORDER BY 1;
I EMPNO	SAL	简写	ROW开窗	RANGE开窗	标量	标量解释 |
7499	1600	1600	1600	1600	2400	(SELECT SUM(sal) FROM emp b WHERE b.empno <= 7499)
7521	1250	2850	2850	2850	3650	(SELECT SUM(sal) FROM emp b WHERE b.empno <= 7521)
7654	1250	4100	4100	4100	7875	(SELECT SUM(sal) FROM emp b WHERE b.empno <= 7654)
7698	2850	6950	6950	6950	10725	(SELECT SUM(sal) FROM emp b WHERE b.empno <= 7698)
7844	1500	8450	8450	8450	22675	(SELECT SUM(sal) FROM emp b WHERE b.empno <= 7844)
7900	950	9400	9400	9400	24725	(SELECT SUM(sal) FROM emp b WHERE b.empno <= 7900)
在这个案例中，简写、ROW开窗、RANGE开窗、标量几列写法等价。 在没有分析函数的时候，计算累加经常要用这个示例中标量的方式，因为使用标量需 要两次访问emp表，会比较慢，是做优化时被改写的目标。 最后一列“标量解释”是每行的计算方式说明，取出来单独执行就是每行的值。
需要注意，本节中各示例语句最后的排序子句只是为了方便大家观察，与分析函数的 结果无关，比如，可以按ename排序：	•
SELECT empno AS 编号， ename AS 姓名， sal AS人工成本，
SUM (sal) over (ORDER BY empno) AS 成本累计 FROM emp WHERE deptno =30 ORDER BY ename;
. 编 号	姓 名	人工成本	成本累计
7499	ALLEN	1600	1600
7698	BLAKE	2850	6950
7900	JAMES	950	9400
• 105 •
Oracle查询优化改写技巧S案例
续表
编 号	姓 名	人工成本	成本累计
7654	MARTIN	1250	4100
7844	TURNER	1500	8450
7521	WARD	1250	2850
可以看到，empn0=7654的累加值仍然是4100,只是通过显示的数据不容易看出数据 间的关系而已。
6.3计算累计差
首先生成样例数据： drop table detail purge; create table detail as select 1000 as编号，'预交费用' insert into detail SELECT empno AS 编号，'支出' FROM emp WHERE deptno = 10; commit;
as 项目，30000 as 金额 from dual;
I | rownum AS 项目，sal + 1000 AS 金额
SQL> select * from detail;
编号项目	金额
1000预交费用	30000
7782 支出	1	3450
7839 支出	2	6000
7934 支出	3	2300
4 rows selected
这是模拟的一个消费流水账，预交费用为30000,后面是三次消费的数据，现在要求 得到每笔费用的余额，结果如下：
• 106 •
第6章使用数字
1000	预交费用	30000	30000
7782	支出1	3450	26550
7839	支出2	6000	20550
7934	支出3	2300	18250
对于这种需求，可能有些人找不到头绪，下面分步来看。 ①对数据排序，一般流水账的编号都是按顺序生成的，我们就根据编号来排序并生 成序号。
SELECT rownum AS seq, a.*
FROM (SELECT 编号，项目，金额 FROM detail ORDER BY 编号）a;

1	1000	预交费用	30000
2	7782	支出1	3450
3	7839	支出2	6000
4	7934	支出3	2300
②可以看到，seq=l是收入，后面的是支出。那么可以用CASE WHEN把后面的数 据变为负数。
WITH x AS (SELECT rownum AS seq, a.*
FROM (SELECT 编号，项目，金额 FROM detail ORDER BY 编号）a)
SELECT 编号，
项目，
金额，
(CASE WHEN seq = 1 THEN 金额 ELSE -金额 END) AS 转换后的值 FROM x;
编 号	项目 金额		转换后的值
1000	预交费用	30000		30000
7782	支出1	3450		-3450
7839	支出2	6000		-6000
7934	支出3	2300		-2300
• 107 •
Oracle查询优化改写技巧4案例
③由转换后的值可以看到，直接相加可以得到需要的余额：30000+ (-3450) = 26550。
所以可以用累加来处理下一步。
WITH x AS (SELECT rownum AS seq, a.*
FROM (SELECT 编号，项目，金额 FROM detail ORDER BY 编号）a)
SELECT 编号，
项目，
金额，	.
SUM (CASE WHEN seq = 1 THEN 金额 ELSE -金额 END) over (ORDER BY seq)
AS余额 FROM x;
		.. ; '
1000	预交费用	30000	30000
7782	支出1	3450	26550
7839	支出2	6000	20550
7934	支出3	2300	18250
6.4 更改累计和的值
CREATE	OR	REPLACE VIEW V			(id,amt,trx)
AS
SELECT	1,	100,	rPR'	FROM	dual	UNION	ALL
SELECT	2,	100,	'PR'	FROM	dual	UNION	ALL
SELECT	3,	50,	1 PY'	FROM	dual	UNION	ALL
SELECT	4r	100,	'PR'	FROM	dual	UNION	ALL
SELECT	5f	200,	fPY'	FROM	dual	UNION	ALL
SELECT	6,	50,	'PY'	FROM	dual	/
这是一个存取/款列表。 ①id是唯一•列。
②amt列表示每次事务处理（取款或存款）涉及的金额。
③trx列定义了事务处理的类型，取款是“PY”，存款是“PR”》 现要求计算每次存/取款后的余额：如果TRX是“PR”，则加上amt值代表的金额， 否则要减去amt代表的金额。
• 108 •
第6章使用数字
这仍然是累加问题，也就是需要先把取款值变为负数。
1.把取款值变为负数
SELECT ID,
CASE WHEN trx = 1PY，THEN •取款'ELSE，存款1 END 存取类型， amt金额，
{CASE WHEN trx = * PY* THEN -amt ELSE amt END) AS 变更后的值 FROM v ORDER BY ID;
	存取类型	金 额	变更后的值， j
i	存款	100	100
2	存款	100	100
3	取款	50	-50
4	存款	100	100
5	取款	200	-200
6	取款	50	-50
2.累加处理后的数据
SELECT ID,
CASE WHEN trx = 'PY'	THEN |取款，ELSE •存款1	END存取类型，
amt金额，
SUM(CASE WHEN trx =	1PY' THEN -amt ELSE amt	END) over(ORDER BY id)
AS余额
FROM v
ORDER BY ID；
mmmmm	存取类型	金 额	余 额 {
i	存款	100	100
2	存款	100	200
3	取款	50	150
4	存款	100	250
5	取款	200	50
6	取款	50	0
• 109 •
Oracle查询优化改写技巧与案例
6^返回各部门工资排名前三位的员工
有经验的人一看到标题，马上就会指出：这个需求太模糊了。为什么？先看下面的示
SELECT deptno, empno, sal,
row_number () over (PARTITION BY deptno ORDER BY sal DESC) AS row_number, rank() over(PARTITION BY deptno ORDER BY sal DESC) AS rank, dense一rank () over (PARTITION BY deptno ORDER BY sal DESC) AS dense—rank FROM emp WHERE deptno = (20, 30)
ORDER BY 1, 3 DESC；
DEPTNO		EMPNO SAL ROW„NUMBER RANK DENSE—RANK
20	7788		3000	1	1	1
20	7902		3000	2	1	1
20	7566		2975	3	3	2
20	7876		1100	4	4	3
20	7369		800	5	5	4
30	7698		2850	1	1	1
30	7499		1600	2	2	2
30	7844		】500	3	3	3
30	7521		1250	4	4	4
30	7654		1250	5	4	4
30	7900		950	6	6	5
该示例用了 PARTITION BY子句，通过这个子句可以把主查询返回的数据分组进行分析。 在查询中分别用了三个分析函数ROW_NUMBER、RANK. DENSE—RANK来分组 (PARTITION BY deptno)生成序号。 注意粗体标识的部分，当排序列（工资）有重复数据时，会出现以下情况。 ROW_NUMBER仍然会生成序号1、2、3。
• 110 •
第6章使用数字
RANK相同的工资会生成同样的序号，而且其后的序号与ROW—NUMBER相同 (empno=7566,生成的序号是3)。
DENSE—RANK相同的工资会生成同样的序号，而且其后的序号递增（empno=7566, 生成的序号是2)。
这里如果用ROW_NUMBER取排名第一的员工，显然会漏掉7902这名员工。如果用 DENSE_RANK取排名前两位的员工，很明显会返回三条记录。
所以具体要分析清楚需求，再决定用哪一个函数。
这里选用DENSE一RANK (因需求不定，所以随意选取了一个）取排名前三的员工， 返回数据如下：
SELECT *
FROM (SELECT deptno, empno, sal,
dense_rank() over(PARTITION BY deptno ORDER BY sal DESC) AS
dense_rank
FROM emp WHERE deptno IN (20, 30))
WHERE dense rank <= 3;
DEPTNO	EMPNO	SAL	DENSE—RANK
20	7788	3000	1
20	7902	3000	1
20	7566	2975	2
20	7876	1100	3
30	7698	2850	1
30	7499	1600	2
30	7844	1500	3
6^计算出现次数最多的值
本例要求查看部门中哪个工资等级的员工最多。
Oracle查询优化改写技巧与案例
这个问题要分为以下四步进行。
1.计算不同工资出现的次数
SQL> SELECT sal, COUNT (*) AS 出现次数 FROM emp WHERE deptno = 20 GROUP BY sal; SAL	出现次数
2975.	,00	1
1100.	,00	1
3000.	,00	2
800.	00	1
rows	selected
2.按次数排序生成序号
SELECT sal, dense_rank() over (ORDER BY 出现次数 DESC) AS 次数序 FROM (SELECT sal, COUNT (” AS 出现次数 FROM emp WHERE deptno = 20 GROUP BY sal) x;
SAL	次数排序
3000.00	1
800.00	2
2975.00	2
1100.00	2
4	rows selected
3.根据序号过滤得到需要的结果
SELECT sal
FROM (SELECT sal, dense_rank() over (ORDER BY 出现次数 DESC) AS 次数排序 FROM (SELECT sal, COUNT (★) AS 出现次数 FROM emp WHERE deptno =20 GROUP BY sal) x) y WHERE次数排序=1;
SAL
• 112 •
第6章使用数字
3000.00
1	row selected
4.利用partition by子句分别査询各部门哪个工资等级的员工最多
SELECT deptno, sal FROM (SELECT deptno, sal,
dense_rank() over (PARTITION BY deptno ORDER BY 出现次数 DESC)
AS次数排序
FROM (SELECT sal, deptno, COUNT (” AS 出现次数 FROM emp GROUP BY deptno, sal) x) y WHERE次数排序=1;
DEPTNO	SAL
10	5000.00
10	1300.00
10	2450.00
20	3000.00
30	1250.00
> rows	selected
部门10各工资档次出现次数都为1,所以返回所有的数据。
如果对于这些数据，各部门只需返回一行，我们还可以用6.7节介绍的分析函数 FIRST、LAST。
6.7返回最值所在行数据
如下图所示，要求返回最大工资（5000)所在行的员工名称（KING)。
DEPTNO EMPNO —	高的人
10
7782
7934
10	7839	KING
10
KING
KING
CLARK	7450T T
MILLER	1300	|
解决办法比较多。
• 113 •
Oracle查询优化改写技巧与案例
1.标量
SELECT deptno,
empno.
(SELECT MAX (b. ename) FROM emp b WHERE b.sal = a.max_sal) AS 工资最高
的人，
ename,
sal
FROM (SELECT deptno,
empno,
MAX(sal)	over(PARTITION BY deptno) AS max_sal,
ename.
sal
FROM emp a
WHERE deptno = 10) a
ORDER BY 1, 5 DESC；
可以看到，这种方式需要先取出最大值，然后与这个最大值关联，稍微有点麻烦。
2.分析函数 在Orade里有分析函数可以直接满足这个需求，而且还可以方便地同时取最大及最小 值：
SELECT deptno, empno,
MAX (ename) keep (dense_rank FIRST ORDER BY sal) over (PARTITION BY deptno) AS工资最低的人，
MAX (ename) keep (dense_rank LAST ORDER BY sal) over (PARTITION BY deptno) AS工资最高的人，
ename, sal FROM emp WHERE deptno =10 ORDER BY 1, 6 DESC;
DEPTNO	empno ism		产人	工^高的人」		ENAME 一	SAL_|
10	7839	MILLER		KING		-KING	5000
10	7782	MILLER		KING		CLARK	2450
10	7934	MILLER		laMn		MILLER	1300
另外，first、last语句也可以放在group里与其他聚合函数一样使用，这时要去掉后面
• 114 •
第6章使用数字
20
20
20
20
20
7788
7902
7566
7876
7369
im
3000
3000
3000
3000
SCOTT	3000
FORD	3000
JONES	2975
ADAMS	1100
SMITH	800
的 over(partition by xxx)：
SELECT deptno,
MIN(sal) AS min_sal,
MAX (ename) keep (dense_rank FIRST ORDER BY sal) AS 工资最低的人， MAX(sal) AS max_sal,
MAX (ename) keep (dense_rank LAST ORDER BY sal) AS 工资最高的人 FROM emp WHERE deptno =10 GROUP BY deptno;
DEPTNO	MIN_SAL	工资最低的人	MAX_SAL	工资最高的人
10	1300	MILLER	5000	KING
或许有人注意到，在first、last语句中，我们不管取工资最低还是最高，都用聚合函 数“MAX”。若要搞清楚这个“MAX”有什么用，需要换一个部门来看：
SELECT deptno, empno,
MAX (sal) over (PARTITION BY deptno) AS 最高工资， ename, sal FROM emp WHERE deptno =20 ORDER BY 1, 5 DESC;
DEPTNO」EMPNO | 最高:T资	ENAME I SAL
可以看到，工资最高的有两个人，对于这种数据，first、last语句会出现什么结果呢？
SELECT deptno, empno, ename,
sal,
to_char(wmsys.wm^concat(ename) keep(dense_rank LAST ORDER BY sal) over (PARTITION BY deptno) ) AS 工资最高的人，
MIN (ename) keep (dense_rank LAST ORDER BY sal) over (PARTITION BY deptno)
1 12 13 -4 i5 I
• 115 •
Oracle查询优化改写技巧与案例
AS工资最高的人min,
MAX (ename) keep (dense_rank LAST ORDER BY sal) over (PARTITION BY deptno) AS工资最高的人max FROM emp WHERE deptno =20 ORDER BY 1, 4 DESC；
DEPTNO _	EMPNO	ENAME SAL —		工^高的人	11^高的人MIN I	高的人MAX 1
20	7788	SCOTT	3000	SCOTT, FORD	FORD	SCOTT |
20	7902	FORD	3000	SCOTT, FORD	…I ford|	SCOTT
20	7566	JONES	2975	SCOTT,FORD	FORD	SCOTT
20	7876	ADAMS	1100	SCOTT,FORD	FORD	SCOTT
20	7369	SMITH	800	SC0TT,F0RD	…FORD	SCOTT
可以看到，当最值有重复数据时，keepC..)部分得到的是一个数据集（SCOTT,FORD), 这时前面的聚合函数就会起作用：min()与max()分别得到“FORD”与“SCOTT”。
6.8 first_value
6.7节的例子也可以用first—value和last_value,它们更简单。但需要注意语句的区别 及正确用法。 下面来看一个示例：
SELECT deptno, empno,
first_value(ename) over(PARTITION BY deptno ORDER BY sal DESC) AS 工
资最高的人，
ename, sal FROM emp WHERE deptno ORDER BY 1, 5 DEPTNO	=10 DESC; EMPNO	工资最高的人	ENAME	SAL
10	7839	KING	KING	5000
10	7782	KING	CLARK	2450
10	7934	KING	MILLER	1300
3 rows selected
看上去这个语句没有问题，但若把“DESC”改写为last_Value来看一下:
• 116 •
第6章使用数字
SELECT deptno,
empno•
last—value(ename) over(PARTITION BY		deptno ORDER BY sal) AS 工资最高
的人，
ename,
sal
FROM emp
WHERE deptno =10
ORDER BY 1, 5;
DEPTNO EMPNO	工资最高的人 ENAME	SAL
10 7934	MILLER MILLER	1300
10 7782	CLARK CLARK	2450
10 7839	KING KING	5000
3 rows selected
结果不对，下面先直接对比一下语法:
lasc value(ename
(enaro e^iceep^e nse_rank
•PARTITION BY deptno)
可以看到，‘‘first—value、last—value” 的 “orderby” 在 “over()” 中，这实际上与累加 模式类似。 first_value取分组（当然，因为这个査询中只有一个部门，也可以不分组）排序后， 最前面一行的数据类似于下面的语句：
SELECT deptno,
empno.
MIN(sal)	over (PARTITION BY deptno ORDER BY sal DESC) AS 最高工资，
ename,
sal
FROM emp
WHERE deptno ;	=10
ORDER BY 1, 5	DESC；
Oracle查询优化改写技巧S案例
DEPTNO	EMPNO	最局工资	ENAME	SAL j
10	7839	5000	KING	5000
10	7782	5000	CLARK	2450
10	7934	5000	MILLER	1300
而last_valUe取分组排序后，最后面一行的数据类似于下列语句:
SELECT deptno, empno^
MAX (sal) over (PARTITION BY deptno ORDER BY sal) AS 最高工资, ename, sal FROM emp WHERE deptno =10 ORDER BY 1, 5;
I DEPTNO	EMPNO	最高工资	ENAME	SAL J
10	7934	1300	MILLER	1300
10	7782	2450	CLARK	2450
10	7839	5000	KING	5000
当部门改为20时，要分别取出“FORD”与“SCOTT”，用first_value需要更改为:
SELECT deptno, empno, enamef sal,
first_value(ename) AS工资最高的人min,
first一value(ename) DESC) AS工资最高的人max FROM emp WHERE deptno = 20 ORDER BY 1, 4 DESC;
over(PARTITION BY deptno ORDER BY sal DESC, ename) over(PARTITION BY deptno ORDER BY sal DESC, ename
• 118 •
第6章使用数字
6^9	求总和的百分比
如下面的表格所示，要求计算各部门工资合计，及该合计工资占总工资的比例。
部门	工资合计	工资比例
10	8750	8750/(8750+10875+8400)=30.15
20	10875	10845/(8750+1()875+8400)=37.47
30	9400	9400/(8750+10875+8400)=32.39
其中的工资合计很简单，直接用group by语句就可以得到。要点在于总工资合计,
需要用到分析函数：sum()和over()。
当over()后不加任何内容时，就是对所有的数据进行汇总，步骤如下。
1.分组汇总
SQL> SELECT deptno, SUM (sal)工资合计 FROM emp GROUP BY deptno;
DEPTNO	工资合计
30	9400
20	10875
10	8750
3 rows	selected
2.通过分析函数获取总合计
SELECT deptno,工资合计，SUM (工资合计）over () AS总合计
FROM (SELECT deptno, SUM (sal)工资合计 FROM emp GROUP BY deptno) x;
DEPTNO	工资合计	总合计
30	9400	29025
20	10875	29025
10	8750	29025
• 119 •
Oracle查询优化改写技巧与案例
3.得到总合计后就可以计算比例
SELECT deptno AS 部门，
工资合计， 总合计， round((工资合计/总合计）★ 100, 2) AS工资比例 FROM (SELECT deptno,工资合计，SUM(工资合计〉over() AS总合计
FROM (SELECT deptno, SUM(sal)工资合计 FROM emp GROUP BY deptno) x) y ORDER BY 1;
部门	工资合计	总合计	工资比例
10	8750	29025	30.15
20	10875	29025	37.47
30	9400	29025	32.39
另外，我们也可以用专用的比例函数“ratiojojeport”来直接计算。
SQL> SELECT deptno, round (ratio一to—report (工资合计）over O ★ 100, 2) AS 工 资比例
2	FROM (SELECT deptno, SUM (sal)工资合计 FROM emp GROUP BY deptno)
3 ORDER BY 1;
DEPTNO	工资比例
10	30.	.15
20	37.	.47
30	32.	.39
3 rows	selected
同其他分析函数一样，可以使用PARTITION BY分组计算，如查询各员工占本部门的 工资比例：
SELECT deptno, empno, ename, sal,
round(ratio_to_report(sal) over(PARTITION BY deptno) * 100, 2) AS 工 资比例	—一	•
FROM emp	.
ORDER BY 1, 2;
• 120 •
第6章使用数字
DEPTNO	EMPNO	ENAME	SAL	工资比例
10	7782	CLARK	2450	28
10	7839	KING	5000	57.14
10	7934	MILLER	1300	14.86

20	7369	SMITH	800	7.36
20	7566	JONES	2975	27.36
20	7788	SCOTT	3000	27.59
20	7876	ADAMS	1100	10.11
20	7902	FORD	3000	27.59

30	7499	ALLEN	1600	17.02
30	7521	WARD	1250	13.3
30	7654	MARTIN	1250	13.3
30	7698	BLAKE	2850	30.32
30	7844	TURNER	1500	15.96
30	7900	JAMES	950	10.11
7
m _________第7章
日期运算
7.1加减日、月、年
在Oracle中，date类型可以直接加减天数，而加减月份要用add_months函数:
SELECT hiredate AS 聘用日期，
hiredate — 5 AS 减 5 天，
hiredate + 5 AS 力口 5 天，
add一months(hiredate, -5)	AS减5个月，
add一 months(hiredate, 5)	AS加5个月，
add一 months(hiredate, -5	★ li2) AS 减 5 年，
add—months(hiredate, 5 *	12) AS加5年
FROM emp
WHERE ROWNUM <= 1;
• 122 •
第7章日期运算
聘用曰期	1980-12-17
减5天	1980-12-12
加5天	1980-12-22
减5个月	1980-07-17
加5个月	1981-05-17
减5年	1975-12-17
加5年	1985-12-17
7^2 加减时、分、秒
前面讲过，date可以直接加减天数，那么丨/24就是一小时，分钟与秒的加减类同: SELECT hiredate AS 聘用曰期，
hiredate	-	5/24/60/60		AS减5秒，
hiredate	+	5/24/60/60		AS力口 5秒，
hiredate	-	5/24/60	AS	减5分钟,
hiredate	+	5/24/60	AS	加5分钟，
hiredate	-	5/24 AS	减	5小时，
hiredate	+	5/24 AS	加5小时
FROM emp WHERE ROWNUM <= 1;
聘用日期	1980-12-17
减5秒	1980-12-16 23:59:55
加5秒	1980-12-17 00:00:05
减5分钟	1980-12-16 23:55:00
加5分钟	1980-12-17 00:05:00
减5小时	1980-12-16 19:00:00
加5小时	1980-12-17 05:00:00
• 123 •
Oracle查询优化改写技巧Si•案例
7.3日期间隔之时、分、秒
两个date相减，得到的就是天数，乘以24就是小时，以此类推，可以计算出秒。
SELECT间隔天数，
间隔天数*	24	AS间隔小时，
间隔天数*	24	★ 60 AS间隔分，
间隔天数*	24	★ 60 * 60 AS间隔秒
FROM (SELECT	MAX (hiredate) - MIN (hiredate) AS 间隔天数
FROM emp
WHERE ename IN ('WARD1, 'ALLEN*)) x;
间隔天数	间隔小时	间隔分	间隔秒
2	48	2880	172800
7.4日期间隔之日、月、年
加减月份用函数add_months，而计算月份间隔就要用函数months_between<>
SELECT max—hd - min_hd 间隔天	r
months between(max hd.	min	_hd)	间隔月，
months一between(max一hd,	min_	_hd)	/ 12间隔年
FROM (SELECT MIN(hiredate)	min_	hd,	MAX(hiredate) max_hd FROM emp) x;
间隔天		间隔月		间隔年
756	24.83870968			2.069892473
7.5确定两个日期之间的工作天数
本例要求返回员工BLAKE与JONES聘用曰期之间的工作天数.
SELECT	SUM(CASE
	WHEN to_	_char(min_hd + t500.id - 1,		• DY • , ' NLS_DATE_LANGUAGE =
American *)	IN ('SAT• • 0	•SUN*	)THEN
• 124 •
第7章日期运算
ELSE
X
END) AS工作天数
FROM (SELECT MIN(hiredate) AS min_hd, MAX(hiredate) AS max_hd FROM emp
WHERE ename IN (* BLAKE 1,	'JONES')) x,
t500
WHERE t500.id <= max_hd - min_hd + 1;
工作天数
22
1	row selected 其中，t500建表语句如下：
CREATE TABLE T500 AS SELECT LEVEL AS ID FROM dual CONNECT BY LEVEL <= 500;
为了便于理解，下面把这个语句的编写过程分拆一下。 ①原始数据。
SQL> SELECT ename, hiredate FROM emp WHERE ename IN ('BLAKE，，'JONES1);
ENAME	HIREDATE
JONES	1981-04-02
BLAKE	1981-05-01
2 rows	selected
②通过max()与group by转为一行。
SQL> SELECT MIN(hiredate) AS		min_hd, MAX(hiredate) AS max_hd
2 FROM	emp
3 WHERE	ename IN (* BLAKE'	,'JONES');
MIN_HD	MAX—HD
1981-04-02	1981-05-01
1 row selected
③枚举两个日期之间的天数要加1,比如：1到2是两天，有两条数据：（2-1) +1。
	SQL>	SELECT	(max_hd - min_hd) + 1 AS 天数
	2	FROM	(SELECT MIN(hiredate) AS min_hd, MAX(hiredate) AS max一hd
	3		FROM emp
	4		WHERE ename IN (* BLAKE *, 1 JONES 1)) x;
		天数
•		30
	1 row	selected
• 125 •
Oracle查询优化改写技巧与案例
④通过与T100做笛卡儿积枚举30天的所有日期。
SELECT min_hd + (t500 .id - 1) AS 日期
FROM (SELECT MIN(hiredate) AS min_hd,	MAX(hiredate) AS max—hd
FROM emp
WHERE ename IN (1 BLAKEr, fJONES	'))x,
t500
WHERE t500.id <= ((max_hd - min_hd) +	1)；
曰期
1981-04-02
1981-04-03
1981-04-29
1981-04-30
1981-05-01
30 rows selected
⑤根据这些日期得到对应的工作日信息。
SELECT 日期,	to—char (日期，’ DY' , ' NLS_DATE_LANGUAGE = American 1)		AS dy
FROM (SELECT min_hd + (tSOO.id - 1) AS 曰期
FROM (SELECT MIN(hiredate) AS min—hd.		MAX(hiredate) AS	max hd
	FROM emp
	WHERE ename IN ('BLAKE', 'JONES	1) ) x,
	t500
WHERE t500.id <= ((max hd - min hd) +		1))；
日期	DY
1981-04-02	THU
1981-04-03	FRI
1981-04-04	SAT
1981-04-29	WED
1981-04-30	THU
1981-05-01	FRI
30 rows selected
⑥进行过滤操作。 把得到的结果汇总就是工作天数。
• 126 •
第7章日期运算
SELECT COUNT(★)
FROM (SELECT	日期，
to_char (日期，，DY*, * NLS_DATE_LANGUAGE =		American1) AS dy
FROM	(SELECT min_hd + (t500.id - 1) AS 日期 FROM (SELECT MIN(hiredate) AS min_hd, MAX(hiredate) AS max_hd FROM emp
	WHERE ename IN (fBLAKE、1 JONES t500	*)) x,
	WHERE t500.id <= ((max_hd - min_hd) +	1)))
WHERE dy NOT COUNT(*)	IN ('SAT1f 1 SUN *);
22
1 row selected
7.6计算一年中周内各日期的次数
比如，计算一年内有多少天是星期一，多少天是星期二等，这个问题需要以下几步。 ①取得当前年度信息。
②计算一年有多少天。
③生成日期列表。
④转换为对应的星期标识。
⑤汇总。 7.5节己分拆过类似的过程，本节不再重复分拆。
WITH xO AS
(SELECT to_date(* 2013-01 - 01*, * yyyy-mm-dd *) AS 年初 FROM dual),
xl AS
(SELECT 年初，add_months (年初，12) AS 下年初 FROM xO),
x2 AS
(SELECT年初，下年初，下年初	-年初AS天数FROM xl),
x3 AS /★生成列表★/
(SELECT 年初 + (LEVEL - 1)	AS 日期 FROM x2 CONNECT BY LEVEL <=天数），
x4 AS /★对数据进行转换*/
(SELECT 日期，to_char (日期，	'DY* ) AS 星期 FROM x3)
• 127 •
Oracle查询优化改写技巧S案例
/*汇总求天数★/
SELECT 星期，COUNT (*) AS 天数 FROM x4 GROUP BY 星期; 星期	天数
星期二	53
星期日	52
星期三	52
星期四	52
星期六	52
星期五	52
星期一	52
7 rows selected
如果不想用枚举法，也可以直接取出年内各工作日的第一天和最后一天，然后除以7。
WITH xO	AS
(SELECT	to_date(12013-01-01', 1yyyy-		-mm-dd1) AS 年初 FROM	dual),
xl AS
(SELECT	年初,	add_months (年初，12) AS 年底 FROM xO),
x2 AS
(SELECT	next	_day (年初-1, LEVEL) AS	dl, next_day (年底-8	,LEVEL) AS d2
FROM	xl
CONNECT BY		LEVEL <= 7)
SELECT to_char (dlf 'dy') AS 星期，dl.			d2 FROM x2;
| 星期 D1		D2
星期日	2013-01-06	2013-12-29
星期一	2013-01-07	2013-12-30
星期二	2013-01-01	2013-12-31
星期三	2013-01-02	2013-12-25
星期四	2013-01-03	2013-12-26
星期五	2013-01-04	2013-12-27
星期六	2013-01-05	2013-12-28
然后看中间有多少个七天，就知道有多少个工作日。
• 128 •
第7章日期运算
WITH xO AS
(SELECT to一date ('2013-01-01 •,，yyyy-mm-dcT ) AS 年初 FROM dual), xl AS
(SELECT 年初，add_months (年初，12> AS 年底 FROM x0> , x2 AS
(SELECT next一day (年初-1, LEVEL) AS dl, next_day (年底-8, LEVEL) AS d2 FROM xl CONNECT BY LEVEL <= 7)
SELECT to一char (dl, 'dy') AS 星期，((d2 - dl) / 1 + 1) AS 天数 FROM x2 ORDER BY 1;
星期	天数
星期二	53
星期六	52
星期日	52
星期三	52
星期四	52
星期五	52
星期一	52
7 rows selected
确定当前记录和下一条记录之间相差的天数
首先需要把下一条记录的雇佣日期作为当前行，这需要用到lead()oVer()分析函数。
SELECT deptno, ename, hiredate,
lead(hiredate) over(ORDER BY hiredate) next_hd FROM emp WHERE deptno = 10;
DEPTOp	ENAME	HIREDATE	NEXT 一HD
10	CLARK	1981-06-09	1981-11-17
10	KING	1981-11-1?	1982-01-23
10	MILLER	1982-01-23
• 129 •
Oracle查询优化改写技巧4案例
当数据提取到同一行后，再计算就比较简单：
SELECT ename, hiredate, next_hd, next_hd - hiredate diff FROM (SELECT deptno, ename, hiredate,
lead(hiredate) over(ORDER BY hiredate) next_hd FROM emp WHERE deptno = 10);
ENAME	HIREDATE	NEXT	HD	DIFF
CLARK	1981-06-09	1981-11-17	161
KING	1981-11-17	1982-01-23	67
MILLER	1982-01-23
3 rows selected.
和lead对应的就是lag函数，如果读者能记住两个函数的区别当然比较好，如果记不 住，可直接实验。
SELECT deptno, ename, hiredate,
lead(hiredate) over(ORDER BY hiredate) lead_hd, hiredate,
lag(hiredate) over(ORDER BY hiredate) lag_hd FROM emp WHERE deptno = 10;
DEPTNO	ENAME	HIREDATE	LEAD_	HD	HIREDATE	LAG一HD
. 10	CLARK	1981-06-09	1981-	-11-17	1981-06-09
10	KING	1981-1*1-17	1982-	-01-23	1981-11-17	1981-06-09
10	MILLER	1982-01-23 •			1982-01-23 %	1981-11-17
• 130 •
8.1	SYSDATE能得到的信息
经常看到有人因为不熟悉日期操作，获取相应信息的时候，要写很复杂的语句。下面 举一个简单的例子。
SQL>	SELECT hiredate AS 雇佣日期，
2	to_date(to_char(hiredate, 1yyyy-mmf) | I	'-11, 1yyyy-mm-dd1) AS
月初
3	FROM emp
4	WHERE rownum <= 1;
雇佣日期 月初
1980-12-17 1980-12-01
• 131 •
Oracle查询优化改写技巧fci案例
1	row selected
其实要获取这个数据，只需要一个简单的函数就可以做到，而根本不需要多次转换:
SQL> SELECT hiredate AS 雇佣日期，trunc (hiredate, 'iran*) AS 月初
2	FROM emp
3 WHERE rownum <= 1;
雇佣日期	月初
1980-12-17	1980-12-01
1	row selected
下面列举几个常用的取值方式，希望对大家有用。
SELECT hiredate,
to_	number (to_	char(hiredate.	*hh24')	)时，
to	number(to一	char(hiredate,	•mi*))	分，
to_	number(to_	char(hiredate.	'ss'))	秒，
to_	number(to_	char(hiredate,	^d1))	曰，
to_	_number (to_	_char(hiredate,	'mm'))	月，
to_	number(to_	char(hiredate,	»yyyy')	)年，
to	number(to	char(hiredate,	^dd*))	年内!
trunc (hiredate, ' dd') 一天之始， trunc (hiredate, * day1)周初， trunc (hiredate, ’mm*)月初， last_day (hiredate)月未，
add一months (trunc (hiredate, 1 mm *) , 1)下月初, trunc (hiredate, 1 yy1)年初， to_char (hiredate, 1 day')周几， to char (hiredate, 'month')月份
FROM (SELECT hiredate + 30/24/60/60 + 20/24/60 + 5/24 AS hiredate FROM emp WHERE ROWNUM <=1);
HIREDATE	1980-12-17 05:20:30
时	5
分	20
秒	30
曰	17
月	12
年	1980
• 132 •
第8章 B期操作
续表
HIREDATE	1980-12-17 05:20:30
年内第几天	352
一天之始	1980-12-17
周初	1980-12-14
月初	1980-12-01
月末	1980-12-31 05:20:30
下月初	1981-01-01
年初	1980-01-01
周几	星期三
月份	12月
需要注意的是上面last_day的用法，该函数返回的时分秒与参数中的一样，如果用该 函数作为区间条件，会发生下面的情况。
	SQL>	WITH t AS
	2	(SELECT to_date(*1980-12-31 13:20:30*	,*yyyy-mm-dd hh24:mi:ss') AS
dlf
	3	to_date('1980-12-3105:20:30',	'yyyy-mm-dd hh24 : mi : ss *) AS d2
	4	FROM dual)
	5	SELECT dl, d2 FROM t;
	D1	D2
	1980-12-31 15:20:30 1980-12-31 05:20:30
	SQL>	WITH t AS
	2	(SELECT to_date('1980-12-31 15:20:30,	,* yyyy-mm-dd hh24:mi:ss *) AS
dir
	3	to_date(t1980-12-3105:20:30',	'yyyy-mm-dd hh2 4 : mi : s s 1) AS d2
	4	FROM dual)
	5	SELECT dl, d2 FROM t WHERE dl BETWEEN trunc (d2, 'mm') AND last_day (d2);
	未选定行
	SQL〉
若要取一个月的数据，应该用下面的方式。
• 133 •
Oracle查询优化改写技巧与案例
WITH t AS
(SELECT to_date('1980-12-31 15:20:30*,	*yyyy-mm-dd hh24:mi:ss1) AS dl,
to_date(*1980-12-31 05:20:30', 1	yyyy-mm-dd hh24:mi:ss f) AS d2
FROM dual)
SELECT dl, d2
FROM t
WHERE dl >= trunc {6.2, ' mm')
AND dl < add_months(trunc(d2, 'mm'),	1)；
Dl D2
1980-12-31 15:20:30 1980-12-31 05:20:30
8.2	INTERVAL
INTERVAL类型中保存的是时间间隔信息，可以通过对应的INTERVAL函数得到 INTERVAL类型的数据。
select INTERVAL	f2	T year as "year",
INTERVAL	-50	1 month as nmonth",
INTERVAL	,99	1 day as/*最大只能用 99*/
INTERVAL	，80	1 hour as "hour",
INTERVAL	* 90	'minute as "minute",
INTERVAL	•3.	15' second as "second",
INTERVAL	•2	12:30:59* DAY to second as "DAY to second",
INTERVAL	113-31 year to month as "Year to month"
from dual;
year	2
month	2
day	+99 00:00:00
hour	+03 08:00:00
minute	+00 01:30:00
second	+00 00:00:03.150000
DAY to second	+02 12:30:59.000000
Year to month	10
• 134 •
第8章日期操作
当增加一个较复杂的时间段时，如上面的“ 02天12小时30分59秒”,通过INTERVAL
实现显然更直观。
8.3 EXTRACT
与TO—CHAR—样，EXTRACT可以提取时间字段中的年、月、日、时、分、秒。不 同的是，EXTRACT的返回值为NUMBER类型。
drop table test; create table test as
select EXTRACT(YEAR from systimestamp) as "YEAR",
EXTRACT(MONTH from systimestamp) as "MONTH”，
EXTRACT(DAY from systimestamp) as "DAY",
EXTRACT(HOUR from systimestamp) as "HOUR",
EXTRACT (MINUTE from systimestamp) as "MINUTE，，，
EXTRACT (SECOND from systimestamp) as '*SECOND" from dual;
SQL> desc test;
Name Type Nullable Default Comments
YEAR NUMBER Y MONTH NUMBER Y DAY NUMBER Y HOUR NUMBER Y MINUTE NUMBER Y SECOND NUMBER Y
select * from test;
YEAR	MONTH	DAY	HOUR	MINUTE	SECOND
2014	6	9	7	45	9.625
EXTRACT不能取DATE中的时、分、秒，示例如下:
SQL> SELECT created, extract(DAY FROM created) AS d
2	FROM dba_objects
3 WHERE object_id =2;
CREATED	D
• 135 •
Oracle查询优化改写技巧与案例
2013-10-11 11
1 row	selected
SQL> SELECT extract(hour		FROM created) AS h
2	FROM dba_objects
3 WHERE object_id = 2;
SELECT	extract(hour FROM	created) AS h
FROM	dba_objects
WHERE	object id = 2
ORA-30076:对析出来源无效的析出字段
TO CHAR可以，示例如下:
SQL> SELECT	created, to_	char(created, 1dd') AS d, to—char(created, 1 hh241)
AS h
2 FROM	dba_objects
3 WHERE	object_id =	2；
CREATED	D H
2013-10-11	11 09
1 row selected
EXTRACT可以取INTERVAL中的信息，示例如下：
SQL> SELECT extract(hour FROM it) AS "hour"
2	FROM (SELECT INTERVAL 12 12:30:59' DAY TO SECOND AS it FROM dual); hour
12
1	row selected
而TO_CHAR不行，示例如下：
SQL> SELECT to一char(it, rhh24') AS "hour"
2	FROM (SELECT INTERVAL f2 12:30:59’ DAY TO SECOND AS it FROM dual); hour
+02 12:30:59.000000
1	row selected
• 136 •
第8章 B期操作
8^4 确定一年是否为闰年
若要判断一年是否为闰年，只需要看二月的月末是哪一天就可以。
SQL> SELECT trunc (hiredate, 'y')年初
2	FROM emp	、
3	WHERE empno = 7788;
年初
1982-01-01
1	row selected
SQL〉SELECT add_months (trunc (hiredate, 1 y') f 1) 二月初
2	FROM emp
3 WHERE empno = 7788;
二月初
1982-02-01
1	row selected
SQL> SELECT last_day (add_months (trunc (hiredate, 1 y') r 1) ) AS 二月底
2	FROM emp
3 WHERE empno = 7788;
二月底
1982-02-28 1 row selected
SQL> SELECT to_char(last_day(add_months(trunc(hiredate, 'y')f 1) ) , 1DD*) AS曰
2	FROM emp
3 WHERE empno = 7788;
曰
28
1 row selected
• 137 •
Oracle查询优化改写技巧与案例
8^5周的计算
WITH x AS
(SELECT t rune (SYS DATE, f YY' ) + (LEVEL - 1) AS 日期 FROM dual CONNECT BY LEVEL <= 8)
SELECT 日期，
/*返回值1代表周日，2代表周一....*/ t。一char (日期，'d') AS d, to_char(曰期，[day') AS day,
数2中1代表周日,2代表周一-----*/
next_day (日期，1) AS下个周日，
/*ww_的算法为每年1月1日为第一周开始，date+6为每一周结束*/ to_char (日期，'ww ') AS ww,
/*Iw的算法为星期一至星期日算一周，且每年的第一个星期一为第一周*/ to_char (曰期，'iw ') AS iw FROM x;
日期	D	DAY	下个周日	WW	IW j
2014-1-1	4	星期三	2014-1-5	1	1
2014-1-2	5	星期四	2014-1-5	1	1
2014-1-3	6	星期五	2014-1-5	1	1
2014-1-4	7	星期六	2014-1-5	1	1
2014-1-5	1	星期日	2014-1-12	1	1
2014-1-6	2	星期一	2014-1-12	1	2
2014-1-7	3	星期二	2014-1-12	1	2
2014-1-8	4	星期三	2014-1-12	2	2
注意以下两点： ①参数“day”与字符集有关，所以提倡改用“d”。
②WW与IW都是取“第几周”，只是两个参数的初始值不一样。
第8章曰期操作
8_6确定一年内属于周内某一天的所有日期
本例要求返回指定年份内的所有周五，用前面介绍的知识枚举全年信息，然后再过滤 就可以。
WITH x AS
(SELECT trunc(SYSDATE, 'y') + (LEVEL - 1) dy FROM dual
CONNECT BY LEVEL <= add_months(trunc(SYSDATE, 'y1), 12) - trunc(SYSDATE,
fy'))
SELECT dy, to_char (dy> 'day1 ) AS 周五 FROM x WHERE to_char (dy, Vd' ) = 6; DY	周五
2014-01-03 星期五 2014-01-10 星期五 2014-01-17 星期五 2014-01-24 星期五
本节的要点是使用“to_char(dy/d’）= 6”来判断，这样可以避免不同客户端设置的影 响，如：
SQL〉select to一char (hiredate, ' day1) as day, to_char (hiredate, 'd') as d from emp where rownum <=1;
DAY	D
星期三 4
SQL> alter session set nls_language=american;
Session altered.
SQL> select to_char (hiredate, 'day') as day, to_char (hiredate, 'd，）as d from emp where rownum <=1;
DAY	D
Wednesday 4
可以看到，当使用参数“day”时，不同字符集返回的结果不一样，但“d”不受影响。
• 139 •
Oracle查询优化改写技巧与案例
8^7确定某月内第一个和最后一个“周内某天”的日期
本例要求返回当月内第一个星期一与最后一个星期一，我们分别找上月末及当月末之 前七天的下一周周一即可。
SELECT next_day (trunc (hiredate, 'mm') - 1, 2)第一■个周
next一day <last_day (trunc (hiredate, 'ram1) ) — 7, 2)最后一个周' FROM emp WHERE empno = 7788;
第一个周一最后一个周一
1982-12-06	1982-12-27
1 row selected
有很多人不理解为什么要分别用“-1”、“-7”，要注意next_day是“下一”的意思, 我们可以通过下面的数据来分析。
WITH x AS
(SELECT to_date('2013-03-241,	'yyyy-rran-dd') + (LEVEL - 1) AS dy
FROM dual CONNECT BY LEVEL <= 10)
SELECT dy, to_char(dy, 'day1) AS DAY, next一day(dy, 2) AS dl FROM x;
DAY — Dl
2013-03 2013-03 2013-03-26 2013-03-27 2013-03-28 2013-03-29 2013-03-30 2013-03-31 2013-04-0： 2013-04-02
0 ▼ i星期六20： 20：
2 - mmn 20：
2013-03-25 2013-04-01 2013-04-01 星期三 2013-04-01 星期四 2013-04-01 2013-04-01 2013-04-01 13-04-01 2013-04-08 2013-04-08
可以看到，通过上月末（2013-03-31 )才能得到其“下一周一”（2013-04-01)。而通 过之前七天（31-7=4,即：2013-03-24)才能得到其“下一周一”，也就是3月的最后一 个周一 (2013-03-25)o
• 140 •
第8章日期操作
我们再看下面的例子。
WITH x AS
(SELECT to—date(*2013-09-23 *,	'yyyy-mm-dd1) + (LEVEL - 1) AS dy
FROM dual CONNECT BY LEVEL <= 15)
SELECT dy, to_char(dy, * day') AS DAY, next_day(dy, 2) AS dl FROM x;
DY	|DAY_JD1 _ |
2013-09-23 ‘	星期 »2013-09-30 ’
2013-09-24 ,	星期;2013-09-30 v
2013-09-25 ,	2013-09-30 ▼
2013-09-26 ，	20i3-<»-30 叫
2013-09-27 ▼	mSSa. 2013-09-30 -
2013-09-28 ，	期六 2013~0M0 ’
2013-09-29 ^	2013-09-30
2013-09-30 二	厓節 1 201S-10-07 ▼
2013>10-Q1 ,	星期三7|3013-1<M>7 ’
2013-10-02 ▼	igW^ 2<03>10-07 -
2013-KMB ’	2oi3-io-o7 ,丨
2013-10-04 ▼	mmE. 2013-10^7 ▼丨
2013-10-05，	2013-10-07 ▼
2013-10-06 |	2013-10-07 ^
2013-10-07『	MM— 2013-10-14
创建本月日历
枚举指定月份所有的日期，并转换为对应的周信息，再按所在周做一次“行转列”即
WITH xl AS /*1、给定一个日期*/
(SELECT to—date(•2013-06-01 *, fyyyy-mm-dd*) AS cur_date FROM dual), x2 AS
/★2、取月初*/
(SELECT trunc (cur_date, ’mm*) AS 月初，
add—months (trunc (cut—date, 'mm') / 1) AS 下月初 FROM xl), x3 AS
/★3、枚举当月所有的天*/
(SELECT 月初 + (LEVEL - 1) AS 0 FROM x2
• 141 •
Oracle查询优化改写技巧与案例
CONNECT BY LEVEL <=(下月初-月初））， x4 AS
/*4、提取周信息*/
(SELECT to_char (日，’iw，）所在周， to_char (曰，'dd •)曰期， to_number (to_char (日，1 d'))周几 FROM x3)
SELECT MAX (CASE 周几 WHEN 2 TEEN 日期 END)周一,
MAX (CASE	周几	WHEN	3	THEN	日期	END)	周二
MAX(CASE	周几	WHEN	4	THEN	曰期	END)	周二
MAX(CASE	周几	WHEN	5	THEN	日期	END)	周四
MAX(CASE	周几	WHEN	6	THEN	曰期	END)	周五
MAX(CASE	周几	WHEN	7	THEN	日期	END)	周六
MAX(CASE	周几	WHEN	1	THEN	日期	END)	周日
FROM x4 GROUP BY所在周 ORDER BY所在周；
i周一	周二 周三 周四				周五	周六	周日 1
						1	2
3	4	5	6		7	8	9
10	11	12	13		14	15	16
17	18	19	20		21	22	23
24	25	26	27		28	29	30
8^9 全年日历
前面介绍了一个月的日历怎么写，那么如果是全年呢？其实枚举365天就可以。 这里有一个小问题，第53周的数据to_char(日期，’iw')返回值有错，返回了第1周。
WITH x AS
(SELECT to_date(12013-12-271,	1yyyy-mm-dd*) + (LEVEL - 1) AS d
FROM dual CONNECT BY LEVEL <= 5)
SELECT d, to_char(d,	*	day') AS DAY, to_ehar(d,	'iw') AS iw FROM x;
D	PAY	IW
• 142 •
第8章日期操作
2013-12-27 星期五 2013-12-28 星期六 2013-12-29 星期日 2013-12-30 星期一 2013-12-31 星期二 5 rows selected	52 52 52 01 01
这种数据需要用case when来处理。
WITH xO AS
(SELECT to_date('	2013-12-27、' yyyy-mm-dd1) h	h (LEVEL - 1) AS d
FROM dual
CONNECT BY LEVEL	<=5),
xl AS
(SELECT d,
to一char(d,	•day” AS DAY,
to char(d,	'mm') AS mm.
to一char(d,	'iw’） AS iw
FROM xO)
SELECT df
DAY,
CASE
WHEN mm =	*12' AND iw = '01' THEN
f 53'
ELSE
iw
END AS iw
FROM xl;
D DAY	IW
2013-12-27 星期五	52 -
2013-12-28 星期六	52
2013-12-29 星期日	52
2013-12-30 星期一	53
2013-12-31 星期二	*53
5 rows selected
于是全年日历可查询为：
WITH xO AS
(SELECT 2013 AS 年份 FROM dual),
• 143 •
Oracle查询优化改写技巧"J•案例
xl AS
(SELECT trunc (to一date (年份，'yyyy') ,	'	YYYY') AS 本年初，
add一months (trunc (to_date (年份，*yyyyr), 1 YYYY') , 12) AS 下年初 FROM xO), x2 AS /*枚举日期*/ (SELECT 本年初 + (LEVEL - 1) AS 日期 FROM xl
CONNECT BY LEVEL <=下年初-本年初）, x3 AS (
/*取月份，及周信息*/
SELECT 日期，
to_char (日期，'蘭1丨）所在月份， to_char (日期，Iw1)所在周， to一number (to_char (日期，'d'))周几 FROM x2)r x4 AS
/*修正周，12月的“第一周”改为“第十三周” ★/
(SELECT 日期，
所在月份，
CASE
WHEN所在月份=，12' AND所在周=*01，THEN ,53*
ELSE 所在周 END AS所在周，
周几 FROM x3)
SELECT CASE
WHEN lag (所在月份）over (ORDER BY所在周）=所在月份THEN NULL ELSE
所在月份 END AS月份, 所在周，
MAX (CASE	周几	WHEN	2	THEN	日期	END)	周一
MAX (CASE	周几	WHEN	3	THEN	日期	END)	ki —• 周一
MAX (CASE	周几	WHEN	4	THEN	曰期	END)	周二
MAX (CASE	周几	WHEN	5	THEN	曰期	END)	周四
MAX (CASE	周几	WHEN	6	THEN	曰期	END)	周五
第8章日期操作
MAX (CASE 周几 WHEN 7	THEN 日期 END)	周六，
MAX (CASE 周几 WHEN 1	THEN 日期 END)	周曰
FROM x4
GROUP BY所在月份，所在周
ORDER BY 2
通过本例可以看到，使用with语句可以让你的思路及代码展示得非常清晰，你可以 很方便地检查xO、xl、x2、x3、x4各步是否达到了预期目的，这就是with语句的作用之
8.10确定指定年份季度的开始日期和结束日期
生成汇总报表时常要求按季度分类汇总，这就需要通过给定年份，提取对应的季度信 息，如2013年，语句如下：
SELECT sn AS 季度，
(sn - 1) *	3 + 1 AS开始月份，
add months(to date(年，1		yyyy1) / (sn - 1) * 3) as 开始日期，
add months(to—date(年，1		yyyy1) / sn * 3) - x as 结束日期
FROM (SELECT '2013* AS 年，LEVEL AS sn FROM dual CONNECT BY LEVEL <= 4);
季度	开始月份开始日期 结束曰期
1	1 2013-08-01	2013-10-31
2	4 2013-11-01	2014-01-31
3	7 2014-02-01	2014-04-30
4	10 2014-05-01	2014-07-31
4 rows selected
这种枚举季度信息的语句在写报表查询时可能会用到，有必要记录下来备用。
补充范围内丢失的值
有时业务数据并不是连续的，如下面的数据：
SQL> select empno,hiredate from scott.emp order by 2; EMPNO HIREDATE
7369 1980-12-17
Oracle查询优化改写技巧与案例
74 99	1981-02-20
7521	1981-02-22
7566	1981-04-02
7698	1981-05-01
7782	1981-06-09
784 4	1981-09-08
7 654	1981-09-28
7839	1981-11-17
7900	1981-12-03
7 902	1981-12-03
7934	1982-01-23
7788	1987-04-19
787 6	1987-05-23
14 rows selected
有的年份没有招聘员工，这时按年份查询招聘人数，结果如下:
SELECT	to_	_char(hiredate, 'yyyy') AS YEAR, COUNT(*；	)AS cnt
FROM	scott.emp
GROUP	BY	to_char(hiredate, 'yyyy')
ORDER	BY	1；
YEAR		CNT
1980		1
1981		10
1982		1
1987		2
4 rows	selected ,
为了分析数据，一般需要把表中没有的年份（如1983年）内的人数统计为0,这时就 需要先根据表中的信息生成一个年份的枚举列表。
WITH x AS (SELECT 开始年份 + (LEVEL - 1) AS 年份
FROM (SELECT extract (YEAR FROM MIN (hiredate) > AS 开始年份, extract (YEAR FROM MAX (hiredate) ) AS 结束年份 FROM scott.emp)
CONNECT BY LEVEL <=结束年份-开始年份+ 1)
SELECT * FROM x;
年份
• 146 •
第8章日期操作
1980
1981
1982
1983
1984
1985	、
1986
1987
8	rows selected
通过这个列表关联查询，就可以得到所有年份的数据。
WITH x AS (SELECT 开始年份 + (LEVEL - 1) AS 年份
FROM (SELECT extract (YEAR FROM MIN (hiredate) ) AS 开始年份, extract (YEAR FROM MAX (hiredate) ) AS 结束年份 FROM scott.emp)
CONNECT BY LEVEL <=结束年份-开始年份+ 1)
SELECT x.年份，COUNT (e. empno)聘用人数 FROM x
LEFT JOIN scott.emp e ON (extract(YEAR FROM e.hiredate)= GROUP BY x •年份 ORDER BY 1;
年份	聘用人数
1980	1
1981	10
1982	1
1983	0
1984	0
1985	0
1986	0
1987	2
8	rows selected
8.12按照给定的时间单位进行查找
有时需要査找特定的条件，如要求返回2月或12月聘用的所有员工,
X.年份)
以及周二聘用
• 147 •
Oracle查询优化改写技巧1亏案例
的所有员工。 若要得到三个条件返回结果的合集，用to_char函数分别确认雇佣日期是几月及周几, 再过滤就可以^
SELECT	ename姓名，hiredate聘用日期，to_		char (hiredate, 1 day') AS 星期
FROM	emp
WHERE	to char(hiredate, *mm*) IN (* 02'		丨，，12’）
OR	to char(hiredate, 'd') = '3';
姓名	—聘用日期 星期
SMITH	1980-12-17	星期三
ALLEN	1981-02-20	星期五
WARD	1981-02-22	星期日
CLARK	1981-06-09	星期二
KING	1981-11-17	星期二
TURNER	1981-09-08	星期二
JAMES	1981-12-03	星期四
FORD	1981-12-03	星期四
8 rows	selected
要点在于要避免字符集的影响，如这里分别用“ t0_Char(hiredate, 'mm') ”及 “to_char(hiredate，’d’)”来生成与字符集无关的数值信息。
8.13使用日期的特殊部分比较记录
在报表统计中常有同期对比的需求，演示案例需求为：统计相同月份与周内日期聘用 的员工，如有两个员工都是3月份周一聘用的，则可以用分析函数计算次数，然后进行过 滤，语句如下：
SELECT ename AS 姓名，
hiredate AS聘用日期， to_char (hiredater *MON day1) AS 月周 FROM (SELECT ename, hiredate,
COUNT(*) over(PARTITION BY to_char(hiredate, 'MON day')) AS
ct
FROM emp)
WHERE ct > 1/
• 148 •
第8章日期操作
姓名	聘用日期		月周
FORD	1981-12-3	12月星期四
SCOTT	1982-12-9	12月星期四
JAMES	1981-12-3	12月星期四
上述语句中，要注意以下几点：
①我们使用了分析函数“COUNTO	over()”，这样可以只访问一次emp就同时得到
了明细（ename,hiredate)及汇总信息（cnt)。与分析函数之前需要两次访问emp的写法相 比，提高了效率。	，
②因为不需要过滤“to_Char”函数的结果，这里可以不必使用“mmd”写法。
8.14识别重叠的日期范围
下面是一个有关工程的明细数据：
CREATE OR REPLACE VIEW proj_end) AS
SELECT 7782, 'CLARK1 , 1 , UNION ALL
SELECT 7782, 1 CLARK1 , 4 , UNION ALL
SELECT 7782, 'CLARK' , 7 , UNION ALL
SELECT 7782, 'CLARK' , 10, UNION ALL
SELECT 7782, 1 CLARK' , 13, UNION ALL
SELECT 7839； 'KING' , 2 , UNION ALL
SELECT 7839, 'KING' , 8 , UNION ALL
SELECT 7839, 'KING' f 14, UNION ALL
SELECT 7839, 'KING' , 11, UNION ALL
SELECT 7839, 'KING' , 5 , UNION ALL
emp—project(empno, ename, proj_idf proj—start,
date
date
date
date
date
date
date
date
date
date
•2005-06-16', '2005-06-19', ,2G05-06-22', '2005-06-25', ’2005 - 06-28、 '2005-06-17', •2005-06-23、 •2005-06-29', '2005-06-26', •2005-06-20',
date
date
date
date
date
date
date
date
date
date
'2005-06-18» '2005-06-24• '2005-06-25' r2005-06-281 丨2005-07-02， '2005-06-21' 2005-06-25' 丨2005-06-30’ '2005-06-27' 2005-06-241
FROM
FROM
FROM
FROM
FROM
FROM
FROM
FROM
FROM
FROM
dual
dual
dual
dual
dual
dual
dual
dual
dual
dual
• 149 •
Oracle查询优化改写技巧与案例
SELECT	7934,	'MILLER'‘	，3嘗	date	'2005-06-18f	,date	'2005-06-221	'FROM	dual
UNION ALL SELECT	7 934,	•MILLER',	r 12,	date	,2005-06-27 1	1 , date	f2005-06-28	'FROM	dual
UNION ALL SELECT	7934,	1 MILLER1 ,	,15,	date	'2005-06-30'	1 , date	'2005-07-03	• FROM	dual
UNION ALL SELECT	7934,	1 MILLER* ,	r 9 ,	date	*2005-06-241	,date	12005-06-27'	1 FROM	dual
UNION ALL SELECT	7934,	'MILLER',	’ 6 ,	date 丨	'2005-06-211	,date 1	2005-06-23'	FROM dual;
通过数据可以看到，有很多员工在旧的工程结束之前就开始了新的工程（如员工7782 的工程4结束日期是6月24日，而工程7开始日期是6月22日），现要求返回这些工程 时间重复的数据。 前面介绍了 Oracle中有两个分析函数LAG和LEAD,分别用于访问结果集中的前一 行和后一行。我们可以用分析函数LAG取得员工各自的上一个工程的结束日期及工程号， 然后与当前工程相比较。
1.取信息
SELECT empno AS 员工编码， ename AS 姓名， proj_id AS 工程号， proj_start AS 开始曰期，
lag(proj_end) over(PARTITION BY empno ORDER BY proj_start) AS 上 一工程结束日期，
proj_end AS结束日期，
lag (pro j_id) over (PARTITION BY empno ORDER BY proj_start) AS 上一
工程号
FROM emp project;
7782	CLARK.,	1	2005-06-16		2005-06-18
7782	CLARK	4	2005-06-19	2005-06-18	2005-06-24	1
7782	CLARK	7	2005-06-22	2005-06-24	2005-06-25	4
7782	CLARK	10	2005-06-25	2005-06-25	2005-06-28	7
7782	CLARK	13	2005-06-28	2005-06-28	2005-07-02	10
7839	KING	2	2005-06-17		2005-06-21
• 150 •
第8章曰期操作
续表
f 员工编码	姓名	工程号	开始日期	上一工程结束日期	结束日期	Jl 一 I程号I
7839		■■	2005-06-20	2005-06-21	2005-06-24	2
7839	KING	8	2005-06-23	2005-06-24	2005-06-25	5
7839	KING	11	2005-06-26	2005-06-25	2005-06-27	8
7839	KING	14	2005-06-29	2005-06-27	2005-06-30	11
7934	MILLER	3	2005-06-18		2005-06-22
7934	MILLER	6	2005-06-21	2005-06-22	2005-06-23	3
7934	MILLER	9	2005-06-24	2005-06-23	2005-06-27	6
7934	MILLER	12	2005-06-27	2005-06-27	2005-06-28	9
7934	MILLER	15	2005-06-30	2005-06-28	2005-07-03	12
这里增加了“PARTITION BY empno”，这样就可以对数据分组进行分析，不同的empno 之间互不影响。
2.比较
SELECT a ■员工编码， a.姓名， a.工程号， a.开始日期， a.结束日期，
CASE
WHEN上一工程结束日期>-开始日期/*筛选时间重复的数据★/
THEN
•(工程.II lpad(a.工程号，2,，◦•) |丨1)与工程（* II lpadfa.上一工程号，2, »0') |丨，）重复1 END AS描述 FROM (SELECT empno AS 员工编码， ename AS 姓名， proj_id AS 工程号， proj_start AS 开始曰期， proj—end AS结束日期，
lag(proj_end) over(PARTITION BY empno ORDER BY proj_start) AS上一工程结束日期，
lag (pro j一id) over (PARTITION BY empno ORDER BY proj—start) AS
上一工程号
FROM emp_project) a
• 151 •
Oracle查询优化改写技巧与案例
—WHERE上一工程结束日期 >=开始日期 ORDER BY 1, 4；
工程号	开始日期
结束日期
7782	CLARK	1	2005-06-16	2005-06-18
7782	CLARK	4	2005-06-19	2005-06-24
7782	CLARK	7	2005-06-22	2005-06-25	(工程07)与工程（04)重复
7782	CLARK	10	2005-06-25	2005-06-28	(工程10)与工程（07)重复
7782	CLARK	13	2005-06-28	2005-07-02	(工程13)与工程（10)箪复
7839	KING	2	2005-06-17	2005-06-21
7839	KING	5	2005-06-20	2005-06-24	(工程05)与工程（02)重复
7839	KING	8	2005-06-23	2005-06-25	(工程08)与工程（05)重复
7839	KING	11	2005-06-26	2005-06-27
7839	KING	14	2005-06-29	2005-06-30
7934	MILLER	3	2005-06-18	2005-06-22
7934	MILLER	6	2005-06-21	2005-06-23	(工程06)与工程（03)重复
7934	MILLER	9	2005-06-24	2005-06-27
7934	MILLER	12	2005-06-27	2005-06-28	(工程丨2)与工程（09)重复
7934	MILLER	15	2005-06-30	2005-07-03
如果只想看重复数据，取消上面查询的最后一句注释就可以。
8.15按指定间隔汇总数据
本例要求按指定的时间间隔（10分钟）汇总数据，分别汇总至0分、10分、20分、 30分等。
我们用示例数据模拟如下（取自dba—audit—trail):
SELECT * FROM t trail
• 152 •
第8章曰期操作
I TIMESTAMP	ACTION	ACTION_NAME 1
2014-08-10 16:58:20	100	LOGON
2014-08-10 16:58:20	100	LOGON
2014-08-10 16:58:25	101	LOGOFF
2014-08-10 17:29:19	100	LOGON
2014-08-10 17:29:50	101	LOGOFF
2014-08-10 17:29:55	100	LOGON
2014-08-10 17:30:17	101	LOGOFF
2014-08-10 17:30:19	100	LOGON
2014-08-10 丨 7:30:55	101	LOGOFF
2014-08-10 17:32:24	100	LOGON
2014-08-10 17:32:48	102	LOGOFF BY CLEANUP
2014-08-10 17:36:41	100	LOGON
要求得到下面的结果:

2014-08-10 16:50:00	3
2014-08-10 17:20:00	3
2014-08-10 17:30:00	6
如果是直接截取到分钟和小时都好办，我们用mmc函数即可。
SELECT trunc(SYSDATE, 'mi1) AS mi, trunc(SYSDATE, fhh') AS hh FROM dual; MI	HH
2014-08-11 16:28:00	2014-08-11	16:00:00
1 row selected
截取到十位后，我们可以分步处理。 ①截取到分钟，并提取分钟信息：
WITH xO AS
(SELECT to_date(	•2013-12-18	16:15:15*,'	'yyyy-mm-dd hh24:mi:ss') AS cl
FROM dual).
SELECT trunc(cl,	* mi *) AS cl.	,to_char(cl(	r ’mi’） AS mi FROM xO;
• 153 •
Oracle查询优化改写技巧与案例
Cl MI
2013-12-18 16:15:00 15 1 row selected
②对15求余：
SQL> select mod(15,10) as m from dual; M
5 1 row selected
③对比上面两个结果可以看到，cl减去5分钟就可以：
WITH xO AS (SELECT to_date('2013-12-18 16:15:15', 'yyyy-mm-dd hh24:mi:ss') FROM dual) SELECT trunc (cl, 'mi” - 5/24/60 FROM xO;	丨 AS cl
TRUNC(Cl,，MI•)-5/24/60
2013-12-18 16:10:00 1 row selected
则最终的语句可以写为：
SELECT gp, COUNT(*) AS cnt FROM (SELECT TIMESTAMP, trunc(TIMESTAMP, 'mi')- M〇D(t。一char(TIMESTAMP, 'mi'), 10) / 24 / 60 AS gp, action, . action name FROM t_trail) GROUP BY gp;
GP CNT
2014-08-10 3 2014-08-10 • 3 2014-08-10 6 3 rows selected
• 154 •
第9章
范围处理
9.1定位连续值的范围
下面是很多工程的明细信息:
CREATE	OR	REPLACE VIEW v(proj		—id, proj一start, proj一end) AS
SELECT	1 ,	date 1	2005-01-01',	date	*2005-01-02	'FROM	dual	UNION	ALL
SELECT	2 t	date '	2005-01-02、	date	12005-01-03	'FROM	dual	UNION	ALL
SELECT	3 ,	date.'	2005-01-03,,	date	'2005-01-04	'FROM	dual	UNION	ALL
SELECT	4 ,	date 1	2005-01-04、	date	'2005-01-05	1 FROM	dual	UNION	ALL
SELECT	5 ,	date *	2005-01-06',	date	'2005-01-07	'FROM	dual	UNION	ALL
SELECT	6 ,	date '	2005-01-16'f	date	'2005-01-17	'FROM	dual	UNION	ALL
SELECT	7 ,	date •	2005-01-17、	date	'2005-01-18	,FROM	dual	UNION	ALL
SELECT	8 ,	date 1	2005-01-181,	date	'2005-01-19	'FROM	dual	UNION	ALL
• 155 •
Oracle查询优化改写技巧与案例
SELECT	9 ,	date	,2005-01-19l	r	date	•2005-01-20'	FROM	dual	UNION	ALL
SELECT	10,	date	'2005-01-21'	r	date	t2005-01-22f	FROM	dual	UNION	ALL
SELECT	11,	date	•2005-01-26，	/	date	'2005-01-27f	FROM	dual	UNION	ALL
SELECT	12,	date	,2005-01-27,	't	date	,2005-01-28*	FROM	dual	UNION	ALL
SELECT	13>	date	* 2005-01-28'	r	date	»2005-01-29'	FROM	dual	UNION	ALL
SELECT	14,	date	'2005-01-29'	r	date	•2005-01-30'	FROM	dual;
通过数据可以看到有很多工程的时间前后是连续的:
PROJ.ID	PROJ START	PROJ.END _\
1	2005-01-01 -2005-01-02-^	2005-01-02 f 2005-01-03 ▼ ^2005-01-04 ’ "2005-01-05 -
2
3 4	2005-01-03^^ 2005-01-04 ^
5	2005-01-06 ’	2005-01-07 ▼
6	2005-01-16 ▼	2005-01-17 ▼
7	2005-01-17 ▼	2005-01-18 ，
8	2005-01-18 ▼	2005-01-19 ’
现在要求把这种连续的数据査询出来，看到这里，可能有人会想到自关联：
SELECT vl.proj—id AS 工程号，vl .proj_start 开始日期，vl.proj—end 结束日期 FROM v vl, v v2 WHERE v2.proj—start = vl.proj—end;
工程号	开始日期	结束日期
1	2005-01-01	2005-01-02
2	2005-01-02	2005-01-03
3	2005-01-03	2005-01-04
6	2005-01-16	2005-01-17
7	2005-01-17	2005-01-18
8	2005-01-18	2005-01-19
11	2005-01-26	2005-01-27
12	2005-01-27	2005-01-28
13	2005-01-28	2005-01-29
有没有其他的方法呢？其实可以用到第7章介绍的分析函数lead() over()o
SELECT proj_id AS 工程号， proj_start开始日期，
• 156 •
第9章范围处理
proj_end结束日期，
lead (proj_start) over (ORDER BY pro j 一 id)下一工程开始曰期 FROM v;
		开始日期_	结束日期」
L	i	2005-01-01 ，	2005-01-Of	►2005-01-02
1	2	2005-01-02 少	切0^51-03 zi	^2005-01-03 ▼
r r	3	200S-01-03 上 4	2005-01^04^-		•j»W3-Ul-64 2005-01-04 _f\ •^005^01-05 2005-01-06 -KJUb-Ul-Uy - 2005-01-16 "W»C i *7 W •W\c A嘈 m _ I
	5 c	2005-01-06 - fvwic m 噶 c •
得到下一行的信息后，直接过滤就可以。
SELECT工程号，开始日期，结束日期 FROM (SELECT proj_id AS 工程号， proj_start开始日期， proj_end结束日期，
lead (proj—start) over (ORDER BY proj_id)下一工程开始日期 FROM v)
WHERE下一工程开始日期=结束日期；
可以看到，在上面的两种写法中，自关联需要扫描两次视图“V”，而使用分析函数只 需要一次就可以。根据这个特性，在大部分情况下可以通过分析函数优化查询性能。
9.2查找同一组或分区中行之间的差
现有下列登录信息（数据取自dba一audit_trail):
SQL> SELECT * FROM LOG;
登录名	登录时间
HR	2013-07-18	09:52:00
HR	2013-07-18	09:55:00
HR	2013-07-18	09:56:00
HR	2013-07-18	14:17:00
HR	2013-07-18	16:52:00
HR	2013-07-18	16:53:00
OE	2013-07-17	09:00:00
OE	2013-07-17	09:01:00
SYSTEM	2013-07-18	11:48:00
SYSTEM	2013-07-18	11:49:00
• 157 •
Oracle查询优化改写技巧案例
10 rows selected
要求查询各用户两次登录的间隔时间。如果不用分析函数，则需要写很多语句。 ①生成序号。
WITH xO AS (SELECT rownum AS seq,登录名，登录时间
FROM (SELECT登录名，登录时间FROM log ORDER BY登录名，登录时间）e> SELECT * FROM xO;
SEQ登录名	登录时间
1	HR	2013-07-18	09:52:	00
2	HR	2013-07-18	09:55:	00
3	HR	2013-07-18	09:56:	00
4	HR	2013-07-18	14:17:	00
5	HR	2013-07-18	16:52:	00
6	HR	2013-07-18	16:53:	00
7	OE	2013-07-17	09:00:	00
8	OE	2013-07-17	09:01:	00
9	SYSTEM	2013-07-18	11:48:00
10	SYSTEM	2013-07-18	11:49:00
10 rows selected ②通过deptno与seq进行自关联，得到下一行数据。
WITH xO AS (SELECT rownum AS seq,登录名，登录时间
FROM (SELECT登录名，登录时间FROM log ORDER BY登录名，登录时间）e) SELECT el.登录名，el.登录时间，e2.登录时间AS下一登录时间 FROM xO el
LEFT JOIN xO e2 ON (e2.登录名=el.登录名 AND e2. seq = el. seq + 1) ORDER BY 1, 2;
]昼录时间
HR •“	2013-07-18 09:52:00 ^	2013-07-18 09:55:00 ▼
碗 _	2013-07-18 05:55:00	^2013-07-18 09:56:00 ▼
HR	2013-07-18 09:56:00 一	2013-07-1814:17:00 ▼
m ^	2013-07-1814:17:00^^]^	2013-07-1816:52:00 ▼
HR …	2013-07-1816:52:00	^2013-07-1816:53:00 ▼
NR ^	2013-07-1816:53:00
OE~	2013-07-17 09:00:00 2013-07-17 09:01:00	,2013-07-17 09:01 :G0 ’
OE
SYSTEM	2013-07-1811:48:00 -2013-07-1811:49:00	2013-07-1811:49:00 ▼
SYSTEM
• 158 •
第9章范围处理
通过前面介绍的分析函数lead可以很容易地直接取出下一行的信息。
SELECT登录名，
登录时间，
lead (登录时间）over (PARTITION BY登录名ORDER BY登录时间）AS下一登录
时间
FROM log;
③得到下一行数据后，直接计算就可以。
SELECT登录名，登录时间，（下一登录时间-登录时间）* 24 ★ 60 AS登录间隔 FROM (SELECT 登录名， 登录时间,
lead (登录时间）over (PARTITION BY登录名ORDER BY登录时间）AS
下一登录时间
FROM log);
登录名	登录时间		登录间隔
HR	2013-07-18	09:52:00	3
HR	2013-07-18	09:55:00	1
HR .,	2013-07-18	09:56:00	261
HR	2013-07-18	14:17:00	155
HR	2013-07-18	16:52:00	1
HR	2013-07-18	16:53:00
OE	2013-07-17	09:00:00	1
OE	2013-07-17	09:01:00
SYSTEM	2013-07-18	11:48:00	1
SYSTEM	2013-07-18	11:49:00
10 rows	selected
9.3定位连续值范围的开始点和结束点
接着9.1节的数据介绍，现在要求把连续的项目合并，返回合并后的起止时间，如前 四个项目合并后起止时间就是1到5号。
• 159 •
Oracle查询优化改写技巧与案例
PROriD^.	^RO^OTABT PROJ,END I
	2005-01-0^) "^2005-01-02 2005-01-02 ^^2005-01-03^ ▼, 2005-01-03 -fUj

4	2005-01-04 ^^2005-01-05^
^5	2005-01-06 ^ |2O05-Bl-d7 y
6	20054)1-16 ^ 20<^-01-17~^
如果是取最小开始时间和最大结束时间，则比较容易操作：
SQL〉SELECT MIN (proj_start) AS 开始，MAX (proj_end) AS 结束 FROM v; 开始	结束
2005-01-01	2005-01-30
1	row selected
但这与我们的要求显然还差很远，不要急，跟着下面的步骤操作即可。 ①提取上一工程的结束日期。
CREATE OR REPLACE VIEW xO AS SELECT proj_id AS 编号，
proj_start AS 开始日期， proj_end AS结束日期，
lag (proj一end) over (ORDER BY proj一id) AS 上一工程结束日期 FROM v;
SELECT * FROM xO;
： 编号	开始日期	结束日期	上一工程结束日期
l	2005-01-01	2005-01-02
2	2005-01-02	2005-01-03	2005-01-02
3	2005-01-03	2005-01-04	2005-0 丨-03
4	2005-01-04	2005-01-05	2005-01-04
5	2005-01-06	2005-01-07	2005-01-05
6	2005-01-16	2005-01-17	2005-01-07
7	2005-01-17	2005-01-18	2005-01-17
8	2005-01-18	2005-01-19	2005-01-18
9	2005-01-19	2005-01-20	2005-01-19
• 160 •
第9章范围处理
续表
编号	开始日期	结束日期	上一工程结束日期
10	2005-01-21	2005-01-22	2005-01-20
11	2005-01-26	2005-01-27	2005-01-22
12	2005-01-27	2005-01-28	• 2005-01-27
13	2005-01-28	2005-01-29	2005-01-28
14	2005-01-29	2005-01-30	2005-01-29
②标定工程的连续状态。
CREATE OR REPLACE VIEW xl AS SELECT 编号，
开始曰期， 结束曰期， 上一工程结束日期， CASE WHEN开始日期=上一工程结束曰期THEN 0 ELSE 1 END AS连续状态 FROM xO； SELECT * FROM xl;
编号	弁始曰期		结束日期	上一工程结束日期	连续状态
1		2005-01-01	2005-01-02		1
2		2005-01-02	2005-01-03	2005-01-02	0
3		2005-01-03	2005-01-04	2005-01-03	0
4		2005-01-04	2005-01-05	2005-01-04	0
5	2005-01-06	2005-01-07	2005-01-05
6	2005-01-16	2005-01-17	2005-01-07	1
7	2005-01-17	2005-01-18	2005-01-17	0
8	2005-01-18	2005-01-19	2005-01-18	0
9	2005-01-19	2005-01-20	2005-01-19	0
• 161 •
Oracle查询优化改写技巧4案例
续表
编号		开始日期	结束日期	上一工程结束日期	连续状芩
10		2005-01-21	2005-01-22	2005-01-20	1
11	2005-01-26	2005-01-27	2005-01-22	1
12	2005-01-27	2005-01-28	2005-01-27	0
13	2005-01-28	2005-01-29	2005-01-28	0
14	2005-01-29	2005-01-30	2005-01-29	0
可以看到，在每一个连续分组的开始位置，我们都生成了一个“1”作为标识。 ③对这个位置状态进行累加，得到分组依据。
CREATE OR REPLACE VIEW x2 AS SELECT 编号，
开始日期， 结束曰期， 上一工程结束日期， 连续状态，
SUM (连续状态）over (ORDER BY编号）AS分组依据 FROM xl;
SELECT * FROM x2;
编号	开始日期		结束曰期	上一工程结束日期	连续状态	分组依据
1		2005-01-01	2005-01-02		1	1
2		2005-01-02	2005-01-03	2005-01-02	0	1
3		2005-01-03	2005-01-04	2005-01-03	0	1
4		2005-01-04	2005-01-05	2005-01-04	0	1
5		2005-01-06	2005-01-07	2005-01-05	1	2
6		2005-01-16	2005-01-17	2005-01-07	1	3
7		2005-01-17	2005-01-18	2005-01-17	0	3
8		2005-01-18	2005-01-19	2005-01-18	0	3
9		2005-01-19	2005-01-20	2005-01-19	0	3
• 162 •
第9章范围处理
续表
10	2005-01-21	2005-01-22	2005-01-20	1	4
11	2005-01-26	2005-01-27	2005-01-22	1	5
12	2005-01-27	2005-01-28	2005-01-27	0	5
13	2005-01-28	2005-01-29	2005-01-28	0	5
14	2005-01-29	2005-01-30	2005-01-29	0	5
可以看到，通过提取数据（上一行日期）一生成标识一累加标识这些操作后，得到了 需要的5个连续分组，有分组依据后就容易完成下面的操作。
SELECT分组依据，MIN (开始日期）AS开始日期，MAX (结束日期）AS结束日期 FROM x2 GROUP BY分组依据 ORDER BY 1;
分组依据开始日期	结束日期
1	2005-01-01	2005-01-05
2	2005-01-06	2005-01-07
3	2005-01-16	2005-01-20
4	2005-01-21	2005-01-22
5	2005-01-26	2005-01—30
把上面各步骤整理在一起的语句如下:
SELECT分组依据，MIN(开始日期）AS开始日期，MAX(结束日期）AS结束日期 FROM (SELECT 编号， 开始曰期， 结束曰期，
SUM (连续状态）over (ORDER BY编号）分组依据 FROM (SELECT pro j 一 id AS 编号，
proj_start AS 开始日期， prdj_end AS结束日期， CASE WHEN lag(proj一end) over(ORDER BY proj_id) proj_start THEN 0 ELSE 1 END 连续状态 FROM v))
GROUP BY分组依据 ORDER BY 1;
• 163 •
Oracle查询优化改写技巧W案例
9.4合并时间段
现有下面一份考勤单，其中的数据有些乱，要求把其中连续或重叠的时间段合并。 CREATE OR REPLACE VIEW Timesheets(task_id, start一date , end_date) AS
SELECT	1,	DATE	*1997-01-01	r	DATE	-1997-01-03.	FROM	dual	UNION	ALL
SELECT	2,	DATE	11997-01-02f	t	DATE	,1997-01-04，	FROM	dual	UNION	ALL
SELECT	3,	DATE	•1997-01-04	r	DATE	,1997-01-05l	FROM	dual	UNION	ALL
SELECT	4,	DATE	•1997-01-06,	r	DATE	•1997-01-09,	FROM	dual	UNION	ALL
SELECT	5,	DATE	•1997-01-091	»	DATE	,1997-01-09t	FROM	dual	UNION	ALL
SELECT	6,	DATE	•1997-01-09，	r	DATE	’1997-01-09,	FROM	dual	UNION	ALL
SELECT		DATE	'1997-01-12'	t	DATE	•1997-01-15*	FROM	dual	UNION	ALL
SELECT	8,	DATE	'lggv-oi-xs1	r	DATE	• 1997-01-13*	FROM	dual	UNION	ALL
SELECT	9f	DATE	,1997-01-15'	t	DATE	,1997-01-15l	FROM	dual	UNION	ALL
SELECT	10	DATE	,1997-01-17	» r	DATE	'1997-01-17'	FROM	dual	r
SQL> select * from Timesheets; TASK ID START DATE END DATE
1	1997-01-01	1997-01-03
2	1997-01-02	1997-01-04
3	1997-01-04	1997-01-05
4	1997-01-06	1997-01-09
5	1997-01-09	1997-01-09
6	1997-01-09	1997-01-09
7	1997-01-12	1997-01-15
8	1997-01-13	1997-01-13
9	1997-01-15	1997-01-15
10	1997-01-17	1997-01-17
10 rows selected
前面刚介绍了一个方法，为了处理重叠的数据，我们把条件改为“>=”：
SELECT分组依据，1^11^<开始日期）AS开始日期，MAX (结束日期〉AS结束日期 FROM (SELECT 编号，
开始日期，
结束曰期，
SUM (连续状态）over (ORDER BY编号）分组依据 FROM (SELECT task_id AS 编号，
start—date AS 开始日期， end_date AS结束日期，
• 164 •
第9章范围处理
CASE WHEN lag(end_date) over(ORDER BY task_id) > start一date THEN 0 ELSE 1 END 连续状态 FROM timesheets))
GROUP BY分组依据 ORDER BY 1;
	分结依据」开始日期」结束曰期_J
	1		1997-01-01 ▼	1997-01-05 ▼
r	—	2	1997-01-06 ’	1997-01-09 ▼
			1997-01-12 ▼	1997-01-15 ^
		[4	1997-01-15 ▼	1997-01-15 1
		5	1997-01-17 ▼	1997-01-17 •
这个结果显然不对，问题在于id为7、8、9的这三列：
7	1997-01-12	1997-01-15
8	1997-01-13	1997-01-13
9	1997-01-15	1997-01-15
id 7与id 9是连续的，但中间id 8的数据与id 9不连续，所以用lag取上一行来判 断肯定不对。这时可以用另一个开窗方式来处理：获取当前行之前的最大“emi_date”。
SELECT start一date, end—date,
MAX(end_date) over(ORDER BY start_date rows BETWEEN unbounded preceding AND 1 preceding) AS max_end_date FROM timesheets b;
START.DATE —	END DATE	MAX END DATE
1997-01-01 ▼	1997-01-03 ▼	▼
1997-01-02 ▼	1997-01-04 ，	1997-01-03 ,
1997-01-04 -	1997-01-05 ▼	1997-01-04 ▼
1997-01-06 ▼	1997-01-09 ▼	1997-01-05 ▼
1997-01-09 ，	1997-01-09 ，	1997-01-09 ▼
1997-01-09 ，	1997-01-09 f	1997-01-09 ▼
1997-01-12 ▼	1997-01-15	1997-01-09 ▼
1997-01-13 ▼	1997-01-13	1997-01-15 ▼
1997-01-15 -	1997-01-15 、	1997-01-15 ▼
1997-01-17 -	1997-01-17 ▼	1997-01-15 ▼
前面章节介绍过 “BETWEEN unbounded preceding AND 1 preceding” 就是一个 “BETWEEN…AND…”子句，整个子句的意思就是“第一行到上一行”，而该分析函数 就是 “ORDER BY start一date” 后“第一行到上一行”范围内的 “MAX(end_date)”。
• 165 •
Oracle查询优化改写技巧案例
有了这个数据后再来判断，就可以把id (7、8、9)判断为连续范围了。
WITH xO AS (SELECT task一id,
start一date, end—date,
MAX(end_date) over(ORDER BY start_date rows BETWEEN unbounded preceding AND 1 preceding) AS max_end_date FROM timesheets b), xl AS
(SELECT start—date AS 开始时间， end_date AS结束时间， max_end_date,
CASE WHEN max一end—date >= start_date THEN 0 ELSE 1 END AS 连续状态 FROM xO)
SELECT * FROM xl;
jfmmm —	结束时间」	MAX_END_DATE
1997-01-01 ▼	1997-01-03 ▼			1|
1997-01-02 ▼	1997-01-04 ▼	1997-01-03	▼	oj
1997-01-04 ▼	1997-01-05 ，	1997-01-04		o|
1997-01-06 ▼	1997-01-09 ▼	1997-01-05		i|
1997-01-09 ▼	1997-01-09 ▼	1997-01-09		0|
1997-01-09 ▼	1997-01-09 ▼	1997-01-09		0
L997-01-12 ▼	1997-01-15 ▼	1997-01-09		1
L997-01-13 ’	1997-01-13 ▼	1997-01-15		0
L997-01-15 ▼	1997-01-15 ▼	1997-01-15		0
lggV-di-iV ▼	1997-01-17 ▼	1^97-61-15		r
这样结果就对了。
WITH xO AS (SELECT task_id,
start_date, end—date,
MAX(end_date) over(ORDER BY start_date rows BETWEEN unbounded preceding AND 1 preceding) AS max_end_date FROM timesheets b), xl AS
(SELECT start一date AS 开始时间， end_date AS结束时间， max_end_date,
CASE WHEN max end date >= start date THEN 0 ELSE 1 END AS 连续状态
• 166 •
第9章范围处理
FROM xO), x2 AS (SELECT开始时间，
结束时间，
SUM (连续状态）over (ORDER BY开始时间）AS分组依据 FROM xl.)
SELECT分组依据，MIN (开始时间〉AS开始时间，MAX (结束时间〉AS结束时间 FROM x2 GROUP BY分组依据 ORDER BY分组依据；
分组依据	开始时间	结束时间
1	1997-01-01	1997-01-05
2	1997-01-06	1997-01-09
3	1997-01-12	1997-01-15
4	1997-01-17	1997-01-17
• 167 •
第10章
高级查找
10J 给结果集分页
为了便于查询网页中的数据，常常要分页显示。如：要求员工表（EMP的数据）按工 资排序后一次只显示5行数据，下次再显示接下来的5行，下面以第二页数据（6到10 行）为例进行分页。
前面己讲过，要先排序，然后在外层才能生成正确的序号：
SELECT rn AS 序号，ename AS 姓名，sal AS 工资 /★3、根据前面生成的序号过滤掉6行以前的数据★/
FROM (SELECT rownura AS rn, sal, ename
/*2、取得排序后的序号，并过滤掉10行以后的数据*/
FROM (
• 168 •
第10章高级查找
/*!,按sal排序*/
SELECT sal, ename FROM emp WHERE sal IS NOT NULL order by
sal) x
WHERE rownum		<=10)
E rn	>=6;
序号	姓名	工资
6	MILLER	1300.	,00
7	TURNER	1500.	.00
8	ALLEN	1600.	00
9	CLARK	2450.	00
10	BLAKE	2850.	,00
①为什么不直接在内层应用条件“ WHERE rownum <= 10”呢？下面对比一下rownum 的结果。
SELECT rownum AS e2_seq, el“seq, sal, ename FROM (SELECT rownum AS el_seq, sal, ename FROM emp el WHERE sal IS NOT NULL
AND	deptno =		20
ORDER	BY	sal)	e2;
SEQ	El_	SEQ	SAL ENAM
1		1	800	SMITH
2		4	1100	ADAMS
3		2	2975	JONES
4		5	3000	FORD
5'		3	3000	SCOTT
5 rows selected
可以看到，内层直接生成的r0wmim(El_SEQ)与sal的顺序不一样，要想得到正确的 顺序，就要先排序，后取序号。
②为什么不直接用“rownum <= 10 and rownum >= 6”，而要分幵写呢？下面来看一下。
SQL> select count(*) from emp;
COUNT(*)
14
1	row selected
SQL> select count(★) from emp where rownum >= 6 and rownum <= 10;
Oracle查询优化改写技巧与案例
COUNT(★)
0
1	row selected
如第1章所述，因为rownum是一个伪列，需要取出数据后，rownum才会有值，在 执行“where rownum >= 6”时，因为始终没取前10条数据出来，所以这个条件就查询不 到数据，需要先在子查询中取出数据，然后外层用“WHERE m>= 6”来过滤。
你也可以先用row_number()生成序号，再过滤，这样就只需要嵌套一次。
SELECT rn AS 序号，ename AS 姓名，sal AS 工资
FROM (SELECT row一number 0 over(ORDER BY sal) AS rn, sal, ename FROM emp WHERE sal IS NOT NULL) x WHERE rn BETWEEN 6 AND 10;
这个语句比较简单，但因为分页语句的特殊性，在调用PLAN时可能会受到分析函数 的影响，有些索引或PLAN (如：first_rows)不能用。所以，在此建议大家使用第一种分 页方式，把第一种分页方式当作模板，然后套用。
10.2重新生成房间号
现有房间号数据如下:
CREATE	TABLE		hotel	• (floor_nbr, r<
SELECT	1,	100	FROM	dual	UNION	ALL
SELECT	1,	100	FROM	dual	UNION	ALL
SELECT	2,	100	FROM	dual	UNION	ALL
SELECT	2,	100	FROM	dual	UNION	ALL
SELECT	3,100		FROM	dual;
里面的房间号是不对的，正常应该是101、102、201、202的形式。现要求重新生成 房间号，我们可以用学到的mwjiumber重新生成房间号，或许马上会有读者想到UPDATE 语句。让我们来执行一下。
UPDATE hotel
SET room—nbr =
(floor一nbr * 100) + row_number() over(PARTITION BY floor_nbr ORDER
BY ROWID);
QRA-30483 : window函数在此禁用
• 170 •
第10章高级查找
0	UPDATE STATEMENT ,'		1 |		0	100:01:59	57
i -	-UPDATE,	HCTEL |	1 1、	.	0	100:01:59	57
2	TABLE • ACCESS FOll j	HOTEL !		、：^ 1	' 5	I 00:00:00
3	VIEW	.		r- 5	5	j00：00：00	01
	WINDOW. SORT • i		5	'5 i	25	I 00:00;00	01
5	TABLE ACCESS FITLLI	HOTEL,. 1	、• ' 5	X 5 |	25	100:00:00	01
Predi.ca"Ce.. Inforrr.ari'on (ider.nifby £>perat:ior- id)：.
3 - filter(W3M.R0WID=:31i
有人想用“可更新VIEW”，语句如下：
UPDATE (SELECT ROWID, room_nbr,
(floor_nbr * 100) + row一number(> over(PARTITION BY floor一nbr ORDER BY ROWID) AS new_nbr FROM hotel)
SET room一nbr = new_nbr;
ORA-OX732: It视图的数据_纵操作非法
这些方法都不可靠，当然，把UPDATE再嵌套一层也可以：
UPDATE hotel a SET room一nbr =
(SELECT room_nbr
FROM (SELECT (floor_nbr ★ 100) + row一number() over(PARTITION BY floor_nbr ORDER BY ROWID) AS room一nbr FROM hotel) b WHERE a.rowid = b.rowid);
SQL> select * from hotel;
FLOOR NBR ROOM NBR
1	101
1	102
2	201
2	202
3	301
5 rows selected
2 2 4 5. 5 5 4 4 1111
• 171 •
Oracle查询优化改写技巧S?案例
0	MERGE STATEMENT J	'1
1	MERGE	HOTEL j
2	VIEW « |	:I
* 3	HASH JOIN
4	VIEW |	r
5'	WINDOW SORT )	•W，i
.6	TABLE ACCESS FULL I	HOTEL |
7	TABLE ACCESS RJLL 1	HOTEL 丨
这种方法虽然能成功，但由执行计划可以看到，子查询执行了 5次，对HOTEL有5 次全表扫描。那么如果表更大，是不是更慢？ 另一个方法是用MERGE语句。
MERGE INTO hotel a
USING (SELECT ROWID AS rid,
(floor_nbr ★ 100) + row_number() over(PARTITION BY floor—nbr ORDER BY ROWID) AS room一nbr FROM hotel) b ON (a.rowid - b.rowid)
WHEN MATCHED THEN
UPDATE SET a.room_nbr = b.room_nbr;
SQL> select * from hotel;
FLOOR NBR ROOM NBR
1	101
1	102
2	201
2	202
3	301
5 rows selected
通过PLAN可以看到，使用MERGE子査询只对hotel访问了一次，效率提高了很多,
Predicate Information (idenrified by operation xd):
3 - access (”A'ROWID=wB".ROWID)
i i 1 1 ,4 1 丄 ill
OOOOOOGO
o o c o o o o o o o o o o o c- o
0 0 0 0 0 0 0-0 o Q o o o o ry o
0 0 0 0 0 0-00 OOOOOOGO
• 172 •
第10章高级查找
10.3跳过表中n行
有时为了取样而不是査看所有的数据，要对数据进行抽样，前面介绍过选取随机行， 这里将介绍隔行返回，对员工表中的数据每隔一行返回一个员工，如下只返回下面方框标 识的部分。
EMPNO」ENAME」SAL」
I 7876	ADAMS	1100
"T^gg^LW		~mr1
| 7698	BLAKE	2850 j
7/82	LLAkk
| 7902	FORD	3000 |
7900 JAMES		950
I 7566	JONES	2975 |
7839	KING	5000
| 7654	MARTIN	1250 |
7934	MILLER	1300
Lzm.	UU	_mil
为了实现这个目标，用求余函数mod即可，我们先看一下mod的结果。
SELECT empno, ename, sal, MOD(rn, 2) AS m FROM (SELECT rownum AS rn, empno, ename, sal
FROM (SELECT empno, ename, sal FROM emp ORDER BY ename) x) y;
EMPNO	ENAME	SAL	M
7876	ADAMS	1100	1
7499	ALLEN	1600	0
7698	BLAKE	2850	1
7782	CLARK	2450	0
7902	FORD	3000	1
7900	JAMES	950	0
7566	JONES	2975	1
7839	KING	5000	0
7654	MARTIN	1250	1
7934	MILLER	1300	0
7788	SCOTT	3000	1
7369	SMITH	800	0
• 173 •
Oracle查询优化改写技巧*5案例
7844 TURNER	1500	1
7521 WARD	1250	0
14 rows selected
对返回的数据增加过滤条件即可。
SELECT empno, ename, sal, MOD(rn, 2) AS m
FROM (SELECT rownum AS rn, empno, ename, sal
FROM (SELECT empno, ename, sal FROM emp WHERE M〇D(rn, 2) - 1;
ENAME	M
ADAMS	1
BLAKE	1
FORD	1
JONES	1
MARTIN	1
SCOTT	1
TURNER	1
7 rows selected 通过这个函数，想间隔几行返回都可以实现。
ORDER BY ename) x) y
104排列组合去重
下面介绍一个数据组合去重的问题。数据环境模拟如下:
DROP TABLE TEST PURGE;
CREATE	TABLE		TEST	(id'tl,t2,t3) AS
SELECT	lr	'1'	1 , *3,	，'2,	FROM	dual	UNION	ALL
SELECT	2,	'1'	1 , '3'	,'2'	FROM	dual	UNION	ALL
SELECT	3,	.3,	i ,	,'1’	FROM	dual	UNION	ALL
SELECT	4,	•4’	| , *2’	,*1,	FROM	dual;
上述测试表中前三列tl、t2、t3的数据组合是重复的（都是1、2、3),要求用查询 语句找出这些重复的数据，并只保留一行。我们可以用以下步骤达到需求。
①把tl、t2、t3这三列用列转行合并为一列。
第10章
高级查找
SELECT *
FROM test unpivot<b2 FOR b3 IN(tl, t2, t3));
ID B3 B2
1	Tl	1
1	T2	3
1	T3	2
2	Tl	1
2	T2	3
2	T3	2
3	Tl	3
3	T2	2
3	T3	1
4	Tl	4
4	T2	2
4	T3	1
12 rows selected "unpivot"的具体用法将在第11章介绍。 ②通过listagg函数对各组字符排序并合并。
WITH xl AS (SELECT *
FROM test unpivot(b2 FOR b3 IN(tl, t2, t3)))
SELECT id, listagg(b2,	',，>	within	GROUP(ORDER BY b2) AS b
FROM xl GROUP BY id;
ID B
1	1,2,3 ♦	2	1,2,3
3	1,2,3
4	1,2,4
4 rows selected
③执行常用的去重语句。
WITH xl AS
• 175 •
Oracle查询优化改写技巧4案例
(SELECT ★ FROM test unpivot(b2 FOR b3 IN(tl, t2, t3))), x2 AS
(SELECT id, listagg(b2,	',1) within GROUP(ORDER BY b2) AS b
FROM xl GROUP BY id)
SELECT id, b, row_number () over (PARTITION BY b ORDER BY id) AS sn FROM x2;
ID B	SN
1	1,2,3	1
2	1,2,3	2
3	1,2,3	3
4	1,2,4	1
4	rows selected 如上所示，如果要去掉重复的组合数据，只需要保留SN=1的行即可。
10.5找到包含最大值和最小值的记录
构建数据如下：
DROP TABLE TEST PURGE;
CREATE TABLE TEST AS SELECT * FROM dba_objects;
CREATE INDEX idx_test_object_id ON TEST(object_id);
begin dbms_stats.get_table_stats(ownname => user,tabname => 'TEST *);
要求返回最大/最小的object_id及对应的object_name，在有分析函数以前，可以用 下面的查询：
SELECT	object	name, object id
FROM	test
WHERE	object_	id IN (SELECT MIN(object_id) FROM test UNION ALL SELECT MAX(object_id) • FROM test);
OBJECT_	_MAM OBJECT一ID
C_OBJ#		2
TEST		88695
• 176 •
第10章高级查找
1 i 1 1 1 o o o o o 0:010:0:0: o D o □ o •• t «• <• «• 0 6 0 0 0 o Q 000
2	(0)|	00:00:01
1	(0)1	00:00:01
2	(0>丨	00:00:01
-••
3 3 3 3 i 1 1*
2
2
2
2
2
WiJtSOJL
IDX_TEST一OBJECT 二ID
IDX_TZST_OBJECT一ID IDX二 tEST二OS JECT二 ID TEST _
SELECT 5TATEMENT NESTED IjOOPS
' HASH UNIQOE
SORT AGGREGATE INDEX FULL SCAN (MIN/MAX) ■ SORT AGGREGATE TW«»nr FTrr r VAN (MIN/MAX) DEX RANGE. SCAN IX ACCESS BY IN^EX RCWXD
TABLE &CCES.
Informnt3.on (idencifi.ed by operation X'd);
10 - accesfl,t"OBJECT* ID"*"HIN (OBJECT ID1"J
dynamic sampling uaed for this statement (level-2)
recursive calls db block gees
consistent gets •	、
physical ■ read5 redo sue'	'
bytes.aenc vi« SQL^Nec to client bye eta received via SQL»Nec frejm client SQL*Mec roondtrips to/froa clieni:、
sores (dislc) rows processed
2	rows selected
需要对员工表扫描三次。但用如下分析函数只需要对员工表扫描一次：
SELECT object一name, object_id FROM (SELECT object一name, object_idf
MIN(object_id) over() min一idr MAX(obj ect_id) over() max_id FROM test) x WHERE object_id IN (min_id/ max_id);
如果读者形成惯性思维，认为分析函数的效率最高，那就错了。我们用autotrace看一 F PLAN (可以多执行几次）。 第一个语句的执行计划，如下图所示：
可以看到，第一个语句虽然访问了三次，但三次都是用的索引，所以效率并不低, 第二个语句执行计划如下图所示：
177
Oracle查询优化改写技巧与案例
8315KI
8315K!
6256KI
6256KI
Predicate Information (identified by operation id):.
1 - filter ("OBJECT一ID”.="MIN-ID" OR "OBJECT一ID"==WMAX一ID")
一 dynamic sampling used for this statement (level=2) 统计信息
4	recursive calls
0	db bloclc gees
1307	consistent gets
•1241	physica.1 reads
0	redo size
541 bytes sent: via SQL^Net to client 415	bytes received via SQL^Net from client
2	5QL*Net roundtrip3 to/from client
1	sorts (memory)
0	sorts (disk)
2	row3 processed
TZST
SELECT STATEMENT VIEW WINDOW BUFFER TASLE ACCESS FULL
31092
81092-
81092
81092
：Cperation
Cose (%CPU)I Time
Bytes
Rov;s
Plan hash value: 109304066^：
(1)| 00:00:05 (1)f 00:00:05 (1)| 00:00:05 (1)I 00:00:05
4 4 4 4*
3 3 3 3
因为用的是分析函数，因此效率反而更低。所以，除语句的改写外，大家还要学会分 析 PLAN。
______第11章
报表和数据仓库运算
11.1	行转列
‘‘行转列”的内容在做报表或语句改写时要经常用到，是一个非常重要的语句。
在Oracle中，有CASE WHEN END和Oracle llg新增的PIVOT函数两种方式。其中:
①CASE	WHEN END编写和维护较麻烦，但适合的场景较多。
②PIVOT编写和维护简单，但有较大限制。
下面简单介绍这两种方法。
查询需求为：对emp表按job分组汇总，每个部门显示为一列。
首先看一下最常用的CASE WHEN END的方法。
• 179 •
Oracle查询优化改写技巧4案例
根据不同的条件来取值，就可以把数据分为几列。 SELECT job AS 工作，
CASE	deptno	WHEN	10	THEN	sal	END	AS	部门	10	工资,
CASE	deptno	WHEN	20	THEN	sal	END	AS	部门	20	工资,
CASE	deptno	WHEN	30	THEN	sal	END	AS	部门	30	工资,
sal AS合计工资
FROM emp ORDER BY 1;
工 作	部门10工资	部门20工资	部门30工资	合计工资 I
ANALYST		3000		3000
ANALYST		3000		3000
CLERK	1300			1300
CLERK			950	950
CLERK		800		800
CLERK		1100		1100
MANAGER			2850	2850
MANAGER		2975		2975
MANAGER	2450			2450
PRESIDENT	5000			5000
SALESMAN			1500	1500
SALESMAN			1250	1250
SALESMAN			1250	1250
SALESMAN			1600	1600
只是这样的数据看上去杂乱无章，需要再按job分组汇总，所以一般“行转列”语句 里都会有聚集函数，就是为了把同类数据转为一行显示。
另外，要注意最后一列，我们增加了合计工资的显示，这在后面介绍的PIVOT函数 中是做不到的，PIVOT函数只能按同一个规则分类各数据，各列之间的数据不能交叉重复。 SELECT job AS 工作，
SUM (CASE	deptno	WHEN	10	THEN	sal	END)	AS	部门	10	工资,
SUM (CASE	deptno	WHEN	20	THEN	sal	END)	AS	部门	20	工资,
SUM(CASE	deptno	WHEN	30	THEN	sal	END)	AS	部门	30	工资,
SOM (sal) AS合计工资 FROM emp
• 180 •
第11章报表和数据仓库运算
GROUP BY job ORDER BY 1;
I 工 作	部门10工资	部门20工资	部门30工资	合计工资 j
ANALYST		6000		6000
CLERK	1300	1900	950	4150
MANAGER	2450	2975	2850	B275
PRESIDENT	5000			5000
SALESMAN			5600	5600
下面看一下Omcle llg新增的“行转列”函数P1V0T，对简单的PIVOT环境提供了 简单的实现方法。
SELECT *
FROM (SELECT job,/★该列未在pivot中，所以被当作分组条件★/ sal, deptno FROM emp)
pivot (SUM(sal) AS s/*SUM、MAX等聚集函数+列别名，若不设置，则默认只使用后面in
里设的别名，否则两个别名相加*/
FOR deptno
IN (10 AS dlO,"相当于 sum (case when deptno = 10 then sal end) as dlO 别名与前面的别名合并后为D10_S*/
20	,/★相当于 sum (case when deptno = 20 then sal end) as 20
若列别名不设置，则默认使用值作为别名，此处为20，与前面的合并后 为 20_S*/
30 AS d30/*相当于 sum (case when deptno = 30 then sal end) as d30 别名与前面的别名合并后为D30 S*/
ORDER BY 1;
[ JOB	D10_S Y	20_S	D30—S j
ANALYST		6000
CLERK	1300	1900	950
MANAGER	2450	2975	2850
PRESIDENT	5000
SALESMAN			5600
• 181 •
Oracle查询优化改写技巧与案例
SELKC了 霣	；；•.	•
.man ；(SELECT； job, sal/ conatt, dept.no
TJiM emp:):	'\	•
pivot (SUH (sal) ?•..：' ^5ij!i(dQimn) 4S C ::F0k deptno m (10 紅 ci/o^	3,与o As；d3a)；;
Cin>fJ'. by i；|
大家可以看一下两种方式的对比，如果还要增加提成的返回，用PIVOT则只需要增 加一个设定即可。
对于PIVOT语句中返回列名称来源，用图表示如下: 工资：DIO S、D20 S、D30 S
提成：DIO C、D20 C、D30 C
1	SELECT *
2	Ff-Ofi ' (SELE'-'T job, sal, conon,
…:::r；PX:勝 emp)
pivot (3Ufl (sal) AS s, ..UM (eomra)
depciic* ;
in®	\	s®:
〕oe	DI03	DIO—C D203	D33J；	D30_S	'C
i ANAL YST	KJUI •
2	CLERK
3	MANAGER
■ PRESIDENT ：SALESMAN:
1300
2450
5000
1900
2975
5600
2200
SELECT *
FROM (SELECT job, FROM emp) pivot(SUM(sal) AS FOR deptno IN(10 AS dlO,
)
ORDER BY 1;
sal, comm, deptno s,SUM(comm) AS c 20 AS d20,30 AS d30)
• 182 •
第11章报表和数据仓库运算
而用CASE WHEN要增加三行语句》 SELECT job,
sum(case	when	deptno	=	10	then	sal	end)	AS	dlO_s,
sum(case	when	deptno	=	20	then	sal	end)	AS	d20_s.
sum(case	when	deptno	=	30	then	sal	end)	AS	d30 s.
sum(case	when	deptno	=	10	then	comm	,end)	AS	dlO_c,
sum(case	when	deptno	=	20	then	comm	end)	AS	d20_c.
sum(case	when	deptno	=	30	then	comm	end)	AS	d30_c
FROM emp GROUP BY job ORDER BY 1;
PIVOT —次只能按一个条件来完成“行转列”，如果同时把工作与部门都转为列，并 汇总为一行时，PIVOT就无能为力了，这时只能用CASE WHEN。
SELECT COUNT(case when deptno = 10 then ename end) AS deptno_10/
COUNT(case	when	deptno	=20 then	ename	end)	AS deptno 20,
COUNT(case	when	deptno	=30 then	ename	end)	AS deptno_30.
COUNT(case	when	job =	,CLERK'	then	ename	end)	AS clerks
COUNT(case	when	job =	'MANAGER*	then	ename	end)	AS mgrs,
COUNT(case	when	job =	■PRESIDENT,	丨 then	ename	end)	AS prez,
COUNT(case	when	job =	'ANALYST1	then	ename	end)	AS anals,
COUNT(case	when	job =	'SALESMAN'	then	ename	end)	AS sales
FROM emp;
DEPTNO_1Q	DEPTNQ_20	DEPTNQ_30	CLERKS	MGRS	PREZ	ANALS	SALES
3			4		1	2	4
最后分析一下 PIVOT 的 PLAN (用 dbms_xplan.display_cursor 看）:
Id | Opesarion
5ytea I Cost (%CP0)j Tlae
0	I SELECT STATEMENT |
1	1 SORT SSOUP BY PrVOT I
2	| TABLE ACCESS FULL | EMF
4 【100) I	I
■!	(25> | 00j00r01 |
3	(0)| 00:00:01 |
oluxcn Projection Inforntacion (ider.tiftea by operation id) i
1	-	-JOS" tVARCRfiFJ. 10], SOM (CASE WHEN riEPTKC^-iO) THES
"SAL" END ) (22), SOM (CASE WHEN ("DEPTOO—IO) THEN "COMM" END ) 122] * SUM (CASE WREN ("rDEPTNC,'=20j THEN "SAL" END );22J, SUM【CASE WHEW (■BEPTNO"-20) THEM "CO*!- END ) \22\, 3!3M(CAS2	fTH£H
"SM.- END ) 122), SOM<CASE WHE1I t ■DEFTIK>tr»30) THEM _CCMK" DJD >{2.2】
2	- "JOB" [VaRCHAR2,101, "SAL" {NUMBER. 22 J f -CCMM*' [W7M3SB, 22),
”DEPTHO"INUMBER,221
已选择27行.
• 183 •
Oracle查询优化改写技巧与案例
通过PLAN可以看到，PIVOT被转换成了如下语句：
SUM(CASE WHEN ("DEPTNO"=10) THEN "SAL" END )[22],
SUM(CASE WHEN (nDEPTNO"=10) THEN "COMM" END )[22],
SUM(CASE WHEN ("DEPTNO"=20) THEN "SAL" END )[22],
SUM(CASE WHEN ("DEPTNO"=20) THEN "COMM" END )[22],
SUM(CASE WHEN ("DEPTNO"=30) THEN "SAL" END )[22],
SUM(CASE WHEN ("DEPTNO"=30) THEN "COMM" END )[22]
也就是说，PIVOT只是写法简单了一些，实际上仍用的是CASE WHEN语句。
11.2	列转行
测试数据如下：
DROP TABLE TEST PURGE;
CREATE TABLE test AS SELECT *
FROM (SELECT deptno,sal FROM emp) pivot(COUNT(*) AS ct,SUM(sal) AS s FOR deptno
IN (10 AS deptno_l0, 2:0 AS deptno_20, 30 AS deptno_30)); SELECT * FROM test;
I DEPTNO_fO_GT	DEPTNO一10_S	DEPTNO—2。一CT	DEPTNCL20—S	DEPTNO_30_CT	DEPTNO一30_S I
3	8750	5	10875	6	9400
要求把三个部门的“人次”转为一列显示。以前这种需求一直用UNION ALL来写:
SELECT ' 10f AS 部门编码，DEPTN〇_10_CT AS 人次 FROM test UNION ALL
SELECT f20' AS 部门编码，DEPT1SI〇_20_CT AS 人次 FROM test UNION ALL
SELECT f30f AS 部 f]编码,DEPTN〇_30—CT AS 人次 FROM test;
这时PLAN如下:
第11章报表和数据仓库运算
,7---------------------------：-----------:-----
Plan hash' value: 21'7€e^912S
Id	Operation	:1	Name*	Raws	3yces	& 23Z	(%CPD)I	Time
0 1	• SELECT STATEMENT I DNTON-ALI. • 1		.^	3	39	! 9 1	(0) 1 1	00：00{01
2 '	TABLE ACCESS	FOI L I	一 , TEST	1	'13	1 . • 3	(or i	00:60:01
3	TABLE ACCESS	FULLI	TEST	1	13	I 3	(0) I	00:00:01
4	TA3LE ACCESS	FtJLLl	TEST	• i*	13	1 3	(0) 1	00:00^:01
需要扫描test三次，而且如果列数较多，这种查询编写与维护都比较麻烦，而用 UNPIVOT 就不一样了。
SELECT *
FROM test
unpivot (人次 FOR deptno IN (deptno_10一CT, deptno一20_CT, deptno_30_CT)); UNPIVOT函数生成两个新列：“deptno”与“人次”如下表。
而 in()中的 deptno_10_CT、deptno_20_CT 和 deptno_30_CT 三列，其列名成为行 “deptno” 的值：
RSELECT •
FROM teat
unprvot (人次 FOR deptno IN (depcno_lQ_CT, deptno_20_CT, deptno_30_CT));
%			\ H 4^-
DEPTNO 10 S	DEPTN0.20_S |DEPTWO_30_S |DEPTf^j I# A
8750	10875 9400 l|DEPTNO_10_a/ /3|
8750	10875	9400	DEPTN0.20.OT | X 5
8750	10875	9400	DEPTNO_30_CT | 6
列中的值分别转为“人次”列中的三行:
185 •
Oracle查询优化改写技巧与案例
DEPTNOJO.S —	DEPTNO_20_S —	DEPTNO_3Q_S —	DEPTNO
8750|	10875	9400	DEPTNO_10_CT
8750	10875	9400	DEPTNO 20 CT		^
8750	10875	9400	DEPTNOJO.CT
语句整理如下：
SELECT deptno AS 列名，substr (deptno, -5, 2) AS 部门编码，人次 FROM test
unpivot (人次 FOR deptno IN (deptno_10_CT, deptno_20_CT, deptno_30_CT));
列 名	部门编码		、 次
DEPTNO_10_CT	10	3 •
DEPTNO一20_CT	20	5
DEPTNO—30一CT	30	6
这时PLAN如下:
Plan hash, value: 734373962
| Id	I Operation	i- Name	f Rows i	3yces 丨.	1 Cost (%GPU)'	Tiise
1 o	| SELECT STATEMENT	J * I	3 1	91 i	1 9 (0)|	00:00:01 1
\* 1	| VIEW		1 ' 3 ]	81 ;	9 {0> 1	00j00;01 t
1 2	! UNPIVOT .	f |	1 *!	1 - • • I	| |
I 3	TABLE ACCESS FULL	.；TEST ；	! 1 1	39	3 (0) 1	00:00:01 |

可以看到，与PIVOT不一样，UNPIVOT不仅语句简略，而且只需要扫描test—次。 我们可以很容易地在后面的in列表里维护要转换的列。当然，UNPIVOT同样有限制， 如果同时有人次与工资合计要转换，就不能一次性完成，只有分别转换后再用JOIN连接。
SELECT a •列名，a .部门编码，a.人次，b,工资
FROM (SELECT substr(deptno, 1, 9) AS 歹！J名，substr(deptno, -5, 2) AS 部 门编码，人次
FROM test
unpivot include NULLS (Aft FOR deptno IN (deptno 一 10_ct, deptno 一 20_ct, deptno_3 0_ct))
)a
INNER JOIN (SELECT substr (deptno, 1, 9) AS 列名，工资 FROM test
unpivot include NULLS(工资 FOR deptno IN(deptno_10_s,
• 186 •
第11章报表和数据仓库运算
deptno_20_s, deptno—30一s)) )b
ON (b•列名=a.列名）；
I 列.名	部门编码	人 次	x m I
DEPTNO一 10	10	3	8750
DEPTNO_20	20	5	10875
DEPTNQ_30	30	6	9400
这里为了让两个结果集一致，使用了参数INCLUDE NULLS,这样即使数据为空，也 显示一行。 是否有办法只用UNPIVOT，而不用JOIN呢？看下面的示例：
SELECT deptno,人次,deptno2,工资 FROM test
unpivot include NULLS (人次 FOR deptno IN (deptno—10—ct AS 10,
deptno_20_ct AS 20, deptno_30_ct AS 30)) unpivot include NULLS (工资 FOR deptno2 IN (deptno_10—s AS 10,
deptno_20_s AS 20, deptno_30_s AS 30))
ORDER BY 1,3;
| DEPTNO	人次	DEPTN02	工资 |
10	3	10	8750
10	3	20	10875
10	3	30	9400
20	5	10	8750
20	5	20	10875
20	5	30	9400
30	6	10	8750
30	6	20	10875
30	6	30	9400
可以看到，当有两个UNPIVOT时，生成的结果是一个笛卡儿积，其中粗体字部分才 是我们需要的。
• 187 •
Oracle查询优化改写技巧4案例
上面的语句实际上就是一个嵌套语句，前一个UNPIVOT结果出来后，再执行另一个 UNPIVOT：
WITH xO AS
(SELECT deptno,人次，deptno_10_s, deptno一20_s, deptno一30—s FROM TEST
unpivot include NULLS (人次 FOR deptno 工N (deptno_10_ct AS 10,
deptno一20_ct AS 20, deptno_30_ct AS 30)))
SELECT deptno,人次，deptno2,工资 FROM xO
unpivot include NULLS (工资 FOR dept no 2 IN (deptno_10_s AS 10,
deptno一20_s AS 20, deptno_30_s AS 30))
ORDER BY 1, 3;
针对需要的数据，在上面的查询上加一个过滤即可。
SELECT deptno AS部门编码，人次，工资 FROM test
unpivot include NULLS {人次 FOR deptno IN (deptno_10_ct AS 10,
deptno_20_ct AS 20, deptno_30__ct AS 30)) unpivot include NULLS (工资 FOR deptno2 IN (deptno一 10_s AS 10,
deptno—20_s AS 20, deptno_30_s AS 30))
WHERE deptno = deptno2;
部门编码	>	、 次	工 资
10	3		8750
20	5		10875
30	6		9400
11.3将结果集反向转置为一列
有时会要求数据竖向显示，如SMITH的数据显示如下（各行之间用空格隔开）:
• 188 •
第门章报表和数据仓库运算
SMITH
CLERK
800
我们使用刚学到的UNPIVOT,再加一点小技巧就可以。
SELECT EMPS
FROM (SELECT ENAME, JOB, TO—CHAR (SAL) AS SAL, NULL AS T_COL/*猶"这一 歹!]来显示空行*/ FROM EMP WHERE deptno = 10)
UNPIVOT INCLUDE NULLS(EMPS FOR COL IN(ENAME, JOB, SAL, T_COL));
EMPS
CLARK
MANAGER
2450
KING
PRESIDENT
5000
MILLER
CLERK
1300	•
已选择12行。
这里要注意以下两点。
①与UNION	ALL 一样，要合并的几列数据类型必须相同，如果sal不用to_char转 换，就会报错：
SELECT EMPS
FROM (SELECT ENAME, JOB, SAL, NULL AS T_CQIj/★增加这一列来显示空行*/ FROM EMP WHERE deptno = 10)
UNPIVOT INCLUDE NULLS(EMPS FOR COL IN(ENAME, JOB, SAL, T_COL)); ORA-01790:表达式必须具有与对应表达式相同的数据类型
②如果不加include	nulls,将不会显示空行：
SELECT EMPS.
FROM (SELECT ENAME, JOB, TO—CHAR (SAL) AS SAL, NULL AS T—COL FROM EMP WHERE deptno = 10)
UNPIVOT (EMPS FOR COL IN(ENAME, JOB, SAL, T—COL)>;
Oracle查询优化改写技巧与案例
EMPS
CLARK
MANAGER
2450
KING
PRESIDENT
5000
MILLER
CLERK
1300
已选择9行。
11.4抑制结果集中的重复值
我们返回的数据中经常会有重复值，如EMP.JOB,这些数据经常要求合并显示。这种 一般都在前台处理，偶尔也有特殊情况，需要在返回时就只显示第一行数据，该如何处理 呢？其实用LAG进行判断即可。
SELECT CASE
"当部门分类按姓名排序后与上一条内容相同时不显示★ WHEN lag(job) over(ORDER BY job, ename) NULL ELSE job END AS职位， ename AS 姓名 FROM emp WHERE deptno =20 ORDER BY emp.job, ename;
job THEN
职位
姓名
ANALYST FORD SCOTT CLERK	ADAMS
SMITH
• 190 •
第11章报表和数据仓库运算
MANAGER JONES
5	rows selected
或许有人注意到，order by子句后的job加上了前缀。如果不加前缀，而且列别名仍 然是job会出现什么情况？
SELECT CASE
WHEN lag(job) over(ORDER BY job, ename) = job THEN NULL ELSE job END AS job, ename FROM emp WHERE deptno =20 ORDER BY job, ename;
JOB	ENAME
ANALYST FORD CLERK	ADAMS
MANAGER JONES SCOTT SMITH
5	rows selected
可以看到，orderby子句后优先使用的是“别名”，而不是“列名”，从而使排序结果 与需求不一样。所以大家要养成加“前缀”的习惯。
11.5利用“行转列”进行计算
本例要求计算部门20与部门10及部门20与部门30之间的总工资差额。
部	n	工资合计		_ 额
30		9400	10875-9400= 1475
20		10875
10		8750	10875-8750 = 2125
对于这种需求，可以通过“行转列”把各值提到同一行上后，再进行计算。
• 191 •
Oracle查询优化改写技巧与案例
SELECT dlO_sal, d20_sal , d30_sal, d20一sal - dlO_sal AS d20一10一diff, d20_sal - d30_sal AS d20_30_diff
FROM (SELECT SUM(CASE WHEN deptno =10 THEN sal END) AS dl0_sal,
SUM(CASE WHEN deptno = 20 THEN sal END) AS d20_sal,
SUM(CASE WHEN deptno = 30 THEN sal END) AS d30_sal FROM emp) totals_by一dept;
D10一SAL	D20—SAL	D30_SAL	P20_10_DIFF	D20J30_DIFF
8750	10875	9400	2125	1475
11^6 给数据分组
有时为了方便打印，会要求多行多列打印，如emp.ename类似下面这样显示:
ADAMS	ALLEN	BLAICE	CLARK	FORD
JAMES	JONES	KING	MARTIN	MILLER
SCOTT	SMITH	TURNER	WARD
要达到这个目的，需要以下操作。
1.生成序号
WITH xl AS (SELECT ename FROM emp ORDER BY ename), x2 AS
(SELECT rownum AS rn, ename FROM xl) SELECT * FROM x2;
RN ENAME
1	SMITH
2	ALLEN
2.通过ceil函数把数据分为几个组
WITH xl AS (SELECT ename FROM emp ORDER BY ename)•
• 192 •
第11章报表和数据仓库运算
x2 AS
(SELECT	rownum AS	rn, ename FROM xl),
x3 AS
(SELECT	ceil(rn /	5) AS gp, ename FROM x2)
SELECT ★	FROM x3;
GP	ENAME
1	SMITH
1	ALLEN
1	WARD
1	JONES
1	MARTIN
2	BLAKE
2	CLARK
2	SCOTT
2	KING
2	TURNER
3	ADAMS
3	JAMES
3	FORD
3	MILLER
14 rows selected
3.给各组数据生成序号
WITH xl AS
(SELECT	ename FROM emp ORDER BY ename)•
x2 AS
(SELECT	rownum AS	rn, ename FROM xl),
x3 AS
(SELECT	ceil(rn /	5) AS gp, ename FROM x2),
x4 AS
(SELECT gp, ename.		row_nuinber () over (PARTITION BY gp ORDER BY ename) AS rn
FROM x3)
SELECT *	FROM x4;
GP	ENAME	RN
1	ADAMS	1
1	ALLEN	2
• 193 •
Oracle查询优化改写技巧与案例
1 BLAKE	3
1 CLARK	4
1 FORD	5
2 JAMES	1
2 JONES	2
2 KING	3
2 MARTIN	4
2 MILLER	5
3 SCOTT	1
3 SMITH	2
3 TURNER	3 .
3 WARD	4
14 rows selected
4.通过分组生成序号,	并进行行转列
WITH xl AS
/*1.排序*/
(SELECT ename FROM	emp ORDER BY ename)r
x2 AS
1*2.生成序号*/
(SELECT rownum AS	rn, ename FROM xl),
x3 AS
/★3.分组★/
(SELECT ceil(rn /	5) AS gp, ename FROM x2),
x4 AS
/*4.分组生成序号★/
(SELECT gp, ename.	row number() over(PARTITION	BY gp ORDER BY ename) AS
rn
FROM x3)
/*5.行转列*/
SELECT *
FROM x4 pivot(MAX(ename) FOR rn 工N(1 AS nl,
	2 AS n2.
	3 AS n3f
	4 AS n4,
	5 AS n5));
GP Nl	N2 N3 N4	N5
1 ADAMS	ALLEN BLAKE CLARK	FORD
• 194 •
第11章报表和数据仓库运算
2 JAMES	JONES	KING	MARTIN	MILLER
3 SCOTT	SMITH	TURNER	WARD
3	rows selected
有些前台打印功能较弱，就可以用这种办法直接返回需要的数据进行打印。
11.7对数据分组
如果想对数据进行分组（比如，“五•一”节放假三天，公司需要对雇员和经理分三 组值班），我们可以用分析函数ntile来处理这个分组需求。
SELECT ntile (3) over (ORDER BY empno) AS 组，empno AS 编码，ename AS 姓名 FROM emp
WHERE job IN ('CLERK', 'MANAGER1);
组	编码姓名
1	7369	SMITH
1	7566	JONES
	7698	BLAKE
2	7782	CLARK
2	7 876	ADAMS
3	7 900	JAMES
3	7 934	MILLER
7 rows selected 至于为什么分成了 3、2、2,这里不进行详细说明。
1^计算简单的小计
生成报表数据时通常还要加一个总合计，必须要用UNION ALL来做吗？答案是否定 的，我们用ROLLUP就可以达到这个目的。
SELECT deptno, SUM(sal) AS s_sal FROM emp GROUP BY ROLLUP(deptno); DEPTNO	S SAL
10	8750
20	10875
• 195 •
Oracle查询优化改写技巧与案例
30	9400
29025
4	rows selected
上述语句中，ROLLUP是GROUP BY子句的一种扩展，可以为每个分组返回小计记 录，以及为所有的分组返回总计记录。 为了便于理解，我们做一个与UNION ALL对照的实例。
SELECT deptno AS 部门编码，job AS 工作，mgr AS 主管，SUM (sal) AS s_sal FROM emp
GROUP BY ROLLUP(deptno, job, mgr);
以上査询相当于下面四个汇总语句的结果合并在一起：
SELECT deptno AS 部门编码，job AS 工作，mgr AS 主管，SUM (sal) as s_sal FROM emp GROUP BY deptno , job, mgr UNION ALL
SELECT deptno AS 部门编码，job AS 工作，mTLL/★工作小计*/ AS 主管，SUM(sal) as s_sal
FROM emp GROUP BY deptno/ job UNION ALL
SELECT deptno AS 部门编码，部门小计*/ AS 工作，NULL AS 主管，SUM (sal) as s—sal
FROM emp GROUP BY deptno UNION ALL
SELECT NULL /*总合计*/, NULL AS 工作，NULL AS 主管，SUM (sal) as s_sal FROM emp;
I 部门编码	工 作	主 管	S_SAL 丨 |
10	CLERK	7782	1300
10	CLERK		1300
10	MANAGER	7839	2450
10	MANAGER		2450
10	PRESIDENT		5000
10	PRESIDENT		5000
10			8750
• 196 •
第11章报表和数据仓库运算
续表
部门编码	工 作	主 管	S一SAL }
20	CLERK	7788	1100
20	CLERK	7902	800
20	CLERK		1900
20	ANALYST	7566	6000
20	ANALYST		6000
20	MANAGER	7839	2975
20	MANAGER		2975
20			10875
30	CLERK	7698	950
30	CLERK		950
30	MANAGER	7839	2850
30	MANAGER		2850
30	SALESMAN	7698	5600
30	SALESMAN		5600
30			9400
			29025
可能这种方式有很多人己用过，如果按部门编号和工作两列汇总，加上总合计有没有 办法处理呢？ 我们可以把部门与工作这两列放入括号中，这样部门与工作会被当作一个整体：
SELECT deptno AS 部门编码， job工作，
SUM (sal) AS工资小计 FROM emp GROUP BY ROLLUP((deptno, job));
I 部门编码	工 作	工资小计 j
CLERK	CLERK	1300
MANAGER	MANAGER	2450
PRESIDENT	PRESIDENT	5000
CLERK	CLERK	1900
• 197 •
Oracle查询优化改写技巧4案例
续表
部门编码	工 作	工资小计 |
ANALYST	ANALYST	6000
MANAGER	MANAGER	2975
CLERK	CLERK	950
MANAGER	MANAGER	2850
SALESMAN	SALESMAN	5600
		29025
11_9判别非小计的行
前面介绍了用ROLLUP来生成级次汇总，那么如何判断哪些行是小计呢？ 有些人会说可以用NVL，如NVL(DEPTNO，•总计’)、NVL(JOB，•小计下面来看是否 可行。 首先处理数据：
UPDATE emp SET job = NULL WHERE empno = 7788;
UPDATE emp SET deptno = NULL WHERE empno in (7654,7902);
查询如下：
SELECT nvl (to_char (deptno) ,	1	总计AS 部门编码，
nvl (job,'小计•）AS 工作， deptno, job,
mgr AS主管，
MAX (CASE WHEN empno IN (7788, 7654, 7902) THEN empno END) AS max—empno, SUM(sal) sal,
GROUPING(deptno) deptno_grouping,
GROUPING(job) job_grouping FROM emp
GROUP BY ROLLUP(deptno, job, mgr);
总计
总计
ANALYST
ANALYST
ANALYST
ANALYST
7566
7902
7902
3000
3000
JOB GROUPING
• 198 •
第11章报表和数据仓库运算
续表
部门编码	工作	DEPTNO	JOB	主管	MAX_EMPNO	SAL	DEPTNO_GROUPING	JOB-GROUPING
总计	SALESMAN		SALESMAN	7698	7654	1250	0	0
总计	SALESMAN		SALESMAN		7654	1250	0	0
总计	小计				7902	4250	0	1
10	CLERK	10	CLERK	7782		1300	0	0
10	CLERK	10	CLERK			1300 __	0	0
10	MANAGER	10	MANAGER	7839		2450	0	0
10	MANAGER	10	MANAGER			2450	0	0
10	PRESIDENT	10	PRESIDENT			5000	0	0
10	PRESIDENT	10	PRESIDENT			5000	0	0
10	小计	10				8750	0	I
20	小计	20		7566	7788	3000	0	0
20	小计	20			7788	3000	0	0
20	CLERK	20	CLERK	7788		1100	0	0
20	CLERK	20	CLERK	7902		800	0	0
20	CLERK	20	CLERK			1900	0	0
20	MANAGER	20	MANAGER	7839		2975	0	0
20	MANAGER	20	MANAGER			2975	0	0
20	小计	20			7788	7875	0	1
30	CLERK	30	CLERK	7698		950	0	0
30	CLERK	30	CLERK			950	0	0
30	MANAGER	30	MANAGER	7839		2850	0	0
30	MANAGER	30	MANAGER			2850	0	0
30	SALESMAN	30	SALESMAN	7698		4350	0	0
30	SALESMAN	30	SALESMAN			4350	0	0
30	小计	30				8150	0	1
总计	小计					7902	29025	1	1
通过上面表中粗体字部分可以看到，当有空值（empno为7788,7654,7902)时，对应 的detpno或job本身就是空值，所以小计结果是错误的。
这时我们就要用GROUPING函数，该函数的参数只能是列名，而且只能是group by
• 199 •
Oracle查询优化改写技巧与案例
后显示的列名。 当该列被汇总时，GROUPING的返回值为1,如DEPTNOJ3ROUPING最后一行。 当该列没有被汇总而是显示明细时，GROUPING的返回值为0，如 DEPTNO_GROUPING 前的所有行。 于是查询语句可以更改如下：
SELECT CASE GROUPING (deptno) WHEN 1 THEN •总计1 ELSE to—char (deptno) END AS部门编码，
CASE WHEN GROUPING (deptno) = 1 THEN NULL WHEN GROUPING (job) = 1 THEN •小计* ELSE job END AS 工作，
CASE WHEN GROUPING(job) - 1 THEN NULL WHEN GROUPING(mgr) = 1 THEN •小计■ ELSE to_char (mgr) END AS 主管，
MAX (CASE WHEN empno in (7788f 7654, 7902) THEN empno end) AS max_empno/ SUM (sal) AS工资合计 FROM emp
GROUP BY ROLLUP(deptno, job, mgr);
1 部门编码	工 作	主 管	MAX一EMPNO	工资合计 |
	ANALYST	7566	7902	3000
	ANALYST	小计	7902	3000
	SALESMAN	7698	7654	1250
	SALESMAN	小计	7654	1250
	小计		7902	4250
10	CLERK	7782		1300
10	CLERK	小计		1300
10	MANAGER	7839		2450
10	MANAGER	小计		2450
10	PRESIDENT			5000
10	PRESIDENT	小计		5000
10	小计			8750
20		7566	7788	3000
20	.	小计	7788	3000
20	CLERK	7788		1100
20	CLERK	7902		800
• 200 •
第11章报表和数据仓库运算
续表
I 部门编码 工 作		主 管	MAX_EMPNO	工资合计 |
20	CLERK	小计		1900
20	MANAGER	7839		2975
20	MANAGER	小计		2975
20	小计		7788	7875
30	CLERK	7698		950
30	CLERK	小计		950
30	MANAGER	7839		2850
30	MANAGER	小计		2850
30	SALESMAN	7698		4350
30	SALESMAN	小计		4350
30	小计			8150
总计			7902	29025
11.10计算所有表达式组合的小计
要求按DEPTNCUOB的各种组合汇总，并返回总的合计。可能很多人都用过，那就 是CUBE语句。 CUBE也是GROUP BY子句的一种扩展，可以返回每一个列组合的小计记录，同时 在末尾加上总计记录。 下面介绍一下grouping_id函数，见下列语句中的注释及与GROUPING的对比。
SELECT CASE GROUPING(deptno) |丨 GROUPINGob)
WHEN '00' THEN ，按部门与工作分组’
WHEN '10' THEN ，按工作分组1 WHEN '01' THEN 1按部门分组•
WHEN '11' THEN •总合计■
END AS GROUPING,
• 201 •
Oracle查询优化改写技巧与案例
/* 把 GROUPING (deptno) | 丨 GROUPING (j ob> 的结果当作二进制， 再转为十进制
就是 grouping_id(deptno, job)的值*/
CASE grouping_id(deptno, job)
WHEN 0 THEN •按部门与工作分组•
WHEN 2 THEN ，按工作分组1 WHEN 1 THEN 1按部门分组•
WHEN 3 THEN •总合计•
END grouping_id, deptno AS 部门， job AS I作,
SUM (sal) AS 工资 FROM emp GROUP BY CUBE(deptno, job)
ORDER BY GROUPING (job) , GROUPING (deptno>
GROUPING	GROUPING JD	部 门	工 作	工 资
按部门与工作分组	按部门与工作分组	10	MANAGER	2450
按部门与工作分组	按部门与工作分组	30	MANAGER	2850
按部门与工作分组	按部门与工作分组	30	CLERK	950
按部门与工作分组	按部门与工作分组	20	MANAGER	2975
按部门与工作分组	按部门与工作分组	20	ANALYST	6000
按部门与工作分组	按部门与工作分组	20	CLERK	1900
按部门与工作分组	按部门与工作分组	10	PRESIDENT	5000
按部门与工作分组	按部门与工作分组	30	SALESMAN	5600
按部门与工作分组	按部门与工作分组	10	CLERK	1300
按工作分组	按工作分组		；SALESMAN	5600
按工作分组	按工作分组	：-■ ： _；；_, ；； **. ：；；；, •：	CLERK	:v A I 4150
按工作分组 按工作分组	按工作分组 按X作分姐		ANALYST MANAGER	6000 	： «275
按工作分组	按工作分组	-：.....; „ ::j;	P 晒 IDENT	5000
按部门分组	按部门分组	10		8750
• 202 •
第11章报表和数据仓库运算
续表
I GROUPING	GROUP1NGJD	部 门	工 作	工 资
按部门分组	按部门分组	30		9400
按部门分组	按部门分组	20		10875
总合计	总合计			29025
grouping与grouping_id之间的关系及对应的group by对比如下:
CASE GROUPlNG(deptno) || GROUPFNG(job)	CASE grouping_id(deptno, job)	二进制数转十进制数	group by
WHEN W THEN	WHEN 0THEN	00=0	deptnojob
•按部门与工作分组•	•按部门与工作分组1
WHEN'10, THEN	WHEN 2 THEN	10=2	job
1按工作分组•	•按工作分组•
WHEN 'Or THEN	WHEN 1 THEN	01=1	deptno
1按部门分组，	•按部门分组*
WHEN THEN	WHEN 3 THEN	11=3	总合计没有 group by
•总合计'	•总合计'
END AS GROUPING	END groupingid
11.11人员在工作间的分布
本例要求每种工作显示为一列，每位员工显示一行，员工与工作对应时显示为I,不 对应则显示为空，结果如下：
j ENAME	IS_CLERK	IS一SALES	IS_MGR	IS一ANALYST	IS—PREZ
MILLER	1
ADAMS	1
JAMES	1
SMITH	1
ALLEN		1
WARD		1
• 203 •
Oracle查询优化改写技巧与案例
续表
ENAME					IS_ANALYST		IS—PREZ ：
TURNER			1
MARTIN			1
JONES				1
BLAKE				1
CLARK				1
SCOTT						1
FORD						1
KING							1
我们可以活用PIVOT函数，按工作、员工分组，则对应位置为1:
SELECT *
FROM (SELECT ENAMEr JOB FROM EMP)
PIV0T(SUM(1) FOR JOB IN(fCLERK' AS IS_CLERK,
'SALESMAN' AS IS_SALES,
'MANAGER* AS IS一MGR,
'ANALYST1 AS IS一ANALYST,
■PRESIDENT1 AS IS_PREZ))
ORDER BY 2, 3, 4, 5, 6;
这个语句相当于group by ename,job。
11.12	创建稀疏矩阵
把n.ii节的需求变化一下，对应位置直接显示为员工姓名，且增加在部门间的分布, 因未对数据进行汇总，所以仍可以用PIVOT来处理，查询语句如下：
SELECT *
FROM (SELECT empno, ename, ename AS ename2, deptno, job FROM emp) pivot(MAX(ename) FOR deptno IN (10 AS deptno_10,
20 AS deptno一20,
30 AS deptno—30>) pivot(MAX(ename2) FOR job IN(rCLERK1 AS clerks,
•MANAGER' AS mgrs,
• 204 •
第11章报表和数据仓库运算
'PRESIDENT' AS prez,
1 ANALYST' AS anals, f SALESMAN' AS sales))
ORDER BY 1;
I EMPNO	DEPTNO一 10	DEPTNQ_20	DEPTNO—30	CLERKS	MGRS	PREZ	ANALS	SALES I
7369		SMITH		SMITH
7499			ALLEN					ALLEN
7521			WARD					WARD
7566		JONES			JONES
7654			MARTIN					MARTIN
7698			BLAKE		BLAKE
7782	CLARK				CLARK
7788		SCOTT					SCOTT
7839	KING					KING
7844			TURNER					TURNER
7876		ADAMS		ADAMS
7900			JAMES	JAMES
7902		FORD					FORD
7934	MILLER			MILLER
注意：如果对数据有汇总，就不要用这种有两个PIOVT的方式。因为这种查询实际 上相当于两个PIVOT的子句嵌套。 在11.1节中有一个count的case when语句，具体如下：
SELECT COUNT(case when deptno = 10 then ename end) AS deptno_10,
COUNT(case	when	deptno	=20 then	ename	end)	AS deptno_20,
COUNT(case	when	deptno	=30 then	ename	end)	AS deptno_30,
COUNT(case	when	job ='	,CLERK 1	then	ename	end)	AS	clerks
COUNT(case	when	job =丨	'MANAGER1	then	ename	end)	AS	mgrsf
COUNT(case	when	job =丨	丨PRESIDENT,	1 then	ename	：end)	AS	prez.
COUNT(case	when	job =丨	rANALYST*	then	ename	end)	AS	anals,
COUNT(case	when	job ='	'SALESMAN 1	then	ename	end)	AS	sales
FROM emp;
我们尝试用PIOVT来改写，看会出现什么问题。 原始PIOVT语句如下：
• 205 •
Oracle查询优化改写技巧与案例
SELECT ★
FROM (SELECT ename, ename AS ename2, deptno, job FROM emp) pivot(COUNT(ename) FOR deptno IN (10 AS deptno_10,
20 AS deptno一20,
30 AS deptno_30)) pivot(COUNT(ename2) FOR job IN(’CLERK1 AS clerks,
'MANAGER' AS mgrs,
'PRESIDENT' AS prez,
'ANALYST' AS anals,
1 SALESMAN' AS sales))
ORDER BY 1;
I DEPTNOJO	DEPTNO—20	DEPTNO—30	CLERKS	MGRS	PREZ	ANALS	SALES |
0	0	1	1	1	0	0	4
0	1	0	2	1	0	2	0
1	0	0	1	1	1	0	0
可以看到数据，与case when的结果不一致。 下面改为嵌套的方式来分析。 嵌套示例第一步：
WITH xO AS(
SELECT *
FROM (SELECT ename, ename AS ename2, deptno, job FROM emp) pivot(COUNT(ename) FOR deptno IN(10 AS deptno_10,
20 AS deptno_20,
30 AS deptno_30))
SELECT * FROM xO;
ENAME2	JOB	DEPTNOJO	DEPTNG^20	DEPTNO_30
WARD	SALESMAN	0	0	1
SMITH	CLERK	0	1	0
CLARK	MANAGER	1	0	0
TURNER	SALESMAN	0	0	1
JAMES	CLERK	0	0	1
JONES	MANAGER	0	1	0
MARTIN	SALESMAN	0	0	1
• 206 •
第11章报表和数据仓库运算
续表
I ENAME2	JOB	DEPTNOJO	DEPTNO一20	DEPTNO_30 |
ADAMS	CLERK	0	1	0
SCOTT	ANALYST	0	i	0
KING	PRESIDENT	1	0	0
FORD	ANALYST	0	I	0
ALLEN	SALESMAN	0	0	1
BLAKE	MANAGER	0	0	1
MJLLER	CLERK	1	0	0
第一步相当于 group by empno2,jobo
嵌套示例第二步：
WITH xO AS(
SELECT *
FROM (SELECT ename	,ename AS ename2, <	deptno, job FROM emp)
pivot(COUNT(ename)	FOR deptno IN(10 AS	deptno 10,
	20 AS deptno	一20,
	30 AS deptno	_30))
) SELECT * FROM xO
pivot(COUNT(ename2)	FOR job IN(* CLERK1	AS clerks,
	'MANAGER1 AS mgrs,
	'PRESIDENT' AS	prez,
	'ANALYST* AS anals.
	1 SALESMAN 1 AS	sales))
ORDER BY 1;
DEPTNOJO	DEPTNO_20	DEPTNQ_30	CLERKS	MGRS	PREZ	ANALS	SALES
0	0	I	1	1	0	0	4
0	1	0	2	1	0	2	0
1	0	0	1	1	1	0	0
因第一步返回的列为(ENAME2, JOB, DEPTNOJO, DEPTNO—20，DEPTN!0_30)去 掉(ENAME2, JOB)后，剩余的是(DEPTNOJO, DEPTNO_20, DEPTNO—30)。所以第二 步相当于 group by deptno—丨0，deptno—20,deptno_30。
• 207 •
Oracle查询优化改写技巧4案例
11.13对不同组/分区同时实现聚集
本例要求在员工表的明细数据里列出员工所在部门及职位的人数，要求结果如下:
KING	10	3	PRESIDENT	1	8
CLARK	10	3	MANAGER	2	8
MILLER	10	3	CLERK	3	8
JONES	20	5	MANAGER	2	B
SMITH	20	5	CLERK	3	8
FORD	20	5	ANALYST	2	8
SCOTT	20	5	ANALYST	2	8
ADAMS	20	5	CLERK	3	8
没用分析函数前，这种需求要用自关联:
SELECT e. ename 姓名,
e.deptno 部门r
s_d.cnt AS部门人数，
e.job AS 职位，
s_j . cnt AS职位人数，
(SELECT COUNT(*) AS cnt FROM	emp	WHERE deptno IN (10, 20)) AS 总
人数
FROM emp e
INNER JOIN (SELECT deptno, COUNT(★)	AS	cnt FROM emp WHERE deptno IN (10,
20) GROUP BY deptno) s_d
ON (s d.deptno = e.deptno)
INNER JOIN (SELECT job, COUNT (*) AS	cnt FROM emp WHERE deptno IN (10, 20)
GROUP BY job) s_j
ON (s_j.j ob = e.job)
WHERE e.deptno IN (10, 20);
这种写法比较复杂，而且要对表emp访问四次。
• 208 •
第11章报表和数据仓库运算
A-Rqws | A-TUte
i E-Rows
1 8 4 3 .3 s 3' 03 3 8 8
.3 1
Buffers |
• • • • 21. '7
.21 14
4	.7
,• •
Operation
SELECT. STATEMENT ' •SORT AGGREGATE . / TABLE ACCESS FULL :HASH JOIN
HASH*JOIN .
TABLE ACCESSt?ULL .
-HASH GROUP BY • '•TABLE ACCESS FULL VIEW HASH GROUP BY TABLE ACCESS FULL
如果改用分析函数，语句就较简单，扫描表的次数也少。
SELECT ename 姓名， deptno 部门，
COUNT (*) over (PARTITION BY deptno) AS 部门人数, job AS职位，
COUNT (” over (PARTITION BY job) AS 职位人数， COUNT (*) over () AS 总人数 FROM emp WHERE deptno IN (10, 20);
当遇到这种多次访问同一个表的情况时，可以看一下能否用分析函数改写，以及改写 后的效率如何。当然最重要的一点是：别忘了核对数据。
11.14对移动范围的值进行聚集
本例要求在员工明细表中显示之前90天（包含％)以内聘用人员的工资总和，我们 以部门30为例，下面是标量及分析函数两种方式的示例及解释。
SELECT hiredate AS 聘用曰期， sal AS工资，
SELECT STATEMENT WINDOW SORT WINDOW SORT' , TABLE ACCESS' FULL
A-Rows
Scarts
.Operation
09-0 000000000 ••«•»•••••»«• 00-0 000 0 00 0 00 000000000000 •««••• ».*•_•«- •• •••_
OOQOOOOOOOOO 00 0:0 00.0 00000
oo'ODo..oocaoo-oo OOQOOOOOOOOO n n ftl fl n at, 1 ftl I I#
| OO lOOiOO .01 100:00:00.01 100:00:00.01 i 00 ： QO : 00 ."oi
• 209 •
Oracle査询伏.化改写技巧4案例
(SELECT SUM(b.sal) FROM emp b WHERE b.deptno =30	AND b.hiredate	<=
-■.hi;	AND b. hiredate >= e .hiredate - 90) AS 标量求值，
1	(1	| | to char (hiredate -	90,	' yy-mm-dd *)	丨丨 1 到1	I |
•)聘用人员工资和1 AS需求，
hiredate RANGE BETWEEN 90 preceding
to」.:har【lv: redate, 1 yy-mm-dd*)	|	|
SUM(sal) over(ORDER BY CJRPKNT ROW) AS分析函数求值，
(SELECT listagg(b.sal,	1+') within GROUP(ORDER BY b.hiredate)
FROM emp b WHERE b.deptno = 30 AND b.hiredate <= e AND b.hiredate >= e
FROM emp e WHERE deptno =30
(RDER BY 1;
AND
.hiredate
.hiredate
90) AS模拟公式
mm	..工资	标量求值	需求	分析函数求值	模拟公式
1981-02-20	1600	1600	(80-11-22到81-02-20)聘用人员工资和	1600	1600
1981-02-22	1250	2850	(80-11-24到8丨-02-22)聘用人员工资和	2850	1600+1250
1981-05-01	2850	5700	(81-01-31到81-05-0丨)聘用人员工资和	5700	1600+1250+2850
1981-09-08	1500	1500	(81-06-10到81-09-08)聘用人员工资和	1500	1500
1981-09-28	1250	2750	(81-06-30到8卜09-28)聘用人员工资和	2750	1500+1250
1981-12-03	950	3700	(81-09-04到81-12-03)聘用人员工资和	3700	1500+1250+950
闲用RANGE关键字表示要对相应的字段做加减运算，所以只有对日期与数值两类字 段使用RANGE开窗。 对T•日期RANGE幵窗，默认单位是“天”，如果需求改为三个月内的数据呢？我们 nj以INTERVAL来写明间隔单位：
SELECT hiredate AS 聘用日期， sal AS工资，
SUM(sal) over(ORDER BY hiredate RANGE BETWEEN INTERVAL '3' MONTH
preceding AND CURRENT ROW) AS ■£月合计
FROM emp e WHERE deptno = 30 ORDER BY 1;
• 210 •
第11章报表和数据仓库运算
聘用日期	工资	仨月合计
1981-02-20	1600	1600
1981-02-22	1250	2850
1981-05-01	2850	5700
1981-09-08	1500	1500
1981-09-28	1250	2750
1981-12-03	950	3700
如果按分钟开窗呢？
DROP TABLE TEST PURGE;
CREATE TABLE TEST AS
SELECT 1 AS cl, trunc(SYSDATE) + LEVEL / 24 / 60 AS dl FROM dual CONNECT BY LEVEL <= 5；
SQL> select * from test;
Cl Dl
1	2013-08-05	00:01:00
1	2013-08-05	00:02:00
1	2013-08-05	00:03:00
1	2013-08-05	00:04:00
1	2013-08-05	00:05:00
5	rows selected 用1/24/60或INTERVAL'丨’minute都可以，当然后一种更直观。
SELECT cl, dl,
SUM(cl) over(ORDER BY dl RANGE BETWEEN 2/24/60 preceding AND CURRENT ROW) AS si,
SUM(cl) over(ORDER BY dl RANGE BETWEEN(INTERVAL *2' minute) preceding AND CURRENT ROW) AS s2 FROM test;
• 211 •
Oracle查询优化改写技巧l:i案例
C1 01		S1	S2 |
1	2013-08-05 00:01:00	1	1
1	2013-08-05 00:02:00	2	2
1	2013-08-05 00:03:00	3	3
1	2013-08-05 00:04:00	3	3
1	2013-08-05 00:05:00	3	3
11.15	常用分析函数开窗讲解
本节汇总演示分析函数常见的几种用法及区别。 ①工资排序后取第一行到当前行范围内的最小值。
SELECT ename, sal,
/*因是按工资排序，所以这个语句返回的结果就是所有行的最小值*/
MIN(sal) over(ORDER BY sal) AS min一11,
/*上述语句默认参数如下，plan中可以看到*7
MIN(sal) over(ORDER BY sal RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS min_12,
/*这种情况卡，rows与RANGE返回数据一样V
MIN(sal) over(ORDER BY sal rows BETWEEN unbounded preceding AND CURRENT ROW) AS min一13,
/*取所有行G最小值，可以与前面返回的值对比查看*/
MIN(sal) over() AS min—14,
/*如果明确写出上面min_14如范围就是*/
MIN(sal) over(ORDER BY sal RANGE BETWEEN unbounded preceding AND unbounded following) AS min_15,
/*这种情况下，rows SRANGE返回数据一样*/
MIN(sal) over(ORDER BY sal rows BETWEEN unbounded preceding AND unbounded following) AS min_16 FROM emp WHERE deptno = 30;
• 212 •
第11章报表和数据仓库运算
JAMES	950	950	950	950	950 .	950	950
WARD	1250	950	950	950	950	950	950
MARTIN	1250	950	950	950	950	950	950
TURNER	1500	950	950	950	950	950	950
ALLEN	1600	950	950	950	950	950	950
BLAKE	2850	950	950	950	950	950	950
②工资排序后取第一行到当前行范围内的最大值。
SELECT ename, sal,
/★因按工资排序，所以这个语句与上面sal返回的值一样*/
MAX(sal) over(ORDER BY sal) AS max_ll,
/★上述语句默认参数如下，plan中可以看到
MAX(sal) over(ORDER BY sal RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS max_12,
/★这种情况下rows与RANGE返回数据一样*/
MAX(sal) over(ORDER BY sal rows BETWEEN unbounded preceding AND CURRENT ROW) AS max_13,
/★取所有行品内最大值，可以与前面返回的值对比查看*/
MAX(sal) over() AS max_l4,
/*如果明确写出上面max_14的范围就是*/
MAX(sal) over(ORDER BY sal RANGE BETWEEN unbounded preceding AND unbounded following) AS max_l5,
/*这种情况下，rows 4range返回数据一样*/
MAX(sal) over(ORDER BY sal rows BETWEEN unbounded preceding AND unbounded following) AS max—16 FROM emp WHERE deptno = 30;
]ENAME	SAL	MAX—11		MAX」2	MAX」3	MAX—14	MAX_15	MAX—16 I
JAMES	950	950		950	950	2850	2850	2850
WARD	1250	1250		1250	1250	2850	2850	2850
MARTIN	1250	1250		1250	1250	2850	2850	2850
TURNER	1500	1500		1500	1500	2850	2850	2850
• 213 •
Oracle查询优化改写技巧与案例
续表
；ENAME	SAL	MAX—11	MAX一 12	MAX一 13	MAX一 14	MAX—15	MAX一16
ALLEN	1600	1600	1600	1600	2850	2850	2850
BLAKE	2850	2850	2850	2850	2850	2850	2850
③工资排序后取第一行到当前行范围内的工资和，这里要注意区别。
SELECT ename, sal,
/*累加工资，要注意工资重复时的现象*/
SUM(sal) over(ORDER BY sal) AS sum_ll,
/*上述语句默认参数如下，在plan中可以看ilj*/
SUM(sal) over(ORDER BY sal RANGE BETWEEN unbounded preceding AND CURRENT ROW) AS sum_12,
/*这种情况〒，rows与RANGE返回数据不一样，见第二行*/
SUM(sal) over(ORDER BY sal rows BETWEEN unbounded preceding AND CURRENT ROW) AS sum_13,
/*工资合计*/
SUM(sal) over() AS sum_14,
/*如果明确写出上面sum一 14如范围就是★/
SUM(sal) over(ORDER BY sal RANGE BETWEEN unbounded preceding AND unbounded following) AS sum—15,
/★这种情况下，rows Grange返回数据一样*/
SUM(sal) over(ORDER BY sal rows BETWEEN unbounded preceding AND unbounded following) AS sum—16 FROM emp WHERE deptno = 30;
ENAME	SAL	SUMj11	SUMJ2	SUMJ3	SUM 14 ..• ：	SUM—15	SUM-16
JAMES	950	950	950	950	9400	9400	9400
WARD	1250	3450	3450	2200	9400	9400	9400
MARTIN	1250	3450	3450	3450	9400	9400 _	9400
TURNER	1500	4950	4950	4950	9400	9400	9400
ALLEN	1600	6550	6550	6550	9400	9400	9400
BLAKE	2850	9400	9400	9400	9400	9400	9400
因为使用关键字“RANGE”时，第二行“SLJM_11”、“SUM_12”对应的条件是“<= 1250”，
• 214 •
第11章报表和数r
而1250有两个，所以会计算两次，产生结果为：950+1250+1250=3450。而“SUM 13" 不同，它只计算到当前行，所以结果是950+1250=2200。 ④前后都有限定条件。
SELECT ENAME,
SAL,
/*当前行（ + -1500)范围内的最大值*/
MAX (sal) over (ORDER BY sal RANGE BETWEEN 500 preceding At,JL_ 0' FOLLOWING) AS max_l1,
/*前后各二行，共三行中的最大值*/
MAX(SAL) OVER(ORDER BY SAL ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
AS max_12
FROM emp WHERE deptno = 30;
, ENAME	SAL	MAX 一 11	MAX \2
JAMES	950	1250	1250
WARD	1250	1600	1250
MARTIN	1250	1600	1500
TURNER	1500	1600	1600
ALLEN	1600	1600	2850
BLAKE	2850	2850	2850
11.16	listagg与小九九
我们知道，listagg与sum类似。下面可以用listagg的分类汇总功能来实现小九九的 一个展示。 首先要生成基础数据。
WITH 1 AS
(SELECT LEVEL AS lv FROM dual CONNECT BY LEVEL <= 9)
SELECT a.lv AS lv_a,
b.lv AS lv_b,	•
to_char (b. lv) | | 1 X • | | to_char (a. lv) | | ' = 1 | | rpad (to_'-i：ar ( .. I v * b.lv), 2,	•	') AS text
• 215 •
Oracle查询优化改写技巧4案例
9x9
-► 16 5- 4 & 8 468=11111 f U II H II H II II 2 3 4 5 67:8:9.
X X K X X X X X 2 2 2 2 2 2 2 2
FROM 1 a, 1 b WHERE b.lv <= a.lv;
LV A
LV B
TEXT
1	1	1	X	1		1
2	1	1	X	2		2
2	2	2	X	2		4
3	1	1	X	3	=	3
3	2	2	X	3	=	6
3	3	3	X	3	=	9
9	6	6	X	9	r=	54
9	7	7	X	9	=	63
9	8	8	X	9	=	72
9	9	9	X	9	=	81
45 rows selected
我们通过条件b.lv <= a.lv生成了一个穷举数据。然后用listagg分类汇总，把LV_A 相同的数据合并为一行：
WITH 1 AS
(SELECT LEVEL AS lv FROM dual CONNECT BY LEVEL <= 9)• m AS
(SELECT a.lv AS lv_a, b.lv AS lv_b,
to_char{b.lv) ||	'	X ，	|I
rpad(to_char(a.lv * b.lv), 2,	'	') AS text
FROM 1 a, 1 b WHERE b.lv <= a.lv)
SELECT listagg(m.text, 1 FROM m GROUP BY m.lv a;
to char(a.lv) ||
I I
within GROUP (ORDER BY m.lv b) AS 4、九九
9 63 4 5 6 __ II '78 .9
X XX
7 7 7
36424854 II H U II 6- 7 8 9
X,:', X X X 6 6 6 6
5 0 5 0 5 2 3 3 4 4
IIsU II:■==
s 6 7 8 9
X X X. XK'
5 5 5 5 5
162024283236
II u u ' u .==u. 4 5 & 7 6 9
X X X KXX
4 4 4 4 4 4
2 5 8 14 7. -y121 1. 2 2 2
I- -I I- * a r ij
3 4 <5.67'8 9 xxxxxxk 3 3 3 3 3 3 3
4
5
6
7
8 9
vl:l 2 3 4 5 6-
-X X XX X X 法 1 1X111-
x 8 x 9
• 216 •
第12章
分层查询
1Z1	简单的树形查询
我们经常会用一些表来保存上下级关系，如地区表、员工表、组织机构表等，为了按 上下级关系递归查询这些数据，就需要用到树形查询，下面以emp表为例。
SELECT empno AS 员工编码， ename AS 姓名， mgr AS主管编码，
(PRIOR ename) AS 主管姓名 FROM emp START WITH empno = 7566 CONNECT BY (PRIOR empno) - mgr;
Oracle查询优化改写技巧与案俠J
我们来分析一下这个语句。
①起点：这个语句以“START W丨TH empno = 7566”为起点向下递归查询。
②通过操作符“PRIOR”可以取得上一级的信息，如上面查询中的主管姓名(PRIOR ename) o
③CONNECT	BY子句列出来递归的条件（上一级的编码）等于本级的主管编码。 我们来看这个过程，以7566为起点，向下一级就是（7788,7902)。
SI翩」	齡 」主雜名一
7566,	JONES	7839
77舣 ^rraT		，參7«566	JONES

7876	ADAMS、 .	S. 7788 …-	SCOTT
7902	驀 nf?n	^7566	JONES
7369 SMITH		7902	FORD
7788的下一级是7876, 7902的下一级是7369。至此，递归查找完成。
	si綱」姓名 」雜綱名」
1	7566	JONES	7839
2	7788,	^COTT 7566		JONES
3	7876			SCOTT
4	7902	^QRD_ 7566		JONES
5	7369			1^7902	FORD
12.2根节点、分支节点、叶子节点
在树形查询中常用的有两个伪列：level与connect一by_isleaf。level返回当前行所在的 等级，根节点为1级，其下为2级……
如果当前节点下没有其他的节点，则connect 一 by—isleaf返回〗，否则返回0。这样就 可以通过level与connect_by—isleaf来判断标识“根节点、分支节点与叶子节点”。
SELECT lpad( , (LEVEL - 1) * 2,	)	|	|	empno	AS	员工编码，
• 218 •
第12章分层查询
ename AS 姓名， mgr AS主管编码，
LEVEL AS 级别，
decode (LEVEL, lf 1) AS 根节点，
decode (connect_by_isleaf, 1, 1) AS 叶子节点r
CASE
WHEN (connect_by_isleaf = 0 AND LEVEL > 1) THEN
1
END AS分支节点 FROM emp START WITH empno = 7566 CONNECT BY (PRIOR empno) = mgr;
员工编码		姓 名 主管编码 级 1] 根节点 卩f子节点 分支节点
7566	JONES		7839	1	1
-7788	SCOTT		7566	2			1
一7876	ADAMS		7788	3		1
-7902	FORD		7566	2			1
一一7369	SMITH		7902	3		1
12.3	sys_connect_by_path
当数据级别比较多时，不容易看清根节点到当前节点的路径，这时就可用 sys connect by path函数把这些信息展示出来：
SELECT empno AS 员工编码， ename AS 姓名， mgr AS主管编码，
sys_connect_by_path(ename, 1,') AS enames FROM emp START WITH empno = 7566 CONNECT BY (PRIOR empno) = mgr;
• 219 •
Oracle查询优化改写技巧案例
员工编码	姓名	主管编码	ENAMES
7566	JONES	7839	JONES
7788	SCOTT	7566	,JONES,SCOTT
7876	ADAMS	7788	，JONES，SCOTT,ADAMS
7902	FORD	7566	,JONES,FORD
7369	SMITH	7902	，JONES，FORD,SMITH
前面介绍过用分析函数listagg来合并字符串，然而Oracle 11.2之前的版本没有listagg 怎么办？其实可以借助树形查询中的sys一connect_by_path函数：
WITH xl AS / * 1.分组生成序号rn* /
(SELECT deptno, ename,
row_number() over(PARTITION BY deptno ORDER BY ename) AS rn FROM emp)
/★2.用 sys_connect_by_path 合并字符串*/
SELECT deptno, sys_connect_by_path(ename, ，，*> AS emps FROM xl WHERE connect_by_isleaf = 1 START WITH rn = 1 CONNECT BY (PRIOR deptno) = deptno
DEPTNO EMPS
10	,CLARK,KING,MILLER 20 ,ADAMS,FORD,JONES,SCOTT,SMITH 30 ,ALLEN,BLAKE,JAMES,MARTIN,TURNER,WARD
3	rows selected
这种方法的要点是分组生成序号，然后通过序号递归循环。注意：要过滤多余的数据 时，只需要加条件“WHERE connect_by—isleaf= 1”来取叶子节点就可以。
12.4	树形查询中的排序
如果树形查询里直接使用ORDER BY排序会怎样？看下面的示例:
第12章分层查询
SELECT lpad('-1, (LEVEL -	1) ★ 2, »-	*) | | empno AS员工编码，
ename AS 姓名，
mgr AS主管编码
FROM emp
START WITH empno = 7566
CONNECT BY (PRIOR empno):	=mgr
ORDER BY empno DESC;
员工编码	姓名	主管编码
—7902	FORD	7566
————7 876	ADAMS	7788
—7788	SCOTT	7566
7566	JONES	7839
	7369	SMITH	7902
5 rows selected
可以看到，数据都乱了，无法再看清上下级关系，而对于树形数据，我们需要的应该 是只对同一分支下的数据排序，此时就要用到专用关键字“SIBLINGS”：
SELECT lpad(1 -', (LEVEL	-1) * 2f	'-*) I	I empno AS员工编码，
ename AS 姓名，
mgr AS主管编码
FROM emp
START WITH empno = 7566
CONNECT BY (PRIOR empno)	=mgr
ORDER SIBLINGS BY empno	DESC;
1	j/566		JONES 7833.
2	4	7902	FORD (7566])
3		—7369	SMITH
4	I	7788	SCOTT ^66J
5	-—7876		ADAMS 7^8
可以看到，这个语句只对同一分支（7566)下的（7902, 7788)进行排序，而没有影 响到树形结构。
12.5	树形查询中的WHERE
如果限定只对部门20的人员进行树形查询，怎么做呢？估计很多人会直接在WHERE
• 221 •
Oracle查询优化改写技巧-S/案例
后加条件如下：
SELECT empno AS 员工编码， mgr AS主管编码， ename AS 姓名， deptno AS部门编码 FROM emp WHERE deptno =20 START WITH mgr IS NULL CONNECT BY (PRIOR empno) = mgr;
员工编码	主管编码	姓名	部门编码 i
7566	7839	JONES	20
7788	7566	SCOTT	20
7876	7788	ADAMS	20
7902	7566	FORD	20
7369	7902	SMITH	20
这个结果明显不对，因为部门20不存在mgr为空的数据，那么也就不该返回数据。 可以与下列语句的结果对比。
SELECT empno AS 员工编码， mgr AS经理编码， ename AS 姓名， deptno AS部门编码 FROM (SELECT * FROM emp WHERE deptno = 20) emp START WITH mgr IS NULL CONNECT BY (PRIOR empno) = mgr;
未选定行
这个语句没有返回数据。原因在于树形查询中的WHERE过滤的对象是树形查询的结 果。所以要谨记，如果要先过滤，再进行树形查询，则要用子查询嵌套一次。
12.6 查询树形的一个分支
查询树形的一个分支不能用WHERE,用START WITH指定分支的起点就可以。如査
第12章分层査询
询员工编码为7698及其下级所有的员工。
SELECT empno AS员工编码，mgr AS主管编码，ename AS姓名，LEVEL AS级别 FROM emp	、
START WITH empno = 7698 CONNECT BY (PRIOR empno) = mgr;
员工编码.	主管编码		姓名 级		别
7698	7839	BLAKE		1
7499	7698	ALLEN		2
7521	7698	WARD		2
■ 7654	7698	MARTIN		2
7844	7698	TURNER		2
7900	7698	JAMES		2
1Z7	剪去一个分支
接上面的示例，本例要求剪去7698开始的这个分支。同样，剪去分支也不能在WHERE 中加条件，因为树形查询递归是根据条件(PRIOR empno) = mgr进行的，所以在下列语句 加条件就可以。
SELECT empno AS员工编码，mgr AS主管编码，ename AS姓名，LEVEL AS级别 FROM emp START WITH mgr IS NULL CONNECT BY (PRIOR empno) = mgr /*剪去分支*/
AND empno != 7698;
员工编码
主管编码
7839		KING	1
7566	7839	JONES	2
7788	7566	SCOTT	3
7876	7788	ADAMS	4
7902	7566	FORD	3
• 223 •
Oracle查询优化改写技巧与案例
续表
员工编码	主管编码	姓 名	级 SH I
7369	7902	SMITH	4
7782	7839	CLARK	2
7934	7782	MILLER	3
1Z8 字段内list值去重
本例要求数据字段内的List值去重。测试数据如下：
CREATE OR REPLACE VIEW v AS
SELECT 1 AS id, •ab,b,c,ab,d,e• AS al FROM dual UNION ALL
SELECT 2 AS id, •11,2,3,4,11,2' FROM dual;
上述语句中，用逗号分隔的各值有重复，现要求其中的重复值只保留一个即可，这种 需求首先要把字符串拆分为多行，再去重。 如果只有一行，拆分很简单：
CREATE OR REPLACE VIEW v2 AS
SELECT 1 AS id, •ab,b,c,ab,d,e1 AS al FROM dual;
SELECT regexp_substr(al,	'	[A,] + ', 1, LEVEL) AS a2
FROM v2
CONNECT BY LEVEL <= regexp—count(al,	1,') + 1;
A2
ab
b
c
ab
d
e
6 rows selected
如果有多行，那么这个语句就有问题了:
SELECT COUNT(*)
• 224 •
第12章分层查询
FROM (SELECT regexp—substr(al,'	1/	LEVEL) AS a2
FROM v
CONNECT BY LEVEL <= regexp_	count(alr	M) + 1);
COUNT(*)
126
1 row selected
拆分后应该是12行，而不是126,显然这是错误的。 有兴趣的读者可以通过下面这个语句观察结果。
SELECT b.*, power(4, lv - 1) AS pw FROM (SELECT LEVEL AS lv, alf
length(al) AS 1,
sys_connect_by_path(id, •一*) AS p,
COUNT(*) over(PARTITION BY al, LEVEL) AS ct FROM v
CONNECT BY LEVEL <= regexp_count(al,	1r1) + 1) b
ORDER BY 2, 1;
下面只显示了部分结果:
1	11,2. 3,4, 11,2	13	->2	1	1
2	11.2. 3, 4.11.2	13	一>1->2	2	4
2	11,2, 3.4. 11.2	13	->2->2	2	4
3	11.2,3,4.11.2	13	->1->2->2	4	16
由这些结果可以看出，树形跨行在ID=1与ID=2之间产生了上下级关系。所以需要加 一个限制：只能在本行循环拆分。
SELECT regexp_substr (al,	•[、]	+	•,	1,	LEVEL)	AS	a2
FROM v
CONNECT BY (LEVEL <= regexp_count(al, ，，'> +1 AND (PRIOR id) = id); QRA-01436: CONNECT BY loop in user data
这个提示是误报，实际上，上面的语句并不存在死循环，所以只需要想法骗过Oracle 就可以，为此增加条件“（PRIOR dbms—random.value()) IS NOT NULL”语句改为如下：
• 225 •
Oracle查询优化改写技巧案例
SELECT COUNT(★)
FROM (SELECT al,
LEVEL AS lv,
regexp_substr(al, 1[A/]+*/ 1, LEVEL) AS a2,
| regexp一substr (，" | I al I I , • ,, 1，[A, ] + •、1, 1 II LEVEL
')'AS fun
FROM v
CONNECT BY nocycle(LEVEL <= regexp—count(al, ',1) +1 AND (PRIOR id) = id
AND (PRIOR dbms_random.value()) IS NOT NULL));
COUNT(★)
12
拆分成功后，后面的操作就很简单了，去重后直接用listagg合并字符串就可以:
WITH v2 AS (SELECT al,
LEVEL AS lv,
regexp_substr(alf *[々,]+■, 1, LEVEL) AS a2,
'regexp_substr (• • ,	| | al | |	•••,，•「，]	+	••, 1, • II LEVEL I I
AS fun
FROM v
CONNECT BY nocycle(LEVEL <= regexp—count(al, 1f 1) +1 AND (PRIOR id) = id
AND (PRIOR dbms_random.valueO> IS NOT NULL))
SELECT v3.al AS old_al,
listagg(v3.a2,	'f') within GROUP(ORDER BY v3.a2) AS new一al
FROM (SELECT al, a2 FROM v2 GROUP BY al, a2) v3 GROUP BY v3.al ORDER BY 1;
OLD一A1	NEW—A1
11’2,3,4，U，2	1U,3,4
ab，b,c,ab，d,e	ab,b,c,d,e
• 226 •
^ '梦	第13章
应用案例实现
13.1	从不固定位置提取字符串的元素
测试数据如下：
CREATE OR REPLACE VIEW v AS
SELECT 1xxxxxabc[867]xxx[-]xxxx[5309]xxxxx * msg FROM dual UNION ALL SELECT 1xxxxxtime:[11271978]favnum:[4]id:[Joe]xxxxx' msg FROM dual UNION
ALL
SELECT 'call: [F一GET一ROWS(>]bl: [ROSEWOOD …SIR]b2: [44400002J 77.90xxxxx1 msg FROM dual UNION ALL
SELECT 'film:[non_marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx' msg FROM dual;
• 227 •
Oracle查询优化改写技巧与案例
要求取出方括号中对应的字符串，分三列显示。 这里的分隔符是两个：与“]”，按前面章节讲述的方法，语句可以写为:
SELECT regexp_substr (v.msg, * [A] [ ] + ' / 1 / 2)第一个串， regexp_substr (v .msg,，[八][] + *, 1, 4)第二个串， regexp_substr (v.msg, U[] + *, 1, 6)第三个串， msg FROM v;
1 第一个串	第二个串	第三个串	MSG I
867	-	5309	xxxxxabc[867]xxx[-]xxxx[5309]xxxxx
11271978	4	Joe	xxxxxtime:[11271978Jfavnum:[4Jid：lJoe]xxxxx
F_GET_ROWS()	ROSEWOOD...SIR	44400002	call：rF_GET_ROWS()]bl:[ROSEW(X)D...SIR]b2:[44400002]77.90xxxxx
nonmarked	unit	withabanana?	film:[non marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx
如果增加一行下面这种数据呢？
CREATE OR REPLACE VIEW v AS
SELECT ixxxxxabc[867]xxx[-]xxxx[5309]xxxxx丨 msg FROM dual UNION ALL SELECT 1xxxxxtime:[11271978]favnum:[4]id:[Joe]xxxxx* msg FROM dual UNION
ALL
SELECT •call:[F_GET_ROWS()]bl:[ROSEWOOD …SIR]b2:[44400002]77•90xxxxx， msg FROM dual UNION ALL
SELECT 'film:[non_marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx' msg FROM dual UNION ALL
SELECT ' [一] [二][三]1 msg FROM dual;
字符串“[一][二][三]”是符合题意需求的，但我们的语句就有问题了，这时结果如下:
I 第一个串.	第二个串	第三个串	MSG 1
867	-	5309	xxxxxabc[867]xxx[-]xxxx[5309]xxxxx
11271978	4	Joe	xxxxxtime:[11271978]favnum:[4]id:[Joe]xxxxx
F_GET一 ROWS()	ROSEWOOD …SIR	44400002	caII:[F_GET_ROWS0]bl；rROSEWOOD...SIR]b2:[44400002]77.90xxxx X
nonmarked	unit	withabanana?	film:[non_marked]qq:[unit]tailpipe:[wilhabanana?]80sxxxxx
二			[一][二][三]
显然，因为两个方括号中间缺少数据，使我们的定位出现了偏差。
• 228 •
第13章应用案例实现
如何更准确地定位呢？我们可以把包括方括号的数据一起取出，然后去掉方括号。
含中括号:
SELECT regexp substr(v.msg,	'(\[)([A]]+)1	,1, 1)第一个串，
regexp_substr(v.msg, 1	丨(\[)([A]]+)	1, 2)第二个串，
regexp_substr(v.msg,丨	'(\[)(["]]+)	1, 3)第三个串，
msg
FROM v;
' 第一个串	第二个串	第三个串	MSG
[867	[-	[5309	xxxxxabc[867]xxx[-]xxxx[5309]xxxxx
[11271978	[4	[Joe	xxxxxtime:[l 1271978]favnum:[4]id:[Joe]xxxxx
[F_GET_ROWS()	[ROSEWOOD... SIR	[44400002	caIl:[F_GET_ROWS()]bl:[ROSEWOOD...SIRlb2:[44400002]77 .90xxxxx
[non一 marked	[unit	[withabanana?	film:[non marked]qq:[unit]tailpipe:[withabanana?]80sxxxxx
卜	[二	[三	[1 二][三】
这里“(\[)”中的斜杠是转义字符，“\丨”放在括号里是为了便于区分和理解。 “([A]]+)”就是用“]”作为分隔符的一个正则表达式，同样，“鬥]+”放在括号里是为
了便于区分和理解。 去掉方括号：
SELECT Itrim(regexp一substr(v.msg.	1 (\[) <r]]+) *	,i, i),	■ [■>第一个串，
ltrim(regexp substr(v.msg,,	丨(\[)([A]]+)、	1, 2),	_[•)第二个串，
ltrim(regexp_substr(v.msg,,	丨(\i) <[A]]十）•，	If 3) r	• [•)第三个串，
msg
FROM v;
1 第一个串	第二个串	第三个串	MSG I
867	-	5309	xxxxxabc[867]xxx[-]xxxx[5309]xxxxx
11271978	4	Joe	xxxxxtime:[l 1271978]favnum:[4]id:[Joe]xxxxx
F_GET_ROWS()	ROSEWOOD...SIR	44400002	caIl:[F_GET_ROWSQ]b1:[ROSEWOOD...SIR]b2:[44400002] 77.90xxxxx
nonmarked	unit	withabanana?	film:[non_markedjqq:[unit]tailpipe:[withabanana?]80sxxxxx
—	二	三	[—][二][三]
• 229 •
Oracle查询优化改写技巧与案例
13.2 搜索字母数字混合的字符串
现有如下数据：
CREATE OR REPLACE VIEW v AS
SELECT 'ClassSummary' strings FROM dual UNION ALL SELECT *3453430278* FROM dual UNION ALL SELECT 'findRow 55' FROM dual UNION ALL SELECT *1010 switch* FROM dual UNION ALL SELECT *333' FROM dual UNION ALL SELECT 'threes' FROM dual;
要求返回其中既包含字母，又包含数字的行。
那么只要其中有“字母在前，数字在后”或“数字在前，字母在后”的数据均可。
SELECT strings FROM v
WHERE regexp—like(v.strings, '([a-zA-Z].*[0-9]丨[0-9]•*[a-zA-Z])，）； STRINGS
findRow 55 1010 switch 2 rows selected
这里用到的“丨”是“或者”的意思。
13.3把结果分级并转为列
本例要求把emp中的结果按工资分级，其中最高的三档作为一列、次高的三档作为一 列、其余的作为一列，显示为如下所示的数据。
最高三档	次高三裆	其余档次
KING (5000)	BLAKE (2850)	TURNER (1500)
FORD (3000)	CLARK (2450)	MILLER (1300)
SCOTT (3000)	ALLEN (1600)	MARTIN (1250)
• 230 •
第13章应用案例实现
续表
嚴高三档	次高三档	其余档次
JONES (2975)		WARD (1250)
		ADAMS (1100)
		JAMES (950)
		SMITH (800)
该问题解决思路如下。 ①生成序号。因为数据相同的（3000)排序相同，且不占位置，所以需要用densejank 来生成序号：
WITH x AS (SELECT ename AS 姓名， sal AS工资，
dense_rank () over (ORDER BY sal DESC) AS 档次 FROM emp)
SELECT * FROM x;
姓名	工资	档次
KING	5000	1
FORD	3000	2
SCOTT	30 00	2
JONES	2975	3
BLAKE	2850	4
SMITH	800	12
14 rows	selected
②划分为三列，这可通过CASE WHEN完成：
WITH x AS (SELECT ename AS 姓名， sal AS工资，
dense一rank (> over (ORDER BY sal DESC) AS 档次 FROM emp), y AS (SELECT 姓名，
工资，
• 231 •
Oracle查询优化改写技巧与案例
档次，
CASE WHEN 档次 <=3 THEN 1 WHEN 档次 <=6 THEN 2 ELSE 3 END 列 FROM x)
SELECT * FROM y;
姓名	工资	档次
KING	5000	1	1
FORD	3000	2	1
SCOTT	3000	2	1
JONES	2975	3	1
BLAKE	2850	4	2
SMITH	800	12	3
14 rows	selected
③要对三列数据重新生成序号，这样行转列时才能把序号相同的归为一行:
WITH x AS
(SELECT ename AS 姓名，
sal AS工资，
dense—	rank () over(ORDER BY sal	DESC) AS 档次
FROM emp)r
y AS
(SELECT 姓名，
工资，
档次，
CASE WHEN 档次 <=3 THEN 1 WHEN		档次 <=6 THEN 2 ELSE	3 END 列
FROM x),
z AS
(SELECT 姓名，
工资，
档次，
列，
row_number () over (PARTITION BY 列 ORDER BY 档次，姓名）			AS分组依据
FROM y)
SELECT * FROM	z;
姓名	工资 列	分组依据
KING	5000 1	1
FORD	3000 1	2
• 232 •
第13章应用案例实现
SCOTT	3000	1	3
JONES	2975	1	4
BLAKE	2850	2	1
CLARK	2450	2	2
ALLEN	1600	2	3
TURNER	1500	3	1
MILLER	1300	3	2
SMITH	800	3	7
14 rows	selected
④根据最后生成的“分组”列进行“行转列”即可。
/*!.对数据分档*/
WITH x AS (SELECT ename AS 姓名， sal AS工资，
dense_rank() over (ORDER BY sal DESC) AS 档次 FROM emp),
/*2.根据档次把数据分为三类★/ y AS
(SELECT姓名，工资，档次，
CASE WHEN 档次 <=3 THEN 1 WHEN 档次 <=6 THEN 2 ELSE 3 END 列 FROM x)•
/★3.分别对三列的数据重新取序号，这样相同序号的可以汇总后放在同一行*/
z AS
(SELECT姓名，工资，档次，列，
row—number。over (PARTITION BY 列 ORDER BY 档次，姓名）AS 分组依据 FROM y)
/*4.行转列*/
SELECT MAX (CASE 列 WHEN 1 THEN rpad (姓名，	6) I |	1 (f	丨丨工资丨丨	')• END)	最
高三档，
MAX (CASE 列 WHEN 2 THEN rpad (姓名，	6) I I	'(f 1	1工资丨丨	1 ) * END)	次
级三档，
MAX (CASE 列 WHEN 3 THEN rpad (姓名，	6) I I	r (' 1	1 1工资1 1	，)1 END)	其
余档次
FROM z GROUP BY分组依据 /*注意要排序，否则显示的数据是乱的*/
ORDER BY分组依据；
排序后生成的行号属于隐含信息，而这种隐含信息常用在各种复杂的查询中。对于这 种查询，当你知道需要哪种隐含信息时，你就成功了一半。
• 233 •
Oracle查询优化改写技巧Sf案例
13.4构建基础数据的重要性
为了进一步明确构建基础数据的重要性，我们看一下案例:
CREATE TABLE j1 AS SELECT 1 AS coll FROM dual;
CREATE TABLE j2 AS
SELECT	1 AS coll FROM	dual	UNION ALL
SELECT	2 AS coll FROM	dual;
CREATE	TABLE j3 AS
SELECT	3 AS coll FROM	dual	UNION ALL
SELECT	4 AS coll FROM	dual;
CREATE	TABLE j4 AS
SELECT	1 AS coll FROM	dual	UNION ALL
SELECT	2 AS coll FROM	dual;
SELECT	j1.coll, j2.coll, j3		i.coll, j 4.
FROM	jl
FULL	JOIN j2 ON j2.coll =		j1.coll
FULL	JOIN j3 ON j3.coll =		j1.col1
FULL	JOIN j4 ON j4.coll =		j1•coll;
2
该例的本义是显示四条数据，但因没有构建基础数据，只是简单地做了 FULLJOIN, 使结果出现了意想不到的数据。 这里因数据简单还是显示了结果，而该语句关联的表更多，最后直接报错退出。 对于这种情况，我们增加一张基础表，并且改为LFETJOIN即可：
• 234 •
第13章应用案例实现
CREATE TABLE j0 AS
SELECT	J	AS	colO	FROM	dual	UNION	ALL
SELECT	2	AS	colO	FROM	dual	UNION	ALL
SELECT	3	AS	colO	FROM	dual	UNION	ALL
SELECT	4	AS	colO	FROM	dual;
SELECT jl.coll, j2.coll, j3.coll, j4.coll FROM jO
LEFT	JOIN	jl	ON	jl.	.coll =	=jo.	.colO
LEFT	JOIN	j2	ON	j2_	•coll =	=jO.	.colO
LEFT	JOIN	j3	ON	j3.	.coll =	=jo.	• colO
LEFT	JOIN		ON	j4.	.coll =	=jo.	► colO
ORDER	BY jO.colO,
COL1	COL1	COL1	COL1
1	1		1
	2		2
		3
		4
从第3章可知，使用丨eft join时返回左表中的所有数据，右表只返回相匹配的数据。 所以通过建立基础表jO,并改为left join后，数据正常。
13.5根据传入条件返回不同列中的数据
模拟数据环境如下：
CREATE TABLE area AS
SELECT	|重庆，	AS	市，	1沙坪i贝'	AS	区，	'小龙坎•	AS	镇	FROM	dual	UNION	ALL
SELECT	,重庆,	AS	市，	'沙坪坝•	AS	区，	*磁器口 *	AS	镇	FROM	dual	UNION	ALL
SELECT	•重庆•	AS	市，	'九龙坡*	AS	区，	1杨家坪*	AS	镇	FROM	dual	UNION	ALL
SELECT	,重庆,	AS	市，	•九龙坡*	AS	区，	•谢家湾*	AS	镇	FROM	dua 1 ;
现有以下需求：根据界面中选中的不同参数。比如，当只在界面中选中“重庆”市级 条件时，显示其下的区级单位，而当选中“九龙坡”区级条件时，要显示其下的镇级单位„ 一般在前面的界面中，市级与区级在不同的下拉框中，相应返回的也是不同的变量。 根据这个特点可以用CASE WHEN来对传入参数进行判断：
• 235 •
Oracle查询优化改写技巧与案例
VAR v_市 VARCHAR2(50>;
VAR v—区 VARCHAR2 (50); exec : v_Tff :="; exec : ^_区：='九龙坡’;
SELECT DISTINCT CASE
WHEN :v 区 IS 镇
WHEN :v 市 IS 区
END AS地区名称
FROM area WHERE 市=nvl (:	市)
AND 区=nvl(:v—区，区）；
地区名称
杨家坪
谢家湾
2 rows selected v区
九龙坡 V—市
NOT NULL THEN NOT NULL THEN
exec :v_市：=* 重庆•；
exec : v_E : = * 1;
SELECT DISTINCT CASE
WHEN :	v_E i s	NOT	NULL	THEN
镇
WHEN 1	v一市 IS	NOT	NULL	THEN
区
END AS地区名称
FROM area
WHERE 市=nvl(:v_市,	市）
AND 区=nvl (: v 区，	区）；
地区名称
九龙坡
沙坪坝
• 236 •
第13章应用案例实现
2	rows selected 7_区
V一市
重庆 地区名称 九龙坡 沙坪坝
13.6拆分字符串进行连接
mmam-----------------------
本例语句如下：
CREATE TABLE d一objects AS SELECT * FROM Dba_Objects;
CREATE TABLE testl AS
SELECT to_char(wmsys.wm_concat(object_id)) AS id—1st, owner, object_type FROM d—objects WHERE owner IN (rSCOTT1,	•TEST')
GROUP BY owner, object_type;
上述语句中，testl表的id_lst中存储的是object—id列表，用逗号分隔：
ID_LST	OWNER	OBJECT_TYPE j
88726,88732,88731,88730,88729,88728,88727	TEST	TABLE
88395,88407,88404	SCOTT	VIEW
86892,86894	SCOTT	INDEX
86891,88637,88631,86896,86895,86893	SCOTT	TABLE
现要求显示其对应的表名信息，同样用逗号分隔:
ID_LST	NAME—LST
86891,88637,88631,86896,86895.86893	DEPT，DETAIL，EMP2，SALGRADE，BONUS
86892,86894	PK_DEPT
88395,88407,88404	V 一 ENAME’V
88726,88732,88731,88730,88729,88728,88727	EMP,D_OBJECTS，T500,T100，T10，DEPT
• 237 •
Oracle查询优化改写技巧1守案例
我们可以先把IDJLST拆分，与DBA_OBJECTS关联，取NAME后再把NAME合并
在一起。
因为网友的版本是Oracle 10g,没有LISTAGG函数，所以仍然采用WMSYS.WM_ CONCAT。
WITH a AS
(SELECT id_lst, regexp_substr(id_lst/ •[々，]+•, 1, LEVEL) AS object一id FROM testl CONNECT BY nocycle(PRIOR ROWID) = ROWID
AND LEVEL <= length(regexp_replace(id_lst,	'	[^^] 1 /	"))
AND (PRIOR dbms_random.value) IS NOT NULL)
SELECT a.id__lst, to_char(wmsys.wm_concat(b.object_name)) AS name_lst FROM a
INNER JOIN d_obj ects b ON b.object_id = a.object_id GROUP BY a.id 1st;
说明Oracle 10g不用加to_char(),但因笔者的环境是Oracle llg,所以这里的例句也
加上了。
13^7 整理垃圾数据
本节整理后的样例数据如下:
CREATE OR REPLACE VIEW XO (人员编号，开始时间，结束时间，类型，数值id) AS
SELECT	11,	to_	_date(l201305'		,'yyyymm*	),to	_date('201308',		1yyyymm'),	1, 1
I dual	UNION ALL
SELECT	11,	to	date (	*201307	1,'yyyymm'	),NULL, 1,		2 FROM	dual UNION	ALL
SELECT	11,	to_	—date(	'201301'	1,'yyyymm'	),NULL, -1		,3 FROM	dual UNION	ALL
SELECT	11；	to	—date(	*201312	',’yyyymm，	),NULL, 1,		4 FROM	dual UNION	ALL
SELECT	22,	to	date('201305’		,'yyyymm'	),to	一 daterSOl^OS、		'yyyymm'),	1, 1
[dual	UNION ALL
SELECT	22,	to_	_date(	*201308'	,|yyyymm*	),to	一date(	'201309',	'yyyymm'),	1, 2
I dual	UNION ALL
SELECT 22,		to	date(1	201312'	r 1 yyyyirun'；	1 , to_	date (T	201312','	1yyyymm1),-	•1, 3
[dual	UNION ALL
SELECT	22,	to	一date('201403!		',1yyyymm1	)f NULL, 1,		4 FROM	dual UNION	ALL
SELECT 22, to_date(，201405、 SELECT 33, to_date('2013051, FROM dual UNION ALL
*yyyymm1 ) , NULL, -1, 4 FROM dual UNION ALL 'yyyymm1), to_date(1201305','yyyymm'), 1, 1
• 238 •
第13章应用案例实现
SELECT 33, to_date(*201307 1	• 'yyyymm')	/ to_date(	•201307','yyyymm1), 1, 2
FROM dual UNION ALL
SELECT 33, to_date(?201310'	,1yyyymm1 ；	),NULL, -1	,3 FROM dual UNION ALL
SELECT 33, to date('201312'	• 'yyyymm'	),NULL, 1,	4 FROM dual;
要求得到如下数据：
人员编号区间
11	201312—NULL
22	201305--201306
22	201308—201309
22	201403—201404
33	201305--201305 -
33	201307—201307
33	201312—NULL
7 rows selected
需求如下： ①当类型为时，数据丢弃。
②当类型为“-1”，且其前一行“结束时间”为空值时，“开始时间-1”当作其前一行 的结束时间。
③如果后面的时间比前面的时间早，则覆盖前面的时间，不能覆盖的时间要保留。
④时段重叠的要合并为一行。 数据乱，需求也就复杂。 首先要取出对应的数据，刚开始写语句时可能不知道要准备哪些数据，这不要紧，当 需要新的数据时，再更改这一步就可以：
CREATE OR REPLACE VIEW xOl AS SELECT人员编号，
开始时间，
/*当前人员的最小日期，覆盖用*/
coalesce (MIN (CASE WHEN 类型=-1 THEN add_months (开始时间，-1> ELSE 开始时间 END) over (PARTITION BY 人员编号 ORDER BY 数值 id rows BETWEEN 1 following AND unbounded following),开始时间 + 1) AS 111；111_开始时间，
结束时间AS修正前，
/★修正结束时间*/
CASE
WHEN 结束时间 IS NULL AND (lead (类型）over (PARTITION BY 人员编号
Oracle查询优化改写技巧与案例
ORDER BY 数值 id” = -1 THEN
add_months ( (lead (开始时间）over (PARTITION BY 人员编号 ORDER BY 数
值-1)
ELSE 结束时间 END AS结束时间， 类型，
数值id,
MAX (数值 id) over (PARTITION BY 人员编号）AS max一id FROM xO;
SELECT * FROM xOl；
		mmm —	间	修正前	结规间 一	難—	nmo j	MAXJD 一
	11	2013-05-01 ▼	2012-12-01 ▼	2013-08-01 ’	2013-08-01 ▼	1	i	4
	11	2013-07-01 ▼	2012-12-01 | ▼	▼	2012-12-01 ▼	1	2	4
	11	2013-01-01 ^	2013-12-01 ▼	▼		卜1	3	4
	11 2013-12-01 ▼		2013-12-02 ▼	▼		1	4	4
	22	2013-05-01 ▼	2013-08-01 ，	2013-06-01 ,	2013-06-01 f	1	1	4
	22	2013-08-01 ▼	2013-11-01 ▼	2013-09-01，	2013-09-01，	1	2	4
	22	2013-12-01 ▼	2014-03-01 -	2013-12-01 -	2013-12-01 ▼	-1	3
	22 2014-03-01 ▼		2014-04-01 ▼		^	2014-04-01 卜			4
	33	2013-05-01 ,	2013-07-01 ▼	2013-05-01，	2013-05-01 -	i	) 4 1	4
	33	2013-07-01 ,	2013-09-01 ▼	2013-07-01 ▼	2013-07-01 ▼	i	2	4
	33	2013-10-01 ▼	2013-12-01 ▼	▼		-i	3	4
tj	33	2013-12-01 ▼	2013-12-02 ▼		▼	1	4	4
上面标识了 “开始时间”（见第三条）与“结束时间”（见第二条）分别处理的过程。 分组数据，这种方法见前面9.3节的演示。
CREATE OR REPLACE VIEW x02 AS SELECT人员编号，
开始时间， min 一开始时间， 结束if间， 类型，
数值id, max_id,
/★^成区间是否重叠的标识，合并时段时用*/
CASE
WHEN (lag (结束时间）over (PARTITION BY 人员编号 ORDER BY 数值 id) > < add一months (开始时间，-1) THEN 1
• 240 •
第13章应用案例实现
WHEN (lag (类型）over (PARTITION BY 人员编号 ORDER BY 数值 id) > = 1 THEN NULL ELSE
1
END AS SO FROM xOl;
SELECT * FROM x02;
	开始时间		结刺间」		数(UD	MAXJDJ	SO _
ii	2013-05-01 -	2012-12-01 -	2013-08-01 ▼	1	1	4	1
ii	2013-07-01 ,	2012-12-01 ▼	2012-12-01 ’	1	2	4
ii	2013-01-01 -	2013-12-01 ▼			3	4
ii	2013-12-01，	2013-12-02 •		1	4	4	1
22	2013-05-01 ’	2013-08-01 ，	2013-06-01 ▼	1	1	4	1
22	2013-08-01 ▼	2013-11-01 ▼	2013-09-01 ’	1	2	4	1
22	2013-12-01 ▼	2014-03-01 -	2013-12-01 ▼		3	4	1
22	2014-03-01 ▼	2014-04-01 ▼	2014-04-01 ▼	1	4	4	1
22	2014-05-01 ▼	2014-05-02 ▼			• 4	4
33	2013-05-01 ▼	2013-07-01 ▼	2013-05-01，	1	1	4	1
33	2013-07-01 ▼	2013-09-01 ▼	2013-07-01 ▼	1	2	4	1
33	2013-10-01 ▼	2013-12-01 «			3	4	1
33	2013-12-01 ▼ 2013-12-02 -				4	4	1
生成分组标识，如果后录入的数据开始时间更早，就说明前面录入的是无用的数据, 要丢弃，如果范围重叠，就修正前面的结束时间。
CREATE OR REPLACE VIEW x03 AS SELECT人员编号，
数值id, max_id,
类型：
产	/*累加标识，生成分组合并依据*/
SUM (so) over (PARTITION BY 人员编号 ORDER BY 数值 id) AS so,
开始时间，min_/F始时间，
/*根据最前面圣成的时间覆盖对应的时段*/
CASE WHEN ^11_开始时间 < 结束时间AND min—开始时间 >=开始时间THEN 1^11_开始时间ELSE结束时间END AS结束时间 FROM x02 WHERE 类型=1
/*如果开始时间比这还小，就丢弃吧*/
AND开始时间<=min_开始时间；
SELECT * FROM x03;
• 241 •
Oracle查询优化改写技巧与案例
	数SID	max.id J	■」	SO」	间		结束时间 —
11	4	4	1	1	2013-12-01 ▼	2013-12-02 ▼
22	1	4	1	1	2013-05-01 ▼	2013-08-01 ▼	2013-06-01 ▼
22	2	4	1	2	2013-08-01 ，	2013-11-01 -	2013-09-01 ▼
22	4	4	1	3	2014-03-01 ▼	2014-04-01 ，	2014-04-01 ▼
33	1	4	1	1	2013-05-01 ▼	2013-07-01 ▼	2013-05-01 ▼
33	2	4	1	2	2013-07-01 ▼	2013-09-01 ▼	2013-07-01 ▼
33	4	4	1	3	2013-12-01 ▼	2013-12-02 ▼
合并数据，语句如下：
CREATE OR REPLACE VIEW x04 AS SELECT人员编号， max_idf MAX (数值 id>
SUM (类型）AS MIN (开始时间）
MAX (结束时间）
FROM x03 GROUP BY 人员编号，so, max id;
AS max_id2,
类型，■
keep(dense_rank FIRST ORDER BY 数值 id) AS 开始时间, keep(dense_rank LAST ORDER BY 数值 id) AS 结束时间
SELECT * FROM x04;
AS解」	MAXJD —	MAXJD2 —	麵」		结束时间」
11	4	4	1	2013-12-01 ▼
22	4	1	1	2013-05-01 ▼	2013-06-01 ’
22	4	2	1	2013-08-01 ▼	2013-09-01 ▼
22	4	4	1	2014-03-01 ▼	2014-04-01 ▼
33	4	1	1	2013-05-01 ▼	2013-05-01 ▼
33	4	2	1	2013-07-01 ▼	2013-07-01 ，
33	4	4	1	2013-12-01 ▼	▼
最后一步是过滤，语句如下：
CREATE OR REPLACE VIEW x05 AS SELECT人员编号，
to_char (开始时间，'yyyymm 'yyyymm') , 'NULL') AS 区间 FROM x04
WHERE (max_id = max_id2 OR 开始时间 <=结束时间> AND 类型 > -1;
II ’ -- * 丨丨 coalesce (to char (结束时间，
SELECT * FROM x05;
• 242 •
第13章应用案例实现
AS鮮」	区间
11	201312-NULL
22	20130)5-201306
22	201308-201309
22	201403-201404
33	201305-201305
33	201307-201307
33	201312—NULL
到这一步就可以了。整理数据是最考验耐心的工作，特别是需求还不确定的时候。
8用“行转列”来得到隐含信息
示例数据如下:
CREATE TABLE cte AS (SELECT *A' AS shop, '2013' AS nyear, 123 AS amount FROM dual UNION ALL SELECT 'A' AS shop, '2012' AS nyear, 200 AS amount FROM dual);
SQL> SELECT * FROM cte; SHOP NYEAR AMOUNT
A 2013 123 A 2012 200 2 rows selected
cte表内始终只有两年的数据，要求返回两列分别显示其中一年的数据，原始写法如
SELECT shop, MAX(decode(nyear, *2012', amount)), MAX(decode(nyear, *2013', amount)) FROM cte GROUP BY shop; SHOP MAX(DECODE(NYEAR,'2012AMOUNT MAX(DECODE(NYEAR,	'2013',AMOUNT
A 200 1 row selected	123
• 243 •
Oracle査询优化改写技巧弓案例
现在的语句中，2012年与2013年是固定的，而数据库中每一年的数据都在变（上一 年与本年），现要求不再固定为2012年与2013年。怎么办？ 其实这就是把上一年与本年数据各写为两列，本例的max用错了，应该为sum。 首先可以用分析函数取出上一年的年份（min)和本年的年份（max)，分别放在两列 里。
SELECT shop, nyear,
MAX(nyear) over() AS max_year,
MIN(nyear) over() AS min_yearr SUM(amount) AS amount FROM cte GROUP BY shop, nyear;
SHOP	NYEAR	MAX 一YEAR	MIN_YEAR	AMOUNT
A	2012	2013	2012	200
A	2013	2013	2012	123
可以看到，我们把年份信息取出来，分别放在了两列中，这样就有了一个参照:
WITH tO AS
(SELECT shop,
nyear,
/★先用分析函数做行转列，把隐藏数据提出来*/
MAX(nyear) over() AS max	year,
MIN(nyear) over() AS min_	year.
SUM(amount) AS amount
FROM cte
GROUP BY shop, nyear)
SELECT shop,
MAX(decode(nyear, min year	/* 代替 2012*/.,	amount))	AS去年，
MAX(decode(nyear, max一year	/*代替 2013*/,	amount))	AS今年
FROM tO
GROUP BY shop;
SHOP 去年 今年
A 200 123
1 row selected
• 244 •
第13章应用案例实现
13.9用隐藏数据进行行转列
有网友提出如下需求，用现有表scott.emp模拟，表中每个job显示为一行，同类job 的姓名分列显示，不够的显示为空，结果如下：
JOB	N1	N2	N3
ANALYST	SCOTT	FORD
CLERK	SMITH	ADAMS	JAMES	MILLER
MANAGER	JONES	BLAKE	CLARK
PRESIDENT	KING
SALESMAN	ALLEN	WARD	MARTIN	TURNER
乍一看，这个语句不好写，因为没有可供case when选用的条件。其实这里的条件是 隐藏的，就是各员工姓名的顺序。
SELECT job, ename, row_number() over(PARTITION BY job ORDER BY empno) AS sn FROM emp;
JOB	ENAME	SN
ANALYST	SCOTT	1
ANALYST	FORD	2
CLERK	SMITH	1
CLERK	ADAMS	2
CLERK	JAMES	3
CLERK	MILLER	4
MANAGER	JONES	1
MANAGER	BLAKE	2
MANAGER	CLARK	3
PRESIDENT	KING	1
SALESMAN	ALLEN	1
SALESMAN	WARD	2
SALESMAN	MARTIN	3
SALESMAN	TURNER	4
14 rows selected
有这个序号后，我们可以把sn=l的放第一列，sn=2的放第二列 SELECT job,
• 245 •
Oracle查询优化改写技巧与案例
MAX(CASE	WHEN	sn =	1	THEN	ename	END)	AS	nl,
MAX(CASE	WHEN	sn =	2	THEN	ename	END)	AS	n2.
MAX(CASE	WHEN	sn =	3	THEN	ename	END)	AS	n3,
MAX(CASE	WHEN	sn =	4	THEN	ename	END)	AS	n4
FROM (SELECT job, ename,
row_number() over(PARTITION BY job ORDER BY empno) AS sn FROM emp)
GROUP BY job;
如果用行转列函数，则为
SELECT *
FROM (SELECT job, ename,
row_number() over(PARTITION BY job ORDER BY empno) AS sn FROM emp)
PIVOT (MAX(ename) FOR sn IN (1 AS nl,2 AS n2,3 AS n3,4 AS n4));
如果不知道有多少列怎么办？那就需要先查询，然后用循环语句自动拼装成需要的 SQL即可：
DECLARE
V—MAX一SEQ NUMBER;
V_SQL	VARCHAR2(4000);
BEGIN
SELECT MAX(COUNT(*)) INTO V_MAX_SEQ FROM EMP GROUP BY JOB;
V—SQL	'select' || CHR(IO);
FOR I IN 1 .. V_MAX_SEQ LOOP
V—SQL ••= V—SQL | 丨 *	max	(case	when seq = 1 丨丨 TO_CHAR(I) | |
'then ename end) as n，| | TO_CHAR(I) ||	I	I	CHR(IO);
END LOOP;
V_SQL := V—SQL 丨丨，	job
from (select ename,job,row_number() over (partition by empno) as seq from emp) group by job1;
DBMS_OUTPUT.PUT_LINE(V_SQL);
END;
select
max (case when seq = 1 then ename end) as nl, max(case when seq = 2 then ename end) as n2,
job order by
• 246 •
第13章应用案例实现
max(case when seq = 3 then ename end) as n3f max(case when seq = 4 then ename end) as n4, job
from (select ename,job,row_number() over (partition by job order by empno) as seq from emp) group by job PL/SQL procedure successfully completed
13.10用正则表达式提取dob里的文本格式记录集
表结构如下：
SQL>	desc	test;
Name	Type	Nullable	Default Comments
Cl	CLOB	Y
SQL>	select count		^) from test;
COUNT(*)
1
字段中内容为
SU.SYSTEM—USER—CODE| | 1 |#l 1 I IS.STAFF_NAME| | ' |#I1 I ISU.STATUS一CD I | ' |# T I I SU.CHANNEL一ID|I'|#| ， I|SU.LAN_ID
011# |i&4k|#11000|#113378|#11407
02	I# | 政企 I # 11000 I # 113383 I # 11407 01 |#丨路|#|11001#丨10093丨#丨1401 54|#12354|#11100|# f111|#114 55|#123551#11100 I#11111#I 14 56|#|2356|#|1100|#|111|#|14 57|#|2357|#|1100|#|111|#|14 58|#12358|#11100 I#I 111 I#114 591#12359!#|1100|#|111|#|14
因为回车符不能用可见字符表示，所以可以在这里使用chr函数来转换，这样就可以 在内联视图中把文本拆分为多行，然后对各行数据进行处理得到结果：
SELECT cl,
regexp_substr(cl, 'I#]+'/ 1, 1) AS dl,
• 247 •
Oracle查询优化改写技巧4案例
regexp_substr(cl,				2)	AS	d2
regexp substr(cl,	'[,			3)	AS	d3
regexp_substr(cl •	f V		1,	4)	AS	d4
regexp_substr(cl,	1 [/	、l#] + \	lr	5)	AS	d5
FROM (SELECT to_char (regexp_substr (cl, * |
1)) AS cl
FROM test
CONNECT BY LEVEL <= regexp—count<cl, chr(10)));
I | CHR(IO) || ，] + • , 1, LEVEL
C1
011# 丨政企间 1000|#| 13378|# 丨 1407
D1	D2	D3	D4
D5
1407
02丨#丨政企丨#丨1000网13383|#| 1407	02	政企	1000	13383	1407
01丨#丨路同1丨00|#丨10093丨#丨1401	01	路	1100	10093	1401
54|#|2354|#|1100|#|I11|#|14	54	2354	1100	111	14
55|#|2355|#|U00|#|lll|#|l4	55	2355	1100	111	14
56|#|2356|#|1100|#|111|#|14	56	2356	1100	111	14
57|#|2357|#|1100|#|111|#|14	57	2357	1100	111	14
58|#|2358|#|1100|#|111|#|14	58 |	2358	1100	111	14
59|#|2359|#|1100|#|U1|#|14	59	2359	1100		14
第14章
改写调优案例分享
本章的大部分例子都是来自网友的实际案例，但笔者更改了表名和大部分列名。因为 很多例子都比较冗长，为了避免读者在不必要的代码上浪费时间，本章截取了其中的讲解 要点。所以大家平时接触的査询可能比这里列举的要复杂得多，平时看语句的时候，要多 点耐心。
14.1	为什么不建议使用标量子查询
下面通过具体案例来分析：
SELECT empno, ename,
sal,	•
• 249 •
Oracle查询优化改写技巧hi案例
deptno,
(SELECT d.dname FROM dept d WHERE d,deptno = e.deptno) as dname FROM emp e;
Plan hash value: 2 981343222
■■I	0	•	•	•	.	'	...	_'r . -	...	•	•,	.
''. ^ ........ ,
I Id ! Operation	J	Name | Rows \ Bytes f Cost (%CPU)| Time
I	0	|	SELECT STATEMENT	|	|	14	|
|	1	|	TABLE ACCESS BY INDEX	ROWID|	DEPT	|	1	J
2	| INDEX UNIQUE SCAN	|	PK一DEPT	|	1	J
I	3 | TABLE ACCESS FULL	.	|	EMP	I	14	|
•	•	o
Predicate Inf6nnation (identified by operation id);
2	- access(nDn."DEPTN0H=:B1)
通过执行计划可以看到，标量子査询中的语句实际上执行的是
SELECT d.dname FROM dept d WHERE d.deptno = :B1
只是针对emp的每一行，：B1取不同的值，这时执行计划只有这一种。
上面这种语句等价于e left join d。为了证明这一点，我们先增加一行数据: insert into emp(empno,deptno) values(9999,null);
这时上面的查询会返回15行数据：
EMPNO	ENAME	SAL	DEPTNO	DNAME
7369	SMITH	800	20	RESEARCH
7934	MILLER	1300	10	ACCOUNTING
9999 已选择15行。
这是因为当emp.deptno为空时，标量子查询查不到数据，根据第3章介绍的知识，这 种场景应该使用left join:
SELECT e.empno, e.ename, e.sal,
644	I	3	(0)|	00:00:01	I
22	|	1	(0)丨	00:00:0!	|
0	(0)'J	00:00:01	•!
644	\	3	(0)	I	00:0*0:01*	|
• 250 •
第14章改写调优案例分享
0	f SELECT STATEMENT	I
1	J	NESTED	LOOPS OUTER )° ■	|
2	|	TABLE	ACCESS	\	EMP
3	|	TABLE	ACCESS BY INDEX ROWID |	DEPT
*	4	|	INDEX	UNIQUE	SCAN	1	PK_DEPT
I	0	|	SFIEnr STATF>^EiT^ 1	\	15	|	1020	I
|*	1	|	HASH JOIN OUTER f	\	15	f	1020
|	2	!	TAbLE ACCEao cULL|	EMP	| .	15	|	6^0	|
I	3	|	••TABLE ACCESS FlTLLj	DEPT	|	4	|	S8	!
Predicate Information (idenrified by operation id):
e.deptno,
d.dname FROM emp e
LEFT JOIN dept d ON (d.deptno = e.deptno), 这里就不重复显示结果了，重点看一下执行计划：
可以看到，现在进行的是HASH JOIN,我们还可以更改执行计划:
SELECT /*+ use_nl(e,d) */
e.empno, e.ename, e.sal, e.deptno, d.dname FROM emp e
LEFT JOIN dept d ON .(d.deptno = e. deptno);
可以看到，改为jOlN后有两种PLAN可供选择，这样优化的余地也就大一些<
:二
Flan
1 一 access("DCT.nDEPTNO”DEPTNO”)
Bytes 1 Cost: (%CPU) J Time
Rows
•Id
3387915970
Flan nash value
11111 o o o o o • •«« «• ■■ __ 00 o Q o o o o o o ••• ••• «• •• o o o o o o o o o o
0 0 0 2 2 2 9 2 0 0 6 1 1
0>丨 00:00:01 0)| 00:00:01 0)丨.00:00:01 0>| 00:00:01
• 251 •
Oracle查询优化改写技巧与案例
另外需要注意的是：改写为LEFT JOIN后，PLAN里会显示OUTER关键字，如果PLAN
里没有这个关键字，就需要注意是否改写错了。
14.2	用LEFT JOIN优化标量子查询
不知为什么很多人都喜欢使用标量子査询，在此建议，如果未经过效率测试，尽量不 要用标量子查询，特别是多次访问同一个表的时候：
SELECT s.sid,
s. sriciins •
s.shot,
s.stype,
(SELECT	a.	•aid FROM a	WHERE a.	.aid = s.aids) aid,
(SELECT	a,	,aname FROM	a WHERE	a.aid = s.aids) aname,
(SELECT	a.	,atime FROM	a WHERE	a.aid = s.aids) aatime
FROM s
这是在一个查询语句中截取的一部分代码，可以看到，在标量子查询中对a表访问了 三次，而且关联条件一样。对于这种查询，一般都直接改为LEFTKMN的方式：
SELECT s.sid, s.sname, s.shot, s.stype, a.aid, a.aname, a.aatime FROM s
LEFT JOIN a ON (a.aid = s.aids)
改为LEFT JOIN后，原关联条件（a.aid = s.aids)直接作为JOIN条件即可。
14.3用LEFT JOIN优化标量子查询之聚合改写
下列语句的标量子查询中有sum:
SELECT d.department—id, d.department一name, d.location一id, nvl((SELECT SUM(e.salary)
FROM hr.employees e WHERE e.department_id = d.department_id)r 0) AS sum 一sal FROM hr.departments d;
• 252 •
第14章改写调优案例分享
如果像14.2节那样改，肯定要报错。
SELECT d.department一id, d.department—name, d.location_id/
nvl(sum(e•sum一sal), 0) AS sum一sal FROM hr.departments d
LEFT JOIN hr.employees e ON (e.department_id = d.department_id); ORA-00904: "E"."SUM_SAL":标识符无效
当然，对熟悉语法的读者来说，这不是问题。
①要先分组汇总改成内联视图，GROUP	BY后面的列就是关联列（department_id)。
原标量子査询改写为：
SELECT e.department—id, SUM(e.salary) AS sum_sal FROM hr.employees e GROUP BY e.department_id
②要左联改写后的内联视图：
SELECT d,department一id, d.department_name, d.location_id,
nvl(e•sum—sal, 0) AS sum一sal FROM hr.departments d
LEFT JOIN (SELECT e•department—id, SUM(e.salary) AS sum—sal FROM hr.employees e GROUP BY	e. depar tmen t*_id)	e ON	(e .department一id =
d. department_id);
注意以下两点： ①除非能根据业务或逻辑判断用INNER JOIN，否则标量子查询改为JOIN时都要改 成 LEFT JOIN。
②如果需要GROUP	BY,要注意：先汇总，后关联。
我们来对比一下执行计划。 更改前：
• 253 •
Oracle查询优化改写技巧Si案例
00:00:01 00： 00-： 01 00:00:01 00:00:01 00：00：01 00:00:01 00:00:01 00：00;01
Cofec (%CPU)| Time	I
(0)| 00:00:01 | I . I ton 00:00:01 i to) I 00：00t1)l I
(0)'J t 00:00:01 t
0	I:	SELECT STATEMENT	|
1	I*	SORT AGGREGATE	' .	|
2	|	TABLE ACCESS BY	INDEX	RONID|	EMPLOYEES
RJDEX RANSE SCAN TABLE ACCESS TULL
EMP_DEFARXMENT_
DEPAfiXKENTS
at:ion (iclencifaecl by op^racion id):
3 - access("E","DEPARTMENT ID"=:51)
recursive c«lls *
o
oils blcclc gee a 'consistent gets
physical reads	^
redo size	■.
bytes aenc. via SQL •'Net co client bytes received Via SQL^Nec from client SQL*Net raimdcrips ca/fram client sores (senary)
丨 Bytes l
|	1215
I 1215 1	513
I 286 | 286 I 77 !	749
Kfenie
DEPARTMENTS
DEPT_IDwPK
EMPLOYEES
| Id I Operation
|	. 0	|	SELECT STAT04E3Tr
|	1	；	MERGE JOIN OUTER
|	2	I	TA3LE ACCESS BY	XNDCX ROWID
|	3 |	*I1?E«X FULL SCAN	«
|*	4	1	SORT	JOIN	•
*	5	丨	VIEW
f	6 I	HASH GROUP BY
•|	7	|	' TABLE ACCESS	FULL
更改后:
熟悉执行计划的，可以对比改写前后的执行计划，不熟悉的可以对比改写前后的执行 时间。注意一点：以返回所有数据的时间为准，而不是在PL/SQL里只返回前几行的时间。
recursive calls db block gees
gees physical reads redo size
bytes sent via 5QL"Net ro client fcytea received vxa SQL-Wee from cliepc SQL*Net roundcrrps to/from client aorca (memory) soics (dx^Jc) rows processed
Predicate Isvformation (identified fay operacioh id) : ■*
4 - access <-E"."DEPARTMEMI_ID”（ + }*=”D-. "DEPARTMENT一ID”）
filter I "Ew . "DEPARTMENT_ID* (+) =”D*V"DEPARXMENX_IDW> —	Y	一
e	,
统计信息	、	■
99000550 22 ( ( 4 (
• 254 •
第14章改写调优案例分享
14.4用LEFT JOIN及行转列优化标量子查询
14.3节介绍了简单的标量改写方式，那么稍微复杂一点的呢？像下面的例子，同样是 多个标量访问一个表，但返回的是同一列的值，只是条件不一样。
SELECT /*省略部分返回列*/
F2	(SELECT ROUND(vr2) UMUM=F4101.IMU0M1 ) AS M3	FROM t	F2	WHERE	F2	UMITM=F4101	IMITM AND	m=	1	AND
F2	(SELECT ROUND(vf2) UMUM=F4101.IMU0M1 ) AS KG	FROM /	F2	WHERE	F2	UMITM=F4101	IMITM AND	m=	2	AND
F2	(SELECT ROUND(vr2) UMUM=F4101.IMU0M1 ) AS KN	FROM /	F2	WHERE	F2	UMITM=F4101	IMITM AND	m=	3	AND
F2	(SELECT ROUND(v,2) UMUM=F4101.IMU0M1 ) AS MH	FROM r	F2	WHERE	F2	UMITM-F4101	IMITM AND	m=	4	AND
F2	(SELECT ROUND(v,2) UMUM=F4101.工MUOM1 ) AS ML	FROM f	F2	WHERE	F2	UMITM=F4101	IMITM AND	m=	5	AND
F2	(SELECT ROUND(v,2) UMUM=F4101.IMUOM1 ) AS MW	FROM t	F2	WHERE	F2	UMITM=F4101	IMITM AND	m=	6	AND
	(SELECT	MAX(BPUPRC)/10000
	FROM	F4106
	WHERE	TRIM(BPMCU) = 1	'ZXIO* and BPCRCD=,CNYf
	AND	F4106.BPLITM =	F4101.IMLITM )	BPUPRC
FROM	F4101,	F4102
WHERE	F4101.	IMITM = F4102.IBITM AND F4101.		_IMLITM=F4102.IBLITM
AND	IBMCU <> ' ZX10'
AND	IMDSC1	NOT LIKE 取消％*
AND	(工MSRP5 IN ( 11', '		6,) OR IMSRP3 INCaT1, *38') OR
in ( '506000040') AND TRIM(工BMCU> =			'SF10,);
可以看到，在这个查询里，通过标量子査询对F4101访问了 6次，这里即使不考虑 CBO计划的对错，仅是6次的査询，如果是大表，也绝对会让人崩溃。好在这几个标量子 査询关联条件都-样，所以可以先合并成一个内联视图，再用LEFT JOIN。
①因为笔者喜欢用JOIN的方式写査询，所以首先把主查询改写成了 F4101 INNER JOIN F4102.
.②因为标量子査询中的表（F2)是否有数据都不影响主查询返回的行数，而F2只需 要返回相匹配的数据就可以。所以，如果要改写，就只能改写为F4101 LEFTJO丨NF2,而 关联条件不变（F2.UMITM=F410UMITM AND F2.UMUM=F4101.丨MUOM1 )。
• 255 •
Oracle查询优化改写技巧与案例
③几个标量子查询除访问的表（F2)与关联条件外，只有的取值不同。为了使用 一个子查询把这些列需要的数据都查询出来，则需要用到CASE WHEN语句，那么这几个 标量子査询合并后的语句就是：
SELECT umitm,
umum,
MAX (CASE	WHEN	m =	'1'	THEN	round(v,	2)	END)	AS	m3,
MAX (CASE	WHEN	m =	'2'	THEN	round(v,	2)	END)	AS	kg.
MAX (CASE	WHEN	m =	f3'	THEN	round(v,	2)	END)	AS	lcn,
MAX (CASE	WHEN	m =	f4'	THEN	round(v,	2)	END)	AS	mh,
MAX (CASE	WHEN	m =	'5'	THEN	round(v,	2)	END)	AS	ml,
MAX (CASE	WHEN	m =	'6'	THEN	round(v,	2)	END)	AS	mw
FROM F2 GROUP BY umitm, umum
注意：F2中的列irniitm、umum都是关联列，所以都需要在子査询中列出，以便进 行关联。 把上面这个语句作为内联视图与主表进行关联，ON后面直接放关联条件 (F2.UMITM=F4101 .IMITM AND F2.UMUM=F4101.IMUOM 1 ),就是下面的语句：
SELECT /*省略部分返回列*/
FROM f4101
INNER JOIN f4102 ON (f4101.imitm f4102.iblitm)
LEFT JOIN (SELECT umitm, umum.
MAX (CASE	WHEN	m =	'1'	THEN	round(v,	2)	END)	AS	m3,
MAX (CASE	WHEN	m =	,2.	THEN	round(v,	2)	END)	AS	kg,
MAX (CASE	WHEN	m =	•3’	THEN	round(v,	2)	END)	AS	kn,
MAX (CASE	WHEN	m =	• 4.	THEN	round(v,	2)	END)	AS	mh,
MAX (CASE	WHEN	m =	•5,	THEN	round(v,	2)	END)	AS	ml.
MAX《CASE	WHEN	m =	'6'	THEN	round(v,	2)	END)	AS	mw
FROM F2
GROUP BY umitm, umum) F2 ON (F2.umitm:
f4101.imitm AND F2.umum
f4101.imuoml) LEFT JOIN
/ 10000 AS bpuprc
(SELECT bplitm,MAX(bpuprc)
FROM f4106 WHERE TRIM(bpmcu) = 'ZX10'
AND bpcrcd = *CNY'
GROUP BY bplitm) f4101 ON f4106.bplitm WHERE ibmcu <> 1	ZX10'
£4101.imlitm
• 256 •
第14章改写调优案例分享
AND iradscl NOT LIKE *%^^%*
AND (imsrp5 IN (，1',	f6') OR imsrp3 IN (，37’，	,38*) OR
iblitm IN ('506000040') AND TRIM(ibmcu) = 'SF10');
经测试发现，改后的查询速度由30分钟降到了 2分钟。
14.5	标量中有ROWNUM =1
有时标量中会有rownum = 1这样的条件语句：
	SELECT s.sid,
	s. sname,	t
	(SELECT	cid FROM b WHERE		b.sid =	s .sid	AND	b.status	IN	('		•3*)
AND	b. sstype = '6	1 AND rownum =	1)	cid,
	(SELECT	cid FROM b WHERE		b.sid =	s .sid	AND	b.status	IN	(•		*3')
AND	b.sstype = 18	'AND rownum =	1)	ringcid,	i
	(SELECT	cid FROM b WHERE		b.sid =	s. sid	AND	b. status	IN	('
AND	b.sstype = * 1	* AND rownum =	1)	mvcid
	FROM s •
	WnfijKij 丄一丄 AND EXISTS	(SELECT 1 FROM	b	c WHERE c.sid		=s.	sid AND status			IN	(T,
t3» )	AND rownum =	1)
	AND NOT EXISTS (SELECT 1
	FROM	b c
	WHERE	c.sstype = 18'
	AND	c.price = * 01
	AND	c.distributionarea != * 99			馨
	AND	c.distributionarea IS NOT			NULL
	AND	s.sid = c.sid)
看到这种语句，可能有很多人都要头痛，普通的标量子查询会改了，可其中有 ROWNUM怎么办？ 其实这种不加排序的子句直接使用rownum = 1的査询，本身就是对数据要求不严格， 我们可以通过案例来看一下：
SELECT deptno, dname,
(SELECT ename FROM emp e WHERE e.deptno = d.deptno
• 257 •
Oracle查询优化改写技巧与案例
AND rownuin = 1) AS ename FROM dept d;
DEPTNO DNAME	ENAME
10	ACCOUNTING	CLARK
20	RESEARCH	SMITH
30	SALES	ALLEN	•
40 OPERATIONS
4	rows selected
这同样是一个“rownum = 1”的例子，返回emp中的一条数据，我们不更改查询，只 增加一个索引：
CREATE INDEX idx_emp_2 ON emp(deptno,ename);
直接再次执行上面的查询语句：
DEPTNO	DNAME	ENAME
10	ACCOUNTING	CLARK
20	RESEARCH	ADAMS
30	SALES	ALLEN
40	OPERATIONS
4 rows selected
可知，部门20返回的值改变了。
既然查询本身对返回值的要求都不严格，所以只要达到它的另一个特性（最多返回一 行）就可以，上面的标量语句可以改为：
		(SELECT	MAX(cid) FROM b	WHERE	b,	.sid =	s	.sid	AND	b.	,status	IN	(•1，，
'3')	AND	b • sstype	=*6') cid.
		(SELECT	MAX(cid) FROM b	WHERE	b.	.sid =	s	.sid	AND	b.	.status	IN
'3f)	AND	b.sstype	=18 *) ringcid,
		(SELECT	MAX(cid) FROM b	WHERE	b.	,sid =	s	.sid	AND	b,	.status	IN	(T ,
'3')	AND	b.sstype	=* 11) mvcid
增加聚合函数max,去掉条件rownum = 1,这样更改还能保证同样的数据一定会返回 同样的结果。下一步就是用一个查询返回上面三列及关联列的信息。 把同样的条件放在WHERE后面，不同的条件放入CASE WHEN中：
SELECT c.sid,
258
第14章改写调优案例分享
MAX (CASE	WHEN	c.	,sstype = 11 *	THEN	cid	END)	AS	mvcid.
MAX (CASE	WHEN	c,	-sstype = '8 *	THEN	cid	END)	AS	ringcid,
MAX(CASE	WHEN	C-	,sstype = '61	THEN	cid	END)	AS	cid
FROM b c WHERE status IN (，1 •,	•3•)
GROUP BY c.sid
这就是一个行转列语句。注意，不要忘记返回关联列。 然后左联上面的结果就可以：
SELECT s.sid, s.sname, c.cid, c.ringcid, c.mvcid FROM s
INNER JOIN (SELECT c.sid,
MAX (CASE	WHEN	c	.sstype =	'I'	THEN	cid	END)	AS	mvcid,
MAX (CASE	WHEN	c	•sstype =		THEN	cid	END)	AS	ringcid,
MAX (CASE	WHEN	c	.sstype =	•6'	THEN	cid	END)	AS	cid
FROM b c WHERE status IN (*1，， '3f) GROUP BY c.sid) c ON (c.sid
s.sid)
WHERE
AND
1 = 1
NOT EXISTS FROM b c
(SELECT 1
'8'
AND c.price = 10 *
AND c.distributionarea != '99'
AND c.distributionarea IS NOT NULL AND s.sid = c.sid)
14.6	不等连接的标量子查询改写（一）
在前面的例子中，因为标量子查询中都是等值的关联条件，所以能直接改为LEFT JOIN或汇总后再用LEFT JOIN。但如果关联条件中有不等连接呢？
SELECT a.licenceid, a.data_source, a.streetf
(SELECT MIN(contdate)
FROM ct
WHERE ct.licenceid = a.licenceid
• 259 •
Oracle查询优化改写技巧与案例
AND	ct.data—source	=a.data—source
AND	trunc(contdate)	>=a.opensaledate) AS mincontdate.
(SELECT	MIN(buydate)
FROM	ct
WHERE	ct.licenceid =	a.licenceid
AND	ct.data source	=a.data一source
AND	trunc(buydate)	>=a.opensaledate) AS minbuydate
FROM a
下面是网友自已改写后的语句:
SELECT a.licenceid, a.data_source,
a.street,
ct2 .mincontdate AS mincontdate,--标量2 ct2 .minbuydate AS minbuydate --标量 3 FROM a
LEFT JOIN (SELECT ct.licenceid, ct.data一source,
trunc(MIN(contdate)) mincontdate, trunc(MIN(buydate)) minbuydate FROM ct
GROUP BY ct.licenceid, ct.data一source) ct2 ON ct2.licenceid = a.licenceid AND ct2.data_source = a.data一source AND ct2.mincontdate >= a.opensaledate AND ct2.minbuydate >= a.opensaledate
这种改写方法乍看上去没有错：内联视图里分组汇总并返回关联列，关联列放在LEFT JOIN…ON后面。但要注意这个案例的关联条件有不等条件“ ct2.mincontdate >= a.opensaledate” 及 “ct2.minbuydate >= a.opensaledate”，而且这两个条件是在不同的标量里。 所以这个改写有以下两个错误： ①把分属两个标量子查询的不同条件用AND合并在一起，条件不对。
②原査询是通过不等条件过滤后取最值，改写后是先取最值，再过滤，执行顺序不 对。 我们改写时一定要注意等价改写的原则，可以是逻辑等价甚至是业务等价。当然，后 者要熟悉业务才行。
• 260
第14章改写调优案例分享
所以要想把上面的两个标量合并，必须要先与a表关联，这样才能在取最值前过滤:
SELECT a.rowid AS rid,
MIN(CASE
WHEN trunc《ct•contdate)	>=a.opensaledate THEN
ct.contdate
END) AS mincontdatef
MIN(CASE
WHEN trunc(ct.buydate)	>=a.opensaledate THEN
ct.buydate
END) AS minbuydate
FROM ct
INNER JOIN a ON (ct. licenceid	=a.licenceid AND ct•data—source =
a.data_source)
GROUP BY a.rowid
至此，标量部分搞定，再左联就可以:
WITH ct2 AS
(SELECT a.rowid AS rid,
MIN(CASE
WHEN trunc (ct.contdate) >=	=a.opensaledate THEN
et.contdate
END) AS mincontdate,
MIN(CASE
WHEN trunc(ct.buydate) >=	a.opensaledate THEN
ct.buydate
END) AS minbuydate
FROM ct
INNER JOIN a ON (ct. licenceid = a	.licenceid AND ct.data_source =
a.data_source)
GROUP BY a.rowid)
SELECT a.licenceid.
a.data一source,
a.street,
ct2.mincontdate AS mincontdate,	■~ _标量2
ct2.minbuydate AS minbuydate ——	标量3
FROM a
LEFT JOIN ct2 ON (ct2.rid = a.rowid)
• 261 •
Oracle查询优化改写技巧案例
14.7不等连接的标量子查询改写（二）
14.6节的例句中，主表没有过滤条件（WHERE子句），而更多的例子是主表中有过滤 条件，而且能过滤掉大部分数据，这时如果像14.6节的例子那样改，就会产生不必要的访 问量：
SELECT s.stkcode.
t.mktcode,
t.stype,
t•sname,
(SELECT SUM(c.hsl)
FROM c
WHERE c.stkcode = s.stkcode
AND c.mktcode = t.mktcode
AND c.calcdate BETWEEN to一char(to_	date(s.tdate,	'yyyymmdd*)-
365, 1 yyyynundd1) AND s.tdate) AS fl,
(SELECT decode(COUNT(c.calcdate),	0, NULL,	SUM(c.hsl) /
COUNT(g.calcdate))
FROM c
WHERE c.stkcode = s.stkcode
AND c.mktcode = t.mktcode
AND c.calcdate BETWEEN to_char(to	date(s.tdate.	'yyyymmdd1)-
365, * yyyymmdd') AND s.tdate) AS f2,
s.tdate
FROM s, t
WHERE s.stkcode = t.scode
AND t.status = 1
AND t.stype = 2
AND s.tdate >= to_nCimber (to char (SYSDATE	-3, 'YYYYMMDD1))；
这种标量有以下两种改写方法： ①把标量数据单独提出来与主表进行JOIN操作，因有区间条件，这时主表就要做两 次 JOIN.
②主表直接与标量进行JOIN操作，然后汇总数据。 两种改写方式都需要把主查询放在WITH语句中：
WITH tO AS
(SELECT rownum AS sn, s.stkcode, t.mktcode, t.stype, t.sname, s.tdate
• 262 •
第14章改写调优案例分享
FROM	Si	r t
WHERE	s	.stkcode = t	•scode
AND	t _	status = 1
AND	t.	stype = 2
AND	s •	tdate >= to一	number(to一char(SYSDATE - 3, 'YYYYMMDDT)))
因为这个语句中有两个表，不能返回rowid，所以在这里使用rownum as sn当作唯一 标识。 改写一：先分组汇总，再关联，与主表（这里改成了 WITH里的tO)关联汇总后的数 据放在内联视图中，然后再与主表关联：
WITH tO AS
(SELECT rownum AS sn, s.stkcode, t.mktcode, t.stype, t.sname, s.tdate FROM s, t WHERE s.stkcode = t.scode AND t.status 二 1 AND t.stype = 2
AND s.tdate >= to—number(to—char(SYSDATE - 3,	'YYYYMMDD')))
SELECT t•stkcode, t.mktcode, t.stype, t.sname, t.tdate, c.fl, c.f2 FROM tO t
LEFT JOIN (SELECT t.sn,
SUM(c.hsl) AS fl, decode(COUNT(c.calcdate)•
0,
NULL,
SUM(c.hsl) / COUNT(c•calcdate)) AS f2
FROM c
INNER JOIN tO t ON (c.stkcode = t.stkcode AND c.mktcode =
t.mktcode)
WHERE c.calcdate BETWEEN	to_char(to一date(t.tdate,
^yyyymmdcT) - 365,	*yyyymmdd*) AND t.tdate
GROUP BY t.sn) c ON (c.sn = t.sn);
因为已把主查询放在了 WITH里，所以后面的两次都是直接改用t0，这样就减少了对 “s”和“t”两个表的访问，及重复语句的后期维护。 改写二：先关联，再汇总。
WITH tO AS
(SELECT rownum AS sn, s.stkcode, t.mktcode, t.stype, t.sname, s.tdate FROM s, t WHERE s.stkcode = t.scode
• 263 •
Oracle查询优化改写技巧与案例
AND t.status = 1
AND t.stype = 2
AND s.tdate >= to_number(to_char(SYSDATE - 3, 'YYYYMMDD1)))
SELECT t.stkcodef
t.mktcode,
t•stype,
t.sname,
t.tdate,
SUM(c.hsl) AS fl,
decode(COUNT(c.calcdate), 0, NULL, SUM(c.hsl) / COUNT(c.calcdate))
AS f2
FROM tO t
LEFT JOIN c ON (c.stkcode = t.stkcode AND c.mktcode = t.mktcode)
WHERE c.calcdate BETWEEN to_char(to_	date(t.tdate, 'yyyymmdd') - 365,
'yyyymmdd') AND t•tdate
GROUP BY t.sn, t.stkcode, t.mktcode,	t.stype, t.sname, t.tdate;
这两种改写方式效率的区别就在于是用GROUP组合多列耗费的时间多还是用
GROUP组合单列后，再用JOIN耗费的时间多，这与表中的数据多少有关，如果不能确定，
两种方式都测试一下。
不管是14.6节增加的ROWID还是本节增加的ROWNUM，都是为了防止重复数据的
影响，那么如果不加会出现什么情况呢？看下面的模拟案例：
CREATE TABLE a AS SELECT * FROM scott	• emp ;
CREATE TABLE b AS SELECT * FROM scott	.emp;
SELECT a.empno,
3.. ©nsrnG •
a.sal,
(SELECT SUM(b.sal) FROM b WHERE	b.sal >= a.sal - 100 AND b.sal <=
a.sal) AS改写前，
c.改写后
FROM a
LEFT JOIN (SELECT a.sal, SUM(b.sal)	AS改写后
FROM b
INNER JOIN a ON (b.sal >=	a.sal - 100 AND b.sal <= a.sal)
GROUP BY a.sal) c
ON c.sal = a.sal
ORDER BY 3;
• 264 •
第14章改写调优案例分享
I EMPNO	ENAME	SAL	^ 改写前	改写后 j
7369	SMITH	800	800	800
7900	JAMES	950	950	950
7876	ADAMS	1100	1100	1100
7654	MARTIN	1250	2500	5000
7521	WARD	1250	2500	5000
7934	MILLER	1300	3800	3800
7844	TURNER	1500	1500	1500
7499	ALLEN	1600	3100	3100
7782	CLARK	2450	2450	2450
7698	BLAKE	2850	2850	2850
7566	JONES	2975	2975	2975
7902	FORD	3000	8975	17950
7788	SCOTT	3000	8975	17950
7839	KJNG	5000	5000	5000
这里把改写前后的两种方法都放在了同一个查询语句中，通过上面的数据可以看出， 不使用ROWID或ROWNUM改写后的数据明显有误，sal(1250，3000)这几个有重复数据的 行多统计了数据。我们通过汇总前的明细数据可以很容易地发现原因：
SELECT	a.empno as a_empnof b.	,empno	as b—empno, a.	sal AS a_sal, b.sal AS
b_sal
FROM	b
INNER	JOIN a ON (b.sal >= a.	,sal 一	100 AND b.sal	<=a.sal)
WHERE	a.sal IN (1250, 3000)
ORDER	BY 3, lf 4;
I A_EMPNO	B一EMPNO	A_SAL	B一SAL |
7521	7521	1250	1250
7521	7654	1250	1250
7654	7521	1250	1250
7654	7654	1250	1250
7788	7566	3000	2975
7788	7788	3000	3000
• 265 •
Oracle查询优化改写技巧4案例
续表
| A 一 EMPNO	B 一 EMPNO	A一SAL	B_SAL |
7788	7902	3000	3000
7902	7566	3000	2975
7902	7788	3000	3000
7902	7902	3000	3000
可以看到，因1250与3000在原表中分别有重复数据，所以关联后分别统计了两次， 这时如果按a—empno分组数据是正常的，而按a_sal分组数据就会翻倍。所以要用“唯一 值、序号或rowid”来分组：
SELECT a.empno, s. 6n3in© f a•sal,
(SELECT SUM(b.sal)
FROM b
WHERE b.sal >= a.sal - 100 AND b.sal <= a.sal) AS 改写前， c.改写后 FROM a
LEFT JOIN (SELECT a. rowid AS rid, SUM (b.sal) AS 改写后 FROM b
INNER JOIN a ON (b.sal >= a.sal - 100 AND b.sal <= a.sal) GROUP BY a.rowid) c ON c.rid = a.rowid ORDER BY 3;
I EMPNO	ENAME	SAL	改写前	改写后 I
7369	SMITH	800	800	800
7900	JAMES	950	950	950
7876	ADAMS	1100	1100	1100
7521	WARD	1250	2500	2500
7654	MARTIN	1250	2500	2500
7934	MILLER	1300	3800	3800
7844	TURNER	1500	1500	1500
7499	ALLEN	1600	3100	3100
• 266 •
第14章改写调优案例分享
续表
I EMPNO	ENAME	SAL	改写前	改写后 |
7782	CLARK	2450	2450	2450
7698	BLAKE	2850	2850	2850
7566	JONES	2975	2975	2975
7788	SCOTT	3000	8975	8975
7902	FORD	3000	8975	8975
7839	KING	5000	5000	5000
现在数据就正确了。
14.8标量子查询与改写逻辑的一致性
当标量子查询中有聚合函数时，很多人都喜欢在改写时把聚合函数移到主查询中，大 概是认为这样改写简单一些：
SELECT *
FROM (SELECT * FROM tl WHERE col4一1 = *00*) a LEFT JOIN (SELECT col3—1,
col3—2 coll, col2r
(SELECT DISTINCT col2_l FROM t2 WHERE col2_2 = a.col2
AND col2_3 <= to一date(*2012-09-30•, 'YYYY-MM-DD*) AND col2_4 > to_date(，2012-09-30'YYYY-MM-DD*))
col3
FROM t3 a
WHERE col2一3 <= to一date(*2012-09-30 *,	'YYYY-MM-DD1)
AND col2_4 > to一date(•2012-09-30*,	1YYYY-MM-DD1)) b ON
a.col4 = b.col3 1;
该网友在改写这个查询时，直接把DISTINCT放在了主查询的SELECT关键字后面:
SELECT	★
FROM	(SELECT * FROM tl WHERE	col4 1 = '00') a
LEFT	JOIN (SELECT DISTINCT a.	col3_l,
	a.col3	一2 coll.
• 267 •
Oracle查询优化改写技巧号案例
	a	•col2,
	b	.col2_l AS	col3
FROM	t3 a
JOIN	(SELECT FROM t2	★ b
	WHERE b.	col2 3 <= t	:o_date(*2012-09-30', 'YYYY-MM-	-DD')
	AND b.col2_4 > to_		dater 2012-09-30、' YYYY-MM-DD	f) ) b
ON a.col2 = b.col2 2
AND	a.col2_3	<=to_date('2012-09-30'f *YYYY-MM-DD')
AND	a.col2_4	> to_date(，2012-09-30•, 'YYYY-MM-DD'))		b ON
a.col4 = b.col3_l;
笔者不赞成这种改写方法，因为这种改写方式与14.7节给出的错误例子非常类似，下
面再来模拟一	下：
CREATE	TABLE dept2 AS
SELECT	* FROM dept;
INSERT	INTO dept2
SELECT	★ FROM dept WHERE deptno =	:10;
则原査询可以表示为:
SELECT a.job,
a.deptno,
(SELECT	DISTINCT dname FROM dept2 b WHERE b.deptno = a.deptno) AS
dname
FROM emp a
ORDER BY 1,	2, 3;
JOB	DEPTNO	DNAME
ANALYST	20	RESEARCH
ANALYST	20	RESEARCH
CLERK	10	ACCOUNTING
CLERK	20	RESEARCH
CLERK	20	RESEARCH
CLERK	30	SALES
MANAGER	10	ACCOUNTING
MANAGER	20	RESEARCH
MANAGER	30	SALES
PRESIDENT	10	ACCOUNTING
SALESMAN	30	SALES
第14章改写调优案例分享
SALESMAN	30	SALES
SALESMAN	30	SALES
SALESMAN	30	SALES
14 rows selected
我们来按上面的方法更改：
SELECT DISTINCT a.job, a.deptno, b.dname FROM emp a
LEFT JOIN dept2 b ON b.deptno = a.deptno;
JOB	DEPTNO	DNAME
CLERK	10	ACCOUNTING
PRESIDENT	10	ACCOUNTING
CLERK	20	RESEARCH
MANAGER	10	ACCOUNTING
ANALYST	20	RESEARCH
CLERK	30	SALES
SALESMAN	30	SALES
MANAGER	30	SALES
MANAGER	20	RESEARCH
9 rows selected
可以看到，改写之前有很多重复行，结果是14条。而改写后因为有DISTINCT,重复 行没有了，结果变成了 9条。 所以，除非你确认主査询无重复数据，否则不要这样改写，正确的改写方法为：
SELECT a.job, a.deptno, b.dname FROM emp a
LEFT JOIN (SELECT dname,deptno FROM dept2 GROUP BY dname,deptno) b ON
b.deptno = a.deptno;
我们在改写语句的时候不要盲目地根据某个案例或结论来机械式地改写，在改写的时 候要静下心来多思考：你在做什么，想达到什么效果，你写出来的与你想的是不是一个结 果？最重要的是：多测试，多核对结果。
14.9用分析函数优化标量子查询（_)
当标量子查询中的表与主查询中的表一样，也就是有自关联的时候，常常可以改用分 析函数直接取值：
• 269 •
Oracle查询优化改写技巧与案例
SELECT a.*, CASE WHEN
(SELECT		COUNT(1)
FROM	ii b
WHERE	b	.id > 0
AND	b,	.flag = 2
AND	b,	_ i code = a.
AND	b.	•c_id NOT IN
	(SELECT c id
a.i code
FROM c
WHERE ig—name LIKE	)	>	1	THEN
	2
	ELSE
	1
END		AS	mulinv
FROM	ii	a
WHERE	(a.	id	> 0 AND	itemdesc LIKE :1
AND	a. c	一id	=:3
ORDER	BY	a. i	_code, a	.i_name, a.d_id
在更改之前需要先处理标量中的子查询，经确认c.c_id为主键，这样就可以直接改成 LEFT JOIN,这样标量中的子查询就可以变换为：
SELECT	COUNT(1)
FROM	ii
LEFT	JOIN c ON	(c. c_	id = ii.c id AND c.ig name LIKE ’％停用％M
WHERE	ii.id > 0
AND	ii.flag =	2
AND	c.c_id IS	NULL
AND	ii.i_code	=ii.	i_code
然后是更改标量。
①标量中的ii(b)与主表ii(a)—样，不必再改为“a	left join b”。
②标量中的c直接改为与主表ii(a)进行JOIN操作。
③标量中与主表不一样的条件“flag	= 2 ANDc.c_idISNULL”要放在CASE WHEN 中。要特别注意这一点，因为“c.c_id IS NULL”要放在CASE WHEN中，所以在前面才 要确认c.c_id为主键，否则会造成数据重复。
于是，原标量子查询就可以改为分析函数：
• 270 •
第14章改写调优案例分享
SUM (CASE WHEN flag = 2 AND c.c_id IS NULL THEN 1 END) over (PARTITION BY ii.i_code)
前面介绍过使用分析函数更改语句时要注意范围的一致性，在这个语句中，主查询的 过滤条件比标量中的要多，所以应该嵌套一次，再应用主查询中多出来的过滤条件：
SELECT *
FROM (SELECT ii>,
CASE
/ *用分析函数代替标量自连接*/
WHEN (SUM(CASE WHEN flag = 2 AND c.c_id IS NULL THEN 1 END) over(PARTITION BY ii.i_code)) > 1 THEN
2
ELSE
1
END AS mulinv FROM ii
/★因c.cid为主键，所以可改为LEFT JOIN,而不必担心主查询数据会翻倍★ / LEFT JOIN c ON (c.c_id = ii.c一id AND c.ig一name LIKE *%停用％•)
/*为了保证分析函数窗口内-数据与原标量IE围一致，这里如过滤条件要保持一致*/ WHERE ii.id > 0)
/*提取出原标量所需数据后再应用其他的过滤条件*/
WHERE itemdesc LIKE :1 AND ii.isphantom <> :2 AND ii.c—id = :3 ORDER BY ii.i_code, ii.i name, ii. did;
14.10	用分析函数优化标量子查询（二）
如果说14.9节的语句查询速度还不算太慢，那么下面这个标量子査询的效率就令人担 忧了：
SELECT A.CODE AS CODE,
A.M_CODE AS M—CODE,
A.STKTYPE AS F—STYPE,
A.E_YEAR	AS E_YEAR,
B.SNAME	AS SNAME,
A.C_DATE AS C—DATE,
(SELECT SUM(VALUEF2)
FROM A T
• 271 •
Oracle查询优化改写技巧与案例
	WHERE	T.CODE = A.CODE
	AND	T.C一DATE BETWEEN TO_	_CHAR(TO	一DATE (A. C_	_DATE,	'YYYYMMDD')	-
180,	'YYYYMMDD')	AND A.C_DATE •
	AND	T.E一YEAR = A.E_YEAR)	F70115_	70011,
	(SELECT	SUM(VALUEFl)
	FROM	A T
	WHERE	T.CODE = A.CODE
	AND	T.C—DATE BETWEEN TO_	CHAR (TO	一DATE(A.C_	DATE,	•YYYYMMDD')	-
180,	'YYYYMMDD*)	AND A.C_DATE
	AND	T.E一YEAR = A.E_YEAR)	F70104_	70011,
	(SELECT	SUM(VALUEF6)
	FROM	A T
	WHERE	T.CODE = A.CODE
	AND	T.C_DATE BETWEEN TO_	_CHAR (TO	一DATE(A.C_	_DATE,	'YYYYMMDD1)	-
180,	'YYYYMMDD*)	AND A.C_DATE
	AND	T.E_YEAR = A.E_YEAR)	F70126一	70011,
	(SELECT	SUM(VALUEF5)
	FROM	A T
	WHERE	T.CODE = A.CODE
	AND	T.C_DATE BETWEEN TO_	CHAR(TO	—DATE (A. C	DATE,	1YYYYMMDD*)	-
180,	'YYYYMMDD')	AND A.C_DATE
	AND	T.E—YEAR = A.E_YEAR)	F70131_	70011,
	AS	F—UNIT
	FROM A, B0LINK B
	WHERE A.CODE	=B.SCODE
	AND B.STYPE = 2
	AND B.STATUS = 1
	AND C一DATE	=20140218
	AND B.SCODE = •000001*;
这个查询语句在标量中对表A访问了 4次，而且其中还有范围条件“T.C_DATE BETWEEN TO_CHAR(TO_DATE(A.C_DATE, 'YYYYMMDD') - 180，'YYYYMMDD') AND A.C_DATE”，这种查询显然很慢，我们来看一下怎么更改。
①主表中的“A.C一DATE”是固定值“20140218”。
②主表中的	“A.CODE = B.SCODE” 是固定值 “B.SCODE = ,000001”，。
那么标量子查询的主体部分可以改为：
SELECT SUM(valuef5)
FROM a t WHERE t.code = '000001'
• 272 •
第14章改写调优案例分享
AND t.c_date BETWEEN to_char(to_date('2014 0218' ,	'YYYYMMDD*) - 180,
•YYYYMMDD1) AND *20140218'
AND t•e_year = a.e_year
现在标量子查询与主查询中“A”表的条件就只有一个t.c一date。我们可以先查询半年 的数据，用分析函数得到所需结果后，再用条件“C_DATE = 20140218”进行过滤：
SELECT A.*,
B.SNAME AS SNAME FROM (SELECT A.CODE AS CODE,
A.M 一CODE AS M一CODE,
A.STKTYPE AS F_STYPE,
A.E一YEAR AS E_YEARr A.C DATE AS C DATE,
SUM(VALUEF2)	OVER(PARTITION	BY	A.	,E_	YEAR)	AS	F70115_	■70011,
SUM(VALUEFl)	OVER(PARTITION	BY	A.	■ E_	YEAR)	AS	F70104_	70011,
SUM(VALUEF6)	OVER(PARTITION	BY	A.	,E_	YEAR)	AS	F70126_	70011,
SUM(VALUEF5)	OVER(PARTITION	BY	A.E_		YEAR)	AS	F70131_	70011,
•-•AS F_UNIT FROM A WHERE (A.C—DATE >=
TO一CHAR(TO一DATE(20140218,
A.C_DATE <= 20140218)
AND A.CODE = '000001') A INNER JOIN (SELECT B.SNAME, B.SCODE FROM B0LINK B WHERE B.STYPE = 2 AND B.STATUS = 1 AND B.SCODE - '000001') ON (A.CODE = B.SCODE)
WHERE A.C DATE = 20140218;
'YYYYMMDD1) -180, 'YYYYMMDD1) AND
当然，你也可以把标量里的a表当作另一个表，先用GROUP BY,再左联:
SELECT a.code AS code, a.m_code AS m_code, a.stktype AS f_stype,
a.c一date	AS c一date, a2 • * •
b.	sname AS sname FROM a
INNER JOIN (SELECT a.e一year.
• 273 •
Oracle查询优化改写技巧S案例
SUM(valuef2) over(PARTITION BY a.e一year) AS SUM(valuefl) over(PARTITION BY a.e_year) AS SUM(valuef6) over(PARTITION BY a.e_year〉 AS SUM(valuef5) over(PARTITION BY a•e_year) AS AS f_unit
FROM a
WHERE (a.c—date >= to一char(to_date(2014 0218, 180, 'YYYYMMDD') AND a.c_date <= 20140218)
AND a.code = * 0000011 GROUP BY e_year) a2 ON (a2.e_year = a.e_year)
INNER JOIN (SELECT b.snamer b.scode FROM b01ink b WHERE b.stype = 2 AND b.status = 1 AND b.scode = ' 0000011) b ON (a.code = b.scode)
WHERE a.c date = 20140218;
f70115_70011f f70104_70011, f70126_70011, f70131 70011,
•YYYYMMDD')-
这种更改方式比较特殊，因为通过分析可知，我们首先把不等连接改成了等值连接。
14.11用分析函数优化标量子查询（三）
如果14.10节的语句还可以用普通标量的方法更改，下面这个来自同一个人的査询就 不好改了：
SELECT A.CODE AS CODE,
A.M一CODE AS M—CODE,
A.STKTYPE AS F—STYPE,
A.E_YEAR AS E_YEAR,
B.SNAME AS SNAME,
A.C_DATE AS C_DATE,
TO一CHAR (SYSDATE, ' YYYYMDD 1 )	AS CREATETIME,
TO—CHAR(SYSDATE, 'YYYYMMDD1)	AS UPDATETIME,
(SELECT SUM(VALUEF2)
FROM A T
WHERE T.CODE = A.CODE
AND T.C_DATE BETWEEN TO一	CHAR(T〇_DATE(A.C_DATE, ’ YYYYMMDD')-
180, 'YYYYMMDD') AND A.C_DATE
AND T.E_YEAR = A.E_YEAR)	F70115_70011,
• 274 •
第14章改写调优案例分享
180,
180,
180,
(SELECT	SUM(VALUEFl)
FROM	A T
WHERE	T.CODE = A.CODE
AND	T.C_DATE BETWEEN T〇_	_CHAR(TO_	—DATE(A.C
YYYYMMDD')	AND A.C_DATE
AND	T.E一YEAR = A.E_YEAR)	F70104_	70011,
(SELECT	SUM(VALUEF6)
FROM	A T
WHERE	T,CODE = A.CODE
AND	T.C_DATE BETWEEN T〇_	_CHAR(TO_	_DATE(A.C
YYYYMMDD')	AND A.C—DATE
AND	T.E_YEAR = A.E_YEAR)	F70126_	70011,
(SELECT	SUM(VALUEFS)
FROM	A T
WHERE	T.CODE = A.CODE
AND	T.C—DATE BETWEEN T〇_	_CHAR(TO_	—DATE (A.C
YYYYMMDD')	AND A.C—DATE
AND	T.E一YEAR = A.E_YEAR)	F70131_	70011,
AS	F UNIT
•YYYYMMDD')
'YYYYMMDD')
FROM	A,	B@LINK	B
WHERE	A	•CODE =	B.S
AND	B.	STYPE =	2::：
AND	B.	STATUS =	=1
AND	C	DATE >=	TO
AR(SYSDATE - 3,	1YYYYMMDD');
因为该查询语句里都不再是固定值，所以不能改为等值连接。如果标 量子查询与主查询是不同的表，那么就要与前面一样，尝试用WITH语句更改。但这个查 询中因为是同一个表，则可以改用分析函数的方式。
我们可以先分析一下标量子查询中的条件“ BETWEEN TO_CHAR (TO_DATE (A.C—DATE，'YYYYMMDD’）- 180，YYYYMMDD’）AND A.C_DATE”。该句的意思就是查 询180天前到当前时间范围内的数据，这种查询用分析函数表示即可：
ORDER BY TO—DATE(C_DATE, 'YYYYMMDD1) RANGE BETWEEN 180 PRECEDING AND CURRENT ROW
那么标量子查询中的语句（以第一个标量为例）可以改为以下语句：
SUM(valuef2) over(PARTITION BY a.code, a.e_year ORDER BY to—date(c_date, •YYYYMMDD') RANGE BETWEEN 180 preceding AND CURRENT ROW)
而我们只需要最后三天的数据：AND C_DATE >= TO 一 CHAR(SYSDATE - 3，
• 275 •
Oracle查询优化改写技巧*5案例
•YYYYMMDD’)，那么可以再加上case when语句来只对后三天的数据进行处理:
CASE WHEN a.c一date >= to_char(SYSDATE - 3, 'YYYYMMDD1) THEN SUM(valuef2) over(PARTITION BY a.code, a.e_year ORDER BY to一date(c_date, * YYYYMMDD *) RANGE BETWEEN 180 preceding AND CURRENT ROW) END
同样，主查询的数据需要返回180+3天内的数据，得到分析函数的结果后再过滤：
SELECT A.*, •
B.SNAME AS SNAME,
TO—CHAR(SYSDATE, •YYYYMMDD*) AS CREATETIME,
TO_CHAR(SYSDATE, 1YYYYMMDD *) AS UPDATETIME
FROM (SELECT A.CODE AS CODE,
A.M_CODE AS M一CODE,
A.STKTYPE AS F—STYPE,
A.E_YEAR AS E_YEAR,
A.C_DATE AS C_DATEf
CASE
WHEN A.C_DATE >= TO一CHAR(SYSDATE	一 3, •YYYYMMDD*) THEN
SUM(VALUEF2)
OVER(PARTITION BY A.CODE,
A.E_YEAR ORDER BY TO_DATE(C	一DATE, 'YYYYMMDD1)
RANGE BETWEEN 180 PRECEDING	AND CURRENT ROW)
END AS F70115_70011,
CASE
WHEN A.C一DATE >= TO_CHAR(SYSDATE	-3, 'YYYYMMDD *) THEN
SUM(VALUEFl)
OVER(PARTITION BY A.CODE,
A.E_YEAR ORDER BY TO_DATE(C_	_DATE, * YYYYMMDDr)
RANGE BETWEEN 180 PRECEDING	AND CURRENT ROW)
END AS F70104_70011,
CASE
WHEN A.C_DATE >= TO—CHAR(SYSDATE	-3, 'YYYYMMDD') THEN
SUM(VALUEF6)
OVER(PARTITION BY A.CODE,
A.E_YEAR ORDER BY TO_DATE(C_	_DATE, 'YYYYMMDD1)
RANGE BETWEEN 180 PRECEDING	AND CURRENT ROW)
END AS F70126_70011,
• 276 •
第14章改写调优案例分享
INNER
WHERE
AND
AND
CASE
WHEN A.C_DATE >= TO一CHAR(SYSDATE - 3,	1YYYYMMDD') THEN
SUM(VALUEF5)
OVER(PARTITION BY A.CODE,
A.E_YEAR ORDER BY TO一DATE(C—DATE, 1YYYYMMDD') RANGE BETWEEN 180 PRECEDING AND CURRENT ROW)
END AS F70131一70011,
AS F—UNIT
FROM A
WHERE A.C_DATE >= TO_CHAR(SYSDATE - 3 - 180,	'YYYYMMDD1)
)A
JOIN B0LINK B ON (A.CODE = B.SCODE)
B.STYPE = 2
B.STATUS = 1
A.C DATE >= TO CHAR(SYSDATE - 3, 'YYYYMMDD1);
下图是改后的效果反馈：
有教綠11:46:51 还有间駆5 ?
1:50:14
问題	数据没问題
有教无类11:51:13
有教无类11:51:23 对效率有作用没?
1:51:34
速度有点吓倒我了呀跑了 22308条记录采用了 28s 我的蹕个毎天尊是半个小时左右
14.12用分析函数优化标量子查询（四）
下面这个子查询不是累加，而且两个标量子查询中访问的表也有区别:
WITH UP	AS
(SELECT	MAX(BDSJ) UTIME, PPC.JG
FROM	PPC, PP
WHERE	PPC.PID = PP.	,PKID
AND	PPC.TZLX IN (	•lb*, •dr*, 'jy»)
GROUP	BY PPC.JG),
AP AS
(SELECT	MAX(SYSTIME)	SYSTIME, ORGID FROM NPS GROUP BY ORGID)
• 277 •
Oracle査询优化改写技巧与案例
SELECT DISTINCT PPC.JG ORGID,
(SELECT NAME FROM QHDM WHERE VALUE = O.QHDM) QHDM, O.ORGNAME,
(SELECT COUNT(*)
FROM PPC, PP WHERE PPC.FID = PP.PKID AND PPC.JG = O.ORGID AND PPC.TZLX IN ( 'lb',	’dr’）
AND PPC.BDS.J >= '2013-0 9-26 00:00:00'
AND PPC.BDSJ > NVL(AP.SYST 工 ME, '1600-09-14 00:00:00') ) LB,
(SELECT	COUNT{*)
FROM	PPC,	PP, SPXX
WHERE	PPC.	PID =	PP	.PKID
AND	SPXX	.EVENTID		=PPC.EVENTID
AND	SPXX	.XM =：	PP.	,XM
AND	SPXX	.SFZH =	=I	PP.SFZH
AND	UPPER(SPXX		•JYBIAO) <> 1LTRY1
AND	PPC.	JG = O	■ORGID
AND	PPC.	TZLX =	'jy'
AND	PPC.	BDSJ >	_ t	f2013-0 9-26 00:00:00
AND PPC.BDSJ> NVL(AP.SYSTIME, '1600-09-14 00:00:00')) JY, UP.UTIME,
O.QFBS,
'.T CONTEXT,
(SELECT ORGNAME FROM OO WHERE ORGID = O.PORGID) PORGNAME,
O.PORGID
FROM PPC
LEFT JOIN PP ON PPC,PID = PIVPKID
LEFT JOIN (SELECT * FROM OO WHERE YOUXIAO = ' 1 ' ) O ON 〇，〇RGID = PPC. JG LEFT JOIN UF ON UP.PPC.JG = 0.ORGID LEFT JOIN AP ON AP.ORGID = O.ORGID WHERE PPC.TZLX IN ('lb', 'dr',	1jyf)
AND NVL(AP.SYSTIME, '1600-09-14 00:00:00') < UP.UTIME AND PPC.BDSJ >= ’2013-09-26 00:00:00';
我们来分析一下这个查询。
①第二个子查询多了表“SPXX”。
②关联条件中有不等条件：“AND	PPC.BDSJ > NVL(AP.SYSTIME, '1600-09-14 oo:oo:o(y)”，这个比较值是两个不同的字段。
• 278 •
第14章改写调优案例分享
该査询也可以用分析函数优化，只是需要多一些操作。
①在	WHERE 子句里有条件 “AND NVL(AP.SYSTIME, '1600-09-14 00:00:00') < UP.UTIME”，所以结果集中“UP”不会为空，那么“UP”及相关的“O”都可以改为INNER JOIN：
FROM PPC
INNER JOIN (SELECT * FROM 00 WHERE YOUXIAO = ' 1 * ) 0 ON O.ORGID = PPC. JG INNER JOIN UP ON UP.PPC.JG = PPC.JG
②因主表中己有“PPC”和表“PP”，两个标量子查询都有大部分条件与主查询一样：
SELECT COUNT(*)
FROM ppcf pp WHERE ppc.pid = pp.pkid AND ppc.jg = o.orgid
AND ppc.bdsj >= '2013-09-26 00:00:00'
所以，第一个标量子査询可以改用分析函数直接由主表中的结果集返回所需数据，里 面与主查询中不同的条件放在C.ASE WHEN中：
COUNT(CASE
WHEN ppc.bdsj > nvl(ap.systime, '1600-09-14 00:00:00') AND ppc.tzlx IN (1 lb1f 1 dr') AND pp.pkid IS NOT NULL THEN ppc.jg
END) over(PARTITION BY ppc.jg) AS lb
③第二个标量子查询多了表SPXX,那么第二个标量子查询要想改为LEFT	JOIN, 就需要先把SPXX放在主查询中，加入的时候同样要用LEFT JOIN:
FROM	PPC
LEFT	JOIN PP ON PPC.PID = PP.PKID
LEFT	JOIN SPXX ON (SPXX.EVENTID = PPC.EVENTID AND SPXX.XM =	=PP.XM AND
SPXX.SFZH =	PP.SFZH)
这样第二个标量子查询就可以用与前面同样的方式改为分析函数，注意，要把不同的 条件放入CASE WHEN：
COUNT(CASE
WHEN PPC.BDSJ > NVL(AP.SYSTIMEf '1600-09-14 00:00:00*) AND
PPC.TZLX = 1jy* AND AND UPPER(SPXX.JYBIAO) <> 1LTRY* THEN PPC.JG
END) OVER(PARTITION BY PPC.JG) AS JY
• 279 •
Oracle查询优化改写技巧与案例
④主查询中多出的条件或范围不一致的条件要在分析函数返回值之后再执行：
WITH UP AS (SELECT MAX(BDSJ) UTIME, PPC.JG FROM PPC, PP WHERE PPC.PID = PP.PKID
AND PPC.TZLX IN ( 'lb',	1	dr', rjy*)
GROUP BY PPC.JG),
AP AS
(SELECT MAX(SYSTIME) SYSTIME, ORGID FROM NPS GROUP BY ORGID)r XO AS
(SELECT DISTINCT PPC.JG ORGID,
(SELECT NAME FROM QHDM WHERE VALUE = 0.QHDM) QHDM, O.ORGNAME,
COUNT(CASE
WHEN PPC.BDSJ > NVL(AP.SYSTIME,	'1600-09-14
00:00:00') AND
PPC.TZLX IN ('lb', 1 dr 1 ) AND PP. PKID IS NOT NULL
THEN
PPC.JG
END) OVER(PARTITION BY PPC.JG) AS LB,
COUNT(CASE
WHEN PPC.BDSJ > NVL(AP.SYSTIME,	T1600-09-14
00:00:00') AND
PPC.TZLX = ' jy' AND AND UPPER (SPXX • JYBIAC0 <>
1LTRY1 THEN
PPC.JG
END) OVER(PARTITION BY PPC.JG) AS JY,
UP.UTIME,
0.QFBS,
1.'	CONTEXT,
(SELECT ORGNAME FROM OO WHERE ORGID = O.PORGID) PORGNAME, O.PORGID,
AP.SYSTIME
FROM	PPC
INNER	JOIN	(SELECT * FROM OO WHERE YOUXIAO = 'I') O			ON〇.	ORGID =	PPC.JG
INNER	JOIN	UP	ON	UP,PPC.JG = PPC.JG
LEFT	JOIN	AP	ON	AP.ORGID = PPC.JG
LEFT	JOIN	PP	ON	PPC.PID- PP.PKID
LEFT	JOIN	SPXX ON (SPXX.EVENTID = PPC.EVENTID AND			SPXX,	•XM = PP.	.XM AND
,SFZH =	PP.SFZH)
• 280 •
第14章改写调优案例分享
WHERE	PPC.TZLX IN (	：'lb', 'dr1
-	- AND NVL(AP	.SYSTIME,	•1600-09-14	00:00:00')	< UP.UTIME
AND	PPC.BDSJ >= 1	2013-09-26	00:00:00')
SELECT *	FROM X0
WHERE	NVL(SYSTIME,	'1600-09-14 00:00:00*		)< UTIME
到此，这个查询就改完了。
14.13	用 MERGE 改写优化 UPDATE
我们来生成一些模拟数据如下：
DROP TABLE t一objects PURGE;
DROP TABLE t一tables PURGE;
CREATE TABLE t_objects AS SELECT * FROM dba_objects;
CREATE TABLE t_tables AS SELECT * FROM dba_tables;
ALTER TABLE t_objects ADD tablespaee_name VARCHAR2(30);
现在需要把 t_tables.tablespace_name 同步至 t_objects.tablespace_name, —般常用的 是 UPDATE：
UPDATE t—objects o
SET o.tablespace_name =
(SELECT t.tablespace_name FROM t一tables t WHERE t.owner = o.owner AND t.table_narae = o.object_name)
WHERE EXISTS (SELECT t.tablespace_name FROM t__tables t WHERE t.owner = o.owner AND t.table_name = o.obj ect_name);
注意上面的写法：两个子查询要保持一致，这样不会更新范围之外的数据，也容易维 护。 第4章己介绍过：像这种关联更新一般要改写为MERGE,因为UPDATE语句有两次 扫描t—tables表，而且其中一次相当于是标量子査询，见下面的PLAN:
• 281 •
Oracle查询优化改写技巧与案例
1 Id	I Operation I	Name		Rows	Bytes |	Cost (%CPU)|	Time
I 0	1 CTPDATE SIATZMENT			59306	77.60KI	1898K (4)|	06:19:39
| 1	| UPDATE ,		_OBJECTS		微	\
2	| HASH JOIN RIGHT SEHI			59306	7760KI	37B (1) |	00:00:05
I 3.	| TABLE ACCESS FULL	1 T	TABLE5	328S	109KI	31 (0) |	00:00:01
| 4	| TABLE ACCESS FULL	T:	C5.7ECT5	81897	7997KI	347 (1) |	00：00i05
里* 5	| TABLE ACCESS FULL	t"	'tables	X	51 I	31 (0) I	00:00:01
Predicate Infonnflcion -(idexicified by operation id):
2	- acceaa ("T".. "0WNER"="0" . "OWNER" AND
"‘T»* • "TABLE_NAMEn=”0" • "OBJECT_NAMEn)
5 - filter ("T**. wOWNER^=：Bi AND "T" . WTAKJ：_NAME"=:B2)
fote	,
-dynaroic sampling used for this stacemenc (level*»2)
统计信息'
k, 0	recursive calls
31_71	db blocJc gees '
30284S .	consistent gezs
1343	physical reads 、
934284	redo size
684 •	bytes sent vxa SQL*Net co client
875	bytes received vie SQL*Nec frcm client
3	3QL*Ner rouHdtrips to/frora client
1	aorta (memory)
0	aorrs (disk)
3086	rows processed
改写方法如下：
①目标表(t_objects	o)放在MERGE INTO后面。
②源表(t_tables	t)放在USING后面。
③关联条件(t.owner	= o.owner AND t.table name = o.object_name)放在 on 后面，注意 关联条件要放在括号里，否则会报错。
④更新子句(SET	o.tablespace_name = t.tablespace_name)» 注意：只能更新目标表， 所以o.tablespace_name —定要放在前面。
MERGE INTO t—objects o
USING t一tables t ON (t.owner = o.owner AND t.table_name = o.object_name) WHEN MATCHED THEN UPDATE SET o.tablespace_name = t.tablespace_name;
改写后，去掉了 “标量子查询”，对t tables只扫描了一次:
第14章改写调优案例分享
Id	^Operaclon	i Name	Rows	Bytea |TenpSpci	Cost	(%CPO)|	rime
0 1 2	MERGE .STATEMENT HERGE	1 I T_OBJZCTS 丨	6626	22坪丨 | 1 1 1 1	1422	(It	oo	00(16 00：1S
*. 3	HA3r；	1 .门 _	662C	4B«5K| 1€96K|	•1422	at	OG
4	. TABLE ACCESS	FULL| T TA3LES	3269	1657K|	31	(01	00	00:01
5 •	TABUE ACCESS	HILLI T_OBJECTS	S1S97	1	347	(1)	00	00s05
(idencifxed by operation id):
3 - acces，f**T-ATO "T" .TAB1*_
dyoai&ic saroplinc used fct cliis acatMtenx (level-2)
0	recursive .calia 3173 db black ocza 1349 consistent, cecs 130 physical reads
834344 cedo size
685 , bycea 6eat via 3QI."Nec to cli.enc "^51 bytes received via SQL*Net from cli.anc
3	SQL*Ne: roundcrxps co/from clxen'c
1	soxcs (memazy)	•
'	0	sorta (dislc)
3066 rows processed
14.14	用MERGE改写有聚合操作的UPDATE (_)
前面己介绍过用MERGE改写简单的语句，那么如果UPDATE中有聚合操作呢？比如
下面的语句就有DISTINCT:
UPDATE f3111 SET coll =
(SELECT DISTINCT col2 FROM f3112 WHERE col3 = col4
AND nchar col = col6)
WHERE AND AND AND
nchar_col=col6)' AND col9 =
TRIM(nchar_col)= col7 = *WXf col8 = ’CD1999* coll <>	'	(SELECT
0;
'CDIO1
DISTINCT col2 FROM F3112 WHERE col3=col4 AND
首先需要整理这个语句，因为它的问题有很多：
①	“AND coll <> '(SELECT DISTINCT co[2 FROM F3112 WHERE col3=coi4 AND nChar_C0l=C0丨6)’”这条语句写错了，后面不该有单引号，这个语句的本义应该是：相同值
283
Oracle查询优化改写技巧与案例
不再更新。
②条件“TRIM(nChar_C0l) =’CD10'”中用了函数，就不能用普通索引，看了一下网 友的表结构，是字段类型为nchar的原因导致的。这两个地方都要改。
那么上面的语句就可以修正为：
UPDATE	f3111
SET	coll =
	(SELECT	DISTINCT col2
	FROM	f311 习
	WHERE	col3 = co14
	AND	nchar col = col6)
WHERE	nchar	col = f CD10
AND	col?=	fWXf
AND	co 18 =	,CD1999I
AND coll <> (SELECT DISTINCT col 2 FROM F3.112 WHERE col3=col4 AND nchar_col=col$)
AND col9 = 0;
似乎下一步就是改写了，但改写的时候又发现：“col3”与“col4”中，哪一个是f3112 的列，哪个是filll的列？
经过确认：0112所用到的三.个字段为col2、col3, col6,通过这个案例再次提醒读者， 在写语句时，一定要注意使用前缀来增加语句的可读性，并减少错误。
①与有聚合函数的标量子查询一样，改写时需要把关联列放在group	by后面。
②因为本例是distinct	col2,所以就把col2—起放在了 group后面。
③关联条件(b.col3	= a.col4 AND a.nchar col = b.col6)放在 using 后面。
MERGE	INTO (SELECT a.coll,	,a.co14, a.nchar_col
	FROM f3111 a
	WHERE a.nchar col = *		CD 10，
	AND a.col7 =	'WX'
	AND a.col8 =	'001999*
	AND a.col9 =	Q) a
USING	(SELECT b.col2, b.col3, b.		,col 6
	FROM f3112 b
	GROUP BY b.col2, b.	col3.	b.col6) b
ON (b,	.col3 = a.col4 AND a	•nchar	col = b.col6)
WHEN MATCHED THEN
UPDATE SET a.coll = to char(b.			col 2)
WHERE	a.coll <> to_char(b	•col2);
• 284 •
第14章改写调优案例分享
对于本节讲到的函数问题，很多人认为加一个函数索引就可以。我们通过例子来看一 下是不是一定可行，通过emp新建一个emp2表，并且在hiredate上增加函数索引：
CREATE TABLE emp2 AS SELECT * FROM scott.emp;
CREATE INDEX idx_emp2 ON emp2(to_char(hiredate,'yyyy-mm-dd'));
SQL>- SELECT * FBOM 3s^p2 WHERE co_char (hxreclace, 'yyyy-	-nmi-dd*) ® '
已迭择i行* • • *			*
执行计切 、	. r
Plan hash value: 4159171873 »
i Id l Operaclcn . I Nanie 1 Raws ■ Byuss 1		| Goal； (%CPO> 1	Tuae I
) 0 丨 SELECT STATEMErTT | ' | 1 I TABLE ACCESS BY INDEX BOWIDI EMP2 | !• 2 t I1JBEX RANGE SZSS \ IDX SMP2 |	i 1 94 丨 11 94 1 11	1 2 W 1 1 2 {0)) 1 (0> 1	*00:00102, • 00:00:01 J 00:00:02； |
Ered!case Inforstacion (idanctfied fcy operation id):
2 - access (TO CHARlIHTERWAL F0UCTIC5S 4»3IREDAXE"),		1 t =•* 1931,-06-09	'1
这看上去没问题，我们改动一个小地方再执行一下:
SQL> SELECT • FROM emp2 WHERE to_char(hiredate,'YYTf-	-MM-DD*) = _	15^1-0€-09'；
已迭择1行’， •
执行计_ *
Plan iiash vatlue: 2941272003
| Id 1 Operation | Name | Rows | Byres | Cose (%CPtJf I		Time • |
j 0 重 SELECT STATEMENT { \ 1 | 87 | !• 1 | TABLE &CCE33 FULL1 EHP2 \ 1 [ ' 87 | *	3 (0) 1 3 (0) |	00:00:02 | 00:00:01 |
Prec^icace Infontacion (Identified by operation Id) !
1 - fiitesaO—CaARdNTZRHAL—FONCTIONrfilREDATE”，1 06:09.*)	lyyYY-MM-DD1
可以看到，仅仅因为格式符大小写不一样，我们建立的函数索引就失效。你能保证应 用程序里的语句时刻会注意大小写？
可见，我们在不讨论维护成本的情况下，函数索引确认可行，但要注意，函数索引可 能会出现失效的情况。
Oracle查询优化改写技巧与案例
14.15	用MERGE改写有聚合操作的UPDATE (二）
改写语句时不仅要熟悉改写思路及调优方法，还要面对各种稀奇古怪的写法，例如， 下面的语句：
UPDATE g SET coll
(SELECT \ntL3Y3.\	raa concar(col2 丨丨 *-•	|| nvl(col3, col4))
FROM k
WHERE 'RS* |	k.colS = g.col€)|
WHERE g.col9 = '10A*
(SELECT	DISTINCT		a.col6
FROM	g	a
JOIN	b
ON	a	co!7 =	b.col8
JOIN	k	c
ON	b	id = c	colS
WHERE	a	co!9 =	•10A');
一般多表关联的UPDATE语句中，SET后面的子查询（见上面线框内的部分）应该 与WHERE后面的子查询一致，这是为了保证更改的范围一致，不会把范围之外的数据更 新成空值（见4.6节中的解析）。经询问，本例的范围确实一致，不过用的是业务逻辑，也 就是这两个子查询的范围在业务上是一致的。但是这种写法不便于维护和更改，我们先修 正一下：
UPDATE g
SET coll =
(SELECT to_char(wmsys.wm_concat(c.col2 ||	，-•	丨丨	nvl(c.col3,
c.col4)))
FROM	g	a
JOIN	b	ON a.	col7 =		b.	col8
JOIN	k	g ON	b	• id =	c.	co 15
WHERE	a	• col9	=	*10A
AND	g-	col6	=	a.col6)
g.col9	=	'10A	i
EXISTS	(SELECT			NULL
FROM	g	a
JOIN	b	ON a.	col7 =		b.	col8
JOIN	k	e ON	b	.id =	c •	col5
WHERE	a	• col9	-	'10A'	»
AND	g.	col 6	-	a.col6)		r
• 286 •
第14章改写调优案例分享
现在的语句就是常用的写法，这里面有一个wmsys.wm_concat,这是一个聚合函数， 作用是把同一组里的字符串合并在一起。 所以同14.14节一样，需要把关联列放在GROUP BY后面：
SELECT a.col6f
wmsys.wm_concat(c.col2 ||	，-•	|| nvl(c.col3, c.co14)) AS coll
FROM	g	a
JOIN	b	ON a.	,col7 = b.	.col8
JOIN	k	c ON	b. id = c.	,col5
WHERE	a.	_ col9	=UOA'
GROUP	BY a.col6
再把上面的语句放入USING子句里就可以:
MERGE INTO g
USING (SELECT		a. co!6.
wmsys.wm concat(c.col2 | | 1 - * |					I nvl(c.col3, c.col4)) AS coll
FROM	g	a
JOIN	b	ON a.col7 =	b.	col8
JOIN	k	c ON b.id =	c •	col 5
WHERE	a,	.col9 = 110A1	t
GROUP	BY a.col6) x
ON (x.col6 =	g	.col6)
WHEN MATCHED	THEN
UPDATE SET	g.	.coll = x.coll		WHERE g.col9 :	='10A'
14.16	用MERGE改写UPDATE之多个子查询（一）
UPDATE中有单个子查询的知识已介绍过，若有多个子查询呢？例如，下列语句:
UPDATE a
SET (a.op_d_id, a•op_work—no, a.a_date, a.c_date) (SELECT d_id, a_person, a_date, c_date FROM xl
WHERE xl.r_number = a.r_number),
a.s_date =
(SELECT s—date FROM x2 WHERE x2.u_id = a.u_id AND x2.fee date = :b4
• 287 •
Oracle查询优化改写技巧与案例
AND rownum = 1)
WHERE city_code = :b3
AND MOD(a.u_id^ :b2) = :bl - 1
如果是标量子查询，依次在后面用LEFT JO丨N就可以，但MERGE语句后面就只有一 个usingO,显然这个思路不行。
我们可用下面的方法来处理：
①可以把主表a—起放在USING后面，这样就可以当作普通的标量子査询来修改。
②既然把表a放在了	USING中，那么直接改用a.rewid作为关联条件就可以。
③因为原查询中没有EXISTS子句来限定范围，所以改写仍然要用LEFT	JOIN。
MERGE INTO a
USING (SELECT a.rowid AS rid.
xl. d_idf
xl.a_person,
xl.a一date.
xl.c date.
x2.s_date
FROM a
LEFT JOIN xl ON (xl.r_number :	=a,	.r number)
LEFT JOIN (SELECT MAX(s_date)	AS	s_date, x2.u_id
FROM x2
WHERE x2.fee date =	:b4
GROUP BY x2.u_id) x2	ON	(x2.u_id = a.u_id)
WHERE a.city_code = :b3
AND MOD(a.u id, :b2) = :bl -	1)	b ON (b.rid = a.rowid)
WHEN MATCHED THEN
UPDATE
SET a.op_d_id = b.d一id,
a.op_work_no = b.a_person,
a. a date = b. a date,
a. c_date - b.c一date,
a . s_date = b. s_date
14.17	用MERGE改写UPDATE之多个子查询（二）
本例也是一个UPDATE语句，据说要20多分钟才能完成查询操作。
• 288 •
第14章改写调优案例分享
UPDATE tablel	f
SET f.累计金额1 =
(SELECT	nvl (SUM(nvl (b.金额 1, 0)),	0)
FROM	tablel b
WHERE	b.会计期间<=f.会计期间
AND	b.公司=f.公司
AND	b.部门- f.部门
AND	b.业务- f.业务
AND	b.currency_id = f.currency—id
AND	substr (b •会计期间，1, 4)=	substr(f,	.会计期间，1,	4)),
f.金额2	=
(SELECT	nvl (SUM(nvl (e•金额 1, 0)),	0)
FROM	table2 e
WHERE	e.会计期间=f.会计期间
AND	e.公司=f.公司			、
AND	e.部门=f.部门
AND	e.业务=f.业务）,
f.累计金额2 =
(SELECT	nvl (SUM (nvl (e.金额 1, 0> ),	0)
FROM	table2 e
WHERE	e.会计期间<=f.会计期间
AND	substr (e •会计期间，1, 4)=	substr(f,	.会计期间，1,	4)
AND	e.公司=f.公司
AND	e.部门=f.部门
AND	e •业务=f •业务）
WHERE substr (f •会计期间，lr 4) = extract (YEAR FROM SYSDATE)				7
这个语句比14.16节的例子要复杂得多，其中有自关联取累加数据（累计金额丨），还 有两次访问表table2，我们可以沿用14.16节的方法：把主表与子查询里的语句一起放在 USING子句里，这样容易整理。
①第一个子查询除了等值条件外，还有一个条件“b.会计期间<=f.会计期间”，所 以说这是一个累加，可以用分析函数来处理。
②第二个子查询中有聚合函数，那就要先把关联条件放入GROUP	BY中，分组汇总 后再左联。
③第三个子查询与第二个类似，只是等值条件改成了 “e.会计期间<=f.会计期间”, 所以这又是一个累加，同样放入分析函数里就可以。
第一个子查询直接使用累加的方法，同时把主查询的条件加进来：
• 289 •
Oracle査询优化改写技巧与案例
SELECT b.rowid AS rid,
SUM(b.金额 1> over (PARTITION BY b.公司，b•部门，b•业务，b • currency__id ORDER BY b.会计期间）AS累计金额1 FROM tablei b
WHERE substr (b•会计期间，1, 4) = extract (YEAR FROM SYSDATE)
第二个子查询中，把关联列放在SELECT和GROUP BY后面：
SELECT e.公司，e.部门，e.业务，e.会计期间，SUM(金额1> AS金额2
FROM table2 e
WHERE substr (e.会计期间，1, 4) = extract (YEAR FROM SYSDATE)
GROUP BY e.公司，e.部门，e.业务，e.会计期间；
对于上面的数据，再用分析函数累加，就可以得到第三个子查询的数据，这样就少扫 描了一次 table2:
SELECT e •公司， e.部门， e.业务， e.会计期间， 6 .金额2 r
SUM (金额 2> over (PARTITION BY e •公司，e •部门，e.业务 ORDER BY e •会计 期间）AS累计金额2
FROM (SELECT e •公司，e •部门，e •业务，e •会计期间，SUM (金额1> AS金额2 FROM table2 e
WHERE substr (e •会计期间，1, 4) = extract (YEAR FROM SYSDATE)
GROUP BY e •公司，e •部门，e •业务，e •会计期间）e
再用第一个子查询来关联上面这个结果集即可：
MERGE INTO tablel f
USING (SELECT b.rowid AS rid,
SUM (b.金额 1) over (PARTITION BY b•公司，b•部门，b•业务，
b.	currency—id ORDER BY b.会计期间> AS 累计金额 1, e.金额2t e.累计金额2 FROM tablel b LEFT JOIN (SELECT e •公司， e.部门， e.业务， e.会计期间， e.金额2,
SUM(金额 2> over (PARTITION BY e •公司，e.部门，e•业务
• 290 •
第14章改写调优案例分享
ORDER BY e.会计期间）AS累计金额2
FROM (SELECT e •公司，
e.部门，
e.业务，
e.会计期间，
SUM (金额1) AS金额	2
FROM table2 e
WHERE substr (e.会计期间,	1,	4) = extract (YEAR FROM
SYSDATE)
GROUP BY e.公司，e.部门,	,e	.业务，e.	会计期间）e) e
ON (e •会计期间=b •会计期间AND e •公司=	b.	公司AND	e.部门=b.部门
AND e•业务=b•业务）
WHERE substr (b •会计期间，1, 4) = extract	(YEAR FROM		SYSDATE)) b ON
(f.rowid = b.rid)
WHEN MATCHED THEN
UPDATE
SET f.累计金额1 = nvl (b.累计金额1, 0) f
f.金额 2 = nvl (b.金额 2, 0),
f.累计金额2 = nvl (b.累计金额2, 0)
完成操作后，看看网友反馈的效果，如下图所示：
4:05:00
教主，大柰拜你了 •原来20多分钟.现在不到1秒
有教无类14:06:17 动.
14:06:32 挪船他了
SUB 14:06:59
这个是个备份表•让他和正式隶比对一下
有孰蚊14:47:43
14:47:58
完全糊
:48:04
太<SLK你了
14.18	UPDATE改写为MERGE时遇到的问题
查询改写一定要注意逻辑正确，而且还要核对结果，笔者就遇到一次:
• 291 •
Oracle查询优化改写技巧与案例
UPDATE mwm
SET mwm.qtyl	=nvl((SELECT SUM(nvl(mws•qty, 0)) FROM mws mws
	WHERE	mws.oid	=mwm.oid
	AND	mws.wid	-mwm.wid
	AND 0)	mws.seq	<=mwm.out_seq),
这个语句看上去很简单，于是顺手改成如下语句:
MERGE INTO mwm
USING (SELECT SUM(qty)	over(PARTITION BY wid,	OID ORDER BY	seq) AS qty,
wid,
OID,
seq
FROM mws) mws
ON (mws . oid { + ) = mwm.	.oid AND mws . wid ( + )=：	mwm.wid AND	mws«seq<+)=
mwm.out_seq)
WHEN MATCHED THEN
UPDATE SET mwm.qtyl	=nvl(mws.qty, 0);
然后，就出现了大的问题。
或许有人已看出来，，这个查询里 SUM(qty) over(PARTITION BY wid, OID ORDER BY seq) AS qty是分析函数的一个累加，把当前分组排序后的数据从第一行开始累加至当前行 (见6.2节的介绍）。而原语句的对应条件是“mws.seq <= mwm.out_seq”，要注意这是两个 不同表中的字段，这样更改就要求有一个前提：“mws.seq”与“mwm.out_seq”要有一 一对应的值才行，比如：
CREATE	TABLE	empl	AS	SELECT	* FROM	scott.emp	WHERE	deptno =	10;
CREATE	TABLE	emp 2	AS	SELECT	* FROM	scott.emp	WHERE	deptno =	10;
• 292 •
第14章改写调优案例分享
这时UPDATE语句的结果如下:
UPDATE	empl
SET	empl.sal =	nvl((SELECT SUM(nvl(emp2.sal, 0)) FROM emp2 WHERE emp2.empno <= empl.empno), 0);
SELECT	empno,sal	FROM empl ORDER BY 1;
EMPNO	SAL
7782	2450.00
7839	7450.00
7934	8750.00
3 rows	selected
SQL〉 rollback;
Rollback complete
改为累加结果也一样:
SELECT	a.empno,	a.sal, b.sum一sal
FROM	empl a
LEFT	JOIN (SELECT b.empno.
		SUM (sal) over (PARTITION BY b . deptno ORDER BY b • empno) AS
sum一sal
	FROM emp2 b) b
ON	(b.empno :	=a.empno)
ORDER	BY 1;
EMPNO	SAL	SUM一SAL
7782	2450.00	2450
7839	5000.00	7450
7934	1300.00	8750
3 rows	selected
但如果数据不一样呢？
UPDATE emp2 SET emp2.empno = emp2.empno - 1;
• 293 •
Oracle查询优化改写技巧*5案例
|SELECT empno FROM en^)l;
	迓SQL		Window • SELECT empno FROM
EMPNO」	SQL		Output | Statistics
7782 7839、			hELECT empno FROM emp2
7934 N			參 "■ ^等s眞
	、		WnoI V/^7781 7838
	i i	3	X7933
这时，UPDATE结果不变，而累加就没有数据了 :
EMPNO	SAL		SUM一SAL
7782	2450.	.00
7839	5000.	.00
7934	1300,	.00
3 rows selected
很不幸，本节开始介绍的这个UPDATE语句就有部分数据属于这种情况，所以用累 加的方法不可行。 对于这种有“不等”连接的情况，只有把主表放在USING子句中才可以：
MERGE INTO mwm
USING (SELECT mwm.rowid AS rid, SUM(mws.qty) AS qty FROM mwm LEFT JOIN mws
ON (mws.oid = mwm.oid AND mws.wid = mwm.wid AND mws.seq <= mwm, out__seq)	%
GROUP BY mwm.rowid) mws ON (mws.rid = mwm.rowid)
WHEN MATCHED THEN
UPDATE SET mwm.qty1 = nvl(mws.qty, 0);
14.19整理优化分页语句
网友说有一个语句查询需要1秒多，希望能优化。于是让网友先把语句发过来，一看 到语句，笔者就惊呆了：
SELECT *
FROM (SELECT a.*, ROWNUM NUM
• 294 •
第14章改写调优案例分享
FROM (SELECT *
FROM b WHERE 1=1
AND type = 110 *
AND s_cd = *1000'
AND name LIKE 1%xxx%f ORDER BY (SELECT NVL(TO—NUMBER(REPLACE(TRANSLATE(des, REPLACE(TRANSLATE(des, * 0123456789•, '##########*), *#•, ' ' ) , RPAD('#1# 20, •#M), •#,, 1，））, ?0')
FROM b—PRICE B WHERE max_price = * 11 AND B.id = b.id), name) a)
WHERE NUM > 1 AND NUM <-20
这个ORDER BY需要全表扫描才能得到所需数据，而且函数嵌套了多层，不好处理。 因为上面这个替换语句的目的是只保留字符串中的数字，于是笔者给他提供了一个正则： ORDER BY regexp_replace(des, 1[^0-9]',	11)
这个语句确认结果后，把语句改成了 10.1节中讲过的样式：
SELECT *
FROM (SELECT a.rownum num
(SELECT		a. *
FROM	b	a
INNER	JOIN b_		一price b ON (b.id = a.
WHERE	1	=1
AND	b	•max— price = '1'
AND	a	■type	=，10,
AND	a	.s_cd	=11000'
AND	a.	.name	LIKE '%xxx% *
ORDER	BY regexp一replace(des, •[々0-
WHERE num <= 20) WHERE num > 1;
注意上面两个分页条件的位置，这样更改后，把过滤列与regexp_replace(des，'[A0-9]',") 一起放在组合索引里，优化就到此结束。
Oracle查询优化改写技巧Q案例
14.20让分页语句走正确的PLAN
很多人优化分页语句时都没有搞清楚分页语句的一个STOPKEY特性，例如，下面的 语句：
SELECT *
FROM (SELECT rownum r, t.*
FROM (SELECT /*+ use_hash(t,r)*/
t.rollno, t.bizfileno, t.id regiid, s.status FROM t
LEFT	JOIN s ON s.regiid = t.id
INNER	JOIN r ON r.docid = t.id AND r.status	=3701
WHERE	t.rollno LIKE 'S10%r
AND	t.status NOT IN (-1, -2, -3, -4r 1001,	1301,
ORDER	BY t.rollno DESC) t
rownum	<=20)
WHERE r > 10；
这个语句原来没有use_hash的提示，是网友优化时加上的，他使用HASH JOIN并 增加索引后，速度减少到两秒，而原来的执行时间为十秒。
但是这个语句仍然没有正确地优化，因为这是一个分页语句，而分页语句有一个特性： 当过滤后的行达到需要的条数（这里是20)后，就会停止提取数据。所以，虽然t与s都 是900多万行的大表，这里仍然不应该用HASH JOIN。或许很多人在网上都看到过，分 页语句要用first_rows，而first—rows的作用就是让表间的关联走NESTED LOOP (嵌套循 环），于是给他改了提示：
SELECT *
FROM (SELECT rownum r, t.*
FROM (SELECT /*+ use_nl(t,s) use_nl(t,r) leading(t,r,s) */ t.rollno, t.bizfileno, t.id regiid, s.status FROM t LEFT JOIN s
ON s.regiid = t.id INNER JOIN r
ON r.docid = t.id AND r.status = 3701 WHERE t.rollno LIKE ,S10%1
AND t.status NOT IN (-1, -2, -3, -4f 1001, 1301, 1005)
• 296 •
第14章改写调优案例分享
ORDER BY t.rollno DESC) t
WHERE rownum <= 20)
WHERE r > 10;
确认t(r0lln0，StatUS)上有索引后，让网友测试，测试后的结果令他很满意，如下图所
示：
	^^15:01:29
	眭
	秒出结果
	^f|5：01：40
	师傅大神！ !
	5:03:25
	这.。•瑪堡了
14.21 去掉分页查询中的DISTINCT
先看优化的语句，模拟数据环境如下：
DROP TABLE t_objects PURGE;
DROP TABLE t—columns PURGE
DROP TABLE t_tables PURGE;
DROP TABLE t_users PURGE;
CREATE TABLE t objects AS SELECT t2 .user_id, tl • ★ FROM dba—objects tl INNER
JOIN All_Users t2 ON t2.username = tl.OWNER;
CREATE TABLE t columns AS
SELECT b.object_id.
tc.owner,
tc•table_name,
tc.column_name.
tc•data_type,
tc.data_type_mod,
tc.data_t ype_owne r,
tc.data_length
FROM all tab columns tc
INNER JOIN t objects b ON (b.owner = tc.owner AND b.object name =
tc.table—name);
CREATE TABLE t_tables AS SELECT * FROM dba_tables;
• 297 •
Oracle査询优化改写技巧4案例
CREATE TABLE t_users AS SELECT ★ FROM all一users;
CREATE INDEX idx_t_tables ON t_tables(owner,table_name);
CREATE INDEX idx一t一columns ON t一columns(object—id,ownerrtable_name); CREATE INDEX idx_t_users ON t_users(user_id,username);
CREATE INDEX idx_t_objects ON t一objects(created DESC,user_id,object_id); 原语句及执行计划如下：
SELECT
FROM
tc.table name)
(SELECT a.*, r own urn rn FROM (SELECT DISTINCT o.object_id,
o	.owner, o•ob j ect_name, o.object_type, o. created, o. status FROM t_objects o
INNER JOIN t_columns tc ON (tc.object_id = o.object_id) INNER JOIN t一tables t ON (t. owner = tc. owner AND t. table一name
LEFT JOIN t一users tu ON (tu.user_id = o.user一id)
WHERE tu.username IN ('HR',	1 SCOTT1,	'OE','SYS1)
ORDER BY o.created DESC) a
WHERE rownum <= 5)
WHERE rn > 0;
SELECT ★ FROM TABLE(DBMS XPLAN.DISPLAY CURSOR(NULL,0,'iostats*))
Operation
SELECT STATEMENT VIETJ COUNT, STOP KEY VIEW
SORT UNIQUE STOPKEY HASH JOIN INDEX FAST FULL SCAN HASH JOIN HASH JOIN INDEX FULL SCAN TABLE ACCESS FULL INDEX FAST FULL SCAN
IDX T TABLES
IDX_.T_U.SEFS' T_pijECtS l5x T COLUMNS
我们知道，分页语句的PLAN中一般都有一个STOPKEY，这个关键字的意思就是如
• 298 •
第14章改写调优案例分享
果返回行数达到所需的条数，后面的数据就不再返回。
对这种现象不熟悉的读者，可以看笔者BLOG中的示例（http://blog.csdn. net/jgmydsai /article/details/16988039 )。
上面的语句就是一种特殊情况。因为语句里有一个DISTINCT,就必须要先对数据做 去重统计，使得STOPKEY不能在得到一定的行数后返回。而该网友那几个表的数据量又 比较大，查询起来就会很慢。 这里将对语句进行改写。 首先因为o.object一id是唯一值，而且返回的数据里只有t一objects o的列，如果不与其 他表关联，就不需要再加DISTINCT,所以可以把查询语句用EXISTS改写。
通过分析语句可以看到，有两个表与主表（t_objects)关联，分别是：t_columns tc(tc.object_id = o.object一id)与 t users (tu.user id = o.user_id)o
如果t一users的确如上面查询所示是left join t users,就没必要再关联它，但因WHERE 引用了这个表的列：WHERE tu.username IN (’HR，，’SCOTTVOEVSYS’)D 所以不再是 LEFT JOIN,而是inner join t_users。关于这一点，请参考3.8节的介绍。
因此可以写成两个EXISTS子查询，其中，“t_tables”表因为只与“t_columns”有关 联，所以，需要放在同一个子查询中：
SELECT ★
FROM (SELECT a.rownum rn
FROM (SELECT /*+ index(o,idx—t一objects) leading(o) ★/ o.object_id, o.owner, o.object—name, o.object_type, o.created, o.status FROM t_objects o WHERE EXISTS
(SELECT /*+ nl_sj qb_name(@inner) */
NULL FROM t_users tu WHERE (tu.user_id = o.user_id)
AND tu.username IN ('HR', •SCOTT*, W, 1 SYS 1)) AND EXISTS (SELECT /*+ nl_sj use_nl (tcrt) */
NULL
• 299 •
Oracle查询优化改写技巧4案例
FROM t_co丄umns tc INNER JOIN t—tables t ON (t.owner = tc.owner AND t.table一name = tc.table_name)
WHERE tc.object_id = o.object一id)
ORDER BY o.created DESC) a WHERE rownum <= 5) b WHERE rn > 0;
SELECT * FROM TABLE(DBMS XPLAN.DISPLAY CURSOR(NULL,0iostats*)>;
这样改写后，去掉了 DISTINCT,并使语句走了 NESTED LOOP,这样在得到需要的 行数后便能很快返回数据。
14.22用WITH语句减少自关联
在行数比较多的查询中，经常会发现重复的查询语句，下面这是一个已经删掉了部分
无关代码的査询：	，
SELECT /*省略返回值列表*/
FROM (SELECT /*省略返回值列表*/
FROM tsl tslO
WHERE
AND
tslO 一.created一date >=
'yyyy-MM-dd hh24:m±:ss')
AND ts10一.created 一date <=
'yyyy-mm-dd hh2 4:mi:s s')
AND ((tsl0_.adjust•一status = '1' AND
to一date(12013-09-01	00:00:00'
to date('2013-09-30	23:59:59'
tslO .serialstatus = f1') OR
'■'.r
Operation
SELECT STATEMENT VIEW3 COUNT STOPKET VIEW
NESTED LOOPS SEHI TABLE ACCESS BY INDEX ROUID INDEX FULL SCAN NESTED LOOPS INDEX RANGE SCAN INDEX RANGE SCAN INLIST ITERATOR INDEX RANGE SCAN
T一OBJECTS IDX T OBJECTS
IDX一T一COLUMNS IDX一 T一 TABLES
IDX 丁 USERS
Starts
-Rows
555558880811
2 2 2 3 2
• 300 •
第14章改写调优案例分享
(tslO_.adjust一status = * 6 * AND tslO_.serialstatus = 10') OR < ts 10一 • ad just•一 status = * 2 ' AND tsl0_.serialstatus = '21))
AND ( (ts 10一• sales一offi一id = tslO一• shipments一offi一id) OR (tslO—. shipments一offi_id = 1337))
AND NOT EXISTS (SELECT 1
FROM tsl 1 WHERE 1. s_no = tsl0_.s_no AND 1.serialstatus = '01 AND 1.created 一date <
to一date ('2013-09-01 00:00:00' , 'yyyy-MM-dd hh24 :mi: ss')) AND tsl0_.tf—adjustment = * 0') a LEFT JOIN (SELECT s_nof
retailer_code, retailer_name, creator—name, empl_type, sales一offi一id, sales_offi_name, sales_group一name, created_date FROM tsl 1 WHERE 1.s_no IN
(SELECT tsll一.s—no FROM tsl tsll
WHERE 1 AND tsl
yyyy-
-dd hh24:mi:ss')
'yyyy-MM-dd hh24:mi:ss')
tsll一. created一date>=to一date (' 2013-09-01 00:00:00' AND tsll_.created 一 date<=to— date(*2013-09-30 23:59:59' AND ((tsll__. adjust___status=111 AND tsll一. serialstatus
'O'
*2'
OR (tsll一.ad just一status:’6'AND tsll一. serialstatus OR (tsll_.adjust_status= • 2 'AND tsll—. serialstatus
AND ((tsll_. sales—offi一id= tsll一. shipments一 offi一id) OR (tsll_. shipments—offi_id = 1337))
• 301 •
Oracle查询优化改写技巧4案例
AND NOT EXISTS
(SELECT 1
FROM tsl 1
WHERE 1	..s一no = tsll_.s一no
AND 1 AND	.serialstatus = '0'
	1.created一date < to一date('	2013-09-01
00:00:00', 'yyyy-MM-dd hh24:mi:ss')))
AND 1.serialstatus	=*0') b
ON a.s_no = b.s_no
WHERE a.sales一offi_id = b.sales	一offi 一id
AND a.empl_type = * 2 *
ORDER BY a.created date, a.id DESC;
可以看，到这个查询中的表tsl被访问了很多次，而且查询条件有很大的相似度，见
粗体字标识的两部分。类似的这种语句可以使用WITH语句改写来减少不必要的扫描次
数。把粗体字部分放在WITH里，同时返回必要的列：
WITH base AS
(SELECT /*省略返回值列表*/
FROM tsl tsll—
WHERE 1=1
AND tsll_.created_date >= to_	date「2013-09-01 00:00:00、'	'yyyy-MM-dd
hh24:mi:ss')
AND tsll—• created_date <= to_	date('2013-09-30 23:59:59*,'	'yyyy-MM-dd
hh24:mi:ss')
AND ( (tsll一.adjust一status =	11' AND tsll .serialstatus =	=，1*) OR
(tsll一•adjust—status = f	61 AND tsll一•serialstatus =	•O’） OR
(tsll_.adjust一status = V	2' AND tsll .serialstatus =	•2')>
AND ((tsll .sales offi id =	tsll .shipments offi id) OR
(tsll_.shipments_offi_id	=1337))
AND NOT EXISTS
(SELECT 1
FROM tsl 1
WHERE 1. s_no = tsll__.s_	_no
AND 1.serialstatus =	•O'
AND 1.created_date	< to一date(*2013-09-01	00:00:00',
•yyyy-MM-dd hh24:mi:ss1)))
SELECT /★省略返回值列表*/
FROM (SELECT *
FROM base
WHERE base.tf adjustment	=*0*
• 302 •
第14章改写调优案例分享
AND base.empl_type = 12') a INNER JOIN (SELECT s_no,
retailer_code, retailer_name, creator_name, exnpl 一type, sales 一 offi_id, sales一of fi—name, sales_group_name/ created—date FROM tsl 1
WHERE l.s一no IN (SELECT base.s—no FROM base)
AND 1.serialstatus = 10') b ON (a.s_no = b.s_no AND a.sales_offi_id = b.sales一offi一id)
ORDER BY a.created—date, a.id DESC;
这里面因为后面的条件a.sales_offi—id = b.sales_offi」d，所以直接把LEFT JOIN改为 了 INNER JOIN。
WITH语句的改写比较简单，写查询语句的人经常会对这些相似的语句比较敏感，但 是要注意，使用WITH更改之前一定要用工具比较两个语句是否真的一样，及不同之处在 哪里，因为有时会因一个字母之差而实际访问的是两个不同的表，这用肉眼看时往往会忽略。
14.23	用WITH改写优化查询
WITH语句的改写一般比较简单，因为只要把相同的部分取出来就可以，但如果在写 语句的时候别名的命名及关联条件中列的先后顺序不注意，就会给维护语句的人造成不小 的麻烦。
select l_target.*, rownum as rn
FROM (select 10.10_id as lOIci,
10.datel as createDate,
10.idl as applyld, bai.stitle as applyTitle, bai.amtl as applyAmt, bai.ratel as applyRatio,
10.value! as oriPri,
10.value2 as leftAmt,
sum(case when lpi.status != *1* then 1 else 0 end)
Oracle查询优化改写技巧案例
as remPeriods,
curi.i user id
lO.flagl AS flag2, curi. s_cnnaine AS name2 r curi.i_user_id AS sellUserld from 10	.
left join lpp on 1pp.10_id = 10.10_id left join lpiO lpi on lpi.id3 = lpp.id3 left join b_apply_info bai on bai.i_idl = lO.idl left join pbpO pbpO on pbpO.idl = lO.idl left join ppO ppO on pbpO.id2 = ppO.id2 INNER JOIN c user_regist_inf o curi on 10 . creditor user id
where
and
and
AND
and
group
1
5263
1
10,creditor_user_id 10.status != 12' lO.flagl = '1' ppO.product_type = 1 by 10.10一id,
10.valuel,
10.value2, lO.idl,
10.datel, bai.stitle, bai.amtl, bai.ratel, lO.flagl, curi.s_cnnarae, curi.i_user_id) l_target inner join (select 12.10_id,
12.creditor_user_id, lpi0.PERI〇D_NUM, lpiO.period—end_time from 10 12
join IppO on 12.10一id = IppO.lO—id join lpiO lpiO on IppO.id3 = lpiO.id3 join ardaO on ardaO.id3 = lpiO.id3 12.creditor一user一id =5263 12.status != '21
lpiO,period_start_time <= sysdate lpi0.period_end—time > sysdate by 12.10_id,
lpiO.PERIOD_NUM,
left
left
left
where
and
and
and
group
• 304 •
第14章改写调优案例分享
			12.creditor_user id,
			lpiO.period_end一time
		having	sum(ardaO,REPAYMENT_AMT) = 0 or sum(ardaO.
REPAYMENT—	_AMT) is : on left	null) 1一cur l—cur.l0_id = 1—target•10Id join (select lpp0.10_id, IppO.status, IppO.PERIOD
		from	IppO
		inner	join (select 12.10一id, 12•creditor一user	_id/
lpiO.PERIOD_NUM, lpi0.period_			_end_time
			from 10 12
			left join IppO on 12.10—id = IppO.10_	id
			left join lpiO lpiO on IppO. id3 = lpiO	• id3
			left join ardaO on ardaO.id3 = lpiO.id3
			where 12.creditor user一id =5263
			and 12.status != *2*
			and lpiO.period_start_time <= sysdate
			and lpiO.period—end_time > sysdate
			group by 12•10一id,lpiO•PERIOD一NUM,	12.
creditor—	user id,lpiO.period end time
			having sum(ardaO.REPAYMENT_AMT)= 0	or
sum(ardaO.	.REPAYMENT一AMT> is null) 1c on lc.10一id = IppO.lO一id
		where	lc•PERIOD 一NUM = IppO.PERIOD + 1) l_pre
	on	l_j)re • 10一id = l_target. lOId
	left	join (select ttla.SELLER_10_ID, count(★) t—cnt, max(transferable) transferable
		from	tla一transfer一10_apply ttla
		where	1 = 1
		AND	ttla.SELLER 一ID =5263
		group	by ttla.SELLER—1Q_ID> l_tran
	on	l_tran.SELLER_10_ID = 1一target•lOId
	left	join (select *
		from	tla_transfer一10一apply
		where	transferable = * 11) ttlal
	on	ttlal•seller—10一id = l_target.lOId
	where	1 = 1
	and	(l_tran.transferable is null or 1一tran•transferable !=		T)
	and	applyRatio=12
	ORDER	by leftAint desc;
可以看，到第一个子査询与第二个子査询因为其中引用了不少相同的表，乍看上去有 点类似，但第一个子查询后面的JOIN条件写法习惯与第二个不一样，而且表的别名也不
• 305 •
Oracle查询优化改写技巧与案例
-样，这在对比的过程中就要耗费不少时间。 最终把第一个子查询排除后才发现第二个与第三个相似度非常高。
WITH l_cur AS (SELECT 12.10_id,
12.creditor—user_id, lpiO.period_num, lpiO.period_end_time
FROM
LEFT
LEFT
LEFT
WHERE
AND
AND
AND
GROUP
HAVING SELECT FROM
10 12
JOIN IppO on 12.10—id = IppO JOIN lpiO lpiO on IppO.id3 =
JOIN ardaO on ardaO.id3 = lpiO 12.creditor_user_id = 5263 12.status != * 2'
lpiO.period_start_time <= SYSDATE lpiO.period—end_time > SYSDATE BY 12.10_id, lpiO.period_num,
12.creditor_user_id, lpiO.period_end_t ime SUM(ardaO•repayment_amt)
1—target.*, rownum AS rn (SELECT 10.10-id AS lOid,
10.datel AS createdate,
10.idl AS applyid, bai.stitle AS applytitlef bai.amtl AS applyamt, bai.ratel AS applyratio,
10.valuel AS oripri,
10.value2 AS leftamt,
SUM(CASE WHEN lpi.status
10_id Ipi0.id3 id3
0 OR SUM(ardaO.repayment_amt)
THEN 1 ELSE 0
remperiods.
10.flagl AS flag2f curi.s_cnname AS name2, curi.i_user_id AS selluserid FROM 10
LEFT JOIN lpp on lpp.10_id = 10.10一id
LEFT JOIN lpiO lpi on lpi.id3 = lpp.id3
LEFT JOIN b_apply一info bai on bai.i_idl = 10.idl
LEFT JOIN pbpO pbpO on pbpO.idl = 10.idl
LEFT JOIN ppO ppO on pbpO.id2 = ppO.id2
IS NULL)
END) AS
• 306 •
第14章改写调优案例分享
INNER JOIN c_user_regist_info curi on 10 • creditor一user_id = curi.i_user_id
WHERE 1=1
AND 10.creditor_user一id = 5263 AND 10.status != '2'
AND lO.flagl = 'I*
AND ppO,product_type = 1 GROUP BY 10.10—id,
10.valuel,
10.value2, lO.idl,
10.datel, bai.stitle, bai.amtl, bai.ratel,
10.flagl/ curi•s_cnnamef curi.i—user_id) 1一target INNER JOIN l_cur ON l_cur.10_id = l_target.lOid LEFT JOIN (SELECT lpp0.10_idf IppO.status, IppO.period FROM IppO
INNER JOIN l_cur lc on lc.10_id = IppO.10_id WHERE lc.period_num = IppO.period + 1) l_pre ON l—pre.10一id = l_target.lOid LEFT JOIN (SELECT ttla.seller_10_idf COUNT(*) t_cnt,
MAX(transferable) transferable FROM tla_transfer_10_apply ttla WHERE 1=1
AND ttla.seller_id = 5263 GROUP BY ttla.seller_10_id) l_tran ON 1一tran•seller一10—id = l_target.lOid LEFT JOIN (SELECT * FROM tla—transfer一10_apply WHERE transferable = '1')
ttlal
ON ttlal•seller一10_id = l_target.lOid WHERE 1=1
AND (l_tran.transferable IS NULL OR 1一tran.transferable i= '11)
AND applyratio = 12 ORDER BY leftamt DESC;
Oracle查询优化改写技巧与案例
用WITH语句改写难度都不大，主要在于查找排除的过程，所以大家在平时写语句时 要按一定的习惯统一别名及关联条件的先后顺序，这样才便于后序的维护。
14.24	用WITH把〇R改为UNION
WITH语句不仅可用于合并相同的语句，还可用于改写其他语句：
WITH Dl AS (select Dl.c2 as cl
from (select distinct nvl(Dl.cl, 0) as cl, Dl.c2 as c2 from (select sum(case
when T49296.T49296—ID in (1, 31, 40, 41) then T49296.AMOUNT * -1 else 0
end) as cl,
T4 9495.SEGMENT1 as c2 from T49221 T今9221,
T49495 T49495,
T48941 T48941,
(select /*这里有160多列*/ from T49296) T4 9296 where (T48941.G_D_ID = T49296.B_DATE_D and T48941.C Y ID = '2013' and
T49221.	0—ID = T49296.0_	ID	and
T49296.	工一ITEM—ID = T4 94 95		.I_ITEM_ID	and
T49296.	0—ID = T4 94 95.0_	_ID	and
(T49221	.ATTRIBUTEl in
(’0、•	Ol、’02’, *03',	i	04', '05*,	'06
T4 9221.	NAME <> 'xxxxx')
,	group	by T4 9495.SEGMENT1
having 0 < nvl(sum(case when T49296.T49296一ID in (1, 31, 40, 41) then T49296.AMOUNT ★ -1 else 0
end), 0)) Dl) Dl),
SAWITH0 AS (select sum(T69824.AM0UNT_R) as cl
• 308 •
第14章改写调优案例分享
from (select case
when (sysdate - sign—date) is null then 0
else
(sysdate - sign—date) / 365 end as fundation一date,
/*这里有160多列*/ from EDW_CUX_INN_INFO一HEADER WHERE CURRENT_FLAG = *Y*) T49157,
T49495 T49495,
T99532 T99532,
T69824 T69824
where (T4 9157.0RG_			ID =	T69824.ORG_ID
and	T49495		_ITEM_	•ID = T69824.ITEM_ID
and	T49495	.0_	ID =	T69824.0RG_ID
and	T49157	.INN_S_NAME = 'xxxxx'
and	T69824	• T_	_L一CODE = 'ZZZZ* arid		T69824,P_FLG =
and	T69824	.RECEIVING_MON = T99532			.CAL_	_MONTH_NAME
and	T99532	• C一	_Y_ID	=*2013*
and	substr	(T49157.		.INN CODE, 1, 1)	<> '	rH*
and (丁6今824.APPROVED—FLAG in ( 'N',	'R',	'Y'))
and (T69824 .CANCEL_FLAG in (*N” or T69824.CANCEL—FLAG is null) /*网友要求把这个or改为union*/
and (T69824.SHIP_TO_BASE_FLAG in (1) or T4 94 95.SEGMENT1 in (select distinct Dl.cl as cl from Dl))
and substr(T49157.INN_CODE, 1, 1) <> *T')) select distinct Dl.cl / 10000 as cl, fYYYY' as c2 from SAWITHO Dl order by cl
上面最后一个注释的部分中，注释下面有一个“OR”连接的两个条件，对于这种条 件，我们常常把它改写为UNION丨吾句（见3.2节的描述）■> 上述语句有近300行，很多人看到这么长的语句都会发愁。其实这个语句要改写的相 关部分就是最后一个子查询和它后面的部分，而这最后一个子查询里相关的也只有几列。 下面是更改步骤。
①把(T69824.SHIP一TO_BASE_FLAG in (1) or T49495.SEGMENT1 in (select distinct Dl.cl ascl from Dl Dl>)注释掉，其余的保留不变，并确认SAWITHO中仍有对应的字段，
没有的补上，以备后用。
• 309 •
Oracle査询优化改写技巧与案例
②取SAWITH0的结果集分别加上两个条件，然后用UNION即可，这一步可以把 SAWITH0当作一个表，要改的语句放在一个新的WITH语句里就可以。
③在3.2节讲过“OR”改写为“UNION”时不能消掉不该消的行，于是在SAWITH0 中加入“ROWNUM AS SN”作为唯一标识。
WITH D1 AS
(select Dl.c2 as cl
from (select distinct Dl.cl as cl, D1.c2 as c2 from (select sum(case
when T49296.T49296_ID in (I r 31, 40, 41) then T49296.AMOUNT * -1 else 0
end) as cl,
T49495.SEGMENT! as c2 from T49221 T49221,
T49495 T49495,
T48941 T48941,
(select /*这里有160多列*/
from T49296) T4 9296	*
where (T48941.C_D_ID = T4 9296.B_DATE_D and T48941.C_Y_ID = '2013' and T49221.0_ID = T49296.0_ID and T49296.I_ITEM_ID = T49495.I_ITEM一工D and T49296.0—ID = T49495.0一工D and (T49221.ATTRIBUTE1 in
(’O', ，01', ' 02', '03，，*04、'05', '06') ) and
T49221.NAME <> 'xxxxx') group by T49495.SEGMENT1 having 0 < sum(case
when T49296.T49296一工D in (1, 31, 40, 41) then T49296.AMOUNT * -1 else
0
end)) Dl) Dl),
SAWITH0 AS (select /*sum (T69824 . AM0UNT_R) as cl,"
ROWNUM AS SNf
T69824.AMOUNT R,
• 310 •
第14章改写调优案例分享
T69824.SH工P—TO—BASE_FLAG,
T4 9495.SEGMENT1 from (select case
when (sysdate - sign_date) is null then
0
else
(sysdate - sign—date) / 365 end as fundation_date,
/★这里有50多列*/ " from EDW_CUX_INN_INFO_HEADER WHERE CURRENT—FLAG = *Y*) T49157,
T49495 T49495,
T99532 T99532,
T69824 T69824 where (T49157.ORG一ID = T69824.ORG_ID and T494 95.I_ITEM_ID = T69824•ITEM_ID and T494 95.0_ID = T69824•ORG_ID and T4 9157•INN_S_NAME = 'xxxxx1 and T69824.T一L一CODE = 'ZZZZ' and T69824.P_FLG = *N'
and T69824.RECEIVING—MON = T99532.CAL_MONTH_NAME
and T99532,C一Y—ID = '2013'
and substr(T4 9157.INN_CODE, 1, 1) <> 'H1
and (T69824.APPROVED_FLAG in (*NT,	’R*,	1Y'))
and (T69824.CANCEL_FLAG in (fN') or T69824.CANCEL_FLAG is null) /★and (T69824 .SHIP一TO一BASE_FLAG in (1) or T4 9495 . SEGMENT! in (select distinct Dl.cl as cl from Dl))*/
and substr(T4 9157.INN_CODEy 1, 1) <> *T')
),
SAWITH1 AS (
SELECT sum(AMOUNT_R) AS Cl FROM (
/*注意这里显示的列要全，能唯一标识各行，能有pk列最好，否则union后会丢数据★/ SELECT AMOUNT一R,SN FROM SAWITHO WHERE SHIP_TO_BASE_FLAG in (1)
UNION SELECT AMOUNT一R,SN FROM SAWITHO
WHERE SEGMENT1 in (select distinct Dl.cl as cl from Dl Dl)
)
• 311 •
Oracle查询优化改写技巧与案例
select distinct Dl.cl / 10000 as cl, 1YYYY1 as c2 from SAWITH1 Dl order by cl;
大家可以对更改前后的语句进行对比，是不是发现有大部分语句在改写时可以不管？ 如果把语句简化为：
SELECT *
FROM sawithO WHERE (t69824.ship_to_base_flag IN (1) OR
t4 94 95.segmentl IN (SELECT DISTINCT dl.cl AS cl FROM dl))
那么改写的勇气是不是更足了？
14.25错误的WITH改写
WITH语句虽然比较简单，但也有很多人容易出错，一个可能的原因是更改前没用工 具进行对比，结果把两个不同的语句放在WITH里合并，另一个可能的原因是不知道为什 么用WITH:
SELECT ：	b.scode f一scode,
b	.sname f sname,
b	•stype f_stype,
b.mktcode f—mktcode,
\	'f_unit,
0	f_type,
a	.f_tradeday,
a	•f20141_20015 f20183_20023,
d	.startday,
d i	.endday, r
FROM	(SELECT a.scode, a•f一tradeday, b.tradedate f2 0141_20015
f i	FROM (SELECT a.scodef c.year f—tradeday, MIN(a.lowprice) ndata, FROM a, c WHERE a.tradedate = c.tdate AND a.mktcode IN (1, 2) AND c.year = to_char(SYSDATE, 'YYYY') GROUP BY a.scode, c.year) a,
• 312 •
第14章改写调优案例分享
(SELECT a-scode,
a.tradedate,
c.year	f—tradeday,
a.lowprice ndata FROM a, c WHERE a.tradedate = c.tdate AND a.mktcode IN (1, 2)
AND c.year = to_char(SYSDATE, *YYYY1)) b WHERE a.scode = b.scode
AND a.f—tradeday = b•f—tradeday AND a.ndata = b.ndata) a, sdc一security b,
(SELECT c.year, MIN(c.tdate) startday, MAX(c.tdate) endday, 1' FROM c GROUP BY c.year) d WHERE a.scode = b.scode AND a.f—tradeday = d.year AND b.stype IN (2, 3);
下面是网友用WITH改写的语句，他的问题是：为什么改写后的语句运行会变快？
WITH temp AS
(SELECT a.scode, » *	r substr(a.t_date, 1,	4) f_t_day, MIN(a.lowprice) ndata,
FROM a
WHERE a.mktcode IN (1, 2)
AND substr(a	i.t_date, 1, 4) = to一	char(SYSDATE, 1YYYY•)
GROUP BY a.scode, substr(a•t一date,		1, 4))
SELECT b.scode f	_scodef
b.sname f—	sname.
b.stype f_	stype,
b.mktcode	f一mktcode,
* 1 f一unit,
0 f_type.
a•f_t_day,
a.t一date,
d.startday	•
d.endday, :t V
FROM (SELECT a	•scode, d.f_t_day, a.	.t 一date
FROM a,	temp d
WHERE sul	〕str(a.t—date, 1, 4)	=d.f_t_day
• 313 •
Oracle查询优化改写技巧与案例
:SEUCT I	•
B SHAME F_SHAKE,
5-	S mtt F„ST*PE；..
i	P. KKTCODE I>	MtTCODE^
s：	” fjmr,
i-	0 F’WE,
~"
..mm.2m .).snivnwt B. E8DDAT,
!i
M
15
II,.
pr
Hr
■ M,；
n
m-
：■,
m-.
；■-
n-
I
丨忠
.'；iTLS'rr « senm, *	抑n	抑i?
.... PBAIf UEt£Ct:ft 弈EWt r XEiSK P_TMPEB«: «!HC* '
3TOX I
;爾IE. i
；-'iflIB I	^	牲
'	'	"^ m_cm.tsn
>»y fe,fE*i> t.；SCODE,： i. TM崎蘇 爾R /
......fe. ummc
.... yjfenfe,..:
STOTSE ^ mriWftTI；=
m> c tea = to cHtfctstsom. 'tm'j &sow sir * s« ............"
.:k. SCODI
i. i：i <-T£
'	:r:.ii肋舰?..：
», ummQE. imn
:：m£&
::
AHD A . JOrrCCiBE I IT (1, 2)
a«b r yi>e & xo„mai.»sri*TE, ' %w y s h $mm
ji f tMttgtot = e r maBEJ
；表ot 由-mm r n ot«ju ■»,
sdc s£cimm i,
(SEiECT C. JTEAK, m»(C. TBAIS) STAKICAy, lUKlC TBAtE) EiTOMt, iROK.C
:RHEK£ i
FRO* C CROUP m C, YEARJ » A SCODE = t> SCODE
:oni
man
m s®smu T.MTE. L 4J ^ TO_€lift&lS?SMTE, ‘I'm i
...........'	衡 iijifer;...............
' S^SftUi	S,	41)；
' ' '〜 km	■	‘
..:4抑
:§論# tty-:*v：sCiatJ :
)A.KKTCODE IS (l, 2)
1 H, WIWWCE t » 师A?厂
1 ： SELECT t SCODE F_SCO»E, 2：	« shame r.shake,
3	B. STYPE P, STYPE,
!i：P,8T1 B XXTCODE P_)
,• f inrrT,
o	tjhrt.
k：rMts.
D. STARTD43,
PjESBD*?,
t gsagr & ssise d	i	i,	mrt
通过对比可以看到，这完全成了两个不同的语句。除非业务上这两个查询等价，否则 仅从语句上看这个改写是错误的。
我们来看一下原语句应该怎么更改，原语句可改的地方主要就是第一个FROM后的 内联视图a,见原语句中的粗体部分。可以看到，这个视图的主要目的是取出MIN(a.lowprice) 所在行的数据，对于这种需求，我们可以使用分析函数来处理：
SELECT	b.scode	,b.f t day, b.t date AS t_date
FROM	(SELECT	a.scode,
	a.	t date,
	c •	year f一t—day.
	MIN(a.lowprice) over(PARTITION BY a.scode, c.year) AS
AND a.mktcode IN (1, 2)
AND a.lowprice = d.ndata) a, sdc_security b,
(SELECT c.year, MIN(c.tdate) startday, MAX(c.tdate) endday, ，• FROM c GROUP BY c.year) d WHERE a.scode = b.scode AND a•f_t_day = d.year AND b.stype IN (2f 3)；
这个改后的这个语句只是简单地把一个语句放到了 WITH里，而且只调用了一次，这 种情况一般不会对执行速度产生影响。
我们来对比一下更改前后的语句：
8.AKY.EJII %VC.BSSB URlc.cBy= f
P|:
REro
J5:2627,SS.S6
• 314 •
第14章改写调优案例分享
min_ndata,
	a.lowprice	ndata
	FROM a, c
	WHERE a.t_date =	=c.tdate
	AND a.mktcode	IN (1, 2)
	AND c.year = to_char(SYSDATE, 1YYYY')		)b
WHERE	min ndata = ndata
这样就只需对a、c访问一次即可。改完后用这部分语句替换原内联视图a即可。
14.26错误的分析函数用法
很多人学习完分析函数后，喜欢用分析函数进行改写，下面是一个案例的模拟:
SELECT	a.deptno.	a.empno, a•	ename, a.sal,	b.min sal, b.max sal
FROM	emp a
INNER	JOIN (SELECT deptno,		MAX(sal) AS max_sal, MIN(sal) AS min_sal
	FROM	emp
	GROUP	BY deptno)	b
ON	b.deptno =	a.deptno
WHERE	a.hiredate	>=to一date('1981-01-01		*yyyy-mm-dd，)
AND	a.hiredate	< to—date(	•1982-01-011,	* yyyy-mm-dd')
AND	a.deptno IN (10, 20)
ORDER	BY 1, 4;
上述语句中，为了取最大值与最小值，对表emp访问了两次，于是有人这样改写:
SELECT a.deptno,
a.empno.
d«©riciinG f
a.sal,
MIN(a.sal)	over(PARTITION BY a.deptno)	AS	min sal,
MAX(a.sal)	over(PARTITION BY a.deptno)	AS	max_sal
FROM emp a
WHERE a.hiredate	>=to一dater1981-01-01*,	/yy^
AND a.hiredate	< to date('1982-01-01', * yyyy-mm-dd')
AND a.deptno IN (10, 20)
ORDER BY I, 4;
使用分析函数来改写没错，但很多人改写的时候都会与这个案例一样，忽略了一个重 点：分析函数只能分析主查询返回的数据。
• 315 •
Oracle査询优化改写技巧案例
这样改写后就由“取全表的最大最小值”变成了取“1981年之内的最大最小值”数据, 范围发生了变化，数据就很可能不准确。 我们来对比一下结果。 未改前：
DEPTNO	EMPNO ENAME	SAL	MIN_SAL	MAX_SAL
10	7782 CLARK	2450	1300	5000
10	7839 KING	5000	1300	5000
20	7566 JONES	2975	800	3000
20	7902 FORD	3000	800	3000
4 rows selected
更改后：
DEPTNO	EMPNO ENAME	SAL	MIN_SAL	MAX一SAL
10	7782 CLARK	2450	2450	5000
10	7839 KING	5000	2450	5000
20	7566 JONES	2975	2975	3000
20	7902 FORD	3000	2975	3000
4 rows selected
对比上述两组数据，大家可以看到最小值发生了变化，因为两个最小值都没在1981 年中，所以大家在对语句做更改时一定要注意更改的内容及其可能产生的影响。同时尽可 能地多次对比更改前后的数据。
那么这种查询还可以用分析函数更改吗？当然可以，只是需要注意条件应一致，这样 就需要先执行分析函数，再使用HIREDATE上的条件过滤：
SELECT	deptno,	empno, ename, sal, min_sal.	max_sal
FROM	(SELECT	a.deptno,
	a.	empno,
	a.	ename.
	a.	sal.
	a.	hiredate.
	MIN(a.sal) over(PARTITION BY a		.deptno)	AS min_	■sal.
	MAX(a.sal) over(PARTITION BY a		.deptno)	AS max—	_sal
	FROM emp a
	WHERE a	i.deptno IN (10, 20)) a
WHERE	a.hiredate >= to_date('1981-01-01',		* yyyy-mm	i-dd •)
• 316 •
第14章改写调优案例分享
AND a.hiredate < to—date<11982-01-01 *,	'yyyy-mm-dd')
ORDER BY 1, 4;
在这个正确的语句中，先在内联视图里用分析函数取得正确的数据，外层再过滤不需 要的数据，这样逻辑就与修改前一样了。
14.27	用LEFT JOIN优化多个子查询（一）
这是一个通过dblink查询的案例，下面来看一下语句及PLAN:
SELECT a.*, b.rkids
FROM (SELECT gys.khbh, gys•khmc, wz.wzzbmf wz.wzmbm, wz.wzmc, wz,wzggv a. slf wz.jldwf wz.wzflmbm,
END) si
a.si * wz.wzflmbm FROM wz@dblink wz, gys@dblink gys, (SELECT m.khbh, d.wzzbm, SUM(CASE m.
jhje
rkzt WHEN f2f THEN d.xysl ELSE -1 ★ d.xysl
FROM	m@dblink			m, d@dblink d
WHERE	m,	.rkid	=	d.rkid
AND	m.	rkzt	IN	(2, 3)
AND	m.	ssny	<	,201311*
GROUP	BY m.khbh			,d.wzzbm) a
a. si >	0
AND gys.khbh = a.khbh AND wz.wzzbm = a.wzzbm) a,
(SELECT m-khbh, d.wzzbm, wmsys.wra_concat(m.rkid) rkids FROM m@dblink m, d@dblink d
WHERE m.rkid = d.rkid AND m.rkzt = 2 AND m.ssny < '2013111
• 317 •
Oracle查询优化改写技巧*5案例
I IN-OUT I
R->S
R->S
R->S
R->S
R->S
R->S
| Id | Operation	|	Name
0	SELECT STATEMENT |
* 1	HASH JOIN RIGHT OUTER|
2	VIEW
3	SORT GROUP BY
* 4	FILTER
5	REMOTE
6	NESTED LOOPS
7	REMOTE	MP_RKDJWZ
8	REMOTE	MP_RKDJ
9	SORT AGGREGATE |
10	NESTED LOOPS |
11	REMOTE	MP_RKDJ¥Z
12	REMOTE	MP_RKDJ
13 14	VIEW REMOTE
	AND m.zxdid	IS NULL
	AND (NOT EXISTS (SELECT 1
		FROM m@dblink	ml,	dQdblink dl
		WHERE ml.rkid =	=dl	.rkid
		AND irtl. Zxdid	=m.	’rkid
		AND dl.wzzbm	=d.	wzzbm
		AND ml,rkzt =	3)	OR
	(SELECT	SUM(dl.xysl)
		FROM m@dblink	ml,	dQdblink dl
		WHERE ml.rkid = dl		.rkid
		AND ml.zxdid	=m.	,rkid
		AND dl.wzzbm	=d.	wzzbm
		AND ml.rkzt =	3)	< d.xysl)
	GROUP BY m.khbhr d.wzzbm) b
WHERE	a.khbh = b.khbh (+)
AND	a.wzzbm = b.wzzbm(+);
Predicate Information (identified by operation id)
1	- access ("A". fl,KHBlT=<,B,r. "KHBH" (+) AND	IZZBIT (+))
4 - filter( NOT EXISTS (SELECT 0 FROM "Al*, "A2" WHERE "Ml*. "ZXDID"=:B1 AND
T0_NUMBER(wMr."RKZr)=3 AND 11". ”狀；0)"=11”. "RKIir AND "Dl". ,TtfZZBM",=:B2) OR WDW. WXYSLW> (SELECT SUHrnrZXYSI/) FROM "Al", "AT WHERE 1厂."ZXDnT-:B3 AND T0_NUMBERrMl'wRKZr)=3 AND "Ml". "RKHT^Dr. "RKIIT AND "Dl". ,VWZZBMW=:B4))
这个PLAN后面还有其他谓词信息，不过不重要。大家看ld=4的位置，在FILTER 里要访问远端表，而这个地方就是以下两个判断。 ①用反连接子查询排除数据。
NOT EXISTS (SELECT 1
FROM m@dblink ml, d@dblink dl
702K
702K
WN
WN
m
WN
WN
m
3 3 2 2 2 1 1 11 1A 1 1* 2
oooo o o o o o o o o oooo oooo0:000 oooo oooo oooo oooo oooo0-0:0:0: oooo oooo oooo
\J^ Jr \J \y %y XJ, \y
5 5 8 8 7 0 0 0 0 0 0 6
6 6 8 8 4 2 4 1 2 4 17 3 3 2 2 .2 1. 1 9 2 2 11 .1
M M M
5 5 8 7 8486502 6 3 4 4 16 382251329 4 4 0 1 12 112
• 318 •
第14章改写调优案例分享
WHERE	ml.rkid =		dl	.rkid
AND	ml,	.zxdid =	=m.	,rkid
AND	dl	.wzzbm =	=d.	,wzzbm
AND	ml,	.rkzt =	3)
②与单行关联子查询中的值进行比较。
(SELECT SUM(dl.xysl)
FROM	m0dblink		ml,	d0dblink
WHERE	ml	.rkid =	=dl	.rkid
AND	ml.	.zxdid	=m,	.rkid
AND	dl.	,wzzbm	=d _	.wzzbm
AND	ml.	,rkzt =	3)	< d.xysl
这两个判断都访问同样的表，而且其条件也一样，这两个子查询可以先合并为如下语句:
(SELECT SUM(dl.xysl) AS xysl, ml.zxdid, dl.wzzbm FROM m@dblink ml, dQdblink dl WHERE ml.rkid = dl.rkid AND ml.rkzt = 3 GROUP BY ml.zxdid, dl.wzzbm)
但在原语句里一个是反连接，一个是有条件半连接子查询，所以合并后的语句不适合 再用子查询关联，不过可以把改后的语句作为内联视图来左联：
SELECT	*
FROM	m0dblink m	,d@dblink d
LEFT	JOIN (SELECT		SUM(dl.xysl) AS xysl		,ml.zxdid, dl.wzzbm
	FROM	m@dblink ml,		d@dblink 丨	dl
	WHERE	ml	.rkid = dl	.rkid
	AND	ml	.rkzt = 3
	GROUP	BY	ml.zxdid,	dl.wzzbm)	ml
ON	(ml.zxdid = m		.rkid AND ml.wzzbm =		d.wzzbm)
WHERE	(ml.zxdid	IS	NULL OR nvl(ml.xysl.		0) < d.xysl)
这样通过一次关联就达到了前面两个子查询的效果。
我们接着观察原语句，会发现查询由两个大的内联视图a与b组成，而视图b只起一 个作用，即取回列“rkids”，而其他条件与内联视图a相差不多。所以可以用CASE WHEN 把视图b合并到视图a中：
SELECT gys.khbh, gys.khmc, wz.wzzbm, wz.wzmbm,
• 319 •
Oracle查询优化改写技巧与案例
wz.wzmc.
wz.wzggf a. si, wz.jldw, wz. wzf lmbiri/
a.si * wz.wzflrabm jhje, a.rkids FROM wz@dblink wz, gys0dblink gysf (SELECT m.khbh, d.wzzbm,
SUM(CASE m.rkzt WHEN *2' wmsys.wm_concat(CASE
WHEN (m.
(ml.
d.xysl)) THEN
m.rkid END) AS rkids
FROM m@dblink m INNER JOIN d@dblink d
THEN d.xysl ELSE -1 * d.xysl END) si, rkzt = 2 AND
zxdid IS NULL OR nvl(ml.xysl, 0) <
WHERE
AND
AND
ON	(m.rkid =	d.rkid)
LEFT	JOIN (SELECT		SUM(dl.xysl) AS xysl, i
	FROM	m@dblink ml,		d@dblink dl
	WHERE	ml •	rkid = dl	.rkid
	AND	ml.	rkzt = 3
	GROUP	BY	ml.zxdid,	dl.wzzbm) ml
ON	(ml • zxdid	=rn	.rkid AND	ml.wzzbm = d.
WHERE	m.rkzt IN	(2,	3)
AND	m.ssny < •	201311'
GROUP	BY m.khbh,		wzzbm) a
a.si >	0
d.wzzbm)
gys.khbh wz.wzzbm
a.khbh a.wzzbm
改后的语句直接走了 HASH JOIN，其运行效率提高了很多。
14.28	用LEFT JOIN优化多个子查询（二）
良好的逻辑思维能力有助于写出高效的查询语句，但如果写的语句连自己都看不明 白，那就比较麻烦，例如下面的语句：
• 320 •
第14章改写调优案例分享
SELECT COUNT(1) num FROM (SELECT tl.*
FROM t_asset WHERE 1=1 AND tl.type AND
4) ) OR
tl
0
(tl.status IN (1, 10, 11, 12, 100) OR (EXISTS (SELECT b•resource一id FROM t■一as set一 file b WHERE tl.resource_id = b.
AND tl.status IN (3, 4,
AND b.status IN (1, 10,
AND (EXISTS (SELECT 1
FROM t_asset 一file al WHERE tl.resource_id = al AND (al.content status =
asset_code
8)
11, 12))))
asset一code
1 OR al.content status
NOT EXISTS (SELECT 1
FROM t一asset一file al
WHERE tl.resource id =
al.asset code))
ORDER BY tl.create time DESC, tl.resource id) a;
这个语句在子查询里对表t_asset_file访问了三次，效率可想而知。 我们对上述语句进行如下整理： ①根据语句的逻辑可以看出：“ANDtl.StatUSIN(3，4，8)”是对主表的过滤，不应该 放在子查询中，应改为：
tl.status IN (3, 4, 8) and (SELECT b•resource一id
FROM t一asset—file b WHERE tl•resource—id = b.asset—code AND b.status IN (1, 10, 11, 12))
②三个子查询可以合并成一个，与多个标量子査询访问同一个表一样，改写时把关 联列放在GROUP BY中，子查询间不相同的条件放在CASE WHEN里（有经验的读者或 许会注意到：这就是一个行转列的写法）：
SELECT asset_code.
MAX(CASE WHEN status IN <1, 10,	11,	12) THEN 1 END)	AS status.
MAX (CASE WHEN (content_s tatus = 1	OR	content一status =	4) THEN 1 END)
AS content一status
FROM t asset file
GROUP BY asset code
• 321 •
Oracle査询优化改写技巧与案例
这样三个子查询需要的列就都在其中了，我们再左联这个结果集就很容易达到目的:
SELECT	COUNT(1) num
FROM	(SELECT tl.*
	FROM	t asset tl
	LEFT	JOIN (SELECT asset_code,
		MAX (CASE WHEN status IN (1, 10,	11,	12) THEN 1 END)
AS status,
		MAX (CASE WHEN (content_status =	1 OR	content—status
=4) THEN	1 END)	AS content_status
		FROM t一asset一file
		GROUP BY asset code) al
	ON	(al.asset_code = tl.resource_id)
	WHERE	1 = 1
	AND	tl.type = 0
	AND	(tl.status IN (1, 10, 11, 12, 100) OR
		(tl.status IN (3, 4, 8) AND al.status =	1))
	AND	(al.content status = 1 OR al.asset_code	IS	NULL)
	ORDER	BY tl.create_time DESCf tl.resource id)	a;
这样就只需要访问一次表t_asset—file,而且PLAN也比原来好看多了，从HLTER变 为了 HASH JOIN。 大家以后写査询的时候可以想想：真的需要写这么多EXISTS吗？
14.29	用LEFT JOIN优化多个子查询（三）
下面又是一个多次访问同一个表的语句:
SELECT in .coll, d. col2 FROm m, d WHERE AND AND AND AND
wmsys.wm_concat(m.col3) c〇13s
m.col3 = d.col3 m.col6 = 2 m.col7 < '201312'
m.col4 IS NULL (NOT EXISTS (SELECT 1
FROm m ml, d dl WHERE ml.col3 = dl.col3 AND ml.col4 = m.col3 AND dl.col2 = d.col2 AND ml.col7 < '201312'
• 322 •
第14章改写调优案例分享
WITH x AS
(SELECT	m	.coll
FROm	m,	d
WHERE	m.	.col3
AND	m.	col6
AND	m.	col7
上述语句中，主表及子查询访问的都是相同的两个表，但条件又有区别，见上面粗体 字部分，由于两个子查询的条件一样，所以可以把两个子查询合并为内联视图。
首先，把主查询扩大范围，结果放在WITH里：
?ITH x AS
(SELECT m.coll, d.col2, m.col3, m.col4, d.col5, m.col6
d.col3 I (2, 3)
•201312.>
上面这段语句是否要放在WITH里，取决于过滤后是否能返回较小比例的行数。
其次，把半连接子查询（not exists)和有条件单行子查询合并在一起，放入内联视图：
SELECT b.col4, b.col2f SUM(b.col5) AS col5 FROM x b WHERE b.col6 = 3 GROUP BY b.col4, b.col2
注意，要用GROUP BY关联列，SELECT里要返回所有需要的列（关联列及判断列）。 左联上面的结果集后再过滤就可以：
WITH x AS
(SELECT m.coll, d.col2, m.col3, m.col4, d.col5, m.col6 FROm m, d WHERE m.col3 = d.col3 AND m.col6 IN (2, 3)
AND xn.col7 < '201312”
SELECT a.coll, a.col2, wmsys.wm_concat(a.col3) col3s FROM x a
LEFT JOIN (SELECT b.col4f b.col2f SUM(b.col5) AS col5 FROM x b
• 323 •
Oracle查询优化改写技巧与案例
55E"
(1)| 00:01:44 I
⑴丨 00:01:11
(1)丨	00:00:32
(2)|	00:00:12 (2)| 00:00:33
0	丨 INSERT STATEMENT
1 I FILTER
2 I	HASH JOIN RIGHT
3 I	TABLE ACCESS
4 I	TABLE ACCESS
5	I TABLE ACCESS
T SEMI i? Ul«Ii :FULL FULL
I
I F I 0 I F
1
451K
131K
1
244
244
11M
27H
142
	WHERE b.col6 = 3
	GROUP BY b.	.col4, b.col2)	b ON (b.col4 =	=a.col3 AND b.col2 =
a.col2)
WHERE	a.col4 IS NULL
AND	a.col6 = 2
AND	(b.co!4 IS NULL	OR b.col5 < a,	.col5)
GROUP	BY a,col1, a.co!2;
这个语句改写后就可以走HASH JOIN或NESTED LOOP,而且少访问了一次表。
14.30	去掉 EXISTS 引起的 FILTER
有些数据库不支持(a,b，c) in (select a，b，c from )这种查询方式，于是有人就喜欢把列合 并后再用IN语句，例如下面的语句：
SELECT
FROM 0
WHERE EXISTS
(SELECT 1
FROM	F
WHERE	0.	.PTY_	ID = F.PTY_ID
AND	0.	ORG :	=F.ORG
AND	0.	CODE	=F.CODE)
AND O.xx II	1 O.xx		II 0.xxx ...	NOT IN
(SELECT	F	• XX |	11 F.xx || F	.XX
FROM	F
WHERE	END_DT		1 = TO一DATE('	29991231',	1YYYY-MM-DD1)
AND	O.PTY_		ID = PTY—ID
AND	0.	ORG :	=ORG
AND	0.	CODE	=CODE)
这种写法的后果就是很难用到预设的索引，而且常常产生不好的PLAN:
I	Id | Operation	I	Naine	I	Rows	I	Bytes	ITenroSpc	I	Coat	(%CPU>	I	Time
5 5 0 1 0 4 0 8 9 6 0 6 5 2 12
• 324 •
第14章改写调优案例分享
00:00:45 I 00:00:45 I 00:00:33 | 00:00:12 I
0	I SELECT STATEMENT	I	I	13 I	4667 I	3696
1	| HASH JOIN	I	I	13 I	4667 |	3696
2	|	TABLE ACCESS FULL I F	I	871 |	120KI	2695
3	I	TABLE ACCESS FULL I 0	I	131KI	27HI	1000
至此，实现了目标。
14.31	重叠时间计数
本例是SQL解惑上的麻醉师谜题。为了计算麻醉师的报酬，需要计算每个时段同时 进行的手术数目，语句如下：
DROP TABLE PROCS PURGE;
CREATE TABLE PROCS(proc_id,anest一name,start—time,end 一time) AS
SELECT	10,	•Baker*,	*08:00',	•11:00*	FROM	dual	UNION	ALL
SELECT	20,	•Baker*,	*09:00、	,13:00t	FROM	dual	UNION	ALL
SELECT	30,	'Dow1 ,	,09:00*,	,15:30，	FROM	dual	UNION	ALL
SELECT	40,	• Dow',	•osioo*,	,13:30’	FROM	dual	UNION	ALL
SELECT	50,	'Dow',	f10:00'f	’lU1	FROM	dual	UNION	ALL
SELECT	60,	1 Dow1 ,	,12:30,f	-13:30’	FROM	dual	UNION	ALL
SELECT	70,	* Dow 1 ,	’13:30’，	,14:30*	FROM	dual	UNION	ALL
SELECT	80,	'Dow',	’18:0(T,	•19:00*	FROM	dual;
这个需求的要点就在于每个时段进行的手术数目都要统计一次，所以，首先需要生成
有没有办法把上面这个PLAN去掉。经确认：表O与表F只有一条数据对应，于是 直接改成了 JOIN的方式：
SELECT
FROM	0,	*
	(SELECT
		FROM	F
	WHERE		END_DT = TO一DATE( 1	'29991231'	,'YYYY-MM-DD1))	F
where	0	• PTY 一	ID = F.PTY_ID
AND	0.	,ORG = F,ORG
AND	O.	CODE	=F.CODE
AND	〇_	XX |	I 0.XX 丨丨 O.xxx ..,	….<> F	• xx 丨丨 F.xx I I F.
这样改写后就只剩下一个HASH JOIN：
I	Id I Operation	I	Name	I	Rows	I	Bvtea	I	Coat	(%CPU)	I	Time
(3
(3
(3
(2
• 325 •
Oracle查询优化改写技巧与案例
一个时间列表:
SELECT anest_name, start_time AS UNION
SELECT anest_namef end—time AS t ANEST NAME T
t FROM procs FROM procs;
Baker
Baker
Baker
Baker
08:00
09:00
11:00
13:00
Dow	18:00
Dow	19:00
14 rows selected
根据这个时间列表，通过不等连接，分别取出对应的麻醉过程数据。
SELECT a.t, b.*, COUNT(*) over(PARTITION BY a•anest_name, a.t) FROM (SELECT anest_name, start_time AS t FROM procs UNION
SELECT anest_name, end—time AS t FROM procs) a INNER JOIN procs b ON (b.anest_name = a.anest_name AND b.start
a.t AND b.end_time > a.t)
ORDER BY 3, 1, 2;
T		PROC—ID ANEST_	_NAME START一	_TIME END—TIME	i
08:	00	10 Baker	08:00	11:00	1
09:	00	10 Baker	08:00	11:00	2
09:	00	20 Baker	09:00	13:00	2
11:	00	20 Baker	09:00	13:00	1
08:	00	4 0 Dow	08:00	13:30	1
09:	00	30 Dow	09:00	15:30	2
09:	00	40 Dow	08:00	13:30	2
10:	00	30 Dow	09:00	15:30	3
10:	00	40 Dow	08 :00	13:30	3
10:	00	50 Dow	10:00	11:30	3
11:	30	30 Dow	09:00	15:30	2
11:	30	4 0 Dow	08:00	13:30	2
12:	30	30 Dow	09:00	15:30	3 :
12:	30	40 Dow	08:00	13:30	3
12:	30	60 Dow	12:30	13:30	3
CT
AS ct
time <=
• 326 •
第14章改写调优案例分享
13:30	30 Dow	09:00	15:30	2
13:30	7 0 Dow	13:30	14:30	2 .
14 :30	30 Dow	09:00	15:30	::1
18:00	80 Dow	18:00	19:00	1
19 rows	selected
然后分别取各麻醉过程最大的重叠时间点即可：
SELECT proc_id,anest_name, start_time,end_time, MAX(ct) AS ct FROM (
SELECT a.t, b.*, COUNT(*) over(PARTITION BY a,anest_name, a.t) AS ct FROM (SELECT anest_name> start—time AS t FROM procs UNION
SELECT anest—name, end_time AS t FROM procs) a INNER JOIN procs b
ON (b. anest_name = a. anest—name AND b • start_time <= a. t AND b. end_time >
a.t)
)
GROUP BY proc_id,anest_name, start_time,end_time
ORDER BY 2,1;
PROC ID ANEST NAME START TIME END TIME	CT
10 Baker	08:00	11:00	2
20 Baker	09:00	13:00	2
30 Dow	09:00	15:30	3
40 Dow	08:00	13:30	3
50 Dow	10:00	11:30	3
60 Dow	12:30	13:30	3
70 Dow	13:30	14:30	2
80 Dow	18:00	19:00	1
8 rows selected
也可以把以上各步骤改为分析函数及树形子句实现：
WITH xO AS ( .
/*枚举时间点t*/
SELECT proc—id, anest—name, start—time, end_time, t FROM (SELECT proc_id,
anest—name, start一time,
• 327 •
Oracle查询优化改写技巧与案例
end_time, start_time AS s, end一time AS e FROM procs) unpivot(t FOR col IN(s, e))),
xl AS ( •
/*落实重叠行★/
SELECT (PRIOR t) AS t, proc_id, anest一name, start_timef end_time FROM xO WHERE LEVEL = 2 CONNECT BY nocycle(PRIOR anest_name) = anest一name AND start_time <= (PRIOR t)
AND (PRIOR t) < end—time AND LEVEL <= 2 ORDER BY 1>, x2 AS (/*计算重叠行数目*/
SELECT proc_id,
anest—name,
start_time,
end_time,
11 ,
COUNT(DISTINCT proc_id) over(PARTITION BY t, anest_name) AS cnt FROM xl)
/★取最值*/
SELECT proc_id, anest_name, start_time, end一time, MAX(cnt) AS cnt FROM x2
GROUP BY proc：—id, anest_name, start—time, end一time ORDER BY 1;
14.32	用分析函数改写优化
这是一个SQL解惑中的例子，语句如下:
/*病人对医疗机构提出法律索赔，记录表为Claims*/
CREATE	OR	REPLACE	VIEW Claims (索赔号，患者）AS
SELECT	10,	* Smith,	r FROM	DUAL	UNION ALL
SELECT	20,	1 Jones丨	丨 FROM	DUAL	ONION ALL
SELECT	30,	'Brown 1	1 FROM	DUAL;
• 328 •
第14章改写调优案例分享
/*每一项索赔都有一个或多个被告（defendant)，通常都是医生，记录表为Defendants*/
CREATE	OR	REPLACE VIEW Defendants (索赔号，
SELECT	10,	'Johnson1	FROM	DUAL	UNION	ALL
SELECT	10,	1Meyer *	FROM	DUAL	UNION	ALL
SELECT	10,	*Dow'	FROM	DUAL	UNION	ALL
SELECT	20,	'Baker*	FROM	DUAL	UNION	ALL
SELECT	20,	'Meyer'	FROM	DUAL	UNION	ALL
SELECT	30,	1 Johnson,	FROM	DUAL	f
每个与索赔相关的被告都有法律事件历史，当某项索赔的被告索赔状态发生变化时，都会记录下来*/
CREATE	OR	REPLACE VIEW		LegalEvents (索赔号，被告，索赔状态，					change_date)
SELECT	10,	1 Johnson1	t t	’AP、	date	* 1994-01-01*	from	dual	union	all
SELECT	10,	'Johnson1,		,OR, r	date	*1994-02-01'	from	dual	union	all
SELECT	10,	'Johnson',		•SF1 ,	date	'1994-03-01'	from	dual	union	all
SELECT	10,	1 Johnson1,		•CL、	date	'1994-04-01*	from	dual	union	all
SELECT	10,	'Meyer1	r	'AP* f	date	,1994-01-01'	from	dual	union	all
SELECT	10,	'Meyer *	r	’OR',	date	,1994-02-01'	from	dual	union	all
SELECT	10,	1Meyer1	r	1 SF» ,	date	'1994-03-01'	from	dual	union	all
SELECT	10,	1 Dow'	\ i	rAP» ,	date	'1994-01-01'	from	dual	union	all
SELECT	10,	'Dow 1	i r	'OR* •	date	,1994-02-01,	from	dual	union	all
SELECT	20,	*Meyer'	r	*AP* ,	date		from	dual	union	all
SELECT	20,	*Meyer'	e	fOR* ,	date	'1994-02-01'	from	dual	union	all
SELECT	20,	1Baker *	r	’AP,,	date	'1994-01-01'	from	dual	union	all
SELECT	30,	1 Johnson'	i /	•AP，，	date	'1994-01-01f	from	dual;
/*对于每个被告索赔状态的变化按照法律制定的已知顺序进行，如下面的Claim状态表所示*/ CREATE OR REPLACE VIEW ClaimStatusCodes (索赔状态，索赔状态描述，顺序）as SELECT *AP', 'Awaiting review panel' , 1 from dual union all SELECT * OR*,	' Panel opinion rendered1, 2 from dual union all
SELECT 'SF', 1 Suit filed1	•	3	from dual union all
SELECT 'CL', 'Closed'	,	4	from dual;
要求找出每一项索赔的索赔状态，并显示出来。 /*被告的索赔状态是他或她最近的索赔状态，是具有最高索赔顺序号的索赔状态*/ SELECT el •被告， cl.索赔号， cl.患者> s3.顺序，
S3.索赔状态 FROM claims cl
INNER JOIN legalevents el ON el.索赔号=cl.索赔号
• 329 •
Oracle查询优化改写技巧4案例
INNER JOIN claimstatuscodes s3 ON s3 •索赔状态=el •索赔状态 ORDER BY 1, 2, 4;
被 告	索赔号	患 者	顺序	索赔状态 |
Baker	20	Jones	1	AP
Dow	10	Smith	1	AP
Dow	10	Smith	2	OR
Johnson	10	Smith	1	AP
Johnson	10	Smith	2	OR
Johnson	10	Smith	3	SF
Johnson	10	Smith	4	CL
Johnson	30	Brown	1	AP
Meyer	10	Smith	i	AP
Meyer	10	Smith	2	OR
Meyer	10	Smith	3	SF
Meyer	20	Jones	1	AP
Meyer	20	Jones	2	OR
某个索赔的索赔状态是所有涉及索赔的“被告索赔状态”最低的那个被告的状态，如 下表：
被告’	索赔号	患 者	顺 序	索赔状态 |
Dow	10	Smith	2	OR
Meyer	10	Smith	3	SF
Johnson	10	Smith	4	CL
Baker	20	Jones	1	AP
Meyer	20	Jones	2	OR
Johnson	30	Brown	1	AP
最终结果如下表:
索赔号		患 者		索赔状态
10	Smith			OR
20	Jones			AP
30	Brown			AP
• 330 •
第14章改写调优案例分享
其中，第一个査询方案如下：
SELECT cl.索赔号，cl.患者，si.索赔状态 FROM claims cl, claimstatuscodes si WHERE si.顺序 IN (SELECT MIN<s2 .顺序）
FROM claimstatuscodes s2 WHERE s2.顺序 IN (SELECT MAX (s3.顺序）
FROM legalevents el, claimstatuscodes s3 WHERE el.索赔状态=s3.索赔状态 AND el.索赔号- cl.索赔号 GROUP BY el.被告）);
现在对这个査询进行优化，这个查询的目的就是先找出案子里每个被告的状态，然后 找出这些状态的最小值。 对于这种自关联求最值的问题，可以用分析函数消去自关联，语句及解释如下：
SELECT索赔号，患者，顺序，索赔状态 FROM (SELECT 被告，
索赔号，
患者，
顺序，
索赔状态，
/*2.查找所有被告索赔状态里最低的那个状态*/
MIN (顺序> over (PARTITION BY 索赔号）AS min一顺序 FROM (SELECT el •被告， cl.索赔号， cl .患者， s3.顺序， s3.索赔状态，
/*1.查找所有被告的当前索赔状态*/
MAX(s3•顺序 > over (PARTITION BY el.被告，el.索赔号）AS
max」頓序
FROM claims cl
INNER JOIN legalevents el ON el.索赔号=cl.索赔号 INNER JOIN claimstatuscodes s3 ON s3 •索P®状态=el •索赔状态） WHERE顺序=max_顺序）
WHERE顺序- min_顺序 ORDER BY 1, 3；
这个语句的思路和步骤就相当于是需求的一个翻译。 而有意思的是下面这种方案，通过枚举所有的状态，再去掉己有的状态后，取最小状
• 331 •
Oracle查询优化改写技巧与案例
态减1,与前面介绍的反连接类似。
1.通过“左连”取出所有的数据
SELECT cl.索赔号， cl.患者， si.顺序， el.索赔号 FROM claims cl
INNER JOIN defendants dl ON cl.索赔号=dl.索赔号 CROSS JOIN claimstatuscodes si LEFT JOIN legalevents el ON (cl.索赔号=el.索赔号 ANDdl.被告=el.被告 AND si •索赔状态=el •索赔状态）
ORDER BY 1,3;
1 索赔号	患 者	顺 序	索赔号	索赔状态 |
10	Smith	1	10	AP
10	Smith	1	10	AP
10	Smith	1	10	AP
10	Smith	2	10	OR
10	Smith	2	10	OR
10	Smith	2	10	OR
10	Smith	3	10	SF
10	Smith	3	10	SF
10	Smith	3
10	Smith	4
10	Smith	4
10	Smith	4	10	CL
20	Jones	1	20	AP
20	Jones	1	20	AP
20	Jones	2	20	OR
20	Jones	2
20	Jones	3
20	Jones	3
20	Jones	4
• 332 •
第14章改写调优案例分享
续表
1 索赔号	患 者	顺 序	索赔号	索赔状态 |
20	Jones	4
30	Brown	1	30	AP
30	Brown	2
30	Brown	3
30	Brown	4
可以看到最小未完成状态如下表:
索赔号		患 者	顺 序
10	Smith		3
20	Jones		2
30	Brown		2
2.通过最小未完成状态得到最后的完成状态
SELECT cl.索赔号， cl.患者， CASE MIN (si.顺序）
WHEN 2 THEN 'AP'
WHEN 3 THEN 'OR*
WHEN 4 THEN 'SF'
ELSE 'CL1 END AS索赔状态 FROM claims cl
INNER JOIN defendants dl ON cl.索赔号=dl.索赔号 CROSS JOIN claimstatuscodes si LEFT JOIN legalevents el ON (cl.索赔号=el.索赔号 AND dl.被告=el.被告 AND si.索赔状态=el •索赔状态）
WHERE el.索赔号 IS NULL GROUP BY cl.索赔号，cl.患者；
这个思路很有意思，但存在一个问题，如果claim_status有变动，就要同步维护这个 查询语句才行，否则返回的就是错误数据。 如果用LAG分析函数直接取库中的记录，就不会存在这种问题。
SELECT cl.索赔号， cl.患者，
• 333 •
Oracle查询优化改写技巧与案例
/*取seq最大的状态*/
MAX (lag_status) keep (dense一rank FIRST ORDER BY si •顺序> AS s FROM claims cl
INNER JOIN defendants dl ON cl.索赔号=dl •索赔号 CROSS JOIN (SELECT /*用lag 取上一个状态*/
lag (索赔状态）over (ORDER BY 顺序）AS lag—status,
索赔状态，
顺序
FROM claimstatuscodes) si LEFT OUTER JOIN legalevents el ON (cl.索赔号=el.索赔号 AND dl •被告=el. 被告AND si •索赔状态=el •索赔状态）
WHERE el.索赔号 IS NULL GROUP BY cl.索赔号，cl.患者；
14.33相等集合之零件供应商
这是一个SQL解惑的谜题，要求成对返回所有能提供完全相同的零件供应商。语句 如下：
DROP TABLE supparts;
CREATE TABLE supparts(
供应商编码CHAR (2) not null,
零件编码 CHAR (2) not null,
PRIMARY KEY (供应商编码，零件编码）)；
INSERT	INTO	supparts
SELECT	曹	'1'	FROM	dual	UNION	ALL
SELECT	'1*,	,2.	FROM	dual	UNION	ALL
SELECT /**/	•1、	.3.	FROM	dual	UNION	ALL
SELECT	'2、	1 3'	FROM	dual	UNION	ALL
SELECT	•2、，	'4'	FROM	dual	UNION	ALL
SELECT "*/	*2、	'5'	FROM	dual	UNION	ALL
SELECT	'3、	'1*	FROM	dual	UNION	ALL
SELECT		'2'	FROM	dual	UNION	ALL
SELECT /★*/	*3*,		FROM	dual	UNION	ALL
SELECT	M*,	'l1	FROM	dual	UNION	ALL
SELECT	'4 ',	*0*	FROM	dual	UNION	ALL
• 334 •
第14章改写调优案例分享
SELECT "V	,	*3'	FROM	dual	UNION	ALL
SELECT	•5',		FROM	dual	UNION	ALL
SELECT	•51,	.2,	FROM	dual	UNION	ALL
SELECT /**/	'5’，	'5!	FROM	dual	UNION	ALL
SELECT		1 lf	FROM	dual	UNION	ALL
SELECT	’6，，	» 4’	FROM	dual	UNION	ALL
SELECT		'5*	FROM	dual;
解惑中的方案都用了很多自关联，像这种求集合相等的需求用分析函数要简单得多。 用分析函数提出厂商的零件数，用内联提出两个厂商之间的相同零件数，只要这两个 数目相等，就说明两个厂商提供的零件完全一样。
SELECT供应商1,供应商2 FROM (SELECT a.供应商编码AS供应商1, b.供应商编码AS供应商2, MAX <a.零件数> AS零件数，COUNT (*) AS相同零件数
FROM (SELECT供应商编码，
零件编码，
COUNT (*) over (PARTITION BY 供应商编码）AS 零件数 FROM supparts) a INNER JOIN supparts b ON <a.零件编码=b.零件编码AND a.供应商编码<
b.供应商编码）
GROUP BY a.供应商编码，b.供应商编码）
WHERE零件数=相同零件数；
供应商1	i	供应商2 I

要注意处理这种问题的思路： ①关联后得到的数目是能匹配到的数目。
②关联前得到的数目是总数目。
这两个数据相等就说明两个集合相等。
14.34相等集合之飞机棚与飞行员
这也是来自SQL解惑的一个案例。描述如下：现有飞行员技能表（PilotSkills)和飞 机棚里所停飞机的列表（Hangar),要求找出能开飞机棚中所有飞机的飞行员。
• 335 •
Oracle査询优化改写技巧4案例
DROP TABLE PilotSkills; CREATE TABLE PilotSkills/*
(飞行员 CHAR (15) NOT NULL, 飞机 CHAR (15) NOT NULL, PRIMARY KEY (飞行员，飞机> );
INSERT	工NTO PilotSkills
SELECT	^elko', f	Piper Cub1 FROM DUAL UNION ALL
SELECT	• Higgins',	1B-52 Bomber	'FROM DUAL UNION ALL
SELECT	1 Higgins 1•	'F-14 Fighter* FROM DUAL UNION ALL
SELECT	• Higgins',	1 Piper Cub *	FROM DUAL UNION ALL
SELECT	* Jones', 1	B-52 Bomber'	FROM DUAL UNION ALL
SELECT	'Jones 1, 1	F-14 Fighter'	FROM DUAL UNION ALL
SELECT	'Smith','	B-l Bomber1 FROM DUAL UNION ALL
SELECT	* Smith1r 1	B-52 Bomber'	FROM DUAL UNION ALL
SELECT	• Smith' • *	F-14 Fighter1	FROM DUAL UNION ALL
SELECT	'Wilson1,	* B-l Bomber'	FROM DUAL UNION ALL
SELECT	'Wilson *•	1B-52 Bomberf	FROM DUAL UNION ALL
SELECT	'Wilson',	'F-14 Fighter' FROM DUAL UNION ALL
SELECT	'Wilson *,	*F-17 Fighter1 FROM DUAL;
DROP TABLE Hangar;
CREATE TABLE Hangar" "8^播V (飞机 CHAR(15) PRIMARY KEY);
INSERT 工NTO Hangar
SELECT •B-l Bomber' FROM DUAL UNION ALL SELECT 'B-52 Bomber* FROM DUAL UNION ALL SELECT fF-14 Fighter* FROM DUAL;
因为需求的目标是飞机棚里的飞机数，所以： ①要先得到飞机棚里的总飞机数，因为要同时返回飞机数与明细，这里可以用分析 函数。
②用飞行员信息左联飞机棚信息，这样可以得到飞行员会开的飞机数及能匹配到的 飞机数。
SELECT psl.飞行员，
COUNT (psl.飞机} AS飞行员会开的飞机数， COUNT (hi.飞机〉AS库中能开的飞机数， MAX (hi.机库里的飞机数）AS机库里的飞机数
• 336 •
第14章改写调优案例分享
FROM pilotskills psl
LEFT JOIN (SELECT COUNT (*) over () AS 机库里的飞机数，飞机 FROM hangar) hi ON (psl •飞机=hi •飞机）
GROUP BY psl •飞行员；
I 飞行员	飞行员会开的飞机数	能开的库中飞机数	机库里的飞机数
Higgins	3	2	3
Jones	2	2	3
Celko	1	0
Smith	3	3	3
Wilson	4	3	3
以上三个数目中，只要“库中能开的飞机数”与“机库里的飞机数”相等，就说明飞 行员会开飞机棚里的所有飞机。
那么对上面的语句添加一个过漶判断即可。
SELECT *
FROM (SELECT psl.飞行员，
COUNT (psl.飞机）AS飞行员会开的飞机数，
COUNT (hi.飞机）AS库中能开的飞机数，
MAX (hi.机库里的飞机数）AS机库里的飞机数 FROM pilotskills psl
LEFT JOIN (SELECT COUNT (*) over () AS 机库里的飞机数，飞机 FROM hangar) hi ON (psl.紇机=hi.飞机}
GROUP BY psl.飞行员）
WHERE库中能幵的飞机数=机库里的飞机数；
飞行员	飞行员会开的飞机数	库中能开的飞机数	机库里的飞机数
Smith	3	3	3
Wilson	4	3	3
可以看到，“Wilson”会开的飞机数有4个，比飞机棚里的飞机还要多，如果要求两 个集合完全相等，也就是飞行员会开且只会开飞机棚里的所有飞机呢？
很明显，我们再加一个过滤条件即可。
SELECT *
FROM (SELECT psl.飞行员，
COUNT (psl •飞机> AS飞行员会开的飞机数, COUNT (hi •飞机）AS库中能开的飞机数，
• 337 •
Oracle查询优化改写技巧与案例
max (hi.机库里的飞机数）as机库里的飞机数 FROM pilotskills psl
LEFT JOIN (SELECT COUNT (*) over () AS 机库里的飞机数，飞机 FROM hangar) hi ON (psl•飞机=hi.飞机〉
GROUP BY psl •飞行员）
WHERE库中能开的飞机数=机库里的飞机数/*会矛V AND飞行员会开的飞机数=机库里的飞机数/^7会矛*/;
飞行员	飞行员会开的飞机数	库中能开的飞机数	机库里的飞机数
Smith	3	3	3
体会到分析函数的好处了吗？希望通过本书的案例讲解，读者能尽早成为技术高手。
14.35用分析函数改写最值过滤条件
这是一个典型的取最大值的查询，语句中对B[LUNGS访问了两次：
SELECT emp_naine, SUM(hi.bill_hrs * bl.bill_rate) AS totalcharges FROM consultants cl, billings bl, hoursworked hi WHERE cl. eitip_id = bl. emp_id AND c1.emp_id = hi.emp_id AND bill_date = (SELECT MAX(bill_date)
FROM billings b2 WHERE b2.emp_id = cl.emp_id
AND b2.bill_date <= hi.work_date)
AND hi.work_date >= bl.bill_date GROUP BY emp_name;
通过这个语句可以分析需求，对主查询返回的每一组“ billings.emp_id, hoursworked.work date返回binings.bill_date最大值所在的行。这个需求分析是要点， 搞清楚这一点后，分析函数就好写了，根据“billings.emp—id, hoursworked.work_date”分 组，按biUingS.bill_date降序生成序号，序号为1的就是我们需要的数据：
SELECT b.emp_name, a.totalcharges
FROM (SELECT emp_idf SUM(bill_rate * bill_hrs) AS totalcharges FROM (SELECT bl.bill_rate, bl.emp_id, hi.bill_hrs,
rank() over(PARTITION BY bl.emp—id, hi.work_date ORDER BY bl.bill_date DESC) AS sn
• 338 •
第14章改写调优案例分享
FROM billings blf hoursworked hi
	WHERE	bl. emp__id =	h 1. emp_	_id
	AND	hi.work date	>=bl •	bill_date)
WHERE	sn = 1
GROUP	BY emp	一id) a
INNER JOIN consultants b ON b.emp一id = a.emp_id;
这种情景下使用rank或densejank是为了在有多个最值的情况下可以正确地返回多
条记录。
14.36用树形查询找指定级别的数据
本例是模拟一个网友的需求，现有emp表，以及用以下语句建立的级别表：
CREATE TABLE emp_level AS
SELECT empno,LEVEL AS lv FROM emp START WITH mgr IS NULL CONNECT BY (PRIOR empno) = mgr;
如下图所示，要求根据给出的lv大于2的empno (如：7876),找出其对应级别为2 (7566)的上级数据。
EMPNO 1 ENAME _]MGR ILV I
7839 KING		1
7566	7839	2
[7788^^6^5	4 7566	3j
7876 -AOAMC^5^7788		4 ；
因为给出empno的级别未知（在这个示例中可能是3级或4级），所以用JOIN语句 不好写，而用树形查询就比较简单，可以先把整个树形数据取出：
SELECT a.empno,a.ename,a.mgr,b.lv FROM emp a
LEFT JOIN emp_level b ON (b.empno = a.empno)
--WHERE b.lv = 2 START WITH a.empno = 7876 CONNECT BY ((PRIOR a.mgr) = a.empno AND (PRIOR b.lv) > 2);
EMPNO ENAME	MGR	LV
7876	ADAMS	7788	4
7788	SCOTT	7566	3
7566	JONES	7839	2
3	rows selected
• 339 •
Oracle查询优化改写技巧案例
我们前面说过，树形查询里的WHERE是对树形查询结果的过滤，所以再加上“WHERE b.lv = 2”就可以：
SELECT	sl • 6 nip no /		a.ename, b.		.lv
FROM	emp a
LEFT	JOIN	emp_	level	b ON	(b.	empno = a.empno)
WHERE	b. lv	=2
START	WITH	a.empno =		7876
CONNECT BY		((PRIOR a.		mgr)=	=a	.empno AND (PRIOR
EMPNO ENAME	LV
7566 JONES	2
1 row selected
14^7行转列与列转行
行转为列后可以进行列间的计算，列转为行后可以进行行间汇总，所以灵活地运用行 列转换可以解决很多需求的难题，下面是一个网友发的需求原图。
销售盈利表，如图•
门店	品牌		销量					»> . • ‘ •>
门店1*，	品牌1*		2一
门店i*	品牌2一		3•’
门店p	品牌3*1		2^			10^
门店2-	品牌		1*，			4*>
门店	品牌2*1		4*’			8^
门店~	岛牌3»'		4*»			20^
门店知	品牌1-，		3^			12-
门店>	品牌2-|		2..			4^
门店>	品牌>		1^			5^
鬌求一销售盈矛		报表如下《困碓奈晃求^				1费用合计一
品牌		门店^
•>		门店P		门店2-			门店>		合计一
销置合tF:		^ I		9. 1			6^
品牌1一		2^		1^\			3^		^ /
品牌2。		3^		4^			2^
品牌3〃		2♦’		4•’			1*>
收入合计。Q		24- |		32 一	1		21^		77^
品牌1*>		8- \		4^			12v Z
品牌2*>		6^ \		8•’			4._		18.
品牌3**		10^							35•’
费用合计，，		24* (7/^2) v'		24M9/22K |			24*(6/22).		«7
品牌 品牌 品牌3^		求舰剖■备d *门店1收入合 计*门店1收入 合th门店1收		.!胎1 3用合计=丨JJi 1销量岔计/销鲞思含计 门店2费用合计=门店2销量合计/销置总合 含计：门店3费用合计=门店3销置合计/销量总 入础^
• 340 •
第14章改写调优案例分享
values('	(门店lf,
values(丨	'门店1»,
values('	店
values('	店
values('	D店2\
values('	店 2»,
values('	I]店3丨,
values('	1门店
values(丨	店3丨,
t (a varchar2(30),
2
3 2 1
4 4 3 2 1
create table
：har2 (30));
insert	into	t
insert	into	t
insert	into	t
insert	into	t
insert	into	t
insert	into	t
insert	into	t
insert	into	t
insert	into	t
varchar2(30) , c varcharz(30) , d
m ;
,• 6 •);
,'10')；
,，4 ’）；
,• 8 -);
,'20');
,'12 ')；
,M ');
,• 5 1);
DROP TABLE t
我们先来生成案例用的数据:
因各门店是分行显示的，而销量与收入则分列显示，均与需求数据相反，所以要对数 据先做“行转列”操作，并进行计算，再进行列转行后把数据展示出来。
WITH Tl AS /★I.行转列*/
(SELECT GROUPING(T.B) AS GP_B, T.B AS品牌，
SUM(CASE	T.	、K	WHEN	店	1*	THEN	T_	,C	END)	AS	销量	门店	1,
SUM(CASE	T.A		WHEN	1门店	2'	THEN	T_	,c	END)	AS	销量	_门店	2,
SUM(CASE	T_	.A	WHEN	*门店	3*	THEN	T_	.c	END)	AS	销量_	_门店	3,
SUM(T.C)	AS销量_合计，
SUM(CASE	T.	.A	WHEN	，门店	1'	THEN	T,	.D	END)	AS	收入_	J1JS	1,
SUM(CASE	T,	.A	WHEN	f门店	2*	THEN	T.D		END)	AS	收入■	门店	2,
SUM (CASE	T.	.A	WHEN	，门店	31	THEN	T.	,D	END)	AS	收入	门店	3,
SUM(T.D) AS收入_合计 FROM T GROUP BY ROLLUP(T.B)
ORDER BY 1 DESC,2)
/★2.列转行*/
SELECT CASE WHEN GP_B = 1 THEN '销量合计，ELSE poW END AS 品牌, 销量—门店1 AS H店1,
销量一门店2 AS门店2,
销量店3 AS门店3,
销量_合计AS合计 FROM Tl
牌牌牌牌牌牌牌牌牌 品品品品品品品品品
• 341 •
Oracle查询优化改写技巧与案例
UNION ALL
SELECT CASE WHEN GP_B = 收入—门店1 AS污店1 收入_门店2 AS门店2 收入:门店3,
收入_合计AS合计 FROM T1
UNION ALL
SELECT CASE WHEN GP_B = round (销量_门店1 * round (销量_门店2 * round (销量_门店3 * 收入_合计AS合计 FROM T1;
结果如下，实现了图示需求。
1 THEN •收入合计'ELSE品牌END AS品牌,
1 THEN '收入合计，ELSE品牌END AS品牌, 收入_门店1 /销量_合计，2) AS门店1,
收入_门店1 /销量_合计，2) AS门店2,
收入门店1 /销量合计，2) AS门店3,
1 品 牌	门店1	门店2	门店3	』合 计 j
销量合计	7	9	6	22
品牌1	2	1	3	6
品牌2	3	4	2	9
品牌3	2	4	1	7
收入合计	24	32	21	77
品牌1	8	4	12	24
品牌2	6	8	4	18
品牌3	10	20	5	35
收入合计	7.64	9.82	6.55	77
品牌1	2.67	1.33	4	24
品牌2	2	2.67	1.33	18
品牌3	2.86	5.71	1.43	35
虽然Oracle提供了行列转换函数PIVOT与UNPIVOT，但对复杂的行列转换还是用 CASE WHEN 及 UNION ALL 容易实现。
• 342 •
第14章改写调优案例分享
14.38	UPDATE、ROW—NUMBER 与 MERGE
一名网友想用ROW_NUMBER来更改主键值，但会报错，想问什么原因。下面来模 拟该网友的操作。 首先建立测试用表如下：
DROP TABLE EMP2 PURGE;
* CREATE TABLE emp2 AS SELECT ★ FROM emp WHERE deptno - 10;
ALTER TABLE emp2 ADD CONSTRAINTS pk_emp2 PRIMARY KEY(empno);
要求按雇佣时间排序重新生成empno的数据（1、2、3…）：
UPDATE emp2 a SET a.empno =
(SELECT row_number() over(ORDER BY b.hiredate) empno FROM emp2 b WHERE b.empno = a.empno);
ORA-OOOOl :违反唯一约束条件（TEST.PK—EMP2)
这种更新方式让笔者想起了 “SQL解惑2”中“谜题56 ‘旅馆房间号’”的语句，当 然，那也是一个错误的语句。
UPDATE hotel SET room_nbr = (f loor_nbr ★ 100) + row_number () over (PARTITION BY floor_nbr);
ORA-30483: window函数在此禁用
我们回到正题，为了形象地说明在运行UPDATE时发生了什么问题，我们可以先把 pk_emp2 去掉。
ALTER TABLE emp2 DROP CONSTRAINTS pk_emp2;
UPDATE emp2 a SET a.empno =
(SELECT row_number() over(ORDER BY b.hiredate) empno FROM emp2 b WHERE b.empno = a.empno);
SELECT empno,ename FROM emp2;
EMPNO ENAME
1 CLARK
• 343 •
Oracle查询优化改写技巧与案例
1	KING
1	MILLER
3	rows selected
可以看到，UPDATE之后的empno都是I,这是因为这个语句的后面因“b.empno = a.empno”条件的限制ROW_NUMBER的部分是逐行执行的，既然只有一行数据，那么返 回的当然也只有1。找到原因就容易解决了，如果仍用UPDATE,就需要把子查询嵌套一 层：
UPDATE emp2 a SET a.empno =
(SELECT new_no
FROM (SELECT row—number 0 over(ORDER BY b.hiredate) new_no FROM emp2 b) b WHERE b.rowid = a•rowid);
SELECT empno, ename, hiredate FROM emp2 ORDER BY 3;
EMPNO ENAME
HIREDATE
1	CLARK
2	KING
3	MILLER 3 rows selected
1981-06-09
1981-11-17
1982-01-23
只是这种方式需要多次扫描子查询中有emp2,只适用于数据量少的情况。
这种情形可以使用MERGE来处理：
MERGE INTO emp2 a
USING (SELECT b.rowid AS rid,
row_number() over(ORDER BY b.hiredate) AS empno FROM emp2 b) b ON (b.rowid = a.rowid)
WHEN MATCHED THEN
•X i 1 1 «lfc 1
6 o- o o- o d
0 0 0 0 0.0 o o o o o Q ■«. ••«■ •«••• * _ o G o ob CD 0 0 0 0-0 0
o 0 0 000 ■ o o o o o o
• 344 •
第14章改写调优案例分享
UPDATE SET a.empno = b.empno;
SELECT empno, ename, hiredate FROM emp2 ORDER BY
EMPNO ENAME
HIREDATE
1	CLARK
2	KING
3	MILLER 3 rows selected
1981-06-09
1981-11-17
1982-01-23
这时只需要一次就可以，注意对比两个PLAN的Starts。
14.39	改写优化UPDATE语句
------------------------
学习了 MERGE语句后，一看到UPDATE语句，很多人想到的都是要改写为MERGE， 这种想法是错误的。下面这个语句改写为MERGE就没有用：
UPDATE t一00000000000000000000000 a SET a.status = -1 WHERE EXISTS (SELECT I
FROM (SELECT m.uuuuuuuuuuu, COUNT(★) cnt
FROM	m,	t_00000000000000000000000 n
WHERE m.sttttttt >= trunc(SYSDATE - 1)
AND m.pppp = substr(n.uuuuuuuuuuu, -2, 2)
AND m.uuuuuuuuuuu = n.uuuuuuuuuuu GROUP BY m.uuuuuuuuuuu HAVING COUNT(*) >= 1) b WHERE a.uuuuuuuuuuu = b.uuuuuuuuuuu);
MERGE•STATEMENT #
MERG?	'	•
.VIEW NESTED LOOPS VTEH :WINDOW. SORT
TABLE . ACC^SS	,
TABLE ACCESS BY USER ROWID
Operacioa
Starts
• 345 •
Oracle查询优化改写技巧与案例
.sifeWE | 3ytsa
Cperaciois ':
lejnpSpi
1 p	SJFB2.TS j
I 1..
| ”... 2
j . -3	xm-t職哪 i
I A	I：.,-1-^ ；jf
5	.1 ?i ;,'..:::纖|^^:;:::.續:議
I €	s-m [mmv 対' i
f j	.：'■； imsn v*0tu , i
i-\' !：»,.■	P&KTlttW 2JLST M.IJ
[• s	134254 ACCESS FULlj
i 10	1 AZC$3S PJLL 1
1 u	：；K5IA t
t^OOOOOOOOOOOOOOOOQOOOOOO
C_OQOQ0OQOOQO9Q00Q0060OG0
C~OQOOOOOOOOOOOOOOSOOOOOO
1 1 < | |	.；■ 1	I	84557
i 1 1 5 "S 7-4950 1	.1：" 2561KJ	:::'r i	B45&1M
1^339 t	131-73CI ：	»	:66-03« ；
…漏,:_鋳1	I317KJ	!
1 * I 74S-39 ||	1 ；28S«KJ	,,• 394MJ	'::輪翁:>
| 6533S8	...:::5獅3:.	52WI	2421?
I i4SSE| ；	35WI	1	2S2S
i ：	35MI	\	2S25：
3 I S-S93KI	114MI	1	17969
I I S593K{	13SNI		1^969-^
PredLLcace Infoimacion	r'j	operacioc s.s3):
access ("A". "uuaxlmatimauu
tx-i set (cqsnn acces- ("M". hpppp"= - '：35：'；- {"N". "jsuj
filter	卿杧	f2'i3,
.Hsyu»iauui!uua ">
luuauui
iCSXEt
iiiuu'-tuu",
—in
elecced.
因为改为MERGE的目的是为了让语句走HASH JOIN或NESTED LOOP。而这个语 句本身就是HASH JOIN。
下面分析一下这个语句及PLAN。
①m.pppp = substr(n.uuuuuuuuuuu，-2，2)写法是错的，这样写把本应在id=9中发生的 过滤推迟到了 HASH JOIN 的时候，应该写为 m.pppp = substr(m.uuuuuuuuuuu，-2，2),因为 有条件 m.uuuuuuuuuuu = n.uuuuuuuuuuuo
②语句中的count(*)>=l是多余的，因为关联列m.uuuuuuuuuuu就是group by后面的
列，既然能关联到数据，条数肯定就不会小于1。
那么语句就可以改为：
UPDATE t一00000000000000000000000 a SET a.status = 一1 WHERE EXISTS (SELECT 1
FROM (SELECT m.uuuuuuuuuuu
FROM	m,	t_00000000000000000000000 n
WHERE m.sttttttt >= trunc(SYSDATE 一 1)
AND m.pppp = substr(m.uuuuuuuuuuu, -2, 2)
AND m.uuuuuuuuuuu = n.uuuuuuuuuuu GROUP BY m.uuuuuuuuuuu) b WHERE a.uuuuuuuuuuu = b.uuuuuuuuuuu);
现在可以看到最内层的n除了关联一次，没有其他作用，而在外层有一个重复的关联 条件。所以，可把这个n去掉，并去掉一个嵌套：
UPDATE t_00000000000000000000000 a SET a.status
=-
_........ ...... .......
--y. y ■
I Pjjtart: I Ba
XOQi'
100
1
J
I
I
I
53. s 3!._ ^ 4 66 i s 2. 1 ^.5J3.33-s一 6..*313:3:e:. S...0;3:3;I
i 1 s, 1 & 0 ol-o.-oj.
m：^
20:2
卯
00:1
00:0：
00:0
輝_
00:0
S'353).3).
0	(((
1
-y/. ty, v» -fcl- If 3 2 7 2 2
• 346 •
第14章改写调优案例分享
I	1
I OCtOliiX I 14 .' I 00:02; 31 i
•	LOOPS
2CSkT UWigSFS
Kwriirw .war 科,:: TM1S if?tES5 f?li :
OOOOOOOOOO'QObOOOO
Predicate Isfora»ciea (• u. . ^ i ； = i l , op«raclo£ - J)
rarr->i)
ajamainu' iuuxrauuss'
一 -■ i "H". "UHnuunuaiJUQ *■*•»•*. *irBuauauiRn3a-)
二（•*»«” •.wpi>pp"_..'-K .	(-Mf, *uuuaa'juuauB-, -2,2| v；. •M-, -5=ttfcctt">- C
Bytes
o：ea：5i
通过这个PLAN可以看到，两个过滤条件在HASH JOIN之前就执行了，效率提高了
很多.
14.40	改写优化UNION ALL语句
UNION ALL语句可供优化的并不多，大多是有相应的环境及条件，语句如下:
col7, col8,
col28, •collO,
SELECT COUNT(★>
FROM (SELECT coll, col27 f col28, col2, col3, col4, col5f col6, col9, collO, col20, col21, col22, col23, col24f col25, col26
FROM ((SELECT l.coll, o.col2_l AS col27f o.col28 AS 1.col2, 1.col3, 1.col4, 1.col5, 1.col6, l.col7, 1.col8, 1.col9, 1.
1.col20, 1.col21, l.col22, l.col23, 1.col24r 1.col25, 1.col26 FROM 1, o WHERE l.col4 = *0'
AND 1.col5 = o.o—id)
UNION ALL
(SELECT 1.coll, a.col2一 1 AS col27, a.col28 AS col28, 1.col2, 1.col3, 1.col4, 1.col5 f 1.col6f 1.col7f l.col8, 1.col9, 1.collO, l.col20, 1.col21, l.col22, 1.col23, 1.col24, 1.go125. 1,col26
WHERE a.uuuuuuuuuuu IN
(SELECT m.uuuuuuuuuuu FROM	m
WHERE m.sttttttt >= trunc(SYSDATE - 1)
AND m.pppp = substr(m.uuuuuuuuuuu, -2, 2));
这样改后的PLAN为：
star, va.v: 411306SS52
:ns12i:01 Esl
!:;;§ § itsHl
15 933
1
lS95d
15939
issrr
1S957
S603K
• 347 •
Oracle査询优化改写技巧与案例
			FROM	1-	.a
			WHERE	1	.col4 =	='Af
			AND	1,	.col5 =	a. a_	_id)
			UNION	ALL
			(SELECT	1.coll,		p.col3_l		AS col27,	AS	col28 f	1.col2f
1	.col3,	l.col4f 1	.col5f	1.	col 6,	1.col7, 1,		.col8, 1-col9,	1.	collO,	1.col20,
1	.col21,	l.col22,	1.col23,		l.co!24f 1		.col25, 1.col2 6
			FROM	1-	r P
			WHERE	1	.col4 = fP'
			AND	1.	■ col5 =	P-P.	_id))	t
		WHERE	(col2 =	f	TCBANK	1 OR	co 13	=•SELLERWANG'))		xtlOO
这个查询中访问了三次1表，三个UNION ALL中的差异条件列col4是一个type字段， 这种字段的选择性较低。
经确认，三个UNION中的1表果然都是TABLE ACCESS FULL。
因此，这里应该把丨表提出来，另外三个0、a、p表先进行UNION ALL操作，进行 UNION ALL操作时可以使用一个小技巧，生成列col4以作为JOIN用：
SELECT COUNT(	*)
FROM (SELECT 1		.coll, t.col27, t.col28, 1.co!2, 1.col3,	l.col4f 1	.col5,
1.C0I6, 1.C017, 1.	,col8, 1.col9f l.collO, 1.col20, l.col21r 1.		col22, 1.	col23,
1.col24, 1.col25,	1.	.col26
FROM	1
INNER	JOIN (SELECT o_id, col2_l AS col27f col28 AS col28,			f0* AS
col4 FROM 0		UNION ALL
		SELECT a_id AS o_id a.col2_l AS col27, a.	,col28 AS	col28,
'A' AS col4 FROM	a	UNION ALL
		SELECT p_id AS o_id, col3_l AS co!27f 1	'AS col28, fP'
AS col4 FROM p) t
ON	(t,	.o_id = 1.col5 AND t•col4 = a.col4)
WHERE	l.col4 IN (•〇•， 'A1f 'P1)
AND	(1	• col2 = * TCBANK1 OR l.col3 = * SELLERWANG	'))xtlOO
这样丨表就只访问了一次，而且UNION ALL内的列col4保障了 JOIN时各表间的对
应关系。
这种改写方式能提升的效率在于1表访问一次与三次的时间差别。
• 348 •
第14章改写调优案例分享
城s' <v—.r.—■»/) | t^jw
psc&m Pstop
^'7IK (2>!
I
42H
42U
被 RGC .....	...
viz»
soat suscr at
HA5K SOIU WEH3T .-OIK: CfiKTSSIW*
?*5?TTTJC«J SUiJGE
ACCE55 3Y 'uh£^. wmx won联 sew?
scrrm 5W f«Tit i or smm hi£::：r mati ^ctss 'tjlu
TAfilC XCCC35 FULL
14.41	纠结的MERGE语句
网友发来语句及PLAN,问能不能把buffer sort去掉。语句如下:
MERGE INTO a
USING (SELECT t.id, t.cp_id7 t.cp_name, t.price
FROM	t, a	tl
WHERE	tl.b_	date =	:*20130101 *
AND	t.b一date =		’20130101'
AND	tl.state =		0
GROUP	BY t.	.id, t.	cp_id, t.cp_namer t.price)
ON (ng.id =	a. id)
WHEN MATCHED	THEN
UPDATE
SET a.cp	id =	ng•cp_	id, a.cp_name = ng.cp一name,
WHERE a.b	date	=T20130101T;
这个语句的问题在于子查询里没有关联条件，是一个笛卡儿积，而且tl表在该子查 询里没有用到。于是加关联语句如下：
MERGE INTO a
USING (SELECT /*+ opt_param (•—optimize r_mjc 一enabled *,	1	false*)	*/
t.id, t.cp_id, t.cp_name, t.price FROM tf a tl WHERE t.id = tl.id
AND tl.b_date = *20130101'
AND t.b_date = 1201301011 AND tl.state = 0 GROUP BY t.id, t.cp_id, t.cp name, t.price) ng
i
i
i
3 3 3 .■»*? 1 1V3 3
3 3 5 1 I
i 1 1
s 8 s I J 2 .s 8 I ,• i ioo Q I I 10
4.-4:4:识0:^:4!*1<:>0: 333'01.C5OJ33301 1 1-1000111^ 3 0 0 0 o.o'a6-0 0
2>2)2><0>叫 S"2»<2)I2>S
1R1K1K& o &IKITCIKS
Cr T «17 1 4 i 4 4 4
Bytes , 384
424
424
323
27
21
13,S HQ 11G 301
ON (ng.id = a.id)
Oracle查询优化改写技巧与案例
WHEN MATCHED THEN UPDATE
SET a.cp_id = ng.cp_id, a.cp_name = ng.cp—name, a.value3 = ng.price WHERE a.b_date = '201301011;
该查询中，a.id与t.id分别是两个表的唯一列，通过分析语句可以得出其对应的 UPDATE语句应该为：
UPDATE a
SET	(a•cp_id,		a •	cp_	name, a.value3)=
	(SELECT	t	.cp	一id,	t.cp name, t.price
	FROM	t
	WHERE	t •	,id	=a	.id
	AND	t.	b_date		==^OISOIOIV)
WHERE	a.b_date		-	f20130101'
AND	a.state =		:0
AND	EXISTS	(SELECT			t.cp id, t.cp name,
	FROM	t
	WHERE	t.	.id	=a	• id
	AND	t.	b date		=*20130101*)
而上面的MERGE语句是一个错误的改写，正确的写法应该为:
MERGE INTO (SELECT *
FROM a
WHERE b date = '20130101'
	AND s	tate		:0) a
USING (SELECT /*+		opt	—param(’—optimizer-mjc—enabled，， 'false') */
t. id,	t. cp_	id,	t •	cp_name, t.price
FROM	t
WHERE	t.b_date		=	'20130101'
GROUP	BY t.	id,	t.	cp一id, t.cp_name, t.price) ng ON (ng.id = a
WHEN MATCHED	THEN
UPDATE
SET a.cp_id = ng.cp_id, a.cp—name = ng.cp—name, a.value3 = ng.price
希望通过这个例子能让更多的人学到如何使用MERGE,以提高更新数据的效率。当 然，那个hint现在没有用了，可以去掉它。
• 350 •
第14章改写调优案例分享
14.42	用 CASE WHEN 去掉 UNION ALL
下面这个语句有点长，因取值条件及分类汇总方式的不同，用了三个UNION ALL语 句来组合数据。
'0101'
select case when substr (a. dept一				id,1,4)	=’0101丨	r then
when	substr(a _	.dept	_id,l,4)	=’0102,	then 1	,0102’
when	substr(a.	.dept_	.id, 1,4)	=,0103’	then '	'01031
when	substr(a.	.dept_	•id,1,4)	=f 0104'	then '	'0104'
when	substr(a.	.dept_	.id,1,4)	=,0105*	then 1	'01051
when	substr(a.dept_idf1,4) = '010 61	then * 010 6'end
dept,
a. dept_id dept—id, nvl ( (select dept. c_dept_name from infor—dept dept where dept. c—dept—id = a. dept一id),'合计') as c_dept_name,
sum(m2013) m2013,sum(ps2 013) ps2013,sum(sl2013) sl2013, sum(vm2013)	vm2013,sum(vps2013)
sum(vsl2013) vsl2013,
sum(m201311)m201311,sum(ps201311) sum(sl201311) S1201311,
sum(m201313) m2 01313,sum(ps201313) sum(sl201313) S1201313,
sum(m201312) m201312,sum(ps201312) sum(sl201312)	sl201312,
sum(m2012) m2012,sum(ps2012) ps2012,j sum(vm2012)	vm2012,sum(vps2012)
sum(vsl2012) vsl2012 ,
sum(m201211) m201211,sum(ps201211) sum(sl201211) S1201211,
sum(m201213) m201213,sum(ps201213) sum(sl201213)	sl201213,
sum(m201212)	m201212,sum(ps201212)
sum(sl201212)	sl201212
from (
select /*+ index (s I_BI__XY) */ substr (s • c_dept■一 id, 1, 6) as dept—id ,
sum(n_m+n_de_discc_b) m2013,count(distinct s.c_detail_id) ps2013, sum(s.n_num) sl2013,
sum(decode(s•c_s—type, '011, (s,n_m+s.n_de_discc_b))) vm2013, count ( distinct decode(s.c_s_type,'01',s.c_detail_id))vps2013 ,
vps2013,sum(vrs2013)
ps201311,sum(rs201311)
ps201313,sum(rs201313)
ps201312/sum(rs201312)
,sum(sl2012) s12012, vps2012,sum(vrs2012)
ps201211,sum(rs201211)
ps201213,sum(rs201213)
ps201212,sum(rs201212)
rs2013.
rs201311,
rs201313,
rs201312.
vrs2012/
rs201211/
rs201213,
rs201212,
• 351 •
Oracle查询优化改写技巧与案例
count( distinct decode(s•c—s—type,•01 *,s•c一cust_id)} vrs2013f sum(decode(s.c_s_type,•01 *,s.n_num)) vsl2013f sum(decode(s•c_v_type,，11 *, (s•n_m+s.n一de一discc一b))〉m201311, count( distinct decode(s.c_v一type,
type,'	11	*, s«	.c_detail一id)) ps201311.
type,'	11	，，s.	.c_cust_id)) rs201311.
n_num)	)S1201311,
;.n m+s	.n	de	_discc_b))) m201313,
type,'	13	、s,	.c_detail_id)) ps201313.
type,,	13	1 f S.	.c cust id)) rs201313f
count( distinct decode(s.c_v_type, count( distinct decode(s.c_v_type, sum(decode(s.c_v_type,'13',s.n_num)) sl201313, sum(decode(s.c_v_type,'121,(s.n_m+s.n_de_discc_b))) m201312, count( distinct decode(s.c_v_type,112*,s.c_detail_id)) ps201312, count( distinct decode(s•c_v一type,’12•,s•c_cust_id)) rs201312, sum(decode(s.c—v_type,1121,s.n_num)) sl201312,
0	m2012,0 ps2012,0 sl2012,
0	vm2012,0 vps2012 r0	vrs2012,0	vsl2012,
0	m201211,0	ps201211,0	rs201211/0	sl201211,
0	m201213,0	ps201213,0	rs201213/0	sl201213,
0	m201212/0	ps201212,0	rs201212,0	sl201212
from bi s
where s . d—retail—time>=to—date (' 20131101' , ' yyyyinmdci') and s . d一retail—time<to_date (' 201312011 , 1 yyyymmdd') and s.c一dept 一id like 101%' group by substr(s.c— dept 一id,1,6〉
union all
select /*+ index (s I_BI_XY) */ substr (s. c—dept一id, 1, 6) as dept一id ,
0 m2013,0 ps2013,0 sl2013,
0	vm2013,0	vps2013 ,0	vrs2013,0	vsl2013,
0	m201311r0	ps201311,0	rs201311,0	sl201311,
0 m201313,0 ps201313,0 rs201313,0 sl201313,
0 m201312,0 ps201312,0 rs201312,0 S1201312,
sum(n—m+n_de_discc一b)	m2012,count(distinct s.c_detail_id) ps2012
sum(s.n_num) sl2012,
sum(decode(s.c_s_type,*01',(s.n_m+s.n_de_discc_b))) vm2012, count( distinct decode(s.c_s_type, '01'f s.c_detail_id))vps2012 , count( distinct decode(s.c_s_type,•01，，s.c一cust一id)) vrs2012, sum(decode(s.c_s_typef•01 *,s.n_num)) vsl2012, sum(decode(s.c_v_type,'11', (s•n_m+s.n_de_discc_b))) m201211, count( distinct decode(s,c_v_type, 1111f s.c_detail_id)) ps201211, count( distinct decode(s.c_v_typef111 *,s.c_cust_id)) rs201211,
• 352 •
第14章改写调优案例分享
sum(decode(s.c_v一type,111',s.n_num)) sl201211,
sum(decode(s.c_v_type,,13t,(s.n_m+s.n_de_discc_b))) m201213,
count( distinct decode(s.c_v_type,'131,s.c_detail_id)) ps201213,
count( distinct decode(s.c_v_type,f13 *,s.c_cust_id)) rs201213r
sum(decode(s•c_v_type,'13 *,s.n—num)) sl201213,
sum(decode<s.c_v一type,* 121, (s.n_m+s.n_de_discc_b))) m201212,
count( distinct decode(s.c_v_typer'12',s.c_detail_id)) ps201212,
count( distinct decode(s•c一v—type,，12 *,s.c一cust一id>) rs201212,
sum(decode(s.c一v一type,'12 f,s.n_num)) S1201212
from bi	s
where s . d_retail一time>=to一date (1 201211011 , 1 yyyymmdd') and s . d_retail_time<to__date (' 20121201' , , yyyymmdd1) and s.c 一dept一id like '01%' group by substr (s . c一dept_id,1,6)
)a group
by rollup (case when substr(a.dept一id,1,4) = ’0101• then * 0101'
when	substr (a.dept_	_id,l	4)=	!0102'	then	'0102'
when	substr (a. dept_	_id,l	4)=	'0103'	then	•0103,
when	substr (a. dept_	_id,l	4)=	’0104,	then	•0104,
when	substr (a. dept_	id,l	4)=	^ios'	then	'0105'
when	substr (a. dept_	_id,l	4)=	^oioe*	then	•0106
a. dept一id )
union all
select case when substr (a.dep^id, 1, 2) = ' 02 * then 1 02 'end dept, a. dept_id dept_id, nvl ( (select dept. c_dept_name from inf or 一 dept dept where dept. c_dept_id = a • dept一id)"合计，> as c_dept_name,
sum(m2013) m2013,sum(ps2013) ps2013,sum(sl2013) sl2013, sum(vm2013)	vm2013,sum(vps2013)
sum(vs12013) vsl2013,
sum(m201311)	m201311fsum(ps201311)
sum(sl201311) S1201311,
sum(m201313) m201313,sum(ps201313) sum(sl201313)	S1201313,
sum(m201312) m201312,sum(ps201312) sum(sl201312)	S1201312,
sum(m2012) m2012,sum(ps2012) ps2012,sum(s12012) sl2012, sum(vm2012)	vm2012,sum(vps2012)	vps2012,sum(vrs2012)
sum(vsl2012) vsl2012 ,
sum(m201211) m201211,sum(ps201211)	ps201211,sum(rs201211)
sum(sl201211) S1201211,
vps2013/sum(vrs2013) ps201311fsum(rs201311) ps201313,sum(rs201313) ps201312/sum(rs201312)
vrs2013,
rs201311,
rs201313,
rs201312.
vrs2012,
rs201211,
• 353 •
Oracle查询优化改写技巧Sf案例
sum(m201213)	m201213,sum(ps201213)	ps201213fsum(rs201213)	rs201213,
sum(sl201213)	sl201213,
sum(m201212)	m201212/sum(ps201212)	ps201212fsum(rs201212)	rs201212,
sum(S1201212)	sl201212
from (
select /*+ index(s I_BI_XY) */ substr(s.c一dept一id,1,6) as dept—id , sum(n_m+n_de_discc_b) m2013,count(distinct	s.c一detail一id)	ps2013,
sum(s.n_num) sl2013,
sum(decode(s.c_s_type,'01',(s.n_m+s.n_de_discc_b))) vm2013,
count( distinct decode(s.c_s_type,'01',s.c_detail_id))vps2013 ,
count( distinct decode(s•c_s_type,'01•,s.c一cust—id)) vrs2013,
sum(decode(s•c一s_type,101 *,s.n_num)) vsl2013,
sum(decode(s.e_v_type, '11', (s•n一m+s•n一de_discc—b)>) m201311f
count( distinct decode(s.c_v_type,'11f,s.c_detail_id)) ps201311,
count( distinct decode(s.c一v一type,1111,s•c一cust一id)> rs201311r
sum(decode(s.c_v_type,’111,s.n_num)) sl201311,
sum(decode(s.c_v_type,113',(s.n一m+s•n_de—discc_b)}) m201313/
count( distinct decode(s.c_v_type,'13',s.c_detail_id)) ps201313,
count( distinct decode(s.c_v_type, '13'f s.c_cust_id)) rs201313,
sum(decode(s.c_v_type,'13 *,s.n_num)) sl201313,
sum(decode(s.c_v_type,'12 f, (s.n_m+s.n_de_discc_b))) m201312f
count( distinct decode<s.c—v_type,•12•,s.c_detail_id)) ps201312,
count( distinct decode(s•c一v_type,112•,s.c一cust—id)) rs201312,
sum(decode(s.c_v_type, '12 f,s.n_num)) sl201312,
0	m20l2/0 ps2012,0 sl2012r
0	vm2012f0 vps2012 ,0	vrs2012,0	vsl2012,
0	m201211,0	ps201211f0	rs201211,0	sl201211,
0	m201213,0	ps201213,0	rs201213,0	sl201213,
0	m201212f0	ps201212#0	rs201212,0	sl201212
from bi	s
where s.d—retail—time>=to_date('20131101','yyyymmdd') and s .d_retail_time<to—date ('201312011 , 'yyyymmdd') and s.c一dept—id like * 02%1 group by substr(s.c—dept 一id,1,6)
union all
select /*+ index (s I_BI_XY) */ substr (s . c一dept一id, 1, 6> as dept一id ,
0 1112013,0 ps2013/0 sl2013,
0	vm2013,0	vps2013	,0	vrs2013,0 vsl2013f
0	m201311, 0	ps201311, 0	rs201311f 0	sl201311,
0 m201313,0 ps201313/0 rs201313/0 sl201313,
• 354 •
第14章改写调优案例分享
0 m201312,0 ps201312r0 s um (n_m-fn_de_di s cc—b) sum(s.n_num) sl2012,
sum(decode(s.c_s—type, count( distinct decode count( distinct decode sum(decode(s.c—s一type, sum(decode(s.c_v_typef count( distinct decode count{ distinct decode sum(decode(s.c—v一type, sum(decode(s.c_v_type, count( distinct decode count( distinct decode sum(decode(s.c_v_type, sum(decode(s.c_v一type, count( distinct decode count( distinct decode sum(decode(s.c—v一type, from bi
where s.d—retail and s.d_retail一 and s.c 一dept 一 id like group by substr(s.c_
rs201312,0 sl201312f m2012,count(distinct
LI 一 time〉:
01f, (s•n_m+s•n_de_di s cc_b))) vm2012, s.c_s_type,•01 *,s.c_detail_id))vps2012 , s.c一s—type,'01 *,s.c_cust_id)) vrs2012,
011,s.n—num))	vsl2012,
111, (s.n_m+s.n一de—discc_b" ) m201211, s.c_v_type,'11',s.c_detail_id)) ps201211, s.c_v_type, '111,s.e_cust_id)) rs201211,
111,s.n_num)) sl20121Xf 13*, (s.n_m+s.n_de_discc_b))) m201213, s.c_v_type,'131,s.c_detail_id)) ps201213, s.c—v_type,'131,s.c_cust_id)) rs201213,
131f s.n_num)) sl201213,
12、(s.	n_m+s . n_de_discc_b) ) ) m2 01212,
s.c_v_type,'121,s.c_detail一id)) ps201212, s.c_v_typef* 12•,s.c_cust_id)) rs201212,
12',s.n_num)) sl201212 s
to一 date('20121101•,•yyyymrndd') date('20121201 • , ’yyyymmdd」
02%' pt id,1,6)
'02' then '02'end
)a
group by rollup (case when substr(a.dept_id,1,2): a.dept_id ) union all
select case when substr(a.dept_idf1# 2) = * 03' then '03 * end dept, a .dept一id dept 一 id, nvl ( (select dept. c_dept_name from infor_dept dept where dept. c一dept_id = a.dept__id) , '	*) as c_dept—name,
sum(m2013) m2013,sum(ps2013) ps2013,sum(sl2013) sl2013, sum(vm2013)	vm2013,sum(vps2013)
sum(vsl2013) vsl2013 ,
sum(ra201311) m201311,sum(ps201311) sum(sl201311) S1201311,
sum(m201313) m2 01313 fsum(ps201313) sum(sl201313)	S1201313,
sum(m201312) m201312,sum(ps201312) sum(sl201312)	S1201312,
vps2013,sum(vrs2013) ps201311/sum(rs201311) ps201313fsum(rs201313) ps201312,sum(rs201312)
vrs2013,
rs201311,
rs201313,
rs201312,
• 355 •
Oracle查询优化改写技巧与案例
vps2012,sum(vrs2012) ps20l211,sum(rs201211) ps20l213,sum(rs201213) ps201212,sum(rs201212)
sum(m2012) m2012,sum(ps2012) ps2012fsum(sl2012) sl2012 sum(vm2012)	vm2012,sum(vps2012)
sum(vsl2012) vsl2012,
sum(m201211)	m201211/sum(ps201211)
sum(sl201211) S1201211,
sum(m201213) m201213,sum(ps201213) sum(sl201213)	sl201213,
sum(m201212) m201212,sum(ps201212) sum(sl201212)	S1201212
from (
select /*+ index (s I__BI_XY) */ s. c_dept_id as dept一id , sum(n_m+n_de__discc_b)	m2013,count(distinct	s.c_detail_id)
sum(s.n_num) sl2013,
sum(decode(s.c—s—type,101',(s.n_m+s.n一de—discc—b))) vm2013,
count ( distinct decode(s,c_s_type,101',s.c_detail_id)) vps2013 r
count( distinct decode(s•c_s_type,•01•,s•c一cust一id)> vrs2013,
sum(decode(s•c_s_type,* 01',s,n_num)) vsl2013,
sum(decode(s.c_v_type,'11'r (s.n_m+s.n_de_discG_b))) m201311,
count( distinct decode(s•c—v一type,•11 *,s•c一detail_id)) ps201311,
count( distinct decode(s.c_v_type,* 11 * f s.c_cust_id)) rs201311,
sum(decode(s•c_v—type,* 11•,s.n_num)) sl201311,
sum(decode(s.c一v—type,•131,(s.n_m+s.n_de_discc_b))) m201313,
count( distinct decode(s.c一v—type,•13•,s.c—detail_id)) ps201313,
count( distinct decode(s.c_v_type,'131,s.c_cust_id)) rs201313,
sum(decode(s•c—v_type,113 *,s.n_num)) sl201313,
sum(decode(s.c_v_type,* 121, (s.n_m+s.n_de_discc_b))) m201312,
count( distinct decode(s•c一v一type,* 121,s•c_detail一id)) ps201312,
count( distinct decode(s•c—v一type,’12s•c_cust_id)) rs20l312f
sum (decode (s. c_v_type, ' 12 ', s . n__num) ) sl201312,
0	m2012,0 ps2012,0 sl2012,
0	vm2012f 0 vps2012 ,0	vrs2012,0	vsl2012,
0	m201211,0	ps201211,0	rs201211f0	sl201211,
0 m2Q1213,0 ps201213,0	rs201213,0	sl201213,
0	m201212,0	ps201212,0	rs201212/0	sl201212
from bi	s
where s . d_retail一time>=to一date (' 20131101 • , ' yyyymmdd') and s .d一retail_time<to一date ('201312011 • 'yyyymmdd') and s.c_dept—id like * 03%' group by s . c_dept__id
union all
vrs2012,
rs201211,
rs201213,
rs201212/
ps2013.
• 356 •
第14章改写调优案例分享
select /*+ index(s I_BI_XY) */ s.c_dept_id as dept一id 0 m2013,0 ps2013,0 sl2013,
0	vm2013f	0	vps2013 ,0	vrs2013,0 vsl2013f
0	m201311,0 ps2013U,0	rs201311,0	S1201311,
0	m201313,0	ps201313,0 rs201313,0 S1201313,
0	m201312,0 ps201312,0 rs201312,0 sl201312,
m2 012,count(distinct
s um (n_m 十 n—de 一cii s cc—b) sum(s.n num) sl2012,
s.c_detail_id)	ps2012,
count<
sum(decode(s.c
(s.n_m+s.n_de_discc_b))) vm2012, s•c_s_type,101',s.c_detail_id))vps2012 s.c_s—type, f 01 *,s.c_cust_id)) vrs2012, r s.n num)) vsl2012,
_m-f-s . n_de_discc_b) ) ) m201211 „ pe, * 11 *,s•c_detail_id)) ps201211, s.c_v_typef * 11 *,s•c_cust_id)) rs201211, s.n_num)) S1201211,
(s.n—m+s.n_de_discc_b))) m201213,
r131,s.c_detail_id)) ps201213, s.c_v_typef'131,s.c—cust一id)) rs201213,
,s.n_nuin) ) sl201213,
(s.n_m+s.n_de_discc_b))) m201212, s.c_v_type,* 12 *,s•c_detail_id)) ps201212,
—___	112 1, s . c cust id) ) rs201212,
de (s . c_v_type, ' 12 1, s.n_num) ) s
from bi
where s . d_retail一ti and s. d_retail_time<to__date (' 20121201' • ' yyyymmdd') and s.c_dept 一id like '03%' group by s•c 一dept 一id
)a
group by rollup (case when substr(a.dept_id,1f2)='03' then 103'end a.dept—id );
一type,	◦ 1,,	(s
decode	s • c_	s 一
decode	s. c	s
—type.	01，,	s.
—type.	11.,	(s
decode	s • c一	V
decode	s. c	V
—type,	11’,	s.
_type,	13’,	(s
decode	s.c_	V
decode	s. c	V
—type.	13’,	s.
一 type,	12’,	(s
decode	s. c_	V
decode	s. c	V
—type.	12、	s.
	s
这个语句主要部分的PLAN如下：
• 357 •
Oracle查询优化改写技巧4案例
1680MI	}	1QS4K
	'• 1 ,I	I-67E
1	1	I6-7K
1 i.BHf	1 23H)	19320
1€HJ 1	I 1	14233 9603
15M|	23Mf	149K
16K> r	1 I	14.5K 1-I1S7
12S2UI	1	721K
22fi2M|	1	720K
76KI	11-9MI	52499
emt	I	52701
	• ：l	203^7
76MJ	ll^Mt	"66SK
ei«i 1	« 1	64SK •14IS?
333«|	1	205K
3S3MI	<	205E
I' 19B|	t 2SMI	20594
21131 1	1 \	IS442 9603
19MI	25M(	Ifi4K
21U|	f	173K
1 14157
^LECT srAr«ME!fI
mm- G84XJF SS R01.U3B
::::V1SW	* ' ■,
■tw-jyx' scwcr Gsxm- Bi1
T^3i£ access ar itsoty. sosrir
UiDSX SKIP SCAK 9CKT SKCQ? ay IA3LE &CCES3 BY 3M0SX R3KZC j«DEX SAN-3E 3C£S SORT SROCF 3T 5BSX5P VIKtt CN2ON-ALL ；50ftT GnmB' BT
tabix access 鮮 nmm I；SBEK	5CKS9
S0KT {31<3^3 HI
Y&air ;^^fcss m zmEx ndmv
iSSCX 卿SE. 3CAJJ.
SCSRT OT03P 3f aOLiUF 'VIXVf
sjnoot-js^
aaJRl GROTf 27
1A3LE ACCES3 3? 13JD2X BOWXE ISDEX SIHP 3C3U5 30KI C-m：^ IX TASLE &60ESS 3? 'lUSSEH.卿iD iwaEx mifss. seas?.
这个语句虽然很长，但通过PLAN来看反而更清晰，其架构是UNION ALL中嵌套了 UNION ALL：
SELECT xxx	FROM	(SELECT	xxx	FROM	bi	s UNION	ALL	SELECT	xxx FROM bi s) a
UNION ALL
SELECT xxx	FROM	(SELECT	xxx	FROM	bi	s UNION	ALL	SELECT	xxx FROM bi s) a
UNION ALL
SELECT xxx	FROM	(SELECT	xxx	FROM bi		S UNION	ALL	SELECT	xxx FROM bi s) a;
所以，第一步就是要搞清楚几个UNION ALL的区别，那么可以先忽略对结果影响不 大的无关列，只保留原语句中粗体字部分：
SELECT CASE
WHEN substr (a •OlOl1	.dept_	id,	lr	4)-	•0101，	THEN
WHEN substr (a •0102.	• dept_	jld,	1,	4)=	'0102'	THEN
WHEN substr(a 'OIOS*	• dept_	_id,	1,	4)=	•0103,	THEN
WHEN substr(a ,0104*	.dept	_id,	1,	4)=	'0104'	THEN
WHEN substr(a.dept_ ,0105’		id,	lf	4)=	'01051	THEN
WHEN substr(a	• dept_	_id,	1/	4)==	^loe'	THEN
-9 2 2 0162306 2 0342 4032 3 6 6 5 3 0 -4 3 3 «*5S505 ^«1 33Q«-a-soo o o s 5 s s !8:3:3;3:2.rl:9:"#"254:4:0:6:2:3:9:2:l:Iihs:i:6:5':2:
-3 .3 3 0 0 0 2 2 0 2 2 1 ff fl 1 € 4 c. o c o 5 3 o f ‘• .■■■rp.*,•••• •• •• •• •• •• •• .»• ■■.'.'£ •• «« X «■ -•■- s £ .•• 2 _ 3 J'0:o 150000022 IOO&2 2OO0-IOOGOOC
to .© o oooooooo o .o.: o o o 0 0 6 ooclooo.
K IKK 1*KK kkrksc X K K K X K K KM K Bn K O 3:3 629CT2 2 9391(CTS966f,Tr- 8 s 5 8 s B 3 s 5 79373 & 77 3 1^3 1 I 9 9 4 € 3 4 € 6 9 5 s 2232226AV 3 4.0 344663 3 0 3 3 3 3 o 22 1X0111 s 1 5 1
bi
IwB：
£_B3
bi
i_a:
bi
i
；::2：
3
4
5
€78 9 01 2 345 ®7B901234-E6T 8 1 1 1 2 i 1 1 2 2 2 2 2 2 2 2 2
• 358 •
第14章改写调优案例分享
END dept,
a.dept_id dept_Id, nvl((SELECT dept.c_dept_name FROM infor—dept dept WHERE dept. c_dept_id == a. dept_id),
'合计')AS c_dept_name, /*这里有很多列★/ —
NULL
FROM (SELECT /*+ index(s I_BI一XY) ★/
substr(s.G_dept_id, 1, 6) AS dept_idf /★2013的很姜列*/
NULL FROM bi s
WHERE s.d_retail_time >= to_date(*201311011,	'yyyymmdd')
AND s.d_retail—time < to_date('20131201', 'yyyymmdd，} AND s.c_dept_id LIKE '01%'
GROUP BY substr(s.c—dept—id, lr 6)
UNION ALL
SELECT /*+ index(s 工一BI_XY> */ substr(s.c_dept—id, 1, 6) AS dept_id,
/*2012的很秦列*/
NULL FROM bi s
WHERE s.d_retail一time >= to—date(•201211011,	1yyyymmdd1)
AND s • d_retail—time < to__date (1 20121201 *, 1 yyyymmdd1) AND s.c_dept_id LIKE '01%'
GROUP BY substr(s.c_dept_id, 1, 6)) a GROUP BY ROLLUP(CASE
WHEN substr(a.dept_id, 1, 4) = ' 0101' THEN '0101,
WHEN substr (a.dept__id, 1, 4) = 10102' THEN 10102'
WHEN substr(a.dept_id, 1, 4) = '0103* THEN •0103’
WHEN substr(a.dept_id, 1, 4) = 10104' THEN '0104f
WHEN substr (a.deptl一id, 1, 4) = 1 0105 1 THEN *0105'
WHEN substr(a.dept—id, 1, 4) = '0106 * THEN ’OlOG1 END,
• 359 •
Oracle查询优化改写技巧与案例
a. dept_id)
UNION ALL SELECT CASE
WHEN substr(a.dept_id, 1, 2) = 102' THEN 1 02'
END dept,
a.dept_id dept_id, nvl((SELECT dept•c_dept_name FROM infor_dept dept WHERE dept.c_dept_id = a.dept_id), f 合计1 > AS c_dept_name,
/*这里有很多列★/ ~
NULL
FROM (SELECT /★+ index(s I_BI_XY) */
substr(s.c_dept_id, 1, 6) AS dept_id, /*2013的很务列*/
NULL
FROM	bi s
WHERE	s.d retail_time >= to_date('20131101'f	,yyyymmdd1)
AND	s.d retail_time < to_date('201312011,'	'yyyymmdd')
AND	s.c_dept_id LIKE 102%f
GROUP	BY substr (s . c__dept_id, 1, 6)
UNION .	ALL
SELECT	/★+ index(s I一BI_XY) */
substr(s•c_dept一id, 1, 6) AS dept_id, "2012的很务列*/
NULL
FROM	bi	s
WHERE	s. d	_retail_time >= to一date(*20121101 *,	'yyyymmdd')
AND	s. d	_retail_time < to一date(*20121201 *, 1	丨 yyyymmdd1)
AND	s .c	_dept_id LIKE '02%'
GROUP	BY	substr(s.c_dept_id, 1, 6)) a
GROUP BY ROLLUP(CASE
WHEN substr(a.dept_id, 1, 2) = '02' THEN ■02'
END,
a.dept_id)
UNION ALL SELECT CASE
WHEN substr(a.dept—id, 1, 2) = 103* THEN ’03*
• 360 •
第14章改写调优案例分享
END dept,
a.dept_id dept一id, nvl((SELECT dept.c_dept_name FROM infor—dept dept WHERE dept. c__dept_id = a .dept一id> ,
'合计')AS c_dept_name,
/*这里有很多列*/ ~
NULL
FROM (SELECT /*+ index(s 工—BI_XY) */ s.c—dept一id AS dept_id,
/*2013的很多列*/
NULL FROM bi S
WHERE s.d一retail—time >= to_date(120131101' AND s•d一retail_time < to_date('20131201f, AND s.c—dept_id LIKE *03%*
GROUP BY s.c_dept_id UNION ALL
SELECT /*+ index(s I_BI_XY) */ s.c_dept_id AS dept_id, r /*2012的很多列*/
NULL FROM bi s
WHERE s.d_retail_time >= to_date(*20121101' AND s.d_retail_time < to_date('20121201', AND s.c—dept一id LIKE '03%'
GROUP BY s.c_dept_id) a GROUP BY ROLLUP(CASE
WHEN substr(a.dept一id, 1, 2) = '03 * '03*
END,
a. dept_id);
,yyyymmdd,> * yyyyinmdd *)
THEN
虽然还是比较长，但比原来的语句清晰多了，这个査询内层的UNION ALL分别取2012 年及2013年的数据，然后合并。因为分类方式（见里面的C_dept—id )的不同，所以又分 成三部分，然后再次进行UNION ALL操作，使其成为一个结果。 遇到这种语句时，通常可以尝试用WITH语句，但WITH语句在过滤性较高的情形下 才能提高效率。在这个査询中达不到这个要求，因为笔者建议网友改用WITH后效果不理 想，而且运彳于更慢。
• 361 •
Oracle查询优化改写技巧与案例
第二个思路在于原查询里外层的三个UN丨ON ALL。我们刚刚说了是因为对c—dept_id 取值的不同而分成了三个部分，所以可以尝试用CASE WHEN语句把三个语句合并成一 个，把WHERE中的条件合并，查询中不同的部分用WITH处理；
SELECT /_*3.02与03部分各合并为一个部门，01要细分为6个部门*/
CASE WHEN substr(a	.dept_	_id,	1,	2)-	，02,	THEN
'02' WHEN substr(a.dept		_idr	1,	2)=	,03,	THEN
'03' WHEN substr(a	• dept一	_id,		4)=	•0101	'THEN
’0101， WHEN substr(a	• dept_	_id,	1,	4)=	f0102	'THEN
•010乏， WHEN substr (a	.dept	_id,	1,	4)=	•0103	* THEN
f0103' WHEN substr(a.dept_		_id,	1,	4)=	'0104	，THEN
,0104’ WHEN substr (a	• dept一		1,	4)=	'0105	'THEN
'01051 WHEN substr (a	•dept_	_id,	1,	4)=	!0106	'THEN
'OIOS1 END dept, a.dept_id dept—	id,
nvl((SELECT dept•c_dept_name
FROM infor_dept dept WHERE dept.c_dept_id = a.dept_id),
’合计*) AS c_dept_name,
"这里有很多列"
FROM (SELECT /★+ index(s	*/
/*2. c_dept_id LIKE ' 03% '使用的 c_dept_id,而其他两个用 substr */ CASE
WHEN s.c_dept_id LIKE '03%' THEN s•c_dept—id ELSE
substr(s * c_dept_id, 1, 6)
END AS dept_id,
”2013的很多列"
FROM bi s
WHERE s.d_retail_time >= to_date('20131101',	'yyyymindd1)
AND s.d_retail_time < to_date('20131201', 'yyyymmdd *)
• 362 •
第14章改写调优案例分享
AND (s.c_dept_id LIKE f01%' OR s.c_dept_id LIKE '02%* OR s.c_dept_id LIKE *03%')
GROUP BY substr(s.c_dept_id, 1, 6)
UNION ALL
SELECT "+ index (s I一BI—XY) */
CASE
WHEN s.c_dept_id LIKE *03%* THEN s.c_dept_id ELSE
substr{s.c_dept_id, 1, 6)
END AS dept—id,
"2012的很多賴"
FROM bi s
WHERE s•d_retail一time >= to一date(120121101 *, f yyyymmdd *) AND s.d一retail一time < to_date(* 20121201', * yyyymmdd') /*1. where语句中不同的条件合并在一起★/
AND (s.c_dept_id LIKE *01%* s.c_dept_id LIKE '03%1)
GROUP BY substr(s•c一dept—id, 1,
GROUP BY ROLLUP(CASE
WHEN substr(a.dept_idf •02/
WHEN substr(a.dept—id,
•03'
WHEN substr(a.dept_id,
'OlOl'
WHEN substr(a.dept_id,
'01021
WHEN substr(a.dept_idr •0103,
WHEN substr(a.dept_id,
,0104f
WHEN substr(a.dept一id,
'0105'
WHEN substr(a.dept一id,
*0106書
END,
a. dept_id)
1,
1,
1,
1,
1,
1,
1,
1/
OR s. c_dept_id LIKE •02%* 6)) a
'021 THEN '03* THEN *0101' THEN *0102* THEN * 0103' THEN »0104| THEN ^lOS* THEN ’OlOG’ THEN
2)
2)
4)
4)
4)
4)
4)
4)
OR
大家可以对比一下，我们改动的主要就是三个地方，这样就可以节约近2/3的时间。
Oracle查询优化改写技巧4案例
而根据网友反馈，这种改写方式效果显著。至此，优化完成。
14.43	不恰当的WITH及标量子查询
在使用一个方法之前，知道它的用处及优缺点是很重要的，否则会犯一些不必要的错
误。
WITH wzxfl AS (SELECT *
FROM (SELECT c •用户号， df.总数量，
row一number () over (PARTITION BY c•类型 ORDER BY df •总数量
DESC) AS 排名
FROM customer c,
(SELECT d•用户号，nvl (SUM(d.总数量），'0')总数量 FROM t_money d WHERE d.mon >= 201301 AND d.mon <= 201309 GROUP BY d.用户号）df WHERE c.用户号- df.用户号
'20')) cc
AND c•用户类型 IN (UCT, 'll',
WHERE cc •排名 <=3000)
SELECT c.用户号，
MAX (c.用户）•
MAX (c.地址},
MAX(c.colli),
MAX(h.总数量）总数量13,
MAX (h.排名）排名，
(SELECT SUM (d•总金额）FROM t_money d.mon >= 201301 AND d.mon <= 201307 GROUP BY (SELECT SUM(d•总数量）FROM t_money d.mon >= 201201 AND d.mon <= 201207 GROUP BY (SELECT SUM<d•总金额）FROM t_money d.mon >= 201201 AND d.mon <= 201207 GROUP BY FROM customer c, wzxfl h WHERE c.用户号=h.用户号 GROUP BY c.用户号；
可以看到，写这个查询的人会用WITH、标量子查询，还会使用分析函数。但这些组 合在一起得到的效果就不尽如人意了。
d WHERE d.用户号= d.用户号> as总金额 d WHERE d.用户号= d.用户号）as总数量 d WHERE d.用户号= d.用户号）as总金额
c.用户号AND 13,
c.用户号 12,
c.用户号 12
AND
AND
• 364 •
第14章改写调优案例分享
①WITH语句中的问题不大，返回各类型的前3000条数据。
②后面的主查询里第一个标量统计的是201307之前的数据，而在WITH中，这个范 围的数据己访问过一次，只是范围更大。那么，若要得到201307之前的数据，用CASE WHEN处理就可以。
③在主查询里又访问了一次customer表，而这个表用到的列完全可以在WITH里提 出来。
④主査询里最后两个标量都是取2012年的数据，那么这两个査询完全可以合并成一 个来减少访问次数，而且在标量里用这么大的范围查询，有很大可能是全表扫描，这样， 即使只有一个标量子查询，也会比较慢。
首先，更改第二点，去掉一个标量：
SELECT d.用户号，
nvl (SUM<d.总数量）,	0)	总数量，
SUM(CASE WHEN mon	<=	201307 THEN d.总金额END) AS总金额
FROM t一 money d
WHERE d.mon >= 201301
AND d.mon <= 201309
GROUP BY d.用户号
接下来，WITH语句中返回customer足够的列，这样主查询就不用再重复关联customer:
SELECT c.*,
df.总数量，
df.总金额，
row一number()	over (PARTITION BY c.类型 ORDER BY df.总数量 DESC) AS W
名
FROM customer c,
(…)df
WHERE c.用户号=df	.用户号
AND c.用户类型IN	(•lO，， *11', ’20，）
然后用一个内联视图来取代最后两个标量：
SELECT d.用户号，SUM(d.总数量）AS总数量，SUM(d.总金额> AS总金额 FROM t—money d WHERE d.mon >- 201201 AND d.mon <= 201207 GROUP BY d.用户号
最终语句如下：
• 365 •
Oracle查询优化改写技巧*5案例
SELECT 3£13.用户号， df 13 •用户, dfl3.地址， dfl3.com, 4；£13.总数量， dfl3.排名， nvl (df 13 .总金额, nvl (dfl2.总数量, nvl (df 12 •总金额, FROM (SELECT *
FROM (SELECT
0)
0)
0)
c.
df.总数量， df.总金额， row number()
over (PARTITION BY c.类型 ORDER BY df •总
数量DESC) AS排名
AS总金额
FROM customer c,
(SELECT d •用户号，
nvl (SUM (d.总数量），
SUM(CASE WHEN mon
FROM t_money d WHERE d.mon >= 201301 AND d.mon <= 201309 GROUP BY d.用户号）df WHERE c.用户号=df.用户号 AND c•用户类型 IN ( '10' , ，11’ WHERE cc •排名 <=3000) dfl3 LEFT JOIN (SELECT d.用户号，
SUM (d.总数量> AS总数量，
SUM (d.总金额）AS总金额 FROM t—money d WHERE d.mon >= 201201 AND d.mon <= 201207 GROUP BY d.用户号）dfl2 ON dfl2.用户号
0)总数量，
<=201307 THEN d.
总金额END)
20')) cc
dfl3.用户号
14.44用分析函数加“行转列”来优化标量子查询
分析函数不是Oracle的专利，SQL Server中也有，来看下面的语句:
第14章改写调优案例分享
SELECT *
FROM (SELECT userid, username,
COUNT(userid) AS usercount,
(CASE
WHEN (COUNT(userid))-(SELECT COUNT⑴
FROM dbo.tl AS c WHERE userid = a.userid AND state IN <0, 2)
AND createtime BETWEEN *2013.12.07 00:00:00.000* AND *2013.12.19 23:59:59.999') <= 0 THEN
0
ELSE
((SELECT COUNT(*)
FROM dbo.tl AS b WHERE NOT EXISTS
(SELECT id FROM dbo.t2 WHERE oldtaskid = b.taskid)
AND (b.state = 1 OR b.state = 6)
AND b.userid = a.userid
AND createtime BETWEEN '2013.12.07 00:00:00.000' AND *2013.12.19 23:59:59.999') / (COUNT(userid)) -(SELECT COUNT(1)
FROM dbo.tl AS c WHERE userid = a.userid AND state IN (0, 2))) * 100 END) AS correctrate,
row一number(> over(ORDER BY a.userid DESC) rownum FROM dbo.tl AS a WHERE NOT EXISTS (SELECT id FROM dbo.t2 WHERE oldtaskid = a.taskid) AND createtime BETWEEN *2013.12.07 00:00:00.000' AND *2013.12.19
23:59:59.999*
GROUP BY userid, username) AS z WHERE rownum BETWEEN 41 AND 60
下面按Oracle的优化思路进行修改。 这个查询对tl在标量子查询里访问了好几次，而且state和createtime条件各不相同， 显示改为LEFT JOIN不合适。对这种情况，我们可以用分析函数通过CASE WHEN及嵌 套后的过滤条件来得到不同的值，这样可以减少tl的扫描次数。 我们由最大范围开始一步步处理。
• 367 •
Oracle查询优化改写技巧Si案例
①全表，因为全表计算次数时多了条件“state IN (0，2)”，所以要放在CASE WHEN里。
SELECT COUNT ⑴ FROM dbo.tl AS c WHERE userid = a.userid AND state IN (0, 2))
改为：
WITH xl AS
(SELECT COUNT(CASE WHEN state IN (0, 2)	THEN userid END) over(PARTITION
BY userid) AS ct2,
userid,
username,
taskidr
state.
createtime
FROM tl)
②按时间过滤之后的计数：
SELECT COUNT(1)
FROM dbo.tl AS c
WHERE userid = a.userid
AND state IN (0, 2)
AND createtime BETWEEN •2013.12.07	00:00:00.000» AND *2013.12.19
23:59:59.999'
改为：
x2 AS
(SELECT COUNT(CASE WHEN state IN (0, 2)	THEN userid END) over(PARTITION
BY userid) AS ctl,
xl.*
FROM xl
WHERE createtime BETWEEN '2013.12.07	00:00:00.000* AND *2013.12.19
23:59:59.999')
剩余的计数与主查询范围一致：
WITH xl AS
(SELECT COUNT(CASE WHEN state IN (0, 2) THEN userid END) over(PARTITION BY userid) AS ct2r userid, username, taskid,
state.
第14章改写调优案例分享
createtime FROM tl), x2 AS
(SELECT COUNT(CASE WHEN state IN (0, 2) THEN userid END) over(PARTITION BY userid) AS ctl, xl.*
FROM xl
WHERE createtime BETWEEN '2013.12.07 00:00:00.000* AND '2013.12.19 23:59:59.999')
SELECT *
FROM (SELECT userid, username,
COUNT(userid) AS usercount,
(CASE
WHEN (COUNT(userid)) - MAX(a.ctl) <= 0 THEN
0
ELSE (COUNT(CASE
WHEN state IN (1, 6) THEN userid
END) / (COUNT(userid)) - MAX(a.ct2)) ★ 100 END) AS correctrate,
row_number() over(ORDER BY a.userid DESC) AS rn FROM x2 a
WHERE NOT EXISTS (SELECT id FROM t2 WHERE oldtaskid = a.taskid) GROUP BY userid, username) z WHERE rn BETWEEN 41 AND 60
当然，这种方法在SQLServer中的效率如何还不得而知。
14.45 用分析函数处理问题
本例的模拟数据如下：
DROP TABLE t PURGE /
CREATE TABLE t(comdate DATE,transdate DATE ,amount NUMBER)
/
INSERT INTO t(comdatef transdate,amount)
VALUES (DATE '2013-01-31 * fDATE，2013-01-01，，1)
• 369 •
Oracle查询优化改写技巧与案例
INSERT
VALUES
/
INSERT
VALUES
/
INSERT
VALUES
INTO t(comdate,transdate,amount)
(DATE •2013-01-31*,DATE •2013-01-02，,2)
INTO t(comdate,transdate,amount)
(DATE '2013-02-28',DATE 12013-02-0111)
INTO t(comdate,transdate,amount)
(DATE '2013-02-28'fDATE •2013-02-02■,12)
comdate --每月最后一天 transdate	每天的日期
amount--交易金额 要求查出：
每天的曰期、
交易金额、
本月每日平均交易金额、
上月每日平均交易金额 表里存的是一天一条记录
要求用标量子查询处理并不难:
SELECT comdate,
transdate,
amount,
(SELECT AVG(b.amount)	FROM t	b WHERE b.comdate = a.	comdate) AS 本
月曰均，
(SELECT AVG(b.amount)	FROM	t b WHERE b.comdate	=add_months
(a. comdate, -1)) AS 上月日均
FROM t a
ORDER BY 2;
只是这种写法运行起来可能会慢。 而用分析函数可以很容易地取出本月日均值:
SELECT transdate AS 日期， amount AS交易金额，
AVG (amount) over (PARTITION BY comdate) AS 本月曰均 FROM t
日期	交易金额	本月曰均
• 370 •
第14章改写调优案例分享
2013-01-01	1	1..5
2013-01-02	2	1.5
2013-02-01	11	H.5
2013-02-02	12	11.5
4 rows selected
问题就在于怎么得到上月的数据，因为不是滑动开窗，所以over(order by xx range)的 方法在这里不适用。 下面一步步地进行操作。首先生成序号：
SELECT transdate AS 日期， amount AS交易金额，
AVG (amount) over (PARTITION BY comdate) AS 本月日均，
/★按月分组，按日期排序，取出当前行在本月的序号*/
row_number() over(PARTITION BY comdate ORDER BY transdate) AS seq FROM t
日期	交易金额	本月日均	SEQ
2013-01-01	1	1.5	1
2013-01-02	2	1.5	2
2013-02-01	11	11.5	1
2013-02-02	12	11.5	2
4 rows selected
我们知道，可以用lag取前面的数据，而lag的第二个参数指定了取前面第几行。这 样就可以用lag(，seq)取出对应的信息：
SELECT 日期,
	交易金额，
	本月日均，
	/*按内层取出的序号前移就是上一个月的数据*/
	lag (本月曰均,seq) over (ORDER BY 曰期〉	AS上月曰均
FROM	：(SELECT transdate AS 曰期，
	amount AS交易金额，
	AVG(amount) over(PARTITION BY	comdate) AS本月曰均，
	/*按月分组，按日期排序，取出当前行在本月的序号*/
	row number() over(PARTITION BY	comdate ORDER BY transdate)
AS seq
	FROM t);
曰期	交易金额	本月日均 上月日均
• 371 •
Oracle查询优化改写技巧与案例
111麵
4	rows selected
14.46用列转行改写A表多列关联B表同列
原语句如下：
SELECT gcc.segment1,
ffvl.DESCRIPTION, gcc.segments, ffv3•DESCRIPTION, gcc.segment2, ffv2.DESCRIPTION, gcc.segment4, ffv4.DESCRIPTION, gcc.segments, ffv5.DESCRIPTION, gcc.segment 6, ffv6.DESCRIPTION, gcc.segment7, gbb,period_name,
gbb. period_net__dr - gbb.period_net_cr b_amount
:apps	• gl_	balances			gbb,
apps •	gl_code_Gombinations				gcc.
apps.	fnd	_f lex_	一values	_vl	ffvl,
apps •	fnd_	_flex	values	_vl	ffv2,
apps •	fnd	_flex	—values	_vl	f fv3f
apps •	fnci_	_flex	_values	_vl	f fv4,
apps.	fnd	_f lex_	_values	_vl	ffv5,
apps.	fnd_	_flex_	_values	_vl	f fv6,
apps,	fnd	一flex—	value	sets	f fvsl
apps.	fnd	flex	_value_	sets	f fvs2
apps •	frid_	_flex	_value_	sets	ffvs3
apps.	fnd	_flex_	_value_	sets	f f vs 4
apps •	fnd_	_f lex	value	sets	f fvs5
apps.	fnd_	flex	_value_；	sets	f fvs6
2013-01-01	1	1.5
2013-01-02	2	1.5
2013-02-01	11	11.5
2013-02-02	12	11.5
• 372 •
第14章改写调优案例分享
WHERE	gbb,period_name = * 2014-01'
AND	gbb.actual一flag		='B	«
AND	gbb.template id		IS NULL
and	gbb.currency_code =			'CNY1
and	gbb.code_combination			—id = gcc. code_coinbination				i_id
and	f fvl •	FLEX_VALUE	=gcc.segmentl
and	f fv2.	FLEX_VALUE	=gcc.segment2
and	ffv3.	FLEX_VALUE	=gcc.segment3
and	ffv4 .	FLEX—VALUE	=gcc.segment4
and	ffv5.	FLEX—VALUE	=gcc.segment5
and	f fv6.	FLEX一VALUE	=gcc.segment6
and	ffvl.	FLEX一VALUE一	SET一	ID = ffvsl.	f lex_	value一	set一	id
and	f fvsl	.flex—value	_set	name = *JI	_COA_	COM1
and	ffv2.	FLEX_VALUE_	SET_	ID = ffvs2.	flex_	一value一	set 一	id
and	f fvs2	.flex_value	_set	name = *JI	_C〇A_	_CST1
and	ffv3.	FLEX_VALUE_	SET一	ID = ffvs3.	flex_	_value_	set一	id
and	f fvs3	.flex_value	_set	—name = * JI	_C0A_	_ACC，
and	ffv4.	FLEX_VALUE_	SET_	ID = ffvs4.	flex_	_value_	set_	id
and	f fvs4	.flex_value	—set	一name = *JI	_C0A_	_BRD*
and	ffv5.	FLEX一 VALUE—	SET一	ID = ffvs5.	flex_	value一	set一	id
and	ffvs5	.flex_value	—set	—name = f JI	_COA	_PRJ*
and	ffv6.	FLEX_VALUE_	SET一	ID = ffvs6.	flex_	_value_	set_	id
and	f fvs6	.flex—value	一set	—name = ' JI	_COA	ICP*
and	gbb.period_net_dr -			gbb.period_	net_cr <> 0
order	by 1,	3;
本里的PLAN在这里省略，读者可以看笔者的BLOG ( http://blog.csdn.net/
jgmydsai/article/details/17580337)。 这里对fnd_flex_values一v丨和fnd_flex—value_sets分别关联了 6次，而且执行计划走的 都是 NESTED LOOP。 有没有办法减少关联次数呢？通过观察，我们可以对gl—codejombinations做列转行。 把几个segment列转为一列。这样再与两个fnd表关联时就可以只关联一次了。 数据都提出来后，再用CASE WHEN和GROUP BY做“行转列”，还原所需数据。 改后的语句如下：
WITH gccO AS (SELECT rownum AS sn, gcc.segmentl, gcc.segment2,
• 373 •
Oracle查询优化改写技巧l_i案例
gcc.segment3, gcc.segment4, gcc.segments f gcc.segment6, gcc.segment7, gbb.period—name,
gbb.period_net_dr - gbb.period_net_cr b_amount FROM apps.gl_balances gbb, apps.gl_code_combinations gcc WHERE gbb.period—name = '2014-01'
AND gbb•actual—flag = 'B'
AND gbb.template_id IS NULL AND gbb.currency_code = 'CNY'
AND gbb.code_combination_id = gcc.code_combination_id AND gbb.period_net_dr <> gbb.period_net_cr), gcc AS
(SELECT sn, flex—value—set_name, segment0, segment7, period—name, b 一 amount
FROM gccO
END)
END)
END)
END)
END)
END)
AS
AS
AS
AS
AS
AS
segmentl, MAX (CASE segmentl, MAX (CASE segmentl, MAX (CASE segmentl, MAX (CASE segmentl, MAX (CASE segmentl,
gcc. gcc. gcc. gcc • gcc •
name	IN(segmentl			AS '	JI_COA_COM1,
segment2 AS			'JI_	_COA_	CST，	t
segments AS			'JI_	_COA_	ACC '	t
segment4 AS			'JX_	_COA_	BRD1	r
segments AS			'JI_	_COA_	■PRJ’	r
segment6 AS			'JI_	_COA_	.ICP')))
WHEN	'Jl	_C〇A_	COM'	THEN	gcc,	.segmentO
WHEN	’J工-	—COA一	CST'	THEN	gcc.	,segmentO
WHEN		_COA_	ACC'	THEN	gcc.	,segmentO
WHEN	1 JI_	_COA_	BRD'	THEN	gcc.segmentO
WHEN	■ Jl	_COA_	•PRJ'	THEN	gcc、	,segmentO
WHEN	'Jl	_COA_	_ICP，	THEN	gcc ■	•segmentO
MAX(CASE	gcc.flex_value_set_name
ffv.description END) AS desl,
MAX(CASE	gcc.flex_value_set_name
ffv.description END) AS des2,
WHEN
WHEN
'Jl COA COM'
'Jl C〇A CST'
THEN
THEN
• 374 •
第14章改写调优案例分享
ffv.	MAX (CASE .description END)	gcc. flex_ AS des3,	value_	_set_	name	WHEN	1 JI_	_COA_	ACC*	THEN
ffv.	MAX(CASE .description END)	gcc.flex_ AS des4,	_value_	_set_	name	WHEN	1 JI_	_COA_	_BRDf	THEN
ffv.	MAX(CASE .description END)	gcc.flex AS des5,	value	_set_	name	WHEN	'JI_	_COA_	_PRJ'	THEN
ffv.	MAX(CASE .description END)	gcc.flex_ AS des6,	_value_	_set_	name	WHEN	1 JI_	_C〇A_	ICP1	THEN
MAX(gcc.segment?) AS segment7,
MAX(gcc.period_name) AS period_name,
MAX(gcc.b_amount) AS b—amount FROM gcc, apps.fnd_flex_values_vl ffv, apps.fnd_flex_value_sets ffvs WHERE ffv.flex_value = gcc.segraentO
AND ffv.flex_value_set_id = ffvs.flex_value_set_id AND ffvs.flex_value_set_name = gcc.flex_value_set_name GROUP BY gcc.sn HAVING COUNT (*) =6
当然，优化方式不止改写这一种思路。 这种改写方式增加了拆分再合并的成本，减少了两个fnd表的访问次数。
是否决定用这种方式需要进行权衡，看是多次关联的成本大还是拆分再合并的成本 大。比如，在这个语句中还可以采取增加提示，让GBB GCC走HASH JOIN。
14.47用分析函数改写最值语句
下面是模拟的一个实际案例：
SELECT a.deptno, a.min一no, mi.ename AS min_n, ma.empno AS max_n FROM (SELECT deptno, MIN(empno) AS min_no, MAX(empno) AS max—no FROM emp GROUP BY deptno) a INNER JOIN emp mi ON (mi.deptno = a.deptno AND mi.empno = a.min_no) INNER JOIN emp ma ON (ma.deptno = a.deptno AND ma.empno = a.max_no);
DEPTNO	MIN一NO MIN—N	MAX 一
30	7499 ALLEN	7900
20	7369 SMITH	7902
10	7782 CLARK	7934
3 rows selected
• 375 •
Oracle查询优化改写技巧4•案例
对这种查询的改写，可以使用max() keep(dense_rank firs/last order by xxx)来完成:
SELECT deptno.
MIN(empno)	AS min no,
MAX(ename)	keep(dense_	rank	FIRST ORDER BY empno) AS min n,
MAX(empno)	AS max_no.
MAX(ename)	keep(dense一	rank	LAST ORDER BY empno) AS min_n
FROM emp
GROUP BY deptno
或许你会注意到笔者在取最小值时仍然用了 max(ename),这是因为在这个查询中 keep()里的子句保证了返回的只有一行数据，而且这行数据的ename本身就是最小值，所 以前面的聚合函数使用max或min结果都一样。 需要注意的是，如果keep()子句返回多行，这种改写就不可行：
SELECT a.deptno, a.min_sal,mi .ename, a.max_sal,ma.ename FROM (SELECT deptno, MIN(sal) AS min_sal, MAX(sal) AS max_sal FROM emp GROUP BY deptno )a
INNER JOIN emp mi ON mi«deptno = a.deptno AND mi.sal - a.min_sal INNER JOIN emp ma ON ma.deptno = a.deptno AND ma.sal = a.max_sal ORDER BY 1;
DEPTNO
MIN SAL ENAME
MAX SAL ENAME
10
20
20
30
1300 MILLER 800 SMITH 800 SMITH 950 JAMES
5000 KING 3000 SCOTT 3000 FORD 2850 BLAKE
4	rows selected
如果使用first语句，部门20就只能保留一行：
SELECT deptno,
MIN (sal) AS min_sal,
MIN(ename) keep(dense_rank FIRST ORDER BY sal) AS min_n, MAX(sal) AS max_sal,
MAX(ename) keep(dense_rank LAST ORDER BY sal) AS min_n FROM emp GROUP BY deptno;
• 376 •
第14章改写调优案例分享
DEPTNO MIN_SAL MIN_N	MAX_SAL	MIN_N
10	1300	MILLER	5000	KING
20	800	SMITH	3000	SCOTT
30	950	JAMES	2850	BLAKE
3	rows selected
可以看到，少了 FORD,因为前面的max(ename)在这里保留了其中的最大值 “SCOTT”。这种情况只能用自关联。
WITH xO AS (SELECT deptnof sal, ename,
MIN(sal) over(PARTITION BY deptno) AS min_sal,
MAX(sal) over(PARTITION BY deptno) AS max_sal FROM emp)
SELECT a .deptno, a.min_sal, a.ename AS min_n, b.max_sal, b.ename AS max一n FROM xO a, xO b WHERE a.deptno = b.deptno AND a.sal = a.min_sal AND b.sal = b.max_sal GROUP BY a.deptno, a.min_sal, a.ename, b,max_sal/ b.ename;
因为最小值和最大值都有重复值时会产生笛卡儿积的现象，所以要去重。前面不用分 析函数，取sal最值的原查询语句也一样，要加去重。
14.48 多列关联的半连接与索引
经常见到有人把列合并后再进行半连接，这种方式的运行效率很不好，下面来模拟一 下：
DROP TABLE emp2 PURGE; CREATE TABLE emp2 AS SELECT ename, job, sal,comm FROM emp WHERE job = CREATE INDEX idx emp ename ON emp(ename);	'CLERK';
其合并后半连接的语句如下：
SELECT empno, ename, job, sal, deptno
FROM emp
• 377 •
Oracle查询优化改写技巧Q案例
WHERE (ename || job I| sal) IN (SELECT ename || job || sal FROM emp2)
这样的语句不能走普通索引，否则查询速度会比较慢。
Description
SELECT STATEMENT, GOAL = ALL_ROWS | _ HASH JOIN SEMI
卜 TABLE ACCESS FULL TABLE ACCESS FULL
在不影响数据的情况下，我们应该把“|丨”去掉：
SELECT empno, ename, job, sal, deptno FROM emp
WHERE (ename, job, sal) IN (SELECT ename, job, sal FROM emp2) 这样就能走索引：
Object owner Object name
TEST	EMP
TEST	EMP2
| Description
SELECT STATEMENT, GOAL NESTED LOOPS NESTED LOOPS -• SORT UNIQUE
TABLE ACCESS FULL INDEX RANGE SCAN TABLE ACCESS BY INDEX ROWID
Object owner Object name
TEST
TEST
TEST
EMP2
IDX-EMP一ENAME EMP
因为SQL Server不支持后一种写法，所以使用SQL Server的时候经常会有人先合并 列，再关联。
14.49巧用分析函数优化自关联
经常看到用自关联过滤数据的查询，这种査询常常可以改写为分析函数，下面就是模 拟其中的一个案例：
DROP TABLE T PURGE; CREATE TABLE t AS
SELECT	,2.	AS	coll ,	»4.	AS	col2	FROM	dual	UNION	ALL
SELECT	'I1	AS	coll ,	*5'	AS	col2	FROM	dual	UNION	ALL
SELECT	*11	AS	coll ,	’5’	AS	co!2	FROM	dual	UNION	ALL
SELECT	• 2,	AS	coll ,	'5'	AS	col2	FROM	dual	UNION	ALL
SELECT	'3'	AS	coll ,	'3'	AS	col2	FROM	dual	UNION	ALL
SELECT '12' AS coll, '16' AS col2 FROM dual UNION ALL
• 378 •
第14章改写调优案例分享
SELECT	’ll'	AS	Coll ,	r15'	AS	col2	FROM	dual	UNION	ALL
SELECT	fl3'	AS	coll ,	•13’	AS	col2	FROM	dual	UNION	ALL
SELECT	r12'	AS	coll •	'17*	AS	co!2	FROM	dual;
要求返回coll到col2间的最大区间，原语句如下：
SELECT to_char(lengthb(col2) ,	'FM000')丨丨 chr(0> num_length,
coll, col2 FROM t
WHERE NOT EXISTS (SELECT 1 FROM t a
WHERE a.coll <= t.coll AND a.co12 >= t.col2
AND (t.coll != a.coll OR t.col2 != a.col2) AND lengthb(a.coll) = lengthb(t.coll));
NUM LENGTH COL1 COL2
001	1	5
001	1	5
002	11	15
002	12	17
4	rows selected
这是常见的写法，其进行速度也比较慢。 其执行计划如下：
PLAN一	TABLE一OUTPUT
Plan	hash value: 366813129
1 Id	I Operation 丨 Name |	I Rows 丨 Bytes 1	1 Cost	(%CPU)I	Time |
I 0 !* 1	I SELECT STATEMENT | I FILTER |	! 11 6丨 1 J !	12	(0)丨 1	00:00:01 | 1
1 2	I TABLE ACCESS FULL| T	1 9 | 54	1 3	(0) 1	00:00:01 丨
| * 3	| TABLE ACCESS FULL| T	1 1 1 6	1 3	(0)丨	00:00:01 I
Predicate Information (identified by operation id):
1	- filter( NOT EXISTS (SELECT 0 FROM "T" "A" WHERE "A"•"C〇L1"<=:BI
• 379 •
Oracle查询优化改写技巧S案例
AND "A"."COL2”>=:B2 AND ( "A"•"C0L1"<>:B3 OR "A"."C0L2"<>:B4)
AND
LENGTHB("A"."GOLl")=LENGTHB(：B5)))
3	- filter("A"."C〇L1"<=:B1 AND "A"•"COL2">=:B2 AND ("A"•nCOLl"<>:B3 OR "A" . ,,COL2,,<>:B4) AND LENGTHB ("A" . "C0L1") =LENGTHB (: B5)) PLAN_TABLE_OUTPUT
Note
-dynamic sampling used for this statement (level=2)
23	rows selected
这是一个自关联，进行了 FILTER操作，而且JOIN列是不等连接，占用了大量的资源。 一般的思路可能是改为LEFT JOIN。我们来看一下PLAN。
EXPLAIN PLAN FOR SELECT to_char(lengthb(t.col2) ,	1FMOOO') M chr(0>
num_length, t.coll, t.col2 FROM t
LEFT JOIN t a
ON (a.coll <= t.coll AND a.col2 >= t.col2 AND (t.coll != a.coll OR t.col2 != a.eol2) AND lengthb(a.coll) = lengthb(t.coll))
WHERE a.coll IS NULL;
PLAN TABLE OUTPUT
Plan	hash value: 353337629
1 Id	I Operation |	Name	Rows | Bytes	Cost	(%GPU)|	Time |
I 0 | * 1	I SELECT STATEMENT | FILTER		1 11 9 1 I 1	30	(0) | .r . 1	00:00:01 | t
| 2	| NESTED LOOPS OUTER		1 1 1 9 j	30	(0)丨	00:00:01 丨
I 3	| TABLE ACCESS FULL	| T	| 9 | 54	3	(0) 1	00:00:01 |
I 4	| VIEW		1 11 3	3	(0) 1	00:00:01 丨
I * 5	I TABLE ACCESS FULL	T	1 11 6	3	(0) |	00:00:01 |
Predicate Information (identified by operation id):
1	- filter("A"."COLl" IS NULL)
5	- filter("A"•"COLl"<="T"•"COLl” AND "A"."COL2">="T"."C〇L2” AND
第14章改写调优案例分享
LENGTHB("A"."C0L1")=LENGTHB("T"•"COLl") AND <"T".nCOLl"<>
"A"•"C0L1
"TM•”C0L2”<>"A"•"C0L2”）)
PLAN TABLE OUTPUT
Note
-dynamic sampling used for this statement (level=2)
24	rows selected
因为有不等连接在内，仍然无法获得较好的执行计划，这种方式对性能的提升显然不 那么如何处理呢？我们来分步考虑一下。
SELECT lengthb(coll) lb, coll/ col 2,
/*按长度分组，按coll排序，累计取col2的最大值*/
MAX(col2) over(PARTITION BY lengthb(coll) ORDER BY coll) AS max一col2 FROM t ORDER BY 1, 2;
LB C0L1 C0L2 MAX C0L2
1	1	5	5
1	1	5	5
1	2	4	5
1	2	5	5
1	3	3	5
2	11	15	15
2	12	16	17
2	12	17	17
2	13	13	17
9 rows selected
可以看到，我们只要加上条件CO丨2>=max_c012,就可以得到当前重复范围的最大值, 加条件后的结果如下：
SELECT a.*
FROM (SELECT lengthb(coll) lb, coll, col2f
• 381 •
Oracle查询优化改写技巧•案例
/*按长度分组，按coll排序，累计取col2的最大值*/
MAX (col2) over (PARTITION BY lengthb (coll) ORDER BY coll), AS
max col2
FROM t) a /*增加条件，取范围截止值*/
WHERE	col2 >=		max	col 2
ORDER	BY	1, 2	!
	LB	C0L1	COL2 MAX」
	1	1	5	5
	1	1	5	5
	1	2	5	5
	2	11	15	15
	2	12	17	17
5 rows selected
至此，这个数据与目标很接近了。对比前面的数据可以看到，多了 “2〜5”这一条数 据。这是因为我们要取的是最大范围，而“2〜5”包含在“1〜5”中，所以还要对起止范 围进行处理。这里仍然要用到分析函数。
SELECT *
FROM (
/★按截止时间分组，对起始时间排序，生成序号，因可能有重复数据，这里用了 rank*/
SELECT rank() over(PARTITION BY col2 ORDER BY coll) AS seq, a.* FROM (SELECT lengthb(coll) lb, coll, col2,
/★按长度分组，按coll排序，累计取col2的最大值*/
MAX(col2) over(PARTITION BY lengthb(coll) ORDER BY
coll) AS max_col2
FROM t) a /★增加条件，取范围截止值*/
WHERE col2 >= max__col2)
/★序号为1的，也就是最小起始间*/
WHERE seq = 1;
SEQ	LB	COL1	COL2 MAX一COL2
1	2	11	15	15
1	2	12	17	17
1	1	1	5	5
第14章改写调优案例分享
1	11	5	5
4	rows selected 下面来看一下PLAN。
SQL> PLAN—	select ★ from table(dbms_xplan. TABLE_OUTPUT	display());
Plan	hash value: 2991172602
1 Id	I Operation | Name	I Rows |	Bytes	Cost (%CPU)丨 Time
| 0	I SELECT STATEMENT |	9 1	315 |	5	(40)	00:00:01
| * 1	| VIEW 丨 |	9 I	315 |	5	(40) |	00:00:01
I* 2	| WINDOW SORT PUSHED RANK |	9 I	198 I	5	(40)	00:00:01
1 * 3	I VIEW 丨 |	9 I	198丨	4	(25) |	00:00:01
1 4	| WINDOW SORT |	9 I	54 |	4	(25)	00:00:01
I 5	1 TABLE ACCESS FULL | T	1 9 |	54 |	3	《0)	00:00:01
Predicate Information (identified by operation id):
1	- filter("SEQ"=1)
2	- filter(RANK() OVER ( PARTITION BY "C0L2" ORDER BY "C0L1")<=1)
3	- filter("COL2">="MAX_C〇L2")
Note
一 dynamic sampling used for this statement (level=2)
23 rows selected
至此，去掉了不等连接的自关联。
14.50 纠结的UPDATE语句
不是所有的UPDATE语句都要用MERGE来改写，例如，下面的语句:
update k
set k.flag = 1 where id in
(select c.id from k c
• 383 •
Oracle查询优化改写技巧浴案例
where c.month = 1 2013121 and c.qty - 0 and not exists (select m.ename
from (select n.ename, count(1) cs from k n where n.month = 1201312 * and n.eclass in (’A1,	'B')
group by n.ename) m where m.cs > 1
and m.ename = c.ename)
union all select b.id from k b where b.month = 1201312 f and b.qty is null and not exists (select a.ename	、
from (select t.ename, count (1) cs from k t where t.month = '201312 * and t.eclass in (1A1,	1B')
group by t.ename) a where a.cs > 1
and a.ename = b.ename));
可以看到，上面的UNION ALL语句中有区别的也就两个条件“ k.qty = 0 ”与“ k.qty IS NULL ”，我们把OR拆分为UNION或UNION ALL是为了能索引或执行更好的PLAN, 这种条件显然不行，所以首先合并成一个语句“ nvl(k.qty，0) = 0
SELECT c.id FROM k c WHERE c.month = 1201312 *
AND nvl(c.qty, 0) =0
AND NOT EXISTS (SELECT m.ename
FROM (SELECT n.ename, COUNT(1) cs FROM k n WHERE n.month = ’201312*
AND n.eclass IN (1A%,	'B1)
GROUP BY n.ename) m WHERE m.cs > 1
AND m.ename = c.ename)
• 384 •
第14章改写调优案例分享
这个查询语句中的U.id是主键，其意思也就是：取按ename分组汇总后有重复值的 行。而这种需求用分析函数处理就是：
UPDATE k c
SET c.flag = 1 WHERE ROWID IN (SELECT rid
FROM (SELECT ROWID AS rid, qty,
COUNT(CASE
WHEN eclass (1Af,	'B') THEN
eclass
END) over(PARTITION BY ename) AS cs
FROM k x WHERE x.month = '201312')
WHERE nvl(qty, 0) = 0 AND cs <= 1);
至此，一个纠结的更新语句精简并改写完成。
这种语句一般是需求没理清楚，一步一步凑条件形成的，那么在写完语句达到需求后， 不妨再重新整理一遍思路，这样就能写出精简实用的语句。
1^51 巧用JOIN条件合并UNION ALL语句
下面这个语句是同一个表用不同的条件过滤后的合集：
SELECT
MSI.*
FROM INV.MSI0LINK MSI WHERE 1=1
AND MSI.FLAG =
AND MSI.0_ID IN (170, 572, 953, 242, 240, 1052, 1131)
AND MSI.LAST_UPDATE_DATE BETWEEN (DATE '2012-1-11) AND (DATE ’2013-1-1•)
AND NOT EXISTS (SELECT NULL FROM INV.MSI B,
APPS.HAO WHERE B.O_ID = HAO.O_ID
AND MSI.SEGMENT1 = B.SEGMENT1 AND HAO.ATTRIBUTEl = MSI.O_ID)
UNION ALL
• 385 •
Oracle查询优化改写技巧与案例
SELECT MS I. * FROM WHERE AND AND AND
'2013-1-1'
AND
工NV.MSI0LINK MSI
1	= 1
MSI.FLAG = 'N'
MSI.O_ID IN <170, 572, 953, 242, 240, 1052, 1131)
MSI.LAST UPDATE DATE BETWEEN (DATE '2012-1-11)
EXISTS (SELECT NULL FROM APPS.MI0LINK MI WHERE 1=1
AND MI. INVENTORY一ITEM—ID AND MI .0 ID = MSI.O ID)
AND (DATE
MSI.INVENTORY ITEM ID
AND
NOT EXISTS		(SELECT NULL
FROM	INV.	,MSI	B,
APPS		.HAO
WHERE	B.O_	JED = HAO. 0_	一ID
AND	MS I .	SEGMENT1 =	B.SEGMENT1
AND	HAO.	ATTRIBUTEl	=MSI•〇—ID)‘
对上述语句可以用PL/SQL进行格式化后，再用工具对比UNION ALL前后部分的语
句。
两个语句的区别就是用粗体字标出的部分，对于第二个结果集里粗体部分的子查询， 可以改为JOIN语句。为了后面便于合并，下面先改写为LEFT JOIN的方式：
(mi . inventory_i tem_id
SELECT msi.*
FROM inv.msi@link msi
LEFT JOIN apps.mi@l±nk mi ON msi.inventory_item_id AND mi.o_id = msi.o_id)
WHERE 1=1
AND msi.flag = 'N*
AND mi.inventory—item 一id IS NOT NULL
AND msi.o_id IN (170, 572, 953, 242, 240, 1052, 1131) AND msi.last_update_date BETWEEN (DATE '2012-1-11) f2013-1-1')
AND EXISTS (SELECT NULL
FROM apps.mi@link mi WHERE 1 = 1.
AND mi.inventory_item_id = msi.inventory_item_id AND mi.o_id = msi.o一id)
AND NOT EXISTS (SELECT NULL
AND (DATE
• 386 •
第14章改写调优案例分享
FROM inv.msi b, apps.hao WHERE b.o_id = hao.o_id
AND msi.segmentl = b.segmentl AND hao.attributel = msi.o_id)
因为已询问过,“MI.丨NVENTORYJTEM—ID,MI.O_lD”两列唯一，所以可直接用JOIN。
注意，前面介绍过 LEFT JOIN 加 “ANDmi.inventory_item_id ISNOTNULL” 这种方 式等价于INNER JOIN。
那么现在不同的部分就是粗体标识的两个条件，进一步把UNION ALL的两个语句合 并就是：
SELECT A.*
FROM (SELECT MSI.*
FROM INV.MSI0LINK MSI,
LEFT JOIN APPS.MI@LINK MI
ON (MSI.FLAG =	'N' AND MI • INVENTORY—ITEM_ID =
MSI.INVENTORY—ITEM一ID AND MI.0_ID = MSI.0一ID)
WHERE MSI.O一ID IN (170, 572, 953, 242, 240, 1052, 1131)
AND MSI.LAST_UPDATE_DATE BETWEEN (DATE f2012-l-l') AND (DATE
*2013-1-1”
AND (MSI. FLAG = 'Y' OR MI • INVENTORY_ITEM_ID IS NOT NULL)
)A,
(SELECT B.SEGMENT1, HAO.ATTRIBUTE1 FROM APPS.HAO,
INV.MS工	B
WHERE B.O_ID = HAO.0一ID) B WHERE A.SEGMENT1 = B.SEGMENT1(+)
AND B.SEGMENT1 IS NULL AND A.O_ID = B.ATTRIBUTEl⑴
AND B.ATTRIBUTE1 IS NULL;
通过合并操作后，对远程表MSI的访问由两次改为一次。或许很多人看过用OR语 句改为UNION ALL或UNION的方法来优化的例子，但没有理解为什么要改为UNION ALL或UNION。请参考3.2节的描述，再分析原语句，以免因不必要的改写而增加不必 要的扫描。
387
Oracle查询优化改写技巧Sf案例
14.52用分析函数去掉NOT IN
常常有些半连接及反连接中主表与子查询访问的是同一个表，也就是自关联，而有些 自关联所用的过滤条件用分析函数也可以得到：
SELECT	CUSTOMER.C_CUST_ID, CARD.TYPE CARD.N_ALL_MONEY
FROM	YD_VIP.CARD
WHERE	G：ARD.C_CUST_ID NOT IN (SELECT C_CUST_ID FROM YD_VIP.CARD
	WHERE TYPE IN ( 111', '12',	'13',	,U4')
	AND FLAG = '1')
AND	CARD.TYPE IN ( '11', '12'f '13','		114 ')
AND	CARD.FLAG = 'F';
这个语句中主查询与子查询内的大部分条件一样。为了便于分析，我们用示例库中的
表来模拟：
SELECT	a•cust_income一level, a.cust_	id,	a.cust first name, a.cust last_
name
FROM	sh.customers a
WHERE	a.cust_city = 1 Aachen *
/	*WHERE TYPE IN (，11’，’121, 1	13',	'14')*/
AND	a.cust_income_level NOT IN (SELECT b.cust income level FROM sh.customers b WHERE
	/★■ERE TYPE IN ('ll1, ' 12 ',	'13	•, ' 141)*/
	b.cust_city = 1 Celle1);
这时auto trace的PLAN如下：
• 388 •
第14章改写调优案例分享
00:00:10 I 00:00:10 J 00:00:05 ! 00:00:05 !
I 310 I 405
S2
4590
90 I 90 |
SELECT SIATEMEI'IT HASH JOIN ANTI MA
tabl£	ACCESS	FULLI	CUSTOMERS
TABLE	ACCES3	FULLj'	CUSTOMERS
! Id • Operation .	I	Nstme	I' Rows i Bycea | Cost (%CPU) | Tnr.e
因为看到有条件一样，很多人倾向于改为WITH语句:
WITH c AS (SELECT a.cust income level,
a _	,cust_	_id,
a _	.cust_	_first
a _	.cust_	_last_:
a.	,cust_	city
FROM sh.customers a WHERE a.cust一city IN /*and TYPE IN (rll r,
)
SELECT *
FROM c a WHERE a.cust一city = AND a.cust income
(*Aachen *, ,12,,	*13'	f
'Celle') •14 f) V
'Aachen' level NOT IN
(SELECT b.cust_income_level FROM c b WHERE b.cust_city = 'Celle') 这的确也是一种思路，这时的PLAN如下：
• 389
1	- access ( "h" . ,,CUS5T__INCOKE_X^VEL,T=rt3w. "CU針一INCOME-LZVEL”
2 - filter i	. "CUST^CITY^-^.acher.' I	~
3	filter (W3M . "CUST^CITY"*' Celle* )
统计信悪
0 -recsiraive c.alls	,
0 db ,fclock aets .	*
291^ consistent gets、	.，	.	_
\ 2903 pJiysical reads
6 rede size	.	.	•
*7 54. bytes ser.t via SC-*N©c to client:
416 bytes received via SQL^Nec fror. cl^oat
2	SQL* Net rounds rip s ro/froir. ci:.enc
0	sorts (memory)	#
,' 0	30IZ3 (disk:)
3	row3 processed
*Infonnaticn (identified by operation id):
Oracle查询优化改写技巧4案例
i Td	Cperacxon	I Ntune		Rows	Bytes.	Coat (%：	1	了lire
i °o i l i 2	SELECT 3TATEHENI TEME XASLE TRAUBFCRMATiqU LCAD A3 SELECT '	1 1 • _ I SYS T£HP 0FD9D6602	' ' 229S5D	179	20585	409	\l) 1	00	::	05
{- 3	TA3LS ACCESS FULL	1 CUSTOMERS	..…J	1*79	9129	*05	⑴1	06	00	05
1 • 4	HASH JOIN RIGHT ANTI NA	I .		179	'20565	4	(0) 1	00	OS	01
| • S	VIEW	1		179-	603€	2	(0)]	00		CL
1 6	TABLE ACCESS FULL	! SYS T£Mt OFD9J>6€02	22935D	1*79	9129	2	(0) I	00	■	:-
I* 7	VIEW •	1		175	14499	2	JO) 1	00	00	01
丨 s	XA3LS ACCESS FOIL	| 5Y3 TEMP 0FD3D6602	229B5D	179	9129	2	(Oi 1	00		j-
Predicate InforrcArien (identified by ape rat; ion id):
3 - fiicer (HAM. "CUS^CITY"-' Aachec' OR "A". HCU5T_CITyn=' Celle') •S - accesa ("A” • "qjST^INCOME一LEVEL"磁”3” . ”CUST一；DfC^G：一LEVE1”J 5 - filter ("B”. "COST二,
- f i iter ("A" ； "CUST~CITY"= • Aachen')	.
统计ft!
12 recursive calls S db blccJc gets 1471 conaiatenc gets '：
1455 physical read3 736 redo size
352 bytes sent via S2L*Nec to client
416 bytes received via	from client:
2	SQL-Net roundcrxps to/from client
0	sczts (ruemory)
0	sorts (disk)
3	rowa processed
只是WITH语句是否能提高效率还在于其中返回的数据比例，所以有必要多了解一种 改写方式：
SELECT a.cust_income_level, a.cust一id, a.cust一first一name, a.cust一last—name,
MIN(cust_city) over(PARTITION BY cust_income_level) MAX(cust_city) over(PARTITION BY cust一income一level) FROM sh,customers a WHERE a.cust—city IN (?Aachen'f 1 Celle')
AND ROWNUM <=3;
AS min_city, AS max city
CUST_INCOME_LEVEL	CUSTJD	CUST_FIRST_NAME	CUST_LAST_NAME	MIN 一 CITY	MAX_CITY I
D: 70,000 - 89,999	23678	Angie	Lauderdale	Aachen	Celle
D: 70,000 - 89,999	22788	Angie	Player	Aachen	Celle
H: 150,000 - 169,999	22790	Anand	Drumm	Aachen	Aachen
390
第14章改写调优案例分享
I 1-9499 | i *14499 ! I 9123 | !	9129	I
；(.1) 1 00:00:05 | (1) 1 00:00:05：] ,ID i 00:0J：：5 (I)! 00:005 05 (
|	0 1 SELECT STATEHEirr j
|*	1	|	VIEW	J
I	2 1 " WINDOW SORT' 、T—.
卜 3 I	TABLE ACCESS FULLJ, CUSTOMERS
redicace Information (identified fay operation Id):
1	- filter (MMMC_CI,tyM==,Aachen*)
3	- filter (”A" • nCUST_CIXY,r='Aacfeen • OR '"A" • "CUST^CITY'^'Celle ■)
0 recursive call3 0 dfa block: get3 1456 consistent gets ‘1454 physical reads
0	redG size
754 bytes sent via SQL-Net to client:
416 bytes reGexved via SQL^Net; froro client
2 SQL*Net rounder ip s t.c/f-rons client;
1	sorts (memory)
0 sorts (dislc)	i
3	rows processed
\ Id | Operation	|	Name	'	Rows	j	Byces	!	Cost-	(%CPCr) Time
可以看到，max_job= “Aachen”的行就是葡要的数据：
SELECT a.cust income level, a.cust id, a.cust—first_name, a.cust_last_name
FROM (SELECT	a.cust income一level
a.	,cust_	.Id,
a.	,cust_	_f irst_name,
a.	,cust	last name,
max_city
MAX(cust_city) over(PARTITION BY cust_income_level) AS
FROM sh.customers a WHERE a.cust_city IN ('Aachen1, 'Celle”）a WHERE max_city = 'Aachen';
CUST INCOME LEVEL
A: Below 30,000 L: 300, 000 and above L: 300,000 and above 3 rows selected
CUST ID CUST FIRST NAME
CUST LAST NAME
324
47870
6870
Brooke
Yuri
Boyd
Sanford
Chang
Leigh
这样就去掉了 NOT IN,只访问customers—次就能得到所需的结果，这时的PLAN如下:
• 391 •
Oracle查询优化改写技巧与案例
14.53	读懂查询中的需求之裁剪语句
有时语句经过多人的修改之后，维护语句的人也不知道查询的目的是什么，如果你能 读懂查询语句，通过语句分析需求对优化也有很大的帮助：
SELECT	id
FROM	(SELECT a.id, COUNT(b.id) cnt
	FROM a, b
	WHERE a.id = b	.cid(+)
	AND a.status	=0
	GROUP BY a.id
	HAVING COUNT(*)	<=(SELECT MIN(COUNT(*))
		FROM b
		WHERE cid IN
		(SELECT id FROM a WHERE status »	=1)
		GROUP BY cid)
	ORDER BY cnt,	id)
WHERE	rownum < 2;
上述语句中，a.id、b.id是主键，a.status只有两个值0和1。
因为a.id是主键，粗体代码部分的半连接可以直接改为INNER JOIN：
SELECT	id
FROM	(SELECT a.id, COUNT(b.id) cnt
	FROM a, b
	WHERE a.id = b.cid(+)
	AND a.status	=0
	GROUP BY a.id
	HAVING COUNT(*)	<=(SELECT MIN(COUNT(b.id))
		FROM b
		INNER JOIN a ON a.id = b.cid
		WHERE a.status = 0
		GROUP BY b.cid) _
	ORDER BY cnt,	id)
WHERE	rownum < 2;
通过“count(*) <=()”语句可以分析到，这个语句的子査询是要找count(b.id) group by a.id的最小值。
那么去掉“count(*) <=()”呢？
• 392 •
第14章改写调优案例分享
SELECT id
FROM (SELECT a.id, COUNT(b.id) cnt FROM a, b WHERE a.id = b.cid(+)
AND a.status = 0 GROUP BY a.id ORDER BY cnt, id)
WHERE rownum < 2;
仍然是取最小值，所以“cmmt(*)<=()”是多余的，只用最后显示的这个査询就可以。
14.54	去掉FILTER里的EXISTS之活学活用
在大部分情况下，如果FILTER里出现了 EXISTS、IN这些子查询，都要对语句进行
例如，	下列语句：
SELECT	/*+	first	—rows */
tO.ani	.AS	col_0	_0_	COUNT(tO.id)	AS col
FROM	to
WHERE	(to.	task—	id	IS NOT NULL)
AND	((to	•type	>	1 OR tO.type <	1) AND
tO.dbdt > current_timestamp - (8 / 24) AND
(tO.ani IN (•列表 1 • > OR concat ('O', tO.ani) IN (•列表 1 *) ) OR tO.type = 1 AND (EXISTS (SELECT /★+ no_unnest */ tl.id FROM tl
WHERE tl.id - tO•lead一interaction一id
AND	tl.begin_date	>=	to_date(*2014-08-08	00:00:00、
'yyyy-MM-dd HH24:mi:ss *)
AND	tl.begin一date	<=	to—date(•2014-08-08	23:59:59',
1yyyy-MM-dd HH24：mi:ss'))) AND
(tO.ani IN r 列表 1\，列表 2 *) OR
•O' | I tO.ani IN「列表 1 _ , 1列表 21, •列表 3')) AND
(tO . acdgroup IN (1 列表 4 1)))
GROUP BY tO.ani;
从上述语句中，很明显地看出这个EXISTS子句肯定会在FILTER中，原因在此不详述。 在更改之前，先看看这个语句的其他问题。
• 393 •
Oracle查询优化改写技巧4案例
①第一个hint	“firSt_rowS”，我们可以看到这个语句是一个分组汇总，很明显，只有 返回所有的数据后才能汇总，而这个提示的意思是优先返回前几行，这是矛盾的。
②提示语句“no—unnest”，是不展开的意思，而其目的是想要去掉FILTER,也就是 要展开，这又是一个矛盾。
③这个查询里加了很多括号，我们知道，加括号是为了对条件分组，括号内的语句 要先执行，问题是这个查询里的括号大部分都是加在单个判断条件上的，而对于OR连接 的两个条件很少处理，所以这个查询里还存在逻辑错误。
由上面的分析可以可看出，给出这个语句的人学习了很多优化方法，但没有理解其中 的原理，只是生搬硬套，这样得出的结果显然不对。因此，希望读者在学习时不要贪多， 能灵活运用一种远比同时使用多种不熟悉的方法获得的效率更高。
若要去掉这个FILTER,有以下两种方法。
①改写成UNION或UNION	ALL,但看到这个语句复杂的逻辑，笔者决定放弃这个 想法。
②可以把EXISTS改为LEFT	JOIN (之所以不改为INNER JOIN，是因为其中有很多 OR 组合，而不是 AND),即 tO LEFT JOIN tl,并把 “tl.id IS NOTNULL” 放在原 EXISTS 的位置：
SELECT tO.ani AS col_0_0_, COUNT(tO.id) AS col_l_0_
FROM tO tO
LEFT JOIN (SELECT tl.id FROM tl
WHERE	tl.begin一date	>=	to_date(12014-08-08	00:00:00*,
1yyyy-MM-dd HH24:mi:ss')
AND	tl.begin_date	<=	to_date(12 014-0 8-0 8	23:59:59、
'yyyy-MM-dd HH24:mi:ss1)) tl
ON (tl.id = tO.lead_interaction_id)
WHERE (t0.task_id IS NOT NULL)
AND ((tO.type >	1 OR tO.type <	1) AND
tO.dbdt > current_timestamp	- (8	/ 24) AND
(tO.ani IN (，列表 1 ’）OR concat ('O', tO.ani) IN ('列表 1”）OR tO.type = 1 AND tl.id IS NOT NULL AND (tO.ani IN ('列表 1、| 列表 2') OR
f0'	|| tO.ani IN ('列表 1’，'列表 2 •,，列表 3，>) AND
(tO . acdgroup IN (1 列表 4 ')))
GROUP BY tO.ani;
• 394 •
电子工业出版社精品丛书推荐
脑动力系列
从零开始学系列
■	V'-丨	榦"|
售: ___ JavaScript	(kxm)		& 轉卜織
	•Android 编程	51单片机	‘HTML+CSS - MATLAB Oracle —- •..
一			^ur-r- Mtuuc mtmiM
由浅入深学系列
由浅入深学	由浅入深学	由浅入深学	由浅入深学	由浅入深学	由*入深学
ASP.NET Java	C#	C 语亩	PHP
—•«.	«>«*«nai 丄	-M.	m«*«4靖	--mm.	•■•••«••	▲
21天学编程系列
宝典丛书系列
华清远见系列
从实践中学
/T
从实践中学
从实践中学
/f
Bmadviews 胃錢点、• I Till I® 麵 口口口 11$
—troadWew.com.cn	技术凝聚实力•专业创新出版
Oracle 査询优化改写技巧与案例
本书的写作手法十分朴实，甚至可以说有些章节有点过于简练，但是瑕不掩瑜，书中实用的内 容之多是十分值得肯定的。本书可以作为DBA的参考书籍，也可以作为开发人员编写SQL的指 导书籍。作为DBA行业的一个老兵，我愿意向大家推荐这本书，对于优化有兴趣的DBA，确实 有必要读一读这本书。
白鳝
国内知名DBA专家
当教主告诉我他准备写一本有关SQL编程改写的书时，我非常高兴，感觉到将会有一大批开发 人员可以借助这样一本书使自己的SQL水平提升一个层次。因为我知道这不是一本SQL入门的 书，也不是一本专门讲优化理论的SQL优化书籍，而是一本结合常见的开发场景介绍编程技巧 的书籍。
黄超（网名：道道） 道森教育集团负责人，资深Oracle培训人员
圖
博文视点Broadview囪
新浪m 専
weibo.com
@博文视点Broad view
r-^-n策划编辑：董英 衫责任编辑：李利健 封面设计：李玲
ISBN 978-7-121-24710-1
9 7 8 7 12 1	2	4	7	10	1	>
定价：69.00元



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



资源由 www.eimhe.com  美河学习在线收集分享
Oracle SQL  编程最佳实践
第一部分 SQL 语言基础
第一章、关系型与非关系型数据库
1.1 关系型数据库由来
关系型数据库，是指采用了关系模型来组织数据的数据库。
关系模型是在 1970 年由 IBM 的研究员 E.F.Codd 博士首先提出的，在之后的几十年中，关系模型的概念得到了充分的发展并逐渐
成为主流数据库结构的模型。
简单来说，关系模型指的就是二维表格模型，而一个关系型数据库就是由二维表及其之间的联系所组成的一个数据组织。
1.2 关系型数据库优点
1）容易理解：
二维表结构是非常贴近逻辑世界的一个概念，关系模型相对之前的网状、层次等其他模型来说更容易理解
2）使用方便：
通用的SQL 语言使得操作关系型数据库非常方便
3）易于维护：
丰富的完整性(实体完整性、参照完整性和用户定义的完整性)大大减低了数据冗余和数据不一致的概率
4）交易安全：
所有关系型数据库都不同程度的遵守事务的四个基本属性，因此对于银行、电信、证券等交易型业务的是不可或缺的。
1.3 关系型数据库瓶颈
1）高并发读写需求
网站的用户并发性非常高，往往达到每秒上万次读写请求，对于传统关系型数据库来说，硬盘 I/O 是一个很大的瓶颈。
2）海量数据的高效率读写
互联网上每天产生的数据量是巨大的，对于关系型数据库来说，在一张包含海量数据的表中查询，效率是非常低的。
3）高扩展性和可用性
在基于web 的结构当中，数据库是最难进行横向扩展的，当一个应用系统的用户量和访问量与日俱增的时候，数据库却没有办
法像web server 和 app server 那样简单的通过添加更多的硬件和服务节点来扩展性能和负载能力。对于很多需要提供 24 小时不
间断服务的网站来说，对数据库系统进行升级和扩展是非常痛苦的事情，往往需要停机维护和数据迁移。
1.4 非关系型数据库
1）NoSQL 特点：
可以弥补关系型数据库的不足。
针对某些特定的应用需求而设计，可以具有极高的性能。
大部分都是开源的，由于成熟度不够，存在潜在的稳定性和维护性问题。
2）NoSQL 分类：
面向高性能并发读写的 key-value 数据库
面向海量数据访问的面向文档数据库
面向可扩展性的分布式数据库
1.5 优势互补，相得益彰
1）关系型数据库适用结构化数据，NoSQL 数据库适用非结构化数据。
2）Oracle 数据库未来的发展方向：提供结构化、非结构化、半结构化的解决方案，实现关系型数据库和 NoSQL 共存互补。值得
强调的是：目前关系型数据库仍是主流数据库，虽然 NoSql 数据库打破了关系数据库存储的观念，可以很好满足 web2.0 时代数
据存储的要求，但 NoSql 数据库也有自己的缺陷。在现阶段的情况下，可以将关系型数据库和 NoSQL 数据库结合使用，相互弥
补各自的不足。
第二章、SQL 的基本函数
2.1 关系型数据库命令类别
数据操纵语言：DML: select; insert; delete; update; merge.
数据定义语言：DDL: create; alter; drop; truncate; rename; comment.
事务控制语言：TCL: commit; rollback; savepoint.
数据控制语言：DCL: grant; revoke.
2.2 单行函数与多行函数
资源由 www.eimhe.com  美河学习在线收集分享
单行函数：指一行数据输入，返回一个值的函数。所以查询一个表时，对选择的每一行数据都返回一个结果。
SQL>select empno,lower(ename) from emp;
多行函数：指多行数据输入，返回一个值的函数。所以对表的群组进行操作，并且每组返回一个结果。（典型的是聚合函数）
SQL>select sum(sal) from emp;
本小结主要介绍常用的一些单行函数，分组函数见第五章
2.3 单行函数的几种类型
2.3.1 字符型函数
lower('SQL Course')----->sql course 返回小写
upper('sql course')----->SQL COURSE 返回大写
initcap('SQL course')-----> Sql Course 每个单字返回首字母大写
concat('good','string')---->good string 拼接 只能拼接 2 个字符串
substr('String',1,3)---->Str 从第 1 位开始截取 3 位数，
演变：只有两个参数的
substr('String',3) 正数第三位起始，得到后面所有字符
substr('String',-2) 倒数第二位，起始，得到最后所有字符
instr('t#i#m#r#a#n#','#') --->找第一个#字符在那个绝对位置，得到的数值
Instr 参数经常作为 substr 的第二个参数值
演变：Instr 参数可有四个之多
如select instr('aunfukk','u',-1,1) from dual; 倒数第一个 u 是哪个位置，结果返回 5
length('String')---->6 长度，得到的是数值
length 参数又经常作为 substr 的第三个参数
lpad('first',10,'$')左填充
rpad(676768,10,'*')右填充
replace('JACK and JUE','J','BL')---->BLACK and BLUE
trim('m' from 'mmtimranm')---->timran 两头截，这里的‘m’是截取集，仅能有一个字符
处理字符串时，利用字符型函数的嵌套组合是非常有效的，试分析一道考题：
create table customers(cust_name varchar2(20));
insert into customers values('Lex De Hann');
insert into customers values('Renske Ladwig');
insert into customers values('Jose Manuel Urman');
insert into customers values('Joson Malin');
select * from customers;
CUST_NAME
--------------------
Lex De Hann
Renske Ladwig
Jose Manuel Urman
Joson Malin
一共四条记录，客户有两个名的，也有三个名的，现在想列出仅有三个名的客户，且第一个名字用*号略去
答案之一：
SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*') "CUST NAME"
FROM customers
WHERE INSTR(cust_name,' ',1,2)<>0;
CUST NAME
*** De Hann
**** Manuel Urman
分析：
先用INSTR(cust_name,' ')找出第一个空格的位置，
然后，SUBSTR(cust_name,INSTR(cust_name,' '))从第一个空格开始往后截取字符串到末尾，结果是第一个空格以后所有的字符,
最后，LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*')用 LPAD 左填充到 cust_name 原来的长度，不足的部
分用*填充，也就是将第一个空格前 的位置，用*填充。
where 后过滤是否有三个名字，INSTR(cust_name, ' ',1,2)从第一个位置，从左往右，查找第二次出现的空格，如果返回非 0 值，
则说明有第二个空格，则有第三个名字。
2.3.2 数值型函数
round 对指定的值做四舍五入,round(p,s) s 为正数时，表示小数点后要保留的位数，s 也可以为负数，但意义不大。
round:按指定精度对十进制数四舍五入,如:round(45.923, 1),结果,45.9
round(45.923, 0),结果,46
round(45.923, -1),结果,50
trunc 对指定的值取整 trunc(p,s)
trunc:按指定精度截断十进制数,如:trunc(45.923, 1),结果,45.9
trunc(45.923),结果,45
trunc(45.923, -1),结果, 40
mod 返回除法后的余数
SQL> select mod(100,12) from dual;
2.3.3 日期型函数
因为日期在 oracle 里是以数字形式存储的，所以可对它进行加减运算，计算是以天为单位。
缺省格式：DD-MON-RR.
可以表示日期范围：（公元前）4712 至（公元）9999
时间格式
SQL> select to_date('2003-11-04 00:00:00' ,'YYYY-MM-DD HH24:MI:SS') FROM dual;
SQL> select sysdate+2 from dual; 当前时间+2day
SQL> select sysdate+2/24 from dual; 当前时间+2hour
SQL> select (sysdate-hiredate)/7 week from emp; 两个 date 类型差，结果是以天为整数位的实数。
①MONTHS_BETWEEN 计算两个日期之间的月数
SQL>select months_between('1994-04-01','1992-04-01') mm from dual;
查找emp 表中参加工作时间>30 年的员工
SQL>select * from emp where months_between(sysdate,hiredate)/12>30;
很容易认为单行函数返回的数据类型与函数类型一致，对于数值函数类型而言的确如此，但字符和日期函数可以返回任何数据
类型的值。比如 instr 函数是字符型的，months_between 函数是日期型的，但它们返回的都是数值。
②ADD_MONTHS 给日期增加月份
SQL>select add_months('1992-03-01',4) am from dual;
③LAST_DAY 日期当前月份的最后一天
SQL>select last_day('1989-03-28') l_d from dual;
④NEXT_DAY NEXT_DAY 的第 2 个参数可以是数字 1-7，分别表示周日--周六(考点）
比如要取下一个星期六，则应该是：
SQL>select next_day(sysdate,7) FROM DUAL;
⑤ROUND(p,s)，TRUNC(p,s)在日期中的应用，如何舍入要看具体情况，s 是 MONTH 按 30 天计，应该是 15 舍 16 入，s 是 YEAR
则按6 舍 7 入计算。
SQL>SELECT empno, hiredate,round(hiredate,'MONTH') AS round,trunc(hiredate,'MONTH') AS trunc
FROM emp WHERE empno=7844;
SQL>SELECT empno, hiredate, round(hiredate,'YEAR') AS round,trunc(hiredate,'YEAR') AS trunc
FROM emp WHERE empno=7839;
2.3.4 几个有用的函数和表达式
1）DECODE 函数和 CASE 表达式：
实现sql 语句中的条件判断语句，具有类似高级语言中的 if-then 语句的功能。
decode函数源自 oracle, case 表达式源自 sql 标准，实现功能类似，decode 语法更简单些。
decode函数用法：
SQL> SELECT job, sal,
decode(job, 'ANALYST', SAL*1.1, 'CLERK', SAL*1.15,'MANAGER', SAL*1.20, SAL) SALARY
FROM emp
decode函数的另两种常见用法：
SQL> select ename,job,decode (comm,null,'nonsale','sale') saleman from emp;
注：单一列处理，共四个参数：含义是：comm 如果为 null 就取'nonsale，否则取'sale'
SQL> select ename,decode (sign(sal-2800), 1, 'HIGH','LOW') as "LEV" from emp;
注：sign()函数根据某个值是 0、正数还是负数，分别返回 0、1、-1，含义是：工资大于 2800,返回 1，真取'HIGH'，假取'LOW'
CASE 表达式第一种用法：
SQL> SELECT job, sal,case job
when 'CLERK' then SAL*1.15
when 'MANAGER' then SAL*1.20
else sal end SALARY
FROM emp
/
CASE 表达式第二种用法：
SQL> SELECT job, sal,case
when job='ANALYST' then SAL*1.1
when job='CLERK' then SAL*1.15
when job='MANAGER' then SAL*1.20
else sal end SALARY
FROM emp
/
以上三种写法结果都是一样的
CASE 第二种语法比第一种语法增加了搜索功能。形式上第一种 when 后跟定值，而第二种还可以使用表达式和比较符。
看一个例子
SQL> SELECT ename,sal,case
when sal>=3000 then '高级'
when sal>=2000 then '中级'
else '低级' end 级别
FROM emp
/
再看一个例子:使用了复杂的表达式
SQL> SELECT AVG(CASE
WHEN sal BETWEEN 500 AND 1000 AND JOB='CLERK'
THEN sal ELSE null END) "CLERK_SAL"
from emp;
比较;
SQL> select avg(sal) from emp where job='CLERK';
2）DISTINCT(去重)限定词的用法：
distinct 貌似多行函数，严格来说它不是函数而是 select 子句中的关键字。
SQL> select distinct job from emp; 消除表行重复值。
SQL> select distinct job,deptno from emp; 重复值是后面的字段组合起来考虑的
3）sys_context 获取环境上下文的函数（应用开发）
scott远程登录
SQL>select SYS_CONTEXT('USERENV','IP_ADDRESS') from dual;
--------------------------------------------------------------------------------
192.168.0.136
SQL> select sys_context('userenv','sid') from dual;
SYS_CONTEXT('USERENV','SID')
--------------------------------------------------------------------------------
129
SQL> select sys_context('userenv','terminal') from dual;
SYS_CONTEXT('USERENV','TERMINAL')
--------------------------------------------------------------------------------
TIMRAN-222C75E5
4）处理空值的几种函数（见第四章）
5）转换函数 TO_CHAR、TO_DATE、TO_NUMBER （见第三章）
资源由 www.eimhe.com  美河学习在线收集分享
第三章、SQL 的数据类型(表的字段类型）
3.1 四种基本的常用数据类型（表的字段类型）
1、字符型，2、数值型，3、日期型，4、大对象型
3.1.1 字符型：
字符类型 char 和 varchar2 的区别
SCOTT@ prod>create table t1(c1 char(10),c2 varchar2(10));
SCOTT@ prod>insert into t1 values('a','ab');
SCOTT@ prod>select length(c1),length(c2) from t1;
LENGTH(C1) LENGTH(C2)
---------- ----------
10 2
3.1.2 数值型：
3.1.3 日期型：
资源由 www.eimhe.com  美河学习在线收集分享
系统安装后，默认日期格式是 DD-MON-RR, RR 和 YY 都是表示两位年份，但 RR 是有世纪认知的，它将指定日期的年份和当前年
份比较后确定年份是上个世纪还是本世纪（如表）。
当前年份  指定日期  RR 格式  YY 格式
------------------------------------------------------------------------------
1995  27-OCT-95 1995 1995
1995  27-OCT-17 2017 1917
2001  27-OCT-17 2017 2017
2013  27-OCT-95 1995 2095
3.1.4 LOB 型：
大对象是 10g 引入的，在 11g 中又重新定义，在一个表的字段里存储大容量数据，所有大对象最大都可能达到 4G
CLOB，NCLOB，BLOB 都是内部的 LOB 类型，没有 LONG 只能有一列的限制。
保存图片或电影使用 BLOB 最好、如果是小说则使用 CLOB 最好。
虽然LONG、RAW 也可以使用，但 LONG 是 oracle 将要废弃的类型，因此建议用 LOB。
虽说将要废弃，但还没有完全废弃，比如 oracle 11g 里的一些视图如 dba_views，对于 text(视图定义）仍然沿用了 LONG 类型。
Oracle 11g 重新设计了大对象，推出 SecureFile Lobs 的概念，相关的参数是 db_securefile，采用 SecureFile Lobs 的前提条件是 11g
以上版本，ASSM 管理等，符合这些条件的
BasicFile Lobs 也可以转换成 SecureFile Lobs。较之过去的 BasicFile Lobs, SecureFile Lobs 有几项改进：
1）压缩，2）去重，3）加密。
当create table 定义 LOB 列时，也可以使用 LOB_storage_clause 指定 SecureFile Lobs 或 BasicFile Lobs
而LOB 的数据操作则使用 Oracle 提供的 DBMS_LOB 包，通过编写 PL/SQL 块完成 LOB 数据的管理。
3.2 数据类型的转换
3.2.1 转换的需求
什么情况下需要数据类型转换
1）如果表中的某字段是日期型的，而日期又是可以进行比较和运算的，这时通常要保证参与比较和运算的数据类型都是日期型。
2）当对函数的参数进行抽（截）取、拼接，或运算等操作时，需要转换为那个函数的参数要求的数据类型。
3）制表输出有格式需求的，可将 date 类型，或 number 类型转换为 char 类型
资源由 www.eimhe.com  美河学习在线收集分享
4）转换成功是有条件的，有隐性转换和显性转换两种方式
3.2.2 隐性类型转换：
是指oracle 自动完成的类型转换。在一些带有明显意图的字面值上，可以由 Oracle 自主判断进行数据类型的转换。
一般规律：
①比较、运算或连接时：
SQL> select empno,ename from emp where empno='7788'
empno 本来是数值类型的，这里字符'7788'隐性转换成数值 7788
SQL> SELECT '12.5'+11 FROM dual;
将字符型‘12.5’隐转成数字型再求和
SQL> SELECT 10+('12.5'||11) FROM dual;
将数字型 11 隐转成字符与‘12.5’合并，其结果再隐转数字型与 10 求和
②调用函数时
SQL> select length(sysdate) from dual;
将date 型隐转成字符型后计算长度
③向表中插入数据时
create table scott. t1 (id int,name char(10),birth date);
insert into scott.t1 values('123',456,'2017-07-15');
按照字段的类型进行隐式转换
3.2.3 显性类型转换
即强制完成类型转换（推荐），有三种形式的数据类型转换函数：
TO_CHAR
TO_DATE
TO_NUMBER
1）日期-->字符
SQL> select ename,hiredate, to_char(hiredate, 'DD-MON-YY') month_hired from emp
where ename='SCOTT';
ENAME HIREDATE MONTH_HIRED
---------- ------------------- --------------
SCOTT 1987-04-19 00:00:00 19-4 月 -87
fm 压缩空格或左边的'0'
SQL> select ename, hiredate, to_char(hiredate, 'fmyyyy-mm-dd') month_hired from emp
where ename='SCOTT';
ENAME HIREDATE MONTH_HIRED
---------- ------------------- ------------
SCOTT 1987-04-19 00:00:00 1987-4 19
其实DD-MM-YY 是比较糟糕的一种格式，因为当日期中天数小于 12 时，DD-MM-YY 和 MM-DD-YY 容易造成混乱。
以下用法也很常见
SQL> select to_char(hiredate,'yyyy') FROM emp;
SQL> select to_char(hiredate,'mm') FROM emp;
SQL> select to_char(hiredate,'dd') FROM emp;
SQL> select to_char(hiredate,'DAY') FROM emp;
2）数字-->字符：9 表示数字，L 本地化货币字符
SQL> select ename, to_char(sal, 'L99,999.99') Salary from emp where ename='SCOTT';
ENAME SALARY
资源由 www.eimhe.com  美河学习在线收集分享
---------- --------------------
SCOTT ￥3,000.00
以下四个语句都是一个结果（考点），
SQL> select to_char(1890.55,'$99,999.99') from dual;
SQL> select to_char(1890.55,'$0G000D00') from dual;
SQL> select to_char(1890.55,'$99G999D99') from dual;
SQL> select to_char(1890.55,'$99G999D00') from dual; 9 和 0 可用，其他数字不行
3）字符-->日期
SQL> select to_date('1983-11-12', 'YYYY-MM-DD') tmp_DATE from dual;
4）字符-->数字：
SQL> SELECT to_number('$123.45','$9999.99') result FROM dual;
使用to_number 时如果使用较短的格式掩码转换数字，就会返回错误。不要混淆 to_number 和 to_char 转换。
SQL> select to_number('123.56','999.9') from dual;
报错：ORA-01722: 无效数字
练习：建立 t1 表，包括出生日期，以不同的日期描述方法插入数据，显示小于 15 岁的都是谁
SQL> create table t1 (id int,name char(10),birth date);
insert into t1 values(1,'tim',sysdate);
insert into t1 values(2,'brian',sysdate-365*20);
insert into t1 values(3,'mike',to_date('1998-05-11','yyyy-mm-dd'));
insert into t1 values(4,'nelson',to_date('15-2 月-12','dd-mon-rr'));
SQL> select * from t1;
ID NAME BIRTH
---------- ---------- -------------------
1 tim 2016-02-25 17:34:00
2brian 1996-03-01 17:34:22
3 mike 1998-05-11 00:00:00
4 nelson 2012-02-15 00:00:00
SQL>select name||'的年龄是'||to_char(months_between(sysdate,birth)/12,99) age from t1
where months_between(sysdate,birth)/12<15;
AGE
-------------------------
tim 的年龄是 0
nelson 的年龄是 4
第四章、WHERE 子句中常用的运算符
4.1 运算符及优先级：
算数运算符
*，/，+，-，
逻辑运算符
not, and ,or
比较运算符
1）单行比较运算 =,>, >=,<,<=, <>
2）多行比较运算 >any,>all,<any,<all,in，not in
3）模糊比较 like（配合“%”和“_”）
4）特殊比较 is null
5）()优先级最高
SQL>select ename, job, sal ,comm from emp where job='SALESMAN' OR job='PRESIDENT' AND sal> 1500;
注意：条件子句使用比较运算符比较两个选项，重要的是要理解这两个选项的数据类型。必须得一致，所以这里常用显性转换。
数值型、日期型、字符型都可以与同类型比较大小，但数值和日期比的是数值的大小，而字符比的是 acsii 码的大小
试比较下面语句，结果为什么不同
SQL> select * from emp where hiredate>to_date('1981-02-21','yyyy-mm-dd');
SQL> select * from emp where to_char(hiredate,'dd-mon-rr')>'21-feb-81';
4.2 常用谓词
4.2.1 用 BETWEEN AND 操作符来查询出在某一范围内的行.
SQL> SELECT ename, sal FROM emp WHERE sal BETWEEN 1000 AND 1500;
资源由 www.eimhe.com  美河学习在线收集分享
between 低值 and 高值，包括低值和高值。
4.2.2 模糊查询及其通配符：
在where 子句中使用 like 谓词，常使用特殊符号"%"或"_"匹配查找内容，也可使用 escape 可以取消特殊符号的作用。
SQL>
create table test (name char(10));
insert into test values ('sFdL');
insert into test values ('AEdLHH');
insert into test values ('A%dMH');
commit;
SQL> select * from test;
NAME
----------
sFdL
AEdLHH
A%dMH
SQL> select * from test where name like 'A\%%' escape '\';
NAME
----------
A%dMH
4.2.3' '和" "的用法：
单引号的转义：连续两个单引号表示转义.
' '内表示字符或日期数据类型，而" " 一般用于别名中有大小写、保留字、空格等场合，引用 recyclebin 中的《表名》也需要" ".
SQL> select empno||' is Scott''s empno' from emp where empno=7788;
EMPNO||'ISSCOTT''SEMPNO'
--------------------------------------------------------
7788 is Scott's empno
4.2.4 交互输入变量符&和&&的用途：
①使用&交互输入
SQL> select empno,ename from emp where empno=&empnumber;
输入 empnumber 的值: 7788
&后面是字符型的，注意单引号问题，可以有两种写法：
SQL> select empno,ename from emp where ename='&emp_name';
输入 emp_name 的值: SCOTT
SQL> select empno,ename from emp where ename=&emp_name;
输入 emp_name 的值: 'SCOTT'
②使用&&可以在当前 session 下将&保存为变量
作用是使后面的相同的&不再提问，自动取代。
SQL> select empno,ename,&&salary from emp where deptno=10 order by &salary;
输入 salary 的值: sal
上例给的&salary 已经在当前 session 下存储了，可以使用 undefine salary 解除。
&&salary 和&的提示是按所在位置从左至右边扫描，&&salary 写在左边(首位)，&salary(第二位)
③define(定义变量）和 undefine 命令（解除变量）
SQL> define --显示当前已经定义的变量（包括默认值）
set define on|off 可以打开和关闭&。
SQL> define emp_num=7788 定义变量 emp_num
SQL>select empno,ename,sal from emp where empno=&emp_num;
SQL>undefine emp_num 取消变量
如果不想显示“原值”和“新值”的提示，可以使用 set verify on|off 命令
④Accept 接收一个变量
类似define 功能，但通常和&配合使用
SQL> accept lowdate prompt 'Please enter the low date range ("MM/DD/YYYY"):';
SQL> accept highdate prompt 'Please enter the highdate range ("MM/DD/YYYY"):';
SQL> select ename||','||job as EMPLOYEES, hiredate from emp where hiredate between to_date('&lowdate','MM/DD/YYYY') and
to_date('&highdate','MM/DD/YYYY');
4.2.5 使用逻辑操作符: AND; OR; NOT
AND 两个条件都为 TRUE ，则返回 TRUE
SQL> SELECT empno,ename,job,sal FROM emp WHERE sal>=1100 AND job='CLERK';
OR 两个条件中任何一个为 TRUE，则返回 TRUE
资源由 www.eimhe.com  美河学习在线收集分享
SQL> SELECT empno,ename,job,sal FROM emp WHERE sal>=1100 OR job='CLERK';
NOT 如果条件为 FALSE，返回 TRUE
SQL> SELECT ename,job FROM emp WHERE job NOT IN ('CLERK','MANAGER','ANALYST');
4.2.6 什么是伪列
简单理解它是表中的列，但不是你创建的。
Oracle 数据库有两个著名的伪列 rowid 和 rownum
ROWID 的含义
rowid 可以说是物理存在的，表示记录在表空间中的唯一位置 ID，所以表的每一行都有一个独一无二的物理门牌号。
ROWNUM 的含义
rownum 是对结果集增加的一个伪列，即先查到结果集，当输出时才加上去的一个编号。rownum 必须包含 1 才有值输出。
SQL> select rowid,rownum,ename from emp;
SQL> select * from emp where rowid='AAARZ+AAEAAAAG0AAH';
SQL> select * from emp where rownum<=3;
第五章、分组函数
5.1 五个分组函数
sum(); avg(); count(); max(); min().
数值类型可以使用所有组函数
SQL> select sum(sal) sum, avg(sal) avg, max(sal) max, min(sal) min, count(*) count from emp;
MIN(),MAX(),count()可以作用于日期类型和字符类型
SQL> select min(hiredate), max(hiredate)，min(ename),max(ename),count(hiredate) from emp;
COUNT(*)函数返回表中行的总数，包括重复行与数据列中含有空值的行，而其他分组函数的统计都不包括空值的行。
COUNT(comm)返回该列所含非空行的数量。
SQL> select count(*),count(comm) from emp;
COUNT(*) COUNT(COMM)
---------- -----------
14 4
5.2 GROUP BY 建立分组
SQL>select deptno, avg(sal）from emp group by deptno;
group by 后面的列也叫分组特性，一旦使用了 group by, select 后面只能有两种列，一个是组函数列，而另一个是分组特性列（可
选）。
对分组结果进行过滤
SQL>select deptno, avg(sal) avgcomm from emp group by deptno having avg(sal)>2000;
SQL>select deptno, avg(sal) avgcomm from emp where avg(sal)>2000 group by deptno; 错误的,应该使用 HAVING 子句
对分组结果排序
SQL>select deptno, avg(nvl(sal,0)) avgcomm from emp group by deptno order by avg(nvl(sal,0));
排序的列不在 select 投影选项中也是可以的，这是因为 order by 是在 select 投影前完成的。
5.3 分组函数的嵌套
单行函数可以嵌套任意层，但分组函数最多可以嵌套两层。
比如：count(sum(avg)))会返回错误“ORA-00935：group function is nested too deeply”.
在分组函数内可以嵌套单行函数，如：要计算各个部门 ename 值的平均长度之和
SQL> select sum(avg(length(ename))) from emp group by deptno;
第六章、数据限定与排序
6.1 SQL 语句的编写规则
1）SQL 语句是不区分大小写的，关键字通常使用大写；其它文字都是使用小写
2）SQL 语句可以是一行，也可以是多行，但关键字不能在两行之间一分为二或缩写
3）子句通常放在单独的行中，这样可以增强可读性并且易于编辑
4）使用缩进是为了增强可读性
简单查询语句执行顺序
简单查询一般是指一个 SELECT 查询结构，仅访问一个表。
资源由 www.eimhe.com  美河学习在线收集分享
基本语法如下：
SELECT 子句— 指定查询结果集的列组成，列表中的列可以来自一个或多个表或视图。
FROM 子句— 指定要查询的一个或多个表或视图。
WHERE 子句— 指定查询的条件。
GROUP BY 子句— 对查询结果进行分组的条件。
HAVING 子句— 指定分组或集合的查询条件。
ORDER BY 子句— 指定查询结果集的排列顺序
语句执行的一般顺序为①from, ②where, ③group by, ④having, ⑤order by, ⑥select
where 限定 from 后面的表或视图，限定的选项只能是表的列或列单行函数或列表达式，where 后不可以直接使用分组函数
SQL> select empno,job from emp where sal>2000;
SQL> select empno,job from emp where length(job)>5;
SQL> select empno,job from emp where sal+comm>2000;
having 限定 group by 的结果，限定的选项必须是 group by 后的聚合函数或分组列，不可以直接使用 where 后的限定选项。
SQL> select sum(sal) from emp group by deptno having deptno=10;
SQL> select deptno,sum(sal) from emp group by deptno having sum(sal)>7000;
也存在一些不规范的写法：不建议采用。如上句改成 having 位置 在 group by 之前
SQL> select deptno,sum(sal) from emp having sum(sal)>7000 group by deptno;
6.2 排序(order by)
1）位置：order by 语句总是在一个 select 语句的最后面。
2）排序可以使用列名，列表达式，列函数，列别名，列位置编号等都没有限制，select 的投影列可不包括排序列，除指定的列
位置标号外。
3）升序和降序，升序 ASC（默认), 降序 DESC。有空值的列的排序，缺省（ASC 升序）时 null 排在最后面（考点）。
4）混合排序，使用多个列进行排序，多列使用逗号隔开，可以分别在各列后面加升降序。
SQL> select ename,sal from emp order by sal;
SQL> select ename,sal as salary from emp order by salary;
SQL> select ename,sal as salary from emp order by 2;
SQL> select ename,sal,sal+100 from emp order by sal+comm;
SQL> select deptno,avg(sal) from emp group by deptno order by avg(sal) desc;
SQL> select ename,job,sal+comm from emp order by 3 nulls first;
SQL> select ename,deptno,job from emp order by deptno asc,job desc;
6.3 空值（null)
空值既不是数值 0,也不是字符" ", null 表示不确定。
6.3.1 空值参与运算或比较时要注意几点：
1）空值（null）的数据行将对算数表达式返回空值
SQL> select ename,sal,comm,sal+comm from emp;
2）分组函数忽略空值
SQL> select sum(sal),sum(sal+comm) from emp; 为什么 sal+comm 的求和小于 sal 的求和？
SUM(SAL) SUM(SAL+COMM)
---------- -------------
29025 7800
3）比较表达式选择有空值（null）的数据行时，表达式返回为“假”，结果返回空行。
SQL>select ename,sal,comm from emp where sal>=comm;
4）非空字段与空值字段做"||"时, null 值转字符型""，合并列的数据类型为 varchar2。
资源由 www.eimhe.com  美河学习在线收集分享
SQL> select ename,sal||comm from emp;
5）not in 在子查询中的空值问题（见第八章）
6）外键值可以为 null，唯一约束中，null 值可以不唯一（见十二章）
7）空值在 where 子句里使用“is null”或“is not null”
SQL> select ename,mgr from emp where mgr is null;
SQL> select ename,mgr from emp where mgr is not null;
8SQL> update emp set comm=null where empno=7788;
6.3.2 处理空值的几种函数方法：
1）nvl(expr1,expr2)
当第一个参数不为空时取第一个值，当第一个值为 NULL 时，取第二个参数的值。
SQL>select nvl(1,2) from dual;
NVL(1,2)
----------
1
SQL> select nvl(null,2) from dual;
NVL(NULL,2)
-----------
2
nvl 函数可以作用于数值类型，字符类型，日期类型，但数据类型尽量匹配。
NVL(comm,0)
NVL(hiredate,'1970-01-01')
NVL(ename,'no manager')
2）nvl2(expr1,expr2,expr3)
当第一个参数不为 NULL，取第二个参数的值，当第一个参数为 NULL，取第三个数的值。
SQL> select nvl2(1,2,3) from dual;
NVL2(1,2,3)
-----------
2
SQL> select nvl2(null,2,3) from dual;
NVL2(NULL,2,3)
--------------
3
SQL> select ename,sal,comm,nvl2(comm,SAL+COMM,SAL) income,deptno from emp where deptno in (10,30);
考点:
1）nvl 和 nvl2 中的第二个参数不是一回事。
2）nvl2 的第二个参数和第三个参数要一致，如果不一致，第三个参数隐形转换成第二个参数
3）NULLIF（expr1,expr2)
当第一个参数和第二个参数相同时，返回为空，当第一个参数和第二个数不同时，返回第一个参数值，第一个参数值不允许为
null
SQL> select nullif(2,2) from dual;
SQL> select nullif(1,2) from dual;
4）coalesce（expr1,expr2........)
返回从左起始第一个不为空的值，如果所有参数都为空，那么返回空值。
这里所有的表达式都是同样的数据类型
SQL> select coalesce(1,2,3,4) from dual;
SQL> select coalesce(null,2,null,4) from dual;
第七章、复杂查询(上)：多表连接技术
7.1 简单查询的解析方法：
全表扫描：指针从第一条记录开始，依次逐行处理，直到最后一条记录结束；
横向选择+纵向投影=结果集
7.2 多表连接
7.2.1 多表连接的优缺点
资源由 www.eimhe.com  美河学习在线收集分享
优点：
1）减少冗余的数据，意味着优化了存储空间，降低了 IO 负担。
2）根据查询需要决定是否需要表连接。
3）灵活的增加字段，各表中字段相对独立（非主外键约束），增减灵活。
缺点：
1）多表连接语句可能冗长复杂，易读性差。
2）可能需要更多的 CPU 资源，一些复杂的连接算法消耗 CPU 和 Memory。
3）只能在一个数据库中完成多表连接查询。
7.2.2 多表连接中表的对应关系
1）一对一关系
将表一份为二，最简单的对应关系
2）一对多关系
两表通过定义主外键约束，符合第三范式标准的对应关系。
3）多对多关系
资源由 www.eimhe.com  美河学习在线收集分享
非标准的对应关系
当两表为多对多关系的时候，通常需要建立一个中间表，中间表至少要有两表的主键，这样，可使中间表分别与每个表为一对
多关系。
7.2.3 多表连接的种类和语法
交叉连接（笛卡尔积）
非等值连接
等值连接(内连)
外连接（内连的扩展，左外，右外，全连接）
自连接
自然连接（内连，隐含连接条件,自动匹配连接字段）
复合连接（多个结果集进行并、交、差）
7.2.1 交叉连接（笛卡尔积）
连接条件无效或被省略，两个表的所有行都发生连接，所有行的组合都会返回（n*m）
SQL99 写法：
SCOTT@ prod>select * from emp e cross join dept d;
Oracle 写法：
SCOTT@ prod>select * from emp e,dept d;
7.2.2 非等值连接：（连接条件没有“=”号）
SQL99 写法：
SCOTT@ prod>select empno,ename,sal,grade,losal,hisal from emp join salgrade on sal between losal and hisal;
Oracle 写法：
SCOTT@ prod>select empno,ename,sal,grade,losal,hisal from emp,salgrade where sal between losal and hisal;
7.2.3 等值连接，典型的内连接
SQL99 写法：
SCOTT@ prod>select e.ename,d.loc from emp e inner join dept d on e.deptno=d.deptno;
Oracle 写法：
SCOTT@ prod>select e.ename,d.loc from emp e,dept d where e.deptno=d.deptno;
7.2.4 等值连接的 using 字句（常用）
资源由 www.eimhe.com  美河学习在线收集分享
等值连接的连接字段可以相同，
比如 on e.deptno=d.deptno;
也可以不同
比如 on e.empno=e.mgr
如果连接字段相同，可以使用 using 字句简化书写
如 on e.deptno=d.detpno.; 换成 using(deptno)
例:
SCOTT@ prod>select e.ename,d.loc from emp e inner join dept d using(deptno); using 里也可以多列
使用using 关键字注意事项
1、如果 select 的结果列表项中包含了 using 关键字所指明的那个关键字，那么，不要指明该关键字属于哪个表。
2、using 中可以指定多个列名。
3、on 和 using 关键字是互斥的，也就是说不能同时出现。
7.2.5 外连接（包括左外连接，右外连接，全外连接）
1） 左外连接语法
SQL99 语法:
SCOTT@ prod>select * from emp e left outer join dept d on e.deptno=d.deptno;
Oracle 语法:
SCOTT@ prod>select * from emp e,dept d where e.deptno=d.deptno(+);
2） ） 左连接要理解两个关键点
1、如何确定左表和右表（左连右连都一样）
SQL99 写法：通过 from 后面表的先后顺序确定，第一个表为左表
SCOTT@ prod>select e.ename,d.loc from emp e left join dept d on e.deptno=d.deptno;
from 后第一个表是 emp 表，为左表，“=”左右位置无所谓
Oracle 写法：通过 where 后面的“=”的位置确定，“=”号左边的为左表
SCOTT@ prod>select e.ename,d.loc from emp e,dept d where e.deptno=d.deptno(+);
“=”左边是 emp 表，为左表，from 后面表位置无所谓
2、左连是左表为主
①左连是以左表为驱动，每行都参与匹配右表的行，匹配上就连成一行，如果匹配不上，左表行也不缺失该连接行，这时右表
内容填空就是了。
②左连后，左表的行是不缺失的，即左连后的结果集的行数>=左表行数，存在>的可能是因为左表的一行可能匹配了右表的多行。
③也可以左表、右表都是同一个表，即“自左连”。
3、到底哪个表当左表好
无一定之规，根据业务需求来决定。
两表之间一般以主外键确定一对多关系，外键表是明细表，比如 emp 和 dept 的关系，以 deptno 确定父子关系，emp 是外键表
你要查每个员工的工作地点，这时以外键表（emp 明细表）做左表理所当然
SCOTT@ prod>select e.ename,d.loc from emp e left outer join dept d on e.deptno=d.deptno;
你要查每个部门有多少员工，这时以主键表(dept)做左表更合理
SCOTT@ prod>select d.deptno,count(e.deptno) from dept d left outer join emp e on e.deptno=d.deptno group by d.deptno;
推导一下：
SCOTT@ prod>select d.deptno,e.deptno from dept d left outer join emp e on e.deptno=d.deptno;
资源由 www.eimhe.com  美河学习在线收集分享
以上三点，属于个人理解，这套法则同样适用于右连。
2）右外连接
SQL99 语法:
SCOTT@ prod>select * from emp e right join dept d on e.deptno=d.deptno;
Oracle 语法:
SCOTT@ prod> select * from emp e,dept d where e.deptno(+)=d.deptno;
3）全外连接
SQL99 语法:
SCOTT@ prod> select * from emp e full join dept d on e.deptno=d.deptno;
Oracle 语法:（无，等同于 union 连接）
SCOTT@ prod>
select * from emp e,dept d where e.deptno=d.deptno(+)
Union
select * from emp e,dept d where e.deptno(+)=d.deptno;
7.2.6 自连接
SQL99 语法：
SCOTT@ prod>select e1.empno,e2.mgr from emp e1 cross join emp e2;
Oracle 语法:
SCOTT@ prod> select e1.empno,e2.mgr from emp e1,emp e2;
必须使用别名区别不同的表
7.2.6 自然连接（属于内连中等值连接）
使用关键字 natural join,就是自然连接。
SCOTT@ prod>select e.ename,d.loc from emp e natural join dept d;
如果有多列复合匹配条件，则自动多列匹配
7.3 复合查询（使用集合运算符）
Union，对两个结果集进行并集操作，重复行只取一次，同时进行默认规则的排序；
Union All，对两个结果集进行并集操作，包括所有重复行，不进行排序；
Intersect，对两个结果集进行交集操作，重复行只取一次，同时进行默认规则的排序；
Minus，对两个结果集进行差操作，不取重复行，同时进行默认规则的排序。
资源由 www.eimhe.com  美河学习在线收集分享
复合查询操作有并，交，差３种运算符。
示例：
SQL> create table dept1 as select * from dept where rownum <=1;
SQL> insert into dept1 values (80, 'MARKTING', 'BEIJING');
SQL> select * from dept;
DEPTNO DNAME LOC
---------- -------------- -------------
10 ACCOUNTING NEW YORK
20 RESEARCH DALLAS
30 SALES CHICAGO
40 OPERATIONS BOSTON
SQL> select * from dept1;
DEPTNO DNAME LOC
---------- -------------- -------------
10 ACCOUNTING NEW YORK
80 MARKTING BEIJING
1）union
SQL>
select * from dept
union
select * from dept1;
DEPTNO DNAME LOC
---------- -------------- -------------
10 ACCOUNTING NEW YORK
20 RESEARCH DALLAS
30 SALES CHICAGO
40 OPERATIONS BOSTON
80 MARKTING BEIJING
2）union all
SQL>
select * from dept
union all
select * from dept1;
DEPTNO DNAME LOC
---------- -------------- -------------
10 ACCOUNTING NEW YORK
20 RESEARCH DALLAS
30 SALES CHICAGO
40 OPERATIONS BOSTON
10 ACCOUNTING NEW YORK
80 MARKTING BEIJING
特别注意：可以看出只有 union all 的结果集是不排序的。
3）intersect
SQL>
资源由 www.eimhe.com  美河学习在线收集分享
select * from dept
intersect
select * from dept1;
DEPTNO DNAME LOC
---------- -------------- -------------
10 ACCOUNTING NEW YORK
4）minus（注意谁 minus 谁）
SQL>
select * from dept
minus
select * from dept1;
DEPTNO DNAME LOC
---------- -------------- -------------
20 RESEARCH DALLAS
30 SALES CHICAGO
40 OPERATIONS BOSTON
SQL>
select * from dept1
minus
select * from dept;
DEPTNO DNAME LOC
---------- -------------- -------------
80 MARKTING BEIJING
7.4 复合查询几点注意事项
1）列名不必相同，但要类型匹配且顺序要对应，大类型对上就行了，比如 char 对 varchar2，date 对 timestamp 都可以，字段数
要等同，不等需要补全。
create table a (id_a int,name_a char(10));
create table b (id_b int,name_b char(10),sal number(10,2));
insert into a values (1, 'sohu');
insert into a values (2, 'sina');
insert into b values (1, 'sohu', 1000);
insert into b values (2, 'yahoo', 2000);
commit;
SQL> select * from a;
ID_A NAME_A
---------- ----------
1 sohu
2 sina
SQL> select * from b;
ID_B NAME_B SAL
---------- ---------- ----------
1 sohu 1000
2 yahoo 2000
SQL>
select id_a,name_a from a
union
select id_b,name_b from b;
2）四种集合运算符优先级按先后出现的顺序执行，如有特殊要求可以使用（）。
3）关于复合查询中 order by 使用别名排序的问题：
资源由 www.eimhe.com  美河学习在线收集分享
①缺省情况下，复合查询后的结果集是按所有字段的组合隐式排序的（除 union all 外）
如果不希望缺省的排序，也可以使用 order by 显式排序
select id_a, name_a name from a
union
select id_b, name_b name from b
order by name;
select id_a, name_a from a
union
select id_b, name_b from b
order by 2;
②显式order by 是参照第一个 select 语句的列元素。所以，order by 后的列名只能是第一个 select 使用的列名、别名、列号（考
点）。如果是补全的 null 值需要 order by，则需要使用别名。
SQL>
select id_a, name_a name,to_number(null) from a
union
select id_b, name_b name,sal from b
order by sal;
报错：ORA-00904: "SAL": 标识符无效
以下三种写法都是正确的
SQL>
select id_a, name_a name,to_number(null) from a
union
select id_b, name_b name,sal from b
order by 3;
SQL>
select id_b, name_b name,sal from b
union
select id_a, name_a name,to_number(null) from a
order by sal;
SQL>
select id_a, name_a name,to_number(null) aa from a
union
select id_b, name_b name,sal aa from b
order by aa;
③排序是对复合查询结果集的排序，不能分别对个别表排序，order by 只能一次且出现在最后一行；
SQL>
select id_a, name_a from a order by id_a
union
select id_b, name_b from b order by id_b;
报错：ORA-00933: SQL 命令未正确结束
第八章、复杂查询(下)：子查询
8.1 非关联子查询 ：
返回的值可以被外部查询使用。子查询可以独立执行的（且仅执行一次）。
资源由 www.eimhe.com  美河学习在线收集分享
8.1.1 单行单列子查询
子查询仅返回一个值，也称为标量子查询，采用单行比较运算符（>，<，=，<>,>=，<=）
例：内部 SELECT 子句只返回单值
SQL>select ename,sal
from emp
where sal > (
select sal from emp
where ename='JONES')
/
8.1.2 多行单列子查询
子查询返回一列多行，采用多行比较运算符（in，not in，all, any）
1）使用 in (逐个比较是否有匹配值）
SQL> select ename, sal from emp where sal in (800,3000,4000);
例：显示出 emp 表中那些员工不是普通员工（属于大小领导的）。
SQL>select ename from emp where empno in (select mgr from emp);
2）使用 not in (子查询不能返回空值）
"in"与"not in"遇到空值时情况不同，对于"not in" 如果子查询的结果集中有空值，那么主查询得到的结果集也是空。
例：查找出没有下属的员工,即普通员工，（该员工号不在 mgr 之列的）
SQL>select ename from emp where empno not in (select mgr from emp);
no rows selected
上面的结果不出所料，主查询没有返回记录。这个原因是在子查询中有一个空值，而对于 not in 这种形式，一旦子查询出现了
空值，则主查询记录结果也就返回空了
排除空值的影响
SQL>select ename from emp where empno not in (select nvl(mgr,0)from emp);
注意：not 后不能跟单行比较符，只有 not in 组合，也没有 not any 和 not all 的组合，但 not 后可以接表达式 如：
where empno not in(...）与 where not empno in(...)两个写法都是同样结果，前者是 not in 组合，后者是 not 一个表达式。
3）使用 all （>大于最大的，<小于最小的）
SQL> select ename,sal from emp where sal >all (2000,3000,4000);
例：查找高于所有部门的平均工资的员工（>比子查询中返回的列表中最大的大才行）
SQL> select ename, job, sal from emp where sal > all(select avg(sal) from emp group by deptno);
ENAME JOB SAL
---------- --------- ----------
JONES MANAGER 2975
SCOTT ANALYST 3000
KING PRESIDENT 5000
FORD ANALYST 3000
4）在多行子查询中使用 any （>大于最小的，<小于最大的）
>any 的意思是：>比子查询中返回的列表中最小的大就行, 注意和 all 的区别，all 的条件苛刻，any 的条件松阔，any 强调的是只
要有任意一个符合就行了，所以>any 只要比最小的那个大就行了，没必要比最大的还大。
select ename, sal from emp where sal >any (2000,3000,4000);
8.1.3 多行多列子查询
资源由 www.eimhe.com  美河学习在线收集分享
子查询返回多列结果集。有成对比较、非成对比较两种形式。
测试准备
SQL>create table emp1 as select * from emp;
SQL>update emp1 set sal=1600,comm=300 where ename='SMITH'; SMITH 是 20 部门的员工
SQL>update emp1 set sal=1500,comm=300 where ename='CLARK'; CLARK 是 10 部门的员工
SQL> select * from emp1;
SQL> select empno,ename,sal,comm,deptno from emp1;
EMPNO ENAME SAL COMM DEPTNO
---------- ---------- ---------- ---------- ----------
7369 SMITH 1600 300 20
7499 ALLEN 1600 300 30
7521 WARD 1250 500 30
7566 JONES 2975 20
7654 MARTIN 1250 1400 30
7698 BLAKE 2850 30
7782 CLARK 1500 300 10
7788 SCOTT 3000 20
7839 KING 5000 10
7844 TURNER 1500 0 30
7876 ADAMS 1100 20
7900 JAMES 950 30
7902 FORD 3000 20
7934 MILLER 1300 10
查询条件：查找 emp1 表中是否有与 30 部门的员工工资和奖金相同的其他部门的员工。
注意看一下：现在 20 部门的 SIMTH 符合这个条件，它与 30 部门的 ALLEN 有相同的工资和奖金
1）成对比较多列子查询：
特点是主查询每一行中的列都要与子查询返回列表中的相应列同时进行比较，只有各列完全匹配时才显示主查询中的该数据行。
SQL>
select ename,deptno,sal,comm from emp1
where (sal,comm) in (select sal,comm from emp1 where deptno=30)
and deptno<>30
/
ENAME DEPTNO SAL COMM
---------- ---------- ---------- ----------
SMITH 20 1600 300
考点：1）成对比较是不能使用>any 或>all 等多行单列比较符的。2）成对比较时的多列顺序和类型必须一一对应。
2）非成对比较成对多列子查询（含布尔运算）
例：非成对比较
SQL>select ename,deptno,sal,comm from emp1
where sal in(
select sal
from emp1
where deptno=30)
and
nvl(comm,0) in (
select nvl(comm,0)
from emp1
where deptno=30)
and deptno<>30
/
ENAME DEPTNO SAL COMM
---------- ---------- ---------- ----------
SMITH 20 1600 300
CLARK 10 1500 300
两个子查询返回的值分别与主查询中的 sal 和 comm 列比较，
如果员工的工资与 30 部门任意一个员工相同，同时，奖金也与 30 部门的其他员工相同，那么得到了两个员工的信息。
可见，成对比较(使用 where （列，列）)比非成对比较（使用 where 列 and 列) 更为严苛。
资源由 www.eimhe.com  美河学习在线收集分享
8.1.4 关于布尔运算符 not
not 就是否定后面的比较符，基本的形式如下
8.1.5 from 子句中使用子查询(也叫内联视图）
例：员工的工资大于他所在的部门的平均工资的话，显示其信息。
分两步来考虑：
第一步，先看看每个部门的平均工资，再把这个结果集作为一个内联视图。
SQL> select deptno,avg(sal) salavg from emp group by deptno;
DEPTNO SALAVG
---------- ----------
30 1566.66667
20 2175
10 2916.66667
第二步，把这个内联视图起一个别名 b, 然后和 emp 别名 e 做连接，满足条件即可。
SQL>
select e.ename, e.sal, e.deptno, b.salavg
from emp e, (select deptno,avg(sal) salavg from emp group by deptno) b
where e.deptno=b.deptno and e.sal > b.salavg
/
ENAME SAL DEPTNO SALAVG
---------- ---------- ---------- ----------
ALLEN 1600 30 1566.66667
JONES 2975 20 2175
BLAKE 2850 30 1566.66667
SCOTT 3000 20 2175
KING 5000 10 2916.66667
FORD 3000 20 2175
8.1.6 Update 使用非关联查询（考点）
范例：
SCOTT@ prod>create table emp1 as select empno,ename,sal from emp where sal>2500;
SCOTT@ prod>select * from emp1;
EMPNO ENAME SAL
---------- ---------- ----------
7566 JONES 2975
7698 BLAKE 2850
7788 SCOTT 3000
7839 KING 5000
7902 FORD 3000
SCOTT@ prod> UPDATE (SELECT empno,sal FROM emp1) SET sal=10000 WHERE empno in (SELECT empno FROM emp WHERE
sal >=3000 ); 这里 update 后面的 select 子句仅提供可选择更新的列
SCOTT@ prod>select * from emp1;
EMPNO ENAME SAL
---------- ---------- ----------
7566 JONES 2975
7698 BLAKE 2850
7788 SCOTT 10000
7839 KING 10000
7902 FORD 10000
资源由 www.eimhe.com  美河学习在线收集分享
8.1.7 delete 使用非关联查询
8.2 关联子查询
8.2.1 特点：
其子查询（内部，inner)会引用主查询(外部，outer)查询中的一列或多列。在执行时，外部查询的每一行都被一次一行地传递给
子查询，子查询依次读取外部查询传递来的每一值，并将其用到子查询上,直到外部查询所有的行都处理完为止，最后返回查询
结果。
理论上主查询有 n 行，子查询被调用 n 次。
示例1 关联查询用于 select 语句
使用关联查询，显示员工的工资大于他所在部门的平均工资（对比非关联查询的例子）。
SQL> select ename,sal,deptno from emp outer where sal> (select avg(sal) from emp inner where inner.deptno=outer.deptno);
示例2 关联查询中的特殊形式，使用 EXISTS 或 NOT EXISTS
EXISTS 关心的是在子查询里能否找到一个行值（哪怕有 10 行匹配，只要找到一行就行），如果子查询有行值，则立即停止子查
询的搜索，然后返回逻辑标识 TRUE, 如果子查询没有返回行值，则返回逻辑标识 FALSE， 子查询要么返回 T，要么返回 F，以
此决定了主查询的调用行的去留，然后主查询指针指向下一行，继续调用子查询...
①EXISTS 的例子：显示出 emp 表中那些员工不是普通员工（属于大小领导的）。
SQL> select empno,ename,job,deptno from emp outer where exists (select 'X' from emp where mgr=outer.empno);
说明：exists 子查询中 select 后的‘X'只是一个占位，它返回什么值无关紧要，它关心的是子查询中否‘存在’，即子查询的
where 条件能否有‘结果’，一旦子查询查到一条记录满足 where 条件，则立即返回逻辑‘TRUE’，（就不往下查了）。否则
返回‘FALSE’。
②NOT EXISTS 的例子：显示 dept 表中还没有员工的部门。
SQL> select deptno,dname from dept d where not exists (select 'X' from emp where deptno=d.deptno);
DEPTNO DNAME
---------- --------------
40 OPERATIONS
对于关联子查询，在某种特定的条件下，比如子查询是个大表，且连接字段建立了索引，那么使用 exists 比 in 的效率可能更高。
8.2.Update 使用关联查询
范例
1）建立 EMP1 表
SQL> create table emp1 as select e.empno,e.sal,d.loc,d.deptno from emp e,dept d
where e.deptno=d.deptno and e.sal>2000 order by 1;
SQL> update emp1 set loc=null;
SQL> commit;
2）将EMP1 表 LOC 字段清空，并提交，然后再将数据回填，恢复到提交前的状态。
SQL> update emp1 e set e.loc=(select d.loc from dept d where d.deptno=e.deptno);
SQL> commit;
8.3 别名的使用
有表别名和列别名, 表别名用于多表连接或子查询中，列别名用于列的命名规范。
如果别名的字面值有特殊字符，需要使用双引号。如："AB C"
必须使用别名的地方：
1）两表连接后，select 投影中有相同命名的列，必须使用表别名区别标识（自然连接中的公共列则采用相反规则）
SQL>select ename,d.deptno from emp e,dept d where e.deptno=d.deptno;
2）使用 create * {table |view} as select ...语句创建一个新的对象，其字段名要符合对象中字段的规范，不能是表达式或函数等非
规范字符，而使用别名可以解决这个问题。
SQL>create table emp1 as select deptno,avg(sal) salavg from emp group by deptno;
SQL>create or replace view v as select deptno,avg(sal) salavg from emp group by deptno;
或SQL> create or replace view v(deptno,salavg) as select deptno,avg(sal) from emp group by deptno;
3）使用内联视图时，若 where 子句还要引用其 select 中函数的投影, 使用别名可以派上用场。
SQL>select * from (select avg(sal) salavg from emp) where salavg>2000;
4）当以内联视图作为多表连接，主查询投影列在形式上不允许单行字段（或函数）与聚合函数并列，解决这个问题是使在内联
视图中为聚合函数加别名，然后主查询的投影中引用其别名。
5）rownum 列是 Oracle 的伪列，加别名可以使它成为一个表列，这样才可以符合 SQL99 标准中的连接和选择。
资源由 www.eimhe.com  美河学习在线收集分享
SQL> select * from (select ename,rownum rn from emp) where rn>5;
6）不能使用别名的地方：
在一个独立的 select 结构的投影中使用了列别名，不能在其后的 where 或 having 中直接引用该列别名（想想为什么？）。
SQL> select ename,sal salary from emp where salary>2000; 错
SQL> select deptno,avg(sal) salavg from emp group by deptno having salavg>2000; 错
8.4 综合练习
练习一、 找出员工工资最高的那个人的工作地点（非关联查询）
两类思路：1）一网打尽型的 2）顺藤摸瓜型的。
1）SQL>select ename,sal,loc from emp e,dept d where e.deptno=d.deptno and sal=(select max(sal) from emp);
2）SQL>select ename,sal,loc from (select * from emp where sal=(select max(sal) from emp)) a,dept b where a.deptno=b.deptno(+);
3）SQL>select ename,sal,loc from (select * from emp where sal>=all(select sal from emp)) a,dept b where a.deptno=b.deptno;
4）SQL>select ename,sal,loc from (select * from emp e,dept d where e.deptno=d.deptno order by sal desc) where rownum=1;
练习二、 员工的工资大于他所在的部门的平均工资的话，显示其信息。
1）SQL>select e.ename, e.sal, e.deptno, b.salavg
from emp e, (select deptno,avg(sal) salavg from emp group by deptno) b
where e.deptno=b.deptno and e.sal > b.salavg; (非关联查询)
2）SQL> select ename,sal,deptno from emp outer where sal> (select avg(sal) from emp inner where inner.deptno=outer.deptno); （关
联查询）
练习三、
1）显示出 emp 表中哪些员工不是普通员工（属于大小领导的）。
SQL>select ename from emp where empno in (select mgr from emp); (非关联查询)
SQL>select empno,ename,job,deptno from emp outer where exists (select 'X' from emp where mgr=outer.empno); （关联查询）
2）查找出没有下属的员工（属于普通员工）
SQL>select ename from emp where empno not in (select distinct (nvl(mgr,0)) from emp);
SQL>select empno,ename,job,deptno from emp outer where not exists (select 'X' from emp where mgr=outer.empno);
练习四、查找高于所有部门的平均工资的员工（>比子查询中返回的列表中最大的大才行）
SQL> select ename, job, sal from emp where sal > all(select avg(sal) from emp group by deptno);
练习五、要求列出 emp 表第 5-第 10 名员工（按 sal 大--小排序）的信息（结果集的分页查询技术）
关于rownum 伪列使用需要注意两点：
1，使用 rownum 筛选时必须显示或隐示的包含第一行，否则不会返回任何行
2，rownum 是在结果集确定后才编号的。
SQL>select * from (select t1.*,rownum rn from (select * from emp order by sal desc) t1 where rownum<=10) where rn>=5; 高效
SQL>select * from (select t1.*, rownum rn from (select * from emp order by sal desc) t1) where rn between 5 and 10; 低效
练习六、
1）从列出 emp 表中显示员工和经理对应关系表。（自连接）
SQL>select ,a.ename, WORKER,b.ename BOSS from emp a, emp b where a.mgr=b.empno;
2）一个叫 team 的表，里面只有一个字段 name, 一共有 4 条纪录，分别是 a,b,c,d, 对应四个球队，现在四个球队进行比赛，
用一条sql 语句显示所有可能的比赛组合（面试题）
create table team (name char(4));
insert into team values('a');
insert into team values('b');
insert into team values('c');
insert into team values('d');
答案：
select * from team a,team b where a.name<b.name;
练习七、根据一张表修改另一张表 （面试题）
有两个表 A 和 B ，均有 key 和 value 两个字段，如果 B 的 key 在 A 中也有，就把 B 的 value 换为 A 中对应的 value
这道题的 SQL 语句怎么写？（关联查询）
。
资源由 www.eimhe.com  美河学习在线收集分享
准备：
create table emp1 as select * from emp;
update emp1 set empno=empno+1000 where sal>2000;
update emp1 set sal=sal+1000;
commit;
答案：
update emp1 b set sal=(select a.sal from emp a where a.empno=b.empno) where b.empno in (select a.empno from emp a);
练习八、表 dept1 增加一列 person_count,要求根据 emp 表填写 dept1 表的各部门员工合计数。（关联查询）
CTAS方法建立 dept1，将 dept1 增加一列 person_count
create table dept1 as select * from dept;
alter table dept1 add person_count int;
update dept1 d set person_count=(select count(*) from emp e where e.deptno=d.deptno);
select * from dept1;
练习九、消除重复行（面试题）
1）建立 EMP1 表
SQL> create table emp1 as select e.empno,e.sal,d.loc,d.deptno from emp e,dept d
where e.deptno=d.deptno and e.sal>2000 order by 1;
2）EMP1 表插入两条重复记录（比如:选择 7788 和 7902）,并提交，然后再删掉重复记录，恢复到提交状态。
SQL> insert into emp1 select * from emp1 where empno in (7788,7902);
SQL> commit；
SQL> delete emp1 where rowid not in (select min(rowid) from emp1 group by empno,sal,loc,deptno);
SQL> commit;
练习十、分组函数练习（面试题）
环境准备：
create table s1(name char(6),subject char(8),score int);
insert into s1 values('张三','语文',79);
insert into s1 values('张三','数学',75);
insert into s1 values('李四','语文',76);
insert into s1 values('李四','数学',90);
insert into s1 values('王五','语文',90);
insert into s1 values('王五','数学',100);
insert into s1 values('王五','英语',81);
commit;
要求1：查询出每门课都大于 80 分的学生姓名
1 SQL> select name from s1 group by name having min(score)>=80; （利用分组函数）
2 SQL> select distinct name from s1 where name not in (select distinct name from s1 where score<80);（利用 distinct 关键字）
要求2：查出表中哪一门课程的平均分数最高
SQL> select subject from s1 group by subject having avg(score)=(select max(avg(score)) from s1 group by subject);
练习十一、行列转换典型示例 (面试题)
表t1
YEAR MONTH AMOUNT
---------- ---------- -------------------------------------------
1991 1 1.1
1991 2 1.2
1991 3 1.3
1991 4 1.4
1992 1 2.1
1992 2 2.2
1992 3 2.3
1992 4 2.4
表t2
资源由 www.eimhe.com  美河学习在线收集分享
YEAR M1 M2 M3 M4
---------- ---------- ---------- ----------------------------------------------------- ----------
1991 1.1 1.2 1.3 1.4
1992 2.1 2.2 2.3 2.4
行转列，将表 1 转换生成表 2（t1----->t2）
利用decode 函数及分组特性
a）建立原始表 t1
create table t1(year number(4),month number(2),amount number(2,1));
insert into t1 values(1991,1,1.1);
insert into t1 values(1991,2,1.2);
insert into t1 values(1991,3,1.3);
insert into t1 values(1991,4,1.4);
insert into t1 values(1992,1,2.1);
insert into t1 values(1992,2,2.2);
insert into t1 values(1992,3,2.3);
insert into t1 values(1992,4,2.4);
commit;
b) 转换语句
create table t2 as select year,
max(decode(month,1,amount,null)) m1,
max(decode(month,2,amount,null)) m2,
max(decode(month,3,amount,null)) m3,
max(decode(month,4,amount,null)) m4
from t1 group by year;
练习十二，三表连接，显示学生与选学课程的对应关系（面试题）
环境准备：
create table student(sno char(4),name char(6));
create table course(cno char(4),cname char(6));
insert into student values('s001','张三');
insert into student values('s002','李四');
insert into student values('s003','王五');
commit;
insert into course values('c001','数学');
insert into course values('c002','语文');
insert into course values('c003','英语');
commit;
create table student_course (id int,sno char(4),cno char(4));
insert into student_course values(1,'s001','c001');
insert into student_course values(2,'s002','c001');
insert into student_course values(3,'s002','c002');
insert into student_course values(4,'s003','c003');
insert into student_course values(5,'s003','c001');
commit;
SQL> select * from student;
SNO NAME
---- ------
s001 张三
s002 李四
资源由 www.eimhe.com  美河学习在线收集分享
s003 王五
SQL> select * from course;
CNO CNAME
---- ------
c001 数学
c002 语文
c003 英语
SQL> select * from student_course;
ID SNO CNO
---------- ---- ----
1 s001 c001
2 s002 c001
3 s002 c002
4 s003 c003
5 s003 c001
一个学生可能选修多门课程，而一门课程也会有多个学生选修，所以 student 和 course 是多对多关系，这两个表之间没有直接
关系stuent 和 course 的关系由中间表 student_course 给出。
现在要列出每个学生的选修课程，分析一下它的连接过程：
第一步（中间过程）
SQL99 写法：
SQL> select * from student_course sc left join student s on sc.sno=s.sno;
Oracle 写法：
SQL> select * from student_course sc,student s where sc.sno=s.sno(+);
ID SNO CNO SNO NAME
---------- ---- ---- ---- ------
1 s001 c001 s001 张三
3 s002 c002 s002 李四
2 s002 c001 s002 李四
5 s003 c001 s003 王五
4 s003 c003 s003 王五
第二步（中间过程）
SQL99 写法：
SQL> select * from student_course sc left join student s on sc.sno=s.sno left join course c on sc.cno=c.cno;
Oracle 写法：
SQL> select * from student_course sc,student s,course c where sc.sno=s.sno(+) and sc.cno=c.cno(+);
ID SNO CNO SNO NAME CNO CNAME
---------- ---- ---- ---- ------ ---- ------
5 s003 c001 s003 王五 c001 数学
2 s002 c001 s002 李四 c001 数学
1 s001 c001 s001 张三 c001 数学
3 s002 c002 s002 李四 c002 语文
4 s003 c003 s003 王五 c003 英语
第三步（最终结果）
SQL99 写法：
SQL> select s.name,c.cname from student_course sc left join student s on sc.sno=s.sno left join course c on sc.cno=c.cno;
Oracle 写法：
SQL> select s.name,c.cname from student_course sc,student s,course c where sc.sno=s.sno(+) and sc.cno=c.cno(+);
NAME CNAME
------ ------
王五 数学
李四 数学
张三 数学
李四 语文
王五 英语
资源由 www.eimhe.com  美河学习在线收集分享
练习十三 影院票房统计（面试题）
数据表1
create table busdata(ydate date,cid number(3),box number(5),person number(5));
insert into busdata values(to_date('2016-01-01','yyyy-mm-dd'),1,100,10);
insert into busdata values(to_date('2016-01-01','yyyy-mm-dd'),2,110,15);
insert into busdata values(to_date('2016-01-01','yyyy-mm-dd'),3,120,20);
insert into busdata values(to_date('2016-01-02','yyyy-mm-dd'),1,150,25);
insert into busdata values(to_date('2016-01-02','yyyy-mm-dd'),2,160,30);
insert into busdata values(to_date('2016-01-02','yyyy-mm-dd'),3,170,35);
insert into busdata values(to_date('2016-01-03','yyyy-mm-dd'),1,200,40);
insert into busdata values(to_date('2016-01-03','yyyy-mm-dd'),2,210,45);
insert into busdata values(to_date('2016-01-03','yyyy-mm-dd'),3,220,50);
commit;
数据表2
create table cinema(cid number(3),cname varchar2(12));
insert into cinema values(1,'五棵松店');
insert into cinema values(2,'马连道店');
insert into cinema values(3,'慈云寺店');
commit;
数据表3
create table mstak(mdate date,cid number(3),mnum number(5));
insert into mstak values(to_date('2016-01-01','yyyy-mm-dd'),1,500);
insert into mstak values(to_date('2016-01-01','yyyy-mm-dd'),2,600);
commit;
1.查询 2016/1/1 各影城营业数据
结果表头：营业日期、影城名称、票房、人次。
select b.ydate 营业日期，c.cname 影城名称,b.box 票房,b.person 人次
from busdata b,cinema c where b.cid=c.cid
and ydate='2016-01-01 00:00:00';
2.查询 2016/1/1 所有影城总营业数据
结果表头：营业日期、总票房、总人数
SELECT ydate,SUM(box),SUM(person) FROM busdata WHERE ydate='2016-01-01 00:00:00' GROUP BY ydate;
3.查询日期从 2016/1/1 到 2016/1/3 各影城营业数据
结果表头：影城名称、总票房、总人次
SELECT c.cname,t.zpf,t.zrs
FROM cinema c,(SELECT cid,SUM(box) zpf,SUM(person) zrs
FROM busdata
WHERE ydate BETWEEN '2016-01-01 00:00:00' AND '2016-01-03 00:00:00' GROUP BY cid) t
WHERE c.cid=t.cid;
4.查询日期从 2016/1/1 到 2016/1/3 所有影城总营业数据
结果表头：总票房、总人次
SELECT SUM(box) zpf, SUM(person) zrs
FROM busdata
WHERE ydate BETWEEN '2016-01-01 00:00:00' AND '2016-01-03 00:00:00';
5.首先查询 2016/1/1 各影城营业数据，再查询 2016/1/1 至 2016/1/3 各影城营业数据。将二者合并在一个查询结果集中显示
查询结果如下
资源由 www.eimhe.com  美河学习在线收集分享
SELECT a.w,a.x,a.y,a.z,b.aa,b.bb FROM
(SELECT t.ydate w,c.cname x,t.box y,t.person z
FROM cinema c,busdata t
WHERE ydate='2016-01-01 00:00:00' AND c.cid=t.cid) a
JOIN
(SELECT b.cname xx,t.zpf aa,t.zrs bb
FROM cinema b,(SELECT cid,SUM(box) zpf,SUM(person) zrs
FROM busdata
WHERE ydate BETWEEN '2016-01-01 00:00:00' AND '2016-01-03 00:00:00' GROUP BY cid) t
WHERE b.cid=t.cid) b
ON a.x=b.xx;
6.查询 1 月份各影城票房完成情况在本例中则为 2016/1/1 至 2016/1/3，说明：“任务完成率”。“总票房”/“票房月任务”。
要求：显示全部的影城信息，也就说会有三行数据影城名称分别为：“五棵松店”、“马连道店”、“慈云寺点”。
查询结果如下：
SELECT a.x,a.y,a.z,b.mnum,a.y/b.mnum*100||'%' wcl
FROM
(SELECT c.cid w,c.cname x,t.zpf y,t.zrs z
FROM cinema c,(SELECT cid,SUM(box) zpf,SUM(person) zrs
FROM busdata
WHERE ydate BETWEEN '2016-01-01 00:00:00' AND '2016-01-03 00:00:00' GROUP BY cid) t
WHERE c.cid=t.cid) a
LEFT JOIN
(select cid,mnum from MSTAK) b
ON a.w=b.cid;


第二部分、管理用户及对象
第九章、用户访问控制
9.1 认识 Oracle 用户
Oracle 数据库是多用户系统，每个用户一个账户。
9.1.1 查看数据库里有多少用户？
SQL>select username from dba_users;


9.1.2 用户默认的存储空间
每个用户账户都可以指定默认的表空间，用户创建的任何对象（如表或索引）将缺省保存在此表空间中，如果创建用户时没有
指定默认表空间，那么该用户缺省使用数据库级的默认表空间。

9.1.3 数据库默认表空间
SQL> select * from database_properties where rownum<=10;

设置数据库的默认表空间
SQL> alter database default tablespace TABLESPACENAME;

9.2 密码认证介绍

用户登录时需要密码认证，认证主要有几种方法
1）OS 认证 用于 sys 用户本地登录
2）数据字典口令认证 用户普通用户登录
3）口令文件认证 用于 sys 用户远程登录
以上三种用户认证是最常用的。
另外还有一些认证方式，考试会提及，比如：
资源由 www.eimhe.com  美河学习在线收集分享
4）外部密码认证
如果配置了 os_authent_prefix 参数，如缺省值为'ops$'，当数据库中存在用户'ops$tim'，且对该用户启用了外部验证。那么在操
作系统上以 tim 用户登录成功后，就可以直接键入 sqlplus / 登录用户是 ops$tim，密码由操作系统外部提供，不是数据字典认证。
示例：
1)用户前缀缺省是 OPS$
sqlplus / as sysdba
SQL> show parameter os_authent_prefix
NAME TYPE VALUE
------------------------------------ ----------- ------------------------------
os_authent_prefix string ops$
2) 建立 Oracle 的用户，密码是操作系统提供（外部）
SQL> create user ops$tim identified externally;
SQL> grant connect to ops$tim;
SQL> select USERNAME,PASSWORD from dba_users where username='OPS$TIM';
USERNAME PASSWORD
------------------------------ ------------------------------
OPS$TIM EXTERNAL
3) 建立操作系统用户
[root@cuug ~]# useradd tim
4）设置用户环境变量
[root@cuug ~]#su - tim
[tim@cuug ~]$ vi .bash_profile (添加环境变量)
ORACLE_BASE=/u01
ORACLE_HOME=$ORACLE_BASE/oracle
ORACLE_SID=prod
PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH
[tim@cuug ~]$ source .bash_profile
5）以操作系统身份登录
[tim@cuug ~]$ id
uid=501(tim) gid=502(tim) groups=502(tim)
[tim@cuug ~]$ sqlplus /
SQL*Plus: Release 11.2.0.1.0 Production on Sat Jul 2 22:25:12 2016
Copyright (c) 1982, 2009, Oracle. All rights reserved.
......
SQL> show user;
USER is "OPS$TIM"
SQL>
9.3 空间配额的概念
资源由 www.eimhe.com  美河学习在线收集分享
配额（quota)是表空间中为用户的对象使用的空间量，dba 建立用户时就应该考虑限制用户的磁盘空间配额，否则无限制配额的
用户可能把你的表空间撑爆（甚至损坏 system 表空间）。
创建用户时，可以指定用户的缺省表空间及其配额，然后才可以建表。
单一的用户不需要临时表空间和 UNOD 表空间的配额
更改用户配额的一些命令：
ALTER USER tim QUOTA 10m ON test_tbs; 给 tim 用户在 test_tbs 上使用了 10m 空间的配额
ALTER USER tim QUOTA unlimited on test_tbs --不受限制
ALTER USER tim QUOTA 0 ON test_tbs; 收回剩余配额
9.4 概要文件的概念
9.4.1 作用：对用户访问数据库做一些限制。
1）概要文件（profile)具有两个功能，一个是 KERNEL 资源（如 CPU 资源）限制，另一个是 PASSWORD 资源（如登录）限制。
2）始终要实施口令控制，而对于 KERNEL 资源限制，则只有实例参数 RESOURE_LIMIT 为 TRUE 时（默认是 FALSE)才会实施。
3）系统自动使用概要文件，有一个默认的 default profile,限制很宽松，作用较小。
4）可以使用 create profile 为用户创建它自己的概要文件，没有指定值的参数，其值就从 default profile 的当前版本中提取。
9.4.2 概要文件示例
创建一个概要文件，对 tim 用户施加两个限制
1）如出现两次口令失误，将账户锁定。
2）tim 用户最多同时以两个 session 登录
步骤一、创建概要文件并命名 two_error
SQL> create profile two_error limit failed_login_attempts 2;
SQL> alter profile two_error limit Sessions_per_user 2; dba_profiles 视图可以列出所有 profile 资源;
SQL> select * from dba_profiles where PROFILE='TWO_ERROR';
步骤二、将概要文件分配给 tim 用户
SQL> alter user tim profile two_error;
步骤三、tim 用户尝试两次登录使用错误密码
SQL> conn tim/fdfd
ERROR: ORA-28000: 帐户已被锁定
步骤四、sys 为 tim 解锁
SQL> alter user tim account unlock;
步骤五、resource_limit=true 才可以使得 KERNEL 资源限制对 profile 起作用(考点)
SQL> alter system set resource_limit=true;
步骤六、测试 tim 只能同时有两个 session 登录
步骤七、sys 删掉了 two_error 概要文件
SQL> drop profile two_error cascade;
删除two_error 后 tim 用户又绑定到 default profile 上。
9.5 权限和角色
9.5.1数据库的安全问题
1）系统安全：
用户名、口令、概要文件、磁盘配额等
2）数据库安全：
对数据库系统和数据库对象的访问及操作
用户具备系统权限才能够访问数据库
具备对象权限才能访问数据库中的对象
9.5.2 系统权限
针对于database 的相关权限，通常由 DBA 授予（11g 已有 200 多种）
典型的DBA 权限：
CREATE USER
DROP USER
SELECT ANY TABLE
CREATE ANY TABLE
典型的一般用户的系统权限：
CREATE SESSION
CREATE TABLE
CREATE VIEW
CREATE PROCEDURE
9.5.3 角色
资源由 www.eimhe.com  美河学习在线收集分享
1）为什么会有角色
系统权限太过繁杂，Oracle 建议将系统权限打包成角色，通过角色授权权限，目的就是为了简化用户访问管理
Oracle 有一些预定义角色，如：connect、resource、dba 角色等
也可以创建和删除自定义角色
SQL> CREATE role myrole;
SQL> DROP role myrole;
2）授予和回收权限的语法
1、授予系统权限和角色的语法
GRANT sys_privs,[role] TO user|role|PUBLIC [WITH ADMIN OPTION]
2、回收系统权限和角色的语法
Revoke sys_prvs[role] FROM user|role|PUBLIC
3）使用预定义角色的考虑
connect 和 resource 两个角色，可以满足一般用户大多数需求
SQL> grant connect, resource to tim;
SQL> revoke unlimited tablespace from tim;
SQL> alter user tim quota 10m on test_tbs;
查看用户表空间配额：
SQL> select tablespace_name,username,max_bytes from DBA_TS_QUOTAS where username='TIM';
当unlimited tablespace 和 quota 共存时，以 unlimited 为准。
关于权限与空间配额的考虑
用户有空间配额才能建表。
空间配额不是权限的概念，而是用户属性的概念。
作为DBA，在生产系统上一定要为普通用户分配空间配额，限制使用存储空间。
有两种办法分配空间配额：
第一种：在建立用户时指定空间配额，这个方法只能分配用户缺省的表空间上的配额，不是很灵活。
第二种：授予 resource 角色，包含有 unlimited tablespace 权限此权限对所有表空间不设限，包括系统表空间，请立即收回该权
限，然后再分配空间配额。
系统权限
sys, system 拥有普通用户的所有对象权限，并有代理授权资格。
系统权限里的 any 含义：
SQL> conn / as sysdba;
SQL> grant create any table to tim;
tim 可以为 SCOTT 建表，这张表是属于 SCOTT 用户下的一个对象。
SQL> conn tim/tim
SQL> create table scott.t100 (id int);
9.5.4 对象权限
资源由 www.eimhe.com  美河学习在线收集分享
1、授予对象权限的语法
GRANT object_privs ON object TO user|role|PUBLIC [WITH GRANT OPTION]
2、回收对象权限的语法
REVOKE object_prvs ON object FROM user|role|PUBLIC
角色授权的示例
9.5.5、授权注意事项
1）系统权限和对象权限语法格式不同，不能混合使用
SQL>grant create table,select on emp to tim 错
2）系统权限和角色语法相同可以并列授权
SQL>grant connect,create table to tim;
3、可以使 update 对象权限精确到列
SQL> grant select, update(sal) on scott.emp to tim;
4）可以一条语句并列授予多个用户
SQL>grant connect to tim,ran;
5）可以通过授权建立用户,如 ran 用户不存在
SQL>grant connect,resource to ran identified by ran;
9.5.6 权限的传递与回收
系统权限的级联授予 WITH ADMIN OPTION
对象权限的级联授予 WITH GRANT OPTION
系统权限和对象权限的级联收回
sys 能分别从 scott 和 tim 收回系统权限，但仅从 scott 收回系统权限时并不能级联收回 tim 系统的权限。
scott只能从 tim 收回对象权限，但同时会级联收回 ran 的对象权限。
9.5.7 对象权限在存储过程中的使用
存储过程 proc1 中包含了一些 tim 没有权限的 DML 操作，scott 将 proc1 的 execute 权限赋给 tim，，那么 tim 能成功地执行存储
过程proc1 吗？这个问题涉及到了 create procedure 时 invoker_rights_clause 的两个选项：
1、AUTHID CURRENT_USER
当执行存储过程时，检查用户 DML 操作的对象权限。
2、AUTHID DEFINER（默认）
当执行存储过程时，不检查用户 DML 操作的对象权限。
测试：默认情况下 AUTHID DEFINER
第一步
资源由 www.eimhe.com  美河学习在线收集分享
SQL> create table scott.a (d1 date);
SQL> grant connect,resource to tim identified by tim;
SQL> conn scott/scott
第二步
create or replace procedure proc1 as
begin
insert into scott.a values(sysdate);
commit;
end;
第三步
SQL> grant execute on proc1 to tim;
第四步
SQL> conn tim/tim
SQL> exec scott.proc1;
测试AUTHID CURRENT_USER 选项
第一步
SQL>conn scott/scott
SQL>create or replace procedure proc1
AUTHID CURRENT_USER as
begin
insert into scott.a values(sysdate);
commit;
end;
第二步，结果报错!
SQL> conn tim/tim
SQL> exec scott.proc1;
第三步，让 scott 在 execute 权限和 insert 权限都具备的情况下再执行上次操作
SQL> grant all on a to tim;
第四步，重复第二步，结果 OK!
9.5.8 有关权限的常用视图
1）用户查看自己当前拥有的系统权限（包括角色中的系统权限）
SESSION_PRIVS （常用）
2）使用数据字典查看权限的一般规律
dba_xxx_privs sys 用户查询用（常用）
all_xxx_privs
user_xxx_privs 普通用户查询用（常用）
3）使用数据字典查看角色的一般规律 普通用户查询用
role_xxx_privs
role_xxx_privs
role_xxx_privs
其中xxx：role 表示角色，sys 表示系统权限，tab 表示对象权限
9.6 相关视图示例：
从哪个角度看，非常重要！三个用户，分别是 sys、scott 和 tim
第一步 sys 用户操作
1）建立 myrole 角色，把 connect 角色和 create table 系统权限以及 update on scott.emp 对象权限放进 myrole。
2）把 myrole 角色授给 tim。
3）把 create table 系统权限授给 tim。
第二步scott 用户操作
把 select on emp 表的对象权限授给 tim
从dba角度看权限：
select * from dba_sys_privs where grantee='TIM'; 看用户 tim 所拥有的系统权限
select * from dba_tab_privs where grantee='TIM'; 看用户 tim 所拥有的对象权限
select * from dba_role_privs where grantee='TIM'; 看用户 tim 所拥有的角色
select * from dba_role_privs where grantee='MYROLE'; 看用 MYROLE 角色包含的角色
select * from dba_sys_privs where grantee='MYROLE'; 查看 MYROLE 角色里包含的系统权限
select * from dba_tab_privs where grantee='MYROLE'; 查看 MYROLE 角色里包含的对象权限
从tim用户角度看权限：
资源由 www.eimhe.com  美河学习在线收集分享
select * from user_role_privs; 查看和自己有关的角色（不含角色中含有的角色）
select * from user_sys_privs; 查看和自己有关的系统权限（不含角色中的系统权限）
select * from user_tab_privs; 查看和自己有关的对象权限（不含角色中的对象权限）
select * from role_role_privs; 角色里包含的角色
select * from role_sys_privs; 角色里包括的系统权限
select * from role_tab_privs; 角色里包括的对象权限
select * from session_privs; 查看和自己有关的系统权限(包括角色里的权限）

从scott 角度看权限
select * from all_tab_privs where grantee='TIM';
select * from all_tab_privs where table_name='EMP';

第十章、事务和锁
10.1 事务具备的四个属性（简称 ACID 属性） ：
1）原子性（Atomicity）：事务是一个完整的操作。事务的各步操作是不可分的（如原子不可分）；各步操作要么都执行了，要
么都不执行。
2）一致性（Consistency）：事务执行的结果必须使数据库从一个一致的状态到另一个一致的状态。。
3）隔离性（Isolation）：事务的执行不干扰其他事务。一般来说数据库的隔离性都提供了不同程度的隔离级别。
4）持久性（Durability）：事务一旦提交完成后，数据库就不可以丢失这个事务的结果，数据库通过日志能够保持事务的持久性。


10.2 事务的开始和结束
10.2.1 事务采用隐性的方式，
1）起始于 session 的第一条 DML 语句
2）一个 session 某个时刻只能有一个事务
10.2.2 事务结束的方式：
1）TCL 语句被执行，COMMIT（提交）或 ROLLBACK（回滚）
2）DDL 语句被执行（提交）
3）DCL 语句被执行（提交）
4）用户退出 SQLPLUS（正常退出是提交，非正常退出是回滚）
5）服务器故障或系统崩溃（回滚）
6）shutdowm immediate(回滚）
在一个事务里如果某个 DML 语句失败，之前其他任何 DML 语句将保持完好，且不会提交！

10.3 Oracle 的事务保存点功能
savepoint 命令允许在事务进行中设置一个标记（保存点），回滚到这个标记可以保留该点之前的事务存在，并使事务继续执行。
实验:
savepoint sp1;
delete from emp1 where empno=7900;
savepoint sp2;
update emp1 set ename='timran' where empno=7788;
select * from emp1；
rollback to sp2;
select * from emp1；
资源由 www.eimhe.com  美河学习在线收集分享
rollback to sp1;
注意rollback to XXX 后，左侧的事务不会结束。
10.4 SCN 的概念
10.4.1 概念：
SCN 全称是 System Change Number，它是一个不断增长的整数，相当于 Oracle 内部的一个时钟，只要数据库一有变更，这个 SCN
就会增加，Oracle 通过 SCN 记录数据库里事务的一致性。SCN 涉及了实例恢复和介质恢复的核心概念，它几乎无处不在：控制
文件，数据文件，日志文件都有 SCN，包括 block 上也有 SCN。
10.4.2 理解一致性读
实际上，我们所说的保证同一时间点一致性读的概念，其背后是物理层面的 block 读，Oracle 会依据你发出 select 命令，记录下
那一刻的 SCN 值，然后以这个 SCN 值去同所读的每个 block 上的 SCN 比较，如果读到的块上的 SCN 大于 select 发出时记录的 SCN，
则需要利用 Undo 得到该 block 的前镜像，在内存中构造 CR 块(Consistent Read)。
10.4.3 获得当前 SCN 的两个办法：
SQL> select current_scn from v$database;
SQL> select dbms_flashback.get_system_change_number from dual;
有两个函数可以实现 SCN 和 TIMESTAMP 之间的互转
scn_to_timestamp
timestamp_to_scn
SQL> select scn_to_timestamp(current_scn) from v$database;
10.5 共享锁与排他锁的基本原理：
10.5.1 基本原则
排他锁，排斥其他的排他锁和共享锁。
共享锁，排斥其他的排他锁，但不排斥其他的共享锁。
10.5.2 Oracle 锁的种类
因为有事务才有锁的概念。Oracle 数据库锁可以分为以下几大类：
DML 锁（data locks，数据锁），用于保护数据的完整性。
DDL 锁（dictionary locks，数据字典锁），用于保护数据库对象的结构，如表、索引等的结构定义。
SYSTEM 锁（internal locks and latches），保护数据库的内部结构。
我们探讨的是 Oracle 的 DML 操作（insert、update、delete），它包括两种锁：TX（行锁）和 TM（表锁）。
TX 是面向事务的行锁，它表示你锁定了表中的一行或若干行。update 和 delete 操作都会产生行锁，insert 操作除外。
TM 是面向对象的表锁，它表示你锁定了系统中的一个对象，在锁定期间不允许其他人对这个对象做 DDL 操作。目的就是为了
实施DDL 保护。（理解一下参数 ddl_lock_timeout）
比如一个 update 语句，有表级锁（即 TM)和行锁（即 TX 锁）。Oracle 是先申请表级锁 TM（其中的 RX 锁）, 获得后系统再自动
申请行锁(TX)。并将实际锁定的数据行的锁标志置位。
对于DML 操作
行锁(TX)只有一种
表锁(TM)共有五种，分别是 RS,RX,S,SRX,X。
资源由 www.eimhe.com  美河学习在线收集分享
10.6 五种 TM 表锁的含义：
1）ROW SHARE 行共享(RS)，
允许其他用户同时更新其他行，允许其他用户同时加共享锁，不允许有独占（排他性质）的锁
2）ROW EXCLUSIVE 行排他(RX)，允许其他用户同时更新其他行，只允许其他用户同时加行共享锁或者行排他锁
3）SHARE 共享(S)，不允许其他用户同时更新任何行，只允许其他用户同时加共享锁或者行共享锁
4）SHARE ROW EXCLUSIVE(SRX) 共享行排他，不允许其他用户同时更新其他行，只允许其他用户同时加行共享锁
5）EXCLUSIVE (X)排他，其他用户禁止更新任何行，禁止其他用户同时加任何排他锁。
10.7 加锁模式
第一种方式：自动加锁
做DML 操作时，如 insert，update，delete，以及 select....for update 由 oracle 自动完成加锁
Session1/scott:
SQL> select * from dept1 where deptno=30 for update; 用 for update 加锁
Session2/sys:
SQL>select * from scott.dept1 for update; 不试探，被锁住
SSession2/sys:
SQL>select * from scott.dept1 for update nowait; 试探，以防被锁住
SQL>select * from scott.dept1 for update wait 5;
SQL> select * from scott.dept1 for update skip locked; 跳过加锁的记录，锁定其他记录
1）对整个表 for update 是不锁 insert 语句的。
2）wait 5：等 5 秒自动退出。nowait：不等待。skip locked：跳过。都可起到防止自己被挂起的作用。
语法：lock table 表名 in exclusive mode.（一般限于后三种表锁）
10.8 死锁和解锁
Oracle 自动侦测死锁，自动解决锁争用。
制作死锁案例：
session1
update scott.emp1 set sal=8000 where empno=7369;
session2
update scott.emp1 set sal=9000 where empno=7934;
session1
update scott.emp1 set sal=8000 where empno=7934;
session2
update scott.emp1 set sal=9000 where empno=7369;
报错：ORA-00060: 等待资源时检测到死锁
10.9 管理员如何解鎖
可以根据以下方法准确定位要 kill session 的 sid 号和 serial#号，
SQL> select * from v$lock where type in ('TX','TM');
SQL> select a.sid,a.serial#,b.sql_text from v$session a,v$sql b where a.prev_sql_id=b.sql_id and a.sid=127;
SID SERIAL# SQL_TEXT
---------- ---------- --------------------------------------------------------------------------------
资源由 www.eimhe.com  美河学习在线收集分享
127 2449 update emp1 set sal=8000 where empno=7788
SQL> select sid,serial#,blocking_session,username,event from v$session where blocking_session_status='VALID';
SID SERIAL# BLOCKING_SESSION USERNAME EVENT
---------- ---------- ---------------- ------------------------------ ----------------------------------------
127 2449 134 SCOTT enq: TX - row lock contention
也可以根据 v$lock 视图的 block 和 request 确定 session 阻塞关系,确定无误后再杀掉这个 session
SQL>ALTER SYSTEM KILL SESSION '127,2449';
更详细的信息，可以从多个视图得出，相关的视图有：v$session,v$process,v$sql,v$locked,v$sqlarea 等等
阻塞(排队）从 EM 里看的更清楚 EM-->Performance-->Additional Monitoring Links-->Blocking Sessions(或 Instance Locks)
第十一章、索引
11.1 索引结构及特点
两大类：B 树索引，2）位图索引
11.1.1 B 树索引结构
根节点，分支节点，叶子节点，以及表行，rowid，键值，双向链等概念。
1）叶块之间使用双向链连接，
2）删除表行时索引叶块也会更新，但只是逻辑更改，并不做物理的删除叶块。
3）索引叶块中不保存表行键值的 null 信息。
11.1.2 位图索引结构
位图索引适用于离散度较低的列，它的叶块中存放 key, start rowid-end rowid,并应用一个函数把位图中相应 key 值置 1。
建立位图索引：
SQL>create bitmap index job_bitmap on emp1(job);
资源由 www.eimhe.com  美河学习在线收集分享
11.1.3 查看约束的两个数据字典视图
select * from user_indexes;
select * user_ind_columns;
11.2 B 树索引和位图索引的适用环境
1）索引是与表相关的一个可选结构，在逻辑上和物理上都独立于表的数据，索引能优化查询，不能优化 DML 操作
2）由于是 Oracle 自动维护索引，所以频繁的 DML 操作反而会引起大量索引维护的开销。3）如果 SQL 语句仅访问被索引的列，
那么数据库只需从索引中读取数据，而不用读取表，如果该语句同时还要访问除索引列之外的列，那么数据库会使用 rowid 来
查找表中的行。
Scott 用户使用 autotrace 工具
SQL>conn / as sysdba
SQL>@$ORACLE_HOME/sqlplus/admin/plustrce.sql
SQL> grant plustrace to scott;
SQL> conn scott/scott
SQL> set autotrace on;
11.3 几种常用的 B 树索引创建方法：
1）唯一索引，指键值不重复。
SQL> create unique index empno_idx on emp1(empno);
2）非唯一索引（Unique or non_unique):
SQL> create index empno_idx on emp1(empno);
3）组合索引(Composite)：绑定了两个或更多列的索引。
SQL> create index job_deptno_idx on emp1(job,deptno);
4）反向键索引(Reverse)：将字节倒置后组织键值。当使用序列产生主键索引时，可以防止叶节点出现热块现象（考点）。缺点
是无法提供索引范围扫描。
SQL> create index mgr_idx on emp1(mgr) reverse;
5）函数索引(Function base)：以索引列值的函数值为键值去组织索引
SQL> create index fun_idx on emp1(lower(ename));
6）压缩（Compress)：重复键值只存储一次，就是说重复的键值在叶块中就存一次，后跟所有与之匹配的 rowid 字符串。
SQL> create index comp_idx on emp1(sal) compress;
7）升序或降序（Ascending or descending)：叶节点中的键值排列默认是升序的。
SQL> create index deptno_job_idx on emp1(deptno desc, job asc);
11.4 索引的优化
11.4.1 查询优化器使用索引
1）索引唯一扫描(index unique scan)
通过唯一索引查找一个数值返回单个 ROWID。对于唯一组合索引，要在 where 的谓词“=”后包含所有列的“布尔与”。
2）索引范围扫描(index range scan)
在非唯一索引上，可能返回多行数据，所以在非唯一索引上都使用索引范围扫描。
使用index rang scan 的 3 种情况：
(在唯一索引列上使用了 range 操作符(> < <> >= <= between)
在唯一组合索引上，对组合索引使用部分列进行查询(含引导列），导致查询出多行
对非唯一索引列上进行的任何查询。不含‘布尔或’
3）索引全扫描(index full scan)
对整个index 进行扫描，并且顺序的读取其中数据。
CBO 根据统计数值得知进行全 Oracle 索引扫描比进行全表扫描更有效时，才进行全 Oracle 索引扫描，
4）索引快速扫描(index fast full scan)
扫描索引中的所有的数据块，fast full scan 在读取叶子块时的顺序完全由物理存储位置决定，并采取多块读，每次读取
资源由 www.eimhe.com  美河学习在线收集分享
DB_FILE_MULTIBLOCK_READ_COUNT 个块。
CBO 能够索引全扫描和快速扫描的前提是：所要的数据必须能从索引中可以直接得到，因此不再需要查询基表。
11.5 索引的碎片问题
对基表做 DML 操作，便导致对索引表块的自动更改操作，尤其是基表的 delete 操作会引起 index 表的 index entries 的逻辑删除。
注意：只有当一个索引块中的全部 index entry 都被删除了，这个块才会被收回。
如果update 基表索引列，则索引块会发生 entry delete，再 entry insert，这都些动作都可能产生索引碎片
测试：
第一步，搭建环境
SQL> create table t (id int);
SQL> create index ind_1 on t(id);
SQL>
begin
for i in 1..1000000 loop
insert into t values (i);
if mod(i, 100)=0 then
commit;
end if;
end loop;
end;
/
第二步，收集统计信息，并查看视图
SQL> analyze index ind_1 validate structure;
SQL> select name,HEIGHT,PCT_USED,DEL_LF_ROWS/LF_ROWS from index_stats;
第三步，基表高强度更新，造成索引碎块
SQL> delete t where rownum<700000;
第四步，重复第二步，查看视图
11.6 重建索引
查询索引的两个动态视图
DBA_INDEXES
DBA_IND_COLUMNS
在Oracle 文档里并没有清晰的给出索引碎片的量化标准。
Oracle 建议通过 Segment Advisor(段顾问）解决表和索引的碎片问题，如果你想自行解决，可以通过查看 index_stats 视图，当以
下三种情形之一发生时，说明积累的碎片应该整理了。
1.HEIGHT >=4
2 PCT_USED< 50% (相对值）
3 DEL_LF_ROWS/LF_ROWS>0.2
SQL> alter index ind_1 rebuild online;
11.7 索引不可用（unusable）和不可见（invisible ）
1）仅仅保存索引定义，不删除索引，也不更新索引。
SQL> alter index ind_1 unusable;
索引被设定为 unusable 后，如再次使用需要做 rebuild。
SQL> alter index ind_1 rebuild;
2）在 11g 里，Oracle 提供了一个新特性(Index Invisible)来降低直接删除索引或禁用索引的风险。我们可以在创建索引时指定
invisible 属性或者用 alter 语句来修改索引为 invisible(visible)
SQL> alter index ind_1 invisible;
SQL> select index_name,status,VISIBILITY from user_indexes;
索引不可见其实是对优化器来说不可见，索引维护还是正常进行的。
第十二章、约束
12.1 什么是约束
1）约束的作用：
约束是数据库能够实施业务规则以及保证数据遵循实体--关系模型的一种手段。如果违反约束，将自动回滚出现问题的整个语句，
而不是语句中的单个操作，也不是整个事务。
2）约束的语法：
资源由 www.eimhe.com  美河学习在线收集分享
列级定义：只能引用一个列，表中可以有多个列级约束。
表级定义：引用一个或多个列，通常用来定义主键。
追加定义：建表后，再通过 alter table 命令追加的约束。
查看约束的两个数据字典视图
select * from user_constraints;
select * user_cons_columns;
12.2 五种约束的建立
12.2.1 非空约束
列级定义：
create table t1 (id number(2) not null, name varchar2(4))
追加非空约束：
如：alter table t1 modify ename not null;
或（alter table t1 modify ename constraint aaa not null）;
非空约束没有表级定义
12.2.2 唯一性约束
1）unique 不包括空值的唯一性
2）单列可设 unique+not null 约束，约束之间没有“，”
create table a (id int unique not null, name char(10));
3）单表中 unique 约束没有数量限制。
4）unique 约束的列上有索引。
列级定义
create table t1(id number(2) unique,name varchar2(4));
表级定义
create table t2(id number(2),name varchar2(4),constraint id_uk unique(id));
追加定义
alter table t2 add CONSTRAINT id_uk UNIQUE (id);
12.2.3 主键约束
主键约束语法上与唯一约束类似
1）每个表只能建立一个主键约束，primary key=unique key + not null，主键约束可以是一列，也可以是组合多列。
2）主键列上需要索引，如果该列没有索引会自动建立一个 unique index, 如果该列上已有索引（非唯一也可以），那么就借用
这个索引，由于是借用的索引，当主键约束被删除后借用的索引不会被删除。同理，多列组合的主键，需要建立多列组合索引，
而多列主键的单列上还可以另建单列索引。
3）主键约束和唯一约束不能同时建立在一个列上。
4）主机约束和外键约束可以在同一列上。（典型的例子是一个表上的两列是组合主键，但这两列的每列都是其他表的外键）
关于主键和索引关联的问题:（这个地方考点较多)
SQL>
create table t (id int, name char(10));
insert into t values (1, 'sohu');
insert into t values (2, 'sina');
commit;
SQL> create index t_idx on t(id);
下面这两句话是一样的效果，因为缺省情况下 id 列已经有索引 t_id 了，建主键时就会自动用这个索引（考点）。
SQL> alter table t add constraint pk_id primary key (id);
SQL> alter table t add constraint pk_id primary key (id) using index t_idx;
SQL> select CONSTRAINT_NAME,TABLE_NAME,INDEX_NAME from user_constraints;
SQL> alter table t drop constraint pk_id; 删除了约束，索引还在，本来就是借用的索引。
SQL> select index_name from user_indexes;
INDEX_NAME
------------------------------
PK_EMP
PK_DEPT
T_IDX
SQL> drop table t purge; t_idx 是和 t 表关联的，关键字 purge 使表和索引一并永久删除了。
也可以使用 using 子句在建表、建约束、建索引一条龙下来，当然 primary key 也会自动使用这个索引(考点）。删除该约束，索
引还存在。
SQL> create table t (id int,name char(10),constraint pk_id primary key(id) using index (create index t_idx on t(id)));
资源由 www.eimhe.com  美河学习在线收集分享
12.2.4.外键约束
作用：引用主键构成完整性约束
1）外键约束和 unique 约束都可以有空值。
2）外键需要参考主键约束，但也可以参考唯一键约束。
3）外键和主键一般分别在两个表中，但也可以同处在一个表中。
SQL> create table emp1 as select * from emp;
SQL> create table dept1 as select * from dept;
SQL> alter table dept1 add constraint pk_dept1 primary key(deptno);
SQL> ALTER TABLE emp1 ADD CONSTRAINT fk_emp1 FOREIGN KEY(deptno) REFERENCES dept1(deptno);
主外键构成完成性约束，有两个要点：
1）插入或更新有外键的记录时，必须参照主键，（子要依赖父）。
2）有外键表时，主键表的记录不能做 DML 删除，（父不能舍子），
如果一定要删除, 需要在建立外键时加 on delete cascade 子句或 on delete set null 子句
测试ON DELETE CASCADE 子句
报错：ORA-02292: integrity constraint (SCOTT.E_FK) violated - child record found
删除外键约束，使用 ON DELETE CASCADE 关键字重建外键,
SQL>alter table emp1 drop constraint fk_emp1;
SQL>ALTER TABLE emp1 ADD CONSTRAINT fk_emp1 FOREIGN KEY(deptno) REFERENCES dept1(deptno) ON DELETE CASCADE;
视图delete_rule 列会显示 CASCADE,否则显示 NO ACTION(考点)
SQL>select constraint_name,constraint_type,status,delete_rule from user_constraints;
测试：
SQL>delete from dept1 where deptno=30
再查看emp1 表的 deptno 已经没有 30 号部门了，如果再对 dept1 的操作进行 rollback，emp1 的子记录也随之 rollback
ON DELETE CASCADE 要慎用，父表中删除一行数据就可能引发子表中大量数据丢失。
为此，还有 on delete set null 子句，顾名思义是子表不会删除（丢失）记录，而是将外键的值填充 null。
如果disable dept1 主键约束并使用级联 cascade 关键字，则 emp1 的外键也会 disable, 若再次 enable dept1 主键，则 emp1 外键
仍然保持 disable.
SQL> alter table dept1 disable constraints pk_dept1 cascade;
SQL> alter table dept1 enable constraints pk_dept1;
SQL>select constraint_name,constraint_type,status,delete_rule from user_constraints;
SQL> drop table dept1 purge;
报错：ORA-02449: 表中的唯一/主键被外键引用
SQL> drop table dept1 cascade constraint purge;
注意：这时外键约束也被删除了（考点）
12.2.5.CHECK 约束
1、作用：CHECK 约束是检查一个表达式，表达式的逻辑结果为”F“时，违反约束则语句失败。
表达式使用”( )“扩起来
涉及多列的表达式，只能使用表级定义描述。
2、语法:
列级定义
SQL> create table emp1 (empno int,sal int check (sal>500),comm int);
表级定义
SQL> create table emp2 (empno int,sal int,comm int,check(sal>500));
追加定义
SQL> alter table emp2 add constraint e_no_ck check (empno is not null);
验证
SQL> insert into emp2 values(null,1,1);
报错：ORA-02290: 违反检查约束条件 (SCOTT.E_NO_CK)
3、check 约束中的特殊情况
1）check 约束中的表达式中不能使用变量日期函数（考点）
SQL> alter table emp1 add constraint chk check(hiredate<sysdate);
报错：ORA-02436: 日期或系统变量在 CHECK 约束条件中指定错误
SQL> alter table emp1 add constraint chk check(hiredate<to_date('2000-01-01','yyyy-mm-dd')); 这句是可以的
2）级联约束
CREATE TABLE test2 (
pk NUMBER PRIMARY KEY,
fk NUMBER,
col1 NUMBER,
资源由 www.eimhe.com  美河学习在线收集分享
col2 NUMBER,
CONSTRAINT fk_constraint FOREIGN KEY (fk) REFERENCES test2,
CONSTRAINT ck1 CHECK (pk > 0 and col1 > 0),
CONSTRAINT ck2 CHECK (col2 > 0)
)
/
当删除列时, 看看会发生什么?
SQL> ALTER TABLE test2 DROP (col1); 这句不能执行，在 constraint ck1 中使用了该列
如果一定要删除级联约束的列，带上 cascade constraints 才行
SQL> ALTER TABLE test2 DROP (col1) cascade constraints;
3）check 中可以使用 in 表达式，如(check deptno in(10,20))
12.3 约束的四种状态
enable validate :无法插入违反约束的行，而且表中所有行都要符合约束
enable novalidate :表中可以存在不合约束的状态，,但对新加入数据必须符合约束条件.
disable novalidate :可以输入任何数据，表中或已存在不符合约束条件的数据.
disable validate :不能对表进行插入/更新/删除等操作,相当于对整个表的 read only 设定.
（如是主键，会删除索引，当 enable 后，又建立了索引）
更改约束状态是一个数据字典更新，将对所有 session 有效。
1）测试 enable novalidate 这种组态的用法
常用于当在表中输入了一些测试数据后﹐而上线后并不想去清除这些违规数据﹐但想从此开始才执行约束。
假设已经建立了一个 emp1 表，也插入了数据，如果有一天想在 empno 上加入 primary key 但是之前有不符合（not null+unique)
约束的，怎样才能既往不咎呢？
SQL>create table emp1 as select * from emp; 没有约束考过来
SQL>update emp1 set empno=7788 where empno=7369; 设置一个重值
SQL>alter table emp1 add constraint pk_emp1 primary key (empno); 因要检查主键唯一性，拒绝建立此约束。
alter table emp1 add constraint pk_emp1 primary key (empno) enable novalidate; 这句话也不行，原因是唯一索引在捣乱
SQL>create index empno_index on emp1(empno); 建一个普通索引不受 unquie 的限制
SQL>alter table emp1 add constraint pk_emp1 primary key (empno) enable novalidate;。
从此之后，这个列的 DML 操作还是要符合主键约束（not null+unique)。
2）将 disable novalidate，enable novalidate 和 enable validate 三种状态组合起来的用法：
这种组合，可以避免因有个别不符合条件的数据而导致大数据量的传输失败。
假设有a 表是源数据表，其中有空值，b 表是 a 表的归档表，设有非空约束，现要将 a 表数据（远程）大批量的插入到 b 表（本
地）。
alter table b modify constraint b_nn1 disable novalidate; 先使 B 表非空约束无效。
insert into b select * from a; 大批数据可以无约束插入，空值也插进 B 表里了。
alter table b modify constraint b_nn1 enable novalidate; 既往不咎，但若新输入数据必须符合要求。
update b set channel='NOT KNOWN'where channel is null; 将所有空值填充了，新老数据都符合要求了。
alter table b modify constraint b_nn1 enable validate; 最终是约束使能+验证生效，双管齐下。
12.4 延迟约束
12.4.1作用：
在插入大批量数据时先不检查约束（节约时间），而当提交时集中在一起检查约束。注意：一旦有一条 DML 语句违反了约束，
整个提交都将失败，全军覆没。
yyyyyyyyyy 分为可延迟（deferrable）可以通过查询 User_Constraints 视图获得当前所有关于约束的系统信息.
查看user_constraints 中的两个字段
Deferrable 是否为延迟约束 值为:Deferrable 或 Not Deferrable(缺省）.
Deferred 是否采用延迟 值为:Immediate（缺省）或 Deferred.
这两个字段的关系是：
1）如果创建约束时没有指定 Deferrable 那么以后也无法使约束成为延迟约束（只有通过重建约束时再指定它是延迟约束）
2）一个约束只有被定义成 Deferrable，那么这个约束 session 级才可以在 deferred 和 immediate 两种状态间相互转换
12.4.2延迟约束示例：
SQL> alter table emp1 add constraint chk_sal check(sal>500) deferrable; 建立可延迟约束
已将chk_sal 约束设为 Deferrable 了，下面可有两种面向 session 的方案：
1）约束不延迟，插入数据立刻检查约束
SQL>set constraint chk_sal immediate;
2）约束延迟，提交时将整个事务一起检查约束
SQL>set constraint chk_sal deferred;
资源由 www.eimhe.com  美河学习在线收集分享
使用set constraint 切换只影响当前会话，
也可以在建立约束时一次性指定系统级(全局设定所有会话）的延迟约束
①SQL>alter table emp1 add constraint chk_sal check(sal>500) deferrable initially immediate;
②SQL>alter table emp1 add constraint chk_sal check(sal>500) deferrable initially deferred;
第十三章、视图
13.1 为什么使用视图
1）限制数据的存取：
用户只能看到基表的部分信息。方法：赋予用户访问视图对象的权限，而不是表的对象权限。
2）使得复杂的查询的书写变得容易：
对于多表连接等复杂语句的映射，或内联视图的使用。
3）提供数据的独立性：
基表的多个独立子集的映射
13.2 简单视图和复杂视图
1） 简单视图：
视图与基表的记录一对一，故而可以通过视图修改基表。
2） 复杂视图：
视图与基表的记录一对多，无法修改视图。
13.2 语法
CREATE [OR REPLACE] [FORCE|NOFORCE] VIEW view
[(alias[, alias]...)]
AS subquery
[WITH CHECK OPTION [CONSTRAINT constraint]]
[WITH READ ONLY];
13.2.1 FORCE 作用：可以先建视图，后建基表
SQL>create force view view1 as select * from test1;
13.2.2 WITH CHECK OPTION 作用：对视图 where 子句进行约束，使视图结果集保持稳定。
SQL>create view view2 as select * from emp where deptno=10 with check option;
insert 不许插入非 10 号部门的记录
update 不许将 10 号部门修改为其他部门
13.2.3 WITH READ ONLY 作用：禁止对视图执行 DML 操作
SQL>create view view3 as select * from emp where deptno=10 with read only;
如果建立了视图 想查看其中的定义，可以访问如下视图 dba_views 中的 text 字段(long 型)；
declare
v_text dba_views.text%type;
v_name dba_views.view_name%type;
begin
select text, view_name into v_text,v_name FROM dba_views WHERE view_name='V1';
dbms_output.put_line(v_name||' define is :'||v_text);
end;
/
第十四章、同义词
14.1 作用
资源由 www.eimhe.com  美河学习在线收集分享
从字面上理解就是别名的意思，和视图的功能类似。就是一种映射关系。
14.2 公有同义词
同义词通常是数据库对象的别名
公有同义词一般由 DBA 创建，使所有用户都可使用,
创建者需要 create public synonym 权限。
示例:
SQL>conn / as sysdba
SQL>create view v1 as select ename,sal,deptno from scott.emp where deptno=10;
SQL>create public synonym syn1 for v1;
SQL>grant select on syn1 to public;
14.3 私有同义词
一般是普通用户自己建立的同义词，创建者需要 create synonym 权限。
sys:
SQL> grant create synonym to scott;
scott:
SQL> create synonym abc for emp; scott 建立了一个私有同义词
SQL> select * from abc; scott 可以使用这个私有同义词了
SQL> grant select on abc to tim; 把访问同义词的对象权限给 tim
SQL> select * from scott.abc; tim 使用同义词时要加模式名前缀(考点)
查看同义词的视图：dba_synonyms
删除私有同义词：drop synonym 同义词名
删除公有同义词：drop public synonym 同义词名
SQL>select * from dba_synonyms where synonym_name='SYN1';
14.3 同义词的要点
1）私有同义词是模式对象，一般在自己的模式中使用，如其他模式使用则必须用模式名前缀限定。
2）公有同义词不是模式对象，不能用模式名做前缀。
3）私有和公有同义词同名时，如果指向不同的对象，私有同义词优先。
4）引用的同义词的对象（表或视图）被删除了，同义词仍然存在，这同视图类似，重新创建该对象名，下次访问同义词时自动
编译。
第十五章、序列
15.1 序列的作用:
主要目的是为了自动生成主键值。
因为一个数据库序列被所有 session 共享使用。当多个 session 向一个表中插入数据时，序列保证主键值不会冲突，按照序列的
要求自动增长并不会重复
15.2 序列的两个伪列：
Currval: 序列的当前值，反复引用时该值不变。
Nextval: 序列的下一个值，每次引用按步长自增。
15.3 用法及示例
15.3.1示例 1：
CREATE SEQUENCE dept_deptno 序列名
INCREMENT BY 10 步长 10
START WITH 5 起点 5
MAXVALUE 100 最大 100
CYCLE 循环
NOCACHE 不缓存
第一次要引用一下 nextval 伪列
SQL>select dept_deptno.nextval from dual;
资源由 www.eimhe.com  美河学习在线收集分享
以后就有 currval 伪列值了。
SQL>select dept_deptno.nextval from dual;
15.3.2 示例 2：
主键使用序列
Session1/scott:
SQL> conn scott/scott
SQL> create table t1 (id int primary key,name char(8));
SQL> create sequence seq1;
SQL> grant all on t1 to tim;
SQL> grant all on seq1 to tim;
SQL> insert into t1 values(seq1.nextval,'a');
SQL> insert into t1 values(seq1.nextval,'b');
SQL> select * from t1;
ID NAME
---------- --------
1 a
2 b
Session2/tim:
SQL> conn tim/tim
SQL> insert into scott.t1 values(scott.seq1.nextval,'c');
SQL> select * from scott.t1;
ID NAME
---------- --------
3 c
两个session 由于使用序列发号而不会造成主键冲突，当它们都提交后，看到的数据是一样的。
SQL> drop sequence seq1; 删除序列不会影响之前的引用
15.3.3 几点说明：
1）建立一个最简单序列只需要 create sequence 序列名，其他使用缺省值，注意：起始是 1，步长也是 1。
2）如果启用选项 cache，缺省只有 20 个号，经验表明这个数量会不够，可以设置多一些，根据需要 10000 个也可以。
3）选项 cycle 其实没有什么意义，因为它使序列发出重复值，这对于基于序列是主键值的用法是个问题。
4）可以使用 alter 命令修改序列配置。但 alter 命令不能修改起始值。如果要重启该序列，唯一的办法是删除并重新创建它。
5）循环后初始是从 1 开始的，不管原来的值是如何设的（考点）
6）currval 的值显示的是当前 session 的最新 nextval
7）建表时 DEFALT(缺省值)不能使用 nextval 定义（考点）
8）删除序列的命令是 drop sequence 序列名
第三部分、SQL 语言的扩展
第十六章、DML 语句总结
16.1 Insert 语句的基本类型
1）单表一次插入一行，有 values 关键字。
2）单表一次插入多行，使用子查询，没有 values 关键字。
3）多表插入，又分 Insert all 和 Insert first 两种形式。
16,2单表单行插入
1）SQL> create table a (id int,name char(10) default 'aaa'); name 列指定了 default 值
2）SQL> insert into a values(1,'abc'); 表 a 后没有所选列，values 必须指定所有字段的值。
3）SQL> insert into a values(2,default); 同上，name 字段用 default 占位。
4）SQL> insert into a values(3,null); 表 a 后没有所选列，name 字段用 null 占位。
5）SQL> insert into a (id) values(4); 未选定的字段如果指定了 default,则以 default 的值代替 null
6）SQL> insert into (select id from a) values (5); 这种形式本质同上，只不过表 a 的形式以结果集代之。
7）SQL> insert into a values(6,(select dname from dept where deptno=10)); values 里的某列使用 subquery 引用另一个表的数据
注意几点：
1）不符合约束条件的 insert 不能成功。
资源由 www.eimhe.com  美河学习在线收集分享
2）default 不但可以用于 insert 语句, 也可以用于 update 语句（考点）
3）values 后面不可以跟多列子查（考点）。
SQL> insert into a values(select deptno,dname from dept where deptno=10);
报错：ORA-00936: 缺失表达式
更正如下：
SQL> insert into a values((select deptno from dept where deptno=10), (select dname from dept where deptno=10));
SQL> commit;
8）insert WITH CHECK OPTION 的用法
SQL> insert into (select id from a where id<100 WITH CHECK OPTION) values (20);
SQL> rollback;
SQL> insert into (select id from a where id<100 WITH CHECK OPTION) values (101);
报错: ORA-01402: view WITH CHECK OPTION where-clause violation
看看这句话的另一种情况：
SQL> insert into (select name from a where id<100 WITH CHECK OPTION) values ('NBA');
报错：ORA-01402: view WITH CHECK OPTION where-clause violation
上例是想说明如果插入的列不在 where 条件里，则不允许插入。
16.3单表一次插入多行
语法：主句去掉了 values 选项。使用 select 子查询，
SQL> create table b as select * from a where 1>2; 建立一个空表 b。结构来自 a 表
SQL> insert into b select * from a where name='aaa'; 插入的是结果集，注意没有 values 选项。
SQL> insert into b(id) select id from a where id in(1,3); 使用子查询（结果集）插入，对位
16.4多表插入
16.4.1作用：
一条INSERT 语句可以完成向多张表的插入任务（Multitable insert）。有两种形式：insert all 与 insert first，
准备测试环境：
1.创建表 T 并初始化测试数据，此表作为数据源。
create table t (x number(10), y varchar2(10));
insert into t values (1,'a');
insert into t values (2,'b');
insert into t values (3,'c');
insert into t values (4,'d');
insert into t values (5,'e');
insert into t values (6,'f');
commit;
2.创建表 T1 和 T2，作为我们要插入数据的目标表。
SQL>create table t1 as select * from t where 0=1;
SQL>create table t2 as select * from t where 0=1;
16.4.1第一种多表插入方法 INSERT ALL
SQL>insert all into t1 into t2 select * from t; （无条件 insert all)
12 rows created.
这里之所以显示插入了 12 条数据，实际上表示在 T1 表中插入了 6 条，T2 表插入了 6 条，一共是 12 条数据。（不分先后，各
插各的）
SQL>rollback;
SQL> insert all when x>=3 then into t1 when x>=2 then into t2 select * from t; （有条件 insert all)。
16.4.2第二种多表插入方法 INSERT FIRST
1）清空表 T1 和 T2
SQL> truncate table t1;
SQL> truncate table t2;
2）完成 INSERT FIRST 插入
SQL> insert first when x>=3 then into t1 when x>=2 then into t2 select * from t; (有条件 insert first)
处理逻辑是这样的，首先检索 T 表查找 X 列值大于等于 3 的数据插入到 T1 表，然后将前一个查询中出现的数据排除后再查找 T
表，找到 X 列值大于等于 2 的数据再插入到 T2 表，注意 INSERT FIRST 的真正目的是将同样的数据只插入一次。
3）验证 T1 和 T2 表中被插入的数据。
SQL> select * from t1;
SQL> select * from t2;
资源由 www.eimhe.com  美河学习在线收集分享
第十七章、其他 DML 和 DDL 语句的用法
17.1 DML 语句-MERGE
根据一个表的数据组织另一个表的数据，一般是对 merge 的目标表插入新数据或替换掉老数据。
Oracle 10g 中 MERGE 有如下一些改进：
1、UPDATE 或 INSERT 子句是可选的
2、UPDATE 和 INSERT 子句可以加 WHERE 子句
3、ON 条件使用常量过滤谓词来 insert 所有的行到目标表中,不需要连接源表和目标表
4、UPDATE 子句后面可以跟 DELETE 子句来去除一些不需要的行
示例：首先创建表：
SQL>create table PRODUCTS
(
PRODUCT_ID INTEGER,
PRODUCT_NAME VARCHAR2(30),
CATEGORY VARCHAR2(30)
);
insert into PRODUCTS values (1501, 'VIVITAR 35MM', 'ELECTRNCS');
insert into PRODUCTS values (1502, 'OLYMPUS IS50', 'ELECTRNCS');
insert into PRODUCTS values (1600, 'PLAY GYM', 'TOYS');
insert into PRODUCTS values (1601, 'LAMAZE', 'TOYS');
insert into PRODUCTS values (1666, 'HARRY POTTER', 'DVD');
commit;
SQL>create table NEWPRODUCTS
(
PRODUCT_ID INTEGER,
PRODUCT_NAME VARCHAR2(30),
CATEGORY VARCHAR2(30)
);
insert into NEWPRODUCTS values (1502, 'OLYMPUS CAMERA', 'ELECTRNCS');
insert into NEWPRODUCTS values (1601, 'LAMAZE', 'TOYS');
insert into NEWPRODUCTS values (1666, 'HARRY POTTER', 'TOYS');
insert into NEWPRODUCTS values (1700, 'WAIT INTERFACE', 'BOOKS');
commit;
SQL>select * from products;
PRODUCT_ID PRODUCT_NAME CATEGORY
---------- ------------------------------ ------------------------------
1501 VIVITAR 35MM ELECTRNCS
1502 OLYMPUS IS50 ELECTRNCS
1600 PLAY GYM TOYS
1601 LAMAZE TOYS
1666 HARRY POTTER DVD
SQL> select * from newproducts;
PRODUCT_ID PRODUCT_NAME CATEGORY
---------- ------------------------------ ------------------------------
1502 OLYMPUS CAMERA ELECTRNCS
1601 LAMAZE TOYS
1666 HARRY POTTER TOYS
1700 WAIT INTERFACE BOOKS
下面我们从表 NEWPRODUCTS 中合并行到表 PRODUCTS 中, 但删除 category 为 ELECTRNCS 的行.
SQL>MERGE INTO products p
USING newproducts np
ON (p.product_id = np.product_id)
WHEN MATCHED THEN
资源由 www.eimhe.com  美河学习在线收集分享
UPDATE
SET p.product_name = np.product_name,p.category = np.category
DELETE WHERE (p.category = 'ELECTRNCS')
WHEN NOT MATCHED THEN
INSERT
VALUES (np.product_id, np.product_name, np.category);
SQL>select * from products;
PRODUCT_ID PRODUCT_NAME CATEGORY
---------- ------------------------------ ------------------------------
1501 VIVITAR 35MM ELECTRNCS
1600 PLAY GYM TOYS
1601 LAMAZE TOYS
1666 HARRY POTTER TOYS
1700 WAIT INTERFACE BOOKS
为什么1502 不在了，但 1501 还在？ 因为 1502 是 matched,先被 update,然后被 delete, 而 1501 是 not matched.
注意几点：
1）例子里有 update,delete 和 insert。它们是否操作是取决于 on 子句的，两个表如果符合 on 条件就是匹配，不符合就是不匹配。
2）匹配了就更新，不匹配则插入。10g 后加入了 delete 语句，这个语句必须在匹配条件下出现。它是一种补充。
3）你必须对操作的表有对象权限
4）ON 子句里的字段不能被 update 子句更新
17.2 WITH 语句
可以使用一个关键字 WITH， 为一个子查询块（subquery block）起一个别名。然后在后面的查询中引用该子查询块的别名。
好处：
1）使用 with 语句，可以避免在 select 语句中重复书写相同的语句块。
2）with 语句将该子句中的语句块执行一次并存储到用户的临时表空间中。
3）使用 with 语句可以避免重复解析，提高查询效率。
示例：这个 with 语句完成三个动作
建立一个 dept_costs，保存每个部门的工资总和，
建立一个 avg_cost，根据 dept_costs 求出所有部门总工资的平均值，
最后显示出部门总工资值小于部门总工资平均值的那些部门的信息(dname)。
WITH
dept_costs AS (
SELECT d.dname, SUM(e.sal) AS dept_total
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY d.dname ),
avg_cost AS (SELECT SUM(dept_total)/COUNT(*) AS dept_avg FROM dept_costs)
SELECT * FROM dept_costs
WHERE dept_total <
(SELECT dept_avg FROM avg_cost)
ORDER BY dname
/
DNAME DEPT_TOTAL
-------------- ----------
ACCOUNTING 8750
SALES 9400、
可以分三个部分来看:
第一AS 建立 dept_costs，保存每个部门的工资总和。
第二个 AS 建立 avg_cost，根据第一个 AS dept_costs 求出所有部门总工资的平均值（两个 with 子程序用逗号分开，第二个使用
了第一个别名）。
最后是查询主体，SELECT * FROM... 调用了前两个 with 下的别名（子查询），显示部门总工资值小于部门总工资平均值的那些
部门的信息。
1）with 语句中只能有 select 子句，没有 DML 子句（注意和 merge 的区别）。
资源由 www.eimhe.com  美河学习在线收集分享
2）一般将主查询放在最后描述，因为查询主体中要引用的 with 别名需要在之前定义过。
17.3 表的 DDL 操作
1）在数据库打开的情况下，可以使用 DDL 语句修改数据字典信息，主要 DDL 语句对列的操作有：
增加（add) 一列，
修改（midify)列的宽度,
删除（drop colunm)一列,
更名（rename column) 列名
2）当想要 add 一列，并约束该列为 not null 时，如果该表已经有数据了，加的列本身是 null,则与 not null 约束矛盾，报错 。
SQL> select * from a;
ID NAME
---------- ----------
1 a
2 b
SQL> alter table a add C number(5) not null;
报错：ORA-01758: 要添加必需的 (NOT NULL) 列, 则表必须为空
SQL> alter table a add C number(5) default 0 not null;
修改成功了，可以看到 C 列全是 0，这样才能使 C 列的约束为 not null （考点）
3）要删除某一个表格上的某个字段，但是由于这个表格拥有非常大量的资料，如果你在尖峰时间直接执行 ALTER TABLE ABC DROP
（COLUMN）；可能会收到 ORA-01562 -
failed to extend rollback segment number string
Oracle 推荐：使用 SET UNUSED 选项标记一列（或多列），使该列不可用。
然后，当业务量下降后再使用 DROP UNUSED column 选项删除被被标记为不可用的列。SET UNUSED COLUMNS 用于 drop 多列时
效率更高，
SET UNUSED COLUMNS 方法系统开销比较小，速度较快，但效果等同于直接 drop column。就是说这两种方法都不可逆，无法再
还原该字段及其内容了。
语法：
ALTER TABLE table SET UNUSED [column] (COLlist 多个)
ALTER TABLE table DROP UNUSED [COLUMN];
查看unused 后的视图
select * from user_unused_col_tabs;
1）如果 set unused 某列，该列上有索引，约束，并定义了视图，引用过序列，结果如何，索引和约束自动删除，序列无关，视
图保留定义。
2）无法删除属于 SYS 的表中的列，会报 ORA-12988 错误，哪怕你是 sys 用户都不可以。
实验：scott 下
SQL>create table a (id int, name char(10));
SQL>create index id_idx on a(id);
SQL>alter table a add constraint unq_id unique(id);
SQL>create sequence a_id start with 1 increment by 1;
SQL>create view v as select id from a;
SQL>insert into a values(a_id.nextval,'tim');
SQL>insert into a values(a_id.nextval,'ran');
SQL>commit;
SQL> select * from a;
SQL> select index_name from user_indexes where table_name='A'; 查看有关索引
SQL> select constraint_name from user_constraints where table_name='A'; 查看有关约束
SQL> select object_name from user_objects where object_type='SEQUENCE'; 查看有关序列
SQL> select text from user_views where view_name='V'; 查看有关视图
SQL> alter table a drop column id;
重复查看有关信息，索引和约束随该列数据虽然被删除，但序列和视图的定义还在。
17.4 模式及名称空间
模式(Schema)是一种逻辑结构，它对应于用户，每建一个用户就有一套模式与之对应。
我们通常说对象的唯一标识符是前缀为模式名加上对象名称，如 scott.emp。
同一模式下的同类对象是不可以重名的。比如在 scott 模式里，表 emp 是唯一的，但在不同模式下可以重名。
名称空间定义了一组对象类型，同一个名称空间里的不同对象不能同名，而不同的名称空间中的不同对象可以共享相同的名称。
1）表，视图，序列，同义词是不同类型的对象，但它们属于同一名称空间, 因此在同一模式下也是不可以重名的，比如 scott
下不可以让一个表名和一个视图名同名。
资源由 www.eimhe.com  美河学习在线收集分享
2）索引、约束有自己的名称空间，所以在 scott 模式下，可以有表 A,索引 A 和约束 A 共存
3）表名最长可以 30 个字符，表名中若包含特殊字符需要使用“”将表名全部包括在内，表的最大列数为 1000。
第十八章、ORACLE 分层查询
18.1 树的遍历
分层查询是 select 语句的扩展，目的是迅速找出表中父列--子列的隶属关系。
首先我们应该熟悉一下树的遍历方法
ORACLE 是一个关系数据库管理系统，在某些表中的数据还呈现出树型结构的联系。例如，在 EMP 表中含有雇员编号（EMPNO）
和经理（MGR）两列，这两列反映出来的就是雇员之间领导和被领导的关系。这种关系就是一种树结构。
图1.1 EMP 表树结构图
树的遍历有两个方向
top--down 自上而下
即父亲找儿子，一个父亲可能有几个儿子，一个儿子可能有几个孙子，遍历不能丢了儿子，顺序以左为先。
down--top 自底向上
即儿子找父亲，一个儿子只能有一个父亲，所以顺序应该是：孙子->儿子-->父亲-->爷爷。
18.2 分层查询语法
在SELECT 命令中使用 CONNECT BY 和 START WITH 子句可以查询表中的树型结构关系。其命令格式如下：
SELECT ...
CONNECT BY {PRIOR 列名 1=列名 2|列名 1=PRIOR 列名 2}
[START WITH]；
18.3.1 CONNECT BY 子句
理解CONNECT BY PRIOR 子句至关重要，它确定了树的检索方向: 是 top --> down（父-->子）还是 down --> top（子-->父）。
在分层表中，表的父列与子列是确定的（身份固定），如：在 emp 表中 empno 是子列（下级）， mgr 是父列（上级）。
PRIOR 关键字就像一个箭头("-->")，
①connect by prior empno = mgr
②connect by mgr = prior empno
两句语法等同，都是说 mgr（父）--> empno(子），因此树的检索方向是 top --> down。
①connect by empno = prior mgr
②connect by prior mgr = empno
两句语法等同，都是说 empno(子）--> mgr(父），因此树的检索方向是 down --> top。
18.3.2 START WITH
子句为可选项，用来标识哪个节点作为查找树型结构的根节点。若该子句被省略，则表示所有满足查询条件的行作为根节点（每
一行都会成为一个树根）。
例1 以树结构方式显示 EMP 表的数据。
SQL>select empno,ename,mgr from emp
connect by prior empno=mgr
start with empno=7839
/
EMPNO ENAME MGR
---------- ---------- ----------
7839 KING
7566 JONES 7839
7788 SCOTT 7566
资源由 www.eimhe.com  美河学习在线收集分享
7876 ADAMS 7788
7902 FORD 7566
7369 SMITH 7902
7698 BLAKE 7839
7499 ALLEN 7698
7521 WARD 7698
7654 MARTIN 7698
7844 TURNER 7698
7900 JAMES 7698
7782 CLARK 7839
7934 MILLER 7782
仔细看empno 这一列输出的顺序，就是上图树状结构每一条分支（从根节点开始）的结构。
例2 从 SMITH 节点开始自底向上查找 EMP 的树结构。
SQL>select empno,ename,mgr
from emp
connect by empno=prior mgr
start with empno=7369
/
EMPNO ENAME MGR
---------- ---------- ----------
7369 SMITH 7902
7902 FORD 7566
7566 JONES 7839
7839 KING
在这种自底向上的查找过程中，只有树中的一枝被显示。
18.3 定义起始节点
在自顶向下查询树结构时，不但可以从根节点开始，还可以定义任何节点为起始节点，以此开始向下查找。这样查找的结果就
是以该节点为开始的结构树的一枝。
例3 查找 7566(JONES)直接或间接领导的所有雇员信息。
SQL＞SELECT EMPNO,ENAME,MGR
FROM EMP
CONNECT BY PRIOR EMPNO=MGR
START WITH EMPNO=7566
/
EMPNO ENAME MGR
---------- ---------- ----------
7566 JONES 7839
7788 SCOTT 7566
7876 ADAMS 7788
7902 FORD 7566
7369 SMITH 7902
START WITH 不但可以指定一个根节点，还可以指定多个根节点。
例4 查找由 FORD 和 BLAKE 领导的所有雇员的信息。
SQL>SELECT EMPNO,ENAME,MGR
FROM EMP
CONNECT BY PRIOR EMPNO=MGR
START WITH ENAME IN ('FORD','BLAKE')
/
EMPNO ENAME MGR
---------- ---------- ----------
7902 FORD 7566
7369 SMITH 7902
7698 BLAKE 7839
7499 ALLEN 7698
7521 WARD 7698
资源由 www.eimhe.com  美河学习在线收集分享
7654 MARTIN 7698
7844 TURNER 7698
7900 JAMES 7698
8 rows selected.
18.4 使用 LEVEL 伪列
在查询中，可以使用伪列 LEVEL 显示每行数据的有关层次。LEVEL 将返回树型结构中当前节点的层次。
伪列LEVEL 为数值型，可以在 SELECT 命令中用于各种计算。
例5
1）使用 LEVEL 伪列显示所有员工隶属关系。
SQL> COLUMN LEVEL FORMAT A20
SQL> SELECT LPAD(LEVEL,LEVEL*3,' ')
as "LEVEL",EMPNO,ENAME,MGR
FROM EMP
CONNECT BY PRIOR EMPNO=MGR
START WITH ENAME='KING'
/
LEVEL EMPNO ENAME MGR
-------------------- ---------- ---------- ----------
1 7839 KING
2 7566 JONES 7839
3 7788 SCOTT 7566
4 7876 ADAMS 7788
3 7902 FORD 7566
4 7369 SMITH 7902
2 7698 BLAKE 7839
3 7499 ALLEN 7698
3 7521 WARD 7698
3 7654 MARTIN 7698
3 7844 TURNER 7698
3 7900 JAMES 7698
2 7782 CLARK 7839
3 7934 MILLER 7782
14 rows selected.
在SELECT 使用了函数 LPAD，该函数表示以 LEVEL*3 个空格进行填充，由于不同行处于不同的节点位置，具有不同的 LEVEL 值，
因此填充的空格数将根据各自的层号确定，空格再与层号拼接，结果显示出这种缩进的层次关系。
2）只查看第 2 层的员工信息：
SQL> select t1.* from (select level LNUM ,ename,mgr from emp connect by prior empno=mgr start with ename='KING') t1 where
LNUM=2;
LNUM ENAME MGR
---------- ---------- ----------
2 JONES 7839
2 BLAKE 7839
2 CLARK 7839
SQL> select lnum,avg(sal) avgsal from (select level LNUM ,ename,mgr,sal from emp connect by prior empno=mgr start with
ename='KING') group by lnum having lnum=2;
LNUM AVGSAL
---------- ----------
2 2758.33333
18.5 节点和分支的裁剪
在对树结构进行查询时，可以去掉表中的某些行，也可以剪掉树中的一个分支，使用 WHERE 子句来限定树型结构中的单个节点，
以去掉树中的单个节点，但它却不影响其后代节点
（自顶向下检索时）或前辈节点（自底向顶检索时）。
SQL>SELECT LPAD(LEVEL,LEVEL*3,' ')
as "LEVEL",EMPNO,ENAME,MGR
FROM EMP
WHERE ENAME<>'SCOTT'
资源由 www.eimhe.com  美河学习在线收集分享
CONNECT BY PRIOR EMPNO=MGR
START WITH ENAME='KING'
/
LEVEL EMPNO ENAME MGR
-------------------- ---------- ---------- ----------
1 7839 KING
2 7566 JONES 7839
4 7876 ADAMS 7788
3 7902 FORD 7566
4 7369 SMITH 7902
2 7698 BLAKE 7839
3 7499 ALLEN 7698
3 7521 WARD 7698
3 7654 MARTIN 7698
3 7844 TURNER 7698
3 7900 JAMES 7698
2 7782 CLARK 7839
3 7934 MILLER 7782
13 rows selected.
在这个查询中，仅剪去了树中单个节点 SCOTT。若希望剪去树结构中的某个分支，则要用 CONNECT BY 子句。CONNECT BY 子句
是限定树型结构中的整个分支，既要剪除分支
上的单个节点，也要剪除其后代节点（自顶向下检索时）或前辈节点（自底向顶检索时）。
例．显示 KING 领导下的全体雇员信息，除去 SCOTT 领导的一支。
SQL>SELECT LPAD(LEVEL,LEVEL*3,' ')
as "LEVEL",EMPNO,ENAME,MGR
FROM EMP
CONNECT BY PRIOR EMPNO=MGR
AND ENAME!='SCOTT'
START WITH ENAME='KING'
/
这个查询结果就除了剪去单个节点 SCOTT 外，还将 SCOTT 的子节点 ADAMS 剪掉，即把 SCOTT 这个分支剪掉了。当然 WHERE 子
句可以和 CONNECT BY 子句联合使用，这样能够同时剪掉单个节点和树中的某个分支。
在使用SELECT 语句来报告树结构报表时应当注意，CONNECT BY 子句不能作用于出现在 WHERE 子句中的表连接。如果需要进行
连接，可以先用树结构建立一个视图，再将这个视图与其他表连接，以完成所需要的查询。




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


一段SQL代码写好以后，可以通过查看SQL的执行计划，初步预测该SQL在运行时的性能好坏，尤其是在发现某个SQL语句的效率较差时，我们可以通过查看执行计划，分析出该SQL代码的问题所在。


那么，作为开发人员，怎么样比较简单的利用执行计划评估SQL语句的性能呢？总结如下步骤供大家参考：

1、 打开熟悉的查看工具：PL/SQL Developer。
  在PL/SQL Developer中写好一段SQL代码后，按F5，PL/SQL Developer会自动打开执行计划窗口，显示该SQL的执行计划。

2、 查看总COST，获得资源耗费的总体印象
  一般而言，执行计划第一行所对应的COST(即成本耗费)值，反应了运行这段SQL的总体估计成本，单看这个总成本没有实际意义，但可以拿它与相同逻辑不同执行计划的SQL的总体COST进行比较，通常COST低的执行计划要好一些。

3、 按照从左至右，从上至下的方法，了解执行计划的执行步骤
执行计划按照层次逐步缩进，从左至右看，缩进最多的那一步，最先执行，如果缩进量相同，则按照从上而下的方法判断执行顺序，可粗略认为上面的步骤优先执行。每一个执行步骤都有对应的COST,可从单步COST的高低，以及单步的估计结果集（对应ROWS/基数），来分析表的访问方式，连接顺序以及连接方式是否合理。

4、 分析表的访问方式
  表的访问方式主要是两种：全表扫描（TABLE ACCESS FULL）和索引扫描(INDEX SCAN)，如果表上存在选择性很好的索引，却走了全表扫描，而且是大表的全表扫描，就说明表的访问方式可能存在问题；若大表上没有合适的索引而走了全表扫描，就需要分析能否建立索引，或者是否能选择更合适的表连接方式和连接顺序以提高效率。

5、 分析表的连接方式和连接顺序
  表的连接顺序：就是以哪张表作为驱动表来连接其他表的先后访问顺序。
表的连接方式：简单来讲，就是两个表获得满足条件的数据时的连接过程。主要有三种表连接方式，嵌套循环（NESTED LOOPS）、哈希连接（HASH JOIN）和排序-合并连接（SORT MERGE JOIN）。我们常见得是嵌套循环和哈希连接。
嵌套循环：最适用也是最简单的连接方式。类似于用两层循环处理两个游标，外层游标称作驱动表，Oracle检索驱动表的数据，一条一条的代入内层游标，查找满足WHERE条件的所有数据，因此内层游标表中可用索引的选择性越好，嵌套循环连接的性能就越高。
哈希连接：先将驱动表的数据按照条件字段以散列的方式放入内存，然后在内存中匹配满足条件的行。哈希连接需要有合适的内存，而且必须在CBO优化模式下，连接两表的WHERE条件有等号的情况下才可以使用。哈希连接在表的数据量较大，表中没有合适的索引可用时比嵌套循环的效率要高。

6、 请核心技术组协助分析  www.2cto.com
以上步骤可以协助我们初步分析SQL性能问题，如果遇到连接表太多，执行计划过于复杂，可联系核心技术组共同讨论，一起寻找更合适的SQL写法或更恰当的索引建立方法

总结两点：
1、这里看到的执行计划，只是SQL运行前可能的执行方式，实际运行时可能因为软硬件环境的不同，而有所改变，而且cost高的执行计划，不一定在实际运行起来，速度就一定差，我们平时需要结合执行计划，和实际测试的运行时间，来确定一个执行计划的好坏。
2、对于表的连接顺序，多数情况下使用的是嵌套循环，尤其是在索引可用性好的情况下，使用嵌套循环式最好的，但当ORACLE发现需要访问的数据表较大，索引的成本较高或者没有合适的索引可用时，会考虑使用哈希连接，以提高效率。排序合并连接的性能最差，但在存在排序需求，或者存在非等值连接无法使用哈希连接的情况下，排序合并的效率，也可能比哈希连接或嵌套循环要好。

附I：几种主要表连接的比较



http://www.2cto.com/database/201204/127178.html

