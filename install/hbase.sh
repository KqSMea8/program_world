#!/bin/bash
HBase_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'


#下载
# http://archive.cloudera.com/cdh5/cdh/5/

if [ ! -d "$HBase_HOME/data/pids" ]; then
  mkdir -p $HBase_HOME/data/pids
fi

if [ ! -d "$HBase_HOME/data/tmp" ]; then
  mkdir -p $HBase_HOME/data/tmp
fi


# 2.1.2.5.  ulimit 和 nproc
#  HBase是数据库，会在同一时间使用很多的文件句柄。大多数linux系统使用的默认值1024是不能满足的，会导致FAQ: Why do I see "java.io.IOException...(Too many open files)" in my logs?异常。还可能会发生这样的异常

      # 2010-04-06 03:04:37,542 INFO org.apache.hadoop.hdfs.DFSClient: Exception increateBlockOutputStream java.io.EOFException
      # 2010-04-06 03:04:37,542 INFO org.apache.hadoop.hdfs.DFSClient: Abandoning block blk_-6935524980745310745_1391901

# 所以你需要修改你的最大文件句柄限制。可以设置到10k。大致的数学运算如下：每列族至少有1个存储文件(StoreFile) 可能达到5-6个如果区域有压力。将每列族的存储文件平均数目和每区域服务器的平均区域数目相乘。例如：假设一个模式有3个列族，每个列族有3个存储文件，每个区域服务器有100个区域，JVM 将打开3 * 3 * 100 = 900 个文件描述符(不包含打开的jar文件，配置文件等)

# 你还需要修改 hbase 用户的 nproc，在压力下，如果过低会造成 OutOfMemoryError异常[3] [4]。

# 需要澄清的，这两个设置是针对操作系统的，不是HBase本身的。有一个常见的错误是HBase运行的用户，和设置最大值的用户不是一个用户。在HBase启动的时候，第一行日志会现在ulimit信息，确保其正确。[5]

# 如果你使用的是Ubuntu,你可以这样设置:

# 在文件 /etc/security/limits.conf 添加一行，如:

# hadoop  -       nofile  32768
# 可以把 hadoop 替换成你运行HBase和Hadoop的用户。如果你用两个用户，你就需要配两个。还有配nproc hard 和 soft limits. 如:

# hadoop soft/hard nproc 32000
# .

# 在 /etc/pam.d/common-session 加上这一行:

# session required  pam_limits.so
# 否则在 /etc/security/limits.conf上的配置不会生效.

# 还有注销再登录，这些配置才能生效!



# hbase-env.sh:

# 其他包括pid存储路径指定和给定指定参数决定是否使用集成zk(默认使用)。
# export JAVA_HOME=/opt/modules/jdk1.7.0_67
# export HBASE_CLASSPATH=/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/etc/hadoop
# #先创建data/pids
# export HBASE_PID_DIR=/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6/data/pids
# export HBASE_MANAGES_ZK=false
# #搭建HA的时候启用
# export HBASE_BACKUP_MASTERS=/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6/conf/backup-masters



# hbase-site.xml：

# 单机模式

 # <property>
    # <name>hbase.rootdir</name>
    # <value>file:///home/testuser/hbase</value>
  # </property>
  # <property>
    # <name>hbase.zookeeper.property.dataDir</name>
    # <value>/home/testuser/zookeeper</value>
  # </property>

# 伪分布模式

# master	一台服务器
# regionserver	多台服务器（datanode）
# zookeeper   集群（2n+1）
# http://xyz01.aiso.com:60010
# 主要指定hbase相关资源配置信息和hdfs相关客户端信息。
  # <property>
    # <name>hbase.rootdir</name>
    # <value>hdfs://xyz01.aiso.com:8020/hbase</value>
  # </property>
  # <property>
    # <name>hbase.cluster.distributed</name>
    # <value>true</value>
  # </property>
  # <property>
	# <name>hbase.tmp.dir</name>
	# <value>/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6/data/tmp</value>
  # </property>
  # <property>
    # <name>hbase.zookeeper.quorum</name>
    # <value>xyz01.aiso.com</value>
  # </property>

 # ****************************
