
module Shell
  module Commands
    class AddLabels < Command
      def help
        <<-EOF
Add a set of visibility labels.
Syntax : add_labels [label1, label2]

For example:

    hbase> add_labels ['SECRET','PRIVATE']
EOF
      end

      def command(*args)
        visibility_labels_admin.add_labels(args)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AddPeer < Command
      def help
        <<-EOF
A peer can either be another HBase cluster or a custom replication endpoint. In either case an id
must be specified to identify the peer.

For a HBase cluster peer, a cluster key must be provided and is composed like this:
hbase.zookeeper.quorum:hbase.zookeeper.property.clientPort:zookeeper.znode.parent
This gives a full path for HBase to connect to another HBase cluster.
An optional parameter for state identifies the replication peer's state is enabled or disabled.
And the default state is enabled.
An optional parameter for namespaces identifies which namespace's tables will be replicated
to the peer cluster.
An optional parameter for table column families identifies which tables and/or column families
will be replicated to the peer cluster.
An optional parameter for serial flag identifies whether or not the replication peer is a serial
replication peer. The default serial flag is false.

Note: Set a namespace in the peer config means that all tables in this namespace
will be replicated to the peer cluster. So if you already have set a namespace in peer config,
then you can't set this namespace's tables in the peer config again.

Examples:

  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase"
  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase", STATE => "ENABLED"
  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase", STATE => "DISABLED"
  hbase> add_peer '2', CLUSTER_KEY => "zk1,zk2,zk3:2182:/hbase-prod",
    TABLE_CFS => { "table1" => [], "table2" => ["cf1"], "table3" => ["cf1", "cf2"] }
  hbase> add_peer '2', CLUSTER_KEY => "zk1,zk2,zk3:2182:/hbase-prod",
    NAMESPACES => ["ns1", "ns2", "ns3"]
  hbase> add_peer '2', CLUSTER_KEY => "zk1,zk2,zk3:2182:/hbase-prod",
    NAMESPACES => ["ns1", "ns2"], TABLE_CFS => { "ns3:table1" => [], "ns3:table2" => ["cf1"] }
  hbase> add_peer '3', CLUSTER_KEY => "zk1,zk2,zk3:2182:/hbase-prod",
    NAMESPACES => ["ns1", "ns2", "ns3"], SERIAL => true

For a custom replication endpoint, the ENDPOINT_CLASSNAME can be provided. Two optional arguments
are DATA and CONFIG which can be specified to set different either the peer_data or configuration
for the custom replication endpoint. Table column families is optional and can be specified with
the key TABLE_CFS.

  hbase> add_peer '6', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint'
  hbase> add_peer '7', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint',
    DATA => { "key1" => 1 }
  hbase> add_peer '8', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint',
    CONFIG => { "config1" => "value1", "config2" => "value2" }
  hbase> add_peer '9', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint',
    DATA => { "key1" => 1 }, CONFIG => { "config1" => "value1", "config2" => "value2" },
  hbase> add_peer '10', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint',
    TABLE_CFS => { "table1" => [], "ns2:table2" => ["cf1"], "ns3:table3" => ["cf1", "cf2"] }
  hbase> add_peer '11', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint',
    DATA => { "key1" => 1 }, CONFIG => { "config1" => "value1", "config2" => "value2" },
    TABLE_CFS => { "table1" => [], "ns2:table2" => ["cf1"], "ns3:table3" => ["cf1", "cf2"] }
  hbase> add_peer '12', ENDPOINT_CLASSNAME => 'org.apache.hadoop.hbase.MyReplicationEndpoint',
        CLUSTER_KEY => "server2.cie.com:2181:/hbase"

Note: Either CLUSTER_KEY or ENDPOINT_CLASSNAME must be specified. If ENDPOINT_CLASSNAME is specified, CLUSTER_KEY is
optional and should only be specified if a particular custom endpoint requires it.

The default replication peer is asynchronous. You can also add a synchronous replication peer
with REMOTE_WAL_DIR parameter. Meanwhile, synchronous replication peer also support other optional
config for asynchronous replication peer.

Examples:

  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase",
    REMOTE_WAL_DIR => "hdfs://srv1:9999/hbase"
  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase",
    STATE => "ENABLED", REMOTE_WAL_DIR => "hdfs://srv1:9999/hbase"
  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase",
    STATE => "DISABLED", REMOTE_WAL_DIR => "hdfs://srv1:9999/hbase"
  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase",
    REMOTE_WAL_DIR => "hdfs://srv1:9999/hbase", NAMESPACES => ["ns1", "ns2"]
  hbase> add_peer '1', CLUSTER_KEY => "server1.cie.com:2181:/hbase",
    REMOTE_WAL_DIR => "hdfs://srv1:9999/hbase", TABLE_CFS => { "table1" => [] }

Note: The REMOTE_WAL_DIR is not allowed to change.

EOF
      end

      def command(id, args = {}, peer_tableCFs = nil)
        replication_admin.add_peer(id, args, peer_tableCFs)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AddRsgroup < Command
      def help
        <<-EOF
Create a new RegionServer group.

Example:

  hbase> add_rsgroup 'my_group'

EOF
      end

      def command(group_name)
        rsgroup_admin.add_rs_group(group_name)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AlterAsync < Command
      def help
        <<-EOF
Alter column family schema, does not wait for all regions to receive the
schema changes. Pass table name and a dictionary specifying new column
family schema. Dictionaries are described on the main help command output.
Dictionary must include name of column family to alter. For example,

To change or add the 'f1' column family in table 't1' from defaults
to instead keep a maximum of 5 cell VERSIONS, do:

  hbase> alter_async 't1', NAME => 'f1', VERSIONS => 5

To delete the 'f1' column family in table 'ns1:t1', do:

  hbase> alter_async 'ns1:t1', NAME => 'f1', METHOD => 'delete'

or a shorter version:

  hbase> alter_async 'ns1:t1', 'delete' => 'f1'

You can also change table-scope attributes like MAX_FILESIZE,
MEMSTORE_FLUSHSIZE, and READONLY.

For example, to change the max size of a family to 128MB, do:

  hbase> alter 't1', METHOD => 'table_att', MAX_FILESIZE => '134217728'

There could be more than one alteration in one command:

  hbase> alter 't1', {NAME => 'f1'}, {NAME => 'f2', METHOD => 'delete'}

To check if all the regions have been updated, use alter_status <table_name>
EOF
      end

      def command(table, *args)
        admin.alter(table, false, *args)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AlterNamespace < Command
      def help
        <<-EOF
Alter namespace properties.

To add/modify a property:

  hbase> alter_namespace 'ns1', {METHOD => 'set', 'PROPERTY_NAME' => 'PROPERTY_VALUE'}

To delete a property:

  hbase> alter_namespace 'ns1', {METHOD => 'unset', NAME=>'PROPERTY_NAME'}
EOF
      end

      def command(namespace, *args)
        admin.alter_namespace(namespace, *args)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Alter < Command
      def help
        <<-EOF
Alter a table. Tables can be altered without disabling them first.
Altering enabled tables has caused problems
in the past, so use caution and test it before using in production.

You can use the alter command to add,
modify or delete column families or change table configuration options.
Column families work in a similar way as the 'create' command. The column family
specification can either be a name string, or a dictionary with the NAME attribute.
Dictionaries are described in the output of the 'help' command, with no arguments.

For example, to change or add the 'f1' column family in table 't1' from
current value to keep a maximum of 5 cell VERSIONS, do:

  hbase> alter 't1', NAME => 'f1', VERSIONS => 5

You can operate on several column families:

  hbase> alter 't1', 'f1', {NAME => 'f2', IN_MEMORY => true}, {NAME => 'f3', VERSIONS => 5}

To delete the 'f1' column family in table 'ns1:t1', use one of:

  hbase> alter 'ns1:t1', NAME => 'f1', METHOD => 'delete'
  hbase> alter 'ns1:t1', 'delete' => 'f1'

You can also change table-scope attributes like MAX_FILESIZE, READONLY,
MEMSTORE_FLUSHSIZE, NORMALIZATION_ENABLED, NORMALIZER_TARGET_REGION_COUNT,
NORMALIZER_TARGET_REGION_SIZE(MB), DURABILITY, etc. These can be put at the end;
for example, to change the max size of a region to 128MB, do:

  hbase> alter 't1', MAX_FILESIZE => '134217728'

You can add a table coprocessor by setting a table coprocessor attribute:

  hbase> alter 't1',
    'coprocessor'=>'hdfs:///foo.jar|com.foo.FooRegionObserver|1001|arg1=1,arg2=2'

Since you can have multiple coprocessors configured for a table, a
sequence number will be automatically appended to the attribute name
to uniquely identify it.

The coprocessor attribute must match the pattern below in order for
the framework to understand how to load the coprocessor classes:

  [coprocessor jar file location] | class name | [priority] | [arguments]

You can also set configuration settings specific to this table or column family:

  hbase> alter 't1', CONFIGURATION => {'hbase.hregion.scan.loadColumnFamiliesOnDemand' => 'true'}
  hbase> alter 't1', {NAME => 'f2', CONFIGURATION => {'hbase.hstore.blockingStoreFiles' => '10'}}

You can also unset configuration settings specific to this table:

  hbase> alter 't1', METHOD => 'table_conf_unset', NAME => 'hbase.hregion.majorcompaction'

You can also remove a table-scope attribute:

  hbase> alter 't1', METHOD => 'table_att_unset', NAME => 'MAX_FILESIZE'

  hbase> alter 't1', METHOD => 'table_att_unset', NAME => 'coprocessor$1'

You can also set REGION_REPLICATION:

  hbase> alter 't1', {REGION_REPLICATION => 2}

You can disable/enable table split and/or merge:

  hbase> alter 't1', {SPLIT_ENABLED => false}
  hbase> alter 't1', {MERGE_ENABLED => false}

There could be more than one alteration in one command:

  hbase> alter 't1', { NAME => 'f1', VERSIONS => 3 },
   { MAX_FILESIZE => '134217728' }, { METHOD => 'delete', NAME => 'f2' },
   OWNER => 'johndoe', METADATA => { 'mykey' => 'myvalue' }
EOF
      end

      def command(table, *args)
        admin.alter(table, true, *args)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AlterStatus < Command
      def help
        <<-EOF
Get the status of the alter command. Indicates the number of regions of the
table that have received the updated schema
Pass table name.

