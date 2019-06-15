#https://github.com/alibaba/DataX.wiki.git
#
#Linux、Windows
#JDK(1.8)
#Python(推荐Python2.6.X)
#Apache Maven 3.x (Compile DataX)
#
#
#一、工具下载以及部署
#方法一、直接下载DataX工具包(如果仅是使用，推荐直接下载)：D
#ataX下载地址
#
#
#下载后解压至本地某个目录，修改权限为755，进入bin目录，即可运行样例同步作业：

 tar zxvf datax.tar.gz

sudo chmod -R 755 {YOUR_DATAX_HOME}

cd  {YOUR_DATAX_HOME}/bin

 python datax.py ../job/job.json


#方法二、下载DataX源码，自己编译：DataX源码编译方法













