import java.util.{Arrays, Properties}

import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}

/**
  * Partitions can be added to a Kafka topic dynamically. This example shows that an existing stream
  * will not see the data published to the new partitions, and only when the existing streaming context is terminated
  * and a new stream is started from a new context will that data be delivered.
  *
  * The topic is created with three partitions, and so each RDD the stream produces has three partitions as well,
  * even after two more partitions are added to the topic. When a new stream is subsequently created, the RDDs produced
  * have five partitions, but only two of them contain data, as all the data has been drained from the initial three
  * partitions of the topic, by the first stream.
  */
object AddPartitionsWhileStreaming {

  /**
    * Publish some data to a topic. Encapsulated here to ensure serializability.
    * @param max
    * @param sc
    * @param topic
    * @param config
    */
  def send(max: Int, sc: SparkContext, topic: String, config: Properties): Unit = {

    // put some data in an RDD and publish to Kafka
    val numbers = 1 to max
    val numbersRDD = sc.parallelize(numbers, 5)

    val kafkaSink = sc.broadcast(SparkKafkaSink(config))

    println("*** producing data")

    numbersRDD.foreach { n =>
      // NOTE:
      //     1) the keys and values are strings, which is important when receiving them
      //     2) We don't specify which Kafka partition to send to, so a hash of the key
      //        is used to determine this
      kafkaSink.value.send(topic, "key_" + n, "string_" + n)
    }
  }

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 3)



    val conf = new SparkConf().setAppName("AddPartitionsWhileStreaming").setMaster("local[7]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    val max = 500

    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("[1] *** got an RDD, size = " + r.count())
      r.foreach(s => println(s))
      if (r.count() > 0) {
        // let's see how many partitions the resulting RDD has -- notice that it has nothing
        // to do with the number of partitions in the RDD used to publish the data (4), nor
        // the number of partitions of the topic (which also happens to be four.)
        println("[1] *** " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("[1] *** partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started streaming context")

    // streams seem to need some time to get going
    Thread.sleep(5000)


    val client = new SimpleKafkaClient(kafkaServer)

    send(max, sc, topic, client.basicStringStringProducer)
    Thread.sleep(5000)

    println("*** adding partitions to topic")

    kafkaServer.addPartitions(topic, 5)

    Thread.sleep(5000)

    send(max, sc, topic, client.basicStringStringProducer)

    Thread.sleep(5000)

    println("*** stop first streaming context")
    ssc.stop(stopSparkContext = false)
    try {
      ssc.awaitTermination()
      println("*** streaming terminated for the first time")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread (first context)")
      }
    }

    println("*** create second streaming context")
    val ssc2 = new StreamingContext(sc, Seconds(1))

    println("*** create a second stream from the second streaming context")
    val kafkaStream2 =
      KafkaUtils.createDirectStream(
        ssc2,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    kafkaStream2.foreachRDD(r => {
      println("[2] *** got an RDD, size = " + r.count())
      r.foreach(s => println(s))
      if (r.count() > 0) {
        // let's see how many partitions the resulting RDD has -- notice that it has nothing
        // to do with the number of partitions in the RDD used to publish the data (4), nor
        // the number of partitions of the topic (which also happens to be four.)
        println("[2] *** " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("[2] *** partition size = " + a.size))
      }
    })

    println("*** start second streaming context")
    ssc2.start()

    Thread.sleep(5000)

    println("*** requesting streaming termination")
    ssc2.stop(stopSparkContext = false, stopGracefully = true)


    try {
      ssc2.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.test

import java.io.IOException
import java.sql.Timestamp
import java.util.Properties

import com.test.beans.RecordBean
import com.test.config.ConfigurationFactory
import com.test.utils.JsonUtils
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.log4j.Logger
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.types._
import org.apache.spark.sql.{Row, SQLContext, SaveMode, SparkSession}
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
import org.apache.spark.streaming.kafka010.KafkaUtils
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferBrokers
import org.apache.spark.streaming.{Seconds, StreamingContext}

object App {
  private[this] lazy val logger = Logger.getLogger(getClass)

  private[this] val config = ConfigurationFactory.load()

  /**
    * Json decode UDF function
    *
    * @param text the encoded JSON string
    * @return Returns record bean
    */
  def jsonDecode(text: String): RecordBean = {
    try {
      JsonUtils.deserialize(text, classOf[RecordBean])
    } catch {
      case e: IOException =>
        logger.error(e.getMessage, e)
        null
    }
  }

  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder
      .appName("spark-kafka-streaming-example")
      .master("local[*]")
      .getOrCreate

    val streaming = new StreamingContext(spark.sparkContext, Seconds(config.getStreaming.getWindow))

    val servers = config.getProducer.getHosts.toArray.mkString(",")

    val params = Map[String, Object](
      "bootstrap.servers" -> servers,
      "key.deserializer" -> classOf[StringDeserializer],
      "value.deserializer" -> classOf[StringDeserializer],
      "auto.offset.reset" -> "latest",
      "group.id" -> "dashboard",
      "enable.auto.commit" -> (false: java.lang.Boolean)
    )

    // topic names which will be read
    val topics = Array(config.getProducer.getTopic)

    // create kafka direct stream object
    val stream = KafkaUtils.createDirectStream[String, String](
      streaming, PreferBrokers, Subscribe[String, String](topics, params))

    // our table has 3 fields called market (varchar), rate (float) and dt (datetime etc.)
    val schema = StructType(
      StructField("market", StringType) ::
        StructField("rate", FloatType) ::
        StructField("dt", TimestampType) :: Nil
    )

    val host = config.getStreaming.getDb.getHost
    val db = config.getStreaming.getDb.getDb
    val url = s"jdbc:mysql://$host/$db"
    val table = config.getStreaming.getDb.getTable

    val props = new Properties
    props.setProperty("driver", "com.mysql.jdbc.Driver")
    props.setProperty("user", config.getStreaming.getDb.getUser)
    props.setProperty("password", config.getStreaming.getDb.getPass)

    // just alias for simplicity
    type Record = ConsumerRecord[String, String]

    stream.foreachRDD((rdd: RDD[Record]) => {
      // convert string to PoJo and generate rows as tuple group
      val pairs = rdd
        .map(row => (row.timestamp(), jsonDecode(row.value())))
        .map(row => (row._2.getType.name(), (1, row._2.getValue, row._1)))

      /**
        * aggregate data by market type
        *
        * tuple has 3 items,
        * the first one is counter value and this value is 1,
        * second one is the rate and received from Kafka,
        * third one is event time. for instance `2017-05-12 16:00:00`
        *
        * in the map,
        * method <code>f._1</code> is market name,
        * we divide total rate to total item count <code>f._2._2 / f._2._1</code>
        * as you can see <code>f._2._3</code> is average event time
        **/
      val flatten = pairs
        .reduceByKey((x, y) => (x._1 + y._1, x._2 + y._2, (y._3 + x._3) / 2))
        .map(f => Row.fromSeq(Seq(f._1, f._2._2 / f._2._1, new Timestamp(f._2._3))))

      // create sql context from active spark context
      val sql = new SQLContext(flatten.sparkContext)

      // write aggregated results to database
      // only one partition required for better visualisation,
      // better to look at https://goo.gl/iBdNDl
      sql.createDataFrame(flatten, schema)
        .repartition(1)
        .write
        .mode(SaveMode.Append)
        .jdbc(url, table, props)
    })

    // create streaming context and submit streaming jobs
    streaming.start()

    // wait to killing signals etc.
    streaming.awaitTermination()
  }
}

package com.github.polomarcus.conf

object ConfService {
  val BOOTSTRAP_SERVERS_CONFIG = "localhost:9092"
  val APPLICATION_ID = "localhost:9092"
  val GROUP_ID = "my-app"
  val TOPIC_IN = "lyrics"
  val TOPIC_OUT = "wordcount-out"


}
import java.util.{Arrays, Properties}

import kafka.serializer.StringDecoder
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}

/**
  * Here the topic has six partitions but instead of writing to it using the configured
  * partitioner, we assign all records to the same partition explicitly. Although the
  * generated RDDs still have the same number of partitions as the topic, only one
  * partition has all the data in it. THis is a rather extreme way to use topic partitions,
  * but it opens up the whole range of algorithms for selecting the partition when sending.
  */
object ControlledPartitioning {

  /**
    * Publish some data to a topic. Encapsulated here to ensure serializability.
    * @param max
    * @param sc
    * @param topic
    * @param config
    */
  def send(max: Int, sc: SparkContext, topic: String, config: Properties): Unit = {

    // put some data in an RDD and publish to Kafka
    val numbers = 1 to max
    val numbersRDD = sc.parallelize(numbers, 5)

    val kafkaSink = sc.broadcast(SparkKafkaSink(config))

    println("*** producing data")

    // use the overload that explicitly assigns a partition (0)
    numbersRDD.foreach { n =>
      kafkaSink.value.send(topic, 0, "key_" + n, "string_" + n)
    }
  }

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 6)



    val conf = new SparkConf().setAppName("ControlledPartitioning").setMaster("local[7]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    val max = 1000

    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())
      r.foreach(s => println(s))
      if (r.count() > 0) {
        // let's see how many partitions the resulting RDD has -- notice that it has nothing
        // to do with the number of partitions in the RDD used to publish the data (4), nor
        // the number of partitions of the topic (which also happens to be four.)
        println("*** " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        send(max, sc, topic, client.basicStringStringProducer)
        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}package util

/**
  * Run this first to verify that the embedded Kafka setup is working for you.
  * It starts an embedded Kafka server, creates a topic, publishes some messages,
  * reads them back and shuts down the embedded server.
  */

object DirectServerDemo {
  def main (args: Array[String]) {

    val topic = "foo"

    println("*** about to start embedded Kafka server")

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()

    println("*** server started")

    kafkaServer.createTopic(topic, 4)

    println("*** topic [" + topic + "] created")

    Thread.sleep(5000)

    val kafkaClient = new SimpleKafkaClient(kafkaServer)

    println("*** about to produce messages")

    kafkaClient.send(topic, Seq(
      ("Key_1", "Value_1"),
      ("Key_2", "Value_2"),
      ("Key_3", "Value_3"),
      ("Key_4", "Value_4"),
      ("Key_5", "Value_5")
    ))

    println("*** produced messages")

    Thread.sleep(5000)

    println("*** about to consume messages")

    kafkaClient.consumeAndPrint(
      topic,
      5)

    println("*** stopping embedded Kafka server")

    kafkaServer.stop()

    println("*** done")
  }
}
package util

import java.io.IOException
import scala.collection.JavaConversions._

import com.typesafe.scalalogging.Logger

import kafka.admin.TopicCommand
import kafka.server.{KafkaServerStartable, KafkaConfig}
import kafka.utils.ZkUtils

import org.apache.kafka.common.security.JaasUtils

/**
 * A single embedded Kafka server and its associated Zookeeper
 */
@throws[IOException]
class EmbeddedKafkaServer() {
  private val LOGGER = Logger[EmbeddedKafkaServer]
  val tempDirs = new TemporaryDirectories
  val zkPort = 39001
  val kbPort = 39002
  val zkSessionTimeout = 20000
  val zkConnectionTimeout = 20000

  private var zookeeperHandle: Option[EmbeddedZookeeper] = None
  private var kafkaBrokerHandle: Option[KafkaServerStartable] = None

  /**
   * Start first the Zookeeper and then the Kafka broker.
   */
  def start() {
    LOGGER.info(s"starting on [$zkPort $kbPort]")
    zookeeperHandle = Some(new EmbeddedZookeeper(zkPort, tempDirs))
    zookeeperHandle.get.start

    val kafkaProps = Map(
      "port" -> Integer.toString(kbPort),
      "broker.id" -> "1",
      "host.name" -> "localhost",
      "log.dir" -> tempDirs.kafkaLogDirPath,
      "zookeeper.connect" -> ("localhost:" + zkPort))

    kafkaBrokerHandle = Some(new KafkaServerStartable(new KafkaConfig(kafkaProps)))
    kafkaBrokerHandle.get.startup()
  }

  /**
   * If running, shut down first the Kafka broker and then the Zookeeper
   */
  def stop() {
    LOGGER.info(s"shutting down broker on $kbPort")
    kafkaBrokerHandle match {
      case Some(b) => {
        b.shutdown()
        b.awaitShutdown()
        kafkaBrokerHandle = None
      }
      case None =>
    }
    Thread.sleep(5000)
    LOGGER.info(s"shutting down zookeeper on $zkPort")
    zookeeperHandle match {
      case Some(zk) => {
        zk.stop()
        zookeeperHandle = None
      }
      case None =>
    }
  }

  /**
   * Create a topic, optionally setting the number of partitions to a non default value and configuring timestamps.
   * @param topic
   * @param partitions
   * @param logAppendTime
   */
  def createTopic(topic: String, partitions: Int = 1, logAppendTime: Boolean = false) : Unit = {
    LOGGER.debug(s"Creating [$topic]")

    val arguments = Array[String](
      "--create",
      "--topic",
      topic
    ) ++ (
    if (logAppendTime) {
      Array[String]("--config", "message.timestamp.type=LogAppendTime")
    } else {
      Array[String]()
    }) ++ Array[String](
      "--partitions",
      "" + partitions,
      "--replication-factor",
      "1"
    )

    val opts = new TopicCommand.TopicCommandOptions(arguments)

    val zkUtils = ZkUtils.apply(getZkConnect,
      zkSessionTimeout, zkConnectionTimeout,
      JaasUtils.isZkSecurityEnabled)

    TopicCommand.createTopic(zkUtils, opts)

    LOGGER.debug(s"Finished creating topic [$topic]")
  }

  def addPartitions(topic: String, partitions: Int) : Unit = {
    LOGGER.debug(s"Adding [$partitions] partitions to [$topic]")

    val arguments = Array[String](
      "--alter",
      "--topic",
      topic,
      "--partitions",
      "" + partitions
    )

   val opts = new TopicCommand.TopicCommandOptions(arguments)

    val zkUtils = ZkUtils.apply(getZkConnect,
      zkSessionTimeout, zkConnectionTimeout,
      JaasUtils.isZkSecurityEnabled)

    TopicCommand.alterTopic(zkUtils, opts)

    LOGGER.debug(s"Finished adding [$partitions] partitions to [$topic]")
  }

  def getKafkaConnect: String = "localhost:" + kbPort

  def getZkConnect: String = "localhost:" + zkPort


}
package util

import java.io.{IOException, File}
import java.net.InetSocketAddress

import com.typesafe.scalalogging.Logger
import org.apache.zookeeper.server.{NIOServerCnxnFactory, ZooKeeperServer, ServerCnxnFactory}

/**
 * Start/stop a single Zookeeper instance for use by EmbeddedKafkaServer. Do not create one of these directly.
 * @param port
 */
private[util] class EmbeddedZookeeper(port: Int, tempDirs: TemporaryDirectories) {
  private val LOGGER = Logger[EmbeddedZookeeper]
  private var serverConnectionFactory: Option[ServerCnxnFactory] = None

  /**
   * Start a single instance.
   */
  def start() {
    LOGGER.info(s"starting Zookeeper on $port")

    try {
      val zkMaxConnections = 32
      val zkTickTime = 2000
      val zkServer = new ZooKeeperServer(tempDirs.zkSnapshotDir, tempDirs.zkLogDir, zkTickTime)
      serverConnectionFactory = Some(new NIOServerCnxnFactory())
      serverConnectionFactory.get.configure(new InetSocketAddress("localhost", port), zkMaxConnections)
      serverConnectionFactory.get.startup(zkServer)
    }
    catch {
      case e: InterruptedException => {
        Thread.currentThread.interrupt()
      }
      case e: IOException => {
        throw new RuntimeException("Unable to start ZooKeeper", e)
      }
    }
  }

  /**
   * Stop the instance if running.
   */
  def stop() {
    LOGGER.info(s"shutting down Zookeeper on $port")
    serverConnectionFactory match {
      case Some(f) => {
        f.shutdown
        serverConnectionFactory = None
      }
      case None =>
    }
  }
}
import java.util.{Arrays, Properties}

import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient}

/**
  * This example demonstrates that exceptions encountered in stream processing are
  * rethrown from the call to awaitTermination().
  * See https://issues.apache.org/jira/browse/SPARK-17397 .
  * Notice this example doesn't even publish any data: the exception is thrown when an empty RDD is received.
  */
object ExceptionPropagation {

  case class SomeException(s: String)  extends Exception(s)

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)

    val client = new SimpleKafkaClient(kafkaServer)


    val conf = new SparkConf().setAppName("ExceptionPropagation").setMaster("local[4]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())
      // throw the custom exception here and see it get caught in the code below
      throw SomeException("error while processing RDD");
    })

    ssc.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
        ssc.stop() // stop it now since we're not blocked
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}package structured

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.sql.{ForeachWriter, Row, SparkSession}
import util.{EmbeddedKafkaServer, SimpleKafkaClient}

