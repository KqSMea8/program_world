/*
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

package org.apache.flink.streaming.scala.examples.async


import java.util.concurrent.TimeUnit

import org.apache.flink.streaming.api.functions.source.ParallelSourceFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction.SourceContext
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.api.scala.async.ResultFuture

import scala.concurrent.{ExecutionContext, Future}

object AsyncIOExample {

  def main(args: Array[String]) {
    val timeout = 10000L

    val env = StreamExecutionEnvironment.getExecutionEnvironment

    val input = env.addSource(new SimpleSource())

    val asyncMapped = AsyncDataStream.orderedWait(input, timeout, TimeUnit.MILLISECONDS, 10) {
      (input, collector: ResultFuture[Int]) =>
        Future {
          collector.complete(Seq(input))
        } (ExecutionContext.global)
    }

    asyncMapped.print()

    env.execute("Async I/O job")
  }
}

class SimpleSource extends ParallelSourceFunction[Int] {
  var running = true
  var counter = 0

  override def run(ctx: SourceContext[Int]): Unit = {
    while (running) {
      ctx.getCheckpointLock.synchronized {
        ctx.collect(counter)
      }
      counter += 1

      Thread.sleep(10L)
    }
  }

  override def cancel(): Unit = {
    running = false
  }
}
/*
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

package org.apache.flink.streaming.scala.examples.socket

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.api.windowing.time.Time

/**
 * Implements a streaming windowed version of the "WordCount" program.
 * 
 * This program connects to a server socket and reads strings from the socket.
 * The easiest way to try this out is to open a text sever (at port 12345) 
 * using the ''netcat'' tool via
 * {{{
 * nc -l 12345
 * }}}
 * and run this example with the hostname and the port as arguments..
 */
object SocketWindowWordCount {

  /** Main program method */
  def main(args: Array[String]) : Unit = {

    // the host and the port to connect to
    var hostname: String = "localhost"
    var port: Int = 0

    try {
      val params = ParameterTool.fromArgs(args)
      hostname = if (params.has("hostname")) params.get("hostname") else "localhost"
      port = params.getInt("port")
    } catch {
      case e: Exception => {
        System.err.println("No port specified. Please run 'SocketWindowWordCount " +
          "--hostname <hostname> --port <port>', where hostname (localhost by default) and port " +
          "is the address of the text server")
        System.err.println("To start a simple text server, run 'netcat -l <port>' " +
          "and type the input text into the command line")
        return
      }
    }
    
    // get the execution environment
    val env: StreamExecutionEnvironment = StreamExecutionEnvironment.getExecutionEnvironment
    
    // get input data by connecting to the socket
    val text: DataStream[String] = env.socketTextStream(hostname, port, '\n')

    // parse the data, group it, window it, and aggregate the counts 
    val windowCounts = text
          .flatMap { w => w.split("\\s") }
          .map { w => WordWithCount(w, 1) }
          .keyBy("word")
          .timeWindow(Time.seconds(5))
          .sum("count")

    // print the results with a single thread, rather than in parallel
    windowCounts.print().setParallelism(1)

    env.execute("Socket Window WordCount")
  }

  /** Data type for words with count */
  case class WordWithCount(word: String, count: Long)
}
/*
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

package org.apache.flink.streaming.scala.examples.join

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.streaming.api.TimeCharacteristic
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows
import org.apache.flink.streaming.api.windowing.time.Time

/**
 * Example illustrating a windowed stream join between two data streams.
 *
 * The example works on two input streams with pairs (name, grade) and (name, salary)
 * respectively. It joins the steams based on "name" within a configurable window.
 *
 * The example uses a built-in sample data generator that generates
 * the steams of pairs at a configurable rate.
 */
object WindowJoin {

  // *************************************************************************
  //  Program Data Types
  // *************************************************************************

  case class Grade(name: String, grade: Int)
  
  case class Salary(name: String, salary: Int)
  
  case class Person(name: String, grade: Int, salary: Int)

  // *************************************************************************
  //  Program
  // *************************************************************************

  def main(args: Array[String]) {
    // parse the parameters
    val params = ParameterTool.fromArgs(args)
    val windowSize = params.getLong("windowSize", 2000)
    val rate = params.getLong("rate", 3)

    println("Using windowSize=" + windowSize + ", data rate=" + rate)
    println("To customize example, use: WindowJoin " +
      "[--windowSize <window-size-in-millis>] [--rate <elements-per-second>]")

    // obtain execution environment, run this example in "ingestion time"
    val env = StreamExecutionEnvironment.getExecutionEnvironment
    env.setStreamTimeCharacteristic(TimeCharacteristic.IngestionTime)

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // // create the data sources for both grades and salaries
    val grades = WindowJoinSampleData.getGradeSource(env, rate)
    val salaries = WindowJoinSampleData.getSalarySource(env, rate)

    // join the two input streams by name on a window.
    // for testability, this functionality is in a separate method.
    val joined = joinStreams(grades, salaries, windowSize)

    // print the results with a single thread, rather than in parallel
    joined.print().setParallelism(1)

    // execute program
    env.execute("Windowed Join Example")
  }


  def joinStreams(
      grades: DataStream[Grade],
      salaries: DataStream[Salary],
      windowSize: Long) : DataStream[Person] = {

    grades.join(salaries)
      .where(_.name)
      .equalTo(_.name)
      .window(TumblingEventTimeWindows.of(Time.milliseconds(windowSize)))
      .apply { (g, s) => Person(g.name, g.grade, s.salary) }
  }
}
/*
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

package org.apache.flink.streaming.scala.examples.join

import java.io.Serializable
import java.util.Random

import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.examples.utils.ThrottledIterator
import org.apache.flink.streaming.scala.examples.join.WindowJoin.{Grade, Salary}

import scala.collection.JavaConverters._

/**
 * Sample data for the [[WindowJoin]] example.
 */
object WindowJoinSampleData {
  
  private[join] val NAMES = Array("tom", "jerry", "alice", "bob", "john", "grace")
  private[join] val GRADE_COUNT = 5
  private[join] val SALARY_MAX = 10000

  /**
   * Continuously generates (name, grade).
   */
  def getGradeSource(env: StreamExecutionEnvironment, rate: Long): DataStream[Grade] = {
      env.fromCollection(new ThrottledIterator(new GradeSource().asJava, rate).asScala)
  }

  /**
   * Continuously generates (name, salary).
   */
  def getSalarySource(env: StreamExecutionEnvironment, rate: Long): DataStream[Salary] = {
    env.fromCollection(new ThrottledIterator(new SalarySource().asJava, rate).asScala)
  }
  
  // --------------------------------------------------------------------------
  
  class GradeSource extends Iterator[Grade] with Serializable {
    
    private[this] val rnd = new Random(hashCode())

    def hasNext: Boolean = true

    def next: Grade = {
      Grade(NAMES(rnd.nextInt(NAMES.length)), rnd.nextInt(GRADE_COUNT) + 1)
    }
  }
  
  class SalarySource extends Iterator[Salary] with Serializable {

    private[this] val rnd = new Random(hashCode())

    def hasNext: Boolean = true

    def next: Salary = {
      Salary(NAMES(rnd.nextInt(NAMES.length)), rnd.nextInt(SALARY_MAX) + 1)
    }
  }
}
/*
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

package org.apache.flink.streaming.scala.examples.windowing


import java.beans.Transient
import java.util.concurrent.TimeUnit

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.streaming.api.TimeCharacteristic
import org.apache.flink.streaming.api.functions.source.SourceFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction.SourceContext
import org.apache.flink.streaming.api.functions.windowing.delta.DeltaFunction
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.api.windowing.assigners.GlobalWindows
import org.apache.flink.streaming.api.windowing.evictors.TimeEvictor
import org.apache.flink.streaming.api.windowing.time.Time
import org.apache.flink.streaming.api.windowing.triggers.DeltaTrigger

import scala.language.postfixOps
import scala.util.Random

/**
 * An example of grouped stream windowing where different eviction and 
 * trigger policies can be used. A source fetches events from cars 
 * every 100 msec containing their id, their current speed (kmh),
 * overall elapsed distance (m) and a timestamp. The streaming
 * example triggers the top speed of each car every x meters elapsed 
 * for the last y seconds.
 */
object TopSpeedWindowing {

  // *************************************************************************
  // PROGRAM
  // *************************************************************************

  case class CarEvent(carId: Int, speed: Int, distance: Double, time: Long)

  val numOfCars = 2
  val evictionSec = 10
  val triggerMeters = 50d

  def main(args: Array[String]) {

    val params = ParameterTool.fromArgs(args)

    val env = StreamExecutionEnvironment.getExecutionEnvironment
    env.getConfig.setGlobalJobParameters(params)
    env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime)
    env.setParallelism(1)

    val cars =
      if (params.has("input")) {
        env.readTextFile(params.get("input"))
          .map(parseMap(_))
          .map(x => CarEvent(x._1, x._2, x._3, x._4))
      } else {
        println("Executing TopSpeedWindowing example with default inputs data set.")
        println("Use --input to specify file input.")
        env.addSource(new SourceFunction[CarEvent]() {

          val speeds = Array.fill[Integer](numOfCars)(50)
          val distances = Array.fill[Double](numOfCars)(0d)
          @Transient lazy val rand = new Random()

          var isRunning:Boolean = true

          override def run(ctx: SourceContext[CarEvent]) = {
            while (isRunning) {
              Thread.sleep(100)

              for (carId <- 0 until numOfCars) {
                if (rand.nextBoolean) speeds(carId) = Math.min(100, speeds(carId) + 5)
                else speeds(carId) = Math.max(0, speeds(carId) - 5)

                distances(carId) += speeds(carId) / 3.6d
                val record = CarEvent(carId, speeds(carId),
                  distances(carId), System.currentTimeMillis)
                ctx.collect(record)
              }
            }
          }

          override def cancel(): Unit = isRunning = false
        })
      }

    val topSpeeds = cars
      .assignAscendingTimestamps( _.time )
      .keyBy("carId")
      .window(GlobalWindows.create)
      .evictor(TimeEvictor.of(Time.of(evictionSec * 1000, TimeUnit.MILLISECONDS)))
      .trigger(DeltaTrigger.of(triggerMeters, new DeltaFunction[CarEvent] {
        def getDelta(oldSp: CarEvent, newSp: CarEvent): Double = newSp.distance - oldSp.distance
      }, cars.getType().createSerializer(env.getConfig)))
//      .window(Time.of(evictionSec * 1000, (car : CarEvent) => car.time))
//      .every(Delta.of[CarEvent](triggerMeters,
//          (oldSp,newSp) => newSp.distance-oldSp.distance, CarEvent(0,0,0,0)))
      .maxBy("speed")

    if (params.has("output")) {
      topSpeeds.writeAsText(params.get("output"))
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      topSpeeds.print()
    }

    env.execute("TopSpeedWindowing")

  }

  // *************************************************************************
  // USER FUNCTIONS
  // *************************************************************************

  def parseMap(line : String): (Int, Int, Double, Long) = {
    val record = line.substring(1, line.length - 1).split(",")
    (record(0).toInt, record(1).toInt, record(2).toDouble, record(3).toLong)
  }
}
/*
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

package org.apache.flink.streaming.scala.examples.windowing

import java.util.concurrent.TimeUnit.MILLISECONDS

import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.functions.sink.SinkFunction
import org.apache.flink.streaming.api.functions.source.RichParallelSourceFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction.SourceContext
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.streaming.api.windowing.time.Time

/**
 * An example of grouped stream windowing into sliding time windows.
 * This example uses [[RichParallelSourceFunction]] to generate a list of key-value pair.
 */
object GroupedProcessingTimeWindowExample {

