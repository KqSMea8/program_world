import org.apache.spark.graphx._
val graph = GraphLoader.edgeListFile(sc, "cit-HepTh.txt")
graph.inDegrees.reduce((a,b) => if (a._2 > b._2) a else b)
import org.apache.spark.graphx._
val graph = GraphLoader.edgeListFile(sc, "cit-HepTh.txt")
val v = graph.pageRank(0.001).vertices
v.reduce((a,b) => if (a._2 > b._2) a else b)
curl --data-binary @/home/cloudera/sjsslashdot/target/scala-2.10/sjsslashdot_2.10-0.1-SNAPSHOT.jar localhost:8090/jars/sd
curl -d "" 'localhost:8090/contexts/sdcontext'
curl -d '{"src":0, "dst":1000}' 'localhost:8090/jobs?appName=sd&classPath=Degrees&context=sdcontext&sync=true&timeout=100'
curl -d '{"src":1000, "dst":1000}' 'localhost:8090/jobs?appName=sd&classPath=Degrees&context=sdcontext&sync=true&timeout=100'
curl -d '{"src":77182, "dst":77359}' 'localhost:8090/jobs?appName=sd&classPath=Degrees&context=sdcontext&sync=true&timeout=100'
absent.sqlContext.sql(
  "SELECT v1.attr, " +
  "       v3.attr, " +
  "       SUM(v1.outdegree * v2.outdegree * v3.outdegree) AS score " +
  "FROM   a " +
            "WHERE  v1.id=7662 " +
            "GROUP BY v1.attr, v3.attr " +
            "ORDER BY score DESC").collect
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

object helloworld {
  def main(args: Array[String]) {
    val sc = new SparkContext(new SparkConf().setMaster("local")
                                             .setAppName("helloworld"))
    val r = sc.makeRDD(Array("Hello", "World"))
    r.foreach(println(_))
    sc.stop
  }
}
val in = readRdfDf(sc, "yagoFactsInfluences.tsv")

in.edges.registerTempTable("e")
in.vertices.registerTempTable("v")

val in2 = GraphFrame(in.vertices.sqlContext.sql(
                       "SELECT v.id," +
                       "       FIRST(v.attr) AS attr," +
                       "       COUNT(*) AS outdegree " +
                       "FROM   v " +
                       "JOIN   e " +
                       "  ON   v.id=e.src " +
                       "GROUP BY v.id").cache,
                     in.edges)

val absent = in2.find("(v1)-[]->(v2); (v2)-[]->(v3); !(v1)-[]->(v3)")
absent.registerTempTable("a")

val present = in2.find("(v1)-[]->(v2); (v2)-[]->(v3); (v1)-[]->(v3)")
present.registerTempTable("p")

absent.sqlContext.sql(
  "SELECT v1 an," +
  "       SUM(v1.outdegree * v2.outdegree * v3.outdegree) AS ac " +
  "FROM   a " +
  "GROUP BY v1").registerTempTable("aa")

present.sqlContext.sql(
  "SELECT v1 pn," +
  "       SUM(v1.outdegree * v2.outdegree * v3.outdegree) AS pc " +
  "FROM   p " +
  "GROUP BY v1").registerTempTable("pa")

absent.sqlContext.sql("SELECT an," +
                      "       ac * pc/(ac+pc) AS score " +
                      "FROM   aa " +
                      "JOIN   pa" +
                      "  ON   an=pn " +
                      "ORDER BY score DESC").show
import org.apache.spark.SparkContext
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib.ShortestPaths

import com.typesafe.config.Config

import spark.jobserver._

object Degrees extends SparkJob {
  val filename = System.getProperty("user.home") + "/soc-Slashdot0811.txt"
  var g:Option[Graph[Int,Int]] = None

  override def runJob(sc:SparkContext, config:Config) = {
    if (!g.isDefined)
      g = Some(GraphLoader.edgeListFile(sc, filename).cache)

    val src = config.getString("src").toInt

    if (g.get.vertices.filter(_._1 == src).isEmpty)
      -1
    else {
      val r = ShortestPaths.run(g.get, Array(src))
                           .vertices
                           .filter(_._1 == config.getString("dst").toInt)

      if (r.isEmpty || r.first._2.toList.isEmpty) -1
      else r.first._2.toList.head._2
    }
  }

  override def validate(sc:SparkContext, config:Config) = SparkJobValid
}
import org.graphframes._
val gf = GraphFrame.fromGraphX(g2)
def time[A](f: => A) = {
  val s = System.nanoTime
  val ret = f
  println("time: " + (System.nanoTime-s)/1e9 + "sec")
  ret
}

time { g2.triangleCount.vertices.map(_._2).reduce(_ + _) }

time { gf.triangleCount.run.vertices.groupBy().sum("count")
         .collect()(0)(0).asInstanceOf[Long] }
import org.apache.spark.sql.Row
import org.apache.spark.sql.types._
def readRdfDf(sc:org.apache.spark.SparkContext, filename:String) = {
  val r = sc.textFile(filename).map(_.split("\t"))
  val v = r.map(_(1)).union(r.map(_(3))).distinct.zipWithIndex.map(
                   x => Row(x._2,x._1))
  // We must have an "id" column in the vertices DataFrame;
  // everything else is just properties we assign to the vertices
  val stv = StructType(StructField("id",LongType) ::
                       StructField("attr",StringType) :: Nil)
  val sqlContext = new org.apache.spark.sql.SQLContext(sc)
  val vdf = sqlContext.createDataFrame(v,stv)
  vdf.registerTempTable("v")
  val str = StructType(StructField("rdfId",StringType) ::
                       StructField("subject",StringType) ::
                       StructField("predicate",StringType) ::
                       StructField("object",StringType) :: Nil)
  sqlContext.createDataFrame(r.map(Row.fromSeq(_)),str)
            .registerTempTable("r")
  // We must have an "src" and "dst" columns in the edges DataFrame;
  // everything else is just properties we assign to the edges
  val edf = sqlContext.sql("SELECT vsubject.id AS src," +
                           "       vobject.id AS dst," +
                           "       predicate AS attr " +
                           "FROM   r " +
                           "JOIN   v AS vsubject" +
                           "  ON   subject=vsubject.attr " +
                           "JOIN   v AS vobject" +
                           "  ON   object=vobject.attr")
  GraphFrame(vdf,edf)
}
val gf = GraphFrame.fromGraphX(myGraph)
gf.find("(u)-[e1]->(v); (v)-[e2]->(w)")
  .filter("e1.attr = 'is-friends-with' AND " +
          "e2.attr = 'is-friends-with' AND " +
          "u.attr='Ann'")
  .select("w.attr")
  .collect
  .map(_(0).toString)