/**
  * The 'foreach' operation allows arbitrary computations on the output data in way that is both
  * partition-aware (computed on the executors and aware of which partition is being processed) and batch-aware
  * (via a separate invocation for each partition/batch combination.)
  *
  * It is always used by passing the operation an object that implements the 'ForeachWriter' interface. In this
  * example, the object doesn't do any "useful" work: instead it is set up to illustrate its slightly arcane state
  * management by printing its arguments and state in each of the three overridden methods.
  *
  * Each instance of ForeachWriter is used for processing a sequence of partition/batch combinations, but at any point
  * in time is is setup (via a single open() call) to process one partition/batch combination. Then it gets multiple
  * process() calls, providing the the actual data for that partition and batch, and then a single close() call to
  * signal that the partition/batch combination has been completely processed.
  */
object Foreach {

  def main (args: Array[String]) {

    val topic = "foo"

    println("*** starting Kafka server")
    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)

    Thread.sleep(5000)

    // publish some messages
    println("*** Publishing messages")
    val messageCount = 16
    val client = new SimpleKafkaClient(kafkaServer)
    val numbers = 1 to messageCount
    val producer = new KafkaProducer[String, String](client.basicStringStringProducer)
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic, "[1]key_" + n, "[1]string_" + n))
    }
    Thread.sleep(5000)

    println("*** Starting to stream")

    val spark = SparkSession
      .builder
      .appName("Structured_Foreach")
      .config("spark.master", "local[4]")
      .getOrCreate()

    val ds1 = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", kafkaServer.getKafkaConnect)
      .option("subscribe", topic)
      .option("startingOffsets", "earliest") // equivalent of auto.offset.reset which is not allowed here
      .load()

    val counts = ds1.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")

    // process the stream using a custom ForeachWriter that simply prints the data and the state of the ForeachWriter
    // in order to illustrate how it works
    val query = counts.writeStream
      .foreach(new ForeachWriter[Row] {

        // Notice the initialization here is very simple, as it gets called on the driver, but never called
        // again on the executor. Any initialization that needs to be called repeatedly on the executor
        // needs to go in the open() method.

        // By using an Option, initializing with None and replacing with None in the close() method, we verify that
        // process() is only ever called between a matched pair of open() and close() calls.
        var myPartition: Option[Long] = None
        var myVersion: Option[Long] = None

        /**
          * Apart from printing the partition and version, we only accept batches from even numbered partitions.
          */
        override def open(partitionId: Long, version: Long): Boolean = {
          myPartition = Some(partitionId)
          myVersion = Some(version)
          println(s"*** ForEachWriter: open partition=[$partitionId] version=[$version]")
          val processThisOne = partitionId % 2 == 0
          // We only accept this partition/batch combination if we return true -- in this case we'll only do so for
          // even numbered partitions. This decision could have been based on the version ID as well.
          processThisOne
        }

        /**
          * Since we've saved the partition and batch IDs, we can see which combination each record comes from.
          * Notice we only get records from even numbered partitions, since we rejected the odd numbered
          * ones in the open() method by returning false.
          */
        override def process(record: Row) : Unit = {
          println(s"*** ForEachWriter: process partition=[$myPartition] version=[$myVersion] record=$record")
        }

        /**
          * Again we've saved the partition and batch IDs, so we can see which combination is being closed.
          * We'll leave error handling for a more advanced example.
          */
        override def close(errorOrNull: Throwable): Unit = {
          println(s"*** ForEachWriter: close partition=[$myPartition] version=[$myVersion]")
          myPartition = None
          myVersion = None
        }
    }).start()

    println("*** done setting up streaming")

    Thread.sleep(5000)

    println("*** publishing more messages")
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic, "[2]key_" + n, "[2]string_" + n))
    }

    Thread.sleep(5000)

    println("*** Stopping stream")
    query.stop()

    query.awaitTermination()
    spark.stop()
    println("*** Streaming terminated")

    // stop Kafka
    println("*** Stopping Kafka")
    kafkaServer.stop()

    println("*** done")
  }
}import java.util.{Arrays, Properties}

