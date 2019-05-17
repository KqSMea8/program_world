package org.dataalgorithms.chap23.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * Correlate "all-samples" vs. "all-samples".
  * Here we use Apache's PearsonsCorrelation,
  * but you may replace it with your desired
  * correlation algorithm.
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object AllVersusAllCorrelation {

  def main(args: Array[String]): Unit = {
    //
    if (args.size < 3) {
      println("Usage: AllVersusAllCorrelation <input-sample-reference> <input-dir-bioset> <output-dir>")
      //
      // <input-sample-reference> can be one of the following:
      //      "r1" = normal sample
      //      "r2" = disease sample
      //      "r3" = paired sample
      //      "r4" = unknown
      //
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("AllVersusAllCorrelation")
    val sc = new SparkContext(sparkConf)

    val inputReference = args(0) // {"r1", "r2", "r3", "r4"}
    val inputBioset = args(1)
    val output = args(2)

    val ref = sc.broadcast(inputReference)
    val biosets = sc.textFile(inputBioset)

    // keep the sample matching with the <input-sample-reference>
    val filtered = biosets.filter(_.split(",")(1).equals(ref.value))

    val pairs = filtered.map(record => {
      val tokens = record.split(",")
      (tokens(0), (tokens(2), tokens(3).toDouble))
    })

    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    val grouped = pairs.groupByKey()

    val cart = grouped.cartesian(grouped)

    // since "correlation of (A, B)" is the same as
    // "correlation of (B, A)", we just only keep (A, B)
    // before further computation and drop (B, A)
    val filtered2 = cart.filter(pair => pair._1._1 < pair._2._1)

    val finalresult = filtered2.map(t => {
      val g1 = t._1
      val g2 = t._2
      val g1Map = g1._2.toMap.groupBy(_._1).mapValues(itr => (itr.values.sum, itr.values.size))
      val g2Map = g2._2.toMap.groupBy(_._1).mapValues(itr => (itr.values.sum, itr.values.size))
      val xy = for {
        g1Entry <- g1Map
        g1PatientID = g1Entry._1
        g2MD = g2Map.get(g1PatientID)
        if (g2MD.isDefined)
      } yield ((g1Entry._2._1 / g1Entry._2._2, g2MD.get._1 / g2MD.get._2))

      val (x, y) = xy.unzip
      val k = (g1._1, g2._1)
      if (x.size < 3) (k, (Double.NaN, Double.NaN))
      else {
        import org.apache.commons.math3.distribution.TDistribution
        import org.apache.commons.math3.stat.correlation.PearsonsCorrelation
        val PC = new PearsonsCorrelation()
        val correlation = PC.correlation(x.toArray, y.toArray)
        val t = math.abs(correlation * math.sqrt((x.size - 2.0) / (1.0 - (correlation * correlation))))
        val tdist = new TDistribution(x.size - 2)
        val pvalue = 2 * (1.0 - tdist.cumulativeProbability(t))
        (k, (correlation, pvalue))
      }
    })

    // For deugging purpose
    finalresult.foreach(println)

    // save final output
    finalresult.saveAsTextFile(output)

    // done!
    sc.stop()
  }

}/*                     __                                               *\
**     ________ ___   / /  ___     Scala API                            **
**    / __/ __// _ | / /  / _ |    (c) 2002-2013, LAMP/EPFL             **
**  __\ \/ /__/ __ |/ /__/ __ |    http://scala-lang.org/               **
** /____/\___/_/ |_/____/_/ | |                                         **
**                          |/                                          **
\*                                                                      */

package scala.annotation

/**
  * An annotation that designates the class to which it is applied as cloneable
  */
@deprecated("instead of `@cloneable class C`, use `class C extends Cloneable`", "2.10.0")
class cloneable extends scala.annotation.StaticAnnotation

package org.dataalgorithms.chap16.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * Count and identify triangles for a given graph
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object CountTriangles {
  //
  def main(args: Array[String]): Unit = {
    if (args.size < 2) {
      println("Usage: CountTriangles <input-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("CountTriangles")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val lines = sc.textFile(input)

    val edges = lines.flatMap(line => {
      val tokens = line.split("\\s+")
      val start = tokens(0).toLong
      val end = tokens(1).toLong
      (start, end) :: (end, start) :: Nil
    })

    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    val triads = edges.groupByKey()

    val possibleTriads = triads.flatMap(tuple => {
      val values = tuple._2.toList
      val result = values.map(v => {
        ((tuple._1, v), 0L)
      })
      val sorted = values.sorted
      val combinations = sorted.combinations(2).map { case Seq(a, b) => (a, b) }.toList
      combinations.map((_, tuple._1)) ::: result
    })

    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    val triadsGrouped = possibleTriads.groupByKey()

    val trianglesWithDuplicates = triadsGrouped.flatMap(tg => {
      val key = tg._1
      val values = tg._2
      val list = values.filter(_ != 0)
      if (values.exists(_ == 0)) {
        if (list.isEmpty) Nil

        list.map(l => {
          val sortedTriangle = (key._1 :: key._2 :: l :: Nil).sorted
          (sortedTriangle(0), sortedTriangle(1), sortedTriangle(2))
        })
      } else Nil
    })

    val uniqueTriangles = trianglesWithDuplicates distinct

    // For debugging purpose
    uniqueTriangles.foreach(println)

    uniqueTriangles.saveAsTextFile(output)

    // done
    sc.stop()

  }
}package org.dataalgorithms.chap01.scala

import org.apache.spark.Partitioner


/**
  * A custom partitioner
  *
  * org.apache.spark.Partitioner:
  *           An abstract class that defines how the elements in a
  *           key-value pair RDD are partitioned by key. Maps each
  *           key to a partition ID, from 0 to numPartitions - 1.
  *
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
class CustomPartitioner(partitions: Int) extends Partitioner {

  require(partitions > 0, s"Number of partitions ($partitions) cannot be negative.")

  def numPartitions: Int = partitions

  def getPartition(key: Any): Int = key match {
    case (k: String, v: Int) => math.abs(k.hashCode % numPartitions)
    case null                => 0
    case _                   => math.abs(key.hashCode % numPartitions)
  }

  override def equals(other: Any): Boolean = other match {
    case h: CustomPartitioner => h.numPartitions == numPartitions
    case _                    => false
  }

  override def hashCode: Int = numPartitions
}
package org.dataalgorithms.chap04.scala

import org.apache.spark.sql.Row
import org.apache.spark.SparkConf
import org.apache.spark.sql.SparkSession

/**
  * This approach used DataFrame add in Spark 1.3 and above.
  * DataFrame are quite powerful yet easy to use, hence higly
  * recommended.
  *
  * This program shows two approaches:
  * 1. Using DataFrame API
  * 2. Using SQL query (this is more easy approach).
  *    We used exactly same query as shown in Query 3 page 88.
  *
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */

object DataFrameLeftOuterJoin {

  def main(args: Array[String]): Unit = {
    if (args.size < 3) {
      println("Usage: DataFrameLeftOuterJoin <users-data-path> <transactions-data-path> <output-path>")
      sys.exit(1)
    }

    val usersInputFile = args(0)
    val transactionsInputFile = args(1)
    val output = args(2)

    val sparkConf = new SparkConf()

    // Use for Spark 1.6.2 or below
    // val sc = new SparkContext(sparkConf)
    // val spark = new SQLContext(sc)

    // Use below for Spark 2.0.0
    val spark = SparkSession
      .builder()
      .appName("DataFram LeftOuterJoin")
      .config(sparkConf)
      .getOrCreate()

    // Use below for Spark 2.0.0
    val sc = spark.sparkContext

    import spark.implicits._
    import org.apache.spark.sql.types._

    // Define user schema
    val userSchema = StructType(Seq(
      StructField("userId", StringType, false),
      StructField("location", StringType, false)))

    // Define transaction schema
    val transactionSchema = StructType(Seq(
      StructField("transactionId", StringType, false),
      StructField("productId", StringType, false),
      StructField("userId", StringType, false),
      StructField("quantity", IntegerType, false),
      StructField("price", DoubleType, false)))

    def userRows(line: String): Row = {
      val tokens = line.split("\t")
      Row(tokens(0), tokens(1))
    }

    def transactionRows(line: String): Row = {
      val tokens = line.split("\t")
      Row(tokens(0), tokens(1), tokens(2), tokens(3).toInt, tokens(4).toDouble)
    }

    val usersRaw = sc.textFile(usersInputFile) // Loading user data
    val userRDDRows = usersRaw.map(userRows(_)) // Converting to RDD[org.apache.spark.sql.Row]
    val users = spark.createDataFrame(userRDDRows, userSchema) // obtaining DataFrame from RDD

    val transactionsRaw = sc.textFile(transactionsInputFile) // Loading transactions data
    val transactionsRDDRows = transactionsRaw.map(transactionRows(_)) // Converting to  RDD[org.apache.spark.sql.Row]
    val transactions = spark.createDataFrame(transactionsRDDRows, transactionSchema) // obtaining DataFrame from RDD

    //
    // Approach 1 using DataFrame API
    //
    val joined = transactions.join(users, transactions("userId") === users("userId")) // performing join on on userId
    joined.printSchema() //Prints schema on the console

    val product_location = joined.select(joined.col("productId"), joined.col("location")) // Selecting only productId and location
    val product_location_distinct = product_location.distinct // Getting only disting values
    val products = product_location_distinct.groupBy("productId").count()
    products.show() // Print first 20 records on the console
    products.write.save(output + "/approach1") // Saves output in compressed Parquet format, recommended for large projects.
    products.rdd.saveAsTextFile(output + "/approach1_textFormat") // Converts DataFram to RDD[Row] and saves it to in text file. To see output use cat command, e.g. cat output/approach1_textFormat/part-00*
    // Approach 1 ends

    //
    // Approach 2 using plain old SQL query
    //
    // Use below for Spark 1.6.2 or below
    // users.registerTempTable("users") // Register as table (temporary) so that query can be performed on the table
    // transactions.registerTempTable("transactions") // Register as table (temporary) so that query can be performed on the table

    // Use below for Spark 2.0.0
    users.createOrReplaceTempView("users") // Register as table (temporary) so that query can be performed on the table
    transactions.createOrReplaceTempView("transactions") // Register as table (temporary) so that query can be performed on the table

    import spark.sql

    // Using Query 3 given on Page 88
    val sqlResult = sql("SELECT productId, count(distinct location) locCount FROM transactions LEFT OUTER JOIN users ON transactions.userId = users.userId group by productId")
    sqlResult.show() // Print first 20 records on the console
    sqlResult.write.save(output + "/approach2") // Saves output in compressed Parquet format, recommended for large projects.
    sqlResult.rdd.saveAsTextFile(output + "/approach2_textFormat") // Converts DataFram to RDD[Row] and saves it to in text file. To see output use cat command, e.g. cat output/approach2_textFormat/part-00*
    // Approach 2 ends

    // done
    spark.stop()
  }

}
package org.dataalgorithms.chap24.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * DNA-base counts for FASTA files using Spark's combineByKey()
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object DNABaseCountFASTAWithCombineByKey {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: DNABaseCountFASTAWithCombineByKey <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("DNABaseCountFASTAWithCombineByKey")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val fastaRDD = sc.textFile(input)

    val dnaSequence = fastaRDD.filter(!_.startsWith(">"))

    val basePair = dnaSequence.flatMap (_.toUpperCase().toCharArray().map((_, 1)))

    val result = basePair.combineByKey(
      (count: Int) => count,
      (c1: Int, c2: Int) => c1 + c2,
      (c1: Int, c2: Int) => c1 + c2
    )

    // For debugging purpose
    result.foreach(println)

    result.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap24.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * DNA-base counts for FASTA files using Spark's mapPartitions()
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object DNABaseCountFASTAWithMapPartitions {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: DNABaseCountFASTAWithMapPartitions  <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("DNABaseCountFASTAWithMapPartitions")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val fastaRDD = sc.textFile(input)

    val partitions = fastaRDD.mapPartitions(itr => {
      val mutableMap = collection.mutable.Map.empty[Char, Long]
      itr.filter(!_.startsWith(">")).foreach(_.toUpperCase().toCharArray().foreach(base => {
        val count = mutableMap.getOrElse(base, 0L)
        mutableMap.put(base, count + 1L)
      }))
      mutableMap.toIterator
    })

    val collectPartition = partitions.collect()

    val result = collectPartition.groupBy(_._1).mapValues(_.unzip._2.sum)

    // debug output
    result.foreach(println)

    // save result in output

    // done
    sc.stop()
  }
}package org.dataalgorithms.chap24.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * DNA-base counts for FASTQ files using Spark's combineByKey()
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object DNABaseCountFASTQWithCombineByKey {
  //
  def main(args: Array[String]): Unit = {
    if (args.size < 2) {
      println("Usage: DNABaseCountFASTQWithCombineByKey <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("DNABaseCountFASTQWithCombineByKey")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val fastqRDD = sc.textFile(input)

    val dnaSequence = fastqRDD.filter(line => {
      !(
        line.startsWith("@") ||
          line.startsWith("+") ||
          line.startsWith(";") ||
          line.startsWith("!") ||
          line.startsWith("~")
        )
    })

    val basePair = dnaSequence.flatMap(_.toUpperCase().toCharArray().map((_, 1)))

    val result = basePair.combineByKey(
      (count: Int) => count,
      (c1: Int, c2: Int) => c1 + c2,
      (c1: Int, c2: Int) => c1 + c2
    )

    // For debugging purpose
    result.foreach(println)

    result.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap24.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * DNA-base counts for FASTQ files using Spark's mapPartitions()
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object DNABaseCountFASTQWithMapPartitions {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: DNABaseCountFASTQWithMapPartitions  <input dir> <output dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("DNABaseCountFASTQWithMapPartitions")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val fastqRDD = sc.textFile(input)

    val partitions = fastqRDD.mapPartitions(itr => {
      val mutableMap = collection.mutable.Map.empty[Char, Long]
      itr.filter(line => {
        !(line.startsWith("@") || line.startsWith("+") || line.startsWith(";") ||
          line.startsWith("!") || line.startsWith("~"))
      }).foreach(_.toUpperCase().toCharArray().foreach(base => {
        val count = mutableMap.getOrElse(base, 0L)
        mutableMap.put(base, count + 1L)
      }))
      mutableMap.toIterator
    })

    val collectPartition = partitions.collect()

    val result = collectPartition.groupBy(_._1).mapValues(_.unzip._2.sum)

    // debug output
    result.foreach(println)

    // save result in output

    // done
    sc.stop()
  }
}package org.dataalgorithms.chap07.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
//
import scala.collection.mutable.ListBuffer

/**
  * Market Basket Analysis: find association rules
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object FindAssociationRules {

  def main(args: Array[String]): Unit = {

    if (args.size < 2) {
      println("Usage: FindAssociationRules <input-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("market-basket-analysis")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val transactions = sc.textFile(input)

    val patterns = transactions.flatMap(line => {
      val items = line.split(",").toList // Converting to List is required because Spark doesn't partition on Array (as returned by split method)
      (0 to items.size) flatMap items.combinations filter (xs => !xs.isEmpty)
    }).map((_, 1))

    val combined = patterns.reduceByKey(_ + _)

    val subpatterns = combined.flatMap(pattern => {
      val result = ListBuffer.empty[Tuple2[List[String], Tuple2[List[String], Int]]]
      result += ((pattern._1, (Nil, pattern._2)))

      val sublist = for {
        i <- 0 until pattern._1.size
        xs = pattern._1.take(i) ++ pattern._1.drop(i + 1)
        if xs.size > 0
      } yield (xs, (pattern._1, pattern._2))
      result ++= sublist
      result.toList
    })

    val rules = subpatterns.groupByKey()

    val assocRules = rules.map(in => {
      val fromCount = in._2.find(p => p._1 == Nil).get
      val toList = in._2.filter(p => p._1 != Nil).toList
      if (toList.isEmpty) Nil
      else {
        val result =
          for {
            t2 <- toList
            confidence = t2._2.toDouble / fromCount._2.toDouble
            difference = t2._1 diff in._1
          } yield (((in._1, difference, confidence)))
        result
      }
    })

    // Formatting the result just for easy reading.
    val formatResult = assocRules.flatMap(f => {
      f.map(s => (s._1.mkString("[", ",", "]"), s._2.mkString("[", ",", "]"), s._3))
    })
    formatResult.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap08.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Find Common Friends
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object FindCommonFriends {

  def main(args: Array[String]): Unit = {
    if (args.size < 2) {
      println("Usage: FindCommonFriends <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("FindCommonFriends")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val records = sc.textFile(input)

    val pairs = records.flatMap(s => {
      val tokens = s.split(",")
      val person = tokens(0).toLong
      val friends = tokens(1).split("\\s+").map(_.toLong).toList
      val result = for {
        i <- 0 until friends.size
        friend = friends(i)
      } yield {
        if (person < friend)
          ((person, friend), friends)
        else
          ((friend, person), friends)
      }
      result
    })

    val grouped = pairs.groupByKey()

    val commonFriends = grouped.mapValues(iter => {
      val friendCount = for {
        list <- iter
        if !list.isEmpty
        friend <- list
      } yield ((friend, 1))
      friendCount.groupBy(_._1).mapValues(_.unzip._2.sum).filter(_._2 > 1).map(_._1)
    })

    // save the result to the file
    commonFriends.saveAsTextFile(output)

    //Format result for easy viewing
    val formatedResult = commonFriends.map(
      f => s"(${f._1._1}, ${f._1._2})\t${f._2.mkString("[", ", ", "]")}"
    )

    formatedResult.foreach(println)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap09.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * FriendRecommendation: recommed friends...
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object FriendRecommendation {

  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: FriendRecommendation <input-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("FriendRecommendation")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val records = sc.textFile(input)

    val pairs = records.flatMap(line => {
      val tokens = line.split("\\s")
      val person = tokens(0).toLong
      val friends = tokens(1).split(",").map(_.toLong).toList
      val mapperOutput = friends.map(directFriend => (person, (directFriend, -1.toLong)))

      val result = for {
        fi <- friends
        fj <- friends
        possibleFriend1 = (fj, person)
        possibleFriend2 = (fi, person)
        if (fi != fj)
      } yield {
        (fi, possibleFriend1) :: (fj, possibleFriend2) :: List()
      }
      mapperOutput ::: result.flatten
    })

    //
    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    //
    val grouped = pairs.groupByKey()

    val result = grouped.mapValues(values => {
      val mutualFriends = new collection.mutable.HashMap[Long, List[Long]].empty
      values.foreach(t2 => {
        val toUser = t2._1
        val mutualFriend = t2._2
        val alreadyFriend = (mutualFriend == -1)
        if (mutualFriends.contains(toUser)) {
          if (alreadyFriend) {
            mutualFriends.put(toUser, List.empty)
          } else if (mutualFriends.get(toUser).isDefined && mutualFriends.get(toUser).get.size > 0 && !mutualFriends.get(toUser).get.contains(mutualFriend)) {
            val existingList = mutualFriends.get(toUser).get
            mutualFriends.put(toUser, (mutualFriend :: existingList))
          }
        } else {
          if (alreadyFriend) {
            mutualFriends.put(toUser, List.empty)
          } else {
            mutualFriends.put(toUser, List(mutualFriend))
          }
        }
      })
      mutualFriends.filter(!_._2.isEmpty).toMap
    })

    result.saveAsTextFile(output)

    //
    // formatting and printing it to console for debugging purposes...
    //
    result.foreach(f => {
      val friends = if (f._2.isEmpty) "" else {
        val items = f._2.map(tuple => (tuple._1, "(" + tuple._2.size + ": " + tuple._2.mkString("[", ",", "]") + ")")).map(g => "" + g._1 + " " + g._2)
        items.toList.mkString(",")
      }
      println(s"${f._1}: ${friends}")
    })

    // done
    sc.stop();
  }
}package org.dataalgorithms.chap26.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * Gene Aggregation by Average
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object GeneAggregationByAverage {
  //
  def main(args: Array[String]): Unit = {
    if (args.size < 5) {
      println("Usage: GeneAggregationByAverage <input-path> <sample-reference-type> <filter-type> <filter-value-threshold> <output-path>")
      // <sample-reference-type> can be one of the following:
      //      "r1" = normal sample
      //      "r2" = disease sample
      //      "r3" = paired sample
      //      "r4" = unknown
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("GeneAggregationByAverage")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val referenceType = args(1)   // {"r1", "r2", "r3", "r4"}
    val filterType = args(2)      // {"up", "down", "abs"}
    val filterValueThreshold = args(3).toDouble
    val output = args(4)

    val broadcastReferenceType = sc.broadcast(referenceType)
    val broadcastFilterType = sc.broadcast(filterType)
    val broadcastFilterValueThreshold = sc.broadcast(filterValueThreshold)

    val records = sc.textFile(input)

    val genes = records.flatMap(record => {
      val tokens = record.split(";")
      val geneIDAndReferenceType = tokens(0)
      val referenceType = geneIDAndReferenceType.split(",")(1)
      val patientIDAndGeneValue = tokens(1)
      if (referenceType == broadcastReferenceType.value) ((geneIDAndReferenceType, patientIDAndGeneValue) :: Nil) else Nil
    })

    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    val genesByID = genes.groupByKey()

    val frequency = genesByID.mapValues(itr => {
      val patients = itr.map(str => {
        val tokens = str.split(",")
        (tokens(0), tokens(1).toDouble)
      }).groupBy(_._1).mapValues(itr => {
        val geneValues = itr.map(_._2)
        (geneValues.sum / geneValues.size)
      })
      val averages = patients.values
      broadcastFilterType.value match {
        case "up"   => averages.filter(_ >= broadcastFilterValueThreshold.value).size
        case "down" => averages.filter(_ <= broadcastFilterValueThreshold.value).size
        case "abs"  => averages.filter(math.abs(_) >= broadcastFilterValueThreshold.value).size
        case _      => 0
      }
    })

    // For debugging
    frequency.foreach(println)

    frequency.saveAsTextFile(output)

    // done
    sc.stop()
  }
}package org.dataalgorithms.chap26.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * Gene Aggregation by Individual
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object GeneAggregationByIndividual {
  //
  def main(args: Array[String]): Unit = {
    if (args.size < 5) {
      println("Usage: GeneAggregationByIndividual <input-path> <sample-reference-type> <filter-type> <filter-value-threshold> <output-path>")
      // <sample-reference-type> can be one of the following:
      //      "r1" = normal sample
      //      "r2" = disease sample
      //      "r3" = paired sample
      //      "r4" = unknown
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("GeneAggregationByIndividual")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val referenceType = args(1) // {"r1", "r2", "r3", "r4"}
    val filterType = args(2)    // {"up", "down", "abs"}
    val filterValueThreshold = args(3).toDouble
    val output = args(4)

    val broadcastReferenceType = sc.broadcast(referenceType)
    val broadcastFilterType = sc.broadcast(filterType)
    val broadcastFilterValueThreshold = sc.broadcast(filterValueThreshold)

    def checkFilter(value: Double, filterType: String, filterValueThreshold: Double): Boolean = {
      filterType match {
        case "abs" if (math.abs(value) >= filterValueThreshold) => true
        case "up" if (value >= filterValueThreshold) => true
        case "down" if (value <= filterValueThreshold) => true
        case _ => false
      }
    }

    val records = sc.textFile(input)

    val genes = records.flatMap(record => {
      val tokens = record.split(";")
      val geneIDAndReferenceType = tokens(0)
      val gr = geneIDAndReferenceType.split(",")
      val geneID = gr(0)
      val referenceType = gr(1)
      val patientIDAndGeneValue = tokens(1)
      val pg = patientIDAndGeneValue.split(",")
      val patientID = pg(0)
      val geneValue = pg(1)
      if (referenceType == broadcastReferenceType.value && checkFilter(geneValue.toDouble, broadcastFilterType.value, broadcastFilterValueThreshold.value)) ((geneIDAndReferenceType, 1) :: Nil) else Nil
    })

    val counts = genes.reduceByKey(_ + _)

    // For debugging
    counts.foreach(println)

    counts.saveAsTextFile(output)

    // done
    sc.stop()
  }
}package org.dataalgorithms.chap17.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  *
  * Kmer counting for a given K and N.
  * K: to find K-mers
  * N: to find top-N
  *
  * A kmer or k-mer is a short DNA sequence consisting of a fixed
  * number (K) of bases. The value of k is usually divisible by 4
  * so that a kmer can fit compactly into a basevector object.
  * Typical values include 12, 20, 24, 36, and 48; kmers of these
  * sizes are referred to as 12-mers, 20-mers, and so forth.
  *
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object Kmer {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 3) {
      println("Usage: Kmer <input-path-as-a-FASTQ-file(s)> <K> <N>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("Kmer")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val K = args(1).toInt
    val N = args(2).toInt

    val broadcastK = sc.broadcast(K)
    val broadcastN = sc.broadcast(N)

    val records = sc.textFile(input)

    // remove the records, which are not an actual sequence data
    val filteredRDD = records.filter(line => {
      !(
        line.startsWith("@") ||
          line.startsWith("+") ||
          line.startsWith(";") ||
          line.startsWith("!") ||
          line.startsWith("~")
        )
    })

    val kmers = filteredRDD.flatMap(_.sliding(broadcastK.value, 1).map((_, 1)))

    // find frequencies of kmers
    val kmersGrouped = kmers.reduceByKey(_ + _)

    val partitions = kmersGrouped.mapPartitions(_.toList.sortBy(_._2).takeRight(broadcastN.value).toIterator)

    val allTopN = partitions.sortBy(_._2, false, 1).take(broadcastN.value)

    // print out top-N kmers
    allTopN.foreach(println)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap13.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * kNN algorithm in scala/spark.
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object kNN {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 5) {
      println("Usage: kNN <k-knn> <d-dimension> <R-input-dir> <S-input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("kNN")
    val sc = new SparkContext(sparkConf)

    val k = args(0).toInt
    val d = args(1).toInt
    val inputDatasetR = args(2)
    val inputDatasetS = args(3)
    val output = args(4)

    val broadcastK = sc.broadcast(k);
    val broadcastD = sc.broadcast(d)

    val R = sc.textFile(inputDatasetR)
    val S = sc.textFile(inputDatasetS)

    /**
      * Calculate the distance between 2 points
      *
      * @param rAsString as r1,r2, ..., rd
      * @param sAsString as s1,s2, ..., sd
      * @param d as dimention
      */
    def calculateDistance(rAsString: String, sAsString: String, d: Int): Double = {
      val r = rAsString.split(",").map(_.toDouble)
      val s = sAsString.split(",").map(_.toDouble)
      if (r.length != d || s.length != d) Double.NaN else {
        math.sqrt((r, s).zipped.take(d).map { case (ri, si) => math.pow((ri - si), 2) }.reduce(_ + _))
      }
    }

    val cart = R cartesian S

    val knnMapped = cart.map(cartRecord => {
      val rRecord = cartRecord._1
      val sRecord = cartRecord._2
      val rTokens = rRecord.split(";")
      val rRecordID = rTokens(0)
      val r = rTokens(1) // r.1, r.2, ..., r.d
      val sTokens = sRecord.split(";")
      val sClassificationID = sTokens(1)
      val s = sTokens(2) // s.1, s.2, ..., s.d
      val distance = calculateDistance(r, s, broadcastD.value)
      (rRecordID, (distance, sClassificationID))
    })

    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    val knnGrouped = knnMapped.groupByKey()

    val knnOutput = knnGrouped.mapValues(itr => {
      val nearestK = itr.toList.sortBy(_._1).take(broadcastK.value)
      val majority = nearestK.map(f => (f._2, 1)).groupBy(_._1).mapValues(list => {
        val (stringList, intlist) = list.unzip
        intlist.sum
      })
      majority.maxBy(_._2)._1
    })

    // for debugging purpose
    knnOutput.foreach(println)

    // save output
    knnOutput.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap04.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Demonstrates how to do "left outer join" on two RDD
  * without using Spark's inbuilt feature 'leftOuterJoin'.
  *
  * The main purpose here is to show the comparison with Hadoop
  * MapReduce shown earlier in the book and is only for demonstration purpose.
  * For your project we suggest to use Spark's built-in feature
  * 'leftOuterJoin' or use DataFrame (highly recommended).
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  * *
  */
object LeftOuterJoin {

  def main(args: Array[String]): Unit = {
    if (args.size < 3) {
      println("Usage: LeftOuterJoin <users-data-path> <transactions-data-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("LeftOuterJoin")
    val sc = new SparkContext(sparkConf)

    val usersInputFile = args(0)
    val transactionsInputFile = args(1)
    val output = args(2)

    val usersRaw = sc.textFile(usersInputFile)
    val transactionsRaw = sc.textFile(transactionsInputFile)

    val users = usersRaw.map(line => {
      val tokens = line.split("\t")
      (tokens(0), ("L", tokens(1))) // Tagging Locations with L
    })

    val transactions = transactionsRaw.map(line => {
      val tokens = line.split("\t")
      (tokens(2), ("P", tokens(1))) // Tagging Products with P
    })

    // This operation is expensive and is listed to compare with Hadoop
    // MapReduce approach, please compare it with more optimized approach
    // shown in SparkLeftOuterJoin.scala or DataFramLeftOuterJoin.scala
    val all = users union transactions

    val grouped = all.groupByKey()

    val productLocations = grouped.flatMap {
      case (userId, iterable) =>
        // span returns two Iterable, one containing Location and other containing Products
        val (location, products) = iterable span (_._1 == "L")
        val loc = location.headOption.getOrElse(("L", "UNKNOWN"))
        products.filter(_._1 == "P").map(p => (p._2, loc._2)).toSet
    }
    //
    val productByLocations = productLocations.groupByKey()

    val result = productByLocations.map(t => (t._1, t._2.size)) // Return (product, location count) tuple

    result.saveAsTextFile(output) // Saves output to the file.

    // done
    sc.stop()
  }
}
package org.dataalgorithms.chap11.scala

import java.text.SimpleDateFormat
//
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Markov algorithm
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object Markov {
  //
  def main(args: Array[String]): Unit = {

    if (args.size < 2) {
      println("Usage: Markov <input-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("Markov")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val transactions = sc.textFile(input)

    val dateFormat = new SimpleDateFormat("yyyy-MM-dd")
    val customers = transactions.map(line => {
      val tokens = line.split(",")
      (tokens(0), (dateFormat.parse(tokens(2)).getTime.toLong, tokens(3).toDouble)) // transaction-id i.e. tokens(1) ignored
    })

    //
    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    //
    val coustomerGrouped = customers.groupByKey()

    val sortedByDate = coustomerGrouped.mapValues(_.toList.sortBy(_._1))

    val stateSequence = sortedByDate.mapValues(list => {
      val sequence = for {
        i <- 0 until list.size - 1
        (currentDate, currentPurchase) = list(i)
        (nextDate, nextPurchse) = list(i + 1)
      } yield {
        val elapsedTime = (nextDate - currentDate) / 86400000 match {
          case diff if (diff < 30) => "S" //small
          case diff if (diff < 60) => "M" // medium
          case _                   => "L" // large
        }
        val amountRange = (currentPurchase / nextPurchse) match {
          case ratio if (ratio < 0.9) => "L" // significantly less than
          case ratio if (ratio < 1.1) => "E" // more or less same
          case _                      => "G" // significantly greater than
        }
        elapsedTime + amountRange
      }
      sequence
    })


    val model = stateSequence.filter(_._2.size >= 2).flatMap(f => {
      val states = f._2

      val statePair = for {
        i <- 0 until states.size - 1
        fromState = states(i)
        toState = states(i + 1)
      } yield {
        ((fromState, toState), 1)
      }
      statePair
    })

    // build Markov model
    val markovModel = model.reduceByKey(_ + _)

    val markovModelFormatted = markovModel.map(f => f._1._1 + "," + f._1._2 + "\t" + f._2)
    markovModelFormatted.foreach(println)

    markovModelFormatted.saveAsTextFile(output)

    // done!
    sc.stop()

  }
}package org.dataalgorithms.chap28.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Finding averge using monoid (implement using Spark's combineByKey())
  *
  * A monoid is a triple (T, ∗, z) such that ∗ is an associative
  * binary operation on T, and z ∈ T has the property that for
  * all x ∈ T it holds that x∗z = z∗x = x.
  *
  *
  * To find means of numbers, convert each number into (number, 1),
  * then add them preserving a monoid structure:
  *
  * The monoid structure is defined as (sum, count)
  *
  * number1 -> (number1, 1)
  * number2 -> (number2, 1)
  * (number1, 1) + (number2, 1) -> (number1+number2, 1+1) = (number1+number2, 2)
  * (number1, x) + (number2, y) ->  (number1+number2, x+y)
  *
  * Finally, per key, we will have a value as (sum, count), then to find the mean,
  * mean = sum / count
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object MeanMonoidizedUsingCombineByKey {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: MeanMonoidizedUsingCombineByKey <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("MeanMonoidizedUsingCombineByKey")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val records = sc.textFile(input)

    // create a monoid structure
    val monoid = records.map(line => {
      val tokens = line.split("\\s+")
      (tokens(0), tokens(1).toInt)
    })

    // combineBykey() requires 3 basic functions:
    val createCombiner = (num: Int) => (num, 1)
    val mergeValue = (c: (Int, Int), num: Int) => (c._1 + num, c._2 + 1)
    val mergeCombiners = (a: (Int, Int), b: (Int, Int)) => (a._1 + b._1, a._2 + b._2)

    val combined = monoid.combineByKey(createCombiner, mergeValue, mergeCombiners)

    val result = combined.mapValues(f => f._1.toDouble / f._2)

    // For debugging
    result.foreach(println)

    result.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap28.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Finding averge using monoid (implement using Spark's reduceByKey())
  *
  * A monoid is a triple (T, ∗, z) such that ∗ is an associative
  * binary operation on T, and z ∈ T has the property that for
  * all x ∈ T it holds that x∗z = z∗x = x.
  *
  *
  * To find means of numbers, convert each number into (number, 1),
  * then add them preserving a monoid structure:
  *
  * The monoid structure is defined as (sum, count)
  *
  * number1 -> (number1, 1)
  * number2 -> (number2, 1)
  * (number1, 1) + (number2, 1) -> (number1+number2, 1+1) = (number1+number2, 2)
  * (number1, x) + (number2, y) ->  (number1+number2, x+y)
  *
  * Finally, per key, we will have a value as (sum, count), then to find the mean,
  * mean = sum / count
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object MeanMonoidizedUsingReduceByKey {
  //
  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: MeanMonoidizedUsingReduceByKey <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("MeanMonoidizedUsingReduceByKey")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val records = sc.textFile(input)

    // create a monoid structure
    val monoid = records.map(line => {
      val tokens = line.split("\\s+")
      (tokens(0), (tokens(1).toInt, 1))
    })

    val reduced = monoid.reduceByKey { case (a, b) => (a._1 + b._1, a._2 + b._2) }
    val result = reduced.mapValues(f => f._1.toDouble / f._2)

    // For debugging
    result.foreach(println)

    result.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap10.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * MovieRecommendations: very basic movie recommnedation...
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object MovieRecommendations {

  def main(args: Array[String]): Unit = {
    //
    if (args.size < 2) {
      println("Usage: MovieRecommendations <input-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("MovieRecommendations")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val usersRatings = sc.textFile(input)

    val userMovieRating = usersRatings.map(line => {
      val tokens = line.split("\\s+")
      (tokens(0), tokens(1), tokens(2).toInt)
    })

    val numberOfRatersPerMovie = userMovieRating.map(umr => (umr._2, 1)).reduceByKey(_ + _)

    val userMovieRatingNumberOfRater = userMovieRating.map(umr => (umr._2, (umr._1, umr._3))).join(numberOfRatersPerMovie)
      .map(tuple => (tuple._2._1._1, tuple._1, tuple._2._1._2, tuple._2._2))

    val groupedByUser = userMovieRatingNumberOfRater.map(f => (f._1, (f._2, f._3, f._4))).groupByKey()

    val moviePairs = groupedByUser.flatMap(tuple => {
      val sorted = tuple._2.toList.sortBy(f => f._1) //sorted by movies
      val tuple7 = for {
        movie1 <- sorted
        movie2 <- sorted
        if (movie1._1 < movie2._1); // avoid duplicate
        ratingProduct = movie1._2 * movie2._2
        rating1Squared = movie1._2 * movie1._2
        rating2Squared = movie2._2 * movie2._2
      } yield {
        ((movie1._1, movie2._1), (movie1._2, movie1._3, movie2._2, movie2._3, ratingProduct, rating1Squared, rating2Squared))
      }
      tuple7
    })

    //
    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    //
    val moviePairsGrouped = moviePairs.groupByKey()

    val result = moviePairsGrouped.mapValues(itr => {
      val groupSize = itr.size // length of each vector
      val (rating1, numOfRaters1, rating2, numOfRaters2, ratingProduct, rating1Squared, rating2Squared) =
        itr.foldRight((List[Int](), List[Int](), List[Int](), List[Int](), List[Int](), List[Int](), List[Int]()))((a, b) =>
          (
            a._1 :: b._1,
            a._2 :: b._2,
            a._3 :: b._3,
            a._4 :: b._4,
            a._5 :: b._5,
            a._6 :: b._6,
            a._7 :: b._7))
      val dotProduct = ratingProduct.sum // sum of ratingProd
      val rating1Sum = rating1.sum // sum of rating1
      val rating2Sum = rating2.sum // sum of rating2
      val rating1NormSq = rating1Squared.sum // sum of rating1Squared
      val rating2NormSq = rating2Squared.sum // sum of rating2Squared
      val maxNumOfumRaters1 = numOfRaters1.max // max of numOfRaters1
      val maxNumOfumRaters2 = numOfRaters2.max // max of numOfRaters2

      val numerator = groupSize * dotProduct - rating1Sum * rating2Sum
      val denominator = math.sqrt(groupSize * rating1NormSq - rating1Sum * rating1Sum) *
        math.sqrt(groupSize * rating2NormSq - rating2Sum * rating2Sum)
      val pearsonCorrelation = numerator / denominator

      val cosineCorrelation = dotProduct / (math.sqrt(rating1NormSq) * math.sqrt(rating2NormSq))

      val jaccardCorrelation = groupSize.toDouble / (maxNumOfumRaters1 + maxNumOfumRaters2 - groupSize)

      (pearsonCorrelation, cosineCorrelation, jaccardCorrelation)
    })


    // for debugging purposes...
    result.foreach(println)

    result.saveAsTextFile(output)

    // done
    sc.stop()
  }
}package org.dataalgorithms.chap06.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/*
 * Moving Average in Scala sses "secondary sorting" via
 * repartitionAndSortWithinPartitions()
 *
 * One question on using scala.collection.mutable.Queue data structure
 * for the moving average solution: will this scale out? The answer is
 * yes, since the queue size is almost fixed and will not grow beyond
 * the “window” size, it will scale out: if even we use thousands or
 * 10’s of thousands of it.  If at the reducer level we use unbounded
 * data structures, then we are looking for OOM error: in our case,
 * it is well guarded by the window size.
 *
 *
 * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
 *
 * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
 *
 */
object MovingAverage {

  def main(args: Array[String]): Unit = {
    if (args.size < 4) {
      println("Usage: MemoryMovingAverage <window> <number-of-partitions> <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("MovingAverage")
    val sc = new SparkContext(sparkConf)

    val window = args(0).toInt
    val numPartitions = args(1).toInt // number of partitions in secondary sorting, choose a high value
    val input = args(2)
    val output = args(3)

    val brodcastWindow = sc.broadcast(window)

    val rawData = sc.textFile(input)

    // Key contains part of value (closing date in this case)
    val valueTokey = rawData.map(line => {
      val tokens = line.split(",")
      val dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd")
      val timestamp = dateFormat.parse(tokens(1)).getTime
      (CompositeKey(tokens(0), timestamp), TimeSeriesData(timestamp, tokens(2).toDouble))
    })

    // Secondary sorting
    val sortedData = valueTokey.repartitionAndSortWithinPartitions(new CompositeKeyPartitioner(numPartitions))

    val keyValue = sortedData.map(k => (k._1.stockSymbol, (k._2)))
    val groupByStockSymbol = keyValue.groupByKey()

    val movingAverage = groupByStockSymbol.mapValues(values => {
      val dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd")
      val queue = new scala.collection.mutable.Queue[Double]()
      for (TimeSeriesData <- values) yield {
        queue.enqueue(TimeSeriesData.closingStockPrice)
        if (queue.size > brodcastWindow.value)
          queue.dequeue

        (dateFormat.format(new java.util.Date(TimeSeriesData.timeStamp)), (queue.sum / queue.size))
      }
    })

    // output will be in CSV format
    // <stock_symbol><,><date><,><moving_average>
    val formattedResult = movingAverage.flatMap(kv => {
      kv._2.map(v => (kv._1 + "," + v._1 + "," + v._2.toString()))
    })
    formattedResult.saveAsTextFile(output)

    // done
    sc.stop()
  }

}

// Case class comes handy
case class CompositeKey(stockSymbol: String, timeStamp: Long)
case class TimeSeriesData(timeStamp: Long, closingStockPrice: Double)

// Defines ordering
object CompositeKey {
  implicit def ordering[A <: CompositeKey]: Ordering[A] = {
    Ordering.by(fk => (fk.stockSymbol, fk.timeStamp))
  }
}


//---------------------------------------------------------
// the following class defines a custom partitioner by
// extending abstract class org.apache.spark.Partitioner
//---------------------------------------------------------
import org.apache.spark.Partitioner

class CompositeKeyPartitioner(partitions: Int) extends Partitioner {
  require(partitions >= 0, s"Number of partitions ($partitions) cannot be negative.")

  def numPartitions: Int = partitions

  def getPartition(key: Any): Int = key match {
    case k: CompositeKey => math.abs(k.stockSymbol.hashCode % numPartitions)
    case null            => 0
    case _               => math.abs(key.hashCode % numPartitions)
  }

  override def equals(other: Any): Boolean = other match {
    case h: CompositeKeyPartitioner => h.numPartitions == numPartitions
    case _                          => false
  }

  override def hashCode: Int = numPartitions
}
package org.dataalgorithms.chap06.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Moving Avergae in Scala using Sort In Memory
  *
  * This example is analogous of to the SortInMemory_MovingAverageDriver
  * (https://github.com/mahmoudparsian/data-algorithms-book/blob/master/src/main/java/org/dataalgorithms/chap06/memorysort/SortInMemory_MovingAverageDriver.java)
  *
  * Please note that this soultion will not scale with large data
  * (if you cluster nodes have a limited amout of memory/RAM for
  * sorting).  For large datasets use MovingAverage.scala which
  * uses secondary sorting via repartitionAndSortWithinPartitions().
  *
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object MovingAverageInMemory {

  def main(args: Array[String]): Unit = {
    if (args.size < 3) {
      println("Usage: MovingAverageInMemory <window> <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("MovingAverageInMemory")
    val sc = new SparkContext(sparkConf)

    val window = args(0).toInt
    val input = args(1)
    val output = args(2)

    val brodcastWindow = sc.broadcast(window)

    val rawData = sc.textFile(input)
    val keyValue = rawData.map(line => {
      val tokens = line.split(",")
      (tokens(0), (tokens(1), tokens(2).toDouble))
    })

    // Key being stock symbol like IBM, GOOG, AAPL, etc
    val groupByStockSymbol = keyValue.groupByKey()

    val result = groupByStockSymbol.mapValues(values => {
      val dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd")
      // in-memory sorting, will not scale with large datasets
      val sortedValues = values.map(s => (dateFormat.parse(s._1).getTime.toLong, s._2)).toSeq.sortBy(_._1)
      val queue = new scala.collection.mutable.Queue[Double]()
      for (tup <- sortedValues) yield {
        queue.enqueue(tup._2)
        if (queue.size > brodcastWindow.value)
          queue.dequeue

        (dateFormat.format(new java.util.Date(tup._1)), (queue.sum / queue.size))
      }
    })

    // output will be in CSV format
    // <stock_symbol><,><date><,><moving_average>
    val formattedResult = result.flatMap(kv => {
      kv._2.map(v => (kv._1 + "," + v._1 + "," + v._2.toString()))
    })
    formattedResult.saveAsTextFile(output)

    //done
    sc.stop()
  }
}
package org.dataalgorithms.chap14.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * Use a Naive Bayes Classifier (built by NaiveBayesClassifierBuilder)
  * to classify new data
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object NaiveBayesClassifier {

  def main(args: Array[String]): Unit = {
    //
    if (args.size < 4) {
      println("Usage: NaiveBayesClassifier <input-query-data> <input-pt> <input-classes> <output-path>")
      // <input-query-data> is a new data that we want to classify by using/applying the built Naive Bayes Classifier
      // <input-pt> is a probability table built by the NaiveBayesClassifierBuilder class
      // <input-classes> are the classes built by the NaiveBayesClassifierBuilder class
      // <output-path> is the output of new data classified by the built Naive Bayes Classifier
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("NaiveBayesClassifier")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val nbProbabilityTablePath = args(1)
    val classesPath = args(2)
    val output = args(3)

    val newdata = sc.textFile(input)
    val classifierRDD = sc.objectFile[Tuple2[Tuple2[String, String], Double]](nbProbabilityTablePath)

    val classifier = classifierRDD.collectAsMap()
    val broadcastClassifier = sc.broadcast(classifier)
    val classesRDD = sc.textFile(classesPath)
    val broadcastClasses = sc.broadcast(classesRDD.collect())

    val classified = newdata.map(rec => {
      val classifier = broadcastClassifier.value
      val classes = broadcastClasses.value
      val attributes = rec.split(",")

      val class_score = classes.map(aClass => {
        val posterior = classifier.getOrElse(("CLASS", aClass), 1d)
        val probabilities = attributes.map(attribute => {
          classifier.getOrElse((attribute, aClass), 0d)
        })
        (aClass, probabilities.product * posterior)
      })
      val maxClass = class_score.maxBy(_._2)
      (rec, maxClass._1)
    })

    // For debugging purpose
    classified.foreach(println)

    // saved the classified data
    classified.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}package org.dataalgorithms.chap14.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * NaiveBayesClassifierBuilder builds a Naive Bayes
  * Classifier. Two outputs are generated by this class:
  *
  *   1. Probability Table
  *   2. Classes used in classification
  *
  * These above generated outputs are used (in BayesClassifierBuilder)
  * to classify new data.
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object NaiveBayesClassifierBuilder {
  //
  def main(args: Array[String]): Unit = {
    if (args.size < 2) {
      println("Usage: NaiveBayesClassifierBuilder <input-training-data-path> <output-path>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("NaiveBayesClassifierBuilder")
    val sc = new SparkContext(sparkConf)

    val input = args(0)
    val output = args(1)

    val training = sc.textFile(input)
    val trainingDataSize = training count

    val pairs = training.flatMap(line => {
      val tokens = line.split(",")
      val theClassification = tokens.last
      (("CLASS", theClassification), 1) :: tokens.init.map(token => ((token, theClassification), 1)).toList
    })

    val counts = pairs reduceByKey (_ + _)

    val countsAsMap = counts collectAsMap
    val pt = countsAsMap.map(tuple => {
      if (tuple._1._1 == "CLASS") (tuple._1, (tuple._2 / trainingDataSize.toDouble)) else {
        val count = countsAsMap.getOrElse(("CLASS", tuple._1._2), 0)
        if (count == 0) (tuple._1, 0d) else (tuple._1, (tuple._2 / count.toDouble))
      }
    })
    val ptRDD = sc.parallelize(pt.toList)

    // For debugging purpose
    pt.foreach(f => println(s"${f._1._1},${f._1._2},${f._2}"))

    // save the probability table
    ptRDD.saveAsObjectFile(output + "/naivebayes/pt")

    val classifications = pairs.filter(_._1._1 == "CLASS").map(_._1._2).distinct

    // For debugging purpose
    classifications.foreach(println)

    // save the classified data (classes used in classification)
    classifications.saveAsTextFile(output + "/naivebayes/classes")

    // done!
    sc.stop()
  }
}/*                     __                                               *\
**     ________ ___   / /  ___     Scala API                            **
**    / __/ __// _ | / /  / _ |    (c) 2002-2011, LAMP/EPFL             **
**  __\ \/ /__/ __ |/ /__/ __ |    http://scala-lang.org/               **
** /____/\___/_/ |_/____/_/ | |                                         **
**                          |/                                          **
\*                                                                      */

package scala.annotation

/**
  * An annotation that designates the class to which it is applied as serializable
  */
@deprecated("instead of `@serializable class C`, use `class C extends Serializable`", "2.9.0")
class serializable extends annotation.StaticAnnotation
package org.dataalgorithms.chap04.scala

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/**
  * This approach uses 'leftOuterJoin' function available on PairRDD.
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */

object SparkLeftOuterJoin {

  def main(args: Array[String]): Unit = {
    if (args.size < 3) {
      println("Usage: SparkLeftOuterJoin <users> <transactions> <output>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("SparkLeftOuterJoin")
    val sc = new SparkContext(sparkConf)

    val usersInputFile = args(0)
    val transactionsInputFile = args(1)
    val output = args(2)

    val usersRaw = sc.textFile(usersInputFile)
    val transactionsRaw = sc.textFile(transactionsInputFile)

    val users = usersRaw.map(line => {
      val tokens = line.split("\t")
      (tokens(0), tokens(1))
    })

    val transactions = transactionsRaw.map(line => {
      val tokens = line.split("\t")
      (tokens(2), tokens(1))
    })

    val joined =  transactions leftOuterJoin users
    // getOrElse is a method availbale on Option which either returns value
    // (if present) or returns passed value (unknown in this case).
    val productLocations = joined.values.map(f => (f._1, f._2.getOrElse("unknown")))

    val productByLocations = productLocations.groupByKey()

    val productWithUniqueLocations = productByLocations.mapValues(_.toSet) // Converting toSet removes duplicates.

    val result = productWithUniqueLocations.map(t => (t._1, t._2.size)) // Return (product, location count) tuple.

    result.saveAsTextFile(output) // Saves output to the file.

    // done
    sc.stop()
  }
}
package org.dataalgorithms.chap05.scala

import org.apache.spark.SparkConf
import org.apache.spark.sql.types.IntegerType
import org.apache.spark.sql.types.StringType
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types.StructType
import org.apache.spark.sql.types.StructField
import org.apache.spark.sql.Row

/**
  * This solution implements Relative Frequency design pattern using Spark SQL.
  *
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object SparkSQLRelativeFrequency {

  def main(args: Array[String]): Unit = {

    if (args.size < 3) {
      println("Usage: SparkSQLRelativeFrequency <neighbor-window> <input-dir> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("SparkSQLRelativeFrequency")

    val spark = SparkSession
      .builder()
      .config(sparkConf)
      .getOrCreate()
    val sc = spark.sparkContext

    val neighborWindow = args(0).toInt
    val input = args(1)
    val output = args(2)

    val brodcastWindow = sc.broadcast(neighborWindow)

    val rawData = sc.textFile(input)

    /*
    * Schema
    * (word, neighbour, frequency)
    */
    val rfSchema = StructType(Seq(
      StructField("word", StringType, false),
      StructField("neighbour", StringType, false),
      StructField("frequency", IntegerType, false)))

    /*
     * Transform the input to the format:
     * Row(word, neighbour, 1)
     */
    val rowRDD = rawData.flatMap(line => {
      val tokens = line.split("\\s")
      for {
        i <- 0 until tokens.length
        start = if (i - brodcastWindow.value < 0) 0 else i - brodcastWindow.value
        end = if (i + brodcastWindow.value >= tokens.length) tokens.length - 1 else i + brodcastWindow.value
        j <- start to end if (j != i)
      } yield Row(tokens(i), tokens(j), 1)
    })

    val rfDataFrame = spark.createDataFrame(rowRDD, rfSchema)
    rfDataFrame.createOrReplaceTempView("rfTable")

    import spark.sql

    val query = "SELECT a.word, a.neighbour, (a.feq_total/b.total) rf " +
      "FROM (SELECT word, neighbour, SUM(frequency) feq_total FROM rfTable GROUP BY word, neighbour) a " +
      "INNER JOIN (SELECT word, SUM(frequency) as total FROM rfTable GROUP BY word) b ON a.word = b.word"

    val sqlResult = sql(query)
    sqlResult.show() // print first 20 records on the console
    sqlResult.write.save(output + "/parquetFormat") // saves output in compressed Parquet format, recommended for large projects.
    sqlResult.rdd.saveAsTextFile(output + "/textFormat") // to see output via cat command

    // done
    spark.stop()

  }
}
package org.dataalgorithms.chap22.scala

import scala.io.Source;
//
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
//
import org.apache.commons.math.stat.inference.TTestImpl;

/**
  *
  * Ttest using Apache's TTestImpl
  *
  * A Ttest is an analysis of two populations means through the
  * use of statistical examination; a t-test with two samples is
  * commonly used, testing the difference between the samples when
  * the variances of two normal distributions are not known.
  *
  *
  * @author Gaurav Bhardwaj (gauravbhardwajemail@gmail.com)
  *
  * @editor Mahmoud Parsian (mahmoud.parsian@yahoo.com)
  *
  */
object Ttest {

  def main(args: Array[String]): Unit = {
    //
    if (args.size < 3) {
      println("Usage: Ttest <input-timetable> <input-dir-bioset> <output-dir>")
      sys.exit(1)
    }

    val sparkConf = new SparkConf().setAppName("Ttest")
    val sc = new SparkContext(sparkConf)

    val inputTimeTable = args(0)
    val inputBioset = args(1)
    val output = args(2)

    // Use this if inputTimeTable is the full path of the file
    // (including filename) on local file system
    val timeTableFile = Source.fromFile(inputTimeTable).getLines
    val timeTable = timeTableFile.map(line => {
      val tokens = line.split("\\s+")
      (tokens(0), tokens(1).toDouble)
    }).toMap

    // ----------------------------------------------------
    // NOTE: Use this if inputTimeTable is the directory
    // on distributed file system (like HDFS)
    // ----------------------------------------------------
    /*
    val timeTableRDD = sc.textFile(inputTimeTable)
    val timeTable = timeTableRDD.map(line => {
      val tokens = line.split("\\s+")
      (tokens(0), tokens(1).toDouble)
    }).collect().toMap
    */

    val broadcastTimeTable = sc.broadcast(timeTable)

    val biosets = sc.textFile(inputBioset)
    val pairs = biosets.map(line => {
      val tokens = line.split(",")
      (tokens(0), tokens(1))
    })

    // note that groupByKey() provides an expensive solution
    // [you must have enough memory/RAM to hold all values for
    // a given key -- otherwise you might get OOM error], but
    // combineByKey() and reduceByKey() will give a better
    // scale-out performance
    val grouped = pairs.groupByKey()

    def ttestCalculator(groupA: Array[Double], groupB: Array[Double]): Double = {
      val ttest = new TTestImpl()
      if (groupA.isEmpty || groupB.isEmpty)
        0d
      else if ((groupA.length == 1) && (groupB.length == 1))
        Double.NaN
      else if (groupA.length == 1)
        ttest.tTest(groupA(0), groupB)
      else if (groupB.length == 1)
        ttest.tTest(groupB(0), groupA)
      else
        ttest.tTest(groupA, groupB)
    }

    val ttest = grouped.mapValues(itr => {
      val geneBiosets = itr.toSet
      val timetable = broadcastTimeTable.value
      val (exist, notexist) = timetable.partition(tuple => geneBiosets.contains(tuple._1))
      ttestCalculator(exist.values.toArray, notexist.values.toArray)
    })

    // For debugging purpose
    ttest.foreach(println)

    // Saving the output
    ttest.saveAsTextFile(output)

    // done!
    sc.stop()
  }
}


// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import org.apache.spark.sql.SparkSession

/**
 * Usage: SimpleSkewedGroupByTest [numMappers] [numKVPairs] [valSize] [numReducers] [ratio]
 */
object SimpleSkewedGroupByTest {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("SimpleSkewedGroupByTest")
      .getOrCreate()

    val numMappers = if (args.length > 0) args(0).toInt else 2
    val numKVPairs = if (args.length > 1) args(1).toInt else 1000
    val valSize = if (args.length > 2) args(2).toInt else 1000
    val numReducers = if (args.length > 3) args(3).toInt else numMappers
    val ratio = if (args.length > 4) args(4).toInt else 5.0

    val pairs1 = spark.sparkContext.parallelize(0 until numMappers, numMappers).flatMap { p =>
      val ranGen = new Random
      val result = new Array[(Int, Array[Byte])](numKVPairs)
      for (i <- 0 until numKVPairs) {
        val byteArr = new Array[Byte](valSize)
        ranGen.nextBytes(byteArr)
        val offset = ranGen.nextInt(1000) * numReducers
        if (ranGen.nextDouble < ratio / (numReducers + ratio - 1)) {
          // give ratio times higher chance of generating key 0 (for reducer 0)
          result(i) = (offset, byteArr)
        } else {
          // generate a key for one of the other reducers
          val key = 1 + ranGen.nextInt(numReducers-1) + offset
          result(i) = (key, byteArr)
        }
      }
      result
    }.cache
    // Enforce that everything has been calculated and in cache
    pairs1.count

    println(s"RESULT: ${pairs1.groupByKey(numReducers).count}")

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import scala.collection.mutable.HashMap
import scala.collection.mutable.HashSet

import breeze.linalg.{squaredDistance, DenseVector, Vector}

/**
 * K-means clustering.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.clustering.KMeans.
 */
object LocalKMeans {
  val N = 1000
  val R = 1000    // Scaling factor
  val D = 10
  val K = 10
  val convergeDist = 0.001
  val rand = new Random(42)

  def generateData: Array[DenseVector[Double]] = {
    def generatePoint(i: Int): DenseVector[Double] = {
      DenseVector.fill(D) {rand.nextDouble * R}
    }
    Array.tabulate(N)(generatePoint)
  }

  def closestPoint(p: Vector[Double], centers: HashMap[Int, Vector[Double]]): Int = {
    var bestIndex = 0
    var closest = Double.PositiveInfinity

    for (i <- 1 to centers.size) {
      val vCurr = centers(i)
      val tempDist = squaredDistance(p, vCurr)
      if (tempDist < closest) {
        closest = tempDist
        bestIndex = i
      }
    }

    bestIndex
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of KMeans Clustering and is given as an example!
        |Please use org.apache.spark.ml.clustering.KMeans
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    showWarning()

    val data = generateData
    val points = new HashSet[Vector[Double]]
    val kPoints = new HashMap[Int, Vector[Double]]
    var tempDist = 1.0

    while (points.size < K) {
      points.add(data(rand.nextInt(N)))
    }

    val iter = points.iterator
    for (i <- 1 to points.size) {
      kPoints.put(i, iter.next())
    }

    println(s"Initial centers: $kPoints")

    while(tempDist > convergeDist) {
      val closest = data.map (p => (closestPoint(p, kPoints), (p, 1)))

      val mappings = closest.groupBy[Int] (x => x._1)

      val pointStats = mappings.map { pair =>
        pair._2.reduceLeft [(Int, (Vector[Double], Int))] {
          case ((id1, (p1, c1)), (id2, (p2, c2))) => (id1, (p1 + p2, c1 + c2))
        }
      }

      var newPoints = pointStats.map {mapping =>
        (mapping._1, mapping._2._1 * (1.0 / mapping._2._2))}

      tempDist = 0.0
      for (mapping <- newPoints) {
        tempDist += squaredDistance(kPoints(mapping._1), mapping._2)
      }

      for (newP <- newPoints) {
        kPoints.put(newP._1, newP._2)
      }
    }

    println(s"Final centers: $kPoints")
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import breeze.linalg.{DenseVector, Vector}

/**
 * Logistic regression based classification.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.classification.LogisticRegression.
 */
object LocalLR {
  val N = 10000  // Number of data points
  val D = 10   // Number of dimensions
  val R = 0.7  // Scaling factor
  val ITERATIONS = 5
  val rand = new Random(42)

  case class DataPoint(x: Vector[Double], y: Double)

  def generateData: Array[DataPoint] = {
    def generatePoint(i: Int): DataPoint = {
      val y = if (i % 2 == 0) -1 else 1
      val x = DenseVector.fill(D) {rand.nextGaussian + y * R}
      DataPoint(x, y)
    }
    Array.tabulate(N)(generatePoint)
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of Logistic Regression and is given as an example!
        |Please use org.apache.spark.ml.classification.LogisticRegression
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    showWarning()

    val data = generateData
    // Initialize w to a random value
    val w = DenseVector.fill(D) {2 * rand.nextDouble - 1}
    println(s"Initial w: $w")

    for (i <- 1 to ITERATIONS) {
      println(s"On iteration $i")
      val gradient = DenseVector.zeros[Double](D)
      for (p <- data) {
        val scale = (1 / (1 + math.exp(-p.y * (w.dot(p.x)))) - 1) * p.y
        gradient +=  p.x * scale
      }
      w -= gradient
    }

    println(s"Final w: $w")
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.spark.metrics.source.{DoubleAccumulatorSource, LongAccumulatorSource}
import org.apache.spark.sql.SparkSession

/**
 * Usage: AccumulatorMetricsTest [numElem]
 *
 * This example shows how to register accumulators against the accumulator source.
 * A simple RDD is created, and during the map, the accumulators are incremented.
 *
 * The only argument, numElem, sets the number elements in the collection to parallize.
 *
 * The result is output to stdout in the driver with the values of the accumulators.
 * For the long accumulator, it should equal numElem the double accumulator should be
 * roughly 1.1 x numElem (within double precision.) This example also sets up a
 * ConsoleSink (metrics) instance, and so registered codahale metrics (like the
 * accumulator source) are reported to stdout as well.
 */
object AccumulatorMetricsTest {
  def main(args: Array[String]) {

    val spark = SparkSession
      .builder()
      .config("spark.metrics.conf.*.sink.console.class",
              "org.apache.spark.metrics.sink.ConsoleSink")
      .getOrCreate()

    val sc = spark.sparkContext

    val acc = sc.longAccumulator("my-long-metric")
    // register the accumulator, the metric system will report as
    // [spark.metrics.namespace].[execId|driver].AccumulatorSource.my-long-metric
    LongAccumulatorSource.register(sc, List(("my-long-metric" -> acc)).toMap)

    val acc2 = sc.doubleAccumulator("my-double-metric")
    // register the accumulator, the metric system will report as
    // [spark.metrics.namespace].[execId|driver].AccumulatorSource.my-double-metric
    DoubleAccumulatorSource.register(sc, List(("my-double-metric" -> acc2)).toMap)

    val num = if (args.length > 0) args(0).toInt else 1000000

    val startTime = System.nanoTime

    val accumulatorTest = sc.parallelize(1 to num).foreach(_ => {
      acc.add(1)
      acc2.add(1.1)
    })

    // Print a footer with test time and accumulator values
    println("Test took %.0f milliseconds".format((System.nanoTime - startTime) / 1E6))
    println("Accumulator values:")
    println("*** Long accumulator (my-long-metric): " + acc.value)
    println("*** Double accumulator (my-double-metric): " + acc2.value)

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples

import org.apache.spark.sql.SparkSession

object ExceptionHandlingTest {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("ExceptionHandlingTest")
      .getOrCreate()

    spark.sparkContext.parallelize(0 until spark.sparkContext.defaultParallelism).foreach { i =>
      if (math.random > 0.75) {
        throw new Exception("Testing exception handling")
      }
    }

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import scala.math.random

import org.apache.spark.sql.SparkSession

/** Computes an approximation to pi */
object SparkPi {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("Spark Pi")
      .getOrCreate()
    val slices = if (args.length > 0) args(0).toInt else 2
    val n = math.min(100000L * slices, Int.MaxValue).toInt // avoid overflow
    val count = spark.sparkContext.parallelize(1 until n, slices).map { i =>
      val x = random * 2 - 1
      val y = random * 2 - 1
      if (x*x + y*y <= 1) 1 else 0
    }.reduce(_ + _)
    println(s"Pi is roughly ${4.0 * count / (n - 1)}")
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.commons.math3.linear._

/**
 * Alternating least squares matrix factorization.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.recommendation.ALS.
 */
object LocalALS {

  // Parameters set through command line arguments
  var M = 0 // Number of movies
  var U = 0 // Number of users
  var F = 0 // Number of features
  var ITERATIONS = 0
  val LAMBDA = 0.01 // Regularization coefficient

  def generateR(): RealMatrix = {
    val mh = randomMatrix(M, F)
    val uh = randomMatrix(U, F)
    mh.multiply(uh.transpose())
  }

  def rmse(targetR: RealMatrix, ms: Array[RealVector], us: Array[RealVector]): Double = {
    val r = new Array2DRowRealMatrix(M, U)
    for (i <- 0 until M; j <- 0 until U) {
      r.setEntry(i, j, ms(i).dotProduct(us(j)))
    }
    val diffs = r.subtract(targetR)
    var sumSqs = 0.0
    for (i <- 0 until M; j <- 0 until U) {
      val diff = diffs.getEntry(i, j)
      sumSqs += diff * diff
    }
    math.sqrt(sumSqs / (M.toDouble * U.toDouble))
  }

  def updateMovie(i: Int, m: RealVector, us: Array[RealVector], R: RealMatrix) : RealVector = {
    var XtX: RealMatrix = new Array2DRowRealMatrix(F, F)
    var Xty: RealVector = new ArrayRealVector(F)
    // For each user that rated the movie
    for (j <- 0 until U) {
      val u = us(j)
      // Add u * u^t to XtX
      XtX = XtX.add(u.outerProduct(u))
      // Add u * rating to Xty
      Xty = Xty.add(u.mapMultiply(R.getEntry(i, j)))
    }
    // Add regularization coefficients to diagonal terms
    for (d <- 0 until F) {
      XtX.addToEntry(d, d, LAMBDA * U)
    }
    // Solve it with Cholesky
    new CholeskyDecomposition(XtX).getSolver.solve(Xty)
  }

  def updateUser(j: Int, u: RealVector, ms: Array[RealVector], R: RealMatrix) : RealVector = {
    var XtX: RealMatrix = new Array2DRowRealMatrix(F, F)
    var Xty: RealVector = new ArrayRealVector(F)
    // For each movie that the user rated
    for (i <- 0 until M) {
      val m = ms(i)
      // Add m * m^t to XtX
      XtX = XtX.add(m.outerProduct(m))
      // Add m * rating to Xty
      Xty = Xty.add(m.mapMultiply(R.getEntry(i, j)))
    }
    // Add regularization coefficients to diagonal terms
    for (d <- 0 until F) {
      XtX.addToEntry(d, d, LAMBDA * M)
    }
    // Solve it with Cholesky
    new CholeskyDecomposition(XtX).getSolver.solve(Xty)
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of ALS and is given as an example!
        |Please use org.apache.spark.ml.recommendation.ALS
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    args match {
      case Array(m, u, f, iters) =>
        M = m.toInt
        U = u.toInt
        F = f.toInt
        ITERATIONS = iters.toInt
      case _ =>
        System.err.println("Usage: LocalALS <M> <U> <F> <iters>")
        System.exit(1)
    }

    showWarning()

    println(s"Running with M=$M, U=$U, F=$F, iters=$ITERATIONS")

    val R = generateR()

    // Initialize m and u randomly
    var ms = Array.fill(M)(randomVector(F))
    var us = Array.fill(U)(randomVector(F))

    // Iteratively update movies then users
    for (iter <- 1 to ITERATIONS) {
      println(s"Iteration $iter:")
      ms = (0 until M).map(i => updateMovie(i, ms(i), us, R)).toArray
      us = (0 until U).map(j => updateUser(j, us(j), ms, R)).toArray
      println(s"RMSE = ${rmse(R, ms, us)}")
    }
  }

  private def randomVector(n: Int): RealVector =
    new ArrayRealVector(Array.fill(n)(math.random))

  private def randomMatrix(rows: Int, cols: Int): RealMatrix =
    new Array2DRowRealMatrix(Array.fill(rows, cols)(math.random))

}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

// $example on$
import org.apache.spark.graphx.{Graph, VertexRDD}
import org.apache.spark.graphx.util.GraphGenerators
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example use the [`aggregateMessages`][Graph.aggregateMessages] operator to
 * compute the average age of the more senior followers of each user
 * Run with
 * {{{
 * bin/run-example graphx.AggregateMessagesExample
 * }}}
 */
object AggregateMessagesExample {

  def main(args: Array[String]): Unit = {
    // Creates a SparkSession.
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    val sc = spark.sparkContext

    // $example on$
    // Create a graph with "age" as the vertex property.
    // Here we use a random graph for simplicity.
    val graph: Graph[Double, Int] =
      GraphGenerators.logNormalGraph(sc, numVertices = 100).mapVertices( (id, _) => id.toDouble )
    // Compute the number of older followers and their total age
    val olderFollowers: VertexRDD[(Int, Double)] = graph.aggregateMessages[(Int, Double)](
      triplet => { // Map Function
        if (triplet.srcAttr > triplet.dstAttr) {
          // Send message to destination vertex containing counter and age
          triplet.sendToDst((1, triplet.srcAttr))
        }
      },
      // Add counter and age
      (a, b) => (a._1 + b._1, a._2 + b._2) // Reduce Function
    )
    // Divide total age by number of older followers to get average age of older followers
    val avgAgeOfOlderFollowers: VertexRDD[Double] =
      olderFollowers.mapValues( (id, value) =>
        value match { case (count, totalAge) => totalAge / count } )
    // Display the results
    avgAgeOfOlderFollowers.collect.foreach(println(_))
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

// $example on$
import org.apache.spark.graphx.GraphLoader
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * A PageRank example on social network dataset
 * Run with
 * {{{
 * bin/run-example graphx.PageRankExample
 * }}}
 */
object PageRankExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession.
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    val sc = spark.sparkContext

    // $example on$
    // Load the edges as a graph
    val graph = GraphLoader.edgeListFile(sc, "data/graphx/followers.txt")
    // Run PageRank
    val ranks = graph.pageRank(0.0001).vertices
    // Join the ranks with the usernames
    val users = sc.textFile("data/graphx/users.txt").map { line =>
      val fields = line.split(",")
      (fields(0).toLong, fields(1))
    }
    val ranksByUsername = users.join(ranks).map {
      case (id, (username, rank)) => (username, rank)
    }
    // Print the result
    println(ranksByUsername.collect().mkString("\n"))
    // $example off$
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

import scala.collection.mutable

import org.apache.spark._
import org.apache.spark.graphx._
import org.apache.spark.graphx.PartitionStrategy._
import org.apache.spark.graphx.lib._
import org.apache.spark.internal.Logging
import org.apache.spark.storage.StorageLevel


/**
 * Driver program for running graph algorithms.
 */
object Analytics extends Logging {

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      val usage = """Usage: Analytics <taskType> <file> --numEPart=<num_edge_partitions>
      |[other options] Supported 'taskType' as follows:
      |pagerank    Compute PageRank
      |cc          Compute the connected components of vertices
      |triangles   Count the number of triangles""".stripMargin
      System.err.println(usage)
      System.exit(1)
    }

    val taskType = args(0)
    val fname = args(1)
    val optionsList = args.drop(2).map { arg =>
      arg.dropWhile(_ == '-').split('=') match {
        case Array(opt, v) => (opt -> v)
        case _ => throw new IllegalArgumentException(s"Invalid argument: $arg")
      }
    }
    val options = mutable.Map(optionsList: _*)

    val conf = new SparkConf()
    GraphXUtils.registerKryoClasses(conf)

    val numEPart = options.remove("numEPart").map(_.toInt).getOrElse {
      println("Set the number of edge partitions using --numEPart.")
      sys.exit(1)
    }
    val partitionStrategy: Option[PartitionStrategy] = options.remove("partStrategy")
      .map(PartitionStrategy.fromString(_))
    val edgeStorageLevel = options.remove("edgeStorageLevel")
      .map(StorageLevel.fromString(_)).getOrElse(StorageLevel.MEMORY_ONLY)
    val vertexStorageLevel = options.remove("vertexStorageLevel")
      .map(StorageLevel.fromString(_)).getOrElse(StorageLevel.MEMORY_ONLY)

    taskType match {
      case "pagerank" =>
        val tol = options.remove("tol").map(_.toFloat).getOrElse(0.001F)
        val outFname = options.remove("output").getOrElse("")
        val numIterOpt = options.remove("numIter").map(_.toInt)

        options.foreach {
          case (opt, _) => throw new IllegalArgumentException(s"Invalid option: $opt")
        }

        println("======================================")
        println("|             PageRank               |")
        println("======================================")

        val sc = new SparkContext(conf.setAppName(s"PageRank($fname)"))

        val unpartitionedGraph = GraphLoader.edgeListFile(sc, fname,
          numEdgePartitions = numEPart,
          edgeStorageLevel = edgeStorageLevel,
          vertexStorageLevel = vertexStorageLevel).cache()
        val graph = partitionStrategy.foldLeft(unpartitionedGraph)(_.partitionBy(_))

        println(s"GRAPHX: Number of vertices ${graph.vertices.count}")
        println(s"GRAPHX: Number of edges ${graph.edges.count}")

        val pr = (numIterOpt match {
          case Some(numIter) => PageRank.run(graph, numIter)
          case None => PageRank.runUntilConvergence(graph, tol)
        }).vertices.cache()

        println(s"GRAPHX: Total rank: ${pr.map(_._2).reduce(_ + _)}")

        if (!outFname.isEmpty) {
          logWarning(s"Saving pageranks of pages to $outFname")
          pr.map { case (id, r) => id + "\t" + r }.saveAsTextFile(outFname)
        }

        sc.stop()

      case "cc" =>
        options.foreach {
          case (opt, _) => throw new IllegalArgumentException(s"Invalid option: $opt")
        }

        println("======================================")
        println("|      Connected Components          |")
        println("======================================")

        val sc = new SparkContext(conf.setAppName(s"ConnectedComponents($fname)"))
        val unpartitionedGraph = GraphLoader.edgeListFile(sc, fname,
          numEdgePartitions = numEPart,
          edgeStorageLevel = edgeStorageLevel,
          vertexStorageLevel = vertexStorageLevel).cache()
        val graph = partitionStrategy.foldLeft(unpartitionedGraph)(_.partitionBy(_))

        val cc = ConnectedComponents.run(graph)
        println(s"Components: ${cc.vertices.map { case (vid, data) => data }.distinct()}")
        sc.stop()

      case "triangles" =>
        options.foreach {
          case (opt, _) => throw new IllegalArgumentException(s"Invalid option: $opt")
        }

        println("======================================")
        println("|      Triangle Count                |")
        println("======================================")

        val sc = new SparkContext(conf.setAppName(s"TriangleCount($fname)"))
        val graph = GraphLoader.edgeListFile(sc, fname,
          canonicalOrientation = true,
          numEdgePartitions = numEPart,
          edgeStorageLevel = edgeStorageLevel,
          vertexStorageLevel = vertexStorageLevel)
          // TriangleCount requires the graph to be partitioned
          .partitionBy(partitionStrategy.getOrElse(RandomVertexCut)).cache()
        val triangles = TriangleCount.run(graph)
        val triangleTypes = triangles.vertices.map {
          case (vid, data) => data.toLong
        }.reduce(_ + _) / 3

        println(s"Triangles: ${triangleTypes}")
        sc.stop()

      case _ =>
        println("Invalid task type.")
    }
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

/**
 * Uses GraphX to run PageRank on a LiveJournal social network graph. Download the dataset from
 * http://snap.stanford.edu/data/soc-LiveJournal1.html.
 */
object LiveJournalPageRank {
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println(
        "Usage: LiveJournalPageRank <edge_list_file>\n" +
          "    --numEPart=<num_edge_partitions>\n" +
          "        The number of partitions for the graph's edge RDD.\n" +
          "    [--tol=<tolerance>]\n" +
          "        The tolerance allowed at convergence (smaller => more accurate). Default is " +
          "0.001.\n" +
          "    [--output=<output_file>]\n" +
          "        If specified, the file to write the ranks to.\n" +
          "    [--partStrategy=RandomVertexCut | EdgePartition1D | EdgePartition2D | " +
          "CanonicalRandomVertexCut]\n" +
          "        The way edges are assigned to edge partitions. Default is RandomVertexCut.")
      System.exit(-1)
    }

    Analytics.main(args.patch(0, List("pagerank"), 0))
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

// $example on$
import org.apache.spark.graphx.GraphLoader
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * Suppose I want to build a graph from some text files, restrict the graph
 * to important relationships and users, run page-rank on the sub-graph, and
 * then finally return attributes associated with the top users.
 * This example do all of this in just a few lines with GraphX.
 *
 * Run with
 * {{{
 * bin/run-example graphx.ComprehensiveExample
 * }}}
 */
object ComprehensiveExample {

  def main(args: Array[String]): Unit = {
    // Creates a SparkSession.
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    val sc = spark.sparkContext

    // $example on$
    // Load my user data and parse into tuples of user id and attribute list
    val users = (sc.textFile("data/graphx/users.txt")
      .map(line => line.split(",")).map( parts => (parts.head.toLong, parts.tail) ))

    // Parse the edge data which is already in userId -> userId format
    val followerGraph = GraphLoader.edgeListFile(sc, "data/graphx/followers.txt")

    // Attach the user attributes
    val graph = followerGraph.outerJoinVertices(users) {
      case (uid, deg, Some(attrList)) => attrList
      // Some users may not have attributes so we set them as empty
      case (uid, deg, None) => Array.empty[String]
    }

    // Restrict the graph to users with usernames and names
    val subgraph = graph.subgraph(vpred = (vid, attr) => attr.size == 2)

    // Compute the PageRank
    val pagerankGraph = subgraph.pageRank(0.001)

    // Get the attributes of the top pagerank users
    val userInfoWithPageRank = subgraph.outerJoinVertices(pagerankGraph.vertices) {
      case (uid, attrList, Some(pr)) => (pr, attrList.toList)
      case (uid, attrList, None) => (0.0, attrList.toList)
    }

    println(userInfoWithPageRank.vertices.top(5)(Ordering.by(_._2._1)).mkString("\n"))
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

// $example on$
import org.apache.spark.graphx.{GraphLoader, PartitionStrategy}
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * A vertex is part of a triangle when it has two adjacent vertices with an edge between them.
 * GraphX implements a triangle counting algorithm in the [`TriangleCount` object][TriangleCount]
 * that determines the number of triangles passing through each vertex,
 * providing a measure of clustering.
 * We compute the triangle count of the social network dataset.
 *
 * Note that `TriangleCount` requires the edges to be in canonical orientation (`srcId < dstId`)
 * and the graph to be partitioned using [`Graph.partitionBy`][Graph.partitionBy].
 *
 * Run with
 * {{{
 * bin/run-example graphx.TriangleCountingExample
 * }}}
 */
object TriangleCountingExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession.
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    val sc = spark.sparkContext

    // $example on$
    // Load the edges in canonical order and partition the graph for triangle count
    val graph = GraphLoader.edgeListFile(sc, "data/graphx/followers.txt", true)
      .partitionBy(PartitionStrategy.RandomVertexCut)
    // Find the triangle count for each vertex
    val triCounts = graph.triangleCount().vertices
    // Join the triangle counts with the usernames
    val users = sc.textFile("data/graphx/users.txt").map { line =>
      val fields = line.split(",")
      (fields(0).toLong, fields(1))
    }
    val triCountByUsername = users.join(triCounts).map { case (id, (username, tc)) =>
      (username, tc)
    }
    // Print the result
    println(triCountByUsername.collect().mkString("\n"))
    // $example off$
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

// $example on$
import org.apache.spark.graphx.{Graph, VertexId}
import org.apache.spark.graphx.util.GraphGenerators
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example use the Pregel operator to express computation
 * such as single source shortest path
 * Run with
 * {{{
 * bin/run-example graphx.SSSPExample
 * }}}
 */
object SSSPExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession.
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    val sc = spark.sparkContext

    // $example on$
    // A graph with edge attributes containing distances
    val graph: Graph[Long, Double] =
      GraphGenerators.logNormalGraph(sc, numVertices = 100).mapEdges(e => e.attr.toDouble)
    val sourceId: VertexId = 42 // The ultimate source
    // Initialize the graph such that all vertices except the root have distance infinity.
    val initialGraph = graph.mapVertices((id, _) =>
        if (id == sourceId) 0.0 else Double.PositiveInfinity)
    val sssp = initialGraph.pregel(Double.PositiveInfinity)(
      (id, dist, newDist) => math.min(dist, newDist), // Vertex Program
      triplet => {  // Send Message
        if (triplet.srcAttr + triplet.attr < triplet.dstAttr) {
          Iterator((triplet.dstId, triplet.srcAttr + triplet.attr))
        } else {
          Iterator.empty
        }
      },
      (a, b) => math.min(a, b) // Merge Message
    )
    println(sssp.vertices.collect.mkString("\n"))
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

import java.io.{FileOutputStream, PrintWriter}

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.graphx.{GraphXUtils, PartitionStrategy}
import org.apache.spark.graphx.util.GraphGenerators

/**
 * The SynthBenchmark application can be used to run various GraphX algorithms on
 * synthetic log-normal graphs.  The intent of this code is to enable users to
 * profile the GraphX system without access to large graph datasets.
 */
object SynthBenchmark {

  /**
   * To run this program use the following:
   *
   * MASTER=spark://foobar bin/run-example graphx.SynthBenchmark -app=pagerank
   *
   * Options:
   *   -app "pagerank" or "cc" for pagerank or connected components. (Default: pagerank)
   *   -niters the number of iterations of pagerank to use (Default: 10)
   *   -nverts the number of vertices in the graph (Default: 1000000)
   *   -numEPart the number of edge partitions in the graph (Default: number of cores)
   *   -partStrategy the graph partitioning strategy to use
   *   -mu the mean parameter for the log-normal graph (Default: 4.0)
   *   -sigma the stdev parameter for the log-normal graph (Default: 1.3)
   *   -degFile the local file to save the degree information (Default: Empty)
   *   -seed seed to use for RNGs (Default: -1, picks seed randomly)
   */
  def main(args: Array[String]) {
    val options = args.map {
      arg =>
        arg.dropWhile(_ == '-').split('=') match {
          case Array(opt, v) => (opt -> v)
          case _ => throw new IllegalArgumentException(s"Invalid argument: $arg")
        }
    }

    var app = "pagerank"
    var niter = 10
    var numVertices = 100000
    var numEPart: Option[Int] = None
    var partitionStrategy: Option[PartitionStrategy] = None
    var mu: Double = 4.0
    var sigma: Double = 1.3
    var degFile: String = ""
    var seed: Int = -1

    options.foreach {
      case ("app", v) => app = v
      case ("niters", v) => niter = v.toInt
      case ("nverts", v) => numVertices = v.toInt
      case ("numEPart", v) => numEPart = Some(v.toInt)
      case ("partStrategy", v) => partitionStrategy = Some(PartitionStrategy.fromString(v))
      case ("mu", v) => mu = v.toDouble
      case ("sigma", v) => sigma = v.toDouble
      case ("degFile", v) => degFile = v
      case ("seed", v) => seed = v.toInt
      case (opt, _) => throw new IllegalArgumentException(s"Invalid option: $opt")
    }

    val conf = new SparkConf()
      .setAppName(s"GraphX Synth Benchmark (nverts = $numVertices, app = $app)")
    GraphXUtils.registerKryoClasses(conf)

    val sc = new SparkContext(conf)

    // Create the graph
    println("Creating graph...")
    val unpartitionedGraph = GraphGenerators.logNormalGraph(sc, numVertices,
      numEPart.getOrElse(sc.defaultParallelism), mu, sigma, seed)
    // Repartition the graph
    val graph = partitionStrategy.foldLeft(unpartitionedGraph)(_.partitionBy(_)).cache()

    var startTime = System.currentTimeMillis()
    val numEdges = graph.edges.count()
    println(s"Done creating graph. Num Vertices = $numVertices, Num Edges = $numEdges")
    val loadTime = System.currentTimeMillis() - startTime

    // Collect the degree distribution (if desired)
    if (!degFile.isEmpty) {
      val fos = new FileOutputStream(degFile)
      val pos = new PrintWriter(fos)
      val hist = graph.vertices.leftJoin(graph.degrees)((id, _, optDeg) => optDeg.getOrElse(0))
        .map(p => p._2).countByValue()
      hist.foreach {
        case (deg, count) => pos.println(s"$deg \t $count")
      }
    }

    // Run PageRank
    startTime = System.currentTimeMillis()
    if (app == "pagerank") {
      println("Running PageRank")
      val totalPR = graph.staticPageRank(niter).vertices.map(_._2).sum()
      println(s"Total PageRank = $totalPR")
    } else if (app == "cc") {
      println("Running Connected Components")
      val numComponents = graph.connectedComponents.vertices.map(_._2).distinct().count()
      println(s"Number of components = $numComponents")
    }
    val runTime = System.currentTimeMillis() - startTime

    println(s"Num Vertices = $numVertices")
    println(s"Num Edges = $numEdges")
    println(s"Creation time = ${loadTime/1000.0} seconds")
    println(s"Run time = ${runTime/1000.0} seconds")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.graphx

// $example on$
import org.apache.spark.graphx.GraphLoader
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * A connected components algorithm example.
 * The connected components algorithm labels each connected component of the graph
 * with the ID of its lowest-numbered vertex.
 * For example, in a social network, connected components can approximate clusters.
 * GraphX contains an implementation of the algorithm in the
 * [`ConnectedComponents` object][ConnectedComponents],
 * and we compute the connected components of the example social network dataset.
 *
 * Run with
 * {{{
 * bin/run-example graphx.ConnectedComponentsExample
 * }}}
 */
object ConnectedComponentsExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession.
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    val sc = spark.sparkContext

    // $example on$
    // Load the graph as in the PageRank example
    val graph = GraphLoader.edgeListFile(sc, "data/graphx/followers.txt")
    // Find the connected components
    val cc = graph.connectedComponents().vertices
    // Join the connected components with the usernames
    val users = sc.textFile("data/graphx/users.txt").map { line =>
      val fields = line.split(",")
      (fields(0).toLong, fields(1))
    }
    val ccByUsername = users.join(cc).map {
      case (id, (username, cc)) => (username, cc)
    }
    // Print the result
    println(ccByUsername.collect().mkString("\n"))
    // $example off$
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.spark.examples.sql

import java.util.Properties

import org.apache.spark.sql.SparkSession

object SQLDataSourceExample {

  case class Person(name: String, age: Long)

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder()
      .appName("Spark SQL data sources example")
      .config("spark.some.config.option", "some-value")
      .getOrCreate()

    runBasicDataSourceExample(spark)
    runBasicParquetExample(spark)
    runParquetSchemaMergingExample(spark)
    runJsonDatasetExample(spark)
    runJdbcDatasetExample(spark)

    spark.stop()
  }

  private def runBasicDataSourceExample(spark: SparkSession): Unit = {
    // $example on:generic_load_save_functions$
    val usersDF = spark.read.load("examples/src/main/resources/users.parquet")
    usersDF.select("name", "favorite_color").write.save("namesAndFavColors.parquet")
    // $example off:generic_load_save_functions$
    // $example on:manual_load_options$
    val peopleDF = spark.read.format("json").load("examples/src/main/resources/people.json")
    peopleDF.select("name", "age").write.format("parquet").save("namesAndAges.parquet")
    // $example off:manual_load_options$
    // $example on:manual_load_options_csv$
    val peopleDFCsv = spark.read.format("csv")
      .option("sep", ";")
      .option("inferSchema", "true")
      .option("header", "true")
      .load("examples/src/main/resources/people.csv")
    // $example off:manual_load_options_csv$
    // $example on:manual_save_options_orc$
    usersDF.write.format("orc")
      .option("orc.bloom.filter.columns", "favorite_color")
      .option("orc.dictionary.key.threshold", "1.0")
      .option("orc.column.encoding.direct", "name")
      .save("users_with_options.orc")
    // $example off:manual_save_options_orc$

    // $example on:direct_sql$
    val sqlDF = spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")
    // $example off:direct_sql$
    // $example on:write_sorting_and_bucketing$
    peopleDF.write.bucketBy(42, "name").sortBy("age").saveAsTable("people_bucketed")
    // $example off:write_sorting_and_bucketing$
    // $example on:write_partitioning$
    usersDF.write.partitionBy("favorite_color").format("parquet").save("namesPartByColor.parquet")
    // $example off:write_partitioning$
    // $example on:write_partition_and_bucket$
    usersDF
      .write
      .partitionBy("favorite_color")
      .bucketBy(42, "name")
      .saveAsTable("users_partitioned_bucketed")
    // $example off:write_partition_and_bucket$

    spark.sql("DROP TABLE IF EXISTS people_bucketed")
    spark.sql("DROP TABLE IF EXISTS users_partitioned_bucketed")
  }

  private def runBasicParquetExample(spark: SparkSession): Unit = {
    // $example on:basic_parquet_example$
    // Encoders for most common types are automatically provided by importing spark.implicits._
    import spark.implicits._

    val peopleDF = spark.read.json("examples/src/main/resources/people.json")

    // DataFrames can be saved as Parquet files, maintaining the schema information
    peopleDF.write.parquet("people.parquet")

    // Read in the parquet file created above
    // Parquet files are self-describing so the schema is preserved
    // The result of loading a Parquet file is also a DataFrame
    val parquetFileDF = spark.read.parquet("people.parquet")

    // Parquet files can also be used to create a temporary view and then used in SQL statements
    parquetFileDF.createOrReplaceTempView("parquetFile")
    val namesDF = spark.sql("SELECT name FROM parquetFile WHERE age BETWEEN 13 AND 19")
    namesDF.map(attributes => "Name: " + attributes(0)).show()
    // +------------+
    // |       value|
    // +------------+
    // |Name: Justin|
    // +------------+
    // $example off:basic_parquet_example$
  }

  private def runParquetSchemaMergingExample(spark: SparkSession): Unit = {
    // $example on:schema_merging$
    // This is used to implicitly convert an RDD to a DataFrame.
    import spark.implicits._

    // Create a simple DataFrame, store into a partition directory
    val squaresDF = spark.sparkContext.makeRDD(1 to 5).map(i => (i, i * i)).toDF("value", "square")
    squaresDF.write.parquet("data/test_table/key=1")

    // Create another DataFrame in a new partition directory,
    // adding a new column and dropping an existing column
    val cubesDF = spark.sparkContext.makeRDD(6 to 10).map(i => (i, i * i * i)).toDF("value", "cube")
    cubesDF.write.parquet("data/test_table/key=2")

    // Read the partitioned table
    val mergedDF = spark.read.option("mergeSchema", "true").parquet("data/test_table")
    mergedDF.printSchema()

    // The final schema consists of all 3 columns in the Parquet files together
    // with the partitioning column appeared in the partition directory paths
    // root
    //  |-- value: int (nullable = true)
    //  |-- square: int (nullable = true)
    //  |-- cube: int (nullable = true)
    //  |-- key: int (nullable = true)
    // $example off:schema_merging$
  }

  private def runJsonDatasetExample(spark: SparkSession): Unit = {
    // $example on:json_dataset$
    // Primitive types (Int, String, etc) and Product types (case classes) encoders are
    // supported by importing this when creating a Dataset.
    import spark.implicits._

    // A JSON dataset is pointed to by path.
    // The path can be either a single text file or a directory storing text files
    val path = "examples/src/main/resources/people.json"
    val peopleDF = spark.read.json(path)

    // The inferred schema can be visualized using the printSchema() method
    peopleDF.printSchema()
    // root
    //  |-- age: long (nullable = true)
    //  |-- name: string (nullable = true)

    // Creates a temporary view using the DataFrame
    peopleDF.createOrReplaceTempView("people")

    // SQL statements can be run by using the sql methods provided by spark
    val teenagerNamesDF = spark.sql("SELECT name FROM people WHERE age BETWEEN 13 AND 19")
    teenagerNamesDF.show()
    // +------+
    // |  name|
    // +------+
    // |Justin|
    // +------+

    // Alternatively, a DataFrame can be created for a JSON dataset represented by
    // a Dataset[String] storing one JSON object per string
    val otherPeopleDataset = spark.createDataset(
      """{"name":"Yin","address":{"city":"Columbus","state":"Ohio"}}""" :: Nil)
    val otherPeople = spark.read.json(otherPeopleDataset)
    otherPeople.show()
    // +---------------+----+
    // |        address|name|
    // +---------------+----+
    // |[Columbus,Ohio]| Yin|
    // +---------------+----+
    // $example off:json_dataset$
  }

  private def runJdbcDatasetExample(spark: SparkSession): Unit = {
    // $example on:jdbc_dataset$
    // Note: JDBC loading and saving can be achieved via either the load/save or jdbc methods
    // Loading data from a JDBC source
    val jdbcDF = spark.read
      .format("jdbc")
      .option("url", "jdbc:postgresql:dbserver")
      .option("dbtable", "schema.tablename")
      .option("user", "username")
      .option("password", "password")
      .load()

    val connectionProperties = new Properties()
    connectionProperties.put("user", "username")
    connectionProperties.put("password", "password")
    val jdbcDF2 = spark.read
      .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)
    // Specifying the custom data types of the read schema
    connectionProperties.put("customSchema", "id DECIMAL(38, 0), name STRING")
    val jdbcDF3 = spark.read
      .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)

    // Saving data to a JDBC source
    jdbcDF.write
      .format("jdbc")
      .option("url", "jdbc:postgresql:dbserver")
      .option("dbtable", "schema.tablename")
      .option("user", "username")
      .option("password", "password")
      .save()

    jdbcDF2.write
      .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)

    // Specifying create table column data types on write
    jdbcDF.write
      .option("createTableColumnTypes", "name CHAR(64), comments VARCHAR(1024)")
      .jdbc("jdbc:postgresql:dbserver", "schema.tablename", connectionProperties)
    // $example off:jdbc_dataset$
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.sql.streaming

import java.util.UUID

import org.apache.spark.sql.SparkSession

/**
 * Consumes messages from one or more topics in Kafka and does wordcount.
 * Usage: StructuredKafkaWordCount <bootstrap-servers> <subscribe-type> <topics>
 *     [<checkpoint-location>]
 *   <bootstrap-servers> The Kafka "bootstrap.servers" configuration. A
 *   comma-separated list of host:port.
 *   <subscribe-type> There are three kinds of type, i.e. 'assign', 'subscribe',
 *   'subscribePattern'.
 *   |- <assign> Specific TopicPartitions to consume. Json string
 *   |  {"topicA":[0,1],"topicB":[2,4]}.
 *   |- <subscribe> The topic list to subscribe. A comma-separated list of
 *   |  topics.
 *   |- <subscribePattern> The pattern used to subscribe to topic(s).
 *   |  Java regex string.
 *   |- Only one of "assign, "subscribe" or "subscribePattern" options can be
 *   |  specified for Kafka source.
 *   <topics> Different value format depends on the value of 'subscribe-type'.
 *   <checkpoint-location> Directory in which to create checkpoints. If not
 *   provided, defaults to a randomized directory in /tmp.
 *
 * Example:
 *    `$ bin/run-example \
 *      sql.streaming.StructuredKafkaWordCount host1:port1,host2:port2 \
 *      subscribe topic1,topic2`
 */
object StructuredKafkaWordCount {
  def main(args: Array[String]): Unit = {
    if (args.length < 3) {
      System.err.println("Usage: StructuredKafkaWordCount <bootstrap-servers> " +
        "<subscribe-type> <topics> [<checkpoint-location>]")
      System.exit(1)
    }

    val Array(bootstrapServers, subscribeType, topics, _*) = args
    val checkpointLocation =
      if (args.length > 3) args(3) else "/tmp/temporary-" + UUID.randomUUID.toString

    val spark = SparkSession
      .builder
      .appName("StructuredKafkaWordCount")
      .getOrCreate()

    import spark.implicits._

    // Create DataSet representing the stream of input lines from kafka
    val lines = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", bootstrapServers)
      .option(subscribeType, topics)
      .load()
      .selectExpr("CAST(value AS STRING)")
      .as[String]

    // Generate running word count
    val wordCounts = lines.flatMap(_.split(" ")).groupBy("value").count()

    // Start running the query that prints the running counts to the console
    val query = wordCounts.writeStream
      .outputMode("complete")
      .format("console")
      .option("checkpointLocation", checkpointLocation)
      .start()

    query.awaitTermination()
  }

}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.sql.streaming

import java.sql.Timestamp

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.streaming._


/**
 * Counts words in UTF8 encoded, '\n' delimited text received from the network.
 *
 * Usage: MapGroupsWithState <hostname> <port>
 * <hostname> and <port> describe the TCP server that Structured Streaming
 * would connect to receive data.
 *
 * To run this on your local machine, you need to first run a Netcat server
 * `$ nc -lk 9999`
 * and then run the example
 * `$ bin/run-example sql.streaming.StructuredSessionization
 * localhost 9999`
 */
object StructuredSessionization {

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("Usage: StructuredSessionization <hostname> <port>")
      System.exit(1)
    }

    val host = args(0)
    val port = args(1).toInt

    val spark = SparkSession
      .builder
      .appName("StructuredSessionization")
      .getOrCreate()

    import spark.implicits._

    // Create DataFrame representing the stream of input lines from connection to host:port
    val lines = spark.readStream
      .format("socket")
      .option("host", host)
      .option("port", port)
      .option("includeTimestamp", true)
      .load()

    // Split the lines into words, treat words as sessionId of events
    val events = lines
      .as[(String, Timestamp)]
      .flatMap { case (line, timestamp) =>
        line.split(" ").map(word => Event(sessionId = word, timestamp))
      }

    // Sessionize the events. Track number of events, start and end timestamps of session, and
    // and report session updates.
    val sessionUpdates = events
      .groupByKey(event => event.sessionId)
      .mapGroupsWithState[SessionInfo, SessionUpdate](GroupStateTimeout.ProcessingTimeTimeout) {

        case (sessionId: String, events: Iterator[Event], state: GroupState[SessionInfo]) =>

          // If timed out, then remove session and send final update
          if (state.hasTimedOut) {
            val finalUpdate =
              SessionUpdate(sessionId, state.get.durationMs, state.get.numEvents, expired = true)
            state.remove()
            finalUpdate
          } else {
            // Update start and end timestamps in session
            val timestamps = events.map(_.timestamp.getTime).toSeq
            val updatedSession = if (state.exists) {
              val oldSession = state.get
              SessionInfo(
                oldSession.numEvents + timestamps.size,
                oldSession.startTimestampMs,
                math.max(oldSession.endTimestampMs, timestamps.max))
            } else {
              SessionInfo(timestamps.size, timestamps.min, timestamps.max)
            }
            state.update(updatedSession)

            // Set timeout such that the session will be expired if no data received for 10 seconds
            state.setTimeoutDuration("10 seconds")
            SessionUpdate(sessionId, state.get.durationMs, state.get.numEvents, expired = false)
          }
      }

    // Start running the query that prints the session updates to the console
    val query = sessionUpdates
      .writeStream
      .outputMode("update")
      .format("console")
      .start()

    query.awaitTermination()
  }
}
/** User-defined data type representing the input events */
case class Event(sessionId: String, timestamp: Timestamp)

/**
 * User-defined data type for storing a session information as state in mapGroupsWithState.
 *
 * @param numEvents        total number of events received in the session
 * @param startTimestampMs timestamp of first event received in the session when it started
 * @param endTimestampMs   timestamp of last event received in the session before it expired
 */
case class SessionInfo(
    numEvents: Int,
    startTimestampMs: Long,
    endTimestampMs: Long) {

  /** Duration of the session, between the first and last events */
  def durationMs: Long = endTimestampMs - startTimestampMs
}

/**
 * User-defined data type representing the update information returned by mapGroupsWithState.
 *
 * @param id          Id of the session
 * @param durationMs  Duration the session was active, that is, from first event to its expiry
 * @param numEvents   Number of events received by the session while it was active
 * @param expired     Is the session active or expired
 */
case class SessionUpdate(
    id: String,
    durationMs: Long,
    numEvents: Int,
    expired: Boolean)

// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.sql.streaming

import org.apache.spark.sql.SparkSession

/**
 * Counts words in UTF8 encoded, '\n' delimited text received from the network.
 *
 * Usage: StructuredNetworkWordCount <hostname> <port>
 * <hostname> and <port> describe the TCP server that Structured Streaming
 * would connect to receive data.
 *
 * To run this on your local machine, you need to first run a Netcat server
 *    `$ nc -lk 9999`
 * and then run the example
 *    `$ bin/run-example sql.streaming.StructuredNetworkWordCount
 *    localhost 9999`
 */
object StructuredNetworkWordCount {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: StructuredNetworkWordCount <hostname> <port>")
      System.exit(1)
    }

    val host = args(0)
    val port = args(1).toInt

    val spark = SparkSession
      .builder
      .appName("StructuredNetworkWordCount")
      .getOrCreate()

    import spark.implicits._

    // Create DataFrame representing the stream of input lines from connection to host:port
    val lines = spark.readStream
      .format("socket")
      .option("host", host)
      .option("port", port)
      .load()

    // Split the lines into words
    val words = lines.as[String].flatMap(_.split(" "))

    // Generate running word count
    val wordCounts = words.groupBy("value").count()

    // Start running the query that prints the running counts to the console
    val query = wordCounts.writeStream
      .outputMode("complete")
      .format("console")
      .start()

    query.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.sql.streaming

import java.sql.Timestamp

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

/**
 * Counts words in UTF8 encoded, '\n' delimited text received from the network over a
 * sliding window of configurable duration. Each line from the network is tagged
 * with a timestamp that is used to determine the windows into which it falls.
 *
 * Usage: StructuredNetworkWordCountWindowed <hostname> <port> <window duration>
 *   [<slide duration>]
 * <hostname> and <port> describe the TCP server that Structured Streaming
 * would connect to receive data.
 * <window duration> gives the size of window, specified as integer number of seconds
 * <slide duration> gives the amount of time successive windows are offset from one another,
 * given in the same units as above. <slide duration> should be less than or equal to
 * <window duration>. If the two are equal, successive windows have no overlap. If
 * <slide duration> is not provided, it defaults to <window duration>.
 *
 * To run this on your local machine, you need to first run a Netcat server
 *    `$ nc -lk 9999`
 * and then run the example
 *    `$ bin/run-example sql.streaming.StructuredNetworkWordCountWindowed
 *    localhost 9999 <window duration in seconds> [<slide duration in seconds>]`
 *
 * One recommended <window duration>, <slide duration> pair is 10, 5
 */
object StructuredNetworkWordCountWindowed {

  def main(args: Array[String]) {
    if (args.length < 3) {
      System.err.println("Usage: StructuredNetworkWordCountWindowed <hostname> <port>" +
        " <window duration in seconds> [<slide duration in seconds>]")
      System.exit(1)
    }

    val host = args(0)
    val port = args(1).toInt
    val windowSize = args(2).toInt
    val slideSize = if (args.length == 3) windowSize else args(3).toInt
    if (slideSize > windowSize) {
      System.err.println("<slide duration> must be less than or equal to <window duration>")
    }
    val windowDuration = s"$windowSize seconds"
    val slideDuration = s"$slideSize seconds"

    val spark = SparkSession
      .builder
      .appName("StructuredNetworkWordCountWindowed")
      .getOrCreate()

    import spark.implicits._

    // Create DataFrame representing the stream of input lines from connection to host:port
    val lines = spark.readStream
      .format("socket")
      .option("host", host)
      .option("port", port)
      .option("includeTimestamp", true)
      .load()

    // Split the lines into words, retaining timestamps
    val words = lines.as[(String, Timestamp)].flatMap(line =>
      line._1.split(" ").map(word => (word, line._2))
    ).toDF("word", "timestamp")

    // Group the data by window and word and compute the count of each group
    val windowedCounts = words.groupBy(
      window($"timestamp", windowDuration, slideDuration), $"word"
    ).count().orderBy("window")

    // Start running the query that prints the windowed word counts to the console
    val query = windowedCounts.writeStream
      .outputMode("complete")
      .format("console")
      .option("truncate", "false")
      .start()

    query.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.spark.examples.sql.hive

// $example on:spark_hive$
import java.io.File

import org.apache.spark.sql.{Row, SaveMode, SparkSession}
// $example off:spark_hive$

object SparkHiveExample {

  // $example on:spark_hive$
  case class Record(key: Int, value: String)
  // $example off:spark_hive$

  def main(args: Array[String]) {
    // When working with Hive, one must instantiate `SparkSession` with Hive support, including
    // connectivity to a persistent Hive metastore, support for Hive serdes, and Hive user-defined
    // functions. Users who do not have an existing Hive deployment can still enable Hive support.
    // When not configured by the hive-site.xml, the context automatically creates `metastore_db`
    // in the current directory and creates a directory configured by `spark.sql.warehouse.dir`,
    // which defaults to the directory `spark-warehouse` in the current directory that the spark
    // application is started.

    // $example on:spark_hive$
    // warehouseLocation points to the default location for managed databases and tables
    val warehouseLocation = new File("spark-warehouse").getAbsolutePath

    val spark = SparkSession
      .builder()
      .appName("Spark Hive Example")
      .config("spark.sql.warehouse.dir", warehouseLocation)
      .enableHiveSupport()
      .getOrCreate()

    import spark.implicits._
    import spark.sql

    sql("CREATE TABLE IF NOT EXISTS src (key INT, value STRING) USING hive")
    sql("LOAD DATA LOCAL INPATH 'examples/src/main/resources/kv1.txt' INTO TABLE src")

    // Queries are expressed in HiveQL
    sql("SELECT * FROM src").show()
    // +---+-------+
    // |key|  value|
    // +---+-------+
    // |238|val_238|
    // | 86| val_86|
    // |311|val_311|
    // ...

    // Aggregation queries are also supported.
    sql("SELECT COUNT(*) FROM src").show()
    // +--------+
    // |count(1)|
    // +--------+
    // |    500 |
    // +--------+

    // The results of SQL queries are themselves DataFrames and support all normal functions.
    val sqlDF = sql("SELECT key, value FROM src WHERE key < 10 ORDER BY key")

    // The items in DataFrames are of type Row, which allows you to access each column by ordinal.
    val stringsDS = sqlDF.map {
      case Row(key: Int, value: String) => s"Key: $key, Value: $value"
    }
    stringsDS.show()
    // +--------------------+
    // |               value|
    // +--------------------+
    // |Key: 0, Value: val_0|
    // |Key: 0, Value: val_0|
    // |Key: 0, Value: val_0|
    // ...

    // You can also use DataFrames to create temporary views within a SparkSession.
    val recordsDF = spark.createDataFrame((1 to 100).map(i => Record(i, s"val_$i")))
    recordsDF.createOrReplaceTempView("records")

    // Queries can then join DataFrame data with data stored in Hive.
    sql("SELECT * FROM records r JOIN src s ON r.key = s.key").show()
    // +---+------+---+------+
    // |key| value|key| value|
    // +---+------+---+------+
    // |  2| val_2|  2| val_2|
    // |  4| val_4|  4| val_4|
    // |  5| val_5|  5| val_5|
    // ...

    // Create a Hive managed Parquet table, with HQL syntax instead of the Spark SQL native syntax
    // `USING hive`
    sql("CREATE TABLE hive_records(key int, value string) STORED AS PARQUET")
    // Save DataFrame to the Hive managed table
    val df = spark.table("src")
    df.write.mode(SaveMode.Overwrite).saveAsTable("hive_records")
    // After insertion, the Hive managed table has data now
    sql("SELECT * FROM hive_records").show()
    // +---+-------+
    // |key|  value|
    // +---+-------+
    // |238|val_238|
    // | 86| val_86|
    // |311|val_311|
    // ...

    // Prepare a Parquet data directory
    val dataDir = "/tmp/parquet_data"
    spark.range(10).write.parquet(dataDir)
    // Create a Hive external Parquet table
    sql(s"CREATE EXTERNAL TABLE hive_ints(key int) STORED AS PARQUET LOCATION '$dataDir'")
    // The Hive external table should already have data
    sql("SELECT * FROM hive_ints").show()
    // +---+
    // |key|
    // +---+
    // |  0|
    // |  1|
    // |  2|
    // ...

    // Turn on flag for Hive Dynamic Partitioning
    spark.sqlContext.setConf("hive.exec.dynamic.partition", "true")
    spark.sqlContext.setConf("hive.exec.dynamic.partition.mode", "nonstrict")
    // Create a Hive partitioned table using DataFrame API
    df.write.partitionBy("key").format("hive").saveAsTable("hive_part_tbl")
    // Partitioned column `key` will be moved to the end of the schema.
    sql("SELECT * FROM hive_part_tbl").show()
    // +-------+---+
    // |  value|key|
    // +-------+---+
    // |val_238|238|
    // | val_86| 86|
    // |val_311|311|
    // ...

    spark.stop()
    // $example off:spark_hive$
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.spark.examples.sql

// $example on:typed_custom_aggregation$
import org.apache.spark.sql.{Encoder, Encoders, SparkSession}
import org.apache.spark.sql.expressions.Aggregator
// $example off:typed_custom_aggregation$

object UserDefinedTypedAggregation {

  // $example on:typed_custom_aggregation$
  case class Employee(name: String, salary: Long)
  case class Average(var sum: Long, var count: Long)

  object MyAverage extends Aggregator[Employee, Average, Double] {
    // A zero value for this aggregation. Should satisfy the property that any b + zero = b
    def zero: Average = Average(0L, 0L)
    // Combine two values to produce a new value. For performance, the function may modify `buffer`
    // and return it instead of constructing a new object
    def reduce(buffer: Average, employee: Employee): Average = {
      buffer.sum += employee.salary
      buffer.count += 1
      buffer
    }
    // Merge two intermediate values
    def merge(b1: Average, b2: Average): Average = {
      b1.sum += b2.sum
      b1.count += b2.count
      b1
    }
    // Transform the output of the reduction
    def finish(reduction: Average): Double = reduction.sum.toDouble / reduction.count
    // Specifies the Encoder for the intermediate value type
    def bufferEncoder: Encoder[Average] = Encoders.product
    // Specifies the Encoder for the final output value type
    def outputEncoder: Encoder[Double] = Encoders.scalaDouble
  }
  // $example off:typed_custom_aggregation$

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      .appName("Spark SQL user-defined Datasets aggregation example")
      .getOrCreate()

    import spark.implicits._

    // $example on:typed_custom_aggregation$
    val ds = spark.read.json("examples/src/main/resources/employees.json").as[Employee]
    ds.show()
    // +-------+------+
    // |   name|salary|
    // +-------+------+
    // |Michael|  3000|
    // |   Andy|  4500|
    // | Justin|  3500|
    // |  Berta|  4000|
    // +-------+------+

    // Convert the function to a `TypedColumn` and give it a name
    val averageSalary = MyAverage.toColumn.name("average_salary")
    val result = ds.select(averageSalary)
    result.show()
    // +--------------+
    // |average_salary|
    // +--------------+
    // |        3750.0|
    // +--------------+
    // $example off:typed_custom_aggregation$

    spark.stop()
  }

}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.spark.examples.sql

// $example on:untyped_custom_aggregation$
import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.expressions.MutableAggregationBuffer
import org.apache.spark.sql.expressions.UserDefinedAggregateFunction
import org.apache.spark.sql.types._
// $example off:untyped_custom_aggregation$

object UserDefinedUntypedAggregation {

  // $example on:untyped_custom_aggregation$
  object MyAverage extends UserDefinedAggregateFunction {
    // Data types of input arguments of this aggregate function
    def inputSchema: StructType = StructType(StructField("inputColumn", LongType) :: Nil)
    // Data types of values in the aggregation buffer
    def bufferSchema: StructType = {
      StructType(StructField("sum", LongType) :: StructField("count", LongType) :: Nil)
    }
    // The data type of the returned value
    def dataType: DataType = DoubleType
    // Whether this function always returns the same output on the identical input
    def deterministic: Boolean = true
    // Initializes the given aggregation buffer. The buffer itself is a `Row` that in addition to
    // standard methods like retrieving a value at an index (e.g., get(), getBoolean()), provides
    // the opportunity to update its values. Note that arrays and maps inside the buffer are still
    // immutable.
    def initialize(buffer: MutableAggregationBuffer): Unit = {
      buffer(0) = 0L
      buffer(1) = 0L
    }
    // Updates the given aggregation buffer `buffer` with new input data from `input`
    def update(buffer: MutableAggregationBuffer, input: Row): Unit = {
      if (!input.isNullAt(0)) {
        buffer(0) = buffer.getLong(0) + input.getLong(0)
        buffer(1) = buffer.getLong(1) + 1
      }
    }
    // Merges two aggregation buffers and stores the updated buffer values back to `buffer1`
    def merge(buffer1: MutableAggregationBuffer, buffer2: Row): Unit = {
      buffer1(0) = buffer1.getLong(0) + buffer2.getLong(0)
      buffer1(1) = buffer1.getLong(1) + buffer2.getLong(1)
    }
    // Calculates the final result
    def evaluate(buffer: Row): Double = buffer.getLong(0).toDouble / buffer.getLong(1)
  }
  // $example off:untyped_custom_aggregation$

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      .appName("Spark SQL user-defined DataFrames aggregation example")
      .getOrCreate()

    // $example on:untyped_custom_aggregation$
    // Register the function to access it
    spark.udf.register("myAverage", MyAverage)

    val df = spark.read.json("examples/src/main/resources/employees.json")
    df.createOrReplaceTempView("employees")
    df.show()
    // +-------+------+
    // |   name|salary|
    // +-------+------+
    // |Michael|  3000|
    // |   Andy|  4500|
    // | Justin|  3500|
    // |  Berta|  4000|
    // +-------+------+

    val result = spark.sql("SELECT myAverage(salary) as average_salary FROM employees")
    result.show()
    // +--------------+
    // |average_salary|
    // +--------------+
    // |        3750.0|
    // +--------------+
    // $example off:untyped_custom_aggregation$

    spark.stop()
  }

}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.sql

import org.apache.spark.sql.{Encoder, Encoders, SparkSession}
import org.apache.spark.sql.expressions.Aggregator

// scalastyle:off println
object SimpleTypedAggregator {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .master("local")
      .appName("common typed aggregator implementations")
      .getOrCreate()

    import spark.implicits._
    val ds = spark.range(20).select(('id % 3).as("key"), 'id).as[(Long, Long)]
    println("input data:")
    ds.show()

    println("running typed sum:")
    ds.groupByKey(_._1).agg(new TypedSum[(Long, Long)](_._2).toColumn).show()

    println("running typed count:")
    ds.groupByKey(_._1).agg(new TypedCount[(Long, Long)](_._2).toColumn).show()

    println("running typed average:")
    ds.groupByKey(_._1).agg(new TypedAverage[(Long, Long)](_._2.toDouble).toColumn).show()

    println("running typed minimum:")
    ds.groupByKey(_._1).agg(new TypedMin[(Long, Long)](_._2.toDouble).toColumn).show()

    println("running typed maximum:")
    ds.groupByKey(_._1).agg(new TypedMax[(Long, Long)](_._2).toColumn).show()

    spark.stop()
  }
}
// scalastyle:on println

class TypedSum[IN](val f: IN => Long) extends Aggregator[IN, Long, Long] {
  override def zero: Long = 0L
  override def reduce(b: Long, a: IN): Long = b + f(a)
  override def merge(b1: Long, b2: Long): Long = b1 + b2
  override def finish(reduction: Long): Long = reduction

  override def bufferEncoder: Encoder[Long] = Encoders.scalaLong
  override def outputEncoder: Encoder[Long] = Encoders.scalaLong
}

class TypedCount[IN](val f: IN => Any) extends Aggregator[IN, Long, Long] {
  override def zero: Long = 0
  override def reduce(b: Long, a: IN): Long = {
    if (f(a) == null) b else b + 1
  }
  override def merge(b1: Long, b2: Long): Long = b1 + b2
  override def finish(reduction: Long): Long = reduction

  override def bufferEncoder: Encoder[Long] = Encoders.scalaLong
  override def outputEncoder: Encoder[Long] = Encoders.scalaLong
}

class TypedAverage[IN](val f: IN => Double) extends Aggregator[IN, (Double, Long), Double] {
  override def zero: (Double, Long) = (0.0, 0L)
  override def reduce(b: (Double, Long), a: IN): (Double, Long) = (f(a) + b._1, 1 + b._2)
  override def finish(reduction: (Double, Long)): Double = reduction._1 / reduction._2
  override def merge(b1: (Double, Long), b2: (Double, Long)): (Double, Long) = {
    (b1._1 + b2._1, b1._2 + b2._2)
  }

  override def bufferEncoder: Encoder[(Double, Long)] = {
    Encoders.tuple(Encoders.scalaDouble, Encoders.scalaLong)
  }
  override def outputEncoder: Encoder[Double] = Encoders.scalaDouble
}

class TypedMin[IN](val f: IN => Double) extends Aggregator[IN, MutableDouble, Option[Double]] {
  override def zero: MutableDouble = null
  override def reduce(b: MutableDouble, a: IN): MutableDouble = {
    if (b == null) {
      new MutableDouble(f(a))
    } else {
      b.value = math.min(b.value, f(a))
      b
    }
  }
  override def merge(b1: MutableDouble, b2: MutableDouble): MutableDouble = {
    if (b1 == null) {
      b2
    } else if (b2 == null) {
      b1
    } else {
      b1.value = math.min(b1.value, b2.value)
      b1
    }
  }
  override def finish(reduction: MutableDouble): Option[Double] = {
    if (reduction != null) {
      Some(reduction.value)
    } else {
      None
    }
  }

  override def bufferEncoder: Encoder[MutableDouble] = Encoders.kryo[MutableDouble]
  override def outputEncoder: Encoder[Option[Double]] = Encoders.product[Option[Double]]
}

class TypedMax[IN](val f: IN => Long) extends Aggregator[IN, MutableLong, Option[Long]] {
  override def zero: MutableLong = null
  override def reduce(b: MutableLong, a: IN): MutableLong = {
    if (b == null) {
      new MutableLong(f(a))
    } else {
      b.value = math.max(b.value, f(a))
      b
    }
  }
  override def merge(b1: MutableLong, b2: MutableLong): MutableLong = {
    if (b1 == null) {
      b2
    } else if (b2 == null) {
      b1
    } else {
      b1.value = math.max(b1.value, b2.value)
      b1
    }
  }
  override def finish(reduction: MutableLong): Option[Long] = {
    if (reduction != null) {
      Some(reduction.value)
    } else {
      None
    }
  }

  override def bufferEncoder: Encoder[MutableLong] = Encoders.kryo[MutableLong]
  override def outputEncoder: Encoder[Option[Long]] = Encoders.product[Option[Long]]
}

class MutableLong(var value: Long) extends Serializable

class MutableDouble(var value: Double) extends Serializable
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.sql

import org.apache.spark.sql.SaveMode
// $example on:init_session$
import org.apache.spark.sql.SparkSession
// $example off:init_session$

// One method for defining the schema of an RDD is to make a case class with the desired column
// names and types.
case class Record(key: Int, value: String)

object RDDRelation {
  def main(args: Array[String]) {
    // $example on:init_session$
    val spark = SparkSession
      .builder
      .appName("Spark Examples")
      .config("spark.some.config.option", "some-value")
      .getOrCreate()

    // Importing the SparkSession gives access to all the SQL functions and implicit conversions.
    import spark.implicits._
    // $example off:init_session$

    val df = spark.createDataFrame((1 to 100).map(i => Record(i, s"val_$i")))
    // Any RDD containing case classes can be used to create a temporary view.  The schema of the
    // view is automatically inferred using scala reflection.
    df.createOrReplaceTempView("records")

    // Once tables have been registered, you can run SQL queries over them.
    println("Result of SELECT *:")
    spark.sql("SELECT * FROM records").collect().foreach(println)

    // Aggregation queries are also supported.
    val count = spark.sql("SELECT COUNT(*) FROM records").collect().head.getLong(0)
    println(s"COUNT(*): $count")

    // The results of SQL queries are themselves RDDs and support all normal RDD functions. The
    // items in the RDD are of type Row, which allows you to access each column by ordinal.
    val rddFromSql = spark.sql("SELECT key, value FROM records WHERE key < 10")

    println("Result of RDD.map:")
    rddFromSql.rdd.map(row => s"Key: ${row(0)}, Value: ${row(1)}").collect().foreach(println)

    // Queries can also be written using a LINQ-like Scala DSL.
    df.where($"key" === 1).orderBy($"value".asc).select($"key").collect().foreach(println)

    // Write out an RDD as a parquet file with overwrite mode.
    df.write.mode(SaveMode.Overwrite).parquet("pair.parquet")

    // Read in parquet file.  Parquet files are self-describing so the schema is preserved.
    val parquetFile = spark.read.parquet("pair.parquet")

    // Queries can be run using the DSL on parquet files just like the original RDD.
    parquetFile.where($"key" === 1).select($"value".as("a")).collect().foreach(println)

    // These files can also be used to create a temporary view.
    parquetFile.createOrReplaceTempView("parquetFile")
    spark.sql("SELECT * FROM parquetFile").collect().foreach(println)

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.spark.examples.sql

// $example on:programmatic_schema$
import org.apache.spark.sql.Row
// $example off:programmatic_schema$
// $example on:init_session$
import org.apache.spark.sql.SparkSession
// $example off:init_session$
// $example on:programmatic_schema$
// $example on:data_types$
import org.apache.spark.sql.types._
// $example off:data_types$
// $example off:programmatic_schema$

object SparkSQLExample {

  // $example on:create_ds$
  case class Person(name: String, age: Long)
  // $example off:create_ds$

  def main(args: Array[String]) {
    // $example on:init_session$
    val spark = SparkSession
      .builder()
      .appName("Spark SQL basic example")
      .config("spark.some.config.option", "some-value")
      .getOrCreate()

    // For implicit conversions like converting RDDs to DataFrames
    import spark.implicits._
    // $example off:init_session$

    runBasicDataFrameExample(spark)
    runDatasetCreationExample(spark)
    runInferSchemaExample(spark)
    runProgrammaticSchemaExample(spark)

    spark.stop()
  }

  private def runBasicDataFrameExample(spark: SparkSession): Unit = {
    // $example on:create_df$
    val df = spark.read.json("examples/src/main/resources/people.json")

    // Displays the content of the DataFrame to stdout
    df.show()
    // +----+-------+
    // | age|   name|
    // +----+-------+
    // |null|Michael|
    // |  30|   Andy|
    // |  19| Justin|
    // +----+-------+
    // $example off:create_df$

    // $example on:untyped_ops$
    // This import is needed to use the $-notation
    import spark.implicits._
    // Print the schema in a tree format
    df.printSchema()
    // root
    // |-- age: long (nullable = true)
    // |-- name: string (nullable = true)

    // Select only the "name" column
    df.select("name").show()
    // +-------+
    // |   name|
    // +-------+
    // |Michael|
    // |   Andy|
    // | Justin|
    // +-------+

    // Select everybody, but increment the age by 1
    df.select($"name", $"age" + 1).show()
    // +-------+---------+
    // |   name|(age + 1)|
    // +-------+---------+
    // |Michael|     null|
    // |   Andy|       31|
    // | Justin|       20|
    // +-------+---------+

    // Select people older than 21
    df.filter($"age" > 21).show()
    // +---+----+
    // |age|name|
    // +---+----+
    // | 30|Andy|
    // +---+----+

    // Count people by age
    df.groupBy("age").count().show()
    // +----+-----+
    // | age|count|
    // +----+-----+
    // |  19|    1|
    // |null|    1|
    // |  30|    1|
    // +----+-----+
    // $example off:untyped_ops$

    // $example on:run_sql$
    // Register the DataFrame as a SQL temporary view
    df.createOrReplaceTempView("people")

    val sqlDF = spark.sql("SELECT * FROM people")
    sqlDF.show()
    // +----+-------+
    // | age|   name|
    // +----+-------+
    // |null|Michael|
    // |  30|   Andy|
    // |  19| Justin|
    // +----+-------+
    // $example off:run_sql$

    // $example on:global_temp_view$
    // Register the DataFrame as a global temporary view
    df.createGlobalTempView("people")

    // Global temporary view is tied to a system preserved database `global_temp`
    spark.sql("SELECT * FROM global_temp.people").show()
    // +----+-------+
    // | age|   name|
    // +----+-------+
    // |null|Michael|
    // |  30|   Andy|
    // |  19| Justin|
    // +----+-------+

    // Global temporary view is cross-session
    spark.newSession().sql("SELECT * FROM global_temp.people").show()
    // +----+-------+
    // | age|   name|
    // +----+-------+
    // |null|Michael|
    // |  30|   Andy|
    // |  19| Justin|
    // +----+-------+
    // $example off:global_temp_view$
  }

  private def runDatasetCreationExample(spark: SparkSession): Unit = {
    import spark.implicits._
    // $example on:create_ds$
    // Encoders are created for case classes
    val caseClassDS = Seq(Person("Andy", 32)).toDS()
    caseClassDS.show()
    // +----+---+
    // |name|age|
    // +----+---+
    // |Andy| 32|
    // +----+---+

    // Encoders for most common types are automatically provided by importing spark.implicits._
    val primitiveDS = Seq(1, 2, 3).toDS()
    primitiveDS.map(_ + 1).collect() // Returns: Array(2, 3, 4)

    // DataFrames can be converted to a Dataset by providing a class. Mapping will be done by name
    val path = "examples/src/main/resources/people.json"
    val peopleDS = spark.read.json(path).as[Person]
    peopleDS.show()
    // +----+-------+
    // | age|   name|
    // +----+-------+
    // |null|Michael|
    // |  30|   Andy|
    // |  19| Justin|
    // +----+-------+
    // $example off:create_ds$
  }

  private def runInferSchemaExample(spark: SparkSession): Unit = {
    // $example on:schema_inferring$
    // For implicit conversions from RDDs to DataFrames
    import spark.implicits._

    // Create an RDD of Person objects from a text file, convert it to a Dataframe
    val peopleDF = spark.sparkContext
      .textFile("examples/src/main/resources/people.txt")
      .map(_.split(","))
      .map(attributes => Person(attributes(0), attributes(1).trim.toInt))
      .toDF()
    // Register the DataFrame as a temporary view
    peopleDF.createOrReplaceTempView("people")

    // SQL statements can be run by using the sql methods provided by Spark
    val teenagersDF = spark.sql("SELECT name, age FROM people WHERE age BETWEEN 13 AND 19")

    // The columns of a row in the result can be accessed by field index
    teenagersDF.map(teenager => "Name: " + teenager(0)).show()
    // +------------+
    // |       value|
    // +------------+
    // |Name: Justin|
    // +------------+

    // or by field name
    teenagersDF.map(teenager => "Name: " + teenager.getAs[String]("name")).show()
    // +------------+
    // |       value|
    // +------------+
    // |Name: Justin|
    // +------------+

    // No pre-defined encoders for Dataset[Map[K,V]], define explicitly
    implicit val mapEncoder = org.apache.spark.sql.Encoders.kryo[Map[String, Any]]
    // Primitive types and case classes can be also defined as
    // implicit val stringIntMapEncoder: Encoder[Map[String, Any]] = ExpressionEncoder()

    // row.getValuesMap[T] retrieves multiple columns at once into a Map[String, T]
    teenagersDF.map(teenager => teenager.getValuesMap[Any](List("name", "age"))).collect()
    // Array(Map("name" -> "Justin", "age" -> 19))
    // $example off:schema_inferring$
  }

  private def runProgrammaticSchemaExample(spark: SparkSession): Unit = {
    import spark.implicits._
    // $example on:programmatic_schema$
    // Create an RDD
    val peopleRDD = spark.sparkContext.textFile("examples/src/main/resources/people.txt")

    // The schema is encoded in a string
    val schemaString = "name age"

    // Generate the schema based on the string of schema
    val fields = schemaString.split(" ")
      .map(fieldName => StructField(fieldName, StringType, nullable = true))
    val schema = StructType(fields)

    // Convert records of the RDD (people) to Rows
    val rowRDD = peopleRDD
      .map(_.split(","))
      .map(attributes => Row(attributes(0), attributes(1).trim))

    // Apply the schema to the RDD
    val peopleDF = spark.createDataFrame(rowRDD, schema)

    // Creates a temporary view using the DataFrame
    peopleDF.createOrReplaceTempView("people")

    // SQL can be run over a temporary view created using DataFrames
    val results = spark.sql("SELECT name FROM people")

    // The results of SQL queries are DataFrames and support all the normal RDD operations
    // The columns of a row in the result can be accessed by field index or by field name
    results.map(attributes => "Name: " + attributes(0)).show()
    // +-------------+
    // |        value|
    // +-------------+
    // |Name: Michael|
    // |   Name: Andy|
    // | Name: Justin|
    // +-------------+
    // $example off:programmatic_schema$
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.io.File

import org.apache.spark.SparkFiles
import org.apache.spark.sql.SparkSession

/** Usage: SparkRemoteFileTest [file] */
object SparkRemoteFileTest {
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("Usage: SparkRemoteFileTest <file>")
      System.exit(1)
    }
    val spark = SparkSession
      .builder()
      .appName("SparkRemoteFileTest")
      .getOrCreate()
    val sc = spark.sparkContext
    val rdd = sc.parallelize(Seq(1)).map(_ => {
      val localLocation = SparkFiles.get(args(0))
      println(s"${args(0)} is stored at: $localLocation")
      new File(localLocation).isFile
    })
    val truthCheck = rdd.collect().head
    println(s"Mounting of ${args(0)} was $truthCheck")
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.spark.sql.SparkSession

/**
 * Usage: BroadcastTest [partitions] [numElem] [blockSize]
 */
object BroadcastTest {
  def main(args: Array[String]) {

    val blockSize = if (args.length > 2) args(2) else "4096"

    val spark = SparkSession
      .builder()
      .appName("Broadcast Test")
      .config("spark.broadcast.blockSize", blockSize)
      .getOrCreate()

    val sc = spark.sparkContext

    val slices = if (args.length > 0) args(0).toInt else 2
    val num = if (args.length > 1) args(1).toInt else 1000000

    val arr1 = (0 until num).toArray

    for (i <- 0 until 3) {
      println(s"Iteration $i")
      println("===========")
      val startTime = System.nanoTime
      val barr1 = sc.broadcast(arr1)
      val observedSizes = sc.parallelize(1 to 10, slices).map(_ => barr1.value.length)
      // Collect the small RDD so we can print the observed sizes locally.
      observedSizes.collect().foreach(i => println(i))
      println("Iteration %d took %.0f milliseconds".format(i, (System.nanoTime - startTime) / 1E6))
    }

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.StringDeserializer

import org.apache.spark.SparkConf
import org.apache.spark.streaming._
import org.apache.spark.streaming.kafka010._

/**
 * Consumes messages from one or more topics in Kafka and does wordcount.
 * Usage: DirectKafkaWordCount <brokers> <topics>
 *   <brokers> is a list of one or more Kafka brokers
 *   <groupId> is a consumer group name to consume from topics
 *   <topics> is a list of one or more kafka topics to consume from
 *
 * Example:
 *    $ bin/run-example streaming.DirectKafkaWordCount broker1-host:port,broker2-host:port \
 *    consumer-group topic1,topic2
 */
object DirectKafkaWordCount {
  def main(args: Array[String]) {
    if (args.length < 3) {
      System.err.println(s"""
        |Usage: DirectKafkaWordCount <brokers> <topics>
        |  <brokers> is a list of one or more Kafka brokers
        |  <groupId> is a consumer group name to consume from topics
        |  <topics> is a list of one or more kafka topics to consume from
        |
        """.stripMargin)
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    val Array(brokers, groupId, topics) = args

    // Create context with 2 second batch interval
    val sparkConf = new SparkConf().setAppName("DirectKafkaWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(2))

    // Create direct kafka stream with brokers and topics
    val topicsSet = topics.split(",").toSet
    val kafkaParams = Map[String, Object](
      ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG -> brokers,
      ConsumerConfig.GROUP_ID_CONFIG -> groupId,
      ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG -> classOf[StringDeserializer],
      ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG -> classOf[StringDeserializer])
    val messages = KafkaUtils.createDirectStream[String, String](
      ssc,
      LocationStrategies.PreferConsistent,
      ConsumerStrategies.Subscribe[String, String](topicsSet, kafkaParams))

    // Get the lines, split them into words, count the words and print
    val lines = messages.map(_.value)
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x, 1L)).reduceByKey(_ + _)
    wordCounts.print()

    // Start the computation
    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import org.apache.spark.SparkConf
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming._
import org.apache.spark.util.IntParam

/**
 * Receives text from multiple rawNetworkStreams and counts how many '\n' delimited
 * lines have the word 'the' in them. This is useful for benchmarking purposes. This
 * will only work with spark.streaming.util.RawTextSender running on all worker nodes
 * and with Spark using Kryo serialization (set Java property "spark.serializer" to
 * "org.apache.spark.serializer.KryoSerializer").
 * Usage: RawNetworkGrep <numStreams> <host> <port> <batchMillis>
 *   <numStream> is the number rawNetworkStreams, which should be same as number
 *               of work nodes in the cluster
 *   <host> is "localhost".
 *   <port> is the port on which RawTextSender is running in the worker nodes.
 *   <batchMillise> is the Spark Streaming batch duration in milliseconds.
 */
object RawNetworkGrep {
  def main(args: Array[String]) {
    if (args.length != 4) {
      System.err.println("Usage: RawNetworkGrep <numStreams> <host> <port> <batchMillis>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    val Array(IntParam(numStreams), host, IntParam(port), IntParam(batchMillis)) = args
    val sparkConf = new SparkConf().setAppName("RawNetworkGrep")
    // Create the context
    val ssc = new StreamingContext(sparkConf, Duration(batchMillis))

    val rawStreams = (1 to numStreams).map(_ =>
      ssc.rawSocketStream[String](host, port, StorageLevel.MEMORY_ONLY_SER_2)).toArray
    val union = ssc.union(rawStreams)
    union.filter(_.contains("the")).count().foreachRDD(r =>
      println(s"Grep count: ${r.collect().mkString}"))
    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import org.apache.spark.SparkConf
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext}

/**
 * Counts words in UTF8 encoded, '\n' delimited text received from the network every second.
 *
 * Usage: NetworkWordCount <hostname> <port>
 * <hostname> and <port> describe the TCP server that Spark Streaming would connect to receive data.
 *
 * To run this on your local machine, you need to first run a Netcat server
 *    `$ nc -lk 9999`
 * and then run the example
 *    `$ bin/run-example org.apache.spark.examples.streaming.NetworkWordCount localhost 9999`
 */
object NetworkWordCount {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: NetworkWordCount <hostname> <port>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    // Create the context with a 1 second batch size
    val sparkConf = new SparkConf().setAppName("NetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(1))

    // Create a socket stream on target ip:port and count the
    // words in input stream of \n delimited text (eg. generated by 'nc')
    // Note that no duplication in storage level only for running locally.
    // Replication necessary in distributed scenario for fault tolerance.
    val lines = ssc.socketTextStream(args(0), args(1).toInt, StorageLevel.MEMORY_AND_DISK_SER)
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x, 1)).reduceByKey(_ + _)
    wordCounts.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import org.apache.spark.SparkConf
import org.apache.spark.streaming.{Seconds, StreamingContext}

/**
 * Counts words in new text files created in the given directory
 * Usage: HdfsWordCount <directory>
 *   <directory> is the directory that Spark Streaming will use to find and read new text files.
 *
 * To run this on your local machine on directory `localdir`, run this example
 *    $ bin/run-example \
 *       org.apache.spark.examples.streaming.HdfsWordCount localdir
 *
 * Then create a text file in `localdir` and the words in the file will get counted.
 */
object HdfsWordCount {
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("Usage: HdfsWordCount <directory>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()
    val sparkConf = new SparkConf().setAppName("HdfsWordCount")
    // Create the context
    val ssc = new StreamingContext(sparkConf, Seconds(2))

    // Create the FileInputDStream on the directory and use the
    // stream to count words in new files created
    val lines = ssc.textFileStream(args(0))
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x, 1)).reduceByKey(_ + _)
    wordCounts.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import java.io.File
import java.nio.charset.Charset

import com.google.common.io.Files

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.broadcast.Broadcast
import org.apache.spark.rdd.RDD
import org.apache.spark.streaming.{Seconds, StreamingContext, Time}
import org.apache.spark.util.{IntParam, LongAccumulator}

/**
 * Use this singleton to get or register a Broadcast variable.
 */
object WordBlacklist {

  @volatile private var instance: Broadcast[Seq[String]] = null

  def getInstance(sc: SparkContext): Broadcast[Seq[String]] = {
    if (instance == null) {
      synchronized {
        if (instance == null) {
          val wordBlacklist = Seq("a", "b", "c")
          instance = sc.broadcast(wordBlacklist)
        }
      }
    }
    instance
  }
}

/**
 * Use this singleton to get or register an Accumulator.
 */
object DroppedWordsCounter {

  @volatile private var instance: LongAccumulator = null

  def getInstance(sc: SparkContext): LongAccumulator = {
    if (instance == null) {
      synchronized {
        if (instance == null) {
          instance = sc.longAccumulator("WordsInBlacklistCounter")
        }
      }
    }
    instance
  }
}

/**
 * Counts words in text encoded with UTF8 received from the network every second. This example also
 * shows how to use lazily instantiated singleton instances for Accumulator and Broadcast so that
 * they can be registered on driver failures.
 *
 * Usage: RecoverableNetworkWordCount <hostname> <port> <checkpoint-directory> <output-file>
 *   <hostname> and <port> describe the TCP server that Spark Streaming would connect to receive
 *   data. <checkpoint-directory> directory to HDFS-compatible file system which checkpoint data
 *   <output-file> file to which the word counts will be appended
 *
 * <checkpoint-directory> and <output-file> must be absolute paths
 *
 * To run this on your local machine, you need to first run a Netcat server
 *
 *      `$ nc -lk 9999`
 *
 * and run the example as
 *
 *      `$ ./bin/run-example org.apache.spark.examples.streaming.RecoverableNetworkWordCount \
 *              localhost 9999 ~/checkpoint/ ~/out`
 *
 * If the directory ~/checkpoint/ does not exist (e.g. running for the first time), it will create
 * a new StreamingContext (will print "Creating new context" to the console). Otherwise, if
 * checkpoint data exists in ~/checkpoint/, then it will create StreamingContext from
 * the checkpoint data.
 *
 * Refer to the online documentation for more details.
 */
object RecoverableNetworkWordCount {

  def createContext(ip: String, port: Int, outputPath: String, checkpointDirectory: String)
    : StreamingContext = {

    // If you do not see this printed, that means the StreamingContext has been loaded
    // from the new checkpoint
    println("Creating new context")
    val outputFile = new File(outputPath)
    if (outputFile.exists()) outputFile.delete()
    val sparkConf = new SparkConf().setAppName("RecoverableNetworkWordCount")
    // Create the context with a 1 second batch size
    val ssc = new StreamingContext(sparkConf, Seconds(1))
    ssc.checkpoint(checkpointDirectory)

    // Create a socket stream on target ip:port and count the
    // words in input stream of \n delimited text (eg. generated by 'nc')
    val lines = ssc.socketTextStream(ip, port)
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map((_, 1)).reduceByKey(_ + _)
    wordCounts.foreachRDD { (rdd: RDD[(String, Int)], time: Time) =>
      // Get or register the blacklist Broadcast
      val blacklist = WordBlacklist.getInstance(rdd.sparkContext)
      // Get or register the droppedWordsCounter Accumulator
      val droppedWordsCounter = DroppedWordsCounter.getInstance(rdd.sparkContext)
      // Use blacklist to drop words and use droppedWordsCounter to count them
      val counts = rdd.filter { case (word, count) =>
        if (blacklist.value.contains(word)) {
          droppedWordsCounter.add(count)
          false
        } else {
          true
        }
      }.collect().mkString("[", ", ", "]")
      val output = s"Counts at time $time $counts"
      println(output)
      println(s"Dropped ${droppedWordsCounter.value} word(s) totally")
      println(s"Appending to ${outputFile.getAbsolutePath}")
      Files.append(output + "\n", outputFile, Charset.defaultCharset())
    }
    ssc
  }

  def main(args: Array[String]) {
    if (args.length != 4) {
      System.err.println(s"Your arguments were ${args.mkString("[", ", ", "]")}")
      System.err.println(
        """
          |Usage: RecoverableNetworkWordCount <hostname> <port> <checkpoint-directory>
          |     <output-file>. <hostname> and <port> describe the TCP server that Spark
          |     Streaming would connect to receive data. <checkpoint-directory> directory to
          |     HDFS-compatible file system which checkpoint data <output-file> file to which the
          |     word counts will be appended
          |
          |In local mode, <master> should be 'local[n]' with n > 1
          |Both <checkpoint-directory> and <output-file> must be absolute paths
        """.stripMargin
      )
      System.exit(1)
    }
    val Array(ip, IntParam(port), checkpointDirectory, outputPath) = args
    val ssc = StreamingContext.getOrCreate(checkpointDirectory,
      () => createContext(ip, port, outputPath, checkpointDirectory))
    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import java.io.{BufferedReader, InputStreamReader}
import java.net.Socket
import java.nio.charset.StandardCharsets

import org.apache.spark.SparkConf
import org.apache.spark.internal.Logging
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.streaming.receiver.Receiver

/**
 * Custom Receiver that receives data over a socket. Received bytes are interpreted as
 * text and \n delimited lines are considered as records. They are then counted and printed.
 *
 * To run this on your local machine, you need to first run a Netcat server
 *    `$ nc -lk 9999`
 * and then run the example
 *    `$ bin/run-example org.apache.spark.examples.streaming.CustomReceiver localhost 9999`
 */
object CustomReceiver {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: CustomReceiver <hostname> <port>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    // Create the context with a 1 second batch size
    val sparkConf = new SparkConf().setAppName("CustomReceiver")
    val ssc = new StreamingContext(sparkConf, Seconds(1))

    // Create an input stream with the custom receiver on target ip:port and count the
    // words in input stream of \n delimited text (eg. generated by 'nc')
    val lines = ssc.receiverStream(new CustomReceiver(args(0), args(1).toInt))
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x, 1)).reduceByKey(_ + _)
    wordCounts.print()
    ssc.start()
    ssc.awaitTermination()
  }
}


class CustomReceiver(host: String, port: Int)
  extends Receiver[String](StorageLevel.MEMORY_AND_DISK_2) with Logging {

  def onStart() {
    // Start the thread that receives data over a connection
    new Thread("Socket Receiver") {
      override def run() { receive() }
    }.start()
  }

  def onStop() {
   // There is nothing much to do as the thread calling receive()
   // is designed to stop by itself isStopped() returns false
  }

  /** Create a socket connection and receive data until receiver is stopped */
  private def receive() {
   var socket: Socket = null
   var userInput: String = null
   try {
     logInfo(s"Connecting to $host : $port")
     socket = new Socket(host, port)
     logInfo(s"Connected to $host : $port")
     val reader = new BufferedReader(
       new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8))
     userInput = reader.readLine()
     while(!isStopped && userInput != null) {
       store(userInput)
       userInput = reader.readLine()
     }
     reader.close()
     socket.close()
     logInfo("Stopped receiving")
     restart("Trying to connect again")
   } catch {
     case e: java.net.ConnectException =>
       restart(s"Error connecting to $host : $port", e)
     case t: Throwable =>
       restart("Error receiving data", t)
   }
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.streaming

import org.apache.log4j.{Level, Logger}

import org.apache.spark.internal.Logging

/** Utility functions for Spark Streaming examples. */
object StreamingExamples extends Logging {

  /** Set reasonable logging levels for streaming if the user has not configured log4j. */
  def setStreamingLogLevels() {
    val log4jInitialized = Logger.getRootLogger.getAllAppenders.hasMoreElements
    if (!log4jInitialized) {
      // We first log something to initialize Spark's default logging, then we override the
      // logging level.
      logInfo("Setting log level to [WARN] for streaming example." +
        " To override add a custom log4j.properties to the classpath.")
      Logger.getRootLogger.setLevel(Level.WARN)
    }
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming.clickstream

import java.io.PrintWriter
import java.net.ServerSocket
import java.util.Random

/** Represents a page view on a website with associated dimension data. */
class PageView(val url: String, val status: Int, val zipCode: Int, val userID: Int)
    extends Serializable {
  override def toString(): String = {
    "%s\t%s\t%s\t%s\n".format(url, status, zipCode, userID)
  }
}

object PageView extends Serializable {
  def fromString(in: String): PageView = {
    val parts = in.split("\t")
    new PageView(parts(0), parts(1).toInt, parts(2).toInt, parts(3).toInt)
  }
}

// scalastyle:off
/**
 * Generates streaming events to simulate page views on a website.
 *
 * This should be used in tandem with PageViewStream.scala. Example:
 *
 * To run the generator
 * `$ bin/run-example org.apache.spark.examples.streaming.clickstream.PageViewGenerator 44444 10`
 * To process the generated stream
 * `$ bin/run-example \
 *    org.apache.spark.examples.streaming.clickstream.PageViewStream errorRatePerZipCode localhost 44444`
 *
 */
// scalastyle:on
object PageViewGenerator {
  val pages = Map("http://foo.com/" -> .7,
                  "http://foo.com/news" -> 0.2,
                  "http://foo.com/contact" -> .1)
  val httpStatus = Map(200 -> .95,
                       404 -> .05)
  val userZipCode = Map(94709 -> .5,
                        94117 -> .5)
  val userID = Map((1 to 100).map(_ -> .01): _*)

  def pickFromDistribution[T](inputMap: Map[T, Double]): T = {
    val rand = new Random().nextDouble()
    var total = 0.0
    for ((item, prob) <- inputMap) {
      total = total + prob
      if (total > rand) {
        return item
      }
    }
    inputMap.take(1).head._1 // Shouldn't get here if probabilities add up to 1.0
  }

  def getNextClickEvent(): String = {
    val id = pickFromDistribution(userID)
    val page = pickFromDistribution(pages)
    val status = pickFromDistribution(httpStatus)
    val zipCode = pickFromDistribution(userZipCode)
    new PageView(page, status, zipCode, id).toString()
  }

  def main(args: Array[String]) {
    if (args.length != 2) {
      System.err.println("Usage: PageViewGenerator <port> <viewsPerSecond>")
      System.exit(1)
    }
    val port = args(0).toInt
    val viewsPerSecond = args(1).toFloat
    val sleepDelayMs = (1000.0 / viewsPerSecond).toInt
    val listener = new ServerSocket(port)
    println(s"Listening on port: $port")

    while (true) {
      val socket = listener.accept()
      new Thread() {
        override def run(): Unit = {
          println(s"Got client connected from: ${socket.getInetAddress}")
          val out = new PrintWriter(socket.getOutputStream(), true)

          while (true) {
            Thread.sleep(sleepDelayMs)
            out.write(getNextClickEvent())
            out.flush()
          }
          socket.close()
        }
      }.start()
    }
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming.clickstream

import org.apache.spark.examples.streaming.StreamingExamples
import org.apache.spark.streaming.{Seconds, StreamingContext}

// scalastyle:off
/**
 * Analyses a streaming dataset of web page views. This class demonstrates several types of
 * operators available in Spark streaming.
 *
 * This should be used in tandem with PageViewStream.scala. Example:
 * To run the generator
 * `$ bin/run-example org.apache.spark.examples.streaming.clickstream.PageViewGenerator 44444 10`
 * To process the generated stream
 * `$ bin/run-example \
 *    org.apache.spark.examples.streaming.clickstream.PageViewStream errorRatePerZipCode localhost 44444`
 */
// scalastyle:on
object PageViewStream {
  def main(args: Array[String]) {
    if (args.length != 3) {
      System.err.println("Usage: PageViewStream <metric> <host> <port>")
      System.err.println("<metric> must be one of pageCounts, slidingPageCounts," +
                         " errorRatePerZipCode, activeUserCount, popularUsersSeen")
      System.exit(1)
    }
    StreamingExamples.setStreamingLogLevels()
    val metric = args(0)
    val host = args(1)
    val port = args(2).toInt

    // Create the context
    val ssc = new StreamingContext("local[2]", "PageViewStream", Seconds(1),
      System.getenv("SPARK_HOME"), StreamingContext.jarOfClass(this.getClass).toSeq)

    // Create a ReceiverInputDStream on target host:port and convert each line to a PageView
    val pageViews = ssc.socketTextStream(host, port)
                       .flatMap(_.split("\n"))
                       .map(PageView.fromString(_))

    // Return a count of views per URL seen in each batch
    val pageCounts = pageViews.map(view => view.url).countByValue()

    // Return a sliding window of page views per URL in the last ten seconds
    val slidingPageCounts = pageViews.map(view => view.url)
                                     .countByValueAndWindow(Seconds(10), Seconds(2))


    // Return the rate of error pages (a non 200 status) in each zip code over the last 30 seconds
    val statusesPerZipCode = pageViews.window(Seconds(30), Seconds(2))
                                      .map(view => ((view.zipCode, view.status)))
                                      .groupByKey()
    val errorRatePerZipCode = statusesPerZipCode.map{
      case(zip, statuses) =>
        val normalCount = statuses.count(_ == 200)
        val errorCount = statuses.size - normalCount
        val errorRatio = errorCount.toFloat / statuses.size
        if (errorRatio > 0.05) {
          "%s: **%s**".format(zip, errorRatio)
        } else {
          "%s: %s".format(zip, errorRatio)
        }
    }

    // Return the number unique users in last 15 seconds
    val activeUserCount = pageViews.window(Seconds(15), Seconds(2))
                                   .map(view => (view.userID, 1))
                                   .groupByKey()
                                   .count()
                                   .map("Unique active users: " + _)

    // An external dataset we want to join to this stream
    val userList = ssc.sparkContext.parallelize(Seq(
      1 -> "Patrick Wendell",
      2 -> "Reynold Xin",
      3 -> "Matei Zaharia"))

    metric match {
      case "pageCounts" => pageCounts.print()
      case "slidingPageCounts" => slidingPageCounts.print()
      case "errorRatePerZipCode" => errorRatePerZipCode.print()
      case "activeUserCount" => activeUserCount.print()
      case "popularUsersSeen" =>
        // Look for users in our existing dataset and print it out if we have a match
        pageViews.map(view => (view.userID, 1))
          .foreachRDD((rdd, time) => rdd.join(userList)
            .map(_._2._2)
            .take(10)
            .foreach(u => println(s"Saw user $u at time $time")))
      case _ => println(s"Invalid metric entered: $metric")
    }

    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.SparkSession
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext, Time}

/**
 * Use DataFrames and SQL to count words in UTF8 encoded, '\n' delimited text received from the
 * network every second.
 *
 * Usage: SqlNetworkWordCount <hostname> <port>
 * <hostname> and <port> describe the TCP server that Spark Streaming would connect to receive data.
 *
 * To run this on your local machine, you need to first run a Netcat server
 *    `$ nc -lk 9999`
 * and then run the example
 *    `$ bin/run-example org.apache.spark.examples.streaming.SqlNetworkWordCount localhost 9999`
 */

object SqlNetworkWordCount {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: NetworkWordCount <hostname> <port>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    // Create the context with a 2 second batch size
    val sparkConf = new SparkConf().setAppName("SqlNetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(2))

    // Create a socket stream on target ip:port and count the
    // words in input stream of \n delimited text (eg. generated by 'nc')
    // Note that no duplication in storage level only for running locally.
    // Replication necessary in distributed scenario for fault tolerance.
    val lines = ssc.socketTextStream(args(0), args(1).toInt, StorageLevel.MEMORY_AND_DISK_SER)
    val words = lines.flatMap(_.split(" "))

    // Convert RDDs of the words DStream to DataFrame and run SQL query
    words.foreachRDD { (rdd: RDD[String], time: Time) =>
      // Get the singleton instance of SparkSession
      val spark = SparkSessionSingleton.getInstance(rdd.sparkContext.getConf)
      import spark.implicits._

      // Convert RDD[String] to RDD[case class] to DataFrame
      val wordsDataFrame = rdd.map(w => Record(w)).toDF()

      // Creates a temporary view using the DataFrame
      wordsDataFrame.createOrReplaceTempView("words")

      // Do word count on table using SQL and print it
      val wordCountsDataFrame =
        spark.sql("select word, count(*) as total from words group by word")
      println(s"========= $time =========")
      wordCountsDataFrame.show()
    }

    ssc.start()
    ssc.awaitTermination()
  }
}


/** Case class for converting RDD to DataFrame */
case class Record(word: String)


/** Lazily instantiated singleton instance of SparkSession */
object SparkSessionSingleton {

  @transient  private var instance: SparkSession = _

  def getInstance(sparkConf: SparkConf): SparkSession = {
    if (instance == null) {
      instance = SparkSession
        .builder
        .config(sparkConf)
        .getOrCreate()
    }
    instance
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.streaming

import scala.collection.mutable.Queue

import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD
import org.apache.spark.streaming.{Seconds, StreamingContext}

object QueueStream {

  def main(args: Array[String]) {

    StreamingExamples.setStreamingLogLevels()
    val sparkConf = new SparkConf().setAppName("QueueStream")
    // Create the context
    val ssc = new StreamingContext(sparkConf, Seconds(1))

    // Create the queue through which RDDs can be pushed to
    // a QueueInputDStream
    val rddQueue = new Queue[RDD[Int]]()

    // Create the QueueInputDStream and use it do some processing
    val inputStream = ssc.queueStream(rddQueue)
    val mappedStream = inputStream.map(x => (x % 10, 1))
    val reducedStream = mappedStream.reduceByKey(_ + _)
    reducedStream.print()
    ssc.start()

    // Create and push some RDDs into rddQueue
    for (i <- 1 to 30) {
      rddQueue.synchronized {
        rddQueue += ssc.sparkContext.makeRDD(1 to 1000, 10)
      }
      Thread.sleep(1000)
    }
    ssc.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.streaming

import org.apache.spark.SparkConf
import org.apache.spark.streaming._

/**
 * Counts words cumulatively in UTF8 encoded, '\n' delimited text received from the network every
 * second starting with initial value of word count.
 * Usage: StatefulNetworkWordCount <hostname> <port>
 *   <hostname> and <port> describe the TCP server that Spark Streaming would connect to receive
 *   data.
 *
 * To run this on your local machine, you need to first run a Netcat server
 *    `$ nc -lk 9999`
 * and then run the example
 *    `$ bin/run-example
 *      org.apache.spark.examples.streaming.StatefulNetworkWordCount localhost 9999`
 */
object StatefulNetworkWordCount {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: StatefulNetworkWordCount <hostname> <port>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    val sparkConf = new SparkConf().setAppName("StatefulNetworkWordCount")
    // Create the context with a 1 second batch size
    val ssc = new StreamingContext(sparkConf, Seconds(1))
    ssc.checkpoint(".")

    // Initial state RDD for mapWithState operation
    val initialRDD = ssc.sparkContext.parallelize(List(("hello", 1), ("world", 1)))

    // Create a ReceiverInputDStream on target ip:port and count the
    // words in input stream of \n delimited test (eg. generated by 'nc')
    val lines = ssc.socketTextStream(args(0), args(1).toInt)
    val words = lines.flatMap(_.split(" "))
    val wordDstream = words.map(x => (x, 1))

    // Update the cumulative count using mapWithState
    // This will give a DStream made of state (which is the cumulative count of the words)
    val mappingFunc = (word: String, one: Option[Int], state: State[Int]) => {
      val sum = one.getOrElse(0) + state.getOption.getOrElse(0)
      val output = (word, sum)
      state.update(sum)
      output
    }

    val stateDstream = wordDstream.mapWithState(
      StateSpec.function(mappingFunc).initialState(initialRDD))
    stateDstream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.spark.sql.SparkSession

/**
 * Computes the PageRank of URLs from an input file. Input file should
 * be in format of:
 * URL         neighbor URL
 * URL         neighbor URL
 * URL         neighbor URL
 * ...
 * where URL and their neighbors are separated by space(s).
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.graphx.lib.PageRank
 *
 * Example Usage:
 * {{{
 * bin/run-example SparkPageRank data/mllib/pagerank_data.txt 10
 * }}}
 */
object SparkPageRank {

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of PageRank and is given as an example!
        |Please use the PageRank implementation found in org.apache.spark.graphx.lib.PageRank
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("Usage: SparkPageRank <file> <iter>")
      System.exit(1)
    }

    showWarning()

    val spark = SparkSession
      .builder
      .appName("SparkPageRank")
      .getOrCreate()

    val iters = if (args.length > 1) args(1).toInt else 10
    val lines = spark.read.textFile(args(0)).rdd
    val links = lines.map{ s =>
      val parts = s.split("\\s+")
      (parts(0), parts(1))
    }.distinct().groupByKey().cache()
    var ranks = links.mapValues(v => 1.0)

    for (i <- 1 to iters) {
      val contribs = links.join(ranks).values.flatMap{ case (urls, rank) =>
        val size = urls.size
        urls.map(url => (url, rank / size))
      }
      ranks = contribs.reduceByKey(_ + _).mapValues(0.15 + 0.85 * _)
    }

    val output = ranks.collect()
    output.foreach(tup => println(s"${tup._1} has rank:  ${tup._2} ."))

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.linalg.Vectors
// $example off$

object PMMLModelExportExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("PMMLModelExportExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data
    val data = sc.textFile("data/mllib/kmeans_data.txt")
    val parsedData = data.map(s => Vectors.dense(s.split(' ').map(_.toDouble))).cache()

    // Cluster the data into two classes using KMeans
    val numClusters = 2
    val numIterations = 20
    val clusters = KMeans.train(parsedData, numClusters, numIterations)

    // Export to PMML to a String in PMML format
    println(s"PMML Model:\n ${clusters.toPMML}")

    // Export the model to a local file in PMML format
    clusters.toPMML("/tmp/kmeans.xml")

    // Export the model to a directory on a distributed file system in PMML format
    clusters.toPMML(sc, "/tmp/kmeans")

    // Export the model to the OutputStream in PMML format
    clusters.toPMML(System.out)
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.PCA
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
// $example off$

@deprecated("Deprecated since LinearRegressionWithSGD is deprecated.  Use ml.feature.PCA", "2.0.0")
object PCAExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("PCAExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data = sc.textFile("data/mllib/ridge-data/lpsa.data").map { line =>
      val parts = line.split(',')
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }.cache()

    val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    val training = splits(0).cache()
    val test = splits(1)

    val pca = new PCA(training.first().features.size / 2).fit(data.map(_.features))
    val training_pca = training.map(p => p.copy(features = pca.transform(p.features)))
    val test_pca = test.map(p => p.copy(features = pca.transform(p.features)))

    val numIterations = 100
    val model = LinearRegressionWithSGD.train(training, numIterations)
    val model_pca = LinearRegressionWithSGD.train(training_pca, numIterations)

    val valuesAndPreds = test.map { point =>
      val score = model.predict(point.features)
      (score, point.label)
    }

    val valuesAndPreds_pca = test_pca.map { point =>
      val score = model_pca.predict(point.features)
      (score, point.label)
    }

    val MSE = valuesAndPreds.map { case (v, p) => math.pow((v - p), 2) }.mean()
    val MSE_pca = valuesAndPreds_pca.map { case (v, p) => math.pow((v - p), 2) }.mean()

    println(s"Mean Squared Error = $MSE")
    println(s"PCA Mean Squared Error = $MSE_pca")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.random.RandomRDDs
import org.apache.spark.rdd.RDD

/**
 * An example app for randomly generated RDDs. Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.RandomRDDGeneration
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object RandomRDDGeneration {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName(s"RandomRDDGeneration")
    val sc = new SparkContext(conf)

    val numExamples = 10000 // number of examples to generate
    val fraction = 0.1 // fraction of data to sample

    // Example: RandomRDDs.normalRDD
    val normalRDD: RDD[Double] = RandomRDDs.normalRDD(sc, numExamples)
    println(s"Generated RDD of ${normalRDD.count()}" +
      " examples sampled from the standard normal distribution")
    println("  First 5 samples:")
    normalRDD.take(5).foreach( x => println(s"    $x") )

    // Example: RandomRDDs.normalVectorRDD
    val normalVectorRDD = RandomRDDs.normalVectorRDD(sc, numRows = numExamples, numCols = 2)
    println(s"Generated RDD of ${normalVectorRDD.count()} examples of length-2 vectors.")
    println("  First 5 samples:")
    normalVectorRDD.take(5).foreach( x => println(s"    $x") )

    println()

    sc.stop()
  }

}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.classification.{LogisticRegressionWithLBFGS, SVMWithSGD}
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.optimization.{L1Updater, SquaredL2Updater}
import org.apache.spark.mllib.util.MLUtils

/**
 * An example app for binary classification. Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.BinaryClassification
 * }}}
 * A synthetic dataset is located at `data/mllib/sample_binary_classification_data.txt`.
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object BinaryClassification {

  object Algorithm extends Enumeration {
    type Algorithm = Value
    val SVM, LR = Value
  }

  object RegType extends Enumeration {
    type RegType = Value
    val L1, L2 = Value
  }

  import Algorithm._
  import RegType._

  case class Params(
      input: String = null,
      numIterations: Int = 100,
      stepSize: Double = 1.0,
      algorithm: Algorithm = LR,
      regType: RegType = L2,
      regParam: Double = 0.01) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("BinaryClassification") {
      head("BinaryClassification: an example app for binary classification.")
      opt[Int]("numIterations")
        .text("number of iterations")
        .action((x, c) => c.copy(numIterations = x))
      opt[Double]("stepSize")
        .text("initial step size (ignored by logistic regression), " +
          s"default: ${defaultParams.stepSize}")
        .action((x, c) => c.copy(stepSize = x))
      opt[String]("algorithm")
        .text(s"algorithm (${Algorithm.values.mkString(",")}), " +
        s"default: ${defaultParams.algorithm}")
        .action((x, c) => c.copy(algorithm = Algorithm.withName(x)))
      opt[String]("regType")
        .text(s"regularization type (${RegType.values.mkString(",")}), " +
        s"default: ${defaultParams.regType}")
        .action((x, c) => c.copy(regType = RegType.withName(x)))
      opt[Double]("regParam")
        .text(s"regularization parameter, default: ${defaultParams.regParam}")
      arg[String]("<input>")
        .required()
        .text("input paths to labeled examples in LIBSVM format")
        .action((x, c) => c.copy(input = x))
      note(
        """
          |For example, the following command runs this app on a synthetic dataset:
          |
          | bin/spark-submit --class org.apache.spark.examples.mllib.BinaryClassification \
          |  examples/target/scala-*/spark-examples-*.jar \
          |  --algorithm LR --regType L2 --regParam 1.0 \
          |  data/mllib/sample_binary_classification_data.txt
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"BinaryClassification with $params")
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    val examples = MLUtils.loadLibSVMFile(sc, params.input).cache()

    val splits = examples.randomSplit(Array(0.8, 0.2))
    val training = splits(0).cache()
    val test = splits(1).cache()

    val numTraining = training.count()
    val numTest = test.count()
    println(s"Training: $numTraining, test: $numTest.")

    examples.unpersist()

    val updater = params.regType match {
      case L1 => new L1Updater()
      case L2 => new SquaredL2Updater()
    }

    val model = params.algorithm match {
      case LR =>
        val algorithm = new LogisticRegressionWithLBFGS()
        algorithm.optimizer
          .setNumIterations(params.numIterations)
          .setUpdater(updater)
          .setRegParam(params.regParam)
        algorithm.run(training).clearThreshold()
      case SVM =>
        val algorithm = new SVMWithSGD()
        algorithm.optimizer
          .setNumIterations(params.numIterations)
          .setStepSize(params.stepSize)
          .setUpdater(updater)
          .setRegParam(params.regParam)
        algorithm.run(training).clearThreshold()
    }

    val prediction = model.predict(test.map(_.features))
    val predictionAndLabel = prediction.zip(test.map(_.label))

    val metrics = new BinaryClassificationMetrics(predictionAndLabel)

    println(s"Test areaUnderPR = ${metrics.areaUnderPR()}.")
    println(s"Test areaUnderROC = ${metrics.areaUnderROC()}.")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.linalg.Matrix
import org.apache.spark.mllib.linalg.SingularValueDecomposition
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.RowMatrix
// $example off$

/**
 * Example for SingularValueDecomposition.
 */
object SVDExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("SVDExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data = Array(
      Vectors.sparse(5, Seq((1, 1.0), (3, 7.0))),
      Vectors.dense(2.0, 0.0, 3.0, 4.0, 5.0),
      Vectors.dense(4.0, 0.0, 0.0, 6.0, 7.0))

    val rows = sc.parallelize(data)

    val mat: RowMatrix = new RowMatrix(rows)

    // Compute the top 5 singular values and corresponding singular vectors.
    val svd: SingularValueDecomposition[RowMatrix, Matrix] = mat.computeSVD(5, computeU = true)
    val U: RowMatrix = svd.U  // The U factor is a RowMatrix.
    val s: Vector = svd.s     // The singular values are stored in a local dense vector.
    val V: Matrix = svd.V     // The V factor is a local dense matrix.
    // $example off$
    val collect = U.rows.collect()
    println("U factor is:")
    collect.foreach { vector => println(vector) }
    println(s"Singular values are: $s")
    println(s"V factor is:\n$V")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.RowMatrix

/**
 * Compute the singular value decomposition (SVD) of a tall-and-skinny matrix.
 *
 * The input matrix must be stored in row-oriented dense format, one line per row with its entries
 * separated by space. For example,
 * {{{
 * 0.5 1.0
 * 2.0 3.0
 * 4.0 5.0
 * }}}
 * represents a 3-by-2 matrix, whose first row is (0.5, 1.0).
 */
object TallSkinnySVD {
  def main(args: Array[String]) {
    if (args.length != 1) {
      System.err.println("Usage: TallSkinnySVD <input>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("TallSkinnySVD")
    val sc = new SparkContext(conf)

    // Load and parse the data file.
    val rows = sc.textFile(args(0)).map { line =>
      val values = line.split(' ').map(_.toDouble)
      Vectors.dense(values)
    }
    val mat = new RowMatrix(rows)

    // Compute SVD.
    val svd = mat.computeSVD(mat.numCols().toInt)

    println(s"Singular values are ${svd.s}")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
// $example off$

@deprecated("Use ml.regression.LinearRegression or LBFGS", "2.0.0")
object LinearRegressionWithSGDExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("LinearRegressionWithSGDExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data
    val data = sc.textFile("data/mllib/ridge-data/lpsa.data")
    val parsedData = data.map { line =>
      val parts = line.split(',')
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }.cache()

    // Building the model
    val numIterations = 100
    val stepSize = 0.00000001
    val model = LinearRegressionWithSGD.train(parsedData, numIterations, stepSize)

    // Evaluate model on training examples and compute training error
    val valuesAndPreds = parsedData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val MSE = valuesAndPreds.map{ case(v, p) => math.pow((v - p), 2) }.mean()
    println(s"training Mean Squared Error $MSE")

    // Save and load model
    model.save(sc, "target/tmp/scalaLinearRegressionWithSGDModel")
    val sameModel = LinearRegressionModel.load(sc, "target/tmp/scalaLinearRegressionWithSGDModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.Normalizer
import org.apache.spark.mllib.util.MLUtils
// $example off$

object NormalizerExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("NormalizerExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")

    val normalizer1 = new Normalizer()
    val normalizer2 = new Normalizer(p = Double.PositiveInfinity)

    // Each sample in data1 will be normalized using $L^2$ norm.
    val data1 = data.map(x => (x.label, normalizer1.transform(x.features)))

    // Each sample in data2 will be normalized using $L^\infty$ norm.
    val data2 = data.map(x => (x.label, normalizer2.transform(x.features)))
    // $example off$

    println("data1: ")
    data1.foreach(x => println(x))

    println("data2: ")
    data2.foreach(x => println(x))

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.{HashingTF, IDF}
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.rdd.RDD
// $example off$

object TFIDFExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("TFIDFExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load documents (one per line).
    val documents: RDD[Seq[String]] = sc.textFile("data/mllib/kmeans_data.txt")
      .map(_.split(" ").toSeq)

    val hashingTF = new HashingTF()
    val tf: RDD[Vector] = hashingTF.transform(documents)

    // While applying HashingTF only needs a single pass to the data, applying IDF needs two passes:
    // First to compute the IDF vector and second to scale the term frequencies by IDF.
    tf.cache()
    val idf = new IDF().fit(tf)
    val tfidf: RDD[Vector] = idf.transform(tf)

    // spark.mllib IDF implementation provides an option for ignoring terms which occur in less than
    // a minimum number of documents. In such cases, the IDF for these terms is set to 0.
    // This feature can be used by passing the minDocFreq value to the IDF constructor.
    val idfIgnore = new IDF(minDocFreq = 2).fit(tf)
    val tfidfIgnore: RDD[Vector] = idfIgnore.transform(tf)
    // $example off$

    println("tfidf: ")
    tfidf.foreach(x => println(x))

    println("tfidfIgnore: ")
    tfidfIgnore.foreach(x => println(x))

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.linalg.Vectors

/**
 * An example k-means app. Run with
 * {{{
 * ./bin/run-example org.apache.spark.examples.mllib.DenseKMeans [options] <input>
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object DenseKMeans {

  object InitializationMode extends Enumeration {
    type InitializationMode = Value
    val Random, Parallel = Value
  }

  import InitializationMode._

  case class Params(
      input: String = null,
      k: Int = -1,
      numIterations: Int = 10,
      initializationMode: InitializationMode = Parallel) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("DenseKMeans") {
      head("DenseKMeans: an example k-means app for dense data.")
      opt[Int]('k', "k")
        .required()
        .text(s"number of clusters, required")
        .action((x, c) => c.copy(k = x))
      opt[Int]("numIterations")
        .text(s"number of iterations, default: ${defaultParams.numIterations}")
        .action((x, c) => c.copy(numIterations = x))
      opt[String]("initMode")
        .text(s"initialization mode (${InitializationMode.values.mkString(",")}), " +
        s"default: ${defaultParams.initializationMode}")
        .action((x, c) => c.copy(initializationMode = InitializationMode.withName(x)))
      arg[String]("<input>")
        .text("input paths to examples")
        .required()
        .action((x, c) => c.copy(input = x))
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"DenseKMeans with $params")
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    val examples = sc.textFile(params.input).map { line =>
      Vectors.dense(line.split(' ').map(_.toDouble))
    }.cache()

    val numExamples = examples.count()

    println(s"numExamples = $numExamples.")

    val initMode = params.initializationMode match {
      case Random => KMeans.RANDOM
      case Parallel => KMeans.K_MEANS_PARALLEL
    }

    val model = new KMeans()
      .setInitializationMode(initMode)
      .setK(params.k)
      .setMaxIterations(params.numIterations)
      .run(examples)

    val cost = model.computeCost(examples)

    println(s"Total cost = $cost.")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
// $example on$
import org.apache.spark.mllib.clustering.StreamingKMeans
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.streaming.{Seconds, StreamingContext}
// $example off$

/**
 * Estimate clusters on one stream of data and make predictions
 * on another stream, where the data streams arrive as text files
 * into two different directories.
 *
 * The rows of the training text files must be vector data in the form
 * `[x1,x2,x3,...,xn]`
 * Where n is the number of dimensions.
 *
 * The rows of the test text files must be labeled data in the form
 * `(y,[x1,x2,x3,...,xn])`
 * Where y is some identifier. n must be the same for train and test.
 *
 * Usage:
 *   StreamingKMeansExample <trainingDir> <testDir> <batchDuration> <numClusters> <numDimensions>
 *
 * To run on your local machine using the two directories `trainingDir` and `testDir`,
 * with updates every 5 seconds, 2 dimensions per data point, and 3 clusters, call:
 *    $ bin/run-example mllib.StreamingKMeansExample trainingDir testDir 5 3 2
 *
 * As you add text files to `trainingDir` the clusters will continuously update.
 * Anytime you add text files to `testDir`, you'll see predicted labels using the current model.
 *
 */
object StreamingKMeansExample {

  def main(args: Array[String]) {
    if (args.length != 5) {
      System.err.println(
        "Usage: StreamingKMeansExample " +
          "<trainingDir> <testDir> <batchDuration> <numClusters> <numDimensions>")
      System.exit(1)
    }

    // $example on$
    val conf = new SparkConf().setAppName("StreamingKMeansExample")
    val ssc = new StreamingContext(conf, Seconds(args(2).toLong))

    val trainingData = ssc.textFileStream(args(0)).map(Vectors.parse)
    val testData = ssc.textFileStream(args(1)).map(LabeledPoint.parse)

    val model = new StreamingKMeans()
      .setK(args(3).toInt)
      .setDecayFactor(1.0)
      .setRandomCenters(args(4).toInt, 0.0)

    model.trainOn(trainingData)
    model.predictOnValues(testData.map(lp => (lp.label, lp.features))).print()

    ssc.start()
    ssc.awaitTermination()
    // $example off$
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.recommendation.ALS
import org.apache.spark.mllib.recommendation.MatrixFactorizationModel
import org.apache.spark.mllib.recommendation.Rating
// $example off$

object RecommendationExample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("CollaborativeFilteringExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load and parse the data
    val data = sc.textFile("data/mllib/als/test.data")
    val ratings = data.map(_.split(',') match { case Array(user, item, rate) =>
      Rating(user.toInt, item.toInt, rate.toDouble)
    })

    // Build the recommendation model using ALS
    val rank = 10
    val numIterations = 10
    val model = ALS.train(ratings, rank, numIterations, 0.01)

    // Evaluate the model on rating data
    val usersProducts = ratings.map { case Rating(user, product, rate) =>
      (user, product)
    }
    val predictions =
      model.predict(usersProducts).map { case Rating(user, product, rate) =>
        ((user, product), rate)
      }
    val ratesAndPreds = ratings.map { case Rating(user, product, rate) =>
      ((user, product), rate)
    }.join(predictions)
    val MSE = ratesAndPreds.map { case ((user, product), (r1, r2)) =>
      val err = (r1 - r2)
      err * err
    }.mean()
    println(s"Mean Squared Error = $MSE")

    // Save and load model
    model.save(sc, "target/tmp/myCollaborativeFilter")
    val sameModel = MatrixFactorizationModel.load(sc, "target/tmp/myCollaborativeFilter")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.fpm.FPGrowth
import org.apache.spark.rdd.RDD
// $example off$

object SimpleFPGrowth {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("SimpleFPGrowth")
    val sc = new SparkContext(conf)

    // $example on$
    val data = sc.textFile("data/mllib/sample_fpgrowth.txt")

    val transactions: RDD[Array[String]] = data.map(s => s.trim.split(' '))

    val fpg = new FPGrowth()
      .setMinSupport(0.2)
      .setNumPartitions(10)
    val model = fpg.run(transactions)

    model.freqItemsets.collect().foreach { itemset =>
      println(s"${itemset.items.mkString("[", ",", "]")},${itemset.freq}")
    }

    val minConfidence = 0.8
    model.generateAssociationRules(minConfidence).collect().foreach { rule =>
      println(s"${rule.antecedent.mkString("[", ",", "]")}=> " +
        s"${rule.consequent .mkString("[", ",", "]")},${rule.confidence}")
    }
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.tree.model.DecisionTreeModel
import org.apache.spark.mllib.util.MLUtils
// $example off$

object DecisionTreeRegressionExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("DecisionTreeRegressionExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Split the data into training and test sets (30% held out for testing)
    val splits = data.randomSplit(Array(0.7, 0.3))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a DecisionTree model.
    //  Empty categoricalFeaturesInfo indicates all features are continuous.
    val categoricalFeaturesInfo = Map[Int, Int]()
    val impurity = "variance"
    val maxDepth = 5
    val maxBins = 32

    val model = DecisionTree.trainRegressor(trainingData, categoricalFeaturesInfo, impurity,
      maxDepth, maxBins)

    // Evaluate model on test instances and compute test error
    val labelsAndPredictions = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testMSE = labelsAndPredictions.map{ case (v, p) => math.pow(v - p, 2) }.mean()
    println(s"Test Mean Squared Error = $testMSE")
    println(s"Learned regression tree model:\n ${model.toDebugString}")

    // Save and load model
    model.save(sc, "target/tmp/myDecisionTreeRegressionModel")
    val sameModel = DecisionTreeModel.load(sc, "target/tmp/myDecisionTreeRegressionModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.mllib.stat.test.ChiSqTestResult
import org.apache.spark.rdd.RDD
// $example off$

object HypothesisTestingExample {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("HypothesisTestingExample")
    val sc = new SparkContext(conf)

    // $example on$
    // a vector composed of the frequencies of events
    val vec: Vector = Vectors.dense(0.1, 0.15, 0.2, 0.3, 0.25)

    // compute the goodness of fit. If a second vector to test against is not supplied
    // as a parameter, the test runs against a uniform distribution.
    val goodnessOfFitTestResult = Statistics.chiSqTest(vec)
    // summary of the test including the p-value, degrees of freedom, test statistic, the method
    // used, and the null hypothesis.
    println(s"$goodnessOfFitTestResult\n")

    // a contingency matrix. Create a dense matrix ((1.0, 2.0), (3.0, 4.0), (5.0, 6.0))
    val mat: Matrix = Matrices.dense(3, 2, Array(1.0, 3.0, 5.0, 2.0, 4.0, 6.0))

    // conduct Pearson's independence test on the input contingency matrix
    val independenceTestResult = Statistics.chiSqTest(mat)
    // summary of the test including the p-value, degrees of freedom
    println(s"$independenceTestResult\n")

    val obs: RDD[LabeledPoint] =
      sc.parallelize(
        Seq(
          LabeledPoint(1.0, Vectors.dense(1.0, 0.0, 3.0)),
          LabeledPoint(1.0, Vectors.dense(1.0, 2.0, 0.0)),
          LabeledPoint(-1.0, Vectors.dense(-1.0, 0.0, -0.5)
          )
        )
      ) // (label, feature) pairs.

    // The contingency table is constructed from the raw (label, feature) pairs and used to conduct
    // the independence test. Returns an array containing the ChiSquaredTestResult for every feature
    // against the label.
    val featureTestResults: Array[ChiSqTestResult] = Statistics.chiSqTest(obs)
    featureTestResults.zipWithIndex.foreach { case (k, v) =>
      println(s"Column ${(v + 1)} :")
      println(k)
    }  // summary of the test
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.BoostingStrategy
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel
import org.apache.spark.mllib.util.MLUtils
// $example off$

object GradientBoostingClassificationExample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("GradientBoostedTreesClassificationExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Split the data into training and test sets (30% held out for testing)
    val splits = data.randomSplit(Array(0.7, 0.3))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a GradientBoostedTrees model.
    // The defaultParams for Classification use LogLoss by default.
    val boostingStrategy = BoostingStrategy.defaultParams("Classification")
    boostingStrategy.numIterations = 3 // Note: Use more iterations in practice.
    boostingStrategy.treeStrategy.numClasses = 2
    boostingStrategy.treeStrategy.maxDepth = 5
    // Empty categoricalFeaturesInfo indicates all features are continuous.
    boostingStrategy.treeStrategy.categoricalFeaturesInfo = Map[Int, Int]()

    val model = GradientBoostedTrees.train(trainingData, boostingStrategy)

    // Evaluate model on test instances and compute test error
    val labelAndPreds = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testErr = labelAndPreds.filter(r => r._1 != r._2).count.toDouble / testData.count()
    println(s"Test Error = $testErr")
    println(s"Learned classification GBT model:\n ${model.toDebugString}")

    // Save and load model
    model.save(sc, "target/tmp/myGradientBoostingClassificationModel")
    val sameModel = GradientBoostedTreesModel.load(sc,
      "target/tmp/myGradientBoostingClassificationModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println


/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.PCA
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.rdd.RDD
// $example off$

object PCAOnSourceVectorExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("PCAOnSourceVectorExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data: RDD[LabeledPoint] = sc.parallelize(Seq(
      new LabeledPoint(0, Vectors.dense(1, 0, 0, 0, 1)),
      new LabeledPoint(1, Vectors.dense(1, 1, 0, 1, 0)),
      new LabeledPoint(1, Vectors.dense(1, 1, 0, 0, 0)),
      new LabeledPoint(0, Vectors.dense(1, 0, 0, 0, 0)),
      new LabeledPoint(1, Vectors.dense(1, 1, 0, 0, 0))))

    // Compute the top 5 principal components.
    val pca = new PCA(5).fit(data.map(_.features))

    // Project vectors to the linear space spanned by the top 5 principal
    // components, keeping the label
    val projected = data.map(p => p.copy(features = pca.transform(p.features)))
    // $example off$
    val collect = projected.collect()
    println("Projected vector of principal component:")
    collect.foreach { vector => println(vector) }

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.Vectors
// $example off$

object KMeansExample {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("KMeansExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data
    val data = sc.textFile("data/mllib/kmeans_data.txt")
    val parsedData = data.map(s => Vectors.dense(s.split(' ').map(_.toDouble))).cache()

    // Cluster the data into two classes using KMeans
    val numClusters = 2
    val numIterations = 20
    val clusters = KMeans.train(parsedData, numClusters, numIterations)

    // Evaluate clustering by computing Within Set Sum of Squared Errors
    val WSSSE = clusters.computeCost(parsedData)
    println(s"Within Set Sum of Squared Errors = $WSSSE")

    // Save and load model
    clusters.save(sc, "target/org/apache/spark/KMeansExample/KMeansModel")
    val sameModel = KMeansModel.load(sc, "target/org/apache/spark/KMeansExample/KMeansModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.evaluation.MultilabelMetrics
import org.apache.spark.rdd.RDD
// $example off$

object MultiLabelMetricsExample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("MultiLabelMetricsExample")
    val sc = new SparkContext(conf)
    // $example on$
    val scoreAndLabels: RDD[(Array[Double], Array[Double])] = sc.parallelize(
      Seq((Array(0.0, 1.0), Array(0.0, 2.0)),
        (Array(0.0, 2.0), Array(0.0, 1.0)),
        (Array.empty[Double], Array(0.0)),
        (Array(2.0), Array(2.0)),
        (Array(2.0, 0.0), Array(2.0, 0.0)),
        (Array(0.0, 1.0, 2.0), Array(0.0, 1.0)),
        (Array(1.0), Array(1.0, 2.0))), 2)

    // Instantiate metrics object
    val metrics = new MultilabelMetrics(scoreAndLabels)

    // Summary stats
    println(s"Recall = ${metrics.recall}")
    println(s"Precision = ${metrics.precision}")
    println(s"F1 measure = ${metrics.f1Measure}")
    println(s"Accuracy = ${metrics.accuracy}")

    // Individual label stats
    metrics.labels.foreach(label =>
      println(s"Class $label precision = ${metrics.precision(label)}"))
    metrics.labels.foreach(label => println(s"Class $label recall = ${metrics.recall(label)}"))
    metrics.labels.foreach(label => println(s"Class $label F1-score = ${metrics.f1Measure(label)}"))

    // Micro stats
    println(s"Micro recall = ${metrics.microRecall}")
    println(s"Micro precision = ${metrics.microPrecision}")
    println(s"Micro F1 measure = ${metrics.microF1Measure}")

    // Hamming loss
    println(s"Hamming loss = ${metrics.hammingLoss}")

    // Subset accuracy
    println(s"Subset accuracy = ${metrics.subsetAccuracy}")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.classification.NaiveBayes
import org.apache.spark.mllib.util.MLUtils

/**
 * An example naive Bayes app. Run with
 * {{{
 * ./bin/run-example org.apache.spark.examples.mllib.SparseNaiveBayes [options] <input>
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object SparseNaiveBayes {

  case class Params(
      input: String = null,
      minPartitions: Int = 0,
      numFeatures: Int = -1,
      lambda: Double = 1.0) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("SparseNaiveBayes") {
      head("SparseNaiveBayes: an example naive Bayes app for LIBSVM data.")
      opt[Int]("numPartitions")
        .text("min number of partitions")
        .action((x, c) => c.copy(minPartitions = x))
      opt[Int]("numFeatures")
        .text("number of features")
        .action((x, c) => c.copy(numFeatures = x))
      opt[Double]("lambda")
        .text(s"lambda (smoothing constant), default: ${defaultParams.lambda}")
        .action((x, c) => c.copy(lambda = x))
      arg[String]("<input>")
        .text("input paths to labeled examples in LIBSVM format")
        .required()
        .action((x, c) => c.copy(input = x))
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"SparseNaiveBayes with $params")
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    val minPartitions =
      if (params.minPartitions > 0) params.minPartitions else sc.defaultMinPartitions

    val examples =
      MLUtils.loadLibSVMFile(sc, params.input, params.numFeatures, minPartitions)
    // Cache examples because it will be used in both training and evaluation.
    examples.cache()

    val splits = examples.randomSplit(Array(0.8, 0.2))
    val training = splits(0)
    val test = splits(1)

    val numTraining = training.count()
    val numTest = test.count()

    println(s"numTraining = $numTraining, numTest = $numTest.")

    val model = new NaiveBayes().setLambda(params.lambda).run(training)

    val prediction = model.predict(test.map(_.features))
    val predictionAndLabel = prediction.zip(test.map(_.label))
    val accuracy = predictionAndLabel.filter(x => x._1 == x._2).count().toDouble / numTest

    println(s"Test accuracy = $accuracy.")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.mllib

// scalastyle:off println
import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.clustering.BisectingKMeans
import org.apache.spark.mllib.linalg.{Vector, Vectors}
// $example off$

/**
 * An example demonstrating a bisecting k-means clustering in spark.mllib.
 *
 * Run with
 * {{{
 * bin/run-example mllib.BisectingKMeansExample
 * }}}
 */
object BisectingKMeansExample {

  def main(args: Array[String]) {
    val sparkConf = new SparkConf().setAppName("mllib.BisectingKMeansExample")
    val sc = new SparkContext(sparkConf)

    // $example on$
    // Loads and parses data
    def parse(line: String): Vector = Vectors.dense(line.split(" ").map(_.toDouble))
    val data = sc.textFile("data/mllib/kmeans_data.txt").map(parse).cache()

    // Clustering the data into 6 clusters by BisectingKMeans.
    val bkm = new BisectingKMeans().setK(6)
    val model = bkm.run(data)

    // Show the compute cost and the cluster centers
    println(s"Compute Cost: ${model.computeCost(data)}")
    model.clusterCenters.zipWithIndex.foreach { case (center, idx) =>
      println(s"Cluster Center ${idx}: ${center}")
    }
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}

object StratifiedSamplingExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("StratifiedSamplingExample")
    val sc = new SparkContext(conf)

    // $example on$
    // an RDD[(K, V)] of any key value pairs
    val data = sc.parallelize(
      Seq((1, 'a'), (1, 'b'), (2, 'c'), (2, 'd'), (2, 'e'), (3, 'f')))

    // specify the exact fraction desired from each key
    val fractions = Map(1 -> 0.1, 2 -> 0.6, 3 -> 0.3)

    // Get an approximate sample from each stratum
    val approxSample = data.sampleByKey(withReplacement = false, fractions = fractions)
    // Get an exact sample from each stratum
    val exactSample = data.sampleByKeyExact(withReplacement = false, fractions = fractions)
    // $example off$

    println(s"approxSample size is ${approxSample.collect().size}")
    approxSample.collect().foreach(println)

    println(s"exactSample its size is ${exactSample.collect().size}")
    exactSample.collect().foreach(println)

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scala.collection.mutable

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.recommendation.{ALS, MatrixFactorizationModel, Rating}
import org.apache.spark.rdd.RDD

/**
 * An example app for ALS on MovieLens data (http://grouplens.org/datasets/movielens/).
 * Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.MovieLensALS
 * }}}
 * A synthetic dataset in MovieLens format can be found at `data/mllib/sample_movielens_data.txt`.
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object MovieLensALS {

  case class Params(
      input: String = null,
      kryo: Boolean = false,
      numIterations: Int = 20,
      lambda: Double = 1.0,
      rank: Int = 10,
      numUserBlocks: Int = -1,
      numProductBlocks: Int = -1,
      implicitPrefs: Boolean = false) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("MovieLensALS") {
      head("MovieLensALS: an example app for ALS on MovieLens data.")
      opt[Int]("rank")
        .text(s"rank, default: ${defaultParams.rank}")
        .action((x, c) => c.copy(rank = x))
      opt[Int]("numIterations")
        .text(s"number of iterations, default: ${defaultParams.numIterations}")
        .action((x, c) => c.copy(numIterations = x))
      opt[Double]("lambda")
        .text(s"lambda (smoothing constant), default: ${defaultParams.lambda}")
        .action((x, c) => c.copy(lambda = x))
      opt[Unit]("kryo")
        .text("use Kryo serialization")
        .action((_, c) => c.copy(kryo = true))
      opt[Int]("numUserBlocks")
        .text(s"number of user blocks, default: ${defaultParams.numUserBlocks} (auto)")
        .action((x, c) => c.copy(numUserBlocks = x))
      opt[Int]("numProductBlocks")
        .text(s"number of product blocks, default: ${defaultParams.numProductBlocks} (auto)")
        .action((x, c) => c.copy(numProductBlocks = x))
      opt[Unit]("implicitPrefs")
        .text("use implicit preference")
        .action((_, c) => c.copy(implicitPrefs = true))
      arg[String]("<input>")
        .required()
        .text("input paths to a MovieLens dataset of ratings")
        .action((x, c) => c.copy(input = x))
      note(
        """
          |For example, the following command runs this app on a synthetic dataset:
          |
          | bin/spark-submit --class org.apache.spark.examples.mllib.MovieLensALS \
          |  examples/target/scala-*/spark-examples-*.jar \
          |  --rank 5 --numIterations 20 --lambda 1.0 --kryo \
          |  data/mllib/sample_movielens_data.txt
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"MovieLensALS with $params")
    if (params.kryo) {
      conf.registerKryoClasses(Array(classOf[mutable.BitSet], classOf[Rating]))
        .set("spark.kryoserializer.buffer", "8m")
    }
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    val implicitPrefs = params.implicitPrefs

    val ratings = sc.textFile(params.input).map { line =>
      val fields = line.split("::")
      if (implicitPrefs) {
        /*
         * MovieLens ratings are on a scale of 1-5:
         * 5: Must see
         * 4: Will enjoy
         * 3: It's okay
         * 2: Fairly bad
         * 1: Awful
         * So we should not recommend a movie if the predicted rating is less than 3.
         * To map ratings to confidence scores, we use
         * 5 -> 2.5, 4 -> 1.5, 3 -> 0.5, 2 -> -0.5, 1 -> -1.5. This mappings means unobserved
         * entries are generally between It's okay and Fairly bad.
         * The semantics of 0 in this expanded world of non-positive weights
         * are "the same as never having interacted at all".
         */
        Rating(fields(0).toInt, fields(1).toInt, fields(2).toDouble - 2.5)
      } else {
        Rating(fields(0).toInt, fields(1).toInt, fields(2).toDouble)
      }
    }.cache()

    val numRatings = ratings.count()
    val numUsers = ratings.map(_.user).distinct().count()
    val numMovies = ratings.map(_.product).distinct().count()

    println(s"Got $numRatings ratings from $numUsers users on $numMovies movies.")

    val splits = ratings.randomSplit(Array(0.8, 0.2))
    val training = splits(0).cache()
    val test = if (params.implicitPrefs) {
      /*
       * 0 means "don't know" and positive values mean "confident that the prediction should be 1".
       * Negative values means "confident that the prediction should be 0".
       * We have in this case used some kind of weighted RMSE. The weight is the absolute value of
       * the confidence. The error is the difference between prediction and either 1 or 0,
       * depending on whether r is positive or negative.
       */
      splits(1).map(x => Rating(x.user, x.product, if (x.rating > 0) 1.0 else 0.0))
    } else {
      splits(1)
    }.cache()

    val numTraining = training.count()
    val numTest = test.count()
    println(s"Training: $numTraining, test: $numTest.")

    ratings.unpersist()

    val model = new ALS()
      .setRank(params.rank)
      .setIterations(params.numIterations)
      .setLambda(params.lambda)
      .setImplicitPrefs(params.implicitPrefs)
      .setUserBlocks(params.numUserBlocks)
      .setProductBlocks(params.numProductBlocks)
      .run(training)

    val rmse = computeRmse(model, test, params.implicitPrefs)

    println(s"Test RMSE = $rmse.")

    sc.stop()
  }

  /** Compute RMSE (Root Mean Squared Error). */
  def computeRmse(model: MatrixFactorizationModel, data: RDD[Rating], implicitPrefs: Boolean)
    : Double = {

    def mapPredictedRating(r: Double): Double = {
      if (implicitPrefs) math.max(math.min(r, 1.0), 0.0) else r
    }

    val predictions: RDD[Rating] = model.predict(data.map(x => (x.user, x.product)))
    val predictionsAndRatings = predictions.map{ x =>
      ((x.user, x.product), mapPredictedRating(x.rating))
    }.join(data.map(x => ((x.user, x.product), x.rating))).values
    math.sqrt(predictionsAndRatings.map(x => (x._1 - x._2) * (x._1 - x._2)).mean())
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.mllib.stat.test.{BinarySample, StreamingTest}
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.util.Utils

/**
 * Perform streaming testing using Welch's 2-sample t-test on a stream of data, where the data
 * stream arrives as text files in a directory. Stops when the two groups are statistically
 * significant (p-value < 0.05) or after a user-specified timeout in number of batches is exceeded.
 *
 * The rows of the text files must be in the form `Boolean, Double`. For example:
 *   false, -3.92
 *   true, 99.32
 *
 * Usage:
 *   StreamingTestExample <dataDir> <batchDuration> <numBatchesTimeout>
 *
 * To run on your local machine using the directory `dataDir` with 5 seconds between each batch and
 * a timeout after 100 insignificant batches, call:
 *    $ bin/run-example mllib.StreamingTestExample dataDir 5 100
 *
 * As you add text files to `dataDir` the significance test wil continually update every
 * `batchDuration` seconds until the test becomes significant (p-value < 0.05) or the number of
 * batches processed exceeds `numBatchesTimeout`.
 */
object StreamingTestExample {

  def main(args: Array[String]) {
    if (args.length != 3) {
      // scalastyle:off println
      System.err.println(
        "Usage: StreamingTestExample " +
          "<dataDir> <batchDuration> <numBatchesTimeout>")
      // scalastyle:on println
      System.exit(1)
    }
    val dataDir = args(0)
    val batchDuration = Seconds(args(1).toLong)
    val numBatchesTimeout = args(2).toInt

    val conf = new SparkConf().setMaster("local").setAppName("StreamingTestExample")
    val ssc = new StreamingContext(conf, batchDuration)
    ssc.checkpoint {
      val dir = Utils.createTempDir()
      dir.toString
    }

    // $example on$
    val data = ssc.textFileStream(dataDir).map(line => line.split(",") match {
      case Array(label, value) => BinarySample(label.toBoolean, value.toDouble)
    })

    val streamingTest = new StreamingTest()
      .setPeacePeriod(0)
      .setWindowSize(0)
      .setTestMethod("welch")

    val out = streamingTest.registerStream(data)
    out.print()
    // $example off$

    // Stop processing if test becomes significant or we time out
    var timeoutCounter = numBatchesTimeout
    out.foreachRDD { rdd =>
      timeoutCounter -= 1
      val anySignificant = rdd.map(_.pValue < 0.05).fold(false)(_ || _)
      if (timeoutCounter == 0 || anySignificant) rdd.context.stop()
    }

    ssc.start()
    ssc.awaitTermination()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.ChiSqSelector
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
// $example off$

object ChiSqSelectorExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("ChiSqSelectorExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load some data in libsvm format
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Discretize data in 16 equal bins since ChiSqSelector requires categorical features
    // Even though features are doubles, the ChiSqSelector treats each unique value as a category
    val discretizedData = data.map { lp =>
      LabeledPoint(lp.label, Vectors.dense(lp.features.toArray.map { x => (x / 16).floor }))
    }
    // Create ChiSqSelector that will select top 50 of 692 features
    val selector = new ChiSqSelector(50)
    // Create ChiSqSelector model (selecting features)
    val transformer = selector.fit(discretizedData)
    // Filter the top 50 features from each feature vector
    val filteredData = discretizedData.map { lp =>
      LabeledPoint(lp.label, transformer.transform(lp.features))
    }
    // $example off$

    println("filtered data: ")
    filteredData.foreach(x => println(x))

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.RowMatrix

/**
 * Compute the principal components of a tall-and-skinny matrix, whose rows are observations.
 *
 * The input matrix must be stored in row-oriented dense format, one line per row with its entries
 * separated by space. For example,
 * {{{
 * 0.5 1.0
 * 2.0 3.0
 * 4.0 5.0
 * }}}
 * represents a 3-by-2 matrix, whose first row is (0.5, 1.0).
 */
object TallSkinnyPCA {
  def main(args: Array[String]) {
    if (args.length != 1) {
      System.err.println("Usage: TallSkinnyPCA <input>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("TallSkinnyPCA")
    val sc = new SparkContext(conf)

    // Load and parse the data file.
    val rows = sc.textFile(args(0)).map { line =>
      val values = line.split(' ').map(_.toDouble)
      Vectors.dense(values)
    }
    val mat = new RowMatrix(rows)

    // Compute principal components.
    val pc = mat.computePrincipalComponents(mat.numCols().toInt)

    println(s"Principal components are:\n $pc")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.classification.LogisticRegressionModel
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.optimization.{LBFGS, LogisticGradient, SquaredL2Updater}
import org.apache.spark.mllib.util.MLUtils
// $example off$

object LBFGSExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("LBFGSExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    val numFeatures = data.take(1)(0).features.size

    // Split data into training (60%) and test (40%).
    val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)

    // Append 1 into the training data as intercept.
    val training = splits(0).map(x => (x.label, MLUtils.appendBias(x.features))).cache()

    val test = splits(1)

    // Run training algorithm to build the model
    val numCorrections = 10
    val convergenceTol = 1e-4
    val maxNumIterations = 20
    val regParam = 0.1
    val initialWeightsWithIntercept = Vectors.dense(new Array[Double](numFeatures + 1))

    val (weightsWithIntercept, loss) = LBFGS.runLBFGS(
      training,
      new LogisticGradient(),
      new SquaredL2Updater(),
      numCorrections,
      convergenceTol,
      maxNumIterations,
      regParam,
      initialWeightsWithIntercept)

    val model = new LogisticRegressionModel(
      Vectors.dense(weightsWithIntercept.toArray.slice(0, weightsWithIntercept.size - 1)),
      weightsWithIntercept(weightsWithIntercept.size - 1))

    // Clear the default threshold.
    model.clearThreshold()

    // Compute raw scores on the test set.
    val scoreAndLabels = test.map { point =>
      val score = model.predict(point.features)
      (score, point.label)
    }

    // Get evaluation metrics.
    val metrics = new BinaryClassificationMetrics(scoreAndLabels)
    val auROC = metrics.areaUnderROC()

    println("Loss of each step in training process")
    loss.foreach(println)
    println(s"Area under ROC = $auROC")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

// $example on$
import org.apache.spark.mllib.evaluation.{RankingMetrics, RegressionMetrics}
import org.apache.spark.mllib.recommendation.{ALS, Rating}
// $example off$
import org.apache.spark.sql.SparkSession

object RankingMetricsExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("RankingMetricsExample")
      .getOrCreate()
    import spark.implicits._
    // $example on$
    // Read in the ratings data
    val ratings = spark.read.textFile("data/mllib/sample_movielens_data.txt").rdd.map { line =>
      val fields = line.split("::")
      Rating(fields(0).toInt, fields(1).toInt, fields(2).toDouble - 2.5)
    }.cache()

    // Map ratings to 1 or 0, 1 indicating a movie that should be recommended
    val binarizedRatings = ratings.map(r => Rating(r.user, r.product,
      if (r.rating > 0) 1.0 else 0.0)).cache()

    // Summarize ratings
    val numRatings = ratings.count()
    val numUsers = ratings.map(_.user).distinct().count()
    val numMovies = ratings.map(_.product).distinct().count()
    println(s"Got $numRatings ratings from $numUsers users on $numMovies movies.")

    // Build the model
    val numIterations = 10
    val rank = 10
    val lambda = 0.01
    val model = ALS.train(ratings, rank, numIterations, lambda)

    // Define a function to scale ratings from 0 to 1
    def scaledRating(r: Rating): Rating = {
      val scaledRating = math.max(math.min(r.rating, 1.0), 0.0)
      Rating(r.user, r.product, scaledRating)
    }

    // Get sorted top ten predictions for each user and then scale from [0, 1]
    val userRecommended = model.recommendProductsForUsers(10).map { case (user, recs) =>
      (user, recs.map(scaledRating))
    }

    // Assume that any movie a user rated 3 or higher (which maps to a 1) is a relevant document
    // Compare with top ten most relevant documents
    val userMovies = binarizedRatings.groupBy(_.user)
    val relevantDocuments = userMovies.join(userRecommended).map { case (user, (actual,
    predictions)) =>
      (predictions.map(_.product), actual.filter(_.rating > 0.0).map(_.product).toArray)
    }

    // Instantiate metrics object
    val metrics = new RankingMetrics(relevantDocuments)

    // Precision at K
    Array(1, 3, 5).foreach { k =>
      println(s"Precision at $k = ${metrics.precisionAt(k)}")
    }

    // Mean average precision
    println(s"Mean average precision = ${metrics.meanAveragePrecision}")

    // Normalized discounted cumulative gain
    Array(1, 3, 5).foreach { k =>
      println(s"NDCG at $k = ${metrics.ndcgAt(k)}")
    }

    // Recall at K
    Array(1, 3, 5).foreach { k =>
      println(s"Recall at $k = ${metrics.recallAt(k)}")
    }

    // Get predictions for each data point
    val allPredictions = model.predict(ratings.map(r => (r.user, r.product))).map(r => ((r.user,
      r.product), r.rating))
    val allRatings = ratings.map(r => ((r.user, r.product), r.rating))
    val predictionsAndLabels = allPredictions.join(allRatings).map { case ((user, product),
    (predicted, actual)) =>
      (predicted, actual)
    }

    // Get the RMSE using regression metrics
    val regressionMetrics = new RegressionMetrics(predictionsAndLabels)
    println(s"RMSE = ${regressionMetrics.rootMeanSquaredError}")

    // R-squared
    println(s"R-squared = ${regressionMetrics.r2}")
    // $example off$
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// scalastyle:off println

package org.apache.spark.examples.mllib

// $example on$
import org.apache.spark.mllib.evaluation.RegressionMetrics
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
// $example off$
import org.apache.spark.sql.SparkSession

@deprecated("Use ml.regression.LinearRegression and the resulting model summary for metrics",
  "2.0.0")
object RegressionMetricsExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("RegressionMetricsExample")
      .getOrCreate()
    // $example on$
    // Load the data
    val data = spark
      .read.format("libsvm").load("data/mllib/sample_linear_regression_data.txt")
      .rdd.map(row => LabeledPoint(row.getDouble(0), row.get(1).asInstanceOf[Vector]))
      .cache()

    // Build the model
    val numIterations = 100
    val model = LinearRegressionWithSGD.train(data, numIterations)

    // Get predictions
    val valuesAndPreds = data.map{ point =>
      val prediction = model.predict(point.features)
      (prediction, point.label)
    }

    // Instantiate metrics object
    val metrics = new RegressionMetrics(valuesAndPreds)

    // Squared error
    println(s"MSE = ${metrics.meanSquaredError}")
    println(s"RMSE = ${metrics.rootMeanSquaredError}")

    // R-squared
    println(s"R-squared = ${metrics.r2}")

    // Mean absolute error
    println(s"MAE = ${metrics.meanAbsoluteError}")

    // Explained variance
    println(s"Explained variance = ${metrics.explainedVariance}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.stat.KernelDensity
import org.apache.spark.rdd.RDD
// $example off$

object KernelDensityEstimationExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("KernelDensityEstimationExample")
    val sc = new SparkContext(conf)

    // $example on$
    // an RDD of sample data
    val data: RDD[Double] = sc.parallelize(Seq(1, 1, 1, 2, 3, 4, 5, 5, 6, 7, 8, 9, 9))

    // Construct the density estimator with the sample data and a standard deviation
    // for the Gaussian kernels
    val kd = new KernelDensity()
      .setSample(data)
      .setBandwidth(3.0)

    // Find density estimates for the given values
    val densities = kd.estimate(Array(-1.0, 2.0, 5.0))
    // $example off$

    densities.foreach(println)

    sc.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.regression.{IsotonicRegression, IsotonicRegressionModel}
import org.apache.spark.mllib.util.MLUtils
// $example off$

object IsotonicRegressionExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("IsotonicRegressionExample")
    val sc = new SparkContext(conf)
    // $example on$
    val data = MLUtils.loadLibSVMFile(sc,
      "data/mllib/sample_isotonic_regression_libsvm_data.txt").cache()

    // Create label, feature, weight tuples from input data with weight set to default value 1.0.
    val parsedData = data.map { labeledPoint =>
      (labeledPoint.label, labeledPoint.features(0), 1.0)
    }

    // Split data into training (60%) and test (40%) sets.
    val splits = parsedData.randomSplit(Array(0.6, 0.4), seed = 11L)
    val training = splits(0)
    val test = splits(1)

    // Create isotonic regression model from training data.
    // Isotonic parameter defaults to true so it is only shown for demonstration
    val model = new IsotonicRegression().setIsotonic(true).run(training)

    // Create tuples of predicted and real labels.
    val predictionAndLabel = test.map { point =>
      val predictedLabel = model.predict(point._2)
      (predictedLabel, point._1)
    }

    // Calculate mean squared error between predicted and real labels.
    val meanSquaredError = predictionAndLabel.map { case (p, l) => math.pow((p - l), 2) }.mean()
    println(s"Mean Squared Error = $meanSquaredError")

    // Save and load model
    model.save(sc, "target/tmp/myIsotonicRegressionModel")
    val sameModel = IsotonicRegressionModel.load(sc, "target/tmp/myIsotonicRegressionModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.MultivariateOnlineSummarizer
import org.apache.spark.mllib.util.MLUtils

/**
 * An example app for summarizing multivariate data from a file. Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.MultivariateSummarizer
 * }}}
 * By default, this loads a synthetic dataset from `data/mllib/sample_linear_regression_data.txt`.
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object MultivariateSummarizer {

  case class Params(input: String = "data/mllib/sample_linear_regression_data.txt")
    extends AbstractParams[Params]

  def main(args: Array[String]) {

    val defaultParams = Params()

    val parser = new OptionParser[Params]("MultivariateSummarizer") {
      head("MultivariateSummarizer: an example app for MultivariateOnlineSummarizer")
      opt[String]("input")
        .text(s"Input path to labeled examples in LIBSVM format, default: ${defaultParams.input}")
        .action((x, c) => c.copy(input = x))
      note(
        """
        |For example, the following command runs this app on a synthetic dataset:
        |
        | bin/spark-submit --class org.apache.spark.examples.mllib.MultivariateSummarizer \
        |  examples/target/scala-*/spark-examples-*.jar \
        |  --input data/mllib/sample_linear_regression_data.txt
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"MultivariateSummarizer with $params")
    val sc = new SparkContext(conf)

    val examples = MLUtils.loadLibSVMFile(sc, params.input).cache()

    println(s"Summary of data file: ${params.input}")
    println(s"${examples.count()} data points")

    // Summarize labels
    val labelSummary = examples.aggregate(new MultivariateOnlineSummarizer())(
      (summary, lp) => summary.add(Vectors.dense(lp.label)),
      (sum1, sum2) => sum1.merge(sum2))

    // Summarize features
    val featureSummary = examples.aggregate(new MultivariateOnlineSummarizer())(
      (summary, lp) => summary.add(lp.features),
      (sum1, sum2) => sum1.merge(sum2))

    println()
    println(s"Summary statistics")
    println(s"\tLabel\tFeatures")
    println(s"mean\t${labelSummary.mean(0)}\t${featureSummary.mean.toArray.mkString("\t")}")
    println(s"var\t${labelSummary.variance(0)}\t${featureSummary.variance.toArray.mkString("\t")}")
    println(
      s"nnz\t${labelSummary.numNonzeros(0)}\t${featureSummary.numNonzeros.toArray.mkString("\t")}")
    println(s"max\t${labelSummary.max(0)}\t${featureSummary.max.toArray.mkString("\t")}")
    println(s"min\t${labelSummary.min(0)}\t${featureSummary.min.toArray.mkString("\t")}")
    println()

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.classification.{LogisticRegressionModel, LogisticRegressionWithLBFGS}
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
// $example off$

object LogisticRegressionWithLBFGSExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("LogisticRegressionWithLBFGSExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load training data in LIBSVM format.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")

    // Split data into training (60%) and test (40%).
    val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    val training = splits(0).cache()
    val test = splits(1)

    // Run training algorithm to build the model
    val model = new LogisticRegressionWithLBFGS()
      .setNumClasses(10)
      .run(training)

    // Compute raw scores on the test set.
    val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
      val prediction = model.predict(features)
      (prediction, label)
    }

    // Get evaluation metrics.
    val metrics = new MulticlassMetrics(predictionAndLabels)
    val accuracy = metrics.accuracy
    println(s"Accuracy = $accuracy")

    // Save and load model
    model.save(sc, "target/tmp/scalaLogisticRegressionWithLBFGSModel")
    val sameModel = LogisticRegressionModel.load(sc,
      "target/tmp/scalaLogisticRegressionWithLBFGSModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
// $example off$

object MulticlassMetricsExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("MulticlassMetricsExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load training data in LIBSVM format
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_multiclass_classification_data.txt")

    // Split data into training (60%) and test (40%)
    val Array(training, test) = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    training.cache()

    // Run training algorithm to build the model
    val model = new LogisticRegressionWithLBFGS()
      .setNumClasses(3)
      .run(training)

    // Compute raw scores on the test set
    val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
      val prediction = model.predict(features)
      (prediction, label)
    }

    // Instantiate metrics object
    val metrics = new MulticlassMetrics(predictionAndLabels)

    // Confusion matrix
    println("Confusion matrix:")
    println(metrics.confusionMatrix)

    // Overall Statistics
    val accuracy = metrics.accuracy
    println("Summary Statistics")
    println(s"Accuracy = $accuracy")

    // Precision by label
    val labels = metrics.labels
    labels.foreach { l =>
      println(s"Precision($l) = " + metrics.precision(l))
    }

    // Recall by label
    labels.foreach { l =>
      println(s"Recall($l) = " + metrics.recall(l))
    }

    // False positive rate by label
    labels.foreach { l =>
      println(s"FPR($l) = " + metrics.falsePositiveRate(l))
    }

    // F-measure by label
    labels.foreach { l =>
      println(s"F1-Score($l) = " + metrics.fMeasure(l))
    }

    // Weighted stats
    println(s"Weighted precision: ${metrics.weightedPrecision}")
    println(s"Weighted recall: ${metrics.weightedRecall}")
    println(s"Weighted F1 score: ${metrics.weightedFMeasure}")
    println(s"Weighted false positive rate: ${metrics.weightedFalsePositiveRate}")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.clustering.{GaussianMixture, GaussianMixtureModel}
import org.apache.spark.mllib.linalg.Vectors
// $example off$

object GaussianMixtureExample {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("GaussianMixtureExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data
    val data = sc.textFile("data/mllib/gmm_data.txt")
    val parsedData = data.map(s => Vectors.dense(s.trim.split(' ').map(_.toDouble))).cache()

    // Cluster the data into two classes using GaussianMixture
    val gmm = new GaussianMixture().setK(2).run(parsedData)

    // Save and load model
    gmm.save(sc, "target/org/apache/spark/GaussianMixtureExample/GaussianMixtureModel")
    val sameModel = GaussianMixtureModel.load(sc,
      "target/org/apache/spark/GaussianMixtureExample/GaussianMixtureModel")

    // output parameters of max-likelihood model
    for (i <- 0 until gmm.k) {
      println("weight=%f\nmu=%s\nsigma=\n%s\n" format
        (gmm.weights(i), gmm.gaussians(i).mu, gmm.gaussians(i).sigma))
    }
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.clustering.{DistributedLDAModel, LDA}
import org.apache.spark.mllib.linalg.Vectors
// $example off$

object LatentDirichletAllocationExample {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("LatentDirichletAllocationExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data
    val data = sc.textFile("data/mllib/sample_lda_data.txt")
    val parsedData = data.map(s => Vectors.dense(s.trim.split(' ').map(_.toDouble)))
    // Index documents with unique IDs
    val corpus = parsedData.zipWithIndex.map(_.swap).cache()

    // Cluster the documents into three topics using LDA
    val ldaModel = new LDA().setK(3).run(corpus)

    // Output topics. Each is a distribution over words (matching word count vectors)
    println(s"Learned topics (as distributions over vocab of ${ldaModel.vocabSize} words):")
    val topics = ldaModel.topicsMatrix
    for (topic <- Range(0, 3)) {
      print(s"Topic $topic :")
      for (word <- Range(0, ldaModel.vocabSize)) {
        print(s"${topics(word, topic)}")
      }
      println()
    }

    // Save and load model.
    ldaModel.save(sc, "target/org/apache/spark/LatentDirichletAllocationExample/LDAModel")
    val sameModel = DistributedLDAModel.load(sc,
      "target/org/apache/spark/LatentDirichletAllocationExample/LDAModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.fpm.FPGrowth

/**
 * Example for mining frequent itemsets using FP-growth.
 * Example usage: ./bin/run-example mllib.FPGrowthExample \
 *   --minSupport 0.8 --numPartition 2 ./data/mllib/sample_fpgrowth.txt
 */
object FPGrowthExample {

  case class Params(
    input: String = null,
    minSupport: Double = 0.3,
    numPartition: Int = -1) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("FPGrowthExample") {
      head("FPGrowth: an example FP-growth app.")
      opt[Double]("minSupport")
        .text(s"minimal support level, default: ${defaultParams.minSupport}")
        .action((x, c) => c.copy(minSupport = x))
      opt[Int]("numPartition")
        .text(s"number of partition, default: ${defaultParams.numPartition}")
        .action((x, c) => c.copy(numPartition = x))
      arg[String]("<input>")
        .text("input paths to input data set, whose file format is that each line " +
          "contains a transaction with each item in String and separated by a space")
        .required()
        .action((x, c) => c.copy(input = x))
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"FPGrowthExample with $params")
    val sc = new SparkContext(conf)
    val transactions = sc.textFile(params.input).map(_.split(" ")).cache()

    println(s"Number of transactions: ${transactions.count()}")

    val model = new FPGrowth()
      .setMinSupport(params.minSupport)
      .setNumPartitions(params.numPartition)
      .run(transactions)

    println(s"Number of frequent itemsets: ${model.freqItemsets.count()}")

    model.freqItemsets.collect().foreach { itemset =>
      println(s"${itemset.items.mkString("[", ",", "]")}, ${itemset.freq}")
    }

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.fpm.AssociationRules
import org.apache.spark.mllib.fpm.FPGrowth.FreqItemset
// $example off$

object AssociationRulesExample {

  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("AssociationRulesExample")
    val sc = new SparkContext(conf)

    // $example on$
    val freqItemsets = sc.parallelize(Seq(
      new FreqItemset(Array("a"), 15L),
      new FreqItemset(Array("b"), 35L),
      new FreqItemset(Array("a", "b"), 12L)
    ))

    val ar = new AssociationRules()
      .setMinConfidence(0.8)
    val results = ar.run(freqItemsets)

    results.collect().foreach { rule =>
    println(s"[${rule.antecedent.mkString(",")}=>${rule.consequent.mkString(",")} ]" +
        s" ${rule.confidence}")
    }
    // $example off$

    sc.stop()
  }

}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.classification.{NaiveBayes, NaiveBayesModel}
import org.apache.spark.mllib.util.MLUtils
// $example off$

object NaiveBayesExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("NaiveBayesExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")

    // Split data into training (60%) and test (40%).
    val Array(training, test) = data.randomSplit(Array(0.6, 0.4))

    val model = NaiveBayes.train(training, lambda = 1.0, modelType = "multinomial")

    val predictionAndLabel = test.map(p => (model.predict(p.features), p.label))
    val accuracy = 1.0 * predictionAndLabel.filter(x => x._1 == x._2).count() / test.count()

    // Save and load model
    model.save(sc, "target/tmp/myNaiveBayesModel")
    val sameModel = NaiveBayesModel.load(sc, "target/tmp/myNaiveBayesModel")
    // $example off$

    sc.stop()
  }
}

// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.tree.model.RandomForestModel
import org.apache.spark.mllib.util.MLUtils
// $example off$

object RandomForestClassificationExample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("RandomForestClassificationExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Split the data into training and test sets (30% held out for testing)
    val splits = data.randomSplit(Array(0.7, 0.3))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a RandomForest model.
    // Empty categoricalFeaturesInfo indicates all features are continuous.
    val numClasses = 2
    val categoricalFeaturesInfo = Map[Int, Int]()
    val numTrees = 3 // Use more in practice.
    val featureSubsetStrategy = "auto" // Let the algorithm choose.
    val impurity = "gini"
    val maxDepth = 4
    val maxBins = 32

    val model = RandomForest.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
      numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)

    // Evaluate model on test instances and compute test error
    val labelAndPreds = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testErr = labelAndPreds.filter(r => r._1 != r._2).count.toDouble / testData.count()
    println(s"Test Error = $testErr")
    println(s"Learned classification forest model:\n ${model.toDebugString}")

    // Save and load model
    model.save(sc, "target/tmp/myRandomForestClassificationModel")
    val sameModel = RandomForestModel.load(sc, "target/tmp/myRandomForestClassificationModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import java.util.Locale

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.feature.{CountVectorizer, CountVectorizerModel, RegexTokenizer, StopWordsRemover}
import org.apache.spark.ml.linalg.{Vector => MLVector}
import org.apache.spark.mllib.clustering.{DistributedLDAModel, EMLDAOptimizer, LDA, OnlineLDAOptimizer}
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{Row, SparkSession}

/**
 * An example Latent Dirichlet Allocation (LDA) app. Run with
 * {{{
 * ./bin/run-example mllib.LDAExample [options] <input>
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object LDAExample {

  private case class Params(
      input: Seq[String] = Seq.empty,
      k: Int = 20,
      maxIterations: Int = 10,
      docConcentration: Double = -1,
      topicConcentration: Double = -1,
      vocabSize: Int = 10000,
      stopwordFile: String = "",
      algorithm: String = "em",
      checkpointDir: Option[String] = None,
      checkpointInterval: Int = 10) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("LDAExample") {
      head("LDAExample: an example LDA app for plain text data.")
      opt[Int]("k")
        .text(s"number of topics. default: ${defaultParams.k}")
        .action((x, c) => c.copy(k = x))
      opt[Int]("maxIterations")
        .text(s"number of iterations of learning. default: ${defaultParams.maxIterations}")
        .action((x, c) => c.copy(maxIterations = x))
      opt[Double]("docConcentration")
        .text(s"amount of topic smoothing to use (> 1.0) (-1=auto)." +
        s"  default: ${defaultParams.docConcentration}")
        .action((x, c) => c.copy(docConcentration = x))
      opt[Double]("topicConcentration")
        .text(s"amount of term (word) smoothing to use (> 1.0) (-1=auto)." +
        s"  default: ${defaultParams.topicConcentration}")
        .action((x, c) => c.copy(topicConcentration = x))
      opt[Int]("vocabSize")
        .text(s"number of distinct word types to use, chosen by frequency. (-1=all)" +
          s"  default: ${defaultParams.vocabSize}")
        .action((x, c) => c.copy(vocabSize = x))
      opt[String]("stopwordFile")
        .text(s"filepath for a list of stopwords. Note: This must fit on a single machine." +
        s"  default: ${defaultParams.stopwordFile}")
        .action((x, c) => c.copy(stopwordFile = x))
      opt[String]("algorithm")
        .text(s"inference algorithm to use. em and online are supported." +
        s" default: ${defaultParams.algorithm}")
        .action((x, c) => c.copy(algorithm = x))
      opt[String]("checkpointDir")
        .text(s"Directory for checkpointing intermediate results." +
        s"  Checkpointing helps with recovery and eliminates temporary shuffle files on disk." +
        s"  default: ${defaultParams.checkpointDir}")
        .action((x, c) => c.copy(checkpointDir = Some(x)))
      opt[Int]("checkpointInterval")
        .text(s"Iterations between each checkpoint.  Only used if checkpointDir is set." +
        s" default: ${defaultParams.checkpointInterval}")
        .action((x, c) => c.copy(checkpointInterval = x))
      arg[String]("<input>...")
        .text("input paths (directories) to plain text corpora." +
        "  Each text file line should hold 1 document.")
        .unbounded()
        .required()
        .action((x, c) => c.copy(input = c.input :+ x))
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  private def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"LDAExample with $params")
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    // Load documents, and prepare them for LDA.
    val preprocessStart = System.nanoTime()
    val (corpus, vocabArray, actualNumTokens) =
      preprocess(sc, params.input, params.vocabSize, params.stopwordFile)
    corpus.cache()
    val actualCorpusSize = corpus.count()
    val actualVocabSize = vocabArray.length
    val preprocessElapsed = (System.nanoTime() - preprocessStart) / 1e9

    println()
    println(s"Corpus summary:")
    println(s"\t Training set size: $actualCorpusSize documents")
    println(s"\t Vocabulary size: $actualVocabSize terms")
    println(s"\t Training set size: $actualNumTokens tokens")
    println(s"\t Preprocessing time: $preprocessElapsed sec")
    println()

    // Run LDA.
    val lda = new LDA()

    val optimizer = params.algorithm.toLowerCase(Locale.ROOT) match {
      case "em" => new EMLDAOptimizer
      // add (1.0 / actualCorpusSize) to MiniBatchFraction be more robust on tiny datasets.
      case "online" => new OnlineLDAOptimizer().setMiniBatchFraction(0.05 + 1.0 / actualCorpusSize)
      case _ => throw new IllegalArgumentException(
        s"Only em, online are supported but got ${params.algorithm}.")
    }

    lda.setOptimizer(optimizer)
      .setK(params.k)
      .setMaxIterations(params.maxIterations)
      .setDocConcentration(params.docConcentration)
      .setTopicConcentration(params.topicConcentration)
      .setCheckpointInterval(params.checkpointInterval)
    if (params.checkpointDir.nonEmpty) {
      sc.setCheckpointDir(params.checkpointDir.get)
    }
    val startTime = System.nanoTime()
    val ldaModel = lda.run(corpus)
    val elapsed = (System.nanoTime() - startTime) / 1e9

    println(s"Finished training LDA model.  Summary:")
    println(s"\t Training time: $elapsed sec")

    if (ldaModel.isInstanceOf[DistributedLDAModel]) {
      val distLDAModel = ldaModel.asInstanceOf[DistributedLDAModel]
      val avgLogLikelihood = distLDAModel.logLikelihood / actualCorpusSize.toDouble
      println(s"\t Training data average log likelihood: $avgLogLikelihood")
      println()
    }

    // Print the topics, showing the top-weighted terms for each topic.
    val topicIndices = ldaModel.describeTopics(maxTermsPerTopic = 10)
    val topics = topicIndices.map { case (terms, termWeights) =>
      terms.zip(termWeights).map { case (term, weight) => (vocabArray(term.toInt), weight) }
    }
    println(s"${params.k} topics:")
    topics.zipWithIndex.foreach { case (topic, i) =>
      println(s"TOPIC $i")
      topic.foreach { case (term, weight) =>
        println(s"$term\t$weight")
      }
      println()
    }
    sc.stop()
  }

  /**
   * Load documents, tokenize them, create vocabulary, and prepare documents as term count vectors.
   * @return (corpus, vocabulary as array, total token count in corpus)
   */
  private def preprocess(
      sc: SparkContext,
      paths: Seq[String],
      vocabSize: Int,
      stopwordFile: String): (RDD[(Long, Vector)], Array[String], Long) = {

    val spark = SparkSession
      .builder
      .sparkContext(sc)
      .getOrCreate()
    import spark.implicits._

    // Get dataset of document texts
    // One document per line in each text file. If the input consists of many small files,
    // this can result in a large number of small partitions, which can degrade performance.
    // In this case, consider using coalesce() to create fewer, larger partitions.
    val df = sc.textFile(paths.mkString(",")).toDF("docs")
    val customizedStopWords: Array[String] = if (stopwordFile.isEmpty) {
      Array.empty[String]
    } else {
      val stopWordText = sc.textFile(stopwordFile).collect()
      stopWordText.flatMap(_.stripMargin.split("\\s+"))
    }
    val tokenizer = new RegexTokenizer()
      .setInputCol("docs")
      .setOutputCol("rawTokens")
    val stopWordsRemover = new StopWordsRemover()
      .setInputCol("rawTokens")
      .setOutputCol("tokens")
    stopWordsRemover.setStopWords(stopWordsRemover.getStopWords ++ customizedStopWords)
    val countVectorizer = new CountVectorizer()
      .setVocabSize(vocabSize)
      .setInputCol("tokens")
      .setOutputCol("features")

    val pipeline = new Pipeline()
      .setStages(Array(tokenizer, stopWordsRemover, countVectorizer))

    val model = pipeline.fit(df)
    val documents = model.transform(df)
      .select("features")
      .rdd
      .map { case Row(features: MLVector) => Vectors.fromML(features) }
      .zipWithIndex()
      .map(_.swap)

    (documents,
      model.stages(2).asInstanceOf[CountVectorizerModel].vocabulary,  // vocabulary
      documents.map(_._2.numActives).sum().toLong) // total token count
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.tree.{impurity, DecisionTree, RandomForest}
import org.apache.spark.mllib.tree.configuration.{Algo, Strategy}
import org.apache.spark.mllib.tree.configuration.Algo._
import org.apache.spark.mllib.tree.model.{DecisionTreeModel, RandomForestModel}
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.rdd.RDD
import org.apache.spark.util.Utils

/**
 * An example runner for decision trees and random forests. Run with
 * {{{
 * ./bin/run-example org.apache.spark.examples.mllib.DecisionTreeRunner [options]
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 *
 * Note: This script treats all features as real-valued (not categorical).
 *       To include categorical features, modify categoricalFeaturesInfo.
 */
object DecisionTreeRunner {

  object ImpurityType extends Enumeration {
    type ImpurityType = Value
    val Gini, Entropy, Variance = Value
  }

  import ImpurityType._

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      algo: Algo = Classification,
      maxDepth: Int = 5,
      impurity: ImpurityType = Gini,
      maxBins: Int = 32,
      minInstancesPerNode: Int = 1,
      minInfoGain: Double = 0.0,
      numTrees: Int = 1,
      featureSubsetStrategy: String = "auto",
      fracTest: Double = 0.2,
      useNodeIdCache: Boolean = false,
      checkpointDir: Option[String] = None,
      checkpointInterval: Int = 10) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("DecisionTreeRunner") {
      head("DecisionTreeRunner: an example decision tree app.")
      opt[String]("algo")
        .text(s"algorithm (${Algo.values.mkString(",")}), default: ${defaultParams.algo}")
        .action((x, c) => c.copy(algo = Algo.withName(x)))
      opt[String]("impurity")
        .text(s"impurity type (${ImpurityType.values.mkString(",")}), " +
          s"default: ${defaultParams.impurity}")
        .action((x, c) => c.copy(impurity = ImpurityType.withName(x)))
      opt[Int]("maxDepth")
        .text(s"max depth of the tree, default: ${defaultParams.maxDepth}")
        .action((x, c) => c.copy(maxDepth = x))
      opt[Int]("maxBins")
        .text(s"max number of bins, default: ${defaultParams.maxBins}")
        .action((x, c) => c.copy(maxBins = x))
      opt[Int]("minInstancesPerNode")
        .text(s"min number of instances required at child nodes to create the parent split," +
          s" default: ${defaultParams.minInstancesPerNode}")
        .action((x, c) => c.copy(minInstancesPerNode = x))
      opt[Double]("minInfoGain")
        .text(s"min info gain required to create a split, default: ${defaultParams.minInfoGain}")
        .action((x, c) => c.copy(minInfoGain = x))
      opt[Int]("numTrees")
        .text(s"number of trees (1 = decision tree, 2+ = random forest)," +
          s" default: ${defaultParams.numTrees}")
        .action((x, c) => c.copy(numTrees = x))
      opt[String]("featureSubsetStrategy")
        .text(s"feature subset sampling strategy" +
          s" (${RandomForest.supportedFeatureSubsetStrategies.mkString(", ")}), " +
          s"default: ${defaultParams.featureSubsetStrategy}")
        .action((x, c) => c.copy(featureSubsetStrategy = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing.  If given option testInput, " +
          s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[Boolean]("useNodeIdCache")
        .text(s"whether to use node Id cache during training, " +
          s"default: ${defaultParams.useNodeIdCache}")
        .action((x, c) => c.copy(useNodeIdCache = x))
      opt[String]("checkpointDir")
        .text(s"checkpoint directory where intermediate node Id caches will be stored, " +
         s"default: ${defaultParams.checkpointDir match {
           case Some(strVal) => strVal
           case None => "None"
         }}")
        .action((x, c) => c.copy(checkpointDir = Some(x)))
      opt[Int]("checkpointInterval")
        .text(s"how often to checkpoint the node Id cache, " +
         s"default: ${defaultParams.checkpointInterval}")
        .action((x, c) => c.copy(checkpointInterval = x))
      opt[String]("testInput")
        .text(s"input path to test dataset.  If given, option fracTest is ignored." +
          s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest > 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1].")
        } else {
          if (params.algo == Classification &&
            (params.impurity == Gini || params.impurity == Entropy)) {
            success
          } else if (params.algo == Regression && params.impurity == Variance) {
            success
          } else {
            failure(s"Algo ${params.algo} is not compatible with impurity ${params.impurity}.")
          }
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  /**
   * Load training and test data from files.
   * @param input  Path to input dataset.
   * @param dataFormat  "libsvm" or "dense"
   * @param testInput  Path to test dataset.
   * @param algo  Classification or Regression
   * @param fracTest  Fraction of input data to hold out for testing.  Ignored if testInput given.
   * @return  (training dataset, test dataset, number of classes),
   *          where the number of classes is inferred from data (and set to 0 for Regression)
   */
  private[mllib] def loadDatasets(
      sc: SparkContext,
      input: String,
      dataFormat: String,
      testInput: String,
      algo: Algo,
      fracTest: Double): (RDD[LabeledPoint], RDD[LabeledPoint], Int) = {
    // Load training data and cache it.
    val origExamples = dataFormat match {
      case "dense" => MLUtils.loadLabeledPoints(sc, input).cache()
      case "libsvm" => MLUtils.loadLibSVMFile(sc, input).cache()
    }
    // For classification, re-index classes if needed.
    val (examples, classIndexMap, numClasses) = algo match {
      case Classification =>
        // classCounts: class --> # examples in class
        val classCounts = origExamples.map(_.label).countByValue()
        val sortedClasses = classCounts.keys.toList.sorted
        val numClasses = classCounts.size
        // classIndexMap: class --> index in 0,...,numClasses-1
        val classIndexMap = {
          if (classCounts.keySet != Set(0.0, 1.0)) {
            sortedClasses.zipWithIndex.toMap
          } else {
            Map[Double, Int]()
          }
        }
        val examples = {
          if (classIndexMap.isEmpty) {
            origExamples
          } else {
            origExamples.map(lp => LabeledPoint(classIndexMap(lp.label), lp.features))
          }
        }
        val numExamples = examples.count()
        println(s"numClasses = $numClasses.")
        println(s"Per-class example fractions, counts:")
        println(s"Class\tFrac\tCount")
        sortedClasses.foreach { c =>
          val frac = classCounts(c) / numExamples.toDouble
          println(s"$c\t$frac\t${classCounts(c)}")
        }
        (examples, classIndexMap, numClasses)
      case Regression =>
        (origExamples, null, 0)
      case _ =>
        throw new IllegalArgumentException(s"Algo $algo not supported.")
    }

    // Create training, test sets.
    val splits = if (testInput != "") {
      // Load testInput.
      val numFeatures = examples.take(1)(0).features.size
      val origTestExamples = dataFormat match {
        case "dense" => MLUtils.loadLabeledPoints(sc, testInput)
        case "libsvm" => MLUtils.loadLibSVMFile(sc, testInput, numFeatures)
      }
      algo match {
        case Classification =>
          // classCounts: class --> # examples in class
          val testExamples = {
            if (classIndexMap.isEmpty) {
              origTestExamples
            } else {
              origTestExamples.map(lp => LabeledPoint(classIndexMap(lp.label), lp.features))
            }
          }
          Array(examples, testExamples)
        case Regression =>
          Array(examples, origTestExamples)
      }
    } else {
      // Split input into training, test.
      examples.randomSplit(Array(1.0 - fracTest, fracTest))
    }
    val training = splits(0).cache()
    val test = splits(1).cache()

    val numTraining = training.count()
    val numTest = test.count()
    println(s"numTraining = $numTraining, numTest = $numTest.")

    examples.unpersist()

    (training, test, numClasses)
  }

  def run(params: Params): Unit = {

    val conf = new SparkConf().setAppName(s"DecisionTreeRunner with $params")
    val sc = new SparkContext(conf)

    println(s"DecisionTreeRunner with parameters:\n$params")

    // Load training and test data and cache it.
    val (training, test, numClasses) = loadDatasets(sc, params.input, params.dataFormat,
      params.testInput, params.algo, params.fracTest)

    val impurityCalculator = params.impurity match {
      case Gini => impurity.Gini
      case Entropy => impurity.Entropy
      case Variance => impurity.Variance
    }

    params.checkpointDir.foreach(sc.setCheckpointDir)

    val strategy
      = new Strategy(
          algo = params.algo,
          impurity = impurityCalculator,
          maxDepth = params.maxDepth,
          maxBins = params.maxBins,
          numClasses = numClasses,
          minInstancesPerNode = params.minInstancesPerNode,
          minInfoGain = params.minInfoGain,
          useNodeIdCache = params.useNodeIdCache,
          checkpointInterval = params.checkpointInterval)
    if (params.numTrees == 1) {
      val startTime = System.nanoTime()
      val model = DecisionTree.train(training, strategy)
      val elapsedTime = (System.nanoTime() - startTime) / 1e9
      println(s"Training time: $elapsedTime seconds")
      if (model.numNodes < 20) {
        println(model.toDebugString) // Print full model.
      } else {
        println(model) // Print model summary.
      }
      if (params.algo == Classification) {
        val trainAccuracy =
          new MulticlassMetrics(training.map(lp => (model.predict(lp.features), lp.label))).accuracy
        println(s"Train accuracy = $trainAccuracy")
        val testAccuracy =
          new MulticlassMetrics(test.map(lp => (model.predict(lp.features), lp.label))).accuracy
        println(s"Test accuracy = $testAccuracy")
      }
      if (params.algo == Regression) {
        val trainMSE = meanSquaredError(model, training)
        println(s"Train mean squared error = $trainMSE")
        val testMSE = meanSquaredError(model, test)
        println(s"Test mean squared error = $testMSE")
      }
    } else {
      val randomSeed = Utils.random.nextInt()
      if (params.algo == Classification) {
        val startTime = System.nanoTime()
        val model = RandomForest.trainClassifier(training, strategy, params.numTrees,
          params.featureSubsetStrategy, randomSeed)
        val elapsedTime = (System.nanoTime() - startTime) / 1e9
        println(s"Training time: $elapsedTime seconds")
        if (model.totalNumNodes < 30) {
          println(model.toDebugString) // Print full model.
        } else {
          println(model) // Print model summary.
        }
        val trainAccuracy =
          new MulticlassMetrics(training.map(lp => (model.predict(lp.features), lp.label))).accuracy
        println(s"Train accuracy = $trainAccuracy")
        val testAccuracy =
          new MulticlassMetrics(test.map(lp => (model.predict(lp.features), lp.label))).accuracy
        println(s"Test accuracy = $testAccuracy")
      }
      if (params.algo == Regression) {
        val startTime = System.nanoTime()
        val model = RandomForest.trainRegressor(training, strategy, params.numTrees,
          params.featureSubsetStrategy, randomSeed)
        val elapsedTime = (System.nanoTime() - startTime) / 1e9
        println(s"Training time: $elapsedTime seconds")
        if (model.totalNumNodes < 30) {
          println(model.toDebugString) // Print full model.
        } else {
          println(model) // Print model summary.
        }
        val trainMSE = meanSquaredError(model, training)
        println(s"Train mean squared error = $trainMSE")
        val testMSE = meanSquaredError(model, test)
        println(s"Test mean squared error = $testMSE")
      }
    }

    sc.stop()
  }

  /**
   * Calculates the mean squared error for regression.
   */
  private[mllib] def meanSquaredError(model: RandomForestModel, data: RDD[LabeledPoint]): Double =
    data.map { y =>
      val err = model.predict(y.features) - y.label
      err * err
    }.mean()

  private[mllib] def meanSquaredError(model: DecisionTreeModel, data: RDD[LabeledPoint]): Double =
    data.map { y =>
      val err = model.predict(y.features) - y.label
      err * err
    }.mean()
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.classification.{SVMModel, SVMWithSGD}
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.util.MLUtils
// $example off$

object SVMWithSGDExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("SVMWithSGDExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load training data in LIBSVM format.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")

    // Split data into training (60%) and test (40%).
    val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    val training = splits(0).cache()
    val test = splits(1)

    // Run training algorithm to build the model
    val numIterations = 100
    val model = SVMWithSGD.train(training, numIterations)

    // Clear the default threshold.
    model.clearThreshold()

    // Compute raw scores on the test set.
    val scoreAndLabels = test.map { point =>
      val score = model.predict(point.features)
      (score, point.label)
    }

    // Get evaluation metrics.
    val metrics = new BinaryClassificationMetrics(scoreAndLabels)
    val auROC = metrics.areaUnderROC()

    println(s"Area under ROC = $auROC")

    // Save and load model
    model.save(sc, "target/tmp/scalaSVMWithSGDModel")
    val sameModel = SVMModel.load(sc, "target/tmp/scalaSVMWithSGDModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.tree.model.RandomForestModel
import org.apache.spark.mllib.util.MLUtils
// $example off$

object RandomForestRegressionExample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("RandomForestRegressionExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Split the data into training and test sets (30% held out for testing)
    val splits = data.randomSplit(Array(0.7, 0.3))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a RandomForest model.
    // Empty categoricalFeaturesInfo indicates all features are continuous.
    val numClasses = 2
    val categoricalFeaturesInfo = Map[Int, Int]()
    val numTrees = 3 // Use more in practice.
    val featureSubsetStrategy = "auto" // Let the algorithm choose.
    val impurity = "variance"
    val maxDepth = 4
    val maxBins = 32

    val model = RandomForest.trainRegressor(trainingData, categoricalFeaturesInfo,
      numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)

    // Evaluate model on test instances and compute test error
    val labelsAndPredictions = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testMSE = labelsAndPredictions.map{ case(v, p) => math.pow((v - p), 2)}.mean()
    println(s"Test Mean Squared Error = $testMSE")
    println(s"Learned regression forest model:\n ${model.toDebugString}")

    // Save and load model
    model.save(sc, "target/tmp/myRandomForestRegressionModel")
    val sameModel = RandomForestModel.load(sc, "target/tmp/myRandomForestRegressionModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.{MatrixEntry, RowMatrix}

/**
 * Compute the similar columns of a matrix, using cosine similarity.
 *
 * The input matrix must be stored in row-oriented dense format, one line per row with its entries
 * separated by space. For example,
 * {{{
 * 0.5 1.0
 * 2.0 3.0
 * 4.0 5.0
 * }}}
 * represents a 3-by-2 matrix, whose first row is (0.5, 1.0).
 *
 * Example invocation:
 *
 * bin/run-example mllib.CosineSimilarity \
 * --threshold 0.1 data/mllib/sample_svm_data.txt
 */
object CosineSimilarity {
  case class Params(inputFile: String = null, threshold: Double = 0.1)
    extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("CosineSimilarity") {
      head("CosineSimilarity: an example app.")
      opt[Double]("threshold")
        .required()
        .text(s"threshold similarity: to tradeoff computation vs quality estimate")
        .action((x, c) => c.copy(threshold = x))
      arg[String]("<inputFile>")
        .required()
        .text(s"input file, one row per line, space-separated")
        .action((x, c) => c.copy(inputFile = x))
      note(
        """
          |For example, the following command runs this app on a dataset:
          |
          | ./bin/spark-submit  --class org.apache.spark.examples.mllib.CosineSimilarity \
          | examplesjar.jar \
          | --threshold 0.1 data/mllib/sample_svm_data.txt
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName("CosineSimilarity")
    val sc = new SparkContext(conf)

    // Load and parse the data file.
    val rows = sc.textFile(params.inputFile).map { line =>
      val values = line.split(' ').map(_.toDouble)
      Vectors.dense(values)
    }.cache()
    val mat = new RowMatrix(rows)

    // Compute similar columns perfectly, with brute force.
    val exact = mat.columnSimilarities()

    // Compute similar columns with estimation using DIMSUM
    val approx = mat.columnSimilarities(params.threshold)

    val exactEntries = exact.entries.map { case MatrixEntry(i, j, u) => ((i, j), u) }
    val approxEntries = approx.entries.map { case MatrixEntry(i, j, v) => ((i, j), v) }
    val MAE = exactEntries.leftOuterJoin(approxEntries).values.map {
      case (u, Some(v)) =>
        math.abs(u - v)
      case (u, None) =>
        math.abs(u)
    }.mean()

    println(s"Average absolute error in estimate is: $MAE")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.optimization.{L1Updater, SimpleUpdater, SquaredL2Updater}
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.util.MLUtils

/**
 * An example app for linear regression. Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.LinearRegression
 * }}}
 * A synthetic dataset can be found at `data/mllib/sample_linear_regression_data.txt`.
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
@deprecated("Use ml.regression.LinearRegression or LBFGS", "2.0.0")
object LinearRegression {

  object RegType extends Enumeration {
    type RegType = Value
    val NONE, L1, L2 = Value
  }

  import RegType._

  case class Params(
      input: String = null,
      numIterations: Int = 100,
      stepSize: Double = 1.0,
      regType: RegType = L2,
      regParam: Double = 0.01) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("LinearRegression") {
      head("LinearRegression: an example app for linear regression.")
      opt[Int]("numIterations")
        .text("number of iterations")
        .action((x, c) => c.copy(numIterations = x))
      opt[Double]("stepSize")
        .text(s"initial step size, default: ${defaultParams.stepSize}")
        .action((x, c) => c.copy(stepSize = x))
      opt[String]("regType")
        .text(s"regularization type (${RegType.values.mkString(",")}), " +
        s"default: ${defaultParams.regType}")
        .action((x, c) => c.copy(regType = RegType.withName(x)))
      opt[Double]("regParam")
        .text(s"regularization parameter, default: ${defaultParams.regParam}")
      arg[String]("<input>")
        .required()
        .text("input paths to labeled examples in LIBSVM format")
        .action((x, c) => c.copy(input = x))
      note(
        """
          |For example, the following command runs this app on a synthetic dataset:
          |
          | bin/spark-submit --class org.apache.spark.examples.mllib.LinearRegression \
          |  examples/target/scala-*/spark-examples-*.jar \
          |  data/mllib/sample_linear_regression_data.txt
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"LinearRegression with $params")
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    val examples = MLUtils.loadLibSVMFile(sc, params.input).cache()

    val splits = examples.randomSplit(Array(0.8, 0.2))
    val training = splits(0).cache()
    val test = splits(1).cache()

    val numTraining = training.count()
    val numTest = test.count()
    println(s"Training: $numTraining, test: $numTest.")

    examples.unpersist()

    val updater = params.regType match {
      case NONE => new SimpleUpdater()
      case L1 => new L1Updater()
      case L2 => new SquaredL2Updater()
    }

    val algorithm = new LinearRegressionWithSGD()
    algorithm.optimizer
      .setNumIterations(params.numIterations)
      .setStepSize(params.stepSize)
      .setUpdater(updater)
      .setRegParam(params.regParam)

    val model = algorithm.run(training)

    val prediction = model.predict(test.map(_.features))
    val predictionAndLabel = prediction.zip(test.map(_.label))

    val loss = predictionAndLabel.map { case (p, l) =>
      val err = p - l
      err * err
    }.reduce(_ + _)
    val rmse = math.sqrt(loss / numTest)

    println(s"Test RMSE = $rmse.")

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.rdd.RDD
// $example off$

object CorrelationsExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("CorrelationsExample")
    val sc = new SparkContext(conf)

    // $example on$
    val seriesX: RDD[Double] = sc.parallelize(Array(1, 2, 3, 3, 5))  // a series
    // must have the same number of partitions and cardinality as seriesX
    val seriesY: RDD[Double] = sc.parallelize(Array(11, 22, 33, 33, 555))

    // compute the correlation using Pearson's method. Enter "spearman" for Spearman's method. If a
    // method is not specified, Pearson's method will be used by default.
    val correlation: Double = Statistics.corr(seriesX, seriesY, "pearson")
    println(s"Correlation is: $correlation")

    val data: RDD[Vector] = sc.parallelize(
      Seq(
        Vectors.dense(1.0, 10.0, 100.0),
        Vectors.dense(2.0, 20.0, 200.0),
        Vectors.dense(5.0, 33.0, 366.0))
    )  // note that each Vector is a row and not a column

    // calculate the correlation matrix using Pearson's method. Use "spearman" for Spearman's method
    // If a method is not specified, Pearson's method will be used by default.
    val correlMatrix: Matrix = Statistics.corr(data, "pearson")
    println(correlMatrix.toString)
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.rdd.RDD
// $example off$

object HypothesisTestingKolmogorovSmirnovTestExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("HypothesisTestingKolmogorovSmirnovTestExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data: RDD[Double] = sc.parallelize(Seq(0.1, 0.15, 0.2, 0.3, 0.25))  // an RDD of sample data

    // run a KS test for the sample versus a standard normal distribution
    val testResult = Statistics.kolmogorovSmirnovTest(data, "norm", 0, 1)
    // summary of the test including the p-value, test statistic, and null hypothesis if our p-value
    // indicates significance, we can reject the null hypothesis.
    println(testResult)
    println()

    // perform a KS test using a cumulative distribution function of our making
    val myCDF = Map(0.1 -> 0.2, 0.15 -> 0.6, 0.2 -> 0.05, 0.3 -> 0.05, 0.25 -> 0.1)
    val testResult2 = Statistics.kolmogorovSmirnovTest(data, myCDF)
    println(testResult2)
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.mllib.util.MLUtils

/**
 * An example app for summarizing multivariate data from a file. Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.Correlations
 * }}}
 * By default, this loads a synthetic dataset from `data/mllib/sample_linear_regression_data.txt`.
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object Correlations {

  case class Params(input: String = "data/mllib/sample_linear_regression_data.txt")
    extends AbstractParams[Params]

  def main(args: Array[String]) {

    val defaultParams = Params()

    val parser = new OptionParser[Params]("Correlations") {
      head("Correlations: an example app for computing correlations")
      opt[String]("input")
        .text(s"Input path to labeled examples in LIBSVM format, default: ${defaultParams.input}")
        .action((x, c) => c.copy(input = x))
      note(
        """
        |For example, the following command runs this app on a synthetic dataset:
        |
        | bin/spark-submit --class org.apache.spark.examples.mllib.Correlations \
        |  examples/target/scala-*/spark-examples-*.jar \
        |  --input data/mllib/sample_linear_regression_data.txt
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"Correlations with $params")
    val sc = new SparkContext(conf)

    val examples = MLUtils.loadLibSVMFile(sc, params.input).cache()

    println(s"Summary of data file: ${params.input}")
    println(s"${examples.count()} data points")

    // Calculate label -- feature correlations
    val labelRDD = examples.map(_.label)
    val numFeatures = examples.take(1)(0).features.size
    val corrType = "pearson"
    println()
    println(s"Correlation ($corrType) between label and each feature")
    println(s"Feature\tCorrelation")
    var feature = 0
    while (feature < numFeatures) {
      val featureRDD = examples.map(_.features(feature))
      val corr = Statistics.corr(labelRDD, featureRDD)
      println(s"$feature\t$corr")
      feature += 1
    }
    println()

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.ElementwiseProduct
import org.apache.spark.mllib.linalg.Vectors
// $example off$

object ElementwiseProductExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("ElementwiseProductExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Create some vector data; also works for sparse vectors
    val data = sc.parallelize(Array(Vectors.dense(1.0, 2.0, 3.0), Vectors.dense(4.0, 5.0, 6.0)))

    val transformingVector = Vectors.dense(0.0, 1.0, 2.0)
    val transformer = new ElementwiseProduct(transformingVector)

    // Batch transform and per-row transform give the same results:
    val transformedData = transformer.transform(data)
    val transformedData2 = data.map(x => transformer.transform(x))
    // $example off$

    println("transformedData: ")
    transformedData.foreach(x => println(x))

    println("transformedData2: ")
    transformedData2.foreach(x => println(x))

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.mllib.classification.StreamingLogisticRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.streaming.{Seconds, StreamingContext}

/**
 * Train a logistic regression model on one stream of data and make predictions
 * on another stream, where the data streams arrive as text files
 * into two different directories.
 *
 * The rows of the text files must be labeled data points in the form
 * `(y,[x1,x2,x3,...,xn])`
 * Where n is the number of features, y is a binary label, and
 * n must be the same for train and test.
 *
 * Usage: StreamingLogisticRegression <trainingDir> <testDir> <batchDuration> <numFeatures>
 *
 * To run on your local machine using the two directories `trainingDir` and `testDir`,
 * with updates every 5 seconds, and 2 features per data point, call:
 *    $ bin/run-example mllib.StreamingLogisticRegression trainingDir testDir 5 2
 *
 * As you add text files to `trainingDir` the model will continuously update.
 * Anytime you add text files to `testDir`, you'll see predictions from the current model.
 *
 */
object StreamingLogisticRegression {

  def main(args: Array[String]) {

    if (args.length != 4) {
      System.err.println(
        "Usage: StreamingLogisticRegression <trainingDir> <testDir> <batchDuration> <numFeatures>")
      System.exit(1)
    }

    val conf = new SparkConf().setMaster("local").setAppName("StreamingLogisticRegression")
    val ssc = new StreamingContext(conf, Seconds(args(2).toLong))

    val trainingData = ssc.textFileStream(args(0)).map(LabeledPoint.parse)
    val testData = ssc.textFileStream(args(1)).map(LabeledPoint.parse)

    val model = new StreamingLogisticRegressionWithSGD()
      .setInitialWeights(Vectors.zeros(args(3).toInt))

    model.trainOn(trainingData)
    model.predictOnValues(testData.map(lp => (lp.label, lp.features))).print()

    ssc.start()
    ssc.awaitTermination()

  }

}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.{Word2Vec, Word2VecModel}
// $example off$

object Word2VecExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("Word2VecExample")
    val sc = new SparkContext(conf)

    // $example on$
    val input = sc.textFile("data/mllib/sample_lda_data.txt").map(line => line.split(" ").toSeq)

    val word2vec = new Word2Vec()

    val model = word2vec.fit(input)

    val synonyms = model.findSynonyms("1", 5)

    for((synonym, cosineSimilarity) <- synonyms) {
      println(s"$synonym $cosineSimilarity")
    }

    // Save and load model
    model.save(sc, "myModelPath")
    val sameModel = Word2VecModel.load(sc, "myModelPath")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.fpm.PrefixSpan
// $example off$

object PrefixSpanExample {

  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("PrefixSpanExample")
    val sc = new SparkContext(conf)

    // $example on$
    val sequences = sc.parallelize(Seq(
      Array(Array(1, 2), Array(3)),
      Array(Array(1), Array(3, 2), Array(1, 2)),
      Array(Array(1, 2), Array(5)),
      Array(Array(6))
    ), 2).cache()
    val prefixSpan = new PrefixSpan()
      .setMinSupport(0.5)
      .setMaxPatternLength(5)
    val model = prefixSpan.run(sequences)
    model.freqSequences.collect().foreach { freqSequence =>
      println(
        s"${freqSequence.sequence.map(_.mkString("[", ", ", "]")).mkString("[", ", ", "]")}," +
          s" ${freqSequence.freq}")
    }
    // $example off$

    sc.stop()
  }
}
// scalastyle:off println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.BoostingStrategy
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel
import org.apache.spark.mllib.util.MLUtils
// $example off$

object GradientBoostingRegressionExample {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("GradientBoostedTreesRegressionExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Split the data into training and test sets (30% held out for testing)
    val splits = data.randomSplit(Array(0.7, 0.3))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a GradientBoostedTrees model.
    // The defaultParams for Regression use SquaredError by default.
    val boostingStrategy = BoostingStrategy.defaultParams("Regression")
    boostingStrategy.numIterations = 3 // Note: Use more iterations in practice.
    boostingStrategy.treeStrategy.maxDepth = 5
    // Empty categoricalFeaturesInfo indicates all features are continuous.
    boostingStrategy.treeStrategy.categoricalFeaturesInfo = Map[Int, Int]()

    val model = GradientBoostedTrees.train(trainingData, boostingStrategy)

    // Evaluate model on test instances and compute test error
    val labelsAndPredictions = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testMSE = labelsAndPredictions.map{ case(v, p) => math.pow((v - p), 2)}.mean()
    println(s"Test Mean Squared Error = $testMSE")
    println(s"Learned regression GBT model:\n ${model.toDebugString}")

    // Save and load model
    model.save(sc, "target/tmp/myGradientBoostingRegressionModel")
    val sameModel = GradientBoostedTreesModel.load(sc,
      "target/tmp/myGradientBoostingRegressionModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.{Algo, BoostingStrategy}
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel
import org.apache.spark.rdd.RDD
import org.apache.spark.util.Utils

/**
 * An example runner for Gradient Boosting using decision trees as weak learners. Run with
 * {{{
 * ./bin/run-example mllib.GradientBoostedTreesRunner [options]
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 *
 * Note: This script treats all features as real-valued (not categorical).
 *       To include categorical features, modify categoricalFeaturesInfo.
 */
object GradientBoostedTreesRunner {

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      algo: String = "Classification",
      maxDepth: Int = 5,
      numIterations: Int = 10,
      fracTest: Double = 0.2) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("GradientBoostedTrees") {
      head("GradientBoostedTrees: an example decision tree app.")
      opt[String]("algo")
        .text(s"algorithm (${Algo.values.mkString(",")}), default: ${defaultParams.algo}")
        .action((x, c) => c.copy(algo = x))
      opt[Int]("maxDepth")
        .text(s"max depth of the tree, default: ${defaultParams.maxDepth}")
        .action((x, c) => c.copy(maxDepth = x))
      opt[Int]("numIterations")
        .text(s"number of iterations of boosting," + s" default: ${defaultParams.numIterations}")
        .action((x, c) => c.copy(numIterations = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing.  If given option testInput, " +
          s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[String]("testInput")
        .text(s"input path to test dataset.  If given, option fracTest is ignored." +
          s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest > 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1].")
        } else {
          success
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {

    val conf = new SparkConf().setAppName(s"GradientBoostedTreesRunner with $params")
    val sc = new SparkContext(conf)

    println(s"GradientBoostedTreesRunner with parameters:\n$params")

    // Load training and test data and cache it.
    val (training, test, numClasses) = DecisionTreeRunner.loadDatasets(sc, params.input,
      params.dataFormat, params.testInput, Algo.withName(params.algo), params.fracTest)

    val boostingStrategy = BoostingStrategy.defaultParams(params.algo)
    boostingStrategy.treeStrategy.numClasses = numClasses
    boostingStrategy.numIterations = params.numIterations
    boostingStrategy.treeStrategy.maxDepth = params.maxDepth

    val randomSeed = Utils.random.nextInt()
    if (params.algo == "Classification") {
      val startTime = System.nanoTime()
      val model = GradientBoostedTrees.train(training, boostingStrategy)
      val elapsedTime = (System.nanoTime() - startTime) / 1e9
      println(s"Training time: $elapsedTime seconds")
      if (model.totalNumNodes < 30) {
        println(model.toDebugString) // Print full model.
      } else {
        println(model) // Print model summary.
      }
      val trainAccuracy =
        new MulticlassMetrics(training.map(lp => (model.predict(lp.features), lp.label))).accuracy
      println(s"Train accuracy = $trainAccuracy")
      val testAccuracy =
        new MulticlassMetrics(test.map(lp => (model.predict(lp.features), lp.label))).accuracy
      println(s"Test accuracy = $testAccuracy")
    } else if (params.algo == "Regression") {
      val startTime = System.nanoTime()
      val model = GradientBoostedTrees.train(training, boostingStrategy)
      val elapsedTime = (System.nanoTime() - startTime) / 1e9
      println(s"Training time: $elapsedTime seconds")
      if (model.totalNumNodes < 30) {
        println(model.toDebugString) // Print full model.
      } else {
        println(model) // Print model summary.
      }
      val trainMSE = meanSquaredError(model, training)
      println(s"Train mean squared error = $trainMSE")
      val testMSE = meanSquaredError(model, test)
      println(s"Test mean squared error = $testMSE")
    }

    sc.stop()
  }

  private[mllib] def meanSquaredError(
      model: GradientBoostedTreesModel, data: RDD[LabeledPoint]): Double =
    data.map { y =>
      val err = model.predict(y.features) - y.label
      err * err
    }.mean()
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.util.MLUtils

/**
 * An example app for randomly generated and sampled RDDs. Run with
 * {{{
 * bin/run-example org.apache.spark.examples.mllib.SampledRDDs
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object SampledRDDs {

  case class Params(input: String = "data/mllib/sample_binary_classification_data.txt")
    extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("SampledRDDs") {
      head("SampledRDDs: an example app for randomly generated and sampled RDDs.")
      opt[String]("input")
        .text(s"Input path to labeled examples in LIBSVM format, default: ${defaultParams.input}")
        .action((x, c) => c.copy(input = x))
      note(
        """
        |For example, the following command runs this app:
        |
        | bin/spark-submit --class org.apache.spark.examples.mllib.SampledRDDs \
        |  examples/target/scala-*/spark-examples-*.jar
        """.stripMargin)
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf().setAppName(s"SampledRDDs with $params")
    val sc = new SparkContext(conf)

    val fraction = 0.1 // fraction of data to sample

    val examples = MLUtils.loadLibSVMFile(sc, params.input)
    val numExamples = examples.count()
    if (numExamples == 0) {
      throw new RuntimeException("Error: Data file had no samples to load.")
    }
    println(s"Loaded data with $numExamples examples from file: ${params.input}")

    // Example: RDD.sample() and RDD.takeSample()
    val expectedSampleSize = (numExamples * fraction).toInt
    println(s"Sampling RDD using fraction $fraction.  Expected sample size = $expectedSampleSize.")
    val sampledRDD = examples.sample(withReplacement = true, fraction = fraction)
    println(s"  RDD.sample(): sample has ${sampledRDD.count()} examples")
    val sampledArray = examples.takeSample(withReplacement = true, num = expectedSampleSize)
    println(s"  RDD.takeSample(): sample has ${sampledArray.length} examples")

    println()

    // Example: RDD.sampleByKey() and RDD.sampleByKeyExact()
    val keyedRDD = examples.map { lp => (lp.label.toInt, lp.features) }
    println(s"  Keyed data using label (Int) as key ==> Orig")
    //  Count examples per label in original data.
    val keyCounts = keyedRDD.countByKey()

    //  Subsample, and count examples per label in sampled data. (approximate)
    val fractions = keyCounts.keys.map((_, fraction)).toMap
    val sampledByKeyRDD = keyedRDD.sampleByKey(withReplacement = true, fractions = fractions)
    val keyCountsB = sampledByKeyRDD.countByKey()
    val sizeB = keyCountsB.values.sum
    println(s"  Sampled $sizeB examples using approximate stratified sampling (by label)." +
      " ==> Approx Sample")

    //  Subsample, and count examples per label in sampled data. (approximate)
    val sampledByKeyRDDExact =
      keyedRDD.sampleByKeyExact(withReplacement = true, fractions = fractions)
    val keyCountsBExact = sampledByKeyRDDExact.countByKey()
    val sizeBExact = keyCountsBExact.values.sum
    println(s"  Sampled $sizeBExact examples using exact stratified sampling (by label)." +
      " ==> Exact Sample")

    //  Compare samples
    println(s"   \tFractions of examples with key")
    println(s"Key\tOrig\tApprox Sample\tExact Sample")
    keyCounts.keys.toSeq.sorted.foreach { key =>
      val origFrac = keyCounts(key) / numExamples.toDouble
      val approxFrac = if (sizeB != 0) {
        keyCountsB.getOrElse(key, 0L) / sizeB.toDouble
      } else {
        0
      }
      val exactFrac = if (sizeBExact != 0) {
        keyCountsBExact.getOrElse(key, 0L) / sizeBExact.toDouble
      } else {
        0
      }
      println(s"$key\t$origFrac\t$approxFrac\t$exactFrac")
    }

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.feature.{StandardScaler, StandardScalerModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.util.MLUtils
// $example off$

object StandardScalerExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("StandardScalerExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")

    val scaler1 = new StandardScaler().fit(data.map(x => x.features))
    val scaler2 = new StandardScaler(withMean = true, withStd = true).fit(data.map(x => x.features))
    // scaler3 is an identical model to scaler2, and will produce identical transformations
    val scaler3 = new StandardScalerModel(scaler2.std, scaler2.mean)

    // data1 will be unit variance.
    val data1 = data.map(x => (x.label, scaler1.transform(x.features)))

    // data2 will be unit variance and zero mean.
    val data2 = data.map(x => (x.label, scaler2.transform(Vectors.dense(x.features.toArray))))
    // $example off$

    println("data1: ")
    data1.foreach(x => println(x))

    println("data2: ")
    data2.foreach(x => println(x))

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// $example on$
import org.apache.spark.mllib.linalg.Matrix
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.RowMatrix
// $example off$

object PCAOnRowMatrixExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("PCAOnRowMatrixExample")
    val sc = new SparkContext(conf)

    // $example on$
    val data = Array(
      Vectors.sparse(5, Seq((1, 1.0), (3, 7.0))),
      Vectors.dense(2.0, 0.0, 3.0, 4.0, 5.0),
      Vectors.dense(4.0, 0.0, 0.0, 6.0, 7.0))

    val rows = sc.parallelize(data)

    val mat: RowMatrix = new RowMatrix(rows)

    // Compute the top 4 principal components.
    // Principal components are stored in a local dense matrix.
    val pc: Matrix = mat.computePrincipalComponents(4)

    // Project the rows to the linear space spanned by the top 4 principal components.
    val projected: RowMatrix = mat.multiply(pc)
    // $example off$
    val collect = projected.rows.collect()
    println("Projected Row Matrix of principal component:")
    collect.foreach { vector => println(vector) }

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.{MultivariateStatisticalSummary, Statistics}
// $example off$

object SummaryStatisticsExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("SummaryStatisticsExample")
    val sc = new SparkContext(conf)

    // $example on$
    val observations = sc.parallelize(
      Seq(
        Vectors.dense(1.0, 10.0, 100.0),
        Vectors.dense(2.0, 20.0, 200.0),
        Vectors.dense(3.0, 30.0, 300.0)
      )
    )

    // Compute column summary statistics.
    val summary: MultivariateStatisticalSummary = Statistics.colStats(observations)
    println(summary.mean)  // a dense vector containing the mean value for each column
    println(summary.variance)  // column-wise variance
    println(summary.numNonzeros)  // number of nonzeros in each column
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.SparkConf
// $example on$
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.StreamingLinearRegressionWithSGD
// $example off$
import org.apache.spark.streaming._

/**
 * Train a linear regression model on one stream of data and make predictions
 * on another stream, where the data streams arrive as text files
 * into two different directories.
 *
 * The rows of the text files must be labeled data points in the form
 * `(y,[x1,x2,x3,...,xn])`
 * Where n is the number of features. n must be the same for train and test.
 *
 * Usage: StreamingLinearRegressionExample <trainingDir> <testDir>
 *
 * To run on your local machine using the two directories `trainingDir` and `testDir`,
 * with updates every 5 seconds, and 2 features per data point, call:
 *    $ bin/run-example mllib.StreamingLinearRegressionExample trainingDir testDir
 *
 * As you add text files to `trainingDir` the model will continuously update.
 * Anytime you add text files to `testDir`, you'll see predictions from the current model.
 *
 */
object StreamingLinearRegressionExample {

  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      System.err.println("Usage: StreamingLinearRegressionExample <trainingDir> <testDir>")
      System.exit(1)
    }

    val conf = new SparkConf().setAppName("StreamingLinearRegressionExample")
    val ssc = new StreamingContext(conf, Seconds(1))

    // $example on$
    val trainingData = ssc.textFileStream(args(0)).map(LabeledPoint.parse).cache()
    val testData = ssc.textFileStream(args(1)).map(LabeledPoint.parse)

    val numFeatures = 3
    val model = new StreamingLinearRegressionWithSGD()
      .setInitialWeights(Vectors.zeros(numFeatures))

    model.trainOn(trainingData)
    model.predictOnValues(testData.map(lp => (lp.label, lp.features))).print()

    ssc.start()
    ssc.awaitTermination()
    // $example off$

    ssc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
// $example off$

object BinaryClassificationMetricsExample {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf().setAppName("BinaryClassificationMetricsExample")
    val sc = new SparkContext(conf)
    // $example on$
    // Load training data in LIBSVM format
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_binary_classification_data.txt")

    // Split data into training (60%) and test (40%)
    val Array(training, test) = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    training.cache()

    // Run training algorithm to build the model
    val model = new LogisticRegressionWithLBFGS()
      .setNumClasses(2)
      .run(training)

    // Clear the prediction threshold so the model will return probabilities
    model.clearThreshold

    // Compute raw scores on the test set
    val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
      val prediction = model.predict(features)
      (prediction, label)
    }

    // Instantiate metrics object
    val metrics = new BinaryClassificationMetrics(predictionAndLabels)

    // Precision by threshold
    val precision = metrics.precisionByThreshold
    precision.foreach { case (t, p) =>
      println(s"Threshold: $t, Precision: $p")
    }

    // Recall by threshold
    val recall = metrics.recallByThreshold
    recall.foreach { case (t, r) =>
      println(s"Threshold: $t, Recall: $r")
    }

    // Precision-Recall Curve
    val PRC = metrics.pr

    // F-measure
    val f1Score = metrics.fMeasureByThreshold
    f1Score.foreach { case (t, f) =>
      println(s"Threshold: $t, F-score: $f, Beta = 1")
    }

    val beta = 0.5
    val fScore = metrics.fMeasureByThreshold(beta)
    f1Score.foreach { case (t, f) =>
      println(s"Threshold: $t, F-score: $f, Beta = 0.5")
    }

    // AUPRC
    val auPRC = metrics.areaUnderPR
    println(s"Area under precision-recall curve = $auPRC")

    // Compute thresholds used in ROC and PR curves
    val thresholds = precision.map(_._1)

    // ROC Curve
    val roc = metrics.roc

    // AUROC
    val auROC = metrics.areaUnderROC
    println(s"Area under ROC = $auROC")
    // $example off$
    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.tree.model.DecisionTreeModel
import org.apache.spark.mllib.util.MLUtils
// $example off$

object DecisionTreeClassificationExample {

  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("DecisionTreeClassificationExample")
    val sc = new SparkContext(conf)

    // $example on$
    // Load and parse the data file.
    val data = MLUtils.loadLibSVMFile(sc, "data/mllib/sample_libsvm_data.txt")
    // Split the data into training and test sets (30% held out for testing)
    val splits = data.randomSplit(Array(0.7, 0.3))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a DecisionTree model.
    //  Empty categoricalFeaturesInfo indicates all features are continuous.
    val numClasses = 2
    val categoricalFeaturesInfo = Map[Int, Int]()
    val impurity = "gini"
    val maxDepth = 5
    val maxBins = 32

    val model = DecisionTree.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
      impurity, maxDepth, maxBins)

    // Evaluate model on test instances and compute test error
    val labelAndPreds = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testErr = labelAndPreds.filter(r => r._1 != r._2).count().toDouble / testData.count()
    println(s"Test Error = $testErr")
    println(s"Learned classification tree model:\n ${model.toDebugString}")

    // Save and load model
    model.save(sc, "target/tmp/myDecisionTreeClassificationModel")
    val sameModel = DecisionTreeModel.load(sc, "target/tmp/myDecisionTreeClassificationModel")
    // $example off$

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.mllib

import scala.reflect.runtime.universe._

/**
 * Abstract class for parameter case classes.
 * This overrides the [[toString]] method to print all case class fields by name and value.
 * @tparam T  Concrete parameter class.
 */
abstract class AbstractParams[T: TypeTag] {

  private def tag: TypeTag[T] = typeTag[T]

  /**
   * Finds all case class fields in concrete class instance, and outputs them in JSON-style format:
   * {
   *   [field name]:\t[field value]\n
   *   [field name]:\t[field value]\n
   *   ...
   * }
   */
  override def toString: String = {
    val tpe = tag.tpe
    val allAccessors = tpe.decls.collect {
      case m: MethodSymbol if m.isCaseAccessor => m
    }
    val mirror = runtimeMirror(getClass.getClassLoader)
    val instanceMirror = mirror.reflect(this)
    allAccessors.map { f =>
      val paramName = f.name.toString
      val fieldMirror = instanceMirror.reflectField(f)
      val paramValue = fieldMirror.get
      s"  $paramName:\t$paramValue"
    }.mkString("{\n", ",\n", "\n}")
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.mllib

import org.apache.log4j.{Level, Logger}
import scopt.OptionParser

import org.apache.spark.{SparkConf, SparkContext}
// $example on$
import org.apache.spark.mllib.clustering.PowerIterationClustering
// $example off$
import org.apache.spark.rdd.RDD

/**
 * An example Power Iteration Clustering app.
 * http://www.cs.cmu.edu/~frank/papers/icml2010-pic-final.pdf
 * Takes an input of K concentric circles and the number of points in the innermost circle.
 * The output should be K clusters - each cluster containing precisely the points associated
 * with each of the input circles.
 *
 * Run with
 * {{{
 * ./bin/run-example mllib.PowerIterationClusteringExample [options]
 *
 * Where options include:
 *   k:  Number of circles/clusters
 *   n:  Number of sampled points on innermost circle.. There are proportionally more points
 *      within the outer/larger circles
 *   maxIterations:   Number of Power Iterations
 * }}}
 *
 * Here is a sample run and output:
 *
 * ./bin/run-example mllib.PowerIterationClusteringExample -k 2 --n 10 --maxIterations 15
 *
 * Cluster assignments: 1 -> [0,1,2,3,4,5,6,7,8,9],
 *   0 -> [10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29]
 *
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object PowerIterationClusteringExample {

  case class Params(
      k: Int = 2,
      numPoints: Int = 10,
      maxIterations: Int = 15
    ) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("PowerIterationClusteringExample") {
      head("PowerIterationClusteringExample: an example PIC app using concentric circles.")
      opt[Int]('k', "k")
        .text(s"number of circles (clusters), default: ${defaultParams.k}")
        .action((x, c) => c.copy(k = x))
      opt[Int]('n', "n")
        .text(s"number of points in smallest circle, default: ${defaultParams.numPoints}")
        .action((x, c) => c.copy(numPoints = x))
      opt[Int]("maxIterations")
        .text(s"number of iterations, default: ${defaultParams.maxIterations}")
        .action((x, c) => c.copy(maxIterations = x))
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val conf = new SparkConf()
      .setMaster("local")
      .setAppName(s"PowerIterationClustering with $params")
    val sc = new SparkContext(conf)

    Logger.getRootLogger.setLevel(Level.WARN)

    // $example on$
    val circlesRdd = generateCirclesRdd(sc, params.k, params.numPoints)
    val model = new PowerIterationClustering()
      .setK(params.k)
      .setMaxIterations(params.maxIterations)
      .setInitializationMode("degree")
      .run(circlesRdd)

    val clusters = model.assignments.collect().groupBy(_.cluster).mapValues(_.map(_.id))
    val assignments = clusters.toList.sortBy { case (k, v) => v.length }
    val assignmentsStr = assignments
      .map { case (k, v) =>
        s"$k -> ${v.sorted.mkString("[", ",", "]")}"
      }.mkString(", ")
    val sizesStr = assignments.map {
      _._2.length
    }.sorted.mkString("(", ",", ")")
    println(s"Cluster assignments: $assignmentsStr\ncluster sizes: $sizesStr")
    // $example off$

    sc.stop()
  }

  def generateCircle(radius: Double, n: Int): Seq[(Double, Double)] = {
    Seq.tabulate(n) { i =>
      val theta = 2.0 * math.Pi * i / n
      (radius * math.cos(theta), radius * math.sin(theta))
    }
  }

  def generateCirclesRdd(
      sc: SparkContext,
      nCircles: Int,
      nPoints: Int): RDD[(Long, Long, Double)] = {
    val points = (1 to nCircles).flatMap { i =>
      generateCircle(i, i * nPoints)
    }.zipWithIndex
    val rdd = sc.parallelize(points)
    val distancesRdd = rdd.cartesian(rdd).flatMap { case (((x0, y0), i0), ((x1, y1), i1)) =>
      if (i0 < i1) {
        Some((i0.toLong, i1.toLong, gaussianSimilarity((x0, y0), (x1, y1))))
      } else {
        None
      }
    }
    distancesRdd
  }

  /**
   * Gaussian Similarity:  http://en.wikipedia.org/wiki/Radial_basis_function_kernel
   */
  def gaussianSimilarity(p1: (Double, Double), p2: (Double, Double)): Double = {
    val ssquares = (p1._1 - p2._1) * (p1._1 - p2._1) + (p1._2 - p2._2) * (p1._2 - p2._2)
    math.exp(-ssquares / 2.0)
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import breeze.linalg.{DenseVector, Vector}

/**
 * Logistic regression based classification.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.classification.LogisticRegression.
 */
object LocalFileLR {
  val D = 10   // Number of dimensions
  val rand = new Random(42)

  case class DataPoint(x: Vector[Double], y: Double)

  def parsePoint(line: String): DataPoint = {
    val nums = line.split(' ').map(_.toDouble)
    DataPoint(new DenseVector(nums.slice(1, D + 1)), nums(0))
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of Logistic Regression and is given as an example!
        |Please use org.apache.spark.ml.classification.LogisticRegression
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    showWarning()

    val fileSrc = scala.io.Source.fromFile(args(0))
    val lines = fileSrc.getLines().toArray
    val points = lines.map(parsePoint)
    val ITERATIONS = args(1).toInt

    // Initialize w to a random value
    val w = DenseVector.fill(D) {2 * rand.nextDouble - 1}
    println(s"Initial w: $w")

    for (i <- 1 to ITERATIONS) {
      println(s"On iteration $i")
      val gradient = DenseVector.zeros[Double](D)
      for (p <- points) {
        val scale = (1 / (1 + math.exp(-p.y * (w.dot(p.x)))) - 1) * p.y
        gradient += p.x * scale
      }
      w -= gradient
    }

    fileSrc.close()
    println(s"Final w: $w")
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import scala.math.exp

import breeze.linalg.{DenseVector, Vector}

import org.apache.spark.sql.SparkSession

/**
 * Logistic regression based classification.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.classification.LogisticRegression.
 */
object SparkHdfsLR {
  val D = 10   // Number of dimensions
  val rand = new Random(42)

  case class DataPoint(x: Vector[Double], y: Double)

  def parsePoint(line: String): DataPoint = {
    val tok = new java.util.StringTokenizer(line, " ")
    val y = tok.nextToken.toDouble
    val x = new Array[Double](D)
    var i = 0
    while (i < D) {
      x(i) = tok.nextToken.toDouble; i += 1
    }
    DataPoint(new DenseVector(x), y)
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of Logistic Regression and is given as an example!
        |Please use org.apache.spark.ml.classification.LogisticRegression
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Usage: SparkHdfsLR <file> <iters>")
      System.exit(1)
    }

    showWarning()

    val spark = SparkSession
      .builder
      .appName("SparkHdfsLR")
      .getOrCreate()

    val inputPath = args(0)
    val lines = spark.read.textFile(inputPath).rdd

    val points = lines.map(parsePoint).cache()
    val ITERATIONS = args(1).toInt

    // Initialize w to a random value
    val w = DenseVector.fill(D) {2 * rand.nextDouble - 1}
    println(s"Initial w: $w")

    for (i <- 1 to ITERATIONS) {
      println(s"On iteration $i")
      val gradient = points.map { p =>
        p.x * (1 / (1 + exp(-p.y * (w.dot(p.x)))) - 1) * p.y
      }.reduce(_ + _)
      w -= gradient
    }

    println(s"Final w: $w")
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.spark.rdd.RDD
import org.apache.spark.sql.SparkSession


/**
 * Usage: MultiBroadcastTest [partitions] [numElem]
 */
object MultiBroadcastTest {
  def main(args: Array[String]) {

    val spark = SparkSession
      .builder
      .appName("Multi-Broadcast Test")
      .getOrCreate()

    val slices = if (args.length > 0) args(0).toInt else 2
    val num = if (args.length > 1) args(1).toInt else 1000000

    val arr1 = new Array[Int](num)
    for (i <- 0 until arr1.length) {
      arr1(i) = i
    }

    val arr2 = new Array[Int](num)
    for (i <- 0 until arr2.length) {
      arr2(i) = i
    }

    val barr1 = spark.sparkContext.broadcast(arr1)
    val barr2 = spark.sparkContext.broadcast(arr2)
    val observedSizes: RDD[(Int, Int)] = spark.sparkContext.parallelize(1 to 10, slices).map { _ =>
      (barr1.value.length, barr2.value.length)
    }
    // Collect the small RDD so we can print the observed sizes locally.
    observedSizes.collect().foreach(i => println(i))

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.spark.{SparkConf, SparkContext}

/**
 * Executes a roll up-style query against Apache logs.
 *
 * Usage: LogQuery [logFile]
 */
object LogQuery {
  val exampleApacheLogs = List(
    """10.10.10.10 - "FRED" [18/Jan/2013:17:56:07 +1100] "GET http://images.com/2013/Generic.jpg
      | HTTP/1.1" 304 315 "http://referall.com/" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1;
      | GTB7.4; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR
      | 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 1.0.3705; .NET CLR 1.1.4322; .NET CLR
      | 3.5.30729; Release=ARP)" "UD-1" - "image/jpeg" "whatever" 0.350 "-" - "" 265 923 934 ""
      | 62.24.11.25 images.com 1358492167 - Whatup""".stripMargin.split('\n').mkString,
    """10.10.10.10 - "FRED" [18/Jan/2013:18:02:37 +1100] "GET http://images.com/2013/Generic.jpg
      | HTTP/1.1" 304 306 "http:/referall.com" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1;
      | GTB7.4; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648; .NET CLR
      | 3.5.21022; .NET CLR 3.0.4506.2152; .NET CLR 1.0.3705; .NET CLR 1.1.4322; .NET CLR
      | 3.5.30729; Release=ARP)" "UD-1" - "image/jpeg" "whatever" 0.352 "-" - "" 256 977 988 ""
      | 0 73.23.2.15 images.com 1358492557 - Whatup""".stripMargin.split('\n').mkString
  )

  def main(args: Array[String]) {

    val sparkConf = new SparkConf().setAppName("Log Query")
    val sc = new SparkContext(sparkConf)

    val dataSet =
      if (args.length == 1) sc.textFile(args(0)) else sc.parallelize(exampleApacheLogs)
    // scalastyle:off
    val apacheLogRegex =
      """^([\d.]+) (\S+) (\S+) \[([\w\d:/]+\s[+\-]\d{4})\] "(.+?)" (\d{3}) ([\d\-]+) "([^"]+)" "([^"]+)".*""".r
    // scalastyle:on
    /** Tracks the total query count and number of aggregate bytes for a particular group. */
    class Stats(val count: Int, val numBytes: Int) extends Serializable {
      def merge(other: Stats): Stats = new Stats(count + other.count, numBytes + other.numBytes)
      override def toString: String = "bytes=%s\tn=%s".format(numBytes, count)
    }

    def extractKey(line: String): (String, String, String) = {
      apacheLogRegex.findFirstIn(line) match {
        case Some(apacheLogRegex(ip, _, user, dateTime, query, status, bytes, referer, ua)) =>
          if (user != "\"-\"") (ip, user, query)
          else (null, null, null)
        case _ => (null, null, null)
      }
    }

    def extractStats(line: String): Stats = {
      apacheLogRegex.findFirstIn(line) match {
        case Some(apacheLogRegex(ip, _, user, dateTime, query, status, bytes, referer, ua)) =>
          new Stats(1, bytes.toInt)
        case _ => new Stats(1, 0)
      }
    }

    dataSet.map(line => (extractKey(line), extractStats(line)))
      .reduceByKey((a, b) => a.merge(b))
      .collect().foreach{
        case (user, query) => println("%s\t%s".format(user, query))}

    sc.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.concurrent.TimeUnit

import org.apache.spark.sql.SparkSession


object HdfsTest {

  /** Usage: HdfsTest [file] */
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("Usage: HdfsTest <file>")
      System.exit(1)
    }
    val spark = SparkSession
      .builder
      .appName("HdfsTest")
      .getOrCreate()
    val file = spark.read.text(args(0)).rdd
    val mapped = file.map(s => s.length).cache()
    for (iter <- 1 to 10) {
      val startTimeNs = System.nanoTime()
      for (x <- mapped) { x + 2 }
      val durationMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTimeNs)
      println(s"Iteration $iter took $durationMs ms")
    }
    println(s"File contents: ${file.map(_.toString).take(1).mkString(",").slice(0, 10)}")
    println(s"Returned length(s) of: ${file.map(_.length).sum().toString}")
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import org.apache.spark.sql.SparkSession

/**
 * Usage: GroupByTest [numMappers] [numKVPairs] [KeySize] [numReducers]
 */
object GroupByTest {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("GroupBy Test")
      .getOrCreate()

    val numMappers = if (args.length > 0) args(0).toInt else 2
    val numKVPairs = if (args.length > 1) args(1).toInt else 1000
    val valSize = if (args.length > 2) args(2).toInt else 1000
    val numReducers = if (args.length > 3) args(3).toInt else numMappers

    val pairs1 = spark.sparkContext.parallelize(0 until numMappers, numMappers).flatMap { p =>
      val ranGen = new Random
      val arr1 = new Array[(Int, Array[Byte])](numKVPairs)
      for (i <- 0 until numKVPairs) {
        val byteArr = new Array[Byte](valSize)
        ranGen.nextBytes(byteArr)
        arr1(i) = (ranGen.nextInt(Int.MaxValue), byteArr)
      }
      arr1
    }.cache()
    // Enforce that everything has been calculated and in cache
    pairs1.count()

    println(pairs1.groupByKey(numReducers).count())

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import scala.collection.JavaConverters._

import org.apache.spark.util.Utils

/**
 * Prints out environmental information, sleeps, and then exits. Made to
 * test driver submission in the standalone scheduler.
 */
object DriverSubmissionTest {
  def main(args: Array[String]) {
    if (args.length < 1) {
      println("Usage: DriverSubmissionTest <seconds-to-sleep>")
      System.exit(0)
    }
    val numSecondsToSleep = args(0).toInt

    val env = System.getenv()
    val properties = Utils.getSystemProperties

    println("Environment variables containing SPARK_TEST:")
    env.asScala.filter { case (k, _) => k.contains("SPARK_TEST")}.foreach(println)

    println("System properties containing spark.test:")
    properties.filter { case (k, _) => k.toString.contains("spark.test") }.foreach(println)

    for (i <- 1 until numSecondsToSleep) {
      println(s"Alive for $i out of $numSecondsToSleep seconds")
      Thread.sleep(1000)
    }
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import org.apache.spark.sql.SparkSession

/**
 * Usage: GroupByTest [numMappers] [numKVPairs] [KeySize] [numReducers]
 */
object SkewedGroupByTest {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("GroupBy Test")
      .getOrCreate()

    val numMappers = if (args.length > 0) args(0).toInt else 2
    var numKVPairs = if (args.length > 1) args(1).toInt else 1000
    val valSize = if (args.length > 2) args(2).toInt else 1000
    val numReducers = if (args.length > 3) args(3).toInt else numMappers

    val pairs1 = spark.sparkContext.parallelize(0 until numMappers, numMappers).flatMap { p =>
      val ranGen = new Random

      // map output sizes linearly increase from the 1st to the last
      numKVPairs = (1.0 * (p + 1) / numMappers * numKVPairs).toInt

      val arr1 = new Array[(Int, Array[Byte])](numKVPairs)
      for (i <- 0 until numKVPairs) {
        val byteArr = new Array[Byte](valSize)
        ranGen.nextBytes(byteArr)
        arr1(i) = (ranGen.nextInt(Int.MaxValue), byteArr)
      }
      arr1
    }.cache()
    // Enforce that everything has been calculated and in cache
    pairs1.count()

    println(pairs1.groupByKey(numReducers).count())

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.io.File

import scala.io.Source._

import org.apache.hadoop.fs.FileSystem
import org.apache.hadoop.fs.Path

import org.apache.spark.sql.SparkSession

/**
 * Simple test for reading and writing to a distributed
 * file system.  This example does the following:
 *
 *   1. Reads local file
 *   2. Computes word count on local file
 *   3. Writes local file to a DFS
 *   4. Reads the file back from the DFS
 *   5. Computes word count on the file using Spark
 *   6. Compares the word count results
 */
object DFSReadWriteTest {

  private var localFilePath: File = new File(".")
  private var dfsDirPath: String = ""

  private val NPARAMS = 2

  private def readFile(filename: String): List[String] = {
    val lineIter: Iterator[String] = fromFile(filename).getLines()
    val lineList: List[String] = lineIter.toList
    lineList
  }

  private def printUsage(): Unit = {
    val usage = """DFS Read-Write Test
    |Usage: localFile dfsDir
    |localFile - (string) local file to use in test
    |dfsDir - (string) DFS directory for read/write tests""".stripMargin

    println(usage)
  }

  private def parseArgs(args: Array[String]): Unit = {
    if (args.length != NPARAMS) {
      printUsage()
      System.exit(1)
    }

    var i = 0

    localFilePath = new File(args(i))
    if (!localFilePath.exists) {
      System.err.println(s"Given path (${args(i)}) does not exist")
      printUsage()
      System.exit(1)
    }

    if (!localFilePath.isFile) {
      System.err.println(s"Given path (${args(i)}) is not a file")
      printUsage()
      System.exit(1)
    }

    i += 1
    dfsDirPath = args(i)
  }

  def runLocalWordCount(fileContents: List[String]): Int = {
    fileContents.flatMap(_.split(" "))
      .flatMap(_.split("\t"))
      .filter(_.nonEmpty)
      .groupBy(w => w)
      .mapValues(_.size)
      .values
      .sum
  }

  def main(args: Array[String]): Unit = {
    parseArgs(args)

    println("Performing local word count")
    val fileContents = readFile(localFilePath.toString())
    val localWordCount = runLocalWordCount(fileContents)

    println("Creating SparkSession")
    val spark = SparkSession
      .builder
      .appName("DFS Read Write Test")
      .getOrCreate()

    println("Writing local file to DFS")
    val dfsFilename = s"$dfsDirPath/dfs_read_write_test"

    // delete file if exists
    val fs = FileSystem.get(spark.sessionState.newHadoopConf())
    if (fs.exists(new Path(dfsFilename))) {
        fs.delete(new Path(dfsFilename), true)
    }

    val fileRDD = spark.sparkContext.parallelize(fileContents)
    fileRDD.saveAsTextFile(dfsFilename)

    println("Reading file from DFS and running Word Count")
    val readFileRDD = spark.sparkContext.textFile(dfsFilename)

    val dfsWordCount = readFileRDD
      .flatMap(_.split(" "))
      .flatMap(_.split("\t"))
      .filter(_.nonEmpty)
      .map(w => (w, 1))
      .countByKey()
      .values
      .sum

    spark.stop()
    if (localWordCount == dfsWordCount) {
      println(s"Success! Local Word Count $localWordCount and " +
        s"DFS Word Count $dfsWordCount agree.")
    } else {
      println(s"Failure! Local Word Count $localWordCount " +
        s"and DFS Word Count $dfsWordCount disagree.")
    }
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import scala.math.random

object LocalPi {
  def main(args: Array[String]) {
    var count = 0
    for (i <- 1 to 100000) {
      val x = random * 2 - 1
      val y = random * 2 - 1
      if (x*x + y*y <= 1) count += 1
    }
    println(s"Pi is roughly ${4 * count / 100000.0}")
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import java.util.Random

import scala.math.exp

import breeze.linalg.{DenseVector, Vector}

import org.apache.spark.sql.SparkSession

/**
 * Logistic regression based classification.
 * Usage: SparkLR [partitions]
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.classification.LogisticRegression.
 */
object SparkLR {
  val N = 10000  // Number of data points
  val D = 10   // Number of dimensions
  val R = 0.7  // Scaling factor
  val ITERATIONS = 5
  val rand = new Random(42)

  case class DataPoint(x: Vector[Double], y: Double)

  def generateData: Array[DataPoint] = {
    def generatePoint(i: Int): DataPoint = {
      val y = if (i % 2 == 0) -1 else 1
      val x = DenseVector.fill(D) {rand.nextGaussian + y * R}
      DataPoint(x, y)
    }
    Array.tabulate(N)(generatePoint)
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of Logistic Regression and is given as an example!
        |Please use org.apache.spark.ml.classification.LogisticRegression
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    showWarning()

    val spark = SparkSession
      .builder
      .appName("SparkLR")
      .getOrCreate()

    val numSlices = if (args.length > 0) args(0).toInt else 2
    val points = spark.sparkContext.parallelize(generateData, numSlices).cache()

    // Initialize w to a random value
    val w = DenseVector.fill(D) {2 * rand.nextDouble - 1}
    println(s"Initial w: $w")

    for (i <- 1 to ITERATIONS) {
      println(s"On iteration $i")
      val gradient = points.map { p =>
        p.x * (1 / (1 + exp(-p.y * (w.dot(p.x)))) - 1) * p.y
      }.reduce(_ + _)
      w -= gradient
    }

    println(s"Final w: $w")

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.pythonconverters

import java.util.{Collection => JCollection, Map => JMap}

import scala.collection.JavaConverters._

import org.apache.avro.Schema
import org.apache.avro.Schema.Type._
import org.apache.avro.generic.{GenericFixed, IndexedRecord}
import org.apache.avro.mapred.AvroWrapper

import org.apache.spark.SparkException
import org.apache.spark.api.python.Converter


object AvroConversionUtil extends Serializable {
  def fromAvro(obj: Any, schema: Schema): Any = {
    if (obj == null) {
      return null
    }
    schema.getType match {
      case UNION => unpackUnion(obj, schema)
      case ARRAY => unpackArray(obj, schema)
      case FIXED => unpackFixed(obj, schema)
      case MAP => unpackMap(obj, schema)
      case BYTES => unpackBytes(obj)
      case RECORD => unpackRecord(obj)
      case STRING => obj.toString
      case ENUM => obj.toString
      case NULL => obj
      case BOOLEAN => obj
      case DOUBLE => obj
      case FLOAT => obj
      case INT => obj
      case LONG => obj
      case other => throw new SparkException(s"Unknown Avro schema type ${other.getName}")
    }
  }

  def unpackRecord(obj: Any): JMap[String, Any] = {
    val map = new java.util.HashMap[String, Any]
    obj match {
      case record: IndexedRecord =>
        record.getSchema.getFields.asScala.zipWithIndex.foreach { case (f, i) =>
          map.put(f.name, fromAvro(record.get(i), f.schema))
        }
      case other => throw new SparkException(
        s"Unsupported RECORD type ${other.getClass.getName}")
    }
    map
  }

  def unpackMap(obj: Any, schema: Schema): JMap[String, Any] = {
    obj.asInstanceOf[JMap[_, _]].asScala.map { case (key, value) =>
      (key.toString, fromAvro(value, schema.getValueType))
    }.asJava
  }

  def unpackFixed(obj: Any, schema: Schema): Array[Byte] = {
    unpackBytes(obj.asInstanceOf[GenericFixed].bytes())
  }

  def unpackBytes(obj: Any): Array[Byte] = {
    val bytes: Array[Byte] = obj match {
      case buf: java.nio.ByteBuffer =>
        val arr = new Array[Byte](buf.remaining())
        buf.get(arr)
        arr
      case arr: Array[Byte] => arr
      case other => throw new SparkException(
        s"Unknown BYTES type ${other.getClass.getName}")
    }
    val bytearray = new Array[Byte](bytes.length)
    System.arraycopy(bytes, 0, bytearray, 0, bytes.length)
    bytearray
  }

  def unpackArray(obj: Any, schema: Schema): JCollection[Any] = obj match {
    case c: JCollection[_] =>
      c.asScala.map(fromAvro(_, schema.getElementType)).toSeq.asJava
    case arr: Array[_] if arr.getClass.getComponentType.isPrimitive =>
      arr.toSeq.asJava.asInstanceOf[JCollection[Any]]
    case arr: Array[_] =>
      arr.map(fromAvro(_, schema.getElementType)).toSeq.asJava
    case other => throw new SparkException(
      s"Unknown ARRAY type ${other.getClass.getName}")
  }

  def unpackUnion(obj: Any, schema: Schema): Any = {
    schema.getTypes.asScala.toList match {
      case List(s) => fromAvro(obj, s)
      case List(n, s) if n.getType == NULL => fromAvro(obj, s)
      case List(s, n) if n.getType == NULL => fromAvro(obj, s)
      case _ => throw new SparkException(
        "Unions may only consist of a concrete type and null")
    }
  }
}

/**
 * Implementation of [[org.apache.spark.api.python.Converter]] that converts
 * an Avro IndexedRecord (e.g., derived from AvroParquetInputFormat) to a Java Map.
 */
class IndexedRecordToJavaConverter extends Converter[IndexedRecord, JMap[String, Any]]{
  override def convert(record: IndexedRecord): JMap[String, Any] = {
    if (record == null) {
      return null
    }
    val map = new java.util.HashMap[String, Any]
    AvroConversionUtil.unpackRecord(record)
  }
}

/**
 * Implementation of [[org.apache.spark.api.python.Converter]] that converts
 * an Avro Record wrapped in an AvroKey (or AvroValue) to a Java Map. It tries
 * to work with all 3 Avro data mappings (Generic, Specific and Reflect).
 */
class AvroWrapperToJavaConverter extends Converter[Any, Any] {
  override def convert(obj: Any): Any = {
    if (obj == null) {
      return null
    }
    obj.asInstanceOf[AvroWrapper[_]].datum() match {
      case null => null
      case record: IndexedRecord => AvroConversionUtil.unpackRecord(record)
      case other => throw new SparkException(
        s"Unsupported top-level Avro data type ${other.getClass.getName}")
    }
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import org.apache.commons.math3.linear._

import org.apache.spark.sql.SparkSession

/**
 * Alternating least squares matrix factorization.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.recommendation.ALS.
 */
object SparkALS {

  // Parameters set through command line arguments
  var M = 0 // Number of movies
  var U = 0 // Number of users
  var F = 0 // Number of features
  var ITERATIONS = 0
  val LAMBDA = 0.01 // Regularization coefficient

  def generateR(): RealMatrix = {
    val mh = randomMatrix(M, F)
    val uh = randomMatrix(U, F)
    mh.multiply(uh.transpose())
  }

  def rmse(targetR: RealMatrix, ms: Array[RealVector], us: Array[RealVector]): Double = {
    val r = new Array2DRowRealMatrix(M, U)
    for (i <- 0 until M; j <- 0 until U) {
      r.setEntry(i, j, ms(i).dotProduct(us(j)))
    }
    val diffs = r.subtract(targetR)
    var sumSqs = 0.0
    for (i <- 0 until M; j <- 0 until U) {
      val diff = diffs.getEntry(i, j)
      sumSqs += diff * diff
    }
    math.sqrt(sumSqs / (M.toDouble * U.toDouble))
  }

  def update(i: Int, m: RealVector, us: Array[RealVector], R: RealMatrix) : RealVector = {
    val U = us.length
    val F = us(0).getDimension
    var XtX: RealMatrix = new Array2DRowRealMatrix(F, F)
    var Xty: RealVector = new ArrayRealVector(F)
    // For each user that rated the movie
    for (j <- 0 until U) {
      val u = us(j)
      // Add u * u^t to XtX
      XtX = XtX.add(u.outerProduct(u))
      // Add u * rating to Xty
      Xty = Xty.add(u.mapMultiply(R.getEntry(i, j)))
    }
    // Add regularization coefs to diagonal terms
    for (d <- 0 until F) {
      XtX.addToEntry(d, d, LAMBDA * U)
    }
    // Solve it with Cholesky
    new CholeskyDecomposition(XtX).getSolver.solve(Xty)
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of ALS and is given as an example!
        |Please use org.apache.spark.ml.recommendation.ALS
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    var slices = 0

    val options = (0 to 4).map(i => if (i < args.length) Some(args(i)) else None)

    options.toArray match {
      case Array(m, u, f, iters, slices_) =>
        M = m.getOrElse("100").toInt
        U = u.getOrElse("500").toInt
        F = f.getOrElse("10").toInt
        ITERATIONS = iters.getOrElse("5").toInt
        slices = slices_.getOrElse("2").toInt
      case _ =>
        System.err.println("Usage: SparkALS [M] [U] [F] [iters] [partitions]")
        System.exit(1)
    }

    showWarning()

    println(s"Running with M=$M, U=$U, F=$F, iters=$ITERATIONS")

    val spark = SparkSession
      .builder
      .appName("SparkALS")
      .getOrCreate()

    val sc = spark.sparkContext

    val R = generateR()

    // Initialize m and u randomly
    var ms = Array.fill(M)(randomVector(F))
    var us = Array.fill(U)(randomVector(F))

    // Iteratively update movies then users
    val Rc = sc.broadcast(R)
    var msb = sc.broadcast(ms)
    var usb = sc.broadcast(us)
    for (iter <- 1 to ITERATIONS) {
      println(s"Iteration $iter:")
      ms = sc.parallelize(0 until M, slices)
                .map(i => update(i, msb.value(i), usb.value, Rc.value))
                .collect()
      msb = sc.broadcast(ms) // Re-broadcast ms because it was updated
      us = sc.parallelize(0 until U, slices)
                .map(i => update(i, usb.value(i), msb.value, Rc.value.transpose()))
                .collect()
      usb = sc.broadcast(us) // Re-broadcast us because it was updated
      println(s"RMSE = ${rmse(R, ms, us)}")
    }
    spark.stop()
  }

  private def randomVector(n: Int): RealVector =
    new ArrayRealVector(Array.fill(n)(math.random))

  private def randomMatrix(rows: Int, cols: Int): RealMatrix =
    new Array2DRowRealMatrix(Array.fill(rows, cols)(math.random))

}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.{CountVectorizer, CountVectorizerModel}
// $example off$
import org.apache.spark.sql.SparkSession

object CountVectorizerExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("CountVectorizerExample")
      .getOrCreate()

    // $example on$
    val df = spark.createDataFrame(Seq(
      (0, Array("a", "b", "c")),
      (1, Array("a", "b", "b", "c", "a"))
    )).toDF("id", "words")

    // fit a CountVectorizerModel from the corpus
    val cvModel: CountVectorizerModel = new CountVectorizer()
      .setInputCol("words")
      .setOutputCol("features")
      .setVocabSize(3)
      .setMinDF(2)
      .fit(df)

    // alternatively, define CountVectorizerModel with a-priori vocabulary
    val cvm = new CountVectorizerModel(Array("a", "b", "c"))
      .setInputCol("words")
      .setOutputCol("features")

    cvModel.transform(df).show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println


/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.Bucketizer
// $example off$
import org.apache.spark.sql.SparkSession
/**
 * An example for Bucketizer.
 * Run with
 * {{{
 * bin/run-example ml.BucketizerExample
 * }}}
 */
object BucketizerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("BucketizerExample")
      .getOrCreate()

    // $example on$
    val splits = Array(Double.NegativeInfinity, -0.5, 0.0, 0.5, Double.PositiveInfinity)

    val data = Array(-999.9, -0.5, -0.3, 0.0, 0.2, 999.9)
    val dataFrame = spark.createDataFrame(data.map(Tuple1.apply)).toDF("features")

    val bucketizer = new Bucketizer()
      .setInputCol("features")
      .setOutputCol("bucketedFeatures")
      .setSplits(splits)

    // Transform original data into its bucket index.
    val bucketedData = bucketizer.transform(dataFrame)

    println(s"Bucketizer output with ${bucketizer.getSplits.length-1} buckets")
    bucketedData.show()
    // $example off$

    // $example on$
    val splitsArray = Array(
      Array(Double.NegativeInfinity, -0.5, 0.0, 0.5, Double.PositiveInfinity),
      Array(Double.NegativeInfinity, -0.3, 0.0, 0.3, Double.PositiveInfinity))

    val data2 = Array(
      (-999.9, -999.9),
      (-0.5, -0.2),
      (-0.3, -0.1),
      (0.0, 0.0),
      (0.2, 0.4),
      (999.9, 999.9))
    val dataFrame2 = spark.createDataFrame(data2).toDF("features1", "features2")

    val bucketizer2 = new Bucketizer()
      .setInputCols(Array("features1", "features2"))
      .setOutputCols(Array("bucketedFeatures1", "bucketedFeatures2"))
      .setSplitsArray(splitsArray)

    // Transform original data into its bucket index.
    val bucketedData2 = bucketizer2.transform(dataFrame2)

    println(s"Bucketizer output with [" +
      s"${bucketizer2.getSplitsArray(0).length-1}, " +
      s"${bucketizer2.getSplitsArray(1).length-1}] buckets for each input column")
    bucketedData2.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.regression.LinearRegression
import org.apache.spark.ml.tuning.{ParamGridBuilder, TrainValidationSplit}
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * A simple example demonstrating model selection using TrainValidationSplit.
 *
 * Run with
 * {{{
 * bin/run-example ml.ModelSelectionViaTrainValidationSplitExample
 * }}}
 */
object ModelSelectionViaTrainValidationSplitExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("ModelSelectionViaTrainValidationSplitExample")
      .getOrCreate()

    // $example on$
    // Prepare training and test data.
    val data = spark.read.format("libsvm").load("data/mllib/sample_linear_regression_data.txt")
    val Array(training, test) = data.randomSplit(Array(0.9, 0.1), seed = 12345)

    val lr = new LinearRegression()
        .setMaxIter(10)

    // We use a ParamGridBuilder to construct a grid of parameters to search over.
    // TrainValidationSplit will try all combinations of values and determine best model using
    // the evaluator.
    val paramGrid = new ParamGridBuilder()
      .addGrid(lr.regParam, Array(0.1, 0.01))
      .addGrid(lr.fitIntercept)
      .addGrid(lr.elasticNetParam, Array(0.0, 0.5, 1.0))
      .build()

    // In this case the estimator is simply the linear regression.
    // A TrainValidationSplit requires an Estimator, a set of Estimator ParamMaps, and an Evaluator.
    val trainValidationSplit = new TrainValidationSplit()
      .setEstimator(lr)
      .setEvaluator(new RegressionEvaluator)
      .setEstimatorParamMaps(paramGrid)
      // 80% of the data will be used for training and the remaining 20% for validation.
      .setTrainRatio(0.8)
      // Evaluate up to 2 parameter settings in parallel
      .setParallelism(2)

    // Run train validation split, and choose the best set of parameters.
    val model = trainValidationSplit.fit(training)

    // Make predictions on test data. model is the model with combination of parameters
    // that performed best.
    model.transform(test)
      .select("features", "label", "prediction")
      .show()
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.PCA
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object PCAExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("PCAExample")
      .getOrCreate()

    // $example on$
    val data = Array(
      Vectors.sparse(5, Seq((1, 1.0), (3, 7.0))),
      Vectors.dense(2.0, 0.0, 3.0, 4.0, 5.0),
      Vectors.dense(4.0, 0.0, 0.0, 6.0, 7.0)
    )
    val df = spark.createDataFrame(data.map(Tuple1.apply)).toDF("features")

    val pca = new PCA()
      .setInputCol("features")
      .setOutputCol("pcaFeatures")
      .setK(3)
      .fit(df)

    val result = pca.transform(df).select("pcaFeatures")
    result.show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.linalg.{Vector, Vectors}
import org.apache.spark.ml.stat.ChiSquareTest
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example for Chi-square hypothesis testing.
 * Run with
 * {{{
 * bin/run-example ml.ChiSquareTestExample
 * }}}
 */
object ChiSquareTestExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("ChiSquareTestExample")
      .getOrCreate()
    import spark.implicits._

    // $example on$
    val data = Seq(
      (0.0, Vectors.dense(0.5, 10.0)),
      (0.0, Vectors.dense(1.5, 20.0)),
      (1.0, Vectors.dense(1.5, 30.0)),
      (0.0, Vectors.dense(3.5, 30.0)),
      (0.0, Vectors.dense(3.5, 40.0)),
      (1.0, Vectors.dense(3.5, 40.0))
    )

    val df = data.toDF("label", "features")
    val chi = ChiSquareTest.test(df, "features", "label").head
    println(s"pValues = ${chi.getAs[Vector](0)}")
    println(s"degreesOfFreedom ${chi.getSeq[Int](1).mkString("[", ",", "]")}")
    println(s"statistics ${chi.getAs[Vector](2)}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.attribute.Attribute
import org.apache.spark.ml.feature.{IndexToString, StringIndexer}
// $example off$
import org.apache.spark.sql.SparkSession

object IndexToStringExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("IndexToStringExample")
      .getOrCreate()

    // $example on$
    val df = spark.createDataFrame(Seq(
      (0, "a"),
      (1, "b"),
      (2, "c"),
      (3, "a"),
      (4, "a"),
      (5, "c")
    )).toDF("id", "category")

    val indexer = new StringIndexer()
      .setInputCol("category")
      .setOutputCol("categoryIndex")
      .fit(df)
    val indexed = indexer.transform(df)

    println(s"Transformed string column '${indexer.getInputCol}' " +
        s"to indexed column '${indexer.getOutputCol}'")
    indexed.show()

    val inputColSchema = indexed.schema(indexer.getOutputCol)
    println(s"StringIndexer will store labels in output column metadata: " +
        s"${Attribute.fromStructField(inputColSchema).toString}\n")

    val converter = new IndexToString()
      .setInputCol("categoryIndex")
      .setOutputCol("originalCategory")

    val converted = converter.transform(indexed)

    println(s"Transformed indexed column '${converter.getInputCol}' back to original string " +
        s"column '${converter.getOutputCol}' using labels in metadata")
    converted.select("id", "categoryIndex", "originalCategory").show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.MinHashLSH
import org.apache.spark.ml.linalg.Vectors
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.col
// $example off$

/**
 * An example demonstrating MinHashLSH.
 * Run with:
 *   bin/run-example ml.MinHashLSHExample
 */
object MinHashLSHExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession
    val spark = SparkSession
      .builder
      .appName("MinHashLSHExample")
      .getOrCreate()

    // $example on$
    val dfA = spark.createDataFrame(Seq(
      (0, Vectors.sparse(6, Seq((0, 1.0), (1, 1.0), (2, 1.0)))),
      (1, Vectors.sparse(6, Seq((2, 1.0), (3, 1.0), (4, 1.0)))),
      (2, Vectors.sparse(6, Seq((0, 1.0), (2, 1.0), (4, 1.0))))
    )).toDF("id", "features")

    val dfB = spark.createDataFrame(Seq(
      (3, Vectors.sparse(6, Seq((1, 1.0), (3, 1.0), (5, 1.0)))),
      (4, Vectors.sparse(6, Seq((2, 1.0), (3, 1.0), (5, 1.0)))),
      (5, Vectors.sparse(6, Seq((1, 1.0), (2, 1.0), (4, 1.0))))
    )).toDF("id", "features")

    val key = Vectors.sparse(6, Seq((1, 1.0), (3, 1.0)))

    val mh = new MinHashLSH()
      .setNumHashTables(5)
      .setInputCol("features")
      .setOutputCol("hashes")

    val model = mh.fit(dfA)

    // Feature Transformation
    println("The hashed dataset where hashed values are stored in the column 'hashes':")
    model.transform(dfA).show()

    // Compute the locality sensitive hashes for the input rows, then perform approximate
    // similarity join.
    // We could avoid computing hashes by passing in the already-transformed dataset, e.g.
    // `model.approxSimilarityJoin(transformedA, transformedB, 0.6)`
    println("Approximately joining dfA and dfB on Jaccard distance smaller than 0.6:")
    model.approxSimilarityJoin(dfA, dfB, 0.6, "JaccardDistance")
      .select(col("datasetA.id").alias("idA"),
        col("datasetB.id").alias("idB"),
        col("JaccardDistance")).show()

    // Compute the locality sensitive hashes for the input rows, then perform approximate nearest
    // neighbor search.
    // We could avoid computing hashes by passing in the already-transformed dataset, e.g.
    // `model.approxNearestNeighbors(transformedA, key, 2)`
    // It may return less than 2 rows when not enough approximate near-neighbor candidates are
    // found.
    println("Approximately searching dfA for 2 nearest neighbors of the key:")
    model.approxNearestNeighbors(dfA, key, 2).show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.OneHotEncoder
// $example off$
import org.apache.spark.sql.SparkSession

object OneHotEncoderExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("OneHotEncoderExample")
      .getOrCreate()

    // Note: categorical features are usually first encoded with StringIndexer
    // $example on$
    val df = spark.createDataFrame(Seq(
      (0.0, 1.0),
      (1.0, 0.0),
      (2.0, 1.0),
      (0.0, 2.0),
      (0.0, 1.0),
      (2.0, 0.0)
    )).toDF("categoryIndex1", "categoryIndex2")

    val encoder = new OneHotEncoder()
      .setInputCols(Array("categoryIndex1", "categoryIndex2"))
      .setOutputCols(Array("categoryVec1", "categoryVec2"))
    val model = encoder.fit(df)

    val encoded = model.transform(df)
    encoded.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example for Multilayer Perceptron Classification.
 */
object MultilayerPerceptronClassifierExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("MultilayerPerceptronClassifierExample")
      .getOrCreate()

    // $example on$
    // Load the data stored in LIBSVM format as a DataFrame.
    val data = spark.read.format("libsvm")
      .load("data/mllib/sample_multiclass_classification_data.txt")

    // Split the data into train and test
    val splits = data.randomSplit(Array(0.6, 0.4), seed = 1234L)
    val train = splits(0)
    val test = splits(1)

    // specify layers for the neural network:
    // input layer of size 4 (features), two intermediate of size 5 and 4
    // and output of size 3 (classes)
    val layers = Array[Int](4, 5, 4, 3)

    // create the trainer and set its parameters
    val trainer = new MultilayerPerceptronClassifier()
      .setLayers(layers)
      .setBlockSize(128)
      .setSeed(1234L)
      .setMaxIter(100)

    // train the model
    val model = trainer.fit(train)

    // compute accuracy on the test set
    val result = model.transform(test)
    val predictionAndLabels = result.select("prediction", "label")
    val evaluator = new MulticlassClassificationEvaluator()
      .setMetricName("accuracy")

    println(s"Test set accuracy = ${evaluator.evaluate(predictionAndLabels)}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.{VectorAssembler, VectorSizeHint}
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object VectorSizeHintExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("VectorSizeHintExample")
      .getOrCreate()

    // $example on$
    val dataset = spark.createDataFrame(
      Seq(
        (0, 18, 1.0, Vectors.dense(0.0, 10.0, 0.5), 1.0),
        (0, 18, 1.0, Vectors.dense(0.0, 10.0), 0.0))
    ).toDF("id", "hour", "mobile", "userFeatures", "clicked")

    val sizeHint = new VectorSizeHint()
      .setInputCol("userFeatures")
      .setHandleInvalid("skip")
      .setSize(3)

    val datasetWithSize = sizeHint.transform(dataset)
    println("Rows where 'userFeatures' is not the right size are filtered out")
    datasetWithSize.show(false)

    val assembler = new VectorAssembler()
      .setInputCols(Array("hour", "mobile", "userFeatures"))
      .setOutputCol("features")

    // This dataframe can be used by downstream transformers as before
    val output = assembler.transform(datasetWithSize)
    println("Assembled columns 'hour', 'mobile', 'userFeatures' to vector column 'features'")
    output.select("features", "clicked").show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.Normalizer
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object NormalizerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("NormalizerExample")
      .getOrCreate()

    // $example on$
    val dataFrame = spark.createDataFrame(Seq(
      (0, Vectors.dense(1.0, 0.5, -1.0)),
      (1, Vectors.dense(2.0, 1.0, 1.0)),
      (2, Vectors.dense(4.0, 10.0, 2.0))
    )).toDF("id", "features")

    // Normalize each Vector using $L^1$ norm.
    val normalizer = new Normalizer()
      .setInputCol("features")
      .setOutputCol("normFeatures")
      .setP(1.0)

    val l1NormData = normalizer.transform(dataFrame)
    println("Normalized using L^1 norm")
    l1NormData.show()

    // Normalize each Vector using $L^\infty$ norm.
    val lInfNormData = normalizer.transform(dataFrame, normalizer.p -> Double.PositiveInfinity)
    println("Normalized using L^inf norm")
    lInfNormData.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.LogisticRegression
// $example off$
import org.apache.spark.sql.SparkSession

object MulticlassLogisticRegressionWithElasticNetExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("MulticlassLogisticRegressionWithElasticNetExample")
      .getOrCreate()

    // $example on$
    // Load training data
    val training = spark
      .read
      .format("libsvm")
      .load("data/mllib/sample_multiclass_classification_data.txt")

    val lr = new LogisticRegression()
      .setMaxIter(10)
      .setRegParam(0.3)
      .setElasticNetParam(0.8)

    // Fit the model
    val lrModel = lr.fit(training)

    // Print the coefficients and intercept for multinomial logistic regression
    println(s"Coefficients: \n${lrModel.coefficientMatrix}")
    println(s"Intercepts: \n${lrModel.interceptVector}")

    val trainingSummary = lrModel.summary

    // Obtain the objective per iteration
    val objectiveHistory = trainingSummary.objectiveHistory
    println("objectiveHistory:")
    objectiveHistory.foreach(println)

    // for multiclass, we can inspect metrics on a per-label basis
    println("False positive rate by label:")
    trainingSummary.falsePositiveRateByLabel.zipWithIndex.foreach { case (rate, label) =>
      println(s"label $label: $rate")
    }

    println("True positive rate by label:")
    trainingSummary.truePositiveRateByLabel.zipWithIndex.foreach { case (rate, label) =>
      println(s"label $label: $rate")
    }

    println("Precision by label:")
    trainingSummary.precisionByLabel.zipWithIndex.foreach { case (prec, label) =>
      println(s"label $label: $prec")
    }

    println("Recall by label:")
    trainingSummary.recallByLabel.zipWithIndex.foreach { case (rec, label) =>
      println(s"label $label: $rec")
    }


    println("F-measure by label:")
    trainingSummary.fMeasureByLabel.zipWithIndex.foreach { case (f, label) =>
      println(s"label $label: $f")
    }

    val accuracy = trainingSummary.accuracy
    val falsePositiveRate = trainingSummary.weightedFalsePositiveRate
    val truePositiveRate = trainingSummary.weightedTruePositiveRate
    val fMeasure = trainingSummary.weightedFMeasure
    val precision = trainingSummary.weightedPrecision
    val recall = trainingSummary.weightedRecall
    println(s"Accuracy: $accuracy\nFPR: $falsePositiveRate\nTPR: $truePositiveRate\n" +
      s"F-measure: $fMeasure\nPrecision: $precision\nRecall: $recall")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.spark.ml.evaluation.BinaryClassificationEvaluator
import org.apache.spark.ml.feature.{HashingTF, Tokenizer}
import org.apache.spark.ml.linalg.Vector
import org.apache.spark.ml.tuning.{CrossValidator, ParamGridBuilder}
import org.apache.spark.sql.Row
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * A simple example demonstrating model selection using CrossValidator.
 * This example also demonstrates how Pipelines are Estimators.
 *
 * Run with
 * {{{
 * bin/run-example ml.ModelSelectionViaCrossValidationExample
 * }}}
 */
object ModelSelectionViaCrossValidationExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("ModelSelectionViaCrossValidationExample")
      .getOrCreate()

    // $example on$
    // Prepare training data from a list of (id, text, label) tuples.
    val training = spark.createDataFrame(Seq(
      (0L, "a b c d e spark", 1.0),
      (1L, "b d", 0.0),
      (2L, "spark f g h", 1.0),
      (3L, "hadoop mapreduce", 0.0),
      (4L, "b spark who", 1.0),
      (5L, "g d a y", 0.0),
      (6L, "spark fly", 1.0),
      (7L, "was mapreduce", 0.0),
      (8L, "e spark program", 1.0),
      (9L, "a e c l", 0.0),
      (10L, "spark compile", 1.0),
      (11L, "hadoop software", 0.0)
    )).toDF("id", "text", "label")

    // Configure an ML pipeline, which consists of three stages: tokenizer, hashingTF, and lr.
    val tokenizer = new Tokenizer()
      .setInputCol("text")
      .setOutputCol("words")
    val hashingTF = new HashingTF()
      .setInputCol(tokenizer.getOutputCol)
      .setOutputCol("features")
    val lr = new LogisticRegression()
      .setMaxIter(10)
    val pipeline = new Pipeline()
      .setStages(Array(tokenizer, hashingTF, lr))

    // We use a ParamGridBuilder to construct a grid of parameters to search over.
    // With 3 values for hashingTF.numFeatures and 2 values for lr.regParam,
    // this grid will have 3 x 2 = 6 parameter settings for CrossValidator to choose from.
    val paramGrid = new ParamGridBuilder()
      .addGrid(hashingTF.numFeatures, Array(10, 100, 1000))
      .addGrid(lr.regParam, Array(0.1, 0.01))
      .build()

    // We now treat the Pipeline as an Estimator, wrapping it in a CrossValidator instance.
    // This will allow us to jointly choose parameters for all Pipeline stages.
    // A CrossValidator requires an Estimator, a set of Estimator ParamMaps, and an Evaluator.
    // Note that the evaluator here is a BinaryClassificationEvaluator and its default metric
    // is areaUnderROC.
    val cv = new CrossValidator()
      .setEstimator(pipeline)
      .setEvaluator(new BinaryClassificationEvaluator)
      .setEstimatorParamMaps(paramGrid)
      .setNumFolds(2)  // Use 3+ in practice
      .setParallelism(2)  // Evaluate up to 2 parameter settings in parallel

    // Run cross-validation, and choose the best set of parameters.
    val cvModel = cv.fit(training)

    // Prepare test documents, which are unlabeled (id, text) tuples.
    val test = spark.createDataFrame(Seq(
      (4L, "spark i j k"),
      (5L, "l m n"),
      (6L, "mapreduce spark"),
      (7L, "apache hadoop")
    )).toDF("id", "text")

    // Make predictions on test documents. cvModel uses the best model found (lrModel).
    cvModel.transform(test)
      .select("id", "text", "probability", "prediction")
      .collect()
      .foreach { case Row(id: Long, text: String, prob: Vector, prediction: Double) =>
        println(s"($id, $text) --> prob=$prob, prediction=$prediction")
      }
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.linalg.{Vector, Vectors}
import org.apache.spark.ml.stat.Summarizer
// $example off$
import org.apache.spark.sql.SparkSession

object SummarizerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("SummarizerExample")
      .getOrCreate()

    import spark.implicits._
    import Summarizer._

    // $example on$
    val data = Seq(
      (Vectors.dense(2.0, 3.0, 5.0), 1.0),
      (Vectors.dense(4.0, 6.0, 7.0), 2.0)
    )

    val df = data.toDF("features", "weight")

    val (meanVal, varianceVal) = df.select(metrics("mean", "variance")
      .summary($"features", $"weight").as("summary"))
      .select("summary.mean", "summary.variance")
      .as[(Vector, Vector)].first()

    println(s"with weight: mean = ${meanVal}, variance = ${varianceVal}")

    val (meanVal2, varianceVal2) = df.select(mean($"features"), variance($"features"))
      .as[(Vector, Vector)].first()

    println(s"without weight: mean = ${meanVal2}, sum = ${varianceVal2}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.DCT
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object DCTExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("DCTExample")
      .getOrCreate()

    // $example on$
    val data = Seq(
      Vectors.dense(0.0, 1.0, -2.0, 3.0),
      Vectors.dense(-1.0, 2.0, 4.0, -7.0),
      Vectors.dense(14.0, -2.0, -5.0, 1.0))

    val df = spark.createDataFrame(data.map(Tuple1.apply)).toDF("features")

    val dct = new DCT()
      .setInputCol("features")
      .setOutputCol("featuresDCT")
      .setInverse(false)

    val dctDf = dct.transform(df)
    dctDf.select("featuresDCT").show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.FeatureHasher
// $example off$
import org.apache.spark.sql.SparkSession

object FeatureHasherExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("FeatureHasherExample")
      .getOrCreate()

    // $example on$
    val dataset = spark.createDataFrame(Seq(
      (2.2, true, "1", "foo"),
      (3.3, false, "2", "bar"),
      (4.4, false, "3", "baz"),
      (5.5, false, "4", "foo")
    )).toDF("real", "bool", "stringNum", "string")

    val hasher = new FeatureHasher()
      .setInputCols("real", "bool", "stringNum", "string")
      .setOutputCol("features")

    val featurized = hasher.transform(dataset)
    featurized.show(false)
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.VectorIndexer
import org.apache.spark.ml.regression.DecisionTreeRegressionModel
import org.apache.spark.ml.regression.DecisionTreeRegressor
// $example off$
import org.apache.spark.sql.SparkSession

object DecisionTreeRegressionExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("DecisionTreeRegressionExample")
      .getOrCreate()

    // $example on$
    // Load the data stored in LIBSVM format as a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Automatically identify categorical features, and index them.
    // Here, we treat features with > 4 distinct values as continuous.
    val featureIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(4)
      .fit(data)

    // Split the data into training and test sets (30% held out for testing).
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Train a DecisionTree model.
    val dt = new DecisionTreeRegressor()
      .setLabelCol("label")
      .setFeaturesCol("indexedFeatures")

    // Chain indexer and tree in a Pipeline.
    val pipeline = new Pipeline()
      .setStages(Array(featureIndexer, dt))

    // Train model. This also runs the indexer.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select example rows to display.
    predictions.select("prediction", "label", "features").show(5)

    // Select (prediction, true label) and compute test error.
    val evaluator = new RegressionEvaluator()
      .setLabelCol("label")
      .setPredictionCol("prediction")
      .setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)
    println(s"Root Mean Squared Error (RMSE) on test data = $rmse")

    val treeModel = model.stages(1).asInstanceOf[DecisionTreeRegressionModel]
    println(s"Learned regression tree model:\n ${treeModel.toDebugString}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.{RandomForestClassificationModel, RandomForestClassifier}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}
// $example off$
import org.apache.spark.sql.SparkSession

object RandomForestClassifierExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("RandomForestClassifierExample")
      .getOrCreate()

    // $example on$
    // Load and parse the data file, converting it to a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Index labels, adding metadata to the label column.
    // Fit on whole dataset to include all labels in index.
    val labelIndexer = new StringIndexer()
      .setInputCol("label")
      .setOutputCol("indexedLabel")
      .fit(data)
    // Automatically identify categorical features, and index them.
    // Set maxCategories so features with > 4 distinct values are treated as continuous.
    val featureIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(4)
      .fit(data)

    // Split the data into training and test sets (30% held out for testing).
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Train a RandomForest model.
    val rf = new RandomForestClassifier()
      .setLabelCol("indexedLabel")
      .setFeaturesCol("indexedFeatures")
      .setNumTrees(10)

    // Convert indexed labels back to original labels.
    val labelConverter = new IndexToString()
      .setInputCol("prediction")
      .setOutputCol("predictedLabel")
      .setLabels(labelIndexer.labels)

    // Chain indexers and forest in a Pipeline.
    val pipeline = new Pipeline()
      .setStages(Array(labelIndexer, featureIndexer, rf, labelConverter))

    // Train model. This also runs the indexers.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select example rows to display.
    predictions.select("predictedLabel", "label", "features").show(5)

    // Select (prediction, true label) and compute test error.
    val evaluator = new MulticlassClassificationEvaluator()
      .setLabelCol("indexedLabel")
      .setPredictionCol("prediction")
      .setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)
    println(s"Test Error = ${(1.0 - accuracy)}")

    val rfModel = model.stages(2).asInstanceOf[RandomForestClassificationModel]
    println(s"Learned classification forest model:\n ${rfModel.toDebugString}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.{GBTClassificationModel, GBTClassifier}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}
// $example off$
import org.apache.spark.sql.SparkSession

object GradientBoostedTreeClassifierExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("GradientBoostedTreeClassifierExample")
      .getOrCreate()

    // $example on$
    // Load and parse the data file, converting it to a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Index labels, adding metadata to the label column.
    // Fit on whole dataset to include all labels in index.
    val labelIndexer = new StringIndexer()
      .setInputCol("label")
      .setOutputCol("indexedLabel")
      .fit(data)
    // Automatically identify categorical features, and index them.
    // Set maxCategories so features with > 4 distinct values are treated as continuous.
    val featureIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(4)
      .fit(data)

    // Split the data into training and test sets (30% held out for testing).
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Train a GBT model.
    val gbt = new GBTClassifier()
      .setLabelCol("indexedLabel")
      .setFeaturesCol("indexedFeatures")
      .setMaxIter(10)
      .setFeatureSubsetStrategy("auto")

    // Convert indexed labels back to original labels.
    val labelConverter = new IndexToString()
      .setInputCol("prediction")
      .setOutputCol("predictedLabel")
      .setLabels(labelIndexer.labels)

    // Chain indexers and GBT in a Pipeline.
    val pipeline = new Pipeline()
      .setStages(Array(labelIndexer, featureIndexer, gbt, labelConverter))

    // Train model. This also runs the indexers.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select example rows to display.
    predictions.select("predictedLabel", "label", "features").show(5)

    // Select (prediction, true label) and compute test error.
    val evaluator = new MulticlassClassificationEvaluator()
      .setLabelCol("indexedLabel")
      .setPredictionCol("prediction")
      .setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)
    println(s"Test Error = ${1.0 - accuracy}")

    val gbtModel = model.stages(2).asInstanceOf[GBTClassificationModel]
    println(s"Learned classification GBT model:\n ${gbtModel.toDebugString}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// scalastyle:off println

// $example on$
import org.apache.spark.ml.clustering.KMeans
import org.apache.spark.ml.evaluation.ClusteringEvaluator
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating k-means clustering.
 * Run with
 * {{{
 * bin/run-example ml.KMeansExample
 * }}}
 */
object KMeansExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()

    // $example on$
    // Loads data.
    val dataset = spark.read.format("libsvm").load("data/mllib/sample_kmeans_data.txt")

    // Trains a k-means model.
    val kmeans = new KMeans().setK(2).setSeed(1L)
    val model = kmeans.fit(dataset)

    // Make predictions
    val predictions = model.transform(dataset)

    // Evaluate clustering by computing Silhouette score
    val evaluator = new ClusteringEvaluator()

    val silhouette = evaluator.evaluate(predictions)
    println(s"Silhouette with squared euclidean distance = $silhouette")

    // Shows the result.
    println("Cluster Centers: ")
    model.clusterCenters.foreach(println)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object VectorAssemblerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("VectorAssemblerExample")
      .getOrCreate()

    // $example on$
    val dataset = spark.createDataFrame(
      Seq((0, 18, 1.0, Vectors.dense(0.0, 10.0, 0.5), 1.0))
    ).toDF("id", "hour", "mobile", "userFeatures", "clicked")

    val assembler = new VectorAssembler()
      .setInputCols(Array("hour", "mobile", "userFeatures"))
      .setOutputCol("features")

    val output = assembler.transform(dataset)
    println("Assembled columns 'hour', 'mobile', 'userFeatures' to vector column 'features'")
    output.select("features", "clicked").show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.spark.ml.linalg.{Vector, Vectors}
import org.apache.spark.ml.param.ParamMap
import org.apache.spark.sql.Row
// $example off$
import org.apache.spark.sql.SparkSession

object EstimatorTransformerParamExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("EstimatorTransformerParamExample")
      .getOrCreate()

    // $example on$
    // Prepare training data from a list of (label, features) tuples.
    val training = spark.createDataFrame(Seq(
      (1.0, Vectors.dense(0.0, 1.1, 0.1)),
      (0.0, Vectors.dense(2.0, 1.0, -1.0)),
      (0.0, Vectors.dense(2.0, 1.3, 1.0)),
      (1.0, Vectors.dense(0.0, 1.2, -0.5))
    )).toDF("label", "features")

    // Create a LogisticRegression instance. This instance is an Estimator.
    val lr = new LogisticRegression()
    // Print out the parameters, documentation, and any default values.
    println(s"LogisticRegression parameters:\n ${lr.explainParams()}\n")

    // We may set parameters using setter methods.
    lr.setMaxIter(10)
      .setRegParam(0.01)

    // Learn a LogisticRegression model. This uses the parameters stored in lr.
    val model1 = lr.fit(training)
    // Since model1 is a Model (i.e., a Transformer produced by an Estimator),
    // we can view the parameters it used during fit().
    // This prints the parameter (name: value) pairs, where names are unique IDs for this
    // LogisticRegression instance.
    println(s"Model 1 was fit using parameters: ${model1.parent.extractParamMap}")

    // We may alternatively specify parameters using a ParamMap,
    // which supports several methods for specifying parameters.
    val paramMap = ParamMap(lr.maxIter -> 20)
      .put(lr.maxIter, 30)  // Specify 1 Param. This overwrites the original maxIter.
      .put(lr.regParam -> 0.1, lr.threshold -> 0.55)  // Specify multiple Params.

    // One can also combine ParamMaps.
    val paramMap2 = ParamMap(lr.probabilityCol -> "myProbability")  // Change output column name.
    val paramMapCombined = paramMap ++ paramMap2

    // Now learn a new model using the paramMapCombined parameters.
    // paramMapCombined overrides all parameters set earlier via lr.set* methods.
    val model2 = lr.fit(training, paramMapCombined)
    println(s"Model 2 was fit using parameters: ${model2.parent.extractParamMap}")

    // Prepare test data.
    val test = spark.createDataFrame(Seq(
      (1.0, Vectors.dense(-1.0, 1.5, 1.3)),
      (0.0, Vectors.dense(3.0, 2.0, -0.1)),
      (1.0, Vectors.dense(0.0, 2.2, -1.5))
    )).toDF("label", "features")

    // Make predictions on test data using the Transformer.transform() method.
    // LogisticRegression.transform will only use the 'features' column.
    // Note that model2.transform() outputs a 'myProbability' column instead of the usual
    // 'probability' column since we renamed the lr.probabilityCol parameter previously.
    model2.transform(test)
      .select("features", "label", "myProbability", "prediction")
      .collect()
      .foreach { case Row(features: Vector, label: Double, prob: Vector, prediction: Double) =>
        println(s"($features, $label) -> prob=$prob, prediction=$prediction")
      }
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// scalastyle:off println

// $example on$
import org.apache.spark.ml.clustering.BisectingKMeans
import org.apache.spark.ml.evaluation.ClusteringEvaluator
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating bisecting k-means clustering.
 * Run with
 * {{{
 * bin/run-example ml.BisectingKMeansExample
 * }}}
 */
object BisectingKMeansExample {

  def main(args: Array[String]): Unit = {
    // Creates a SparkSession
    val spark = SparkSession
      .builder
      .appName("BisectingKMeansExample")
      .getOrCreate()

    // $example on$
    // Loads data.
    val dataset = spark.read.format("libsvm").load("data/mllib/sample_kmeans_data.txt")

    // Trains a bisecting k-means model.
    val bkm = new BisectingKMeans().setK(2).setSeed(1)
    val model = bkm.fit(dataset)

    // Make predictions
    val predictions = model.transform(dataset)

    // Evaluate clustering by computing Silhouette score
    val evaluator = new ClusteringEvaluator()

    val silhouette = evaluator.evaluate(predictions)
    println(s"Silhouette with squared euclidean distance = $silhouette")

    // Shows the result.
    println("Cluster Centers: ")
    val centers = model.clusterCenters
    centers.foreach(println)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import java.io.File

import scopt.OptionParser

import org.apache.spark.examples.mllib.AbstractParams
import org.apache.spark.ml.linalg.Vector
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.MultivariateOnlineSummarizer
import org.apache.spark.sql.{DataFrame, Row, SparkSession}
import org.apache.spark.util.Utils

/**
 * An example of how to use [[DataFrame]] for ML. Run with
 * {{{
 * ./bin/run-example ml.DataFrameExample [options]
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object DataFrameExample {

  case class Params(input: String = "data/mllib/sample_libsvm_data.txt")
    extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("DataFrameExample") {
      head("DataFrameExample: an example app using DataFrame for ML.")
      opt[String]("input")
        .text("input path to dataframe")
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        success
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"DataFrameExample with $params")
      .getOrCreate()

    // Load input data
    println(s"Loading LIBSVM file with UDT from ${params.input}.")
    val df: DataFrame = spark.read.format("libsvm").load(params.input).cache()
    println("Schema from LIBSVM:")
    df.printSchema()
    println(s"Loaded training data as a DataFrame with ${df.count()} records.")

    // Show statistical summary of labels.
    val labelSummary = df.describe("label")
    labelSummary.show()

    // Convert features column to an RDD of vectors.
    val features = df.select("features").rdd.map { case Row(v: Vector) => v }
    val featureSummary = features.aggregate(new MultivariateOnlineSummarizer())(
      (summary, feat) => summary.add(Vectors.fromML(feat)),
      (sum1, sum2) => sum1.merge(sum2))
    println(s"Selected features column with average values:\n ${featureSummary.mean.toString}")

    // Save the records in a parquet file.
    val tmpDir = Utils.createTempDir()
    val outputDir = new File(tmpDir, "dataframe").toString
    println(s"Saving to $outputDir as Parquet file.")
    df.write.parquet(outputDir)

    // Load the records back.
    println(s"Loading Parquet file with UDT from $outputDir.")
    val newDF = spark.read.parquet(outputDir)
    println("Schema from Parquet:")
    newDF.printSchema()

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.ChiSqSelector
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object ChiSqSelectorExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("ChiSqSelectorExample")
      .getOrCreate()
    import spark.implicits._

    // $example on$
    val data = Seq(
      (7, Vectors.dense(0.0, 0.0, 18.0, 1.0), 1.0),
      (8, Vectors.dense(0.0, 1.0, 12.0, 0.0), 0.0),
      (9, Vectors.dense(1.0, 0.0, 15.0, 0.1), 0.0)
    )

    val df = spark.createDataset(data).toDF("id", "features", "clicked")

    val selector = new ChiSqSelector()
      .setNumTopFeatures(1)
      .setFeaturesCol("features")
      .setLabelCol("clicked")
      .setOutputCol("selectedFeatures")

    val result = selector.fit(df).transform(df)

    println(s"ChiSqSelector output with top ${selector.getNumTopFeatures} features selected")
    result.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.VectorIndexer
// $example off$
import org.apache.spark.sql.SparkSession

object VectorIndexerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("VectorIndexerExample")
      .getOrCreate()

    // $example on$
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    val indexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexed")
      .setMaxCategories(10)

    val indexerModel = indexer.fit(data)

    val categoricalFeatures: Set[Int] = indexerModel.categoryMaps.keys.toSet
    println(s"Chose ${categoricalFeatures.size} " +
      s"categorical features: ${categoricalFeatures.mkString(", ")}")

    // Create new column "indexed" with categorical values transformed to indices
    val indexedData = indexerModel.transform(data)
    indexedData.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.LogisticRegression
// $example off$
import org.apache.spark.sql.SparkSession

object LogisticRegressionWithElasticNetExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("LogisticRegressionWithElasticNetExample")
      .getOrCreate()

    // $example on$
    // Load training data
    val training = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    val lr = new LogisticRegression()
      .setMaxIter(10)
      .setRegParam(0.3)
      .setElasticNetParam(0.8)

    // Fit the model
    val lrModel = lr.fit(training)

    // Print the coefficients and intercept for logistic regression
    println(s"Coefficients: ${lrModel.coefficients} Intercept: ${lrModel.intercept}")

    // We can also use the multinomial family for binary classification
    val mlr = new LogisticRegression()
      .setMaxIter(10)
      .setRegParam(0.3)
      .setElasticNetParam(0.8)
      .setFamily("multinomial")

    val mlrModel = mlr.fit(training)

    // Print the coefficients and intercepts for logistic regression with multinomial family
    println(s"Multinomial coefficients: ${mlrModel.coefficientMatrix}")
    println(s"Multinomial intercepts: ${mlrModel.interceptVector}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.LinearSVC
// $example off$
import org.apache.spark.sql.SparkSession

object LinearSVCExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("LinearSVCExample")
      .getOrCreate()

    // $example on$
    // Load training data
    val training = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    val lsvc = new LinearSVC()
      .setMaxIter(10)
      .setRegParam(0.1)

    // Fit the model
    val lsvcModel = lsvc.fit(training)

    // Print the coefficients and intercept for linear svc
    println(s"Coefficients: ${lsvcModel.coefficients} Intercept: ${lsvcModel.intercept}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.recommendation.ALS
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating ALS.
 * Run with
 * {{{
 * bin/run-example ml.ALSExample
 * }}}
 */
object ALSExample {

  // $example on$
  case class Rating(userId: Int, movieId: Int, rating: Float, timestamp: Long)
  def parseRating(str: String): Rating = {
    val fields = str.split("::")
    assert(fields.size == 4)
    Rating(fields(0).toInt, fields(1).toInt, fields(2).toFloat, fields(3).toLong)
  }
  // $example off$

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("ALSExample")
      .getOrCreate()
    import spark.implicits._

    // $example on$
    val ratings = spark.read.textFile("data/mllib/als/sample_movielens_ratings.txt")
      .map(parseRating)
      .toDF()
    val Array(training, test) = ratings.randomSplit(Array(0.8, 0.2))

    // Build the recommendation model using ALS on the training data
    val als = new ALS()
      .setMaxIter(5)
      .setRegParam(0.01)
      .setUserCol("userId")
      .setItemCol("movieId")
      .setRatingCol("rating")
    val model = als.fit(training)

    // Evaluate the model by computing the RMSE on the test data
    // Note we set cold start strategy to 'drop' to ensure we don't get NaN evaluation metrics
    model.setColdStartStrategy("drop")
    val predictions = model.transform(test)

    val evaluator = new RegressionEvaluator()
      .setMetricName("rmse")
      .setLabelCol("rating")
      .setPredictionCol("prediction")
    val rmse = evaluator.evaluate(predictions)
    println(s"Root-mean-square error = $rmse")

    // Generate top 10 movie recommendations for each user
    val userRecs = model.recommendForAllUsers(10)
    // Generate top 10 user recommendations for each movie
    val movieRecs = model.recommendForAllItems(10)

    // Generate top 10 movie recommendations for a specified set of users
    val users = ratings.select(als.getUserCol).distinct().limit(3)
    val userSubsetRecs = model.recommendForUserSubset(users, 10)
    // Generate top 10 user recommendations for a specified set of movies
    val movies = ratings.select(als.getItemCol).distinct().limit(3)
    val movieSubSetRecs = model.recommendForItemSubset(movies, 10)
    // $example off$
    userRecs.show()
    movieRecs.show()
    userSubsetRecs.show()
    movieSubSetRecs.show()

    spark.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.regression.IsotonicRegression
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating Isotonic Regression.
 * Run with
 * {{{
 * bin/run-example ml.IsotonicRegressionExample
 * }}}
 */
object IsotonicRegressionExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()

    // $example on$
    // Loads data.
    val dataset = spark.read.format("libsvm")
      .load("data/mllib/sample_isotonic_regression_libsvm_data.txt")

    // Trains an isotonic regression model.
    val ir = new IsotonicRegression()
    val model = ir.fit(dataset)

    println(s"Boundaries in increasing order: ${model.boundaries}\n")
    println(s"Predictions associated with the boundaries: ${model.predictions}\n")

    // Makes predictions.
    model.transform(dataset).show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.NGram
// $example off$
import org.apache.spark.sql.SparkSession

object NGramExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("NGramExample")
      .getOrCreate()

    // $example on$
    val wordDataFrame = spark.createDataFrame(Seq(
      (0, Array("Hi", "I", "heard", "about", "Spark")),
      (1, Array("I", "wish", "Java", "could", "use", "case", "classes")),
      (2, Array("Logistic", "regression", "models", "are", "neat"))
    )).toDF("id", "words")

    val ngram = new NGram().setN(2).setInputCol("words").setOutputCol("ngrams")

    val ngramDataFrame = ngram.transform(wordDataFrame)
    ngramDataFrame.select("ngrams").show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.RFormula
// $example off$
import org.apache.spark.sql.SparkSession

object RFormulaExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("RFormulaExample")
      .getOrCreate()

    // $example on$
    val dataset = spark.createDataFrame(Seq(
      (7, "US", 18, 1.0),
      (8, "CA", 12, 0.0),
      (9, "NZ", 15, 0.0)
    )).toDF("id", "country", "hour", "clicked")

    val formula = new RFormula()
      .setFormula("clicked ~ country + hour")
      .setFeaturesCol("features")
      .setLabelCol("label")

    val output = formula.fit(dataset).transform(dataset)
    output.select("features", "label").show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.MaxAbsScaler
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object MaxAbsScalerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("MaxAbsScalerExample")
      .getOrCreate()

    // $example on$
    val dataFrame = spark.createDataFrame(Seq(
      (0, Vectors.dense(1.0, 0.1, -8.0)),
      (1, Vectors.dense(2.0, 1.0, -4.0)),
      (2, Vectors.dense(4.0, 10.0, 8.0))
    )).toDF("id", "features")

    val scaler = new MaxAbsScaler()
      .setInputCol("features")
      .setOutputCol("scaledFeatures")

    // Compute summary statistics and generate MaxAbsScalerModel
    val scalerModel = scaler.fit(dataFrame)

    // rescale each feature to range [-1, 1]
    val scaledData = scalerModel.transform(dataFrame)
    scaledData.select("features", "scaledFeatures").show()
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.MinMaxScaler
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object MinMaxScalerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("MinMaxScalerExample")
      .getOrCreate()

    // $example on$
    val dataFrame = spark.createDataFrame(Seq(
      (0, Vectors.dense(1.0, 0.1, -1.0)),
      (1, Vectors.dense(2.0, 1.1, 1.0)),
      (2, Vectors.dense(3.0, 10.1, 3.0))
    )).toDF("id", "features")

    val scaler = new MinMaxScaler()
      .setInputCol("features")
      .setOutputCol("scaledFeatures")

    // Compute summary statistics and generate MinMaxScalerModel
    val scalerModel = scaler.fit(dataFrame)

    // rescale each feature to range [min, max].
    val scaledData = scalerModel.transform(dataFrame)
    println(s"Features scaled to range: [${scaler.getMin}, ${scaler.getMax}]")
    scaledData.select("features", "scaledFeatures").show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.linalg.{Matrix, Vectors}
import org.apache.spark.ml.stat.Correlation
import org.apache.spark.sql.Row
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example for computing correlation matrix.
 * Run with
 * {{{
 * bin/run-example ml.CorrelationExample
 * }}}
 */
object CorrelationExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("CorrelationExample")
      .getOrCreate()
    import spark.implicits._

    // $example on$
    val data = Seq(
      Vectors.sparse(4, Seq((0, 1.0), (3, -2.0))),
      Vectors.dense(4.0, 5.0, 0.0, 3.0),
      Vectors.dense(6.0, 7.0, 0.0, 8.0),
      Vectors.sparse(4, Seq((0, 9.0), (3, 1.0)))
    )

    val df = data.map(Tuple1.apply).toDF("features")
    val Row(coeff1: Matrix) = Correlation.corr(df, "features").head
    println(s"Pearson correlation matrix:\n $coeff1")

    val Row(coeff2: Matrix) = Correlation.corr(df, "features", "spearman").head
    println(s"Spearman correlation matrix:\n $coeff2")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.{RegexTokenizer, Tokenizer}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
// $example off$

object TokenizerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("TokenizerExample")
      .getOrCreate()

    // $example on$
    val sentenceDataFrame = spark.createDataFrame(Seq(
      (0, "Hi I heard about Spark"),
      (1, "I wish Java could use case classes"),
      (2, "Logistic,regression,models,are,neat")
    )).toDF("id", "sentence")

    val tokenizer = new Tokenizer().setInputCol("sentence").setOutputCol("words")
    val regexTokenizer = new RegexTokenizer()
      .setInputCol("sentence")
      .setOutputCol("words")
      .setPattern("\\W") // alternatively .setPattern("\\w+").setGaps(false)

    val countTokens = udf { (words: Seq[String]) => words.length }

    val tokenized = tokenizer.transform(sentenceDataFrame)
    tokenized.select("sentence", "words")
        .withColumn("tokens", countTokens(col("words"))).show(false)

    val regexTokenized = regexTokenizer.transform(sentenceDataFrame)
    regexTokenized.select("sentence", "words")
        .withColumn("tokens", countTokens(col("words"))).show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.StringIndexer
// $example off$
import org.apache.spark.sql.SparkSession

object StringIndexerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("StringIndexerExample")
      .getOrCreate()

    // $example on$
    val df = spark.createDataFrame(
      Seq((0, "a"), (1, "b"), (2, "c"), (3, "a"), (4, "a"), (5, "c"))
    ).toDF("id", "category")

    val indexer = new StringIndexer()
      .setInputCol("category")
      .setOutputCol("categoryIndex")

    val indexed = indexer.fit(df).transform(df)
    indexed.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// scalastyle:off println

// $example on$
import org.apache.spark.ml.clustering.GaussianMixture
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating Gaussian Mixture Model (GMM).
 * Run with
 * {{{
 * bin/run-example ml.GaussianMixtureExample
 * }}}
 */
object GaussianMixtureExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
        .builder
        .appName(s"${this.getClass.getSimpleName}")
        .getOrCreate()

    // $example on$
    // Loads data
    val dataset = spark.read.format("libsvm").load("data/mllib/sample_kmeans_data.txt")

    // Trains Gaussian Mixture Model
    val gmm = new GaussianMixture()
      .setK(2)
    val model = gmm.fit(dataset)

    // output parameters of mixture model model
    for (i <- 0 until model.getK) {
      println(s"Gaussian $i:\nweight=${model.weights(i)}\n" +
          s"mu=${model.gaussians(i).mean}\nsigma=\n${model.gaussians(i).cov}\n")
    }
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.fpm.FPGrowth
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating FP-Growth.
 * Run with
 * {{{
 * bin/run-example ml.FPGrowthExample
 * }}}
 */
object FPGrowthExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    import spark.implicits._

    // $example on$
    val dataset = spark.createDataset(Seq(
      "1 2 5",
      "1 2 3 5",
      "1 2")
    ).map(t => t.split(" ")).toDF("items")

    val fpgrowth = new FPGrowth().setItemsCol("items").setMinSupport(0.5).setMinConfidence(0.6)
    val model = fpgrowth.fit(dataset)

    // Display frequent itemsets.
    model.freqItemsets.show()

    // Display generated association rules.
    model.associationRules.show()

    // transform examines the input items against all the association rules and summarize the
    // consequents as prediction
    model.transform(dataset).show()
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.NaiveBayes
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
// $example off$
import org.apache.spark.sql.SparkSession

object NaiveBayesExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("NaiveBayesExample")
      .getOrCreate()

    // $example on$
    // Load the data stored in LIBSVM format as a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Split the data into training and test sets (30% held out for testing)
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3), seed = 1234L)

    // Train a NaiveBayes model.
    val model = new NaiveBayes()
      .fit(trainingData)

    // Select example rows to display.
    val predictions = model.transform(testData)
    predictions.show()

    // Select (prediction, true label) and compute test error
    val evaluator = new MulticlassClassificationEvaluator()
      .setLabelCol("label")
      .setPredictionCol("prediction")
      .setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)
    println(s"Test set accuracy = $accuracy")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import java.util.Arrays

import org.apache.spark.ml.attribute.{Attribute, AttributeGroup, NumericAttribute}
import org.apache.spark.ml.feature.VectorSlicer
import org.apache.spark.ml.linalg.Vectors
import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.types.StructType
// $example off$

object VectorSlicerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("VectorSlicerExample")
      .getOrCreate()

    // $example on$
    val data = Arrays.asList(
      Row(Vectors.sparse(3, Seq((0, -2.0), (1, 2.3)))),
      Row(Vectors.dense(-2.0, 2.3, 0.0))
    )

    val defaultAttr = NumericAttribute.defaultAttr
    val attrs = Array("f1", "f2", "f3").map(defaultAttr.withName)
    val attrGroup = new AttributeGroup("userFeatures", attrs.asInstanceOf[Array[Attribute]])

    val dataset = spark.createDataFrame(data, StructType(Array(attrGroup.toStructField())))

    val slicer = new VectorSlicer().setInputCol("userFeatures").setOutputCol("features")

    slicer.setIndices(Array(1)).setNames(Array("f3"))
    // or slicer.setIndices(Array(1, 2)), or slicer.setNames(Array("f2", "f3"))

    val output = slicer.transform(dataset)
    output.show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import java.util.Locale

import scala.collection.mutable

import scopt.OptionParser

import org.apache.spark.examples.mllib.AbstractParams
import org.apache.spark.ml.{Pipeline, PipelineStage, Transformer}
import org.apache.spark.ml.classification.{DecisionTreeClassificationModel, DecisionTreeClassifier}
import org.apache.spark.ml.feature.{StringIndexer, VectorIndexer}
import org.apache.spark.ml.linalg.Vector
import org.apache.spark.ml.regression.{DecisionTreeRegressionModel, DecisionTreeRegressor}
import org.apache.spark.ml.util.MetadataUtils
import org.apache.spark.mllib.evaluation.{MulticlassMetrics, RegressionMetrics}
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.sql.{DataFrame, SparkSession}

/**
 * An example runner for decision trees. Run with
 * {{{
 * ./bin/run-example ml.DecisionTreeExample [options]
 * }}}
 * Note that Decision Trees can take a large amount of memory. If the run-example command above
 * fails, try running via spark-submit and specifying the amount of memory as at least 1g.
 * For local mode, run
 * {{{
 * ./bin/spark-submit --class org.apache.spark.examples.ml.DecisionTreeExample --driver-memory 1g
 *   [examples JAR path] [options]
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object DecisionTreeExample {

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      algo: String = "Classification",
      maxDepth: Int = 5,
      maxBins: Int = 32,
      minInstancesPerNode: Int = 1,
      minInfoGain: Double = 0.0,
      fracTest: Double = 0.2,
      cacheNodeIds: Boolean = false,
      checkpointDir: Option[String] = None,
      checkpointInterval: Int = 10) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("DecisionTreeExample") {
      head("DecisionTreeExample: an example decision tree app.")
      opt[String]("algo")
        .text(s"algorithm (classification, regression), default: ${defaultParams.algo}")
        .action((x, c) => c.copy(algo = x))
      opt[Int]("maxDepth")
        .text(s"max depth of the tree, default: ${defaultParams.maxDepth}")
        .action((x, c) => c.copy(maxDepth = x))
      opt[Int]("maxBins")
        .text(s"max number of bins, default: ${defaultParams.maxBins}")
        .action((x, c) => c.copy(maxBins = x))
      opt[Int]("minInstancesPerNode")
        .text(s"min number of instances required at child nodes to create the parent split," +
          s" default: ${defaultParams.minInstancesPerNode}")
        .action((x, c) => c.copy(minInstancesPerNode = x))
      opt[Double]("minInfoGain")
        .text(s"min info gain required to create a split, default: ${defaultParams.minInfoGain}")
        .action((x, c) => c.copy(minInfoGain = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing. If given option testInput, " +
          s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[Boolean]("cacheNodeIds")
        .text(s"whether to use node Id cache during training, " +
          s"default: ${defaultParams.cacheNodeIds}")
        .action((x, c) => c.copy(cacheNodeIds = x))
      opt[String]("checkpointDir")
        .text(s"checkpoint directory where intermediate node Id caches will be stored, " +
         s"default: ${defaultParams.checkpointDir match {
           case Some(strVal) => strVal
           case None => "None"
         }}")
        .action((x, c) => c.copy(checkpointDir = Some(x)))
      opt[Int]("checkpointInterval")
        .text(s"how often to checkpoint the node Id cache, " +
         s"default: ${defaultParams.checkpointInterval}")
        .action((x, c) => c.copy(checkpointInterval = x))
      opt[String]("testInput")
        .text(s"input path to test dataset. If given, option fracTest is ignored." +
          s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest >= 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1).")
        } else {
          success
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  /** Load a dataset from the given path, using the given format */
  private[ml] def loadData(
      spark: SparkSession,
      path: String,
      format: String,
      expectedNumFeatures: Option[Int] = None): DataFrame = {
    import spark.implicits._

    format match {
      case "dense" => MLUtils.loadLabeledPoints(spark.sparkContext, path).toDF()
      case "libsvm" => expectedNumFeatures match {
        case Some(numFeatures) => spark.read.option("numFeatures", numFeatures.toString)
          .format("libsvm").load(path)
        case None => spark.read.format("libsvm").load(path)
      }
      case _ => throw new IllegalArgumentException(s"Bad data format: $format")
    }
  }

  /**
   * Load training and test data from files.
   * @param input  Path to input dataset.
   * @param dataFormat  "libsvm" or "dense"
   * @param testInput  Path to test dataset.
   * @param algo  Classification or Regression
   * @param fracTest  Fraction of input data to hold out for testing. Ignored if testInput given.
   * @return  (training dataset, test dataset)
   */
  private[ml] def loadDatasets(
      input: String,
      dataFormat: String,
      testInput: String,
      algo: String,
      fracTest: Double): (DataFrame, DataFrame) = {
    val spark = SparkSession
      .builder
      .getOrCreate()

    // Load training data
    val origExamples: DataFrame = loadData(spark, input, dataFormat)

    // Load or create test set
    val dataframes: Array[DataFrame] = if (testInput != "") {
      // Load testInput.
      val numFeatures = origExamples.first().getAs[Vector](1).size
      val origTestExamples: DataFrame =
        loadData(spark, testInput, dataFormat, Some(numFeatures))
      Array(origExamples, origTestExamples)
    } else {
      // Split input into training, test.
      origExamples.randomSplit(Array(1.0 - fracTest, fracTest), seed = 12345)
    }

    val training = dataframes(0).cache()
    val test = dataframes(1).cache()

    val numTraining = training.count()
    val numTest = test.count()
    val numFeatures = training.select("features").first().getAs[Vector](0).size
    println("Loaded data:")
    println(s"  numTraining = $numTraining, numTest = $numTest")
    println(s"  numFeatures = $numFeatures")

    (training, test)
  }

  def run(params: Params): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"DecisionTreeExample with $params")
      .getOrCreate()

    params.checkpointDir.foreach(spark.sparkContext.setCheckpointDir)
    val algo = params.algo.toLowerCase(Locale.ROOT)

    println(s"DecisionTreeExample with parameters:\n$params")

    // Load training and test data and cache it.
    val (training: DataFrame, test: DataFrame) =
      loadDatasets(params.input, params.dataFormat, params.testInput, algo, params.fracTest)

    // Set up Pipeline.
    val stages = new mutable.ArrayBuffer[PipelineStage]()
    // (1) For classification, re-index classes.
    val labelColName = if (algo == "classification") "indexedLabel" else "label"
    if (algo == "classification") {
      val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol(labelColName)
      stages += labelIndexer
    }
    // (2) Identify categorical features using VectorIndexer.
    //     Features with more than maxCategories values will be treated as continuous.
    val featuresIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(10)
    stages += featuresIndexer
    // (3) Learn Decision Tree.
    val dt = algo match {
      case "classification" =>
        new DecisionTreeClassifier()
          .setFeaturesCol("indexedFeatures")
          .setLabelCol(labelColName)
          .setMaxDepth(params.maxDepth)
          .setMaxBins(params.maxBins)
          .setMinInstancesPerNode(params.minInstancesPerNode)
          .setMinInfoGain(params.minInfoGain)
          .setCacheNodeIds(params.cacheNodeIds)
          .setCheckpointInterval(params.checkpointInterval)
      case "regression" =>
        new DecisionTreeRegressor()
          .setFeaturesCol("indexedFeatures")
          .setLabelCol(labelColName)
          .setMaxDepth(params.maxDepth)
          .setMaxBins(params.maxBins)
          .setMinInstancesPerNode(params.minInstancesPerNode)
          .setMinInfoGain(params.minInfoGain)
          .setCacheNodeIds(params.cacheNodeIds)
          .setCheckpointInterval(params.checkpointInterval)
      case _ => throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }
    stages += dt
    val pipeline = new Pipeline().setStages(stages.toArray)

    // Fit the Pipeline.
    val startTime = System.nanoTime()
    val pipelineModel = pipeline.fit(training)
    val elapsedTime = (System.nanoTime() - startTime) / 1e9
    println(s"Training time: $elapsedTime seconds")

    // Get the trained Decision Tree from the fitted PipelineModel.
    algo match {
      case "classification" =>
        val treeModel = pipelineModel.stages.last.asInstanceOf[DecisionTreeClassificationModel]
        if (treeModel.numNodes < 20) {
          println(treeModel.toDebugString) // Print full model.
        } else {
          println(treeModel) // Print model summary.
        }
      case "regression" =>
        val treeModel = pipelineModel.stages.last.asInstanceOf[DecisionTreeRegressionModel]
        if (treeModel.numNodes < 20) {
          println(treeModel.toDebugString) // Print full model.
        } else {
          println(treeModel) // Print model summary.
        }
      case _ => throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }

    // Evaluate model on training, test data.
    algo match {
      case "classification" =>
        println("Training data results:")
        evaluateClassificationModel(pipelineModel, training, labelColName)
        println("Test data results:")
        evaluateClassificationModel(pipelineModel, test, labelColName)
      case "regression" =>
        println("Training data results:")
        evaluateRegressionModel(pipelineModel, training, labelColName)
        println("Test data results:")
        evaluateRegressionModel(pipelineModel, test, labelColName)
      case _ =>
        throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }

    spark.stop()
  }

  /**
   * Evaluate the given ClassificationModel on data. Print the results.
   * @param model  Must fit ClassificationModel abstraction
   * @param data  DataFrame with "prediction" and labelColName columns
   * @param labelColName  Name of the labelCol parameter for the model
   *
   * TODO: Change model type to ClassificationModel once that API is public. SPARK-5995
   */
  private[ml] def evaluateClassificationModel(
      model: Transformer,
      data: DataFrame,
      labelColName: String): Unit = {
    val fullPredictions = model.transform(data).cache()
    val predictions = fullPredictions.select("prediction").rdd.map(_.getDouble(0))
    val labels = fullPredictions.select(labelColName).rdd.map(_.getDouble(0))
    // Print number of classes for reference.
    val numClasses = MetadataUtils.getNumClasses(fullPredictions.schema(labelColName)) match {
      case Some(n) => n
      case None => throw new RuntimeException(
        "Unknown failure when indexing labels for classification.")
    }
    val accuracy = new MulticlassMetrics(predictions.zip(labels)).accuracy
    println(s"  Accuracy ($numClasses classes): $accuracy")
  }

  /**
   * Evaluate the given RegressionModel on data. Print the results.
   * @param model  Must fit RegressionModel abstraction
   * @param data  DataFrame with "prediction" and labelColName columns
   * @param labelColName  Name of the labelCol parameter for the model
   *
   * TODO: Change model type to RegressionModel once that API is public. SPARK-5995
   */
  private[ml] def evaluateRegressionModel(
      model: Transformer,
      data: DataFrame,
      labelColName: String): Unit = {
    val fullPredictions = model.transform(data).cache()
    val predictions = fullPredictions.select("prediction").rdd.map(_.getDouble(0))
    val labels = fullPredictions.select(labelColName).rdd.map(_.getDouble(0))
    val RMSE = new RegressionMetrics(predictions.zip(labels)).rootMeanSquaredError
    println(s"  Root mean squared error (RMSE): $RMSE")
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// scalastyle:off println
// $example on$
import org.apache.spark.ml.clustering.LDA
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating LDA.
 * Run with
 * {{{
 * bin/run-example ml.LDAExample
 * }}}
 */
object LDAExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()

    // $example on$
    // Loads data.
    val dataset = spark.read.format("libsvm")
      .load("data/mllib/sample_lda_libsvm_data.txt")

    // Trains a LDA model.
    val lda = new LDA().setK(10).setMaxIter(10)
    val model = lda.fit(dataset)

    val ll = model.logLikelihood(dataset)
    val lp = model.logPerplexity(dataset)
    println(s"The lower bound on the log likelihood of the entire corpus: $ll")
    println(s"The upper bound on perplexity: $lp")

    // Describe topics.
    val topics = model.describeTopics(3)
    println("The topics described by their top-weighted terms:")
    topics.show(false)

    // Shows the result.
    val transformed = model.transform(dataset)
    transformed.show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.UnaryTransformer
import org.apache.spark.ml.param.DoubleParam
import org.apache.spark.ml.util.{DefaultParamsReadable, DefaultParamsWritable, Identifiable}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.types.{DataType, DataTypes}
import org.apache.spark.util.Utils
// $example off$

/**
 * An example demonstrating creating a custom [[org.apache.spark.ml.Transformer]] using
 * the [[UnaryTransformer]] abstraction.
 *
 * Run with
 * {{{
 * bin/run-example ml.UnaryTransformerExample
 * }}}
 */
object UnaryTransformerExample {

  // $example on$
  /**
   * Simple Transformer which adds a constant value to input Doubles.
   *
   * [[UnaryTransformer]] can be used to create a stage usable within Pipelines.
   * It defines parameters for specifying input and output columns:
   * [[UnaryTransformer.inputCol]] and [[UnaryTransformer.outputCol]].
   * It can optionally handle schema validation.
   *
   * [[DefaultParamsWritable]] provides a default implementation for persisting instances
   * of this Transformer.
   */
  class MyTransformer(override val uid: String)
    extends UnaryTransformer[Double, Double, MyTransformer] with DefaultParamsWritable {

    final val shift: DoubleParam = new DoubleParam(this, "shift", "Value added to input")

    def getShift: Double = $(shift)

    def setShift(value: Double): this.type = set(shift, value)

    def this() = this(Identifiable.randomUID("myT"))

    override protected def createTransformFunc: Double => Double = (input: Double) => {
      input + $(shift)
    }

    override protected def outputDataType: DataType = DataTypes.DoubleType

    override protected def validateInputType(inputType: DataType): Unit = {
      require(inputType == DataTypes.DoubleType, s"Bad input type: $inputType. Requires Double.")
    }
  }

  /**
   * Companion object for our simple Transformer.
   *
   * [[DefaultParamsReadable]] provides a default implementation for loading instances
   * of this Transformer which were persisted using [[DefaultParamsWritable]].
   */
  object MyTransformer extends DefaultParamsReadable[MyTransformer]
  // $example off$

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder()
      .appName("UnaryTransformerExample")
      .getOrCreate()

    // $example on$
    val myTransformer = new MyTransformer()
      .setShift(0.5)
      .setInputCol("input")
      .setOutputCol("output")

    // Create data, transform, and display it.
    val data = spark.range(0, 5).toDF("input")
      .select(col("input").cast("double").as("input"))
    val result = myTransformer.transform(data)
    println("Transformed by adding constant value")
    result.show()

    // Save and load the Transformer.
    val tmpDir = Utils.createTempDir()
    val dirName = tmpDir.getCanonicalPath
    myTransformer.write.overwrite().save(dirName)
    val sameTransformer = MyTransformer.load(dirName)

    // Transform the data to show the results are identical.
    println("Same transform applied from loaded model")
    val sameResult = sameTransformer.transform(data)
    sameResult.show()

    Utils.deleteRecursively(tmpDir)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.{LogisticRegression, OneVsRest}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example of Multiclass to Binary Reduction with One Vs Rest,
 * using Logistic Regression as the base classifier.
 * Run with
 * {{{
 * ./bin/run-example ml.OneVsRestExample
 * }}}
 */

object OneVsRestExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName(s"OneVsRestExample")
      .getOrCreate()

    // $example on$
    // load data file.
    val inputData = spark.read.format("libsvm")
      .load("data/mllib/sample_multiclass_classification_data.txt")

    // generate the train/test split.
    val Array(train, test) = inputData.randomSplit(Array(0.8, 0.2))

    // instantiate the base classifier
    val classifier = new LogisticRegression()
      .setMaxIter(10)
      .setTol(1E-6)
      .setFitIntercept(true)

    // instantiate the One Vs Rest Classifier.
    val ovr = new OneVsRest().setClassifier(classifier)

    // train the multiclass model.
    val ovrModel = ovr.fit(train)

    // score the model on test data.
    val predictions = ovrModel.transform(test)

    // obtain evaluator.
    val evaluator = new MulticlassClassificationEvaluator()
      .setMetricName("accuracy")

    // compute the classification error on test data.
    val accuracy = evaluator.evaluate(predictions)
    println(s"Test Error = ${1 - accuracy}")
    // $example off$

    spark.stop()
  }

}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.PolynomialExpansion
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object PolynomialExpansionExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("PolynomialExpansionExample")
      .getOrCreate()

    // $example on$
    val data = Array(
      Vectors.dense(2.0, 1.0),
      Vectors.dense(0.0, 0.0),
      Vectors.dense(3.0, -1.0)
    )
    val df = spark.createDataFrame(data.map(Tuple1.apply)).toDF("features")

    val polyExpansion = new PolynomialExpansion()
      .setInputCol("features")
      .setOutputCol("polyFeatures")
      .setDegree(3)

    val polyDF = polyExpansion.transform(df)
    polyDF.show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.Interaction
import org.apache.spark.ml.feature.VectorAssembler
// $example off$
import org.apache.spark.sql.SparkSession

object InteractionExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("InteractionExample")
      .getOrCreate()

    // $example on$
    val df = spark.createDataFrame(Seq(
      (1, 1, 2, 3, 8, 4, 5),
      (2, 4, 3, 8, 7, 9, 8),
      (3, 6, 1, 9, 2, 3, 6),
      (4, 10, 8, 6, 9, 4, 5),
      (5, 9, 2, 7, 10, 7, 3),
      (6, 1, 1, 4, 2, 8, 4)
    )).toDF("id1", "id2", "id3", "id4", "id5", "id6", "id7")

    val assembler1 = new VectorAssembler().
      setInputCols(Array("id2", "id3", "id4")).
      setOutputCol("vec1")

    val assembled1 = assembler1.transform(df)

    val assembler2 = new VectorAssembler().
      setInputCols(Array("id5", "id6", "id7")).
      setOutputCol("vec2")

    val assembled2 = assembler2.transform(assembled1).select("id1", "vec1", "vec2")

    val interaction = new Interaction()
      .setInputCols(Array("id1", "vec1", "vec2"))
      .setOutputCol("interactedCol")

    val interacted = interaction.transform(assembled2)

    interacted.show(truncate = false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.VectorIndexer
import org.apache.spark.ml.regression.{GBTRegressionModel, GBTRegressor}
// $example off$
import org.apache.spark.sql.SparkSession

object GradientBoostedTreeRegressorExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("GradientBoostedTreeRegressorExample")
      .getOrCreate()

    // $example on$
    // Load and parse the data file, converting it to a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Automatically identify categorical features, and index them.
    // Set maxCategories so features with > 4 distinct values are treated as continuous.
    val featureIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(4)
      .fit(data)

    // Split the data into training and test sets (30% held out for testing).
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Train a GBT model.
    val gbt = new GBTRegressor()
      .setLabelCol("label")
      .setFeaturesCol("indexedFeatures")
      .setMaxIter(10)

    // Chain indexer and GBT in a Pipeline.
    val pipeline = new Pipeline()
      .setStages(Array(featureIndexer, gbt))

    // Train model. This also runs the indexer.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select example rows to display.
    predictions.select("prediction", "label", "features").show(5)

    // Select (prediction, true label) and compute test error.
    val evaluator = new RegressionEvaluator()
      .setLabelCol("label")
      .setPredictionCol("prediction")
      .setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)
    println(s"Root Mean Squared Error (RMSE) on test data = $rmse")

    val gbtModel = model.stages(1).asInstanceOf[GBTRegressionModel]
    println(s"Learned regression GBT model:\n ${gbtModel.toDebugString}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.StopWordsRemover
// $example off$
import org.apache.spark.sql.SparkSession

object StopWordsRemoverExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("StopWordsRemoverExample")
      .getOrCreate()

    // $example on$
    val remover = new StopWordsRemover()
      .setInputCol("raw")
      .setOutputCol("filtered")

    val dataSet = spark.createDataFrame(Seq(
      (0, Seq("I", "saw", "the", "red", "balloon")),
      (1, Seq("Mary", "had", "a", "little", "lamb"))
    )).toDF("id", "raw")

    remover.transform(dataSet).show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.SQLTransformer
// $example off$
import org.apache.spark.sql.SparkSession

object SQLTransformerExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("SQLTransformerExample")
      .getOrCreate()

    // $example on$
    val df = spark.createDataFrame(
      Seq((0, 1.0, 3.0), (2, 2.0, 5.0))).toDF("id", "v1", "v2")

    val sqlTrans = new SQLTransformer().setStatement(
      "SELECT *, (v1 + v2) AS v3, (v1 * v2) AS v4 FROM __THIS__")

    sqlTrans.transform(df).show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.ElementwiseProduct
import org.apache.spark.ml.linalg.Vectors
// $example off$
import org.apache.spark.sql.SparkSession

object ElementwiseProductExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("ElementwiseProductExample")
      .getOrCreate()

    // $example on$
    // Create some vector data; also works for sparse vectors
    val dataFrame = spark.createDataFrame(Seq(
      ("a", Vectors.dense(1.0, 2.0, 3.0)),
      ("b", Vectors.dense(4.0, 5.0, 6.0)))).toDF("id", "vector")

    val transformingVector = Vectors.dense(0.0, 1.0, 2.0)
    val transformer = new ElementwiseProduct()
      .setScalingVec(transformingVector)
      .setInputCol("vector")
      .setOutputCol("transformedVector")

    // Batch transform the vectors to create new column:
    transformer.transform(dataFrame).show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import java.util.Locale

import scala.collection.mutable

import scopt.OptionParser

import org.apache.spark.examples.mllib.AbstractParams
import org.apache.spark.ml.{Pipeline, PipelineStage}
import org.apache.spark.ml.classification.{GBTClassificationModel, GBTClassifier}
import org.apache.spark.ml.feature.{StringIndexer, VectorIndexer}
import org.apache.spark.ml.regression.{GBTRegressionModel, GBTRegressor}
import org.apache.spark.sql.{DataFrame, SparkSession}


/**
 * An example runner for decision trees. Run with
 * {{{
 * ./bin/run-example ml.GBTExample [options]
 * }}}
 * Decision Trees and ensembles can take a large amount of memory. If the run-example command
 * above fails, try running via spark-submit and specifying the amount of memory as at least 1g.
 * For local mode, run
 * {{{
 * ./bin/spark-submit --class org.apache.spark.examples.ml.GBTExample --driver-memory 1g
 *   [examples JAR path] [options]
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object GBTExample {

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      algo: String = "classification",
      maxDepth: Int = 5,
      maxBins: Int = 32,
      minInstancesPerNode: Int = 1,
      minInfoGain: Double = 0.0,
      maxIter: Int = 10,
      fracTest: Double = 0.2,
      cacheNodeIds: Boolean = false,
      checkpointDir: Option[String] = None,
      checkpointInterval: Int = 10) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("GBTExample") {
      head("GBTExample: an example Gradient-Boosted Trees app.")
      opt[String]("algo")
        .text(s"algorithm (classification, regression), default: ${defaultParams.algo}")
        .action((x, c) => c.copy(algo = x))
      opt[Int]("maxDepth")
        .text(s"max depth of the tree, default: ${defaultParams.maxDepth}")
        .action((x, c) => c.copy(maxDepth = x))
      opt[Int]("maxBins")
        .text(s"max number of bins, default: ${defaultParams.maxBins}")
        .action((x, c) => c.copy(maxBins = x))
      opt[Int]("minInstancesPerNode")
        .text(s"min number of instances required at child nodes to create the parent split," +
        s" default: ${defaultParams.minInstancesPerNode}")
        .action((x, c) => c.copy(minInstancesPerNode = x))
      opt[Double]("minInfoGain")
        .text(s"min info gain required to create a split, default: ${defaultParams.minInfoGain}")
        .action((x, c) => c.copy(minInfoGain = x))
      opt[Int]("maxIter")
        .text(s"number of trees in ensemble, default: ${defaultParams.maxIter}")
        .action((x, c) => c.copy(maxIter = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing. If given option testInput, " +
        s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[Boolean]("cacheNodeIds")
        .text(s"whether to use node Id cache during training, " +
        s"default: ${defaultParams.cacheNodeIds}")
        .action((x, c) => c.copy(cacheNodeIds = x))
      opt[String]("checkpointDir")
        .text(s"checkpoint directory where intermediate node Id caches will be stored, " +
        s"default: ${
          defaultParams.checkpointDir match {
            case Some(strVal) => strVal
            case None => "None"
          }
        }")
        .action((x, c) => c.copy(checkpointDir = Some(x)))
      opt[Int]("checkpointInterval")
        .text(s"how often to checkpoint the node Id cache, " +
        s"default: ${defaultParams.checkpointInterval}")
        .action((x, c) => c.copy(checkpointInterval = x))
      opt[String]("testInput")
        .text(s"input path to test dataset. If given, option fracTest is ignored." +
        s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest >= 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1).")
        } else {
          success
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"GBTExample with $params")
      .getOrCreate()

    params.checkpointDir.foreach(spark.sparkContext.setCheckpointDir)
    val algo = params.algo.toLowerCase(Locale.ROOT)

    println(s"GBTExample with parameters:\n$params")

    // Load training and test data and cache it.
    val (training: DataFrame, test: DataFrame) = DecisionTreeExample.loadDatasets(params.input,
      params.dataFormat, params.testInput, algo, params.fracTest)

    // Set up Pipeline
    val stages = new mutable.ArrayBuffer[PipelineStage]()
    // (1) For classification, re-index classes.
    val labelColName = if (algo == "classification") "indexedLabel" else "label"
    if (algo == "classification") {
      val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol(labelColName)
      stages += labelIndexer
    }
    // (2) Identify categorical features using VectorIndexer.
    //     Features with more than maxCategories values will be treated as continuous.
    val featuresIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(10)
    stages += featuresIndexer
    // (3) Learn GBT.
    val dt = algo match {
      case "classification" =>
        new GBTClassifier()
          .setFeaturesCol("indexedFeatures")
          .setLabelCol(labelColName)
          .setMaxDepth(params.maxDepth)
          .setMaxBins(params.maxBins)
          .setMinInstancesPerNode(params.minInstancesPerNode)
          .setMinInfoGain(params.minInfoGain)
          .setCacheNodeIds(params.cacheNodeIds)
          .setCheckpointInterval(params.checkpointInterval)
          .setMaxIter(params.maxIter)
      case "regression" =>
        new GBTRegressor()
          .setFeaturesCol("indexedFeatures")
          .setLabelCol(labelColName)
          .setMaxDepth(params.maxDepth)
          .setMaxBins(params.maxBins)
          .setMinInstancesPerNode(params.minInstancesPerNode)
          .setMinInfoGain(params.minInfoGain)
          .setCacheNodeIds(params.cacheNodeIds)
          .setCheckpointInterval(params.checkpointInterval)
          .setMaxIter(params.maxIter)
      case _ => throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }
    stages += dt
    val pipeline = new Pipeline().setStages(stages.toArray)

    // Fit the Pipeline.
    val startTime = System.nanoTime()
    val pipelineModel = pipeline.fit(training)
    val elapsedTime = (System.nanoTime() - startTime) / 1e9
    println(s"Training time: $elapsedTime seconds")

    // Get the trained GBT from the fitted PipelineModel.
    algo match {
      case "classification" =>
        val rfModel = pipelineModel.stages.last.asInstanceOf[GBTClassificationModel]
        if (rfModel.totalNumNodes < 30) {
          println(rfModel.toDebugString) // Print full model.
        } else {
          println(rfModel) // Print model summary.
        }
      case "regression" =>
        val rfModel = pipelineModel.stages.last.asInstanceOf[GBTRegressionModel]
        if (rfModel.totalNumNodes < 30) {
          println(rfModel.toDebugString) // Print full model.
        } else {
          println(rfModel) // Print model summary.
        }
      case _ => throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }

    // Evaluate model on training, test data.
    algo match {
      case "classification" =>
        println("Training data results:")
        DecisionTreeExample.evaluateClassificationModel(pipelineModel, training, labelColName)
        println("Test data results:")
        DecisionTreeExample.evaluateClassificationModel(pipelineModel, test, labelColName)
      case "regression" =>
        println("Training data results:")
        DecisionTreeExample.evaluateRegressionModel(pipelineModel, training, labelColName)
        println("Test data results:")
        DecisionTreeExample.evaluateRegressionModel(pipelineModel, test, labelColName)
      case _ =>
        throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.Word2Vec
import org.apache.spark.ml.linalg.Vector
import org.apache.spark.sql.Row
// $example off$
import org.apache.spark.sql.SparkSession

object Word2VecExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("Word2Vec example")
      .getOrCreate()

    // $example on$
    // Input data: Each row is a bag of words from a sentence or document.
    val documentDF = spark.createDataFrame(Seq(
      "Hi I heard about Spark".split(" "),
      "I wish Java could use case classes".split(" "),
      "Logistic regression models are neat".split(" ")
    ).map(Tuple1.apply)).toDF("text")

    // Learn a mapping from words to Vectors.
    val word2Vec = new Word2Vec()
      .setInputCol("text")
      .setOutputCol("result")
      .setVectorSize(3)
      .setMinCount(0)
    val model = word2Vec.fit(documentDF)

    val result = model.transform(documentDF)
    result.collect().foreach { case Row(text: Seq[_], features: Vector) =>
      println(s"Text: [${text.mkString(", ")}] => \nVector: $features\n") }
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.fpm.PrefixSpan
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating PrefixSpan.
 * Run with
 * {{{
 * bin/run-example ml.PrefixSpanExample
 * }}}
 */
object PrefixSpanExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"${this.getClass.getSimpleName}")
      .getOrCreate()
    import spark.implicits._

    // $example on$
    val smallTestData = Seq(
      Seq(Seq(1, 2), Seq(3)),
      Seq(Seq(1), Seq(3, 2), Seq(1, 2)),
      Seq(Seq(1, 2), Seq(5)),
      Seq(Seq(6)))

    val df = smallTestData.toDF("sequence")
    val result = new PrefixSpan()
      .setMinSupport(0.5)
      .setMaxPatternLength(5)
      .setMaxLocalProjDBSize(32000000)
      .findFrequentSequentialPatterns(df)
      .show()
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import scopt.OptionParser

import org.apache.spark.examples.mllib.AbstractParams
import org.apache.spark.ml.regression.LinearRegression
import org.apache.spark.sql.{DataFrame, SparkSession}

/**
 * An example runner for linear regression with elastic-net (mixing L1/L2) regularization.
 * Run with
 * {{{
 * bin/run-example ml.LinearRegressionExample [options]
 * }}}
 * A synthetic dataset can be found at `data/mllib/sample_linear_regression_data.txt` which can be
 * trained by
 * {{{
 * bin/run-example ml.LinearRegressionExample --regParam 0.15 --elasticNetParam 1.0 \
 *   data/mllib/sample_linear_regression_data.txt
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object LinearRegressionExample {

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      regParam: Double = 0.0,
      elasticNetParam: Double = 0.0,
      maxIter: Int = 100,
      tol: Double = 1E-6,
      fracTest: Double = 0.2) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("LinearRegressionExample") {
      head("LinearRegressionExample: an example Linear Regression with Elastic-Net app.")
      opt[Double]("regParam")
        .text(s"regularization parameter, default: ${defaultParams.regParam}")
        .action((x, c) => c.copy(regParam = x))
      opt[Double]("elasticNetParam")
        .text(s"ElasticNet mixing parameter. For alpha = 0, the penalty is an L2 penalty. " +
        s"For alpha = 1, it is an L1 penalty. For 0 < alpha < 1, the penalty is a combination of " +
        s"L1 and L2, default: ${defaultParams.elasticNetParam}")
        .action((x, c) => c.copy(elasticNetParam = x))
      opt[Int]("maxIter")
        .text(s"maximum number of iterations, default: ${defaultParams.maxIter}")
        .action((x, c) => c.copy(maxIter = x))
      opt[Double]("tol")
        .text(s"the convergence tolerance of iterations, Smaller value will lead " +
        s"to higher accuracy with the cost of more iterations, default: ${defaultParams.tol}")
        .action((x, c) => c.copy(tol = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing. If given option testInput, " +
        s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[String]("testInput")
        .text(s"input path to test dataset. If given, option fracTest is ignored." +
        s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest >= 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1).")
        } else {
          success
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"LinearRegressionExample with $params")
      .getOrCreate()

    println(s"LinearRegressionExample with parameters:\n$params")

    // Load training and test data and cache it.
    val (training: DataFrame, test: DataFrame) = DecisionTreeExample.loadDatasets(params.input,
      params.dataFormat, params.testInput, "regression", params.fracTest)

    val lir = new LinearRegression()
      .setFeaturesCol("features")
      .setLabelCol("label")
      .setRegParam(params.regParam)
      .setElasticNetParam(params.elasticNetParam)
      .setMaxIter(params.maxIter)
      .setTol(params.tol)

    // Train the model
    val startTime = System.nanoTime()
    val lirModel = lir.fit(training)
    val elapsedTime = (System.nanoTime() - startTime) / 1e9
    println(s"Training time: $elapsedTime seconds")

    // Print the weights and intercept for linear regression.
    println(s"Weights: ${lirModel.coefficients} Intercept: ${lirModel.intercept}")

    println("Training data results:")
    DecisionTreeExample.evaluateRegressionModel(lirModel, training, "label")
    println("Test data results:")
    DecisionTreeExample.evaluateRegressionModel(lirModel, test, "label")

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.Binarizer
// $example off$
import org.apache.spark.sql.SparkSession

object BinarizerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("BinarizerExample")
      .getOrCreate()

    // $example on$
    val data = Array((0, 0.1), (1, 0.8), (2, 0.2))
    val dataFrame = spark.createDataFrame(data).toDF("id", "feature")

    val binarizer: Binarizer = new Binarizer()
      .setInputCol("feature")
      .setOutputCol("binarized_feature")
      .setThreshold(0.5)

    val binarizedDataFrame = binarizer.transform(dataFrame)

    println(s"Binarizer output with Threshold = ${binarizer.getThreshold}")
    binarizedDataFrame.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import scala.collection.mutable

import scopt.OptionParser

import org.apache.spark.examples.mllib.AbstractParams
import org.apache.spark.ml.{Pipeline, PipelineStage}
import org.apache.spark.ml.classification.{LogisticRegression, LogisticRegressionModel}
import org.apache.spark.ml.feature.StringIndexer
import org.apache.spark.sql.{DataFrame, SparkSession}

/**
 * An example runner for logistic regression with elastic-net (mixing L1/L2) regularization.
 * Run with
 * {{{
 * bin/run-example ml.LogisticRegressionExample [options]
 * }}}
 * A synthetic dataset can be found at `data/mllib/sample_libsvm_data.txt` which can be
 * trained by
 * {{{
 * bin/run-example ml.LogisticRegressionExample --regParam 0.3 --elasticNetParam 0.8 \
 *   data/mllib/sample_libsvm_data.txt
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object LogisticRegressionExample {

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      regParam: Double = 0.0,
      elasticNetParam: Double = 0.0,
      maxIter: Int = 100,
      fitIntercept: Boolean = true,
      tol: Double = 1E-6,
      fracTest: Double = 0.2) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("LogisticRegressionExample") {
      head("LogisticRegressionExample: an example Logistic Regression with Elastic-Net app.")
      opt[Double]("regParam")
        .text(s"regularization parameter, default: ${defaultParams.regParam}")
        .action((x, c) => c.copy(regParam = x))
      opt[Double]("elasticNetParam")
        .text(s"ElasticNet mixing parameter. For alpha = 0, the penalty is an L2 penalty. " +
        s"For alpha = 1, it is an L1 penalty. For 0 < alpha < 1, the penalty is a combination of " +
        s"L1 and L2, default: ${defaultParams.elasticNetParam}")
        .action((x, c) => c.copy(elasticNetParam = x))
      opt[Int]("maxIter")
        .text(s"maximum number of iterations, default: ${defaultParams.maxIter}")
        .action((x, c) => c.copy(maxIter = x))
      opt[Boolean]("fitIntercept")
        .text(s"whether to fit an intercept term, default: ${defaultParams.fitIntercept}")
        .action((x, c) => c.copy(fitIntercept = x))
      opt[Double]("tol")
        .text(s"the convergence tolerance of iterations, Smaller value will lead " +
        s"to higher accuracy with the cost of more iterations, default: ${defaultParams.tol}")
        .action((x, c) => c.copy(tol = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing. If given option testInput, " +
        s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[String]("testInput")
        .text(s"input path to test dataset. If given, option fracTest is ignored." +
        s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest >= 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1).")
        } else {
          success
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"LogisticRegressionExample with $params")
      .getOrCreate()

    println(s"LogisticRegressionExample with parameters:\n$params")

    // Load training and test data and cache it.
    val (training: DataFrame, test: DataFrame) = DecisionTreeExample.loadDatasets(params.input,
      params.dataFormat, params.testInput, "classification", params.fracTest)

    // Set up Pipeline.
    val stages = new mutable.ArrayBuffer[PipelineStage]()

    val labelIndexer = new StringIndexer()
      .setInputCol("label")
      .setOutputCol("indexedLabel")
    stages += labelIndexer

    val lor = new LogisticRegression()
      .setFeaturesCol("features")
      .setLabelCol("indexedLabel")
      .setRegParam(params.regParam)
      .setElasticNetParam(params.elasticNetParam)
      .setMaxIter(params.maxIter)
      .setTol(params.tol)
      .setFitIntercept(params.fitIntercept)

    stages += lor
    val pipeline = new Pipeline().setStages(stages.toArray)

    // Fit the Pipeline.
    val startTime = System.nanoTime()
    val pipelineModel = pipeline.fit(training)
    val elapsedTime = (System.nanoTime() - startTime) / 1e9
    println(s"Training time: $elapsedTime seconds")

    val lorModel = pipelineModel.stages.last.asInstanceOf[LogisticRegressionModel]
    // Print the weights and intercept for logistic regression.
    println(s"Weights: ${lorModel.coefficients} Intercept: ${lorModel.intercept}")

    println("Training data results:")
    DecisionTreeExample.evaluateClassificationModel(pipelineModel, training, "indexedLabel")
    println("Test data results:")
    DecisionTreeExample.evaluateClassificationModel(pipelineModel, test, "indexedLabel")

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.BucketedRandomProjectionLSH
import org.apache.spark.ml.linalg.Vectors
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.col
// $example off$

/**
 * An example demonstrating BucketedRandomProjectionLSH.
 * Run with:
 *   bin/run-example ml.BucketedRandomProjectionLSHExample
 */
object BucketedRandomProjectionLSHExample {
  def main(args: Array[String]): Unit = {
    // Creates a SparkSession
    val spark = SparkSession
      .builder
      .appName("BucketedRandomProjectionLSHExample")
      .getOrCreate()

    // $example on$
    val dfA = spark.createDataFrame(Seq(
      (0, Vectors.dense(1.0, 1.0)),
      (1, Vectors.dense(1.0, -1.0)),
      (2, Vectors.dense(-1.0, -1.0)),
      (3, Vectors.dense(-1.0, 1.0))
    )).toDF("id", "features")

    val dfB = spark.createDataFrame(Seq(
      (4, Vectors.dense(1.0, 0.0)),
      (5, Vectors.dense(-1.0, 0.0)),
      (6, Vectors.dense(0.0, 1.0)),
      (7, Vectors.dense(0.0, -1.0))
    )).toDF("id", "features")

    val key = Vectors.dense(1.0, 0.0)

    val brp = new BucketedRandomProjectionLSH()
      .setBucketLength(2.0)
      .setNumHashTables(3)
      .setInputCol("features")
      .setOutputCol("hashes")

    val model = brp.fit(dfA)

    // Feature Transformation
    println("The hashed dataset where hashed values are stored in the column 'hashes':")
    model.transform(dfA).show()

    // Compute the locality sensitive hashes for the input rows, then perform approximate
    // similarity join.
    // We could avoid computing hashes by passing in the already-transformed dataset, e.g.
    // `model.approxSimilarityJoin(transformedA, transformedB, 1.5)`
    println("Approximately joining dfA and dfB on Euclidean distance smaller than 1.5:")
    model.approxSimilarityJoin(dfA, dfB, 1.5, "EuclideanDistance")
      .select(col("datasetA.id").alias("idA"),
        col("datasetB.id").alias("idB"),
        col("EuclideanDistance")).show()

    // Compute the locality sensitive hashes for the input rows, then perform approximate nearest
    // neighbor search.
    // We could avoid computing hashes by passing in the already-transformed dataset, e.g.
    // `model.approxNearestNeighbors(transformedA, key, 2)`
    println("Approximately searching dfA for 2 nearest neighbors of the key:")
    model.approxNearestNeighbors(dfA, key, 2).show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.StandardScaler
// $example off$
import org.apache.spark.sql.SparkSession

object StandardScalerExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("StandardScalerExample")
      .getOrCreate()

    // $example on$
    val dataFrame = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    val scaler = new StandardScaler()
      .setInputCol("features")
      .setOutputCol("scaledFeatures")
      .setWithStd(true)
      .setWithMean(false)

    // Compute summary statistics by fitting the StandardScaler.
    val scalerModel = scaler.fit(dataFrame)

    // Normalize each feature to have unit standard deviation.
    val scaledData = scalerModel.transform(dataFrame)
    scaledData.show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.regression.GeneralizedLinearRegression
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating generalized linear regression.
 * Run with
 * {{{
 * bin/run-example ml.GeneralizedLinearRegressionExample
 * }}}
 */

object GeneralizedLinearRegressionExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("GeneralizedLinearRegressionExample")
      .getOrCreate()

    // $example on$
    // Load training data
    val dataset = spark.read.format("libsvm")
      .load("data/mllib/sample_linear_regression_data.txt")

    val glr = new GeneralizedLinearRegression()
      .setFamily("gaussian")
      .setLink("identity")
      .setMaxIter(10)
      .setRegParam(0.3)

    // Fit the model
    val model = glr.fit(dataset)

    // Print the coefficients and intercept for generalized linear regression model
    println(s"Coefficients: ${model.coefficients}")
    println(s"Intercept: ${model.intercept}")

    // Summarize the model over the training set and print out some metrics
    val summary = model.summary
    println(s"Coefficient Standard Errors: ${summary.coefficientStandardErrors.mkString(",")}")
    println(s"T Values: ${summary.tValues.mkString(",")}")
    println(s"P Values: ${summary.pValues.mkString(",")}")
    println(s"Dispersion: ${summary.dispersion}")
    println(s"Null Deviance: ${summary.nullDeviance}")
    println(s"Residual Degree Of Freedom Null: ${summary.residualDegreeOfFreedomNull}")
    println(s"Deviance: ${summary.deviance}")
    println(s"Residual Degree Of Freedom: ${summary.residualDegreeOfFreedom}")
    println(s"AIC: ${summary.aic}")
    println("Deviance Residuals: ")
    summary.residuals().show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.{HashingTF, IDF, Tokenizer}
// $example off$
import org.apache.spark.sql.SparkSession

object TfIdfExample {

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("TfIdfExample")
      .getOrCreate()

    // $example on$
    val sentenceData = spark.createDataFrame(Seq(
      (0.0, "Hi I heard about Spark"),
      (0.0, "I wish Java could use case classes"),
      (1.0, "Logistic regression models are neat")
    )).toDF("label", "sentence")

    val tokenizer = new Tokenizer().setInputCol("sentence").setOutputCol("words")
    val wordsData = tokenizer.transform(sentenceData)

    val hashingTF = new HashingTF()
      .setInputCol("words").setOutputCol("rawFeatures").setNumFeatures(20)

    val featurizedData = hashingTF.transform(wordsData)
    // alternatively, CountVectorizer can also be used to get term frequency vectors

    val idf = new IDF().setInputCol("rawFeatures").setOutputCol("features")
    val idfModel = idf.fit(featurizedData)

    val rescaledData = idfModel.transform(featurizedData)
    rescaledData.select("label", "features").show()
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.{Pipeline, PipelineModel}
import org.apache.spark.ml.classification.LogisticRegression
import org.apache.spark.ml.feature.{HashingTF, Tokenizer}
import org.apache.spark.ml.linalg.Vector
import org.apache.spark.sql.Row
// $example off$
import org.apache.spark.sql.SparkSession

object PipelineExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("PipelineExample")
      .getOrCreate()

    // $example on$
    // Prepare training documents from a list of (id, text, label) tuples.
    val training = spark.createDataFrame(Seq(
      (0L, "a b c d e spark", 1.0),
      (1L, "b d", 0.0),
      (2L, "spark f g h", 1.0),
      (3L, "hadoop mapreduce", 0.0)
    )).toDF("id", "text", "label")

    // Configure an ML pipeline, which consists of three stages: tokenizer, hashingTF, and lr.
    val tokenizer = new Tokenizer()
      .setInputCol("text")
      .setOutputCol("words")
    val hashingTF = new HashingTF()
      .setNumFeatures(1000)
      .setInputCol(tokenizer.getOutputCol)
      .setOutputCol("features")
    val lr = new LogisticRegression()
      .setMaxIter(10)
      .setRegParam(0.001)
    val pipeline = new Pipeline()
      .setStages(Array(tokenizer, hashingTF, lr))

    // Fit the pipeline to training documents.
    val model = pipeline.fit(training)

    // Now we can optionally save the fitted pipeline to disk
    model.write.overwrite().save("/tmp/spark-logistic-regression-model")

    // We can also save this unfit pipeline to disk
    pipeline.write.overwrite().save("/tmp/unfit-lr-model")

    // And load it back in during production
    val sameModel = PipelineModel.load("/tmp/spark-logistic-regression-model")

    // Prepare test documents, which are unlabeled (id, text) tuples.
    val test = spark.createDataFrame(Seq(
      (4L, "spark i j k"),
      (5L, "l m n"),
      (6L, "spark hadoop spark"),
      (7L, "apache hadoop")
    )).toDF("id", "text")

    // Make predictions on test documents.
    model.transform(test)
      .select("id", "text", "probability", "prediction")
      .collect()
      .foreach { case Row(id: Long, text: String, prob: Vector, prediction: Double) =>
        println(s"($id, $text) --> prob=$prob, prediction=$prediction")
      }
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.linalg.Vectors
import org.apache.spark.ml.regression.AFTSurvivalRegression
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating AFTSurvivalRegression.
 * Run with
 * {{{
 * bin/run-example ml.AFTSurvivalRegressionExample
 * }}}
 */
object AFTSurvivalRegressionExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("AFTSurvivalRegressionExample")
      .getOrCreate()

    // $example on$
    val training = spark.createDataFrame(Seq(
      (1.218, 1.0, Vectors.dense(1.560, -0.605)),
      (2.949, 0.0, Vectors.dense(0.346, 2.158)),
      (3.627, 0.0, Vectors.dense(1.380, 0.231)),
      (0.273, 1.0, Vectors.dense(0.520, 1.151)),
      (4.199, 0.0, Vectors.dense(0.795, -0.226))
    )).toDF("label", "censor", "features")
    val quantileProbabilities = Array(0.3, 0.6)
    val aft = new AFTSurvivalRegression()
      .setQuantileProbabilities(quantileProbabilities)
      .setQuantilesCol("quantiles")

    val model = aft.fit(training)

    // Print the coefficients, intercept and scale parameter for AFT survival regression
    println(s"Coefficients: ${model.coefficients}")
    println(s"Intercept: ${model.intercept}")
    println(s"Scale: ${model.scale}")
    model.transform(training).show(false)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import org.apache.spark.ml.classification.{ClassificationModel, Classifier, ClassifierParams}
import org.apache.spark.ml.feature.LabeledPoint
import org.apache.spark.ml.linalg.{BLAS, Vector, Vectors}
import org.apache.spark.ml.param.{IntParam, ParamMap}
import org.apache.spark.ml.util.Identifiable
import org.apache.spark.sql.{Dataset, Row, SparkSession}

/**
 * A simple example demonstrating how to write your own learning algorithm using Estimator,
 * Transformer, and other abstractions.
 * This mimics [[org.apache.spark.ml.classification.LogisticRegression]].
 * Run with
 * {{{
 * bin/run-example ml.DeveloperApiExample
 * }}}
 */
object DeveloperApiExample {

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("DeveloperApiExample")
      .getOrCreate()
    import spark.implicits._

    // Prepare training data.
    val training = spark.createDataFrame(Seq(
      LabeledPoint(1.0, Vectors.dense(0.0, 1.1, 0.1)),
      LabeledPoint(0.0, Vectors.dense(2.0, 1.0, -1.0)),
      LabeledPoint(0.0, Vectors.dense(2.0, 1.3, 1.0)),
      LabeledPoint(1.0, Vectors.dense(0.0, 1.2, -0.5))))

    // Create a LogisticRegression instance. This instance is an Estimator.
    val lr = new MyLogisticRegression()
    // Print out the parameters, documentation, and any default values.
    println(s"MyLogisticRegression parameters:\n ${lr.explainParams()}")

    // We may set parameters using setter methods.
    lr.setMaxIter(10)

    // Learn a LogisticRegression model. This uses the parameters stored in lr.
    val model = lr.fit(training.toDF())

    // Prepare test data.
    val test = spark.createDataFrame(Seq(
      LabeledPoint(1.0, Vectors.dense(-1.0, 1.5, 1.3)),
      LabeledPoint(0.0, Vectors.dense(3.0, 2.0, -0.1)),
      LabeledPoint(1.0, Vectors.dense(0.0, 2.2, -1.5))))

    // Make predictions on test data.
    val sumPredictions: Double = model.transform(test)
      .select("features", "label", "prediction")
      .collect()
      .map { case Row(features: Vector, label: Double, prediction: Double) =>
        prediction
      }.sum
    assert(sumPredictions == 0.0,
      "MyLogisticRegression predicted something other than 0, even though all coefficients are 0!")

    spark.stop()
  }
}

/**
 * Example of defining a parameter trait for a user-defined type of [[Classifier]].
 *
 * NOTE: This is private since it is an example. In practice, you may not want it to be private.
 */
private trait MyLogisticRegressionParams extends ClassifierParams {

  /**
   * Param for max number of iterations
   *
   * NOTE: The usual way to add a parameter to a model or algorithm is to include:
   *   - val myParamName: ParamType
   *   - def getMyParamName
   *   - def setMyParamName
   * Here, we have a trait to be mixed in with the Estimator and Model (MyLogisticRegression
   * and MyLogisticRegressionModel). We place the setter (setMaxIter) method in the Estimator
   * class since the maxIter parameter is only used during training (not in the Model).
   */
  val maxIter: IntParam = new IntParam(this, "maxIter", "max number of iterations")
  def getMaxIter: Int = $(maxIter)
}

/**
 * Example of defining a type of [[Classifier]].
 *
 * NOTE: This is private since it is an example. In practice, you may not want it to be private.
 */
private class MyLogisticRegression(override val uid: String)
  extends Classifier[Vector, MyLogisticRegression, MyLogisticRegressionModel]
  with MyLogisticRegressionParams {

  def this() = this(Identifiable.randomUID("myLogReg"))

  setMaxIter(100) // Initialize

  // The parameter setter is in this class since it should return type MyLogisticRegression.
  def setMaxIter(value: Int): this.type = set(maxIter, value)

  // This method is used by fit()
  override protected def train(dataset: Dataset[_]): MyLogisticRegressionModel = {
    // Extract columns from data using helper method.
    val oldDataset = extractLabeledPoints(dataset)

    // Do learning to estimate the coefficients vector.
    val numFeatures = oldDataset.take(1)(0).features.size
    val coefficients = Vectors.zeros(numFeatures) // Learning would happen here.

    // Create a model, and return it.
    new MyLogisticRegressionModel(uid, coefficients).setParent(this)
  }

  override def copy(extra: ParamMap): MyLogisticRegression = defaultCopy(extra)
}

/**
 * Example of defining a type of [[ClassificationModel]].
 *
 * NOTE: This is private since it is an example. In practice, you may not want it to be private.
 */
private class MyLogisticRegressionModel(
    override val uid: String,
    val coefficients: Vector)
  extends ClassificationModel[Vector, MyLogisticRegressionModel]
  with MyLogisticRegressionParams {

  // This uses the default implementation of transform(), which reads column "features" and outputs
  // columns "prediction" and "rawPrediction."

  // This uses the default implementation of predict(), which chooses the label corresponding to
  // the maximum value returned by [[predictRaw()]].

  /**
   * Raw prediction for each possible label.
   * The meaning of a "raw" prediction may vary between algorithms, but it intuitively gives
   * a measure of confidence in each possible label (where larger = more confident).
   * This internal method is used to implement [[transform()]] and output [[rawPredictionCol]].
   *
   * @return  vector where element i is the raw prediction for label i.
   *          This raw prediction may be any real number, where a larger value indicates greater
   *          confidence for that label.
   */
  override protected def predictRaw(features: Vector): Vector = {
    val margin = BLAS.dot(features, coefficients)
    // There are 2 classes (binary classification), so we return a length-2 vector,
    // where index i corresponds to class i (i = 0, 1).
    Vectors.dense(-margin, margin)
  }

  // Number of classes the label can take. 2 indicates binary classification.
  override val numClasses: Int = 2

  // Number of features the model was trained on.
  override val numFeatures: Int = coefficients.size

  /**
   * Create a copy of the model.
   * The copy is shallow, except for the embedded paramMap, which gets a deep copy.
   *
   * This is used for the default implementation of [[transform()]].
   */
  override def copy(extra: ParamMap): MyLogisticRegressionModel = {
    copyValues(new MyLogisticRegressionModel(uid, coefficients), extra).setParent(parent)
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.classification.LogisticRegression
// $example off$
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.max

object LogisticRegressionSummaryExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("LogisticRegressionSummaryExample")
      .getOrCreate()
    import spark.implicits._

    // Load training data
    val training = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    val lr = new LogisticRegression()
      .setMaxIter(10)
      .setRegParam(0.3)
      .setElasticNetParam(0.8)

    // Fit the model
    val lrModel = lr.fit(training)

    // $example on$
    // Extract the summary from the returned LogisticRegressionModel instance trained in the earlier
    // example
    val trainingSummary = lrModel.binarySummary

    // Obtain the objective per iteration.
    val objectiveHistory = trainingSummary.objectiveHistory
    println("objectiveHistory:")
    objectiveHistory.foreach(loss => println(loss))

    // Obtain the receiver-operating characteristic as a dataframe and areaUnderROC.
    val roc = trainingSummary.roc
    roc.show()
    println(s"areaUnderROC: ${trainingSummary.areaUnderROC}")

    // Set the model threshold to maximize F-Measure
    val fMeasure = trainingSummary.fMeasureByThreshold
    val maxFMeasure = fMeasure.select(max("F-Measure")).head().getDouble(0)
    val bestThreshold = fMeasure.where($"F-Measure" === maxFMeasure)
      .select("threshold").head().getDouble(0)
    lrModel.setThreshold(bestThreshold)
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.VectorIndexer
import org.apache.spark.ml.regression.{RandomForestRegressionModel, RandomForestRegressor}
// $example off$
import org.apache.spark.sql.SparkSession

object RandomForestRegressorExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("RandomForestRegressorExample")
      .getOrCreate()

    // $example on$
    // Load and parse the data file, converting it to a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Automatically identify categorical features, and index them.
    // Set maxCategories so features with > 4 distinct values are treated as continuous.
    val featureIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(4)
      .fit(data)

    // Split the data into training and test sets (30% held out for testing).
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Train a RandomForest model.
    val rf = new RandomForestRegressor()
      .setLabelCol("label")
      .setFeaturesCol("indexedFeatures")

    // Chain indexer and forest in a Pipeline.
    val pipeline = new Pipeline()
      .setStages(Array(featureIndexer, rf))

    // Train model. This also runs the indexer.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select example rows to display.
    predictions.select("prediction", "label", "features").show(5)

    // Select (prediction, true label) and compute test error.
    val evaluator = new RegressionEvaluator()
      .setLabelCol("label")
      .setPredictionCol("prediction")
      .setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)
    println(s"Root Mean Squared Error (RMSE) on test data = $rmse")

    val rfModel = model.stages(1).asInstanceOf[RandomForestRegressionModel]
    println(s"Learned regression forest model:\n ${rfModel.toDebugString}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.DecisionTreeClassificationModel
import org.apache.spark.ml.classification.DecisionTreeClassifier
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}
// $example off$
import org.apache.spark.sql.SparkSession

object DecisionTreeClassificationExample {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("DecisionTreeClassificationExample")
      .getOrCreate()
    // $example on$
    // Load the data stored in LIBSVM format as a DataFrame.
    val data = spark.read.format("libsvm").load("data/mllib/sample_libsvm_data.txt")

    // Index labels, adding metadata to the label column.
    // Fit on whole dataset to include all labels in index.
    val labelIndexer = new StringIndexer()
      .setInputCol("label")
      .setOutputCol("indexedLabel")
      .fit(data)
    // Automatically identify categorical features, and index them.
    val featureIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(4) // features with > 4 distinct values are treated as continuous.
      .fit(data)

    // Split the data into training and test sets (30% held out for testing).
    val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

    // Train a DecisionTree model.
    val dt = new DecisionTreeClassifier()
      .setLabelCol("indexedLabel")
      .setFeaturesCol("indexedFeatures")

    // Convert indexed labels back to original labels.
    val labelConverter = new IndexToString()
      .setInputCol("prediction")
      .setOutputCol("predictedLabel")
      .setLabels(labelIndexer.labels)

    // Chain indexers and tree in a Pipeline.
    val pipeline = new Pipeline()
      .setStages(Array(labelIndexer, featureIndexer, dt, labelConverter))

    // Train model. This also runs the indexers.
    val model = pipeline.fit(trainingData)

    // Make predictions.
    val predictions = model.transform(testData)

    // Select example rows to display.
    predictions.select("predictedLabel", "label", "features").show(5)

    // Select (prediction, true label) and compute test error.
    val evaluator = new MulticlassClassificationEvaluator()
      .setLabelCol("indexedLabel")
      .setPredictionCol("prediction")
      .setMetricName("accuracy")
    val accuracy = evaluator.evaluate(predictions)
    println(s"Test Error = ${(1.0 - accuracy)}")

    val treeModel = model.stages(2).asInstanceOf[DecisionTreeClassificationModel]
    println(s"Learned classification tree model:\n ${treeModel.toDebugString}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.Imputer
// $example off$
import org.apache.spark.sql.SparkSession

/**
 * An example demonstrating Imputer.
 * Run with:
 *   bin/run-example ml.ImputerExample
 */
object ImputerExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder
      .appName("ImputerExample")
      .getOrCreate()

    // $example on$
    val df = spark.createDataFrame(Seq(
      (1.0, Double.NaN),
      (2.0, Double.NaN),
      (Double.NaN, 3.0),
      (4.0, 4.0),
      (5.0, 5.0)
    )).toDF("a", "b")

    val imputer = new Imputer()
      .setInputCols(Array("a", "b"))
      .setOutputCols(Array("out_a", "out_b"))

    val model = imputer.fit(df)
    model.transform(df).show()
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

import java.util.Locale

import scala.collection.mutable

import scopt.OptionParser

import org.apache.spark.examples.mllib.AbstractParams
import org.apache.spark.ml.{Pipeline, PipelineStage}
import org.apache.spark.ml.classification.{RandomForestClassificationModel, RandomForestClassifier}
import org.apache.spark.ml.feature.{StringIndexer, VectorIndexer}
import org.apache.spark.ml.regression.{RandomForestRegressionModel, RandomForestRegressor}
import org.apache.spark.sql.{DataFrame, SparkSession}


/**
 * An example runner for decision trees. Run with
 * {{{
 * ./bin/run-example ml.RandomForestExample [options]
 * }}}
 * Decision Trees and ensembles can take a large amount of memory. If the run-example command
 * above fails, try running via spark-submit and specifying the amount of memory as at least 1g.
 * For local mode, run
 * {{{
 * ./bin/spark-submit --class org.apache.spark.examples.ml.RandomForestExample --driver-memory 1g
 *   [examples JAR path] [options]
 * }}}
 * If you use it as a template to create your own app, please use `spark-submit` to submit your app.
 */
object RandomForestExample {

  case class Params(
      input: String = null,
      testInput: String = "",
      dataFormat: String = "libsvm",
      algo: String = "classification",
      maxDepth: Int = 5,
      maxBins: Int = 32,
      minInstancesPerNode: Int = 1,
      minInfoGain: Double = 0.0,
      numTrees: Int = 10,
      featureSubsetStrategy: String = "auto",
      fracTest: Double = 0.2,
      cacheNodeIds: Boolean = false,
      checkpointDir: Option[String] = None,
      checkpointInterval: Int = 10) extends AbstractParams[Params]

  def main(args: Array[String]) {
    val defaultParams = Params()

    val parser = new OptionParser[Params]("RandomForestExample") {
      head("RandomForestExample: an example random forest app.")
      opt[String]("algo")
        .text(s"algorithm (classification, regression), default: ${defaultParams.algo}")
        .action((x, c) => c.copy(algo = x))
      opt[Int]("maxDepth")
        .text(s"max depth of the tree, default: ${defaultParams.maxDepth}")
        .action((x, c) => c.copy(maxDepth = x))
      opt[Int]("maxBins")
        .text(s"max number of bins, default: ${defaultParams.maxBins}")
        .action((x, c) => c.copy(maxBins = x))
      opt[Int]("minInstancesPerNode")
        .text(s"min number of instances required at child nodes to create the parent split," +
        s" default: ${defaultParams.minInstancesPerNode}")
        .action((x, c) => c.copy(minInstancesPerNode = x))
      opt[Double]("minInfoGain")
        .text(s"min info gain required to create a split, default: ${defaultParams.minInfoGain}")
        .action((x, c) => c.copy(minInfoGain = x))
      opt[Int]("numTrees")
        .text(s"number of trees in ensemble, default: ${defaultParams.numTrees}")
        .action((x, c) => c.copy(numTrees = x))
      opt[String]("featureSubsetStrategy")
        .text(s"number of features to use per node (supported:" +
        s" ${RandomForestClassifier.supportedFeatureSubsetStrategies.mkString(",")})," +
        s" default: ${defaultParams.numTrees}")
        .action((x, c) => c.copy(featureSubsetStrategy = x))
      opt[Double]("fracTest")
        .text(s"fraction of data to hold out for testing. If given option testInput, " +
        s"this option is ignored. default: ${defaultParams.fracTest}")
        .action((x, c) => c.copy(fracTest = x))
      opt[Boolean]("cacheNodeIds")
        .text(s"whether to use node Id cache during training, " +
        s"default: ${defaultParams.cacheNodeIds}")
        .action((x, c) => c.copy(cacheNodeIds = x))
      opt[String]("checkpointDir")
        .text(s"checkpoint directory where intermediate node Id caches will be stored, " +
        s"default: ${
          defaultParams.checkpointDir match {
            case Some(strVal) => strVal
            case None => "None"
          }
        }")
        .action((x, c) => c.copy(checkpointDir = Some(x)))
      opt[Int]("checkpointInterval")
        .text(s"how often to checkpoint the node Id cache, " +
        s"default: ${defaultParams.checkpointInterval}")
        .action((x, c) => c.copy(checkpointInterval = x))
      opt[String]("testInput")
        .text(s"input path to test dataset. If given, option fracTest is ignored." +
        s" default: ${defaultParams.testInput}")
        .action((x, c) => c.copy(testInput = x))
      opt[String]("dataFormat")
        .text("data format: libsvm (default), dense (deprecated in Spark v1.1)")
        .action((x, c) => c.copy(dataFormat = x))
      arg[String]("<input>")
        .text("input path to labeled examples")
        .required()
        .action((x, c) => c.copy(input = x))
      checkConfig { params =>
        if (params.fracTest < 0 || params.fracTest >= 1) {
          failure(s"fracTest ${params.fracTest} value incorrect; should be in [0,1).")
        } else {
          success
        }
      }
    }

    parser.parse(args, defaultParams) match {
      case Some(params) => run(params)
      case _ => sys.exit(1)
    }
  }

  def run(params: Params): Unit = {
    val spark = SparkSession
      .builder
      .appName(s"RandomForestExample with $params")
      .getOrCreate()

    params.checkpointDir.foreach(spark.sparkContext.setCheckpointDir)
    val algo = params.algo.toLowerCase(Locale.ROOT)

    println(s"RandomForestExample with parameters:\n$params")

    // Load training and test data and cache it.
    val (training: DataFrame, test: DataFrame) = DecisionTreeExample.loadDatasets(params.input,
      params.dataFormat, params.testInput, algo, params.fracTest)

    // Set up Pipeline.
    val stages = new mutable.ArrayBuffer[PipelineStage]()
    // (1) For classification, re-index classes.
    val labelColName = if (algo == "classification") "indexedLabel" else "label"
    if (algo == "classification") {
      val labelIndexer = new StringIndexer()
        .setInputCol("label")
        .setOutputCol(labelColName)
      stages += labelIndexer
    }
    // (2) Identify categorical features using VectorIndexer.
    //     Features with more than maxCategories values will be treated as continuous.
    val featuresIndexer = new VectorIndexer()
      .setInputCol("features")
      .setOutputCol("indexedFeatures")
      .setMaxCategories(10)
    stages += featuresIndexer
    // (3) Learn Random Forest.
    val dt = algo match {
      case "classification" =>
        new RandomForestClassifier()
          .setFeaturesCol("indexedFeatures")
          .setLabelCol(labelColName)
          .setMaxDepth(params.maxDepth)
          .setMaxBins(params.maxBins)
          .setMinInstancesPerNode(params.minInstancesPerNode)
          .setMinInfoGain(params.minInfoGain)
          .setCacheNodeIds(params.cacheNodeIds)
          .setCheckpointInterval(params.checkpointInterval)
          .setFeatureSubsetStrategy(params.featureSubsetStrategy)
          .setNumTrees(params.numTrees)
      case "regression" =>
        new RandomForestRegressor()
          .setFeaturesCol("indexedFeatures")
          .setLabelCol(labelColName)
          .setMaxDepth(params.maxDepth)
          .setMaxBins(params.maxBins)
          .setMinInstancesPerNode(params.minInstancesPerNode)
          .setMinInfoGain(params.minInfoGain)
          .setCacheNodeIds(params.cacheNodeIds)
          .setCheckpointInterval(params.checkpointInterval)
          .setFeatureSubsetStrategy(params.featureSubsetStrategy)
          .setNumTrees(params.numTrees)
      case _ => throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }
    stages += dt
    val pipeline = new Pipeline().setStages(stages.toArray)

    // Fit the Pipeline.
    val startTime = System.nanoTime()
    val pipelineModel = pipeline.fit(training)
    val elapsedTime = (System.nanoTime() - startTime) / 1e9
    println(s"Training time: $elapsedTime seconds")

    // Get the trained Random Forest from the fitted PipelineModel.
    algo match {
      case "classification" =>
        val rfModel = pipelineModel.stages.last.asInstanceOf[RandomForestClassificationModel]
        if (rfModel.totalNumNodes < 30) {
          println(rfModel.toDebugString) // Print full model.
        } else {
          println(rfModel) // Print model summary.
        }
      case "regression" =>
        val rfModel = pipelineModel.stages.last.asInstanceOf[RandomForestRegressionModel]
        if (rfModel.totalNumNodes < 30) {
          println(rfModel.toDebugString) // Print full model.
        } else {
          println(rfModel) // Print model summary.
        }
      case _ => throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }

    // Evaluate model on training, test data.
    algo match {
      case "classification" =>
        println("Training data results:")
        DecisionTreeExample.evaluateClassificationModel(pipelineModel, training, labelColName)
        println("Test data results:")
        DecisionTreeExample.evaluateClassificationModel(pipelineModel, test, labelColName)
      case "regression" =>
        println("Training data results:")
        DecisionTreeExample.evaluateRegressionModel(pipelineModel, training, labelColName)
        println("Test data results:")
        DecisionTreeExample.evaluateRegressionModel(pipelineModel, test, labelColName)
      case _ =>
        throw new IllegalArgumentException(s"Algo ${params.algo} not supported.")
    }

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.feature.QuantileDiscretizer
// $example off$
import org.apache.spark.sql.SparkSession

object QuantileDiscretizerExample {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("QuantileDiscretizerExample")
      .getOrCreate()

    // $example on$
    val data = Array((0, 18.0), (1, 19.0), (2, 8.0), (3, 5.0), (4, 2.2))
    val df = spark.createDataFrame(data).toDF("id", "hour")
    // $example off$
    // Output of QuantileDiscretizer for such small datasets can depend on the number of
    // partitions. Here we force a single partition to ensure consistent results.
    // Note this is not necessary for normal use cases
      .repartition(1)

    // $example on$
    val discretizer = new QuantileDiscretizer()
      .setInputCol("hour")
      .setOutputCol("result")
      .setNumBuckets(3)

    val result = discretizer.fit(df).transform(df)
    result.show(false)
    // $example off$

    spark.stop()
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.clustering.PowerIterationClustering
// $example off$
import org.apache.spark.sql.SparkSession

object PowerIterationClusteringExample {
   def main(args: Array[String]): Unit = {
     val spark = SparkSession
       .builder
       .appName(s"${this.getClass.getSimpleName}")
       .getOrCreate()

     // $example on$
     val dataset = spark.createDataFrame(Seq(
       (0L, 1L, 1.0),
       (0L, 2L, 1.0),
       (1L, 2L, 1.0),
       (3L, 4L, 1.0),
       (4L, 0L, 0.1)
     )).toDF("src", "dst", "weight")

     val model = new PowerIterationClustering().
       setK(2).
       setMaxIter(20).
       setInitMode("degree").
       setWeightCol("weight")

     val prediction = model.assignClusters(dataset).select("id", "cluster")

     //  Shows the cluster assignment
     prediction.show(false)
     // $example off$

     spark.stop()
   }
 }
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples.ml

// $example on$
import org.apache.spark.ml.regression.LinearRegression
// $example off$
import org.apache.spark.sql.SparkSession

object LinearRegressionWithElasticNetExample {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("LinearRegressionWithElasticNetExample")
      .getOrCreate()

    // $example on$
    // Load training data
    val training = spark.read.format("libsvm")
      .load("data/mllib/sample_linear_regression_data.txt")

    val lr = new LinearRegression()
      .setMaxIter(10)
      .setRegParam(0.3)
      .setElasticNetParam(0.8)

    // Fit the model
    val lrModel = lr.fit(training)

    // Print the coefficients and intercept for linear regression
    println(s"Coefficients: ${lrModel.coefficients} Intercept: ${lrModel.intercept}")

    // Summarize the model over the training set and print out some metrics
    val trainingSummary = lrModel.summary
    println(s"numIterations: ${trainingSummary.totalIterations}")
    println(s"objectiveHistory: [${trainingSummary.objectiveHistory.mkString(",")}]")
    trainingSummary.residuals.show()
    println(s"RMSE: ${trainingSummary.rootMeanSquaredError}")
    println(s"r2: ${trainingSummary.r2}")
    // $example off$

    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import breeze.linalg.{squaredDistance, DenseVector, Vector}

import org.apache.spark.sql.SparkSession

/**
 * K-means clustering.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.clustering.KMeans.
 */
object SparkKMeans {

  def parseVector(line: String): Vector[Double] = {
    DenseVector(line.split(' ').map(_.toDouble))
  }

  def closestPoint(p: Vector[Double], centers: Array[Vector[Double]]): Int = {
    var bestIndex = 0
    var closest = Double.PositiveInfinity

    for (i <- 0 until centers.length) {
      val tempDist = squaredDistance(p, centers(i))
      if (tempDist < closest) {
        closest = tempDist
        bestIndex = i
      }
    }

    bestIndex
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of KMeans Clustering and is given as an example!
        |Please use org.apache.spark.ml.clustering.KMeans
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    if (args.length < 3) {
      System.err.println("Usage: SparkKMeans <file> <k> <convergeDist>")
      System.exit(1)
    }

    showWarning()

    val spark = SparkSession
      .builder
      .appName("SparkKMeans")
      .getOrCreate()

    val lines = spark.read.textFile(args(0)).rdd
    val data = lines.map(parseVector _).cache()
    val K = args(1).toInt
    val convergeDist = args(2).toDouble

    val kPoints = data.takeSample(withReplacement = false, K, 42)
    var tempDist = 1.0

    while(tempDist > convergeDist) {
      val closest = data.map (p => (closestPoint(p, kPoints), (p, 1)))

      val pointStats = closest.reduceByKey{case ((p1, c1), (p2, c2)) => (p1 + p2, c1 + c2)}

      val newPoints = pointStats.map {pair =>
        (pair._1, pair._2._1 * (1.0 / pair._2._2))}.collectAsMap()

      tempDist = 0.0
      for (i <- 0 until K) {
        tempDist += squaredDistance(kPoints(i), newPoints(i))
      }

      for (newP <- newPoints) {
        kPoints(newP._1) = newP._2
      }
      println(s"Finished iteration (delta = $tempDist)")
    }

    println("Final centers:")
    kPoints.foreach(println)
    spark.stop()
  }
}
// scalastyle:on println
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println
package org.apache.spark.examples

import scala.collection.mutable
import scala.util.Random

import org.apache.spark.sql.SparkSession

/**
 * Transitive closure on a graph.
 */
object SparkTC {
  val numEdges = 200
  val numVertices = 100
  val rand = new Random(42)

  def generateGraph: Seq[(Int, Int)] = {
    val edges: mutable.Set[(Int, Int)] = mutable.Set.empty
    while (edges.size < numEdges) {
      val from = rand.nextInt(numVertices)
      val to = rand.nextInt(numVertices)
      if (from != to) edges.+=((from, to))
    }
    edges.toSeq
  }

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("SparkTC")
      .getOrCreate()
    val slices = if (args.length > 0) args(0).toInt else 2
    var tc = spark.sparkContext.parallelize(generateGraph, slices).cache()

    // Linear transitive closure: each round grows paths by one edge,
    // by joining the graph's edges with the already-discovered paths.
    // e.g. join the path (y, z) from the TC with the edge (x, y) from
    // the graph to obtain the path (x, z).

    // Because join() joins on keys, the edges are stored in reversed order.
    val edges = tc.map(x => (x._2, x._1))

    // This join is iterated until a fixed point is reached.
    var oldCount = 0L
    var nextCount = tc.count()
    do {
      oldCount = nextCount
      // Perform the join, obtaining an RDD of (y, (z, x)) pairs,
      // then project the result to obtain the new (x, z) paths.
      tc = tc.union(tc.join(edges).map(x => (x._2._2, x._2._1))).distinct().cache()
      nextCount = tc.count()
    } while (nextCount != oldCount)

    println(s"TC has ${tc.count()} edges.")
    spark.stop()
  }
}
// scalastyle:on println