# 分布式模式：
# <property>
    # <name>hbase.rootdir</name>
    # <value>hdfs://xyz01.aiso.com:8020/hbase</value>
  # </property>
  # <property>
    # <name>hbase.cluster.distributed</name>
    # <value>true</value>
  # </property>
  # <property>
	# <name>hbase.tmp.dir</name>
	# <value>/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6/data/tmp</value>
  # </property>
  # <property>
    # <name>hbase.zookeeper.quorum</name> 	<value>xyz01.aiso.com,xyz02.aiso.com,xyz03.aiso.com</value>
  # </property>


# regionservers:
	# xyz01.aiso.com
	# xyz02.aiso.com
	# xyz03.aiso.com

# backup-masters:
  # 如果需要使用hbase的多master结构，那么需要在conf文件夹下添加backup-masters文件，然后一行一个主机名，和regionservers是一样的；或者在hbase-env.sh中添加变量HBASE_BACKUP_MASTERS，对应value为backup-masters存储路径(启动命令一样)。

# conf/backup-masters:
# xyz02.aiso.com

# 替换lib目录关于hadoop和zookeeper的jar 包
 # cd lib/
# rm -rf hadoop-*
# rm -rf zookeeper-3.4.6.jar

 # 上传提供的jar包


 # 2.1.3.5. dfs.datanode.max.xcievers
# 一个 Hadoop HDFS Datanode 有一个同时处理文件的上限. 这个参数叫 xcievers (Hadoop的作者把这个单词拼错了). 在你加载之前，先确认下你有没有配置这个文件conf/hdfs-site.xml里面的xceivers参数，至少要有4096:

      # <property>
        # <name>dfs.datanode.max.xcievers</name>
        # <value>4096</value>
      # </property>

# 对于HDFS修改配置要记得重启.

# 如果没有这一项配置，你可能会遇到奇怪的失败。你会在Datanode的日志中看到xcievers exceeded，但是运行起来会报 missing blocks错误。例如: 10/12/08 20:10:31 INFO hdfs.DFSClient: Could not obtain block blk_XXXXXXXXXXXXXXXXXXXXXX_YYYYYYYY from any node: java.io.IOException: No live nodes contain current block. Will get new block locations from namenode and retry... [5]



 ##doc
 ## http://abloz.com/hbase/book.html














#!/bin/bash
HBase_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'




##启动hadoop
# sbin/hadoop-daemon.sh start namenode
# sbin/hadoop-daemon.sh start datanode

##启动zookeeper
# bin/zkServer.sh start
# bin/zkServer.sh status

# bin/zkServer.sh stop && bin/zkServer.sh start
# bin/zkServer.sh status


cd $HBase_HOME

##启动Hbase
bin/start-hbase.sh


# bin/hbase-daemon.sh {start/stop/restart} {regionserver/master}

# bin/hbase-daemon.sh --hosts regionserversfile {start/stop/restart}




# hbase-daemon.sh (start|stop) (master|regionserver|zookeeper)
# hbase-daemons.sh (start|stop) (regionserver|zookeeper)

# bin/hbase-daemon.sh start master
# bin/hbase-daemon.sh start regionserver
# bin/hbase-daemons.sh start master-backup



# sudo netstat -anp | grep 60010
# ps -ef | grep -i master
# ps -ef | grep -i hbase



##webUI http://xyz01.aiso.com:60010
# 验证
# 验证分为三种方式：
# 1. jsp查看是否有hbase的正常启动。
# 2. web界面查看是否启动成功。
# http://xyz01.aiso.com:60010
# 3. shell命令客户端查看是否启动成功。
# 4. 查看hbase是否安装成功，查看hdfs文件下是否有hbase的文件夹。
# jps:HMaster HRegionServer
# http://xyz01.aiso.com:60010/master-status







#!/bin/bash
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'
ZOOK_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'
HBase_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'



##停止hadoop
#sh $HADOOP_HOME/shell/stop.sh


##停止zookeeper
#$ZOOK_HOME/bin/zkServer.sh stop





cd $HBase_HOME
bin/stop-hbase.sh

ssh xiaoyuzhou@xyz01.aiso.com rm -rf $HBase_HOME/data/pids

ssh xiaoyuzhou@xyz02.aiso.com rm -rf $HBase_HOME/data/pids

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $HBase_HOME/data/pids

#!/bin/bash

HBASE_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'

