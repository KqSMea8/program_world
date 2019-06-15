





bin/kafka-server-stop.sh || true
vagrant/broker.sh:43:bin/kafka-server-start.sh $kafka_dir/config/server-$BROKER_ID.properties 1>> /tmp/broker.log 2>> /tmp/broker.log &
vagrant/README.md:54:    bin/kafka-topics.sh --create --zookeeper 192.168.50.11:2181 --replication-factor 3 --partitions 1 --topic sandbox
vagrant/README.md:57:    bin/kafka-console-producer.sh --broker-list broker1:9092,broker2:9092,broker3:9092 --topic sandbox
vagrant/README.md:60:    bin/kafka-console-consumer.sh --zookeeper zk1:2181 --topic sandbox --from-beginning
streams/examples/src/main/java/org/apache/kafka/streams/examples/pipe/PipeDemo.java:36: * bin/kafka-topics.sh --create ...), and write some data to the input topic (e.g. via
bin/kafka-console-producer.sh). Otherwise you won't see any data arriving in the output topic.
 * bin/kafka-topics --create ...), and write some data to the input topics (e.g. via
streams/examples/src/main/java/org/apache/kafka/streams/examples/pageview/PageViewTypedDemo.java:55: * bin/kafka-console-producer). Otherwise you won't see any data arriving in the output topic.
streams/examples/src/main/java/org/apache/kafka/streams/examples/pageview/PageViewTypedDemo.java:66: * To observe the results, read the output topic (e.g., via bin/kafka-console-consumer)
streams/examples/src/main/java/org/apache/kafka/streams/examples/pageview/PageViewUntypedDemo.java:53: * bin/kafka-topics.sh --create ...), and write some data to the input topics (e.g. via
streams/examples/src/main/java/org/apache/kafka/streams/examples/pageview/PageViewUntypedDemo.java:54: * bin/kafka-console-producer.sh). Otherwise you won't see any data arriving in the output topic.
streams/examples/src/main/java/org/apache/kafka/streams/examples/temperature/TemperatureDemo.java:46: * bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic iot-temperature
streams/examples/src/main/java/org/apache/kafka/streams/examples/temperature/TemperatureDemo.java:50: * bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic iot-temperature-max
streams/examples/src/main/java/org/apache/kafka/streams/examples/temperature/TemperatureDemo.java:54: * bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic iot-temperature-max --from-beginning
streams/examples/src/main/java/org/apache/kafka/streams/examples/temperature/TemperatureDemo.java:59: * bin/kafka-console-producer.sh --broker-list localhost:9092 --topic iot-temperature
streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountProcessorDemo.java:50: * {@code bin/kafka-topics.sh --create ...}), and write some data to the input topic (e.g. via
streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountProcessorDemo.java:51: * {@code bin/kafka-console-producer.sh}). Otherwise you won't see any data arriving in the output topic.
streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java:42: * {@code bin/kafka-topics.sh --create ...}), and write some data to the input topic (e.g. via
streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java:43: * {@code bin/kafka-console-producer.sh}). Otherwise you won't see any data arriving in the output topic.
tests/unit/directory_layout/check_project_paths.py:61:        assert resolver.script("kafka-run-class.sh") == "/opt/kafka-dev/bin/kafka-run-class.sh"
tests/unit/directory_layout/check_project_paths.py:69:        assert resolver.script("kafka-run-class.sh", V_0_9_0_1) == "/opt/kafka-0.9.0.1/bin/kafka-run-class.sh"
Binary file .git/index matches
docs/security.html:64:        bin/kafka-configs.sh --bootstrap-server localhost:9093 --entity-type brokers --entity-name 0 --alter --add-config "listener.name.internal.ssl.endpoint.identification.algorithm="
docs/security.html:580:    > bin/kafka-configs.sh --zookeeper localhost:2181 --alter --add-config 'SCRAM-SHA-256=[iterations=8192,password=alice-secret],SCRAM-SHA-512=[password=alice-secret]' --entity-type users --entity-name alice
docs/security.html:587:    > bin/kafka-configs.sh --zookeeper localhost:2181 --alter --add-config 'SCRAM-SHA-256=[password=admin-secret],SCRAM-SHA-512=[password=admin-secret]' --entity-type users --entity-name admin
docs/security.html:591:    > bin/kafka-configs.sh --zookeeper localhost:2181 --describe --entity-type users --entity-name alice
docs/security.html:595:    > bin/kafka-configs.sh --zookeeper localhost:2181 --alter --delete-config 'SCRAM-SHA-512' --entity-type users --entity-name alice
docs/security.html:953:    > bin/kafka-delegation-tokens.sh --bootstrap-server localhost:9092 --create   --max-life-time-period -1 --command-config client.properties --renewer-principal User:user1
docs/security.html:957:    > bin/kafka-delegation-tokens.sh --bootstrap-server localhost:9092 --renew    --renew-time-period -1 --command-config client.properties --hmac ABCDEFGHIJK
docs/security.html:961:    > bin/kafka-delegation-tokens.sh --bootstrap-server localhost:9092 --expire   --expiry-time-period -1   --command-config client.properties  --hmac ABCDEFGHIJK
docs/security.html:965:    > bin/kafka-delegation-tokens.sh --bootstrap-server localhost:9092 --describe --command-config client.properties  --owner-principal User:user1
docs/security.html:1246:            <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic</pre>
docs/security.html:1248:            <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:* --allow-host * --deny-principal User:BadBob --deny-host 198.51.100.3 --operation Read --topic Test-topic</pre>
docs/security.html:1253:            <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Peter --allow-host 198.51.200.1 --producer --topic *</pre>
docs/security.html:1256:            <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Jane --producer --topic Test- --resource-pattern-type prefixed</pre>
docs/security.html:1261:            <pre class="brush: bash;"> bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Bob --allow-principal User:Alice --allow-host 198.51.100.0 --allow-host 198.51.100.1 --operation Read --operation Write --topic Test-topic </pre>
docs/security.html:1263:            <pre class="brush: bash;"> bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:Jane --producer --topic Test- --resource-pattern-type Prefixed</pre></li>
docs/security.html:1267:                <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic</pre>
docs/security.html:1270:                <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic *</pre>
docs/security.html:1273:                <pre class="brush: bash;">bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --list --topic Test-topic --resource-pattern-type match</pre>
docs/security.html:1278:            <pre class="brush: bash;"> bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --producer --topic Test-topic</pre>
docs/security.html:1280:            <pre class="brush: bash;"> bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:Bob --consumer --topic Test-topic --group Group-1 </pre>
docs/security.html:1289:            bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --add --allow-principal User:Bob --producer --topic Test-topic
docs/security.html:1290:            bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --add --allow-principal User:Bob --consumer --topic Test-topic --group Group-1
docs/security.html:1291:            bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /tmp/adminclient-configs.conf --list --topic Test-topic</pre></li>
docs/ops.html:31:  &gt; bin/kafka-topics.sh --bootstrap-server broker_host:port --create --topic my_topic_name \
docs/ops.html:48:  &gt; bin/kafka-topics.sh --bootstrap-server broker_host:port --alter --topic my_topic_name \
docs/ops.html:55:  &gt; bin/kafka-configs.sh --bootstrap-server broker_host:port --entity-type topics --entity-name my_topic_name --alter --add-config x=y
docs/ops.html:59:  &gt; bin/kafka-configs.sh --bootstrap-server broker_host:port --entity-type topics --entity-name my_topic_name --alter --delete-config x
docs/ops.html:63:  &gt; bin/kafka-topics.sh --bootstrap-server broker_host:port --delete --topic my_topic_name
docs/ops.html:92:  &gt; bin/kafka-preferred-replica-election.sh --zookeeper zk_host:port/chroot
docs/ops.html:125:  &gt; bin/kafka-mirror-maker.sh
docs/ops.html:136:  &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
docs/ops.html:151:  &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
docs/ops.html:159:  &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group
docs/ops.html:174:      &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --members
docs/ops.html:185:      &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --members --verbose
docs/ops.html:197:      &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group --state
docs/ops.html:207:  &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group my-group --group my-other-group
docs/ops.html:267:  &gt; bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group consumergroup1 --topic topic1 --to-latest
docs/ops.html:279:  &gt; bin/kafka-consumer-groups.sh --zookeeper localhost:2181 --list
docs/ops.html:311:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --topics-to-move-json-file topics-to-move.json --broker-list "5,6" --generate
docs/ops.html:337:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file expand-cluster-reassignment.json --execute
docs/ops.html:363:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file expand-cluster-reassignment.json --verify
docs/ops.html:385:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file custom-reassignment.json --execute
docs/ops.html:403:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file custom-reassignment.json --verify
docs/ops.html:425:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file increase-replication-factor.json --execute
docs/ops.html:439:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file increase-replication-factor.json --verify
docs/ops.html:445:  > bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic foo --describe
docs/ops.html:456:  <pre class="brush: bash;">$ bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --execute --reassignment-json-file bigger-cluster.json —throttle 50000000</pre>
docs/ops.html:462:  <pre class="brush: bash;">$ bin/kafka-reassign-partitions.sh --zookeeper localhost:2181  --execute --reassignment-json-file bigger-cluster.json --throttle 700000000
docs/ops.html:473:  > bin/kafka-reassign-partitions.sh --zookeeper localhost:2181  --verify --reassignment-json-file bigger-cluster.json
docs/ops.html:496:  > bin/kafka-configs.sh --describe --zookeeper localhost:2181 --entity-type brokers
docs/ops.html:506:  > bin/kafka-configs.sh --describe --zookeeper localhost:2181 --entity-type topics
docs/ops.html:555:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type users --entity-name user1 --entity-type clients --entity-name clientA
docs/ops.html:561:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type users --entity-name user1
docs/ops.html:567:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type clients --entity-name clientA
docs/ops.html:575:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type users --entity-name user1 --entity-type clients --entity-default
docs/ops.html:581:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type users --entity-default
docs/ops.html:587:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --alter --add-config 'producer_byte_rate=1024,consumer_byte_rate=2048,request_percentage=200' --entity-type clients --entity-default
docs/ops.html:593:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --describe --entity-type users --entity-name user1 --entity-type clients --entity-name clientA
docs/ops.html:598:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --describe --entity-type users --entity-name user1
docs/ops.html:603:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --describe --entity-type clients --entity-name clientA
docs/ops.html:608:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --describe --entity-type users
docs/ops.html:614:  > bin/kafka-configs.sh  --zookeeper localhost:2181 --describe --entity-type users --entity-type clients
docs/configuration.html:47:  &gt; bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --alter --add-config log.cleaner.threads=2
docs/configuration.html:52:  &gt; bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --describe
docs/configuration.html:58:  &gt; bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --alter --delete-config log.cleaner.threads
docs/configuration.html:64:  &gt; bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-default --alter --add-config log.cleaner.threads=2
docs/configuration.html:69:  &gt; bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-default --describe
docs/configuration.html:103:  &gt; bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type brokers --entity-name 0 --alter --add-config
docs/configuration.html:237:  &gt; bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic --partitions 1 \
docs/configuration.html:242:  &gt; bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name my-topic
docs/configuration.html:248:  &gt; bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name my-topic --describe
docs/configuration.html:253:  &gt; bin/kafka-configs.sh --zookeeper localhost:2181  --entity-type topics --entity-name my-topic
docs/streams/developer-guide/dsl-api.html:1697:                                partitions of a Kafka topic you can use, for example, the CLI tool <code class="docutils literal"><span class="pre">bin/kafka-topics</span></code> with the <code class="docutils literal"><span class="pre">--describe</span></code>
docs/streams/developer-guide/dsl-api.html:1701:                                new topic &#8220;repartitioned-topic-for-smaller&#8221;.  Typically, you&#8217;d use the CLI tool <code class="docutils literal"><span class="pre">bin/kafka-topics</span></code> with the
docs/streams/developer-guide/app-reset-tool.html:59:                <li><p class="first">All instances of your application must be stopped. Otherwise, the application may enter an invalid state, crash, or produce incorrect results. You can verify whether the consumer group with ID <code class="docutils literal"><span class="pre">application.id</span></code> is still active by using <code class="docutils literal"><span class="pre">bin/kafka-consumer-groups</span></code>.</p>
docs/streams/developer-guide/app-reset-tool.html:79:            <div class="highlight-bash"><div class="highlight"><pre><span></span>&lt;path-to-kafka&gt;/bin/kafka-streams-application-reset
docs/streams/quickstart.html:116:&gt; bin/kafka-server-start.sh config/server.properties
docs/streams/quickstart.html:142:&gt; bin/kafka-topics.sh --create \
docs/streams/quickstart.html:154:&gt; bin/kafka-topics.sh --create \
docs/streams/quickstart.html:166:&gt; bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe
docs/streams/quickstart.html:179:&gt; bin/kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo
docs/streams/quickstart.html:191:&gt; bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input
docs/streams/quickstart.html:197:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
docs/streams/quickstart.html:215:&gt; bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input
docs/streams/quickstart.html:224:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
docs/streams/quickstart.html:249:&gt; bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input
docs/streams/quickstart.html:257:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
docs/streams/quickstart.html:282:&gt; bin/kafka-console-producer.sh --broker-list localhost:9092 --topic streams-plaintext-input
docs/streams/quickstart.html:292:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
docs/quickstart.html:49:&gt; bin/kafka-server-start.sh config/server.properties
docs/quickstart.html:59:&gt; bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test
docs/quickstart.html:64:&gt; bin/kafka-topics.sh --list --bootstrap-server localhost:9092
docs/quickstart.html:76:&gt; bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
docs/quickstart.html:86:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
docs/quickstart.html:128:&gt; bin/kafka-server-start.sh config/server-1.properties &amp;
docs/quickstart.html:130:&gt; bin/kafka-server-start.sh config/server-2.properties &amp;
docs/quickstart.html:136:&gt; bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 3 --partitions 1 --topic my-replicated-topic
docs/quickstart.html:141:&gt; bin/kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic my-replicated-topic
docs/quickstart.html:156:&gt; bin/kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic test
docs/quickstart.html:165:&gt; bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-replicated-topic
docs/quickstart.html:173:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
docs/quickstart.html:198:&gt; bin/kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic my-replicated-topic
docs/quickstart.html:204:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
docs/quickstart.html:272:&gt; bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning
docs/upgrade.html:70:    <li>The <code>bin/kafka-topics.sh</code> command line tool is now able to connect directly to brokers with <code>--bootstrap-server</code> instead of zookeeper. The old <code>--zookeeper</code>
docs/upgrade.html:592:  <li>It is also possible to enable the 0.11.0 message format on individual topics using the topic admin tool (<code>bin/kafka-topics.sh</code>)
 <li>For secure clusters, the transactional APIs require new ACLs which can be turned on with the <code>bin/kafka-acls.sh</code>.