def sendMsg(ec: EdgeContext[Int,String,Int]): Unit = {
  ec.sendToDst(ec.srcAttr+1)
}

def mergeMsg(a: Int, b: Int): Int = {
  math.max(a,b)
}

def propagateEdgeCount(g:Graph[Int,String]):Graph[Int,String] = {
  val verts = g.aggregateMessages[Int](sendMsg, mergeMsg)
  val g2 = Graph(verts, g.edges)
  val check = g2.vertices.join(g.vertices).
       map(x => x._2._1 ?x._2._2).
       reduce(_ + _)
  if (check > 0)
    propagateEdgeCount(g2)
  else
    g
}
myGraph.vertices.saveAsObjectFile("myGraphVertices")
myGraph.edges.saveAsObjectFile("myGraphEdges")
val myGraph2 = Graph(
    sc.objectFile[Tuple2[VertexId,String]]("myGraphVertices"),
    sc.objectFile[Edge[String]]("myGraphEdges"))
import org.apache.hadoop.fs.{FileSystem, FileUtil, Path}
val conf = new org.apache.hadoop.conf.Configuration
conf.set("fs.defaultFS", "hdfs://localhost")
val fs = FileSystem.get(conf)
FileUtil.copyMerge(fs, new Path("/user/cloudera/myGraphVertices/"),
  fs, new Path("/user/cloudera/myGraphVerticesFile"), false, conf, null)
myGraph.vertices.map(x => {
    val mapper = new com.fasterxml.jackson.databind.ObjectMapper()
    mapper.registerModule(
        com.fasterxml.jackson.module.scala.DefaultScalaModule)
    val writer = new java.io.StringWriter()
    mapper.writeValue(writer, x)
    writer.toString
}).coalesce(1,true).saveAsTextFile("myGraphVertices")
import com.fasterxml.jackson.core.`type`.TypeReference
import com.fasterxml.jackson.module.scala.DefaultScalaModule

myGraph.vertices.mapPartitions(vertices => {
    val mapper = new com.fasterxml.jackson.databind.ObjectMapper()
    mapper.registerModule(DefaultScalaModule)
    val writer = new java.io.StringWriter()
    vertices.map(v => {writer.getBuffer.setLength(0)
                       mapper.writeValue(writer, v)
                       writer.toString})
}).coalesce(1,true).saveAsTextFile("myGraphVertices")

myGraph.edges.mapPartitions(edges => {
    val mapper = new com.fasterxml.jackson.databind.ObjectMapper();
    mapper.registerModule(DefaultScalaModule)
    val writer = new java.io.StringWriter()
    edges.map(e => {writer.getBuffer.setLength(0)
                    mapper.writeValue(writer, e)
                    writer.toString})
}).coalesce(1,true).saveAsTextFile("myGraphEdges")

val myGraph2 = Graph(
    sc.textFile("myGraphVertices").mapPartitions(vertices => {
        val mapper = new com.fasterxml.jackson.databind.ObjectMapper()
        mapper.registerModule(DefaultScalaModule)
        vertices.map(v => {
            val r = mapper.readValue[Tuple2[Integer,String]](v,
                new TypeReference[Tuple2[Integer,String]]{})
            (r._1.toLong, r._2)
        })
    }),
    sc.textFile("myGraphEdges").mapPartitions(edges => {
        val mapper = new com.fasterxml.jackson.databind.ObjectMapper()
        mapper.registerModule(DefaultScalaModule)
        edges.map(e => mapper.readValue[Edge[String]](e,
            new TypeReference[Edge[String]]{}))
    })
)
def toGexf[VD,ED](g:Graph[VD,ED]) =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
    "<gexf xmlns=\"http://www.gexf.net/1.2draft\" version=\"1.2\">\n" +
    "  <graph mode=\"static\" defaultedgetype=\"directed\">\n" +
    "    <nodes>\n" +
    g.vertices.map(v => "      <node id=\"" + v._1 + "\" label=\"" +
                        v._2 + "\" />\n").collect.mkString +
    "    </nodes>\n" +
    "    <edges>\n" +
    g.edges.map(e => "      <edge source=\"" + e.srcId +
                     "\" target=\"" + e.dstId + "\" label=\"" + e.attr +
                     "\" />\n").collect.mkString +
    "    </edges>\n" +
    "  </graph>\n" +
    "</gexf>"

val pw = new java.io.PrintWriter("myGraph.gexf")
pw.write(toGexf(myGraph))
pw.close
val pw = new java.io.PrintWriter("gridGraph.gexf")
pw.write(toGexf(util.GraphGenerators.gridGraph(sc, 4, 4)))
pw.close
val pw = new java.io.PrintWriter("starGraph.gexf")
pw.write(toGexf(util.GraphGenerators.starGraph(sc, 8)))
pw.close
val logNormalGraph = util.GraphGenerators.logNormalGraph(sc, 15)
val pw = new java.io.PrintWriter("logNormalGraph.gexf")
pw.write(toGexf(logNormalGraph))
pw.close
logNormalGraph.aggregateMessages[Int](
    _.sendToSrc(1), _ + _).map(_._2).collect.sorted
import org.apache.spark.graphx._

val myVertices = sc.makeRDD(Array((1L, "Ann"), (2L, "Bill"),
 (3L, "Charles"), (4L, "Diane"), (5L, "Went to gym this morning")))

val myEdges = sc.makeRDD(Array(Edge(1L, 2L, "is-friends-with"),
 Edge(2L, 3L, "is-friends-with"), Edge(3L, 4L, "is-friends-with"),
 Edge(4L, 5L, "Likes-status"), Edge(3L, 5L, "Wrote-status")))

val myGraph = Graph(myVertices, myEdges)