if [ ! -d "$HBASE_HOME" ]; then
  echo "HBASE_HOME is not exist"
   exit 1
fi

ssh xiaoyuzhou@xyz02.aiso.com rm -rf $HBASE_HOME/conf  &&  scp -r $HBASE_HOME/conf xiaoyuzhou@xyz02.aiso.com:$HBASE_HOME/

 if [[ $? -ne 0 ]]
		then exit
 fi

 ssh xiaoyuzhou@xyz02.aiso.com rm -rf $HBASE_HOME/lib  &&  scp -r $HBASE_HOME/lib xiaoyuzhou@xyz02.aiso.com:$HBASE_HOME/


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $HBASE_HOME/conf  &&  scp -r $HBASE_HOME/conf xiaoyuzhou@xyz03.aiso.com:$HBASE_HOME/

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $HBASE_HOME/lib  &&  scp -r $HBASE_HOME/lib xiaoyuzhou@xyz03.aiso.com:$HBASE_HOME/


echo "successful!"


























=============


#开启集群，
start-hbase.sh
#关闭集群，stop-hbase.sh
#开启/关闭所有的regionserver、zookeeper，hbase-daemons.sh start/stop regionserver/zookeeper
#开启/关闭单个regionserver、zookeeper，hbase-daemon.sh start/stop regionserver/zookeeper
#开启/关闭master hbase-daemon.sh start/stop master, 是否成为active master取决于当前是否有active master
#rolling-restart.sh 可以用来挨个滚动重启
服务器上的所有region后，再stop/restart该服务器，可以用来进行版本的热升级

#graceful_stop.sh move

$HBASE_HOME/bin/start-hbase.sh

$HBASE_HOME/bin/stop-hbase.sh

$HBASE_HOME/bin/hbase-daemons.sh
#启动或停止，所有的regionserver或zookeeper或backup-master

$HBASE_HOME/bin/hbase-daemon.sh
#启动或停止，单个master或regionserver或zookeeper
以start-hbase.sh为起点，可以看看脚本间的一些调用关系
start-hbase.sh的流程如下：
运行hbase-config.sh（作用后面解释）
解析参数（版本及以后才可以带唯一参数autorestart，作用就是重启）
调用hbase-daemon.sh来启动master；
调用hbase-daemons.sh来启动regionserver zookeeper master-backup
hbase-config.sh
装载相关配置，如HBASE_HOME目录，conf目录，regionserver机器列表，JAVA_HOME目录等，它会调用$HBASE_HOME/conf/hbase-env.sh
hbase-env.sh的作用：
#主要是配置JVM及其GC参数，还可以配置log目录及参数，配置是否需要hbase管理ZK，配置进程id目录等
hbase-daemons.sh的作用：
根据需要启动的进程，
如为zookeeper,则调用zookeepers.sh
如为regionserver，则调用regionservers.sh
如为master-backup，则调用master-backup.sh

zookeepers.sh的作用：
如果hbase-env.sh中的HBASE_MANAGES_ZK" = "true"，那么通过ZKServerTool这个类解析xml配置文件，获取ZK节点列表（即hbase.zookeeper.quorum的配置值），然后通过SSH向这些节点发送远程命令：
cd ${HBASE_HOME};
$bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop zookeeper


regionservers.sh的作用：
与zookeepers.sh类似，通过${HBASE_CONF_DIR}/regionservers配置文件，获取regionserver机器列表，然后SSH向这些机器发送远程命令：
cd ${HBASE_HOME};
$bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop regionserver

master-backup.sh的作用：
通过${HBASE_CONF_DIR}/backup-masters这个配置文件，获取backup-masters机器列表（默认配置中，这个配置文件并不存在，所以不会启动backup-master）,然后SSH向这些机器发送远程命令：
cd ${HBASE_HOME};
$bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop master --backup

hbase-daemon.sh的作用：
无论是zookeepers.sh还是regionservers.sh或是master-backup.sh，最终都会调用本地的hbase-daemon.sh，其执行过程如下：
运行hbase-config.sh，装载各种配置（java环境、log配置、进程ID目录等）
如果是start命令？
滚动out输出文件，滚动gc日志文件，日志文件中输出启动时间+ulimit -a信息，如
“Mon Nov  :: CST  Starting master on dwxx.yy.taobao”
"..open files                      (-n) ."
调用$HBASE_HOME/bin/hbase start master/regionserver/zookeeper
执行wait，等待开启的进程结束
执行cleanZNode，将regionserver在zk上登记的节点删除，这样做的目的是：在regionserver进程意外退出的情况下，可以免去钟的ZK心跳超时等待，直接由master进行宕机恢复
如果是stop命令？
根据进程ID，检查进程是否存在；调用kill命令，然后等待到进程不存在为止
如果是restart命令？
调用stop后，再调用start。。。


