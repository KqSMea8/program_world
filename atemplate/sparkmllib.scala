




import org.apache.spark.mllib.classification.LogisticRegressionWithSGD
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkContext, SparkConf}

object GastriCcancer {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("LogisticRegression4")                              //设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例

    val data = MLUtils.loadLibSVMFile(sc, "c://wa.txt")				//获取数据集
    val splits = data.randomSplit(Array(0.7, 0.3), seed = 11L)			//对数据集切分
    val parsedData = splits(0)									//分割训练数据
    val parseTtest = splits(1)									//分割测试数据
    val model = LogisticRegressionWithSGD.train(parsedData,50)		//训练模型

    val predictionAndLabels = parseTtest.map { 					//计算测试值
      case LabeledPoint(label, features) =>						//计算测试值
        val prediction = model.predict(features)						//计算测试值
        (prediction, label)										//存储测试和预测值
    }

    val metrics = new MulticlassMetrics(predictionAndLabels)			//创建验证类
    val precision = metrics.precision								//计算验证值
    println("Precision = " + precision)							//打印验证值

    val patient = Vectors.dense(Array(70,3,180.0,4,3))				//计算患者可能性
    if(patient == 1) println("患者的胃癌有几率转移。")				//做出判断
    else println("患者的胃癌没有几率转移。")					//做出判断
  }
}

import org.apache.spark.mllib.classification.SVMWithSGD
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.{SparkConf, SparkContext}

object SVM {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("SVM")                              			//设定名称
    val sc = new SparkContext(conf)                                //创建环境变量实例
    val data = sc.textFile("c:/u.txt")							  	//获取数据集路径
    val parsedData = data.map { line =>							//开始对数据集处理
      val parts = line.split('|')									//根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).map(_.toDouble))
    }.cache()                                                      //转化数据格式
    val model = SVMWithSGD.train(parsedData, 10)				//训练数据模型
    println(model.weights)									//打印权重
    println(model.intercept)									//打印截距
  }
}

import org.apache.spark.mllib.classification. SVMWithSGD
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkContext, SparkConf}

object GastriCcancer {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("SVMTest ")                        		      //设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例

    val data = MLUtils.loadLibSVMFile(sc, "c://wa.txt")				//获取数据集
    val splits = data.randomSplit(Array(0.7, 0.3), seed = 11L)			//对数据集切分
    val parsedData = splits(0)									//分割训练数据
    val parseTtest = splits(1)									//分割测试数据
    val model = SVMWithSGD.train(parsedData,50)					//训练模型
    val predictionAndLabels = parseTtest.map { 					//计算测试值
      case LabeledPoint(label, features) =>						//计算测试值
        val prediction = model.predict(features)						//计算测试值
        (prediction, label)										//存储测试和预测值
    }

    val metrics = new MulticlassMetrics(predictionAndLabels)			//创建验证类
    val precision = metrics.precision								//计算验证值
    println("Precision = " + precision)							//打印验证值

    val patient = Vectors.dense(Array(70,3,180.0,4,3))				//计算患者可能性
    if(patient == 1) println("患者的胃癌有几率转移。")				//做出判断
    else println("患者的胃癌没有几率转移。")					//做出判断
  }
}


import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.util.MLUtils

object DT {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("DT")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://DTree.txt")				//输入数据集

    val numClasses = 2 										//设定分类数量
    val categoricalFeaturesInfo = Map[Int, Int]()					//设定输入格式
    val impurity = "entropy"									//设定信息增益计算方式
    val maxDepth = 5										//设定树高度
    val maxBins = 3											//设定分裂数据集

    val model = DecisionTree.trainClassifier(data, numClasses, categoricalFeaturesInfo,
      impurity, maxDepth, maxBins)								//建立模型
    println(model.topNode)									//打印决策树信息

  }
}

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.util.MLUtils

object RFDTree {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("DT2")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://DTree.txt")				//输入数据集

    val numClasses = 2										//设定分类的数量
    val categoricalFeaturesInfo = Map[Int, Int]()					//设置输入数据格式
    val numTrees = 3 								   //设置随机雨林中决策树的数目
    val featureSubsetStrategy = "auto"							//设置属性在节点计算数
    val impurity = "entropy"									//设定信息增益计算方式
    val maxDepth = 5										//设定树高度
    val maxBins = 3											//设定分裂数据集

    val model = RandomForest.trainClassifier(data, numClasses, categoricalFeaturesInfo,
      numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)	//建立模型

    model.trees.foreach(println)								//打印每棵树的相信信息
  }
}


import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.BoostingStrategy
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel
import org.apache.spark.mllib.util.MLUtils

object GDTree {

  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("GDTree")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://DTree.txt")				//输入数据集

    val boostingStrategy = BoostingStrategy.defaultParams("Classification")	//创建算法类型
    boostingStrategy.numIterations = 3 							//迭代次数
    boostingStrategy.treeStrategy.numClasses = 2					//分类数目
    boostingStrategy.treeStrategy.maxDepth = 5					//决策树最高层数
    boostingStrategy.treeStrategy.categoricalFeaturesInfo = Map[Int, Int]()	//数据格式

    val model = GradientBoostedTrees.train(data, boostingStrategy)	//训练模型
  }
}



import org.apache.spark.mllib.regression.IsotonicRegression
import org.apache.spark.{SparkConf, SparkContext}

object IS {
  def main(args: Array[String]) {

    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("IS")                              				//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://u.txt")				//输入数据集

    val parsedData = data.map { line =>							//处理数据格式
      val parts = line.split(',').map(_.toDouble)						//切分数据
      (parts(0), parts(1), 1.0)									//分配数据格式
    }

    val model = new IsotonicRegression().setIsotonic(true).run(parsedData)	//建立模型

    model.predictions.foreach(println)							//打印保序回归模型

    val res = model.predict(5)									//创建预测值
    println(res)												//打印预测结果

  }
}

import org.apache.spark.mllib.clustering.GaussianMixture
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkConf, SparkContext}

object GMG {
  def main(args: Array[String]) {

    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("GMG ")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = sc.textFile("c://gmg.txt")							//输入数个
    val parsedData = data.map(s => Vectors.dense(s.trim.split(' ')		//转化数据格式
      .map(_.toDouble))).cache()
    val model = new GaussianMixture().setK(2).run(parsedData)		//训练模型

    for (i <- 0 until model.k) {
      println("weight=%f\nmu=%s\nsigma=\n%s\n" format			//逐个打印单个模型
        (model.weights(i), model.gaussians(i).mu, model.gaussians(i).sigma))	//打印结果
    }
  }
}







import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}

object LinearRegression {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                              //设置本地化处理
    .setAppName("LinearRegression ")                               //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/lpsa2.data")							//获取数据集路径
    val parsedData = data.map { line =>							//开始对数据集处理
      val parts = line.split(',')									//根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }.cache()                                                     //转化数据格式
    val model = LinearRegressionWithSGD.train(parsedData, 100,0.1)	//建立模型
    val result = model.predict(Vectors.dense(2))					//通过模型预测模型
    println(result)											//打印预测结果
  }

}