myGraph.vertices.collect
val pw = new java.io.PrintWriter("rmatGraph.gexf")
pw.write(toGexf(util.GraphGenerators.rmatGraph(sc, 32, 60)))
pw.close
val g = Pregel(myGraph.mapVertices((vid,vd) => 0), 0,
               activeDirection = EdgeDirection.Out)(
               (id:VertexId,vd:Int,a:Int) => math.max(vd,a),
               (et:EdgeTriplet[Int,String]) =>
                    Iterator((et.dstId, et.srcAttr+1)),
               (a:Int,b:Int) => math.max(a,b))
g.vertices.collect
myGraph.edges.collectmyGraph.triplets.collectmyGraph.mapTriplets(t => (t.attr, t.attr=="is-friends-with" &&
 t.srcAttr.toLowerCase.contains("a"))).triplets.collect
myGraph.aggregateMessages[Int](_.sendToSrc(1), _ + _).collectmyGraph.aggregateMessages[Int](_.sendToSrc(1),
 _ + _).join(myGraph.vertices).collect
myGraph.aggregateMessages[Int](_.sendToSrc(1),
 _ + _).join(myGraph.vertices).map(_._2.swap).collect
myGraph.aggregateMessages[Int](_.sendToSrc(1),
 _ + _).rightOuterJoin(myGraph.vertices).map(_._2.swap).collect
myGraph.aggregateMessages[Int](_.sendToSrc(1),
 _ + _).rightOuterJoin(myGraph.vertices).map(
 x => (x._2._2, x._2._1.getOrElse(0))).collect
import org.apache.spark.graphx._
val g = GraphLoader.edgeListFile(sc, "cit-HepTh.txt")
g.personalizedPageRank(9207016, 0.001)
 .vertices
 .filter(_._1 != 9207016)
 .reduce((a,b) => if (a._2 > b._2) a else b)
import org.apache.spark.graphx._
val g = GraphLoader.edgeListFile(sc, "soc-Slashdot0811.txt").cache
val g2 = Graph(g.vertices, g.edges.map(e =>
        if (e.srcId < e.dstId) e else new Edge(e.dstId, e.srcId, e.attr))).
    partitionBy(PartitionStrategy.RandomVertexCut)
(0 to 6).map(i => g2.subgraph(vpred =
        (vid,_) => vid >= i*10000 && vid < (i+1)*10000).
    triangleCount.vertices.map(_._2).reduce(_ + _))
lib.ShortestPaths.run(myGraph,Array(3)).vertices.collect
val g = Graph(sc.makeRDD((1L to 7L).map((_,""))),
    sc.makeRDD(Array(Edge(2L,5L,""), Edge(5L,3L,""), Edge(3L,2L,""),
                     Edge(4L,5L,""), Edge(6L,7L,"")))).cache
g.connectedComponents.vertices.map(_.swap).groupByKey.map(_._2).collect
// returns the userId from a file path with the format
//   <path>/<userId>.egonet
def extract(s: String) = {
    val Pattern = """^.*?(\d+).egonet""".r
    val Pattern(num) = s
    num
}

// Processes a line from an egonet file to return a
// Array of edges in a tuple
def get_edges_from_line(line: String): Array[(Long, Long)] = {
    val ary = line.split(":")
    val srcId = ary(0).toInt
    val dstIds = ary(1).split(" ")
    val edges = for {
        dstId <- dstIds
        if (dstId != "")
      } yield {
        (srcId.toLong, dstId.toLong)
      }
      if (edges.size > 0) edges else Array((srcId, srcId))
}

// Constructs Edges tuples from an egonet file
// contents
def make_edges(contents: String) = {
    val lines = contents.split("\n")
    val unflat = for {
      line <- lines
    } yield {
      get_edges_from_line(line)
    }
    val flat = unflat.flatten
    flat
}

// Constructs a graph from Edge tuples
// and runs connectedComponents returning
// the results as a string
def get_circles(flat: Array[(Long, Long)]) = {
    val edges = sc.makeRDD(flat)
    val g = Graph.fromEdgeTuples(edges,1)
    val cc = g.connectedComponents()
    cc.vertices.map(x => (x._2, Array(x._1))).
        reduceByKey( (a,b) => a ++ b).
        values.map(_.mkString(" ")).collect.mkString(";")
}

val egonets = sc.wholeTextFiles("socialcircles/data/egonets")
val egonet_numbers = egonets.map(x => extract(x._1)).collect
val egonet_edges   = egonets.map(x => make_edges(x._2)).collect
val egonet_circles = egonet_edges.toList.map(x => get_circles(x))
println("UserId,Prediction")
val result = egonet_numbers.zip(egonet_circles).map(x => x._1 + "," + x._2)
println(result.mkString("\n"))
g.stronglyConnectedComponents(10).vertices.map(_.swap).groupByKey.
    map(_._2).collect
val v = sc.makeRDD(Array((1L,""), (2L,""), (3L,""), (4L,""), (5L,""),
 (6L,""), (7L,""), (8L,"")))
val e = sc.makeRDD(Array(Edge(1L,2L,""), Edge(2L,3L,""), Edge(3L,4L,""),
 Edge(4L,1L,""), Edge(1L,3L,""), Edge(2L,4L,""), Edge(4L,5L,""),
 Edge(5L,6L,""), Edge(6L,7L,""), Edge(7L,8L,""), Edge(8L,5L,""),
 Edge(5L,7L,""), Edge(6L,8L,"")))
lib.LabelPropagation.run(Graph(v,e),5).vertices.collect.
 sortWith(_._1<_._1)
import org.apache.spark.graphx._
def dijkstra[VD](g:Graph[VD,Double], origin:VertexId) = {
  var g2 = g.mapVertices(
    (vid,vd) => (false, if (vid == origin) 0 else Double.MaxValue))

  for (i <- 1L to g.vertices.count-1) {
    val currentVertexId =
      g2.vertices.filter(!_._2._1)
        .fold((0L,(false,Double.MaxValue)))((a,b) =>
           if (a._2._2 < b._2._2) a else b)
        ._1

    val newDistances = g2.aggregateMessages[Double](
        ctx => if (ctx.srcId == currentVertexId)
                 ctx.sendToDst(ctx.srcAttr._2 + ctx.attr),
        (a,b) => math.min(a,b))

    g2 = g2.outerJoinVertices(newDistances)((vid, vd, newSum) =>
      (vd._1 || vid == currentVertexId,
       math.min(vd._2, newSum.getOrElse(Double.MaxValue))))
  }

  g.outerJoinVertices(g2.vertices)((vid, vd, dist) =>
    (vd, dist.getOrElse((false,Double.MaxValue))._2))
}
val myVertices = sc.makeRDD(Array((1L, "A"), (2L, "B"), (3L, "C"),
  (4L, "D"), (5L, "E"), (6L, "F"), (7L, "G")))
