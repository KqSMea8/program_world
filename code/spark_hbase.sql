import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.streaming.Seconds
import org.apache.kafka.common.serialization.StringDeserializer
import scala.util.Random
import org.apache.spark.streaming.dstream.InputDStream
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.spark.streaming.kafka010.KafkaUtils
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
import org.apache.spark.streaming.dstream.DStream
import java.util.ArrayList
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.client.Connection
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hbase.client.ConnectionFactory
import org.apache.hadoop.hbase.TableName
import scala.reflect.io.Streamable.Bytes

object SparkStreamingToHbase {
   def main(args: Array[String]): Unit = {

    val sparkConf = new SparkConf().setAppName(s"${this.getClass.getSimpleName}").setMaster("local[*]")
    val sc = new SparkContext(sparkConf)
    val ssc = new StreamingContext(sc, Seconds(2))

    val kafkaParams = Map[String, AnyRef](
      "bootstrap.servers" -> "192.168.0.183:9092,192.168.0.213:9092,192.168.0.214:9092",
      "key.deserializer" -> classOf[StringDeserializer],
      "value.deserializer" -> classOf[StringDeserializer],
      "auto.offset.reset" -> "latest",
      "group.id" -> s"GROUP${new Random().nextInt(1000)}"
    )

    val topics = Array("Monitor")

    val stream: InputDStream[ConsumerRecord[String, String]] = KafkaUtils.createDirectStream[String, String](
      ssc,
      PreferConsistent,
      Subscribe[String, String](topics, kafkaParams)
    )

    val values: DStream[Array[String]] = stream.map(_.value.split("\\|"))

    values.foreachRDD(rdd => {
      rdd.foreachPartition(partition => {
        val connection = HBaseUtil.getConnection
        val tableName = TableName.valueOf("Monitor")
        val table = connection.getTable(tableName)
        val puts = new ArrayList[Put]

        try {
          partition.foreach(arr => {
            val put = new Put(arr(0).getBytes)
            val index = Array[Int](0, 1, 2, 3, 4, 5, 6)
            var value = ""
            for (i <- 0 until index.length) {
              value += arr(i) + "|"
            }
            value = value.dropRight(1)
            put.addColumn("f".getBytes, "q".getBytes, value.getBytes)
            puts.add(put)
            // 这里为了提高性能，每一万条入一次HBase库
            if (puts.size % 10000 == 0) {
              table.put(puts)
              puts.clear()
            }
          })
        } catch {
          case e: Exception => e.printStackTrace
        } finally {
          table.put(puts)
          table.close
          connection.close
        }
      })
    })

    ssc.start
    ssc.awaitTermination
  }
}


object HBaseUtil {

  var conf: Configuration = null
  var connection: Connection = null

  def getConnection(): Connection = {

    if (conf == null) {
      conf.set("hbase.zookeeper.quorum", "192.168.0.183:2181,192.168.0.213:2181,192.168.0.214:2181")
    }

    if ((connection == null || connection.isClosed()) && conf != null) {
      try {
        connection = ConnectionFactory.createConnection(conf)
      } catch {
        case e: Exception => e.printStackTrace()
      }
    }
    return connection;
  }

  def colse() = {
    if (connection != null) {
      try {
        connection.close();
      } catch {
        case e: Exception => e.printStackTrace()
      }
    }
  }
