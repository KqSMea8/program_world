SELECT
UPSERT VALUES
UPSERT SELECT
DELETE
DECLARE CURSOR
OPEN CURSOR
FETCH NEXT
CLOSE
CREATE TABLE
DROP TABLE
CREATE FUNCTION
DROP FUNCTION
CREATE VIEW
DROP VIEW
CREATE SEQUENCE
DROP SEQUENCE
ALTER
CREATE INDEX
DROP INDEX
ALTER INDEX
EXPLAIN
UPDATE STATISTICS
CREATE SCHEMA
USE
DROP SCHEMA
GRANT
REVOKE
Other Grammar
Constraint
Options
Hint
Scan Hint
Cache Hint
Index Hint
Small Hint
Seek To Column Hint
Join Hint
Serial Hint
Column Def
Table Ref
Sequence Ref
Column Ref
Select Expression
Select Statement
Split Point
Table Spec
Aliased Table Ref
Join Type
Func Argument
Class Name
Jar Path
Order
Expression
And Condition
Boolean Condition
Condition
RHS Operand
Operand
Summand
Factor
Term
Array Constructor
Sequence
Cast
Row Value Constructor
Bind Parameter
Value
Case
Case When
Name
Quoted Name
Alias
Null
Data Type
SQL Data Type
HBase Data Type
String
Boolean
Numeric
Int
Long
Decimal
Number
Comments
SELECT
selectStatement

UNION ALL selectStatement

...


ORDER BY order

, ...

LIMIT
bindParameter
number


OFFSET
bindParameter
number

ROW
ROWS

FETCH
FIRST
NEXT
bindParameter
number
ROW
ROWS
ONLY
Selects data from one or more tables. UNION ALL combines rows from multiple select statements. ORDER BY sorts the result based on the given expressions. LIMIT(or FETCH FIRST) limits the number of rows returned by the query with no limit applied if unspecified or specified as null or less than zero. The LIMIT(or FETCH FIRST) clause is executed after the ORDER BY clause to support top-N type queries. OFFSET clause skips that many rows before beginning to return rows. An optional hint may be used to override decisions made by the query optimizer.

Example:

SELECT * FROM TEST LIMIT 1000;
SELECT * FROM TEST LIMIT 1000 OFFSET 100;
SELECT full_name FROM SALES_PERSON WHERE ranking >= 5.0
    UNION ALL SELECT reviewer_name FROM CUSTOMER_REVIEW WHERE score >= 8.0

UPSERT VALUES
UPSERT INTO tableName

(
columnRef
columnDef

, ...
)
VALUES ( constantTerm

, ...
)


ON DUPLICATE KEY
IGNORE
UPDATE columnRef = operand
Inserts if not present and updates otherwise the value in the table. The list of columns is optional and if not present, the values will map to the column in the order they are declared in the schema. The values must evaluate to constants.

Use the ON DUPLICATE KEY clause (available in Phoenix 4.9) if you need the UPSERT to be atomic. Performance will be slower in this case as the row needs to be read on the server side when the commit is done. Use IGNORE if you do not want the UPSERT performed if the row already exists. Otherwise, with UPDATE, the expression will be evaluated and the result used to set the column, for example to perform an atomic increment. An UPSERT to the same row in the same commit batch will be processed in the order of execution.

Example:

UPSERT INTO TEST VALUES('foo','bar',3);
UPSERT INTO TEST(NAME,ID) VALUES('foo',123);
UPSERT INTO TEST(ID, COUNTER) VALUES(123, 0) ON DUPLICATE KEY UPDATE COUNTER = COUNTER + 1;
UPSERT INTO TEST(ID, MY_COL) VALUES(123, 0) ON DUPLICATE KEY IGNORE;

UPSERT SELECT
UPSERT

/ * + hint * /
INTO tableName

(
columnRef
columnDef

, ...
)
select
Inserts if not present and updates otherwise rows in the table based on the results of running another query. The values are set based on their matching position between the source and target tables. The list of columns is optional and if not present will map to the column in the order they are declared in the schema. If auto commit is on, and both a) the target table matches the source table, and b) the select performs no aggregation, then the population of the target table will be done completely on the server-side (with constraint violations logged, but otherwise ignored). Otherwise, data is buffered on the client and, if auto commit is on, committed in row batches as specified by the UpsertBatchSize connection property (or the phoenix.mutate.upsertBatchSize HBase config property which defaults to 10000 rows)

Example:

UPSERT INTO test.targetTable(col1, col2) SELECT col3, col4 FROM test.sourceTable WHERE col5 < 100
UPSERT INTO foo SELECT * FROM bar;

DELETE
DELETE

/ * + hint * /
FROM tableName

WHERE expression


ORDER BY order

, ...

LIMIT
bindParameter
number
Deletes the rows selected by the where clause. If auto commit is on, the deletion is performed completely server-side.

Example:

DELETE FROM TEST;
DELETE FROM TEST WHERE ID=123;
DELETE FROM TEST WHERE NAME LIKE 'foo%';

DECLARE CURSOR
DECLARE CURSOR cursorName FOR selectStatement
Creates a cursor for the select statement

Example:

DECLARE CURSOR TEST_CURSOR FOR SELECT * FROM TEST_TABLE

OPEN CURSOR
OPEN CURSOR cursorName
Opens already declared cursor to perform FETCH operations

Example:

OPEN CURSOR TEST_CURSOR

FETCH NEXT
FETCH NEXT

n ROWS
FROM cursorName
Retrieves next or next n rows from already opened cursor

Example:

FETCH NEXT FROM TEST_CURSOR
FETCH NEXT 10 ROWS FROM TEST_CURSOR

CLOSE
CLOSE cursorName
Closes an already open cursor

Example:

CLOSE TEST_CURSOR

CREATE TABLE
CREATE TABLE

IF NOT EXISTS
tableRef

( columnDef

, ...

constraint
)


tableOptions

SPLIT ON ( splitPoint

, ...
)
Creates a new table. The HBase table and any column families referenced are created if they don't already exist. All table, column family and column names are uppercased unless they are double quoted in which case they are case sensitive. Column families that exist in the HBase table but are not listed are ignored. At create time, to improve query performance, an empty key value is added to the first column family of any existing rows or the default column family if no column families are explicitly defined. Upserts will also add this empty key value. This improves query performance by having a key value column we can guarantee always being there and thus minimizing the amount of data that must be projected and subsequently returned back to the client. HBase table and column configuration options may be passed through as key/value pairs to configure the HBase table as desired. Note that when using the IF NOT EXISTS clause, if a table already exists, then no change will be made to it. Additionally, no validation is done to check whether the existing table metadata matches the proposed table metadata. so it's better to use DROP TABLE followed by CREATE TABLE is the table metadata may be changing.

Example:

CREATE TABLE my_schema.my_table ( id BIGINT not null primary key, date)
CREATE TABLE my_table ( id INTEGER not null primary key desc, date DATE not null,
    m.db_utilization DECIMAL, i.db_utilization)
    m.DATA_BLOCK_ENCODING='DIFF'
CREATE TABLE stats.prod_metrics ( host char(50) not null, created_date date not null,
    txn_count bigint CONSTRAINT pk PRIMARY KEY (host, created_date) )
CREATE TABLE IF NOT EXISTS "my_case_sensitive_table"
    ( "id" char(10) not null primary key, "value" integer)
    DATA_BLOCK_ENCODING='NONE',VERSIONS=5,MAX_FILESIZE=2000000 split on (?, ?, ?)
CREATE TABLE IF NOT EXISTS my_schema.my_table (
    org_id CHAR(15), entity_id CHAR(15), payload binary(1000),
    CONSTRAINT pk PRIMARY KEY (org_id, entity_id) )
    TTL=86400

DROP TABLE
DROP TABLE

IF EXISTS
tableRef

CASCADE
Drops a table. The optional CASCADE keyword causes any views on the table to be dropped as well. When dropping a table, by default the underlying HBase data and index tables are dropped. The phoenix.schema.dropMetaData may be used to override this and keep the HBase table for point-in-time queries.

Example:

DROP TABLE my_schema.my_table;
DROP TABLE IF EXISTS my_table;
DROP TABLE my_schema.my_table CASCADE;

CREATE FUNCTION
CREATE

TEMPORARY
FUNCTION funcName

(

funcArgument

, ...
)

RETURNS dataType AS className

USING JAR jarPath
Creates a new function. The function name is uppercased unless they are double quoted in which case they are case sensitive. The function accepts zero or more arguments. The class name and jar path should be in single quotes. The jar path is optional and if not specified then the class name will be loaded from the jars present in directory configured for hbase.dynamic.jars.dir.

Example:

CREATE FUNCTION my_reverse(varchar) returns varchar as 'com.mypackage.MyReverseFunction' using jar 'hdfs:/localhost:8080/hbase/lib/myjar.jar'
CREATE FUNCTION my_reverse(varchar) returns varchar as 'com.mypackage.MyReverseFunction'
CREATE FUNCTION my_increment(integer, integer constant defaultvalue='10') returns integer as 'com.mypackage.MyIncrementFunction' using jar '/hbase/lib/myincrement.jar'
CREATE TEMPORARY FUNCTION my_reverse(varchar) returns varchar as 'com.mypackage.MyReverseFunction' using jar 'hdfs:/localhost:8080/hbase/lib/myjar.jar'

DROP FUNCTION
DROP FUNCTION

IF EXISTS
funcName
Drops a function.

Example:

DROP FUNCTION IF EXISTS my_reverse
DROP FUNCTION my_reverse

CREATE VIEW
CREATE VIEW

IF NOT EXISTS
newTableRef


( columnDef

, ...
)


AS SELECT * FROM existingTableRef

WHERE expression


tableOptions
Creates a new view over an existing HBase or Phoenix table. As expected, the WHERE expression is always automatically applied to any query run against the view. As with CREATE TABLE, the table, column family, and column names are uppercased unless they are double quoted. The newTableRef may refer directly to an HBase table, in which case, the table, column family, and column names must match the existing metadata exactly or an exception will occur. When a view is mapped directly to an HBase table, no empty key value will be added to rows and the view will be read-only. A view will be updatable (i.e. referenceable in a DML statement such as UPSERT or DELETE) if its WHERE clause expression contains only simple equality expressions separated by ANDs. Updatable views are not required to set the columns which appear in the equality expressions, as the equality expressions define the default values for those columns. If they are set, then they must match the value used in the WHERE clause, or an error will occur. All columns from the existingTableRef are included as columns in the new view as are columns defined in the columnDef list. An ALTER VIEW statement may be issued against a view to remove or add columns, however, no changes may be made to the primary key constraint. In addition, columns referenced in the WHERE clause are not allowed to be removed. Once a view is created for a table, that table may no longer altered or dropped until all of its views have been dropped.

Example:

CREATE VIEW "my_hbase_table"
    ( k VARCHAR primary key, "v" UNSIGNED_LONG) default_column_family='a';
CREATE VIEW my_view ( new_col SMALLINT )
    AS SELECT * FROM my_table WHERE k = 100;
CREATE VIEW my_view_on_view
    AS SELECT * FROM my_view WHERE new_col > 70;

DROP VIEW
DROP VIEW

IF EXISTS
tableRef

CASCADE
Drops a view. The optional CASCADE keyword causes any views derived from the view to be dropped as well. When dropping a view, the actual table data is not affected. However, index data for the view will be deleted.

Example:

DROP VIEW my_view
DROP VIEW IF EXISTS my_schema.my_view
DROP VIEW IF EXISTS my_schema.my_view CASCADE

CREATE SEQUENCE
CREATE SEQUENCE

IF NOT EXISTS
sequenceRef


START

WITH
number
bindParameter

INCREMENT

BY
number
bindParameter


MINVALUE
number
bindParameter

MAXVALUE
number
bindParameter

CYCLE


CACHE
number
bindParameter
Creates a monotonically increasing sequence. START controls the initial sequence value while INCREMENT controls by how much the sequence is incremented after each call to NEXT VALUE FOR. By default, the sequence will start with 1 and be incremented by 1. Specify CYCLE to indicate that the sequence should continue to generate values after reaching either its MINVALUE or MAXVALUE. After an ascending sequence reaches its MAXVALUE, it generates its MINVALUE. After a descending sequence reaches its MINVALUE, it generates its MAXVALUE. CACHE controls how many sequence values will be reserved from the server, cached on the client, and doled out as need by subsequent NEXT VALUE FOR calls for that client connection to the cluster to save on RPC calls. If not specified, the phoenix.sequence.cacheSize config parameter defaulting to 100 will be used for the CACHE value.

Example:

CREATE SEQUENCE my_sequence;
CREATE SEQUENCE my_sequence START WITH -1000
CREATE SEQUENCE my_sequence INCREMENT BY 10
CREATE SEQUENCE my_schema.my_sequence START 0 CACHE 10

DROP SEQUENCE
DROP SEQUENCE

IF EXISTS
sequenceRef
Drops a sequence.

Example:

DROP SEQUENCE my_sequence
DROP SEQUENCE IF EXISTS my_schema.my_sequence

ALTER
ALTER
TABLE
VIEW
tableRef
ADD

IF NOT EXISTS
columnDef

, ...

options
DROP COLUMN

IF EXISTS
columnRef

, ...
SET options
Alters an existing table by adding or removing columns or updating table options. When a column is dropped from a table, the data in that column is deleted as well. PK columns may not be dropped, and only nullable PK columns may be added. For a view, the data is not affected when a column is dropped. Note that creating or dropping columns only affects subsequent queries and data modifications. Snapshot queries that are connected at an earlier timestamp will still use the prior schema that was in place when the data was written.

Example:

ALTER TABLE my_schema.my_table ADD d.dept_id char(10) VERSIONS=10
ALTER TABLE my_table ADD dept_name char(50), parent_id char(15) null primary key
ALTER TABLE my_table DROP COLUMN d.dept_id, parent_id;
ALTER VIEW my_view DROP COLUMN new_col;
ALTER TABLE my_table SET IMMUTABLE_ROWS=true,DISABLE_WAL=true;

CREATE INDEX
CREATE

LOCAL
INDEX

IF NOT EXISTS
indexName

ON tableRef ( expression

ASC
DESC

, ...
)


INCLUDE ( columnRef

, ...
)


ASYNC


indexOptions

SPLIT ON ( splitPoint

, ...
)
Creates a new secondary index on a table or view. The index will be automatically kept in sync with the table as the data changes. At query time, the optimizer will use the index if it contains all columns referenced in the query and produces the most efficient execution plan. If a table has rows that are write-once and append-only, then the table may set the IMMUTABLE_ROWS property to true (either up-front in the CREATE TABLE statement or afterwards in an ALTER TABLE statement). This reduces the overhead at write time to maintain the index. Otherwise, if this property is not set on the table, then incremental index maintenance will be performed on the server side when the data changes. As of the 4.3 release, functional indexes are supported which allow arbitrary expressions rather than solely column names to be indexed. As of the 4.4.0 release, you can specify the ASYNC keyword to create the index using a map reduce job.

Example:

CREATE INDEX my_idx ON sales.opportunity(last_updated_date DESC)
CREATE INDEX my_idx ON log.event(created_date DESC) INCLUDE (name, payload) SALT_BUCKETS=10
CREATE INDEX IF NOT EXISTS my_comp_idx ON server_metrics ( gc_time DESC, created_date DESC )
    DATA_BLOCK_ENCODING='NONE',VERSIONS=?,MAX_FILESIZE=2000000 split on (?, ?, ?)
CREATE INDEX my_idx ON sales.opportunity(UPPER(contact_name))

DROP INDEX
DROP INDEX

IF EXISTS
indexName ON tableRef
Drops an index from a table. When dropping an index, the data in the index is deleted. Note that since metadata is versioned, snapshot queries connecting at an earlier time stamp may still use the index, as the HBase table backing the index is not deleted.

Example:

DROP INDEX my_idx ON sales.opportunity
DROP INDEX IF EXISTS my_idx ON server_metrics

ALTER INDEX
ALTER INDEX

IF EXISTS
indexName ON tableRef
DISABLE
REBUILD
UNUSABLE
USABLE
Alters the state of an existing index.  DISABLE will cause the no further index maintenance to be performed on the index and it will no longer be considered for use in queries. REBUILD will completely rebuild the index and upon completion will enable the index to be used in queries again. UNUSABLE will cause the index to no longer be considered for use in queries, however index maintenance will continue to be performed. USABLE will cause the index to again be considered for use in queries. Note that a disabled index must be rebuild and cannot be set as USABLE.

Example:

ALTER INDEX my_idx ON sales.opportunity DISABLE
ALTER INDEX IF EXISTS my_idx ON server_metrics REBUILD

EXPLAIN
EXPLAIN
select
upsertSelect
delete
Computes the logical steps necessary to execute the given command. Each step is represented as a string in a single column result set row.

Example:

EXPLAIN SELECT NAME, COUNT(*) FROM TEST GROUP BY NAME HAVING COUNT(*) > 2;
EXPLAIN SELECT entity_id FROM CORE.CUSTOM_ENTITY_DATA WHERE organization_id='00D300000000XHP' AND SUBSTR(entity_id,1,3) = '002' AND created_date < CURRENT_DATE()-1;

UPDATE STATISTICS
UPDATE STATISTICS tableRef

ALL
INDEX
COLUMNS

SET guidepostOptions
Updates the statistics on the table and by default all of its associated index tables. To only update the table, use the COLUMNS option and to only update the INDEX, use the INDEX option. The statistics for a single index may also be updated by using its full index name for the tableRef. The default guidepost properties may be overridden by specifying their values after the SET keyword. Note that when a major compaction occurs, the default guidepost properties will be used again.

Example:

UPDATE STATISTICS my_table
UPDATE STATISTICS my_schema.my_table INDEX
UPDATE STATISTICS my_index
UPDATE STATISTICS my_table COLUMNS
UPDATE STATISTICS my_table SET phoenix.stats.guidepost.width=50000000

CREATE SCHEMA
CREATE SCHEMA

IF NOT EXISTS
schemaName
creates a schema and corresponding name-space in hbase. To enable namespace mapping, see https://phoenix.apache.org/tuning.html

User that execute this command should have admin permissions to create namespace in HBase.

Example:

CREATE SCHEMA IF NOT EXISTS my_schema
CREATE SCHEMA my_schema

USE
USE
schemaName
DEFAULT
Sets a default schema for the connection and is used as a target schema for all statements issued from the connection that do not specify schema name explicitly. USE DEFAULT unset the schema for the connection so that no schema will be used for the statements issued from the connection.

schemaName should already be existed for the USE SCHEMA statement to succeed. see CREATE SCHEMA for creating schema.

Example:

USE my_schema
USE DEFAULT

DROP SCHEMA
DROP SCHEMA

IF EXISTS
schemaName
Drops a schema and corresponding name-space from hbase. To enable namespace mapping, see https://phoenix.apache.org/tuning.html

This statement succeed only when schema doesn't hold any tables.

Example:

DROP SCHEMA IF EXISTS my_schema
DROP SCHEMA my_schema

GRANT
GRANT permissionString

ON

SCHEMA schemaName
tableName
TO

GROUP
userString
Grant permissions at table, schema or user level. Permissions are managed by HBase in hbase:acl table, hence access controls need to be enabled. This feature will be available from Phoenix 4.14 version onwards.

Possible permissions are R - Read, W - Write, X - Execute, C - Create and A - Admin. To enable/disable access controls, see https://hbase.apache.org/book.html#hbase.accesscontrol.configuration

Permissions should be granted on base tables. It will be propagated to all its indexes and views. Group permissions are applicable to all users in the group and schema permissions are applicable to all tables with that schema. Grant statements without table/schema specified are assigned at GLOBAL level.

Phoenix doesn't expose Execute('X') functionality to end users. However, it is required for mutable tables with secondary indexes.

Important Note:

Every user requires 'RX' permissions on all Phoenix SYSTEM tables in order to work correctly. Users also require 'RWX' permissions on SYSTEM.SEQUENCE table for using SEQUENCES.

Example:

GRANT 'RXC' TO 'User1'
GRANT 'RWXC' TO GROUP 'Group1'
GRANT 'A' ON Table1 TO 'User2'
GRANT 'RWX' ON my_schema.my_table TO 'User2'
GRANT 'A' ON SCHEMA my_schema TO 'User3'

REVOKE
REVOKE

ON

SCHEMA schemaName
tableName
FROM

GROUP
userString
Revoke permissions at table, schema or user level. Permissions are managed by HBase in hbase:acl table, hence access controls need to be enabled. This feature will be available from Phoenix 4.14 version onwards.

To enable/disable access controls, see https://hbase.apache.org/book.html#hbase.accesscontrol.configuration

Group permissions are applicable to all users in the group and schema permissions are applicable to all tables with that schema. Permissions should be revoked on base tables. It will be propagated to all its indexes and views. Revoke statements without table/schema specified are assigned at GLOBAL level.

Revoke removes all the permissions at that level.

Important Note:

Revoke permissions needs to be exactly at the same level as permissions assigned via Grant permissions statement. Level refers to table, schema or user. Revoking any of 'RX' permissions on any Phoenix SYSTEM tables will cause exceptions. Revoking any of 'RWX' permissions on SYSTEM.SEQUENCE will cause exceptions while accessing sequences.

The examples below are for revoking permissions granted using the examples from GRANT statement above.

Example:

REVOKE FROM 'User1'
REVOKE FROM GROUP 'Group1'
REVOKE ON Table1 FROM 'User2'
REVOKE ON my_schema.my_table FROM 'User2'
REVOKE ON SCHEMA my_schema FROM 'User3'

Constraint
CONSTRAINT constraintName PRIMARY KEY ( columnName

ASC
DESC

ROW_TIMESTAMP

, ...
)
Defines a multi-part primary key constraint. Each column may be declared to be sorted in ascending or descending ordering. The default is ascending. One primary key column can also be designated as ROW_TIMESTAMP provided it is of one of the types: BIGINT, UNSIGNED_LONG, DATE, TIME and TIMESTAMP.

Example:

CONSTRAINT my_pk PRIMARY KEY (host,created_date)
CONSTRAINT my_pk PRIMARY KEY (host ASC,created_date DESC)
CONSTRAINT my_pk PRIMARY KEY (host ASC,created_date DESC ROW_TIMESTAMP)

Options

familyName .
name = value

, ...
Sets a built-in Phoenix table property or an HBase table or column descriptor metadata attribute. The name is case insensitive. If the name is a known HColumnDescriptor attribute, then the value is applied to the specified column family or, if omitted, to all column families. Otherwise, the HBase metadata attribute value is applied to the HTableDescriptor. Note that no validation is performed on the property name or value, so unknown or misspelled options will end up as adhoc metadata attributes values on the HBase table.

Built-in Phoenix table options include:

SALT_BUCKETS numeric property causes an extra byte to be transparently prepended to every row key to ensure an evenly distributed read and write load across all region servers. This is especially useful when your row key is always monotonically increasing and causing hot spotting on a single region server. However, even if it's not, it often improves performance by ensuring an even distribution of data across your cluster.  The byte is determined by hashing the row key and modding it with the SALT_BUCKETS value. The value may be from 0 to 256, with 0 being a special means of turning salting off for an index in which the data table is salted (since by default an index has the same number of salt buckets as its data table). If split points are not defined for the table, the table will automatically be pre-split at each possible salt bucket value. For more information, see http://phoenix.incubator.apache.org/salted.html

DISABLE_WAL boolean option when true causes HBase not to write data to the write-ahead-log, thus making updates faster at the expense of potentially losing data in the event of a region server failure. This option is useful when updating a table which is not the source-of-truth and thus making the lose of data acceptable.

IMMUTABLE_ROWS boolean option when true declares that your table has rows which are write-once, append-only (i.e. the same row is never updated). With this option set, indexes added to the table are managed completely on the client-side, with no need to perform incremental index maintenance, thus improving performance. Deletes of rows in immutable tables are allowed with some restrictions if there are indexes on the table. Namely, the WHERE clause may not filter on columns not contained by every index. Upserts are expected to never update an existing row (failure to follow this will result in invalid indexes). For more information, see http://phoenix.incubator.apache.org/secondary_indexing.html

MULTI_TENANT boolean option when true enables views to be created over the table across different tenants. This option is useful to share the same physical HBase table across many different tenants. For more information, see http://phoenix.incubator.apache.org/multi-tenancy.html

DEFAULT_COLUMN_FAMILY string option determines the column family used used when none is specified. The value is case sensitive. If this option is not present, a column family name of '0' is used.

STORE_NULLS boolean option (available as of Phoenix 4.3) determines whether or not null values should be explicitly stored in HBase. This option is generally only useful if a table is configured to store multiple versions in order to facilitate doing flashback queries (i.e. queries to look at the state of a record in the past).

TRANSACTIONAL option (available as of Phoenix 4.7) determines whether a table (and its secondary indexes) are tranactional. The default value is FALSE, but may be overriden with the phoenix.table.istransactional.default property. A table may be altered to become transactional, but it cannot be transitioned back to be non transactional. For more information on transactions, see http://phoenix.apache.org/transactions.html

UPDATE_CACHE_FREQUENCY option (available as of Phoenix 4.7) determines how often the server will be checked for meta data updates (for example, the addition or removal of a table column or the updates of table statistics). Possible values are ALWAYS (the default), NEVER, and a millisecond numeric value. An ALWAYS value will cause the client to check with the server each time a statement is executed that references a table (or once per commit for an UPSERT VALUES statement).  A millisecond value indicates how long the client will hold on to its cached version of the metadata before checking back with the server for updates.

APPEND_ONLY_SCHEMA boolean option (available as of Phoenix 4.8) when true declares that columns will only be added but never removed from a table. With this option set we can prevent the RPC from the client to the server to fetch the table metadata when the client already has all columns declared in a CREATE TABLE/VIEW IF NOT EXISTS statement.

AUTO_PARTITION_SEQ string option (available as of Phoenix 4.8) when set on a base table determines the sequence used to automatically generate a WHERE clause with the first PK column and the unique identifier from the sequence for child views. With this option set, we prevent allocating a sequence in the event that the view already exists.

The GUIDE_POSTS_WIDTH option (available as of Phoenix 4.9) enables specifying a different guidepost width per table. The guidepost width determines the byte sized chunk of work over which a query will be parallelized. A value of 0 means that no guideposts should be collected for the table. A value of null removes any table specific guidepost setting, causing the global server-side phoenix.stats.guidepost.width config parameter to be used again. For more information, see the Statistics Collection page.

Example:

IMMUTABLE_ROWS=true
DEFAULT_COLUMN_FAMILY='a'
SALT_BUCKETS=10
DATA_BLOCK_ENCODING='NONE',a.VERSIONS=10
MAX_FILESIZE=2000000000,MEMSTORE_FLUSHSIZE=80000000
UPDATE_CACHE_FREQUENCY=300000
GUIDE_POSTS_WIDTH=30000000
CREATE SEQUENCE id;
CREATE TABLE base_table (partition_id INTEGER, val DOUBLE) AUTO_PARTITION_SEQ=id;
CREATE VIEW my_view AS SELECT * FROM base_table;
The view statement for my_view will be : WHERE partition_id =  1

Hint
scanHint
indexHint
cacheHint
smallHint
joinHint
seekToColumnHint
serialHint

, ...
An advanced features that overrides default query processing behavior for decisions such as whether to use a range scan versus skip scan and an index versus no index. Note that strict parsing is not done on hints. If hints are misspelled or invalid, they are silently ignored.

Example:

SKIP_SCAN,NO_INDEX
USE_SORT_MERGE_JOIN
NO_CACHE
INDEX(employee emp_name_idx emp_start_date_idx)
SMALL

Scan Hint
SKIP_SCAN
RANGE_SCAN
Use the SKIP_SCAN hint to force a skip scan to be performed on the query when it otherwise would not be. This option may improve performance if a query does not include the leading primary key column, but does include other, very selective primary key columns.

Use the RANGE_SCAN hint to force a range scan to be performed on the query. This option may improve performance if a query filters on a range for non selective leading primary key column along with other primary key columns

Example:

SKIP_SCAN
RANGE_SCAN

Cache Hint
NO_CACHE
Use the NO_CACHE hint to prevent the results of the query from populating the HBase block cache. This is useful in situation where you're doing a full table scan and know that it's unlikely that the rows being returned will be queried again.

Example:

NO_CACHE

Index Hint
INDEX
NO_INDEX
USE_INDEX_OVER_DATA_TABLE
USE_DATA_OVER_INDEX_TABLE
Use the INDEX(<table_name> <index_name>...) to suggest which index to use for a given query. Double quotes may be used to surround a table_name and/or index_name to make them case sensitive. As of the 4.3 release, this will force an index to be used, even if it doesn't contain all referenced columns, by joining back to the data table to retrieve any columns not contained by the index.

Use the NO_INDEX hint to force the data table to be used for a query.

Use the USE_INDEX_OVER_DATA_TABLE hint to act as a tiebreaker for choosing the index table over the data table when all other criteria are equal. Note that this is the default optimizer decision.

Use the USE_DATA_OVER_INDEX_TABLE hint to act as a tiebreaker for choosing the data table over the index table when all other criteria are equal.

Example:

INDEX(employee emp_name_idx emp_start_date_idx)
NO_INDEX
USE_INDEX_OVER_DATA_TABLE
USE_DATA_OVER_INDEX_TABLE

Small Hint
SMALL
Use the SMALL hint to reduce the number of RPCs done between the client and server when a query is executed. Generally, if the query is a point lookup or returns data that is likely in a single data block (64 KB by default), performance may improve when using this hint.

Example:

SMALL

Seek To Column Hint
SEEK_TO_COLUMN
NO_SEEK_TO_COLUMN
Use the SEEK_TO_COLUMN hint to force the server to seek to navigate between columns instead of doing a next. If there are many versions of the same column value or if there are many columns between the columns that are projected, then this may be more efficient.

Use the NO_SEEK_TO_COLUMN hint to force the server to do a next to navigate between columns instead of a seek. If there are few versions of the same column value or if the columns that are projected are adjacent to each other, then this may be more efficient.

Example:

SEEK_TO_COLUMN
NO_SEEK_TO_COLUMN

Join Hint
USE_SORT_MERGE_JOIN
NO_STAR_JOIN
NO_CHILD_PARENT_JOIN_OPTIMIZATION
Use the USE_SORT_MERGE_JOIN hint to force the optimizer to use a sort merge join instead of a broadcast hash join when both sides of the join are bigger than will fit in the server-side memory. Currently the optimizer will not make this determination itself, so this hint is required to override the default behavior of using a hash join.

Use the NO_STAR_JOIN hint to prevent the optimizer from using the star join query to broadcast the results of the querying one common table to all region servers. This is useful when the results of the querying the one common table is too large and would likely be substantially filtered when joined against one or more of the other joined tables.

Use the NO_CHILD_PARENT_JOIN_OPTIMIZATION hint to prevent the optimizer from doing point lookups between a child table (such as a secondary index) and a parent table (such as the data table) for a correlated subquery.

Example:

NO_STAR_JOIN

Serial Hint
SERIAL
Use the SERIAL hint to force a query to be executed serially as opposed to being parallelized along the guideposts and region boundaries.

Example:

SERIAL

Column Def
columnRef dataType


NOT
NULL

DEFAULT constantOperand


PRIMARY KEY

ASC
DESC

ROW_TIMESTAMP
Define a new primary key column. The column name is case insensitive by default and case sensitive if double quoted. The sort order of a primary key may be ascending (ASC) or descending (DESC). The default is ascending. You may also specify a default value (Phoenix 4.9 or above) for the column with a constant expression. If the column is the only column that forms the primary key, then it can be designated as ROW_TIMESTAMP column provided its data type is one of these: BIGINT, UNSIGNED_LONG, DATE, TIME and TIMESTAMP.

Example:

id char(15) not null primary key
key integer null
m.response_time bigint

created_date date not null primary key row_timestamp
key integer null
m.response_time bigint

Table Ref

schemaName .
tableName
References a table or view with an optional schema name qualifier

Example:

Sales.Contact
HR.Employee
Department

Sequence Ref

schemaName .
sequenceName
References a sequence with an optional schema name qualifier

Example:

my_id_generator
my_seq_schema.id_generator

Column Ref

familyName .
columnName
References a column with an optional family name qualifier

Example:

e.salary
dept_name

Select Expression
*
( familyName . * )
expression


AS
columnAlias
An expression in a SELECT statement. All columns in a table may be selected using *, and all columns in a column family may be selected using <familyName>.*.

Example:

*
cf.*
ID AS VALUE
VALUE + 1 VALUE_PLUS_ONE

Select Statement
SELECT

/ * + hint * /

DISTINCT
ALL
selectExpression

, ...

FROM tableSpec


joinType
JOIN tableSpec ON expression

...


WHERE expression


GROUP BY expression

, ...