README.md:81:*Note that if building the jars with a version other than 2.12.x, you need to set the `SCALA_VERSION` variable or change it in `bin/kafka-run-class.sh` to run the quick start.*
core/src/main/scala/kafka/tools/StreamsResetter.java:118:            + "with the bin/kafka-topics.sh command).\n"
> ./bin/kafka-server-start.sh ./config/server.properties &> /tmp/kafka.log &
examples/bin/java-producer-consumer-demo.sh:22:exec $base_dir/bin/kafka-run-class.sh kafka.examples.KafkaConsumerProducerDemo $@
examples/bin/java-simple-consumer-demo.sh:22:exec $base_dir/bin/kafka-run-class.sh kafka.examples.SimpleConsumerDemo $@



-2. 创建Topic

bin/kafka-topics.sh --create --topic test0 --zookeeper 192.168.187.146:2181 --config max.message.bytes=12800000 --config flush.messages=1 --partitions 5 --replication-factor 1

--create： 指定创建topic动作

--topic：指定新建topic的名称

--zookeeper： 指定kafka连接zk的连接url，该值和server.properties文件中的配置项{zookeeper.connect}一样

--config：指定当前topic上有效的参数值，参数列表参考文档为: Topic-level configuration

--partitions：指定当前创建的kafka分区数量，默认为1个