import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}

/**
  * This example creates two streams based on two different consumer groups, so both streams
  * get a copy of the same data. It's simply a matter of specifying the two names of the
  * two different consumer groups in the two calls to createStream() -- no special
  * configuration is needed.
  */

object MultipleConsumerGroups {

  /**
    * Publish some data to a topic. Encapsulated here to ensure serializability.
    * @param max
    * @param sc
    * @param topic
    * @param config
    */
  def send(max: Int, sc: SparkContext, topic: String, config: Properties): Unit = {

    // put some data in an RDD and publish to Kafka
    val numbers = 1 to max
    val numbersRDD = sc.parallelize(numbers, 4)

    val kafkaSink = sc.broadcast(SparkKafkaSink(config))

    println("*** producing data")

    numbersRDD.foreach { n =>
      kafkaSink.value.send(topic, "key_" + n, "string_" + n)
    }
  }

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)

    val conf = new SparkConf().setAppName("MultipleConsumerGroups").setMaster("local[4]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    val max = 1000


    //
    // the first stream subscribes to consumer group Group1
    //

    val props1: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer, "Group1")

    val kafkaStream1 =
    KafkaUtils.createDirectStream(
      ssc,
      LocationStrategies.PreferConsistent,
      ConsumerStrategies.Subscribe[String, String](
        Arrays.asList(topic),
        props1.asInstanceOf[java.util.Map[String, Object]]
      )

    )

    kafkaStream1.foreachRDD(r => {
      println("*** [stream 1] got an RDD, size = " + r.count())
      r.foreach(s => println("*** [stream 1] " + s))
      if (r.count() > 0) {
        println("*** [stream 1] " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** [stream 1] partition size = " + a.size))
      }
    })

    //
    // a second stream, subscribing to the second consumer group (Group2), will
    // see all of the same data
    //

    val props2: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer, "Group2")

    val kafkaStream2 =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props2.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    kafkaStream2.foreachRDD(r => {
      println("*** [stream 2] got an RDD, size = " + r.count())
      r.foreach(s => println("*** [stream 2] " + s))
      if (r.count() > 0) {
        println("*** [stream 2] " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** [stream 2] partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        send(max, sc, topic, client.basicStringStringProducer)
        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}import java.util.{Arrays, Properties}

import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}

/**
  * This example creates two streams based on a single consumer group, so they divide up the data.
  * There's an interesting partitioning interaction here as the streams each get data from two fo the four
  * topic partitions, and each produce RDDs with two partitions each.
  */

object MultipleStreams {

  /**
    * Publish some data to a topic. Encapsulated here to ensure serializability.
    * @param max
    * @param sc
    * @param topic
    * @param config
    */
  def send(max: Int, sc: SparkContext, topic: String, config: Properties): Unit = {

    // put some data in an RDD and publish to Kafka
    val numbers = 1 to max
    val numbersRDD = sc.parallelize(numbers, 4)

    val kafkaSink = sc.broadcast(SparkKafkaSink(config))

    println("*** producing data")

    numbersRDD.foreach { n =>
      kafkaSink.value.send(topic, "key_" + n, "string_" + n)
    }
  }

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)

    val conf = new SparkConf().setAppName("MultipleStreams").setMaster("local[4]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    val max = 1000


    //
    // the first stream subscribes to the default consumer group in our SParkKafkaClient class
    //

    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream1 =
    KafkaUtils.createDirectStream(
      ssc,
      LocationStrategies.PreferConsistent,
      ConsumerStrategies.Subscribe[String, String](
        Arrays.asList(topic),
        props.asInstanceOf[java.util.Map[String, Object]]
      )

    )

    kafkaStream1.foreachRDD(r => {
      println("*** [stream 1] got an RDD, size = " + r.count())
      r.foreach(s => println("*** [stream 1] " + s))
      if (r.count() > 0) {
        println("*** [stream 1] " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** [stream 1] partition size = " + a.size))
      }
    })

    //
    // a second stream, uses the same props and hence the same consumer group
    //

    val kafkaStream2 =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    kafkaStream2.foreachRDD(r => {
      println("*** [stream 2] got an RDD, size = " + r.count())
      r.foreach(s => println("*** [stream 2] " + s))
      if (r.count() > 0) {
        println("*** [stream 2] " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** [stream 2] partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        send(max, sc, topic, client.basicStringStringProducer)
        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}import java.util.{Arrays, Properties}

import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, PartitionMapAnalyzer, SimpleKafkaClient}

/**
  * A single stream subscribing to the two topics receives data from both of them.
  * The partitioning behavior here is quite interesting, as the topics have three and six partitions respectively,
  * each RDD has nine partitions, and each RDD partition receives data from exactly one partition of one topic.
  *
  * Partitioning is analyzed using the PartitionMapAnalyzer.
  */
object MultipleTopics {

  def main (args: Array[String]) {

    val topic1 = "foo"
    val topic2 = "bar"

    // topics are partitioned differently
    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic1, 3)
    kafkaServer.createTopic(topic2, 6)

    val conf = new SparkConf().setAppName("MultipleTopics").setMaster("local[10]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    // this many messages
    val max = 100

    // Create the stream.
    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic1, topic2),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())

      PartitionMapAnalyzer.analyze(r)

    })

    ssc.start()

    println("*** started streaming context")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThreadTopic1 = new Thread("Producer thread 1") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        val numbers = 1 to max

        val producer = new KafkaProducer[String, String](client.basicStringStringProducer)

        numbers.foreach { n =>
          // NOTE:
          //     1) the keys and values are strings, which is important when receiving them
          //     2) We don't specify which Kafka partition to send to, so a hash of the key
          //        is used to determine this
          producer.send(new ProducerRecord(topic1, "key_1_" + n, "string_1_" + n))
        }

      }
    }

    val producerThreadTopic2 = new Thread("Producer thread 2; controlling termination") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        val numbers = 1 to max

        val producer = new KafkaProducer[String, String](client.basicStringStringProducer)

        numbers.foreach { n =>
          // NOTE:
          //     1) the keys and values are strings, which is important when receiving them
          //     2) We don't specify which Kafka partition to send to, so a hash of the key
          //        is used to determine this
          producer.send(new ProducerRecord(topic2, "key_2_" + n, "string_2_" + n))
        }
        Thread.sleep(10000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }

    producerThreadTopic1.start()
    producerThreadTopic2.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}package com.github.polomarcus

import java.util.Properties
import java.util.concurrent.TimeUnit

import com.github.polomarcus.conf.ConfService
import com.typesafe.scalalogging.Logger
import org.apache.kafka.streams.scala.ImplicitConversions._
import org.apache.kafka.streams.scala._
import org.apache.kafka.streams.scala.kstream._
import org.apache.kafka.streams.{KafkaStreams, StreamsConfig}

/**
  * From https://kafka.apache.org/20/documentation/streams/developer-guide/dsl-api.html#scala-dsl
  */
object WordCountApplication extends App {
  val logger = Logger(WordCountApplication.getClass)

  import Serdes._

  val props: Properties = {
    val p = new Properties()
    p.put(StreamsConfig.APPLICATION_ID_CONFIG, "wordcount-application")
    p.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, ConfService.BOOTSTRAP_SERVERS_CONFIG)
    p
  }

  val builder: StreamsBuilder = new StreamsBuilder
  val textLines: KStream[String, String] = builder.stream[String, String](ConfService.TOPIC_IN)
  val wordCounts: KTable[String, Long] = textLines
    .flatMapValues(textLine => textLine.toLowerCase.split("\\W+"))
    .groupBy((_, word) => word)
    .count()

  wordCounts.toStream.to(ConfService.TOPIC_OUT)

  val streams: KafkaStreams = new KafkaStreams(builder.build(), props)

  logger.info("Stream started")
  streams.start()

  sys.ShutdownHookThread {
    logger.info("Stream closed")
    streams.close(10, TimeUnit.SECONDS)
  }
}package util