HAVING expression
Selects data from a table. DISTINCT filters out duplicate results while ALL, the default, includes all results. FROM identifies the table being queried. Columns may be dynamically defined in parenthesis after the table name and then used in the query. Joins are processed in reverse order through a broadcast hash join mechanism. For best performance, order tables from largest to smallest in terms of how many rows you expect to be used from each table. GROUP BY groups the the result by the given expression(s). HAVING filters rows after grouping. An optional hint may be used to override decisions made by the query optimizer.

Example:

SELECT * FROM TEST;
SELECT DISTINCT NAME FROM TEST;
SELECT ID, COUNT(1) FROM TEST GROUP BY ID;
SELECT NAME, SUM(VAL) FROM TEST GROUP BY NAME HAVING COUNT(1) > 2;
SELECT d.dept_id,e.dept_id,e.name FROM DEPT d JOIN EMPL e ON e.dept_id = d.dept_id;

Split Point
value
bindParameter
Defines a split point for a table. Use a bind parameter with preparedStatement.setBinary(int,byte[]) to supply arbitrary bytes.

Example:

'A'

Table Spec
aliasedTableRef
( select )


AS
tableAlias
An optionally aliased table reference, or an optionally aliased select statement in paranthesis.

Example:

PRODUCT_METRICS AS PM
PRODUCT_METRICS(referrer VARCHAR)
( SELECT feature FROM PRODUCT_METRICS ) AS PM

Aliased Table Ref

schemaName .
tableName


AS
tableAlias

( columnDef

, ...
)


TABLESAMPLE ( positiveDecimal )
A reference to an optionally aliased table optionally followed by dynamic column definitions.

Example:

PRODUCT_METRICS AS PM
PRODUCT_METRICS(referrer VARCHAR)
PRODUCT_METRICS TABLESAMPLE (12.08)

Join Type
INNER
LEFT
RIGHT

OUTER
The type of join

Example:

INNER
LEFT OUTER
RIGHT

Func Argument
dataType

CONSTANT

DEFUALTVALUE = string

MINVALUE = string

MAXVALUE = string
The function argument is sql data type. It can be constant and also we can provide default,min and max values for the argument in single quotes.

Example:

VARCHAR
INTEGER DEFAULTVALUE='100'
INTEGER CONSTANT DEFAULTVALUE='10' MINVALUE='1' MAXVALUE='15'

Class Name
String
Canonical class name in single quotes.

Example:

'com.mypackage.MyReverseFunction'

Jar Path
String
Hdfs path of jar in single quotes.

Example:

'hdfs://localhost:8080:/hbase/lib/myjar.jar'
'/tmp/lib/myjar.jar'

Order
expression

ASC
DESC

NULLS
FIRST
LAST
Sorts the result by an expression.

Example:

NAME DESC NULLS LAST

Expression
andCondition

OR andCondition

...
Value or condition.

Example:

ID=1 OR NAME='Hi'

And Condition
booleanCondition

AND booleanCondition

...
Condition separated by AND.

Example:

FOO!='bar' AND ID=1

Boolean Condition

NOT
condition
Boolean condition.

Example:

ID=1 AND NAME='Hi'

Condition
operand

=
<
>
< =
> =
< >
! =
rhsOperand
LIKE
ILIKE
operand
IS

NOT
NULL

NOT
IN (
select
constantOperand

, ...
)
EXISTS ( select )
BETWEEN operand AND operand
Boolean value or condition. When comparing with LIKE, the wildcards characters are _ (any one character) and % (any characters). ILIKE is the same, but the search is case insensitive. To search for the characters % and _, the characters need to be escaped. The escape character is \ (backslash). Patterns that end with an escape character are invalid and the expression returns NULL. BETWEEN does an inclusive comparison for both operands.

Example:

FOO = 'bar'
NAME LIKE 'Jo%'
IN (1, 2, 3)
NOT EXISTS (SELECT 1 FROM FOO WHERE BAR < 10)
N BETWEEN 1 and 100

RHS Operand
operand
ANY
ALL
(
operand
select
)
Right-hand side operand

Example:

s.my_col
ANY(my_col + 1)
ALL(select foo from bar where bas > 5)

Operand
summand

|| summand

...
A string concatenation.

Example:

'foo'|| s

Summand
factor

+
-
factor

...
An addition or subtraction of numeric or date type values

Example:

a + b
a - b

Factor
term

*
/
%
term

...
A multiplication, division, or modulus of numeric type values.

Example:

c * d
e / 5
f % 10

Term
value
( expression )
bindParameter
Function
case
caseWhen

tableAlias .
columnRef
rowValueConstructor
cast
sequence
arrayConstructor

[ expression ]
A term which may use subscript notation if it's an array.

Example:

'Hello'
23
my_array[my_index]
array_col[1]

Array Constructor
ARRAY [ expression

, ...
]
Constructs an ARRAY out of the list of expressions.

Example:

ARRAY[1.0,2.2,3.3]
ARRAY['foo','bas']
ARRAY[col1,col2,col3+1,?]

Sequence
NEXT
CURRENT
VALUE
number VALUES
FOR sequenceRef
Gets the CURRENT or NEXT value for a sequence, a monotonically incrementing BIGINT value. Each call to NEXT VALUE FOR increments the sequence value and returns the current value. The NEXT <n> VALUES syntax may be used to reserve <n> consecutive sequence values. A sequence is only increment once for a given statement, so multiple references to the same sequence by NEXT VALUE FOR produce the same value. Use CURRENT VALUE FOR to access the last sequence allocated with NEXT VALUE FOR for cluster connection of your client. If no NEXT VALUE FOR had been previously called, an error will occur. These calls are only allowed in the SELECT expressions or UPSERT VALUES expressions.

Example:

NEXT VALUE FOR my_table_id
NEXT 5 VALUES FOR my_table_id
CURRENT VALUE FOR my_schema.my_id_generator

Cast
CAST ( expression AS dataType )
The CAST operator coerces the given expression to a different dataType. This is useful, for example, to convert a BIGINT or INTEGER to a DECIMAL or DOUBLE to prevent truncation to a whole number during arithmetic operations. It is also useful to coerce from a more precise type to a less precise type since this type of coercion will not automatically occur, for example from a TIMESTAMP to a DATE. If the coercion is not possible, an error will occur.

Example:

CAST ( my_int AS DECIMAL )
CAST ( my_timestamp AS DATE )

Row Value Constructor
( expression , expression

...
)
A row value constructor is a list of other terms which are treated together as a kind of composite structure. They may be compared to each other or to other other terms. The main use case is 1) to enable efficiently stepping through a set of rows in support of query-more type functionality, or 2) to allow IN clause to perform point gets on composite row keys.

Example:

(col1, col2, 5)

Bind Parameter
?
: number
A parameters can be indexed, for example :1 meaning the first parameter.

Example:

:1
?

Value
string
numeric
boolean
null
A literal value of any data type, or null.

Example:

10

Case
CASE term WHEN expression THEN term

...


ELSE expression
END
Returns the first expression where the value is equal to the test expression. If no else part is specified, return NULL.

Example:

CASE CNT WHEN 0 THEN 'No' WHEN 1 THEN 'One' ELSE 'Some' END

Case When
CASE WHEN expression THEN term

...


ELSE term
END
Returns the first expression where the condition is true. If no else part is specified, return NULL.

Example:

CASE WHEN CNT<10 THEN 'Low' ELSE 'High' END

Name
A-Z | _

A-Z | _
0-9

...
quotedName
Unquoted names are not case sensitive. There is no maximum name length.

Example:

my_column

Quoted Name
" anything "
Quoted names are case sensitive, and can contain spaces. There is no maximum name length. Two double quotes can be used to create a single double quote inside an identifier.

Example:

"first-name"

Alias
name
An alias is a name that is only valid in the context of the statement.

Example:

A

Null
NULL
NULL is a value without data type and means 'unknown value'.

Example:

NULL

Data Type
sqlDataType
hbaseDataType

ARRAY

[

dimensionInt
]
A type name optionally declared as an array. An array is mapped to java.sql.Array. Only single dimension arrays are supported and varbinary arrays are not allowed.

Example:

CHAR(15)
VARCHAR
DECIMAL(10,2)
DOUBLE
DATE
VARCHAR ARRAY
CHAR(10) ARRAY [5]
INTEGER []

SQL Data Type
charType
varcharType
decimalType
tinyintType
smallintType
integerType
bigintType
floatType
doubleType
timestampType
dateType
timeType
binaryType
varbinaryType
A standard SQL data type.

Example:

TINYINT
CHAR(15)
VARCHAR
VARCHAR(1000)
DECIMAL(10,2)
DOUBLE
INTEGER
BINARY(200)
DATE

HBase Data Type
unsignedTimestampType
unsignedDateType
unsignedTimeType
unsignedTinyintType
unsignedSmallintType
unsignedIntType
unsignedLongType
unsignedFloatType
unsignedDoubleType
A type that maps to a native primitive HBase value serialized through the Bytes.toBytes() utility methods. Only positive values are allowed.

Example:

UNSIGNED_INT
UNSIGNED_DATE
UNSIGNED_LONG

String
' anything '
A string starts and ends with a single quote. Two single quotes can be used to create a single quote inside a string.

Example:

'John''s car'

Boolean
TRUE
FALSE
A boolean value.

Example:

TRUE

Numeric
int
long
decimal
The data type of a numeric value is always the lowest possible for the given value. If the number contains a dot this is decimal; otherwise it is int, long, or decimal (depending on the value).

Example:

SELECT -10.05
SELECT 5
SELECT 12345678912345

Int

-
number
The maximum integer number is 2147483647, the minimum is -2147483648.

Example:

10

Long

-
number
Long numbers are between -9223372036854775808 and 9223372036854775807.

Example:

100000

Decimal

-
number

. number
A decimal number with fixed precision and scale. Internally, java.lang.BigDecimal is used.

Example:

SELECT -10.5

Number
0-9

...
The maximum length of the number depends on the data type used.

Example:

100

Comments
- - anything
/ / anything
/ * anything * /
Comments can be used anywhere in a command and are ignored by the database. Line comments end with a newline. Block comments cannot be nested, but can be multiple lines long.

Example:

// This is a comment

ABOUT
Overview
Who is Using
Recent Improvements
Roadmap
News
Performance
Team
Presentations
Mailing Lists
Source Repository
Issue Tracking
Download
Installation
How to Contribute
How to Develop
How to Update Website
How to Release
License
USING
F.A.Q.
Quick Start
Building
Tuning
Explain Plan
Configuration
Backward Compatibility
Release Notes
Performance Testing
Apache Spark Integration
Phoenix Storage Handler for Apache Hive
Apache Pig Integration
Map Reduce Integration
Apache Flume Plugin
Apache Kafka Plugin
Python Driver
FEATURES
Transactions
User-defined Functions
Secondary Indexes
Storage Formats
Atomic Upsert
Namespace Mapping
Statistics Collection
Row Timestamp Column
Paged Queries
Salted Tables
Skip Scan
Table Sampling
Views
Multi tenancy
Dynamic Columns
Bulk Loading
Query Server
Metrics
Tracing
Cursor
REFERENCE
Grammar
Functions
Datatypes
ARRAY type
Sequences
Joins
Subqueries
Explain Plan

Search Phoenix…
Back to top
Copyright ©2019 Apache Software Foundation. All Rights Reserved.




CREATE TABLE IF NOT EXISTS STOCK_SYMBOL (SYMBOL VARCHAR NOT NULL PRIMARY KEY, COMPANY VARCHAR);
UPSERT INTO STOCK_SYMBOL VALUES ('CRM','SalesForce.com');
SELECT * FROM STOCK_SYMBOL;

SELECT DOMAIN, AVG(CORE) Average_CPU_Usage, AVG(DB) Average_DB_Usage
FROM WEB_STAT
GROUP BY DOMAIN
ORDER BY DOMAIN DESC;

-- Sum, Min and Max CPU usage by Salesforce grouped by day
SELECT TRUNC(DATE,'DAY') DAY, SUM(CORE) TOTAL_CPU_Usage, MIN(CORE) MIN_CPU_Usage, MAX(CORE) MAX_CPU_Usage
FROM WEB_STAT
WHERE DOMAIN LIKE 'Salesforce%'
GROUP BY TRUNC(DATE,'DAY');

-- list host and total active users when core CPU usage is 10X greater than DB usage
SELECT HOST, SUM(ACTIVE_VISITOR) TOTAL_ACTIVE_VISITORS
FROM WEB_STAT
WHERE DB > (CORE * 10)
GROUP BY HOST;
CREATE TABLE IF NOT EXISTS WEB_STAT (
     HOST CHAR(2) NOT NULL,
     DOMAIN VARCHAR NOT NULL,
     FEATURE VARCHAR NOT NULL,
     DATE DATE NOT NULL,
     USAGE.CORE BIGINT,
     USAGE.DB BIGINT,
     STATS.ACTIVE_VISITOR INTEGER
     CONSTRAINT PK PRIMARY KEY (HOST, DOMAIN, FEATURE, DATE)
);


在Phoenix中是没有Insert语句的，取而代之的是Upsert语句。Upsert有两种用法，
分别是:upsert into 和 upsert select


upsert into:
类似于insert into的语句，旨在单条插入外部数据
upsert into tb values('ak','hhh',222)
upsert into tb(stat,city,num) values('ak','hhh',222)


upsert select：
类似于Hive中的insert select语句，旨在批量插入其他表的数据。
upsert into tb1 (state,city,population) select state,city,population from tb2 where population < 40000;
upsert into tb1 select state,city,population from tb2 where population > 40000;
upsert into tb1 select * from tb2 where population > 40000;
注意：在phoenix中插入语句并不会像传统数据库一样存在重复数据。
因为Phoenix是构建在HBase之上的，也就是必须存在一个主键。
后面插入的会覆盖前面的，但是时间戳不一样。




2.删除数据
delete from tb; 清空表中所有记录，Phoenix中不能使用truncate table tb；
delete from tb where city = 'kenai';
drop table tb;删除表
delete from system.catalog where table_name = 'int_s6a';
drop table if exists tb;
drop table my_schema.tb;
drop table my_schema.tb cascade;用于删除表的同时删除基于该表的所有视图。




3.修改数据
由于HBase的主键设计，相同rowkey的内容可以直接覆盖，这就变相的更新了数据。
所以Phoenix的更新操作仍旧是upsert into 和 upsert select
upsert into us_population (state,city,population) values('ak','juneau',40711);




4.查询数据
union all， group by， order by， limit 都支持
select * from test limit 1000;
select * from test limit 1000 offset 100;
select full_name from sales_person where ranking >= 5.0 union all select reviewer_name from customer_review where score >= 8.0




5.在Phoenix中是没有Database的概念的，所有的表都在同一个命名空间。但支持多个命名空间
设置为true，创建的带有schema的表将映射到一个namespace
<property>
   <name>phoenix.schema.isNamespaceMappingEnabled</name>
   <value>true</value>
</property>




6.创建表
A.SALT_BUCKETS(加盐)
加盐Salting能够通过预分区(pre-splitting)数据到多个region中来显著提升读写性能。
本质是在hbase中，rowkey的byte数组的第一个字节位置设定一个系统生成的byte值，
这个byte值是由主键生成rowkey的byte数组做一个哈希算法，计算得来的。
Salting之后可以把数据分布到不同的region上，这样有利于phoenix并发的读写操作。


SALT_BUCKETS的值范围在（1 ~ 256）：
create table test(host varchar not null primary key, description  varchar)salt_buckets=16;


upsert into test (host,description) values ('192.168.0.1','s1');
upsert into test (host,description) values ('192.168.0.2','s2');
upsert into test (host,description) values ('192.168.0.3','s3');


salted table可以自动在每一个rowkey前面加上一个字节，这样对于一段连续的rowkeys，它们在表中实际存储时，就被自动地分布到不同的region中去了。
当指定要读写该段区间内的数据时，也就避免了读写操作都集中在同一个region上。
简而言之，如果我们用Phoenix创建了一个saltedtable，那么向该表中写入数据时，
原始的rowkey的前面会被自动地加上一个byte（不同的rowkey会被分配不同的byte），使得连续的rowkeys也能被均匀地分布到多个regions。


B.Pre-split（预分区）
Salting能够自动的设置表预分区，但是你得去控制表是如何分区的，
所以在建phoenix表时，可以精确的指定要根据什么值来做预分区，比如：
create table test (host varchar not null primary key, description varchar) split on ('cs','eu','na');


C.使用多列族
列族包含相关的数据都在独立的文件中，在Phoenix设置多个列族可以提高查询性能。
创建两个列族：
create table test (
 mykey varchar not null primary key,
 a.col1 varchar,
 a.col2 varchar, 
 b.col3 varchar
);
upsert into test values ('key1','a1','b1','c1');
upsert into test values ('key2','a2','b2','c2');


D.使用压缩
create table test (host varchar not null primary key, description varchar) compression='snappy';




7.创建视图,删除视图
create view "my_hbase_table"( k varchar primary key, "v" unsigned_long) default_column_family='a';
create view my_view ( new_col smallint ) as select * from my_table where k = 100;
create view my_view_on_view as select * from my_view where new_col > 70
create view v1 as select *  from test where description in ('s1','s2','s3')


drop view my_view
drop view if exists my_schema.my_view
drop view if exists my_schema.my_view cascade


8.创建二级索引
支持可变数据和不可变数据（数据插入后不再更新）上建立二级索引
create index my_idx on sales.opportunity(last_updated_date desc)
create index my_idx on log.event(created_date desc) include (name, payload) salt_buckets=10
create index if not exists my_comp_idx on server_metrics ( gc_time desc, created_date desc ) 
data_block_encoding='none',versions=?,max_filesize=2000000 split on (?, ?, ?)
create index my_idx on sales.opportunity(upper(contact_name))
create index test_index on test (host) include (description);


删除索引：
drop index my_idx on sales.opportunity
drop index if exists my_idx on server_metrics
drop index if exists xdgl_acct_fee_index on xdgl_acct_fee




默认是可变表，手动创建不可变表
create table hao2 (k varchar primary key, v varchar) immutable_rows=true;
alter table HAO2 set IMMUTABLE_ROWS = false;	修改为可变
alter index index1 on tb rebuild;索引重建是把索引表清空后重新装配数据。


Global Indexing多读少写，适合条件较少
create index my_index on items(price);
调用方法：
1.强制索引
select /*+ index(items my_index) */ * from items where price=0.8824734;
drop index my_name on usertable;


2.覆盖索引 Covered Indexes，需要include包含需要返回数据结果的列。
create index index1_c on hao1 (age) include(name);  name已经被缓存在这张索引表里了。
对于select name from hao1 where age=2，查询效率和速度最快
select * from hao1 where age =2，其他列不在索引表内，会全表扫描




Local Indexing写多读少，不是索引字段索引表也会被使用，索引数据和真实数据存储在同一台机器上（
create local index index3_l_name on hao1 (name);


异步创建索引，创建的索引表中不会有数据，单独使用命令行工具来执行数据的创建
create index index1_c on hao1 (age) include(name) async;
hbase org.apache.phoenix.mapreduce.index.indextool
  --schema my_schema --data-table my_table --index-table async_idx
  --output-path async_idx_hfiles




9.与现有的HBase表关联
首先创建一张HBase表，再创建的Phoenix表，表名必须和HBase表名一致即可。
create  'stu' ,'cf1','cf2'
put 'stu', 'key1','cf1:name','luozhao'
put 'stu', 'key1','cf1:sex','man'
put 'stu', 'key1','cf2:age','24'
put 'stu', 'key1','cf2:adress','cqupt'


create table "stu" (
id VARCHAR NOT NULL  PRIMARY KEY ,
"cf1"."name" VARCHAR ,
"cf1"."sex" VARCHAR ,
"cf2"."age" VARCHAR ,
"cf2"."adress" VARCHAR );
upsert into "stu"(id,"cf1"."name","cf1"."sex","cf2"."age","cf2"."adress") values('key6','zkk','man','111','Beijing');


select * from "stu";会发现两张表是数据同步的。
这里查询表名需要用双引号括起来，强制不转换为大写。
这里一定要注意的是表名和列族以及列名需要用双引号括起来，因为HBase是区分大小写的，
如果不用双引号括起来的话Phoenix在创建表的时候会自动将小写转换为大写字母




10.在Spark运行环境中添加Phoenix依赖
spark-env.sh添加如下代码:
#添加Phoenix依赖
for file in $(find /opt/hbase-1.2.4/lib |grep  phoenix)
do
    SPARK_DIST_CLASSPATH="$SPARK_DIST_CLASSPATH:$file"
done
export SPARK_DIST_CLASSPATH
这样每次启动spark任务都会将phoenix的jar包添加到classpath了




/**
 *
 * Tests for compiling a query
 * The compilation stage finds additional errors that can't be found at parse
 * time so this is a good place for negative tests (since the mini-cluster
 * is not necessary enabling the tests to run faster).
 *
 *
 * @since 0.1
 */
@edu.umd.cs.findbugs.annotations.SuppressWarnings(
        value="RV_RETURN_VALUE_IGNORED",
        justification="Test code.")
public class QueryCompilerTest extends BaseConnectionlessQueryTest {

