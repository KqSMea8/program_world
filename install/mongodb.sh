#!/bin/bash#

source /etc/profile

MO_HOME='/opt/module/mongodb-3.4.9'

# source function library
# . /etc/rc.d/init.d/functions

#定义命令
CMD=$MO_HOME/bin/mongod

#定义配置文件路径
INITFILE=$MO_HOME/mongodb.conf

start()
{
    #&表示后台启动，也可以使用fork参数
    $CMD -f $INITFILE --rest &
	ps aux|grep mongo
    echo "MongoDB is running background..."
}

stop()
{
	$MO_HOME/bin/mongod -f $INITFILE --shutdown
    # pkill mongod
	ps aux|grep mongo
    echo "MongoDB is stopped."
}

repair()
{	rm -rf $$MO_HOME/data/mongod.lock
	$MO_HOME/bin/mongod -f $INITFILE --repair
}

web()
{
	$MO_HOME/bin/mongod -f $INITFILE  --rest
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
	repair)
        repair
        ;;
    *)
        echo $"Usage: $0 {start|stop}"
esac

###############

sudo rm /var/lib/mongodb/mongod.lock
sudo service mongod restart
 bin/mongod --repair