import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.spark.rdd.RDD

//
// This is a general tool for analyzing an RDD of ConsumerRecord, such as is normally produced by a Kafka stream.
// The goal is to see how subscribed Kafka topics and their Kafka partitions map to partitions in the RDD that is
// emitted by the Spark stream. The code is a little convoluted because of its contradictory goals:
//    1) avoid collecting the RDD tot he driver node (thus having to serialize ConsumerRecord
//    2) print the partition information sequentially to keep the output from being jumbled
//
// It may be fun to rewrite it so that a data structure containing this infrastructure is produced in parallel
// and then collected and printed sequentially.
//
object PartitionMapAnalyzer {

  def analyze[K,V](r: RDD[ConsumerRecord[K,V]],
                   dumpRecords: Boolean = false) : Unit =
  {
    if (r.count() > 0) {
      println("*** " + r.getNumPartitions + " partitions")

      val partitions = r.glom().zipWithIndex()

      // this loop will be sequential; each iteration analyzes one partition
      (0l to partitions.count() - 1).foreach(n => analyzeOnePartition(partitions, n, dumpRecords))

    } else {
      println("*** RDD is empty")
    }
  }

  private def analyzeOnePartition[K,V](partitions: RDD[(Array[ConsumerRecord[K, V]], Long)],
                                       which: Long,
                                       dumpRecords: Boolean) : Unit =
  {
    partitions.foreach({
      case (data: Array[ConsumerRecord[K, V]], index: Long) => {
        if (index == which) {
          println(s"*** partition $index has ${data.length} records")
          data.groupBy(cr => (cr.topic(), cr.partition())).foreach({
            case (k: (String, Int), v: Array[ConsumerRecord[K, V]]) =>
              println(s"*** rdd partition = $index, topic = ${k._1}, topic partition = ${k._2}, record count = ${v.length}.")
          })
          if (dumpRecords) data.foreach(cr => println(s"RDD partition $index record $cr"))
        }
      }
    })
  }
}
import java.util.{Arrays, Properties}