  def main(args: Array[String]): Unit = {

    val env = StreamExecutionEnvironment.getExecutionEnvironment
    env.setParallelism(4)

    val stream: DataStream[(Long, Long)] = env.addSource(new DataSource)

    stream
      .keyBy(0)
      .timeWindow(Time.of(2500, MILLISECONDS), Time.of(500, MILLISECONDS))
      .reduce((value1, value2) => (value1._1, value1._2 + value2._2))
      .addSink(new SinkFunction[(Long, Long)]() {
        override def invoke(in: (Long, Long)): Unit = {}
      })

    env.execute()
  }

  /**
   * Parallel data source that serves a list of key-value pair.
   */
  private class DataSource extends RichParallelSourceFunction[(Long, Long)] {
    @volatile private var running = true

    override def run(ctx: SourceContext[(Long, Long)]): Unit = {
      val startTime = System.currentTimeMillis()

      val numElements = 20000000
      val numKeys = 10000
      var value = 1L
      var count = 0L

      while (running && count < numElements) {

        ctx.collect((value, 1L))

        count += 1
        value += 1

        if (value > numKeys) {
          value = 1L
        }
      }

      val endTime = System.currentTimeMillis()
      println(s"Took ${endTime - startTime} msecs for ${numElements} values")
    }

    override def cancel(): Unit = running = false
  }
}
/*
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

package org.apache.flink.streaming.scala.examples.windowing

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.streaming.examples.wordcount.util.WordCountData

/**
 * Implements a windowed version of the streaming "WordCount" program.
 *
 * The input is a plain text file with lines separated by newline characters.
 *
 * Usage:
 * {{{
 * WordCount
 * --input <path>
 * --output <path>
 * --window <n>
 * --slide <n>
 * }}}
 *
 * If no parameters are provided, the program is run with default data from
 * [[WordCountData]].
 *
 * This example shows how to:
 *
 *  - write a simple Flink Streaming program,
 *  - use tuple data types,
 *  - use basic windowing abstractions.
 *
 */
object WindowWordCount {

  def main(args: Array[String]): Unit = {

    val params = ParameterTool.fromArgs(args)

    // set up the execution environment
    val env = StreamExecutionEnvironment.getExecutionEnvironment

    // get input data
    val text =
    if (params.has("input")) {
      // read the text file from given input path
      env.readTextFile(params.get("input"))
    } else {
      println("Executing WindowWordCount example with default input data set.")
      println("Use --input to specify file input.")
      // get default test text data
      env.fromElements(WordCountData.WORDS: _*)
    }

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    val windowSize = params.getInt("window", 250)
    val slideSize = params.getInt("slide", 150)

    val counts: DataStream[(String, Int)] = text
      // split up the lines in pairs (2-tuple) containing: (word,1)
      .flatMap(_.toLowerCase.split("\\W+"))
      .filter(_.nonEmpty)
      .map((_, 1))
      .keyBy(0)
      // create windows of windowSize records slided every slideSize records
      .countWindow(windowSize, slideSize)
      // group by the tuple field "0" and sum up tuple field "1"
      .sum(1)

    // emit result
    if (params.has("output")) {
      counts.writeAsText(params.get("output"))
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      counts.print()
    }

    // execute program
    env.execute("WindowWordCount")
  }

}
/*
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

package org.apache.flink.streaming.scala.examples.windowing

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.TimeCharacteristic
import org.apache.flink.streaming.api.functions.source.SourceFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction.SourceContext
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.streaming.api.watermark.Watermark
import org.apache.flink.streaming.api.windowing.assigners.EventTimeSessionWindows
import org.apache.flink.streaming.api.windowing.time.Time

/**
 * An example of grouped stream windowing in session windows with session timeout of 3 msec.
 * A source fetches elements with key, timestamp, and count.
 */
object SessionWindowing {

  def main(args: Array[String]): Unit = {

    val params = ParameterTool.fromArgs(args)
    val env = StreamExecutionEnvironment.getExecutionEnvironment

    env.getConfig.setGlobalJobParameters(params)
    env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime)
    env.setParallelism(1)

    val fileOutput = params.has("output")

    val input = List(
      ("a", 1L, 1),
      ("b", 1L, 1),
      ("b", 3L, 1),
      ("b", 5L, 1),
      ("c", 6L, 1),
      // We expect to detect the session "a" earlier than this point (the old
      // functionality can only detect here when the next starts)
      ("a", 10L, 1),
      // We expect to detect session "b" and "c" at this point as well
      ("c", 11L, 1)
    )

    val source: DataStream[(String, Long, Int)] = env.addSource(
      new SourceFunction[(String, Long, Int)]() {

        override def run(ctx: SourceContext[(String, Long, Int)]): Unit = {
          input.foreach(value => {
            ctx.collectWithTimestamp(value, value._2)
            ctx.emitWatermark(new Watermark(value._2 - 1))
          })
          ctx.emitWatermark(new Watermark(Long.MaxValue))
        }

        override def cancel(): Unit = {}

      })

    // We create sessions for each id with max timeout of 3 time units
    val aggregated: DataStream[(String, Long, Int)] = source
      .keyBy(0)
      .window(EventTimeSessionWindows.withGap(Time.milliseconds(3L)))
      .sum(2)

    if (fileOutput) {
      aggregated.writeAsText(params.get("output"))
    } else {
      print("Printing result to stdout. Use --output to specify output path.")
      aggregated.print()
    }

    env.execute()
  }

}
/*
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

package org.apache.flink.streaming.scala.examples.wordcount

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.examples.wordcount.util.WordCountData

/**
 * Implements the "WordCount" program that computes a simple word occurrence
 * histogram over text files in a streaming fashion.
 *
 * The input is a plain text file with lines separated by newline characters.
 *
 * Usage:
 * {{{
 * WordCount --input <path> --output <path>
 * }}}
 *
 * If no parameters are provided, the program is run with default data from
 * {@link WordCountData}.
 *
 * This example shows how to:
 *
 *  - write a simple Flink Streaming program,
 *  - use tuple data types,
 *  - write and use transformation functions.
 *
 */
object WordCount {

  def main(args: Array[String]) {

    // Checking input parameters
    val params = ParameterTool.fromArgs(args)

    // set up the execution environment
    val env = StreamExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // get input data
    val text =
    // read the text file from given input path
    if (params.has("input")) {
      env.readTextFile(params.get("input"))
    } else {
      println("Executing WordCount example with default inputs data set.")
      println("Use --input to specify file input.")
      // get default test text data
      env.fromElements(WordCountData.WORDS: _*)
    }

    val counts: DataStream[(String, Int)] = text
      // split up the lines in pairs (2-tuples) containing: (word,1)
      .flatMap(_.toLowerCase.split("\\W+"))
      .filter(_.nonEmpty)
      .map((_, 1))
      // group by the tuple field "0" and sum up tuple field "1"
      .keyBy(0)
      .sum(1)

    // emit result
    if (params.has("output")) {
      counts.writeAsText(params.get("output"))
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      counts.print()
    }

    // execute program
    env.execute("Streaming WordCount")
  }
}
/*
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

package org.apache.flink.streaming.scala.examples.iteration

import java.util.Random

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.functions.source.SourceFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction.SourceContext
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}

/**
 * Example illustrating iterations in Flink streaming.
 *
 * The program sums up random numbers and counts additions
 * it performs to reach a specific threshold in an iterative streaming fashion.
 *
 * This example shows how to use:
 *
 *  - streaming iterations,
 *  - buffer timeout to enhance latency,
 *  - directed outputs.
 *
 */
object IterateExample {

  private final val Bound = 100

  def main(args: Array[String]): Unit = {
    // Checking input parameters
    val params = ParameterTool.fromArgs(args)

    // obtain execution environment and set setBufferTimeout to 1 to enable
    // continuous flushing of the output buffers (lowest latency)
    val env = StreamExecutionEnvironment.getExecutionEnvironment.setBufferTimeout(1)

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // create input stream of integer pairs
    val inputStream: DataStream[(Int, Int)] =
    if (params.has("input")) {
      // map a list of strings to integer pairs
      env.readTextFile(params.get("input")).map { value: String =>
        val record = value.substring(1, value.length - 1)
        val splitted = record.split(",")
        (Integer.parseInt(splitted(0)), Integer.parseInt(splitted(1)))
      }
    } else {
      println("Executing Iterate example with default input data set.")
      println("Use --input to specify file input.")
      env.addSource(new RandomFibonacciSource)
    }

    def withinBound(value: (Int, Int)) = value._1 < Bound && value._2 < Bound

    // create an iterative data stream from the input with 5 second timeout
    val numbers: DataStream[((Int, Int), Int)] = inputStream
      // Map the inputs so that the next Fibonacci numbers can be calculated
      // while preserving the original input tuple
      // A counter is attached to the tuple and incremented in every iteration step
      .map(value => (value._1, value._2, value._1, value._2, 0))
      .iterate(
        (iteration: DataStream[(Int, Int, Int, Int, Int)]) => {
          // calculates the next Fibonacci number and increment the counter
          val step = iteration.map(value =>
            (value._1, value._2, value._4, value._3 + value._4, value._5 + 1))
          // testing which tuple needs to be iterated again
          val feedback = step.filter(value => withinBound(value._3, value._4))
          // giving back the input pair and the counter
          val output: DataStream[((Int, Int), Int)] = step
            .filter(value => !withinBound(value._3, value._4))
            .map(value => ((value._1, value._2), value._5))
          (feedback, output)
        }
        // timeout after 5 seconds
        , 5000L
      )

    if (params.has("output")) {
      numbers.writeAsText(params.get("output"))
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      numbers.print()
    }

    env.execute("Streaming Iteration Example")
  }

  // *************************************************************************
  // USER FUNCTIONS
  // *************************************************************************

  /**
   * Generate BOUND number of random integer pairs from the range from 0 to BOUND/2
   */
  private class RandomFibonacciSource extends SourceFunction[(Int, Int)] {

    val rnd = new Random()
    var counter = 0
    @volatile var isRunning = true

    override def run(ctx: SourceContext[(Int, Int)]): Unit = {

      while (isRunning && counter < Bound) {
        val first = rnd.nextInt(Bound / 2 - 1) + 1
        val second = rnd.nextInt(Bound / 2 - 1) + 1

        ctx.collect((first, second))
        counter += 1
        Thread.sleep(50L)
      }
    }

    override def cancel(): Unit = isRunning = false
  }

}
/*
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

package org.apache.flink.streaming.scala.examples.ml

import java.util.concurrent.TimeUnit

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.TimeCharacteristic
import org.apache.flink.streaming.api.functions.AssignerWithPunctuatedWatermarks
import org.apache.flink.streaming.api.functions.co.CoMapFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction
import org.apache.flink.streaming.api.functions.source.SourceFunction.SourceContext
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.streaming.api.scala.function.AllWindowFunction
import org.apache.flink.streaming.api.watermark.Watermark
import org.apache.flink.streaming.api.windowing.time.Time
import org.apache.flink.streaming.api.windowing.windows.TimeWindow
import org.apache.flink.util.Collector

/**
 * Skeleton for incremental machine learning algorithm consisting of a
 * pre-computed model, which gets updated for the new inputs and new input data
 * for which the job provides predictions.
 *
 * This may serve as a base of a number of algorithms, e.g. updating an
 * incremental Alternating Least Squares model while also providing the
 * predictions.
 *
 * This example shows how to use:
 *
 *  - Connected streams
 *  - CoFunctions
 *  - Tuple data types
 *
 */
object IncrementalLearningSkeleton {

  // *************************************************************************
  // PROGRAM
  // *************************************************************************

