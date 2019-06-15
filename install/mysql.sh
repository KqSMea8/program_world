#!/bin/bash

###########uninstall
/sbin/chkconfig --del  mysql
service mysql stop
yum -y remove mysql*
RPMNAME=`rpm -qa | grep -i mysql`
i=1
while((1==1))
do
        split=`echo $RPMNAME|cut -d " " -f$i`
        if [ "$split" != "" ]
        then
                ((i++))
				#echo ${split%.rpm}
                rpm -e --nodeps ${split%.rpm}
        else
                break
        fi
done

rm -rf /etc/my.cnf.rpmsave && rm -rf /var/log/mysqld.log.rpmsave
rm -rf /usr/include/mysql
rm -f /etc/my.cnf
rm -fr /var/lib/mysql
rm -rf /var/lib/mysql*
rm -rf /usr/share/mysql*
rpm -ivh *.rpm

/etc/init.d/mysql stop

mysqld_safe --user=mysql --skip-grant-tables --skip-networking &

/usr/bin/mysql -u root mysql


#########install############

yum install mysql-server
chkconfig --list | grep mysql
/etc/init.d/mysqld start || service mysqld start
/etc/init.d/mysqld status

##########setting#################
chkconfig mysqld on
chkconfig --list | grep mysql


mysqld_safe --user=mysql --skip-grant-tables --skip-networking & UPDATE user SET Password=PASSWORD('123456') where USER='root';


mysqladmin -uroot password root
mysql -uroot -proot

sudo cat /root/.mysql_secret

use mysql;
set password=password('zrr123');
select User,Host,Password from user;
update user set Host='%' where User='root' and Host='localhost';
delete from user where user='root' and host='127.0.0.1';


update user set password=password('zrr123') where user='root';
update mysql.user set password_expired='N';
flush privileges;


# Mysql的varchar主键只支持不超过768个字节
# GBK双字节 384
# UTF-8三字节 256






# /etc/init.d/mysql restart


# mysql -u root -p
# Enter password:*******
#SET PASSWORD = PASSWORD('zrr123');

# grant all privileges on *.* to root@'%' identified by 'zrr123';
# flush privileges;
# exit;


# use mysql 
# update user set Host = '%' where User= 'root' limit 1;



安装MySQL数据库
	版本5.6.26
安装包：mysql-5.6.26.tar.gz
1、下载解压
# tar -zxvf ~/softwares/mysql-5.6.26.tar.gz -C /opt/modules/mysql/
2、编译环境准备
# yum -y install gcc gcc-c++ gdb cmake ncurses-devel bison bison-devel  #### 网速慢的话，将yum源改为阿里yum
3、进入解压路径，进行编译检测
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci

4、make && make install  编译安装
5、配置MySQL
1）配置用户
使用下面的命令查看是否有mysql用户及用户组
cat /etc/passwd 查看用户列表
cat /etc/group  查看用户组列表
如果没有就创建
#groupadd mysql
#useradd -r -g mysql mysql
确认一下创建结果
id mysql
修改/usr/local/mysql目录权限
chown -R mysql:mysql /usr/local/mysql
2）初始化配置
安装运行MySQL测试脚本需要的perl
yum install perl
进入安装路径
cd /usr/local/mysql
执行初始化配置脚本，创建系统自带的数据库和表
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql

注：在启动MySQL服务时，会按照一定次序搜索my.cnf，先在/etc目录下找，找不到则会搜索"$basedir/my.cnf"，在本例中就是 /usr/local/mysql/my.cnf，这是新版MySQL的配置文件的默认位置！
注意：在CentOS 6.4版操作系统的最小安装完成后，在/etc目录下会存在一个my.cnf，需要将此文件更名为其他的名字，如：/etc/my.cnf.bak，否则，该文件会干扰源码安装的MySQL的正确配置，造成无法启动。
在使用"yum update"更新系统后，需要检查下/etc目录下是否会多出一个my.cnf，如果多出，将它重命名成别的。否则，MySQL将使用这个配置文件启动，可能造成无法正常启动等问题。
3）启动MySQL
添加服务，拷贝服务脚本到init.d目录，并设置开机启动
cp support-files/mysql.server /etc/init.d/mysql
ll /etc/init.d/mysql ### 查看有无可执行权限，如果没有则执行 chmod u+x /etc/init.d/mysql
chkconfig mysql on
service mysql start  --启动MySQL