    @Test
    public void testParameterUnbound() throws Exception {
        try {
            String query = "SELECT a_string, b_string FROM atable WHERE organization_id=? and a_integer = ?";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage().contains("Parameter 2 is unbound"));
        }
    }

    @Test
    public void testMultiPKDef() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE foo (pk1 integer not null primary key, pk2 bigint not null primary key)";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 510 (42889): The table already has a primary key. columnName=PK2"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testPKDefAndPKConstraint() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE foo (pk integer not null primary key, col1 decimal, col2 decimal constraint my_pk primary key (col1,col2))";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 510 (42889): The table already has a primary key. columnName=PK"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testFamilyNameInPK() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE foo (a.pk integer not null primary key, col1 decimal, col2 decimal)";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertEquals(e.getErrorCode(), SQLExceptionCode.PRIMARY_KEY_WITH_FAMILY_NAME.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testSameColumnNameInPKAndNonPK() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE t1 (k integer not null primary key, a.k decimal, b.k decimal)";
            conn.createStatement().execute(query);
            PhoenixConnection pconn = conn.unwrap(PhoenixConnection.class);
            PColumn c = pconn.getTable(new PTableKey(pconn.getTenantId(), "T1")).getColumnForColumnName("K");
            assertTrue(SchemaUtil.isPKColumn(c));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testVarBinaryNotLastInMultipartPK() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        // When the VARBINARY key is the last column, it is allowed.
        String query = "CREATE TABLE foo (a_string varchar not null, b_string varchar not null, a_binary varbinary not null, " +
                "col1 decimal, col2 decimal CONSTRAINT pk PRIMARY KEY (a_string, b_string, a_binary))";
        PreparedStatement statement = conn.prepareStatement(query);
        statement.execute();
        try {
            // VARBINARY key is not allowed in the middle of the key.
            query = "CREATE TABLE foo (a_binary varbinary not null, a_string varchar not null, col1 decimal, col2 decimal CONSTRAINT pk PRIMARY KEY (a_binary, a_string))";
            statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.VARBINARY_IN_ROW_KEY.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testArrayNotLastInMultipartPK() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        // When the VARBINARY key is the last column, it is allowed.
        String query = "CREATE TABLE foo (a_string varchar not null, b_string varchar not null, a_array varchar[] not null, " +
                "col1 decimal, col2 decimal CONSTRAINT pk PRIMARY KEY (a_string, b_string, a_array))";
        PreparedStatement statement = conn.prepareStatement(query);
        statement.execute();
        try {
            // VARBINARY key is not allowed in the middle of the key.
            query = "CREATE TABLE foo (a_array varchar[] not null, a_string varchar not null, col1 decimal, col2 decimal CONSTRAINT pk PRIMARY KEY (a_array, a_string))";
            statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.VARBINARY_IN_ROW_KEY.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testNoPK() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE foo (pk integer not null, col1 decimal, col2 decimal)";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.KEY_VALUE_NOT_NULL.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testImmutableRowsPK() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE IMMUTABLE TABLE foo (pk integer not null, col1 decimal, col2 decimal)";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.PRIMARY_KEY_MISSING.getErrorCode(), e.getErrorCode());
        }
        String query = "CREATE IMMUTABLE TABLE foo (k1 integer not null, k2 decimal not null, col1 decimal not null, constraint pk primary key (k1,k2))";
        PreparedStatement statement = conn.prepareStatement(query);
        statement.execute();
        conn.close();
    }

    @Test
    public void testUnknownFamilyNameInTableOption() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE foo (pk integer not null primary key, a.col1 decimal, b.col2 decimal) c.my_property='foo'";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage().contains("Properties may not be defined for an unused family name"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testInvalidGroupedAggregation() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT count(1),a_integer FROM atable WHERE organization_id=? GROUP BY a_string";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. A_INTEGER"));
        }
    }

    @Test
    public void testInvalidGroupExpressionAggregation() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT sum(a_integer) + a_integer FROM atable WHERE organization_id=? GROUP BY a_string";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. A_INTEGER"));
        }
    }

    @Test
    public void testAggInWhereClause() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT a_integer FROM atable WHERE organization_id=? AND count(1) > 2";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1017 (42Y26): Aggregate may not be used in WHERE."));
        }
    }

    @Test
    public void testHavingAggregateQuery() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT a_integer FROM atable WHERE organization_id=? HAVING count(1) > 2";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. A_INTEGER"));
        }
    }

    @Test
    public void testNonAggInHavingClause() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT a_integer FROM atable WHERE organization_id=? HAVING a_integer = 5";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1019 (42Y26): Only aggregate maybe used in the HAVING clause."));
        }
    }

    @Test
    public void testTypeMismatchInCase() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT a_integer FROM atable WHERE organization_id=? HAVING CASE WHEN a_integer <= 2 THEN 'foo' WHEN a_integer = 3 THEN 2 WHEN a_integer <= 5 THEN 5 ELSE 5 END  = 5";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage().contains("Case expressions must have common type"));
        }
    }

    @Test
    public void testNonBooleanWhereExpression() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "SELECT a_integer FROM atable WHERE organization_id=? and CASE WHEN a_integer <= 2 THEN 'foo' WHEN a_integer = 3 THEN 'bar' WHEN a_integer <= 5 THEN 'bas' ELSE 'blah' END";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage().contains("ERROR 203 (22005): Type mismatch. BOOLEAN and VARCHAR for CASE WHEN A_INTEGER <= 2 THEN 'foo'WHEN A_INTEGER = 3 THEN 'bar'WHEN A_INTEGER <= 5 THEN 'bas' ELSE 'blah' END"));
        }
    }

    @Test
    public void testNoSCNInConnectionProps() throws Exception {
        Properties props = new Properties();
        DriverManager.getConnection(getUrl(), props);
    }


    @Test
    public void testPercentileWrongQueryWithMixOfAggrAndNonAggrExps() throws Exception {
        String query = "select a_integer, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a_integer ASC) from ATABLE";
        try {
            compileQuery(query, Collections.emptyList());
            fail();
        } catch (SQLException e) {
            assertEquals("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. A_INTEGER",
                    e.getMessage());
        }
    }

    @Test
    public void testPercentileWrongQuery1() throws Exception {
        String query = "select PERCENTILE_CONT('*') WITHIN GROUP (ORDER BY a_integer ASC) from ATABLE";
        try {
            compileQuery(query, Collections.emptyList());
            fail();
        } catch (SQLException e) {
            assertEquals(
                    "ERROR 203 (22005): Type mismatch. expected: [DECIMAL] but was: VARCHAR at PERCENTILE_CONT argument 3",
                    e.getMessage());
        }
    }

    @Test
    public void testPercentileWrongQuery2() throws Exception {
        String query = "select PERCENTILE_CONT(1.1) WITHIN GROUP (ORDER BY a_integer ASC) from ATABLE";
        try {
            compileQuery(query, Collections.emptyList());
            fail();
        } catch (SQLException e) {
            assertEquals(
                    "ERROR 213 (22003): Value outside range. expected: [0 , 1] but was: 1.1 at PERCENTILE_CONT argument 3",
                    e.getMessage());
        }
    }

    @Test
    public void testPercentileWrongQuery3() throws Exception {
        String query = "select PERCENTILE_CONT(-1) WITHIN GROUP (ORDER BY a_integer ASC) from ATABLE";
        try {
            compileQuery(query, Collections.emptyList());
            fail();
        } catch (Exception e) {
            assertEquals(
                    "ERROR 213 (22003): Value outside range. expected: [0 , 1] but was: -1 at PERCENTILE_CONT argument 3",
                    e.getMessage());
        }
    }

    private Scan compileQuery(String query, List<Object> binds) throws SQLException {
        QueryPlan plan = getQueryPlan(query, binds);
        return plan.getContext().getScan();
    }

    private Scan projectQuery(String query) throws SQLException {
        QueryPlan plan = getQueryPlan(query, Collections.emptyList());
        plan.iterator(); // Forces projection
        return plan.getContext().getScan();
    }

    private QueryPlan getOptimizedQueryPlan(String query) throws SQLException {
        return getOptimizedQueryPlan(query, Collections.emptyList());
    }

    private QueryPlan getOptimizedQueryPlan(String query, List<Object> binds) throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PhoenixPreparedStatement statement = conn.prepareStatement(query).unwrap(PhoenixPreparedStatement.class);
            for (Object bind : binds) {
                statement.setObject(1, bind);
            }
            QueryPlan plan = statement.optimizeQuery(query);
            return plan;
        } finally {
            conn.close();
        }
    }

    private QueryPlan getQueryPlan(String query, List<Object> binds) throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PhoenixPreparedStatement statement = conn.prepareStatement(query).unwrap(PhoenixPreparedStatement.class);
            for (Object bind : binds) {
                statement.setObject(1, bind);
            }
            QueryPlan plan = statement.compileQuery(query);
            return plan;
        } finally {
            conn.close();
        }
    }

    @Test
    public void testKeyOrderedGroupByOptimization() throws Exception {
        // Select columns in PK
        String[] queries = new String[] {
            "SELECT count(1) FROM atable GROUP BY organization_id,entity_id",
            "SELECT count(1) FROM atable GROUP BY organization_id,substr(entity_id,1,3),entity_id",
            "SELECT count(1) FROM atable GROUP BY entity_id,organization_id",
            "SELECT count(1) FROM atable GROUP BY substr(entity_id,1,3),organization_id",
            "SELECT count(1) FROM ptsdb GROUP BY host,inst,round(\"DATE\",'HOUR')",
            "SELECT count(1) FROM atable GROUP BY organization_id",
        };
        List<Object> binds = Collections.emptyList();
        for (String query : queries) {
            QueryPlan plan = getQueryPlan(query, binds);
            assertEquals(query, BaseScannerRegionObserver.KEY_ORDERED_GROUP_BY_EXPRESSIONS, plan.getGroupBy().getScanAttribName());
        }
    }

    @Test
    public void testNullInScanKey() throws Exception {
        // Select columns in PK
        String query = "select val from ptsdb where inst is null and host='a'";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        // Projects column family with not null column
        assertNull(scan.getFilter());
        assertEquals(1,scan.getFamilyMap().keySet().size());
        assertArrayEquals(Bytes.toBytes(SchemaUtil.normalizeIdentifier(QueryConstants.DEFAULT_COLUMN_FAMILY)), scan.getFamilyMap().keySet().iterator().next());
    }

    @Test
    public void testOnlyNullInScanKey() throws Exception {
        // Select columns in PK
        String query = "select val from ptsdb where inst is null";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        // Projects column family with not null column
        assertEquals(1,scan.getFamilyMap().keySet().size());
        assertArrayEquals(Bytes.toBytes(SchemaUtil.normalizeIdentifier(QueryConstants.DEFAULT_COLUMN_FAMILY)), scan.getFamilyMap().keySet().iterator().next());
    }

    @Test
    public void testIsNullOnNotNullable() throws Exception {
        // Select columns in PK
        String query = "select a_string from atable where entity_id is null";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        assertDegenerate(scan);
    }

    @Test
    public void testIsNotNullOnNotNullable() throws Exception {
        // Select columns in PK
        String query = "select a_string from atable where entity_id is not null";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        assertNull(scan.getFilter());
        assertTrue(scan.getStartRow().length == 0);
        assertTrue(scan.getStopRow().length == 0);
    }

    @Test
    public void testUpsertTypeMismatch() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "upsert into ATABLE VALUES (?, ?, ?)";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.setString(2, "00D300000000XHP");
                statement.setInt(3, 1);
                statement.executeUpdate();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) { // TODO: use error codes
            assertTrue(e.getMessage().contains("Type mismatch"));
        }
    }

    @Test
    public void testUpsertMultiByteIntoChar() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "upsert into ATABLE VALUES (?, ?, ?)";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.setString(1, "00D300000000XHP");
                statement.setString(2, "繰り返し曜日マスク");
                statement.setInt(3, 1);
                statement.executeUpdate();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 201 (22000): Illegal data."));
            assertTrue(e.getMessage().contains("CHAR types may only contain single byte characters"));
        }
    }

    @Test
    public void testSelectStarOnGroupBy() throws Exception {
        try {
            // Select non agg column in aggregate query
            String query = "select * from ATABLE group by a_string";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY."));
        }
    }

    @Test
    public void testOrderByAggSelectNonAgg() throws Exception {
        try {
            // Order by in select with no limit or group by
            String query = "select a_string from ATABLE order by max(b_string)";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. A_STRING"));
        }
    }

    @Test
    public void testOrderByAggAndNonAgg() throws Exception {
        try {
            // Order by in select with no limit or group by
            String query = "select max(a_string) from ATABLE order by max(b_string),a_string";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. A_STRING"));
        }
    }

    @Test
    public void testOrderByNonAggSelectAgg() throws Exception {
        try {
            // Order by in select with no limit or group by
            String query = "select max(a_string) from ATABLE order by b_string LIMIT 5";
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            Connection conn = DriverManager.getConnection(getUrl(), props);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.executeQuery();
                fail();
            } finally {
                conn.close();
            }
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 1018 (42Y27): Aggregate may not contain columns not in GROUP BY. B_STRING"));
        }
    }

    @Test
    public void testNotKeyOrderedGroupByOptimization() throws Exception {
        // Select columns in PK
        String[] queries = new String[] {
            "SELECT count(1) FROM atable GROUP BY entity_id",
            "SELECT count(1) FROM atable GROUP BY substr(organization_id,2,3)",
            "SELECT count(1) FROM atable GROUP BY substr(entity_id,1,3)",
            "SELECT count(1) FROM atable GROUP BY to_date(organization_id)",
            "SELECT count(1) FROM atable GROUP BY regexp_substr(organization_id, '.*foo.*'),entity_id",
            "SELECT count(1) FROM atable GROUP BY substr(organization_id,1),entity_id",
        };
        List<Object> binds = Collections.emptyList();
        for (String query : queries) {
            QueryPlan plan = getQueryPlan(query, binds);
            assertEquals(plan.getGroupBy().getScanAttribName(), BaseScannerRegionObserver.UNORDERED_GROUP_BY_EXPRESSIONS);
        }
    }

    @Test
    public void testFunkyColumnNames() throws Exception {
        // Select columns in PK
        String[] queries = new String[] {
            "SELECT \"foo!\",\"foo.bar-bas\",\"#@$\",\"_blah^\" FROM FUNKY_NAMES",
            "SELECT count(\"foo!\"),\"_blah^\" FROM FUNKY_NAMES WHERE \"foo.bar-bas\"='x' GROUP BY \"#@$\",\"_blah^\"",
        };
        List<Object> binds = Collections.emptyList();
        for (String query : queries) {
            compileQuery(query, binds);
        }
    }

    @Test
    public void testCountAggregatorFirst() throws Exception {
        String[] queries = new String[] {
            "SELECT sum(2.5),organization_id FROM atable GROUP BY organization_id,entity_id",
            "SELECT avg(a_integer) FROM atable GROUP BY organization_id,substr(entity_id,1,3),entity_id",
            "SELECT count(a_string) FROM atable GROUP BY substr(organization_id,1),entity_id",
            "SELECT min('foo') FROM atable GROUP BY entity_id,organization_id",
            "SELECT min('foo'),sum(a_integer),avg(2.5),4.5,max(b_string) FROM atable GROUP BY substr(organization_id,1),entity_id",
            "SELECT sum(2.5) FROM atable",
            "SELECT avg(a_integer) FROM atable",
            "SELECT count(a_string) FROM atable",
            "SELECT min('foo') FROM atable LIMIT 5",
            "SELECT min('foo'),sum(a_integer),avg(2.5),4.5,max(b_string) FROM atable",
        };
        List<Object> binds = Collections.emptyList();
        String query = null;
        try {
            for (int i = 0; i < queries.length; i++) {
                query = queries[i];
                Scan scan = compileQuery(query, binds);
                ServerAggregators aggregators = ServerAggregators.deserialize(scan.getAttribute(BaseScannerRegionObserver.AGGREGATORS), null, null);
                Aggregator aggregator = aggregators.getAggregators()[0];
                assertTrue(aggregator instanceof CountAggregator);
            }
        } catch (Exception e) {
            throw new Exception(query, e);
        }
    }

    @Test
    public void testInvalidArithmetic() throws Exception {
        String[] queries = new String[] {
                "SELECT entity_id,organization_id FROM atable where A_STRING - 5.5 < 0",
                "SELECT entity_id,organization_id FROM atable where A_DATE - 'transaction' < 0",
                "SELECT entity_id,organization_id FROM atable where A_DATE * 45 < 0",
                "SELECT entity_id,organization_id FROM atable where A_DATE / 45 < 0",
                "SELECT entity_id,organization_id FROM atable where 45 - A_DATE < 0",
                "SELECT entity_id,organization_id FROM atable where A_DATE - to_date('2000-01-01 12:00:00') < to_date('2000-02-01 12:00:00')", // RHS must be number
                "SELECT entity_id,organization_id FROM atable where A_DATE - A_DATE + 1 < A_DATE", // RHS must be number
                "SELECT entity_id,organization_id FROM atable where A_DATE + 2 < 0", // RHS must be date
                "SELECT entity_id,organization_id FROM atable where 45.5 - A_DATE < 0",
                "SELECT entity_id,organization_id FROM atable where 1 + A_DATE + A_DATE < A_DATE",
                "SELECT entity_id,organization_id FROM atable where A_STRING - 45 < 0",
                "SELECT entity_id,organization_id FROM atable where A_STRING / 45 < 0",
                "SELECT entity_id,organization_id FROM atable where A_STRING * 45 < 0",
                "SELECT entity_id,organization_id FROM atable where A_STRING + 45 < 0",
                "SELECT entity_id,organization_id FROM atable where A_STRING - 45 < 0",
                "SELECT entity_id,organization_id FROM atable where A_STRING - 'transaction' < 0", };

        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        for (String query : queries) {
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.executeQuery();
                fail(query);
            } catch (SQLException e) {
                if (e.getMessage().contains("ERROR 203 (22005): Type mismatch.")) {
                    continue;
                }
                throw new IllegalStateException("Didn't find type mismatch: " + query, e);
            }
        }
    }


    @Test
    public void testAmbiguousColumn() throws Exception {
        String query = "SELECT * from multi_cf G where RESPONSE_TIME = 2222";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (AmbiguousColumnException e) { // expected
        } finally {
            conn.close();
        }
    }

    @Test
    public void testTableAliasMatchesCFName() throws Exception {
        String query = "SELECT F.RESPONSE_TIME,G.RESPONSE_TIME from multi_cf G where G.RESPONSE_TIME-1 = F.RESPONSE_TIME";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (AmbiguousColumnException e) { // expected
        } finally {
            conn.close();
        }
    }

    @Test
    public void testCoelesceFunctionTypeMismatch() throws Exception {
        String query = "SELECT coalesce(x_integer,'foo') from atable";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 203 (22005): Type mismatch. COALESCE expected INTEGER, but got VARCHAR"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testOrderByNotInSelectDistinct() throws Exception {
        String query = "SELECT distinct a_string,b_string from atable order by x_integer";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.ORDER_BY_NOT_IN_SELECT_DISTINCT.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testSelectDistinctAndAll() throws Exception {
        String query = "SELECT all distinct a_string,b_string from atable order by x_integer";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.PARSER_ERROR.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testSelectDistinctAndOrderBy() throws Exception {
        String query = "select /*+ RANGE_SCAN */ count(distinct organization_id) from atable order by organization_id";
        String query1 = "select count(distinct organization_id) from atable order by organization_id";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.AGGREGATE_WITH_NOT_GROUP_BY_COLUMN.getErrorCode(), e.getErrorCode());
        }
        try {
            PreparedStatement statement = conn.prepareStatement(query1);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.AGGREGATE_WITH_NOT_GROUP_BY_COLUMN.getErrorCode(), e.getErrorCode());
        }
        conn.close();
    }

    @Test
    public void testOrderByNotInSelectDistinctAgg() throws Exception {
        String query = "SELECT distinct count(1) from atable order by x_integer";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.ORDER_BY_NOT_IN_SELECT_DISTINCT.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testSelectDistinctWithAggregation() throws Exception {
        String query = "SELECT distinct a_string,count(*) from atable";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.AGGREGATE_WITH_NOT_GROUP_BY_COLUMN.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testAggregateOnColumnsNotInGroupByForImmutableEncodedTable() throws Exception {
        String tableName = generateUniqueName();
        String ddl = "CREATE IMMUTABLE TABLE  " + tableName +
                "  (a_string varchar not null, col1 integer, col2 integer" +
                "  CONSTRAINT pk PRIMARY KEY (a_string))";
        String query = "SELECT col1, max(a_string) from " + tableName + " group by col2";
        try (Connection conn = DriverManager.getConnection(getUrl())) {
            conn.createStatement().execute(ddl);
            try {
                PreparedStatement statement = conn.prepareStatement(query);
                statement.executeQuery();
                fail();
            } catch (SQLException e) { // expected
                assertEquals(SQLExceptionCode.AGGREGATE_WITH_NOT_GROUP_BY_COLUMN.getErrorCode(), e.getErrorCode());
            }
        }
    }

    @Test
    public void testRegexpSubstrSetScanKeys() throws Exception {
        // First test scan keys are set when the offset is 0 or 1.
        String query = "SELECT host FROM ptsdb WHERE regexp_substr(inst, '[a-zA-Z]+') = 'abc'";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        assertArrayEquals(Bytes.toBytes("abc"), scan.getStartRow());
        assertArrayEquals(ByteUtil.nextKey(Bytes.toBytes("abc")),scan.getStopRow());
        assertTrue(scan.getFilter() != null);

        query = "SELECT host FROM ptsdb WHERE regexp_substr(inst, '[a-zA-Z]+', 0) = 'abc'";
        binds = Collections.emptyList();
        scan = compileQuery(query, binds);
        assertArrayEquals(Bytes.toBytes("abc"), scan.getStartRow());
        assertArrayEquals(ByteUtil.nextKey(Bytes.toBytes("abc")), scan.getStopRow());
        assertTrue(scan.getFilter() != null);

        // Test scan keys are not set when the offset is not 0 or 1.
        query = "SELECT host FROM ptsdb WHERE regexp_substr(inst, '[a-zA-Z]+', 3) = 'abc'";
        binds = Collections.emptyList();
        scan = compileQuery(query, binds);
        assertTrue(scan.getStartRow().length == 0);
        assertTrue(scan.getStopRow().length == 0);
        assertTrue(scan.getFilter() != null);
    }

    @Test
    public void testStringConcatExpression() throws Exception {
        String query = "SELECT entity_id,a_string FROM atable where 2 || a_integer || ? like '2%'";
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        Connection conn = DriverManager.getConnection(getUrl(), props);
        byte []x=new byte[]{127,127,0,0};//Binary data
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.setBytes(1, x);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertTrue(e.getMessage().contains("Concatenation does not support"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testDivideByBigDecimalZero() throws Exception {
        String query = "SELECT a_integer/x_integer/0.0 FROM atable";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertTrue(e.getMessage().contains("Divide by zero"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testDivideByIntegerZero() throws Exception {
        String query = "SELECT a_integer/0 FROM atable";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.executeQuery();
            fail();
        } catch (SQLException e) { // expected
            assertTrue(e.getMessage().contains("Divide by zero"));
        } finally {
            conn.close();
        }
    }

    @Test
    public void testCreateNullableInPKMiddle() throws Exception {
        String query = "CREATE TABLE foo(i integer not null, j integer null, k integer not null CONSTRAINT pk PRIMARY KEY(i,j,k))";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) { // expected
            assertTrue(e.getMessage().contains("PK columns may not be both fixed width and nullable"));
        }
    }

    @Test
    public void testSetSaltBucketOnAlterTable() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("ALTER TABLE atable ADD xyz INTEGER SALT_BUCKETS=4");
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.SALT_ONLY_ON_CREATE_TABLE.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().execute("ALTER TABLE atable SET SALT_BUCKETS=4");
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.SALT_ONLY_ON_CREATE_TABLE.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testAlterNotNull() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("ALTER TABLE atable ADD xyz VARCHAR NOT NULL");
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.KEY_VALUE_NOT_NULL.getErrorCode(), e.getErrorCode());
        }
        conn.createStatement().execute("CREATE IMMUTABLE TABLE foo (K1 VARCHAR PRIMARY KEY)");
        try {
            conn.createStatement().execute("ALTER TABLE foo ADD xyz VARCHAR NOT NULL PRIMARY KEY");
            fail();
        } catch (SQLException e) { // expected
            assertEquals(SQLExceptionCode.NOT_NULLABLE_COLUMN_IN_ROW_KEY.getErrorCode(), e.getErrorCode());
        }
        conn.createStatement().execute("ALTER TABLE FOO ADD xyz VARCHAR NOT NULL");
    }

    @Test
    public void testSubstrSetScanKey() throws Exception {
        String query = "SELECT inst FROM ptsdb WHERE substr(inst, 0, 3) = 'abc'";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        assertArrayEquals(Bytes.toBytes("abc"), scan.getStartRow());
        assertArrayEquals(ByteUtil.nextKey(Bytes.toBytes("abc")), scan.getStopRow());
        assertTrue(scan.getFilter() == null); // Extracted.
    }

    @Test
    public void testRTrimSetScanKey() throws Exception {
        String query = "SELECT inst FROM ptsdb WHERE rtrim(inst) = 'abc'";
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery(query, binds);
        assertArrayEquals(Bytes.toBytes("abc"), scan.getStartRow());
        assertArrayEquals(ByteUtil.nextKey(Bytes.toBytes("abc ")), scan.getStopRow());
        assertNotNull(scan.getFilter());
    }

    @Test
    public void testCastingIntegerToDecimalInSelect() throws Exception {
        String query = "SELECT CAST (a_integer AS DECIMAL)/2 FROM aTable WHERE 5=a_integer";
        List<Object> binds = Collections.emptyList();
        compileQuery(query, binds);
    }

    @Test
    public void testCastingTimestampToDateInSelect() throws Exception {
        String query = "SELECT CAST (a_timestamp AS DATE) FROM aTable";
        List<Object> binds = Collections.emptyList();
        compileQuery(query, binds);
    }

    @Test
    public void testCastingStringToDecimalInSelect() throws Exception {
        String query = "SELECT CAST (b_string AS DECIMAL)/2 FROM aTable WHERE 5=a_integer";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a string to decimal isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testCastingStringToDecimalInWhere() throws Exception {
        String query = "SELECT a_integer FROM aTable WHERE 2.5=CAST (b_string AS DECIMAL)/2 ";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a string to decimal isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testCastingWithLengthInSelect() throws Exception {
        String query = "SELECT CAST (b_string AS VARCHAR(10)) FROM aTable";
        List<Object> binds = Collections.emptyList();
        compileQuery(query, binds);
    }

    @Test
    public void testCastingWithLengthInWhere() throws Exception {
        String query = "SELECT b_string FROM aTable WHERE CAST (b_string AS VARCHAR(10)) = 'b'";
        List<Object> binds = Collections.emptyList();
        compileQuery(query, binds);
    }

    @Test
    public void testCastingWithLengthAndScaleInSelect() throws Exception {
        String query = "SELECT CAST (x_decimal AS DECIMAL(10,5)) FROM aTable";
        List<Object> binds = Collections.emptyList();
        compileQuery(query, binds);
    }

    @Test
    public void testUsingNonComparableDataTypesInRowValueConstructorFails() throws Exception {
        String query = "SELECT a_integer, x_integer FROM aTable WHERE (a_integer, x_integer) > (2, 'abc')";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a integer to string isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testUsingNonComparableDataTypesOfColumnRefOnLHSAndRowValueConstructorFails() throws Exception {
        String query = "SELECT a_integer, x_integer FROM aTable WHERE a_integer > ('abc', 2)";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a integer to string isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testUsingNonComparableDataTypesOfLiteralOnLHSAndRowValueConstructorFails() throws Exception {
        String query = "SELECT a_integer, x_integer FROM aTable WHERE 'abc' > (a_integer, x_integer)";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a integer to string isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testUsingNonComparableDataTypesOfColumnRefOnRHSAndRowValueConstructorFails() throws Exception {
        String query = "SELECT a_integer, x_integer FROM aTable WHERE ('abc', 2) < a_integer ";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a integer to string isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testUsingNonComparableDataTypesOfLiteralOnRHSAndRowValueConstructorFails() throws Exception {
        String query = "SELECT a_integer, x_integer FROM aTable WHERE (a_integer, x_integer) < 'abc'";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since casting a integer to string isn't supported");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.TYPE_MISMATCH.getErrorCode());
        }
    }

    @Test
    public void testNonConstantInList() throws Exception {
        String query = "SELECT a_integer, x_integer FROM aTable WHERE a_integer IN (x_integer)";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since non constants in IN is not valid");
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.VALUE_IN_LIST_NOT_CONSTANT.getErrorCode());
        }
    }

    @Test
    public void testKeyValueColumnInPKConstraint() throws Exception {
        String ddl = "CREATE TABLE t (a.k VARCHAR, b.v VARCHAR CONSTRAINT pk PRIMARY KEY(k))";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (SQLException e) {
            assertTrue(e.getErrorCode() == SQLExceptionCode.PRIMARY_KEY_WITH_FAMILY_NAME.getErrorCode());
        }
    }

    @Test
    public void testUnknownColumnInPKConstraint() throws Exception {
        String ddl = "CREATE TABLE t (k1 VARCHAR, b.v VARCHAR CONSTRAINT pk PRIMARY KEY(k1, k2))";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (ColumnNotFoundException e) {
            assertEquals("K2",e.getColumnName());
        }
    }


    @Test
    public void testDuplicatePKColumn() throws Exception {
        String ddl = "CREATE TABLE t (k1 VARCHAR, k1 VARCHAR CONSTRAINT pk PRIMARY KEY(k1))";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (ColumnAlreadyExistsException e) {
            assertEquals("K1",e.getColumnName());
        }
    }


    @Test
    public void testDuplicateKVColumn() throws Exception {
        String ddl = "CREATE TABLE t (k1 VARCHAR, v1 VARCHAR, v2 VARCHAR, v1 INTEGER CONSTRAINT pk PRIMARY KEY(k1))";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (ColumnAlreadyExistsException e) {
            assertEquals("V1",e.getColumnName());
        }
    }

    private void assertImmutableRows(Connection conn, String fullTableName, boolean expectedValue) throws SQLException {
        PhoenixConnection pconn = conn.unwrap(PhoenixConnection.class);
        assertEquals(expectedValue, pconn.getTable(new PTableKey(pconn.getTenantId(), fullTableName)).isImmutableRows());
    }

    @Test
    public void testInvalidNegativeArrayIndex() throws Exception {
        String query = "SELECT a_double_array[-20] FROM table_with_array";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(query);
            fail();
        } catch (Exception e) {

        }
    }
    @Test
    public void testWrongDataTypeInRoundFunction() throws Exception {
        String query = "SELECT ROUND(a_string, 'day', 1) FROM aTable";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since VARCHAR is not a valid data type for ROUND");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testNonArrayColumnWithIndex() throws Exception {
        String query = "SELECT a_float[1] FROM table_with_array";
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(query);
            fail();
        } catch (Exception e) {
        }
    }

    public void testWrongTimeUnitInRoundDateFunction() throws Exception {
        String query = "SELECT ROUND(a_date, 'dayss', 1) FROM aTable";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since dayss is not a valid time unit type");
        } catch (IllegalArgumentException e) {
            assertTrue(e.getMessage().contains(TimeUnit.VALID_VALUES));
        }
    }

    @Test
    public void testWrongMultiplierInRoundDateFunction() throws Exception {
        String query = "SELECT ROUND(a_date, 'days', 1.23) FROM aTable";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since multiplier can be an INTEGER only");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testTypeMismatchForArrayElem() throws Exception {
        String query = "SELECT (a_string,a_date)[1] FROM aTable";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since a row value constructor is not an array");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testTypeMismatch2ForArrayElem() throws Exception {
        String query = "SELECT ROUND(a_date, 'days', 1.23)[1] FROM aTable";
        List<Object> binds = Collections.emptyList();
        try {
            compileQuery(query, binds);
            fail("Compilation should have failed since ROUND does not return an array");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testInvalidArraySize() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            String query = "CREATE TABLE foo (col1 INTEGER[-1] NOT NULL PRIMARY KEY)";
            PreparedStatement statement = conn.prepareStatement(query);
            statement.execute();
            fail();
        } catch (SQLException e) {
                assertEquals(SQLExceptionCode.MISMATCHED_TOKEN.getErrorCode(), e.getErrorCode());
        } finally {
                conn.close();
        }
    }

    @Test
    public void testInvalidArrayElemRefInUpsert() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k VARCHAR PRIMARY KEY, a INTEGER[10], B INTEGER[10])");
        try {
            conn.createStatement().execute("UPSERT INTO t(k,a[2]) VALUES('A', 5)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.PARSER_ERROR.getErrorCode(), e.getErrorCode());
        }
        conn.close();
    }

    @Test
    public void testVarbinaryArrayNotSupported() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (k VARCHAR PRIMARY KEY, a VARBINARY[10])");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.VARBINARY_ARRAY_NOT_SUPPORTED.getErrorCode(), e.getErrorCode());
        }
        conn.close();
    }

    @Test
    public void testInvalidNextValueFor() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE SEQUENCE alpha.zeta");
        String[] queries = {
                "SELECT * FROM aTable WHERE a_integer < next value for alpha.zeta",
                "SELECT * FROM aTable GROUP BY a_string,next value for alpha.zeta",
                "SELECT * FROM aTable GROUP BY 1 + next value for alpha.zeta",
                "SELECT * FROM aTable GROUP BY a_integer HAVING a_integer < next value for alpha.zeta",
                "SELECT * FROM aTable WHERE a_integer < 3 GROUP BY a_integer HAVING a_integer < next value for alpha.zeta",
                "SELECT * FROM aTable ORDER BY next value for alpha.zeta",
                "SELECT max(next value for alpha.zeta) FROM aTable",
        };
        for (String query : queries) {
            List<Object> binds = Collections.emptyList();
            try {
                compileQuery(query, binds);
                fail("Compilation should have failed since this is an invalid usage of NEXT VALUE FOR: " + query);
            } catch (SQLException e) {
                assertEquals(query, SQLExceptionCode.INVALID_USE_OF_NEXT_VALUE_FOR.getErrorCode(), e.getErrorCode());
            }
        }
    }

    @Test
    public void testNoCachingHint() throws Exception {
        List<Object> binds = Collections.emptyList();
        Scan scan = compileQuery("select val from ptsdb", binds);
        assertTrue(scan.getCacheBlocks());
        scan = compileQuery("select /*+ NO_CACHE */ val from ptsdb", binds);
        assertFalse(scan.getCacheBlocks());
        scan = compileQuery("select /*+ NO_CACHE */ p1.val from ptsdb p1 inner join ptsdb p2 on p1.inst = p2.inst", binds);
        assertFalse(scan.getCacheBlocks());
    }

    @Test
    public void testExecuteWithNonEmptyBatch() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            Statement stmt = conn.createStatement();
            stmt.addBatch("SELECT * FROM atable");
            stmt.execute("UPSERT INTO atable VALUES('000000000000000','000000000000000')");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.EXECUTE_UPDATE_WITH_NON_EMPTY_BATCH.getErrorCode(), e.getErrorCode());
        }
        try {
            Statement stmt = conn.createStatement();
            stmt.addBatch("SELECT * FROM atable");
            stmt.executeUpdate("UPSERT INTO atable VALUES('000000000000000','000000000000000')");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.EXECUTE_UPDATE_WITH_NON_EMPTY_BATCH.getErrorCode(), e.getErrorCode());
        }
        try {
            PreparedStatement stmt = conn.prepareStatement("UPSERT INTO atable VALUES('000000000000000','000000000000000')");
            stmt.addBatch();
            stmt.execute();
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.EXECUTE_UPDATE_WITH_NON_EMPTY_BATCH.getErrorCode(), e.getErrorCode());
        }
        try {
            PreparedStatement stmt = conn.prepareStatement("UPSERT INTO atable VALUES('000000000000000','000000000000000')");
            stmt.addBatch();
            stmt.executeUpdate();
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.EXECUTE_UPDATE_WITH_NON_EMPTY_BATCH.getErrorCode(), e.getErrorCode());
        }
        conn.close();
    }

    @Test
    public void testInvalidPrimaryKeyDecl() throws Exception {
        String[] queries = {
                "CREATE TABLE t (k varchar null primary key)",
                "CREATE TABLE t (k varchar null, constraint pk primary key (k))",
        };
        Connection conn = DriverManager.getConnection(getUrl());
        for (String query : queries) {
            try {
                conn.createStatement().execute(query);
                fail("Compilation should have failed since this is an invalid PRIMARY KEY declaration: " + query);
            } catch (SQLException e) {
                assertEquals(query, SQLExceptionCode.SINGLE_PK_MAY_NOT_BE_NULL.getErrorCode(), e.getErrorCode());
            }
        }
    }

    @Test
    public void testInvalidNullCompositePrimaryKey() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 varchar, k2 varchar, constraint pk primary key(k1,k2))");
        PreparedStatement stmt = conn.prepareStatement("UPSERT INTO t values(?,?)");
        stmt.setString(1, "");
        stmt.setString(2, "");
        try {
            stmt.execute();
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage().contains("Primary key may not be null"));
        }
    }


    @Test
    public void testGroupByLimitOptimization() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 varchar, k2 varchar, v varchar, constraint pk primary key(k1,k2))");
        ResultSet rs;
        String[] queries = {
                "SELECT DISTINCT v FROM T LIMIT 3",
                "SELECT v FROM T GROUP BY v,k1 LIMIT 3",
                "SELECT count(*) FROM T GROUP BY k1 LIMIT 3",
                "SELECT max(v) FROM T GROUP BY k1,k2 LIMIT 3",
                "SELECT k1,k2 FROM T GROUP BY k1,k2 LIMIT 3",
                "SELECT max(v) FROM T GROUP BY k2,k1 HAVING k1 > 'a' LIMIT 3", // Having optimized out, order of GROUP BY key not important
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            rs = conn.createStatement().executeQuery("EXPLAIN " + query);
            assertTrue("Expected to find GROUP BY limit optimization in: " + query, QueryUtil.getExplainPlan(rs).contains(" LIMIT 3 GROUPS"));
        }
    }

    @Test
    public void testNoGroupByLimitOptimization() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 varchar, k2 varchar, v varchar, constraint pk primary key(k1,k2))");
        ResultSet rs;
        String[] queries = {
//                "SELECT DISTINCT v FROM T ORDER BY v LIMIT 3",
//                "SELECT v FROM T GROUP BY v,k1 ORDER BY v LIMIT 3",
                "SELECT DISTINCT count(*) FROM T GROUP BY k1 LIMIT 3",
                "SELECT count(1) FROM T GROUP BY v,k1 LIMIT 3",
                "SELECT max(v) FROM T GROUP BY k1,k2 HAVING count(k1) > 1 LIMIT 3",
                "SELECT count(v) FROM T GROUP BY to_date(k2),k1 LIMIT 3",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            rs = conn.createStatement().executeQuery("EXPLAIN " + query);
            String explainPlan = QueryUtil.getExplainPlan(rs);
            assertFalse("Did not expected to find GROUP BY limit optimization in: " + query, explainPlan.contains(" LIMIT 3 GROUPS"));
        }
    }

    @Test
    public void testLocalIndexCreationWithDefaultFamilyOption() throws Exception {
        Connection conn1 = DriverManager.getConnection(getUrl());
        try{
            Statement statement = conn1.createStatement();
            statement.execute("create table example (id integer not null,fn varchar,"
                    + "\"ln\" varchar constraint pk primary key(id)) DEFAULT_COLUMN_FAMILY='F'");
            try {
                statement.execute("create local index my_idx on example (fn) DEFAULT_COLUMN_FAMILY='F'");
                fail();
            } catch (SQLException e) {
                assertEquals(SQLExceptionCode.DEFAULT_COLUMN_FAMILY_ON_SHARED_TABLE.getErrorCode(),e.getErrorCode());
            }
            statement.execute("create local index my_idx on example (fn)");
       } finally {
            conn1.close();
        }
    }

    @Test
    public void testMultiCFProjection() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        String ddl = "CREATE TABLE multiCF (k integer primary key, a.a varchar, b.b varchar)";
        conn.createStatement().execute(ddl);
        String query = "SELECT COUNT(*) FROM multiCF";
        QueryPlan plan = getQueryPlan(query,Collections.emptyList());
        plan.iterator();
        Scan scan = plan.getContext().getScan();
        assertTrue(scan.getFilter() instanceof FirstKeyOnlyFilter);
        assertEquals(1, scan.getFamilyMap().size());
    }

    @Test
    public void testNonDeterministicExpressionIndex() throws Exception {
        String ddl = "CREATE TABLE t (k1 INTEGER PRIMARY KEY)";
        Connection conn = DriverManager.getConnection(getUrl());
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
            stmt.execute(ddl);
            stmt.execute("CREATE INDEX i ON t (RAND())");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.NON_DETERMINISTIC_EXPRESSION_NOT_ALLOWED_IN_INDEX.getErrorCode(), e.getErrorCode());
        }
        finally {
            stmt.close();
        }
    }

    @Test
    public void testStatelessExpressionIndex() throws Exception {
        String ddl = "CREATE TABLE t (k1 INTEGER PRIMARY KEY)";
        Connection conn = DriverManager.getConnection(getUrl());
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
            stmt.execute(ddl);
            stmt.execute("CREATE INDEX i ON t (2)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.STATELESS_EXPRESSION_NOT_ALLOWED_IN_INDEX.getErrorCode(), e.getErrorCode());
        }
        finally {
            stmt.close();
        }
    }

    @Test
    public void testAggregateExpressionIndex() throws Exception {
        String ddl = "CREATE TABLE t (k1 INTEGER PRIMARY KEY)";
        Connection conn = DriverManager.getConnection(getUrl());
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
            stmt.execute(ddl);
            stmt.execute("CREATE INDEX i ON t (SUM(k1))");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.AGGREGATE_EXPRESSION_NOT_ALLOWED_IN_INDEX.getErrorCode(), e.getErrorCode());
        }
        finally {
            stmt.close();
        }
    }

    @Test
    public void testDescVarbinaryNotSupported() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (k VARBINARY PRIMARY KEY DESC)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DESC_VARBINARY_NOT_SUPPORTED.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().execute("CREATE TABLE t (k1 VARCHAR NOT NULL, k2 VARBINARY, CONSTRAINT pk PRIMARY KEY (k1,k2 DESC))");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DESC_VARBINARY_NOT_SUPPORTED.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().execute("CREATE TABLE t (k1 VARCHAR PRIMARY KEY)");
            conn.createStatement().execute("ALTER TABLE t ADD k2 VARBINARY PRIMARY KEY DESC");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DESC_VARBINARY_NOT_SUPPORTED.getErrorCode(), e.getErrorCode());
        }
        conn.close();
    }

    @Test
    public void testDivideByZeroExpressionIndex() throws Exception {
        String ddl = "CREATE TABLE t (k1 INTEGER PRIMARY KEY)";
        Connection conn = DriverManager.getConnection(getUrl());
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
            stmt.execute(ddl);
            stmt.execute("CREATE INDEX i ON t (k1/0)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DIVIDE_BY_ZERO.getErrorCode(), e.getErrorCode());
        }
        finally {
            stmt.close();
        }
    }

    @Test
    public void testRegex() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        Statement stmt = conn.createStatement();
        stmt.execute("CREATE TABLE t (k1 INTEGER PRIMARY KEY, v VARCHAR)");

        //character classes
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[abc]') = 'val'");
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[^abc]') = 'val'");
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[a-zA-Z]') = 'val'");
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[a-d[m-p]]') = 'val'");
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[a-z&&[def]]') = 'val'");
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[a-z&&[^bc]]') = 'val'");
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '[a-z&&[^m-p]]') = 'val'");

        // predefined character classes
        stmt.executeQuery("select * from T where REGEXP_SUBSTR(v, '.\\\\d\\\\D\\\\s\\\\S\\\\w\\\\W') = 'val'");
    }

    private static void assertLiteralEquals(Object o, RowProjector p, int i) {
        assertTrue(i < p.getColumnCount());
        Expression e = p.getColumnProjector(i).getExpression();
        assertTrue(e instanceof LiteralExpression);
        LiteralExpression l = (LiteralExpression)e;
        Object lo = l.getValue();
        assertEquals(o, lo);
    }

    @Test
    public void testIntAndLongMinValue() throws Exception {
        BigDecimal oneLessThanMinLong = BigDecimal.valueOf(Long.MIN_VALUE).subtract(BigDecimal.ONE);
        BigDecimal oneMoreThanMaxLong = BigDecimal.valueOf(Long.MAX_VALUE).add(BigDecimal.ONE);
        String query = "SELECT " +
            Integer.MIN_VALUE + "," + Long.MIN_VALUE + "," +
            (Integer.MIN_VALUE+1) + "," + (Long.MIN_VALUE+1) + "," +
            ((long)Integer.MIN_VALUE - 1) + "," + oneLessThanMinLong + "," +
            Integer.MAX_VALUE + "," + Long.MAX_VALUE + "," +
            (Integer.MAX_VALUE - 1) + "," + (Long.MAX_VALUE - 1) + "," +
            ((long)Integer.MAX_VALUE + 1) + "," + oneMoreThanMaxLong +
        " FROM " + "\""+ SYSTEM_CATALOG_SCHEMA + "\".\"" + SYSTEM_STATS_TABLE + "\"" + " LIMIT 1";
        List<Object> binds = Collections.emptyList();
        QueryPlan plan = getQueryPlan(query, binds);
        RowProjector p = plan.getProjector();
        // Negative integers end up as longs once the * -1 occurs
        assertLiteralEquals((long)Integer.MIN_VALUE, p, 0);
        // Min long still stays as long
        assertLiteralEquals(Long.MIN_VALUE, p, 1);
        assertLiteralEquals((long)Integer.MIN_VALUE + 1, p, 2);
        assertLiteralEquals(Long.MIN_VALUE + 1, p, 3);
        assertLiteralEquals((long)Integer.MIN_VALUE - 1, p, 4);
        // Can't fit into long, so becomes BigDecimal
        assertLiteralEquals(oneLessThanMinLong, p, 5);
        // Positive integers stay as ints
        assertLiteralEquals(Integer.MAX_VALUE, p, 6);
        assertLiteralEquals(Long.MAX_VALUE, p, 7);
        assertLiteralEquals(Integer.MAX_VALUE - 1, p, 8);
        assertLiteralEquals(Long.MAX_VALUE - 1, p, 9);
        assertLiteralEquals((long)Integer.MAX_VALUE + 1, p, 10);
        assertLiteralEquals(oneMoreThanMaxLong, p, 11);
    }

    @Test
    public void testMathFunctionOrderByOrderPreservingFwd() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 INTEGER not null, k2 double not null, k3 BIGINT not null, v varchar, constraint pk primary key(k1,k2,k3))");
        /*
         * "SELECT * FROM T ORDER BY k1, k2",
         * "SELECT * FROM T ORDER BY k1, SIGN(k2)",
         * "SELECT * FROM T ORDER BY SIGN(k1), k2",
         */
        List<String> queryList = new ArrayList<String>();
        queryList.add("SELECT * FROM T ORDER BY k1, k2");
        for (String sub : new String[] { "SIGN", "CBRT", "LN", "LOG", "EXP" }) {
            queryList.add(String.format("SELECT * FROM T ORDER BY k1, %s(k2)", sub));
            queryList.add(String.format("SELECT * FROM T ORDER BY %s(k1), k2", sub));
        }
        String[] queries = queryList.toArray(new String[queryList.size()]);
        for (int i = 0; i < queries.length; i++) {
            String query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
        }
        // Negative test
        queryList.clear();
        for (String sub : new String[] { "SIGN", "CBRT", "LN", "LOG", "EXP" }) {
            queryList.add(String.format("SELECT * FROM T WHERE %s(k2)=2.0", sub));
        }
        for (String query : queryList.toArray(new String[queryList.size()])) {
            Scan scan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query).getContext().getScan();
            assertNotNull(scan.getFilter());
            assertTrue(scan.getStartRow().length == 0);
            assertTrue(scan.getStopRow().length == 0);
        }
    }

    @Test
    public void testMathFunctionOrderByOrderPreservingRev() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 INTEGER not null, k2 double not null, k3 BIGINT not null, v varchar, constraint pk primary key(k1,k2 DESC,k3))");
        List<String> queryList = new ArrayList<String>();
        // "SELECT * FROM T ORDER BY k1 DESC, SIGN(k2) DESC, k3 DESC"
        queryList.add("SELECT * FROM T ORDER BY k1 DESC");
        queryList.add("SELECT * FROM T ORDER BY k1 DESC, k2");
        queryList.add("SELECT * FROM T ORDER BY k1 DESC, k2, k3 DESC");
        for (String sub : new String[] { "SIGN", "CBRT", "LN", "LOG", "EXP" }) {
            queryList.add(String.format("SELECT * FROM T ORDER BY k1 DESC, %s(k2) DESC, k3 DESC", sub));
        }
        String[] queries = queryList.toArray(new String[queryList.size()]);
        for (int i = 0; i < queries.length; i++) {
            String query = queries[i];
            QueryPlan plan =
                    conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue(query, plan.getOrderBy() == OrderBy.REV_ROW_KEY_ORDER_BY);
        }
        // Negative test
        queryList.clear();
        for (String sub : new String[] { "SIGN", "CBRT", "LN", "LOG", "EXP" }) {
            queryList.add(String.format("SELECT * FROM T WHERE %s(k2)=2.0", sub));
        }
        for (String query : queryList.toArray(new String[queryList.size()])) {
            Scan scan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query).getContext().getScan();
            assertNotNull(scan.getFilter());
            assertTrue(scan.getStartRow().length == 0);
            assertTrue(scan.getStopRow().length == 0);
        }
    }

    @Test
    public void testOrderByOrderPreservingFwd() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 date not null, k2 date not null, k3 varchar, v varchar, constraint pk primary key(k1,k2,k3))");
        String[] queries = {
                "SELECT * FROM T WHERE k2=CURRENT_DATE() ORDER BY k1, k3",
                "SELECT * FROM T ORDER BY (k1,k2), k3",
                "SELECT * FROM T ORDER BY k1,k2,k3 NULLS FIRST",
                "SELECT * FROM T ORDER BY k1,k2,k3",
                "SELECT * FROM T ORDER BY k1,k2",
                "SELECT * FROM T ORDER BY k1",
                "SELECT * FROM T ORDER BY CAST(k1 AS TIMESTAMP)",
                "SELECT * FROM T ORDER BY (k1,k2,k3)",
                "SELECT * FROM T ORDER BY TRUNC(k1, 'DAY'), CEIL(k2, 'HOUR')",
                "SELECT * FROM T ORDER BY INVERT(k1) DESC",
                "SELECT * FROM T WHERE k1=CURRENT_DATE() ORDER BY k2",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue("Expected order by to be compiled out: " + query, plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
        }
    }

    @Test
    public void testOrderByOrderPreservingRev() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 date not null, k2 date not null, k3 varchar, v varchar, constraint pk primary key(k1,k2 DESC,k3 DESC))");
        String[] queries = {
                "SELECT * FROM T ORDER BY INVERT(k1),k2,k3 nulls last",
                "SELECT * FROM T ORDER BY INVERT(k1),k2",
                "SELECT * FROM T ORDER BY INVERT(k1)",
                 "SELECT * FROM T ORDER BY TRUNC(k1, 'DAY') DESC, CEIL(k2, 'HOUR') DESC",
                "SELECT * FROM T ORDER BY k1 DESC",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue("Expected order by to be compiled out: " + query, plan.getOrderBy() == OrderBy.REV_ROW_KEY_ORDER_BY);
        }
    }

    @Test
    public void testNotOrderByOrderPreserving() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 date not null, k2 varchar, k3 varchar, v varchar, constraint pk primary key(k1,k2,k3 desc))");
        String[] queries = {
                "SELECT * FROM T ORDER BY k1,k2 NULLS LAST",
                "SELECT * FROM T ORDER BY k1,k2, k3 NULLS LAST",
                "SELECT * FROM T ORDER BY k1,k3",
                "SELECT * FROM T ORDER BY SUBSTR(TO_CHAR(k1),1,4)",
                "SELECT * FROM T ORDER BY k2",
                "SELECT * FROM T ORDER BY INVERT(k1),k3",
                "SELECT * FROM T ORDER BY CASE WHEN k1 = CURRENT_DATE() THEN 0 ELSE 1 END",
                "SELECT * FROM T ORDER BY TO_CHAR(k1)",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertFalse("Expected order by not to be compiled out: " + query, plan.getOrderBy().getOrderByExpressions().isEmpty());
        }
    }

    @Test
    public void testNotOrderByOrderPreservingForAggregation() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE IF NOT EXISTS VA_TEST(ID VARCHAR NOT NULL PRIMARY KEY, VAL1 VARCHAR, VAL2 INTEGER)");
        String[] queries = {
                "select distinct ID, VAL1, VAL2 from VA_TEST where \"ID\" in ('ABC','ABD','ABE','ABF','ABG','ABH','AAA', 'AAB', 'AAC','AAD','AAE','AAF') order by VAL1 ASC"
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertFalse("Expected order by not to be compiled out: " + query, plan.getOrderBy().getOrderByExpressions().isEmpty());
        }
    }

    @Test
    public void testGroupByOrderPreserving() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 date not null, k2 date not null, k3 date not null, v varchar, constraint pk primary key(k1,k2,k3))");
        String[] queries = {
                "SELECT 1 FROM T GROUP BY k3, (k1,k2)",
                "SELECT 1 FROM T GROUP BY k2,k1,k3",
                "SELECT 1 FROM T GROUP BY k1,k2",
                "SELECT 1 FROM T GROUP BY k1",
                "SELECT 1 FROM T GROUP BY CAST(k1 AS TIMESTAMP)",
                "SELECT 1 FROM T GROUP BY (k1,k2,k3)",
                "SELECT 1 FROM T GROUP BY TRUNC(k2, 'DAY'), CEIL(k1, 'HOUR')",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue("Expected group by to be order preserving: " + query, plan.getGroupBy().isOrderPreserving());
        }
    }

    @Test
    public void testGroupByOrderPreserving2() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE T (ORGANIZATION_ID char(15) not null, \n" +
                "JOURNEY_ID char(15) not null, \n" +
                "DATASOURCE SMALLINT not null, \n" +
                "MATCH_STATUS TINYINT not null, \n" +
                "EXTERNAL_DATASOURCE_KEY varchar(30), \n" +
                "ENTITY_ID char(15) not null, \n" +
                "CONSTRAINT PK PRIMARY KEY (\n" +
                "    ORGANIZATION_ID, \n" +
                "    JOURNEY_ID, \n" +
                "    DATASOURCE, \n" +
                "    MATCH_STATUS,\n" +
                "    EXTERNAL_DATASOURCE_KEY,\n" +
                "    ENTITY_ID))");
        String[] queries = {
                "SELECT COUNT(1) As DUP_COUNT\n" +
                "    FROM T \n" +
                "   WHERE JOURNEY_ID='07ixx000000004J' AND \n" +
                "                 DATASOURCE=0 AND MATCH_STATUS <= 1 and \n" +
                "                 ORGANIZATION_ID='07ixx000000004J' \n" +
                "    GROUP BY MATCH_STATUS, EXTERNAL_DATASOURCE_KEY \n" +
                "    HAVING COUNT(1) > 1",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue("Expected group by to be order preserving: " + query, plan.getGroupBy().isOrderPreserving());
        }
    }

    @Test
    public void testNotGroupByOrderPreserving() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t (k1 date not null, k2 date not null, k3 date not null, v varchar, constraint pk primary key(k1,k2,k3))");
        String[] queries = {
                "SELECT 1 FROM T GROUP BY k1,k3",
                "SELECT 1 FROM T GROUP BY k2",
                "SELECT 1 FROM T GROUP BY INVERT(k1),k3",
                "SELECT 1 FROM T GROUP BY CASE WHEN k1 = CURRENT_DATE() THEN 0 ELSE 1 END",
                "SELECT 1 FROM T GROUP BY TO_CHAR(k1)",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertFalse("Expected group by not to be order preserving: " + query, plan.getGroupBy().isOrderPreserving());
        }
    }

    @Test
    public void testUseRoundRobinIterator() throws Exception {
        Properties props = new Properties();
        props.setProperty(QueryServices.FORCE_ROW_KEY_ORDER_ATTRIB, Boolean.toString(false));
        Connection conn = DriverManager.getConnection(getUrl(), props);
        conn.createStatement().execute("CREATE TABLE t (k1 char(2) not null, k2 varchar not null, k3 integer not null, v varchar, constraint pk primary key(k1,k2,k3))");
        String[] queries = {
                "SELECT 1 FROM T ",
                "SELECT 1 FROM T WHERE V = 'c'",
                "SELECT 1 FROM T WHERE (k1,k2, k3) > ('a', 'ab', 1)",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertTrue("Expected plan to use round robin iterator " + query, plan.useRoundRobinIterator());
        }
    }

    @Test
    public void testForcingRowKeyOrderNotUseRoundRobinIterator() throws Exception {
        Properties props = new Properties();
        props.setProperty(QueryServices.FORCE_ROW_KEY_ORDER_ATTRIB, Boolean.toString(true));
        Connection conn = DriverManager.getConnection(getUrl(), props);
        testForceRowKeyOrder(conn, false);
        testForceRowKeyOrder(conn, true);
    }

    private void testForceRowKeyOrder(Connection conn, boolean isSalted) throws SQLException {
        String tableName = "tablename" + (isSalted ? "_salt" : "");
        conn.createStatement().execute("CREATE TABLE " + tableName + " (k1 char(2) not null, k2 varchar not null, k3 integer not null, v varchar, constraint pk primary key(k1,k2,k3))");
        String[] queries = {
                "SELECT 1 FROM  " + tableName ,
                "SELECT 1 FROM  " + tableName + "  WHERE V = 'c'",
                "SELECT 1 FROM  " + tableName + "  WHERE (k1, k2, k3) > ('a', 'ab', 1)",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertFalse("Expected plan to not use round robin iterator " + query, plan.useRoundRobinIterator());
        }
    }

    @Test
    public void testPlanForOrderByOrGroupByNotUseRoundRobin() throws Exception {
        Properties props = new Properties();
        props.setProperty(QueryServices.FORCE_ROW_KEY_ORDER_ATTRIB, Boolean.toString(false));
        Connection conn = DriverManager.getConnection(getUrl(), props);
        testOrderByOrGroupByDoesntUseRoundRobin(conn, true);
        testOrderByOrGroupByDoesntUseRoundRobin(conn, false);
    }

    private void testOrderByOrGroupByDoesntUseRoundRobin(Connection conn, boolean salted) throws SQLException {
        String tableName = "orderbygroupbytable" + (salted ? "_salt" : "");
        conn.createStatement().execute("CREATE TABLE " + tableName + " (k1 char(2) not null, k2 varchar not null, k3 integer not null, v varchar, constraint pk primary key(k1,k2,k3))");
        String[] queries = {
                "SELECT 1 FROM  " + tableName + "  ORDER BY K1",
                "SELECT 1 FROM  " + tableName + "  WHERE V = 'c' ORDER BY K1, K2",
                "SELECT 1 FROM  " + tableName + "  WHERE V = 'c' ORDER BY K1, K2, K3",
                "SELECT 1 FROM  " + tableName + "  WHERE V = 'c' ORDER BY K3",
                "SELECT 1 FROM  " + tableName + "  WHERE (k1,k2, k3) > ('a', 'ab', 1) ORDER BY V",
                "SELECT 1 FROM  " + tableName + "  GROUP BY V",
                "SELECT 1 FROM  " + tableName + "  GROUP BY K1, V, K2 ORDER BY V",
                };
        String query;
        for (int i = 0; i < queries.length; i++) {
            query = queries[i];
            QueryPlan plan = conn.createStatement().unwrap(PhoenixStatement.class).compileQuery(query);
            assertFalse("Expected plan to not use round robin iterator " + query, plan.useRoundRobinIterator());
        }
    }

    @Test
    public void testSelectColumnsInOneFamily() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        Statement statement = conn.createStatement();
        try {
            // create table with specified column family.
            String create = "CREATE TABLE t (k integer not null primary key, f1.v1 varchar, f1.v2 varchar, f2.v3 varchar, v4 varchar)";
            statement.execute(create);
            // select columns in one family.
            String query = "SELECT f1.*, v4 FROM t";
            ResultSetMetaData rsMeta = statement.executeQuery(query).getMetaData();
            assertEquals("V1", rsMeta.getColumnName(1));
            assertEquals("V2", rsMeta.getColumnName(2));
            assertEquals("V4", rsMeta.getColumnName(3));
        } finally {
            statement.execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testSelectColumnsInOneFamilyWithSchema() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        Statement statement = conn.createStatement();
        try {
            // create table with specified column family.
            String create = "CREATE TABLE s.t (k integer not null primary key, f1.v1 varchar, f1.v2 varchar, f2.v3 varchar, v4 varchar)";
            statement.execute(create);
            // select columns in one family.
            String query = "SELECT f1.*, v4 FROM s.t";
            ResultSetMetaData rsMeta = statement.executeQuery(query).getMetaData();
            assertEquals("V1", rsMeta.getColumnName(1));
            assertEquals("V2", rsMeta.getColumnName(2));
            assertEquals("V4", rsMeta.getColumnName(3));
        } finally {
            statement.execute("DROP TABLE IF EXISTS s.t");
            conn.close();
        }
    }

     @Test
     public void testNoFromClauseSelect() throws Exception {
         Connection conn = DriverManager.getConnection(getUrl());
         ResultSet rs = conn.createStatement().executeQuery("SELECT 2 * 3 * 4, 5 + 1");
         assertTrue(rs.next());
         assertEquals(24, rs.getInt(1));
         assertEquals(6, rs.getInt(2));
         assertFalse(rs.next());

         String query =
                 "SELECT 'a' AS col\n" +
                 "UNION ALL\n" +
                 "SELECT 'b' AS col\n" +
                 "UNION ALL\n" +
                 "SELECT 'c' AS col";
         rs = conn.createStatement().executeQuery(query);
         assertTrue(rs.next());
         assertEquals("a", rs.getString(1));
         assertTrue(rs.next());
         assertEquals("b", rs.getString(1));
         assertTrue(rs.next());
         assertEquals("c", rs.getString(1));
         assertFalse(rs.next());

         rs = conn.createStatement().executeQuery("SELECT * FROM (" + query + ")");
         assertTrue(rs.next());
         assertEquals("a", rs.getString(1));
         assertTrue(rs.next());
         assertEquals("b", rs.getString(1));
         assertTrue(rs.next());
         assertEquals("c", rs.getString(1));
         assertFalse(rs.next());
     }


     @Test
     public void testFailNoFromClauseSelect() throws Exception {
         Connection conn = DriverManager.getConnection(getUrl());
         try {
             try {
                 conn.createStatement().executeQuery("SELECT foo, bar");
                 fail("Should have got ColumnNotFoundException");
             } catch (ColumnNotFoundException e) {
             }

             try {
                 conn.createStatement().executeQuery("SELECT *");
                 fail("Should have got SQLException");
             } catch (SQLException e) {
                 assertEquals(SQLExceptionCode.NO_TABLE_SPECIFIED_FOR_WILDCARD_SELECT.getErrorCode(), e.getErrorCode());
             }

             try {
                 conn.createStatement().executeQuery("SELECT A.*");
                 fail("Should have got SQLException");
             } catch (SQLException e) {
                 assertEquals(SQLExceptionCode.NO_TABLE_SPECIFIED_FOR_WILDCARD_SELECT.getErrorCode(), e.getErrorCode());
             }
         } finally {
             conn.close();
         }
     }

    @Test
    public void testServerArrayElementProjection1() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t(a INTEGER PRIMARY KEY, arr INTEGER ARRAY)");
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN SELECT arr[1] from t");
            assertTrue(QueryUtil.getExplainPlan(rs).contains("    SERVER ARRAY ELEMENT PROJECTION"));
        } finally {
            conn.createStatement().execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testServerArrayElementProjection2() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t(a INTEGER PRIMARY KEY, arr INTEGER ARRAY)");
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN SELECT arr, arr[1] from t");
            assertFalse(QueryUtil.getExplainPlan(rs).contains("    SERVER ARRAY ELEMENT PROJECTION"));
        } finally {
            conn.createStatement().execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testServerArrayElementProjection3() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t(a INTEGER PRIMARY KEY, arr INTEGER ARRAY, arr2 VARCHAR ARRAY)");
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN SELECT arr, arr[1], arr2[1] from t");
            assertTrue(QueryUtil.getExplainPlan(rs).contains("    SERVER ARRAY ELEMENT PROJECTION"));
        } finally {
            conn.createStatement().execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testServerArrayElementProjection4() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (p INTEGER PRIMARY KEY, arr1 INTEGER ARRAY, arr2 INTEGER ARRAY)");
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN SELECT arr1, arr1[1], ARRAY_APPEND(ARRAY_APPEND(arr1, arr2[2]), arr2[1]), p from t");
            assertTrue(QueryUtil.getExplainPlan(rs).contains("    SERVER ARRAY ELEMENT PROJECTION"));
        } finally {
            conn.createStatement().execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testArrayAppendSingleArg() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (p INTEGER PRIMARY KEY, arr1 INTEGER ARRAY, arr2 INTEGER ARRAY)");
            conn.createStatement().executeQuery("SELECT ARRAY_APPEND(arr2) from t");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.FUNCTION_UNDEFINED.getErrorCode(),e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testArrayPrependSingleArg() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (p INTEGER PRIMARY KEY, arr1 INTEGER ARRAY, arr2 INTEGER ARRAY)");
            conn.createStatement().executeQuery("SELECT ARRAY_PREPEND(arr2) from t");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.FUNCTION_UNDEFINED.getErrorCode(),e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testArrayConcatSingleArg() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (p INTEGER PRIMARY KEY, arr1 INTEGER ARRAY, arr2 INTEGER ARRAY)");
            conn.createStatement().executeQuery("SELECT ARRAY_CAT(arr2) from t");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.FUNCTION_UNDEFINED.getErrorCode(),e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testServerArrayElementProjection5() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t (p INTEGER PRIMARY KEY, arr1 INTEGER ARRAY, arr2 INTEGER ARRAY)");
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN SELECT arr1, arr1[1], ARRAY_ELEM(ARRAY_APPEND(arr1, arr2[1]), 1), p, arr2[2] from t");
            assertTrue(QueryUtil.getExplainPlan(rs).contains("    SERVER ARRAY ELEMENT PROJECTION"));
        } finally {
            conn.createStatement().execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testServerArrayElementProjectionWithArrayPrimaryKey() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t(arr INTEGER ARRAY PRIMARY KEY)");
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN SELECT arr[1] from t");
            assertFalse(QueryUtil.getExplainPlan(rs).contains("    SERVER ARRAY ELEMENT PROJECTION"));
        } finally {
            conn.createStatement().execute("DROP TABLE IF EXISTS t");
            conn.close();
        }
    }

    @Test
    public void testAddingRowTimestampColumn() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        // Column of type VARCHAR cannot be declared as ROW_TIMESTAMP
        try {
            conn.createStatement().execute("CREATE TABLE T1 (PK1 VARCHAR NOT NULL, PK2 VARCHAR NOT NULL, KV1 VARCHAR CONSTRAINT PK PRIMARY KEY(PK1, PK2 ROW_TIMESTAMP)) ");
            fail("Varchar column cannot be added as row_timestamp");
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.ROWTIMESTAMP_COL_INVALID_TYPE.getErrorCode(), e.getErrorCode());
        }
        // Column of type INTEGER cannot be declared as ROW_TIMESTAMP
        try {
            conn.createStatement().execute("CREATE TABLE T1 (PK1 VARCHAR NOT NULL, PK2 INTEGER NOT NULL, KV1 VARCHAR CONSTRAINT PK PRIMARY KEY(PK1, PK2 ROW_TIMESTAMP)) ");
            fail("Integer column cannot be added as row_timestamp");
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.ROWTIMESTAMP_COL_INVALID_TYPE.getErrorCode(), e.getErrorCode());
        }
        // Column of type DOUBLE cannot be declared as ROW_TIMESTAMP
        try {
            conn.createStatement().execute("CREATE TABLE T1 (PK1 VARCHAR NOT NULL, PK2 DOUBLE NOT NULL, KV1 VARCHAR CONSTRAINT PK PRIMARY KEY(PK1, PK2 ROW_TIMESTAMP)) ");
            fail("Double column cannot be added as row_timestamp");
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.ROWTIMESTAMP_COL_INVALID_TYPE.getErrorCode(), e.getErrorCode());
        }
        // Invalid - two columns declared as row_timestamp in pk constraint
        try {
            conn.createStatement().execute("CREATE TABLE T2 (PK1 DATE NOT NULL, PK2 DATE NOT NULL, KV1 VARCHAR CONSTRAINT PK PRIMARY KEY(PK1 ROW_TIMESTAMP , PK2 ROW_TIMESTAMP)) ");
            fail("Creating table with two row_timestamp columns should fail");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.ROWTIMESTAMP_ONE_PK_COL_ONLY.getErrorCode(), e.getErrorCode());
        }

        // Invalid because only (unsigned)date, time, long, (unsigned)timestamp are valid data types for column to be declared as row_timestamp
        try {
            conn.createStatement().execute("CREATE TABLE T5 (PK1 VARCHAR PRIMARY KEY ROW_TIMESTAMP, PK2 VARCHAR, KV1 VARCHAR)");
            fail("Creating table with a key value column as row_timestamp should fail");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.ROWTIMESTAMP_COL_INVALID_TYPE.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testGroupByVarbinaryOrArray() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE T1 (PK VARCHAR PRIMARY KEY, c1 VARCHAR, c2 VARBINARY, C3 VARCHAR ARRAY, c4 VARBINARY, C5 VARCHAR ARRAY, C6 BINARY(10)) ");
        try {
            conn.createStatement().executeQuery("SELECT c1 FROM t1 GROUP BY c1,c2,c3");
            fail();
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.UNSUPPORTED_GROUP_BY_EXPRESSIONS.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().executeQuery("SELECT c1 FROM t1 GROUP BY c1,c3,c2");
            fail();
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.UNSUPPORTED_GROUP_BY_EXPRESSIONS.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().executeQuery("SELECT c1 FROM t1 GROUP BY c1,c2,c4");
            fail();
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.UNSUPPORTED_GROUP_BY_EXPRESSIONS.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().executeQuery("SELECT c1 FROM t1 GROUP BY c1,c3,c5");
            fail();
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.UNSUPPORTED_GROUP_BY_EXPRESSIONS.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().executeQuery("SELECT c1 FROM t1 GROUP BY c1,c6,c5");
            fail();
        } catch(SQLException e) {
            assertEquals(SQLExceptionCode.UNSUPPORTED_GROUP_BY_EXPRESSIONS.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testDMLOfNonIndexWithBuildIndexAt() throws Exception {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props);) {
            conn.createStatement().execute(
                    "CREATE TABLE t (k VARCHAR NOT NULL PRIMARY KEY, v1 VARCHAR)");
        }
        props.put(PhoenixRuntime.BUILD_INDEX_AT_ATTRIB, Long.toString(EnvironmentEdgeManager.currentTimeMillis()+1));
        try (Connection conn = DriverManager.getConnection(getUrl(), props);) {
            try {
            	conn.createStatement().execute("UPSERT INTO T (k,v1) SELECT k,v1 FROM T");
                fail();
            } catch (SQLException e) {
                assertEquals("Unexpected Exception",
                        SQLExceptionCode.ONLY_INDEX_UPDATABLE_AT_SCN
                                .getErrorCode(), e.getErrorCode());
            }
        }
    }

    @Test
    public void testNegativeGuidePostWidth() throws Exception {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props);) {
            try {
                conn.createStatement().execute(
                        "CREATE TABLE t (k VARCHAR NOT NULL PRIMARY KEY, v1 VARCHAR) GUIDE_POSTS_WIDTH = -1");
                fail();
            } catch (SQLException e) {
                assertEquals("Unexpected Exception",
                        SQLExceptionCode.PARSER_ERROR
                                .getErrorCode(), e.getErrorCode());
            }
        }
    }

    private static void assertFamilies(Scan s, String... families) {
        assertEquals(families.length, s.getFamilyMap().size());
        for (String fam : families) {
            byte[] cf = Bytes.toBytes(fam);
            assertTrue("Expected to contain " + fam, s.getFamilyMap().containsKey(cf));
        }
    }

    @Test
    public void testProjection() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t(k INTEGER PRIMARY KEY, a.v1 VARCHAR, b.v2 VARCHAR, c.v3 VARCHAR)");
            assertFamilies(projectQuery("SELECT k FROM t"), "A");
            assertFamilies(projectQuery("SELECT k FROM t WHERE k = 5"), "A");
            assertFamilies(projectQuery("SELECT v2 FROM t WHERE k = 5"), "A", "B");
            assertFamilies(projectQuery("SELECT v2 FROM t WHERE v2 = 'a'"), "B");
            assertFamilies(projectQuery("SELECT v3 FROM t WHERE v2 = 'a'"), "B", "C");
            assertFamilies(projectQuery("SELECT v3 FROM t WHERE v2 = 'a' AND v3 is null"), "A", "B", "C");
        } finally {
            conn.close();
        }
    }

    private static boolean hasColumnProjectionFilter(Scan scan) {
        Iterator<Filter> iterator = ScanUtil.getFilterIterator(scan);
        while (iterator.hasNext()) {
            Filter filter = iterator.next();
            if (filter instanceof EncodedQualifiersColumnProjectionFilter) {
                return true;
            }
        }
        return false;
    }

    @Test
    public void testColumnProjectionOptimized() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t(k INTEGER PRIMARY KEY, a.v1 VARCHAR, a.v1b VARCHAR, b.v2 VARCHAR, c.v3 VARCHAR)");
            assertTrue(hasColumnProjectionFilter(projectQuery("SELECT k, v1 FROM t WHERE v2 = 'foo'")));
            assertFalse(hasColumnProjectionFilter(projectQuery("SELECT k, v1 FROM t WHERE v1 = 'foo'")));
            assertFalse(hasColumnProjectionFilter(projectQuery("SELECT v1,v2 FROM t WHERE v1 = 'foo'")));
            assertTrue(hasColumnProjectionFilter(projectQuery("SELECT v1,v2 FROM t WHERE v1 = 'foo' and v2 = 'bar' and v3 = 'bas'")));
            assertFalse(hasColumnProjectionFilter(projectQuery("SELECT a.* FROM t WHERE v1 = 'foo' and v1b = 'bar'")));
        } finally {
            conn.close();
        }
    }
    @Test
    public void testOrderByWithNoProjection() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("create table x (id integer primary key, A.i1 integer," +
                    " B.i2 integer)");
            Scan scan = projectQuery("select A.i1 from X group by i1 order by avg(B.i2) " +
                    "desc");
            ServerAggregators aggregators = ServerAggregators.deserialize(scan.getAttribute
                    (BaseScannerRegionObserver.AGGREGATORS), null, null);
            assertEquals(2,aggregators.getAggregatorCount());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testColumnProjectionUnionAll() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1(k INTEGER PRIMARY KEY,"+
                    " col1 CHAR(8), col2 VARCHAR(10), col3 decimal(10,2))");
            conn.createStatement().execute("CREATE TABLE t2(k TINYINT PRIMARY KEY," +
                    " col1 CHAR(20), col2 CHAR(30), col3 double)");
            QueryPlan plan = getQueryPlan("SELECT * from t1 union all select * from t2",
                Collections.emptyList());
            RowProjector rowProj = plan.getProjector();
            assertTrue(rowProj.getColumnProjector(0).getExpression().getDataType()
                instanceof PInteger);
            assertTrue(rowProj.getColumnProjector(1).getExpression().getDataType()
                instanceof PChar);
            assertTrue(rowProj.getColumnProjector(1).getExpression().getMaxLength() == 20);
            assertTrue(rowProj.getColumnProjector(2).getExpression().getDataType()
                instanceof PVarchar);
            assertTrue(rowProj.getColumnProjector(2).getExpression().getMaxLength() == 30);
            assertTrue(rowProj.getColumnProjector(3).getExpression().getDataType()
                instanceof PDecimal);
            assertTrue(rowProj.getColumnProjector(3).getExpression().getScale() == 2);
        } finally {
            conn.close();
        }
    }

    @Test
    public void testFuncIndexUsage() throws SQLException {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1(k INTEGER PRIMARY KEY,"+
                    " col1 VARCHAR, col2 VARCHAR)");
            conn.createStatement().execute("CREATE TABLE t2(k INTEGER PRIMARY KEY," +
                    " col1 VARCHAR, col2 VARCHAR)");
            conn.createStatement().execute("CREATE TABLE t3(j INTEGER PRIMARY KEY," +
                    " col3 VARCHAR, col4 VARCHAR)");
            conn.createStatement().execute("CREATE INDEX idx ON t1 (col1 || col2)");
            String query = "SELECT a.k from t1 a where a.col1 || a.col2 = 'foobar'";
            ResultSet rs = conn.createStatement().executeQuery("EXPLAIN "+query);
            String explainPlan = QueryUtil.getExplainPlan(rs);
            assertEquals("CLIENT PARALLEL 1-WAY RANGE SCAN OVER IDX ['foobar']\n" +
                    "    SERVER FILTER BY FIRST KEY ONLY",explainPlan);
            query = "SELECT k,j from t3 b join t1 a ON k = j where a.col1 || a.col2 = 'foobar'";
            rs = conn.createStatement().executeQuery("EXPLAIN "+query);
            explainPlan = QueryUtil.getExplainPlan(rs);
            assertEquals("CLIENT PARALLEL 1-WAY FULL SCAN OVER T3\n" +
                    "    SERVER FILTER BY FIRST KEY ONLY\n" +
                    "    PARALLEL INNER-JOIN TABLE 0\n" +
                    "        CLIENT PARALLEL 1-WAY RANGE SCAN OVER IDX ['foobar']\n" +
                    "            SERVER FILTER BY FIRST KEY ONLY\n" +
                    "    DYNAMIC SERVER FILTER BY B.J IN (\"A.:K\")",explainPlan);
            query = "SELECT a.k,b.k from t2 b join t1 a ON a.k = b.k where a.col1 || a.col2 = 'foobar'";
            rs = conn.createStatement().executeQuery("EXPLAIN "+query);
            explainPlan = QueryUtil.getExplainPlan(rs);
            assertEquals("CLIENT PARALLEL 1-WAY FULL SCAN OVER T2\n" +
                    "    SERVER FILTER BY FIRST KEY ONLY\n" +
                    "    PARALLEL INNER-JOIN TABLE 0\n" +
                    "        CLIENT PARALLEL 1-WAY RANGE SCAN OVER IDX ['foobar']\n" +
                    "            SERVER FILTER BY FIRST KEY ONLY\n" +
                    "    DYNAMIC SERVER FILTER BY B.K IN (\"A.:K\")",explainPlan);
        } finally {
            conn.close();
        }
    }

    @Test
    public void testSaltTableJoin() throws Exception{

        PhoenixConnection conn = (PhoenixConnection)DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("drop table if exists SALT_TEST2900");

            conn.createStatement().execute(
                "create table SALT_TEST2900"+
                        "("+
                        "id UNSIGNED_INT not null primary key,"+
                        "appId VARCHAR"+
                    ")SALT_BUCKETS=2");



            conn.createStatement().execute("drop table if exists RIGHT_TEST2900 ");
            conn.createStatement().execute(
                "create table RIGHT_TEST2900"+
                        "("+
                        "appId VARCHAR not null primary key,"+
                        "createTime VARCHAR"+
                    ")");


            String sql="select * from SALT_TEST2900 a inner join RIGHT_TEST2900 b on a.appId=b.appId where a.id>=3 and a.id<=5";
            HashJoinPlan plan = (HashJoinPlan)getQueryPlan(sql, Collections.emptyList());
            ScanRanges ranges=plan.getContext().getScanRanges();

            List<HRegionLocation> regionLocations=
                    conn.getQueryServices().getAllTableRegions(Bytes.toBytes("SALT_TEST2900"));
            for (HRegionLocation regionLocation : regionLocations) {
                assertTrue(ranges.intersectRegion(regionLocation.getRegion().getStartKey(),
                    regionLocation.getRegion().getEndKey(), false));
            }
        } finally {
            conn.close();
        }
    }

    @Test
    public void testStatefulDefault() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY, " +
                "datecol DATE DEFAULT CURRENT_DATE())";

        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CANNOT_CREATE_DEFAULT.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testAlterTableStatefulDefault() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY)";
        String ddl2 = "ALTER TABLE table_with_default " +
                "ADD datecol DATE DEFAULT CURRENT_DATE()";

        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute(ddl);
        try {
            conn.createStatement().execute(ddl2);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CANNOT_CREATE_DEFAULT.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testDefaultTypeMismatch() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY, " +
                "v VARCHAR DEFAULT 1)";

        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testAlterTableDefaultTypeMismatch() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY)";
        String ddl2 = "ALTER TABLE table_with_default " +
                "ADD v CHAR(3) DEFAULT 1";

        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute(ddl);
        try {
            conn.createStatement().execute(ddl2);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testDefaultTypeMismatchInView() throws Exception {
        String ddl1 = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY, " +
                "v VARCHAR DEFAULT 'foo')";
        String ddl2 = "CREATE VIEW my_view(v2 VARCHAR DEFAULT 1) AS SELECT * FROM table_with_default";

        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute(ddl1);
        try {
            conn.createStatement().execute(ddl2);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testDefaultRowTimestamp1() throws Exception {
        String ddl = "CREATE TABLE IF NOT EXISTS table_with_defaults ("
                + "pk1 INTEGER NOT NULL,"
                + "pk2 BIGINT NOT NULL DEFAULT 5,"
                + "CONSTRAINT NAME_PK PRIMARY KEY (pk1, pk2 ROW_TIMESTAMP))";

        Connection conn = DriverManager.getConnection(getUrl());

        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (SQLException e) {
            assertEquals(
                    SQLExceptionCode.CANNOT_CREATE_DEFAULT_ROWTIMESTAMP.getErrorCode(),
                    e.getErrorCode());
        }
    }

    @Test
    public void testDefaultRowTimestamp2() throws Exception {
        String ddl = "CREATE TABLE table_with_defaults ("
                + "k BIGINT DEFAULT 5 PRIMARY KEY ROW_TIMESTAMP)";

        Connection conn = DriverManager.getConnection(getUrl());

        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (SQLException e) {
            assertEquals(
                    SQLExceptionCode.CANNOT_CREATE_DEFAULT_ROWTIMESTAMP.getErrorCode(),
                    e.getErrorCode());
        }
    }

    @Test
    public void testDefaultSizeMismatch() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY, " +
                "v CHAR(3) DEFAULT 'foobar')";

        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute(ddl);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DATA_EXCEEDS_MAX_CAPACITY.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testAlterTableDefaultSizeMismatch() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY)";
        String ddl2 = "ALTER TABLE table_with_default " +
                "ADD v CHAR(3) DEFAULT 'foobar'";

        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute(ddl);
        try {
            conn.createStatement().execute(ddl2);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DATA_EXCEEDS_MAX_CAPACITY.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testNullDefaultRemoved() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY, " +
                "v VARCHAR DEFAULT null)";

        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute(ddl);
        PTable table = conn.unwrap(PhoenixConnection.class).getMetaDataCache()
                .getTableRef(new PTableKey(null,"TABLE_WITH_DEFAULT")).getTable();
        assertNull(table.getColumnForColumnName("V").getExpressionStr());
    }

    @Test
    public void testNullAlterTableDefaultRemoved() throws Exception {
        String ddl = "CREATE TABLE table_with_default (" +
                "pk INTEGER PRIMARY KEY)";
        String ddl2 = "ALTER TABLE table_with_default " +
                "ADD v CHAR(3) DEFAULT null";

        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute(ddl);
        conn.createStatement().execute(ddl2);
        PTable table = conn.unwrap(PhoenixConnection.class).getMetaDataCache()
                .getTableRef(new PTableKey(null,"TABLE_WITH_DEFAULT")).getTable();
        assertNull(table.getColumnForColumnName("V").getExpressionStr());
    }

    @Test
    public void testIndexOnViewWithChildView() throws SQLException {
        try (Connection conn = DriverManager.getConnection(getUrl())) {
            conn.createStatement().execute("CREATE TABLE PLATFORM_ENTITY.GLOBAL_TABLE (\n" +
                    "    ORGANIZATION_ID CHAR(15) NOT NULL,\n" +
                    "    KEY_PREFIX CHAR(3) NOT NULL,\n" +
                    "    CREATED_DATE DATE,\n" +
                    "    CREATED_BY CHAR(15),\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        ORGANIZATION_ID,\n" +
                    "        KEY_PREFIX\n" +
                    "    )\n" +
                    ") VERSIONS=1, IMMUTABLE_ROWS=true, MULTI_TENANT=true");
            conn.createStatement().execute("CREATE VIEW PLATFORM_ENTITY.GLOBAL_VIEW  (\n" +
                    "    INT1 BIGINT NOT NULL,\n" +
                    "    DOUBLE1 DECIMAL(12, 3),\n" +
                    "    IS_BOOLEAN BOOLEAN,\n" +
                    "    TEXT1 VARCHAR,\n" +
                    "    CONSTRAINT PKVIEW PRIMARY KEY\n" +
                    "    (\n" +
                    "        INT1\n" +
                    "    )\n" +
                    ")\n" +
                    "AS SELECT * FROM PLATFORM_ENTITY.GLOBAL_TABLE WHERE KEY_PREFIX = '123'");
            conn.createStatement().execute("CREATE INDEX GLOBAL_INDEX\n" +
                    "ON PLATFORM_ENTITY.GLOBAL_VIEW (TEXT1 DESC, INT1)\n" +
                    "INCLUDE (CREATED_BY, DOUBLE1, IS_BOOLEAN, CREATED_DATE)");
            String query = "SELECT DOUBLE1 FROM PLATFORM_ENTITY.GLOBAL_VIEW\n"
                    + "WHERE ORGANIZATION_ID = '00Dxx0000002Col' AND TEXT1='Test' AND INT1=1";
            QueryPlan plan = getOptimizedQueryPlan(query);
            assertEquals("PLATFORM_ENTITY.GLOBAL_VIEW", plan.getContext().getCurrentTable().getTable().getName()
                    .getString());
            query = "SELECT DOUBLE1 FROM PLATFORM_ENTITY.GLOBAL_VIEW\n"
                    + "WHERE ORGANIZATION_ID = '00Dxx0000002Col' AND TEXT1='Test'";
            plan = getOptimizedQueryPlan(query);
            assertEquals("PLATFORM_ENTITY.GLOBAL_INDEX", plan.getContext().getCurrentTable().getTable().getName().getString());
        }
    }

    @Test
    public void testNotNullKeyValueColumnSalted() throws Exception {
        testNotNullKeyValueColumn(3);
    }
    @Test
    public void testNotNullKeyValueColumnUnsalted() throws Exception {
        testNotNullKeyValueColumn(0);
    }

    private void testNotNullKeyValueColumn(int saltBuckets) throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1 (k integer not null primary key, v bigint not null) IMMUTABLE_ROWS=true" + (saltBuckets == 0 ? "" : (",SALT_BUCKETS="+saltBuckets)));
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CONSTRAINT_VIOLATION.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().execute("CREATE TABLE t2 (k integer not null primary key, v1 bigint not null, v2 varchar, v3 tinyint not null) IMMUTABLE_ROWS=true" + (saltBuckets == 0 ? "" : (",SALT_BUCKETS="+saltBuckets)));
            conn.createStatement().execute("UPSERT INTO t2(k, v3) VALUES(0,0)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CONSTRAINT_VIOLATION.getErrorCode(), e.getErrorCode());
        }
        try {
            conn.createStatement().execute("CREATE TABLE t3 (k integer not null primary key, v1 bigint not null, v2 varchar, v3 tinyint not null) IMMUTABLE_ROWS=true" + (saltBuckets == 0 ? "" : (",SALT_BUCKETS="+saltBuckets)));
            conn.createStatement().execute("UPSERT INTO t3(k, v1) VALUES(0,0)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CONSTRAINT_VIOLATION.getErrorCode(), e.getErrorCode());
        }
        conn.createStatement().execute("CREATE TABLE t4 (k integer not null primary key, v1 bigint not null) IMMUTABLE_ROWS=true" + (saltBuckets == 0 ? "" : (",SALT_BUCKETS="+saltBuckets)));
        conn.createStatement().execute("UPSERT INTO t4 VALUES(0,0)");
        conn.createStatement().execute("CREATE TABLE t5 (k integer not null primary key, v1 bigint not null default 0) IMMUTABLE_ROWS=true" + (saltBuckets == 0 ? "" : (",SALT_BUCKETS="+saltBuckets)));
        conn.createStatement().execute("UPSERT INTO t5 VALUES(0)");
        conn.close();
    }

    @Test
    public void testAlterAddNotNullKeyValueColumn() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t1 (k integer not null primary key, v1 bigint not null) IMMUTABLE_ROWS=true");
        try {
            conn.createStatement().execute("ALTER TABLE t1 ADD k2 bigint not null primary key");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.NOT_NULLABLE_COLUMN_IN_ROW_KEY.getErrorCode(), e.getErrorCode());
        }
        conn.createStatement().execute("ALTER TABLE t1 ADD v2 bigint not null");
        try {
            conn.createStatement().execute("UPSERT INTO t1(k, v1) VALUES(0,0)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CONSTRAINT_VIOLATION.getErrorCode(), e.getErrorCode());
        }
        conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0,0)");
        conn.createStatement().execute("UPSERT INTO t1(v1,k,v2) VALUES(0,0,0)");
    }

    @Test
    public void testOnDupKeyForImmutableTable() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1 (k integer not null primary key, v bigint) IMMUTABLE_ROWS=true");
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE v = v + 1");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CANNOT_USE_ON_DUP_KEY_FOR_IMMUTABLE.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testOnDupKeyWithGlobalIndex() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1 (k integer not null primary key, v bigint)");
            conn.createStatement().execute("CREATE INDEX idx ON t1 (v)");
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE v = v + 1");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CANNOT_USE_ON_DUP_KEY_WITH_GLOBAL_IDX.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testUpdatePKOnDupKey() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1 (k1 integer not null, k2 integer not null, v bigint, constraint pk primary key (k1,k2))");
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE k2 = v + 1");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.CANNOT_UPDATE_PK_ON_DUP_KEY.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testOnDupKeyTypeMismatch() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1 (k1 integer not null, k2 integer not null, v1 bigint, v2 varchar, constraint pk primary key (k1,k2))");
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE v1 = v2 || 'a'");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testDuplicateColumnOnDupKeyUpdate() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        try {
            conn.createStatement().execute("CREATE TABLE t1 (k1 integer not null, k2 integer not null, v1 bigint, v2 bigint, constraint pk primary key (k1,k2))");
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE v1 = v1 + 1, v1 = v2 + 2");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.DUPLICATE_COLUMN_IN_ON_DUP_KEY.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testAggregationInOnDupKey() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t1 (k1 integer not null, k2 integer not null, v bigint, constraint pk primary key (k1,k2))");
        try {
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE v = sum(v)");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.AGGREGATION_NOT_ALLOWED_IN_ON_DUP_KEY.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testSequenceInOnDupKey() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.createStatement().execute("CREATE TABLE t1 (k1 integer not null, k2 integer not null, v bigint, constraint pk primary key (k1,k2))");
        conn.createStatement().execute("CREATE SEQUENCE s1");
        try {
            conn.createStatement().execute("UPSERT INTO t1 VALUES(0,0) ON DUPLICATE KEY UPDATE v = next value for s1");
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.INVALID_USE_OF_NEXT_VALUE_FOR.getErrorCode(), e.getErrorCode());
        } finally {
            conn.close();
        }
    }

    @Test
    public void testOrderPreservingGroupBy() throws Exception {
        try (Connection conn= DriverManager.getConnection(getUrl())) {

            conn.createStatement().execute("CREATE TABLE test (\n" +
                    "            pk1 INTEGER NOT NULL,\n" +
                    "            pk2 INTEGER NOT NULL,\n" +
                    "            pk3 INTEGER NOT NULL,\n" +
                    "            pk4 INTEGER NOT NULL,\n" +
                    "            v1 INTEGER,\n" +
                    "            CONSTRAINT pk PRIMARY KEY (\n" +
                    "               pk1,\n" +
                    "               pk2,\n" +
                    "               pk3,\n" +
                    "               pk4\n" +
                    "             )\n" +
                    "         )");
            String[] queries = new String[] {
                    "SELECT pk3 FROM test WHERE pk2 = 1 GROUP BY pk2+1,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk2 = 1 GROUP BY pk2,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 and pk2 = 2 GROUP BY pk1+pk2,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 and pk2 = 2 GROUP BY pk4,CASE WHEN pk1 > pk2 THEN pk1 ELSE pk2 END,pk3 ORDER BY pk4,pk3",
            };
            int index = 0;
            for (String query : queries) {
                QueryPlan plan = getQueryPlan(conn, query);
                assertTrue((index + 1) + ") " + queries[index], plan.getOrderBy().getOrderByExpressions().isEmpty());
                index++;
            }
        }
    }

    @Test
    public void testOrderPreservingGroupByForNotPkColumns() throws Exception {
         try (Connection conn= DriverManager.getConnection(getUrl())) {
             conn.createStatement().execute("CREATE TABLE test (\n" +
                    "            pk1 varchar, \n" +
                    "            pk2 varchar, \n" +
                    "            pk3 varchar, \n" +
                    "            pk4 varchar, \n" +
                    "            v1 varchar, \n" +
                    "            v2 varchar,\n" +
                    "            CONSTRAINT pk PRIMARY KEY (\n" +
                    "               pk1,\n" +
                    "               pk2,\n" +
                    "               pk3,\n" +
                    "               pk4\n" +
                    "             )\n" +
                    "         )");
            String[] queries = new String[] {
                    "SELECT pk3 FROM test WHERE v2 = 'a' GROUP BY substr(v2,0,1),pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 'c' and v2 = substr('abc',1,1) GROUP BY v2,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE v1 = 'a' and v2 = 'b' GROUP BY length(v1)+length(v2),pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 'a' and v2 = 'b' GROUP BY length(pk1)+length(v2),pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE v1 = 'a' and v2 = substr('abc',2,1) GROUP BY pk4,CASE WHEN v1 > v2 THEN v1 ELSE v2 END,pk3 ORDER BY pk4,pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 'a' and v2 = substr('abc',2,1) GROUP BY pk4,CASE WHEN pk1 > v2 THEN pk1 ELSE v2 END,pk3 ORDER BY pk4,pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 'a' and pk2 = 'b' and v1 = 'c' GROUP BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3 ORDER BY pk3"
            };
            int index = 0;
            for (String query : queries) {
                QueryPlan plan = getQueryPlan(conn, query);
                assertTrue((index + 1) + ") " + queries[index], plan.getOrderBy().getOrderByExpressions().isEmpty());
                index++;
            }
        }
    }

    @Test
    public void testOrderPreservingGroupByForClientAggregatePlan() throws Exception {
        Connection conn = null;
         try {
             conn = DriverManager.getConnection(getUrl());
             String tableName = "test_table";
             String sql = "create table " + tableName + "( "+
                     " pk1 varchar not null , " +
                     " pk2 varchar not null, " +
                     " pk3 varchar not null," +
                     " v1 varchar, " +
                     " v2 varchar, " +
                     " CONSTRAINT TEST_PK PRIMARY KEY ( "+
                        "pk1,"+
                        "pk2,"+
                        "pk3 ))";
             conn.createStatement().execute(sql);

             String[] queries = new String[] {
                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "group by a.ak3,a.av1 order by a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av2 = 'a' GROUP BY substr(a.av2,0,1),ak3 ORDER BY ak3",

                   //for InListExpression
                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av2 in('a') GROUP BY substr(a.av2,0,1),ak3 ORDER BY ak3",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 'c' and a.av2 = substr('abc',1,1) GROUP BY a.av2,a.ak3 ORDER BY a.ak3",

                   //for RVC
                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where (a.ak1,a.av2) = ('c', substr('abc',1,1)) GROUP BY a.av2,a.ak3 ORDER BY a.ak3",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av1 = 'a' and a.av2 = 'b' GROUP BY length(a.av1)+length(a.av2),a.ak3 ORDER BY a.ak3",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 'a' and a.av2 = 'b' GROUP BY length(a.ak1)+length(a.av2),a.ak3 ORDER BY a.ak3",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3, coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av1 = 'a' and a.av2 = substr('abc',2,1) GROUP BY a.ak4,CASE WHEN a.av1 > a.av2 THEN a.av1 ELSE a.av2 END,a.ak3 ORDER BY a.ak4,a.ak3",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 0.0 and a.av2 = (5+3*2) GROUP BY a.ak3,CASE WHEN a.ak1 > a.av2 THEN a.ak1 ELSE a.av2 END,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 0.0 and a.av2 = length(substr('abc',1,1)) GROUP BY a.ak3,CASE WHEN a.ak1 > a.av2 THEN a.ak1 ELSE a.av2 END,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 0.0 and a.av2 = length(substr('abc',1,1)) GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",

                   //for IS NULL
                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 is null and a.av2 = length(substr('abc',1,1)) GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 0.0 and a.av2 is null GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",
             };
              int index = 0;
             for (String query : queries) {
                 QueryPlan plan =  TestUtil.getOptimizeQueryPlan(conn, query);
                 assertTrue((index + 1) + ") " + queries[index], plan.getOrderBy()== OrderBy.FWD_ROW_KEY_ORDER_BY);
                 index++;
             }
         }
         finally {
             if(conn != null) {
                 conn.close();
             }
         }
    }

    @Test
    public void testNotOrderPreservingGroupBy() throws Exception {
        try (Connection conn= DriverManager.getConnection(getUrl())) {

            conn.createStatement().execute("CREATE TABLE test (\n" +
                    "            pk1 INTEGER NOT NULL,\n" +
                    "            pk2 INTEGER NOT NULL,\n" +
                    "            pk3 INTEGER NOT NULL,\n" +
                    "            pk4 INTEGER NOT NULL,\n" +
                    "            v1 INTEGER,\n" +
                    "            CONSTRAINT pk PRIMARY KEY (\n" +
                    "               pk1,\n" +
                    "               pk2,\n" +
                    "               pk3,\n" +
                    "               pk4\n" +
                    "             )\n" +
                    "         )");
            String[] queries = new String[] {
                    "SELECT pk3 FROM test WHERE pk1 = 1 and pk2 = 2 GROUP BY pk4,CASE WHEN pk1 > pk2 THEN coalesce(v1,1) ELSE pk2 END,pk3 ORDER BY pk4,pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 and pk2 = 2 GROUP BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3 ORDER BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 and pk2 = 2 GROUP BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3 ORDER BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3",
                    "SELECT pk3 FROM test GROUP BY pk2,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 GROUP BY pk1,pk2,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 GROUP BY RAND()+pk1,pk2,pk3 ORDER BY pk3",
                    "SELECT pk3 FROM test WHERE pk1 = 1 and pk2 = 2 GROUP BY CASE WHEN pk1 > pk2 THEN pk1 ELSE RAND(1) END,pk3 ORDER BY pk3",
            };
            int index = 0;
            for (String query : queries) {
                QueryPlan plan = getQueryPlan(conn, query);
                assertFalse((index + 1) + ") " + queries[index], plan.getOrderBy().getOrderByExpressions().isEmpty());
                index++;
            }
        }
    }

    @Test
    public void testNotOrderPreservingGroupByForNotPkColumns() throws Exception {
        try (Connection conn= DriverManager.getConnection(getUrl())) {
            conn.createStatement().execute("CREATE TABLE test (\n" +
                    "            pk1 varchar,\n" +
                    "            pk2 varchar,\n" +
                    "            pk3 varchar,\n" +
                    "            pk4 varchar,\n" +
                    "            v1 varchar,\n" +
                    "            v2 varchar,\n" +
                    "            CONSTRAINT pk PRIMARY KEY (\n" +
                    "               pk1,\n" +
                    "               pk2,\n" +
                    "               pk3,\n" +
                    "               pk4\n" +
                    "             )\n" +
                    "         )");
             String[] queries = new String[] {
                     "SELECT pk3 FROM test WHERE (pk1 = 'a' and pk2 = 'b') or v1 ='c' GROUP BY pk4,CASE WHEN pk1 > pk2 THEN coalesce(v1,'1') ELSE pk2 END,pk3 ORDER BY pk4,pk3",
                     "SELECT pk3 FROM test WHERE pk1 = 'a' or pk2 = 'b' GROUP BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3 ORDER BY pk3",
                     "SELECT pk3 FROM test WHERE pk1 = 'a' and (pk2 = 'b' or v1 = 'c') GROUP BY CASE WHEN pk1 > pk2 THEN v1 WHEN pk1 = pk2 THEN pk1 ELSE pk2 END,pk3 ORDER BY pk3",
                     "SELECT v2 FROM test GROUP BY v1,v2 ORDER BY v2",
                     "SELECT pk3 FROM test WHERE v1 = 'a' GROUP BY v1,v2,pk3 ORDER BY pk3",
                     "SELECT length(pk3) FROM test WHERE v1 = 'a' GROUP BY RAND()+length(v1),length(v2),length(pk3) ORDER BY length(v2),length(pk3)",
                     "SELECT length(pk3) FROM test WHERE v1 = 'a' and v2 = 'b' GROUP BY CASE WHEN v1 > v2 THEN length(v1) ELSE RAND(1) END,length(pk3) ORDER BY length(pk3)",
             };
             int index = 0;
            for (String query : queries) {
                QueryPlan plan = getQueryPlan(conn, query);
                assertFalse((index + 1) + ") " + queries[index], plan.getOrderBy().getOrderByExpressions().isEmpty());
                index++;
            }
        }
    }

    @Test
    public void testNotOrderPreservingGroupByForClientAggregatePlan() throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());
            String tableName = "table_test";
            String sql = "create table " + tableName + "( "+
                    " pk1 varchar not null , " +
                    " pk2 varchar not null, " +
                    " pk3 varchar not null," +
                    " v1 varchar, " +
                    " v2 varchar, " +
                    " CONSTRAINT TEST_PK PRIMARY KEY ( "+
                    "pk1,"+
                    "pk2,"+
                    "pk3 ))";
            conn.createStatement().execute(sql);

            String[] queries = new String[] {
                  "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where (a.ak1 = 'a' and a.ak2 = 'b') or a.av1 ='c' GROUP BY a.ak4,CASE WHEN a.ak1 > a.ak2 THEN coalesce(a.av1,'1') ELSE a.ak2 END,a.ak3 ORDER BY a.ak4,a.ak3",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 'a' or a.ak2 = 'b' GROUP BY CASE WHEN a.ak1 > a.ak2 THEN a.av1 WHEN a.ak1 = a.ak2 THEN a.ak1 ELSE a.ak2 END,a.ak3 ORDER BY a.ak3",

                   //for in
                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 in ( 'a','b') GROUP BY CASE WHEN a.ak1 > a.ak2 THEN a.av1 WHEN a.ak1 = a.ak2 THEN a.ak1 ELSE a.ak2 END,a.ak3 ORDER BY a.ak3",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 'a' and (a.ak2 = 'b' or a.av1 = 'c') GROUP BY CASE WHEN a.ak1 > a.ak2 THEN a.av1 WHEN a.ak1 = a.ak2 THEN a.ak1 ELSE a.ak2 END,a.ak3 ORDER BY a.ak3",

                   "select a.av2 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "GROUP BY a.av1,a.av2 ORDER BY a.av2",

                   "select a.ak3 "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av1 = 'a' GROUP BY a.av1,a.av2,a.ak3 ORDER BY a.ak3",

                   "select length(a.ak3) "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av1 = 'a' GROUP BY RAND()+length(a.av1),length(a.av2),length(a.ak3) ORDER BY length(a.av2),length(a.ak3)",

                   "select length(a.ak3) "+
                   "from (select substr(pk1,1,1) ak1,substr(pk2,1,1) ak2,substr(pk3,1,1) ak3,coalesce(pk3,'1') ak4, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.av1 = 'a' and a.av2 = 'b' GROUP BY CASE WHEN a.av1 > a.av2 THEN length(a.av1) ELSE RAND(1) END,length(a.ak3) ORDER BY length(a.ak3)",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 > 0.0 and a.av2 = (5+3*2) GROUP BY a.ak3,CASE WHEN a.ak1 > a.av2 THEN a.ak1 ELSE a.av2 END,a.av1 ORDER BY a.ak3,a.av1",

                   //for CoerceExpression
                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where CAST(a.ak1 AS INTEGER) = 0 and a.av2 = (5+3*2) GROUP BY a.ak3,a.ak1,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 = 0.0 or a.av2 = length(substr('abc',1,1)) GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",

                   //for IS NULL
                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 is not null and a.av2 = length(substr('abc',1,1)) GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 is null or a.av2 = length(substr('abc',1,1)) GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 is null and a.av2 = length(substr('abc',1,1)) and a.ak1 = 0.0 GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",

                   "select a.ak3 "+
                   "from (select rand() ak1,length(pk2) ak2,length(pk3) ak3,length(v1) av1,length(v2) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                   "where a.ak1 is null and a.av2 = length(substr('abc',1,1)) or a.ak1 = 0.0 GROUP BY a.ak3,CASE WHEN coalesce(a.ak1,1) > coalesce(a.av2,2) THEN coalesce(a.ak1,1) ELSE coalesce(a.av2,2) END,a.av1 ORDER BY a.ak3,a.av1",
             };
            int index = 0;
            for (String query : queries) {
                QueryPlan plan = TestUtil.getOptimizeQueryPlan(conn, query);
                assertTrue((index + 1) + ") " + queries[index], plan.getOrderBy().getOrderByExpressions().size() > 0);
                index++;
            }
        }
        finally {
            if(conn != null) {
                conn.close();
            }
        }
    }

    @Test
    public void testOrderByOptimizeForClientAggregatePlanAndDesc() throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());
            String tableName = "test_table";
            String sql = "create table " + tableName + "( "+
                    " pk1 varchar not null, " +
                    " pk2 varchar not null, " +
                    " pk3 varchar not null, " +
                    " v1 varchar, " +
                    " v2 varchar, " +
                    " CONSTRAINT TEST_PK PRIMARY KEY ( "+
                    "pk1 desc,"+
                    "pk2 desc,"+
                    "pk3 desc))";
            conn.createStatement().execute(sql);

            String[] queries = new String[] {
                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3, substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "group by a.ak3,a.av1 order by a.ak3 desc,a.av1",

                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "where a.av1 = 'a' group by a.av1,a.ak3 order by a.ak3 desc",

                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "where a.av1 = 'a' and a.av2= 'b' group by CASE WHEN a.av1 > a.av2 THEN a.av1 ELSE a.av2 END,a.ak3,a.ak2 order by a.ak3 desc,a.ak2 desc"
            };

            int index = 0;
            for (String query : queries) {
                QueryPlan plan =  TestUtil.getOptimizeQueryPlan(conn, query);
                assertTrue((index + 1) + ") " + queries[index], plan.getOrderBy()== OrderBy.FWD_ROW_KEY_ORDER_BY);
                index++;
            }

            queries = new String[] {
                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "group by a.ak3,a.av1 order by a.ak3,a.av1",

                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "where a.av1 = 'a' group by a.av1,a.ak3 order by a.ak3",

                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "where a.av1 = 'a' and a.av2= 'b' group by CASE WHEN a.av1 > a.av2 THEN a.av1 ELSE a.av2 END,a.ak3,a.ak2 order by a.ak3,a.ak2",

                     "select a.ak3 "+
                     "from (select pk1 ak1,pk2 ak2,pk3 ak3,substr(v1,1,1) av1,substr(v2,1,1) av2 from "+tableName+" order by pk2,pk3 limit 10) a "+
                     "where a.av1 = 'a' and a.av2= 'b' group by CASE WHEN a.av1 > a.av2 THEN a.av1 ELSE a.av2 END,a.ak3,a.ak2 order by a.ak3 asc,a.ak2 desc"
            };
            index = 0;
            for (String query : queries) {
                QueryPlan plan = TestUtil.getOptimizeQueryPlan(conn, query);
                assertTrue((index + 1) + ") " + queries[index], plan.getOrderBy().getOrderByExpressions().size() > 0);
                index++;
            }
        }
        finally {
            if(conn != null) {
                conn.close();
            }
        }
    }

    @Test
    public void testGroupByDescColumnBug3451() throws Exception {

        try (Connection conn= DriverManager.getConnection(getUrl())) {

            conn.createStatement().execute("CREATE TABLE IF NOT EXISTS GROUPBYTEST (\n" +
                    "            ORGANIZATION_ID CHAR(15) NOT NULL,\n" +
                    "            CONTAINER_ID CHAR(15) NOT NULL,\n" +
                    "            ENTITY_ID CHAR(15) NOT NULL,\n" +
                    "            SCORE DOUBLE,\n" +
                    "            CONSTRAINT TEST_PK PRIMARY KEY (\n" +
                    "               ORGANIZATION_ID,\n" +
                    "               CONTAINER_ID,\n" +
                    "               ENTITY_ID\n" +
                    "             )\n" +
                    "         )");
            conn.createStatement().execute("CREATE INDEX SCORE_IDX ON GROUPBYTEST (ORGANIZATION_ID,CONTAINER_ID, SCORE DESC, ENTITY_ID DESC)");
            QueryPlan plan = getQueryPlan(conn, "SELECT DISTINCT entity_id, score\n" +
                    "    FROM GROUPBYTEST\n" +
                    "    WHERE organization_id = 'org2'\n" +
                    "    AND container_id IN ( 'container1','container2','container3' )\n" +
                    "    ORDER BY score DESC\n" +
                    "    LIMIT 2");
            assertFalse(plan.getOrderBy().getOrderByExpressions().isEmpty());
            plan = getQueryPlan(conn, "SELECT DISTINCT entity_id, score\n" +
                    "    FROM GROUPBYTEST\n" +
                    "    WHERE entity_id = 'entity1'\n" +
                    "    AND container_id IN ( 'container1','container2','container3' )\n" +
                    "    ORDER BY score DESC\n" +
                    "    LIMIT 2");
            assertTrue(plan.getOrderBy().getOrderByExpressions().isEmpty());
        }
    }

    @Test
    public void testGroupByDescColumnBug3452() throws Exception {

       Connection conn=null;
        try {
            conn= DriverManager.getConnection(getUrl());

            String sql="CREATE TABLE GROUPBYDESC3452 ( "+
                "ORGANIZATION_ID VARCHAR,"+
                "CONTAINER_ID VARCHAR,"+
                "ENTITY_ID VARCHAR NOT NULL,"+
                "CONSTRAINT TEST_PK PRIMARY KEY ( "+
                "ORGANIZATION_ID DESC,"+
                "CONTAINER_ID DESC,"+
                "ENTITY_ID"+
                "))";
            conn.createStatement().execute(sql);

            //-----ORGANIZATION_ID

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID ASC NULLS FIRST";
            QueryPlan queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy()== OrderBy.REV_ROW_KEY_ORDER_BY);

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy()== OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            //----CONTAINER_ID

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            //-----ORGANIZATION_ID ASC  CONTAINER_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID NULLS FIRST,CONTAINER_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID NULLS FIRST,CONTAINER_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID NULLS LAST,CONTAINER_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID NULLS LAST,CONTAINER_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == OrderBy.REV_ROW_KEY_ORDER_BY);

            //-----ORGANIZATION_ID ASC  CONTAINER_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID ASC NULLS FIRST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID ASC NULLS FIRST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID ASC NULLS LAST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID ASC NULLS LAST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            //-----ORGANIZATION_ID DESC  CONTAINER_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID NULLS LAST"));

            //-----ORGANIZATION_ID DESC  CONTAINER_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            //-----CONTAINER_ID ASC  ORGANIZATION_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID NULLS FIRST,ORGANIZATION_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID NULLS FIRST,ORGANIZATION_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID NULLS LAST,ORGANIZATION_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID NULLS LAST,ORGANIZATION_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            //-----CONTAINER_ID ASC  ORGANIZATION_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID ASC NULLS FIRST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID ASC NULLS FIRST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID ASC NULLS LAST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID ASC NULLS LAST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            //-----CONTAINER_ID DESC  ORGANIZATION_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            //-----CONTAINER_ID DESC  ORGANIZATION_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID,CONTAINER_ID order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM GROUPBYDESC3452 group by ORGANIZATION_ID, CONTAINER_ID order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testOrderByDescWithNullsLastBug3469() throws Exception {
        Connection conn=null;
        try {
            conn= DriverManager.getConnection(getUrl());

            String sql="CREATE TABLE DESCNULLSLAST3469 ( "+
                "ORGANIZATION_ID VARCHAR,"+
                "CONTAINER_ID VARCHAR,"+
                "ENTITY_ID VARCHAR NOT NULL,"+
                "CONSTRAINT TEST_PK PRIMARY KEY ( "+
                "ORGANIZATION_ID DESC,"+
                "CONTAINER_ID DESC,"+
                "ENTITY_ID"+
                "))";
            conn.createStatement().execute(sql);

            //-----ORGANIZATION_ID

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID ASC NULLS FIRST";
            QueryPlan queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy()== OrderBy.REV_ROW_KEY_ORDER_BY);

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy()== OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            //----CONTAINER_ID

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==1);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            //-----ORGANIZATION_ID ASC  CONTAINER_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID NULLS FIRST,CONTAINER_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID NULLS FIRST,CONTAINER_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID NULLS LAST,CONTAINER_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID NULLS LAST,CONTAINER_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy() == OrderBy.REV_ROW_KEY_ORDER_BY);

            //-----ORGANIZATION_ID ASC  CONTAINER_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID ASC NULLS FIRST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID ASC NULLS FIRST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID ASC NULLS LAST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID ASC NULLS LAST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            //-----ORGANIZATION_ID DESC  CONTAINER_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID NULLS LAST"));

            //-----ORGANIZATION_ID DESC  CONTAINER_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS FIRST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by ORGANIZATION_ID DESC NULLS LAST,CONTAINER_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("CONTAINER_ID DESC NULLS LAST"));

            //-----CONTAINER_ID ASC  ORGANIZATION_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID NULLS FIRST,ORGANIZATION_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID NULLS FIRST,ORGANIZATION_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID NULLS LAST,ORGANIZATION_ID NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID NULLS LAST,ORGANIZATION_ID NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            //-----CONTAINER_ID ASC  ORGANIZATION_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID ASC NULLS FIRST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID ASC NULLS FIRST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID ASC NULLS LAST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID ASC NULLS LAST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            //-----CONTAINER_ID DESC  ORGANIZATION_ID ASC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID ASC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID ASC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID NULLS LAST"));

            //-----CONTAINER_ID DESC  ORGANIZATION_ID DESC

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS FIRST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID DESC NULLS FIRST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC"));

            sql="SELECT CONTAINER_ID,ORGANIZATION_ID FROM DESCNULLSLAST3469 order by CONTAINER_ID DESC NULLS LAST,ORGANIZATION_ID DESC NULLS LAST";
            queryPlan =getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size()==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("CONTAINER_ID DESC NULLS LAST"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("ORGANIZATION_ID DESC NULLS LAST"));
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testOrderByReverseOptimizationBug3491() throws Exception {
        for(boolean salted: new boolean[]{true,false}) {
            boolean[] groupBys=new boolean[]{true,true,true,true,false,false,false,false};
            doTestOrderByReverseOptimizationBug3491(salted,true,true,true,
                    groupBys,
                    new OrderBy[]{
                    OrderBy.REV_ROW_KEY_ORDER_BY,null,null,OrderBy.FWD_ROW_KEY_ORDER_BY,
                    OrderBy.REV_ROW_KEY_ORDER_BY,null,null,OrderBy.FWD_ROW_KEY_ORDER_BY});

            doTestOrderByReverseOptimizationBug3491(salted,true,true,false,
                    groupBys,
                    new OrderBy[]{
                    OrderBy.REV_ROW_KEY_ORDER_BY,null,null,OrderBy.FWD_ROW_KEY_ORDER_BY,
                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationBug3491(salted,true,false,true,
                    groupBys,
                    new OrderBy[]{
                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null,
                    OrderBy.REV_ROW_KEY_ORDER_BY,null,null,OrderBy.FWD_ROW_KEY_ORDER_BY});

            doTestOrderByReverseOptimizationBug3491(salted,true,false,false,
                    groupBys,
                    new OrderBy[]{
                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null,
                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationBug3491(salted,false,true,true,
                    groupBys,
                    new OrderBy[]{
                    null,OrderBy.FWD_ROW_KEY_ORDER_BY,OrderBy.REV_ROW_KEY_ORDER_BY,null,
                    null,OrderBy.FWD_ROW_KEY_ORDER_BY,OrderBy.REV_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationBug3491(salted,false,true,false,
                    groupBys,
                    new OrderBy[]{
                    null,OrderBy.FWD_ROW_KEY_ORDER_BY,OrderBy.REV_ROW_KEY_ORDER_BY,null,
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY});

            doTestOrderByReverseOptimizationBug3491(salted,false,false,true,
                    groupBys,
                    new OrderBy[]{
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    null,OrderBy.FWD_ROW_KEY_ORDER_BY,OrderBy.REV_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationBug3491(salted,false,false,false,
                    groupBys,
                    new OrderBy[]{
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY});
        }
    }

    private void doTestOrderByReverseOptimizationBug3491(boolean salted,boolean desc1,boolean desc2,boolean desc3,boolean[] groupBys,OrderBy[] orderBys) throws Exception {
        Connection conn = null;
        try {
            conn= DriverManager.getConnection(getUrl());
            String tableName="ORDERBY3491_TEST";
            conn.createStatement().execute("DROP TABLE if exists "+tableName);
            String sql="CREATE TABLE "+tableName+" ( "+
                    "ORGANIZATION_ID INTEGER NOT NULL,"+
                    "CONTAINER_ID INTEGER NOT NULL,"+
                    "SCORE INTEGER NOT NULL,"+
                    "ENTITY_ID INTEGER NOT NULL,"+
                    "CONSTRAINT TEST_PK PRIMARY KEY ( "+
                    "ORGANIZATION_ID" +(desc1 ? " DESC" : "" )+","+
                    "CONTAINER_ID"+(desc2 ? " DESC" : "" )+","+
                    "SCORE"+(desc3 ? " DESC" : "" )+","+
                    "ENTITY_ID"+
                    ")) "+(salted ? "SALT_BUCKETS =4" : "");
            conn.createStatement().execute(sql);


            String[] sqls={
                    //groupBy orderPreserving orderBy asc asc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC, CONTAINER_ID ASC",
                    //groupBy orderPreserving orderBy asc desc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC, CONTAINER_ID DESC",
                    //groupBy orderPreserving orderBy desc asc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC, CONTAINER_ID ASC",
                    //groupBy orderPreserving orderBy desc desc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC, CONTAINER_ID DESC",

                    //groupBy not orderPreserving orderBy asc asc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC, SCORE ASC",
                    //groupBy not orderPreserving orderBy asc desc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC, SCORE DESC",
                    //groupBy not orderPreserving orderBy desc asc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC, SCORE ASC",
                    //groupBy not orderPreserving orderBy desc desc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC, SCORE DESC"
            };

            for(int i=0;i< sqls.length;i++) {
                sql=sqls[i];
                QueryPlan queryPlan=getQueryPlan(conn, sql);
                assertTrue((i+1) + ") " + sql,queryPlan.getGroupBy().isOrderPreserving()== groupBys[i]);
                OrderBy orderBy=queryPlan.getOrderBy();
                if(orderBys[i]!=null) {
                    assertTrue((i+1) + ") " + sql,orderBy == orderBys[i]);
                }
                else {
                    assertTrue((i+1) + ") " + sql,orderBy.getOrderByExpressions().size() > 0);
                }
            }
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testOrderByReverseOptimizationWithNUllsLastBug3491() throws Exception {
        for(boolean salted: new boolean[]{true,false}) {
            boolean[] groupBys=new boolean[]{
                    //groupBy orderPreserving orderBy asc asc
                    true,true,true,true,
                    //groupBy orderPreserving orderBy asc desc
                    true,true,true,true,
                    //groupBy orderPreserving orderBy desc asc
                    true,true,true,true,
                    //groupBy orderPreserving orderBy desc desc
                    true,true,true,true,

                    //groupBy not orderPreserving orderBy asc asc
                    false,false,false,false,
                    //groupBy not orderPreserving orderBy asc desc
                    false,false,false,false,
                    //groupBy not orderPreserving orderBy desc asc
                    false,false,false,false,
                    //groupBy not orderPreserving orderBy desc desc
                    false,false,false,false,

                    false,false,false,false};
            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,true,true,true,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,

                    //groupBy not orderPreserving orderBy asc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy not orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,

                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,true,true,false,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,

                    //groupBy not orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy asc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy not orderPreserving orderBy desc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy not orderPreserving orderBy desc desc
                    null,null,null,null,

                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY});

            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,true,false,true,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy asc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy orderPreserving orderBy desc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy orderPreserving orderBy desc desc
                    null,null,null,null,

                    //groupBy not orderPreserving orderBy asc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy not orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,true,false,false,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy asc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy orderPreserving orderBy desc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy orderPreserving orderBy desc desc
                    null,null,null,null,

                    //groupBy not orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy asc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy not orderPreserving orderBy desc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy not orderPreserving orderBy desc desc
                    null,null,null,null,

                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY});

            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,false,true,true,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy asc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy orderPreserving orderBy desc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy orderPreserving orderBy desc desc
                    null,null,null,null,

                    //groupBy not orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy asc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy not orderPreserving orderBy desc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy not orderPreserving orderBy desc desc
                    null,null,null,null,

                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null});


            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,false,true,false,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy asc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy orderPreserving orderBy desc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy orderPreserving orderBy desc desc
                    null,null,null,null,

                    //groupBy not orderPreserving orderBy asc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy not orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,

                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY});

            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,false,false,true,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,

                    //groupBy not orderPreserving orderBy asc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy asc desc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy not orderPreserving orderBy desc asc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,
                    //groupBy not orderPreserving orderBy desc desc
                    null,null,null,null,

                    null,OrderBy.REV_ROW_KEY_ORDER_BY,OrderBy.FWD_ROW_KEY_ORDER_BY,null});

            doTestOrderByReverseOptimizationWithNUllsLastBug3491(salted,false,false,false,
                    groupBys,
                    new OrderBy[]{
                    //groupBy orderPreserving orderBy asc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy orderPreserving orderBy desc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,

                    //groupBy not orderPreserving orderBy asc asc
                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,null,
                    //groupBy not orderPreserving orderBy asc desc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc asc
                    null,null,null,null,
                    //groupBy not orderPreserving orderBy desc desc
                    null,null,null,OrderBy.REV_ROW_KEY_ORDER_BY,

                    OrderBy.FWD_ROW_KEY_ORDER_BY,null,null,OrderBy.REV_ROW_KEY_ORDER_BY});
        }
    }

    private void doTestOrderByReverseOptimizationWithNUllsLastBug3491(boolean salted,boolean desc1,boolean desc2,boolean desc3,boolean[] groupBys,OrderBy[] orderBys) throws Exception {
        Connection conn = null;
        try {
            conn= DriverManager.getConnection(getUrl());
            String tableName="ORDERBY3491_TEST";
            conn.createStatement().execute("DROP TABLE if exists "+tableName);
            String sql="CREATE TABLE "+tableName+" ( "+
                    "ORGANIZATION_ID VARCHAR,"+
                    "CONTAINER_ID VARCHAR,"+
                    "SCORE VARCHAR,"+
                    "ENTITY_ID VARCHAR NOT NULL,"+
                    "CONSTRAINT TEST_PK PRIMARY KEY ( "+
                    "ORGANIZATION_ID" +(desc1 ? " DESC" : "" )+","+
                    "CONTAINER_ID"+(desc2 ? " DESC" : "" )+","+
                    "SCORE"+(desc3 ? " DESC" : "" )+","+
                    "ENTITY_ID"+
                    ")) "+(salted ? "SALT_BUCKETS =4" : "");
            conn.createStatement().execute(sql);

            String[] sqls={
                    //groupBy orderPreserving orderBy asc asc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS FIRST, CONTAINER_ID ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS FIRST, CONTAINER_ID ASC NULLS LAST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS LAST, CONTAINER_ID ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS LAST, CONTAINER_ID ASC NULLS LAST",

                    //groupBy orderPreserving orderBy asc desc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS FIRST, CONTAINER_ID DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS FIRST, CONTAINER_ID DESC NULLS LAST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS LAST, CONTAINER_ID DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID ASC NULLS LAST, CONTAINER_ID DESC NULLS LAST",

                    //groupBy orderPreserving orderBy desc asc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS FIRST, CONTAINER_ID ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS FIRST, CONTAINER_ID ASC NULLS LAST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS LAST, CONTAINER_ID ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS LAST, CONTAINER_ID ASC NULLS LAST",

                    //groupBy orderPreserving orderBy desc desc
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS FIRST, CONTAINER_ID DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS FIRST, CONTAINER_ID DESC NULLS LAST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS LAST, CONTAINER_ID DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,CONTAINER_ID FROM "+tableName+" group by ORGANIZATION_ID, CONTAINER_ID ORDER BY ORGANIZATION_ID DESC NULLS LAST, CONTAINER_ID DESC NULLS LAST",

                    //-----groupBy not orderPreserving

                    //groupBy not orderPreserving orderBy asc asc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS FIRST, SCORE ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS FIRST, SCORE ASC NULLS LAST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS LAST, SCORE ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS LAST, SCORE ASC NULLS LAST",

                    //groupBy not orderPreserving orderBy asc desc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS FIRST, SCORE DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS FIRST, SCORE DESC NULLS LAST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS LAST, SCORE DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID ASC NULLS LAST, SCORE DESC NULLS LAST",

                    //groupBy not orderPreserving orderBy desc asc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS FIRST, SCORE ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS FIRST, SCORE ASC NULLS LAST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS LAST, SCORE ASC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS LAST, SCORE ASC NULLS LAST",

                    //groupBy not orderPreserving orderBy desc desc
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS FIRST, SCORE DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS FIRST, SCORE DESC NULLS LAST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS LAST, SCORE DESC NULLS FIRST",
                    "SELECT ORGANIZATION_ID,SCORE FROM "+tableName+" group by ORGANIZATION_ID, SCORE ORDER BY ORGANIZATION_ID DESC NULLS LAST, SCORE DESC NULLS LAST",

                    //-------only one return column----------------------------------
                    "SELECT SCORE FROM "+tableName+" group by SCORE ORDER BY SCORE ASC NULLS FIRST",
                    "SELECT SCORE FROM "+tableName+" group by SCORE ORDER BY SCORE ASC NULLS LAST",
                    "SELECT SCORE FROM "+tableName+" group by SCORE ORDER BY SCORE DESC NULLS FIRST",
                    "SELECT SCORE FROM "+tableName+" group by SCORE ORDER BY SCORE DESC NULLS LAST"
            };

            for(int i=0;i< sqls.length;i++) {
                sql=sqls[i];
                QueryPlan queryPlan=getQueryPlan(conn, sql);
                assertTrue((i+1) + ") " + sql,queryPlan.getGroupBy().isOrderPreserving()== groupBys[i]);
                OrderBy orderBy=queryPlan.getOrderBy();
                if(orderBys[i]!=null) {
                    assertTrue((i+1) + ") " + sql,orderBy == orderBys[i]);
                }
                else {
                    assertTrue((i+1) + ") " + sql,orderBy.getOrderByExpressions().size() > 0);
                }
            }
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testGroupByCoerceExpressionBug3453() throws Exception {
        Connection conn = null;
        try {
            conn= DriverManager.getConnection(getUrl());
            String tableName="GROUPBY3453_INT";
            String sql="CREATE TABLE "+ tableName +"("+
                    "ENTITY_ID INTEGER NOT NULL,"+
                    "CONTAINER_ID INTEGER NOT NULL,"+
                    "SCORE INTEGER NOT NULL,"+
                    "CONSTRAINT TEST_PK PRIMARY KEY (ENTITY_ID DESC,CONTAINER_ID DESC,SCORE DESC))";
            conn.createStatement().execute(sql);
            sql="select DISTINCT entity_id, score from ( select entity_id, score from "+tableName+" limit 1)";
            QueryPlan queryPlan=getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().getExpressions().get(0).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getExpressions().get(1).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getKeyExpressions().get(0).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getKeyExpressions().get(1).getSortOrder()==SortOrder.DESC);

            sql="select DISTINCT entity_id, score from ( select entity_id, score from "+tableName+" limit 3) order by entity_id";
            queryPlan=getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().getExpressions().get(0).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getExpressions().get(1).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getKeyExpressions().get(0).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getKeyExpressions().get(1).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).getExpression().getSortOrder()==SortOrder.DESC);

            sql="select DISTINCT entity_id, score from ( select entity_id, score from "+tableName+" limit 3) order by entity_id desc";
            queryPlan=getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().getExpressions().get(0).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getExpressions().get(1).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getKeyExpressions().get(0).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getGroupBy().getKeyExpressions().get(1).getSortOrder()==SortOrder.DESC);
            assertTrue(queryPlan.getOrderBy()==OrderBy.FWD_ROW_KEY_ORDER_BY);
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    private static QueryPlan getQueryPlan(Connection conn,String sql) throws SQLException {
        PhoenixPreparedStatement statement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
        QueryPlan queryPlan = statement.optimizeQuery(sql);
        queryPlan.iterator();
        return queryPlan;
    }

    @Test
    public void testSortMergeJoinSubQueryOrderByOverrideBug3745() throws Exception {
        Connection conn = null;
        try {
            conn= DriverManager.getConnection(getUrl());

            String tableName1="MERGE1";
            String tableName2="MERGE2";

            conn.createStatement().execute("DROP TABLE if exists "+tableName1);

            String sql="CREATE TABLE IF NOT EXISTS "+tableName1+" ( "+
                    "AID INTEGER PRIMARY KEY,"+
                    "AGE INTEGER"+
                    ")";
            conn.createStatement().execute(sql);

            conn.createStatement().execute("DROP TABLE if exists "+tableName2);
            sql="CREATE TABLE IF NOT EXISTS "+tableName2+" ( "+
                    "BID INTEGER PRIMARY KEY,"+
                    "CODE INTEGER"+
                    ")";
            conn.createStatement().execute(sql);

            //test for simple scan
            sql="select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid ";

            QueryPlan queryPlan=getQueryPlan(conn, sql);
            SortMergeJoinPlan sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            ClientScanPlan lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            OrderBy orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            ScanPlan innerScanPlan=(ScanPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AGE"));
            assertTrue(innerScanPlan.getLimit().intValue() == 3);

            ClientScanPlan rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("BID"));
            innerScanPlan=(ScanPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("CODE"));
            assertTrue(innerScanPlan.getLimit().intValue() == 1);

            //test for aggregate
            sql="select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.codesum from (select aid,sum(age) agesum from "+tableName1+" where age >=11 and age<=33 group by aid order by agesum limit 3) a inner join "+
                    "(select bid,sum(code) codesum from "+tableName2+" group by bid order by codesum limit 1) b on a.aid=b.bid ";


            queryPlan=getQueryPlan(conn, sql);
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            AggregatePlan innerAggregatePlan=(AggregatePlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(AGE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("BID"));
            innerAggregatePlan=(AggregatePlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(CODE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 1);

            String tableName3="merge3";
            conn.createStatement().execute("DROP TABLE if exists "+tableName3);
            sql="CREATE TABLE IF NOT EXISTS "+tableName3+" ( "+
                    "CID INTEGER PRIMARY KEY,"+
                    "REGION INTEGER"+
                    ")";
            conn.createStatement().execute(sql);

            //test for join
            sql="select t1.aid,t1.code,t2.region from "+
                "(select a.aid,b.code from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid where b.code >=44 and b.code<=66 order by b.code limit 3) t1 inner join "+
                "(select a.aid,c.region from "+tableName1+" a inner join "+tableName3+" c on a.aid=c.cid where c.region>=77 and c.region<=99 order by c.region desc limit 1) t2 on t1.aid=t2.aid";

            PhoenixPreparedStatement phoenixPreparedStatement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
            queryPlan = phoenixPreparedStatement.optimizeQuery(sql);
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerScanPlan=(ScanPlan)((HashJoinPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("B.CODE"));
            assertTrue(innerScanPlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerScanPlan=(ScanPlan)((HashJoinPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("C.REGION DESC"));
            assertTrue(innerScanPlan.getLimit().intValue() == 1);

            //test for join and aggregate
            sql="select t1.aid,t1.codesum,t2.regionsum from "+
                "(select a.aid,sum(b.code) codesum from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid where b.code >=44 and b.code<=66 group by a.aid order by codesum limit 3) t1 inner join "+
                "(select a.aid,sum(c.region) regionsum from "+tableName1+" a inner join "+tableName3+" c on a.aid=c.cid where c.region>=77 and c.region<=99 group by a.aid order by regionsum desc limit 2) t2 on t1.aid=t2.aid";

            phoenixPreparedStatement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
            queryPlan = phoenixPreparedStatement.optimizeQuery(sql);
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(B.CODE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(C.REGION) DESC"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 2);

            //test for if SubselectRewriter.isOrderByPrefix had take effect
            sql="select t1.aid,t1.codesum,t2.regionsum from "+
                "(select a.aid,sum(b.code) codesum from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid where b.code >=44 and b.code<=66 group by a.aid order by a.aid,codesum limit 3) t1 inner join "+
                "(select a.aid,sum(c.region) regionsum from "+tableName1+" a inner join "+tableName3+" c on a.aid=c.cid where c.region>=77 and c.region<=99 group by a.aid order by a.aid desc,regionsum desc limit 2) t2 on t1.aid=t2.aid "+
                 "order by t1.aid desc";

            phoenixPreparedStatement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
            queryPlan = phoenixPreparedStatement.optimizeQuery(sql);
            orderBy=queryPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("T1.AID DESC"));
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)(((TupleProjectionPlan)sortMergeJoinPlan.getLhsPlan()).getDelegate())).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 2);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("A.AID"));
            assertTrue(orderBy.getOrderByExpressions().get(1).toString().equals("SUM(B.CODE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 2);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("A.AID DESC"));
            assertTrue(orderBy.getOrderByExpressions().get(1).toString().equals("SUM(C.REGION) DESC"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 2);
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testUnionDifferentColumnNumber() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        Statement statement = conn.createStatement();
        try {
            String create = "CREATE TABLE s.t1 (k integer not null primary key, f1.v1 varchar, f1.v2 varchar, " +
                    "f2.v3 varchar, v4 varchar)";
            statement.execute(create);
            create = "CREATE TABLE s.t2 (k integer not null primary key, f1.v1 varchar, f1.v2 varchar, f2.v3 varchar)";
            statement.execute(create);
            String query = "SELECT *  FROM s.t1 UNION ALL select * FROM s.t2";
            statement.executeQuery(query);
            fail("Should fail with different column numbers ");
        } catch (SQLException e) {
            assertEquals(e.getMessage(), "ERROR 525 (42902): SELECT column number differs in a Union All query " +
                    "is not allowed. 1st query has 5 columns whereas 2nd query has 4");
        } finally {
            statement.execute("DROP TABLE IF EXISTS s.t1");
            statement.execute("DROP TABLE IF EXISTS s.t2");
            conn.close();
        }
    }

    @Test
    public void testUnionDifferentColumnType() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        Statement statement = conn.createStatement();
        try {
            String create = "CREATE TABLE s.t1 (k integer not null primary key, f1.v1 varchar, f1.v2 varchar, " +
                    "f2.v3 varchar, v4 varchar)";
            statement.execute(create);
            create = "CREATE TABLE s.t2 (k integer not null primary key, f1.v1 varchar, f1.v2 integer, " +
                    "f2.v3 varchar, f2.v4 varchar)";
            statement.execute(create);
            String query = "SELECT *  FROM s.t1 UNION ALL select * FROM s.t2";
            statement.executeQuery(query);
            fail("Should fail with different column types ");
        } catch (SQLException e) {
            assertEquals(e.getMessage(), "ERROR 526 (42903): SELECT column types differ in a Union All query " +
                    "is not allowed. Column # 2 is VARCHAR in 1st query where as it is INTEGER in 2nd query");
        } finally {
            statement.execute("DROP TABLE IF EXISTS s.t1");
            statement.execute("DROP TABLE IF EXISTS s.t2");
            conn.close();
        }
    }

    @Test
    public void testCannotCreateStatementOnClosedConnection() throws Exception {
        Connection conn = DriverManager.getConnection(getUrl());
        conn.close();
        try {
            conn.createStatement();
            fail();
        } catch (SQLException e) {
            assertEquals(e.getErrorCode(), SQLExceptionCode.CONNECTION_CLOSED.getErrorCode());
        }
        try {
            conn.prepareStatement("SELECT * FROM SYSTEM.CATALOG");
            fail();
        } catch (SQLException e) {
            assertEquals(e.getErrorCode(), SQLExceptionCode.CONNECTION_CLOSED.getErrorCode());
        }
    }

    @Test
    public void testSingleColLocalIndexPruning() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(A,C)");
            String query = "SELECT * FROM T WHERE A = 'B' and C='C'";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(1, outerScans.size());
            List<Scan> innerScans = outerScans.get(0);
            assertEquals(1, innerScans.size());
            Scan scan = innerScans.get(0);
            assertEquals("A", Bytes.toString(scan.getStartRow()).trim());
            assertEquals("C", Bytes.toString(scan.getStopRow()).trim());
        }
    }

    @Test
    public void testMultiColLocalIndexPruning() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    D CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C,\n" +
                    "        D\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(A,B,D)");
            String query = "SELECT * FROM T WHERE A = 'C' and B = 'X' and D='C'";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(1, outerScans.size());
            List<Scan> innerScans = outerScans.get(0);
            assertEquals(1, innerScans.size());
            Scan scan = innerScans.get(0);
            assertEquals("C", Bytes.toString(scan.getStartRow()).trim());
            assertEquals("E", Bytes.toString(scan.getStopRow()).trim());
        }
    }

    @Test
    public void testSkipScanLocalIndexPruning() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    D CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C,\n" +
                    "        D\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(A,B,D)");
            String query = "SELECT * FROM T WHERE A IN ('A','G') and B = 'A' and D = 'D'";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(2, outerScans.size());
            List<Scan> innerScans1 = outerScans.get(0);
            assertEquals(1, innerScans1.size());
            Scan scan1 = innerScans1.get(0);
            assertEquals("A", Bytes.toString(scan1.getStartRow()).trim());
            assertEquals("C", Bytes.toString(scan1.getStopRow()).trim());
            List<Scan> innerScans2 = outerScans.get(1);
            assertEquals(1, innerScans2.size());
            Scan scan2 = innerScans2.get(0);
            assertEquals("G", Bytes.toString(scan2.getStartRow()).trim());
            assertEquals("I", Bytes.toString(scan2.getStopRow()).trim());
        }
    }

    @Test
    public void testRVCLocalIndexPruning() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    D CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C,\n" +
                    "        D\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(A,B,D)");
            String query = "SELECT * FROM T WHERE A='I' and (B,D) IN (('A','D'),('B','I'))";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(1, outerScans.size());
            List<Scan> innerScans = outerScans.get(0);
            assertEquals(1, innerScans.size());
            Scan scan = innerScans.get(0);
            assertEquals("I", Bytes.toString(scan.getStartRow()).trim());
            assertEquals(0, scan.getStopRow().length);
        }
    }

    @Test
    public void testRVCLocalIndexPruning2() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B VARCHAR,\n" +
                    "    C VARCHAR,\n" +
                    "    D VARCHAR,\n" +
                    "    E VARCHAR,\n" +
                    "    F VARCHAR,\n" +
                    "    G VARCHAR,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C,\n" +
                    "        D,\n" +
                    "        E,\n" +
                    "        F,\n" +
                    "        G\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(A,B,C,F,G)");
            String query = "SELECT * FROM T WHERE (A,B,C,D) IN (('I','D','F','X'),('I','I','G','Y')) and F='X' and G='Y'";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(1, outerScans.size());
            List<Scan> innerScans = outerScans.get(0);
            assertEquals(1, innerScans.size());
            Scan scan = innerScans.get(0);
            assertEquals("I", Bytes.toString(scan.getStartRow()).trim());
            assertEquals(0, scan.getStopRow().length);
        }
    }

    @Test
    public void testMinMaxRangeLocalIndexPruning() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    D CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C,\n" +
                    "        D\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(A,B,D)");
            String query = "SELECT * FROM T WHERE A = 'C' and (A,B,D) > ('C','B','X') and B < 'Z' and D='C'";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(1, outerScans.size());
            List<Scan> innerScans = outerScans.get(0);
            assertEquals(1, innerScans.size());
            Scan scan = innerScans.get(0);
            assertEquals("C", Bytes.toString(scan.getStartRow()).trim());
            assertEquals("E", Bytes.toString(scan.getStopRow()).trim());
        }
    }

    @Test
    public void testNoLocalIndexPruning() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX ON T(C)");
            String query = "SELECT * FROM T WHERE C='C'";
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            assertEquals("IDX", plan.getContext().getCurrentTable().getTable().getName().getString());
            plan.iterator();
            List<List<Scan>> outerScans = plan.getScans();
            assertEquals(6, outerScans.size());
        }
    }

    @Test
    public void testSmallScanForPointLookups() throws SQLException {
        Properties props = PropertiesUtil.deepCopy(new Properties());
        createTestTable(getUrl(), "CREATE TABLE FOO(\n" +
                      "                a VARCHAR NOT NULL,\n" +
                      "                b VARCHAR NOT NULL,\n" +
                      "                c VARCHAR,\n" +
                      "                CONSTRAINT pk PRIMARY KEY (a, b DESC, c)\n" +
                      "              )");

        props.put(QueryServices.SMALL_SCAN_THRESHOLD_ATTRIB, "2");
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            String query = "select * from foo where a = 'a' and b = 'b' and c in ('x','y','z')";
            PhoenixStatement stmt = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = stmt.optimizeQuery(query);
            plan.iterator();
            //Fail since we have 3 rows in pointLookup
            assertFalse(plan.getContext().getScan().isSmall());
            query = "select * from foo where a = 'a' and b = 'b' and c = 'c'";
            plan = stmt.compileQuery(query);
            plan.iterator();
            //Should be small scan, query is for single row pointLookup
            assertTrue(plan.getContext().getScan().isSmall());
        }
    }

    @Test
    public void testLocalIndexPruningInSortMergeJoin() throws SQLException {
        verifyLocalIndexPruningWithMultipleTables("SELECT /*+ USE_SORT_MERGE_JOIN*/ *\n" +
                "FROM T1 JOIN T2 ON T1.A = T2.A\n" +
                "WHERE T1.A = 'B' and T1.C='C' and T2.A IN ('A','G') and T2.B = 'A' and T2.D = 'D'");
    }

    @Ignore("Blocked by PHOENIX-4614")
    @Test
    public void testLocalIndexPruningInLeftOrInnerHashJoin() throws SQLException {
        verifyLocalIndexPruningWithMultipleTables("SELECT *\n" +
                "FROM T1 JOIN T2 ON T1.A = T2.A\n" +
                "WHERE T1.A = 'B' and T1.C='C' and T2.A IN ('A','G') and T2.B = 'A' and T2.D = 'D'");
    }

    @Ignore("Blocked by PHOENIX-4614")
    @Test
    public void testLocalIndexPruningInRightHashJoin() throws SQLException {
        verifyLocalIndexPruningWithMultipleTables("SELECT *\n" +
                "FROM (\n" +
                "    SELECT A, B, C, D FROM T2 WHERE T2.A IN ('A','G') and T2.B = 'A' and T2.D = 'D'\n" +
                ") T2\n" +
                "RIGHT JOIN T1 ON T2.A = T1.A\n" +
                "WHERE T1.A = 'B' and T1.C='C'");
    }

    @Test
    public void testLocalIndexPruningInUinon() throws SQLException {
        verifyLocalIndexPruningWithMultipleTables("SELECT A, B, C FROM T1\n" +
                "WHERE A = 'B' and C='C'\n" +
                "UNION ALL\n" +
                "SELECT A, B, C FROM T2\n" +
                "WHERE A IN ('A','G') and B = 'A' and D = 'D'");
    }

    private void verifyLocalIndexPruningWithMultipleTables(String query) throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE T1 (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX1 ON T1(A,C)");
            conn.createStatement().execute("CREATE TABLE T2 (\n" +
                    "    A CHAR(1) NOT NULL,\n" +
                    "    B CHAR(1) NOT NULL,\n" +
                    "    C CHAR(1) NOT NULL,\n" +
                    "    D CHAR(1) NOT NULL,\n" +
                    "    CONSTRAINT PK PRIMARY KEY (\n" +
                    "        A,\n" +
                    "        B,\n" +
                    "        C,\n" +
                    "        D\n" +
                    "    )\n" +
                    ") SPLIT ON ('A','C','E','G','I')");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX2 ON T2(A,B,D)");
            PhoenixStatement statement = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = statement.optimizeQuery(query);
            List<QueryPlan> childPlans = plan.accept(new MultipleChildrenExtractor());
            assertEquals(2, childPlans.size());
            // Check left child
            assertEquals("IDX1", childPlans.get(0).getContext().getCurrentTable().getTable().getName().getString());
            childPlans.get(0).iterator();
            List<List<Scan>> outerScansL = childPlans.get(0).getScans();
            assertEquals(1, outerScansL.size());
            List<Scan> innerScansL = outerScansL.get(0);
            assertEquals(1, innerScansL.size());
            Scan scanL = innerScansL.get(0);
            assertEquals("A", Bytes.toString(scanL.getStartRow()).trim());
            assertEquals("C", Bytes.toString(scanL.getStopRow()).trim());
            // Check right child
            assertEquals("IDX2", childPlans.get(1).getContext().getCurrentTable().getTable().getName().getString());
            childPlans.get(1).iterator();
            List<List<Scan>> outerScansR = childPlans.get(1).getScans();
            assertEquals(2, outerScansR.size());
            List<Scan> innerScansR1 = outerScansR.get(0);
            assertEquals(1, innerScansR1.size());
            Scan scanR1 = innerScansR1.get(0);
            assertEquals("A", Bytes.toString(scanR1.getStartRow()).trim());
            assertEquals("C", Bytes.toString(scanR1.getStopRow()).trim());
            List<Scan> innerScansR2 = outerScansR.get(1);
            assertEquals(1, innerScansR2.size());
            Scan scanR2 = innerScansR2.get(0);
            assertEquals("G", Bytes.toString(scanR2.getStartRow()).trim());
            assertEquals("I", Bytes.toString(scanR2.getStopRow()).trim());
        }
    }

    @Test
    public void testQueryPlanSourceRefsInHashJoin() throws SQLException {
        String query = "SELECT * FROM (\n" +
                "    SELECT K1, V1 FROM A WHERE V1 = 'A'\n" +
                ") T1 JOIN (\n" +
                "    SELECT K2, V2 FROM B WHERE V2 = 'B'\n" +
                ") T2 ON K1 = K2 ORDER BY V1";
        verifyQueryPlanSourceRefs(query, 2);
    }

    @Test
    public void testQueryPlanSourceRefsInSortMergeJoin() throws SQLException {
        String query = "SELECT * FROM (\n" +
                "    SELECT max(K1) KEY1, V1 FROM A GROUP BY V1\n" +
                ") T1 JOIN (\n" +
                "    SELECT max(K2) KEY2, V2 FROM B GROUP BY V2\n" +
                ") T2 ON KEY1 = KEY2 ORDER BY V1";
        verifyQueryPlanSourceRefs(query, 2);
    }

    @Test
    public void testQueryPlanSourceRefsInSubquery() throws SQLException {
        String query = "SELECT * FROM A\n" +
                "WHERE K1 > (\n" +
                "    SELECT max(K2) FROM B WHERE V2 = V1\n" +
                ") ORDER BY V1";
        verifyQueryPlanSourceRefs(query, 2);
    }

    @Test
    public void testQueryPlanSourceRefsInSubquery2() throws SQLException {
        String query = "SELECT * FROM A\n" +
                "WHERE V1 > ANY (\n" +
                "    SELECT K2 FROM B WHERE V2 = 'B'\n" +
                ")";
        verifyQueryPlanSourceRefs(query, 2);
    }

    @Test
    public void testQueryPlanSourceRefsInSubquery3() throws SQLException {
        String query = "SELECT * FROM A\n" +
                "WHERE V1 > ANY (\n" +
                "    SELECT K2 FROM B B1" +
                "    WHERE V2 = (\n" +
                "        SELECT max(V2) FROM B B2\n" +
                "        WHERE B2.K2 = B1.K2 AND V2 < 'K'\n" +
                "    )\n" +
                ")";
        verifyQueryPlanSourceRefs(query, 3);
    }

    @Test
    public void testQueryPlanSourceRefsInSubquery4() throws SQLException {
        String query = "SELECT * FROM (\n" +
                "    SELECT K1, K2 FROM A\n" +
                "    JOIN B ON K1 = K2\n" +
                "    WHERE V1 = 'A' AND V2 = 'B'\n" +
                "    LIMIT 10\n" +
                ") ORDER BY K1";
        verifyQueryPlanSourceRefs(query, 2);
    }

    @Test
    public void testQueryPlanSourceRefsInSubquery5() throws SQLException {
        String query = "SELECT * FROM (\n" +
                "    SELECT KEY1, KEY2 FROM (\n" +
                "        SELECT max(K1) KEY1, V1 FROM A GROUP BY V1\n" +
                "    ) T1 JOIN (\n" +
                "        SELECT max(K2) KEY2, V2 FROM B GROUP BY V2\n" +
                "    ) T2 ON KEY1 = KEY2 LIMIT 10\n" +
                ") ORDER BY KEY1";
        verifyQueryPlanSourceRefs(query, 2);
    }

    @Test
    public void testQueryPlanSourceRefsInUnion() throws SQLException {
        String query = "SELECT K1, V1 FROM A WHERE V1 = 'A'\n" +
                "UNION ALL\n" +
                "SELECT K2, V2 FROM B WHERE V2 = 'B'";
        verifyQueryPlanSourceRefs(query, 2);
    }

    private void verifyQueryPlanSourceRefs(String query, int refCount) throws SQLException {
        Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
        try (Connection conn = DriverManager.getConnection(getUrl(), props)) {
            conn.createStatement().execute("CREATE TABLE A (\n" +
                    "    K1 VARCHAR(10) NOT NULL PRIMARY KEY,\n" +
                    "    V1 VARCHAR(10))");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX1 ON A(V1)");
            conn.createStatement().execute("CREATE TABLE B (\n" +
                    "    K2 VARCHAR(10) NOT NULL PRIMARY KEY,\n" +
                    "    V2 VARCHAR(10))");
            conn.createStatement().execute("CREATE LOCAL INDEX IDX2 ON B(V2)");
            PhoenixStatement stmt = conn.createStatement().unwrap(PhoenixStatement.class);
            QueryPlan plan = stmt.compileQuery(query);
            Set<TableRef> sourceRefs = plan.getSourceRefs();
            assertEquals(refCount, sourceRefs.size());
            for (TableRef table : sourceRefs) {
                assertTrue(table.getTable().getType() == PTableType.TABLE);
            }
            plan = stmt.optimizeQuery(query);
            sourceRefs = plan.getSourceRefs();
            assertEquals(refCount, sourceRefs.size());
            for (TableRef table : sourceRefs) {
                assertTrue(table.getTable().getType() == PTableType.INDEX);
            }
        }
    }

    private static class MultipleChildrenExtractor implements QueryPlanVisitor<List<QueryPlan>> {

        @Override
        public List<QueryPlan> defaultReturn(QueryPlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(AggregatePlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(ScanPlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(ClientAggregatePlan plan) {
            return plan.getDelegate().accept(this);
        }

        @Override
        public List<QueryPlan> visit(ClientScanPlan plan) {
            return plan.getDelegate().accept(this);
        }

        @Override
        public List<QueryPlan> visit(LiteralResultIterationPlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(TupleProjectionPlan plan) {
            return plan.getDelegate().accept(this);
        }

        @Override
        public List<QueryPlan> visit(HashJoinPlan plan) {
            List<QueryPlan> children = new ArrayList<QueryPlan>(plan.getSubPlans().length + 1);
            children.add(plan.getDelegate());
            for (HashJoinPlan.SubPlan subPlan : plan.getSubPlans()) {
                children.add(subPlan.getInnerPlan());
            }
            return children;
        }

        @Override
        public List<QueryPlan> visit(SortMergeJoinPlan plan) {
            return Lists.newArrayList(plan.getLhsPlan(), plan.getRhsPlan());
        }

        @Override
        public List<QueryPlan> visit(UnionPlan plan) {
            return plan.getSubPlans();
        }

        @Override
        public List<QueryPlan> visit(UnnestArrayPlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(CorrelatePlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(CursorFetchPlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(ListJarsQueryPlan plan) {
            return Collections.emptyList();
        }

        @Override
        public List<QueryPlan> visit(TraceQueryPlan plan) {
            return Collections.emptyList();
        }
    }

    @Test
    public void testGroupByOrderMatchPkColumnOrder4690() throws Exception{
        this.doTestGroupByOrderMatchPkColumnOrderBug4690(false, false);
        this.doTestGroupByOrderMatchPkColumnOrderBug4690(false, true);
        this.doTestGroupByOrderMatchPkColumnOrderBug4690(true, false);
        this.doTestGroupByOrderMatchPkColumnOrderBug4690(true, true);
    }

    private void doTestGroupByOrderMatchPkColumnOrderBug4690(boolean desc ,boolean salted) throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());
            String tableName = generateUniqueName();
            String sql = "create table " + tableName + "( "+
                    " pk1 integer not null , " +
                    " pk2 integer not null, " +
                    " pk3 integer not null," +
                    " pk4 integer not null,"+
                    " v integer, " +
                    " CONSTRAINT TEST_PK PRIMARY KEY ( "+
                       "pk1 "+(desc ? "desc" : "")+", "+
                       "pk2 "+(desc ? "desc" : "")+", "+
                       "pk3 "+(desc ? "desc" : "")+", "+
                       "pk4 "+(desc ? "desc" : "")+
                    " )) "+(salted ? "SALT_BUCKETS =4" : "split on(2)");
            conn.createStatement().execute(sql);

            sql = "select pk2,pk1,count(v) from " + tableName + " group by pk2,pk1 order by pk2,pk1";
            QueryPlan queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() ==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("PK2"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("PK1"));

            sql = "select pk1,pk2,count(v) from " + tableName + " group by pk2,pk1 order by pk1,pk2";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == (!desc ? OrderBy.FWD_ROW_KEY_ORDER_BY : OrderBy.REV_ROW_KEY_ORDER_BY));

            sql = "select pk2,pk1,count(v) from " + tableName + " group by pk2,pk1 order by pk2 desc,pk1 desc";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() ==2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("PK2 DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("PK1 DESC"));

            sql = "select pk1,pk2,count(v) from " + tableName + " group by pk2,pk1 order by pk1 desc,pk2 desc";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == (!desc ? OrderBy.REV_ROW_KEY_ORDER_BY : OrderBy.FWD_ROW_KEY_ORDER_BY));


            sql = "select pk3,pk2,count(v) from " + tableName + " where pk1=1 group by pk3,pk2 order by pk3,pk2";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() == 2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("PK3"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("PK2"));

            sql = "select pk2,pk3,count(v) from " + tableName + " where pk1=1 group by pk3,pk2 order by pk2,pk3";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == (!desc ? OrderBy.FWD_ROW_KEY_ORDER_BY : OrderBy.REV_ROW_KEY_ORDER_BY));

            sql = "select pk3,pk2,count(v) from " + tableName + " where pk1=1 group by pk3,pk2 order by pk3 desc,pk2 desc";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() == 2);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("PK3 DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("PK2 DESC"));

            sql = "select pk2,pk3,count(v) from " + tableName + " where pk1=1 group by pk3,pk2 order by pk2 desc,pk3 desc";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == (!desc ? OrderBy.REV_ROW_KEY_ORDER_BY : OrderBy.FWD_ROW_KEY_ORDER_BY));


            sql = "select pk4,pk3,pk1,count(v) from " + tableName + " where pk2=9 group by pk4,pk3,pk1 order by pk4,pk3,pk1";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() == 3);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("PK4"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("PK3"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(2).toString().equals("PK1"));

            sql = "select pk1,pk3,pk4,count(v) from " + tableName + " where pk2=9 group by pk4,pk3,pk1 order by pk1,pk3,pk4";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == (!desc ? OrderBy.FWD_ROW_KEY_ORDER_BY : OrderBy.REV_ROW_KEY_ORDER_BY));

            sql = "select pk4,pk3,pk1,count(v) from " + tableName + " where pk2=9 group by pk4,pk3,pk1 order by pk4 desc,pk3 desc,pk1 desc";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() == 3);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(0).toString().equals("PK4 DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(1).toString().equals("PK3 DESC"));
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().get(2).toString().equals("PK1 DESC"));

            sql = "select pk1,pk3,pk4,count(v) from " + tableName + " where pk2=9 group by pk4,pk3,pk1 order by pk1 desc,pk3 desc,pk4 desc";
            queryPlan = TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == (!desc ? OrderBy.REV_ROW_KEY_ORDER_BY : OrderBy.FWD_ROW_KEY_ORDER_BY));
        } finally {
            if(conn != null) {
                conn.close();
            }
        }
    }

    @Test
    public void testSortMergeJoinPushFilterThroughSortBug5105() throws Exception {
        Connection conn = null;
        try {
            conn= DriverManager.getConnection(getUrl());

            String tableName1="MERGE1";
            String tableName2="MERGE2";

            conn.createStatement().execute("DROP TABLE if exists "+tableName1);

            String sql="CREATE TABLE IF NOT EXISTS "+tableName1+" ( "+
                    "AID INTEGER PRIMARY KEY,"+
                    "AGE INTEGER"+
                    ")";
            conn.createStatement().execute(sql);

            conn.createStatement().execute("DROP TABLE if exists "+tableName2);
            sql="CREATE TABLE IF NOT EXISTS "+tableName2+" ( "+
                    "BID INTEGER PRIMARY KEY,"+
                    "CODE INTEGER"+
                    ")";
            conn.createStatement().execute(sql);

            //test for simple scan
            sql="select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid where b.code > 50";

            QueryPlan queryPlan=getQueryPlan(conn, sql);
            SortMergeJoinPlan sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            ClientScanPlan lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            OrderBy orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            ScanPlan innerScanPlan=(ScanPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AGE"));
            assertTrue(innerScanPlan.getLimit().intValue() == 3);

            ClientScanPlan rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            String tableAlias = rhsOuterPlan.getTableRef().getTableAlias();
            String rewrittenSql = "SELECT "+tableAlias+".BID,"+tableAlias+".CODE FROM (SELECT BID,CODE FROM MERGE2  ORDER BY CODE LIMIT 1) "+tableAlias+" WHERE "+tableAlias+".CODE > 50 ORDER BY "+tableAlias+".BID";
            assertTrue(rhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("BID"));
            innerScanPlan=(ScanPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("CODE"));
            assertTrue(innerScanPlan.getLimit().intValue() == 1);

            //test for aggregate
            sql="select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.codesum from (select aid,sum(age) agesum from "+tableName1+" where age >=11 and age<=33 group by aid order by agesum limit 3) a inner join "+
                "(select bid,sum(code) codesum from "+tableName2+" group by bid order by codesum limit 1) b on a.aid=b.bid where b.codesum > 50";


            queryPlan=getQueryPlan(conn, sql);
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            AggregatePlan innerAggregatePlan=(AggregatePlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(AGE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            tableAlias = rhsOuterPlan.getTableRef().getTableAlias();
            rewrittenSql = "SELECT "+tableAlias+".BID,"+tableAlias+".CODESUM FROM (SELECT BID, SUM(CODE) CODESUM FROM MERGE2  GROUP BY BID ORDER BY CODESUM LIMIT 1) "+tableAlias+" WHERE "+tableAlias+".CODESUM > 50 ORDER BY "+tableAlias+".BID";
            assertTrue(rhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("BID"));
            innerAggregatePlan=(AggregatePlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(CODE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 1);

            String tableName3="merge3";
            conn.createStatement().execute("DROP TABLE if exists "+tableName3);
            sql="CREATE TABLE IF NOT EXISTS "+tableName3+" ( "+
                    "CID INTEGER PRIMARY KEY,"+
                    "REGION INTEGER"+
                    ")";
            conn.createStatement().execute(sql);

            //test for join
            sql="select t1.aid,t1.code,t2.region from "+
                "(select a.aid,b.code from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid where b.code >=44 and b.code<=66 order by b.code limit 3) t1 inner join "+
                "(select a.aid,c.region from "+tableName1+" a inner join "+tableName3+" c on a.aid=c.cid where c.region>=77 and c.region<=99 order by c.region desc limit 1) t2 on t1.aid=t2.aid "+
                "where t1.code > 50";

            PhoenixPreparedStatement phoenixPreparedStatement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
            queryPlan = phoenixPreparedStatement.optimizeQuery(sql);
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            tableAlias = lhsOuterPlan.getTableRef().getTableAlias();
            rewrittenSql = "SELECT "+tableAlias+".AID,"+tableAlias+".CODE FROM (SELECT A.AID,B.CODE FROM MERGE1 A  Inner JOIN MERGE2 B  ON (A.AID = B.BID) WHERE (B.CODE >= 44 AND B.CODE <= 66) ORDER BY B.CODE LIMIT 3) "+
                           tableAlias+" WHERE "+tableAlias+".CODE > 50 ORDER BY "+tableAlias+".AID";
            assertTrue(lhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerScanPlan=(ScanPlan)((HashJoinPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("B.CODE"));
            assertTrue(innerScanPlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerScanPlan=(ScanPlan)((HashJoinPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerScanPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("C.REGION DESC"));
            assertTrue(innerScanPlan.getLimit().intValue() == 1);

            //test for join and aggregate
            sql="select t1.aid,t1.codesum,t2.regionsum from "+
                "(select a.aid,sum(b.code) codesum from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid where b.code >=44 and b.code<=66 group by a.aid order by codesum limit 3) t1 inner join "+
                "(select a.aid,sum(c.region) regionsum from "+tableName1+" a inner join "+tableName3+" c on a.aid=c.cid where c.region>=77 and c.region<=99 group by a.aid order by regionsum desc limit 2) t2 on t1.aid=t2.aid "+
                "where t1.codesum >=40 and t2.regionsum >= 90";

            phoenixPreparedStatement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
            queryPlan = phoenixPreparedStatement.optimizeQuery(sql);
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getLhsPlan())).getDelegate();
            tableAlias = lhsOuterPlan.getTableRef().getTableAlias();
            rewrittenSql = "SELECT "+tableAlias+".AID,"+tableAlias+".CODESUM FROM (SELECT A.AID, SUM(B.CODE) CODESUM FROM MERGE1 A  Inner JOIN MERGE2 B  ON (A.AID = B.BID) WHERE (B.CODE >= 44 AND B.CODE <= 66) GROUP BY A.AID ORDER BY CODESUM LIMIT 3) "+tableAlias+
                           " WHERE "+tableAlias+".CODESUM >= 40 ORDER BY "+tableAlias+".AID";
            assertTrue(lhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            orderBy=lhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(B.CODE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            tableAlias = rhsOuterPlan.getTableRef().getTableAlias();
            rewrittenSql = "SELECT "+tableAlias+".AID,"+tableAlias+".REGIONSUM FROM (SELECT A.AID, SUM(C.REGION) REGIONSUM FROM MERGE1 A  Inner JOIN MERGE3 C  ON (A.AID = C.CID) WHERE (C.REGION >= 77 AND C.REGION <= 99) GROUP BY A.AID ORDER BY REGIONSUM DESC LIMIT 2) "+tableAlias+
                           " WHERE "+tableAlias+".REGIONSUM >= 90 ORDER BY "+tableAlias+".AID";
            assertTrue(rhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("SUM(C.REGION) DESC"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 2);

            //test for if SubselectRewriter.isOrderByPrefix had take effect
            sql="select t1.aid,t1.codesum,t2.regionsum from "+
                "(select a.aid,sum(b.code) codesum from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid where b.code >=44 and b.code<=66 group by a.aid order by a.aid,codesum limit 3) t1 inner join "+
                "(select a.aid,sum(c.region) regionsum from "+tableName1+" a inner join "+tableName3+" c on a.aid=c.cid where c.region>=77 and c.region<=99 group by a.aid order by a.aid desc,regionsum desc limit 2) t2 on t1.aid=t2.aid "+
                 "where t1.codesum >=40 and t2.regionsum >= 90 order by t1.aid desc";

            phoenixPreparedStatement = conn.prepareStatement(sql).unwrap(PhoenixPreparedStatement.class);
            queryPlan = phoenixPreparedStatement.optimizeQuery(sql);
            orderBy=queryPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("T1.AID DESC"));
            sortMergeJoinPlan=(SortMergeJoinPlan)((ClientScanPlan)queryPlan).getDelegate();

            lhsOuterPlan = (ClientScanPlan)(((TupleProjectionPlan)sortMergeJoinPlan.getLhsPlan()).getDelegate());
            tableAlias = lhsOuterPlan.getTableRef().getTableAlias();
            rewrittenSql = "SELECT "+tableAlias+".AID,"+tableAlias+".CODESUM FROM (SELECT A.AID, SUM(B.CODE) CODESUM FROM MERGE1 A  Inner JOIN MERGE2 B  ON (A.AID = B.BID) WHERE (B.CODE >= 44 AND B.CODE <= 66) GROUP BY A.AID ORDER BY A.AID,CODESUM LIMIT 3) "+tableAlias+
                           " WHERE "+tableAlias+".CODESUM >= 40";
            assertTrue(lhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)lhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 2);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("A.AID"));
            assertTrue(orderBy.getOrderByExpressions().get(1).toString().equals("SUM(B.CODE)"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 3);

            rhsOuterPlan=(ClientScanPlan)((TupleProjectionPlan)(sortMergeJoinPlan.getRhsPlan())).getDelegate();
            tableAlias = rhsOuterPlan.getTableRef().getTableAlias();
            rewrittenSql = "SELECT "+tableAlias+".AID,"+tableAlias+".REGIONSUM FROM (SELECT A.AID, SUM(C.REGION) REGIONSUM FROM MERGE1 A  Inner JOIN MERGE3 C  ON (A.AID = C.CID) WHERE (C.REGION >= 77 AND C.REGION <= 99) GROUP BY A.AID ORDER BY A.AID DESC,REGIONSUM DESC LIMIT 2) "+tableAlias+
                           " WHERE "+tableAlias+".REGIONSUM >= 90 ORDER BY "+tableAlias+".AID";
            assertTrue(rhsOuterPlan.getStatement().toString().equals(rewrittenSql));

            orderBy=rhsOuterPlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 1);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("AID"));
            innerAggregatePlan=(AggregatePlan)((HashJoinPlan)((TupleProjectionPlan)rhsOuterPlan.getDelegate()).getDelegate()).getDelegate();
            orderBy=innerAggregatePlan.getOrderBy();
            assertTrue(orderBy.getOrderByExpressions().size() == 2);
            assertTrue(orderBy.getOrderByExpressions().get(0).toString().equals("A.AID DESC"));
            assertTrue(orderBy.getOrderByExpressions().get(1).toString().equals("SUM(C.REGION) DESC"));
            assertTrue(innerAggregatePlan.getLimit().intValue() == 2);
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testOrderPreservingForClientScanPlanBug5148() throws Exception {
        doTestOrderPreservingForClientScanPlanBug5148(false,false);
        doTestOrderPreservingForClientScanPlanBug5148(false,true);
        doTestOrderPreservingForClientScanPlanBug5148(true, false);
        doTestOrderPreservingForClientScanPlanBug5148(true, true);
    }

    private void doTestOrderPreservingForClientScanPlanBug5148(boolean desc, boolean salted) throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());
            String tableName = generateUniqueName();
            String sql = "create table " + tableName + "( "+
                    " pk1 char(20) not null , " +
                    " pk2 char(20) not null, " +
                    " pk3 char(20) not null," +
                    " v1 varchar, " +
                    " v2 varchar, " +
                    " CONSTRAINT TEST_PK PRIMARY KEY ( "+
                    "pk1 "+(desc ? "desc" : "")+", "+
                    "pk2 "+(desc ? "desc" : "")+", "+
                    "pk3 "+(desc ? "desc" : "")+
                    " )) "+(salted ? "SALT_BUCKETS =4" : "");
            conn.createStatement().execute(sql);

            sql = "select v1 from (select v1,v2,pk3 from "+tableName+" t where pk1 = '6' order by t.v2,t.pk3,t.v1 limit 10) a order by v2,pk3";
            QueryPlan plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select v1 from (select v1,v2,pk3 from "+tableName+" t where pk1 = '6' order by t.v2,t.pk3,t.v1 limit 10) a where pk3 = '8' order by v2,v1";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select v1 from (select v1,v2,pk3 from "+tableName+" t where pk1 = '6' order by t.v2 desc,t.pk3 desc,t.v1 desc limit 10) a order by v2 desc ,pk3 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v2,0,2) sub,cast (count(pk3) as bigint) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by count(pk3),t.v2 limit 10) a order by cnt,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by count(pk3),t.v2 limit 10) a order by cast(cnt as bigint),substr(sub,0,1)";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v2,0,2) sub,cast (count(pk3) as bigint) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by count(pk3) desc,t.v2 desc limit 10) a order by cnt desc ,sub desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v2,0,2) sub,pk2 from "+tableName+" t where pk1 = '6' group by pk2,v2 limit 10) a order by pk2,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            if(desc) {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            } else {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            }

            sql = "select sub from (select substr(v2,0,2) sub,pk2 from "+tableName+" t where pk1 = '6' group by pk2,v2 limit 10) a order by pk2 desc,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            if(desc) {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            } else {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            }

            sql = "select sub from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by t.v2 ,count(pk3) limit 10) a order by sub ,cnt";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select sub from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by t.v2 ,count(pk3) limit 10) a order by substr(sub,0,1) ,cast(cnt as bigint)";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select sub from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by t.v2 ,count(pk3) limit 10) a order by sub ,cnt";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select v1 from (select v1,v2,pk3  from "+tableName+" t where pk1 = '6' order by t.v2 desc,t.pk3 desc,t.v1 desc limit 10) a order by v2 ,pk3";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select v1 from (select v1,v2,pk3 from "+tableName+" t where pk1 = '6' order by t.v2,t.pk3,t.v1 limit 10) a where pk3 = '8' or (v2 < 'abc' and pk3 > '11') order by v2,v1";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);

            //test innerQueryPlan is ordered by rowKey
            sql = "select pk1 from (select pk3,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1,t.pk2 limit 10) a where pk3 > '8' order by pk1,pk2,pk3";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select pk1 from (select substr(pk3,0,3) sub,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1,t.pk2 limit 10) a where sub > '8' order by pk1,pk2,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select pk1 from (select pk3,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1 desc,t.pk2 desc limit 10) a where pk3 > '8' order by pk1 desc ,pk2 desc ,pk3 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select pk1 from (select substr(pk3,0,3) sub,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1 desc,t.pk2 desc limit 10) a where sub > '8' order by pk1 desc,pk2 desc,sub desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
        } finally {
            if(conn != null) {
                conn.close();
            }
        }
    }

    @Test
    public void testGroupByOrderPreservingForClientAggregatePlanBug5148() throws Exception {
        doTestGroupByOrderPreservingForClientAggregatePlanBug5148(false, false);
        doTestGroupByOrderPreservingForClientAggregatePlanBug5148(false, true);
        doTestGroupByOrderPreservingForClientAggregatePlanBug5148(true, false);
        doTestGroupByOrderPreservingForClientAggregatePlanBug5148(true, true);
    }

    private void doTestGroupByOrderPreservingForClientAggregatePlanBug5148(boolean desc, boolean salted) throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());
            String tableName = generateUniqueName();
            String sql = "create table " + tableName + "( "+
                    " pk1 varchar not null , " +
                    " pk2 varchar not null, " +
                    " pk3 varchar not null," +
                    " v1 varchar, " +
                    " v2 varchar, " +
                    " CONSTRAINT TEST_PK PRIMARY KEY ( "+
                    "pk1 "+(desc ? "desc" : "")+", "+
                    "pk2 "+(desc ? "desc" : "")+", "+
                    "pk3 "+(desc ? "desc" : "")+
                    " )) "+(salted ? "SALT_BUCKETS =4" : "");
            conn.createStatement().execute(sql);

            sql = "select v1 from (select v1,pk2,pk1 from "+tableName+" t where pk1 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a group by pk2,v1 order by pk2,v1";
            QueryPlan plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select v1 from (select v1,pk2,pk1 from "+tableName+" t where pk1 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a where pk2 = '8' group by v1, pk1 order by v1,pk1";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select v1 from (select v1,pk2,pk1 from "+tableName+" t where pk1 = '6' order by t.pk2 desc,t.v1 desc,t.pk1 limit 10) a group by pk2, v1 order by pk2 desc,v1 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select v1 from (select v1,pk2,pk1 from "+tableName+" t where pk1 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a where pk2 = '8' or (v1 < 'abc' and pk2 > '11') group by v1, pk1 order by v1,pk1";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(!plan.getGroupBy().isOrderPreserving());
            if(desc) {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            } else {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            }

            sql = "select v1 from (select v1,pk2,pk1 from "+tableName+" t where pk1 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a where pk2 = '8' or (v1 < 'abc' and pk2 > '11') group by v1, pk1 order by v1,pk1 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(!plan.getGroupBy().isOrderPreserving());
            if(desc) {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            } else {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            }

            sql = "select sub from (select v1,pk2,substr(pk1,0,1) sub from "+tableName+" t where v2 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a where pk2 = '8' group by v1,sub order by v1,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v1,0,1) sub,pk2,pk1 from "+tableName+" t where v2 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a where pk2 = '8' group by sub,pk1 order by sub,pk1";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(!plan.getGroupBy().isOrderPreserving());
            if(desc) {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            } else {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            }

            sql = "select sub from (select substr(v1,0,1) sub,pk2,pk1 from "+tableName+" t where v2 = '6' order by t.pk2,t.v1,t.pk1 limit 10) a where pk2 = '8' group by sub,pk1 order by sub,pk1 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(!plan.getGroupBy().isOrderPreserving());
            if(desc) {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            } else {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            }

            sql = "select sub from (select substr(v2,0,2) sub,cast (count(pk3) as bigint) cnt from "+tableName+" t where pk1 = '6' group by v1,v2 order by count(pk3),t.v2 limit 10) a group by cnt,sub order by cnt,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select substr(sub,0,1) from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by count(pk3),t.v2 limit 10) a "+
                  "group by cast(cnt as bigint),substr(sub,0,1) order by cast(cnt as bigint),substr(sub,0,1)";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by count(pk3) desc,t.v2 desc limit 10) a group by cnt,sub order by cnt desc ,sub desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select substr(sub,0,1) from (select substr(v2,0,2) sub,count(pk3) cnt from "+tableName+" t where pk1 = '6' group by v1 ,v2 order by count(pk3) desc,t.v2 desc limit 10) a "+
                  "group by cast(cnt as bigint),substr(sub,0,1) order by cast(cnt as bigint) desc,substr(sub,0,1) desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select sub from (select substr(v2,0,2) sub,pk2 from "+tableName+" t where pk1 = '6' group by pk2,v2 limit 10) a group by pk2,sub order by pk2,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            if(desc) {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            } else {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            }

            sql = "select sub from (select substr(v2,0,2) sub,pk2 from "+tableName+" t where pk1 = '6' group by pk2,v2 limit 10) a group by pk2,sub order by pk2 desc,sub";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            if(desc) {
                assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
            } else {
                assertTrue(plan.getOrderBy().getOrderByExpressions().size() > 0);
            }

            //test innerQueryPlan is ordered by rowKey
            sql = "select pk1 from (select pk3,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1,t.pk2 limit 10) a where pk3 > '8' group by pk1,pk2,pk3 order by pk1,pk2,pk3";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select pk1 from (select substr(pk3,0,3) sub,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1,t.pk2 limit 10) a where sub > '8' group by pk1,pk2,sub order by pk1,pk2";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select pk1 from (select pk3,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1 desc,t.pk2 desc limit 10) a where pk3 > '8' group by pk1, pk2, pk3 order by pk1 desc ,pk2 desc ,pk3 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select pk1 from (select substr(pk3,0,3) sub,pk2,pk1 from "+tableName+" t where v1 = '6' order by t.pk1 desc,t.pk2 desc limit 10) a where sub > '8' group by pk1,pk2,sub order by pk1 desc,pk2 desc";
            plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            assertTrue(plan.getGroupBy().isOrderPreserving());
            assertTrue(plan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);
        } finally {
            if(conn != null) {
                conn.close();
            }
        }
    }

    @Test
    public void testOrderPreservingForSortMergeJoinBug5148() throws Exception {
        doTestOrderPreservingForSortMergeJoinBug5148(false, false);
        doTestOrderPreservingForSortMergeJoinBug5148(false, true);
        doTestOrderPreservingForSortMergeJoinBug5148(true, false);
        doTestOrderPreservingForSortMergeJoinBug5148(true, true);
    }

    private void doTestOrderPreservingForSortMergeJoinBug5148(boolean desc, boolean salted) throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());

            String tableName1 = generateUniqueName();
            String tableName2 = generateUniqueName();

            String sql = "CREATE TABLE IF NOT EXISTS "+tableName1+" ( "+
                    "AID INTEGER PRIMARY KEY "+(desc ? "desc" : "")+","+
                    "AGE INTEGER"+
                    ") "+(salted ? "SALT_BUCKETS =4" : "");
            conn.createStatement().execute(sql);

            sql = "CREATE TABLE IF NOT EXISTS "+tableName2+" ( "+
                    "BID INTEGER PRIMARY KEY "+(desc ? "desc" : "")+","+
                    "CODE INTEGER"+
                    ")"+(salted ? "SALT_BUCKETS =4" : "");
            conn.createStatement().execute(sql);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code order by a.aid ,a.age";
            QueryPlan queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code order by a.aid desc,a.age desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,a.age from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code group by a.aid,a.age order by a.aid ,a.age";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,a.age from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code group by a.aid,a.age order by a.aid desc,a.age desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code order by b.bid ,b.code";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code order by b.bid desc ,b.code desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code group by b.bid, b.code order by b.bid ,b.code";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.code from (select aid,age from "+tableName1+" where age >=11 and age<=33 order by age limit 3) a inner join "+
                    "(select bid,code from "+tableName2+" order by code limit 1) b on a.aid=b.bid and a.age = b.code group by b.bid, b.code order by b.bid desc,b.code desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);
            //test part column
            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code order by a.aid";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code order by a.aid desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code group by a.aid order by a.aid";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code group by a.aid order by a.aid desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ a.aid,b.code from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code order by a.age";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.bid,a.age from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code order by b.bid";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.bid,a.age from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code order by b.bid desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.bid from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code group by b.bid order by b.bid";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy() == OrderBy.FWD_ROW_KEY_ORDER_BY);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.bid from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code group by b.bid order by b.bid desc";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getGroupBy().isOrderPreserving());
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);

            sql = "select /*+ USE_SORT_MERGE_JOIN */ b.bid,a.age from "+tableName1+" a inner join "+tableName2+" b on a.aid=b.bid and a.age = b.code order by b.code";
            queryPlan = getQueryPlan(conn, sql);
            assertTrue(queryPlan.getOrderBy().getOrderByExpressions().size() > 0);
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }

    @Test
    public void testSortMergeBug4508() throws Exception {
        Connection conn = null;
        Connection conn010 = null;
        try {
            // Salted tables
            Properties props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            conn = DriverManager.getConnection(getUrl(), props);
            props = PropertiesUtil.deepCopy(TEST_PROPERTIES);
            props.setProperty("TenantId", "010");
            conn010 = DriverManager.getConnection(getUrl(), props);

            String peopleTable1 = generateUniqueName();
            String myTable1 = generateUniqueName();
            conn.createStatement().execute("CREATE TABLE " + peopleTable1 + " (\n" +
                    "PERSON_ID VARCHAR NOT NULL,\n" +
                    "NAME VARCHAR\n" +
                    "CONSTRAINT PK_TEST_PEOPLE PRIMARY KEY (PERSON_ID)) SALT_BUCKETS = 3");
            conn.createStatement().execute("CREATE TABLE " + myTable1 + " (\n" +
                    "LOCALID VARCHAR NOT NULL,\n" +
                    "DSID VARCHAR(255) NOT NULL, \n" +
                    "EID CHAR(40),\n" +
                    "HAS_CANDIDATES BOOLEAN\n" +
                    "CONSTRAINT PK_MYTABLE PRIMARY KEY (LOCALID, DSID)) SALT_BUCKETS = 3");
            verifyQueryPlanForSortMergeBug4508(conn, peopleTable1, myTable1);

            // Salted multi-tenant tables
            String peopleTable2 = generateUniqueName();
            String myTable2 = generateUniqueName();
            conn.createStatement().execute("CREATE TABLE " + peopleTable2 + " (\n" +
                    "TENANT_ID VARCHAR NOT NULL,\n" +
                    "PERSON_ID VARCHAR NOT NULL,\n" +
                    "NAME VARCHAR\n" +
                    "CONSTRAINT PK_TEST_PEOPLE PRIMARY KEY (TENANT_ID, PERSON_ID))\n" +
                    "SALT_BUCKETS = 3, MULTI_TENANT=true");
            conn.createStatement().execute("CREATE TABLE " + myTable2 + " (\n" +
                    "TENANT_ID VARCHAR NOT NULL,\n" +
                    "LOCALID VARCHAR NOT NULL,\n" +
                    "DSID VARCHAR(255) NOT NULL, \n" +
                    "EID CHAR(40),\n" +
                    "HAS_CANDIDATES BOOLEAN\n" +
                    "CONSTRAINT PK_MYTABLE PRIMARY KEY (TENANT_ID, LOCALID, DSID))\n" +
                    "SALT_BUCKETS = 3, MULTI_TENANT=true");
            verifyQueryPlanForSortMergeBug4508(conn010, peopleTable2, myTable2);
        } finally {
            if(conn!=null) {
                conn.close();
            }
            if(conn010 != null) {
                conn010.close();
            }
        }
    }

    private static void verifyQueryPlanForSortMergeBug4508(Connection conn, String peopleTable, String myTable) throws Exception {
        String query1 = "SELECT /*+ USE_SORT_MERGE_JOIN*/ COUNT(*)\n" +
                "FROM " + peopleTable + " ds JOIN " + myTable + " l\n" +
                "ON ds.PERSON_ID = l.LOCALID\n" +
                "WHERE l.EID IS NULL AND l.DSID = 'PEOPLE' AND l.HAS_CANDIDATES = FALSE";
        String query2 = "SELECT /*+ USE_SORT_MERGE_JOIN */ COUNT(*)\n" +
                "FROM (SELECT LOCALID FROM " + myTable + "\n" +
                "WHERE EID IS NULL AND DSID = 'PEOPLE' AND HAS_CANDIDATES = FALSE) l\n" +
                "JOIN " + peopleTable + " ds ON ds.PERSON_ID = l.LOCALID";

        for (String q : new String[]{query1, query2}) {
            ResultSet rs = conn.createStatement().executeQuery("explain " + q);
            String plan = QueryUtil.getExplainPlan(rs);
            assertFalse("Tables should not require sort over their PKs:\n" + plan,
                    plan.contains("SERVER SORTED BY"));
        }
    }

    @Test
    public void testDistinctCountLimitBug5217() throws Exception {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(getUrl());
            String tableName = generateUniqueName();
            String sql = "create table " + tableName + "( "+
                    " pk1 integer not null , " +
                    " pk2 integer not null, " +
                    " v integer, " +
                    " CONSTRAINT TEST_PK PRIMARY KEY (pk1,pk2))";
            conn.createStatement().execute(sql);

            sql = "select count(distinct pk1) from " + tableName + " limit 1";
            QueryPlan plan =  TestUtil.getOptimizeQueryPlan(conn, sql);
            Scan scan = plan.getContext().getScan();
            assertFalse(TestUtil.hasFilter(scan, PageFilter.class));
        } finally {
            if(conn!=null) {
                conn.close();
            }
        }
    }
}



