CentOS服务器上搭建Gitlab安装步骤、中文汉化详细步骤、日常管理以及异常故障排查


一， 服务器快速搭建gitlab方法

可以参考gitlab中文社区 的教程
centos7安装gitlab：https://www.gitlab.cc/downloads/#centos7
centos6安装gitlab：https://www.gitlab.cc/downloads/#centos6
如下方法按照官网来操作，手工安装过于麻烦。测试机器：阿里云centos6.8机器。
1. 安装配置依赖项

如想使用Postfix来发送邮件,在安装期间请选择’Internet Site’. 您也可以用sendmai或者 配置SMTP服务 并 使用SMTP发送邮件.
在 Centos 6 系统上, 下面的命令将在系统防火墙里面开放HTTP和SSH端口.

sudo yum install curl openssh-server openssh-clients postfix cronie -y
sudo service postfix start
sudo chkconfig postfix on
sudo lokkit -s http -s ssh

2. 添加GitLab仓库,并安装到服务器上

curl -sS http://packages.gitlab.cc/install/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce
如果你不习惯使用命令管道的安装方式, 你可以在这里下载 安装脚本 或者 手动下载您使用的系统相应的安装包(RPM/Deb) 然后安装

wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-XXX.rpm
rpm -ivh gitlab-ce-XXX.rpm

说明：个人平时喜欢采用如上方式的rpm安装
centos （内核7.x）https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7
centos （内核6.x）https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el6，选择需要的版本进行安装。

老版本用习惯了，用的是一种情怀，有些功能新版本不是很喜欢用，请根据自己个人喜好来安装。

3. 启动GitLab
sudo gitlab-ctl reconfigure

下边就可以访问了：
1
重置下密码。登录效果如下：
1

注意事项以及异常故障排查：
1，按照该方式，我安装了一个确实没问题，只不过是英文版。没有经过汉化（汉化请参考后边的教程）。


2，默认安装登录需要重置root密码。

可以自己单独设置一个复杂密码后登录。

3，gitlab本身采用80端口，如安装前服务器有启用80，安装完访问会报错。需更改gitlab的默认端口。
修改vim /etc/gitlab/gitlab.rb：

external_url 'http://localhost:90'
如果就想用80端口，那没问题。如果更改了端口，后边可以自行调整nginx配置文件进行nginx反向代理设置。


4，这里可以绑定自己的gitlab的域名或者公网、内网IP替换localhost进行公网访问，具体根据自己的实际情况。安全起见，一般会将gitlab部署于内网。具体部署到哪里，请根据自己的实际情况来定。（基于安全原因，这里不建议设置公网IP进行暴露，可以通过nginx设置IP绑定进行return或者其他规则进行IP回避访问。）
本站测试gitlab地址域名为：gitlab.21yunwei.com

5，unicorn本身采用8080端口，如果你那里没有8080使用，可以后边不用修改了。如安装前服务器有启用8080，安装完访问会报错。需更改unicorn的默认端口：
修改 /etc/gitlab/gitlab.rb：

unicorn['listen'] = '127.0.0.1'
unicorn['port'] = 3000
5，每次重新配置，都需要执行sudo gitlab-ctl reconfigure  使之生效。
6，日志位置：/var/log/gitlab 可以进去查看访问日志以及报错日志等，供访问查看以及异常排查。
gitlab-ctl tail #查看所有日志
gitlab-ctl tail nginx/gitlab_access.log #查看nginx访问日志

二，gitlab中文汉化【如不清楚gitlab版本以及git，请不要操作，否则gitlab瘫痪！建议运维人员或者对gitlab比较熟悉的人操作】
（1）centos 6.x汉化步骤。【centos 7.x请查看（2）步骤）】

1，克隆gitLab汉化仓库
首先我们要确认下当前我们gitlab的版本，查看版本命令如下：

[root@21yunwei src]# cat /opt/gitlab/embedded/service/gitlab-rails/VERSION
8.8.5
比如我安装的gitlab版本是8.8.5,那么我就需要下载这个版本的补丁。
克隆汉化仓库地址（这个比较全，可以自己切换对应分支）：

git clone https://gitlab.com/larryli/gitlab.git
下载完以后进入gitlab查看补丁版本：

[root@21yunwei src]# cat  gitlab/VERSION
8.8.5
版本正确，后边可以正式操作了。
PS：有很多朋友安装了或旧或老版本，不同版本的地址可以到https://gitlab.com/larryli/gitlab/tags 进行下载，这里的版本很全，基本可以满足下载使用，仅仅版本不一样而已，其他后续操作都是一样的。

2，汉化操作
停止当前gitlab运行。

gitlab-ctl stop
执行如下操作：

cd /usr/local/src/gitlab  #说明：这个就是刚才我们git clone以后的目录，需要进入到这个仓库进行操作。
git diff origin/8-8-stable origin/8-8-zh > /tmp/8.8.diff
说明：8-8-stable是英文稳定版，8-8-zh是中文版，两个仓库git diff结果便是汉化补丁了。

3，应用汉化。

cd /opt/gitlab/embedded/service/gitlab-rails
git apply /tmp/8.8.diff
启动gitlab：

gitlab-ctl start
汉化效果(演示地址gitlab.21yunwei.com)：
1
（2）centos 7.x汉化步骤。
1，下载补丁。这个没有采用larryli的，而是另外一个安装包。larrili测试在centos7有报错。

git clone https://git.oschina.net/qiai365/gitlab-L-zh.git
2，切换分支。这里centos7测试的是8.5.4低版本，需要进行切换。

cd gitlab-L-zh
git checkout -b 8-5-zh origin/8-5-zh
cp -r /opt/gitlab/embedded/service/gitlab-rails{,.ori}
3，汉化操作
首先停止gitlab：

gitlab-ctl stop
汉化操作：