4）配置MySQL账号密码
MySQL启动成功后，root默认没有密码，我们需要设置root密码。
设置之前，我们需要先设置PATH，要不不能直接调用mysql
修改/etc/profile文件，在文件末尾添加
PATH=/usr/local/mysql/bin:$PATH
export PATH
关闭文件，运行下面的命令，让配置立即生效
source /etc/profile
现在，我们可以在终端内直接输入mysql进入，mysql的环境了
执行下面的命令修改root密码
mysql -uroot
mysql> SET PASSWORD = PASSWORD('123456');
若要设置root用户可以远程访问，执行
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
远程访问时的密码可以和本地不同。




#!/bin/bash

/etc/init.d/mysql stop

if [[ $? -ne 0 ]]
	then exit
fi


BASEPATH='/opt/module/mysql-5.6/bak'


if [ ! -d "$BASEPATH" ]; then
  mkdir -p "$BASEPATH"
fi

#修改权限
#BASEPATH chown mysql.mysql /databackup/ -R

tar -cvPzf $BASEPATH/$(date +%Y%m%d%H%M%S).tar.gz /var/lib/mysql/

# rm -rf /usr/local/mysql/data/*

# tar -xvPf mysql01.tar.gz

/etc/init.d/mysql start



##################


#!/bin/bash


#输入 要备份的数据库名，多个数据库用空格分开
#databases=(db1 db2 db3)
#databases=(xiaoyuzhou)

#备份文件要保存的目录
BASEPATH='/opt/module/mysql-5.6/bak/'

# 删除生成的SQL文件
rm -rf $BASEPATH*.sql



if [ ! -d "$BASEPATH" ]; then
  mkdir -p "$BASEPATH"
fi

# 循环databases数组
for db in $*
  do
	v=$(/usr/bin/mysql -uroot -pzrr123  -A -e "use $db;show tables;")
	#v=$(/usr/bin/mysql -uroot -pzrr123 -D xiaoyuzhou -e "select count(*) from person;")
	echo $v

	 if [ -z "$v" ]
		then echo "NOT EXISTS"
				break
	 fi

	 if [[ $? -ne 0 ]]
		then break
	 fi

    # 备份数据库生成SQL文件
    /bin/nice -n 19 /usr/bin/mysqldump -uroot -pzrr123 --database --default-character-set=utf8 $db  > $BASEPATH$db-$(date +%Y%m%d%H%M%S).sql



    # 将生成的SQL文件压缩
    #/bin/nice -n 19 tar zPcf $BASEPATH$db-$(date +%Y%m%d).sql.tar.gz $BASEPATH$db-$(date +%Y%m%d).sql

    # 删除7天之前的备份数据
    find $BASEPATH -mtime +7 -name "*.sql" -exec rm -rf {} \;
  done


################
#!/bin/bash
BASEPATH='/opt/module/mysql-5.6/bak/'
SQLNAME=$1
DB=${SQLNAME%-*}
mysql -h  localhost -uroot -pzrr123 < $BASEPATH$SQLNAME

###############

#!/bin/bash

#mysqldump -uroot -p### ganxiyouth > /home/mysql/ganxiyouth_$(date +%Y%m%d_%H%M%S).sql

mysqldump --defaults-extra-file=/etc/my.cnf ganxiyouth  >  /home/mysql/ganxiyouth_$(date +%Y%m%d_%H%M%S).sql