import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}

object LinearRegression {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                              //设置本地化处理
    .setAppName("LinearRegression2 ")                               //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/lr.txt")							  	 //获取数据集路径
    val parsedData = data.map { line =>							 //开始对数据集处理
      val parts = line.split('|')									 //根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(',').map(_.toDouble)))
    }.cache()                                                      //转化数据格式
    val model = LinearRegressionWithSGD.train(parsedData, 2,0.1)	  	 //建立模型
    val result = model.predict(Vectors.dense(2))					 //通过模型预测模型
    println(result)											 //打印预测结果
  }

}

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}

object LinearRegression {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                              //设置本地化处理
    .setAppName("LinearRegression3 ")                               //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/lr.txt")							  	 //获取数据集路径
    val parsedData = data.map { line =>							 //开始对数据集处理
      val parts = line.split('|')									 //根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(',').map(_.toDouble)))
    }.cache()                                                      //转化数据格式
    val model = LinearRegressionWithSGD.train(parsedData, 2,0.1)	  	//建立模型
    val valuesAndPreds = parsedData.map { point => {				//获取真实值与预测值
      val prediction = model.predict(point.features)					//对系数进行预测
      (point.label, prediction)									//按格式存储
    }
    }

    val MSE = valuesAndPreds.map{ case(v, p) => math.pow((v - p), 2)}.mean() //计算MSE
    println(MSE)
  }

}


















import org.apache.spark.{SparkContext, SparkConf}

object CacheTest {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                           //设置本地化处理
  .setAppName("CacheTest")								//设定名称
    val sc = new SparkContext(conf)							//创建环境变量实例
    val arr = sc.parallelize(Array("abc","b","c","d","e","f"))				//设定数据集
    println(arr)												//打印结果
    println("----------------")										//分隔符
    println(arr.cache())										//打印结果
  }
}


import org.apache.spark.{SparkContext, SparkConf}

object CacheTest2 {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                           //设置本地化处理
  .setAppName("CacheTest2")								//设定名称
    val sc = new SparkContext(conf)							//创建环境变量实例
    val arr = sc.parallelize(Array("abc","b","c","d","e","f"))				//设定数据集
    arr.foreach(println)										//打印结果
  }
}



import org.apache.spark.{SparkContext, SparkConf}

object Cartesian{
  def main(args: Array[String]) {
val conf = new SparkConf()                                        //创建环境变量
.setMaster("local")                                                //设置本地化处理
.setAppName("Cartesian ")                                    	   //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var arr = sc.parallelize(Array(1,2,3,4,5,6))						  //创建第一个数组
    var arr2 = sc.parallelize(Array(6,5,4,3,2,1))						  //创建第二个数据
    val result = arr.cartesian(arr2)                                     //进行笛卡尔计算
    result.foreach(print)                                              //打印结果
  }
}

import org.apache.spark.{SparkContext, SparkConf}

object Coalesce{
  def main(args: Array[String]) {
val conf = new SparkConf()                                        //创建环境变量
.setMaster("local")                                                //设置本地化处理
.setAppName("Coalesce ")                                    	   //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    val arr = sc.parallelize(Array(1,2,3,4,5,6))						  //创建数据集
    val arr2 = arr.coalesce(2,true)                                     //将数据重新分区
    val result = arr.aggregate(0)(math.max(_, _), _ + _)                  //计算数据值
    println(result)                                                   //打印结果
    val result2 = arr2.aggregate(0)(math.max(_, _), _ + _)               //计算重新分区数据值
    println(result2)  }                                               //打印结果
}


import org.apache.spark._
import org.apache.spark.mllib.recommendation.{ALS, Rating}

object CollaborativeFilter {
  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local").setAppName("CollaborativeFilter ")	//设置环境变量
val sc = new SparkContext(conf)                                 //实例化环境
    val data = sc.textFile("c://u1.txt")								//设置数据集
val ratings = data.map(_.split(' ') match {						//处理数据
 case Array(user, item, rate) => 							//将数据集转化
      Rating(user.toInt, item.toInt, rate.toDouble)				//将数据集转化为专用Rating
    })
    val rank = 2											//设置隐藏因子
    val numIterations = 2										//设置迭代次数
    val model = ALS.train(ratings, rank, numIterations, 0.01)			//进行模型训练
    var rs = model.recommendProducts(2,1)						//为用户2推荐一个商品
    rs.foreach(println)										//打印结果
  }
}


import org.apache.spark.{SparkConf, SparkContext}
import scala.collection.mutable.Map


object CollaborativeFilteringSpark {
val conf = new SparkConf().setMaster("local").setAppName("CollaborativeFilteringSpark ")	//设置环境变量
val sc = new SparkContext(conf)                                 //实例化环境
val users = sc.parallelize(Array("aaa","bbb","ccc","ddd","eee"))       //设置用户
val films = sc.parallelize(Array("smzdm","ylxb","znh","nhsc","fcwr"))	//设置电影名

val source = Map[String,Map[String,Int]]()				//使用一个source嵌套map作为姓名电影名和分值的存储
   val filmSource = Map[String,Int]() 					//设置一个用以存放电影分的map
   def getSource(): Map[String,Map[String,Int]] = {			//设置电影评分
     val user1FilmSource = Map("smzdm" -> 2,"ylxb" -> 3,"znh" -> 1,"nhsc" -> 0,"fcwr" -> 1)
     val user2FilmSource = Map("smzdm" -> 1,"ylxb" -> 2,"znh" -> 2,"nhsc" -> 1,"fcwr" -> 4)
     val user3FilmSource = Map("smzdm" -> 2,"ylxb" -> 1,"znh" -> 0,"nhsc" -> 1,"fcwr" -> 4)
     val user4FilmSource = Map("smzdm" -> 3,"ylxb" -> 2,"znh" -> 0,"nhsc" -> 5,"fcwr" -> 3)
     val user5FilmSource = Map("smzdm" -> 5,"ylxb" -> 3,"znh" -> 1,"nhsc" -> 1,"fcwr" -> 2)
     source += ("aaa" -> user1FilmSource)				//对人名进行存储
     source += ("bbb" -> user2FilmSource) 				//对人名进行存储
     source += ("ccc" -> user3FilmSource) 				//对人名进行存储
     source += ("ddd" -> user4FilmSource) 				//对人名进行存储
     source += ("eee" -> user5FilmSource) 				//对人名进行存储
     source										//返回嵌套map
   }

   //两两计算分值,采用余弦相似性
   def getCollaborateSource(user1:String,user2:String):Double = {
     val user1FilmSource = source.get(user1).get.values.toVector		//获得第1个用户的评分
     val user2FilmSource = source.get(user2).get.values.toVector		//获得第2个用户的评分
val member = user1FilmSource.zip(user2FilmSource).map(d => d._1 * d._2).reduce(_ + _   _).toDouble												//对公式分子部分进行计算
     val temp1  = math.sqrt(user1FilmSource.map(num => {			//求出分母第1个变量值
       math.pow(num,2)										//数学计算
     }).reduce(_ + _))										//进行叠加
     val temp2  = math.sqrt(user2FilmSource.map(num => {			////求出分母第2个变量值
       math.pow(num,2) 									//数学计算
     }).reduce(_ + _))										//进行叠加
     val denominator = temp1 * temp2							//求出分母
     member / denominator									//进行计算
}

