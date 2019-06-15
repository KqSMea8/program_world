
Hadoop 和 RDBMS 间数据相互传输
import ：导入数据（hdfs、hive、hbase）
export：导出数据
sqoop-list-databases ：查看数据库中的用户
sqoop-list-tables：查看数据库中的表
sqoop-eval：执行简单的sql


sqoop export -D sqoop.export.statements.per.transaction=3000 -D  //提交数量 mapred.job.queue.name=${queueName} \
--connect ${oracle_connection} \
--username ${oracle_username} \
--password ${oracle_password} \
--export-dir “/apps-data/hduser0101/sx_mis_life_safe/export/${dataName}_SUB_REDEV_EMP_INFO_RESULT” \  //临时目录
--verbose \  //打印命令运行时的详细信息
--table lolapdata.SUB_REDEV_EMP_INFO_RESULT \
--columns CONFIG_CALC_DATE,CONFIG_CALC_MONTH_DATE,EMPNO,EMP_NAME,DEPTNO,DEPT_NAME,LEAVE_DATE,REGION_CODE,DESCRIPTION,REGION_CODE_2,DESCRIPTION_2,CLIENTNO,CLIENT_NAME,REDEV_TYPE,MIN_UNDWRT_DATE,PREMIUM,REGION_SID \
--input-fields-terminated-by '\001'  \
--input-lines-terminated-by '\n'  \
--input-null-string '\\N'  \
--input-null-non-string '\\N';


sqoop.export.statements.per.transaction=3000  每次传输多少条记录
--verbose  打印执行详细日志
--table oracle表名
--columns 导入的字段名
--input-fields-terminated-by ‘\001’  hive的分隔符
--input-lines-terminated-by ‘\n’  hive的换行符
--input-null-string ‘\\N’  空值字符处理
--input-null-non-string ‘\\N’空值字符处理




sqoop import -D mapred.job.queue.name=${queueName}   -D mapred.job.name=${job_name} \
--connect ${postgre_connection}                                   \
--username ${postgre_username}                                    \
--password ${postgre_password}                                    \
--query "SELECT   POLNO    BRNO    sysdate  ORA_SYN_DATE       \
  from ${org_table} where 1=1 AND \$CONDITIONS" \
-m 1                                                        \
--hive-table ${hive_db}.${hive_table}           //hive表名称
--hive-drop-import-delims                  //删除字段中的 \n, \r, \01 等特殊字符
--fetch-size 5000                                  //每次获取5000条记录
--target-dir “${target_dir}”                //HDFS 目录位置
--hive-partition-key region_sid             //分区字段名
--hive-partition-value ${dataName}      //分区字段的值
--hive-overwrite                                     //如果hive表中有数据，全部删除后增加
--null-string ‘\\N’                               //空字符串处理
--null-non-string '\\N'                            //空字符串处理
--hive-import;                                         //导入Hive表中