  def main(args: Array[String]): Unit = {
    // Checking input parameters
    val params = ParameterTool.fromArgs(args)

    // set up the execution environment
    val env = StreamExecutionEnvironment.getExecutionEnvironment
    env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime)

    // build new model on every second of new data
    val trainingData: DataStream[Int] = env.addSource(new FiniteTrainingDataSource)
    val newData: DataStream[Int] = env.addSource(new FiniteNewDataSource)

    val model: DataStream[Array[Double]] = trainingData
      .assignTimestampsAndWatermarks(new LinearTimestamp)
      .timeWindowAll(Time.of(5000, TimeUnit.MILLISECONDS))
      .apply(new PartialModelBuilder)

    // use partial model for newData
    val prediction: DataStream[Int] = newData.connect(model).map(new Predictor)

    // emit result
    if (params.has("output")) {
      prediction.writeAsText(params.get("output"))
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      prediction.print()
    }

    // execute program
    env.execute("Streaming Incremental Learning")
  }

  // *************************************************************************
  // USER FUNCTIONS
  // *************************************************************************

  /**
   * Feeds new data for newData. By default it is implemented as constantly
   * emitting the Integer 1 in a loop.
   */
  private class FiniteNewDataSource extends SourceFunction[Int] {
    override def run(ctx: SourceContext[Int]) = {
      Thread.sleep(15)
      (0 until 50).foreach{ _ =>
        Thread.sleep(5)
        ctx.collect(1)
      }
    }

    override def cancel() = {
      // No cleanup needed
    }
  }

  /**
   * Feeds new training data for the partial model builder. By default it is
   * implemented as constantly emitting the Integer 1 in a loop.
   */
  private class FiniteTrainingDataSource extends SourceFunction[Int] {
    override def run(ctx: SourceContext[Int]) = (0 until 8200).foreach( _ => ctx.collect(1) )

    override def cancel() = {
      // No cleanup needed
    }
  }

  private class LinearTimestamp extends AssignerWithPunctuatedWatermarks[Int] {
    var counter = 0L

    override def extractTimestamp(element: Int, previousElementTimestamp: Long): Long = {
      counter += 10L
      counter
    }

    override def checkAndGetNextWatermark(lastElement: Int, extractedTimestamp: Long) = {
      new Watermark(counter - 1)
    }
  }

  /**
   * Builds up-to-date partial models on new training data.
   */
  private class PartialModelBuilder extends AllWindowFunction[Int, Array[Double], TimeWindow] {

    protected def buildPartialModel(values: Iterable[Int]): Array[Double] = Array[Double](1)

    override def apply(window: TimeWindow,
                       values: Iterable[Int],
                       out: Collector[Array[Double]]): Unit = {
      out.collect(buildPartialModel(values))
    }
  }

  /**
   * Creates newData using the model produced in batch-processing and the
   * up-to-date partial model.
   *
   * By default emits the Integer 0 for every newData and the Integer 1
   * for every model update.
   *
   */
  private class Predictor extends CoMapFunction[Int, Array[Double], Int] {

    var batchModel: Array[Double] = null
    var partialModel: Array[Double] = null

    override def map1(value: Int): Int = {
      // Return newData
      predict(value)
    }

    override def map2(value: Array[Double]): Int = {
      // Update model
      partialModel = value
      batchModel = getBatchModel()
      1
    }

    // pulls model built with batch-job on the old training data
    protected def getBatchModel(): Array[Double] = Array[Double](0)

    // performs newData using the two models
    protected def predict(inTuple: Int): Int = 0
  }

}
/*
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

package org.apache.flink.streaming.scala.examples.twitter

import java.util.StringTokenizer

import org.apache.flink.api.common.functions.FlatMapFunction
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.{JsonNode, ObjectMapper}
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.streaming.connectors.twitter.TwitterSource
import org.apache.flink.streaming.examples.twitter.util.TwitterExampleData
import org.apache.flink.util.Collector

import scala.collection.mutable.ListBuffer

/**
 * Implements the "TwitterStream" program that computes a most used word
 * occurrence over JSON objects in a streaming fashion.
 *
 * The input is a Tweet stream from a TwitterSource.
 *
 * Usage:
 * {{{
 * TwitterExample [--output <path>]
 * [--twitter-source.consumerKey <key>
 * --twitter-source.consumerSecret <secret>
 * --twitter-source.token <token>
 * --twitter-source.tokenSecret <tokenSecret>]
 * }}}
 *
 * If no parameters are provided, the program is run with default data from
 * {@link TwitterExampleData}.
 *
 * This example shows how to:
 *
 *  - acquire external data,
 *  - use in-line defined functions,
 *  - handle flattened stream inputs.
 *
 */
object TwitterExample {

  def main(args: Array[String]): Unit = {

    // Checking input parameters
    val params = ParameterTool.fromArgs(args)
    println("Usage: TwitterExample [--output <path>] " +
      "[--twitter-source.consumerKey <key> " +
      "--twitter-source.consumerSecret <secret> " +
      "--twitter-source.token <token> " +
      "--twitter-source.tokenSecret <tokenSecret>]")

    // set up the execution environment
    val env = StreamExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    env.setParallelism(params.getInt("parallelism", 1))

    // get input data
    val streamSource: DataStream[String] =
    if (params.has(TwitterSource.CONSUMER_KEY) &&
      params.has(TwitterSource.CONSUMER_SECRET) &&
      params.has(TwitterSource.TOKEN) &&
      params.has(TwitterSource.TOKEN_SECRET)
    ) {
      env.addSource(new TwitterSource(params.getProperties))
    } else {
      print("Executing TwitterStream example with default props.")
      print("Use --twitter-source.consumerKey <key> --twitter-source.consumerSecret <secret> " +
        "--twitter-source.token <token> " +
        "--twitter-source.tokenSecret <tokenSecret> specify the authentication info."
      )
      // get default test text data
      env.fromElements(TwitterExampleData.TEXTS: _*)
    }

    val tweets: DataStream[(String, Int)] = streamSource
      // selecting English tweets and splitting to (word, 1)
      .flatMap(new SelectEnglishAndTokenizeFlatMap)
      // group by words and sum their occurrences
      .keyBy(0).sum(1)

    // emit result
    if (params.has("output")) {
      tweets.writeAsText(params.get("output"))
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      tweets.print()
    }

    // execute program
    env.execute("Twitter Streaming Example")
  }

  /**
   * Deserialize JSON from twitter source
   *
   * Implements a string tokenizer that splits sentences into words as a
   * user-defined FlatMapFunction. The function takes a line (String) and
   * splits it into multiple pairs in the form of "(word,1)" ({{{ Tuple2<String, Integer> }}}).
   */
  private class SelectEnglishAndTokenizeFlatMap extends FlatMapFunction[String, (String, Int)] {
    lazy val jsonParser = new ObjectMapper()

    override def flatMap(value: String, out: Collector[(String, Int)]): Unit = {
      // deserialize JSON from twitter source
      val jsonNode = jsonParser.readValue(value, classOf[JsonNode])
      val isEnglish = jsonNode.has("user") &&
        jsonNode.get("user").has("lang") &&
        jsonNode.get("user").get("lang").asText == "en"
      val hasText = jsonNode.has("text")

      (isEnglish, hasText, jsonNode) match {
        case (true, true, node) => {
          val tokens = new ListBuffer[(String, Int)]()
          val tokenizer = new StringTokenizer(node.get("text").asText())

          while (tokenizer.hasMoreTokens) {
            val token = tokenizer.nextToken().replaceAll("\\s*", "").toLowerCase()
            if (token.nonEmpty)out.collect((token, 1))
          }
        }
        case _ =>
      }
    }
  }
}
/*
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

package org.apache.flink.streaming.scala.examples

import java.io.File

import org.apache.commons.io.FileUtils
import org.apache.flink.core.fs.FileSystem.WriteMode
import org.apache.flink.streaming.api.TimeCharacteristic
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.examples.iteration.util.IterateExampleData
import org.apache.flink.streaming.examples.ml.util.IncrementalLearningSkeletonData
import org.apache.flink.streaming.examples.twitter.util.TwitterExampleData
import org.apache.flink.streaming.examples.windowing.util.SessionWindowingData
import org.apache.flink.streaming.scala.examples.iteration.IterateExample
import org.apache.flink.streaming.scala.examples.join.WindowJoin
import org.apache.flink.streaming.scala.examples.join.WindowJoin.{Grade, Salary}
import org.apache.flink.streaming.scala.examples.ml.IncrementalLearningSkeleton
import org.apache.flink.streaming.scala.examples.twitter.TwitterExample
import org.apache.flink.streaming.scala.examples.windowing.{SessionWindowing, WindowWordCount}
import org.apache.flink.streaming.scala.examples.wordcount.WordCount
import org.apache.flink.streaming.test.examples.join.WindowJoinData
import org.apache.flink.test.testdata.WordCountData
import org.apache.flink.test.util.{AbstractTestBase, TestBaseUtils}
import org.junit.Test

/**
 * Integration test for streaming programs in Scala examples.
 */
class StreamingExamplesITCase extends AbstractTestBase {

  @Test
  def testIterateExample(): Unit = {
    val inputPath = createTempFile("fibonacciInput.txt", IterateExampleData.INPUT_PAIRS)
    val resultPath = getTempDirPath("result")

    // the example is inherently non-deterministic. The iteration timeout of 5000 ms
    // is frequently not enough to make the test run stable on CI infrastructure
    // with very small containers, so we cannot do a validation here
    IterateExample.main(Array(
      "--input", inputPath,
      "--output", resultPath
    ))
  }

  @Test
  def testWindowJoin(): Unit = {
    val resultPath = File.createTempFile("result-path", "dir").toURI.toString
    try {
      val env = StreamExecutionEnvironment.getExecutionEnvironment
      env.setStreamTimeCharacteristic(TimeCharacteristic.IngestionTime)

      val grades = env
        .fromCollection(WindowJoinData.GRADES_INPUT.split("\n"))
        .map( line => {
          val fields = line.split(",")
          Grade(fields(1), fields(2).toInt)
        })

      val salaries = env
        .fromCollection(WindowJoinData.SALARIES_INPUT.split("\n"))
        .map( line => {
          val fields = line.split(",")
          Salary(fields(1), fields(2).toInt)
        })

      WindowJoin.joinStreams(grades, salaries, 100)
        .writeAsText(resultPath, WriteMode.OVERWRITE)

      env.execute()

      TestBaseUtils.checkLinesAgainstRegexp(resultPath, "^Person\\([a-z]+,(\\d),(\\d)+\\)")
    }
    finally try
      FileUtils.deleteDirectory(new File(resultPath))

    catch {
      case _: Throwable =>
    }
  }

  @Test
  def testIncrementalLearningSkeleton(): Unit = {
    val resultPath = getTempDirPath("result")
    IncrementalLearningSkeleton.main(Array("--output", resultPath))
    TestBaseUtils.compareResultsByLinesInMemory(IncrementalLearningSkeletonData.RESULTS, resultPath)
  }

  @Test
  def testTwitterExample(): Unit = {
    val resultPath = getTempDirPath("result")
    TwitterExample.main(Array("--output", resultPath))
    TestBaseUtils.compareResultsByLinesInMemory(
      TwitterExampleData.STREAMING_COUNTS_AS_TUPLES,
      resultPath)
  }

  @Test
  def testSessionWindowing(): Unit = {
    val resultPath = getTempDirPath("result")
    SessionWindowing.main(Array("--output", resultPath))
    TestBaseUtils.compareResultsByLinesInMemory(SessionWindowingData.EXPECTED, resultPath)
  }

