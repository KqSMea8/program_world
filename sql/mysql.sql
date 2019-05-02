mysql的性能优化包罗甚广： 索引优化，查询优化，查询缓存，服务器设置优化，操作系统和硬件优化，应用层面优化（web服务器，缓存）等等。

建立索引的几个准则：

1、合理的建立索引能够加速数据读取效率，不合理的建立索引反而会拖慢数据库的响应速度。 2、索引越多，更新数据的速度越慢。 3、尽量在采用MyIsam作为引擎的时候使用索引（因为MySQL以BTree存储索引），而不是InnoDB。但MyISAM不支持Transcation。 4、当你的程序和数据库结构/SQL语句已经优化到无法优化的程度，而程序瓶颈并不能顺利解决，那就是应该考虑使用诸如memcached这样的分布式缓存系统的时候了。 5、习惯和强迫自己用EXPLAIN来分析你SQL语句的性能。

1. count的优化

计算id大于5的城市 a. select count(*) from world.city where id > 5; b. select (select count(*) from world.city) – count(*) from world.city where id <= 5; a语句当行数超过11行的时候需要扫描的行数比b语句要多， b语句扫描了6行，此种情况下，b语句比a语句更有效率

当没有where语句的时候直接select count(*) from world.city这样会更快，因为mysql总是知道表的行数。

2. 避免使用不兼容的数据类型。

例如float和int、char和varchar、binary和varbinary是不兼容的。数据类型的不兼容可能使优化器无法执行一些本来可以进行的优化操作。 在程序中，保证在实现功能的基础上，尽量减少对数据库的访问次数；通过搜索参数，尽量减少对表的访问行数,最小化结果集，从而减轻网络负担；能够分开的操作尽量分开处理，提高每次的响应速度；在数据窗口使用SQL时，尽量把使用的索引放在选择的首列；算法的结构尽量简单；在查询时，不要过多地使用通配符如 SELECT * FROM T1语句，要用到几列就选择几列如：SELECT COL1,COL2 FROM T1；在可能的情况下尽量限制尽量结果集行数如：SELECT TOP 300 COL1,COL2,COL3 FROM T1,因为某些情况下用户是不需要那么多的数据的。不要在应用中使用数据库游标，游标是非常有用的工具，但比使用常规的、面向集的SQL语句需要更大的开销；按照特定顺序提取数据的查找。

3. 索引字段上进行运算会使索引失效。

尽量避免在WHERE子句中对字段进行函数或表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如： SELECT * FROM T1 WHERE F1/2=100 应改为: SELECT * FROM T1 WHERE F1=100*2

4. 避免使用!=或＜＞、IS NULL或IS NOT NULL、IN ，NOT IN等这样的操作符.

因为这会使系统无法使用索引,而只能直接搜索表中的数据。例如: SELECT id FROM employee WHERE id != “B%” 优化器将无法通过索引来确定将要命中的行数,因此需要搜索该表的所有行。在in语句中能用exists语句代替的就用exists.

5. 尽量使用数字型字段.

一部分开发人员和数据库管理人员喜欢把包含数值信息的字段 设计为字符型，这会降低查询和连接的性能，并会增加存储开销。这是因为引擎在处理查询和连接回逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了。

6. 合理使用EXISTS,NOT EXISTS子句。如下所示：

1.SELECT SUM(T1.C1) FROM T1 WHERE (SELECT COUNT(*)FROM T2 WHERE T2.C2=T1.C2>0) 2.SELECT SUM(T1.C1) FROM T1WHERE EXISTS(SELECT * FROM T2 WHERE T2.C2=T1.C2) 两者产生相同的结果，但是后者的效率显然要高于前者。因为后者不会产生大量锁定的表扫描或是索引扫描。如果你想校验表里是否存在某条纪录，不要用count(*)那样效率很低，而且浪费服务器资源。可以用EXISTS代替。如： IF (SELECT COUNT(*) FROM table_name WHERE column_name = ‘xxx’)可以写成：IF EXISTS (SELECT * FROM table_name WHERE column_name = ‘xxx’)

