#!/bin/bash
JAVA_HOME='/opt/module/jdk1.7.0_67'
MYSQL_HOME='/opt/module/mysql-5.6'

HIVE_HOME='/opt/module/cdh-5.3.6-ha/hive-0.13.1-cdh5.3.6'
FLUME_HOME='/opt/module/cdh-5.3.6-ha/apache-flume-1.5.0-cdh5.3.6-bin'
ZOOK_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'
HBase_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'


sh $ZOOK_HOME/start.sh
 if [[ $? -ne 0 ]]
	then
		echo 'zookeeper error!'
		exit
 fi
sh $HADOOP_HOME/shell/start.sh
 if [[ $? -ne 0 ]]
	then
		echo 'hadoop error!'
		exit
 fi
sh $HBase_HOME/start.sh
 if [[ $? -ne 0 ]]
	then
		echo 'hbase error!'
		exit
 fi
sh $HIVE_HOME/bin/hive
 if [[ $? -ne 0 ]]
	then
		echo 'hive error!'
		exit
 fi
#!/bin/bash
JAVA_HOME='/opt/module/jdk1.7.0_67'
MYSQL_HOME='/opt/module/mysql-5.6'

HIVE_HOME='/opt/module/cdh-5.3.6-ha/hive-0.13.1-cdh5.3.6'
FLUME_HOME='/opt/module/cdh-5.3.6-ha/apache-flume-1.5.0-cdh5.3.6-bin'
ZOOK_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'
HBase_HOME='/opt/module/cdh-5.3.6-ha/hbase-0.98.6-cdh5.3.6'
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'


sh $HBase_HOME/stop.sh
 if [[ $? -ne 0 ]]
	then
		echo 'hbase error!'
		exit
 fi
sh $HADOOP_HOME/shell/stop.sh
 if [[ $? -ne 0 ]]
	then
		echo 'hadoop error!'
		exit
 fi
sh $ZOOK_HOME/stop.sh
	if [[ $? -ne 0 ]]
		then
			echo 'zookeeper error!'
			exit
	 fi


==========================================
#!/bin/bash


# 1) 安装sanppy
# 2) 编译haodop 2.x源码
	# mvn package -Pdist,native -DskipTests -Dtar -Drequire.snappy
	# /opt/modules/hadoop-2.5.0-src/target/hadoop-2.5.0/lib/native

# $ bin/hadoop checknative
# 15/08/31 23:10:16 INFO bzip2.Bzip2Factory: Successfully loaded & initialized native-bzip2 library system-native
# 15/08/31 23:10:16 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
# Native library checking:
# hadoop: true /opt/modules/hadoop-2.5.0/lib/native/libhadoop.so
# zlib:   true /lib64/libz.so.1
# snappy: true /opt/modules/hadoop-2.5.0/lib/native/libsnappy.so.1
# lz4:    true revision:99
# bzip2:  true /lib64/libbz2.so.1

# bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0.jar wordcount /user/beifeng/mapreduce/wordcount/input /user/beifeng/mapreduce/wordcount/output

# bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0.jar wordcount -Dmapreduce.map.output.compress=true -Dmapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec /user/beifeng/mapreduce/wordcount/input /user/beifeng/mapreduce/wordcount/output22


####################################依赖#################################
# sudo yum -y install autoconf automake libtool &&
#sudo yum -y install gcc gcc-c++ make
# sudo yum  -y install cmake openssl-devel ncurses-devel

#########################snappy#############################################
#下载
# snappy-1.1.2
# https://code.google.com/p/snappy/

# sudo wget http://pkgs.fedoraproject.org/repo/pkgs/snappy/snappy-1.1.1.tar.gz/8887e3b7253b22a31f5486bca3cbc1c2/snappy-1.1.1.tar.gz
export SNAPPY_HOME='/opt/module/snappy-1.1.2'
cd $SNAPPY_HOME
sudo chmod  u+x ./configure && sudo ./configure && sudo make && sudo make install

 # ls /usr/local/lib


################################### hadoop-snappy-master###############################
# https://github.com/electrum/hadoop-snappy
# sudo unzip hadoop-snappy-master.zip -d /opt/module/

# cd $HADOOP_SNAPPY_CODE_HOME
# mvn package
export HADOOP_SNAPPY_CODE_HOME='/opt/module/hadoop-snappy-master'
cp  $HADOOP_SNAPPY_CODE_HOME/target/hadoop-snappy-0.0.1-SNAPSHOT.jar /opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/lib/

#同时把编译生成后的动态库
cp -r $HADOOP_SNAPPY_CODE_HOME/target/hadoop-snappy-0.0.1-SNAPSHOT-tar/hadoop-snappy-0.0.1-SNAPSHOT/lib/native/Linux-amd64-64  /opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/lib/native/



sudo ln -s $JAVA_HOME/jre/lib/amd64/server/libjvm.so /usr/local/lib/


# ################################hadoop-2.5.0-cdh5.3.6-src make#######################
# Apache Hadoop 所有可用版本下载地址
# https://archive.apache.org/dist/hadoop/common/

# Hadoop2.5.0 版本下载地址
# https://archive.apache.org/dist/hadoop/common/hadoop-2.5.0/

# jdk 略
# maven 略


#gcc/ gcc-c++/make
#



################################### Protobuf#####################################
export PROTOBUF_HOME='/opt/module/protobuf-2.5.0'
cd $PROTOBUF_HOME
sudo ./configure --prefix=/usr/local/protoc && sudo make && sudo make install

# f.  设置 PROTOC_HOME 环境变量
# sudo vi /etc/profile
# source /etc/profile


# cd ~
# vi TeacherProtoc.proto
# message Teacher{
# required int32 id = 1;
# optional string name = 2;
# optional int32 age = 3;
# }

#生成 Java 类，表示 Protobuf 安装成功

 # protoc --java_out=. TeacherProtoc.proto CMake/openssl/ncurses

#################################hadoop-2.5.0-cdh5.3.6-src #########################

export HADOOP_SRC_HOME='/opt/module/cdh-5.3.6-ha/bak/hadoop-2.5.0-cdh5.3.6-src'

##翻墙

# cd  $HADOOP_SRC_HOME
# mvn package -Pdist,native -DskipTests -Dtar -Drequire.snappy

