#!/bin/bash

SPARK_HOME='/opt/module/cdh-5.3.6-ha/spark-1.6.1-bin-2.5.0-cdh5.3.6'
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'

# $HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark/spark_log

if [ ! -d "$SPARK_HOME" ]; then
  echo "SPARK_HOME is not exist"
   exit 1
fi


# make log directory
if [ "$SPARK_LOG_DIR" = "" ]; then
  export SPARK_LOG_DIR="$SPARK_HOME/logs"
fi
mkdir -p "$SPARK_LOG_DIR"


ssh xiaoyuzhou@xyz02.aiso.com rm -rf $SPARK_HOME/conf && scp -r $SPARK_HOME/conf xiaoyuzhou@xyz02.aiso.com:$SPARK_HOME/

ssh xiaoyuzhou@xyz03.aiso.com rm -rf $SPARK_HOME/conf && scp -r $SPARK_HOME/conf xiaoyuzhou@xyz03.aiso.com:$SPARK_HOME/


################################################
# spark-env.sh:
# JAVA_HOME=/opt/module/jdk1.7.0_67
# SCALA_HOME=/opt/module/scala-2.11.8/
# HADOOP_CONF_DIR=/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/etc/hadoop


#######################yarn########################
# spark-defaults.conf:
# spark.master聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽  yarn


 echo "successful!"#!/bin/bash
SPARK_HOME='/opt/module/cdh-5.3.6-ha/spark-1.6.1-bin-2.5.0-cdh5.3.6'

# $SPARK_HOME/sbin/start-history-server.sh hdfs://xyz01:8020/directory

# spark.history.fs.logDirectory
# hdfs://xyz01:8020/directory可以配置在配置文件中，那么在启动history-server时就不需要指定

$SPARK_HOME/sbin/start-master.sh && $SPARK_HOME/sbin/start-slaves.sh && $SPARK_HOME/sbin/start-history-server.sh


# 注意：
		# 使用此命令时，运行此命令的机器，必须要配置与其他机器的SSH无密钥登录，否则启动的时候会出现一些问题，比如说输入密码之类的。
# 启动所有的从节点，也就是Work


#!/bin/bash
SPARK_HOME='/opt/module/cdh-5.3.6-ha/spark-1.6.1-bin-2.5.0-cdh5.3.6'

$SPARK_HOME/sbin/stop-master.sh && $SPARK_HOME/sbin/stop-slaves.sh && $SPARK_HOME/sbin/stop-history-server.sh

