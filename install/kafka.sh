#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

cd $KFK_HOME
bin/kafka-topics.sh --create --zookeeper xyz01.aiso.com:2181,xyz02.aiso.com:2181,xyz03.aiso.com:2181 --replication-factor 1 --partitions 1 --topic WordCount


bin/kafka-console-producer.sh --broker-list xyz01.aiso.com:9092,xyz02.aiso.com:9092,xyz03.aiso.com:9092 --topic WordCount#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'


 # wget http://www.slf4j.org/dist/slf4j-1.7.6.zip
 # unzip slf4j-1.7.6.zip
 # cp slf4j-nop-1.7.6.jar $KFK_HOME/libs/



# mkdir -p data/kafka-logs
sudo chown -R xiaoyuzhou:xiaoyuzhou ./*

# Setting up a multi-broker-cluster.sh
# cp config/server.properties config/server-1.properties
# cp config/server.properties config/server-2.properties


# config/server-1.properties:
    # broker.id=1
    # listeners=PLAINTEXT://:9093
    # log.dir=/tmp/kafka-logs-1

# config/server-2.properties:
    # broker.id=2
    # listeners=PLAINTEXT://:9094
    # log.dir=/tmp/kafka-logs-2











#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'


# scp -r $KFK_HOME xiaoyuzhou@xyz02.aiso.com:/opt/module/cdh-5.3.6-ha/
# scp -r $KFK_HOME xiaoyuzhou@xyz03.aiso.com:/opt/module/cdh-5.3.6-ha/

if [ ! -d "$KFK_HOME" ]; then
  echo "KFK_HOME is not exist"
   exit 1
fi

ssh xiaoyuzhou@xyz02.aiso.com rm -rf $KFK_HOME/config/producer.properties  &&  scp -r $KFK_HOME/config/producer.properties xiaoyuzhou@xyz02.aiso.com:$KFK_HOME/config

 if [[ $? -ne 0 ]]
		then exit
 fi


ssh xiaoyuzhou@xyz03.aiso.com rm -rf $KFK_HOME/config/producer.properties  &&  scp -r $KFK_HOME/config/producer.properties xiaoyuzhou@xyz03.aiso.com:$KFK_HOME/config




echo "successful!"#!/bin/bash
ZK_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

# sh $ZK_HOME/start.sh



# 启动Kafka集群
# bin/zookeeper-server-start.sh config/zookeeper.properties

nohup $KFK_HOME/bin/kafka-server-start.sh -daemon  $KFK_HOME/config/server.properties >/dev/null 2>&1 &

 # bin/kafka-server-start.sh  config/server.properties &

# ps -ef | grep java


 # cd $KFK_HOME/bin
 # ./kafka-server-start.sh -daemon ../config/server.properties &


ssh xiaoyuzhou@xyz02.aiso.com "nohup $KFK_HOME/bin/kafka-server-start.sh -daemon  $KFK_HOME/config/server.properties >/dev/null 2>&1 &"

ssh xiaoyuzhou@xyz03.aiso.com  "nohup $KFK_HOME/bin/kafka-server-start.sh -daemon  $KFK_HOME/config/server.properties >/dev/null 2>&1 &"

#!/bin/bash
ZK_HOME='/opt/module/cdh-5.3.6-ha/zookeeper-3.4.5-cdh5.3.6'
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

# sh $ZK_HOME/stop.sh

# cd $KFK_HOME/bin
$KFK_HOME/bin/kafka-server-stop.sh


ssh xiaoyuzhou@xyz02.aiso.com "$KFK_HOME/bin/kafka-server-stop.sh"

ssh xiaoyuzhou@xyz03.aiso.com  "$KFK_HOME/bin/kafka-server-stop.sh"

#################

#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

cd $KFK_HOME


# broker.properties.
allow.everyone.if.no.acl.found=true

super.users=User:Bob;User:Alice

principal.builder.class=CustomizedPrincipalBuilderClass


sasl.kerberos.principal.to.local.rules=RULE:[1:$1@$0](.*@MYDOMAIN.COM)s/@.*//,DEFAULT


# Option	Description	Default	Option type
# --add	Indicates to the script that user is trying to add an acl.		Action
# --remove	Indicates to the script that user is trying to remove an acl.		Action
# --list	Indicates to the script that user is trying to list acls.		Action
# --authorizer	Fully qualified class name of the authorizer.	kafka.security.auth.SimpleAclAuthorizer	Configuration
# --authorizer-properties	key=val pairs that will be passed to authorizer for initialization. For the default authorizer the example values are: zookeeper.connect=localhost:2181		Configuration
# --cluster	Specifies cluster as resource.		Resource
# --topic [topic-name]	Specifies the topic as resource.		Resource
# --group [group-name]	Specifies the consumer-group as resource.		Resource
# --allow-principal	Principal is in PrincipalType:name format that will be added to ACL with Allow permission.
# You can specify multiple --allow-principal in a single command.		Principal
# --deny-principal	Principal is in PrincipalType:name format that will be added to ACL with Deny permission.
# You can specify multiple --deny-principal in a single command.		Principal
# --allow-host	IP address from which principals listed in --allow-principal will have access.	if --allow-principal is specified defaults to * which translates to "all hosts"	Host
# --deny-host	IP address from which principals listed in --deny-principal will be denied access.	if --deny-principal is specified defaults to * which translates to "all hosts"	Host
# --operation	Operation that will be allowed or denied.
# Valid values are : Read, Write, Create, Delete, Alter, Describe, ClusterAction, All	All	Operation
# --producer	Convenience option to add/remove acls for producer role. This will generate acls that allows WRITE, DESCRIBE on topic and CREATE on cluster.		Convenience
# --consumer	Convenience option to add/remove acls for consumer role. This will generate acls that allows READ, DESCRIBE on topic and READ on consumer-group.		Convenience


bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic

 bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic

 bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic

  bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --producer --topic Test-topic


   bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --consumer --topic test-topic --group Group-1


#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

cd $KFK_HOME

echo -e "foo\nbar" > test.txt

bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties

 cat test.sink.txt


  bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic connect-test --from-beginning

   echo "Another line" >> test.txtserver.log #kafka的运行日志
state-change.log  #kafka他是用zookeeper来保存状态，所以他可能会进行切换，切换的日志就保存在这里

controller.log #kafka选择一个节点作为“controller”,当发现有节点down掉的时候它负责在游泳分区的所有节点中选择新的leader,这使得Kafka可以批量的高效的管理所有分区节点的主从关系。如果controller down掉了，活着的节点中的一个会备切换为新的controller.#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

cd $KFK_HOME


bin/kafka-server-start.sh config/server-1.properties &

bin/kafka-server-start.sh config/server-2.properties &


bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic my-replicated-topic


 bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic



 bin/kafka-console-consumer.sh --zookeeper localhost:2181 --from-beginning --topic my-replicated-topic

 ps | grep server-1.properties

 kill -9 7564


 bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic


 bin/kafka-console-consumer.sh --zookeeper localhost:2181 --from-beginning --topic my-replicated-topic
 #!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

cd $KFK_HOME

# KTable wordCounts = textLines
    # // Split each text line, by whitespace, into words.
    # .flatMapValues(value -> Arrays.asList(value.toLowerCase().split("\\W+")))

    # // Ensure the words are available as record keys for the next aggregate operation.
    # .map((key, value) -> new KeyValue<>(value, value))

    # // Count the occurrences of each word (record key) and store the results into a table named "Counts".
    # .countByKey("Counts")

 echo -e "all streams lead to kafka\nhello kafka streams\njoin kafka summit" > file-input.txt

  bin/kafka-topics.sh --create \
            --zookeeper localhost:2181 \
            --replication-factor 1 \
            --partitions 1 \
            --topic streams-file-input

cat file-input.txt | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-file-input

bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo


 bin/kafka-console-consumer.sh --zookeeper localhost:2181 \
            --topic streams-wordcount-output \
            --from-beginning \
            --formatter kafka.tools.DefaultMessageFormatter \
            --property print.key=true \
            --property print.value=true \
            --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
            --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer



#!/bin/bash
KFK_HOME='/opt/module/cdh-5.3.6-ha/kafka_2.9.2-0.8.1'

cd $KFK_HOME
#####################################producer##################
# 生产数据
bin/kafka-console-producer.sh --broker-list xyz01.aiso.com:9092 --topic WordCount
# bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test



#####################################topic#####################################
###'''在一台服务器上创建一个发布者'''
#创建一个broker，发布者
bin/kafka-console-producer.sh --broker-list xyz01.aiso.com:9092 --topic shuaige

# 创建topic命令
bin/kafka-topics.sh --create --zookeeper xyz01.aiso.com:2181 --replication-factor 1 --partitions 1 --topic WordCount


# bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test

# bin/kafka-topics.sh --list --zookeeper localhost:2181


bin/kafka-topics.sh --create --zookeeper xyz01.aiso.com:2181 --replication-factor 2 --partitions 1 --topic shuaige


# 查看topic
bin/kafka-topics.sh --list --zookeeper localhost:2181
#就会显示我们创建的所有topic

# 查看topic状态
bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic shuaige


# 查看已用topic
bin/kafka-topics.sh --list --zookeeper xyz01.aiso.com:2181
#就会显示我们创建的所有topic

#解释
--replication-factor 2   #复制两份
--partitions 1 #创建1个分区
--topic #主题为shuaige


#下面是显示信息
# Topic:ssports    PartitionCount:1    ReplicationFactor:2    Configs:
    # Topic: shuaige    Partition: 0    Leader: 1    Replicas: 0,1    Isr: 1
#分区为为1  复制因子为2   他的  shuaige的分区为0
#Replicas: 0,1   复制的为0，1
#


####################################consumer##################################

# 消费数据
bin/kafka-console-consumer.sh --zookeeper xyz01.aiso.com:2181 --topic test --from-beginning


# '''在一台服务器上创建一个订阅者'''
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic shuaige --from-beginning


