
package main.scala

import kafka.api.{OffsetCommitRequest, OffsetFetchRequest, TopicMetadataRequest}
import kafka.common.{OffsetAndMetadata, TopicAndPartition}
import kafka.consumer.SimpleConsumer
import kafka.message.MessageAndMetadata
import kafka.serializer.StringDecoder
import org.apache.spark.SparkConf
import org.apache.spark.streaming.{Duration, StreamingContext}
import org.apache.spark.streaming.dstream.InputDStream
import org.apache.spark.streaming.kafka.{HasOffsetRanges, KafkaUtils}


//需求：消费者自定义控制offset
//在这里offset保存到kafka内部的特殊topic：__consumer_offsets中，使用kafka.consumer.SimpleConsumer类来进行一系列操作
object kafka_offset_learning {
  val groupid="user3"
  def main(args: Array[String]) {
    val sparkConf = new SparkConf().setMaster("local[2]").setAppName("kafka-spark-demo")
    val scc = new StreamingContext(sparkConf, Duration(5000)) //new一个spark-streaming的上下文
    val topics = Set("kafka_test4") //我们需要消费的kafka数据的topic
    val kafkaParam = Map(
      "metadata.broker.list" -> "localhost:9092",// kafka的broker list地址
      "groupid"->groupid
    )
    val topic="kafka_test4"
    //查看当前topic：__consumer_offsets中已存储的最新的offset
    val simpleConsumer = new SimpleConsumer("localhost", 9092, 1000000, 64 * 1024, "test")//new一个consumer并连接上kafka
    val topiclist=Seq("kafka_test4")
    val topicReq = new TopicMetadataRequest(topiclist,0)//定义一个topic请求，为了获取相关topic的信息（不包括offset,有partition）
    val res = simpleConsumer.send(topicReq)//发送请求，得到kafka相应
    val topicMetaOption = res.topicsMetadata.headOption

    //定义一个Topicandpartition的格式，便于后面请求offset
    val topicAndPartition: Seq[TopicAndPartition] = topicMetaOption match {
      case Some(tm) => tm.partitionsMetadata.map(pm => TopicAndPartition("kafka_test4", pm.partitionId))
      case None => Seq[TopicAndPartition]()
    }
    val fetchRequest = OffsetFetchRequest("user3",topicAndPartition)//定义一个请求，传递的参数为groupid,topic,partitionid,这三个也正好能确定对应的offset的位置

    val fetchResponse = simpleConsumer.fetchOffsets(fetchRequest).requestInfo//向kafka发送请求并获取返回的offset信息
//    println(fetchRequest)
//    println(fetchResponse)
    val offsetl=fetchResponse.map{l=>
    val part_name=l._1.partition
    val offset_name=l._2.offset
  (topic,part_name,offset_name)
}
    println(offsetl.toList)
    //使用KafkaUtils.createDirectStream,使得kafka流从指定的offset开始
    val offsetList = offsetl.toList
//    val offsetList = List((topic, 0, 1L),(topic, 1, 1L),(topic, 2, 1L),(topic, 3, 1L))//在此只是用1做实验，没有变成动态的，实际情况应该是这里的offset都是前面查出来已经存储好的offset
    val fromOffsets = setFromOffsets(offsetList)//对List进行处理，变成需要的格式，即Map[TopicAndPartition, Long]
    val messageHandler = (mam: MessageAndMetadata[String, String]) => (mam.topic, mam.message()) //构建MessageAndMetadata，这个所有使用情况都是一样的，就这么写

    //定义流.这种方法是不会在zookeeper的/consumers中创建一个新的groupid实例的
    val stream: InputDStream[(String, String)] = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder, (String, String)](scc, kafkaParam, fromOffsets, messageHandler)

    stream.print()//为了放出时间戳
    //将已更新的offset存入topic：__consumer_offsets中，以便下次使用
    //另外，这里涉及到与外部系统即kafka的连接，所以要使用一下结构
    stream.foreachRDD { rdd =>
      rdd.foreachPartition { partitionOfRecords =>
        //配置说明
        val simpleConsumer2 = new SimpleConsumer("localhost", 9092, 1000000, 64 * 1024, "test-client")
        partitionOfRecords.foreach { record =>
          val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges//这个语句可以返回当前rdd所更新到的offset值（OffsetRange(topic: 'kafka_test4', partition: 0, range: [1 -> 4])）
          for (o <- offsetRanges) {
            //在这里o.untilOffset返回的是offset末态
            //而o.fromOffset返回的是offset初态
            //所以看需求进行存储
            val topicAndPartition = TopicAndPartition(topic, o.partition)//定义一个格式
            val commitRequest = OffsetCommitRequest(groupid, Map(topicAndPartition -> OffsetAndMetadata(o.fromOffset)))//定义一个请求，注意，在这里存储的是fromOffset
            val commitResponse = simpleConsumer2.commitOffsets(commitRequest)//提交请求，完成offset存储即更新
          }
        }

      }
    }
    scc.start() // 真正启动程序
    scc.awaitTermination()
  }
  def setFromOffsets(list: List[(String, Int, Long)]): Map[TopicAndPartition, Long] = {
    var fromOffsets: Map[TopicAndPartition, Long] = Map()
    for (offset <- list) {
      val tp = TopicAndPartition(offset._1, offset._2)//topic和分区数
      fromOffsets += (tp -> offset._3)           // offset位置
    }
    fromOffsets
  }

