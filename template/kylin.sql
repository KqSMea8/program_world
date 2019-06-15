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

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `acl_class`
-- ----------------------------
DROP TABLE IF EXISTS `acl_class`;
CREATE TABLE `acl_class` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `class` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class` (`class`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `acl_sid`
-- ----------------------------
DROP TABLE IF EXISTS `acl_sid`;
CREATE TABLE `acl_sid` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `principal` tinyint(1) NOT NULL,
  `sid` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `acl_sid_idx_1` (`sid`,`principal`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;


-- ----------------------------
-- Table structure for `acl_object_identity`
-- ----------------------------
DROP TABLE IF EXISTS `acl_object_identity`;
CREATE TABLE `acl_object_identity` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `object_id_class` bigint(20) unsigned NOT NULL,
  `object_id_identity` varchar(64) NOT NULL,
  `parent_object` bigint(20) unsigned DEFAULT NULL,
  `owner_sid` bigint(20) unsigned DEFAULT NULL,
  `entries_inheriting` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `acl_object_identity_idx_1` (`object_id_class`,`object_id_identity`),
  KEY `parent_object` (`parent_object`),
  KEY `owner_sid` (`owner_sid`),
  CONSTRAINT `acl_object_identity_ibfk_1` FOREIGN KEY (`object_id_class`) REFERENCES `acl_class` (`id`),
  CONSTRAINT `acl_object_identity_ibfk_2` FOREIGN KEY (`parent_object`) REFERENCES `acl_object_identity` (`id`),
  CONSTRAINT `acl_object_identity_ibfk_3` FOREIGN KEY (`owner_sid`) REFERENCES `acl_sid` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `acl_entry`
-- ----------------------------
DROP TABLE IF EXISTS `acl_entry`;
CREATE TABLE `acl_entry` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `acl_object_identity` bigint(20) unsigned NOT NULL,
  `ace_order` int(10) unsigned NOT NULL,
  `sid` bigint(20) unsigned NOT NULL,
  `mask` int(11) NOT NULL,
  `granting` tinyint(1) NOT NULL,
  `audit_success` tinyint(1) NOT NULL,
  `audit_failure` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `acl_entry_idx_1` (`acl_object_identity`,`ace_order`),
  KEY `sid` (`sid`),
  CONSTRAINT `acl_entry_ibfk_1` FOREIGN KEY (`acl_object_identity`) REFERENCES `acl_object_identity` (`id`),
  CONSTRAINT `acl_entry_ibfk_2` FOREIGN KEY (`sid`) REFERENCES `acl_sid` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=228 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `users`
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `username` varchar(64) NOT NULL,
  `password` varchar(128) NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `groups`
-- ----------------------------
DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `group_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `authorities`
-- ----------------------------
DROP TABLE IF EXISTS `authorities`;
CREATE TABLE `authorities` (
  `username` varchar(255) NOT NULL,
  `authority` varchar(255) NOT NULL,
  UNIQUE KEY `authorities_idx_1` (`username`,`authority`),
  CONSTRAINT `authorities_ibfk_1` FOREIGN KEY (`username`) REFERENCES `users` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `group_authorities`
-- ----------------------------
DROP TABLE IF EXISTS `group_authorities`;
CREATE TABLE `group_authorities` (
  `group_id` bigint(20) unsigned NOT NULL,
  `authority` varchar(50) NOT NULL,
  KEY `group_id` (`group_id`),
  CONSTRAINT `group_authorities_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `group_members`
-- ----------------------------
DROP TABLE IF EXISTS `group_members`;
CREATE TABLE `group_members` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `group_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
--  KEY `group_id` (`group_id`),
  CONSTRAINT `group_members_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `queries`
-- ----------------------------
DROP TABLE IF EXISTS `queries`;
CREATE TABLE `queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `project` varchar(255) DEFAULT NULL,
  `sql_string` text NOT NULL,
  `creator` varchar(64) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `user_hits`
-- ----------------------------
DROP TABLE IF EXISTS `user_hits`;
CREATE TABLE `user_hits` (
  `username` varchar(64) NOT NULL,
  `hit_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SELECT

BUYER_ACCOUNT.ACCOUNT_ID, BUYER_ACCOUNT.ACCOUNT_CONTACT, count(*) as cnt, sum(price) as sum_price

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_ACCOUNT as BUYER_ACCOUNT
ON TEST_ORDER.BUYER_ID = BUYER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN TEST_COUNTRY as BUYER_COUNTRY
ON BUYER_ACCOUNT.ACCOUNT_COUNTRY = BUYER_COUNTRY.COUNTRY
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY

where BUYER_ACCOUNT.ACCOUNT_BUYER_LEVEL > 2 and SELLER_COUNTRY.NAME = 'France'
      and CAL_DT > '2013-01-01'
group by BUYER_ACCOUNT.ACCOUNT_ID, BUYER_ACCOUNT.ACCOUNT_CONTACTSELECT

count(*) as cnt, sum(price) as sum_price, SELLER_COUNTRY.NAME

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY

where SELLER_ACCOUNT.ACCOUNT_SELLER_LEVEL=1
group by SELLER_COUNTRY.NAMESELECT

count(*) as cnt, SELLER_COUNTRY.NAME

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY

group by SELLER_COUNTRY.NAMESELECT

count(*) as cnt

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_ACCOUNT as BUYER_ACCOUNT
ON TEST_ORDER.BUYER_ID = BUYER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN EDW.TEST_CAL_DT as TEST_CAL_DT
ON TEST_KYLIN_FACT.CAL_DT = TEST_CAL_DT.CAL_DT
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN EDW.TEST_SITES as TEST_SITES
ON TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_SITES.SITE_ID
INNER JOIN EDW.TEST_SELLER_TYPE_DIM as TEST_SELLER_TYPE_DIM
ON TEST_KYLIN_FACT.SLR_SEGMENT_CD = TEST_SELLER_TYPE_DIM.SELLER_TYPE_CD
INNER JOIN TEST_COUNTRY as BUYER_COUNTRY
ON BUYER_ACCOUNT.ACCOUNT_COUNTRY = BUYER_COUNTRY.COUNTRY
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY
SELECT

LSTG_FORMAT_NAME, count(*) as cnt, sum(price) as sum_price

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_ACCOUNT as BUYER_ACCOUNT
ON TEST_ORDER.BUYER_ID = BUYER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN TEST_COUNTRY as BUYER_COUNTRY
ON BUYER_ACCOUNT.ACCOUNT_COUNTRY = BUYER_COUNTRY.COUNTRY
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY

where BUYER_COUNTRY.NAME='China' and SELLER_COUNTRY.NAME='Japan'
group by LSTG_FORMAT_NAMESELECT

count(*) as cnt

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_ACCOUNT as BUYER_ACCOUNT
ON TEST_ORDER.BUYER_ID = BUYER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN TEST_COUNTRY as BUYER_COUNTRY
ON BUYER_ACCOUNT.ACCOUNT_COUNTRY = BUYER_COUNTRY.COUNTRY
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY

where BUYER_ACCOUNT.ACCOUNT_COUNTRY='CN'--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 , count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 , count(distinct site_name) as site_count
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 , count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 , count(distinct site_name) as site_count
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt
 having count(distinct seller_id) > 2--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.QTR_BEG_DT,sum(test_kylin_fact.price) as gmv
 , count(*) as trans_cnt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between '2013-05-01' and '2013-08-01'
 group by test_cal_dt.QTR_BEG_DT
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt, sum(price)as GMV, count(1) as trans_cnt from test_kylin_fact
 group by cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select seller_id,cal_dt,lstg_format_name,sum(price) from test_kylin_fact group by seller_id,cal_dt,lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select seller_id,lstg_format_name from test_kylin_fact limit 1200
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT sum(price)
FROM test_kylin_fact
WHERE CAL_DT >= '2012-02-16' and CAL_DT <= '2012-03-16' and LEAF_CATEG_ID in
(
  SELECT DISTINCT LEAF_CATEG_ID
  FROM TEST_CATEGORY_GROUPINGS
  WHERE META_CATEG_NAME is not null
) limit 10
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_kylin_fact.cal_dt , sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002 + 4

 group by  seller_id,test_kylin_fact.cal_dt
 limit 10
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select seller_id,CAL_DT,sum(price) from test_kylin_fact
  group by seller_id,CAL_DT limit 20

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select
    *
from test_kylin_fact
    left join TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
    ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
where lstg_format_name='FP-GTC'
limit 20
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) from test_kylin_fact
  where CAL_DT >= '2012-02-16' and CAL_DT <= '2012-03-16'
  limit 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select * from (
select * from test_kylin_fact
  where lstg_format_name is not null
  ) limit 20

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_KYLIN_FACT"."CAL_DT", SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok" FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
  INNER JOIN (
             SELECT COUNT(1) AS "XTableau_join_flag",     SUM("TEST_KYLIN_FACT"."PRICE") AS "X__alias__A",     "TEST_KYLIN_FACT"."CAL_DT" AS "none_CAL_DT_ok"   FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
             GROUP BY "TEST_KYLIN_FACT"."CAL_DT"   ORDER BY 2 DESC   LIMIT 7  )

    "t0" ON ("TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok") GROUP BY "TEST_KYLIN_FACT"."CAL_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select fact.cal_dt, sum(fact.price) as sum_price, count(1) as cnt_1
from test_kylin_fact fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON fact.lstg_site_id = test_sites.site_id
inner join
(
	select test_kylin_fact.cal_dt, sum(test_kylin_fact.price) from test_kylin_fact  left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id group by test_kylin_fact.cal_dt order by 2 desc limit 7
) cal_2 on fact.cal_dt = cal_2.cal_dt
group by fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT t1.week_beg_dt, t1.sum_price, t2.cnt
FROM (
  select test_cal_dt.week_beg_dt, sum(price) as sum_price
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id
  group by test_cal_dt.week_beg_dt
) t1
inner join  (
  select test_cal_dt.week_beg_dt, count(*) as cnt
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id
  group by test_cal_dt.week_beg_dt
) t2
on t1.week_beg_dt=t2.week_beg_dt
order by t1.week_beg_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


SELECT t1.week_beg_dt, t1.sum_price,t1.lstg_site_id
FROM (
  select test_cal_dt.week_beg_dt, sum(price) as sum_price, lstg_site_id
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id
  group by test_cal_dt.week_beg_dt, lstg_site_id
) t1
inner JOIN edw.test_cal_dt as test_cal_dt
on t1.week_beg_dt=test_cal_dt.week_beg_dt
 inner JOIN edw.test_sites as test_sites

  on t1.lstg_site_id = test_sites.site_id

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT CAST(SUM("COUNT") as BIGINT) as TOTAL_COUNT
FROM (
	SELECT LSTG_FORMAT_NAME, COUNT(*) AS "COUNT"
	FROM TEST_KYLIN_FACT
	GROUP BY LSTG_FORMAT_NAME
	ORDER BY "COUNT" DESC
) A
select
    f.cal_dt
from test_kylin_fact f
where
    f.cal_dt not in (
        select cal_dt from EDW.TEST_CAL_DT where week_beg_dt = date'2012-01-01'
    )
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, sum(test_kylin_fact.price)  as sum_price, count(1) as cnt_1
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT t1.week_beg_dt, t1.sum_price, t2.cnt
FROM (
  select test_cal_dt.week_beg_dt, sum(price) as sum_price
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id
  group by test_cal_dt.week_beg_dt
) t1
inner join  (
  select test_cal_dt.week_beg_dt, count(*) as cnt
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id
  group by test_cal_dt.week_beg_dt
) t2
on t1.week_beg_dt=t2.week_beg_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
  week_beg_dt
  ,sum(price) as sum_price
FROM
(
  select
    test_cal_dt.week_beg_dt
    ,test_kylin_fact.price
  from test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
      ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
      ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
    inner JOIN edw.test_sites as test_sites
      ON test_kylin_fact.lstg_site_id = test_sites.site_id
) t
group by week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


  select  (case when '1'='1' then test_cal_dt.week_beg_dt when '1'='2' then test_kylin_fact.lstg_site_id else test_kylin_fact.leaf_categ_id end) as xxx , sum(price) as sum_price
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id

  where case when '1'='1' then test_kylin_fact.cal_dt < date'2012-04-01' when '1'='2' then  test_cal_dt.week_beg_dt > date'2012-04-01' else  test_kylin_fact.lstg_site_id is not null end and lstg_format_name='FP-GTC'

  group by case when '1'='1' then test_cal_dt.week_beg_dt when '1'='2' then test_kylin_fact.lstg_site_id else test_kylin_fact.leaf_categ_id end

select
    lstg_format_name,
    sum(price) as gvm
from
    (
        select
            cal_dt,
            lstg_format_name,
            price
        from test_kylin_fact
            inner JOIN test_category_groupings
            ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
            inner JOIN edw.test_sites as test_sites
            ON test_kylin_fact.lstg_site_id = test_sites.site_id
        where
            lstg_site_id = 0
            and cal_dt > '2013-05-13'
    ) f
where
    lstg_format_name ='Auction'
group by
    lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2012-04-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt



inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2013-01-01'  ) xxx2
ON test_kylin_fact.cal_dt = xxx2.cal_dt





  where test_category_groupings.meta_categ_name <> 'Baby'

 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt, sum(price) as sum_price
from test_kylin_fact fact
inner join (
select count(1) as cnt, min(cal_dt) as "mmm",  cal_dt as dt from test_kylin_fact group by cal_dt order by 2 desc limit 10
) t0 on (fact.cal_dt = t0.dt)
group by cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

-- inner JOIN test_category_groupings
-- ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id

 inner JOIN (select leaf_categ_id, site_id,meta_categ_name from test_category_groupings ) yyy
 ON test_kylin_fact.leaf_categ_id = yyy.leaf_categ_id AND test_kylin_fact.lstg_site_id = yyy.site_id


 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2010-02-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt


 where yyy.meta_categ_name > ''
 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name, xxx.week_beg_dt , sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2010-02-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt


 where test_category_groupings.meta_categ_name  <> 'Baby'
 group by test_kylin_fact.lstg_format_name, xxx.week_beg_dt


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


  select  (case when '3'='1' then test_cal_dt.week_beg_dt else   test_kylin_fact.cal_dt  end) as xxx ,  sum(price) as sum_price
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id

  where case when '3'='1' then test_kylin_fact.cal_dt < date'2012-04-01' else  test_cal_dt.week_beg_dt  > date'2012-04-01' end and lstg_format_name='FP-GTC'

  group by case when '3'='1' then test_cal_dt.week_beg_dt  else   test_kylin_fact.cal_dt end

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select t1.leaf_categ_id, max_price, min_price, sum_price
from
(select leaf_categ_id, sum(price) as sum_price from test_kylin_fact group by leaf_categ_id) t1
join
(select leaf_categ_id, max(price) as max_price from test_kylin_fact group by leaf_categ_id) t2
on t1.leaf_categ_id = t2.leaf_categ_id
join
(select leaf_categ_id, min(price) as min_price from test_kylin_fact group by leaf_categ_id) t3
on t1.leaf_categ_id = t3.leaf_categ_id
order by t1.leaf_categ_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2012-04-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt


 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id

inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2013-01-01'  ) xxx2
ON test_kylin_fact.cal_dt = xxx2.cal_dt

 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

    where test_category_groupings.meta_categ_name <> 'Baby' and test_sites.site_name <> 'France'

 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2010-02-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt


 where test_category_groupings.meta_categ_name  <> 'Baby'
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2012-04-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


  where test_category_groupings.meta_categ_name <> 'Baby'

 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2010-02-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


 where test_category_groupings.meta_categ_name  <> 'Baby'
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
    t1.leaf_categ_id, COUNT(*) AS nums
FROM
    (SELECT
        f.leaf_categ_id
    FROM
        test_kylin_fact f inner join TEST_CATEGORY_GROUPINGS o on f.leaf_categ_id = o.leaf_categ_id and f.LSTG_SITE_ID = o.site_id
    WHERE
        f.lstg_format_name = 'ABIN') t1
    INNER JOIN
    (SELECT
        leaf_categ_id
    FROM
        test_kylin_fact f
    INNER JOIN test_order o ON f.order_id = o.order_id
    WHERE
        buyer_id > 100) t2 ON t1.leaf_categ_id = t2.leaf_categ_id
GROUP BY t1.leaf_categ_id
ORDER BY nums, leaf_categ_id
limit 100--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


  select    lstg_format_name,(case when '2'='1' then test_kylin_fact.lstg_site_id  when '2'='2' then test_cal_dt.week_beg_dt else test_kylin_fact.leaf_categ_id end) as xxx ,sum(price) as sum_price
  from test_kylin_fact
  inner JOIN edw.test_cal_dt as test_cal_dt
  ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
  inner JOIN test_category_groupings
  ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
  inner JOIN edw.test_sites as test_sites
  ON test_kylin_fact.lstg_site_id = test_sites.site_id

  where case  when '2'='1' then  test_cal_dt.week_beg_dt > date'2012-04-01' when '2'='2' then test_kylin_fact.cal_dt < date'2012-04-01' else  test_kylin_fact.lstg_site_id is not null end

  group by case  when '2'='1' then test_kylin_fact.lstg_site_id  when '2'='2' then test_cal_dt.week_beg_dt else test_kylin_fact.leaf_categ_id end,lstg_format_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_category_groupings.meta_categ_name,
sum(price) as sum_price
from test_kylin_fact as test_kylin_fact
inner join  (select leaf_categ_id,site_id,meta_categ_name from test_category_groupings ) as test_category_groupings
on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
test_kylin_fact.lstg_site_id = test_category_groupings.site_id
group by test_category_groupings.meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


SELECT t1.cal_dt, t1.sum_price,t1.lstg_site_id
FROM (
  select cal_dt, lstg_site_id, sum(price) as sum_price
  from test_kylin_fact
  group by cal_dt, lstg_site_id

) t1

inner JOIN edw.test_cal_dt as test_cal_dt
on t1.cal_dt=test_cal_dt.cal_dt

inner JOIN edw.test_sites as test_sites
on t1.lstg_site_id = test_sites.site_id

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


SELECT "TEST_KYLIN_FACT"."CAL_DT", SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok" FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
   RIGHT JOIN (
             SELECT COUNT(1) AS "XTableau_join_flag",     SUM("TEST_KYLIN_FACT"."PRICE") AS "X__alias__A",     "TEST_KYLIN_FACT"."CAL_DT"  AS "none_CAL_DT_ok"   FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
             GROUP BY "TEST_KYLIN_FACT"."CAL_DT"   ORDER BY 2 DESC   LIMIT 7  )
    "t0" ON
    CASE WHEN 1 = 1
    THEN  ("TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok")
    ELSE "TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok"
    END
    GROUP BY "TEST_KYLIN_FACT"."CAL_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
    week_beg_dt
FROM
    edw.test_cal_dt t1
WHERE
    t1.cal_dt IN (SELECT
            cal_dt
        FROM
            test_kylin_fact
        WHERE
            lstg_format_name = 'ABIN')--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT sum(sum_price) AS "COL"
 FROM (
 select test_cal_dt.week_beg_dt, sum(test_kylin_fact.price) as sum_price, count(1) as cnt_1
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
 ) "TableauSQL"
 HAVING COUNT(1)>0
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2012-04-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id

 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

   where test_category_groupings.meta_categ_name <> 'Baby' and test_sites.site_name <> 'France'

 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2012-04-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt


 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2013-01-01'  ) xxx2
ON test_kylin_fact.cal_dt = xxx2.cal_dt



  where test_category_groupings.meta_categ_name <> 'Baby'

 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2012-04-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt

inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2013-01-01'  ) xxx2
ON test_kylin_fact.cal_dt = xxx2.cal_dt

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id

 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

   where test_category_groupings.meta_categ_name <> 'Baby' and test_sites.site_name <> 'France'

 group by test_kylin_fact.lstg_format_name


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT count(1) cnt
 FROM (
 select LSTG_FORMAT_NAME, sum(test_kylin_fact.price) as sum_price, count(1) as cnt_1
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by LSTG_FORMAT_NAME
 )
 limit 1

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
  f.lstg_format_name
  ,sum(price) as sum_price
FROM
  test_kylin_fact f
  inner join
  (
    select
      lstg_format_name,
      min(slr_segment_cd) as min_seg
    from
      test_kylin_fact
    group by
      lstg_format_name
  ) t on f.lstg_format_name = t.lstg_format_name
where
  f.slr_segment_cd = min_seg
group by
  f.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--




select test_kylin_fact.lstg_format_name, xxx.week_beg_dt,xxx.cal_dt, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from

 test_kylin_fact

 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id


 inner JOIN (select cal_dt,week_beg_dt from edw.test_cal_dt  where week_beg_dt >= DATE '2010-02-10'  ) xxx
 ON test_kylin_fact.cal_dt = xxx.cal_dt


 where test_category_groupings.meta_categ_name  <> 'Baby'
 group by test_kylin_fact.lstg_format_name, xxx.week_beg_dt , xxx.cal_dt


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT  SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
	FROM "TEST_KYLIN_FACT"
    INNER JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
     inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

    INNER JOIN (
     SELECT COUNT(1) AS "XTableau_join_flag",
      SUM("TEST_KYLIN_FACT"."PRICE") AS "X__alias__A",
       "TEST_KYLIN_FACT"."CAL_DT" AS "none_CAL_DT_ok"   FROM "TEST_KYLIN_FACT"
         INNER JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
          inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
     GROUP BY "TEST_KYLIN_FACT"."CAL_DT"   ORDER BY 2 DESC   LIMIT 10  ) "t0" ON ("TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok")
    GROUP BY "TEST_KYLIN_FACT"."CAL_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select fact.cal_dt, sum(fact.price) as sum_price, count(1) as cnt_1
from test_kylin_fact fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON fact.lstg_site_id = test_sites.site_id
inner join
(
	select test_kylin_fact.cal_dt, max(test_kylin_fact.cal_dt) as mmm from test_kylin_fact  left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id group by test_kylin_fact.cal_dt order by 2 desc limit 7
) cal_2 on fact.cal_dt = cal_2.mmm
group by fact.cal_dt
select max(cal_dt) as x from edw.test_cal_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from edw.test_cal_dt as test_cal_dt where extract(YEAR from test_cal_dt.cal_dt) = 2012
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select SELLER_TYPE_DESC, SELLER_TYPE_CD from edw.test_seller_type_dim
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select CATEG_LVL3_NAME, CATEG_LVL2_NAME, SITE_ID, META_CATEG_NAME, LEAF_CATEG_ID  from test_category_groupings
select site_id,count(*) as y,count(DISTINCT site_name) as x from edw.test_sites group by site_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as CNT  from test_category_groupings
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as CNT  from edw.test_seller_type_dim
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select CAL_DT, WEEK_BEG_DT from edw.test_cal_dt





--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as CNT from edw.test_cal_dt





--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(distinct META_CATEG_NAME) as CNT ,max(META_CATEG_NAME) as y from test_category_groupings
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select SITE_NAME, SITE_ID from edw.test_sites
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as CNT from edw.test_sites
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT distinct cal_dt from test_kylin_fact

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT distinct LSTG_FORMAT_NAME from test_kylin_fact


--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select distinct leaf_categ_id, site_id from test_category_groupings
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name, sum(test_kylin_fact.price) as gmv, count(*) as trans_cnt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 where test_cal_dt.week_beg_dt is not null
 group by test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_kylin_fact.seller_id
 ,test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_sites.site_id
 ,test_sites.cre_user
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002 and test_sites.site_id=0
 group by
 test_kylin_fact.seller_id
 ,test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_sites.site_id
 ,test_sites.cre_user
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt, lstg_format_name, sum(price) as GMV
 from test_kylin_fact
 where cal_dt=date '2013-05-06'
 group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.upd_user
 ,test_category_groupings.upd_date
 ,test_kylin_fact.leaf_categ_id
 ,test_category_groupings.leaf_categ_id
 ,test_kylin_fact.lstg_site_id
 ,test_category_groupings.site_id
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 where
 test_category_groupings.upd_date='2012-09-11 20:26:04'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.upd_user
 ,test_category_groupings.upd_date
 ,test_kylin_fact.leaf_categ_id
 ,test_category_groupings.leaf_categ_id
 ,test_kylin_fact.lstg_site_id
 ,test_category_groupings.site_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name, sum(test_kylin_fact.price) as gmv, count(*) as trans_cnt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-10-01'
 group by test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_kylin_fact.seller_id
 ,test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_sites.site_id
 ,test_sites.cre_user
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002
 group by
 test_kylin_fact.seller_id
 ,test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_sites.site_id
 ,test_sites.cre_user
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select UPD_USER,count(1) as CNT
from TEST_KYLIN_FACT  as TEST_KYLIN_FACT
inner join TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
where UPD_USER not in ('USER_Y')
group by UPD_USER--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_sites.site_name, test_kylin_fact.lstg_format_name, sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY
 test_sites.site_name, test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT site_id, site_name, cre_user from edw.test_sites

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT "TEST_KYLIN_FACT"."CAL_DT", SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok" FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
   RIGHT JOIN (
             SELECT COUNT(1) AS "XTableau_join_flag",     SUM("TEST_KYLIN_FACT"."PRICE") AS "X__alias__A",     "TEST_KYLIN_FACT"."CAL_DT"  AS "none_CAL_DT_ok"   FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
             GROUP BY 3   ORDER BY 2 DESC   LIMIT 7  )
    "t0" ON
    CASE WHEN 1 = 1
    THEN  ("TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok")
    ELSE "TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok"
    END
    GROUP BY 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select LSTG_FORMAT_NAME, (case
    when USER_DEFINED_FIELD1 < 0 then 0
    when USER_DEFINED_FIELD1 < 10 then 1
    else 3
    end),
    sum(price)
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
WHERE SLR_SEGMENT_CD < 16 and USER_DEFINED_FIELD1 is not null
group by 1, 2
order by 1, 2--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
  count(*) as TRANS_CNT ,
  count(DISTINCT test_kylin_fact.SELLER_ID)
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where massin(test_kylin_fact.SELLER_ID,'vip_customers')  and test_kylin_fact.cal_dt > date'2010-01-01'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
  count(*) as TRANS_CNT ,
  count(DISTINCT test_kylin_fact.SELLER_ID)
  ,test_kylin_fact.cal_dt
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where massin(test_kylin_fact.SELLER_ID,'vip_customers')  and test_kylin_fact.cal_dt > date'2010-01-01'
 group by test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
  count(*) as TRANS_CNT ,
  count(DISTINCT test_kylin_fact.SELLER_ID)
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where massin(test_kylin_fact.SELLER_ID,'vip_customers')
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) from (select test_cal_dt.week_beg_dt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 group by test_cal_dt.week_beg_dt) t
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) from ( select test_kylin_fact.lstg_format_name from test_kylin_fact
 where test_kylin_fact.lstg_format_name='FP-GTC'
 group by test_kylin_fact.lstg_format_name ) t
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from streaming_table where minute_start >= {TS '2015-01-02 20:00:00'}  --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c ,hour_start AS h from streaming_table group by hour_start--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from streaming_table where minute_start >= {TS '2015-01-02 20:30:00'}--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select minute_start, streaming_category.name as category, count(*) as c,sum(gmv) as g, cast(sum(item_count) as BIGINT) AS i from streaming_table inner join streaming_category on streaming_table.category_id = streaming_category.category_id group by minute_start, streaming_category.name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from streaming_table where minute_start < {TS '2015-01-02 21:00:00'} and minute_start > {TS '2015-01-02 20:00:00'}--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) AS c ,cast(sum(item_count) as BIGINT) as i from streaming_table group by site,day_start--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select streaming_category.region, day_start, count(*) AS c, cast(sum(item_count) as BIGINT) as i from streaming_table inner join streaming_category on streaming_table.category_id = streaming_category.category_id group by streaming_category.region, day_start--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from streaming_table where minute_start < {TS '2015-01-02 21:00:00'}--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from streaming_table where minute_start >= {TS '2015-01-01 20:30:00'}--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) AS c from streaming_table inner join streaming_category on streaming_table.category_id = streaming_category.category_id--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) AS c from streaming_table--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) AS c from streaming_table inner join streaming_category on streaming_table.category_id = streaming_category.category_id where minute_start < {TS '2015-01-02 21:00:00'} and minute_start > {TS '2015-01-02 20:00:00'}--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c from streaming_table where day_start >= DATE'2015-01-02'--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as c,sum(gmv) as g,cast(sum(item_count) as BIGINT) AS i from streaming_table group by minute_start--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select
  l.cal_dt
  , sum(left_join_gvm) as left_join_sum
  , sum(inner_join_gvm) as inner_join_sum
from
  (
    select test_kylin_fact.cal_dt, sum(price) as left_join_gvm

     from test_kylin_fact
     left JOIN edw.test_cal_dt as test_cal_dt
     ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
     left JOIN test_category_groupings
     ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id

    group by test_kylin_fact.cal_dt
  ) l
  inner join
  (
    select test_kylin_fact.cal_dt, sum(price) as inner_join_gvm

     from test_kylin_fact
     inner JOIN edw.test_cal_dt as test_cal_dt
     ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
     inner JOIN test_category_groupings
     ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id

    group by test_kylin_fact.cal_dt
  ) i
  on l.cal_dt = i.cal_dt
group by
  l.cal_dt
-- join condition cast type
select sum(ITEM_COUNT) as ITEM_CNT
FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_ACCOUNT as BUYER_ACCOUNT
ON TEST_ORDER.BUYER_ID = BUYER_ACCOUNT.ACCOUNT_ID
INNER JOIN TEST_ACCOUNT as SELLER_ACCOUNT
ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
INNER JOIN EDW.TEST_CAL_DT as TEST_CAL_DT
ON TEST_KYLIN_FACT.CAL_DT = TEST_CAL_DT.CAL_DT
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
INNER JOIN EDW.TEST_SITES as TEST_SITES
ON TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_SITES.SITE_ID
INNER JOIN EDW.TEST_SELLER_TYPE_DIM as TEST_SELLER_TYPE_DIM
ON TEST_KYLIN_FACT.SLR_SEGMENT_CD = TEST_SELLER_TYPE_DIM.SELLER_TYPE_CD
INNER JOIN TEST_COUNTRY as BUYER_COUNTRY
ON BUYER_ACCOUNT.ACCOUNT_COUNTRY = BUYER_COUNTRY.COUNTRY
INNER JOIN TEST_COUNTRY as SELLER_COUNTRY
ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRYSELECT ORDER_ID
FROM test_kylin_fact
GROUP BY CAST(CASE
		WHEN '1030101' = '1030101' THEN substring(COALESCE(LSTG_FORMAT_NAME, '888888888888'), 1, 1)
		WHEN '1030101' = '1030102' THEN substring(COALESCE(LSTG_FORMAT_NAME, '999999999999'), 1, 1)
		WHEN '1030101' = '1030103' THEN substring(COALESCE(LSTG_FORMAT_NAME, '777777777777'), 1, 1)
		WHEN '1030101' = '1030104' THEN substring(COALESCE(LSTG_FORMAT_NAME, '666666666666'), 1, 1)
	END AS varchar(256)), ORDER_ID--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT , sum(test_kylin_fact.item_count) as total_items
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where  1 < 3
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
 where test_kylin_fact.lstg_format_name is not null
 group by test_kylin_fact.lstg_format_name
 having sum(price)>5000 or count(*)>20
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt as bb , sum(price) as aa from test_kylin_fact fact
inner join (


select count(1) as cnt, min(cal_dt) as "mmm",  cal_dt as dt from test_kylin_fact group by cal_dt order by 2 desc limit 10


) t0 on (fact.cal_dt = t0.dt) group by cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.cal_dt, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where
 extract(DAY from test_cal_dt.cal_dt) = 12
 group by test_cal_dt.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,sum(test_kylin_fact.price) as GMV
 ,count(*) as trans_cnt
 FROM test_kylin_fact
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by
 test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.cal_dt,test_kylin_fact.seller_id, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
from test_kylin_fact
where DATE '2012-09-01' <= test_kylin_fact.cal_dt   and  test_kylin_fact.seller_id = 10000002
 group by test_kylin_fact.cal_dt,
test_kylin_fact.seller_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(*) as TRANS_CNT from test_kylin_fact
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(1) as cnt_1
from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
group by test_kylin_fact.cal_dt
order by 1 desc
limit 4
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV , min(cal_dt) as min_cal_dt
 , count(*) as TRANS_CNT from test_kylin_fact
 group by test_kylin_fact.lstg_format_name having sum(price)>5000 and count(*)>72
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

 select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV , min(cal_dt) as min_cal_dt
 , count(*) as TRANS_CNT from test_kylin_fact
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select count(*) as x

FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id



where ( META_CATEG_NAME IN ('jenny','esrzongguan','Baby')

  AND ( META_CATEG_NAME IN
         ('non_existing_dict_value1', 'Baby', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
               'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
               'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
               ) OR
         META_CATEG_NAME IN
           ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                        'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                        'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                        )  OR
         META_CATEG_NAME IN
           ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                        'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                        'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                        )  OR
         META_CATEG_NAME IN
            ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                         'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                         'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                         )  OR

                META_CATEG_NAME IN
            ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                         'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                         'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                         )  OR
         'administrators' IN
           ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                       'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                       'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1'
                       ))

                       and

        ( META_CATEG_NAME IN
                 ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                       'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                       'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                       ) OR
                 META_CATEG_NAME IN
                   ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                )  OR
                 META_CATEG_NAME IN
                   ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                )  OR
                 META_CATEG_NAME IN
                    ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                 )  OR

                        META_CATEG_NAME IN
                    ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                 )  OR
                 'administrators' IN
                   ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                               'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                               'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1'
                               ))



                       )
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GVM,lstg_format_name from test_kylin_fact group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, sum(price) as GMV
 from test_kylin_fact
 where test_kylin_fact.seller_id in ( 10000002, 10000003, 10000004,10000005,10000006,10000008,10000009,10000001,10000010,10000011)
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_sites.site_name = '英国'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select min(cal_dt) as min_cal_dt, max(cal_dt) as max_cal_dt from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select max(cal_dt) as cnt from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where meta_categ_name not in ('Unknown')
 group by meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.cal_dt, count(*) as CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.lstg_format_name='XXXUnknown'
 group by test_cal_dt.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT , sum(test_kylin_fact.item_count) as total_items
 from test_kylin_fact
 where "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" = 'Auction' and (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" IN ('Auction', 'FP-GTC')) THEN 'Auction' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END) = 'Auction'
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select min(cal_dt) as min_cal_dt
 from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GMV
 from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- greater than non-exist and super big value 'ZZZZ'
select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(*) as TRANS_CNT from test_kylin_fact
where test_kylin_fact.lstg_format_name > 'ZZZZ'
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_category_groupings.meta_categ_name
 ,sum(test_kylin_fact.price) as GMV_SUM
 ,max(test_kylin_fact.price) as GMV_MAX
 ,min(test_kylin_fact.price) as GMV_MIN
 ,count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002 or test_kylin_fact.lstg_format_name = 'FP-non GTC'
 group by
 test_category_groupings.meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as cnt from test_kylin_fact
where lstg_format_name>='AAAA' and 'BBBB'>=lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(PRICE) as GMV, LSTG_FORMAT_NAME as FORMAT_NAME
from test_kylin_fact
where (LSTG_FORMAT_NAME in ('ABIN')) or  (LSTG_FORMAT_NAME>='FP-GTC' and LSTG_FORMAT_NAME<='Others')
group by LSTG_FORMAT_NAME
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, sum(price) as GMV
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select min("t"."s") as min_x, max("t"."s") as max_x from (select max(price) as "s" from test_kylin_fact group by lstg_format_name) "t" having ( count(1)  > 0)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where not ( meta_categ_name not in ('', 'a','Computers') and meta_categ_name not in ('Crafts','Computers'))
 group by meta_categ_name --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--




  select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(price) as GMV_CNT
 from test_kylin_fact where test_kylin_fact.lstg_format_name > 'AB'
 group by test_kylin_fact.lstg_format_name having count(price) > 2
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
 where not (test_kylin_fact.lstg_format_name='FP-GTC')
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.lstg_format_name='FP-GTC'  or extract(MONTH from test_cal_dt.week_beg_dt) = 12
 group by test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GMV, count(1) as TRANS_CNT from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt, lstg_format_name, sum(price) as GMV , sum(test_kylin_fact.item_count) as total_items
 from test_kylin_fact
 where cal_dt between date '2013-05-06' and date '2013-07-31'
 group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where not ( meta_categ_name not in ('', 'a','Computers') )
 group by meta_categ_name --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as trans_cnt
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id < 9 -- row keys are represented as string in kylin, make sure 10000002 is not < 9
  or test_kylin_fact.seller_id > 10000003
 group by
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT (CASE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" WHEN 'Auction' THEN '111' ELSE '222' END) AS "LSTG_FORMAT_NAME__group_",
  SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
group by (CASE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" WHEN 'Auction' THEN '111' ELSE '222' END)  ORDER BY 1 ASC
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
 where test_kylin_fact.lstg_format_name='FP-GTC'
 group by test_kylin_fact.lstg_format_name having sum(price)>5000 or count(*)>20
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- greater than non-exist value 'GGGG'
select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(*) as TRANS_CNT from test_kylin_fact
where test_kylin_fact.lstg_format_name > 'GGGG'
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-09-01' and DATE '2013-10-01'
 and test_category_groupings.categ_lvl2_name='Comics'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where
 extract(MONTH from test_cal_dt.week_beg_dt) = 12
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
 select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 from test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 left JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 and test_kylin_fact.cal_dt between DATE '2013-06-01' and DATE '2013-09-01'
 group by test_cal_dt.week_beg_dt --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,sum(price) as GMV, count(*) as TRANS_CNT , sum(test_kylin_fact.item_count) as total_items
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-09-01' and DATE '2013-10-01'
 and test_category_groupings.categ_lvl3_name='Other'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where
 (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.categ_lvl3_name='Dresses')
 and test_sites.site_name='Ebay'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002
 group by
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.cal_dt, sum(test_kylin_fact.price) as sum_price, count(1) as cnt_1, sum(test_kylin_fact.item_count) as total_items
from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
group by test_kylin_fact.cal_dt
order by 2 desc
limit 3
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT , sum(test_kylin_fact.item_count) as total_items
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-02-01' and DATE '2013-10-01'
 and site_name='Ebay'
 and test_category_groupings.categ_lvl3_name='Other'
 and test_kylin_fact.lstg_format_name='Auction'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-09-01' and DATE '2013-10-01'
 and test_category_groupings.meta_categ_name='Collectibles'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_kylin_fact.seller_id
 ,test_category_groupings.meta_categ_name
 ,test_kylin_fact.lstg_format_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.lstg_site_id = test_category_groupings.site_id  AND test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 where test_category_groupings.meta_categ_name='Collectibles'
 group by  test_kylin_fact.seller_id
 ,test_category_groupings.meta_categ_name
 ,test_kylin_fact.lstg_format_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select  sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where
 (test_kylin_fact.lstg_format_name='FP-GTC')  and extract(MONTH from test_cal_dt.week_beg_dt) = 12
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where  DATE '2013-03-24'  <= test_cal_dt.week_beg_dt
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where 1 <> 1
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
 select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 from test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 left JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 and test_cal_dt.cal_dt between DATE '2013-06-01' and DATE '2013-09-01'
 group by test_cal_dt.week_beg_dt --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.cal_dt, count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT
 from test_kylin_fact
 where (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" IN ('Auction', 'FP-GTC')) THEN 'Auction' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END) = 'Auction'
 group by lstg_format_name
 order by sum(price)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--




  select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(price) as GMV_CNT
 from test_kylin_fact where test_kylin_fact.lstg_format_name <= 'ABZ'
 group by test_kylin_fact.lstg_format_name having count(price) > 2
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select upper(lstg_format_name) as lstg_format_name, count(*) as cnt from test_kylin_fact
where lower(lstg_format_name)='abin' and substring(lstg_format_name,1,3) in ('ABI') and upper(lstg_format_name) > 'AAAA' and
lower(lstg_format_name) like '%b%' and char_length(lstg_format_name) < 10 and char_length(lstg_format_name) > 3 and 'abc'||lstg_format_name||'a'||'b'||'c'='abcABINabc'
group by lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select min("t"."s") as min_pr from (select max(price) as "s" from test_kylin_fact group by lstg_format_name) "t"  having (count(1) > 0)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GMV, count(*) as TRANS_CNT  FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
where test_kylin_fact.cal_dt < DATE '2012-05-01' or test_kylin_fact.cal_dt > DATE '2013-05-01'

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-09-01' and DATE '2013-10-01'
 and test_category_groupings.meta_categ_name='Collectibles'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT
 from test_kylin_fact
 where "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" in ('Auction', 'ABIN') and (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" IN ('Auction', 'FP-GTC')) THEN 'Auction' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END) = 'Auction'
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.week_beg_dt between DATE '2013-01-01' and DATE '2013-06-04'
 and (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.meta_categ_name='Clothing, Shoes & Accessories') and
 test_category_groupings.categ_lvl3_name <>'Other' and test_sites.site_name='Ebay'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT COUNT(test_kylin_fact.price) AS GMV_CNT
FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
WHERE test_cal_dt.WEEK_BEG_DT >= '2001-09-09'
 AND test_cal_dt.WEEK_BEG_DT <= '2018-05-16'
 --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, sum(price) as GMV
 from test_kylin_fact
 where (NOT ((CASE WHEN (lstg_format_name IS NULL) THEN 1 WHEN NOT (lstg_format_name IS NULL) THEN 0 ELSE NULL END) <> 0))
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- equals to non-exist value 'GGGG'
select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(*) as TRANS_CNT from test_kylin_fact
where test_kylin_fact.lstg_format_name = 'GGGG'
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as x

FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id



where ( META_CATEG_NAME IN ('jenny','esrzongguan','Baby')

  AND ( META_CATEG_NAME IN
         ('non_existing_dict_value1', 'Baby', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
               'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
               'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
               ) OR
         META_CATEG_NAME IN
           ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                        'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                        'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                        )  OR
         META_CATEG_NAME IN
           ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                        'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                        'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                        )  OR
         META_CATEG_NAME IN
            ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                         'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                         'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                         )  OR

                META_CATEG_NAME IN
            ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                         'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                         'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                         )  OR
         'administrators' IN
           ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                       'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                       'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1'
                       ))

                       and

        ( META_CATEG_NAME IN
                 ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                       'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                       'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                       ) OR
                 META_CATEG_NAME IN
                   ('non_existing_dict_value1', 'Baby', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                )  OR
                 META_CATEG_NAME IN
                   ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                )  OR
                 META_CATEG_NAME IN
                    ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                 )  OR

                        META_CATEG_NAME IN
                    ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                                 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2', 'non_existing_dict_value2',
                                 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3', 'non_existing_dict_value3'
                                 )  OR
                 'administrators' IN
                   ('non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                               'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1',
                               'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1', 'non_existing_dict_value1'
                               ))



                       )
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select concat(meta_categ_name, lstg_format_name) as c1, concat(meta_categ_name, 'CONST') as c2, concat(meta_categ_name, concat(test_sites.site_name, lstg_format_name)) as c3, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where not ( meta_categ_name not in ('', 'a','Computers') or meta_categ_name not in ('Crafts','Computers'))
 group by concat(meta_categ_name, lstg_format_name), concat(meta_categ_name, 'CONST'), concat(meta_categ_name, concat(test_sites.site_name, lstg_format_name))--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_kylin_fact.seller_id
 ,test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002
 group by
 test_kylin_fact.seller_id
 ,test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
 having sum(price)>500
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT COUNT(test_kylin_fact.test_count_column) AS TEST_COUNT_COLUMN_CNT
FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
WHERE test_cal_dt.WEEK_BEG_DT >= '2001-09-09'
 AND test_cal_dt.WEEK_BEG_DT <= '2018-05-16'--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select fact.lstg_format_name from

 (select * from test_kylin_fact where cal_dt > date'2010-01-01' ) as fact

 group by fact.lstg_format_name

 order by CASE WHEN fact.lstg_format_name IS NULL THEN 'sdf' ELSE fact.lstg_format_name END

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GMV, count(1) as TRANS_CNT ,  sum(test_kylin_fact.item_count) as total_items from test_kylin_fact limit 50
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT  TEST_KYLIN_FACT.CAL_DT as TEST_KYLIN_FACT_CAL_DT,
        TEST_KYLIN_FACT.ORDER_ID as TEST_KYLIN_FACT_ORDER_ID,
        TEST_ORDER.TEST_DATE_ENC as TEST_ORDER_TEST_DATE_ENC,
        TEST_ORDER.TEST_TIME_ENC as TEST_ORDER_TEST_TIME_ENC,
        TEST_KYLIN_FACT.LEAF_CATEG_ID as TEST_KYLIN_FACT_LEAF_CATEG_ID,
        TEST_KYLIN_FACT.LSTG_SITE_ID as TEST_KYLIN_FACT_LSTG_SITE_ID,
        TEST_CATEGORY_GROUPINGS.META_CATEG_NAME as TEST_CATEGORY_GROUPINGS_META_CATEG_NAME,
        TEST_CATEGORY_GROUPINGS.CATEG_LVL2_NAME as TEST_CATEGORY_GROUPINGS_CATEG_LVL2_NAME,
        TEST_CATEGORY_GROUPINGS.CATEG_LVL3_NAME as TEST_CATEGORY_GROUPINGS_CATEG_LVL3_NAME,
        TEST_KYLIN_FACT.LSTG_FORMAT_NAME as TEST_KYLIN_FACT_LSTG_FORMAT_NAME,
        TEST_KYLIN_FACT.SLR_SEGMENT_CD as TEST_KYLIN_FACT_SLR_SEGMENT_CD,
        TEST_KYLIN_FACT.SELLER_ID as TEST_KYLIN_FACT_SELLER_ID,
        SELLER_ACCOUNT.ACCOUNT_BUYER_LEVEL as SELLER_ACCOUNT_ACCOUNT_BUYER_LEVEL,
        SELLER_ACCOUNT.ACCOUNT_SELLER_LEVEL as SELLER_ACCOUNT_ACCOUNT_SELLER_LEVEL,
        SELLER_ACCOUNT.ACCOUNT_COUNTRY as SELLER_ACCOUNT_ACCOUNT_COUNTRY,
        SELLER_COUNTRY.NAME as SELLER_COUNTRY_NAME,
        TEST_ORDER.BUYER_ID as TEST_ORDER_BUYER_ID,
        BUYER_ACCOUNT.ACCOUNT_BUYER_LEVEL as BUYER_ACCOUNT_ACCOUNT_BUYER_LEVEL,
        BUYER_ACCOUNT.ACCOUNT_SELLER_LEVEL as BUYER_ACCOUNT_ACCOUNT_SELLER_LEVEL,
        BUYER_ACCOUNT.ACCOUNT_COUNTRY as BUYER_ACCOUNT_ACCOUNT_COUNTRY,
        year(TEST_KYLIN_FACT.CAL_DT) as TEST_KYLIN_FACT_DEAL_YEAR
        FROM "DEFAULT".TEST_KYLIN_FACT as TEST_KYLIN_FACT
        LEFT JOIN "DEFAULT".TEST_ORDER as TEST_ORDER
        ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
        LEFT JOIN EDW.TEST_CAL_DT as TEST_CAL_DT
        ON TEST_KYLIN_FACT.CAL_DT = TEST_CAL_DT.CAL_DT
        LEFT JOIN "DEFAULT".TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
        ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
        LEFT JOIN EDW.TEST_SITES as TEST_SITES
        ON TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_SITES.SITE_ID
        LEFT JOIN EDW.TEST_SELLER_TYPE_DIM as TEST_SELLER_TYPE_DIM
        ON TEST_KYLIN_FACT.SLR_SEGMENT_CD = TEST_SELLER_TYPE_DIM.SELLER_TYPE_CD
        LEFT JOIN "DEFAULT".TEST_ACCOUNT as SELLER_ACCOUNT
        ON TEST_KYLIN_FACT.SELLER_ID = SELLER_ACCOUNT.ACCOUNT_ID
        LEFT JOIN "DEFAULT".TEST_ACCOUNT as BUYER_ACCOUNT
        ON TEST_ORDER.BUYER_ID = BUYER_ACCOUNT.ACCOUNT_ID
        LEFT JOIN "DEFAULT".TEST_COUNTRY as SELLER_COUNTRY
        ON SELLER_ACCOUNT.ACCOUNT_COUNTRY = SELLER_COUNTRY.COUNTRY
        LEFT JOIN "DEFAULT".TEST_COUNTRY as BUYER_COUNTRY
        ON BUYER_ACCOUNT.ACCOUNT_COUNTRY = BUYER_COUNTRY.COUNTRY
        WHERE 1=1--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.seller_id = 10000002 or test_kylin_fact.lstg_format_name = 'FP-non GTC'
 group by
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GMV, count(*) as TRANS_CNT  FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
where test_kylin_fact.cal_dt < DATE '2012-05-01' or test_kylin_fact.cal_dt > DATE '2013-05-01'

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where
 (test_kylin_fact.lstg_format_name='FP-GTC')  and extract(MONTH from test_cal_dt.week_beg_dt) = 12
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select LSTG_FORMAT_NAME,slr_segment_cd ,sum(price) as GMV, count(1) as TRANS_CNT from test_kylin_fact
 group by LSTG_FORMAT_NAME ,slr_segment_cd
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.week_beg_dt between DATE '2013-01-01' and DATE '2013-06-01'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT COUNT(1) AS TRANS_CNT
FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
WHERE test_cal_dt.WEEK_BEG_DT >= '2001-09-09'
 AND test_cal_dt.WEEK_BEG_DT <= '2018-05-16'
 --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 left JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 left JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 left JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where not ( meta_categ_name not in ('', 'a','Computers') or meta_categ_name not in ('Crafts','Computers'))
 group by meta_categ_name --
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt,leaf_categ_id as x, sum(price) as GMV
 from test_kylin_fact
 group by leaf_categ_id, cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, sum(price) as GMV
 from test_kylin_fact
 group by lstg_format_name, SLR_SEGMENT_CD
  having SLR_SEGMENT_CD > 0
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.cal_dt, count(*) as CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where meta_categ_name not in ('Unknown', 'ToyHobbies', '', 'a', 'BookMagazines')
 group by meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-02-01' and DATE '2013-03-01'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2012-02-01' and DATE '2013-10-01'
 and site_name='Canada'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where
 (test_kylin_fact.lstg_format_name > '')
 and (
 (test_kylin_fact.lstg_format_name='FP-GTC')
 OR
 (test_cal_dt.week_beg_dt between DATE '2013-05-20' and DATE '2013-05-21')
 )
 and (
 (test_kylin_fact.lstg_format_name='ABIN')
 OR
 (test_cal_dt.week_beg_dt between DATE '2013-05-20' and DATE '2013-05-21')
 )
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where meta_categ_name not in ('', 'a')
 group by meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 min(test_cal_dt.cal_dt) as mmin
 ,max(test_cal_dt.cal_dt) as mmax,
  sum(test_kylin_fact.item_count) as total_items
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(price) as GMV, count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.lstg_site_id = test_category_groupings.site_id  AND test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 where test_cal_dt.week_beg_dt between DATE '2013-09-01' and DATE '2013-10-01'
 and test_category_groupings.meta_categ_name='Collectibles'
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt >= DATE '2013-02-10'
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
 where test_kylin_fact.lstg_format_name is null
 group by test_kylin_fact.lstg_format_name having sum(price)>5000 and count(*)>72
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
 group by test_kylin_fact.lstg_format_name having sum(price)>5000
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, sum(price) as GMV
 from test_kylin_fact
 where lstg_format_name not in ('FP-GTC', 'ABIN')
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select meta_categ_name, count(1) as cnt, sum(price) as GMV

 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id

 where meta_categ_name is not null
 group by meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT from test_kylin_fact
 group by test_kylin_fact.lstg_format_name having sum(price)>5000 and count(*)>72
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.cal_dt, max(test_kylin_fact.cal_dt) as mmm from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id group by test_kylin_fact.cal_dt order by 2 desc limit 7
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_category_groupings.meta_categ_name
 ,sum(test_kylin_fact.price) as GMV
 ,count(*) as trans_cnt
 FROM test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 group by
 test_category_groupings.meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.cal_dt, count(*) as mmm from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id where lstg_format_name = 'Others'  group by test_kylin_fact.cal_dt order by test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select seller_id, percentile_approx(price, 0.5) from test_kylin_fact
group by seller_id--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select seller_id, percentile(price, 0.5) from test_kylin_fact
group by seller_id--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select T1.LSTG_FORMAT_NAME, avg(T1.gmv/T2.gmv)
from
(select LSTG_FORMAT_NAME, SLR_SEGMENT_CD,
    sum(0.9*(price+50)) as gmv
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
group by LSTG_FORMAT_NAME, SLR_SEGMENT_CD) T1
inner join
(select LSTG_FORMAT_NAME, SLR_SEGMENT_CD,
    sum(case
    when LSTG_FORMAT_NAME = 'ABIN' then 0.8*(price+50)
    else price
    end) as gmv
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
group by LSTG_FORMAT_NAME, SLR_SEGMENT_CD) T2
on T1.LSTG_FORMAT_NAME = T2.LSTG_FORMAT_NAME and T1.SLR_SEGMENT_CD = T2.SLR_SEGMENT_CD
group by T1.LSTG_FORMAT_NAME
order by T1.LSTG_FORMAT_NAME--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select SLR_SEGMENT_CD, count(LSTG_FORMAT_NAME)
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
group by SLR_SEGMENT_CD
order by SLR_SEGMENT_CD--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select LSTG_FORMAT_NAME,
    sum(price),
    sum(case
    when LSTG_FORMAT_NAME = 'ABIN' then 2*price
    when LSTG_FORMAT_NAME = 'Auction' then (1+2)*price*(2+3)+(2+3)*(3+2)*(4+5)-4+5
    else 3
    end)
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
WHERE SLR_SEGMENT_CD < 16
group by LSTG_FORMAT_NAME
having sum((1+2)*price*(2+3)+(2+3)*(3+2)*(4+5)-4+5) > 1800000
order by LSTG_FORMAT_NAME--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select SLR_SEGMENT_CD, sum(case when LSTG_FORMAT_NAME is null then 0 else 1 end)
FROM test_kylin_fact
group by SLR_SEGMENT_CD
order by SLR_SEGMENT_CD--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select LSTG_FORMAT_NAME, (case
    when USER_DEFINED_FIELD1 < 0 then 0
    when USER_DEFINED_FIELD1 < 10 then 1
    else 3
    end),
    sum(price)
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
WHERE SLR_SEGMENT_CD < 16 and USER_DEFINED_FIELD1 is not null
group by LSTG_FORMAT_NAME, (case
    when USER_DEFINED_FIELD1 < 0 then 0
    when USER_DEFINED_FIELD1 < 10 then 1
    else 3
    end)
order by LSTG_FORMAT_NAME, (case
    when USER_DEFINED_FIELD1 < 0 then 0
    when USER_DEFINED_FIELD1 < 10 then 1
    else 3
    end)--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select LSTG_FORMAT_NAME, (case
    when SLR_SEGMENT_CD < 0 then 0
    when SLR_SEGMENT_CD < 10 then 1
    else 3
    end),
    sum(price)
FROM test_kylin_fact
    inner JOIN edw.test_cal_dt as test_cal_dt
    ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
    inner JOIN test_category_groupings
    ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
WHERE SLR_SEGMENT_CD < 16
group by LSTG_FORMAT_NAME, (case
    when SLR_SEGMENT_CD < 0 then 0
    when SLR_SEGMENT_CD < 10 then 1
    else 3
    end)
order by LSTG_FORMAT_NAME, (case
    when SLR_SEGMENT_CD < 0 then 0
    when SLR_SEGMENT_CD < 10 then 1
    else 3
    end)--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


 select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(*) as x
 from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where massin(test_kylin_fact.SELLER_ID,'vip_customers')
 group by test_kylin_fact.lstg_format_name having count(*) > 2
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


 select test_kylin_fact.leaf_categ_id,sum(price) as GMV, count(*) as x
 from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
  where massin(test_kylin_fact.SELLER_ID,'vip_customers')
 group by test_kylin_fact.leaf_categ_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
  count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where massin(test_kylin_fact.SELLER_ID,'vip_customers')
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(price) as GMV, count(*) as TRANS_CNT  FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
where (test_kylin_fact.cal_dt < DATE '2012-05-01' or test_kylin_fact.cal_dt > DATE '2013-05-01')
and massin(test_kylin_fact.SELLER_ID,'vip_customers')

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name from test_kylin_fact limit 100
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select *
from
test_kylin_fact left join edw.test_cal_dt on test_kylin_fact.cal_dt = edw.test_cal_dt.CAL_DT
limit 10
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


 select lstg_format_name from test_kylin_fact order by case

                                                           when 1=1  then

                                                             cal_dt

                                                          ELSE

                                                             seller_id

                                                         end




--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,sum(price) as sp from test_kylin_fact group by lstg_format_name limit 1 offset 2
-- simple union
select * from TEST_KYLIN_FACT where CAL_DT < DATE '2012-06-01'
union
select * from TEST_KYLIN_FACT where CAL_DT > DATE '2013-07-01'--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select price,lstg_format_name from test_kylin_fact limit 100
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


 select  * from test_kylin_fact order by case

                                                           when 1=1  then

                                                             cal_dt

                                                          ELSE

                                                             seller_id

                                                         end  desc




--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


 select  * from test_kylin_fact where case

                                                           when cal_dt is null then

                                                             date'2010-01-01'

                                                          ELSE

                                                                cal_dt

                                                         end

                                                         < date '2013-01-01'
                                              limit 10



--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select * from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select price from test_kylin_fact limit 100
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select * from test_kylin_fact limit 100
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_kylin_fact.seller_id
 ,count(DISTINCT test_cal_dt.cal_dt) as CNT_DT
 ,count(DISTINCT test_kylin_fact.leaf_categ_id) as CNT_CATE_LEAF
 ,count(DISTINCT test_kylin_fact.lstg_format_name) as CNT_LSTG
 ,count(DISTINCT test_category_groupings.meta_categ_name) as CNT_CATE
 ,count(test_kylin_fact.price) as GMV_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.lstg_site_id = test_category_groupings.site_id  AND test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 group by  test_kylin_fact.seller_id--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select seller_id, lstg_site_id, count(DISTINCT leaf_categ_id) as CategCount
from test_kylin_fact
group by seller_id, lstg_site_id-- union subquery under join
select  count(*) as cnt,TEST_A.SELLER_ID
FROM TEST_KYLIN_FACT as TEST_A
inner join (

    (
    select sum(PRICE) as x, seller_id,count(*) as y
    from
        TEST_KYLIN_FACT where CAL_DT < DATE '2012-08-01'
    group by seller_id
    )

       union

       (
    select sum(PRICE) as x, seller_id,count(*) as y
        from
            TEST_KYLIN_FACT where CAL_DT > DATE '2012-12-01'
        group by seller_id
       )

) TEST_B
on TEST_A.seller_id = TEST_B.seller_id
group by TEST_A.seller_id
-- union subquery under join
select count(*) as cnt
FROM TEST_KYLIN_FACT as TEST_A
join (
    select * from TEST_KYLIN_FACT where CAL_DT < DATE '2012-08-01'
    union
    select * from TEST_KYLIN_FACT where CAL_DT > DATE '2013-06-01'
) TEST_B
on TEST_A.ORDER_ID = TEST_B.ORDER_ID
group by TEST_A.SELLER_ID
-- union subquery under join
select count(*) as cnt
FROM TEST_KYLIN_FACT as TEST_A
join (
    select sum(TEST_C.PRICE), TEST_C.ORDER_ID
    from (
        select * from TEST_KYLIN_FACT where CAL_DT < DATE '2012-08-01'
        union
        select * from TEST_KYLIN_FACT where CAL_DT > DATE '2013-06-01'
    ) TEST_C group by ORDER_ID
) TEST_B
on TEST_A.ORDER_ID = TEST_B.ORDER_ID
group by TEST_A.SELLER_ID
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- This is a sample case

SELECT 'Hello world' AS message--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "SUBCOL" AS "COL" FROM ( SELECT 1 AS "SUBCOL" ) "SUBQUERY" GROUP BY 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "COL" FROM (SELECT 1 AS "COL") AS "SUBQUERY"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT 1 AS "COL"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "SUBCOL" AS "COL" FROM ( SELECT 1 AS "SUBCOL" ) "SUBQUERY" GROUP BY 2
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "COL" FROM (SELECT 1 AS "COL") AS "CHECKTOP" LIMIT 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT TOP 1 "COL" FROM (SELECT 1 AS "COL") AS "CHECKTOP"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select WEEK_START, count(*) as cnt, max(EXPERIENCE) as max_exp from STREAMING_V2_USER_INFO_TABLE group by WEEK_START--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(distinct uid) as cnt_uid from STREAMING_V2_USER_INFO_TABLE where MINUTE_START >= {TS '2019-01-28 16:25:00'} and MINUTE_START <= {TS '2019-01-28 17:05:00'}--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select YEAR_START, count(*) as cnt, min(EXPERIENCE) as min_exp from STREAMING_V2_USER_INFO_TABLE group by YEAR_START--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select ALLIACNCE, CLASSES, max(EXPERIENCE) as max_exp, min(EXPERIENCE) as min_exp from STREAMING_V2_USER_INFO_TABLE where DAY_START = date '2019-01-28' group by ALLIACNCE, CLASSES--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select QUARTER_START, PROVINCE, count(*) as cnt, sum(COINS) as sum_coins from STREAMING_V2_USER_INFO_TABLE group by QUARTER_START, PROVINCE--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PROVINCE, "HOLD", sum(COINS) as sum_coins from STREAMING_V2_USER_INFO_TABLE where YEAR_START >= date '2019-01-01' group by PROVINCE, "HOLD"--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select HOUR_START, count(*) as cnt from STREAMING_V2_USER_INFO_TABLE group by HOUR_START--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select DAY_START, count(*) AS cnt, sum(COINS) as sum_coins from STREAMING_V2_USER_INFO_TABLE group by DAY_START--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as cnt from STREAMING_V2_USER_INFO_TABLE--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PROVINCE, percentile_approx(REPUTATION, 0.5) from STREAMING_V2_USER_INFO_TABLE
group by PROVINCE--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PROVINCE, percentile(REPUTATION, 0.5) from STREAMING_V2_USER_INFO_TABLE
group by PROVINCESELECT

TEST_ORDER.ORDER_ID
,max(TEST_ORDER.TEST_TIME_ENC) as test_time
,max(TEST_ORDER.TEST_DATE_ENC) as test_date

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID

group by TEST_ORDER.ORDER_ID
order by TEST_ORDER.ORDER_IDselect "TEST_KYLIN_FACT"."CAL_DT" as "CAL_DT"  from "DEFAULT"."TEST_KYLIN_FACT" "TEST_KYLIN_FACT" where ("TEST_KYLIN_FACT"."CAL_DT" ) >= DATE'2013-01-07' + interval '3' day  group by "TEST_KYLIN_FACT"."CAL_DT" order by "TEST_KYLIN_FACT"."CAL_DT"--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select cal_dt,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id, lstg_format_name) as DIST_SELLER_FORMAT
 from test_kylin_fact
 group by cal_dt
select "TEST_KYLIN_FACT"."CAL_DT" as "CAL_DT"  from "DEFAULT"."TEST_KYLIN_FACT" "TEST_KYLIN_FACT" where ("TEST_KYLIN_FACT"."CAL_DT" + interval '3' day ) >= DATE'2013-01-07'  group by "TEST_KYLIN_FACT"."CAL_DT" order by "TEST_KYLIN_FACT"."CAL_DT"--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name in (?, ?)
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select sum(1) as "col" from (
 select test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name, sum(test_kylin_fact.price) as gmv, count(*) as trans_cnt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 where test_kylin_fact.lstg_format_name = ?
 and test_category_groupings.meta_categ_name = ?
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-10-01'
 group by test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name
 ) "tableausql" having count(1)>0
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name, sum(test_kylin_fact.price) as gmv, count(*) as trans_cnt
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 where test_kylin_fact.lstg_format_name = ?
 and test_category_groupings.meta_categ_name = ?
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-10-01'
 group by test_cal_dt.week_beg_dt, test_kylin_fact.lstg_format_name, test_category_groupings.meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) as cnt from test_kylin_fact
where lstg_format_name>=? and ?>=lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt,cast(timestampdiff(YEAR,date'2000-01-01',test_kylin_fact.cal_dt) as integer) as x,sum(price) as y
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT sum(price)  as sum_price
 FROM TEST_KYLIN_FACT
 WHERE CAL_DT > cast(TIMESTAMPADD(Day, -0, CURRENT_TIMESTAMP) as DATE)
GROUP BY CAL_DT
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(MONTH,23,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(MONTH,-2,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(WEEK,-5,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(MONTH,25,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt,cast(timestampdiff(MONTH,date'2012-01-01',test_kylin_fact.cal_dt) as integer) as x,sum(price) as y
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT sum(price)  as sum_price
 FROM TEST_KYLIN_FACT
 WHERE CAL_DT > cast(TIMESTAMPADD(Day, -15000, CURRENT_TIMESTAMP ) as DATE)
GROUP BY CAL_DT
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(MONTH,-25,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(YEAR,1,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT count(*) as cnt
 FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
 INNER JOIN TEST_ORDER as TEST_ORDER
 ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
 INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
 ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID
 where TEST_TIME_ENC >= TIMESTAMP'2010-01-01 15:43:38'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y, cast(timestampadd(MONTH,-23,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT sum(price)  as sum_price
 FROM TEST_KYLIN_FACT
 WHERE CAL_DT > cast(TIMESTAMPADD(Day, -15000, CURRENT_DATE) as DATE)
GROUP BY CAL_DT
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt,cast(timestampdiff(DAY,date'2013-01-01',test_kylin_fact.cal_dt) as integer) as x,sum(price) as y
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(WEEK,1,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y, cast(timestampadd(DAY,1,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(MONTH,1,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(YEAR,-2,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT sum(price)  as sum_price
 FROM TEST_KYLIN_FACT
 WHERE CAL_DT > cast(TIMESTAMPADD(Day, -2000, CURRENT_DATE) as DATE)
GROUP BY CAL_DT
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt,cast(timestampdiff(WEEK,date'2013-01-01',test_kylin_fact.cal_dt) as integer) as x,sum(price) as y
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT test_kylin_fact.cal_dt ,sum(price) as y,cast(timestampadd(DAY,-2,test_kylin_fact.cal_dt) as date) as x
 FROM TEST_KYLIN_FACT

inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 GROUP BY test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select
(case grouping(cal_dt) when 1 then 'ALL' else cast(cal_dt as varchar(256)) end) as dt,
(case grouping(slr_segment_cd) when 1 then 'ALL' else cast(slr_segment_cd as varchar(256)) end) as cd,
(case grouping(lstg_format_name) when 1 then 'ALL' else lstg_format_name end) as name,
sum(price) as GMV,
count(*) as TRANS_CNT from test_kylin_fact
where cal_dt between '2012-01-01' and '2012-02-01'
group by cube(lstg_format_name, cal_dt, slr_segment_cd)--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select
sum(price) as GMV,
(case grouping(cal_dt) when 1 then 'ALL' else cast(cal_dt as varchar(256)) end) as dt,
(case grouping(slr_segment_cd) when 1 then 'ALL' else cast(slr_segment_cd as varchar(256)) end) as cd,
(case grouping(lstg_format_name) when 1 then 'ALL' else lstg_format_name end) as name,
count(*) as TRANS_CNT from test_kylin_fact
where cal_dt between '2012-01-01' and '2012-02-01'
group by grouping sets((lstg_format_name, cal_dt, slr_segment_cd), (cal_dt, slr_segment_cd), (lstg_format_name, slr_segment_cd))
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select
(case grouping(cal_dt) when 1 then 'ALL' else cast(cal_dt as varchar(256)) end) as dt,
(case grouping(slr_segment_cd) when 1 then 'ALL' else cast(slr_segment_cd as varchar(256)) end) as cd,
(case grouping(lstg_format_name) when 1 then 'ALL' else lstg_format_name end) as name,
sum(price) as GMV,
count(*) as TRANS_CNT from test_kylin_fact
where cal_dt between '2012-01-01' and '2012-02-01'
group by rollup(lstg_format_name, cal_dt, slr_segment_cd)-- unionall subquery under join
select count(*) as cnt
FROM TEST_KYLIN_FACT as TEST_A
join (
    select * from TEST_KYLIN_FACT where CAL_DT < DATE '2012-02-01'
    union all
    select * from TEST_KYLIN_FACT where CAL_DT > DATE '2013-12-31'
) TEST_B
on TEST_A.ORDER_ID = TEST_B.ORDER_ID
group by TEST_A.SELLER_ID
-- unionall
select count(*) as count_a
from TEST_KYLIN_FACT as TEST_A
where lstg_format_name='FP-GTC'
union all
select count(*) as count_a
from TEST_KYLIN_FACT as TEST_A
where lstg_format_name='FP-GTC'-- unionall
select max(ORDER_ID) as ORDER_ID_MAX
from TEST_KYLIN_FACT as TEST_A
where ORDER_ID <> 1
union all
select max(ORDER_ID) as ORDER_ID_MAX
from TEST_KYLIN_FACT as TEST_BSELECT LSTG_FORMAT_NAME, sum_price, sum_price2
FROM (
	SELECT LSTG_FORMAT_NAME, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY LSTG_FORMAT_NAME
	UNION ALL
	SELECT LSTG_FORMAT_NAME, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY LSTG_FORMAT_NAME
)
	CROSS JOIN (
		SELECT SUM(price) AS sum_price2
		FROM test_kylin_fact
		GROUP BY LSTG_FORMAT_NAME
	)
UNION ALL
SELECT 'name' AS LSTG_FORMAT_NAME, 11.2 AS sum_price, 22.1 AS sum_price2--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt, SUM(test_kylin_fact.price) AS GMV
	, COUNT(*) AS TRANS_CNT
FROM test_kylin_fact
	INNER JOIN edw.test_cal_dt test_cal_dt ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
	INNER JOIN test_category_groupings
	ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
		AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
	INNER JOIN edw.test_sites test_sites ON test_kylin_fact.lstg_site_id = test_sites.site_id
WHERE 1 <> 1
GROUP BY test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
SELECT *
FROM (
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
	UNION ALL
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
)
	CROSS JOIN (
		SELECT SUM(price) AS sum_price_2
		FROM test_kylin_fact
		GROUP BY leaf_categ_id
	)
UNION ALL
SELECT cast(1999 as bigint) AS leaf_categ_id, 11.2 AS sum_price, 21.2 AS sum_price2
UNION ALL
SELECT *
FROM (
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
	UNION ALL
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
)
	CROSS JOIN (
		SELECT SUM(price) AS sum_price_2
		FROM test_kylin_fact
		GROUP BY leaf_categ_id
	)
ORDER BY 1select leaf_categ_id, sum(price) as sum_price from test_kylin_fact  group by leaf_categ_id
union all
select cast(1  as bigint) as leaf_categ_id, 22.5 as sum_priceSELECT *
FROM (
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
	UNION ALL
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
)
	CROSS JOIN (
		SELECT MAX(price) AS sum_price_2
		FROM test_kylin_fact
		GROUP BY leaf_categ_id
	)
UNION ALL
SELECT *
FROM (
	SELECT cast(1  as bigint) AS leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	WHERE 1 <> 1
	GROUP BY leaf_categ_id
	UNION ALL
	SELECT cast(2  as bigint) AS leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	WHERE 1 <> 1
	GROUP BY leaf_categ_id
)
	CROSS JOIN (
		SELECT MAX(price) AS sum_price_2
		FROM test_kylin_fact
		GROUP BY leaf_categ_id
	)
UNION ALL
SELECT *
FROM (
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
	UNION ALL
	SELECT leaf_categ_id, SUM(price) AS sum_price
	FROM test_kylin_fact
	GROUP BY leaf_categ_id
)
	CROSS JOIN (
		SELECT MAX(price) AS sum_price_2
		FROM test_kylin_fact
		GROUP BY leaf_categ_id
	)
ORDER BY 1--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select cal_dt, lstg_format_name, sum(price) as GMV,
(case lag(sum(price), 1, 0.0) over(partition by lstg_format_name order by cal_dt)
when 0.0 then 0 else sum(price)/lag(sum(price), 1, 0.0) over(partition by lstg_format_name order by cal_dt) end) as "prev"
from test_kylin_fact
where cal_dt < '2012-02-01'
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select lstg_format_name,
sum(sum(price)) over(partition by lstg_format_name),
max(sum(price)) over(partition by lstg_format_name),
min(sum(price)) over(partition by lstg_format_name)
from test_kylin_fact
group by cal_dt, lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select * from(
  select cal_dt, lstg_format_name, sum(price) as GMV,
  100*sum(price)/first_value(sum(price)) over (partition by lstg_format_name order by cast(cal_dt as timestamp) range interval '1' day PRECEDING) as "last_day",
  first_value(sum(price)) over (partition by lstg_format_name order by cast(cal_dt as timestamp) range cast(366 as INTERVAL day) preceding)
  from test_kylin_fact as "last_year"
  where cal_dt between '2013-01-08' and '2013-01-15' or cal_dt between '2013-01-07' and '2013-01-15' or cal_dt between '2012-01-01' and '2012-01-15'
  group by cal_dt, lstg_format_name
)t
where cal_dt between '2013-01-06' and '2013-01-15'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select lstg_format_name, sum(price) as GMV, row_number() over()
from test_kylin_fact
group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select cal_dt, lstg_format_name, sum(price) as GMV,
first_value(sum(price)) over (partition by lstg_format_name order by cast(cal_dt as timestamp) range interval '3' day preceding) as "prev 3 days",
last_value(sum(price)) over (partition by lstg_format_name order by cast(cal_dt as timestamp) range interval '3' day following) as "next 3 days"
from test_kylin_fact
where cal_dt < '2012-02-01'
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select lstg_format_name, avg(sum(price)) over(partition by lstg_format_name)
from test_kylin_fact
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select cal_dt, lstg_format_name, sum(price) as GMV,
first_value(sum(price)) over (partition by lstg_format_name order by cal_dt rows 2 preceding) as "prev 2 rows",
last_value(sum(price)) over (partition by lstg_format_name order by cal_dt rows 2 following) as "next 2 rows"
from test_kylin_fact
where cal_dt < '2012-02-01'
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select lstg_format_name,cal_dt,
sum(sum(price)) over(partition by lstg_format_name,cal_dt),
max(sum(price)) over(partition by lstg_format_name,cal_dt),
min(sum(price)) over(partition by lstg_format_name)
from test_kylin_fact
group by cal_dt, lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select lstg_format_name, sum(price) as GMV, count(lstg_format_name) over(partition by lstg_format_name)
from test_kylin_fact
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select * from(
  select cal_dt, lstg_format_name, sum(price) as GMV,
  100*sum(price)/first_value(sum(price)) over (partition by lstg_format_name,SLR_SEGMENT_CD order by cast(cal_dt as timestamp) range interval '1' day PRECEDING) as "last_day",
  first_value(sum(price)) over (partition by lstg_format_name order by cast(cal_dt as timestamp) range cast(366 as INTERVAL day) preceding)
  from test_kylin_fact as "last_year"
  where cal_dt between '2013-01-08' and '2013-01-15' or cal_dt between '2013-01-07' and '2013-01-15' or cal_dt between '2012-01-01' and '2012-01-15'
  group by cal_dt, lstg_format_name,SLR_SEGMENT_CD
)t
where cal_dt between '2013-01-06' and '2013-01-15'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select cal_dt, lstg_format_name, sum(price) as GMV,
first_value(sum(price)) over(partition by lstg_format_name order by cal_dt) as "first",
last_value(sum(price)) over(partition by lstg_format_name order by cal_dt) as "current",
lag(sum(price), 1, 0.0) over(partition by lstg_format_name order by cal_dt) as "prev",
lead(sum(price), 1, 0.0) over(partition by lstg_format_name order by cal_dt) as "next",
ntile(4) over (partition by lstg_format_name order by cal_dt) as "quarter"
from test_kylin_fact
where cal_dt < '2012-02-01'
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select cal_dt, lstg_format_name, sum(price),
rank() over(partition by lstg_format_name order by cal_dt) as "RANK",
dense_rank() over(partition by lstg_format_name order by cal_dt) as "DENSE_RANK"
from test_kylin_fact
group by cal_dt, lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2013-10-10' AND test_kylin_fact.cal_dt > DATE '2013-09-10'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2013-02-10'  AND test_kylin_fact.cal_dt > DATE '2012-01-01'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2018-10-10' AND test_kylin_fact.cal_dt > DATE '2009-09-10'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2012-09-10' AND test_kylin_fact.cal_dt > DATE '2012-01-01'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2012-10-10'  AND test_kylin_fact.cal_dt > DATE '2012-01-01'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2018-10-10' AND test_kylin_fact.cal_dt > DATE '2009-09-10'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2012-09-10' AND test_kylin_fact.cal_dt > DATE '2012-01-01'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2014-10-10'  AND test_kylin_fact.cal_dt > DATE '2012-01-01'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.cal_dt < DATE '2013-10-10'  AND test_kylin_fact.cal_dt > DATE '2012-01-01'
 group by test_kylin_fact.lstg_format_name, test_kylin_fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select LSTG_FORMAT_NAME,LSTG_SITE_ID,SLR_SEGMENT_CD,CAL_DT,LEAF_CATEG_ID,PRICE,TRANS_ID from test_kylin_fact--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select CAL_DT,LSTG_FORMAT_NAME,PRICE from test_kylin_fact where LSTG_FORMAT_NAME = 'ABIN'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PRICE from test_kylin_fact where LSTG_FORMAT_NAME = 'ABIN'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.CAL_DT,PRICE from test_kylin_fact  inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id  where LSTG_FORMAT_NAME = 'ABIN'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PRICE from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.CAL_DT from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PRICE from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select PRICE from test_kylin_fact inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id  where LSTG_FORMAT_NAME = 'ABIN'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select CAL_DT from test_kylin_fact
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select CAL_DT,LSTG_FORMAT_NAME,PRICE,TRANS_ID from test_kylin_fact where LSTG_FORMAT_NAME = 'ABIN'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT
 from test_kylin_fact
 group by lstg_format_name
 order by sum(price)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
 order by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.Week_Beg_Dt, sum(price) as c1, count(1) as c2
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_kylin_fact.lstg_format_name='ABIN'
 and test_cal_dt.week_beg_dt >= DATE '2013-06-09'
 group by test_cal_dt.week_beg_dt
 order by test_cal_dt.week_beg_dt

 -- optiq 0.8 reports varchar instead of date on week_beg_dt and fail test case
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- test case for KYLIN-1954

select META_CATEG_NAME as META_CATEG_NAME, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where META_CATEG_NAME like '%ab%' and META_CATEG_NAME > 'A'
group by META_CATEG_NAME
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- test case for KYLIN-1954

select lstg_format_name as lstg_format_name, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where lstg_format_name like '%BIN%' and lstg_format_name > 'A'
group by lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select upper(lstg_format_name) as lstg_format_name, count(*) as cnt from test_kylin_fact
where lower(lstg_format_name)='abin_a' and substring(lstg_format_name,1,3) in ('ABI') and upper(lstg_format_name) > 'AAAA' and
lower(lstg_format_name) like '%b%' and char_length(lstg_format_name) < 10 and char_length(lstg_format_name) > 3 and lstg_format_name||'a'='ABIN_Aa'
group by lstg_format_name
select USER_DEFINED_FIELD3 as abc

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where upper(USER_DEFINED_FIELD3) like '%VID%'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name as lstg_format_name, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where lstg_format_name not like '%BIN%'
group by lstg_format_name
select USER_DEFINED_FIELD3 as abc

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where USER_DEFINED_FIELD3 like '%Video Game%'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select META_CATEG_NAME as META_CATEG_NAME, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where not(META_CATEG_NAME not like '%ab%')
group by META_CATEG_NAME

select USER_DEFINED_FIELD3 as abc

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where upper(USER_DEFINED_FIELD3) like '%VIDEO GAME%'

select USER_DEFINED_FIELD3 as abc

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where lower(USER_DEFINED_FIELD3) like '%video game%'

select USER_DEFINED_FIELD3 as abc

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where lower(USER_DEFINED_FIELD3) like '%Video Game%'
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select META_CATEG_NAME as META_CATEG_NAME, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where META_CATEG_NAME like '%ab%'
group by META_CATEG_NAME
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name as lstg_format_name, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where not(lstg_format_name not like '%BIN%')
group by lstg_format_name--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select META_CATEG_NAME as META_CATEG_NAME, count(*) as cnt

 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where META_CATEG_NAME not like '%ab%'
group by META_CATEG_NAME
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select upper(meta_categ_name) as META_CATEG_NAME, count(*) as cnt


from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id


where lower(meta_categ_name)='baby' and substring(meta_categ_name,1,3) in ('Bab') and upper(meta_categ_name) > 'AAAA' and
lower(meta_categ_name) like '%b%' and char_length(meta_categ_name) < 10 and char_length(meta_categ_name) > 3 and meta_categ_name||'a'='Babya'
group by meta_categ_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select upper(lstg_format_name) as lstg_format_name, count(*) as cnt from test_kylin_fact
where lower(lstg_format_name)='auction' and substring(lstg_format_name,1,3) in ('Auc') and upper(lstg_format_name) > 'AAAA' and
upper(lstg_format_name) like '%UC%' and char_length(lstg_format_name) < 10 and char_length(lstg_format_name) > 3 and lstg_format_name||'a'='Auctiona'
group by lstg_format_nameSELECT

TEST_ORDER.ORDER_ID
,TEST_EXTENDED_COLUMN

FROM TEST_KYLIN_FACT as TEST_KYLIN_FACT
INNER JOIN TEST_ORDER as TEST_ORDER
ON TEST_KYLIN_FACT.ORDER_ID = TEST_ORDER.ORDER_ID
INNER JOIN TEST_CATEGORY_GROUPINGS as TEST_CATEGORY_GROUPINGS
ON TEST_KYLIN_FACT.LEAF_CATEG_ID = TEST_CATEGORY_GROUPINGS.LEAF_CATEG_ID AND TEST_KYLIN_FACT.LSTG_SITE_ID = TEST_CATEGORY_GROUPINGS.SITE_ID

group by TEST_ORDER.ORDER_ID,TEST_EXTENDED_COLUMN
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select  test_kylin_fact.cal_dt, seller_id
  FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by
 test_kylin_fact.cal_dt, test_kylin_fact.seller_id order by sum(test_kylin_fact.price) desc limit 20
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 seller_id
  FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 where test_kylin_fact.cal_dt < DATE '2013-02-01'
 group by
 test_kylin_fact.seller_id order by sum(test_kylin_fact.price) desc limit 20
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, sum(price) as GMV
 from test_kylin_fact
inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 where test_cal_dt.week_beg_dt between DATE '2013-09-01' and DATE '2013-10-01' and (lstg_format_name='FP-GTC' or 'a' = 'b')
 group by test_cal_dt.week_beg_dt--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 , count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 , count(distinct site_name) as site_count
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.cal_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, cal_dt,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 from test_kylin_fact
 group by lstg_format_name, cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
 having user_count > 50
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.cal_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT
 , count(distinct TEST_COUNT_DISTINCT_BITMAP) as user_count
 , count(distinct site_name) as site_count
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and
 test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 on test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN edw.test_seller_type_dim as test_seller_type_dim
 on test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.cal_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.cal_dt
 having user_count > 2
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select MAX(SLR_SEGMENT_CD)
from TEST_KYLIN_FACT--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select DISTINCT SLR_SEGMENT_CD
from TEST_KYLIN_FACT--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select SLR_SEGMENT_CD
from TEST_KYLIN_FACT
group by SLR_SEGMENT_CD--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
 order by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT, count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name, cal_dt,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 group by lstg_format_name, cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
 having count(distinct seller_id) > 50
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 where lstg_format_name='FP-GTC'
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select lstg_format_name,
 sum(price) as GMV,
 count(1) as TRANS_CNT,
 count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 group by lstg_format_name
 order by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(1) as TRANS_CNT, count(distinct seller_id) as DIST_SELLER
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_kylin_fact.lstg_format_name='FP-GTC'
 and test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_cal_dt.week_beg_dt
 having count(distinct seller_id) > 2
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select LEAF_CATEG_ID,
intersect_count(TEST_COUNT_DISTINCT_BITMAP, CAL_DT, array[date'2012-01-01']) as first_day
from test_kylin_fact
where CAL_DT in (date'2012-01-01',date'2012-01-02',date'2012-01-03')
group by LEAF_CATEG_ID

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select
week_beg_dt as week,
intersect_count( TEST_COUNT_DISTINCT_BITMAP, lstg_format_name, array['FP-GTC']) as a,
intersect_count( TEST_COUNT_DISTINCT_BITMAP, lstg_format_name, array['Auction']) as b,
intersect_count( TEST_COUNT_DISTINCT_BITMAP, lstg_format_name, array['Others']) as c,
intersect_count( TEST_COUNT_DISTINCT_BITMAP, lstg_format_name, array['FP-GTC', 'Auction']) as ab,
intersect_count( TEST_COUNT_DISTINCT_BITMAP, lstg_format_name, array['FP-GTC', 'Others']) as ac,
intersect_count( TEST_COUNT_DISTINCT_BITMAP, lstg_format_name, array['FP-GTC', 'Auction', 'Others']) as abc,
count(distinct TEST_COUNT_DISTINCT_BITMAP) as sellers,
count(*) as cnt
from test_kylin_fact left join edw.test_cal_dt on test_kylin_fact.cal_dt = edw.test_cal_dt.CAL_DT
where week_beg_dt in (DATE '2013-12-22', DATE '2012-06-23')
group by week_beg_dt

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
select CAL_DT,
intersect_count(TEST_COUNT_DISTINCT_BITMAP, CAL_DT, array[date'2012-01-01']) as first_day,
intersect_count(TEST_COUNT_DISTINCT_BITMAP, CAL_DT, array[date'2012-01-02']) as second_day,
intersect_count(TEST_COUNT_DISTINCT_BITMAP, CAL_DT, array[date'2012-01-03']) as third_day,
intersect_count(TEST_COUNT_DISTINCT_BITMAP, CAL_DT, array[date'2012-01-01',date'2012-01-02']) as retention_oneday,
intersect_count(TEST_COUNT_DISTINCT_BITMAP, CAL_DT, array[date'2012-01-01',date'2012-01-02',date'2012-01-03']) as retention_twoday
from test_kylin_fact
where CAL_DT in (date'2012-01-01',date'2012-01-02',date'2012-01-03')
group by CAL_DT

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT SUM("TableauSQL"."GMV") AS "sum_GMV_ok",
 SUM("TableauSQL"."TRANS_CNT") AS "sum_TRANS_CNT_ok"
 FROM (
 SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ) "TableauSQL"
 HAVING (COUNT(1) > 0)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT EXTRACT(YEAR FROM TEST_CAL_DT.WEEK_BEG_DT) AS yr_WEEK_BEG_DT_ok
 FROM TEST_KYLIN_FACT
 inner JOIN EDW.TEST_CAL_DT AS TEST_CAL_DT ON (TEST_KYLIN_FACT.CAL_DT = TEST_CAL_DT.CAL_DT)
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 GROUP BY EXTRACT(YEAR FROM TEST_CAL_DT.WEEK_BEG_DT)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_cal_dt.week_beg_dt, sum(test_kylin_fact.price)
 from test_kylin_fact
 inner join edw.test_cal_dt as test_cal_dt on test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 group by test_cal_dt.week_beg_dt

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT *
 FROM (
 select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
 having sum(price)>500
 ) "TableauSQL"
 LIMIT 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT QUARTER("TEST_CAL_DT"."WEEK_BEG_DT") AS "qr_WEEK_BEG_DT_ok", EXTRACT(YEAR FROM "TEST_CAL_DT"."WEEK_BEG_DT") AS "yr_WEEK_BEG_DT_ok"
FROM "TEST_KYLIN_FACT"
inner JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT"  ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
GROUP BY QUARTER("TEST_CAL_DT"."WEEK_BEG_DT"), EXTRACT(YEAR FROM "TEST_CAL_DT"."WEEK_BEG_DT")
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.cal_dt, count(1) as cnt_1
from test_kylin_fact
left join EDW.TEST_CAL_DT AS TEST_CAL_DT on test_kylin_fact.cal_dt=test_cal_dt.cal_dt
group by test_kylin_fact.cal_dt
order by 2 desc
limit 3
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT (CASE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" WHEN 'Auction' THEN '111' ELSE '222' END) AS "LSTG_FORMAT_NAME__group_",
  SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
--group by (CASE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" WHEN 'Auction' THEN '111' ELSE '222' END)  ORDER BY 1 ASC
GROUP BY "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"  ORDER BY 1 ASC
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT SUM("TableauSQL"."GMV") AS "sum_GMV_ok", SUM("TableauSQL"."TRANS_CNT") AS "sum_TRANS_CNT_ok"
 FROM (
 SELECT test_cal_dt.week_beg_dt ,test_category_groupings.meta_categ_name ,test_category_groupings.categ_lvl2_name ,test_category_groupings.categ_lvl3_name ,sum(test_kylin_fact.price) as GMV , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by test_cal_dt.week_beg_dt ,test_category_groupings.meta_categ_name ,test_category_groupings.categ_lvl2_name ,test_category_groupings.categ_lvl3_name
 ) "TableauSQL" HAVING (COUNT(1) > 0)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(price) as GMV_CNT
 from test_kylin_fact
 group by test_kylin_fact.lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--




 SELECT "TableauSQL"."LSTG_FORMAT_NAME" AS "none_LSTG_FORMAT_NAME_nk", SUM("TableauSQL"."GMV_CNT") AS "sum_GMV_CNT_qk"
 FROM ( select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(price) as GMV_CNT
 from test_kylin_fact where test_kylin_fact.lstg_format_name > 'ab'
 group by test_kylin_fact.lstg_format_name having count(price) > 2 ) "TableauSQL"
 GROUP BY "TableauSQL"."LSTG_FORMAT_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_KYLIN_FACT"."CAL_DT", SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok" FROM "TEST_KYLIN_FACT"
  INNER JOIN (
             SELECT COUNT(1) AS "XTableau_join_flag",     SUM("TEST_KYLIN_FACT"."PRICE") AS "X__alias__A",     "TEST_KYLIN_FACT"."CAL_DT" AS "none_CAL_DT_ok"   FROM "TEST_KYLIN_FACT"
             GROUP BY "TEST_KYLIN_FACT"."CAL_DT"   ORDER BY 2 DESC   LIMIT 7  )

    "t0" ON ("TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok") GROUP BY "TEST_KYLIN_FACT"."CAL_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_CAL_DT"."WEEK_BEG_DT" AS "none_WEEK_BEG_DT_nk",
 SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
 FROM "TEST_KYLIN_FACT"
 inner JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 GROUP BY "TEST_CAL_DT"."WEEK_BEG_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--


select fact.cal_dt, sum(fact.price) from test_kylin_fact fact
left join EDW.TEST_CAL_DT cal on fact.cal_dt=cal.cal_dt
where cal.cal_dt  = date '2012-05-17' or cal.cal_dt  = date '2013-05-17'
group by fact.cal_dt
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT EXTRACT(MONTH FROM "TEST_CAL_DT"."WEEK_BEG_DT") AS "mn_WEEK_BEG_DT_ok", (( EXTRACT(YEAR FROM "TEST_CAL_DT"."WEEK_BEG_DT") * 100) + EXTRACT(MONTH FROM "TEST_CAL_DT"."WEEK_BEG_DT")) AS "my_WEEK_BEG_DT_ok", QUARTER("TEST_CAL_DT"."WEEK_BEG_DT") AS "qr_WEEK_BEG_DT_ok", EXTRACT(YEAR FROM "TEST_CAL_DT"."WEEK_BEG_DT") AS "yr_WEEK_BEG_DT_ok"
FROM "TEST_KYLIN_FACT"
inner JOIN EDW.TEST_CAL_DT AS TEST_CAL_DT ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
GROUP BY EXTRACT(YEAR FROM "TEST_CAL_DT"."WEEK_BEG_DT"), QUARTER("TEST_CAL_DT"."WEEK_BEG_DT"), (( EXTRACT(YEAR FROM "TEST_CAL_DT"."WEEK_BEG_DT") * 100) + EXTRACT(MONTH FROM "TEST_CAL_DT"."WEEK_BEG_DT")), EXTRACT(MONTH FROM "TEST_CAL_DT"."WEEK_BEG_DT")
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--




 SELECT "TableauSQL"."LSTG_FORMAT_NAME" AS "none_LSTG_FORMAT_NAME_nk", SUM("TableauSQL"."GMV_CNT") AS "sum_GMV_CNT_qk"
 FROM ( select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(price) as GMV_CNT
 from test_kylin_fact
 group by test_kylin_fact.lstg_format_name ) "TableauSQL"
 GROUP BY "TableauSQL"."LSTG_FORMAT_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT *
 FROM (
 select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
 ) "TableauSQL"
 LIMIT 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT EXTRACT(YEAR FROM TEST_CAL_DT.WEEK_BEG_DT) AS yr_WEEK_BEG_DT_ok, QUARTER(TEST_CAL_DT.WEEK_BEG_DT) AS qr_WEEK_BEG_DT_ok
 FROM TEST_KYLIN_FACT
 inner JOIN EDW.TEST_CAL_DT AS TEST_CAL_DT ON (TEST_KYLIN_FACT.CAL_DT = TEST_CAL_DT.CAL_DT)
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 GROUP BY EXTRACT(YEAR FROM TEST_CAL_DT.WEEK_BEG_DT), QUARTER(TEST_CAL_DT.WEEK_BEG_DT)

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT COUNT(1) AS cnt_ITEM_COUNT_ok,
 TEST_CAL_DT.WEEK_BEG_DT AS none_WEEK_BEG_DT_nk
 FROM "TEST_KYLIN_FACT"
 inner JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 GROUP BY "TEST_CAL_DT"."WEEK_BEG_DT"

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT QUARTER(TEST_CAL_DT.WEEK_BEG_DT) AS qr_WEEK_BEG_DT_ok
 FROM TEST_KYLIN_FACT
 inner JOIN EDW.TEST_CAL_DT AS TEST_CAL_DT  ON (TEST_KYLIN_FACT.CAL_DT = TEST_CAL_DT.CAL_DT)
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 GROUP BY QUARTER(TEST_CAL_DT.WEEK_BEG_DT)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT SUM(1) AS "COL",
 2 AS "COL2"
 FROM (
 select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
 having sum(price)>500
 ) "TableauSQL"
 GROUP BY 2
 HAVING COUNT(1)>0

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_KYLIN_FACT"."CAL_DT", SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
	FROM "TEST_KYLIN_FACT"
    INNER JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
    INNER JOIN (
     SELECT COUNT(1) AS "XTableau_join_flag",
      SUM("TEST_KYLIN_FACT"."PRICE") AS "X__alias__A",
       "TEST_KYLIN_FACT"."CAL_DT" AS "none_CAL_DT_ok"   FROM "TEST_KYLIN_FACT"
         INNER JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
     GROUP BY "TEST_KYLIN_FACT"."CAL_DT"   ORDER BY 2 DESC   LIMIT 10  ) "t0" ON ("TEST_KYLIN_FACT"."CAL_DT" = "t0"."none_CAL_DT_ok")
    GROUP BY "TEST_KYLIN_FACT"."CAL_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

 select test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 from test_kylin_fact
 inner JOIN EDW.TEST_CAL_DT AS TEST_CAL_DT
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 where test_cal_dt.week_beg_dt between DATE '2013-05-01' and DATE '2013-08-01'
 group by test_kylin_fact.lstg_format_name, test_cal_dt.week_beg_dt
 having sum(price)>500
 limit 1
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_CAL_DT"."WEEK_BEG_DT" AS "none_WEEK_BEG_DT_nk",
 SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
 FROM "TEST_KYLIN_FACT"
 inner JOIN "EDW"."TEST_CAL_DT" AS "TEST_CAL_DT" ON ("TEST_KYLIN_FACT"."CAL_DT" = "TEST_CAL_DT"."CAL_DT")
 inner join test_category_groupings AS test_category_groupings
 on test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id and test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 GROUP BY "TEST_CAL_DT"."WEEK_BEG_DT"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- This query don't result exact same average number as H2 DB

select lstg_format_name, avg(price) as GMV
 from test_kylin_fact
 group by lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT SUM("TableauSQL"."GMV") AS "sum_GMV_ok",
 SUM("TableauSQL"."TRANS_CNT") AS "sum_TRANS_CNT_ok"
 FROM (
 SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ) "TableauSQL"
 HAVING (COUNT(1) > 0)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TableauSQL"."META_CATEG_NAME" AS "none_META_CATEG_NAME_nk"
 FROM (
 SELECT
 test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,sum(test_kylin_fact.price) as GMV
 , count(*) as TRANS_CNT
 FROM test_kylin_fact
 inner JOIN edw.test_cal_dt as test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id
 AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 group by test_cal_dt.week_beg_dt
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ) "TableauSQL"
 GROUP BY "TableauSQL"."META_CATEG_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt_test
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as gmv
 , count(*) as trans_cnt
 FROM test_kylin_fact
 inner JOIN test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.retail_year='2013'
 and retail_week in(1,2,3,4,5,6,7,7,7)
 and (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.categ_lvl3_name='Dresses')
 and test_sites.site_name='Ebay'
 and test_cal_dt.retail_year not in ('2014')
 and test_kylin_fact.price<100
 group by test_cal_dt.week_beg_dt
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt_test
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price_amt) as gmv
 , count(*) as trans_cnt
 FROM test_kylin_fact
 inner JOIN test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.retail_year='2013'
 and retail_week in(1,2,3,4,5,6,7,7,7)
 and (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.categ_lvl3_name='Dresses')
 and test_sites.site_name='Ebay'
 and test_cal_dt.retail_year not in ('2014')
 group by test_cal_dt.week_beg_dt
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt_test
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as gmv
 , count(*) as trans_cnt
 FROM test_kylin_fact
 inner JOIN test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.retail_year='2013'
 and retail_week in(1,2,3,4,5,6,7,7,7)
 and (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.categ_lvl3_name='Dresses')
 and test_sites.site_name='Ebay'
 and test_cal_dt.retail_year not in ('2014')
 group by test_cal_dt.week_beg_dt
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt_test
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as gmv
 , count(*) as trans_cnt
 FROM test_kylin_fact
 inner JOIN test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN edw.test_sites as test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.retail_year='2013'
 and retail_week in(1,2,3,4,5,6,7,7,7)
 and (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.categ_lvl3_name='Dresses')
 and test_sites.site_name='Ebay'
 and test_cal_dt.retail_year not in ('2014')
 group by test_cal_dt.week_beg_dt
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT COUNT(DISTINCT "TableauSQL"."TRANS_CNT") AS "ctd_TRANS_CNT_qk", "TableauSQL"."LSTG_FORMAT_NAME" AS "none_LSTG_FORMAT_NAME_nk"
 FROM ( select test_kylin_fact.lstg_format_name, sum(price) as GMV, count(seller_id) as TRANS_CNT
 from test_kylin_fact
 group by test_kylin_fact.lstg_format_name
 ) "TableauSQL"
 GROUP BY "TableauSQL"."LSTG_FORMAT_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT
 test_cal_dt.week_beg_dt_test
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
 ,sum(test_kylin_fact.price) as gmv
 , count(*) as trans_cnt
 FROM test_kylin_fact
 inner JOIN test_cal_dt
 ON test_kylin_fact.cal_dt = test_cal_dt.cal_dt
 inner JOIN test_category_groupings
 ON test_kylin_fact.leaf_categ_id = test_category_groupings.leaf_categ_id AND test_kylin_fact.lstg_site_id = test_category_groupings.site_id
 inner JOIN test_sites
 ON test_kylin_fact.lstg_site_id = test_sites.site_id
 inner JOIN test_seller_type_dim
 ON test_kylin_fact.slr_segment_cd = test_seller_type_dim.seller_type_cd
 where test_cal_dt.retail_year='2013'
 and retail_week in(1,2,3,4,5,6,7,7,7)
 and (test_category_groupings.meta_categ_name='Collectibles' or test_category_groupings.categ_lvl3_name='Dresses')
 and test_sites.site_name='Ebay'
 and test_cal_dt.retail_year not in ('2014')
 and test_kylin_fact.trans_id=1000000001
 group by test_cal_dt.week_beg_dt
 ,test_cal_dt.retail_year
 ,test_cal_dt.rtl_month_of_rtl_year_id
 ,test_cal_dt.retail_week
 ,test_category_groupings.meta_categ_name
 ,test_category_groupings.categ_lvl2_name
 ,test_category_groupings.categ_lvl3_name
 ,test_kylin_fact.lstg_format_name
 ,test_sites.site_name
 ,test_seller_type_dim.seller_type_desc
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" IN ('Auction', 'FP-GTC')) THEN 'Auction' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END) AS "LSTG_FORMAT_NAME__group_",
  SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
GROUP BY (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" IN ('Auction', 'FP-GTC')) THEN 'Auction' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
FROM   TEST_KYLIN_FACT
WHERE  (CASE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
	WHEN 'Auction' THEN '111'
	WHEN 'FP-GTC' THEN '222'
	ELSE '999' END) = '111'
GROUP BY "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
FROM   TEST_KYLIN_FACT
WHERE  (

(CASE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" WHEN 'Auction' THEN 'Auc'
WHEN 'FOO' THEN 'NO' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END)

> 'A')
GROUP BY "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
FROM   TEST_KYLIN_FACT
WHERE  ((CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" = 'Auction') THEN 'Auction1' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END) = 'Auction1')
GROUP BY "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

 SELECT (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" = 'Auction') THEN 'Auction2' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END) AS "LSTG_FORMAT_NAME__group_",
  SUM("TEST_KYLIN_FACT"."PRICE") AS "sum_PRICE_ok"
FROM "TEST_KYLIN_FACT" "TEST_KYLIN_FACT"
GROUP BY (CASE WHEN ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" =  'Auction') THEN 'Auction2' ELSE "TEST_KYLIN_FACT"."LSTG_FORMAT_NAME" END)
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT lstg_format_name
FROM   test_kylin_fact
WHERE  ( NOT ( ( CASE
                   WHEN ( lstg_format_name IS NULL ) THEN 1
                   WHEN NOT ( lstg_format_name IS NULL ) THEN 0
                   ELSE NULL
                 END ) <> 0 ) )
GROUP  BY lstg_format_name
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select "TEST_KYLIN_FACT"."ORDER_ID",
       case
           when ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"='Auction') = (1 = 1) then 'B'
           when ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"='FP-GTC') = (1 = 1) then 'C'
           when ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"='ABIN') = (1 = 1) then 'D'
           else 'N'
       end as phase
from TEST_KYLIN_FACT
where "TEST_KYLIN_FACT"."CAL_DT" between '2013-01-01' and '2013-01-02'
group by "TEST_KYLIN_FACT"."ORDER_ID",
       case
           when ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"='Auction') = (1 = 1) then 'B'
           when ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"='FP-GTC') = (1 = 1) then 'C'
           when ("TEST_KYLIN_FACT"."LSTG_FORMAT_NAME"='ABIN') = (1 = 1) then 'D'
           else 'N'
       end

--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

select count(*) from kylin_sales
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

DROP TABLE IF EXISTS KYLIN_CAL_DT;

CREATE TABLE KYLIN_CAL_DT
(
CAL_DT date COMMENT 'Date, PK'
,YEAR_BEG_DT date COMMENT 'YEAR Begin Date'
,QTR_BEG_DT date COMMENT 'Quarter Begin Date'
,MONTH_BEG_DT date COMMENT 'Month Begin Date'
,WEEK_BEG_DT date COMMENT 'Week Begin Date'
,AGE_FOR_YEAR_ID smallint
,AGE_FOR_QTR_ID smallint
,AGE_FOR_MONTH_ID smallint
,AGE_FOR_WEEK_ID smallint
,AGE_FOR_DT_ID smallint
,AGE_FOR_RTL_YEAR_ID smallint
,AGE_FOR_RTL_QTR_ID smallint
,AGE_FOR_RTL_MONTH_ID smallint
,AGE_FOR_RTL_WEEK_ID smallint
,AGE_FOR_CS_WEEK_ID smallint
,DAY_OF_CAL_ID int
,DAY_OF_YEAR_ID smallint
,DAY_OF_QTR_ID smallint
,DAY_OF_MONTH_ID smallint
,DAY_OF_WEEK_ID int
,WEEK_OF_YEAR_ID tinyint
,WEEK_OF_CAL_ID int
,MONTH_OF_QTR_ID tinyint
,MONTH_OF_YEAR_ID tinyint
,MONTH_OF_CAL_ID smallint
,QTR_OF_YEAR_ID tinyint
,QTR_OF_CAL_ID smallint
,YEAR_OF_CAL_ID smallint
,YEAR_END_DT string
,QTR_END_DT string
,MONTH_END_DT string
,WEEK_END_DT string
,CAL_DT_NAME string
,CAL_DT_DESC string
,CAL_DT_SHORT_NAME string
,YTD_YN_ID tinyint
,QTD_YN_ID tinyint
,MTD_YN_ID tinyint
,WTD_YN_ID tinyint
,SEASON_BEG_DT string
,DAY_IN_YEAR_COUNT smallint
,DAY_IN_QTR_COUNT tinyint
,DAY_IN_MONTH_COUNT tinyint
,DAY_IN_WEEK_COUNT tinyint
,RTL_YEAR_BEG_DT string
,RTL_QTR_BEG_DT string
,RTL_MONTH_BEG_DT string
,RTL_WEEK_BEG_DT string
,CS_WEEK_BEG_DT string
,CAL_DATE string
,DAY_OF_WEEK string
,MONTH_ID string
,PRD_DESC string
,PRD_FLAG string
,PRD_ID string
,PRD_IND string
,QTR_DESC string
,QTR_ID string
,QTR_IND string
,RETAIL_WEEK string
,RETAIL_YEAR string
,RETAIL_START_DATE string
,RETAIL_WK_END_DATE string
,WEEK_IND string
,WEEK_NUM_DESC string
,WEEK_BEG_DATE string
,WEEK_END_DATE string
,WEEK_IN_YEAR_ID string
,WEEK_ID string
,WEEK_BEG_END_DESC_MDY string
,WEEK_BEG_END_DESC_MD string
,YEAR_ID string
,YEAR_IND string
,CAL_DT_MNS_1YEAR_DT string
,CAL_DT_MNS_2YEAR_DT string
,CAL_DT_MNS_1QTR_DT string
,CAL_DT_MNS_2QTR_DT string
,CAL_DT_MNS_1MONTH_DT string
,CAL_DT_MNS_2MONTH_DT string
,CAL_DT_MNS_1WEEK_DT string
,CAL_DT_MNS_2WEEK_DT string
,CURR_CAL_DT_MNS_1YEAR_YN_ID tinyint
,CURR_CAL_DT_MNS_2YEAR_YN_ID tinyint
,CURR_CAL_DT_MNS_1QTR_YN_ID tinyint
,CURR_CAL_DT_MNS_2QTR_YN_ID tinyint
,CURR_CAL_DT_MNS_1MONTH_YN_ID tinyint
,CURR_CAL_DT_MNS_2MONTH_YN_ID tinyint
,CURR_CAL_DT_MNS_1WEEK_YN_IND tinyint
,CURR_CAL_DT_MNS_2WEEK_YN_IND tinyint
,RTL_MONTH_OF_RTL_YEAR_ID string
,RTL_QTR_OF_RTL_YEAR_ID tinyint
,RTL_WEEK_OF_RTL_YEAR_ID tinyint
,SEASON_OF_YEAR_ID tinyint
,YTM_YN_ID tinyint
,YTQ_YN_ID tinyint
,YTW_YN_ID tinyint
,KYLIN_CAL_DT_CRE_DATE string
,KYLIN_CAL_DT_CRE_USER string
,KYLIN_CAL_DT_UPD_DATE string
,KYLIN_CAL_DT_UPD_USER string
)
COMMENT 'Date Dimension Table'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

DROP TABLE IF EXISTS KYLIN_CATEGORY_GROUPINGS;

CREATE TABLE KYLIN_CATEGORY_GROUPINGS
(
LEAF_CATEG_ID bigint COMMENT 'Category ID, PK'
,LEAF_CATEG_NAME string
,SITE_ID int COMMENT 'Site ID, PK'
,CATEG_BUSN_MGR string
,CATEG_BUSN_UNIT string
,REGN_CATEG string
,USER_DEFINED_FIELD1 string COMMENT 'User Defined Field1'
,USER_DEFINED_FIELD3 string COMMENT 'User Defined Field3'
,KYLIN_GROUPINGS_CRE_DATE string
,KYLIN_GROUPINGS_UPD_DATE string COMMENT 'Last Updated Date'
,KYLIN_GROUPINGS_CRE_USER string
,KYLIN_GROUPINGS_UPD_USER string COMMENT 'Last Updated User'
,META_CATEG_ID decimal
,META_CATEG_NAME string COMMENT 'Level1 Category'
,CATEG_LVL2_ID decimal
,CATEG_LVL3_ID decimal
,CATEG_LVL4_ID decimal
,CATEG_LVL5_ID decimal
,CATEG_LVL6_ID decimal
,CATEG_LVL7_ID decimal
,CATEG_LVL2_NAME string COMMENT 'Level2 Category'
,CATEG_LVL3_NAME string COMMENT 'Level3 Category'
,CATEG_LVL4_NAME string
,CATEG_LVL5_NAME string
,CATEG_LVL6_NAME string
,CATEG_LVL7_NAME string
,CATEG_FLAGS decimal
,ADULT_CATEG_YN string
,DOMAIN_ID decimal
,USER_DEFINED_FIELD5 string
,VCS_ID decimal
,GCS_ID decimal
,MOVE_TO decimal
,SAP_CATEGORY_ID decimal
,SRC_ID tinyint
,BSNS_VRTCL_NAME string
)
COMMENT 'Detail category inforamtion, Dimension Table'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

DROP TABLE IF EXISTS KYLIN_COUNTRY;

CREATE TABLE KYLIN_COUNTRY
(
COUNTRY string
,LATITUDE double
,LONGITUDE double
,NAME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

DROP TABLE IF EXISTS KYLIN_ACCOUNT;

CREATE TABLE KYLIN_ACCOUNT
(
ACCOUNT_ID bigint
,ACCOUNT_BUYER_LEVEL int COMMENT 'Account Buyer Level'
,ACCOUNT_SELLER_LEVEL int COMMENT 'Account Seller Level'
,ACCOUNT_COUNTRY string COMMENT 'Account Country'
,ACCOUNT_CONTACT string COMMENT 'Account Contact Info'
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

DROP TABLE IF EXISTS KYLIN_SALES;

CREATE TABLE KYLIN_SALES
(
TRANS_ID bigint
,PART_DT date COMMENT 'Order Date'
,LSTG_FORMAT_NAME string COMMENT 'Order Transaction Type'
,LEAF_CATEG_ID bigint COMMENT 'Category ID'
,LSTG_SITE_ID int COMMENT 'Site ID'
,SLR_SEGMENT_CD smallint
,PRICE decimal(19,4) COMMENT 'Order Price'
,ITEM_COUNT bigint COMMENT 'Number of Purchased Goods'
,SELLER_ID bigint COMMENT 'Seller ID'
,BUYER_ID bigint COMMENT 'Buyer ID'
,OPS_USER_ID string COMMENT 'System User ID'
,OPS_REGION string COMMENT 'System User Region'
)
COMMENT 'Sales order table, fact table'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '${hdfs_tmp_dir}/sample_cube/data/DEFAULT.KYLIN_SALES.csv' OVERWRITE INTO TABLE KYLIN_SALES;
LOAD DATA INPATH '${hdfs_tmp_dir}/sample_cube/data/DEFAULT.KYLIN_ACCOUNT.csv' OVERWRITE INTO TABLE KYLIN_ACCOUNT;
LOAD DATA INPATH '${hdfs_tmp_dir}/sample_cube/data/DEFAULT.KYLIN_COUNTRY.csv' OVERWRITE INTO TABLE KYLIN_COUNTRY;
LOAD DATA INPATH '${hdfs_tmp_dir}/sample_cube/data/DEFAULT.KYLIN_CAL_DT.csv' OVERWRITE INTO TABLE KYLIN_CAL_DT;
LOAD DATA INPATH '${hdfs_tmp_dir}/sample_cube/data/DEFAULT.KYLIN_CATEGORY_GROUPINGS.csv' OVERWRITE INTO TABLE KYLIN_CATEGORY_GROUPINGS;