--replication-factor：指定每个分区的复制因子个数，默认1个





-3. 查看当前Kafka集群中Topic的情况

bin/kafka-topics.sh --list --zookeeper 192.168.187.146:2181





-4. 查看对应topic的描述信息

bin/kafka-topics.sh --describe --zookeeper 192.168.187.146:2181  --topic test0

--describe： 指定是展示详细信息命令

--zookeeper： 指定kafka连接zk的连接url，该值和server.properties文件中的配置项{zookeeper.connect}一样

--topic：指定需要展示数据的topic名称





-5. Topic信息修改

bin/kafka-topics.sh --zookeeper 192.168.187.146:2181 --alter --topic test0 --config max.message.bytes=128000
bin/kafka-topics.sh --zookeeper 192.168.187.146:2181 --alter --topic test0 --delete-config max.message.bytes
bin/kafka-topics.sh --zookeeper 192.168.187.146:2181 --alter --topic test0 --partitions 10
bin/kafka-topics.sh --zookeeper 192.168.187.146:2181 --alter --topic test0 --partitions 3 ## Kafka分区数量只允许增加，不允许减少





-6. Topic删除

默认情况下Kafka的Topic是没法直接删除的，需要进行相关参数配置

bin/kafka-topics.sh --delete --topic test0 --zookeeper 192.168.187.146:2181