hbase> alter_status 't1'
hbase> alter_status 'ns1:t1'
EOF
      end

      def command(table)
        admin.alter_status(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AppendPeerExcludeNamespaces < Command
      def help
        <<-EOF
Append the namespaces which not replicated for the specified peer.

Note:
  1. The replicate_all flag need to be true when append exclude namespaces.
  2. Append a exclude namespace in the peer config means that all tables in this
     namespace will not be replicated to the peer cluster. If peer config
     already has a exclude table, then not allow append this table's namespace
     as a exclude namespace.

Examples:

    # append ns1,ns2 to be not replicable for peer '2'.
    hbase> append_peer_exclude_namespaces '2', ["ns1", "ns2"]

        EOF
      end

      def command(id, namespaces)
        replication_admin.append_peer_exclude_namespaces(id, namespaces)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AppendPeerExcludeTableCFs < Command
      def help
        <<-EOF
Append table-cfs config to the specified peer' exclude table-cfs to make them non-replicable
Examples:

  # append tables / table-cfs to peers' exclude table-cfs
  hbase> append_peer_exclude_tableCFs '2', { "table1" => [], "ns2:table2" => ["cfA", "cfB"]}
        EOF
      end

      def command(id, table_cfs)
        replication_admin.append_peer_exclude_tableCFs(id, table_cfs)
      end

      def command_name
        'append_peer_exclude_tableCFs'
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AppendPeerNamespaces < Command
      def help
        <<-EOF
  Append some namespaces to be replicable for the specified peer.

  Set a namespace in the peer config means that all tables in this
  namespace (with replication_scope != 0 ) will be replicated.

  Examples:

    # append ns1,ns2 to be replicable for peer '2'.
    hbase> append_peer_namespaces '2', ["ns1", "ns2"]

  EOF
      end

      def command(id, namespaces)
        replication_admin.add_peer_namespaces(id, namespaces)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class AppendPeerTableCFs < Command
      def help
        <<-EOF
Append a replicable table-cf config for the specified peer
Examples:

  # append a table / table-cf to be replicable for a peer
  hbase> append_peer_tableCFs '2', { "ns1:table4" => ["cfA", "cfB"]}

EOF
      end

      def command(id, table_cfs)
        replication_admin.append_peer_tableCFs(id, table_cfs)
      end

      def command_name
        'append_peer_tableCFs'
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Append < Command
      def help
        <<-EOF
Appends a cell 'value' at specified table/row/column coordinates.

  hbase> append 't1', 'r1', 'c1', 'value', ATTRIBUTES=>{'mykey'=>'myvalue'}
  hbase> append 't1', 'r1', 'c1', 'value', {VISIBILITY=>'PRIVATE|SECRET'}

The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.append 'r1', 'c1', 'value', ATTRIBUTES=>{'mykey'=>'myvalue'}
  hbase> t.append 'r1', 'c1', 'value', {VISIBILITY=>'PRIVATE|SECRET'}
EOF
      end

      def command(table_name, row, column, value, args = {})
        table = table(table_name)
        @start_time = Time.now
        append(table, row, column, value, args)
      end

      def append(table, row, column, value, args = {})
        if current_value = table._append_internal(row, column, value, args)
          puts "CURRENT VALUE = #{current_value}"
        end
      end
    end
  end
end

# add incr comamnd to Table
::Hbase::Table.add_shell_command('append')
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Assign < Command
      def help
        <<-EOF
Assign a region. Use with caution. If region already assigned,
this command will do a force reassign. For experts only.
Examples:

  hbase> assign 'REGIONNAME'
  hbase> assign 'ENCODED_REGIONNAME'
EOF
      end

      def command(region_name)
        admin.assign(region_name)
      end
    end
  end
end
#!/usr/bin/env hbase-jruby
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with this
# work for additional information regarding copyright ownership. The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Prints the current balancer status

module Shell
  module Commands
    class BalancerEnabled < Command
      def help
        <<-EOF
Query the balancer's state.
Examples:

  hbase> balancer_enabled
EOF
      end

      def command
        state = admin.balancer_enabled?
        formatter.row([state.to_s])
        state
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Balancer < Command
      def help
        <<-EOF
Trigger the cluster balancer. Returns true if balancer ran and was able to
tell the region servers to unassign all the regions to balance  (the re-assignment itself is async).
Otherwise false (Will not run if regions in transition).
Parameter tells master whether we should force balance even if there is region in transition.

WARNING: For experts only. Forcing a balance may do more damage than repair
when assignment is confused

Examples:

  hbase> balancer
  hbase> balancer "force"
EOF
      end

      def command(force = nil)
        force_balancer = 'false'
        if force == 'force'
          force_balancer = 'true'
        elsif !force.nil?
          raise ArgumentError, "Invalid argument #{force}."
        end
        formatter.row([admin.balancer(force_balancer) ? 'true' : 'false'])
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class BalanceRsgroup < Command
      def help
        <<-EOF
Balance a RegionServer group

Example:

  hbase> balance_rsgroup 'my_group'

EOF
      end

      def command(group_name)
        # Returns true if balancer was run, otherwise false.
        ret = rsgroup_admin.balance_rs_group(group_name)
        if ret
          puts 'Ran the balancer.'
        else
          puts "Couldn't run the balancer."
        end
        ret
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class BalanceSwitch < Command
      def help
        <<-EOF
Enable/Disable balancer. Returns previous balancer state.
Examples:

  hbase> balance_switch true
  hbase> balance_switch false
EOF
      end

      def command(enableDisable)
        prev_state = admin.balance_switch(enableDisable) ? 'true' : 'false'
        formatter.row(["Previous balancer state : #{prev_state}"])
        prev_state
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CatalogjanitorEnabled < Command
      def help
        <<-EOF
Query for the CatalogJanitor state (enabled/disabled?)
Examples:

  hbase> catalogjanitor_enabled
EOF
      end

      def command
        formatter.row([admin.catalogjanitor_enabled ? 'true' : 'false'])
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CatalogjanitorRun < Command
      def help
        <<-EOF
Catalog janitor command to run the (garbage collection) scan from command line.

  hbase> catalogjanitor_run

EOF
      end

      def command
        admin.catalogjanitor_run
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CatalogjanitorSwitch < Command
      def help
        <<-EOF
Enable/Disable CatalogJanitor. Returns previous CatalogJanitor state.
Examples:

  hbase> catalogjanitor_switch true
  hbase> catalogjanitor_switch false
EOF
      end

      def command(enableDisable)
        formatter.row([admin.catalogjanitor_switch(enableDisable) ? 'true' : 'false'])
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CleanerChoreEnabled < Command
      def help
        <<-EOF
Query for the Cleaner chore state (enabled/disabled?).
Examples:

  hbase> cleaner_chore_enabled
EOF
      end

      def command
        formatter.row([admin.cleaner_chore_enabled ? 'true' : 'false'])
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CleanerChoreRun < Command
      def help
        <<-EOF
Cleaner chore command for garbage collection of HFiles and WAL files.

  hbase> cleaner_chore_run

EOF
      end

      def command
        admin.cleaner_chore_run
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CleanerChoreSwitch < Command
      def help
        <<-EOF
Enable/Disable Cleaner chore. Returns previous Cleaner chore state.
Examples:

  hbase> cleaner_chore_switch true
  hbase> cleaner_chore_switch false
EOF
      end

      def command(enableDisable)
        formatter.row([admin.cleaner_chore_switch(enableDisable) ? 'true' : 'false'])
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ClearAuths < Command
      def help
        <<-EOF
Clear visibility labels from a user or group
Syntax : clear_auths 'user',[label1, label2]

For example:

    hbase> clear_auths 'user1', ['SECRET','PRIVATE']
    hbase> clear_auths '@group1', ['SECRET','PRIVATE']
EOF
      end

      def command(user, *args)
        visibility_labels_admin.clear_auths(user, args)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ClearBlockCache < Command
      def help
        <<-EOF
Clear all the blocks corresponding to this table from BlockCache. For expert-admins.
Calling this API will drop all the cached blocks specific to a table from BlockCache.
This can significantly impact the query performance as the subsequent queries will
have to retrieve the blocks from underlying filesystem.
For example:

  hbase> clear_block_cache 'TABLENAME'
EOF
      end

      def command(table_name)
        formatter.row([admin.clear_block_cache(table_name)])
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ClearCompactionQueues < Command
      def help
        <<-EOF
          Clear compacting queues on a regionserver.
          The queue_name contains short and long.
          short is shortCompactions's queue,long is longCompactions's queue.

          Examples:
          hbase> clear_compaction_queues 'host187.example.com,60020'
          hbase> clear_compaction_queues 'host187.example.com,60020','long'
          hbase> clear_compaction_queues 'host187.example.com,60020', ['long','short']
        EOF
      end

      def command(server_name, queue_name = nil)
        admin.clear_compaction_queues(server_name, queue_name)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ClearDeadservers < Command
      def help
        <<-EOF
          Clear the dead region servers that are never used.
          Examples:
          Clear all dead region servers:
          hbase> clear_deadservers
          Clear the specified dead region servers:
          hbase> clear_deadservers 'host187.example.com,60020,1289493121758'
          or
          hbase> clear_deadservers 'host187.example.com,60020,1289493121758',
                                   'host188.example.com,60020,1289493121758'
        EOF
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def command(*dead_servers)
        now = Time.now
        servers = admin.clear_deadservers(dead_servers)
        if servers.size <= 0
          formatter.row(['true'])
        else
          formatter.row(['Some dead server clear failed'])
          formatter.row(['SERVERNAME'])
          servers.each do |server|
            formatter.row([server.toString])
          end
          formatter.footer(now, servers.size)
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CloneSnapshot < Command
      def help
        <<-EOF
Create a new table by cloning the snapshot content.
There're no copies of data involved.
And writing on the newly created table will not influence the snapshot data.

Examples:
  hbase> clone_snapshot 'snapshotName', 'tableName'
  hbase> clone_snapshot 'snapshotName', 'namespace:tableName'

Following command will restore all acl from origin snapshot table into the
newly created table.

  hbase> clone_snapshot 'snapshotName', 'namespace:tableName', {RESTORE_ACL=>true}
EOF
      end

      def command(snapshot_name, table, args = {})
        raise(ArgumentError, 'Arguments should be a Hash') unless args.is_a?(Hash)
        restore_acl = args.delete(RESTORE_ACL) || false
        admin.clone_snapshot(snapshot_name, table, restore_acl)
      end

      def handle_exceptions(cause, *args)
        if cause.is_a?(org.apache.hadoop.hbase.TableExistsException)
          tableName = args[1]
          raise "Table already exists: #{tableName}!"
        end
        if cause.is_a?(org.apache.hadoop.hbase.NamespaceNotFoundException)
          namespace_name = args[1].split(':')[0]
          raise "Unknown namespace: #{namespace_name}!"
        end
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # create a new table by cloning the existent table schema.
    class CloneTableSchema < Command
      def help
        <<-HELP
          Create a new table by cloning the existent table schema.
          There're no copies of data involved.
          Just copy the table descriptor and split keys.

          Passing 'false' as the optional third parameter will
          not preserve split keys.
          Examples:
            hbase> clone_table_schema 'table_name', 'new_table_name'
            hbase> clone_table_schema 'table_name', 'new_table_name', false
        HELP
      end

      def command(table_name, new_table_name, preserve_splits = true)
        admin.clone_table_schema(table_name, new_table_name, preserve_splits)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CloseRegion < Command
      def help
        <<-EOF
---------------------------------------------
DEPRECATED!!! Use 'unassign' command instead.
---------------------------------------------
EOF
      end

      def command(region_name, server = nil)
        puts "DEPRECATED!!! Use 'unassign' command instead."
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CompactionState < Command
      def help
        <<-EOF
          Gets compaction status (MAJOR, MAJOR_AND_MINOR, MINOR, NONE) for a table:
          hbase> compaction_state 'ns1:t1'
          hbase> compaction_state 't1'
        EOF
      end

      def command(table_name)
        rv = admin.getCompactionState(table_name)
        formatter.row([rv])
        rv
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Switch compaction for a region server
    class CompactionSwitch < Command
      def help
        <<-EOF
          Turn the compaction on or off on regionservers. Disabling compactions will also interrupt
          any currently ongoing compactions. This state is ephemeral. The setting will be lost on
          restart of the server. Compaction can also be enabled/disabled by modifying configuration
          hbase.regionserver.compaction.enabled in hbase-site.xml.
          Examples:
            To enable compactions on all region servers
            hbase> compaction_switch true
            To disable compactions on all region servers
            hbase> compaction_switch false
            To enable compactions on specific region servers
            hbase> compaction_switch true 'server2','server1'
            To disable compactions on specific region servers
            hbase> compaction_switch false 'server2','server1'
          NOTE: A server name is its host, port plus startcode. For example:
          host187.example.com,60020,1289493121758
        EOF
      end

      def command(enable_disable, *server)
        formatter.header(%w(['SERVER' 'PREV_STATE']))
        prev_state = admin.compaction_switch(enable_disable, server)
        prev_state.each { |k, v| formatter.row([k.getServerName, java.lang.String.valueOf(v)]) }
        formatter.footer(prev_state.size)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Compact < Command
      def help
        <<-EOF
          Compact all regions in passed table or pass a region row
          to compact an individual region. You can also compact a single column
          family within a region.
          You can also set compact type, "NORMAL" or "MOB", and default is "NORMAL"
          Examples:
          Compact all regions in a table:
          hbase> compact 'ns1:t1'
          hbase> compact 't1'
          Compact an entire region:
          hbase> compact 'r1'
          Compact only a column family within a region:
          hbase> compact 'r1', 'c1'
          Compact a column family within a table:
          hbase> compact 't1', 'c1'
          Compact table with type "MOB"
          hbase> compact 't1', nil, 'MOB'
          Compact a column family using "MOB" type within a table
          hbase> compact 't1', 'c1', 'MOB'
        EOF
      end

      def command(table_or_region_name, family = nil, type = 'NORMAL')
        admin.compact(table_or_region_name, family, type)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CompactRs < Command
      def help
        <<-EOF
          Compact all regions on passed regionserver.
          Examples:
          Compact all regions on a regionserver:
          hbase> compact_rs 'host187.example.com,60020'
          or
          hbase> compact_rs 'host187.example.com,60020,1289493121758'
          Major compact all regions on a regionserver:
          hbase> compact_rs 'host187.example.com,60020,1289493121758', true
        EOF
      end

      def command(regionserver, major = false)
        admin.compact_regionserver(regionserver, major)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Count < Command
      def help
        <<-EOF
Count the number of rows in a table.  Return value is the number of rows.
This operation may take a LONG time (Run '$HADOOP_HOME/bin/hadoop jar
hbase.jar rowcount' to run a counting mapreduce job). Current count is shown
every 1000 rows by default. Count interval may be optionally specified. Scan
caching is enabled on count scans by default. Default cache size is 10 rows.
If your rows are small in size, you may want to increase this
parameter. Examples:

 hbase> count 'ns1:t1'
 hbase> count 't1'
 hbase> count 't1', INTERVAL => 100000
 hbase> count 't1', CACHE => 1000
 hbase> count 't1', INTERVAL => 10, CACHE => 1000
 hbase> count 't1', FILTER => "
    (QualifierFilter (>=, 'binary:xyz')) AND (TimestampsFilter ( 123, 456))"
 hbase> count 't1', COLUMNS => ['c1', 'c2'], STARTROW => 'abc', STOPROW => 'xyz'

The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding commands would be:

 hbase> t.count
 hbase> t.count INTERVAL => 100000
 hbase> t.count CACHE => 1000
 hbase> t.count INTERVAL => 10, CACHE => 1000
 hbase> t.count FILTER => "
    (QualifierFilter (>=, 'binary:xyz')) AND (TimestampsFilter ( 123, 456))"
 hbase> t.count COLUMNS => ['c1', 'c2'], STARTROW => 'abc', STOPROW => 'xyz'
EOF
      end

      def command(table, params = {})
        count(table(table), params)
      end

      def count(table, params = {})
        # If the second parameter is an integer, then it is the old command syntax
        params = { 'INTERVAL' => params } if params.is_a?(Integer)

        # Merge params with defaults
        params = {
          'INTERVAL' => 1000,
          'CACHE' => 10
        }.merge(params)

        scan = table._hash_to_scan(params)
        # Call the counter method
        @start_time = Time.now
        formatter.header
        count = table._count_internal(params['INTERVAL'].to_i, scan) do |cnt, row|
          formatter.row(["Current count: #{cnt}, row: #{row}"])
        end
        formatter.footer(count)
        count
      end
    end
  end
end

# Add the method table.count that calls count.count
::Hbase::Table.add_shell_command('count')
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class CreateNamespace < Command
      def help
        <<-EOF
Create namespace; pass namespace name,
and optionally a dictionary of namespace configuration.
Examples:

  hbase> create_namespace 'ns1'
  hbase> create_namespace 'ns1', {'PROPERTY_NAME'=>'PROPERTY_VALUE'}
EOF
      end

      def command(namespace, *args)
        admin.create_namespace(namespace, *args)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Create < Command
      def help
        <<-EOF
Creates a table. Pass a table name, and a set of column family
specifications (at least one), and, optionally, table configuration.
Column specification can be a simple string (name), or a dictionary
(dictionaries are described below in main help output), necessarily
including NAME attribute.
Examples:

Create a table with namespace=ns1 and table qualifier=t1
  hbase> create 'ns1:t1', {NAME => 'f1', VERSIONS => 5}

Create a table with namespace=default and table qualifier=t1
  hbase> create 't1', {NAME => 'f1'}, {NAME => 'f2'}, {NAME => 'f3'}
  hbase> # The above in shorthand would be the following:
  hbase> create 't1', 'f1', 'f2', 'f3'
  hbase> create 't1', {NAME => 'f1', VERSIONS => 1, TTL => 2592000, BLOCKCACHE => true}
  hbase> create 't1', {NAME => 'f1', CONFIGURATION => {'hbase.hstore.blockingStoreFiles' => '10'}}
  hbase> create 't1', {NAME => 'f1', IS_MOB => true, MOB_THRESHOLD => 1000000, MOB_COMPACT_PARTITION_POLICY => 'weekly'}

Table configuration options can be put at the end.
Examples:

  hbase> create 'ns1:t1', 'f1', SPLITS => ['10', '20', '30', '40']
  hbase> create 't1', 'f1', SPLITS => ['10', '20', '30', '40']
  hbase> create 't1', 'f1', SPLITS_FILE => 'splits.txt', OWNER => 'johndoe'
  hbase> create 't1', {NAME => 'f1', VERSIONS => 5}, METADATA => { 'mykey' => 'myvalue' }
  hbase> # Optionally pre-split the table into NUMREGIONS, using
  hbase> # SPLITALGO ("HexStringSplit", "UniformSplit" or classname)
  hbase> create 't1', 'f1', {NUMREGIONS => 15, SPLITALGO => 'HexStringSplit'}
  hbase> create 't1', 'f1', {NUMREGIONS => 15, SPLITALGO => 'HexStringSplit', REGION_REPLICATION => 2, CONFIGURATION => {'hbase.hregion.scan.loadColumnFamiliesOnDemand' => 'true'}}
  hbase> create 't1', 'f1', {SPLIT_ENABLED => false, MERGE_ENABLED => false}
  hbase> create 't1', {NAME => 'f1', DFS_REPLICATION => 1}

You can also keep around a reference to the created table:

  hbase> t1 = create 't1', 'f1'

Which gives you a reference to the table named 't1', on which you can then
call methods.
EOF
      end

      def command(table, *args)
        admin.create(table, *args)
        @end_time = Time.now
        puts 'Created table ' + table.to_s

        # and then return the table just created
        table(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Decommission a list of region servers, optionally offload corresponding regions
    class DecommissionRegionservers < Command
      def help
        <<-EOF
  Mark region server(s) as decommissioned to prevent additional regions from
  getting assigned to them.

  Optionally, offload the regions on the servers by passing true.
  NOTE: Region offloading is asynchronous.

  If there are multiple servers to be decommissioned, decommissioning them
  at the same time can prevent wasteful region movements.

  Examples:
    hbase> decommission_regionservers 'server'
    hbase> decommission_regionservers 'server,port'
    hbase> decommission_regionservers 'server,port,starttime'
    hbase> decommission_regionservers 'server', false
    hbase> decommission_regionservers ['server1','server2'], true
EOF
      end

      def command(server_names, should_offload = false)
        admin.decommission_regionservers(server_names, should_offload)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Deleteall < Command
      def help
        <<-EOF
Delete all cells in a given row; pass a table name, row, and optionally
a column and timestamp. Deleteall also support deleting a row range using a
row key prefix. Examples:

  hbase> deleteall 'ns1:t1', 'r1'
  hbase> deleteall 't1', 'r1'
  hbase> deleteall 't1', 'r1', 'c1'
  hbase> deleteall 't1', 'r1', 'c1', ts1
  hbase> deleteall 't1', 'r1', 'c1', ts1, {VISIBILITY=>'PRIVATE|SECRET'}

ROWPREFIXFILTER can be used to delete row ranges
  hbase> deleteall 't1', {ROWPREFIXFILTER => 'prefix'}
  hbase> deleteall 't1', {ROWPREFIXFILTER => 'prefix'}, 'c1'        //delete certain column family in the row ranges
  hbase> deleteall 't1', {ROWPREFIXFILTER => 'prefix'}, 'c1', ts1
  hbase> deleteall 't1', {ROWPREFIXFILTER => 'prefix'}, 'c1', ts1, {VISIBILITY=>'PRIVATE|SECRET'}

CACHE can be used to specify how many deletes batched to be sent to server at one time, default is 100
  hbase> deleteall 't1', {ROWPREFIXFILTER => 'prefix', CACHE => 100}


The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.deleteall 'r1', 'c1', ts1, {VISIBILITY=>'PRIVATE|SECRET'}
  hbase> t.deleteall {ROWPREFIXFILTER => 'prefix', CACHE => 100}, 'c1', ts1, {VISIBILITY=>'PRIVATE|SECRET'}
EOF
      end

      def command(table, row, column = nil,
                  timestamp = org.apache.hadoop.hbase.HConstants::LATEST_TIMESTAMP, args = {})
        deleteall(table(table), row, column, timestamp, args)
      end

      def deleteall(table, row, column = nil,
                    timestamp = org.apache.hadoop.hbase.HConstants::LATEST_TIMESTAMP, args = {})
        @start_time = Time.now
        table._deleteall_internal(row, column, timestamp, args, true)
      end
    end
  end
end

# Add the method table.deleteall that calls deleteall.deleteall
::Hbase::Table.add_shell_command('deleteall')
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DeleteAllSnapshot < Command
      def help
        <<-EOF
Delete all of the snapshots matching the given regex. Examples:

  hbase> delete_all_snapshot 's.*'

EOF
      end

      def command(regex)
        formatter.header(['SNAPSHOT', 'TABLE + CREATION TIME'])
        list = admin.list_snapshot(regex)
        count = list.size
        list.each do |snapshot|
          creation_time = Time.at(snapshot.getCreationTime / 1000).to_s
          formatter.row([snapshot.getName, snapshot.getTable + ' (' + creation_time + ')'])
        end
        puts "\nDelete the above #{count} snapshots (y/n)?" unless count == 0
        answer = 'n'
        answer = gets.chomp unless count == 0
        puts "No snapshots matched the regex #{regex}" if count == 0
        return unless answer =~ /y.*/i
        @start_time = Time.now
        admin.delete_all_snapshot(regex)
        @end_time = Time.now
        list = admin.list_snapshot(regex)
        leftOverSnapshotCount = list.size
        successfullyDeleted = count - leftOverSnapshotCount
        puts "#{successfullyDeleted} snapshots successfully deleted." unless successfullyDeleted == 0
        return if leftOverSnapshotCount == 0
        puts "\nFailed to delete the below #{leftOverSnapshotCount} snapshots."
        formatter.header(['SNAPSHOT', 'TABLE + CREATION TIME'])
        list.each do |snapshot|
          creation_time = Time.at(snapshot.getCreationTime / 1000).to_s
          formatter.row([snapshot.getName, snapshot.getTable + ' (' + creation_time + ')'])
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Delete < Command
      def help
        <<-EOF
Put a delete cell value at specified table/row/column and optionally
timestamp coordinates.  Deletes must match the deleted cell's
coordinates exactly.  When scanning, a delete cell suppresses older
versions. To delete a cell from  't1' at row 'r1' under column 'c1'
marked with the time 'ts1', do:

  hbase> delete 'ns1:t1', 'r1', 'c1', ts1
  hbase> delete 't1', 'r1', 'c1', ts1
  hbase> delete 't1', 'r1', 'c1', ts1, {VISIBILITY=>'PRIVATE|SECRET'}

The same command can also be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.delete 'r1', 'c1',  ts1
  hbase> t.delete 'r1', 'c1',  ts1, {VISIBILITY=>'PRIVATE|SECRET'}
EOF
      end

      def command(table, row, column,
                  timestamp = org.apache.hadoop.hbase.HConstants::LATEST_TIMESTAMP, args = {})
        delete(table(table), row, column, timestamp, args)
      end

      def delete(table, row, column,
                 timestamp = org.apache.hadoop.hbase.HConstants::LATEST_TIMESTAMP, args = {})
        @start_time = Time.now
        table._delete_internal(row, column, timestamp, args, false)
      end
    end
  end
end

# Add the method table.delete that calls delete.delete
::Hbase::Table.add_shell_command('delete')
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DeleteSnapshot < Command
      def help
        <<-EOF
Delete a specified snapshot. Examples:

  hbase> delete_snapshot 'snapshotName',
EOF
      end

      def command(snapshot_name)
        admin.delete_snapshot(snapshot_name)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DeleteTableSnapshots < Command
      def help
        <<-EOF
Delete all of the snapshots matching the given table name regular expression
and snapshot name regular expression.
By default snapshot name regular expression will delete all the snapshots of the
matching table name regular expression.

Examples:
  hbase> delete_table_snapshots 'tableName'
  hbase> delete_table_snapshots 'tableName.*'
  hbase> delete_table_snapshots 'tableName', 'snapshotName'
  hbase> delete_table_snapshots 'tableName', 'snapshotName.*'
  hbase> delete_table_snapshots 'tableName.*', 'snapshotName.*'
  hbase> delete_table_snapshots 'ns:tableName.*', 'snapshotName.*'

EOF
      end

      def command(tableNameregex, snapshotNameRegex = '.*')
        formatter.header(['SNAPSHOT', 'TABLE + CREATION TIME'])
        list = admin.list_table_snapshots(tableNameregex, snapshotNameRegex)
        count = list.size
        list.each do |snapshot|
          creation_time = Time.at(snapshot.getCreationTime / 1000).to_s
          formatter.row([snapshot.getName, snapshot.getTable + ' (' + creation_time + ')'])
        end
        puts "\nDelete the above #{count} snapshots (y/n)?" unless count == 0
        answer = 'n'
        answer = gets.chomp unless count == 0
        puts "No snapshots matched the table name regular expression #{tableNameregex} and the snapshot name regular expression #{snapshotNameRegex}" if count == 0
        return unless answer =~ /y.*/i

        @start_time = Time.now
        list.each do |deleteSnapshot|
          begin
            admin.delete_snapshot(deleteSnapshot.getName)
            puts "Successfully deleted snapshot: #{deleteSnapshot.getName}"
            puts "\n"
          rescue RuntimeError
            puts "Failed to delete snapshot: #{deleteSnapshot.getName}, due to below exception,\n" + $ERROR_INFO
            puts "\n"
          end
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DescribeNamespace < Command
      def help
        <<-EOF
Describe the named namespace. For example:
  hbase> describe_namespace 'ns1'
EOF
      end

      # rubocop:disable Metrics/AbcSize
      def command(namespace)
        desc = admin.describe_namespace(namespace)

        formatter.header(['DESCRIPTION'], [64])
        formatter.row([desc], true, [64])

        puts
        formatter.header(%w[QUOTAS])
        ns = namespace.to_s
        count = quotas_admin.list_quotas(NAMESPACE => ns) do |_, quota|
          formatter.row([quota])
        end
        formatter.footer(count)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Describe < Command
      def help
        <<-EOF
Describe the named table. For example:
  hbase> describe 't1'
  hbase> describe 'ns1:t1'

Alternatively, you can use the abbreviated 'desc' for the same thing.
  hbase> desc 't1'
  hbase> desc 'ns1:t1'
EOF
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def command(table)
        column_families = admin.get_column_families(table)

        formatter.header(['Table ' + table.to_s + ' is ' + (admin.enabled?(table) ? 'ENABLED' : 'DISABLED')])
        formatter.row([table.to_s + admin.get_table_attributes(table)], true)
        formatter.header(['COLUMN FAMILIES DESCRIPTION'])
        column_families.each do |column_family|
          formatter.row([column_family.to_s], true)
          puts
        end
        formatter.footer
        puts
        formatter.header(%w[QUOTAS])
        count = quotas_admin.list_quotas(TABLE => table.to_s) do |_, quota|
          formatter.row([quota])
        end
        formatter.footer(count)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DisableAll < Command
      def help
        <<-EOF
Disable all of tables matching the given regex:

hbase> disable_all 't.*'
hbase> disable_all 'ns:t.*'
hbase> disable_all 'ns:.*'
EOF
      end

      def command(regex)
        list = admin.list(regex)
        count = list.size
        list.each do |table|
          formatter.row([table])
        end
        puts "\nDisable the above #{count} tables (y/n)?" unless count == 0
        answer = 'n'
        answer = gets.chomp unless count == 0
        puts "No tables matched the regex #{regex}" if count == 0
        return unless answer =~ /y.*/i
        failed = admin.disable_all(regex)
        puts "#{count - failed.size} tables successfully disabled"
        puts "#{failed.size} tables not disabled due to an exception: #{failed.join ','}" unless failed.empty?
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DisableExceedThrottleQuota < Command
      def help
        <<-EOF
Disable exceed throttle quota. Returns previous exceed throttle quota enabled value.
NOTE: if quota is not enabled, this will not work and always return false.

Examples:
    hbase> disable_exceed_throttle_quota
        EOF
      end

      def command
        prev_state = quotas_admin.switch_exceed_throttle_quota(false) ? 'true' : 'false'
        formatter.row(["Previous exceed throttle quota enabled : #{prev_state}"])
        prev_state
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DisablePeer < Command
      def help
        <<-EOF
Stops the replication stream to the specified cluster, but still
keeps track of new edits to replicate.

Examples:

  hbase> disable_peer '1'
EOF
      end

      def command(id)
        replication_admin.disable_peer(id)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Disable < Command
      def help
        <<-EOF
Start disable of named table:
  hbase> disable 't1'
  hbase> disable 'ns1:t1'
EOF
      end

      def command(table)
        admin.disable(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DisableRpcThrottle < Command
      def help
        return <<-EOF
Disable quota rpc throttle. Returns previous rpc throttle enabled value.
NOTE: if quota is not enabled, this will not work and always return false.

Examples:
    hbase> disable_rpc_throttle
        EOF
      end

      def command
        prev_state = quotas_admin.switch_rpc_throttle(false) ? 'true' : 'false'
        formatter.row(["Previous rpc throttle state : #{prev_state}"])
        prev_state
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DisableTableReplication < Command
      def help
        <<-EOF
Disable a table's replication switch.

Examples:

  hbase> disable_table_replication 'table_name'
EOF
      end

      def command(table_name)
        replication_admin.disable_tablerep(table_name)
        puts "Replication of table '#{table_name}' successfully disabled."
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DropAll < Command
      def help
        <<-EOF
Drop all of the tables matching the given regex:

hbase> drop_all 't.*'
hbase> drop_all 'ns:t.*'
hbase> drop_all 'ns:.*'
EOF
      end

      def command(regex)
        list = admin.list(regex)
        count = list.size
        list.each do |table|
          formatter.row([table])
        end
        puts "\nDrop the above #{count} tables (y/n)?" unless count == 0
        answer = 'n'
        answer = gets.chomp unless count == 0
        puts "No tables matched the regex #{regex}" if count == 0
        return unless answer =~ /y.*/i
        failed = admin.drop_all(regex)
        puts "#{count - failed.size} tables successfully dropped"
        puts "#{failed.size} tables not dropped due to an exception: #{failed.join ','}" unless failed.empty?
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class DropNamespace < Command
      def help
        <<-EOF
Drop the named namespace. The namespace must be empty.
EOF
      end

      def command(namespace)
        admin.drop_namespace(namespace)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Drop < Command
      def help
        <<-EOF
Drop the named table. Table must first be disabled:
  hbase> drop 't1'
  hbase> drop 'ns1:t1'
EOF
      end

      def command(table)
        admin.drop(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class EnableAll < Command
      def help
        <<-EOF
Enable all of the tables matching the given regex:

hbase> enable_all 't.*'
hbase> enable_all 'ns:t.*'
hbase> enable_all 'ns:.*'
EOF
      end

      def command(regex)
        list = admin.list(regex)
        count = list.size
        list.each do |table|
          formatter.row([table])
        end
        puts "\nEnable the above #{count} tables (y/n)?" unless count == 0
        answer = 'n'
        answer = gets.chomp unless count == 0
        puts "No tables matched the regex #{regex}" if count == 0
        return unless answer =~ /y.*/i
        failed = admin.enable_all(regex)
        puts "#{count - failed.size} tables successfully enabled"
        puts "#{failed.size} tables not enabled due to an exception: #{failed.join ','}" unless failed.empty?
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class EnableExceedThrottleQuota < Command
      def help
        <<-EOF
Enable exceed throttle quota. Returns previous exceed throttle quota enabled value.
NOTE: if quota is not enabled, this will not work and always return false.

If enabled, allow requests exceed user/table/namespace throttle quotas when region
server has available quota.

There are two limits if enable exceed throttle quota. First, please set region server
quota. Second, please make sure that all region server throttle quotas are in seconds
time unit, because once previous requests exceed their quota and consume region server
quota, quota in other time units may be refilled in a long time, which may affect later
requests.


Examples:
    hbase> enable_exceed_throttle_quota
        EOF
      end

      def command
        prev_state = quotas_admin.switch_exceed_throttle_quota(true) ? 'true' : 'false'
        formatter.row(["Previous exceed throttle quota enabled : #{prev_state}"])
        prev_state
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class EnablePeer < Command
      def help
        <<-EOF
Restarts the replication to the specified peer cluster,
continuing from where it was disabled.

Examples:

  hbase> enable_peer '1'
EOF
      end

      def command(id)
        replication_admin.enable_peer(id)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Enable < Command
      def help
        <<-EOF
Start enable of named table:
  hbase> enable 't1'
  hbase> enable 'ns1:t1'
EOF
      end

      def command(table)
        admin.enable(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class EnableRpcThrottle < Command
      def help
        return <<-EOF
Enable quota rpc throttle. Returns previous rpc throttle enabled value.
NOTE: if quota is not enabled, this will not work and always return false.

Examples:
    hbase> enable_rpc_throttle
        EOF
      end

      def command
        prev_state = quotas_admin.switch_rpc_throttle(true) ? 'true' : 'false'
        formatter.row(["Previous rpc throttle state : #{prev_state}"])
        prev_state
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class EnableTableReplication < Command
      def help
        <<-EOF
Enable a table's replication switch.

Examples:

  hbase> enable_table_replication 'table_name'
EOF
      end

      def command(table_name)
        replication_admin.enable_tablerep(table_name)
        puts "The replication of table '#{table_name}' successfully enabled"
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Exists < Command
      def help
        <<-EOF
Does the named table exist?
  hbase> exists 't1'
  hbase> exists 'ns1:t1'
EOF
      end

      def command(table)
        exists = admin.exists?(table.to_s)
        formatter.row([
                        "Table #{table} " + (exists ? 'does exist' : 'does not exist')
                      ])
        exists
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Flush < Command
      def help
        <<-EOF
Flush all regions in passed table or pass a region row to
flush an individual region or a region server name whose format
is 'host,port,startcode', to flush all its regions.
For example:

  hbase> flush 'TABLENAME'
  hbase> flush 'REGIONNAME'
  hbase> flush 'ENCODED_REGIONNAME'
  hbase> flush 'REGION_SERVER_NAME'
EOF
      end

      def command(table_or_region_name)
        admin.flush(table_or_region_name)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetAuths < Command
      def help
        <<-EOF
Get the visibility labels set for a particular user or group
Syntax : get_auths 'user'

For example:

    hbase> get_auths 'user1'
    hbase> get_auths '@group1'
EOF
      end

      def command(user)
        list = visibility_labels_admin.get_auths(user)
        list.each do |auths|
          formatter.row([org.apache.hadoop.hbase.util.Bytes.toStringBinary(auths.toByteArray)])
        end
        list
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetCounter < Command
      def help
        <<-EOF
Return a counter cell value at specified table/row/column coordinates.
A counter cell should be managed with atomic increment functions on HBase
and the data should be binary encoded (as long value). Example:

  hbase> get_counter 'ns1:t1', 'r1', 'c1'
  hbase> get_counter 't1', 'r1', 'c1'

The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.get_counter 'r1', 'c1'
EOF
      end

      def command(table, row, column)
        get_counter(table(table), row, column)
      end

      def get_counter(table, row, column)
        if cnt = table._get_counter_internal(row, column)
          puts "COUNTER VALUE = #{cnt}"
        else
          puts 'No counter found at specified coordinates'
        end
      end
    end
  end
end

::Hbase::Table.add_shell_command('get_counter')
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetPeerConfig < Command
      def help
        <<-EOF
          Outputs the cluster key, replication endpoint class (if present), and any replication configuration parameters
        EOF
      end

      def command(id)
        peer_config = replication_admin.get_peer_config(id)
        @start_time = Time.now
        format_peer_config(peer_config)
        peer_config
      end

      def format_peer_config(peer_config)
        cluster_key = peer_config.get_cluster_key
        endpoint = peer_config.get_replication_endpoint_impl

        formatter.row(['Cluster Key', cluster_key]) unless cluster_key.nil?
        formatter.row(['Replication Endpoint', endpoint]) unless endpoint.nil?
        unless peer_config.get_configuration.nil?
          peer_config.get_configuration.each do |config_entry|
            formatter.row(config_entry)
          end
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Get < Command
      def help
        <<-EOF
Get row or cell contents; pass table name, row, and optionally
a dictionary of column(s), timestamp, timerange and versions. Examples:

  hbase> get 'ns1:t1', 'r1'
  hbase> get 't1', 'r1'
  hbase> get 't1', 'r1', {TIMERANGE => [ts1, ts2]}
  hbase> get 't1', 'r1', {COLUMN => 'c1'}
  hbase> get 't1', 'r1', {COLUMN => ['c1', 'c2', 'c3']}
  hbase> get 't1', 'r1', {COLUMN => 'c1', TIMESTAMP => ts1}
  hbase> get 't1', 'r1', {COLUMN => 'c1', TIMERANGE => [ts1, ts2], VERSIONS => 4}
  hbase> get 't1', 'r1', {COLUMN => 'c1', TIMESTAMP => ts1, VERSIONS => 4}
  hbase> get 't1', 'r1', {FILTER => "ValueFilter(=, 'binary:abc')"}
  hbase> get 't1', 'r1', 'c1'
  hbase> get 't1', 'r1', 'c1', 'c2'
  hbase> get 't1', 'r1', ['c1', 'c2']
  hbase> get 't1', 'r1', {COLUMN => 'c1', ATTRIBUTES => {'mykey'=>'myvalue'}}
  hbase> get 't1', 'r1', {COLUMN => 'c1', AUTHORIZATIONS => ['PRIVATE','SECRET']}
  hbase> get 't1', 'r1', {CONSISTENCY => 'TIMELINE'}
  hbase> get 't1', 'r1', {CONSISTENCY => 'TIMELINE', REGION_REPLICA_ID => 1}

Besides the default 'toStringBinary' format, 'get' also supports custom formatting by
column.  A user can define a FORMATTER by adding it to the column name in the get
specification.  The FORMATTER can be stipulated:

 1. either as a org.apache.hadoop.hbase.util.Bytes method name (e.g, toInt, toString)
 2. or as a custom class followed by method name: e.g. 'c(MyFormatterClass).format'.

Example formatting cf:qualifier1 and cf:qualifier2 both as Integers:
  hbase> get 't1', 'r1' {COLUMN => ['cf:qualifier1:toInt',
    'cf:qualifier2:c(org.apache.hadoop.hbase.util.Bytes).toInt'] }

Note that you can specify a FORMATTER by column only (cf:qualifier). You can set a
formatter for all columns (including, all key parts) using the "FORMATTER"
and "FORMATTER_CLASS" options. The default "FORMATTER_CLASS" is
"org.apache.hadoop.hbase.util.Bytes".

  hbase> get 't1', 'r1', {FORMATTER => 'toString'}
  hbase> get 't1', 'r1', {FORMATTER_CLASS => 'org.apache.hadoop.hbase.util.Bytes', FORMATTER => 'toString'}

The same commands also can be run on a reference to a table (obtained via get_table or
create_table). Suppose you had a reference t to table 't1', the corresponding commands
would be:

  hbase> t.get 'r1'
  hbase> t.get 'r1', {TIMERANGE => [ts1, ts2]}
  hbase> t.get 'r1', {COLUMN => 'c1'}
  hbase> t.get 'r1', {COLUMN => ['c1', 'c2', 'c3']}
  hbase> t.get 'r1', {COLUMN => 'c1', TIMESTAMP => ts1}
  hbase> t.get 'r1', {COLUMN => 'c1', TIMERANGE => [ts1, ts2], VERSIONS => 4}
  hbase> t.get 'r1', {COLUMN => 'c1', TIMESTAMP => ts1, VERSIONS => 4}
  hbase> t.get 'r1', {FILTER => "ValueFilter(=, 'binary:abc')"}
  hbase> t.get 'r1', 'c1'
  hbase> t.get 'r1', 'c1', 'c2'
  hbase> t.get 'r1', ['c1', 'c2']
  hbase> t.get 'r1', {CONSISTENCY => 'TIMELINE'}
  hbase> t.get 'r1', {CONSISTENCY => 'TIMELINE', REGION_REPLICA_ID => 1}
EOF
      end

      def command(table, row, *args)
        get(table(table), row, *args)
      end

      def get(table, row, *args)
        @start_time = Time.now
        formatter.header(%w[COLUMN CELL])

        count, is_stale = table._get_internal(row, *args) do |column, value|
          formatter.row([column, value])
        end

        formatter.footer(count, is_stale)
      end
    end
  end
end

# add get command to table
::Hbase::Table.add_shell_command('get')
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetRsgroup < Command
      def help
        <<-EOF
Get a RegionServer group's information.

Example:

  hbase> get_rsgroup 'default'

EOF
      end

      def command(group_name)
        group = rsgroup_admin.get_rsgroup(group_name)

        formatter.header(['SERVERS'])
        group.getServers.each do |server|
          formatter.row([server.toString])
        end
        formatter.footer

        formatter.header(['TABLES'])
        group.getTables.each do |table|
          formatter.row([table.getNameAsString])
        end
        formatter.footer
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetServerRsgroup < Command
      def help
        <<-EOF
Get the group name the given RegionServer is a member of.

Example:

  hbase> get_server_rsgroup 'server1:port1'

EOF
      end

      def command(server)
        group_name = rsgroup_admin.get_rsgroup_of_server(server).getName
        formatter.row([group_name])
        formatter.footer(1)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetSplits < Command
      def help
        <<-EOF
Get the splits of the named table:
  hbase> get_splits 't1'
  hbase> get_splits 'ns1:t1'

The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.get_splits
EOF
      end

      def command(table)
        get_splits(table(table))
      end

      def get_splits(table)
        splits = table._get_splits_internal
        puts(format('Total number of splits = %<numsplits>d',
                    numsplits: (splits.size + 1)))
        puts splits
        splits
      end
    end
  end
end

::Hbase::Table.add_shell_command('get_splits')
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetTable < Command
      def help
        <<-EOF
Get the given table name and return it as an actual object to
be manipulated by the user. See table.help for more information
on how to use the table.
Eg.

  hbase> t1 = get_table 't1'
  hbase> t1 = get_table 'ns1:t1'

returns the table named 't1' as a table object. You can then do

  hbase> t1.help

which will then print the help for that table.
EOF
      end

      def command(table, *_args)
        table(table)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class GetTableRsgroup < Command
      def help
        <<-EOF
Get the RegionServer group name the given table is a member of.

Example:

  hbase> get_table_rsgroup 'myTable'

EOF
      end

      def command(table)
        group_name =
          rsgroup_admin.get_rsgroup_of_table(table).getName
        formatter.row([group_name])
        formatter.footer(1)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Grant < Command
      def help
        <<-EOF
Grant users specific rights.
Syntax: grant <user or @group>, <permissions> [, <table> [, <column family> [, <column qualifier>]]]
Syntax: grant <user or @group>, <permissions>, <@namespace>

permissions is either zero or more letters from the set "RWXCA".
READ('R'), WRITE('W'), EXEC('X'), CREATE('C'), ADMIN('A')

Note: Groups and users are granted access in the same way, but groups are prefixed with an '@'
      character. Tables and namespaces are specified the same way, but namespaces are
      prefixed with an '@' character.

For example:

    hbase> grant 'bobsmith', 'RWXCA'
    hbase> grant '@admins', 'RWXCA'
    hbase> grant 'bobsmith', 'RWXCA', '@ns1'
    hbase> grant 'bobsmith', 'RW', 't1', 'f1', 'col1'
    hbase> grant 'bobsmith', 'RW', 'ns1:t1', 'f1', 'col1'
EOF
      end

      def command(*args)
        # command form is ambiguous at first argument
        table_name = user = args[0]
        raise(ArgumentError, 'First argument should be a String') unless user.is_a?(String)

        if args[1].is_a?(String)

          # Original form of the command
          #     user in args[0]
          #     permissions in args[1]
          #     table_name in args[2]
          #     family in args[3] or nil
          #     qualifier in args[4] or nil

          permissions = args[1]
          raise(ArgumentError, 'Permissions are not of String type') unless permissions.is_a?(
            String
          )
          table_name = family = qualifier = nil
          table_name = args[2] # will be nil if unset
          unless table_name.nil?
            raise(ArgumentError, 'Table name is not of String type') unless table_name.is_a?(
              String
            )
            family = args[3] # will be nil if unset
            unless family.nil?
              raise(ArgumentError, 'Family is not of String type') unless family.is_a?(String)
              qualifier = args[4] # will be nil if unset
              unless qualifier.nil?
                raise(ArgumentError, 'Qualifier is not of String type') unless qualifier.is_a?(
                  String
                )
              end
            end
          end
          @start_time = Time.now
          security_admin.grant(user, permissions, table_name, family, qualifier)

        elsif args[1].is_a?(Hash)

          # New form of the command, a cell ACL update
          #    table_name in args[0], a string
          #    a Hash mapping users (or groups) to permisisons in args[1]
          #    a Hash argument suitable for passing to Table#_get_scanner in args[2]
          # Useful for feature testing and debugging.

          permissions = args[1]
          raise(ArgumentError, 'Permissions are not of Hash type') unless permissions.is_a?(Hash)
          scan = args[2]
          raise(ArgumentError, 'Scanner specification is not a Hash') unless scan.is_a?(Hash)

          t = table(table_name)
          @start_time = Time.now
          scanner = t._get_scanner(scan)
          count = 0
          iter = scanner.iterator
          while iter.hasNext
            row = iter.next
            row.listCells.each do |cell|
              put = org.apache.hadoop.hbase.client.Put.new(row.getRow)
              put.add(cell)
              t.set_cell_permissions(put, permissions)
              t.table.put(put)
            end
            count += 1
          end
          formatter.footer(count)

        else
          raise(ArgumentError, 'Second argument should be a String or Hash')
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Incr < Command
      def help
        <<-EOF
Increments a cell 'value' at specified table/row/column coordinates.
To increment a cell value in table 'ns1:t1' or 't1' at row 'r1' under column
'c1' by 1 (can be omitted) or 10 do:

  hbase> incr 'ns1:t1', 'r1', 'c1'
  hbase> incr 't1', 'r1', 'c1'
  hbase> incr 't1', 'r1', 'c1', 1
  hbase> incr 't1', 'r1', 'c1', 10
  hbase> incr 't1', 'r1', 'c1', 10, {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> incr 't1', 'r1', 'c1', {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> incr 't1', 'r1', 'c1', 10, {VISIBILITY=>'PRIVATE|SECRET'}

The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.incr 'r1', 'c1'
  hbase> t.incr 'r1', 'c1', 1
  hbase> t.incr 'r1', 'c1', 10, {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> t.incr 'r1', 'c1', 10, {VISIBILITY=>'PRIVATE|SECRET'}
EOF
      end

      def command(table, row, column, value = nil, args = {})
        incr(table(table), row, column, value, args)
      end

      def incr(table, row, column, value = nil, args = {})
        if cnt = table._incr_internal(row, column, value, args)
          puts "COUNTER VALUE = #{cnt}"
        else
          puts 'No counter found at specified coordinates'
        end
      end
    end
  end
end

# add incr comamnd to Table
::Hbase::Table.add_shell_command('incr')
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class IsDisabled < Command
      def help
        <<-EOF
Is named table disabled? For example:
  hbase> is_disabled 't1'
  hbase> is_disabled 'ns1:t1'
EOF
      end

      def command(table)
        formatter.row([admin.disabled?(table) ? 'true' : 'false'])
    end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class IsEnabled < Command
      def help
        <<-EOF
Is named table enabled? For example:
  hbase> is_enabled 't1'
  hbase> is_enabled 'ns1:t1'
EOF
      end

      def command(table)
        enabled = admin.enabled?(table)
        formatter.row([enabled ? 'true' : 'false'])
        enabled
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class IsInMaintenanceMode < Command
      def help
        <<-EOF
Is master in maintenance mode? For example:

  hbase> is_in_maintenance_mode
EOF
      end

      def command
        state = admin.in_maintenance_mode?
        formatter.row([state.to_s])
        state
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListDeadservers < Command
      def help
        <<-EOF
           List all dead region servers in hbase
           Examples:
           hbase> list_deadservers
        EOF
      end

      def command
        now = Time.now
        formatter.header(['SERVERNAME'])

        servers = admin.list_deadservers
        servers.each do |server|
          formatter.row([server.toString])
        end

        formatter.footer(now, servers.size)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # List decommissioned region servers
    class ListDecommissionedRegionservers < Command
      def help
        <<-EOF
  List region servers marked as decommissioned, which can not be assigned regions.
EOF
      end

      def command
        formatter.header(['DECOMMISSIONED REGION SERVERS'])

        list = admin.list_decommissioned_regionservers
        list.each do |server_name|
          formatter.row([server_name.getServerName])
        end

        formatter.footer(list.size)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListLabels < Command
      def help
        <<-EOF
List the visibility labels defined in the system.
Optional regular expression parameter could be used to filter the labels being returned.
Syntax : list_labels

For example:

    hbase> list_labels 'secret.*'
    hbase> list_labels
EOF
      end

      def command(regex = '.*')
        list = visibility_labels_admin.list_labels(regex)
        list.each do |label|
          formatter.row([org.apache.hadoop.hbase.util.Bytes.toStringBinary(label.toByteArray)])
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'json'

module Shell
  module Commands
    class ListLocks < Command
      def help
        <<-EOF
List all locks in hbase. Examples:

  hbase> list_locks
EOF
      end

      def command
        list = JSON.parse(admin.list_locks)

        list.each do |lock|
          formatter.output_strln("#{lock['resourceType']}(#{lock['resourceName']})")

          case lock['lockType']
          when 'EXCLUSIVE' then
            formatter.output_strln("Lock type: #{lock['lockType']}, " \
              "procedure: #{lock['exclusiveLockOwnerProcedure']}")
          when 'SHARED' then
            formatter.output_strln("Lock type: #{lock['lockType']}, " \
              "count: #{lock['sharedLockCount']}")
          end

          if lock['waitingProcedures']
            formatter.header(['Waiting procedures'])

            lock['waitingProcedures'].each do |waiting_procedure|
              formatter.row([waiting_procedure])
            end

            formatter.footer(lock['waitingProcedures'].size)
          end

          formatter.output_strln('')
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListNamespace < Command
      def help
        <<-EOF
List all namespaces in hbase. Optional regular expression parameter could
be used to filter the output. Examples:

  hbase> list_namespace
  hbase> list_namespace 'abc.*'
EOF
      end

      def command(regex = '.*')
        formatter.header(['NAMESPACE'])

        list = admin.list_namespace(regex)
        list.each do |table|
          formatter.row([table])
        end

        formatter.footer(list.size)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListNamespaceTables < Command
      def help
        <<-EOF
List all tables that are members of the namespace.
Examples:

  hbase> list_namespace_tables 'ns1'
EOF
      end

      def command(namespace)
        formatter.header(['TABLE'])

        list = admin.list_namespace_tables(namespace)
        list.each do |table|
          formatter.row([table])
        end

        formatter.footer(list.size)
        list
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListPeerConfigs < Command
      def help
        <<-EOF
          No-argument method that outputs the replication peer configuration for each peer defined on this cluster.
        EOF
      end

      def command
        peer_configs = replication_admin.list_peer_configs
        unless peer_configs.nil?
          peer_configs.each do |peer_config_entry|
            peer_id = peer_config_entry[0]
            peer_config = peer_config_entry[1]
            formatter.row(['PeerId', peer_id])
            GetPeerConfig.new(@shell).format_peer_config(peer_config)
            formatter.row([' '])
          end
        end
        peer_configs
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListPeers < Command
      def help
        <<-EOF
  List all replication peer clusters.

  If replicate_all flag is false, the namespaces and table-cfs in peer config
  will be replicated to peer cluster.

  If replicate_all flag is true, all user tables will be replicate to peer
  cluster, except that the namespaces and table-cfs in peer config.

  hbase> list_peers
EOF
      end

      def command
        peers = replication_admin.list_peers

        formatter.header(%w[PEER_ID CLUSTER_KEY ENDPOINT_CLASSNAME
                            REMOTE_ROOT_DIR SYNC_REPLICATION_STATE STATE
                            REPLICATE_ALL NAMESPACES TABLE_CFS BANDWIDTH
                            SERIAL])

        peers.each do |peer|
          id = peer.getPeerId
          state = peer.isEnabled ? 'ENABLED' : 'DISABLED'
          config = peer.getPeerConfig
          if config.replicateAllUserTables
            namespaces = replication_admin.show_peer_exclude_namespaces(config)
            tableCFs = replication_admin.show_peer_exclude_tableCFs(config)
          else
            namespaces = replication_admin.show_peer_namespaces(config)
            tableCFs = replication_admin.show_peer_tableCFs_by_config(config)
          end
          cluster_key = 'nil'
          unless config.getClusterKey.nil?
            cluster_key = config.getClusterKey
          end
          endpoint_classname = 'nil'
          unless config.getReplicationEndpointImpl.nil?
            endpoint_classname = config.getReplicationEndpointImpl
          end
          remote_root_dir = 'nil'
          unless config.getRemoteWALDir.nil?
            remote_root_dir = config.getRemoteWALDir
          end
          formatter.row([id, cluster_key, endpoint_classname,
                         remote_root_dir, peer.getSyncReplicationState, state,
                         config.replicateAllUserTables, namespaces, tableCFs,
                         config.getBandwidth, config.isSerial])
        end

        formatter.footer
        peers
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'json'

module Shell
  module Commands
    class ListProcedures < Command
      def help
        <<-EOF
List all procedures in hbase. For example:

  hbase> list_procedures
EOF
      end

      def command
        formatter.header(%w[PID Name State Submitted Last_Update Parameters])
        list = JSON.parse(admin.list_procedures)
        list.each do |proc|
          submitted_time = Time.at(Integer(proc['submittedTime']) / 1000).to_s
          last_update = Time.at(Integer(proc['lastUpdate']) / 1000).to_s
          formatter.row([proc['procId'], proc['className'], proc['state'],
                         submitted_time, last_update, proc['stateMessage']])
        end

        formatter.footer(list.size)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListQuotaSnapshots < Command
      def help
        <<-EOF
Lists the current space quota snapshots with optional selection criteria.
Snapshots encapsulate relevant information to space quotas such as space
use, configured limits, and quota violation details. This command is
useful for understanding the current state of a cluster with space quotas.

By default, this command will read all snapshots stored in the system from
the hbase:quota table. A table name or namespace can be provided to filter
the snapshots returned. RegionServers maintain a copy of snapshots, refreshing
at a regular interval; by providing a RegionServer option, snapshots will
be retreived from that RegionServer instead of the quota table.

For example:

    hbase> list_quota_snapshots
    hbase> list_quota_snapshots({TABLE => 'table1'})
    hbase> list_quota_snapshots({NAMESPACE => 'org1'})
    hbase> list_quota_snapshots({REGIONSERVER => 'server1.domain,16020,1483482894742'})
    hbase> list_quota_snapshots({NAMESPACE => 'org1', REGIONSERVER => 'server1.domain,16020,1483482894742'})
EOF
      end

      def command(args = {})
        # All arguments may be nil
        desired_table = args[TABLE]
        desired_namespace = args[NAMESPACE]
        desired_regionserver = args[REGIONSERVER]
        formatter.header(%w[TABLE USAGE LIMIT IN_VIOLATION POLICY])
        count = 0
        quotas_admin.get_quota_snapshots(desired_regionserver).each do |table_name, snapshot|
          # Skip this snapshot if it's for a table/namespace the user did not ask for
          next unless accept? table_name, desired_table, desired_namespace
          status = snapshot.getQuotaStatus
          policy = get_policy(status)
          formatter.row([table_name.to_s, snapshot.getUsage.to_s, snapshot.getLimit.to_s,
                         status.isInViolation.to_s, policy])
          count += 1
        end
        formatter.footer(count)
      end

      def get_policy(status)
        # Unwrap the violation policy if it exists
        if status.isInViolation
          status.getPolicy.get.name
        else
          'None'
        end
      end

      def accept?(table_name, desired_table = nil, desired_namespace = nil)
        # Check the table name if given one
        if desired_table && table_name.getQualifierAsString != desired_table
          return false
        end
        # Check the namespace if given one
        if desired_namespace && table_name.getNamespaceAsString != desired_namespace
          return false
        end
        true
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListQuotas < Command
      def help
        <<-EOF
List the quota settings added to the system.
You can filter the result based on USER, TABLE, or NAMESPACE.

For example:

    hbase> list_quotas
    hbase> list_quotas USER => 'bob.*'
    hbase> list_quotas USER => 'bob.*', TABLE => 't1'
    hbase> list_quotas USER => 'bob.*', NAMESPACE => 'ns.*'
    hbase> list_quotas TABLE => 'myTable'
    hbase> list_quotas NAMESPACE => 'ns.*'
EOF
      end

      def command(args = {})
        formatter.header(%w[OWNER QUOTAS])

        # actually do the scanning
        count = quotas_admin.list_quotas(args) do |row, cells|
          formatter.row([row, cells])
        end

        formatter.footer(count)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListQuotaTableSizes < Command
      def help
        <<-EOF
Lists the computed size of each table in the cluster as computed by
all RegionServers. This is the raw information that the Master uses to
make decisions about space quotas. Most times, using `list_quota_snapshots`
provides a higher-level of insight than this command.

For example:

    hbase> list_quota_table_sizes
EOF
      end

      def command(_args = {})
        formatter.header(%w[TABLE SIZE])
        count = 0
        quotas_admin.get_master_table_sizes.each do |tableName, size|
          formatter.row([tableName.to_s, size.to_s])
          count += 1
        end
        formatter.footer(count)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class List < Command
      def help
        <<-EOF
List all user tables in hbase. Optional regular expression parameter could
be used to filter the output. Examples:

  hbase> list
  hbase> list 'abc.*'
  hbase> list 'ns:abc.*'
  hbase> list 'ns:.*'
EOF
      end

      def command(regex = '.*')
        formatter.header(['TABLE'])

        list = admin.list(regex)
        list.each do |table|
          formatter.row([table])
        end

        formatter.footer(list.size)
        list
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListRegions < Command
      def help
        return <<EOF
        List all regions for a particular table as an array and also filter them by server name (optional) as prefix
        and maximum locality (optional). By default, it will return all the regions for the table with any locality.
        The command displays server name, region name, start key, end key, size of the region in MB, number of requests
        and the locality. The information can be projected out via an array as third parameter. By default all these information
        is displayed. Possible array values are SERVER_NAME, REGION_NAME, START_KEY, END_KEY, SIZE, REQ and LOCALITY. Values
        are not case sensitive. If you don't want to filter by server name, pass an empty hash / string as shown below.

        Examples:
        hbase> list_regions 'table_name'
        hbase> list_regions 'table_name', 'server_name'
        hbase> list_regions 'table_name', {SERVER_NAME => 'server_name', LOCALITY_THRESHOLD => 0.8}
        hbase> list_regions 'table_name', {SERVER_NAME => 'server_name', LOCALITY_THRESHOLD => 0.8}, ['SERVER_NAME']
        hbase> list_regions 'table_name', {}, ['SERVER_NAME', 'start_key']
        hbase> list_regions 'table_name', '', ['SERVER_NAME', 'start_key']

EOF
        nil
      end

      def command(table_name, options = nil, cols = nil)
        if options.nil?
          options = {}
        elsif !options.is_a? Hash
          # When options isn't a hash, assume it's the server name
          # and create the hash internally
          options = { SERVER_NAME => options }
        end

        raise "Table #{table_name} must be enabled." unless admin.enabled?(table_name)

        size_hash = {}
        if cols.nil?
          size_hash = { 'SERVER_NAME' => 12, 'REGION_NAME' => 12, 'START_KEY' => 10, 'END_KEY' => 10, 'SIZE' => 5, 'REQ' => 5, 'LOCALITY' => 10 }
        elsif cols.is_a?(Array)
          cols.each do |col|
            if col.casecmp('SERVER_NAME').zero?
              size_hash.store('SERVER_NAME', 12)
            elsif col.casecmp('REGION_NAME').zero?
              size_hash.store('REGION_NAME', 12)
            elsif col.casecmp('START_KEY').zero?
              size_hash.store('START_KEY', 10)
            elsif col.casecmp('END_KEY').zero?
              size_hash.store('END_KEY', 10)
            elsif col.casecmp('SIZE').zero?
              size_hash.store('SIZE', 5)
            elsif col.casecmp('REQ').zero?
              size_hash.store('REQ', 5)
            elsif col.casecmp('LOCALITY').zero?
              size_hash.store('LOCALITY', 10)
            else
              raise "#{col} is not a valid column. Possible values are SERVER_NAME, REGION_NAME, START_KEY, END_KEY, SIZE, REQ, LOCALITY."
            end
          end
        else
          raise "#{cols} must be an array of strings. Possible values are SERVER_NAME, REGION_NAME, START_KEY, END_KEY, SIZE, REQ, LOCALITY."
        end

        error = false
        admin_instance = admin.instance_variable_get('@admin')
        conn_instance = admin_instance.getConnection
        cluster_status = admin_instance.getClusterStatus
        hregion_locator_instance = conn_instance.getRegionLocator(TableName.valueOf(table_name))
        hregion_locator_list = hregion_locator_instance.getAllRegionLocations.to_a
        results = []
        desired_server_name = options[SERVER_NAME]

        begin
          # Filter out region servers which we don't want, default to all RS
          regions = get_regions_for_table_and_server(table_name, conn_instance, desired_server_name)
          # A locality threshold of "1.0" would be all regions (cannot have greater than 1 locality)
          # Regions which have a `dataLocality` less-than-or-equal to this value are accepted
          locality_threshold = 1.0
          if options.key? LOCALITY_THRESHOLD
            value = options[LOCALITY_THRESHOLD]
            # Value validation. Must be a Float, and must be between [0, 1.0]
            raise "#{LOCALITY_THRESHOLD} must be a float value" unless value.is_a? Float
            raise "#{LOCALITY_THRESHOLD} must be between 0 and 1.0, inclusive" unless valid_locality_threshold? value
            locality_threshold = value
          end

          regions.each do |hregion|
            hregion_info = hregion.getRegionInfo
            server_name = hregion.getServerName
            region_load_map = cluster_status.getLoad(server_name).getRegionsLoad
            region_load = region_load_map.get(hregion_info.getRegionName)

            if region_load.nil?
              puts "Can not find region: #{hregion_info.getRegionName} , it may be disabled or in transition\n"
              error = true
              break
            end

            # Ignore regions which exceed our locality threshold
            next unless accept_region_for_locality? region_load.getDataLocality, locality_threshold
            result_hash = {}

            if size_hash.key?('SERVER_NAME')
              result_hash.store('SERVER_NAME', server_name.toString.strip)
              size_hash['SERVER_NAME'] = [size_hash['SERVER_NAME'], server_name.toString.strip.length].max
            end

            if size_hash.key?('REGION_NAME')
              result_hash.store('REGION_NAME', hregion_info.getRegionNameAsString.strip)
              size_hash['REGION_NAME'] = [size_hash['REGION_NAME'], hregion_info.getRegionNameAsString.length].max
            end

            if size_hash.key?('START_KEY')
              startKey = Bytes.toStringBinary(hregion_info.getStartKey).strip
              result_hash.store('START_KEY', startKey)
              size_hash['START_KEY'] = [size_hash['START_KEY'], startKey.length].max
            end

            if size_hash.key?('END_KEY')
              endKey = Bytes.toStringBinary(hregion_info.getEndKey).strip
              result_hash.store('END_KEY', endKey)
              size_hash['END_KEY'] = [size_hash['END_KEY'], endKey.length].max
            end

            if size_hash.key?('SIZE')
              region_store_file_size = region_load.getStorefileSizeMB.to_s.strip
              result_hash.store('SIZE', region_store_file_size)
              size_hash['SIZE'] = [size_hash['SIZE'], region_store_file_size.length].max
            end

            if size_hash.key?('REQ')
              region_requests = region_load.getRequestsCount.to_s.strip
              result_hash.store('REQ', region_requests)
              size_hash['REQ'] = [size_hash['REQ'], region_requests.length].max
            end

            if size_hash.key?('LOCALITY')
              locality = region_load.getDataLocality.to_s.strip
              result_hash.store('LOCALITY', locality)
              size_hash['LOCALITY'] = [size_hash['LOCALITY'], locality.length].max
            end

            results << result_hash
          end
        ensure
          hregion_locator_instance.close
        end

        @end_time = Time.now

        return if error

        size_hash.each do |param, length|
          printf(" %#{length}s |", param)
        end
        printf("\n")

        size_hash.each_value do |length|
          str = '-' * length
          printf(" %#{length}s |", str)
        end
        printf("\n")

        results.each do |result|
          size_hash.each do |param, length|
            printf(" %#{length}s |", result[param])
          end
          printf("\n")
        end

        printf(" %d rows\n", results.size)
      end

      def valid_locality_threshold?(value)
        value >= 0 && value <= 1.0
      end

      def get_regions_for_table_and_server(table_name, conn, server_name)
        get_regions_for_server(get_regions_for_table(table_name, conn), server_name)
      end

      def get_regions_for_server(regions_for_table, server_name)
        regions_for_table.select do |hregion|
          accept_server_name? server_name, hregion.getServerName.toString
        end
      end

      def get_regions_for_table(table_name, conn)
        conn.getRegionLocator(TableName.valueOf(table_name)).getAllRegionLocations.to_a
      end

      def accept_server_name?(desired_server_name, actual_server_name)
        desired_server_name.nil? || actual_server_name.start_with?(desired_server_name)
      end

      def accept_region_for_locality?(actual_locality, locality_threshold)
        actual_locality <= locality_threshold
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListReplicatedTables < Command
      def help
        <<-EOF
List all the tables and column families replicated from this cluster

  hbase> list_replicated_tables
  hbase> list_replicated_tables 'abc.*'
EOF
      end

      def command(regex = '.*')
        formatter.header(['TABLE:COLUMNFAMILY', 'ReplicationType'], [32])
        list = replication_admin.list_replicated_tables(regex)
        list.each do |e|
          map = e.getColumnFamilyMap
          map.each do |cf|
            if cf[1] == org.apache.hadoop.hbase.HConstants::REPLICATION_SCOPE_LOCAL
              replicateType = 'LOCAL'
            elsif cf[1] == org.apache.hadoop.hbase.HConstants::REPLICATION_SCOPE_GLOBAL
              replicateType = 'GLOBAL'
            elsif cf[1] == org.apache.hadoop.hbase.HConstants::REPLICATION_SCOPE_SERIAL
              replicateType = 'SERIAL'
            else
              replicateType = 'UNKNOWN'
            end
            formatter.row([e.getTable.getNameAsString + ':' + cf[0], replicateType], true, [32])
          end
        end
        formatter.footer
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListRsgroups < Command
      def help
        <<-EOF
List all RegionServer groups. Optional regular expression parameter can
be used to filter the output.

Example:

  hbase> list_rsgroups
  hbase> list_rsgroups 'abc.*'

EOF
      end

      def command(regex = '.*')
        formatter.header(['NAME', 'SERVER / TABLE'])

        regex = /#{regex}/ unless regex.is_a?(Regexp)
        list = rsgroup_admin.list_rs_groups
        groups = 0

        list.each do |group|
          next unless group.getName.match(regex)

          groups += 1
          group_name_printed = false

          group.getServers.each do |server|
            if group_name_printed
              group_name = ''
            else
              group_name = group.getName
              group_name_printed = true
            end

            formatter.row([group_name, 'server ' + server.toString])
          end

          group.getTables.each do |table|
            if group_name_printed
              group_name = ''
            else
              group_name = group.getName
              group_name_printed = true
            end

            formatter.row([group_name, 'table ' + table.getNameAsString])
          end

          formatter.row([group.getName, '']) unless group_name_printed
        end

        formatter.footer(groups)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListSecurityCapabilities < Command
      def help
        <<-EOF
List supported security capabilities

Example:
    hbase> list_security_capabilities
EOF
      end

      def command
        list = admin.get_security_capabilities
        list.each do |s|
          puts s.getName
        end
        return list.map(&:getName)
      rescue Exception => e
        if e.to_s.include? 'UnsupportedOperationException'
          puts 'ERROR: Master does not support getSecurityCapabilities'
          return []
        end
        raise e
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ListSnapshotSizes < Command
      def help
        <<-EOF
Lists the size of every HBase snapshot given the space quota size computation
algorithms. An HBase snapshot only "owns" the size of a file when the table
from which the snapshot was created no longer refers to that file.
EOF
      end

      def command(_args = {})
        formatter.header(%w[SNAPSHOT SIZE])
        count = 0
        quotas_admin.list_snapshot_sizes.each do |snapshot, size|
          formatter.row([snapshot.to_s, size.to_s])
          count += 1
        end
        formatter.footer(count)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'time'

module Shell
  module Commands
    class ListSnapshots < Command
      def help
        <<-EOF
List all snapshots taken (by printing the names and relative information).
Optional regular expression parameter could be used to filter the output
by snapshot name.

Examples:
  hbase> list_snapshots
  hbase> list_snapshots 'abc.*'
EOF
      end

      def command(regex = '.*')
        formatter.header(['SNAPSHOT', 'TABLE + CREATION TIME'])

        list = admin.list_snapshot(regex)
        list.each do |snapshot|
          creation_time = Time.at(snapshot.getCreationTime / 1000).to_s
          formatter.row([snapshot.getName, snapshot.getTable + ' (' + creation_time + ')'])
        end

        formatter.footer(list.size)
        list.map(&:getName)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'time'

module Shell
  module Commands
    class ListTableSnapshots < Command
      def help
        <<-EOF
List all completed snapshots matching the table name regular expression and the
snapshot name regular expression (by printing the names and relative information).
Optional snapshot name regular expression parameter could be used to filter the output
by snapshot name.

Examples:
  hbase> list_table_snapshots 'tableName'
  hbase> list_table_snapshots 'tableName.*'
  hbase> list_table_snapshots 'tableName', 'snapshotName'
  hbase> list_table_snapshots 'tableName', 'snapshotName.*'
  hbase> list_table_snapshots 'tableName.*', 'snapshotName.*'
  hbase> list_table_snapshots 'ns:tableName.*', 'snapshotName.*'
EOF
      end

      def command(tableNameRegex, snapshotNameRegex = '.*')
        formatter.header(['SNAPSHOT', 'TABLE + CREATION TIME'])

        list = admin.list_table_snapshots(tableNameRegex, snapshotNameRegex)
        list.each do |snapshot|
          creation_time = Time.at(snapshot.getCreationTime / 1000).to_s
          formatter.row([snapshot.getName, snapshot.getTable + ' (' + creation_time + ')'])
        end

        formatter.footer(list.size)
        list.map(&:getName)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class LocateRegion < Command
      def help
        <<-EOF
Locate the region given a table name and a row-key

  hbase> locate_region 'tableName', 'key0'
EOF
      end

      def command(table, row_key)
        region_location = admin.locate_region(table, row_key)
        hri = region_location.getRegionInfo

        formatter.header(%w[HOST REGION])
        formatter.row([region_location.getHostnamePort, hri.toString])
        formatter.footer(1)
        region_location
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class MajorCompact < Command
      def help
        <<-EOF
          Run major compaction on passed table or pass a region row
          to major compact an individual region. To compact a single
          column family within a region specify the region name
          followed by the column family name.
          Examples:
          Compact all regions in a table:
          hbase> major_compact 't1'
          hbase> major_compact 'ns1:t1'
          Compact an entire region:
          hbase> major_compact 'r1'
          Compact a single column family within a region:
          hbase> major_compact 'r1', 'c1'
          Compact a single column family within a table:
          hbase> major_compact 't1', 'c1'
          Compact table with type "MOB"
          hbase> major_compact 't1', nil, 'MOB'
          Compact a column family using "MOB" type within a table
          hbase> major_compact 't1', 'c1', 'MOB'
        EOF
      end

      def command(table_or_region_name, family = nil, type = 'NORMAL')
        admin.major_compact(table_or_region_name, family, type)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class MergeRegion < Command
      def help
        <<-EOF
Merge two regions. Passing 'true' as the optional third parameter will force
a merge ('force' merges regardless else merge will fail unless passed
adjacent regions. 'force' is for expert use only).

You can pass the encoded region name or the full region name.  The encoded
region name is the hash suffix on region names: e.g. if the region name were
TestTable,0094429456,1289497600452.527db22f95c8a9e0116f0cc13c680396. then
the encoded region name portion is 527db22f95c8a9e0116f0cc13c680396

Examples:

  hbase> merge_region 'FULL_REGIONNAME', 'FULL_REGIONNAME'
  hbase> merge_region 'FULL_REGIONNAME', 'FULL_REGIONNAME', true

  hbase> merge_region 'ENCODED_REGIONNAME', 'ENCODED_REGIONNAME'
  hbase> merge_region 'ENCODED_REGIONNAME', 'ENCODED_REGIONNAME', true
EOF
      end

      def command(region_a_name, region_b_name, force = 'false')
        admin.merge_region(region_a_name, region_b_name, force)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Reassign tables of specified namespaces
    # from one RegionServer group to another.
    class MoveNamespacesRsgroup < Command
      def help
        <<-CMD

  Example:
  hbase> move_namespaces_rsgroup 'dest',['ns1','ns2']

CMD
      end

      def command(dest, namespaces)
        rsgroup_admin.move_namespaces(dest, namespaces)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Move < Command
      def help
        <<-EOF
Move a region.  Optionally specify target regionserver else we choose one
at random.  NOTE: You pass the encoded region name, not the region name so
this command is a little different to the others.  The encoded region name
is the hash suffix on region names: e.g. if the region name were
TestTable,0094429456,1289497600452.527db22f95c8a9e0116f0cc13c680396. then
the encoded region name portion is 527db22f95c8a9e0116f0cc13c680396
A server name is its host, port plus startcode. For example:
host187.example.com,60020,1289493121758
Examples:

  hbase> move 'ENCODED_REGIONNAME'
  hbase> move 'ENCODED_REGIONNAME', 'SERVER_NAME'
EOF
      end

      def command(encoded_region_name, server_name = nil)
        admin.move(encoded_region_name, server_name)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Reassign RegionServers and Tables of
    # specified namespaces from one group to another.
    class MoveServersNamespacesRsgroup < Command
      def help
        <<-CMD

  Example:
  hbase> move_servers_namespaces_rsgroup 'dest',['server1:port','server2:port'],['ns1','ns2']

CMD
      end

      def command(dest, servers, namespaces)
        rsgroup_admin.move_servers_namespaces(dest, servers, namespaces)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class MoveServersRsgroup < Command
      def help
        <<-EOF
Reassign RegionServers from one group to another. Every region of the
RegionServer will be moved to another RegionServer.

Example:

  hbase> move_servers_rsgroup 'dest',['server1:port','server2:port']

EOF
      end

      def command(dest, servers)
        rsgroup_admin.move_servers(dest, servers)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class MoveServersTablesRsgroup < Command
      def help
        <<-EOF
Reassign RegionServers and Tables from one group to another.

Example:

  hbase> move_servers_tables_rsgroup 'dest',['server1:port','server2:port'],['table1','table2']

EOF
      end

      def command(dest, servers, tables)
        rsgroup_admin.move_servers_tables(dest, servers, tables)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class MoveTablesRsgroup < Command
      def help
        <<-EOF
Reassign tables from one RegionServer group to another.

Example:

  hbase> move_tables_rsgroup 'dest',['table1','table2']

EOF
      end

      def command(dest, tables)
        rsgroup_admin.move_tables(dest, tables)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Normalize < Command
      def help
        <<-EOF
Trigger region normalizer for all tables which have NORMALIZATION_ENABLED flag set. Returns true
 if normalizer ran successfully, false otherwise. Note that this command has no effect
 if region normalizer is disabled (make sure it's turned on using 'normalizer_switch' command).

 Examples:

   hbase> normalize
EOF
      end

      def command
        formatter.row([admin.normalize ? 'true' : 'false'])
      end
    end
  end
end
#!/usr/bin/env hbase-jruby
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with this
# work for additional information regarding copyright ownership. The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Prints current region normalizer status

module Shell
  module Commands
    class NormalizerEnabled < Command
      def help
        <<-EOF
Query the state of region normalizer.
Examples:

  hbase> normalizer_enabled
EOF
      end

      def command
        formatter.row([admin.normalizer_enabled?.to_s])
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class NormalizerSwitch < Command
      def help
        <<-EOF
Enable/Disable region normalizer. Returns previous normalizer state.
When normalizer is enabled, it handles all tables with 'NORMALIZATION_ENABLED' => true.
Examples:

  hbase> normalizer_switch true
  hbase> normalizer_switch false
EOF
      end

      def command(enableDisable)
        formatter.row([admin.normalizer_switch(enableDisable) ? 'true' : 'false'])
      end
    end
  end
end
#
# Copyright 2010 The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Processlist < Command
      def help
        <<-EOF
Show regionserver task list.

  hbase> processlist
  hbase> processlist 'all'
  hbase> processlist 'general'
  hbase> processlist 'handler'
  hbase> processlist 'rpc'
  hbase> processlist 'operation'
  hbase> processlist 'all','host187.example.com'
  hbase> processlist 'all','host187.example.com,16020'
  hbase> processlist 'all','host187.example.com,16020,1289493121758'

EOF
      end

      def command(*args)
        if %w[all general handler rpc operation].include? args[0]
          # if the first argument is a valid filter specifier, use it as such
          filter = args[0]
          hosts = args[1, args.length]
        else
          # otherwise, treat all arguments as host addresses by default
          filter = 'general'
          hosts = args
        end

        hosts = admin.getServerNames(hosts, true)

        if hosts.nil?
          puts 'No regionservers available.'
        else
          taskmonitor.tasks(filter, hosts)
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Put < Command
      def help
        <<-EOF
Put a cell 'value' at specified table/row/column and optionally
timestamp coordinates.  To put a cell value into table 'ns1:t1' or 't1'
at row 'r1' under column 'c1' marked with the time 'ts1', do:

  hbase> put 'ns1:t1', 'r1', 'c1', 'value'
  hbase> put 't1', 'r1', 'c1', 'value'
  hbase> put 't1', 'r1', 'c1', 'value', ts1
  hbase> put 't1', 'r1', 'c1', 'value', {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> put 't1', 'r1', 'c1', 'value', ts1, {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> put 't1', 'r1', 'c1', 'value', ts1, {VISIBILITY=>'PRIVATE|SECRET'}

The same commands also can be run on a table reference. Suppose you had a reference
t to table 't1', the corresponding command would be:

  hbase> t.put 'r1', 'c1', 'value', ts1, {ATTRIBUTES=>{'mykey'=>'myvalue'}}
EOF
      end

      def command(table, row, column, value, timestamp = nil, args = {})
        put table(table), row, column, value, timestamp, args
      end

      def put(table, row, column, value, timestamp = nil, args = {})
        @start_time = Time.now
        table._put_internal(row, column, value, timestamp, args)
      end
    end
  end
end

# Add the method table.put that calls Put.put
::Hbase::Table.add_shell_command('put')
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Recommission a region server, optionally load a list of passed regions
    class RecommissionRegionserver < Command
      def help
        <<-EOF
  Remove decommission marker from a region server to allow regions assignments.

  Optionally, load regions onto the server by passing a list of encoded region names.
  NOTE: Region loading is asynchronous.

  Examples:
    hbase> recommission_regionserver 'server'
    hbase> recommission_regionserver 'server,port'
    hbase> recommission_regionserver 'server,port,starttime'
    hbase> recommission_regionserver 'server,port,starttime', ['encoded_region_name1', 'encoded_region_name1']
EOF
      end

      def command(server_name, encoded_region_names = [])
        admin.recommission_regionserver(server_name, encoded_region_names)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemovePeerExcludeNamespaces < Command
      def help
        <<-EOF
Remove the namespaces which not replicated for the specified peer.

Note:
  1. The replicate_all flag need to be true when remove exclude namespaces.
  2. Remove a exclude namespace in the peer config means that all tables in this
     namespace will be replicated to the peer cluster.

Examples:

    # remove ns1 from the not replicable namespaces for peer '2'.
    hbase> remove_peer_exclude_namespaces '2', ["ns1", "ns2"]

        EOF
      end

      def command(id, namespaces)
        replication_admin.remove_peer_exclude_namespaces(id, namespaces)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemovePeerExcludeTableCFs < Command
      def help
        <<-EOF
Remove table-cfs config from the specified peer' exclude table-cfs to make them replicable
Examples:

  # remove tables / table-cfs from peer' exclude table-cfs
  hbase> remove_peer_exclude_tableCFs '2', { "table1" => [], "ns2:table2" => ["cfA", "cfB"]}
        EOF
      end

      def command(id, table_cfs)
        replication_admin.remove_peer_exclude_tableCFs(id, table_cfs)
      end

      def command_name
        'remove_peer_exclude_tableCFs'
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemovePeerNamespaces < Command
      def help
        <<-EOF
  Remove some namespaces from the namespaces config for the specified peer.

  Examples:

    # remove ns1 from the replicable namespaces for peer '2'.
    hbase> remove_peer_namespaces '2', ["ns1"]

  EOF
      end

      def command(id, namespaces)
        replication_admin.remove_peer_namespaces(id, namespaces)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemovePeer < Command
      def help
        <<-EOF
Stops the specified replication stream and deletes all the meta
information kept about it. Examples:

  hbase> remove_peer '1'
EOF
      end

      def command(id)
        replication_admin.remove_peer(id)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemovePeerTableCFs < Command
      def help
        <<-EOF
Remove a table / table-cf from the table-cfs config for the specified peer
Examples:

  # Remove a table / table-cf from the replicable table-cfs for a peer
  hbase> remove_peer_tableCFs '2',  { "ns1:table1" => []}
  hbase> remove_peer_tableCFs '2',  { "ns1:table1" => ["cf1"]}

EOF
      end

      def command(id, table_cfs)
        replication_admin.remove_peer_tableCFs(id, table_cfs)
      end

      def command_name
        'remove_peer_tableCFs'
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemoveRsgroup < Command
      def help
        <<-EOF
Remove a RegionServer group.

  hbase> remove_rsgroup 'my_group'

EOF
      end

      def command(group_name)
        rsgroup_admin.remove_rs_group(group_name)
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RemoveServersRsgroup < Command
      def help
        <<-EOF
Remove decommissioned servers from rsgroup.
Dead/recovering/live servers will be disallowed.
Example:
  hbase> remove_servers_rsgroup ['server1:port','server2:port']
EOF
      end

      def command(servers)
        rsgroup_admin.remove_servers(servers)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class RestoreSnapshot < Command
      def help
        <<-EOF
Restore a specified snapshot.
The restore will replace the content of the original table,
bringing back the content to the snapshot state.
The table must be disabled.

Examples:
  hbase> restore_snapshot 'snapshotName'

Following command will restore all acl from snapshot table into the table.

  hbase> restore_snapshot 'snapshotName', {RESTORE_ACL=>true}
EOF
      end

      def command(snapshot_name, args = {})
        raise(ArgumentError, 'Arguments should be a Hash') unless args.is_a?(Hash)
        restore_acl = args.delete(RESTORE_ACL) || false
        admin.restore_snapshot(snapshot_name, restore_acl)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Revoke < Command
      def help
        <<-EOF
Revoke a user's access rights.
Syntax: revoke <user or @group> [, <table> [, <column family> [, <column qualifier>]]]
Syntax: revoke <user or @group>, <@namespace>

Note: Groups and users access are revoked in the same way, but groups are prefixed with an '@'
      character. Tables and namespaces are specified the same way, but namespaces are
      prefixed with an '@' character.

For example:

    hbase> revoke 'bobsmith'
    hbase> revoke '@admins'
    hbase> revoke 'bobsmith', '@ns1'
    hbase> revoke 'bobsmith', 't1', 'f1', 'col1'
    hbase> revoke 'bobsmith', 'ns1:t1', 'f1', 'col1'
EOF
      end

      def command(user, table_name = nil, family = nil, qualifier = nil)
        security_admin.revoke(user, table_name, family, qualifier)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # List all regions in transition
    class Rit < Command
      def help
        <<-EOF
List all regions in transition.
Examples:
  hbase> rit
        EOF
      end

      def command
        rit = admin.getClusterStatus.getRegionStatesInTransition
        rit.each do |v|
          formatter.row([v.toDescriptiveString])
        end
        formatter.footer(rit.size)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Scan < Command
      def help
        <<-EOF
Scan a table; pass table name and optionally a dictionary of scanner
specifications.  Scanner specifications may include one or more of:
TIMERANGE, FILTER, LIMIT, STARTROW, STOPROW, ROWPREFIXFILTER, TIMESTAMP,
MAXLENGTH, COLUMNS, CACHE, RAW, VERSIONS, ALL_METRICS, METRICS,
REGION_REPLICA_ID, ISOLATION_LEVEL, READ_TYPE, ALLOW_PARTIAL_RESULTS,
BATCH or MAX_RESULT_SIZE

If no columns are specified, all columns will be scanned.
To scan all members of a column family, leave the qualifier empty as in
'col_family'.

The filter can be specified in two ways:
1. Using a filterString - more information on this is available in the
Filter Language document attached to the HBASE-4176 JIRA
2. Using the entire package name of the filter.

If you wish to see metrics regarding the execution of the scan, the
ALL_METRICS boolean should be set to true. Alternatively, if you would
prefer to see only a subset of the metrics, the METRICS array can be
defined to include the names of only the metrics you care about.

Some examples:

  hbase> scan 'hbase:meta'
  hbase> scan 'hbase:meta', {COLUMNS => 'info:regioninfo'}
  hbase> scan 'ns1:t1', {COLUMNS => ['c1', 'c2'], LIMIT => 10, STARTROW => 'xyz'}
  hbase> scan 't1', {COLUMNS => ['c1', 'c2'], LIMIT => 10, STARTROW => 'xyz'}
  hbase> scan 't1', {COLUMNS => 'c1', TIMERANGE => [1303668804000, 1303668904000]}
  hbase> scan 't1', {REVERSED => true}
  hbase> scan 't1', {ALL_METRICS => true}
  hbase> scan 't1', {METRICS => ['RPC_RETRIES', 'ROWS_FILTERED']}
  hbase> scan 't1', {ROWPREFIXFILTER => 'row2', FILTER => "
    (QualifierFilter (>=, 'binary:xyz')) AND (TimestampsFilter ( 123, 456))"}
  hbase> scan 't1', {FILTER =>
    org.apache.hadoop.hbase.filter.ColumnPaginationFilter.new(1, 0)}
  hbase> scan 't1', {CONSISTENCY => 'TIMELINE'}
  hbase> scan 't1', {ISOLATION_LEVEL => 'READ_UNCOMMITTED'}
  hbase> scan 't1', {MAX_RESULT_SIZE => 123456}
For setting the Operation Attributes
  hbase> scan 't1', { COLUMNS => ['c1', 'c2'], ATTRIBUTES => {'mykey' => 'myvalue'}}
  hbase> scan 't1', { COLUMNS => ['c1', 'c2'], AUTHORIZATIONS => ['PRIVATE','SECRET']}
For experts, there is an additional option -- CACHE_BLOCKS -- which
switches block caching for the scanner on (true) or off (false).  By
default it is enabled.  Examples:

  hbase> scan 't1', {COLUMNS => ['c1', 'c2'], CACHE_BLOCKS => false}

Also for experts, there is an advanced option -- RAW -- which instructs the
scanner to return all cells (including delete markers and uncollected deleted
cells). This option cannot be combined with requesting specific COLUMNS.
Disabled by default.  Example:

  hbase> scan 't1', {RAW => true, VERSIONS => 10}

There is yet another option -- READ_TYPE -- which instructs the scanner to
use a specific read type. Example:

  hbase> scan 't1', {READ_TYPE => 'PREAD'}

Besides the default 'toStringBinary' format, 'scan' supports custom formatting
by column.  A user can define a FORMATTER by adding it to the column name in
the scan specification.  The FORMATTER can be stipulated:

 1. either as a org.apache.hadoop.hbase.util.Bytes method name (e.g, toInt, toString)
 2. or as a custom class followed by method name: e.g. 'c(MyFormatterClass).format'.

Example formatting cf:qualifier1 and cf:qualifier2 both as Integers:
  hbase> scan 't1', {COLUMNS => ['cf:qualifier1:toInt',
    'cf:qualifier2:c(org.apache.hadoop.hbase.util.Bytes).toInt'] }

Note that you can specify a FORMATTER by column only (cf:qualifier). You can set a
formatter for all columns (including, all key parts) using the "FORMATTER"
and "FORMATTER_CLASS" options. The default "FORMATTER_CLASS" is
"org.apache.hadoop.hbase.util.Bytes".

  hbase> scan 't1', {FORMATTER => 'toString'}
  hbase> scan 't1', {FORMATTER_CLASS => 'org.apache.hadoop.hbase.util.Bytes', FORMATTER => 'toString'}

Scan can also be used directly from a table, by first getting a reference to a
table, like such:

  hbase> t = get_table 't'
  hbase> t.scan

Note in the above situation, you can still provide all the filtering, columns,
options, etc as described above.

EOF
      end

      def command(table, args = {})
        scan(table(table), args)
      end

      # internal command that actually does the scanning
      def scan(table, args = {})
        formatter.header(['ROW', 'COLUMN+CELL'])

        scan = table._hash_to_scan(args)
        # actually do the scanning
        @start_time = Time.now
        count, is_stale = table._scan_internal(args, scan) do |row, cells|
          formatter.row([row, cells])
        end
        @end_time = Time.now

        formatter.footer(count, is_stale)
        # if scan metrics were enabled, print them after the results
        if !scan.nil? && scan.isScanMetricsEnabled
          formatter.scan_metrics(scan.getScanMetrics, args['METRICS'])
        end
      end
    end
  end
end

# Add the method table.scan that calls Scan.scan
::Hbase::Table.add_shell_command('scan')
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetAuths < Command
      def help
        <<-EOF
Add a set of visibility labels for a user or group
Syntax : set_auths 'user',[label1, label2]

For example:

    hbase> set_auths 'user1', ['SECRET','PRIVATE']
    hbase> set_auths '@group1', ['SECRET','PRIVATE']
EOF
      end

      def command(user, *args)
        visibility_labels_admin.set_auths(user, args)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerBandwidth < Command
      def help
        <<-EOF
Set the replication source per node bandwidth for the specified peer.
Examples:

  # set bandwidth=2MB per regionserver for a peer
  hbase> set_peer_bandwidth '1', 2097152
  # unset bandwidth for a peer to use the default bandwidth configured in server-side
  hbase> set_peer_bandwidth '1'

EOF
      end

      def command(id, bandwidth = 0)
        replication_admin.set_peer_bandwidth(id, bandwidth)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerExcludeNamespaces < Command
      def help
        <<-EOF
  Set the namespaces which not replicated for the specified peer.

  Note:
  1. The replicate_all flag need to be true when set exclude namespaces.
  2. Set a exclude namespace in the peer config means that all tables in this
     namespace will not be replicated to the peer cluster. If peer config
     already has a exclude table, then not allow set this table's namespace
     as a exclude namespace.

  Examples:

    # set exclude namespaces config to null
    hbase> set_peer_exclude_namespaces '1', []
    # set namespaces which not replicated for a peer.
    # set a exclude namespace in the peer config means that all tables in this
    # namespace will not be replicated.
    hbase> set_peer_exclude_namespaces '2', ["ns1", "ns2"]

  EOF
      end

      def command(id, exclude_namespaces)
        replication_admin.set_peer_exclude_namespaces(id, exclude_namespaces)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerExcludeTableCFs < Command
      def help
        <<-EOF
  Set the table-cfs which not replicated for the specified peer.

  Note:
  1. The replicate_all flag need to be true when set exclude table-cfs.
  2. If peer config already has a exclude namespace, then not allow set any
     exclude table of this namespace to the peer config.

  Examples:

    # set exclude table-cfs to null
    hbase> set_peer_exclude_tableCFs '1'
    # set table / table-cf which not replicated for a peer, for a table without
    # an explicit column-family list, all column-families will not be replicated
    hbase> set_peer_exclude_tableCFs '2', { "ns1:table1" => [],
                                    "ns2:table2" => ["cf1", "cf2"],
                                    "ns3:table3" => ["cfA", "cfB"]}

  EOF
      end

      def command(id, exclude_peer_table_cfs = nil)
        replication_admin.set_peer_exclude_tableCFs(id, exclude_peer_table_cfs)
      end

      def command_name
        'set_peer_exclude_tableCFs'
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerNamespaces < Command
      def help
        <<-EOF
  Set the replicable namespaces config for the specified peer.

  1. The replicate_all flag need to be false when set the replicable namespaces.
  2. Set a namespace in the peer config means that all tables in this namespace
     will be replicated to the peer cluster. If peer config already has a table,
     then not allow set this table's namespace to the peer config.

  Examples:

    # set namespaces config is null, then the table-cfs config decide
    # which table to be replicated.
    hbase> set_peer_namespaces '1', []
    # set namespaces to be replicable for a peer.
    # set a namespace in the peer config means that all tables in this
    # namespace (with replication_scope != 0 ) will be replicated.
    hbase> set_peer_namespaces '2', ["ns1", "ns2"]

  EOF
      end

      def command(id, namespaces)
        replication_admin.set_peer_namespaces(id, namespaces)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerReplicateAll < Command
      def help
        <<-EOF
  Set the replicate_all flag to true or false for the specified peer.

  If replicate_all flag is true, then all user tables (REPLICATION_SCOPE != 0)
  will be replicate to peer cluster. But you can use 'set_peer_exclude_namespaces'
  to set which namespaces can't be replicated to peer cluster. And you can use
  'set_peer_exclude_tableCFs' to set which tables can't be replicated to peer
  cluster.

  If replicate_all flag is false, then all user tables cannot be replicate to
  peer cluster. Then you can use 'set_peer_namespaces' or 'append_peer_namespaces'
  to set which namespaces will be replicated to peer cluster. And you can use
  'set_peer_tableCFs' or 'append_peer_tableCFs' to set which tables will be
  replicated to peer cluster.

  Notice: When you want to change a peer's replicate_all flag from false to true,
          you need clean the peer's NAMESPACES and TABLECFS config firstly.
          When you want to change a peer's replicate_all flag from true to false,
          you need clean the peer's EXCLUDE_NAMESPACES and EXCLUDE_TABLECFS
          config firstly.

  Examples:

    # set replicate_all flag to true
    hbase> set_peer_replicate_all '1', true
    # set replicate_all flag to false
    hbase> set_peer_replicate_all '1', false
EOF
      end

      def command(id, replicate_all)
        replication_admin.set_peer_replicate_all(id, replicate_all)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerSerial < Command
      def help
        <<-EOF
  Set the serial flag to true or false for the specified peer.

  If serial flag is true, then all logs of user tables (REPLICATION_SCOPE != 0) will be
  replicated to peer cluster serially, which means that each segment of log for replicated
  table will be pushed to peer cluster in order of their log sequence id.

  If serial flag is false, then the source cluster won't ensure that the logs of replicated
  table will be pushed to peer cluster serially.

  Examples:

    # set serial flag to true
    hbase> set_peer_serial '1', true
    # set serial flag to false
    hbase> set_peer_serial '1', false
  EOF
      end

      def command(id, serial)
        replication_admin.set_peer_serial(id, serial)
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetPeerTableCFs < Command
      def help
        <<-EOF
  Set the replicable table-cf config for the specified peer.

  Note:
  1. The replicate_all flag need to be false when set the replicable table-cfs.
  2. Can't set a table to table-cfs config if it's namespace already was in
     namespaces config of this peer.

  Examples:

    # set table-cfs config is null, then the namespaces config decide which
    # table to be replicated.
    hbase> set_peer_tableCFs '1'
    # set table / table-cf to be replicable for a peer, for a table without
    # an explicit column-family list, all replicable column-families (with
    # replication_scope == 1) will be replicated
    hbase> set_peer_tableCFs '2',
     { "ns1:table1" => [],
     "ns2:table2" => ["cf1", "cf2"],
     "ns3:table3" => ["cfA", "cfB"]}

  EOF
      end

      def command(id, peer_table_cfs = nil)
        replication_admin.set_peer_tableCFs(id, peer_table_cfs)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetQuota < Command
      def help
        <<-EOF
Set a quota for a user, table, namespace or region server.
Syntax : set_quota TYPE => <type>, <args>

TYPE => THROTTLE
1. User can set throttle quota for user, namespace, table, region server, user over namespace,
   user over table by USER, NAMESPACE, TABLE, REGIONSERVER keys.
   Note: Setting specified region server quota isn't supported currently and using 'all' to
   represent all region servers.
2. User can set throttle quota type either on read, write or on both the requests together(
   read+write, default throttle type) by THROTTLE_TYPE => READ, WRITE, REQUEST.
3. The request limit can be expressed using the form 100req/sec, 100req/min; or can be expressed
   using the form 100k/sec, 100M/min with (B, K, M, G, T, P) as valid size unit; or can be expressed
   using the form 100CU/sec as capacity unit by LIMIT key.
   The valid time units are (sec, min, hour, day).
4. User can set throttle scope to be either MACHINE(default throttle scope) or CLUSTER by
   SCOPE => MACHINE, CLUSTER. MACHINE scope quota means the throttle limit is used by single
   region server, CLUSTER scope quota means the throttle limit is shared by all region servers.
   Region server throttle quota must be MACHINE scope.
   Note: because currently use [ClusterLimit / RsNum] to divide cluster limit to machine limit,
   so it's better to do not use cluster scope quota when you use rs group feature.

For example:

    hbase> set_quota TYPE => THROTTLE, USER => 'u1', LIMIT => '10req/sec'
    hbase> set_quota TYPE => THROTTLE, THROTTLE_TYPE => READ, USER => 'u1', LIMIT => '10req/sec'

    hbase> set_quota TYPE => THROTTLE, USER => 'u1', LIMIT => '10M/sec'
    hbase> set_quota TYPE => THROTTLE, THROTTLE_TYPE => WRITE, USER => 'u1', LIMIT => '10M/sec'

    hbase> set_quota TYPE => THROTTLE, USER => 'u1', LIMIT => '10CU/sec'
    hbase> set_quota TYPE => THROTTLE, THROTTLE_TYPE => WRITE, USER => 'u1', LIMIT => '10CU/sec'

    hbase> set_quota TYPE => THROTTLE, USER => 'u1', TABLE => 't2', LIMIT => '5K/min'
    hbase> set_quota TYPE => THROTTLE, USER => 'u1', NAMESPACE => 'ns2', LIMIT => NONE

    hbase> set_quota TYPE => THROTTLE, NAMESPACE => 'ns1', LIMIT => '10req/sec'
    hbase> set_quota TYPE => THROTTLE, TABLE => 't1', LIMIT => '10M/sec'
    hbase> set_quota TYPE => THROTTLE, THROTTLE_TYPE => WRITE, TABLE => 't1', LIMIT => '10M/sec'
    hbase> set_quota TYPE => THROTTLE, USER => 'u1', LIMIT => NONE
    hbase> set_quota TYPE => THROTTLE, THROTTLE_TYPE => WRITE, USER => 'u1', LIMIT => NONE

    hbase> set_quota TYPE => THROTTLE, REGIONSERVER => 'all', LIMIT => '30000req/sec'
    hbase> set_quota TYPE => THROTTLE, REGIONSERVER => 'all', THROTTLE_TYPE => WRITE, LIMIT => '20000req/sec'
    hbase> set_quota TYPE => THROTTLE, REGIONSERVER => 'all', LIMIT => NONE

    hbase> set_quota TYPE => THROTTLE, NAMESPACE => 'ns1', LIMIT => '10req/sec', SCOPE => CLUSTER
    hbase> set_quota TYPE => THROTTLE, NAMESPACE => 'ns1', LIMIT => '10req/sec', SCOPE => MACHINE

    hbase> set_quota USER => 'u1', GLOBAL_BYPASS => true

TYPE => SPACE
Users can either set a quota on a table or a namespace. The quota is a limit on the target's
size on the FileSystem and some action to take when the target exceeds that limit. The limit
is in bytes and can expressed using standard metric suffixes (B, K, M, G, T, P), defaulting
to bytes if not provided. Different quotas can be applied to one table at the table and namespace
level; table-level quotas take priority over namespace-level quotas.

There are a limited number of policies to take when a quota is violation, listed in order of
least strict to most strict.

  NO_INSERTS - No new data is allowed to be ingested (e.g. Put, Increment, Append).
  NO_WRITES - Same as NO_INSERTS but Deletes are also disallowed.
  NO_WRITES_COMPACTIONS - Same as NO_WRITES but compactions are also disallowed.
  DISABLE - The table(s) are disabled.

For example:

  hbase> set_quota TYPE => SPACE, TABLE => 't1', LIMIT => '1G', POLICY => NO_INSERTS
  hbase> set_quota TYPE => SPACE, TABLE => 't2', LIMIT => '50G', POLICY => DISABLE
  hbase> set_quota TYPE => SPACE, TABLE => 't3', LIMIT => '2T', POLICY => NO_WRITES_COMPACTIONS
  hbase> set_quota TYPE => SPACE, NAMESPACE => 'ns1', LIMIT => '50T', POLICY => NO_WRITES

Space quotas can also be removed via this command. To remove a space quota, provide NONE
for the limit.

For example:

  hbase> set_quota TYPE => SPACE, TABLE => 't1', LIMIT => NONE
  hbase> set_quota TYPE => SPACE, NAMESPACE => 'ns1', LIMIT => NONE

EOF
      end

      def command(args = {})
        if args.key?(TYPE)
          qtype = args.delete(TYPE)
          case qtype
          when THROTTLE
            if args[LIMIT].eql? NONE
              args.delete(LIMIT)
              quotas_admin.unthrottle(args)
            else
              quotas_admin.throttle(args)
            end
          when SPACE
            if args[LIMIT].eql? NONE
              args.delete(LIMIT)
              # Table/Namespace argument is verified in remove_space_limit
              quotas_admin.remove_space_limit(args)
            else
              raise(ArgumentError, 'Expected a LIMIT to be provided') unless args.key?(LIMIT)
              raise(ArgumentError, 'Expected a POLICY to be provided') unless args.key?(POLICY)
              quotas_admin.limit_space(args)
            end
          else
            raise 'Invalid TYPE argument. got ' + qtype
          end
        elsif args.key?(GLOBAL_BYPASS)
          quotas_admin.set_global_bypass(args.delete(GLOBAL_BYPASS), args)
        else
          raise 'Expected TYPE argument'
        end
      end
    end
  end
end
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class SetVisibility < Command
      def help
        <<-EOF
Set the visibility expression on one or more existing cells.

Pass table name, visibility expression, and a dictionary containing
scanner specifications.  Scanner specifications may include one or more
of: TIMERANGE, FILTER, STARTROW, STOPROW, ROWPREFIXFILTER, TIMESTAMP, or COLUMNS

If no columns are specified, all columns will be included.
To include all members of a column family, leave the qualifier empty as in
'col_family:'.

The filter can be specified in two ways:
1. Using a filterString - more information on this is available in the
Filter Language document attached to the HBASE-4176 JIRA
2. Using the entire package name of the filter.

Examples:

    hbase> set_visibility 't1', 'A|B', {COLUMNS => ['c1', 'c2']}
    hbase> set_visibility 't1', '(A&B)|C', {COLUMNS => 'c1',
        TIMERANGE => [1303668804000, 1303668904000]}
    hbase> set_visibility 't1', 'A&B&C', {ROWPREFIXFILTER => 'row2',
        FILTER => "(QualifierFilter (>=, 'binary:xyz')) AND
        (TimestampsFilter ( 123, 456))"}

This command will only affect existing cells and is expected to be mainly
useful for feature testing and functional verification.
EOF
      end

      def command(table, visibility, scan)
        t = table(table)
        @start_time = Time.now
        scanner = t._get_scanner(scan)
        count = 0
        iter = scanner.iterator
        while iter.hasNext
          row = iter.next
          row.listCells.each do |cell|
            put = org.apache.hadoop.hbase.client.Put.new(row.getRow)
            put.add(cell)
            t.set_cell_visibility(put, visibility)
            t.table.put(put)
          end
          count += 1
        end
        formatter.footer(count)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

java_import org.apache.hadoop.hbase.filter.ParseFilter

module Shell
  module Commands
    class ShowFilters < Command
      def help
        <<-EOF
Show all the filters in hbase. Example:
  hbase> show_filters

  ColumnPrefixFilter
  TimestampsFilter
  PageFilter
  .....
  KeyOnlyFilter
EOF
      end

      def command
        parseFilter = ParseFilter.new
        supportedFilters = parseFilter.getSupportedFilters

        supportedFilters.each do |filter|
          formatter.row([filter])
        end
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ShowPeerTableCFs < Command
      def help
        <<-EOF
  Show replicable table-cf config for the specified peer.

    hbase> show_peer_tableCFs '2'
  EOF
      end

      def command(id)
        peer_table_cfs = replication_admin.show_peer_tableCFs(id)
        puts peer_table_cfs
        peer_table_cfs
      end

      def command_name
        'show_peer_tableCFs'
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Snapshot < Command
      def help
        <<-EOF
Take a snapshot of specified table. Examples:

  hbase> snapshot 'sourceTable', 'snapshotName'
  hbase> snapshot 'namespace:sourceTable', 'snapshotName', {SKIP_FLUSH => true}
EOF
      end

      def command(table, snapshot_name, *args)
        admin.snapshot(table, snapshot_name, *args)
      end
    end
  end
end
#!/usr/bin/env hbase-jruby
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with this
# work for additional information regarding copyright ownership. The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Prints the current split or merge status
module Shell
  module Commands
    # Command for check split or merge switch status
    class SplitormergeEnabled < Command
      def help
        print <<-EOF
Query the switch's state. You can set switch type, 'SPLIT' or 'MERGE'
Examples:

  hbase> splitormerge_enabled 'SPLIT'
EOF
      end

      def command(switch_type)
        formatter.row(
          [admin.splitormerge_enabled(switch_type) ? 'true' : 'false']
        )
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Command for set switch for split and merge
    class SplitormergeSwitch < Command
      def help
        print <<-EOF
Enable/Disable one switch. You can set switch type 'SPLIT' or 'MERGE'. Returns previous split state.
Examples:

  hbase> splitormerge_switch 'SPLIT', true
  hbase> splitormerge_switch 'SPLIT', false
EOF
      end

      def command(switch_type, enabled)
        formatter.row(
          [admin.splitormerge_switch(switch_type, enabled) ? 'true' : 'false']
        )
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Split < Command
      def help
        <<-EOF
Split entire table or pass a region to split individual region.  With the
second parameter, you can specify an explicit split key for the region.
Examples:
    split 'TABLENAME'
    split 'REGIONNAME'
    split 'ENCODED_REGIONNAME'
    split 'TABLENAME', 'splitKey'
    split 'REGIONNAME', 'splitKey'
    split 'ENCODED_REGIONNAME', 'splitKey'
EOF
      end

      def command(table_or_region_name, split_point = nil)
        admin.split(table_or_region_name, split_point)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Status < Command
      def help
        <<-EOF
Show cluster status. Can be 'summary', 'simple', 'detailed', or 'replication'. The
default is 'summary'. Examples:

  hbase> status
  hbase> status 'simple'
  hbase> status 'summary'
  hbase> status 'detailed'
  hbase> status 'replication'
  hbase> status 'replication', 'source'
  hbase> status 'replication', 'sink'
EOF
      end

      def command(format = 'summary', type = 'both')
        admin.status(format, type)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Stop active Master
    class StopMaster < Command
      def help
        <<-EOF
Stop active Master. For experts only.
Examples:

  hbase> stop_master
EOF
      end

      def command
        admin.stop_master
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    # Stop a RegionServer
    class StopRegionserver < Command
      def help
        <<-EOF
Stop a RegionServer. For experts only.
Consider using graceful_stop.sh script instead!

Examples:

  hbase> stop_regionserver 'hostname:port'
EOF
      end

      def command(hostport)
        admin.stop_regionserver(hostport)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class TableHelp < Command
      def help
        Hbase::Table.help
      end

      # just print the help
      def command
        # call the shell to get the nice formatting there
        @shell.help_command 'table_help'
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

java_import org.apache.hadoop.hbase.trace.SpanReceiverHost

module Shell
  module Commands
    class Trace < Command
      @@conf = org.apache.htrace.core.HTraceConfiguration.fromKeyValuePairs(
        'sampler.classes', 'org.apache.htrace.core.AlwaysSampler'
      )
      @@tracer = org.apache.htrace.core.Tracer::Builder.new('HBaseShell').conf(@@conf).build()
      @@tracescope = nil

      def help
        <<-EOF
Start or Stop tracing using HTrace.
Always returns true if tracing is running, otherwise false.
If the first argument is 'start', new span is started.
If the first argument is 'stop', current running span is stopped.
('stop' returns false on success.)
If the first argument is 'status', just returns if or not tracing is running.
On 'start'-ing, you can optionally pass the name of span as the second argument.
The default name of span is 'HBaseShell'.
Repeating 'start' does not start nested span.

Examples:

  hbase> trace 'start'
  hbase> trace 'status'
  hbase> trace 'stop'

  hbase> trace 'start', 'MySpanName'
  hbase> trace 'stop'

EOF
      end

      def command(startstop = 'status', spanname = 'HBaseShell')
        trace(startstop, spanname)
      end

      def trace(startstop, spanname)
        @@receiver ||= SpanReceiverHost.getInstance(@shell.hbase.configuration)
        if startstop == 'start'
          unless tracing?
            @@tracescope = @@tracer.newScope(spanname)
          end
        elsif startstop == 'stop'
          if tracing?
            @@tracescope.close
            @@tracescope = nil
          end
        end
        tracing?
      end

      def tracing?
        @@tracescope != nil
      end
    end
  end
end
#
# Copyright The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class TransitPeerSyncReplicationState < Command
      def help
        <<-EOF
Transit current cluster to new state in the specified synchronous replication peer.
Examples:

  # Transit cluster state to DOWNGRADE_ACTIVE in a synchronous replication peer
  hbase> transit_peer_sync_replication_state '1', 'DOWNGRADE_ACTIVE'
  # Transit cluster state to ACTIVE in a synchronous replication peer
  hbase> transit_peer_sync_replication_state '1', 'ACTIVE'
  # Transit cluster state to STANDBY in a synchronous replication peer
  hbase> transit_peer_sync_replication_state '1', 'STANDBY'

EOF
      end

      def command(id, state)
        replication_admin.transit_peer_sync_replication_state(id, state)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class TruncatePreserve < Command
      def help
        <<-EOF
  Disables, drops and recreates the specified table while still maintaing the previous region boundaries.
EOF
      end

      def command(table)
        admin.truncate_preserve(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Truncate < Command
      def help
        <<-EOF
  Disables, drops and recreates the specified table.
EOF
      end

      def command(table)
        admin.truncate(table)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Unassign < Command
      def help
        <<-EOF
Unassign a region. Unassign will close region in current location and then
reopen it again.  Pass 'true' to force the unassignment ('force' will clear
all in-memory state in master before the reassign. If results in
double assignment use hbck -fix to resolve. To be used by experts).
Use with caution.  For expert use only.  Examples:

  hbase> unassign 'REGIONNAME'
  hbase> unassign 'REGIONNAME', true
  hbase> unassign 'ENCODED_REGIONNAME'
  hbase> unassign 'ENCODED_REGIONNAME', true
EOF
      end

      def command(region_name, force = 'false')
        admin.unassign(region_name, force)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class UpdateAllConfig < Command
      def help
        <<-EOF
Reload a subset of configuration on all servers in the cluster.  See
http://hbase.apache.org/book.html#dyn_config for more details. Here is how
you would run the command in the hbase shell:
  hbase> update_all_config
EOF
      end

      def command
        admin.update_all_config
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class UpdateConfig < Command
      def help
        <<-EOF
Reload a subset of configuration on server 'servername' where servername is
host, port plus startcode. For example: host187.example.com,60020,1289493121758
See http://hbase.apache.org/book.html#dyn_config for more details. Here is how
you would run the command in the hbase shell:
  hbase> update_config 'servername'
EOF
      end

      def command(serverName)
        admin.update_config(serverName)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class UpdatePeerConfig < Command
      def help
        <<-EOF
A peer can either be another HBase cluster or a custom replication endpoint. In either case an id
must be specified to identify the peer. This command does not interrupt processing on an enabled replication peer.

Two optional arguments are DATA and CONFIG which can be specified to set different values for either
the peer_data or configuration for a custom replication endpoint. Any existing values not updated by this command
are left unchanged.

CLUSTER_KEY, REPLICATION_ENDPOINT, and TABLE_CFs cannot be updated with this command.
To update TABLE_CFs, see the append_peer_tableCFs and remove_peer_tableCFs commands.

  hbase> update_peer_config '1', DATA => { "key1" => 1 }
  hbase> update_peer_config '2', CONFIG => { "config1" => "value1", "config2" => "value2" }
  hbase> update_peer_config '3', DATA => { "key1" => 1 }, CONFIG => { "config1" => "value1", "config2" => "value2" },

        EOF
      end

      def command(id, args = {})
        replication_admin.update_peer_config(id, args)
      end
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class UserPermission < Command
      def help
        <<-EOF
Show all permissions for the particular user.
Syntax : user_permission <table>

Note: A namespace must always precede with '@' character.

For example:

    hbase> user_permission
    hbase> user_permission '@ns1'
    hbase> user_permission '@.*'
    hbase> user_permission '@^[a-c].*'
    hbase> user_permission 'table1'
    hbase> user_permission 'namespace1:table1'
    hbase> user_permission '.*'
    hbase> user_permission '^[A-C].*'
EOF
      end

      def command(table_regex = nil)
        # admin.user_permission(table_regex)
        formatter.header(['User', 'Namespace,Table,Family,Qualifier:Permission'])

        count = security_admin.user_permission(table_regex) do |user, permission|
          formatter.row([user, permission])
        end

        formatter.footer(count)
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Version < Command
      def help
        <<-EOF
Output this HBase version
EOF
      end

      def command
        # Output version.
        puts "#{org.apache.hadoop.hbase.util.VersionInfo.getVersion}, " \
             "r#{org.apache.hadoop.hbase.util.VersionInfo.getRevision}, " \
             "#{org.apache.hadoop.hbase.util.VersionInfo.getDate}"
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Shell
  module Commands
    class WalRoll < Command
      def help
        <<-EOF
Roll the log writer. That is, start writing log messages to a new file.
The name of the regionserver should be given as the parameter.  A
'server_name' is the host, port plus startcode of a regionserver. For
example: host187.example.com,60020,1289493121758 (find servername in
master ui or when you do detailed status in shell)
EOF
      end

      def command(server_name)
        admin.wal_roll(server_name)
      end
    end

    # TODO: remove old HLog version
    class HlogRoll < WalRoll
    end
  end
end
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class Whoami < Command
      def help
        <<-EOF
Show the current hbase user.
Syntax : whoami
For example:

    hbase> whoami
EOF
      end

      def command
        user = org.apache.hadoop.hbase.security.User.getCurrent
        puts user.toString.to_s
        groups = user.getGroupNames.to_a
        if !groups.nil? && !groups.empty?
          puts "    groups: #{groups.join(', ')}"
        end
      end
    end
  end
end
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Shell
  module Commands
    class ZkDump < Command
      def help
        <<-EOF
Dump status of HBase cluster as seen by ZooKeeper.
EOF
      end

      def command
        puts admin.zk_dump
      end
    end
  end
end




bin/hbase shell,这个就是常用的shell工具，运维常用的DDL和DML都会通过此进行，其具体实现（对hbase的调用）是用ruby写的

bin/hbase shell -d

bin/hbase shell ./sample_commands.txt

$ HBASE_SHELL_OPTS="-verbose:gc -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCDateStamps \
  -XX:+PrintGCDetails -Xloggc:$HBASE_HOME/logs/gc-hbase.log" ./bin/hbase shell

# Hbase集群的访问入口
# 使用HBase RPC机制与HMaster和HRegionServer进行通信
# 使用HMaster进行通信管理类操作
# 与HRegionServer进行数据读写类操作
# 包含访问HBase的接口 并维护cache来加快对HBase的访问

# upgrade         Upgrade hbase
# master          Run an HBase HMaster node
# regionserver    Run an HBase HRegionServer node
# zookeeper       Run a Zookeeper server
# rest            Run an HBase REST server
# thrift          Run the HBase Thrift server
# thrift2         Run the HBase Thrift2 server
# clean           Run the HBase clean up script
# classpath       Dump hbase CLASSPATH
# mapredcp        Dump CLASSPATH entries required by mapreduce
# pe              Run PerformanceEvaluation
# ltt             Run LoadTestTool
# version         Print the version
# CLASSNAME       Run the class named CLASSNAME

================

000765d9-4ce5-45d3-bd3c-5355e15f34cb_1512916178000_2  column=cf:type, timestamp=1512916178891, value=2
——20170830202048

scan 'mileage_check_coords', {STARTROW=>'c306b4c9-1bfd-4753-8d8a-0b7867bfa8e7_201701', STOPROW=>'c306b4c9-1bfd-4753-8d8a-0b7867bfa8e7_201712'}

major_compact 'mileage_check_coords'

import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.SubstringComparator \
import org.apache.hadoop.hbase.filter.RowFilter \

scan 'mileage_check_coords', {FILTER => RowFilter.new(CompareFilter::CompareOp.valueOf('EQUAL'), SubstringComparator.new('_201707'))} \


get 'mileage_check_coords','27E2ADD687957EB1E0533C02A8C0B094'

----------------------------------


scan 'packet', {FILTER => RowFilter.new(CompareFilter::CompareOp.valueOf('EQUAL'), SubstringComparator.new('892ef1af-5e99-4ed5-9be0-7c8b457cb1c0'))}


import org.apache.hadoop.hbase.filter.KeyOnlyFilter;
scan 'hbaseFilter', {FILTER=>KeyOnlyFilter.new()}


hbase(main):096:0> import org.apache.hadoop.hbase.filter.FirstKeyOnlyFilter;
hbase(main):097:0* scan 'hbaseFilter',{FILTER=>FirstKeyOnlyFilter.new()}


hbase(main):106:0> import org.apache.hadoop.hbase.filter.PrefixFilter;
hbase(main):107:0* import org.apache.hadoop.hbase.util.Bytes;
hbase(main):108:0* scan 'hbaseFilter',{FILTER=>PrefixFilter.new(Bytes.toBytes('row3'))}


hbase(main):113:0> import org.apache.hadoop.hbase.filter.ColumnPrefixFilter;
hbase(main):114:0* import org.apache.hadoop.hbase.util.Bytes;
hbase(main):115:0* scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>ColumnPrefixFilter.new(Bytes.toBytes('n'))}


hbase(main):011:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"MultipleColumnPrefixFilter('a','b')"}

hbase(main):012:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"ColumnCountGetFilter(2)"}

hbase(main):013:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"PageFilter(3)"}

hbase(main):014:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"ColumnPaginationFilter(2,1)"}

hbase(main):015:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"InclusiveStopFilter('row15')"}

hbase(main):016:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"TimestampsFilter(1499150787875,1499150787913)"}

hbase(main):018:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"RowFilter(>=,'binary:row6')"}

hbase(main):020:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"FamilyFilter(=,'substring:f')"}

hbase(main):023:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"QualifierFilter(=,'regexstring:n.')"}

hbase(main):024:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"ValueFilter(=,'binary:name3')"}

hbase(main):035:0> scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',COLUMN=>'f',FILTER=>"SingleColumnValueFilter('f','name',>=,'binary:name3')"}

scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"(FamilyFilter(=,'substring:f')) AND (ValueFilter(>,'binary:name6'))"}


scan 'hbaseFilter',{STARTROW=>'row0',STOPROW=>'row99',FILTER=>"(FamilyFilter(=,'substring:f')) AND (ValueFilter(>,'binary:name6')) OR (FamilyFilter(=,'substring:f2')) AND (ValueFilter(>,'binary:name17'))"}

scan ‘tweet0’, {FILTER=>”SingleColumnValueFilter(‘info’,’pubtime’,=,’regexstring:2014-11-08.*’)”}

scan ‘tweet0’, {FILTER=>”SingleColumnValueFilter(‘info’,’pubtime’,>=,’binary:2014-11-08 19:26:27’) AND SingleColumnValueFilter(‘info’,’pubtime’,<=,’binary:2014-11-10 20:20:00’)”}


scan ‘tweet0’, {FILTER=>”SingleColumnValueFilter(‘emotion’,’PB’,=,’binary:\x00\x00\x00\x05’)”, COLUMNS=>[‘emotion:PB’]}


前面例子中的regexstring:2014-11-08.*、binary:\x00\x00\x00\x05，这都是比较器。HBase的filter有四种比较器：
（1）二进制比较器：如’binary:abc’，按字典排序跟’abc’进行比较
（2）二进制前缀比较器：如’binaryprefix:abc’，按字典顺序只跟’abc’比较前3个字符
（3）正则表达式比较器：如’regexstring:ab*yz’，按正则表达式匹配以ab开头，以yz结尾的值。这个比较器只能使用=、!=两个比较运算符。
（4）子串比较器：如’substring:abc123’，匹配以abc123开头的值。这个比较顺也只能使用=、!=两个比较运算符。


SingleColumnValueFilter 这个过滤器有6个参数：列族、列名、比较运算符、比较器和两个可选参数：filterIfColumnMissing和setLatestVersionOnly。
filterIfColumnMissing：如果设置为true，则会把没有过滤器所指定列的行都过滤掉。默认值是false，所以看上去，当没有过滤器所指定的列时，过滤器不起作用。
setLatestVersionOnly：如果设置为false，则除了检查最新版本，还会检查以前的版本。默认值是true，只检查最新版本的值。
这两个参数要么一起使用，要么都不使用。

import org.apache.hadoop.hbase.filter.SingleColumnValueFilter
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.BinaryComparator
scan ‘tweet0’, { FILTER => SingleColumnValueFilter.new(Bytes.toBytes(‘info’), Bytes.toBytes(‘id’), CompareFilter::CompareOp.valueOf(‘EQUAL’), BinaryComparator.new(Bytes.toBytes(‘1001158684’))), COLUMNS=>[‘info:id’]}

=======================================

hbase(main):002:0> import org.apache.hadoop.hbase.util.Bytes
hbase(main):003:0> import org.apache.hadoop.hbase.filter.SingleColumnValueFilter
hbase(main):004:0> import org.apache.hadoop.hbase.filter.BinaryComparator
hbase(main):005:0> import org.apache.hadoop.hbase.filter.CompareFilter

scan 'test', { STARTROW=>'row-1',ENDROW=>'row-4',FILTER => SingleColumnValueFilter.new(Bytes.toBytes('d'), Bytes.toBytes('a'), CompareFilter::CompareOp.valueOf('EQUAL'), BinaryComparator.new(Bytes.toBytes('v-b')))}

scan 'test1',{STARTROW=>'006040058',ENDROW=>'006040059',COLUMN=>'d:ltime',FILTER=>SingleColumnValueFilter.new(Bytes.toBytes('d'), Bytes.toBytes('eventCat'), CompareFilter::CompareOp.valueOf('EQUAL'), SubstringComparator.new('jbs'))}

----------------------------------------
hbase shell test.hbaseshell


create 't1',{NAME => 'f1', VERSIONS => 2},{NAME => 'f2', VERSIONS => 2}

 disable 't1'

 drop 't1'


 describe 't1'



f)  多条件查询

#使用scan

hbase(main)>scan 't1', {COLUMNS => ['c1', 'c2'], LIMIT => 10, STARTROW => '052072986'}
hbase(main)>scan 't1', {FILTER => "(PrefixFilter ('row2') AND (QualifierFilter (>=, 'binary:xyz'))) AND (TimestampsFilter ( 123, 456))"}

hbase(main)>scan 't1', { COLUMNS =>[ 'c1','c2'], LIMIT => 2,STARTROW => '052072986'}

hbase(main)>scan 't1', {FILTER => "(PrefixFilter ('00036')) AND (SingleColumnValueFilter ('列族','列名',>=,'binary:20141208'))"}

hbase(main)>scan 't1', {FILTER => "(PrefixFilter ('00036')) AND (SingleColumnValueFilter ('列族','列名',>=,'binary:20141208')) AND (SingleColumnValueFilter ('列族','列名',<,'binary:20150101'))"}



g）查询表中的数据行数

# 语法：count <table>, {INTERVAL => intervalNum, CACHE => cacheNum}
# INTERVAL设置多少行显示一次及对应的rowkey，默认1000；CACHE每次去取的缓存区大小，默认是10，调整该参数可提高查询速度
# 例如，查询表t1中的行数，每100条显示一次，缓存区为500
hbase(main)> count 't1', {INTERVAL => 100, CACHE => 500}




3）删除数据
a )删除行中的某个列值

# 语法：delete <table>, <rowkey>,  <family:column> , <timestamp>,必须指定列名
# 例如：删除表t1，rowkey001中的f1:col1的数据
hbase(main)> delete 't1','rowkey001','f1:col1'
注：将删除改行f1:col1列所有版本的数据



b )删除行