yes|cp -rf ../gitlab-L-zh/* /opt/gitlab/embedded/service/gitlab-rails/
4，启动，查看效果

gitlab-ctl start
1

低版本gitlab默认用户名和密码：root/5iveL!fe

三，日常管理

gitlab-ctl start|stop|status|restart
比如查看状态：

[root@21yunwei gitlab]# gitlab-ctl status
run: gitlab-workhorse: (pid 19922) 665s; run: log: (pid 19159) 725s
run: logrotate: (pid 19179) 723s; run: log: (pid 19178) 723s
run: nginx: (pid 19166) 724s; run: log: (pid 19165) 724s
run: postgresql: (pid 19026) 760s; run: log: (pid 19025) 760s
run: redis: (pid 18943) 766s; run: log: (pid 18942) 766s
run: sidekiq: (pid 19149) 732s; run: log: (pid 19148) 732s
run: unicorn: (pid 20257) 642s; run: log: (pid 19116) 734s

============================================================================================================

Gitlab安装使用及汉化配置
2017年05月22日 16:51:31
阅读数：10180


一、GitLab简介
GitHub是2008年由Ruby on Rails编写而成，与业界闻名的Github类似;但要将代码上传到GitHub上面，而且将项目设为私有还要收费。GitLab 是一个用于仓库管理系统的开源项目，使用Git作为代码管理工具，可通过Web界面进行访问公开的或者私人项目，非常适合在团队内部使用。

在gitlab中有三个版本，分别是CE（社区版）、EE（企业版）、OM（RPM包完整版，里面包括nginx、redis等其它软件，比较大）。这里的编译安装版，是指CE版的源码安装

官网https://docs.gitlab.com/

这里呢建议大家使用rpm安装

1.1 Gitlab提供的功能
1.     代码托管服务

2.     访问权限控制

3.     问题跟踪，bug的记录和讨论

4.     代码审查，可以查看、评论代码

5.     社区版基于 MIT License开源完全免费

1.2 Gitlab(Github)和Git区别
Github和Git是两回事。

Git是版本控制系统，Github是在线的基于Git的代码托管服务。

1.3 Github PK Sourceforge
为什么现在Github这么火，以至于世界顶级公司和项目的源码很多都托管在Github上

Why？

1.     颜值高

2.     简洁大方



2011年，Github已经取代Sourceforge，成为最活跃的代码交流社区。这意味着在Open SourceCommunity（开源社区），Git取代了SVN已经成为事实。

1.3.1 Github界面
1.3.2 Sourceforge界面
1.4 搭建私有Git服务的优势
公司的项目，因为商业层面的原因，需要把代码托管到自有的服务器上，并且服务器很有可能是放在企业内网中，不对公网开放。

出于安全性的考虑，暂时没有使用国内的Git服务平台的计划。

GitHub和BitBucket，GitLab，由于服务商是在国外，受地域的影响，因此在网络访问上会有延迟。

现有的服务商，对于免费的套餐都有一定的限制，比如GitHub只允许建立免费的开源repository，不允许建立私有的仓库。BitBucket允许建立无限制的私有项目，不过对于项目中参与的开发人员是有人数限制的。当团队中开发者规模达到一定数量后，需要付费购买相应的套餐。

二、Gitlab安装
2.1 环境配置
硬件：

redhat-7.x系列_x86_64

Mem建议至少2G

软件：

       gitlab-ce.x86_64 0:8.8.0-ce

       git-2.11.0

       ruby2.1(至少是2.1)

server

client

192.168.201.148

192.168.201.130(作为测试端)

本次采用Omnibus 安装方式

2.2 gitlab环境要求
#系统层
Ubuntu

Debian

CentOS

Red Hat Enterprise Linux (please use the CentOSpackages and instructions)

Scientific Linux (please use the CentOSpackages and instructions)

Oracle Linux (please use the CentOS packagesand instructions)

不支持win

#Ruby versions
GitLab需要Ruby（MRI）2.3。支持低于2.3（2.1，2.2）的Ruby版本将停止与GitLab 8.13

#硬件要求
必要的硬盘驱动器空间很大程度上取决于您要存储在GitLab中的存档的大小，但是根据经验，您应该至少拥有与所有存档组合相同的可用空间。

       如果你希望在将来考虑使用LVM来安装硬盘驱动器空间方面具有灵活性，那么您可以在需要时添加更多的硬盘驱动器。

       除本地硬盘驱动器外，你还可以安装支持网络文件系统（NFS）协议的卷。此卷可能位于文件服务器，网络连接存储（NAS）设备，存储区域网络（SAN）或Amazon Web Services（AWS）弹性块存储（EBS）卷上。

       如果你有足够的RAM内存和最近的CPU，则GitLab的速度主要受硬盘搜索时间的限制。快速驱动（7200 RPM或更高）或固态硬盘（SSD）将提高GitLab的响应速度

#CPU
1核心的CPU，基本上可以满足需求，大概支撑100个左右的用户，不过在运行GitLab网站的同时，还需要运行多个worker以及后台job，显得有点捉襟见肘了。

两核心的CPU是推荐的配置，大概能支撑500个用户.

4核心的CPU能支撑 2,000 个用户.

8核心的CPU能支撑 5,000 个用户.

16核心的CPU能支撑 10,000 个用户.

32核心的CPU能支撑 20,000 个用户.

64核心的CPU能支持多达 40,000 个用户.

#Memory
你需要至少4GB的可寻址内存（RAM交换）来安装和使用GitLab！操作系统和任何其他正在运行的应用程序也将使用内存，因此请记住，在运行GitLab之前，您至少需要4GB的可用空间。使用更少的内存GitLab将在重新配置运行期间给出奇怪的错误，并在使用过程中发生500个错误.

1GBRAM + 3GB of swap is the absolute minimum but we strongly adviseagainst this amount of memory. See the unicorn worker section belowfor more advice.

2GBRAM + 2GB swap supports up to 100 users but it will be very slow

4GBRAM isthe recommended memory size for all installations and supportsup to 100 users

8GBRAM supports up to 1,000 users

16GBRAM supports up to 2,000 users

32GBRAM supports up to 4,000 users

64GBRAM supports up to 8,000 users

128GBRAM supports up to 16,000 users

256GBRAM supports up to 32,000 users

建议服务器上至少有2GB的交换，即使您目前拥有足够的可用RAM。如果可用的内存更改，交换将有助于减少错误发生的机会。

#Unicorn Workers(进程数)
可以增加独角兽工人的数量，这通常有助于减少应用程序的响应时间，并增加处理并行请求的能力.

对于大多数情况，我们建议使用：CPU内核1 =独角兽工人。所以对于一个有2个核心的机器，3个独角兽工人是理想的。

对于所有拥有2GB及以上的机器，我们建议至少三名独角兽工人。如果您有1GB机器，我们建议只配置两个Unicorn工作人员以防止过度的交换.

#Database
PostgreSQL

MySQL/MariaDB

强烈推荐使用PostgreSQL而不是MySQL/ MariaDB，因为GitLab的所有功能都不能与MySQL/ MariaDB一起使用。例如，MySQL没有正确的功能来以有效的方式支持嵌套组.

运行数据库的服务器应至少有5-10 GB的可用存储空间，尽管具体要求取决于GitLab安装的大小

#PostgreSQL要求
从GitLab 9.0起，PostgreSQL 9.2或更新版本是必需的，不支持早期版本。

#Redis and Sidekiq
Redis存储所有用户会话和后台任务队列。Redis的存储要求最低，每个用户大约25kB。

Sidekiq使用多线程进程处理后台作业。这个过程从整个Rails堆栈（200MB）开始，但是由于内存泄漏，它可以随着时间的推移而增长。在非常活跃的服务器（10,000个活跃用户）上，Sidekiq进程可以使用1GB的内存。

#Prometheus and its exporters
从Omnibus GitLab 9.0开始，默认情况下，Prometheus及其相关出口商启用，可以轻松，深入地监控GitLab。这些进程将使用大约200MB的内存，具有默认设置。这个还可以监控k8s

#Node exporter
节点导出器允许您测量各种机器资源，如内存，磁盘和CPU利用率。默认端口9100

#Redis exporter
       Redis出口商允许您测量各种Redis指标。

#Postgres exporter
Postgres导出器允许您测量各种PostgreSQL度量。

#GitLab monitor exporter
GitLab监视器导出器允许您测量各种GitLab指标。

#Supported web browsers
支持Firefox，Chrome /Chromium，Safari和Microsoft浏览器（Microsoft Edge和Internet Explorer 11）的当前和之前的主要版本。

2.3 安装
1、关闭SELinux
#下面的命令实现永久关闭SELinux

[root@git ~]# sed -i's/^SELINUX=.*/#&/;s/^SELINUXTYPE=.*/#&/;/SELINUX=.*/aSELINUX=disabled' /etc/sysconfig/selinux