import kafka.serializer.StringDecoder
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}

/**
  * This example is very similar to SimpleStreaming, except that the data is sent
  * from an RDD with 5 partitions to a Kafka topic with 6 partitions. WThe KafkaStream consuming
  * the topic produces RDDs with size partitions. This is because the data is repartitioned when sent,
  * as we continue use the KafkaProducer constructor overload that doesn't allow us to specify
  * the destination partition.
  */
object SendWithDifferentPartitioning {

  /**
    * Publish some data to a topic. Encapsulated here to ensure serializability.
    * @param max
    * @param sc
    * @param topic
    * @param config
    */
  def send(max: Int, sc: SparkContext, topic: String, config: Properties): Unit = {

    // put some data in an RDD and publish to Kafka
    val numbers = 1 to max
    val numbersRDD = sc.parallelize(numbers, 5)

    val kafkaSink = sc.broadcast(SparkKafkaSink(config))

    println("*** producing data")

    numbersRDD.foreach { n =>
      // NOTE:
      //     1) the keys and values are strings, which is important when receiving them
      //     2) We don't specify which Kafka partition to send to, so a hash of the key
      //        is used to determine this
      kafkaSink.value.send(topic, "key_" + n, "string_" + n)
    }
  }

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 6)



    val conf = new SparkConf().setAppName("SendWithDifferentPartitioning").setMaster("local[7]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    val max = 1000

    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())
      r.foreach(s => println(s))
      if (r.count() > 0) {
        // let's see how many partitions the resulting RDD has -- notice that it has nothing
        // to do with the number of partitions in the RDD used to publish the data (4), nor
        // the number of partitions of the topic (which also happens to be four.)
        println("*** " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        send(max, sc, topic, client.basicStringStringProducer)
        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}package structured

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.sql.SparkSession
import util.{EmbeddedKafkaServer, SimpleKafkaClient}

/**
  * A very simple example of structured streaming from a Kafka source, where the messages
  * are produced directly via calls to a KafkaProducer. A streaming DataFrame is created from a
  * single Kafka topic, and feeds all the data received to a streaming computation that outputs it to a console.
  *
  * Note that writing all the incremental data in each batch to output only makes sense because there is no
  * aggregation performed. In subsequent examples with aggregation this will not be possible.
  */
object Simple {

  def main (args: Array[String]) {

    val topic = "foo"

    println("*** starting Kafka server")
    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)

    Thread.sleep(5000)

    // publish some messages
    println("*** Publishing messages")
    val max = 5
    val client = new SimpleKafkaClient(kafkaServer)
    val numbers = 1 to max
    val producer = new KafkaProducer[String, String](client.basicStringStringProducer)
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic, "[1]key_" + n, "[1]string_" + n))
    }
    Thread.sleep(5000)

    println("*** Starting to stream")

    val spark = SparkSession
      .builder
      .appName("Structured_Simple")
      .config("spark.master", "local[4]")
      .getOrCreate()

    val ds1 = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", kafkaServer.getKafkaConnect)
      .option("subscribe", topic)
      .option("startingOffsets", "earliest") // equivalent of auto.offset.reset which is not allowed here
      .load()

    val counts = ds1.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")

    val query = counts.writeStream
      .format("console") // write all counts to console when updated
      .start()

    println("*** done setting up streaming")

    Thread.sleep(5000)

    println("*** publishing more messages")
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic, "[2]key_" + n, "[2]string_" + n))
    }

    Thread.sleep(5000)

    println("*** Stopping stream")
    query.stop()

    query.awaitTermination()
    spark.stop()

    println("*** Streaming terminated")

    // stop Kafka
    println("*** Stopping Kafka")
    kafkaServer.stop()

    println("*** done")
  }
}package structured

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.sql.SparkSession
import util.{EmbeddedKafkaServer, SimpleKafkaClient}

/**
  * A streaming DataFrame is created from a single Kafka topic, an aggregating query is set up to count
  * occurrences of each key, and the results are streamed to a console. Each batch results in the entire
  * aggregation result to date being output.
  */
object SimpleAggregation {

  def main (args: Array[String]) {

    val topic = "foo"

    println("*** starting Kafka server")
    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)

    Thread.sleep(5000)

    // publish some messages
    println("*** Publishing messages")
    val max = 1000
    val client = new SimpleKafkaClient(kafkaServer)
    val numbers = 1 to max
    val producer = new KafkaProducer[String, String](client.basicStringStringProducer)
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic, "key_" + (n % 4), "string_" + n))
    }
    Thread.sleep(5000)

    println("*** Starting to stream")

    val spark = SparkSession
      .builder
      .appName("Structured_Simple")
      .config("spark.master", "local[4]")
      .getOrCreate()

    import spark.implicits._

    val ds1 = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", kafkaServer.getKafkaConnect)
      .option("subscribe", topic)
      .option("startingOffsets", "earliest") // equivalent of auto.offset.reset which is not allowed here
      .load()

    val counts = ds1.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")
      .groupBy("key")
      .count()

    val query = counts.writeStream
      .outputMode("complete")
      .format("console")
      .start()

    println("*** done setting up streaming")

    Thread.sleep(5000)

    println("*** publishing more messages")
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic, "key_" + (n % 4), "string_" + n))
    }

    Thread.sleep(5000)

    println("*** Stopping stream")
    query.stop()

    query.awaitTermination()
    spark.stop()

    println("*** Streaming terminated")

    // stop Kafka
    println("*** Stopping Kafka")
    kafkaServer.stop()

    println("*** done")
  }
}package util

