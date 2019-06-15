#!/bin/bash

yum install libevent libevent-deve
yum install memcached


# wget http://memcached.org/latest
# tar -zxvf memcached-1.x.x.tar.gz
# cd memcached-1.x.x
# ./configure && make && make test && sudo make install

# source /etc/profile


# cd /opt/module/memcached-1.5.1

# mkdir build

# ./configure --prefix=/opt/module/memcached-1.5.1/build

# make

# sudo make install

###############################################

#!/bin/bash

cd '/opt/module/memcached-1.5.1'

#作为前台程序运行
# sudo bin/memcached -p 11211 -m 64m -vv -u root


#作为后台服务程序运行
sudo bin/memcached -p 11211 -m 64m -d  -u root

# sudo bin/memcached -d -m 64M -u root -l 127.0.0.1 -p 11211 -c 256 -P /tmp/memcached.pid

telnet 127.0.0.1 11211

# set foo 0 0 3                                                   保存命令

# bar                                                             数据

# STORED                                                          结果

# get foo                                                         取得命令

# VALUE foo 0 3                                                   数据

# bar                                                             数据

# END                                                             结束行

# quit                                                            退出