# 语法：deleteall <table>, <rowkey>,  <family:column> , <timestamp>，可以不指定列名，删除整行数据
# 例如：删除表t1，rowk001的数据
hbase(main)> deleteall 't1','rowkey001'



c）删除表中的所有数据

# 语法： truncate <table>
# 其具体过程是：disable table -> drop table -> create table
# 例如：删除表t1的所有数据
hbase(main)> truncate 't1'


put ‘scores','Tom','grade:','5′
put ‘scores','Tom','course:math','97′
put ‘scores','Tom','course:art','87′
put ‘scores','Jim','grade','4′
put ‘scores','Jim','course:','89′
put ‘scores','Jim','course:','80′

 put ‘t1′, ‘r1′, ‘c1′, ‘value', ts1


 get ‘scores','Jim'
 get ‘scores','Jim','grade'


 hbase> get ‘t1′, ‘r1′
 hbase> get ‘t1′, ‘r1′, {TIMERANGE => [ts1, ts2]}
 hbase> get ‘t1′, ‘r1′, {COLUMN => ‘c1′}
 hbase> get ‘t1′, ‘r1′, {COLUMN => ['c1', 'c2', 'c3']}
 hbase> get ‘t1′, ‘r1′, {COLUMN => ‘c1′, TIMESTAMP => ts1}
 hbase> get ‘t1′, ‘r1′, {COLUMN => ‘c1′, TIMERANGE => [ts1, ts2], VERSIONS => 4}
 hbase> get ‘t1′, ‘r1′, {COLUMN => ‘c1′, TIMESTAMP => ts1, VERSIONS => 4}
 hbase> get ‘t1′, ‘r1′, ‘c1′
 hbase> get ‘t1′, ‘r1′, ‘c1′, ‘c2′
 hbase> get ‘t1′, ‘r1′, ['c1', 'c2']


 scan ‘scores'


 hbase> scan ‘.META.'
 hbase> scan ‘.META.', {COLUMNS => ‘info:regioninfo'}
 hbase> scan ‘t1′, {COLUMNS => ['c1', 'c2'], LIMIT => 10, STARTROW => ‘xyz'}
 hbase> scan ‘t1′, {COLUMNS => ‘c1′, TIMERANGE => [1303668804, 1303668904]}
 hbase> scan ‘t1′, {FILTER => “(PrefixFilter (‘row2′) AND (QualifierFilter (>=, ‘binary:xyz'))) AND (TimestampsFilter ( 123, 456))”}
 hbase> scan ‘t1′, {FILTER => org.apache.hadoop.hbase.filter.ColumnPaginationFilter.new(1, 0)}


 delete ‘scores','Jim','grade'
 delete ‘scores','Jim'


hbase> delete ‘t1′, ‘r1′, ‘c1′, ts1


disable ‘scores'
alter ‘scores',NAME=>'info'
enable ‘scores'


hbase> alter ‘t1′, NAME => ‘f1′, VERSIONS => 5


hbase> alter ‘t1′, NAME => ‘f1′, METHOD => ‘delete'
hbase> alter ‘t1′, ‘delete' => ‘f1′

MEMSTORE_FLUSHSIZE, READONLY,和 DEFERRED_LOG_FLUSH：
hbase> alter ‘t1′, METHOD => ‘table_att', MAX_FILESIZE => '134217728′


hbase> alter ‘t1′, METHOD => ‘table_att', ‘coprocessor'=> ‘hdfs:///foo.jar|com.foo.FooRegionObserver|1001|arg1=1,arg2=2′

[coprocessor jar file location] | class name | [priority] | [arguments]

hbase> alter ‘t1′, METHOD => ‘table_att_unset', NAME => ‘MAX_FILESIZE'
hbase> alter ‘t1′, METHOD => ‘table_att_unset', NAME => ‘coprocessor$1′

hbase> alter ‘t1′, {NAME => ‘f1′}, {NAME => ‘f2′, METHOD => ‘delete'}

hbase> count ‘t1′
hbase> count ‘t1′, INTERVAL => 100000
hbase> count ‘t1′, CACHE => 1000
hbase> count ‘t1′, INTERVAL => 10, CACHE => 1000

describe 't1'

disable 'test1'


 alter 'test1',{NAME=>'body',TTL=>'15552000'},{NAME=>'meta', TTL=>'15552000'}

  enable 'test1'

  grant 'test','RW','t1'

   grant <user> <permissions> <table> <column family> <column qualifier>

   # 语法 : grant <user> <permissions> <table> <column family> <column qualifier> 参数后面用逗号分隔
   # 权限用五个字母表示： "RWXCA".
   # READ('R'), WRITE('W'), EXEC('X'), CREATE('C'), ADMIN('A')
   # 例如，给用户‘test'分配对表t1有读写的权限，
   hbase(main)> grant 'test','RW','t1'


   # 语法：user_permission <table>
   # 例如，查看表t1的权限列表
   hbase(main)> user_permission 't1'

   # 与分配权限类似，语法：revoke <user> <table> <column family> <column qualifier>
   # 例如，收回test用户在表t1上的权限
   hbase(main)> revoke 'test','t1'

   1）添加数据
   # 语法：put <table>,<rowkey>,<family:column>,<value>,<timestamp>
   # 例如：给表t1的添加一行记录：rowkey是rowkey001，family name：f1，column name：col1，value：value01，timestamp：系统默认
   hbase(main)> put 't1','rowkey001','f1:col1','value01'
   用法比较单一。

   # 语法：get <table>,<rowkey>,[<family:column>,....]
   # 例如：查询表t1，rowkey001中的f1下的col1的值
   hbase(main)> get 't1','rowkey001', 'f1:col1'
   # 或者：
   hbase(main)> get 't1','rowkey001', {COLUMN=>'f1:col1'}
   # 查询表t1，rowke002中的f1下的所有列值
   hbase(main)> get 't1','rowkey001'

   # 语法：scan <table>, {COLUMNS => [ <family:column>,.... ], LIMIT => num}
   # 另外，还可以添加STARTROW、TIMERANGE和FITLER等高级功能
   # 例如：扫描表t1的前5条数据,有两种方式：
   hbase(main)> scan 't1',{LIMIT=>5}

   hbase(main)> scan 't1', { COLUMNS => '列族', FILTER => org.apache.hadoop.hbase.filter.PageFilter.new(5)}

   d)  rowkey模糊查询

   #使用scan模糊查询rowkey以600034开头数据，两种方式

   hbase(main)> scan 't1',{ FILTER => "(PrefixFilter('600034')"}

   hbase(main)> scan 't1',{ STARTROW=> '600034'}


   #使用scan加FILTER

   hbase(main)> scan 't1',{FILTER => "(TimestampsFilter (1532039601011))"}

   hbase(main)>scan 't1', {COLUMNS => ['c1', 'c2'], LIMIT => 10, STARTROW => '052072986'}
   hbase(main)>scan 't1', {FILTER => "(PrefixFilter ('row2') AND (QualifierFilter (>=, 'binary:xyz'))) AND (TimestampsFilter ( 123, 456))"}

   hbase(main)>scan 't1', { COLUMNS =>[ 'c1','c2'], LIMIT => 2,STARTROW => '052072986'}

   hbase(main)>scan 't1', {FILTER => "(PrefixFilter ('00036')) AND (SingleColumnValueFilter ('列族','列名',>=,'binary:20141208'))"}

   hbase(main)>scan 't1', {FILTER => "(PrefixFilter ('00036')) AND (SingleColumnValueFilter ('列族','列名',>=,'binary:20141208')) AND (SingleColumnValueFilter ('列族','列名',<,'binary:20150101'))"}

   -----------------------------

   20170830182428

   1504088668000

   get 'packet','892ef1af-5e99-4ed5-9be0-7c8b457cb1c0_1504088668000_1';




scan 't1', {FILTER => "(PrefixFilter ('row2') AND (QualifierFilter (>=, 'binary:xyz'))) AND (TimestampsFilter ( 123, 456))"}


scan 'packet', {FILTER => "(PrefixFilter ('892ef1af-5e99-4ed5-9be0-7c8b457cb1c0')) AND (SingleColumnValueFilter ('cf','stime',>=,'binary:20170830182428'))"}









