import java.util
import java.util.Properties

import scala.collection.JavaConversions._
import org.apache.kafka.clients.consumer.{ConsumerConfig, ConsumerRecords, KafkaConsumer}
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerConfig, ProducerRecord}
import org.apache.kafka.common.serialization.{StringDeserializer, StringSerializer}


/**
  * Simple utilities for connecting directly to Kafka.
  */
class SimpleKafkaClient(server: EmbeddedKafkaServer) {

  def send(topic: String, pairs: Seq[(String, String)]) : Unit = {
    val producer = new KafkaProducer[String, String](basicStringStringProducer)
    pairs.foreach(pair => {
      producer send(new ProducerRecord(topic, pair._1, pair._2))
    })
    producer.close()
  }

  /**
    * Read and print the specified number of records from the specified topic.
    * Poll for as long as necessary.
    * @param topic
    * @param max
    */
  def consumeAndPrint(topic: String, max: Int): Unit = {
    // configure a consumer


    val consumer = new KafkaConsumer[String, String](basicStringStringConsumer);

    // need to subscribe to the topic

    consumer.subscribe(util.Arrays.asList(topic))

    // and read the records back -- just keep polling until we have read
    // all of them (poll each 100 msec) as the Kafka server may not make
    // them available immediately

    var count = 0;

    while (count < max) {
      println("*** Polling ")

      val records: ConsumerRecords[String, String] =
        consumer.poll(100)
      println(s"*** received ${records.count} messages")
      count = count + records.count

      // must specify the topic as we could have subscribed to more than one
      records.records(topic).foreach(rec => {
        println("*** [ " + rec.partition() + " ] " + rec.key() + ":" + rec.value())
      })
    }

    println("*** got the expected number of messages")

    consumer.close()
  }

  def basicStringStringProducer : Properties = {
    val config: Properties = new Properties
    config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, classOf[StringSerializer].getCanonicalName)
    config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, classOf[StringSerializer].getCanonicalName)
    config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, server.getKafkaConnect)
    //config.put(ProducerConfig.PARTITIONER_CLASS_CONFIG, "org.apache.kafka.clients.producer.internals.DefaultPartitioner")
    config
  }

  def basicStringStringConsumer : Properties = {
    SimpleKafkaClient.getBasicStringStringConsumer(server)
  }
}

object SimpleKafkaClient {

  def getBasicStringStringConsumer(server: EmbeddedKafkaServer, group:String = "MyGroup") : Properties = {
    val consumerConfig: Properties = new Properties
    consumerConfig.put(ConsumerConfig.GROUP_ID_CONFIG, group)
    consumerConfig.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, classOf[StringDeserializer].getCanonicalName)
    consumerConfig.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, classOf[StringDeserializer].getCanonicalName)
    consumerConfig.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, server.getKafkaConnect)
    consumerConfig.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")

    //consumerConfig.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY, "roundrobin")

    consumerConfig
  }

}
import java.util.Properties
import java.util.Arrays

import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}
import java.util

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.broadcast.Broadcast
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}

/**
  * The most basic streaming example: starts a Kafka server, creates a topic, creates a stream
  * to process that topic, and publishes some data using the SparkKafkaSink.
  *
  * Notice there's quite a lot of waiting. It takes some time for streaming to get going,
  * and data published too early tends to be missed by the stream. (No doubt, this is partly
  * because this example uses the simplest method to create the stream, and thus doesn't
  * get an opportunity to set auto.offset.reset to "earliest".
  *
  * Also, data that is published takes some time to propagate to the stream.
  * This seems inevitable, and is almost guaranteed to be slower
  * in a self-contained example like this.
  */
object SimpleStreaming {

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)



    val conf = new SparkConf().setAppName("SimpleStreaming").setMaster("local[4]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    // this many messages
    val max = 1000

    // Create the stream.
    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())
      r.foreach(s => println(s))
      if (r.count() > 0) {
        // let's see how many partitions the resulting RDD has -- notice that it has nothing
        // to do with the number of partitions in the RDD used to publish the data (4), nor
        // the number of partitions of the topic (which also happens to be four.)
        println("*** " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        val numbers = 1 to max

        val producer = new KafkaProducer[String, String](client.basicStringStringProducer)

        numbers.foreach { n =>
          // NOTE:
          //     1) the keys and values are strings, which is important when receiving them
          //     2) We don't specify which Kafka partition to send to, so a hash of the key
          //        is used to determine this
          producer.send(new ProducerRecord(topic, "key_" + n, "string_" + n))
        }
        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}import java.util.{Arrays, Properties}

import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, SimpleKafkaClient, SparkKafkaSink}

/**
  * The most basic streaming example: starts a Kafka server, creates a topic, creates a stream
  * to process that topic, and publishes some data using the SparkKafkaSink.
  *
  * Notice there's quite a lot of waiting. It takes some time for streaming to get going,
  * and data published too early tends to be missed by the stream. (No doubt, this is partly
  * because this example uses the simplest method to create the stream, and thus doesn't
  * get an opportunity to set auto.offset.reset to "earliest".
  *
  * Also, data that is published takes some time to propagate to the stream.
  * This seems inevitable, and is almost guaranteed to be slower
  * in a self-contained example like this.
  */
object SimpleStreamingFromRDD {

  /**
    * Publish some data to a topic. Encapsulated here to ensure serializability.
    * @param max
    * @param sc
    * @param topic
    * @param config
    */
  def send(max: Int, sc: SparkContext, topic: String, config: Properties): Unit = {

    // put some data in an RDD and publish to Kafka
    val numbers = 1 to max
    val numbersRDD = sc.parallelize(numbers, 4)

    val kafkaSink = sc.broadcast(SparkKafkaSink(config))

    println("*** producing data")

    numbersRDD.foreach { n =>
      // NOTE:
      //     1) the keys and values are strings, which is important when receiving them
      //     2) We don't specify which Kafka partition to send to, so a hash of the key
      //        is used to determine this
      kafkaSink.value.send(topic, "key_" + n, "string_" + n)
    }
  }

  def main (args: Array[String]) {

    val topic = "foo"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic, 4)



    val conf = new SparkConf().setAppName("SimpleStreamingFromRDD").setMaster("local[4]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    // this many messages
    val max = 1000

    // Create the stream.
    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topic),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())
      r.foreach(s => println(s))
      if (r.count() > 0) {
        // let's see how many partitions the resulting RDD has -- notice that it has nothing
        // to do with the number of partitions in the RDD used to publish the data (4), nor
        // the number of partitions of the topic (which also happens to be four.)
        println("*** " + r.getNumPartitions + " partitions")
        r.glom().foreach(a => println("*** partition size = " + a.size))
      }
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        send(max, sc, topic, client.basicStringStringProducer)

        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}package util

import java.util.Properties

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}

/**
  * For publishing to Kafka from every partition of an RDD -- see
  * http://allegro.tech/2015/08/spark-kafka-integration.html
  *
  * @param createProducer
  */
class SparkKafkaSink(createProducer: () => KafkaProducer[String, String]) extends Serializable {

  lazy val producer = createProducer()