   def main(args: Array[String]) {
     getSource()											//初始化分数
     val name = "bbb"										//设定目标对象
    users.foreach(user =>{									//迭代进行计算
      println(name + " 相对于 " + user +"的相似性分数是："+ getCollaborateSource(name,user))
    })
   }
 }


import org.apache.spark.{SparkContext, SparkConf}

object countByKey{
  def main(args: Array[String]) {
val conf = new SparkConf()                                       //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("countByKey ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var arr = sc.parallelize(Array((1, "cool"), (2, "good"), (1, "bad"), (1, "fine")))  //创建数据集
    val result = arr.countByKey()                                      //进行计数
    result.foreach(print)                                              //打印结果
  }
}


import org.apache.spark.{SparkContext, SparkConf}

object countByValue{
  def main(args: Array[String]) {
val conf = new SparkConf()                                       //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("countByValue ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    val arr = sc.parallelize(Array(1,2,3,4,5,6))						  //创建数据集
    val result = arr.countByValue()								  //调用方法计算个数
    result.foreach(print)                                              //打印结果
  }
}


import org.apache.spark.{SparkContext, SparkConf}

object distinct{
  def main(args: Array[String]) {
val conf = new SparkConf()                                       //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("distinct ")                                    	  //设定名称
val sc = new SparkContext(conf)						       //创建环境变量实例
var arr = sc.parallelize(Array(("cool"), ("good"), ("bad"), ("fine"),("good"),("cool")))  //创建数据集
val result = arr.distinct()                                           //进行去重操作
result.foreach(println)                                             //打印最终结果
  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.util.MLUtils

object DT {
  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("DT")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://DTree.txt")				//输入数据集

    val numClasses = 2 										//设定分类数量
    val categoricalFeaturesInfo = Map[Int, Int]()					//设定输入格式
    val impurity = "entropy"									//设定信息增益计算方式
    val maxDepth = 5										//设定树高度
    val maxBins = 3											//设定分裂数据集

    val model = DecisionTree.trainClassifier(data, numClasses, categoricalFeaturesInfo,
      impurity, maxDepth, maxBins)								//建立模型
    println(model.topNode)									//打印决策树信息

  }
}

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.util.MLUtils

object RFDTree {
  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("DT2")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://DTree.txt")				//输入数据集

val numClasses = 2										//设定分类的数量
    val categoricalFeaturesInfo = Map[Int, Int]()					//设置输入数据格式
    val numTrees = 3 								   //设置随机雨林中决策树的数目
val featureSubsetStrategy = "auto"							//设置属性在节点计算数
val impurity = "entropy"									//设定信息增益计算方式
    val maxDepth = 5										//设定树高度
    val maxBins = 3											//设定分裂数据集

    val model = RandomForest.trainClassifier(data, numClasses, categoricalFeaturesInfo,
      numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)	//建立模型

    model.trees.foreach(println)								//打印每棵树的相信信息
  }
}

import org.apache.spark.mllib.feature.ChiSqSelector
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkConf, SparkContext}

object FeatureSelection {
  def main(args: Array[String]) {
val conf = new SparkConf()                                   	//创建环境变量
.setMaster("local")                                          	//设置本地化处理
.setAppName("FeatureSelection ")                              //设定名称
val sc = new SparkContext(conf)                               	//创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://fs.txt")				//读取数据文件

    val discretizedData = data.map { lp =>						//创建数据处理空间
      LabeledPoint(lp.label, Vectors.dense(lp.features.toArray.map { x => x / 2 } ) )
    }

    val selector = new ChiSqSelector(2)					//创建选择2个特性的卡方检验实例
    val transformer = selector.fit(discretizedData)					//创建训练模型
    val filteredData = discretizedData.map { lp =>					//过滤前2个特性
      LabeledPoint(lp.label, transformer.transform(lp.features))
    }

    filteredData.foreach(println)								//打印结果
  }
}


import org.apache.spark.{SparkContext, SparkConf}

object filter{
  def main(args: Array[String]) {
val conf = new SparkConf()                                       //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("filter ")                                    	  //设定名称
val sc = new SparkContext(conf)						       //创建环境变量实例
var arr = sc.parallelize(Array(1,2,3,4,5))                             //创建数据集
val result = arr.filter(_ >= 3)                                        //进行筛选工作
result.foreach(println)                                             //打印最终结果
  }
}

import org.apache.spark.{SparkContext, SparkConf}

object flatMap{
  def main(args: Array[String]) {
val conf = new SparkConf()                                      //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("flatMap ")                                    	  //设定名称
val sc = new SparkContext(conf)						       //创建环境变量实例
var arr = sc.parallelize(Array(1,2,3,4,5))                             //创建数据集
    val result = arr.flatMap(x => List(x + 1)).collect()                      //进行数据集计算
    result.foreach(println)                                             //打印结果
  }
}

import org.apache.spark.mllib.fpm.FPGrowth
import org.apache.spark.{SparkConf, SparkContext}
object FPTree {

  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("FPTree ")                              		//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = sc.textFile("c://fp.txt")								//读取数据
    val fpg = new FPGrowth().setMinSupport(0.3)			//创建FP数实例并设置最小支持度
    val model = fpg.run(data)									//创建模型

  }
}

import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.tree.GradientBoostedTrees
import org.apache.spark.mllib.tree.configuration.BoostingStrategy
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel
import org.apache.spark.mllib.util.MLUtils

object GDTree {

  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("GDTree")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://DTree.txt")				//输入数据集

    val boostingStrategy = BoostingStrategy.defaultParams("Classification")	//创建算法类型
    boostingStrategy.numIterations = 3 							//迭代次数
    boostingStrategy.treeStrategy.numClasses = 2					//分类数目
    boostingStrategy.treeStrategy.maxDepth = 5					//决策树最高层数
    boostingStrategy.treeStrategy.categoricalFeaturesInfo = Map[Int, Int]()	//数据格式

val model = GradientBoostedTrees.train(data, boostingStrategy)	//训练模型
  }
}

import org.apache.spark.mllib.clustering.GaussianMixture
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkConf, SparkContext}

object GMG {
  def main(args: Array[String]) {

val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("GMG ")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = sc.textFile("c://gmg.txt")							//输入数个
val parsedData = data.map(s => Vectors.dense(s.trim.split(' ')		//转化数据格式
.map(_.toDouble))).cache()
    val model = new GaussianMixture().setK(2).run(parsedData)		//训练模型

    for (i <- 0 until model.k) {
      println("weight=%f\nmu=%s\nsigma=\n%s\n" format			//逐个打印单个模型
        (model.weights(i), model.gaussians(i).mu, model.gaussians(i).sigma))	//打印结果
    }
  }
}



import org.apache.spark.{SparkContext, SparkConf}