val myEdges = sc.makeRDD(Array(Edge(1L, 2L, 7.0), Edge(1L, 4L, 5.0),
  Edge(2L, 3L, 8.0), Edge(2L, 4L, 9.0), Edge(2L, 5L, 7.0),
  Edge(3L, 5L, 5.0), Edge(4L, 5L, 15.0), Edge(4L, 6L, 6.0),
  Edge(5L, 6L, 8.0), Edge(5L, 7L, 9.0), Edge(6L, 7L, 11.0)))
val myGraph = Graph(myVertices, myEdges)

dijkstra(myGraph, 1L).vertices.map(_._2).collect
import org.apache.spark.graphx._
def dijkstra[VD](g:Graph[VD,Double], origin:VertexId) = {
  var g2 = g.mapVertices(
    (vid,vd) => (false, if (vid == origin) 0 else Double.MaxValue,
                 List[VertexId]()))

  for (i <- 1L to g.vertices.count-1) {
    val currentVertexId =
      g2.vertices.filter(!_._2._1)
        .fold((0L,(false,Double.MaxValue,List[VertexId]())))((a,b) =>
           if (a._2._2 < b._2._2) a else b)
        ._1

    val newDistances = g2.aggregateMessages[(Double,List[VertexId])](
        ctx => if (ctx.srcId == currentVertexId)
                 ctx.sendToDst((ctx.srcAttr._2 + ctx.attr,
                                ctx.srcAttr._3 :+ ctx.srcId)),
        (a,b) => if (a._1 < b._1) a else b)

    g2 = g2.outerJoinVertices(newDistances)((vid, vd, newSum) => {
      val newSumVal =
        newSum.getOrElse((Double.MaxValue,List[VertexId]()))
      (vd._1 || vid == currentVertexId,
       math.min(vd._2, newSumVal._1),
       if (vd._2 < newSumVal._1) vd._3 else newSumVal._2)})
  }

  g.outerJoinVertices(g2.vertices)((vid, vd, dist) =>
    (vd, dist.getOrElse((false,Double.MaxValue,List[VertexId]()))
             .productIterator.toList.tail))
}
dijkstra(myGraph, 1L).vertices.map(_._2).collectdef greedy[VD](g:Graph[VD,Double], origin:VertexId) = {
  var g2 = g.mapVertices((vid,vd) => vid == origin)
            .mapTriplets(et => (et.attr,false))
  var nextVertexId = origin
  var edgesAreAvailable = true

  do {
    type tripletType = EdgeTriplet[Boolean,Tuple2[Double,Boolean]]

    val availableEdges =
      g2.triplets
        .filter(et => !et.attr._2
                      && (et.srcId == nextVertexId && !et.dstAttr
                          || et.dstId == nextVertexId && !et.srcAttr))

    edgesAreAvailable = availableEdges.count > 0

    if (edgesAreAvailable) {
      val smallestEdge = availableEdges
          .min()(new Ordering[tripletType]() {
             override def compare(a:tripletType, b:tripletType) = {
               Ordering[Double].compare(a.attr._1,b.attr._1)
             }
           })

      nextVertexId = Seq(smallestEdge.srcId, smallestEdge.dstId)
                     .filter(_ != nextVertexId)(0)

      g2 = g2.mapVertices((vid,vd) => vd || vid == nextVertexId)
             .mapTriplets(et => (et.attr._1,
                                 et.attr._2 ||
                                   (et.srcId == smallestEdge.srcId
                                    && et.dstId == smallestEdge.dstId)))
    }
  } while(edgesAreAvailable)

  g2
}

greedy(myGraph,1L).triplets.filter(_.attr._2).map(et=>(et.srcId, et.dstId))
                  .collect
def minSpanningTree[VD:scala.reflect.ClassTag](g:Graph[VD,Double]) = {
  var g2 = g.mapEdges(e => (e.attr,false))

  for (i <- 1L to g.vertices.count-1) {
    val unavailableEdges =
      g2.outerJoinVertices(g2.subgraph(_.attr._2)
                             .connectedComponents
                             .vertices)((vid,vd,cid) => (vd,cid))
        .subgraph(et => et.srcAttr._2.getOrElse(-1) ==
                          et.dstAttr._2.getOrElse(-2))
        .edges
        .map(e => ((e.srcId,e.dstId),e.attr))

    type edgeType = Tuple2[Tuple2[VertexId,VertexId],Double]

    val smallestEdge =
      g2.edges
        .map(e => ((e.srcId,e.dstId),e.attr))
        .leftOuterJoin(unavailableEdges)
        .filter(x => !x._2._1._2 && x._2._2.isEmpty)
        .map(x => (x._1, x._2._1._1))
        .min()(new Ordering[edgeType]() {
           override def compare(a:edgeType, b:edgeType) = {
             val r = Ordering[Double].compare(a._2,b._2)
             if (r == 0)
               Ordering[Long].compare(a._1._1, b._1._1)
             else
               r
           }
         })

    g2 = g2.mapTriplets(et =>
      (et.attr._1, et.attr._2 || (et.srcId == smallestEdge._1._1
                                  && et.dstId == smallestEdge._1._2)))
  }

  g2.subgraph(_.attr._2).mapEdges(_.attr._1)
}

minSpanningTree(myGraph).triplets.map(et =>
 (et.srcAttr,et.dstAttr)).collect
val dist = sc.textFile("animal_distances.txt")
val verts = dist.map(_.split(",")(0)).distinct. \\#A
    map(x => (x.hashCode.toLong,x)) \\#B
val edges = dist.map(x => x.split(",")).
    map(x => Edge(x(0).hashCode.toLong, \\#B
                 x(1).hashCode.toLong, \\#B
                 x(2).toDouble))
