#!/bin/bash

ZOOKP_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'

if [ ! -d "$ZOOKP_HOME" ]; then
  echo "ZOOKP_HOME is not exist"
   exit 1
fi

ssh xiaoyuzhou@xyz02.aiso.com rm -rf $ZOOKP_HOME/conf  &&  scp -r $ZOOKP_HOME/conf xiaoyuzhou@xyz02.aiso.com:$ZOOKP_HOME/

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $ZOOKP_HOME/conf  &&  scp -r $ZOOKP_HOME/conf xiaoyuzhou@xyz03.aiso.com:$ZOOKP_HOME/


ssh xiaoyuzhou@xyz02.aiso.com rm -rf $ZOOKP_HOME/bin  &&  scp -r $ZOOKP_HOME/bin xiaoyuzhou@xyz02.aiso.com:$ZOOKP_HOME/

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $ZOOKP_HOME/bin  &&  scp -r $ZOOKP_HOME/bin xiaoyuzhou@xyz03.aiso.com:$ZOOKP_HOME/


echo "successful!"#!/bin/bash

ZOOKP_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'


# cd $ZOOKP_HOME

# # 单机启动
# bin/zkServer.sh start

# bin/zkServer.sh status


# 集群启动
# if [ $# -ne 1 ];then
        # echo "Usage:give me a parameter [start|stop|status]"
        # exit 2
# fi

# for slave in xyz01.aiso.com xyz02.aiso.com xyz03.aiso.com
# do
        # # ssh $slave "source /etc/profile && $ZOOKP_HOME/bin/zkServer.sh $1"
        # ssh $slave "$ZOOKP_HOME/bin/zkServer.sh start"
        # ssh $slave "$ZOOKP_HOME/bin/zkServer.sh status"
# done
# sh start-zookeeper.sh start

##第一次执行
# if [ $ZOOKP_HOME != ""  ]; then
    # confFile=$ZOOKP_HOME/conf/zoo.cfg
    # slaves=$(cat "$confFile" | sed '/^server/!d;s/^.*=//;s/:.*$//g;/^$/d')
    # for salve in $slaves ;
	# do
		# echo $salve
        # ssh $salve " echo 'source /etc/profile' >> ~/.bashrc && $ZOOKP_HOME/bin/zkServer.sh start"
        # ssh $salve "$ZOOKP_HOME/bin/zkServer.sh status"
    # done
# fi

##第二次以后
if [ $ZOOKP_HOME != ""  ]; then
    confFile=$ZOOKP_HOME/conf/zoo.cfg
    slaves=$(cat "$confFile" | sed '/^server/!d;s/^.*=//;s/:.*$//g;/^$/d')
    for salve in $slaves ;
	do
		echo $salve
        ssh $salve "$ZOOKP_HOME/bin/zkServer.sh start;$ZOOKP_HOME/bin/zkServer.sh status"
    done
fi
$ZOOKP_HOME/bin/zkServer.sh start;$ZOOKP_HOME/bin/zkServer.sh status
#!/bin/bash

ZOOKP_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'


#单机停止
# cd $ZOOKP_HOME

# bin/zkServer.sh stop

# bin/zkServer.sh status



# 集群停止
if [ $ZOOKP_HOME != ""  ]; then
    confFile=$ZOOKP_HOME/conf/zoo.cfg
    slaves=$(cat "$confFile" | sed '/^server/!d;s/^.*=//;s/:.*$//g;/^$/d')
    for salve in $slaves ;
	do
		echo $salve
        ssh $salve "$ZOOKP_HOME/bin/zkServer.sh stop;$ZOOKP_HOME/bin/zkServer.sh status"
    done
fi#!/bin/bash

ZOOKP_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'


# scp $ZOOKP_HOME

ssh xyz01.aiso.com echo "1" > $ZOOKP_HOME/data/myid
ssh xyz02.aiso.com echo "2" > $ZOOKP_HOME/data/myid
ssh xyz03.aiso.com echo "3" > $ZOOKP_HOME/data/myid


# $ZOOKP_HOME/conf/zoo.cfg
# # The number of milliseconds of each tick
# tickTime=2000

# # The number of ticks that the initial
# # synchronization phase can take
# initLimit=10

# # The number of ticks that can pass between
# # sending a request and getting an acknowledgement
# syncLimit=5

# # the directory where the snapshot is stored.
# # do not use /tmp for storage, /tmp here is just
# # example sakes.
# dataDir=/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6/data