Note: This will have no impact if delete.topic.enable is not set to true.## 默认情况下，删除是标记删除，没有实际删除这个Topic；如果运行删除Topic，两种方式：
方式一：通过delete命令删除后，手动将本地磁盘以及zk上的相关topic的信息删除即可
方式二：配置server.properties文件，给定参数delete.topic.enable=true，重启kafka服务，此时执行delete命令表示允许进行Topic的删除




作者：半兽人
链接：http://orchome.com/454
来源：OrcHome
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

管理
## 创建主题（4个分区，2个副本）
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 4 --topic test
查询
## 查询集群描述
bin/kafka-topics.sh --describe --zookeeper

## 消费者列表查询
bin/kafka-topics.sh --zookeeper 127.0.0.1:2181 --list

## 新消费者列表查询（支持0.9版本+）
bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server localhost:9092 --list

## 显示某个消费组的消费详情（仅支持offset存储在zookeeper上的）
bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zookeeper localhost:2181 --group test

## 显示某个消费组的消费详情（支持0.9版本+）
bin/kafka-consumer-groups.sh --new-consumer --bootstrap-server localhost:9092 --describe --group test-consumer-group
发送和消费
## 生产者
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

## 消费者
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test

## 新生产者（支持0.9版本+）
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test --producer.config config/producer.properties

