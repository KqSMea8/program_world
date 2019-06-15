/**
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
package org.apache.hadoop.hbase.types;

import com.google.protobuf.CodedInputStream;
import com.google.protobuf.CodedOutputStream;
import java.io.IOException;
import org.apache.hadoop.hbase.protobuf.generated.CellProtos;
import org.apache.hadoop.hbase.util.PositionedByteRange;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * An example for using protobuf objects with {@link DataType} API.
 */
@InterfaceAudience.Private
public class PBCell extends PBType<CellProtos.Cell> {
  @Override
  public Class<CellProtos.Cell> encodedClass() {
    return CellProtos.Cell.class;
  }

  @Override
  public int skip(PositionedByteRange src) {
    CellProtos.Cell.Builder builder = CellProtos.Cell.newBuilder();
    CodedInputStream is = inputStreamFromByteRange(src);
    is.setSizeLimit(src.getLength());
    try {
      builder.mergeFrom(is);
      int consumed = is.getTotalBytesRead();
      src.setPosition(src.getPosition() + consumed);
      return consumed;
    } catch (IOException e) {
      throw new RuntimeException("Error while skipping type.", e);
    }
  }

  @Override
  public CellProtos.Cell decode(PositionedByteRange src) {
    CellProtos.Cell.Builder builder = CellProtos.Cell.newBuilder();
    CodedInputStream is = inputStreamFromByteRange(src);
    is.setSizeLimit(src.getLength());
    try {
      CellProtos.Cell ret = builder.mergeFrom(is).build();
      src.setPosition(src.getPosition() + is.getTotalBytesRead());
      return ret;
    } catch (IOException e) {
      throw new RuntimeException("Error while decoding type.", e);
    }
  }

  @Override
  public int encode(PositionedByteRange dst, CellProtos.Cell val) {
    CodedOutputStream os = outputStreamFromByteRange(dst);
    try {
      int before = os.spaceLeft(), after, written;
      val.writeTo(os);
      after = os.spaceLeft();
      written = before - after;
      dst.setPosition(dst.getPosition() + written);
      return written;
    } catch (IOException e) {
      throw new RuntimeException("Error while encoding type.", e);
    }
  }
}
/**
 *
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
package org.apache.hadoop.hbase.thrift2;

import java.nio.ByteBuffer;
import java.security.PrivilegedExceptionAction;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.security.auth.Subject;
import javax.security.auth.login.AppConfigurationEntry;
import javax.security.auth.login.Configuration;
import javax.security.auth.login.LoginContext;
import javax.security.sasl.Sasl;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.thrift2.generated.TColumnValue;
import org.apache.hadoop.hbase.thrift2.generated.TGet;
import org.apache.hadoop.hbase.thrift2.generated.THBaseService;
import org.apache.hadoop.hbase.thrift2.generated.TPut;
import org.apache.hadoop.hbase.thrift2.generated.TResult;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TFramedTransport;
import org.apache.thrift.transport.TSaslClientTransport;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
import org.apache.yetus.audience.InterfaceAudience;

@InterfaceAudience.Private
public class DemoClient {

  private static String host = "localhost";
  private static int port = 9090;
  private static boolean secure = false;
  private static String user = null;

  public static void main(String[] args) throws Exception {
    System.out.println("Thrift2 Demo");
    System.out.println("Usage: DemoClient [host=localhost] [port=9090] [secure=false]");
    System.out.println("This demo assumes you have a table called \"example\" with a column family called \"family1\"");

    // use passed in arguments instead of defaults
    if (args.length >= 1) {
      host = args[0];
    }
    if (args.length >= 2) {
      port = Integer.parseInt(args[1]);
    }
    org.apache.hadoop.conf.Configuration conf = HBaseConfiguration.create();
    String principal = conf.get("hbase.thrift.kerberos.principal");
    if (principal != null) {
      secure = true;
      int slashIdx = principal.indexOf("/");
      int atIdx = principal.indexOf("@");
      int idx = slashIdx != -1 ? slashIdx : atIdx != -1 ? atIdx : principal.length();
      user = principal.substring(0, idx);
    }
    if (args.length >= 3) {
      secure = Boolean.parseBoolean(args[2]);
    }

    final DemoClient client = new DemoClient();
    Subject.doAs(getSubject(),
      new PrivilegedExceptionAction<Void>() {
        @Override
        public Void run() throws Exception {
          client.run();
          return null;
        }
      });
  }

  public void run() throws Exception {
    int timeout = 10000;
    boolean framed = false;

    TTransport transport = new TSocket(host, port, timeout);
    if (framed) {
      transport = new TFramedTransport(transport);
    } else if (secure) {
      /**
       * The Thrift server the DemoClient is trying to connect to
       * must have a matching principal, and support authentication.
       *
       * The HBase cluster must be secure, allow proxy user.
       */
      Map<String, String> saslProperties = new HashMap<>();
      saslProperties.put(Sasl.QOP, "auth-conf,auth-int,auth");
      transport = new TSaslClientTransport("GSSAPI", null,
        user != null ? user : "hbase",// Thrift server user name, should be an authorized proxy user
        host, // Thrift server domain
        saslProperties, null, transport);
    }

    TProtocol protocol = new TBinaryProtocol(transport);
    // This is our thrift client.
    THBaseService.Iface client = new THBaseService.Client(protocol);

    // open the transport
    transport.open();

    ByteBuffer table = ByteBuffer.wrap(Bytes.toBytes("example"));

    TPut put = new TPut();
    put.setRow(Bytes.toBytes("row1"));

    TColumnValue columnValue = new TColumnValue();
    columnValue.setFamily(Bytes.toBytes("family1"));
    columnValue.setQualifier(Bytes.toBytes("qualifier1"));
    columnValue.setValue(Bytes.toBytes("value1"));
    List<TColumnValue> columnValues = new ArrayList<>(1);
    columnValues.add(columnValue);
    put.setColumnValues(columnValues);

    client.put(table, put);

    TGet get = new TGet();
    get.setRow(Bytes.toBytes("row1"));

    TResult result = client.get(table, get);

    System.out.print("row = " + new String(result.getRow()));
    for (TColumnValue resultColumnValue : result.getColumnValues()) {
      System.out.print("family = " + new String(resultColumnValue.getFamily()));
      System.out.print("qualifier = " + new String(resultColumnValue.getFamily()));
      System.out.print("value = " + new String(resultColumnValue.getValue()));
      System.out.print("timestamp = " + resultColumnValue.getTimestamp());
    }

    transport.close();
  }

  static Subject getSubject() throws Exception {
    if (!secure) return new Subject();

    /*
     * To authenticate the DemoClient, kinit should be invoked ahead.
     * Here we try to get the Kerberos credential from the ticket cache.
     */
    LoginContext context = new LoginContext("", new Subject(), null,
      new Configuration() {
        @Override
        public AppConfigurationEntry[] getAppConfigurationEntry(String name) {
          Map<String, String> options = new HashMap<>();
          options.put("useKeyTab", "false");
          options.put("storeKey", "false");
          options.put("doNotPrompt", "true");
          options.put("useTicketCache", "true");
          options.put("renewTGT", "true");
          options.put("refreshKrb5Config", "true");
          options.put("isInitiator", "true");
          String ticketCache = System.getenv("KRB5CCNAME");
          if (ticketCache != null) {
            options.put("ticketCache", ticketCache);
          }
          options.put("debug", "true");

          return new AppConfigurationEntry[]{
              new AppConfigurationEntry("com.sun.security.auth.module.Krb5LoginModule",
                  AppConfigurationEntry.LoginModuleControlFlag.REQUIRED,
                  options)};
        }
      });
    context.login();
    return context.getSubject();
  }
}
/**
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

package org.apache.hadoop.hbase.rest;

import java.security.PrivilegedExceptionAction;
import java.util.HashMap;
import java.util.Map;

import javax.security.auth.Subject;
import javax.security.auth.login.AppConfigurationEntry;
import javax.security.auth.login.Configuration;
import javax.security.auth.login.LoginContext;

import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.rest.client.Client;
import org.apache.hadoop.hbase.rest.client.Cluster;
import org.apache.hadoop.hbase.rest.client.RemoteHTable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;
import org.apache.hbase.thirdparty.com.google.common.base.Preconditions;

@InterfaceAudience.Private
public class RESTDemoClient {

  private static String host = "localhost";
  private static int port = 9090;
  private static boolean secure = false;
  private static org.apache.hadoop.conf.Configuration conf = null;

  public static void main(String[] args) throws Exception {
    System.out.println("REST Demo");
    System.out.println("Usage: RESTDemoClient [host=localhost] [port=9090] [secure=false]");
    System.out.println("This demo assumes you have a table called \"example\""
        + " with a column family called \"family1\"");

    // use passed in arguments instead of defaults
    if (args.length >= 1) {
      host = args[0];
    }
    if (args.length >= 2) {
      port = Integer.parseInt(args[1]);
    }
    conf = HBaseConfiguration.create();
    String principal = conf.get(Constants.REST_KERBEROS_PRINCIPAL);
    if (principal != null) {
      secure = true;
    }
    if (args.length >= 3) {
      secure = Boolean.parseBoolean(args[2]);
    }

    final RESTDemoClient client = new RESTDemoClient();
    Subject.doAs(getSubject(), new PrivilegedExceptionAction<Void>() {
      @Override
      public Void run() throws Exception {
        client.run();
        return null;
      }
    });
  }

  public void run() throws Exception {
    Cluster cluster = new Cluster();
    cluster.add(host, port);
    Client restClient = new Client(cluster, conf.getBoolean(Constants.REST_SSL_ENABLED, false));
    try (RemoteHTable remoteTable = new RemoteHTable(restClient, conf, "example")) {
      // Write data to the table
      String rowKey = "row1";
      Put p = new Put(Bytes.toBytes(rowKey));
      p.addColumn(Bytes.toBytes("family1"), Bytes.toBytes("qualifier1"), Bytes.toBytes("value1"));
      remoteTable.put(p);

      // Get the data from the table
      Get g = new Get(Bytes.toBytes(rowKey));
      Result result = remoteTable.get(g);

      Preconditions.checkArgument(result != null,
        Bytes.toString(remoteTable.getTableName()) + " should have a row with key as " + rowKey);
      System.out.println("row = " + new String(result.getRow()));
      for (Cell cell : result.rawCells()) {
        System.out.print("family = " + Bytes.toString(CellUtil.cloneFamily(cell)) + "\t");
        System.out.print("qualifier = " + Bytes.toString(CellUtil.cloneQualifier(cell)) + "\t");
        System.out.print("value = " + Bytes.toString(CellUtil.cloneValue(cell)) + "\t");
        System.out.println("timestamp = " + Long.toString(cell.getTimestamp()));
      }
    }
  }

  static Subject getSubject() throws Exception {
    if (!secure) {
      return new Subject();
    }

    /*
     * To authenticate the demo client, kinit should be invoked ahead. Here we try to get the
     * Kerberos credential from the ticket cache.
     */
    LoginContext context = new LoginContext("", new Subject(), null, new Configuration() {
      @Override
      public AppConfigurationEntry[] getAppConfigurationEntry(String name) {
        Map<String, String> options = new HashMap<>();
        options.put("useKeyTab", "false");
        options.put("storeKey", "false");
        options.put("doNotPrompt", "true");
        options.put("useTicketCache", "true");
        options.put("renewTGT", "true");
        options.put("refreshKrb5Config", "true");
        options.put("isInitiator", "true");
        String ticketCache = System.getenv("KRB5CCNAME");
        if (ticketCache != null) {
          options.put("ticketCache", ticketCache);
        }
        options.put("debug", "true");

        return new AppConfigurationEntry[] {
          new AppConfigurationEntry("com.sun.security.auth.module.Krb5LoginModule",
                AppConfigurationEntry.LoginModuleControlFlag.REQUIRED, options) };
      }
    });
    context.login();
    return context.getSubject();
  }
}
/**
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
package org.apache.hadoop.hbase.client.example;

import static org.apache.hadoop.hbase.util.FutureUtils.addListener;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.AsyncConnection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.ipc.NettyRpcClientConfigHelper;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;

import org.apache.hbase.thirdparty.com.google.common.base.Preconditions;
import org.apache.hbase.thirdparty.com.google.common.base.Throwables;
import org.apache.hbase.thirdparty.io.netty.bootstrap.ServerBootstrap;
import org.apache.hbase.thirdparty.io.netty.buffer.ByteBuf;
import org.apache.hbase.thirdparty.io.netty.channel.Channel;
import org.apache.hbase.thirdparty.io.netty.channel.ChannelHandlerContext;
import org.apache.hbase.thirdparty.io.netty.channel.ChannelInitializer;
import org.apache.hbase.thirdparty.io.netty.channel.ChannelOption;
import org.apache.hbase.thirdparty.io.netty.channel.EventLoopGroup;
import org.apache.hbase.thirdparty.io.netty.channel.SimpleChannelInboundHandler;
import org.apache.hbase.thirdparty.io.netty.channel.group.ChannelGroup;
import org.apache.hbase.thirdparty.io.netty.channel.group.DefaultChannelGroup;
import org.apache.hbase.thirdparty.io.netty.channel.nio.NioEventLoopGroup;
import org.apache.hbase.thirdparty.io.netty.channel.socket.nio.NioServerSocketChannel;
import org.apache.hbase.thirdparty.io.netty.channel.socket.nio.NioSocketChannel;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.DefaultFullHttpResponse;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.FullHttpRequest;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.HttpHeaderNames;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.HttpObjectAggregator;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.HttpResponseStatus;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.HttpServerCodec;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.HttpVersion;
import org.apache.hbase.thirdparty.io.netty.handler.codec.http.QueryStringDecoder;
import org.apache.hbase.thirdparty.io.netty.util.concurrent.GlobalEventExecutor;

/**
 * A simple example on how to use {@link org.apache.hadoop.hbase.client.AsyncTable} to write a fully
 * asynchronous HTTP proxy server. The {@link AsyncConnection} will share the same event loop with
 * the HTTP server.
 * <p>
 * The request URL is:
 *
 * <pre>
 * http://&lt;host&gt;:&lt;port&gt;/&lt;table&gt;/&lt;rowgt;/&lt;family&gt;:&lt;qualifier&gt;
 * </pre>
 *
 * Use HTTP GET to fetch data, and use HTTP PUT to put data. Encode the value as the request content
 * when doing PUT.
 */
@InterfaceAudience.Private
public class HttpProxyExample {

  private final EventLoopGroup bossGroup = new NioEventLoopGroup(1);

  private final EventLoopGroup workerGroup = new NioEventLoopGroup();

  private final Configuration conf;

  private final int port;

  private AsyncConnection conn;

  private Channel serverChannel;

  private ChannelGroup channelGroup;

  public HttpProxyExample(Configuration conf, int port) {
    this.conf = conf;
    this.port = port;
  }

  private static final class Params {
    public final String table;

    public final String row;

    public final String family;

    public final String qualifier;

    public Params(String table, String row, String family, String qualifier) {
      this.table = table;
      this.row = row;
      this.family = family;
      this.qualifier = qualifier;
    }
  }

  private static final class RequestHandler extends SimpleChannelInboundHandler<FullHttpRequest> {

    private final AsyncConnection conn;

    private final ChannelGroup channelGroup;

    public RequestHandler(AsyncConnection conn, ChannelGroup channelGroup) {
      this.conn = conn;
      this.channelGroup = channelGroup;
    }

    @Override
    public void channelActive(ChannelHandlerContext ctx) {
      channelGroup.add(ctx.channel());
      ctx.fireChannelActive();
    }

    @Override
    public void channelInactive(ChannelHandlerContext ctx) {
      channelGroup.remove(ctx.channel());
      ctx.fireChannelInactive();
    }

    private void write(ChannelHandlerContext ctx, HttpResponseStatus status,
        Optional<String> content) {
      DefaultFullHttpResponse resp;
      if (content.isPresent()) {
        ByteBuf buf =
            ctx.alloc().buffer().writeBytes(Bytes.toBytes(content.get()));
        resp = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, status, buf);
        resp.headers().set(HttpHeaderNames.CONTENT_LENGTH, buf.readableBytes());
      } else {
        resp = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, status);
      }
      resp.headers().set(HttpHeaderNames.CONTENT_TYPE, "text-plain; charset=UTF-8");
      ctx.writeAndFlush(resp);
    }

    private Params parse(FullHttpRequest req) {
      String[] components = new QueryStringDecoder(req.uri()).path().split("/");
      Preconditions.checkArgument(components.length == 4, "Unrecognized uri: %s", req.uri());
      // path is start with '/' so split will give an empty component
      String[] cfAndCq = components[3].split(":");
      Preconditions.checkArgument(cfAndCq.length == 2, "Unrecognized uri: %s", req.uri());
      return new Params(components[1], components[2], cfAndCq[0], cfAndCq[1]);
    }

    private void get(ChannelHandlerContext ctx, FullHttpRequest req) {
      Params params = parse(req);
      addListener(
        conn.getTable(TableName.valueOf(params.table)).get(new Get(Bytes.toBytes(params.row))
          .addColumn(Bytes.toBytes(params.family), Bytes.toBytes(params.qualifier))),
        (r, e) -> {
          if (e != null) {
            exceptionCaught(ctx, e);
          } else {
            byte[] value =
              r.getValue(Bytes.toBytes(params.family), Bytes.toBytes(params.qualifier));
            if (value != null) {
              write(ctx, HttpResponseStatus.OK, Optional.of(Bytes.toStringBinary(value)));
            } else {
              write(ctx, HttpResponseStatus.NOT_FOUND, Optional.empty());
            }
          }
        });
    }

    private void put(ChannelHandlerContext ctx, FullHttpRequest req) {
      Params params = parse(req);
      byte[] value = new byte[req.content().readableBytes()];
      req.content().readBytes(value);
      addListener(
        conn.getTable(TableName.valueOf(params.table)).put(new Put(Bytes.toBytes(params.row))
          .addColumn(Bytes.toBytes(params.family), Bytes.toBytes(params.qualifier), value)),
        (r, e) -> {
          if (e != null) {
            exceptionCaught(ctx, e);
          } else {
            write(ctx, HttpResponseStatus.OK, Optional.empty());
          }
        });
    }

    @Override
    protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest req) {
      switch (req.method().name()) {
        case "GET":
          get(ctx, req);
          break;
        case "PUT":
          put(ctx, req);
          break;
        default:
          write(ctx, HttpResponseStatus.METHOD_NOT_ALLOWED, Optional.empty());
          break;
      }
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
      if (cause instanceof IllegalArgumentException) {
        write(ctx, HttpResponseStatus.BAD_REQUEST, Optional.of(cause.getMessage()));
      } else {
        write(ctx, HttpResponseStatus.INTERNAL_SERVER_ERROR,
          Optional.of(Throwables.getStackTraceAsString(cause)));
      }
    }
  }

  public void start() throws InterruptedException, ExecutionException {
    NettyRpcClientConfigHelper.setEventLoopConfig(conf, workerGroup, NioSocketChannel.class);
    conn = ConnectionFactory.createAsyncConnection(conf).get();
    channelGroup = new DefaultChannelGroup(GlobalEventExecutor.INSTANCE);
    serverChannel = new ServerBootstrap().group(bossGroup, workerGroup)
        .channel(NioServerSocketChannel.class).childOption(ChannelOption.TCP_NODELAY, true)
        .childHandler(new ChannelInitializer<Channel>() {

          @Override
          protected void initChannel(Channel ch) throws Exception {
            ch.pipeline().addFirst(new HttpServerCodec(), new HttpObjectAggregator(4 * 1024 * 1024),
              new RequestHandler(conn, channelGroup));
          }
        }).bind(port).syncUninterruptibly().channel();
  }

  public void join() {
    serverChannel.closeFuture().awaitUninterruptibly();
  }

  public int port() {
    if (serverChannel == null) {
      return port;
    } else {
      return ((InetSocketAddress) serverChannel.localAddress()).getPort();
    }
  }

  public void stop() throws IOException {
    serverChannel.close().syncUninterruptibly();
    serverChannel = null;
    channelGroup.close().syncUninterruptibly();
    channelGroup = null;
    conn.close();
    conn = null;
  }

  public static void main(String[] args) throws InterruptedException, ExecutionException {
    int port = Integer.parseInt(args[0]);
    HttpProxyExample proxy = new HttpProxyExample(HBaseConfiguration.create(), port);
    proxy.start();
    proxy.join();
  }
}
/**
 *
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
package org.apache.hadoop.hbase.client.example;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.Future;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.Cell.Type;
import org.apache.hadoop.hbase.CellBuilderFactory;
import org.apache.hadoop.hbase.CellBuilderType;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.RegionLocator;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.filter.KeyOnlyFilter;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.hbase.thirdparty.com.google.common.util.concurrent.ThreadFactoryBuilder;

/**
 * Example on how to use HBase's {@link Connection} and {@link Table} in a
 * multi-threaded environment. Each table is a light weight object
 * that is created and thrown away. Connections are heavy weight objects
 * that hold on to zookeeper connections, async processes, and other state.
 *
 * <pre>
 * Usage:
 * bin/hbase org.apache.hadoop.hbase.client.example.MultiThreadedClientExample testTableName 500000
 * </pre>
 *
 * <p>
 * The table should already be created before running the command.
 * This example expects one column family named d.
 * </p>
 * <p>
 * This is meant to show different operations that are likely to be
 * done in a real world application. These operations are:
 * </p>
 *
 * <ul>
 *   <li>
 *     30% of all operations performed are batch writes.
 *     30 puts are created and sent out at a time.
 *     The response for all puts is waited on.
 *   </li>
 *   <li>
 *     20% of all operations are single writes.
 *     A single put is sent out and the response is waited for.
 *   </li>
 *   <li>
 *     50% of all operations are scans.
 *     These scans start at a random place and scan up to 100 rows.
 *   </li>
 * </ul>
 *
 */
