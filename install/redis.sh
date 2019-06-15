#!/bin/bash
REDIS_HOME='/opt/module/redis-3.2.1'

# wget http://download.redis.io/releases/redis-3.2.3.tar.gz
# chmod u+x redis-3.0.7.tar.gz
# tar -zxf redis-3.0.7.tar.gz

cd $REDIS_HOME

# 二进制文件是编译完成后在src目录下，通过下面的命令启动Redis服务：

# if [ ! -d "$REDIS_HOME/build" ]; then
  # mkdir -p $REDIS_HOME/build
# fi

 # ./configure

cd $REDIS_HOME  &&  sudo make
cd $REDIS_HOME/src && sudo make install

cd $REDIS_HOME/src && sudo make clean
cd $REDIS_HOME/src && sudo make dist

sudo yum install -y tcl
cd $REDIS_HOME  &&  sudo make test

# make distclean
# make PREFIX=$REDIS_HOME/build install
# make PREFIX=/usr/local/bin install


# make 32bit
# make test
# make CFLAGS="-m32 -march=native" LDFLAGS="-m32"
# make MALLOC=libc
# make MALLOC=jemalloc
# make V=1







# 2768:M 14 Sep 09:53:33.557 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
# 2768:M 14 Sep 09:53:33.557 # Server started, Redis version 3.2.1
# 2768:M 14 Sep 09:53:33.557 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
# 2768:M 14 Sep 09:53:33.557 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.

# echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

# sysctl vm.overcommit_memory=1



# echo never > /sys/kernel/mm/transparent_hugepage/enabled

# /etc/rc.local








# Redis是一个Key-value的数据结构存储系统，可以已数据库的形式，缓存系统，消息处理器使用，它支持的存储类型很多，例如，String(字符串)，list(列表)，set(集合)，zset(有序集合)，还支持设置排序范围查询，位图，hyperloglogs和半径查询地理信息的索引。Redis内部实现使用replication, Lua scripting, LRU eviction, transactions以及周期性的把更新数据写入磁盘或者修改操作追加到文件的机制。它还能支持分布式，集群部署以及自带的集群管理工具。

# 适合场景需求
# 1.对数据高并发读写
# 2.对海量数据的高效率存储以及访问
# 3.提高数据的拓展性和使用性

# Redis的安装和配置使用
# Redis官方不支持windows的Redis，所以我们在linux下进行安装,参照官方安装事例

# 1.下载安装包
# wget http://download.redis.io/releases/redis-3.2.0.tar.gz

# 这里写图片描述

# 2.解压安装包
# tar xzf redis-3.2.0.tar.gz

# 这里写图片描述

# 3.编译源代码
# cd redis-3.2.0
# make

# 这里写图片描述

# 4.查看编译是否成功，src目录是否客户端和服务器相关命令
# cd src
# ll

# 这里写图片描述

# 5.修改redis配置文件，配置成后台启动
# vi /home/sofepackage/redis-3.2.0/redis.conf

# 这里写图片描述

# 6.启动redis-server
# ./redis-server /home/sofepackage/redis-3.2.0/redis.conf

# 这里写图片描述

# 7.启动redis-cli客户端，并进程测试
# ./redis-cli
# set foo bar
# get foo

# 这里写图片描述

# 看到这里说明测试成功，我们把redis安装完成

# 8.如何停止服务器

# 这里写图片描述

# 在客户端里面输入shutdown命令即可，退出客户端用exit

# 9.卸载redis服务，只需把/usr/local/bin/目录下的redis删除即可

# 这里写图片描述

# 为了卸载干净，你还可以把解压和编译的redis包也给删除了

# 这里写图片描述

# 到此所有过程完成……………..

#################
#!/bin/bash

REDIS_HOME='/opt/module/redis-3.2.1'


ps -ef | grep 6379

/usr/local/bin/redis-cli -a zrr123 shutdown

ps -ef | grep 6379


# $REDIS_HOME/src/redis-cli -p 8888 shutdown
# $REDIS_HOME/src/redis-cli -p 6379 shutdown


# 脚本启动的的停止方式
# 命令：
# /etc/init.d/redis_6380 stop
# Redis服务器的启动和停止



####################

#!/bin/bash

sudo /usr/local/bin/redis-cli  shutdown

sudo rm -rf /usr/local/bin/redis*
# 卸载redis服务，只需把/usr/local/bin/目录下的redis删除即可
















生产环境中的 redis 是怎么部署的？

面试官心理分析
看看你了解不了解你们公司的 redis 生产集群的部署架构，如果你不了解，那么确实你就很失职了，你的 redis 是主从架构？集群架构？用了哪种集群方案？有没有做高可用保证？有没有开启持久化机制确保可以进行数据恢复？线上 redis 给几个 G 的内存？设置了哪些参数？压测后你们 redis 集群承载多少 QPS？

兄弟，这些你必须是门儿清的，否则你确实是没好好思考过。

面试题剖析
redis cluster，10 台机器，5 台机器部署了 redis 主实例，另外 5 台机器部署了 redis 的从实例，每个主实例挂了一个从实例，5 个节点对外提供读写服务，每个节点的读写高峰qps可能可以达到每秒 5 万，5 台机器最多是 25 万读写请求/s。

机器是什么配置？32G 内存+ 8 核 CPU + 1T 磁盘，但是分配给 redis 进程的是10g内存，一般线上生产环境，redis 的内存尽量不要超过 10g，超过 10g 可能会有问题。

5 台机器对外提供读写，一共有 50g 内存。

因为每个主实例都挂了一个从实例，所以是高可用的，任何一个主实例宕机，都会自动故障迁移，redis 从实例会自动变成主实例继续提供读写服务。