object groupBy{
  def main(args: Array[String]) {
val conf = new SparkConf()                                       //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("groupBy ")                                    	  //设定名称
val sc = new SparkContext(conf)						       //创建环境变量实例
var arr = sc.parallelize(Array(1,2,3,4,5))                             //创建数据集
    arr.groupBy(myFilter(_), 1)									   //设置第一个分组
    arr.groupBy(myFilter2(_), 2)								   //设置第二个分组
  }

  def myFilter(num: Int): Unit = {								   //自定义方法
    num >= 3                                                        //条件
  }
  def myFilter2(num: Int): Unit = {								   //自定义方法
    num < 3                                                         //条件
  }

}

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object irisALL{
  def main(args: Array[String]) {
val conf = new SparkConf()                                       //创建环境变量
.setMaster("local")                                               //设置本地化处理
.setAppName("irisAll ")                                          //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val data = sc.textFile("c:// Sepal.Length.txt")                        //创建RDD文件路径
.map(_.toDouble))                                             //转成Double类型
      .map(line => Vectors.dense(line))                                //转成Vector格式
val summary = Statistics.colStats(data)						  //计算统计量
println("全部Sepal.Length的均值为：" + summary.mean)		      //打印均值
println("全部Sepal.Length的方差为：" + summary.variance)	      //打印方差
  }
}


import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.classification.{NaiveBayes, NaiveBayesModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint

object irisBayes {
  def main(args: Array[String]) {

val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("irisBayes")                              		//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLabeledPoints(sc,"c://a.txt")				//读取数据集
    val model = NaiveBayes.train(data, 1.0)						//训练贝叶斯模型
val test = Vectors.dense(7.3,2.9,6.3,1.8)						//创建待测定数据
val result = model.predict(“测试数据归属在类别:” + test)			//打印结果
}
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object irisCorrect {
  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("irisCorrect ")                                    //设定名称
    val sc = new SparkContext(conf)                                //创建环境变量实例
    val dataX = sc.textFile("c://x.txt")                                //读取数据
        .flatMap(_.split(' ')                                         //进行分割
        .map(_.toDouble))                                         //转化为Double类型
    val dataY = sc.textFile("c://y.txt")                                 //读取数据
      .flatMap(_.split(' ')                                            //进行分割
      .map(_.toDouble))                                           //转化为Double类型
    val correlation: Double = Statistics.corr(dataX, dataY)         //计算不同数据之间的相关系数
    println(correlation)                                              //打印结果
  }



import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object irisCorrect2 {
  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("irisCorrect2")                                    //设定名称
    val sc = new SparkContext(conf)                                //创建环境变量实例
    val dataX = sc.textFile("c://x.txt")                                //读取数据
        .flatMap(_.split(' ')                                         //进行分割
        .map(_.toDouble))                                         //转化为Double类型
    val dataY = sc.textFile("c://y.txt")                                 //读取数据
      .flatMap(_.split(' ')                                            //进行分割
      .map(_.toDouble))                                           //转化为Double类型
    val correlation: Double = Statistics.corr(dataX, dataY)         //计算不同数据之间的相关系数
    println("setosa和versicolor中Sepal.Length的相关系数为：" + correlation) //打印相关系数
  }
}



import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object irisCorrect {
  def main(args: Array[String]) {
val conf = new SparkConf()                                     //创建环境变量
.setMaster("local")                                             //设置本地化处理
.setAppName("irisCorrect3 ")                                    //设定名称
    val sc = new SparkContext(conf)                                //创建环境变量实例
    val dataX = sc.textFile("c://x.txt")                                //读取数据
        .flatMap(_.split(' ')                                         //进行分割
        .map(_.toDouble))                                         //转化为Double类型
    val dataY = sc.textFile("c://y.txt")                                 //读取数据
      .flatMap(_.split(' ')                                            //进行分割
      .map(_.toDouble))                                           //转化为Double类型
    val correlation: Double = Statistics.corr(dataX, dataY)         //计算不同数据之间的相关系数
    println("setosa和versicolor中Sepal.Length的相关系数为：" + correlation) //打印相关系数
  }
}


  import org.apache.spark.mllib.linalg.Vectors
  import org.apache.spark.{SparkContext, SparkConf}
  import org.apache.spark.mllib.tree.DecisionTree
  import org.apache.spark.mllib.util.MLUtils

  object irisDecisionTree {
    def main(args: Array[String]) {
      val conf = new SparkConf()                                     //创建环境变量
        .setMaster("local")                                             //设置本地化处理
        .setAppName("irisDecisionTree ")                              	//设定名称
      val sc = new SparkContext(conf)                                 //创建环境变量实例
      val data = MLUtils.loadLibSVMFile(sc, "c://a.txt")				//输入数据集
      val numClasses = 3 										//设定分类数量
      val categoricalFeaturesInfo = Map[Int, Int]()					//设定输入格式
      val impurity = "entropy"									//设定信息增益计算方式
      val maxDepth = 5										//设定树高度
      val maxBins = 3											//设定分裂数据集
      val model = DecisionTree.trainClassifier(data, numClasses, categoricalFeaturesInfo,
        impurity, maxDepth, maxBins)								//建立模型
      val test = Vectors.dense(Array(7.2,3.6,6.1,2.5))
      println(model.predict(“预测结果是:” + test))
    }
  }

  import org.apache.spark.mllib.clustering.GaussianMixture
  import org.apache.spark.mllib.linalg.Vectors
  import org.apache.spark.{SparkConf, SparkContext}

  object irisGMG {
    def main(args: Array[String]) {

      val conf = new SparkConf()                                     //创建环境变量
        .setMaster("local")                                             //设置本地化处理
        .setAppName("irisGMG")                              			//设定名称
      val sc = new SparkContext(conf)                                 //创建环境变量实例
      val data = sc.textFile("c://a.txt")							//输入数个
      val parsedData = data.map(s => Vectors.dense(s.trim.split(' ')		//转化数据格式
        .map(_.toDouble))).cache()
      val model = new GaussianMixture().setK(2).run(parsedData)		//训练模型

      for (i <- 0 until model.k) {
        println("weight=%f\nmu=%s\nsigma=\n%s\n" format			//逐个打印单个模型
          (model.weights(i), model.gaussians(i).mu, model.gaussians(i).sigma))	//打印结果
      }
    }
  }

  import org.apache.spark.mllib.clustering.KMeans
  import org.apache.spark.mllib.linalg.Vectors
  import org.apache.spark.{SparkConf, SparkContext}

  object irisKmeans{
    def main(args: Array[String]) {

      val conf = new SparkConf()                                     //创建环境变量
        .setMaster("local")                                             //设置本地化处理
        .setAppName("irisKmeans ")                              		//设定名称
      val sc = new SparkContext(conf)                                 //创建环境变量实例
      val data = MLUtils.loadLibSVMFile(sc, "c://a.txt")			//输入数据集
      val parsedData = data.map(s => Vectors.dense(s.split(' ').map(_.toDouble)))
        .cache()												//数据处理

      val numClusters = 3										//最大分类数
      val numIterations = 20									//迭代次数
      val model = KMeans.train(parsedData, numClusters, numIterations)	//训练模型
      model.clusterCenters.foreach(println)							//打印中心点坐标

    }
  }

  import org.apache.spark.mllib.linalg.Vectors
  import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
  import org.apache.spark.{SparkConf, SparkContext}


  object irisLinearRegression {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("irisLinearRegression ")                            //设定名称
    val sc = new SparkContext(conf)                                //创建环境变量实例
    val data = sc.textFile("c:/a.txt")								//读取数据
    val parsedData = data.map { line =>							//处理数据
      val parts = line.split('	')								//按空格分割
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).toDouble)) //固定格式
    }.cache()												//加载数据
    val model = LinearRegressionWithSGD.train(parsedData, 10,0.1)	//创建模型
    println("回归公式为: y = " + model.weights + " * x + " + model.intercept) //打印回归公式
  }
}

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}