@InterfaceAudience.Private
public class MultiThreadedClientExample extends Configured implements Tool {
  private static final Logger LOG = LoggerFactory.getLogger(MultiThreadedClientExample.class);
  private static final int DEFAULT_NUM_OPERATIONS = 500000;

  /**
   * The name of the column family.
   *
   * d for default.
   */
  private static final byte[] FAMILY = Bytes.toBytes("d");

  /**
   * For the example we're just using one qualifier.
   */
  private static final byte[] QUAL = Bytes.toBytes("test");

  private final ExecutorService internalPool;

  private final int threads;

  public MultiThreadedClientExample() throws IOException {
    // Base number of threads.
    // This represents the number of threads you application has
    // that can be interacting with an hbase client.
    this.threads = Runtime.getRuntime().availableProcessors() * 4;

    // Daemon threads are great for things that get shut down.
    ThreadFactory threadFactory = new ThreadFactoryBuilder()
        .setDaemon(true).setNameFormat("internal-pol-%d").build();


    this.internalPool = Executors.newFixedThreadPool(threads, threadFactory);
  }

  @Override
  public int run(String[] args) throws Exception {

    if (args.length < 1 || args.length > 2) {
      System.out.println("Usage: " + this.getClass().getName() + " tableName [num_operations]");
      return -1;
    }

    final TableName tableName = TableName.valueOf(args[0]);
    int numOperations = DEFAULT_NUM_OPERATIONS;

    // the second arg is the number of operations to send.
    if (args.length == 2) {
      numOperations = Integer.parseInt(args[1]);
    }

    // Threads for the client only.
    //
    // We don't want to mix hbase and business logic.
    //
    ExecutorService service = new ForkJoinPool(threads * 2);

    // Create two different connections showing how it's possible to
    // separate different types of requests onto different connections
    final Connection writeConnection = ConnectionFactory.createConnection(getConf(), service);
    final Connection readConnection = ConnectionFactory.createConnection(getConf(), service);

    // At this point the entire cache for the region locations is full.
    // Only do this if the number of regions in a table is easy to fit into memory.
    //
    // If you are interacting with more than 25k regions on a client then it's probably not good
    // to do this at all.
    warmUpConnectionCache(readConnection, tableName);
    warmUpConnectionCache(writeConnection, tableName);

    List<Future<Boolean>> futures = new ArrayList<>(numOperations);
    for (int i = 0; i < numOperations; i++) {
      double r = ThreadLocalRandom.current().nextDouble();
      Future<Boolean> f;

      // For the sake of generating some synthetic load this queues
      // some different callables.
      // These callables are meant to represent real work done by your application.
      if (r < .30) {
        f = internalPool.submit(new WriteExampleCallable(writeConnection, tableName));
      } else if (r < .50) {
        f = internalPool.submit(new SingleWriteExampleCallable(writeConnection, tableName));
      } else {
        f = internalPool.submit(new ReadExampleCallable(writeConnection, tableName));
      }
      futures.add(f);
    }

    // Wait a long time for all the reads/writes to complete
    for (Future<Boolean> f : futures) {
      f.get(10, TimeUnit.MINUTES);
    }

    // Clean up after our selves for cleanliness
    internalPool.shutdownNow();
    service.shutdownNow();
    return 0;
  }

  private void warmUpConnectionCache(Connection connection, TableName tn) throws IOException {
    try (RegionLocator locator = connection.getRegionLocator(tn)) {
      LOG.info(
          "Warmed up region location cache for " + tn
              + " got " + locator.getAllRegionLocations().size());
    }
  }

  /**
   * Class that will show how to send batches of puts at the same time.
   */
  public static class WriteExampleCallable implements Callable<Boolean> {
    private final Connection connection;
    private final TableName tableName;

    public WriteExampleCallable(Connection connection, TableName tableName) {
      this.connection = connection;
      this.tableName = tableName;
    }

    @Override
    public Boolean call() throws Exception {

      // Table implements Closable so we use the try with resource structure here.
      // https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html
      try (Table t = connection.getTable(tableName)) {
        byte[] value = Bytes.toBytes(Double.toString(ThreadLocalRandom.current().nextDouble()));
        int rows = 30;

        // Array to put the batch
        ArrayList<Put> puts = new ArrayList<>(rows);
        for (int i = 0; i < 30; i++) {
          byte[] rk = Bytes.toBytes(ThreadLocalRandom.current().nextLong());
          Put p = new Put(rk);
          p.add(CellBuilderFactory.create(CellBuilderType.SHALLOW_COPY)
                .setRow(rk)
                .setFamily(FAMILY)
                .setQualifier(QUAL)
                .setTimestamp(p.getTimestamp())
                .setType(Cell.Type.Put)
                .setValue(value)
                .build());
          puts.add(p);
        }

        // now that we've assembled the batch it's time to push it to hbase.
        t.put(puts);
      }
      return true;
    }
  }

  /**
   * Class to show how to send a single put.
   */
  public static class SingleWriteExampleCallable implements Callable<Boolean> {
    private final Connection connection;
    private final TableName tableName;

    public SingleWriteExampleCallable(Connection connection, TableName tableName) {
      this.connection = connection;
      this.tableName = tableName;
    }

    @Override
    public Boolean call() throws Exception {
      try (Table t = connection.getTable(tableName)) {

        byte[] value = Bytes.toBytes(Double.toString(ThreadLocalRandom.current().nextDouble()));
        byte[] rk = Bytes.toBytes(ThreadLocalRandom.current().nextLong());
        Put p = new Put(rk);
        p.add(CellBuilderFactory.create(CellBuilderType.SHALLOW_COPY)
                .setRow(rk)
                .setFamily(FAMILY)
                .setQualifier(QUAL)
                .setTimestamp(p.getTimestamp())
                .setType(Type.Put)
                .setValue(value)
                .build());
        t.put(p);
      }
      return true;
    }
  }


  /**
   * Class to show how to scan some rows starting at a random location.
   */
  public static class ReadExampleCallable implements Callable<Boolean> {
    private final Connection connection;
    private final TableName tableName;

    public ReadExampleCallable(Connection connection, TableName tableName) {
      this.connection = connection;
      this.tableName = tableName;
    }

    @Override
    public Boolean call() throws Exception {

      // total length in bytes of all read rows.
      int result = 0;

      // Number of rows the scan will read before being considered done.
      int toRead = 100;
      try (Table t = connection.getTable(tableName)) {
        byte[] rk = Bytes.toBytes(ThreadLocalRandom.current().nextLong());
        Scan s = new Scan(rk);

        // This filter will keep the values from being sent accross the wire.
        // This is good for counting or other scans that are checking for
        // existence and don't rely on the value.
        s.setFilter(new KeyOnlyFilter());

        // Don't go back to the server for every single row.
        // We know these rows are small. So ask for 20 at a time.
        // This would be application specific.
        //
        // The goal is to reduce round trips but asking for too
        // many rows can lead to GC problems on client and server sides.
        s.setCaching(20);

        // Don't use the cache. While this is a silly test program it's still good to be
        // explicit that scans normally don't use the block cache.
        s.setCacheBlocks(false);

        // Open up the scanner and close it automatically when done.
        try (ResultScanner rs = t.getScanner(s)) {

          // Now go through rows.
          for (Result r : rs) {
            // Keep track of things size to simulate doing some real work.
            result += r.getRow().length;
            toRead -= 1;

            // Most online applications won't be
            // reading the entire table so this break
            // simulates small to medium size scans,
            // without needing to know an end row.
            if (toRead <= 0)  {
              break;
            }
          }
        }
      }
      return result > 0;
    }
  }

  public static void main(String[] args) throws Exception {
    ToolRunner.run(new MultiThreadedClientExample(), args);
  }
}
/*
 *
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

package org.apache.hadoop.hbase.client.example;

import java.io.Closeable;
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.client.coprocessor.Batch;
import org.apache.hadoop.hbase.ipc.CoprocessorRpcUtils.BlockingRpcCallback;
import org.apache.hadoop.hbase.ipc.ServerRpcController;
import org.apache.hadoop.hbase.protobuf.generated.RefreshHFilesProtos;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * This client class is for invoking the refresh HFile function deployed on the
 * Region Server side via the RefreshHFilesService.
 */
@InterfaceAudience.Private
public class RefreshHFilesClient extends Configured implements Tool, Closeable {
  private static final Logger LOG = LoggerFactory.getLogger(RefreshHFilesClient.class);
  private final Connection connection;

  /**
   * Constructor with Conf object
   *
   * @param cfg
   */
  public RefreshHFilesClient(Configuration cfg) {
    try {
      this.connection = ConnectionFactory.createConnection(cfg);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void close() throws IOException {
    if (this.connection != null && !this.connection.isClosed()) {
      this.connection.close();
    }
  }

  public void refreshHFiles(final TableName tableName) throws Throwable {
    try (Table table = connection.getTable(tableName)) {
      refreshHFiles(table);
    }
  }

  public void refreshHFiles(final Table table) throws Throwable {
    final RefreshHFilesProtos.RefreshHFilesRequest request = RefreshHFilesProtos.RefreshHFilesRequest
                                                               .getDefaultInstance();
    table.coprocessorService(RefreshHFilesProtos.RefreshHFilesService.class, HConstants.EMPTY_START_ROW,
                             HConstants.EMPTY_END_ROW,
                             new Batch.Call<RefreshHFilesProtos.RefreshHFilesService,
                                             RefreshHFilesProtos.RefreshHFilesResponse>() {
                               @Override
                               public RefreshHFilesProtos.RefreshHFilesResponse call(
                                 RefreshHFilesProtos.RefreshHFilesService refreshHFilesService)
                                 throws IOException {
                                 ServerRpcController controller = new ServerRpcController();
                                 BlockingRpcCallback<RefreshHFilesProtos.RefreshHFilesResponse> rpcCallback =
                                   new BlockingRpcCallback<>();
                                 refreshHFilesService.refreshHFiles(controller, request, rpcCallback);
                                 if (controller.failedOnException()) {
                                   throw controller.getFailedOn();
                                 }
                                 return rpcCallback.get();
                               }
                             });
    LOG.debug("Done refreshing HFiles");
  }

  @Override
  public int run(String[] args) throws Exception {
    if (args.length != 1) {
      String message = "When there are multiple HBase clusters are sharing a common root dir, "
          + "especially for read replica cluster (see detail in HBASE-18477), please consider to "
          + "use this tool manually sync the flushed HFiles from the source cluster.";
      message += "\nUsage: " + this.getClass().getName() + " tableName";
      System.out.println(message);
      return -1;
    }
    final TableName tableName = TableName.valueOf(args[0]);
    try {
      refreshHFiles(tableName);
    } catch (Throwable t) {
      LOG.error("Refresh HFiles from table " + tableName.getNameAsString() + "  failed: ", t);
      return -1;
    }
    return 0;
  }

  public static void main(String[] args) throws Exception {
    ToolRunner.run(new RefreshHFilesClient(HBaseConfiguration.create()), args);
  }
}
/**
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
package org.apache.hadoop.hbase.client.example;

import static org.apache.hadoop.hbase.util.FutureUtils.addListener;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.IntStream;
import org.apache.commons.io.IOUtils;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.AsyncConnection;
import org.apache.hadoop.hbase.client.AsyncTable;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.util.Threads;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A simple example shows how to use asynchronous client.
 */
@InterfaceAudience.Private
public class AsyncClientExample extends Configured implements Tool {

  private static final Logger LOG = LoggerFactory.getLogger(AsyncClientExample.class);

  /**
   * The size for thread pool.
   */
  private static final int THREAD_POOL_SIZE = 16;

  /**
   * The default number of operations.
   */
  private static final int DEFAULT_NUM_OPS = 100;

  /**
   * The name of the column family. d for default.
   */
  private static final byte[] FAMILY = Bytes.toBytes("d");

  /**
   * For the example we're just using one qualifier.
   */
  private static final byte[] QUAL = Bytes.toBytes("test");

  private final AtomicReference<CompletableFuture<AsyncConnection>> future =
      new AtomicReference<>();

  private CompletableFuture<AsyncConnection> getConn() {
    CompletableFuture<AsyncConnection> f = future.get();
    if (f != null) {
      return f;
    }
    for (;;) {
      if (future.compareAndSet(null, new CompletableFuture<>())) {
        CompletableFuture<AsyncConnection> toComplete = future.get();
        addListener(ConnectionFactory.createAsyncConnection(getConf()),(conn, error) -> {
          if (error != null) {
            toComplete.completeExceptionally(error);
            // we need to reset the future holder so we will get a chance to recreate an async
            // connection at next try.
            future.set(null);
            return;
          }
          toComplete.complete(conn);
        });
        return toComplete;
      } else {
        f = future.get();
        if (f != null) {
          return f;
        }
      }
    }
  }

  @edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "NP_NONNULL_PARAM_VIOLATION",
      justification = "it is valid to pass NULL to CompletableFuture#completedFuture")
  private CompletableFuture<Void> closeConn() {
    CompletableFuture<AsyncConnection> f = future.get();
    if (f == null) {
      return CompletableFuture.completedFuture(null);
    }
    CompletableFuture<Void> closeFuture = new CompletableFuture<>();
    addListener(f, (conn, error) -> {
      if (error == null) {
        IOUtils.closeQuietly(conn);
      }
      closeFuture.complete(null);
    });
    return closeFuture;
  }

  private byte[] getKey(int i) {
    return Bytes.toBytes(String.format("%08x", i));
  }

  @Override
  public int run(String[] args) throws Exception {
    if (args.length < 1 || args.length > 2) {
      System.out.println("Usage: " + this.getClass().getName() + " tableName [num_operations]");
      return -1;
    }
    TableName tableName = TableName.valueOf(args[0]);
    int numOps = args.length > 1 ? Integer.parseInt(args[1]) : DEFAULT_NUM_OPS;
    ExecutorService threadPool = Executors.newFixedThreadPool(THREAD_POOL_SIZE,
      Threads.newDaemonThreadFactory("AsyncClientExample"));
    // We use AsyncTable here so we need to provide a separated thread pool. RawAsyncTable does not
    // need a thread pool and may have a better performance if you use it correctly as it can save
    // some context switches. But if you use RawAsyncTable incorrectly, you may have a very bad
    // impact on performance so use it with caution.
    CountDownLatch latch = new CountDownLatch(numOps);
    IntStream.range(0, numOps).forEach(i -> {
      CompletableFuture<AsyncConnection> future = getConn();
      addListener(future, (conn, error) -> {
        if (error != null) {
          LOG.warn("failed to get async connection for " + i, error);
          latch.countDown();
          return;
        }
        AsyncTable<?> table = conn.getTable(tableName, threadPool);
        addListener(table.put(new Put(getKey(i)).addColumn(FAMILY, QUAL, Bytes.toBytes(i))),
          (putResp, putErr) -> {
            if (putErr != null) {
              LOG.warn("put failed for " + i, putErr);
              latch.countDown();
              return;
            }
            LOG.info("put for " + i + " succeeded, try getting");
            addListener(table.get(new Get(getKey(i))), (result, getErr) -> {
              if (getErr != null) {
                LOG.warn("get failed for " + i);
                latch.countDown();
                return;
              }
              if (result.isEmpty()) {
                LOG.warn("get failed for " + i + ", server returns empty result");
              } else if (!result.containsColumn(FAMILY, QUAL)) {
                LOG.warn("get failed for " + i + ", the result does not contain " +
                  Bytes.toString(FAMILY) + ":" + Bytes.toString(QUAL));
              } else {
                int v = Bytes.toInt(result.getValue(FAMILY, QUAL));
                if (v != i) {
                  LOG.warn("get failed for " + i + ", the value of " + Bytes.toString(FAMILY) +
                    ":" + Bytes.toString(QUAL) + " is " + v + ", exected " + i);
                } else {
                  LOG.info("get for " + i + " succeeded");
                }
              }
              latch.countDown();
            });
          });
      });
    });
    latch.await();
    closeConn().get();
    return 0;
  }

  public static void main(String[] args) throws Exception {
    ToolRunner.run(new AsyncClientExample(), args);
  }
}
/**
 *
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
package org.apache.hadoop.hbase.client.example;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.BufferedMutator;
import org.apache.hadoop.hbase.client.BufferedMutatorParams;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.RetriesExhaustedWithDetailsException;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * An example of using the {@link BufferedMutator} interface.
 */
@InterfaceAudience.Private
public class BufferedMutatorExample extends Configured implements Tool {

  private static final Logger LOG = LoggerFactory.getLogger(BufferedMutatorExample.class);