7. 能够用BETWEEN的就不要用IN

8. 能够用DISTINCT的就不用GROUP BY

9. 尽量不要用SELECT INTO语句。SELECT INTO 语句会导致表锁定，阻止其他用户访问该表。

10. 必要时强制查询优化器使用某个索引

SELECT * FROM T1 WHERE nextprocess = 1 AND processid IN (8,32,45) 改成： SELECT * FROM T1 (INDEX = IX_ProcessID) WHERE nextprocess = 1 AND processid IN (8,32,45) 则查询优化器将会强行利用索引IX_ProcessID 执行查询。

11. 消除对大型表行数据的顺序存取

尽管在所有的检查列上都有索引，但某些形式的WHERE子句强迫优化器使用顺序存取。如： SELECT * FROM orders WHERE (customer_num=104 AND order_num>1001) OR order_num=1008 解决办法可以使用并集来避免顺序存取： SELECT * FROM orders WHERE customer_num=104 AND order_num>1001 UNION SELECT * FROM orders WHERE order_num=1008 这样就能利用索引路径处理查询。【jacking 数据结果集很多，但查询条件限定后结果集不大的情况下，后面的语句快】

12. 尽量避免在索引过的字符数据中，使用非打头字母搜索。这也使得引擎无法利用索引。

见如下例子： SELECT * FROM T1 WHERE NAME LIKE ‘%L%’ SELECT * FROM T1 WHERE SUBSTING(NAME,2,1)=’L’ SELECT * FROM T1 WHERE NAME LIKE ‘L%’ 即使NAME字段建有索引，前两个查询依然无法利用索引完成加快操作，引擎不得不对全表所有数据逐条操作来完成任务。而第三个查询能够使用索引来加快操作，不要习惯性的使用 ‘%L%’这种方式(会导致全表扫描)，如果可以使用`L%’相对来说更好;

13. 虽然UPDATE、DELETE语句的写法基本固定，但是还是对UPDATE语句给点建议：

a) 尽量不要修改主键字段。 b) 当修改VARCHAR型字段时，尽量使用相同长度内容的值代替。 c) 尽量最小化对于含有UPDATE触发器的表的UPDATE操作。 d) 避免UPDATE将要复制到其他数据库的列。 e) 避免UPDATE建有很多索引的列。 f) 避免UPDATE在WHERE子句条件中的列。

14. 能用UNION ALL就不要用UNION

UNION ALL不执行SELECT DISTINCT函数，这样就会减少很多不必要的资源 在跨多个不同的数据库时使用UNION是一个有趣的优化方法，UNION从两个互不关联的表中返回数据，这就意味着不会出现重复的行，同时也必须对数据进行排序，我们知道排序是非常耗费资源的，特别是对大表的排序。 UNION ALL可以大大加快速度，如果你已经知道你的数据不会包括重复行，或者你不在乎是否会出现重复的行，在这两种情况下使用UNION ALL更适合。此外，还可以在应用程序逻辑中采用某些方法避免出现重复的行，这样UNION ALL和UNION返回的结果都是一样的，但UNION ALL不会进行排序。

15. 字段数据类型优化：

a. 避免使用NULL类型：NULL对于大多数数据库都需要特殊处理，MySQL也不例外，它需要更多的代码，更多的检查和特殊的索引逻辑，有些开发人员完全没有意识到，创建表时NULL是默认值，但大多数时候应该使用NOT NULL，或者使用一个特殊的值，如0，-1作为默认值。 b. 尽可能使用更小的字段，MySQL从磁盘读取数据后是存储到内存中的，然后使用cpu周期和磁盘I/O读取它，这意味着越小的数据类型占用的空间越小，从磁盘读或打包到内存的效率都更好，但也不要太过执着减小数据类型，要是以后应用程序发生什么变化就没有空间了。修改表将需要重构，间接地可能引起代码的改变，这是很头疼的问题，因此需要找到一个平衡点。 c. 优先使用定长型

16. 关于大数据量limit分布的优化见下面链接（当偏移量特别大时，limit效率会非常低）：

http://ariyue.iteye.com/blog/553541 附上一个提高limit效率的简单技巧，在覆盖索引(覆盖索引用通俗的话讲就是在select的时候只用去读取索引而取得数据，无需进行二次select相关表)上进行偏移，而不是对全行数据进行偏移。可以将从覆盖索引上提取出来的数据和全行数据进行联接，然后取得需要的列，会更有效率，看看下面的查询： mysql> select film_id, description from sakila.film order by title limit 50, 5; 如果表非常大，这个查询最好写成下面的样子： mysql> select film.film_id, film.description from sakila.film inner join(select film_id from sakila.film order by title liimit 50,5) as film usinig(film_id);

17. 程序中如果一次性对同一个表插入多条数据，比如以下语句：

insert into person(name,age) values(‘xboy’, 14); insert into person(name,age) values(‘xgirl’, 15); insert into person(name,age) values(‘nia’, 19); 把它拼成一条语句执行效率会更高. insert into person(name,age) values(‘xboy’, 14), (‘xgirl’, 15),(‘nia’, 19);

18. 不要在选择的栏位上放置索引，这是无意义的。应该在条件选择的语句上合理的放置索引，比如where，order by。

SELECT id,title,content,cat_id FROM article WHERE cat_id = 1;

上面这个语句，你在id/title/content上放置索引是毫无意义的，对这个语句没有任何优化作用。但是如果你在外键cat_id上放置一个索引，那作用就相当大了。

19. ORDER BY语句的MySQL优化： a. ORDER BY + LIMIT组合的索引优化。如果一个SQL语句形如：

SELECT [column1],[column2],…. FROM [TABLE] ORDER BY [sort] LIMIT [offset],[LIMIT];

这个SQL语句优化比较简单，在[sort]这个栏位上建立索引即可。

b. WHERE + ORDER BY + LIMIT组合的索引优化，形如：

SELECT [column1],[column2],…. FROM [TABLE] WHERE [columnX] = [VALUE] ORDER BY [sort] LIMIT [offset],[LIMIT];

这个语句，如果你仍然采用第一个例子中建立索引的方法，虽然可以用到索引，但是效率不高。更高效的方法是建立一个联合索引(columnX,sort)

c. WHERE + IN + ORDER BY + LIMIT组合的索引优化，形如：

SELECT [column1],[column2],…. FROM [TABLE] WHERE [columnX] IN ([value1],[value2],…) ORDER BY [sort] LIMIT [offset],[LIMIT];

这个语句如果你采用第二个例子中建立索引的方法，会得不到预期的效果（仅在[sort]上是using index，WHERE那里是using where;using filesort），理由是这里对应columnX的值对应多个。 目前哥还木有找到比较优秀的办法，等待高手指教。

d.WHERE+ORDER BY多个栏位+LIMIT，比如:

SELECT * FROM [table] WHERE uid=1 ORDER x,y LIMIT 0,10;

对于这个语句，大家可能是加一个这样的索引:(x,y,uid)。但实际上更好的效果是(uid,x,y)。这是由MySQL处理排序的机制造成的。

20. 其它技巧：

http://www.cnblogs.com/nokiaguy/archive/2008/05/24/1206469.html http://www.cnblogs.com/suchshow/archive/2011/12/15/2289182.html http://www.cnblogs.com/cy163/archive/2009/05/28/1491473.html http://www.cnblogs.com/younggun/articles/1719943.html http://wenku.baidu.com/view/f57c7041be1e650e52ea9985.html


MySQL的万能嵌套循环并不是对每种查询都是最优的。不过MySQL查询优化器只对少部分查询不适用，而且我们往往可以通过改写查询让MySQL高效的完成工作。

1 关联子查询
MySQL的子查询实现的非常糟糕。最糟糕的一类查询时where条件中包含in()的子查询语句。因为MySQL对in()列表中的选项有专门的优化策略，一般会认为MySQL会先执行子查询返回所有in()子句中查询的值。一般来说，in()列表查询速度很快，所以我们会以为sql会这样执行

select * from tast_user where id in (select id from user where name like '王%');
我们以为这个sql会解析成下面的形式
select * from tast_user where id in (1,2,3,4,5);
实际上MySQL是这样解析的
select * from tast_user where exists
(select id from user where name like '王%' and tast_user.id = user.id);
MySQL会将相关的外层表压缩到子查询中，它认为这样可以更高效的查找到数据行。

这时候由于子查询用到了外部表中的id字段所以子查询无法先执行。通过explin可以看到，MySQL先选择对tast_user表进行全表扫描，然后根据返回的id逐个执行子查询。如果外层是一个很大的表，那么这个查询的性能会非常糟糕。当然我们可以优化这个表的写法：

select tast_user.* from tast_user inner join user using(tast_user.id) where user.name like '王%'
另一个优化的办法就是使用group_concat()在in中构造一个由逗号分隔的列表。有时这比上面使用关联改写更快。因为使用in()加子查询，性能通常会非常糟糕。所以通常建议使用exists()等效的改写查询来获取更好的效率。

如何书写更好的子查询就不在介绍了，因为现在基本都要求拆分成单表查询了，有兴趣的话可以自行去了解下。

2 UNION的限制
有时，MySQL无法将限制条件从外层下推导内层，这使得原本能够限制部分返回结果的条件无法应用到内层查询的优化上。

如果希望union的各个子句能够根据limit只取部分结果集，或者希望能够先排好序在合并结果集的话，就需要在union的各个子句中分别使用这些子句。例如，想将两个子查询结果联合起来，然后在取前20条，那么MySQL会将两个表都存放到一个临时表中，然后在去除前20行。

(select first_name,last_name from actor order by last_name) union all
(select first_name,last_name from customer order by  last_name) limit 20;
这条查询会将actor中的记录和customer表中的记录全部取出来放在一个临时表中，然后在取前20条，可以通过在两个子查询中分别加上一个limit 20来减少临时表中的数据。

现在中间的临时表只会包含40条记录了，处于性能考虑之外，这里还需要注意一点：从临时表中取出数据的顺序并不是一定，所以如果想获得正确的顺序，还需要在加上一个全局的order by操作

3 索引合并优化
前面文章中已经提到过，MySQL能够访问单个表的多个索引以合并和交叉过滤的方式来定位需要查找的行。

4 等值传递
某些时候，等值传递会带来一些意想不到的额外消耗。例如，有一个非常大的in()列表，而MySQL优化器发现存在where/on或using的子句，将这个列表的值和另一个表的某个列相关联。

那么优化器会将in()列表都赋值应用到关联的各个表中。通常，因为各个表新增了过滤条件，优化器可以更高效的从存储引擎过滤记录。但是如果这个列表非常大，则会导致优化和执行都会变慢。

5 并行执行
MySQL无法利用多核特性来并行执行查询。很多其他的关系型数据库鞥能够提供这个特性，但MySQL做不到。这里特别指出是想提醒大家不要花时间去尝试寻找并行执行查询的方法。

6 哈希关联
在2013年MySQL并不执行哈希关联，MySQL的所有关联都是嵌套循环关联。不过可以通过建立一个哈希索引来曲线实现哈希关联如果使用的是Memory引擎，则索引都是哈希索引，所以关联的时候也类似于哈希关联。另外MariaDB已经实现了哈希关联。

7 松散索引扫描
由于历史原因，MySQL并不支持松散索引扫描，也就无法按照不连续的方式扫描一个索引。通常，MySQL的索引扫描需要先定义一个起点和重点，即使需要的数据只是这段索引中很少的几个，MySQL仍需要扫描这段索引中每个条目。

例：现有索引（a,b）

select * from table where b between 2 and 3;

因为索引的前导字段是a，但是在查询中只指定了字段b，MySQL无法使用这个索引，从而只能通过全表扫描找到匹配的行。

MySQL全表扫描：


了解索引的物理结构的话，不难发现还可以有一个更快的办法执行上面的查询。索引的物理结构不是存储引擎的API使得可以先扫描a列第一个值对应的b列的范围，然后在跳到a列第二个不同值扫描对应的b列的范围



这时就无需在使用where子句过滤，因为松散索引扫描已经跳过了所有不需要的记录。

上面是一个简单的例子，处理松散索引扫描，新增一个合适的索引当然也可以优化上述查询。但对于某些场景，增加索引是没用的，例如，对于第一个索引列是范围条件，第二个索引列是等值提交建查询，靠增加索引就无法解决问题。

MySQL5.6之后，关于松散索引扫描的一些限制将会通过索引条件吓退的分行是解决。

8 最大值和最小值优化
对于MIN()和MAX()查询，MySQL的优化做的并不好，例：

select min(actor_id) from actor where first_name = 'wang'
因为在first_name字段上并没有索引，因此MySQL将会进行一次全表扫描。如果MySQL能够进行主键扫描，那么理论上，当MySQL读到第一个太满足条件的记录的时候就是我们需要的最小值了，因为主键是严哥按照actor_id字段的大小排序的。但是MySSQL这时只会做全表扫描，我们可以通过show status的全表扫描计数器来验证这一点。一个区县优化办法就是移除min()函数，然后使用limit 1来查询。

这个策略可以让MySQL扫描尽可能少的记录数。这个例子告诉我们有时候为了获得更高的性能，就得放弃一些原则。

9 在同一个表上查询和更新
MySQL不允许对同一张表同时进行查询和更新。这并不是优化器的限制，如果清楚MySQL是如何执行查询的，就可以避免这种情况。例：

update table set cnt = (select count(*) from table as tb where tb.type = table.type);
这个sql虽然符合标准单无法执行，我们可以通过使用生成表的形式绕过上面的限制，因为MySQL只会把这个表当做一个临时表来处理。

update table inner join
(select type,count(*) as cnt from table group by type) as tb using(type)
set table.cnt = tb.cnt;
实际上这执行了两个查询：一个是子查询中的select语句，另一个是夺标关联update，只是关联的表时一个临时表。子查询会在update语句打开表之前就完成，所以会正常执行。

10 查询优化器的提示（hint）
如果对优化器选择的执行计划不满意，可以使用优化器提供的几个提示（hint）来控制最终的执行计划。下面将列举一些常见的提示，并简单的给出什么时候使用该提示。通过在查询中加入响应的提示，就可以控制该查询的执行计划。

① HIGH_PRIORITY 和 LOW_PRIORITY

这个提示告诉MySQL，当多个语句同时访问某一表的时候，哪些语句的优先级相对高些，哪些语句优先级相对低些。

HIGH_PRIORITY用于select语句的时候，MySQL会将此select语句重新调度到所有正在表锁以便修改数据的语句之前。实际上MySQL是将其放在表的队列的最前面，而不是按照常规顺序等待。HIGH_PRIORITY还可以用于insert语句，其效果只是简单的体校了全局LOW_PRIORITY设置对该语句的影响。

LOW_PRIORITY则正好相反，它会让语句一直处于等待状态，只要在队列中有对同一表的访问，就会一直在队尾等待。在CRUD语句中都可以使用。

这两个提示只对使用表锁的存储引擎有效，不能在InnoDB或其他有细粒度所机制和并发控制的引擎中使用。在MyISAM中也要慎用，因为这两个提示会导致并发插入被禁用，可能会严重降低性能。

HIGH_PRIORITY和LOW_PRIORITY其实只是简单的控制了MySQL访问某个数据表的队列顺序。

② DELAYED

这个提示对insert和replace有效。MySSQL会将使用该提示的语句立即返回给客户端，并将插入的行数据放入缓冲区，然后在表空闲时批量将数据写入。日志型系统使用这样的提示非常有效，或者是其他需要写入大量数据但是客户端却不需要等待单条语句完成I/O的应用。这个用法有一些限制。并不是所有的存储引擎都支持，并且该提示会导致函数last_insert_id()无法正常工作。

③ STRAIGHT_JOIN

这个提示可以防止在select语句的select关键字之后，也可以防止在任何两个关联表的名字之间。第一个用法是让查询中所有的表按照在语句中出现的顺序进行关联。第二个用法则是固定其前后两个表的关联顺序。

当MySQL没能选择正确的关联顺序的时候，或者由于可能的顺序太多导致MySQL无法评估所有的关联顺序的时候，STRAIGHT_JOIN都会很有用，在MySQL可能会发给大量时间在statistics状态时，加上这个提示则会大大减少优化器的搜索空间

④ SQL_SMALLRESULT和SQL_BIG_RESULT

这个两个提示只对select语句有效。他们告诉优化器对group by或者distinct查询如何使用临时表及排序。SQL_SMALL_RESULT告诉优化器结果集会很小，可以将结果集放在内存中的索引临时表，以避免排序操作。如果是SQL_BIG_RESULT，则会告诉优化器结果集可能会非常大，建议使用磁盘临时表做排序操作。

⑤ SQL_BUFFER_RESULT

这个提示告诉优化器将查询结果放入一个临时表，然后尽可能快速释放表锁。这和前面提到的由客户端缓存结果不同。当你无法使用客户端缓存的时候，使用服务器端的缓存通常很有效。好处是无需在客户端上消耗过多内存，还能尽快释放表锁。代价是服务器端将需要更多的内存。

⑥ SQL_CACHE和SQL_NO_CACHE

这个提示告诉MySQL这个结果集是否应该放入查询缓存中。

⑦ SQL_CALC_FOUND_ROWS

严哥来说，这并不是一个优化器提示。它不会告诉优化器任何关于执行计划的东西。它会让MySQL返回的结果集包含更多的信息。查询中加上该提示MySQL会计算limit子句之后这个查询要返回的结果集总数，而实际上值返回limit要求的结果集。可以通过函数found_row()获得这个值。慎用，后面会说明为什么。

⑧ FOR UPDATE和LOCK IN SHARE MODE

这两个提示主要控制select语句的锁机制，但只对实现了行级锁的存储引擎有效。使用该提示会对符合查询条件的数据行加锁。对于insert/select语句是不需要这两个提示的因为5.0以后会默认给这些记录加上读锁。

唯一内置的支持这两个提示的引擎就是InnoDB，可以禁用该默认行为。另外需要记住的是，这两个提示会让某些优化无法正常使用，例如索引覆盖扫描。InnoDB不能在不访问主键的情况下排他的锁定行，因为行的版本信息保存在主键中。

如果这两个提示被经常滥用，很容易早晨服务器的锁争用问题。

⑨ USE INDEX、IGNORE INDEX和FORCE INDEX

这几个提示会告诉优化器使用或者不使用那些索引来查询记录。

在5.0版本以后新增了一些参数来控制优化器的行为：

① optimizer_search_depth

这个参数控制优化器在穷举执行计划时的限度。如果查询长时间处于statistics状态，那么可以考虑调低此参数。

② optimizer_prune_level

该参数默认是打开的，这让优化器会根据需要扫描的行数来决定是否跳过某些执行计划。

③optimizer_switch

这个变量包含了一些开启/关闭优化器特性的标志位。

前面两个参数时用来控制优化器可以走的一些捷径。这些捷径可以让优化器在处理非常复杂的SQL语句时，可以更高效，但也可能让优化器错过一些真正最优的执行计划，所以慎用。

修改优化器提示可能在MySQL更新后让新版的优化策略失效，所以一定要谨慎