cp -r $HADOOP_SRC_HOME/hadoop-dist/target/hadoop-2.5.0-cdh5.3.6/lib/native/* /opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/lib/native/

#################################hadoop-2.5.0-cdh5.3.6-bin#########################
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'

# hadoop-env.sh

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/module/cdh-5.3.6-ps/hadoop-2.5.0-cdh5.3.6/lib/native/Linux-amd64-64


# core-site.xml:
# <property>
			# <name>io.compression.codecs</name>
			# <value>
			# org.apache.hadoop.io.compress.GzipCodec,
			# org.apache.hadoop.io.compress.DefaultCodec,
			# org.apache.hadoop.io.compress.BZip2Codec,
			# org.apache.hadoop.io.compress.SnappyCodec
			# </value>
			# <description>
			  # A comma-separated list of the compression codec classes that can
			  # be used for compression/decompression. In addition to any classes specified
			  # with this property (which take precedence), codec classes on the classpath
			  # are discovered using a Java ServiceLoader.
			# </description>
# </property>


# mapred-site.xml

# <property>
        # <name>mapreduce.map.output.compress</name>
        # <value>true</value>
# </property>
# <property>
        # <name>mapreduce.map.output.compress.codec</name>
        # <value>org.apache.hadoop.io.compress.SnappyCodec</value>
# </property>






# 验证
# hadoop-2.5.0-cdh5.3.6-bin
# bin/hadoop checknative


























# 其他

# Hadoop CDH5.3.6添加Snappy压缩支持

# snappy-1.1.1

# https://code.google.com/p/snappy/
# sudowgethttp://pkgs.fedoraproject.org/repo/pkgs/snappy/snappy-1.1.1.tar.gz/8887e3b7253b22a31f5486bca3cbc1c2/snappy-1.1.1.tar.gz
# tar -zxfsnappy-1.1.1.tar.gz -C /opt/module/

# 创建一个build目录用于存放编译结果
# mkdir build

# sudo./configure--prefix=/opt/module/snappy-1.1.1/build

# sudo make && sudo make install

# Hadoop-Snappy
# https://github.com/electrum/hadoop-snappy
# sudo unzip hadoop-snappy-master.zip -d /opt/module/

# cdhadoop-snappy-master/
# sudochown-Rxiaoyuzhou:xiaoyuzhouhadoop-snappy-master/
# mvnpackage-Dsnappy.prefix=/opt/module/snappy-1.1.1/build

# yum -y install libtool

# cp -r /opt/module/hadoop-snappy-master/target/hadoop-snappy-0.0.1-SNAPSHOT.jar
# /opt/module/hadoop-2.5.0-cdh5.3.6/lib

# tar-zxvfhadoop-snappy-0.0.1-SNAPSHOT.tar.gz
# cp hadoop-snappy-0.0.1-SNAPSHOT/lib/hadoop-snappy-0.0.1-SNAPSHOT.jar $HADOOP_HOME/lib
# cp hadoop-snappy-0.0.1-SNAPSHOT/lib/native/Linux-amd64-64/* $HADOOP_HOME/lib/native/



# hadoop
# core-site.xml：
# <property>
# <name>io.compression.codecs</name>
# <value>
# org.apache.hadoop.io.compress.GzipCodec,
# org.apache.hadoop.io.compress.DefaultCodec,
# org.apache.hadoop.io.compress.BZip2Codec,
# org.apache.hadoop.io.compress.SnappyCodec
# </value>
# </property>

# hadoop-env.sh：
# export HADOOP_COMMON_LIB_NATIVE_DIR=/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/lib/native/Linux-amd64-64

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/lib/native/Linux-amd64-64/:/usr/local/lib/

# exportHADOOP_OPTS="$HADOOP_OPTS-Djava.net.preferIPv4Stack=true-Djava.library.path=/opt/module/hadoop-2.5.0-cdh5.3.6/lib/native"

# export HADOOP_IDENT_STRING=$USER
# exportHADOOP_COMMON_LIB_NATIVE_DIR=/opt/module/hadoop-2.5.0-cdh5.3.6/lib/native/

# hadoop checknative
#!/bin/bash
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'
HADOOP_SNAPPY_CODE_HOME='/opt/module/hadoop-snappy-master'


##安装 gcc c++, autoconf, automake, libtool, Java, JAVA_HOME set, Maven 3

# 到官网 http://code.google.com/p/snappy/ 或者到 https://github.com/google/snappy 下载源码，目前版本为 1.1.1。

# 官网 http://code.google.com/p/hadoop-snappy/  ,目前官网没有软件包提供，只能借助 svn 下载源码：


# svn checkout http://hadoop-snappy.googlecode.com/svn/trunk/ hadoop-snappy
# 1
# svn checkout http://hadoop-snappy.googlecode.com/svn/trunk/ hadoop-snappy
# 3.3、hadoop-snappy 编译

su - root

tar -zxvf snappy-1.1.1.tar.gz

#编译
./configure && make && make install

ls -lh /usr/local/lib |grep snappy

#打包
# 默认安装到/usr/local/lib
mvn package -Pdist,native -DskipTests -Dtar  -Drequire.snappy  -Dsnappy.prefix=/usr/local/lib



###################################################
cp  $HADOOP_SNAPPY_CODE_HOME/target/hadoop-snappy-0.0.1-SNAPSHOT.jar /opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/lib/

#同时把编译生成后的动态库
cp -r $HADOOP_SNAPPY_CODE_HOME/target/hadoop-snappy-0.0.1-SNAPSHOT-tar/hadoop-snappy-0.0.1-SNAPSHOT/lib/native/Linux-amd64-64  /opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/lib/native/


这个错误是因为没有把安装jvm的libjvm.so 链接到 /usr/local/lib。如果你的系统时amd64，可以执行如下命令解决这个问题：
ln -s $JAVA_HOME/jre/lib/amd64/server/libjvm.so /usr/local/lib/

$HADOOP_HOME/etc/hadoop/hadoop-env.sh：
##添加：
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native/Linux-amd64-64/


##支持的压缩格式
Zlib org.apache.hadoop.io.compress.DefaultCodec
Gzip org.apache.hadoop.io.compress.GzipCodec
Bzip2 org.apache.hadoop.io.compress.Bzip2Codec
Lzo com.hadoop.compression.lzo.LzoCodec
LZ4 org.apache.hadoop.io.compress.Lz4Codec
Snappy org.apache.hadoop.io.compress.SnappyCodec

##Compressed Input Useage core-site.xml：
set mapred.output.compression.codec="Snappy"
set mapred.output.compression.type=BLOCK/RECORD;

<property>
  <name>io.compression.codecs</name>
  <value>org.apache.hadoop.io.compress.GzipCodec,
    org.apache.hadoop.io.compress.DefaultCodec,
    org.apache.hadoop.io.compress.BZip2Codec,
    org.apache.hadoop.io.compress.SnappyCodec
  </value>
</property>

  # compress intermediate Data (Map Output) 中间结果集的压缩
###Lzo LZ4 产生大量中间结果集的时候 例如joins
set hive.exec.compress.intermediate = True;
set mapred.map.output.compression.codec="Snappy";
set mapred.map.output.compression.type=BLOCK/RECORD;

mapred-site.xml:
  <property>
      <name>mapreduce.map.output.compress</name>
      <value>true</value>
  </property>

  <property>
      <name>mapreduce.map.output.compress.codec</name>
      <value>org.apache.hadoop.io.compress.SnappyCodec</value>
   </property>

# Compress job output (Reducer Output)
mapreduce.output.fileoutputformat.compress=True;
mapreduce.output.fileoutputformat.compress.codec=CodecName;


#验证
# tar -zxf /home/beifeng/2.5.0-native-snappy.tar.gz -C $HADOOP_HOME/lib/native
$HADOOP_HOME/bin/hadoop checknative
bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0.jar wordcount -Dmapreduce.map.output.compress=true  /mr/input  /mr/output

#!/bin/bash
BASE='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'
cd $BASE/bin/hadoop

hdfs dfs -appendToFile localfile /user/hadoop/hadoopfile
hdfs dfs -appendToFile localfile1 localfile2 /user/hadoop/hadoopfile
hdfs dfs -appendToFile localfile hdfs://nn.example.com/hadoop/hadoopfile
hdfs dfs -appendToFile - hdfs://nn.example.com/hadoop/hadoopfile Reads the input from stdin.

hdfs dfs -cat hdfs://nn1.example.com/file1 hdfs://nn2.example.com/file2
hdfs dfs -cat file:///file3 /user/hadoop/file4

# Usage:
hdfs dfs -chgrp [-R] GROUP URI [URI ...]

# Change group association of files. The user must be the owner of files, or else a super-user. Additional information is in the Permissions Guide.


 hdfs dfs -chmod [-R] <MODE[,MODE]... | OCTALMODE> URI [URI ...]

# Change the permissions of files. With -R, make the change recursively through the directory structure. The user must be the owner of the file, or else a super-user. Additional information is in the Permissions Guide.

# Options

# The -R option will make the change recursively through the directory structure.
# chown

# Usage:

hdfs dfs -chown [-R] [OWNER][:[GROUP]] URI [URI ]

# Change the owner of files. The user must be a super-user. Additional information is in the Permissions Guide.

# Options

# The -R option will make the change recursively through the directory structure.
# copyFromLocal

# Usage:
hdfs dfs -copyFromLocal <localsrc> URI

# Similar to put command, except that the source is restricted to a local file reference.

# Options:

# The -f option will overwrite the destination if it already exists.
# copyToLocal

# Usage:

hdfs dfs -copyToLocal [-ignorecrc] [-crc] URI <localdst>

# Similar to get command, except that the destination is restricted to a local file reference.

# count

# Usage:

hdfs dfs -count [-q] <paths>

# Count the number of directories, files and bytes under the paths that match the specified file pattern. The output columns with -count are: DIR_COUNT, FILE_COUNT, CONTENT_SIZE FILE_NAME

# The output columns with -count -q are: QUOTA, REMAINING_QUATA, SPACE_QUOTA, REMAINING_SPACE_QUOTA, DIR_COUNT, FILE_COUNT, CONTENT_SIZE, FILE_NAME

# Example:

hdfs dfs -count hdfs://nn1.example.com/file1 hdfs://nn2.example.com/file2
hdfs dfs -count -q hdfs://nn1.example.com/file1

# Exit Code:

# Returns 0 on success and -1 on error.

# cp

# Usage:

hdfs dfs -cp [-f] [-p | -p[topax]] URI [URI ...] <dest>

# Copy files from source to destination. This command allows multiple sources as well in which case the destination must be a directory.

# Options:

# The -f option will overwrite the destination if it already exists.
# The -p option will preserve file attributes [topx] (timestamps, ownership, permission, ACL, XAttr). If -p is specified with no arg, then preserves timestamps, ownership, permission. If -pa is specified, then preserves permission also because ACL is a super-set of permission.
# Example:

  hdfs dfs -cp /user/hadoop/file1 /user/hadoop/file2
 hdfs dfs -cp /user/hadoop/file1 /user/hadoop/file2 /user/hadoop/dir
# Exit Code:

# Returns 0 on success and -1 on error.

# du

# Usage:

hdfs dfs -du [-s] [-h] URI [URI ...]

# Displays sizes of files and directories contained in the given directory or the length of a file in case its just a file.

# Options:

# The -s option will result in an aggregate summary of file lengths being displayed, rather than the individual files.
# The -h option will format file sizes in a "human-readable" fashion (e.g 64.0m instead of 67108864)
# Example:

# hdfs dfs -du /user/hadoop/dir1 /user/hadoop/file1 hdfs://nn.example.com/user/hadoop/dir1
# Exit Code: Returns 0 on success and -1 on error.

# dus

# Usage:

hdfs dfs -dus <args>

# Displays a summary of file lengths. This is an alternate form of hdfs dfs -du -s.

# expunge

# Usage:

hdfs dfs -expunge

# Empty the Trash. Refer to the HDFS Architecture Guide for more information on the Trash feature.

# get

# Usage: hdfs dfs -get [-ignorecrc] [-crc] <src> <localdst>

# Copy files to the local file system. Files that fail the CRC check may be copied with the -ignorecrc option. Files and CRCs may be copied using the -crc option.

# Example:

hdfs dfs -get /user/hadoop/file localfile
hdfs dfs -get hdfs://nn.example.com/user/hadoop/file localfile

# Exit Code:

# Returns 0 on success and -1 on error.

# getfacl

# Usage: hdfs dfs -getfacl [-R] <path>

# Displays the Access Control Lists (ACLs) of files and directories. If a directory has a default ACL, then getfacl also displays the default ACL.

# Options:

# -R: List the ACLs of all files and directories recursively.
# path: File or directory to list.
# Examples:

hdfs dfs -getfacl /file
hdfs dfs -getfacl -R /dir
# Exit Code:

# Returns 0 on success and non-zero on error.

# getfattr

# Usage:

hdfs dfs -getfattr [-R] -n name | -d [-e en] <path>

# Displays the extended attribute names and values (if any) for a file or directory.

# Options:

# -R: Recursively list the attributes for all files and directories.
# -n name: Dump the named extended attribute value.
# -d: Dump all extended attribute values associated with pathname.
# -e encoding: Encode values after retrieving them. Valid encodings are "text", "hex", and "base64". Values encoded as text strings are enclosed in double quotes ("), and values encoded as hexadecimal and base64 are prefixed with 0x and 0s, respectively.
# path: The file or directory.
# Examples:

hdfs dfs -getfattr -d /file
hdfs dfs -getfattr -R -n user.myAttr /dir
# Exit Code:

# Returns 0 on success and non-zero on error.

# getmerge

# Usage:

 hdfs dfs -getmerge <src> <localdst> [addnl]

# Takes a source directory and a destination file as input and concatenates files in src into the destination local file. Optionally addnl can be set to enable adding a newline character at the end of each file.

# ls

# Usage:

hdfs dfs -ls <args>

# For a file returns stat on the file with the following format:

# permissions number_of_replicas userid groupid filesize modification_date modification_time filename
# For a directory it returns list of its direct children as in Unix. A directory is listed as:

# permissions userid groupid modification_date modification_time dirname
# Example:

hdfs dfs -ls /user/hadoop/file1


# Exit Code:

# Returns 0 on success and -1 on error.

# lsr

# Usage: hdfs dfs -lsr <args>

# Recursive version of ls. Similar to Unix ls -R.

# mkdir

# Usage:

 hdfs dfs -mkdir [-p] <paths>

# Takes path uri's as argument and creates directories.

# Options:

# The -p option behavior is much like Unix mkdir -p, creating parent directories along the path.
# Example:

# hdfs dfs -mkdir /user/hadoop/dir1 /user/hadoop/dir2
# hdfs dfs -mkdir hdfs://nn1.example.com/user/hadoop/dir hdfs://nn2.example.com/user/hadoop/dir
# Exit Code:

# Returns 0 on success and -1 on error.

# moveFromLocal

# Usage:

 dfs -moveFromLocal <localsrc> <dst>

# Similar to put command, except that the source localsrc is deleted after it's copied.

# moveToLocal

# Usage: hdfs dfs -moveToLocal [-crc] <src> <dst>

# Displays a "Not implemented yet" message.

# mv

# Usage:

hdfs dfs -mv URI [URI ...] <dest>

# Moves files from source to destination. This command allows multiple sources as well in which case the destination needs to be a directory. Moving files across file systems is not permitted.

# Example:

# hdfs dfs -mv /user/hadoop/file1 /user/hadoop/file2
# hdfs dfs -mv hdfs://nn.example.com/file1 hdfs://nn.example.com/file2 hdfs://nn.example.com/file3 hdfs://nn.example.com/dir1
# Exit Code:

# Returns 0 on success and -1 on error.

# put

# Usage:

 hdfs dfs -put <localsrc> ... <dst>

# Copy single src, or multiple srcs from local file system to the destination file system. Also reads input from stdin and writes to destination file system.

hdfs dfs -put localfile /user/hadoop/hadoopfile
 hdfs dfs -put localfile1 localfile2 /user/hadoop/hadoopdir
hdfs dfs -put localfile hdfs://nn.example.com/hadoop/hadoopfile
hdfs dfs -put - hdfs://nn.example.com/hadoop/hadoopfile Reads the input from stdin.
# Exit Code:

# Returns 0 on success and -1 on error.

# rm

# Usage:

hdfs dfs -rm [-skipTrash] URI [URI ...]

# Delete files specified as args. Only deletes non empty directory and files. If the -skipTrash option is specified, the trash, if enabled, will be bypassed and the specified file(s) deleted immediately. This can be useful when it is necessary to delete files from an over-quota directory. Refer to rmr for recursive deletes.

# Example:

# hdfs dfs -rm hdfs://nn.example.com/file /user/hadoop/emptydir
# Exit Code:

# Returns 0 on success and -1 on error.

# rmr

# Usage:

hdfs dfs -rmr [-skipTrash] URI [URI ...]

# Recursive version of delete. If the -skipTrash option is specified, the trash, if enabled, will be bypassed and the specified file(s) deleted immediately. This can be useful when it is necessary to delete files from an over-quota directory.

# Example:

hdfs dfs -rmr /user/hadoop/dir
hdfs dfs -rmr hdfs://nn.example.com/user/hadoop/dir
# Exit Code:

# Returns 0 on success and -1 on error.

# setfacl

# Usage:

hdfs dfs -setfacl [-R] [-b|-k -m|-x <acl_spec> <path>]|[--set <acl_spec> <path>]

# Sets Access Control Lists (ACLs) of files and directories.

# Options:

# -b: Remove all but the base ACL entries. The entries for user, group and others are retained for compatibility with permission bits.
# -k: Remove the default ACL.
# -R: Apply operations to all files and directories recursively.
# -m: Modify ACL. New entries are added to the ACL, and existing entries are retained.
# -x: Remove specified ACL entries. Other ACL entries are retained.
# --set: Fully replace the ACL, discarding all existing entries. The acl_spec must include entries for user, group, and others for compatibility with permission bits.
# acl_spec: Comma separated list of ACL entries.
# path: File or directory to modify.
# Examples:

hdfs dfs -setfacl -m user:hadoop:rw- /file
hdfs dfs -setfacl -x user:hadoop /file
hdfs dfs -setfacl -b /file
hdfs dfs -setfacl -k /dir
hdfs dfs -setfacl --set user::rw-,user:hadoop:rw-,group::r--,other::r-- /file
hdfs dfs -setfacl -R -m user:hadoop:r-x /dir
hdfs dfs -setfacl -m default:user:hadoop:r-x /dir
# Exit Code:

# Returns 0 on success and non-zero on error.

# setfattr

# Usage:

 hdfs dfs -setfattr -n name [-v value] | -x name <path>

# Sets an extended attribute name and value for a file or directory.

# Options:

# -b: Remove all but the base ACL entries. The entries for user, group and others are retained for compatibility with permission bits.
# -n name: The extended attribute name.
# -v value: The extended attribute value. There are three different encoding methods for the value. If the argument is enclosed in double quotes, then the value is the string inside the quotes. If the argument is prefixed with 0x or 0X, then it is taken as a hexadecimal number. If the argument begins with 0s or 0S, then it is taken as a base64 encoding.
# -x name: Remove the extended attribute.
# path: The file or directory.
# Examples:

hdfs dfs -setfattr -n user.myAttr -v myValue /file
hdfs dfs -setfattr -n user.noValue /file
hdfs dfs -setfattr -x user.myAttr /file
# Exit Code:

# Returns 0 on success and non-zero on error.

# setrep

# Usage:

hdfs dfs -setrep [-R] [-w] <numReplicas> <path>

# Changes the replication factor of a file. If path is a directory then the command recursively changes the replication factor of all files under the directory tree rooted at path.

# Options:

# The -w flag requests that the command wait for the replication to complete. This can potentially take a very long time.
# The -R flag is accepted for backwards compatibility. It has no effect.
# Example:

hdfs dfs -setrep -w 3 /user/hadoop/dir1
# Exit Code:

# Returns 0 on success and -1 on error.

# stat

# Usage:
hdfs dfs -stat URI [URI ...]

# Returns the stat information on the path.

# Example:

# hdfs dfs -stat path
# Exit Code: Returns 0 on success and -1 on error.

# tail

# Usage:
hdfs dfs -tail [-f] URI

# Displays last kilobyte of the file to stdout.

# Options:

# The -f option will output appended data as the file grows, as in Unix.
# Example:

# hdfs dfs -tail pathname
# Exit Code: Returns 0 on success and -1 on error.

# test

# Usage:

hdfs dfs -test -[ezd] URI

# Options:

# The -e option will check to see if the file exists, returning 0 if true.
# The -z option will check to see if the file is zero length, returning 0 if true.
# The -d option will check to see if the path is directory, returning 0 if true.
# Example:

 hdfs dfs -test -e filename
# text

# Usage:

 hdfs dfs -text <src>

# Takes a source file and outputs the file in text format. The allowed formats are zip and TextRecordInputStream.

# touchz

# Usage:

hdfs dfs -touchz URI [URI ...]

# Create a file of zero length.

# Example:

# hadoop -touchz pathname
# Exit Code: Returns 0 on success and -1 on error.#!/bin/bash

#安装

You can use a tool such as curl to access HDFS via HttpFS. For example, to obtain the home directory of the user babu, use a command such as this:

$ curl "http://localhost:14000/webhdfs/v1?op=gethomedirectory&user.name=babu"
You should see output such as this:

HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Set-Cookie: hadoop.auth="u=babu&p=babu&t=simple&e=1332977755010&s=JVfT4T785K4jeeLNWXK68rc/0xI="; Version=1; Path=/
Content-Type: application/json
Transfer-Encoding: chunked
Date: Wed, 28 Mar 2012 13:35:55 GMT

{"Path":"\/user\/babu"}

https://github.com/cloudera/httpfs
使用Git下载
git clone https://github.com/cloudera/httpfs.git

2.修改pom.xml文件
在<dependencies>中增加依赖
<dependency>
<groupId>org.apache.Hadoop</groupId>
<artifactId>hadoop-core</artifactId>
<version>${cdh.hadoop.version}</version>
</dependency>

3.下载所需要的依赖，
mvn clean:install
其中有些依赖的jar包已不在Cloudera的源上了，需要自己设置maven源，在~/.m2/setting.xml中增加自己的源

4.编译打包
mvn clean:install && mvn package -Pdist
生成的hadoop-hdfs-httpfs-0.20.2-cdh3u6.tar.gz包在target目录下

5.修改hadoop集群的所有机器的core-site.xml文件
在其中加入以下内容
<property>
<name>hadoop.proxyuser.httpfs.hosts</name>
<value>httpfs-host.foo.com</value>
</property>
<property>
<name>hadoop.proxyuser.httpfs.groups</name>
<value>*</value>
</property>
重启hadoop集群

6.在要安装httpfs的机器上创建httpfs用户
useradd --create-home --shell /bin/bash httpfs
passwd httpfs

7.安装httpfs
将hadoop-hdfs-httpfs-0.20.2-cdh3u6.tar.gz包复制到/home/httpfs目录下解压
进入到解压出来的目录hadoop-hdfs-httpfs-0.20.2-cdh3u6
将现网集群的hadoop配置文件core-site.xml和hdfs-site.xml复制到/home/httpfs/hadoop-hdfs-httpfs-0.20.2-cdh3u6/etc/hadoop目录下

8.修改httpfs-site.xml
在其中加入
<property>
<name>httpfs.proxyuser.httpfs.hosts</name>
<value>*</value>
</property>
<property>
<name>httpfs.proxyuser.httpfs.groups</name>
<value>*</value>
</property>

9.启动httpfs
使用httpfs用户启动
/home/httpfs/hadoop-hdfs-httpfs-0.20.2-cdh3u6/sbin/httpfs.sh start

10.检查
检查进程是否存在:jps看看有没有Bootstrap进程
查看logs目录下httpfs.log和其他log有无异常信息

11.curl测试
上传文件
curl -i -X PUT "http://172.16.61.154:14000/webhdfs/v1/tmp/testfile?user.name=bdws&op=create"
根据返回回来的URL再次put
curl -i -X PUT -T test.txt --header "Content-Type: application/octet-stream" "http://172.16.61.154:14000/webhdfs/v1/tmp/testfile?op=CREATE&user.name=bdws&data=true"
下载文件
curl -i "http://172.16.61.154:14000/webhdfs/v1/tmp/testfile?user.name=bdws&op=open"
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Set-Cookie: hadoop.auth="u=bdws&p=bdws&t=simple&e=1400181237161&s=F5K1C44TbM/tMjbdFUpM+zExtso="; Version=1; Path=/
Content-Type: application/octet-stream
Content-Length: 20
Date: Thu, 15 May 2014 09:13:57 GMT

this is a test file



1、WebHDFS是HDFS内置的、默认开启的一个服务，而HttpFS是HDFS一个独立的服务，若使用需要配置并手动开启。
2、HttpFS重在后面的GateWay。即WebHDFS面向的是集群中的所有节点，首先通过namenode，然后转发到相应的datanode，而HttpFS面向的是集群中的一个节点（相当于该节点被配置为HttpFS的GateWay）
3、WebHDFS是HortonWorks开发的，然后捐给了Apache；而HttpFS是Cloudera开发的，也捐给了Apache。

四、使用步骤：

1、使用WebHDFS的步骤：

（1）WebHDFS服务内置在HDFS中，不需额外安装、启动。需要在hdfs-site.xml打开WebHDFS开关，此开关默认打开。

<property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
</property>

（2）连接NameNode的50070端口进行文件操作。

curl "http://ctrl:50070/webhdfs/v1/?op=liststatus&user.name=root"


2、使用HttpFS GateWay的步骤：

（1）根据需求配置：httpfs-site.xml
（2）配置：hdfs-site.xml，需要增加如下配置，其他两个参数名称中的root代表的是启动hdfs服务的OS用户，应以实际的用户名称代替。

<property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
</property>
<property>
<name>hadoop.proxyuser.root.groups</name>
    <value>*</value>
</property>

（3）启动：

sbin/httpfs.sh start
sbin/httpfs.sh stop

启动后，默认监听14000端口：

[hadoop@master hadoop]# netstat -antp | grep 14000
tcp        0      0 :::14000   :::*       LISTEN      7415/java
[hadoop@master hadoop]#

（4）使用：

curl -i -L "http://xyz01.aiso.com:14000/webhdfs/v1/foo/bar?op=OPEN"




















#JAVA
   开源项目地址，有什么问题可以直接反馈给我

    https://github.com/gitriver/httpfs-client

   说明

   1  包com.catt.httpfs.client.httpclient是采用commons-httpclient.jar,
    基于http请求实现的，没有使用到hadoop相关的jar
    2  包org.apache.hadoop.fs.http.client根据httpfs项目的源代码，
    根据需要修改了一下，使用了hadoop相关的jar




#启动

curl -i  http://xyz01.aiso.com/webhdfs/v1?op=LISTSTATUS&user.name=xiaoyuzhou

curl -i -X  PUT  "http://xyz01.aiso.com:14000/webhdfs/v1/beifeng/httpfs?op=mkdirs&user.name=xiaoyuzhou"










#操作
  curl -c ~/.httpsauth "http://host:14000/webhdfs/v1?op=gethomedirectory&user.name=hdfs"

    curl -b ~/.httpsauth "http://host:14000/webhdfs/v1?op=gethomedirectory"

    curl -b ~/.httpsauth "http://host:14000/webhdfs/v1/test/data1.txt?op=OPEN"

    curl -b ~/.httpsauth -X DELETE "http://host:14000/webhdfs/v1/test/data1.txt?op=DELETE"

    创建和追加都是分为两步,测试都没有成功(注意，一定要追加--header参数，否则创建会失败)
    curl -b ~/.httpsauth -i -X PUT "http://172.168.63.221:14000/webhdfs/v1/test2?op=CREATE&buffersize=1000"
    curl -b ~/.httpsauth -i -X PUT -T data2.txt --header "Content-Type: application/octet-stream" "http://172.168.63.221:14000/webhdfs/v1/test2/data.txt?op=CREATE&user.name=hdfs&buffersize=1000&data=true"













~ $ tar xzf  httpfs-2.7.2.tar.gz
By default, HttpFS assumes that Hadoop configuration files (core-site.xml & hdfs-site.xml) are in the HttpFS configuration directory.

If this is not the case, add to the httpfs-site.xml file the httpfs.hadoop.config.dir property set to the location of the Hadoop configuration directory.

  <property>
    <name>hadoop.proxyuser.#HTTPFSUSER#.hosts</name>
    <value>httpfs-host.foo.com</value>
  </property>
  <property>
    <name>hadoop.proxyuser.#HTTPFSUSER#.groups</name>
    <value>*</value>
  </property>

  $ sbin/httpfs.sh start



  ~ $ curl -i "http://<HTTPFSHOSTNAME>:14000?user.name=babu&op=homedir"
HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"homeDir":"http:\/\/<HTTPFS_HOST>:14000\/user\/babu"}



HttpFS over HTTPS (SSL)

To configure HttpFS to work over SSL edit the httpfs-env.sh script in the configuration directory setting the HTTPFS_SSL_ENABLED to true.

In addition, the following 2 properties may be defined (shown with default values):

HTTPFS_SSL_KEYSTORE_FILE=$HOME/.keystore

HTTPFS_SSL_KEYSTORE_PASS=password

In the HttpFS tomcat/conf directory, replace the server.xml file with the ssl-server.xml file.

You need to create an SSL certificate for the HttpFS server. As the httpfs Unix user, using the Java keytool command to create the SSL certificate:

$ keytool -genkey -alias tomcat -keyalg RSA





$ curl http://httpfs-host:14000/webhdfs/v1/user/foo/README.txt returns the contents of the HDFS /user/foo/README.txt file.

$ curl http://httpfs-host:14000/webhdfs/v1/user/foo?op=list returns the contents of the HDFS /user/foo directory in JSON format.

$ curl -X POST http://httpfs-host:14000/webhdfs/v1/user/foo/bar?op=mkdirs creates the HDFS /user/foo.bar directory.






 webhdfs://<HOST>:<HTTP_PORT>/<PATH>

 hdfs://<HOST>:<RPC_PORT>/<PATH>

 http://<HOST>:<HTTP_PORT>/webhdfs/v1/<PATH>?op=...



Property Name	Description
dfs.webhdfs.enabled	Enable/disable WebHDFS in Namenodes and Datanodes
dfs.web.authentication.kerberos.principal	The HTTP Kerberos principal used by Hadoop-Auth in the HTTP endpoint. The HTTP Kerberos principal MUST start with 'HTTP/' per Kerberos HTTP SPNEGO specification.
dfs.web.authentication.kerberos.keytab	The Kerberos keytab file with the credentials for the HTTP Kerberos principal used by Hadoop-Auth in the HTTP endpoint.


Authentication when security is off:
curl -i "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?[user.name=<USER>&]op=..."
Authentication using Kerberos SPNEGO when security is on:
curl -i --negotiate -u : "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=..."
Authentication using Hadoop delegation token when security is on:
curl -i "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?delegation=<TOKEN>&op=..."





A proxy request when security is off:
curl -i "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?[user.name=<USER>&]doas=<USER>&op=..."
A proxy request using Kerberos SPNEGO when security is on:
curl -i --negotiate -u : "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?doas=<USER>&op=..."
A proxy request using Hadoop delegation token when security is on:
curl -i "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?delegation=<TOKEN>&op=..."







#Create and Write to a File

Step 1: Submit a HTTP PUT request without automatically following redirects and without sending the file data.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=CREATE
                    [&overwrite=<true|false>][&blocksize=<LONG>][&replication=<SHORT>]
                    [&permission=<OCTAL>][&buffersize=<INT>]"
The request is redirected to a datanode where the file data is to be written:

HTTP/1.1 307 TEMPORARY_REDIRECT
Location: http://<DATANODE>:<PORT>/webhdfs/v1/<PATH>?op=CREATE...
Content-Length: 0
Step 2: Submit another HTTP PUT request using the URL in the Location header with the file data to be written.
curl -i -X PUT -T <LOCAL_FILE> "http://<DATANODE>:<PORT>/webhdfs/v1/<PATH>?op=CREATE..."
The client receives a 201 Created response with zero content length and the WebHDFS URI of the file in the Location header:

HTTP/1.1 201 Created
Location: webhdfs://<HOST>:<PORT>/<PATH>
Content-Length: 0
Note that the reason of having two-step create/append is for preventing clients to send out data before the redirect. This issue is addressed by the "Expect: 100-continue" header in HTTP/1.1; see RFC 2616, Section 8.2.3. Unfortunately, there are software library bugs (e.g. Jetty 6 HTTP server and Java 6 HTTP client), which do not correctly implement "Expect: 100-continue". The two-step create/append is a temporary workaround for the software library bugs.

See also: overwrite, blocksize, replication, permission, buffersize, FileSystem.create



#Append to a File
Step 1: Submit a HTTP POST request without automatically following redirects and without sending the file data.
curl -i -X POST "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=APPEND[&buffersize=<INT>]"
The request is redirected to a datanode where the file data is to be appended:

HTTP/1.1 307 TEMPORARY_REDIRECT
Location: http://<DATANODE>:<PORT>/webhdfs/v1/<PATH>?op=APPEND...
Content-Length: 0
Step 2: Submit another HTTP POST request using the URL in the Location header with the file data to be appended.
curl -i -X POST -T <LOCAL_FILE> "http://<DATANODE>:<PORT>/webhdfs/v1/<PATH>?op=APPEND..."
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0
See the note in the previous section for the description of why this operation requires two steps.

See also: buffersize, FileSystem.append


# Concat File(s)
Submit a HTTP POST request.
curl -i -X POST "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=CONCAT&sources=<SOURCES>"
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0
This REST API call is available as of Hadoop version 2.0.3. Please note that SOURCES is a comma seperated list of absolute paths. (Example: sources=/test/file1,/test/file2,/test/file3)

See also: sources, FileSystem.concat




# Open and Read a File
Submit a HTTP GET request with automatically following redirects.
curl -i -L "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=OPEN
                    [&offset=<LONG>][&length=<LONG>][&buffersize=<INT>]"
The request is redirected to a datanode where the file data can be read:

HTTP/1.1 307 TEMPORARY_REDIRECT
Location: http://<DATANODE>:<PORT>/webhdfs/v1/<PATH>?op=OPEN...
Content-Length: 0
The client follows the redirect to the datanode and receives the file data:

HTTP/1.1 200 OK
Content-Type: application/octet-stream
Content-Length: 22

Hello, webhdfs user!
See also: offset, length, buffersize, FileSystem.open



# Make a Directory
Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/<PATH>?op=MKDIRS[&permission=<OCTAL>]"
The client receives a response with a boolean JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"boolean": true}
See also: permission, FileSystem.mkdirs





#Create a Symbolic Link

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/<PATH>?op=CREATESYMLINK
                              &destination=<PATH>[&createParent=<true|false>]"
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0
See also: destination, createParent, FileSystem.createSymlink

Rename a File/Directory

Submit a HTTP PUT request.
curl -i -X PUT "<HOST>:<PORT>/webhdfs/v1/<PATH>?op=RENAME&destination=<PATH>"
The client receives a response with a boolean JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"boolean": true}
See also: destination, FileSystem.rename

#Delete a File/Directory

Submit a HTTP DELETE request.
curl -i -X DELETE "http://<host>:<port>/webhdfs/v1/<path>?op=DELETE
                              [&recursive=<true|false>]"
The client receives a response with a boolean JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"boolean": true}
See also: recursive, FileSystem.delete

Status of a File/Directory

#Submit a HTTP GET request.
curl -i  "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=GETFILESTATUS"
The client receives a response with a FileStatus JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "FileStatus":
  {
    "accessTime"      : 0,
    "blockSize"       : 0,
    "group"           : "supergroup",
    "length"          : 0,             //in bytes, zero for directories
    "modificationTime": 1320173277227,
    "owner"           : "webuser",
    "pathSuffix"      : "",
    "permission"      : "777",
    "replication"     : 0,
    "type"            : "DIRECTORY"    //enum {FILE, DIRECTORY, SYMLINK}
  }
}
See also: FileSystem.getFileStatus

List a Directory

#Submit a HTTP GET request.
curl -i  "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=LISTSTATUS"
The client receives a response with a FileStatuses JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 427

{
  "FileStatuses":
  {
    "FileStatus":
    [
      {
        "accessTime"      : 1320171722771,
        "blockSize"       : 33554432,
        "group"           : "supergroup",
        "length"          : 24930,
        "modificationTime": 1320171722771,
        "owner"           : "webuser",
        "pathSuffix"      : "a.patch",
        "permission"      : "644",
        "replication"     : 1,
        "type"            : "FILE"
      },
      {
        "accessTime"      : 0,
        "blockSize"       : 0,
        "group"           : "supergroup",
        "length"          : 0,
        "modificationTime": 1320895981256,
        "owner"           : "szetszwo",
        "pathSuffix"      : "bar",
        "permission"      : "711",
        "replication"     : 0,
        "type"            : "DIRECTORY"
      },
      ...
    ]
  }
}
See also: FileSystem.listStatus





#Get Content Summary of a Directory

Submit a HTTP GET request.
curl -i "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=GETCONTENTSUMMARY"
The client receives a response with a ContentSummary JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "ContentSummary":
  {
    "directoryCount": 2,
    "fileCount"     : 1,
    "length"        : 24930,
    "quota"         : -1,
    "spaceConsumed" : 24930,
    "spaceQuota"    : -1
  }
}


#Get File Checksum
Submit a HTTP GET request.
curl -i "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=GETFILECHECKSUM"
The request is redirected to a datanode:

HTTP/1.1 307 TEMPORARY_REDIRECT
Location: http://<DATANODE>:<PORT>/webhdfs/v1/<PATH>?op=GETFILECHECKSUM...
Content-Length: 0
The client follows the redirect to the datanode and receives a FileChecksum JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "FileChecksum":
  {
    "algorithm": "MD5-of-1MD5-of-512CRC32",
    "bytes"    : "eadb10de24aa315748930df6e185c0d ...",
    "length"   : 28
  }
}


# Get Home Directory
Submit a HTTP GET request.
curl -i "http://<HOST>:<PORT>/webhdfs/v1/?op=GETHOMEDIRECTORY"
The client receives a response with a Path JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"Path": "/user/szetszwo"}




# Set Permission

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=SETPERMISSION
                              [&permission=<OCTAL>]"
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0





# Set Owner

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=SETOWNER
                              [&owner=<USER>][&group=<GROUP>]"
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0
See also: owner, group, FileSystem.setOwner

# Set Replication Factor

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=SETREPLICATION
                              [&replication=<SHORT>]"
The client receives a response with a boolean JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"boolean": true}



# Set Access or Modification Time

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?op=SETTIMES
                              [&modificationtime=<TIME>][&accesstime=<TIME>]"
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0
See also: modificationtime, accesstime, FileSystem.setTimes




# Get Delegation Token

Submit a HTTP GET request.
curl -i "http://<HOST>:<PORT>/webhdfs/v1/?op=GETDELEGATIONTOKEN&renewer=<USER>"
The client receives a response with a Token JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "Token":
  {
    "urlString": "JQAIaG9y..."
  }
}
See also: renewer, FileSystem.getDelegationToken





# Get Delegation Tokens

Submit a HTTP GET request.
curl -i "http://<HOST>:<PORT>/webhdfs/v1/?op=GETDELEGATIONTOKENS&renewer=<USER>"
The client receives a response with a Tokens JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{
  "Tokens":
  {
    "Token":
    [
      {
        "urlString":"KAAKSm9i ..."
      }
    ]
  }
}


# Renew Delegation Token

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/?op=RENEWDELEGATIONTOKEN&token=<TOKEN>"
The client receives a response with a long JSON object:

HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked

{"long": 1320962673997}           //the new expiration time


# Cancel Delegation Token

Submit a HTTP PUT request.
curl -i -X PUT "http://<HOST>:<PORT>/webhdfs/v1/?op=CANCELDELEGATIONTOKEN&token=<TOKEN>"
The client receives a response with zero content length:

HTTP/1.1 200 OK
Content-Length: 0



# Error Responses

When an operation fails, the server may throw an exception. The JSON schema of error responses is defined in RemoteException JSON schema. The table below shows the mapping from exceptions to HTTP response codes.

HTTP Response Codes

Exceptions	HTTP Response Codes
IllegalArgumentException	400 Bad Request
UnsupportedOperationException	400 Bad Request
SecurityException	401 Unauthorized
IOException	403 Forbidden
FileNotFoundException	404 Not Found
RumtimeException	500 Internal Server Error
Below are examples of exception responses.

Illegal Argument Exception

HTTP/1.1 400 Bad Request
Content-Type: application/json
Transfer-Encoding: chunked

{
  "RemoteException":
  {
    "exception"    : "IllegalArgumentException",
    "javaClassName": "java.lang.IllegalArgumentException",
    "message"      : "Invalid value for webhdfs parameter \"permission\": ..."
  }
}
Security Exception

HTTP/1.1 401 Unauthorized
Content-Type: application/json
Transfer-Encoding: chunked

{
  "RemoteException":
  {
    "exception"    : "SecurityException",
    "javaClassName": "java.lang.SecurityException",
    "message"      : "Failed to obtain user group information: ..."
  }
}
Access Control Exception

HTTP/1.1 403 Forbidden
Content-Type: application/json
Transfer-Encoding: chunked

{
  "RemoteException":
  {
    "exception"    : "AccessControlException",
    "javaClassName": "org.apache.hadoop.security.AccessControlException",
    "message"      : "Permission denied: ..."
  }
}
File Not Found Exception

HTTP/1.1 404 Not Found
Content-Type: application/json
Transfer-Encoding: chunked

{
  "RemoteException":
  {
    "exception"    : "FileNotFoundException",
    "javaClassName": "java.io.FileNotFoundException",
    "message"      : "File does not exist: /foo/a.patch"
  }
}



Boolean JSON Schema

{
  "name"      : "boolean",
  "properties":
  {
    "boolean":
    {
      "description": "A boolean value",
      "type"       : "boolean",
      "required"   : true
    }
  }
}
See also: MKDIRS, RENAME, DELETE, SETREPLICATION

ContentSummary JSON Schema

{
  "name"      : "ContentSummary",
  "properties":
  {
    "ContentSummary":
    {
      "type"      : "object",
      "properties":
      {
        "directoryCount":
        {
          "description": "The number of directories.",
          "type"       : "integer",
          "required"   : true
        },
        "fileCount":
        {
          "description": "The number of files.",
          "type"       : "integer",
          "required"   : true
        },
        "length":
        {
          "description": "The number of bytes used by the content.",
          "type"       : "integer",
          "required"   : true
        },
        "quota":
        {
          "description": "The namespace quota of this directory.",
          "type"       : "integer",
          "required"   : true
        },
        "spaceConsumed":
        {
          "description": "The disk space consumed by the content.",
          "type"       : "integer",
          "required"   : true
        },
        "spaceQuota":
        {
          "description": "The disk space quota.",
          "type"       : "integer",
          "required"   : true
        }
      }
    }
  }
}
See also: GETCONTENTSUMMARY

FileChecksum JSON Schema

{
  "name"      : "FileChecksum",
  "properties":
  {
    "FileChecksum":
    {
      "type"      : "object",
      "properties":
      {
        "algorithm":
        {
          "description": "The name of the checksum algorithm.",
          "type"       : "string",
          "required"   : true
        },
        "bytes":
        {
          "description": "The byte sequence of the checksum in hexadecimal.",
          "type"       : "string",
          "required"   : true
        },
        "length":
        {
          "description": "The length of the bytes (not the length of the string).",
          "type"       : "integer",
          "required"   : true
        }
      }
    }
  }
}
See also: GETFILECHECKSUM

FileStatus JSON Schema

{
  "name"      : "FileStatus",
  "properties":
  {
    "FileStatus": fileStatusProperties      //See FileStatus Properties
  }
}
See also: FileStatus Properties, GETFILESTATUS, FileStatus

FileStatus Properties

JavaScript syntax is used to define fileStatusProperties so that it can be referred in both FileStatus and FileStatuses JSON schemas.

var fileStatusProperties =
{
  "type"      : "object",
  "properties":
  {
    "accessTime":
    {
      "description": "The access time.",
      "type"       : "integer",
      "required"   : true
    },
    "blockSize":
    {
      "description": "The block size of a file.",
      "type"       : "integer",
      "required"   : true
    },
    "group":
    {
      "description": "The group owner.",
      "type"       : "string",
      "required"   : true
    },
    "length":
    {
      "description": "The number of bytes in a file.",
      "type"       : "integer",
      "required"   : true
    },
    "modificationTime":
    {
      "description": "The modification time.",
      "type"       : "integer",
      "required"   : true
    },
    "owner":
    {
      "description": "The user who is the owner.",
      "type"       : "string",
      "required"   : true
    },
    "pathSuffix":
    {
      "description": "The path suffix.",
      "type"       : "string",
      "required"   : true
    },
    "permission":
    {
      "description": "The permission represented as a octal string.",
      "type"       : "string",
      "required"   : true
    },
    "replication":
    {
      "description": "The number of replication of a file.",
      "type"       : "integer",
      "required"   : true
    },
   "symlink":                                         //an optional property
    {
      "description": "The link target of a symlink.",
      "type"       : "string"
    },
   "type":
    {
      "description": "The type of the path object.",
      "enum"       : ["FILE", "DIRECTORY", "SYMLINK"],
      "required"   : true
    }
  }
};
FileStatuses JSON Schema

A FileStatuses JSON object represents an array of FileStatus JSON objects.

{
  "name"      : "FileStatuses",
  "properties":
  {
    "FileStatuses":
    {
      "type"      : "object",
      "properties":
      {
        "FileStatus":
        {
          "description": "An array of FileStatus",
          "type"       : "array",
          "items"      : fileStatusProperties      //See FileStatus Properties
        }
      }
    }
  }
}
See also: FileStatus Properties, LISTSTATUS, FileStatus

Long JSON Schema

{
  "name"      : "long",
  "properties":
  {
    "long":
    {
      "description": "A long integer value",
      "type"       : "integer",
      "required"   : true
    }
  }
}
See also: RENEWDELEGATIONTOKEN,

# Path JSON Schema

{
  "name"      : "Path",
  "properties":
  {
    "Path":
    {
      "description": "The string representation a Path.",
      "type"       : "string",
      "required"   : true
    }
  }
}
See also: GETHOMEDIRECTORY, Path

RemoteException JSON Schema

{
  "name"      : "RemoteException",
  "properties":
  {
    "RemoteException":
    {
      "type"      : "object",
      "properties":
      {
        "exception":
        {
          "description": "Name of the exception",
          "type"       : "string",
          "required"   : true
        },
        "message":
        {
          "description": "Exception message",
          "type"       : "string",
          "required"   : true
        },
        "javaClassName":                                     //an optional property
        {
          "description": "Java class name of the exception",
          "type"       : "string",
        }
      }
    }
  }
}
See also: Error Responses

Token JSON Schema

{
  "name"      : "Token",
  "properties":
  {
    "Token": tokenProperties      //See Token Properties
  }
}
See also: Token Properties, GETDELEGATIONTOKEN, the note in Delegation.

Token Properties

JavaScript syntax is used to define tokenProperties so that it can be referred in both Token and Tokens JSON schemas.

var tokenProperties =
{
  "type"      : "object",
  "properties":
  {
    "urlString":
    {
      "description": "A delegation token encoded as a URL safe string.",
      "type"       : "string",
      "required"   : true
    }
  }
}
Tokens JSON Schema

A Tokens JSON object represents an array of Token JSON objects.

{
  "name"      : "Tokens",
  "properties":
  {
    "Tokens":
    {
      "type"      : "object",
      "properties":
      {
        "Token":
        {
          "description": "An array of Token",
          "type"       : "array",
          "items"      : "Token": tokenProperties      //See Token Properties
        }
      }
    }
  }
}
See also: Token Properties, GETDELEGATIONTOKENS, the note in Delegation.

HTTP Query Parameter Dictionary

Access Time

Name	accesstime
Description	The access time of a file/directory.
Type	long
Default Value	-1 (means keeping it unchanged)
Valid Values	-1 or a timestamp
Syntax	Any integer.
See also: SETTIMES

Block Size

Name	blocksize
Description	The block size of a file.
Type	long
Default Value	Specified in the configuration.
Valid Values	> 0
Syntax	Any integer.
See also: CREATE

Buffer Size

Name	buffersize
Description	The size of the buffer used in transferring data.
Type	int
Default Value	Specified in the configuration.
Valid Values	> 0
Syntax	Any integer.
See also: CREATE, APPEND, OPEN

Create Parent

Name	createparent
Description	If the parent directories do not exist, should they be created?
Type	boolean
Default Value	false
Valid Values	true
Syntax	true
See also: CREATESYMLINK

Delegation

Name	delegation
Description	The delegation token used for authentication.
Type	String
Default Value	<empty>
Valid Values	An encoded token.
Syntax	See the note below.
Note that delegation tokens are encoded as a URL safe string; see encodeToUrlString() and decodeFromUrlString(String) in org.apache.hadoop.security.token.Token for the details of the encoding.

See also: Authentication

Destination

Name	destination
Description	The destination path.
Type	Path
Default Value	<empty> (an invalid path)
Valid Values	An absolute FileSystem path without scheme and authority.
Syntax	Any path.
See also: CREATESYMLINK, RENAME

Do As

Name	doas
Description	Allowing a proxy user to do as another user.
Type	String
Default Value	null
Valid Values	Any valid username.
Syntax	Any string.
See also: Proxy Users

Group

Name	group
Description	The name of a group.
Type	String
Default Value	<empty> (means keeping it unchanged)
Valid Values	Any valid group name.
Syntax	Any string.
See also: SETOWNER

Length

Name	length
Description	The number of bytes to be processed.
Type	long
Default Value	null (means the entire file)
Valid Values	>= 0 or null
Syntax	Any integer.
See also: OPEN

Modification Time

Name	modificationtime
Description	The modification time of a file/directory.
Type	long
Default Value	-1 (means keeping it unchanged)
Valid Values	-1 or a timestamp
Syntax	Any integer.
See also: SETTIMES

Offset

Name	offset
Description	The starting byte position.
Type	long
Default Value	0
Valid Values	>= 0
Syntax	Any integer.
See also: OPEN

Op

Name	op
Description	The name of the operation to be executed.
Type	enum
Default Value	null (an invalid value)
Valid Values	Any valid operation name.
Syntax	Any string.
See also: Operations

Overwrite

Name	overwrite
Description	If a file already exists, should it be overwritten?
Type	boolean
Default Value	false
Valid Values	true
Syntax	true
See also: CREATE

Owner

Name	owner
Description	The username who is the owner of a file/directory.
Type	String
Default Value	<empty> (means keeping it unchanged)
Valid Values	Any valid username.
Syntax	Any string.
See also: SETOWNER

Permission

Name	permission
Description	The permission of a file/directory.
Type	Octal
Default Value	755
Valid Values	0 - 1777
Syntax	Any radix-8 integer (leading zeros may be omitted.)
See also: CREATE, MKDIRS, SETPERMISSION

Recursive

Name	recursive
Description	Should the operation act on the content in the subdirectories?
Type	boolean
Default Value	false
Valid Values	true
Syntax	true
See also: RENAME

Renewer

Name	renewer
Description	The username of the renewer of a delegation token.
Type	String
Default Value	<empty> (means the current user)
Valid Values	Any valid username.
Syntax	Any string.
See also: GETDELEGATIONTOKEN, GETDELEGATIONTOKENS

Replication

Name	replication
Description	The number of replications of a file.
Type	short
Default Value	Specified in the configuration.
Valid Values	> 0
Syntax	Any integer.
See also: CREATE, SETREPLICATION

Sources

Name	sources
Description	The comma seperated absolute paths used for concatenation.
Type	String
Default Value	<empty>
Valid Values	A list of comma seperated absolute FileSystem paths without scheme and authority.
Syntax	See the note in Delegation.
Note that sources are absolute FileSystem paths.

See also: CONCAT

Token

Name	token
Description	The delegation token used for the operation.
Type	String
Default Value	<empty>
Valid Values	An encoded token.
Syntax	See the note in Delegation.
See also: RENEWDELEGATIONTOKEN, CANCELDELEGATIONTOKEN

Username

Name	user.name
Description	The authenticated user; see Authentication.
Type	String
Default Value	null
Valid Values	Any valid username.
Syntax	Any string.




























#!/bin/bash
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'

cd $HADOOP_HOME

sudo rm -rf logs
sudo rm -rf share/doc
sudo rm -rf bin/*.cmd
sudo rm -rf sbin/*.cmd
sudo rm -rf etc/hadoop/*.cmd
sudo mkdir -p tmp/data
#鍦╟ore-site.xml閰嶇疆鏈烘灦鎰熺煡
bin/hdfs namenode -format
#!/bin/bash

sudo apt-get install liblzo2-dev

dpkg -L liblzo2-2  (查看安装包的位置)

/.
/usr
/usr/lib
/usr/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu/liblzo2.so.2.0.0
/usr/share
/usr/share/doc
/usr/share/doc/liblzo2-2
/usr/share/doc/liblzo2-2/THANKS
/usr/share/doc/liblzo2-2/AUTHORS
/usr/share/doc/liblzo2-2/changelog.Debian.gz
/usr/share/doc/liblzo2-2/copyright
/usr/share/doc/liblzo2-2/LZO.TXT.gz
/usr/lib/x86_64-linux-gnu/liblzo2.so.2

wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz

tar -xzvf lzo-2.09.tar.gz
cd lzo-2.09
export CFLAGS=-m64 (字段64位操作系统)
./configure --enable-shared --prefix /usr/local/lzo-2.09
make && sudo make install

sudo apt-get install lzop

 C_INCLUDE_PATH=/usr/local/lzo-2.09/include/ \
   > LIBRARY_PATH=/usr/local/lzo-2.09/lib/ \
   > CXXFLAGS=-m64 \
   > mvn clean package  (修改hadoop.version为对应正确的版本)


tar -cBf - -C target/native/Linux-amd64-64/lib . | tar -xBvf - -C ~/modules/hadoop-2.6.0/lib/native/

cp ${HADOOP_LZO_HOME}/target/hadoop-lzo-0.4.20-SNAPSHOT.jar  ${HADOOP_HOME}/share/hadoop/common/lib/
source /etc/profile




9  同步以上操作至其它节点

复制代码
 scp lzo-2.09.tar.gz  hadoop-slave1:/home/hadoop/
 scp lzo-2.09.tar.gz  hadoop-slave2:/home/hadoop/

 ./configure --enable-shared --prefix /usr/local/lzo-2.09
 make && sudo make install

 sudo apt-get install liblzo2-dev
 sudo apt-get install lzop

 scp -r libgpl* hadoop-slave1:/home/hadoop/modules/hadoop-2.6.0/lib/native/
 scp -r libgpl* hadoop-slave2:/home/hadoop/modules/hadoop-2.6.0/lib/native/

 scp   $HADOOP-LZO-HOME/target/hadoop-lzo-0.4.20-SNAPSHOT.jar hadoop-slave1:$HADOOP_HOME/share/hadoop/common/lib/
 scp   $HADOOP-LZO-HOME/target/hadoop-lzo-0.4.20-SNAPSHOT.jar hadoop-slave1:$HADOOP_HOME/share/hadoop/common/lib/
 source /etc/profile
复制代码





10 更新hadoop配置文件

   (1)在文件$HADOOP_HOME/etc/hadoop/hadoop-env.sh中追加如下内容：
# add lzo environment variables
export LD_LIBRARY_PATH=/usr/local/lzo-2.09/lib
   (2)修改core-size.xml


复制代码
      <property>
        <name>io.compression.codecs </name>
        <value>org.apache.hadoop.io.compress.GzipCodec,
          org.apache.hadoop.io.compress.DefaultCodec,
          com.hadoop.compression.lzo.LzoCodec,
          com.hadoop.compression.lzo.LzopCodec,
          org.apache.hadoop.io.compress.BZip2Codec,
          org.apache.hadoop.io.compress.SnappyCodec</value>
      </property>
      <property>
        <name>io.compression.codec.lzo.class </name>
        <value>com.hadoop.compression.lzo.LzoCodec</value>
      </property>
复制代码
   (3)修改mapred-site.xml

复制代码
      <property>
       <name>mapred.child.env </name>
        <value>LD_LIBRARY_PATH =/usr/local/lzo-2.09/lib </value>
      </property>
       <property>
        <name>mapreduce.map.output.compress</name>
        <value>true</value>
      </property>
      <property>
        <name>mapreduce.map.output.compress.codec</name>
        <value>com.hadoop.compression.lzo.LzoCodec</value>
      </property>
      <property>
       <name>mapreduce.output.fileoutputformat.compress.type</name>
       <value>BLOCK</value>
      </property>
      <property>
       <name>mapreduce.output.fileoutputformat.compress</name>
       <value>false</value>
      </property>
      <property>
       <name>mapreduce.output.fileoutputformat.compress.codec</name>
       <value>org.apache.hadoop.io.compress.DefaultCodec</value>
      </property>
复制代码
 PS:

       中间结果压缩

hadoop设置或者hive设置	属性名称(最新名称)	默认值	过时属性名称
hadoop job	mapreduce.map.output.compress	false	mapred.compress.map.output
mapreduce.map.output.compress.codec	org.apache.hadoop.io.compress.DefaultCodec
mapred.map.output.compression.codec
hive 　　job	hive.exec.compress.intermediate	false

       最终输出结果压缩

hadoop设置或者hive设置	属性名称(最新名称)	默认值	过时属性名称
hadoop job	mapreduce.output.fileoutputformat.compress	 false	mapred.output.compress
mapreduce.output.fileoutputformat.compress.type	RECORD	mapred.output.compression.type
mapreduce.output.fileoutputformat.compress.codec	org.apache.hadoop.io.compress.DefaultCodec	mapred.output.compression.codec
hive       job	hive.exec.compress.output	false

11  hive创建支持存储lzo压缩数据的测试表

复制代码
    CREATE TABLE rawdata(
      appkey string, uid string, uidtype string
    )
    COMMENT 'This is the staging of raw data'
    PARTITIONED BY (day INT)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
    STORED AS INPUTFORMAT
      'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
    OUTPUTFORMAT
      'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';
复制代码












#!/bin/bash
BASE='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'
BASEPATH='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/bin'

cd $BASE
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0-cdh5.3.6.jar pi 2 10

# bin/hadoop jar hadoop-*-examples.jar grep input output 'dfs[a-z.]+'

# $BASEPATH/hdfs dfs -mkdir -p /mr/input/

# $BASEPATH/hdfs dfs -put /opt/data/wc.input /mr/input


#$BASEPATH/hdfs dfs -rm -r /mr/output

# $BASEPATH/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0-cdh5.3.6.jar wordcount  /mr/input    /mr/output


# $BASEPATH/hadoop jar $BASE/jars/mr-wordcount.jar template.WordCountApp  /mr/input    /mr/output

# $BASEPATH/hadoop jar $BASE/jars/hadoop-mapreduce-01.jar template.WordCountApp

#!/bin/bash

# 安全模式是hadoop的一种保护机制，用于保证集群中的数据块的安全性。



# 正常情况下，安全模式会运行一段时间自动退出的，只需要我们稍等一会就行了，到底等多长时间呢，我们可以通过50070端口查看安全模式退出的剩余时间，如图

# 虽然不能进行修改文件的操作，但是可以浏览目录结构、查看文件内容的。

# 在命令行下是可以控制安全模式的进入、退出和查看的。
# 命令 hadoop fs -safemode get 查看安全模式状态
# 命令 hadoop fs -safemode enter  进入安全模式状态
# 命令 hadoop fs -safemode leave 离开安全模式

 # 安全模式是hadoop的一种保护机制，在启动时，最好是等待集群自动退出，然后进行文件操作。

 #!/bin/bash
HADOOP_HOME='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6'

if [ ! -d "$HADOOP_HOME" ]; then
  echo "HADOOP_HOME is not exist"
   exit 1
fi

ssh xiaoyuzhou@xyz02.aiso.com rm -rf $HADOOP_HOME/etc  &&  scp -r $HADOOP_HOME/etc xiaoyuzhou@xyz02.aiso.com:$HADOOP_HOME/

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $HADOOP_HOME/etc  &&  scp -r $HADOOP_HOME/etc xiaoyuzhou@xyz03.aiso.com:$HADOOP_HOME/


ssh xiaoyuzhou@xyz02.aiso.com rm -rf $HADOOP_HOME/lib  &&  scp -r $HADOOP_HOME/lib xiaoyuzhou@xyz02.aiso.com:$HADOOP_HOME/

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $HADOOP_HOME/lib  &&  scp -r $HADOOP_HOME/lib xiaoyuzhou@xyz03.aiso.com:$HADOOP_HOME/


echo "successful!"#!/bin/bash

# sudo chmod u+w /etc/sudoers
# sudo vi /etc/sudoers
# #注释掉 Default requiretty

ssh xiaoyuzhou@xyz02.aiso.com sudo /sbin/shutdown -h now && ssh xiaoyuzhou@xyz03.aiso.com sudo /sbin/shutdown -h now && sudo /sbin/shutdown -h now
#!/bin/bash
BASEPATH='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/sbin'

$BASEPATH/start-dfs.sh && $BASEPATH/start-yarn.sh && $BASEPATH/httpfs.sh start

 if [[ $? -ne 0 ]]
		then exit
 fi

ssh xiaoyuzhou@xyz03.aiso.com $BASEPATH/mr-jobhistory-daemon.sh start historyserver#!/bin/bash
BASEPATH='/opt/module/cdh-5.3.6-ha/hadoop-2.5.0-cdh5.3.6/sbin'

$BASEPATH/stop-dfs.sh && $BASEPATH/stop-yarn.sh && $BASEPATH/httpfs.sh stop

# $BASEPATH/hadoop-daemon.sh stop namenode
# $BASEPATH/hadoop-daemon.sh stop datanode
# $BASEPATH/hadoop-daemon.sh stop secondarynamenode
# $BASEPATH/yarn-daemon.sh stop resourcemanager
# $BASEPATH/yarn-daemon.sh stop nodemanager


 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com $BASEPATH/mr-jobhistory-daemon.sh stop historyserver

