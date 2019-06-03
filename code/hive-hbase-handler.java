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

package org.apache.hadoop.hive.hbase;

import java.io.IOException;
import java.util.Properties;

import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hive.ql.plan.ExprNodeDesc;
import org.apache.hadoop.hive.ql.plan.TableDesc;
import org.apache.hadoop.hive.serde2.Deserializer;
import org.apache.hadoop.hive.serde2.SerDeException;
import org.apache.hadoop.mapred.JobConf;

public abstract class AbstractHBaseKeyFactory implements HBaseKeyFactory {

    protected HBaseSerDeParameters hbaseParams;
    protected ColumnMappings.ColumnMapping keyMapping;
    protected Properties properties;

    @Override
    public void init(HBaseSerDeParameters hbaseParam, Properties properties) throws SerDeException {
        this.hbaseParams = hbaseParam;
        this.keyMapping = hbaseParam.getKeyColumnMapping();
        this.properties = properties;
    }

    @Override
    public void configureJobConf(TableDesc tableDesc, JobConf jobConf) throws IOException {
        TableMapReduceUtil.addDependencyJars(jobConf, getClass());
    }

    @Override
    public DecomposedPredicate decomposePredicate(JobConf jobConf, Deserializer deserializer, ExprNodeDesc predicate) {
        return HBaseStorageHandler.decomposePredicate(jobConf, (HBaseSerDe) deserializer, predicate);
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
package org.apache.hadoop.hive.hbase;

        import java.util.ArrayList;
        import java.util.List;

        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.hive.ql.index.IndexPredicateAnalyzer;
        import org.apache.hadoop.hive.ql.index.IndexSearchCondition;
        import org.apache.hadoop.hive.ql.metadata.HiveStoragePredicateHandler.DecomposedPredicate;
        import org.apache.hadoop.hive.ql.plan.ExprNodeDesc;
        import org.apache.hadoop.hive.ql.plan.ExprNodeGenericFuncDesc;

/**
 * Simple abstract class to help with creation of a {@link DecomposedPredicate}. In order to create
 * one, consumers should extend this class and override the "getScanRange" method to define the
 * start/stop keys and/or filters on their hbase scans
 * */
public abstract class AbstractHBaseKeyPredicateDecomposer {

    public static final Logger LOG = LoggerFactory.getLogger(AbstractHBaseKeyPredicateDecomposer.class);

    public DecomposedPredicate decomposePredicate(String keyColName, ExprNodeDesc predicate) {
        IndexPredicateAnalyzer analyzer = IndexPredicateAnalyzer.createAnalyzer(true);
        analyzer.allowColumnName(keyColName);
        analyzer.setAcceptsFields(true);
        analyzer.setFieldValidator(getFieldValidator());

        DecomposedPredicate decomposed = new DecomposedPredicate();

        List<IndexSearchCondition> conditions = new ArrayList<IndexSearchCondition>();
        decomposed.residualPredicate =
                (ExprNodeGenericFuncDesc) analyzer.analyzePredicate(predicate, conditions);
        if (!conditions.isEmpty()) {
            decomposed.pushedPredicate = analyzer.translateSearchConditions(conditions);
            try {
                decomposed.pushedPredicateObject = getScanRange(conditions);
            } catch (Exception e) {
                LOG.warn("Failed to decompose predicates", e);
                return null;
            }
        }

        return decomposed;
    }

    /**
     * Get the scan range that specifies the start/stop keys and/or filters to be applied onto the
     * hbase scan
     * */
    protected abstract HBaseScanRange getScanRange(List<IndexSearchCondition> searchConditions)
            throws Exception;

    /**
     * Get an optional {@link IndexPredicateAnalyzer.FieldValidator validator}. A validator can be
     * used to optinally filter out the predicates which need not be decomposed. By default this
     * method returns {@code null} which means that all predicates are pushed but consumers can choose
     * to override this to provide a custom validator as well.
     * */
    protected IndexPredicateAnalyzer.FieldValidator getFieldValidator() {
        return null;
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

/*
 * This source file is based on code taken from SQLLine 1.0.2
 * See SQLLine notice in LICENSE
 */

package org.apache.hadoop.hive.hbase;

        import java.util.ArrayList;
        import java.util.Arrays;
        import java.util.Iterator;
        import java.util.List;
        import java.util.Properties;

        import org.apache.commons.lang.StringUtils;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hive.serde.serdeConstants;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector.PrimitiveCategory;
        import org.apache.hadoop.hive.serde2.typeinfo.MapTypeInfo;
        import org.apache.hadoop.hive.serde2.typeinfo.PrimitiveTypeInfo;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;

        import com.google.common.collect.Iterators;

public class ColumnMappings implements Iterable<ColumnMappings.ColumnMapping> {

    private final int keyIndex;
    private final int timestampIndex;
    private final ColumnMapping[] columnsMapping;

    public ColumnMappings(List<ColumnMapping> columnMapping, int keyIndex) {
        this(columnMapping, keyIndex, -1);
    }

    public ColumnMappings(List<ColumnMapping> columnMapping, int keyIndex, int timestampIndex) {
        this.columnsMapping = columnMapping.toArray(new ColumnMapping[columnMapping.size()]);
        this.keyIndex = keyIndex;
        this.timestampIndex = timestampIndex;
    }

    @Override
    public Iterator<ColumnMapping> iterator() {
        return Iterators.forArray(columnsMapping);
    }

    public int size() {
        return columnsMapping.length;
    }

    String toNamesString(Properties tbl, String autogenerate) {
        if (autogenerate != null && autogenerate.equals("true")) {
            StringBuilder sb = new StringBuilder();
            HBaseSerDeHelper.generateColumns(tbl, Arrays.asList(columnsMapping), sb);
            return sb.toString();
        }

        return StringUtils.EMPTY; // return empty string
    }

    String toTypesString(Properties tbl, Configuration conf, String autogenerate)
            throws SerDeException {
        StringBuilder sb = new StringBuilder();

        if (autogenerate != null && autogenerate.equals("true")) {
            HBaseSerDeHelper.generateColumnTypes(tbl, Arrays.asList(columnsMapping), sb, conf);
        } else {
            for (ColumnMapping colMap : columnsMapping) {
                if (sb.length() > 0) {
                    sb.append(":");
                }
                if (colMap.hbaseRowKey) {
                    // the row key column becomes a STRING
                    sb.append(serdeConstants.STRING_TYPE_NAME);
                } else if (colMap.qualifierName == null) {
                    // a column family become a MAP
                    sb.append(serdeConstants.MAP_TYPE_NAME + "<" + serdeConstants.STRING_TYPE_NAME + ","
                            + serdeConstants.STRING_TYPE_NAME + ">");
                } else {
                    // an individual column becomes a STRING
                    sb.append(serdeConstants.STRING_TYPE_NAME);
                }
            }
        }

        return sb.toString();
    }

    void setHiveColumnDescription(String serdeName,
                                  List<String> columnNames, List<TypeInfo> columnTypes) throws SerDeException {
        if (columnsMapping.length != columnNames.size()) {
            throw new SerDeException(serdeName + ": columns has " + columnNames.size() +
                    " elements while hbase.columns.mapping has " + columnsMapping.length + " elements" +
                    " (counting the key if implicit)");
        }

        // check that the mapping schema is right;
        // check that the "column-family:" is mapped to  Map<key,?>
        // where key extends LazyPrimitive<?, ?> and thus has type Category.PRIMITIVE
        for (int i = 0; i < columnNames.size(); i++) {
            ColumnMapping colMap = columnsMapping[i];
            colMap.columnName = columnNames.get(i);
            colMap.columnType = columnTypes.get(i);
            if (colMap.qualifierName == null && !colMap.hbaseRowKey && !colMap.hbaseTimestamp) {
                TypeInfo typeInfo = columnTypes.get(i);
                if ((typeInfo.getCategory() != ObjectInspector.Category.MAP) ||
                        (((MapTypeInfo) typeInfo).getMapKeyTypeInfo().getCategory()
                                != ObjectInspector.Category.PRIMITIVE)) {

                    throw new SerDeException(
                            serdeName + ": hbase column family '" + colMap.familyName
                                    + "' should be mapped to Map<? extends LazyPrimitive<?, ?>,?>, that is "
                                    + "the Key for the map should be of primitive type, but is mapped to "
                                    + typeInfo.getTypeName());
                }
            }
            if (colMap.hbaseTimestamp) {
                TypeInfo typeInfo = columnTypes.get(i);
                if (!colMap.isCategory(PrimitiveCategory.TIMESTAMP) &&
                        !colMap.isCategory(PrimitiveCategory.LONG)) {
                    throw new SerDeException(serdeName + ": timestamp columns should be of " +
                            "timestamp or bigint type, but is mapped to " + typeInfo.getTypeName());
                }
            }
        }
    }

    /**
     * Utility method for parsing a string of the form '-,b,s,-,s:b,...' as a means of specifying
     * whether to use a binary or an UTF string format to serialize and de-serialize primitive
     * data types like boolean, byte, short, int, long, float, and double. This applies to
     * regular columns and also to map column types which are associated with an HBase column
     * family. For the map types, we apply the specification to the key or the value provided it
     * is one of the above primitive types. The specifier is a colon separated value of the form
     * -:s, or b:b where we have 's', 'b', or '-' on either side of the colon. 's' is for string
     * format storage, 'b' is for native fixed width byte oriented storage, and '-' uses the
     * table level default.
     *
     * @param hbaseTableDefaultStorageType - the specification associated with the table property
     *        hbase.table.default.storage.type
     * @throws SerDeException on parse error.
     */
    void parseColumnStorageTypes(String hbaseTableDefaultStorageType) throws SerDeException {

        boolean tableBinaryStorage = false;

        if (hbaseTableDefaultStorageType != null && !"".equals(hbaseTableDefaultStorageType)) {
            if (hbaseTableDefaultStorageType.equals("binary")) {
                tableBinaryStorage = true;
            } else if (!hbaseTableDefaultStorageType.equals("string")) {
                throw new SerDeException("Error: " + HBaseSerDe.HBASE_TABLE_DEFAULT_STORAGE_TYPE +
                        " parameter must be specified as" +
                        " 'string' or 'binary'; '" + hbaseTableDefaultStorageType +
                        "' is not a valid specification for this table/serde property.");
            }
        }

        // parse the string to determine column level storage type for primitive types
        // 's' is for variable length string format storage
        // 'b' is for fixed width binary storage of bytes
        // '-' is for table storage type, which defaults to UTF8 string
        // string data is always stored in the default escaped storage format; the data types
        // byte, short, int, long, float, and double have a binary byte oriented storage option
        for (ColumnMapping colMap : columnsMapping) {
            TypeInfo colType = colMap.columnType;
            String mappingSpec = colMap.mappingSpec;
            String[] mapInfo = mappingSpec.split("#");
            String[] storageInfo = null;

            if (mapInfo.length == 2) {
                storageInfo = mapInfo[1].split(":");
            }

            if (storageInfo == null) {

                // use the table default storage specification
                if (colType.getCategory() == ObjectInspector.Category.PRIMITIVE) {
                    if (!colType.getTypeName().equals(serdeConstants.STRING_TYPE_NAME)) {
                        colMap.binaryStorage.add(tableBinaryStorage);
                    } else {
                        colMap.binaryStorage.add(false);
                    }
                } else if (colType.getCategory() == ObjectInspector.Category.MAP) {
                    TypeInfo keyTypeInfo = ((MapTypeInfo) colType).getMapKeyTypeInfo();
                    TypeInfo valueTypeInfo = ((MapTypeInfo) colType).getMapValueTypeInfo();

                    if (keyTypeInfo.getCategory() == ObjectInspector.Category.PRIMITIVE &&
                            !keyTypeInfo.getTypeName().equals(serdeConstants.STRING_TYPE_NAME)) {
                        colMap.binaryStorage.add(tableBinaryStorage);
                    } else {
                        colMap.binaryStorage.add(false);
                    }

                    if (valueTypeInfo.getCategory() == ObjectInspector.Category.PRIMITIVE &&
                            !valueTypeInfo.getTypeName().equals(serdeConstants.STRING_TYPE_NAME)) {
                        colMap.binaryStorage.add(tableBinaryStorage);
                    } else {
                        colMap.binaryStorage.add(false);
                    }
                } else {
                    colMap.binaryStorage.add(false);
                }

            } else if (storageInfo.length == 1) {
                // we have a storage specification for a primitive column type
                String storageOption = storageInfo[0];

                if ((colType.getCategory() == ObjectInspector.Category.MAP) ||
                        !(storageOption.equals("-") || "string".startsWith(storageOption) ||
                                "binary".startsWith(storageOption))) {
                    throw new SerDeException("Error: A column storage specification is one of the following:"
                            + " '-', a prefix of 'string', or a prefix of 'binary'. "
                            + storageOption + " is not a valid storage option specification for "
                            + colMap.columnName);
                }

                if (colType.getCategory() == ObjectInspector.Category.PRIMITIVE &&
                        !colType.getTypeName().equals(serdeConstants.STRING_TYPE_NAME)) {

                    if ("-".equals(storageOption)) {
                        colMap.binaryStorage.add(tableBinaryStorage);
                    } else if ("binary".startsWith(storageOption)) {
                        colMap.binaryStorage.add(true);
                    } else {
                        colMap.binaryStorage.add(false);
                    }
                } else {
                    colMap.binaryStorage.add(false);
                }

            } else if (storageInfo.length == 2) {
                // we have a storage specification for a map column type

                String keyStorage = storageInfo[0];
                String valStorage = storageInfo[1];

                if ((colType.getCategory() != ObjectInspector.Category.MAP) ||
                        !(keyStorage.equals("-") || "string".startsWith(keyStorage) ||
                                "binary".startsWith(keyStorage)) ||
                        !(valStorage.equals("-") || "string".startsWith(valStorage) ||
                                "binary".startsWith(valStorage))) {
                    throw new SerDeException("Error: To specify a valid column storage type for a Map"
                            + " column, use any two specifiers from '-', a prefix of 'string', "
                            + " and a prefix of 'binary' separated by a ':'."
                            + " Valid examples are '-:-', 's:b', etc. They specify the storage type for the"
                            + " key and value parts of the Map<?,?> respectively."
                            + " Invalid storage specification for column "
                            + colMap.columnName
                            + "; " + storageInfo[0] + ":" + storageInfo[1]);
                }

                TypeInfo keyTypeInfo = ((MapTypeInfo) colType).getMapKeyTypeInfo();
                TypeInfo valueTypeInfo = ((MapTypeInfo) colType).getMapValueTypeInfo();

                if (keyTypeInfo.getCategory() == ObjectInspector.Category.PRIMITIVE &&
                        !keyTypeInfo.getTypeName().equals(serdeConstants.STRING_TYPE_NAME)) {

                    if (keyStorage.equals("-")) {
                        colMap.binaryStorage.add(tableBinaryStorage);
                    } else if ("binary".startsWith(keyStorage)) {
                        colMap.binaryStorage.add(true);
                    } else {
                        colMap.binaryStorage.add(false);
                    }
                } else {
                    colMap.binaryStorage.add(false);
                }

                if (valueTypeInfo.getCategory() == ObjectInspector.Category.PRIMITIVE &&
                        !valueTypeInfo.getTypeName().equals(serdeConstants.STRING_TYPE_NAME)) {
                    if (valStorage.equals("-")) {
                        colMap.binaryStorage.add(tableBinaryStorage);
                    } else if ("binary".startsWith(valStorage)) {
                        colMap.binaryStorage.add(true);
                    } else {
                        colMap.binaryStorage.add(false);
                    }
                } else {
                    colMap.binaryStorage.add(false);
                }

                if (colMap.binaryStorage.size() != 2) {
                    throw new SerDeException("Error: In parsing the storage specification for column "
                            + colMap.columnName);
                }

            } else {
                // error in storage specification
                throw new SerDeException("Error: " + HBaseSerDe.HBASE_COLUMNS_MAPPING + " storage specification "
                        + mappingSpec + " is not valid for column: "
                        + colMap.columnName);
            }
        }
    }

    public ColumnMapping getKeyMapping() {
        return columnsMapping[keyIndex];
    }

    public ColumnMapping getTimestampMapping() {
        return timestampIndex < 0 ? null : columnsMapping[timestampIndex];
    }

    public int getKeyIndex() {
        return keyIndex;
    }

    public int getTimestampIndex() {
        return timestampIndex;
    }

    public ColumnMapping[] getColumnsMapping() {
        return columnsMapping;
    }

    /**
     * Represents a mapping from a single Hive column to an HBase column qualifier, column family or row key.
     */
    // todo use final fields
    public static class ColumnMapping {

        ColumnMapping() {
            binaryStorage = new ArrayList<Boolean>(2);
        }

        String columnName;
        TypeInfo columnType;

        String familyName;
        String qualifierName;
        byte[] familyNameBytes;
        byte[] qualifierNameBytes;
        List<Boolean> binaryStorage;
        boolean hbaseRowKey;
        boolean hbaseTimestamp;
        String mappingSpec;
        String qualifierPrefix;
        byte[] qualifierPrefixBytes;
        boolean doPrefixCut;

        public String getColumnName() {
            return columnName;
        }

        public TypeInfo getColumnType() {
            return columnType;
        }

        public String getFamilyName() {
            return familyName;
        }

        public String getQualifierName() {
            return qualifierName;
        }

        public byte[] getFamilyNameBytes() {
            return familyNameBytes;
        }

        public byte[] getQualifierNameBytes() {
            return qualifierNameBytes;
        }

        public List<Boolean> getBinaryStorage() {
            return binaryStorage;
        }

        public boolean isHbaseRowKey() {
            return hbaseRowKey;
        }

        public String getMappingSpec() {
            return mappingSpec;
        }

        public String getQualifierPrefix() {
            return qualifierPrefix;
        }

        public byte[] getQualifierPrefixBytes() {
            return qualifierPrefixBytes;
        }

        public boolean isDoPrefixCut(){
            return doPrefixCut;
        }

        public boolean isCategory(ObjectInspector.Category category) {
            return columnType.getCategory() == category;
        }

        public boolean isCategory(PrimitiveCategory category) {
            return columnType.getCategory() == ObjectInspector.Category.PRIMITIVE &&
                    ((PrimitiveTypeInfo)columnType).getPrimitiveCategory() == category;
        }

        public boolean isComparable() {
            return binaryStorage.get(0) || isCategory(PrimitiveCategory.STRING);
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.lang.reflect.Constructor;
        import java.util.Properties;

        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
        import org.apache.hadoop.hive.ql.plan.TableDesc;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazySimpleStructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.mapred.JobConf;

public class CompositeHBaseKeyFactory<T extends HBaseCompositeKey> extends DefaultHBaseKeyFactory {

    public static final Logger LOG = LoggerFactory.getLogger(CompositeHBaseKeyFactory.class);

    private final Class<T> keyClass;
    private final Constructor constructor;

    private Configuration conf;

    public CompositeHBaseKeyFactory(Class<T> keyClass) throws Exception {
        // see javadoc of HBaseCompositeKey
        this.keyClass = keyClass;
        this.constructor = keyClass.getDeclaredConstructor(
                LazySimpleStructObjectInspector.class, Properties.class, Configuration.class);
    }

    @Override
    public void configureJobConf(TableDesc tableDesc, JobConf jobConf) throws IOException {
        super.configureJobConf(tableDesc, jobConf);
        TableMapReduceUtil.addDependencyJars(jobConf, keyClass);
    }

    @Override
    public T createKey(ObjectInspector inspector) throws SerDeException {
        try {
            return (T) constructor.newInstance(inspector, properties, hbaseParams.getBaseConfiguration());
        } catch (Exception e) {
            throw new SerDeException(e);
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

package org.apache.hadoop.hive.hbase;
        import java.io.DataInput;
        import java.io.EOFException;
        import java.io.IOException;
        import java.io.InputStream;

public class DataInputInputStream extends InputStream {

    private final DataInput dataInput;
    public DataInputInputStream(DataInput dataInput) {
        this.dataInput = dataInput;
    }
    @Override
    public int read() throws IOException {
        try {
            return dataInput.readUnsignedByte();
        } catch (EOFException e) {
            // contract on EOF differs between DataInput and InputStream
            return -1;
        }
    }

    public static InputStream from(DataInput dataInput) {
        if(dataInput instanceof InputStream) {
            return (InputStream)dataInput;
        }
        return new DataInputInputStream(dataInput);
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

package org.apache.hadoop.hive.hbase;
        import java.io.DataOutput;
        import java.io.IOException;
        import java.io.OutputStream;

public class DataOutputOutputStream extends OutputStream {

    private final DataOutput dataOutput;
    public DataOutputOutputStream(DataOutput dataOutput) {
        this.dataOutput = dataOutput;
    }
    @Override
    public void write(int b) throws IOException {
        dataOutput.write(b);
    }


    public static OutputStream from(DataOutput dataOutput) {
        if(dataOutput instanceof OutputStream) {
            return (OutputStream)dataOutput;
        }
        return new DataOutputOutputStream(dataOutput);
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.util.Properties;

        import com.google.common.annotations.VisibleForTesting;

        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.lazy.LazySerDeParameters;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory.ObjectInspectorOptions;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;

public class DefaultHBaseKeyFactory extends AbstractHBaseKeyFactory implements HBaseKeyFactory {

    protected LazySerDeParameters serdeParams;
    protected HBaseRowSerializer serializer;

    @Override
    public void init(HBaseSerDeParameters hbaseParam, Properties properties) throws SerDeException {
        super.init(hbaseParam, properties);
        this.serdeParams = hbaseParam.getSerdeParams();
        this.serializer = new HBaseRowSerializer(hbaseParam);
    }

    @Override
    public ObjectInspector createKeyObjectInspector(TypeInfo type) throws SerDeException {
        return LazyFactory.createLazyObjectInspector(type, 1, serdeParams, ObjectInspectorOptions.JAVA);
    }

    @Override
    public LazyObjectBase createKey(ObjectInspector inspector) throws SerDeException {
        return LazyFactory.createLazyObject(inspector, keyMapping.binaryStorage.get(0));
    }

    @Override
    public byte[] serializeKey(Object object, StructField field) throws IOException {
        return serializer.serializeKeyField(object, field, keyMapping);
    }

    @VisibleForTesting
    static DefaultHBaseKeyFactory forTest(LazySerDeParameters params, ColumnMappings mappings) {
        DefaultHBaseKeyFactory factory = new DefaultHBaseKeyFactory();
        factory.serdeParams = params;
        factory.keyMapping = mappings.getKeyMapping();
        return factory;
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

package org.apache.hadoop.hive.hbase;

        import java.util.ArrayList;
        import java.util.Collections;
        import java.util.List;
        import java.util.Map;

        import org.apache.hadoop.hive.serde2.lazy.ByteArrayRef;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyObject;
        import org.apache.hadoop.hive.serde2.lazy.LazyStruct;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazySimpleStructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;

/**
 * HBaseCompositeKey extension of LazyStruct. All complex composite keys should extend this class
 * and override the {@link LazyStruct#getField(int)} method where fieldID corresponds to the ID of a
 * key in the composite key.
 * <br>
 * For example, for a composite key <i>"/part1/part2/part3"</i>, <i>part1</i> will have an id
 * <i>0</i>, <i>part2</i> will have an id <i>1</i> and <i>part3</i> will have an id <i>2</i>. Custom
 * implementations of getField(fieldID) should return the value corresponding to that fieldID. So,
 * for the above example, the value returned for <i>getField(0)</i> should be <i>part1</i>,
 * <i>getField(1)</i> should be <i>part2</i> and <i>getField(2)</i> should be <i>part3</i>.
 *
 *
 * <br>
 * All custom implementation are expected to have a constructor of the form:
 *
 * <pre>
 * MyCustomCompositeKey(LazySimpleStructObjectInspector oi, Properties tbl, Configuration conf)
 * </pre>
 *
 *
 * */
public class HBaseCompositeKey extends LazyStruct {

    public HBaseCompositeKey(LazySimpleStructObjectInspector oi) {
        super(oi);
    }

    @Override
    public ArrayList<Object> getFieldsAsList() {
        ArrayList<Object> allFields = new ArrayList<Object>();

        List<? extends StructField> fields = oi.getAllStructFieldRefs();

        for (int i = 0; i < fields.size(); i++) {
            allFields.add(getField(i));
        }

        return allFields;
    }

    /**
     * Create an initialize a {@link LazyObject} with the given bytes for the given fieldID.
     *
     * @param fieldID
     *          field for which the object is to be created
     * @param bytes
     *          value with which the object is to be initialized with
     * @return initialized {@link LazyObject}
     * */
    public LazyObject<? extends ObjectInspector> toLazyObject(int fieldID, byte[] bytes) {
        ObjectInspector fieldOI = oi.getAllStructFieldRefs().get(fieldID).getFieldObjectInspector();

        LazyObject<? extends ObjectInspector> lazyObject = LazyFactory
                .createLazyObject(fieldOI);

        ByteArrayRef ref = new ByteArrayRef();

        ref.setData(bytes);

        // initialize the lazy object
        lazyObject.init(ref, 0, ref.getData().length);

        return lazyObject;
    }

    /**
     * Return the different parts of the key. By default, this returns an empty map. Consumers can
     * choose to override this to provide their own names and types of parts of the key.
     *
     * @return map of parts name to their type
     * */
    public Map<String, String> getParts() {
        return Collections.emptyMap();
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

package org.apache.hadoop.hive.hbase;

        import org.apache.hadoop.hive.ql.metadata.HiveStoragePredicateHandler;
        import org.apache.hadoop.hive.ql.plan.TableDesc;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
        import org.apache.hadoop.mapred.JobConf;

        import java.io.IOException;
        import java.util.Properties;

/**
 * Provides custom implementation of object and object inspector for hbase key.
 * The key object should implement LazyObjectBase.
 *
 * User can optionally implement HiveStoragePredicateHandler for handling filter predicates
 */
public interface HBaseKeyFactory extends HiveStoragePredicateHandler {

    /**
     * initialize factory with properties
     */
    void init(HBaseSerDeParameters hbaseParam, Properties properties) throws SerDeException;

    /**
     * create custom object inspector for hbase key
     * @param type type information
     */
    ObjectInspector createKeyObjectInspector(TypeInfo type) throws SerDeException;

    /**
     * create custom object for hbase key
     * @param inspector OI create by {@link HBaseKeyFactory#createKeyObjectInspector}
     */
    LazyObjectBase createKey(ObjectInspector inspector) throws SerDeException;

    /**
     * serialize hive object in internal format of custom key
     *
     * @param object
     * @param field
     *
     * @return true if it's not null
     * @throws java.io.IOException
     */
    byte[] serializeKey(Object object, StructField field) throws IOException;

    /**
     * configure jobConf for this factory
     *
     * @param tableDesc
     * @param jobConf
     */
    void configureJobConf(TableDesc tableDesc, JobConf jobConf) throws IOException;
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

package org.apache.hadoop.hive.hbase;

        import org.apache.commons.lang3.StringUtils;
        import org.apache.hadoop.hive.hbase.struct.HBaseValueFactory;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.LazySerDeParameters;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazyObjectInspectorFactory;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory.ObjectInspectorOptions;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;

        import java.util.ArrayList;
        import java.util.Arrays;
        import java.util.Collections;
        import java.util.List;
        import java.util.Properties;

// Does same thing with LazyFactory#createLazyObjectInspector except that this replaces
// original keyOI with OI which is create by HBaseKeyFactory provided by serde property for hbase
public class HBaseLazyObjectFactory {

    public static ObjectInspector createLazyHBaseStructInspector(
            LazySerDeParameters serdeParams, int index, HBaseKeyFactory keyFactory, List<HBaseValueFactory> valueFactories) throws SerDeException {
        List<TypeInfo> columnTypes = serdeParams.getColumnTypes();
        ArrayList<ObjectInspector> columnObjectInspectors = new ArrayList<ObjectInspector>(
                columnTypes.size());
        for (int i = 0; i < columnTypes.size(); i++) {
            if (i == index) {
                columnObjectInspectors.add(keyFactory.createKeyObjectInspector(columnTypes.get(i)));
            } else {
                columnObjectInspectors.add(valueFactories.get(i).createValueObjectInspector(
                        columnTypes.get(i)));
            }
        }
        return LazyObjectInspectorFactory.getLazySimpleStructObjectInspector(
                serdeParams.getColumnNames(), columnObjectInspectors, null, serdeParams.getSeparators()[0],
                serdeParams, ObjectInspectorOptions.JAVA);
    }

    public static ObjectInspector createLazyHBaseStructInspector(HBaseSerDeParameters hSerdeParams,
                                                                 Properties tbl)
            throws SerDeException {
        List<TypeInfo> columnTypes = hSerdeParams.getColumnTypes();
        ArrayList<ObjectInspector> columnObjectInspectors = new ArrayList<ObjectInspector>(
                columnTypes.size());
        for (int i = 0; i < columnTypes.size(); i++) {
            if (i == hSerdeParams.getKeyIndex()) {
                columnObjectInspectors.add(hSerdeParams.getKeyFactory()
                        .createKeyObjectInspector(columnTypes.get(i)));
            } else {
                columnObjectInspectors.add(hSerdeParams.getValueFactories().get(i)
                        .createValueObjectInspector(columnTypes.get(i)));
            }
        }
        List<String> structFieldComments = StringUtils.isEmpty(tbl.getProperty("columns.comments")) ?
                new ArrayList<>(Collections.nCopies(columnTypes.size(), ""))
                : Arrays.asList(tbl.getProperty("columns.comments").split("\0", columnTypes.size()));

        return LazyObjectInspectorFactory.getLazySimpleStructObjectInspector(
                hSerdeParams.getColumnNames(), columnObjectInspectors, structFieldComments,
                hSerdeParams.getSerdeParams().getSeparators()[0],
                hSerdeParams.getSerdeParams(), ObjectInspectorOptions.JAVA);
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

package org.apache.hadoop.hive.hbase;

        import org.apache.commons.io.IOUtils;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hbase.HColumnDescriptor;
        import org.apache.hadoop.hbase.HTableDescriptor;
        import org.apache.hadoop.hbase.TableName;
        import org.apache.hadoop.hbase.client.Admin;
        import org.apache.hadoop.hbase.client.Connection;
        import org.apache.hadoop.hbase.client.ConnectionFactory;
        import org.apache.hadoop.hbase.util.Bytes;
        import org.apache.hadoop.hive.metastore.HiveMetaHook;
        import org.apache.hadoop.hive.metastore.api.MetaException;
        import org.apache.hadoop.hive.metastore.api.Table;
        import org.apache.hadoop.hive.metastore.utils.MetaStoreUtils;
        import org.apache.hadoop.util.StringUtils;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;

        import java.io.Closeable;
        import java.io.IOException;
        import java.util.HashSet;
        import java.util.Map;
        import java.util.Set;

/**
 * MetaHook for HBase. Updates the table data in HBase too. Not thread safe, and cleanup should
 * be used after usage.
 */
public class HBaseMetaHook implements HiveMetaHook, Closeable {
    private static final Logger LOG = LoggerFactory.getLogger(HBaseMetaHook.class);
    private Configuration hbaseConf;
    private Admin admin;

    public HBaseMetaHook(Configuration hbaseConf) {
        this.hbaseConf = hbaseConf;
    }

    private Admin getHBaseAdmin() throws MetaException {
        try {
            if (admin == null) {
                Connection conn = ConnectionFactory.createConnection(hbaseConf);
                admin = conn.getAdmin();
            }
            return admin;
        } catch (IOException ioe) {
            throw new MetaException(StringUtils.stringifyException(ioe));
        }
    }

    private String getHBaseTableName(Table tbl) {
        // Give preference to TBLPROPERTIES over SERDEPROPERTIES
        // (really we should only use TBLPROPERTIES, so this is just
        // for backwards compatibility with the original specs).
        String tableName = tbl.getParameters().get(HBaseSerDe.HBASE_TABLE_NAME);
        if (tableName == null) {
            //convert to lower case in case we are getting from serde
            tableName = tbl.getSd().getSerdeInfo().getParameters().get(HBaseSerDe.HBASE_TABLE_NAME);
            //standardize to lower case
            if (tableName != null) {
                tableName = tableName.toLowerCase();
            }
        }
        if (tableName == null) {
            tableName = (tbl.getDbName() + "." + tbl.getTableName()).toLowerCase();
            if (tableName.startsWith(HBaseStorageHandler.DEFAULT_PREFIX)) {
                tableName = tableName.substring(HBaseStorageHandler.DEFAULT_PREFIX.length());
            }
        }
        return tableName;
    }

    @Override
    public void preDropTable(Table table) throws MetaException {
        // nothing to do
    }

    @Override
    public void rollbackDropTable(Table table) throws MetaException {
        // nothing to do
    }

    @Override
    public void commitDropTable(Table tbl, boolean deleteData) throws MetaException {
        try {
            String tableName = getHBaseTableName(tbl);
            boolean isPurge = !MetaStoreUtils.isExternalTable(tbl) || MetaStoreUtils.isExternalTablePurge(tbl);
            if (deleteData && isPurge) {
                LOG.info("Dropping with purge all the data for data source {}", tableName);
                if (getHBaseAdmin().tableExists(TableName.valueOf(tableName))) {
                    if (getHBaseAdmin().isTableEnabled(TableName.valueOf(tableName))) {
                        getHBaseAdmin().disableTable(TableName.valueOf(tableName));
                    }
                    getHBaseAdmin().deleteTable(TableName.valueOf(tableName));
                }
            }
        } catch (IOException ie) {
            throw new MetaException(StringUtils.stringifyException(ie));
        }
    }

    @Override
    public void preCreateTable(Table tbl) throws MetaException {
        // We'd like to move this to HiveMetaStore for any non-native table, but
        // first we need to support storing NULL for location on a table
        if (tbl.getSd().getLocation() != null) {
            throw new MetaException("LOCATION may not be specified for HBase.");
        }

        org.apache.hadoop.hbase.client.Table htable = null;

        try {
            String tableName = getHBaseTableName(tbl);
            Map<String, String> serdeParam = tbl.getSd().getSerdeInfo().getParameters();
            String hbaseColumnsMapping = serdeParam.get(HBaseSerDe.HBASE_COLUMNS_MAPPING);

            ColumnMappings columnMappings = HBaseSerDe.parseColumnsMapping(hbaseColumnsMapping);

            HTableDescriptor tableDesc;

            if (!getHBaseAdmin().tableExists(TableName.valueOf(tableName))) {
                // create table from Hive
                // create the column descriptors
                tableDesc = new HTableDescriptor(TableName.valueOf(tableName));
                Set<String> uniqueColumnFamilies = new HashSet<String>();

                for (ColumnMappings.ColumnMapping colMap : columnMappings) {
                    if (!colMap.hbaseRowKey && !colMap.hbaseTimestamp) {
                        uniqueColumnFamilies.add(colMap.familyName);
                    }
                }

                for (String columnFamily : uniqueColumnFamilies) {
                    tableDesc.addFamily(new HColumnDescriptor(Bytes.toBytes(columnFamily)));
                }

                getHBaseAdmin().createTable(tableDesc);
            } else {
                // register table in Hive
                // make sure the schema mapping is right
                tableDesc = getHBaseAdmin().getTableDescriptor(TableName.valueOf(tableName));

                for (ColumnMappings.ColumnMapping colMap : columnMappings) {

                    if (colMap.hbaseRowKey || colMap.hbaseTimestamp) {
                        continue;
                    }

                    if (!tableDesc.hasFamily(colMap.familyNameBytes)) {
                        throw new MetaException("Column Family " + colMap.familyName
                                + " is not defined in hbase table " + tableName);
                    }
                }
            }

            // ensure the table is online
            htable = getHBaseAdmin().getConnection().getTable(tableDesc.getTableName());
        } catch (Exception se) {
            throw new MetaException(StringUtils.stringifyException(se));
        } finally {
            if (htable != null) {
                IOUtils.closeQuietly(htable);
            }
        }
    }

    @Override
    public void rollbackCreateTable(Table table) throws MetaException {
        String tableName = getHBaseTableName(table);
        boolean isPurge = !MetaStoreUtils.isExternalTable(table) || MetaStoreUtils.isExternalTablePurge(table);
        try {
            if (isPurge && getHBaseAdmin().tableExists(TableName.valueOf(tableName))) {
                // we have created an HBase table, so we delete it to roll back;
                if (getHBaseAdmin().isTableEnabled(TableName.valueOf(tableName))) {
                    getHBaseAdmin().disableTable(TableName.valueOf(tableName));
                }
                getHBaseAdmin().deleteTable(TableName.valueOf(tableName));
            }
        } catch (IOException ie) {
            throw new MetaException(StringUtils.stringifyException(ie));
        }
    }

    @Override
    public void commitCreateTable(Table table) throws MetaException {
        // nothing to do
    }

    @Override
    public void close() throws IOException {
        if (admin != null) {
            Connection connection = admin.getConnection();
            admin.close();
            admin = null;
            if (connection != null) {
                connection.close();
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.util.List;
        import java.util.Map;

        import org.apache.hadoop.hbase.client.Put;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.serde2.ByteStream;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.SerDeUtils;
        import org.apache.hadoop.hive.serde2.lazy.LazyUtils;
        import org.apache.hadoop.hive.serde2.lazy.LazySerDeParameters;
        import org.apache.hadoop.hive.serde2.objectinspector.ListObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.MapObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;
        import org.apache.hadoop.hive.serde2.objectinspector.StructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.LongObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorUtils;
        import org.apache.hadoop.io.Writable;

public class HBaseRowSerializer {

    private final HBaseKeyFactory keyFactory;
    private final HBaseSerDeParameters hbaseParam;
    private final LazySerDeParameters serdeParam;

    private final int keyIndex;
    private final int timestampIndex;
    private final ColumnMapping keyMapping;
    private final ColumnMapping timestampMapping;
    private final ColumnMapping[] columnMappings;
    private final byte[] separators;      // the separators array
    private final boolean escaped;        // whether we need to escape the data when writing out
    private final byte escapeChar;        // which char to use as the escape char, e.g. '\\'
    private final boolean[] needsEscape;  // which chars need to be escaped.

    private final long putTimestamp;
    private final ByteStream.Output output = new ByteStream.Output();

    public HBaseRowSerializer(HBaseSerDeParameters hbaseParam) {
        this.hbaseParam = hbaseParam;
        this.keyFactory = hbaseParam.getKeyFactory();
        this.serdeParam = hbaseParam.getSerdeParams();
        this.separators = serdeParam.getSeparators();
        this.escaped = serdeParam.isEscaped();
        this.escapeChar = serdeParam.getEscapeChar();
        this.needsEscape = serdeParam.getNeedsEscape();
        this.keyIndex = hbaseParam.getKeyIndex();
        this.timestampIndex = hbaseParam.getTimestampIndex();
        this.columnMappings = hbaseParam.getColumnMappings().getColumnsMapping();
        this.keyMapping = hbaseParam.getColumnMappings().getKeyMapping();
        this.timestampMapping = hbaseParam.getColumnMappings().getTimestampMapping();
        this.putTimestamp = hbaseParam.getPutTimestamp();
    }

    public Writable serialize(Object obj, ObjectInspector objInspector) throws Exception {
        if (objInspector.getCategory() != ObjectInspector.Category.STRUCT) {
            throw new SerDeException(getClass().toString()
                    + " can only serialize struct types, but we got: "
                    + objInspector.getTypeName());
        }

        // Prepare the field ObjectInspectors
        StructObjectInspector soi = (StructObjectInspector) objInspector;
        List<? extends StructField> fields = soi.getAllStructFieldRefs();
        List<Object> values = soi.getStructFieldsDataAsList(obj);

        StructField field = fields.get(keyIndex);
        Object value = values.get(keyIndex);

        byte[] key = keyFactory.serializeKey(value, field);
        if (key == null) {
            throw new SerDeException("HBase row key cannot be NULL");
        }
        long timestamp = putTimestamp;
        if (timestamp < 0 && timestampIndex >= 0) {
            ObjectInspector inspector = fields.get(timestampIndex).getFieldObjectInspector();
            value = values.get(timestampIndex);
            if (inspector instanceof LongObjectInspector) {
                timestamp = ((LongObjectInspector)inspector).get(value);
            } else {
                PrimitiveObjectInspector primitive = (PrimitiveObjectInspector) inspector;
                timestamp = PrimitiveObjectInspectorUtils.getTimestamp(value, primitive).toEpochMilli();
            }
        }

        Put put = timestamp >= 0 ? new Put(key, timestamp) : new Put(key);

        // Serialize each field
        for (int i = 0; i < fields.size(); i++) {
            if (i == keyIndex || i == timestampIndex) {
                continue;
            }
            field = fields.get(i);
            value = values.get(i);
            serializeField(value, field, columnMappings[i], put);
        }

        return new PutWritable(put);
    }

    byte[] serializeKeyField(Object keyValue, StructField keyField, ColumnMapping keyMapping)
            throws IOException {
        if (keyValue == null) {
            throw new IOException("HBase row key cannot be NULL");
        }
        ObjectInspector keyFieldOI = keyField.getFieldObjectInspector();

        if (!keyFieldOI.getCategory().equals(ObjectInspector.Category.PRIMITIVE) &&
                keyMapping.isCategory(ObjectInspector.Category.PRIMITIVE)) {
            // we always serialize the String type using the escaped algorithm for LazyString
            return serialize(SerDeUtils.getJSONString(keyValue, keyFieldOI),
                    PrimitiveObjectInspectorFactory.javaStringObjectInspector, 1, false);
        }
        // use the serialization option switch to write primitive values as either a variable
        // length UTF8 string or a fixed width bytes if serializing in binary format
        boolean writeBinary = keyMapping.binaryStorage.get(0);
        return serialize(keyValue, keyFieldOI, 1, writeBinary);
    }

    private void serializeField(
            Object value, StructField field, ColumnMapping colMap, Put put) throws IOException {
        if (value == null) {
            // a null object, we do not serialize it
            return;
        }
        // Get the field objectInspector and the field object.
        ObjectInspector foi = field.getFieldObjectInspector();

        // If the field corresponds to a column family in HBase
        if (colMap.qualifierName == null) {
            MapObjectInspector moi = (MapObjectInspector) foi;
            Map<?, ?> map = moi.getMap(value);
            if (map == null) {
                return;
            }
            ObjectInspector koi = moi.getMapKeyObjectInspector();
            ObjectInspector voi = moi.getMapValueObjectInspector();

            for (Map.Entry<?, ?> entry: map.entrySet()) {
                // Get the Key
                // Map keys are required to be primitive and may be serialized in binary format
                byte[] columnQualifierBytes = serialize(entry.getKey(), koi, 3, colMap.binaryStorage.get(0));
                if (columnQualifierBytes == null) {
                    continue;
                }

                // Map values may be serialized in binary format when they are primitive and binary
                // serialization is the option selected
                byte[] bytes = serialize(entry.getValue(), voi, 3, colMap.binaryStorage.get(1));
                if (bytes == null) {
                    continue;
                }

                put.addColumn(colMap.familyNameBytes, columnQualifierBytes, bytes);
            }
        } else {
            byte[] bytes;
            // If the field that is passed in is NOT a primitive, and either the
            // field is not declared (no schema was given at initialization), or
            // the field is declared as a primitive in initialization, serialize
            // the data to JSON string.  Otherwise serialize the data in the
            // delimited way.
            if (!foi.getCategory().equals(ObjectInspector.Category.PRIMITIVE)
                    && colMap.isCategory(ObjectInspector.Category.PRIMITIVE)) {
                // we always serialize the String type using the escaped algorithm for LazyString
                bytes = serialize(SerDeUtils.getJSONString(value, foi),
                        PrimitiveObjectInspectorFactory.javaStringObjectInspector, 1, false);
            } else {
                // use the serialization option switch to write primitive values as either a variable
                // length UTF8 string or a fixed width bytes if serializing in binary format
                bytes = serialize(value, foi, 1, colMap.binaryStorage.get(0));
            }

            if (bytes == null) {
                return;
            }

            put.addColumn(colMap.familyNameBytes, colMap.qualifierNameBytes, bytes);
        }
    }

    /*
   * Serialize the row into a ByteStream.
   *
   * @param obj           The object for the current field.
   * @param objInspector  The ObjectInspector for the current Object.
   * @param level         The current level of separator.
   * @param writeBinary   Whether to write a primitive object as an UTF8 variable length string or
   *                      as a fixed width byte array onto the byte stream.
   * @throws IOException  On error in writing to the serialization stream.
   * @return true         On serializing a non-null object, otherwise false.
   */
    private byte[] serialize(Object obj, ObjectInspector objInspector, int level, boolean writeBinary)
            throws IOException {
        output.reset();
        if (objInspector.getCategory() == ObjectInspector.Category.PRIMITIVE && writeBinary) {
            LazyUtils.writePrimitive(output, obj, (PrimitiveObjectInspector) objInspector);
        } else {
            if (!serialize(obj, objInspector, level, output)) {
                return null;
            }
        }
        return output.toByteArray();
    }

    private boolean serialize(Object obj, ObjectInspector objInspector, int level, ByteStream.Output ss)
            throws IOException {

        switch (objInspector.getCategory()) {
            case PRIMITIVE:
                LazyUtils.writePrimitiveUTF8(ss, obj, (PrimitiveObjectInspector) objInspector, escaped, escapeChar, needsEscape);
                return true;
            case LIST:
                char separator = (char) separators[level];
                ListObjectInspector loi = (ListObjectInspector) objInspector;
                List<?> list = loi.getList(obj);
                ObjectInspector eoi = loi.getListElementObjectInspector();
                if (list == null) {
                    return false;
                } else {
                    for (int i = 0; i < list.size(); i++) {
                        if (i > 0) {
                            ss.write(separator);
                        }
                        Object currentItem = list.get(i);
                        if (currentItem != null) {
                            serialize(currentItem, eoi, level + 1, ss);
                        }
                    }
                }
                return true;
            case MAP:
                char sep = (char) separators[level];
                char keyValueSeparator = (char) separators[level + 1];
                MapObjectInspector moi = (MapObjectInspector) objInspector;
                ObjectInspector koi = moi.getMapKeyObjectInspector();
                ObjectInspector voi = moi.getMapValueObjectInspector();

                Map<?, ?> map = moi.getMap(obj);
                if (map == null) {
                    return false;
                } else {
                    boolean first = true;
                    for (Map.Entry<?, ?> entry : map.entrySet()) {
                        if (first) {
                            first = false;
                        } else {
                            ss.write(sep);
                        }
                        serialize(entry.getKey(), koi, level + 2, ss);
                        Object currentValue = entry.getValue();
                        if (currentValue != null) {
                            ss.write(keyValueSeparator);
                            serialize(currentValue, voi, level + 2, ss);
                        }
                    }
                }
                return true;
            case STRUCT:
                sep = (char) separators[level];
                StructObjectInspector soi = (StructObjectInspector) objInspector;
                List<? extends StructField> fields = soi.getAllStructFieldRefs();
                list = soi.getStructFieldsDataAsList(obj);
                if (list == null) {
                    return false;
                } else {
                    for (int i = 0; i < list.size(); i++) {
                        if (i > 0) {
                            ss.write(sep);
                        }
                        Object currentItem = list.get(i);
                        if (currentItem != null) {
                            serialize(currentItem, fields.get(i).getFieldObjectInspector(), level + 1, ss);
                        }
                    }
                }
                return true;
            case UNION:
                // union type currently not totally supported. See HIVE-2390
                return false;
            default:
                throw new RuntimeException("Unknown category type: " + objInspector.getCategory());
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

package org.apache.hadoop.hive.hbase;

        import java.io.Serializable;
        import java.lang.reflect.Method;
        import java.util.ArrayList;
        import java.util.List;

        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hbase.client.Scan;
        import org.apache.hadoop.hbase.filter.Filter;
        import org.apache.hadoop.hbase.filter.FilterList;
        import org.apache.hadoop.io.BytesWritable;

public class HBaseScanRange implements Serializable {

    private byte[] startRow;
    private byte[] stopRow;

    private List<FilterDesc> filterDescs = new ArrayList<FilterDesc>();

    public byte[] getStartRow() {
        return startRow;
    }

    public void setStartRow(byte[] startRow) {
        this.startRow = startRow;
    }

    public byte[] getStopRow() {
        return stopRow;
    }

    public void setStopRow(byte[] stopRow) {
        this.stopRow = stopRow;
    }

    public void addFilter(Filter filter) throws Exception {
        Class<? extends Filter> clazz = filter.getClass();
        clazz.getMethod("parseFrom", byte[].class);   // valiade
        filterDescs.add(new FilterDesc(clazz.getName(), filter.toByteArray()));
    }

    public void setup(Scan scan, Configuration conf) throws Exception {
        setup(scan, conf, false);
    }

    public void setup(Scan scan, Configuration conf, boolean filterOnly) throws Exception {
        if (!filterOnly) {
            // Set the start and stop rows only if asked to
            if (startRow != null) {
                scan.setStartRow(startRow);
            }
            if (stopRow != null) {
                scan.setStopRow(stopRow);
            }
        }

        if (filterDescs.isEmpty()) {
            return;
        }
        if (filterDescs.size() == 1) {
            scan.setFilter(filterDescs.get(0).toFilter(conf));
            return;
        }
        List<Filter> filters = new ArrayList<Filter>();
        for (FilterDesc filter : filterDescs) {
            filters.add(filter.toFilter(conf));
        }
        scan.setFilter(new FilterList(filters));
    }

    public String toString() {
        return (startRow == null ? "" : new BytesWritable(startRow).toString()) + " ~ " +
                (stopRow == null ? "" : new BytesWritable(stopRow).toString());
    }

    private static class FilterDesc implements Serializable {

        private String className;
        private byte[] binary;

        public FilterDesc(String className, byte[] binary) {
            this.className = className;
            this.binary = binary;
        }

        public Filter toFilter(Configuration conf) throws Exception {
            return (Filter) getFactoryMethod(className, conf).invoke(null, binary);
        }

        private Method getFactoryMethod(String className, Configuration conf) throws Exception {
            Class<?> clazz = conf.getClassByName(className);
            return clazz.getMethod("parseFrom", byte[].class);
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
package org.apache.hadoop.hive.hbase;

        import static org.apache.hadoop.hive.hbase.HBaseSerDeParameters.AVRO_SERIALIZATION_TYPE;

        import java.io.IOException;
        import java.net.URI;
        import java.net.URISyntaxException;
        import java.util.List;
        import java.util.Map;
        import java.util.Map.Entry;
        import java.util.Properties;

        import org.apache.avro.Schema;
        import org.apache.avro.reflect.ReflectData;
        import org.apache.commons.io.IOUtils;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.fs.FSDataInputStream;
        import org.apache.hadoop.fs.FileSystem;
        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hive.common.JavaUtils;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.serde.serdeConstants;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.avro.AvroObjectInspectorGenerator;
        import org.apache.hadoop.hive.serde2.avro.AvroSerdeUtils.AvroTableProperties;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazyMapObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
        import org.apache.hadoop.util.StringUtils;

/**
 * Helper class for {@link HBaseSerDe}
 * */
public class HBaseSerDeHelper {

    /**
     * Logger
     * */
    public static final Logger LOG = LoggerFactory.getLogger(HBaseSerDeHelper.class);

    /**
     * Autogenerates the columns from the given serialization class
     *
     * @param tbl the hive table properties
     * @param columnsMapping the hbase columns mapping determining hbase column families and
     *          qualifiers
     * @param sb StringBuilder to form the list of columns
     * @throws IllegalArgumentException if any of the given arguments was null
     * */
    public static void generateColumns(Properties tbl, List<ColumnMapping> columnsMapping,
                                       StringBuilder sb) {
        // Generate the columns according to the column mapping provided
        // Note: The generated column names are same as the
        // family_name.qualifier_name. If the qualifier
        // name is null, each column is familyname_col[i] where i is the index of
        // the column ranging
        // from 0 to n-1 where n is the size of the column mapping. The filter
        // function removes any
        // special characters other than alphabets and numbers from the column
        // family and qualifier name
        // as the only special character allowed in a column name is "_" which is
        // used as a separator
        // between the column family and qualifier name.

        if (columnsMapping == null) {
            throw new IllegalArgumentException("columnsMapping cannot be null");
        }

        if (sb == null) {
            throw new IllegalArgumentException("StringBuilder cannot be null");
        }

        for (int i = 0; i < columnsMapping.size(); i++) {
            ColumnMapping colMap = columnsMapping.get(i);

            if (colMap.hbaseRowKey) {
                sb.append("key").append(StringUtils.COMMA_STR);
            } else if (colMap.qualifierName == null) {
                // this corresponds to a map<string,?>

                if (colMap.qualifierPrefix != null) {
                    sb.append(filter(colMap.familyName)).append("_")
                            .append(filter(colMap.qualifierPrefix) + i).append(StringUtils.COMMA_STR);
                } else {
                    sb.append(filter(colMap.familyName)).append("_").append("col" + i)
                            .append(StringUtils.COMMA_STR);
                }
            } else {
                // just an individual column
                sb.append(filter(colMap.familyName)).append("_").append(filter(colMap.qualifierName))
                        .append(StringUtils.COMMA_STR);
            }
        }

        // trim off the ending ",", if any
        trim(sb);

        if (LOG.isDebugEnabled()) {
            LOG.debug("Generated columns: [" + sb.toString() + "]");
        }
    }

    /**
     * Autogenerates the column types from the given serialization class
     *
     * @param tbl the hive table properties
     * @param columnsMapping the hbase columns mapping determining hbase column families and
     *          qualifiers
     * @param sb StringBuilder to form the list of columns
     * @param conf configuration
     * @throws IllegalArgumentException if any of the given arguments was null
     * @throws SerDeException if there was an error generating the column types
     * */
    public static void generateColumnTypes(Properties tbl, List<ColumnMapping> columnsMapping,
                                           StringBuilder sb, Configuration conf) throws SerDeException {

        if (tbl == null) {
            throw new IllegalArgumentException("tbl cannot be null");
        }

        if (columnsMapping == null) {
            throw new IllegalArgumentException("columnsMapping cannot be null");
        }

        if (sb == null) {
            throw new IllegalArgumentException("StringBuilder cannot be null");
        }

        // Generate the columns according to the column mapping provided
        for (int i = 0; i < columnsMapping.size(); i++) {
            if (sb.length() > 0) {
                sb.append(":");
            }

            ColumnMapping colMap = columnsMapping.get(i);

            if (colMap.hbaseRowKey) {

                Map<String, String> compositeKeyParts = getCompositeKeyParts(tbl);
                StringBuilder keyStruct = new StringBuilder();

                if (compositeKeyParts == null || compositeKeyParts.isEmpty()) {
                    String compKeyClass = tbl.getProperty(HBaseSerDe.HBASE_COMPOSITE_KEY_CLASS);
                    String compKeyTypes = tbl.getProperty(HBaseSerDe.HBASE_COMPOSITE_KEY_TYPES);

                    if (compKeyTypes == null) {

                        if (compKeyClass != null) {
                            // a composite key class was provided. But neither the types
                            // property was set and
                            // neither the getParts() method of HBaseCompositeKey was
                            // overidden in the
                            // implementation. Flag exception.
                            throw new SerDeException(
                                    "Either the hbase.composite.key.types property should be set or the getParts method must be overridden in "
                                            + compKeyClass);
                        }

                        // the row key column becomes a STRING
                        sb.append(serdeConstants.STRING_TYPE_NAME);
                    } else {
                        generateKeyStruct(compKeyTypes, keyStruct);
                    }
                } else {
                    generateKeyStruct(compositeKeyParts, keyStruct);
                }
                sb.append(keyStruct);
            } else if (colMap.qualifierName == null) {

                String serClassName = null;
                String serType = null;
                String schemaLiteral = null;
                String schemaUrl = null;

                if (colMap.qualifierPrefix != null) {

                    serType =
                            tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                    + HBaseSerDe.SERIALIZATION_TYPE);

                    if (serType == null) {
                        throw new SerDeException(HBaseSerDe.SERIALIZATION_TYPE
                                + " property not provided for column family [" + colMap.familyName
                                + "] and prefix [" + colMap.qualifierPrefix + "]");
                    }

                    // we are provided with a prefix
                    serClassName =
                            tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                    + serdeConstants.SERIALIZATION_CLASS);

                    if (serClassName == null) {
                        if (serType.equalsIgnoreCase(HBaseSerDeParameters.AVRO_SERIALIZATION_TYPE)) {
                            // for avro type, the serialization class parameter is optional
                            schemaLiteral =
                                    tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                            + AvroTableProperties.SCHEMA_LITERAL.getPropName());
                            schemaUrl =
                                    tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                            + AvroTableProperties.SCHEMA_URL.getPropName());

                            if (schemaLiteral == null && schemaUrl == null) {
                                // either schema literal, schema url or serialization class must
                                // be provided
                                throw new SerDeException("For an avro schema, either "
                                        + AvroTableProperties.SCHEMA_LITERAL.getPropName() + ", "
                                        + AvroTableProperties.SCHEMA_URL.getPropName() + " or "
                                        + serdeConstants.SERIALIZATION_CLASS + " property must be set.");
                            }

                            if (schemaUrl != null) {
                                schemaLiteral = getSchemaFromFS(schemaUrl, conf).toString();
                            }

                        } else {
                            throw new SerDeException(serdeConstants.SERIALIZATION_CLASS
                                    + " property not provided for column family [" + colMap.familyName
                                    + "] and prefix [" + colMap.qualifierPrefix + "]");
                        }
                    }
                } else {
                    serType = tbl.getProperty(colMap.familyName + "." + HBaseSerDe.SERIALIZATION_TYPE);

                    if (serType == null) {
                        throw new SerDeException(HBaseSerDe.SERIALIZATION_TYPE
                                + " property not provided for column family [" + colMap.familyName + "]");
                    }

                    serClassName =
                            tbl.getProperty(colMap.familyName + "." + serdeConstants.SERIALIZATION_CLASS);

                    if (serClassName == null) {

                        if (serType.equalsIgnoreCase(AVRO_SERIALIZATION_TYPE)) {
                            // for avro type, the serialization class parameter is optional
                            schemaLiteral =
                                    tbl.getProperty(colMap.familyName + "." + AvroTableProperties.SCHEMA_LITERAL.getPropName());
                            schemaUrl = tbl.getProperty(colMap.familyName + "." + AvroTableProperties.SCHEMA_URL.getPropName());

                            if (schemaLiteral == null && schemaUrl == null) {
                                // either schema literal or serialization class must be provided
                                throw new SerDeException("For an avro schema, either "
                                        + AvroTableProperties.SCHEMA_LITERAL.getPropName() + " property or "
                                        + serdeConstants.SERIALIZATION_CLASS + " property must be set.");
                            }

                            if (schemaUrl != null) {
                                schemaLiteral = getSchemaFromFS(schemaUrl, conf).toString();
                            }
                        } else {
                            throw new SerDeException(serdeConstants.SERIALIZATION_CLASS
                                    + " property not provided for column family [" + colMap.familyName + "]");
                        }
                    }
                }

                StringBuilder generatedStruct = new StringBuilder();

                // generate struct for each of the given prefixes
                generateColumnStruct(serType, serClassName, schemaLiteral, colMap, generatedStruct);

                // a column family becomes a MAP
                sb.append(serdeConstants.MAP_TYPE_NAME + "<" + serdeConstants.STRING_TYPE_NAME + ","
                        + generatedStruct + ">");

            } else {

                String qualifierName = colMap.qualifierName;

                if (colMap.qualifierName.endsWith("*")) {
                    // we are provided with a prefix
                    qualifierName = colMap.qualifierName.substring(0, colMap.qualifierName.length() - 1);
                }

                String serType =
                        tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                                + HBaseSerDe.SERIALIZATION_TYPE);

                if (serType == null) {
                    throw new SerDeException(HBaseSerDe.SERIALIZATION_TYPE
                            + " property not provided for column family [" + colMap.familyName
                            + "] and qualifier [" + qualifierName + "]");
                }

                String serClassName =
                        tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                                + serdeConstants.SERIALIZATION_CLASS);

                String schemaLiteral = null;
                String schemaUrl = null;

                if (serClassName == null) {

                    if (serType.equalsIgnoreCase(AVRO_SERIALIZATION_TYPE)) {
                        // for avro type, the serialization class parameter is optional
                        schemaLiteral =
                                tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                                        + AvroTableProperties.SCHEMA_LITERAL.getPropName());
                        schemaUrl =
                                tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                                        + AvroTableProperties.SCHEMA_URL.getPropName());

                        if (schemaLiteral == null && schemaUrl == null) {
                            // either schema literal, schema url or serialization class must
                            // be provided
                            throw new SerDeException("For an avro schema, either "
                                    + AvroTableProperties.SCHEMA_LITERAL.getPropName() + ", " + AvroTableProperties.SCHEMA_URL.getPropName() + " or "
                                    + serdeConstants.SERIALIZATION_CLASS + " property must be set.");
                        }

                        if (schemaUrl != null) {
                            schemaLiteral = getSchemaFromFS(schemaUrl, conf).toString();
                        }
                    } else {
                        throw new SerDeException(serdeConstants.SERIALIZATION_CLASS
                                + " property not provided for column family [" + colMap.familyName
                                + "] and qualifier [" + qualifierName + "]");
                    }
                }

                StringBuilder generatedStruct = new StringBuilder();

                generateColumnStruct(serType, serClassName, schemaLiteral, colMap, generatedStruct);

                sb.append(generatedStruct);
            }
        }

        // trim off ending ",", if any
        trim(sb);

        if (LOG.isDebugEnabled()) {
            LOG.debug("Generated column types: [" + sb.toString() + "]");
        }
    }

    /**
     * Read the schema from the given hdfs url for the schema
     * */
    public static Schema getSchemaFromFS(String schemaFSUrl, Configuration conf)
            throws SerDeException {
        FSDataInputStream in = null;
        FileSystem fs = null;
        try {
            fs = FileSystem.get(new URI(schemaFSUrl), conf);
            in = fs.open(new Path(schemaFSUrl));
            Schema s = Schema.parse(in);
            return s;
        } catch (URISyntaxException e) {
            throw new SerDeException("Failure reading schema from filesystem", e);
        } catch (IOException e) {
            throw new SerDeException("Failure reading schema from filesystem", e);
        } finally {
            IOUtils.closeQuietly(in);
        }
    }

    /**
     * Create the {@link LazyObjectBase lazy field}
     * */
    public static LazyObjectBase createLazyField(ColumnMapping[] columnMappings, int fieldID,
                                                 ObjectInspector inspector) {
        ColumnMapping colMap = columnMappings[fieldID];
        if (colMap.getQualifierName() == null && !colMap.isHbaseRowKey()) {
            // a column family
            return new LazyHBaseCellMap((LazyMapObjectInspector) inspector);
        }
        return LazyFactory.createLazyObject(inspector, colMap.getBinaryStorage().get(0));
    }

    /**
     * Auto-generates the key struct for composite keys
     *
     * @param compositeKeyParts map of composite key part name to its type. Usually this would be
     *          provided by the custom implementation of {@link HBaseCompositeKey composite key}
     * @param sb StringBuilder object to construct the struct
     * */
    private static void generateKeyStruct(Map<String, String> compositeKeyParts, StringBuilder sb) {
        sb.append("struct<");

        for (Entry<String, String> entry : compositeKeyParts.entrySet()) {
            sb.append(entry.getKey()).append(":").append(entry.getValue()).append(",");
        }

        // trim the trailing ","
        trim(sb);
        sb.append(">");
    }

    /**
     * Auto-generates the key struct for composite keys
     *
     * @param compositeKeyTypes comma separated list of composite key types in order
     * @param sb StringBuilder object to construct the struct
     * */
    private static void generateKeyStruct(String compositeKeyTypes, StringBuilder sb) {
        sb.append("struct<");

        // composite key types is a comma separated list of different parts of the
        // composite keys in
        // order in which they appear in the key
        String[] keyTypes = compositeKeyTypes.split(",");

        for (int i = 0; i < keyTypes.length; i++) {
            sb.append("col" + i).append(":").append(keyTypes[i]).append(StringUtils.COMMA_STR);
        }

        // trim the trailing ","
        trim(sb);
        sb.append(">");
    }

    /**
     * Auto-generates the column struct
     *
     * @param serType serialization type
     * @param serClassName serialization class name
     * @param schemaLiteral schema string
     * @param colMap hbase column mapping
     * @param sb StringBuilder to hold the generated struct
     * @throws SerDeException if something goes wrong while generating the struct
     * */
    private static void generateColumnStruct(String serType, String serClassName,
                                             String schemaLiteral, ColumnMapping colMap, StringBuilder sb) throws SerDeException {

        if (serType.equalsIgnoreCase(AVRO_SERIALIZATION_TYPE)) {

            if (serClassName != null) {
                generateAvroStructFromClass(serClassName, sb);
            } else {
                generateAvroStructFromSchema(schemaLiteral, sb);
            }
        } else {
            throw new SerDeException("Unknown " + HBaseSerDe.SERIALIZATION_TYPE
                    + " found for column family [" + colMap.familyName + "]");
        }
    }

    /**
     * Auto-generate the avro struct from class
     *
     * @param serClassName serialization class for avro struct
     * @param sb StringBuilder to hold the generated struct
     * @throws SerDeException if something goes wrong while generating the struct
     * */
    private static void generateAvroStructFromClass(String serClassName, StringBuilder sb)
            throws SerDeException {
        Class<?> serClass;
        try {
            serClass = JavaUtils.loadClass(serClassName);
        } catch (ClassNotFoundException e) {
            throw new SerDeException("Error obtaining descriptor for " + serClassName, e);
        }

        Schema schema = ReflectData.get().getSchema(serClass);

        generateAvroStructFromSchema(schema, sb);
    }

    /**
     * Auto-generate the avro struct from schema
     *
     * @param schemaLiteral schema for the avro struct as string
     * @param sb StringBuilder to hold the generated struct
     * @throws SerDeException if something goes wrong while generating the struct
     * */
    private static void generateAvroStructFromSchema(String schemaLiteral, StringBuilder sb)
            throws SerDeException {
        Schema schema = Schema.parse(schemaLiteral);

        generateAvroStructFromSchema(schema, sb);
    }

    /**
     * Auto-generate the avro struct from schema
     *
     * @param schema schema for the avro struct
     * @param sb StringBuilder to hold the generated struct
     * @throws SerDeException if something goes wrong while generating the struct
     * */
    private static void generateAvroStructFromSchema(Schema schema, StringBuilder sb)
            throws SerDeException {
        AvroObjectInspectorGenerator avig = new AvroObjectInspectorGenerator(schema);

        sb.append("struct<");

        // Get the column names and their corresponding types
        List<String> columnNames = avig.getColumnNames();
        List<TypeInfo> columnTypes = avig.getColumnTypes();

        if (columnNames.size() != columnTypes.size()) {
            throw new AssertionError("The number of column names should be the same as column types");
        }

        for (int i = 0; i < columnNames.size(); i++) {
            sb.append(columnNames.get(i));
            sb.append(":");
            sb.append(columnTypes.get(i).getTypeName());
            sb.append(",");
        }

        trim(sb).append(">");
    }

    /**
     * Trims by removing the trailing "," if any
     *
     * @param sb StringBuilder to trim
     * @return StringBuilder trimmed StringBuilder
     * */
    private static StringBuilder trim(StringBuilder sb) {
        if (sb.charAt(sb.length() - 1) == StringUtils.COMMA) {
            return sb.deleteCharAt(sb.length() - 1);
        }

        return sb;
    }

    /**
     * Filters the given name by removing any special character and convert to lowercase
     * */
    private static String filter(String name) {
        return name.replaceAll("[^a-zA-Z0-9]+", "").toLowerCase();
    }

    /**
     * Return the types for the composite key.
     *
     * @param tbl Properties for the table
     * @return a comma-separated list of composite key types
     * @throws SerDeException if something goes wrong while getting the composite key parts
     * */
    @SuppressWarnings("unchecked")
    private static Map<String, String> getCompositeKeyParts(Properties tbl) throws SerDeException {
        String compKeyClassName = tbl.getProperty(HBaseSerDe.HBASE_COMPOSITE_KEY_CLASS);

        if (compKeyClassName == null) {
            // no custom composite key class provided. return null
            return null;
        }

        CompositeHBaseKeyFactory<HBaseCompositeKey> keyFactory = null;

        Class<?> keyClass;
        try {
            keyClass = JavaUtils.loadClass(compKeyClassName);
            keyFactory = new CompositeHBaseKeyFactory(keyClass);
        } catch (Exception e) {
            throw new SerDeException(e);
        }

        HBaseCompositeKey compKey = keyFactory.createKey(null);
        return compKey.getParts();
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

package org.apache.hadoop.hive.hbase;

        import java.util.ArrayList;
        import java.util.List;
        import java.util.Properties;

        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hbase.util.Bytes;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.ql.plan.TableDesc;
        import org.apache.hadoop.hive.serde.serdeConstants;
        import org.apache.hadoop.hive.serde2.AbstractSerDe;
        import org.apache.hadoop.hive.serde2.AbstractSerDe;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.SerDeSpec;
        import org.apache.hadoop.hive.serde2.SerDeStats;
        import org.apache.hadoop.hive.serde2.lazy.LazySerDeParameters;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazySimpleStructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.io.Writable;
        import org.apache.hadoop.mapred.JobConf;

/**
 * HBaseSerDe can be used to serialize object into an HBase table and
 * deserialize objects from an HBase table.
 */
@SerDeSpec(schemaProps = {
        serdeConstants.LIST_COLUMNS, serdeConstants.LIST_COLUMN_TYPES,
        serdeConstants.FIELD_DELIM, serdeConstants.COLLECTION_DELIM, serdeConstants.MAPKEY_DELIM,
        serdeConstants.SERIALIZATION_FORMAT, serdeConstants.SERIALIZATION_NULL_FORMAT,
        serdeConstants.SERIALIZATION_ESCAPE_CRLF,
        serdeConstants.SERIALIZATION_LAST_COLUMN_TAKES_REST,
        serdeConstants.ESCAPE_CHAR,
        serdeConstants.SERIALIZATION_ENCODING,
        LazySerDeParameters.SERIALIZATION_EXTEND_NESTING_LEVELS,
        LazySerDeParameters.SERIALIZATION_EXTEND_ADDITIONAL_NESTING_LEVELS,
        HBaseSerDe.HBASE_COLUMNS_MAPPING,
        HBaseSerDe.HBASE_TABLE_NAME,
        HBaseSerDe.HBASE_TABLE_DEFAULT_STORAGE_TYPE,
        HBaseSerDe.HBASE_KEY_COL,
        HBaseSerDe.HBASE_PUT_TIMESTAMP,
        HBaseSerDe.HBASE_COMPOSITE_KEY_CLASS,
        HBaseSerDe.HBASE_COMPOSITE_KEY_TYPES,
        HBaseSerDe.HBASE_COMPOSITE_KEY_FACTORY,
        HBaseSerDe.HBASE_STRUCT_SERIALIZER_CLASS,
        HBaseSerDe.HBASE_SCAN_CACHE,
        HBaseSerDe.HBASE_SCAN_CACHEBLOCKS,
        HBaseSerDe.HBASE_SCAN_BATCH,
        HBaseSerDe.HBASE_AUTOGENERATE_STRUCT})
public class HBaseSerDe extends AbstractSerDe {
    public static final Logger LOG = LoggerFactory.getLogger(HBaseSerDe.class);

    public static final String HBASE_COLUMNS_MAPPING = "hbase.columns.mapping";
    public static final String HBASE_TABLE_NAME = "hbase.table.name";
    public static final String HBASE_TABLE_DEFAULT_STORAGE_TYPE = "hbase.table.default.storage.type";
    public static final String HBASE_KEY_COL = ":key";
    public static final String HBASE_TIMESTAMP_COL = ":timestamp";
    public static final String HBASE_PUT_TIMESTAMP = "hbase.put.timestamp";
    public static final String HBASE_COMPOSITE_KEY_CLASS = "hbase.composite.key.class";
    public static final String HBASE_COMPOSITE_KEY_TYPES = "hbase.composite.key.types";
    public static final String HBASE_COMPOSITE_KEY_FACTORY = "hbase.composite.key.factory";
    public static final String HBASE_STRUCT_SERIALIZER_CLASS = "hbase.struct.serialization.class";
    public static final String HBASE_SCAN_CACHE = "hbase.scan.cache";
    public static final String HBASE_SCAN_CACHEBLOCKS = "hbase.scan.cacheblock";
    public static final String HBASE_SCAN_BATCH = "hbase.scan.batch";
    public static final String HBASE_AUTOGENERATE_STRUCT = "hbase.struct.autogenerate";
    /**
     * Determines whether a regex matching should be done on the columns or not. Defaults to true.
     * <strong>WARNING: Note that currently this only supports the suffix wildcard .*</strong>
     */
    public static final String HBASE_COLUMNS_REGEX_MATCHING = "hbase.columns.mapping.regex.matching";
    /**
     * Defines the type for a column.
     **/
    public static final String SERIALIZATION_TYPE = "serialization.type";

    /**
     * Defines if the prefix column from hbase should be hidden.
     * It works only when @HBASE_COLUMNS_REGEX_MATCHING is true.
     * Default value of this parameter is false
     */
    public static final String HBASE_COLUMNS_PREFIX_HIDE = "hbase.columns.mapping.prefix.hide";

    private ObjectInspector cachedObjectInspector;
    private LazyHBaseRow cachedHBaseRow;

    private HBaseSerDeParameters serdeParams;
    private HBaseRowSerializer serializer;

    @Override
    public String toString() {
        return getClass() + "[" + serdeParams + "]";
    }

    public HBaseSerDe() throws SerDeException {
    }

    /**
     * Initialize the SerDe given parameters.
     * @see AbstractSerDe#initialize(Configuration, Properties)
     */
    @Override
    public void initialize(Configuration conf, Properties tbl)
            throws SerDeException {
        serdeParams = new HBaseSerDeParameters(conf, tbl, getClass().getName());

        cachedObjectInspector =
                HBaseLazyObjectFactory.createLazyHBaseStructInspector(serdeParams, tbl);

        cachedHBaseRow = new LazyHBaseRow(
                (LazySimpleStructObjectInspector) cachedObjectInspector, serdeParams);

        serializer = new HBaseRowSerializer(serdeParams);

        if (LOG.isDebugEnabled()) {
            LOG.debug("HBaseSerDe initialized with : " + serdeParams);
        }
    }

    public static ColumnMappings parseColumnsMapping(String columnsMappingSpec)
            throws SerDeException {
        return parseColumnsMapping(columnsMappingSpec, true);
    }

    public static ColumnMappings parseColumnsMapping(
            String columnsMappingSpec, boolean doColumnRegexMatching) throws SerDeException {
        return parseColumnsMapping(columnsMappingSpec, doColumnRegexMatching, false);
    }
    /**
     * Parses the HBase columns mapping specifier to identify the column families, qualifiers
     * and also caches the byte arrays corresponding to them. One of the Hive table
     * columns maps to the HBase row key, by default the first column.
     *
     * @param columnsMappingSpec string hbase.columns.mapping specified when creating table
     * @param doColumnRegexMatching whether to do a regex matching on the columns or not
     * @param hideColumnPrefix whether to hide a prefix of column mapping in key name in a map (works only if @doColumnRegexMatching is true)
     * @return List&lt;ColumnMapping&gt; which contains the column mapping information by position
     * @throws org.apache.hadoop.hive.serde2.SerDeException
     */
    public static ColumnMappings parseColumnsMapping(
            String columnsMappingSpec, boolean doColumnRegexMatching, boolean hideColumnPrefix) throws SerDeException {

        if (columnsMappingSpec == null) {
            throw new SerDeException("Error: hbase.columns.mapping missing for this HBase table.");
        }

        if (columnsMappingSpec.isEmpty() || columnsMappingSpec.equals(HBASE_KEY_COL)) {
            throw new SerDeException("Error: hbase.columns.mapping specifies only the HBase table"
                    + " row key. A valid Hive-HBase table must specify at least one additional column.");
        }

        int rowKeyIndex = -1;
        int timestampIndex = -1;
        List<ColumnMapping> columnsMapping = new ArrayList<ColumnMapping>();
        String[] columnSpecs = columnsMappingSpec.split(",");

        for (int i = 0; i < columnSpecs.length; i++) {
            String mappingSpec = columnSpecs[i].trim();
            String [] mapInfo = mappingSpec.split("#");
            String colInfo = mapInfo[0];

            int idxFirst = colInfo.indexOf(":");
            int idxLast = colInfo.lastIndexOf(":");

            if (idxFirst < 0 || !(idxFirst == idxLast)) {
                throw new SerDeException("Error: the HBase columns mapping contains a badly formed " +
                        "column family, column qualifier specification.");
            }

            ColumnMapping columnMapping = new ColumnMapping();

            if (colInfo.equals(HBASE_KEY_COL)) {
                rowKeyIndex = i;
                columnMapping.familyName = colInfo;
                columnMapping.familyNameBytes = Bytes.toBytes(colInfo);
                columnMapping.qualifierName = null;
                columnMapping.qualifierNameBytes = null;
                columnMapping.hbaseRowKey = true;
            } else if (colInfo.equals(HBASE_TIMESTAMP_COL)) {
                timestampIndex = i;
                columnMapping.familyName = colInfo;
                columnMapping.familyNameBytes = Bytes.toBytes(colInfo);
                columnMapping.qualifierName = null;
                columnMapping.qualifierNameBytes = null;
                columnMapping.hbaseTimestamp = true;
            } else {
                String [] parts = colInfo.split(":");
                assert(parts.length > 0 && parts.length <= 2);
                columnMapping.familyName = parts[0];
                columnMapping.familyNameBytes = Bytes.toBytes(parts[0]);
                columnMapping.hbaseRowKey = false;
                columnMapping.hbaseTimestamp = false;

                if (parts.length == 2) {

                    if (doColumnRegexMatching && parts[1].endsWith(".*")) {
                        // we have a prefix with a wildcard
                        columnMapping.qualifierPrefix = parts[1].substring(0, parts[1].length() - 2);
                        columnMapping.qualifierPrefixBytes = Bytes.toBytes(columnMapping.qualifierPrefix);
                        //pass a flag to hide prefixes
                        columnMapping.doPrefixCut=hideColumnPrefix;
                        // we weren't provided any actual qualifier name. Set these to
                        // null.
                        columnMapping.qualifierName = null;
                        columnMapping.qualifierNameBytes = null;
                    } else {
                        // set the regular provided qualifier names
                        columnMapping.qualifierName = parts[1];
                        columnMapping.qualifierNameBytes = Bytes.toBytes(parts[1]);
                        //if there is no prefix then we don't cut anything
                        columnMapping.doPrefixCut=false;
                    }
                } else {
                    columnMapping.qualifierName = null;
                    columnMapping.qualifierNameBytes = null;
                }
            }

            columnMapping.mappingSpec = mappingSpec;

            columnsMapping.add(columnMapping);
        }

        if (rowKeyIndex == -1) {
            rowKeyIndex = 0;
            ColumnMapping columnMapping = new ColumnMapping();
            columnMapping.familyName = HBaseSerDe.HBASE_KEY_COL;
            columnMapping.familyNameBytes = Bytes.toBytes(HBaseSerDe.HBASE_KEY_COL);
            columnMapping.qualifierName = null;
            columnMapping.qualifierNameBytes = null;
            columnMapping.hbaseRowKey = true;
            columnMapping.mappingSpec = HBaseSerDe.HBASE_KEY_COL;
            columnsMapping.add(0, columnMapping);
        }

        return new ColumnMappings(columnsMapping, rowKeyIndex, timestampIndex);
    }

    public LazySerDeParameters getSerdeParams() {
        return serdeParams.getSerdeParams();
    }

    public HBaseSerDeParameters getHBaseSerdeParam() {
        return serdeParams;
    }

    /**
     * Deserialize a row from the HBase Result writable to a LazyObject
     * @param result the HBase Result Writable containing the row
     * @return the deserialized object
     * @see AbstractSerDe#deserialize(Writable)
     */
    @Override
    public Object deserialize(Writable result) throws SerDeException {
        if (!(result instanceof ResultWritable)) {
            throw new SerDeException(getClass().getName() + ": expects ResultWritable!");
        }

        cachedHBaseRow.init(((ResultWritable) result).getResult());

        return cachedHBaseRow;
    }

    @Override
    public ObjectInspector getObjectInspector() throws SerDeException {
        return cachedObjectInspector;
    }

    @Override
    public Class<? extends Writable> getSerializedClass() {
        return PutWritable.class;
    }

    @Override
    public Writable serialize(Object obj, ObjectInspector objInspector) throws SerDeException {
        try {
            return serializer.serialize(obj, objInspector);
        } catch (SerDeException e) {
            throw e;
        } catch (Exception e) {
            throw new SerDeException(e);
        }
    }

    @Override
    public SerDeStats getSerDeStats() {
        // no support for statistics
        return null;
    }

    public HBaseKeyFactory getKeyFactory() {
        return serdeParams.getKeyFactory();
    }

    public static void configureJobConf(TableDesc tableDesc, JobConf jobConf) throws Exception {
        HBaseSerDeParameters serdeParams =
                new HBaseSerDeParameters(jobConf, tableDesc.getProperties(), HBaseSerDe.class.getName());
        serdeParams.getKeyFactory().configureJobConf(tableDesc, jobConf);
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

package org.apache.hadoop.hive.hbase;

        import java.util.ArrayList;
        import java.util.List;
        import java.util.Properties;

        import javax.annotation.Nullable;

        import org.apache.avro.Schema;
        import org.apache.avro.reflect.ReflectData;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hive.common.JavaUtils;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.hbase.struct.AvroHBaseValueFactory;
        import org.apache.hadoop.hive.hbase.struct.DefaultHBaseValueFactory;
        import org.apache.hadoop.hive.hbase.struct.HBaseValueFactory;
        import org.apache.hadoop.hive.hbase.struct.StructHBaseValueFactory;
        import org.apache.hadoop.hive.serde.serdeConstants;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.avro.AvroSerdeUtils.AvroTableProperties;
        import org.apache.hadoop.hive.serde2.lazy.LazySerDeParameters;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
        import org.apache.hadoop.util.ReflectionUtils;

/**
 * HBaseSerDeParameters encapsulates SerDeParameters and additional configurations that are specific for
 * HBaseSerDe.
 *
 */
public class HBaseSerDeParameters {

    public static final String AVRO_SERIALIZATION_TYPE = "avro";
    public static final String STRUCT_SERIALIZATION_TYPE = "struct";

    private final LazySerDeParameters serdeParams;

    private final Configuration job;

    private final String columnMappingString;
    private final ColumnMappings columnMappings;
    private final boolean doColumnRegexMatching;
    private final boolean doColumnPrefixCut;

    private final long putTimestamp;
    private final HBaseKeyFactory keyFactory;
    private final List<HBaseValueFactory> valueFactories;

    HBaseSerDeParameters(Configuration job, Properties tbl, String serdeName) throws SerDeException {
        this.job = job;

        // Read configuration parameters
        columnMappingString = tbl.getProperty(HBaseSerDe.HBASE_COLUMNS_MAPPING);
        doColumnRegexMatching =
                Boolean.parseBoolean(tbl.getProperty(HBaseSerDe.HBASE_COLUMNS_REGEX_MATCHING, "true"));
        doColumnPrefixCut = Boolean.parseBoolean(tbl.getProperty(HBaseSerDe.HBASE_COLUMNS_PREFIX_HIDE, "false"));
        // Parse and initialize the HBase columns mapping
        columnMappings = HBaseSerDe.parseColumnsMapping(columnMappingString, doColumnRegexMatching, doColumnPrefixCut);

        // Build the type property string if not supplied
        String columnTypeProperty = tbl.getProperty(serdeConstants.LIST_COLUMN_TYPES);
        String autogenerate = tbl.getProperty(HBaseSerDe.HBASE_AUTOGENERATE_STRUCT);

        if (columnTypeProperty == null || columnTypeProperty.isEmpty()) {
            String columnNameProperty = tbl.getProperty(serdeConstants.LIST_COLUMNS);
            if (columnNameProperty == null || columnNameProperty.isEmpty()) {
                if (autogenerate == null || autogenerate.isEmpty()) {
                    throw new IllegalArgumentException("Either the columns must be specified or the "
                            + HBaseSerDe.HBASE_AUTOGENERATE_STRUCT + " property must be set to true.");
                }

                tbl.setProperty(serdeConstants.LIST_COLUMNS,
                        columnMappings.toNamesString(tbl, autogenerate));
            }

            tbl.setProperty(serdeConstants.LIST_COLUMN_TYPES,
                    columnMappings.toTypesString(tbl, job, autogenerate));
        }

        this.serdeParams = new LazySerDeParameters(job, tbl, serdeName);
        this.putTimestamp = Long.parseLong(tbl.getProperty(HBaseSerDe.HBASE_PUT_TIMESTAMP, "-1"));

        columnMappings.setHiveColumnDescription(serdeName, serdeParams.getColumnNames(),
                serdeParams.getColumnTypes());

        // Precondition: make sure this is done after the rest of the SerDe initialization is done.
        String hbaseTableStorageType = tbl.getProperty(HBaseSerDe.HBASE_TABLE_DEFAULT_STORAGE_TYPE);
        columnMappings.parseColumnStorageTypes(hbaseTableStorageType);

        this.keyFactory = initKeyFactory(job, tbl);
        this.valueFactories = initValueFactories(job, tbl);
    }

    public List<String> getColumnNames() {
        return serdeParams.getColumnNames();
    }

    public List<TypeInfo> getColumnTypes() {
        return serdeParams.getColumnTypes();
    }

    public LazySerDeParameters getSerdeParams() {
        return serdeParams;
    }

    public long getPutTimestamp() {
        return putTimestamp;
    }

    public int getKeyIndex() {
        return columnMappings.getKeyIndex();
    }

    public ColumnMapping getKeyColumnMapping() {
        return columnMappings.getKeyMapping();
    }

    public int getTimestampIndex() {
        return columnMappings.getTimestampIndex();
    }

    public ColumnMapping getTimestampColumnMapping() {
        return columnMappings.getTimestampMapping();
    }

    public ColumnMappings getColumnMappings() {
        return columnMappings;
    }

    public HBaseKeyFactory getKeyFactory() {
        return keyFactory;
    }

    public List<HBaseValueFactory> getValueFactories() {
        return valueFactories;
    }

    public Configuration getBaseConfiguration() {
        return job;
    }

    public TypeInfo getTypeForName(String columnName) {
        List<String> columnNames = serdeParams.getColumnNames();
        List<TypeInfo> columnTypes = serdeParams.getColumnTypes();
        for (int i = 0; i < columnNames.size(); i++) {
            if (columnName.equals(columnNames.get(i))) {
                return columnTypes.get(i);
            }
        }
        throw new IllegalArgumentException("Invalid column name " + columnName);
    }

    public String toString() {
        return "[" + columnMappingString + ":" + getColumnNames() + ":" + getColumnTypes() + "]";
    }

    private HBaseKeyFactory initKeyFactory(Configuration conf, Properties tbl) throws SerDeException {
        try {
            HBaseKeyFactory keyFactory = createKeyFactory(conf, tbl);
            if (keyFactory != null) {
                keyFactory.init(this, tbl);
            }
            return keyFactory;
        } catch (Exception e) {
            throw new SerDeException(e);
        }
    }

    private static HBaseKeyFactory createKeyFactory(Configuration job, Properties tbl)
            throws Exception {
        String factoryClassName = tbl.getProperty(HBaseSerDe.HBASE_COMPOSITE_KEY_FACTORY);
        if (factoryClassName != null) {
            Class<?> factoryClazz = loadClass(factoryClassName, job);
            return (HBaseKeyFactory) ReflectionUtils.newInstance(factoryClazz, job);
        }
        String keyClassName = tbl.getProperty(HBaseSerDe.HBASE_COMPOSITE_KEY_CLASS);
        if (keyClassName != null) {
            Class<?> keyClass = loadClass(keyClassName, job);
            return new CompositeHBaseKeyFactory(keyClass);
        }
        return new DefaultHBaseKeyFactory();
    }

    private static Class<?> loadClass(String className, @Nullable Configuration configuration)
            throws Exception {
        if (configuration != null) {
            return configuration.getClassByName(className);
        }
        return JavaUtils.loadClass(className);
    }

    private List<HBaseValueFactory> initValueFactories(Configuration conf, Properties tbl)
            throws SerDeException {
        List<HBaseValueFactory> valueFactories = createValueFactories(conf, tbl);

        for (HBaseValueFactory valueFactory : valueFactories) {
            valueFactory.init(this, conf, tbl);
        }

        return valueFactories;
    }

    private List<HBaseValueFactory> createValueFactories(Configuration conf, Properties tbl)
            throws SerDeException {
        List<HBaseValueFactory> valueFactories = new ArrayList<HBaseValueFactory>();

        try {
            for (int i = 0; i < columnMappings.size(); i++) {
                String serType = getSerializationType(conf, tbl, columnMappings.getColumnsMapping()[i]);

                if (AVRO_SERIALIZATION_TYPE.equals(serType)) {
                    Schema schema = getSchema(conf, tbl, columnMappings.getColumnsMapping()[i]);
                    valueFactories.add(new AvroHBaseValueFactory(i, schema));
                } else if (STRUCT_SERIALIZATION_TYPE.equals(serType)) {
                    String structValueClassName = tbl.getProperty(HBaseSerDe.HBASE_STRUCT_SERIALIZER_CLASS);

                    if (structValueClassName == null) {
                        throw new IllegalArgumentException(HBaseSerDe.HBASE_STRUCT_SERIALIZER_CLASS
                                + " must be set for hbase columns of type [" + STRUCT_SERIALIZATION_TYPE + "]");
                    }

                    Class<?> structValueClass = loadClass(structValueClassName, job);
                    valueFactories.add(new StructHBaseValueFactory(i, structValueClass));
                } else {
                    valueFactories.add(new DefaultHBaseValueFactory(i));
                }
            }
        } catch (Exception e) {
            throw new SerDeException(e);
        }

        return valueFactories;
    }

    /**
     * Get the type for the given {@link ColumnMapping colMap}
     * */
    private String getSerializationType(Configuration conf, Properties tbl,
                                        ColumnMapping colMap) throws Exception {
        String serType = null;

        if (colMap.qualifierName == null) {
            // only a column family

            if (colMap.qualifierPrefix != null) {
                serType = tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                        + HBaseSerDe.SERIALIZATION_TYPE);
            } else {
                serType = tbl.getProperty(colMap.familyName + "." + HBaseSerDe.SERIALIZATION_TYPE);
            }
        } else if (!colMap.hbaseRowKey) {
            // not an hbase row key. This should either be a prefix or an individual qualifier
            String qualifierName = colMap.qualifierName;

            if (colMap.qualifierName.endsWith("*")) {
                qualifierName = colMap.qualifierName.substring(0, colMap.qualifierName.length() - 1);
            }

            serType =
                    tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                            + HBaseSerDe.SERIALIZATION_TYPE);
        }

        return serType;
    }

    private Schema getSchema(Configuration conf, Properties tbl, ColumnMapping colMap)
            throws Exception {
        String serType = null;
        String serClassName = null;
        String schemaLiteral = null;
        String schemaUrl = null;

        if (colMap.qualifierName == null) {
            // only a column family

            if (colMap.qualifierPrefix != null) {
                serType =
                        tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                + HBaseSerDe.SERIALIZATION_TYPE);

                serClassName =
                        tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                + serdeConstants.SERIALIZATION_CLASS);

                schemaLiteral =
                        tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                + AvroTableProperties.SCHEMA_LITERAL.getPropName());

                schemaUrl =
                        tbl.getProperty(colMap.familyName + "." + colMap.qualifierPrefix + "."
                                + AvroTableProperties.SCHEMA_URL.getPropName());
            } else {
                serType = tbl.getProperty(colMap.familyName + "." + HBaseSerDe.SERIALIZATION_TYPE);

                serClassName =
                        tbl.getProperty(colMap.familyName + "." + serdeConstants.SERIALIZATION_CLASS);

                schemaLiteral = tbl.getProperty(colMap.familyName + "." + AvroTableProperties.SCHEMA_LITERAL.getPropName());

                schemaUrl = tbl.getProperty(colMap.familyName + "." + AvroTableProperties.SCHEMA_URL.getPropName());
            }
        } else if (!colMap.hbaseRowKey) {
            // not an hbase row key. This should either be a prefix or an individual qualifier
            String qualifierName = colMap.qualifierName;

            if (colMap.qualifierName.endsWith("*")) {
                qualifierName = colMap.qualifierName.substring(0, colMap.qualifierName.length() - 1);
            }

            serType =
                    tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                            + HBaseSerDe.SERIALIZATION_TYPE);

            serClassName =
                    tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                            + serdeConstants.SERIALIZATION_CLASS);

            schemaLiteral =
                    tbl.getProperty(colMap.familyName + "." + qualifierName + "."
                            + AvroTableProperties.SCHEMA_LITERAL.getPropName());

            schemaUrl =
                    tbl.getProperty(colMap.familyName + "." + qualifierName + "." + AvroTableProperties.SCHEMA_URL.getPropName());
        }

        if (serType == null) {
            throw new IllegalArgumentException("serialization.type property is missing");
        }

        String avroSchemaRetClass = tbl.getProperty(AvroTableProperties.SCHEMA_RETRIEVER.getPropName());

        if (schemaLiteral == null && serClassName == null && schemaUrl == null
                && avroSchemaRetClass == null) {
            throw new IllegalArgumentException("serialization.type was set to [" + serType
                    + "] but neither " + AvroTableProperties.SCHEMA_LITERAL.getPropName() + ", " + AvroTableProperties.SCHEMA_URL.getPropName()
                    + ", serialization.class or " + AvroTableProperties.SCHEMA_RETRIEVER.getPropName() + " property was set");
        }

        Class<?> deserializerClass = null;

        if (serClassName != null) {
            deserializerClass = loadClass(serClassName, conf);
        }

        Schema schema = null;

        // only worry about getting schema if we are dealing with Avro
        if (serType.equalsIgnoreCase(AVRO_SERIALIZATION_TYPE)) {
            if (avroSchemaRetClass == null) {
                // bother about generating a schema only if a schema retriever class wasn't provided
                if (schemaLiteral != null) {
                    schema = Schema.parse(schemaLiteral);
                } else if (schemaUrl != null) {
                    schema = HBaseSerDeHelper.getSchemaFromFS(schemaUrl, conf);
                } else if (deserializerClass != null) {
                    schema = ReflectData.get().getSchema(deserializerClass);
                }
            }
        }

        return schema;
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

package org.apache.hadoop.hive.hbase;

        import java.io.DataInput;
        import java.io.DataOutput;
        import java.io.IOException;

        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hbase.mapreduce.TableSplit;
        import org.apache.hadoop.mapred.FileSplit;
        import org.apache.hadoop.mapred.InputSplit;

/**
 * HBaseSplit augments FileSplit with HBase column mapping.
 */
public class HBaseSplit extends FileSplit implements InputSplit {

    private final TableSplit tableSplit;
    private final InputSplit snapshotSplit;
    private boolean isTableSplit; // should be final but Writable

    /**
     * For Writable
     */
    public HBaseSplit() {
        super((Path) null, 0, 0, (String[]) null);
        tableSplit = new TableSplit();
        snapshotSplit = HBaseTableSnapshotInputFormatUtil.createTableSnapshotRegionSplit();
    }

    public HBaseSplit(TableSplit tableSplit, Path dummyPath) {
        super(dummyPath, 0, 0, (String[]) null);
        this.tableSplit = tableSplit;
        this.snapshotSplit = HBaseTableSnapshotInputFormatUtil.createTableSnapshotRegionSplit();
        this.isTableSplit = true;
    }

    /**
     * TODO: use TableSnapshotRegionSplit HBASE-11555 is fixed.
     */
    public HBaseSplit(InputSplit snapshotSplit, Path dummyPath) {
        super(dummyPath, 0, 0, (String[]) null);
        this.tableSplit = new TableSplit();
        this.snapshotSplit = snapshotSplit;
        this.isTableSplit = false;
    }

    public TableSplit getTableSplit() {
        assert isTableSplit;
        return this.tableSplit;
    }

    public InputSplit getSnapshotSplit() {
        assert !isTableSplit;
        return this.snapshotSplit;
    }

    @Override
    public String toString() {
        return "" + (isTableSplit ? tableSplit : snapshotSplit);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        super.readFields(in);
        this.isTableSplit = in.readBoolean();
        if (this.isTableSplit) {
            tableSplit.readFields(in);
        } else {
            snapshotSplit.readFields(in);
        }
    }

    @Override
    public void write(DataOutput out) throws IOException {
        super.write(out);
        out.writeBoolean(isTableSplit);
        if (isTableSplit) {
            tableSplit.write(out);
        } else {
            snapshotSplit.write(out);
        }
    }

    @Override
    public long getLength() {
        long val = 0;
        try {
            val = isTableSplit ? tableSplit.getLength() : snapshotSplit.getLength();
        } finally {
            return val;
        }
    }

    @Override
    public String[] getLocations() throws IOException {
        return isTableSplit ? tableSplit.getLocations() : snapshotSplit.getLocations();
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.util.ArrayList;
        import java.util.LinkedHashSet;
        import java.util.List;
        import java.util.Map;
        import java.util.Map.Entry;
        import java.util.Properties;
        import java.util.Set;

        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hbase.HBaseConfiguration;
        import org.apache.hadoop.hbase.client.Connection;
        import org.apache.hadoop.hbase.client.ConnectionFactory;
        import org.apache.hadoop.hbase.mapred.TableOutputFormat;
        import org.apache.hadoop.hbase.mapreduce.TableInputFormatBase;
        import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
        import org.apache.hadoop.hbase.security.User;
        import org.apache.hadoop.hbase.security.token.TokenUtil;
        import org.apache.hadoop.hive.conf.HiveConf;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.metastore.HiveMetaHook;
        import org.apache.hadoop.hive.metastore.api.MetaException;
        import org.apache.hadoop.hive.metastore.api.hive_metastoreConstants;
        import org.apache.hadoop.hive.metastore.utils.MetaStoreUtils;
        import org.apache.hadoop.hive.ql.exec.FunctionRegistry;
        import org.apache.hadoop.hive.ql.index.IndexPredicateAnalyzer;
        import org.apache.hadoop.hive.ql.index.IndexSearchCondition;
        import org.apache.hadoop.hive.ql.metadata.DefaultStorageHandler;
        import org.apache.hadoop.hive.ql.metadata.HiveStoragePredicateHandler;
        import org.apache.hadoop.hive.ql.plan.ExprNodeDesc;
        import org.apache.hadoop.hive.ql.plan.ExprNodeGenericFuncDesc;
        import org.apache.hadoop.hive.ql.plan.TableDesc;
        import org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqual;
        import org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrGreaterThan;
        import org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrLessThan;
        import org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPGreaterThan;
        import org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPLessThan;
        import org.apache.hadoop.hive.serde2.Deserializer;
        import org.apache.hadoop.hive.serde2.AbstractSerDe;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector.Category;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorUtils;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorUtils.PrimitiveGrouping;
        import org.apache.hadoop.hive.serde2.typeinfo.PrimitiveTypeInfo;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfoFactory;
        import org.apache.hadoop.hive.shims.ShimLoader;
        import org.apache.hadoop.mapred.InputFormat;
        import org.apache.hadoop.mapred.JobConf;
        import org.apache.hadoop.mapred.OutputFormat;
        import org.apache.hadoop.mapreduce.Job;
        import org.apache.hadoop.util.StringUtils;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;

        import com.codahale.metrics.MetricRegistry;

/**
 * HBaseStorageHandler provides a HiveStorageHandler implementation for
 * HBase.
 */
public class HBaseStorageHandler extends DefaultStorageHandler
        implements HiveStoragePredicateHandler {

    private static final Logger LOG = LoggerFactory.getLogger(HBaseStorageHandler.class);

    /** HBase-internal config by which input format receives snapshot name. */
    private static final String HBASE_SNAPSHOT_NAME_KEY = "hbase.TableSnapshotInputFormat.snapshot.name";
    /** HBase-internal config by which input format received restore dir before HBASE-11335. */
    private static final String HBASE_SNAPSHOT_TABLE_DIR_KEY = "hbase.TableSnapshotInputFormat.table.dir";
    /** HBase-internal config by which input format received restore dir after HBASE-11335. */
    private static final String HBASE_SNAPSHOT_RESTORE_DIR_KEY = "hbase.TableSnapshotInputFormat.restore.dir";
    private static final String[] HBASE_CACHE_KEYS = new String[] {
            /** HBase config by which a SlabCache is sized. From HBase [0.98.3, 1.0.0) */
            "hbase.offheapcache.percentage",
            /** HBase config by which a BucketCache is sized. */
            "hbase.bucketcache.size",
            /** HBase config by which the bucket cache implementation is chosen. From HBase 0.98.10+ */
            "hbase.bucketcache.ioengine",
            /** HBase config by which a BlockCache is sized. */
            "hfile.block.cache.size"
    };

    final static public String DEFAULT_PREFIX = "default.";

    //Check if the configure job properties is called from input
    // or output for setting asymmetric properties
    private boolean configureInputJobProps = true;

    private Configuration jobConf;
    private Configuration hbaseConf;

    @Override
    public Configuration getConf() {
        return hbaseConf;
    }

    public Configuration getJobConf() {
        return jobConf;
    }

    @Override
    public void setConf(Configuration conf) {
        jobConf = conf;
        hbaseConf = HBaseConfiguration.create(conf);
    }

    @Override
    public Class<? extends InputFormat> getInputFormatClass() {
        if (HiveConf.getVar(jobConf, HiveConf.ConfVars.HIVE_HBASE_SNAPSHOT_NAME) != null) {
            LOG.debug("Using TableSnapshotInputFormat");
            return HiveHBaseTableSnapshotInputFormat.class;
        }
        LOG.debug("Using HiveHBaseTableInputFormat");
        return HiveHBaseTableInputFormat.class;
    }

    @Override
    public Class<? extends OutputFormat> getOutputFormatClass() {
        if (isHBaseGenerateHFiles(jobConf)) {
            return HiveHFileOutputFormat.class;
        }
        return HiveHBaseTableOutputFormat.class;
    }

    @Override
    public Class<? extends AbstractSerDe> getSerDeClass() {
        return HBaseSerDe.class;
    }

    @Override
    public HiveMetaHook getMetaHook() {
        return new HBaseMetaHook(hbaseConf);
    }

    @Override
    public void configureInputJobProperties(
            TableDesc tableDesc,
            Map<String, String> jobProperties) {
        //Input
        this.configureInputJobProps = true;
        configureTableJobProperties(tableDesc, jobProperties);
    }

    @Override
    public void configureOutputJobProperties(
            TableDesc tableDesc,
            Map<String, String> jobProperties) {
        //Output
        this.configureInputJobProps = false;
        configureTableJobProperties(tableDesc, jobProperties);
    }

    @Override
    public void configureTableJobProperties(
            TableDesc tableDesc,
            Map<String, String> jobProperties) {

        Properties tableProperties = tableDesc.getProperties();

        jobProperties.put(
                HBaseSerDe.HBASE_COLUMNS_MAPPING,
                tableProperties.getProperty(HBaseSerDe.HBASE_COLUMNS_MAPPING));
        jobProperties.put(HBaseSerDe.HBASE_COLUMNS_REGEX_MATCHING,
                tableProperties.getProperty(HBaseSerDe.HBASE_COLUMNS_REGEX_MATCHING, "true"));
        jobProperties.put(HBaseSerDe.HBASE_COLUMNS_PREFIX_HIDE,
                tableProperties.getProperty(HBaseSerDe.HBASE_COLUMNS_PREFIX_HIDE, "false"));
        jobProperties.put(HBaseSerDe.HBASE_TABLE_DEFAULT_STORAGE_TYPE,
                tableProperties.getProperty(HBaseSerDe.HBASE_TABLE_DEFAULT_STORAGE_TYPE,"string"));
        jobProperties.put(HBaseSerDe.HBASE_SCAN_CACHEBLOCKS, tableProperties
                .getProperty(HBaseSerDe.HBASE_SCAN_CACHEBLOCKS, "false"));
        String scanCache = tableProperties.getProperty(HBaseSerDe.HBASE_SCAN_CACHE);
        if (scanCache != null) {
            jobProperties.put(HBaseSerDe.HBASE_SCAN_CACHE, scanCache);
        }
        String scanBatch = tableProperties.getProperty(HBaseSerDe.HBASE_SCAN_BATCH);
        if (scanBatch != null) {
            jobProperties.put(HBaseSerDe.HBASE_SCAN_BATCH, scanBatch);
        }

        String tableName = tableProperties.getProperty(HBaseSerDe.HBASE_TABLE_NAME);
        if (tableName == null) {
            tableName = tableProperties.getProperty(hive_metastoreConstants.META_TABLE_NAME);
            tableName = tableName.toLowerCase();
            if (tableName.startsWith(DEFAULT_PREFIX)) {
                tableName = tableName.substring(DEFAULT_PREFIX.length());
            }
        }
        jobProperties.put(HBaseSerDe.HBASE_TABLE_NAME, tableName);

        Configuration jobConf = getJobConf();
        addHBaseResources(jobConf, jobProperties);

        // do this for reconciling HBaseStorageHandler for use in HCatalog
        // check to see if this an input job or an outputjob
        if (this.configureInputJobProps) {
            LOG.info("Configuring input job properties");
            String snapshotName = HiveConf.getVar(jobConf, HiveConf.ConfVars.HIVE_HBASE_SNAPSHOT_NAME);
            if (snapshotName != null) {
                HBaseTableSnapshotInputFormatUtil.assertSupportsTableSnapshots();

                try {
                    String restoreDir =
                            HiveConf.getVar(jobConf, HiveConf.ConfVars.HIVE_HBASE_SNAPSHOT_RESTORE_DIR);
                    if (restoreDir == null) {
                        throw new IllegalArgumentException(
                                "Cannot process HBase snapshot without specifying " + HiveConf.ConfVars
                                        .HIVE_HBASE_SNAPSHOT_RESTORE_DIR);
                    }

                    HBaseTableSnapshotInputFormatUtil.configureJob(hbaseConf, snapshotName, new Path(restoreDir));
                    // copy over configs touched by above method
                    jobProperties.put(HBASE_SNAPSHOT_NAME_KEY, hbaseConf.get(HBASE_SNAPSHOT_NAME_KEY));
                    if (hbaseConf.get(HBASE_SNAPSHOT_TABLE_DIR_KEY, null) != null) {
                        jobProperties.put(HBASE_SNAPSHOT_TABLE_DIR_KEY, hbaseConf.get(HBASE_SNAPSHOT_TABLE_DIR_KEY));
                    } else {
                        jobProperties.put(HBASE_SNAPSHOT_RESTORE_DIR_KEY, hbaseConf.get(HBASE_SNAPSHOT_RESTORE_DIR_KEY));
                    }

                    TableMapReduceUtil.resetCacheConfig(hbaseConf);
                    // copy over configs touched by above method
                    for (String cacheKey : HBASE_CACHE_KEYS) {
                        final String value = hbaseConf.get(cacheKey);
                        if (value != null) {
                            jobProperties.put(cacheKey, value);
                        } else {
                            jobProperties.remove(cacheKey);
                        }
                    }
                } catch (IOException e) {
                    throw new IllegalArgumentException(e);
                }
            }

            for (String k : jobProperties.keySet()) {
                jobConf.set(k, jobProperties.get(k));
            }
            try {
                addHBaseDelegationToken(jobConf);
            } catch (IOException | MetaException e) {
                throw new IllegalStateException("Error while configuring input job properties", e);
            } //input job properties
        }
        else {
            LOG.info("Configuring output job properties");
            if (isHBaseGenerateHFiles(jobConf)) {
                // only support bulkload when a hfile.family.path has been specified.
                // TODO: support detecting cf's from column mapping
                // TODO: support loading into multiple CF's at a time
                String path = HiveHFileOutputFormat.getFamilyPath(jobConf, tableProperties);
                if (path == null || path.isEmpty()) {
                    throw new RuntimeException("Please set " + HiveHFileOutputFormat.HFILE_FAMILY_PATH + " to target location for HFiles");
                }
                // TODO: should call HiveHFileOutputFormat#setOutputPath
                jobProperties.put("mapred.output.dir", path);
            } else {
                jobProperties.put(TableOutputFormat.OUTPUT_TABLE, tableName);
            }
        } // output job properties
    }

    /**
     * Return true when HBaseStorageHandler should generate hfiles instead of operate against the
     * online table. This mode is implicitly applied when "hive.hbase.generatehfiles" is true.
     */
    public static boolean isHBaseGenerateHFiles(Configuration conf) {
        return HiveConf.getBoolVar(conf, HiveConf.ConfVars.HIVE_HBASE_GENERATE_HFILES);
    }

    /**
     * Utility method to add hbase-default.xml and hbase-site.xml properties to a new map
     * if they are not already present in the jobConf.
     * @param jobConf Job configuration
     * @param newJobProperties  Map to which new properties should be added
     */
    private void addHBaseResources(Configuration jobConf,
                                   Map<String, String> newJobProperties) {
        Configuration conf = new Configuration(false);
        HBaseConfiguration.addHbaseResources(conf);
        for (Entry<String, String> entry : conf) {
            if (jobConf.get(entry.getKey()) == null) {
                newJobProperties.put(entry.getKey(), entry.getValue());
            }
        }
    }

    private void addHBaseDelegationToken(Configuration conf) throws IOException, MetaException {
        if (User.isHBaseSecurityEnabled(conf)) {
            Connection connection = ConnectionFactory.createConnection(hbaseConf);
            try {
                User curUser = User.getCurrent();
                Job job = new Job(conf);
                TokenUtil.addTokenForJob(connection, curUser, job);
            } catch (InterruptedException e) {
                throw new IOException("Error while obtaining hbase delegation token", e);
            } finally {
                if (connection != null) {
                    connection.close();
                }
            }
        }
    }

    private static Class counterClass = null;
    static {
        try {
            counterClass = Class.forName("org.cliffc.high_scale_lib.Counter");
        } catch (ClassNotFoundException cnfe) {
            // this dependency is removed for HBase 1.0
        }
    }
    @Override
    public void configureJobConf(TableDesc tableDesc, JobConf jobConf) {
        try {
            HBaseSerDe.configureJobConf(tableDesc, jobConf);
      /*
       * HIVE-6356
       * The following code change is only needed for hbase-0.96.0 due to HBASE-9165, and
       * will not be required once Hive bumps up its hbase version). At that time , we will
       * only need TableMapReduceUtil.addDependencyJars(jobConf) here.
       */
            if (counterClass != null) {
                TableMapReduceUtil.addDependencyJars(
                        jobConf, HBaseStorageHandler.class, TableInputFormatBase.class, counterClass);
            } else {
                TableMapReduceUtil.addDependencyJars(
                        jobConf, HBaseStorageHandler.class, TableInputFormatBase.class);
            }
            if (HiveConf.getVar(jobConf, HiveConf.ConfVars.HIVE_HBASE_SNAPSHOT_NAME) != null) {
                // There is an extra dependency on MetricsRegistry for snapshot IF.
                TableMapReduceUtil.addDependencyJars(jobConf, MetricRegistry.class);
            }

            Set<String> merged = new LinkedHashSet<String>(jobConf.getStringCollection("tmpjars"));

            Job copy = new Job(jobConf);
            TableMapReduceUtil.addDependencyJars(copy);
            merged.addAll(copy.getConfiguration().getStringCollection("tmpjars"));
            jobConf.set("tmpjars", StringUtils.arrayToString(merged.toArray(new String[0])));

            // Get credentials using the configuration instance which has HBase properties
            JobConf hbaseJobConf = new JobConf(getConf());
            org.apache.hadoop.hbase.mapred.TableMapReduceUtil.initCredentials(hbaseJobConf);
            ShimLoader.getHadoopShims().mergeCredentials(jobConf, hbaseJobConf);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public DecomposedPredicate decomposePredicate(
            JobConf jobConf,
            Deserializer deserializer,
            ExprNodeDesc predicate)
    {
        HBaseKeyFactory keyFactory = ((HBaseSerDe) deserializer).getKeyFactory();
        return keyFactory.decomposePredicate(jobConf, deserializer, predicate);
    }

    public static DecomposedPredicate decomposePredicate(
            JobConf jobConf,
            HBaseSerDe hBaseSerDe,
            ExprNodeDesc predicate) {
        ColumnMapping keyMapping = hBaseSerDe.getHBaseSerdeParam().getKeyColumnMapping();
        ColumnMapping tsMapping = hBaseSerDe.getHBaseSerdeParam().getTimestampColumnMapping();
        IndexPredicateAnalyzer analyzer = HiveHBaseTableInputFormat.newIndexPredicateAnalyzer(
                keyMapping.columnName, keyMapping.isComparable(),
                tsMapping == null ? null : tsMapping.columnName);
        List<IndexSearchCondition> conditions = new ArrayList<IndexSearchCondition>();
        ExprNodeGenericFuncDesc pushedPredicate = null;
        ExprNodeGenericFuncDesc residualPredicate =
                (ExprNodeGenericFuncDesc)analyzer.analyzePredicate(predicate, conditions);

        for (List<IndexSearchCondition> searchConditions:
                HiveHBaseInputFormatUtil.decompose(conditions).values()) {
            int scSize = searchConditions.size();
            if (scSize < 1 || 2 < scSize) {
                // Either there was nothing which could be pushed down (size = 0),
                // there were complex predicates which we don't support yet.
                // Currently supported are one of the form:
                // 1. key < 20                        (size = 1)
                // 2. key = 20                        (size = 1)
                // 3. key < 20 and key > 10           (size = 2)
                // Add to residual
                residualPredicate =
                        extractResidualCondition(analyzer, searchConditions, residualPredicate);
                continue;
            }
            if (scSize == 2 &&
                    (searchConditions.get(0).getComparisonOp().equals(GenericUDFOPEqual.class.getName()) ||
                            searchConditions.get(1).getComparisonOp().equals(GenericUDFOPEqual.class.getName()))) {
                // If one of the predicates is =, then any other predicate with it is illegal.
                // Add to residual
                residualPredicate =
                        extractResidualCondition(analyzer, searchConditions, residualPredicate);
                continue;
            }
            boolean sameType = sameTypeIndexSearchConditions(searchConditions);
            if (!sameType) {
                // If type for column and constant are different, we currently do not support pushing them
                residualPredicate =
                        extractResidualCondition(analyzer, searchConditions, residualPredicate);
                continue;
            }
            TypeInfo typeInfo = searchConditions.get(0).getColumnDesc().getTypeInfo();
            if (typeInfo.getCategory() == Category.PRIMITIVE && PrimitiveObjectInspectorUtils.getPrimitiveGrouping(
                    ((PrimitiveTypeInfo) typeInfo).getPrimitiveCategory()) == PrimitiveGrouping.NUMERIC_GROUP) {
                // If the predicate is on a numeric column, and it specifies an
                // open range e.g. key < 20 , we do not support conversion, as negative
                // values are lexicographically stored after positive values and thus they
                // would be returned.
                if (scSize == 2) {
                    boolean lowerBound = false;
                    boolean upperBound = false;
                    if (searchConditions.get(0).getComparisonOp().equals(GenericUDFOPEqualOrLessThan.class.getName()) ||
                            searchConditions.get(0).getComparisonOp().equals(GenericUDFOPLessThan.class.getName())) {
                        lowerBound = true;
                    } else {
                        upperBound = true;
                    }
                    if (searchConditions.get(1).getComparisonOp().equals(GenericUDFOPEqualOrGreaterThan.class.getName()) ||
                            searchConditions.get(1).getComparisonOp().equals(GenericUDFOPGreaterThan.class.getName())) {
                        upperBound = true;
                    } else {
                        lowerBound = true;
                    }
                    if (!upperBound || !lowerBound) {
                        // Not valid range, add to residual
                        residualPredicate =
                                extractResidualCondition(analyzer, searchConditions, residualPredicate);
                        continue;
                    }
                } else {
                    // scSize == 1
                    if (!searchConditions.get(0).getComparisonOp().equals(GenericUDFOPEqual.class.getName())) {
                        // Not valid range, add to residual
                        residualPredicate =
                                extractResidualCondition(analyzer, searchConditions, residualPredicate);
                        continue;
                    }
                }
            }

            // This one can be pushed
            pushedPredicate =
                    extractStorageHandlerCondition(analyzer, searchConditions, pushedPredicate);
        }

        DecomposedPredicate decomposedPredicate = new DecomposedPredicate();
        decomposedPredicate.pushedPredicate = pushedPredicate;
        decomposedPredicate.residualPredicate = residualPredicate;
        return decomposedPredicate;
    }

    private static ExprNodeGenericFuncDesc extractStorageHandlerCondition(IndexPredicateAnalyzer analyzer,
                                                                          List<IndexSearchCondition> searchConditions, ExprNodeGenericFuncDesc inputExpr) {
        if (inputExpr == null) {
            return analyzer.translateSearchConditions(searchConditions);
        }
        List<ExprNodeDesc> children = new ArrayList<ExprNodeDesc>();
        children.add(analyzer.translateSearchConditions(searchConditions));
        children.add(inputExpr);
        return new ExprNodeGenericFuncDesc(TypeInfoFactory.booleanTypeInfo,
                FunctionRegistry.getGenericUDFForAnd(), children);
    }

    private static ExprNodeGenericFuncDesc extractResidualCondition(IndexPredicateAnalyzer analyzer,
                                                                    List<IndexSearchCondition> searchConditions, ExprNodeGenericFuncDesc inputExpr) {
        if (inputExpr == null) {
            return analyzer.translateOriginalConditions(searchConditions);
        }
        List<ExprNodeDesc> children = new ArrayList<ExprNodeDesc>();
        children.add(analyzer.translateOriginalConditions(searchConditions));
        children.add(inputExpr);
        return new ExprNodeGenericFuncDesc(TypeInfoFactory.booleanTypeInfo,
                FunctionRegistry.getGenericUDFForAnd(), children);
    }

    private static boolean sameTypeIndexSearchConditions(List<IndexSearchCondition> searchConditions) {
        for (IndexSearchCondition isc : searchConditions) {
            if (!isc.getColumnDesc().getTypeInfo().equals(isc.getConstantDesc().getTypeInfo())) {
                return false;
            }
        }
        return true;
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

package org.apache.hadoop.hive.hbase;

        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hbase.mapreduce.TableSnapshotInputFormatImpl;
        import org.apache.hadoop.mapred.InputSplit;

        import java.io.IOException;
        import java.lang.reflect.Constructor;
        import java.lang.reflect.InvocationTargetException;

/**
 * A helper class to isolate newer HBase features from users running against older versions of
 * HBase that don't provide those features.
 *
 * TODO: remove this class when it's okay to drop support for earlier version of HBase.
 */
public class HBaseTableSnapshotInputFormatUtil {

    private static final Logger LOG = LoggerFactory.getLogger(HBaseTableSnapshotInputFormatUtil.class);

    /** The class we look for to determine if hbase snapshots are supported. */
    private static final String TABLESNAPSHOTINPUTFORMAT_CLASS
            = "org.apache.hadoop.hbase.mapreduce.TableSnapshotInputFormatImpl";

    private static final String TABLESNAPSHOTREGIONSPLIT_CLASS
            = "org.apache.hadoop.hbase.mapred.TableSnapshotInputFormat$TableSnapshotRegionSplit";

    /** True when {@link #TABLESNAPSHOTINPUTFORMAT_CLASS} is present. */
    private static final boolean SUPPORTS_TABLE_SNAPSHOTS;

    static {
        boolean support = false;
        try {
            Class<?> clazz = Class.forName(TABLESNAPSHOTINPUTFORMAT_CLASS);
            support = clazz != null;
        } catch (ClassNotFoundException e) {
            // pass
        }
        SUPPORTS_TABLE_SNAPSHOTS = support;
    }

    /** Return true when the HBase runtime supports {@link HiveHBaseTableSnapshotInputFormat}. */
    public static void assertSupportsTableSnapshots() {
        if (!SUPPORTS_TABLE_SNAPSHOTS) {
            throw new RuntimeException("This version of HBase does not support Hive over table " +
                    "snapshots. Please upgrade to at least HBase 0.98.3 or later. See HIVE-6584 for details.");
        }
    }

    /**
     * Configures {@code conf} for the snapshot job. Call only when
     * {@link #assertSupportsTableSnapshots()} returns true.
     */
    public static void configureJob(Configuration conf, String snapshotName, Path restoreDir)
            throws IOException {
        TableSnapshotInputFormatImpl.setInput(conf, snapshotName, restoreDir);
    }

    /**
     * Create a bare TableSnapshotRegionSplit. Needed because Writables require a
     * default-constructed instance to hydrate from the DataInput.
     *
     * TODO: remove once HBASE-11555 is fixed.
     */
    public static InputSplit createTableSnapshotRegionSplit() {
        try {
            assertSupportsTableSnapshots();
        } catch (RuntimeException e) {
            LOG.debug("Probably don't support table snapshots. Returning null instance.", e);
            return null;
        }

        try {
            Class<? extends InputSplit> resultType =
                    (Class<? extends InputSplit>) Class.forName(TABLESNAPSHOTREGIONSPLIT_CLASS);
            Constructor<? extends InputSplit> cxtor = resultType.getDeclaredConstructor(new Class[]{});
            cxtor.setAccessible(true);
            return cxtor.newInstance(new Object[]{});
        } catch (ClassNotFoundException e) {
            throw new UnsupportedOperationException(
                    "Unable to find " + TABLESNAPSHOTREGIONSPLIT_CLASS, e);
        } catch (IllegalAccessException e) {
            throw new UnsupportedOperationException(
                    "Unable to access specified class " + TABLESNAPSHOTREGIONSPLIT_CLASS, e);
        } catch (InstantiationException e) {
            throw new UnsupportedOperationException(
                    "Unable to instantiate specified class " + TABLESNAPSHOTREGIONSPLIT_CLASS, e);
        } catch (InvocationTargetException e) {
            throw new UnsupportedOperationException(
                    "Constructor threw an exception for " + TABLESNAPSHOTREGIONSPLIT_CLASS, e);
        } catch (NoSuchMethodException e) {
            throw new UnsupportedOperationException(
                    "Unable to find suitable constructor for class " + TABLESNAPSHOTREGIONSPLIT_CLASS, e);
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.util.ArrayList;
        import java.util.HashMap;
        import java.util.List;
        import java.util.Map;

        import org.apache.hadoop.hbase.HConstants;
        import org.apache.hadoop.hbase.client.Scan;
        import org.apache.hadoop.hbase.filter.FilterList;
        import org.apache.hadoop.hbase.filter.FirstKeyOnlyFilter;
        import org.apache.hadoop.hbase.filter.KeyOnlyFilter;
        import org.apache.hadoop.hbase.util.Bytes;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.ql.exec.ExprNodeConstantEvaluator;
        import org.apache.hadoop.hive.ql.exec.SerializationUtilities;
        import org.apache.hadoop.hive.ql.index.IndexSearchCondition;
        import org.apache.hadoop.hive.ql.metadata.HiveException;
        import org.apache.hadoop.hive.ql.plan.TableScanDesc;
        import org.apache.hadoop.hive.serde2.ByteStream;
        import org.apache.hadoop.hive.serde2.ColumnProjectionUtils;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.io.ByteWritable;
        import org.apache.hadoop.hive.serde2.io.DoubleWritable;
        import org.apache.hadoop.hive.serde2.io.ShortWritable;
        import org.apache.hadoop.hive.serde2.lazy.LazyUtils;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector.PrimitiveCategory;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.LongObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorUtils;
        import org.apache.hadoop.io.BooleanWritable;
        import org.apache.hadoop.io.FloatWritable;
        import org.apache.hadoop.io.IntWritable;
        import org.apache.hadoop.io.LongWritable;
        import org.apache.hadoop.io.Text;
        import org.apache.hadoop.mapred.JobConf;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;

/**
 * Util code common between HiveHBaseTableInputFormat and HiveHBaseTableSnapshotInputFormat.
 */
class HiveHBaseInputFormatUtil {

    private static final Logger LOG = LoggerFactory.getLogger(HiveHBaseInputFormatUtil.class);

    /**
     * Parse {@code jobConf} to create a {@link Scan} instance.
     */
    public static Scan getScan(JobConf jobConf) throws IOException {
        String hbaseColumnsMapping = jobConf.get(HBaseSerDe.HBASE_COLUMNS_MAPPING);
        boolean doColumnRegexMatching = jobConf.getBoolean(HBaseSerDe.HBASE_COLUMNS_REGEX_MATCHING, true);
        List<Integer> readColIDs = ColumnProjectionUtils.getReadColumnIDs(jobConf);
        ColumnMappings columnMappings;

        try {
            columnMappings = HBaseSerDe.parseColumnsMapping(hbaseColumnsMapping, doColumnRegexMatching);
        } catch (SerDeException e) {
            throw new IOException(e);
        }

        if (columnMappings.size() < readColIDs.size()) {
            throw new IOException("Cannot read more columns than the given table contains.");
        }

        boolean readAllColumns = ColumnProjectionUtils.isReadAllColumns(jobConf);
        Scan scan = new Scan();
        boolean empty = true;

        // The list of families that have been added to the scan
        List<String> addedFamilies = new ArrayList<String>();

        if (!readAllColumns) {
            ColumnMapping[] columnsMapping = columnMappings.getColumnsMapping();
            for (int i : readColIDs) {
                ColumnMapping colMap = columnsMapping[i];
                if (colMap.hbaseRowKey || colMap.hbaseTimestamp) {
                    continue;
                }

                if (colMap.qualifierName == null) {
                    scan.addFamily(colMap.familyNameBytes);
                    addedFamilies.add(colMap.familyName);
                } else {
                    if(!addedFamilies.contains(colMap.familyName)){
                        // add only if the corresponding family has not already been added
                        scan.addColumn(colMap.familyNameBytes, colMap.qualifierNameBytes);
                    }
                }

                empty = false;
            }
        }

        // If we have cases where we are running a query like count(key) or count(*),
        // in such cases, the readColIDs is either empty(for count(*)) or has just the
        // key column in it. In either case, nothing gets added to the scan. So if readAllColumns is
        // true, we are going to add all columns. Else we are just going to add a key filter to run a
        // count only on the keys
        if (empty) {
            if (readAllColumns) {
                for (ColumnMapping colMap: columnMappings) {
                    if (colMap.hbaseRowKey || colMap.hbaseTimestamp) {
                        continue;
                    }

                    if (colMap.qualifierName == null) {
                        scan.addFamily(colMap.familyNameBytes);
                    } else {
                        scan.addColumn(colMap.familyNameBytes, colMap.qualifierNameBytes);
                    }
                }
            } else {
                // Add a filter to just do a scan on the keys so that we pick up everything
                scan.setFilter(new FilterList(new FirstKeyOnlyFilter(), new KeyOnlyFilter()));
            }
        }

        String scanCache = jobConf.get(HBaseSerDe.HBASE_SCAN_CACHE);
        if (scanCache != null) {
            scan.setCaching(Integer.parseInt(scanCache));
        }

        boolean scanCacheBlocks =
                jobConf.getBoolean(HBaseSerDe.HBASE_SCAN_CACHEBLOCKS, false);
        scan.setCacheBlocks(scanCacheBlocks);

        String scanBatch = jobConf.get(HBaseSerDe.HBASE_SCAN_BATCH);
        if (scanBatch != null) {
            scan.setBatch(Integer.parseInt(scanBatch));
        }

        String filterObjectSerialized = jobConf.get(TableScanDesc.FILTER_OBJECT_CONF_STR);

        if (filterObjectSerialized != null) {
            setupScanRange(scan, filterObjectSerialized, jobConf, true);
        }

        return scan;
    }

    public static boolean getStorageFormatOfKey(String spec, String defaultFormat) throws IOException{

        String[] mapInfo = spec.split("#");
        boolean tblLevelDefault = "binary".equalsIgnoreCase(defaultFormat);

        switch (mapInfo.length) {
            case 1:
                return tblLevelDefault;

            case 2:
                String storageType = mapInfo[1];
                if(storageType.equals("-")) {
                    return tblLevelDefault;
                } else if ("string".startsWith(storageType)){
                    return false;
                } else if ("binary".startsWith(storageType)){
                    return true;
                }

            default:
                throw new IOException("Malformed string: " + spec);
        }
    }

    public static Map<String, List<IndexSearchCondition>> decompose(
            List<IndexSearchCondition> searchConditions) {
        Map<String, List<IndexSearchCondition>> result =
                new HashMap<String, List<IndexSearchCondition>>();
        for (IndexSearchCondition condition : searchConditions) {
            List<IndexSearchCondition> conditions = result.get(condition.getColumnDesc().getColumn());
            if (conditions == null) {
                conditions = new ArrayList<IndexSearchCondition>();
                result.put(condition.getColumnDesc().getColumn(), conditions);
            }
            conditions.add(condition);
        }
        return result;
    }

    static void setupScanRange(Scan scan, String filterObjectSerialized, JobConf jobConf,
                               boolean filterOnly) throws IOException {
        HBaseScanRange range =
                SerializationUtilities.deserializeObject(filterObjectSerialized,
                        HBaseScanRange.class);
        try {
            range.setup(scan, jobConf, filterOnly);
        } catch (Exception e) {
            throw new IOException(e);
        }
    }

    static void setupKeyRange(Scan scan, List<IndexSearchCondition> conditions, boolean isBinary)
            throws IOException {
        // Convert the search condition into a restriction on the HBase scan
        byte[] startRow = HConstants.EMPTY_START_ROW, stopRow = HConstants.EMPTY_END_ROW;
        for (IndexSearchCondition sc : conditions) {

            ExprNodeConstantEvaluator eval = new ExprNodeConstantEvaluator(sc.getConstantDesc());
            PrimitiveObjectInspector objInspector;
            Object writable;

            try {
                objInspector = (PrimitiveObjectInspector) eval.initialize(null);
                writable = eval.evaluate(null);
            } catch (ClassCastException cce) {
                throw new IOException("Currently only primitve types are supported. Found: "
                        + sc.getConstantDesc().getTypeString());
            } catch (HiveException e) {
                throw new IOException(e);
            }

            byte[] constantVal = getConstantVal(writable, objInspector, isBinary);
            String comparisonOp = sc.getComparisonOp();

            if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqual".equals(comparisonOp)) {
                startRow = constantVal;
                stopRow = getNextBA(constantVal);
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPLessThan".equals(comparisonOp)) {
                stopRow = constantVal;
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrGreaterThan"
                    .equals(comparisonOp)) {
                startRow = constantVal;
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPGreaterThan"
                    .equals(comparisonOp)) {
                startRow = getNextBA(constantVal);
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrLessThan"
                    .equals(comparisonOp)) {
                stopRow = getNextBA(constantVal);
            } else {
                throw new IOException(comparisonOp + " is not a supported comparison operator");
            }
        }
        scan.setStartRow(startRow);
        scan.setStopRow(stopRow);

        if (LOG.isDebugEnabled()) {
            LOG.debug(Bytes.toStringBinary(startRow) + " ~ " + Bytes.toStringBinary(stopRow));
        }
    }

    static void setupTimeRange(Scan scan, List<IndexSearchCondition> conditions) throws IOException {
        long start = 0;
        long end = Long.MAX_VALUE;
        for (IndexSearchCondition sc : conditions) {
            long timestamp = getTimestampVal(sc);
            String comparisonOp = sc.getComparisonOp();
            if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqual".equals(comparisonOp)) {
                start = timestamp;
                end = timestamp + 1;
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPLessThan".equals(comparisonOp)) {
                end = timestamp;
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrGreaterThan"
                    .equals(comparisonOp)) {
                start = timestamp;
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPGreaterThan"
                    .equals(comparisonOp)) {
                start = timestamp + 1;
            } else if ("org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrLessThan"
                    .equals(comparisonOp)) {
                end = timestamp + 1;
            } else {
                throw new IOException(comparisonOp + " is not a supported comparison operator");
            }
        }
        scan.setTimeRange(start, end);
    }

    static long getTimestampVal(IndexSearchCondition sc) throws IOException {
        long timestamp;
        try {
            ExprNodeConstantEvaluator eval = new ExprNodeConstantEvaluator(sc.getConstantDesc());
            ObjectInspector inspector = eval.initialize(null);
            Object value = eval.evaluate(null);
            if (inspector instanceof LongObjectInspector) {
                timestamp = ((LongObjectInspector) inspector).get(value);
            } else {
                PrimitiveObjectInspector primitive = (PrimitiveObjectInspector) inspector;
                timestamp = PrimitiveObjectInspectorUtils.getTimestamp(value, primitive).toEpochMilli();
            }
        } catch (HiveException e) {
            throw new IOException(e);
        }
        return timestamp;
    }

    static byte[] getConstantVal(Object writable, PrimitiveObjectInspector poi, boolean isKeyBinary)
            throws IOException {

        if (!isKeyBinary) {
            // Key is stored in text format. Get bytes representation of constant also of
            // text format.
            byte[] startRow;
            ByteStream.Output serializeStream = new ByteStream.Output();
            LazyUtils.writePrimitiveUTF8(serializeStream, writable, poi, false, (byte) 0, null);
            startRow = new byte[serializeStream.getLength()];
            System.arraycopy(serializeStream.getData(), 0, startRow, 0, serializeStream.getLength());
            return startRow;
        }

        PrimitiveCategory pc = poi.getPrimitiveCategory();
        switch (poi.getPrimitiveCategory()) {
            case INT:
                return Bytes.toBytes(((IntWritable) writable).get());
            case BOOLEAN:
                return Bytes.toBytes(((BooleanWritable) writable).get());
            case LONG:
                return Bytes.toBytes(((LongWritable) writable).get());
            case FLOAT:
                return Bytes.toBytes(((FloatWritable) writable).get());
            case DOUBLE:
                return Bytes.toBytes(((DoubleWritable) writable).get());
            case SHORT:
                return Bytes.toBytes(((ShortWritable) writable).get());
            case STRING:
                return Bytes.toBytes(((Text) writable).toString());
            case BYTE:
                return Bytes.toBytes(((ByteWritable) writable).get());

            default:
                throw new IOException("Type not supported " + pc);
        }
    }

    static byte[] getNextBA(byte[] current) {
        // startRow is inclusive while stopRow is exclusive,
        // this util method returns very next bytearray which will occur after the current one
        // by padding current one with a trailing 0 byte.
        byte[] next = new byte[current.length + 1];
        System.arraycopy(current, 0, next, 0, current.length);
        return next;
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.security.PrivilegedExceptionAction;
        import java.util.ArrayList;
        import java.util.List;
        import java.util.Map;

        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hbase.HBaseConfiguration;
        import org.apache.hadoop.hbase.TableName;
        import org.apache.hadoop.hbase.client.Connection;
        import org.apache.hadoop.hbase.client.ConnectionFactory;
        import org.apache.hadoop.hbase.client.Result;
        import org.apache.hadoop.hbase.client.Scan;
        import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
        import org.apache.hadoop.hbase.mapred.TableMapReduceUtil;
        import org.apache.hadoop.hbase.mapreduce.TableInputFormatBase;
        import org.apache.hadoop.hbase.mapreduce.TableSplit;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.ql.exec.SerializationUtilities;
        import org.apache.hadoop.hive.ql.index.IndexPredicateAnalyzer;
        import org.apache.hadoop.hive.ql.index.IndexSearchCondition;
        import org.apache.hadoop.hive.ql.plan.ExprNodeDesc;
        import org.apache.hadoop.hive.ql.plan.ExprNodeGenericFuncDesc;
        import org.apache.hadoop.hive.ql.plan.TableScanDesc;
        import org.apache.hadoop.hive.serde.serdeConstants;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfoUtils;
        import org.apache.hadoop.hive.shims.ShimLoader;
        import org.apache.hadoop.mapred.InputFormat;
        import org.apache.hadoop.mapred.InputSplit;
        import org.apache.hadoop.mapred.JobConf;
        import org.apache.hadoop.mapred.RecordReader;
        import org.apache.hadoop.mapred.Reporter;
        import org.apache.hadoop.mapreduce.Job;
        import org.apache.hadoop.mapreduce.JobContext;
        import org.apache.hadoop.mapreduce.TaskAttemptContext;
        import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
        import org.apache.hadoop.security.UserGroupInformation;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;

/**
 * HiveHBaseTableInputFormat implements InputFormat for HBase storage handler
 * tables, decorating an underlying HBase TableInputFormat with extra Hive logic
 * such as column pruning and filter pushdown.
 */
public class HiveHBaseTableInputFormat extends TableInputFormatBase
        implements InputFormat<ImmutableBytesWritable, ResultWritable> {

    static final Logger LOG = LoggerFactory.getLogger(HiveHBaseTableInputFormat.class);
    private static final Object HBASE_TABLE_MONITOR = new Object();

    @Override public RecordReader<ImmutableBytesWritable, ResultWritable> getRecordReader(InputSplit split,
                                                                                          JobConf jobConf, final Reporter reporter) throws IOException {

        HBaseSplit hbaseSplit = (HBaseSplit) split;
        TableSplit tableSplit = hbaseSplit.getTableSplit();

        final org.apache.hadoop.mapreduce.RecordReader<ImmutableBytesWritable, Result> recordReader;

        Job job = new Job(jobConf);
        TaskAttemptContext tac = ShimLoader.getHadoopShims().newTaskAttemptContext(job.getConfiguration(), reporter);

        final Connection conn;

        synchronized (HBASE_TABLE_MONITOR) {
            conn = ConnectionFactory.createConnection(HBaseConfiguration.create(jobConf));
            initializeTable(conn, tableSplit.getTable());
            setScan(HiveHBaseInputFormatUtil.getScan(jobConf));
            recordReader = createRecordReader(tableSplit, tac);
            try {
                recordReader.initialize(tableSplit, tac);
            } catch (InterruptedException e) {
                closeTable(); // Free up the HTable connections
                conn.close();
                throw new IOException("Failed to initialize RecordReader", e);
            }
        }

        return new RecordReader<ImmutableBytesWritable, ResultWritable>() {

            @Override public void close() throws IOException {
                synchronized (HBASE_TABLE_MONITOR) {
                    recordReader.close();
                    closeTable();
                    conn.close();
                }
            }

            @Override public ImmutableBytesWritable createKey() {
                return new ImmutableBytesWritable();
            }

            @Override public ResultWritable createValue() {
                return new ResultWritable(new Result());
            }

            @Override public long getPos() throws IOException {
                return 0;
            }

            @Override public float getProgress() throws IOException {
                float progress = 0.0F;

                try {
                    progress = recordReader.getProgress();
                } catch (InterruptedException e) {
                    throw new IOException(e);
                }

                return progress;
            }

            @Override public boolean next(ImmutableBytesWritable rowKey, ResultWritable value) throws IOException {

                boolean next = false;

                try {
                    next = recordReader.nextKeyValue();

                    if (next) {
                        rowKey.set(recordReader.getCurrentValue().getRow());
                        value.setResult(recordReader.getCurrentValue());
                    }
                } catch (InterruptedException e) {
                    throw new IOException(e);
                }

                return next;
            }
        };
    }

    /**
     * Converts a filter (which has been pushed down from Hive's optimizer)
     * into corresponding restrictions on the HBase scan.  The
     * filter should already be in a form which can be fully converted.
     *
     * @param jobConf configuration for the scan
     *
     * @param iKey 0-based offset of key column within Hive table
     *
     * @return converted table split if any
     */
    private Scan createFilterScan(JobConf jobConf, int iKey, int iTimestamp, boolean isKeyBinary) throws IOException {

        // TODO: assert iKey is HBaseSerDe#HBASE_KEY_COL

        Scan scan = new Scan();
        String filterObjectSerialized = jobConf.get(TableScanDesc.FILTER_OBJECT_CONF_STR);
        if (filterObjectSerialized != null) {
            HiveHBaseInputFormatUtil.setupScanRange(scan, filterObjectSerialized, jobConf, false);
            return scan;
        }

        String filterExprSerialized = jobConf.get(TableScanDesc.FILTER_EXPR_CONF_STR);
        if (filterExprSerialized == null) {
            return scan;
        }

        ExprNodeGenericFuncDesc filterExpr = SerializationUtilities.deserializeExpression(filterExprSerialized);

        String keyColName = jobConf.get(serdeConstants.LIST_COLUMNS).split(",")[iKey];
        ArrayList<TypeInfo> cols = TypeInfoUtils.getTypeInfosFromTypeString(jobConf.get(serdeConstants.LIST_COLUMN_TYPES));
        String colType = cols.get(iKey).getTypeName();
        boolean isKeyComparable = isKeyBinary || "string".equalsIgnoreCase(colType);

        String tsColName = null;
        if (iTimestamp >= 0) {
            tsColName = jobConf.get(serdeConstants.LIST_COLUMNS).split(",")[iTimestamp];
        }

        IndexPredicateAnalyzer analyzer = newIndexPredicateAnalyzer(keyColName, isKeyComparable, tsColName);

        List<IndexSearchCondition> conditions = new ArrayList<IndexSearchCondition>();
        ExprNodeDesc residualPredicate = analyzer.analyzePredicate(filterExpr, conditions);

        // There should be no residual since we already negotiated that earlier in
        // HBaseStorageHandler.decomposePredicate. However, with hive.optimize.index.filter
        // OpProcFactory#pushFilterToStorageHandler pushes the original filter back down again.
        // Since pushed-down filters are not omitted at the higher levels (and thus the
        // contract of negotiation is ignored anyway), just ignore the residuals.
        // Re-assess this when negotiation is honored and the duplicate evaluation is removed.
        // THIS IGNORES RESIDUAL PARSING FROM HBaseStorageHandler#decomposePredicate
        if (residualPredicate != null) {
            LOG.debug("Ignoring residual predicate " + residualPredicate.getExprString());
        }

        Map<String, List<IndexSearchCondition>> split = HiveHBaseInputFormatUtil.decompose(conditions);
        List<IndexSearchCondition> keyConditions = split.get(keyColName);
        if (keyConditions != null && !keyConditions.isEmpty()) {
            HiveHBaseInputFormatUtil.setupKeyRange(scan, keyConditions, isKeyBinary);
        }
        List<IndexSearchCondition> tsConditions = split.get(tsColName);
        if (tsConditions != null && !tsConditions.isEmpty()) {
            HiveHBaseInputFormatUtil.setupTimeRange(scan, tsConditions);
        }
        return scan;
    }

    /**
     * Instantiates a new predicate analyzer suitable for
     * determining how to push a filter down into the HBase scan,
     * based on the rules for what kinds of pushdown we currently support.
     *
     * @param keyColumnName name of the Hive column mapped to the HBase row key
     *
     * @return preconfigured predicate analyzer
     */
    static IndexPredicateAnalyzer newIndexPredicateAnalyzer(String keyColumnName, boolean isKeyComparable,
                                                            String timestampColumn) {

        IndexPredicateAnalyzer analyzer = new IndexPredicateAnalyzer();

        // We can always do equality predicate. Just need to make sure we get appropriate
        // BA representation of constant of filter condition.
        // We can do other comparisons only if storage format in hbase is either binary
        // or we are dealing with string types since there lexicographic ordering will suffice.
        if (isKeyComparable) {
            analyzer.addComparisonOp(keyColumnName, "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqual",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrGreaterThan",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrLessThan",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPLessThan",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPGreaterThan");
        } else {
            analyzer.addComparisonOp(keyColumnName, "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqual");
        }

        if (timestampColumn != null) {
            analyzer.addComparisonOp(timestampColumn, "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqual",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrGreaterThan",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPEqualOrLessThan",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPLessThan",
                    "org.apache.hadoop.hive.ql.udf.generic.GenericUDFOPGreaterThan");
        }

        return analyzer;
    }

    @Override public InputSplit[] getSplits(final JobConf jobConf, final int numSplits) throws IOException {
        synchronized (HBASE_TABLE_MONITOR) {
            final UserGroupInformation ugi = UserGroupInformation.getCurrentUser();
            if (ugi == null) {
                return getSplitsInternal(jobConf, numSplits);
            }

            try {
                return ugi.doAs(new PrivilegedExceptionAction<InputSplit[]>() {
                    @Override public InputSplit[] run() throws IOException {
                        return getSplitsInternal(jobConf, numSplits);
                    }
                });
            } catch (InterruptedException e) {
                throw new IOException(e);
            }
        }
    }

    private InputSplit[] getSplitsInternal(JobConf jobConf, int numSplits) throws IOException {

        //obtain delegation tokens for the job
        if (UserGroupInformation.getCurrentUser().hasKerberosCredentials()) {
            TableMapReduceUtil.initCredentials(jobConf);
        }

        String hbaseTableName = jobConf.get(HBaseSerDe.HBASE_TABLE_NAME);

        Connection conn = ConnectionFactory.createConnection(HBaseConfiguration.create(jobConf));

        TableName tableName = TableName.valueOf(hbaseTableName);
        initializeTable(conn, tableName);

        String hbaseColumnsMapping = jobConf.get(HBaseSerDe.HBASE_COLUMNS_MAPPING);
        boolean doColumnRegexMatching = jobConf.getBoolean(HBaseSerDe.HBASE_COLUMNS_REGEX_MATCHING, true);

        try {
            if (hbaseColumnsMapping == null) {
                throw new IOException(HBaseSerDe.HBASE_COLUMNS_MAPPING + " required for HBase Table.");
            }

            ColumnMappings columnMappings = null;
            try {
                columnMappings = HBaseSerDe.parseColumnsMapping(hbaseColumnsMapping, doColumnRegexMatching);
            } catch (SerDeException e) {
                throw new IOException(e);
            }

            int iKey = columnMappings.getKeyIndex();
            int iTimestamp = columnMappings.getTimestampIndex();
            ColumnMapping keyMapping = columnMappings.getKeyMapping();

            // Take filter pushdown into account while calculating splits; this
            // allows us to prune off regions immediately.  Note that although
            // the Javadoc for the superclass getSplits says that it returns one
            // split per region, the implementation actually takes the scan
            // definition into account and excludes regions which don't satisfy
            // the start/stop row conditions (HBASE-1829).
            Scan scan = createFilterScan(jobConf, iKey, iTimestamp, HiveHBaseInputFormatUtil
                    .getStorageFormatOfKey(keyMapping.mappingSpec,
                            jobConf.get(HBaseSerDe.HBASE_TABLE_DEFAULT_STORAGE_TYPE, "string")));

            // The list of families that have been added to the scan
            List<String> addedFamilies = new ArrayList<String>();

            // REVIEW:  are we supposed to be applying the getReadColumnIDs
            // same as in getRecordReader?
            for (ColumnMapping colMap : columnMappings) {
                if (colMap.hbaseRowKey || colMap.hbaseTimestamp) {
                    continue;
                }

                if (colMap.qualifierName == null) {
                    scan.addFamily(colMap.familyNameBytes);
                    addedFamilies.add(colMap.familyName);
                } else {
                    if (!addedFamilies.contains(colMap.familyName)) {
                        // add the column only if the family has not already been added
                        scan.addColumn(colMap.familyNameBytes, colMap.qualifierNameBytes);
                    }
                }
            }
            setScan(scan);

            Job job = new Job(jobConf);
            JobContext jobContext = ShimLoader.getHadoopShims().newJobContext(job);
            Path[] tablePaths = FileInputFormat.getInputPaths(jobContext);

            List<org.apache.hadoop.mapreduce.InputSplit> splits = super.getSplits(jobContext);
            InputSplit[] results = new InputSplit[splits.size()];

            for (int i = 0; i < splits.size(); i++) {
                results[i] = new HBaseSplit((TableSplit) splits.get(i), tablePaths[0]);
            }

            return results;
        } finally {
            closeTable();
            conn.close();
        }
    }

    @Override protected void finalize() throws Throwable {
        try {
            closeTable();
        } finally {
            super.finalize();
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.util.Properties;

        import org.apache.hadoop.hbase.TableName;
        import org.apache.hadoop.hbase.client.BufferedMutator;
        import org.apache.hadoop.hbase.client.Connection;
        import org.apache.hadoop.hbase.client.ConnectionFactory;
        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hive.ql.exec.FileSinkOperator;
        import org.apache.hadoop.hive.ql.io.HiveOutputFormat;
        import org.apache.hadoop.io.Writable;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.fs.FileSystem;
        import org.apache.hadoop.hbase.HBaseConfiguration;
        import org.apache.hadoop.hbase.client.Durability;
        import org.apache.hadoop.hbase.client.Put;
        import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
        import org.apache.hadoop.hbase.mapred.TableMapReduceUtil;
        import org.apache.hadoop.hbase.mapreduce.TableOutputCommitter;
        import org.apache.hadoop.hbase.mapreduce.TableOutputFormat;
        import org.apache.hadoop.hive.conf.HiveConf;
        import org.apache.hadoop.hive.shims.ShimLoader;
        import org.apache.hadoop.mapred.JobConf;
        import org.apache.hadoop.mapred.Reporter;
        import org.apache.hadoop.mapreduce.Job;
        import org.apache.hadoop.mapreduce.JobContext;
        import org.apache.hadoop.mapreduce.OutputCommitter;
        import org.apache.hadoop.mapreduce.TaskAttemptContext;
        import org.apache.hadoop.util.Progressable;
        import org.apache.hadoop.security.UserGroupInformation;

/**
 * HiveHBaseTableOutputFormat implements HiveOutputFormat for HBase tables.
 */
public class HiveHBaseTableOutputFormat extends
        TableOutputFormat<ImmutableBytesWritable> implements
        HiveOutputFormat<ImmutableBytesWritable, Object> {

    static final Logger LOG = LoggerFactory.getLogger(HiveHBaseTableOutputFormat.class);

    @Override
    public void checkOutputSpecs(FileSystem fs, JobConf jc) throws IOException {

        //obtain delegation tokens for the job
        if (UserGroupInformation.getCurrentUser().hasKerberosCredentials()) {
            TableMapReduceUtil.initCredentials(jc);
        }

        String hbaseTableName = jc.get(HBaseSerDe.HBASE_TABLE_NAME);
        jc.set(TableOutputFormat.OUTPUT_TABLE, hbaseTableName);
        Job job = new Job(jc);
        JobContext jobContext = ShimLoader.getHadoopShims().newJobContext(job);

        try {
            checkOutputSpecs(jobContext);
        } catch (InterruptedException e) {
            throw new IOException(e);
        }
    }

    @Override
    public
    org.apache.hadoop.mapred.RecordWriter<ImmutableBytesWritable, Object>
    getRecordWriter(
            FileSystem fileSystem,
            JobConf jobConf,
            String name,
            Progressable progressable) throws IOException {
        return getMyRecordWriter(jobConf);
    }

    @Override
    public OutputCommitter getOutputCommitter(TaskAttemptContext context) throws IOException,
            InterruptedException {
        return new TableOutputCommitter();
    }

    @Override
    public FileSinkOperator.RecordWriter getHiveRecordWriter(
            JobConf jobConf, Path finalOutPath, Class<? extends Writable> valueClass, boolean isCompressed,
            Properties tableProperties, Progressable progress) throws IOException {
        return getMyRecordWriter(jobConf);
    }

    private MyRecordWriter getMyRecordWriter(JobConf jobConf) throws IOException {
        String hbaseTableName = jobConf.get(HBaseSerDe.HBASE_TABLE_NAME);
        jobConf.set(TableOutputFormat.OUTPUT_TABLE, hbaseTableName);
        final boolean walEnabled = HiveConf.getBoolVar(
                jobConf, HiveConf.ConfVars.HIVE_HBASE_WAL_ENABLED);
        final Connection conn = ConnectionFactory.createConnection(HBaseConfiguration.create(jobConf));
        final BufferedMutator table = conn.getBufferedMutator(TableName.valueOf(hbaseTableName));
        return new MyRecordWriter(table, conn, walEnabled);
    }

    private static class MyRecordWriter
            implements org.apache.hadoop.mapred.RecordWriter<ImmutableBytesWritable, Object>,
            org.apache.hadoop.hive.ql.exec.FileSinkOperator.RecordWriter {
        private final BufferedMutator m_table;
        private final boolean m_walEnabled;
        private final Connection m_connection;

        public MyRecordWriter(BufferedMutator table, Connection connection, boolean walEnabled) {
            m_table = table;
            m_walEnabled = walEnabled;
            m_connection = connection;
        }

        public void close(Reporter reporter) throws IOException {
            m_table.close();
        }

        public void write(ImmutableBytesWritable key,
                          Object value) throws IOException {
            Put put;
            if (value instanceof Put){
                put = (Put)value;
            } else if (value instanceof PutWritable) {
                put = new Put(((PutWritable)value).getPut());
            } else {
                throw new IllegalArgumentException("Illegal Argument " + (value == null ? "null" : value.getClass().getName()));
            }
            if(m_walEnabled) {
                put.setDurability(Durability.SYNC_WAL);
            } else {
                put.setDurability(Durability.SKIP_WAL);
            }
            m_table.mutate(put);
        }

        @Override
        protected void finalize() throws Throwable {
            try {
                m_table.close();
                m_connection.close();
            } finally {
                super.finalize();
            }
        }

        @Override
        public void write(Writable w) throws IOException {
            write(null, w);
        }

        @Override
        public void close(boolean abort) throws IOException {
            close(null);
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

package org.apache.hadoop.hive.hbase;

        import org.apache.commons.codec.binary.Base64;
        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hbase.client.Result;
        import org.apache.hadoop.hbase.client.Scan;
        import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
        import org.apache.hadoop.hbase.mapred.TableInputFormat;
        import org.apache.hadoop.hbase.mapred.TableSnapshotInputFormat;
        import org.apache.hadoop.hbase.protobuf.ProtobufUtil;
        import org.apache.hadoop.hbase.protobuf.generated.ClientProtos;
        import org.apache.hadoop.hbase.util.Bytes;
        import org.apache.hadoop.mapred.FileInputFormat;
        import org.apache.hadoop.mapred.InputFormat;
        import org.apache.hadoop.mapred.InputSplit;
        import org.apache.hadoop.mapred.JobConf;
        import org.apache.hadoop.mapred.RecordReader;
        import org.apache.hadoop.mapred.Reporter;

        import java.io.IOException;
        import java.util.List;

public class HiveHBaseTableSnapshotInputFormat
        implements InputFormat<ImmutableBytesWritable, ResultWritable> {

    TableSnapshotInputFormat delegate = new TableSnapshotInputFormat();

    private static void setColumns(JobConf job) throws IOException {
        Scan scan = HiveHBaseInputFormatUtil.getScan(job);
        job.set(org.apache.hadoop.hbase.mapreduce.TableInputFormat.SCAN,
                convertScanToString(scan));
    }

    // TODO: Once HBASE-11163 is completed, use that API, or switch to
    // using mapreduce version of the APIs. rather than mapred
    // Copied from HBase's TableMapreduceUtil since it is not public API
    static String convertScanToString(Scan scan) throws IOException {
        ClientProtos.Scan proto = ProtobufUtil.toScan(scan);
        return Base64.encodeBase64String(proto.toByteArray());
    }

    @Override
    public InputSplit[] getSplits(JobConf job, int numSplits) throws IOException {
        setColumns(job);

        // hive depends on FileSplits, so wrap in HBaseSplit
        Path[] tablePaths = FileInputFormat.getInputPaths(job);

        InputSplit [] results = delegate.getSplits(job, numSplits);
        for (int i = 0; i < results.length; i++) {
            results[i] = new HBaseSplit(results[i], tablePaths[0]);
        }

        return results;
    }

    @Override
    public RecordReader<ImmutableBytesWritable, ResultWritable> getRecordReader(
            InputSplit split, JobConf job, Reporter reporter) throws IOException {
        setColumns(job);
        final RecordReader<ImmutableBytesWritable, Result> rr =
                delegate.getRecordReader(((HBaseSplit) split).getSnapshotSplit(), job, reporter);

        return new RecordReader<ImmutableBytesWritable, ResultWritable>() {
            @Override
            public boolean next(ImmutableBytesWritable key, ResultWritable value) throws IOException {
                return rr.next(key, value.getResult());
            }

            @Override
            public ImmutableBytesWritable createKey() {
                return rr.createKey();
            }

            @Override
            public ResultWritable createValue() {
                return new ResultWritable(rr.createValue());
            }

            @Override
            public long getPos() throws IOException {
                return rr.getPos();
            }

            @Override
            public void close() throws IOException {
                rr.close();
            }

            @Override
            public float getProgress() throws IOException {
                return rr.getProgress();
            }
        };
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

package org.apache.hadoop.hive.hbase;

        import java.io.IOException;
        import java.io.InterruptedIOException;
        import java.util.Collections;
        import java.util.List;
        import java.util.Map;
        import java.util.Properties;
        import java.util.SortedMap;
        import java.util.TreeMap;

        import org.apache.commons.lang.NotImplementedException;
        import org.slf4j.Logger;
        import org.slf4j.LoggerFactory;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.fs.FileStatus;
        import org.apache.hadoop.fs.FileSystem;
        import org.apache.hadoop.fs.Path;
        import org.apache.hadoop.hbase.Cell;
        import org.apache.hadoop.hbase.CellComparatorImpl;
        import org.apache.hadoop.hbase.KeyValue;
        import org.apache.hadoop.hbase.KeyValueUtil;
        import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
        import org.apache.hadoop.hbase.mapreduce.HFileOutputFormat2;
        import org.apache.hadoop.hbase.util.Bytes;
        import org.apache.hadoop.hive.common.FileUtils;
        import org.apache.hadoop.hive.metastore.api.hive_metastoreConstants;
        import org.apache.hadoop.hive.ql.exec.FileSinkOperator.RecordWriter;
        import org.apache.hadoop.hive.ql.io.HiveOutputFormat;
        import org.apache.hadoop.hive.shims.ShimLoader;
        import org.apache.hadoop.io.Text;
        import org.apache.hadoop.io.Writable;
        import org.apache.hadoop.mapred.JobConf;
        import org.apache.hadoop.mapreduce.Job;
        import org.apache.hadoop.mapreduce.JobContext;
        import org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter;
        import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
        import org.apache.hadoop.util.Progressable;

/**
 * HiveHFileOutputFormat implements HiveOutputFormat for HFile bulk
 * loading.  Until HBASE-1861 is implemented, it can only be used
 * for loading a table with a single column family.
 */
public class HiveHFileOutputFormat extends
        HFileOutputFormat2 implements
        HiveOutputFormat<ImmutableBytesWritable, Cell> {

    public static final String HFILE_FAMILY_PATH = "hfile.family.path";
    public static final String OUTPUT_TABLE_NAME_CONF_KEY =
            "hbase.mapreduce.hfileoutputformat.table.name";
    static final Logger LOG = LoggerFactory.getLogger(HiveHFileOutputFormat.class.getName());

    private
    org.apache.hadoop.mapreduce.RecordWriter<ImmutableBytesWritable, Cell>
    getFileWriter(org.apache.hadoop.mapreduce.TaskAttemptContext tac)
            throws IOException {
        try {
            return super.getRecordWriter(tac);
        } catch (InterruptedException ex) {
            throw new IOException(ex);
        }
    }

    /**
     * Retrieve the family path, first check the JobConf, then the table properties.
     * @return the family path or null if not specified.
     */
    public static String getFamilyPath(Configuration jc, Properties tableProps) {
        return jc.get(HFILE_FAMILY_PATH, tableProps.getProperty(HFILE_FAMILY_PATH));
    }

    @Override
    public RecordWriter getHiveRecordWriter(
            final JobConf jc,
            final Path finalOutPath,
            Class<? extends Writable> valueClass,
            boolean isCompressed,
            Properties tableProperties,
            final Progressable progressable) throws IOException {

        String hbaseTableName = jc.get(HBaseSerDe.HBASE_TABLE_NAME);
        if (hbaseTableName == null) {
            hbaseTableName = tableProperties.getProperty(hive_metastoreConstants.META_TABLE_NAME);
            hbaseTableName = hbaseTableName.toLowerCase();
            if (hbaseTableName.startsWith(HBaseStorageHandler.DEFAULT_PREFIX)) {
                hbaseTableName = hbaseTableName.substring(HBaseStorageHandler.DEFAULT_PREFIX.length());
            }
        }
        jc.set(OUTPUT_TABLE_NAME_CONF_KEY, hbaseTableName);

        // Read configuration for the target path, first from jobconf, then from table properties
        String hfilePath = getFamilyPath(jc, tableProperties);
        if (hfilePath == null) {
            throw new RuntimeException(
                    "Please set " + HFILE_FAMILY_PATH + " to target location for HFiles");
        }

        // Target path's last component is also the column family name.
        final Path columnFamilyPath = new Path(hfilePath);
        final String columnFamilyName = columnFamilyPath.getName();
        final byte [] columnFamilyNameBytes = Bytes.toBytes(columnFamilyName);
        final Job job = new Job(jc);
        setCompressOutput(job, isCompressed);
        setOutputPath(job, finalOutPath);

        // Create the HFile writer
        final org.apache.hadoop.mapreduce.TaskAttemptContext tac =
                ShimLoader.getHadoopShims().newTaskAttemptContext(
                        job.getConfiguration(), progressable);

        final Path outputdir = FileOutputFormat.getOutputPath(tac);
        final Path taskAttemptOutputdir = new FileOutputCommitter(outputdir, tac).getWorkPath();
        final org.apache.hadoop.mapreduce.RecordWriter<
                ImmutableBytesWritable, Cell> fileWriter = getFileWriter(tac);

        // Individual columns are going to be pivoted to HBase cells,
        // and for each row, they need to be written out in order
        // of column name, so sort the column names now, creating a
        // mapping to their column position.  However, the first
        // column is interpreted as the row key.
        String columnList = tableProperties.getProperty("columns");
        String [] columnArray = columnList.split(",");
        final SortedMap<byte [], Integer> columnMap =
                new TreeMap<byte [], Integer>(Bytes.BYTES_COMPARATOR);
        int i = 0;
        for (String columnName : columnArray) {
            if (i != 0) {
                columnMap.put(Bytes.toBytes(columnName), i);
            }
            ++i;
        }

        return new RecordWriter() {

            @Override
            public void close(boolean abort) throws IOException {
                try {
                    fileWriter.close(null);
                    if (abort) {
                        return;
                    }
                    // Move the hfiles file(s) from the task output directory to the
                    // location specified by the user.
                    FileSystem fs = outputdir.getFileSystem(jc);
                    fs.mkdirs(columnFamilyPath);
                    Path srcDir = taskAttemptOutputdir;
                    for (;;) {
                        FileStatus [] files = fs.listStatus(srcDir, FileUtils.STAGING_DIR_PATH_FILTER);
                        if ((files == null) || (files.length == 0)) {
                            throw new IOException("No family directories found in " + srcDir);
                        }
                        if (files.length != 1) {
                            throw new IOException("Multiple family directories found in " + srcDir);
                        }
                        srcDir = files[0].getPath();
                        if (srcDir.getName().equals(columnFamilyName)) {
                            break;
                        }
                        if (files[0].isFile()) {
                            throw new IOException("No family directories found in " + taskAttemptOutputdir + ". "
                                    + "The last component in hfile path should match column family name "
                                    + columnFamilyName);
                        }
                    }
                    for (FileStatus regionFile : fs.listStatus(srcDir, FileUtils.STAGING_DIR_PATH_FILTER)) {
                        fs.rename(
                                regionFile.getPath(),
                                new Path(
                                        columnFamilyPath,
                                        regionFile.getPath().getName()));
                    }
                } catch (InterruptedException ex) {
                    throw new IOException(ex);
                }
            }

            private void writeText(Text text) throws IOException {
                // Decompose the incoming text row into fields.
                String s = text.toString();
                String [] fields = s.split("\u0001");
                assert(fields.length <= (columnMap.size() + 1));
                // First field is the row key.
                byte [] rowKeyBytes = Bytes.toBytes(fields[0]);
                // Remaining fields are cells addressed by column name within row.
                for (Map.Entry<byte [], Integer> entry : columnMap.entrySet()) {
                    byte [] columnNameBytes = entry.getKey();
                    int iColumn = entry.getValue();
                    String val;
                    if (iColumn >= fields.length) {
                        // trailing blank field
                        val = "";
                    } else {
                        val = fields[iColumn];
                        if ("\\N".equals(val)) {
                            // omit nulls
                            continue;
                        }
                    }
                    byte [] valBytes = Bytes.toBytes(val);
                    KeyValue kv = new KeyValue(
                            rowKeyBytes,
                            columnFamilyNameBytes,
                            columnNameBytes,
                            valBytes);
                    try {
                        fileWriter.write(null, kv);
                    } catch (IOException e) {
                        LOG.error("Failed while writing row: " + s);
                        throw e;
                    } catch (InterruptedException ex) {
                        throw new IOException(ex);
                    }
                }
            }

            private void writePut(PutWritable put) throws IOException {
                ImmutableBytesWritable row = new ImmutableBytesWritable(put.getPut().getRow());
                SortedMap<byte[], List<Cell>> cells = put.getPut().getFamilyCellMap();
                for (Map.Entry<byte[], List<Cell>> entry : cells.entrySet()) {
                    Collections.sort(entry.getValue(), new CellComparatorImpl());
                    for (Cell c : entry.getValue()) {
                        try {
                            fileWriter.write(row, KeyValueUtil.copyToNewKeyValue(c));
                        } catch (InterruptedException e) {
                            throw (InterruptedIOException) new InterruptedIOException().initCause(e);
                        }
                    }
                }
            }

            @Override
            public void write(Writable w) throws IOException {
                if (w instanceof Text) {
                    writeText((Text) w);
                } else if (w instanceof PutWritable) {
                    writePut((PutWritable) w);
                } else {
                    throw new IOException("Unexpected writable " + w);
                }
            }
        };
    }

    @Override
    public void checkOutputSpecs(FileSystem ignored, JobConf jc) throws IOException {
        //delegate to the new api
        Job job = new Job(jc);
        JobContext jobContext = ShimLoader.getHadoopShims().newJobContext(job);

        checkOutputSpecs(jobContext);
    }

    @Override
    public org.apache.hadoop.mapred.RecordWriter<ImmutableBytesWritable, Cell> getRecordWriter(
            FileSystem ignored, JobConf job, String name, Progressable progress) throws IOException {
        throw new NotImplementedException("This will not be invoked");
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

package org.apache.hadoop.hive.hbase;

        import java.util.LinkedHashMap;
        import java.util.List;
        import java.util.Map;
        import java.util.Map.Entry;
        import java.util.NavigableMap;

        import org.apache.hadoop.hbase.client.Result;
        import org.apache.hadoop.hbase.util.Bytes;
        import org.apache.hadoop.hive.serde2.lazy.ByteArrayRef;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyMap;
        import org.apache.hadoop.hive.serde2.lazy.LazyObject;
        import org.apache.hadoop.hive.serde2.lazy.LazyPrimitive;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazyMapObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector;
        import org.apache.hadoop.io.Writable;

/**
 * LazyHBaseCellMap refines LazyMap with HBase column mapping.
 */
public class LazyHBaseCellMap extends LazyMap {

    private Result result;
    private byte [] columnFamilyBytes;
    private byte[] qualPrefix;
    private List<Boolean> binaryStorage;
    private boolean hideQualPrefix;

    /**
     * Construct a LazyCellMap object with the ObjectInspector.
     * @param oi
     */
    public LazyHBaseCellMap(LazyMapObjectInspector oi) {
        super(oi);
    }

    public void init(
            Result r,
            byte[] columnFamilyBytes,
            List<Boolean> binaryStorage) {

        init(r, columnFamilyBytes, binaryStorage, null);
    }

    public void init(
            Result r,
            byte [] columnFamilyBytes,
            List<Boolean> binaryStorage, byte[] qualPrefix) {
        init(r, columnFamilyBytes, binaryStorage, qualPrefix, false);
    }

    public void init(
            Result r,
            byte [] columnFamilyBytes,
            List<Boolean> binaryStorage, byte[] qualPrefix, boolean hideQualPrefix) {
        this.isNull = false;
        this.result = r;
        this.columnFamilyBytes = columnFamilyBytes;
        this.binaryStorage = binaryStorage;
        this.qualPrefix = qualPrefix;
        this.hideQualPrefix = hideQualPrefix;
        setParsed(false);
    }

    private void parse() {
        if (cachedMap == null) {
            cachedMap = new LinkedHashMap<Object, Object>();
        } else {
            cachedMap.clear();
        }

        NavigableMap<byte [], byte []> familyMap = result.getFamilyMap(columnFamilyBytes);

        if (familyMap != null) {

            for (Entry<byte [], byte []> e : familyMap.entrySet()) {
                // null values and values of zero length are not added to the cachedMap
                if (e.getValue() == null || e.getValue().length == 0) {
                    continue;
                }

                if (qualPrefix != null && !Bytes.startsWith(e.getKey(), qualPrefix)) {
                    // since we were provided a qualifier prefix, only accept qualifiers that start with this
                    // prefix
                    continue;
                }

                LazyMapObjectInspector lazyMoi = getInspector();

                // Keys are always primitive
                LazyPrimitive<? extends ObjectInspector, ? extends Writable> key =
                        LazyFactory.createLazyPrimitiveClass(
                                (PrimitiveObjectInspector) lazyMoi.getMapKeyObjectInspector(),
                                binaryStorage.get(0));

                ByteArrayRef keyRef = new ByteArrayRef();
                if (qualPrefix!=null && hideQualPrefix){
                    keyRef.setData(Bytes.tail(e.getKey(), e.getKey().length-qualPrefix.length)); //cut prefix from hive's map key
                }else{
                    keyRef.setData(e.getKey()); //for non-prefix maps
                }
                key.init(keyRef, 0, keyRef.getData().length);

                // Value
                LazyObject<?> value =
                        LazyFactory.createLazyObject(lazyMoi.getMapValueObjectInspector(),
                                binaryStorage.get(1));

                byte[] bytes = e.getValue();

                if (isNull(oi.getNullSequence(), bytes, 0, bytes.length)) {
                    value.setNull();
                } else {
                    ByteArrayRef valueRef = new ByteArrayRef();
                    valueRef.setData(bytes);
                    value.init(valueRef, 0, valueRef.getData().length);
                }

                // Put the key/value into the map
                cachedMap.put(key.getObject(), value.getObject());
            }
        }

        setParsed(true);
    }


    /**
     * Get the value in the map for the given key.
     *
     * @param key
     * @return
     */
    @Override
    public Object getMapValueElement(Object key) {
        if (!getParsed()) {
            parse();
        }

        for (Map.Entry<Object, Object> entry : cachedMap.entrySet()) {
            LazyPrimitive<?, ?> lazyKeyI = (LazyPrimitive<?, ?>) entry.getKey();
            // getWritableObject() will convert LazyPrimitive to actual primitive
            // writable objects.
            Object keyI = lazyKeyI.getWritableObject();
            if (keyI == null) {
                continue;
            }
            if (keyI.equals(key)) {
                // Got a match, return the value
                Object _value = entry.getValue();

                // If the given value is a type of LazyObject, then only try and convert it to that form.
                // Else return it as it is.
                if (_value instanceof LazyObject) {
                    LazyObject<?> v = (LazyObject<?>) entry.getValue();
                    return v == null ? v : v.getObject();
                } else {
                    return _value;
                }
            }
        }

        return null;
    }

    @Override
    public Map<Object, Object> getMap() {
        if (!getParsed()) {
            parse();
        }
        return cachedMap;
    }

    @Override
    public int getMapSize() {
        if (!getParsed()) {
            parse();
        }
        return cachedMap.size();
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

package org.apache.hadoop.hive.hbase;

        import java.util.ArrayList;
        import java.util.Arrays;
        import java.util.List;

        import org.apache.hadoop.hbase.client.Result;
        import org.apache.hadoop.hive.common.type.Timestamp;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.hbase.struct.HBaseValueFactory;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.ByteArrayRef;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyLong;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.lazy.LazyStruct;
        import org.apache.hadoop.hive.serde2.lazy.LazyTimestamp;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazySimpleStructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;

        import com.google.common.annotations.VisibleForTesting;

/**
 * LazyObject for storing an HBase row.  The field of an HBase row can be
 * primitive or non-primitive.
 */
public class LazyHBaseRow extends LazyStruct {

    /**
     * The HBase columns mapping of the row.
     */
    private Result result;
    private ArrayList<Object> cachedList;

    private final HBaseKeyFactory keyFactory;
    private final List<HBaseValueFactory> valueFactories;
    private final ColumnMapping[] columnsMapping;

    @VisibleForTesting
    LazyHBaseRow(LazySimpleStructObjectInspector oi, ColumnMappings columnMappings) {
        super(oi);
        this.keyFactory = DefaultHBaseKeyFactory.forTest(null, columnMappings);
        this.valueFactories = null;
        this.columnsMapping = columnMappings.getColumnsMapping();
    }

    /**
     * Construct a LazyHBaseRow object with the ObjectInspector.
     */
    public LazyHBaseRow(LazySimpleStructObjectInspector oi, HBaseSerDeParameters serdeParams) {
        super(oi);
        this.keyFactory = serdeParams.getKeyFactory();
        this.valueFactories = serdeParams.getValueFactories();
        this.columnsMapping = serdeParams.getColumnMappings().getColumnsMapping();
    }

    /**
     * Set the HBase row data(a Result writable) for this LazyStruct.
     * @see LazyHBaseRow#init(org.apache.hadoop.hbase.client.Result)
     */
    public void init(Result r) {
        this.result = r;
        setParsed(false);
    }

    @Override
    protected LazyObjectBase createLazyField(final int fieldID, final StructField fieldRef)
            throws SerDeException {
        if (columnsMapping[fieldID].hbaseRowKey) {
            return keyFactory.createKey(fieldRef.getFieldObjectInspector());
        }
        if (columnsMapping[fieldID].hbaseTimestamp) {
            return LazyFactory.createLazyObject(fieldRef.getFieldObjectInspector());
        }

        if (valueFactories != null) {
            return valueFactories.get(fieldID).createValueObject(fieldRef.getFieldObjectInspector());
        }

        // fallback to default
        return HBaseSerDeHelper.createLazyField(columnsMapping, fieldID,
                fieldRef.getFieldObjectInspector());
    }

    /**
     * Get one field out of the HBase row.
     *
     * If the field is a primitive field, return the actual object.
     * Otherwise return the LazyObject.  This is because PrimitiveObjectInspector
     * does not have control over the object used by the user - the user simply
     * directly uses the Object instead of going through
     * Object PrimitiveObjectInspector.get(Object).
     *
     * @param fieldID  The field ID
     * @return         The field as a LazyObject
     */
    @Override
    public Object getField(int fieldID) {
        initFields();
        return uncheckedGetField(fieldID);
    }

    private void initFields() {
        if (getFields() == null) {
            initLazyFields(oi.getAllStructFieldRefs());
        }
        if (!getParsed()) {
            Arrays.fill(getFieldInited(), false);
            setParsed(true);
        }
    }

    /**
     * Get the field out of the row without checking whether parsing is needed.
     * This is called by both getField and getFieldsAsList.
     * @param fieldID  The id of the field starting from 0.
     * @return  The value of the field
     */
    private Object uncheckedGetField(int fieldID) {

        LazyObjectBase[] fields = getFields();
        boolean [] fieldsInited = getFieldInited();

        if (!fieldsInited[fieldID]) {
            fieldsInited[fieldID] = true;

            ColumnMapping colMap = columnsMapping[fieldID];

            if (!colMap.hbaseRowKey && !colMap.hbaseTimestamp && colMap.qualifierName == null) {
                // it is a column family
                // primitive type for Map<Key, Value> can be stored in binary format. Pass in the
                // qualifier prefix to cherry pick the qualifiers that match the prefix instead of picking
                // up everything
                ((LazyHBaseCellMap) fields[fieldID]).init(
                        result, colMap.familyNameBytes, colMap.binaryStorage, colMap.qualifierPrefixBytes, colMap.isDoPrefixCut());
                return fields[fieldID].getObject();
            }

            if (colMap.hbaseTimestamp) {
                // Get the latest timestamp of all the cells as the row timestamp
                long timestamp = result.rawCells()[0].getTimestamp(); // from hbase-0.96.0
                for (int i = 1; i < result.rawCells().length; i++) {
                    timestamp = Math.max(timestamp, result.rawCells()[i].getTimestamp());
                }
                LazyObjectBase lz = fields[fieldID];
                if (lz instanceof LazyTimestamp) {
                    ((LazyTimestamp) lz).getWritableObject().set(
                            Timestamp.ofEpochMilli(timestamp));
                } else {
                    ((LazyLong) lz).getWritableObject().set(timestamp);
                }
                return lz.getObject();
            }

            byte[] bytes;
            if (colMap.hbaseRowKey) {
                bytes = result.getRow();
            } else {
                // it is a column i.e. a column-family with column-qualifier
                bytes = result.getValue(colMap.familyNameBytes, colMap.qualifierNameBytes);
            }
            if (bytes == null || isNull(oi.getNullSequence(), bytes, 0, bytes.length)) {
                fields[fieldID].setNull();
            } else {
                ByteArrayRef ref = new ByteArrayRef();
                ref.setData(bytes);
                fields[fieldID].init(ref, 0, bytes.length);
            }
        }

        return fields[fieldID].getObject();
    }

    /**
     * Get the values of the fields as an ArrayList.
     * @return The values of the fields as an ArrayList.
     */
    @Override
    public ArrayList<Object> getFieldsAsList() {
        initFields();
        if (cachedList == null) {
            cachedList = new ArrayList<Object>();
        } else {
            cachedList.clear();
        }
        for (int i = 0; i < getFields().length; i++) {
            cachedList.add(uncheckedGetField(i));
        }
        return cachedList;
    }

    @Override
    public Object getObject() {
        return this;
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

/** Implements an HBase storage handler for Hive. */
package org.apache.hadoop.hive.hbase;

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

        package org.apache.hadoop.hive.hbase;
        import java.io.DataInput;
        import java.io.DataOutput;
        import java.io.IOException;

        import org.apache.hadoop.hbase.Cell;
        import org.apache.hadoop.hbase.CellScanner;
        import org.apache.hadoop.hbase.CellUtil;
        import org.apache.hadoop.hbase.KeyValue;
        import org.apache.hadoop.hbase.KeyValueUtil;
        import org.apache.hadoop.hbase.client.Put;
        import org.apache.hadoop.hbase.protobuf.ProtobufUtil;
        import org.apache.hadoop.hbase.protobuf.generated.ClientProtos;
        import org.apache.hadoop.hbase.protobuf.generated.ClientProtos.MutationProto.MutationType;
        import org.apache.hadoop.io.Writable;

public class PutWritable implements Writable {

    private Put put;

    public PutWritable() {

    }
    public PutWritable(Put put) {
        this.put = put;
    }
    public Put getPut() {
        return put;
    }
    @Override
    public void readFields(final DataInput in)
            throws IOException {
        ClientProtos.MutationProto putProto = ClientProtos.MutationProto.parseDelimitedFrom(DataInputInputStream.from(in));
        int size = in.readInt();
        if(size < 0) {
            throw new IOException("Invalid size " + size);
        }
        Cell[] kvs = new Cell[size];
        for (int i = 0; i < kvs.length; i++) {
            kvs[i] = KeyValue.create(in);
        }
        put = ProtobufUtil.toPut(putProto, CellUtil.createCellScanner(kvs));
    }
    @Override
    public void write(final DataOutput out)
            throws IOException {
        ProtobufUtil.toMutationNoData(MutationType.PUT, put).writeDelimitedTo(DataOutputOutputStream.from(out));
        out.writeInt(put.size());
        CellScanner scanner = put.cellScanner();
        while(scanner.advance()) {
            KeyValue kv = KeyValueUtil.ensureKeyValue(scanner.current());
            KeyValue.write(kv, out);
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

package org.apache.hadoop.hive.hbase;
        import java.io.DataInput;
        import java.io.DataOutput;
        import java.io.IOException;

        import org.apache.hadoop.hbase.Cell;
        import org.apache.hadoop.hbase.CellUtil;
        import org.apache.hadoop.hbase.KeyValue;
        import org.apache.hadoop.hbase.KeyValueUtil;
        import org.apache.hadoop.hbase.client.Result;
        import org.apache.hadoop.hbase.protobuf.ProtobufUtil;
        import org.apache.hadoop.hbase.protobuf.generated.ClientProtos;
        import org.apache.hadoop.io.Writable;

public class ResultWritable implements Writable {

    private Result result;

    public ResultWritable() {

    }
    public ResultWritable(Result result) {
        this.result = result;
    }

    public Result getResult() {
        return result;
    }
    public void setResult(Result result) {
        this.result = result;
    }
    @Override
    public void readFields(final DataInput in)
            throws IOException {
        ClientProtos.Result protosResult = ClientProtos.Result.parseDelimitedFrom(DataInputInputStream.from(in));
        int size = in.readInt();
        if(size < 0) {
            throw new IOException("Invalid size " + size);
        }
        Cell[] kvs = new Cell[size];
        for (int i = 0; i < kvs.length; i++) {
            kvs[i] = KeyValue.create(in);
        }
        result = ProtobufUtil.toResult(protosResult, CellUtil.createCellScanner(kvs));
    }
    @Override
    public void write(final DataOutput out)
            throws IOException {
        ProtobufUtil.toResultNoData(result).writeDelimitedTo(DataOutputOutputStream.from(out));
        out.writeInt(result.size());
        for(Cell cell : result.listCells()) {
            KeyValue kv = KeyValueUtil.ensureKeyValue(cell);
            KeyValue.write(kv, out);
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
package org.apache.hadoop.hive.hbase.struct;

        import java.io.IOException;
        import java.util.Properties;

        import org.apache.avro.Schema;
        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hive.hbase.HBaseSerDeParameters;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.avro.AvroLazyObjectInspector;
        import org.apache.hadoop.hive.serde2.avro.AvroSchemaRetriever;
        import org.apache.hadoop.hive.serde2.avro.AvroSerdeUtils;
        import org.apache.hadoop.hive.serde2.avro.AvroSerdeUtils.AvroTableProperties;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.objectinspector.ListObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.MapObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory.ObjectInspectorOptions;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;

/**
 * Avro specific implementation of the {@link HBaseValueFactory}
 * */
public class AvroHBaseValueFactory extends DefaultHBaseValueFactory {

    private AvroSchemaRetriever avroSchemaRetriever;
    private Schema schema;

    /**
     * Constructor
     *
     * @param schema the associated {@link Schema schema}
     * */
    public AvroHBaseValueFactory(int fieldID, Schema schema) {
        super(fieldID);
        this.schema = schema;
    }

    @Override
    public void init(HBaseSerDeParameters hbaseParams, Configuration conf, Properties properties)
            throws SerDeException {
        super.init(hbaseParams, conf, properties);
        String avroSchemaRetClass = properties.getProperty(AvroTableProperties.SCHEMA_RETRIEVER.getPropName());

        if (avroSchemaRetClass != null) {
            Class<?> avroSchemaRetrieverClass = null;
            try {
                avroSchemaRetrieverClass = conf.getClassByName(avroSchemaRetClass);
            } catch (ClassNotFoundException e) {
                throw new SerDeException(e);
            }

            initAvroSchemaRetriever(avroSchemaRetrieverClass, conf, properties);
        }
    }

    @Override
    public ObjectInspector createValueObjectInspector(TypeInfo type) throws SerDeException {
        ObjectInspector oi =
                LazyFactory.createLazyObjectInspector(type, 1, serdeParams, ObjectInspectorOptions.AVRO);

        // initialize the object inspectors
        initInternalObjectInspectors(oi);

        return oi;
    }

    @Override
    public byte[] serializeValue(Object object, StructField field) throws IOException {
        // Explicit avro serialization not supported yet. Revert to default
        return super.serializeValue(object, field);
    }

    /**
     * Initialize the instance for {@link AvroSchemaRetriever}
     *
     * @throws SerDeException
     * */
    private void initAvroSchemaRetriever(Class<?> avroSchemaRetrieverClass, Configuration conf,
                                         Properties tbl) throws SerDeException {

        try {
            avroSchemaRetriever = (AvroSchemaRetriever) avroSchemaRetrieverClass.getDeclaredConstructor(
                    Configuration.class, Properties.class).newInstance(
                    conf, tbl);
        } catch (NoSuchMethodException e) {
            // the constructor wasn't defined in the implementation class. Flag error
            throw new SerDeException("Constructor not defined in schema retriever class [" + avroSchemaRetrieverClass.getName() + "]", e);
        } catch (Exception e) {
            throw new SerDeException(e);
        }
    }

    /**
     * Initialize the internal object inspectors
     * */
    private void initInternalObjectInspectors(ObjectInspector oi) {
        if (oi instanceof AvroLazyObjectInspector) {
            initAvroObjectInspector(oi);
        } else if (oi instanceof MapObjectInspector) {
            // we found a map objectinspector. Grab the objectinspector for the value and initialize it
            // aptly
            ObjectInspector valueOI = ((MapObjectInspector) oi).getMapValueObjectInspector();

            if (valueOI instanceof AvroLazyObjectInspector) {
                initAvroObjectInspector(valueOI);
            }
        }
    }

    /**
     * Recursively initialize the {@link AvroLazyObjectInspector} and all its nested ois
     *
     * @param oi ObjectInspector to be recursively initialized
     * @param schema {@link Schema} to be initialized with
     * @param schemaRetriever class to be used to retrieve schema
     * */
    private void initAvroObjectInspector(ObjectInspector oi) {
        // Check for a list. If found, recursively init its members
        if (oi instanceof ListObjectInspector) {
            ListObjectInspector loi = (ListObjectInspector) oi;

            initAvroObjectInspector(loi.getListElementObjectInspector());
            return;
        }

        // Check for a nested message. If found, set the schema, else return.
        if (!(oi instanceof AvroLazyObjectInspector)) {
            return;
        }

        AvroLazyObjectInspector aoi = (AvroLazyObjectInspector) oi;

        aoi.setSchemaRetriever(avroSchemaRetriever);
        aoi.setReaderSchema(schema);

        // call the method recursively over all the internal fields of the given avro
        // objectinspector
        for (StructField field : aoi.getAllStructFieldRefs()) {
            initAvroObjectInspector(field.getFieldObjectInspector());
        }
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
package org.apache.hadoop.hive.hbase.struct;

        import java.io.IOException;
        import java.util.Properties;

        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hive.hbase.ColumnMappings;
        import org.apache.hadoop.hive.hbase.HBaseSerDeHelper;
        import org.apache.hadoop.hive.hbase.HBaseSerDeParameters;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.lazy.LazySerDeParameters;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory.ObjectInspectorOptions;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;

/**
 * Default implementation of the {@link HBaseValueFactory}
 * */
public class DefaultHBaseValueFactory implements HBaseValueFactory {

    protected LazySerDeParameters serdeParams;
    protected ColumnMappings columnMappings;
    protected HBaseSerDeParameters hbaseParams;
    protected Properties properties;
    protected Configuration conf;

    private int fieldID;

    public DefaultHBaseValueFactory(int fieldID) {
        this.fieldID = fieldID;
    }

    @Override
    public void init(HBaseSerDeParameters hbaseParams, Configuration conf, Properties properties)
            throws SerDeException {
        this.hbaseParams = hbaseParams;
        this.serdeParams = hbaseParams.getSerdeParams();
        this.columnMappings = hbaseParams.getColumnMappings();
        this.properties = properties;
        this.conf = conf;
    }

    @Override
    public ObjectInspector createValueObjectInspector(TypeInfo type)
            throws SerDeException {
        return LazyFactory.createLazyObjectInspector(type,
                1, serdeParams, ObjectInspectorOptions.JAVA);
    }

    @Override
    public LazyObjectBase createValueObject(ObjectInspector inspector) throws SerDeException {
        return HBaseSerDeHelper.createLazyField(columnMappings.getColumnsMapping(), fieldID, inspector);
    }

    @Override
    public byte[] serializeValue(Object object, StructField field)
            throws IOException {
        // TODO Add support for serialization of values here
        return null;
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
package org.apache.hadoop.hive.hbase.struct;

        import java.util.ArrayList;
        import java.util.List;

        import org.apache.hadoop.hive.serde2.lazy.ByteArrayRef;
        import org.apache.hadoop.hive.serde2.lazy.LazyFactory;
        import org.apache.hadoop.hive.serde2.lazy.LazyObject;
        import org.apache.hadoop.hive.serde2.lazy.LazyStruct;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazySimpleStructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;

/**
 * This is an extension of LazyStruct. All value structs should extend this class and override the
 * {@link LazyStruct#getField(int)} method where fieldID corresponds to the ID of a value in the
 * value structure.
 * <br>
 * For example, for a value structure <i>"/part1/part2/part3"</i>, <i>part1</i> will have an id
 * <i>0</i>, <i>part2</i> will have an id <i>1</i> and <i>part3</i> will have an id <i>2</i>. Custom
 * implementations of getField(fieldID) should return the value corresponding to that fieldID. So,
 * for the above example, the value returned for <i>getField(0)</i> should be <i>part1</i>,
 * <i>getField(1)</i> should be <i>part2</i> and <i>getField(2)</i> should be <i>part3</i>.
 *
 * <br>
 * All implementation are expected to have a constructor of the form <br>
 *
 * <pre>
 * MyCustomStructObject(LazySimpleStructObjectInspector oi, Properties props, Configuration conf, ColumnMapping colMap)
 * </pre>
 *
 * */
public class HBaseStructValue extends LazyStruct {

    /**
     * The column family name
     */
    protected String familyName;

    /**
     * The column qualifier name
     */
    protected String qualifierName;

    public HBaseStructValue(LazySimpleStructObjectInspector oi) {
        super(oi);
    }

    /**
     * Set the row data for this LazyStruct.
     *
     * @see LazyObject#init(ByteArrayRef, int, int)
     *
     * @param familyName The column family name
     * @param qualifierName The column qualifier name
     */
    public void init(ByteArrayRef bytes, int start, int length, String familyName,
                     String qualifierName) {
        init(bytes, start, length);
        this.familyName = familyName;
        this.qualifierName = qualifierName;
    }

    @Override
    public ArrayList<Object> getFieldsAsList() {
        ArrayList<Object> allFields = new ArrayList<Object>();

        List<? extends StructField> fields = oi.getAllStructFieldRefs();

        for (int i = 0; i < fields.size(); i++) {
            allFields.add(getField(i));
        }

        return allFields;
    }

    /**
     * Create an initialize a {@link LazyObject} with the given bytes for the given fieldID.
     *
     * @param fieldID field for which the object is to be created
     * @param bytes value with which the object is to be initialized with
     * @return initialized {@link LazyObject}
     * */
    public LazyObject<? extends ObjectInspector> toLazyObject(int fieldID, byte[] bytes) {
        ObjectInspector fieldOI = oi.getAllStructFieldRefs().get(fieldID).getFieldObjectInspector();

        LazyObject<? extends ObjectInspector> lazyObject = LazyFactory.createLazyObject(fieldOI);

        ByteArrayRef ref = new ByteArrayRef();

        ref.setData(bytes);

        // initialize the lazy object
        lazyObject.init(ref, 0, ref.getData().length);

        return lazyObject;
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

package org.apache.hadoop.hive.hbase.struct;

        import java.io.IOException;
        import java.util.Properties;

        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hive.hbase.HBaseKeyFactory;
        import org.apache.hadoop.hive.hbase.HBaseSerDeParameters;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.StructField;
        import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;

/**
 * Provides capability to plugin custom implementations for querying of data stored in HBase.
 * */
public interface HBaseValueFactory {

    /**
     * Initialize factory with properties
     *
     * @param hbaseParam the HBaseParameters hbase parameters
     * @param conf the hadoop {@link Configuration configuration}
     * @param properties the custom {@link Properties}
     * @throws SerDeException if there was an issue initializing the factory
     */
    void init(HBaseSerDeParameters hbaseParam, Configuration conf, Properties properties)
            throws SerDeException;

    /**
     * create custom object inspector for the value
     *
     * @param type type information
     * @throws SerDeException if there was an issue creating the {@link ObjectInspector object inspector}
     */
    ObjectInspector createValueObjectInspector(TypeInfo type) throws SerDeException;

    /**
     * create custom object for hbase value
     *
     * @param inspector OI create by {@link HBaseKeyFactory#createKeyObjectInspector}
     */
    LazyObjectBase createValueObject(ObjectInspector inspector) throws SerDeException;

    /**
     * Serialize the given hive object
     *
     * @param object the object to be serialized
     * @param field the {@link StructField}
     * @return the serialized value
     * @throws IOException if there was an issue serializing the value
     */
    byte[] serializeValue(Object object, StructField field) throws IOException;
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
package org.apache.hadoop.hive.hbase.struct;

        import java.lang.reflect.Constructor;
        import java.util.Properties;

        import org.apache.hadoop.conf.Configuration;
        import org.apache.hadoop.hive.hbase.ColumnMappings.ColumnMapping;
        import org.apache.hadoop.hive.serde2.SerDeException;
        import org.apache.hadoop.hive.serde2.lazy.LazyObjectBase;
        import org.apache.hadoop.hive.serde2.lazy.objectinspector.LazySimpleStructObjectInspector;
        import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;

/**
 * Implementation of {@link HBaseValueFactory} to consume a custom struct
 * */
public class StructHBaseValueFactory<T extends HBaseStructValue> extends DefaultHBaseValueFactory {

    private final int fieldID;
    private final Constructor constructor;

    public StructHBaseValueFactory(int fieldID, Class<?> structValueClass) throws Exception {
        super(fieldID);
        this.fieldID = fieldID;
        this.constructor =
                structValueClass.getDeclaredConstructor(LazySimpleStructObjectInspector.class,
                        Properties.class, Configuration.class, ColumnMapping.class);
    }

    @Override
    public LazyObjectBase createValueObject(ObjectInspector inspector) throws SerDeException {
        try {
            return (T) constructor.newInstance(inspector, properties, hbaseParams.getBaseConfiguration(),
                    hbaseParams.getColumnMappings().getColumnsMapping()[fieldID]);
        } catch (Exception e) {
            throw new SerDeException(e);
        }
    }
}