object irisLinearRegression2 {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                             //设置本地化处理
    .setAppName("irisLinearRegression2")                            //设定名称
  val sc = new SparkContext(conf)                                //创建环境变量实例
  val data = sc.textFile("c:/a.txt")								//读取数据
  val parsedData = data.map { line =>							//处理数据
    val parts = line.split('	')								//按空格分割
    LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).toDouble)) //固定格式
  }.cache()												//加载数据
  val model = LinearRegressionWithSGD.train(parsedData, 10,0.1)	//创建模型
  val valuesAndPreds = parsedData.map { point => {				//创建均方误差训练数据
    val prediction = model.predict(point.features)					//创建数据
    (point.label, prediction)									//创建预测数据
  }
    val MSE = valuesAndPreds.map{ case(v, p) => math.pow((v - p), 2)}.mean() //计算均方误差
    println(“均方误差结果为:” + MSE)  							//打印结果
  }
}


import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}


object irisLogicRegression{
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                             //设置本地化处理
    .setAppName("irisLogicRegression ")                            //设定名称
  val sc = new SparkContext(conf)                                //创建环境变量实例
  val data = sc.textFile("c:/a.txt")								//读取数据
  val parsedData = data.map { line =>							//处理数据
    val parts = line.split('	')								//按空格分割
    LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).toDouble)) //固定格式
  }.cache()												//加载数据
  val model = irisLogicRegression.train(parsedData, 20)	         //创建模型
  val valuesAndPreds = parsedData.map { point => {				//创建均方误差训练数据
    val prediction = model.predict(point.features)					//创建数据
    (point.label, prediction)									//创建预测数据
  }
    val MSE = valuesAndPreds.map{ case(v, p) => math.pow((v - p), 2)}.mean() //计算均方误差
    println(“均方误差结果为:” + MSE)  							//打印结果
  }
}

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object irisMean{
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("irisMean ")                                        //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val data = sc.textFile("c:// Sepal.Length_setosa.txt")                  //创建RDD文件路径
      .map(_.toDouble))                                             //转成Double类型
    .map(line => Vectors.dense(line))                                //转成Vector格式
    val summary = Statistics.colStats(data)						  //计算统计量
    println("setosa中Sepal.Length的均值为：" + summary.mean)		  //打印均值
    println("setosa中Sepal.Length的方差为：" + summary.variance)	  //打印方差
  }
}


import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object irisNorm{
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("irisNorm")                                         //设定名称
    val sc = new SparkContext(conf)                                   //创建环境变量实例
    val data = sc.textFile("c:// Sepal.Length_setosa.txt")                   //创建RDD文件路径
      .map(_.toDouble))                                              //转成Double类型
    .map(line => Vectors.dense(line))                                 //转成Vector格式
    val summary = Statistics.colStats(data)						   //计算统计量
    println("setosa中Sepal的曼哈顿距离的值为：" + summary.normL1)	   //计算曼哈顿距离
    println("setosa中Sepal的欧几里得距离的值为：" + summary.normL2)  //计算欧几里得距离
  }
}


import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.util.MLUtils

object irisRFDTree {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("irisRFDTree")                              		//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://a.txt")				//输入数据集

    val numClasses = 3										//设定分类的数量
    val categoricalFeaturesInfo = Map[Int, Int]()					//设置输入数据格式
    val numTrees = 3 								   //设置随机雨林中决策树的数目
    val featureSubsetStrategy = "auto"							//设置属性在节点计算数
    val impurity = "entropy"									//设定信息增益计算方式
    val maxDepth = 5										//设定树高度
    val maxBins = 3											//设定分裂数据集

    val model = RandomForest.trainClassifier(data, numClasses, categoricalFeaturesInfo,
      numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)	//建立模型

    model.trees.foreach(println)								//打印每棵树的相信信息
  }
}

import org.apache.spark.mllib.regression.IsotonicRegression
import org.apache.spark.{SparkConf, SparkContext}

object IS {
  def main(args: Array[String]) {

    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("IS")                              				//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://u.txt")				//输入数据集

    val parsedData = data.map { line =>							//处理数据格式
      val parts = line.split(',').map(_.toDouble)						//切分数据
      (parts(0), parts(1), 1.0)									//分配数据格式
    }

    val model = new IsotonicRegression().setIsotonic(true).run(parsedData)	//建立模型

    model.predictions.foreach(println)							//打印保序回归模型

    val res = model.predict(5)									//创建预测值
    println(res)												//打印预测结果

  }
}
import org.apache.spark.{SparkContext, SparkConf}

object keyBy{
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("keyBy ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var str = sc.parallelize(Array("one","two","three","four","five"))          //创建数据集
    val str2 = str.keyBy(word => word.size)                              //设置配置方法
    str2.foreach(println)                                               打印结果
  }
}

import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.{SparkConf, SparkContext}

object Kmeans {
  def main(args: Array[String]) {

    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("Kmeans ")                              		//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = MLUtils.loadLibSVMFile(sc, "c://Kmeans.txt")			//输入数据集
    val parsedData = data.map(s => Vectors.dense(s.split(' ').map(_.toDouble)))
      .cache()												//数据处理

    val numClusters = 2										//最大分类数
    val numIterations = 20									//迭代次数
    val model = KMeans.train(parsedData, numClusters, numIterations)	//训练模型
    model.clusterCenters.foreach(println)							//打印中心点坐标

  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}

object LinearRegression {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                              //设置本地化处理
    .setAppName("LinearRegression ")                               //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/lpsa2.data")							//获取数据集路径
    val parsedData = data.map { line =>							//开始对数据集处理
      val parts = line.split(',')									//根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }.cache()                                                     //转化数据格式
    val model = LinearRegressionWithSGD.train(parsedData, 100,0.1)	//建立模型
    val result = model.predict(Vectors.dense(2))					//通过模型预测模型
    println(result)											//打印预测结果
  }

}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}

object LinearRegression {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                              //设置本地化处理
    .setAppName("LinearRegression2 ")                               //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/lr.txt")							  	 //获取数据集路径
    val parsedData = data.map { line =>							 //开始对数据集处理
      val parts = line.split('|')									 //根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(',').map(_.toDouble)))
    }.cache()                                                      //转化数据格式
    val model = LinearRegressionWithSGD.train(parsedData, 2,0.1)	  	 //建立模型
    val result = model.predict(Vectors.dense(2))					 //通过模型预测模型
    println(result)											 //打印预测结果
  }

}

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.{LabeledPoint, LinearRegressionWithSGD}
import org.apache.spark.{SparkConf, SparkContext}

