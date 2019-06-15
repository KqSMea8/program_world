// ORM class for table 'bf_log_visit'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Wed Aug 31 23:47:18 CST 2016
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class bf_log_visit extends SqoopRecord  implements DBWritable, Writable {
    private final int PROTOCOL_VERSION = 3;
    public int getClassFormatVersion() { return PROTOCOL_VERSION; }
    protected ResultSet __cur_result_set;
    private String day;
    public String get_day() {
        return day;
    }
    public void set_day(String day) {
        this.day = day;
    }
    public bf_log_visit with_day(String day) {
        this.day = day;
        return this;
    }
    private String hour;
    public String get_hour() {
        return hour;
    }
    public void set_hour(String hour) {
        this.hour = hour;
    }
    public bf_log_visit with_hour(String hour) {
        this.hour = hour;
        return this;
    }
    private Long pv;
    public Long get_pv() {
        return pv;
    }
    public void set_pv(Long pv) {
        this.pv = pv;
    }
    public bf_log_visit with_pv(Long pv) {
        this.pv = pv;
        return this;
    }
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof bf_log_visit)) {
            return false;
        }
        bf_log_visit that = (bf_log_visit) o;
        boolean equal = true;
        equal = equal && (this.day == null ? that.day == null : this.day.equals(that.day));
        equal = equal && (this.hour == null ? that.hour == null : this.hour.equals(that.hour));
        equal = equal && (this.pv == null ? that.pv == null : this.pv.equals(that.pv));
        return equal;
    }
    public boolean equals0(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof bf_log_visit)) {
            return false;
        }
        bf_log_visit that = (bf_log_visit) o;
        boolean equal = true;
        equal = equal && (this.day == null ? that.day == null : this.day.equals(that.day));
        equal = equal && (this.hour == null ? that.hour == null : this.hour.equals(that.hour));
        equal = equal && (this.pv == null ? that.pv == null : this.pv.equals(that.pv));
        return equal;
    }
    public void readFields(ResultSet __dbResults) throws SQLException {
        this.__cur_result_set = __dbResults;
        this.day = JdbcWritableBridge.readString(1, __dbResults);
        this.hour = JdbcWritableBridge.readString(2, __dbResults);
        this.pv = JdbcWritableBridge.readLong(3, __dbResults);
    }
    public void readFields0(ResultSet __dbResults) throws SQLException {
        this.day = JdbcWritableBridge.readString(1, __dbResults);
        this.hour = JdbcWritableBridge.readString(2, __dbResults);
        this.pv = JdbcWritableBridge.readLong(3, __dbResults);
    }
    public void loadLargeObjects(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void loadLargeObjects0(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void write(PreparedStatement __dbStmt) throws SQLException {
        write(__dbStmt, 0);
    }

    public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeString(day, 1 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeString(hour, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeLong(pv, 3 + __off, -5, __dbStmt);
        return 3;
    }
    public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeString(day, 1 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeString(hour, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeLong(pv, 3 + __off, -5, __dbStmt);
    }
    public void readFields(DataInput __dataIn) throws IOException {
        this.readFields0(__dataIn);  }
    public void readFields0(DataInput __dataIn) throws IOException {
        if (__dataIn.readBoolean()) {
            this.day = null;
        } else {
            this.day = Text.readString(__dataIn);
        }
        if (__dataIn.readBoolean()) {
            this.hour = null;
        } else {
            this.hour = Text.readString(__dataIn);
        }
        if (__dataIn.readBoolean()) {
            this.pv = null;
        } else {
            this.pv = Long.valueOf(__dataIn.readLong());
        }
    }
    public void write(DataOutput __dataOut) throws IOException {
        if (null == this.day) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, day);
        }
        if (null == this.hour) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, hour);
        }
        if (null == this.pv) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.pv);
        }
    }
    public void write0(DataOutput __dataOut) throws IOException {
        if (null == this.day) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, day);
        }
        if (null == this.hour) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, hour);
        }
        if (null == this.pv) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.pv);
        }
    }
    private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
    public String toString() {
        return toString(__outputDelimiters, true);
    }
    public String toString(DelimiterSet delimiters) {
        return toString(delimiters, true);
    }
    public String toString(boolean useRecordDelim) {
        return toString(__outputDelimiters, useRecordDelim);
    }
    public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
        StringBuilder __sb = new StringBuilder();
        char fieldDelim = delimiters.getFieldsTerminatedBy();
        __sb.append(FieldFormatter.escapeAndEnclose(day==null?"null":day, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(hour==null?"null":hour, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(pv==null?"null":"" + pv, delimiters));
        if (useRecordDelim) {
            __sb.append(delimiters.getLinesTerminatedBy());
        }
        return __sb.toString();
    }
    public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
        __sb.append(FieldFormatter.escapeAndEnclose(day==null?"null":day, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(hour==null?"null":hour, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(pv==null?"null":"" + pv, delimiters));
    }
    private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
    private RecordParser __parser;
    public void parse(Text __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharSequence __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(byte [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(char [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(ByteBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    private void __loadFromFields(List<String> fields) {
        Iterator<String> __it = fields.listIterator();
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.day = null; } else {
                this.day = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.hour = null; } else {
                this.hour = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.pv = null; } else {
                this.pv = Long.valueOf(__cur_str);
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    private void __loadFromFields0(Iterator<String> __it) {
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.day = null; } else {
                this.day = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.hour = null; } else {
                this.hour = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.pv = null; } else {
                this.pv = Long.valueOf(__cur_str);
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    public Object clone() throws CloneNotSupportedException {
        bf_log_visit o = (bf_log_visit) super.clone();
        return o;
    }

    public void clone0(bf_log_visit o) throws CloneNotSupportedException {
    }

    public Map<String, Object> getFieldMap() {
        Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
        __sqoop$field_map.put("day", this.day);
        __sqoop$field_map.put("hour", this.hour);
        __sqoop$field_map.put("pv", this.pv);
        return __sqoop$field_map;
    }

    public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
        __sqoop$field_map.put("day", this.day);
        __sqoop$field_map.put("hour", this.hour);
        __sqoop$field_map.put("pv", this.pv);
    }

    public void setField(String __fieldName, Object __fieldVal) {
        if ("day".equals(__fieldName)) {
            this.day = (String) __fieldVal;
        }
        else    if ("hour".equals(__fieldName)) {
            this.hour = (String) __fieldVal;
        }
        else    if ("pv".equals(__fieldName)) {
            this.pv = (Long) __fieldVal;
        }
        else {
            throw new RuntimeException("No such field: " + __fieldName);
        }
    }
    public boolean setField0(String __fieldName, Object __fieldVal) {
        if ("day".equals(__fieldName)) {
            this.day = (String) __fieldVal;
            return true;
        }
        else    if ("hour".equals(__fieldName)) {
            this.hour = (String) __fieldVal;
            return true;
        }
        else    if ("pv".equals(__fieldName)) {
            this.pv = (Long) __fieldVal;
            return true;
        }
        else {
            return false;    }
    }
}
// ORM class for table 'daily_hour_visit_from_hive'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Sat Jul 02 10:31:11 CST 2016
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
        import org.apache.hadoop.io.Text;
        import org.apache.hadoop.io.Writable;
        import org.apache.hadoop.mapred.lib.db.DBWritable;
        import com.cloudera.sqoop.lib.JdbcWritableBridge;
        import com.cloudera.sqoop.lib.DelimiterSet;
        import com.cloudera.sqoop.lib.FieldFormatter;
        import com.cloudera.sqoop.lib.RecordParser;
        import com.cloudera.sqoop.lib.BooleanParser;
        import com.cloudera.sqoop.lib.BlobRef;
        import com.cloudera.sqoop.lib.ClobRef;
        import com.cloudera.sqoop.lib.LargeObjectLoader;
        import com.cloudera.sqoop.lib.SqoopRecord;
        import java.sql.PreparedStatement;
        import java.sql.ResultSet;
        import java.sql.SQLException;
        import java.io.DataInput;
        import java.io.DataOutput;
        import java.io.IOException;
        import java.nio.ByteBuffer;
        import java.nio.CharBuffer;
        import java.sql.Date;
        import java.sql.Time;
        import java.sql.Timestamp;
        import java.util.Arrays;
        import java.util.Iterator;
        import java.util.List;
        import java.util.Map;
        import java.util.TreeMap;

public class daily_hour_visit_from_hive extends SqoopRecord  implements DBWritable, Writable {
    private final int PROTOCOL_VERSION = 3;
    public int getClassFormatVersion() { return PROTOCOL_VERSION; }
    protected ResultSet __cur_result_set;
    private java.sql.Date date;
    public java.sql.Date get_date() {
        return date;
    }
    public void set_date(java.sql.Date date) {
        this.date = date;
    }
    public daily_hour_visit_from_hive with_date(java.sql.Date date) {
        this.date = date;
        return this;
    }
    private String hour;
    public String get_hour() {
        return hour;
    }
    public void set_hour(String hour) {
        this.hour = hour;
    }
    public daily_hour_visit_from_hive with_hour(String hour) {
        this.hour = hour;
        return this;
    }
    private Long pv;
    public Long get_pv() {
        return pv;
    }
    public void set_pv(Long pv) {
        this.pv = pv;
    }
    public daily_hour_visit_from_hive with_pv(Long pv) {
        this.pv = pv;
        return this;
    }
    private Long uv;
    public Long get_uv() {
        return uv;
    }
    public void set_uv(Long uv) {
        this.uv = uv;
    }
    public daily_hour_visit_from_hive with_uv(Long uv) {
        this.uv = uv;
        return this;
    }
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof daily_hour_visit_from_hive)) {
            return false;
        }
        daily_hour_visit_from_hive that = (daily_hour_visit_from_hive) o;
        boolean equal = true;
        equal = equal && (this.date == null ? that.date == null : this.date.equals(that.date));
        equal = equal && (this.hour == null ? that.hour == null : this.hour.equals(that.hour));
        equal = equal && (this.pv == null ? that.pv == null : this.pv.equals(that.pv));
        equal = equal && (this.uv == null ? that.uv == null : this.uv.equals(that.uv));
        return equal;
    }
    public boolean equals0(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof daily_hour_visit_from_hive)) {
            return false;
        }
        daily_hour_visit_from_hive that = (daily_hour_visit_from_hive) o;
        boolean equal = true;
        equal = equal && (this.date == null ? that.date == null : this.date.equals(that.date));
        equal = equal && (this.hour == null ? that.hour == null : this.hour.equals(that.hour));
        equal = equal && (this.pv == null ? that.pv == null : this.pv.equals(that.pv));
        equal = equal && (this.uv == null ? that.uv == null : this.uv.equals(that.uv));
        return equal;
    }
    public void readFields(ResultSet __dbResults) throws SQLException {
        this.__cur_result_set = __dbResults;
        this.date = JdbcWritableBridge.readDate(1, __dbResults);
        this.hour = JdbcWritableBridge.readString(2, __dbResults);
        this.pv = JdbcWritableBridge.readLong(3, __dbResults);
        this.uv = JdbcWritableBridge.readLong(4, __dbResults);
    }
    public void readFields0(ResultSet __dbResults) throws SQLException {
        this.date = JdbcWritableBridge.readDate(1, __dbResults);
        this.hour = JdbcWritableBridge.readString(2, __dbResults);
        this.pv = JdbcWritableBridge.readLong(3, __dbResults);
        this.uv = JdbcWritableBridge.readLong(4, __dbResults);
    }
    public void loadLargeObjects(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void loadLargeObjects0(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void write(PreparedStatement __dbStmt) throws SQLException {
        write(__dbStmt, 0);
    }

    public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeDate(date, 1 + __off, 91, __dbStmt);
        JdbcWritableBridge.writeString(hour, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeLong(pv, 3 + __off, -5, __dbStmt);
        JdbcWritableBridge.writeLong(uv, 4 + __off, -5, __dbStmt);
        return 4;
    }
    public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeDate(date, 1 + __off, 91, __dbStmt);
        JdbcWritableBridge.writeString(hour, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeLong(pv, 3 + __off, -5, __dbStmt);
        JdbcWritableBridge.writeLong(uv, 4 + __off, -5, __dbStmt);
    }
    public void readFields(DataInput __dataIn) throws IOException {
        this.readFields0(__dataIn);  }
    public void readFields0(DataInput __dataIn) throws IOException {
        if (__dataIn.readBoolean()) {
            this.date = null;
        } else {
            this.date = new Date(__dataIn.readLong());
        }
        if (__dataIn.readBoolean()) {
            this.hour = null;
        } else {
            this.hour = Text.readString(__dataIn);
        }
        if (__dataIn.readBoolean()) {
            this.pv = null;
        } else {
            this.pv = Long.valueOf(__dataIn.readLong());
        }
        if (__dataIn.readBoolean()) {
            this.uv = null;
        } else {
            this.uv = Long.valueOf(__dataIn.readLong());
        }
    }
    public void write(DataOutput __dataOut) throws IOException {
        if (null == this.date) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.date.getTime());
        }
        if (null == this.hour) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, hour);
        }
        if (null == this.pv) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.pv);
        }
        if (null == this.uv) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.uv);
        }
    }
    public void write0(DataOutput __dataOut) throws IOException {
        if (null == this.date) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.date.getTime());
        }
        if (null == this.hour) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, hour);
        }
        if (null == this.pv) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.pv);
        }
        if (null == this.uv) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeLong(this.uv);
        }
    }
    private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
    public String toString() {
        return toString(__outputDelimiters, true);
    }
    public String toString(DelimiterSet delimiters) {
        return toString(delimiters, true);
    }
    public String toString(boolean useRecordDelim) {
        return toString(__outputDelimiters, useRecordDelim);
    }
    public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
        StringBuilder __sb = new StringBuilder();
        char fieldDelim = delimiters.getFieldsTerminatedBy();
        __sb.append(FieldFormatter.escapeAndEnclose(date==null?"null":"" + date, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(hour==null?"null":hour, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(pv==null?"null":"" + pv, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(uv==null?"null":"" + uv, delimiters));
        if (useRecordDelim) {
            __sb.append(delimiters.getLinesTerminatedBy());
        }
        return __sb.toString();
    }
    public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
        __sb.append(FieldFormatter.escapeAndEnclose(date==null?"null":"" + date, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(hour==null?"null":hour, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(pv==null?"null":"" + pv, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(uv==null?"null":"" + uv, delimiters));
    }
    private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 9, (char) 10, (char) 0, (char) 0, false);
    private RecordParser __parser;
    public void parse(Text __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharSequence __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(byte [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(char [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(ByteBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    private void __loadFromFields(List<String> fields) {
        Iterator<String> __it = fields.listIterator();
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.date = null; } else {
                this.date = java.sql.Date.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.hour = null; } else {
                this.hour = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.pv = null; } else {
                this.pv = Long.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.uv = null; } else {
                this.uv = Long.valueOf(__cur_str);
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    private void __loadFromFields0(Iterator<String> __it) {
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.date = null; } else {
                this.date = java.sql.Date.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.hour = null; } else {
                this.hour = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.pv = null; } else {
                this.pv = Long.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.uv = null; } else {
                this.uv = Long.valueOf(__cur_str);
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    public Object clone() throws CloneNotSupportedException {
        daily_hour_visit_from_hive o = (daily_hour_visit_from_hive) super.clone();
        o.date = (o.date != null) ? (java.sql.Date) o.date.clone() : null;
        return o;
    }

    public void clone0(daily_hour_visit_from_hive o) throws CloneNotSupportedException {
        o.date = (o.date != null) ? (java.sql.Date) o.date.clone() : null;
    }

    public Map<String, Object> getFieldMap() {
        Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
        __sqoop$field_map.put("date", this.date);
        __sqoop$field_map.put("hour", this.hour);
        __sqoop$field_map.put("pv", this.pv);
        __sqoop$field_map.put("uv", this.uv);
        return __sqoop$field_map;
    }

    public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
        __sqoop$field_map.put("date", this.date);
        __sqoop$field_map.put("hour", this.hour);
        __sqoop$field_map.put("pv", this.pv);
        __sqoop$field_map.put("uv", this.uv);
    }

    public void setField(String __fieldName, Object __fieldVal) {
        if ("date".equals(__fieldName)) {
            this.date = (java.sql.Date) __fieldVal;
        }
        else    if ("hour".equals(__fieldName)) {
            this.hour = (String) __fieldVal;
        }
        else    if ("pv".equals(__fieldName)) {
            this.pv = (Long) __fieldVal;
        }
        else    if ("uv".equals(__fieldName)) {
            this.uv = (Long) __fieldVal;
        }
        else {
            throw new RuntimeException("No such field: " + __fieldName);
        }
    }
    public boolean setField0(String __fieldName, Object __fieldVal) {
        if ("date".equals(__fieldName)) {
            this.date = (java.sql.Date) __fieldVal;
            return true;
        }
        else    if ("hour".equals(__fieldName)) {
            this.hour = (String) __fieldVal;
            return true;
        }
        else    if ("pv".equals(__fieldName)) {
            this.pv = (Long) __fieldVal;
            return true;
        }
        else    if ("uv".equals(__fieldName)) {
            this.uv = (Long) __fieldVal;
            return true;
        }
        else {
            return false;    }
    }
}
// ORM class for table 'my_user_from_hive'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Thu Jun 30 16:28:33 CST 2016
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
        import org.apache.hadoop.io.Text;
        import org.apache.hadoop.io.Writable;
        import org.apache.hadoop.mapred.lib.db.DBWritable;
        import com.cloudera.sqoop.lib.JdbcWritableBridge;
        import com.cloudera.sqoop.lib.DelimiterSet;
        import com.cloudera.sqoop.lib.FieldFormatter;
        import com.cloudera.sqoop.lib.RecordParser;
        import com.cloudera.sqoop.lib.BooleanParser;
        import com.cloudera.sqoop.lib.BlobRef;
        import com.cloudera.sqoop.lib.ClobRef;
        import com.cloudera.sqoop.lib.LargeObjectLoader;
        import com.cloudera.sqoop.lib.SqoopRecord;
        import java.sql.PreparedStatement;
        import java.sql.ResultSet;
        import java.sql.SQLException;
        import java.io.DataInput;
        import java.io.DataOutput;
        import java.io.IOException;
        import java.nio.ByteBuffer;
        import java.nio.CharBuffer;
        import java.sql.Date;
        import java.sql.Time;
        import java.sql.Timestamp;
        import java.util.Arrays;
        import java.util.Iterator;
        import java.util.List;
        import java.util.Map;
        import java.util.TreeMap;

public class my_user_from_hive extends SqoopRecord  implements DBWritable, Writable {
    private final int PROTOCOL_VERSION = 3;
    public int getClassFormatVersion() { return PROTOCOL_VERSION; }
    protected ResultSet __cur_result_set;
    private Integer id;
    public Integer get_id() {
        return id;
    }
    public void set_id(Integer id) {
        this.id = id;
    }
    public my_user_from_hive with_id(Integer id) {
        this.id = id;
        return this;
    }
    private String account;
    public String get_account() {
        return account;
    }
    public void set_account(String account) {
        this.account = account;
    }
    public my_user_from_hive with_account(String account) {
        this.account = account;
        return this;
    }
    private String passwd;
    public String get_passwd() {
        return passwd;
    }
    public void set_passwd(String passwd) {
        this.passwd = passwd;
    }
    public my_user_from_hive with_passwd(String passwd) {
        this.passwd = passwd;
        return this;
    }
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof my_user_from_hive)) {
            return false;
        }
        my_user_from_hive that = (my_user_from_hive) o;
        boolean equal = true;
        equal = equal && (this.id == null ? that.id == null : this.id.equals(that.id));
        equal = equal && (this.account == null ? that.account == null : this.account.equals(that.account));
        equal = equal && (this.passwd == null ? that.passwd == null : this.passwd.equals(that.passwd));
        return equal;
    }
    public boolean equals0(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof my_user_from_hive)) {
            return false;
        }
        my_user_from_hive that = (my_user_from_hive) o;
        boolean equal = true;
        equal = equal && (this.id == null ? that.id == null : this.id.equals(that.id));
        equal = equal && (this.account == null ? that.account == null : this.account.equals(that.account));
        equal = equal && (this.passwd == null ? that.passwd == null : this.passwd.equals(that.passwd));
        return equal;
    }
    public void readFields(ResultSet __dbResults) throws SQLException {
        this.__cur_result_set = __dbResults;
        this.id = JdbcWritableBridge.readInteger(1, __dbResults);
        this.account = JdbcWritableBridge.readString(2, __dbResults);
        this.passwd = JdbcWritableBridge.readString(3, __dbResults);
    }
    public void readFields0(ResultSet __dbResults) throws SQLException {
        this.id = JdbcWritableBridge.readInteger(1, __dbResults);
        this.account = JdbcWritableBridge.readString(2, __dbResults);
        this.passwd = JdbcWritableBridge.readString(3, __dbResults);
    }
    public void loadLargeObjects(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void loadLargeObjects0(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void write(PreparedStatement __dbStmt) throws SQLException {
        write(__dbStmt, 0);
    }

    public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeInteger(id, 1 + __off, -6, __dbStmt);
        JdbcWritableBridge.writeString(account, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeString(passwd, 3 + __off, 12, __dbStmt);
        return 3;
    }
    public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeInteger(id, 1 + __off, -6, __dbStmt);
        JdbcWritableBridge.writeString(account, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeString(passwd, 3 + __off, 12, __dbStmt);
    }
    public void readFields(DataInput __dataIn) throws IOException {
        this.readFields0(__dataIn);  }
    public void readFields0(DataInput __dataIn) throws IOException {
        if (__dataIn.readBoolean()) {
            this.id = null;
        } else {
            this.id = Integer.valueOf(__dataIn.readInt());
        }
        if (__dataIn.readBoolean()) {
            this.account = null;
        } else {
            this.account = Text.readString(__dataIn);
        }
        if (__dataIn.readBoolean()) {
            this.passwd = null;
        } else {
            this.passwd = Text.readString(__dataIn);
        }
    }
    public void write(DataOutput __dataOut) throws IOException {
        if (null == this.id) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeInt(this.id);
        }
        if (null == this.account) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, account);
        }
        if (null == this.passwd) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, passwd);
        }
    }
    public void write0(DataOutput __dataOut) throws IOException {
        if (null == this.id) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeInt(this.id);
        }
        if (null == this.account) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, account);
        }
        if (null == this.passwd) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, passwd);
        }
    }
    private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
    public String toString() {
        return toString(__outputDelimiters, true);
    }
    public String toString(DelimiterSet delimiters) {
        return toString(delimiters, true);
    }
    public String toString(boolean useRecordDelim) {
        return toString(__outputDelimiters, useRecordDelim);
    }
    public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
        StringBuilder __sb = new StringBuilder();
        char fieldDelim = delimiters.getFieldsTerminatedBy();
        __sb.append(FieldFormatter.escapeAndEnclose(id==null?"null":"" + id, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(account==null?"null":account, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(passwd==null?"null":passwd, delimiters));
        if (useRecordDelim) {
            __sb.append(delimiters.getLinesTerminatedBy());
        }
        return __sb.toString();
    }
    public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
        __sb.append(FieldFormatter.escapeAndEnclose(id==null?"null":"" + id, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(account==null?"null":account, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(passwd==null?"null":passwd, delimiters));
    }
    private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 9, (char) 10, (char) 0, (char) 0, false);
    private RecordParser __parser;
    public void parse(Text __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharSequence __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(byte [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(char [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(ByteBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    private void __loadFromFields(List<String> fields) {
        Iterator<String> __it = fields.listIterator();
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.id = null; } else {
                this.id = Integer.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.account = null; } else {
                this.account = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.passwd = null; } else {
                this.passwd = __cur_str;
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    private void __loadFromFields0(Iterator<String> __it) {
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.id = null; } else {
                this.id = Integer.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.account = null; } else {
                this.account = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.passwd = null; } else {
                this.passwd = __cur_str;
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    public Object clone() throws CloneNotSupportedException {
        my_user_from_hive o = (my_user_from_hive) super.clone();
        return o;
    }

    public void clone0(my_user_from_hive o) throws CloneNotSupportedException {
    }

    public Map<String, Object> getFieldMap() {
        Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
        __sqoop$field_map.put("id", this.id);
        __sqoop$field_map.put("account", this.account);
        __sqoop$field_map.put("passwd", this.passwd);
        return __sqoop$field_map;
    }

    public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
        __sqoop$field_map.put("id", this.id);
        __sqoop$field_map.put("account", this.account);
        __sqoop$field_map.put("passwd", this.passwd);
    }

    public void setField(String __fieldName, Object __fieldVal) {
        if ("id".equals(__fieldName)) {
            this.id = (Integer) __fieldVal;
        }
        else    if ("account".equals(__fieldName)) {
            this.account = (String) __fieldVal;
        }
        else    if ("passwd".equals(__fieldName)) {
            this.passwd = (String) __fieldVal;
        }
        else {
            throw new RuntimeException("No such field: " + __fieldName);
        }
    }
    public boolean setField0(String __fieldName, Object __fieldVal) {
        if ("id".equals(__fieldName)) {
            this.id = (Integer) __fieldVal;
            return true;
        }
        else    if ("account".equals(__fieldName)) {
            this.account = (String) __fieldVal;
            return true;
        }
        else    if ("passwd".equals(__fieldName)) {
            this.passwd = (String) __fieldVal;
            return true;
        }
        else {
            return false;    }
    }
}
// ORM class for table 'my_user'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Thu Jun 30 12:43:12 CST 2016
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
        import org.apache.hadoop.io.Text;
        import org.apache.hadoop.io.Writable;
        import org.apache.hadoop.mapred.lib.db.DBWritable;
        import com.cloudera.sqoop.lib.JdbcWritableBridge;
        import com.cloudera.sqoop.lib.DelimiterSet;
        import com.cloudera.sqoop.lib.FieldFormatter;
        import com.cloudera.sqoop.lib.RecordParser;
        import com.cloudera.sqoop.lib.BooleanParser;
        import com.cloudera.sqoop.lib.BlobRef;
        import com.cloudera.sqoop.lib.ClobRef;
        import com.cloudera.sqoop.lib.LargeObjectLoader;
        import com.cloudera.sqoop.lib.SqoopRecord;
        import java.sql.PreparedStatement;
        import java.sql.ResultSet;
        import java.sql.SQLException;
        import java.io.DataInput;
        import java.io.DataOutput;
        import java.io.IOException;
        import java.nio.ByteBuffer;
        import java.nio.CharBuffer;
        import java.sql.Date;
        import java.sql.Time;
        import java.sql.Timestamp;
        import java.util.Arrays;
        import java.util.Iterator;
        import java.util.List;
        import java.util.Map;
        import java.util.TreeMap;

public class my_user extends SqoopRecord  implements DBWritable, Writable {
    private final int PROTOCOL_VERSION = 3;
    public int getClassFormatVersion() { return PROTOCOL_VERSION; }
    protected ResultSet __cur_result_set;
    private Integer id;
    public Integer get_id() {
        return id;
    }
    public void set_id(Integer id) {
        this.id = id;
    }
    public my_user with_id(Integer id) {
        this.id = id;
        return this;
    }
    private String account;
    public String get_account() {
        return account;
    }
    public void set_account(String account) {
        this.account = account;
    }
    public my_user with_account(String account) {
        this.account = account;
        return this;
    }
    private String passwd;
    public String get_passwd() {
        return passwd;
    }
    public void set_passwd(String passwd) {
        this.passwd = passwd;
    }
    public my_user with_passwd(String passwd) {
        this.passwd = passwd;
        return this;
    }
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof my_user)) {
            return false;
        }
        my_user that = (my_user) o;
        boolean equal = true;
        equal = equal && (this.id == null ? that.id == null : this.id.equals(that.id));
        equal = equal && (this.account == null ? that.account == null : this.account.equals(that.account));
        equal = equal && (this.passwd == null ? that.passwd == null : this.passwd.equals(that.passwd));
        return equal;
    }
    public boolean equals0(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof my_user)) {
            return false;
        }
        my_user that = (my_user) o;
        boolean equal = true;
        equal = equal && (this.id == null ? that.id == null : this.id.equals(that.id));
        equal = equal && (this.account == null ? that.account == null : this.account.equals(that.account));
        equal = equal && (this.passwd == null ? that.passwd == null : this.passwd.equals(that.passwd));
        return equal;
    }
    public void readFields(ResultSet __dbResults) throws SQLException {
        this.__cur_result_set = __dbResults;
        this.id = JdbcWritableBridge.readInteger(1, __dbResults);
        this.account = JdbcWritableBridge.readString(2, __dbResults);
        this.passwd = JdbcWritableBridge.readString(3, __dbResults);
    }
    public void readFields0(ResultSet __dbResults) throws SQLException {
        this.id = JdbcWritableBridge.readInteger(1, __dbResults);
        this.account = JdbcWritableBridge.readString(2, __dbResults);
        this.passwd = JdbcWritableBridge.readString(3, __dbResults);
    }
    public void loadLargeObjects(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void loadLargeObjects0(LargeObjectLoader __loader)
            throws SQLException, IOException, InterruptedException {
    }
    public void write(PreparedStatement __dbStmt) throws SQLException {
        write(__dbStmt, 0);
    }

    public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeInteger(id, 1 + __off, -6, __dbStmt);
        JdbcWritableBridge.writeString(account, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeString(passwd, 3 + __off, 12, __dbStmt);
        return 3;
    }
    public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
        JdbcWritableBridge.writeInteger(id, 1 + __off, -6, __dbStmt);
        JdbcWritableBridge.writeString(account, 2 + __off, 12, __dbStmt);
        JdbcWritableBridge.writeString(passwd, 3 + __off, 12, __dbStmt);
    }
    public void readFields(DataInput __dataIn) throws IOException {
        this.readFields0(__dataIn);  }
    public void readFields0(DataInput __dataIn) throws IOException {
        if (__dataIn.readBoolean()) {
            this.id = null;
        } else {
            this.id = Integer.valueOf(__dataIn.readInt());
        }
        if (__dataIn.readBoolean()) {
            this.account = null;
        } else {
            this.account = Text.readString(__dataIn);
        }
        if (__dataIn.readBoolean()) {
            this.passwd = null;
        } else {
            this.passwd = Text.readString(__dataIn);
        }
    }
    public void write(DataOutput __dataOut) throws IOException {
        if (null == this.id) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeInt(this.id);
        }
        if (null == this.account) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, account);
        }
        if (null == this.passwd) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, passwd);
        }
    }
    public void write0(DataOutput __dataOut) throws IOException {
        if (null == this.id) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            __dataOut.writeInt(this.id);
        }
        if (null == this.account) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, account);
        }
        if (null == this.passwd) {
            __dataOut.writeBoolean(true);
        } else {
            __dataOut.writeBoolean(false);
            Text.writeString(__dataOut, passwd);
        }
    }
    private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 9, (char) 10, (char) 0, (char) 0, false);
    public String toString() {
        return toString(__outputDelimiters, true);
    }
    public String toString(DelimiterSet delimiters) {
        return toString(delimiters, true);
    }
    public String toString(boolean useRecordDelim) {
        return toString(__outputDelimiters, useRecordDelim);
    }
    public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
        StringBuilder __sb = new StringBuilder();
        char fieldDelim = delimiters.getFieldsTerminatedBy();
        __sb.append(FieldFormatter.escapeAndEnclose(id==null?"null":"" + id, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(account==null?"null":account, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(passwd==null?"null":passwd, delimiters));
        if (useRecordDelim) {
            __sb.append(delimiters.getLinesTerminatedBy());
        }
        return __sb.toString();
    }
    public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
        __sb.append(FieldFormatter.escapeAndEnclose(id==null?"null":"" + id, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(account==null?"null":account, delimiters));
        __sb.append(fieldDelim);
        __sb.append(FieldFormatter.escapeAndEnclose(passwd==null?"null":passwd, delimiters));
    }
    private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 9, (char) 10, (char) 0, (char) 0, false);
    private RecordParser __parser;
    public void parse(Text __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharSequence __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(byte [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(char [] __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(ByteBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    public void parse(CharBuffer __record) throws RecordParser.ParseError {
        if (null == this.__parser) {
            this.__parser = new RecordParser(__inputDelimiters);
        }
        List<String> __fields = this.__parser.parseRecord(__record);
        __loadFromFields(__fields);
    }

    private void __loadFromFields(List<String> fields) {
        Iterator<String> __it = fields.listIterator();
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.id = null; } else {
                this.id = Integer.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.account = null; } else {
                this.account = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.passwd = null; } else {
                this.passwd = __cur_str;
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    private void __loadFromFields0(Iterator<String> __it) {
        String __cur_str = null;
        try {
            __cur_str = __it.next();
            if (__cur_str.equals("null") || __cur_str.length() == 0) { this.id = null; } else {
                this.id = Integer.valueOf(__cur_str);
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.account = null; } else {
                this.account = __cur_str;
            }

            __cur_str = __it.next();
            if (__cur_str.equals("null")) { this.passwd = null; } else {
                this.passwd = __cur_str;
            }

        } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

    public Object clone() throws CloneNotSupportedException {
        my_user o = (my_user) super.clone();
        return o;
    }

    public void clone0(my_user o) throws CloneNotSupportedException {
    }

    public Map<String, Object> getFieldMap() {
        Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
        __sqoop$field_map.put("id", this.id);
        __sqoop$field_map.put("account", this.account);
        __sqoop$field_map.put("passwd", this.passwd);
        return __sqoop$field_map;
    }

    public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
        __sqoop$field_map.put("id", this.id);
        __sqoop$field_map.put("account", this.account);
        __sqoop$field_map.put("passwd", this.passwd);
    }

    public void setField(String __fieldName, Object __fieldVal) {
        if ("id".equals(__fieldName)) {
            this.id = (Integer) __fieldVal;
        }
        else    if ("account".equals(__fieldName)) {
            this.account = (String) __fieldVal;
        }
        else    if ("passwd".equals(__fieldName)) {
            this.passwd = (String) __fieldVal;
        }
        else {
            throw new RuntimeException("No such field: " + __fieldName);
        }
    }
    public boolean setField0(String __fieldName, Object __fieldVal) {
        if ("id".equals(__fieldName)) {
            this.id = (Integer) __fieldVal;
            return true;
        }
        else    if ("account".equals(__fieldName)) {
            this.account = (String) __fieldVal;
            return true;
        }
        else    if ("passwd".equals(__fieldName)) {
            this.passwd = (String) __fieldVal;
            return true;
        }
        else {
            return false;    }
    }
}
