#!/bin/bash

NGINX_HOME='/opt/module/nginx-1.10.1'

#!/bin/bash

NGINX_HOME='/opt/module/nginx-1.10.1'

cd $NGINX_HOME
sudo sbin/nginx

# service nginx start



# nginx启动、重启、关闭

# 一、启动　　


# cd usr/local/nginx/sbin
# ./nginx
# 二、重启

# 　　更改配置重启nginx　　

# kill -HUP 主进程号或进程号文件路径
# 或者使用
# cd /usr/local/nginx/sbin
# ./nginx -s reload
    # 判断配置文件是否正确　

# nginx -t -c /usr/local/nginx/conf/nginx.conf
# 或者
# cd  /usr/local/nginx/sbin
# ./nginx -t
# 三、关闭

# 　　查询nginx主进程号

# 　　ps -ef | grep nginx

# 　　从容停止   kill -QUIT 主进程号

# 　　快速停止   kill -TERM 主进程号

# 　　强制停止   kill -9 nginx

# 　　若nginx.conf配置了pid文件路径，如果没有，则在logs目录下

# 　　kill -信号类型 '/usr/local/nginx/logs/nginx.pid'

# 四、升级

# 　　1、先用新程序替换旧程序文件

# 　　2、kill -USR2 旧版程序的主进程号或者进程文件名

# 　　　　此时旧的nginx主进程会把自己的进程文件改名为.oldbin，然后执行新版nginx，此时新旧版本同时运行

# 　　3、kill -WINCH 旧版本主进程号

# 　　4、不重载配置启动新/旧工作进程

# 　　　　kill -HUP 旧/新版本主进程号

# 　　　　从容关闭旧/新进程

# 　　　　kill -QUIT 旧/新进程号

# 　　　　快速关闭旧/新进程

# 　　　　kill -TERM 旧/新进程号

################

#!/bin/bash

NGINX_HOME=/usr/local/nginx

cd $NGINX_HOME

$NGINX_HOME/sbin/nginx -s quit
$NGINX_HOME/sbin/nginx

ps aux | grep nginx
tail -f $NGINX_HOME/logs/error.log


#######################


#!/bin/bash

NGINX_HOME='/opt/module/nginx-1.10.1'

PIDS=`sudo ps -ef | grep nginx |awk '{print $2}'`

i=1
while((1==1))
do
        split=`echo $PIDS|cut -d " " -f$i`
        if [ "$split" != "" ]
        then
                ((i++))
				sudo kill -quit $split
				# sudo kill -9  $split
        else
                break
        fi
done


##cat nigxpid | kill -9

################ha

#!/bin/bash
A=`ps-C nginx--no-header | wc-l`
if [ $A -eq 0 ];then
	/opt/module/nginx-1.10.1/sbin/nginx
	if [ `ps-Cnginx--no-header | wc-l` -eq 0];then
	killall keepalived
	fi