public class QueryParserTest {
    private void parseQuery(String sql) throws IOException, SQLException {
        SQLParser parser = new SQLParser(new StringReader(sql));
        BindableStatement stmt = null;
        stmt = parser.parseStatement();
        if (stmt.getOperation() != Operation.QUERY) {
            return;
        }
        String newSQL = stmt.toString();
        SQLParser newParser = new SQLParser(new StringReader(newSQL));
        BindableStatement newStmt = null;
        try {
            newStmt = newParser.parseStatement();
        } catch (SQLException e) {
            fail("Unable to parse new:\n" + newSQL);
        }
        assertEquals("Expected equality:\n" + sql + "\n" + newSQL, stmt, newStmt);
    }

    private void parseQueryThatShouldFail(String sql) throws Exception {
        try {
            parseQuery(sql);
            fail("Query should throw a PhoenixParserException \n " + sql);
        }
        catch (PhoenixParserException e){
        }
    }

    @Test
    public void testParseGrantQuery() throws Exception {

        String sql0 = "GRANT 'RX' ON SYSTEM.\"SEQUENCE\" TO 'user'";
        parseQuery(sql0);
        String sql1 = "GRANT 'RWXCA' ON TABLE some_table0 TO 'user0'";
        parseQuery(sql1);
        String sql2 = "GRANT 'RWX' ON some_table1 TO 'user1'";
        parseQuery(sql2);
        String sql3 = "GRANT 'CA' ON SCHEMA some_schema2 TO 'user2'";
        parseQuery(sql3);
        String sql4 = "GRANT 'RXW' ON some_table3 TO GROUP 'group3'";
        parseQuery(sql4);
        String sql5 = "GRANT 'RXW' ON \"some_schema5\".\"some_table5\" TO GROUP 'group5'";
        parseQuery(sql5);
        String sql6 = "GRANT 'RWA' TO 'user6'";
        parseQuery(sql6);
        String sql7 = "GRANT 'A' TO GROUP 'group7'";
        parseQuery(sql7);
        String sql8 = "GRANT 'ARXRRRRR' TO GROUP 'group8'";
        parseQueryThatShouldFail(sql8);
    }