val distg = Graph(verts, edges)
val mst = minSpanningTree(distg) \\#C
val pw = new java.io.PrintWriter("animal_taxonomy.gexf")
pw.write(toGexf(mst))
pw.close
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.apache.spark.mllib.clustering.PowerIterationClustering
import org.apache.spark.graphx._

import java.awt.image.BufferedImage
import java.awt.image.DataBufferInt
import java.awt.Color
import java.io.File

import javax.imageio.ImageIO

object PIC {
  def main(args: Array[String]) {
    val sc = new SparkContext(new SparkConf().setMaster("local")
                                             .setAppName("PIC"))
    val im = ImageIO.read(new File("105053.jpg"))
    val ims = im.getScaledInstance(im.getWidth/8, im.getHeight/8,
                                   java.awt.Image.SCALE_AREA_AVERAGING)
    val width = ims.getWidth(null)
    val height = ims.getHeight(null)
    val bi = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
    bi.getGraphics.drawImage(ims, 0, 0, null)
    val r = sc.makeRDD(bi.getData.getDataBuffer
                         .asInstanceOf[DataBufferInt].getData)
              .zipWithIndex.cache
    val g = Graph.fromEdges(r.cartesian(r).cache.map(x => {
      def toVec(a:Tuple2[Int,Long]) = {
        val c = new Color(a._1)
        Array[Double](c.getRed, c.getGreen, c.getBlue)
      }
      def cosineSimilarity(u:Array[Double], v:Array[Double]) = {
        val d = Math.sqrt(u.map(a => a*a).sum * v.map(a => a*a).sum)
        if (d == 0.0) 0.0 else
        u.zip(v).map(a => a._1 * a._2).sum / d
      }
      Edge(x._1._2, x._2._2, cosineSimilarity(toVec(x._1), toVec(x._2)))
    }).filter(e => e.attr > 0.5), 0.0).cache
    val m = new PowerIterationClustering().run(g)
    val colors = Array(Color.white.getRGB, Color.black.getRGB)
    val bi2 = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
    m.assignments
     .map(a => (a.id/width, (a.id%width, colors(a.cluster))))
     .groupByKey
     .map(a => (a._1, a._2.toList.sortBy(_._1).map(_._2).toArray))
     .collect
     .foreach(x => bi2.setRGB(0, x._1.toInt, width, 1, x._2, 0, width))
    ImageIO.write(bi2, "PNG", new File("out.png"));
    sc.stop
  }
}
import org.apache.spark.graphx._

case class knnVertex(classNum:Option[Int],
                     pos:Array[Double]) extends Serializable {
  def dist(that:knnVertex) = math.sqrt(
    pos.zip(that.pos).map(x => (x._1-x._2)*(x._1-x._2)).reduce(_ + _))
}

def knnGraph(a:Seq[knnVertex], k:Int) = {
  val a2 = a.zipWithIndex.map(x => (x._2.toLong, x._1)).toArray
  val v = sc.makeRDD(a2)
  val e = v.map(v1 => (v1._1, a2.map(v2 => (v2._1, v1._2.dist(v2._2)))
                                .sortWith((e,f) => e._2 < f._2)
                                .slice(1,k+1)
                                .map(_._1)))
           .flatMap(x => x._2.map(vid2 =>
             Edge(x._1, vid2,
                  1 / (1+a2(vid2.toInt)._2.dist(a2(x._1.toInt)._2)))))
  Graph(v,e)
}
import scala.util.Random
Random.setSeed(17L)
val n = 10
val a = (1 to n*2).map(i => {
  val x = Random.nextDouble;
  if (i <= n)
    knnVertex(if (i % n == 0) Some(0) else None, Array(x*50,
      20 + (math.sin(x*math.Pi) + Random.nextDouble / 2) * 25))
  else
    knnVertex(if (i % n == 0) Some(1) else None, Array(x*50 + 25,
      30 - (math.sin(x*math.Pi) + Random.nextDouble / 2) * 25))
})
import java.awt.Color
def toGexfWithViz(g:Graph[knnVertex,Double], scale:Double) = {
  val colors = Array(Color.red, Color.blue, Color.yellow, Color.pink,
                     Color.magenta, Color.green, Color.darkGray)
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
  "<gexf xmlns=\"http://www.gexf.net/1.2draft\" " +
        "xmlns:viz=\"http://www.gexf.net/1.1draft/viz\" " +
        "version=\"1.2\">\n" +
  "  <graph mode=\"static\" defaultedgetype=\"directed\">\n" +
  "    <nodes>\n" +
  g.vertices.map(v =>
    "      <node id=\"" + v._1 + "\" label=\"" + v._1 + "\">\n" +
    "        <viz:position x=\"" + v._2.pos(0) * scale +
              "\" y=\"" + v._2.pos(1) * scale + "\" />\n" +
    (if (v._2.classNum.isDefined)
       "        <viz:color r=\"" + colors(v._2.classNum.get).getRed +
                 "\" g=\"" + colors(v._2.classNum.get).getGreen +
                 "\" b=\"" + colors(v._2.classNum.get).getBlue + "\" />\n"
     else "") +
    "      </node>\n").collect.mkString +
  "    </nodes>\n" +
  "    <edges>\n" +
  g.edges.map(e => "      <edge source=\"" + e.srcId +
                   "\" target=\"" + e.dstId + "\" label=\"" + e.attr +
                   "\" />\n").collect.mkString +
  "    </edges>\n" +
  "  </graph>\n" +
  "</gexf>"
}
val g = knnGraph(a, 4)