object LinearRegression {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                              //设置本地化处理
    .setAppName("LinearRegression3 ")                               //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/lr.txt")							  	 //获取数据集路径
    val parsedData = data.map { line =>							 //开始对数据集处理
      val parts = line.split('|')									 //根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(',').map(_.toDouble)))
    }.cache()                                                      //转化数据格式
    val model = LinearRegressionWithSGD.train(parsedData, 2,0.1)	  	//建立模型
    val valuesAndPreds = parsedData.map { point => {				//获取真实值与预测值
      val prediction = model.predict(point.features)					//对系数进行预测
      (point.label, prediction)									//按格式存储
    }
    }

    val MSE = valuesAndPreds.map{ case(v, p) => math.pow((v - p), 2)}.mean() //计算MSE
    println(MSE)
  }

}
import org.apache.spark.mllib.classification.LogisticRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.{SparkConf, SparkContext}

object LogisticRegression{
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                             //设置本地化处理
    .setAppName("LogisticRegression ")                              //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = sc.textFile("c:/u.txt")							  	 //获取数据集路径
    val parsedData = data.map { line =>							 //开始对数据集处理
      val parts = line.split('|')									 //根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).map(_.toDouble))
    }.cache()                                                      //转化数据格式
    val model = LogisticRegressionWithSGD.train(parsedData,50)		//建立模型
    val target = Vectors.dense(-1)								//创建测试值
    val resulet = model.predict(target)							//根据模型计算结果
    println(resulet)  										//打印结果
  }
}

import org.apache.spark.mllib.classification.LogisticRegressionWithSGD
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkConf, SparkContext}

object LogisticRegression2 {
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                             //设置本地化处理
    .setAppName("LogisticRegression2 ")                              //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = MLUtils.loadLibSVMFile(sc, "c://sample_libsvm_data.txt")	//读取数据文件
    val model = LogisticRegressionWithSGD.train(data,50)			//训练数据模型
    println(model.weights.size)								//打印θ值
    println(model.weights)									//打印θ值个数
    println(model.weights.toArray.filter(_ != 0).size)					//打印θ中不为0的数
  }
}
import org.apache.spark.mllib.classification.LogisticRegressionWithSGD
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.evaluation.MulticlassMetrics

object LinearRegression3{
  val conf = new SparkConf()                                     //创建环境变量
    .setMaster("local")                                             //设置本地化处理
    .setAppName("LogisticRegression3")                              //设定名称
  val sc = new SparkContext(conf)                                 //创建环境变量实例

  def main(args: Array[String]) {
    val data = MLUtils.loadLibSVMFile(sc, "c://sample_libsvm_data.txt")	//读取数据集
    val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)			//对数据集切分
    val parsedData = splits(0)									//分割训练数据
    val parseTtest = splits(1)									//分割测试数据
    val model = LogisticRegressionWithSGD.train(parsedData,50)		//训练模型
    println(model.weights)									//打印θ值
    val predictionAndLabels = parseTtest.map { 					//计算测试值
      case LabeledPoint(label, features) =>						//计算测试值
        val prediction = model.predict(features)						//计算测试值
        (prediction, label)										//存储测试和预测值
    }
    val metrics = new MulticlassMetrics(predictionAndLabels)			//创建验证类
    val precision = metrics.precision								//计算验证值
    println("Precision = " + precision)							//打印验证值
  }
}
import org.apache.spark.mllib.classification.LogisticRegressionWithSGD
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.{SparkContext, SparkConf}

object GastriCcancer {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("LogisticRegression4")                              //设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例

    val data = MLUtils.loadLibSVMFile(sc, "c://wa.txt")				//获取数据集
    val splits = data.randomSplit(Array(0.7, 0.3), seed = 11L)			//对数据集切分
    val parsedData = splits(0)									//分割训练数据
    val parseTtest = splits(1)									//分割测试数据
    val model = LogisticRegressionWithSGD.train(parsedData,50)		//训练模型

    val predictionAndLabels = parseTtest.map { 					//计算测试值
      case LabeledPoint(label, features) =>						//计算测试值
        val prediction = model.predict(features)						//计算测试值
        (prediction, label)										//存储测试和预测值
    }

    val metrics = new MulticlassMetrics(predictionAndLabels)			//创建验证类
    val precision = metrics.precision								//计算验证值
    println("Precision = " + precision)							//打印验证值

    val patient = Vectors.dense(Array(70,3,180.0,4,3))				//计算患者可能性
    if(patient == 1) println("患者的胃癌有几率转移。")				//做出判断
    else println("患者的胃癌没有几率转移。")					//做出判断
  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import org.apache.spark.{SparkConf, SparkContext}

object PCA {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                   	//创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("PCA ")                                    		//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例

    val data = sc.textFile("c://a.txt")                                   //创建RDD文件路径
      .map(_.split(' ')                                               //按“ ”分割
      .map(_.toDouble))                                            //转成Double类型
      .map(line => Vectors.dense(line))                               //转成Vector格式
    val rm = new RowMatrix(data)                                    //读入行矩阵

    val pc = rm.computePrincipalComponents(3)				//提取主成分，设置主成分个数
    val mx = rm.multiply(pc)									//创建主成分矩阵
    mx.rows.foreach(println)									//打印结果
  }
}
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.clustering.PowerIterationClustering

