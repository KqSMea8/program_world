DataX本身作为数据同步框架，将不同数据源的同步抽象为从源头数据源读取数据的Reader插件，以及向目标端写入数据的Writer插件，理论上DataX框架可以支持任意数据源类型的数据同步工作。同时DataX插件体系作为一套生态系统, 每接入一套新数据源该新加入的数据源即可实现和现有的数据源互通。

  1. DataX是离线数据同步工具，当需要迁移增量时，建议使用DTS，而不是DataX；

  2. 针对离线数据，当数据量很大或表非常多时，建议使用DataX。

  此时配置文件可编写脚本批量生成，详见ODPS数据迁移指南

  同时可以增大DataX本身的并发，并提高运行DataX的任务机数量，来达到高并发，从而实现快速迁移；





3.2 运行Datax任务

运行Datax任务很简单，只要执行python脚本即可。
python /home/admin/datax3/bin/datax.py ./json/table_1.json


建议真正跑任务时，可按照ODPS迁移指南中给出的批量工具的方式运行
即将所有的命令整理到一个sh文件中，最后再用nohup运行该文件。

cat /root/datax_tools/run_datax.sh
python /home/admin/datax3/bin/datax.py ./json/table_1.json > ./log/table_1.log
#实际运行
nohup /root/datax_tools/run_datax.sh > result.txt 2>&1 &

4.2 DataX本身的参数
  1. 可通过增加如下的core参数，去除掉DataX默认对速度的限制；
{
    "core":{
        "transport":{
            "channel":{
                "speed":{
                    "record":-1,
                    "byte":-1
                }
            }
        }
    },
    "job":{
        ...
    }
}

  2. 针对odpsreader有如下参数可以调节，注意并不是压缩速度就会提升，根据具体情况不同，速度还有可能下降，此项为试验项，需要具体情况具体分析。
...
“parameter”:{
    "isCompress":"true",
    ...
}

  3. 针对odpswrtier有如下参数可以调节，其中isCompress选项同reader，blockSizeInMB，为按块写入，后面的值为块的大小。该项值并不是越大越好，一般可以结合tunnel做综合考量。过分大的 blockSizeInMB 可能造成速度波动以及内存OOM。
...
“parameter”:{
    "isCompress":"true",
    "blockSizeInMB":128,
    ...
}

  4. 针对任务本身，有如下参数可以调节，注意如果调整了tunnel的数量，可能会造成JVM虚拟机崩溃，故需修改相应的参数；