# 1.$HBASE_HOME/bin/start-hbase.sh

# 2.$HBASE_HOME/bin/stop-hbase.sh

# 3.$HBASE_HOME/bin/hbase-daemons.sh
# 启动或停止，所有的regionserver或zookeeper或backup-master

# 4.$HBASE_HOME/bin/hbase-daemon.sh
# 启动或停止，单个master或regionserver或zookeeper

# 以start-hbase.sh为起点，可以看看脚本间的一些调用关系
# start-hbase.sh的流程如下：
# 1.运行hbase-config.sh（作用后面解释）
# 2.解析参数（0.96版本及以后才可以带唯一参数autorestart，作用就是重启）
# 3.调用hbase-daemon.sh来启动master；调用hbase-daemons.sh来启动regionserver zookeeper master-backup

# hbase-config.sh的作用：
# 装载相关配置，如HBASE_HOME目录，conf目录，regionserver机器列表，JAVA_HOME目录等，它会调用$HBASE_HOME/conf/hbase-env.sh

# hbase-env.sh的作用：
# 主要是配置JVM及其GC参数，还可以配置log目录及参数，配置是否需要hbase管理ZK，配置进程id目录等

# hbase-daemons.sh的作用：
# 根据需要启动的进程，
# 如为zookeeper,则调用zookeepers.sh
# 如为regionserver，则调用regionservers.sh
# 如为master-backup，则调用master-backup.sh

# zookeepers.sh的作用：
# 如果hbase-env.sh中的HBASE_MANAGES_ZK" = "true"，那么通过ZKServerTool这个类解析xml配置文件，获取ZK节点列表（即hbase.zookeeper.quorum的配置值），然后通过SSH向这些节点发送远程命令：
# cd ${HBASE_HOME};
# $bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop zookeeper

# regionservers.sh的作用：
# 与zookeepers.sh类似，通过${HBASE_CONF_DIR}/regionservers配置文件，获取regionserver机器列表，然后SSH向这些机器发送远程命令：
# cd ${HBASE_HOME};
# $bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop regionserver

# master-backup.sh的作用：
# 通过${HBASE_CONF_DIR}/backup-masters这个配置文件，获取backup-masters机器列表（默认配置中，这个配置文件并不存在，所以不会启动backup-master）,然后SSH向这些机器发送远程命令：
# cd ${HBASE_HOME};
# $bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop master --backup

# hbase-daemon.sh的作用：
# 无论是zookeepers.sh还是regionservers.sh或是master-backup.sh，最终都会调用本地的hbase-daemon.sh，其执行过程如下：
# 1.运行hbase-config.sh，装载各种配置（java环境、log配置、进程ID目录等）
# 2.如果是start命令？
# 滚动out输出文件，滚动gc日志文件，日志文件中输出启动时间+ulimit -a信息，如
# “Mon Nov 26 10:31:42 CST 2012 Starting master on dwxx.yy.taobao”
# "..open files                      (-n) 65536.."
# 3.调用$HBASE_HOME/bin/hbase start master/regionserver/zookeeper
# 4.执行wait，等待3中开启的进程结束
# 5.执行cleanZNode，将regionserver在zk上登记的节点删除，这样做的目的是：在regionserver进程意外退出的情况下，可以免去3分钟的ZK心跳超时等待，直接由master进行宕机恢复
# 6.如果是stop命令？
# 根据进程ID，检查进程是否存在；调用kill命令，然后等待到进程不存在为止
# 7.如果是restart命令？
# 调用stop后，再调用start。。。