object PIC {
  def main(args: Array[String]) {

    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("PIC ")                              			//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例
    val data = sc.textFile("c://u2.txt")								//读取数据
    val pic = new PowerIterationClustering()						//创建专用类
      .setK(3)												//设定聚类数
      .setMaxIterations(20)									//设置迭代次数
    val model = pic.run(data)									//创建模型
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object Repartition {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("Repartition ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    val arr = sc.parallelize(Array(1,2,3,4,5,6))						  //创建数据集
    arr = arr.repartition(3)                                            //重新分区
    println(arr.partitions.length)}                                       //打印分区数
}
import scala.collection.mutable.HashMap

object SGD {
  val data = HashMap[Int,Int]()									//创建数据集
  def getData():HashMap[Int,Int] = {								//生成数据集内容
    for(i <- 1 to 50){											//创建50个数据
      data += (i -> (12*i))										//写入公式y=2x
    }
    data													//返回数据集
  }

  var θ:Double = 0											//第一步假设θ为0
  var α:Double = 0.1 										//设置步进系数

  def sgd(x:Double,y:Double) = {								//设置迭代公式
    θ = θ - α * ( (θ*x) - y)										//迭代公式
  }
  def main(args: Array[String]) {
    val dataSource = getData()									//获取数据集
    dataSource.foreach(myMap =>{								//开始迭代
      sgd(myMap._1,myMap._2)								//输入数据
    })
    println(“最终结果θ值为 ” + θ)								//显示结果
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object sortBy {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                                //设置本地化处理
      .setAppName("sortBy ")                                       //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var str = sc.parallelize(Array((5,"b"),(6,"a"),(1,"f"),(3,"d"),(4,"c"),(2,"e")))  //创建数据集
    str = str.sortBy(word => word._1,true)                              //按第一个数据排序
    val str2 = str.sortBy(word => word._2,true)                          //按第二个数据排序
    str.foreach(print)                                                //打印输出结果
    str2.foreach(print)                                               //打印输出结果
  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import org.apache.spark.{SparkConf, SparkContext}

object SVD {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                   	//创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("SVD ")                                    		//设定名称
    val sc = new SparkContext(conf)                                 //创建环境变量实例

    val data = sc.textFile("c://a.txt")                                   //创建RDD文件路径
      .map(_.split(' ')                                               //按“ ”分割
      .map(_.toDouble))                                            //转成Double类型
      .map(line => Vectors.dense(line))                               //转成Vector格式

    val rm = new RowMatrix(data)                                    //读入行矩阵
    val SVD = rm.computeSVD(2, computeU = true)					 //进行SVD计算
    println(SVD)											 //打印SVD结果矩阵
  }
}

import org.apache.spark.mllib.classification.SVMWithSGD
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.{SparkConf, SparkContext}

object SVM {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                     //创建环境变量
      .setMaster("local")                                             //设置本地化处理
      .setAppName("SVM")                              			//设定名称
    val sc = new SparkContext(conf)                                //创建环境变量实例
    val data = sc.textFile("c:/u.txt")							  	//获取数据集路径
    val parsedData = data.map { line =>							//开始对数据集处理
      val parts = line.split('|')									//根据逗号进行分区
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).map(_.toDouble))
    }.cache()                                                      //转化数据格式
    val model = SVMWithSGD.train(parsedData, 10)				//训练数据模型
    println(model.weights)									//打印权重
    println(model.intercept)									//打印截距
  }
}
import org.apache.spark.mllib.linalg.{Matrices, Vectors}
import org.apache.spark.mllib.stat.Statistics

object testChiSq{
  def main(args: Array[String]) {
    val vd = Vectors.dense(1,2,3,4,5)                                 //
    val vdResult = Statistics.chiSqTest(vd)
    println(vdResult)
    println("-------------------------------")
    val mtx = Matrices.dense(3, 2, Array(1, 3, 5, 2, 4, 6))
    val mtxResult = Statistics.chiSqTest(mtx)
    println(mtxResult)
  }
}
import org.apache.spark._
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.mllib.linalg.distributed.{CoordinateMatrix, MatrixEntry}

object testCoordinateRowMatrix {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testIndexedRowMatrix")						  //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val rdd = sc.textFile("c://a.txt")                                     //创建RDD文件路径
      .map(_.split(' ')                                                //按“ ”分割
      .map(_.toDouble))                                             //转成Double类型
      .map(vue => (vue(0).toLong,vue(1).toLong,vue(2)))                //转化成坐标格式
      .map(vue2 => new MatrixEntry(vue2 _1,vue2 _2,vue2 _3))         //转化成坐标矩阵格式
    val crm = new CoordinateMatrix(rdd)                              //实例化坐标矩阵
    println(crm.entries.foreach(println))                                //打印数据
  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object testCorrect {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testCorrect ")                                    //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val rddX = sc.textFile("c://x.txt")                                   //读取数据
      .flatMap(_.split(' ')                                           //进行分割
      .map(_.toDouble))                                           //转化为Double类型
    val rddY = sc.textFile("c://y.txt")                                   //读取数据
      .flatMap(_.split(' ')                                             //进行分割
      .map(_.toDouble))                                            //转化为Double类型
    val correlation: Double = Statistics.corr(rddX, rddY)                 //计算不同数据之间的相关系数
    println(correlation)                                              //打印结果
  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object testCorrect2 {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testCorrect2 ")                                    //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val rddX = sc.textFile("c://x.txt")                                   //读取数据
      .flatMap(_.split(' ')                                           //进行分割
      .map(_.toDouble))                                           //转化为Double类型
    val rddY = sc.textFile("c://y.txt")                                   //读取数据
      .flatMap(_.split(' ')                                             //进行分割
      .map(_.toDouble))                                            //转化为Double类型
    val correlation: Double = Statistics.corr(rddX, rddY，” spearman “)    //使用斯皮尔曼计算不同数据之间的相关系数
    println(correlation)                                              //打印结果
  }
}
import org.apache.spark._
import org.apache.spark.mllib.linalg.distributed.{IndexedRow, RowMatrix, IndexedRowMatrix}
import org.apache.spark.mllib.linalg.{Vector, Vectors}

object testIndexedRowMatrix {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
    setAppName("testIndexedRowMatrix")						  //设定名称
    val sc = new SparkContext(conf)                               //创建环境变量实例
    val rdd = sc.textFile("c://a.txt")                                     //创建RDD文件路径
      .map(_.split(' ')                                                //按“ ”分割
      .map(_.toDouble))                                             //转成Double类型
      .map(line => Vectors.dense(line))                               //转化成向量存储
      .map((vd) => new IndexedRow(vd.size,vd))                      //转化格式
    val irm = new IndexedRowMatrix(rdd)                             //建立索引行矩阵实例
    println(irm.getClass)                                            //打印类型
    println(irm.rows.foreach(println))                                 //打印内容数据
  }
}
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.mllib.regression.LabeledPoint

object testLabeledPoint {
  def main(args: Array[String]) {
    val vd: Vector =  Vectors.dense(2, 0, 6)                            //建立密集向量
    val pos = LabeledPoint(1, vd)                                     //对密集向量建立标记点
    println(pos.features)                                             //打印标记点内容数据
    println(pos.label)                                                //打印既定标记
    val vs: Vector = Vectors.sparse(4, Array(0,1,2,3), Array(9,5,2,7))      //建立稀疏向量
    val neg = LabeledPoint(2, vs)                                    //对密集向量建立标记点
    println(neg.features)                                            //打印标记点内容数据
    println(neg.label)                                               //打印既定标记
  }
}
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark._
import org.apache.spark.mllib.util.MLUtils

object testLabeledPoint2 {
  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local").setAppName("SparkPi")//建立本地环境变量
    val sc = new SparkContext(conf)                                 //建立Spark处理