  private static final int POOL_SIZE = 10;
  private static final int TASK_COUNT = 100;
  private static final TableName TABLE = TableName.valueOf("foo");
  private static final byte[] FAMILY = Bytes.toBytes("f");

  @Override
  public int run(String[] args) throws InterruptedException, ExecutionException, TimeoutException {

    /** a callback invoked when an asynchronous write fails. */
    final BufferedMutator.ExceptionListener listener = new BufferedMutator.ExceptionListener() {
      @Override
      public void onException(RetriesExhaustedWithDetailsException e, BufferedMutator mutator) {
        for (int i = 0; i < e.getNumExceptions(); i++) {
          LOG.info("Failed to sent put " + e.getRow(i) + ".");
        }
      }
    };
    BufferedMutatorParams params = new BufferedMutatorParams(TABLE)
        .listener(listener);

    //
    // step 1: create a single Connection and a BufferedMutator, shared by all worker threads.
    //
    try (final Connection conn = ConnectionFactory.createConnection(getConf());
         final BufferedMutator mutator = conn.getBufferedMutator(params)) {

      /** worker pool that operates on BufferedTable instances */
      final ExecutorService workerPool = Executors.newFixedThreadPool(POOL_SIZE);
      List<Future<Void>> futures = new ArrayList<>(TASK_COUNT);

      for (int i = 0; i < TASK_COUNT; i++) {
        futures.add(workerPool.submit(new Callable<Void>() {
          @Override
          public Void call() throws Exception {
            //
            // step 2: each worker sends edits to the shared BufferedMutator instance. They all use
            // the same backing buffer, call-back "listener", and RPC executor pool.
            //
            Put p = new Put(Bytes.toBytes("someRow"));
            p.addColumn(FAMILY, Bytes.toBytes("someQualifier"), Bytes.toBytes("some value"));
            mutator.mutate(p);
            // do work... maybe you want to call mutator.flush() after many edits to ensure any of
            // this worker's edits are sent before exiting the Callable
            return null;
          }
        }));
      }

      //
      // step 3: clean up the worker pool, shut down.
      //
      for (Future<Void> f : futures) {
        f.get(5, TimeUnit.MINUTES);
      }
      workerPool.shutdown();
    } catch (IOException e) {
      // exception while creating/destroying Connection or BufferedMutator
      LOG.info("exception while creating/destroying Connection or BufferedMutator", e);
    } // BufferedMutator.close() ensures all work is flushed. Could be the custom listener is
      // invoked from here.
    return 0;
  }

  public static void main(String[] args) throws Exception {
    ToolRunner.run(new BufferedMutatorExample(), args);
  }
}
/**
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
package org.apache.hadoop.hbase.client.example;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Admin;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.client.TableDescriptor;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.coprocessor.Export;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * A simple example on how to use {@link org.apache.hadoop.hbase.coprocessor.Export}.
 *
 * <p>
 * For the protocol buffer definition of the ExportService, see the source file located under
 * hbase-endpoint/src/main/protobuf/Export.proto.
 * </p>
 */
@InterfaceAudience.Private
public final class ExportEndpointExample {

  public static void main(String[] args) throws Throwable {
    int rowCount = 100;
    byte[] family = Bytes.toBytes("family");
    Configuration conf = HBaseConfiguration.create();
    TableName tableName = TableName.valueOf("ExportEndpointExample");
    try (Connection con = ConnectionFactory.createConnection(conf);
         Admin admin = con.getAdmin()) {
      TableDescriptor desc = TableDescriptorBuilder.newBuilder(tableName)
              // MUST mount the export endpoint
              .setCoprocessor(Export.class.getName())
              .setColumnFamily(ColumnFamilyDescriptorBuilder.of(family))
              .build();
      admin.createTable(desc);

      List<Put> puts = new ArrayList<>(rowCount);
      for (int row = 0; row != rowCount; ++row) {
        byte[] bs = Bytes.toBytes(row);
        Put put = new Put(bs);
        put.addColumn(family, bs, bs);
        puts.add(put);
      }
      try (Table table = con.getTable(tableName)) {
        table.put(puts);
      }

      Path output = new Path("/tmp/ExportEndpointExample_output");
      Scan scan = new Scan();
      Map<byte[], Export.Response> result = Export.run(conf, tableName, scan, output);
      final long totalOutputRows = result.values().stream().mapToLong(v -> v.getRowCount()).sum();
      final long totalOutputCells = result.values().stream().mapToLong(v -> v.getCellCount()).sum();
      System.out.println("table:" + tableName);
      System.out.println("output:" + output);
      System.out.println("total rows:" + totalOutputRows);
      System.out.println("total cells:" + totalOutputCells);
    }
  }

  private ExportEndpointExample(){}
}
/**
 *
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
package org.apache.hadoop.hbase.thrift;

import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.security.PrivilegedExceptionAction;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;
import javax.security.auth.Subject;
import javax.security.auth.login.AppConfigurationEntry;
import javax.security.auth.login.Configuration;
import javax.security.auth.login.LoginContext;
import org.apache.hadoop.hbase.thrift.generated.AlreadyExists;
import org.apache.hadoop.hbase.thrift.generated.ColumnDescriptor;
import org.apache.hadoop.hbase.thrift.generated.Hbase;
import org.apache.hadoop.hbase.thrift.generated.TCell;
import org.apache.hadoop.hbase.thrift.generated.TRowResult;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.THttpClient;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
import org.apache.yetus.audience.InterfaceAudience;
import org.ietf.jgss.GSSContext;
import org.ietf.jgss.GSSCredential;
import org.ietf.jgss.GSSException;
import org.ietf.jgss.GSSManager;
import org.ietf.jgss.GSSName;
import org.ietf.jgss.Oid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * See the instructions under hbase-examples/README.txt
 */
@InterfaceAudience.Private
public class HttpDoAsClient {
  private static final Logger LOG = LoggerFactory.getLogger(HttpDoAsClient.class);

  static protected int port;
  static protected String host;
  CharsetDecoder decoder = null;
  private static boolean secure = false;
  static protected String doAsUser = null;
  static protected String principal = null;

  public static void main(String[] args) throws Exception {

    if (args.length < 3 || args.length > 4) {

      System.out.println("Invalid arguments!");
      System.out.println("Usage: HttpDoAsClient host port doAsUserName [security=true]");
      System.exit(-1);
    }

    host = args[0];
    port = Integer.parseInt(args[1]);
    doAsUser = args[2];
    if (args.length > 3) {
      secure = Boolean.parseBoolean(args[3]);
      principal = getSubject().getPrincipals().iterator().next().getName();
    }

    final HttpDoAsClient client = new HttpDoAsClient();
    Subject.doAs(getSubject(),
        new PrivilegedExceptionAction<Void>() {
          @Override
          public Void run() throws Exception {
            client.run();
            return null;
          }
        });
  }

  HttpDoAsClient() {
    decoder = Charset.forName("UTF-8").newDecoder();
  }

  // Helper to translate byte[]'s to UTF8 strings
  private String utf8(byte[] buf) {
    try {
      return decoder.decode(ByteBuffer.wrap(buf)).toString();
    } catch (CharacterCodingException e) {
      return "[INVALID UTF-8]";
    }
  }

  // Helper to translate strings to UTF8 bytes
  private byte[] bytes(String s) {
    return Bytes.toBytes(s);
  }

  private void run() throws Exception {
    TTransport transport = new TSocket(host, port);

    transport.open();
    String url = "http://" + host + ":" + port;
    THttpClient httpClient = new THttpClient(url);
    httpClient.open();
    TProtocol protocol = new TBinaryProtocol(httpClient);
    Hbase.Client client = new Hbase.Client(protocol);

    byte[] t = bytes("demo_table");

    //
    // Scan all tables, look for the demo table and delete it.
    //
    System.out.println("scanning tables...");
    for (ByteBuffer name : refresh(client, httpClient).getTableNames()) {
      System.out.println("  found: " + utf8(name.array()));
      if (utf8(name.array()).equals(utf8(t))) {
        if (refresh(client, httpClient).isTableEnabled(name)) {
          System.out.println("    disabling table: " + utf8(name.array()));
          refresh(client, httpClient).disableTable(name);
        }
        System.out.println("    deleting table: " + utf8(name.array()));
        refresh(client, httpClient).deleteTable(name);
      }
    }



    //
    // Create the demo table with two column families, entry: and unused:
    //
    ArrayList<ColumnDescriptor> columns = new ArrayList<>(2);
    ColumnDescriptor col;
    col = new ColumnDescriptor();
    col.name = ByteBuffer.wrap(bytes("entry:"));
    col.timeToLive = Integer.MAX_VALUE;
    col.maxVersions = 10;
    columns.add(col);
    col = new ColumnDescriptor();
    col.name = ByteBuffer.wrap(bytes("unused:"));
    col.timeToLive = Integer.MAX_VALUE;
    columns.add(col);

    System.out.println("creating table: " + utf8(t));
    try {

      refresh(client, httpClient).createTable(ByteBuffer.wrap(t), columns);
    } catch (AlreadyExists ae) {
      System.out.println("WARN: " + ae.message);
    }

    System.out.println("column families in " + utf8(t) + ": ");
    Map<ByteBuffer, ColumnDescriptor> columnMap = refresh(client, httpClient)
        .getColumnDescriptors(ByteBuffer.wrap(t));
    for (ColumnDescriptor col2 : columnMap.values()) {
      System.out.println("  column: " + utf8(col2.name.array()) + ", maxVer: " + Integer.toString(col2.maxVersions));
    }

    transport.close();
    httpClient.close();
  }

  private Hbase.Client refresh(Hbase.Client client, THttpClient httpClient) {
    httpClient.setCustomHeader("doAs", doAsUser);
    if(secure) {
      try {
        httpClient.setCustomHeader("Authorization", generateTicket());
      } catch (GSSException e) {
        LOG.error("Kerberos authentication failed", e);
      }
    }
    return client;
  }

  private String generateTicket() throws GSSException {
    final GSSManager manager = GSSManager.getInstance();
    // Oid for kerberos principal name
    Oid krb5PrincipalOid = new Oid("1.2.840.113554.1.2.2.1");
    Oid KERB_V5_OID = new Oid("1.2.840.113554.1.2.2");
    final GSSName clientName = manager.createName(principal,
        krb5PrincipalOid);
    final GSSCredential clientCred = manager.createCredential(clientName,
        8 * 3600,
        KERB_V5_OID,
        GSSCredential.INITIATE_ONLY);

    final GSSName serverName = manager.createName(principal, krb5PrincipalOid);

    final GSSContext context = manager.createContext(serverName,
        KERB_V5_OID,
        clientCred,
        GSSContext.DEFAULT_LIFETIME);
    context.requestMutualAuth(true);
    context.requestConf(false);
    context.requestInteg(true);

    final byte[] outToken = context.initSecContext(new byte[0], 0, 0);
    StringBuffer outputBuffer = new StringBuffer();
    outputBuffer.append("Negotiate ");
    outputBuffer.append(Bytes.toString(Base64.getEncoder().encode(outToken)));
    System.out.print("Ticket is: " + outputBuffer);
    return outputBuffer.toString();
  }

  private void printVersions(ByteBuffer row, List<TCell> versions) {
    StringBuilder rowStr = new StringBuilder();
    for (TCell cell : versions) {
      rowStr.append(utf8(cell.value.array()));
      rowStr.append("; ");
    }
    System.out.println("row: " + utf8(row.array()) + ", values: " + rowStr);
  }

  private void printRow(TRowResult rowResult) {
    // copy values into a TreeMap to get them in sorted order

    TreeMap<String, TCell> sorted = new TreeMap<>();
    for (Map.Entry<ByteBuffer, TCell> column : rowResult.columns.entrySet()) {
      sorted.put(utf8(column.getKey().array()), column.getValue());
    }

    StringBuilder rowStr = new StringBuilder();
    for (SortedMap.Entry<String, TCell> entry : sorted.entrySet()) {
      rowStr.append(entry.getKey());
      rowStr.append(" => ");
      rowStr.append(utf8(entry.getValue().value.array()));
      rowStr.append("; ");
    }
    System.out.println("row: " + utf8(rowResult.row.array()) + ", cols: " + rowStr);
  }

  static Subject getSubject() throws Exception {
    if (!secure) return new Subject();
    /*
     * To authenticate the DemoClient, kinit should be invoked ahead.
     * Here we try to get the Kerberos credential from the ticket cache.
     */
    LoginContext context = new LoginContext("", new Subject(), null,
        new Configuration() {
          @Override
          public AppConfigurationEntry[] getAppConfigurationEntry(String name) {
            Map<String, String> options = new HashMap<>();
            options.put("useKeyTab", "false");
            options.put("storeKey", "false");
            options.put("doNotPrompt", "true");
            options.put("useTicketCache", "true");
            options.put("renewTGT", "true");
            options.put("refreshKrb5Config", "true");
            options.put("isInitiator", "true");
            String ticketCache = System.getenv("KRB5CCNAME");
            if (ticketCache != null) {
              options.put("ticketCache", ticketCache);
            }
            options.put("debug", "true");

            return new AppConfigurationEntry[]{
                new AppConfigurationEntry("com.sun.security.auth.module.Krb5LoginModule",
                    AppConfigurationEntry.LoginModuleControlFlag.REQUIRED,
                    options)};
          }
        });
    context.login();
    return context.getSubject();
  }
}
/**
 *
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
package org.apache.hadoop.hbase.thrift;

import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.security.PrivilegedExceptionAction;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;
import javax.security.auth.Subject;
import javax.security.auth.login.AppConfigurationEntry;
import javax.security.auth.login.Configuration;
import javax.security.auth.login.LoginContext;
import javax.security.sasl.Sasl;
import org.apache.hadoop.hbase.thrift.generated.AlreadyExists;
import org.apache.hadoop.hbase.thrift.generated.ColumnDescriptor;
import org.apache.hadoop.hbase.thrift.generated.Hbase;
import org.apache.hadoop.hbase.thrift.generated.Mutation;
import org.apache.hadoop.hbase.thrift.generated.TCell;
import org.apache.hadoop.hbase.thrift.generated.TRowResult;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSaslClientTransport;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * See the instructions under hbase-examples/README.txt
 */
@InterfaceAudience.Private
public class DemoClient {
  private static final Logger LOG = LoggerFactory.getLogger(DemoClient.class);

  static protected int port;
  static protected String host;
  CharsetDecoder decoder = null;

  private static boolean secure = false;
  private static String serverPrincipal = "hbase";

  public static void main(String[] args) throws Exception {
    if (args.length < 2 || args.length > 4 || (args.length > 2 && !isBoolean(args[2]))) {
      System.out.println("Invalid arguments!");
      System.out.println("Usage: DemoClient host port [secure=false [server-principal=hbase] ]");

      System.exit(-1);
    }

    port = Integer.parseInt(args[1]);
    host = args[0];

    if (args.length > 2) {
      secure = Boolean.parseBoolean(args[2]);
    }

    if (args.length == 4) {
      serverPrincipal = args[3];
    }

    final DemoClient client = new DemoClient();
    Subject.doAs(getSubject(),
      new PrivilegedExceptionAction<Void>() {
        @Override
        public Void run() throws Exception {
          client.run();
          return null;
        }
      });
  }

  private static boolean isBoolean(String s){
    return Boolean.TRUE.toString().equalsIgnoreCase(s) ||
            Boolean.FALSE.toString().equalsIgnoreCase(s);
  }

  DemoClient() {
    decoder = Charset.forName("UTF-8").newDecoder();
  }

  // Helper to translate byte[]'s to UTF8 strings
  private String utf8(byte[] buf) {
    try {
      return decoder.decode(ByteBuffer.wrap(buf)).toString();
    } catch (CharacterCodingException e) {
      return "[INVALID UTF-8]";
    }
  }

  // Helper to translate strings to UTF8 bytes
  private byte[] bytes(String s) {
    return Bytes.toBytes(s);
  }