val pw = new java.io.PrintWriter("knn.gexf")
pw.write(toGexfWithViz(g,10))
pw.close
def knnGraphApprox(a:Seq[knnVertex], k:Int) = {
  val a2 = a.zipWithIndex.map(x => (x._2.toLong, x._1)).toArray
  val v = sc.makeRDD(a2)
  val n = 3
  val minMax =
    v.map(x => (x._2.pos(0), x._2.pos(0), x._2.pos(1), x._2.pos(1)))
     .reduce((a,b) => (math.min(a._1,b._1), math.max(a._2,b._2),
                       math.min(a._3,b._3), math.max(a._4,b._4)))
  val xRange = minMax._2 - minMax._1
  val yRange = minMax._4 - minMax._3

  def calcEdges(offset: Double) =
    v.map(x => (math.floor((x._2.pos(0) - minMax._1)
                           / xRange * (n-1) + offset) * n
                  + math.floor((x._2.pos(1) - minMax._3)
                               / yRange * (n-1) + offset),
                x))
     .groupByKey(n*n)
     .mapPartitions(ap => {
       val af = ap.flatMap(_._2).toList
       af.map(v1 => (v1._1, af.map(v2 => (v2._1, v1._2.dist(v2._2)))
                              .toArray
                              .sortWith((e,f) => e._2 < f._2)
                              .slice(1,k+1)
                              .map(_._1)))
            .flatMap(x => x._2.map(vid2 => Edge(x._1, vid2,
               1 / (1+a2(vid2.toInt)._2.dist(a2(x._1.toInt)._2)))))
            .iterator
      })

  val e = calcEdges(0.0).union(calcEdges(0.5))
                        .distinct
                        .map(x => (x.srcId,x))
                        .groupByKey
                        .map(x => x._2.toArray
                                   .sortWith((e,f) => e.attr > f.attr)
                                   .take(k))
                        .flatMap(x => x)

  Graph(v,e)
}
import scala.collection.mutable.HashMap

def semiSupervisedLabelPropagation(g:Graph[knnVertex,Double],
                                   maxIterations:Int = 0) = {
  val maxIter = if (maxIterations == 0) g.vertices.count / 2
                else maxIterations

  var g2 = g.mapVertices((vid,vd) => (vd.classNum.isDefined, vd))
  var isChanged = true
  var i = 0

  do {
    val newV =
      g2.aggregateMessages[Tuple2[Option[Int],HashMap[Int,Double]]](
        ctx => {
          ctx.sendToSrc((ctx.srcAttr._2.classNum,
                         if (ctx.dstAttr._2.classNum.isDefined)
                           HashMap(ctx.dstAttr._2.classNum.get->ctx.attr)
                         else
                           HashMap[Int,Double]()))
          if (ctx.srcAttr._2.classNum.isDefined)
            ctx.sendToDst((None,
                           HashMap(ctx.srcAttr._2.classNum.get->ctx.attr)))
        },
        (a1, a2) => {
          if (a1._1.isDefined)
            (a1._1, HashMap[Int,Double]())
          else if (a2._1.isDefined)
            (a2._1, HashMap[Int,Double]())
          else
            (None, a1._2 ++ a2._2.map{
              case (k,v) => k -> (v + a1._2.getOrElse(k,0.0)) })
        }
      )

    val newVClassVoted = newV.map(x => (x._1,
      if (x._2._1.isDefined)
        x._2._1
      else if (x._2._2.size > 0)
        Some(x._2._2.toArray.sortWith((a,b) => a._2 > b._2)(0)._1)
      else None
    ))

    isChanged = g2.vertices.join(newVClassVoted)
                           .map(x => x._2._1._2.classNum != x._2._2)
                           .reduce(_ || _)

    g2 = g2.joinVertices(newVClassVoted)((vid, vd1, u) =>
      (vd1._1, knnVertex(u, vd1._2.pos)))

    i += 1
  } while (i < maxIter && isChanged)

  g2.mapVertices((vid,vd) => vd._2)
}
def knnPredict[E](g:Graph[knnVertex,E],pos:Array[Double]) =
  g.vertices
   .filter(_._2.classNum.isDefined)
   .map(x => (x._2.classNum.get, x._2.dist(knnVertex(None,pos))))
   .min()(new Ordering[Tuple2[Int,Double]] {
     override def compare(a:Tuple2[Int,Double],
                          b:Tuple2[Int,Double]): Int =
       a._2.compare(b._2)
    })
   ._1
val gs = semiSupervisedLabelPropagation(g)
knnPredict(gs, Array(30.0,30.0))
import org.apache.spark.graphx._

val edges = sc.makeRDD(Array(
  Edge(1L,11L,5.0),Edge(1L,12L,4.0),Edge(2L,12L,5.0),
  Edge(2L,13L,5.0),Edge(3L,11L,5.0),Edge(3L,13L,2.0),
  Edge(4L,11L,4.0),Edge(4L,12L,4.0)))

val conf = new lib.SVDPlusPlus.Conf(2,10,0,5,0.007,0.007,0.005,0.015)

val (g,mean) = lib.SVDPlusPlus.run(edges, conf)
def pred(g:Graph[(Array[Double], Array[Double], Double, Double),Double],
         mean:Double, u:Long, i:Long) = {
  val user = g.vertices.filter(_._1 == u).collect()(0)._2
  val item = g.vertices.filter(_._1 == i).collect()(0)._2
  mean + user._3 + item._3 +
    item._1.zip(user._2).map(x => x._1 * x._2).reduce(_ + _)
}
pred(g, mean, 4L, 13L)
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.clustering._
import org.apache.spark.rdd._

def bagsFromDocumentPerLine(filename:String) =
  sc.textFile(filename)
    .map(_.split(" ")
          .filter(x => x.length > 5 && x.toLowerCase != "reuter")
          .map(_.toLowerCase)
          .groupBy(x => x)
          .toList
          .map(x => (x._1, x._2.size)))

val rddBags:RDD[List[Tuple2[String,Int]]] =
  bagsFromDocumentPerLine("rcorpus")

val vocab:Array[Tuple2[String,Long]] =
  rddBags.flatMap(x => x)
         .reduceByKey(_ + _)
         .map(_._1)
         .zipWithIndex
         .collect

def codeBags(rddBags:RDD[List[Tuple2[String,Int]]]) =
  rddBags.map(x => (x ++ vocab).groupBy(_._1)
                               .filter(_._2.size > 1)
                               .map(x => (x._2(1)._2.asInstanceOf[Long]
                                                    .toInt,
                                          x._2(0)._2.asInstanceOf[Int]
                                                    .toDouble))
                               .toList)
         .zipWithIndex.map(x => (x._2, new SparseVector(
                                                vocab.size,
                                                x._1.map(_._1).toArray,
                                                x._1.map(_._2).toArray)
                                       .asInstanceOf[Vector]))

val model = new LDA().setK(5).run(codeBags(rddBags))
import org.apache.spark.graphx._
import org.apache.spark.mllib.classification.LogisticRegressionWithSGD

