#!/usr/bin/env bash


autobak



#backup files by date

DATE=`/bin/date +%Y%m%d`
BAK_FILEName=${1##*/}
/bin/tar -cf /backup/$BAK_FILEName.$DATE.tar $BAK_FILEName > /dev/null 2>> /backup/$BAK_FILEName.bak.log
/bin/gzip /backup/$BAK_FILEName.$DATE.tar
if [ $? -eq 0 ]
then
	echo "$1 $DATE backup successfully" >> /backup/$BAK_FILEName.bak.log
else
	echo "ERROR:failure $1 DATE backup!" >> /backup/$BAK_FILEName.bak.log
fi

# crontab -e
# 0 3 * * 2,5 script

#############################################


#!/bin/sh
echo '输入 1 到 4 之间的数字:'
                echo '你输入的数字为:'
                read aNum
                case $aNum in
                    1)  echo '你选择了 1'
                    ;;
                    2)  echo '你选择了 2'
                    ;;
                    3)  echo '你选择了 3'
                    ;;
                    4)  echo '你选择了 4'
                    ;;
                    *)  echo '你没有输入 1 到 4 之间的数字'
                    ;;
                esac


###系统监控
#!/bin/bash


#network
#Mike.Xu
# while : ; do
      # time='date +%m"-"%d" "%k":"%M'
      # day='date +%m"-"%d'
      # rx_before='ifconfig eth0|sed -n "8"p|awk '{print $2}'|cut -c7-'
      # tx_before='ifconfig eth0|sed -n "8"p|awk '{print $6}'|cut -c7-'
      # sleep 2
      # rx_after='ifconfig eth0|sed -n "8"p|awk '{print $2}'|cut -c7-'
      # tx_after='ifconfig eth0|sed -n "8"p|awk '{print $6}'|cut -c7-'
      # rx_result=$[(rx_after-rx_before)/256]
      # tx_result=$[(tx_after-tx_before)/256]
      # echo "$time Now_In_Speed: "$rx_result"kbps Now_OUt_Speed: "$tx_result"kbps"
      # sleep 2
# done


#systemstat.sh
#Mike.Xu
IP=192.168.1.227
top -n 2| grep "Cpu" #>>./temp/cpu.txt
free -m | grep "Mem" #>> ./temp/mem.txt
df -k | grep "sda1" #>> ./temp/drive_sda1.txt
#df -k | grep sda2 >> ./temp/drive_sda2.txt
df -k | grep "/mnt/storage_0" #>> ./temp/mnt_storage_0.txt
df -k | grep "/mnt/storage_pic" #>> ./temp/mnt_storage_pic.txt
time=`date +%m"."%d" "%k":"%M`
connect=`netstat -na | grep "219.238.148.30:80" | wc -l`
echo "$time  $connect" #>> ./temp/connect_count.txt



#monitor available disk space
SPACE="df | sed -n '/ \ / $ / p' | gawk '{print $5}' | sed  's/%//'"
if [ $SPACE -ge 90 ]
then
jbxue123@163.com
fi


#script  to capture system statistics
OUTFILE=/home/xiaoyuzhou/capstats.csv
DATE='date +%m/%d/%Y'
TIME='date +%k:%m:%s'
TIMEOUT='uptime'
VMOUT='vmstat 1 2'
USERS='echo $TIMEOUT | gawk '{print $4}' '
LOAD='echo $TIMEOUT | gawk '{print $9}' | sed "s/,//' ''
FREE="echo $VMOUT | sed -n '/[0-9]/p' | sed -n '2p' | gawk '{print $4} ''"
IDLE="echo  $VMOUT | sed -n '/[0-9]/p' | sed -n '2p' |gawk '{print $15}'"
echo "$DATE,$TIME,$USERS,$LOAD,$FREE,$IDLE" >> $OUTFILE


# check_xu.sh
# 0 * * * * /home/check_xu.sh

DAT="`date +%Y%m%d`"
HOUR="`date +%H`"
DIR="/home/xiaoyuzhou/host_${DAT}/${HOUR}"
DELAY=60
COUNT=60
# whether the responsible directory exist
if ! test -d ${DIR}
then
        /bin/mkdir -p ${DIR}
fi
# general check
export TERM=linux
/usr/bin/top -b -d ${DELAY} -n ${COUNT} > ${DIR}/top_${DAT}.log 2>&1 &
# cpu check
/usr/bin/sar -u ${DELAY} ${COUNT} > ${DIR}/cpu_${DAT}.log 2>&1 &
#/usr/bin/mpstat -P 0 ${DELAY} ${COUNT} > ${DIR}/cpu_0_${DAT}.log 2>&1 &
#/usr/bin/mpstat -P 1 ${DELAY} ${COUNT} > ${DIR}/cpu_1_${DAT}.log 2>&1 &
# memory check
/usr/bin/vmstat ${DELAY} ${COUNT} > ${DIR}/vmstat_${DAT}.log 2>&1 &
# I/O check
/usr/bin/iostat ${DELAY} ${COUNT} > ${DIR}/iostat_${DAT}.log 2>&1 &
# network check
/usr/bin/sar -n DEV ${DELAY} ${COUNT} > ${DIR}/net_${DAT}.log 2>&1 &
#/usr/bin/sar -n EDEV ${DELAY} ${COUNT} > ${DIR}/net_edev_${DAT}.log 2>&1 &






# free_mem=$(free -m | grep "buffers/cache" | awk '{print $4}')
# load_5min=$(cat /proc/loadavg | awk '{print $2}')
# cpu_idle=$(sar 1 5 | grep -i 'Average' | awk '{print $NF}')
# tx_speed=$(sar -n DEV 10 5 | grep "Average" | grep "$interface" | awk '{print $6}')
# httpd_status=$(ps -ef | grep 'httpd' | grep -v 'grep')

# header="{";
# name="'hostname':'"
# host=`hostname`
# end="'}"


# echo "{'hostname':'"$host"','freemem':"$free_mem",'load':"$load_5min",'cpuidle':"$cpu_idle",'txspeed':"$tx_speed",'httpstatus':'"$httpd_status"'}"


cpuuse=`top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }'`

echo 'cpu use:'$cpuuse

mem=`free -m|grep Mem|awk '{print ($3-$6-$7)/$2}'`

echo 'mem use:'$mem


##################
#!/bin/bash

#对进程进行监控
function GetPID #User #Name
 {
    PsUser=$1
    PsName=$2
    pid=`ps -u $PsUser|grep $PsName|grep -v grep|grep -v vi|grep -v dbx\n |grep -v tail|grep -v start|grep -v stop |sed -n 1p |awk '{print $1}'`
    echo $pid
 }

PID=`GetPID root mysql`
     # 检查进程是否存在
    if [ "-$PID" == "-" ]
    then
    {
        echo "The process does not exist."
    }
    fi

 echo $PID


 #------------------------------------------------------------------------------