  private void run() throws Exception {
    TTransport transport = new TSocket(host, port);
    if (secure) {
      Map<String, String> saslProperties = new HashMap<>();
      saslProperties.put(Sasl.QOP, "auth-conf,auth-int,auth");
      /*
       * The Thrift server the DemoClient is trying to connect to
       * must have a matching principal, and support authentication.
       *
       * The HBase cluster must be secure, allow proxy user.
       */
      transport = new TSaslClientTransport("GSSAPI", null,
              serverPrincipal, // Thrift server user name, should be an authorized proxy user.
              host, // Thrift server domain
              saslProperties, null, transport);
    }

    transport.open();

    TProtocol protocol = new TBinaryProtocol(transport, true, true);
    Hbase.Client client = new Hbase.Client(protocol);

    byte[] t = bytes("demo_table");

    // Scan all tables, look for the demo table and delete it.
    System.out.println("scanning tables...");

    for (ByteBuffer name : client.getTableNames()) {
      System.out.println("  found: " + utf8(name.array()));

      if (utf8(name.array()).equals(utf8(t))) {
        if (client.isTableEnabled(name)) {
          System.out.println("    disabling table: " + utf8(name.array()));
          client.disableTable(name);
        }

        System.out.println("    deleting table: " + utf8(name.array()));
        client.deleteTable(name);
      }
    }

    // Create the demo table with two column families, entry: and unused:
    ArrayList<ColumnDescriptor> columns = new ArrayList<>(2);
    ColumnDescriptor col;
    col = new ColumnDescriptor();
    col.name = ByteBuffer.wrap(bytes("entry:"));
    col.timeToLive = Integer.MAX_VALUE;
    col.maxVersions = 10;
    columns.add(col);
    col = new ColumnDescriptor();
    col.name = ByteBuffer.wrap(bytes("unused:"));
    col.timeToLive = Integer.MAX_VALUE;
    columns.add(col);

    System.out.println("creating table: " + utf8(t));

    try {
      client.createTable(ByteBuffer.wrap(t), columns);
    } catch (AlreadyExists ae) {
      System.out.println("WARN: " + ae.message);
    }

    System.out.println("column families in " + utf8(t) + ": ");
    Map<ByteBuffer, ColumnDescriptor> columnMap = client.getColumnDescriptors(ByteBuffer.wrap(t));

    for (ColumnDescriptor col2 : columnMap.values()) {
      System.out.println("  column: " + utf8(col2.name.array()) + ", maxVer: " + col2.maxVersions);
    }

    Map<ByteBuffer, ByteBuffer> dummyAttributes = null;
    boolean writeToWal = false;

    // Test UTF-8 handling
    byte[] invalid = {(byte) 'f', (byte) 'o', (byte) 'o', (byte) '-',
            (byte) 0xfc, (byte) 0xa1, (byte) 0xa1, (byte) 0xa1, (byte) 0xa1};
    byte[] valid = {(byte) 'f', (byte) 'o', (byte) 'o', (byte) '-',
            (byte) 0xE7, (byte) 0x94, (byte) 0x9F, (byte) 0xE3, (byte) 0x83,
            (byte) 0x93, (byte) 0xE3, (byte) 0x83, (byte) 0xBC, (byte) 0xE3,
            (byte) 0x83, (byte) 0xAB};

    ArrayList<Mutation> mutations;
    // non-utf8 is fine for data
    mutations = new ArrayList<>(1);
    mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:foo")),
            ByteBuffer.wrap(invalid), writeToWal));
    client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(bytes("foo")),
            mutations, dummyAttributes);

    // this row name is valid utf8
    mutations = new ArrayList<>(1);
    mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:foo")),
            ByteBuffer.wrap(valid), writeToWal));
    client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(valid), mutations, dummyAttributes);

    // non-utf8 is now allowed in row names because HBase stores values as binary
    mutations = new ArrayList<>(1);
    mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:foo")),
            ByteBuffer.wrap(invalid), writeToWal));
    client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(invalid), mutations, dummyAttributes);

    // Run a scanner on the rows we just created
    ArrayList<ByteBuffer> columnNames = new ArrayList<>();
    columnNames.add(ByteBuffer.wrap(bytes("entry:")));

    System.out.println("Starting scanner...");
    int scanner = client.scannerOpen(ByteBuffer.wrap(t), ByteBuffer.wrap(bytes("")), columnNames,
            dummyAttributes);

    while (true) {
      List<TRowResult> entry = client.scannerGet(scanner);

      if (entry.isEmpty()) {
        break;
      }

      printRow(entry);
    }

    // Run some operations on a bunch of rows
    for (int i = 100; i >= 0; --i) {
      // format row keys as "00000" to "00100"
      NumberFormat nf = NumberFormat.getInstance();
      nf.setMinimumIntegerDigits(5);
      nf.setGroupingUsed(false);
      byte[] row = bytes(nf.format(i));

      mutations = new ArrayList<>(1);
      mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("unused:")),
              ByteBuffer.wrap(bytes("DELETE_ME")), writeToWal));
      client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), mutations, dummyAttributes);
      printRow(client.getRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), dummyAttributes));
      client.deleteAllRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), dummyAttributes);

      // sleep to force later timestamp
      try {
        Thread.sleep(50);
      } catch (InterruptedException e) {
        // no-op
      }

      mutations = new ArrayList<>(2);
      mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:num")),
              ByteBuffer.wrap(bytes("0")), writeToWal));
      mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:foo")),
              ByteBuffer.wrap(bytes("FOO")), writeToWal));
      client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), mutations, dummyAttributes);
      printRow(client.getRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), dummyAttributes));

      Mutation m;
      mutations = new ArrayList<>(2);
      m = new Mutation();
      m.column = ByteBuffer.wrap(bytes("entry:foo"));
      m.isDelete = true;
      mutations.add(m);
      m = new Mutation();
      m.column = ByteBuffer.wrap(bytes("entry:num"));
      m.value = ByteBuffer.wrap(bytes("-1"));
      mutations.add(m);
      client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), mutations, dummyAttributes);
      printRow(client.getRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), dummyAttributes));

      mutations = new ArrayList<>();
      mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:num")),
              ByteBuffer.wrap(bytes(Integer.toString(i))), writeToWal));
      mutations.add(new Mutation(false, ByteBuffer.wrap(bytes("entry:sqr")),
              ByteBuffer.wrap(bytes(Integer.toString(i * i))), writeToWal));
      client.mutateRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), mutations, dummyAttributes);
      printRow(client.getRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), dummyAttributes));

      // sleep to force later timestamp
      try {
        Thread.sleep(50);
      } catch (InterruptedException e) {
        // no-op
      }

      mutations.clear();
      m = new Mutation();
      m.column = ByteBuffer.wrap(bytes("entry:num"));
      m.value= ByteBuffer.wrap(bytes("-999"));
      mutations.add(m);
      m = new Mutation();
      m.column = ByteBuffer.wrap(bytes("entry:sqr"));
      m.isDelete = true;
      client.mutateRowTs(ByteBuffer.wrap(t), ByteBuffer.wrap(row), mutations, 1,
              dummyAttributes); // shouldn't override latest
      printRow(client.getRow(ByteBuffer.wrap(t), ByteBuffer.wrap(row), dummyAttributes));

      List<TCell> versions = client.getVer(ByteBuffer.wrap(t), ByteBuffer.wrap(row),
              ByteBuffer.wrap(bytes("entry:num")), 10, dummyAttributes);
      printVersions(ByteBuffer.wrap(row), versions);

      if (versions.isEmpty()) {
        System.out.println("FATAL: wrong # of versions");
        System.exit(-1);
      }

      List<TCell> result = client.get(ByteBuffer.wrap(t), ByteBuffer.wrap(row),
              ByteBuffer.wrap(bytes("entry:foo")), dummyAttributes);

      if (!result.isEmpty()) {
        System.out.println("FATAL: shouldn't get here");
        System.exit(-1);
      }

      System.out.println("");
    }

    // scan all rows/columnNames
    columnNames.clear();

    for (ColumnDescriptor col2 : client.getColumnDescriptors(ByteBuffer.wrap(t)).values()) {
      System.out.println("column with name: " + new String(col2.name.array()));
      System.out.println(col2.toString());

      columnNames.add(col2.name);
    }

    System.out.println("Starting scanner...");
    scanner = client.scannerOpenWithStop(ByteBuffer.wrap(t), ByteBuffer.wrap(bytes("00020")),
            ByteBuffer.wrap(bytes("00040")), columnNames, dummyAttributes);

    while (true) {
      List<TRowResult> entry = client.scannerGet(scanner);

      if (entry.isEmpty()) {
        System.out.println("Scanner finished");
        break;
      }

      printRow(entry);
    }

    transport.close();
  }

  private void printVersions(ByteBuffer row, List<TCell> versions) {
    StringBuilder rowStr = new StringBuilder();

    for (TCell cell : versions) {
      rowStr.append(utf8(cell.value.array()));
      rowStr.append("; ");
    }

    System.out.println("row: " + utf8(row.array()) + ", values: " + rowStr);
  }

  private void printRow(TRowResult rowResult) {
    // copy values into a TreeMap to get them in sorted order
    TreeMap<String, TCell> sorted = new TreeMap<>();

    for (Map.Entry<ByteBuffer, TCell> column : rowResult.columns.entrySet()) {
      sorted.put(utf8(column.getKey().array()), column.getValue());
    }

    StringBuilder rowStr = new StringBuilder();

    for (SortedMap.Entry<String, TCell> entry : sorted.entrySet()) {
      rowStr.append(entry.getKey());
      rowStr.append(" => ");
      rowStr.append(utf8(entry.getValue().value.array()));
      rowStr.append("; ");
    }

    System.out.println("row: " + utf8(rowResult.row.array()) + ", cols: " + rowStr);
  }

  private void printRow(List<TRowResult> rows) {
    for (TRowResult rowResult : rows) {
      printRow(rowResult);
    }
  }

  static Subject getSubject() throws Exception {
    if (!secure) {
      return new Subject();
    }

    /*
     * To authenticate the DemoClient, kinit should be invoked ahead.
     * Here we try to get the Kerberos credential from the ticket cache.
     */
    LoginContext context = new LoginContext("", new Subject(), null,
        new Configuration() {
          @Override
          public AppConfigurationEntry[] getAppConfigurationEntry(String name) {
            Map<String, String> options = new HashMap<>();
            options.put("useKeyTab", "false");
            options.put("storeKey", "false");
            options.put("doNotPrompt", "true");
            options.put("useTicketCache", "true");
            options.put("renewTGT", "true");
            options.put("refreshKrb5Config", "true");
            options.put("isInitiator", "true");
            String ticketCache = System.getenv("KRB5CCNAME");

            if (ticketCache != null) {
              options.put("ticketCache", ticketCache);
            }

            options.put("debug", "true");

            return new AppConfigurationEntry[]{
                new AppConfigurationEntry("com.sun.security.auth.module.Krb5LoginModule",
                    AppConfigurationEntry.LoginModuleControlFlag.REQUIRED,
                    options)};
          }
        });

    context.login();
    return context.getSubject();
  }
}
/**
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

package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.util.Optional;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.RegionInfo;
import org.apache.hadoop.hbase.client.TableDescriptor;
import org.apache.hadoop.hbase.coprocessor.MasterCoprocessor;
import org.apache.hadoop.hbase.coprocessor.MasterCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.MasterObserver;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.metrics.Counter;
import org.apache.hadoop.hbase.metrics.Gauge;
import org.apache.hadoop.hbase.metrics.MetricRegistry;
import org.apache.hadoop.hbase.metrics.Timer;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * An example coprocessor that collects some metrics to demonstrate the usage of exporting custom
 * metrics from the coprocessor.
 *
 * <p>
 * These metrics will be available through the regular Hadoop metrics2 sinks (ganglia, opentsdb,
 * etc) as well as JMX output. You can view a snapshot of the metrics by going to the http web UI
 * of the master page, something like http://mymasterhost:16010/jmx
 * </p>
 * @see ExampleRegionObserverWithMetrics
 */
@InterfaceAudience.Private
public class ExampleMasterObserverWithMetrics implements MasterCoprocessor, MasterObserver {
  @Override
  public Optional<MasterObserver> getMasterObserver() {
    return Optional.of(this);
  }

  private static final Logger LOG = LoggerFactory.getLogger(ExampleMasterObserverWithMetrics.class);

  /** This is the Timer metric object to keep track of the current count across invocations */
  private Timer createTableTimer;
  private long createTableStartTime = Long.MIN_VALUE;

  /** This is a Counter object to keep track of disableTable operations */
  private Counter disableTableCounter;

  /** Returns the total memory of the process. We will use this to define a gauge metric */
  private long getTotalMemory() {
    return Runtime.getRuntime().totalMemory();
  }

  /** Returns the max memory of the process. We will use this to define a gauge metric */
  private long getMaxMemory() {
    return Runtime.getRuntime().maxMemory();
  }

  @Override
  public void preCreateTable(ObserverContext<MasterCoprocessorEnvironment> ctx,
                             TableDescriptor desc, RegionInfo[] regions) throws IOException {
    // we rely on the fact that there is only 1 instance of our MasterObserver. We keep track of
    // when the operation starts before the operation is executing.
    this.createTableStartTime = System.currentTimeMillis();
  }

  @Override
  public void postCreateTable(ObserverContext<MasterCoprocessorEnvironment> ctx,
                              TableDescriptor desc, RegionInfo[] regions) throws IOException {
    if (this.createTableStartTime > 0) {
      long time = System.currentTimeMillis() - this.createTableStartTime;
      LOG.info("Create table took: " + time);

      // Update the timer metric for the create table operation duration.
      createTableTimer.updateMillis(time);
    }
  }

  @Override
  public void preDisableTable(ObserverContext<MasterCoprocessorEnvironment> ctx, TableName tableName) throws IOException {
    // Increment the Counter for disable table operations
    this.disableTableCounter.increment();
  }

  @Override
  public void start(CoprocessorEnvironment env) throws IOException {
    // start for the MasterObserver will be called only once in the lifetime of the
    // server. We will construct and register all metrics that we will track across method
    // invocations.

    if (env instanceof MasterCoprocessorEnvironment) {
      // Obtain the MetricRegistry for the Master. Metrics from this registry will be reported
      // at the master level per-server.
      MetricRegistry registry =
          ((MasterCoprocessorEnvironment) env).getMetricRegistryForMaster();

      if (createTableTimer == null) {
        // Create a new Counter, or get the already registered counter.
        // It is much better to only call this once and save the Counter as a class field instead
        // of creating the counter every time a coprocessor method is invoked. This will negate
        // any performance bottleneck coming from map lookups tracking metrics in the registry.
        createTableTimer = registry.timer("CreateTable");

        // on stop(), we can remove these registered metrics via calling registry.remove(). But
        // it is not needed for coprocessors at the master level. If coprocessor is stopped,
        // the server is stopping anyway, so there will not be any resource leaks.
      }

      if (disableTableCounter == null) {
        disableTableCounter = registry.counter("DisableTable");
      }

      // Register a custom gauge. The Gauge object will be registered in the metrics registry and
      // periodically the getValue() is invoked to obtain the snapshot.
      registry.register("totalMemory", new Gauge<Long>() {
        @Override
        public Long getValue() {
          return getTotalMemory();
        }
      });

      // Register a custom gauge using Java-8 lambdas (Supplier converted into Gauge)
      registry.register("maxMemory", this::getMaxMemory);
    }
  }
}
/**
 * Copyright The Apache Software Foundation
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.util.Optional;
import java.util.OptionalLong;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.framework.recipes.cache.ChildData;
import org.apache.curator.framework.recipes.cache.NodeCache;
import org.apache.curator.retry.RetryForever;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.RegionObserver;
import org.apache.hadoop.hbase.regionserver.FlushLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.ScanOptions;
import org.apache.hadoop.hbase.regionserver.ScanType;
import org.apache.hadoop.hbase.regionserver.Store;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionRequest;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.util.EnvironmentEdgeManager;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * This is an example showing how a RegionObserver could configured via ZooKeeper in order to
 * control a Region compaction, flush, and scan policy. This also demonstrated the use of shared
 * {@link org.apache.hadoop.hbase.coprocessor.RegionObserver} state. See
 * {@link RegionCoprocessorEnvironment#getSharedData()}.
 * <p>
 * This would be useful for an incremental backup tool, which would indicate the last time of a
 * successful backup via ZK and instruct HBase that to safely delete the data which has already been
 * backup.
 */
@InterfaceAudience.Private
public class ZooKeeperScanPolicyObserver implements RegionCoprocessor, RegionObserver {

  @Override
  public Optional<RegionObserver> getRegionObserver() {
    return Optional.of(this);
  }

  // The zk ensemble info is put in hbase config xml with given custom key.
  public static final String ZK_ENSEMBLE_KEY = "ZooKeeperScanPolicyObserver.zookeeper.ensemble";
  public static final String ZK_SESSION_TIMEOUT_KEY =
      "ZooKeeperScanPolicyObserver.zookeeper.session.timeout";
  public static final int ZK_SESSION_TIMEOUT_DEFAULT = 30 * 1000; // 30 secs
  public static final String NODE = "/backup/example/lastbackup";
  private static final String ZKKEY = "ZK";

  private NodeCache cache;

  /**
   * Internal watcher that keep "data" up to date asynchronously.
   */
  private static final class ZKDataHolder {

    private final String ensemble;

    private final int sessionTimeout;

    private CuratorFramework client;

    private NodeCache cache;

    private int ref;

    public ZKDataHolder(String ensemble, int sessionTimeout) {
      this.ensemble = ensemble;
      this.sessionTimeout = sessionTimeout;
    }

    private void create() throws Exception {
      client =
          CuratorFrameworkFactory.builder().connectString(ensemble).sessionTimeoutMs(sessionTimeout)
              .retryPolicy(new RetryForever(1000)).canBeReadOnly(true).build();
      client.start();
      cache = new NodeCache(client, NODE);
      cache.start(true);
    }

    private void close() {
      if (cache != null) {
        try {
          cache.close();
        } catch (IOException e) {
          // should not happen
          throw new AssertionError(e);
        }
        cache = null;
      }
      if (client != null) {
        client.close();
        client = null;
      }
    }

    public synchronized NodeCache acquire() throws Exception {
      if (ref == 0) {
        try {
          create();
        } catch (Exception e) {
          close();
          throw e;
        }
      }
      ref++;
      return cache;
    }

    public synchronized void release() {
      ref--;
      if (ref == 0) {
        close();
      }
    }
  }

  @Override
  public void start(CoprocessorEnvironment env) throws IOException {
    RegionCoprocessorEnvironment renv = (RegionCoprocessorEnvironment) env;
    try {
      this.cache = ((ZKDataHolder) renv.getSharedData().computeIfAbsent(ZKKEY, k -> {
        String ensemble = renv.getConfiguration().get(ZK_ENSEMBLE_KEY);
        int sessionTimeout =
            renv.getConfiguration().getInt(ZK_SESSION_TIMEOUT_KEY, ZK_SESSION_TIMEOUT_DEFAULT);
        return new ZKDataHolder(ensemble, sessionTimeout);
      })).acquire();
    } catch (Exception e) {
      throw new IOException(e);
    }
  }

  @Override
  public void stop(CoprocessorEnvironment env) throws IOException {
    RegionCoprocessorEnvironment renv = (RegionCoprocessorEnvironment) env;
    this.cache = null;
    ((ZKDataHolder) renv.getSharedData().get(ZKKEY)).release();
  }

  private OptionalLong getExpireBefore() {
    ChildData data = cache.getCurrentData();
    if (data == null) {
      return OptionalLong.empty();
    }
    byte[] bytes = data.getData();
    if (bytes == null || bytes.length != Long.BYTES) {
      return OptionalLong.empty();
    }
    return OptionalLong.of(Bytes.toLong(bytes));
  }

  private void resetTTL(ScanOptions options) {
    OptionalLong expireBefore = getExpireBefore();
    if (!expireBefore.isPresent()) {
      return;
    }
    options.setTTL(EnvironmentEdgeManager.currentTime() - expireBefore.getAsLong());
  }

  @Override
  public void preFlushScannerOpen(ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      ScanOptions options, FlushLifeCycleTracker tracker) throws IOException {
    resetTTL(options);
  }