val trainV = sc.makeRDD(Array((1L, (0,1,false)), (2L, (0,0,false)),
  (3L, (1,0,false)), (4L, (0,0,false)), (5L, (0,0,false)),
  (6L, (0,0,false)), (7L, (0,0,false)), (8L, (0,0,false)),
  (9L, (0,1,false)), (10L,(0,0,false)), (11L,(5,2,true)),
  (12L,(0,0,true)),  (13L,(1,0,false))))

val trainE = sc.makeRDD(Array(Edge(1L,9L,""), Edge(2L,3L,""),
  Edge(3L,10L,""), Edge(4L,9L,""), Edge(4L,10L,""), Edge(5L,6L,""),
  Edge(5L,11L,""), Edge(5L,12L,""), Edge(6L,11L,""), Edge(6L,12L,""),
  Edge(7L,8L,""), Edge(7L,11L,""), Edge(7L,12L,""), Edge(7L,13L,""),
  Edge(8L,11L,""), Edge(8L,12L,""), Edge(8L,13L,""), Edge(9L,2L,""),
  Edge(9L,13L,""), Edge(10L,13L,""), Edge(12L,9L,"")))

val trainG = Graph(trainV, trainE)
import org.apache.spark.graphx.lib.PageRank
import org.apache.spark.mllib.linalg.DenseVector
import org.apache.spark.mllib.regression.LabeledPoint
def augment(g:Graph[Tuple3[Int,Int,Boolean],String]) =
  g.vertices.join(
    PageRank.run(trainG, 1).vertices.join(
      PageRank.run(trainG, 5).vertices
    ).map(x => (x._1,x._2._2/x._2._1))
  ).map(x => LabeledPoint(
    if (x._2._1._3) 1 else 0,
    new DenseVector(Array(x._2._1._1, x._2._1._2, x._2._2))))
val trainSet = augment(trainG)
val model = LogisticRegressionWithSGD.train(trainSet, 10)
import org.apache.spark.rdd.RDD

def perf(s:RDD[LabeledPoint]) = 100 * (s.count -
  s.map(x => math.abs(model.predict(x.features)-x.label)).reduce(_ + _)) /
  s.count

perf(trainSet)
val testV = sc.makeRDD(Array((1L, (0,1,false)), (2L, (0,0,false)),
  (3L, (1,0,false)), (4L, (5,4,true)), (5L, (0,1,false)),
  (6L, (0,0,false)), (7L, (1,1,true))))

val testE = sc.makeRDD(Array(Edge(1L,5L,""), Edge(2L,5L,""),
  Edge(3L,6L,""), Edge(4L,6L,""), Edge(5L,7L,""), Edge(6L,7L,"")))

perf(augment(Graph(testV,testE)))
def pred(v:Map[VertexId, (Array[Double], Array[Double], Double, Double)],
         mean:Double, u:Long, i:Long) = {
  val user = v.getOrElse(u, (Array(0.0), Array(0.0), 0.0, 0.0))
  val item = v.getOrElse(i, (Array(0.0), Array(0.0), 0.0, 0.0))
  mean + user._3 + item._3 + item._1.zip(user._2).map(
    x => x._1*x._2).reduce(_ + _)
}

def vertexMap(g:Graph[(Array[Double], Array[Double],
                       Double, Double),Double]) =
  g.vertices.collect.map(v => v._1 -> v._2).toMap
val vm = vertexMap(gs)
val cid = gf.vertices.filter(_._2 == "<Canada>").first._1
val r = vr.map(v => (v,pred(vm,mean,cid,v)))

val maxKey = r.max()(new Ordering[Tuple2[VertexId, Double]]() {
  override def compare(x: (VertexId, Double), y: (VertexId, Double)): Int =
      Ordering[Double].compare(x._2, y._2)
})._1

gf.vertices.filter(_._1 == maxKey).collect
import scala.reflect.ClassTag
def clusteringCoefficient[VD:ClassTag,ED:ClassTag](g:Graph[VD,ED]) = {
  val numTriplets =
    g.aggregateMessages[Set[VertexId]](
        et => { et.sendToSrc(Set(et.dstId));
                et.sendToDst(Set(et.srcId)) },
        (a,b) => a ++ b)
     .map(x => {val s = (x._2 - x._1).size; s*(s-1) / 2})
     .reduce(_ + _)

  if (numTriplets == 0) 0.0 else
    g.triangleCount.vertices.map(_._2).reduce(_ + _) /
      numTriplets.toFloat
}
import org.apache.spark.graphx._
val g = GraphLoader.edgeListFile(sc, System.getProperty("user.home") +
  "/Downloads/facebook/0.edges")
val feat = sc.textFile(System.getProperty("user.home") +
  "/Downloads/facebook/0.feat").map(x =>
  (x.split(" ")(0).toLong, x.split(" ")(78).toInt == 1))
val g2 = g.outerJoinVertices(feat)((vid,vd,u) => u.get)

clusteringCoefficient(g2)

clusteringCoefficient(g2.subgraph(_ => true, (vid,vd) => vd))

clusteringCoefficient(g2.subgraph(_ => true, (vid,vd) => !vd))
import scala.reflect.ClassTag

def removeSingletons[VD:ClassTag,ED:ClassTag](g:Graph[VD,ED]) =
  Graph(g.triplets.map(et => (et.srcId,et.srcAttr))
                  .union(g.triplets.map(et => (et.dstId,et.dstAttr)))
                  .distinct,
        g.edges)
val vertices = sc.makeRDD(Seq(
	(1L, "Ann"), (2L, "Bill"), (3L, "Charles"), (4L, "Dianne")))
val edges = sc.makeRDD(Seq(
	Edge(1L,2L, "is-friends-with"),Edge(1L,3L, "is-friends-with"),
	Edge(4L,1L, "has-blocked"),Edge(2L,3L, "has-blocked"),
	Edge(3L,4L, "has-blocked")))
val originalGraph = Graph(vertices, edges)
val subgraph = originalGraph.subgraph(et => et.attr == "is-friends-with")

// show vertices of subgraph ?includes Dianne
subgraph.vertices.foreach(println)

// now call removeSingletons and show the resulting vertices
removeSingletons(subgraph).vertices.foreach(println)
import org.apache.spark.graphx._