# 函数: CheckProcess
# 功能: 检查一个进程是否存在  自动重启的shell脚本实现方法
# 参数: $1 --- 要检查的进程名称
# 返回: 如果存在返回0, 否则返回1.
#------------------------------------------------------------------------------
CheckProcess()
{
  # 检查输入的参数是否有效
  if [ "$1" = "" ];
  then
    return 1
  fi

  #$PROCESS_NUM获取指定进程名的数目，为1返回0，表示正常，不为1返回1，表示有错误，需要重新启动
  PROCESS_NUM=`ps -ef | grep "$1" | grep -v "grep" | wc -l`
  if [ $PROCESS_NUM -eq 1 ];
  then
    return 0
  else
    return 1
  fi
}

# 检查test实例是否已经存在
while [ 1 ] ; do
 CheckProcess "mysql"
 CheckQQ_RET=$?
 # if [ $CheckQQ_RET -eq 1 ];
 # then

# # 杀死所有test进程，可换任意你需要执行的操作
  # killall -9 test
  # exec ./test &
 # fi
 sleep 1
done


# # #对业务进程 CPU 进行实时监控
 # function GetCpu #PID
  # {
   # CpuValue=`ps -p $1 -o pcpu |grep -v CPU | awk '{print $1}' | awk -  F. '{print $1}'`
        # echo $CpuValue
    # }

# GetCpu $PID



# #判断 CPU 利用率是否超过限制
# function CheckCpu
 # {
    # PID=$1
    # cpu=`GetCpu $PID`
    # if [ $cpu -gt 80 ]
    # then
    # {
 # echo “The usage of cpu is larger than 80%”
    # }
    # else
    # {
 # echo “The usage of cpu is normal”
    # }
    # fi
 # }

# CheckCpu $PID




# #对业务进程内存使用量进行监控

# function GetMem
    # {
        # MEMUsage=`ps -o vsz -p $1|grep -v VSZ`
        # (( MEMUsage /= 1000))
        # echo $MEMUsage
    # }




# #判断内存使用是否超过限制
# mem=`GetMem $PID`
 # if [ $mem -gt 1600 ]
 # then
 # {
     # echo “The usage of memory is larger than 1.6G”
 # }
 # else
 # {
    # echo “The usage of memory is normal”
 # }
 # fi

# mem=`GetMem $PID`

    # echo "The usage of memory is $mem M"

    # if [ $mem -gt 1600 ]
    # then
    # {
         # echo "The usage of memory is larger than 1.6G"
    # }
    # else
    # {
        # echo "The usage of memory is normal"
    # }
    # fi


# # 检测进程句柄使用量
# function GetDes
    # {
        # DES=`ls /proc/$1/fd | wc -l`
        # echo $DES
    # }

# des=` GetDes $PID`
 # if [ $des -gt 900 ]
 # then
 # {
     # echo “The number of des is larger than 900”
 # }
 # else
 # {
    # echo “The number of des is normal”
 # }
 # fi

 # des=`GetDes $PID`

    # echo "The number of des is $des"

    # if [ $des -gt 900 ]
    # then
    # {
         # echo "The number of des is larger than 900"
    # }
    # else
    # {
        # echo "The number of des is normal"
    # }
    # fi

# #查看某个 TCP 或 UDP 端口是否在监听
# function Listening
 # {
    # TCPListeningnum=`netstat -an | grep ":$1 " | \n
    # awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l`
    # UDPListeningnum=`netstat -an|grep ":$1 " \n
    # |awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l`
    # (( Listeningnum = TCPListeningnum + UDPListeningnum ))
    # if [ $Listeningnum == 0 ]
    # then
    # {
        # echo "0"
    # }
    # else
    # {
       # echo "1"
    # }
    # fi
 # }

 # isListen=`Listening 8080`
    # if [ $isListen -eq 1 ]
    # then
    # {
        # echo "The port is listening"
    # }
    # else
    # {
        # echo "The port is not listening"
    # }
    # fi



	# # tcp: netstat -an|egrep $1 |awk '$6 == "LISTEN" && $1 == "tcp" {print $0}'
    # # udp: netstat -an|egrep $1 |awk '$1 == "udp" && $5 == "0.0.0.0:*" {print $0}'


# #查看某个进程名正在运行的个数

# #Runnum=`ps -ef | grep -v vi | grep -v tail | grep "[ /]CFTestApp" | grep -v grep | wc -l


# #检测系统 CPU 负载
# # function GetSysCPU
 # # {
   # # CpuIdle=`vmstat 1 5 |sed -n '3,$p' \n |awk '{x = x + $15} END {print x/5}' |awk -F. '{print $1}'
   # # CpuNum=`echo "100-$CpuIdle" | bc`
   # # echo $CpuNum
 # # }
 # # cpu=`GetSysCPU`
 # # echo "The system CPU is $cpu"

 # # if [ $cpu -gt 90 ]
 # # then
 # # {
    # # echo "The usage of system cpu is larger than 90%"
 # # }
 # # else
 # # {
    # # echo "The usage of system cpu is normal"
 # # }
 # # fi


# #检测系统磁盘空间
# function GetDiskSpc
 # {
    # if [ $# -ne 1 ]
    # then
        # return 1
    # fi

    # Folder="$1$"
    # DiskSpace=`df -k |grep $Folder |awk '{print $5}' |awk -F% '{print $1}'
    # echo $DiskSpace
# }


 # Folder="/boot"

 # DiskSpace=`GetDiskSpc $Folder`

 # echo "The system $Folder disk space is $DiskSpace%"

 # if [ $DiskSpace -gt 90 ]
 # then
 # {
    # echo "The usage of system disk($Folder) is larger than 90%"
 # }
 # else
 # {
    # echo "The usage of system disk($Folder)  is normal"
 # }
 # fi

###################################