#下面的命令实现临时关闭SELinux

[root@git ~]# setenforce 0

setenforce: SELinux is disabled

#永久修改下主机名，需要重启系统之后生效

Redhat6中修改

[root@git ~]# vi /etc/sysconfig/network

NETWORKING=yes

HOSTNAME=git.server.com #修改成你自己的主机名

Redhat7中修改

[root@noede1 ~]# vi /etc/hostname

gitlab.server.com

#永久修改

[root@git ~]#hostnamectl set-hostname gitlab.server.com

#添加域名

[root@git ~]#cat /etc/hosts

192.168.201.131 gitlab.server.com

2、关闭firewall
#临时关闭

[root@git yum.repos.d]# iptables -F

或者

[root@git gitlab_pack]# systemctl stopfirewalld.service

#永久关闭，需要下次重启系统之后生效

[root@git gitlab_pack]# systemctl disablefirewalld.service

Removed symlink/etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.

Removed symlink/etc/systemd/system/basic.target.wants/firewalld.service.

#线上开启防火墙

[root@gitlab ~]# firewall-cmd --permanent--add-service=http

success

[root@gitlab ~]# firewall-cmd --permanent--add-service=https

Success

[root@gitlab ~]# firewall-cmd --reload

success

#重新加载配置

[root@gitlab ~]#systemctl reload firewalld

3、同步时间
[root@git yum.repos.d]# ntpdate time.nist.gov

10 Apr 11:00:04 ntpdate[40122]: step timeserver 216.229.0.179 offset 53747.856066 sec

4、配置gitlab-ce yum源
[root@git yum.repos.d]# cat gitlab.repo

[gitlab-ce]

name=gitlab-ce

baseurl=http://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7

repo_gpgcheck=0

gpgcheck=0

enabled=1

gpgkey=https://packages.gitlab.com/gpg.key

注解：

如果想要在centos6系列上安装，只需把el7修改成el6

5、Gitlab安装方式
Gitlab两种安装方式
编译安装
优点：可定制性强。数据库既可以选择MySQL,也可以选择PostgreSQL;服务器既可以选择Apache，也可以选择Nginx。

缺点：国外的源不稳定，被墙时，依赖软件包难以下载。配置流程繁琐、复杂，容易出现各种各样的问题。依赖关系多，不容易管理，卸载GitLab相对麻烦。

rpm包安装
优点：安装过程简单，安装速度快。采用rpm包安装方式，安装的软件包便于管理。

缺点：数据库默认采用PostgreSQL，服务器默认采用Nginx，不容易定制。

gitlab安装
1，下载
https://about.gitlab.com/installation/

2，安装
#官方地址

https://about.gitlab.com/downloads/#centos7

#如果想查看rpm中内容，默认安装的位置

[root@gitlab gitlab_pack]# rpm2cpiogitlab-ce-8.8.0-ce.0.el6.x86_64.rpm | cpio -ivd



[root@git yum.repos.d]# yum install curlopenssh-server openssh-clients postfix -y

[root@git yum.repos.d]# yum install gitlab-ce-8.8.0-y

#这里为了节省时间，直接rpm安装

[root@git gitlab_pack]# rpm -ivhgitlab-ce-8.8.0-ce.0.el6.x86_64.rpm

Preparing...                         ################################# [100%]

Updating / installing...

  1:gitlab-ce-8.8.0-ce.0.el6        ################################# [100%]

gitlab: Thank you for installing GitLab!

gitlab: To configure and start GitLab, RUN THEFOLLOWING COMMAND:



sudo gitlab-ctl reconfigure



gitlab: GitLab should be reachable athttp://localhost

gitlab: Otherwise configure GitLab for yoursystem by editing /etc/gitlab/gitlab.rb file

gitlab: And running reconfigure again.

gitlab:

gitlab: For a comprehensive list ofconfiguration options please see the Omnibus GitLab readme

gitlab:https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md

gitlab:

It looks like GitLab has not been configuredyet; skipping the upgrade script.

至此gitlab安装成功

注意：

       rpm 安装Gitlab的默认位置在/opt下

6、修改下配置文件
#修改url，供外部访问

[root@gitlab ~]# vi /etc/gitlab/gitlab.rb

external_url'http://gitlab.server.com'

external_url 修改成自己的ip或者域名

#修改配置文件之后，需要重新是配置文件生效下，初始化下

[root@gitlab ~]#gitlab-ctl reconfigure #这里会花费一定的时间(1-10min)，如果这里内存小，将会花费大量时间

Recipe: gitlab::gitlab-rails

  *execute[clear the gitlab-rails cache] action run

    -execute /opt/gitlab/bin/gitlab-rake cache:clear

  *execute[clear the gitlab-rails cache] action run

    -execute /opt/gitlab/bin/gitlab-rake cache:clear