  @Test
  def testWindowWordCount(): Unit = {
    val windowSize = "250"
    val slideSize = "150"
    val textPath = createTempFile("text.txt", WordCountData.TEXT)
    val resultPath = getTempDirPath("result")

    WindowWordCount.main(Array(
      "--input", textPath,
      "--output", resultPath,
      "--window", windowSize,
      "--slide", slideSize
    ))

    // since the parallel tokenizers might have different speed
    // the exact output can not be checked just whether it is well-formed
    // checks that the result lines look like e.g. (faust, 2)
    TestBaseUtils.checkLinesAgainstRegexp(resultPath, "^\\([a-z]+,(\\d)+\\)")
  }

  @Test
  def testWordCount(): Unit = {
    val textPath = createTempFile("text.txt", WordCountData.TEXT)
    val resultPath = getTempDirPath("result")

    WordCount.main(Array(
      "--input", textPath,
      "--output", resultPath
    ))

    TestBaseUtils.compareResultsByLinesInMemory(
      WordCountData.STREAMING_COUNTS_AS_TUPLES,
      resultPath)
  }
}
/*
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

package org.apache.flink.table.examples.scala

import org.apache.flink.api.scala._
import org.apache.flink.table.api.scala._

/**
  * Simple example for demonstrating the use of the Table API for a Word Count in Scala.
  *
  * This example shows how to:
  *  - Convert DataSets to Tables
  *  - Apply group, aggregate, select, and filter operations
  *
  */
object WordCountTable {

  // *************************************************************************
  //     PROGRAM
  // *************************************************************************