  @Override
  public void preCompactScannerOpen(ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      ScanType scanType, ScanOptions options, CompactionLifeCycleTracker tracker,
      CompactionRequest request) throws IOException {
    resetTTL(options);
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to you under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellBuilder;
import org.apache.hadoop.hbase.CellBuilderFactory;
import org.apache.hadoop.hbase.CellBuilderType;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.RegionObserver;
import org.apache.hadoop.hbase.regionserver.InternalScanner;
import org.apache.hadoop.hbase.regionserver.ScanType;
import org.apache.hadoop.hbase.regionserver.ScannerContext;
import org.apache.hadoop.hbase.regionserver.Store;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionRequest;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * This RegionObserver replaces the values of Puts from one value to another on compaction.
 */
@InterfaceAudience.Private
public class ValueRewritingObserver implements RegionObserver, RegionCoprocessor {
  public static final String ORIGINAL_VALUE_KEY =
      "hbase.examples.coprocessor.value.rewrite.orig";
  public static final String REPLACED_VALUE_KEY =
      "hbase.examples.coprocessor.value.rewrite.replaced";

  private byte[] sourceValue = null;
  private byte[] replacedValue = null;
  private Bytes.ByteArrayComparator comparator;
  private CellBuilder cellBuilder;


  @Override
  public Optional<RegionObserver> getRegionObserver() {
    // Extremely important to be sure that the coprocessor is invoked as a RegionObserver
    return Optional.of(this);
  }

  @Override
  public void start(
      @SuppressWarnings("rawtypes") CoprocessorEnvironment env) throws IOException {
    RegionCoprocessorEnvironment renv = (RegionCoprocessorEnvironment) env;
    sourceValue = Bytes.toBytes(renv.getConfiguration().get(ORIGINAL_VALUE_KEY));
    replacedValue = Bytes.toBytes(renv.getConfiguration().get(REPLACED_VALUE_KEY));
    comparator = new Bytes.ByteArrayComparator();
    cellBuilder = CellBuilderFactory.create(CellBuilderType.SHALLOW_COPY);
  }

  @Override
  public InternalScanner preCompact(
      ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      final InternalScanner scanner, ScanType scanType, CompactionLifeCycleTracker tracker,
      CompactionRequest request) {
    InternalScanner modifyingScanner = new InternalScanner() {
      @Override
      public boolean next(List<Cell> result, ScannerContext scannerContext) throws IOException {
        boolean ret = scanner.next(result, scannerContext);
        for (int i = 0; i < result.size(); i++) {
          Cell c = result.get(i);
          // Replace the Cell if the value is the one we're replacing
          if (CellUtil.isPut(c) &&
              comparator.compare(CellUtil.cloneValue(c), sourceValue) == 0) {
            try {
              cellBuilder.setRow(CellUtil.copyRow(c));
              cellBuilder.setFamily(CellUtil.cloneFamily(c));
              cellBuilder.setQualifier(CellUtil.cloneQualifier(c));
              cellBuilder.setTimestamp(c.getTimestamp());
              cellBuilder.setType(Cell.Type.Put);
              // Make sure each cell gets a unique value
              byte[] clonedValue = new byte[replacedValue.length];
              System.arraycopy(replacedValue, 0, clonedValue, 0, replacedValue.length);
              cellBuilder.setValue(clonedValue);
              result.set(i, cellBuilder.build());
            } finally {
              cellBuilder.clear();
            }
          }
        }
        return ret;
      }

      @Override
      public void close() throws IOException {
        scanner.close();
      }
    };

    return modifyingScanner;
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
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.hbase.coprocessor.example;

import com.google.protobuf.RpcCallback;
import com.google.protobuf.RpcController;
import com.google.protobuf.Service;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.coprocessor.CoprocessorException;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.example.generated.ExampleProtos;
import org.apache.hadoop.hbase.filter.FirstKeyOnlyFilter;
import org.apache.hadoop.hbase.ipc.CoprocessorRpcUtils;
import org.apache.hadoop.hbase.regionserver.InternalScanner;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * Sample coprocessor endpoint exposing a Service interface for counting rows and key values.
 *
 * <p>
 * For the protocol buffer definition of the RowCountService, see the source file located under
 * hbase-examples/src/main/protobuf/Examples.proto.
 * </p>
 */
@InterfaceAudience.Private
public class RowCountEndpoint extends ExampleProtos.RowCountService implements RegionCoprocessor {
  private RegionCoprocessorEnvironment env;

  public RowCountEndpoint() {
  }

  /**
   * Just returns a reference to this object, which implements the RowCounterService interface.
   */
  @Override
  public Iterable<Service> getServices() {
    return Collections.singleton(this);
  }

  /**
   * Returns a count of the rows in the region where this coprocessor is loaded.
   */
  @Override
  public void getRowCount(RpcController controller, ExampleProtos.CountRequest request,
                          RpcCallback<ExampleProtos.CountResponse> done) {
    Scan scan = new Scan();
    scan.setFilter(new FirstKeyOnlyFilter());
    ExampleProtos.CountResponse response = null;
    InternalScanner scanner = null;
    try {
      scanner = env.getRegion().getScanner(scan);
      List<Cell> results = new ArrayList<>();
      boolean hasMore = false;
      byte[] lastRow = null;
      long count = 0;
      do {
        hasMore = scanner.next(results);
        for (Cell kv : results) {
          byte[] currentRow = CellUtil.cloneRow(kv);
          if (lastRow == null || !Bytes.equals(lastRow, currentRow)) {
            lastRow = currentRow;
            count++;
          }
        }
        results.clear();
      } while (hasMore);

      response = ExampleProtos.CountResponse.newBuilder()
          .setCount(count).build();
    } catch (IOException ioe) {
      CoprocessorRpcUtils.setControllerException(controller, ioe);
    } finally {
      if (scanner != null) {
        try {
          scanner.close();
        } catch (IOException ignored) {}
      }
    }
    done.run(response);
  }

  /**
   * Returns a count of all KeyValues in the region where this coprocessor is loaded.
   */
  @Override
  public void getKeyValueCount(RpcController controller, ExampleProtos.CountRequest request,
                               RpcCallback<ExampleProtos.CountResponse> done) {
    ExampleProtos.CountResponse response = null;
    InternalScanner scanner = null;
    try {
      scanner = env.getRegion().getScanner(new Scan());
      List<Cell> results = new ArrayList<>();
      boolean hasMore = false;
      long count = 0;
      do {
        hasMore = scanner.next(results);
        for (Cell kv : results) {
          count++;
        }
        results.clear();
      } while (hasMore);

      response = ExampleProtos.CountResponse.newBuilder()
          .setCount(count).build();
    } catch (IOException ioe) {
      CoprocessorRpcUtils.setControllerException(controller, ioe);
    } finally {
      if (scanner != null) {
        try {
          scanner.close();
        } catch (IOException ignored) {}
      }
    }
    done.run(response);
  }

  /**
   * Stores a reference to the coprocessor environment provided by the
   * {@link org.apache.hadoop.hbase.regionserver.RegionCoprocessorHost} from the region where this
   * coprocessor is loaded.  Since this is a coprocessor endpoint, it always expects to be loaded
   * on a table region, so always expects this to be an instance of
   * {@link RegionCoprocessorEnvironment}.
   * @param env the environment provided by the coprocessor host
   * @throws IOException if the provided environment is not an instance of
   * {@code RegionCoprocessorEnvironment}
   */
  @Override
  public void start(CoprocessorEnvironment env) throws IOException {
    if (env instanceof RegionCoprocessorEnvironment) {
      this.env = (RegionCoprocessorEnvironment)env;
    } else {
      throw new CoprocessorException("Must be loaded on a table region!");
    }
  }

  @Override
  public void stop(CoprocessorEnvironment env) throws IOException {
    // nothing to do
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.Optional;
import java.util.TreeMap;
import java.util.stream.IntStream;
import org.apache.commons.lang3.mutable.MutableLong;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellBuilderFactory;
import org.apache.hadoop.hbase.CellBuilderType;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Increment;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.RegionObserver;
import org.apache.hadoop.hbase.regionserver.FlushLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.InternalScanner;
import org.apache.hadoop.hbase.regionserver.RegionScanner;
import org.apache.hadoop.hbase.regionserver.ScanOptions;
import org.apache.hadoop.hbase.regionserver.ScanType;
import org.apache.hadoop.hbase.regionserver.ScannerContext;
import org.apache.hadoop.hbase.regionserver.Store;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionRequest;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;

import org.apache.hbase.thirdparty.com.google.common.math.IntMath;

/**
 * An example for implementing a counter that reads is much less than writes, i.e, write heavy.
 * <p>
 * We will convert increment to put, and do aggregating when get. And of course the return value of
 * increment is useless then.
 * <p>
 * Notice that this is only an example so we do not handle most corner cases, for example, you must
 * provide a qualifier when doing a get.
 */
@InterfaceAudience.Private
public class WriteHeavyIncrementObserver implements RegionCoprocessor, RegionObserver {

  @Override
  public Optional<RegionObserver> getRegionObserver() {
    return Optional.of(this);
  }

  @Override
  public void preFlushScannerOpen(ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      ScanOptions options, FlushLifeCycleTracker tracker) throws IOException {
    options.readAllVersions();
  }

  private Cell createCell(byte[] row, byte[] family, byte[] qualifier, long ts, long value) {
    return CellBuilderFactory.create(CellBuilderType.SHALLOW_COPY).setRow(row)
        .setType(Cell.Type.Put).setFamily(family).setQualifier(qualifier)
        .setTimestamp(ts).setValue(Bytes.toBytes(value)).build();
  }

  private InternalScanner wrap(byte[] family, InternalScanner scanner) {
    return new InternalScanner() {

      private List<Cell> srcResult = new ArrayList<>();

      private byte[] row;

      private byte[] qualifier;

      private long timestamp;

      private long sum;

      @Override
      public boolean next(List<Cell> result, ScannerContext scannerContext) throws IOException {
        boolean moreRows = scanner.next(srcResult, scannerContext);
        if (srcResult.isEmpty()) {
          if (!moreRows && row != null) {
            result.add(createCell(row, family, qualifier, timestamp, sum));
          }
          return moreRows;
        }
        Cell firstCell = srcResult.get(0);
        // Check if there is a row change first. All the cells will come from the same row so just
        // check the first one once is enough.
        if (row == null) {
          row = CellUtil.cloneRow(firstCell);
          qualifier = CellUtil.cloneQualifier(firstCell);
        } else if (!CellUtil.matchingRows(firstCell, row)) {
          result.add(createCell(row, family, qualifier, timestamp, sum));
          row = CellUtil.cloneRow(firstCell);
          qualifier = CellUtil.cloneQualifier(firstCell);
          sum = 0;
        }
        srcResult.forEach(c -> {
          if (CellUtil.matchingQualifier(c, qualifier)) {
            sum += Bytes.toLong(c.getValueArray(), c.getValueOffset());
          } else {
            result.add(createCell(row, family, qualifier, timestamp, sum));
            qualifier = CellUtil.cloneQualifier(c);
            sum = Bytes.toLong(c.getValueArray(), c.getValueOffset());
          }
          timestamp = c.getTimestamp();
        });
        if (!moreRows) {
          result.add(createCell(row, family, qualifier, timestamp, sum));
        }
        srcResult.clear();
        return moreRows;
      }

      @Override
      public void close() throws IOException {
        scanner.close();
      }
    };
  }

  @Override
  public InternalScanner preFlush(ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      InternalScanner scanner, FlushLifeCycleTracker tracker) throws IOException {
    return wrap(store.getColumnFamilyDescriptor().getName(), scanner);
  }

  @Override
  public void preCompactScannerOpen(ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      ScanType scanType, ScanOptions options, CompactionLifeCycleTracker tracker,
      CompactionRequest request) throws IOException {
    options.readAllVersions();
  }

  @Override
  public InternalScanner preCompact(ObserverContext<RegionCoprocessorEnvironment> c, Store store,
      InternalScanner scanner, ScanType scanType, CompactionLifeCycleTracker tracker,
      CompactionRequest request) throws IOException {
    return wrap(store.getColumnFamilyDescriptor().getName(), scanner);
  }

  @Override
  public void preMemStoreCompactionCompactScannerOpen(
      ObserverContext<RegionCoprocessorEnvironment> c, Store store, ScanOptions options)
      throws IOException {
    options.readAllVersions();
  }

  @Override
  public InternalScanner preMemStoreCompactionCompact(
      ObserverContext<RegionCoprocessorEnvironment> c, Store store, InternalScanner scanner)
      throws IOException {
    return wrap(store.getColumnFamilyDescriptor().getName(), scanner);
  }

  @Override
  public void preGetOp(ObserverContext<RegionCoprocessorEnvironment> c, Get get, List<Cell> result)
      throws IOException {
    Scan scan =
        new Scan().withStartRow(get.getRow()).withStopRow(get.getRow(), true).readAllVersions();
    NavigableMap<byte[], NavigableMap<byte[], MutableLong>> sums =
        new TreeMap<>(Bytes.BYTES_COMPARATOR);
    get.getFamilyMap().forEach((cf, cqs) -> {
      NavigableMap<byte[], MutableLong> ss = new TreeMap<>(Bytes.BYTES_COMPARATOR);
      sums.put(cf, ss);
      cqs.forEach(cq -> {
        ss.put(cq, new MutableLong(0));
        scan.addColumn(cf, cq);
      });
    });
    List<Cell> cells = new ArrayList<>();
    try (RegionScanner scanner = c.getEnvironment().getRegion().getScanner(scan)) {
      boolean moreRows;
      do {
        moreRows = scanner.next(cells);
        for (Cell cell : cells) {
          byte[] family = CellUtil.cloneFamily(cell);
          byte[] qualifier = CellUtil.cloneQualifier(cell);
          long value = Bytes.toLong(cell.getValueArray(), cell.getValueOffset());
          sums.get(family).get(qualifier).add(value);
        }
        cells.clear();
      } while (moreRows);
    }
    sums.forEach((cf, m) -> m.forEach((cq, s) -> result
        .add(createCell(get.getRow(), cf, cq, HConstants.LATEST_TIMESTAMP, s.longValue()))));
    c.bypass();
  }

  private final int mask;
  private final MutableLong[] lastTimestamps;
  {
    int stripes =
        1 << IntMath.log2(Runtime.getRuntime().availableProcessors(), RoundingMode.CEILING);
    lastTimestamps =
        IntStream.range(0, stripes).mapToObj(i -> new MutableLong()).toArray(MutableLong[]::new);
    mask = stripes - 1;
  }

  // We need make sure the different put uses different timestamp otherwise we may lost some
  // increments. This is a known issue for HBase.
  private long getUniqueTimestamp(byte[] row) {
    int slot = Bytes.hashCode(row) & mask;
    MutableLong lastTimestamp = lastTimestamps[slot];
    long now = System.currentTimeMillis();
    synchronized (lastTimestamp) {
      long pt = lastTimestamp.longValue() >> 10;
      if (now > pt) {
        lastTimestamp.setValue(now << 10);
      } else {
        lastTimestamp.increment();
      }
      return lastTimestamp.longValue();
    }
  }

  @Override
  public Result preIncrement(ObserverContext<RegionCoprocessorEnvironment> c, Increment increment)
      throws IOException {
    byte[] row = increment.getRow();
    Put put = new Put(row);
    long ts = getUniqueTimestamp(row);
    for (Map.Entry<byte[], List<Cell>> entry : increment.getFamilyCellMap().entrySet()) {
      for (Cell cell : entry.getValue()) {
        put.add(CellBuilderFactory.create(CellBuilderType.SHALLOW_COPY).setRow(row)
            .setFamily(cell.getFamilyArray(), cell.getFamilyOffset(), cell.getFamilyLength())
            .setQualifier(cell.getQualifierArray(), cell.getQualifierOffset(),
              cell.getQualifierLength())
            .setValue(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength())
            .setType(Cell.Type.Put).setTimestamp(ts).build());
      }
    }
    c.getEnvironment().getRegion().put(put);
    c.bypass();
    return Result.EMPTY_RESULT;
  }

  @Override
  public void preStoreScannerOpen(ObserverContext<RegionCoprocessorEnvironment> ctx, Store store,
      ScanOptions options) throws IOException {
    options.readAllVersions();
  }
}
/**
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.RegionObserver;
import org.apache.hadoop.hbase.metrics.Counter;
import org.apache.hadoop.hbase.metrics.MetricRegistry;
import org.apache.hadoop.hbase.metrics.Timer;
import org.apache.hadoop.hbase.regionserver.FlushLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.Store;
import org.apache.hadoop.hbase.regionserver.StoreFile;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionLifeCycleTracker;
import org.apache.hadoop.hbase.regionserver.compactions.CompactionRequest;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * An example coprocessor that collects some metrics to demonstrate the usage of exporting custom
 * metrics from the coprocessor.
 * <p>
 * These metrics will be available through the regular Hadoop metrics2 sinks (ganglia, opentsdb,
 * etc) as well as JMX output. You can view a snapshot of the metrics by going to the http web UI
 * of the regionserver page, something like http://myregionserverhost:16030/jmx
 * </p>
 *
 * @see ExampleMasterObserverWithMetrics
 */
@InterfaceAudience.Private
public class ExampleRegionObserverWithMetrics implements RegionCoprocessor {

  private Counter preGetCounter;
  private Counter flushCounter;
  private Counter filesCompactedCounter;
  private Timer costlyOperationTimer;
  private ExampleRegionObserver observer;

  class ExampleRegionObserver implements RegionCoprocessor, RegionObserver {
    @Override
    public Optional<RegionObserver> getRegionObserver() {
      return Optional.of(this);
    }

    @Override
    public void preGetOp(ObserverContext<RegionCoprocessorEnvironment> e, Get get,
        List<Cell> results) throws IOException {
      // Increment the Counter whenever the coprocessor is called
      preGetCounter.increment();
    }

    @Override
    public void postGetOp(ObserverContext<RegionCoprocessorEnvironment> e, Get get,
        List<Cell> results) throws IOException {
      // do a costly (high latency) operation which we want to measure how long it takes by
      // using a Timer (which is a Meter and a Histogram).
      long start = System.nanoTime();
      try {
        performCostlyOperation();
      } finally {
        costlyOperationTimer.updateNanos(System.nanoTime() - start);
      }
    }

    @Override
    public void postFlush(
        ObserverContext<RegionCoprocessorEnvironment> c,
        FlushLifeCycleTracker tracker) throws IOException {
      flushCounter.increment();
    }

    @Override
    public void postFlush(
        ObserverContext<RegionCoprocessorEnvironment> c, Store store, StoreFile resultFile,
        FlushLifeCycleTracker tracker) throws IOException {
      flushCounter.increment();
    }

    @Override
    public void postCompactSelection(
        ObserverContext<RegionCoprocessorEnvironment> c, Store store,
        List<? extends StoreFile> selected, CompactionLifeCycleTracker tracker,
        CompactionRequest request) {
      if (selected != null) {
        filesCompactedCounter.increment(selected.size());
      }
    }

    private void performCostlyOperation() {
      try {
        // simulate the operation by sleeping.
        Thread.sleep(ThreadLocalRandom.current().nextLong(100));
      } catch (InterruptedException ignore) {
      }
    }
  }

  @Override public Optional<RegionObserver> getRegionObserver() {
    return Optional.of(observer);
  }

  @Override
  public void start(CoprocessorEnvironment env) throws IOException {
    // start for the RegionServerObserver will be called only once in the lifetime of the
    // server. We will construct and register all metrics that we will track across method
    // invocations.

    if (env instanceof RegionCoprocessorEnvironment) {
      // Obtain the MetricRegistry for the RegionServer. Metrics from this registry will be reported
      // at the region server level per-regionserver.
      MetricRegistry registry =
          ((RegionCoprocessorEnvironment) env).getMetricRegistryForRegionServer();
      observer = new ExampleRegionObserver();

      if (preGetCounter == null) {
        // Create a new Counter, or get the already registered counter.
        // It is much better to only call this once and save the Counter as a class field instead
        // of creating the counter every time a coprocessor method is invoked. This will negate
        // any performance bottleneck coming from map lookups tracking metrics in the registry.
        // Returned counter instance is shared by all coprocessors of the same class in the same
        // region server.
        preGetCounter = registry.counter("preGetRequests");
      }

      if (costlyOperationTimer == null) {
        // Create a Timer to track execution times for the costly operation.
        costlyOperationTimer = registry.timer("costlyOperation");
      }

      if (flushCounter == null) {
        // Track the number of flushes that have completed
        flushCounter = registry.counter("flushesCompleted");
      }

      if (filesCompactedCounter == null) {
        // Track the number of files that were compacted (many files may be rewritten in a single
        // compaction).
        filesCompactedCounter = registry.counter("filesCompacted");
      }
    }
  }

  @Override
  public void stop(CoprocessorEnvironment e) throws IOException {
    // we should NOT remove / deregister the metrics in stop(). The whole registry will be
    // removed when the last region of the table is closed.
  }
}
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to you under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.util.Optional;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.coprocessor.ObserverContext;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.RegionObserver;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * A RegionObserver which modifies incoming Scan requests to include additional
 * columns than what the user actually requested.
 */
@InterfaceAudience.Private
public class ScanModifyingObserver implements RegionCoprocessor, RegionObserver {

  public static final String FAMILY_TO_ADD_KEY = "hbase.examples.coprocessor.scanmodifying.family";
  public static final String QUALIFIER_TO_ADD_KEY =
      "hbase.examples.coprocessor.scanmodifying.qualifier";

  private byte[] FAMILY_TO_ADD = null;
  private byte[] QUALIFIER_TO_ADD = null;

  @Override
  public void start(
      @SuppressWarnings("rawtypes") CoprocessorEnvironment env) throws IOException {
    RegionCoprocessorEnvironment renv = (RegionCoprocessorEnvironment) env;
    FAMILY_TO_ADD = Bytes.toBytes(renv.getConfiguration().get(FAMILY_TO_ADD_KEY));
    QUALIFIER_TO_ADD = Bytes.toBytes(renv.getConfiguration().get(QUALIFIER_TO_ADD_KEY));
  }

  @Override
  public Optional<RegionObserver> getRegionObserver() {
    // Extremely important to be sure that the coprocessor is invoked as a RegionObserver
    return Optional.of(this);
  }

  @Override
  public void preScannerOpen(
      ObserverContext<RegionCoprocessorEnvironment> c, Scan scan) throws IOException {
    // Add another family:qualifier
    scan.addColumn(FAMILY_TO_ADD, QUALIFIER_TO_ADD);
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
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.hbase.coprocessor.example;

import com.google.protobuf.RpcCallback;
import com.google.protobuf.RpcController;
import com.google.protobuf.Service;
import java.io.IOException;
import java.util.Collections;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.CoprocessorException;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.ipc.CoprocessorRpcUtils;
import org.apache.hadoop.hbase.protobuf.generated.RefreshHFilesProtos;
import org.apache.hadoop.hbase.regionserver.Store;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Coprocessor endpoint to refresh HFiles on replica.
 * <p>
 * <p>
 * For the protocol buffer definition of the RefreshHFilesService, see the source file located under
 * hbase-protocol/src/main/protobuf/RefreshHFiles.proto.
 * </p>
 */
@InterfaceAudience.Private
public class RefreshHFilesEndpoint extends RefreshHFilesProtos.RefreshHFilesService
  implements RegionCoprocessor {
  protected static final Logger LOG = LoggerFactory.getLogger(RefreshHFilesEndpoint.class);
  private RegionCoprocessorEnvironment env;

  public RefreshHFilesEndpoint() {
  }

  @Override
  public Iterable<Service> getServices() {
    return Collections.singleton(this);
  }

  @Override
  public void refreshHFiles(RpcController controller, RefreshHFilesProtos.RefreshHFilesRequest request,
                            RpcCallback<RefreshHFilesProtos.RefreshHFilesResponse> done) {
    try {
      for (Store store : env.getRegion().getStores()) {
        LOG.debug("Refreshing HFiles for region: " + store.getRegionInfo().getRegionNameAsString() +
                    " and store: " + store.getColumnFamilyName() + "class:" + store.getClass());
        store.refreshStoreFiles();
      }
    } catch (IOException ioe) {
      LOG.error("Exception while trying to refresh store files: ", ioe);
      CoprocessorRpcUtils.setControllerException(controller, ioe);
    }
    done.run(RefreshHFilesProtos.RefreshHFilesResponse.getDefaultInstance());
  }

  @Override
  public void start(CoprocessorEnvironment env) throws IOException {
    if (env instanceof RegionCoprocessorEnvironment) {
      this.env = (RegionCoprocessorEnvironment) env;
    } else {
      throw new CoprocessorException("Must be loaded on a table region!");
    }
  }

  @Override
  public void stop(CoprocessorEnvironment env) throws IOException {
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import java.util.List;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.regionserver.InternalScanner;
import org.apache.hadoop.hbase.regionserver.ScannerContext;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * A simple delegation for doing filtering on {@link InternalScanner}.
 */
@InterfaceAudience.Private
public class DelegatingInternalScanner implements InternalScanner {

  protected final InternalScanner scanner;

  public DelegatingInternalScanner(InternalScanner scanner) {
    this.scanner = scanner;
  }

  @Override
  public boolean next(List<Cell> result, ScannerContext scannerContext) throws IOException {
    return scanner.next(result, scannerContext);
  }

  @Override
  public void close() throws IOException {
    scanner.close();
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
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.hbase.coprocessor.example;

import com.google.protobuf.RpcCallback;
import com.google.protobuf.RpcController;
import com.google.protobuf.Service;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.CoprocessorEnvironment;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.HConstants.OperationStatusCode;
import org.apache.hadoop.hbase.client.Delete;
import org.apache.hadoop.hbase.client.Mutation;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.coprocessor.CoprocessorException;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessor;
import org.apache.hadoop.hbase.coprocessor.RegionCoprocessorEnvironment;
import org.apache.hadoop.hbase.coprocessor.example.generated.BulkDeleteProtos.BulkDeleteRequest;
import org.apache.hadoop.hbase.coprocessor.example.generated.BulkDeleteProtos.BulkDeleteRequest.DeleteType;
import org.apache.hadoop.hbase.coprocessor.example.generated.BulkDeleteProtos.BulkDeleteResponse;
import org.apache.hadoop.hbase.coprocessor.example.generated.BulkDeleteProtos.BulkDeleteResponse.Builder;
import org.apache.hadoop.hbase.coprocessor.example.generated.BulkDeleteProtos.BulkDeleteService;
import org.apache.hadoop.hbase.filter.FirstKeyOnlyFilter;
import org.apache.hadoop.hbase.ipc.CoprocessorRpcUtils;
import org.apache.hadoop.hbase.protobuf.ProtobufUtil;
import org.apache.hadoop.hbase.regionserver.OperationStatus;
import org.apache.hadoop.hbase.regionserver.Region;
import org.apache.hadoop.hbase.regionserver.RegionScanner;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Defines a protocol to delete data in bulk based on a scan. The scan can be range scan or with
 * conditions(filters) etc.This can be used to delete rows, column family(s), column qualifier(s)
 * or version(s) of columns.When delete type is FAMILY or COLUMN, which all family(s) or column(s)
 * getting deleted will be determined by the Scan. Scan need to select all the families/qualifiers
 * which need to be deleted.When delete type is VERSION, Which column(s) and version(s) to be
 * deleted will be determined by the Scan. Scan need to select all the qualifiers and its versions
 * which needs to be deleted.When a timestamp is passed only one version at that timestamp will be
 * deleted(even if Scan fetches many versions). When timestamp passed as null, all the versions
 * which the Scan selects will get deleted.
 *
 * <br> Example: <pre><code>
 * Scan scan = new Scan();
 * // set scan properties(rowkey range, filters, timerange etc).
 * HTable ht = ...;
 * long noOfDeletedRows = 0L;
 * Batch.Call&lt;BulkDeleteService, BulkDeleteResponse&gt; callable =
 *     new Batch.Call&lt;BulkDeleteService, BulkDeleteResponse&gt;() {
 *   ServerRpcController controller = new ServerRpcController();
 *   BlockingRpcCallback&lt;BulkDeleteResponse&gt; rpcCallback =
 *     new BlockingRpcCallback&lt;BulkDeleteResponse&gt;();
 *
 *   public BulkDeleteResponse call(BulkDeleteService service) throws IOException {
 *     Builder builder = BulkDeleteRequest.newBuilder();
 *     builder.setScan(ProtobufUtil.toScan(scan));
 *     builder.setDeleteType(DeleteType.VERSION);
 *     builder.setRowBatchSize(rowBatchSize);
 *     // Set optional timestamp if needed
 *     builder.setTimestamp(timeStamp);
 *     service.delete(controller, builder.build(), rpcCallback);
 *     return rpcCallback.get();
 *   }
 * };
 * Map&lt;byte[], BulkDeleteResponse&gt; result = ht.coprocessorService(BulkDeleteService.class, scan
 *     .getStartRow(), scan.getStopRow(), callable);
 * for (BulkDeleteResponse response : result.values()) {
 *   noOfDeletedRows += response.getRowsDeleted();
 * }
 * </code></pre>
 */
@InterfaceAudience.Private
public class BulkDeleteEndpoint extends BulkDeleteService implements RegionCoprocessor {
  private static final String NO_OF_VERSIONS_TO_DELETE = "noOfVersionsToDelete";
  private static final Logger LOG = LoggerFactory.getLogger(BulkDeleteEndpoint.class);

  private RegionCoprocessorEnvironment env;

  @Override
  public Iterable<Service> getServices() {
    return Collections.singleton(this);
  }

  @Override
  public void delete(RpcController controller, BulkDeleteRequest request,
      RpcCallback<BulkDeleteResponse> done) {
    long totalRowsDeleted = 0L;
    long totalVersionsDeleted = 0L;
    Region region = env.getRegion();
    int rowBatchSize = request.getRowBatchSize();
    Long timestamp = null;
    if (request.hasTimestamp()) {
      timestamp = request.getTimestamp();
    }
    DeleteType deleteType = request.getDeleteType();
    boolean hasMore = true;
    RegionScanner scanner = null;
    try {
      Scan scan = ProtobufUtil.toScan(request.getScan());
      if (scan.getFilter() == null && deleteType == DeleteType.ROW) {
        // What we need is just the rowkeys. So only 1st KV from any row is enough.
        // Only when it is a row delete, we can apply this filter.
        // In other types we rely on the scan to know which all columns to be deleted.
        scan.setFilter(new FirstKeyOnlyFilter());
      }
      // Here by assume that the scan is perfect with the appropriate
      // filter and having necessary column(s).
      scanner = region.getScanner(scan);
      while (hasMore) {
        List<List<Cell>> deleteRows = new ArrayList<>(rowBatchSize);
        for (int i = 0; i < rowBatchSize; i++) {
          List<Cell> results = new ArrayList<>();
          hasMore = scanner.next(results);
          if (results.size() > 0) {
            deleteRows.add(results);
          }
          if (!hasMore) {
            // There are no more rows.
            break;
          }
        }
        if (deleteRows.size() > 0) {
          Mutation[] deleteArr = new Mutation[deleteRows.size()];
          int i = 0;
          for (List<Cell> deleteRow : deleteRows) {
            deleteArr[i++] = createDeleteMutation(deleteRow, deleteType, timestamp);
          }
          OperationStatus[] opStatus = region.batchMutate(deleteArr);
          for (i = 0; i < opStatus.length; i++) {
            if (opStatus[i].getOperationStatusCode() != OperationStatusCode.SUCCESS) {
              break;
            }
            totalRowsDeleted++;
            if (deleteType == DeleteType.VERSION) {
              byte[] versionsDeleted = deleteArr[i].getAttribute(
                  NO_OF_VERSIONS_TO_DELETE);
              if (versionsDeleted != null) {
                totalVersionsDeleted += Bytes.toInt(versionsDeleted);
              }
            }
          }
        }
      }
    } catch (IOException ioe) {
      LOG.error(ioe.toString(), ioe);
      // Call ServerRpcController#getFailedOn() to retrieve this IOException at client side.
      CoprocessorRpcUtils.setControllerException(controller, ioe);
    } finally {
      if (scanner != null) {
        try {
          scanner.close();
        } catch (IOException ioe) {
          LOG.error(ioe.toString(), ioe);
        }
      }
    }
    Builder responseBuilder = BulkDeleteResponse.newBuilder();
    responseBuilder.setRowsDeleted(totalRowsDeleted);
    if (deleteType == DeleteType.VERSION) {
      responseBuilder.setVersionsDeleted(totalVersionsDeleted);
    }
    BulkDeleteResponse result = responseBuilder.build();
    done.run(result);
  }

  private Delete createDeleteMutation(List<Cell> deleteRow, DeleteType deleteType,
      Long timestamp) {
    long ts;
    if (timestamp == null) {
      ts = HConstants.LATEST_TIMESTAMP;
    } else {
      ts = timestamp;
    }
    // We just need the rowkey. Get it from 1st KV.
    byte[] row = CellUtil.cloneRow(deleteRow.get(0));
    Delete delete = new Delete(row, ts);
    if (deleteType == DeleteType.FAMILY) {
      Set<byte[]> families = new TreeSet<>(Bytes.BYTES_COMPARATOR);
      for (Cell kv : deleteRow) {
        if (families.add(CellUtil.cloneFamily(kv))) {
          delete.addFamily(CellUtil.cloneFamily(kv), ts);
        }
      }
    } else if (deleteType == DeleteType.COLUMN) {
      Set<Column> columns = new HashSet<>();
      for (Cell kv : deleteRow) {
        Column column = new Column(CellUtil.cloneFamily(kv), CellUtil.cloneQualifier(kv));
        if (columns.add(column)) {
          // Making deleteColumns() calls more than once for the same cf:qualifier is not correct
          // Every call to deleteColumns() will add a new KV to the familymap which will finally
          // get written to the memstore as part of delete().
          delete.addColumns(column.family, column.qualifier, ts);
        }
      }
    } else if (deleteType == DeleteType.VERSION) {
      // When some timestamp was passed to the delete() call only one version of the column (with
      // given timestamp) will be deleted. If no timestamp passed, it will delete N versions.
      // How many versions will get deleted depends on the Scan being passed. All the KVs that
      // the scan fetched will get deleted.
      int noOfVersionsToDelete = 0;
      if (timestamp == null) {
        for (Cell kv : deleteRow) {
          delete.addColumn(CellUtil.cloneFamily(kv), CellUtil.cloneQualifier(kv), kv.getTimestamp());
          noOfVersionsToDelete++;
        }
      } else {
        Set<Column> columns = new HashSet<>();
        for (Cell kv : deleteRow) {
          Column column = new Column(CellUtil.cloneFamily(kv), CellUtil.cloneQualifier(kv));
          // Only one version of particular column getting deleted.
          if (columns.add(column)) {
            delete.addColumn(column.family, column.qualifier, ts);
            noOfVersionsToDelete++;
          }
        }
      }
      delete.setAttribute(NO_OF_VERSIONS_TO_DELETE, Bytes.toBytes(noOfVersionsToDelete));
    }
    return delete;
  }

  private static class Column {
    private byte[] family;
    private byte[] qualifier;

    public Column(byte[] family, byte[] qualifier) {
      this.family = family;
      this.qualifier = qualifier;
    }

    @Override
    public boolean equals(Object other) {
      if (!(other instanceof Column)) {
        return false;
      }
      Column column = (Column) other;
      return Bytes.equals(this.family, column.family)
          && Bytes.equals(this.qualifier, column.qualifier);
    }

    @Override
    public int hashCode() {
      int h = 31;
      h = h + 13 * Bytes.hashCode(this.family);
      h = h + 13 * Bytes.hashCode(this.qualifier);
      return h;
    }
  }

  @Override
  public void start(CoprocessorEnvironment env) throws IOException {
    if (env instanceof RegionCoprocessorEnvironment) {
      this.env = (RegionCoprocessorEnvironment) env;
    } else {
      throw new CoprocessorException("Must be loaded on a table region!");
    }
  }

  @Override
  public void stop(CoprocessorEnvironment env) throws IOException {
    // nothing to do
  }
}
/**
 *
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
package org.apache.hadoop.hbase.mapreduce;

import java.io.IOException;
import java.util.TreeMap;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.yetus.audience.InterfaceAudience;

/**
 * Example map/reduce job to construct index tables that can be used to quickly
 * find a row based on the value of a column. It demonstrates:
 * <ul>
 * <li>Using TableInputFormat and TableMapReduceUtil to use an HTable as input
 * to a map/reduce job.</li>
 * <li>Passing values from main method to children via the configuration.</li>
 * <li>Using MultiTableOutputFormat to output to multiple tables from a
 * map/reduce job.</li>
 * <li>A real use case of building a secondary index over a table.</li>
 * </ul>
 *
 * <h3>Usage</h3>
 *
 * <p>
 * Modify ${HADOOP_HOME}/conf/hadoop-env.sh to include the hbase jar, the
 * zookeeper jar (can be found in lib/ directory under HBase root, the examples output directory,
 * and the hbase conf directory in HADOOP_CLASSPATH, and then run
 * <tt><strong>bin/hadoop org.apache.hadoop.hbase.mapreduce.IndexBuilder TABLE_NAME COLUMN_FAMILY ATTR [ATTR ...]</strong></tt>
 * </p>
 *
 * <p>
 * To run with the sample data provided in index-builder-setup.rb, use the
 * arguments <strong><tt>people attributes name email phone</tt></strong>.
 * </p>
 *
 * <p>
 * This code was written against HBase 0.21 trunk.
 * </p>
 */
@InterfaceAudience.Private
public class IndexBuilder extends Configured implements Tool {
  /** the column family containing the indexed row key */
  public static final byte[] INDEX_COLUMN = Bytes.toBytes("INDEX");
  /** the qualifier containing the indexed row key */
  public static final byte[] INDEX_QUALIFIER = Bytes.toBytes("ROW");

  /**
   * Internal Mapper to be run by Hadoop.
   */
  public static class Map extends
      Mapper<ImmutableBytesWritable, Result, ImmutableBytesWritable, Put> {
    private byte[] family;
    private TreeMap<byte[], ImmutableBytesWritable> indexes;

    @Override
    protected void map(ImmutableBytesWritable rowKey, Result result, Context context)
        throws IOException, InterruptedException {
      for(java.util.Map.Entry<byte[], ImmutableBytesWritable> index : indexes.entrySet()) {
        byte[] qualifier = index.getKey();
        ImmutableBytesWritable tableName = index.getValue();
        byte[] value = result.getValue(family, qualifier);
        if (value != null) {
          // original: row 123 attribute:phone 555-1212
          // index: row 555-1212 INDEX:ROW 123
          Put put = new Put(value);
          put.addColumn(INDEX_COLUMN, INDEX_QUALIFIER, rowKey.get());
          context.write(tableName, put);
        }
      }
    }

    @Override
    protected void setup(Context context) throws IOException,
        InterruptedException {
      Configuration configuration = context.getConfiguration();
      String tableName = configuration.get("index.tablename");
      String[] fields = configuration.getStrings("index.fields");
      String familyName = configuration.get("index.familyname");
      family = Bytes.toBytes(familyName);
      indexes = new TreeMap<>(Bytes.BYTES_COMPARATOR);
      for(String field : fields) {
        // if the table is "people" and the field to index is "email", then the
        // index table will be called "people-email"
        indexes.put(Bytes.toBytes(field),
            new ImmutableBytesWritable(Bytes.toBytes(tableName + "-" + field)));
      }
    }
  }

  /**
   * Job configuration.
   */
  public static Job configureJob(Configuration conf, String [] args)
  throws IOException {
    String tableName = args[0];
    String columnFamily = args[1];
    System.out.println("****" + tableName);
    conf.set(TableInputFormat.SCAN, TableMapReduceUtil.convertScanToString(new Scan()));
    conf.set(TableInputFormat.INPUT_TABLE, tableName);
    conf.set("index.tablename", tableName);
    conf.set("index.familyname", columnFamily);
    String[] fields = new String[args.length - 2];
    System.arraycopy(args, 2, fields, 0, fields.length);
    conf.setStrings("index.fields", fields);
    Job job = new Job(conf, tableName);
    job.setJarByClass(IndexBuilder.class);
    job.setMapperClass(Map.class);
    job.setNumReduceTasks(0);
    job.setInputFormatClass(TableInputFormat.class);
    job.setOutputFormatClass(MultiTableOutputFormat.class);
    return job;
  }

  public int run(String[] args) throws Exception {
    Configuration conf = HBaseConfiguration.create(getConf());
    if(args.length < 3) {
      System.err.println("Only " + args.length + " arguments supplied, required: 3");
      System.err.println("Usage: IndexBuilder <TABLE_NAME> <COLUMN_FAMILY> <ATTR> [<ATTR> ...]");
      System.exit(-1);
    }
    Job job = configureJob(conf, args);
    return (job.waitForCompletion(true) ? 0 : 1);
  }

  public static void main(String[] args) throws Exception {
    int result = ToolRunner.run(HBaseConfiguration.create(), new IndexBuilder(), args);
    System.exit(result);
  }
}
/**
 *
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
package org.apache.hadoop.hbase.mapreduce;

import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.yetus.audience.InterfaceAudience;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Sample Uploader MapReduce
 * <p>
 * This is EXAMPLE code.  You will need to change it to work for your context.
 * <p>
 * Uses {@link TableReducer} to put the data into HBase. Change the InputFormat
 * to suit your data.  In this example, we are importing a CSV file.
 * <p>
 * <pre>row,family,qualifier,value</pre>
 * <p>
 * The table and columnfamily we're to insert into must preexist.
 * <p>
 * There is no reducer in this example as it is not necessary and adds
 * significant overhead.  If you need to do any massaging of data before
 * inserting into HBase, you can do this in the map as well.
 * <p>Do the following to start the MR job:
 * <pre>
 * ./bin/hadoop org.apache.hadoop.hbase.mapreduce.SampleUploader /tmp/input.csv TABLE_NAME
 * </pre>
 * <p>
 * This code was written against HBase 0.21 trunk.
 */
@InterfaceAudience.Private
public class SampleUploader extends Configured implements Tool {
  private static final Logger LOG = LoggerFactory.getLogger(SampleUploader.class);

  private static final String NAME = "SampleUploader";

  static class Uploader
  extends Mapper<LongWritable, Text, ImmutableBytesWritable, Put> {

    private long checkpoint = 100;
    private long count = 0;

    @Override
    public void map(LongWritable key, Text line, Context context)
    throws IOException {

      // Input is a CSV file
      // Each map() is a single line, where the key is the line number
      // Each line is comma-delimited; row,family,qualifier,value

      // Split CSV line
      String [] values = line.toString().split(",");
      if(values.length != 4) {
        return;
      }

      // Extract each value
      byte [] row = Bytes.toBytes(values[0]);
      byte [] family = Bytes.toBytes(values[1]);
      byte [] qualifier = Bytes.toBytes(values[2]);
      byte [] value = Bytes.toBytes(values[3]);

      // Create Put
      Put put = new Put(row);
      put.addColumn(family, qualifier, value);

      // Uncomment below to disable WAL. This will improve performance but means
      // you will experience data loss in the case of a RegionServer crash.
      // put.setWriteToWAL(false);

      try {
        context.write(new ImmutableBytesWritable(row), put);
      } catch (InterruptedException e) {
        LOG.error("Interrupted emitting put", e);
        Thread.currentThread().interrupt();
      }

      // Set status every checkpoint lines
      if(++count % checkpoint == 0) {
        context.setStatus("Emitting Put " + count);
      }
    }
  }

  /**
   * Job configuration.
   */
  public static Job configureJob(Configuration conf, String [] args)
  throws IOException {
    Path inputPath = new Path(args[0]);
    String tableName = args[1];
    Job job = new Job(conf, NAME + "_" + tableName);
    job.setJarByClass(Uploader.class);
    FileInputFormat.setInputPaths(job, inputPath);
    job.setInputFormatClass(SequenceFileInputFormat.class);
    job.setMapperClass(Uploader.class);
    // No reducers.  Just write straight to table.  Call initTableReducerJob
    // because it sets up the TableOutputFormat.
    TableMapReduceUtil.initTableReducerJob(tableName, null, job);
    job.setNumReduceTasks(0);
    return job;
  }

  /**
   * Main entry point.
   *
   * @param otherArgs  The command line parameters after ToolRunner handles standard.
   * @throws Exception When running the job fails.
   */
  public int run(String[] otherArgs) throws Exception {
    if(otherArgs.length != 2) {
      System.err.println("Wrong number of arguments: " + otherArgs.length);
      System.err.println("Usage: " + NAME + " <input> <tablename>");
      return -1;
    }
    Job job = configureJob(getConf(), otherArgs);
    return (job.waitForCompletion(true) ? 0 : 1);
  }

  public static void main(String[] args) throws Exception {
    int status = ToolRunner.run(HBaseConfiguration.create(), new SampleUploader(), args);
    System.exit(status);
  }
}
/**
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
package org.apache.hadoop.hbase.types;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellBuilderType;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.ExtendedCellBuilderFactory;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.protobuf.ProtobufUtil;
import org.apache.hadoop.hbase.protobuf.generated.CellProtos;
import org.apache.hadoop.hbase.testclassification.MiscTests;
import org.apache.hadoop.hbase.testclassification.SmallTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.util.PositionedByteRange;
import org.apache.hadoop.hbase.util.SimplePositionedByteRange;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({SmallTests.class, MiscTests.class})
public class TestPBCell {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestPBCell.class);

  private static final PBCell CODEC = new PBCell();

  /**
   * Basic test to verify utility methods in {@link PBType} and delegation to protobuf works.
   */
  @Test
  public void testRoundTrip() {
    final Cell cell = new KeyValue(Bytes.toBytes("row"), Bytes.toBytes("fam"),
        Bytes.toBytes("qual"), Bytes.toBytes("val"));
    CellProtos.Cell c = ProtobufUtil.toCell(cell), decoded;
    PositionedByteRange pbr = new SimplePositionedByteRange(c.getSerializedSize());
    pbr.setPosition(0);
    int encodedLength = CODEC.encode(pbr, c);
    pbr.setPosition(0);
    decoded = CODEC.decode(pbr);
    assertEquals(encodedLength, pbr.getPosition());
    assertTrue(CellUtil.equals(cell, ProtobufUtil
        .toCell(ExtendedCellBuilderFactory.create(CellBuilderType.SHALLOW_COPY), decoded)));
  }
}
/**
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
package org.apache.hadoop.hbase.client.example;

import static org.junit.Assert.assertEquals;

import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.testclassification.ClientTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.util.ToolRunner;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ ClientTests.class, MediumTests.class })
public class TestAsyncClientExample {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestAsyncClientExample.class);

  private static final HBaseTestingUtility UTIL = new HBaseTestingUtility();

  private static final TableName TABLE_NAME = TableName.valueOf("test");

  @BeforeClass
  public static void setUp() throws Exception {
    UTIL.startMiniCluster(1);
    UTIL.createTable(TABLE_NAME, Bytes.toBytes("d"));
  }

  @AfterClass
  public static void tearDown() throws Exception {
    UTIL.shutdownMiniCluster();
  }

  @Test
  public void test() throws Exception {
    AsyncClientExample tool = new AsyncClientExample();
    tool.setConf(UTIL.getConfiguration());
    assertEquals(0, ToolRunner.run(tool, new String[] { TABLE_NAME.getNameAsString() }));
  }
}
/**
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
package org.apache.hadoop.hbase.client.example;

import static org.junit.Assert.assertEquals;

import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.coprocessor.example.TestRefreshHFilesBase;
import org.apache.hadoop.hbase.regionserver.HRegion;
import org.apache.hadoop.hbase.testclassification.ClientTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.util.ToolRunner;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ ClientTests.class, MediumTests.class })
public class TestRefreshHFilesClient extends TestRefreshHFilesBase {
  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestRefreshHFilesClient.class);

  @BeforeClass
  public static void setUp() {
    setUp(HRegion.class.getName());
  }

  @Test
  public void testRefreshHFilesClient() throws Exception {
    addHFilesToRegions();
    assertEquals(2, HTU.getNumHFiles(TABLE_NAME, FAMILY));
    RefreshHFilesClient tool = new RefreshHFilesClient(HTU.getConfiguration());
    assertEquals(0, ToolRunner.run(tool, new String[] { TABLE_NAME.getNameAsString() }));
    assertEquals(4, HTU.getNumHFiles(TABLE_NAME, FAMILY));
  }
}
/**
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
package org.apache.hadoop.hbase.client.example;

import static org.junit.Assert.assertEquals;

import java.nio.charset.StandardCharsets;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.testclassification.ClientTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.http.HttpStatus;
import org.apache.http.client.entity.EntityBuilder;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.ContentType;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

import org.apache.hbase.thirdparty.com.google.common.io.ByteStreams;

@Category({ ClientTests.class, MediumTests.class })
public class TestHttpProxyExample {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestHttpProxyExample.class);

  private static final HBaseTestingUtility UTIL = new HBaseTestingUtility();

  private static final TableName TABLE_NAME = TableName.valueOf("test");

  private static final String FAMILY = "cf";

  private static final String QUALIFIER = "cq";

  private static final String URL_TEMPLCATE = "http://localhost:%d/%s/%s/%s:%s";

  private static final String ROW = "row";

  private static final String VALUE = "value";

  private static HttpProxyExample PROXY;

  private static int PORT;

  @BeforeClass
  public static void setUp() throws Exception {
    UTIL.startMiniCluster(1);
    UTIL.createTable(TABLE_NAME, Bytes.toBytes(FAMILY));
    PROXY = new HttpProxyExample(UTIL.getConfiguration(), 0);
    PROXY.start();
    PORT = PROXY.port();
  }

  @AfterClass
  public static void tearDown() throws Exception {
    if (PROXY != null) {
      PROXY.stop();
    }
    UTIL.shutdownMiniCluster();
  }

  @Test
  public void test() throws Exception {
    try (CloseableHttpClient client = HttpClientBuilder.create().build()) {
      HttpPut put = new HttpPut(
          String.format(URL_TEMPLCATE, PORT, TABLE_NAME.getNameAsString(), ROW, FAMILY, QUALIFIER));
      put.setEntity(EntityBuilder.create().setText(VALUE)
          .setContentType(ContentType.create("text-plain", StandardCharsets.UTF_8)).build());
      try (CloseableHttpResponse resp = client.execute(put)) {
        assertEquals(HttpStatus.SC_OK, resp.getStatusLine().getStatusCode());
      }
      HttpGet get = new HttpGet(
          String.format(URL_TEMPLCATE, PORT, TABLE_NAME.getNameAsString(), ROW, FAMILY, QUALIFIER));
      try (CloseableHttpResponse resp = client.execute(get)) {
        assertEquals(HttpStatus.SC_OK, resp.getStatusLine().getStatusCode());
        assertEquals("value",
          Bytes.toString(ByteStreams.toByteArray(resp.getEntity().getContent())));
      }
      get = new HttpGet(String.format(URL_TEMPLCATE, PORT, TABLE_NAME.getNameAsString(), "whatever",
        FAMILY, QUALIFIER));
      try (CloseableHttpResponse resp = client.execute(get)) {
        assertEquals(HttpStatus.SC_NOT_FOUND, resp.getStatusLine().getStatusCode());
      }
    }
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.io.IOException;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.testclassification.CoprocessorTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.ZooDefs;
import org.apache.zookeeper.ZooKeeper;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ CoprocessorTests.class, MediumTests.class })
public class TestZooKeeperScanPolicyObserver {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestZooKeeperScanPolicyObserver.class);

  private static final HBaseTestingUtility UTIL = new HBaseTestingUtility();

  private static TableName NAME = TableName.valueOf("TestCP");

  private static byte[] FAMILY = Bytes.toBytes("cf");

  private static byte[] QUALIFIER = Bytes.toBytes("cq");

  private static Table TABLE;

  @BeforeClass
  public static void setUp() throws Exception {
    UTIL.startMiniCluster(3);
    UTIL.getAdmin()
        .createTable(TableDescriptorBuilder.newBuilder(NAME)
            .setCoprocessor(ZooKeeperScanPolicyObserver.class.getName())
            .setValue(ZooKeeperScanPolicyObserver.ZK_ENSEMBLE_KEY,
              "localhost:" + UTIL.getZkCluster().getClientPort())
            .setValue(ZooKeeperScanPolicyObserver.ZK_SESSION_TIMEOUT_KEY, "2000")
            .setColumnFamily(ColumnFamilyDescriptorBuilder.newBuilder(FAMILY).build()).build());
    TABLE = UTIL.getConnection().getTable(NAME);
  }

  @AfterClass
  public static void tearDown() throws Exception {
    if (TABLE != null) {
      TABLE.close();
    }
    UTIL.shutdownMiniCluster();
  }

  private void setExpireBefore(long time)
      throws KeeperException, InterruptedException, IOException {
    ZooKeeper zk = UTIL.getZooKeeperWatcher().getRecoverableZooKeeper().getZooKeeper();
    if (zk.exists(ZooKeeperScanPolicyObserver.NODE, false) == null) {
      zk.create(ZooKeeperScanPolicyObserver.NODE, Bytes.toBytes(time), ZooDefs.Ids.OPEN_ACL_UNSAFE,
        CreateMode.PERSISTENT);
    } else {
      zk.setData(ZooKeeperScanPolicyObserver.NODE, Bytes.toBytes(time), -1);
    }
  }

  private void assertValueEquals(int start, int end) throws IOException {
    for (int i = start; i < end; i++) {
      assertEquals(i,
        Bytes.toInt(TABLE.get(new Get(Bytes.toBytes(i))).getValue(FAMILY, QUALIFIER)));
    }
  }

  private void assertNotExists(int start, int end) throws IOException {
    for (int i = start; i < end; i++) {
      assertFalse(TABLE.exists(new Get(Bytes.toBytes(i))));
    }
  }

  private void put(int start, int end, long ts) throws IOException {
    for (int i = start; i < end; i++) {
      TABLE.put(new Put(Bytes.toBytes(i)).addColumn(FAMILY, QUALIFIER, ts, Bytes.toBytes(i)));
    }
  }

  @Test
  public void test() throws IOException, KeeperException, InterruptedException {
    long now = System.currentTimeMillis();
    put(0, 100, now - 10000);
    assertValueEquals(0, 100);

    setExpireBefore(now - 5000);
    Thread.sleep(5000);
    UTIL.getAdmin().flush(NAME);
    assertNotExists(0, 100);

    put(0, 50, now - 1000);
    UTIL.getAdmin().flush(NAME);
    put(50, 100, now - 100);
    UTIL.getAdmin().flush(NAME);
    assertValueEquals(0, 100);

    setExpireBefore(now - 500);
    Thread.sleep(5000);
    UTIL.getAdmin().majorCompact(NAME);
    UTIL.waitFor(30000, () -> UTIL.getHBaseCluster().getRegions(NAME).iterator().next()
        .getStore(FAMILY).getStorefilesCount() == 1);
    assertNotExists(0, 50);
    assertValueEquals(50, 100);
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptor;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.testclassification.CoprocessorTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ CoprocessorTests.class, MediumTests.class })
public class TestValueReplacingCompaction {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestValueReplacingCompaction.class);

  private static final HBaseTestingUtility UTIL = new HBaseTestingUtility();
  private static final TableName NAME = TableName.valueOf("TestValueReplacement");
  private static final byte[] FAMILY = Bytes.toBytes("f");
  private static final byte[] QUALIFIER = Bytes.toBytes("q");
  private static final ColumnFamilyDescriptor CFD = ColumnFamilyDescriptorBuilder
      .newBuilder(FAMILY).build();
  private static final int NUM_ROWS = 5;
  private static final String value = "foo";
  private static final String replacedValue = "bar";

  @BeforeClass
  public static void setUp() throws Exception {
    UTIL.startMiniCluster(1);
    UTIL.getAdmin()
        .createTable(TableDescriptorBuilder.newBuilder(NAME)
            .setCoprocessor(ValueRewritingObserver.class.getName())
            .setValue(ValueRewritingObserver.ORIGINAL_VALUE_KEY, value)
            .setValue(ValueRewritingObserver.REPLACED_VALUE_KEY, replacedValue)
            .setColumnFamily(CFD).build());
  }

  @AfterClass
  public static void tearDown() throws Exception {
    UTIL.shutdownMiniCluster();
  }

  private void writeData(Table t) throws IOException {
    List<Put> puts = new ArrayList<>(NUM_ROWS);
    for (int i = 0; i < NUM_ROWS; i++) {
      Put p = new Put(Bytes.toBytes(i + 1));
      p.addColumn(FAMILY, QUALIFIER, Bytes.toBytes(value));
      puts.add(p);
    }
    t.put(puts);
  }

  @Test
  public void test() throws IOException, InterruptedException {
    try (Table t = UTIL.getConnection().getTable(NAME)) {
      writeData(t);

      // Flush the data
      UTIL.flush(NAME);
      // Issue a compaction
      UTIL.compact(NAME, true);

      Scan s = new Scan();
      s.addColumn(FAMILY, QUALIFIER);

      try (ResultScanner scanner = t.getScanner(s)) {
        for (int i = 0; i < NUM_ROWS; i++) {
          Result result = scanner.next();
          assertNotNull("The " + (i + 1) + "th result was unexpectedly null", result);
          assertEquals(1, result.getFamilyMap(FAMILY).size());
          assertArrayEquals(Bytes.toBytes(i + 1), result.getRow());
          assertArrayEquals(Bytes.toBytes(replacedValue), result.getValue(FAMILY, QUALIFIER));
        }
        assertNull(scanner.next());
      }
    }
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertEquals;

import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.MemoryCompactionPolicy;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.regionserver.CompactingMemStore;
import org.apache.hadoop.hbase.regionserver.HStore;
import org.apache.hadoop.hbase.testclassification.CoprocessorTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ CoprocessorTests.class, MediumTests.class })
public class TestWriteHeavyIncrementObserverWithMemStoreCompaction
    extends WriteHeavyIncrementObserverTestBase {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestWriteHeavyIncrementObserverWithMemStoreCompaction.class);

  @BeforeClass
  public static void setUp() throws Exception {
    WriteHeavyIncrementObserverTestBase.setUp();
    UTIL.getAdmin()
        .createTable(TableDescriptorBuilder.newBuilder(NAME)
            .setCoprocessor(WriteHeavyIncrementObserver.class.getName())
            .setValue(CompactingMemStore.COMPACTING_MEMSTORE_TYPE_KEY,
              MemoryCompactionPolicy.EAGER.name())
            .setColumnFamily(ColumnFamilyDescriptorBuilder.of(FAMILY)).build());
    TABLE = UTIL.getConnection().getTable(NAME);
  }

  @Test
  public void test() throws Exception {
    // sleep every 10 loops to give memstore compaction enough time to finish before reaching the
    // flush size.
    doIncrement(10);
    assertSum();
    HStore store = UTIL.getHBaseCluster().findRegionsForTable(NAME).get(0).getStore(FAMILY);
    // should have no store files created as we have done aggregating all in memory
    assertEquals(0, store.getStorefilesCount());
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptor;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.RegionInfo;
import org.apache.hadoop.hbase.client.RetriesExhaustedException;
import org.apache.hadoop.hbase.client.TableDescriptor;
import org.apache.hadoop.hbase.client.example.RefreshHFilesClient;
import org.apache.hadoop.hbase.regionserver.HRegion;
import org.apache.hadoop.hbase.regionserver.HStore;
import org.apache.hadoop.hbase.regionserver.RegionServerServices;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.hbase.wal.WAL;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category(MediumTests.class)
public class TestRefreshHFilesEndpoint extends TestRefreshHFilesBase {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestRefreshHFilesEndpoint.class);

  @Test
  public void testRefreshRegionHFilesEndpoint() throws Exception {
    setUp(HRegion.class.getName());
    addHFilesToRegions();
    assertEquals(2, HTU.getNumHFiles(TABLE_NAME, FAMILY));
    callRefreshRegionHFilesEndPoint();
    assertEquals(4, HTU.getNumHFiles(TABLE_NAME, FAMILY));
  }

  @Test(expected = IOException.class)
  public void testRefreshRegionHFilesEndpointWithException() throws IOException {
    setUp(HRegionForRefreshHFilesEP.class.getName());
    callRefreshRegionHFilesEndPoint();
  }

  private void callRefreshRegionHFilesEndPoint() throws IOException {
    try {
      RefreshHFilesClient refreshHFilesClient = new RefreshHFilesClient(CONF);
      refreshHFilesClient.refreshHFiles(TABLE_NAME);
    } catch (RetriesExhaustedException rex) {
      if (rex.getCause() instanceof IOException)
        throw new IOException();
    } catch (Throwable ex) {
      LOG.error(ex.toString(), ex);
      fail("Couldn't call the RefreshRegionHFilesEndpoint");
    }
  }

  public static class HRegionForRefreshHFilesEP extends HRegion {
    HStoreWithFaultyRefreshHFilesAPI store;

    public HRegionForRefreshHFilesEP(final Path tableDir, final WAL wal, final FileSystem fs,
                                     final Configuration confParam, final RegionInfo regionInfo,
                                     final TableDescriptor htd, final RegionServerServices rsServices) {
      super(tableDir, wal, fs, confParam, regionInfo, htd, rsServices);
    }

    @Override
    public List<HStore> getStores() {
      List<HStore> list = new ArrayList<>(stores.size());
      /**
       * This is used to trigger the custom definition (faulty)
       * of refresh HFiles API.
       */
      try {
        if (this.store == null) {
          store = new HStoreWithFaultyRefreshHFilesAPI(this,
              ColumnFamilyDescriptorBuilder.of(FAMILY), this.conf);
        }
        list.add(store);
      } catch (IOException ioe) {
        LOG.info("Couldn't instantiate custom store implementation", ioe);
      }

      list.addAll(stores.values());
      return list;
    }
  }

  public static class HStoreWithFaultyRefreshHFilesAPI extends HStore {
    public HStoreWithFaultyRefreshHFilesAPI(final HRegion region,
        final ColumnFamilyDescriptor family, final Configuration confParam) throws IOException {
      super(region, family, confParam, false);
    }

    @Override
    public void refreshStoreFiles() throws IOException {
      throw new IOException();
    }
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.stream.IntStream;

import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Increment;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.regionserver.CompactingMemStore;
import org.apache.hadoop.hbase.util.Bytes;
import org.junit.AfterClass;
import org.junit.BeforeClass;

public class WriteHeavyIncrementObserverTestBase {

  protected static final HBaseTestingUtility UTIL = new HBaseTestingUtility();

  protected static TableName NAME = TableName.valueOf("TestCP");

  protected static byte[] FAMILY = Bytes.toBytes("cf");

  protected static byte[] ROW = Bytes.toBytes("row");

  protected static byte[] CQ1 = Bytes.toBytes("cq1");

  protected static byte[] CQ2 = Bytes.toBytes("cq2");

  protected static Table TABLE;

  protected static long UPPER = 1000;

  protected static int THREADS = 10;

  @BeforeClass
  public static void setUp() throws Exception {
    UTIL.getConfiguration().setLong(HConstants.HREGION_MEMSTORE_FLUSH_SIZE, 64 * 1024L);
    UTIL.getConfiguration().setLong("hbase.hregion.memstore.flush.size.limit", 1024L);
    UTIL.getConfiguration().setDouble(CompactingMemStore.IN_MEMORY_FLUSH_THRESHOLD_FACTOR_KEY,
        0.014);
    UTIL.startMiniCluster(3);
  }

  @AfterClass
  public static void tearDown() throws Exception {
    if (TABLE != null) {
      TABLE.close();
    }
    UTIL.shutdownMiniCluster();
  }

  private static void increment(int sleepSteps) throws IOException {
    for (long i = 1; i <= UPPER; i++) {
      TABLE.increment(new Increment(ROW).addColumn(FAMILY, CQ1, i).addColumn(FAMILY, CQ2, 2 * i));
      if (sleepSteps > 0 && i % sleepSteps == 0) {
        try {
          Thread.sleep(10);
        } catch (InterruptedException e) {
        }
      }
    }
  }

  protected final void assertSum() throws IOException {
    Result result = TABLE.get(new Get(ROW).addColumn(FAMILY, CQ1).addColumn(FAMILY, CQ2));
    assertEquals(THREADS * (1 + UPPER) * UPPER / 2, Bytes.toLong(result.getValue(FAMILY, CQ1)));
    assertEquals(THREADS * (1 + UPPER) * UPPER, Bytes.toLong(result.getValue(FAMILY, CQ2)));
  }

  protected final void doIncrement(int sleepSteps) throws InterruptedException {
    Thread[] threads = IntStream.range(0, THREADS).mapToObj(i -> new Thread(() -> {
      try {
        increment(sleepSteps);
      } catch (IOException e) {
        throw new UncheckedIOException(e);
      }
    }, "increment-" + i)).toArray(Thread[]::new);
    for (Thread thread : threads) {
      thread.start();
    }
    for (Thread thread : threads) {
      thread.join();
    }
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.regionserver.HRegion;
import org.apache.hadoop.hbase.regionserver.HStore;
import org.apache.hadoop.hbase.testclassification.CoprocessorTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ CoprocessorTests.class, MediumTests.class })
public class TestWriteHeavyIncrementObserver extends WriteHeavyIncrementObserverTestBase {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestWriteHeavyIncrementObserver.class);

  @BeforeClass
  public static void setUp() throws Exception {
    WriteHeavyIncrementObserverTestBase.setUp();
    UTIL.getAdmin()
        .createTable(TableDescriptorBuilder.newBuilder(NAME)
            .setCoprocessor(WriteHeavyIncrementObserver.class.getName())
            .setColumnFamily(ColumnFamilyDescriptorBuilder.of(FAMILY)).build());
    TABLE = UTIL.getConnection().getTable(NAME);
  }

  @Test
  public void test() throws Exception {
    doIncrement(0);
    assertSum();
    // we do not hack scan operation so using scan we could get the original values added into the
    // table.
    try (ResultScanner scanner = TABLE.getScanner(new Scan().withStartRow(ROW)
      .withStopRow(ROW, true).addFamily(FAMILY).readAllVersions().setAllowPartialResults(true))) {
      Result r = scanner.next();
      assertTrue(r.rawCells().length > 2);
    }
    UTIL.flush(NAME);
    HRegion region = UTIL.getHBaseCluster().findRegionsForTable(NAME).get(0);
    HStore store = region.getStore(FAMILY);
    for (;;) {
      region.compact(true);
      if (store.getStorefilesCount() == 1) {
        break;
      }
    }
    assertSum();
    // Should only have two cells after flush and major compaction
    try (ResultScanner scanner = TABLE.getScanner(new Scan().withStartRow(ROW)
      .withStopRow(ROW, true).addFamily(FAMILY).readAllVersions().setAllowPartialResults(true))) {
      Result r = scanner.next();
      assertEquals(2, r.rawCells().length);
    }
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptor;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.testclassification.CoprocessorTests;
import org.apache.hadoop.hbase.testclassification.MediumTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;

@Category({ CoprocessorTests.class, MediumTests.class })
public class TestScanModifyingObserver {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestScanModifyingObserver.class);

  private static final HBaseTestingUtility UTIL = new HBaseTestingUtility();
  private static final TableName NAME = TableName.valueOf("TestScanModifications");
  private static final byte[] FAMILY = Bytes.toBytes("f");
  private static final ColumnFamilyDescriptor CFD = ColumnFamilyDescriptorBuilder
      .newBuilder(FAMILY).build();
  private static final int NUM_ROWS = 5;
  private static final byte[] EXPLICIT_QUAL = Bytes.toBytes("our_qualifier");
  private static final byte[] IMPLICIT_QUAL = Bytes.toBytes("their_qualifier");
  private static final byte[] EXPLICIT_VAL = Bytes.toBytes("provided");
  private static final byte[] IMPLICIT_VAL = Bytes.toBytes("implicit");

  @BeforeClass
  public static void setUp() throws Exception {
    UTIL.startMiniCluster(1);
    UTIL.getAdmin()
        .createTable(TableDescriptorBuilder.newBuilder(NAME)
            .setCoprocessor(ScanModifyingObserver.class.getName())
            .setValue(ScanModifyingObserver.FAMILY_TO_ADD_KEY, Bytes.toString(FAMILY))
            .setValue(ScanModifyingObserver.QUALIFIER_TO_ADD_KEY, Bytes.toString(IMPLICIT_QUAL))
            .setColumnFamily(CFD).build());
  }

  @AfterClass
  public static void tearDown() throws Exception {
    UTIL.shutdownMiniCluster();
  }

  private void writeData(Table t) throws IOException {
    List<Put> puts = new ArrayList<>(NUM_ROWS);
    for (int i = 0; i < NUM_ROWS; i++) {
      Put p = new Put(Bytes.toBytes(i + 1));
      p.addColumn(FAMILY, EXPLICIT_QUAL, EXPLICIT_VAL);
      p.addColumn(FAMILY, IMPLICIT_QUAL, IMPLICIT_VAL);
      puts.add(p);
    }
    t.put(puts);
  }

  @Test
  public void test() throws IOException {
    try (Table t = UTIL.getConnection().getTable(NAME)) {
      writeData(t);

      Scan s = new Scan();
      s.addColumn(FAMILY, EXPLICIT_QUAL);

      try (ResultScanner scanner = t.getScanner(s)) {
        for (int i = 0; i < NUM_ROWS; i++) {
          Result result = scanner.next();
          assertNotNull("The " + (i + 1) + "th result was unexpectedly null", result);
          assertEquals(2, result.getFamilyMap(FAMILY).size());
          assertArrayEquals(Bytes.toBytes(i + 1), result.getRow());
          assertArrayEquals(EXPLICIT_VAL, result.getValue(FAMILY, EXPLICIT_QUAL));
          assertArrayEquals(IMPLICIT_VAL, result.getValue(FAMILY, IMPLICIT_QUAL));
        }
        assertNull(scanner.next());
      }
    }
  }
}
/**
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
package org.apache.hadoop.hbase.coprocessor.example;

import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.MiniHBaseCluster;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.coprocessor.CoprocessorHost;
import org.apache.hadoop.hbase.master.MasterFileSystem;
import org.apache.hadoop.hbase.regionserver.Region;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.util.FSUtils;
import org.apache.hadoop.hbase.util.HFileTestUtil;
import org.junit.After;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestRefreshHFilesBase {
  protected static final Logger LOG = LoggerFactory.getLogger(TestRefreshHFilesBase.class);
  protected static final HBaseTestingUtility HTU = new HBaseTestingUtility();
  protected static final int NUM_RS = 2;
  protected static final TableName TABLE_NAME = TableName.valueOf("testRefreshRegionHFilesEP");
  protected static final byte[] FAMILY = Bytes.toBytes("family");
  protected static final byte[] QUALIFIER = Bytes.toBytes("qualifier");
  protected static final byte[][] SPLIT_KEY = new byte[][] { Bytes.toBytes("30") };
  protected static final int NUM_ROWS = 5;
  protected static final String HFILE_NAME = "123abcdef";

  protected static Configuration CONF = HTU.getConfiguration();
  protected static MiniHBaseCluster cluster;
  protected static Table table;

  public static void setUp(String regionImpl) {
    try {
      CONF.set(HConstants.REGION_IMPL, regionImpl);
      CONF.setInt(HConstants.HBASE_CLIENT_RETRIES_NUMBER, 2);

      CONF.setStrings(CoprocessorHost.REGION_COPROCESSOR_CONF_KEY, RefreshHFilesEndpoint.class.getName());
      cluster = HTU.startMiniCluster(NUM_RS);

      // Create table
      table = HTU.createTable(TABLE_NAME, FAMILY, SPLIT_KEY);

      // this will create 2 regions spread across slaves
      HTU.loadNumericRows(table, FAMILY, 1, 20);
      HTU.flush(TABLE_NAME);
    } catch (Exception ex) {
      LOG.error("Couldn't finish setup", ex);
    }
  }

  @After
  public void tearDown() throws Exception {
    HTU.shutdownMiniCluster();
  }

  protected void addHFilesToRegions() throws IOException {
    MasterFileSystem mfs = HTU.getMiniHBaseCluster().getMaster().getMasterFileSystem();
    Path tableDir = FSUtils.getTableDir(mfs.getRootDir(), TABLE_NAME);
    for (Region region : cluster.getRegions(TABLE_NAME)) {
      Path regionDir = new Path(tableDir, region.getRegionInfo().getEncodedName());
      Path familyDir = new Path(regionDir, Bytes.toString(FAMILY));
      HFileTestUtil
          .createHFile(HTU.getConfiguration(), HTU.getTestFileSystem(), new Path(familyDir, HFILE_NAME), FAMILY,
              QUALIFIER, Bytes.toBytes("50"), Bytes.toBytes("60"), NUM_ROWS);
    }
  }
}
/**
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
package org.apache.hadoop.hbase.mapreduce;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseClassTestRule;
import org.apache.hadoop.hbase.HBaseTestingUtility;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.IndexBuilder.Map;
import org.apache.hadoop.hbase.mapreduce.SampleUploader.Uploader;
import org.apache.hadoop.hbase.testclassification.LargeTests;
import org.apache.hadoop.hbase.testclassification.MapReduceTests;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.util.LauncherSecurityManager;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Mapper.Context;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

@Category({MapReduceTests.class, LargeTests.class})
public class TestMapReduceExamples {

  @ClassRule
  public static final HBaseClassTestRule CLASS_RULE =
      HBaseClassTestRule.forClass(TestMapReduceExamples.class);

  private static HBaseTestingUtility util = new HBaseTestingUtility();

  /**
   * Test SampleUploader from examples
   */

  @SuppressWarnings("unchecked")
  @Test
  public void testSampleUploader() throws Exception {

    Configuration configuration = new Configuration();
    Uploader uploader = new Uploader();
    Mapper<LongWritable, Text, ImmutableBytesWritable, Put>.Context ctx = mock(Context.class);
    doAnswer(new Answer<Void>() {

      @Override
      public Void answer(InvocationOnMock invocation) throws Throwable {
        ImmutableBytesWritable writer = (ImmutableBytesWritable) invocation.getArgument(0);
        Put put = (Put) invocation.getArgument(1);
        assertEquals("row", Bytes.toString(writer.get()));
        assertEquals("row", Bytes.toString(put.getRow()));
        return null;
      }
    }).when(ctx).write(any(), any());

    uploader.map(null, new Text("row,family,qualifier,value"), ctx);

    Path dir = util.getDataTestDirOnTestFS("testSampleUploader");

    String[] args = { dir.toString(), "simpleTable" };
    Job job = SampleUploader.configureJob(configuration, args);
    assertEquals(SequenceFileInputFormat.class, job.getInputFormatClass());

  }

  /**
   * Test main method of SampleUploader.
   */
  @Test
  public void testMainSampleUploader() throws Exception {
    PrintStream oldPrintStream = System.err;
    SecurityManager SECURITY_MANAGER = System.getSecurityManager();
    LauncherSecurityManager newSecurityManager= new LauncherSecurityManager();
    System.setSecurityManager(newSecurityManager);
    ByteArrayOutputStream data = new ByteArrayOutputStream();
    String[] args = {};
    System.setErr(new PrintStream(data));
    try {
      System.setErr(new PrintStream(data));

      try {
        SampleUploader.main(args);
        fail("should be SecurityException");
      } catch (SecurityException e) {
        assertEquals(-1, newSecurityManager.getExitCode());
        assertTrue(data.toString().contains("Wrong number of arguments:"));
        assertTrue(data.toString().contains("Usage: SampleUploader <input> <tablename>"));
      }

    } finally {
      System.setErr(oldPrintStream);
      System.setSecurityManager(SECURITY_MANAGER);
    }

  }

  /**
   * Test IndexBuilder from examples
   */
  @SuppressWarnings("unchecked")
  @Test
  public void testIndexBuilder() throws Exception {
    Configuration configuration = new Configuration();
    String[] args = { "tableName", "columnFamily", "column1", "column2" };
    IndexBuilder.configureJob(configuration, args);
    assertEquals("tableName", configuration.get("index.tablename"));
    assertEquals("tableName", configuration.get(TableInputFormat.INPUT_TABLE));
    assertEquals("column1,column2", configuration.get("index.fields"));

    Map map = new Map();
    ImmutableBytesWritable rowKey = new ImmutableBytesWritable(Bytes.toBytes("test"));
    Mapper<ImmutableBytesWritable, Result, ImmutableBytesWritable, Put>.Context ctx =
        mock(Context.class);
    when(ctx.getConfiguration()).thenReturn(configuration);
    doAnswer(new Answer<Void>() {

      @Override
      public Void answer(InvocationOnMock invocation) throws Throwable {
        ImmutableBytesWritable writer = (ImmutableBytesWritable) invocation.getArgument(0);
        Put put = (Put) invocation.getArgument(1);
        assertEquals("tableName-column1", Bytes.toString(writer.get()));
        assertEquals("test", Bytes.toString(put.getRow()));
        return null;
      }
    }).when(ctx).write(any(), any());
    Result result = mock(Result.class);
    when(result.getValue(Bytes.toBytes("columnFamily"), Bytes.toBytes("column1"))).thenReturn(
        Bytes.toBytes("test"));
    map.setup(ctx);
    map.map(rowKey, result, ctx);
  }

  /**
   * Test main method of IndexBuilder
   */
  @Test
  public void testMainIndexBuilder() throws Exception {
    PrintStream oldPrintStream = System.err;
    SecurityManager SECURITY_MANAGER = System.getSecurityManager();
    LauncherSecurityManager newSecurityManager= new LauncherSecurityManager();
    System.setSecurityManager(newSecurityManager);
    ByteArrayOutputStream data = new ByteArrayOutputStream();
    String[] args = {};
    System.setErr(new PrintStream(data));
    try {
      System.setErr(new PrintStream(data));
      try {
        IndexBuilder.main(args);
        fail("should be SecurityException");
      } catch (SecurityException e) {
        assertEquals(-1, newSecurityManager.getExitCode());
        assertTrue(data.toString().contains("arguments supplied, required: 3"));
        assertTrue(data.toString().contains(
            "Usage: IndexBuilder <TABLE_NAME> <COLUMN_FAMILY> <ATTR> [<ATTR> ...]"));
      }

    } finally {
      System.setErr(oldPrintStream);
      System.setSecurityManager(SECURITY_MANAGER);
    }

  }
}