    @Test
    public void testParseRevokeQuery() throws Exception {

        String sql0 = "REVOKE ON SCHEMA SYSTEM FROM 'user0'";
        parseQuery(sql0);
        String sql1 = "REVOKE ON SYSTEM.\"SEQUENCE\" FROM 'user1'";
        parseQuery(sql1);
        String sql2 = "REVOKE ON TABLE some_table2 FROM GROUP 'group2'";
        parseQuery(sql2);
        String sql3 = "REVOKE ON some_table3 FROM GROUP 'group2'";
        parseQuery(sql3);
        String sql4 = "REVOKE FROM 'user4'";
        parseQuery(sql4);
        String sql5 = "REVOKE FROM GROUP 'group5'";
        parseQuery(sql5);
        String sql6 = "REVOKE 'RRWWXAAA' FROM GROUP 'group6'";
        parseQueryThatShouldFail(sql6);
    }

    @Test
    public void testParsePreQuery0() throws Exception {
        String sql = ((
            "select a from b\n" +
            "where ((ind.name = 'X')" +
            "and rownum <= (1000 + 1000))\n"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParsePreQuery1() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ count(1) from core.search_name_lookup ind\n" +
            "where( (ind.name = 'X'\n" +
            "and rownum <= 1 + 2)\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.name_type = 't'))"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParsePreQuery2() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ count(1) from core.custom_index_value ind\n" +
            "where (ind.string_value in ('a', 'b', 'c', 'd'))\n" +
            "and rownum <= ( 3 + 1 )\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.deleted = '0')\n" +
            "and (ind.index_num = 1)"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParsePreQuery3() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ count(1) from core.custom_index_value ind\n" +
            "where (ind.number_value > 3)\n" +
            "and rownum <= 1000\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '001'\n" +
            "and (ind.deleted = '0'))\n" +
            "and (ind.index_num = 2)"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParsePreQuery4() throws Exception {
        String sql = ((
            "select /*+ index(t iecustom_entity_data_created) */ /*gatherSlowStats*/ count(1) from core.custom_entity_data t\n" +
            "where (t.created_date > to_date('01/01/2001'))\n" +
            "and rownum <= 4500\n" +
            "and (t.organization_id = '000000000000000')\n" +
            "and (t.key_prefix = '001')"
            ));
        parseQuery(sql);
    }

    @Test
    public void testCountDistinctQuery() throws Exception {
        String sql = ((
                "select count(distinct foo) from core.custom_entity_data t\n"
                        + "where (t.created_date > to_date('01/01/2001'))\n"
                        + "and (t.organization_id = '000000000000000')\n"
                        + "and (t.key_prefix = '001')\n" + "limit 4500"));
        parseQuery(sql);
    }

    @Test
    public void testIsNullQuery() throws Exception {
        String sql = ((
            "select count(foo) from core.custom_entity_data t\n" +
            "where (t.created_date is null)\n" +
            "and (t.organization_id is not null)\n"
            ));
        parseQuery(sql);
    }

    @Test
    public void testAsInColumnAlias() throws Exception {
        String sql = ((
            "select count(foo) AS c from core.custom_entity_data t\n" +
            "where (t.created_date is null)\n" +
            "and (t.organization_id is not null)\n"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParseJoin1() throws Exception {
        String sql = ((
            "select /*SOQL*/ \"Id\"\n" +
            "from (select /*+ ordered index(cft) */\n" +
            "cft.val188 \"Marketing_Offer_Code__c\",\n" +
            "t.account_id \"Id\"\n" +
            "from sales.account_cfdata cft,\n" +
            "sales.account t\n" +
            "where (cft.account_cfdata_id = t.account_id)\n" +
            "and (cft.organization_id = '00D300000000XHP')\n" +
            "and (t.organization_id = '00D300000000XHP')\n" +
            "and (t.deleted = '0')\n" +
            "and (t.account_id != '000000000000000'))\n" +
            "where (\"Marketing_Offer_Code__c\" = 'FSCR')"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParseJoin2() throws Exception {
        String sql = ((
            "select /*rptacctlist 00O40000002C3of*/ \"00N40000001M8VK\",\n" +
            "\"00N40000001M8VK.ID\",\n" +
            "\"00N30000000r0K2\",\n" +
            "\"00N30000000jgjo\"\n" +
            "from (select /*+ ordered use_hash(aval368) index(cfa) */\n" +
            "a.record_type_id \"RECORDTYPE\",\n" +
            "aval368.last_name,aval368.first_name || ' ' || aval368.last_name,aval368.name \"00N40000001M8VK\",\n" +
            "a.last_update \"LAST_UPDATE\",\n" +
            "cfa.val368 \"00N40000001M8VK.ID\",\n" +
            "TO_DATE(cfa.val282) \"00N30000000r0K2\",\n" +
            "cfa.val252 \"00N30000000jgjo\"\n" +
            "from sales.account a,\n" +
            "sales.account_cfdata cfa,\n" +
            "core.name_denorm aval368\n" +
            "where (cfa.account_cfdata_id = a.account_id)\n" +
            "and (aval368.entity_id = cfa.val368)\n" +
            "and (a.deleted = '0')\n" +
            "and (a.organization_id = '00D300000000EaE')\n" +
            "and (a.account_id <> '000000000000000')\n" +
            "and (cfa.organization_id = '00D300000000EaE')\n" +
            "and (aval368.organization_id = '00D300000000EaE')\n" +
            "and (aval368.entity_id like '005%'))\n" +
            "where (\"RECORDTYPE\" = '0123000000002Gv')\n" +
            "AND (\"00N40000001M8VK\" is null or \"00N40000001M8VK\" in ('BRIAN IRWIN', 'BRIAN MILLER', 'COLLEEN HORNYAK', 'ERNIE ZAVORAL JR', 'JAMIE TRIMBUR', 'JOE ANTESBERGER', 'MICHAEL HYTLA', 'NATHAN DELSIGNORE', 'SANJAY GANDHI', 'TOM BASHIOUM'))\n" +
            "AND (\"LAST_UPDATE\" >= to_date('2009-08-01 07:00:00'))"
            ));
        parseQuery(sql);
    }

    @Test
    public void testNegative1() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ count(1) core.search_name_lookup ind\n" +
            "where (ind.name = 'X')\n" +
            "and rownum <= 2000\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.name_type = 't')"
            ));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.MISSING_TOKEN.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testNegative2() throws Exception {
        String sql = ((
            "seelect /*gatherSlowStats*/ count(1) from core.search_name_lookup ind\n" +
            "where (ind.name = 'X')\n" +
            "and rownum <= 2000\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.name_type = 't')"
            ));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 601 (42P00): Syntax error. Encountered \"seelect\" at line 1, column 1."));
        }
    }

    @Test
    public void testNegative3() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ count(1) from core.search_name_lookup ind\n" +
            "where (ind.name = 'X')\n" +
            "and rownum <= 2000\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.name_type = 't'))"
            ));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 603 (42P00): Syntax error. Unexpected input. Expecting \"EOF\", got \")\" at line 6, column 26."));
        }
    }

    @Test
    public void testNegativeCountDistinct() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ max( distinct 1) from core.search_name_lookup ind\n" +
            "where (ind.name = 'X')\n" +
            "and rownum <= 2000\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.name_type = 't')"
            ));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLFeatureNotSupportedException e) {
            // expected
        }
    }

    @Test
    public void testNegativeCountStar() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ max(*) from core.search_name_lookup ind\n" +
            "where (ind.name = 'X')\n" +
            "and rownum <= 2000\n" +
            "and (ind.organization_id = '000000000000000')\n" +
            "and (ind.key_prefix = '00T')\n" +
            "and (ind.name_type = 't')"
            ));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 601 (42P00): Syntax error. Encountered \"*\" at line 1, column 32."));
        }
    }

    @Test
    public void testNegativeNonBooleanWhere() throws Exception {
        String sql = ((
            "select /*gatherSlowStats*/ max( distinct 1) from core.search_name_lookup ind\n" +
            "where 1"
            ));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLFeatureNotSupportedException e) {
            // expected
        }
    }

    @Test
    public void testCommentQuery() throws Exception {
        String sql = ((
            "select a from b -- here we come\n" +
            "where ((ind.name = 'X') // to save the day\n" +
            "and rownum /* won't run */ <= (1000 + 1000))\n"
            ));
        parseQuery(sql);
    }

    @Test
    public void testQuoteEscapeQuery() throws Exception {
        String sql = ((
            "select a from b\n" +
            "where ind.name = 'X''Y'\n"
            ));
        parseQuery(sql);
    }

    @Test
    public void testSubtractionInSelect() throws Exception {
        String sql = ((
            "select a, 3-1-2, -4- -1-1 from b\n" +
            "where d = c - 1\n"
            ));
        parseQuery(sql);
    }

    @Test
    public void testParsingStatementWithMispellToken() throws Exception {
        try {
            String sql = ((
                    "selects a from b\n" +
                    "where e = d\n"));
            parseQuery(sql);
            fail("Should have caught exception.");
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 601 (42P00): Syntax error. Encountered \"selects\" at line 1, column 1."));
        }
        try {
            String sql = ((
                    "select a froms b\n" +
                    "where e = d\n"));
            parseQuery(sql);
            fail("Should have caught exception.");
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 602 (42P00): Syntax error. Missing \"EOF\" at line 1, column 16."));
        }
    }

    @Test
    public void testParsingStatementWithExtraToken() throws Exception {
        try {
            String sql = ((
                    "select a,, from b\n" +
                    "where e = d\n"));
            parseQuery(sql);
            fail("Should have caught exception.");
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 601 (42P00): Syntax error. Encountered \",\" at line 1, column 10."));
        }
        try {
            String sql = ((
                    "select a from from b\n" +
                    "where e = d\n"));
            parseQuery(sql);
            fail("Should have caught exception.");
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 601 (42P00): Syntax error. Encountered \"from\" at line 1, column 15."));
        }
    }

    @Test
    public void testParseCreateTableInlinePrimaryKeyWithOrder() throws Exception {
        for (String order : new String[]{"asc", "desc"}) {
            String s = "create table core.entity_history_archive (id char(15) primary key ${o})".replace("${o}", order);
            CreateTableStatement stmt = (CreateTableStatement)new SQLParser((s)).parseStatement();
            List<ColumnDef> columnDefs = stmt.getColumnDefs();
            assertEquals(1, columnDefs.size());
            assertEquals(SortOrder.fromDDLValue(order), columnDefs.iterator().next().getSortOrder());
        }
    }

    @Test
    public void testParseCreateTableOrderWithoutPrimaryKeyFails() throws Exception {
        for (String order : new String[]{"asc", "desc"}) {
            String stmt = "create table core.entity_history_archive (id varchar(20) ${o})".replace("${o}", order);
            try {
                new SQLParser((stmt)).parseStatement();
                fail("Expected parse exception to be thrown");
            } catch (SQLException e) {
                String errorMsg = "ERROR 603 (42P00): Syntax error. Unexpected input. Expecting \"RPAREN\", got \"${o}\"".replace("${o}", order);
                assertTrue("Expected message to contain \"" + errorMsg + "\" but got \"" + e.getMessage() + "\"", e.getMessage().contains(errorMsg));
            }
        }
    }

    @Test
    public void testParseCreateTablePrimaryKeyConstraintWithOrder() throws Exception {
        for (String order : new String[]{"asc", "desc"}) {
            String s = "create table core.entity_history_archive (id CHAR(15), name VARCHAR(150), constraint pk primary key (id ${o}, name ${o}))".replace("${o}", order);
            CreateTableStatement stmt = (CreateTableStatement)new SQLParser((s)).parseStatement();
            PrimaryKeyConstraint pkConstraint = stmt.getPrimaryKeyConstraint();
            List<Pair<ColumnName,SortOrder>> columns = pkConstraint.getColumnNames();
            assertEquals(2, columns.size());
            for (Pair<ColumnName,SortOrder> pair : columns) {
                assertEquals(SortOrder.fromDDLValue(order), pkConstraint.getColumnWithSortOrder(pair.getFirst()).getSecond());
            }
        }
    }

    @Test
    public void testParseCreateTableCommaBeforePrimaryKeyConstraint() throws Exception {
        for (String leadingComma : new String[]{",", ""}) {
            String s = "create table core.entity_history_archive (id CHAR(15), name VARCHAR(150)${o} constraint pk primary key (id))".replace("${o}", leadingComma);

            CreateTableStatement stmt = (CreateTableStatement)new SQLParser((s)).parseStatement();

            assertEquals(2, stmt.getColumnDefs().size());
            assertNotNull(stmt.getPrimaryKeyConstraint());
        }
    }

    @Test
    public void testInvalidTrailingCommaOnCreateTable() throws Exception {
        String sql = (
                (
                        "create table foo (c1 varchar primary key, c2 varchar,)"));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.MISMATCHED_TOKEN.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testCreateSequence() throws Exception {
        String sql = ((
                "create sequence foo.bar\n" +
                        "start with 0\n"    +
                        "increment by 1\n"));
        parseQuery(sql);
    }

    @Test
    public void testNextValueForSelect() throws Exception {
        String sql = ((
                "select next value for foo.bar \n" +
                        "from core.custom_entity_data\n"));
        parseQuery(sql);
    }

    @Test
    public void testNextValueForWhere() throws Exception {
        String sql = ((
                "upsert into core.custom_entity_data\n" +
                        "select next value for foo.bar from core.custom_entity_data\n"));
        parseQuery(sql);
    }

    @Test
    public void testBadCharDef() throws Exception {
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadVarcharDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col CHAR(0))");
            parseQuery(sql);
            fail("Should have caught bad char definition.");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.NONPOSITIVE_MAX_LENGTH.getErrorCode(), e.getErrorCode());
        }
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadVarcharDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col CHAR)");
            parseQuery(sql);
            fail("Should have caught bad char definition.");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.MISSING_MAX_LENGTH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testBadVarcharDef() throws Exception {
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadVarcharDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col VARCHAR(0))");
            parseQuery(sql);
            fail("Should have caught bad varchar definition.");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.NONPOSITIVE_MAX_LENGTH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testBadDecimalDef() throws Exception {
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadDecimalDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col DECIMAL(0, 5))");
            parseQuery(sql);
            fail("Should have caught bad decimal definition.");
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 209 (22003): Decimal precision outside of range. Should be within 1 and 38. columnName=COL"));
        }
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadDecimalDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col DECIMAL(40, 5))");
            parseQuery(sql);
            fail("Should have caught bad decimal definition.");
        } catch (SQLException e) {
            assertTrue(e.getMessage(), e.getMessage().contains("ERROR 209 (22003): Decimal precision outside of range. Should be within 1 and 38. columnName=COL"));
        }
    }

    @Test
    public void testBadBinaryDef() throws Exception {
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadBinaryDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col BINARY(0))");
            parseQuery(sql);
            fail("Should have caught bad binary definition.");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.NONPOSITIVE_MAX_LENGTH.getErrorCode(), e.getErrorCode());
        }
        try {
            String sql = ("CREATE TABLE IF NOT EXISTS testBadVarcharDef" +
                    "  (pk VARCHAR NOT NULL PRIMARY KEY, col BINARY)");
            parseQuery(sql);
            fail("Should have caught bad char definition.");
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.MISSING_MAX_LENGTH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testPercentileQuery1() throws Exception {
        String sql = (
                (
                        "select PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY salary DESC) from core.custom_index_value ind"));
        parseQuery(sql);
    }

    @Test
    public void testPercentileQuery2() throws Exception {
        String sql = (
                (
                        "select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mark ASC) from core.custom_index_value ind"));
        parseQuery(sql);
    }

    @Test
    public void testRowValueConstructorQuery() throws Exception {
        String sql = (
                (
                        "select a_integer FROM aTable where (x_integer, y_integer) > (3, 4)"));
        parseQuery(sql);
    }

    @Test
    public void testSingleTopLevelNot() throws Exception {
        String sql = (
                (
                        "select * from t where not c = 5"));
        parseQuery(sql);
    }

    @Test
    public void testTopLevelNot() throws Exception {
        String sql = (
                (
                        "select * from t where not c"));
        parseQuery(sql);
    }

    @Test
    public void testRVCInList() throws Exception {
        String sql = (
                (
                        "select * from t where k in ( (1,2), (3,4) )"));
        parseQuery(sql);
    }

    @Test
    public void testInList() throws Exception {
        String sql = (
                (
                        "select * from t where k in ( 1,2 )"));
        parseQuery(sql);
    }

    @Test
    public void testInvalidSelectStar() throws Exception {
        String sql = (
                (
                        "select *,k from t where k in ( 1,2 )"));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.MISSING_TOKEN.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testTableNameStartsWithUnderscore() throws Exception {
        String sql = (
                (
                        "select* from _t where k in ( 1,2 )"));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.PARSER_ERROR.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testValidUpsertSelectHint() throws Exception {
        String sql = (
                (
                        "upsert /*+ NO_INDEX */ into t select k from t where k in ( 1,2 )"));
            parseQuery(sql);
    }

    @Test
    public void testHavingWithNot() throws Exception {
        String sql = (
                (
                        "select\n" +
                        "\"WEB_STAT_ALIAS\".\"DOMAIN\" as \"c0\"\n" +
                        "from \"WEB_STAT\" \"WEB_STAT_ALIAS\"\n" +
                        "group by \"WEB_STAT_ALIAS\".\"DOMAIN\" having\n" +
                        "(\n" +
                        "(\n" +
                        "NOT\n" +
                        "(\n" +
                        "(sum(\"WEB_STAT_ALIAS\".\"ACTIVE_VISITOR\") is null)\n" +
                        ")\n" +
                        "OR NOT((sum(\"WEB_STAT_ALIAS\".\"ACTIVE_VISITOR\") is null))\n" +
                        ")\n" +
                        "OR NOT((sum(\"WEB_STAT_ALIAS\".\"ACTIVE_VISITOR\") is null))\n" +
                        ")\n" +
                        "order by CASE WHEN \"WEB_STAT_ALIAS\".\"DOMAIN\" IS NULL THEN 1 ELSE 0 END,\n" +
                        "\"WEB_STAT_ALIAS\".\"DOMAIN\" ASC"));
        parseQuery(sql);
    }

    @Test
    public void testToDateInList() throws Exception {
        String sql = (
                ("select * from date_test where d in (to_date('2013-11-04 09:12:00'))"));
        parseQuery(sql);
    }

    @Test
    public void testDateLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = DATE '2013-11-04 09:12:00'"));
        parseQuery(sql);
    }

    @Test
    public void testTimeLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = TIME '2013-11-04 09:12:00'"));
        parseQuery(sql);
    }


    @Test
    public void testTimestampLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = TIMESTAMP '2013-11-04 09:12:00'"));
        parseQuery(sql);
    }

    @Test
    public void testUnsignedDateLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = UNSIGNED_DATE '2013-11-04 09:12:00'"));
        parseQuery(sql);
    }

    @Test
    public void testUnsignedTimeLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = UNSIGNED_TIME '2013-11-04 09:12:00'"));
        parseQuery(sql);
    }


    @Test
    public void testUnsignedTimestampLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = UNSIGNED_TIMESTAMP '2013-11-04 09:12:00'"));
        parseQuery(sql);
    }

    @Test
    public void testParseDateEquality() throws Exception {
        SQLParser parser = new SQLParser(new StringReader(
            "select a from b\n" +
            "where date '2014-01-04' = date '2014-01-04'"
            ));
        parser.parseStatement();
    }

    @Test
    public void testParseDateIn() throws Exception {
        SQLParser parser = new SQLParser(new StringReader(
            "select a from b\n" +
            "where date '2014-01-04' in (date '2014-01-04')"
            ));
        parser.parseStatement();
    }

    @Test
    public void testUnknownLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = FOO '2013-11-04 09:12:00'"));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.ILLEGAL_DATA.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testUnsupportedLiteral() throws Exception {
        String sql = (
                (
                        "select * from t where d = DECIMAL '2013-11-04 09:12:00'"));
        try {
            parseQuery(sql);
            fail();
        } catch (SQLException e) {
            assertEquals(SQLExceptionCode.TYPE_MISMATCH.getErrorCode(), e.getErrorCode());
        }
    }

    @Test
    public void testAnyElementExpression1() throws Exception {
        String sql = "select * from t where 'a' = ANY(a)";
        parseQuery(sql);
    }

    @Test
    public void testAnyElementExpression2() throws Exception {
        String sql = "select * from t where 'a' <= ANY(a-b+1)";
        parseQuery(sql);
    }

    @Test
    public void testAllElementExpression() throws Exception {
        String sql = "select * from t where 'a' <= ALL(a-b+1)";
        parseQuery(sql);
    }

    @Test
    public void testDoubleBackslash() throws Exception {
        String sql = "SELECT * FROM T WHERE A LIKE 'a\\(d'";
        parseQuery(sql);
    }

    @Test
    public void testUnicodeSpace() throws Exception {
        // U+2002 (8194) is a "EN Space" which looks just like a normal space (0x20 in ascii)
        String unicodeEnSpace = String.valueOf(Character.toChars(8194));
        String sql = Joiner.on(unicodeEnSpace).join(new String[] {"SELECT", "*", "FROM", "T"});
        parseQuery(sql);
    }

    @Test
    public void testInvalidTableOrSchemaName() throws Exception {
        // namespace separator (:) cannot be used
        parseQueryThatShouldFail("create table a:b (id varchar not null primary key)");
        parseQueryThatShouldFail("create table \"a:b\" (id varchar not null primary key)");
        // name separator (.) cannot be used without double quotes
        parseQueryThatShouldFail("create table a.b.c.d (id varchar not null primary key)");
        parseQuery("create table \"a.b\".\"c.d\" (id varchar not null primary key)");
        parseQuery("create table \"a.b.c.d\" (id varchar not null primary key)");
    }
}