Recipe: gitlab::unicorn

  *service[unicorn] action restart

    -restart service service[unicorn]

Recipe: gitlab::redis

  *ruby_block[reload redis svlogd configuration] action create

    -execute the ruby block reload redis svlogd configuration

Recipe: gitlab::postgresql

  *ruby_block[reload postgresql svlogd configuration] action create

    -execute the ruby block reload postgresql svlogd configuration

Recipe: gitlab::unicorn

  *ruby_block[reload unicorn svlogd configuration] action create

    -execute the ruby block reload unicorn svlogd configuration

Recipe: gitlab::sidekiq

  *ruby_block[reload sidekiq svlogd configuration] action create

    -execute the ruby block reload sidekiq svlogd configuration

Recipe: gitlab::gitlab-workhorse

  *service[gitlab-workhorse] action restart

    -restart service service[gitlab-workhorse]

  *ruby_block[reload gitlab-workhorse svlogd configuration] action create

    -execute the ruby block reload gitlab-workhorse svlogd configuration

Recipe: gitlab::gitlab-workhorse

  *service[gitlab-workhorse] action restart

    -restart service service[gitlab-workhorse]

  *ruby_block[reload gitlab-workhorse svlogd configuration] action create

    -execute the ruby block reload gitlab-workhorse svlogd configuration

Recipe: gitlab::nginx

  *ruby_block[reload nginx svlogd configuration] action create

    -execute the ruby block reload nginx svlogd configuration

Recipe: gitlab::logrotate

  *ruby_block[reload logrotate svlogd configuration] action create

    -execute the ruby block reload logrotate svlogd configuration



Running handlers:

Running handlers complete

Chef Client finished, 222/309 resources updatedin 02 minutes 50 seconds

gitlab Reconfigured!#如果在此期间没有出现error，证明成功

7、启动Gitlab服务
[root@gitlab ~]# gitlab-ctl start

ok: down:gitaly: 0s, normally up

ok: down:gitlab-monitor: 1s, normally up

ok: down: gitlab-workhorse: 0s, normally up

ok: down: logrotate: 0s, normally up

ok: down: nginx: 0s, normally up

ok: down:node-exporter: 0s, normally up

ok: down:postgres-exporter: 1s, normally up

ok: down: postgresql: 0s, normally up

ok: down:prometheus: 1s, normally up

ok: down: redis: 0s, normally up

ok: down:redis-exporter: 0s, normally up

ok: down: sidekiq: 0s, normally up

ok: down: unicorn: 1s, normally up

注解：

绿色部分是9中新添加的

ü  gitlab-workhorse这个“工作马”，就是gitlab-Git-http-server（GitlabV8.0出现，V8.2名称变更为Gitlab-workhorse）

ü  sidekiq多线程启动

ü  unicorn是ruby的http server，可以通过http://localhost:8080端口访问, 默认端口是8080

ü  nginx作为方向代理，代理到unicorn，nginx默认端口是80

ü  postgresql作为数据库，默认端口是5432

ü  redis作为一个队列（NoSql）,用于存储用户session和任务，任务包括新建仓库、发送邮件等等，默认端口是6379

ü  logrotate切割日志

ü  prometheus监控，默认端口9090

ü  gitlab-monitor默认端口9168

注：

(可选)如果系统资源不足，可以通过以下命令关闭Sidekiq来释放一部分内存

[root@gitlab ~]# gitlab-ctl stop sidekiq

ok: down: sidekiq: 0s, normally up

7.1 RPM安装模式下的启动、停止、重启
#初次配置服务
# gitlab-ctlreconfigure

#启动服务
# gitlab-ctl start

#停止服务
# gitlab-ctl stop

#重启服务
# gitlab-ctl restart

#状态
#gitlab-ctl status

#监控
#gitlab-ctl tailunicorn 监控unicorn日志

#gitlab-ctl tail

8、登录
访问地址http://ip

由于第一次登陆，需要设置密码

登录

登录之后的界面

Gitlab8的界面

Gitlab9版本

9、卸载
重新安装清理

1，卸载

[root@git Gitlab-cn]# rpm -e gitlab-ce

2，删除文件

[root@git Gitlab-cn]#rm -rf /etc/gitlab/*/var/log/gitlab/ /var/opt/gitlab/ /opt/gitlab/

2.4 汉化
#查看版本
[root@git .ssh]# cat /opt/gitlab/embedded/service/gitlab-rails/VERSION

9.1.2

#8版本下载汉化包并汉化
[root@git hanhua]# git clonehttps://gitlab.com/larryli/gitlab.git Gitlab-cn && cd Gitlab-cn

#备份/opt/gitlab/embedded/service目录下的gitlab-rails目录，该目录下的内容主要是web应用部分

#备份

[root@git Gitlab-cn]#\cp -rf/opt/gitlab/embedded/service/gitlab-rails{,.ori}

#关闭gitlab这个服务

[root@git Gitlab-cn]#gitlab-ctl stop

#开始汉化

[root@git gitlab_pack]# \cp -rf Gitlab-cn/*/opt/gitlab/embedded/service/gitlab-rails/

测试是否汉化成功

[root@git ~]# gitlab-ctl start

ok: run: gitlab-workhorse: (pid 1407) 263s

ok: run: logrotate: (pid 1403) 263s

ok: run: nginx: (pid 1404) 263s

ok: run: postgresql: (pid 1405) 263s

ok: run: redis: (pid 1402) 263s

ok: run: sidekiq: (pid 1400) 263s

ok: run: unicorn: (pid 1401) 263s

登录

http://192.168.201.131/users/sign_in

#9版本汉化
[root@gitlab ~]#gitclone https://gitlab.com/xhang/gitlab.git

Cloning into 'gitlab'...

remote: Counting objects: 496150, done.

remote: Compressing objects: 100%(103590/103590), done.

remote: Total 496150 (delta 387041), reused495906 (delta 386824)Receiving objects: 100% (496150/496150), 220.14 MiB | 2



Resolving deltas: 100% (387041/387041), done.

Checking out files: 100% (9254/9254), done

#更新包

[root@gitlab ~]# cd gitlab/