===========

  def initKafkaParams = {
    Map[String, String](
      "metadata.broker.list" -> Constants.KAFKA_BROKERS,
      "group.id " -> Constants.KAFKA_CONSUMER_GROUP,
      "fetch.message.max.bytes" -> "20971520",
      "auto.offset.reset" -> "smallest"
    )
  }

  // kafka参数
  val kafkaParams = initKafkaParams
  val manager = new KafkaManager(kafkaParams)
  val messageDstream = manager.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, Set(topic))

  // 更新offsets
  manager.updateZKOffsets(rdd)

  import kafka.common.TopicAndPartition
  import kafka.message.MessageAndMetadata
  import kafka.serializer.Decoder
  import org.apache.spark.SparkException
  import org.apache.spark.rdd.RDD
  import org.apache.spark.streaming.StreamingContext
  import org.apache.spark.streaming.dstream.InputDStream
  import org.apache.spark.streaming.kafka.KafkaCluster.LeaderOffset

  import scala.reflect.ClassTag

  /**
    * Created by knowpigxia on 15-8-5.
    */
  class KafkaManager(val kafkaParams: Map[String, String]) extends Serializable {

    private val kc = new KafkaCluster(kafkaParams)

    /**
      * 创建数据流
      * @param ssc
      * @param kafkaParams
      * @param topics
      * @tparam K
      * @tparam V
      * @tparam KD
      * @tparam VD
      * @return
      */
    def createDirectStream[K: ClassTag, V: ClassTag, KD <: Decoder[K]: ClassTag, VD <: Decoder[V]: ClassTag](
                                                                                                              ssc: StreamingContext,
                                                                                                              kafkaParams: Map[String, String],
                                                                                                              topics: Set[String]): InputDStream[(K, V)] =  {
      val groupId = kafkaParams.get("group.id").get
      // 在zookeeper上读取offsets前先根据实际情况更新offsets
      setOrUpdateOffsets(topics, groupId)

      //从zookeeper上读取offset开始消费message
      val messages = {
        val partitionsE = kc.getPartitions(topics)
        if (partitionsE.isLeft)
          throw new SparkException(s"get kafka partition failed: ${partitionsE.left.get}")
        val partitions = partitionsE.right.get
        val consumerOffsetsE = kc.getConsumerOffsets(groupId, partitions)
        if (consumerOffsetsE.isLeft)
          throw new SparkException(s"get kafka consumer offsets failed: ${consumerOffsetsE.left.get}")
        val consumerOffsets = consumerOffsetsE.right.get
        KafkaUtils.createDirectStream[K, V, KD, VD, (K, V)](
          ssc, kafkaParams, consumerOffsets, (mmd: MessageAndMetadata[K, V]) => (mmd.key, mmd.message))
      }
      messages
    }

    /**
      * 创建数据流前，根据实际消费情况更新消费offsets
      * @param topics
      * @param groupId
      */
    private def setOrUpdateOffsets(topics: Set[String], groupId: String): Unit = {
      topics.foreach(topic => {
        var hasConsumed = true
        val partitionsE = kc.getPartitions(Set(topic))
        if (partitionsE.isLeft)
          throw new SparkException(s"get kafka partition failed: ${partitionsE.left.get}")
        val partitions = partitionsE.right.get
        val consumerOffsetsE = kc.getConsumerOffsets(groupId, partitions)
        if (consumerOffsetsE.isLeft) hasConsumed = false
        if (hasConsumed) {// 消费过
          /**
            * 如果streaming程序执行的时候出现kafka.common.OffsetOutOfRangeException，
            * 说明zk上保存的offsets已经过时了，即kafka的定时清理策略已经将包含该offsets的文件删除。
            * 针对这种情况，只要判断一下zk上的consumerOffsets和earliestLeaderOffsets的大小，
            * 如果consumerOffsets比earliestLeaderOffsets还小的话，说明consumerOffsets已过时,
            * 这时把consumerOffsets更新为earliestLeaderOffsets
            */
          val earliestLeaderOffsetsE = kc.getEarliestLeaderOffsets(partitions)
          if (earliestLeaderOffsetsE.isLeft)
            throw new SparkException(s"get earliest leader offsets failed: ${earliestLeaderOffsetsE.left.get}")
          val earliestLeaderOffsets = earliestLeaderOffsetsE.right.get
          val consumerOffsets = consumerOffsetsE.right.get

          // 可能只是存在部分分区consumerOffsets过时，所以只更新过时分区的consumerOffsets为earliestLeaderOffsets
          var offsets: Map[TopicAndPartition, Long] = Map()
          consumerOffsets.foreach({ case(tp, n) =>
            val earliestLeaderOffset = earliestLeaderOffsets(tp).offset
            if (n < earliestLeaderOffset) {
              println("consumer group:" + groupId + ",topic:" + tp.topic + ",partition:" + tp.partition +
                " offsets已经过时，更新为" + earliestLeaderOffset)
              offsets += (tp -> earliestLeaderOffset)
            }
          })
          if (!offsets.isEmpty) {
            kc.setConsumerOffsets(groupId, offsets)
          }
        } else {// 没有消费过
        val reset = kafkaParams.get("auto.offset.reset").map(_.toLowerCase)
          var leaderOffsets: Map[TopicAndPartition, LeaderOffset] = null
          if (reset == Some("smallest")) {
            val leaderOffsetsE = kc.getEarliestLeaderOffsets(partitions)
            if (leaderOffsetsE.isLeft)
              throw new SparkException(s"get earliest leader offsets failed: ${leaderOffsetsE.left.get}")
            leaderOffsets = leaderOffsetsE.right.get
          } else {
            val leaderOffsetsE = kc.getLatestLeaderOffsets(partitions)
            if (leaderOffsetsE.isLeft)
              throw new SparkException(s"get latest leader offsets failed: ${leaderOffsetsE.left.get}")
            leaderOffsets = leaderOffsetsE.right.get
          }
          val offsets = leaderOffsets.map {
            case (tp, offset) => (tp, offset.offset)
          }
          kc.setConsumerOffsets(groupId, offsets)
        }
      })
    }

    /**
      * 更新zookeeper上的消费offsets
      * @param rdd
      */
    def updateZKOffsets(rdd: RDD[(String, String)]) : Unit = {
      val groupId = kafkaParams.get("group.id").get
      val offsetsList = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

      for (offsets <- offsetsList) {
        val topicAndPartition = TopicAndPartition(offsets.topic, offsets.partition)
        val o = kc.setConsumerOffsets(groupId, Map((topicAndPartition, offsets.untilOffset)))
        if (o.isLeft) {
          println(s"Error updating the offset to Kafka cluster: ${o.left.get}")
        }
      }
    }
  }


  为了应对可能出现的引起Streaming程序崩溃的异常情况，我们一般都需要手动管理好Kafka的offset，而不是让它自动提交，即需要将enable.auto.commit设为false。只有管理好offset，才能使整个流式系统最大限度地接近exactly once语义。
  管理offset的流程
  下面这张图能够简要地说明管理offset的大致流程。






  offset管理流程


  在Kafka DirectStream初始化时，取得当前所有partition的存量offset，以让DirectStream能够从正确的位置开始读取数据。
  读取消息数据，处理并存储结果。
  提交offset，并将其持久化在可靠的外部存储中。
  图中的“process and store results”及“commit offsets”两项，都可以施加更强的限制，比如存储结果时保证幂等性，或者提交offset时采用原子操作。
  图中提出了4种offset存储的选项，分别是HBase、Kafka自身、HDFS和ZooKeeper。综合考虑实现的难易度和效率，我们目前采用过的是Kafka自身与ZooKeeper两种方案。

  Kafka自身
  在Kafka 0.10+版本中，offset的默认存储由ZooKeeper移动到了一个自带的topic中，名为__consumer_offsets。Spark Streaming也专门提供了commitAsync() API用于提交offset。使用方法如下。
  stream.foreachRDD { rdd =>
    val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
    // 确保结果都已经正确且幂等地输出了
    stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)
  }

  上面是Spark Streaming官方文档中给出的写法。但在实际上我们总会对DStream进行一些运算，这时我们可以借助DStream的transform()算子。
  var offsetRanges: Array[OffsetRange] = Array.empty[OffsetRange]

  stream.transform(rdd => {
    // 利用transform取得OffsetRanges
    offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
    rdd
  }).mapPartitions(records => {
    var result = new ListBuffer[...]()
    // 处理流程
    result.toList.iterator
  }).foreachRDD(rdd => {
    if (!rdd.isEmpty()) {
      // 数据入库
      session.createDataFrame...
    }
    // 提交offset
    stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)
  })

  特别需要注意，在转换过程中不能破坏RDD分区与Kafka分区之间的映射关系。亦即像map()/mapPartitions()这样的算子是安全的，而会引起shuffle或者repartition的算子，如reduceByKey()/join()/coalesce()等等都是不安全的。
  另外需要注意的是，HasOffsetRanges是KafkaRDD的一个trait，而CanCommitOffsets是DirectKafkaInputDStream的一个trait。从spark-streaming-kafka包的源码中，可以看得一清二楚。
  private[spark] class KafkaRDD[K, V](
                                       sc: SparkContext,
                                       val kafkaParams: ju.Map[String, Object],
                                       val offsetRanges: Array[OffsetRange],
                                       val preferredHosts: ju.Map[TopicPartition, String],
                                       useConsumerCache: Boolean
                                     ) extends RDD[ConsumerRecord[K, V]](sc, Nil) with Logging with HasOffsetRanges

  private[spark] class DirectKafkaInputDStream[K, V](
                                                      _ssc: StreamingContext,
                                                      locationStrategy: LocationStrategy,
                                                      consumerStrategy: ConsumerStrategy[K, V],
                                                      ppc: PerPartitionConfig
                                                    ) extends InputDStream[ConsumerRecord[K, V]](_ssc) with Logging with CanCommitOffsets {

    这就意味着不能对stream对象做transformation操作之后的结果进行强制转换（会直接报ClassCastException），因为RDD与DStream的类型都改变了。只有RDD或DStream的包含类型为ConsumerRecord才行。
    ZooKeeper
    虽然Kafka将offset从ZooKeeper中移走是考虑到可能的性能问题，但ZooKeeper内部是采用树形node结构存储的，这使得它天生适合存储像offset这样细碎的结构化数据。并且我们的分区数不是很多，batch间隔也相对长（20秒），因此并没有什么瓶颈。
    Kafka中还保留了一个已经标记为过时的类ZKGroupTopicDirs，其中预先指定了Kafka相关数据的存储路径，借助它，我们可以方便地用ZooKeeper来管理offset。为了方便调用，将存取offset的逻辑封装成一个类如下。
    class ZkKafkaOffsetManager(zkUrl: String) {
      private val logger = LoggerFactory.getLogger(classOf[ZkKafkaOffsetManager])

      private val zkClientAndConn = ZkUtils.createZkClientAndConnection(zkUrl, 30000, 30000);
      private val zkUtils = new ZkUtils(zkClientAndConn._1, zkClientAndConn._2, false)

      def readOffsets(topics: Seq[String], groupId: String): Map[TopicPartition, Long] = {
        val offsets = mutable.HashMap.empty[TopicPartition, Long]
        val partitionsForTopics = zkUtils.getPartitionsForTopics(topics)

        // /consumers/<groupId>/offsets/<topic>/<partition>
        partitionsForTopics.foreach(partitions => {
          val topic = partitions._1
          val groupTopicDirs = new ZKGroupTopicDirs(groupId, topic)

          partitions._2.foreach(partition => {
            val path = groupTopicDirs.consumerOffsetDir + "/" + partition
            try {
              val data = zkUtils.readData(path)
              if (data != null) {
                offsets.put(new TopicPartition(topic, partition), data._1.toLong)
                logger.info(
                  "Read offset - topic={}, partition={}, offset={}, path={}",
                  Seq[AnyRef](topic, partition.toString, data._1, path)
                )
              }
            } catch {
              case ex: Exception =>
                offsets.put(new TopicPartition(topic, partition), 0L)
                logger.info(
                  "Read offset - not exist: {}, topic={}, partition={}, path={}",
                  Seq[AnyRef](ex.getMessage, topic, partition.toString, path)
                )
            }
          })
        })

        offsets.toMap
      }

      def saveOffsets(offsetRanges: Seq[OffsetRange], groupId: String): Unit = {
        offsetRanges.foreach(range => {
          val groupTopicDirs = new ZKGroupTopicDirs(groupId, range.topic)
          val path = groupTopicDirs.consumerOffsetDir + "/" + range.partition
          zkUtils.updatePersistentPath(path, range.untilOffset.toString)
          logger.info(
            "Save offset - topic={}, partition={}, offset={}, path={}",
            Seq[AnyRef](range.topic, range.partition.toString, range.untilOffset.toString, path)
          )
        })
      }
    }

    这样，offset就会被存储在ZK的/consumers/[groupId]/offsets/[topic]/[partition]路径下。当初始化DirectStream时，调用readOffsets()方法获得offset。当数据处理完成后，调用saveOffsets()方法来更新ZK中的值。
    为什么不用checkpoint
    Spark Streaming的checkpoint机制无疑是用起来最简单的，checkpoint数据存储在HDFS中，如果Streaming应用挂掉，可以快速恢复。
    但是，如果Streaming程序的代码改变了，重新打包执行就会出现反序列化异常的问题。这是因为checkpoint首次持久化时会将整个jar包序列化，以便重启时恢复。重新打包之后，新旧代码逻辑不同，就会报错或者仍然执行旧版代码。
    要解决这个问题，只能将HDFS上的checkpoint文件删掉，但这样也会同时删掉Kafka的offset信息，就毫无意义了。

    ===========

    【翻译】Spark Streaming 管理 Kafka Offsets 的方式探讨
      96  _和_
      0.1 2018.01.19 19:48* 字数 2694 阅读 5207评论 2喜欢 25
    Cloudera Engineering Blog 翻译：Offset Management For Apache Kafka With Apache Spark Streaming

    Spark Streaming 应用从Kafka中获取信息是一种常见的场景。从Kafka中读取持续不断的数据将有很多优势，例如性能好、速度快。然而，用户必须管理Kafka Offsets保证Spark Streaming应用挂掉之后仍然能够正确地读取数据。在这一篇文章，我们将来讨论如何管理offset。

    目录
    Offset管理概述
    将Offsests存储在外部系统
    Spark Streaming checkpoints
    将offsets存储在HBase中
    将offsets存储到 ZooKeeper中
      将offsets存储到Kafka 本身
      其他方式
    总结
    Offset管理概述
    Spark Streaming集成了Kafka允许用户从Kafka中读取一个或者多个topic的数据。一个Kafka topic包含多个存储消息的分区（partition）。每个分区中的消息是顺序存储，并且用offset（可以认为是位置）来标记消息。开发者可以在他的Spark Streaming应用中通过offset来控制数据的读取位置，但是这需要好的offset的管理机制。

    Offsets管理对于保证流式应用在整个生命周期中数据的连贯性是非常有益的。举个例子，如果在应用停止或者报错退出之前没有将offset保存在持久化数据库中，那么offset rangges就会丢失。更进一步说，如果没有保存每个分区已经读取的offset，那么Spark Streaming就没有办法从上次断开（停止或者报错导致）的位置继续读取消息。


    Spark-Streaming-flow-for-offsets.png
    上面的图描述通常的Spark Streaming应用管理offset流程。Offsets可以通过多种方式来管理，但是一般来说遵循下面的步骤:

      在 Direct DStream初始化的时候，需要指定一个包含每个topic的每个分区的offset用于让Direct DStream从指定位置读取数据。
    offsets就是步骤4中所保存的offsets位置
    读取并处理消息
    处理完之后存储结果数据
    用虚线圈存储和提交offset只是简单强调用户可能会执行一系列操作来满足他们更加严格的语义要求。这包括幂等操作和通过原子操作的方式存储offset。
    最后，将offsets保存在外部持久化数据库如 HBase, Kafka, HDFS, and ZooKeeper中
      不同的方案可以根据不同的商业需求进行组合。Spark具有很好的编程范式允许用户很好的控制offsets的保存时机。认真考虑以下的情形：一个Spark Streaming 应用从Kafka中读取数据，处理或者转换数据，然后将数据发送到另一个topic或者其他系统中（例如其他消息系统、Hbase、Solr、DBMS等等）。在这个例子中，我们只考虑消息处理之后发送到其他系统中。

    将Offsests存储在外部系统
    在这一章节中，我们将来探讨一下不同的外部持久化存储选项。

    为了更好地理解这一章节中提到的内容，我们先来做一些铺垫。如果是使用spark-streaming-kafka-0-10，那么我们建议将enable.auto.commit设为false。这个配置只是在这个版本生效，enable.auto.commit如果设为true的话，那么意味着offsets会按照auto.commit.interval.ms中所配置的间隔来周期性自动提交到Kafka中。在Spark Streaming中，将这个选项设置为true的话会使得Spark应用从kafka中读取数据之后就自动提交，而不是数据处理之后提交，这不是我们想要的。所以为了更好地控制offsets的提交，我们建议将enable.auto.commit设为false。

    Spark Streaming checkpoints
    使用Spark Streaming的checkpoint是最简单的存储方式，并且在Spark 框架中很容易实现。Spark Streaming checkpoints就是为保存应用状态而设计的，我们将路径这在HDFS上，所以能够从失败中恢复数据。

    对Kafka Stream 执行checkpoint操作使得offset保存在checkpoint中，如果是应用挂掉的话，那么SparkStreamig应用功能可以从保存的offset中开始读取消息。但是，如果是对Spark Streaming应用进行升级的话，那么很抱歉，不能checkpoint的数据没法使用，所以这种机制并不可靠，特别是在严格的生产环境中，我们不推荐这种方式。

    将offsets存储在HBase中
    HBase可以作为一个可靠的外部数据库来持久化offsets。通过将offsets存储在外部系统中，Spark Streaming应用功能能够重读或者回放任何仍然存储在Kafka中的数据。

    根据HBase的设计模式，允许应用能够以rowkey和column的结构将多个Spark Streaming应用和多个Kafka topic存放在一张表格中。在这个例子中，表格以topic名称、消费者group id和Spark Streaming 的batchTime.milliSeconds作为rowkey以做唯一标识。尽管batchTime.milliSeconds不是必须的，但是它能够更好地展示历史的每批次的offsets。表格将存储30天的累积数据，如果超出30天则会被移除。下面是创建表格的DDL和结构

    DDL
    create 'stream_kafka_offsets', {NAME=>'offsets', TTL=>2592000}

    RowKey Layout:
      row:              <TOPIC_NAME>:<GROUP_ID>:<EPOCH_BATCHTIME_MS>
      column family:    offsets
      qualifier:        <PARTITION_ID>
        value:            <OFFSET_ID>
          对每一个批次的消息，使用saveOffsets()将从指定topic中读取的offsets保存到HBase中

          /*
          Save offsets for each batch into HBase
          */

          def saveOffsets(TOPIC_NAME:String,GROUP_ID:String,offsetRanges:Array[OffsetRange],

          hbaseTableName:String,batchTime: org.apache.spark.streaming.Time) ={

          val hbaseConf = HBaseConfiguration.create()

          hbaseConf.addResource("src/main/resources/hbase-site.xml")

          val conn = ConnectionFactory.createConnection(hbaseConf)

          val table = conn.getTable(TableName.valueOf(hbaseTableName))

          val rowKey = TOPIC_NAME + ":" + GROUP_ID + ":" +String.valueOf(batchTime.milliseconds)

          val put = new Put(rowKey.getBytes)

          for(offset <- offsetRanges){

            put.addColumn(Bytes.toBytes("offsets"),Bytes.toBytes(offset.partition.toString),

              Bytes.toBytes(offset.untilOffset.toString))

          }

          table.put(put)

          conn.close()

          }
          在执行streaming任务之前，首先会使用getLastCommittedOffsets()来从HBase中读取上一次任务结束时所保存的offsets。该方法将采用常用方案来返回kafka topic分区offsets。

          情形1：Streaming任务第一次启动，从zookeeper中获取给定topic的分区数，然后将每个分区的offset都设置为0，并返回。

          情形2：一个运行了很长时间的streaming任务停止并且给定的topic增加了新的分区，处理方式是从zookeeper中获取给定topic的分区数，对于所有老的分区，offset依然使用HBase中所保存，对于新的分区则将offset设置为0。

          情形3：Streaming任务长时间运行后停止并且topic分区没有任何变化，在这个情形下，直接使用HBase中所保存的offset即可。

          在Spark Streaming应用启动之后如果topic增加了新的分区，那么应用只能读取到老的分区中的数据，新的是读取不到的。所以如果想读取新的分区中的数据，那么就得重新启动Spark Streaming应用。

          /*
          Returns last committed offsets for all the partitions of a given topic from HBase in  following  cases.
          */

          def getLastCommittedOffsets(TOPIC_NAME:String,GROUP_ID:String,hbaseTableName:String,

          zkQuorum:String,zkRootDir:String,sessionTimeout:Int,connectionTimeOut:Int):Map[TopicPartition,Long] ={

          val hbaseConf = HBaseConfiguration.create()

          val zkUrl = zkQuorum+"/"+zkRootDir

          val zkClientAndConnection = ZkUtils.createZkClientAndConnection(zkUrl, sessionTimeout,connectionTimeOut)

          val zkUtils = new ZkUtils(zkClientAndConnection._1, zkClientAndConnection._2,false)

          val zKNumberOfPartitionsForTopic = zkUtils.getPartitionsForTopics(Seq(TOPIC_NAME)).get(TOPIC_NAME).toList.head.size

          zkClientAndConnection._1.close()

          zkClientAndConnection._2.close()

          //Connect to HBase to retrieve last committed offsets

          val conn = ConnectionFactory.createConnection(hbaseConf)

          val table = conn.getTable(TableName.valueOf(hbaseTableName))

          val startRow = TOPIC_NAME + ":" + GROUP_ID + ":" +

          String.valueOf(System.currentTimeMillis())

          val stopRow = TOPIC_NAME + ":" + GROUP_ID + ":" + 0

          val scan = new Scan()

          val scanner = table.getScanner(scan.setStartRow(startRow.getBytes).setStopRow(

            stopRow.getBytes).setReversed(true))

          val result = scanner.next()

          var hbaseNumberOfPartitionsForTopic = 0 //Set the number of partitions discovered for a topic in HBase to 0

          if (result != null){

            //If the result from hbase scanner is not null, set number of partitions from hbase

            to the  number of cells

            hbaseNumberOfPartitionsForTopic = result.listCells().size()

          }

          val fromOffsets = collection.mutable.Map[TopicPartition,Long]()

          if(hbaseNumberOfPartitionsForTopic == 0){

            // initialize fromOffsets to beginning

            for (partition <- 0 to zKNumberOfPartitionsForTopic-1){

              fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> 0)

            }

          } else if(zKNumberOfPartitionsForTopic > hbaseNumberOfPartitionsForTopic){

            // handle scenario where new partitions have been added to existing kafka topic

            for (partition <- 0 to hbaseNumberOfPartitionsForTopic-1){

              val fromOffset = Bytes.toString(result.getValue(Bytes.toBytes("offsets"),

                Bytes.toBytes(partition.toString)))

              fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> fromOffset.toLong)

            }

            for (partition <- hbaseNumberOfPartitionsForTopic to zKNumberOfPartitionsForTopic-1){

              fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> 0)

            }

          } else {

            //initialize fromOffsets from last run

            for (partition <- 0 to hbaseNumberOfPartitionsForTopic-1 ){

              val fromOffset = Bytes.toString(result.getValue(Bytes.toBytes("offsets"),

                Bytes.toBytes(partition.toString)))

              fromOffsets += (new TopicPartition(TOPIC_NAME,partition) -> fromOffset.toLong)

            }

          }

          scanner.close()

          conn.close()

          fromOffsets.toMap

          }
          当我们获取到offsets之后我们就可以创建一个Kafka Direct DStream

          val fromOffsets= getLastCommittedOffsets(topic,consumerGroupID,hbaseTableName,zkQuorum,

          zkKafkaRootDir,zkSessionTimeOut,zkConnectionTimeOut)

          val inputDStream = KafkaUtils.createDirectStream[String,String](ssc,PreferConsistent,

          Assign[String, String](fromOffsets.keys,kafkaParams,fromOffsets))
          在完成本批次的数据处理之后调用saveOffsets()保存offsets.

          /*
          For each RDD in a DStream apply a map transformation that processes the message.
          */

          inputDStream.foreachRDD((rdd,batchTime) => {

          val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

          offsetRanges.foreach(offset => println(offset.topic,offset.partition, offset.fromOffset,

            offset.untilOffset))

          val newRDD = rdd.map(message => processMessage(message))

          newRDD.count()

          saveOffsets(topic,consumerGroupID,offsetRanges,hbaseTableName,batchTime)

          })
          你可以到HBase中去查看不同topic和消费者组的offset数据

          hbase(main):001:0> scan 'stream_kafka_offsets', {REVERSED => true}

          ROW                                                COLUMN+CELL

          kafkablog2:groupid-1:1497628830000                column=offsets:0, timestamp=1497628832448, value=285

          kafkablog2:groupid-1:1497628830000                column=offsets:1, timestamp=1497628832448, value=285

          kafkablog2:groupid-1:1497628830000                column=offsets:2, timestamp=1497628832448, value=285

          kafkablog2:groupid-1:1497628770000                column=offsets:0, timestamp=1497628773773, value=225

          kafkablog2:groupid-1:1497628770000                column=offsets:1, timestamp=1497628773773, value=225

          kafkablog2:groupid-1:1497628770000                column=offsets:2, timestamp=1497628773773, value=225

          kafkablog1:groupid-2:1497628650000                column=offsets:0, timestamp=1497628653451, value=165

          kafkablog1:groupid-2:1497628650000                column=offsets:1, timestamp=1497628653451, value=165

          kafkablog1:groupid-2:1497628650000                column=offsets:2, timestamp=1497628653451, value=165

          kafkablog1:groupid-1:1497628530000                column=offsets:0, timestamp=1497628533108, value=120

          kafkablog1:groupid-1:1497628530000                column=offsets:1, timestamp=1497628533108, value=120

          kafkablog1:groupid-1:1497628530000                column=offsets:2, timestamp=1497628533108, value=120

          4 row(s) in 0.5030 seconds

          hbase(main):002:0>
          代码示例用的以下的版本

          GroupID	ArtifactID	Version
          org.apache.spark	spark-streaming_2.11	2.1.0.cloudera1
          org.apache.spark	spark-streaming-kafka-0-10_2.11	2.1.0.cloudera1
          示例代码的github

          将offsets存储到 ZooKeeper中
          在Spark Streaming连接Kafka应用中使用Zookeeper来存储offsets也是一种比较可靠的方式。

          在这个方案中，Spark Streaming任务在启动时会去Zookeeper中读取每个分区的offsets。如果有新的分区出现，那么他的offset将会设置在最开始的位置。在每批数据处理完之后，用户需要可以选择存储已处理数据的一个offset或者最后一个offset。此外，新消费者将使用跟旧的Kafka 消费者API一样的格式将offset保存在ZooKeeper中。因此，任何追踪或监控Zookeeper中Kafka Offset的工具仍然生效的。

          初始化Zookeeper connection来从Zookeeper中获取offsets

          val zkClientAndConnection = ZkUtils.createZkClientAndConnection(zkUrl, sessionTimeout, connectionTimeout)

          val zkUtils = new ZkUtils(zkClientAndConnection._1, zkClientAndConnection._2, false)

          Method for retrieving the last offsets stored in ZooKeeper of the consumer group and topic list.

          def readOffsets(topics: Seq[String], groupId:String):

          Map[TopicPartition, Long] = {

          val topicPartOffsetMap = collection.mutable.HashMap.empty[TopicPartition, Long]

          val partitionMap = zkUtils.getPartitionsForTopics(topics)

          // /consumers/<groupId>/offsets/<topic>/

          partitionMap.foreach(topicPartitions => {

            val zkGroupTopicDirs = new ZKGroupTopicDirs(groupId, topicPartitions._1)

            topicPartitions._2.foreach(partition => {

              val offsetPath = zkGroupTopicDirs.consumerOffsetDir + "/" + partition

              try {

                val offsetStatTuple = zkUtils.readData(offsetPath)

                if (offsetStatTuple != null) {

                  LOGGER.info("retrieving offset details - topic: {}, partition: {}, offset: {}, node path: {}", Seq[AnyRef](topicPartitions._1, partition.toString, offsetStatTuple._1, offsetPath): _*)

                  topicPartOffsetMap.put(new TopicPartition(topicPartitions._1, Integer.valueOf(partition)),

                    offsetStatTuple._1.toLong)

                }

              } catch {

                case e: Exception =>

                  LOGGER.warn("retrieving offset details - no previous node exists:" + " {}, topic: {}, partition: {}, node path: {}", Seq[AnyRef](e.getMessage, topicPartitions._1, partition.toString, offsetPath): _*)

                  topicPartOffsetMap.put(new TopicPartition(topicPartitions._1, Integer.valueOf(partition)), 0L)

              }

            })

          })

          topicPartOffsetMap.toMap

          }
          使用获取到的offsets来初始化Kafka Direct DStream

          val inputDStream = KafkaUtils.createDirectStream(ssc, PreferConsistent, ConsumerStrategies.Subscribe[String,String](topics, kafkaParams, fromOffsets))
          下面是从ZooKeeper获取一组offsets的方法

          注意: Kafka offset在ZooKeeper中的存储路径为/consumers/[groupId]/offsets/topic/[partitionId], 存储的值为offset

          def persistOffsets(offsets: Seq[OffsetRange], groupId: String, storeEndOffset: Boolean): Unit = {

          offsets.foreach(or => {

            val zkGroupTopicDirs = new ZKGroupTopicDirs(groupId, or.topic);

            val acls = new ListBuffer[ACL]()

            val acl = new ACL

            acl.setId(ANYONE_ID_UNSAFE)

            acl.setPerms(PERMISSIONS_ALL)

            acls += acl

            val offsetPath = zkGroupTopicDirs.consumerOffsetDir + "/" + or.partition;

            val offsetVal = if (storeEndOffset) or.untilOffset else or.fromOffset

            zkUtils.updatePersistentPath(zkGroupTopicDirs.consumerOffsetDir + "/"

              + or.partition, offsetVal + "", JavaConversions.bufferAsJavaList(acls))

            LOGGER.debug("persisting offset details - topic: {}, partition: {}, offset: {}, node path: {}", Seq[AnyRef](or.topic, or.partition.toString, offsetVal.toString, offsetPath): _*)

          })

          }
          Kafka 本身
          Apache Spark 2.1.x以及spark-streaming-kafka-0-10使用新的的消费者API即异步提交API。你可以在你确保你处理后的数据已经妥善保存之后使用commitAsync API（异步提交 API）来向Kafka提交offsets。新的消费者API会以消费者组id作为唯一标识来提交offsets

          将offsets提交到Kafka中

          stream.foreachRDD { rdd =>

            val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

            // some time later, after outputs have completed

            stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)

          }
          可以到streaming-kafka-0-10-integration里学习到更多内容

          注意： commitAsync()是Spark Streaming集成kafka-0-10版本中的，在Spark文档提醒到它仍然是个实验性质的API并且存在修改的可能性。

          其他方式
          值得注意的是你也可以将offsets存储到HDFS中。但是将offsets存储到HDFS中并不是一个受欢迎的方式，因为HDFS对已ZooKeeper和Hbase来说它的延迟有点高。此外，将每批次数据的offset存储到HDFS中还会带来小文件的问题

          不管理offsets
          管理offsets对于Spark Streaming应该用来说并不是必须的。举个例子，像应用存活监控它只需要当前的数据，并不需要通过管理offsets来保证数据的不丢失。这种情形下你完全不需要管理offsets，老的kafka消费者可以将auto.offset.reset设为largest或者smallest，而新的消费者则设置为earliest or latest。

          如果你将auto.offset.reset设为smallest (earliest)，那么任务会从最开始的offset读取数据，相当于重播所有数据。这样的设置会使得你的任务重启时将该topic中仍然存在的数据再读取一遍。这将由你的消息保存周期来决定你是否会重复消费。

          相反地，如果你将auto.offset.reset 设置为largest (latest),那么你的应用启动时会从最新的offset开始读取，这将导致你丢失数据。这将依赖于你的应用对数据的严格性和语义需求，这或许是个可行的方案。

          总结
          上面我们所讨论的管理offsets的方式将帮助你在Spark Streaming应用中如何有效地控制offsets。这些方法能够帮助用户在持续不断地计算和存储数据应用中更好地面对应用失效和数据恢复的场景。
          ===============
          提交Offsets
          Spark官方文档中提供了在Spark应用程序中获取Offset和提交Offset的代码，现整合如下：

          val conf = new SparkConf().setAppName("KafkaOffsetDemo").setMaster("local[*]")
          val ssc = new StreamingContext(conf, Seconds(1))

          //设置日志的级别为warn
          ssc.sparkContext.setLogLevel("warn")

          val kafkaParams = Map[String, Object](
          //kafka 集群地址
          "bootstrap.servers" -> "localhost:9092",
          "key.deserializer" -> classOf[StringDeserializer],
          "value.deserializer" -> classOf[StringDeserializer],
          //消费者组名
          "group.id" -> "KafkaOffset",
          //当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，从最新的数据开始消费
          "auto.offset.reset" -> "latest",
          //如果是true，则这个消费者的偏移量会在后台自动提交
          "enable.auto.commit" -> (false: java.lang.Boolean)
          )

          val topics = Array("mytopic")

          val stream = KafkaUtils.createDirectStream[String, String](
          ssc,
          PreferConsistent,
          Subscribe[String, String](topics, kafkaParams)
          )

          stream.foreachRDD(f => {
          // 获取offsetRanges
          val offsetRanges = f.asInstanceOf[HasOffsetRanges].offsetRanges
          //打印offset的信息
          f.foreachPartition(iter => {
            val o: OffsetRange = offsetRanges(TaskContext.get.partitionId)
            println(s"${o.topic} ${o.partition} ${o.fromOffset} ${o.untilOffset}")
          })
          // 等输出(保存)操作完成后提交offset
          stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)

          }
          )

          ssc.start()
          ssc.awaitTermination()
          说明：
          group.id：offset是和group.id以及topic相关联的，如果换了一个group.id，那么消息就会从最新的开始消费；
          auto.offset.reset：可以接收earliest和latest两个参数，latest是从最新的开始消费，earliest是从头开始消费；
          enable.auto.commit：设置为false，这样做是为了后面手动提交offset；
          提交后的offset会在保存在Kafka的 __consumer_offsets 这个topic中。
          自己保存Offset的数据
          这里直接贴出官网示例代码

          // The details depend on your data store, but the general idea looks like this

          // begin from the the offsets committed to the database
          val fromOffsets = selectOffsetsFromYourDatabase.map { resultSet =>
            new TopicPartition(resultSet.string("topic"), resultSet.int("partition")) -> resultSet.long("offset")
          }.toMap

          val stream = KafkaUtils.createDirectStream[String, String](
          streamingContext,
          PreferConsistent,
          Assign[String, String](fromOffsets.keys.toList, kafkaParams, fromOffsets)
          )

          stream.foreachRDD { rdd =>
            val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

            val results = yourCalculation(rdd)

          // begin your transaction

          // update results
          // update offsets where the end of existing offsets matches the beginning of this batch of offsets
          // assert that offsets were updated correctly

          // end your transaction
          }

          ========

          Exactly once的语义

          本篇主要介绍一下Spark Streaming在消费Kafka过程中，当出现程序挂掉重启后，找到上次消费过的最后一次数据，确保kafka数据精确消费一次(exactly-once)的目的。

          1. 背景介绍

          首先先说下kafka三种消息传递保证：

          at most once，消息至多会被发送一次，但如果产生网络延迟等原因消息就会有丢失

          at least once，消息至少会被发送一次，上面既然有消息会丢失，那么给它加一个消息确认机制即可解决，但是消息确认阶段也还会出现同样问题，这样消息就有可能被发送两次。

          exactly once，消息只会被发送一次，这是我们想要的效果

          对于数据的消费者，自然希望最后一种情况。kafka通过offset记录每个topic中的每个partition的消息的位置信息，如果程序挂掉重启的话，程序可以找到上次最后一次消费消息的offset位置，从下一个开始继续消费数据。如果没有保存每个分区已经读取的offset，那么Spark Streaming就没有办法从上次断开（停止或者报错导致）的位置继续读取消息。

          2.常见offset管理方法介绍

          常见的offset管理办法随着kafka的完善不断改进的，offset可以通过多种方式管理，一般的步骤如下：

          DStream初始化的时候，需要指定一个包含每个topic的每个分区的offset用于让DStream从指定位置读取数据

          消费数据

          更新offsets并保存


          2.1 checkpoints

          Spark Streaming的checkpoints是最基本的存储状态信息的方式，一般是保存在HDFS中。但是最大的问题是如果streaming程序升级的话，checkpoints的数据无法使用，所以几乎没人使用。

          2.2 Zookeeper

          Spark Streaming任务在启动时会去Zookeeper中读取每个分区的offsets。如果有新的分区出现，那么他的offset将会设置在最开始的位置。在每批数据处理完之后，用户需要可以选择存储已处理数据的一个offset或者最后一个offset来保存。这种办法需要消费者频繁的去与Zookeeper进行交互，如果期间 Zookeeper 集群发生变化，那 Kafka 集群的吞吐量也跟着受影响。

          2.3 一些外部数据库(HBase,Redis等)

          可以借助一些可靠的外部数据库，比如HBase,Redis保存offset信息，Spark Streaming可以通过读取这些外部数据库，获取最新的消费信息。

          2.4 kafka

          Apache Spark 2.1.x以及spark-streaming-kafka-0-10使用新的的消费者API即异步提交API。你可以在你确保你处理后的数据已经妥善保存之后使用commitAsync API（异步提交API来向Kafka提交offsets。新的消费者API会以消费者组id作为唯一标识来提交offsets。

          3. 实例demo

          本文通过两个例子，展示Streaming管理offset的方法。

          3.1 使用kafka自身保存offset

          Kafka版本0.10.1.1，已默认将消费的offset迁入到了Kafka一个名为__consumer_offsets的Topic中。所以我们读写offset的对象正是这个topic，实际上，一切都已经封装好了，直接调用相关API即可。


          3.2 使用redis保存offset

          根据官网推荐的使用步骤，其实也就两部分，一是从外部数据库中读取offset，第二是完成一个批次的操作后，更新库里的offset值。本demo以保存在redis为例，简要列出相关代码。

          3.2.1 RedisUtils

          基本的redis工具类


          3.2.2  StreamingTest

          前面的配置spark,kafka与之前一样，之后首先配置redis信息，并从redis读取topic各分区对应的lastoffset


          再创建stream流，每个partition处理完成后，需要更新这个partition的offset值。


          4. 测试

          两个都已经亲测可以正常使用，这里就简单拿offset保存在kafka这个例子做个测试。我的测试版本是spark 2.1.2 + kafka 0.10.0.1。

          首先启动streaming程序，在kafka producer终端打进几个测试数据

          可以看到确实消费了三条数据，把程序终止。

          再向这个topic打进三条数据，打完后重启streaming程序。

          我们可以看到，确实是从最新的三条数据开始消费的，之前的数据没有被消费。做到了exactly onece

          5. 总结

          相对于离线批处理，流处理需要考虑的地方更多一些，对程序的鲁棒性要求也更高。对offset的管理