回归到刚才hbase-daemon.sh对此脚本的调用为：
$HBASE_HOME/bin/hbase start master/regionserver/zookeeper
其执行则直接调用
org.apache.hadoop.hbase.master.HMaster
org.apache.hadoop.hbase.regionserver.HRegionServer
org.apache.hadoop.hbase.zookeeper.HQuorumPeer
的main函数，而这些main函数就是了new一个了Runnable的HMaster/HRegionServer/QuorumPeer，在不停的Running...


 hbase-daemon.sh start master 与 hbase-daemon.sh start master --backup，这命令的作用一样的，是否成为backup或active是由master的内部逻辑来控制的


stop-hbase.sh 不会调用hbase-daemons.sh stop regionserver 来关闭regionserver， 但是会调用hbase-daemons.sh stop zookeeper/master-backup来关闭zk和backup master，关闭regionserver实际调用的是hbaseAdmin的shutdown接口


#!/usr/bin/env bash
1.$HBASE_HOME/bin/start-hbase.sh

2.$HBASE_HOME/bin/stop-hbase.sh

3.$HBASE_HOME/bin/hbase-daemons.sh
启动或停止，所有的regionserver或zookeeper或backup-master

4.$HBASE_HOME/bin/hbase-daemon.sh
启动或停止，单个master或regionserver或zookeeper

以start-hbase.sh为起点，可以看看脚本间的一些调用关系
start-hbase.sh的流程如下：
1.运行hbase-config.sh（作用后面解释）
2.解析参数（0.96版本及以后才可以带唯一参数autorestart，作用就是重启）
3.调用hbase-daemon.sh来启动master；调用hbase-daemons.sh来启动regionserver zookeeper master-backup

hbase-config.sh的作用：
装载相关配置，如HBASE_HOME目录，conf目录，regionserver机器列表，JAVA_HOME目录等，它会调用$HBASE_HOME/conf/hbase-env.sh

hbase-env.sh的作用：
主要是配置JVM及其GC参数，还可以配置log目录及参数，配置是否需要hbase管理ZK，配置进程id目录等

hbase-daemons.sh的作用：
根据需要启动的进程，
如为zookeeper,则调用zookeepers.sh
如为regionserver，则调用regionservers.sh
如为master-backup，则调用master-backup.sh

zookeepers.sh的作用：
如果hbase-env.sh中的HBASE_MANAGES_ZK" = "true"，那么通过ZKServerTool这个类解析xml配置文件，获取ZK节点列表（即hbase.zookeeper.quorum的配置值），然后通过SSH向这些节点发送远程命令：
cd ${HBASE_HOME};
$bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop zookeeper

regionservers.sh的作用：
与zookeepers.sh类似，通过${HBASE_CONF_DIR}/regionservers配置文件，获取regionserver机器列表，然后SSH向这些机器发送远程命令：
cd ${HBASE_HOME};
$bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop regionserver

master-backup.sh的作用：
通过${HBASE_CONF_DIR}/backup-masters这个配置文件，获取backup-masters机器列表（默认配置中，这个配置文件并不存在，所以不会启动backup-master）,然后SSH向这些机器发送远程命令：
cd ${HBASE_HOME};
$bin/hbase-daemon.sh --config ${HBASE_CONF_DIR} start/stop master --backup

hbase-daemon.sh的作用：
无论是zookeepers.sh还是regionservers.sh或是master-backup.sh，最终都会调用本地的hbase-daemon.sh，其执行过程如下：
1.运行hbase-config.sh，装载各种配置（java环境、log配置、进程ID目录等）

2.如果是start命令？
滚动out输出文件，滚动gc日志文件，日志文件中输出启动时间+ulimit -a信息，如
“Mon Nov 26 10:31:42 CST 2012 Starting master on dwxx.yy.taobao”
"..open files                      (-n) 65536.."

3.调用$HBASE_HOME/bin/hbase start master/regionserver/zookeeper

4.执行wait，等待3中开启的进程结束

5.执行cleanZNode，将regionserver在zk上登记的节点删除，这样做的目的是：在regionserver进程意外退出的情况下，可以免去3分钟的ZK心跳超时等待，直接由master进行宕机恢复

6.如果是stop命令？
根据进程ID，检查进程是否存在；调用kill命令，然后等待到进程不存在为止

7.如果是restart命令？
调用stop后，再调用start。。。

$HBASE_HOME/bin/hbase的作用：
1.可以通过敲入$HBASE_HOME/bin/hbase查看其usage
DBA TOOLS
  shell            run the HBase shell
  hbck             run the hbase 'fsck' tool
  hlog             write-ahead-log analyzer
  hfile            store file analyzer
  zkcli            run the ZooKeeper shell