# # the port at which the clients will connect
# clientPort=2181


sudo chown -R xiaoyuzhou:xiaoyuzhou $ZOOKP_HOME/*

============

#!/bin/bash

bin/zkCli.sh
bin/zkCli.sh -server master:2181
bin/zkCli.sh -server localhost:2181


ZooKeeper -server host:port cmd args
	connect host:port
	get path [watch]
	ls path [watch]
	set path data [version]
	rmr path
	delquota [-n|-b] path
	quit
	printwatches on|off
	create [-s] [-e] path data acl
	stat path [watch]
	close
	ls2 path [watch]
	history
	listquota path
	setAcl path acl
	getAcl path
	sync path
	redo cmdno
	addauth scheme auth
	delete path [version]
	setquota -n|-b val path

	 create /test hellozookeeper 创建一个节点

	 hellozookeeper
cZxid = 0x2
ctime = Mon May 30 00:12:43 CST 2016
mZxid = 0x2
mtime = Mon May 30 00:12:43 CST 2016
pZxid = 0x2
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 14
numChildren = 0


create /aa 'aavalue'
create -s -e /tmp "tem"

create /test “test-data”

ls /

get /test

zookeeper上的一个节点，类似于一个文件，有数据，类似于一个目录

quit 退出Zookeeper交互式窗口


目录是可以存放数据的
修改配置信息的一瞬间 重新获取这个数据

-s 序列化

默认持久化目录
-e 临时目录
-s 序列化 目录

序列化尾数 不断的向上增加
Leader选举 挂掉了
选举规则：尾数最大 最小的
get /aa 获取明细 值
set /aa “newValue” 添加值




连接指定的ZooKeeper服务器：

#zkCli.sh –server  Server IP:port
1
(注：Server IP代表服务器IP)

1) 启动客户端脚本
本次环境: ZooKeeper 单机模式，并启动服务器

# zkCli.sh
Connecting to localhost:2181
…………………………..
2015-02-11 11:08:18,470 [myid:] - INFO  [main:ZooKeeper@438] - Initiating client connection, connectString=localhost:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@1c507aaf
Welcome to ZooKeeper!   注1
2015-02-11 11:08:18,517 [myid:] - INFO  [main-SendThread(localhost:2181):ClientCnxn$SendThread@966] - Opening socket connection to server localhost/127.0.0.1:2181. Will not attempt to authenticate using SASL (unknown error)  注2
2015-02-11 11:08:18,527 [myid:] - INFO  [main-SendThread(localhost:2181):ClientCnxn$SendThread@849] - Socket connection established to localhost/127.0.0.1:2181, initiating session
JLine support is enabled   注3
2015-02-11 11:08:18,550 [myid:] - INFO  [main-SendThread(localhost:2181):ClientCnxn$SendThread@1207] - Session establishment complete on server localhost/127.0.0.1:2181, sessionid = 0x14b769a51fe0001, negotiated timeout = 30000  注4

WATCHER::

WatchedEvent state:SyncConnected type:None path:null  注5
[zk: Server IP:2181(CONNECTED) 0]

注1：客户端启动初始化连接
注2：客户端尝试连接到ZooKeeper服务器
注3：连接成功，服务器创建一个session
注4：session创建成功
注5：服务器向客户端返回一个SyncConnected事件

其中注2中” Will not attempt to authenticate using SASL (unknown error)”，网上说是解析不对，但是在hosts文件中添加解析后依然如此，看ZooKeeper书籍中也是如此：
暂时无法知晓原因，以及是否会产生影响。


[zk: localhost:2181(CONNECTED) 0] help
ZooKeeper -server host:port cmd args
        connect host:port
        get path [watch]
        ls path [watch]
        set path data [version]
        rmr path
        delquota [-n|-b] path
        quit
        printwatches on|off
        create [-s] [-e] path data acl
        stat path [watch]
        close
        ls2 path [watch]
        history
        listquota path
        setAcl path acl
        getAcl path
        sync path
        redo cmdno
        addauth scheme auth
        delete path [version]
        setquota -n|-b val path

1) ls
使用ls命令，可以列出ZooKeeper指定节点下的所有的子节点，不过只能看到指定节点下第一级所有子节点。用法如下：

ls path [watch]
1
其中，path表示的是指定数据节点的节点路径
执行如下命令：

[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper]
1
2
第一次部署的ZooKeeper，默认在根节点”/”下面有一个叫做[zookeeper]的保留节点

2) create
使用create命令，可以创建一个ZooKeeper节点。用法如下：

create [-s] [-e] path data acl
1
其中：-s或-e分别指定节点特性：顺序或临时节点。默认情况下，即不添加-s或-e参数的，创建的是持久节点。data代表节点的数据内容。acl是进行权限控制，缺省情况下，不做任何权限控制。
执行如下命令创建一个新节点：

[zk: localhost:2181(CONNECTED) 1] create /example "演示创建节点命令"
Created /example
1
2
3) get
使用get命令，可以获取ZooKeeper指定节点的数据内容和属性信息。用法如下：

get path [watch]
1
执行如下命令：

[zk: localhost:2181(CONNECTED) 2] get /example
"演示创建节点命令"
cZxid = 0x4
ctime = Wed Feb 11 15:33:19 CST 2015
mZxid = 0x4
mtime = Wed Feb 11 15:33:19 CST 2015
pZxid = 0x4
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 26
numChildren = 0



4) set
使用set命令，可以更新指定节点的数据内容。用法如下：

set path data [version]
1
其中，data就是要更新的数据新内容。version参数用于指定本次更新操作是基于ZNode的哪一个数据版本进行的。ZooKeeper中，节点的数据是有版本概念的。
执行如下命令：

[zk: localhost:2181(CONNECTED) 3] set /example "演示更新数据内容命令"
cZxid = 0x4
ctime = Wed Feb 11 15:33:19 CST 2015
mZxid = 0x7
mtime = Wed Feb 11 15:43:33 CST 2015
pZxid = 0x4
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 32
numChildren = 0


使用get命令查看：

[zk: localhost:2181(CONNECTED) 4] get /example
"演示更新数据内容命令"
cZxid = 0x4
ctime = Wed Feb 11 15:33:19 CST 2015
mZxid = 0x7
mtime = Wed Feb 11 15:43:33 CST 2015
pZxid = 0x4
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 32
numChildren = 0
1
2
3
4
5
6
7
8
9
10
11
12
13
使用set命令时带上版本参数：

[zk: localhost:2181(CONNECTED) 5] set /example "演示带版本参数更新" 1
cZxid = 0x4
ctime = Wed Feb 11 15:33:19 CST 2015
mZxid = 0xb
mtime = Wed Feb 11 15:46:33 CST 2015
pZxid = 0x4
cversion = 0
dataVersion = 2
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 29
numChildren = 0
1
2
3
4
5
6
7
8
9
10
11
12
使用get命令查看：

[zk: localhost:2181(CONNECTED) 6] get  /example
"演示带版本参数更新"
cZxid = 0x4
ctime = Wed Feb 11 15:33:19 CST 2015
mZxid = 0xb
mtime = Wed Feb 11 15:46:33 CST 2015
pZxid = 0x4
cversion = 0
dataVersion = 2
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 29
numChildren = 0

可以看到mtime, dataVersion, dataLength会随之变化。

5) delete
使用delete命令，可以删除ZooKeeper上的指定节点。用法如下：

delete path [version]
1
其中，version参数和set命令中version参数的作用是一致的。
执行如下命令：

[zk: localhost:2181(CONNECTED) 7] delete /example
[zk: localhost:2181(CONNECTED) 8] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 9]
1
2
3
4
需要注意：被删除的节点，该节点必须没有子节点存在，否则会出现出错信息：

Node not empty: /example
1
执行如下命令：

[zk: localhost:2181(CONNECTED) 6] create /example/test "演示非空删除"
Created /example/test
[zk: localhost:2181(CONNECTED) 7] ls /
[example, zookeeper]
[zk: localhost:2181(CONNECTED) 8] ls /example
[test]
[zk: localhost:2181(CONNECTED) 9]
[zk: localhost:2181(CONNECTED) 10] delete /example
Node not empty: /example
[zk: localhost:2181(CONNECTED) 11]

###########################
#!/bin/bash

ZOOKP_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'

#snapshot file dir
dataDir=$ZOOKP_HOME/data/version-2
#tran log dir
dataLogDir=$ZOOKP_HOME/logs/version-2

#Leave 66 files
count=66
count=$[$count+1]
ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f
ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f

#以上这个脚本定义了删除对应两个目录中的文件，保留最新的66个文件，可以将他写到crontab中，设置为每天凌晨2点执行一次就可以了。


#zk log dir   del the zookeeper log
#logDir=
#ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f