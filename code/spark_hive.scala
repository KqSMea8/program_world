
package org.apache.spark.sql.hive.execution

import scala.util.control.NonFatal

import org.apache.spark.sql.{AnalysisException, Row, SaveMode, SparkSession}
import org.apache.spark.sql.catalyst.catalog.CatalogTable
import org.apache.spark.sql.catalyst.expressions.Attribute
import org.apache.spark.sql.catalyst.plans.logical.LogicalPlan
import org.apache.spark.sql.execution.SparkPlan
import org.apache.spark.sql.execution.command.DataWritingCommand


/**
 * Create table and insert the query result into it.
 *
 * @param tableDesc the Table Describe, which may contain serde, storage handler etc.
 * @param query the query whose result will be insert into the new relation
 * @param mode SaveMode
 */
case class CreateHiveTableAsSelectCommand(
    tableDesc: CatalogTable,
    query: LogicalPlan,
    outputColumnNames: Seq[String],
    mode: SaveMode)
  extends DataWritingCommand {

  private val tableIdentifier = tableDesc.identifier

  override def run(sparkSession: SparkSession, child: SparkPlan): Seq[Row] = {
    val catalog = sparkSession.sessionState.catalog
    if (catalog.tableExists(tableIdentifier)) {
      assert(mode != SaveMode.Overwrite,
        s"Expect the table $tableIdentifier has been dropped when the save mode is Overwrite")

      if (mode == SaveMode.ErrorIfExists) {
        throw new AnalysisException(s"$tableIdentifier already exists.")
      }
      if (mode == SaveMode.Ignore) {
        // Since the table already exists and the save mode is Ignore, we will just return.
        return Seq.empty
      }

      // For CTAS, there is no static partition values to insert.
      val partition = tableDesc.partitionColumnNames.map(_ -> None).toMap
      InsertIntoHiveTable(
        tableDesc,
        partition,
        query,
        overwrite = false,
        ifPartitionNotExists = false,
        outputColumnNames = outputColumnNames).run(sparkSession, child)
    } else {
      // TODO ideally, we should get the output data ready first and then
      // add the relation into catalog, just in case of failure occurs while data
      // processing.
      assert(tableDesc.schema.isEmpty)
      catalog.createTable(
        tableDesc.copy(schema = outputColumns.toStructType), ignoreIfExists = false)

      try {
        // Read back the metadata of the table which was created just now.
        val createdTableMeta = catalog.getTableMetadata(tableDesc.identifier)
        // For CTAS, there is no static partition values to insert.
        val partition = createdTableMeta.partitionColumnNames.map(_ -> None).toMap
        InsertIntoHiveTable(
          createdTableMeta,
          partition,
          query,
          overwrite = true,
          ifPartitionNotExists = false,
          outputColumnNames = outputColumnNames).run(sparkSession, child)
      } catch {
        case NonFatal(e) =>
          // drop the created table.
          catalog.dropTable(tableIdentifier, ignoreIfNotExists = true, purge = false)
          throw e
      }
    }

    Seq.empty[Row]
  }

  override def argString: String = {
    s"[Database:${tableDesc.database}, " +
    s"TableName: ${tableDesc.identifier.table}, " +
    s"InsertIntoHiveTable]"
  }
}

package org.apache.spark.sql.hive.client

import java.io.PrintStream

import org.apache.spark.sql.catalyst.analysis._
import org.apache.spark.sql.catalyst.catalog._
import org.apache.spark.sql.catalyst.catalog.CatalogTypes.TablePartitionSpec
import org.apache.spark.sql.catalyst.expressions.Expression
import org.apache.spark.sql.types.StructType


/**
 * An externally visible interface to the Hive client.  This interface is shared across both the
 * internal and external classloaders for a given version of Hive and thus must expose only
 * shared classes.
 */
private[hive] trait HiveClient {

  /** Returns the Hive Version of this client. */
  def version: HiveVersion

  /** Returns the configuration for the given key in the current session. */
  def getConf(key: String, defaultValue: String): String

  /**
   * Return the associated Hive SessionState of this [[HiveClientImpl]]
   * @return [[Any]] not SessionState to avoid linkage error
   */
  def getState: Any

  /**
   * Runs a HiveQL command using Hive, returning the results as a list of strings.  Each row will
   * result in one string.
   */
  def runSqlHive(sql: String): Seq[String]

  def setOut(stream: PrintStream): Unit
  def setInfo(stream: PrintStream): Unit
  def setError(stream: PrintStream): Unit

  /** Returns the names of all tables in the given database. */
  def listTables(dbName: String): Seq[String]

  /** Returns the names of tables in the given database that matches the given pattern. */
  def listTables(dbName: String, pattern: String): Seq[String]

  /** Sets the name of current database. */
  def setCurrentDatabase(databaseName: String): Unit

  /** Returns the metadata for specified database, throwing an exception if it doesn't exist */
  def getDatabase(name: String): CatalogDatabase

  /** Return whether a table/view with the specified name exists. */
  def databaseExists(dbName: String): Boolean

  /** List the names of all the databases that match the specified pattern. */
  def listDatabases(pattern: String): Seq[String]

  /** Return whether a table/view with the specified name exists. */
  def tableExists(dbName: String, tableName: String): Boolean

  /** Returns the specified table, or throws [[NoSuchTableException]]. */
  final def getTable(dbName: String, tableName: String): CatalogTable = {
    getTableOption(dbName, tableName).getOrElse(throw new NoSuchTableException(dbName, tableName))
  }

  /** Returns the metadata for the specified table or None if it doesn't exist. */
  def getTableOption(dbName: String, tableName: String): Option[CatalogTable]

  /** Creates a table with the given metadata. */
  def createTable(table: CatalogTable, ignoreIfExists: Boolean): Unit

  /** Drop the specified table. */
  def dropTable(dbName: String, tableName: String, ignoreIfNotExists: Boolean, purge: Boolean): Unit

  /** Alter a table whose name matches the one specified in `table`, assuming it exists. */
  final def alterTable(table: CatalogTable): Unit = {
    alterTable(table.database, table.identifier.table, table)
  }

  /**
   * Updates the given table with new metadata, optionally renaming the table or
   * moving across different database.
   */
  def alterTable(dbName: String, tableName: String, table: CatalogTable): Unit

  /**
   * Updates the given table with a new data schema and table properties, and keep everything else
   * unchanged.
   *
   * TODO(cloud-fan): it's a little hacky to introduce the schema table properties here in
   * `HiveClient`, but we don't have a cleaner solution now.
   */
  def alterTableDataSchema(
    dbName: String, tableName: String, newDataSchema: StructType, schemaProps: Map[String, String])

  /** Creates a new database with the given name. */
  def createDatabase(database: CatalogDatabase, ignoreIfExists: Boolean): Unit

  /**
   * Drop the specified database, if it exists.
   *
   * @param name database to drop
   * @param ignoreIfNotExists if true, do not throw error if the database does not exist
   * @param cascade whether to remove all associated objects such as tables and functions
   */
  def dropDatabase(name: String, ignoreIfNotExists: Boolean, cascade: Boolean): Unit

  /**
   * Alter a database whose name matches the one specified in `database`, assuming it exists.
   */
  def alterDatabase(database: CatalogDatabase): Unit

  /**
   * Create one or many partitions in the given table.
   */
  def createPartitions(
      db: String,
      table: String,
      parts: Seq[CatalogTablePartition],
      ignoreIfExists: Boolean): Unit

  /**
   * Drop one or many partitions in the given table, assuming they exist.
   */
  def dropPartitions(
      db: String,
      table: String,
      specs: Seq[TablePartitionSpec],
      ignoreIfNotExists: Boolean,
      purge: Boolean,
      retainData: Boolean): Unit

  /**
   * Rename one or many existing table partitions, assuming they exist.
   */
  def renamePartitions(
      db: String,
      table: String,
      specs: Seq[TablePartitionSpec],
      newSpecs: Seq[TablePartitionSpec]): Unit

  /**
   * Alter one or more table partitions whose specs match the ones specified in `newParts`,
   * assuming the partitions exist.
   */
  def alterPartitions(
      db: String,
      table: String,
      newParts: Seq[CatalogTablePartition]): Unit

  /** Returns the specified partition, or throws [[NoSuchPartitionException]]. */
  final def getPartition(
      dbName: String,
      tableName: String,
      spec: TablePartitionSpec): CatalogTablePartition = {
    getPartitionOption(dbName, tableName, spec).getOrElse {
      throw new NoSuchPartitionException(dbName, tableName, spec)
    }
  }

  /**
   * Returns the partition names for the given table that match the supplied partition spec.
   * If no partition spec is specified, all partitions are returned.
   *
   * The returned sequence is sorted as strings.
   */
  def getPartitionNames(
      table: CatalogTable,
      partialSpec: Option[TablePartitionSpec] = None): Seq[String]

  /** Returns the specified partition or None if it does not exist. */
  final def getPartitionOption(
      db: String,
      table: String,
      spec: TablePartitionSpec): Option[CatalogTablePartition] = {
    getPartitionOption(getTable(db, table), spec)
  }

  /** Returns the specified partition or None if it does not exist. */
  def getPartitionOption(
      table: CatalogTable,
      spec: TablePartitionSpec): Option[CatalogTablePartition]

  /**
   * Returns the partitions for the given table that match the supplied partition spec.
   * If no partition spec is specified, all partitions are returned.
   */
  final def getPartitions(
      db: String,
      table: String,
      partialSpec: Option[TablePartitionSpec]): Seq[CatalogTablePartition] = {
    getPartitions(getTable(db, table), partialSpec)
  }

  /**
   * Returns the partitions for the given table that match the supplied partition spec.
   * If no partition spec is specified, all partitions are returned.
   */
  def getPartitions(
      catalogTable: CatalogTable,
      partialSpec: Option[TablePartitionSpec] = None): Seq[CatalogTablePartition]

  /** Returns partitions filtered by predicates for the given table. */
  def getPartitionsByFilter(
      catalogTable: CatalogTable,
      predicates: Seq[Expression]): Seq[CatalogTablePartition]

  /** Loads a static partition into an existing table. */
  def loadPartition(
      loadPath: String,
      dbName: String,
      tableName: String,
      partSpec: java.util.LinkedHashMap[String, String], // Hive relies on LinkedHashMap ordering
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSrcLocal: Boolean): Unit

  /** Loads data into an existing table. */
  def loadTable(
      loadPath: String, // TODO URI
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit

  /** Loads new dynamic partitions into an existing table. */
  def loadDynamicPartitions(
      loadPath: String,
      dbName: String,
      tableName: String,
      partSpec: java.util.LinkedHashMap[String, String], // Hive relies on LinkedHashMap ordering
      replace: Boolean,
      numDP: Int): Unit

  /** Create a function in an existing database. */
  def createFunction(db: String, func: CatalogFunction): Unit

  /** Drop an existing function in the database. */
  def dropFunction(db: String, name: String): Unit

  /** Rename an existing function in the database. */
  def renameFunction(db: String, oldName: String, newName: String): Unit

  /** Alter a function whose name matches the one specified in `func`, assuming it exists. */
  def alterFunction(db: String, func: CatalogFunction): Unit

  /** Return an existing function in the database, assuming it exists. */
  final def getFunction(db: String, name: String): CatalogFunction = {
    getFunctionOption(db, name).getOrElse(throw new NoSuchPermanentFunctionException(db, name))
  }

  /** Return an existing function in the database, or None if it doesn't exist. */
  def getFunctionOption(db: String, name: String): Option[CatalogFunction]

  /** Return whether a function exists in the specified database. */
  final def functionExists(db: String, name: String): Boolean = {
    getFunctionOption(db, name).isDefined
  }

  /** Return the names of all functions that match the given pattern in the database. */
  def listFunctions(db: String, pattern: String): Seq[String]

  /** Add a jar into class loader */
  def addJar(path: String): Unit

  /** Return a [[HiveClient]] as new session, that will share the class loader and Hive client */
  def newSession(): HiveClient

  /** Run a function within Hive state (SessionState, HiveConf, Hive client and class loader) */
  def withHiveState[A](f: => A): A

  /** Used for testing only.  Removes all metadata from this instance of Hive. */
  def reset(): Unit

}

package org.apache.spark.sql.hive.client

import java.io.{File, PrintStream}
import java.lang.{Iterable => JIterable}
import java.util.{Locale, Map => JMap}

import scala.collection.JavaConverters._
import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

import org.apache.hadoop.fs.Path
import org.apache.hadoop.hive.common.StatsSetupConst
import org.apache.hadoop.hive.conf.HiveConf
import org.apache.hadoop.hive.conf.HiveConf.ConfVars
import org.apache.hadoop.hive.metastore.{TableType => HiveTableType}
import org.apache.hadoop.hive.metastore.api.{Database => HiveDatabase, FieldSchema, Order}
import org.apache.hadoop.hive.metastore.api.{SerDeInfo, StorageDescriptor}
import org.apache.hadoop.hive.ql.Driver
import org.apache.hadoop.hive.ql.metadata.{Hive, Partition => HivePartition, Table => HiveTable}
import org.apache.hadoop.hive.ql.parse.BaseSemanticAnalyzer.HIVE_COLUMN_ORDER_ASC
import org.apache.hadoop.hive.ql.processors._
import org.apache.hadoop.hive.ql.session.SessionState

import org.apache.spark.{SparkConf, SparkException}
import org.apache.spark.internal.Logging
import org.apache.spark.metrics.source.HiveCatalogMetrics
import org.apache.spark.sql.AnalysisException
import org.apache.spark.sql.catalyst.TableIdentifier
import org.apache.spark.sql.catalyst.analysis.{NoSuchDatabaseException, NoSuchPartitionException}
import org.apache.spark.sql.catalyst.catalog._
import org.apache.spark.sql.catalyst.catalog.CatalogTypes.TablePartitionSpec
import org.apache.spark.sql.catalyst.expressions.Expression
import org.apache.spark.sql.catalyst.parser.{CatalystSqlParser, ParseException}
import org.apache.spark.sql.execution.QueryExecutionException
import org.apache.spark.sql.execution.command.DDLUtils
import org.apache.spark.sql.hive.HiveExternalCatalog.{DATASOURCE_SCHEMA, DATASOURCE_SCHEMA_NUMPARTS, DATASOURCE_SCHEMA_PART_PREFIX}
import org.apache.spark.sql.hive.client.HiveClientImpl._
import org.apache.spark.sql.types._
import org.apache.spark.util.{CircularBuffer, Utils}

/**
 * A class that wraps the HiveClient and converts its responses to externally visible classes.
 * Note that this class is typically loaded with an internal classloader for each instantiation,
 * allowing it to interact directly with a specific isolated version of Hive.  Loading this class
 * with the isolated classloader however will result in it only being visible as a [[HiveClient]],
 * not a [[HiveClientImpl]].
 *
 * This class needs to interact with multiple versions of Hive, but will always be compiled with
 * the 'native', execution version of Hive.  Therefore, any places where hive breaks compatibility
 * must use reflection after matching on `version`.
 *
 * Every HiveClientImpl creates an internal HiveConf object. This object is using the given
 * `hadoopConf` as the base. All options set in the `sparkConf` will be applied to the HiveConf
 * object and overrides any exiting options. Then, options in extraConfig will be applied
 * to the HiveConf object and overrides any existing options.
 *
 * @param version the version of hive used when pick function calls that are not compatible.
 * @param sparkConf all configuration options set in SparkConf.
 * @param hadoopConf the base Configuration object used by the HiveConf created inside
 *                   this HiveClientImpl.
 * @param extraConfig a collection of configuration options that will be added to the
 *                hive conf before opening the hive client.
 * @param initClassLoader the classloader used when creating the `state` field of
 *                        this [[HiveClientImpl]].
 */
private[hive] class HiveClientImpl(
    override val version: HiveVersion,
    warehouseDir: Option[String],
    sparkConf: SparkConf,
    hadoopConf: JIterable[JMap.Entry[String, String]],
    extraConfig: Map[String, String],
    initClassLoader: ClassLoader,
    val clientLoader: IsolatedClientLoader)
  extends HiveClient
  with Logging {

  // Circular buffer to hold what hive prints to STDOUT and ERR.  Only printed when failures occur.
  private val outputBuffer = new CircularBuffer()

  private val shim = version match {
    case hive.v12 => new Shim_v0_12()
    case hive.v13 => new Shim_v0_13()
    case hive.v14 => new Shim_v0_14()
    case hive.v1_0 => new Shim_v1_0()
    case hive.v1_1 => new Shim_v1_1()
    case hive.v1_2 => new Shim_v1_2()
    case hive.v2_0 => new Shim_v2_0()
    case hive.v2_1 => new Shim_v2_1()
    case hive.v2_2 => new Shim_v2_2()
    case hive.v2_3 => new Shim_v2_3()
  }

  // Create an internal session state for this HiveClientImpl.
  val state: SessionState = {
    val original = Thread.currentThread().getContextClassLoader
    if (clientLoader.isolationOn) {
      // Switch to the initClassLoader.
      Thread.currentThread().setContextClassLoader(initClassLoader)
      try {
        newState()
      } finally {
        Thread.currentThread().setContextClassLoader(original)
      }
    } else {
      // Isolation off means we detect a CliSessionState instance in current thread.
      // 1: Inside the spark project, we have already started a CliSessionState in
      // `SparkSQLCLIDriver`, which contains configurations from command lines. Later, we call
      // `SparkSQLEnv.init()` there, which would new a hive client again. so we should keep those
      // configurations and reuse the existing instance of `CliSessionState`. In this case,
      // SessionState.get will always return a CliSessionState.
      // 2: In another case, a user app may start a CliSessionState outside spark project with built
      // in hive jars, which will turn off isolation, if SessionSate.detachSession is
      // called to remove the current state after that, hive client created later will initialize
      // its own state by newState()
      val ret = SessionState.get
      if (ret != null) {
        // hive.metastore.warehouse.dir is determined in SharedState after the CliSessionState
        // instance constructed, we need to follow that change here.
        warehouseDir.foreach { dir =>
          ret.getConf.setVar(ConfVars.METASTOREWAREHOUSE, dir)
        }
        ret
      } else {
        newState()
      }
    }
  }

  // Log the default warehouse location.
  logInfo(
    s"Warehouse location for Hive client " +
      s"(version ${version.fullVersion}) is ${conf.getVar(ConfVars.METASTOREWAREHOUSE)}")

  private def newState(): SessionState = {
    val hiveConf = new HiveConf(classOf[SessionState])
    // HiveConf is a Hadoop Configuration, which has a field of classLoader and
    // the initial value will be the current thread's context class loader
    // (i.e. initClassLoader at here).
    // We call initialConf.setClassLoader(initClassLoader) at here to make
    // this action explicit.
    hiveConf.setClassLoader(initClassLoader)

    // 1: Take all from the hadoopConf to this hiveConf.
    // This hadoopConf contains user settings in Hadoop's core-site.xml file
    // and Hive's hive-site.xml file. Note, we load hive-site.xml file manually in
    // SharedState and put settings in this hadoopConf instead of relying on HiveConf
    // to load user settings. Otherwise, HiveConf's initialize method will override
    // settings in the hadoopConf. This issue only shows up when spark.sql.hive.metastore.jars
    // is not set to builtin. When spark.sql.hive.metastore.jars is builtin, the classpath
    // has hive-site.xml. So, HiveConf will use that to override its default values.
    // 2: we set all spark confs to this hiveConf.
    // 3: we set all entries in config to this hiveConf.
    (hadoopConf.iterator().asScala.map(kv => kv.getKey -> kv.getValue)
      ++ sparkConf.getAll.toMap ++ extraConfig).foreach { case (k, v) =>
      logDebug(
        s"""
           |Applying Hadoop/Hive/Spark and extra properties to Hive Conf:
           |$k=${if (k.toLowerCase(Locale.ROOT).contains("password")) "xxx" else v}
         """.stripMargin)
      hiveConf.set(k, v)
    }
    val state = new SessionState(hiveConf)
    if (clientLoader.cachedHive != null) {
      Hive.set(clientLoader.cachedHive.asInstanceOf[Hive])
    }
    SessionState.start(state)
    state.out = new PrintStream(outputBuffer, true, "UTF-8")
    state.err = new PrintStream(outputBuffer, true, "UTF-8")
    state
  }

  /** Returns the configuration for the current session. */
  def conf: HiveConf = state.getConf

  private val userName = conf.getUser

  override def getConf(key: String, defaultValue: String): String = {
    conf.get(key, defaultValue)
  }

  // We use hive's conf for compatibility.
  private val retryLimit = conf.getIntVar(HiveConf.ConfVars.METASTORETHRIFTFAILURERETRIES)
  private val retryDelayMillis = shim.getMetastoreClientConnectRetryDelayMillis(conf)

  /**
   * Runs `f` with multiple retries in case the hive metastore is temporarily unreachable.
   */
  private def retryLocked[A](f: => A): A = clientLoader.synchronized {
    // Hive sometimes retries internally, so set a deadline to avoid compounding delays.
    val deadline = System.nanoTime + (retryLimit * retryDelayMillis * 1e6).toLong
    var numTries = 0
    var caughtException: Exception = null
    do {
      numTries += 1
      try {
        return f
      } catch {
        case e: Exception if causedByThrift(e) =>
          caughtException = e
          logWarning(
            "HiveClient got thrift exception, destroying client and retrying " +
              s"(${retryLimit - numTries} tries remaining)", e)
          clientLoader.cachedHive = null
          Thread.sleep(retryDelayMillis)
      }
    } while (numTries <= retryLimit && System.nanoTime < deadline)
    if (System.nanoTime > deadline) {
      logWarning("Deadline exceeded")
    }
    throw caughtException
  }

  private def causedByThrift(e: Throwable): Boolean = {
    var target = e
    while (target != null) {
      val msg = target.getMessage()
      if (msg != null && msg.matches("(?s).*(TApplication|TProtocol|TTransport)Exception.*")) {
        return true
      }
      target = target.getCause()
    }
    false
  }

  private def client: Hive = {
    if (clientLoader.cachedHive != null) {
      clientLoader.cachedHive.asInstanceOf[Hive]
    } else {
      val c = Hive.get(conf)
      clientLoader.cachedHive = c
      c
    }
  }

  /** Return the associated Hive [[SessionState]] of this [[HiveClientImpl]] */
  override def getState: SessionState = withHiveState(state)

  /**
   * Runs `f` with ThreadLocal session state and classloaders configured for this version of hive.
   */
  def withHiveState[A](f: => A): A = retryLocked {
    val original = Thread.currentThread().getContextClassLoader
    val originalConfLoader = state.getConf.getClassLoader
    // The classloader in clientLoader could be changed after addJar, always use the latest
    // classloader. We explicitly set the context class loader since "conf.setClassLoader" does
    // not do that, and the Hive client libraries may need to load classes defined by the client's
    // class loader.
    Thread.currentThread().setContextClassLoader(clientLoader.classLoader)
    state.getConf.setClassLoader(clientLoader.classLoader)
    // Set the thread local metastore client to the client associated with this HiveClientImpl.
    Hive.set(client)
    // Replace conf in the thread local Hive with current conf
    Hive.get(conf)
    // setCurrentSessionState will use the classLoader associated
    // with the HiveConf in `state` to override the context class loader of the current
    // thread.
    shim.setCurrentSessionState(state)
    val ret = try f finally {
      state.getConf.setClassLoader(originalConfLoader)
      Thread.currentThread().setContextClassLoader(original)
      HiveCatalogMetrics.incrementHiveClientCalls(1)
    }
    ret
  }

  def setOut(stream: PrintStream): Unit = withHiveState {
    state.out = stream
  }

  def setInfo(stream: PrintStream): Unit = withHiveState {
    state.info = stream
  }

  def setError(stream: PrintStream): Unit = withHiveState {
    state.err = stream
  }

  private def setCurrentDatabaseRaw(db: String): Unit = {
    if (state.getCurrentDatabase != db) {
      if (databaseExists(db)) {
        state.setCurrentDatabase(db)
      } else {
        throw new NoSuchDatabaseException(db)
      }
    }
  }

  override def setCurrentDatabase(databaseName: String): Unit = withHiveState {
    setCurrentDatabaseRaw(databaseName)
  }

  override def createDatabase(
      database: CatalogDatabase,
      ignoreIfExists: Boolean): Unit = withHiveState {
    client.createDatabase(
      new HiveDatabase(
        database.name,
        database.description,
        CatalogUtils.URIToString(database.locationUri),
        Option(database.properties).map(_.asJava).orNull),
        ignoreIfExists)
  }

  override def dropDatabase(
      name: String,
      ignoreIfNotExists: Boolean,
      cascade: Boolean): Unit = withHiveState {
    client.dropDatabase(name, true, ignoreIfNotExists, cascade)
  }

  override def alterDatabase(database: CatalogDatabase): Unit = withHiveState {
    client.alterDatabase(
      database.name,
      new HiveDatabase(
        database.name,
        database.description,
        CatalogUtils.URIToString(database.locationUri),
        Option(database.properties).map(_.asJava).orNull))
  }

  override def getDatabase(dbName: String): CatalogDatabase = withHiveState {
    Option(client.getDatabase(dbName)).map { d =>
      CatalogDatabase(
        name = d.getName,
        description = Option(d.getDescription).getOrElse(""),
        locationUri = CatalogUtils.stringToURI(d.getLocationUri),
        properties = Option(d.getParameters).map(_.asScala.toMap).orNull)
    }.getOrElse(throw new NoSuchDatabaseException(dbName))
  }

  override def databaseExists(dbName: String): Boolean = withHiveState {
    client.databaseExists(dbName)
  }

  override def listDatabases(pattern: String): Seq[String] = withHiveState {
    client.getDatabasesByPattern(pattern).asScala
  }

  private def getRawTableOption(dbName: String, tableName: String): Option[HiveTable] = {
    Option(client.getTable(dbName, tableName, false /* do not throw exception */))
  }

  override def tableExists(dbName: String, tableName: String): Boolean = withHiveState {
    getRawTableOption(dbName, tableName).nonEmpty
  }

  override def getTableOption(
      dbName: String,
      tableName: String): Option[CatalogTable] = withHiveState {
    logDebug(s"Looking up $dbName.$tableName")
    getRawTableOption(dbName, tableName).map { h =>
      // Note: Hive separates partition columns and the schema, but for us the
      // partition columns are part of the schema
      val cols = h.getCols.asScala.map(fromHiveColumn)
      val partCols = h.getPartCols.asScala.map(fromHiveColumn)
      val schema = StructType(cols ++ partCols)

      val bucketSpec = if (h.getNumBuckets > 0) {
        val sortColumnOrders = h.getSortCols.asScala
        // Currently Spark only supports columns to be sorted in ascending order
        // but Hive can support both ascending and descending order. If all the columns
        // are sorted in ascending order, only then propagate the sortedness information
        // to downstream processing / optimizations in Spark
        // TODO: In future we can have Spark support columns sorted in descending order
        val allAscendingSorted = sortColumnOrders.forall(_.getOrder == HIVE_COLUMN_ORDER_ASC)

        val sortColumnNames = if (allAscendingSorted) {
          sortColumnOrders.map(_.getCol)
        } else {
          Seq.empty
        }
        Option(BucketSpec(h.getNumBuckets, h.getBucketCols.asScala, sortColumnNames))
      } else {
        None
      }

      // Skew spec and storage handler can't be mapped to CatalogTable (yet)
      val unsupportedFeatures = ArrayBuffer.empty[String]

      if (!h.getSkewedColNames.isEmpty) {
        unsupportedFeatures += "skewed columns"
      }

      if (h.getStorageHandler != null) {
        unsupportedFeatures += "storage handler"
      }

      if (h.getTableType == HiveTableType.VIRTUAL_VIEW && partCols.nonEmpty) {
        unsupportedFeatures += "partitioned view"
      }

      val properties = Option(h.getParameters).map(_.asScala.toMap).orNull

      // Hive-generated Statistics are also recorded in ignoredProperties
      val ignoredProperties = scala.collection.mutable.Map.empty[String, String]
      for (key <- HiveStatisticsProperties; value <- properties.get(key)) {
        ignoredProperties += key -> value
      }

      val excludedTableProperties = HiveStatisticsProperties ++ Set(
        // The property value of "comment" is moved to the dedicated field "comment"
        "comment",
        // For EXTERNAL_TABLE, the table properties has a particular field "EXTERNAL". This is added
        // in the function toHiveTable.
        "EXTERNAL"
      )

      val filteredProperties = properties.filterNot {
        case (key, _) => excludedTableProperties.contains(key)
      }
      val comment = properties.get("comment")

      CatalogTable(
        identifier = TableIdentifier(h.getTableName, Option(h.getDbName)),
        tableType = h.getTableType match {
          case HiveTableType.EXTERNAL_TABLE => CatalogTableType.EXTERNAL
          case HiveTableType.MANAGED_TABLE => CatalogTableType.MANAGED
          case HiveTableType.VIRTUAL_VIEW => CatalogTableType.VIEW
          case unsupportedType =>
            val tableTypeStr = unsupportedType.toString.toLowerCase(Locale.ROOT).replace("_", " ")
            throw new AnalysisException(s"Hive $tableTypeStr is not supported.")
        },
        schema = schema,
        partitionColumnNames = partCols.map(_.name),
        // If the table is written by Spark, we will put bucketing information in table properties,
        // and will always overwrite the bucket spec in hive metastore by the bucketing information
        // in table properties. This means, if we have bucket spec in both hive metastore and
        // table properties, we will trust the one in table properties.
        bucketSpec = bucketSpec,
        owner = Option(h.getOwner).getOrElse(""),
        createTime = h.getTTable.getCreateTime.toLong * 1000,
        lastAccessTime = h.getLastAccessTime.toLong * 1000,
        storage = CatalogStorageFormat(
          locationUri = shim.getDataLocation(h).map(CatalogUtils.stringToURI),
          // To avoid ClassNotFound exception, we try our best to not get the format class, but get
          // the class name directly. However, for non-native tables, there is no interface to get
          // the format class name, so we may still throw ClassNotFound in this case.
          inputFormat = Option(h.getTTable.getSd.getInputFormat).orElse {
            Option(h.getStorageHandler).map(_.getInputFormatClass.getName)
          },
          outputFormat = Option(h.getTTable.getSd.getOutputFormat).orElse {
            Option(h.getStorageHandler).map(_.getOutputFormatClass.getName)
          },
          serde = Option(h.getSerializationLib),
          compressed = h.getTTable.getSd.isCompressed,
          properties = Option(h.getTTable.getSd.getSerdeInfo.getParameters)
            .map(_.asScala.toMap).orNull
        ),
        // For EXTERNAL_TABLE, the table properties has a particular field "EXTERNAL". This is added
        // in the function toHiveTable.
        properties = filteredProperties,
        stats = readHiveStats(properties),
        comment = comment,
        // In older versions of Spark(before 2.2.0), we expand the view original text and store
        // that into `viewExpandedText`, and that should be used in view resolution. So we get
        // `viewExpandedText` instead of `viewOriginalText` for viewText here.
        viewText = Option(h.getViewExpandedText),
        unsupportedFeatures = unsupportedFeatures,
        ignoredProperties = ignoredProperties.toMap)
    }
  }

  override def createTable(table: CatalogTable, ignoreIfExists: Boolean): Unit = withHiveState {
    verifyColumnDataType(table.dataSchema)
    client.createTable(toHiveTable(table, Some(userName)), ignoreIfExists)
  }

  override def dropTable(
      dbName: String,
      tableName: String,
      ignoreIfNotExists: Boolean,
      purge: Boolean): Unit = withHiveState {
    shim.dropTable(client, dbName, tableName, true, ignoreIfNotExists, purge)
  }

  override def alterTable(
      dbName: String,
      tableName: String,
      table: CatalogTable): Unit = withHiveState {
    // getTableOption removes all the Hive-specific properties. Here, we fill them back to ensure
    // these properties are still available to the others that share the same Hive metastore.
    // If users explicitly alter these Hive-specific properties through ALTER TABLE DDL, we respect
    // these user-specified values.
    verifyColumnDataType(table.dataSchema)
    val hiveTable = toHiveTable(
      table.copy(properties = table.ignoredProperties ++ table.properties), Some(userName))
    // Do not use `table.qualifiedName` here because this may be a rename
    val qualifiedTableName = s"$dbName.$tableName"
    shim.alterTable(client, qualifiedTableName, hiveTable)
  }

  override def alterTableDataSchema(
      dbName: String,
      tableName: String,
      newDataSchema: StructType,
      schemaProps: Map[String, String]): Unit = withHiveState {
    val oldTable = client.getTable(dbName, tableName)
    verifyColumnDataType(newDataSchema)
    val hiveCols = newDataSchema.map(toHiveColumn)
    oldTable.setFields(hiveCols.asJava)

    // remove old schema table properties
    val it = oldTable.getParameters.entrySet.iterator
    while (it.hasNext) {
      val entry = it.next()
      val isSchemaProp = entry.getKey.startsWith(DATASOURCE_SCHEMA_PART_PREFIX) ||
        entry.getKey == DATASOURCE_SCHEMA || entry.getKey == DATASOURCE_SCHEMA_NUMPARTS
      if (isSchemaProp) {
        it.remove()
      }
    }

    // set new schema table properties
    schemaProps.foreach { case (k, v) => oldTable.setProperty(k, v) }

    val qualifiedTableName = s"$dbName.$tableName"
    shim.alterTable(client, qualifiedTableName, oldTable)
  }

  override def createPartitions(
      db: String,
      table: String,
      parts: Seq[CatalogTablePartition],
      ignoreIfExists: Boolean): Unit = withHiveState {
    shim.createPartitions(client, db, table, parts, ignoreIfExists)
  }

  override def dropPartitions(
      db: String,
      table: String,
      specs: Seq[TablePartitionSpec],
      ignoreIfNotExists: Boolean,
      purge: Boolean,
      retainData: Boolean): Unit = withHiveState {
    // TODO: figure out how to drop multiple partitions in one call
    val hiveTable = client.getTable(db, table, true /* throw exception */)
    // do the check at first and collect all the matching partitions
    val matchingParts =
      specs.flatMap { s =>
        assert(s.values.forall(_.nonEmpty), s"partition spec '$s' is invalid")
        // The provided spec here can be a partial spec, i.e. it will match all partitions
        // whose specs are supersets of this partial spec. E.g. If a table has partitions
        // (b='1', c='1') and (b='1', c='2'), a partial spec of (b='1') will match both.
        val parts = client.getPartitions(hiveTable, s.asJava).asScala
        if (parts.isEmpty && !ignoreIfNotExists) {
          throw new AnalysisException(
            s"No partition is dropped. One partition spec '$s' does not exist in table '$table' " +
            s"database '$db'")
        }
        parts.map(_.getValues)
      }.distinct
    var droppedParts = ArrayBuffer.empty[java.util.List[String]]
    matchingParts.foreach { partition =>
      try {
        shim.dropPartition(client, db, table, partition, !retainData, purge)
      } catch {
        case e: Exception =>
          val remainingParts = matchingParts.toBuffer -- droppedParts
          logError(
            s"""
               |======================
               |Attempt to drop the partition specs in table '$table' database '$db':
               |${specs.mkString("\n")}
               |In this attempt, the following partitions have been dropped successfully:
               |${droppedParts.mkString("\n")}
               |The remaining partitions have not been dropped:
               |${remainingParts.mkString("\n")}
               |======================
             """.stripMargin)
          throw e
      }
      droppedParts += partition
    }
  }

  override def renamePartitions(
      db: String,
      table: String,
      specs: Seq[TablePartitionSpec],
      newSpecs: Seq[TablePartitionSpec]): Unit = withHiveState {
    require(specs.size == newSpecs.size, "number of old and new partition specs differ")
    val catalogTable = getTable(db, table)
    val hiveTable = toHiveTable(catalogTable, Some(userName))
    specs.zip(newSpecs).foreach { case (oldSpec, newSpec) =>
      val hivePart = getPartitionOption(catalogTable, oldSpec)
        .map { p => toHivePartition(p.copy(spec = newSpec), hiveTable) }
        .getOrElse { throw new NoSuchPartitionException(db, table, oldSpec) }
      client.renamePartition(hiveTable, oldSpec.asJava, hivePart)
    }
  }

  override def alterPartitions(
      db: String,
      table: String,
      newParts: Seq[CatalogTablePartition]): Unit = withHiveState {
    // Note: Before altering table partitions in Hive, you *must* set the current database
    // to the one that contains the table of interest. Otherwise you will end up with the
    // most helpful error message ever: "Unable to alter partition. alter is not possible."
    // See HIVE-2742 for more detail.
    val original = state.getCurrentDatabase
    try {
      setCurrentDatabaseRaw(db)
      val hiveTable = toHiveTable(getTable(db, table), Some(userName))
      shim.alterPartitions(client, table, newParts.map { toHivePartition(_, hiveTable) }.asJava)
    } finally {
      state.setCurrentDatabase(original)
    }
  }

  /**
   * Returns the partition names for the given table that match the supplied partition spec.
   * If no partition spec is specified, all partitions are returned.
   *
   * The returned sequence is sorted as strings.
   */
  override def getPartitionNames(
      table: CatalogTable,
      partialSpec: Option[TablePartitionSpec] = None): Seq[String] = withHiveState {
    val hivePartitionNames =
      partialSpec match {
        case None =>
          // -1 for result limit means "no limit/return all"
          client.getPartitionNames(table.database, table.identifier.table, -1)
        case Some(s) =>
          assert(s.values.forall(_.nonEmpty), s"partition spec '$s' is invalid")
          client.getPartitionNames(table.database, table.identifier.table, s.asJava, -1)
      }
    hivePartitionNames.asScala.sorted
  }

  override def getPartitionOption(
      table: CatalogTable,
      spec: TablePartitionSpec): Option[CatalogTablePartition] = withHiveState {
    val hiveTable = toHiveTable(table, Some(userName))
    val hivePartition = client.getPartition(hiveTable, spec.asJava, false)
    Option(hivePartition).map(fromHivePartition)
  }

  /**
   * Returns the partitions for the given table that match the supplied partition spec.
   * If no partition spec is specified, all partitions are returned.
   */
  override def getPartitions(
      table: CatalogTable,
      spec: Option[TablePartitionSpec]): Seq[CatalogTablePartition] = withHiveState {
    val hiveTable = toHiveTable(table, Some(userName))
    val partSpec = spec match {
      case None => CatalogTypes.emptyTablePartitionSpec
      case Some(s) =>
        assert(s.values.forall(_.nonEmpty), s"partition spec '$s' is invalid")
        s
    }
    val parts = client.getPartitions(hiveTable, partSpec.asJava).asScala.map(fromHivePartition)
    HiveCatalogMetrics.incrementFetchedPartitions(parts.length)
    parts
  }

  override def getPartitionsByFilter(
      table: CatalogTable,
      predicates: Seq[Expression]): Seq[CatalogTablePartition] = withHiveState {
    val hiveTable = toHiveTable(table, Some(userName))
    val parts = shim.getPartitionsByFilter(client, hiveTable, predicates).map(fromHivePartition)
    HiveCatalogMetrics.incrementFetchedPartitions(parts.length)
    parts
  }

  override def listTables(dbName: String): Seq[String] = withHiveState {
    client.getAllTables(dbName).asScala
  }

  override def listTables(dbName: String, pattern: String): Seq[String] = withHiveState {
    client.getTablesByPattern(dbName, pattern).asScala
  }

  /**
   * Runs the specified SQL query using Hive.
   */
  override def runSqlHive(sql: String): Seq[String] = {
    val maxResults = 100000
    val results = runHive(sql, maxResults)
    // It is very confusing when you only get back some of the results...
    if (results.size == maxResults) sys.error("RESULTS POSSIBLY TRUNCATED")
    results
  }

  /**
   * Execute the command using Hive and return the results as a sequence. Each element
   * in the sequence is one row.
   */
  protected def runHive(cmd: String, maxRows: Int = 1000): Seq[String] = withHiveState {
    logDebug(s"Running hiveql '$cmd'")
    if (cmd.toLowerCase(Locale.ROOT).startsWith("set")) { logDebug(s"Changing config: $cmd") }
    try {
      val cmd_trimmed: String = cmd.trim()
      val tokens: Array[String] = cmd_trimmed.split("\\s+")
      // The remainder of the command.
      val cmd_1: String = cmd_trimmed.substring(tokens(0).length()).trim()
      val proc = shim.getCommandProcessor(tokens(0), conf)
      proc match {
        case driver: Driver =>
          val response: CommandProcessorResponse = driver.run(cmd)
          // Throw an exception if there is an error in query processing.
          if (response.getResponseCode != 0) {
            driver.close()
            CommandProcessorFactory.clean(conf)
            throw new QueryExecutionException(response.getErrorMessage)
          }
          driver.setMaxRows(maxRows)

          val results = shim.getDriverResults(driver)
          driver.close()
          CommandProcessorFactory.clean(conf)
          results

        case _ =>
          if (state.out != null) {
            // scalastyle:off println
            state.out.println(tokens(0) + " " + cmd_1)
            // scalastyle:on println
          }
          Seq(proc.run(cmd_1).getResponseCode.toString)
      }
    } catch {
      case e: Exception =>
        logError(
          s"""
            |======================
            |HIVE FAILURE OUTPUT
            |======================
            |${outputBuffer.toString}
            |======================
            |END HIVE FAILURE OUTPUT
            |======================
          """.stripMargin)
        throw e
    }
  }

  def loadPartition(
      loadPath: String,
      dbName: String,
      tableName: String,
      partSpec: java.util.LinkedHashMap[String, String],
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSrcLocal: Boolean): Unit = withHiveState {
    val hiveTable = client.getTable(dbName, tableName, true /* throw exception */)
    shim.loadPartition(
      client,
      new Path(loadPath), // TODO: Use URI
      s"$dbName.$tableName",
      partSpec,
      replace,
      inheritTableSpecs,
      isSkewedStoreAsSubdir = hiveTable.isStoredAsSubDirectories,
      isSrcLocal = isSrcLocal)
  }

  def loadTable(
      loadPath: String, // TODO URI
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit = withHiveState {
    shim.loadTable(
      client,
      new Path(loadPath),
      tableName,
      replace,
      isSrcLocal)
  }

  def loadDynamicPartitions(
      loadPath: String,
      dbName: String,
      tableName: String,
      partSpec: java.util.LinkedHashMap[String, String],
      replace: Boolean,
      numDP: Int): Unit = withHiveState {
    val hiveTable = client.getTable(dbName, tableName, true /* throw exception */)
    shim.loadDynamicPartitions(
      client,
      new Path(loadPath),
      s"$dbName.$tableName",
      partSpec,
      replace,
      numDP,
      listBucketingEnabled = hiveTable.isStoredAsSubDirectories)
  }

  override def createFunction(db: String, func: CatalogFunction): Unit = withHiveState {
    shim.createFunction(client, db, func)
  }

  override def dropFunction(db: String, name: String): Unit = withHiveState {
    shim.dropFunction(client, db, name)
  }

  override def renameFunction(db: String, oldName: String, newName: String): Unit = withHiveState {
    shim.renameFunction(client, db, oldName, newName)
  }

  override def alterFunction(db: String, func: CatalogFunction): Unit = withHiveState {
    shim.alterFunction(client, db, func)
  }

  override def getFunctionOption(
      db: String, name: String): Option[CatalogFunction] = withHiveState {
    shim.getFunctionOption(client, db, name)
  }

  override def listFunctions(db: String, pattern: String): Seq[String] = withHiveState {
    shim.listFunctions(client, db, pattern)
  }

  def addJar(path: String): Unit = {
    val uri = new Path(path).toUri
    val jarURL = if (uri.getScheme == null) {
      // `path` is a local file path without a URL scheme
      new File(path).toURI.toURL
    } else {
      // `path` is a URL with a scheme
      uri.toURL
    }
    clientLoader.addJar(jarURL)
    runSqlHive(s"ADD JAR $path")
  }

  def newSession(): HiveClientImpl = {
    clientLoader.createClient().asInstanceOf[HiveClientImpl]
  }

  def reset(): Unit = withHiveState {
    client.getAllTables("default").asScala.foreach { t =>
      logDebug(s"Deleting table $t")
      val table = client.getTable("default", t)
      client.getIndexes("default", t, 255).asScala.foreach { index =>
        shim.dropIndex(client, "default", t, index.getIndexName)
      }
      if (!table.isIndexTable) {
        client.dropTable("default", t)
      }
    }
    client.getAllDatabases.asScala.filterNot(_ == "default").foreach { db =>
      logDebug(s"Dropping Database: $db")
      client.dropDatabase(db, true, false, true)
    }
  }
}

private[hive] object HiveClientImpl {
  /** Converts the native StructField to Hive's FieldSchema. */
  def toHiveColumn(c: StructField): FieldSchema = {
    val typeString = if (c.metadata.contains(HIVE_TYPE_STRING)) {
      c.metadata.getString(HIVE_TYPE_STRING)
    } else {
      c.dataType.catalogString
    }
    new FieldSchema(c.name, typeString, c.getComment().orNull)
  }

  /** Get the Spark SQL native DataType from Hive's FieldSchema. */
  private def getSparkSQLDataType(hc: FieldSchema): DataType = {
    try {
      CatalystSqlParser.parseDataType(hc.getType)
    } catch {
      case e: ParseException =>
        throw new SparkException("Cannot recognize hive type string: " + hc.getType, e)
    }
  }

  /** Builds the native StructField from Hive's FieldSchema. */
  def fromHiveColumn(hc: FieldSchema): StructField = {
    val columnType = getSparkSQLDataType(hc)
    val metadata = if (hc.getType != columnType.catalogString) {
      new MetadataBuilder().putString(HIVE_TYPE_STRING, hc.getType).build()
    } else {
      Metadata.empty
    }

    val field = StructField(
      name = hc.getName,
      dataType = columnType,
      nullable = true,
      metadata = metadata)
    Option(hc.getComment).map(field.withComment).getOrElse(field)
  }

  private def verifyColumnDataType(schema: StructType): Unit = {
    schema.foreach(col => getSparkSQLDataType(toHiveColumn(col)))
  }

  private def toInputFormat(name: String) =
    Utils.classForName(name).asInstanceOf[Class[_ <: org.apache.hadoop.mapred.InputFormat[_, _]]]

  private def toOutputFormat(name: String) =
    Utils.classForName(name)
      .asInstanceOf[Class[_ <: org.apache.hadoop.hive.ql.io.HiveOutputFormat[_, _]]]

  /**
   * Converts the native table metadata representation format CatalogTable to Hive's Table.
   */
  def toHiveTable(table: CatalogTable, userName: Option[String] = None): HiveTable = {
    val hiveTable = new HiveTable(table.database, table.identifier.table)
    // For EXTERNAL_TABLE, we also need to set EXTERNAL field in the table properties.
    // Otherwise, Hive metastore will change the table to a MANAGED_TABLE.
    // (metastore/src/java/org/apache/hadoop/hive/metastore/ObjectStore.java#L1095-L1105)
    hiveTable.setTableType(table.tableType match {
      case CatalogTableType.EXTERNAL =>
        hiveTable.setProperty("EXTERNAL", "TRUE")
        HiveTableType.EXTERNAL_TABLE
      case CatalogTableType.MANAGED =>
        HiveTableType.MANAGED_TABLE
      case CatalogTableType.VIEW => HiveTableType.VIRTUAL_VIEW
      case t =>
        throw new IllegalArgumentException(
          s"Unknown table type is found at toHiveTable: $t")
    })
    // Note: In Hive the schema and partition columns must be disjoint sets
    val (partCols, schema) = table.schema.map(toHiveColumn).partition { c =>
      table.partitionColumnNames.contains(c.getName)
    }
    hiveTable.setFields(schema.asJava)
    hiveTable.setPartCols(partCols.asJava)
    userName.foreach(hiveTable.setOwner)
    hiveTable.setCreateTime((table.createTime / 1000).toInt)
    hiveTable.setLastAccessTime((table.lastAccessTime / 1000).toInt)
    table.storage.locationUri.map(CatalogUtils.URIToString).foreach { loc =>
      hiveTable.getTTable.getSd.setLocation(loc)}
    table.storage.inputFormat.map(toInputFormat).foreach(hiveTable.setInputFormatClass)
    table.storage.outputFormat.map(toOutputFormat).foreach(hiveTable.setOutputFormatClass)
    hiveTable.setSerializationLib(
      table.storage.serde.getOrElse("org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"))
    table.storage.properties.foreach { case (k, v) => hiveTable.setSerdeParam(k, v) }
    table.properties.foreach { case (k, v) => hiveTable.setProperty(k, v) }
    table.comment.foreach { c => hiveTable.setProperty("comment", c) }
    // Hive will expand the view text, so it needs 2 fields: viewOriginalText and viewExpandedText.
    // Since we don't expand the view text, but only add table properties, we map the `viewText` to
    // the both fields in hive table.
    table.viewText.foreach { t =>
      hiveTable.setViewOriginalText(t)
      hiveTable.setViewExpandedText(t)
    }

    table.bucketSpec match {
      case Some(bucketSpec) if DDLUtils.isHiveTable(table) =>
        hiveTable.setNumBuckets(bucketSpec.numBuckets)
        hiveTable.setBucketCols(bucketSpec.bucketColumnNames.toList.asJava)

        if (bucketSpec.sortColumnNames.nonEmpty) {
          hiveTable.setSortCols(
            bucketSpec.sortColumnNames
              .map(col => new Order(col, HIVE_COLUMN_ORDER_ASC))
              .toList
              .asJava
          )
        }
      case _ =>
    }

    hiveTable
  }

  /**
   * Converts the native partition metadata representation format CatalogTablePartition to
   * Hive's Partition.
   */
  def toHivePartition(
      p: CatalogTablePartition,
      ht: HiveTable): HivePartition = {
    val tpart = new org.apache.hadoop.hive.metastore.api.Partition
    val partValues = ht.getPartCols.asScala.map { hc =>
      p.spec.get(hc.getName).getOrElse {
        throw new IllegalArgumentException(
          s"Partition spec is missing a value for column '${hc.getName}': ${p.spec}")
      }
    }
    val storageDesc = new StorageDescriptor
    val serdeInfo = new SerDeInfo
    p.storage.locationUri.map(CatalogUtils.URIToString(_)).foreach(storageDesc.setLocation)
    p.storage.inputFormat.foreach(storageDesc.setInputFormat)
    p.storage.outputFormat.foreach(storageDesc.setOutputFormat)
    p.storage.serde.foreach(serdeInfo.setSerializationLib)
    serdeInfo.setParameters(p.storage.properties.asJava)
    storageDesc.setSerdeInfo(serdeInfo)
    tpart.setDbName(ht.getDbName)
    tpart.setTableName(ht.getTableName)
    tpart.setValues(partValues.asJava)
    tpart.setSd(storageDesc)
    tpart.setCreateTime((p.createTime / 1000).toInt)
    tpart.setLastAccessTime((p.lastAccessTime / 1000).toInt)
    tpart.setParameters(mutable.Map(p.parameters.toSeq: _*).asJava)
    new HivePartition(ht, tpart)
  }

  /**
   * Build the native partition metadata from Hive's Partition.
   */
  def fromHivePartition(hp: HivePartition): CatalogTablePartition = {
    val apiPartition = hp.getTPartition
    val properties: Map[String, String] = if (hp.getParameters != null) {
      hp.getParameters.asScala.toMap
    } else {
      Map.empty
    }
    CatalogTablePartition(
      spec = Option(hp.getSpec).map(_.asScala.toMap).getOrElse(Map.empty),
      storage = CatalogStorageFormat(
        locationUri = Option(CatalogUtils.stringToURI(apiPartition.getSd.getLocation)),
        inputFormat = Option(apiPartition.getSd.getInputFormat),
        outputFormat = Option(apiPartition.getSd.getOutputFormat),
        serde = Option(apiPartition.getSd.getSerdeInfo.getSerializationLib),
        compressed = apiPartition.getSd.isCompressed,
        properties = Option(apiPartition.getSd.getSerdeInfo.getParameters)
          .map(_.asScala.toMap).orNull),
      createTime = apiPartition.getCreateTime.toLong * 1000,
      lastAccessTime = apiPartition.getLastAccessTime.toLong * 1000,
      parameters = properties,
      stats = readHiveStats(properties))
  }

  /**
   * Reads statistics from Hive.
   * Note that this statistics could be overridden by Spark's statistics if that's available.
   */
  private def readHiveStats(properties: Map[String, String]): Option[CatalogStatistics] = {
    val totalSize = properties.get(StatsSetupConst.TOTAL_SIZE).map(BigInt(_))
    val rawDataSize = properties.get(StatsSetupConst.RAW_DATA_SIZE).map(BigInt(_))
    val rowCount = properties.get(StatsSetupConst.ROW_COUNT).map(BigInt(_))
    // NOTE: getting `totalSize` directly from params is kind of hacky, but this should be
    // relatively cheap if parameters for the table are populated into the metastore.
    // Currently, only totalSize, rawDataSize, and rowCount are used to build the field `stats`
    // TODO: stats should include all the other two fields (`numFiles` and `numPartitions`).
    // (see StatsSetupConst in Hive)

    // When table is external, `totalSize` is always zero, which will influence join strategy.
    // So when `totalSize` is zero, use `rawDataSize` instead. When `rawDataSize` is also zero,
    // return None.
    // In Hive, when statistics gathering is disabled, `rawDataSize` and `numRows` is always
    // zero after INSERT command. So they are used here only if they are larger than zero.
    if (totalSize.isDefined && totalSize.get > 0L) {
      Some(CatalogStatistics(sizeInBytes = totalSize.get, rowCount = rowCount.filter(_ > 0)))
    } else if (rawDataSize.isDefined && rawDataSize.get > 0) {
      Some(CatalogStatistics(sizeInBytes = rawDataSize.get, rowCount = rowCount.filter(_ > 0)))
    } else {
      // TODO: still fill the rowCount even if sizeInBytes is empty. Might break anything?
      None
    }
  }

  // Below is the key of table properties for storing Hive-generated statistics
  private val HiveStatisticsProperties = Set(
    StatsSetupConst.COLUMN_STATS_ACCURATE,
    StatsSetupConst.NUM_FILES,
    StatsSetupConst.NUM_PARTITIONS,
    StatsSetupConst.ROW_COUNT,
    StatsSetupConst.RAW_DATA_SIZE,
    StatsSetupConst.TOTAL_SIZE
  )
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

package org.apache.spark.sql.hive

import org.apache.spark.SparkContext
import org.apache.spark.api.java.JavaSparkContext
import org.apache.spark.internal.Logging
import org.apache.spark.sql.{SparkSession, SQLContext}


/**
 * An instance of the Spark SQL execution engine that integrates with data stored in Hive.
 * Configuration for Hive is read from hive-site.xml on the classpath.
 */
@deprecated("Use SparkSession.builder.enableHiveSupport instead", "2.0.0")
class HiveContext private[hive](_sparkSession: SparkSession)
  extends SQLContext(_sparkSession) with Logging {

  self =>

  def this(sc: SparkContext) = {
    this(SparkSession.builder().sparkContext(HiveUtils.withHiveExternalCatalog(sc)).getOrCreate())
  }

  def this(sc: JavaSparkContext) = this(sc.sc)

  /**
   * Returns a new HiveContext as new session, which will have separated SQLConf, UDF/UDAF,
   * temporary tables and SessionState, but sharing the same CacheManager, IsolatedClientLoader
   * and Hive client (both of execution and metadata) with existing HiveContext.
   */
  override def newSession(): HiveContext = {
    new HiveContext(sparkSession.newSession())
  }

  /**
   * Invalidate and refresh all the cached the metadata of the given table. For performance reasons,
   * Spark SQL or the external data source library it uses might cache certain metadata about a
   * table, such as the location of blocks. When those change outside of Spark SQL, users should
   * call this function to invalidate the cache.
   *
   * @since 1.3.0
   */
  def refreshTable(tableName: String): Unit = {
    sparkSession.catalog.refreshTable(tableName)
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

package org.apache.spark.sql.hive

import java.io.IOException
import java.lang.reflect.InvocationTargetException
import java.util
import java.util.Locale

import scala.collection.mutable
import scala.util.control.NonFatal

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.{FileSystem, Path}
import org.apache.hadoop.hive.ql.metadata.HiveException
import org.apache.thrift.TException

import org.apache.spark.{SparkConf, SparkException}
import org.apache.spark.internal.Logging
import org.apache.spark.sql.AnalysisException
import org.apache.spark.sql.catalyst.TableIdentifier
import org.apache.spark.sql.catalyst.analysis.TableAlreadyExistsException
import org.apache.spark.sql.catalyst.catalog._
import org.apache.spark.sql.catalyst.catalog.ExternalCatalogUtils._
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.plans.logical.ColumnStat
import org.apache.spark.sql.catalyst.util.CaseInsensitiveMap
import org.apache.spark.sql.execution.command.DDLUtils
import org.apache.spark.sql.execution.datasources.{PartitioningUtils, SourceOptions}
import org.apache.spark.sql.hive.client.HiveClient
import org.apache.spark.sql.internal.HiveSerDe
import org.apache.spark.sql.internal.StaticSQLConf._
import org.apache.spark.sql.types.{DataType, StructType}


/**
 * A persistent implementation of the system catalog using Hive.
 * All public methods must be synchronized for thread-safety.
 */
private[spark] class HiveExternalCatalog(conf: SparkConf, hadoopConf: Configuration)
  extends ExternalCatalog with Logging {

  import CatalogTypes.TablePartitionSpec
  import HiveExternalCatalog._
  import CatalogTableType._

  /**
   * A Hive client used to interact with the metastore.
   */
  lazy val client: HiveClient = {
    HiveUtils.newClientForMetadata(conf, hadoopConf)
  }

  // Exceptions thrown by the hive client that we would like to wrap
  private val clientExceptions = Set(
    classOf[HiveException].getCanonicalName,
    classOf[TException].getCanonicalName,
    classOf[InvocationTargetException].getCanonicalName)

  /**
   * Whether this is an exception thrown by the hive client that should be wrapped.
   *
   * Due to classloader isolation issues, pattern matching won't work here so we need
   * to compare the canonical names of the exceptions, which we assume to be stable.
   */
  private def isClientException(e: Throwable): Boolean = {
    var temp: Class[_] = e.getClass
    var found = false
    while (temp != null && !found) {
      found = clientExceptions.contains(temp.getCanonicalName)
      temp = temp.getSuperclass
    }
    found
  }

  /**
   * Run some code involving `client` in a [[synchronized]] block and wrap certain
   * exceptions thrown in the process in [[AnalysisException]].
   */
  private def withClient[T](body: => T): T = synchronized {
    try {
      body
    } catch {
      case NonFatal(exception) if isClientException(exception) =>
        val e = exception match {
          // Since we are using shim, the exceptions thrown by the underlying method of
          // Method.invoke() are wrapped by InvocationTargetException
          case i: InvocationTargetException => i.getCause
          case o => o
        }
        throw new AnalysisException(
          e.getClass.getCanonicalName + ": " + e.getMessage, cause = Some(e))
    }
  }

  /**
   * Get the raw table metadata from hive metastore directly. The raw table metadata may contain
   * special data source properties that should not be exposed outside of `HiveExternalCatalog`. We
   * should interpret these special data source properties and restore the original table metadata
   * before returning it.
   */
  private[hive] def getRawTable(db: String, table: String): CatalogTable = {
    client.getTable(db, table)
  }

  /**
   * If the given table properties contains datasource properties, throw an exception. We will do
   * this check when create or alter a table, i.e. when we try to write table metadata to Hive
   * metastore.
   */
  private def verifyTableProperties(table: CatalogTable): Unit = {
    val invalidKeys = table.properties.keys.filter(_.startsWith(SPARK_SQL_PREFIX))
    if (invalidKeys.nonEmpty) {
      throw new AnalysisException(s"Cannot persistent ${table.qualifiedName} into hive metastore " +
        s"as table property keys may not start with '$SPARK_SQL_PREFIX': " +
        invalidKeys.mkString("[", ", ", "]"))
    }
    // External users are not allowed to set/switch the table type. In Hive metastore, the table
    // type can be switched by changing the value of a case-sensitive table property `EXTERNAL`.
    if (table.properties.contains("EXTERNAL")) {
      throw new AnalysisException("Cannot set or change the preserved property key: 'EXTERNAL'")
    }
  }

  /**
   * Checks the validity of data column names. Hive metastore disallows the table to use some
   * special characters (',', ':', and ';') in data column names, including nested column names.
   * Partition columns do not have such a restriction. Views do not have such a restriction.
   */
  private def verifyDataSchema(
      tableName: TableIdentifier, tableType: CatalogTableType, dataSchema: StructType): Unit = {
    if (tableType != VIEW) {
      val invalidChars = Seq(",", ":", ";")
      def verifyNestedColumnNames(schema: StructType): Unit = schema.foreach { f =>
        f.dataType match {
          case st: StructType => verifyNestedColumnNames(st)
          case _ if invalidChars.exists(f.name.contains) =>
            val invalidCharsString = invalidChars.map(c => s"'$c'").mkString(", ")
            val errMsg = "Cannot create a table having a nested column whose name contains " +
              s"invalid characters ($invalidCharsString) in Hive metastore. Table: $tableName; " +
              s"Column: ${f.name}"
            throw new AnalysisException(errMsg)
          case _ =>
        }
      }

      dataSchema.foreach { f =>
        f.dataType match {
          // Checks top-level column names
          case _ if f.name.contains(",") =>
            throw new AnalysisException("Cannot create a table having a column whose name " +
              s"contains commas in Hive metastore. Table: $tableName; Column: ${f.name}")
          // Checks nested column names
          case st: StructType =>
            verifyNestedColumnNames(st)
          case _ =>
        }
      }
    }
  }

  // --------------------------------------------------------------------------
  // Databases
  // --------------------------------------------------------------------------

  override def createDatabase(
      dbDefinition: CatalogDatabase,
      ignoreIfExists: Boolean): Unit = withClient {
    client.createDatabase(dbDefinition, ignoreIfExists)
  }

  override def dropDatabase(
      db: String,
      ignoreIfNotExists: Boolean,
      cascade: Boolean): Unit = withClient {
    client.dropDatabase(db, ignoreIfNotExists, cascade)
  }

  /**
   * Alter a database whose name matches the one specified in `dbDefinition`,
   * assuming the database exists.
   *
   * Note: As of now, this only supports altering database properties!
   */
  override def alterDatabase(dbDefinition: CatalogDatabase): Unit = withClient {
    val existingDb = getDatabase(dbDefinition.name)
    if (existingDb.properties == dbDefinition.properties) {
      logWarning(s"Request to alter database ${dbDefinition.name} is a no-op because " +
        s"the provided database properties are the same as the old ones. Hive does not " +
        s"currently support altering other database fields.")
    }
    client.alterDatabase(dbDefinition)
  }

  override def getDatabase(db: String): CatalogDatabase = withClient {
    client.getDatabase(db)
  }

  override def databaseExists(db: String): Boolean = withClient {
    client.databaseExists(db)
  }

  override def listDatabases(): Seq[String] = withClient {
    client.listDatabases("*")
  }

  override def listDatabases(pattern: String): Seq[String] = withClient {
    client.listDatabases(pattern)
  }

  override def setCurrentDatabase(db: String): Unit = withClient {
    client.setCurrentDatabase(db)
  }

  // --------------------------------------------------------------------------
  // Tables
  // --------------------------------------------------------------------------

  override def createTable(
      tableDefinition: CatalogTable,
      ignoreIfExists: Boolean): Unit = withClient {
    assert(tableDefinition.identifier.database.isDefined)
    val db = tableDefinition.identifier.database.get
    val table = tableDefinition.identifier.table
    requireDbExists(db)
    verifyTableProperties(tableDefinition)
    verifyDataSchema(
      tableDefinition.identifier, tableDefinition.tableType, tableDefinition.dataSchema)

    if (tableExists(db, table) && !ignoreIfExists) {
      throw new TableAlreadyExistsException(db = db, table = table)
    }

    // Ideally we should not create a managed table with location, but Hive serde table can
    // specify location for managed table. And in [[CreateDataSourceTableAsSelectCommand]] we have
    // to create the table directory and write out data before we create this table, to avoid
    // exposing a partial written table.
    val needDefaultTableLocation = tableDefinition.tableType == MANAGED &&
      tableDefinition.storage.locationUri.isEmpty

    val tableLocation = if (needDefaultTableLocation) {
      Some(CatalogUtils.stringToURI(defaultTablePath(tableDefinition.identifier)))
    } else {
      tableDefinition.storage.locationUri
    }

    if (DDLUtils.isDatasourceTable(tableDefinition)) {
      createDataSourceTable(
        tableDefinition.withNewStorage(locationUri = tableLocation),
        ignoreIfExists)
    } else {
      val tableWithDataSourceProps = tableDefinition.copy(
        // We can't leave `locationUri` empty and count on Hive metastore to set a default table
        // location, because Hive metastore uses hive.metastore.warehouse.dir to generate default
        // table location for tables in default database, while we expect to use the location of
        // default database.
        storage = tableDefinition.storage.copy(locationUri = tableLocation),
        // Here we follow data source tables and put table metadata like table schema, partition
        // columns etc. in table properties, so that we can work around the Hive metastore issue
        // about not case preserving and make Hive serde table and view support mixed-case column
        // names.
        properties = tableDefinition.properties ++ tableMetaToTableProps(tableDefinition))
      client.createTable(tableWithDataSourceProps, ignoreIfExists)
    }
  }

  private def createDataSourceTable(table: CatalogTable, ignoreIfExists: Boolean): Unit = {
    // data source table always have a provider, it's guaranteed by `DDLUtils.isDatasourceTable`.
    val provider = table.provider.get
    val options = new SourceOptions(table.storage.properties)

    // To work around some hive metastore issues, e.g. not case-preserving, bad decimal type
    // support, no column nullability, etc., we should do some extra works before saving table
    // metadata into Hive metastore:
    //  1. Put table metadata like table schema, partition columns, etc. in table properties.
    //  2. Check if this table is hive compatible.
    //    2.1  If it's not hive compatible, set location URI, schema, partition columns and bucket
    //         spec to empty and save table metadata to Hive.
    //    2.2  If it's hive compatible, set serde information in table metadata and try to save
    //         it to Hive. If it fails, treat it as not hive compatible and go back to 2.1
    val tableProperties = tableMetaToTableProps(table)

    // put table provider and partition provider in table properties.
    tableProperties.put(DATASOURCE_PROVIDER, provider)
    if (table.tracksPartitionsInCatalog) {
      tableProperties.put(TABLE_PARTITION_PROVIDER, TABLE_PARTITION_PROVIDER_CATALOG)
    }

    // Ideally we should also put `locationUri` in table properties like provider, schema, etc.
    // However, in older version of Spark we already store table location in storage properties
    // with key "path". Here we keep this behaviour for backward compatibility.
    val storagePropsWithLocation = table.storage.properties ++
      table.storage.locationUri.map("path" -> CatalogUtils.URIToString(_))

    // converts the table metadata to Spark SQL specific format, i.e. set data schema, names and
    // bucket specification to empty. Note that partition columns are retained, so that we can
    // call partition-related Hive API later.
    def newSparkSQLSpecificMetastoreTable(): CatalogTable = {
      table.copy(
        // Hive only allows directory paths as location URIs while Spark SQL data source tables
        // also allow file paths. For non-hive-compatible format, we should not set location URI
        // to avoid hive metastore to throw exception.
        storage = table.storage.copy(
          locationUri = None,
          properties = storagePropsWithLocation),
        schema = StructType(EMPTY_DATA_SCHEMA ++ table.partitionSchema),
        bucketSpec = None,
        properties = table.properties ++ tableProperties)
    }

    // converts the table metadata to Hive compatible format, i.e. set the serde information.
    def newHiveCompatibleMetastoreTable(serde: HiveSerDe): CatalogTable = {
      val location = if (table.tableType == EXTERNAL) {
        // When we hit this branch, we are saving an external data source table with hive
        // compatible format, which means the data source is file-based and must have a `path`.
        require(table.storage.locationUri.isDefined,
          "External file-based data source table must have a `path` entry in storage properties.")
        Some(table.location)
      } else {
        None
      }

      table.copy(
        storage = table.storage.copy(
          locationUri = location,
          inputFormat = serde.inputFormat,
          outputFormat = serde.outputFormat,
          serde = serde.serde,
          properties = storagePropsWithLocation
        ),
        properties = table.properties ++ tableProperties)
    }

    val qualifiedTableName = table.identifier.quotedString
    val maybeSerde = HiveSerDe.sourceToSerDe(provider)

    val (hiveCompatibleTable, logMessage) = maybeSerde match {
      case _ if options.skipHiveMetadata =>
        val message =
          s"Persisting data source table $qualifiedTableName into Hive metastore in" +
            "Spark SQL specific format, which is NOT compatible with Hive."
        (None, message)

      // our bucketing is un-compatible with hive(different hash function)
      case _ if table.bucketSpec.nonEmpty =>
        val message =
          s"Persisting bucketed data source table $qualifiedTableName into " +
            "Hive metastore in Spark SQL specific format, which is NOT compatible with Hive. "
        (None, message)

      case Some(serde) =>
        val message =
          s"Persisting file based data source table $qualifiedTableName into " +
            s"Hive metastore in Hive compatible format."
        (Some(newHiveCompatibleMetastoreTable(serde)), message)

      case _ =>
        val message =
          s"Couldn't find corresponding Hive SerDe for data source provider $provider. " +
            s"Persisting data source table $qualifiedTableName into Hive metastore in " +
            s"Spark SQL specific format, which is NOT compatible with Hive."
        (None, message)
    }

    (hiveCompatibleTable, logMessage) match {
      case (Some(table), message) =>
        // We first try to save the metadata of the table in a Hive compatible way.
        // If Hive throws an error, we fall back to save its metadata in the Spark SQL
        // specific way.
        try {
          logInfo(message)
          saveTableIntoHive(table, ignoreIfExists)
        } catch {
          case NonFatal(e) =>
            val warningMessage =
              s"Could not persist ${table.identifier.quotedString} in a Hive " +
                "compatible way. Persisting it into Hive metastore in Spark SQL specific format."
            logWarning(warningMessage, e)
            saveTableIntoHive(newSparkSQLSpecificMetastoreTable(), ignoreIfExists)
        }

      case (None, message) =>
        logWarning(message)
        saveTableIntoHive(newSparkSQLSpecificMetastoreTable(), ignoreIfExists)
    }
  }

  /**
   * Data source tables may be non Hive compatible and we need to store table metadata in table
   * properties to workaround some Hive metastore limitations.
   * This method puts table schema, partition column names, bucket specification into a map, which
   * can be used as table properties later.
   */
  private def tableMetaToTableProps(table: CatalogTable): mutable.Map[String, String] = {
    tableMetaToTableProps(table, table.schema)
  }

  private def tableMetaToTableProps(
      table: CatalogTable,
      schema: StructType): mutable.Map[String, String] = {
    val partitionColumns = table.partitionColumnNames
    val bucketSpec = table.bucketSpec

    val properties = new mutable.HashMap[String, String]

    properties.put(CREATED_SPARK_VERSION, table.createVersion)

    // Serialized JSON schema string may be too long to be stored into a single metastore table
    // property. In this case, we split the JSON string and store each part as a separate table
    // property.
    val threshold = conf.get(SCHEMA_STRING_LENGTH_THRESHOLD)
    val schemaJsonString = schema.json
    // Split the JSON string.
    val parts = schemaJsonString.grouped(threshold).toSeq
    properties.put(DATASOURCE_SCHEMA_NUMPARTS, parts.size.toString)
    parts.zipWithIndex.foreach { case (part, index) =>
      properties.put(s"$DATASOURCE_SCHEMA_PART_PREFIX$index", part)
    }

    if (partitionColumns.nonEmpty) {
      properties.put(DATASOURCE_SCHEMA_NUMPARTCOLS, partitionColumns.length.toString)
      partitionColumns.zipWithIndex.foreach { case (partCol, index) =>
        properties.put(s"$DATASOURCE_SCHEMA_PARTCOL_PREFIX$index", partCol)
      }
    }

    if (bucketSpec.isDefined) {
      val BucketSpec(numBuckets, bucketColumnNames, sortColumnNames) = bucketSpec.get

      properties.put(DATASOURCE_SCHEMA_NUMBUCKETS, numBuckets.toString)
      properties.put(DATASOURCE_SCHEMA_NUMBUCKETCOLS, bucketColumnNames.length.toString)
      bucketColumnNames.zipWithIndex.foreach { case (bucketCol, index) =>
        properties.put(s"$DATASOURCE_SCHEMA_BUCKETCOL_PREFIX$index", bucketCol)
      }

      if (sortColumnNames.nonEmpty) {
        properties.put(DATASOURCE_SCHEMA_NUMSORTCOLS, sortColumnNames.length.toString)
        sortColumnNames.zipWithIndex.foreach { case (sortCol, index) =>
          properties.put(s"$DATASOURCE_SCHEMA_SORTCOL_PREFIX$index", sortCol)
        }
      }
    }

    properties
  }

  private def defaultTablePath(tableIdent: TableIdentifier): String = {
    val dbLocation = getDatabase(tableIdent.database.get).locationUri
    new Path(new Path(dbLocation), tableIdent.table).toString
  }

  private def saveTableIntoHive(tableDefinition: CatalogTable, ignoreIfExists: Boolean): Unit = {
    assert(DDLUtils.isDatasourceTable(tableDefinition),
      "saveTableIntoHive only takes data source table.")
    // If this is an external data source table...
    if (tableDefinition.tableType == EXTERNAL &&
      // ... that is not persisted as Hive compatible format (external tables in Hive compatible
      // format always set `locationUri` to the actual data location and should NOT be hacked as
      // following.)
      tableDefinition.storage.locationUri.isEmpty) {
      // !! HACK ALERT !!
      //
      // Due to a restriction of Hive metastore, here we have to set `locationUri` to a temporary
      // directory that doesn't exist yet but can definitely be successfully created, and then
      // delete it right after creating the external data source table. This location will be
      // persisted to Hive metastore as standard Hive table location URI, but Spark SQL doesn't
      // really use it. Also, since we only do this workaround for external tables, deleting the
      // directory after the fact doesn't do any harm.
      //
      // Please refer to https://issues.apache.org/jira/browse/SPARK-15269 for more details.
      val tempPath = {
        val dbLocation = new Path(getDatabase(tableDefinition.database).locationUri)
        new Path(dbLocation, tableDefinition.identifier.table + "-__PLACEHOLDER__")
      }

      try {
        client.createTable(
          tableDefinition.withNewStorage(locationUri = Some(tempPath.toUri)),
          ignoreIfExists)
      } finally {
        FileSystem.get(tempPath.toUri, hadoopConf).delete(tempPath, true)
      }
    } else {
      client.createTable(tableDefinition, ignoreIfExists)
    }
  }

  override def dropTable(
      db: String,
      table: String,
      ignoreIfNotExists: Boolean,
      purge: Boolean): Unit = withClient {
    requireDbExists(db)
    client.dropTable(db, table, ignoreIfNotExists, purge)
  }

  override def renameTable(
      db: String,
      oldName: String,
      newName: String): Unit = withClient {
    val rawTable = getRawTable(db, oldName)

    // Note that Hive serde tables don't use path option in storage properties to store the value
    // of table location, but use `locationUri` field to store it directly. And `locationUri` field
    // will be updated automatically in Hive metastore by the `alterTable` call at the end of this
    // method. Here we only update the path option if the path option already exists in storage
    // properties, to avoid adding a unnecessary path option for Hive serde tables.
    val hasPathOption = CaseInsensitiveMap(rawTable.storage.properties).contains("path")
    val storageWithNewPath = if (rawTable.tableType == MANAGED && hasPathOption) {
      // If it's a managed table with path option and we are renaming it, then the path option
      // becomes inaccurate and we need to update it according to the new table name.
      val newTablePath = defaultTablePath(TableIdentifier(newName, Some(db)))
      updateLocationInStorageProps(rawTable, Some(newTablePath))
    } else {
      rawTable.storage
    }

    val newTable = rawTable.copy(
      identifier = TableIdentifier(newName, Some(db)),
      storage = storageWithNewPath)

    client.alterTable(db, oldName, newTable)
  }

  private def getLocationFromStorageProps(table: CatalogTable): Option[String] = {
    CaseInsensitiveMap(table.storage.properties).get("path")
  }

  private def updateLocationInStorageProps(
      table: CatalogTable,
      newPath: Option[String]): CatalogStorageFormat = {
    // We can't use `filterKeys` here, as the map returned by `filterKeys` is not serializable,
    // while `CatalogTable` should be serializable.
    val propsWithoutPath = table.storage.properties.filter {
      case (k, v) => k.toLowerCase(Locale.ROOT) != "path"
    }
    table.storage.copy(properties = propsWithoutPath ++ newPath.map("path" -> _))
  }

  /**
   * Alter a table whose name that matches the one specified in `tableDefinition`,
   * assuming the table exists. This method does not change the properties for data source and
   * statistics.
   *
   * Note: As of now, this doesn't support altering table schema, partition column names and bucket
   * specification. We will ignore them even if users do specify different values for these fields.
   */
  override def alterTable(tableDefinition: CatalogTable): Unit = withClient {
    assert(tableDefinition.identifier.database.isDefined)
    val db = tableDefinition.identifier.database.get
    requireTableExists(db, tableDefinition.identifier.table)
    verifyTableProperties(tableDefinition)

    if (tableDefinition.tableType == VIEW) {
      client.alterTable(tableDefinition)
    } else {
      val oldTableDef = getRawTable(db, tableDefinition.identifier.table)

      val newStorage = if (DDLUtils.isHiveTable(tableDefinition)) {
        tableDefinition.storage
      } else {
        // We can't alter the table storage of data source table directly for 2 reasons:
        //   1. internally we use path option in storage properties to store the value of table
        //      location, but the given `tableDefinition` is from outside and doesn't have the path
        //      option, we need to add it manually.
        //   2. this data source table may be created on a file, not a directory, then we can't set
        //      the `locationUri` field and save it to Hive metastore, because Hive only allows
        //      directory as table location.
        //
        // For example, an external data source table is created with a single file '/path/to/file'.
        // Internally, we will add a path option with value '/path/to/file' to storage properties,
        // and set the `locationUri` to a special value due to SPARK-15269(please see
        // `saveTableIntoHive` for more details). When users try to get the table metadata back, we
        // will restore the `locationUri` field from the path option and remove the path option from
        // storage properties. When users try to alter the table storage, the given
        // `tableDefinition` will have `locationUri` field with value `/path/to/file` and the path
        // option is not set.
        //
        // Here we need 2 extra steps:
        //   1. add path option to storage properties, to match the internal format, i.e. using path
        //      option to store the value of table location.
        //   2. set the `locationUri` field back to the old one from the existing table metadata,
        //      if users don't want to alter the table location. This step is necessary as the
        //      `locationUri` is not always same with the path option, e.g. in the above example
        //      `locationUri` is a special value and we should respect it. Note that, if users
        //       want to alter the table location to a file path, we will fail. This should be fixed
        //       in the future.

        val newLocation = tableDefinition.storage.locationUri.map(CatalogUtils.URIToString(_))
        val storageWithPathOption = tableDefinition.storage.copy(
          properties = tableDefinition.storage.properties ++ newLocation.map("path" -> _))

        val oldLocation = getLocationFromStorageProps(oldTableDef)
        if (oldLocation == newLocation) {
          storageWithPathOption.copy(locationUri = oldTableDef.storage.locationUri)
        } else {
          storageWithPathOption
        }
      }

      val partitionProviderProp = if (tableDefinition.tracksPartitionsInCatalog) {
        TABLE_PARTITION_PROVIDER -> TABLE_PARTITION_PROVIDER_CATALOG
      } else {
        TABLE_PARTITION_PROVIDER -> TABLE_PARTITION_PROVIDER_FILESYSTEM
      }

      // Add old data source properties to table properties, to retain the data source table format.
      // Add old stats properties to table properties, to retain spark's stats.
      // Set the `schema`, `partitionColumnNames` and `bucketSpec` from the old table definition,
      // to retain the spark specific format if it is.
      val propsFromOldTable = oldTableDef.properties.filter { case (k, v) =>
        k.startsWith(DATASOURCE_PREFIX) || k.startsWith(STATISTICS_PREFIX) ||
          k.startsWith(CREATED_SPARK_VERSION)
      }
      val newTableProps = propsFromOldTable ++ tableDefinition.properties + partitionProviderProp
      val newDef = tableDefinition.copy(
        storage = newStorage,
        schema = oldTableDef.schema,
        partitionColumnNames = oldTableDef.partitionColumnNames,
        bucketSpec = oldTableDef.bucketSpec,
        properties = newTableProps)

      client.alterTable(newDef)
    }
  }

  /**
   * Alter the data schema of a table identified by the provided database and table name. The new
   * data schema should not have conflict column names with the existing partition columns, and
   * should still contain all the existing data columns.
   */
  override def alterTableDataSchema(
      db: String,
      table: String,
      newDataSchema: StructType): Unit = withClient {
    requireTableExists(db, table)
    val oldTable = getTable(db, table)
    verifyDataSchema(oldTable.identifier, oldTable.tableType, newDataSchema)
    val schemaProps =
      tableMetaToTableProps(oldTable, StructType(newDataSchema ++ oldTable.partitionSchema)).toMap

    if (isDatasourceTable(oldTable)) {
      // For data source tables, first try to write it with the schema set; if that does not work,
      // try again with updated properties and the partition schema. This is a simplified version of
      // what createDataSourceTable() does, and may leave the table in a state unreadable by Hive
      // (for example, the schema does not match the data source schema, or does not match the
      // storage descriptor).
      try {
        client.alterTableDataSchema(db, table, newDataSchema, schemaProps)
      } catch {
        case NonFatal(e) =>
          val warningMessage =
            s"Could not alter schema of table ${oldTable.identifier.quotedString} in a Hive " +
              "compatible way. Updating Hive metastore in Spark SQL specific format."
          logWarning(warningMessage, e)
          client.alterTableDataSchema(db, table, EMPTY_DATA_SCHEMA, schemaProps)
      }
    } else {
      client.alterTableDataSchema(db, table, newDataSchema, schemaProps)
    }
  }

  /** Alter the statistics of a table. If `stats` is None, then remove all existing statistics. */
  override def alterTableStats(
      db: String,
      table: String,
      stats: Option[CatalogStatistics]): Unit = withClient {
    requireTableExists(db, table)
    val rawTable = getRawTable(db, table)

    // convert table statistics to properties so that we can persist them through hive client
    val statsProperties =
      if (stats.isDefined) {
        statsToProperties(stats.get)
      } else {
        new mutable.HashMap[String, String]()
      }

    val oldTableNonStatsProps = rawTable.properties.filterNot(_._1.startsWith(STATISTICS_PREFIX))
    val updatedTable = rawTable.copy(properties = oldTableNonStatsProps ++ statsProperties)
    client.alterTable(updatedTable)
  }

  override def getTable(db: String, table: String): CatalogTable = withClient {
    restoreTableMetadata(getRawTable(db, table))
  }

  /**
   * Restores table metadata from the table properties. This method is kind of a opposite version
   * of [[createTable]].
   *
   * It reads table schema, provider, partition column names and bucket specification from table
   * properties, and filter out these special entries from table properties.
   */
  private def restoreTableMetadata(inputTable: CatalogTable): CatalogTable = {
    if (conf.get(DEBUG_MODE)) {
      return inputTable
    }

    var table = inputTable

    table.properties.get(DATASOURCE_PROVIDER) match {
      case None if table.tableType == VIEW =>
        // If this is a view created by Spark 2.2 or higher versions, we should restore its schema
        // from table properties.
        if (table.properties.contains(DATASOURCE_SCHEMA_NUMPARTS)) {
          table = table.copy(schema = getSchemaFromTableProperties(table))
        }

      // No provider in table properties, which means this is a Hive serde table.
      case None =>
        table = restoreHiveSerdeTable(table)

      // This is a regular data source table.
      case Some(provider) =>
        table = restoreDataSourceTable(table, provider)
    }

    // Restore version info
    val version: String = table.properties.getOrElse(CREATED_SPARK_VERSION, "2.2 or prior")

    // Restore Spark's statistics from information in Metastore.
    val restoredStats =
      statsFromProperties(table.properties, table.identifier.table, table.schema)
    if (restoredStats.isDefined) {
      table = table.copy(stats = restoredStats)
    }

    // Get the original table properties as defined by the user.
    table.copy(
      createVersion = version,
      properties = table.properties.filterNot { case (key, _) => key.startsWith(SPARK_SQL_PREFIX) })
  }

  // Reorder table schema to put partition columns at the end. Before Spark 2.2, the partition
  // columns are not put at the end of schema. We need to reorder it when reading the schema
  // from the table properties.
  private def reorderSchema(schema: StructType, partColumnNames: Seq[String]): StructType = {
    val partitionFields = partColumnNames.map { partCol =>
      schema.find(_.name == partCol).getOrElse {
        throw new AnalysisException("The metadata is corrupted. Unable to find the " +
          s"partition column names from the schema. schema: ${schema.catalogString}. " +
          s"Partition columns: ${partColumnNames.mkString("[", ", ", "]")}")
      }
    }
    StructType(schema.filterNot(partitionFields.contains) ++ partitionFields)
  }

  private def restoreHiveSerdeTable(table: CatalogTable): CatalogTable = {
    val options = new SourceOptions(table.storage.properties)
    val hiveTable = table.copy(
      provider = Some(DDLUtils.HIVE_PROVIDER),
      tracksPartitionsInCatalog = true)

    // If this is a Hive serde table created by Spark 2.1 or higher versions, we should restore its
    // schema from table properties.
    if (table.properties.contains(DATASOURCE_SCHEMA_NUMPARTS)) {
      val schemaFromTableProps = getSchemaFromTableProperties(table)
      val partColumnNames = getPartitionColumnsFromTableProperties(table)
      val reorderedSchema = reorderSchema(schema = schemaFromTableProps, partColumnNames)

      if (DataType.equalsIgnoreCaseAndNullability(reorderedSchema, table.schema) ||
          options.respectSparkSchema) {
        hiveTable.copy(
          schema = reorderedSchema,
          partitionColumnNames = partColumnNames,
          bucketSpec = getBucketSpecFromTableProperties(table))
      } else {
        // Hive metastore may change the table schema, e.g. schema inference. If the table
        // schema we read back is different(ignore case and nullability) from the one in table
        // properties which was written when creating table, we should respect the table schema
        // from hive.
        logWarning(s"The table schema given by Hive metastore(${table.schema.catalogString}) is " +
          "different from the schema when this table was created by Spark SQL" +
          s"(${schemaFromTableProps.catalogString}). We have to fall back to the table schema " +
          "from Hive metastore which is not case preserving.")
        hiveTable.copy(schemaPreservesCase = false)
      }
    } else {
      hiveTable.copy(schemaPreservesCase = false)
    }
  }

  private def restoreDataSourceTable(table: CatalogTable, provider: String): CatalogTable = {
    // Internally we store the table location in storage properties with key "path" for data
    // source tables. Here we set the table location to `locationUri` field and filter out the
    // path option in storage properties, to avoid exposing this concept externally.
    val storageWithLocation = {
      val tableLocation = getLocationFromStorageProps(table)
      // We pass None as `newPath` here, to remove the path option in storage properties.
      updateLocationInStorageProps(table, newPath = None).copy(
        locationUri = tableLocation.map(CatalogUtils.stringToURI(_)))
    }
    val partitionProvider = table.properties.get(TABLE_PARTITION_PROVIDER)

    val schemaFromTableProps = getSchemaFromTableProperties(table)
    val partColumnNames = getPartitionColumnsFromTableProperties(table)
    val reorderedSchema = reorderSchema(schema = schemaFromTableProps, partColumnNames)

    table.copy(
      provider = Some(provider),
      storage = storageWithLocation,
      schema = reorderedSchema,
      partitionColumnNames = partColumnNames,
      bucketSpec = getBucketSpecFromTableProperties(table),
      tracksPartitionsInCatalog = partitionProvider == Some(TABLE_PARTITION_PROVIDER_CATALOG))
  }

  override def tableExists(db: String, table: String): Boolean = withClient {
    client.tableExists(db, table)
  }

  override def listTables(db: String): Seq[String] = withClient {
    requireDbExists(db)
    client.listTables(db)
  }

  override def listTables(db: String, pattern: String): Seq[String] = withClient {
    requireDbExists(db)
    client.listTables(db, pattern)
  }

  override def loadTable(
      db: String,
      table: String,
      loadPath: String,
      isOverwrite: Boolean,
      isSrcLocal: Boolean): Unit = withClient {
    requireTableExists(db, table)
    client.loadTable(
      loadPath,
      s"$db.$table",
      isOverwrite,
      isSrcLocal)
  }

  override def loadPartition(
      db: String,
      table: String,
      loadPath: String,
      partition: TablePartitionSpec,
      isOverwrite: Boolean,
      inheritTableSpecs: Boolean,
      isSrcLocal: Boolean): Unit = withClient {
    requireTableExists(db, table)

    val orderedPartitionSpec = new util.LinkedHashMap[String, String]()
    getTable(db, table).partitionColumnNames.foreach { colName =>
      // Hive metastore is not case preserving and keeps partition columns with lower cased names,
      // and Hive will validate the column names in partition spec to make sure they are partition
      // columns. Here we Lowercase the column names before passing the partition spec to Hive
      // client, to satisfy Hive.
      orderedPartitionSpec.put(colName.toLowerCase, partition(colName))
    }

    client.loadPartition(
      loadPath,
      db,
      table,
      orderedPartitionSpec,
      isOverwrite,
      inheritTableSpecs,
      isSrcLocal)
  }

  override def loadDynamicPartitions(
      db: String,
      table: String,
      loadPath: String,
      partition: TablePartitionSpec,
      replace: Boolean,
      numDP: Int): Unit = withClient {
    requireTableExists(db, table)

    val orderedPartitionSpec = new util.LinkedHashMap[String, String]()
    getTable(db, table).partitionColumnNames.foreach { colName =>
      // Hive metastore is not case preserving and keeps partition columns with lower cased names,
      // and Hive will validate the column names in partition spec to make sure they are partition
      // columns. Here we Lowercase the column names before passing the partition spec to Hive
      // client, to satisfy Hive.
      orderedPartitionSpec.put(colName.toLowerCase, partition(colName))
    }

    client.loadDynamicPartitions(
      loadPath,
      db,
      table,
      orderedPartitionSpec,
      replace,
      numDP)
  }

  // --------------------------------------------------------------------------
  // Partitions
  // --------------------------------------------------------------------------

  // Hive metastore is not case preserving and the partition columns are always lower cased. We need
  // to lower case the column names in partition specification before calling partition related Hive
  // APIs, to match this behaviour.
  private def lowerCasePartitionSpec(spec: TablePartitionSpec): TablePartitionSpec = {
    spec.map { case (k, v) => k.toLowerCase -> v }
  }

  // Build a map from lower-cased partition column names to exact column names for a given table
  private def buildLowerCasePartColNameMap(table: CatalogTable): Map[String, String] = {
    val actualPartColNames = table.partitionColumnNames
    actualPartColNames.map(colName => (colName.toLowerCase, colName)).toMap
  }

  // Hive metastore is not case preserving and the column names of the partition specification we
  // get from the metastore are always lower cased. We should restore them w.r.t. the actual table
  // partition columns.
  private def restorePartitionSpec(
      spec: TablePartitionSpec,
      partColMap: Map[String, String]): TablePartitionSpec = {
    spec.map { case (k, v) => partColMap(k.toLowerCase) -> v }
  }

  private def restorePartitionSpec(
      spec: TablePartitionSpec,
      partCols: Seq[String]): TablePartitionSpec = {
    spec.map { case (k, v) => partCols.find(_.equalsIgnoreCase(k)).get -> v }
  }

  override def createPartitions(
      db: String,
      table: String,
      parts: Seq[CatalogTablePartition],
      ignoreIfExists: Boolean): Unit = withClient {
    requireTableExists(db, table)

    val tableMeta = getTable(db, table)
    val partitionColumnNames = tableMeta.partitionColumnNames
    val tablePath = new Path(tableMeta.location)
    val partsWithLocation = parts.map { p =>
      // Ideally we can leave the partition location empty and let Hive metastore to set it.
      // However, Hive metastore is not case preserving and will generate wrong partition location
      // with lower cased partition column names. Here we set the default partition location
      // manually to avoid this problem.
      val partitionPath = p.storage.locationUri.map(uri => new Path(uri)).getOrElse {
        ExternalCatalogUtils.generatePartitionPath(p.spec, partitionColumnNames, tablePath)
      }
      p.copy(storage = p.storage.copy(locationUri = Some(partitionPath.toUri)))
    }
    val lowerCasedParts = partsWithLocation.map(p => p.copy(spec = lowerCasePartitionSpec(p.spec)))
    client.createPartitions(db, table, lowerCasedParts, ignoreIfExists)
  }

  override def dropPartitions(
      db: String,
      table: String,
      parts: Seq[TablePartitionSpec],
      ignoreIfNotExists: Boolean,
      purge: Boolean,
      retainData: Boolean): Unit = withClient {
    requireTableExists(db, table)
    client.dropPartitions(
      db, table, parts.map(lowerCasePartitionSpec), ignoreIfNotExists, purge, retainData)
  }

  override def renamePartitions(
      db: String,
      table: String,
      specs: Seq[TablePartitionSpec],
      newSpecs: Seq[TablePartitionSpec]): Unit = withClient {
    client.renamePartitions(
      db, table, specs.map(lowerCasePartitionSpec), newSpecs.map(lowerCasePartitionSpec))

    val tableMeta = getTable(db, table)
    val partitionColumnNames = tableMeta.partitionColumnNames
    // Hive metastore is not case preserving and keeps partition columns with lower cased names.
    // When Hive rename partition for managed tables, it will create the partition location with
    // a default path generate by the new spec with lower cased partition column names. This is
    // unexpected and we need to rename them manually and alter the partition location.
    val hasUpperCasePartitionColumn = partitionColumnNames.exists(col => col.toLowerCase != col)
    if (tableMeta.tableType == MANAGED && hasUpperCasePartitionColumn) {
      val tablePath = new Path(tableMeta.location)
      val fs = tablePath.getFileSystem(hadoopConf)
      val newParts = newSpecs.map { spec =>
        val rightPath = renamePartitionDirectory(fs, tablePath, partitionColumnNames, spec)
        val partition = client.getPartition(db, table, lowerCasePartitionSpec(spec))
        partition.copy(storage = partition.storage.copy(locationUri = Some(rightPath.toUri)))
      }
      alterPartitions(db, table, newParts)
    }
  }

  /**
   * Rename the partition directory w.r.t. the actual partition columns.
   *
   * It will recursively rename the partition directory from the first partition column, to be most
   * compatible with different file systems. e.g. in some file systems, renaming `a=1/b=2` to
   * `A=1/B=2` will result to `a=1/B=2`, while in some other file systems, the renaming works, but
   * will leave an empty directory `a=1`.
   */
  private def renamePartitionDirectory(
      fs: FileSystem,
      tablePath: Path,
      partCols: Seq[String],
      newSpec: TablePartitionSpec): Path = {
    import ExternalCatalogUtils.getPartitionPathString

    var currentFullPath = tablePath
    partCols.foreach { col =>
      val partValue = newSpec(col)
      val expectedPartitionString = getPartitionPathString(col, partValue)
      val expectedPartitionPath = new Path(currentFullPath, expectedPartitionString)

      if (fs.exists(expectedPartitionPath)) {
        // It is possible that some parental partition directories already exist or doesn't need to
        // be renamed. e.g. the partition columns are `a` and `B`, then we don't need to rename
        // `/table_path/a=1`. Or we already have a partition directory `A=1/B=2`, and we rename
        // another partition to `A=1/B=3`, then we will have `A=1/B=2` and `a=1/b=3`, and we should
        // just move `a=1/b=3` into `A=1` with new name `B=3`.
      } else {
        val actualPartitionString = getPartitionPathString(col.toLowerCase, partValue)
        val actualPartitionPath = new Path(currentFullPath, actualPartitionString)
        try {
          fs.rename(actualPartitionPath, expectedPartitionPath)
        } catch {
          case e: IOException =>
            throw new SparkException("Unable to rename partition path from " +
              s"$actualPartitionPath to $expectedPartitionPath", e)
        }
      }
      currentFullPath = expectedPartitionPath
    }

    currentFullPath
  }

  private def statsToProperties(stats: CatalogStatistics): Map[String, String] = {

    val statsProperties = new mutable.HashMap[String, String]()
    statsProperties += STATISTICS_TOTAL_SIZE -> stats.sizeInBytes.toString()
    if (stats.rowCount.isDefined) {
      statsProperties += STATISTICS_NUM_ROWS -> stats.rowCount.get.toString()
    }

    stats.colStats.foreach { case (colName, colStat) =>
      colStat.toMap(colName).foreach { case (k, v) =>
        // Fully qualified name used in table properties for a particular column stat.
        // For example, for column "mycol", and "min" stat, this should return
        // "spark.sql.statistics.colStats.mycol.min".
        statsProperties += (STATISTICS_COL_STATS_PREFIX + k -> v)
      }
    }

    statsProperties.toMap
  }

  private def statsFromProperties(
      properties: Map[String, String],
      table: String,
      schema: StructType): Option[CatalogStatistics] = {

    val statsProps = properties.filterKeys(_.startsWith(STATISTICS_PREFIX))
    if (statsProps.isEmpty) {
      None
    } else {
      val colStats = new mutable.HashMap[String, CatalogColumnStat]
      val colStatsProps = properties.filterKeys(_.startsWith(STATISTICS_COL_STATS_PREFIX)).map {
        case (k, v) => k.drop(STATISTICS_COL_STATS_PREFIX.length) -> v
      }

      // Find all the column names by matching the KEY_VERSION properties for them.
      colStatsProps.keys.filter {
        k => k.endsWith(CatalogColumnStat.KEY_VERSION)
      }.map { k =>
        k.dropRight(CatalogColumnStat.KEY_VERSION.length + 1)
      }.foreach { fieldName =>
        // and for each, create a column stat.
        CatalogColumnStat.fromMap(table, fieldName, colStatsProps).foreach { cs =>
          colStats += fieldName -> cs
        }
      }

      Some(CatalogStatistics(
        sizeInBytes = BigInt(statsProps(STATISTICS_TOTAL_SIZE)),
        rowCount = statsProps.get(STATISTICS_NUM_ROWS).map(BigInt(_)),
        colStats = colStats.toMap))
    }
  }

  override def alterPartitions(
      db: String,
      table: String,
      newParts: Seq[CatalogTablePartition]): Unit = withClient {
    val lowerCasedParts = newParts.map(p => p.copy(spec = lowerCasePartitionSpec(p.spec)))

    val rawTable = getRawTable(db, table)

    // convert partition statistics to properties so that we can persist them through hive api
    val withStatsProps = lowerCasedParts.map { p =>
      if (p.stats.isDefined) {
        val statsProperties = statsToProperties(p.stats.get)
        p.copy(parameters = p.parameters ++ statsProperties)
      } else {
        p
      }
    }

    client.alterPartitions(db, table, withStatsProps)
  }

  override def getPartition(
      db: String,
      table: String,
      spec: TablePartitionSpec): CatalogTablePartition = withClient {
    val part = client.getPartition(db, table, lowerCasePartitionSpec(spec))
    restorePartitionMetadata(part, getTable(db, table))
  }

  /**
   * Restores partition metadata from the partition properties.
   *
   * Reads partition-level statistics from partition properties, puts these
   * into [[CatalogTablePartition#stats]] and removes these special entries
   * from the partition properties.
   */
  private def restorePartitionMetadata(
      partition: CatalogTablePartition,
      table: CatalogTable): CatalogTablePartition = {
    val restoredSpec = restorePartitionSpec(partition.spec, table.partitionColumnNames)

    // Restore Spark's statistics from information in Metastore.
    // Note: partition-level statistics were introduced in 2.3.
    val restoredStats =
      statsFromProperties(partition.parameters, table.identifier.table, table.schema)
    if (restoredStats.isDefined) {
      partition.copy(
        spec = restoredSpec,
        stats = restoredStats,
        parameters = partition.parameters.filterNot {
          case (key, _) => key.startsWith(SPARK_SQL_PREFIX) })
    } else {
      partition.copy(spec = restoredSpec)
    }
  }

  /**
   * Returns the specified partition or None if it does not exist.
   */
  override def getPartitionOption(
      db: String,
      table: String,
      spec: TablePartitionSpec): Option[CatalogTablePartition] = withClient {
    client.getPartitionOption(db, table, lowerCasePartitionSpec(spec)).map { part =>
      restorePartitionMetadata(part, getTable(db, table))
    }
  }

  /**
   * Returns the partition names from hive metastore for a given table in a database.
   */
  override def listPartitionNames(
      db: String,
      table: String,
      partialSpec: Option[TablePartitionSpec] = None): Seq[String] = withClient {
    val catalogTable = getTable(db, table)
    val partColNameMap = buildLowerCasePartColNameMap(catalogTable).mapValues(escapePathName)
    val clientPartitionNames =
      client.getPartitionNames(catalogTable, partialSpec.map(lowerCasePartitionSpec))
    clientPartitionNames.map { partitionPath =>
      val partSpec = PartitioningUtils.parsePathFragmentAsSeq(partitionPath)
      partSpec.map { case (partName, partValue) =>
        partColNameMap(partName.toLowerCase) + "=" + escapePathName(partValue)
      }.mkString("/")
    }
  }

  /**
   * Returns the partitions from hive metastore for a given table in a database.
   */
  override def listPartitions(
      db: String,
      table: String,
      partialSpec: Option[TablePartitionSpec] = None): Seq[CatalogTablePartition] = withClient {
    val partColNameMap = buildLowerCasePartColNameMap(getTable(db, table))
    val res = client.getPartitions(db, table, partialSpec.map(lowerCasePartitionSpec)).map { part =>
      part.copy(spec = restorePartitionSpec(part.spec, partColNameMap))
    }

    partialSpec match {
      // This might be a bug of Hive: When the partition value inside the partial partition spec
      // contains dot, and we ask Hive to list partitions w.r.t. the partial partition spec, Hive
      // treats dot as matching any single character and may return more partitions than we
      // expected. Here we do an extra filter to drop unexpected partitions.
      case Some(spec) if spec.exists(_._2.contains(".")) =>
        res.filter(p => isPartialPartitionSpec(spec, p.spec))
      case _ => res
    }
  }

  override def listPartitionsByFilter(
      db: String,
      table: String,
      predicates: Seq[Expression],
      defaultTimeZoneId: String): Seq[CatalogTablePartition] = withClient {
    val rawTable = getRawTable(db, table)
    val catalogTable = restoreTableMetadata(rawTable)

    val partColNameMap = buildLowerCasePartColNameMap(catalogTable)

    val clientPrunedPartitions =
      client.getPartitionsByFilter(rawTable, predicates).map { part =>
        part.copy(spec = restorePartitionSpec(part.spec, partColNameMap))
      }
    prunePartitionsByFilter(catalogTable, clientPrunedPartitions, predicates, defaultTimeZoneId)
  }

  // --------------------------------------------------------------------------
  // Functions
  // --------------------------------------------------------------------------

  override def createFunction(
      db: String,
      funcDefinition: CatalogFunction): Unit = withClient {
    requireDbExists(db)
    // Hive's metastore is case insensitive. However, Hive's createFunction does
    // not normalize the function name (unlike the getFunction part). So,
    // we are normalizing the function name.
    val functionName = funcDefinition.identifier.funcName.toLowerCase(Locale.ROOT)
    requireFunctionNotExists(db, functionName)
    val functionIdentifier = funcDefinition.identifier.copy(funcName = functionName)
    client.createFunction(db, funcDefinition.copy(identifier = functionIdentifier))
  }

  override def dropFunction(db: String, name: String): Unit = withClient {
    requireFunctionExists(db, name)
    client.dropFunction(db, name)
  }

  override def alterFunction(
      db: String, funcDefinition: CatalogFunction): Unit = withClient {
    requireDbExists(db)
    val functionName = funcDefinition.identifier.funcName.toLowerCase(Locale.ROOT)
    requireFunctionExists(db, functionName)
    val functionIdentifier = funcDefinition.identifier.copy(funcName = functionName)
    client.alterFunction(db, funcDefinition.copy(identifier = functionIdentifier))
  }

  override def renameFunction(
      db: String,
      oldName: String,
      newName: String): Unit = withClient {
    requireFunctionExists(db, oldName)
    requireFunctionNotExists(db, newName)
    client.renameFunction(db, oldName, newName)
  }

  override def getFunction(db: String, funcName: String): CatalogFunction = withClient {
    requireFunctionExists(db, funcName)
    client.getFunction(db, funcName)
  }

  override def functionExists(db: String, funcName: String): Boolean = withClient {
    requireDbExists(db)
    client.functionExists(db, funcName)
  }

  override def listFunctions(db: String, pattern: String): Seq[String] = withClient {
    requireDbExists(db)
    client.listFunctions(db, pattern)
  }

}

object HiveExternalCatalog {
  val SPARK_SQL_PREFIX = "spark.sql."

  val DATASOURCE_PREFIX = SPARK_SQL_PREFIX + "sources."
  val DATASOURCE_PROVIDER = DATASOURCE_PREFIX + "provider"
  val DATASOURCE_SCHEMA = DATASOURCE_PREFIX + "schema"
  val DATASOURCE_SCHEMA_PREFIX = DATASOURCE_SCHEMA + "."
  val DATASOURCE_SCHEMA_NUMPARTS = DATASOURCE_SCHEMA_PREFIX + "numParts"
  val DATASOURCE_SCHEMA_NUMPARTCOLS = DATASOURCE_SCHEMA_PREFIX + "numPartCols"
  val DATASOURCE_SCHEMA_NUMSORTCOLS = DATASOURCE_SCHEMA_PREFIX + "numSortCols"
  val DATASOURCE_SCHEMA_NUMBUCKETS = DATASOURCE_SCHEMA_PREFIX + "numBuckets"
  val DATASOURCE_SCHEMA_NUMBUCKETCOLS = DATASOURCE_SCHEMA_PREFIX + "numBucketCols"
  val DATASOURCE_SCHEMA_PART_PREFIX = DATASOURCE_SCHEMA_PREFIX + "part."
  val DATASOURCE_SCHEMA_PARTCOL_PREFIX = DATASOURCE_SCHEMA_PREFIX + "partCol."
  val DATASOURCE_SCHEMA_BUCKETCOL_PREFIX = DATASOURCE_SCHEMA_PREFIX + "bucketCol."
  val DATASOURCE_SCHEMA_SORTCOL_PREFIX = DATASOURCE_SCHEMA_PREFIX + "sortCol."

  val STATISTICS_PREFIX = SPARK_SQL_PREFIX + "statistics."
  val STATISTICS_TOTAL_SIZE = STATISTICS_PREFIX + "totalSize"
  val STATISTICS_NUM_ROWS = STATISTICS_PREFIX + "numRows"
  val STATISTICS_COL_STATS_PREFIX = STATISTICS_PREFIX + "colStats."

  val TABLE_PARTITION_PROVIDER = SPARK_SQL_PREFIX + "partitionProvider"
  val TABLE_PARTITION_PROVIDER_CATALOG = "catalog"
  val TABLE_PARTITION_PROVIDER_FILESYSTEM = "filesystem"

  val CREATED_SPARK_VERSION = SPARK_SQL_PREFIX + "create.version"

  // When storing data source tables in hive metastore, we need to set data schema to empty if the
  // schema is hive-incompatible. However we need a hack to preserve existing behavior. Before
  // Spark 2.0, we do not set a default serde here (this was done in Hive), and so if the user
  // provides an empty schema Hive would automatically populate the schema with a single field
  // "col". However, after SPARK-14388, we set the default serde to LazySimpleSerde so this
  // implicit behavior no longer happens. Therefore, we need to do it in Spark ourselves.
  val EMPTY_DATA_SCHEMA = new StructType()
    .add("col", "array<string>", nullable = true, comment = "from deserializer")

  // A persisted data source table always store its schema in the catalog.
  private def getSchemaFromTableProperties(metadata: CatalogTable): StructType = {
    val errorMessage = "Could not read schema from the hive metastore because it is corrupted."
    val props = metadata.properties
    val schema = props.get(DATASOURCE_SCHEMA)
    if (schema.isDefined) {
      // Originally, we used `spark.sql.sources.schema` to store the schema of a data source table.
      // After SPARK-6024, we removed this flag.
      // Although we are not using `spark.sql.sources.schema` any more, we need to still support.
      DataType.fromJson(schema.get).asInstanceOf[StructType]
    } else if (props.filterKeys(_.startsWith(DATASOURCE_SCHEMA_PREFIX)).isEmpty) {
      // If there is no schema information in table properties, it means the schema of this table
      // was empty when saving into metastore, which is possible in older version(prior to 2.1) of
      // Spark. We should respect it.
      new StructType()
    } else {
      val numSchemaParts = props.get(DATASOURCE_SCHEMA_NUMPARTS)
      if (numSchemaParts.isDefined) {
        val parts = (0 until numSchemaParts.get.toInt).map { index =>
          val part = metadata.properties.get(s"$DATASOURCE_SCHEMA_PART_PREFIX$index").orNull
          if (part == null) {
            throw new AnalysisException(errorMessage +
              s" (missing part $index of the schema, ${numSchemaParts.get} parts are expected).")
          }
          part
        }
        // Stick all parts back to a single schema string.
        DataType.fromJson(parts.mkString).asInstanceOf[StructType]
      } else {
        throw new AnalysisException(errorMessage)
      }
    }
  }

  private def getColumnNamesByType(
      props: Map[String, String],
      colType: String,
      typeName: String): Seq[String] = {
    for {
      numCols <- props.get(s"spark.sql.sources.schema.num${colType.capitalize}Cols").toSeq
      index <- 0 until numCols.toInt
    } yield props.getOrElse(
      s"$DATASOURCE_SCHEMA_PREFIX${colType}Col.$index",
      throw new AnalysisException(
        s"Corrupted $typeName in catalog: $numCols parts expected, but part $index is missing."
      )
    )
  }

  private def getPartitionColumnsFromTableProperties(metadata: CatalogTable): Seq[String] = {
    getColumnNamesByType(metadata.properties, "part", "partitioning columns")
  }

  private def getBucketSpecFromTableProperties(metadata: CatalogTable): Option[BucketSpec] = {
    metadata.properties.get(DATASOURCE_SCHEMA_NUMBUCKETS).map { numBuckets =>
      BucketSpec(
        numBuckets.toInt,
        getColumnNamesByType(metadata.properties, "bucket", "bucketing columns"),
        getColumnNamesByType(metadata.properties, "sort", "sorting columns"))
    }
  }

  /**
   * Detects a data source table. This checks both the table provider and the table properties,
   * unlike DDLUtils which just checks the former.
   */
  private[spark] def isDatasourceTable(table: CatalogTable): Boolean = {
    val provider = table.provider.orElse(table.properties.get(DATASOURCE_PROVIDER))
    provider.isDefined && provider != Some(DDLUtils.HIVE_PROVIDER)
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

package org.apache.spark.sql.hive.execution

import scala.collection.JavaConverters._

import org.apache.hadoop.fs.{FileStatus, Path}
import org.apache.hadoop.hive.ql.exec.Utilities
import org.apache.hadoop.hive.ql.io.{HiveFileFormatUtils, HiveOutputFormat}
import org.apache.hadoop.hive.serde2.Serializer
import org.apache.hadoop.hive.serde2.objectinspector.{ObjectInspectorUtils, StructObjectInspector}
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorUtils.ObjectInspectorCopyOption
import org.apache.hadoop.io.Writable
import org.apache.hadoop.mapred.{JobConf, Reporter}
import org.apache.hadoop.mapreduce.{Job, TaskAttemptContext}

import org.apache.spark.internal.Logging
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.execution.datasources.{FileFormat, OutputWriter, OutputWriterFactory}
import org.apache.spark.sql.hive.{HiveInspectors, HiveTableUtil}
import org.apache.spark.sql.hive.HiveShim.{ShimFileSinkDesc => FileSinkDesc}
import org.apache.spark.sql.sources.DataSourceRegister
import org.apache.spark.sql.types.StructType
import org.apache.spark.util.SerializableJobConf

/**
 * `FileFormat` for writing Hive tables.
 *
 * TODO: implement the read logic.
 */
class HiveFileFormat(fileSinkConf: FileSinkDesc)
  extends FileFormat with DataSourceRegister with Logging {

  def this() = this(null)

  override def shortName(): String = "hive"

  override def inferSchema(
      sparkSession: SparkSession,
      options: Map[String, String],
      files: Seq[FileStatus]): Option[StructType] = {
    throw new UnsupportedOperationException(s"inferSchema is not supported for hive data source.")
  }

  override def prepareWrite(
      sparkSession: SparkSession,
      job: Job,
      options: Map[String, String],
      dataSchema: StructType): OutputWriterFactory = {
    val conf = job.getConfiguration
    val tableDesc = fileSinkConf.getTableInfo
    conf.set("mapred.output.format.class", tableDesc.getOutputFileFormatClassName)

    // When speculation is on and output committer class name contains "Direct", we should warn
    // users that they may loss data if they are using a direct output committer.
    val speculationEnabled = sparkSession.sparkContext.conf.getBoolean("spark.speculation", false)
    val outputCommitterClass = conf.get("mapred.output.committer.class", "")
    if (speculationEnabled && outputCommitterClass.contains("Direct")) {
      val warningMessage =
        s"$outputCommitterClass may be an output committer that writes data directly to " +
          "the final location. Because speculation is enabled, this output committer may " +
          "cause data loss (see the case in SPARK-10063). If possible, please use an output " +
          "committer that does not have this behavior (e.g. FileOutputCommitter)."
      logWarning(warningMessage)
    }

    // Add table properties from storage handler to hadoopConf, so any custom storage
    // handler settings can be set to hadoopConf
    HiveTableUtil.configureJobPropertiesForStorageHandler(tableDesc, conf, false)
    Utilities.copyTableJobPropertiesToConf(tableDesc, conf)

    // Avoid referencing the outer object.
    val fileSinkConfSer = fileSinkConf
    new OutputWriterFactory {
      private val jobConf = new SerializableJobConf(new JobConf(conf))
      @transient private lazy val outputFormat =
        jobConf.value.getOutputFormat.asInstanceOf[HiveOutputFormat[AnyRef, Writable]]

      override def getFileExtension(context: TaskAttemptContext): String = {
        Utilities.getFileExtension(jobConf.value, fileSinkConfSer.getCompressed, outputFormat)
      }

      override def newInstance(
          path: String,
          dataSchema: StructType,
          context: TaskAttemptContext): OutputWriter = {
        new HiveOutputWriter(path, fileSinkConfSer, jobConf.value, dataSchema)
      }
    }
  }
}

class HiveOutputWriter(
    path: String,
    fileSinkConf: FileSinkDesc,
    jobConf: JobConf,
    dataSchema: StructType) extends OutputWriter with HiveInspectors {

  private def tableDesc = fileSinkConf.getTableInfo

  private val serializer = {
    val serializer = tableDesc.getDeserializerClass.newInstance().asInstanceOf[Serializer]
    serializer.initialize(jobConf, tableDesc.getProperties)
    serializer
  }

  private val hiveWriter = HiveFileFormatUtils.getHiveRecordWriter(
    jobConf,
    tableDesc,
    serializer.getSerializedClass,
    fileSinkConf,
    new Path(path),
    Reporter.NULL)

  private val standardOI = ObjectInspectorUtils
    .getStandardObjectInspector(
      tableDesc.getDeserializer(jobConf).getObjectInspector,
      ObjectInspectorCopyOption.JAVA)
    .asInstanceOf[StructObjectInspector]

  private val fieldOIs =
    standardOI.getAllStructFieldRefs.asScala.map(_.getFieldObjectInspector).toArray
  private val dataTypes = dataSchema.map(_.dataType).toArray
  private val wrappers = fieldOIs.zip(dataTypes).map { case (f, dt) => wrapperFor(f, dt) }
  private val outputData = new Array[Any](fieldOIs.length)

  override def write(row: InternalRow): Unit = {
    var i = 0
    while (i < fieldOIs.length) {
      outputData(i) = if (row.isNullAt(i)) null else wrappers(i)(row.get(i, dataTypes(i)))
      i += 1
    }
    hiveWriter.write(serializer.serialize(outputData, standardOI))
  }

  override def close(): Unit = {
    // Seems the boolean value passed into close does not matter.
    hiveWriter.close(false)
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

package org.apache.spark.sql.hive

import java.lang.reflect.{ParameterizedType, Type, WildcardType}

import scala.collection.JavaConverters._

import org.apache.hadoop.{io => hadoopIo}
import org.apache.hadoop.hive.common.`type`.{HiveChar, HiveDecimal, HiveVarchar}
import org.apache.hadoop.hive.serde2.{io => hiveIo}
import org.apache.hadoop.hive.serde2.objectinspector.{StructField => HiveStructField, _}
import org.apache.hadoop.hive.serde2.objectinspector.primitive._
import org.apache.hadoop.hive.serde2.typeinfo.{DecimalTypeInfo, TypeInfoFactory}

import org.apache.spark.sql.AnalysisException
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.util._
import org.apache.spark.sql.types
import org.apache.spark.sql.types._
import org.apache.spark.unsafe.types.UTF8String

/**
 * 1. The Underlying data type in catalyst and in Hive
 * In catalyst:
 *  Primitive  =>
 *     UTF8String
 *     int / scala.Int
 *     boolean / scala.Boolean
 *     float / scala.Float
 *     double / scala.Double
 *     long / scala.Long
 *     short / scala.Short
 *     byte / scala.Byte
 *     [[org.apache.spark.sql.types.Decimal]]
 *     Array[Byte]
 *     java.sql.Date
 *     java.sql.Timestamp
 *  Complex Types =>
 *    Map: `MapData`
 *    List: `ArrayData`
 *    Struct: [[org.apache.spark.sql.catalyst.InternalRow]]
 *    Union: NOT SUPPORTED YET
 *  The Complex types plays as a container, which can hold arbitrary data types.
 *
 * In Hive, the native data types are various, in UDF/UDAF/UDTF, and associated with
 * Object Inspectors, in Hive expression evaluation framework, the underlying data are
 * Primitive Type
 *   Java Boxed Primitives:
 *       org.apache.hadoop.hive.common.type.HiveVarchar
 *       org.apache.hadoop.hive.common.type.HiveChar
 *       java.lang.String
 *       java.lang.Integer
 *       java.lang.Boolean
 *       java.lang.Float
 *       java.lang.Double
 *       java.lang.Long
 *       java.lang.Short
 *       java.lang.Byte
 *       org.apache.hadoop.hive.common.`type`.HiveDecimal
 *       byte[]
 *       java.sql.Date
 *       java.sql.Timestamp
 *   Writables:
 *       org.apache.hadoop.hive.serde2.io.HiveVarcharWritable
 *       org.apache.hadoop.hive.serde2.io.HiveCharWritable
 *       org.apache.hadoop.io.Text
 *       org.apache.hadoop.io.IntWritable
 *       org.apache.hadoop.hive.serde2.io.DoubleWritable
 *       org.apache.hadoop.io.BooleanWritable
 *       org.apache.hadoop.io.LongWritable
 *       org.apache.hadoop.io.FloatWritable
 *       org.apache.hadoop.hive.serde2.io.ShortWritable
 *       org.apache.hadoop.hive.serde2.io.ByteWritable
 *       org.apache.hadoop.io.BytesWritable
 *       org.apache.hadoop.hive.serde2.io.DateWritable
 *       org.apache.hadoop.hive.serde2.io.TimestampWritable
 *       org.apache.hadoop.hive.serde2.io.HiveDecimalWritable
 * Complex Type
 *   List: Object[] / java.util.List
 *   Map: java.util.Map
 *   Struct: Object[] / java.util.List / java POJO
 *   Union: class StandardUnion { byte tag; Object object }
 *
 * NOTICE: HiveVarchar/HiveChar is not supported by catalyst, it will be simply considered as
 *  String type.
 *
 *
 * 2. Hive ObjectInspector is a group of flexible APIs to inspect value in different data
 *  representation, and developers can extend those API as needed, so technically,
 *  object inspector supports arbitrary data type in java.
 *
 * Fortunately, only few built-in Hive Object Inspectors are used in generic udf/udaf/udtf
 * evaluation.
 * 1) Primitive Types (PrimitiveObjectInspector & its sub classes)
  {{{
   public interface PrimitiveObjectInspector {
     // Java Primitives (java.lang.Integer, java.lang.String etc.)
     Object getPrimitiveJavaObject(Object o);
     // Writables (hadoop.io.IntWritable, hadoop.io.Text etc.)
     Object getPrimitiveWritableObject(Object o);
     // ObjectInspector only inspect the `writable` always return true, we need to check it
     // before invoking the methods above.
     boolean preferWritable();
     ...
   }
  }}}

 * 2) Complex Types:
 *   ListObjectInspector: inspects java array or [[java.util.List]]
 *   MapObjectInspector: inspects [[java.util.Map]]
 *   Struct.StructObjectInspector: inspects java array, [[java.util.List]] and
 *                                 even a normal java object (POJO)
 *   UnionObjectInspector: (tag: Int, object data) (TODO: not supported by SparkSQL yet)
 *
 * 3) ConstantObjectInspector:
 * Constant object inspector can be either primitive type or Complex type, and it bundles a
 * constant value as its property, usually the value is created when the constant object inspector
 * constructed.
 * {{{
   public interface ConstantObjectInspector extends ObjectInspector {
      Object getWritableConstantValue();
      ...
    }
  }}}
 * Hive provides 3 built-in constant object inspectors:
 * Primitive Object Inspectors:
 *     WritableConstantStringObjectInspector
 *     WritableConstantHiveVarcharObjectInspector
 *     WritableConstantHiveCharObjectInspector
 *     WritableConstantHiveDecimalObjectInspector
 *     WritableConstantTimestampObjectInspector
 *     WritableConstantIntObjectInspector
 *     WritableConstantDoubleObjectInspector
 *     WritableConstantBooleanObjectInspector
 *     WritableConstantLongObjectInspector
 *     WritableConstantFloatObjectInspector
 *     WritableConstantShortObjectInspector
 *     WritableConstantByteObjectInspector
 *     WritableConstantBinaryObjectInspector
 *     WritableConstantDateObjectInspector
 * Map Object Inspector:
 *     StandardConstantMapObjectInspector
 * List Object Inspector:
 *     StandardConstantListObjectInspector]]
 * Struct Object Inspector: Hive doesn't provide the built-in constant object inspector for Struct
 * Union Object Inspector: Hive doesn't provide the built-in constant object inspector for Union
 *
 *
 * 3. This trait facilitates:
 *    Data Unwrapping: Hive Data => Catalyst Data (unwrap)
 *    Data Wrapping: Catalyst Data => Hive Data (wrap)
 *    Binding the Object Inspector for Catalyst Data (toInspector)
 *    Retrieving the Catalyst Data Type from Object Inspector (inspectorToDataType)
 *
 *
 * 4. Future Improvement (TODO)
 *   This implementation is quite ugly and inefficient:
 *     a. Pattern matching in runtime
 *     b. Small objects creation in catalyst data => writable
 *     c. Unnecessary unwrap / wrap for nested UDF invoking:
 *       e.g. date_add(printf("%s-%s-%s", a,b,c), 3)
 *       We don't need to unwrap the data for printf and wrap it again and passes in data_add
 */
private[hive] trait HiveInspectors {

  def javaTypeToDataType(clz: Type): DataType = clz match {
    // writable
    case c: Class[_] if c == classOf[hadoopIo.DoubleWritable] => DoubleType
    case c: Class[_] if c == classOf[hiveIo.DoubleWritable] => DoubleType
    case c: Class[_] if c == classOf[hiveIo.HiveDecimalWritable] => DecimalType.SYSTEM_DEFAULT
    case c: Class[_] if c == classOf[hiveIo.ByteWritable] => ByteType
    case c: Class[_] if c == classOf[hiveIo.ShortWritable] => ShortType
    case c: Class[_] if c == classOf[hiveIo.DateWritable] => DateType
    case c: Class[_] if c == classOf[hiveIo.TimestampWritable] => TimestampType
    case c: Class[_] if c == classOf[hadoopIo.Text] => StringType
    case c: Class[_] if c == classOf[hadoopIo.IntWritable] => IntegerType
    case c: Class[_] if c == classOf[hadoopIo.LongWritable] => LongType
    case c: Class[_] if c == classOf[hadoopIo.FloatWritable] => FloatType
    case c: Class[_] if c == classOf[hadoopIo.BooleanWritable] => BooleanType
    case c: Class[_] if c == classOf[hadoopIo.BytesWritable] => BinaryType

    // java class
    case c: Class[_] if c == classOf[java.lang.String] => StringType
    case c: Class[_] if c == classOf[java.sql.Date] => DateType
    case c: Class[_] if c == classOf[java.sql.Timestamp] => TimestampType
    case c: Class[_] if c == classOf[HiveDecimal] => DecimalType.SYSTEM_DEFAULT
    case c: Class[_] if c == classOf[java.math.BigDecimal] => DecimalType.SYSTEM_DEFAULT
    case c: Class[_] if c == classOf[Array[Byte]] => BinaryType
    case c: Class[_] if c == classOf[java.lang.Short] => ShortType
    case c: Class[_] if c == classOf[java.lang.Integer] => IntegerType
    case c: Class[_] if c == classOf[java.lang.Long] => LongType
    case c: Class[_] if c == classOf[java.lang.Double] => DoubleType
    case c: Class[_] if c == classOf[java.lang.Byte] => ByteType
    case c: Class[_] if c == classOf[java.lang.Float] => FloatType
    case c: Class[_] if c == classOf[java.lang.Boolean] => BooleanType

    // primitive type
    case c: Class[_] if c == java.lang.Short.TYPE => ShortType
    case c: Class[_] if c == java.lang.Integer.TYPE => IntegerType
    case c: Class[_] if c == java.lang.Long.TYPE => LongType
    case c: Class[_] if c == java.lang.Double.TYPE => DoubleType
    case c: Class[_] if c == java.lang.Byte.TYPE => ByteType
    case c: Class[_] if c == java.lang.Float.TYPE => FloatType
    case c: Class[_] if c == java.lang.Boolean.TYPE => BooleanType

    case c: Class[_] if c.isArray => ArrayType(javaTypeToDataType(c.getComponentType))

    // Hive seems to return this for struct types?
    case c: Class[_] if c == classOf[java.lang.Object] => NullType

    case p: ParameterizedType if isSubClassOf(p.getRawType, classOf[java.util.List[_]]) =>
      val Array(elementType) = p.getActualTypeArguments
      ArrayType(javaTypeToDataType(elementType))

    case p: ParameterizedType if isSubClassOf(p.getRawType, classOf[java.util.Map[_, _]]) =>
      val Array(keyType, valueType) = p.getActualTypeArguments
      MapType(javaTypeToDataType(keyType), javaTypeToDataType(valueType))

    // raw java list type unsupported
    case c: Class[_] if isSubClassOf(c, classOf[java.util.List[_]]) =>
      throw new AnalysisException(
        "Raw list type in java is unsupported because Spark cannot infer the element type.")

    // raw java map type unsupported
    case c: Class[_] if isSubClassOf(c, classOf[java.util.Map[_, _]]) =>
      throw new AnalysisException(
        "Raw map type in java is unsupported because Spark cannot infer key and value types.")

    case _: WildcardType =>
      throw new AnalysisException(
        "Collection types with wildcards (e.g. List<?> or Map<?, ?>) are unsupported because " +
          "Spark cannot infer the data type for these type parameters.")

    case c => throw new AnalysisException(s"Unsupported java type $c")
  }

  private def isSubClassOf(t: Type, parent: Class[_]): Boolean = t match {
    case cls: Class[_] => parent.isAssignableFrom(cls)
    case _ => false
  }

  private def withNullSafe(f: Any => Any): Any => Any = {
    input => if (input == null) null else f(input)
  }

  /**
   * Wraps with Hive types based on object inspector.
   */
  protected def wrapperFor(oi: ObjectInspector, dataType: DataType): Any => Any = oi match {
    case _ if dataType.isInstanceOf[UserDefinedType[_]] =>
      val sqlType = dataType.asInstanceOf[UserDefinedType[_]].sqlType
      wrapperFor(oi, sqlType)
    case x: ConstantObjectInspector =>
      (o: Any) =>
        x.getWritableConstantValue
    case x: PrimitiveObjectInspector => x match {
      // TODO we don't support the HiveVarcharObjectInspector yet.
      case _: StringObjectInspector if x.preferWritable() =>
        withNullSafe(o => getStringWritable(o))
      case _: StringObjectInspector =>
        withNullSafe(o => o.asInstanceOf[UTF8String].toString())
      case _: IntObjectInspector if x.preferWritable() =>
        withNullSafe(o => getIntWritable(o))
      case _: IntObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Integer])
      case _: BooleanObjectInspector if x.preferWritable() =>
        withNullSafe(o => getBooleanWritable(o))
      case _: BooleanObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Boolean])
      case _: FloatObjectInspector if x.preferWritable() =>
        withNullSafe(o => getFloatWritable(o))
      case _: FloatObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Float])
      case _: DoubleObjectInspector if x.preferWritable() =>
        withNullSafe(o => getDoubleWritable(o))
      case _: DoubleObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Double])
      case _: LongObjectInspector if x.preferWritable() =>
        withNullSafe(o => getLongWritable(o))
      case _: LongObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Long])
      case _: ShortObjectInspector if x.preferWritable() =>
        withNullSafe(o => getShortWritable(o))
      case _: ShortObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Short])
      case _: ByteObjectInspector if x.preferWritable() =>
        withNullSafe(o => getByteWritable(o))
      case _: ByteObjectInspector =>
        withNullSafe(o => o.asInstanceOf[java.lang.Byte])
      case _: JavaHiveVarcharObjectInspector =>
        withNullSafe { o =>
            val s = o.asInstanceOf[UTF8String].toString
            new HiveVarchar(s, s.length)
        }
      case _: JavaHiveCharObjectInspector =>
        withNullSafe { o =>
            val s = o.asInstanceOf[UTF8String].toString
            new HiveChar(s, s.length)
          }
      case _: JavaHiveDecimalObjectInspector =>
        withNullSafe(o =>
          HiveDecimal.create(o.asInstanceOf[Decimal].toJavaBigDecimal))
      case _: JavaDateObjectInspector =>
        withNullSafe(o =>
            DateTimeUtils.toJavaDate(o.asInstanceOf[Int]))
      case _: JavaTimestampObjectInspector =>
        withNullSafe(o =>
            DateTimeUtils.toJavaTimestamp(o.asInstanceOf[Long]))
      case _: HiveDecimalObjectInspector if x.preferWritable() =>
        withNullSafe(o => getDecimalWritable(o.asInstanceOf[Decimal]))
      case _: HiveDecimalObjectInspector =>
        withNullSafe(o =>
            HiveDecimal.create(o.asInstanceOf[Decimal].toJavaBigDecimal))
      case _: BinaryObjectInspector if x.preferWritable() =>
        withNullSafe(o => getBinaryWritable(o))
      case _: BinaryObjectInspector =>
        withNullSafe(o => o.asInstanceOf[Array[Byte]])
      case _: DateObjectInspector if x.preferWritable() =>
        withNullSafe(o => getDateWritable(o))
      case _: DateObjectInspector =>
        withNullSafe(o => DateTimeUtils.toJavaDate(o.asInstanceOf[Int]))
      case _: TimestampObjectInspector if x.preferWritable() =>
        withNullSafe(o => getTimestampWritable(o))
      case _: TimestampObjectInspector =>
        withNullSafe(o => DateTimeUtils.toJavaTimestamp(o.asInstanceOf[Long]))
      case _: VoidObjectInspector =>
        (_: Any) => null // always be null for void object inspector
    }

    case soi: StandardStructObjectInspector =>
      val schema = dataType.asInstanceOf[StructType]
      val wrappers = soi.getAllStructFieldRefs.asScala.zip(schema.fields).map {
        case (ref, field) => wrapperFor(ref.getFieldObjectInspector, field.dataType)
      }
      withNullSafe { o =>
        val struct = soi.create()
        val row = o.asInstanceOf[InternalRow]
        soi.getAllStructFieldRefs.asScala.zip(wrappers).zipWithIndex.foreach {
          case ((field, wrapper), i) =>
            soi.setStructFieldData(struct, field, wrapper(row.get(i, schema(i).dataType)))
        }
        struct
      }

    case ssoi: SettableStructObjectInspector =>
      val structType = dataType.asInstanceOf[StructType]
      val wrappers = ssoi.getAllStructFieldRefs.asScala.zip(structType).map {
        case (ref, tpe) => wrapperFor(ref.getFieldObjectInspector, tpe.dataType)
      }
      withNullSafe { o =>
        val row = o.asInstanceOf[InternalRow]
        // 1. create the pojo (most likely) object
        val result = ssoi.create()
        ssoi.getAllStructFieldRefs.asScala.zip(wrappers).zipWithIndex.foreach {
          case ((field, wrapper), i) =>
            val tpe = structType(i).dataType
            ssoi.setStructFieldData(
            result,
            field,
            wrapper(row.get(i, tpe)).asInstanceOf[AnyRef])
        }
        result
      }

    case soi: StructObjectInspector =>
      val structType = dataType.asInstanceOf[StructType]
      val wrappers = soi.getAllStructFieldRefs.asScala.zip(structType).map {
        case (ref, tpe) => wrapperFor(ref.getFieldObjectInspector, tpe.dataType)
      }
      withNullSafe { o =>
        val row = o.asInstanceOf[InternalRow]
        val result = new java.util.ArrayList[AnyRef](wrappers.size)
        soi.getAllStructFieldRefs.asScala.zip(wrappers).zipWithIndex.foreach {
          case ((field, wrapper), i) =>
          val tpe = structType(i).dataType
          result.add(wrapper(row.get(i, tpe)).asInstanceOf[AnyRef])
        }
        result
      }

    case loi: ListObjectInspector =>
      val elementType = dataType.asInstanceOf[ArrayType].elementType
      val wrapper = wrapperFor(loi.getListElementObjectInspector, elementType)
      withNullSafe { o =>
        val array = o.asInstanceOf[ArrayData]
        val values = new java.util.ArrayList[Any](array.numElements())
        array.foreach(elementType, (_, e) => values.add(wrapper(e)))
        values
      }

    case moi: MapObjectInspector =>
      val mt = dataType.asInstanceOf[MapType]
      val keyWrapper = wrapperFor(moi.getMapKeyObjectInspector, mt.keyType)
      val valueWrapper = wrapperFor(moi.getMapValueObjectInspector, mt.valueType)
      withNullSafe { o =>
          val map = o.asInstanceOf[MapData]
          val jmap = new java.util.HashMap[Any, Any](map.numElements())
          map.foreach(mt.keyType, mt.valueType, (k, v) =>
            jmap.put(keyWrapper(k), valueWrapper(v)))
          jmap
        }

    case _ =>
      identity[Any]
  }

  /**
   * Builds unwrappers ahead of time according to object inspector
   * types to avoid pattern matching and branching costs per row.
   *
   * Strictly follows the following order in unwrapping (constant OI has the higher priority):
   * Constant Null object inspector =>
   *   return null
   * Constant object inspector =>
   *   extract the value from constant object inspector
   * If object inspector prefers writable =>
   *   extract writable from `data` and then get the catalyst type from the writable
   * Extract the java object directly from the object inspector
   *
   * NOTICE: the complex data type requires recursive unwrapping.
   *
   * @param objectInspector the ObjectInspector used to create an unwrapper.
   * @return A function that unwraps data objects.
   *         Use the overloaded HiveStructField version for in-place updating of a MutableRow.
   */
  def unwrapperFor(objectInspector: ObjectInspector): Any => Any =
    objectInspector match {
      case coi: ConstantObjectInspector if coi.getWritableConstantValue == null =>
        _ => null
      case poi: WritableConstantStringObjectInspector =>
        val constant = UTF8String.fromString(poi.getWritableConstantValue.toString)
        _ => constant
      case poi: WritableConstantHiveVarcharObjectInspector =>
        val constant = UTF8String.fromString(poi.getWritableConstantValue.getHiveVarchar.getValue)
        _ => constant
      case poi: WritableConstantHiveCharObjectInspector =>
        val constant = UTF8String.fromString(poi.getWritableConstantValue.getHiveChar.getValue)
        _ => constant
      case poi: WritableConstantHiveDecimalObjectInspector =>
        val constant = HiveShim.toCatalystDecimal(
          PrimitiveObjectInspectorFactory.javaHiveDecimalObjectInspector,
          poi.getWritableConstantValue.getHiveDecimal)
        _ => constant
      case poi: WritableConstantTimestampObjectInspector =>
        val t = poi.getWritableConstantValue
        val constant = t.getSeconds * 1000000L + t.getNanos / 1000L
        _ => constant
      case poi: WritableConstantIntObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantDoubleObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantBooleanObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantLongObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantFloatObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantShortObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantByteObjectInspector =>
        val constant = poi.getWritableConstantValue.get()
        _ => constant
      case poi: WritableConstantBinaryObjectInspector =>
        val writable = poi.getWritableConstantValue
        val constant = new Array[Byte](writable.getLength)
        System.arraycopy(writable.getBytes, 0, constant, 0, constant.length)
        _ => constant
      case poi: WritableConstantDateObjectInspector =>
        val constant = DateTimeUtils.fromJavaDate(poi.getWritableConstantValue.get())
        _ => constant
      case mi: StandardConstantMapObjectInspector =>
        val keyUnwrapper = unwrapperFor(mi.getMapKeyObjectInspector)
        val valueUnwrapper = unwrapperFor(mi.getMapValueObjectInspector)
        val keyValues = mi.getWritableConstantValue
        val constant = ArrayBasedMapData(keyValues, keyUnwrapper, valueUnwrapper)
        _ => constant
      case li: StandardConstantListObjectInspector =>
        val unwrapper = unwrapperFor(li.getListElementObjectInspector)
        val values = li.getWritableConstantValue.asScala
          .map(unwrapper)
          .toArray
        val constant = new GenericArrayData(values)
        _ => constant
      case poi: VoidObjectInspector =>
        _ => null // always be null for void object inspector
      case pi: PrimitiveObjectInspector => pi match {
        // We think HiveVarchar/HiveChar is also a String
        case hvoi: HiveVarcharObjectInspector if hvoi.preferWritable() =>
          data: Any => {
            if (data != null) {
              UTF8String.fromString(hvoi.getPrimitiveWritableObject(data).getHiveVarchar.getValue)
            } else {
              null
            }
          }
        case hvoi: HiveVarcharObjectInspector =>
          data: Any => {
            if (data != null) {
              UTF8String.fromString(hvoi.getPrimitiveJavaObject(data).getValue)
            } else {
              null
            }
          }
        case hvoi: HiveCharObjectInspector if hvoi.preferWritable() =>
          data: Any => {
            if (data != null) {
              UTF8String.fromString(hvoi.getPrimitiveWritableObject(data).getHiveChar.getValue)
            } else {
              null
            }
          }
        case hvoi: HiveCharObjectInspector =>
          data: Any => {
            if (data != null) {
              UTF8String.fromString(hvoi.getPrimitiveJavaObject(data).getValue)
            } else {
              null
            }
          }
        case x: StringObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) {
              // Text is in UTF-8 already. No need to convert again via fromString. Copy bytes
              val wObj = x.getPrimitiveWritableObject(data)
              val result = wObj.copyBytes()
              UTF8String.fromBytes(result, 0, result.length)
            } else {
              null
            }
          }
        case x: StringObjectInspector =>
          data: Any => {
            if (data != null) {
              UTF8String.fromString(x.getPrimitiveJavaObject(data))
            } else {
              null
            }
          }
        case x: IntObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: BooleanObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: FloatObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: DoubleObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: LongObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: ShortObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: ByteObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) x.get(data) else null
          }
        case x: HiveDecimalObjectInspector =>
          data: Any => {
            if (data != null) {
              HiveShim.toCatalystDecimal(x, data)
            } else {
              null
            }
          }
        case x: BinaryObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) {
              // BytesWritable.copyBytes() only available since Hadoop2
              // In order to keep backward-compatible, we have to copy the
              // bytes with old apis
              val bw = x.getPrimitiveWritableObject(data)
              val result = new Array[Byte](bw.getLength())
              System.arraycopy(bw.getBytes(), 0, result, 0, bw.getLength())
              result
            } else {
              null
            }
          }
        case x: DateObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) {
              DateTimeUtils.fromJavaDate(x.getPrimitiveWritableObject(data).get())
            } else {
              null
            }
          }
        case x: DateObjectInspector =>
          data: Any => {
            if (data != null) {
              DateTimeUtils.fromJavaDate(x.getPrimitiveJavaObject(data))
            } else {
              null
            }
          }
        case x: TimestampObjectInspector if x.preferWritable() =>
          data: Any => {
            if (data != null) {
              val t = x.getPrimitiveWritableObject(data)
              t.getSeconds * 1000000L + t.getNanos / 1000L
            } else {
              null
            }
          }
        case ti: TimestampObjectInspector =>
          data: Any => {
            if (data != null) {
              DateTimeUtils.fromJavaTimestamp(ti.getPrimitiveJavaObject(data))
            } else {
              null
            }
          }
        case _ =>
          data: Any => {
            if (data != null) {
              pi.getPrimitiveJavaObject(data)
            } else {
              null
            }
          }
      }
      case li: ListObjectInspector =>
        val unwrapper = unwrapperFor(li.getListElementObjectInspector)
        data: Any => {
          if (data != null) {
            Option(li.getList(data))
              .map { l =>
                val values = l.asScala.map(unwrapper).toArray
                new GenericArrayData(values)
              }
              .orNull
          } else {
            null
          }
        }
      case mi: MapObjectInspector =>
        val keyUnwrapper = unwrapperFor(mi.getMapKeyObjectInspector)
        val valueUnwrapper = unwrapperFor(mi.getMapValueObjectInspector)
        data: Any => {
          if (data != null) {
            val map = mi.getMap(data)
            if (map == null) {
              null
            } else {
              ArrayBasedMapData(map, keyUnwrapper, valueUnwrapper)
            }
          } else {
            null
          }
        }
      // currently, hive doesn't provide the ConstantStructObjectInspector
      case si: StructObjectInspector =>
        val fields = si.getAllStructFieldRefs.asScala
        val unwrappers = fields.map { field =>
          val unwrapper = unwrapperFor(field.getFieldObjectInspector)
          data: Any => unwrapper(si.getStructFieldData(data, field))
        }
        data: Any => {
          if (data != null) {
            InternalRow.fromSeq(unwrappers.map(_(data)))
          } else {
            null
          }
        }
    }

  /**
   * Builds unwrappers ahead of time according to object inspector
   * types to avoid pattern matching and branching costs per row.
   *
   * @param field The HiveStructField to create an unwrapper for.
   * @return A function that performs in-place updating of a MutableRow.
   *         Use the overloaded ObjectInspector version for assignments.
   */
  def unwrapperFor(field: HiveStructField): (Any, InternalRow, Int) => Unit =
    field.getFieldObjectInspector match {
      case oi: BooleanObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setBoolean(ordinal, oi.get(value))
      case oi: ByteObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setByte(ordinal, oi.get(value))
      case oi: ShortObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setShort(ordinal, oi.get(value))
      case oi: IntObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setInt(ordinal, oi.get(value))
      case oi: LongObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setLong(ordinal, oi.get(value))
      case oi: FloatObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setFloat(ordinal, oi.get(value))
      case oi: DoubleObjectInspector =>
        (value: Any, row: InternalRow, ordinal: Int) => row.setDouble(ordinal, oi.get(value))
      case oi =>
        val unwrapper = unwrapperFor(oi)
        (value: Any, row: InternalRow, ordinal: Int) => row(ordinal) = unwrapper(value)
    }

  def wrap(a: Any, oi: ObjectInspector, dataType: DataType): AnyRef = {
    wrapperFor(oi, dataType)(a).asInstanceOf[AnyRef]
  }

  def wrap(
      row: InternalRow,
      wrappers: Array[(Any) => Any],
      cache: Array[AnyRef],
      dataTypes: Array[DataType]): Array[AnyRef] = {
    var i = 0
    val length = wrappers.length
    while (i < length) {
      cache(i) = wrappers(i)(row.get(i, dataTypes(i))).asInstanceOf[AnyRef]
      i += 1
    }
    cache
  }

  def wrap(
      row: Seq[Any],
      wrappers: Array[(Any) => Any],
      cache: Array[AnyRef],
      dataTypes: Array[DataType]): Array[AnyRef] = {
    var i = 0
    val length = wrappers.length
    while (i < length) {
      cache(i) = wrappers(i)(row(i)).asInstanceOf[AnyRef]
      i += 1
    }
    cache
  }

  /**
   * @param dataType Catalyst data type
   * @return Hive java object inspector (recursively), not the Writable ObjectInspector
   * We can easily map to the Hive built-in object inspector according to the data type.
   */
  def toInspector(dataType: DataType): ObjectInspector = dataType match {
    case ArrayType(tpe, _) =>
      ObjectInspectorFactory.getStandardListObjectInspector(toInspector(tpe))
    case MapType(keyType, valueType, _) =>
      ObjectInspectorFactory.getStandardMapObjectInspector(
        toInspector(keyType), toInspector(valueType))
    case StringType => PrimitiveObjectInspectorFactory.javaStringObjectInspector
    case IntegerType => PrimitiveObjectInspectorFactory.javaIntObjectInspector
    case DoubleType => PrimitiveObjectInspectorFactory.javaDoubleObjectInspector
    case BooleanType => PrimitiveObjectInspectorFactory.javaBooleanObjectInspector
    case LongType => PrimitiveObjectInspectorFactory.javaLongObjectInspector
    case FloatType => PrimitiveObjectInspectorFactory.javaFloatObjectInspector
    case ShortType => PrimitiveObjectInspectorFactory.javaShortObjectInspector
    case ByteType => PrimitiveObjectInspectorFactory.javaByteObjectInspector
    case NullType => PrimitiveObjectInspectorFactory.javaVoidObjectInspector
    case BinaryType => PrimitiveObjectInspectorFactory.javaByteArrayObjectInspector
    case DateType => PrimitiveObjectInspectorFactory.javaDateObjectInspector
    case TimestampType => PrimitiveObjectInspectorFactory.javaTimestampObjectInspector
    // TODO decimal precision?
    case DecimalType() => PrimitiveObjectInspectorFactory.javaHiveDecimalObjectInspector
    case StructType(fields) =>
      ObjectInspectorFactory.getStandardStructObjectInspector(
        java.util.Arrays.asList(fields.map(f => f.name) : _*),
        java.util.Arrays.asList(fields.map(f => toInspector(f.dataType)) : _*))
  }

  /**
   * Map the catalyst expression to ObjectInspector, however,
   * if the expression is `Literal` or foldable, a constant writable object inspector returns;
   * Otherwise, we always get the object inspector according to its data type(in catalyst)
   * @param expr Catalyst expression to be mapped
   * @return Hive java objectinspector (recursively).
   */
  def toInspector(expr: Expression): ObjectInspector = expr match {
    case Literal(value, StringType) =>
      getStringWritableConstantObjectInspector(value)
    case Literal(value, IntegerType) =>
      getIntWritableConstantObjectInspector(value)
    case Literal(value, DoubleType) =>
      getDoubleWritableConstantObjectInspector(value)
    case Literal(value, BooleanType) =>
      getBooleanWritableConstantObjectInspector(value)
    case Literal(value, LongType) =>
      getLongWritableConstantObjectInspector(value)
    case Literal(value, FloatType) =>
      getFloatWritableConstantObjectInspector(value)
    case Literal(value, ShortType) =>
      getShortWritableConstantObjectInspector(value)
    case Literal(value, ByteType) =>
      getByteWritableConstantObjectInspector(value)
    case Literal(value, BinaryType) =>
      getBinaryWritableConstantObjectInspector(value)
    case Literal(value, DateType) =>
      getDateWritableConstantObjectInspector(value)
    case Literal(value, TimestampType) =>
      getTimestampWritableConstantObjectInspector(value)
    case Literal(value, DecimalType()) =>
      getDecimalWritableConstantObjectInspector(value)
    case Literal(_, NullType) =>
      getPrimitiveNullWritableConstantObjectInspector
    case Literal(value, ArrayType(dt, _)) =>
      val listObjectInspector = toInspector(dt)
      if (value == null) {
        ObjectInspectorFactory.getStandardConstantListObjectInspector(listObjectInspector, null)
      } else {
        val list = new java.util.ArrayList[Object]()
        value.asInstanceOf[ArrayData].foreach(dt, (_, e) =>
          list.add(wrap(e, listObjectInspector, dt)))
        ObjectInspectorFactory.getStandardConstantListObjectInspector(listObjectInspector, list)
      }
    case Literal(value, MapType(keyType, valueType, _)) =>
      val keyOI = toInspector(keyType)
      val valueOI = toInspector(valueType)
      if (value == null) {
        ObjectInspectorFactory.getStandardConstantMapObjectInspector(keyOI, valueOI, null)
      } else {
        val map = value.asInstanceOf[MapData]
        val jmap = new java.util.HashMap[Any, Any](map.numElements())

        map.foreach(keyType, valueType, (k, v) =>
          jmap.put(wrap(k, keyOI, keyType), wrap(v, valueOI, valueType)))

        ObjectInspectorFactory.getStandardConstantMapObjectInspector(keyOI, valueOI, jmap)
      }
    // We will enumerate all of the possible constant expressions, throw exception if we missed
    case Literal(_, dt) => sys.error(s"Hive doesn't support the constant type [$dt].")
    // ideally, we don't test the foldable here(but in optimizer), however, some of the
    // Hive UDF / UDAF requires its argument to be constant objectinspector, we do it eagerly.
    case _ if expr.foldable => toInspector(Literal.create(expr.eval(), expr.dataType))
    // For those non constant expression, map to object inspector according to its data type
    case _ => toInspector(expr.dataType)
  }

  def inspectorToDataType(inspector: ObjectInspector): DataType = inspector match {
    case s: StructObjectInspector =>
      StructType(s.getAllStructFieldRefs.asScala.map(f =>
        types.StructField(
          f.getFieldName, inspectorToDataType(f.getFieldObjectInspector), nullable = true)
      ))
    case l: ListObjectInspector => ArrayType(inspectorToDataType(l.getListElementObjectInspector))
    case m: MapObjectInspector =>
      MapType(
        inspectorToDataType(m.getMapKeyObjectInspector),
        inspectorToDataType(m.getMapValueObjectInspector))
    case _: WritableStringObjectInspector => StringType
    case _: JavaStringObjectInspector => StringType
    case _: WritableHiveVarcharObjectInspector => StringType
    case _: JavaHiveVarcharObjectInspector => StringType
    case _: WritableHiveCharObjectInspector => StringType
    case _: JavaHiveCharObjectInspector => StringType
    case _: WritableIntObjectInspector => IntegerType
    case _: JavaIntObjectInspector => IntegerType
    case _: WritableDoubleObjectInspector => DoubleType
    case _: JavaDoubleObjectInspector => DoubleType
    case _: WritableBooleanObjectInspector => BooleanType
    case _: JavaBooleanObjectInspector => BooleanType
    case _: WritableLongObjectInspector => LongType
    case _: JavaLongObjectInspector => LongType
    case _: WritableShortObjectInspector => ShortType
    case _: JavaShortObjectInspector => ShortType
    case _: WritableByteObjectInspector => ByteType
    case _: JavaByteObjectInspector => ByteType
    case _: WritableFloatObjectInspector => FloatType
    case _: JavaFloatObjectInspector => FloatType
    case _: WritableBinaryObjectInspector => BinaryType
    case _: JavaBinaryObjectInspector => BinaryType
    case w: WritableHiveDecimalObjectInspector => decimalTypeInfoToCatalyst(w)
    case j: JavaHiveDecimalObjectInspector => decimalTypeInfoToCatalyst(j)
    case _: WritableDateObjectInspector => DateType
    case _: JavaDateObjectInspector => DateType
    case _: WritableTimestampObjectInspector => TimestampType
    case _: JavaTimestampObjectInspector => TimestampType
    case _: WritableVoidObjectInspector => NullType
    case _: JavaVoidObjectInspector => NullType
  }

  private def decimalTypeInfoToCatalyst(inspector: PrimitiveObjectInspector): DecimalType = {
    val info = inspector.getTypeInfo.asInstanceOf[DecimalTypeInfo]
    DecimalType(info.precision(), info.scale())
  }

  private def getStringWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.stringTypeInfo, getStringWritable(value))

  private def getIntWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.intTypeInfo, getIntWritable(value))

  private def getDoubleWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.doubleTypeInfo, getDoubleWritable(value))

  private def getBooleanWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.booleanTypeInfo, getBooleanWritable(value))

  private def getLongWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.longTypeInfo, getLongWritable(value))

  private def getFloatWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.floatTypeInfo, getFloatWritable(value))

  private def getShortWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.shortTypeInfo, getShortWritable(value))

  private def getByteWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.byteTypeInfo, getByteWritable(value))

  private def getBinaryWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.binaryTypeInfo, getBinaryWritable(value))

  private def getDateWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.dateTypeInfo, getDateWritable(value))

  private def getTimestampWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.timestampTypeInfo, getTimestampWritable(value))

  private def getDecimalWritableConstantObjectInspector(value: Any): ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.decimalTypeInfo, getDecimalWritable(value))

  private def getPrimitiveNullWritableConstantObjectInspector: ObjectInspector =
    PrimitiveObjectInspectorFactory.getPrimitiveWritableConstantObjectInspector(
      TypeInfoFactory.voidTypeInfo, null)

  private def getStringWritable(value: Any): hadoopIo.Text =
    if (value == null) null else new hadoopIo.Text(value.asInstanceOf[UTF8String].getBytes)

  private def getIntWritable(value: Any): hadoopIo.IntWritable =
    if (value == null) null else new hadoopIo.IntWritable(value.asInstanceOf[Int])

  private def getDoubleWritable(value: Any): hiveIo.DoubleWritable =
    if (value == null) {
      null
    } else {
      new hiveIo.DoubleWritable(value.asInstanceOf[Double])
    }

  private def getBooleanWritable(value: Any): hadoopIo.BooleanWritable =
    if (value == null) {
      null
    } else {
      new hadoopIo.BooleanWritable(value.asInstanceOf[Boolean])
    }

  private def getLongWritable(value: Any): hadoopIo.LongWritable =
    if (value == null) null else new hadoopIo.LongWritable(value.asInstanceOf[Long])

  private def getFloatWritable(value: Any): hadoopIo.FloatWritable =
    if (value == null) {
      null
    } else {
      new hadoopIo.FloatWritable(value.asInstanceOf[Float])
    }

  private def getShortWritable(value: Any): hiveIo.ShortWritable =
    if (value == null) null else new hiveIo.ShortWritable(value.asInstanceOf[Short])

  private def getByteWritable(value: Any): hiveIo.ByteWritable =
    if (value == null) null else new hiveIo.ByteWritable(value.asInstanceOf[Byte])

  private def getBinaryWritable(value: Any): hadoopIo.BytesWritable =
    if (value == null) {
      null
    } else {
      new hadoopIo.BytesWritable(value.asInstanceOf[Array[Byte]])
    }

  private def getDateWritable(value: Any): hiveIo.DateWritable =
    if (value == null) null else new hiveIo.DateWritable(value.asInstanceOf[Int])

  private def getTimestampWritable(value: Any): hiveIo.TimestampWritable =
    if (value == null) {
      null
    } else {
      new hiveIo.TimestampWritable(DateTimeUtils.toJavaTimestamp(value.asInstanceOf[Long]))
    }

  private def getDecimalWritable(value: Any): hiveIo.HiveDecimalWritable =
    if (value == null) {
      null
    } else {
      // TODO precise, scale?
      new hiveIo.HiveDecimalWritable(
        HiveDecimal.create(value.asInstanceOf[Decimal].toJavaBigDecimal))
    }

  implicit class typeInfoConversions(dt: DataType) {
    import org.apache.hadoop.hive.serde2.typeinfo._
    import TypeInfoFactory._

    private def decimalTypeInfo(decimalType: DecimalType): TypeInfo = decimalType match {
      case DecimalType.Fixed(precision, scale) => new DecimalTypeInfo(precision, scale)
    }

    def toTypeInfo: TypeInfo = dt match {
      case ArrayType(elemType, _) =>
        getListTypeInfo(elemType.toTypeInfo)
      case StructType(fields) =>
        getStructTypeInfo(
          java.util.Arrays.asList(fields.map(_.name) : _*),
          java.util.Arrays.asList(fields.map(_.dataType.toTypeInfo) : _*))
      case MapType(keyType, valueType, _) =>
        getMapTypeInfo(keyType.toTypeInfo, valueType.toTypeInfo)
      case BinaryType => binaryTypeInfo
      case BooleanType => booleanTypeInfo
      case ByteType => byteTypeInfo
      case DoubleType => doubleTypeInfo
      case FloatType => floatTypeInfo
      case IntegerType => intTypeInfo
      case LongType => longTypeInfo
      case ShortType => shortTypeInfo
      case StringType => stringTypeInfo
      case d: DecimalType => decimalTypeInfo(d)
      case DateType => dateTypeInfo
      case TimestampType => timestampTypeInfo
      case NullType => voidTypeInfo
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

package org.apache.spark.sql.hive

import scala.util.control.NonFatal

import com.google.common.util.concurrent.Striped
import org.apache.hadoop.fs.Path

import org.apache.spark.SparkException
import org.apache.spark.internal.Logging
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.{QualifiedTableName, TableIdentifier}
import org.apache.spark.sql.catalyst.catalog._
import org.apache.spark.sql.catalyst.plans.logical._
import org.apache.spark.sql.execution.datasources._
import org.apache.spark.sql.internal.SQLConf.HiveCaseSensitiveInferenceMode._
import org.apache.spark.sql.types._

/**
 * Legacy catalog for interacting with the Hive metastore.
 *
 * This is still used for things like creating data source tables, but in the future will be
 * cleaned up to integrate more nicely with [[HiveExternalCatalog]].
 */
private[hive] class HiveMetastoreCatalog(sparkSession: SparkSession) extends Logging {
  // these are def_s and not val/lazy val since the latter would introduce circular references
  private def sessionState = sparkSession.sessionState
  private def catalogProxy = sparkSession.sessionState.catalog
  import HiveMetastoreCatalog._

  /** These locks guard against multiple attempts to instantiate a table, which wastes memory. */
  private val tableCreationLocks = Striped.lazyWeakLock(100)

  /** Acquires a lock on the table cache for the duration of `f`. */
  private def withTableCreationLock[A](tableName: QualifiedTableName, f: => A): A = {
    val lock = tableCreationLocks.get(tableName)
    lock.lock()
    try f finally {
      lock.unlock()
    }
  }

  // For testing only
  private[hive] def getCachedDataSourceTable(table: TableIdentifier): LogicalPlan = {
    val key = QualifiedTableName(
      table.database.getOrElse(sessionState.catalog.getCurrentDatabase).toLowerCase,
      table.table.toLowerCase)
    catalogProxy.getCachedTable(key)
  }

  private def getCached(
      tableIdentifier: QualifiedTableName,
      pathsInMetastore: Seq[Path],
      schemaInMetastore: StructType,
      expectedFileFormat: Class[_ <: FileFormat],
      partitionSchema: Option[StructType]): Option[LogicalRelation] = {

    catalogProxy.getCachedTable(tableIdentifier) match {
      case null => None // Cache miss
      case logical @ LogicalRelation(relation: HadoopFsRelation, _, _, _) =>
        val cachedRelationFileFormatClass = relation.fileFormat.getClass

        expectedFileFormat match {
          case `cachedRelationFileFormatClass` =>
            // If we have the same paths, same schema, and same partition spec,
            // we will use the cached relation.
            val useCached =
              relation.location.rootPaths.toSet == pathsInMetastore.toSet &&
                logical.schema.sameType(schemaInMetastore) &&
                // We don't support hive bucketed tables. This function `getCached` is only used for
                // converting supported Hive tables to data source tables.
                relation.bucketSpec.isEmpty &&
                relation.partitionSchema == partitionSchema.getOrElse(StructType(Nil))

            if (useCached) {
              Some(logical)
            } else {
              // If the cached relation is not updated, we invalidate it right away.
              catalogProxy.invalidateCachedTable(tableIdentifier)
              None
            }
          case _ =>
            logWarning(s"Table $tableIdentifier should be stored as $expectedFileFormat. " +
              s"However, we are getting a ${relation.fileFormat} from the metastore cache. " +
              "This cached entry will be invalidated.")
            catalogProxy.invalidateCachedTable(tableIdentifier)
            None
        }
      case other =>
        logWarning(s"Table $tableIdentifier should be stored as $expectedFileFormat. " +
          s"However, we are getting a $other from the metastore cache. " +
          "This cached entry will be invalidated.")
        catalogProxy.invalidateCachedTable(tableIdentifier)
        None
    }
  }

  def convertToLogicalRelation(
      relation: HiveTableRelation,
      options: Map[String, String],
      fileFormatClass: Class[_ <: FileFormat],
      fileType: String): LogicalRelation = {
    val metastoreSchema = relation.tableMeta.schema
    val tableIdentifier =
      QualifiedTableName(relation.tableMeta.database, relation.tableMeta.identifier.table)

    val lazyPruningEnabled = sparkSession.sqlContext.conf.manageFilesourcePartitions
    val tablePath = new Path(relation.tableMeta.location)
    val fileFormat = fileFormatClass.newInstance()

    val result = if (relation.isPartitioned) {
      val partitionSchema = relation.tableMeta.partitionSchema
      val rootPaths: Seq[Path] = if (lazyPruningEnabled) {
        Seq(tablePath)
      } else {
        // By convention (for example, see CatalogFileIndex), the definition of a
        // partitioned table's paths depends on whether that table has any actual partitions.
        // Partitioned tables without partitions use the location of the table's base path.
        // Partitioned tables with partitions use the locations of those partitions' data
        // locations,_omitting_ the table's base path.
        val paths = sparkSession.sharedState.externalCatalog
          .listPartitions(tableIdentifier.database, tableIdentifier.name)
          .map(p => new Path(p.storage.locationUri.get))

        if (paths.isEmpty) {
          Seq(tablePath)
        } else {
          paths
        }
      }

      withTableCreationLock(tableIdentifier, {
        val cached = getCached(
          tableIdentifier,
          rootPaths,
          metastoreSchema,
          fileFormatClass,
          Some(partitionSchema))

        val logicalRelation = cached.getOrElse {
          val sizeInBytes = relation.stats.sizeInBytes.toLong
          val fileIndex = {
            val index = new CatalogFileIndex(sparkSession, relation.tableMeta, sizeInBytes)
            if (lazyPruningEnabled) {
              index
            } else {
              index.filterPartitions(Nil)  // materialize all the partitions in memory
            }
          }

          val updatedTable = inferIfNeeded(relation, options, fileFormat, Option(fileIndex))

          val fsRelation = HadoopFsRelation(
            location = fileIndex,
            partitionSchema = partitionSchema,
            dataSchema = updatedTable.dataSchema,
            bucketSpec = None,
            fileFormat = fileFormat,
            options = options)(sparkSession = sparkSession)
          val created = LogicalRelation(fsRelation, updatedTable)
          catalogProxy.cacheTable(tableIdentifier, created)
          created
        }

        logicalRelation
      })
    } else {
      val rootPath = tablePath
      withTableCreationLock(tableIdentifier, {
        val cached = getCached(
          tableIdentifier,
          Seq(rootPath),
          metastoreSchema,
          fileFormatClass,
          None)
        val logicalRelation = cached.getOrElse {
          val updatedTable = inferIfNeeded(relation, options, fileFormat)
          val created =
            LogicalRelation(
              DataSource(
                sparkSession = sparkSession,
                paths = rootPath.toString :: Nil,
                userSpecifiedSchema = Option(updatedTable.dataSchema),
                bucketSpec = None,
                options = options,
                className = fileType).resolveRelation(),
              table = updatedTable)

          catalogProxy.cacheTable(tableIdentifier, created)
          created
        }

        logicalRelation
      })
    }
    // The inferred schema may have different field names as the table schema, we should respect
    // it, but also respect the exprId in table relation output.
    assert(result.output.length == relation.output.length &&
      result.output.zip(relation.output).forall { case (a1, a2) => a1.dataType == a2.dataType })
    val newOutput = result.output.zip(relation.output).map {
      case (a1, a2) => a1.withExprId(a2.exprId)
    }
    result.copy(output = newOutput)
  }

  private def inferIfNeeded(
      relation: HiveTableRelation,
      options: Map[String, String],
      fileFormat: FileFormat,
      fileIndexOpt: Option[FileIndex] = None): CatalogTable = {
    val inferenceMode = sparkSession.sessionState.conf.caseSensitiveInferenceMode
    val shouldInfer = (inferenceMode != NEVER_INFER) && !relation.tableMeta.schemaPreservesCase
    val tableName = relation.tableMeta.identifier.unquotedString
    if (shouldInfer) {
      logInfo(s"Inferring case-sensitive schema for table $tableName (inference mode: " +
        s"$inferenceMode)")
      val fileIndex = fileIndexOpt.getOrElse {
        val rootPath = new Path(relation.tableMeta.location)
        new InMemoryFileIndex(sparkSession, Seq(rootPath), options, None)
      }

      val inferredSchema = fileFormat
        .inferSchema(
          sparkSession,
          options,
          fileIndex.listFiles(Nil, Nil).flatMap(_.files))
        .map(mergeWithMetastoreSchema(relation.tableMeta.dataSchema, _))

      inferredSchema match {
        case Some(dataSchema) =>
          if (inferenceMode == INFER_AND_SAVE) {
            updateDataSchema(relation.tableMeta.identifier, dataSchema)
          }
          val newSchema = StructType(dataSchema ++ relation.tableMeta.partitionSchema)
          relation.tableMeta.copy(schema = newSchema)
        case None =>
          logWarning(s"Unable to infer schema for table $tableName from file format " +
            s"$fileFormat (inference mode: $inferenceMode). Using metastore schema.")
          relation.tableMeta
      }
    } else {
      relation.tableMeta
    }
  }

  private def updateDataSchema(identifier: TableIdentifier, newDataSchema: StructType): Unit = try {
    logInfo(s"Saving case-sensitive schema for table ${identifier.unquotedString}")
    sparkSession.sessionState.catalog.alterTableDataSchema(identifier, newDataSchema)
  } catch {
    case NonFatal(ex) =>
      logWarning(s"Unable to save case-sensitive schema for table ${identifier.unquotedString}", ex)
  }
}


private[hive] object HiveMetastoreCatalog {
  def mergeWithMetastoreSchema(
      metastoreSchema: StructType,
      inferredSchema: StructType): StructType = try {
    // Find any nullable fields in mestastore schema that are missing from the inferred schema.
    val metastoreFields = metastoreSchema.map(f => f.name.toLowerCase -> f).toMap
    val missingNullables = metastoreFields
      .filterKeys(!inferredSchema.map(_.name.toLowerCase).contains(_))
      .values
      .filter(_.nullable)
    // Merge missing nullable fields to inferred schema and build a case-insensitive field map.
    val inferredFields = StructType(inferredSchema ++ missingNullables)
      .map(f => f.name.toLowerCase -> f).toMap
    StructType(metastoreSchema.map(f => f.copy(name = inferredFields(f.name.toLowerCase).name)))
  } catch {
    case NonFatal(_) =>
      val msg = s"""Detected conflicting schemas when merging the schema obtained from the Hive
         | Metastore with the one inferred from the file format. Metastore schema:
         |${metastoreSchema.prettyJson}
         |
         |Inferred schema:
         |${inferredSchema.prettyJson}
       """.stripMargin
      throw new SparkException(msg)
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

package org.apache.spark.sql.hive.execution

import java.util.Locale

import scala.collection.JavaConverters._

import org.apache.hadoop.hive.ql.plan.TableDesc
import org.apache.orc.OrcConf.COMPRESS
import org.apache.parquet.hadoop.ParquetOutputFormat

import org.apache.spark.sql.catalyst.util.CaseInsensitiveMap
import org.apache.spark.sql.execution.datasources.orc.OrcOptions
import org.apache.spark.sql.execution.datasources.parquet.ParquetOptions
import org.apache.spark.sql.internal.SQLConf

/**
 * Options for the Hive data source. Note that rule `DetermineHiveSerde` will extract Hive
 * serde/format information from these options.
 */
class HiveOptions(@transient private val parameters: CaseInsensitiveMap[String])
  extends Serializable {
  import HiveOptions._

  def this(parameters: Map[String, String]) = this(CaseInsensitiveMap(parameters))

  val fileFormat = parameters.get(FILE_FORMAT).map(_.toLowerCase(Locale.ROOT))
  val inputFormat = parameters.get(INPUT_FORMAT)
  val outputFormat = parameters.get(OUTPUT_FORMAT)

  if (inputFormat.isDefined != outputFormat.isDefined) {
    throw new IllegalArgumentException("Cannot specify only inputFormat or outputFormat, you " +
      "have to specify both of them.")
  }

  def hasInputOutputFormat: Boolean = inputFormat.isDefined

  if (fileFormat.isDefined && inputFormat.isDefined) {
    throw new IllegalArgumentException("Cannot specify fileFormat and inputFormat/outputFormat " +
      "together for Hive data source.")
  }

  val serde = parameters.get(SERDE)

  if (fileFormat.isDefined && serde.isDefined) {
    if (!Set("sequencefile", "textfile", "rcfile").contains(fileFormat.get)) {
      throw new IllegalArgumentException(
        s"fileFormat '${fileFormat.get}' already specifies a serde.")
    }
  }

  val containsDelimiters = delimiterOptions.keys.exists(parameters.contains)

  if (containsDelimiters) {
    if (serde.isDefined) {
      throw new IllegalArgumentException("Cannot specify delimiters with a custom serde.")
    }
    if (fileFormat.isEmpty) {
      throw new IllegalArgumentException("Cannot specify delimiters without fileFormat.")
    }
    if (fileFormat.get != "textfile") {
      throw new IllegalArgumentException("Cannot specify delimiters as they are only compatible " +
        s"with fileFormat 'textfile', not ${fileFormat.get}.")
    }
  }

  for (lineDelim <- parameters.get("lineDelim") if lineDelim != "\n") {
    throw new IllegalArgumentException("Hive data source only support newline '\\n' as " +
      s"line delimiter, but given: $lineDelim.")
  }

  def serdeProperties: Map[String, String] = parameters.filterKeys {
    k => !lowerCasedOptionNames.contains(k.toLowerCase(Locale.ROOT))
  }.map { case (k, v) => delimiterOptions.getOrElse(k, k) -> v }
}

object HiveOptions {
  private val lowerCasedOptionNames = collection.mutable.Set[String]()

  private def newOption(name: String): String = {
    lowerCasedOptionNames += name.toLowerCase(Locale.ROOT)
    name
  }

  val FILE_FORMAT = newOption("fileFormat")
  val INPUT_FORMAT = newOption("inputFormat")
  val OUTPUT_FORMAT = newOption("outputFormat")
  val SERDE = newOption("serde")

  // A map from the public delimiter option keys to the underlying Hive serde property keys.
  val delimiterOptions = Map(
    "fieldDelim" -> "field.delim",
    "escapeDelim" -> "escape.delim",
    // The following typo is inherited from Hive...
    "collectionDelim" -> "colelction.delim",
    "mapkeyDelim" -> "mapkey.delim",
    "lineDelim" -> "line.delim").map { case (k, v) => k.toLowerCase(Locale.ROOT) -> v }

  def getHiveWriteCompression(tableInfo: TableDesc, sqlConf: SQLConf): Option[(String, String)] = {
    val tableProps = tableInfo.getProperties.asScala.toMap
    tableInfo.getOutputFileFormatClassName.toLowerCase(Locale.ROOT) match {
      case formatName if formatName.endsWith("parquetoutputformat") =>
        val compressionCodec = new ParquetOptions(tableProps, sqlConf).compressionCodecClassName
        Option((ParquetOutputFormat.COMPRESSION, compressionCodec))
      case formatName if formatName.endsWith("orcoutputformat") =>
        val compressionCodec = new OrcOptions(tableProps, sqlConf).compressionCodec
        Option((COMPRESS.getAttribute, compressionCodec))
      case _ => None
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

package org.apache.spark.sql.hive

import java.util.Locale

import scala.util.{Failure, Success, Try}
import scala.util.control.NonFatal

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hive.ql.exec.{UDAF, UDF}
import org.apache.hadoop.hive.ql.exec.{FunctionRegistry => HiveFunctionRegistry}
import org.apache.hadoop.hive.ql.udf.generic.{AbstractGenericUDAFResolver, GenericUDF, GenericUDTF}

import org.apache.spark.sql.AnalysisException
import org.apache.spark.sql.catalyst.FunctionIdentifier
import org.apache.spark.sql.catalyst.analysis.FunctionRegistry
import org.apache.spark.sql.catalyst.catalog.{CatalogFunction, ExternalCatalog, FunctionResourceLoader, GlobalTempViewManager, SessionCatalog}
import org.apache.spark.sql.catalyst.expressions.{Cast, Expression}
import org.apache.spark.sql.catalyst.parser.ParserInterface
import org.apache.spark.sql.hive.HiveShim.HiveFunctionWrapper
import org.apache.spark.sql.internal.SQLConf
import org.apache.spark.sql.types.{DecimalType, DoubleType}


private[sql] class HiveSessionCatalog(
    externalCatalogBuilder: () => ExternalCatalog,
    globalTempViewManagerBuilder: () => GlobalTempViewManager,
    val metastoreCatalog: HiveMetastoreCatalog,
    functionRegistry: FunctionRegistry,
    conf: SQLConf,
    hadoopConf: Configuration,
    parser: ParserInterface,
    functionResourceLoader: FunctionResourceLoader)
  extends SessionCatalog(
      externalCatalogBuilder,
      globalTempViewManagerBuilder,
      functionRegistry,
      conf,
      hadoopConf,
      parser,
      functionResourceLoader) {

  /**
   * Constructs a [[Expression]] based on the provided class that represents a function.
   *
   * This performs reflection to decide what type of [[Expression]] to return in the builder.
   */
  override def makeFunctionExpression(
      name: String,
      clazz: Class[_],
      input: Seq[Expression]): Expression = {

    Try(super.makeFunctionExpression(name, clazz, input)).getOrElse {
      var udfExpr: Option[Expression] = None
      try {
        // When we instantiate hive UDF wrapper class, we may throw exception if the input
        // expressions don't satisfy the hive UDF, such as type mismatch, input number
        // mismatch, etc. Here we catch the exception and throw AnalysisException instead.
        if (classOf[UDF].isAssignableFrom(clazz)) {
          udfExpr = Some(HiveSimpleUDF(name, new HiveFunctionWrapper(clazz.getName), input))
          udfExpr.get.dataType // Force it to check input data types.
        } else if (classOf[GenericUDF].isAssignableFrom(clazz)) {
          udfExpr = Some(HiveGenericUDF(name, new HiveFunctionWrapper(clazz.getName), input))
          udfExpr.get.dataType // Force it to check input data types.
        } else if (classOf[AbstractGenericUDAFResolver].isAssignableFrom(clazz)) {
          udfExpr = Some(HiveUDAFFunction(name, new HiveFunctionWrapper(clazz.getName), input))
          udfExpr.get.dataType // Force it to check input data types.
        } else if (classOf[UDAF].isAssignableFrom(clazz)) {
          udfExpr = Some(HiveUDAFFunction(
            name,
            new HiveFunctionWrapper(clazz.getName),
            input,
            isUDAFBridgeRequired = true))
          udfExpr.get.dataType // Force it to check input data types.
        } else if (classOf[GenericUDTF].isAssignableFrom(clazz)) {
          udfExpr = Some(HiveGenericUDTF(name, new HiveFunctionWrapper(clazz.getName), input))
          udfExpr.get.asInstanceOf[HiveGenericUDTF].elementSchema // Force it to check data types.
        }
      } catch {
        case NonFatal(e) =>
          val noHandlerMsg = s"No handler for UDF/UDAF/UDTF '${clazz.getCanonicalName}': $e"
          val errorMsg =
            if (classOf[GenericUDTF].isAssignableFrom(clazz)) {
              s"$noHandlerMsg\nPlease make sure your function overrides " +
                "`public StructObjectInspector initialize(ObjectInspector[] args)`."
            } else {
              noHandlerMsg
            }
          val analysisException = new AnalysisException(errorMsg)
          analysisException.setStackTrace(e.getStackTrace)
          throw analysisException
      }
      udfExpr.getOrElse {
        throw new AnalysisException(s"No handler for UDF/UDAF/UDTF '${clazz.getCanonicalName}'")
      }
    }
  }

  override def lookupFunction(name: FunctionIdentifier, children: Seq[Expression]): Expression = {
    try {
      lookupFunction0(name, children)
    } catch {
      case NonFatal(_) =>
        // SPARK-16228 ExternalCatalog may recognize `double`-type only.
        val newChildren = children.map { child =>
          if (child.dataType.isInstanceOf[DecimalType]) Cast(child, DoubleType) else child
        }
        lookupFunction0(name, newChildren)
    }
  }

  private def lookupFunction0(name: FunctionIdentifier, children: Seq[Expression]): Expression = {
    val database = name.database.map(formatDatabaseName)
    val funcName = name.copy(database = database)
    Try(super.lookupFunction(funcName, children)) match {
      case Success(expr) => expr
      case Failure(error) =>
        if (super.functionExists(name)) {
          // If the function exists (either in functionRegistry or externalCatalog),
          // it means that there is an error when we create the Expression using the given children.
          // We need to throw the original exception.
          throw error
        } else {
          // This function does not exist (neither in functionRegistry or externalCatalog),
          // let's try to load it as a Hive's built-in function.
          // Hive is case insensitive.
          val functionName = funcName.unquotedString.toLowerCase(Locale.ROOT)
          if (!hiveFunctions.contains(functionName)) {
            failFunctionLookup(funcName)
          }

          // TODO: Remove this fallback path once we implement the list of fallback functions
          // defined below in hiveFunctions.
          val functionInfo = {
            try {
              Option(HiveFunctionRegistry.getFunctionInfo(functionName)).getOrElse(
                failFunctionLookup(funcName))
            } catch {
              // If HiveFunctionRegistry.getFunctionInfo throws an exception,
              // we are failing to load a Hive builtin function, which means that
              // the given function is not a Hive builtin function.
              case NonFatal(e) => failFunctionLookup(funcName)
            }
          }
          val className = functionInfo.getFunctionClass.getName
          val functionIdentifier =
            FunctionIdentifier(functionName.toLowerCase(Locale.ROOT), database)
          val func = CatalogFunction(functionIdentifier, className, Nil)
          // Put this Hive built-in function to our function registry.
          registerFunction(func, overrideIfExists = false)
          // Now, we need to create the Expression.
          functionRegistry.lookupFunction(functionIdentifier, children)
        }
    }
  }

  // TODO Removes this method after implementing Spark native "histogram_numeric".
  override def functionExists(name: FunctionIdentifier): Boolean = {
    super.functionExists(name) || hiveFunctions.contains(name.funcName)
  }

  override def isPersistentFunction(name: FunctionIdentifier): Boolean = {
    super.isPersistentFunction(name) || hiveFunctions.contains(name.funcName)
  }

  /** List of functions we pass over to Hive. Note that over time this list should go to 0. */
  // We have a list of Hive built-in functions that we do not support. So, we will check
  // Hive's function registry and lazily load needed functions into our own function registry.
  // List of functions we are explicitly not supporting are:
  // compute_stats, context_ngrams, create_union,
  // current_user, ewah_bitmap, ewah_bitmap_and, ewah_bitmap_empty, ewah_bitmap_or, field,
  // in_file, index, matchpath, ngrams, noop, noopstreaming, noopwithmap,
  // noopwithmapstreaming, parse_url_tuple, reflect2, windowingtablefunction.
  // Note: don't forget to update SessionCatalog.isTemporaryFunction
  private val hiveFunctions = Seq(
    "histogram_numeric"
  )
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

package org.apache.spark.sql.hive

import org.apache.spark.annotation.{Experimental, InterfaceStability}
import org.apache.spark.sql._
import org.apache.spark.sql.catalyst.analysis.Analyzer
import org.apache.spark.sql.catalyst.catalog.ExternalCatalogWithListener
import org.apache.spark.sql.catalyst.plans.logical.LogicalPlan
import org.apache.spark.sql.catalyst.rules.Rule
import org.apache.spark.sql.execution.SparkPlanner
import org.apache.spark.sql.execution.datasources._
import org.apache.spark.sql.hive.client.HiveClient
import org.apache.spark.sql.internal.{BaseSessionStateBuilder, SessionResourceLoader, SessionState}

/**
 * Builder that produces a Hive-aware `SessionState`.
 */
@Experimental
@InterfaceStability.Unstable
class HiveSessionStateBuilder(session: SparkSession, parentState: Option[SessionState] = None)
  extends BaseSessionStateBuilder(session, parentState) {

  private def externalCatalog: ExternalCatalogWithListener = session.sharedState.externalCatalog

  /**
   * Create a Hive aware resource loader.
   */
  override protected lazy val resourceLoader: HiveSessionResourceLoader = {
    new HiveSessionResourceLoader(
      session, () => externalCatalog.unwrapped.asInstanceOf[HiveExternalCatalog].client)
  }

  /**
   * Create a [[HiveSessionCatalog]].
   */
  override protected lazy val catalog: HiveSessionCatalog = {
    val catalog = new HiveSessionCatalog(
      () => externalCatalog,
      () => session.sharedState.globalTempViewManager,
      new HiveMetastoreCatalog(session),
      functionRegistry,
      conf,
      SessionState.newHadoopConf(session.sparkContext.hadoopConfiguration, conf),
      sqlParser,
      resourceLoader)
    parentState.foreach(_.catalog.copyStateTo(catalog))
    catalog
  }

  /**
   * A logical query plan `Analyzer` with rules specific to Hive.
   */
  override protected def analyzer: Analyzer = new Analyzer(catalog, conf) {
    override val extendedResolutionRules: Seq[Rule[LogicalPlan]] =
      new ResolveHiveSerdeTable(session) +:
        new FindDataSourceTable(session) +:
        new ResolveSQLOnFile(session) +:
        customResolutionRules

    override val postHocResolutionRules: Seq[Rule[LogicalPlan]] =
      new DetermineTableStats(session) +:
        RelationConversions(conf, catalog) +:
        PreprocessTableCreation(session) +:
        PreprocessTableInsertion(conf) +:
        DataSourceAnalysis(conf) +:
        HiveAnalysis +:
        customPostHocResolutionRules

    override val extendedCheckRules: Seq[LogicalPlan => Unit] =
      PreWriteCheck +:
        PreReadCheck +:
        customCheckRules
  }

  /**
   * Planner that takes into account Hive-specific strategies.
   */
  override protected def planner: SparkPlanner = {
    new SparkPlanner(session.sparkContext, conf, experimentalMethods) with HiveStrategies {
      override val sparkSession: SparkSession = session

      override def extraPlanningStrategies: Seq[Strategy] =
        super.extraPlanningStrategies ++ customPlanningStrategies ++ Seq(HiveTableScans, Scripts)
    }
  }

  override protected def newBuilder: NewBuilder = new HiveSessionStateBuilder(_, _)
}

class HiveSessionResourceLoader(
    session: SparkSession,
    clientBuilder: () => HiveClient)
  extends SessionResourceLoader(session) {
  private lazy val client = clientBuilder()
  override def addJar(path: String): Unit = {
    client.addJar(path)
    super.addJar(path)
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

package org.apache.spark.sql.hive

import java.io.{InputStream, OutputStream}
import java.rmi.server.UID

import scala.collection.JavaConverters._
import scala.language.implicitConversions
import scala.reflect.ClassTag

import com.google.common.base.Objects
import org.apache.avro.Schema
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path
import org.apache.hadoop.hive.ql.exec.{UDF, Utilities}
import org.apache.hadoop.hive.ql.plan.{FileSinkDesc, TableDesc}
import org.apache.hadoop.hive.ql.udf.generic.GenericUDFMacro
import org.apache.hadoop.hive.serde2.ColumnProjectionUtils
import org.apache.hadoop.hive.serde2.avro.{AvroGenericRecordWritable, AvroSerdeUtils}
import org.apache.hadoop.hive.serde2.objectinspector.primitive.HiveDecimalObjectInspector
import org.apache.hadoop.io.Writable
import org.apache.hive.com.esotericsoftware.kryo.Kryo
import org.apache.hive.com.esotericsoftware.kryo.io.{Input, Output}

import org.apache.spark.internal.Logging
import org.apache.spark.sql.types.Decimal
import org.apache.spark.util.Utils

private[hive] object HiveShim {
  // Precision and scale to pass for unlimited decimals; these are the same as the precision and
  // scale Hive 0.13 infers for BigDecimals from sources that don't specify them (e.g. UDFs)
  val UNLIMITED_DECIMAL_PRECISION = 38
  val UNLIMITED_DECIMAL_SCALE = 18
  val HIVE_GENERIC_UDF_MACRO_CLS = "org.apache.hadoop.hive.ql.udf.generic.GenericUDFMacro"

  /*
   * This function in hive-0.13 become private, but we have to do this to work around hive bug
   */
  private def appendReadColumnNames(conf: Configuration, cols: Seq[String]) {
    val old: String = conf.get(ColumnProjectionUtils.READ_COLUMN_NAMES_CONF_STR, "")
    val result: StringBuilder = new StringBuilder(old)
    var first: Boolean = old.isEmpty

    for (col <- cols) {
      if (first) {
        first = false
      } else {
        result.append(',')
      }
      result.append(col)
    }
    conf.set(ColumnProjectionUtils.READ_COLUMN_NAMES_CONF_STR, result.toString)
  }

  /*
   * Cannot use ColumnProjectionUtils.appendReadColumns directly, if ids is null
   */
  def appendReadColumns(conf: Configuration, ids: Seq[Integer], names: Seq[String]) {
    if (ids != null) {
      ColumnProjectionUtils.appendReadColumns(conf, ids.asJava)
    }
    if (names != null) {
      appendReadColumnNames(conf, names)
    }
  }

  /*
   * Bug introduced in hive-0.13. AvroGenericRecordWritable has a member recordReaderID that
   * is needed to initialize before serialization.
   */
  def prepareWritable(w: Writable, serDeProps: Seq[(String, String)]): Writable = {
    w match {
      case w: AvroGenericRecordWritable =>
        w.setRecordReaderID(new UID())
        // In Hive 1.1, the record's schema may need to be initialized manually or a NPE will
        // be thrown.
        if (w.getFileSchema() == null) {
          serDeProps
            .find(_._1 == AvroSerdeUtils.AvroTableProperties.SCHEMA_LITERAL.getPropName())
            .foreach { kv =>
              w.setFileSchema(new Schema.Parser().parse(kv._2))
            }
        }
      case _ =>
    }
    w
  }

  def toCatalystDecimal(hdoi: HiveDecimalObjectInspector, data: Any): Decimal = {
    if (hdoi.preferWritable()) {
      Decimal(hdoi.getPrimitiveWritableObject(data).getHiveDecimal().bigDecimalValue,
        hdoi.precision(), hdoi.scale())
    } else {
      Decimal(hdoi.getPrimitiveJavaObject(data).bigDecimalValue(), hdoi.precision(), hdoi.scale())
    }
  }

  /**
   * This class provides the UDF creation and also the UDF instance serialization and
   * de-serialization cross process boundary.
   *
   * Detail discussion can be found at https://github.com/apache/spark/pull/3640
   *
   * @param functionClassName UDF class name
   * @param instance optional UDF instance which contains additional information (for macro)
   */
  private[hive] case class HiveFunctionWrapper(var functionClassName: String,
    private var instance: AnyRef = null) extends java.io.Externalizable {

    // for Serialization
    def this() = this(null)

    override def hashCode(): Int = {
      if (functionClassName == HIVE_GENERIC_UDF_MACRO_CLS) {
        Objects.hashCode(functionClassName, instance.asInstanceOf[GenericUDFMacro].getBody())
      } else {
        functionClassName.hashCode()
      }
    }

    override def equals(other: Any): Boolean = other match {
      case a: HiveFunctionWrapper if functionClassName == a.functionClassName =>
        // In case of udf macro, check to make sure they point to the same underlying UDF
        if (functionClassName == HIVE_GENERIC_UDF_MACRO_CLS) {
          a.instance.asInstanceOf[GenericUDFMacro].getBody() ==
            instance.asInstanceOf[GenericUDFMacro].getBody()
        } else {
          true
        }
      case _ => false
    }

    @transient
    def deserializeObjectByKryo[T: ClassTag](
        kryo: Kryo,
        in: InputStream,
        clazz: Class[_]): T = {
      val inp = new Input(in)
      val t: T = kryo.readObject(inp, clazz).asInstanceOf[T]
      inp.close()
      t
    }

    @transient
    def serializeObjectByKryo(
        kryo: Kryo,
        plan: Object,
        out: OutputStream) {
      val output: Output = new Output(out)
      kryo.writeObject(output, plan)
      output.close()
    }

    def deserializePlan[UDFType](is: java.io.InputStream, clazz: Class[_]): UDFType = {
      deserializeObjectByKryo(Utilities.runtimeSerializationKryo.get(), is, clazz)
        .asInstanceOf[UDFType]
    }

    def serializePlan(function: AnyRef, out: java.io.OutputStream): Unit = {
      serializeObjectByKryo(Utilities.runtimeSerializationKryo.get(), function, out)
    }

    def writeExternal(out: java.io.ObjectOutput) {
      // output the function name
      out.writeUTF(functionClassName)

      // Write a flag if instance is null or not
      out.writeBoolean(instance != null)
      if (instance != null) {
        // Some of the UDF are serializable, but some others are not
        // Hive Utilities can handle both cases
        val baos = new java.io.ByteArrayOutputStream()
        serializePlan(instance, baos)
        val functionInBytes = baos.toByteArray

        // output the function bytes
        out.writeInt(functionInBytes.length)
        out.write(functionInBytes, 0, functionInBytes.length)
      }
    }

    def readExternal(in: java.io.ObjectInput) {
      // read the function name
      functionClassName = in.readUTF()

      if (in.readBoolean()) {
        // if the instance is not null
        // read the function in bytes
        val functionInBytesLength = in.readInt()
        val functionInBytes = new Array[Byte](functionInBytesLength)
        in.readFully(functionInBytes)

        // deserialize the function object via Hive Utilities
        instance = deserializePlan[AnyRef](new java.io.ByteArrayInputStream(functionInBytes),
          Utils.getContextOrSparkClassLoader.loadClass(functionClassName))
      }
    }

    def createFunction[UDFType <: AnyRef](): UDFType = {
      if (instance != null) {
        instance.asInstanceOf[UDFType]
      } else {
        val func = Utils.getContextOrSparkClassLoader
          .loadClass(functionClassName).newInstance.asInstanceOf[UDFType]
        if (!func.isInstanceOf[UDF]) {
          // We cache the function if it's no the Simple UDF,
          // as we always have to create new instance for Simple UDF
          instance = func
        }
        func
      }
    }
  }

  /*
   * Bug introduced in hive-0.13. FileSinkDesc is serializable, but its member path is not.
   * Fix it through wrapper.
   */
  implicit def wrapperToFileSinkDesc(w: ShimFileSinkDesc): FileSinkDesc = {
    val f = new FileSinkDesc(new Path(w.dir), w.tableInfo, w.compressed)
    f.setCompressCodec(w.compressCodec)
    f.setCompressType(w.compressType)
    f.setTableInfo(w.tableInfo)
    f.setDestTableId(w.destTableId)
    f
  }

  /*
   * Bug introduced in hive-0.13. FileSinkDesc is serializable, but its member path is not.
   * Fix it through wrapper.
   */
  private[hive] class ShimFileSinkDesc(
      var dir: String,
      var tableInfo: TableDesc,
      var compressed: Boolean)
    extends Serializable with Logging {
    var compressCodec: String = _
    var compressType: String = _
    var destTableId: Int = _

    def setCompressed(compressed: Boolean) {
      this.compressed = compressed
    }

    def getDirName(): String = dir

    def setDestTableId(destTableId: Int) {
      this.destTableId = destTableId
    }

    def setTableInfo(tableInfo: TableDesc) {
      this.tableInfo = tableInfo
    }

    def setCompressCodec(intermediateCompressorCodec: String) {
      compressCodec = intermediateCompressorCodec
    }

    def setCompressType(intermediateCompressType: String) {
      compressType = intermediateCompressType
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

package org.apache.spark.sql.hive.client

import java.lang.{Boolean => JBoolean, Integer => JInteger, Long => JLong}
import java.lang.reflect.{InvocationTargetException, Method, Modifier}
import java.net.URI
import java.util.{ArrayList => JArrayList, List => JList, Locale, Map => JMap, Set => JSet}
import java.util.concurrent.TimeUnit

import scala.collection.JavaConverters._
import scala.util.control.NonFatal

import org.apache.hadoop.fs.Path
import org.apache.hadoop.hive.conf.HiveConf
import org.apache.hadoop.hive.metastore.api.{EnvironmentContext, Function => HiveFunction, FunctionType}
import org.apache.hadoop.hive.metastore.api.{MetaException, PrincipalType, ResourceType, ResourceUri}
import org.apache.hadoop.hive.ql.Driver
import org.apache.hadoop.hive.ql.io.AcidUtils
import org.apache.hadoop.hive.ql.metadata.{Hive, HiveException, Partition, Table}
import org.apache.hadoop.hive.ql.plan.AddPartitionDesc
import org.apache.hadoop.hive.ql.processors.{CommandProcessor, CommandProcessorFactory}
import org.apache.hadoop.hive.ql.session.SessionState
import org.apache.hadoop.hive.serde.serdeConstants

import org.apache.spark.internal.Logging
import org.apache.spark.sql.AnalysisException
import org.apache.spark.sql.catalyst.FunctionIdentifier
import org.apache.spark.sql.catalyst.analysis.NoSuchPermanentFunctionException
import org.apache.spark.sql.catalyst.catalog.{CatalogFunction, CatalogTablePartition, CatalogUtils, FunctionResource, FunctionResourceType}
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.internal.SQLConf
import org.apache.spark.sql.types.{AtomicType, IntegralType, StringType}
import org.apache.spark.unsafe.types.UTF8String
import org.apache.spark.util.Utils

/**
 * A shim that defines the interface between [[HiveClientImpl]] and the underlying Hive library used
 * to talk to the metastore. Each Hive version has its own implementation of this class, defining
 * version-specific version of needed functions.
 *
 * The guideline for writing shims is:
 * - always extend from the previous version unless really not possible
 * - initialize methods in lazy vals, both for quicker access for multiple invocations, and to
 *   avoid runtime errors due to the above guideline.
 */
private[client] sealed abstract class Shim {

  /**
   * Set the current SessionState to the given SessionState. Also, set the context classloader of
   * the current thread to the one set in the HiveConf of this given `state`.
   */
  def setCurrentSessionState(state: SessionState): Unit

  /**
   * This shim is necessary because the return type is different on different versions of Hive.
   * All parameters are the same, though.
   */
  def getDataLocation(table: Table): Option[String]

  def setDataLocation(table: Table, loc: String): Unit

  def getAllPartitions(hive: Hive, table: Table): Seq[Partition]

  def getPartitionsByFilter(hive: Hive, table: Table, predicates: Seq[Expression]): Seq[Partition]

  def getCommandProcessor(token: String, conf: HiveConf): CommandProcessor

  def getDriverResults(driver: Driver): Seq[String]

  def getMetastoreClientConnectRetryDelayMillis(conf: HiveConf): Long

  def alterTable(hive: Hive, tableName: String, table: Table): Unit

  def alterPartitions(hive: Hive, tableName: String, newParts: JList[Partition]): Unit

  def createPartitions(
      hive: Hive,
      db: String,
      table: String,
      parts: Seq[CatalogTablePartition],
      ignoreIfExists: Boolean): Unit

  def loadPartition(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSkewedStoreAsSubdir: Boolean,
      isSrcLocal: Boolean): Unit

  def loadTable(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit

  def loadDynamicPartitions(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      numDP: Int,
      listBucketingEnabled: Boolean): Unit

  def createFunction(hive: Hive, db: String, func: CatalogFunction): Unit

  def dropFunction(hive: Hive, db: String, name: String): Unit

  def renameFunction(hive: Hive, db: String, oldName: String, newName: String): Unit

  def alterFunction(hive: Hive, db: String, func: CatalogFunction): Unit

  def getFunctionOption(hive: Hive, db: String, name: String): Option[CatalogFunction]

  def listFunctions(hive: Hive, db: String, pattern: String): Seq[String]

  def dropIndex(hive: Hive, dbName: String, tableName: String, indexName: String): Unit

  def dropTable(
      hive: Hive,
      dbName: String,
      tableName: String,
      deleteData: Boolean,
      ignoreIfNotExists: Boolean,
      purge: Boolean): Unit

  def dropPartition(
      hive: Hive,
      dbName: String,
      tableName: String,
      part: JList[String],
      deleteData: Boolean,
      purge: Boolean): Unit

  protected def findStaticMethod(klass: Class[_], name: String, args: Class[_]*): Method = {
    val method = findMethod(klass, name, args: _*)
    require(Modifier.isStatic(method.getModifiers()),
      s"Method $name of class $klass is not static.")
    method
  }

  protected def findMethod(klass: Class[_], name: String, args: Class[_]*): Method = {
    klass.getMethod(name, args: _*)
  }
}

private[client] class Shim_v0_12 extends Shim with Logging {
  // See HIVE-12224, HOLD_DDLTIME was broken as soon as it landed
  protected lazy val holdDDLTime = JBoolean.FALSE
  // deletes the underlying data along with metadata
  protected lazy val deleteDataInDropIndex = JBoolean.TRUE

  private lazy val startMethod =
    findStaticMethod(
      classOf[SessionState],
      "start",
      classOf[SessionState])
  private lazy val getDataLocationMethod = findMethod(classOf[Table], "getDataLocation")
  private lazy val setDataLocationMethod =
    findMethod(
      classOf[Table],
      "setDataLocation",
      classOf[URI])
  private lazy val getAllPartitionsMethod =
    findMethod(
      classOf[Hive],
      "getAllPartitionsForPruner",
      classOf[Table])
  private lazy val getCommandProcessorMethod =
    findStaticMethod(
      classOf[CommandProcessorFactory],
      "get",
      classOf[String],
      classOf[HiveConf])
  private lazy val getDriverResultsMethod =
    findMethod(
      classOf[Driver],
      "getResults",
      classOf[JArrayList[String]])
  private lazy val createPartitionMethod =
    findMethod(
      classOf[Hive],
      "createPartition",
      classOf[Table],
      classOf[JMap[String, String]],
      classOf[Path],
      classOf[JMap[String, String]],
      classOf[String],
      classOf[String],
      JInteger.TYPE,
      classOf[JList[Object]],
      classOf[String],
      classOf[JMap[String, String]],
      classOf[JList[Object]],
      classOf[JList[Object]])
  private lazy val loadPartitionMethod =
    findMethod(
      classOf[Hive],
      "loadPartition",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadTableMethod =
    findMethod(
      classOf[Hive],
      "loadTable",
      classOf[Path],
      classOf[String],
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadDynamicPartitionsMethod =
    findMethod(
      classOf[Hive],
      "loadDynamicPartitions",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JInteger.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val dropIndexMethod =
    findMethod(
      classOf[Hive],
      "dropIndex",
      classOf[String],
      classOf[String],
      classOf[String],
      JBoolean.TYPE)
  private lazy val alterTableMethod =
    findMethod(
      classOf[Hive],
      "alterTable",
      classOf[String],
      classOf[Table])
  private lazy val alterPartitionsMethod =
    findMethod(
      classOf[Hive],
      "alterPartitions",
      classOf[String],
      classOf[JList[Partition]])

  override def setCurrentSessionState(state: SessionState): Unit = {
    // Starting from Hive 0.13, setCurrentSessionState will internally override
    // the context class loader of the current thread by the class loader set in
    // the conf of the SessionState. So, for this Hive 0.12 shim, we add the same
    // behavior and make shim.setCurrentSessionState of all Hive versions have the
    // consistent behavior.
    Thread.currentThread().setContextClassLoader(state.getConf.getClassLoader)
    startMethod.invoke(null, state)
  }

  override def getDataLocation(table: Table): Option[String] =
    Option(getDataLocationMethod.invoke(table)).map(_.toString())

  override def setDataLocation(table: Table, loc: String): Unit =
    setDataLocationMethod.invoke(table, new URI(loc))

  // Follows exactly the same logic of DDLTask.createPartitions in Hive 0.12
  override def createPartitions(
      hive: Hive,
      database: String,
      tableName: String,
      parts: Seq[CatalogTablePartition],
      ignoreIfExists: Boolean): Unit = {
    val table = hive.getTable(database, tableName)
    parts.foreach { s =>
      val location = s.storage.locationUri.map(
        uri => new Path(table.getPath, new Path(uri))).orNull
      val params = if (s.parameters.nonEmpty) s.parameters.asJava else null
      val spec = s.spec.asJava
      if (hive.getPartition(table, spec, false) != null && ignoreIfExists) {
        // Ignore this partition since it already exists and ignoreIfExists == true
      } else {
        if (location == null && table.isView()) {
          throw new HiveException("LOCATION clause illegal for view partition");
        }

        createPartitionMethod.invoke(
          hive,
          table,
          spec,
          location,
          params, // partParams
          null, // inputFormat
          null, // outputFormat
          -1: JInteger, // numBuckets
          null, // cols
          null, // serializationLib
          null, // serdeParams
          null, // bucketCols
          null) // sortCols
      }
    }
  }

  override def getAllPartitions(hive: Hive, table: Table): Seq[Partition] =
    getAllPartitionsMethod.invoke(hive, table).asInstanceOf[JSet[Partition]].asScala.toSeq

  override def getPartitionsByFilter(
      hive: Hive,
      table: Table,
      predicates: Seq[Expression]): Seq[Partition] = {
    // getPartitionsByFilter() doesn't support binary comparison ops in Hive 0.12.
    // See HIVE-4888.
    logDebug("Hive 0.12 doesn't support predicate pushdown to metastore. " +
      "Please use Hive 0.13 or higher.")
    getAllPartitions(hive, table)
  }

  override def getCommandProcessor(token: String, conf: HiveConf): CommandProcessor =
    getCommandProcessorMethod.invoke(null, token, conf).asInstanceOf[CommandProcessor]

  override def getDriverResults(driver: Driver): Seq[String] = {
    val res = new JArrayList[String]()
    getDriverResultsMethod.invoke(driver, res)
    res.asScala
  }

  override def getMetastoreClientConnectRetryDelayMillis(conf: HiveConf): Long = {
    conf.getIntVar(HiveConf.ConfVars.METASTORE_CLIENT_CONNECT_RETRY_DELAY) * 1000L
  }

  override def loadPartition(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSkewedStoreAsSubdir: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadPartitionMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      JBoolean.FALSE, inheritTableSpecs: JBoolean, isSkewedStoreAsSubdir: JBoolean)
  }

  override def loadTable(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadTableMethod.invoke(hive, loadPath, tableName, replace: JBoolean, holdDDLTime)
  }

  override def loadDynamicPartitions(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      numDP: Int,
      listBucketingEnabled: Boolean): Unit = {
    loadDynamicPartitionsMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      numDP: JInteger, holdDDLTime, listBucketingEnabled: JBoolean)
  }

  override def dropIndex(hive: Hive, dbName: String, tableName: String, indexName: String): Unit = {
    dropIndexMethod.invoke(hive, dbName, tableName, indexName, deleteDataInDropIndex)
  }

  override def dropTable(
      hive: Hive,
      dbName: String,
      tableName: String,
      deleteData: Boolean,
      ignoreIfNotExists: Boolean,
      purge: Boolean): Unit = {
    if (purge) {
      throw new UnsupportedOperationException("DROP TABLE ... PURGE")
    }
    hive.dropTable(dbName, tableName, deleteData, ignoreIfNotExists)
  }

  override def alterTable(hive: Hive, tableName: String, table: Table): Unit = {
    alterTableMethod.invoke(hive, tableName, table)
  }

  override def alterPartitions(hive: Hive, tableName: String, newParts: JList[Partition]): Unit = {
    alterPartitionsMethod.invoke(hive, tableName, newParts)
  }

  override def dropPartition(
      hive: Hive,
      dbName: String,
      tableName: String,
      part: JList[String],
      deleteData: Boolean,
      purge: Boolean): Unit = {
    if (purge) {
      throw new UnsupportedOperationException("ALTER TABLE ... DROP PARTITION ... PURGE")
    }
    hive.dropPartition(dbName, tableName, part, deleteData)
  }

  override def createFunction(hive: Hive, db: String, func: CatalogFunction): Unit = {
    throw new AnalysisException("Hive 0.12 doesn't support creating permanent functions. " +
      "Please use Hive 0.13 or higher.")
  }

  def dropFunction(hive: Hive, db: String, name: String): Unit = {
    throw new NoSuchPermanentFunctionException(db, name)
  }

  def renameFunction(hive: Hive, db: String, oldName: String, newName: String): Unit = {
    throw new NoSuchPermanentFunctionException(db, oldName)
  }

  def alterFunction(hive: Hive, db: String, func: CatalogFunction): Unit = {
    throw new NoSuchPermanentFunctionException(db, func.identifier.funcName)
  }

  def getFunctionOption(hive: Hive, db: String, name: String): Option[CatalogFunction] = {
    None
  }

  def listFunctions(hive: Hive, db: String, pattern: String): Seq[String] = {
    Seq.empty[String]
  }
}

private[client] class Shim_v0_13 extends Shim_v0_12 {

  private lazy val setCurrentSessionStateMethod =
    findStaticMethod(
      classOf[SessionState],
      "setCurrentSessionState",
      classOf[SessionState])
  private lazy val setDataLocationMethod =
    findMethod(
      classOf[Table],
      "setDataLocation",
      classOf[Path])
  private lazy val getAllPartitionsMethod =
    findMethod(
      classOf[Hive],
      "getAllPartitionsOf",
      classOf[Table])
  private lazy val getPartitionsByFilterMethod =
    findMethod(
      classOf[Hive],
      "getPartitionsByFilter",
      classOf[Table],
      classOf[String])
  private lazy val getCommandProcessorMethod =
    findStaticMethod(
      classOf[CommandProcessorFactory],
      "get",
      classOf[Array[String]],
      classOf[HiveConf])
  private lazy val getDriverResultsMethod =
    findMethod(
      classOf[Driver],
      "getResults",
      classOf[JList[Object]])

  override def setCurrentSessionState(state: SessionState): Unit =
    setCurrentSessionStateMethod.invoke(null, state)

  override def setDataLocation(table: Table, loc: String): Unit =
    setDataLocationMethod.invoke(table, new Path(loc))

  override def createPartitions(
      hive: Hive,
      db: String,
      table: String,
      parts: Seq[CatalogTablePartition],
      ignoreIfExists: Boolean): Unit = {
    val addPartitionDesc = new AddPartitionDesc(db, table, ignoreIfExists)
    parts.zipWithIndex.foreach { case (s, i) =>
      addPartitionDesc.addPartition(
        s.spec.asJava, s.storage.locationUri.map(CatalogUtils.URIToString(_)).orNull)
      if (s.parameters.nonEmpty) {
        addPartitionDesc.getPartition(i).setPartParams(s.parameters.asJava)
      }
    }
    hive.createPartitions(addPartitionDesc)
  }

  override def getAllPartitions(hive: Hive, table: Table): Seq[Partition] =
    getAllPartitionsMethod.invoke(hive, table).asInstanceOf[JSet[Partition]].asScala.toSeq

  private def toHiveFunction(f: CatalogFunction, db: String): HiveFunction = {
    val resourceUris = f.resources.map { resource =>
      new ResourceUri(ResourceType.valueOf(
        resource.resourceType.resourceType.toUpperCase(Locale.ROOT)), resource.uri)
    }
    new HiveFunction(
      f.identifier.funcName,
      db,
      f.className,
      null,
      PrincipalType.USER,
      (System.currentTimeMillis / 1000).toInt,
      FunctionType.JAVA,
      resourceUris.asJava)
  }

  override def createFunction(hive: Hive, db: String, func: CatalogFunction): Unit = {
    hive.createFunction(toHiveFunction(func, db))
  }

  override def dropFunction(hive: Hive, db: String, name: String): Unit = {
    hive.dropFunction(db, name)
  }

  override def renameFunction(hive: Hive, db: String, oldName: String, newName: String): Unit = {
    val catalogFunc = getFunctionOption(hive, db, oldName)
      .getOrElse(throw new NoSuchPermanentFunctionException(db, oldName))
      .copy(identifier = FunctionIdentifier(newName, Some(db)))
    val hiveFunc = toHiveFunction(catalogFunc, db)
    hive.alterFunction(db, oldName, hiveFunc)
  }

  override def alterFunction(hive: Hive, db: String, func: CatalogFunction): Unit = {
    hive.alterFunction(db, func.identifier.funcName, toHiveFunction(func, db))
  }

  private def fromHiveFunction(hf: HiveFunction): CatalogFunction = {
    val name = FunctionIdentifier(hf.getFunctionName, Option(hf.getDbName))
    val resources = hf.getResourceUris.asScala.map { uri =>
      val resourceType = uri.getResourceType() match {
        case ResourceType.ARCHIVE => "archive"
        case ResourceType.FILE => "file"
        case ResourceType.JAR => "jar"
        case r => throw new AnalysisException(s"Unknown resource type: $r")
      }
      FunctionResource(FunctionResourceType.fromString(resourceType), uri.getUri())
    }
    CatalogFunction(name, hf.getClassName, resources)
  }

  override def getFunctionOption(hive: Hive, db: String, name: String): Option[CatalogFunction] = {
    try {
      Option(hive.getFunction(db, name)).map(fromHiveFunction)
    } catch {
      case NonFatal(e) if isCausedBy(e, s"$name does not exist") =>
        None
    }
  }

  private def isCausedBy(e: Throwable, matchMassage: String): Boolean = {
    if (e.getMessage.contains(matchMassage)) {
      true
    } else if (e.getCause != null) {
      isCausedBy(e.getCause, matchMassage)
    } else {
      false
    }
  }

  override def listFunctions(hive: Hive, db: String, pattern: String): Seq[String] = {
    hive.getFunctions(db, pattern).asScala
  }

  /**
   * Converts catalyst expression to the format that Hive's getPartitionsByFilter() expects, i.e.
   * a string that represents partition predicates like "str_key=\"value\" and int_key=1 ...".
   *
   * Unsupported predicates are skipped.
   */
  def convertFilters(table: Table, filters: Seq[Expression]): String = {
    /**
     * An extractor that matches all binary comparison operators except null-safe equality.
     *
     * Null-safe equality is not supported by Hive metastore partition predicate pushdown
     */
    object SpecialBinaryComparison {
      def unapply(e: BinaryComparison): Option[(Expression, Expression)] = e match {
        case _: EqualNullSafe => None
        case _ => Some((e.left, e.right))
      }
    }

    object ExtractableLiteral {
      def unapply(expr: Expression): Option[String] = expr match {
        case Literal(null, _) => None // `null`s can be cast as other types; we want to avoid NPEs.
        case Literal(value, _: IntegralType) => Some(value.toString)
        case Literal(value, _: StringType) => Some(quoteStringLiteral(value.toString))
        case _ => None
      }
    }

    object ExtractableLiterals {
      def unapply(exprs: Seq[Expression]): Option[Seq[String]] = {
        // SPARK-24879: The Hive metastore filter parser does not support "null", but we still want
        // to push down as many predicates as we can while still maintaining correctness.
        // In SQL, the `IN` expression evaluates as follows:
        //  > `1 in (2, NULL)` -> NULL
        //  > `1 in (1, NULL)` -> true
        //  > `1 in (2)` -> false
        // Since Hive metastore filters are NULL-intolerant binary operations joined only by
        // `AND` and `OR`, we can treat `NULL` as `false` and thus rewrite `1 in (2, NULL)` as
        // `1 in (2)`.
        // If the Hive metastore begins supporting NULL-tolerant predicates and Spark starts
        // pushing down these predicates, then this optimization will become incorrect and need
        // to be changed.
        val extractables = exprs
            .filter {
              case Literal(null, _) => false
              case _ => true
            }.map(ExtractableLiteral.unapply)
        if (extractables.nonEmpty && extractables.forall(_.isDefined)) {
          Some(extractables.map(_.get))
        } else {
          None
        }
      }
    }

    object ExtractableValues {
      private lazy val valueToLiteralString: PartialFunction[Any, String] = {
        case value: Byte => value.toString
        case value: Short => value.toString
        case value: Int => value.toString
        case value: Long => value.toString
        case value: UTF8String => quoteStringLiteral(value.toString)
      }

      def unapply(values: Set[Any]): Option[Seq[String]] = {
        val extractables = values.toSeq.map(valueToLiteralString.lift)
        if (extractables.nonEmpty && extractables.forall(_.isDefined)) {
          Some(extractables.map(_.get))
        } else {
          None
        }
      }
    }

    object NonVarcharAttribute {
      // hive varchar is treated as catalyst string, but hive varchar can't be pushed down.
      private val varcharKeys = table.getPartitionKeys.asScala
        .filter(col => col.getType.startsWith(serdeConstants.VARCHAR_TYPE_NAME) ||
          col.getType.startsWith(serdeConstants.CHAR_TYPE_NAME))
        .map(col => col.getName).toSet

      def unapply(attr: Attribute): Option[String] = {
        if (varcharKeys.contains(attr.name)) {
          None
        } else {
          Some(attr.name)
        }
      }
    }

    def convertInToOr(name: String, values: Seq[String]): String = {
      values.map(value => s"$name = $value").mkString("(", " or ", ")")
    }

    val useAdvanced = SQLConf.get.advancedPartitionPredicatePushdownEnabled

    object ExtractAttribute {
      def unapply(expr: Expression): Option[Attribute] = {
        expr match {
          case attr: Attribute => Some(attr)
          case Cast(child @ AtomicType(), dt: AtomicType, _)
              if Cast.canSafeCast(child.dataType.asInstanceOf[AtomicType], dt) => unapply(child)
          case _ => None
        }
      }
    }

    def convert(expr: Expression): Option[String] = expr match {
      case In(ExtractAttribute(NonVarcharAttribute(name)), ExtractableLiterals(values))
          if useAdvanced =>
        Some(convertInToOr(name, values))

      case InSet(ExtractAttribute(NonVarcharAttribute(name)), ExtractableValues(values))
          if useAdvanced =>
        Some(convertInToOr(name, values))

      case op @ SpecialBinaryComparison(
          ExtractAttribute(NonVarcharAttribute(name)), ExtractableLiteral(value)) =>
        Some(s"$name ${op.symbol} $value")

      case op @ SpecialBinaryComparison(
          ExtractableLiteral(value), ExtractAttribute(NonVarcharAttribute(name))) =>
        Some(s"$value ${op.symbol} $name")

      case And(expr1, expr2) if useAdvanced =>
        val converted = convert(expr1) ++ convert(expr2)
        if (converted.isEmpty) {
          None
        } else {
          Some(converted.mkString("(", " and ", ")"))
        }

      case Or(expr1, expr2) if useAdvanced =>
        for {
          left <- convert(expr1)
          right <- convert(expr2)
        } yield s"($left or $right)"

      case _ => None
    }

    filters.flatMap(convert).mkString(" and ")
  }

  private def quoteStringLiteral(str: String): String = {
    if (!str.contains("\"")) {
      s""""$str""""
    } else if (!str.contains("'")) {
      s"""'$str'"""
    } else {
      throw new UnsupportedOperationException(
        """Partition filter cannot have both `"` and `'` characters""")
    }
  }

  override def getPartitionsByFilter(
      hive: Hive,
      table: Table,
      predicates: Seq[Expression]): Seq[Partition] = {

    // Hive getPartitionsByFilter() takes a string that represents partition
    // predicates like "str_key=\"value\" and int_key=1 ..."
    val filter = convertFilters(table, predicates)

    val partitions =
      if (filter.isEmpty) {
        getAllPartitionsMethod.invoke(hive, table).asInstanceOf[JSet[Partition]]
      } else {
        logDebug(s"Hive metastore filter is '$filter'.")
        val tryDirectSqlConfVar = HiveConf.ConfVars.METASTORE_TRY_DIRECT_SQL
        // We should get this config value from the metaStore. otherwise hit SPARK-18681.
        // To be compatible with hive-0.12 and hive-0.13, In the future we can achieve this by:
        // val tryDirectSql = hive.getMetaConf(tryDirectSqlConfVar.varname).toBoolean
        val tryDirectSql = hive.getMSC.getConfigValue(tryDirectSqlConfVar.varname,
          tryDirectSqlConfVar.defaultBoolVal.toString).toBoolean
        try {
          // Hive may throw an exception when calling this method in some circumstances, such as
          // when filtering on a non-string partition column when the hive config key
          // hive.metastore.try.direct.sql is false
          getPartitionsByFilterMethod.invoke(hive, table, filter)
            .asInstanceOf[JArrayList[Partition]]
        } catch {
          case ex: InvocationTargetException if ex.getCause.isInstanceOf[MetaException] &&
              !tryDirectSql =>
            logWarning("Caught Hive MetaException attempting to get partition metadata by " +
              "filter from Hive. Falling back to fetching all partition metadata, which will " +
              "degrade performance. Modifying your Hive metastore configuration to set " +
              s"${tryDirectSqlConfVar.varname} to true may resolve this problem.", ex)
            // HiveShim clients are expected to handle a superset of the requested partitions
            getAllPartitionsMethod.invoke(hive, table).asInstanceOf[JSet[Partition]]
          case ex: InvocationTargetException if ex.getCause.isInstanceOf[MetaException] &&
              tryDirectSql =>
            throw new RuntimeException("Caught Hive MetaException attempting to get partition " +
              "metadata by filter from Hive. You can set the Spark configuration setting " +
              s"${SQLConf.HIVE_MANAGE_FILESOURCE_PARTITIONS.key} to false to work around this " +
              "problem, however this will result in degraded performance. Please report a bug: " +
              "https://issues.apache.org/jira/browse/SPARK", ex)
        }
      }

    partitions.asScala.toSeq
  }

  override def getCommandProcessor(token: String, conf: HiveConf): CommandProcessor =
    getCommandProcessorMethod.invoke(null, Array(token), conf).asInstanceOf[CommandProcessor]

  override def getDriverResults(driver: Driver): Seq[String] = {
    val res = new JArrayList[Object]()
    getDriverResultsMethod.invoke(driver, res)
    res.asScala.map { r =>
      r match {
        case s: String => s
        case a: Array[Object] => a(0).asInstanceOf[String]
      }
    }
  }

}

private[client] class Shim_v0_14 extends Shim_v0_13 {

  // true if this is an ACID operation
  protected lazy val isAcid = JBoolean.FALSE
  // true if list bucketing enabled
  protected lazy val isSkewedStoreAsSubdir = JBoolean.FALSE

  private lazy val loadPartitionMethod =
    findMethod(
      classOf[Hive],
      "loadPartition",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadTableMethod =
    findMethod(
      classOf[Hive],
      "loadTable",
      classOf[Path],
      classOf[String],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadDynamicPartitionsMethod =
    findMethod(
      classOf[Hive],
      "loadDynamicPartitions",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JInteger.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val dropTableMethod =
    findMethod(
      classOf[Hive],
      "dropTable",
      classOf[String],
      classOf[String],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val getTimeVarMethod =
    findMethod(
      classOf[HiveConf],
      "getTimeVar",
      classOf[HiveConf.ConfVars],
      classOf[TimeUnit])

  override def loadPartition(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSkewedStoreAsSubdir: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadPartitionMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      holdDDLTime, inheritTableSpecs: JBoolean, isSkewedStoreAsSubdir: JBoolean,
      isSrcLocal: JBoolean, isAcid)
  }

  override def loadTable(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadTableMethod.invoke(hive, loadPath, tableName, replace: JBoolean, holdDDLTime,
      isSrcLocal: JBoolean, isSkewedStoreAsSubdir, isAcid)
  }

  override def loadDynamicPartitions(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      numDP: Int,
      listBucketingEnabled: Boolean): Unit = {
    loadDynamicPartitionsMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      numDP: JInteger, holdDDLTime, listBucketingEnabled: JBoolean, isAcid)
  }

  override def dropTable(
      hive: Hive,
      dbName: String,
      tableName: String,
      deleteData: Boolean,
      ignoreIfNotExists: Boolean,
      purge: Boolean): Unit = {
    dropTableMethod.invoke(hive, dbName, tableName, deleteData: JBoolean,
      ignoreIfNotExists: JBoolean, purge: JBoolean)
  }

  override def getMetastoreClientConnectRetryDelayMillis(conf: HiveConf): Long = {
    getTimeVarMethod.invoke(
      conf,
      HiveConf.ConfVars.METASTORE_CLIENT_CONNECT_RETRY_DELAY,
      TimeUnit.MILLISECONDS).asInstanceOf[Long]
  }

}

private[client] class Shim_v1_0 extends Shim_v0_14

private[client] class Shim_v1_1 extends Shim_v1_0 {

  // throws an exception if the index does not exist
  protected lazy val throwExceptionInDropIndex = JBoolean.TRUE

  private lazy val dropIndexMethod =
    findMethod(
      classOf[Hive],
      "dropIndex",
      classOf[String],
      classOf[String],
      classOf[String],
      JBoolean.TYPE,
      JBoolean.TYPE)

  override def dropIndex(hive: Hive, dbName: String, tableName: String, indexName: String): Unit = {
    dropIndexMethod.invoke(hive, dbName, tableName, indexName, throwExceptionInDropIndex,
      deleteDataInDropIndex)
  }

}

private[client] class Shim_v1_2 extends Shim_v1_1 {

  // txnId can be 0 unless isAcid == true
  protected lazy val txnIdInLoadDynamicPartitions: JLong = 0L

  private lazy val loadDynamicPartitionsMethod =
    findMethod(
      classOf[Hive],
      "loadDynamicPartitions",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JInteger.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JLong.TYPE)

  private lazy val dropOptionsClass =
      Utils.classForName("org.apache.hadoop.hive.metastore.PartitionDropOptions")
  private lazy val dropOptionsDeleteData = dropOptionsClass.getField("deleteData")
  private lazy val dropOptionsPurge = dropOptionsClass.getField("purgeData")
  private lazy val dropPartitionMethod =
    findMethod(
      classOf[Hive],
      "dropPartition",
      classOf[String],
      classOf[String],
      classOf[JList[String]],
      dropOptionsClass)

  override def loadDynamicPartitions(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      numDP: Int,
      listBucketingEnabled: Boolean): Unit = {
    loadDynamicPartitionsMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      numDP: JInteger, holdDDLTime, listBucketingEnabled: JBoolean, isAcid,
      txnIdInLoadDynamicPartitions)
  }

  override def dropPartition(
      hive: Hive,
      dbName: String,
      tableName: String,
      part: JList[String],
      deleteData: Boolean,
      purge: Boolean): Unit = {
    val dropOptions = dropOptionsClass.newInstance().asInstanceOf[Object]
    dropOptionsDeleteData.setBoolean(dropOptions, deleteData)
    dropOptionsPurge.setBoolean(dropOptions, purge)
    dropPartitionMethod.invoke(hive, dbName, tableName, part, dropOptions)
  }

}

private[client] class Shim_v2_0 extends Shim_v1_2 {
  private lazy val loadPartitionMethod =
    findMethod(
      classOf[Hive],
      "loadPartition",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadTableMethod =
    findMethod(
      classOf[Hive],
      "loadTable",
      classOf[Path],
      classOf[String],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadDynamicPartitionsMethod =
    findMethod(
      classOf[Hive],
      "loadDynamicPartitions",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JInteger.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JLong.TYPE)

  override def loadPartition(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSkewedStoreAsSubdir: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadPartitionMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      inheritTableSpecs: JBoolean, isSkewedStoreAsSubdir: JBoolean,
      isSrcLocal: JBoolean, isAcid)
  }

  override def loadTable(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadTableMethod.invoke(hive, loadPath, tableName, replace: JBoolean, isSrcLocal: JBoolean,
      isSkewedStoreAsSubdir, isAcid)
  }

  override def loadDynamicPartitions(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      numDP: Int,
      listBucketingEnabled: Boolean): Unit = {
    loadDynamicPartitionsMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      numDP: JInteger, listBucketingEnabled: JBoolean, isAcid, txnIdInLoadDynamicPartitions)
  }

}

private[client] class Shim_v2_1 extends Shim_v2_0 {

  // true if there is any following stats task
  protected lazy val hasFollowingStatsTask = JBoolean.FALSE
  // TODO: Now, always set environmentContext to null. In the future, we should avoid setting
  // hive-generated stats to -1 when altering tables by using environmentContext. See Hive-12730
  protected lazy val environmentContextInAlterTable = null

  private lazy val loadPartitionMethod =
    findMethod(
      classOf[Hive],
      "loadPartition",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadTableMethod =
    findMethod(
      classOf[Hive],
      "loadTable",
      classOf[Path],
      classOf[String],
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE)
  private lazy val loadDynamicPartitionsMethod =
    findMethod(
      classOf[Hive],
      "loadDynamicPartitions",
      classOf[Path],
      classOf[String],
      classOf[JMap[String, String]],
      JBoolean.TYPE,
      JInteger.TYPE,
      JBoolean.TYPE,
      JBoolean.TYPE,
      JLong.TYPE,
      JBoolean.TYPE,
      classOf[AcidUtils.Operation])
  private lazy val alterTableMethod =
    findMethod(
      classOf[Hive],
      "alterTable",
      classOf[String],
      classOf[Table],
      classOf[EnvironmentContext])
  private lazy val alterPartitionsMethod =
    findMethod(
      classOf[Hive],
      "alterPartitions",
      classOf[String],
      classOf[JList[Partition]],
      classOf[EnvironmentContext])

  override def loadPartition(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      inheritTableSpecs: Boolean,
      isSkewedStoreAsSubdir: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadPartitionMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      inheritTableSpecs: JBoolean, isSkewedStoreAsSubdir: JBoolean,
      isSrcLocal: JBoolean, isAcid, hasFollowingStatsTask)
  }

  override def loadTable(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      replace: Boolean,
      isSrcLocal: Boolean): Unit = {
    loadTableMethod.invoke(hive, loadPath, tableName, replace: JBoolean, isSrcLocal: JBoolean,
      isSkewedStoreAsSubdir, isAcid, hasFollowingStatsTask)
  }

  override def loadDynamicPartitions(
      hive: Hive,
      loadPath: Path,
      tableName: String,
      partSpec: JMap[String, String],
      replace: Boolean,
      numDP: Int,
      listBucketingEnabled: Boolean): Unit = {
    loadDynamicPartitionsMethod.invoke(hive, loadPath, tableName, partSpec, replace: JBoolean,
      numDP: JInteger, listBucketingEnabled: JBoolean, isAcid, txnIdInLoadDynamicPartitions,
      hasFollowingStatsTask, AcidUtils.Operation.NOT_ACID)
  }

  override def alterTable(hive: Hive, tableName: String, table: Table): Unit = {
    alterTableMethod.invoke(hive, tableName, table, environmentContextInAlterTable)
  }

  override def alterPartitions(hive: Hive, tableName: String, newParts: JList[Partition]): Unit = {
    alterPartitionsMethod.invoke(hive, tableName, newParts, environmentContextInAlterTable)
  }
}

private[client] class Shim_v2_2 extends Shim_v2_1

private[client] class Shim_v2_3 extends Shim_v2_1
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

package org.apache.spark.sql.hive

import java.io.IOException
import java.util.Locale

import org.apache.hadoop.fs.{FileSystem, Path}

import org.apache.spark.sql._
import org.apache.spark.sql.catalyst.catalog._
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.planning._
import org.apache.spark.sql.catalyst.plans.logical.{InsertIntoDir, InsertIntoTable, LogicalPlan,
    ScriptTransformation}
import org.apache.spark.sql.catalyst.rules.Rule
import org.apache.spark.sql.execution._
import org.apache.spark.sql.execution.command.{CreateTableCommand, DDLUtils}
import org.apache.spark.sql.execution.datasources.{CreateTable, LogicalRelation}
import org.apache.spark.sql.execution.datasources.parquet.{ParquetFileFormat, ParquetOptions}
import org.apache.spark.sql.hive.execution._
import org.apache.spark.sql.internal.{HiveSerDe, SQLConf}


/**
 * Determine the database, serde/format and schema of the Hive serde table, according to the storage
 * properties.
 */
class ResolveHiveSerdeTable(session: SparkSession) extends Rule[LogicalPlan] {
  private def determineHiveSerde(table: CatalogTable): CatalogTable = {
    if (table.storage.serde.nonEmpty) {
      table
    } else {
      if (table.bucketSpec.isDefined) {
        throw new AnalysisException("Creating bucketed Hive serde table is not supported yet.")
      }

      val defaultStorage = HiveSerDe.getDefaultStorage(session.sessionState.conf)
      val options = new HiveOptions(table.storage.properties)

      val fileStorage = if (options.fileFormat.isDefined) {
        HiveSerDe.sourceToSerDe(options.fileFormat.get) match {
          case Some(s) =>
            CatalogStorageFormat.empty.copy(
              inputFormat = s.inputFormat,
              outputFormat = s.outputFormat,
              serde = s.serde)
          case None =>
            throw new IllegalArgumentException(s"invalid fileFormat: '${options.fileFormat.get}'")
        }
      } else if (options.hasInputOutputFormat) {
        CatalogStorageFormat.empty.copy(
          inputFormat = options.inputFormat,
          outputFormat = options.outputFormat)
      } else {
        CatalogStorageFormat.empty
      }

      val rowStorage = if (options.serde.isDefined) {
        CatalogStorageFormat.empty.copy(serde = options.serde)
      } else {
        CatalogStorageFormat.empty
      }

      val storage = table.storage.copy(
        inputFormat = fileStorage.inputFormat.orElse(defaultStorage.inputFormat),
        outputFormat = fileStorage.outputFormat.orElse(defaultStorage.outputFormat),
        serde = rowStorage.serde.orElse(fileStorage.serde).orElse(defaultStorage.serde),
        properties = options.serdeProperties)

      table.copy(storage = storage)
    }
  }

  override def apply(plan: LogicalPlan): LogicalPlan = plan resolveOperators {
    case c @ CreateTable(t, _, query) if DDLUtils.isHiveTable(t) =>
      // Finds the database name if the name does not exist.
      val dbName = t.identifier.database.getOrElse(session.catalog.currentDatabase)
      val table = t.copy(identifier = t.identifier.copy(database = Some(dbName)))

      // Determines the serde/format of Hive tables
      val withStorage = determineHiveSerde(table)

      // Infers the schema, if empty, because the schema could be determined by Hive
      // serde.
      val withSchema = if (query.isEmpty) {
        val inferred = HiveUtils.inferSchema(withStorage)
        if (inferred.schema.length <= 0) {
          throw new AnalysisException("Unable to infer the schema. " +
            s"The schema specification is required to create the table ${inferred.identifier}.")
        }
        inferred
      } else {
        withStorage
      }

      c.copy(tableDesc = withSchema)
  }
}

class DetermineTableStats(session: SparkSession) extends Rule[LogicalPlan] {
  override def apply(plan: LogicalPlan): LogicalPlan = plan resolveOperators {
    case relation: HiveTableRelation
        if DDLUtils.isHiveTable(relation.tableMeta) && relation.tableMeta.stats.isEmpty =>
      val table = relation.tableMeta
      val sizeInBytes = if (session.sessionState.conf.fallBackToHdfsForStatsEnabled) {
        try {
          val hadoopConf = session.sessionState.newHadoopConf()
          val tablePath = new Path(table.location)
          val fs: FileSystem = tablePath.getFileSystem(hadoopConf)
          fs.getContentSummary(tablePath).getLength
        } catch {
          case e: IOException =>
            logWarning("Failed to get table size from hdfs.", e)
            session.sessionState.conf.defaultSizeInBytes
        }
      } else {
        session.sessionState.conf.defaultSizeInBytes
      }

      val withStats = table.copy(stats = Some(CatalogStatistics(sizeInBytes = BigInt(sizeInBytes))))
      relation.copy(tableMeta = withStats)
  }
}

/**
 * Replaces generic operations with specific variants that are designed to work with Hive.
 *
 * Note that, this rule must be run after `PreprocessTableCreation` and
 * `PreprocessTableInsertion`.
 */
object HiveAnalysis extends Rule[LogicalPlan] {
  override def apply(plan: LogicalPlan): LogicalPlan = plan resolveOperators {
    case InsertIntoTable(r: HiveTableRelation, partSpec, query, overwrite, ifPartitionNotExists)
        if DDLUtils.isHiveTable(r.tableMeta) =>
      InsertIntoHiveTable(r.tableMeta, partSpec, query, overwrite,
        ifPartitionNotExists, query.output.map(_.name))

    case CreateTable(tableDesc, mode, None) if DDLUtils.isHiveTable(tableDesc) =>
      DDLUtils.checkDataColNames(tableDesc)
      CreateTableCommand(tableDesc, ignoreIfExists = mode == SaveMode.Ignore)

    case CreateTable(tableDesc, mode, Some(query)) if DDLUtils.isHiveTable(tableDesc) =>
      DDLUtils.checkDataColNames(tableDesc)
      CreateHiveTableAsSelectCommand(tableDesc, query, query.output.map(_.name), mode)

    case InsertIntoDir(isLocal, storage, provider, child, overwrite)
        if DDLUtils.isHiveTable(provider) =>
      val outputPath = new Path(storage.locationUri.get)
      if (overwrite) DDLUtils.verifyNotReadPath(child, outputPath)

      InsertIntoHiveDirCommand(isLocal, storage, child, overwrite, child.output.map(_.name))
  }
}

/**
 * Relation conversion from metastore relations to data source relations for better performance
 *
 * - When writing to non-partitioned Hive-serde Parquet/Orc tables
 * - When scanning Hive-serde Parquet/ORC tables
 *
 * This rule must be run before all other DDL post-hoc resolution rules, i.e.
 * `PreprocessTableCreation`, `PreprocessTableInsertion`, `DataSourceAnalysis` and `HiveAnalysis`.
 */
case class RelationConversions(
    conf: SQLConf,
    sessionCatalog: HiveSessionCatalog) extends Rule[LogicalPlan] {
  private def isConvertible(relation: HiveTableRelation): Boolean = {
    val serde = relation.tableMeta.storage.serde.getOrElse("").toLowerCase(Locale.ROOT)
    serde.contains("parquet") && conf.getConf(HiveUtils.CONVERT_METASTORE_PARQUET) ||
      serde.contains("orc") && conf.getConf(HiveUtils.CONVERT_METASTORE_ORC)
  }

  // Return true for Apache ORC and Hive ORC-related configuration names.
  // Note that Spark doesn't support configurations like `hive.merge.orcfile.stripe.level`.
  private def isOrcProperty(key: String) =
    key.startsWith("orc.") || key.contains(".orc.")

  private def isParquetProperty(key: String) =
    key.startsWith("parquet.") || key.contains(".parquet.")

  private def convert(relation: HiveTableRelation): LogicalRelation = {
    val serde = relation.tableMeta.storage.serde.getOrElse("").toLowerCase(Locale.ROOT)

    // Consider table and storage properties. For properties existing in both sides, storage
    // properties will supersede table properties.
    if (serde.contains("parquet")) {
      val options = relation.tableMeta.properties.filterKeys(isParquetProperty) ++
        relation.tableMeta.storage.properties + (ParquetOptions.MERGE_SCHEMA ->
        conf.getConf(HiveUtils.CONVERT_METASTORE_PARQUET_WITH_SCHEMA_MERGING).toString)
      sessionCatalog.metastoreCatalog
        .convertToLogicalRelation(relation, options, classOf[ParquetFileFormat], "parquet")
    } else {
      val options = relation.tableMeta.properties.filterKeys(isOrcProperty) ++
        relation.tableMeta.storage.properties
      if (conf.getConf(SQLConf.ORC_IMPLEMENTATION) == "native") {
        sessionCatalog.metastoreCatalog.convertToLogicalRelation(
          relation,
          options,
          classOf[org.apache.spark.sql.execution.datasources.orc.OrcFileFormat],
          "orc")
      } else {
        sessionCatalog.metastoreCatalog.convertToLogicalRelation(
          relation,
          options,
          classOf[org.apache.spark.sql.hive.orc.OrcFileFormat],
          "orc")
      }
    }
  }

  override def apply(plan: LogicalPlan): LogicalPlan = {
    plan resolveOperators {
      // Write path
      case InsertIntoTable(r: HiveTableRelation, partition, query, overwrite, ifPartitionNotExists)
        // Inserting into partitioned table is not supported in Parquet/Orc data source (yet).
          if query.resolved && DDLUtils.isHiveTable(r.tableMeta) &&
            !r.isPartitioned && isConvertible(r) =>
        InsertIntoTable(convert(r), partition, query, overwrite, ifPartitionNotExists)

      // Read path
      case relation: HiveTableRelation
          if DDLUtils.isHiveTable(relation.tableMeta) && isConvertible(relation) =>
        convert(relation)
    }
  }
}

private[hive] trait HiveStrategies {
  // Possibly being too clever with types here... or not clever enough.
  self: SparkPlanner =>

  val sparkSession: SparkSession

  object Scripts extends Strategy {
    def apply(plan: LogicalPlan): Seq[SparkPlan] = plan match {
      case ScriptTransformation(input, script, output, child, ioschema) =>
        val hiveIoSchema = HiveScriptIOSchema(ioschema)
        ScriptTransformationExec(input, script, output, planLater(child), hiveIoSchema) :: Nil
      case _ => Nil
    }
  }

  /**
   * Retrieves data using a HiveTableScan.  Partition pruning predicates are also detected and
   * applied.
   */
  object HiveTableScans extends Strategy {
    def apply(plan: LogicalPlan): Seq[SparkPlan] = plan match {
      case PhysicalOperation(projectList, predicates, relation: HiveTableRelation) =>
        // Filter out all predicates that only deal with partition keys, these are given to the
        // hive table scan operator to be used for partition pruning.
        val partitionKeyIds = AttributeSet(relation.partitionCols)
        val (pruningPredicates, otherPredicates) = predicates.partition { predicate =>
          !predicate.references.isEmpty &&
          predicate.references.subsetOf(partitionKeyIds)
        }

        pruneFilterProject(
          projectList,
          otherPredicates,
          identity[Seq[Expression]],
          HiveTableScanExec(_, relation, pruningPredicates)(sparkSession)) :: Nil
      case _ =>
        Nil
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

package org.apache.spark.sql.hive.execution

import scala.collection.JavaConverters._

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hive.ql.metadata.{Partition => HivePartition}
import org.apache.hadoop.hive.ql.plan.TableDesc
import org.apache.hadoop.hive.serde.serdeConstants
import org.apache.hadoop.hive.serde2.objectinspector._
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorUtils.ObjectInspectorCopyOption
import org.apache.hadoop.hive.serde2.typeinfo.TypeInfoUtils

import org.apache.spark.rdd.RDD
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.catalyst.analysis.CastSupport
import org.apache.spark.sql.catalyst.catalog.HiveTableRelation
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.plans.QueryPlan
import org.apache.spark.sql.execution._
import org.apache.spark.sql.execution.metric.SQLMetrics
import org.apache.spark.sql.hive._
import org.apache.spark.sql.hive.client.HiveClientImpl
import org.apache.spark.sql.internal.SQLConf
import org.apache.spark.sql.types.{BooleanType, DataType}
import org.apache.spark.util.Utils

/**
 * The Hive table scan operator.  Column and partition pruning are both handled.
 *
 * @param requestedAttributes Attributes to be fetched from the Hive table.
 * @param relation The Hive table be scanned.
 * @param partitionPruningPred An optional partition pruning predicate for partitioned table.
 */
private[hive]
case class HiveTableScanExec(
    requestedAttributes: Seq[Attribute],
    relation: HiveTableRelation,
    partitionPruningPred: Seq[Expression])(
    @transient private val sparkSession: SparkSession)
  extends LeafExecNode with CastSupport {

  require(partitionPruningPred.isEmpty || relation.isPartitioned,
    "Partition pruning predicates only supported for partitioned tables.")

  override def conf: SQLConf = sparkSession.sessionState.conf

  override def nodeName: String = s"Scan hive ${relation.tableMeta.qualifiedName}"

  override lazy val metrics = Map(
    "numOutputRows" -> SQLMetrics.createMetric(sparkContext, "number of output rows"))

  override def producedAttributes: AttributeSet = outputSet ++
    AttributeSet(partitionPruningPred.flatMap(_.references))

  private val originalAttributes = AttributeMap(relation.output.map(a => a -> a))

  override val output: Seq[Attribute] = {
    // Retrieve the original attributes based on expression ID so that capitalization matches.
    requestedAttributes.map(originalAttributes)
  }

  // Bind all partition key attribute references in the partition pruning predicate for later
  // evaluation.
  private lazy val boundPruningPred = partitionPruningPred.reduceLeftOption(And).map { pred =>
    require(pred.dataType == BooleanType,
      s"Data type of predicate $pred must be ${BooleanType.catalogString} rather than " +
        s"${pred.dataType.catalogString}.")

    BindReferences.bindReference(pred, relation.partitionCols)
  }

  @transient private lazy val hiveQlTable = HiveClientImpl.toHiveTable(relation.tableMeta)
  @transient private lazy val tableDesc = new TableDesc(
    hiveQlTable.getInputFormatClass,
    hiveQlTable.getOutputFormatClass,
    hiveQlTable.getMetadata)

  // Create a local copy of hadoopConf,so that scan specific modifications should not impact
  // other queries
  @transient private lazy val hadoopConf = {
    val c = sparkSession.sessionState.newHadoopConf()
    // append columns ids and names before broadcast
    addColumnMetadataToConf(c)
    c
  }

  @transient private lazy val hadoopReader = new HadoopTableReader(
    output,
    relation.partitionCols,
    tableDesc,
    sparkSession,
    hadoopConf)

  private def castFromString(value: String, dataType: DataType) = {
    cast(Literal(value), dataType).eval(null)
  }

  private def addColumnMetadataToConf(hiveConf: Configuration): Unit = {
    // Specifies needed column IDs for those non-partitioning columns.
    val columnOrdinals = AttributeMap(relation.dataCols.zipWithIndex)
    val neededColumnIDs = output.flatMap(columnOrdinals.get).map(o => o: Integer)

    HiveShim.appendReadColumns(hiveConf, neededColumnIDs, output.map(_.name))

    val deserializer = tableDesc.getDeserializerClass.newInstance
    deserializer.initialize(hiveConf, tableDesc.getProperties)

    // Specifies types and object inspectors of columns to be scanned.
    val structOI = ObjectInspectorUtils
      .getStandardObjectInspector(
        deserializer.getObjectInspector,
        ObjectInspectorCopyOption.JAVA)
      .asInstanceOf[StructObjectInspector]

    val columnTypeNames = structOI
      .getAllStructFieldRefs.asScala
      .map(_.getFieldObjectInspector)
      .map(TypeInfoUtils.getTypeInfoFromObjectInspector(_).getTypeName)
      .mkString(",")

    hiveConf.set(serdeConstants.LIST_COLUMN_TYPES, columnTypeNames)
    hiveConf.set(serdeConstants.LIST_COLUMNS, relation.dataCols.map(_.name).mkString(","))
  }

  /**
   * Prunes partitions not involve the query plan.
   *
   * @param partitions All partitions of the relation.
   * @return Partitions that are involved in the query plan.
   */
  private[hive] def prunePartitions(partitions: Seq[HivePartition]) = {
    boundPruningPred match {
      case None => partitions
      case Some(shouldKeep) => partitions.filter { part =>
        val dataTypes = relation.partitionCols.map(_.dataType)
        val castedValues = part.getValues.asScala.zip(dataTypes)
          .map { case (value, dataType) => castFromString(value, dataType) }

        // Only partitioned values are needed here, since the predicate has already been bound to
        // partition key attribute references.
        val row = InternalRow.fromSeq(castedValues)
        shouldKeep.eval(row).asInstanceOf[Boolean]
      }
    }
  }

  // exposed for tests
  @transient lazy val rawPartitions = {
    val prunedPartitions =
      if (sparkSession.sessionState.conf.metastorePartitionPruning &&
          partitionPruningPred.size > 0) {
        // Retrieve the original attributes based on expression ID so that capitalization matches.
        val normalizedFilters = partitionPruningPred.map(_.transform {
          case a: AttributeReference => originalAttributes(a)
        })
        sparkSession.sessionState.catalog.listPartitionsByFilter(
          relation.tableMeta.identifier,
          normalizedFilters)
      } else {
        sparkSession.sessionState.catalog.listPartitions(relation.tableMeta.identifier)
      }
    prunedPartitions.map(HiveClientImpl.toHivePartition(_, hiveQlTable))
  }

  protected override def doExecute(): RDD[InternalRow] = {
    // Using dummyCallSite, as getCallSite can turn out to be expensive with
    // multiple partitions.
    val rdd = if (!relation.isPartitioned) {
      Utils.withDummyCallSite(sqlContext.sparkContext) {
        hadoopReader.makeRDDForTable(hiveQlTable)
      }
    } else {
      Utils.withDummyCallSite(sqlContext.sparkContext) {
        hadoopReader.makeRDDForPartitionedTable(prunePartitions(rawPartitions))
      }
    }
    val numOutputRows = longMetric("numOutputRows")
    // Avoid to serialize MetastoreRelation because schema is lazy. (see SPARK-15649)
    val outputSchema = schema
    rdd.mapPartitionsWithIndexInternal { (index, iter) =>
      val proj = UnsafeProjection.create(outputSchema)
      proj.initialize(index)
      iter.map { r =>
        numOutputRows += 1
        proj(r)
      }
    }
  }

  override def doCanonicalize(): HiveTableScanExec = {
    val input: AttributeSeq = relation.output
    HiveTableScanExec(
      requestedAttributes.map(QueryPlan.normalizeExprId(_, input)),
      relation.canonicalized.asInstanceOf[HiveTableRelation],
      QueryPlan.normalizePredicates(partitionPruningPred, input))(sparkSession)
  }

  override def otherCopyArgs: Seq[AnyRef] = Seq(sparkSession)
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

package org.apache.spark.sql.hive

import java.nio.ByteBuffer

import scala.collection.JavaConverters._
import scala.collection.mutable.ArrayBuffer

import org.apache.hadoop.hive.ql.exec._
import org.apache.hadoop.hive.ql.udf.{UDFType => HiveUDFType}
import org.apache.hadoop.hive.ql.udf.generic._
import org.apache.hadoop.hive.ql.udf.generic.GenericUDAFEvaluator.AggregationBuffer
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF._
import org.apache.hadoop.hive.ql.udf.generic.GenericUDFUtils.ConversionHelper
import org.apache.hadoop.hive.serde2.objectinspector.{ConstantObjectInspector, ObjectInspector, ObjectInspectorFactory}
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory.ObjectInspectorOptions

import org.apache.spark.internal.Logging
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.expressions.aggregate._
import org.apache.spark.sql.catalyst.expressions.codegen.CodegenFallback
import org.apache.spark.sql.hive.HiveShim._
import org.apache.spark.sql.types._


private[hive] case class HiveSimpleUDF(
    name: String, funcWrapper: HiveFunctionWrapper, children: Seq[Expression])
  extends Expression
  with HiveInspectors
  with CodegenFallback
  with Logging
  with UserDefinedExpression {

  override lazy val deterministic: Boolean = isUDFDeterministic && children.forall(_.deterministic)

  override def nullable: Boolean = true

  @transient
  lazy val function = funcWrapper.createFunction[UDF]()

  @transient
  private lazy val method =
    function.getResolver.getEvalMethod(children.map(_.dataType.toTypeInfo).asJava)

  @transient
  private lazy val arguments = children.map(toInspector).toArray

  @transient
  private lazy val isUDFDeterministic = {
    val udfType = function.getClass.getAnnotation(classOf[HiveUDFType])
    udfType != null && udfType.deterministic() && !udfType.stateful()
  }

  override def foldable: Boolean = isUDFDeterministic && children.forall(_.foldable)

  // Create parameter converters
  @transient
  private lazy val conversionHelper = new ConversionHelper(method, arguments)

  override lazy val dataType = javaTypeToDataType(method.getGenericReturnType)

  @transient
  private lazy val wrappers = children.map(x => wrapperFor(toInspector(x), x.dataType)).toArray

  @transient
  lazy val unwrapper = unwrapperFor(ObjectInspectorFactory.getReflectionObjectInspector(
    method.getGenericReturnType, ObjectInspectorOptions.JAVA))

  @transient
  private lazy val cached: Array[AnyRef] = new Array[AnyRef](children.length)

  @transient
  private lazy val inputDataTypes: Array[DataType] = children.map(_.dataType).toArray

  // TODO: Finish input output types.
  override def eval(input: InternalRow): Any = {
    val inputs = wrap(children.map(_.eval(input)), wrappers, cached, inputDataTypes)
    val ret = FunctionRegistry.invoke(
      method,
      function,
      conversionHelper.convertIfNecessary(inputs : _*): _*)
    unwrapper(ret)
  }

  override def toString: String = {
    s"$nodeName#${funcWrapper.functionClassName}(${children.mkString(",")})"
  }

  override def prettyName: String = name

  override def sql: String = s"$name(${children.map(_.sql).mkString(", ")})"
}

// Adapter from Catalyst ExpressionResult to Hive DeferredObject
private[hive] class DeferredObjectAdapter(oi: ObjectInspector, dataType: DataType)
  extends DeferredObject with HiveInspectors {

  private val wrapper = wrapperFor(oi, dataType)
  private var func: () => Any = _
  def set(func: () => Any): Unit = {
    this.func = func
  }
  override def prepare(i: Int): Unit = {}
  override def get(): AnyRef = wrapper(func()).asInstanceOf[AnyRef]
}

private[hive] case class HiveGenericUDF(
    name: String, funcWrapper: HiveFunctionWrapper, children: Seq[Expression])
  extends Expression
  with HiveInspectors
  with CodegenFallback
  with Logging
  with UserDefinedExpression {

  override def nullable: Boolean = true

  override lazy val deterministic: Boolean = isUDFDeterministic && children.forall(_.deterministic)

  override def foldable: Boolean =
    isUDFDeterministic && returnInspector.isInstanceOf[ConstantObjectInspector]

  @transient
  lazy val function = funcWrapper.createFunction[GenericUDF]()

  @transient
  private lazy val argumentInspectors = children.map(toInspector)

  @transient
  private lazy val returnInspector = {
    function.initializeAndFoldConstants(argumentInspectors.toArray)
  }

  @transient
  private lazy val unwrapper = unwrapperFor(returnInspector)

  @transient
  private lazy val isUDFDeterministic = {
    val udfType = function.getClass.getAnnotation(classOf[HiveUDFType])
    udfType != null && udfType.deterministic() && !udfType.stateful()
  }

  @transient
  private lazy val deferredObjects = argumentInspectors.zip(children).map { case (inspect, child) =>
    new DeferredObjectAdapter(inspect, child.dataType)
  }.toArray[DeferredObject]

  override lazy val dataType: DataType = inspectorToDataType(returnInspector)

  override def eval(input: InternalRow): Any = {
    returnInspector // Make sure initialized.

    var i = 0
    val length = children.length
    while (i < length) {
      val idx = i
      deferredObjects(i).asInstanceOf[DeferredObjectAdapter]
        .set(() => children(idx).eval(input))
      i += 1
    }
    unwrapper(function.evaluate(deferredObjects))
  }

  override def prettyName: String = name

  override def toString: String = {
    s"$nodeName#${funcWrapper.functionClassName}(${children.mkString(",")})"
  }
}

/**
 * Converts a Hive Generic User Defined Table Generating Function (UDTF) to a
 * `Generator`. Note that the semantics of Generators do not allow
 * Generators to maintain state in between input rows.  Thus UDTFs that rely on partitioning
 * dependent operations like calls to `close()` before producing output will not operate the same as
 * in Hive.  However, in practice this should not affect compatibility for most sane UDTFs
 * (e.g. explode or GenericUDTFParseUrlTuple).
 *
 * Operators that require maintaining state in between input rows should instead be implemented as
 * user defined aggregations, which have clean semantics even in a partitioned execution.
 */
private[hive] case class HiveGenericUDTF(
    name: String,
    funcWrapper: HiveFunctionWrapper,
    children: Seq[Expression])
  extends Generator with HiveInspectors with CodegenFallback with UserDefinedExpression {

  @transient
  protected lazy val function: GenericUDTF = {
    val fun: GenericUDTF = funcWrapper.createFunction()
    fun.setCollector(collector)
    fun
  }

  @transient
  protected lazy val inputInspectors = children.map(toInspector)

  @transient
  protected lazy val outputInspector = function.initialize(inputInspectors.toArray)

  @transient
  protected lazy val udtInput = new Array[AnyRef](children.length)

  @transient
  protected lazy val collector = new UDTFCollector

  override lazy val elementSchema = StructType(outputInspector.getAllStructFieldRefs.asScala.map {
    field => StructField(field.getFieldName, inspectorToDataType(field.getFieldObjectInspector),
      nullable = true)
  })

  @transient
  private lazy val inputDataTypes: Array[DataType] = children.map(_.dataType).toArray

  @transient
  private lazy val wrappers = children.map(x => wrapperFor(toInspector(x), x.dataType)).toArray

  @transient
  private lazy val unwrapper = unwrapperFor(outputInspector)

  override def eval(input: InternalRow): TraversableOnce[InternalRow] = {
    outputInspector // Make sure initialized.

    val inputProjection = new InterpretedProjection(children)

    function.process(wrap(inputProjection(input), wrappers, udtInput, inputDataTypes))
    collector.collectRows()
  }

  protected class UDTFCollector extends Collector {
    var collected = new ArrayBuffer[InternalRow]

    override def collect(input: java.lang.Object) {
      // We need to clone the input here because implementations of
      // GenericUDTF reuse the same object. Luckily they are always an array, so
      // it is easy to clone.
      collected += unwrapper(input).asInstanceOf[InternalRow]
    }

    def collectRows(): Seq[InternalRow] = {
      val toCollect = collected
      collected = new ArrayBuffer[InternalRow]
      toCollect
    }
  }

  override def terminate(): TraversableOnce[InternalRow] = {
    outputInspector // Make sure initialized.
    function.close()
    collector.collectRows()
  }

  override def toString: String = {
    s"$nodeName#${funcWrapper.functionClassName}(${children.mkString(",")})"
  }

  override def prettyName: String = name
}

/**
 * While being evaluated by Spark SQL, the aggregation state of a Hive UDAF may be in the following
 * three formats:
 *
 *  1. An instance of some concrete `GenericUDAFEvaluator.AggregationBuffer` class
 *
 *     This is the native Hive representation of an aggregation state. Hive `GenericUDAFEvaluator`
 *     methods like `iterate()`, `merge()`, `terminatePartial()`, and `terminate()` use this format.
 *     We call these methods to evaluate Hive UDAFs.
 *
 *  2. A Java object that can be inspected using the `ObjectInspector` returned by the
 *     `GenericUDAFEvaluator.init()` method.
 *
 *     Hive uses this format to produce a serializable aggregation state so that it can shuffle
 *     partial aggregation results. Whenever we need to convert a Hive `AggregationBuffer` instance
 *     into a Spark SQL value, we have to convert it to this format first and then do the conversion
 *     with the help of `ObjectInspector`s.
 *
 *  3. A Spark SQL value
 *
 *     We use this format for serializing Hive UDAF aggregation states on Spark side. To be more
 *     specific, we convert `AggregationBuffer`s into equivalent Spark SQL values, write them into
 *     `UnsafeRow`s, and then retrieve the byte array behind those `UnsafeRow`s as serialization
 *     results.
 *
 * We may use the following methods to convert the aggregation state back and forth:
 *
 *  - `wrap()`/`wrapperFor()`: from 3 to 1
 *  - `unwrap()`/`unwrapperFor()`: from 1 to 3
 *  - `GenericUDAFEvaluator.terminatePartial()`: from 2 to 3
 *
 *  Note that, Hive UDAF is initialized with aggregate mode, and some specific Hive UDAFs can't
 *  mix UPDATE and MERGE actions during its life cycle. However, Spark may do UPDATE on a UDAF and
 *  then do MERGE, in case of hash aggregate falling back to sort aggregate. To work around this
 *  issue, we track the ability to do MERGE in the Hive UDAF aggregate buffer. If Spark does
 *  UPDATE then MERGE, we can detect it and re-create the aggregate buffer with a different
 *  aggregate mode.
 */
private[hive] case class HiveUDAFFunction(
    name: String,
    funcWrapper: HiveFunctionWrapper,
    children: Seq[Expression],
    isUDAFBridgeRequired: Boolean = false,
    mutableAggBufferOffset: Int = 0,
    inputAggBufferOffset: Int = 0)
  extends TypedImperativeAggregate[HiveUDAFBuffer]
  with HiveInspectors
  with UserDefinedExpression {

  override def withNewMutableAggBufferOffset(newMutableAggBufferOffset: Int): ImperativeAggregate =
    copy(mutableAggBufferOffset = newMutableAggBufferOffset)

  override def withNewInputAggBufferOffset(newInputAggBufferOffset: Int): ImperativeAggregate =
    copy(inputAggBufferOffset = newInputAggBufferOffset)

  // Hive `ObjectInspector`s for all child expressions (input parameters of the function).
  @transient
  private lazy val inputInspectors = children.map(toInspector).toArray

  // Spark SQL data types of input parameters.
  @transient
  private lazy val inputDataTypes: Array[DataType] = children.map(_.dataType).toArray

  private def newEvaluator(): GenericUDAFEvaluator = {
    val resolver = if (isUDAFBridgeRequired) {
      new GenericUDAFBridge(funcWrapper.createFunction[UDAF]())
    } else {
      funcWrapper.createFunction[AbstractGenericUDAFResolver]()
    }

    val parameterInfo = new SimpleGenericUDAFParameterInfo(inputInspectors, false, false)
    resolver.getEvaluator(parameterInfo)
  }

  private case class HiveEvaluator(
      evaluator: GenericUDAFEvaluator,
      objectInspector: ObjectInspector)

  // The UDAF evaluator used to consume raw input rows and produce partial aggregation results.
  // Hive `ObjectInspector` used to inspect partial aggregation results.
  @transient
  private lazy val partial1HiveEvaluator = {
    val evaluator = newEvaluator()
    HiveEvaluator(evaluator, evaluator.init(GenericUDAFEvaluator.Mode.PARTIAL1, inputInspectors))
  }

  // The UDAF evaluator used to consume partial aggregation results and produce final results.
  // Hive `ObjectInspector` used to inspect final results.
  @transient
  private lazy val finalHiveEvaluator = {
    val evaluator = newEvaluator()
    HiveEvaluator(
      evaluator,
      evaluator.init(GenericUDAFEvaluator.Mode.FINAL, Array(partial1HiveEvaluator.objectInspector)))
  }

  // Spark SQL data type of partial aggregation results
  @transient
  private lazy val partialResultDataType =
    inspectorToDataType(partial1HiveEvaluator.objectInspector)

  // Wrapper functions used to wrap Spark SQL input arguments into Hive specific format.
  @transient
  private lazy val inputWrappers = children.map(x => wrapperFor(toInspector(x), x.dataType)).toArray

  // Unwrapper function used to unwrap final aggregation result objects returned by Hive UDAFs into
  // Spark SQL specific format.
  @transient
  private lazy val resultUnwrapper = unwrapperFor(finalHiveEvaluator.objectInspector)

  @transient
  private lazy val cached: Array[AnyRef] = new Array[AnyRef](children.length)

  @transient
  private lazy val aggBufferSerDe: AggregationBufferSerDe = new AggregationBufferSerDe

  override def nullable: Boolean = true

  override lazy val dataType: DataType = inspectorToDataType(finalHiveEvaluator.objectInspector)

  override def prettyName: String = name

  override def sql(isDistinct: Boolean): String = {
    val distinct = if (isDistinct) "DISTINCT " else " "
    s"$name($distinct${children.map(_.sql).mkString(", ")})"
  }

  // The hive UDAF may create different buffers to handle different inputs: original data or
  // aggregate buffer. However, the Spark UDAF framework does not expose this information when
  // creating the buffer. Here we return null, and create the buffer in `update` and `merge`
  // on demand, so that we can know what input we are dealing with.
  override def createAggregationBuffer(): HiveUDAFBuffer = null

  @transient
  private lazy val inputProjection = UnsafeProjection.create(children)

  override def update(buffer: HiveUDAFBuffer, input: InternalRow): HiveUDAFBuffer = {
    // The input is original data, we create buffer with the partial1 evaluator.
    val nonNullBuffer = if (buffer == null) {
      HiveUDAFBuffer(partial1HiveEvaluator.evaluator.getNewAggregationBuffer, false)
    } else {
      buffer
    }

    assert(!nonNullBuffer.canDoMerge, "can not call `merge` then `update` on a Hive UDAF.")

    partial1HiveEvaluator.evaluator.iterate(
      nonNullBuffer.buf, wrap(inputProjection(input), inputWrappers, cached, inputDataTypes))
    nonNullBuffer
  }

  override def merge(buffer: HiveUDAFBuffer, input: HiveUDAFBuffer): HiveUDAFBuffer = {
    // The input is aggregate buffer, we create buffer with the final evaluator.
    val nonNullBuffer = if (buffer == null) {
      HiveUDAFBuffer(finalHiveEvaluator.evaluator.getNewAggregationBuffer, true)
    } else {
      buffer
    }

    // It's possible that we've called `update` of this Hive UDAF, and some specific Hive UDAF
    // implementation can't mix the `update` and `merge` calls during its life cycle. To work
    // around it, here we create a fresh buffer with final evaluator, and merge the existing buffer
    // to it, and replace the existing buffer with it.
    val mergeableBuf = if (!nonNullBuffer.canDoMerge) {
      val newBuf = finalHiveEvaluator.evaluator.getNewAggregationBuffer
      finalHiveEvaluator.evaluator.merge(
        newBuf, partial1HiveEvaluator.evaluator.terminatePartial(nonNullBuffer.buf))
      HiveUDAFBuffer(newBuf, true)
    } else {
      nonNullBuffer
    }

    // The 2nd argument of the Hive `GenericUDAFEvaluator.merge()` method is an input aggregation
    // buffer in the 3rd format mentioned in the ScalaDoc of this class. Originally, Hive converts
    // this `AggregationBuffer`s into this format before shuffling partial aggregation results, and
    // calls `GenericUDAFEvaluator.terminatePartial()` to do the conversion.
    finalHiveEvaluator.evaluator.merge(
      mergeableBuf.buf, partial1HiveEvaluator.evaluator.terminatePartial(input.buf))
    mergeableBuf
  }

  override def eval(buffer: HiveUDAFBuffer): Any = {
    resultUnwrapper(finalHiveEvaluator.evaluator.terminate(buffer.buf))
  }

  override def serialize(buffer: HiveUDAFBuffer): Array[Byte] = {
    // Serializes an `AggregationBuffer` that holds partial aggregation results so that we can
    // shuffle it for global aggregation later.
    aggBufferSerDe.serialize(buffer.buf)
  }

  override def deserialize(bytes: Array[Byte]): HiveUDAFBuffer = {
    // Deserializes an `AggregationBuffer` from the shuffled partial aggregation phase to prepare
    // for global aggregation by merging multiple partial aggregation results within a single group.
    HiveUDAFBuffer(aggBufferSerDe.deserialize(bytes), false)
  }

  // Helper class used to de/serialize Hive UDAF `AggregationBuffer` objects
  private class AggregationBufferSerDe {
    private val partialResultUnwrapper = unwrapperFor(partial1HiveEvaluator.objectInspector)

    private val partialResultWrapper =
      wrapperFor(partial1HiveEvaluator.objectInspector, partialResultDataType)

    private val projection = UnsafeProjection.create(Array(partialResultDataType))

    private val mutableRow = new GenericInternalRow(1)

    def serialize(buffer: AggregationBuffer): Array[Byte] = {
      // The buffer may be null if there is no input. It's unclear if the hive UDAF accepts null
      // buffer, for safety we create an empty buffer here.
      val nonNullBuffer = if (buffer == null) {
        partial1HiveEvaluator.evaluator.getNewAggregationBuffer
      } else {
        buffer
      }

      // `GenericUDAFEvaluator.terminatePartial()` converts an `AggregationBuffer` into an object
      // that can be inspected by the `ObjectInspector` returned by `GenericUDAFEvaluator.init()`.
      // Then we can unwrap it to a Spark SQL value.
      mutableRow.update(0, partialResultUnwrapper(
        partial1HiveEvaluator.evaluator.terminatePartial(nonNullBuffer)))
      val unsafeRow = projection(mutableRow)
      val bytes = ByteBuffer.allocate(unsafeRow.getSizeInBytes)
      unsafeRow.writeTo(bytes)
      bytes.array()
    }

    def deserialize(bytes: Array[Byte]): AggregationBuffer = {
      // `GenericUDAFEvaluator` doesn't provide any method that is capable to convert an object
      // returned by `GenericUDAFEvaluator.terminatePartial()` back to an `AggregationBuffer`. The
      // workaround here is creating an initial `AggregationBuffer` first and then merge the
      // deserialized object into the buffer.
      val buffer = finalHiveEvaluator.evaluator.getNewAggregationBuffer
      val unsafeRow = new UnsafeRow(1)
      unsafeRow.pointTo(bytes, bytes.length)
      val partialResult = unsafeRow.get(0, partialResultDataType)
      finalHiveEvaluator.evaluator.merge(buffer, partialResultWrapper(partialResult))
      buffer
    }
  }
}

case class HiveUDAFBuffer(buf: AggregationBuffer, canDoMerge: Boolean)
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

package org.apache.spark.sql.hive

import java.io.File
import java.net.{URL, URLClassLoader}
import java.nio.charset.StandardCharsets
import java.sql.Timestamp
import java.util.Locale
import java.util.concurrent.TimeUnit

import scala.collection.JavaConverters._
import scala.collection.mutable.HashMap
import scala.language.implicitConversions

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hive.common.`type`.HiveDecimal
import org.apache.hadoop.hive.conf.HiveConf
import org.apache.hadoop.hive.conf.HiveConf.ConfVars
import org.apache.hadoop.hive.ql.session.SessionState
import org.apache.hadoop.hive.serde2.io.{DateWritable, TimestampWritable}
import org.apache.hadoop.util.VersionInfo

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.deploy.SparkHadoopUtil
import org.apache.spark.internal.Logging
import org.apache.spark.sql._
import org.apache.spark.sql.catalyst.catalog.CatalogTable
import org.apache.spark.sql.execution.command.DDLUtils
import org.apache.spark.sql.hive.client._
import org.apache.spark.sql.internal.SQLConf
import org.apache.spark.sql.internal.SQLConf._
import org.apache.spark.sql.internal.StaticSQLConf.{CATALOG_IMPLEMENTATION, WAREHOUSE_PATH}
import org.apache.spark.sql.types._
import org.apache.spark.util.{ChildFirstURLClassLoader, Utils}


private[spark] object HiveUtils extends Logging {

  def withHiveExternalCatalog(sc: SparkContext): SparkContext = {
    sc.conf.set(CATALOG_IMPLEMENTATION.key, "hive")
    sc
  }

  /** The version of hive used internally by Spark SQL. */
  val builtinHiveVersion: String = "1.2.1"

  val HIVE_METASTORE_VERSION = buildConf("spark.sql.hive.metastore.version")
    .doc("Version of the Hive metastore. Available options are " +
        s"<code>0.12.0</code> through <code>2.3.3</code>.")
    .stringConf
    .createWithDefault(builtinHiveVersion)

  // A fake config which is only here for backward compatibility reasons. This config has no effect
  // to Spark, just for reporting the builtin Hive version of Spark to existing applications that
  // already rely on this config.
  val FAKE_HIVE_VERSION = buildConf("spark.sql.hive.version")
    .doc(s"deprecated, please use ${HIVE_METASTORE_VERSION.key} to get the Hive version in Spark.")
    .stringConf
    .createWithDefault(builtinHiveVersion)

  val HIVE_METASTORE_JARS = buildConf("spark.sql.hive.metastore.jars")
    .doc(s"""
      | Location of the jars that should be used to instantiate the HiveMetastoreClient.
      | This property can be one of three options: "
      | 1. "builtin"
      |   Use Hive ${builtinHiveVersion}, which is bundled with the Spark assembly when
      |   <code>-Phive</code> is enabled. When this option is chosen,
      |   <code>spark.sql.hive.metastore.version</code> must be either
      |   <code>${builtinHiveVersion}</code> or not defined.
      | 2. "maven"
      |   Use Hive jars of specified version downloaded from Maven repositories.
      | 3. A classpath in the standard format for both Hive and Hadoop.
      """.stripMargin)
    .stringConf
    .createWithDefault("builtin")

  val CONVERT_METASTORE_PARQUET = buildConf("spark.sql.hive.convertMetastoreParquet")
    .doc("When set to true, the built-in Parquet reader and writer are used to process " +
      "parquet tables created by using the HiveQL syntax, instead of Hive serde.")
    .booleanConf
    .createWithDefault(true)

  val CONVERT_METASTORE_PARQUET_WITH_SCHEMA_MERGING =
    buildConf("spark.sql.hive.convertMetastoreParquet.mergeSchema")
      .doc("When true, also tries to merge possibly different but compatible Parquet schemas in " +
        "different Parquet data files. This configuration is only effective " +
        "when \"spark.sql.hive.convertMetastoreParquet\" is true.")
      .booleanConf
      .createWithDefault(false)

  val CONVERT_METASTORE_ORC = buildConf("spark.sql.hive.convertMetastoreOrc")
    .doc("When set to true, the built-in ORC reader and writer are used to process " +
      "ORC tables created by using the HiveQL syntax, instead of Hive serde.")
    .booleanConf
    .createWithDefault(true)

  val HIVE_METASTORE_SHARED_PREFIXES = buildConf("spark.sql.hive.metastore.sharedPrefixes")
    .doc("A comma separated list of class prefixes that should be loaded using the classloader " +
      "that is shared between Spark SQL and a specific version of Hive. An example of classes " +
      "that should be shared is JDBC drivers that are needed to talk to the metastore. Other " +
      "classes that need to be shared are those that interact with classes that are already " +
      "shared. For example, custom appenders that are used by log4j.")
    .stringConf
    .toSequence
    .createWithDefault(jdbcPrefixes)

  private def jdbcPrefixes = Seq(
    "com.mysql.jdbc", "org.postgresql", "com.microsoft.sqlserver", "oracle.jdbc")

  val HIVE_METASTORE_BARRIER_PREFIXES = buildConf("spark.sql.hive.metastore.barrierPrefixes")
    .doc("A comma separated list of class prefixes that should explicitly be reloaded for each " +
      "version of Hive that Spark SQL is communicating with. For example, Hive UDFs that are " +
      "declared in a prefix that typically would be shared (i.e. <code>org.apache.spark.*</code>).")
    .stringConf
    .toSequence
    .createWithDefault(Nil)

  val HIVE_THRIFT_SERVER_ASYNC = buildConf("spark.sql.hive.thriftServer.async")
    .doc("When set to true, Hive Thrift server executes SQL queries in an asynchronous way.")
    .booleanConf
    .createWithDefault(true)

  /**
   * The version of the hive client that will be used to communicate with the metastore.  Note that
   * this does not necessarily need to be the same version of Hive that is used internally by
   * Spark SQL for execution.
   */
  private def hiveMetastoreVersion(conf: SQLConf): String = {
    conf.getConf(HIVE_METASTORE_VERSION)
  }

  /**
   * The location of the jars that should be used to instantiate the HiveMetastoreClient.  This
   * property can be one of three options:
   *  - a classpath in the standard format for both hive and hadoop.
   *  - builtin - attempt to discover the jars that were used to load Spark SQL and use those. This
   *              option is only valid when using the execution version of Hive.
   *  - maven - download the correct version of hive on demand from maven.
   */
  private def hiveMetastoreJars(conf: SQLConf): String = {
    conf.getConf(HIVE_METASTORE_JARS)
  }

  /**
   * A comma separated list of class prefixes that should be loaded using the classloader that
   * is shared between Spark SQL and a specific version of Hive. An example of classes that should
   * be shared is JDBC drivers that are needed to talk to the metastore. Other classes that need
   * to be shared are those that interact with classes that are already shared.  For example,
   * custom appenders that are used by log4j.
   */
  private def hiveMetastoreSharedPrefixes(conf: SQLConf): Seq[String] = {
    conf.getConf(HIVE_METASTORE_SHARED_PREFIXES).filterNot(_ == "")
  }

  /**
   * A comma separated list of class prefixes that should explicitly be reloaded for each version
   * of Hive that Spark SQL is communicating with.  For example, Hive UDFs that are declared in a
   * prefix that typically would be shared (i.e. org.apache.spark.*)
   */
  private def hiveMetastoreBarrierPrefixes(conf: SQLConf): Seq[String] = {
    conf.getConf(HIVE_METASTORE_BARRIER_PREFIXES).filterNot(_ == "")
  }

  /**
   * Change time configurations needed to create a [[HiveClient]] into unified [[Long]] format.
   */
  private[hive] def formatTimeVarsForHiveClient(hadoopConf: Configuration): Map[String, String] = {
    // Hive 0.14.0 introduces timeout operations in HiveConf, and changes default values of a bunch
    // of time `ConfVar`s by adding time suffixes (`s`, `ms`, and `d` etc.).  This breaks backwards-
    // compatibility when users are trying to connecting to a Hive metastore of lower version,
    // because these options are expected to be integral values in lower versions of Hive.
    //
    // Here we enumerate all time `ConfVar`s and convert their values to numeric strings according
    // to their output time units.
    Seq(
      ConfVars.METASTORE_CLIENT_CONNECT_RETRY_DELAY -> TimeUnit.SECONDS,
      ConfVars.METASTORE_CLIENT_SOCKET_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.METASTORE_CLIENT_SOCKET_LIFETIME -> TimeUnit.SECONDS,
      ConfVars.HMSHANDLERINTERVAL -> TimeUnit.MILLISECONDS,
      ConfVars.METASTORE_EVENT_DB_LISTENER_TTL -> TimeUnit.SECONDS,
      ConfVars.METASTORE_EVENT_CLEAN_FREQ -> TimeUnit.SECONDS,
      ConfVars.METASTORE_EVENT_EXPIRY_DURATION -> TimeUnit.SECONDS,
      ConfVars.METASTORE_AGGREGATE_STATS_CACHE_TTL -> TimeUnit.SECONDS,
      ConfVars.METASTORE_AGGREGATE_STATS_CACHE_MAX_WRITER_WAIT -> TimeUnit.MILLISECONDS,
      ConfVars.METASTORE_AGGREGATE_STATS_CACHE_MAX_READER_WAIT -> TimeUnit.MILLISECONDS,
      ConfVars.HIVES_AUTO_PROGRESS_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_LOG_INCREMENTAL_PLAN_PROGRESS_INTERVAL -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_STATS_JDBC_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_STATS_RETRIES_WAIT -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_LOCK_SLEEP_BETWEEN_RETRIES -> TimeUnit.SECONDS,
      ConfVars.HIVE_ZOOKEEPER_SESSION_TIMEOUT -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_ZOOKEEPER_CONNECTION_BASESLEEPTIME -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_TXN_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_COMPACTOR_WORKER_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_COMPACTOR_CHECK_INTERVAL -> TimeUnit.SECONDS,
      ConfVars.HIVE_COMPACTOR_CLEANER_RUN_INTERVAL -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_SERVER2_THRIFT_HTTP_MAX_IDLE_TIME -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_SERVER2_THRIFT_HTTP_WORKER_KEEPALIVE_TIME -> TimeUnit.SECONDS,
      ConfVars.HIVE_SERVER2_THRIFT_HTTP_COOKIE_MAX_AGE -> TimeUnit.SECONDS,
      ConfVars.HIVE_SERVER2_THRIFT_LOGIN_BEBACKOFF_SLOT_LENGTH -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_SERVER2_THRIFT_LOGIN_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_SERVER2_THRIFT_WORKER_KEEPALIVE_TIME -> TimeUnit.SECONDS,
      ConfVars.HIVE_SERVER2_ASYNC_EXEC_SHUTDOWN_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_SERVER2_ASYNC_EXEC_KEEPALIVE_TIME -> TimeUnit.SECONDS,
      ConfVars.HIVE_SERVER2_LONG_POLLING_TIMEOUT -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_SERVER2_SESSION_CHECK_INTERVAL -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_SERVER2_IDLE_SESSION_TIMEOUT -> TimeUnit.MILLISECONDS,
      ConfVars.HIVE_SERVER2_IDLE_OPERATION_TIMEOUT -> TimeUnit.MILLISECONDS,
      ConfVars.SERVER_READ_SOCKET_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.HIVE_LOCALIZE_RESOURCE_WAIT_INTERVAL -> TimeUnit.MILLISECONDS,
      ConfVars.SPARK_CLIENT_FUTURE_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.SPARK_JOB_MONITOR_TIMEOUT -> TimeUnit.SECONDS,
      ConfVars.SPARK_RPC_CLIENT_CONNECT_TIMEOUT -> TimeUnit.MILLISECONDS,
      ConfVars.SPARK_RPC_CLIENT_HANDSHAKE_TIMEOUT -> TimeUnit.MILLISECONDS
    ).map { case (confVar, unit) =>
      confVar.varname -> HiveConf.getTimeVar(hadoopConf, confVar, unit).toString
    }.toMap
  }

  /**
   * Check current Thread's SessionState type
   * @return true when SessionState.get returns an instance of CliSessionState,
   *         false when it gets non-CliSessionState instance or null
   */
  def isCliSessionState(): Boolean = {
    val state = SessionState.get
    var temp: Class[_] = if (state != null) state.getClass else null
    var found = false
    while (temp != null && !found) {
      found = temp.getName == "org.apache.hadoop.hive.cli.CliSessionState"
      temp = temp.getSuperclass
    }
    found
  }

  /**
   * Create a [[HiveClient]] used for execution.
   *
   * Currently this must always be Hive 13 as this is the version of Hive that is packaged
   * with Spark SQL. This copy of the client is used for execution related tasks like
   * registering temporary functions or ensuring that the ThreadLocal SessionState is
   * correctly populated.  This copy of Hive is *not* used for storing persistent metadata,
   * and only point to a dummy metastore in a temporary directory.
   */
  protected[hive] def newClientForExecution(
      conf: SparkConf,
      hadoopConf: Configuration): HiveClientImpl = {
    logInfo(s"Initializing execution hive, version $builtinHiveVersion")
    val loader = new IsolatedClientLoader(
      version = IsolatedClientLoader.hiveVersion(builtinHiveVersion),
      sparkConf = conf,
      execJars = Seq.empty,
      hadoopConf = hadoopConf,
      config = newTemporaryConfiguration(useInMemoryDerby = true),
      isolationOn = false,
      baseClassLoader = Utils.getContextOrSparkClassLoader)
    loader.createClient().asInstanceOf[HiveClientImpl]
  }

  /**
   * Create a [[HiveClient]] used to retrieve metadata from the Hive MetaStore.
   *
   * The version of the Hive client that is used here must match the metastore that is configured
   * in the hive-site.xml file.
   */
  protected[hive] def newClientForMetadata(
      conf: SparkConf,
      hadoopConf: Configuration): HiveClient = {
    val configurations = formatTimeVarsForHiveClient(hadoopConf)
    newClientForMetadata(conf, hadoopConf, configurations)
  }

  protected[hive] def newClientForMetadata(
      conf: SparkConf,
      hadoopConf: Configuration,
      configurations: Map[String, String]): HiveClient = {
    val sqlConf = new SQLConf
    sqlConf.setConf(SQLContext.getSQLProperties(conf))
    val hiveMetastoreVersion = HiveUtils.hiveMetastoreVersion(sqlConf)
    val hiveMetastoreJars = HiveUtils.hiveMetastoreJars(sqlConf)
    val hiveMetastoreSharedPrefixes = HiveUtils.hiveMetastoreSharedPrefixes(sqlConf)
    val hiveMetastoreBarrierPrefixes = HiveUtils.hiveMetastoreBarrierPrefixes(sqlConf)
    val metaVersion = IsolatedClientLoader.hiveVersion(hiveMetastoreVersion)

    val isolatedLoader = if (hiveMetastoreJars == "builtin") {
      if (builtinHiveVersion != hiveMetastoreVersion) {
        throw new IllegalArgumentException(
          "Builtin jars can only be used when hive execution version == hive metastore version. " +
            s"Execution: $builtinHiveVersion != Metastore: $hiveMetastoreVersion. " +
            s"Specify a valid path to the correct hive jars using ${HIVE_METASTORE_JARS.key} " +
            s"or change ${HIVE_METASTORE_VERSION.key} to $builtinHiveVersion.")
      }

      // We recursively find all jars in the class loader chain,
      // starting from the given classLoader.
      def allJars(classLoader: ClassLoader): Array[URL] = classLoader match {
        case null => Array.empty[URL]
        case childFirst: ChildFirstURLClassLoader =>
          childFirst.getURLs() ++ allJars(Utils.getSparkClassLoader)
        case urlClassLoader: URLClassLoader =>
          urlClassLoader.getURLs ++ allJars(urlClassLoader.getParent)
        case other => allJars(other.getParent)
      }

      val classLoader = Utils.getContextOrSparkClassLoader
      val jars = allJars(classLoader)
      if (jars.length == 0) {
        throw new IllegalArgumentException(
          "Unable to locate hive jars to connect to metastore. " +
            s"Please set ${HIVE_METASTORE_JARS.key}.")
      }

      logInfo(
        s"Initializing HiveMetastoreConnection version $hiveMetastoreVersion using Spark classes.")
      new IsolatedClientLoader(
        version = metaVersion,
        sparkConf = conf,
        hadoopConf = hadoopConf,
        execJars = jars.toSeq,
        config = configurations,
        isolationOn = !isCliSessionState(),
        barrierPrefixes = hiveMetastoreBarrierPrefixes,
        sharedPrefixes = hiveMetastoreSharedPrefixes)
    } else if (hiveMetastoreJars == "maven") {
      // TODO: Support for loading the jars from an already downloaded location.
      logInfo(
        s"Initializing HiveMetastoreConnection version $hiveMetastoreVersion using maven.")
      IsolatedClientLoader.forVersion(
        hiveMetastoreVersion = hiveMetastoreVersion,
        hadoopVersion = VersionInfo.getVersion,
        sparkConf = conf,
        hadoopConf = hadoopConf,
        config = configurations,
        barrierPrefixes = hiveMetastoreBarrierPrefixes,
        sharedPrefixes = hiveMetastoreSharedPrefixes)
    } else {
      // Convert to files and expand any directories.
      val jars =
        hiveMetastoreJars
          .split(File.pathSeparator)
          .flatMap {
          case path if new File(path).getName == "*" =>
            val files = new File(path).getParentFile.listFiles()
            if (files == null) {
              logWarning(s"Hive jar path '$path' does not exist.")
              Nil
            } else {
              files.filter(_.getName.toLowerCase(Locale.ROOT).endsWith(".jar"))
            }
          case path =>
            new File(path) :: Nil
        }
          .map(_.toURI.toURL)

      logInfo(
        s"Initializing HiveMetastoreConnection version $hiveMetastoreVersion " +
          s"using ${jars.mkString(":")}")
      new IsolatedClientLoader(
        version = metaVersion,
        sparkConf = conf,
        hadoopConf = hadoopConf,
        execJars = jars.toSeq,
        config = configurations,
        isolationOn = true,
        barrierPrefixes = hiveMetastoreBarrierPrefixes,
        sharedPrefixes = hiveMetastoreSharedPrefixes)
    }
    isolatedLoader.createClient()
  }

  /** Constructs a configuration for hive, where the metastore is located in a temp directory. */
  def newTemporaryConfiguration(useInMemoryDerby: Boolean): Map[String, String] = {
    val withInMemoryMode = if (useInMemoryDerby) "memory:" else ""

    val tempDir = Utils.createTempDir()
    val localMetastore = new File(tempDir, "metastore")
    val propMap: HashMap[String, String] = HashMap()
    // We have to mask all properties in hive-site.xml that relates to metastore data source
    // as we used a local metastore here.
    HiveConf.ConfVars.values().foreach { confvar =>
      if (confvar.varname.contains("datanucleus") || confvar.varname.contains("jdo")
        || confvar.varname.contains("hive.metastore.rawstore.impl")) {
        propMap.put(confvar.varname, confvar.getDefaultExpr())
      }
    }
    propMap.put(WAREHOUSE_PATH.key, localMetastore.toURI.toString)
    propMap.put(HiveConf.ConfVars.METASTORECONNECTURLKEY.varname,
      s"jdbc:derby:${withInMemoryMode};databaseName=${localMetastore.getAbsolutePath};create=true")
    propMap.put("datanucleus.rdbms.datastoreAdapterClassName",
      "org.datanucleus.store.rdbms.adapter.DerbyAdapter")

    // SPARK-11783: When "hive.metastore.uris" is set, the metastore connection mode will be
    // remote (https://cwiki.apache.org/confluence/display/Hive/AdminManual+MetastoreAdmin
    // mentions that "If hive.metastore.uris is empty local mode is assumed, remote otherwise").
    // Remote means that the metastore server is running in its own process.
    // When the mode is remote, configurations like "javax.jdo.option.ConnectionURL" will not be
    // used (because they are used by remote metastore server that talks to the database).
    // Because execution Hive should always connects to an embedded derby metastore.
    // We have to remove the value of hive.metastore.uris. So, the execution Hive client connects
    // to the actual embedded derby metastore instead of the remote metastore.
    // You can search HiveConf.ConfVars.METASTOREURIS in the code of HiveConf (in Hive's repo).
    // Then, you will find that the local metastore mode is only set to true when
    // hive.metastore.uris is not set.
    propMap.put(ConfVars.METASTOREURIS.varname, "")

    // The execution client will generate garbage events, therefore the listeners that are generated
    // for the execution clients are useless. In order to not output garbage, we don't generate
    // these listeners.
    propMap.put(ConfVars.METASTORE_PRE_EVENT_LISTENERS.varname, "")
    propMap.put(ConfVars.METASTORE_EVENT_LISTENERS.varname, "")
    propMap.put(ConfVars.METASTORE_END_FUNCTION_LISTENERS.varname, "")

    // SPARK-21451: Spark will gather all `spark.hadoop.*` properties from a `SparkConf` to a
    // Hadoop Configuration internally, as long as it happens after SparkContext initialized.
    // Some instances such as `CliSessionState` used in `SparkSQLCliDriver` may also rely on these
    // Configuration. But it happens before SparkContext initialized, we need to take them from
    // system properties in the form of regular hadoop configurations.
    SparkHadoopUtil.get.appendSparkHadoopConfigs(sys.props.toMap, propMap)

    propMap.toMap
  }

  protected val primitiveTypes =
    Seq(StringType, IntegerType, LongType, DoubleType, FloatType, BooleanType, ByteType,
      ShortType, DateType, TimestampType, BinaryType)

  protected[sql] def toHiveString(a: (Any, DataType)): String = a match {
    case (struct: Row, StructType(fields)) =>
      struct.toSeq.zip(fields).map {
        case (v, t) => s""""${t.name}":${toHiveStructString((v, t.dataType))}"""
      }.mkString("{", ",", "}")
    case (seq: Seq[_], ArrayType(typ, _)) =>
      seq.map(v => (v, typ)).map(toHiveStructString).mkString("[", ",", "]")
    case (map: Map[_, _], MapType(kType, vType, _)) =>
      map.map {
        case (key, value) =>
          toHiveStructString((key, kType)) + ":" + toHiveStructString((value, vType))
      }.toSeq.sorted.mkString("{", ",", "}")
    case (null, _) => "NULL"
    case (d: Int, DateType) => new DateWritable(d).toString
    case (t: Timestamp, TimestampType) => new TimestampWritable(t).toString
    case (bin: Array[Byte], BinaryType) => new String(bin, StandardCharsets.UTF_8)
    case (decimal: java.math.BigDecimal, DecimalType()) =>
      // Hive strips trailing zeros so use its toString
      HiveDecimal.create(decimal).toString
    case (other, _ : UserDefinedType[_]) => other.toString
    case (other, tpe) if primitiveTypes contains tpe => other.toString
  }

  /** Hive outputs fields of structs slightly differently than top level attributes. */
  protected def toHiveStructString(a: (Any, DataType)): String = a match {
    case (struct: Row, StructType(fields)) =>
      struct.toSeq.zip(fields).map {
        case (v, t) => s""""${t.name}":${toHiveStructString((v, t.dataType))}"""
      }.mkString("{", ",", "}")
    case (seq: Seq[_], ArrayType(typ, _)) =>
      seq.map(v => (v, typ)).map(toHiveStructString).mkString("[", ",", "]")
    case (map: Map[_, _], MapType(kType, vType, _)) =>
      map.map {
        case (key, value) =>
          toHiveStructString((key, kType)) + ":" + toHiveStructString((value, vType))
      }.toSeq.sorted.mkString("{", ",", "}")
    case (null, _) => "null"
    case (s: String, StringType) => "\"" + s + "\""
    case (decimal, DecimalType()) => decimal.toString
    case (other, tpe) if primitiveTypes contains tpe => other.toString
  }

  /**
   * Infers the schema for Hive serde tables and returns the CatalogTable with the inferred schema.
   * When the tables are data source tables or the schema already exists, returns the original
   * CatalogTable.
   */
  def inferSchema(table: CatalogTable): CatalogTable = {
    if (DDLUtils.isDatasourceTable(table) || table.dataSchema.nonEmpty) {
      table
    } else {
      val hiveTable = HiveClientImpl.toHiveTable(table)
      // Note: Hive separates partition columns and the schema, but for us the
      // partition columns are part of the schema
      val partCols = hiveTable.getPartCols.asScala.map(HiveClientImpl.fromHiveColumn)
      val dataCols = hiveTable.getCols.asScala.map(HiveClientImpl.fromHiveColumn)
      table.copy(schema = StructType(dataCols ++ partCols))
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

package org.apache.spark.sql.hive.execution

import scala.language.existentials

import org.apache.hadoop.fs.{FileSystem, Path}
import org.apache.hadoop.hive.common.FileUtils
import org.apache.hadoop.hive.ql.plan.TableDesc
import org.apache.hadoop.hive.serde.serdeConstants
import org.apache.hadoop.hive.serde2.`lazy`.LazySimpleSerDe
import org.apache.hadoop.mapred._

import org.apache.spark.SparkException
import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.catalyst.TableIdentifier
import org.apache.spark.sql.catalyst.catalog.{CatalogStorageFormat, CatalogTable}
import org.apache.spark.sql.catalyst.expressions.Attribute
import org.apache.spark.sql.catalyst.plans.logical.LogicalPlan
import org.apache.spark.sql.execution.SparkPlan
import org.apache.spark.sql.hive.client.HiveClientImpl
import org.apache.spark.sql.util.SchemaUtils

/**
 * Command for writing the results of `query` to file system.
 *
 * The syntax of using this command in SQL is:
 * {{{
 *   INSERT OVERWRITE [LOCAL] DIRECTORY
 *   path
 *   [ROW FORMAT row_format]
 *   [STORED AS file_format]
 *   SELECT ...
 * }}}
 *
 * @param isLocal whether the path specified in `storage` is a local directory
 * @param storage storage format used to describe how the query result is stored.
 * @param query the logical plan representing data to write to
 * @param overwrite whether overwrites existing directory
 */
case class InsertIntoHiveDirCommand(
    isLocal: Boolean,
    storage: CatalogStorageFormat,
    query: LogicalPlan,
    overwrite: Boolean,
    outputColumnNames: Seq[String]) extends SaveAsHiveFile {

  override def run(sparkSession: SparkSession, child: SparkPlan): Seq[Row] = {
    assert(storage.locationUri.nonEmpty)
    SchemaUtils.checkColumnNameDuplication(
      outputColumnNames,
      s"when inserting into ${storage.locationUri.get}",
      sparkSession.sessionState.conf.caseSensitiveAnalysis)

    val hiveTable = HiveClientImpl.toHiveTable(CatalogTable(
      identifier = TableIdentifier(storage.locationUri.get.toString, Some("default")),
      tableType = org.apache.spark.sql.catalyst.catalog.CatalogTableType.VIEW,
      storage = storage,
      schema = outputColumns.toStructType
    ))
    hiveTable.getMetadata.put(serdeConstants.SERIALIZATION_LIB,
      storage.serde.getOrElse(classOf[LazySimpleSerDe].getName))

    val tableDesc = new TableDesc(
      hiveTable.getInputFormatClass,
      hiveTable.getOutputFormatClass,
      hiveTable.getMetadata
    )

    val hadoopConf = sparkSession.sessionState.newHadoopConf()
    val jobConf = new JobConf(hadoopConf)

    val targetPath = new Path(storage.locationUri.get)
    val writeToPath =
      if (isLocal) {
        val localFileSystem = FileSystem.getLocal(jobConf)
        localFileSystem.makeQualified(targetPath)
      } else {
        val qualifiedPath = FileUtils.makeQualified(targetPath, hadoopConf)
        val dfs = qualifiedPath.getFileSystem(jobConf)
        if (!dfs.exists(qualifiedPath)) {
          dfs.mkdirs(qualifiedPath.getParent)
        }
        qualifiedPath
      }

    val tmpPath = getExternalTmpPath(sparkSession, hadoopConf, writeToPath)
    val fileSinkConf = new org.apache.spark.sql.hive.HiveShim.ShimFileSinkDesc(
      tmpPath.toString, tableDesc, false)

    try {
      saveAsHiveFile(
        sparkSession = sparkSession,
        plan = child,
        hadoopConf = hadoopConf,
        fileSinkConf = fileSinkConf,
        outputLocation = tmpPath.toString)

      val fs = writeToPath.getFileSystem(hadoopConf)
      if (overwrite && fs.exists(writeToPath)) {
        fs.listStatus(writeToPath).foreach { existFile =>
          if (Option(existFile.getPath) != createdTempDir) fs.delete(existFile.getPath, true)
        }
      }

      fs.listStatus(tmpPath).foreach {
        tmpFile => fs.rename(tmpFile.getPath, writeToPath)
      }
    } catch {
      case e: Throwable =>
        throw new SparkException(
          "Failed inserting overwrite directory " + storage.locationUri.get, e)
    } finally {
      deleteExternalTmpPath(hadoopConf)
    }

    Seq.empty[Row]
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

package org.apache.spark.sql.hive.execution

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path
import org.apache.hadoop.hive.ql.ErrorMsg
import org.apache.hadoop.hive.ql.plan.TableDesc

import org.apache.spark.SparkException
import org.apache.spark.sql.{AnalysisException, Row, SparkSession}
import org.apache.spark.sql.catalyst.catalog.{CatalogTable, ExternalCatalog}
import org.apache.spark.sql.catalyst.expressions.Attribute
import org.apache.spark.sql.catalyst.plans.logical.LogicalPlan
import org.apache.spark.sql.execution.SparkPlan
import org.apache.spark.sql.execution.command.CommandUtils
import org.apache.spark.sql.hive.HiveShim.{ShimFileSinkDesc => FileSinkDesc}
import org.apache.spark.sql.hive.client.HiveClientImpl


/**
 * Command for writing data out to a Hive table.
 *
 * This class is mostly a mess, for legacy reasons (since it evolved in organic ways and had to
 * follow Hive's internal implementations closely, which itself was a mess too). Please don't
 * blame Reynold for this! He was just moving code around!
 *
 * In the future we should converge the write path for Hive with the normal data source write path,
 * as defined in `org.apache.spark.sql.execution.datasources.FileFormatWriter`.
 *
 * @param table the metadata of the table.
 * @param partition a map from the partition key to the partition value (optional). If the partition
 *                  value is optional, dynamic partition insert will be performed.
 *                  As an example, `INSERT INTO tbl PARTITION (a=1, b=2) AS ...` would have
 *
 *                  {{{
 *                  Map('a' -> Some('1'), 'b' -> Some('2'))
 *                  }}}
 *
 *                  and `INSERT INTO tbl PARTITION (a=1, b) AS ...`
 *                  would have
 *
 *                  {{{
 *                  Map('a' -> Some('1'), 'b' -> None)
 *                  }}}.
 * @param query the logical plan representing data to write to.
 * @param overwrite overwrite existing table or partitions.
 * @param ifPartitionNotExists If true, only write if the partition does not exist.
 *                                   Only valid for static partitions.
 */
case class InsertIntoHiveTable(
    table: CatalogTable,
    partition: Map[String, Option[String]],
    query: LogicalPlan,
    overwrite: Boolean,
    ifPartitionNotExists: Boolean,
    outputColumnNames: Seq[String]) extends SaveAsHiveFile {

  /**
   * Inserts all the rows in the table into Hive.  Row objects are properly serialized with the
   * `org.apache.hadoop.hive.serde2.SerDe` and the
   * `org.apache.hadoop.mapred.OutputFormat` provided by the table definition.
   */
  override def run(sparkSession: SparkSession, child: SparkPlan): Seq[Row] = {
    val externalCatalog = sparkSession.sharedState.externalCatalog
    val hadoopConf = sparkSession.sessionState.newHadoopConf()

    val hiveQlTable = HiveClientImpl.toHiveTable(table)
    // Have to pass the TableDesc object to RDD.mapPartitions and then instantiate new serializer
    // instances within the closure, since Serializer is not serializable while TableDesc is.
    val tableDesc = new TableDesc(
      hiveQlTable.getInputFormatClass,
      // The class of table should be org.apache.hadoop.hive.ql.metadata.Table because
      // getOutputFormatClass will use HiveFileFormatUtils.getOutputFormatSubstitute to
      // substitute some output formats, e.g. substituting SequenceFileOutputFormat to
      // HiveSequenceFileOutputFormat.
      hiveQlTable.getOutputFormatClass,
      hiveQlTable.getMetadata
    )
    val tableLocation = hiveQlTable.getDataLocation
    val tmpLocation = getExternalTmpPath(sparkSession, hadoopConf, tableLocation)

    try {
      processInsert(sparkSession, externalCatalog, hadoopConf, tableDesc, tmpLocation, child)
    } finally {
      // Attempt to delete the staging directory and the inclusive files. If failed, the files are
      // expected to be dropped at the normal termination of VM since deleteOnExit is used.
      deleteExternalTmpPath(hadoopConf)
    }

    // un-cache this table.
    sparkSession.catalog.uncacheTable(table.identifier.quotedString)
    sparkSession.sessionState.catalog.refreshTable(table.identifier)

    CommandUtils.updateTableStats(sparkSession, table)

    // It would be nice to just return the childRdd unchanged so insert operations could be chained,
    // however for now we return an empty list to simplify compatibility checks with hive, which
    // does not return anything for insert operations.
    // TODO: implement hive compatibility as rules.
    Seq.empty[Row]
  }

  private def processInsert(
      sparkSession: SparkSession,
      externalCatalog: ExternalCatalog,
      hadoopConf: Configuration,
      tableDesc: TableDesc,
      tmpLocation: Path,
      child: SparkPlan): Unit = {
    val fileSinkConf = new FileSinkDesc(tmpLocation.toString, tableDesc, false)

    val numDynamicPartitions = partition.values.count(_.isEmpty)
    val numStaticPartitions = partition.values.count(_.nonEmpty)
    val partitionSpec = partition.map {
      case (key, Some(value)) => key -> value
      case (key, None) => key -> ""
    }

    // All partition column names in the format of "<column name 1>/<column name 2>/..."
    val partitionColumns = fileSinkConf.getTableInfo.getProperties.getProperty("partition_columns")
    val partitionColumnNames = Option(partitionColumns).map(_.split("/")).getOrElse(Array.empty)

    // By this time, the partition map must match the table's partition columns
    if (partitionColumnNames.toSet != partition.keySet) {
      throw new SparkException(
        s"""Requested partitioning does not match the ${table.identifier.table} table:
           |Requested partitions: ${partition.keys.mkString(",")}
           |Table partitions: ${table.partitionColumnNames.mkString(",")}""".stripMargin)
    }

    // Validate partition spec if there exist any dynamic partitions
    if (numDynamicPartitions > 0) {
      // Report error if dynamic partitioning is not enabled
      if (!hadoopConf.get("hive.exec.dynamic.partition", "true").toBoolean) {
        throw new SparkException(ErrorMsg.DYNAMIC_PARTITION_DISABLED.getMsg)
      }

      // Report error if dynamic partition strict mode is on but no static partition is found
      if (numStaticPartitions == 0 &&
        hadoopConf.get("hive.exec.dynamic.partition.mode", "strict").equalsIgnoreCase("strict")) {
        throw new SparkException(ErrorMsg.DYNAMIC_PARTITION_STRICT_MODE.getMsg)
      }

      // Report error if any static partition appears after a dynamic partition
      val isDynamic = partitionColumnNames.map(partitionSpec(_).isEmpty)
      if (isDynamic.init.zip(isDynamic.tail).contains((true, false))) {
        throw new AnalysisException(ErrorMsg.PARTITION_DYN_STA_ORDER.getMsg)
      }
    }

    table.bucketSpec match {
      case Some(bucketSpec) =>
        // Writes to bucketed hive tables are allowed only if user does not care about maintaining
        // table's bucketing ie. both "hive.enforce.bucketing" and "hive.enforce.sorting" are
        // set to false
        val enforceBucketingConfig = "hive.enforce.bucketing"
        val enforceSortingConfig = "hive.enforce.sorting"

        val message = s"Output Hive table ${table.identifier} is bucketed but Spark " +
          "currently does NOT populate bucketed output which is compatible with Hive."

        if (hadoopConf.get(enforceBucketingConfig, "true").toBoolean ||
          hadoopConf.get(enforceSortingConfig, "true").toBoolean) {
          throw new AnalysisException(message)
        } else {
          logWarning(message + s" Inserting data anyways since both $enforceBucketingConfig and " +
            s"$enforceSortingConfig are set to false.")
        }
      case _ => // do nothing since table has no bucketing
    }

    val partitionAttributes = partitionColumnNames.takeRight(numDynamicPartitions).map { name =>
      query.resolve(name :: Nil, sparkSession.sessionState.analyzer.resolver).getOrElse {
        throw new AnalysisException(
          s"Unable to resolve $name given [${query.output.map(_.name).mkString(", ")}]")
      }.asInstanceOf[Attribute]
    }

    saveAsHiveFile(
      sparkSession = sparkSession,
      plan = child,
      hadoopConf = hadoopConf,
      fileSinkConf = fileSinkConf,
      outputLocation = tmpLocation.toString,
      partitionAttributes = partitionAttributes)

    if (partition.nonEmpty) {
      if (numDynamicPartitions > 0) {
        externalCatalog.loadDynamicPartitions(
          db = table.database,
          table = table.identifier.table,
          tmpLocation.toString,
          partitionSpec,
          overwrite,
          numDynamicPartitions)
      } else {
        // scalastyle:off
        // ifNotExists is only valid with static partition, refer to
        // https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-InsertingdataintoHiveTablesfromqueries
        // scalastyle:on
        val oldPart =
          externalCatalog.getPartitionOption(
            table.database,
            table.identifier.table,
            partitionSpec)

        var doHiveOverwrite = overwrite

        if (oldPart.isEmpty || !ifPartitionNotExists) {
          // SPARK-18107: Insert overwrite runs much slower than hive-client.
          // Newer Hive largely improves insert overwrite performance. As Spark uses older Hive
          // version and we may not want to catch up new Hive version every time. We delete the
          // Hive partition first and then load data file into the Hive partition.
          if (oldPart.nonEmpty && overwrite) {
            oldPart.get.storage.locationUri.foreach { uri =>
              val partitionPath = new Path(uri)
              val fs = partitionPath.getFileSystem(hadoopConf)
              if (fs.exists(partitionPath)) {
                if (!fs.delete(partitionPath, true)) {
                  throw new RuntimeException(
                    "Cannot remove partition directory '" + partitionPath.toString)
                }
                // Don't let Hive do overwrite operation since it is slower.
                doHiveOverwrite = false
              }
            }
          }

          // inheritTableSpecs is set to true. It should be set to false for an IMPORT query
          // which is currently considered as a Hive native command.
          val inheritTableSpecs = true
          externalCatalog.loadPartition(
            table.database,
            table.identifier.table,
            tmpLocation.toString,
            partitionSpec,
            isOverwrite = doHiveOverwrite,
            inheritTableSpecs = inheritTableSpecs,
            isSrcLocal = false)
        }
      }
    } else {
      externalCatalog.loadTable(
        table.database,
        table.identifier.table,
        tmpLocation.toString, // TODO: URI
        overwrite,
        isSrcLocal = false)
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

package org.apache.spark.sql.hive.client

import java.io.File
import java.lang.reflect.InvocationTargetException
import java.net.{URL, URLClassLoader}
import java.util

import scala.util.Try

import org.apache.commons.io.{FileUtils, IOUtils}
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hive.conf.HiveConf.ConfVars

import org.apache.spark.SparkConf
import org.apache.spark.deploy.SparkSubmitUtils
import org.apache.spark.internal.Logging
import org.apache.spark.sql.catalyst.util.quietly
import org.apache.spark.sql.hive.HiveUtils
import org.apache.spark.sql.internal.NonClosableMutableURLClassLoader
import org.apache.spark.util.{MutableURLClassLoader, Utils}

/** Factory for `IsolatedClientLoader` with specific versions of hive. */
private[hive] object IsolatedClientLoader extends Logging {
  /**
   * Creates isolated Hive client loaders by downloading the requested version from maven.
   */
  def forVersion(
      hiveMetastoreVersion: String,
      hadoopVersion: String,
      sparkConf: SparkConf,
      hadoopConf: Configuration,
      config: Map[String, String] = Map.empty,
      ivyPath: Option[String] = None,
      sharedPrefixes: Seq[String] = Seq.empty,
      barrierPrefixes: Seq[String] = Seq.empty,
      sharesHadoopClasses: Boolean = true): IsolatedClientLoader = synchronized {
    val resolvedVersion = hiveVersion(hiveMetastoreVersion)
    // We will first try to share Hadoop classes. If we cannot resolve the Hadoop artifact
    // with the given version, we will use Hadoop 2.6 and then will not share Hadoop classes.
    var _sharesHadoopClasses = sharesHadoopClasses
    val files = if (resolvedVersions.contains((resolvedVersion, hadoopVersion))) {
      resolvedVersions((resolvedVersion, hadoopVersion))
    } else {
      val (downloadedFiles, actualHadoopVersion) =
        try {
          (downloadVersion(resolvedVersion, hadoopVersion, ivyPath), hadoopVersion)
        } catch {
          case e: RuntimeException if e.getMessage.contains("hadoop") =>
            // If the error message contains hadoop, it is probably because the hadoop
            // version cannot be resolved.
            logWarning(s"Failed to resolve Hadoop artifacts for the version $hadoopVersion. " +
              s"We will change the hadoop version from $hadoopVersion to 2.6.0 and try again. " +
              "Hadoop classes will not be shared between Spark and Hive metastore client. " +
              "It is recommended to set jars used by Hive metastore client through " +
              "spark.sql.hive.metastore.jars in the production environment.")
            _sharesHadoopClasses = false
            (downloadVersion(resolvedVersion, "2.6.5", ivyPath), "2.6.5")
        }
      resolvedVersions.put((resolvedVersion, actualHadoopVersion), downloadedFiles)
      resolvedVersions((resolvedVersion, actualHadoopVersion))
    }

    new IsolatedClientLoader(
      hiveVersion(hiveMetastoreVersion),
      sparkConf,
      execJars = files,
      hadoopConf = hadoopConf,
      config = config,
      sharesHadoopClasses = _sharesHadoopClasses,
      sharedPrefixes = sharedPrefixes,
      barrierPrefixes = barrierPrefixes)
  }

  def hiveVersion(version: String): HiveVersion = version match {
    case "12" | "0.12" | "0.12.0" => hive.v12
    case "13" | "0.13" | "0.13.0" | "0.13.1" => hive.v13
    case "14" | "0.14" | "0.14.0" => hive.v14
    case "1.0" | "1.0.0" => hive.v1_0
    case "1.1" | "1.1.0" => hive.v1_1
    case "1.2" | "1.2.0" | "1.2.1" | "1.2.2" => hive.v1_2
    case "2.0" | "2.0.0" | "2.0.1" => hive.v2_0
    case "2.1" | "2.1.0" | "2.1.1" => hive.v2_1
    case "2.2" | "2.2.0" => hive.v2_2
    case "2.3" | "2.3.0" | "2.3.1" | "2.3.2" | "2.3.3" => hive.v2_3
  }

  private def downloadVersion(
      version: HiveVersion,
      hadoopVersion: String,
      ivyPath: Option[String]): Seq[URL] = {
    val hiveArtifacts = version.extraDeps ++
      Seq("hive-metastore", "hive-exec", "hive-common", "hive-serde")
        .map(a => s"org.apache.hive:$a:${version.fullVersion}") ++
      Seq("com.google.guava:guava:14.0.1",
        s"org.apache.hadoop:hadoop-client:$hadoopVersion")

    val classpath = quietly {
      SparkSubmitUtils.resolveMavenCoordinates(
        hiveArtifacts.mkString(","),
        SparkSubmitUtils.buildIvySettings(
          Some("http://www.datanucleus.org/downloads/maven2"),
          ivyPath),
        exclusions = version.exclusions)
    }
    val allFiles = classpath.split(",").map(new File(_)).toSet

    // TODO: Remove copy logic.
    val tempDir = Utils.createTempDir(namePrefix = s"hive-${version}")
    allFiles.foreach(f => FileUtils.copyFileToDirectory(f, tempDir))
    logInfo(s"Downloaded metastore jars to ${tempDir.getCanonicalPath}")
    tempDir.listFiles().map(_.toURI.toURL)
  }

  // A map from a given pair of HiveVersion and Hadoop version to jar files.
  // It is only used by forVersion.
  private val resolvedVersions =
    new scala.collection.mutable.HashMap[(HiveVersion, String), Seq[URL]]
}

/**
 * Creates a [[HiveClient]] using a classloader that works according to the following rules:
 *  - Shared classes: Java, Scala, logging, and Spark classes are delegated to `baseClassLoader`
 *    allowing the results of calls to the [[HiveClient]] to be visible externally.
 *  - Hive classes: new instances are loaded from `execJars`.  These classes are not
 *    accessible externally due to their custom loading.
 *  - [[HiveClientImpl]]: a new copy is created for each instance of `IsolatedClassLoader`.
 *    This new instance is able to see a specific version of hive without using reflection. Since
 *    this is a unique instance, it is not visible externally other than as a generic
 *    [[HiveClient]], unless `isolationOn` is set to `false`.
 *
 * @param version The version of hive on the classpath.  used to pick specific function signatures
 *                that are not compatible across versions.
 * @param execJars A collection of jar files that must include hive and hadoop.
 * @param config   A set of options that will be added to the HiveConf of the constructed client.
 * @param isolationOn When true, custom versions of barrier classes will be constructed.  Must be
 *                    true unless loading the version of hive that is on Sparks classloader.
 * @param sharesHadoopClasses When true, we will share Hadoop classes between Spark and
 * @param rootClassLoader The system root classloader. Must not know about Hive classes.
 * @param baseClassLoader The spark classloader that is used to load shared classes.
 */
private[hive] class IsolatedClientLoader(
    val version: HiveVersion,
    val sparkConf: SparkConf,
    val hadoopConf: Configuration,
    val execJars: Seq[URL] = Seq.empty,
    val config: Map[String, String] = Map.empty,
    val isolationOn: Boolean = true,
    val sharesHadoopClasses: Boolean = true,
    val rootClassLoader: ClassLoader = ClassLoader.getSystemClassLoader.getParent.getParent,
    val baseClassLoader: ClassLoader = Thread.currentThread().getContextClassLoader,
    val sharedPrefixes: Seq[String] = Seq.empty,
    val barrierPrefixes: Seq[String] = Seq.empty)
  extends Logging {

  // Check to make sure that the root classloader does not know about Hive.
  assert(Try(rootClassLoader.loadClass("org.apache.hadoop.hive.conf.HiveConf")).isFailure)

  /** All jars used by the hive specific classloader. */
  protected def allJars = execJars.toArray

  protected def isSharedClass(name: String): Boolean = {
    val isHadoopClass =
      name.startsWith("org.apache.hadoop.") && !name.startsWith("org.apache.hadoop.hive.")

    name.startsWith("org.slf4j") ||
    name.startsWith("org.apache.log4j") || // log4j1.x
    name.startsWith("org.apache.logging.log4j") || // log4j2
    name.startsWith("org.apache.spark.") ||
    (sharesHadoopClasses && isHadoopClass) ||
    name.startsWith("scala.") ||
    (name.startsWith("com.google") && !name.startsWith("com.google.cloud")) ||
    name.startsWith("java.lang.") ||
    name.startsWith("java.net") ||
    sharedPrefixes.exists(name.startsWith)
  }

  /** True if `name` refers to a spark class that must see specific version of Hive. */
  protected def isBarrierClass(name: String): Boolean =
    name.startsWith(classOf[HiveClientImpl].getName) ||
    name.startsWith(classOf[Shim].getName) ||
    barrierPrefixes.exists(name.startsWith)

  protected def classToPath(name: String): String =
    name.replaceAll("\\.", "/") + ".class"

  /**
   * The classloader that is used to load an isolated version of Hive.
   * This classloader is a special URLClassLoader that exposes the addURL method.
   * So, when we add jar, we can add this new jar directly through the addURL method
   * instead of stacking a new URLClassLoader on top of it.
   */
  private[hive] val classLoader: MutableURLClassLoader = {
    val isolatedClassLoader =
      if (isolationOn) {
        new URLClassLoader(allJars, rootClassLoader) {
          override def loadClass(name: String, resolve: Boolean): Class[_] = {
            val loaded = findLoadedClass(name)
            if (loaded == null) doLoadClass(name, resolve) else loaded
          }
          def doLoadClass(name: String, resolve: Boolean): Class[_] = {
            val classFileName = name.replaceAll("\\.", "/") + ".class"
            if (isBarrierClass(name)) {
              // For barrier classes, we construct a new copy of the class.
              val bytes = IOUtils.toByteArray(baseClassLoader.getResourceAsStream(classFileName))
              logDebug(s"custom defining: $name - ${util.Arrays.hashCode(bytes)}")
              defineClass(name, bytes, 0, bytes.length)
            } else if (!isSharedClass(name)) {
              logDebug(s"hive class: $name - ${getResource(classToPath(name))}")
              super.loadClass(name, resolve)
            } else {
              // For shared classes, we delegate to baseClassLoader, but fall back in case the
              // class is not found.
              logDebug(s"shared class: $name")
              try {
                baseClassLoader.loadClass(name)
              } catch {
                case _: ClassNotFoundException =>
                  super.loadClass(name, resolve)
              }
            }
          }
        }
      } else {
        baseClassLoader
      }
    // Right now, we create a URLClassLoader that gives preference to isolatedClassLoader
    // over its own URLs when it loads classes and resources.
    // We may want to use ChildFirstURLClassLoader based on
    // the configuration of spark.executor.userClassPathFirst, which gives preference
    // to its own URLs over the parent class loader (see Executor's createClassLoader method).
    new NonClosableMutableURLClassLoader(isolatedClassLoader)
  }

  private[hive] def addJar(path: URL): Unit = synchronized {
    classLoader.addURL(path)
  }

  /** The isolated client interface to Hive. */
  private[hive] def createClient(): HiveClient = synchronized {
    val warehouseDir = Option(hadoopConf.get(ConfVars.METASTOREWAREHOUSE.varname))
    if (!isolationOn) {
      return new HiveClientImpl(version, warehouseDir, sparkConf, hadoopConf, config,
        baseClassLoader, this)
    }
    // Pre-reflective instantiation setup.
    logDebug("Initializing the logger to avoid disaster...")
    val origLoader = Thread.currentThread().getContextClassLoader
    Thread.currentThread.setContextClassLoader(classLoader)

    try {
      classLoader
        .loadClass(classOf[HiveClientImpl].getName)
        .getConstructors.head
        .newInstance(version, warehouseDir, sparkConf, hadoopConf, config, classLoader, this)
        .asInstanceOf[HiveClient]
    } catch {
      case e: InvocationTargetException =>
        if (e.getCause().isInstanceOf[NoClassDefFoundError]) {
          val cnf = e.getCause().asInstanceOf[NoClassDefFoundError]
          throw new ClassNotFoundException(
            s"$cnf when creating Hive client using classpath: ${execJars.mkString(", ")}\n" +
            "Please make sure that jars for your version of hive and hadoop are included in the " +
            s"paths passed to ${HiveUtils.HIVE_METASTORE_JARS.key}.", e)
        } else {
          throw e
        }
    } finally {
      Thread.currentThread.setContextClassLoader(origLoader)
    }
  }

  /**
   * The place holder for shared Hive client for all the HiveContext sessions (they share an
   * IsolatedClientLoader).
   */
  private[hive] var cachedHive: Any = null
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

package org.apache.spark.sql.hive.orc

import java.net.URI
import java.util.Properties

import scala.collection.JavaConverters._

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.{FileStatus, Path}
import org.apache.hadoop.hive.conf.HiveConf.ConfVars
import org.apache.hadoop.hive.ql.io.orc._
import org.apache.hadoop.hive.serde2.objectinspector.{SettableStructObjectInspector, StructObjectInspector}
import org.apache.hadoop.hive.serde2.typeinfo.{StructTypeInfo, TypeInfoUtils}
import org.apache.hadoop.io.{NullWritable, Writable}
import org.apache.hadoop.mapred.{JobConf, OutputFormat => MapRedOutputFormat, RecordWriter, Reporter}
import org.apache.hadoop.mapreduce._
import org.apache.hadoop.mapreduce.lib.input.{FileInputFormat, FileSplit}
import org.apache.orc.OrcConf.COMPRESS

import org.apache.spark.TaskContext
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.execution.datasources._
import org.apache.spark.sql.execution.datasources.orc.OrcOptions
import org.apache.spark.sql.hive.{HiveInspectors, HiveShim}
import org.apache.spark.sql.sources.{Filter, _}
import org.apache.spark.sql.types._
import org.apache.spark.util.SerializableConfiguration

/**
 * `FileFormat` for reading ORC files. If this is moved or renamed, please update
 * `DataSource`'s backwardCompatibilityMap.
 */
class OrcFileFormat extends FileFormat with DataSourceRegister with Serializable {

  override def shortName(): String = "orc"

  override def toString: String = "ORC"

  override def inferSchema(
      sparkSession: SparkSession,
      options: Map[String, String],
      files: Seq[FileStatus]): Option[StructType] = {
    val ignoreCorruptFiles = sparkSession.sessionState.conf.ignoreCorruptFiles
    OrcFileOperator.readSchema(
      files.map(_.getPath.toString),
      Some(sparkSession.sessionState.newHadoopConf()),
      ignoreCorruptFiles
    )
  }

  override def prepareWrite(
      sparkSession: SparkSession,
      job: Job,
      options: Map[String, String],
      dataSchema: StructType): OutputWriterFactory = {

    val orcOptions = new OrcOptions(options, sparkSession.sessionState.conf)

    val configuration = job.getConfiguration

    configuration.set(COMPRESS.getAttribute, orcOptions.compressionCodec)
    configuration match {
      case conf: JobConf =>
        conf.setOutputFormat(classOf[OrcOutputFormat])
      case conf =>
        conf.setClass(
          "mapred.output.format.class",
          classOf[OrcOutputFormat],
          classOf[MapRedOutputFormat[_, _]])
    }

    new OutputWriterFactory {
      override def newInstance(
          path: String,
          dataSchema: StructType,
          context: TaskAttemptContext): OutputWriter = {
        new OrcOutputWriter(path, dataSchema, context)
      }

      override def getFileExtension(context: TaskAttemptContext): String = {
        val compressionExtension: String = {
          val name = context.getConfiguration.get(COMPRESS.getAttribute)
          OrcFileFormat.extensionsForCompressionCodecNames.getOrElse(name, "")
        }

        compressionExtension + ".orc"
      }
    }
  }

  override def isSplitable(
      sparkSession: SparkSession,
      options: Map[String, String],
      path: Path): Boolean = {
    true
  }

  override def buildReader(
      sparkSession: SparkSession,
      dataSchema: StructType,
      partitionSchema: StructType,
      requiredSchema: StructType,
      filters: Seq[Filter],
      options: Map[String, String],
      hadoopConf: Configuration): (PartitionedFile) => Iterator[InternalRow] = {

    if (sparkSession.sessionState.conf.orcFilterPushDown) {
      // Sets pushed predicates
      OrcFilters.createFilter(requiredSchema, filters.toArray).foreach { f =>
        hadoopConf.set(OrcFileFormat.SARG_PUSHDOWN, f.toKryo)
        hadoopConf.setBoolean(ConfVars.HIVEOPTINDEXFILTER.varname, true)
      }
    }

    val broadcastedHadoopConf =
      sparkSession.sparkContext.broadcast(new SerializableConfiguration(hadoopConf))
    val ignoreCorruptFiles = sparkSession.sessionState.conf.ignoreCorruptFiles

    (file: PartitionedFile) => {
      val conf = broadcastedHadoopConf.value.value

      val filePath = new Path(new URI(file.filePath))

      // SPARK-8501: Empty ORC files always have an empty schema stored in their footer. In this
      // case, `OrcFileOperator.readSchema` returns `None`, and we can't read the underlying file
      // using the given physical schema. Instead, we simply return an empty iterator.
      val isEmptyFile =
        OrcFileOperator.readSchema(Seq(filePath.toString), Some(conf), ignoreCorruptFiles).isEmpty
      if (isEmptyFile) {
        Iterator.empty
      } else {
        OrcFileFormat.setRequiredColumns(conf, dataSchema, requiredSchema)

        val orcRecordReader = {
          val job = Job.getInstance(conf)
          FileInputFormat.setInputPaths(job, file.filePath)

          val fileSplit = new FileSplit(filePath, file.start, file.length, Array.empty)
          // Custom OrcRecordReader is used to get
          // ObjectInspector during recordReader creation itself and can
          // avoid NameNode call in unwrapOrcStructs per file.
          // Specifically would be helpful for partitioned datasets.
          val orcReader = OrcFile.createReader(filePath, OrcFile.readerOptions(conf))
          new SparkOrcNewRecordReader(orcReader, conf, fileSplit.getStart, fileSplit.getLength)
        }

        val recordsIterator = new RecordReaderIterator[OrcStruct](orcRecordReader)
        Option(TaskContext.get())
          .foreach(_.addTaskCompletionListener[Unit](_ => recordsIterator.close()))

        // Unwraps `OrcStruct`s to `UnsafeRow`s
        OrcFileFormat.unwrapOrcStructs(
          conf,
          dataSchema,
          requiredSchema,
          Some(orcRecordReader.getObjectInspector.asInstanceOf[StructObjectInspector]),
          recordsIterator)
      }
    }
  }

  override def supportDataType(dataType: DataType, isReadPath: Boolean): Boolean = dataType match {
    case _: AtomicType => true

    case st: StructType => st.forall { f => supportDataType(f.dataType, isReadPath) }

    case ArrayType(elementType, _) => supportDataType(elementType, isReadPath)

    case MapType(keyType, valueType, _) =>
      supportDataType(keyType, isReadPath) && supportDataType(valueType, isReadPath)

    case udt: UserDefinedType[_] => supportDataType(udt.sqlType, isReadPath)

    case _: NullType => isReadPath

    case _ => false
  }
}

private[orc] class OrcSerializer(dataSchema: StructType, conf: Configuration)
  extends HiveInspectors {

  def serialize(row: InternalRow): Writable = {
    wrapOrcStruct(cachedOrcStruct, structOI, row)
    serializer.serialize(cachedOrcStruct, structOI)
  }

  private[this] val serializer = {
    val table = new Properties()
    table.setProperty("columns", dataSchema.fieldNames.mkString(","))
    table.setProperty("columns.types", dataSchema.map(_.dataType.catalogString).mkString(":"))

    val serde = new OrcSerde
    serde.initialize(conf, table)
    serde
  }

  // Object inspector converted from the schema of the relation to be serialized.
  private[this] val structOI = {
    val typeInfo = TypeInfoUtils.getTypeInfoFromTypeString(dataSchema.catalogString)
    OrcStruct.createObjectInspector(typeInfo.asInstanceOf[StructTypeInfo])
      .asInstanceOf[SettableStructObjectInspector]
  }

  private[this] val cachedOrcStruct = structOI.create().asInstanceOf[OrcStruct]

  // Wrapper functions used to wrap Spark SQL input arguments into Hive specific format
  private[this] val wrappers = dataSchema.zip(structOI.getAllStructFieldRefs().asScala.toSeq).map {
    case (f, i) => wrapperFor(i.getFieldObjectInspector, f.dataType)
  }

  private[this] def wrapOrcStruct(
      struct: OrcStruct,
      oi: SettableStructObjectInspector,
      row: InternalRow): Unit = {
    val fieldRefs = oi.getAllStructFieldRefs
    var i = 0
    val size = fieldRefs.size
    while (i < size) {

      oi.setStructFieldData(
        struct,
        fieldRefs.get(i),
        wrappers(i)(row.get(i, dataSchema(i).dataType))
      )
      i += 1
    }
  }
}

private[orc] class OrcOutputWriter(
    path: String,
    dataSchema: StructType,
    context: TaskAttemptContext)
  extends OutputWriter {

  private[this] val serializer = new OrcSerializer(dataSchema, context.getConfiguration)

  // `OrcRecordWriter.close()` creates an empty file if no rows are written at all.  We use this
  // flag to decide whether `OrcRecordWriter.close()` needs to be called.
  private var recordWriterInstantiated = false

  private lazy val recordWriter: RecordWriter[NullWritable, Writable] = {
    recordWriterInstantiated = true
    new OrcOutputFormat().getRecordWriter(
      new Path(path).getFileSystem(context.getConfiguration),
      context.getConfiguration.asInstanceOf[JobConf],
      path,
      Reporter.NULL
    ).asInstanceOf[RecordWriter[NullWritable, Writable]]
  }

  override def write(row: InternalRow): Unit = {
    recordWriter.write(NullWritable.get(), serializer.serialize(row))
  }

  override def close(): Unit = {
    if (recordWriterInstantiated) {
      recordWriter.close(Reporter.NULL)
    }
  }
}

private[orc] object OrcFileFormat extends HiveInspectors {
  // This constant duplicates `OrcInputFormat.SARG_PUSHDOWN`, which is unfortunately not public.
  private[orc] val SARG_PUSHDOWN = "sarg.pushdown"

  // The extensions for ORC compression codecs
  val extensionsForCompressionCodecNames = Map(
    "NONE" -> "",
    "SNAPPY" -> ".snappy",
    "ZLIB" -> ".zlib",
    "LZO" -> ".lzo")

  def unwrapOrcStructs(
      conf: Configuration,
      dataSchema: StructType,
      requiredSchema: StructType,
      maybeStructOI: Option[StructObjectInspector],
      iterator: Iterator[Writable]): Iterator[InternalRow] = {
    val deserializer = new OrcSerde
    val mutableRow = new SpecificInternalRow(requiredSchema.map(_.dataType))
    val unsafeProjection = UnsafeProjection.create(requiredSchema)

    def unwrap(oi: StructObjectInspector): Iterator[InternalRow] = {
      val (fieldRefs, fieldOrdinals) = requiredSchema.zipWithIndex.map {
        case (field, ordinal) =>
          var ref = oi.getStructFieldRef(field.name)
          if (ref == null) {
            ref = oi.getStructFieldRef("_col" + dataSchema.fieldIndex(field.name))
          }
          ref -> ordinal
      }.unzip

      val unwrappers = fieldRefs.map(r => if (r == null) null else unwrapperFor(r))

      iterator.map { value =>
        val raw = deserializer.deserialize(value)
        var i = 0
        val length = fieldRefs.length
        while (i < length) {
          val fieldRef = fieldRefs(i)
          val fieldValue = if (fieldRef == null) null else oi.getStructFieldData(raw, fieldRef)
          if (fieldValue == null) {
            mutableRow.setNullAt(fieldOrdinals(i))
          } else {
            unwrappers(i)(fieldValue, mutableRow, fieldOrdinals(i))
          }
          i += 1
        }
        unsafeProjection(mutableRow)
      }
    }

    maybeStructOI.map(unwrap).getOrElse(Iterator.empty)
  }

  def setRequiredColumns(
      conf: Configuration, dataSchema: StructType, requestedSchema: StructType): Unit = {
    val ids = requestedSchema.map(a => dataSchema.fieldIndex(a.name): Integer)
    val (sortedIDs, sortedNames) = ids.zip(requestedSchema.fieldNames).sorted.unzip
    HiveShim.appendReadColumns(conf, sortedIDs, sortedNames)
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

package org.apache.spark.sql.hive.orc

import java.io.IOException

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path
import org.apache.hadoop.hive.ql.io.orc.{OrcFile, Reader}
import org.apache.hadoop.hive.serde2.objectinspector.StructObjectInspector

import org.apache.spark.SparkException
import org.apache.spark.deploy.SparkHadoopUtil
import org.apache.spark.internal.Logging
import org.apache.spark.sql.catalyst.parser.CatalystSqlParser
import org.apache.spark.sql.types.StructType

private[hive] object OrcFileOperator extends Logging {
  /**
   * Retrieves an ORC file reader from a given path.  The path can point to either a directory or a
   * single ORC file.  If it points to a directory, it picks any non-empty ORC file within that
   * directory.
   *
   * The reader returned by this method is mainly used for two purposes:
   *
   * 1. Retrieving file metadata (schema and compression codecs, etc.)
   * 2. Read the actual file content (in this case, the given path should point to the target file)
   *
   * @note As recorded by SPARK-8501, ORC writes an empty schema (<code>struct&lt;&gt;</code>) to an
   *       ORC file if the file contains zero rows. This is OK for Hive since the schema of the
   *       table is managed by metastore.  But this becomes a problem when reading ORC files
   *       directly from HDFS via Spark SQL, because we have to discover the schema from raw ORC
   *       files. So this method always tries to find an ORC file whose schema is non-empty, and
   *       create the result reader from that file.  If no such file is found, it returns `None`.
   * @todo Needs to consider all files when schema evolution is taken into account.
   */
  def getFileReader(basePath: String,
      config: Option[Configuration] = None,
      ignoreCorruptFiles: Boolean = false)
      : Option[Reader] = {
    def isWithNonEmptySchema(path: Path, reader: Reader): Boolean = {
      reader.getObjectInspector match {
        case oi: StructObjectInspector if oi.getAllStructFieldRefs.size() == 0 =>
          logInfo(
            s"ORC file $path has empty schema, it probably contains no rows. " +
              "Trying to read another ORC file to figure out the schema.")
          false
        case _ => true
      }
    }

    val conf = config.getOrElse(new Configuration)
    val fs = {
      val hdfsPath = new Path(basePath)
      hdfsPath.getFileSystem(conf)
    }

    listOrcFiles(basePath, conf).iterator.map { path =>
      val reader = try {
        Some(OrcFile.createReader(fs, path))
      } catch {
        case e: IOException =>
          if (ignoreCorruptFiles) {
            logWarning(s"Skipped the footer in the corrupted file: $path", e)
            None
          } else {
            throw new SparkException(s"Could not read footer for file: $path", e)
          }
      }
      path -> reader
    }.collectFirst {
      case (path, Some(reader)) if isWithNonEmptySchema(path, reader) => reader
    }
  }

  def readSchema(paths: Seq[String], conf: Option[Configuration], ignoreCorruptFiles: Boolean)
      : Option[StructType] = {
    // Take the first file where we can open a valid reader if we can find one.  Otherwise just
    // return None to indicate we can't infer the schema.
    paths.toIterator.map(getFileReader(_, conf, ignoreCorruptFiles)).collectFirst {
      case Some(reader) =>
        val readerInspector = reader.getObjectInspector.asInstanceOf[StructObjectInspector]
        val schema = readerInspector.getTypeName
        logDebug(s"Reading schema from file $paths, got Hive schema string: $schema")
        CatalystSqlParser.parseDataType(schema).asInstanceOf[StructType]
    }
  }

  def getObjectInspector(
      path: String, conf: Option[Configuration]): Option[StructObjectInspector] = {
    getFileReader(path, conf).map(_.getObjectInspector.asInstanceOf[StructObjectInspector])
  }

  def listOrcFiles(pathStr: String, conf: Configuration): Seq[Path] = {
    // TODO: Check if the paths coming in are already qualified and simplify.
    val origPath = new Path(pathStr)
    val fs = origPath.getFileSystem(conf)
    val paths = SparkHadoopUtil.get.listLeafStatuses(fs, origPath)
      .filterNot(_.isDirectory)
      .map(_.getPath)
      .filterNot(_.getName.startsWith("_"))
      .filterNot(_.getName.startsWith("."))
    paths
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

package org.apache.spark.sql.hive.orc

import org.apache.hadoop.hive.ql.io.sarg.SearchArgument
import org.apache.hadoop.hive.ql.io.sarg.SearchArgument.Builder
import org.apache.hadoop.hive.ql.io.sarg.SearchArgumentFactory.newBuilder

import org.apache.spark.internal.Logging
import org.apache.spark.sql.execution.datasources.orc.OrcFilters.buildTree
import org.apache.spark.sql.sources._
import org.apache.spark.sql.types._

/**
 * Helper object for building ORC `SearchArgument`s, which are used for ORC predicate push-down.
 *
 * Due to limitation of ORC `SearchArgument` builder, we had to end up with a pretty weird double-
 * checking pattern when converting `And`/`Or`/`Not` filters.
 *
 * An ORC `SearchArgument` must be built in one pass using a single builder.  For example, you can't
 * build `a = 1` and `b = 2` first, and then combine them into `a = 1 AND b = 2`.  This is quite
 * different from the cases in Spark SQL or Parquet, where complex filters can be easily built using
 * existing simpler ones.
 *
 * The annoying part is that, `SearchArgument` builder methods like `startAnd()`, `startOr()`, and
 * `startNot()` mutate internal state of the builder instance.  This forces us to translate all
 * convertible filters with a single builder instance. However, before actually converting a filter,
 * we've no idea whether it can be recognized by ORC or not. Thus, when an inconvertible filter is
 * found, we may already end up with a builder whose internal state is inconsistent.
 *
 * For example, to convert an `And` filter with builder `b`, we call `b.startAnd()` first, and then
 * try to convert its children.  Say we convert `left` child successfully, but find that `right`
 * child is inconvertible.  Alas, `b.startAnd()` call can't be rolled back, and `b` is inconsistent
 * now.
 *
 * The workaround employed here is that, for `And`/`Or`/`Not`, we first try to convert their
 * children with brand new builders, and only do the actual conversion with the right builder
 * instance when the children are proven to be convertible.
 *
 * P.S.: Hive seems to use `SearchArgument` together with `ExprNodeGenericFuncDesc` only.  Usage of
 * builder methods mentioned above can only be found in test code, where all tested filters are
 * known to be convertible.
 */
private[orc] object OrcFilters extends Logging {
  def createFilter(schema: StructType, filters: Array[Filter]): Option[SearchArgument] = {
    val dataTypeMap = schema.map(f => f.name -> f.dataType).toMap

    // First, tries to convert each filter individually to see whether it's convertible, and then
    // collect all convertible ones to build the final `SearchArgument`.
    val convertibleFilters = for {
      filter <- filters
      _ <- buildSearchArgument(dataTypeMap, filter, newBuilder)
    } yield filter

    for {
      // Combines all convertible filters using `And` to produce a single conjunction
      conjunction <- buildTree(convertibleFilters)
      // Then tries to build a single ORC `SearchArgument` for the conjunction predicate
      builder <- buildSearchArgument(dataTypeMap, conjunction, newBuilder)
    } yield builder.build()
  }

  private def buildSearchArgument(
      dataTypeMap: Map[String, DataType],
      expression: Filter,
      builder: Builder): Option[Builder] = {
    def isSearchableType(dataType: DataType): Boolean = dataType match {
      // Only the values in the Spark types below can be recognized by
      // the `SearchArgumentImpl.BuilderImpl.boxLiteral()` method.
      case ByteType | ShortType | FloatType | DoubleType => true
      case IntegerType | LongType | StringType | BooleanType => true
      case TimestampType | _: DecimalType => true
      case _ => false
    }

    expression match {
      case And(left, right) =>
        // At here, it is not safe to just convert one side if we do not understand the
        // other side. Here is an example used to explain the reason.
        // Let's say we have NOT(a = 2 AND b in ('1')) and we do not understand how to
        // convert b in ('1'). If we only convert a = 2, we will end up with a filter
        // NOT(a = 2), which will generate wrong results.
        // Pushing one side of AND down is only safe to do at the top level.
        // You can see ParquetRelation's initializeLocalJobFunc method as an example.
        for {
          _ <- buildSearchArgument(dataTypeMap, left, newBuilder)
          _ <- buildSearchArgument(dataTypeMap, right, newBuilder)
          lhs <- buildSearchArgument(dataTypeMap, left, builder.startAnd())
          rhs <- buildSearchArgument(dataTypeMap, right, lhs)
        } yield rhs.end()

      case Or(left, right) =>
        for {
          _ <- buildSearchArgument(dataTypeMap, left, newBuilder)
          _ <- buildSearchArgument(dataTypeMap, right, newBuilder)
          lhs <- buildSearchArgument(dataTypeMap, left, builder.startOr())
          rhs <- buildSearchArgument(dataTypeMap, right, lhs)
        } yield rhs.end()

      case Not(child) =>
        for {
          _ <- buildSearchArgument(dataTypeMap, child, newBuilder)
          negate <- buildSearchArgument(dataTypeMap, child, builder.startNot())
        } yield negate.end()

      // NOTE: For all case branches dealing with leaf predicates below, the additional `startAnd()`
      // call is mandatory.  ORC `SearchArgument` builder requires that all leaf predicates must be
      // wrapped by a "parent" predicate (`And`, `Or`, or `Not`).

      case EqualTo(attribute, value) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startAnd().equals(attribute, value).end())

      case EqualNullSafe(attribute, value) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startAnd().nullSafeEquals(attribute, value).end())

      case LessThan(attribute, value) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startAnd().lessThan(attribute, value).end())

      case LessThanOrEqual(attribute, value) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startAnd().lessThanEquals(attribute, value).end())

      case GreaterThan(attribute, value) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startNot().lessThanEquals(attribute, value).end())

      case GreaterThanOrEqual(attribute, value) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startNot().lessThan(attribute, value).end())

      case IsNull(attribute) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startAnd().isNull(attribute).end())

      case IsNotNull(attribute) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startNot().isNull(attribute).end())

      case In(attribute, values) if isSearchableType(dataTypeMap(attribute)) =>
        Some(builder.startAnd().in(attribute, values.map(_.asInstanceOf[AnyRef]): _*).end())

      case _ => None
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

package org.apache.spark.sql

/**
 * Support for running Spark SQL queries using functionality from Apache Hive (does not require an
 * existing Hive installation).  Supported Hive features include:
 *  - Using HiveQL to express queries.
 *  - Reading metadata from the Hive Metastore using HiveSerDes.
 *  - Hive UDFs, UDAs, UDTs
 *
 * Users that would like access to this functionality should create a
 * [[hive.HiveContext HiveContext]] instead of a [[SQLContext]].
 */
package object hive
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

package org.apache.spark.sql.hive

/** Support for interacting with different versions of the HiveMetastoreClient */
package object client {
  private[hive] sealed abstract class HiveVersion(
      val fullVersion: String,
      val extraDeps: Seq[String] = Nil,
      val exclusions: Seq[String] = Nil)

  // scalastyle:off
  private[hive] object hive {
    case object v12 extends HiveVersion("0.12.0")
    case object v13 extends HiveVersion("0.13.1")

    // Hive 0.14 depends on calcite 0.9.2-incubating-SNAPSHOT which does not exist in
    // maven central anymore, so override those with a version that exists.
    //
    // The other excluded dependencies are also nowhere to be found, so exclude them explicitly. If
    // they're needed by the metastore client, users will have to dig them out of somewhere and use
    // configuration to point Spark at the correct jars.
    case object v14 extends HiveVersion("0.14.0",
      extraDeps = Seq("org.apache.calcite:calcite-core:1.3.0-incubating",
        "org.apache.calcite:calcite-avatica:1.3.0-incubating"),
      exclusions = Seq("org.pentaho:pentaho-aggdesigner-algorithm"))

    case object v1_0 extends HiveVersion("1.0.0",
      exclusions = Seq("eigenbase:eigenbase-properties",
        "org.pentaho:pentaho-aggdesigner-algorithm",
        "net.hydromatic:linq4j",
        "net.hydromatic:quidem"))

    // The curator dependency was added to the exclusions here because it seems to confuse the ivy
    // library. org.apache.curator:curator is a pom dependency but ivy tries to find the jar for it,
    // and fails.
    case object v1_1 extends HiveVersion("1.1.0",
      exclusions = Seq("eigenbase:eigenbase-properties",
        "org.apache.curator:*",
        "org.pentaho:pentaho-aggdesigner-algorithm",
        "net.hydromatic:linq4j",
        "net.hydromatic:quidem"))

    case object v1_2 extends HiveVersion("1.2.2",
      exclusions = Seq("eigenbase:eigenbase-properties",
        "org.apache.curator:*",
        "org.pentaho:pentaho-aggdesigner-algorithm",
        "net.hydromatic:linq4j",
        "net.hydromatic:quidem"))

    case object v2_0 extends HiveVersion("2.0.1",
      exclusions = Seq("org.apache.curator:*",
        "org.pentaho:pentaho-aggdesigner-algorithm"))

    case object v2_1 extends HiveVersion("2.1.1",
      exclusions = Seq("org.apache.curator:*",
        "org.pentaho:pentaho-aggdesigner-algorithm"))

    case object v2_2 extends HiveVersion("2.2.0",
      exclusions = Seq("org.apache.curator:*",
        "org.pentaho:pentaho-aggdesigner-algorithm"))

    case object v2_3 extends HiveVersion("2.3.3",
      exclusions = Seq("org.apache.curator:*",
        "org.pentaho:pentaho-aggdesigner-algorithm"))

    val allSupportedHiveVersions = Set(v12, v13, v14, v1_0, v1_1, v1_2, v2_0, v2_1, v2_2, v2_3)
  }
  // scalastyle:on

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

package org.apache.spark.sql.hive.execution

import java.io.{File, IOException}
import java.net.URI
import java.text.SimpleDateFormat
import java.util.{Date, Locale, Random}

import scala.util.control.NonFatal

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.{FileSystem, Path}
import org.apache.hadoop.hive.common.FileUtils
import org.apache.hadoop.hive.ql.exec.TaskRunner

import org.apache.spark.internal.io.FileCommitProtocol
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.catalog.CatalogTypes.TablePartitionSpec
import org.apache.spark.sql.catalyst.expressions.Attribute
import org.apache.spark.sql.execution.SparkPlan
import org.apache.spark.sql.execution.command.DataWritingCommand
import org.apache.spark.sql.execution.datasources.FileFormatWriter
import org.apache.spark.sql.hive.HiveExternalCatalog
import org.apache.spark.sql.hive.HiveShim.{ShimFileSinkDesc => FileSinkDesc}
import org.apache.spark.sql.hive.client.HiveVersion

// Base trait from which all hive insert statement physical execution extends.
private[hive] trait SaveAsHiveFile extends DataWritingCommand {

  var createdTempDir: Option[Path] = None

  protected def saveAsHiveFile(
      sparkSession: SparkSession,
      plan: SparkPlan,
      hadoopConf: Configuration,
      fileSinkConf: FileSinkDesc,
      outputLocation: String,
      customPartitionLocations: Map[TablePartitionSpec, String] = Map.empty,
      partitionAttributes: Seq[Attribute] = Nil): Set[String] = {

    val isCompressed =
      fileSinkConf.getTableInfo.getOutputFileFormatClassName.toLowerCase(Locale.ROOT) match {
        case formatName if formatName.endsWith("orcoutputformat") =>
          // For ORC,"mapreduce.output.fileoutputformat.compress",
          // "mapreduce.output.fileoutputformat.compress.codec", and
          // "mapreduce.output.fileoutputformat.compress.type"
          // have no impact because it uses table properties to store compression information.
          false
        case _ => hadoopConf.get("hive.exec.compress.output", "false").toBoolean
    }

    if (isCompressed) {
      hadoopConf.set("mapreduce.output.fileoutputformat.compress", "true")
      fileSinkConf.setCompressed(true)
      fileSinkConf.setCompressCodec(hadoopConf
        .get("mapreduce.output.fileoutputformat.compress.codec"))
      fileSinkConf.setCompressType(hadoopConf
        .get("mapreduce.output.fileoutputformat.compress.type"))
    } else {
      // Set compression by priority
      HiveOptions.getHiveWriteCompression(fileSinkConf.getTableInfo, sparkSession.sessionState.conf)
        .foreach { case (compression, codec) => hadoopConf.set(compression, codec) }
    }

    val committer = FileCommitProtocol.instantiate(
      sparkSession.sessionState.conf.fileCommitProtocolClass,
      jobId = java.util.UUID.randomUUID().toString,
      outputPath = outputLocation)

    FileFormatWriter.write(
      sparkSession = sparkSession,
      plan = plan,
      fileFormat = new HiveFileFormat(fileSinkConf),
      committer = committer,
      outputSpec =
        FileFormatWriter.OutputSpec(outputLocation, customPartitionLocations, outputColumns),
      hadoopConf = hadoopConf,
      partitionColumns = partitionAttributes,
      bucketSpec = None,
      statsTrackers = Seq(basicWriteJobStatsTracker(hadoopConf)),
      options = Map.empty)
  }

  protected def getExternalTmpPath(
      sparkSession: SparkSession,
      hadoopConf: Configuration,
      path: Path): Path = {
    import org.apache.spark.sql.hive.client.hive._

    // Before Hive 1.1, when inserting into a table, Hive will create the staging directory under
    // a common scratch directory. After the writing is finished, Hive will simply empty the table
    // directory and move the staging directory to it.
    // After Hive 1.1, Hive will create the staging directory under the table directory, and when
    // moving staging directory to table directory, Hive will still empty the table directory, but
    // will exclude the staging directory there.
    // We have to follow the Hive behavior here, to avoid troubles. For example, if we create
    // staging directory under the table director for Hive prior to 1.1, the staging directory will
    // be removed by Hive when Hive is trying to empty the table directory.
    val hiveVersionsUsingOldExternalTempPath: Set[HiveVersion] = Set(v12, v13, v14, v1_0)
    val hiveVersionsUsingNewExternalTempPath: Set[HiveVersion] =
      Set(v1_1, v1_2, v2_0, v2_1, v2_2, v2_3)

    // Ensure all the supported versions are considered here.
    assert(hiveVersionsUsingNewExternalTempPath ++ hiveVersionsUsingOldExternalTempPath ==
      allSupportedHiveVersions)

    val externalCatalog = sparkSession.sharedState.externalCatalog
    val hiveVersion = externalCatalog.unwrapped.asInstanceOf[HiveExternalCatalog].client.version
    val stagingDir = hadoopConf.get("hive.exec.stagingdir", ".hive-staging")
    val scratchDir = hadoopConf.get("hive.exec.scratchdir", "/tmp/hive")

    if (hiveVersionsUsingOldExternalTempPath.contains(hiveVersion)) {
      oldVersionExternalTempPath(path, hadoopConf, scratchDir)
    } else if (hiveVersionsUsingNewExternalTempPath.contains(hiveVersion)) {
      newVersionExternalTempPath(path, hadoopConf, stagingDir)
    } else {
      throw new IllegalStateException("Unsupported hive version: " + hiveVersion.fullVersion)
    }
  }

  protected def deleteExternalTmpPath(hadoopConf: Configuration) : Unit = {
    // Attempt to delete the staging directory and the inclusive files. If failed, the files are
    // expected to be dropped at the normal termination of VM since deleteOnExit is used.
    try {
      createdTempDir.foreach { path =>
        val fs = path.getFileSystem(hadoopConf)
        if (fs.delete(path, true)) {
          // If we successfully delete the staging directory, remove it from FileSystem's cache.
          fs.cancelDeleteOnExit(path)
        }
      }
    } catch {
      case NonFatal(e) =>
        val stagingDir = hadoopConf.get("hive.exec.stagingdir", ".hive-staging")
        logWarning(s"Unable to delete staging directory: $stagingDir.\n" + e)
    }
  }

  // Mostly copied from Context.java#getExternalTmpPath of Hive 0.13
  private def oldVersionExternalTempPath(
      path: Path,
      hadoopConf: Configuration,
      scratchDir: String): Path = {
    val extURI: URI = path.toUri
    val scratchPath = new Path(scratchDir, executionId)
    var dirPath = new Path(
      extURI.getScheme,
      extURI.getAuthority,
      scratchPath.toUri.getPath + "-" + TaskRunner.getTaskRunnerID())

    try {
      val fs: FileSystem = dirPath.getFileSystem(hadoopConf)
      dirPath = new Path(fs.makeQualified(dirPath).toString())

      if (!FileUtils.mkdir(fs, dirPath, true, hadoopConf)) {
        throw new IllegalStateException("Cannot create staging directory: " + dirPath.toString)
      }
      createdTempDir = Some(dirPath)
      fs.deleteOnExit(dirPath)
    } catch {
      case e: IOException =>
        throw new RuntimeException("Cannot create staging directory: " + dirPath.toString, e)
    }
    dirPath
  }

  // Mostly copied from Context.java#getExternalTmpPath of Hive 1.2
  private def newVersionExternalTempPath(
      path: Path,
      hadoopConf: Configuration,
      stagingDir: String): Path = {
    val extURI: URI = path.toUri
    if (extURI.getScheme == "viewfs") {
      getExtTmpPathRelTo(path.getParent, hadoopConf, stagingDir)
    } else {
      new Path(getExternalScratchDir(extURI, hadoopConf, stagingDir), "-ext-10000")
    }
  }

  private def getExtTmpPathRelTo(
      path: Path,
      hadoopConf: Configuration,
      stagingDir: String): Path = {
    new Path(getStagingDir(path, hadoopConf, stagingDir), "-ext-10000") // Hive uses 10000
  }

  private def getExternalScratchDir(
      extURI: URI,
      hadoopConf: Configuration,
      stagingDir: String): Path = {
    getStagingDir(
      new Path(extURI.getScheme, extURI.getAuthority, extURI.getPath),
      hadoopConf,
      stagingDir)
  }

  private def getStagingDir(
      inputPath: Path,
      hadoopConf: Configuration,
      stagingDir: String): Path = {
    val inputPathUri: URI = inputPath.toUri
    val inputPathName: String = inputPathUri.getPath
    val fs: FileSystem = inputPath.getFileSystem(hadoopConf)
    var stagingPathName: String =
      if (inputPathName.indexOf(stagingDir) == -1) {
        new Path(inputPathName, stagingDir).toString
      } else {
        inputPathName.substring(0, inputPathName.indexOf(stagingDir) + stagingDir.length)
      }

    // SPARK-20594: This is a walk-around fix to resolve a Hive bug. Hive requires that the
    // staging directory needs to avoid being deleted when users set hive.exec.stagingdir
    // under the table directory.
    if (FileUtils.isSubDir(new Path(stagingPathName), inputPath, fs) &&
      !stagingPathName.stripPrefix(inputPathName).stripPrefix(File.separator).startsWith(".")) {
      logDebug(s"The staging dir '$stagingPathName' should be a child directory starts " +
        "with '.' to avoid being deleted if we set hive.exec.stagingdir under the table " +
        "directory.")
      stagingPathName = new Path(inputPathName, ".hive-staging").toString
    }

    val dir: Path =
      fs.makeQualified(
        new Path(stagingPathName + "_" + executionId + "-" + TaskRunner.getTaskRunnerID))
    logDebug("Created staging dir = " + dir + " for path = " + inputPath)
    try {
      if (!FileUtils.mkdir(fs, dir, true, hadoopConf)) {
        throw new IllegalStateException("Cannot create staging directory  '" + dir.toString + "'")
      }
      createdTempDir = Some(dir)
      fs.deleteOnExit(dir)
    } catch {
      case e: IOException =>
        throw new RuntimeException(
          "Cannot create staging directory '" + dir.toString + "': " + e.getMessage, e)
    }
    dir
  }

  private def executionId: String = {
    val rand: Random = new Random
    val format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss_SSS", Locale.US)
    "hive_" + format.format(new Date) + "_" + Math.abs(rand.nextLong)
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

package org.apache.spark.sql.hive.execution

import java.io._
import java.nio.charset.StandardCharsets
import java.util.Properties
import javax.annotation.Nullable

import scala.collection.JavaConverters._
import scala.util.control.NonFatal

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hive.ql.exec.{RecordReader, RecordWriter}
import org.apache.hadoop.hive.serde.serdeConstants
import org.apache.hadoop.hive.serde2.AbstractSerDe
import org.apache.hadoop.hive.serde2.objectinspector._
import org.apache.hadoop.io.Writable

import org.apache.spark.{SparkException, TaskContext}
import org.apache.spark.internal.Logging
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.catalyst.{CatalystTypeConverters, InternalRow}
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.plans.logical.ScriptInputOutputSchema
import org.apache.spark.sql.catalyst.plans.physical.Partitioning
import org.apache.spark.sql.execution._
import org.apache.spark.sql.hive.HiveInspectors
import org.apache.spark.sql.hive.HiveShim._
import org.apache.spark.sql.types.DataType
import org.apache.spark.util.{CircularBuffer, RedirectThread, SerializableConfiguration, Utils}

/**
 * Transforms the input by forking and running the specified script.
 *
 * @param input the set of expression that should be passed to the script.
 * @param script the command that should be executed.
 * @param output the attributes that are produced by the script.
 */
case class ScriptTransformationExec(
    input: Seq[Expression],
    script: String,
    output: Seq[Attribute],
    child: SparkPlan,
    ioschema: HiveScriptIOSchema)
  extends UnaryExecNode {

  override def producedAttributes: AttributeSet = outputSet -- inputSet

  override def outputPartitioning: Partitioning = child.outputPartitioning

  protected override def doExecute(): RDD[InternalRow] = {
    def processIterator(inputIterator: Iterator[InternalRow], hadoopConf: Configuration)
      : Iterator[InternalRow] = {
      val cmd = List("/bin/bash", "-c", script)
      val builder = new ProcessBuilder(cmd.asJava)

      val proc = builder.start()
      val inputStream = proc.getInputStream
      val outputStream = proc.getOutputStream
      val errorStream = proc.getErrorStream

      // In order to avoid deadlocks, we need to consume the error output of the child process.
      // To avoid issues caused by large error output, we use a circular buffer to limit the amount
      // of error output that we retain. See SPARK-7862 for more discussion of the deadlock / hang
      // that motivates this.
      val stderrBuffer = new CircularBuffer(2048)
      new RedirectThread(
        errorStream,
        stderrBuffer,
        "Thread-ScriptTransformation-STDERR-Consumer").start()

      val outputProjection = new InterpretedProjection(input, child.output)

      // This nullability is a performance optimization in order to avoid an Option.foreach() call
      // inside of a loop
      @Nullable val (inputSerde, inputSoi) = ioschema.initInputSerDe(input).getOrElse((null, null))

      // This new thread will consume the ScriptTransformation's input rows and write them to the
      // external process. That process's output will be read by this current thread.
      val writerThread = new ScriptTransformationWriterThread(
        inputIterator,
        input.map(_.dataType),
        outputProjection,
        inputSerde,
        inputSoi,
        ioschema,
        outputStream,
        proc,
        stderrBuffer,
        TaskContext.get(),
        hadoopConf
      )

      // This nullability is a performance optimization in order to avoid an Option.foreach() call
      // inside of a loop
      @Nullable val (outputSerde, outputSoi) = {
        ioschema.initOutputSerDe(output).getOrElse((null, null))
      }

      val reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))
      val outputIterator: Iterator[InternalRow] = new Iterator[InternalRow] with HiveInspectors {
        var curLine: String = null
        val scriptOutputStream = new DataInputStream(inputStream)

        @Nullable val scriptOutputReader =
          ioschema.recordReader(scriptOutputStream, hadoopConf).orNull

        var scriptOutputWritable: Writable = null
        val reusedWritableObject: Writable = if (null != outputSerde) {
          outputSerde.getSerializedClass().newInstance
        } else {
          null
        }
        val mutableRow = new SpecificInternalRow(output.map(_.dataType))

        @transient
        lazy val unwrappers = outputSoi.getAllStructFieldRefs.asScala.map(unwrapperFor)

        private def checkFailureAndPropagate(cause: Throwable = null): Unit = {
          if (writerThread.exception.isDefined) {
            throw writerThread.exception.get
          }

          if (!proc.isAlive) {
            val exitCode = proc.exitValue()
            if (exitCode != 0) {
              logError(stderrBuffer.toString) // log the stderr circular buffer
              throw new SparkException(s"Subprocess exited with status $exitCode. " +
                s"Error: ${stderrBuffer.toString}", cause)
            }
          }
        }

        override def hasNext: Boolean = {
          try {
            if (outputSerde == null) {
              if (curLine == null) {
                curLine = reader.readLine()
                if (curLine == null) {
                  checkFailureAndPropagate()
                  return false
                }
              }
            } else if (scriptOutputWritable == null) {
              scriptOutputWritable = reusedWritableObject

              if (scriptOutputReader != null) {
                if (scriptOutputReader.next(scriptOutputWritable) <= 0) {
                  checkFailureAndPropagate()
                  return false
                }
              } else {
                try {
                  scriptOutputWritable.readFields(scriptOutputStream)
                } catch {
                  case _: EOFException =>
                    // This means that the stdout of `proc` (ie. TRANSFORM process) has exhausted.
                    // Ideally the proc should *not* be alive at this point but
                    // there can be a lag between EOF being written out and the process
                    // being terminated. So explicitly waiting for the process to be done.
                    proc.waitFor()
                    checkFailureAndPropagate()
                    return false
                }
              }
            }

            true
          } catch {
            case NonFatal(e) =>
              // If this exception is due to abrupt / unclean termination of `proc`,
              // then detect it and propagate a better exception message for end users
              checkFailureAndPropagate(e)

              throw e
          }
        }

        override def next(): InternalRow = {
          if (!hasNext) {
            throw new NoSuchElementException
          }
          if (outputSerde == null) {
            val prevLine = curLine
            curLine = reader.readLine()
            if (!ioschema.schemaLess) {
              new GenericInternalRow(
                prevLine.split(ioschema.outputRowFormatMap("TOK_TABLEROWFORMATFIELD"))
                  .map(CatalystTypeConverters.convertToCatalyst))
            } else {
              new GenericInternalRow(
                prevLine.split(ioschema.outputRowFormatMap("TOK_TABLEROWFORMATFIELD"), 2)
                  .map(CatalystTypeConverters.convertToCatalyst))
            }
          } else {
            val raw = outputSerde.deserialize(scriptOutputWritable)
            scriptOutputWritable = null
            val dataList = outputSoi.getStructFieldsDataAsList(raw)
            var i = 0
            while (i < dataList.size()) {
              if (dataList.get(i) == null) {
                mutableRow.setNullAt(i)
              } else {
                unwrappers(i)(dataList.get(i), mutableRow, i)
              }
              i += 1
            }
            mutableRow
          }
        }
      }

      writerThread.start()

      outputIterator
    }

    val broadcastedHadoopConf =
      new SerializableConfiguration(sqlContext.sessionState.newHadoopConf())

    child.execute().mapPartitions { iter =>
      if (iter.hasNext) {
        val proj = UnsafeProjection.create(schema)
        processIterator(iter, broadcastedHadoopConf.value).map(proj)
      } else {
        // If the input iterator has no rows then do not launch the external script.
        Iterator.empty
      }
    }
  }
}

private class ScriptTransformationWriterThread(
    iter: Iterator[InternalRow],
    inputSchema: Seq[DataType],
    outputProjection: Projection,
    @Nullable inputSerde: AbstractSerDe,
    @Nullable inputSoi: ObjectInspector,
    ioschema: HiveScriptIOSchema,
    outputStream: OutputStream,
    proc: Process,
    stderrBuffer: CircularBuffer,
    taskContext: TaskContext,
    conf: Configuration
  ) extends Thread("Thread-ScriptTransformation-Feed") with Logging {

  setDaemon(true)

  @volatile private var _exception: Throwable = null

  /** Contains the exception thrown while writing the parent iterator to the external process. */
  def exception: Option[Throwable] = Option(_exception)

  override def run(): Unit = Utils.logUncaughtExceptions {
    TaskContext.setTaskContext(taskContext)

    val dataOutputStream = new DataOutputStream(outputStream)
    @Nullable val scriptInputWriter = ioschema.recordWriter(dataOutputStream, conf).orNull

    // We can't use Utils.tryWithSafeFinally here because we also need a `catch` block, so
    // let's use a variable to record whether the `finally` block was hit due to an exception
    var threwException: Boolean = true
    val len = inputSchema.length
    try {
      iter.map(outputProjection).foreach { row =>
        if (inputSerde == null) {
          val data = if (len == 0) {
            ioschema.inputRowFormatMap("TOK_TABLEROWFORMATLINES")
          } else {
            val sb = new StringBuilder
            sb.append(row.get(0, inputSchema(0)))
            var i = 1
            while (i < len) {
              sb.append(ioschema.inputRowFormatMap("TOK_TABLEROWFORMATFIELD"))
              sb.append(row.get(i, inputSchema(i)))
              i += 1
            }
            sb.append(ioschema.inputRowFormatMap("TOK_TABLEROWFORMATLINES"))
            sb.toString()
          }
          outputStream.write(data.getBytes(StandardCharsets.UTF_8))
        } else {
          val writable = inputSerde.serialize(
            row.asInstanceOf[GenericInternalRow].values, inputSoi)

          if (scriptInputWriter != null) {
            scriptInputWriter.write(writable)
          } else {
            prepareWritable(writable, ioschema.outputSerdeProps).write(dataOutputStream)
          }
        }
      }
      threwException = false
    } catch {
      case t: Throwable =>
        // An error occurred while writing input, so kill the child process. According to the
        // Javadoc this call will not throw an exception:
        _exception = t
        proc.destroy()
        throw t
    } finally {
      try {
        Utils.tryLogNonFatalError(outputStream.close())
        if (proc.waitFor() != 0) {
          logError(stderrBuffer.toString) // log the stderr circular buffer
        }
      } catch {
        case NonFatal(exceptionFromFinallyBlock) =>
          if (!threwException) {
            throw exceptionFromFinallyBlock
          } else {
            log.error("Exception in finally block", exceptionFromFinallyBlock)
          }
      }
    }
  }
}

object HiveScriptIOSchema {
  def apply(input: ScriptInputOutputSchema): HiveScriptIOSchema = {
    HiveScriptIOSchema(
      input.inputRowFormat,
      input.outputRowFormat,
      input.inputSerdeClass,
      input.outputSerdeClass,
      input.inputSerdeProps,
      input.outputSerdeProps,
      input.recordReaderClass,
      input.recordWriterClass,
      input.schemaLess)
  }
}

/**
 * The wrapper class of Hive input and output schema properties
 */
case class HiveScriptIOSchema (
    inputRowFormat: Seq[(String, String)],
    outputRowFormat: Seq[(String, String)],
    inputSerdeClass: Option[String],
    outputSerdeClass: Option[String],
    inputSerdeProps: Seq[(String, String)],
    outputSerdeProps: Seq[(String, String)],
    recordReaderClass: Option[String],
    recordWriterClass: Option[String],
    schemaLess: Boolean)
  extends HiveInspectors {

  private val defaultFormat = Map(
    ("TOK_TABLEROWFORMATFIELD", "\t"),
    ("TOK_TABLEROWFORMATLINES", "\n")
  )

  val inputRowFormatMap = inputRowFormat.toMap.withDefault((k) => defaultFormat(k))
  val outputRowFormatMap = outputRowFormat.toMap.withDefault((k) => defaultFormat(k))


  def initInputSerDe(input: Seq[Expression]): Option[(AbstractSerDe, ObjectInspector)] = {
    inputSerdeClass.map { serdeClass =>
      val (columns, columnTypes) = parseAttrs(input)
      val serde = initSerDe(serdeClass, columns, columnTypes, inputSerdeProps)
      val fieldObjectInspectors = columnTypes.map(toInspector)
      val objectInspector = ObjectInspectorFactory
        .getStandardStructObjectInspector(columns.asJava, fieldObjectInspectors.asJava)
        .asInstanceOf[ObjectInspector]
      (serde, objectInspector)
    }
  }

  def initOutputSerDe(output: Seq[Attribute]): Option[(AbstractSerDe, StructObjectInspector)] = {
    outputSerdeClass.map { serdeClass =>
      val (columns, columnTypes) = parseAttrs(output)
      val serde = initSerDe(serdeClass, columns, columnTypes, outputSerdeProps)
      val structObjectInspector = serde.getObjectInspector().asInstanceOf[StructObjectInspector]
      (serde, structObjectInspector)
    }
  }

  private def parseAttrs(attrs: Seq[Expression]): (Seq[String], Seq[DataType]) = {
    val columns = attrs.zipWithIndex.map(e => s"${e._1.prettyName}_${e._2}")
    val columnTypes = attrs.map(_.dataType)
    (columns, columnTypes)
  }

  private def initSerDe(
      serdeClassName: String,
      columns: Seq[String],
      columnTypes: Seq[DataType],
      serdeProps: Seq[(String, String)]): AbstractSerDe = {

    val serde = Utils.classForName(serdeClassName).newInstance.asInstanceOf[AbstractSerDe]

    val columnTypesNames = columnTypes.map(_.toTypeInfo.getTypeName()).mkString(",")

    var propsMap = serdeProps.toMap + (serdeConstants.LIST_COLUMNS -> columns.mkString(","))
    propsMap = propsMap + (serdeConstants.LIST_COLUMN_TYPES -> columnTypesNames)

    val properties = new Properties()
    // Can not use properties.putAll(propsMap.asJava) in scala-2.12
    // See https://github.com/scala/bug/issues/10418
    propsMap.foreach { case (k, v) => properties.put(k, v) }
    serde.initialize(null, properties)

    serde
  }

  def recordReader(
      inputStream: InputStream,
      conf: Configuration): Option[RecordReader] = {
    recordReaderClass.map { klass =>
      val instance = Utils.classForName(klass).newInstance().asInstanceOf[RecordReader]
      val props = new Properties()
      // Can not use props.putAll(outputSerdeProps.toMap.asJava) in scala-2.12
      // See https://github.com/scala/bug/issues/10418
      outputSerdeProps.toMap.foreach { case (k, v) => props.put(k, v) }
      instance.initialize(inputStream, conf, props)
      instance
    }
  }

  def recordWriter(outputStream: OutputStream, conf: Configuration): Option[RecordWriter] = {
    recordWriterClass.map { klass =>
      val instance = Utils.classForName(klass).newInstance().asInstanceOf[RecordWriter]
      instance.initialize(outputStream, conf)
      instance
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

package org.apache.spark.sql.hive

import java.util.Properties

import scala.collection.JavaConverters._

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.{Path, PathFilter}
import org.apache.hadoop.hive.metastore.api.hive_metastoreConstants._
import org.apache.hadoop.hive.ql.exec.Utilities
import org.apache.hadoop.hive.ql.metadata.{Partition => HivePartition, Table => HiveTable}
import org.apache.hadoop.hive.ql.plan.TableDesc
import org.apache.hadoop.hive.serde2.Deserializer
import org.apache.hadoop.hive.serde2.objectinspector.{ObjectInspectorConverters, StructObjectInspector}
import org.apache.hadoop.hive.serde2.objectinspector.primitive._
import org.apache.hadoop.io.Writable
import org.apache.hadoop.mapred.{FileInputFormat, InputFormat, JobConf}

import org.apache.spark.broadcast.Broadcast
import org.apache.spark.deploy.SparkHadoopUtil
import org.apache.spark.internal.Logging
import org.apache.spark.rdd.{EmptyRDD, HadoopRDD, RDD, UnionRDD}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.catalyst.analysis.CastSupport
import org.apache.spark.sql.catalyst.expressions._
import org.apache.spark.sql.catalyst.util.DateTimeUtils
import org.apache.spark.sql.internal.SQLConf
import org.apache.spark.unsafe.types.UTF8String
import org.apache.spark.util.{SerializableConfiguration, Utils}

/**
 * A trait for subclasses that handle table scans.
 */
private[hive] sealed trait TableReader {
  def makeRDDForTable(hiveTable: HiveTable): RDD[InternalRow]

  def makeRDDForPartitionedTable(partitions: Seq[HivePartition]): RDD[InternalRow]
}


/**
 * Helper class for scanning tables stored in Hadoop - e.g., to read Hive tables that reside in the
 * data warehouse directory.
 */
private[hive]
class HadoopTableReader(
    @transient private val attributes: Seq[Attribute],
    @transient private val partitionKeys: Seq[Attribute],
    @transient private val tableDesc: TableDesc,
    @transient private val sparkSession: SparkSession,
    hadoopConf: Configuration)
  extends TableReader with CastSupport with Logging {

  // Hadoop honors "mapreduce.job.maps" as hint,
  // but will ignore when mapreduce.jobtracker.address is "local".
  // https://hadoop.apache.org/docs/r2.6.5/hadoop-mapreduce-client/hadoop-mapreduce-client-core/
  // mapred-default.xml
  //
  // In order keep consistency with Hive, we will let it be 0 in local mode also.
  private val _minSplitsPerRDD = if (sparkSession.sparkContext.isLocal) {
    0 // will splitted based on block by default.
  } else {
    math.max(hadoopConf.getInt("mapreduce.job.maps", 1),
      sparkSession.sparkContext.defaultMinPartitions)
  }

  SparkHadoopUtil.get.appendS3AndSparkHadoopConfigurations(
    sparkSession.sparkContext.conf, hadoopConf)

  private val _broadcastedHadoopConf =
    sparkSession.sparkContext.broadcast(new SerializableConfiguration(hadoopConf))

  override def conf: SQLConf = sparkSession.sessionState.conf

  override def makeRDDForTable(hiveTable: HiveTable): RDD[InternalRow] =
    makeRDDForTable(
      hiveTable,
      Utils.classForName(tableDesc.getSerdeClassName).asInstanceOf[Class[Deserializer]],
      filterOpt = None)

  /**
   * Creates a Hadoop RDD to read data from the target table's data directory. Returns a transformed
   * RDD that contains deserialized rows.
   *
   * @param hiveTable Hive metadata for the table being scanned.
   * @param deserializerClass Class of the SerDe used to deserialize Writables read from Hadoop.
   * @param filterOpt If defined, then the filter is used to reject files contained in the data
   *                  directory being read. If None, then all files are accepted.
   */
  def makeRDDForTable(
      hiveTable: HiveTable,
      deserializerClass: Class[_ <: Deserializer],
      filterOpt: Option[PathFilter]): RDD[InternalRow] = {

    assert(!hiveTable.isPartitioned,
      "makeRDDForTable() cannot be called on a partitioned table, since input formats may " +
      "differ across partitions. Use makeRDDForPartitionedTable() instead.")

    // Create local references to member variables, so that the entire `this` object won't be
    // serialized in the closure below.
    val localTableDesc = tableDesc
    val broadcastedHadoopConf = _broadcastedHadoopConf

    val tablePath = hiveTable.getPath
    val inputPathStr = applyFilterIfNeeded(tablePath, filterOpt)

    // logDebug("Table input: %s".format(tablePath))
    val ifc = hiveTable.getInputFormatClass
      .asInstanceOf[java.lang.Class[InputFormat[Writable, Writable]]]
    val hadoopRDD = createHadoopRdd(localTableDesc, inputPathStr, ifc)

    val attrsWithIndex = attributes.zipWithIndex
    val mutableRow = new SpecificInternalRow(attributes.map(_.dataType))

    val deserializedHadoopRDD = hadoopRDD.mapPartitions { iter =>
      val hconf = broadcastedHadoopConf.value.value
      val deserializer = deserializerClass.newInstance()
      deserializer.initialize(hconf, localTableDesc.getProperties)
      HadoopTableReader.fillObject(iter, deserializer, attrsWithIndex, mutableRow, deserializer)
    }

    deserializedHadoopRDD
  }

  override def makeRDDForPartitionedTable(partitions: Seq[HivePartition]): RDD[InternalRow] = {
    val partitionToDeserializer = partitions.map(part =>
      (part, part.getDeserializer.getClass.asInstanceOf[Class[Deserializer]])).toMap
    makeRDDForPartitionedTable(partitionToDeserializer, filterOpt = None)
  }

  /**
   * Create a HadoopRDD for every partition key specified in the query. Note that for on-disk Hive
   * tables, a data directory is created for each partition corresponding to keys specified using
   * 'PARTITION BY'.
   *
   * @param partitionToDeserializer Mapping from a Hive Partition metadata object to the SerDe
   *     class to use to deserialize input Writables from the corresponding partition.
   * @param filterOpt If defined, then the filter is used to reject files contained in the data
   *     subdirectory of each partition being read. If None, then all files are accepted.
   */
  def makeRDDForPartitionedTable(
      partitionToDeserializer: Map[HivePartition, Class[_ <: Deserializer]],
      filterOpt: Option[PathFilter]): RDD[InternalRow] = {

    // SPARK-5068:get FileStatus and do the filtering locally when the path is not exists
    def verifyPartitionPath(
        partitionToDeserializer: Map[HivePartition, Class[_ <: Deserializer]]):
        Map[HivePartition, Class[_ <: Deserializer]] = {
      if (!sparkSession.sessionState.conf.verifyPartitionPath) {
        partitionToDeserializer
      } else {
        val existPathSet = collection.mutable.Set[String]()
        val pathPatternSet = collection.mutable.Set[String]()
        partitionToDeserializer.filter {
          case (partition, partDeserializer) =>
            def updateExistPathSetByPathPattern(pathPatternStr: String) {
              val pathPattern = new Path(pathPatternStr)
              val fs = pathPattern.getFileSystem(hadoopConf)
              val matches = fs.globStatus(pathPattern)
              matches.foreach(fileStatus => existPathSet += fileStatus.getPath.toString)
            }
            // convert  /demo/data/year/month/day  to  /demo/data/*/*/*/
            def getPathPatternByPath(parNum: Int, tempPath: Path): String = {
              var path = tempPath
              for (i <- (1 to parNum)) path = path.getParent
              val tails = (1 to parNum).map(_ => "*").mkString("/", "/", "/")
              path.toString + tails
            }

            val partPath = partition.getDataLocation
            val partNum = Utilities.getPartitionDesc(partition).getPartSpec.size()
            val pathPatternStr = getPathPatternByPath(partNum, partPath)
            if (!pathPatternSet.contains(pathPatternStr)) {
              pathPatternSet += pathPatternStr
              updateExistPathSetByPathPattern(pathPatternStr)
            }
            existPathSet.contains(partPath.toString)
        }
      }
    }

    val hivePartitionRDDs = verifyPartitionPath(partitionToDeserializer)
      .map { case (partition, partDeserializer) =>
      val partDesc = Utilities.getPartitionDesc(partition)
      val partPath = partition.getDataLocation
      val inputPathStr = applyFilterIfNeeded(partPath, filterOpt)
      val ifc = partDesc.getInputFileFormatClass
        .asInstanceOf[java.lang.Class[InputFormat[Writable, Writable]]]
      // Get partition field info
      val partSpec = partDesc.getPartSpec
      val partProps = partDesc.getProperties

      val partColsDelimited: String = partProps.getProperty(META_TABLE_PARTITION_COLUMNS)
      // Partitioning columns are delimited by "/"
      val partCols = partColsDelimited.trim().split("/").toSeq
      // 'partValues[i]' contains the value for the partitioning column at 'partCols[i]'.
      val partValues = if (partSpec == null) {
        Array.fill(partCols.size)(new String)
      } else {
        partCols.map(col => new String(partSpec.get(col))).toArray
      }

      val broadcastedHiveConf = _broadcastedHadoopConf
      val localDeserializer = partDeserializer
      val mutableRow = new SpecificInternalRow(attributes.map(_.dataType))

      // Splits all attributes into two groups, partition key attributes and those that are not.
      // Attached indices indicate the position of each attribute in the output schema.
      val (partitionKeyAttrs, nonPartitionKeyAttrs) =
        attributes.zipWithIndex.partition { case (attr, _) =>
          partitionKeys.contains(attr)
        }

      def fillPartitionKeys(rawPartValues: Array[String], row: InternalRow): Unit = {
        partitionKeyAttrs.foreach { case (attr, ordinal) =>
          val partOrdinal = partitionKeys.indexOf(attr)
          row(ordinal) = cast(Literal(rawPartValues(partOrdinal)), attr.dataType).eval(null)
        }
      }

      // Fill all partition keys to the given MutableRow object
      fillPartitionKeys(partValues, mutableRow)

      val tableProperties = tableDesc.getProperties

      // Create local references so that the outer object isn't serialized.
      val localTableDesc = tableDesc
      createHadoopRdd(localTableDesc, inputPathStr, ifc).mapPartitions { iter =>
        val hconf = broadcastedHiveConf.value.value
        val deserializer = localDeserializer.newInstance()
        // SPARK-13709: For SerDes like AvroSerDe, some essential information (e.g. Avro schema
        // information) may be defined in table properties. Here we should merge table properties
        // and partition properties before initializing the deserializer. Note that partition
        // properties take a higher priority here. For example, a partition may have a different
        // SerDe as the one defined in table properties.
        val props = new Properties(tableProperties)
        partProps.asScala.foreach {
          case (key, value) => props.setProperty(key, value)
        }
        deserializer.initialize(hconf, props)
        // get the table deserializer
        val tableSerDe = localTableDesc.getDeserializerClass.newInstance()
        tableSerDe.initialize(hconf, localTableDesc.getProperties)

        // fill the non partition key attributes
        HadoopTableReader.fillObject(iter, deserializer, nonPartitionKeyAttrs,
          mutableRow, tableSerDe)
      }
    }.toSeq

    // Even if we don't use any partitions, we still need an empty RDD
    if (hivePartitionRDDs.size == 0) {
      new EmptyRDD[InternalRow](sparkSession.sparkContext)
    } else {
      new UnionRDD(hivePartitionRDDs(0).context, hivePartitionRDDs)
    }
  }

  /**
   * If `filterOpt` is defined, then it will be used to filter files from `path`. These files are
   * returned in a single, comma-separated string.
   */
  private def applyFilterIfNeeded(path: Path, filterOpt: Option[PathFilter]): String = {
    filterOpt match {
      case Some(filter) =>
        val fs = path.getFileSystem(hadoopConf)
        val filteredFiles = fs.listStatus(path, filter).map(_.getPath.toString)
        filteredFiles.mkString(",")
      case None => path.toString
    }
  }

  /**
   * Creates a HadoopRDD based on the broadcasted HiveConf and other job properties that will be
   * applied locally on each slave.
   */
  private def createHadoopRdd(
    tableDesc: TableDesc,
    path: String,
    inputFormatClass: Class[InputFormat[Writable, Writable]]): RDD[Writable] = {

    val initializeJobConfFunc = HadoopTableReader.initializeLocalJobConfFunc(path, tableDesc) _

    val rdd = new HadoopRDD(
      sparkSession.sparkContext,
      _broadcastedHadoopConf.asInstanceOf[Broadcast[SerializableConfiguration]],
      Some(initializeJobConfFunc),
      inputFormatClass,
      classOf[Writable],
      classOf[Writable],
      _minSplitsPerRDD)

    // Only take the value (skip the key) because Hive works only with values.
    rdd.map(_._2)
  }
}

private[hive] object HiveTableUtil {

  // copied from PlanUtils.configureJobPropertiesForStorageHandler(tableDesc)
  // that calls Hive.get() which tries to access metastore, but it's not valid in runtime
  // it would be fixed in next version of hive but till then, we should use this instead
  def configureJobPropertiesForStorageHandler(
      tableDesc: TableDesc, conf: Configuration, input: Boolean) {
    val property = tableDesc.getProperties.getProperty(META_TABLE_STORAGE)
    val storageHandler =
      org.apache.hadoop.hive.ql.metadata.HiveUtils.getStorageHandler(conf, property)
    if (storageHandler != null) {
      val jobProperties = new java.util.LinkedHashMap[String, String]
      if (input) {
        storageHandler.configureInputJobProperties(tableDesc, jobProperties)
      } else {
        storageHandler.configureOutputJobProperties(tableDesc, jobProperties)
      }
      if (!jobProperties.isEmpty) {
        tableDesc.setJobProperties(jobProperties)
      }
    }
  }
}

private[hive] object HadoopTableReader extends HiveInspectors with Logging {
  /**
   * Curried. After given an argument for 'path', the resulting JobConf => Unit closure is used to
   * instantiate a HadoopRDD.
   */
  def initializeLocalJobConfFunc(path: String, tableDesc: TableDesc)(jobConf: JobConf) {
    FileInputFormat.setInputPaths(jobConf, Seq[Path](new Path(path)): _*)
    if (tableDesc != null) {
      HiveTableUtil.configureJobPropertiesForStorageHandler(tableDesc, jobConf, true)
      Utilities.copyTableJobPropertiesToConf(tableDesc, jobConf)
    }
    val bufferSize = System.getProperty("spark.buffer.size", "65536")
    jobConf.set("io.file.buffer.size", bufferSize)
  }

  /**
   * Transform all given raw `Writable`s into `Row`s.
   *
   * @param iterator Iterator of all `Writable`s to be transformed
   * @param rawDeser The `Deserializer` associated with the input `Writable`
   * @param nonPartitionKeyAttrs Attributes that should be filled together with their corresponding
   *                             positions in the output schema
   * @param mutableRow A reusable `MutableRow` that should be filled
   * @param tableDeser Table Deserializer
   * @return An `Iterator[Row]` transformed from `iterator`
   */
  def fillObject(
      iterator: Iterator[Writable],
      rawDeser: Deserializer,
      nonPartitionKeyAttrs: Seq[(Attribute, Int)],
      mutableRow: InternalRow,
      tableDeser: Deserializer): Iterator[InternalRow] = {

    val soi = if (rawDeser.getObjectInspector.equals(tableDeser.getObjectInspector)) {
      rawDeser.getObjectInspector.asInstanceOf[StructObjectInspector]
    } else {
      ObjectInspectorConverters.getConvertedOI(
        rawDeser.getObjectInspector,
        tableDeser.getObjectInspector).asInstanceOf[StructObjectInspector]
    }

    logDebug(soi.toString)

    val (fieldRefs, fieldOrdinals) = nonPartitionKeyAttrs.map { case (attr, ordinal) =>
      soi.getStructFieldRef(attr.name) -> ordinal
    }.toArray.unzip

    /**
     * Builds specific unwrappers ahead of time according to object inspector
     * types to avoid pattern matching and branching costs per row.
     */
    val unwrappers: Seq[(Any, InternalRow, Int) => Unit] = fieldRefs.map {
      _.getFieldObjectInspector match {
        case oi: BooleanObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setBoolean(ordinal, oi.get(value))
        case oi: ByteObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setByte(ordinal, oi.get(value))
        case oi: ShortObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setShort(ordinal, oi.get(value))
        case oi: IntObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setInt(ordinal, oi.get(value))
        case oi: LongObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setLong(ordinal, oi.get(value))
        case oi: FloatObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setFloat(ordinal, oi.get(value))
        case oi: DoubleObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) => row.setDouble(ordinal, oi.get(value))
        case oi: HiveVarcharObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) =>
            row.update(ordinal, UTF8String.fromString(oi.getPrimitiveJavaObject(value).getValue))
        case oi: HiveCharObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) =>
            row.update(ordinal, UTF8String.fromString(oi.getPrimitiveJavaObject(value).getValue))
        case oi: HiveDecimalObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) =>
            row.update(ordinal, HiveShim.toCatalystDecimal(oi, value))
        case oi: TimestampObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) =>
            row.setLong(ordinal, DateTimeUtils.fromJavaTimestamp(oi.getPrimitiveJavaObject(value)))
        case oi: DateObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) =>
            row.setInt(ordinal, DateTimeUtils.fromJavaDate(oi.getPrimitiveJavaObject(value)))
        case oi: BinaryObjectInspector =>
          (value: Any, row: InternalRow, ordinal: Int) =>
            row.update(ordinal, oi.getPrimitiveJavaObject(value))
        case oi =>
          val unwrapper = unwrapperFor(oi)
          (value: Any, row: InternalRow, ordinal: Int) => row(ordinal) = unwrapper(value)
      }
    }

    val converter = ObjectInspectorConverters.getConverter(rawDeser.getObjectInspector, soi)

    // Map each tuple to a row object
    iterator.map { value =>
      val raw = converter.convert(rawDeser.deserialize(value))
      var i = 0
      val length = fieldRefs.length
      while (i < length) {
        val fieldValue = soi.getStructFieldData(raw, fieldRefs(i))
        if (fieldValue == null) {
          mutableRow.setNullAt(fieldOrdinals(i))
        } else {
          unwrappers(i)(fieldValue, mutableRow, fieldOrdinals(i))
        }
        i += 1
      }

      mutableRow: InternalRow
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

package org.apache.spark.sql.hive.test

import java.io.File
import java.net.URI
import java.util.{Set => JavaSet}

import scala.collection.JavaConverters._
import scala.collection.mutable
import scala.language.implicitConversions

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path
import org.apache.hadoop.hive.conf.HiveConf.ConfVars
import org.apache.hadoop.hive.ql.exec.FunctionRegistry
import org.apache.hadoop.hive.serde2.`lazy`.LazySimpleSerDe

import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.internal.Logging
import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.sql.catalyst.analysis.UnresolvedRelation
import org.apache.spark.sql.catalyst.catalog.{ExternalCatalog, ExternalCatalogWithListener}
import org.apache.spark.sql.catalyst.optimizer.ConvertToLocalRelation
import org.apache.spark.sql.catalyst.plans.logical.{LogicalPlan, OneRowRelation}
import org.apache.spark.sql.execution.{QueryExecution, SQLExecution}
import org.apache.spark.sql.execution.command.CacheTableCommand
import org.apache.spark.sql.hive._
import org.apache.spark.sql.hive.client.HiveClient
import org.apache.spark.sql.internal.{SessionState, SharedState, SQLConf, WithTestConf}
import org.apache.spark.sql.internal.StaticSQLConf.CATALOG_IMPLEMENTATION
import org.apache.spark.util.{ShutdownHookManager, Utils}

// SPARK-3729: Test key required to check for initialization errors with config.
object TestHive
  extends TestHiveContext(
    new SparkContext(
      System.getProperty("spark.sql.test.master", "local[1]"),
      "TestSQLContext",
      new SparkConf()
        .set("spark.sql.test", "")
        .set(SQLConf.CODEGEN_FALLBACK.key, "false")
        .set("spark.sql.hive.metastore.barrierPrefixes",
          "org.apache.spark.sql.hive.execution.PairSerDe")
        .set("spark.sql.warehouse.dir", TestHiveContext.makeWarehouseDir().toURI.getPath)
        // SPARK-8910
        .set("spark.ui.enabled", "false")
        .set("spark.unsafe.exceptionOnMemoryLeak", "true")
        // Disable ConvertToLocalRelation for better test coverage. Test cases built on
        // LocalRelation will exercise the optimization rules better by disabling it as
        // this rule may potentially block testing of other optimization rules such as
        // ConstantPropagation etc.
        .set(SQLConf.OPTIMIZER_EXCLUDED_RULES.key, ConvertToLocalRelation.ruleName)))


case class TestHiveVersion(hiveClient: HiveClient)
  extends TestHiveContext(TestHive.sparkContext, hiveClient)


private[hive] class TestHiveExternalCatalog(
    conf: SparkConf,
    hadoopConf: Configuration,
    hiveClient: Option[HiveClient] = None)
  extends HiveExternalCatalog(conf, hadoopConf) with Logging {

  override lazy val client: HiveClient =
    hiveClient.getOrElse {
      HiveUtils.newClientForMetadata(conf, hadoopConf)
    }
}


private[hive] class TestHiveSharedState(
    sc: SparkContext,
    hiveClient: Option[HiveClient] = None)
  extends SharedState(sc) {

  override lazy val externalCatalog: ExternalCatalogWithListener = {
    new ExternalCatalogWithListener(new TestHiveExternalCatalog(
      sc.conf,
      sc.hadoopConfiguration,
      hiveClient))
  }
}


/**
 * A locally running test instance of Spark's Hive execution engine.
 *
 * Data from [[testTables]] will be automatically loaded whenever a query is run over those tables.
 * Calling [[reset]] will delete all tables and other state in the database, leaving the database
 * in a "clean" state.
 *
 * TestHive is singleton object version of this class because instantiating multiple copies of the
 * hive metastore seems to lead to weird non-deterministic failures.  Therefore, the execution of
 * test cases that rely on TestHive must be serialized.
 */
class TestHiveContext(
    @transient override val sparkSession: TestHiveSparkSession)
  extends SQLContext(sparkSession) {

  /**
   * If loadTestTables is false, no test tables are loaded. Note that this flag can only be true
   * when running in the JVM, i.e. it needs to be false when calling from Python.
   */
  def this(sc: SparkContext, loadTestTables: Boolean = true) {
    this(new TestHiveSparkSession(HiveUtils.withHiveExternalCatalog(sc), loadTestTables))
  }

  def this(sc: SparkContext, hiveClient: HiveClient) {
    this(new TestHiveSparkSession(HiveUtils.withHiveExternalCatalog(sc),
      hiveClient,
      loadTestTables = false))
  }

  override def newSession(): TestHiveContext = {
    new TestHiveContext(sparkSession.newSession())
  }

  def setCacheTables(c: Boolean): Unit = {
    sparkSession.setCacheTables(c)
  }

  def getHiveFile(path: String): File = {
    sparkSession.getHiveFile(path)
  }

  def loadTestTable(name: String): Unit = {
    sparkSession.loadTestTable(name)
  }

  def reset(): Unit = {
    sparkSession.reset()
  }

}

/**
 * A [[SparkSession]] used in [[TestHiveContext]].
 *
 * @param sc SparkContext
 * @param existingSharedState optional [[SharedState]]
 * @param parentSessionState optional parent [[SessionState]]
 * @param loadTestTables if true, load the test tables. They can only be loaded when running
 *                       in the JVM, i.e when calling from Python this flag has to be false.
 */
private[hive] class TestHiveSparkSession(
    @transient private val sc: SparkContext,
    @transient private val existingSharedState: Option[TestHiveSharedState],
    @transient private val parentSessionState: Option[SessionState],
    private val loadTestTables: Boolean)
  extends SparkSession(sc) with Logging { self =>

  def this(sc: SparkContext, loadTestTables: Boolean) {
    this(
      sc,
      existingSharedState = None,
      parentSessionState = None,
      loadTestTables)
  }

  def this(sc: SparkContext, hiveClient: HiveClient, loadTestTables: Boolean) {
    this(
      sc,
      existingSharedState = Some(new TestHiveSharedState(sc, Some(hiveClient))),
      parentSessionState = None,
      loadTestTables)
  }

  SparkSession.setDefaultSession(this)
  SparkSession.setActiveSession(this)

  { // set the metastore temporary configuration
    val metastoreTempConf = HiveUtils.newTemporaryConfiguration(useInMemoryDerby = false) ++ Map(
      ConfVars.METASTORE_INTEGER_JDO_PUSHDOWN.varname -> "true",
      // scratch directory used by Hive's metastore client
      ConfVars.SCRATCHDIR.varname -> TestHiveContext.makeScratchDir().toURI.toString,
      ConfVars.METASTORE_CLIENT_CONNECT_RETRY_DELAY.varname -> "1") ++
      // After session cloning, the JDBC connect string for a JDBC metastore should not be changed.
      existingSharedState.map { state =>
        val connKey =
          state.sparkContext.hadoopConfiguration.get(ConfVars.METASTORECONNECTURLKEY.varname)
        ConfVars.METASTORECONNECTURLKEY.varname -> connKey
      }

    metastoreTempConf.foreach { case (k, v) =>
      sc.hadoopConfiguration.set(k, v)
    }
  }

  assume(sc.conf.get(CATALOG_IMPLEMENTATION) == "hive")

  @transient
  override lazy val sharedState: TestHiveSharedState = {
    existingSharedState.getOrElse(new TestHiveSharedState(sc))
  }

  @transient
  override lazy val sessionState: SessionState = {
    new TestHiveSessionStateBuilder(this, parentSessionState).build()
  }

  lazy val metadataHive: HiveClient = {
    sharedState.externalCatalog.unwrapped.asInstanceOf[HiveExternalCatalog].client.newSession()
  }

  override def newSession(): TestHiveSparkSession = {
    new TestHiveSparkSession(sc, Some(sharedState), None, loadTestTables)
  }

  override def cloneSession(): SparkSession = {
    val result = new TestHiveSparkSession(
      sparkContext,
      Some(sharedState),
      Some(sessionState),
      loadTestTables)
    result.sessionState // force copy of SessionState
    result
  }

  private var cacheTables: Boolean = false

  def setCacheTables(c: Boolean): Unit = {
    cacheTables = c
  }

  // By clearing the port we force Spark to pick a new one.  This allows us to rerun tests
  // without restarting the JVM.
  System.clearProperty("spark.hostPort")

  // For some hive test case which contain ${system:test.tmp.dir}
  System.setProperty("test.tmp.dir", Utils.createTempDir().toURI.getPath)

  /** The location of the compiled hive distribution */
  lazy val hiveHome = envVarToFile("HIVE_HOME")

  /** The location of the hive source code. */
  lazy val hiveDevHome = envVarToFile("HIVE_DEV_HOME")

  /**
   * Returns the value of specified environmental variable as a [[java.io.File]] after checking
   * to ensure it exists
   */
  private def envVarToFile(envVar: String): Option[File] = {
    Option(System.getenv(envVar)).map(new File(_))
  }

  val hiveFilesTemp = File.createTempFile("catalystHiveFiles", "")
  hiveFilesTemp.delete()
  hiveFilesTemp.mkdir()
  ShutdownHookManager.registerShutdownDeleteDir(hiveFilesTemp)

  def getHiveFile(path: String): File = {
    new File(Thread.currentThread().getContextClassLoader.getResource(path).getFile)
  }

  private def quoteHiveFile(path : String) = if (Utils.isWindows) {
    getHiveFile(path).getPath.replace('\\', '/')
  } else {
    getHiveFile(path).getPath
  }

  def getWarehousePath(): String = {
    val tempConf = new SQLConf
    sc.conf.getAll.foreach { case (k, v) => tempConf.setConfString(k, v) }
    tempConf.warehousePath
  }

  val describedTable = "DESCRIBE (\\w+)".r

  case class TestTable(name: String, commands: (() => Unit)*)

  protected[hive] implicit class SqlCmd(sql: String) {
    def cmd: () => Unit = {
      () => new TestHiveQueryExecution(sql).hiveResultString(): Unit
    }
  }

  /**
   * A list of test tables and the DDL required to initialize them.  A test table is loaded on
   * demand when a query are run against it.
   */
  @transient
  lazy val testTables = new mutable.HashMap[String, TestTable]()

  def registerTestTable(testTable: TestTable): Unit = {
    testTables += (testTable.name -> testTable)
  }

  if (loadTestTables) {
    // The test tables that are defined in the Hive QTestUtil.
    // /itests/util/src/main/java/org/apache/hadoop/hive/ql/QTestUtil.java
    // https://github.com/apache/hive/blob/branch-0.13/data/scripts/q_test_init.sql
    @transient
    val hiveQTestUtilTables: Seq[TestTable] = Seq(
      TestTable("src",
        "CREATE TABLE src (key INT, value STRING)".cmd,
        s"LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/kv1.txt")}' INTO TABLE src".cmd),
      TestTable("src1",
        "CREATE TABLE src1 (key INT, value STRING)".cmd,
        s"LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/kv3.txt")}' INTO TABLE src1".cmd),
      TestTable("srcpart", () => {
        "CREATE TABLE srcpart (key INT, value STRING) PARTITIONED BY (ds STRING, hr STRING)"
          .cmd.apply()
        for (ds <- Seq("2008-04-08", "2008-04-09"); hr <- Seq("11", "12")) {
          s"""
             |LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/kv1.txt")}'
             |OVERWRITE INTO TABLE srcpart PARTITION (ds='$ds',hr='$hr')
          """.stripMargin.cmd.apply()
        }
      }),
      TestTable("srcpart1", () => {
        "CREATE TABLE srcpart1 (key INT, value STRING) PARTITIONED BY (ds STRING, hr INT)"
          .cmd.apply()
        for (ds <- Seq("2008-04-08", "2008-04-09"); hr <- 11 to 12) {
          s"""
             |LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/kv1.txt")}'
             |OVERWRITE INTO TABLE srcpart1 PARTITION (ds='$ds',hr='$hr')
          """.stripMargin.cmd.apply()
        }
      }),
      TestTable("src_thrift", () => {
        import org.apache.hadoop.hive.serde2.thrift.ThriftDeserializer
        import org.apache.hadoop.mapred.{SequenceFileInputFormat, SequenceFileOutputFormat}
        import org.apache.thrift.protocol.TBinaryProtocol

        s"""
           |CREATE TABLE src_thrift(fake INT)
           |ROW FORMAT SERDE '${classOf[ThriftDeserializer].getName}'
           |WITH SERDEPROPERTIES(
           |  'serialization.class'='org.apache.spark.sql.hive.test.Complex',
           |  'serialization.format'='${classOf[TBinaryProtocol].getName}'
           |)
           |STORED AS
           |INPUTFORMAT '${classOf[SequenceFileInputFormat[_, _]].getName}'
           |OUTPUTFORMAT '${classOf[SequenceFileOutputFormat[_, _]].getName}'
        """.stripMargin.cmd.apply()

        s"""
           |LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/complex.seq")}'
           |INTO TABLE src_thrift
        """.stripMargin.cmd.apply()
      }),
      TestTable("serdeins",
        s"""CREATE TABLE serdeins (key INT, value STRING)
           |ROW FORMAT SERDE '${classOf[LazySimpleSerDe].getCanonicalName}'
           |WITH SERDEPROPERTIES ('field.delim'='\\t')
         """.stripMargin.cmd,
        "INSERT OVERWRITE TABLE serdeins SELECT * FROM src".cmd),
      TestTable("episodes",
        s"""CREATE TABLE episodes (title STRING, air_date STRING, doctor INT)
           |STORED AS avro
           |TBLPROPERTIES (
           |  'avro.schema.literal'='{
           |    "type": "record",
           |    "name": "episodes",
           |    "namespace": "testing.hive.avro.serde",
           |    "fields": [
           |      {
           |          "name": "title",
           |          "type": "string",
           |          "doc": "episode title"
           |      },
           |      {
           |          "name": "air_date",
           |          "type": "string",
           |          "doc": "initial date"
           |      },
           |      {
           |          "name": "doctor",
           |          "type": "int",
           |          "doc": "main actor playing the Doctor in episode"
           |      }
           |    ]
           |  }'
           |)
         """.stripMargin.cmd,
        s"""
           |LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/episodes.avro")}'
           |INTO TABLE episodes
         """.stripMargin.cmd
      ),
      // THIS TABLE IS NOT THE SAME AS THE HIVE TEST TABLE episodes_partitioned AS DYNAMIC
      // PARTITIONING IS NOT YET SUPPORTED
      TestTable("episodes_part",
        s"""CREATE TABLE episodes_part (title STRING, air_date STRING, doctor INT)
           |PARTITIONED BY (doctor_pt INT)
           |STORED AS avro
           |TBLPROPERTIES (
           |  'avro.schema.literal'='{
           |    "type": "record",
           |    "name": "episodes",
           |    "namespace": "testing.hive.avro.serde",
           |    "fields": [
           |      {
           |          "name": "title",
           |          "type": "string",
           |          "doc": "episode title"
           |      },
           |      {
           |          "name": "air_date",
           |          "type": "string",
           |          "doc": "initial date"
           |      },
           |      {
           |          "name": "doctor",
           |          "type": "int",
           |          "doc": "main actor playing the Doctor in episode"
           |      }
           |    ]
           |  }'
           |)
         """.stripMargin.cmd,
        // WORKAROUND: Required to pass schema to SerDe for partitioned tables.
        // TODO: Pass this automatically from the table to partitions.
        s"""
           |ALTER TABLE episodes_part SET SERDEPROPERTIES (
           |  'avro.schema.literal'='{
           |    "type": "record",
           |    "name": "episodes",
           |    "namespace": "testing.hive.avro.serde",
           |    "fields": [
           |      {
           |          "name": "title",
           |          "type": "string",
           |          "doc": "episode title"
           |      },
           |      {
           |          "name": "air_date",
           |          "type": "string",
           |          "doc": "initial date"
           |      },
           |      {
           |          "name": "doctor",
           |          "type": "int",
           |          "doc": "main actor playing the Doctor in episode"
           |      }
           |    ]
           |  }'
           |)
          """.stripMargin.cmd,
        s"""
          INSERT OVERWRITE TABLE episodes_part PARTITION (doctor_pt=1)
          SELECT title, air_date, doctor FROM episodes
        """.cmd
        ),
      TestTable("src_json",
        s"""CREATE TABLE src_json (json STRING) STORED AS TEXTFILE
         """.stripMargin.cmd,
        s"LOAD DATA LOCAL INPATH '${quoteHiveFile("data/files/json.txt")}' INTO TABLE src_json".cmd)
    )

    hiveQTestUtilTables.foreach(registerTestTable)
  }

  private val loadedTables = new collection.mutable.HashSet[String]

  def getLoadedTables: collection.mutable.HashSet[String] = loadedTables

  def loadTestTable(name: String) {
    if (!(loadedTables contains name)) {
      // Marks the table as loaded first to prevent infinite mutually recursive table loading.
      loadedTables += name
      logDebug(s"Loading test table $name")
      val createCmds =
        testTables.get(name).map(_.commands).getOrElse(sys.error(s"Unknown test table $name"))

      // test tables are loaded lazily, so they may be loaded in the middle a query execution which
      // has already set the execution id.
      if (sparkContext.getLocalProperty(SQLExecution.EXECUTION_ID_KEY) == null) {
        // We don't actually have a `QueryExecution` here, use a fake one instead.
        SQLExecution.withNewExecutionId(this, new QueryExecution(this, OneRowRelation())) {
          createCmds.foreach(_())
        }
      } else {
        createCmds.foreach(_())
      }

      if (cacheTables) {
        new SQLContext(self).cacheTable(name)
      }
    }
  }

  /**
   * Records the UDFs present when the server starts, so we can delete ones that are created by
   * tests.
   */
  protected val originalUDFs: JavaSet[String] = FunctionRegistry.getFunctionNames

  /**
   * Resets the test instance by deleting any table, view, temp view, and UDF that have been created
   */
  def reset() {
    try {
      // HACK: Hive is too noisy by default.
      org.apache.log4j.LogManager.getCurrentLoggers.asScala.foreach { log =>
        val logger = log.asInstanceOf[org.apache.log4j.Logger]
        if (!logger.getName.contains("org.apache.spark")) {
          logger.setLevel(org.apache.log4j.Level.WARN)
        }
      }

      // Clean out the Hive warehouse between each suite
      val warehouseDir = new File(new URI(sparkContext.conf.get("spark.sql.warehouse.dir")).getPath)
      Utils.deleteRecursively(warehouseDir)
      warehouseDir.mkdir()

      sharedState.cacheManager.clearCache()
      loadedTables.clear()
      sessionState.catalog.reset()
      metadataHive.reset()

      // HDFS root scratch dir requires the write all (733) permission. For each connecting user,
      // an HDFS scratch dir: ${hive.exec.scratchdir}/<username> is created, with
      // ${hive.scratch.dir.permission}. To resolve the permission issue, the simplest way is to
      // delete it. Later, it will be re-created with the right permission.
      val hadoopConf = sessionState.newHadoopConf()
      val location = new Path(hadoopConf.get(ConfVars.SCRATCHDIR.varname))
      val fs = location.getFileSystem(hadoopConf)
      fs.delete(location, true)

      // Some tests corrupt this value on purpose, which breaks the RESET call below.
      sessionState.conf.setConfString("fs.defaultFS", new File(".").toURI.toString)
      // It is important that we RESET first as broken hooks that might have been set could break
      // other sql exec here.
      metadataHive.runSqlHive("RESET")
      // For some reason, RESET does not reset the following variables...
      // https://issues.apache.org/jira/browse/HIVE-9004
      metadataHive.runSqlHive("set hive.table.parameters.default=")
      // Lots of tests fail if we do not change the partition whitelist from the default.
      metadataHive.runSqlHive("set hive.metastore.partition.name.whitelist.pattern=.*")

      sessionState.catalog.setCurrentDatabase("default")
    } catch {
      case e: Exception =>
        logError("FATAL ERROR: Failed to reset TestDB state.", e)
    }
  }

}


private[hive] class TestHiveQueryExecution(
    sparkSession: TestHiveSparkSession,
    logicalPlan: LogicalPlan)
  extends QueryExecution(sparkSession, logicalPlan) with Logging {

  def this(sparkSession: TestHiveSparkSession, sql: String) {
    this(sparkSession, sparkSession.sessionState.sqlParser.parsePlan(sql))
  }

  def this(sql: String) {
    this(TestHive.sparkSession, sql)
  }

  override lazy val analyzed: LogicalPlan = {
    val describedTables = logical match {
      case CacheTableCommand(tbl, _, _) => tbl.table :: Nil
      case _ => Nil
    }

    // Make sure any test tables referenced are loaded.
    val referencedTables =
      describedTables ++
        logical.collect { case UnresolvedRelation(tableIdent) => tableIdent.table }
    val resolver = sparkSession.sessionState.conf.resolver
    val referencedTestTables = sparkSession.testTables.keys.filter { testTable =>
      referencedTables.exists(resolver(_, testTable))
    }
    logDebug(s"Query references test tables: ${referencedTestTables.mkString(", ")}")
    referencedTestTables.foreach(sparkSession.loadTestTable)
    // Proceed with analysis.
    sparkSession.sessionState.analyzer.executeAndCheck(logical)
  }
}


private[hive] object TestHiveContext {

  /**
   * A map used to store all confs that need to be overridden in sql/hive unit tests.
   */
  val overrideConfs: Map[String, String] =
    Map(
      // Fewer shuffle partitions to speed up testing.
      SQLConf.SHUFFLE_PARTITIONS.key -> "5"
    )

  def makeWarehouseDir(): File = {
    val warehouseDir = Utils.createTempDir(namePrefix = "warehouse")
    warehouseDir.delete()
    warehouseDir
  }

  def makeScratchDir(): File = {
    val scratchDir = Utils.createTempDir(namePrefix = "scratch")
    scratchDir.delete()
    scratchDir
  }

}

private[sql] class TestHiveSessionStateBuilder(
    session: SparkSession,
    state: Option[SessionState])
  extends HiveSessionStateBuilder(session, state)
  with WithTestConf {

  override def overrideConfs: Map[String, String] = TestHiveContext.overrideConfs

  override def createQueryExecution: (LogicalPlan) => QueryExecution = { plan =>
    new TestHiveQueryExecution(session.asInstanceOf[TestHiveSparkSession], plan)
  }

  override protected def newBuilder: NewBuilder = new TestHiveSessionStateBuilder(_, _)
}








package com.ardentex.spark.hiveudf

import java.util.Locale

import org.apache.hadoop.io.{DoubleWritable, FloatWritable, LongWritable}
import org.scalatest.{FlatSpec, Matchers}

class FormatCurrencySpec extends FlatSpec with Matchers {
  val udf = new FormatCurrency

  def doTest(data: Array[(Double, String)], lang: String): Unit = {
    for ((input, expected) <- data)
    //udf.evaluate(new DoubleWritable(input),lang) should be (expected)
    udf.evaluate(input,lang) should be (expected)
  }

  "FormatCurrency" should "return a valid currency string for the US locale" in {
    val data = Array(
      (2999100.01, "$2,999,100.01"),
      (.11,        "$0.11"),
      (999.0,      "$999.00"),
      (1122.0,     "$1,122.00")
    )

    doTest(data, "en_US")
  }

  it should "return a valid currency string for the en_GB locale" in {
    val data = Array(
      (2999100.01, "£2,999,100.01"),
      (.11,        "£0.11"),
      (999.0,      "£999.00"),
      (1122.0,     "£1,122.00")
    )

    doTest(data, "en_GB")
  }

  it should "return a currency string in the default locale for a bad locale string" in {
    withDefaultLocale("fr", "FR") {
      val data = Array(
        (2999100.01, "2 999 100,01 €"),
        (.11,        "0,11 €"),
        (999.0,      "999,00 €"),
        (1122.0,     "1 122,00 €")
      )

      doTest(data, "nnyy")
    }
  }

  it should "return a currency string in the default locale if no locale is specified" in {
    withDefaultLocale("se", "SE") {
      val data = Array(
        (2999100.01, "SEK 2,999,100.01"),
        (.11,        "SEK 0.11"),
        (999.0,      "SEK 999.00"),
        (1122.0,     "SEK 1,122.00")
      )

      doTest(data, null)
    }
  }

  it should "return a valid currency string for the jp_JP locale" in {
    val data = Array(
      (2999100.01, "JPY 2,999,100"),
      (.11,        "JPY 0"),
      (999.0,      "JPY 999"),
      (1122.0,     "JPY 1,122")
    )

    doTest(data, "jp_JP")
  }


  it should "return an empty string for a null input" in {
    udf.evaluate(null, null) should be ("")
  }

  private def withDefaultLocale(lang: String, variant: String)
                               (code: => Unit): Unit = {
    val locale = Locale.getDefault
    val newLocale = new Locale(lang, variant)
    Locale.setDefault(newLocale)

    try {
      code
    }

    finally {
      Locale.setDefault(locale)
    }

  }
}



package com.ardentex.spark.hiveudf

import java.sql.Timestamp
import java.text.SimpleDateFormat
import java.util.Date

import org.apache.hadoop.hive.ql.exec.UDF

/** This UDF takes a SQL Timestamp and converts it to a string, using a
  * Java `SimpleDateFormat` string to dictate the format.
  */
class FormatTimestamp extends UDF {

  def evaluate(t: Timestamp, fmt: String): String = {
    val optRes =
      for { ts <- Option(t)     // null check
            f  <- Option(fmt) } // null check
      yield try {
        val formatter = new SimpleDateFormat(fmt)
        formatter.format(new Date(t.getTime))
      }
      catch {
        // Bad format. Return Timestmap.toString. (We could return
        // an error message, as well, but this is fine for now.)
        case _: IllegalArgumentException =>
          t.toString
      }

    optRes.getOrElse("")
  }
}


package com.ardentex.spark.hiveudf

import java.sql.Timestamp
import java.text.SimpleDateFormat
import java.util.Date

import org.scalatest.{FlatSpec, Matchers}

class FormatTimestampSpec extends FlatSpec with Matchers {
  val udf = new FormatTimestamp
  val timestampParser = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")

  "FormatTimestamp.evaluate" should "properly format a timestamp" in {
    val format = "yyyy/MMM/dd hh:mm a"
    val data = Array(
      ("2013-01-29 23:49:03", "2013/Jan/29 11:49 PM"),
      ("1941-09-03 10:01:53", "1941/Sep/03 10:01 AM"),
      ("1888-07-01 01:01:59", "1888/Jul/01 01:01 AM")
    )

    for ((input, expected) <- data) {
      val ts = new Timestamp(timestampParser.parse(input).getTime)
      udf.evaluate(ts, format) should be (expected)
    }
  }

  it should "return an empty string when the timestamp is null" in {
    udf.evaluate(null, "yyyy-MM-dd") should be ("")
  }

  it should "return an empty string when the format is null" in {
    udf.evaluate(new Timestamp((new Date).getTime), null) should be ("")
  }

  it should "return Timestamp.toString when the format is bad" in {
    val ts = new Timestamp((new Date).getTime)
    udf.evaluate(ts, "bad format") should be (ts.toString)
  }
}

package com.ardentex.spark.hiveudf

import org.apache.hadoop.hive.ql.exec.UDF
import org.apache.hadoop.io.LongWritable

/** This UDF takes a long integer and converts it to a hexadecimal string.
  */
class ToHex extends UDF {

  def evaluate(n: LongWritable): String = {
    Option(n)
      .map { num =>
        // Use Scala string interpolation. It's the easiest way, and it's
        // type-safe, unlike String.format().
        f"0x${num.get}%x"
  }
      .getOrElse("")
  }
}


package com.ardentex.spark.hiveudf

import org.apache.hadoop.io.LongWritable
import org.scalatest.{FlatSpec, Matchers}

class ToHexSpec extends FlatSpec with Matchers {
  val udf = new ToHex

  "ToHex.evaluate" should "return a valid hex string" in {
    val data = Array(
      (234908234222L, "0x36b19f31ee"),
      (0L,            "0x0"),
      (Long.MaxValue, "0x7fffffffffffffff"),
      (-10L,          "0xfffffffffffffff6")
    )

    for ((input, expected) <- data) {
      udf.evaluate(new LongWritable(input)) should be (expected)
    }
  }

  it should "return an empty string for a null input" in {
    udf.evaluate(null) should be ("")
  }
}



import java.sql.Timestamp
import java.text.SimpleDateFormat
import java.util.Date

case class Person(firstName: String, lastName: String, birthDate: Timestamp, salary: Double, children: Int)

val fmt = new SimpleDateFormat("yyyy-MM-dd")

val people = Array(
    Person("Joe", "Smith", new Timestamp(fmt.parse("1993-10-20").getTime), 70000.0, 2),
    Person("Jenny", "Harmon", new Timestamp(fmt.parse("1987-08-02").getTime), 94000.0, 1)
)

// Replace spark.sparkContext with sc if you're using Spark 1.x.
val df = spark.createDataFrame(spark.sparkContext.parallelize(people))

// Replace spark with sqlContext if  you're using Spark 1.x.
spark.sql("CREATE TEMPORARY FUNCTION toHex AS 'com.ardentex.spark.hiveudf.ToHex'")
spark.sql("CREATE TEMPORARY FUNCTION datestring AS 'com.ardentex.spark.hiveudf.FormatTimestamp'")
spark.sql("CREATE TEMPORARY FUNCTION currency AS 'com.ardentex.spark.hiveudf.FormatCurrency'")

// Replace createOrReplaceTempView with registerTempTable if you're using
// Spark 1.x
df.createOrReplaceTempView("people")
val df2 = spark.sql("SELECT firstName, lastName, datestring(birthDate, 'MMMM dd, yyyy') as birthDate, currency(salary, 'en_US') as salary, toHex(children) as hexChildren FROM people")