PROCESS MANAGEMENT
  master           run an HBase HMaster node
  regionserver     run an HBase HRegionServer node
  zookeeper        run a Zookeeper server
  rest             run an HBase REST server
  thrift           run the HBase Thrift server
  thrift2          run the HBase Thrift2 server
  avro             run an HBase Avro server

PACKAGE MANAGEMENT
  classpath        dump hbase CLASSPATH
  version          print the version
or
  CLASSNAME        run the class named CLASSNAME

2.bin/hbase shell,这个就是常用的shell工具，运维常用的DDL和DML都会通过此进行，其具体实现（对hbase的调用）是用ruby写的

3.bin/hbase hbck, 运维常用工具，检查集群的数据一致性状态，其执行是直接调用
org.apache.hadoop.hbase.util.HBaseFsck中的main函数

4.bin/hbase hlog, log分析工具，其执行是直接调用
org.apache.hadoop.hbase.regionserver.wal.HLogPrettyPrinter中的main函数

5.bin/hbase hfile， hfile分析工具，其执行是直接调用
org.apache.hadoop.hbase.io.hfile.HFile中的main函数

6.bin/hbase zkcli,查看/管理ZK的shell工具，很实用，经常用，比如你可以通过（get /hbase-tianwu-94/master）其得知当前的active master,可以通过（get /hbase-tianwu-94/root-region-server）得知当前root region所在的server，你也可以在测试中通过（delete /hbase-tianwu-94/rs/dwxx.yy.taobao），模拟regionserver与ZK断开连接，，，
其执行则是调用了org.apache.zookeeper.ZooKeeperMain的main函数

7.回归到刚才hbase-daemon.sh对此脚本的调用为：
$HBASE_HOME/bin/hbase start master/regionserver/zookeeper
其执行则直接调用
org.apache.hadoop.hbase.master.HMaster
org.apache.hadoop.hbase.regionserver.HRegionServer
org.apache.hadoop.hbase.zookeeper.HQuorumPeer
的main函数，而这些main函数就是了new一个了Runnable的HMaster/HRegionServer/QuorumPeer，在不停的Running...

8.bin/hbase classpath 打印classpath

9.bin/hbase version 打印hbase版本信息

10.bin/hbase CLASSNAME， 这个很实用，所有实现了main函数的类都可以通过这个脚本来运行，比如前面的hlog hfile hbck工具，实质是对这个接口的一个快捷调用，而其他未提供快捷方式的class我们也可以用这个接口调用，如Region merge 调用：
$HBASE_HOME/bin/hbase/org.apache.hadoop.hbase.util.Merge


===============

#!/bin/bash
HBase_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'

cd $HBase_HOME


# You can pass commands to the HBase Shell in non-interactive mode (see ???) using the echo command and the | (pipe) operator. Be sure to escape characters in the HBase commands which would otherwise be interpreted by the shell. Some debug-level output has been truncated from the example below.

$ echo "describe 'test1'" | ./hbase shell -n

# Version 0.98.3-hadoop2, rd5e65a9144e315bb0a964e7730871af32f5018d5, Sat May 31 19:56:09 PDT 2014

describe 'test1'

# DESCRIPTION                                          ENABLED
 # 'test1', {NAME => 'cf', DATA_BLOCK_ENCODING => 'NON true
 # E', BLOOMFILTER => 'ROW', REPLICATION_SCOPE => '0',
  # VERSIONS => '1', COMPRESSION => 'NONE', MIN_VERSIO
 # NS => '0', TTL => 'FOREVER', KEEP_DELETED_CELLS =>
 # 'false', BLOCKSIZE => '65536', IN_MEMORY => 'false'
 # , BLOCKCACHE => 'true'}
# 1 row(s) in 3.2410 seconds


# To suppress all output, echo it to /dev/null:

$ echo "describe 'test'" | ./hbase shell -n > /dev/null 2>&1



# #!/bin/bash

# echo "describe 'test'" | ./hbase shell -n > /dev/null 2>&1
# status=$?
# echo "The status was " $status
# if ($status == 0); then
    # echo "The command succeeded"
# else
    # echo "The command may have failed."
# fi
# return $status