  /**
    * Records assigned to partitions using the configured partitioner.
    *
    * @param topic
    * @param key
    * @param value
    */
  def send(topic: String, key: String, value: String): Unit = {
    producer.send(new ProducerRecord(topic, key, value))
  }

  /**
    * Records assigned to partitions explicitly, ignoring the configured partitioner.
    *
    * @param topic
    * @param partition
    * @param key
    * @param value
    */
  def send(topic: String, partition: Int, key: String, value: String): Unit = {
    producer.send(new ProducerRecord(topic, partition, key, value))
  }
}

object SparkKafkaSink {
  def apply(config: Properties): SparkKafkaSink = {
    val f = () => {
      val producer = new KafkaProducer[String, String](config)

      sys.addShutdownHook {
        producer.close()
      }

      producer
    }
    new SparkKafkaSink(f)
  }
}package applications.stock_price_feed

import java.io.{ByteArrayInputStream, ByteArrayOutputStream, ObjectInputStream, ObjectOutputStream}
import java.util.{Arrays, Properties}

import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerConfig, ProducerRecord}
import org.apache.kafka.common.serialization.{Deserializer, Serializer}
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import util.{EmbeddedKafkaServer, PartitionMapAnalyzer, SimpleKafkaClient}

import scala.collection.{Iterator, mutable}

class TradeData(val symbol: String, val price: Double, val volume: Long) extends Serializable {

}

class ChunkedTradeData(val symbol: String) extends Serializable {
  var trades = 0
  var totalAmount = 0.0
  var totalVolume: Long = 0

  def addTrade(trade: TradeData) : Unit = {
    trades = trades + 1
    totalVolume = totalVolume + trade.volume
    totalAmount = totalAmount + trade.volume * trade.price
  }

  def averagePrice = totalAmount / totalVolume
}

class TradeDataSerializer extends Serializer[TradeData] {

  override def close(): Unit = {}

  override def configure(config: java.util.Map[String, _], isKey: Boolean) : Unit = {}

  override def serialize(topic: String, data: TradeData) : Array[Byte] = {
    val stream: ByteArrayOutputStream = new ByteArrayOutputStream()
    val oos = new ObjectOutputStream(stream)
    oos.writeObject(data)
    oos.close
    stream.toByteArray
  }
}

class TradeDataDeserializer extends Deserializer[TradeData] {

  override def close(): Unit = {}

  override def configure(config: java.util.Map[String, _], isKey: Boolean) : Unit = {}

  override def deserialize(topic: String, data: Array[Byte]) : TradeData = {
    val ois = new ObjectInputStream(new ByteArrayInputStream(data))
    val value = ois.readObject
    ois.close
    value.asInstanceOf[TradeData]
  }
}



object StockMarketData {

  def getProducer(server: EmbeddedKafkaServer) : Properties = {
    val config: Properties = new Properties
    config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, classOf[TradeDataSerializer].getCanonicalName)
    config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, classOf[TradeDataSerializer].getCanonicalName)
    config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, server.getKafkaConnect)
    config
  }

  def getConsumer(server: EmbeddedKafkaServer, group:String = "MyGroup") : Properties = {
    val consumerConfig: Properties = new Properties
    consumerConfig.put(ConsumerConfig.GROUP_ID_CONFIG, group)
    consumerConfig.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, classOf[TradeDataDeserializer].getCanonicalName)
    consumerConfig.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, classOf[TradeDataDeserializer].getCanonicalName)
    consumerConfig.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, server.getKafkaConnect)
    consumerConfig.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")
    consumerConfig
  }

  def main (args: Array[String]) {

    val topic1 = "SYM1"
    val topic2 = "SYM2"

    // topics are partitioned differently
    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic1, 1)
    kafkaServer.createTopic(topic2, 1)

    val conf = new SparkConf().setAppName("StockMarketData").setMaster("local[10]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    // this many messages
    val max = 100

    // Create the stream.
    val props: Properties = getConsumer(kafkaServer)

    val rawDataFeed =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, TradeData](
          Arrays.asList(topic1, topic2),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    rawDataFeed.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())

      PartitionMapAnalyzer.analyze(r)

    })

    def chunkingFunc(i: Iterator[TradeData]) : Iterator[Map[String, ChunkedTradeData]] = {
      val m = new mutable.HashMap[String, ChunkedTradeData]()
      i.foreach {
        case trade: TradeData =>
          if (m.contains(trade.symbol)) {
            m(trade.symbol).addTrade(trade)
          } else {
            val chunked = new ChunkedTradeData(trade.symbol)
            chunked.addTrade(trade)
            m(trade.symbol) = chunked
          }
      }
      Iterator.single(m.toMap)
    }

    val decodedFeed = rawDataFeed.map(cr => cr.value())

    val chunkedDataFeed = decodedFeed.mapPartitions(chunkingFunc, preservePartitioning = true)

    chunkedDataFeed.foreachRDD(rdd => {
      rdd.foreach(m =>
        m.foreach {
          case (symbol, chunk) =>
            println(s"Symbol ${chunk.symbol} Price ${chunk.averagePrice} Volume ${chunk.totalVolume} Trades ${chunk.trades}")
        })
    })

    ssc.start()

    println("*** started streaming context")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThreadTopic1 = new Thread("Producer thread 1") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        val numbers = 1 to max

        val producer = new KafkaProducer[String, TradeData](getProducer(kafkaServer))

        numbers.foreach { n =>
          // NOTE:
          //     1) the keys and values are strings, which is important when receiving them
          //     2) We don't specify which Kafka partition to send to, so a hash of the key
          //        is used to determine this
          producer.send(new ProducerRecord(topic1, new TradeData("SYM1", 12.0, 100)))
        }

      }
    }

    val producerThreadTopic2 = new Thread("Producer thread 2; controlling termination") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        val numbers = 1 to max

        val producer = new KafkaProducer[String, TradeData](getProducer(kafkaServer))

        numbers.foreach { n =>
          // NOTE:
          //     1) the keys and values are strings, which is important when receiving them
          //     2) We don't specify which Kafka partition to send to, so a hash of the key
          //        is used to determine this
          producer.send(new ProducerRecord(topic2,  new TradeData("SYM2", 123.0, 200)))
        }
        Thread.sleep(10000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }

    producerThreadTopic1.start()
    producerThreadTopic2.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}
package structured

import java.io.File

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.streaming.{ProcessingTime, Trigger}
import util.{TemporaryDirectories, EmbeddedKafkaServer, SimpleKafkaClient}

/**
  * Two Kafka topics are set up and a KafkaProducer is used to publish to the first topic.
  * Then structured streaming is used to subscribe to that topic and publish a running aggregation to the
  * second topic. Finally structured streaming is used to subscribe to the second topic and print the data received.
  */
object SubscribeAndPublish {

  def main (args: Array[String]) {

    val topic1 = "foo"
    val topic2 = "bar"

    println("*** starting Kafka server")
    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topic1, 4)
    kafkaServer.createTopic(topic2, 4)

    Thread.sleep(5000)