  def main(args: Array[String]): Unit = {

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment
    val tEnv = BatchTableEnvironment.create(env)

    val input = env.fromElements(WC("hello", 1), WC("hello", 1), WC("ciao", 1))
    val expr = input.toTable(tEnv)
    val result = expr
      .groupBy('word)
      .select('word, 'frequency.sum as 'frequency)
      .filter('frequency === 2)
      .toDataSet[WC]

    result.print()
  }

  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************

  case class WC(word: String, frequency: Long)

}
/*
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
package org.apache.flink.table.examples.scala

import org.apache.flink.api.scala._
import org.apache.flink.table.api.scala._

/**
  * Simple example that shows how the Batch SQL API is used in Scala.
  *
  * This example shows how to:
  *  - Convert DataSets to Tables
  *  - Register a Table under a name
  *  - Run a SQL query on the registered Table
  *
  */
object WordCountSQL {

  // *************************************************************************
  //     PROGRAM
  // *************************************************************************

  def main(args: Array[String]): Unit = {

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment
    val tEnv = BatchTableEnvironment.create(env)

    val input = env.fromElements(WC("hello", 1), WC("hello", 1), WC("ciao", 1))

    // register the DataSet as table "WordCount"
    tEnv.registerDataSet("WordCount", input, 'word, 'frequency)

    // run a SQL query on the Table and retrieve the result as a new Table
    val table = tEnv.sqlQuery("SELECT word, SUM(frequency) FROM WordCount GROUP BY word")

    table.toDataSet[WC].print()
  }

  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************

  case class WC(word: String, frequency: Long)

}
/*
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
package org.apache.flink.table.examples.scala

import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.table.api.scala._

/**
  * Simple example for demonstrating the use of SQL on a Stream Table in Scala.
  *
  * This example shows how to:
  *  - Convert DataStreams to Tables
  *  - Register a Table under a name
  *  - Run a StreamSQL query on the registered Table
  *
  */
object StreamSQLExample {

  // *************************************************************************
  //     PROGRAM
  // *************************************************************************

  def main(args: Array[String]): Unit = {

    // set up execution environment
    val env = StreamExecutionEnvironment.getExecutionEnvironment
    val tEnv = StreamTableEnvironment.create(env)

    val orderA: DataStream[Order] = env.fromCollection(Seq(
      Order(1L, "beer", 3),
      Order(1L, "diaper", 4),
      Order(3L, "rubber", 2)))

    val orderB: DataStream[Order] = env.fromCollection(Seq(
      Order(2L, "pen", 3),
      Order(2L, "rubber", 3),
      Order(4L, "beer", 1)))

    // convert DataStream to Table
    var tableA = tEnv.fromDataStream(orderA, 'user, 'product, 'amount)
    // register DataStream as Table
    tEnv.registerDataStream("OrderB", orderB, 'user, 'product, 'amount)

    // union the two tables
    val result = tEnv.sqlQuery(
      s"SELECT * FROM $tableA WHERE amount > 2 UNION ALL " +
        "SELECT * FROM OrderB WHERE amount < 2")

    result.toAppendStream[Order].print()

    env.execute()
  }

  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************

  case class Order(user: Long, product: String, amount: Int)

}
/*
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
package org.apache.flink.table.examples.scala

import org.apache.flink.api.scala._
import org.apache.flink.streaming.api.scala.{DataStream, StreamExecutionEnvironment}
import org.apache.flink.table.api.scala._

/**
  * Simple example for demonstrating the use of Table API on a Stream Table.
  *
  * This example shows how to:
  *  - Convert DataStreams to Tables
  *  - Apply union, select, and filter operations
  */
object StreamTableExample {

  // *************************************************************************
  //     PROGRAM
  // *************************************************************************

  def main(args: Array[String]): Unit = {

    // set up execution environment
    val env = StreamExecutionEnvironment.getExecutionEnvironment
    val tEnv = StreamTableEnvironment.create(env)

    val orderA = env.fromCollection(Seq(
      Order(1L, "beer", 3),
      Order(1L, "diaper", 4),
      Order(3L, "rubber", 2))).toTable(tEnv)

    val orderB = env.fromCollection(Seq(
      Order(2L, "pen", 3),
      Order(2L, "rubber", 3),
      Order(4L, "beer", 1))).toTable(tEnv)

    // union the two tables
    val result: DataStream[Order] = orderA.unionAll(orderB)
      .select('user, 'product, 'amount)
      .where('amount > 2)
      .toAppendStream[Order]

    result.print()

    env.execute()
  }

  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************

  case class Order(user: Long, product: String, amount: Int)

}
/*
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
package org.apache.flink.table.examples.scala

import org.apache.flink.api.scala._
import org.apache.flink.table.api.scala._

/**
  * This program implements a modified version of the TPC-H query 3. The
  * example demonstrates how to assign names to fields by extending the Tuple class.
  * The original query can be found at
  * [http://www.tpc.org/tpch/spec/tpch2.16.0.pdf](http://www.tpc.org/tpch/spec/tpch2.16.0.pdf)
  * (page 29).
  *
  * This program implements the following SQL equivalent:
  *
  * {{{
  * SELECT
  *      l_orderkey,
  *      SUM(l_extendedprice*(1-l_discount)) AS revenue,
  *      o_orderdate,
  *      o_shippriority
  * FROM customer,
  *      orders,
  *      lineitem
  * WHERE
  *      c_mktsegment = '[SEGMENT]'
  *      AND c_custkey = o_custkey
  *      AND l_orderkey = o_orderkey
  *      AND o_orderdate < date '[DATE]'
  *      AND l_shipdate > date '[DATE]'
  * GROUP BY
  *      l_orderkey,
  *      o_orderdate,
  *      o_shippriority
  * ORDER BY
  *      revenue desc,
  *      o_orderdate;
  * }}}
  *
  * Input files are plain text CSV files using the pipe character ('|') as field separator
  * as generated by the TPC-H data generator which is available at
  * [http://www.tpc.org/tpch/](a href="http://www.tpc.org/tpch/).
  *
  * Usage:
  * {{{
  * TPCHQuery3Expression <lineitem-csv path> <customer-csv path> <orders-csv path> <result path>
  * }}}
  *
  * This example shows how to:
  *  - Convert DataSets to Tables
  *  - Use Table API expressions
  *
  */
object TPCHQuery3Table {

  // *************************************************************************
  //     PROGRAM
  // *************************************************************************

  def main(args: Array[String]) {
    if (!parseParameters(args)) {
      return
    }

    // set filter date
    val date = "1995-03-12".toDate

    // get execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment
    val tEnv = BatchTableEnvironment.create(env)

    val lineitems = getLineitemDataSet(env)
      .toTable(tEnv, 'id, 'extdPrice, 'discount, 'shipDate)
      .filter('shipDate.toDate > date)

    val customers = getCustomerDataSet(env)
      .toTable(tEnv, 'id, 'mktSegment)
      .filter('mktSegment === "AUTOMOBILE")

    val orders = getOrdersDataSet(env)
      .toTable(tEnv, 'orderId, 'custId, 'orderDate, 'shipPrio)
      .filter('orderDate.toDate < date)

    val items =
      orders.join(customers)
        .where('custId === 'id)
        .select('orderId, 'orderDate, 'shipPrio)
      .join(lineitems)
        .where('orderId === 'id)
        .select(
          'orderId,
          'extdPrice * (1.0f.toExpr - 'discount) as 'revenue,
          'orderDate,
          'shipPrio)

    val result = items
      .groupBy('orderId, 'orderDate, 'shipPrio)
      .select('orderId, 'revenue.sum as 'revenue, 'orderDate, 'shipPrio)
      .orderBy('revenue.desc, 'orderDate.asc)

    // emit result
    result.writeAsCsv(outputPath, "\n", "|")

    // execute program
    env.execute("Scala TPCH Query 3 (Table API Expression) Example")
  }
  
  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************
  
  case class Lineitem(id: Long, extdPrice: Double, discount: Double, shipDate: String)
  case class Customer(id: Long, mktSegment: String)
  case class Order(orderId: Long, custId: Long, orderDate: String, shipPrio: Long)

  // *************************************************************************
  //     UTIL METHODS
  // *************************************************************************
  
  private var lineitemPath: String = _
  private var customerPath: String = _
  private var ordersPath: String = _
  private var outputPath: String = _

  private def parseParameters(args: Array[String]): Boolean = {
    if (args.length == 4) {
      lineitemPath = args(0)
      customerPath = args(1)
      ordersPath = args(2)
      outputPath = args(3)
      true
    } else {
      System.err.println("This program expects data from the TPC-H benchmark as input data.\n" +
          " Due to legal restrictions, we can not ship generated data.\n" +
          " You can find the TPC-H data generator at http://www.tpc.org/tpch/.\n" +
          " Usage: TPCHQuery3 <lineitem-csv path> <customer-csv path> " +
                             "<orders-csv path> <result path>")
      false
    }
  }

  private def getLineitemDataSet(env: ExecutionEnvironment): DataSet[Lineitem] = {
    env.readCsvFile[Lineitem](
        lineitemPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 5, 6, 10) )
  }

  private def getCustomerDataSet(env: ExecutionEnvironment): DataSet[Customer] = {
    env.readCsvFile[Customer](
        customerPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 6) )
  }

  private def getOrdersDataSet(env: ExecutionEnvironment): DataSet[Order] = {
    env.readCsvFile[Order](
        ordersPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 1, 4, 7) )
  }
  
}
/*
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

package org.apache.flink.examples.scala.misc

import org.apache.flink.api.scala._

object PiEstimation {

  def main(args: Array[String]) {

    val numSamples: Long = if (args.length > 0) args(0).toLong else 1000000

    val env = ExecutionEnvironment.getExecutionEnvironment

    // count how many of the samples would randomly fall into
    // the upper right quadrant of the unit circle
    val count =
      env.generateSequence(1, numSamples)
        .map  { sample =>
          val x = Math.random()
          val y = Math.random()
          if (x * x + y * y < 1) 1L else 0L
        }
        .reduce(_ + _)

    // ratio of samples in upper right quadrant vs total samples gives surface of upper
    // right quadrant, times 4 gives surface of whole unit circle, i.e. PI
    val pi = count
      .map ( _ * 4.0 / numSamples)

    println("We estimate Pi to be:")

    pi.print()
  }

}
/*
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

package org.apache.flink.examples.scala.relational

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.examples.java.relational.util.WebLogData
import org.apache.flink.util.Collector

/**
 * This program processes web logs and relational data.
 * It implements the following relational query:
 *
 * {{{
 * SELECT
 *       r.pageURL,
 *       r.pageRank,
 *       r.avgDuration
 * FROM documents d JOIN rankings r
 *                  ON d.url = r.url
 * WHERE CONTAINS(d.text, [keywords])
 *       AND r.rank > [rank]
 *       AND NOT EXISTS
 *           (
 *              SELECT * FROM Visits v
 *              WHERE v.destUrl = d.url
 *                    AND v.visitDate < [date]
 *           );
 * }}}
 *
 *
 * Input files are plain text CSV files using the pipe character ('|') as field separator.
 * The tables referenced in the query can be generated using the
 * [org.apache.flink.examples.java.relational.util.WebLogDataGenerator]] and
 * have the following schemas
 *
 * {{{
 * CREATE TABLE Documents (
 *                url VARCHAR(100) PRIMARY KEY,
 *                contents TEXT );
 *
 * CREATE TABLE Rankings (
 *                pageRank INT,
 *                pageURL VARCHAR(100) PRIMARY KEY,
 *                avgDuration INT );
 *
 * CREATE TABLE Visits (
 *                sourceIP VARCHAR(16),
 *                destURL VARCHAR(100),
 *                visitDate DATE,
 *                adRevenue FLOAT,
 *                userAgent VARCHAR(64),
 *                countryCode VARCHAR(3),
 *                languageCode VARCHAR(6),
 *                searchWord VARCHAR(32),
 *                duration INT );
 * }}}
 *
 *
 * Usage
 * {{{
 *   WebLogAnalysis --documents <path> --ranks <path> --visits <path> --output <path>
 * }}}
 *
 * If no parameters are provided, the program is run with default data from
 * [[org.apache.flink.examples.java.relational.util.WebLogData]].
 *
 * This example shows how to use:
 *
 *  - tuple data types
 *  - projection and join projection
 *  - the CoGroup transformation for an anti-join
 *
 */
object WebLogAnalysis {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    val documents = getDocumentsDataSet(env, params)
    val ranks = getRanksDataSet(env, params)
    val visits = getVisitsDataSet(env, params)

    val filteredDocs = documents
      .filter(doc => doc._2.contains(" editors ") && doc._2.contains(" oscillations "))

    val filteredRanks = ranks
      .filter(rank => rank._1 > 40)

    val filteredVisits = visits
      .filter(visit => visit._2.substring(0, 4).toInt == 2007)

    val joinDocsRanks = filteredDocs.join(filteredRanks).where(0).equalTo(1) {
      (doc, rank) => rank
    }.withForwardedFieldsSecond("*")

    val result = joinDocsRanks.coGroup(filteredVisits).where(1).equalTo(0) {
      (
        ranks: Iterator[(Int, String, Int)],
        visits: Iterator[(String, String)],
        out: Collector[(Int, String, Int)]) =>
          if (visits.isEmpty) for (rank <- ranks) out.collect(rank)
    }.withForwardedFieldsFirst("*")

    // emit result
    if (params.has("output")) {
      result.writeAsCsv(params.get("output"), "\n", "|")
      env.execute("Scala WebLogAnalysis Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      result.print()
    }

  }

  private def getDocumentsDataSet(env: ExecutionEnvironment, params: ParameterTool):
  DataSet[(String, String)] = {
    if (params.has("documents")) {
      env.readCsvFile[(String, String)](
        params.get("documents"),
        fieldDelimiter = "|",
        includedFields = Array(0, 1))
    } else {
      println("Executing WebLogAnalysis example with default documents data set.")
      println("Use --documents to specify file input.")
      val documents = WebLogData.DOCUMENTS map {
        case Array(x, y) => (x.asInstanceOf[String], y.asInstanceOf[String])
      }
      env.fromCollection(documents)
    }
  }

  private def getRanksDataSet(env: ExecutionEnvironment, params: ParameterTool):
  DataSet[(Int, String, Int)] = {
    if (params.has("ranks")) {
      env.readCsvFile[(Int, String, Int)](
        params.get("ranks"),
        fieldDelimiter = "|",
        includedFields = Array(0, 1, 2))
    } else {
      println("Executing WebLogAnalysis example with default ranks data set.")
      println("Use --ranks to specify file input.")
      val ranks = WebLogData.RANKS map {
        case Array(x, y, z) => (x.asInstanceOf[Int], y.asInstanceOf[String], z.asInstanceOf[Int])
      }
      env.fromCollection(ranks)
    }
  }

  private def getVisitsDataSet(env: ExecutionEnvironment, params: ParameterTool):
  DataSet[(String, String)] = {
    if (params.has("visits")) {
      env.readCsvFile[(String, String)](
        params.get("visits"),
        fieldDelimiter = "|",
        includedFields = Array(1, 2))
    } else {
      println("Executing WebLogAnalysis example with default visits data set.")
      println("Use --visits to specify file input.")
      val visits = WebLogData.VISITS map {
        case Array(x, y) => (x.asInstanceOf[String], y.asInstanceOf[String])
      }
      env.fromCollection(visits)
    }
  }
}
/*
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

package org.apache.flink.examples.scala.relational

import org.apache.flink.api.java.aggregation.Aggregations
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._

/**
 * This program implements a modified version of the TPC-H query 3. The
 * example demonstrates how to assign names to fields by extending the Tuple class.
 * The original query can be found at
 * [http://www.tpc.org/tpch/spec/tpch2.16.0.pdf](http://www.tpc.org/tpch/spec/tpch2.16.0.pdf)
 * (page 29).
 *
 * This program implements the following SQL equivalent:
 *
 * {{{
 * SELECT 
 *      l_orderkey, 
 *      SUM(l_extendedprice*(1-l_discount)) AS revenue,
 *      o_orderdate, 
 *      o_shippriority 
 * FROM customer, 
 *      orders, 
 *      lineitem 
 * WHERE
 *      c_mktsegment = '[SEGMENT]' 
 *      AND c_custkey = o_custkey
 *      AND l_orderkey = o_orderkey
 *      AND o_orderdate < date '[DATE]'
 *      AND l_shipdate > date '[DATE]'
 * GROUP BY
 *      l_orderkey, 
 *      o_orderdate, 
 *      o_shippriority;
 * }}}
 *
 * Compared to the original TPC-H query this version does not sort the result by revenue
 * and orderdate.
 *
 * Input files are plain text CSV files using the pipe character ('|') as field separator 
 * as generated by the TPC-H data generator which is available at 
 * [http://www.tpc.org/tpch/](a href="http://www.tpc.org/tpch/).
 *
 * Usage: 
 * {{{
 * TPCHQuery3 --lineitem <path> --customer <path> --orders <path> --output <path>
 * }}}
 *  
 * This example shows how to use:
 *  - case classes and case class field addressing
 *  - build-in aggregation functions
 * 
 */
object TPCHQuery3 {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)
    if (!params.has("lineitem") && !params.has("customer") && !params.has("orders")) {
      println("  This program expects data from the TPC-H benchmark as input data.")
      println("  Due to legal restrictions, we can not ship generated data.")
      println("  You can find the TPC-H data generator at http://www.tpc.org/tpch/.")
      println("  Usage: TPCHQuery3 " +
        "--lineitem <path> --customer <path> --orders <path> [--output <path>]")
      return
    }

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // set filter date
    val dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd")
    val date = dateFormat.parse("1995-03-12")
    
    // read and filter lineitems by shipDate
    val lineitems =
      getLineitemDataSet(env, params.get("lineitem")).
        filter( l => dateFormat.parse(l.shipDate).after(date) )
    // read and filter customers by market segment
    val customers =
      getCustomerDataSet(env, params.get("customer")).
        filter( c => c.mktSegment.equals("AUTOMOBILE"))
    // read orders
    val orders = getOrdersDataSet(env, params.get("orders"))

                      // filter orders by order date
    val items = orders.filter( o => dateFormat.parse(o.orderDate).before(date) )
                      // filter orders by joining with customers
                      .join(customers).where("custId").equalTo("custId").apply( (o,c) => o )
                      // join with lineitems 
                      .join(lineitems).where("orderId").equalTo("orderId")
                                      .apply( (o,l) => 
                                        new ShippedItem( o.orderId,
                                                         l.extdPrice * (1.0 - l.discount),
                                                         o.orderDate,
                                                         o.shipPrio ) )

    // group by order and aggregate revenue
    val result = items.groupBy("orderId", "orderDate", "shipPrio")
                      .aggregate(Aggregations.SUM, "revenue")

    if (params.has("output")) {
      // emit result
      result.writeAsCsv(params.get("output"), "\n", "|")
      // execute program
      env.execute("Scala TPCH Query 3 Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      result.print()
    }

  }
  
  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************
  
  case class Lineitem(orderId: Long, extdPrice: Double, discount: Double, shipDate: String)
  case class Order(orderId: Long, custId: Long, orderDate: String, shipPrio: Long)
  case class Customer(custId: Long, mktSegment: String)
  case class ShippedItem(orderId: Long, revenue: Double, orderDate: String, shipPrio: Long)

  // *************************************************************************
  //     UTIL METHODS
  // *************************************************************************
  
  private def getLineitemDataSet(env: ExecutionEnvironment, lineitemPath: String):
                         DataSet[Lineitem] = {
    env.readCsvFile[Lineitem](
        lineitemPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 5, 6, 10) )
  }

  private def getCustomerDataSet(env: ExecutionEnvironment, customerPath: String):
                         DataSet[Customer] = {
    env.readCsvFile[Customer](
        customerPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 6) )
  }

  private def getOrdersDataSet(env: ExecutionEnvironment, ordersPath: String):
                       DataSet[Order] = {
    env.readCsvFile[Order](
        ordersPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 1, 4, 7) )
  }
}
/*
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

package org.apache.flink.examples.scala.relational

import org.apache.flink.api.java.aggregation.Aggregations
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._

/**
 * This program implements a modified version of the TPC-H query 10. 
 * 
 * The original query can be found at
 * [http://www.tpc.org/tpch/spec/tpch2.16.0.pdf](http://www.tpc.org/tpch/spec/tpch2.16.0.pdf)
 * (page 45).
 *
 * This program implements the following SQL equivalent:
 *
 * {{{
 * SELECT 
 *        c_custkey,
 *        c_name, 
 *        c_address,
 *        n_name, 
 *        c_acctbal
 *        SUM(l_extendedprice * (1 - l_discount)) AS revenue,  
 * FROM   
 *        customer, 
 *        orders, 
 *        lineitem, 
 *        nation 
 * WHERE 
 *        c_custkey = o_custkey 
 *        AND l_orderkey = o_orderkey 
 *        AND YEAR(o_orderdate) > '1990' 
 *        AND l_returnflag = 'R' 
 *        AND c_nationkey = n_nationkey 
 * GROUP BY 
 *        c_custkey, 
 *        c_name, 
 *        c_acctbal, 
 *        n_name, 
 *        c_address
 * }}}
 *
 * Compared to the original TPC-H query this version does not print 
 * c_phone and c_comment, only filters by years greater than 1990 instead of
 * a period of 3 months, and does not sort the result by revenue..
 *
 * Input files are plain text CSV files using the pipe character ('|') as field separator 
 * as generated by the TPC-H data generator which is available at 
 * [http://www.tpc.org/tpch/](a href="http://www.tpc.org/tpch/).
 *
 * Usage: 
 * {{{
 *TPCHQuery10 --customer <path> --orders <path> --lineitem <path> --nation <path> --output <path>
 * }}}
 *  
 * This example shows how to use:
 *  - tuple data types
 *  - build-in aggregation functions
 *  - join with size hints
 *  
 */
object TPCHQuery10 {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)
    if (!params.has("lineitem") && !params.has("customer") &&
      !params.has("orders") && !params.has("nation")) {
      println("  This program expects data from the TPC-H benchmark as input data.")
      println("  Due to legal restrictions, we can not ship generated data.")
      println("  You can find the TPC-H data generator at http://www.tpc.org/tpch/.")
      println("  Usage: TPCHQuery10" +
        "--customer <path> --orders <path> --lineitem <path> --nation <path> --output <path>")
      return
    }

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // get customer data set: (custkey, name, address, nationkey, acctbal) 
    val customers = getCustomerDataSet(env, params.get("customer"))
    // get orders data set: (orderkey, custkey, orderdate)
    val orders = getOrdersDataSet(env, params.get("orders"))
    // get lineitem data set: (orderkey, extendedprice, discount, returnflag)
    val lineitems = getLineitemDataSet(env, params.get("lineitem"))
    // get nation data set: (nationkey, name)    
    val nations = getNationDataSet(env, params.get("nation"))

    // filter orders by years
    val orders1990 = orders.filter( o => o._3.substring(0,4).toInt > 1990)
                           .map( o => (o._1, o._2))
    
    // filter lineitems by return status
    val lineitemsReturn = lineitems.filter( l => l._4.equals("R"))
                                   .map( l => (l._1, l._2 * (1 - l._3)) )

    // compute revenue by customer
    val revenueByCustomer = orders1990.joinWithHuge(lineitemsReturn).where(0).equalTo(0)
                                        .apply( (o,l) => (o._2, l._2) )
                                      .groupBy(0)
                                      .aggregate(Aggregations.SUM, 1)

    // compute final result by joining customer and nation information with revenue
    val result = customers.joinWithTiny(nations).where(3).equalTo(0)
                            .apply( (c, n) => (c._1, c._2, c._3, n._2, c._5) )
                          .join(revenueByCustomer).where(0).equalTo(0)
                            .apply( (c, r) => (c._1, c._2, c._3, c._4, c._5, r._2) )

    if (params.has("output")) {
      // emit result
      result.writeAsCsv(params.get("output"), "\n", "|")
      // execute program
      env.execute("Scala TPCH Query 10 Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      result.print()
    }

  }
  
  // *************************************************************************
  //     UTIL METHODS
  // *************************************************************************
  
  private def getCustomerDataSet(env: ExecutionEnvironment, customerPath: String):
                         DataSet[(Int, String, String, Int, Double)] = {
    env.readCsvFile[(Int, String, String, Int, Double)](
        customerPath,
        fieldDelimiter = "|",
        includedFields = Array(0,1,2,3,5) )
  }
  
  private def getOrdersDataSet(env: ExecutionEnvironment, ordersPath: String):
                       DataSet[(Int, Int, String)] = {
    env.readCsvFile[(Int, Int, String)](
        ordersPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 1, 4) )
  }
  
  private def getLineitemDataSet(env: ExecutionEnvironment, lineitemPath: String):
                         DataSet[(Int, Double, Double, String)] = {
    env.readCsvFile[(Int, Double, Double, String)](
        lineitemPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 5, 6, 8) )
  }

  private def getNationDataSet(env: ExecutionEnvironment, nationPath: String):
                       DataSet[(Int, String)] = {
    env.readCsvFile[(Int, String)](
        nationPath,
        fieldDelimiter = "|",
        includedFields = Array(0, 1) )
  }
}
/*
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

package org.apache.flink.examples.scala.graph

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.examples.java.graph.util.ConnectedComponentsData
import org.apache.flink.util.Collector

/**
 * An implementation of the connected components algorithm, using a delta iteration.
 *
 * Initially, the algorithm assigns each vertex an unique ID. In each step, a vertex picks the
 * minimum of its own ID and its neighbors' IDs, as its new ID and tells its neighbors about its
 * new ID. After the algorithm has completed, all vertices in the same component will have the same
 * ID.
 *
 * A vertex whose component ID did not change needs not propagate its information in the next
 * step. Because of that, the algorithm is easily expressible via a delta iteration. We here model
 * the solution set as the vertices with their current component ids, and the workset as the changed
 * vertices. Because we see all vertices initially as changed, the initial workset and the initial
 * solution set are identical. Also, the delta to the solution set is consequently also the next
 * workset.
 * 
 * Input files are plain text files and must be formatted as follows:
 *
 *   - Vertices represented as IDs and separated by new-line characters. For example,
 *     `"1\n2\n12\n42\n63"` gives five vertices (1), (2), (12), (42), and (63).
 *   - Edges are represented as pairs for vertex IDs which are separated by space characters. Edges
 *     are separated by new-line characters. For example `"1 2\n2 12\n1 12\n42 63"`
 *     gives four (undirected) edges (1)-(2), (2)-(12), (1)-(12), and (42)-(63).
 *
 * Usage:
 * {{{
 *   ConnectedComponents --vertices <path> --edges <path> --result <path> --iterations <n>
 * }}}
 *   
 * If no parameters are provided, the program is run with default data from
 * [[org.apache.flink.examples.java.graph.util.ConnectedComponentsData]] and 10 iterations.
 * 
 *
 * This example shows how to use:
 *
 *   - Delta Iterations
 *   - Generic-typed Functions 
 *   
 */
object ConnectedComponents {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    val maxIterations: Int = params.getInt("iterations", 10)

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // read vertex and edge data
    // assign the initial components (equal to the vertex id)
    val vertices =
      getVertexDataSet(env, params).map { id => (id, id) }.withForwardedFields("*->_1;*->_2")

    // undirected edges by emitting for each input edge the input
    // edges itself and an inverted version
    val edges =
      getEdgeDataSet(env, params).flatMap { edge => Seq(edge, (edge._2, edge._1)) }

    // open a delta iteration
    val verticesWithComponents = vertices.iterateDelta(vertices, maxIterations, Array("_1")) {
      (s, ws) =>

        // apply the step logic: join with the edges
        val allNeighbors = ws.join(edges).where(0).equalTo(0) { (vertex, edge) =>
          (edge._2, vertex._2)
        }.withForwardedFieldsFirst("_2->_2").withForwardedFieldsSecond("_2->_1")

        // select the minimum neighbor
        val minNeighbors = allNeighbors.groupBy(0).min(1)

        // update if the component of the candidate is smaller
        val updatedComponents = minNeighbors.join(s).where(0).equalTo(0) {
          (newVertex, oldVertex, out: Collector[(Long, Long)]) =>
            if (newVertex._2 < oldVertex._2) out.collect(newVertex)
        }.withForwardedFieldsFirst("*")

        // delta and new workset are identical
        (updatedComponents, updatedComponents)
    }

    if (params.has("output")) {
      verticesWithComponents.writeAsCsv(params.get("output"), "\n", " ")
      env.execute("Scala Connected Components Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      verticesWithComponents.print()
    }

  }

  private def getVertexDataSet(env: ExecutionEnvironment, params: ParameterTool): DataSet[Long] = {
    if (params.has("vertices")) {
      env.readCsvFile[Tuple1[Long]](
        params.get("vertices"),
        includedFields = Array(0))
        .map { x => x._1 }
    }
    else {
      println("Executing ConnectedComponents example with default vertices data set.")
      println("Use --vertices to specify file input.")
      env.fromCollection(ConnectedComponentsData.VERTICES)
    }
  }

  private def getEdgeDataSet(env: ExecutionEnvironment, params: ParameterTool):
                     DataSet[(Long, Long)] = {
    if (params.has("edges")) {
      env.readCsvFile[(Long, Long)](
        params.get("edges"),
        fieldDelimiter = " ",
        includedFields = Array(0, 1))
        .map { x => (x._1, x._2)}
    }
    else {
      println("Executing ConnectedComponents example with default edges data set.")
      println("Use --edges to specify file input.")
      val edgeData = ConnectedComponentsData.EDGES map {
        case Array(x, y) => (x.asInstanceOf[Long], y.asInstanceOf[Long])
      }
      env.fromCollection(edgeData)
    }
  }
}
/*
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
package org.apache.flink.examples.scala.graph

import java.lang.Iterable

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.java.aggregation.Aggregations.SUM
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.examples.java.graph.util.PageRankData
import org.apache.flink.util.Collector

import scala.collection.JavaConverters._

/**
 * A basic implementation of the Page Rank algorithm using a bulk iteration.
 * 
 * This implementation requires a set of pages and a set of directed links as input and works as
 * follows.
 *
 * In each iteration, the rank of every page is evenly distributed to all pages it points to. Each
 * page collects the partial ranks of all pages that point to it, sums them up, and applies a
 * dampening factor to the sum. The result is the new rank of the page. A new iteration is started
 * with the new ranks of all pages. This implementation terminates after a fixed number of
 * iterations. This is the Wikipedia entry for the
 * [[http://en.wikipedia.org/wiki/Page_rank Page Rank algorithm]]
 * 
 * Input files are plain text files and must be formatted as follows:
 *
 *  - Pages represented as an (long) ID separated by new-line characters.
 *    For example `"1\n2\n12\n42\n63"` gives five pages with IDs 1, 2, 12, 42, and 63.
 *  - Links are represented as pairs of page IDs which are separated by space  characters. Links
 *    are separated by new-line characters.
 *    For example `"1 2\n2 12\n1 12\n42 63"` gives four (directed) links (1)->(2), (2)->(12),
 *    (1)->(12), and (42)->(63). For this simple implementation it is required that each page has
 *    at least one incoming and one outgoing link (a page can point to itself).
 *
 * Usage:
 * {{{
 *   PageRankBasic --pages <path> --links <path> --output <path> --numPages <n> --iterations <n>
 * }}}
 *
 * If no parameters are provided, the program is run with default data from
 * [[org.apache.flink.examples.java.graph.util.PageRankData]] and 10 iterations.
 * 
 * This example shows how to use:
 *
 *  - Bulk Iterations
 *  - Default Join
 *  - Configure user-defined functions using constructor parameters.
 *
 */
object PageRankBasic {

  private final val DAMPENING_FACTOR: Double = 0.85
  private final val EPSILON: Double = 0.0001

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // read input data
    val (pages, numPages) = getPagesDataSet(env, params)
    val links = getLinksDataSet(env, params)
    val maxIterations = params.getInt("iterations", 10)

    // assign initial ranks to pages
    val pagesWithRanks = pages.map(p => Page(p, 1.0 / numPages)).withForwardedFields("*->pageId")

    // build adjacency list from link input
    val adjacencyLists = links
      .groupBy("sourceId").reduceGroup( new GroupReduceFunction[Link, AdjacencyList] {
        override def reduce(values: Iterable[Link], out: Collector[AdjacencyList]): Unit = {
          var outputId = -1L
          val outputList = values.asScala map { t => outputId = t.sourceId; t.targetId }
          out.collect(new AdjacencyList(outputId, outputList.toArray))
        }
      })

    // start iteration
    val finalRanks = pagesWithRanks.iterateWithTermination(maxIterations) {
      currentRanks =>
        val newRanks = currentRanks
          // distribute ranks to target pages
          .join(adjacencyLists).where("pageId").equalTo("sourceId") {
            (page, adjacent, out: Collector[Page]) =>
              val targets = adjacent.targetIds
              val len = targets.length
              adjacent.targetIds foreach { t => out.collect(Page(t, page.rank /len )) }
          }
          // collect ranks and sum them up
          .groupBy("pageId").aggregate(SUM, "rank")
          // apply dampening factor
          .map { p =>
            Page(p.pageId, (p.rank * DAMPENING_FACTOR) + ((1 - DAMPENING_FACTOR) / numPages))
          }.withForwardedFields("pageId")

        // terminate if no rank update was significant
        val termination = currentRanks.join(newRanks).where("pageId").equalTo("pageId") {
          (current, next, out: Collector[Int]) =>
            // check for significant update
            if (math.abs(current.rank - next.rank) > EPSILON) out.collect(1)
        }
        (newRanks, termination)
    }

    val result = finalRanks

    // emit result
    if (params.has("output")) {
      result.writeAsCsv(params.get("output"), "\n", " ")
      // execute program
      env.execute("Basic PageRank Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      result.print()
    }
  }

  // *************************************************************************
  //     USER TYPES
  // *************************************************************************

  case class Link(sourceId: Long, targetId: Long)

  case class Page(pageId: Long, rank: Double)

  case class AdjacencyList(sourceId: Long, targetIds: Array[Long])

  // *************************************************************************
  //     UTIL METHODS
  // *************************************************************************

  private def getPagesDataSet(env: ExecutionEnvironment, params: ParameterTool):
                     (DataSet[Long], Long) = {
    if (params.has("pages") && params.has("numPages")) {
      val pages = env
        .readCsvFile[Tuple1[Long]](params.get("pages"), fieldDelimiter = " ", lineDelimiter = "\n")
        .map(x => x._1)
      (pages, params.getLong("numPages"))
    } else {
      println("Executing PageRank example with default pages data set.")
      println("Use --pages and --numPages to specify file input.")
      (env.generateSequence(1, 15), PageRankData.getNumberOfPages)
    }
  }

  private def getLinksDataSet(env: ExecutionEnvironment, params: ParameterTool):
                      DataSet[Link] = {
    if (params.has("links")) {
      env.readCsvFile[Link](params.get("links"), fieldDelimiter = " ",
        includedFields = Array(0, 1))
    } else {
      println("Executing PageRank example with default links data set.")
      println("Use --links to specify file input.")
      val edges = PageRankData.EDGES.map { case Array(v1, v2) => Link(v1.asInstanceOf[Long],
        v2.asInstanceOf[Long])}
      env.fromCollection(edges)
    }
  }
}
/*
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

package org.apache.flink.examples.scala.graph

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.common.operators.Order
import org.apache.flink.api.java.functions.FunctionAnnotation.ForwardedFields
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala.{ExecutionEnvironment, _}
import org.apache.flink.examples.java.graph.util.EnumTrianglesData
import org.apache.flink.util.Collector

import scala.collection.JavaConverters._
import scala.collection.mutable

/**
 * Triangle enumeration is a pre-processing step to find closely connected parts in graphs.
 * A triangle consists of three edges that connect three vertices with each other.
 * 
 * The algorithm works as follows:
 * It groups all edges that share a common vertex and builds triads, i.e., triples of vertices 
 * that are connected by two edges. Finally, all triads are filtered for which no third edge exists 
 * that closes the triangle.
 *  
 * Input files are plain text files and must be formatted as follows:
 *
 *  - Edges are represented as pairs for vertex IDs which are separated by space
 *   characters. Edges are separated by new-line characters.
 *   For example `"1 2\n2 12\n1 12\n42 63"` gives four (undirected) edges (1)-(2), (2)-(12),
 *   (1)-(12), and (42)-(63) that include a triangle
 *
 * <pre>
 *     (1)
 *     /  \
 *   (2)-(12)
 * </pre>
 * 
 * Usage: 
 * {{{
 * EnumTriangleBasic <edge path> <result path>
 * }}}
 * <br>
 * If no parameters are provided, the program is run with default data from 
 * [[org.apache.flink.examples.java.graph.util.EnumTrianglesData]]
 * 
 * This example shows how to use:
 *
 *  - Custom Java objects which extend Tuple
 *  - Group Sorting
 *
 */
object EnumTriangles {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    // read input data
    val edges =
      if (params.has("edges")) {
        env.readCsvFile[Edge](
          filePath = params.get("edges"),
          fieldDelimiter = " ",
          includedFields = Array(0, 1))
      } else {
        println("Executing EnumTriangles example with default edges data set.")
        println("Use --edges to specify file input.")
        val edges = EnumTrianglesData.EDGES.map {
          case Array(v1, v2) => new Edge(v1.asInstanceOf[Int], v2.asInstanceOf[Int])
        }
        env.fromCollection(edges)
      }
    
    // project edges by vertex id
    val edgesById = edges map(e => if (e.v1 < e.v2) e else Edge(e.v2, e.v1) )
    
    val triangles = edgesById
            // build triads
            .groupBy("v1").sortGroup("v2", Order.ASCENDING).reduceGroup(new TriadBuilder())
            // filter triads
            .join(edgesById).where("v2", "v3").equalTo("v1", "v2") { (t, _) => t }
              .withForwardedFieldsFirst("*")
    
    // emit result
    if (params.has("output")) {
      triangles.writeAsCsv(params.get("output"), "\n", ",")
      // execute program
      env.execute("TriangleEnumeration Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      triangles.print()
    }
    

  }

  // *************************************************************************
  //     USER DATA TYPES
  // *************************************************************************

  case class Edge(v1: Int, v2: Int) extends Serializable
  case class Triad(v1: Int, v2: Int, v3: Int) extends Serializable
  
    
  // *************************************************************************
  //     USER FUNCTIONS
  // *************************************************************************

  /**
   *  Builds triads (triples of vertices) from pairs of edges that share a vertex. The first vertex
   *  of a triad is the shared vertex, the second and third vertex are ordered by vertexId. Assumes
   *  that input edges share the first vertex and are in ascending order of the second vertex.
   */
  @ForwardedFields(Array("v1->v1"))
  class TriadBuilder extends GroupReduceFunction[Edge, Triad] {

    val vertices = mutable.MutableList[Integer]()
    
    override def reduce(edges: java.lang.Iterable[Edge], out: Collector[Triad]) = {
      
      // clear vertex list
      vertices.clear()

      // build and emit triads
      for(e <- edges.asScala) {
      
        // combine vertex with all previously read vertices
        for(v <- vertices) {
          out.collect(Triad(e.v1, v, e.v2))
        }
        vertices += e.v2
      }
    }
  }
}
/*
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

package org.apache.flink.examples.scala.graph

import org.apache.flink.api.scala._
import org.apache.flink.util.Collector

object DeltaPageRank {

  private final val DAMPENING_FACTOR: Double = 0.85
  private final val NUM_VERTICES = 5
  private final val INITIAL_RANK = 1.0 / NUM_VERTICES
  private final val RANDOM_JUMP = (1 - DAMPENING_FACTOR) / NUM_VERTICES
  private final val THRESHOLD = 0.0001 / NUM_VERTICES

  type Page = (Long, Double)
  type Adjacency = (Long, Array[Long])

  def main(args: Array[String]) {

    val maxIterations = 100

    val env = ExecutionEnvironment.getExecutionEnvironment

    val rawLines: DataSet[String] = env.fromElements(
                                                      "1 2 3 4",
                                                      "2 1",
                                                      "3 5",
                                                      "4 2 3",
                                                      "5 2 4")
    val adjacency: DataSet[Adjacency] = rawLines
      .map(str => {
        val elements = str.split(' ')
        val id = elements(0).toLong
        val neighbors = elements.slice(1, elements.length).map(_.toLong)
        (id, neighbors)
      })

    val initialRanks: DataSet[Page] = adjacency.flatMap {
      (adj, out: Collector[Page]) =>
        {
          val targets = adj._2
          val rankPerTarget = INITIAL_RANK * DAMPENING_FACTOR / targets.length

          // dampen fraction to targets
          for (target <- targets) {
            out.collect((target, rankPerTarget))
          }

          // random jump to self
          out.collect((adj._1, RANDOM_JUMP))
        }
    }
      .groupBy(0).sum(1)

    val initialDeltas = initialRanks.map { (page) => (page._1, page._2 - INITIAL_RANK) }
                                      .withForwardedFields("_1")

    val iteration = initialRanks.iterateDelta(initialDeltas, maxIterations, Array(0)) {

      (solutionSet, workset) =>
        {
          val deltas = workset.join(adjacency).where(0).equalTo(0) {
            (lastDeltas, adj, out: Collector[Page]) =>
              {
                val targets = adj._2
                val deltaPerTarget = DAMPENING_FACTOR * lastDeltas._2 / targets.length

                for (target <- targets) {
                  out.collect((target, deltaPerTarget))
                }
              }
          }
            .groupBy(0).sum(1)
            .filter(x => Math.abs(x._2) > THRESHOLD)

          val rankUpdates = solutionSet.join(deltas).where(0).equalTo(0) {
            (current, delta) => (current._1, current._2 + delta._2)
          }.withForwardedFieldsFirst("_1")

          (rankUpdates, deltas)
        }
    }

    iteration.print()

  }
}
/*
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

package org.apache.flink.examples.scala.graph

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.examples.java.graph.util.ConnectedComponentsData
import org.apache.flink.util.Collector

object TransitiveClosureNaive {

  def main (args: Array[String]): Unit = {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    val edges =
      if (params.has("edges")) {
        env.readCsvFile[(Long, Long)](
          filePath = params.get("edges"),
          fieldDelimiter = " ",
          includedFields = Array(0, 1))
          .map { x => (x._1, x._2)}
      } else {
        println("Executing TransitiveClosure example with default edges data set.")
        println("Use --edges to specify file input.")
        val edgeData = ConnectedComponentsData.EDGES map {
          case Array(x, y) => (x.asInstanceOf[Long], y.asInstanceOf[Long])
        }
        env.fromCollection(edgeData)
      }

    val maxIterations = params.getInt("iterations", 10)

    val paths = edges.iterateWithTermination(maxIterations) { prevPaths: DataSet[(Long, Long)] =>

      val nextPaths = prevPaths
        .join(edges)
        .where(1).equalTo(0) {
          (left, right) => (left._1,right._2)
        }.withForwardedFieldsFirst("_1").withForwardedFieldsSecond("_2")
        .union(prevPaths)
        .groupBy(0, 1)
        .reduce((l, r) => l).withForwardedFields("_1; _2")

      val terminate = prevPaths
        .coGroup(nextPaths)
        .where(0).equalTo(0) {
          (
            prev: Iterator[(Long, Long)],
            next: Iterator[(Long, Long)],
            out: Collector[(Long, Long)]) => {
              val prevPaths = prev.toSet
              for (n <- next)
                if (!prevPaths.contains(n)) out.collect(n)
            }
      }.withForwardedFieldsSecond("*")
      (nextPaths, terminate)
    }

    if (params.has("output")) {
      paths.writeAsCsv(params.get("output"), "\n", " ")
      env.execute("Scala Transitive Closure Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      paths.print()
    }

  }
}
/*
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
package org.apache.flink.examples.scala.clustering

import org.apache.flink.api.common.functions._
import org.apache.flink.api.java.functions.FunctionAnnotation.ForwardedFields
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.configuration.Configuration
import org.apache.flink.examples.java.clustering.util.KMeansData

import scala.collection.JavaConverters._

/**
 * This example implements a basic K-Means clustering algorithm.
 *
 * K-Means is an iterative clustering algorithm and works as follows:
 * K-Means is given a set of data points to be clustered and an initial set of ''K'' cluster
 * centers.
 * In each iteration, the algorithm computes the distance of each data point to each cluster center.
 * Each point is assigned to the cluster center which is closest to it.
 * Subsequently, each cluster center is moved to the center (''mean'') of all points that have
 * been assigned to it.
 * The moved cluster centers are fed into the next iteration.
 * The algorithm terminates after a fixed number of iterations (as in this implementation)
 * or if cluster centers do not (significantly) move in an iteration.
 * This is the Wikipedia entry for the [[http://en.wikipedia
 * .org/wiki/K-means_clustering K-Means Clustering algorithm]].
 *
 * This implementation works on two-dimensional data points.
 * It computes an assignment of data points to cluster centers, i.e.,
 * each data point is annotated with the id of the final cluster (center) it belongs to.
 *
 * Input files are plain text files and must be formatted as follows:
 *
 * - Data points are represented as two double values separated by a blank character.
 * Data points are separated by newline characters.
 * For example `"1.2 2.3\n5.3 7.2\n"` gives two data points (x=1.2, y=2.3) and (x=5.3,
 * y=7.2).
 * - Cluster centers are represented by an integer id and a point value.
 * For example `"1 6.2 3.2\n2 2.9 5.7\n"` gives two centers (id=1, x=6.2,
 * y=3.2) and (id=2, x=2.9, y=5.7).
 *
 * Usage:
 * {{{
 *   KMeans --points <path> --centroids <path> --output <path> --iterations <n>
 * }}}
 * If no parameters are provided, the program is run with default data from
 * [[org.apache.flink.examples.java.clustering.util.KMeansData]]
 * and 10 iterations.
 *
 * This example shows how to use:
 *
 * - Bulk iterations
 * - Broadcast variables in bulk iterations
 * - Scala case classes
 */
object KMeans {

  def main(args: Array[String]) {

    // checking input parameters
    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env: ExecutionEnvironment = ExecutionEnvironment.getExecutionEnvironment

    // get input data:
    // read the points and centroids from the provided paths or fall back to default data
    val points: DataSet[Point] = getPointDataSet(params, env)
    val centroids: DataSet[Centroid] = getCentroidDataSet(params, env)

    val finalCentroids = centroids.iterate(params.getInt("iterations", 10)) { currentCentroids =>
      val newCentroids = points
        .map(new SelectNearestCenter).withBroadcastSet(currentCentroids, "centroids")
        .map { x => (x._1, x._2, 1L) }.withForwardedFields("_1; _2")
        .groupBy(0)
        .reduce { (p1, p2) => (p1._1, p1._2.add(p2._2), p1._3 + p2._3) }.withForwardedFields("_1")
        .map { x => new Centroid(x._1, x._2.div(x._3)) }.withForwardedFields("_1->id")
      newCentroids
    }

    val clusteredPoints: DataSet[(Int, Point)] =
      points.map(new SelectNearestCenter).withBroadcastSet(finalCentroids, "centroids")

    if (params.has("output")) {
      clusteredPoints.writeAsCsv(params.get("output"), "\n", " ")
      env.execute("Scala KMeans Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      clusteredPoints.print()
    }

  }

  // *************************************************************************
  //     UTIL FUNCTIONS
  // *************************************************************************

  def getCentroidDataSet(params: ParameterTool, env: ExecutionEnvironment): DataSet[Centroid] = {
    if (params.has("centroids")) {
      env.readCsvFile[Centroid](
        params.get("centroids"),
        fieldDelimiter = " ",
        includedFields = Array(0, 1, 2))
    } else {
      println("Executing K-Means example with default centroid data set.")
      println("Use --centroids to specify file input.")
      env.fromCollection(KMeansData.CENTROIDS map {
        case Array(id, x, y) =>
          new Centroid(id.asInstanceOf[Int], x.asInstanceOf[Double], y.asInstanceOf[Double])
      })
    }
  }

  def getPointDataSet(params: ParameterTool, env: ExecutionEnvironment): DataSet[Point] = {
    if (params.has("points")) {
      env.readCsvFile[Point](
        params.get("points"),
        fieldDelimiter = " ",
        includedFields = Array(0, 1))
    } else {
      println("Executing K-Means example with default points data set.")
      println("Use --points to specify file input.")
      env.fromCollection(KMeansData.POINTS map {
        case Array(x, y) => new Point(x.asInstanceOf[Double], y.asInstanceOf[Double])
      })
    }
  }

  // *************************************************************************
  //     DATA TYPES
  // *************************************************************************

  /**
    * Common trait for operations supported by both points and centroids
    * Note: case class inheritance is not allowed in Scala
    */
  trait Coordinate extends Serializable {

    var x: Double
    var y: Double

    def add(other: Coordinate): this.type = {
      x += other.x
      y += other.y
      this
    }

    def div(other: Long): this.type = {
      x /= other
      y /= other
      this
    }

    def euclideanDistance(other: Coordinate): Double =
      Math.sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))

    def clear(): Unit = {
      x = 0
      y = 0
    }

    override def toString: String =
      s"$x $y"

  }

  /**
    * A simple two-dimensional point.
    */
  case class Point(var x: Double = 0, var y: Double = 0) extends Coordinate

  /**
    * A simple two-dimensional centroid, basically a point with an ID.
    */
  case class Centroid(var id: Int = 0, var x: Double = 0, var y: Double = 0) extends Coordinate {

    def this(id: Int, p: Point) {
      this(id, p.x, p.y)
    }

    override def toString: String =
      s"$id ${super.toString}"

  }

  /** Determines the closest cluster center for a data point. */
  @ForwardedFields(Array("*->_2"))
  final class SelectNearestCenter extends RichMapFunction[Point, (Int, Point)] {
    private var centroids: Traversable[Centroid] = null

    /** Reads the centroid values from a broadcast variable into a collection. */
    override def open(parameters: Configuration) {
      centroids = getRuntimeContext.getBroadcastVariable[Centroid]("centroids").asScala
    }

    def map(p: Point): (Int, Point) = {
      var minDistance: Double = Double.MaxValue
      var closestCentroidId: Int = -1
      for (centroid <- centroids) {
        val distance = p.euclideanDistance(centroid)
        if (distance < minDistance) {
          minDistance = distance
          closestCentroidId = centroid.id
        }
      }
      (closestCentroidId, p)
    }

  }
}


/*
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

package org.apache.flink.examples.scala.wordcount

import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.examples.java.wordcount.util.WordCountData

/**
 * Implements the "WordCount" program that computes a simple word occurrence histogram
 * over text files. 
 *
 * The input is a plain text file with lines separated by newline characters.
 *
 * Usage:
 * {{{
 *   WordCount --input <path> --output <path>
 * }}}
 *
 * If no parameters are provided, the program is run with default data from
 * [[org.apache.flink.examples.java.wordcount.util.WordCountData]]
 *
 * This example shows how to:
 *
 *   - write a simple Flink program.
 *   - use Tuple data types.
 *   - write and use user-defined functions.
 *
 */
object WordCount {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)
    val text =
      if (params.has("input")) {
        env.readTextFile(params.get("input"))
      } else {
        println("Executing WordCount example with default input data set.")
        println("Use --input to specify file input.")
        env.fromCollection(WordCountData.WORDS)
      }

    val counts = text.flatMap { _.toLowerCase.split("\\W+") filter { _.nonEmpty } }
      .map { (_, 1) }
      .groupBy(0)
      .sum(1)

    if (params.has("output")) {
      counts.writeAsCsv(params.get("output"), "\n", " ")
      env.execute("Scala WordCount Example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      counts.print()
    }

  }
}


/*
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

package org.apache.flink.examples.scala.ml

import org.apache.flink.api.common.functions._
import org.apache.flink.api.java.utils.ParameterTool
import org.apache.flink.api.scala._
import org.apache.flink.configuration.Configuration
import org.apache.flink.examples.java.ml.util.LinearRegressionData

import scala.collection.JavaConverters._

/**
 * This example implements a basic Linear Regression  to solve the y = theta0 + theta1*x problem
 * using batch gradient descent algorithm.
 *
 * Linear Regression with BGD(batch gradient descent) algorithm is an iterative algorithm and
 * works as follows:
 *
 * Giving a data set and target set, the BGD try to find out the best parameters for the data set
 * to fit the target set.
 * In each iteration, the algorithm computes the gradient of the cost function and use it to
 * update all the parameters.
 * The algorithm terminates after a fixed number of iterations (as in this implementation).
 * With enough iteration, the algorithm can minimize the cost function and find the best parameters
 * This is the Wikipedia entry for the
 * [[http://en.wikipedia.org/wiki/Linear_regression Linear regression]] and
 * [[http://en.wikipedia.org/wiki/Gradient_descent Gradient descent algorithm]].
 *
 * This implementation works on one-dimensional data and finds the best two-dimensional theta to
 * fit the target.
 *
 * Input files are plain text files and must be formatted as follows:
 *
 *  - Data points are represented as two double values separated by a blank character. The first
 *    one represent the X(the training data) and the second represent the Y(target). Data points are
 *    separated by newline characters.
 *    For example `"-0.02 -0.04\n5.3 10.6\n"`gives two data points
 *    (x=-0.02, y=-0.04) and (x=5.3, y=10.6).
 *
 * This example shows how to use:
 *
 *  - Bulk iterations
 *  - Broadcast variables in bulk iterations
 */
object LinearRegression {

