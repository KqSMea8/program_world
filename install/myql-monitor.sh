#! /bin/bash  
#MySQL running这个字符串根据数据库版本正常运行时status显示的信息确定  
/sbin/service mysql status | grep "MySQL running" > /dev/null  
  
if [ $? -eq 0 ]  
then  
        #状态正常检查3306端口是否正常监听  
        netstat -ntp | grep 3306 > /dev/null  
        if [ $? -ne 0 ]  
        then  
                /sbin/service mysql restart  
                sleep 3  
                /sbin/service mysql status | grep " MySQL running" > /dev/null  
				
                if [ $? -ne 0 ]  
                then  
                        echo "mysql service has stoped ,Automatic startup failure, please start it manually!" | mail -s "mysql is not running" 410358630@qq.com  
                 fi  
  
        fi  
else  
        /sbin/service mysql start  
        sleep 2;  
        /sbin/service mysql status | grep "MySQL running" > /dev/null  
        if [ $? -ne 0 ]  
        then  
                echo "mysql service has stoped ,Automatic startup failure, please start it manually!" | mail -s "mysql is not running" 410358630@qq.com  
        fi  
fi  