    val mu = MLUtils.loadLibSVMFile(sc, "c://a.txt")                    //从C路径盘读取文件
    mu.foreach(println)                                             //打印内容
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object testMap {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                      //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testMap ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var arr = sc.parallelize(Array(1,2,3,4,5))                             //创建数据集
    val result = arr.map(x => List(x + 1)).collect()                        //进行单个数据计算
    result.foreach(println)                                             //打印结果
  }
}
import org.apache.spark.mllib.linalg.{Matrix, Matrices}

object testMatrix {
  def main(args: Array[String]) {
    val mx = Matrices.dense(2, 3, Array(1,2,3,4,5,6))                    //创建一个分布式矩阵
    println(mx)                                                     //打印结果
  }
}
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.mllib.random.RandomRDDs._

object testRandomRDD {
  def main(args: Array[String]) {
    val conf = new SparkConf()
      .setMaster("local")
      .setAppName("testRandomRDD")
    val sc = new SparkContext(conf)
    val randomNum = normalRDD(sc, 100)
    randomNum.foreach(println)
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object testRDDMethod {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testRDDMethod ")                                    	  //设定名称
    val sc = new SparkContext(conf)						      //创建环境变量实例
    val arr = sc.parallelize(Array(1,2,3,4,5,6))						  //输入数组数据集
    val result = arr.aggregate(0)(math.max(_, _), _ + _)				  //使用aggregate方法
    println(result)											  //打印结果
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object testRDDMethod2 {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                        //创建环境变量
      .setMaster("local")                                                //设置本地化处理
      .setAppName("testRDDMethod2 ")                                    	   //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    val arr = sc.parallelize(Array(1,2,3,4,5,6)，2)				       //输入数组数据集
    val result = arr.aggregate(0)(math.max(_, _), _ + _)				  //使用aggregate方法
    println(result)											  //打印结果
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object testRDDMethod3 {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                        //创建环境变量
      .setMaster("local")                                                //设置本地化处理
      .setAppName("testRDDMethod3 ")                                    	   //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    val arr = sc.parallelize(Array("abc","b","c","d","e","f"))				   //创建数据集
    val result = arr.aggregate("")((value,word) => value + word, _ + _)       //调用计算方法
    println(result)						                          //打印结果
  }
}

import org.apache.spark.{SparkContext, SparkConf}

object testReduce {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testReduce ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var str = sc.parallelize(Array("one","two","three","four","five"))          //创建数据集
    val result = str.reduce(_ + _)                                       //进行数据拟合
    result.foreach(print)                                               //打印数据结果
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object testRDDMethod {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testRDDMethod ")                                    	  //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    var str = sc.parallelize(Array("one","two","three","four","five"))          //创建数据集
    val result = str.reduce(myFun)								  //进行数据拟合
    result.foreach(print)                                              //打印结果
  }

  def myFun(str1:String,str2:String):String = {                          //创建方法
    var str = str1                                                   //设置确定方法
    if(str2.size >= str.size){                                          //比较长度
      str = str2                                                    //替换
    }
    return str                                                     //返回最长的那个字符串
  }
}
import org.apache.spark._
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.mllib.linalg.distributed.RowMatrix

object testRowMatrix {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testRowMatrix")                                    //设定名称
    val sc = new SparkContext(conf)                                   //创建环境变量实例
    val rdd = sc.textFile("c://a.txt")                                     //创建RDD文件路径
      .map(_.split(' ')                                                //按“ ”分割
      .map(_.toDouble))                                             //转成Double类型
      .map(line => Vectors.dense(line))                                //转成Vector格式
    val rm = new RowMatrix(rdd)                                      //读入行矩阵
    println(rm.numRows())                                           //打印列数
    println(rm.numCols())                                            //打印行数
  }
}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.stat.Statistics
import org.apache.spark.{SparkConf, SparkContext}

object testSingleCorrect {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testSingleCorrect ")                                //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val rdd = sc.textFile("c://x.txt")                                    //读取数据文件
      .map(_.split(' ')                                               //切割数据
      .map(_.toDouble))                                            //转化为Double类型
      .map(line => Vectors.dense(line))                               //转为向量
    println(Statistics.corr(rdd,"spearman"))                            //使用斯皮尔曼计算相关系数
  }
}
object testStratifiedSampling2 {
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testSingleCorrect2 ")                                //设定名称
    val sc = new SparkContext(conf)                                  //创建环境变量实例
    val data = sc.textFile("c://a.txt")                                   //读取数据
      .map(row => {                                                //开始处理
      if(row.length == 3)                                            //判断字符数
        (row,1)                                                    //建立对应map
      else (row,2)                                                  //建立对应map
    })
    val fractions: Map[String, Double] = Map("aa" -> 2)                 //设定抽样格式
    val approxSample = data.sampleByKey(withReplacement = false, fractions,0) //计算抽样样本
    approxSample.foreach(println)                                   //打印结果
  }
}
object testSummary{
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testSummary")                                    //设定名称
    val sc = new SparkContext(conf)                                   //创建环境变量实例
    val rdd = sc.textFile("c://a.txt")                                     //创建RDD文件路径
      .map(_.split(' ')                                                //按“ ”分割
      .map(_.toDouble))                                             //转成Double类型
      .map(line => Vectors.dense(line))                                //转成Vector格式
    val summary = Statistics.colStats(rdd)						  //获取Statistics实例
    println(summary.mean)                                           //计算均值
    println(summary.variance)                                        //计算标准差
  }
}
object testSummary{
  def main(args: Array[String]) {
    val conf = new SparkConf()                                       //创建环境变量
      .setMaster("local")                                               //设置本地化处理
      .setAppName("testSummary2")                                    //设定名称
    val sc = new SparkContext(conf)                                   //创建环境变量实例
    val rdd = sc.textFile("c://a.txt")                                     //创建RDD文件路径
      .map(_.split(' ')                                                //按“ ”分割
      .map(_.toDouble))                                             //转成Double类型
      .map(line => Vectors.dense(line))                                //转成Vector格式
    val summary = Statistics.colStats(rdd)						  //获取Statistics实例
    println(summary.normL1)                                         //计算曼哈段距离
    println(summary.normL2)                                        //计算欧几里得距离
  }
}

import org.apache.spark.mllib.linalg.{Vector, Vectors}

object testVector {
  def main(args: Array[String]) {
    val vd: Vector = Vectors.dense(2, 0, 6)                             //建立密集向量
    println(vd(2))	                                                //打印稀疏向量第3个值
    val vs: Vector = Vectors.sparse(4, Array(0,1,2,3), Array(9,5,2,7))		 //建立稀疏向量
    println(vs(2))											 //打印稀疏向量第3个值
  }
}
import org.apache.spark.{SparkContext, SparkConf}

object testZip{
  def main(args: Array[String]) {
    val conf = new SparkConf()                                        //创建环境变量
      .setMaster("local")                                                //设置本地化处理
      .setAppName("testZip")                                       //设定名称
    val sc = new SparkContext(conf)						       //创建环境变量实例
    val arr1 = Array(1,2,3,4,5,6)							       //创建数据集1
    val arr2 = Array("a","b","c","d","e","f")                                //创建数据集1
    val arr3 = Array("g","h","i","j","k","l")                                 //创建数据集1
    val arr4 = arr1.zip(arr2).zip(arr3)                                   //进行亚述算法
    arr4.foreach(print)                                               //打印结果
  }
}



import org.apache.spark.{SparkContext, SparkConf}
object wordCount {
  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local").setAppName("wordCount")	//创建环境变量
    val sc = new SparkContext(conf)								//创建环境变量实例
    val data = sc.textFile("c://wc.txt")								//读取文件
    data.flatMap(_.split(" ")).map((_, 1)).reduceByKey(_+_).collect().foreach(println)	//word计数
  }
}