  def main(args: Array[String]) {

    val params: ParameterTool = ParameterTool.fromArgs(args)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // make parameters available in the web interface
    env.getConfig.setGlobalJobParameters(params)

    val parameters = env.fromCollection(LinearRegressionData.PARAMS map {
      case Array(x, y) => Params(x.asInstanceOf[Double], y.asInstanceOf[Double])
    })

    val data =
      if (params.has("input")) {
        env.readCsvFile[(Double, Double)](
          params.get("input"),
          fieldDelimiter = " ",
          includedFields = Array(0, 1))
          .map { t => new Data(t._1, t._2) }
      } else {
        println("Executing LinearRegression example with default input data set.")
        println("Use --input to specify file input.")
        val data = LinearRegressionData.DATA map {
          case Array(x, y) => Data(x.asInstanceOf[Double], y.asInstanceOf[Double])
        }
        env.fromCollection(data)
      }

    val numIterations = params.getInt("iterations", 10)

    val result = parameters.iterate(numIterations) { currentParameters =>
      val newParameters = data
        .map(new SubUpdate).withBroadcastSet(currentParameters, "parameters")
        .reduce { (p1, p2) =>
          val result = p1._1 + p2._1
          (result, p1._2 + p2._2)
        }
        .map { x => x._1.div(x._2) }
      newParameters
    }

    if (params.has("output")) {
      result.writeAsText(params.get("output"))
      env.execute("Scala Linear Regression example")
    } else {
      println("Printing result to stdout. Use --output to specify output path.")
      result.print()
    }
  }