## 新消费者（支持0.9版本+）
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --new-consumer --from-beginning --consumer.config config/consumer.properties

## 高级点的用法
bin/kafka-simple-consumer-shell.sh --brist localhost:9092 --topic test --partition 0 --offset 1234  --max-messages 10
平衡leader
bin/kafka-preferred-replica-election.sh --zookeeper zk_host:port/chroot
kafka自带压测命令
bin/kafka-producer-perf-test.sh --topic test --num-records 100 --record-size 1 --throughput 100  --producer-props bootstrap.servers=localhost:9092
增加副本
创建规则json

cat > increase-replication-factor.json <<EOF
{"version":1, "partitions":[
{"topic":"__consumer_offsets","partition":0,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":1,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":2,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":3,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":4,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":5,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":6,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":7,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":8,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":9,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":10,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":11,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":12,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":13,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":14,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":15,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":16,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":17,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":18,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":19,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":20,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":21,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":22,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":23,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":24,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":25,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":26,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":27,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":28,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":29,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":30,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":31,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":32,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":33,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":34,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":35,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":36,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":37,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":38,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":39,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":40,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":41,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":42,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":43,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":44,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":45,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":46,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":47,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":48,"replicas":[0,1]},
{"topic":"__consumer_offsets","partition":49,"replicas":[0,1]}]
}
EOF

bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file increase-replication-factor.json --execute

bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 --reassignment-json-file increase-replication-factor.json --verify



#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

base_dir=$(dirname $0)/../..

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx512M"
fi
exec $base_dir/bin/kafka-run-class.sh kafka.examples.KafkaConsumerProducerDemo $@
#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

base_dir=$(dirname $0)/../..

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx512M"
fi
exec $base_dir/bin/kafka-run-class.sh kafka.examples.SimpleConsumerDemo $@