"job": {
"setting": {
    "speed": {
        "channel": 32
    }
}

channel增大，为防止OOM，需要修改datax工具的datax.py文件。
如下所示，可根据任务机的实际配置，提升-Xms与-Xmx，来防止OOM。由此可以看出，tunnel并不是越大越好，过分大反而会影响宿主机的性能。
DEFAULT_JVM = "-Xms1g -Xmx1g -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=%s/log" % (DATAX_HOME)

4.3 从源端到任务机
  1. 可使用dataX从源端传输分区信息到本机，来观察速度。并和初始任务的速度进行比较，从而判断是哪一部分的原因造成的速度缓慢；具体配置文件如下：
"writer": {
    "name": "txtfilewriter",
    "parameter": {
        "path": "/root/log",
        "fileName": "test_src_result.csv",
        "writeMode": "truncate",
        "dateFormat": "yyyy-MM-dd"
    }
}

试验时，注意观察任务机本身的IO负载。
  2. 如果判断结果是源端的速度慢，可将任务机迁移至源端所在的集群，并再次运行任务，观察结果；
  3. 可尝试用odpscmd，直接从源端odps下载分区到本地，和上述结果作比较。如果odpscmd速度快，可尝试调整datax的相关参数；
odpscmd --config=odps_config.ini.src
> tunnel download -thread 20 project_name.table_name/dt='20150101' log.txt;

上述是通过tunnel使用20线程下载数据到本地。
  4. 如果是在专有云环境可尝试指定源端的tunnel server的ip进行测试，从而排除从域名到负载均衡部分的网络造成的影响。源端的tunnel server的ip需要咨询云端管理员。
 ...
“parameter”:{
    "tunnelServer":"http://src_tunnel_server_ip",
    ...
}

注意此步骤可选择负载较低的tunnel_server。
  5. 观察源端tunnel server的负载情况，尤其是磁盘IO和网卡的负载，从而判断是否为tunnel sever负载过高造成了资源瓶颈。
  6. 观察源端的表结果，当有多个分区键或列过多时，都有可能造成传输的性能下降，此时可考虑换一张表进行测试，以排除表结构等问题造成的影响。
4.4 从任务机到目的端
  1. 可使用datax从任务机传输文件分区文件到目的端，来观察速度。并和初始任务的速度进行比较，从而判断是哪一部分的原因造成的速度缓慢；具体配置文件如下：
"reader": {
    "name": "txtfilereader",
    "parameter": {
        "path": ["/home/haiwei.luo/case00/data"],
        "encoding": "UTF-8",
        "column": [
            {
                "index": 0,
                "type": "long"
            },
            {
                "index": 1,
                "type": "boolean"
            },
            {
                "index": 2,
                "type": "double"
            },
            {
                "index": 3,
                "type": "string"
            },
            {
                "index": 4,
                "type": "date",
                "format": "yyyy.MM.dd"
            }
        ],
        "fieldDelimiter": ","
    }
},

  2. 如果判断结果是源端的速度慢，可将任务机迁移至源端所在的集群，并再次运行任务，观察结果；
  3. 可尝试用odpscmd，直接从本地上传分区到目的端，和上述结果作比较。如果odpscmd速度快，可尝试调整datax的相关参数；
odpscmd --config=odps_config.ini.src
> tunnel upload ./log.txt mingxuantest/pt='20150101';

上述log.txt可为上一步tunnel下载的文件，或自行编写。
  4. 如果是在专有云环境可尝试指定指定端的tunnel server的ip进行测试，从而排除从域名到负载均衡部分的网络造成的影响。源端的tunnel server的ip需要咨询云端管理员。
 ...
“parameter”:{
    "tunnelServer":"http://dst_tunnel_server_ip",
    ...
}

注意此步骤可选择负载较低的tunnel_server。
  5. 观察源端tunnel server的负载情况，尤其是磁盘IO和网卡的负载，从而判断是否为tunnel sever负载过高造成了资源瓶颈。
4.5 综合
  1. 通过对DataX本身参数，源端到任务机、任务机到目的端的网络、负载等情况综合考量，进行针对各个部分的优化；
  2. 同时，可在多台机器上部署DataX，将任务平均分配到多台机器上并发运行，来提高速度；


##############



利用datax批量配置工具来生成对应的脚本和json文件。

进行环境的准备，本步骤需要在迁移机上安装odpscmd与datax工具，

其中datax工具和datax批量工具需要python2.6及以上的运行环境；

在datax批量工具的config.ini中进行相关配置，包括源与目的ODPS的accessID与key、odps及tunnel的endpoint、odpscmd与datax的路径等信息；

在tables.ini中填写调试用到的表列表；

运行python datax_tools.py生成对应的脚本和json配置文件；

检查脚本与json配置文件；

运行run_datax.py脚本，批量顺序执行datax任务；

运行check_datax.py脚本，进行条数的检查；



3.2.2.1 批量配置工具

配置源与目的端的基础信息；

读取并校验源与目的端的表结构和分区信息；

根据校验结果，生成DataX所需的json文件；

生成顺序运行Datax迁移命令的脚本文件；

利用select count(*)的方式进行条数检查;


################


（1）、Job基本配置

Job基本配置定义了一个Job基础的、框架级别的配置信息，包括：

{
  "job": {
    "content": [
      {
        "reader": {
          "name": "",
          "parameter": {}
        },
        "writer": {
          "name": "",
          "parameter": {}
        }
      }
    ],
    "setting": {
      "speed": {},
      "errorLimit": {}
    }
  }
}
（2） Job Setting配置

{
  "job": {
    "content": [
      {
        "reader": {
          "name": "",
          "parameter": {}
        },
        "writer": {
          "name": "",
          "parameter": {}
        }
      }
    ],
    "setting": {
      "speed": {
        "channel": 1,
        "byte": 104857600
      },
      "errorLimit": {
        "record": 10,
        "percentage": 0.05
      }
    }
  }
}
job.setting.speed(流量控制)
Job支持用户对速度的自定义控制，channel的值可以控制同步时的并发数，byte的值可以控制同步时的速度

job.setting.errorLimit(脏数据控制)
Job支持用户对于脏数据的自定义监控和告警，包括对脏数据最大记录数阈值（record值）或者脏数据占比阈值（percentage值），当Job传输过程出现的脏数据大于用户指定的数量/百分比，DataX Job报错退出。


==============
{
    "job": {
           "content":[
                {
                    "reader":{
                        "name":"odpsreader",
                        "parameter":{
                            "accessId":"<accessID>",
                            "accessKey":"******************************",
                            "column":[
                                "col_1",
                                "col_2"
                            ],
                            "odpsServer":"http://service.odps.aliyun-inc.com/api",
                            "partition":[
                                "dt=20160524"
                            ],
                            "project":"src_project_name",
                            "splitMode":"record",
                            "table":"table_name_1"
                        }
                    },
                    "writer":{
                        "name":"odpswriter",
                        "parameter":{
                            "accessId":"<accessId>",
                            "accessKey":"******************************",
                            "accountType":"aliyun",
                            "column":[
                                "ci_name",
                                "geohash"
                            ],
                            "odpsServer":"http://service.odps.xxx.com/api",
                            "partition":"dt=20160524",
                            "project":"dst_project_name",
                            "table":"nb_tab_http"
                        }
                    }
                }
            ],
        "setting":{
            "speed":{
                "channel":20
            }
        }
    }
}

  1. 整个配置文件是一个job的描述；
  2. job下面有两个配置项，content和setting，其中content用来描述该任务的源和目的端的信息，setting用来描述任务本身的信息；
  3. content又分为两部分，reader和writer，分别用来描述源端和目的端的信息；
  4. 本例中由于源和目的都是ODPS，所以类型为odpsreader和odpswriter。均包含accessId，accessKey与odpsServer的api地址。
  5. 同时预迁移表的project，table以及列名和分区信息都要一一填写清楚。
  6. setting中的speed项表示同时起20个并发去跑该任务。

###########################################


从MySQL读取数据 写入ODPS


第一步、创建作业的配置文件（json格式）
可以通过命令查看配置模板： python datax.py -r {YOUR_READER} -w {YOUR_WRITER}

$ cd  {YOUR_DATAX_HOME}/bin
$  python datax.py -r mysqlreader -w odpswriter
    DataX (DATAX-OPENSOURCE-1.0), From Alibaba !
Copyright (C) 2010-2015, Alibaba Group. All Rights Reserved.


Please refer to the mysqlreader document:
     https://github.com/alibaba/DataX/blob/master/mysqlreader/doc/mysqlreader.md

Please refer to the odpswriter document:
     https://github.com/alibaba/DataX/blob/master/odpswriter/doc/odpswriter.md

Please save the following configuration as a json file and  use
     python {DATAX_HOME}/bin/datax.py {JSON_FILE_NAME}.json
to run the job.

{
    "job": {
        "content": [
            {
                "reader": {
                    "name": "mysqlreader",
                    "parameter": {
                        "column": [],
                        "connection": [
                            {
                                "jdbcUrl": [],
                                "table": []
                            }
                        ],
                        "password": "",
                        "username": "",
                        "where": ""
                    }
                },
                "writer": {
                    "name": "odpswriter",
                    "parameter": {
                        "accessId": "",
                        "accessKey": "",
                        "column": [],
                        "odpsServer": "",
                        "partition": "",
                        "project": "",
                        "table": "",
                        "truncate": true
                    }
                }
            }
        ],
        "setting": {
            "speed": {
                "channel": ""
            }
        }
    }
}



第二步、根据配置文件模板填写相关选项

命令打印里面包含对应reader、writer的文档地址，以及配置json样例，根据json样例填空完成配置即可。

根据模板配置json文件(mysql2odps.json)如下：

{
    "job": {
        "content": [
            {
                "reader": {
                    "name": "mysqlreader",
                    "parameter": {
                        "username": "****",
                        "password": "****",
                        "column": ["id","age","name"],
                        "connection": [
                            {
                                "table": [
                                    "test_table"
                                ],
                                "jdbcUrl": [
                                    "jdbc:mysql://127.0.0.1:3306/test"
                                ]
                            }
                        ]
                    }
                },
                "writer": {
                    "name": "odpswriter",
                    "parameter": {
                        "accessId": "****",
                        "accessKey": "****",
                        "column": ["id","age","name"],
                        "odpsServer": "http://service.odps.aliyun.com/api",
                        "partition": "pt='datax_test'",
                        "project": "datax_opensource",
                        "table": "datax_opensource_test",
                        "truncate": true
                    }
                }
            }
        ],
        "setting": {
            "speed": {
                "channel": 1
            }
        }
    }
}


第三步：启动DataX

$ cd {YOUR_DATAX_DIR_BIN}
$ python datax.py ./mysql2odps.json
同步结束，显示日志如下：

...
2015-12-17 11:20:25.263 [job-0] INFO  JobContainer -
任务启动时刻                    : 2015-12-17 11:20:15
任务结束时刻                    : 2015-12-17 11:20:25
任务总计耗时                    :                 10s
任务平均流量                    :              205B/s
记录写入速度                    :              5rec/s
读出记录总数                    :                  50
读写失败总数                    :                   0
如果您在试用Windows发现datax打印乱码，请参考：Windows乱码问题解决


###########################################


配置定时任务（Linux环境）：

从MySQL读取数据 写入ODPS，通过crontab命令实现

前置条件：安装crond服务,并已启动

#查看crond服务是否启动，出现以下日志表示已启动
$/sbin/service crond status
 crond (pid  30742) is running...


第一步：创建作业的配置文件（json格式） 参考上节内容。这里假设已配置好MySQL到ODPS的配置文件mysql2odps.json



第二步：列出列出crontab文件，命令： crontab -l
（1）若出现以下日志，表示当前用户没有定时任务，用户需要新建crontab文件，并提交crontab文件，参考第三步。

$crontab -l
 no crontab for xxx
（2）若出现以下日志，表示当前用户已经有正在运行的定时任务，用户只需用命令crontab -e 来编辑crontab文件，参考第四步。 shell $ crontab -l 0,10,20,35,44,50 * * * * python /home/admin/datax3/bin/datax.py /home/admin/mysql2odps.json >>/home/hanfa.shf/log.`date +\%Y\%m\%d\%H\%M\%S` 2>&1

第三步：若当前用户没有定时任务（之前从未创建过crontab任务)
（1）创建一个新的crontab文件，如取名crondatax
示例1：每天13点5分进行同步作业，并把运行日志输出到目录/home/hanfa.shf/下log.运行时间 文件中,如定时运行是在2016-3-26 13:10:13运行的，产生的日志文件名为：log.20160326131023