你往内存里写的是什么数据？每条数据的大小是多少？商品数据，每条数据是 10kb。100 条数据是 1mb，10 万条数据是 1g。常驻内存的是 200 万条商品数据，占用内存是 20g，仅仅不到总内存的 50%。目前高峰期每秒就是 3500 左右的请求量。

其实大型的公司，会有基础架构的 team 负责缓存集群的运维。

http://redis.io
http://www.redis.cn
https://github.com/MSOpenTech/redis
https://github.com/MSOpenTech/redis/releases


2：创建redis.conf文件：



这是一个配置文件，指定了redis的监听端口，timeout等。如下面有：port 6379。

配置：

[18892] 05 Jan 16:02:28.584 #
The Windows version of Redis allocates a memory mapped heap for sharing with
the forked process used for persistence operations. In order to share this
memory, Windows allocates from the system paging file a portion equal to the
size of the Redis heap. At this time there is insufficient contiguous free
space available in the system paging file for this operation (Windows error
0x5AF). To work around this you may either increase the size of the system
paging file, or decrease the size of the Redis heap with the --maxheap flag.
Sometimes a reboot will defragment the system paging file sufficiently for
this operation to complete successfully.

Please see the documentation included with the binary distributions for more
details on the --maxheap flag.

Redis can not continue. Exiting.
处理方法：

windows硬盘需要配置虚拟内存，如果还有问题，清理磁盘碎片
redis.windows.conf
<span style="color: #ff0000;"><strong>maxheap 1024000000
daemonize no
</strong></span>
　　

更改redis的配置需要修改redis.conf文件,以下是它一些主要的配置注释：

#是否作为守护进程运行
daemonize no
#Redis 默认监听端口
port 6379
#客户端闲置多少秒后，断开连接
timeout 300
#日志显示级别
loglevel verbose
#指定日志输出的文件名，也可指定到标准输出端口
logfile redis.log
#设置数据库的数量，默认最大是16,默认连接的数据库是0，可以通过select N 来连接不同的数据库
databases 32
#Dump持久化策略
#当有一条Keys 数据被改变是，900 秒刷新到disk 一次
#save 900 1
#当有10 条Keys 数据被改变时，300 秒刷新到disk 一次
save 300 100
#当有1w 条keys 数据被改变时，60 秒刷新到disk 一次
save 6000 10000
#当dump     .rdb 数据库的时候是否压缩数据对象
rdbcompression yes
#dump 持久化数据保存的文件名
dbfilename dump.rdb
###########    Replication #####################
#Redis的主从配置,配置slaveof则实例作为从服务器
#slaveof 192.168.0.105 6379
#主服务器连接密码
# masterauth <master-password>
############## 安全性 ###########
#设置连接密码
#requirepass <password>
############### LIMITS ##############
#最大客户端连接数
# maxclients 128
#最大内存使用率
# maxmemory <bytes>
########## APPEND ONLY MODE #########
#是否开启日志功能
appendonly no
# AOF持久化策略
#appendfsync always
#appendfsync everysec
#appendfsync no
################ VIRTUAL MEMORY ###########
#是否开启VM 功能
#vm-enabled no
# vm-enabled yes
#vm-swap-file logs/redis.swap
#vm-max-memory 0
#vm-page-size 32
#vm-pages 134217728
#vm-max-threads 4
主从复制

在从服务器配置文件中配置slaveof ,填写服务器IP及端口即可,如果主服务器设置了连接密码,在masterauth后指定密码就行了。

持久化

redis提供了两种持久化文案,Dump持久化和AOF日志文件持久化。
Dump持久化是把内存中的数据完整写入到数据文件,由配置策略触发写入,如果在数据更改后又未达到触发条件而发生故障会造成部分数据丢失。
AOF持久化是日志存储的,是增量的形式,记录每一个数据操作动作,数据恢复时就根据这些日志来生成。


3.命令行操作

使用CMD命令提示符,打开redis-cli连接redis服务器 ,也可以使用telnet客户端

# redis-cli -h 服务器 –p 端口 –a 密码

redis-cli.exe -h 127.0.0.1 -p 6379
连接成功后，就可对redis数据增删改查了,如字符串操作：

Windows环境下安装Redis体验谈_新客网

以下是一些服务器管理常用命令:

info   #查看服务器信息
select <dbsize> #选择数据库索引  select 1
flushall #清空全部数据
flushdb  #清空当前索引的数据库
slaveof <服务器> <端口>  #设置为从服务器
slaveof no one #设置为主服务器
shutdown  #关闭服务


附加几个 bat 批处理脚本,请根据需要灵活配置

service-install.bat
redis-server.exe --service-install redis.windows.conf --loglevel verbose

uninstall-service.bat
redis-server --service-uninstall

startup.bat
redis-server.exe redis.windows.conf









下载安装文件,选择稳定版本
w.redis.io/download  直接安装文件
github.com/MSOpenTech/redis/  解压后找到bin目录下的release下的redis-2.8.17

点击安装exe文件，进行安装。选择好路径，一直到安装结束即可。

点击Service查看Redis服务是否正确的安装。Windows--》Service.msc。默认的端口为6379。服务已启动。

使用客户端工具进行连接，出现如下画面即成功。

使用CMD工具，安装另一个Redis实例服务，端口为6369. 需要提前建好6369端口使用的conf文件
如：C:\Users\Gray>E:\redis-2.8.17\redis-server.exe --service-install E:\redis-2.8.17\redis6369.conf --service-name RedisServer6369 --port 6369

试验了几次都没有提示成功的信息，但是查看服务成功了，而且用客户端连接也成功了。 ..