[root@gitlab [9-1-stable-zh ≡]# git fetch

#生成补丁，进入到gitlab目录下

[root@gitlab gitlab]# git diff v9.1.2 v9.1.2-zh> ../9.1.2-zh.diff

#打补丁

[root@gitlab gitlab]# patch -d/opt/gitlab/embedded/service/gitlab-rails -p1 < ../9.1.2-zh.diff

2.5 Gitlab命令使用
语法:

gitlab-ctl command (subcommand)

Service Management Commands

start

启动所有服务

stop

关闭所有服务

restart

重启所有服务

status

查看所有服务状态

tail

查看日志信息

service-list

列举所有启动服务

graceful-kill

平稳停止一个服务

例子：

#启动所有服务

[root@gitlab ~]# gitlab-ctl start

#启动单独一个服务

[root@gitlab ~]# gitlab-ctl start nginx

#查看日志，查看所有日志

[root@gitlab ~]# gitlab-ctl tail

#查看具体一个日志,类似tail -f

[root@gitlab ~]# gitlab-ctl tail nginx

General Commands

help

帮助

reconfigure

修改配置文件之后，需要重新加载下

show-config

查看所有服务配置文件信息

uninstall

卸载这个软件

cleanse

删除gitlab数据，重新白手起家

例子：

#显示所有服务配置文件

[root@gitlab ~]#gitlab-ctl show-config

#卸载gitlab

[root@gitlab ~]#gitlab-ctl uninstall



DatabaseCommands（慎重使用）

Database Commands

pg-upgrade

更新postgresql版本

revert-pg-upgrade

还远先前的(离现在正在使用靠近的版本)一个数据库版本

例子：

#升级数据库

[root@gitlab ~]# gitlab-ctl pg-upgrade

Checking for an omnibus managed postgresql: OK

Checking if we already upgraded: OK

The latest version 9.6.1 is already running,nothing to do

#降级数据库版本

[root@gitlab ~]# gitlab-ctl revert-pg-upgrade

Toggling deploy page:cp/opt/gitlab/embedded/service/gitlab-rails/public/deploy.html/opt/gitlab/embedded/service/gitlab-rails/public/index.html

Toggling deploy page: OK

Toggling services:ok: down: gitaly: 129s,normally up

ok: down: gitlab-monitor: 128s, normally up

ok: down: logrotate: 127s, normally up

ok: down: node-exporter: 127s, normally up

ok: down: postgres-exporter: 126s, normally up

ok: down: prometheus: 125s, normally up

ok: down: redis-exporter: 125s, normally up

ok: down: sidekiq: 123s, normally up

Toggling services: OK

Checking if we need to downgrade: NOT OK

/var/opt/gitlab/postgresql/data.9.2.18 does notexist, cannot revert data

Will proceed with reverting the running programversion only, unless you interrupt

Reverting database to 9.2.18 in 5 seconds

=== WARNING ===

This will revert the database to what it wasbefore you upgraded, including the data.

Please hit Ctrl-C now if this isn't what youwere looking for

=== WARNING ===

== Reverting ==

ok: down: postgresql: 131s, normally up

ok: run: postgresql: (pid 12102) 0s

== Reverted ==

Toggling deploy page:rm -f/opt/gitlab/embedded/service/gitlab-rails/public/index.html

Toggling deploy page: OK

Toggling services:ok: run: gitaly: (pid 12107)1s

ok: run: gitlab-monitor: (pid 12111) 0s

ok: run: logrotate: (pid 12115) 1s

ok: run: node-exporter: (pid 12121) 0s

ok: run: postgres-exporter: (pid 12125) 0s

ok: run: prometheus: (pid 12130) 1s

ok: run: redis-exporter: (pid 12139) 0s

ok: run: sidekiq: (pid 12144) 1s

Toggling services: OK

2.6 gitlab配置详解
名称

配置路径

gitlab配置文件

/etc/gitlab/gitlab.rb

unicorn配置文件

/var/opt/gitlab/gitlab-rails/etc/unicorn.rb

nginx配置文件

/var/opt/gitlab/nginx/conf/gitlab-http.conf

gitlab仓库默认位置

/var/opt/gitlab/git-data/repositories

#修改web端口
如果80和8080端口被占用可以修改

[root@gitlabgitlab_pack]# vi /var/opt/gitlab/gitlab-rails/etc/unicorn.rb

listen"127.0.0.1:8080", :tcp_nopush => true #这一行端口修改为你要端口

#修改nginx端口

[root@gitlabgitlab_pack]# vi /var/opt/gitlab/nginx/conf/gitlab-http.conf

server{ #这里的80端口修改为你所需要的端口

  listen *:80;

注:

       只要修改了配置文件一定要重新加载配置

#修改Prometheus端口
#Prometheus默认端口是9090

[root@gitlabgitlab_pack]# vi /etc/gitlab/gitlab.rb

#根据自己情况自行修改成自己需要的port

#修改项目工程数量
默认安装好,你能创建的项目，只能创建10个

#第一种方式修改
[root@gitlab gitlab_pack]# vi/opt/gitlab/embedded/service/gitlab-rails/config/initializers/1_settings.rb

Settings.gitlab['default_projects_limit'] ||=10

修改成你自己所需要的参数，保存

Settings.gitlab['default_projects_limit'] ||=10000

#重新初始化

[root@gitlab postgresql]# gitlab-ctlreconfigure

#查看修改之后项目数量

注：

       这个是在安装完gitlab之后修改，如果已经使用一段时间，在修改项目的数量，需要你自己在自己的用户下修改，第二次初始化，会缩短时间

#第二种方式修改
#首先登录gitlab
#点击Adminstrator这个用户
#点击编辑
#关闭注册功能
默认注册功能是开启的, 对于个人的gitlab, 没有对外公布的必要

#首先点击管理区域---à在点击设置按钮

找到注册限制

选中，然后保存

#关闭监控
#关闭服务

[root@gitlab gitlab_pack]# gitlab-ctl stop

[root@gitlabgitlab_pack]# vi /etc/gitlab/gitlab.rb

把true改成false

prometheus_monitoring['enable']= true

prometheus_monitoring['enable']= false

#保存

#重新加载配置文件

[root@gitlabgitlab_pack]# gitlab-ctl reconfigure

#启动服务

[root@gitlab gitlab_pack]# gitlab-ctl start

ok: run: gitaly: (pid 21611) 0s

ok: run: gitlab-workhorse: (pid 21615) 1s

ok: run: logrotate: (pid 21622) 0s

ok: run: nginx: (pid 21628) 1s

ok: run: postgresql: (pid 21633) 0s

ok: run: redis: (pid 21641) 0s

ok: run: sidekiq: (pid 21645) 1s

ok: run: unicorn: (pid 21648) 0s

#很显然没有prometheus这个服务

2.7 gitlab安全
#Custom password length limits
#初始化器的密码长度设置为最少8个字符

[root@gitlab opt]# cd/opt/gitlab/embedded/service/gitlab-rails/config/initializers

[root@gitlab initializers]#cpdevise_password_length.rb.example devise_password_length.rb

#重启gitlab服务

#Rack attack
为了防止滥用客户造成损害GitLab使用机架攻击，提供一个保护路径

默认情况下，用户登录，用户注册（如果启用）和用户密码重置被限制为每分钟6个请求。尝试6次后，客户端将不得不等待下一分钟再次尝试。

如果发现节流不足以保护您免遭滥用客户端，机架式攻击宝石提供IP白名单，黑名单，Fail2ban样式过滤器和跟踪。

[root@gitlab opt]# cd/opt/gitlab/embedded/service/gitlab-rails/config/initializers

[root@gitlab initializers]# cp rack_attack.rb.example rack_attack.rb

#编辑application.rb

[root@gitlab config]#vi/opt/gitlab/embedded/service/gitlab-rails/config/application.rb

config.middleware.use Rack::Attack

保存

#重新启动GitLab实例

#Information exclusivity
       Git是分布式版本控制系统（DVCS）。这意味着每个与源代码一起工作的人都具有完整存储库的本地副本。在GitLab中，不是客人的所有项目成员（因此，记者，开发人员和主人）都可以克隆资料库以获取本地副本。获取本地副本后，用户可以随时上传完整的存储库，包括其控制下的另一个项目或其他服务器。结果是您无法构建访问控制，阻止有权访问源代码的用户有意共享源代码。这是DVCS的固有特性，所有git管理系统都有这个限制。很明显，你可以采取措施，防止意外分享和破坏信息，这就是为什么只有一些人被允许邀请他人，没有人可以强制推行一个受保护的分支机构。

#How to reset your root password
[root@gitlab config]# gitlab-railsconsole production

Loading production environment (Rails 4.2.8)

irb(main):001:0> user = User.where(id: 1).first#查看信息

=> #<User id: 1, email: "admin@example.com",created_at: "2017-05-16 09:04:59", updated_at: "2017-05-1707:18:16", name: "Administrator", admin: true, projects_limit:100000, skype: "", linkedin: "", twitter: "",authentication_token: "k44aWyAaaaJaHYx4B_QP", bio: nil, username:"root", can_create_group: true, can_create_team: false, state:"active", color_scheme_id: 1, password_expires_at: nil,created_by_id: nil, last_credential_check_at: nil, avatar: nil,hide_no_ssh_key: false, website_url: "", notification_email:"admin@example.com", hide_no_password: false, password_automatically_set:false, location: nil, encrypted_otp_secret: nil, encrypted_otp_secret_iv: nil,encrypted_otp_secret_salt: nil, otp_required_for_login: false,otp_backup_codes: nil, public_email: "", dashboard: 0, project_view:2, consumed_timestep: nil, layout: 0, hide_project_limit: false,otp_grace_period_started_at: nil, ldap_email: false, external: false,incoming_email_token: "9wt82lanyjoakil3asrhfevvh", organization: nil,authorized_projects_populated: true, ghost: nil, last_activity_on: nil, notified_of_own_activity:false, require_two_factor_authentication_from_group: false,two_factor_grace_period: 48>

irb(main):002:0> user.password = 'admin123' #设置新的密码

=> "admin123"

irb(main):003:0> user.password_confirmation = 'admin123' #验证密码

=> "admin123"

irb(main):004:0> user.save! #保存密码

Enqueued ActionMailer::DeliveryJob (Job ID:b2ba5d30-853c-405d-8d95-fa938d88f32c) to Sidekiq(mailers) with arguments:"DeviseMailer", "password_change", "deliver_now",gid://gitlab/User/1

=> true

irb(main):005:0> #ctrl+d退出

#User email confirmation at sign-up
       如果您想在所有用户电子邮件登录之前确认，Gitlab管理员可以在注册时启用电子邮件确认。

2.8 gitlab集群


2.9 GitLab Runner 构建任务
官方：https://docs.gitlab.com/runner/

#简介
GitLab Runner是用于运行作业并将结果发送回GitLab的开源项目。它与GitLab CI结合使用，GitLab CI是GitLab中协调工作的开源连续集成服务。

#Requirements
GitLab Runner是用Go编写的，可以作为一个二进制文件运行，不需要任何语言特定的要求。它被设计为在GNU / Linux，macOS和Windows操作系统上运行。只要您可以编译一个Go二进制文件，其他操作系统就可能会工作。

#Features
Allows to run
multiple jobs concurrently(多个工作同时进行)
use multiple tokens with multiple server (even per-project)( 使用多个令牌与多个服务器（甚至每个项目）)
limit number of concurrent jobs per-token(限制每个令牌的并发作业数)
Jobs can be run
locally(本地)
using Docker containers(使用Docker容器)
using Docker containers and executing job over SSH(使用Docker容器并通过SSH执行作业)
using Docker containers with autoscaling on different clouds and virtualization hypervisors(使用Docker容器在不同的云和虚拟化管理程序上进行自动缩放)
connecting to remote SSH server(连接到远程SSH服务器)
#安装
#安装gitlab-ci-multi-runner源

[root@gitlab ~]#curl -Lhttps://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.rpm.sh| sudo bash

#安装

[root@gitlab ~]#yum installgitlab-ci-multi-runner

#gitlab-runner使用
必须是在8版本以上才能使用这个集成功能

https://docs.gitlab.com/runner/commands/README.html

语法
gitlab-runner
[root@gitlab ~]# gitlab-runner --help

USAGE:

   gitlab-runner[global options] command [command options] [arguments...]

COMMANDS

名称

作用

exec

显示runner配置文件

list



run

运行多个runner服务

register

注册一个新的runner

install

安装服务

uninstall

卸载服务

start

启动一个服务

stop

停止一个服务

restart

重启

status

一个服务状态

run-single

运行单独的一个runner

unregister

注销特定的runner

verify

验证所有注册的runner

artifacts-downloader    downloadand extract build artifacts (internal)

  artifacts-uploader   create andupload build artifacts (internal)

  cache-archiver  create and uploadcache artifacts (internal)

  cache-extractor       download andextract cache artifacts (internal)

例子：

#list

[root@gitlab ~]# gitlab-runner list

Listing configured runners                         ConfigFile=/etc/gitlab-runner/config.toml

#debug

[root@gitlab ~]# gitlab-runner --debug  list

Runtime platform                                    arch=amd64 os=linuxrevision=0118d89 version=9.1.0

Listing configured runners                         ConfigFile=/etc/gitlab-runner/config.toml

gitlab-ci-multi-runner
[root@gitlab gitlab]# gitlab-ci-multi-runnerregister --help



Runner类型
GitLab-Runner可以分类两种类型：

Shared Runner（共享型）

Specific Runner（指定型）。

Shared Runner：

这种Runner（工人）是所有工程都能够用的。只有系统管理员能够创建Shared Runner。

Specific Runner：

这种Runner（工人）只能为指定的工程服务。拥有该工程访问权限的人都能够为该工程创建Shared Runner。

注册runner
1，copy 注册授权码
2，register
安装好gitlab-ci-multi-runner这个软件之后，我们就可以用它向GitLab-CI注册Runner了。

向GitLab-CI注册一个Runner需要两样东西：GitLab-CI的url和注册token。

其中，token是为了确定你这个Runner是所有工程都能够使用的Shared Runner还是具体某一个工程才能使用的Specific Runner

#查看register帮助

[root@gitlab gitlab]# gitlab-ci-multi-runnerregister --help



#注册Shared Runner

在注册Runner的时候，需要填入Token，GitLab根据不同的Token确定这个Runner是被设置为Shared Runner还是Specific Runner



[root@gitlab gitlab]# gitlab-ci-multi-runnerregister

Running in system-mode.



Please enter the gitlab-ci coordinator URL(e.g. https://gitlab.com/):

http://192.168.201.148/ci#输入ci

Please enter the gitlab-ci token for thisrunner:

2RBdZavdy6UsZvbyCcMF#注册授权码

Please enter the gitlab-ci description for thisrunner:

[gitlab.server.com]: test_runner #描述

Please enter the gitlab-ci tags for this runner(comma separated):

hello_tom #写个标签，可以多个，用逗号隔开

Whether to run untagged builds [true/false]:

[false]: #输入回车

Whether to lock Runner to current project[true/false]:

[false]: #输入回车

Registering runner... succeeded                     runner=2RBdZavd

Please enter the executor: virtualbox, docker-ssh+machine,kubernetes, parallels, shell, ssh, docker+machine, docker, docker-ssh:

shell #输入选择通讯方式

Runner registered successfully. Feel free tostart it, but if it's running already the config should be automaticallyreloaded!

#查看服务是否运行

[root@gitlab gitlab]# ps -ef|grep runner

root      7998      1  0 13:09 ?        00:00:02/usr/bin/gitlab-ci-multi-runner run --working-directory /home/gitlab-runner --config/etc/gitlab-runner/config.toml --service gitlab-runner --syslog --usergitlab-runner

注意：

如果不运行gitlab-ci-multi-runner register命令，直接在配置文件里面添加Runner的配置信息可以吗

当然不行。因为gitlab-ci-multi-runner register的作用除了把Runner的信息保存到配置文件以外，还有一个很重要的作用，那就是向GitLab-CI发出请求，在GitLab-CI中登记这个Runner的信息并且获取后续通信所需要的token。

3，查看register
# 登陆

http://my_url/admin/runners

#查看gitlab-runner配置文件

[root@gitlab ~]# cat/etc/gitlab-runner/config.toml

concurrent = 1

check_interval = 0



[[runners]]

  name ="test_ci"

  url ="http://192.168.201.148/ci"

  token ="c6f62fe5a2b4ec072f5cc2fb096c02"

 executor = "shell"

 [runners.cache]



4，运行runner
       要让一个Runner运行起来，--url、--token和--executor选项是必要的.

[root@gitlab gitlab]# gitlab-ci-multi-runnerrun-single --help

[root@gitlab ~]# gitlab-ci-multi-runner install--user=gitlab-runner --working-directory=/home/gitlab-runner

[root@gitlab ~]# gitlab-ci-multi-runner status

gitlab-runner: Service is running!

[root@gitlab test]# gitlab-ci-multi-runner list

Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml

popop                                              Executor=shell Token=8bfcd3b988ae348111b5500a355273URL=http://192.168.201.149/ci

5，yaml
https://docs.gitlab.com/ee/ci/yaml/README.html

从7.12版本开始，GitLab CI使用YAML 文件(.gitlab-ci.yml)来配置project's builds

.gitlab-ci.yml 使用YAML语法， 需要格外注意缩进格式，要用空格来缩进，不能用tabs来缩进。

6，实战


3.0 实战测试
http客户端测试
#创建测试目录
[root@client ~]# mkdir test2

[root@client ~]# cd test2

#把服务器的上仓库clone下来
[root@cleint test2]# git clone http://gitlab.server.com/root/test.git

Cloning into 'test'...

warning: You appear to have cloned an emptyrepository.

Checking connectivity... done.

或者

[root@cleint test2]# git clone http://gitlab.server.com/root/test.git

Username for 'http://git.server.com':root

Password for 'http://root@git.server.com':adminroot

Counting objects: 3, done.

Writing objects: 100% (3/3), 216 bytes | 0bytes/s, done.

Total 3 (delta 0), reused 0 (delta 0)

To http://git.server.com/root/go.git

 * [newbranch]      master -> master

Branch master set up to track remote branchmaster from origin.

[root@git test2]# ls

test

#配置用户
[root@cleint test2]# git config --globaluser.name "Administrator"

[root@client test2]# git config --globaluser.email "admin@example.com"

[root@client test2]# cd test/

#创建文件
[root@client test]# touch README.md

[root@client test]# vi README.md

[root@client test]# git add README.md

[root@client test]# git commit -m "addREADME"

[master (root-commit) 874889b] add README

 1 filechanged, 1 insertion(+)

 createmode 100644 README.md

#push
[root@client test]# git push -u origin master

Username for 'http://git.server.com': root

Password for 'http://root@gitlab.server.com': adminroot

Counting objects: 3, done.

Writing objects: 100% (3/3), 223 bytes | 0bytes/s, done.

Total 3 (delta 0), reused 0 (delta 0)

To http://git.server.com/root/test.git

 * [newbranch]      master -> master

Branch master set up to track remote branchmaster from origin.

从web上查看test仓库下是否上传了README.md这个文件

#查看是否成功
上传成功

ssh客户端测试
#生成公钥
[root@node6 .ssh]# ssh-keygen

Generating public/private rsa key pair.

Enter file in which to save the key(/root/.ssh/id_rsa):

Enter passphrase (empty for no passphrase):

Enter same passphrase again:

Your identification has been saved in/root/.ssh/id_rsa.

Your public key has been saved in/root/.ssh/id_rsa.pub.

The key fingerprint is:

d9:0d:43:2b:17:cc:3b:01:fa:c9:cb:2c:6e:b7:27:6droot@node6

The key's randomart image is:

+--[ RSA 2048]----+

|       .+o      |

|       ..+o     |

|      .. =o     |

|       o*o+     |

|       S ...    |

|       o.       |

|      .+.       |

|    ...o E      |

|    ....=       |

+-----------------+

[root@node6 .ssh]#

[root@node6 .ssh]# ls

id_rsa id_rsa.pub

[root@node6 .ssh]# cat id_rsa.pub

ssh-rsaAAAAB3NzaC1yc2EAAAABIwAAAQEAoOLsYhPPlHPOnGh6SoVDPlVn2o8rfO55J60Gz7E0EDB0ugKgTu4VGOE8vVta7HH5exNAjw2UqHIliYcmVvrj5eFbvXLdLYGypiMfuP4H7dVwGXfxSzeG17aIbZma0fpB2bTQr3tN+nVA7tokVSmO+jC61/H6Qj9G1TEiedq0wtTuSQ8pza5hyeWRO9oi0W7ccZkYg7lSQ3Eo2n2/RJbmQHWdIcoBO8c64h5vq/gB1s7ZjHKUjSFvGTyHu7uYE6yD2PXylavLfq2FHUc4syV8yAvyW2ehgIcc+xDWMFC85SNuPvTOt0YNzG628gWB2lm+D8CPhZBUbz2IUkFN0jEdyQ==root@node6

#添加域名（如果是真实的域名，这步不需要做）

[root@node6 .ssh]# vi /etc/hosts

192.168.201.131 git.server.com

#添加到gitlab上

#测试ssh是否可用
[root@node6 .ssh]# ssh -T git@gitlab.server.com

The authenticity of host 'git.server.com(192.168.201.134)' can't be established.

RSA key fingerprint is45:1f:76:55:cb:72:fe:65:22:75:10:eb:d5:2e:35:d5.

Are you sure you want to continue connecting(yes/no)?yes

Warning: Permanently added'git.server.com,192.168.201.134' (RSA) to the list of known hosts.

Welcome to GitLab, Administrator!

证明成功

#克隆数据
[root@node6 .ssh]# git clone git@gitlab.server.com:root/test.git

Initialized empty Git repository in/root/.ssh/test/.git/

remote: Counting objects: 3, done.

remote: Total 3 (delta 0), reused 0 (delta 0)

Receiving objects: 100% (3/3), 223 bytes, done

Gitlab-runner
在创建register之前，需要拿到token和ci地址

1，找到你要register的项目地址

2，进入到这个项目

3，点击设置

4，点击pipline，查看token和ci

#register
[root@gitlab test]# gitlab-ci-multi-runnerregister

#查看register
# 登陆

http://my_url/admin/runners

#查看gitlab-runner配置文件

[root@gitlab ~]# cat/etc/gitlab-runner/config.toml

concurrent = 1

check_interval = 0



[[runners]]

  name ="test_ci"

  url ="http://192.168.201.148/ci"

  token ="c6f62fe5a2b4ec072f5cc2fb096c02"

 executor = "shell"

 [runners.cache]

#配置pipline
1，打开runner

2，编辑runner

#clone仓库
[root@gitlab test]# git clone http://root@gitlab.server.com/root/test.git

[root@gitlab test]#cd test

#创建gitlab-ci.yml文件
[root@gitlab test]# cat .gitlab-ci.yml

stages:

  - test

job1:

  stage:test

  script:

    -echo "I am job1"

- echo "I am intest stage"

#上传到gitlab仓库中
[root@gitlab test]# git add .gitlab-ci.yml

[root@gitlab test]# git commit -m"kskksksk"

[master 9376c70] kskksksk

 1 filechanged, 1 insertion(+), 1 deletion(-)

[root@gitlab test]# git push origin master

Password for 'http://root@gitlab.server.com':

Counting objects: 5, done.

Compressing objects: 100% (3/3), done.

Writing objects: 100% (3/3), 363 bytes | 0bytes/s, done.

Total 3 (delta 1), reused 0 (delta 0)

To http://root@gitlab.server.com/root/test.git

  df0b7b4..9376c70  master ->master

#查看效果
#点击passwd

======================================================================

Centos 7 上安装 Gitlab的步骤和一些设置方法
2015年10月24日 02:48:20
阅读数：12707
安装过程


 转自  https://about.gitlab.com/downloads/#centos7
1. Install and configure the necessary dependencies

If you install Postfix to send email please select 'Internet Site' during setup. Instead of using Postfix you can also use Sendmail or configure a custom SMTP server. If you wish to use Exim, please configure it as an SMTP server.

On Centos 6 and 7, the commands below will also open HTTP and SSH access in the system firewall.

sudo yum install curl openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld
2. Add the GitLab package server and install the package

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce
If you are not comfortable installing the repository through a piped script, you can find the entire script here.
Alternatively you can select and download the package manually and install using
rpm -i gitlab-ce-XXX.rpm
3. Configure and start GitLab

sudo gitlab-ctl reconfigure
4. Browse to the hostname and login

Username: root
Password: 5iveL!fe


5. 关闭gitlab的自动启动

systemctl disable gitlab-runsvdir.service


6. 开启gitlab的自动启动


systemctl enable gitlab-runsvdir.service
systemctl start gitlab-runsvdir.service
gitlab-cmd start



修改端口


As suggested on https://github.com/gitlabhq/gitlabhq/issues/6581 you can configure port on below file.

Change port to 81 (You can choose your own) at port: near by production:$base >> gitlab: for file /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
Change your host address if you like to use different from your ip address or localhost
Change server port to 81 in file "/opt/gitlab/embedded/conf/nginx.conf"
Restart gitlab using command "sudo gitlab-ctl restart".
After applying all above changes still my nginx was running on port 80only and not sure why also reconfiguring gitlab reset may all change on gitlab.yml files. Finally, file "/etc/gitlab/gitlab.rb" make this work for me.


5. Open "/etc/gitlab/gitlab.rb" to text editor where currently I have external_url 'http://myipaddress/' as text. I just change to
external_url 'http://gitlab.com.local:81/'
then reconfigure using command "sudo gitlab-ctl reconfigure" and voila, Gitlab is now working on port 81.


=======================================