$ vim crondatax
#输入以下内容
5  13 * * *  python /home/admin/datax3/bin/datax.py /home/admin/mysql2odps.json  >>/home/hanfa.shf/log.`date +\%Y\%m\%d\%H\%M\%S`  2>&1


#/home/admin/datax3/bin/datax.py 表示你安装的DataX datax.py所在目录（请替换为您真实的绝对路径目录）；
#/home/admin/mysql2odps.json  表示作业的配置文件目录（请替换为您真实的绝对路径目录）；
#/home/hanfa.shf/log.`date +\%Y\%m\%d\%H\%M\%S` 表示日志输出位置，并以log.当前时间 命名（请替换为您真实的绝对路径目录）


（2）提交你刚刚创建的crontab文件 shell $ crontab crondatax #crondatax 你创建的crontab文件名


（3）重启crontab服务 shell $ sudo /etc/init.d/crond restart Stopping crond: [ OK ] Starting crond: [ OK ] （4）在13点5分过后，在日志目录会看到对应的日文件 shell $ ls -al /home/hanfa.shf/ -rw-r--r-- 1 hanfa.shf users 12062 Mar 26 13:05 log.20160326130501

第四步：若当前用户已有定时任务（想继续增加定时任务）
（1）编辑已有crontab文件
示例2：每10分钟运行一次同步任务,并把运行日志输出到目录/home/hanfa.shf/下log.运行时间 文件中，如定时运行是在2016-3-26 13:10:13运行的，产生的日志文件名为：log.20160326131023

$ crontab -e

#会进入已有crontab文件编辑界面，继续增加定时任务即可，

本示例增加以下内容,并保存
0,10,20,30,40,50 * * * *  python /home/admin/datax3/bin/datax.py /home/admin/mysql2odps.json  >>/home/hanfa.shf/log.`date +\%Y\%m\%d\%H\%M\%S`  2>&1


（2）重启crontab服务

```shell
$ sudo /etc/init.d/crond restart Stopping crond: [ OK ] Starting crond: [ OK ] ```


（3）用crontab -l 命令检查是否添加成功
 $ crontab -l

5  13 * * *  python /home/admin/datax3/bin/datax.py /home/admin/mysql2odps.json  >>/home/hanfa.shf/log.`date +\%Y\%m\%d\%H\%M\%S`  2>&1
0,10,20,30,40,50 * * * *  python /home/admin/datax3/bin/datax.py /home/admin/mysql2odps.json  >>/home/hanfa.shf/log.`date +\%Y\%m\%d\%H\%M\%S`  2>&1



yum install crontabs
/sbin/service crond start //启动服务
/sbin/service crond stop //关闭服务
/sbin/service crond restart //重启服务
/sbin/service crond reload //重新载入配置
/sbin/chkconfig --level 35 crond on