  /**
   * A simple data sample, x means the input, and y means the target.
   */
  case class Data(var x: Double, var y: Double)

  /**
   * A set of parameters -- theta0, theta1.
   */
  case class Params(theta0: Double, theta1: Double) {
    def div(a: Int): Params = {
      Params(theta0 / a, theta1 / a)
    }

    def + (other: Params) = {
      Params(theta0 + other.theta0, theta1 + other.theta1)
    }
  }

  // *************************************************************************
  //     USER FUNCTIONS
  // *************************************************************************

  /**
   * Compute a single BGD type update for every parameters.
   */
  class SubUpdate extends RichMapFunction[Data, (Params, Int)] {

    private var parameter: Params = null

    /** Reads the parameters from a broadcast variable into a collection. */
    override def open(parameters: Configuration) {
      val parameters = getRuntimeContext.getBroadcastVariable[Params]("parameters").asScala
      parameter = parameters.head
    }

    def map(in: Data): (Params, Int) = {
      val theta0 =
        parameter.theta0 - 0.01 * ((parameter.theta0 + (parameter.theta1 * in.x)) - in.y)
      val theta1 =
        parameter.theta1 - 0.01 * (((parameter.theta0 + (parameter.theta1 * in.x)) - in.y) * in.x)
      (Params(theta0, theta1), 1)
    }
  }
}