    // publish some messages
    println("*** Publishing messages")
    val max = 1000
    val client = new SimpleKafkaClient(kafkaServer)
    val numbers = 1 to max
    val producer = new KafkaProducer[String, String](client.basicStringStringProducer)
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic1, "key_" + n, "string_" + n))
    }
    Thread.sleep(5000)

    val checkpointPath = kafkaServer.tempDirs.checkpointPath

    println("*** Starting to stream")

    val spark = SparkSession
      .builder
      .appName("Structured_SubscribeAndPublish")
      .config("spark.master", "local[4]")
      .getOrCreate()

    import spark.implicits._

    val ds1 = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", kafkaServer.getKafkaConnect)
      .option("subscribe", topic1)
      .option("startingOffsets", "earliest")
      .load()

    val counts = ds1.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")
      .groupBy()
      .count()

    val publishQuery =
      counts
        .selectExpr("'RunningCount' AS key", "CAST(count AS STRING) AS value")
        .writeStream
        .outputMode("complete")
        .format("kafka")
        .option("checkpointLocation", checkpointPath)
        .option("kafka.bootstrap.servers", kafkaServer.getKafkaConnect)
        .option("topic", topic2)
        .start()

    val ds2 = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", kafkaServer.getKafkaConnect)
      .option("subscribe", topic2)
      .option("startingOffsets", "earliest")
      .load()

    val counts2 = ds2.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")
      .as[(String, String)]

    val query = counts2
      .writeStream
      .trigger(Trigger.ProcessingTime("4 seconds"))
      .format("console")
      .start()

    println("*** done setting up streaming")

    Thread.sleep(2000)

    println("*** publishing more messages")
    numbers.foreach { n =>
      producer.send(new ProducerRecord(topic1, "key_" + n, "string_" + n))
    }

    Thread.sleep(8000)

    println("*** Stopping stream")
    query.stop()

    query.awaitTermination()
    spark.stop()

    println("*** Streaming terminated")

    // stop Kafka
    println("*** Stopping Kafka")
    kafkaServer.stop()

    println("*** done")
  }
}package util

import java.io.{IOException, File}

import org.apache.commons.io.FileUtils

/**
 * Set up temporary directories, to be deleted automatically at shutdown. If the directories
 * exist at creation time they will be cleaned up (deleted) first.
 */
private[util] class TemporaryDirectories {
  val tempRootPath = java.io.File.separator + "tmp" + java.io.File.separator + "SSWK"

  val checkpointPath = tempRootPath + File.separator + "checkpoints"

  private val rootDir = new File(tempRootPath)

  // delete in advance in case last cleanup didn't
  deleteRecursively(rootDir)
  rootDir.mkdir

  val zkSnapshotPath = tempRootPath + File.separator + "zookeeper-snapshot"
  val zkSnapshotDir = new File(zkSnapshotPath)
  zkSnapshotDir.mkdir()

  val zkLogDirPath = tempRootPath + File.separator + "zookeeper-logs"
  val zkLogDir = new File(zkLogDirPath)
  zkLogDir.mkdir()

  val kafkaLogDirPath = tempRootPath + File.separator + "kafka-logs"
  val kafkaLogDir = new File(kafkaLogDirPath)
  kafkaLogDir.mkdir()


  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    def run {
      try {
        deleteRecursively(rootDir)
      }
      catch {
        case e: Exception => {
        }
      }
    }
  }))


  private def deleteRecursively(file: File): Unit = {
    if (file.isDirectory)
      file.listFiles.foreach(deleteRecursively)
    if (file.exists && !file.delete)
      throw new Exception(s"Unable to delete ${file.getAbsolutePath}")
  }
}
import java.util.{Arrays, Calendar, Properties, TimeZone}

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import util.{EmbeddedKafkaServer, SimpleKafkaClient}

/**
  * Record timestamps were introduced into Kafka 0.10 as described in
  * https://cwiki.apache.org/confluence/display/KAFKA/KIP-32+-+Add+timestamps+to+Kafka+message
  * and
  * https://cwiki.apache.org/confluence/display/KAFKA/KIP-33+-+Add+a+time+based+log+index .
  *
  * This example sets up two different topics that handle timestamps differently -- topic A has the timestamp
  * set by the broker when it receives the record, while topic B passes through the timestamp provided in the record
  * (either programmatically when the record was created, as shown here, or otherwise automatically by the producer.)
  *
  * Since the record carries information about where its timestamp originates, its easy to subscribe to the two topics
  * to create a single stream, and then examine the timestamp of every received record and its type.
  */
object Timestamp {
  def main (args: Array[String]) {

    val topicLogAppendTime = "A"
    val topicCreateTime = "B"

    val kafkaServer = new EmbeddedKafkaServer()
    kafkaServer.start()
    kafkaServer.createTopic(topicLogAppendTime, 4, logAppendTime = true)
    kafkaServer.createTopic(topicCreateTime, 4)

    val conf = new SparkConf().setAppName("Timestamp").setMaster("local[4]")
    val sc = new SparkContext(conf)

    // streams will produce data every second
    val ssc = new StreamingContext(sc, Seconds(1))

    // this many messages
    val max = 1000

    // Create the stream.
    val props: Properties = SimpleKafkaClient.getBasicStringStringConsumer(kafkaServer)

    val kafkaStream =
      KafkaUtils.createDirectStream(
        ssc,
        LocationStrategies.PreferConsistent,
        ConsumerStrategies.Subscribe[String, String](
          Arrays.asList(topicLogAppendTime, topicCreateTime),
          props.asInstanceOf[java.util.Map[String, Object]]
        )

      )

    val timeFormat = new java.text.SimpleDateFormat("HH:mm:ss.SSS")

    // now, whenever this Kafka stream produces data the resulting RDD will be printed
    kafkaStream.foreachRDD(r => {
      println("*** got an RDD, size = " + r.count())
      r.foreach(cr => {

        val time = timeFormat.format(cr.timestamp())
        println("Topic [" + cr.topic() + "] Key [" + cr.key + "] Type [" + cr.timestampType().toString +
          "] Timestamp [" + time + "]")
      })
    })

    ssc.start()

    println("*** started termination monitor")

    // streams seem to need some time to get going
    Thread.sleep(5000)

    val producerThread = new Thread("Streaming Termination Controller") {
      override def run() {
        val client = new SimpleKafkaClient(kafkaServer)

        val producer = new KafkaProducer[String, String](client.basicStringStringProducer)

        // the two records are created at almost the same time, so should have similar creation time stamps
        // if we didn't provide one, the producer would so so, but then we wouldn't know what it was ...

        val timestamp = Calendar.getInstance().getTime().getTime

        println("Record creation time: " + timeFormat.format(timestamp))

        val record1 = new ProducerRecord(topicLogAppendTime, 1, timestamp, "key1", "value1")
        val record2 = new ProducerRecord(topicCreateTime, 1, timestamp, "key2", "value2")

        Thread.sleep(2000)

        // the two records are sent to the Kafka broker two seconds after they are created, and three seconds apart

        producer.send(record1)
        Thread.sleep(3000)
        producer.send(record2)

        Thread.sleep(5000)
        println("*** requesting streaming termination")
        ssc.stop(stopSparkContext = false, stopGracefully = true)
      }
    }
    producerThread.start()

    try {
      ssc.awaitTermination()
      println("*** streaming terminated")
    } catch {
      case e: Exception => {
        println("*** streaming exception caught in monitor thread")
      }
    }

    // stop Spark
    sc.stop()

    // stop Kafka
    kafkaServer.stop()

    println("*** done")
  }
}
