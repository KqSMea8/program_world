#!/usr/bin/bash
HADOOP_HOME="/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6"
HIVE_HOME='/opt/module/cdh-5.3.6-ha/hive-0.13.1-cdh5.3.6'
SQOOP_HOME='/opt/module/cdh-5.3.6-ha/sqoop-1.4.5-cdh5.3.6'
MYSQL_HOME='/opt/module/mysql-5.6'


# Sqoopѡձ°汾sqoop-1.4.5-cdh5.3.6£¬°²װ²½רɧЂ£º
# Ђ՘£ºwget http://archive.cloudera.com/cdh5/cdh/5/sqoop-1.4.5-cdh5.3.6.tar.gz

# sqoop-env.sh
# #Set path to where bin/hadoop is available
# export HADOOP_COMMON_HOME=/opt/module/hadoop-2.5.0-cdh5.3.6

# #Set path to where hadoop-*-core.jar is available
# export HADOOP_MAPRED_HOME=/opt/module/hadoop-2.5.0-cdh5.3.6

# #Set the path to where bin/hive is available
# export HIVE_HOME=/opt/module/hive-0.13.1-cdh5.3.6

# #Set the path for where zookeper config dir is
# export ZOOCFGDIR=/opt/module/zookeeper-3.4.5-cdh5.3.6/conf


#¿½±´Ƚ¶¯°
#mysql
 if [ ! -f "$SQOOP_HOME/lib/mysql-connector-java-5.1.27-bin.jar" ]; then
	cp $MYSQL_HOME/mysql-connector-java-5.1.27/mysql-connector-java-5.1.27-bin.jar  $SQOOP_HOME/lib/
 fi

# export SQOOP_HOME=$SQOOP_HOME
# export PATH=$PATH:$SQOOP_HOME/bin


sudo yum install -y  mysqldump;