def mergeGraphs(g1:Graph[String,String], g2:Graph[String,String]) = {
  val v = g1.vertices.map(_._2).union(g2.vertices.map(_._2)).distinct
                     .zipWithIndex
  def edgesWithNewVertexIds(g:Graph[String,String]) =
    g.triplets
     .map(et => (et.srcAttr, (et.attr,et.dstAttr)))
     .join(v)
     .map(x => (x._2._1._2, (x._2._2,x._2._1._1)))
     .join(v)
     .map(x => new Edge(x._2._1._1,x._2._2,x._2._1._2))
  Graph(v.map(_.swap),
        edgesWithNewVertexIds(g1).union(edgesWithNewVertexIds(g2)))
}
val philosophers = Graph(
sc.makeRDD(Seq(
    (1L, "Aristotle"),(2L,"Plato"),(3L,"Socrates"),(4L,"male"))),
sc.makeRDD(Seq(
    Edge(2L,1L,"Influences"),
    Edge(3L,2L,"Influences"),
    Edge(3L,4L,"hasGender"))))

val rdfGraph = Graph(
    sc.makeRDD(Seq(
        (1L,"wordnet_philosophers"),(2L,"Aristotle"),
        (3L,"Plato"),(4L,"Socrates"))),
    sc.makeRDD(Seq(
        Edge(2L,1L,"rdf:type"),
        Edge(3L,1L,"rdf:type"),
        Edge(4L,1L,"rdf:type"))))

val combined = mergeGraphs(philosophers, rdfGraph)

combined.triplets.foreach(
       t => println(s"${t.srcAttr} --- ${t.attr} ---> ${t.dstAttr}"))
def readRdf(sc:org.apache.spark.SparkContext, filename:String) = {
  val r = sc.textFile(filename).map(_.split("\t"))
  val v = r.map(_(1)).union(r.map(_(3))).distinct.zipWithIndex
  Graph(v.map(_.swap),
        r.map(x => (x(1),(x(2),x(3))))
         .join(v)
         .map(x => (x._2._1._2,(x._2._2,x._2._1._1)))
         .join(v)
         .map(x => new Edge(x._2._1._1, x._2._2, x._2._1._2)))
}
import org.apache.spark.graphx._
import org.apache.spark.{SparkContext, SparkConf}

import edu.berkeley.cs.amplab.spark.indexedrdd.IndexedRDD
import edu.berkeley.cs.amplab.spark.indexedrdd.IndexedRDD._

object readrdf {
  def readRdfIndexed(sc:SparkContext, filename:String) = {
    val r = sc.textFile(filename).map(_.split("\t"))
    val v = IndexedRDD(r.map(_(1)).union(r.map(_(3))).distinct
                        .zipWithIndex)
    Graph(v.map(_.swap),
          IndexedRDD(IndexedRDD(r.map(x => (x(1),(x(2),x(3)))))
           .innerJoin(v)((id, a, b) => (a,b))
           .map(x => (x._2._1._2,(x._2._2,x._2._1._1))))
           .innerJoin(v)((id, a, b) => (a,b))
           .map(x => new Edge(x._2._1._1, x._2._2, x._2._1._2)))
  }

  def main(args: Array[String]) {
    val sc = new SparkContext(
      new SparkConf().setMaster("local").setAppName("readrdf"))
    val t0 = System.currentTimeMillis
    val r = readRdf(sc, 搚agoFacts.tsv")
    println("#edges=" + r.edges.count +
            " #vertices=" + r.vertices.count)
    val t1 = System.currentTimeMillis
    println("Elapsed: " + ((t1-t0) / 1000) + "sec")
    sc.stop
  }
}
val gf = readRdf(sc, "yagoFacts.tsv").subgraph(_.attr == "<exports>")
val e = gf.edges.map(e => Edge(e.srcId, e.dstId, 1.0))
val (gs,mean) = lib.SVDPlusPlus.run(e,
      new lib.SVDPlusPlus.Conf(2,10,0,5,0.007,0.007,0.005,0.015))
val gc = removeSingletons(gf.subgraph(et => et.srcAttr == "<Canada>"))
val vr = e.map(x => (x.dstId,""))
          .distinct
          .subtractByKey(gc.vertices)
          .map(_._1)
val rdd = sc.makeRDD(1 to 10000)
rdd
  .filter(_ % 4 == 0)
  .map(Math.sqrt(_))
  .map(el => (el.toInt,el))
  .groupByKey
  .collect
val iterations = 500
var g = Graph.fromEdges(sc.makeRDD(
       Seq(Edge(1L,3L,1),Edge(2L,4L,1),Edge(3L,4L,1))),1)
for (i <- 1 to iterations) {
  println("Iteration: " + i)
  val newGraph: Graph[Int, Int] =
      g.mapVertices((vid,vd)  => (vd * i)/17)
  g = g.outerJoinVertices[Int, Int](newGraph.vertices) {
                   (vid, vd, newData) => newData.getOrElse(0)
      }
}
g.vertices.collect.foreach(println)
sc.setCheckpointDir("/tmp/spark-checkpoint")
var updateCount = 0
val checkpointInterval = 50

def update(newData: Graph[Int, Int]): Unit = {
  newData.persist()
  updateCount += 1
  if (updateCount % checkpointInterval == 0) {
    newData.checkpoint()
  }
}

val iterations = 500
var g = Graph.fromEdges(sc.makeRDD(
       Seq(Edge(1L,3L,1),Edge(2L,4L,1),Edge(3L,4L,1))),1)
update(g)
g.vertices.count
for (i <- 1 to iterations) {
  println("Iteration: " + i)
  val newGraph: Graph[Int, Int] = g.mapVertices((vid,vd)  => (vd * i)/17)
  g = g.outerJoinVertices[Int, Int](newGraph.vertices) {
      (vid, vd, newData) => newData.getOrElse(0) }
  update(g)
  g.vertices.count
}
g.vertices.collect.foreach(println)
case class Person(name: String, age: Int)

val conf = new SparkConf()
conf.set("spark.serializer",
         "org.apache.spark.serializer.KryoSerializer")
conf.registerKryoClasses(Array(classOf[Person]))
val sc = new SparkContext(conf)
val rdd = sc.makeRDD(1 to 1000000).
             map(el => Person("John Smith", 42))
rdd.persist(StorageLevel.MEMORY_ONLY_SER)
rdd.count