until [ $# -eq 0 ]
		do
			echo "第一个参数为: $1 参数个数为: $#"
			#shift 命令执行前变量 $1 的值在shift命令执行后不可用
			shift
		done

########流量监控###################
#input the network name

if [ -n "$1" ]; then
    eth_name=$1
else
    eth_name="eth0"
fi

send_o=`ifconfig $eth_name | grep bytes | awk '{print $6}' | awk -F : '{print $2}'`
recv_o=`ifconfig $eth_name | grep bytes | awk '{print $2}' | awk -F : '{print $2}'`

send_n=$send_o
recv_n=$recv_o

i=0
while [ $i -le 100000 ]; do
    send_l=$send_n
    recv_l=$recv_n
    sleep 2
    send_n=`ifconfig $eth_name | grep bytes | awk '{print $6}' | awk -F : '{print $2}'`
    recv_n=`ifconfig $eth_name | grep bytes | awk '{print $2}' | awk -F : '{print $2}'`
    i=`expr $i + 1`

    send_r=`expr $send_n - $send_l`
    recv_r=`expr $recv_n - $recv_l`
    total_r=`expr $send_r + $recv_r`
    send_ra=`expr \( $send_n - $send_o \) / $i`
    recv_ra=`expr \( $recv_n - $recv_o \) / $i`
    total_ra=`expr $send_ra + $recv_ra`
    sendn=`ifconfig $eth_name | grep bytes | awk -F \( '{print $3}' | awk -F \) '{print $1}'`
    recvn=`ifconfig $eth_name | grep bytes | awk -F \( '{print $2}' | awk -F \) '{print $1}'`
    clear
    echo "Last second : Send rate: $send_r Bytes/sec Recv rate: $recv_r Bytes/sec Total rate: $total_r Bytes/sec"
    echo "Average value: Send rate: $send_ra Bytes/sec Recv rate: $recv_ra Bytes/sec Total rate: $total_ra Bytes/sec"
    echo "Total traffic after startup: Send traffic: $sendn Recv traffic: $recvn"
done

#############
数组

#!/usr/bin/env bash
for ((i=0;i<${#o[*]};i++))
do
    echo ${o[$i]}
done

declare -a myarray
local -a myarray

myarray=`ls *.bin 2>/dev/null`
 read -a myarray

${array[0]}='test'
myarray=(${myarray[*] test)


echo ${myarrra[*]};
echo ${myarrra[@]};

for item in ${myarray[*]};
do
echo $item;
done;

uset ${myarray}
myarray=


$ hobbies=( "${activities[@]" diving }
 $ for hobby in "${hobbies[@]}"
> do
>   echo "Hobby: $hobby"
> done
Hobby: swimming
Hobby: water skiing
Hobby: canoeing
Hobby: white-water rafting
Hobby: surfing
Hobby: scuba diving
Hobby: diving
$

本章开头介绍了如何使用seq 0 $((${#beatles[@]}–1))获取数组的最后一个实际元素。但数组从0开始索引这一事实使得这一任务变得有些棘手。在向数组追加单个元素时，数组从0开始索引实际上使得追加操作更容易。
$ hobbies[${#hobbies[@]}]=rowing
$ for hobby in "${hobbies[@]}"
> do
>   echo "Hobby: $hobby"
> done
Hobby: swimming
Hobby: water skiing
Hobby: canoeing
Hobby: white-water rafting
Hobby: surfing
Hobby: scuba diving
Hobby: diving
Hobby: rowing
$
bash shell确实有组合两个数组的内置语法。这种使用C风格符号+=的方法更简洁，而且写出的代码更清晰。
$ airsports=( flying gliding parachuting )
$ activities+=("${airsports[@]}")
$ for act in "${activities[@]}"
> do
>   echo "Activity: $act"
> done
Activity: swimming
Activity: water skiing
Activity: canoeing
Activity: white-water rafting
Activity: surfing
Activity: scuba diving
Activity: climbing
Activity: walking
Activity: cycling
Activity: flying
Activity: gliding
Activity: parachuting
$

for data in ${array[@]}
do
    echo ${data}
done






bash支持一维数组（不支持多维数组），并且没有限定数组的大小。类似与C语言，数组元素的下标由0开始编号。获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于0。
定义数组

在Shell中，用括号来表示数组，数组元素用“空格”符号分割开。定义数组的一般形式为：
    array_name=(value1 ... valuen)
例如：
array_name=(value0 value1 value2 value3)
或者
array_name=(
value0
value1
value2
value3
)

array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
#可以不使用连续的下标，而且下标的范围没有限制。
#读取数组

#读取数组元素值的一般格式是：
    ${array_name[index]}
例如：
valuen=${array_name[2]}
举个例子：
#!/bin/sh
NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo "First Index: ${NAME[0]}"
echo "Second Index: ${NAME[1]}"
运行脚本，输出：
$./test.sh
First Index: Zara
Second Index: Qadir
使用@ 或 * 可以获取数组中的所有元素，例如：
${array_name[*]}
${array_name[@]}
举个例子：
#!/bin/sh
NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo "First Method: ${NAME[*]}"
echo "Second Method: ${NAME[@]}"
运行脚本，输出：
$./test.sh
First Method: Zara Qadir Mahnaz Ayan Daisy
Second Method: Zara Qadir Mahnaz Ayan Daisy
获取数组的长度

获取数组长度的方法与获取字符串长度的方法相同，例如：
纯文本复制
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}


##############

#!/bin/sh
#backup files by date
#bug:只支持在数据的当前目录备份
DATE=`/bin/date +%Y%m%d`
/bin/tar -cf /backup/$1.$DATE.tar $1 > /dev/null 2>> /backup/$1.bak.log
/bin/gzip /backup/$1.$DATE.tar
if [ $? -eq 0]
then
	echo "$1 $DATE backup successfully" >> /backup/$1.bak.log
else
	echo "ERROR:failure $1 DATE backup!" >> /backup/$1.bak.log
fi

# crontab -e
# 0 3 * * 2,5 /bin/sh /shell/shell.example/autobak.sh /etc

















#######################################


 find . -name *.sql -exec cat {} \; > all.txt

十六. 文件查找命令find:

    下面给出find命令的主要应用示例：
    /> ls -l     #列出当前目录下所包含的测试文件
    -rw-r--r--. 1 root root 48217 Nov 12 00:57 install.log
    -rw-r--r--. 1 root root      37 Nov 12 00:56 testfile.dat
    -rw-r--r--. 1 root root 10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 root root     183 Nov 11 08:02 users
    -rw-r--r--. 1 root root     279 Nov 11 08:45 users2

    1. 按文件名查找：
    -name:  查找时文件名大小写敏感。
    -iname: 查找时文件名大小写不敏感。
    #该命令为find命令中最为常用的命令，即从当前目录中查找扩展名为.log的文件。需要说明的是，缺省情况下，find会从指定的目录搜索，并递归的搜索其子目录。
    /> find . -name "*.log"
     ./install.log
    /> find . -iname U*          #如果执行find . -name U*将不会找到匹配的文件
    users users2


    2. 按文件时间属性查找：
    -atime  -n[+n]: 找出文件访问时间在n日之内[之外]的文件。
    -ctime  -n[+n]: 找出文件更改时间在n日之内[之外]的文件。
    -mtime -n[+n]: 找出修改数据时间在n日之内[之外]的文件。
    -amin   -n[+n]: 找出文件访问时间在n分钟之内[之外]的文件。
    -cmin   -n[+n]: 找出文件更改时间在n分钟之内[之外]的文件。
    -mmin  -n[+n]: 找出修改数据时间在n分钟之内[之外]的文件。
    /> find -ctime -2        #找出距此时2天之内创建的文件
    .
    ./users2
    ./install.log
    ./testfile.dat
    ./users
    ./test.tar.bz2
    /> find -ctime +2        #找出距此时2天之前创建的文件
    没有找到                     #因为当前目录下所有文件都是2天之内创建的
    /> touch install.log     #手工更新install.log的最后访问时间，以便下面的find命令可以找出该文件
    /> find . -cmin  -3       #找出修改状态时间在3分钟之内的文件。
    install.log

    3. 基于找到的文件执行指定的操作：
    -exec: 对匹配的文件执行该参数所给出的shell命令。相应命令的形式为'command' {} \;，注意{}和\；之间的空格，同时两个{}之间没有空格
    -ok:   其主要功能和语法格式与-exec完全相同，唯一的差别是在于该选项更加安全，因为它会在每次执行shell命令之前均予以提示，只有在回答为y的时候，其后的shell命令才会被继续执行。需要说明的是，该选项不适用于自动化脚本，因为该提供可能会挂起整个自动化流程。
    #找出距此时2天之内创建的文件，同时基于find的结果，应用-exec之后的命令，即ls -l，从而可以直接显示出find找到文件的明显列表。
    /> find . -ctime -2 -exec ls -l {} \;
    -rw-r--r--. 1 root root      279 Nov 11 08:45 ./users2
    -rw-r--r--. 1 root root  48217 Nov 12 00:57 ./install.log
    -rw-r--r--. 1 root root        37 Nov 12 00:56 ./testfile.dat
    -rw-r--r--. 1 root root      183 Nov 11 08:02 ./users
    -rw-r--r--. 1 root root  10530 Nov 11 23:08 ./test.tar.bz2
    #找到文件名为*.log, 同时文件数据修改时间距此时为1天之内的文件。如果找到就删除他们。有的时候，这样的写法由于是在找到之后立刻删除，因此存在一定误删除的危险。
    /> ls
    install.log  testfile.dat  test.tar.bz2  users  users2
    /> find . -name "*.log" -mtime -1 -exec rm -f {} \;
    /> ls
    testfile.dat  test.tar.bz2  users  users2
    在控制台下，为了使上面的命令更加安全，我们可以使用-ok替换-exec，见如下示例：
    />  find . -name "*.dat" -mtime -1 -ok rm -f {} \;
    < rm ... ./testfile.dat > ? y    #对于该提示，如果回答y，找到的*.dat文件将被删除，这一点从下面的ls命令的结果可以看出。
    /> ls
    test.tar.bz2  users  users2

    4. 按文件所属的owner和group查找：
    -user:      查找owner属于-user选项后面指定用户的文件。
    ! -user:    查找owner不属于-user选项后面指定用户的文件。
    -group:   查找group属于-group选项后面指定组的文件。
    ! -group: 查找group不属于-group选项后面指定组的文件。
    /> ls -l                            #下面三个文件的owner均为root
    -rw-r--r--. 1 root root 10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 root root     183 Nov 11 08:02 users
    -rw-r--r--. 1 root root     279 Nov 11 08:45 users2
    /> chown stephen users   #将users文件的owner从root改为stephen。
    /> ls -l
    -rw-r--r--. 1 root       root 10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 stephen root    183 Nov 11 08:02 users
    -rw-r--r--. 1 root       root     279 Nov 11 08:45 users2
    /> find . -user root          #搜索owner是root的文件
    .
    ./users2
    ./test.tar.bz2
    /> find . ! -user root        #搜索owner不是root的文件，注意!和-user之间要有空格。
    ./users
    /> ls -l                            #下面三个文件的所属组均为root
    -rw-r--r--. 1 root      root 10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 stephen root    183 Nov 11 08:02 users
    -rw-r--r--. 1 root      root    279 Nov 11 08:45 users2
    /> chgrp stephen users    #将users文件的所属组从root改为stephen
    /> ls -l
    -rw-r--r--. 1 root           root    10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 stephen stephen      183 Nov 11 08:02 users
    -rw-r--r--. 1 root            root       279 Nov 11 08:45 users2
    /> find . -group root        #搜索所属组是root的文件
    .
    ./users2
    ./test.tar.bz2
    /> find . ! -group root      #搜索所属组不是root的文件，注意!和-user之间要有空格。
    ./users

    5. 按指定目录深度查找：
    -maxdepth: 后面的参数表示距当前目录指定的深度，其中1表示当前目录，2表示一级子目录，以此类推。在指定该选项后，find只是在找到指定深度后就不在递归其子目录了。下例中的深度为1，表示只是在当前子目录中搜索。如果没有设置该选项，find将递归当前目录下的所有子目录。
    /> mkdir subdir               #创建一个子目录，并在该子目录内创建一个文件
    /> cd subdir
    /> touch testfile
    /> cd ..
    #maxdepth后面的参数表示距当前目录指定的深度，其中1表示当前目录，2表示一级子目录，以此类推。在指定该选项后，find只是在找到指定深度后就不在递归其子目录了。下例中的深度为1，表示只是在当前子目录中搜索。如果没有设置该选项，find将递归当前目录下的所有子目录。
    /> find . -maxdepth 1 -name "*"
    .
    ./users2
    ./subdir
    ./users
    ./test.tar.bz2
    #搜索深度为子一级子目录，这里可以看出子目录下刚刚创建的testfile已经被找到
    /> find . -maxdepth 2 -name "*"
    .
    ./users2
    ./subdir
    ./subdir/testfile
    ./users
    ./test.tar.bz2

    6. 排除指定子目录查找：
    -path pathname -prune:   避开指定子目录pathname查找。
    -path expression -prune:  避开表达中指定的一组pathname查找。
    需要说明的是，如果同时使用-depth选项，那么-prune将被find命令忽略。
    #为后面的示例创建需要避开的和不需要避开的子目录，并在这些子目录内均创建符合查找规则的文件。
    /> mkdir DontSearchPath
    /> cd DontSearchPath
    /> touch datafile1
    /> cd ..
    /> mkdir DoSearchPath
    /> cd DoSearchPath
    /> touch datafile2
    /> cd ..
    /> touch datafile3
    #当前目录下，避开DontSearchPath子目录，搜索所有文件名为datafile*的文件。
    /> find . -path "./DontSearchPath" -prune -o -name "datafile*" -print
    ./DoSearchPath/datafile2
    ./datafile3
    #当前目录下，同时避开DontSearchPath和DoSearchPath两个子目录，搜索所有文件名为datafile*的文件。
    /> find . \( -path "./DontSearchPath" -o -path "./DoSearchPath" \) -prune -o -name "datafile*" -print
    ./datafile3

    7. 按文件权限属性查找：
    -perm mode:   文件权限正好符合mode(mode为文件权限的八进制表示)。
    -perm +mode: 文件权限部分符合mode。如命令参数为644(-rw-r--r--)，那么只要文件权限属性中有任何权限和644重叠，这样的文件均可以被选出。
    -perm -mode:  文件权限完全符合mode。如命令参数为644(-rw-r--r--)，当644中指定的权限已经被当前文件完全拥有，同时该文件还拥有额外的权限属性，这样的文件可被选出。
    /> ls -l
    -rw-r--r--. 1 root            root           0 Nov 12 10:02 datafile3
    -rw-r--r--. 1 root            root    10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 stephen stephen        183 Nov 11 08:02 users
    -rw-r--r--. 1 root            root        279 Nov 11 08:45 users2
    /> find . -perm 644      #查找所有文件权限正好为644(-rw-r--r--)的文件。
    ./users2
    ./datafile3
    ./users
    ./test.tar.bz2
    /> find . -perm 444      #当前目录下没有文件的权限属于等于444(均为644)。
    /> find . -perm -444     #644所包含的权限完全覆盖444所表示的权限。
    .
    ./users2
    ./datafile3
    ./users
    ./test.tar.bz2
    /> find . -perm +111    #查找所有可执行的文件，该命令没有找到任何文件。
    /> chmod u+x users     #改变users文件的权限，添加owner的可执行权限，以便于下面的命令可以将其找出。
    /> find . -perm +111
    .
    ./users

    8. 按文件类型查找：
    -type：后面指定文件的类型。
    b - 块设备文件。
    d - 目录。
    c - 字符设备文件。
    p - 管道文件。
    l  - 符号链接文件。
    f  - 普通文件。
    /> mkdir subdir
    /> find . -type d      #在当前目录下，找出文件类型为目录的文件。
    ./subdir
　 /> find . ! -type d    #在当前目录下，找出文件类型不为目录的文件。
    ./users2
    ./datafile3
    ./users
    ./test.tar.bz2
    /> find . -type f       #在当前目录下，找出文件类型为文件的文件
    ./users2
    ./datafile3
    ./users
    ./test.tar.bz2

    9. 按文件大小查找：
    -size [+/-]100[c/k/M/G]: 表示文件的长度为等于[大于/小于]100块[字节/k/M/G]的文件。
    -empty: 查找空文件。
    /> find . -size +4k -exec ls -l {} \;  #查找文件大小大于4k的文件，同时打印出找到文件的明细
    -rw-r--r--. 1 root root 10530 Nov 11 23:08 ./test.tar.bz2
    /> find . -size -4k -exec ls -l {} \;  #查找文件大小小于4k的文件。
    -rw-r--r--. 1 root            root 279 Nov 11 08:45 ./users2
    -rw-r--r--. 1 root             root    0 Nov 12 10:02 ./datafile3
    -rwxr--r--. 1 stephen stephen 183 Nov 11 08:02 ./users
    /> find . -size 183c -exec ls -l {} \; #查找文件大小等于183字节的文件。
    -rwxr--r--. 1 stephen stephen 183 Nov 11 08:02 ./users
    /> find . -empty  -type f -exec ls -l {} \;
    -rw-r--r--. 1 root root 0 Nov 12 10:02 ./datafile3

    10. 按更改时间比指定文件新或比文件旧的方式查找：
    -newer file1 ! file2： 查找文件的更改日期比file1新，但是比file2老的文件。
    /> ls -lrt   #以时间顺序(从早到晚)列出当前目录下所有文件的明细列表，以供后面的例子参考。
    -rwxr--r--. 1 stephen stephen   183 Nov 11 08:02 users1
    -rw-r--r--. 1 root           root    279 Nov 11 08:45 users2
    -rw-r--r--. 1 root           root 10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 root           root        0 Nov 12 10:02 datafile3
    /> find . -newer users1     #查找文件更改日期比users1新的文件，从上面结果可以看出，其余文件均符合要求。
    ./users2
    ./datafile3
    ./test.tar.bz2
    /> find . ! -newer users2   #查找文件更改日期不比users1新的文件。
    ./users2
    ./users
    #查找文件更改日期比users2新，但是不比test.tar.bz2新的文件。
    /> find . -newer users2 ! -newer test.tar.bz2
    ./test.tar.bz2

    细心的读者可能发现，关于find的说明，在我之前的Blog中已经给出，这里之所以拿出一个小节再次讲述该命令主要是因为以下三点原因：
    1. find命令在Linux Shell中扮演着极为重要的角色；
    2. 为了保证本系列的完整性；
    3. 之前的Blog是我多年之前留下的总结笔记，多少有些粗糙，这里给出了更为详细的举例。





十七. xargs命令:

    该命令的主要功能是从输入中构建和执行shell命令。
    在使用find命令的-exec选项处理匹配到的文件时， find命令将所有匹配到的文件一起传递给exec执行。但有些系统对能够传递给exec的命令长度有限制，这样在find命令运行几分钟之后，就会出现溢出错误。错误信息通常是“参数列太长”或“参数列溢出”。这就是xargs命令的用处所在，特别是与find命令一起使用。
    find命令把匹配到的文件传递给xargs命令，而xargs命令每次只获取一部分文件而不是全部，不像-exec选项那样。这样它可以先处理最先获取的一部分文件，然后是下一批，并如此继续下去。
    在有些系统中，使用-exec选项会为处理每一个匹配到的文件而发起一个相应的进程，并非将匹配到的文件全部作为参数一次执行；这样在有些情况下就会出现进程过多，系统性能下降的问题，因而效率不高；
    而使用xargs命令则只有一个进程。另外，在使用xargs命令时，究竟是一次获取所有的参数，还是分批取得参数，以及每一次获取参数的数目都会根据该命令的选项及系统内核中相应的可调参数来确定。
    /> ls -l
    -rw-r--r--. 1 root root        0 Nov 12 10:02 datafile3
    -rw-r--r--. 1 root root 10530 Nov 11 23:08 test.tar.bz2
    -rwxr--r--. 1 root root    183 Nov 11 08:02 users
    -rw-r--r--. 1 root root    279 Nov 11 08:45 users2
    #查找当前目录下的每一个普通文件，然后使用xargs命令来测试它们分别属于哪类文件。
    /> find . -type f -print | xargs file
    ./users2:        ASCII text
    ./datafile3:      empty
    ./users:          ASCII text
    ./test.tar.bz2: bzip2 compressed data, block size = 900k
    #回收当前目录下所有普通文件的执行权限。
    /> find . -type f -print | xargs chmod a-x
    /> ls -l
    -rw-r--r--. 1 root root     0 Nov 12 10:02 datafile3
    -rw-r--r--. 1 root root 10530 Nov 11 23:08 test.tar.bz2
    -rw-r--r--. 1 root root   183 Nov 11 08:02 users
    -rw-r--r--. 1 root root   279 Nov 11 08:45 users2
    #在当面目录下查找所有普通文件，并用grep命令在搜索到的文件中查找hostname这个词
    /> find . -type f -print | xargs grep "hostname"
    #在整个系统中查找内存信息转储文件(core dump) ，然后把结果保存到/tmp/core.log 文件中。
    /> find / -name "core" -print | xargs echo "" >/tmp/core.log 　

    /> pgrep mysql | xargs kill -9　　#直接杀掉mysql的进程
    [1]+  Killed                  mysql




find pathname -options [-print -exec -ok ...]
#pathname: find命令所查找的目录路径。例如用.来表示当前目录，用/来表示系统根目录。
#-print： find命令将匹配的文件输出到标准输出。
#-exec： find命令对匹配的文件执行该参数所给出的shell命令。相应命令的形式为'command' {  } \;，注意{   }和\；之间的空格。
#-ok： 和-exec的作用相同，只不过以一种更为安全的模式来执行该参数所给出的shell命令，在执行每一个命令之前，都会给出提示，让用户来确定是否执行。
#
#-name
#
#按照文件名查找文件。
#
#-perm
#按照文件权限来查找文件。
#
#-prune
#使用这一选项可以使find命令不在当前指定的目录中查找，如果同时使用-depth选项，那么-prune将被find命令忽略。
#
#-user
#按照文件属主来查找文件。
#
#-group
#按照文件所属的组来查找文件。
#
#-mtime -n +n
#按照文件的更改时间来查找文件， - n表示文件更改时间距现在n天以内，+ n表示文件更改时间距现在n天以前。find命令还有-atime和-ctime 选项，但它们都和-m time选项。
#
#-nogroup
#查找无有效所属组的文件，即该文件所属的组在/etc/groups中不存在。
#
#-nouser
#查找无有效属主的文件，即该文件的属主在/etc/passwd中不存在。
#-newer file1 ! file2
#
#查找更改时间比文件file1新但比文件file2旧的文件。
#-type
#
#查找某一类型的文件，诸如：
#
#b - 块设备文件。
#d - 目录。
#c - 字符设备文件。
#p - 管道文件。
#l - 符号链接文件。
#f - 普通文件。
#
#-size n：[c] 查找文件长度为n块的文件，带有c时表示文件长度以字节计。
#-depth：在查找文件时，首先查找当前目录中的文件，然后再在其子目录中查找。
#-fstype：查找位于某一类型文件系统中的文件，这些文件系统类型通常可以在配置文件/etc/fstab中找到，该配置文件中包含了本系统中有关文件系统的信息。
#
#-mount：在查找文件时不跨越文件系统mount点。
#-follow：如果find命令遇到符号链接文件，就跟踪至链接所指向的文件。
#-cpio：对匹配的文件使用cpio命令，将这些文件备份到磁带设备中。
#
#  -amin n
#　　查找系统中最后N分钟访问的文件
#
#　　-atime n
#　　查找系统中最后n*24小时访问的文件
#
#　　-cmin n
#　　查找系统中最后N分钟被改变文件状态的文件
#
#　　-ctime n
#　　查找系统中最后n*24小时被改变文件状态的文件
#
#   　-mmin n
#　　查找系统中最后N分钟被改变文件数据的文件
#
#　　-mtime n
#　　查找系统中最后n*24小时被改变文件数据的文件
#
#
#4、使用exec或ok来执行shell命令
#
#使用find时，只要把想要的操作写在一个文件里，就可以用exec来配合find查找，很方便的
#
#在有些操作系统中只允许-exec选项执行诸如l s或ls -l这样的命令。大多数用户使用这一选项是为了查找旧文件并删除它们。建议在真正执行rm命令删除文件之前，最好先用ls命令看一下，确认它们是所要删除的文件。
#
#exec选项后面跟随着所要执行的命令或脚本，然后是一对儿{ }，一个空格和一个\，最后是一个分号。为了使用exec选项，必须要同时使用print选项。如果验证一下find命令，会发现该命令只输出从当前路径起的相对路径及文件名。
#
#例如：为了用ls -l命令列出所匹配到的文件，可以把ls -l命令放在find命令的-exec选项中
#
## find . -type f -exec ls -l {  } \;
#-rw-r--r--    1 root     root        34928 2003-02-25  ./conf/httpd.conf
#-rw-r--r--    1 root     root        12959 2003-02-25  ./conf/magic
#-rw-r--r--    1 root     root          180 2003-02-25  ./conf.d/README
#上面的例子中，find命令匹配到了当前目录下的所有普通文件，并在-exec选项中使用ls -l命令将它们列出。
#在/logs目录中查找更改时间在5日以前的文件并删除它们：
#
#$ find logs -type f -mtime +5 -exec rm {  } \;
#记住：在shell中用任何方式删除文件之前，应当先查看相应的文件，一定要小心！当使用诸如mv或rm命令时，可以使用-exec选项的安全模式。它将在对每个匹配到的文件进行操作之前提示你。
#
#在下面的例子中， find命令在当前目录中查找所有文件名以.LOG结尾、更改时间在5日以上的文件，并删除它们，只不过在删除之前先给出提示。
#
#$ find . -name "*.conf"  -mtime +5 -ok rm {  } \;
#< rm ... ./conf/httpd.conf > ? n
#按y键删除文件，按n键不删除。
#
#任何形式的命令都可以在-exec选项中使用。
#
#在下面的例子中我们使用grep命令。find命令首先匹配所有文件名为“ passwd*”的文件，例如passwd、passwd.old、passwd.bak，然后执行grep命令看看在这些文件中是否存在一个sam用户。
#
## find /etc -name "passwd*" -exec grep "sam" {  } \;
#sam:x:501:501::/usr/sam:/bin/bash
#
#二、find命令的例子；
#
#
#1、查找当前用户主目录下的所有文件：
#
#下面两种方法都可以使用
#
#$ find $HOME -print
#$ find ~ -print
#
#
#2、让当前目录中文件属主具有读、写权限，并且文件所属组的用户和其他用户具有读权限的文件；
#
#$ find . -type f -perm 644 -exec ls -l {  } \;
#
#3、为了查找系统中所有文件长度为0的普通文件，并列出它们的完整路径；
#
#$ find / -type f -size 0 -exec ls -l {  } \;
#
#4、查找/var/logs目录中更改时间在7日以前的普通文件，并在删除之前询问它们；
#
#$ find /var/logs -type f -mtime +7 -ok rm {  } \;
#
#5、为了查找系统中所有属于root组的文件；
#
#$find . -group root -exec ls -l {  } \;
#-rw-r--r--    1 root     root          595 10月 31 01:09 ./fie1
#
#6、find命令将删除当目录中访问时间在7日以来、含有数字后缀的admin.log文件。
#
#该命令只检查三位数字，所以相应文件的后缀不要超过999。先建几个admin.log*的文件 ，才能使用下面这个命令
#
#$ find . -name "admin.log[0-9][0-9][0-9]" -atime -7  -ok
#rm {  } \;
#< rm ... ./admin.log001 > ? n
#< rm ... ./admin.log002 > ? n
#< rm ... ./admin.log042 > ? n
#< rm ... ./admin.log942 > ? n
#
#7、为了查找当前文件系统中的所有目录并排序；
#
#$ find . -type d | sort
#
#8、为了查找系统中所有的rmt磁带设备；
#
#$ find /dev/rmt -print
#
#三、xargs
#
#xargs - build and execute command lines from standard input
#
#在使用find命令的-exec选项处理匹配到的文件时， find命令将所有匹配到的文件一起传递给exec执行。但有些系统对能够传递给exec的命令长度有限制，这样在find命令运行几分钟之后，就会出现 溢出错误。错误信息通常是“参数列太长”或“参数列溢出”。这就是xargs命令的用处所在，特别是与find命令一起使用。
#
#find命令把匹配到的文件传递给xargs命令，而xargs命令每次只获取一部分文件而不是全部，不像-exec选项那样。这样它可以先处理最先获取的一部分文件，然后是下一批，并如此继续下去。
#
#在有些系统中，使用-exec选项会为处理每一个匹配到的文件而发起一个相应的进程，并非将匹配到的文件全部作为参数一次执行；这样在有些情况下就会出现进程过多，系统性能下降的问题，因而效率不高；
#
#而使用xargs命令则只有一个进程。另外，在使用xargs命令时，究竟是一次获取所有的参数，还是分批取得参数，以及每一次获取参数的数目都会根据该命令的选项及系统内核中相应的可调参数来确定。
#
#来看看xargs命令是如何同find命令一起使用的，并给出一些例子。
#
#下面的例子查找系统中的每一个普通文件，然后使用xargs命令来测试它们分别属于哪类文件
#
##find . -type f -print | xargs file
#./.kde/Autostart/Autorun.desktop: UTF-8 Unicode English text
#./.kde/Autostart/.directory:      ISO-8859 text\
#......
#在整个系统中查找内存信息转储文件(core dump) ，然后把结果保存到/tmp/core.log 文件中：
#
#$ find / -name "core" -print | xargs echo "" >/tmp/core.log
#上面这个执行太慢，我改成在当前目录下查找
#
##find . -name "file*" -print | xargs echo "" > /temp/core.log
## cat /temp/core.log
#./file6
#在当前目录下查找所有用户具有读、写和执行权限的文件，并收回相应的写权限：
#
## ls -l
#drwxrwxrwx    2 sam      adm          4096 10月 30 20:14 file6
#-rwxrwxrwx    2 sam      adm             0 10月 31 01:01 http3.conf
#-rwxrwxrwx    2 sam      adm             0 10月 31 01:01 httpd.conf
#
## find . -perm -7 -print | xargs chmod o-w
## ls -l
#drwxrwxr-x    2 sam      adm          4096 10月 30 20:14 file6
#-rwxrwxr-x    2 sam      adm             0 10月 31 01:01 http3.conf
#-rwxrwxr-x    2 sam      adm             0 10月 31 01:01 httpd.conf
#用grep命令在所有的普通文件中搜索hostname这个词：
#
## find . -type f -print | xargs grep "hostname"
#./httpd1.conf:#     different IP addresses or hostnames and have them handled by the
#./httpd1.conf:# VirtualHost: If you want to maintain multiple domains/hostnames
#on your
#用grep命令在当前目录下的所有普通文件中搜索hostnames这个词：
#
## find . -name \* -type f -print | xargs grep "hostnames"
#./httpd1.conf:#     different IP addresses or hostnames and have them handled by the
#./httpd1.conf:# VirtualHost: If you want to maintain multiple domains/hostnames
#on your
#注意，在上面的例子中， \用来取消find命令中的*在shell中的特殊含义。
#
#find命令配合使用exec和xargs可以使用户对所匹配到的文件执行几乎所有的命令。
#
#
#四、find 命令的参数
#
#下面是find一些常用参数的例子，有用到的时候查查就行了，像上面前几个贴子，都用到了其中的的一些参数，也可以用man或查看论坛里其它贴子有find的命令手册
#
#
#1、使用name选项
#
#文件名选项是find命令最常用的选项，要么单独使用该选项，要么和其他选项一起使用。
#
#可以使用某种文件名模式来匹配文件，记住要用引号将文件名模式引起来。
#
#不管当前路径是什么，如果想要在自己的根目录$HOME中查找文件名符合*.txt的文件，使用~作为 'pathname'参数，波浪号~代表了你的$HOME目录。
#
#$ find ~ -name "*.txt" -print
#想要在当前目录及子目录中查找所有的‘ *.txt’文件，可以用：
#
#$ find . -name "*.txt" -print
#想要的当前目录及子目录中查找文件名以一个大写字母开头的文件，可以用：
#
#$ find . -name "[A-Z]*" -print
#想要在/etc目录中查找文件名以host开头的文件，可以用：
#
#$ find /etc -name "host*" -print
#想要查找$HOME目录中的文件，可以用：
#
#$ find ~ -name "*" -print 或find . -print
#要想让系统高负荷运行，就从根目录开始查找所有的文件。
#
#$ find / -name "*" -print
#如果想在当前目录查找文件名以两个小写字母开头，跟着是两个数字，最后是.txt的文件，下面的命令就能够返回名为ax37.txt的文件：
#
#$find . -name "[a-z][a-z][0--9][0--9].txt" -print
#
#2、用perm选项
#
#按照文件权限模式用-perm选项,按文件权限模式来查找文件的话。最好使用八进制的权限表示法。
#
#如在当前目录下查找文件权限位为755的文件，即文件属主可以读、写、执行，其他用户可以读、执行的文件，可以用：
#
#$ find . -perm 755 -print
#还有一种表达方法：在八进制数字前面要加一个横杠-，表示都匹配，如-007就相当于777，-006相当于666
#
## ls -l
#-rwxrwxr-x    2 sam      adm             0 10月 31 01:01 http3.conf
#-rw-rw-rw-    1 sam      adm         34890 10月 31 00:57 httpd1.conf
#-rwxrwxr-x    2 sam      adm             0 10月 31 01:01 httpd.conf
#drw-rw-rw-    2 gem      group        4096 10月 26 19:48 sam
#-rw-rw-rw-    1 root     root         2792 10月 31 20:19 temp
#
## find . -perm 006
## find . -perm -006
#./sam
#./httpd1.conf
#./temp
#-perm mode:文件许可正好符合mode
#
#-perm +mode:文件许可部分符合mode
#
#-perm -mode: 文件许可完全符合mode
#
#
#3、忽略某个目录
#
#如果在查找文件时希望忽略某个目录，因为你知道那个目录中没有你所要查找的文件，那么可以使用-prune选项来指出需要忽略的目录。在使用-prune选项时要当心，因为如果你同时使用了-depth选项，那么-prune选项就会被find命令忽略。
#
#如果希望在/apps目录下查找文件，但不希望在/apps/bin目录下查找，可以用：
#
#$ find /apps -path "/apps/bin" -prune -o -print
#
#4、使用find查找文件的时候怎么避开某个文件目录
#
#比如要在/usr/sam目录下查找不在dir1子目录之内的所有文件
#
#find /usr/sam -path "/usr/sam/dir1" -prune -o -print
#find [-path ..] [expression] 在路径列表的后面的是表达式
#-path "/usr/sam" -prune -o -print 是 -path "/usr/sam" -a -prune -o
#-print 的简写表达式按顺序求值, -a 和 -o 都是短路求值，与 shell 的 && 和 || 类似如果 -path "/usr/sam" 为真，则求值 -prune , -prune 返回真，与逻辑表达式为真；否则不求值 -prune，与逻辑表达式为假。如果 -path "/usr/sam" -a -prune 为假，则求值 -print ，-print返回真，或逻辑表达式为真；否则不求值 -print，或逻辑表达式为真。
#
#这个表达式组合特例可以用伪码写为
#
#if -path "/usr/sam"  then
#          -prune
#else
#          -print
#避开多个文件夹
#
#find /usr/sam \( -path /usr/sam/dir1 -o -path /usr/sam/file1 \) -prune -o -print
#圆括号表示表达式的结合。
#
#\ 表示引用，即指示 shell 不对后面的字符作特殊解释，而留给 find 命令去解释其意义。
#查找某一确定文件，-name等选项加在-o 之后
#
##find /usr/sam  \(-path /usr/sam/dir1 -o -path /usr/sam/file1 \) -prune -o -name "temp" -print
#
#5、使用user和nouser选项
#
#按文件属主查找文件，如在$HOME目录中查找文件属主为sam的文件，可以用：
#
#$ find ~ -user sam -print
#在/etc目录下查找文件属主为uucp的文件：
#
#$ find /etc -user uucp -print
#为了查找属主帐户已经被删除的文件，可以使用-nouser选项。这样就能够找到那些属主在/etc/passwd文件中没有有效帐户的文件。在使用-nouser选项时，不必给出用户名； find命令能够为你完成相应的工作。
#
#例如，希望在/home目录下查找所有的这类文件，可以用：
#
#$ find /home -nouser -print
#
#6、使用group和nogroup选项
#
#就像user和nouser选项一样，针对文件所属于的用户组， find命令也具有同样的选项，为了在/apps目录下查找属于gem用户组的文件，可以用：
#
#$ find /apps -group gem -print
#要查找没有有效所属用户组的所有文件，可以使用nogroup选项。下面的find命令从文件系统的根目录处查找这样的文件
#
#$ find / -nogroup-print
#
#7、按照更改时间或访问时间等查找文件
#
#如果希望按照更改时间来查找文件，可以使用mtime,atime或ctime选项。如果系统突然没有可用空间了，很有可能某一个文件的长度在此期间增长迅速，这时就可以用mtime选项来查找这样的文件。
#
#用减号-来限定更改时间在距今n日以内的文件，而用加号+来限定更改时间在距今n日以前的文件。
#
#希望在系统根目录下查找更改时间在5日以内的文件，可以用：
#
#$ find / -mtime -5 -print
#为了在/var/adm目录下查找更改时间在3日以前的文件，可以用：
#
#$ find /var/adm -mtime +3 -print
#
#8、查找比某个文件新或旧的文件
#
#如果希望查找更改时间比某个文件新但比另一个文件旧的所有文件，可以使用-newer选项。它的一般形式为：
#
#newest_file_name ! oldest_file_name
#其中，！是逻辑非符号。
#
#查找更改时间比文件sam新但比文件temp旧的文件：
#
#例：有两个文件
#
#-rw-r--r--    1 sam      adm             0 10月 31 01:07 fiel
#-rw-rw-rw-    1 sam      adm         34890 10月 31 00:57 httpd1.conf
#-rwxrwxr-x    2 sam      adm             0 10月 31 01:01 httpd.conf
#drw-rw-rw-    2 gem      group        4096 10月 26 19:48 sam
#-rw-rw-rw-    1 root     root         2792 10月 31 20:19 temp
#
## find -newer httpd1.conf  ! -newer temp -ls
#1077669    0 -rwxrwxr-x   2 sam      adm             0 10月 31 01:01 ./httpd.conf
#1077671    4 -rw-rw-rw-   1 root     root         2792 10月 31 20:19 ./temp
#1077673    0 -rw-r--r--   1 sam      adm             0 10月 31 01:07 ./fiel
#查找更改时间在比temp文件新的文件：
#
#$ find . -newer temp -print
#
#
#9、使用type选项
#
#在/etc目录下查找所有的目录，可以用：
#
#$ find /etc -type d -print
#在当前目录下查找除目录以外的所有类型的文件，可以用：
#
#$ find . ! -type d -print
#在/etc目录下查找所有的符号链接文件，可以用
#
#$ find /etc -type l -print
#
#10、使用size选项
#
#可以按照文件长度来查找文件，这里所指的文件长度既可以用块（block）来计量，也可以用字节来计量。以字节计量文件长度的表达形式为N c；以块计量文件长度只用数字表示即可。
#
#在按照文件长度查找文件时，一般使用这种以字节表示的文件长度，在查看文件系统的大小，因为这时使用块来计量更容易转换。
#在当前目录下查找文件长度大于1 M字节的文件：
#
#$ find . -size +1000000c -print
#在/home/apache目录下查找文件长度恰好为100字节的文件：
#
#$ find /home/apache -size 100c -print
#在当前目录下查找长度超过10块的文件（一块等于512字节）：
#
#$ find . -size +10 -print
#
#11、使用depth选项
#
#在使用find命令时，可能希望先匹配所有的文件，再在子目录中查找。使用depth选项就可以使find命令这样做。这样做的一个原因就是，当在使用find命令向磁带上备份文件系统时，希望首先备份所有的文件，其次再备份子目录中的文件。
#
#在下面的例子中， find命令从文件系统的根目录开始，查找一个名为CON.FILE的文件。
#
#它将首先匹配所有的文件然后再进入子目录中查找。
#
#$ find / -name "CON.FILE" -depth -print
#
#12、使用mount选项
#
#在当前的文件系统中查找文件（不进入其他文件系统），可以使用find命令的mount选项。
#
#从当前目录开始查找位于本文件系统中文件名以XC结尾的文件：
#
#$ find . -name "*.XC" -mount -print
#

几个面试官常问的Shell脚本编写


1）开头加解释器：#!/bin/bash



2）语法缩进，使用四个空格；多加注释说明。



3）命名建议规则：变量名大写、局部变量小写，函数名小写，名字体现出实际作用。



4）默认变量是全局的，在函数中变量local指定为局部变量，避免污染其他作用域。



5）有两个命令能帮助我调试脚本：set -e 遇到执行非0时退出脚本，set-x 打印执行过程。



6）写脚本一定先测试再到生产上。



1 获取随机字符串或数字


获取随机8位字符串：






获取随机8位数字：







cksum：打印CRC效验和统计字节



2 定义一个颜色输出字符串函数






function关键字定义一个函数，可加或不加。



3 批量创建用户





4 检查软件包是否安装





5 检查服务状态





6 检查主机存活状态


方法1： 将错误IP放到数组里面判断是否ping失败三次







方法2： 将错误次数放到FAIL_COUNT变量里面判断是否ping失败三次







方法3： 利用for循环将ping通就跳出循环继续，如果不跳出就会走到打印ping失败






7 监控CPU、内存和硬盘利用率


1）CPU



借助vmstat工具来分析CPU统计信息。







2）内存







3）硬盘






8 批量主机磁盘利用率监控


前提监控端和被监控端SSH免交互登录或者密钥登录。



写一个配置文件保存被监控主机SSH连接信息，文件内容格式：IP User Port






9 检查网站可用性


1）检查URL可用性







2）判断三次URL可用性



思路与上面检查主机存活状态一样。







本文写的Shell脚本例子都比较实用，在面试题中也经常出现，希望大家参考着多动手写写，不要复制粘贴就拿来跑，这样是学不会的！



=================
