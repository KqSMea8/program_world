DROP TABLE IF EXISTS src;
DROP TABLE IF EXISTS src1;
DROP TABLE IF EXISTS src_json;
DROP TABLE IF EXISTS src_sequencefile;
DROP TABLE IF EXISTS src_thrift;
DROP TABLE IF EXISTS srcbucket;
DROP TABLE IF EXISTS srcbucket2;
DROP TABLE IF EXISTS srcpart;
DROP TABLE IF EXISTS primitives;

--
-- Table src
--
DROP TABLE IF EXISTS src;

CREATE TABLE src (key STRING, value STRING) STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv1.txt" INTO TABLE src;

--
-- Table src1
--
DROP TABLE IF EXISTS src1;

CREATE TABLE src1 (key STRING, value STRING) STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv3.txt" INTO TABLE src1;

--
-- Table src_json
--
DROP TABLE IF EXISTS src_json;

CREATE TABLE src_json (json STRING) STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/json.txt" INTO TABLE src_json;


--
-- Table src_sequencefile
--
DROP TABLE IF EXISTS src_sequencefile;

CREATE TABLE src_sequencefile (key STRING, value STRING) STORED AS SEQUENCEFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv1.seq" INTO TABLE src_sequencefile;


--
-- Table src_thrift
--
DROP TABLE IF EXISTS src_thrift;

CREATE TABLE src_thrift
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.thrift.ThriftDeserializer'
WITH SERDEPROPERTIES (
  'serialization.class' = 'org.apache.hadoop.hive.serde2.thrift.test.Complex',
  'serialization.format' = 'com.facebook.thrift.protocol.TBinaryProtocol')
STORED AS SEQUENCEFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/complex.seq" INTO TABLE src_thrift;


--
-- Table srcbucket
--
DROP TABLE IF EXISTS srcbucket;

CREATE TABLE srcbucket (key INT, value STRING)
CLUSTERED BY (key) INTO 2 BUCKETS
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/srcbucket0.txt" INTO TABLE srcbucket;
LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/srcbucket1.txt" INTO TABLE srcbucket;


--
-- Table srcbucket2
--
DROP TABLE IF EXISTS srcbucket2;

CREATE TABLE srcbucket2 (key INT, value STRING)
CLUSTERED BY (key) INTO 4 BUCKETS
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/srcbucket20.txt" INTO TABLE srcbucket2;
LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/srcbucket21.txt" INTO TABLE srcbucket2;


--
-- Table srcpart
--
DROP TABLE IF EXISTS srcpart;

CREATE TABLE srcpart (key STRING, value STRING)
PARTITIONED BY (ds STRING, hr STRING)
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv1.txt"
OVERWRITE INTO TABLE srcpart PARTITION (ds="2008-04-08", hr="11");

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv1.txt"
OVERWRITE INTO TABLE srcpart PARTITION (ds="2008-04-08", hr="12");

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv1.txt"
OVERWRITE INTO TABLE srcpart PARTITION (ds="2008-04-09", hr="11");

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/kv1.txt"
OVERWRITE INTO TABLE srcpart PARTITION (ds="2008-04-09", hr="12");


DROP TABLE IF EXISTS primitives;
CREATE TABLE primitives (
  id INT,
  bool_col BOOLEAN,
  tinyint_col TINYINT,
  smallint_col SMALLINT,
  int_col INT,
  bigint_col BIGINT,
  float_col FLOAT,
  double_col DOUBLE,
  date_string_col STRING,
  string_col STRING,
  timestamp_col TIMESTAMP)
PARTITIONED BY (year INT, month INT)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  ESCAPED BY '\\'
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/types/primitives/090101.txt"
OVERWRITE INTO TABLE primitives PARTITION(year=2009, month=1);

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/types/primitives/090201.txt"
OVERWRITE INTO TABLE primitives PARTITION(year=2009, month=2);

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/types/primitives/090301.txt"
OVERWRITE INTO TABLE primitives PARTITION(year=2009, month=3);

LOAD DATA LOCAL INPATH "${hiveconf:test.data.dir}/types/primitives/090401.txt"
OVERWRITE INTO TABLE primitives PARTITION(year=2009, month=4);

create table tbl_created_by_init(i int);
WITH ss AS
(SELECT
    s_store_sk,
    sum(ss_ext_sales_price) AS sales,
    sum(ss_net_profit) AS profit
  FROM store_sales, date_dim, store
  WHERE ss_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-03' AS DATE) AND
  (cast('2000-08-03' AS DATE) + INTERVAL 30 days)
    AND ss_store_sk = s_store_sk
  GROUP BY s_store_sk),
    sr AS
  (SELECT
    s_store_sk,
    sum(sr_return_amt) AS returns,
    sum(sr_net_loss) AS profit_loss
  FROM store_returns, date_dim, store
  WHERE sr_returned_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-03' AS DATE) AND
  (cast('2000-08-03' AS DATE) + INTERVAL 30 days)
    AND sr_store_sk = s_store_sk
  GROUP BY s_store_sk),
    cs AS
  (SELECT
    cs_call_center_sk,
    sum(cs_ext_sales_price) AS sales,
    sum(cs_net_profit) AS profit
  FROM catalog_sales, date_dim
  WHERE cs_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-03' AS DATE) AND
  (cast('2000-08-03' AS DATE) + INTERVAL 30 days)
  GROUP BY cs_call_center_sk),
    cr AS
  (SELECT
    sum(cr_return_amount) AS returns,
    sum(cr_net_loss) AS profit_loss
  FROM catalog_returns, date_dim
  WHERE cr_returned_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-03' AS DATE) AND
  (cast('2000-08-03' AS DATE) + INTERVAL 30 days)),
    ws AS
  (SELECT
    wp_web_page_sk,
    sum(ws_ext_sales_price) AS sales,
    sum(ws_net_profit) AS profit
  FROM web_sales, date_dim, web_page
  WHERE ws_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-03' AS DATE) AND
  (cast('2000-08-03' AS DATE) + INTERVAL 30 days)
    AND ws_web_page_sk = wp_web_page_sk
  GROUP BY wp_web_page_sk),
    wr AS
  (SELECT
    wp_web_page_sk,
    sum(wr_return_amt) AS returns,
    sum(wr_net_loss) AS profit_loss
  FROM web_returns, date_dim, web_page
  WHERE wr_returned_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-03' AS DATE) AND
  (cast('2000-08-03' AS DATE) + INTERVAL 30 days)
    AND wr_web_page_sk = wp_web_page_sk
  GROUP BY wp_web_page_sk)
SELECT
  channel,
  id,
  sum(sales) AS sales,
  sum(returns) AS returns,
  sum(profit) AS profit
FROM
  (SELECT
     'store channel' AS channel,
     ss.s_store_sk AS id,
     sales,
     coalesce(returns, 0) AS returns,
     (profit - coalesce(profit_loss, 0)) AS profit
   FROM ss
     LEFT JOIN sr
       ON ss.s_store_sk = sr.s_store_sk
   UNION ALL
   SELECT
     'catalog channel' AS channel,
     cs_call_center_sk AS id,
     sales,
     returns,
     (profit - profit_loss) AS profit
   FROM cs, cr
   UNION ALL
   SELECT
     'web channel' AS channel,
     ws.wp_web_page_sk AS id,
     sales,
     coalesce(returns, 0) returns,
     (profit - coalesce(profit_loss, 0)) AS profit
   FROM ws
     LEFT JOIN wr
       ON ws.wp_web_page_sk = wr.wp_web_page_sk
  ) x
GROUP BY ROLLUP (channel, id)
ORDER BY channel, id
LIMIT 100
SELECT
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
FROM
  customer c, customer_address ca, customer_demographics
WHERE
  c.c_current_addr_sk = ca.ca_address_sk AND
    ca_county IN ('Rush County', 'Toole County', 'Jefferson County',
                  'Dona Ana County', 'La Porte County') AND
    cd_demo_sk = c.c_current_cdemo_sk AND
    exists(SELECT *
           FROM store_sales, date_dim
           WHERE c.c_customer_sk = ss_customer_sk AND
             ss_sold_date_sk = d_date_sk AND
             d_year = 2002 AND
             d_moy BETWEEN 1 AND 1 + 3) AND
    (exists(SELECT *
            FROM web_sales, date_dim
            WHERE c.c_customer_sk = ws_bill_customer_sk AND
              ws_sold_date_sk = d_date_sk AND
              d_year = 2002 AND
              d_moy BETWEEN 1 AND 1 + 3) OR
      exists(SELECT *
             FROM catalog_sales, date_dim
             WHERE c.c_customer_sk = cs_ship_customer_sk AND
               cs_sold_date_sk = d_date_sk AND
               d_year = 2002 AND
               d_moy BETWEEN 1 AND 1 + 3))
GROUP BY cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
ORDER BY cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
LIMIT 100
WITH cross_items AS
(SELECT i_item_sk ss_item_sk
  FROM item,
    (SELECT
      iss.i_brand_id brand_id,
      iss.i_class_id class_id,
      iss.i_category_id category_id
    FROM store_sales, item iss, date_dim d1
    WHERE ss_item_sk = iss.i_item_sk
      AND ss_sold_date_sk = d1.d_date_sk
      AND d1.d_year BETWEEN 1999 AND 1999 + 2
    INTERSECT
    SELECT
      ics.i_brand_id,
      ics.i_class_id,
      ics.i_category_id
    FROM catalog_sales, item ics, date_dim d2
    WHERE cs_item_sk = ics.i_item_sk
      AND cs_sold_date_sk = d2.d_date_sk
      AND d2.d_year BETWEEN 1999 AND 1999 + 2
    INTERSECT
    SELECT
      iws.i_brand_id,
      iws.i_class_id,
      iws.i_category_id
    FROM web_sales, item iws, date_dim d3
    WHERE ws_item_sk = iws.i_item_sk
      AND ws_sold_date_sk = d3.d_date_sk
      AND d3.d_year BETWEEN 1999 AND 1999 + 2) x
  WHERE i_brand_id = brand_id
    AND i_class_id = class_id
    AND i_category_id = category_id
),
    avg_sales AS
  (SELECT avg(quantity * list_price) average_sales
  FROM (SELECT
          ss_quantity quantity,
          ss_list_price list_price
        FROM store_sales, date_dim
        WHERE ss_sold_date_sk = d_date_sk AND d_year BETWEEN 1999 AND 1999 + 2
        UNION ALL
        SELECT
          cs_quantity quantity,
          cs_list_price list_price
        FROM catalog_sales, date_dim
        WHERE cs_sold_date_sk = d_date_sk AND d_year BETWEEN 1999 AND 1999 + 2
        UNION ALL
        SELECT
          ws_quantity quantity,
          ws_list_price list_price
        FROM web_sales, date_dim
        WHERE ws_sold_date_sk = d_date_sk AND d_year BETWEEN 1999 AND 1999 + 2) x)
SELECT *
FROM
  (SELECT
    'store' channel,
    i_brand_id,
    i_class_id,
    i_category_id,
    sum(ss_quantity * ss_list_price) sales,
    count(*) number_sales
  FROM store_sales, item, date_dim
  WHERE ss_item_sk IN (SELECT ss_item_sk
  FROM cross_items)
    AND ss_item_sk = i_item_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_week_seq = (SELECT d_week_seq
  FROM date_dim
  WHERE d_year = 1999 + 1 AND d_moy = 12 AND d_dom = 11)
  GROUP BY i_brand_id, i_class_id, i_category_id
  HAVING sum(ss_quantity * ss_list_price) > (SELECT average_sales
  FROM avg_sales)) this_year,
  (SELECT
    'store' channel,
    i_brand_id,
    i_class_id,
    i_category_id,
    sum(ss_quantity * ss_list_price) sales,
    count(*) number_sales
  FROM store_sales, item, date_dim
  WHERE ss_item_sk IN (SELECT ss_item_sk
  FROM cross_items)
    AND ss_item_sk = i_item_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_week_seq = (SELECT d_week_seq
  FROM date_dim
  WHERE d_year = 1999 AND d_moy = 12 AND d_dom = 11)
  GROUP BY i_brand_id, i_class_id, i_category_id
  HAVING sum(ss_quantity * ss_list_price) > (SELECT average_sales
  FROM avg_sales)) last_year
WHERE this_year.i_brand_id = last_year.i_brand_id
  AND this_year.i_class_id = last_year.i_class_id
  AND this_year.i_category_id = last_year.i_category_id
ORDER BY this_year.channel, this_year.i_brand_id, this_year.i_class_id, this_year.i_category_id
LIMIT 100
SELECT
  avg(ss_quantity),
  avg(ss_ext_sales_price),
  avg(ss_ext_wholesale_cost),
  sum(ss_ext_wholesale_cost)
FROM store_sales
  , store
  , customer_demographics
  , household_demographics
  , customer_address
  , date_dim
WHERE s_store_sk = ss_store_sk
  AND ss_sold_date_sk = d_date_sk AND d_year = 2001
  AND ((ss_hdemo_sk = hd_demo_sk
  AND cd_demo_sk = ss_cdemo_sk
  AND cd_marital_status = 'M'
  AND cd_education_status = 'Advanced Degree'
  AND ss_sales_price BETWEEN 100.00 AND 150.00
  AND hd_dep_count = 3
) OR
  (ss_hdemo_sk = hd_demo_sk
    AND cd_demo_sk = ss_cdemo_sk
    AND cd_marital_status = 'S'
    AND cd_education_status = 'College'
    AND ss_sales_price BETWEEN 50.00 AND 100.00
    AND hd_dep_count = 1
  ) OR
  (ss_hdemo_sk = hd_demo_sk
    AND cd_demo_sk = ss_cdemo_sk
    AND cd_marital_status = 'W'
    AND cd_education_status = '2 yr Degree'
    AND ss_sales_price BETWEEN 150.00 AND 200.00
    AND hd_dep_count = 1
  ))
  AND ((ss_addr_sk = ca_address_sk
  AND ca_country = 'United States'
  AND ca_state IN ('TX', 'OH', 'TX')
  AND ss_net_profit BETWEEN 100 AND 200
) OR
  (ss_addr_sk = ca_address_sk
    AND ca_country = 'United States'
    AND ca_state IN ('OR', 'NM', 'KY')
    AND ss_net_profit BETWEEN 150 AND 300
  ) OR
  (ss_addr_sk = ca_address_sk
    AND ca_country = 'United States'
    AND ca_state IN ('VA', 'TX', 'MS')
    AND ss_net_profit BETWEEN 50 AND 250
  ))
SELECT
  substr(r_reason_desc, 1, 20),
  avg(ws_quantity),
  avg(wr_refunded_cash),
  avg(wr_fee)
FROM web_sales, web_returns, web_page, customer_demographics cd1,
  customer_demographics cd2, customer_address, date_dim, reason
WHERE ws_web_page_sk = wp_web_page_sk
  AND ws_item_sk = wr_item_sk
  AND ws_order_number = wr_order_number
  AND ws_sold_date_sk = d_date_sk AND d_year = 2000
  AND cd1.cd_demo_sk = wr_refunded_cdemo_sk
  AND cd2.cd_demo_sk = wr_returning_cdemo_sk
  AND ca_address_sk = wr_refunded_addr_sk
  AND r_reason_sk = wr_reason_sk
  AND
  (
    (
      cd1.cd_marital_status = 'M'
        AND
        cd1.cd_marital_status = cd2.cd_marital_status
        AND
        cd1.cd_education_status = 'Advanced Degree'
        AND
        cd1.cd_education_status = cd2.cd_education_status
        AND
        ws_sales_price BETWEEN 100.00 AND 150.00
    )
      OR
      (
        cd1.cd_marital_status = 'S'
          AND
          cd1.cd_marital_status = cd2.cd_marital_status
          AND
          cd1.cd_education_status = 'College'
          AND
          cd1.cd_education_status = cd2.cd_education_status
          AND
          ws_sales_price BETWEEN 50.00 AND 100.00
      )
      OR
      (
        cd1.cd_marital_status = 'W'
          AND
          cd1.cd_marital_status = cd2.cd_marital_status
          AND
          cd1.cd_education_status = '2 yr Degree'
          AND
          cd1.cd_education_status = cd2.cd_education_status
          AND
          ws_sales_price BETWEEN 150.00 AND 200.00
      )
  )
  AND
  (
    (
      ca_country = 'United States'
        AND
        ca_state IN ('IN', 'OH', 'NJ')
        AND ws_net_profit BETWEEN 100 AND 200
    )
      OR
      (
        ca_country = 'United States'
          AND
          ca_state IN ('WI', 'CT', 'KY')
          AND ws_net_profit BETWEEN 150 AND 300
      )
      OR
      (
        ca_country = 'United States'
          AND
          ca_state IN ('LA', 'IA', 'AR')
          AND ws_net_profit BETWEEN 50 AND 250
      )
  )
GROUP BY r_reason_desc
ORDER BY substr(r_reason_desc, 1, 20)
  , avg(ws_quantity)
  , avg(wr_refunded_cash)
  , avg(wr_fee)
LIMIT 100
WITH ss AS (
  SELECT
    i_manufact_id,
    sum(ss_ext_sales_price) total_sales
  FROM
    store_sales, date_dim, customer_address, item
  WHERE
    i_manufact_id IN (SELECT i_manufact_id
    FROM item
    WHERE i_category IN ('Electronics'))
      AND ss_item_sk = i_item_sk
      AND ss_sold_date_sk = d_date_sk
      AND d_year = 1998
      AND d_moy = 5
      AND ss_addr_sk = ca_address_sk
      AND ca_gmt_offset = -5
  GROUP BY i_manufact_id), cs AS
(SELECT
    i_manufact_id,
    sum(cs_ext_sales_price) total_sales
  FROM catalog_sales, date_dim, customer_address, item
  WHERE
    i_manufact_id IN (
      SELECT i_manufact_id
      FROM item
      WHERE
        i_category IN ('Electronics'))
      AND cs_item_sk = i_item_sk
      AND cs_sold_date_sk = d_date_sk
      AND d_year = 1998
      AND d_moy = 5
      AND cs_bill_addr_sk = ca_address_sk
      AND ca_gmt_offset = -5
  GROUP BY i_manufact_id),
    ws AS (
    SELECT
      i_manufact_id,
      sum(ws_ext_sales_price) total_sales
    FROM
      web_sales, date_dim, customer_address, item
    WHERE
      i_manufact_id IN (SELECT i_manufact_id
      FROM item
      WHERE i_category IN ('Electronics'))
        AND ws_item_sk = i_item_sk
        AND ws_sold_date_sk = d_date_sk
        AND d_year = 1998
        AND d_moy = 5
        AND ws_bill_addr_sk = ca_address_sk
        AND ca_gmt_offset = -5
    GROUP BY i_manufact_id)
SELECT
  i_manufact_id,
  sum(total_sales) total_sales
FROM (SELECT *
      FROM ss
      UNION ALL
      SELECT *
      FROM cs
      UNION ALL
      SELECT *
      FROM ws) tmp1
GROUP BY i_manufact_id
ORDER BY total_sales
LIMIT 100
WITH ssr AS
( SELECT
    s_store_id,
    sum(sales_price) AS sales,
    sum(profit) AS profit,
    sum(return_amt) AS RETURNS,
    sum(net_loss) AS profit_loss
  FROM
    (SELECT
       ss_store_sk AS store_sk,
       ss_sold_date_sk AS date_sk,
       ss_ext_sales_price AS sales_price,
       ss_net_profit AS profit,
       cast(0 AS DECIMAL(7, 2)) AS return_amt,
       cast(0 AS DECIMAL(7, 2)) AS net_loss
     FROM store_sales
     UNION ALL
     SELECT
       sr_store_sk AS store_sk,
       sr_returned_date_sk AS date_sk,
       cast(0 AS DECIMAL(7, 2)) AS sales_price,
       cast(0 AS DECIMAL(7, 2)) AS profit,
       sr_return_amt AS return_amt,
       sr_net_loss AS net_loss
     FROM store_returns)
    salesreturns, date_dim, store
  WHERE date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-23' AS DATE)
  AND ((cast('2000-08-23' AS DATE) + INTERVAL 14 days))
    AND store_sk = s_store_sk
  GROUP BY s_store_id),
    csr AS
  ( SELECT
    cp_catalog_page_id,
    sum(sales_price) AS sales,
    sum(profit) AS profit,
    sum(return_amt) AS RETURNS,
    sum(net_loss) AS profit_loss
  FROM
    (SELECT
       cs_catalog_page_sk AS page_sk,
       cs_sold_date_sk AS date_sk,
       cs_ext_sales_price AS sales_price,
       cs_net_profit AS profit,
       cast(0 AS DECIMAL(7, 2)) AS return_amt,
       cast(0 AS DECIMAL(7, 2)) AS net_loss
     FROM catalog_sales
     UNION ALL
     SELECT
       cr_catalog_page_sk AS page_sk,
       cr_returned_date_sk AS date_sk,
       cast(0 AS DECIMAL(7, 2)) AS sales_price,
       cast(0 AS DECIMAL(7, 2)) AS profit,
       cr_return_amount AS return_amt,
       cr_net_loss AS net_loss
     FROM catalog_returns
    ) salesreturns, date_dim, catalog_page
  WHERE date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-23' AS DATE)
  AND ((cast('2000-08-23' AS DATE) + INTERVAL 14 days))
    AND page_sk = cp_catalog_page_sk
  GROUP BY cp_catalog_page_id)
  ,
    wsr AS
  ( SELECT
    web_site_id,
    sum(sales_price) AS sales,
    sum(profit) AS profit,
    sum(return_amt) AS RETURNS,
    sum(net_loss) AS profit_loss
  FROM
    (SELECT
       ws_web_site_sk AS wsr_web_site_sk,
       ws_sold_date_sk AS date_sk,
       ws_ext_sales_price AS sales_price,
       ws_net_profit AS profit,
       cast(0 AS DECIMAL(7, 2)) AS return_amt,
       cast(0 AS DECIMAL(7, 2)) AS net_loss
     FROM web_sales
     UNION ALL
     SELECT
       ws_web_site_sk AS wsr_web_site_sk,
       wr_returned_date_sk AS date_sk,
       cast(0 AS DECIMAL(7, 2)) AS sales_price,
       cast(0 AS DECIMAL(7, 2)) AS profit,
       wr_return_amt AS return_amt,
       wr_net_loss AS net_loss
     FROM web_returns
       LEFT OUTER JOIN web_sales ON
                                   (wr_item_sk = ws_item_sk
                                     AND wr_order_number = ws_order_number)
    ) salesreturns, date_dim, web_site
  WHERE date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-23' AS DATE)
  AND ((cast('2000-08-23' AS DATE) + INTERVAL 14 days))
    AND wsr_web_site_sk = web_site_sk
  GROUP BY web_site_id)
SELECT
  channel,
  id,
  sum(sales) AS sales,
  sum(returns) AS returns,
  sum(profit) AS profit
FROM
  (SELECT
     'store channel' AS channel,
     concat('store', s_store_id) AS id,
     sales,
     returns,
     (profit - profit_loss) AS profit
   FROM ssr
   UNION ALL
   SELECT
     'catalog channel' AS channel,
     concat('catalog_page', cp_catalog_page_id) AS id,
     sales,
     returns,
     (profit - profit_loss) AS profit
   FROM csr
   UNION ALL
   SELECT
     'web channel' AS channel,
     concat('web_site', web_site_id) AS id,
     sales,
     returns,
     (profit - profit_loss) AS profit
   FROM wsr
  ) x
GROUP BY ROLLUP (channel, id)
ORDER BY channel, id
LIMIT 100
SELECT *
FROM (
       SELECT
         w_warehouse_name,
         i_item_id,
         sum(CASE WHEN (cast(d_date AS DATE) < cast('2000-03-11' AS DATE))
           THEN inv_quantity_on_hand
             ELSE 0 END) AS inv_before,
         sum(CASE WHEN (cast(d_date AS DATE) >= cast('2000-03-11' AS DATE))
           THEN inv_quantity_on_hand
             ELSE 0 END) AS inv_after
       FROM inventory, warehouse, item, date_dim
       WHERE i_current_price BETWEEN 0.99 AND 1.49
         AND i_item_sk = inv_item_sk
         AND inv_warehouse_sk = w_warehouse_sk
         AND inv_date_sk = d_date_sk
         AND d_date BETWEEN (cast('2000-03-11' AS DATE) - INTERVAL 30 days)
       AND (cast('2000-03-11' AS DATE) + INTERVAL 30 days)
       GROUP BY w_warehouse_name, i_item_id) x
WHERE (CASE WHEN inv_before > 0
  THEN inv_after / inv_before
       ELSE NULL
       END) BETWEEN 2.0 / 3.0 AND 3.0 / 2.0
ORDER BY w_warehouse_name, i_item_id
LIMIT 100
WITH ss AS (
  SELECT
    i_item_id,
    sum(ss_ext_sales_price) total_sales
  FROM store_sales, date_dim, customer_address, item
  WHERE
    i_item_id IN (SELECT i_item_id
    FROM item
    WHERE i_category IN ('Music'))
      AND ss_item_sk = i_item_sk
      AND ss_sold_date_sk = d_date_sk
      AND d_year = 1998
      AND d_moy = 9
      AND ss_addr_sk = ca_address_sk
      AND ca_gmt_offset = -5
  GROUP BY i_item_id),
    cs AS (
    SELECT
      i_item_id,
      sum(cs_ext_sales_price) total_sales
    FROM catalog_sales, date_dim, customer_address, item
    WHERE
      i_item_id IN (SELECT i_item_id
      FROM item
      WHERE i_category IN ('Music'))
        AND cs_item_sk = i_item_sk
        AND cs_sold_date_sk = d_date_sk
        AND d_year = 1998
        AND d_moy = 9
        AND cs_bill_addr_sk = ca_address_sk
        AND ca_gmt_offset = -5
    GROUP BY i_item_id),
    ws AS (
    SELECT
      i_item_id,
      sum(ws_ext_sales_price) total_sales
    FROM web_sales, date_dim, customer_address, item
    WHERE
      i_item_id IN (SELECT i_item_id
      FROM item
      WHERE i_category IN ('Music'))
        AND ws_item_sk = i_item_sk
        AND ws_sold_date_sk = d_date_sk
        AND d_year = 1998
        AND d_moy = 9
        AND ws_bill_addr_sk = ca_address_sk
        AND ca_gmt_offset = -5
    GROUP BY i_item_id)
SELECT
  i_item_id,
  sum(total_sales) total_sales
FROM (SELECT *
      FROM ss
      UNION ALL
      SELECT *
      FROM cs
      UNION ALL
      SELECT *
      FROM ws) tmp1
GROUP BY i_item_id
ORDER BY i_item_id, total_sales
LIMIT 100
SELECT
  promotions,
  total,
  cast(promotions AS DECIMAL(15, 4)) / cast(total AS DECIMAL(15, 4)) * 100
FROM
  (SELECT sum(ss_ext_sales_price) promotions
  FROM store_sales, store, promotion, date_dim, customer, customer_address, item
  WHERE ss_sold_date_sk = d_date_sk
    AND ss_store_sk = s_store_sk
    AND ss_promo_sk = p_promo_sk
    AND ss_customer_sk = c_customer_sk
    AND ca_address_sk = c_current_addr_sk
    AND ss_item_sk = i_item_sk
    AND ca_gmt_offset = -5
    AND i_category = 'Jewelry'
    AND (p_channel_dmail = 'Y' OR p_channel_email = 'Y' OR p_channel_tv = 'Y')
    AND s_gmt_offset = -5
    AND d_year = 1998
    AND d_moy = 11) promotional_sales,
  (SELECT sum(ss_ext_sales_price) total
  FROM store_sales, store, date_dim, customer, customer_address, item
  WHERE ss_sold_date_sk = d_date_sk
    AND ss_store_sk = s_store_sk
    AND ss_customer_sk = c_customer_sk
    AND ca_address_sk = c_current_addr_sk
    AND ss_item_sk = i_item_sk
    AND ca_gmt_offset = -5
    AND i_category = 'Jewelry'
    AND s_gmt_offset = -5
    AND d_year = 1998
    AND d_moy = 11) all_sales
ORDER BY promotions, total
LIMIT 100
WITH ss AS (
  SELECT
    i_item_id,
    sum(ss_ext_sales_price) total_sales
  FROM
    store_sales, date_dim, customer_address, item
  WHERE
    i_item_id IN (SELECT i_item_id
    FROM item
    WHERE i_color IN ('slate', 'blanched', 'burnished'))
      AND ss_item_sk = i_item_sk
      AND ss_sold_date_sk = d_date_sk
      AND d_year = 2001
      AND d_moy = 2
      AND ss_addr_sk = ca_address_sk
      AND ca_gmt_offset = -5
  GROUP BY i_item_id),
    cs AS (
    SELECT
      i_item_id,
      sum(cs_ext_sales_price) total_sales
    FROM
      catalog_sales, date_dim, customer_address, item
    WHERE
      i_item_id IN (SELECT i_item_id
      FROM item
      WHERE i_color IN ('slate', 'blanched', 'burnished'))
        AND cs_item_sk = i_item_sk
        AND cs_sold_date_sk = d_date_sk
        AND d_year = 2001
        AND d_moy = 2
        AND cs_bill_addr_sk = ca_address_sk
        AND ca_gmt_offset = -5
    GROUP BY i_item_id),
    ws AS (
    SELECT
      i_item_id,
      sum(ws_ext_sales_price) total_sales
    FROM
      web_sales, date_dim, customer_address, item
    WHERE
      i_item_id IN (SELECT i_item_id
      FROM item
      WHERE i_color IN ('slate', 'blanched', 'burnished'))
        AND ws_item_sk = i_item_sk
        AND ws_sold_date_sk = d_date_sk
        AND d_year = 2001
        AND d_moy = 2
        AND ws_bill_addr_sk = ca_address_sk
        AND ca_gmt_offset = -5
    GROUP BY i_item_id)
SELECT
  i_item_id,
  sum(total_sales) total_sales
FROM (SELECT *
      FROM ss
      UNION ALL
      SELECT *
      FROM cs
      UNION ALL
      SELECT *
      FROM ws) tmp1
GROUP BY i_item_id
ORDER BY total_sales
LIMIT 100
WITH customer_total_return AS
( SELECT
    sr_customer_sk AS ctr_customer_sk,
    sr_store_sk AS ctr_store_sk,
    sum(sr_return_amt) AS ctr_total_return
  FROM store_returns, date_dim
  WHERE sr_returned_date_sk = d_date_sk AND d_year = 2000
  GROUP BY sr_customer_sk, sr_store_sk)
SELECT c_customer_id
FROM customer_total_return ctr1, store, customer
WHERE ctr1.ctr_total_return >
  (SELECT avg(ctr_total_return) * 1.2
  FROM customer_total_return ctr2
  WHERE ctr1.ctr_store_sk = ctr2.ctr_store_sk)
  AND s_store_sk = ctr1.ctr_store_sk
  AND s_state = 'TN'
  AND ctr1.ctr_customer_sk = c_customer_sk
ORDER BY c_customer_id
LIMIT 100
SELECT
  i_brand_id brand_id,
  i_brand brand,
  sum(ss_ext_sales_price) ext_price
FROM date_dim, store_sales, item
WHERE d_date_sk = ss_sold_date_sk
  AND ss_item_sk = i_item_sk
  AND i_manager_id = 28
  AND d_moy = 11
  AND d_year = 1999
GROUP BY i_brand, i_brand_id
ORDER BY ext_price DESC, brand_id
LIMIT 100
SELECT
  cc_call_center_id Call_Center,
  cc_name Call_Center_Name,
  cc_manager Manager,
  sum(cr_net_loss) Returns_Loss
FROM
  call_center, catalog_returns, date_dim, customer, customer_address,
  customer_demographics, household_demographics
WHERE
  cr_call_center_sk = cc_call_center_sk
    AND cr_returned_date_sk = d_date_sk
    AND cr_returning_customer_sk = c_customer_sk
    AND cd_demo_sk = c_current_cdemo_sk
    AND hd_demo_sk = c_current_hdemo_sk
    AND ca_address_sk = c_current_addr_sk
    AND d_year = 1998
    AND d_moy = 11
    AND ((cd_marital_status = 'M' AND cd_education_status = 'Unknown')
    OR (cd_marital_status = 'W' AND cd_education_status = 'Advanced Degree'))
    AND hd_buy_potential LIKE 'Unknown%'
    AND ca_gmt_offset = -7
GROUP BY cc_call_center_id, cc_name, cc_manager, cd_marital_status, cd_education_status
ORDER BY sum(cr_net_loss) DESC
SELECT
  i_item_id,
  avg(ss_quantity) agg1,
  avg(ss_list_price) agg2,
  avg(ss_coupon_amt) agg3,
  avg(ss_sales_price) agg4
FROM store_sales, customer_demographics, date_dim, item, promotion
WHERE ss_sold_date_sk = d_date_sk AND
  ss_item_sk = i_item_sk AND
  ss_cdemo_sk = cd_demo_sk AND
  ss_promo_sk = p_promo_sk AND
  cd_gender = 'M' AND
  cd_marital_status = 'S' AND
  cd_education_status = 'College' AND
  (p_channel_email = 'N' OR p_channel_event = 'N') AND
  d_year = 2000
GROUP BY i_item_id
ORDER BY i_item_id
LIMIT 100
SELECT
  i_item_id,
  s_state,
  grouping(s_state) g_state,
  avg(ss_quantity) agg1,
  avg(ss_list_price) agg2,
  avg(ss_coupon_amt) agg3,
  avg(ss_sales_price) agg4
FROM store_sales, customer_demographics, date_dim, store, item
WHERE ss_sold_date_sk = d_date_sk AND
  ss_item_sk = i_item_sk AND
  ss_store_sk = s_store_sk AND
  ss_cdemo_sk = cd_demo_sk AND
  cd_gender = 'M' AND
  cd_marital_status = 'S' AND
  cd_education_status = 'College' AND
  d_year = 2002 AND
  s_state IN ('TN', 'TN', 'TN', 'TN', 'TN', 'TN')
GROUP BY ROLLUP (i_item_id, s_state)
ORDER BY i_item_id, s_state
LIMIT 100
WITH cs_ui AS
(SELECT
    cs_item_sk,
    sum(cs_ext_list_price) AS sale,
    sum(cr_refunded_cash + cr_reversed_charge + cr_store_credit) AS refund
  FROM catalog_sales
    , catalog_returns
  WHERE cs_item_sk = cr_item_sk
    AND cs_order_number = cr_order_number
  GROUP BY cs_item_sk
  HAVING sum(cs_ext_list_price) > 2 * sum(cr_refunded_cash + cr_reversed_charge + cr_store_credit)),
    cross_sales AS
  (SELECT
    i_product_name product_name,
    i_item_sk item_sk,
    s_store_name store_name,
    s_zip store_zip,
    ad1.ca_street_number b_street_number,
    ad1.ca_street_name b_streen_name,
    ad1.ca_city b_city,
    ad1.ca_zip b_zip,
    ad2.ca_street_number c_street_number,
    ad2.ca_street_name c_street_name,
    ad2.ca_city c_city,
    ad2.ca_zip c_zip,
    d1.d_year AS syear,
    d2.d_year AS fsyear,
    d3.d_year s2year,
    count(*) cnt,
    sum(ss_wholesale_cost) s1,
    sum(ss_list_price) s2,
    sum(ss_coupon_amt) s3
  FROM store_sales, store_returns, cs_ui, date_dim d1, date_dim d2, date_dim d3,
    store, customer, customer_demographics cd1, customer_demographics cd2,
    promotion, household_demographics hd1, household_demographics hd2,
    customer_address ad1, customer_address ad2, income_band ib1, income_band ib2, item
  WHERE ss_store_sk = s_store_sk AND
    ss_sold_date_sk = d1.d_date_sk AND
    ss_customer_sk = c_customer_sk AND
    ss_cdemo_sk = cd1.cd_demo_sk AND
    ss_hdemo_sk = hd1.hd_demo_sk AND
    ss_addr_sk = ad1.ca_address_sk AND
    ss_item_sk = i_item_sk AND
    ss_item_sk = sr_item_sk AND
    ss_ticket_number = sr_ticket_number AND
    ss_item_sk = cs_ui.cs_item_sk AND
    c_current_cdemo_sk = cd2.cd_demo_sk AND
    c_current_hdemo_sk = hd2.hd_demo_sk AND
    c_current_addr_sk = ad2.ca_address_sk AND
    c_first_sales_date_sk = d2.d_date_sk AND
    c_first_shipto_date_sk = d3.d_date_sk AND
    ss_promo_sk = p_promo_sk AND
    hd1.hd_income_band_sk = ib1.ib_income_band_sk AND
    hd2.hd_income_band_sk = ib2.ib_income_band_sk AND
    cd1.cd_marital_status <> cd2.cd_marital_status AND
    i_color IN ('purple', 'burlywood', 'indian', 'spring', 'floral', 'medium') AND
    i_current_price BETWEEN 64 AND 64 + 10 AND
    i_current_price BETWEEN 64 + 1 AND 64 + 15
  GROUP BY i_product_name, i_item_sk, s_store_name, s_zip, ad1.ca_street_number,
    ad1.ca_street_name, ad1.ca_city, ad1.ca_zip, ad2.ca_street_number,
    ad2.ca_street_name, ad2.ca_city, ad2.ca_zip, d1.d_year, d2.d_year, d3.d_year
  )
SELECT
  cs1.product_name,
  cs1.store_name,
  cs1.store_zip,
  cs1.b_street_number,
  cs1.b_streen_name,
  cs1.b_city,
  cs1.b_zip,
  cs1.c_street_number,
  cs1.c_street_name,
  cs1.c_city,
  cs1.c_zip,
  cs1.syear,
  cs1.cnt,
  cs1.s1,
  cs1.s2,
  cs1.s3,
  cs2.s1,
  cs2.s2,
  cs2.s3,
  cs2.syear,
  cs2.cnt
FROM cross_sales cs1, cross_sales cs2
WHERE cs1.item_sk = cs2.item_sk AND
  cs1.syear = 1999 AND
  cs2.syear = 1999 + 1 AND
  cs2.cnt <= cs1.cnt AND
  cs1.store_name = cs2.store_name AND
  cs1.store_zip = cs2.store_zip
ORDER BY cs1.product_name, cs1.store_name, cs2.cnt
SELECT
  CASE WHEN (SELECT count(*)
  FROM store_sales
  WHERE ss_quantity BETWEEN 1 AND 20) > 62316685
    THEN (SELECT avg(ss_ext_discount_amt)
    FROM store_sales
    WHERE ss_quantity BETWEEN 1 AND 20)
  ELSE (SELECT avg(ss_net_paid)
  FROM store_sales
  WHERE ss_quantity BETWEEN 1 AND 20) END bucket1,
  CASE WHEN (SELECT count(*)
  FROM store_sales
  WHERE ss_quantity BETWEEN 21 AND 40) > 19045798
    THEN (SELECT avg(ss_ext_discount_amt)
    FROM store_sales
    WHERE ss_quantity BETWEEN 21 AND 40)
  ELSE (SELECT avg(ss_net_paid)
  FROM store_sales
  WHERE ss_quantity BETWEEN 21 AND 40) END bucket2,
  CASE WHEN (SELECT count(*)
  FROM store_sales
  WHERE ss_quantity BETWEEN 41 AND 60) > 365541424
    THEN (SELECT avg(ss_ext_discount_amt)
    FROM store_sales
    WHERE ss_quantity BETWEEN 41 AND 60)
  ELSE (SELECT avg(ss_net_paid)
  FROM store_sales
  WHERE ss_quantity BETWEEN 41 AND 60) END bucket3,
  CASE WHEN (SELECT count(*)
  FROM store_sales
  WHERE ss_quantity BETWEEN 61 AND 80) > 216357808
    THEN (SELECT avg(ss_ext_discount_amt)
    FROM store_sales
    WHERE ss_quantity BETWEEN 61 AND 80)
  ELSE (SELECT avg(ss_net_paid)
  FROM store_sales
  WHERE ss_quantity BETWEEN 61 AND 80) END bucket4,
  CASE WHEN (SELECT count(*)
  FROM store_sales
  WHERE ss_quantity BETWEEN 81 AND 100) > 184483884
    THEN (SELECT avg(ss_ext_discount_amt)
    FROM store_sales
    WHERE ss_quantity BETWEEN 81 AND 100)
  ELSE (SELECT avg(ss_net_paid)
  FROM store_sales
  WHERE ss_quantity BETWEEN 81 AND 100) END bucket5
FROM reason
WHERE r_reason_sk = 1
SELECT
  dt.d_year,
  item.i_category_id,
  item.i_category,
  sum(ss_ext_sales_price)
FROM date_dim dt, store_sales, item
WHERE dt.d_date_sk = store_sales.ss_sold_date_sk
  AND store_sales.ss_item_sk = item.i_item_sk
  AND item.i_manager_id = 1
  AND dt.d_moy = 11
  AND dt.d_year = 2000
GROUP BY dt.d_year
  , item.i_category_id
  , item.i_category
ORDER BY sum(ss_ext_sales_price) DESC, dt.d_year
  , item.i_category_id
  , item.i_category
LIMIT 100
SELECT
  i_item_desc,
  w_warehouse_name,
  d1.d_week_seq,
  count(CASE WHEN p_promo_sk IS NULL
    THEN 1
        ELSE 0 END) no_promo,
  count(CASE WHEN p_promo_sk IS NOT NULL
    THEN 1
        ELSE 0 END) promo,
  count(*) total_cnt
FROM catalog_sales
  JOIN inventory ON (cs_item_sk = inv_item_sk)
  JOIN warehouse ON (w_warehouse_sk = inv_warehouse_sk)
  JOIN item ON (i_item_sk = cs_item_sk)
  JOIN customer_demographics ON (cs_bill_cdemo_sk = cd_demo_sk)
  JOIN household_demographics ON (cs_bill_hdemo_sk = hd_demo_sk)
  JOIN date_dim d1 ON (cs_sold_date_sk = d1.d_date_sk)
  JOIN date_dim d2 ON (inv_date_sk = d2.d_date_sk)
  JOIN date_dim d3 ON (cs_ship_date_sk = d3.d_date_sk)
  LEFT OUTER JOIN promotion ON (cs_promo_sk = p_promo_sk)
  LEFT OUTER JOIN catalog_returns ON (cr_item_sk = cs_item_sk AND cr_order_number = cs_order_number)
WHERE d1.d_week_seq = d2.d_week_seq
  AND inv_quantity_on_hand < cs_quantity
  AND d3.d_date > (cast(d1.d_date AS DATE) + interval 5 days)
  AND hd_buy_potential = '>10000'
  AND d1.d_year = 1999
  AND hd_buy_potential = '>10000'
  AND cd_marital_status = 'D'
  AND d1.d_year = 1999
GROUP BY i_item_desc, w_warehouse_name, d1.d_week_seq
ORDER BY total_cnt DESC, i_item_desc, w_warehouse_name, d_week_seq
LIMIT 100
WITH wss AS
(SELECT
    d_week_seq,
    ss_store_sk,
    sum(CASE WHEN (d_day_name = 'Sunday')
      THEN ss_sales_price
        ELSE NULL END) sun_sales,
    sum(CASE WHEN (d_day_name = 'Monday')
      THEN ss_sales_price
        ELSE NULL END) mon_sales,
    sum(CASE WHEN (d_day_name = 'Tuesday')
      THEN ss_sales_price
        ELSE NULL END) tue_sales,
    sum(CASE WHEN (d_day_name = 'Wednesday')
      THEN ss_sales_price
        ELSE NULL END) wed_sales,
    sum(CASE WHEN (d_day_name = 'Thursday')
      THEN ss_sales_price
        ELSE NULL END) thu_sales,
    sum(CASE WHEN (d_day_name = 'Friday')
      THEN ss_sales_price
        ELSE NULL END) fri_sales,
    sum(CASE WHEN (d_day_name = 'Saturday')
      THEN ss_sales_price
        ELSE NULL END) sat_sales
  FROM store_sales, date_dim
  WHERE d_date_sk = ss_sold_date_sk
  GROUP BY d_week_seq, ss_store_sk
)
SELECT
  s_store_name1,
  s_store_id1,
  d_week_seq1,
  sun_sales1 / sun_sales2,
  mon_sales1 / mon_sales2,
  tue_sales1 / tue_sales2,
  wed_sales1 / wed_sales2,
  thu_sales1 / thu_sales2,
  fri_sales1 / fri_sales2,
  sat_sales1 / sat_sales2
FROM
  (SELECT
    s_store_name s_store_name1,
    wss.d_week_seq d_week_seq1,
    s_store_id s_store_id1,
    sun_sales sun_sales1,
    mon_sales mon_sales1,
    tue_sales tue_sales1,
    wed_sales wed_sales1,
    thu_sales thu_sales1,
    fri_sales fri_sales1,
    sat_sales sat_sales1
  FROM wss, store, date_dim d
  WHERE d.d_week_seq = wss.d_week_seq AND
    ss_store_sk = s_store_sk AND
    d_month_seq BETWEEN 1212 AND 1212 + 11) y,
  (SELECT
    s_store_name s_store_name2,
    wss.d_week_seq d_week_seq2,
    s_store_id s_store_id2,
    sun_sales sun_sales2,
    mon_sales mon_sales2,
    tue_sales tue_sales2,
    wed_sales wed_sales2,
    thu_sales thu_sales2,
    fri_sales fri_sales2,
    sat_sales sat_sales2
  FROM wss, store, date_dim d
  WHERE d.d_week_seq = wss.d_week_seq AND
    ss_store_sk = s_store_sk AND
    d_month_seq BETWEEN 1212 + 12 AND 1212 + 23) x
WHERE s_store_id1 = s_store_id2
  AND d_week_seq1 = d_week_seq2 - 52
ORDER BY s_store_name1, s_store_id1, d_week_seq1
LIMIT 100
WITH wscs AS
( SELECT
    sold_date_sk,
    sales_price
  FROM (SELECT
    ws_sold_date_sk sold_date_sk,
    ws_ext_sales_price sales_price
  FROM web_sales) x
  UNION ALL
  (SELECT
    cs_sold_date_sk sold_date_sk,
    cs_ext_sales_price sales_price
  FROM catalog_sales)),
    wswscs AS
  ( SELECT
    d_week_seq,
    sum(CASE WHEN (d_day_name = 'Sunday')
      THEN sales_price
        ELSE NULL END)
    sun_sales,
    sum(CASE WHEN (d_day_name = 'Monday')
      THEN sales_price
        ELSE NULL END)
    mon_sales,
    sum(CASE WHEN (d_day_name = 'Tuesday')
      THEN sales_price
        ELSE NULL END)
    tue_sales,
    sum(CASE WHEN (d_day_name = 'Wednesday')
      THEN sales_price
        ELSE NULL END)
    wed_sales,
    sum(CASE WHEN (d_day_name = 'Thursday')
      THEN sales_price
        ELSE NULL END)
    thu_sales,
    sum(CASE WHEN (d_day_name = 'Friday')
      THEN sales_price
        ELSE NULL END)
    fri_sales,
    sum(CASE WHEN (d_day_name = 'Saturday')
      THEN sales_price
        ELSE NULL END)
    sat_sales
  FROM wscs, date_dim
  WHERE d_date_sk = sold_date_sk
  GROUP BY d_week_seq)
SELECT
  d_week_seq1,
  round(sun_sales1 / sun_sales2, 2),
  round(mon_sales1 / mon_sales2, 2),
  round(tue_sales1 / tue_sales2, 2),
  round(wed_sales1 / wed_sales2, 2),
  round(thu_sales1 / thu_sales2, 2),
  round(fri_sales1 / fri_sales2, 2),
  round(sat_sales1 / sat_sales2, 2)
FROM
  (SELECT
    wswscs.d_week_seq d_week_seq1,
    sun_sales sun_sales1,
    mon_sales mon_sales1,
    tue_sales tue_sales1,
    wed_sales wed_sales1,
    thu_sales thu_sales1,
    fri_sales fri_sales1,
    sat_sales sat_sales1
  FROM wswscs, date_dim
  WHERE date_dim.d_week_seq = wswscs.d_week_seq AND d_year = 2001) y,
  (SELECT
    wswscs.d_week_seq d_week_seq2,
    sun_sales sun_sales2,
    mon_sales mon_sales2,
    tue_sales tue_sales2,
    wed_sales wed_sales2,
    thu_sales thu_sales2,
    fri_sales fri_sales2,
    sat_sales sat_sales2
  FROM wswscs, date_dim
  WHERE date_dim.d_week_seq = wswscs.d_week_seq AND d_year = 2001 + 1) z
WHERE d_week_seq1 = d_week_seq2 - 53
ORDER BY d_week_seq1
SELECT
  s_store_name,
  s_store_id,
  sum(CASE WHEN (d_day_name = 'Sunday')
    THEN ss_sales_price
      ELSE NULL END) sun_sales,
  sum(CASE WHEN (d_day_name = 'Monday')
    THEN ss_sales_price
      ELSE NULL END) mon_sales,
  sum(CASE WHEN (d_day_name = 'Tuesday')
    THEN ss_sales_price
      ELSE NULL END) tue_sales,
  sum(CASE WHEN (d_day_name = 'Wednesday')
    THEN ss_sales_price
      ELSE NULL END) wed_sales,
  sum(CASE WHEN (d_day_name = 'Thursday')
    THEN ss_sales_price
      ELSE NULL END) thu_sales,
  sum(CASE WHEN (d_day_name = 'Friday')
    THEN ss_sales_price
      ELSE NULL END) fri_sales,
  sum(CASE WHEN (d_day_name = 'Saturday')
    THEN ss_sales_price
      ELSE NULL END) sat_sales
FROM date_dim, store_sales, store
WHERE d_date_sk = ss_sold_date_sk AND
  s_store_sk = ss_store_sk AND
  s_gmt_offset = -5 AND
  d_year = 2000
GROUP BY s_store_name, s_store_id
ORDER BY s_store_name, s_store_id, sun_sales, mon_sales, tue_sales, wed_sales,
  thu_sales, fri_sales, sat_sales
LIMIT 100
SELECT
  ss_customer_sk,
  sum(act_sales) sumsales
FROM (SELECT
  ss_item_sk,
  ss_ticket_number,
  ss_customer_sk,
  CASE WHEN sr_return_quantity IS NOT NULL
    THEN (ss_quantity - sr_return_quantity) * ss_sales_price
  ELSE (ss_quantity * ss_sales_price) END act_sales
FROM store_sales
  LEFT OUTER JOIN store_returns
    ON (sr_item_sk = ss_item_sk AND sr_ticket_number = ss_ticket_number)
  ,
  reason
WHERE sr_reason_sk = r_reason_sk AND r_reason_desc = 'reason 28') t
GROUP BY ss_customer_sk
ORDER BY sumsales, ss_customer_sk
LIMIT 100
SELECT count(*)
FROM ((SELECT DISTINCT
  c_last_name,
  c_first_name,
  d_date
FROM store_sales, date_dim, customer
WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
  AND store_sales.ss_customer_sk = customer.c_customer_sk
  AND d_month_seq BETWEEN 1200 AND 1200 + 11)
      EXCEPT
      (SELECT DISTINCT
        c_last_name,
        c_first_name,
        d_date
      FROM catalog_sales, date_dim, customer
      WHERE catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
        AND catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
        AND d_month_seq BETWEEN 1200 AND 1200 + 11)
      EXCEPT
      (SELECT DISTINCT
        c_last_name,
        c_first_name,
        d_date
      FROM web_sales, date_dim, customer
      WHERE web_sales.ws_sold_date_sk = date_dim.d_date_sk
        AND web_sales.ws_bill_customer_sk = customer.c_customer_sk
        AND d_month_seq BETWEEN 1200 AND 1200 + 11)
     ) cool_cust
SELECT
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number,
  amt,
  profit
FROM
  (SELECT
    ss_ticket_number,
    ss_customer_sk,
    ca_city bought_city,
    sum(ss_coupon_amt) amt,
    sum(ss_net_profit) profit
  FROM store_sales, date_dim, store, household_demographics, customer_address
  WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
    AND store_sales.ss_store_sk = store.s_store_sk
    AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    AND store_sales.ss_addr_sk = customer_address.ca_address_sk
    AND (household_demographics.hd_dep_count = 4 OR
    household_demographics.hd_vehicle_count = 3)
    AND date_dim.d_dow IN (6, 0)
    AND date_dim.d_year IN (1999, 1999 + 1, 1999 + 2)
    AND store.s_city IN ('Fairview', 'Midway', 'Fairview', 'Fairview', 'Fairview')
  GROUP BY ss_ticket_number, ss_customer_sk, ss_addr_sk, ca_city) dn, customer,
  customer_address current_addr
WHERE ss_customer_sk = c_customer_sk
  AND customer.c_current_addr_sk = current_addr.ca_address_sk
  AND current_addr.ca_city <> bought_city
ORDER BY c_last_name, c_first_name, ca_city, bought_city, ss_ticket_number
LIMIT 100
SELECT
  s_store_name,
  sum(ss_net_profit)
FROM store_sales, date_dim, store,
  (SELECT ca_zip
  FROM (
         (SELECT substr(ca_zip, 1, 5) ca_zip
         FROM customer_address
         WHERE substr(ca_zip, 1, 5) IN (
               '24128','76232','65084','87816','83926','77556','20548',
               '26231','43848','15126','91137','61265','98294','25782',
               '17920','18426','98235','40081','84093','28577','55565',
               '17183','54601','67897','22752','86284','18376','38607',
               '45200','21756','29741','96765','23932','89360','29839',
               '25989','28898','91068','72550','10390','18845','47770',
               '82636','41367','76638','86198','81312','37126','39192',
               '88424','72175','81426','53672','10445','42666','66864',
               '66708','41248','48583','82276','18842','78890','49448',
               '14089','38122','34425','79077','19849','43285','39861',
               '66162','77610','13695','99543','83444','83041','12305',
               '57665','68341','25003','57834','62878','49130','81096',
               '18840','27700','23470','50412','21195','16021','76107',
               '71954','68309','18119','98359','64544','10336','86379',
               '27068','39736','98569','28915','24206','56529','57647',
               '54917','42961','91110','63981','14922','36420','23006',
               '67467','32754','30903','20260','31671','51798','72325',
               '85816','68621','13955','36446','41766','68806','16725',
               '15146','22744','35850','88086','51649','18270','52867',
               '39972','96976','63792','11376','94898','13595','10516',
               '90225','58943','39371','94945','28587','96576','57855',
               '28488','26105','83933','25858','34322','44438','73171',
               '30122','34102','22685','71256','78451','54364','13354',
               '45375','40558','56458','28286','45266','47305','69399',
               '83921','26233','11101','15371','69913','35942','15882',
               '25631','24610','44165','99076','33786','70738','26653',
               '14328','72305','62496','22152','10144','64147','48425',
               '14663','21076','18799','30450','63089','81019','68893',
               '24996','51200','51211','45692','92712','70466','79994',
               '22437','25280','38935','71791','73134','56571','14060',
               '19505','72425','56575','74351','68786','51650','20004',
               '18383','76614','11634','18906','15765','41368','73241',
               '76698','78567','97189','28545','76231','75691','22246',
               '51061','90578','56691','68014','51103','94167','57047',
               '14867','73520','15734','63435','25733','35474','24676',
               '94627','53535','17879','15559','53268','59166','11928',
               '59402','33282','45721','43933','68101','33515','36634',
               '71286','19736','58058','55253','67473','41918','19515',
               '36495','19430','22351','77191','91393','49156','50298',
               '87501','18652','53179','18767','63193','23968','65164',
               '68880','21286','72823','58470','67301','13394','31016',
               '70372','67030','40604','24317','45748','39127','26065',
               '77721','31029','31880','60576','24671','45549','13376',
               '50016','33123','19769','22927','97789','46081','72151',
               '15723','46136','51949','68100','96888','64528','14171',
               '79777','28709','11489','25103','32213','78668','22245',
               '15798','27156','37930','62971','21337','51622','67853',
               '10567','38415','15455','58263','42029','60279','37125',
               '56240','88190','50308','26859','64457','89091','82136',
               '62377','36233','63837','58078','17043','30010','60099',
               '28810','98025','29178','87343','73273','30469','64034',
               '39516','86057','21309','90257','67875','40162','11356',
               '73650','61810','72013','30431','22461','19512','13375',
               '55307','30625','83849','68908','26689','96451','38193',
               '46820','88885','84935','69035','83144','47537','56616',
               '94983','48033','69952','25486','61547','27385','61860',
               '58048','56910','16807','17871','35258','31387','35458',
               '35576'))
         INTERSECT
         (SELECT ca_zip
         FROM
           (SELECT
             substr(ca_zip, 1, 5) ca_zip,
             count(*) cnt
           FROM customer_address, customer
           WHERE ca_address_sk = c_current_addr_sk AND
             c_preferred_cust_flag = 'Y'
           GROUP BY ca_zip
           HAVING count(*) > 10) A1)
       ) A2
  ) V1
WHERE ss_store_sk = s_store_sk
  AND ss_sold_date_sk = d_date_sk
  AND d_qoy = 2 AND d_year = 1998
  AND (substr(s_zip, 1, 2) = substr(V1.ca_zip, 1, 2))
GROUP BY s_store_name
ORDER BY s_store_name
LIMIT 100
SELECT
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(cs_ext_sales_price) AS itemrevenue,
  sum(cs_ext_sales_price) * 100 / sum(sum(cs_ext_sales_price))
  OVER
  (PARTITION BY i_class) AS revenueratio
FROM catalog_sales, item, date_dim
WHERE cs_item_sk = i_item_sk
  AND i_category IN ('Sports', 'Books', 'Home')
  AND cs_sold_date_sk = d_date_sk
  AND d_date BETWEEN cast('1999-02-22' AS DATE)
AND (cast('1999-02-22' AS DATE) + INTERVAL 30 days)
GROUP BY i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY i_category, i_class, i_item_id, i_item_desc, revenueratio
LIMIT 100
SELECT *
FROM
  (SELECT
    i_manufact_id,
    sum(ss_sales_price) sum_sales,
    avg(sum(ss_sales_price))
    OVER (PARTITION BY i_manufact_id) avg_quarterly_sales
  FROM item, store_sales, date_dim, store
  WHERE ss_item_sk = i_item_sk AND
    ss_sold_date_sk = d_date_sk AND
    ss_store_sk = s_store_sk AND
    d_month_seq IN (1200, 1200 + 1, 1200 + 2, 1200 + 3, 1200 + 4, 1200 + 5, 1200 + 6,
                          1200 + 7, 1200 + 8, 1200 + 9, 1200 + 10, 1200 + 11) AND
    ((i_category IN ('Books', 'Children', 'Electronics') AND
      i_class IN ('personal', 'portable', 'reference', 'self-help') AND
      i_brand IN ('scholaramalgamalg #14', 'scholaramalgamalg #7',
                  'exportiunivamalg #9', 'scholaramalgamalg #9'))
      OR
      (i_category IN ('Women', 'Music', 'Men') AND
        i_class IN ('accessories', 'classical', 'fragrances', 'pants') AND
        i_brand IN ('amalgimporto #1', 'edu packscholar #1', 'exportiimporto #1',
                    'importoamalg #1')))
  GROUP BY i_manufact_id, d_qoy) tmp1
WHERE CASE WHEN avg_quarterly_sales > 0
  THEN abs(sum_sales - avg_quarterly_sales) / avg_quarterly_sales
      ELSE NULL END > 0.1
ORDER BY avg_quarterly_sales,
  sum_sales,
  i_manufact_id
LIMIT 100
SELECT *
FROM
  (SELECT count(*) h8_30_to_9
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 8
    AND time_dim.t_minute >= 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s1,
  (SELECT count(*) h9_to_9_30
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 9
    AND time_dim.t_minute < 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s2,
  (SELECT count(*) h9_30_to_10
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 9
    AND time_dim.t_minute >= 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s3,
  (SELECT count(*) h10_to_10_30
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 10
    AND time_dim.t_minute < 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s4,
  (SELECT count(*) h10_30_to_11
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 10
    AND time_dim.t_minute >= 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s5,
  (SELECT count(*) h11_to_11_30
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 11
    AND time_dim.t_minute < 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s6,
  (SELECT count(*) h11_30_to_12
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 11
    AND time_dim.t_minute >= 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s7,
  (SELECT count(*) h12_to_12_30
  FROM store_sales, household_demographics, time_dim, store
  WHERE ss_sold_time_sk = time_dim.t_time_sk
    AND ss_hdemo_sk = household_demographics.hd_demo_sk
    AND ss_store_sk = s_store_sk
    AND time_dim.t_hour = 12
    AND time_dim.t_minute < 30
    AND (
    (household_demographics.hd_dep_count = 4 AND household_demographics.hd_vehicle_count <= 4 + 2)
      OR
      (household_demographics.hd_dep_count = 2 AND household_demographics.hd_vehicle_count <= 2 + 2)
      OR
      (household_demographics.hd_dep_count = 0 AND
        household_demographics.hd_vehicle_count <= 0 + 2))
    AND store.s_store_name = 'ese') s8
SELECT *
FROM
  (SELECT
    i_category,
    i_class,
    i_brand,
    i_product_name,
    d_year,
    d_qoy,
    d_moy,
    s_store_id,
    sumsales,
    rank()
    OVER (PARTITION BY i_category
      ORDER BY sumsales DESC) rk
  FROM
    (SELECT
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      s_store_id,
      sum(coalesce(ss_sales_price * ss_quantity, 0)) sumsales
    FROM store_sales, date_dim, store, item
    WHERE ss_sold_date_sk = d_date_sk
      AND ss_item_sk = i_item_sk
      AND ss_store_sk = s_store_sk
      AND d_month_seq BETWEEN 1200 AND 1200 + 11
    GROUP BY ROLLUP (i_category, i_class, i_brand, i_product_name, d_year, d_qoy,
      d_moy, s_store_id)) dw1) dw2
WHERE rk <= 100
ORDER BY
  i_category, i_class, i_brand, i_product_name, d_year,
  d_qoy, d_moy, s_store_id, sumsales, rk
LIMIT 100
SELECT
  ca_state,
  cd_gender,
  cd_marital_status,
  count(*) cnt1,
  min(cd_dep_count),
  max(cd_dep_count),
  avg(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  min(cd_dep_employed_count),
  max(cd_dep_employed_count),
  avg(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  min(cd_dep_college_count),
  max(cd_dep_college_count),
  avg(cd_dep_college_count)
FROM
  customer c, customer_address ca, customer_demographics
WHERE
  c.c_current_addr_sk = ca.ca_address_sk AND
    cd_demo_sk = c.c_current_cdemo_sk AND
    exists(SELECT *
           FROM store_sales, date_dim
           WHERE c.c_customer_sk = ss_customer_sk AND
             ss_sold_date_sk = d_date_sk AND
             d_year = 2002 AND
             d_qoy < 4) AND
    (exists(SELECT *
            FROM web_sales, date_dim
            WHERE c.c_customer_sk = ws_bill_customer_sk AND
              ws_sold_date_sk = d_date_sk AND
              d_year = 2002 AND
              d_qoy < 4) OR
      exists(SELECT *
             FROM catalog_sales, date_dim
             WHERE c.c_customer_sk = cs_ship_customer_sk AND
               cs_sold_date_sk = d_date_sk AND
               d_year = 2002 AND
               d_qoy < 4))
GROUP BY ca_state, cd_gender, cd_marital_status, cd_dep_count,
  cd_dep_employed_count, cd_dep_college_count
ORDER BY ca_state, cd_gender, cd_marital_status, cd_dep_count,
  cd_dep_employed_count, cd_dep_college_count
LIMIT 100
SELECT
  i_item_id,
  i_item_desc,
  i_current_price
FROM item, inventory, date_dim, catalog_sales
WHERE i_current_price BETWEEN 68 AND 68 + 30
  AND inv_item_sk = i_item_sk
  AND d_date_sk = inv_date_sk
  AND d_date BETWEEN cast('2000-02-01' AS DATE) AND (cast('2000-02-01' AS DATE) + INTERVAL 60 days)
  AND i_manufact_id IN (677, 940, 694, 808)
  AND inv_quantity_on_hand BETWEEN 100 AND 500
  AND cs_item_sk = i_item_sk
GROUP BY i_item_id, i_item_desc, i_current_price
ORDER BY i_item_id
LIMIT 100
SELECT
  i_product_name,
  i_brand,
  i_class,
  i_category,
  avg(inv_quantity_on_hand) qoh
FROM inventory, date_dim, item, warehouse
WHERE inv_date_sk = d_date_sk
  AND inv_item_sk = i_item_sk
  AND inv_warehouse_sk = w_warehouse_sk
  AND d_month_seq BETWEEN 1200 AND 1200 + 11
GROUP BY ROLLUP (i_product_name, i_brand, i_class, i_category)
ORDER BY qoh, i_product_name, i_brand, i_class, i_category
LIMIT 100
WITH ssr AS
(SELECT
    s_store_id AS store_id,
    sum(ss_ext_sales_price) AS sales,
    sum(coalesce(sr_return_amt, 0)) AS returns,
    sum(ss_net_profit - coalesce(sr_net_loss, 0)) AS profit
  FROM store_sales
    LEFT OUTER JOIN store_returns ON
                                    (ss_item_sk = sr_item_sk AND
                                      ss_ticket_number = sr_ticket_number)
    ,
    date_dim, store, item, promotion
  WHERE ss_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-23' AS DATE)
  AND (cast('2000-08-23' AS DATE) + INTERVAL 30 days)
    AND ss_store_sk = s_store_sk
    AND ss_item_sk = i_item_sk
    AND i_current_price > 50
    AND ss_promo_sk = p_promo_sk
    AND p_channel_tv = 'N'
  GROUP BY s_store_id),
    csr AS
  (SELECT
    cp_catalog_page_id AS catalog_page_id,
    sum(cs_ext_sales_price) AS sales,
    sum(coalesce(cr_return_amount, 0)) AS returns,
    sum(cs_net_profit - coalesce(cr_net_loss, 0)) AS profit
  FROM catalog_sales
    LEFT OUTER JOIN catalog_returns ON
                                      (cs_item_sk = cr_item_sk AND
                                        cs_order_number = cr_order_number)
    ,
    date_dim, catalog_page, item, promotion
  WHERE cs_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-23' AS DATE)
  AND (cast('2000-08-23' AS DATE) + INTERVAL 30 days)
    AND cs_catalog_page_sk = cp_catalog_page_sk
    AND cs_item_sk = i_item_sk
    AND i_current_price > 50
    AND cs_promo_sk = p_promo_sk
    AND p_channel_tv = 'N'
  GROUP BY cp_catalog_page_id),
    wsr AS
  (SELECT
    web_site_id,
    sum(ws_ext_sales_price) AS sales,
    sum(coalesce(wr_return_amt, 0)) AS returns,
    sum(ws_net_profit - coalesce(wr_net_loss, 0)) AS profit
  FROM web_sales
    LEFT OUTER JOIN web_returns ON
                                  (ws_item_sk = wr_item_sk AND ws_order_number = wr_order_number)
    ,
    date_dim, web_site, item, promotion
  WHERE ws_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('2000-08-23' AS DATE)
  AND (cast('2000-08-23' AS DATE) + INTERVAL 30 days)
    AND ws_web_site_sk = web_site_sk
    AND ws_item_sk = i_item_sk
    AND i_current_price > 50
    AND ws_promo_sk = p_promo_sk
    AND p_channel_tv = 'N'
  GROUP BY web_site_id)
SELECT
  channel,
  id,
  sum(sales) AS sales,
  sum(returns) AS returns,
  sum(profit) AS profit
FROM (SELECT
        'store channel' AS channel,
        concat('store', store_id) AS id,
        sales,
        returns,
        profit
      FROM ssr
      UNION ALL
      SELECT
        'catalog channel' AS channel,
        concat('catalog_page', catalog_page_id) AS id,
        sales,
        returns,
        profit
      FROM csr
      UNION ALL
      SELECT
        'web channel' AS channel,
        concat('web_site', web_site_id) AS id,
        sales,
        returns,
        profit
      FROM wsr) x
GROUP BY ROLLUP (channel, id)
ORDER BY channel, id
LIMIT 100
SELECT
  s_store_name,
  i_item_desc,
  sc.revenue,
  i_current_price,
  i_wholesale_cost,
  i_brand
FROM store, item,
  (SELECT
    ss_store_sk,
    avg(revenue) AS ave
  FROM
    (SELECT
      ss_store_sk,
      ss_item_sk,
      sum(ss_sales_price) AS revenue
    FROM store_sales, date_dim
    WHERE ss_sold_date_sk = d_date_sk AND d_month_seq BETWEEN 1176 AND 1176 + 11
    GROUP BY ss_store_sk, ss_item_sk) sa
  GROUP BY ss_store_sk) sb,
  (SELECT
    ss_store_sk,
    ss_item_sk,
    sum(ss_sales_price) AS revenue
  FROM store_sales, date_dim
  WHERE ss_sold_date_sk = d_date_sk AND d_month_seq BETWEEN 1176 AND 1176 + 11
  GROUP BY ss_store_sk, ss_item_sk) sc
WHERE sb.ss_store_sk = sc.ss_store_sk AND
  sc.revenue <= 0.1 * sb.ave AND
  s_store_sk = sc.ss_store_sk AND
  i_item_sk = sc.ss_item_sk
ORDER BY s_store_name, i_item_desc
LIMIT 100
SELECT
  i_item_id,
  i_item_desc,
  s_store_id,
  s_store_name,
  sum(ss_net_profit) AS store_sales_profit,
  sum(sr_net_loss) AS store_returns_loss,
  sum(cs_net_profit) AS catalog_sales_profit
FROM
  store_sales, store_returns, catalog_sales, date_dim d1, date_dim d2, date_dim d3,
  store, item
WHERE
  d1.d_moy = 4
    AND d1.d_year = 2001
    AND d1.d_date_sk = ss_sold_date_sk
    AND i_item_sk = ss_item_sk
    AND s_store_sk = ss_store_sk
    AND ss_customer_sk = sr_customer_sk
    AND ss_item_sk = sr_item_sk
    AND ss_ticket_number = sr_ticket_number
    AND sr_returned_date_sk = d2.d_date_sk
    AND d2.d_moy BETWEEN 4 AND 10
    AND d2.d_year = 2001
    AND sr_customer_sk = cs_bill_customer_sk
    AND sr_item_sk = cs_item_sk
    AND cs_sold_date_sk = d3.d_date_sk
    AND d3.d_moy BETWEEN 4 AND 10
    AND d3.d_year = 2001
GROUP BY
  i_item_id, i_item_desc, s_store_id, s_store_name
ORDER BY
  i_item_id, i_item_desc, s_store_id, s_store_name
LIMIT 100WITH year_total AS (
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum(((ss_ext_list_price - ss_ext_wholesale_cost - ss_ext_discount_amt) +
      ss_ext_sales_price) / 2) year_total,
    's' sale_type
  FROM customer, store_sales, date_dim
  WHERE c_customer_sk = ss_customer_sk AND ss_sold_date_sk = d_date_sk
  GROUP BY c_customer_id,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_country,
    c_login,
    c_email_address,
    d_year
  UNION ALL
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum((((cs_ext_list_price - cs_ext_wholesale_cost - cs_ext_discount_amt) +
      cs_ext_sales_price) / 2)) year_total,
    'c' sale_type
  FROM customer, catalog_sales, date_dim
  WHERE c_customer_sk = cs_bill_customer_sk AND cs_sold_date_sk = d_date_sk
  GROUP BY c_customer_id,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_country,
    c_login,
    c_email_address,
    d_year
  UNION ALL
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum((((ws_ext_list_price - ws_ext_wholesale_cost - ws_ext_discount_amt) + ws_ext_sales_price) /
      2)) year_total,
    'w' sale_type
  FROM customer, web_sales, date_dim
  WHERE c_customer_sk = ws_bill_customer_sk AND ws_sold_date_sk = d_date_sk
  GROUP BY c_customer_id,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_country,
    c_login,
    c_email_address,
    d_year)
SELECT
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name,
  t_s_secyear.customer_preferred_cust_flag,
  t_s_secyear.customer_birth_country,
  t_s_secyear.customer_login,
  t_s_secyear.customer_email_address
FROM year_total t_s_firstyear, year_total t_s_secyear, year_total t_c_firstyear,
  year_total t_c_secyear, year_total t_w_firstyear, year_total t_w_secyear
WHERE t_s_secyear.customer_id = t_s_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_c_secyear.customer_id
  AND t_s_firstyear.customer_id = t_c_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_w_secyear.customer_id
  AND t_s_firstyear.sale_type = 's'
  AND t_c_firstyear.sale_type = 'c'
  AND t_w_firstyear.sale_type = 'w'
  AND t_s_secyear.sale_type = 's'
  AND t_c_secyear.sale_type = 'c'
  AND t_w_secyear.sale_type = 'w'
  AND t_s_firstyear.dyear = 2001
  AND t_s_secyear.dyear = 2001 + 1
  AND t_c_firstyear.dyear = 2001
  AND t_c_secyear.dyear = 2001 + 1
  AND t_w_firstyear.dyear = 2001
  AND t_w_secyear.dyear = 2001 + 1
  AND t_s_firstyear.year_total > 0
  AND t_c_firstyear.year_total > 0
  AND t_w_firstyear.year_total > 0
  AND CASE WHEN t_c_firstyear.year_total > 0
  THEN t_c_secyear.year_total / t_c_firstyear.year_total
      ELSE NULL END
  > CASE WHEN t_s_firstyear.year_total > 0
  THEN t_s_secyear.year_total / t_s_firstyear.year_total
    ELSE NULL END
  AND CASE WHEN t_c_firstyear.year_total > 0
  THEN t_c_secyear.year_total / t_c_firstyear.year_total
      ELSE NULL END
  > CASE WHEN t_w_firstyear.year_total > 0
  THEN t_w_secyear.year_total / t_w_firstyear.year_total
    ELSE NULL END
ORDER BY
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name,
  t_s_secyear.customer_preferred_cust_flag,
  t_s_secyear.customer_birth_country,
  t_s_secyear.customer_login,
  t_s_secyear.customer_email_address
LIMIT 100
SELECT
  ca_zip,
  sum(cs_sales_price)
FROM catalog_sales, customer, customer_address, date_dim
WHERE cs_bill_customer_sk = c_customer_sk
  AND c_current_addr_sk = ca_address_sk
  AND (substr(ca_zip, 1, 5) IN ('85669', '86197', '88274', '83405', '86475',
                                '85392', '85460', '80348', '81792')
  OR ca_state IN ('CA', 'WA', 'GA')
  OR cs_sales_price > 500)
  AND cs_sold_date_sk = d_date_sk
  AND d_qoy = 2 AND d_year = 2001
GROUP BY ca_zip
ORDER BY ca_zip
LIMIT 100
SELECT
  a.ca_state state,
  count(*) cnt
FROM
  customer_address a, customer c, store_sales s, date_dim d, item i
WHERE a.ca_address_sk = c.c_current_addr_sk
  AND c.c_customer_sk = s.ss_customer_sk
  AND s.ss_sold_date_sk = d.d_date_sk
  AND s.ss_item_sk = i.i_item_sk
  AND d.d_month_seq =
  (SELECT DISTINCT (d_month_seq)
  FROM date_dim
  WHERE d_year = 2000 AND d_moy = 1)
  AND i.i_current_price > 1.2 *
  (SELECT avg(j.i_current_price)
  FROM item j
  WHERE j.i_category = i.i_category)
GROUP BY a.ca_state
HAVING count(*) >= 10
ORDER BY cnt
LIMIT 100
WITH cross_items AS
(SELECT i_item_sk ss_item_sk
  FROM item,
    (SELECT
      iss.i_brand_id brand_id,
      iss.i_class_id class_id,
      iss.i_category_id category_id
    FROM store_sales, item iss, date_dim d1
    WHERE ss_item_sk = iss.i_item_sk
      AND ss_sold_date_sk = d1.d_date_sk
      AND d1.d_year BETWEEN 1999 AND 1999 + 2
    INTERSECT
    SELECT
      ics.i_brand_id,
      ics.i_class_id,
      ics.i_category_id
    FROM catalog_sales, item ics, date_dim d2
    WHERE cs_item_sk = ics.i_item_sk
      AND cs_sold_date_sk = d2.d_date_sk
      AND d2.d_year BETWEEN 1999 AND 1999 + 2
    INTERSECT
    SELECT
      iws.i_brand_id,
      iws.i_class_id,
      iws.i_category_id
    FROM web_sales, item iws, date_dim d3
    WHERE ws_item_sk = iws.i_item_sk
      AND ws_sold_date_sk = d3.d_date_sk
      AND d3.d_year BETWEEN 1999 AND 1999 + 2) x
  WHERE i_brand_id = brand_id
    AND i_class_id = class_id
    AND i_category_id = category_id
),
    avg_sales AS
  (SELECT avg(quantity * list_price) average_sales
  FROM (
         SELECT
           ss_quantity quantity,
           ss_list_price list_price
         FROM store_sales, date_dim
         WHERE ss_sold_date_sk = d_date_sk
           AND d_year BETWEEN 1999 AND 2001
         UNION ALL
         SELECT
           cs_quantity quantity,
           cs_list_price list_price
         FROM catalog_sales, date_dim
         WHERE cs_sold_date_sk = d_date_sk
           AND d_year BETWEEN 1999 AND 1999 + 2
         UNION ALL
         SELECT
           ws_quantity quantity,
           ws_list_price list_price
         FROM web_sales, date_dim
         WHERE ws_sold_date_sk = d_date_sk
           AND d_year BETWEEN 1999 AND 1999 + 2) x)
SELECT
  channel,
  i_brand_id,
  i_class_id,
  i_category_id,
  sum(sales),
  sum(number_sales)
FROM (
       SELECT
         'store' channel,
         i_brand_id,
         i_class_id,
         i_category_id,
         sum(ss_quantity * ss_list_price) sales,
         count(*) number_sales
       FROM store_sales, item, date_dim
       WHERE ss_item_sk IN (SELECT ss_item_sk
       FROM cross_items)
         AND ss_item_sk = i_item_sk
         AND ss_sold_date_sk = d_date_sk
         AND d_year = 1999 + 2
         AND d_moy = 11
       GROUP BY i_brand_id, i_class_id, i_category_id
       HAVING sum(ss_quantity * ss_list_price) > (SELECT average_sales
       FROM avg_sales)
       UNION ALL
       SELECT
         'catalog' channel,
         i_brand_id,
         i_class_id,
         i_category_id,
         sum(cs_quantity * cs_list_price) sales,
         count(*) number_sales
       FROM catalog_sales, item, date_dim
       WHERE cs_item_sk IN (SELECT ss_item_sk
       FROM cross_items)
         AND cs_item_sk = i_item_sk
         AND cs_sold_date_sk = d_date_sk
         AND d_year = 1999 + 2
         AND d_moy = 11
       GROUP BY i_brand_id, i_class_id, i_category_id
       HAVING sum(cs_quantity * cs_list_price) > (SELECT average_sales FROM avg_sales)
       UNION ALL
       SELECT
         'web' channel,
         i_brand_id,
         i_class_id,
         i_category_id,
         sum(ws_quantity * ws_list_price) sales,
         count(*) number_sales
       FROM web_sales, item, date_dim
       WHERE ws_item_sk IN (SELECT ss_item_sk
       FROM cross_items)
         AND ws_item_sk = i_item_sk
         AND ws_sold_date_sk = d_date_sk
         AND d_year = 1999 + 2
         AND d_moy = 11
       GROUP BY i_brand_id, i_class_id, i_category_id
       HAVING sum(ws_quantity * ws_list_price) > (SELECT average_sales
       FROM avg_sales)
     ) y
GROUP BY ROLLUP (channel, i_brand_id, i_class_id, i_category_id)
ORDER BY channel, i_brand_id, i_class_id, i_category_id
LIMIT 100
WITH ws_wh AS
(SELECT
    ws1.ws_order_number,
    ws1.ws_warehouse_sk wh1,
    ws2.ws_warehouse_sk wh2
  FROM web_sales ws1, web_sales ws2
  WHERE ws1.ws_order_number = ws2.ws_order_number
    AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
SELECT
  count(DISTINCT ws_order_number) AS `order count `,
  sum(ws_ext_ship_cost) AS `total shipping cost `,
  sum(ws_net_profit) AS `total net profit `
FROM
  web_sales ws1, date_dim, customer_address, web_site
WHERE
  d_date BETWEEN '1999-02-01' AND
  (CAST('1999-02-01' AS DATE) + INTERVAL 60 DAY)
    AND ws1.ws_ship_date_sk = d_date_sk
    AND ws1.ws_ship_addr_sk = ca_address_sk
    AND ca_state = 'IL'
    AND ws1.ws_web_site_sk = web_site_sk
    AND web_company_name = 'pri'
    AND ws1.ws_order_number IN (SELECT ws_order_number
  FROM ws_wh)
    AND ws1.ws_order_number IN (SELECT wr_order_number
  FROM web_returns, ws_wh
  WHERE wr_order_number = ws_wh.ws_order_number)
ORDER BY count(DISTINCT ws_order_number)
LIMIT 100
SELECT
  ca_zip,
  ca_city,
  sum(ws_sales_price)
FROM web_sales, customer, customer_address, date_dim, item
WHERE ws_bill_customer_sk = c_customer_sk
  AND c_current_addr_sk = ca_address_sk
  AND ws_item_sk = i_item_sk
  AND (substr(ca_zip, 1, 5) IN
  ('85669', '86197', '88274', '83405', '86475', '85392', '85460', '80348', '81792')
  OR
  i_item_id IN (SELECT i_item_id
  FROM item
  WHERE i_item_sk IN (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
  )
)
  AND ws_sold_date_sk = d_date_sk
  AND d_qoy = 2 AND d_year = 2001
GROUP BY ca_zip, ca_city
ORDER BY ca_zip, ca_city
LIMIT 100
SELECT
  i_item_id,
  i_item_desc,
  s_store_id,
  s_store_name,
  sum(ss_quantity) AS store_sales_quantity,
  sum(sr_return_quantity) AS store_returns_quantity,
  sum(cs_quantity) AS catalog_sales_quantity
FROM
  store_sales, store_returns, catalog_sales, date_dim d1, date_dim d2,
  date_dim d3, store, item
WHERE
  d1.d_moy = 9
    AND d1.d_year = 1999
    AND d1.d_date_sk = ss_sold_date_sk
    AND i_item_sk = ss_item_sk
    AND s_store_sk = ss_store_sk
    AND ss_customer_sk = sr_customer_sk
    AND ss_item_sk = sr_item_sk
    AND ss_ticket_number = sr_ticket_number
    AND sr_returned_date_sk = d2.d_date_sk
    AND d2.d_moy BETWEEN 9 AND 9 + 3
    AND d2.d_year = 1999
    AND sr_customer_sk = cs_bill_customer_sk
    AND sr_item_sk = cs_item_sk
    AND cs_sold_date_sk = d3.d_date_sk
    AND d3.d_year IN (1999, 1999 + 1, 1999 + 2)
GROUP BY
  i_item_id, i_item_desc, s_store_id, s_store_name
ORDER BY
  i_item_id, i_item_desc, s_store_id, s_store_name
LIMIT 100
WITH customer_total_return AS
(SELECT
    cr_returning_customer_sk AS ctr_customer_sk,
    ca_state AS ctr_state,
    sum(cr_return_amt_inc_tax) AS ctr_total_return
  FROM catalog_returns, date_dim, customer_address
  WHERE cr_returned_date_sk = d_date_sk
    AND d_year = 2000
    AND cr_returning_addr_sk = ca_address_sk
  GROUP BY cr_returning_customer_sk, ca_state )
SELECT
  c_customer_id,
  c_salutation,
  c_first_name,
  c_last_name,
  ca_street_number,
  ca_street_name,
  ca_street_type,
  ca_suite_number,
  ca_city,
  ca_county,
  ca_state,
  ca_zip,
  ca_country,
  ca_gmt_offset,
  ca_location_type,
  ctr_total_return
FROM customer_total_return ctr1, customer_address, customer
WHERE ctr1.ctr_total_return > (SELECT avg(ctr_total_return) * 1.2
FROM customer_total_return ctr2
WHERE ctr1.ctr_state = ctr2.ctr_state)
  AND ca_address_sk = c_current_addr_sk
  AND ca_state = 'GA'
  AND ctr1.ctr_customer_sk = c_customer_sk
ORDER BY c_customer_id, c_salutation, c_first_name, c_last_name, ca_street_number, ca_street_name
  , ca_street_type, ca_suite_number, ca_city, ca_county, ca_state, ca_zip, ca_country, ca_gmt_offset
  , ca_location_type, ctr_total_return
LIMIT 100
SELECT
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(ws_ext_sales_price) AS itemrevenue,
  sum(ws_ext_sales_price) * 100 / sum(sum(ws_ext_sales_price))
  OVER
  (PARTITION BY i_class) AS revenueratio
FROM
  web_sales, item, date_dim
WHERE
  ws_item_sk = i_item_sk
    AND i_category IN ('Sports', 'Books', 'Home')
    AND ws_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('1999-02-22' AS DATE)
  AND (cast('1999-02-22' AS DATE) + INTERVAL 30 days)
GROUP BY
  i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY
  i_category, i_class, i_item_id, i_item_desc, revenueratio
LIMIT 100
SELECT DISTINCT (i_product_name)
FROM item i1
WHERE i_manufact_id BETWEEN 738 AND 738 + 40
  AND (SELECT count(*) AS item_cnt
FROM item
WHERE (i_manufact = i1.i_manufact AND
  ((i_category = 'Women' AND
    (i_color = 'powder' OR i_color = 'khaki') AND
    (i_units = 'Ounce' OR i_units = 'Oz') AND
    (i_size = 'medium' OR i_size = 'extra large')
  ) OR
    (i_category = 'Women' AND
      (i_color = 'brown' OR i_color = 'honeydew') AND
      (i_units = 'Bunch' OR i_units = 'Ton') AND
      (i_size = 'N/A' OR i_size = 'small')
    ) OR
    (i_category = 'Men' AND
      (i_color = 'floral' OR i_color = 'deep') AND
      (i_units = 'N/A' OR i_units = 'Dozen') AND
      (i_size = 'petite' OR i_size = 'large')
    ) OR
    (i_category = 'Men' AND
      (i_color = 'light' OR i_color = 'cornflower') AND
      (i_units = 'Box' OR i_units = 'Pound') AND
      (i_size = 'medium' OR i_size = 'extra large')
    ))) OR
  (i_manufact = i1.i_manufact AND
    ((i_category = 'Women' AND
      (i_color = 'midnight' OR i_color = 'snow') AND
      (i_units = 'Pallet' OR i_units = 'Gross') AND
      (i_size = 'medium' OR i_size = 'extra large')
    ) OR
      (i_category = 'Women' AND
        (i_color = 'cyan' OR i_color = 'papaya') AND
        (i_units = 'Cup' OR i_units = 'Dram') AND
        (i_size = 'N/A' OR i_size = 'small')
      ) OR
      (i_category = 'Men' AND
        (i_color = 'orange' OR i_color = 'frosted') AND
        (i_units = 'Each' OR i_units = 'Tbl') AND
        (i_size = 'petite' OR i_size = 'large')
      ) OR
      (i_category = 'Men' AND
        (i_color = 'forest' OR i_color = 'ghost') AND
        (i_units = 'Lb' OR i_units = 'Bundle') AND
        (i_size = 'medium' OR i_size = 'extra large')
      )))) > 0
ORDER BY i_product_name
LIMIT 100
WITH ssales AS
(SELECT
    c_last_name,
    c_first_name,
    s_store_name,
    ca_state,
    s_state,
    i_color,
    i_current_price,
    i_manager_id,
    i_units,
    i_size,
    sum(ss_net_paid) netpaid
  FROM store_sales, store_returns, store, item, customer, customer_address
  WHERE ss_ticket_number = sr_ticket_number
    AND ss_item_sk = sr_item_sk
    AND ss_customer_sk = c_customer_sk
    AND ss_item_sk = i_item_sk
    AND ss_store_sk = s_store_sk
    AND c_birth_country = upper(ca_country)
    AND s_zip = ca_zip
    AND s_market_id = 8
  GROUP BY c_last_name, c_first_name, s_store_name, ca_state, s_state,
    i_color, i_current_price, i_manager_id, i_units, i_size)
SELECT
  c_last_name,
  c_first_name,
  s_store_name,
  sum(netpaid) paid
FROM ssales
WHERE i_color = 'chiffon'
GROUP BY c_last_name, c_first_name, s_store_name
HAVING sum(netpaid) > (SELECT 0.05 * avg(netpaid)
FROM ssales)
WITH customer_total_return AS
(SELECT
    wr_returning_customer_sk AS ctr_customer_sk,
    ca_state AS ctr_state,
    sum(wr_return_amt) AS ctr_total_return
  FROM web_returns, date_dim, customer_address
  WHERE wr_returned_date_sk = d_date_sk
    AND d_year = 2002
    AND wr_returning_addr_sk = ca_address_sk
  GROUP BY wr_returning_customer_sk, ca_state)
SELECT
  c_customer_id,
  c_salutation,
  c_first_name,
  c_last_name,
  c_preferred_cust_flag,
  c_birth_day,
  c_birth_month,
  c_birth_year,
  c_birth_country,
  c_login,
  c_email_address,
  c_last_review_date,
  ctr_total_return
FROM customer_total_return ctr1, customer_address, customer
WHERE ctr1.ctr_total_return > (SELECT avg(ctr_total_return) * 1.2
FROM customer_total_return ctr2
WHERE ctr1.ctr_state = ctr2.ctr_state)
  AND ca_address_sk = c_current_addr_sk
  AND ca_state = 'GA'
  AND ctr1.ctr_customer_sk = c_customer_sk
ORDER BY c_customer_id, c_salutation, c_first_name, c_last_name, c_preferred_cust_flag
  , c_birth_day, c_birth_month, c_birth_year, c_birth_country, c_login, c_email_address
  , c_last_review_date, ctr_total_return
LIMIT 100
WITH inv AS
(SELECT
    w_warehouse_name,
    w_warehouse_sk,
    i_item_sk,
    d_moy,
    stdev,
    mean,
    CASE mean
    WHEN 0
      THEN NULL
    ELSE stdev / mean END cov
  FROM (SELECT
    w_warehouse_name,
    w_warehouse_sk,
    i_item_sk,
    d_moy,
    stddev_samp(inv_quantity_on_hand) stdev,
    avg(inv_quantity_on_hand) mean
  FROM inventory, item, warehouse, date_dim
  WHERE inv_item_sk = i_item_sk
    AND inv_warehouse_sk = w_warehouse_sk
    AND inv_date_sk = d_date_sk
    AND d_year = 2001
  GROUP BY w_warehouse_name, w_warehouse_sk, i_item_sk, d_moy) foo
  WHERE CASE mean
        WHEN 0
          THEN 0
        ELSE stdev / mean END > 1)
SELECT
  inv1.w_warehouse_sk,
  inv1.i_item_sk,
  inv1.d_moy,
  inv1.mean,
  inv1.cov,
  inv2.w_warehouse_sk,
  inv2.i_item_sk,
  inv2.d_moy,
  inv2.mean,
  inv2.cov
FROM inv inv1, inv inv2
WHERE inv1.i_item_sk = inv2.i_item_sk
  AND inv1.w_warehouse_sk = inv2.w_warehouse_sk
  AND inv1.d_moy = 1
  AND inv2.d_moy = 1 + 1
ORDER BY inv1.w_warehouse_sk, inv1.i_item_sk, inv1.d_moy, inv1.mean, inv1.cov
  , inv2.d_moy, inv2.mean, inv2.cov
SELECT
  dt.d_year,
  item.i_brand_id brand_id,
  item.i_brand brand,
  SUM(ss_ext_sales_price) sum_agg
FROM date_dim dt, store_sales, item
WHERE dt.d_date_sk = store_sales.ss_sold_date_sk
  AND store_sales.ss_item_sk = item.i_item_sk
  AND item.i_manufact_id = 128
  AND dt.d_moy = 11
GROUP BY dt.d_year, item.i_brand, item.i_brand_id
ORDER BY dt.d_year, sum_agg DESC, brand_id
LIMIT 100
SELECT
  sum(ss_net_profit) AS total_sum,
  s_state,
  s_county,
  grouping(s_state) + grouping(s_county) AS lochierarchy,
  rank()
  OVER (
    PARTITION BY grouping(s_state) + grouping(s_county),
      CASE WHEN grouping(s_county) = 0
        THEN s_state END
    ORDER BY sum(ss_net_profit) DESC) AS rank_within_parent
FROM
  store_sales, date_dim d1, store
WHERE
  d1.d_month_seq BETWEEN 1200 AND 1200 + 11
    AND d1.d_date_sk = ss_sold_date_sk
    AND s_store_sk = ss_store_sk
    AND s_state IN
    (SELECT s_state
    FROM
      (SELECT
        s_state AS s_state,
        rank()
        OVER (PARTITION BY s_state
          ORDER BY sum(ss_net_profit) DESC) AS ranking
      FROM store_sales, store, date_dim
      WHERE d_month_seq BETWEEN 1200 AND 1200 + 11
        AND d_date_sk = ss_sold_date_sk
        AND s_store_sk = ss_store_sk
      GROUP BY s_state) tmp1
    WHERE ranking <= 5)
GROUP BY ROLLUP (s_state, s_county)
ORDER BY
  lochierarchy DESC
  , CASE WHEN lochierarchy = 0
  THEN s_state END
  , rank_within_parent
LIMIT 100
SELECT
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag,
  ss_ticket_number,
  cnt
FROM
  (SELECT
    ss_ticket_number,
    ss_customer_sk,
    count(*) cnt
  FROM store_sales, date_dim, store, household_demographics
  WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
    AND store_sales.ss_store_sk = store.s_store_sk
    AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    AND date_dim.d_dom BETWEEN 1 AND 2
    AND (household_demographics.hd_buy_potential = '>10000' OR
    household_demographics.hd_buy_potential = 'unknown')
    AND household_demographics.hd_vehicle_count > 0
    AND CASE WHEN household_demographics.hd_vehicle_count > 0
    THEN
      household_demographics.hd_dep_count / household_demographics.hd_vehicle_count
        ELSE NULL END > 1
    AND date_dim.d_year IN (1999, 1999 + 1, 1999 + 2)
    AND store.s_county IN ('Williamson County', 'Franklin Parish', 'Bronx County', 'Orange County')
  GROUP BY ss_ticket_number, ss_customer_sk) dj, customer
WHERE ss_customer_sk = c_customer_sk
  AND cnt BETWEEN 1 AND 5
ORDER BY cnt DESC
SELECT
  i_brand_id brand_id,
  i_brand brand,
  i_manufact_id,
  i_manufact,
  sum(ss_ext_sales_price) ext_price
FROM date_dim, store_sales, item, customer, customer_address, store
WHERE d_date_sk = ss_sold_date_sk
  AND ss_item_sk = i_item_sk
  AND i_manager_id = 8
  AND d_moy = 11
  AND d_year = 1998
  AND ss_customer_sk = c_customer_sk
  AND c_current_addr_sk = ca_address_sk
  AND substr(ca_zip, 1, 5) <> substr(s_zip, 1, 5)
  AND ss_store_sk = s_store_sk
GROUP BY i_brand, i_brand_id, i_manufact_id, i_manufact
ORDER BY ext_price DESC, brand, brand_id, i_manufact_id, i_manufact
LIMIT 100
SELECT
  i_brand_id brand_id,
  i_brand brand,
  t_hour,
  t_minute,
  sum(ext_price) ext_price
FROM item,
  (SELECT
     ws_ext_sales_price AS ext_price,
     ws_sold_date_sk AS sold_date_sk,
     ws_item_sk AS sold_item_sk,
     ws_sold_time_sk AS time_sk
   FROM web_sales, date_dim
   WHERE d_date_sk = ws_sold_date_sk
     AND d_moy = 11
     AND d_year = 1999
   UNION ALL
   SELECT
     cs_ext_sales_price AS ext_price,
     cs_sold_date_sk AS sold_date_sk,
     cs_item_sk AS sold_item_sk,
     cs_sold_time_sk AS time_sk
   FROM catalog_sales, date_dim
   WHERE d_date_sk = cs_sold_date_sk
     AND d_moy = 11
     AND d_year = 1999
   UNION ALL
   SELECT
     ss_ext_sales_price AS ext_price,
     ss_sold_date_sk AS sold_date_sk,
     ss_item_sk AS sold_item_sk,
     ss_sold_time_sk AS time_sk
   FROM store_sales, date_dim
   WHERE d_date_sk = ss_sold_date_sk
     AND d_moy = 11
     AND d_year = 1999
  ) AS tmp, time_dim
WHERE
  sold_item_sk = i_item_sk
    AND i_manager_id = 1
    AND time_sk = t_time_sk
    AND (t_meal_time = 'breakfast' OR t_meal_time = 'dinner')
GROUP BY i_brand, i_brand_id, t_hour, t_minute
ORDER BY ext_price DESC, brand_id
WITH all_sales AS (
  SELECT
    d_year,
    i_brand_id,
    i_class_id,
    i_category_id,
    i_manufact_id,
    SUM(sales_cnt) AS sales_cnt,
    SUM(sales_amt) AS sales_amt
  FROM (
         SELECT
           d_year,
           i_brand_id,
           i_class_id,
           i_category_id,
           i_manufact_id,
           cs_quantity - COALESCE(cr_return_quantity, 0) AS sales_cnt,
           cs_ext_sales_price - COALESCE(cr_return_amount, 0.0) AS sales_amt
         FROM catalog_sales
           JOIN item ON i_item_sk = cs_item_sk
           JOIN date_dim ON d_date_sk = cs_sold_date_sk
           LEFT JOIN catalog_returns ON (cs_order_number = cr_order_number
             AND cs_item_sk = cr_item_sk)
         WHERE i_category = 'Books'
         UNION
         SELECT
           d_year,
           i_brand_id,
           i_class_id,
           i_category_id,
           i_manufact_id,
           ss_quantity - COALESCE(sr_return_quantity, 0) AS sales_cnt,
           ss_ext_sales_price - COALESCE(sr_return_amt, 0.0) AS sales_amt
         FROM store_sales
           JOIN item ON i_item_sk = ss_item_sk
           JOIN date_dim ON d_date_sk = ss_sold_date_sk
           LEFT JOIN store_returns ON (ss_ticket_number = sr_ticket_number
             AND ss_item_sk = sr_item_sk)
         WHERE i_category = 'Books'
         UNION
         SELECT
           d_year,
           i_brand_id,
           i_class_id,
           i_category_id,
           i_manufact_id,
           ws_quantity - COALESCE(wr_return_quantity, 0) AS sales_cnt,
           ws_ext_sales_price - COALESCE(wr_return_amt, 0.0) AS sales_amt
         FROM web_sales
           JOIN item ON i_item_sk = ws_item_sk
           JOIN date_dim ON d_date_sk = ws_sold_date_sk
           LEFT JOIN web_returns ON (ws_order_number = wr_order_number
             AND ws_item_sk = wr_item_sk)
         WHERE i_category = 'Books') sales_detail
  GROUP BY d_year, i_brand_id, i_class_id, i_category_id, i_manufact_id)
SELECT
  prev_yr.d_year AS prev_year,
  curr_yr.d_year AS year,
  curr_yr.i_brand_id,
  curr_yr.i_class_id,
  curr_yr.i_category_id,
  curr_yr.i_manufact_id,
  prev_yr.sales_cnt AS prev_yr_cnt,
  curr_yr.sales_cnt AS curr_yr_cnt,
  curr_yr.sales_cnt - prev_yr.sales_cnt AS sales_cnt_diff,
  curr_yr.sales_amt - prev_yr.sales_amt AS sales_amt_diff
FROM all_sales curr_yr, all_sales prev_yr
WHERE curr_yr.i_brand_id = prev_yr.i_brand_id
  AND curr_yr.i_class_id = prev_yr.i_class_id
  AND curr_yr.i_category_id = prev_yr.i_category_id
  AND curr_yr.i_manufact_id = prev_yr.i_manufact_id
  AND curr_yr.d_year = 2002
  AND prev_yr.d_year = 2002 - 1
  AND CAST(curr_yr.sales_cnt AS DECIMAL(17, 2)) / CAST(prev_yr.sales_cnt AS DECIMAL(17, 2)) < 0.9
ORDER BY sales_cnt_diff
LIMIT 100
SELECT *
FROM (SELECT
  avg(ss_list_price) B1_LP,
  count(ss_list_price) B1_CNT,
  count(DISTINCT ss_list_price) B1_CNTD
FROM store_sales
WHERE ss_quantity BETWEEN 0 AND 5
  AND (ss_list_price BETWEEN 8 AND 8 + 10
  OR ss_coupon_amt BETWEEN 459 AND 459 + 1000
  OR ss_wholesale_cost BETWEEN 57 AND 57 + 20)) B1,
  (SELECT
    avg(ss_list_price) B2_LP,
    count(ss_list_price) B2_CNT,
    count(DISTINCT ss_list_price) B2_CNTD
  FROM store_sales
  WHERE ss_quantity BETWEEN 6 AND 10
    AND (ss_list_price BETWEEN 90 AND 90 + 10
    OR ss_coupon_amt BETWEEN 2323 AND 2323 + 1000
    OR ss_wholesale_cost BETWEEN 31 AND 31 + 20)) B2,
  (SELECT
    avg(ss_list_price) B3_LP,
    count(ss_list_price) B3_CNT,
    count(DISTINCT ss_list_price) B3_CNTD
  FROM store_sales
  WHERE ss_quantity BETWEEN 11 AND 15
    AND (ss_list_price BETWEEN 142 AND 142 + 10
    OR ss_coupon_amt BETWEEN 12214 AND 12214 + 1000
    OR ss_wholesale_cost BETWEEN 79 AND 79 + 20)) B3,
  (SELECT
    avg(ss_list_price) B4_LP,
    count(ss_list_price) B4_CNT,
    count(DISTINCT ss_list_price) B4_CNTD
  FROM store_sales
  WHERE ss_quantity BETWEEN 16 AND 20
    AND (ss_list_price BETWEEN 135 AND 135 + 10
    OR ss_coupon_amt BETWEEN 6071 AND 6071 + 1000
    OR ss_wholesale_cost BETWEEN 38 AND 38 + 20)) B4,
  (SELECT
    avg(ss_list_price) B5_LP,
    count(ss_list_price) B5_CNT,
    count(DISTINCT ss_list_price) B5_CNTD
  FROM store_sales
  WHERE ss_quantity BETWEEN 21 AND 25
    AND (ss_list_price BETWEEN 122 AND 122 + 10
    OR ss_coupon_amt BETWEEN 836 AND 836 + 1000
    OR ss_wholesale_cost BETWEEN 17 AND 17 + 20)) B5,
  (SELECT
    avg(ss_list_price) B6_LP,
    count(ss_list_price) B6_CNT,
    count(DISTINCT ss_list_price) B6_CNTD
  FROM store_sales
  WHERE ss_quantity BETWEEN 26 AND 30
    AND (ss_list_price BETWEEN 154 AND 154 + 10
    OR ss_coupon_amt BETWEEN 7326 AND 7326 + 1000
    OR ss_wholesale_cost BETWEEN 7 AND 7 + 20)) B6
LIMIT 100
WITH frequent_ss_items AS
(SELECT
    substr(i_item_desc, 1, 30) itemdesc,
    i_item_sk item_sk,
    d_date solddate,
    count(*) cnt
  FROM store_sales, date_dim, item
  WHERE ss_sold_date_sk = d_date_sk
    AND ss_item_sk = i_item_sk
    AND d_year IN (2000, 2000 + 1, 2000 + 2, 2000 + 3)
  GROUP BY substr(i_item_desc, 1, 30), i_item_sk, d_date
  HAVING count(*) > 4),
    max_store_sales AS
  (SELECT max(csales) tpcds_cmax
  FROM (SELECT
    c_customer_sk,
    sum(ss_quantity * ss_sales_price) csales
  FROM store_sales, customer, date_dim
  WHERE ss_customer_sk = c_customer_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year IN (2000, 2000 + 1, 2000 + 2, 2000 + 3)
  GROUP BY c_customer_sk) x),
    best_ss_customer AS
  (SELECT
    c_customer_sk,
    sum(ss_quantity * ss_sales_price) ssales
  FROM store_sales
    , customer
  WHERE ss_customer_sk = c_customer_sk
  GROUP BY c_customer_sk
  HAVING sum(ss_quantity * ss_sales_price) > (50 / 100.0) *
    (SELECT *
    FROM max_store_sales))
SELECT
  c_last_name,
  c_first_name,
  sales
FROM ((SELECT
  c_last_name,
  c_first_name,
  sum(cs_quantity * cs_list_price) sales
FROM catalog_sales, customer, date_dim
WHERE d_year = 2000
  AND d_moy = 2
  AND cs_sold_date_sk = d_date_sk
  AND cs_item_sk IN (SELECT item_sk
FROM frequent_ss_items)
  AND cs_bill_customer_sk IN (SELECT c_customer_sk
FROM best_ss_customer)
  AND cs_bill_customer_sk = c_customer_sk
GROUP BY c_last_name, c_first_name)
      UNION ALL
      (SELECT
        c_last_name,
        c_first_name,
        sum(ws_quantity * ws_list_price) sales
      FROM web_sales, customer, date_dim
      WHERE d_year = 2000
        AND d_moy = 2
        AND ws_sold_date_sk = d_date_sk
        AND ws_item_sk IN (SELECT item_sk
      FROM frequent_ss_items)
        AND ws_bill_customer_sk IN (SELECT c_customer_sk
      FROM best_ss_customer)
        AND ws_bill_customer_sk = c_customer_sk
      GROUP BY c_last_name, c_first_name)) y
ORDER BY c_last_name, c_first_name, sales
LIMIT 100
SELECT
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3
FROM
  customer c, customer_address ca, customer_demographics
WHERE
  c.c_current_addr_sk = ca.ca_address_sk AND
    ca_state IN ('KY', 'GA', 'NM') AND
    cd_demo_sk = c.c_current_cdemo_sk AND
    exists(SELECT *
           FROM store_sales, date_dim
           WHERE c.c_customer_sk = ss_customer_sk AND
             ss_sold_date_sk = d_date_sk AND
             d_year = 2001 AND
             d_moy BETWEEN 4 AND 4 + 2) AND
    (NOT exists(SELECT *
                FROM web_sales, date_dim
                WHERE c.c_customer_sk = ws_bill_customer_sk AND
                  ws_sold_date_sk = d_date_sk AND
                  d_year = 2001 AND
                  d_moy BETWEEN 4 AND 4 + 2) AND
      NOT exists(SELECT *
                 FROM catalog_sales, date_dim
                 WHERE c.c_customer_sk = cs_ship_customer_sk AND
                   cs_sold_date_sk = d_date_sk AND
                   d_year = 2001 AND
                   d_moy BETWEEN 4 AND 4 + 2))
GROUP BY cd_gender, cd_marital_status, cd_education_status,
  cd_purchase_estimate, cd_credit_rating
ORDER BY cd_gender, cd_marital_status, cd_education_status,
  cd_purchase_estimate, cd_credit_rating
LIMIT 100
SELECT
  sum(ss_net_profit) / sum(ss_ext_sales_price) AS gross_margin,
  i_category,
  i_class,
  grouping(i_category) + grouping(i_class) AS lochierarchy,
  rank()
  OVER (
    PARTITION BY grouping(i_category) + grouping(i_class),
      CASE WHEN grouping(i_class) = 0
        THEN i_category END
    ORDER BY sum(ss_net_profit) / sum(ss_ext_sales_price) ASC) AS rank_within_parent
FROM
  store_sales, date_dim d1, item, store
WHERE
  d1.d_year = 2001
    AND d1.d_date_sk = ss_sold_date_sk
    AND i_item_sk = ss_item_sk
    AND s_store_sk = ss_store_sk
    AND s_state IN ('TN', 'TN', 'TN', 'TN', 'TN', 'TN', 'TN', 'TN')
GROUP BY ROLLUP (i_category, i_class)
ORDER BY
  lochierarchy DESC
  , CASE WHEN lochierarchy = 0
  THEN i_category END
  , rank_within_parent
LIMIT 100
SELECT
  i_item_id,
  avg(cs_quantity) agg1,
  avg(cs_list_price) agg2,
  avg(cs_coupon_amt) agg3,
  avg(cs_sales_price) agg4
FROM catalog_sales, customer_demographics, date_dim, item, promotion
WHERE cs_sold_date_sk = d_date_sk AND
  cs_item_sk = i_item_sk AND
  cs_bill_cdemo_sk = cd_demo_sk AND
  cs_promo_sk = p_promo_sk AND
  cd_gender = 'M' AND
  cd_marital_status = 'S' AND
  cd_education_status = 'College' AND
  (p_channel_email = 'N' OR p_channel_event = 'N') AND
  d_year = 2000
GROUP BY i_item_id
ORDER BY i_item_id
LIMIT 100
SELECT count(*)
FROM store_sales, household_demographics, time_dim, store
WHERE ss_sold_time_sk = time_dim.t_time_sk
  AND ss_hdemo_sk = household_demographics.hd_demo_sk
  AND ss_store_sk = s_store_sk
  AND time_dim.t_hour = 20
  AND time_dim.t_minute >= 30
  AND household_demographics.hd_dep_count = 7
  AND store.s_store_name = 'ese'
ORDER BY count(*)
LIMIT 100
WITH frequent_ss_items AS
(SELECT
    substr(i_item_desc, 1, 30) itemdesc,
    i_item_sk item_sk,
    d_date solddate,
    count(*) cnt
  FROM store_sales, date_dim, item
  WHERE ss_sold_date_sk = d_date_sk
    AND ss_item_sk = i_item_sk
    AND d_year IN (2000, 2000 + 1, 2000 + 2, 2000 + 3)
  GROUP BY substr(i_item_desc, 1, 30), i_item_sk, d_date
  HAVING count(*) > 4),
    max_store_sales AS
  (SELECT max(csales) tpcds_cmax
  FROM (SELECT
    c_customer_sk,
    sum(ss_quantity * ss_sales_price) csales
  FROM store_sales, customer, date_dim
  WHERE ss_customer_sk = c_customer_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year IN (2000, 2000 + 1, 2000 + 2, 2000 + 3)
  GROUP BY c_customer_sk) x),
    best_ss_customer AS
  (SELECT
    c_customer_sk,
    sum(ss_quantity * ss_sales_price) ssales
  FROM store_sales, customer
  WHERE ss_customer_sk = c_customer_sk
  GROUP BY c_customer_sk
  HAVING sum(ss_quantity * ss_sales_price) > (50 / 100.0) *
    (SELECT *
    FROM max_store_sales))
SELECT sum(sales)
FROM ((SELECT cs_quantity * cs_list_price sales
FROM catalog_sales, date_dim
WHERE d_year = 2000
  AND d_moy = 2
  AND cs_sold_date_sk = d_date_sk
  AND cs_item_sk IN (SELECT item_sk
FROM frequent_ss_items)
  AND cs_bill_customer_sk IN (SELECT c_customer_sk
FROM best_ss_customer))
      UNION ALL
      (SELECT ws_quantity * ws_list_price sales
      FROM web_sales, date_dim
      WHERE d_year = 2000
        AND d_moy = 2
        AND ws_sold_date_sk = d_date_sk
        AND ws_item_sk IN (SELECT item_sk
      FROM frequent_ss_items)
        AND ws_bill_customer_sk IN (SELECT c_customer_sk
      FROM best_ss_customer))) y
LIMIT 100
SELECT
  sum(ws_net_paid) AS total_sum,
  i_category,
  i_class,
  grouping(i_category) + grouping(i_class) AS lochierarchy,
  rank()
  OVER (
    PARTITION BY grouping(i_category) + grouping(i_class),
      CASE WHEN grouping(i_class) = 0
        THEN i_category END
    ORDER BY sum(ws_net_paid) DESC) AS rank_within_parent
FROM
  web_sales, date_dim d1, item
WHERE
  d1.d_month_seq BETWEEN 1200 AND 1200 + 11
    AND d1.d_date_sk = ws_sold_date_sk
    AND i_item_sk = ws_item_sk
GROUP BY ROLLUP (i_category, i_class)
ORDER BY
  lochierarchy DESC,
  CASE WHEN lochierarchy = 0
    THEN i_category END,
  rank_within_parent
LIMIT 100
SELECT
  'web' AS channel,
  web.item,
  web.return_ratio,
  web.return_rank,
  web.currency_rank
FROM (
       SELECT
         item,
         return_ratio,
         currency_ratio,
         rank()
         OVER (
           ORDER BY return_ratio) AS return_rank,
         rank()
         OVER (
           ORDER BY currency_ratio) AS currency_rank
       FROM
         (SELECT
           ws.ws_item_sk AS item,
           (cast(sum(coalesce(wr.wr_return_quantity, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(ws.ws_quantity, 0)) AS DECIMAL(15, 4))) AS return_ratio,
           (cast(sum(coalesce(wr.wr_return_amt, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(ws.ws_net_paid, 0)) AS DECIMAL(15, 4))) AS currency_ratio
         FROM
           web_sales ws LEFT OUTER JOIN web_returns wr
             ON (ws.ws_order_number = wr.wr_order_number AND
             ws.ws_item_sk = wr.wr_item_sk)
           , date_dim
         WHERE
           wr.wr_return_amt > 10000
             AND ws.ws_net_profit > 1
             AND ws.ws_net_paid > 0
             AND ws.ws_quantity > 0
             AND ws_sold_date_sk = d_date_sk
             AND d_year = 2001
             AND d_moy = 12
         GROUP BY ws.ws_item_sk
         ) in_web
     ) web
WHERE (web.return_rank <= 10 OR web.currency_rank <= 10)
UNION
SELECT
  'catalog' AS channel,
  catalog.item,
  catalog.return_ratio,
  catalog.return_rank,
  catalog.currency_rank
FROM (
       SELECT
         item,
         return_ratio,
         currency_ratio,
         rank()
         OVER (
           ORDER BY return_ratio) AS return_rank,
         rank()
         OVER (
           ORDER BY currency_ratio) AS currency_rank
       FROM
         (SELECT
           cs.cs_item_sk AS item,
           (cast(sum(coalesce(cr.cr_return_quantity, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(cs.cs_quantity, 0)) AS DECIMAL(15, 4))) AS return_ratio,
           (cast(sum(coalesce(cr.cr_return_amount, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(cs.cs_net_paid, 0)) AS DECIMAL(15, 4))) AS currency_ratio
         FROM
           catalog_sales cs LEFT OUTER JOIN catalog_returns cr
             ON (cs.cs_order_number = cr.cr_order_number AND
             cs.cs_item_sk = cr.cr_item_sk)
           , date_dim
         WHERE
           cr.cr_return_amount > 10000
             AND cs.cs_net_profit > 1
             AND cs.cs_net_paid > 0
             AND cs.cs_quantity > 0
             AND cs_sold_date_sk = d_date_sk
             AND d_year = 2001
             AND d_moy = 12
         GROUP BY cs.cs_item_sk
         ) in_cat
     ) catalog
WHERE (catalog.return_rank <= 10 OR catalog.currency_rank <= 10)
UNION
SELECT
  'store' AS channel,
  store.item,
  store.return_ratio,
  store.return_rank,
  store.currency_rank
FROM (
       SELECT
         item,
         return_ratio,
         currency_ratio,
         rank()
         OVER (
           ORDER BY return_ratio) AS return_rank,
         rank()
         OVER (
           ORDER BY currency_ratio) AS currency_rank
       FROM
         (SELECT
           sts.ss_item_sk AS item,
           (cast(sum(coalesce(sr.sr_return_quantity, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(sts.ss_quantity, 0)) AS DECIMAL(15, 4))) AS return_ratio,
           (cast(sum(coalesce(sr.sr_return_amt, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(sts.ss_net_paid, 0)) AS DECIMAL(15, 4))) AS currency_ratio
         FROM
           store_sales sts LEFT OUTER JOIN store_returns sr
             ON (sts.ss_ticket_number = sr.sr_ticket_number AND sts.ss_item_sk = sr.sr_item_sk)
           , date_dim
         WHERE
           sr.sr_return_amt > 10000
             AND sts.ss_net_profit > 1
             AND sts.ss_net_paid > 0
             AND sts.ss_quantity > 0
             AND ss_sold_date_sk = d_date_sk
             AND d_year = 2001
             AND d_moy = 12
         GROUP BY sts.ss_item_sk
         ) in_store
     ) store
WHERE (store.return_rank <= 10 OR store.currency_rank <= 10)
ORDER BY 1, 4, 5
LIMIT 100
SELECT
  asceding.rnk,
  i1.i_product_name best_performing,
  i2.i_product_name worst_performing
FROM (SELECT *
FROM (SELECT
  item_sk,
  rank()
  OVER (
    ORDER BY rank_col ASC) rnk
FROM (SELECT
  ss_item_sk item_sk,
  avg(ss_net_profit) rank_col
FROM store_sales ss1
WHERE ss_store_sk = 4
GROUP BY ss_item_sk
HAVING avg(ss_net_profit) > 0.9 * (SELECT avg(ss_net_profit) rank_col
FROM store_sales
WHERE ss_store_sk = 4
  AND ss_addr_sk IS NULL
GROUP BY ss_store_sk)) V1) V11
WHERE rnk < 11) asceding,
  (SELECT *
  FROM (SELECT
    item_sk,
    rank()
    OVER (
      ORDER BY rank_col DESC) rnk
  FROM (SELECT
    ss_item_sk item_sk,
    avg(ss_net_profit) rank_col
  FROM store_sales ss1
  WHERE ss_store_sk = 4
  GROUP BY ss_item_sk
  HAVING avg(ss_net_profit) > 0.9 * (SELECT avg(ss_net_profit) rank_col
  FROM store_sales
  WHERE ss_store_sk = 4
    AND ss_addr_sk IS NULL
  GROUP BY ss_store_sk)) V2) V21
  WHERE rnk < 11) descending,
  item i1, item i2
WHERE asceding.rnk = descending.rnk
  AND i1.i_item_sk = asceding.item_sk
  AND i2.i_item_sk = descending.item_sk
ORDER BY asceding.rnk
LIMIT 100
SELECT
  s_store_name,
  s_company_id,
  s_street_number,
  s_street_name,
  s_street_type,
  s_suite_number,
  s_city,
  s_county,
  s_state,
  s_zip,
  sum(CASE WHEN (sr_returned_date_sk - ss_sold_date_sk <= 30)
    THEN 1
      ELSE 0 END)  AS `30 days `,
  sum(CASE WHEN (sr_returned_date_sk - ss_sold_date_sk > 30) AND
    (sr_returned_date_sk - ss_sold_date_sk <= 60)
    THEN 1
      ELSE 0 END)  AS `31 - 60 days `,
  sum(CASE WHEN (sr_returned_date_sk - ss_sold_date_sk > 60) AND
    (sr_returned_date_sk - ss_sold_date_sk <= 90)
    THEN 1
      ELSE 0 END)  AS `61 - 90 days `,
  sum(CASE WHEN (sr_returned_date_sk - ss_sold_date_sk > 90) AND
    (sr_returned_date_sk - ss_sold_date_sk <= 120)
    THEN 1
      ELSE 0 END)  AS `91 - 120 days `,
  sum(CASE WHEN (sr_returned_date_sk - ss_sold_date_sk > 120)
    THEN 1
      ELSE 0 END)  AS `>120 days `
FROM
  store_sales, store_returns, store, date_dim d1, date_dim d2
WHERE
  d2.d_year = 2001
    AND d2.d_moy = 8
    AND ss_ticket_number = sr_ticket_number
    AND ss_item_sk = sr_item_sk
    AND ss_sold_date_sk = d1.d_date_sk
    AND sr_returned_date_sk = d2.d_date_sk
    AND ss_customer_sk = sr_customer_sk
    AND ss_store_sk = s_store_sk
GROUP BY
  s_store_name, s_company_id, s_street_number, s_street_name, s_street_type,
  s_suite_number, s_city, s_county, s_state, s_zip
ORDER BY
  s_store_name, s_company_id, s_street_number, s_street_name, s_street_type,
  s_suite_number, s_city, s_county, s_state, s_zip
LIMIT 100
SELECT *
FROM (SELECT
  i_manager_id,
  sum(ss_sales_price) sum_sales,
  avg(sum(ss_sales_price))
  OVER (PARTITION BY i_manager_id) avg_monthly_sales
FROM item
  , store_sales
  , date_dim
  , store
WHERE ss_item_sk = i_item_sk
  AND ss_sold_date_sk = d_date_sk
  AND ss_store_sk = s_store_sk
  AND d_month_seq IN (1200, 1200 + 1, 1200 + 2, 1200 + 3, 1200 + 4, 1200 + 5, 1200 + 6, 1200 + 7,
                            1200 + 8, 1200 + 9, 1200 + 10, 1200 + 11)
  AND ((i_category IN ('Books', 'Children', 'Electronics')
  AND i_class IN ('personal', 'portable', 'refernece', 'self-help')
  AND i_brand IN ('scholaramalgamalg #14', 'scholaramalgamalg #7',
                  'exportiunivamalg #9', 'scholaramalgamalg #9'))
  OR (i_category IN ('Women', 'Music', 'Men')
  AND i_class IN ('accessories', 'classical', 'fragrances', 'pants')
  AND i_brand IN ('amalgimporto #1', 'edu packscholar #1', 'exportiimporto #1',
                  'importoamalg #1')))
GROUP BY i_manager_id, d_moy) tmp1
WHERE CASE WHEN avg_monthly_sales > 0
  THEN abs(sum_sales - avg_monthly_sales) / avg_monthly_sales
      ELSE NULL END > 0.1
ORDER BY i_manager_id
  , avg_monthly_sales
  , sum_sales
LIMIT 100
WITH v1 AS (
  SELECT
    i_category,
    i_brand,
    cc_name,
    d_year,
    d_moy,
    sum(cs_sales_price) sum_sales,
    avg(sum(cs_sales_price))
    OVER
    (PARTITION BY i_category, i_brand, cc_name, d_year)
    avg_monthly_sales,
    rank()
    OVER
    (PARTITION BY i_category, i_brand, cc_name
      ORDER BY d_year, d_moy) rn
  FROM item, catalog_sales, date_dim, call_center
  WHERE cs_item_sk = i_item_sk AND
    cs_sold_date_sk = d_date_sk AND
    cc_call_center_sk = cs_call_center_sk AND
    (
      d_year = 1999 OR
        (d_year = 1999 - 1 AND d_moy = 12) OR
        (d_year = 1999 + 1 AND d_moy = 1)
    )
  GROUP BY i_category, i_brand,
    cc_name, d_year, d_moy),
    v2 AS (
    SELECT
      v1.i_category,
      v1.i_brand,
      v1.cc_name,
      v1.d_year,
      v1.d_moy,
      v1.avg_monthly_sales,
      v1.sum_sales,
      v1_lag.sum_sales psum,
      v1_lead.sum_sales nsum
    FROM v1, v1 v1_lag, v1 v1_lead
    WHERE v1.i_category = v1_lag.i_category AND
      v1.i_category = v1_lead.i_category AND
      v1.i_brand = v1_lag.i_brand AND
      v1.i_brand = v1_lead.i_brand AND
      v1.cc_name = v1_lag.cc_name AND
      v1.cc_name = v1_lead.cc_name AND
      v1.rn = v1_lag.rn + 1 AND
      v1.rn = v1_lead.rn - 1)
SELECT *
FROM v2
WHERE d_year = 1999 AND
  avg_monthly_sales > 0 AND
  CASE WHEN avg_monthly_sales > 0
    THEN abs(sum_sales - avg_monthly_sales) / avg_monthly_sales
  ELSE NULL END > 0.1
ORDER BY sum_sales - avg_monthly_sales, 3
LIMIT 100
WITH my_customers AS (
  SELECT DISTINCT
    c_customer_sk,
    c_current_addr_sk
  FROM
    (SELECT
       cs_sold_date_sk sold_date_sk,
       cs_bill_customer_sk customer_sk,
       cs_item_sk item_sk
     FROM catalog_sales
     UNION ALL
     SELECT
       ws_sold_date_sk sold_date_sk,
       ws_bill_customer_sk customer_sk,
       ws_item_sk item_sk
     FROM web_sales
    ) cs_or_ws_sales,
    item,
    date_dim,
    customer
  WHERE sold_date_sk = d_date_sk
    AND item_sk = i_item_sk
    AND i_category = 'Women'
    AND i_class = 'maternity'
    AND c_customer_sk = cs_or_ws_sales.customer_sk
    AND d_moy = 12
    AND d_year = 1998
)
  , my_revenue AS (
  SELECT
    c_customer_sk,
    sum(ss_ext_sales_price) AS revenue
  FROM my_customers,
    store_sales,
    customer_address,
    store,
    date_dim
  WHERE c_current_addr_sk = ca_address_sk
    AND ca_county = s_county
    AND ca_state = s_state
    AND ss_sold_date_sk = d_date_sk
    AND c_customer_sk = ss_customer_sk
    AND d_month_seq BETWEEN (SELECT DISTINCT d_month_seq + 1
  FROM date_dim
  WHERE d_year = 1998 AND d_moy = 12)
  AND (SELECT DISTINCT d_month_seq + 3
  FROM date_dim
  WHERE d_year = 1998 AND d_moy = 12)
  GROUP BY c_customer_sk
)
  , segments AS
(SELECT cast((revenue / 50) AS INT) AS segment
  FROM my_revenue)
SELECT
  segment,
  count(*) AS num_customers,
  segment * 50 AS segment_base
FROM segments
GROUP BY segment
ORDER BY segment, num_customers
LIMIT 100
SELECT
  i_item_id,
  i_item_desc,
  s_state,
  count(ss_quantity) AS store_sales_quantitycount,
  avg(ss_quantity) AS store_sales_quantityave,
  stddev_samp(ss_quantity) AS store_sales_quantitystdev,
  stddev_samp(ss_quantity) / avg(ss_quantity) AS store_sales_quantitycov,
  count(sr_return_quantity) as_store_returns_quantitycount,
  avg(sr_return_quantity) as_store_returns_quantityave,
  stddev_samp(sr_return_quantity) as_store_returns_quantitystdev,
  stddev_samp(sr_return_quantity) / avg(sr_return_quantity) AS store_returns_quantitycov,
  count(cs_quantity) AS catalog_sales_quantitycount,
  avg(cs_quantity) AS catalog_sales_quantityave,
  stddev_samp(cs_quantity) / avg(cs_quantity) AS catalog_sales_quantitystdev,
  stddev_samp(cs_quantity) / avg(cs_quantity) AS catalog_sales_quantitycov
FROM store_sales, store_returns, catalog_sales, date_dim d1, date_dim d2, date_dim d3, store, item
WHERE d1.d_quarter_name = '2001Q1'
  AND d1.d_date_sk = ss_sold_date_sk
  AND i_item_sk = ss_item_sk
  AND s_store_sk = ss_store_sk
  AND ss_customer_sk = sr_customer_sk
  AND ss_item_sk = sr_item_sk
  AND ss_ticket_number = sr_ticket_number
  AND sr_returned_date_sk = d2.d_date_sk
  AND d2.d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3')
  AND sr_customer_sk = cs_bill_customer_sk
  AND sr_item_sk = cs_item_sk
  AND cs_sold_date_sk = d3.d_date_sk
  AND d3.d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3')
GROUP BY i_item_id, i_item_desc, s_state
ORDER BY i_item_id, i_item_desc, s_state
LIMIT 100
SELECT *
FROM (
       SELECT
         i_category,
         i_class,
         i_brand,
         s_store_name,
         s_company_name,
         d_moy,
         sum(ss_sales_price) sum_sales,
         avg(sum(ss_sales_price))
         OVER
         (PARTITION BY i_category, i_brand, s_store_name, s_company_name)
         avg_monthly_sales
       FROM item, store_sales, date_dim, store
       WHERE ss_item_sk = i_item_sk AND
         ss_sold_date_sk = d_date_sk AND
         ss_store_sk = s_store_sk AND
         d_year IN (1999) AND
         ((i_category IN ('Books', 'Electronics', 'Sports') AND
           i_class IN ('computers', 'stereo', 'football'))
           OR (i_category IN ('Men', 'Jewelry', 'Women') AND
           i_class IN ('shirts', 'birdal', 'dresses')))
       GROUP BY i_category, i_class, i_brand,
         s_store_name, s_company_name, d_moy) tmp1
WHERE CASE WHEN (avg_monthly_sales <> 0)
  THEN (abs(sum_sales - avg_monthly_sales) / avg_monthly_sales)
      ELSE NULL END > 0.1
ORDER BY sum_sales - avg_monthly_sales, s_store_name
LIMIT 100
WITH v1 AS (
  SELECT
    i_category,
    i_brand,
    s_store_name,
    s_company_name,
    d_year,
    d_moy,
    sum(ss_sales_price) sum_sales,
    avg(sum(ss_sales_price))
    OVER
    (PARTITION BY i_category, i_brand,
      s_store_name, s_company_name, d_year)
    avg_monthly_sales,
    rank()
    OVER
    (PARTITION BY i_category, i_brand,
      s_store_name, s_company_name
      ORDER BY d_year, d_moy) rn
  FROM item, store_sales, date_dim, store
  WHERE ss_item_sk = i_item_sk AND
    ss_sold_date_sk = d_date_sk AND
    ss_store_sk = s_store_sk AND
    (
      d_year = 1999 OR
        (d_year = 1999 - 1 AND d_moy = 12) OR
        (d_year = 1999 + 1 AND d_moy = 1)
    )
  GROUP BY i_category, i_brand,
    s_store_name, s_company_name,
    d_year, d_moy),
    v2 AS (
    SELECT
      v1.i_category,
      v1.i_brand,
      v1.s_store_name,
      v1.s_company_name,
      v1.d_year,
      v1.d_moy,
      v1.avg_monthly_sales,
      v1.sum_sales,
      v1_lag.sum_sales psum,
      v1_lead.sum_sales nsum
    FROM v1, v1 v1_lag, v1 v1_lead
    WHERE v1.i_category = v1_lag.i_category AND
      v1.i_category = v1_lead.i_category AND
      v1.i_brand = v1_lag.i_brand AND
      v1.i_brand = v1_lead.i_brand AND
      v1.s_store_name = v1_lag.s_store_name AND
      v1.s_store_name = v1_lead.s_store_name AND
      v1.s_company_name = v1_lag.s_company_name AND
      v1.s_company_name = v1_lead.s_company_name AND
      v1.rn = v1_lag.rn + 1 AND
      v1.rn = v1_lead.rn - 1)
SELECT *
FROM v2
WHERE d_year = 1999 AND
  avg_monthly_sales > 0 AND
  CASE WHEN avg_monthly_sales > 0
    THEN abs(sum_sales - avg_monthly_sales) / avg_monthly_sales
  ELSE NULL END > 0.1
ORDER BY sum_sales - avg_monthly_sales, 3
LIMIT 100
SELECT
  i_item_id,
  i_item_desc,
  i_current_price
FROM item, inventory, date_dim, store_sales
WHERE i_current_price BETWEEN 62 AND 62 + 30
  AND inv_item_sk = i_item_sk
  AND d_date_sk = inv_date_sk
  AND d_date BETWEEN cast('2000-05-25' AS DATE) AND (cast('2000-05-25' AS DATE) + INTERVAL 60 days)
  AND i_manufact_id IN (129, 270, 821, 423)
  AND inv_quantity_on_hand BETWEEN 100 AND 500
  AND ss_item_sk = i_item_sk
GROUP BY i_item_id, i_item_desc, i_current_price
ORDER BY i_item_id
LIMIT 100
SELECT cast(amc AS DECIMAL(15, 4)) / cast(pmc AS DECIMAL(15, 4)) am_pm_ratio
FROM (SELECT count(*) amc
FROM web_sales, household_demographics, time_dim, web_page
WHERE ws_sold_time_sk = time_dim.t_time_sk
  AND ws_ship_hdemo_sk = household_demographics.hd_demo_sk
  AND ws_web_page_sk = web_page.wp_web_page_sk
  AND time_dim.t_hour BETWEEN 8 AND 8 + 1
  AND household_demographics.hd_dep_count = 6
  AND web_page.wp_char_count BETWEEN 5000 AND 5200) at,
  (SELECT count(*) pmc
  FROM web_sales, household_demographics, time_dim, web_page
  WHERE ws_sold_time_sk = time_dim.t_time_sk
    AND ws_ship_hdemo_sk = household_demographics.hd_demo_sk
    AND ws_web_page_sk = web_page.wp_web_page_sk
    AND time_dim.t_hour BETWEEN 19 AND 19 + 1
    AND household_demographics.hd_dep_count = 6
    AND web_page.wp_char_count BETWEEN 5000 AND 5200) pt
ORDER BY am_pm_ratio
LIMIT 100
SELECT 1 AS `excess discount amount `
FROM
  catalog_sales, item, date_dim
WHERE
  i_manufact_id = 977
    AND i_item_sk = cs_item_sk
    AND d_date BETWEEN '2000-01-27' AND (cast('2000-01-27' AS DATE) + interval 90 days)
    AND d_date_sk = cs_sold_date_sk
    AND cs_ext_discount_amt > (
    SELECT 1.3 * avg(cs_ext_discount_amt)
    FROM catalog_sales, date_dim
    WHERE cs_item_sk = i_item_sk
      AND d_date BETWEEN '2000-01-27]' AND (cast('2000-01-27' AS DATE) + interval 90 days)
      AND d_date_sk = cs_sold_date_sk)
LIMIT 100
SELECT
  w_state,
  i_item_id,
  sum(CASE WHEN (cast(d_date AS DATE) < cast('2000-03-11' AS DATE))
    THEN cs_sales_price - coalesce(cr_refunded_cash, 0)
      ELSE 0 END) AS sales_before,
  sum(CASE WHEN (cast(d_date AS DATE) >= cast('2000-03-11' AS DATE))
    THEN cs_sales_price - coalesce(cr_refunded_cash, 0)
      ELSE 0 END) AS sales_after
FROM
  catalog_sales
  LEFT OUTER JOIN catalog_returns ON
                                    (cs_order_number = cr_order_number
                                      AND cs_item_sk = cr_item_sk)
  , warehouse, item, date_dim
WHERE
  i_current_price BETWEEN 0.99 AND 1.49
    AND i_item_sk = cs_item_sk
    AND cs_warehouse_sk = w_warehouse_sk
    AND cs_sold_date_sk = d_date_sk
    AND d_date BETWEEN (cast('2000-03-11' AS DATE) - INTERVAL 30 days)
  AND (cast('2000-03-11' AS DATE) + INTERVAL 30 days)
GROUP BY w_state, i_item_id
ORDER BY w_state, i_item_id
LIMIT 100
SELECT
  substr(w_warehouse_name, 1, 20),
  sm_type,
  web_name,
  sum(CASE WHEN (ws_ship_date_sk - ws_sold_date_sk <= 30)
    THEN 1
      ELSE 0 END)  AS `30 days `,
  sum(CASE WHEN (ws_ship_date_sk - ws_sold_date_sk > 30) AND
    (ws_ship_date_sk - ws_sold_date_sk <= 60)
    THEN 1
      ELSE 0 END)  AS `31 - 60 days `,
  sum(CASE WHEN (ws_ship_date_sk - ws_sold_date_sk > 60) AND
    (ws_ship_date_sk - ws_sold_date_sk <= 90)
    THEN 1
      ELSE 0 END)  AS `61 - 90 days `,
  sum(CASE WHEN (ws_ship_date_sk - ws_sold_date_sk > 90) AND
    (ws_ship_date_sk - ws_sold_date_sk <= 120)
    THEN 1
      ELSE 0 END)  AS `91 - 120 days `,
  sum(CASE WHEN (ws_ship_date_sk - ws_sold_date_sk > 120)
    THEN 1
      ELSE 0 END)  AS `>120 days `
FROM
  web_sales, warehouse, ship_mode, web_site, date_dim
WHERE
  d_month_seq BETWEEN 1200 AND 1200 + 11
    AND ws_ship_date_sk = d_date_sk
    AND ws_warehouse_sk = w_warehouse_sk
    AND ws_ship_mode_sk = sm_ship_mode_sk
    AND ws_web_site_sk = web_site_sk
GROUP BY
  substr(w_warehouse_name, 1, 20), sm_type, web_name
ORDER BY
  substr(w_warehouse_name, 1, 20), sm_type, web_name
LIMIT 100
SELECT
  channel,
  col_name,
  d_year,
  d_qoy,
  i_category,
  COUNT(*) sales_cnt,
  SUM(ext_sales_price) sales_amt
FROM (
       SELECT
         'store' AS channel,
         ss_store_sk col_name,
         d_year,
         d_qoy,
         i_category,
         ss_ext_sales_price ext_sales_price
       FROM store_sales, item, date_dim
       WHERE ss_store_sk IS NULL
         AND ss_sold_date_sk = d_date_sk
         AND ss_item_sk = i_item_sk
       UNION ALL
       SELECT
         'web' AS channel,
         ws_ship_customer_sk col_name,
         d_year,
         d_qoy,
         i_category,
         ws_ext_sales_price ext_sales_price
       FROM web_sales, item, date_dim
       WHERE ws_ship_customer_sk IS NULL
         AND ws_sold_date_sk = d_date_sk
         AND ws_item_sk = i_item_sk
       UNION ALL
       SELECT
         'catalog' AS channel,
         cs_ship_addr_sk col_name,
         d_year,
         d_qoy,
         i_category,
         cs_ext_sales_price ext_sales_price
       FROM catalog_sales, item, date_dim
       WHERE cs_ship_addr_sk IS NULL
         AND cs_sold_date_sk = d_date_sk
         AND cs_item_sk = i_item_sk) foo
GROUP BY channel, col_name, d_year, d_qoy, i_category
ORDER BY channel, col_name, d_year, d_qoy, i_category
LIMIT 100
SELECT sum(ws_ext_discount_amt) AS `Excess Discount Amount `
FROM web_sales, item, date_dim
WHERE i_manufact_id = 350
  AND i_item_sk = ws_item_sk
  AND d_date BETWEEN '2000-01-27' AND (cast('2000-01-27' AS DATE) + INTERVAL 90 days)
  AND d_date_sk = ws_sold_date_sk
  AND ws_ext_discount_amt >
  (
    SELECT 1.3 * avg(ws_ext_discount_amt)
    FROM web_sales, date_dim
    WHERE ws_item_sk = i_item_sk
      AND d_date BETWEEN '2000-01-27' AND (cast('2000-01-27' AS DATE) + INTERVAL 90 days)
      AND d_date_sk = ws_sold_date_sk
  )
ORDER BY sum(ws_ext_discount_amt)
LIMIT 100
SELECT
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(ss_ext_sales_price) AS itemrevenue,
  sum(ss_ext_sales_price) * 100 / sum(sum(ss_ext_sales_price))
  OVER
  (PARTITION BY i_class) AS revenueratio
FROM
  store_sales, item, date_dim
WHERE
  ss_item_sk = i_item_sk
    AND i_category IN ('Sports', 'Books', 'Home')
    AND ss_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('1999-02-22' AS DATE)
  AND (cast('1999-02-22' AS DATE) + INTERVAL 30 days)
GROUP BY
  i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY
  i_category, i_class, i_item_id, i_item_desc, revenueratio
WITH ss_items AS
(SELECT
    i_item_id item_id,
    sum(ss_ext_sales_price) ss_item_rev
  FROM store_sales, item, date_dim
  WHERE ss_item_sk = i_item_sk
    AND d_date IN (SELECT d_date
  FROM date_dim
  WHERE d_week_seq = (SELECT d_week_seq
  FROM date_dim
  WHERE d_date = '2000-01-03'))
    AND ss_sold_date_sk = d_date_sk
  GROUP BY i_item_id),
    cs_items AS
  (SELECT
    i_item_id item_id,
    sum(cs_ext_sales_price) cs_item_rev
  FROM catalog_sales, item, date_dim
  WHERE cs_item_sk = i_item_sk
    AND d_date IN (SELECT d_date
  FROM date_dim
  WHERE d_week_seq = (SELECT d_week_seq
  FROM date_dim
  WHERE d_date = '2000-01-03'))
    AND cs_sold_date_sk = d_date_sk
  GROUP BY i_item_id),
    ws_items AS
  (SELECT
    i_item_id item_id,
    sum(ws_ext_sales_price) ws_item_rev
  FROM web_sales, item, date_dim
  WHERE ws_item_sk = i_item_sk
    AND d_date IN (SELECT d_date
  FROM date_dim
  WHERE d_week_seq = (SELECT d_week_seq
  FROM date_dim
  WHERE d_date = '2000-01-03'))
    AND ws_sold_date_sk = d_date_sk
  GROUP BY i_item_id)
SELECT
  ss_items.item_id,
  ss_item_rev,
  ss_item_rev / (ss_item_rev + cs_item_rev + ws_item_rev) / 3 * 100 ss_dev,
  cs_item_rev,
  cs_item_rev / (ss_item_rev + cs_item_rev + ws_item_rev) / 3 * 100 cs_dev,
  ws_item_rev,
  ws_item_rev / (ss_item_rev + cs_item_rev + ws_item_rev) / 3 * 100 ws_dev,
  (ss_item_rev + cs_item_rev + ws_item_rev) / 3 average
FROM ss_items, cs_items, ws_items
WHERE ss_items.item_id = cs_items.item_id
  AND ss_items.item_id = ws_items.item_id
  AND ss_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
  AND ss_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
  AND cs_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
  AND cs_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
  AND ws_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
  AND ws_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
ORDER BY item_id, ss_item_rev
LIMIT 100
WITH web_v1 AS (
  SELECT
    ws_item_sk item_sk,
    d_date,
    sum(sum(ws_sales_price))
    OVER (PARTITION BY ws_item_sk
      ORDER BY d_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cume_sales
  FROM web_sales, date_dim
  WHERE ws_sold_date_sk = d_date_sk
    AND d_month_seq BETWEEN 1200 AND 1200 + 11
    AND ws_item_sk IS NOT NULL
  GROUP BY ws_item_sk, d_date),
    store_v1 AS (
    SELECT
      ss_item_sk item_sk,
      d_date,
      sum(sum(ss_sales_price))
      OVER (PARTITION BY ss_item_sk
        ORDER BY d_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cume_sales
    FROM store_sales, date_dim
    WHERE ss_sold_date_sk = d_date_sk
      AND d_month_seq BETWEEN 1200 AND 1200 + 11
      AND ss_item_sk IS NOT NULL
    GROUP BY ss_item_sk, d_date)
SELECT *
FROM (SELECT
  item_sk,
  d_date,
  web_sales,
  store_sales,
  max(web_sales)
  OVER (PARTITION BY item_sk
    ORDER BY d_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) web_cumulative,
  max(store_sales)
  OVER (PARTITION BY item_sk
    ORDER BY d_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) store_cumulative
FROM (SELECT
  CASE WHEN web.item_sk IS NOT NULL
    THEN web.item_sk
  ELSE store.item_sk END item_sk,
  CASE WHEN web.d_date IS NOT NULL
    THEN web.d_date
  ELSE store.d_date END d_date,
  web.cume_sales web_sales,
  store.cume_sales store_sales
FROM web_v1 web FULL OUTER JOIN store_v1 store ON (web.item_sk = store.item_sk
  AND web.d_date = store.d_date)
     ) x) y
WHERE web_cumulative > store_cumulative
ORDER BY item_sk, d_date
LIMIT 100
SELECT
  substr(w_warehouse_name, 1, 20),
  sm_type,
  cc_name,
  sum(CASE WHEN (cs_ship_date_sk - cs_sold_date_sk <= 30)
    THEN 1
      ELSE 0 END)  AS `30 days `,
  sum(CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 30) AND
    (cs_ship_date_sk - cs_sold_date_sk <= 60)
    THEN 1
      ELSE 0 END)  AS `31 - 60 days `,
  sum(CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 60) AND
    (cs_ship_date_sk - cs_sold_date_sk <= 90)
    THEN 1
      ELSE 0 END)  AS `61 - 90 days `,
  sum(CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 90) AND
    (cs_ship_date_sk - cs_sold_date_sk <= 120)
    THEN 1
      ELSE 0 END)  AS `91 - 120 days `,
  sum(CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 120)
    THEN 1
      ELSE 0 END)  AS `>120 days `
FROM
  catalog_sales, warehouse, ship_mode, call_center, date_dim
WHERE
  d_month_seq BETWEEN 1200 AND 1200 + 11
    AND cs_ship_date_sk = d_date_sk
    AND cs_warehouse_sk = w_warehouse_sk
    AND cs_ship_mode_sk = sm_ship_mode_sk
    AND cs_call_center_sk = cc_call_center_sk
GROUP BY
  substr(w_warehouse_name, 1, 20), sm_type, cc_name
ORDER BY substr(w_warehouse_name, 1, 20), sm_type, cc_name
LIMIT 100
SELECT
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag,
  ss_ticket_number,
  cnt
FROM
  (SELECT
    ss_ticket_number,
    ss_customer_sk,
    count(*) cnt
  FROM store_sales, date_dim, store, household_demographics
  WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
    AND store_sales.ss_store_sk = store.s_store_sk
    AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    AND (date_dim.d_dom BETWEEN 1 AND 3 OR date_dim.d_dom BETWEEN 25 AND 28)
    AND (household_demographics.hd_buy_potential = '>10000' OR
    household_demographics.hd_buy_potential = 'unknown')
    AND household_demographics.hd_vehicle_count > 0
    AND (CASE WHEN household_demographics.hd_vehicle_count > 0
    THEN household_demographics.hd_dep_count / household_demographics.hd_vehicle_count
         ELSE NULL
         END) > 1.2
    AND date_dim.d_year IN (1999, 1999 + 1, 1999 + 2)
    AND store.s_county IN
    ('Williamson County', 'Williamson County', 'Williamson County', 'Williamson County',
     'Williamson County', 'Williamson County', 'Williamson County', 'Williamson County')
  GROUP BY ss_ticket_number, ss_customer_sk) dn, customer
WHERE ss_customer_sk = c_customer_sk
  AND cnt BETWEEN 15 AND 20
ORDER BY c_last_name, c_first_name, c_salutation, c_preferred_cust_flag DESC
SELECT
  w_warehouse_name,
  w_warehouse_sq_ft,
  w_city,
  w_county,
  w_state,
  w_country,
  ship_carriers,
  year,
  sum(jan_sales) AS jan_sales,
  sum(feb_sales) AS feb_sales,
  sum(mar_sales) AS mar_sales,
  sum(apr_sales) AS apr_sales,
  sum(may_sales) AS may_sales,
  sum(jun_sales) AS jun_sales,
  sum(jul_sales) AS jul_sales,
  sum(aug_sales) AS aug_sales,
  sum(sep_sales) AS sep_sales,
  sum(oct_sales) AS oct_sales,
  sum(nov_sales) AS nov_sales,
  sum(dec_sales) AS dec_sales,
  sum(jan_sales / w_warehouse_sq_ft) AS jan_sales_per_sq_foot,
  sum(feb_sales / w_warehouse_sq_ft) AS feb_sales_per_sq_foot,
  sum(mar_sales / w_warehouse_sq_ft) AS mar_sales_per_sq_foot,
  sum(apr_sales / w_warehouse_sq_ft) AS apr_sales_per_sq_foot,
  sum(may_sales / w_warehouse_sq_ft) AS may_sales_per_sq_foot,
  sum(jun_sales / w_warehouse_sq_ft) AS jun_sales_per_sq_foot,
  sum(jul_sales / w_warehouse_sq_ft) AS jul_sales_per_sq_foot,
  sum(aug_sales / w_warehouse_sq_ft) AS aug_sales_per_sq_foot,
  sum(sep_sales / w_warehouse_sq_ft) AS sep_sales_per_sq_foot,
  sum(oct_sales / w_warehouse_sq_ft) AS oct_sales_per_sq_foot,
  sum(nov_sales / w_warehouse_sq_ft) AS nov_sales_per_sq_foot,
  sum(dec_sales / w_warehouse_sq_ft) AS dec_sales_per_sq_foot,
  sum(jan_net) AS jan_net,
  sum(feb_net) AS feb_net,
  sum(mar_net) AS mar_net,
  sum(apr_net) AS apr_net,
  sum(may_net) AS may_net,
  sum(jun_net) AS jun_net,
  sum(jul_net) AS jul_net,
  sum(aug_net) AS aug_net,
  sum(sep_net) AS sep_net,
  sum(oct_net) AS oct_net,
  sum(nov_net) AS nov_net,
  sum(dec_net) AS dec_net
FROM (
       (SELECT
         w_warehouse_name,
         w_warehouse_sq_ft,
         w_city,
         w_county,
         w_state,
         w_country,
         concat('DHL', ',', 'BARIAN') AS ship_carriers,
         d_year AS year,
         sum(CASE WHEN d_moy = 1
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS jan_sales,
         sum(CASE WHEN d_moy = 2
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS feb_sales,
         sum(CASE WHEN d_moy = 3
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS mar_sales,
         sum(CASE WHEN d_moy = 4
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS apr_sales,
         sum(CASE WHEN d_moy = 5
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS may_sales,
         sum(CASE WHEN d_moy = 6
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS jun_sales,
         sum(CASE WHEN d_moy = 7
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS jul_sales,
         sum(CASE WHEN d_moy = 8
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS aug_sales,
         sum(CASE WHEN d_moy = 9
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS sep_sales,
         sum(CASE WHEN d_moy = 10
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS oct_sales,
         sum(CASE WHEN d_moy = 11
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS nov_sales,
         sum(CASE WHEN d_moy = 12
           THEN ws_ext_sales_price * ws_quantity
             ELSE 0 END) AS dec_sales,
         sum(CASE WHEN d_moy = 1
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS jan_net,
         sum(CASE WHEN d_moy = 2
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS feb_net,
         sum(CASE WHEN d_moy = 3
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS mar_net,
         sum(CASE WHEN d_moy = 4
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS apr_net,
         sum(CASE WHEN d_moy = 5
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS may_net,
         sum(CASE WHEN d_moy = 6
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS jun_net,
         sum(CASE WHEN d_moy = 7
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS jul_net,
         sum(CASE WHEN d_moy = 8
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS aug_net,
         sum(CASE WHEN d_moy = 9
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS sep_net,
         sum(CASE WHEN d_moy = 10
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS oct_net,
         sum(CASE WHEN d_moy = 11
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS nov_net,
         sum(CASE WHEN d_moy = 12
           THEN ws_net_paid * ws_quantity
             ELSE 0 END) AS dec_net
       FROM
         web_sales, warehouse, date_dim, time_dim, ship_mode
       WHERE
         ws_warehouse_sk = w_warehouse_sk
           AND ws_sold_date_sk = d_date_sk
           AND ws_sold_time_sk = t_time_sk
           AND ws_ship_mode_sk = sm_ship_mode_sk
           AND d_year = 2001
           AND t_time BETWEEN 30838 AND 30838 + 28800
           AND sm_carrier IN ('DHL', 'BARIAN')
       GROUP BY
         w_warehouse_name, w_warehouse_sq_ft, w_city, w_county, w_state, w_country, d_year)
       UNION ALL
       (SELECT
         w_warehouse_name,
         w_warehouse_sq_ft,
         w_city,
         w_county,
         w_state,
         w_country,
         concat('DHL', ',', 'BARIAN') AS ship_carriers,
         d_year AS year,
         sum(CASE WHEN d_moy = 1
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS jan_sales,
         sum(CASE WHEN d_moy = 2
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS feb_sales,
         sum(CASE WHEN d_moy = 3
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS mar_sales,
         sum(CASE WHEN d_moy = 4
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS apr_sales,
         sum(CASE WHEN d_moy = 5
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS may_sales,
         sum(CASE WHEN d_moy = 6
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS jun_sales,
         sum(CASE WHEN d_moy = 7
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS jul_sales,
         sum(CASE WHEN d_moy = 8
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS aug_sales,
         sum(CASE WHEN d_moy = 9
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS sep_sales,
         sum(CASE WHEN d_moy = 10
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS oct_sales,
         sum(CASE WHEN d_moy = 11
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS nov_sales,
         sum(CASE WHEN d_moy = 12
           THEN cs_sales_price * cs_quantity
             ELSE 0 END) AS dec_sales,
         sum(CASE WHEN d_moy = 1
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS jan_net,
         sum(CASE WHEN d_moy = 2
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS feb_net,
         sum(CASE WHEN d_moy = 3
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS mar_net,
         sum(CASE WHEN d_moy = 4
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS apr_net,
         sum(CASE WHEN d_moy = 5
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS may_net,
         sum(CASE WHEN d_moy = 6
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS jun_net,
         sum(CASE WHEN d_moy = 7
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS jul_net,
         sum(CASE WHEN d_moy = 8
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS aug_net,
         sum(CASE WHEN d_moy = 9
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS sep_net,
         sum(CASE WHEN d_moy = 10
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS oct_net,
         sum(CASE WHEN d_moy = 11
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS nov_net,
         sum(CASE WHEN d_moy = 12
           THEN cs_net_paid_inc_tax * cs_quantity
             ELSE 0 END) AS dec_net
       FROM
         catalog_sales, warehouse, date_dim, time_dim, ship_mode
       WHERE
         cs_warehouse_sk = w_warehouse_sk
           AND cs_sold_date_sk = d_date_sk
           AND cs_sold_time_sk = t_time_sk
           AND cs_ship_mode_sk = sm_ship_mode_sk
           AND d_year = 2001
           AND t_time BETWEEN 30838 AND 30838 + 28800
           AND sm_carrier IN ('DHL', 'BARIAN')
       GROUP BY
         w_warehouse_name, w_warehouse_sq_ft, w_city, w_county, w_state, w_country, d_year
       )
     ) x
GROUP BY
  w_warehouse_name, w_warehouse_sq_ft, w_city, w_county, w_state, w_country,
  ship_carriers, year
ORDER BY w_warehouse_name
LIMIT 100
WITH ws AS
(SELECT
    d_year AS ws_sold_year,
    ws_item_sk,
    ws_bill_customer_sk ws_customer_sk,
    sum(ws_quantity) ws_qty,
    sum(ws_wholesale_cost) ws_wc,
    sum(ws_sales_price) ws_sp
  FROM web_sales
    LEFT JOIN web_returns ON wr_order_number = ws_order_number AND ws_item_sk = wr_item_sk
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
  WHERE wr_order_number IS NULL
  GROUP BY d_year, ws_item_sk, ws_bill_customer_sk
),
    cs AS
  (SELECT
    d_year AS cs_sold_year,
    cs_item_sk,
    cs_bill_customer_sk cs_customer_sk,
    sum(cs_quantity) cs_qty,
    sum(cs_wholesale_cost) cs_wc,
    sum(cs_sales_price) cs_sp
  FROM catalog_sales
    LEFT JOIN catalog_returns ON cr_order_number = cs_order_number AND cs_item_sk = cr_item_sk
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
  WHERE cr_order_number IS NULL
  GROUP BY d_year, cs_item_sk, cs_bill_customer_sk
  ),
    ss AS
  (SELECT
    d_year AS ss_sold_year,
    ss_item_sk,
    ss_customer_sk,
    sum(ss_quantity) ss_qty,
    sum(ss_wholesale_cost) ss_wc,
    sum(ss_sales_price) ss_sp
  FROM store_sales
    LEFT JOIN store_returns ON sr_ticket_number = ss_ticket_number AND ss_item_sk = sr_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
  WHERE sr_ticket_number IS NULL
  GROUP BY d_year, ss_item_sk, ss_customer_sk
  )
SELECT
  round(ss_qty / (coalesce(ws_qty + cs_qty, 1)), 2) ratio,
  ss_qty store_qty,
  ss_wc store_wholesale_cost,
  ss_sp store_sales_price,
  coalesce(ws_qty, 0) + coalesce(cs_qty, 0) other_chan_qty,
  coalesce(ws_wc, 0) + coalesce(cs_wc, 0) other_chan_wholesale_cost,
  coalesce(ws_sp, 0) + coalesce(cs_sp, 0) other_chan_sales_price
FROM ss
  LEFT JOIN ws
    ON (ws_sold_year = ss_sold_year AND ws_item_sk = ss_item_sk AND ws_customer_sk = ss_customer_sk)
  LEFT JOIN cs
    ON (cs_sold_year = ss_sold_year AND cs_item_sk = ss_item_sk AND cs_customer_sk = ss_customer_sk)
WHERE coalesce(ws_qty, 0) > 0 AND coalesce(cs_qty, 0) > 0 AND ss_sold_year = 2000
ORDER BY
  ratio,
  ss_qty DESC, ss_wc DESC, ss_sp DESC,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price,
  round(ss_qty / (coalesce(ws_qty + cs_qty, 1)), 2)
LIMIT 100
SELECT
  dt.d_year,
  item.i_brand_id brand_id,
  item.i_brand brand,
  sum(ss_ext_sales_price) ext_price
FROM date_dim dt, store_sales, item
WHERE dt.d_date_sk = store_sales.ss_sold_date_sk
  AND store_sales.ss_item_sk = item.i_item_sk
  AND item.i_manager_id = 1
  AND dt.d_moy = 11
  AND dt.d_year = 2000
GROUP BY dt.d_year, item.i_brand, item.i_brand_id
ORDER BY dt.d_year, ext_price DESC, brand_id
LIMIT 100
SELECT
  c_last_name,
  c_first_name,
  substr(s_city, 1, 30),
  ss_ticket_number,
  amt,
  profit
FROM
  (SELECT
    ss_ticket_number,
    ss_customer_sk,
    store.s_city,
    sum(ss_coupon_amt) amt,
    sum(ss_net_profit) profit
  FROM store_sales, date_dim, store, household_demographics
  WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
    AND store_sales.ss_store_sk = store.s_store_sk
    AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    AND (household_demographics.hd_dep_count = 6 OR
    household_demographics.hd_vehicle_count > 2)
    AND date_dim.d_dow = 1
    AND date_dim.d_year IN (1999, 1999 + 1, 1999 + 2)
    AND store.s_number_employees BETWEEN 200 AND 295
  GROUP BY ss_ticket_number, ss_customer_sk, ss_addr_sk, store.s_city) ms, customer
WHERE ss_customer_sk = c_customer_sk
ORDER BY c_last_name, c_first_name, substr(s_city, 1, 30), profit
LIMIT 100
SELECT sum(ss_quantity)
FROM store_sales, store, customer_demographics, customer_address, date_dim
WHERE s_store_sk = ss_store_sk
  AND ss_sold_date_sk = d_date_sk AND d_year = 2001
  AND
  (
    (
      cd_demo_sk = ss_cdemo_sk
        AND
        cd_marital_status = 'M'
        AND
        cd_education_status = '4 yr Degree'
        AND
        ss_sales_price BETWEEN 100.00 AND 150.00
    )
      OR
      (
        cd_demo_sk = ss_cdemo_sk
          AND
          cd_marital_status = 'D'
          AND
          cd_education_status = '2 yr Degree'
          AND
          ss_sales_price BETWEEN 50.00 AND 100.00
      )
      OR
      (
        cd_demo_sk = ss_cdemo_sk
          AND
          cd_marital_status = 'S'
          AND
          cd_education_status = 'College'
          AND
          ss_sales_price BETWEEN 150.00 AND 200.00
      )
  )
  AND
  (
    (
      ss_addr_sk = ca_address_sk
        AND
        ca_country = 'United States'
        AND
        ca_state IN ('CO', 'OH', 'TX')
        AND ss_net_profit BETWEEN 0 AND 2000
    )
      OR
      (ss_addr_sk = ca_address_sk
        AND
        ca_country = 'United States'
        AND
        ca_state IN ('OR', 'MN', 'KY')
        AND ss_net_profit BETWEEN 150 AND 3000
      )
      OR
      (ss_addr_sk = ca_address_sk
        AND
        ca_country = 'United States'
        AND
        ca_state IN ('VA', 'CA', 'MS')
        AND ss_net_profit BETWEEN 50 AND 25000
      )
  )
SELECT
  i_item_id,
  ca_country,
  ca_state,
  ca_county,
  avg(cast(cs_quantity AS DECIMAL(12, 2))) agg1,
  avg(cast(cs_list_price AS DECIMAL(12, 2))) agg2,
  avg(cast(cs_coupon_amt AS DECIMAL(12, 2))) agg3,
  avg(cast(cs_sales_price AS DECIMAL(12, 2))) agg4,
  avg(cast(cs_net_profit AS DECIMAL(12, 2))) agg5,
  avg(cast(c_birth_year AS DECIMAL(12, 2))) agg6,
  avg(cast(cd1.cd_dep_count AS DECIMAL(12, 2))) agg7
FROM catalog_sales, customer_demographics cd1,
  customer_demographics cd2, customer, customer_address, date_dim, item
WHERE cs_sold_date_sk = d_date_sk AND
  cs_item_sk = i_item_sk AND
  cs_bill_cdemo_sk = cd1.cd_demo_sk AND
  cs_bill_customer_sk = c_customer_sk AND
  cd1.cd_gender = 'F' AND
  cd1.cd_education_status = 'Unknown' AND
  c_current_cdemo_sk = cd2.cd_demo_sk AND
  c_current_addr_sk = ca_address_sk AND
  c_birth_month IN (1, 6, 8, 9, 12, 2) AND
  d_year = 1998 AND
  ca_state IN ('MS', 'IN', 'ND', 'OK', 'NM', 'VA', 'MS')
GROUP BY ROLLUP (i_item_id, ca_country, ca_state, ca_county)
ORDER BY ca_country, ca_state, ca_county, i_item_id
LIMIT 100
SELECT
  count(DISTINCT cs_order_number) AS `order count `,
  sum(cs_ext_ship_cost) AS `total shipping cost `,
  sum(cs_net_profit) AS `total net profit `
FROM
  catalog_sales cs1, date_dim, customer_address, call_center
WHERE
  d_date BETWEEN '2002-02-01' AND (CAST('2002-02-01' AS DATE) + INTERVAL 60 days)
    AND cs1.cs_ship_date_sk = d_date_sk
    AND cs1.cs_ship_addr_sk = ca_address_sk
    AND ca_state = 'GA'
    AND cs1.cs_call_center_sk = cc_call_center_sk
    AND cc_county IN
    ('Williamson County', 'Williamson County', 'Williamson County', 'Williamson County', 'Williamson County')
    AND EXISTS(SELECT *
               FROM catalog_sales cs2
               WHERE cs1.cs_order_number = cs2.cs_order_number
                 AND cs1.cs_warehouse_sk <> cs2.cs_warehouse_sk)
    AND NOT EXISTS(SELECT *
                   FROM catalog_returns cr1
                   WHERE cs1.cs_order_number = cr1.cr_order_number)
ORDER BY count(DISTINCT cs_order_number)
LIMIT 100
SELECT
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number,
  extended_price,
  extended_tax,
  list_price
FROM (SELECT
  ss_ticket_number,
  ss_customer_sk,
  ca_city bought_city,
  sum(ss_ext_sales_price) extended_price,
  sum(ss_ext_list_price) list_price,
  sum(ss_ext_tax) extended_tax
FROM store_sales, date_dim, store, household_demographics, customer_address
WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
  AND store_sales.ss_store_sk = store.s_store_sk
  AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
  AND store_sales.ss_addr_sk = customer_address.ca_address_sk
  AND date_dim.d_dom BETWEEN 1 AND 2
  AND (household_demographics.hd_dep_count = 4 OR
  household_demographics.hd_vehicle_count = 3)
  AND date_dim.d_year IN (1999, 1999 + 1, 1999 + 2)
  AND store.s_city IN ('Midway', 'Fairview')
GROUP BY ss_ticket_number, ss_customer_sk, ss_addr_sk, ca_city) dn,
  customer,
  customer_address current_addr
WHERE ss_customer_sk = c_customer_sk
  AND customer.c_current_addr_sk = current_addr.ca_address_sk
  AND current_addr.ca_city <> bought_city
ORDER BY c_last_name, ss_ticket_number
LIMIT 100
SELECT count(*)
FROM (
       SELECT DISTINCT
         c_last_name,
         c_first_name,
         d_date
       FROM store_sales, date_dim, customer
       WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
         AND store_sales.ss_customer_sk = customer.c_customer_sk
         AND d_month_seq BETWEEN 1200 AND 1200 + 11
       INTERSECT
       SELECT DISTINCT
         c_last_name,
         c_first_name,
         d_date
       FROM catalog_sales, date_dim, customer
       WHERE catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
         AND catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
         AND d_month_seq BETWEEN 1200 AND 1200 + 11
       INTERSECT
       SELECT DISTINCT
         c_last_name,
         c_first_name,
         d_date
       FROM web_sales, date_dim, customer
       WHERE web_sales.ws_sold_date_sk = date_dim.d_date_sk
         AND web_sales.ws_bill_customer_sk = customer.c_customer_sk
         AND d_month_seq BETWEEN 1200 AND 1200 + 11
     ) hot_cust
LIMIT 100
WITH year_total AS (
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    d_year AS year,
    sum(ss_net_paid) year_total,
    's' sale_type
  FROM
    customer, store_sales, date_dim
  WHERE c_customer_sk = ss_customer_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year IN (2001, 2001 + 1)
  GROUP BY
    c_customer_id, c_first_name, c_last_name, d_year
  UNION ALL
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    d_year AS year,
    sum(ws_net_paid) year_total,
    'w' sale_type
  FROM
    customer, web_sales, date_dim
  WHERE c_customer_sk = ws_bill_customer_sk
    AND ws_sold_date_sk = d_date_sk
    AND d_year IN (2001, 2001 + 1)
  GROUP BY
    c_customer_id, c_first_name, c_last_name, d_year)
SELECT
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name
FROM
  year_total t_s_firstyear, year_total t_s_secyear,
  year_total t_w_firstyear, year_total t_w_secyear
WHERE t_s_secyear.customer_id = t_s_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_w_secyear.customer_id
  AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
  AND t_s_firstyear.sale_type = 's'
  AND t_w_firstyear.sale_type = 'w'
  AND t_s_secyear.sale_type = 's'
  AND t_w_secyear.sale_type = 'w'
  AND t_s_firstyear.year = 2001
  AND t_s_secyear.year = 2001 + 1
  AND t_w_firstyear.year = 2001
  AND t_w_secyear.year = 2001 + 1
  AND t_s_firstyear.year_total > 0
  AND t_w_firstyear.year_total > 0
  AND CASE WHEN t_w_firstyear.year_total > 0
  THEN t_w_secyear.year_total / t_w_firstyear.year_total
      ELSE NULL END
  > CASE WHEN t_s_firstyear.year_total > 0
  THEN t_s_secyear.year_total / t_s_firstyear.year_total
    ELSE NULL END
ORDER BY 1, 1, 1
LIMIT 100
WITH year_total AS (
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum(ss_ext_list_price - ss_ext_discount_amt) year_total,
    's' sale_type
  FROM customer, store_sales, date_dim
  WHERE c_customer_sk = ss_customer_sk
    AND ss_sold_date_sk = d_date_sk
  GROUP BY c_customer_id
    , c_first_name
    , c_last_name
    , d_year
    , c_preferred_cust_flag
    , c_birth_country
    , c_login
    , c_email_address
    , d_year
  UNION ALL
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum(ws_ext_list_price - ws_ext_discount_amt) year_total,
    'w' sale_type
  FROM customer, web_sales, date_dim
  WHERE c_customer_sk = ws_bill_customer_sk
    AND ws_sold_date_sk = d_date_sk
  GROUP BY
    c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country,
    c_login, c_email_address, d_year)
SELECT t_s_secyear.customer_preferred_cust_flag
FROM year_total t_s_firstyear
  , year_total t_s_secyear
  , year_total t_w_firstyear
  , year_total t_w_secyear
WHERE t_s_secyear.customer_id = t_s_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_w_secyear.customer_id
  AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
  AND t_s_firstyear.sale_type = 's'
  AND t_w_firstyear.sale_type = 'w'
  AND t_s_secyear.sale_type = 's'
  AND t_w_secyear.sale_type = 'w'
  AND t_s_firstyear.dyear = 2001
  AND t_s_secyear.dyear = 2001 + 1
  AND t_w_firstyear.dyear = 2001
  AND t_w_secyear.dyear = 2001 + 1
  AND t_s_firstyear.year_total > 0
  AND t_w_firstyear.year_total > 0
  AND CASE WHEN t_w_firstyear.year_total > 0
  THEN t_w_secyear.year_total / t_w_firstyear.year_total
      ELSE NULL END
  > CASE WHEN t_s_firstyear.year_total > 0
  THEN t_s_secyear.year_total / t_s_firstyear.year_total
    ELSE NULL END
ORDER BY t_s_secyear.customer_preferred_cust_flag
LIMIT 100
WITH sr_items AS
(SELECT
    i_item_id item_id,
    sum(sr_return_quantity) sr_item_qty
  FROM store_returns, item, date_dim
  WHERE sr_item_sk = i_item_sk
    AND d_date IN (SELECT d_date
  FROM date_dim
  WHERE d_week_seq IN
    (SELECT d_week_seq
    FROM date_dim
    WHERE d_date IN ('2000-06-30', '2000-09-27', '2000-11-17')))
    AND sr_returned_date_sk = d_date_sk
  GROUP BY i_item_id),
    cr_items AS
  (SELECT
    i_item_id item_id,
    sum(cr_return_quantity) cr_item_qty
  FROM catalog_returns, item, date_dim
  WHERE cr_item_sk = i_item_sk
    AND d_date IN (SELECT d_date
  FROM date_dim
  WHERE d_week_seq IN
    (SELECT d_week_seq
    FROM date_dim
    WHERE d_date IN ('2000-06-30', '2000-09-27', '2000-11-17')))
    AND cr_returned_date_sk = d_date_sk
  GROUP BY i_item_id),
    wr_items AS
  (SELECT
    i_item_id item_id,
    sum(wr_return_quantity) wr_item_qty
  FROM web_returns, item, date_dim
  WHERE wr_item_sk = i_item_sk AND d_date IN
    (SELECT d_date
    FROM date_dim
    WHERE d_week_seq IN
      (SELECT d_week_seq
      FROM date_dim
      WHERE d_date IN ('2000-06-30', '2000-09-27', '2000-11-17')))
    AND wr_returned_date_sk = d_date_sk
  GROUP BY i_item_id)
SELECT
  sr_items.item_id,
  sr_item_qty,
  sr_item_qty / (sr_item_qty + cr_item_qty + wr_item_qty) / 3.0 * 100 sr_dev,
  cr_item_qty,
  cr_item_qty / (sr_item_qty + cr_item_qty + wr_item_qty) / 3.0 * 100 cr_dev,
  wr_item_qty,
  wr_item_qty / (sr_item_qty + cr_item_qty + wr_item_qty) / 3.0 * 100 wr_dev,
  (sr_item_qty + cr_item_qty + wr_item_qty) / 3.0 average
FROM sr_items, cr_items, wr_items
WHERE sr_items.item_id = cr_items.item_id
  AND sr_items.item_id = wr_items.item_id
ORDER BY sr_items.item_id, sr_item_qty
LIMIT 100
WITH ssci AS (
  SELECT
    ss_customer_sk customer_sk,
    ss_item_sk item_sk
  FROM store_sales, date_dim
  WHERE ss_sold_date_sk = d_date_sk
    AND d_month_seq BETWEEN 1200 AND 1200 + 11
  GROUP BY ss_customer_sk, ss_item_sk),
    csci AS (
    SELECT
      cs_bill_customer_sk customer_sk,
      cs_item_sk item_sk
    FROM catalog_sales, date_dim
    WHERE cs_sold_date_sk = d_date_sk
      AND d_month_seq BETWEEN 1200 AND 1200 + 11
    GROUP BY cs_bill_customer_sk, cs_item_sk)
SELECT
  sum(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NULL
    THEN 1
      ELSE 0 END) store_only,
  sum(CASE WHEN ssci.customer_sk IS NULL AND csci.customer_sk IS NOT NULL
    THEN 1
      ELSE 0 END) catalog_only,
  sum(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NOT NULL
    THEN 1
      ELSE 0 END) store_and_catalog
FROM ssci
  FULL OUTER JOIN csci ON (ssci.customer_sk = csci.customer_sk
    AND ssci.item_sk = csci.item_sk)
LIMIT 100
WITH ssales AS
(SELECT
    c_last_name,
    c_first_name,
    s_store_name,
    ca_state,
    s_state,
    i_color,
    i_current_price,
    i_manager_id,
    i_units,
    i_size,
    sum(ss_net_paid) netpaid
  FROM store_sales, store_returns, store, item, customer, customer_address
  WHERE ss_ticket_number = sr_ticket_number
    AND ss_item_sk = sr_item_sk
    AND ss_customer_sk = c_customer_sk
    AND ss_item_sk = i_item_sk
    AND ss_store_sk = s_store_sk
    AND c_birth_country = upper(ca_country)
    AND s_zip = ca_zip
    AND s_market_id = 8
  GROUP BY c_last_name, c_first_name, s_store_name, ca_state, s_state, i_color,
    i_current_price, i_manager_id, i_units, i_size)
SELECT
  c_last_name,
  c_first_name,
  s_store_name,
  sum(netpaid) paid
FROM ssales
WHERE i_color = 'pale'
GROUP BY c_last_name, c_first_name, s_store_name
HAVING sum(netpaid) > (SELECT 0.05 * avg(netpaid)
FROM ssales)
SELECT
  count(DISTINCT ws_order_number) AS `order count `,
  sum(ws_ext_ship_cost) AS `total shipping cost `,
  sum(ws_net_profit) AS `total net profit `
FROM
  web_sales ws1, date_dim, customer_address, web_site
WHERE
  d_date BETWEEN '1999-02-01' AND
  (CAST('1999-02-01' AS DATE) + INTERVAL 60 days)
    AND ws1.ws_ship_date_sk = d_date_sk
    AND ws1.ws_ship_addr_sk = ca_address_sk
    AND ca_state = 'IL'
    AND ws1.ws_web_site_sk = web_site_sk
    AND web_company_name = 'pri'
    AND EXISTS(SELECT *
               FROM web_sales ws2
               WHERE ws1.ws_order_number = ws2.ws_order_number
                 AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk)
    AND NOT EXISTS(SELECT *
                   FROM web_returns wr1
                   WHERE ws1.ws_order_number = wr1.wr_order_number)
ORDER BY count(DISTINCT ws_order_number)
LIMIT 100
WITH ss AS
(SELECT
    ca_county,
    d_qoy,
    d_year,
    sum(ss_ext_sales_price) AS store_sales
  FROM store_sales, date_dim, customer_address
  WHERE ss_sold_date_sk = d_date_sk
    AND ss_addr_sk = ca_address_sk
  GROUP BY ca_county, d_qoy, d_year),
    ws AS
  (SELECT
    ca_county,
    d_qoy,
    d_year,
    sum(ws_ext_sales_price) AS web_sales
  FROM web_sales, date_dim, customer_address
  WHERE ws_sold_date_sk = d_date_sk
    AND ws_bill_addr_sk = ca_address_sk
  GROUP BY ca_county, d_qoy, d_year)
SELECT
  ss1.ca_county,
  ss1.d_year,
  ws2.web_sales / ws1.web_sales web_q1_q2_increase,
  ss2.store_sales / ss1.store_sales store_q1_q2_increase,
  ws3.web_sales / ws2.web_sales web_q2_q3_increase,
  ss3.store_sales / ss2.store_sales store_q2_q3_increase
FROM
  ss ss1, ss ss2, ss ss3, ws ws1, ws ws2, ws ws3
WHERE
  ss1.d_qoy = 1
    AND ss1.d_year = 2000
    AND ss1.ca_county = ss2.ca_county
    AND ss2.d_qoy = 2
    AND ss2.d_year = 2000
    AND ss2.ca_county = ss3.ca_county
    AND ss3.d_qoy = 3
    AND ss3.d_year = 2000
    AND ss1.ca_county = ws1.ca_county
    AND ws1.d_qoy = 1
    AND ws1.d_year = 2000
    AND ws1.ca_county = ws2.ca_county
    AND ws2.d_qoy = 2
    AND ws2.d_year = 2000
    AND ws1.ca_county = ws3.ca_county
    AND ws3.d_qoy = 3
    AND ws3.d_year = 2000
    AND CASE WHEN ws1.web_sales > 0
    THEN ws2.web_sales / ws1.web_sales
        ELSE NULL END
    > CASE WHEN ss1.store_sales > 0
    THEN ss2.store_sales / ss1.store_sales
      ELSE NULL END
    AND CASE WHEN ws2.web_sales > 0
    THEN ws3.web_sales / ws2.web_sales
        ELSE NULL END
    > CASE WHEN ss2.store_sales > 0
    THEN ss3.store_sales / ss2.store_sales
      ELSE NULL END
ORDER BY ss1.ca_county
WITH inv AS
(SELECT
    w_warehouse_name,
    w_warehouse_sk,
    i_item_sk,
    d_moy,
    stdev,
    mean,
    CASE mean
    WHEN 0
      THEN NULL
    ELSE stdev / mean END cov
  FROM (SELECT
    w_warehouse_name,
    w_warehouse_sk,
    i_item_sk,
    d_moy,
    stddev_samp(inv_quantity_on_hand) stdev,
    avg(inv_quantity_on_hand) mean
  FROM inventory, item, warehouse, date_dim
  WHERE inv_item_sk = i_item_sk
    AND inv_warehouse_sk = w_warehouse_sk
    AND inv_date_sk = d_date_sk
    AND d_year = 2001
  GROUP BY w_warehouse_name, w_warehouse_sk, i_item_sk, d_moy) foo
  WHERE CASE mean
        WHEN 0
          THEN 0
        ELSE stdev / mean END > 1)
SELECT
  inv1.w_warehouse_sk,
  inv1.i_item_sk,
  inv1.d_moy,
  inv1.mean,
  inv1.cov,
  inv2.w_warehouse_sk,
  inv2.i_item_sk,
  inv2.d_moy,
  inv2.mean,
  inv2.cov
FROM inv inv1, inv inv2
WHERE inv1.i_item_sk = inv2.i_item_sk
  AND inv1.w_warehouse_sk = inv2.w_warehouse_sk
  AND inv1.d_moy = 1
  AND inv2.d_moy = 1 + 1
  AND inv1.cov > 1.5
ORDER BY inv1.w_warehouse_sk, inv1.i_item_sk, inv1.d_moy, inv1.mean, inv1.cov
  , inv2.d_moy, inv2.mean, inv2.cov
SELECT
  c_customer_id AS customer_id,
  concat(c_last_name, ', ', c_first_name) AS customername
FROM customer
  , customer_address
  , customer_demographics
  , household_demographics
  , income_band
  , store_returns
WHERE ca_city = 'Edgewood'
  AND c_current_addr_sk = ca_address_sk
  AND ib_lower_bound >= 38128
  AND ib_upper_bound <= 38128 + 50000
  AND ib_income_band_sk = hd_income_band_sk
  AND cd_demo_sk = c_current_cdemo_sk
  AND hd_demo_sk = c_current_hdemo_sk
  AND sr_cdemo_sk = cd_demo_sk
ORDER BY c_customer_id
LIMIT 100
-- This is a new query in TPCDS v2.7
with results as (
    select
        i_category,
        i_class,
        i_brand,
        i_product_name,
        d_year,
        d_qoy,
        d_moy,
        s_store_id,
        sum(coalesce(ss_sales_price * ss_quantity, 0)) sumsales
    from
      store_sales, date_dim, store, item
    where
      ss_sold_date_sk=d_date_sk
        and ss_item_sk=i_item_sk
        and ss_store_sk = s_store_sk
        and d_month_seq between 1212 and 1212 + 11
    group by
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      s_store_id),
results_rollup as (
    select
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      s_store_id,
      sumsales
    from
      results
    union all
    select
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      null s_store_id,
      sum(sumsales) sumsales
    from
      results
    group by
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy
    union all
    select
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      null d_moy,
      null s_store_id,
      sum(sumsales) sumsales
    from
      results
    group by
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy
    union all
    select
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      null d_qoy,
      null d_moy,
      null s_store_id,
      sum(sumsales) sumsales
    from
      results
    group by
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year
    union all
    select
      i_category,
      i_class,
      i_brand,
      i_product_name,
      null d_year,
      null d_qoy,
      null d_moy,
      null s_store_id,
      sum(sumsales) sumsales
  from
    results
  group by
    i_category,
    i_class,
    i_brand,
    i_product_name
  union all
  select
    i_category,
    i_class,
    i_brand,
    null i_product_name,
    null d_year,
    null d_qoy,
    null d_moy,
    null s_store_id,
    sum(sumsales) sumsales
  from
    results
  group by
    i_category,
    i_class,
    i_brand
  union all
  select
    i_category,
    i_class,
    null i_brand,
    null i_product_name,
    null d_year,
    null d_qoy,
    null d_moy,
    null s_store_id,
    sum(sumsales) sumsales
  from
    results
  group by
    i_category,
    i_class
  union all
  select
    i_category,
    null i_class,
    null i_brand,
    null i_product_name,
    null d_year,
    null d_qoy,
    null d_moy,
    null s_store_id,
    sum(sumsales) sumsales
  from results
  group by
    i_category
  union all
  select
    null i_category,
    null i_class,
    null i_brand,
    null i_product_name,
    null d_year,
    null d_qoy,
    null d_moy,
    null s_store_id,
    sum(sumsales) sumsales
  from
    results)
select
  *
from (
    select
      i_category,
      i_class,
      i_brand,
      i_product_name,
      d_year,
      d_qoy,
      d_moy,
      s_store_id,
      sumsales,
      rank() over (partition by i_category order by sumsales desc) rk
    from results_rollup) dw2
where
  rk <= 100
order by
  i_category,
  i_class,
  i_brand,
  i_product_name,
  d_year,
  d_qoy,
  d_moy,
  s_store_id,
  sumsales,
  rk
limit 100
-- This is a new query in TPCDS v2.7
with ssr as(
    select
      s_store_id,
      sum(sales_price) as sales,
      sum(profit) as profit,
      sum(return_amt) as returns,
      sum(net_loss) as profit_loss
    from (
        select
          ss_store_sk as store_sk,
          ss_sold_date_sk as date_sk,
          ss_ext_sales_price as sales_price,
          ss_net_profit as profit,
          cast(0 as decimal(7,2)) as return_amt,
          cast(0 as decimal(7,2)) as net_loss
        from
          store_sales
        union all
        select
          sr_store_sk as store_sk,
          sr_returned_date_sk as date_sk,
          cast(0 as decimal(7,2)) as sales_price,
          cast(0 as decimal(7,2)) as profit,
          sr_return_amt as return_amt,
          sr_net_loss as net_loss
        from
          store_returns) salesreturns,
      date_dim,
      store
    where
      date_sk = d_date_sk and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + INTERVAL 14 days)
        and store_sk = s_store_sk
    group by
      s_store_id),
csr as (
    select
      cp_catalog_page_id,
      sum(sales_price) as sales,
      sum(profit) as profit,
      sum(return_amt) as returns,
      sum(net_loss) as profit_loss
    from (
        select
          cs_catalog_page_sk as page_sk,
          cs_sold_date_sk  as date_sk,
          cs_ext_sales_price as sales_price,
          cs_net_profit as profit,
          cast(0 as decimal(7,2)) as return_amt,
          cast(0 as decimal(7,2)) as net_loss
        from catalog_sales
        union all
        select
          cr_catalog_page_sk as page_sk,
          cr_returned_date_sk as date_sk,
          cast(0 as decimal(7,2)) as sales_price,
          cast(0 as decimal(7,2)) as profit,
          cr_return_amount as return_amt,
          cr_net_loss as net_loss
        from catalog_returns) salesreturns,
      date_dim,
      catalog_page
    where
      date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) +  INTERVAL 14 days)
        and page_sk = cp_catalog_page_sk
    group by
      cp_catalog_page_id),
wsr as (
    select
      web_site_id,
      sum(sales_price) as sales,
      sum(profit) as profit,
      sum(return_amt) as returns,
      sum(net_loss) as profit_loss
    from (
        select
          ws_web_site_sk as wsr_web_site_sk,
          ws_sold_date_sk  as date_sk,
          ws_ext_sales_price as sales_price,
          ws_net_profit as profit,
          cast(0 as decimal(7,2)) as return_amt,
          cast(0 as decimal(7,2)) as net_loss
        from
          web_sales
        union all
        select
          ws_web_site_sk as wsr_web_site_sk,
          wr_returned_date_sk as date_sk,
          cast(0 as decimal(7,2)) as sales_price,
          cast(0 as decimal(7,2)) as profit,
          wr_return_amt as return_amt,
          wr_net_loss as net_loss
        from
          web_returns
        left outer join web_sales on (
          wr_item_sk = ws_item_sk and wr_order_number = ws_order_number)
      ) salesreturns,
      date_dim,
      web_site
    where
      date_sk = d_date_sk and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) +  INTERVAL 14 days)
        and wsr_web_site_sk = web_site_sk
    group by
      web_site_id),
results as (
    select
      channel,
      id,
      sum(sales) as sales,
      sum(returns) as returns,
      sum(profit) as profit
    from (
      select
        'store channel' as channel,
        'store' || s_store_id as id,
        sales,
        returns,
        (profit - profit_loss) as profit
      from
        ssr
      union all
      select
        'catalog channel' as channel,
        'catalog_page' || cp_catalog_page_id as id,
        sales,
        returns,
        (profit - profit_loss) as profit
      from
        csr
      union all
      select
        'web channel' as channel,
        'web_site' || web_site_id as id,
        sales,
        returns,
        (profit - profit_loss) as profit
    from
      wsr) x
    group by
      channel, id)
select
  channel, id, sales, returns, profit
from (
  select channel, id, sales, returns, profit
  from results
  union
  select channel, null as id, sum(sales), sum(returns), sum(profit)
  from results
  group by channel
  union
  select null as channel, null as id, sum(sales), sum(returns), sum(profit)
  from results) foo
  order by channel, id
limit 100
-- This is a new query in TPCDS v2.7
with results as (
    select
      sum(ss_net_profit) as ss_net_profit,
      sum(ss_ext_sales_price) as ss_ext_sales_price,
      sum(ss_net_profit)/sum(ss_ext_sales_price) as gross_margin,
      i_category,
      i_class,
      0 as g_category,
      0 as g_class
    from
      store_sales,
      date_dim d1,
      item,
      store
    where
      d1.d_year = 2001
        and d1.d_date_sk = ss_sold_date_sk
        and i_item_sk  = ss_item_sk
        and s_store_sk  = ss_store_sk
        and s_state in ('TN', 'TN', 'TN', 'TN', 'TN', 'TN', 'TN', 'TN')
    group by
      i_category,
      i_class),
 results_rollup as (
     select
       gross_margin,
       i_category,
       i_class,
       0 as t_category,
       0 as t_class,
       0 as lochierarchy
     from
       results
     union
     select
       sum(ss_net_profit) / sum(ss_ext_sales_price) as gross_margin,
       i_category, NULL AS i_class,
       0 as t_category,
       1 as t_class,
       1 as lochierarchy
     from
       results
     group by
       i_category
     union
     select
       sum(ss_net_profit) / sum(ss_ext_sales_price) as gross_margin,
       NULL AS i_category,
       NULL AS i_class,
       1 as t_category,
       1 as t_class,
       2 as lochierarchy
     from
       results)
select
  gross_margin,
  i_category,
  i_class,
  lochierarchy,
  rank() over (
    partition by lochierarchy, case when t_class = 0 then i_category end
    order by gross_margin asc) as rank_within_parent
from
  results_rollup
order by
  lochierarchy desc,
  case when lochierarchy = 0 then i_category end,
  rank_within_parent
limit 100
-- This is a new query in TPCDS v2.7
with results as (
    select
      sum(ss_net_profit) as total_sum,
      s_state ,s_county,
      0 as gstate,
      0 as g_county
    from
      store_sales, date_dim d1, store
    where
      d1.d_month_seq between 1212 and 1212 + 11
        and d1.d_date_sk = ss_sold_date_sk
        and s_store_sk  = ss_store_sk
        and s_state in (
            select s_state
            from (
                select
                  s_state as s_state,
                  rank() over (partition by s_state order by sum(ss_net_profit) desc) as ranking
                from store_sales, store, date_dim
                where d_month_seq between 1212 and 1212 + 11
                  and d_date_sk = ss_sold_date_sk
                  and s_store_sk  = ss_store_sk
                group by s_state) tmp1
              where ranking <= 5)
    group by
      s_state, s_county),
results_rollup as (
    select
      total_sum,
      s_state,
      s_county,
      0 as g_state,
      0 as g_county,
      0 as lochierarchy
    from results
    union
    select
      sum(total_sum) as total_sum,s_state,
      NULL as s_county,
      0 as g_state,
      1 as g_county,
      1 as lochierarchy
    from results
    group by s_state
    union
    select
      sum(total_sum) as total_sum,
      NULL as s_state,
      NULL as s_county,
      1 as g_state,
      1 as g_county,
      2 as lochierarchy
    from results)
select
  total_sum,
  s_state,
  s_county,
  lochierarchy,
  rank() over (
      partition by lochierarchy,
      case when g_county = 0 then s_state end
      order by total_sum desc) as rank_within_parent
from
  results_rollup
order by
  lochierarchy desc,
  case when lochierarchy = 0 then s_state end,
  rank_within_parent
limit 100
WITH cs_ui AS
(SELECT
    cs_item_sk,
    sum(cs_ext_list_price) AS sale,
    sum(cr_refunded_cash + cr_reversed_charge + cr_store_credit) AS refund
  FROM catalog_sales
    , catalog_returns
  WHERE cs_item_sk = cr_item_sk
    AND cs_order_number = cr_order_number
  GROUP BY cs_item_sk
  HAVING sum(cs_ext_list_price) > 2 * sum(cr_refunded_cash + cr_reversed_charge + cr_store_credit)),
    cross_sales AS
  (SELECT
    i_product_name product_name,
    i_item_sk item_sk,
    s_store_name store_name,
    s_zip store_zip,
    ad1.ca_street_number b_street_number,
    ad1.ca_street_name b_streen_name,
    ad1.ca_city b_city,
    ad1.ca_zip b_zip,
    ad2.ca_street_number c_street_number,
    ad2.ca_street_name c_street_name,
    ad2.ca_city c_city,
    ad2.ca_zip c_zip,
    d1.d_year AS syear,
    d2.d_year AS fsyear,
    d3.d_year s2year,
    count(*) cnt,
    sum(ss_wholesale_cost) s1,
    sum(ss_list_price) s2,
    sum(ss_coupon_amt) s3
  FROM store_sales, store_returns, cs_ui, date_dim d1, date_dim d2, date_dim d3,
    store, customer, customer_demographics cd1, customer_demographics cd2,
    promotion, household_demographics hd1, household_demographics hd2,
    customer_address ad1, customer_address ad2, income_band ib1, income_band ib2, item
  WHERE ss_store_sk = s_store_sk AND
    ss_sold_date_sk = d1.d_date_sk AND
    ss_customer_sk = c_customer_sk AND
    ss_cdemo_sk = cd1.cd_demo_sk AND
    ss_hdemo_sk = hd1.hd_demo_sk AND
    ss_addr_sk = ad1.ca_address_sk AND
    ss_item_sk = i_item_sk AND
    ss_item_sk = sr_item_sk AND
    ss_ticket_number = sr_ticket_number AND
    ss_item_sk = cs_ui.cs_item_sk AND
    c_current_cdemo_sk = cd2.cd_demo_sk AND
    c_current_hdemo_sk = hd2.hd_demo_sk AND
    c_current_addr_sk = ad2.ca_address_sk AND
    c_first_sales_date_sk = d2.d_date_sk AND
    c_first_shipto_date_sk = d3.d_date_sk AND
    ss_promo_sk = p_promo_sk AND
    hd1.hd_income_band_sk = ib1.ib_income_band_sk AND
    hd2.hd_income_band_sk = ib2.ib_income_band_sk AND
    cd1.cd_marital_status <> cd2.cd_marital_status AND
    i_color IN ('purple', 'burlywood', 'indian', 'spring', 'floral', 'medium') AND
    i_current_price BETWEEN 64 AND 64 + 10 AND
    i_current_price BETWEEN 64 + 1 AND 64 + 15
  GROUP BY
    i_product_name,
    i_item_sk,
    s_store_name,
    s_zip,
    ad1.ca_street_number,
    ad1.ca_street_name,
    ad1.ca_city,
    ad1.ca_zip,
    ad2.ca_street_number,
    ad2.ca_street_name,
    ad2.ca_city,
    ad2.ca_zip,
    d1.d_year,
    d2.d_year,
    d3.d_year
  )
SELECT
  cs1.product_name,
  cs1.store_name,
  cs1.store_zip,
  cs1.b_street_number,
  cs1.b_streen_name,
  cs1.b_city,
  cs1.b_zip,
  cs1.c_street_number,
  cs1.c_street_name,
  cs1.c_city,
  cs1.c_zip,
  cs1.syear,
  cs1.cnt,
  cs1.s1,
  cs1.s2,
  cs1.s3,
  cs2.s1,
  cs2.s2,
  cs2.s3,
  cs2.syear,
  cs2.cnt
FROM cross_sales cs1, cross_sales cs2
WHERE cs1.item_sk = cs2.item_sk AND
  cs1.syear = 1999 AND
  cs2.syear = 1999 + 1 AND
  cs2.cnt <= cs1.cnt AND
  cs1.store_name = cs2.store_name AND
  cs1.store_zip = cs2.store_zip
ORDER BY
  cs1.product_name,
  cs1.store_name,
  cs2.cnt,
  -- The two columns below are newly added in TPCDS v2.7
  cs1.s1,
  cs2.s1
-- This is a new query in TPCDS v2.7
with results as (
    select
      i_product_name,
      i_brand,
      i_class,
      i_category,
      avg(inv_quantity_on_hand) qoh
    from
      inventory, date_dim, item, warehouse
    where
      inv_date_sk = d_date_sk
        and inv_item_sk = i_item_sk
        and inv_warehouse_sk = w_warehouse_sk
        and d_month_seq between 1212 and 1212 + 11
    group by
      i_product_name,
      i_brand,
      i_class,
      i_category),
results_rollup as (
    select
      i_product_name,
      i_brand,
      i_class,
      i_category,
      avg(qoh) qoh
    from
      results
    group by
      i_product_name,
      i_brand,
      i_class,
      i_category
    union all
    select
      i_product_name,
      i_brand,
      i_class,
      null i_category,
      avg(qoh) qoh
    from
      results
    group by
      i_product_name,
      i_brand,
      i_class
    union all
    select
      i_product_name,
      i_brand,
      null i_class,
      null i_category,
      avg(qoh) qoh
    from
      results
    group by
      i_product_name,
      i_brand
    union all
    select
      i_product_name,
      null i_brand,
      null i_class,
      null i_category,
      avg(qoh) qoh
    from
      results
    group by
      i_product_name
    union all
    select
      null i_product_name,
      null i_brand,
      null i_class,
      null i_category,
      avg(qoh) qoh
    from
      results)
select
  i_product_name,
  i_brand,
  i_class,
  i_category,
  qoh
from
  results_rollup
order by
  qoh,
  i_product_name,
  i_brand,
  i_class,
  i_category
limit 100
SELECT
  i_item_desc,
  w_warehouse_name,
  d1.d_week_seq,
  count(CASE WHEN p_promo_sk IS NULL
    THEN 1
        ELSE 0 END) no_promo,
  count(CASE WHEN p_promo_sk IS NOT NULL
    THEN 1
        ELSE 0 END) promo,
  count(*) total_cnt
FROM catalog_sales
  JOIN inventory ON (cs_item_sk = inv_item_sk)
  JOIN warehouse ON (w_warehouse_sk = inv_warehouse_sk)
  JOIN item ON (i_item_sk = cs_item_sk)
  JOIN customer_demographics ON (cs_bill_cdemo_sk = cd_demo_sk)
  JOIN household_demographics ON (cs_bill_hdemo_sk = hd_demo_sk)
  JOIN date_dim d1 ON (cs_sold_date_sk = d1.d_date_sk)
  JOIN date_dim d2 ON (inv_date_sk = d2.d_date_sk)
  JOIN date_dim d3 ON (cs_ship_date_sk = d3.d_date_sk)
  LEFT OUTER JOIN promotion ON (cs_promo_sk = p_promo_sk)
  LEFT OUTER JOIN catalog_returns ON (cr_item_sk = cs_item_sk AND cr_order_number = cs_order_number)
-- q72 in TPCDS v1.4 had conditions below:
-- WHERE d1.d_week_seq = d2.d_week_seq
--   AND inv_quantity_on_hand < cs_quantity
--   AND d3.d_date > (cast(d1.d_date AS DATE) + interval 5 days)
--   AND hd_buy_potential = '>10000'
--   AND d1.d_year = 1999
--   AND hd_buy_potential = '>10000'
--   AND cd_marital_status = 'D'
--   AND d1.d_year = 1999
WHERE d1.d_week_seq = d2.d_week_seq
    AND inv_quantity_on_hand < cs_quantity
    AND d3.d_date > d1.d_date + INTERVAL 5 days
    AND hd_buy_potential = '1001-5000'
    AND d1.d_year = 2001
    AND cd_marital_status = 'M'
GROUP BY i_item_desc, w_warehouse_name, d1.d_week_seq
ORDER BY total_cnt DESC, i_item_desc, w_warehouse_name, d_week_seq
LIMIT 100
-- This is a new query in TPCDS v2.7
with ss as (
    select
      s_store_sk,
      sum(ss_ext_sales_price) as sales,
      sum(ss_net_profit) as profit
    from
      store_sales, date_dim, store
    where
      ss_sold_date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + interval 30 days)
        and ss_store_sk = s_store_sk
    group by
      s_store_sk),
sr as (
    select
      s_store_sk,
      sum(sr_return_amt) as returns,
      sum(sr_net_loss) as profit_loss
    from
      store_returns, date_dim, store
    where
      sr_returned_date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + interval 30 days)
        and sr_store_sk = s_store_sk
     group by
       s_store_sk),
cs as (
    select
      cs_call_center_sk,
      sum(cs_ext_sales_price) as sales,
      sum(cs_net_profit) as profit
    from
      catalog_sales,
      date_dim
    where
      cs_sold_date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + interval 30 days)
    group by
      cs_call_center_sk),
 cr as (
     select
       sum(cr_return_amount) as returns,
       sum(cr_net_loss) as profit_loss
     from catalog_returns,
       date_dim
     where
       cr_returned_date_sk = d_date_sk
         and d_date between cast('1998-08-04' as date)
         and (cast('1998-08-04' as date) + interval 30 days)),
ws as ( select wp_web_page_sk,
        sum(ws_ext_sales_price) as sales,
        sum(ws_net_profit) as profit
 from web_sales,
      date_dim,
      web_page
 where ws_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and (cast('1998-08-04' as date) +  interval 30 days)
       and ws_web_page_sk = wp_web_page_sk
 group by wp_web_page_sk), 
 wr as
 (select wp_web_page_sk,
        sum(wr_return_amt) as returns,
        sum(wr_net_loss) as profit_loss
 from web_returns,
      date_dim,
      web_page
 where wr_returned_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and (cast('1998-08-04' as date) +  interval 30 days)
       and wr_web_page_sk = wp_web_page_sk
 group by wp_web_page_sk)
 ,
 results as
 (select channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , ss.s_store_sk as id
        , sales
        , coalesce(returns, 0) as returns
        , (profit - coalesce(profit_loss,0)) as profit
 from   ss left join sr
        on  ss.s_store_sk = sr.s_store_sk
 union all
 select 'catalog channel' as channel
        , cs_call_center_sk as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from  cs
       , cr
 union all
 select 'web channel' as channel
        , ws.wp_web_page_sk as id
        , sales
        , coalesce(returns, 0) returns
        , (profit - coalesce(profit_loss,0)) as profit
 from   ws left join wr
        on  ws.wp_web_page_sk = wr.wp_web_page_sk
 ) x
 group by channel, id )

  select  *
 from (
 select channel, id, sales, returns, profit from  results
 union
 select channel, NULL AS id, sum(sales) as sales, sum(returns) as returns, sum(profit) as profit from  results group by channel
 union
 select NULL AS channel, NULL AS id, sum(sales) as sales, sum(returns) as returns, sum(profit) as profit from  results
) foo
order by
  channel, id
limit 100
SELECT
  i_item_id, -- This column did not exist in TPCDS v1.4
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(cs_ext_sales_price) AS itemrevenue,
  sum(cs_ext_sales_price) * 100 / sum(sum(cs_ext_sales_price))
  OVER
  (PARTITION BY i_class) AS revenueratio
FROM catalog_sales, item, date_dim
WHERE cs_item_sk = i_item_sk
  AND i_category IN ('Sports', 'Books', 'Home')
  AND cs_sold_date_sk = d_date_sk
  AND d_date BETWEEN cast('1999-02-22' AS DATE)
AND (cast('1999-02-22' AS DATE) + INTERVAL 30 days)
GROUP BY i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY i_category, i_class, i_item_id, i_item_desc, revenueratio
LIMIT 100
SELECT
  -- select list of q35 in TPCDS v1.4 is below:
  -- ca_state,
  -- cd_gender,
  -- cd_marital_status,
  -- count(*) cnt1,
  -- min(cd_dep_count),
  -- max(cd_dep_count),
  -- avg(cd_dep_count),
  -- cd_dep_employed_count,
  -- count(*) cnt2,
  -- min(cd_dep_employed_count),
  -- max(cd_dep_employed_count),
  -- avg(cd_dep_employed_count),
  -- cd_dep_college_count,
  -- count(*) cnt3,
  -- min(cd_dep_college_count),
  -- max(cd_dep_college_count),
  -- avg(cd_dep_college_count)
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  count(*) cnt1,
  avg(cd_dep_count),
  max(cd_dep_count),
  sum(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  avg(cd_dep_employed_count),
  max(cd_dep_employed_count),
  sum(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  avg(cd_dep_college_count),
  max(cd_dep_college_count),
  sum(cd_dep_college_count)
FROM
  customer c, customer_address ca, customer_demographics
WHERE
  c.c_current_addr_sk = ca.ca_address_sk AND
    cd_demo_sk = c.c_current_cdemo_sk AND
    exists(SELECT *
           FROM store_sales, date_dim
           WHERE c.c_customer_sk = ss_customer_sk AND
             ss_sold_date_sk = d_date_sk AND
             d_year = 2002 AND
             d_qoy < 4) AND
    (exists(SELECT *
            FROM web_sales, date_dim
            WHERE c.c_customer_sk = ws_bill_customer_sk AND
              ws_sold_date_sk = d_date_sk AND
              d_year = 2002 AND
              d_qoy < 4) OR
      exists(SELECT *
             FROM catalog_sales, date_dim
             WHERE c.c_customer_sk = cs_ship_customer_sk AND
               cs_sold_date_sk = d_date_sk AND
               d_year = 2002 AND
               d_qoy < 4))
GROUP BY ca_state, cd_gender, cd_marital_status, cd_dep_count,
  cd_dep_employed_count, cd_dep_college_count
ORDER BY ca_state, cd_gender, cd_marital_status, cd_dep_count,
  cd_dep_employed_count, cd_dep_college_count
LIMIT 100
SELECT
  i_product_name,
  i_brand,
  i_class,
  i_category,
  avg(inv_quantity_on_hand) qoh
FROM inventory, date_dim, item, warehouse
WHERE inv_date_sk = d_date_sk
  AND inv_item_sk = i_item_sk
  -- q22 in TPCDS v1.4 had a condition below:
  -- AND inv_warehouse_sk = w_warehouse_sk
  AND d_month_seq BETWEEN 1200 AND 1200 + 11
GROUP BY ROLLUP (i_product_name, i_brand, i_class, i_category)
ORDER BY qoh, i_product_name, i_brand, i_class, i_category
LIMIT 100
SELECT
  a.ca_state state,
  count(*) cnt
FROM
  customer_address a, customer c, store_sales s, date_dim d, item i
WHERE a.ca_address_sk = c.c_current_addr_sk
  AND c.c_customer_sk = s.ss_customer_sk
  AND s.ss_sold_date_sk = d.d_date_sk
  AND s.ss_item_sk = i.i_item_sk
  AND d.d_month_seq =
  (SELECT DISTINCT (d_month_seq)
  FROM date_dim
  WHERE d_year = 2000 AND d_moy = 1)
  AND i.i_current_price > 1.2 *
  (SELECT avg(j.i_current_price)
  FROM item j
  WHERE j.i_category = i.i_category)
GROUP BY a.ca_state
HAVING count(*) >= 10
-- order-by list of q6 in TPCDS v1.4 is below:
-- order by cnt
order by cnt, a.ca_state
LIMIT 100
-- This query is the alternative form of sql/core/src/test/resources/tpcds/q14b.sql
with cross_items as (
    select
      i_item_sk ss_item_sk
    from item, (
        select
          iss.i_brand_id brand_id,
          iss.i_class_id class_id,
          iss.i_category_id category_id
        from
          store_sales, item iss, date_dim d1
        where
          ss_item_sk = iss.i_item_sk
            and ss_sold_date_sk = d1.d_date_sk
            and d1.d_year between 1999 AND 1999 + 2
        intersect
        select
          ics.i_brand_id,
          ics.i_class_id,
          ics.i_category_id
        from
          catalog_sales, item ics, date_dim d2
        where
          cs_item_sk = ics.i_item_sk
            and cs_sold_date_sk = d2.d_date_sk
            and d2.d_year between 1999 AND 1999 + 2
        intersect
        select
          iws.i_brand_id,
          iws.i_class_id,
          iws.i_category_id
        from
          web_sales, item iws, date_dim d3
        where
          ws_item_sk = iws.i_item_sk
            and ws_sold_date_sk = d3.d_date_sk
            and d3.d_year between 1999 AND 1999 + 2) x
    where
      i_brand_id = brand_id
        and i_class_id = class_id
        and i_category_id = category_id),
avg_sales as (
    select
      avg(quantity*list_price) average_sales
    from (
        select
          ss_quantity quantity,
          ss_list_price list_price
         from
           store_sales, date_dim
         where
           ss_sold_date_sk = d_date_sk
             and d_year between 1999 and 2001
         union all
         select
           cs_quantity quantity,
           cs_list_price list_price
         from
           catalog_sales, date_dim
         where
           cs_sold_date_sk = d_date_sk
             and d_year between 1998 and 1998 + 2
         union all
         select
           ws_quantity quantity,
           ws_list_price list_price
         from
           web_sales, date_dim
         where
           ws_sold_date_sk = d_date_sk
             and d_year between 1998 and 1998 + 2) x),
results AS (
    select
      channel,
      i_brand_id,
      i_class_id,
      i_category_id,
      sum(sales) sum_sales,
      sum(number_sales) number_sales
    from (
        select
          'store' channel,
          i_brand_id,i_class_id,
          i_category_id,
          sum(ss_quantity*ss_list_price) sales,
          count(*) number_sales
       from
         store_sales, item, date_dim
       where
         ss_item_sk in (select ss_item_sk from cross_items)
           and ss_item_sk = i_item_sk
           and ss_sold_date_sk = d_date_sk
           and d_year = 1998 + 2
           and d_moy = 11
       group by
         i_brand_id,
         i_class_id,
         i_category_id
       having
         sum(ss_quantity * ss_list_price) > (select average_sales from avg_sales)
       union all
       select
         'catalog' channel,
         i_brand_id,
         i_class_id,
         i_category_id,
         sum(cs_quantity*cs_list_price) sales,
         count(*) number_sales
       from
         catalog_sales, item, date_dim
       where
         cs_item_sk in (select ss_item_sk from cross_items)
           and cs_item_sk = i_item_sk
           and cs_sold_date_sk = d_date_sk
           and d_year = 1998+2
           and d_moy = 11
       group by
         i_brand_id,i_class_id,i_category_id
       having
         sum(cs_quantity*cs_list_price) > (select average_sales from avg_sales)
       union all
       select
         'web' channel,
         i_brand_id,
         i_class_id,
         i_category_id,
         sum(ws_quantity*ws_list_price) sales,
         count(*) number_sales
       from
         web_sales, item, date_dim
       where
         ws_item_sk in (select ss_item_sk from cross_items)
           and ws_item_sk = i_item_sk
           and ws_sold_date_sk = d_date_sk
           and d_year = 1998 + 2
           and d_moy = 11
       group by
         i_brand_id,
         i_class_id,
         i_category_id
       having
         sum(ws_quantity*ws_list_price) > (select average_sales from avg_sales)) y
    group by
      channel,
      i_brand_id,
      i_class_id,
      i_category_id)
select
  channel,
  i_brand_id,
  i_class_id,
  i_category_id,
  sum_sales,
  number_sales
from (
    select
      channel,
      i_brand_id,
      i_class_id,
      i_category_id,
      sum_sales,
      number_sales
    from
      results
    union
    select
      channel,
      i_brand_id,
      i_class_id,
      null as i_category_id,
      sum(sum_sales),
      sum(number_sales)
    from results
    group by
      channel,
      i_brand_id,
      i_class_id
    union
    select
      channel,
      i_brand_id,
      null as i_class_id,
      null as i_category_id,
      sum(sum_sales),
      sum(number_sales)
    from results
    group by
      channel,
      i_brand_id
    union
    select
      channel,
      null as i_brand_id,
      null as i_class_id,
      null as i_category_id,
      sum(sum_sales),
      sum(number_sales)
    from results
    group by
      channel
    union
    select
      null as channel,
      null as i_brand_id,
      null as i_class_id,
      null as i_category_id,
      sum(sum_sales),
      sum(number_sales)
    from results) z
order by
  channel,
  i_brand_id,
  i_class_id,
  i_category_id
limit 100
SELECT
  i_item_id, -- This column did not exist in TPCDS v1.4
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(ws_ext_sales_price) AS itemrevenue,
  sum(ws_ext_sales_price) * 100 / sum(sum(ws_ext_sales_price))
  OVER
  (PARTITION BY i_class) AS revenueratio
FROM
  web_sales, item, date_dim
WHERE
  ws_item_sk = i_item_sk
    AND i_category IN ('Sports', 'Books', 'Home')
    AND ws_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('1999-02-22' AS DATE)
  AND (cast('1999-02-22' AS DATE) + INTERVAL 30 days)
GROUP BY
  i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY
  i_category, i_class, i_item_id, i_item_desc, revenueratio
LIMIT 100
-- This is a new query in TPCDS v2.7
with results as (
    select
      sum(ws_net_paid) as total_sum,
      i_category, i_class,
      0 as g_category,
      0 as g_class
    from
      web_sales, date_dim d1, item
    where
      d1.d_month_seq between 1212 and 1212 + 11
        and d1.d_date_sk = ws_sold_date_sk
        and i_item_sk = ws_item_sk
    group by
      i_category, i_class),
results_rollup as(
    select
      total_sum,
      i_category,
      i_class,
      g_category,
      g_class,
      0 as lochierarchy
    from
      results
    union
    select
      sum(total_sum) as total_sum,
      i_category,
      NULL as i_class,
      0 as g_category,
      1 as g_class,
      1 as lochierarchy
    from
      results
    group by
      i_category
    union
    select
      sum(total_sum) as total_sum,
      NULL as i_category,
      NULL as i_class,
      1 as g_category,
      1 as g_class,
      2 as lochierarchy
    from
      results)
select
  total_sum,
  i_category ,i_class, lochierarchy,
  rank() over (
      partition by lochierarchy,
        case when g_class = 0 then i_category end
      order by total_sum desc) as rank_within_parent
from
  results_rollup
order by
  lochierarchy desc,
  case when lochierarchy = 0 then i_category end,
  rank_within_parent
limit 100
WITH ssales AS
(SELECT
    c_last_name,
    c_first_name,
    s_store_name,
    ca_state,
    s_state,
    i_color,
    i_current_price,
    i_manager_id,
    i_units,
    i_size,
    sum(ss_net_paid) netpaid
  FROM store_sales, store_returns, store, item, customer, customer_address
  WHERE ss_ticket_number = sr_ticket_number
    AND ss_item_sk = sr_item_sk
    AND ss_customer_sk = c_customer_sk
    AND ss_item_sk = i_item_sk
    AND ss_store_sk = s_store_sk
    AND c_current_addr_sk = ca_address_sk -- This condition did not exist in TPCDS v1.4
    AND c_birth_country = upper(ca_country)
    AND s_zip = ca_zip
    AND s_market_id = 8
  GROUP BY c_last_name, c_first_name, s_store_name, ca_state, s_state, i_color,
    i_current_price, i_manager_id, i_units, i_size)
SELECT
  c_last_name,
  c_first_name,
  s_store_name,
  sum(netpaid) paid
FROM ssales
WHERE i_color = 'pale'
GROUP BY c_last_name, c_first_name, s_store_name
HAVING sum(netpaid) > (SELECT 0.05 * avg(netpaid)
FROM ssales)
-- no order-by exists in q24a of TPCDS v1.4
ORDER BY
  c_last_name,
  c_first_name,
  s_store_name
-- This query is the alternative form of sql/core/src/test/resources/tpcds/q14a.sql
with cross_items as (
  select
    i_item_sk ss_item_sk
  from item, (
      select
        iss.i_brand_id brand_id,
        iss.i_class_id class_id,
        iss.i_category_id category_id
      from
        store_sales, item iss, date_dim d1
      where
        ss_item_sk = iss.i_item_sk
          and ss_sold_date_sk = d1.d_date_sk
          and d1.d_year between 1998 AND 1998 + 2
      intersect
      select
        ics.i_brand_id,
        ics.i_class_id,
        ics.i_category_id
      from
        catalog_sales, item ics, date_dim d2
      where
        cs_item_sk = ics.i_item_sk
          and cs_sold_date_sk = d2.d_date_sk
          and d2.d_year between 1998 AND 1998 + 2
      intersect
      select
        iws.i_brand_id,
        iws.i_class_id,
        iws.i_category_id
      from
        web_sales, item iws, date_dim d3
      where
        ws_item_sk = iws.i_item_sk
          and ws_sold_date_sk = d3.d_date_sk
          and d3.d_year between 1998 AND 1998 + 2) x
      where
        i_brand_id = brand_id
          and i_class_id = class_id
          and i_category_id = category_id),
avg_sales as (
  select
    avg(quantity*list_price) average_sales
  from (
      select
        ss_quantity quantity,
        ss_list_price list_price
      from
        store_sales, date_dim
      where
        ss_sold_date_sk = d_date_sk
          and d_year between 1998 and 1998 + 2
      union all
      select
        cs_quantity quantity,
        cs_list_price list_price
      from
        catalog_sales, date_dim
      where
        cs_sold_date_sk = d_date_sk
          and d_year between 1998 and 1998 + 2
      union all
      select
        ws_quantity quantity,
        ws_list_price list_price
      from
        web_sales, date_dim
      where
        ws_sold_date_sk = d_date_sk
          and d_year between 1998 and 1998 + 2) x)
select
  *
from (
    select
      'store' channel,
      i_brand_id,
      i_class_id,
      i_category_id,
      sum(ss_quantity * ss_list_price) sales,
      count(*) number_sales
    from
      store_sales, item, date_dim
    where
      ss_item_sk in (select ss_item_sk from cross_items)
        and ss_item_sk = i_item_sk
        and ss_sold_date_sk = d_date_sk
        and d_week_seq = (
            select d_week_seq
            from date_dim
            where d_year = 1998 + 1
              and d_moy = 12
              and d_dom = 16)
    group by
      i_brand_id,
      i_class_id,
      i_category_id
    having
      sum(ss_quantity*ss_list_price) > (select average_sales from avg_sales)) this_year,
  (
    select
      'store' channel,
      i_brand_id,
      i_class_id,
      i_category_id,
      sum(ss_quantity * ss_list_price) sales,
      count(*) number_sales
    from
      store_sales, item, date_dim
    where
      ss_item_sk in (select ss_item_sk from cross_items)
        and ss_item_sk = i_item_sk
        and ss_sold_date_sk = d_date_sk
        and d_week_seq = (
            select d_week_seq
            from date_dim
            where d_year = 1998
              and d_moy = 12
              and d_dom = 16)
    group by
      i_brand_id,
      i_class_id,
      i_category_id
    having
      sum(ss_quantity * ss_list_price) > (select average_sales from avg_sales)) last_year
where
  this_year.i_brand_id = last_year.i_brand_id
    and this_year.i_class_id = last_year.i_class_id
    and this_year.i_category_id = last_year.i_category_id
order by
  this_year.channel,
  this_year.i_brand_id,
  this_year.i_class_id,
  this_year.i_category_id
limit 100
WITH all_sales AS (
  SELECT
    d_year,
    i_brand_id,
    i_class_id,
    i_category_id,
    i_manufact_id,
    SUM(sales_cnt) AS sales_cnt,
    SUM(sales_amt) AS sales_amt
  FROM (
         SELECT
           d_year,
           i_brand_id,
           i_class_id,
           i_category_id,
           i_manufact_id,
           cs_quantity - COALESCE(cr_return_quantity, 0) AS sales_cnt,
           cs_ext_sales_price - COALESCE(cr_return_amount, 0.0) AS sales_amt
         FROM catalog_sales
           JOIN item ON i_item_sk = cs_item_sk
           JOIN date_dim ON d_date_sk = cs_sold_date_sk
           LEFT JOIN catalog_returns ON (cs_order_number = cr_order_number
             AND cs_item_sk = cr_item_sk)
         WHERE i_category = 'Books'
         UNION
         SELECT
           d_year,
           i_brand_id,
           i_class_id,
           i_category_id,
           i_manufact_id,
           ss_quantity - COALESCE(sr_return_quantity, 0) AS sales_cnt,
           ss_ext_sales_price - COALESCE(sr_return_amt, 0.0) AS sales_amt
         FROM store_sales
           JOIN item ON i_item_sk = ss_item_sk
           JOIN date_dim ON d_date_sk = ss_sold_date_sk
           LEFT JOIN store_returns ON (ss_ticket_number = sr_ticket_number
             AND ss_item_sk = sr_item_sk)
         WHERE i_category = 'Books'
         UNION
         SELECT
           d_year,
           i_brand_id,
           i_class_id,
           i_category_id,
           i_manufact_id,
           ws_quantity - COALESCE(wr_return_quantity, 0) AS sales_cnt,
           ws_ext_sales_price - COALESCE(wr_return_amt, 0.0) AS sales_amt
         FROM web_sales
           JOIN item ON i_item_sk = ws_item_sk
           JOIN date_dim ON d_date_sk = ws_sold_date_sk
           LEFT JOIN web_returns ON (ws_order_number = wr_order_number
             AND ws_item_sk = wr_item_sk)
         WHERE i_category = 'Books') sales_detail
  GROUP BY d_year, i_brand_id, i_class_id, i_category_id, i_manufact_id)
SELECT
  prev_yr.d_year AS prev_year,
  curr_yr.d_year AS year,
  curr_yr.i_brand_id,
  curr_yr.i_class_id,
  curr_yr.i_category_id,
  curr_yr.i_manufact_id,
  prev_yr.sales_cnt AS prev_yr_cnt,
  curr_yr.sales_cnt AS curr_yr_cnt,
  curr_yr.sales_cnt - prev_yr.sales_cnt AS sales_cnt_diff,
  curr_yr.sales_amt - prev_yr.sales_amt AS sales_amt_diff
FROM all_sales curr_yr, all_sales prev_yr
WHERE curr_yr.i_brand_id = prev_yr.i_brand_id
  AND curr_yr.i_class_id = prev_yr.i_class_id
  AND curr_yr.i_category_id = prev_yr.i_category_id
  AND curr_yr.i_manufact_id = prev_yr.i_manufact_id
  AND curr_yr.d_year = 2002
  AND prev_yr.d_year = 2002 - 1
  AND CAST(curr_yr.sales_cnt AS DECIMAL(17, 2)) / CAST(prev_yr.sales_cnt AS DECIMAL(17, 2)) < 0.9
ORDER BY
  sales_cnt_diff,
  sales_amt_diff -- This order-by condition did not exist in TPCDS v1.4
LIMIT 100
-- This is a new query in TPCDS v2.7
with ssr as (
    select
      s_store_id as store_id,
      sum(ss_ext_sales_price) as sales,
      sum(coalesce(sr_return_amt, 0)) as returns,
      sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
    from
      store_sales left outer join store_returns on (
          ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number),
      date_dim,
      store,
      item,
      promotion
    where
      ss_sold_date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + interval 30 days)
        and ss_store_sk = s_store_sk
        and ss_item_sk = i_item_sk
        and i_current_price > 50
        and ss_promo_sk = p_promo_sk
        and p_channel_tv = 'N'
    group by
      s_store_id),
csr as (
    select
      cp_catalog_page_id as catalog_page_id,
      sum(cs_ext_sales_price) as sales,
      sum(coalesce(cr_return_amount, 0)) as returns,
      sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
    from
      catalog_sales left outer join catalog_returns on
          (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number),
      date_dim,
      catalog_page,
      item,
      promotion
    where
      cs_sold_date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + interval 30 days)
        and cs_catalog_page_sk = cp_catalog_page_sk
        and cs_item_sk = i_item_sk
        and i_current_price > 50
        and cs_promo_sk = p_promo_sk
        and p_channel_tv = 'N'
    group by
      cp_catalog_page_id),
wsr as (
    select
      web_site_id,
      sum(ws_ext_sales_price) as sales,
      sum(coalesce(wr_return_amt, 0)) as returns,
      sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
    from
      web_sales left outer join web_returns on (
          ws_item_sk = wr_item_sk and ws_order_number = wr_order_number),
      date_dim,
      web_site,
      item,
      promotion
    where
      ws_sold_date_sk = d_date_sk
        and d_date between cast('1998-08-04' as date)
        and (cast('1998-08-04' as date) + interval 30 days)
        and ws_web_site_sk = web_site_sk
        and ws_item_sk = i_item_sk
        and i_current_price > 50
        and ws_promo_sk = p_promo_sk
        and p_channel_tv = 'N'
    group by
      web_site_id),
results as (
    select
      channel,
      id,
      sum(sales) as sales,
      sum(returns) as returns,
      sum(profit) as profit
    from (
        select
          'store channel' as channel,
          'store' || store_id as id,
          sales,
          returns,
          profit
        from
          ssr
        union all
        select
          'catalog channel' as channel,
          'catalog_page' || catalog_page_id as id,
          sales,
          returns,
          profit
        from
          csr
        union all
        select
          'web channel' as channel,
          'web_site' || web_site_id as id,
          sales,
          returns,
          profit
        from
          wsr) x
    group by
      channel, id)
select
  channel,
  id,
  sales,
  returns,
  profit
from (
    select
      channel,
      id,
      sales,
      returns,
      profit
    from
      results
    union
    select
      channel,
      NULL AS id,
      sum(sales) as sales,
      sum(returns) as returns,
      sum(profit) as profit
    from
      results
    group by
      channel
    union
    select
      NULL AS channel,
      NULL AS id,
      sum(sales) as sales,
      sum(returns) as returns,
      sum(profit) as profit
    from
      results) foo
order by
  channel, id
limit 100
-- The first SELECT query below is different from q49 of TPCDS v1.4
SELECT
  channel,
  item,
  return_ratio,
  return_rank,
  currency_rank
FROM (
       SELECT
         'web' as channel,
         in_web.item,
         in_web.return_ratio,
         in_web.return_rank,
         in_web.currency_rank
       FROM
         (SELECT
           item,
           return_ratio,
           currency_ratio,
           rank() over (ORDER BY return_ratio) AS return_rank,
           rank() over (ORDER BY currency_ratio) AS currency_rank
         FROM (
            SELECT
              ws.ws_item_sk AS item,
              CAST(SUM(COALESCE(wr.wr_return_quantity, 0)) AS DECIMAL(15, 4)) /
                CAST(SUM(COALESCE(ws.ws_quantity, 0)) AS DECIMAL(15, 4)) AS return_ratio,
              CAST(SUM(COALESCE(wr.wr_return_amt, 0)) AS DECIMAL(15, 4)) /
                CAST(SUM(COALESCE(ws.ws_net_paid, 0)) AS DECIMAL(15, 4)) AS currency_ratio
            FROM
              web_sales ws LEFT OUTER JOIN web_returns wr
                ON (ws.ws_order_number = wr.wr_order_number AND ws.ws_item_sk = wr.wr_item_sk),
              date_dim
            WHERE
              wr.wr_return_amt > 10000
                AND ws.ws_net_profit > 1
                AND ws.ws_net_paid > 0
                AND ws.ws_quantity > 0
                AND ws_sold_date_sk = d_date_sk
                AND d_year = 2001
                AND d_moy = 12
            GROUP BY
              ws.ws_item_sk)
         ) in_web
     ) web
WHERE (web.return_rank <= 10 OR web.currency_rank <= 10)
UNION
SELECT
  'catalog' AS channel,
  catalog.item,
  catalog.return_ratio,
  catalog.return_rank,
  catalog.currency_rank
FROM (
       SELECT
         item,
         return_ratio,
         currency_ratio,
         rank()
         OVER (
           ORDER BY return_ratio) AS return_rank,
         rank()
         OVER (
           ORDER BY currency_ratio) AS currency_rank
       FROM
         (SELECT
           cs.cs_item_sk AS item,
           (cast(sum(coalesce(cr.cr_return_quantity, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(cs.cs_quantity, 0)) AS DECIMAL(15, 4))) AS return_ratio,
           (cast(sum(coalesce(cr.cr_return_amount, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(cs.cs_net_paid, 0)) AS DECIMAL(15, 4))) AS currency_ratio
         FROM
           catalog_sales cs LEFT OUTER JOIN catalog_returns cr
             ON (cs.cs_order_number = cr.cr_order_number AND
             cs.cs_item_sk = cr.cr_item_sk)
           , date_dim
         WHERE
           cr.cr_return_amount > 10000
             AND cs.cs_net_profit > 1
             AND cs.cs_net_paid > 0
             AND cs.cs_quantity > 0
             AND cs_sold_date_sk = d_date_sk
             AND d_year = 2001
             AND d_moy = 12
         GROUP BY cs.cs_item_sk
         ) in_cat
     ) catalog
WHERE (catalog.return_rank <= 10 OR catalog.currency_rank <= 10)
UNION
SELECT
  'store' AS channel,
  store.item,
  store.return_ratio,
  store.return_rank,
  store.currency_rank
FROM (
       SELECT
         item,
         return_ratio,
         currency_ratio,
         rank()
         OVER (
           ORDER BY return_ratio) AS return_rank,
         rank()
         OVER (
           ORDER BY currency_ratio) AS currency_rank
       FROM
         (SELECT
           sts.ss_item_sk AS item,
           (cast(sum(coalesce(sr.sr_return_quantity, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(sts.ss_quantity, 0)) AS DECIMAL(15, 4))) AS return_ratio,
           (cast(sum(coalesce(sr.sr_return_amt, 0)) AS DECIMAL(15, 4)) /
             cast(sum(coalesce(sts.ss_net_paid, 0)) AS DECIMAL(15, 4))) AS currency_ratio
         FROM
           store_sales sts LEFT OUTER JOIN store_returns sr
             ON (sts.ss_ticket_number = sr.sr_ticket_number AND sts.ss_item_sk = sr.sr_item_sk)
           , date_dim
         WHERE
           sr.sr_return_amt > 10000
             AND sts.ss_net_profit > 1
             AND sts.ss_net_paid > 0
             AND sts.ss_quantity > 0
             AND ss_sold_date_sk = d_date_sk
             AND d_year = 2001
             AND d_moy = 12
         GROUP BY sts.ss_item_sk
         ) in_store
     ) store
WHERE (store.return_rank <= 10 OR store.currency_rank <= 10)
ORDER BY
  -- order-by list of q49 in TPCDS v1.4 is below:
  -- 1, 4, 5
  1, 4, 5, 2
LIMIT 100
WITH v1 AS (
  SELECT
    i_category,
    i_brand,
    cc_name,
    d_year,
    d_moy,
    sum(cs_sales_price) sum_sales,
    avg(sum(cs_sales_price))
    OVER
    (PARTITION BY i_category, i_brand, cc_name, d_year)
    avg_monthly_sales,
    rank()
    OVER
    (PARTITION BY i_category, i_brand, cc_name
      ORDER BY d_year, d_moy) rn
  FROM item, catalog_sales, date_dim, call_center
  WHERE cs_item_sk = i_item_sk AND
    cs_sold_date_sk = d_date_sk AND
    cc_call_center_sk = cs_call_center_sk AND
    (
      d_year = 1999 OR
        (d_year = 1999 - 1 AND d_moy = 12) OR
        (d_year = 1999 + 1 AND d_moy = 1)
    )
  GROUP BY i_category, i_brand,
    cc_name, d_year, d_moy),
    v2 AS (
    SELECT
      v1.i_category,
      v1.i_brand,
      -- q57 in TPCDS v1.4 had a column below:
      -- v1.cc_name,
      v1.d_year,
      v1.d_moy,
      v1.avg_monthly_sales,
      v1.sum_sales,
      v1_lag.sum_sales psum,
      v1_lead.sum_sales nsum
    FROM v1, v1 v1_lag, v1 v1_lead
    WHERE v1.i_category = v1_lag.i_category AND
      v1.i_category = v1_lead.i_category AND
      v1.i_brand = v1_lag.i_brand AND
      v1.i_brand = v1_lead.i_brand AND
      v1.cc_name = v1_lag.cc_name AND
      v1.cc_name = v1_lead.cc_name AND
      v1.rn = v1_lag.rn + 1 AND
      v1.rn = v1_lead.rn - 1)
SELECT *
FROM v2
WHERE d_year = 1999 AND
  avg_monthly_sales > 0 AND
  CASE WHEN avg_monthly_sales > 0
    THEN abs(sum_sales - avg_monthly_sales) / avg_monthly_sales
  ELSE NULL END > 0.1
ORDER BY sum_sales - avg_monthly_sales, 3
LIMIT 100
WITH v1 AS (
  SELECT
    i_category,
    i_brand,
    s_store_name,
    s_company_name,
    d_year,
    d_moy,
    sum(ss_sales_price) sum_sales,
    avg(sum(ss_sales_price))
    OVER
    (PARTITION BY i_category, i_brand,
      s_store_name, s_company_name, d_year)
    avg_monthly_sales,
    rank()
    OVER
    (PARTITION BY i_category, i_brand,
      s_store_name, s_company_name
      ORDER BY d_year, d_moy) rn
  FROM item, store_sales, date_dim, store
  WHERE ss_item_sk = i_item_sk AND
    ss_sold_date_sk = d_date_sk AND
    ss_store_sk = s_store_sk AND
    (
      d_year = 1999 OR
        (d_year = 1999 - 1 AND d_moy = 12) OR
        (d_year = 1999 + 1 AND d_moy = 1)
    )
  GROUP BY i_category, i_brand,
    s_store_name, s_company_name,
    d_year, d_moy),
    v2 AS (
    SELECT
      v1.i_category,
      -- q47 in TPCDS v1.4 had more columns below:
      -- v1.i_brand,
      -- v1.s_store_name,
      -- v1.s_company_name,
      v1.d_year,
      v1.d_moy,
      v1.avg_monthly_sales,
      v1.sum_sales,
      v1_lag.sum_sales psum,
      v1_lead.sum_sales nsum
    FROM v1, v1 v1_lag, v1 v1_lead
    WHERE v1.i_category = v1_lag.i_category AND
      v1.i_category = v1_lead.i_category AND
      v1.i_brand = v1_lag.i_brand AND
      v1.i_brand = v1_lead.i_brand AND
      v1.s_store_name = v1_lag.s_store_name AND
      v1.s_store_name = v1_lead.s_store_name AND
      v1.s_company_name = v1_lag.s_company_name AND
      v1.s_company_name = v1_lead.s_company_name AND
      v1.rn = v1_lag.rn + 1 AND
      v1.rn = v1_lead.rn - 1)
SELECT *
FROM v2
WHERE d_year = 1999 AND
  avg_monthly_sales > 0 AND
  CASE WHEN avg_monthly_sales > 0
    THEN abs(sum_sales - avg_monthly_sales) / avg_monthly_sales
  ELSE NULL END > 0.1
ORDER BY sum_sales - avg_monthly_sales, 3
LIMIT 100
SELECT
  i_item_id, -- This column did not exist in TPCDS v1.4
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(ss_ext_sales_price) AS itemrevenue,
  sum(ss_ext_sales_price) * 100 / sum(sum(ss_ext_sales_price))
  OVER
  (PARTITION BY i_class) AS revenueratio
FROM
  store_sales, item, date_dim
WHERE
  ss_item_sk = i_item_sk
    AND i_category IN ('Sports', 'Books', 'Home')
    AND ss_sold_date_sk = d_date_sk
    AND d_date BETWEEN cast('1999-02-22' AS DATE)
  AND (cast('1999-02-22' AS DATE) + INTERVAL 30 days)
GROUP BY
  i_item_id, i_item_desc, i_category, i_class, i_current_price
ORDER BY
  i_category, i_class, i_item_id, i_item_desc, revenueratio
SELECT
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag,
  ss_ticket_number,
  cnt
FROM
  (SELECT
    ss_ticket_number,
    ss_customer_sk,
    count(*) cnt
  FROM store_sales, date_dim, store, household_demographics
  WHERE store_sales.ss_sold_date_sk = date_dim.d_date_sk
    AND store_sales.ss_store_sk = store.s_store_sk
    AND store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    AND (date_dim.d_dom BETWEEN 1 AND 3 OR date_dim.d_dom BETWEEN 25 AND 28)
    AND (household_demographics.hd_buy_potential = '>10000' OR
    household_demographics.hd_buy_potential = 'unknown')
    AND household_demographics.hd_vehicle_count > 0
    AND (CASE WHEN household_demographics.hd_vehicle_count > 0
    THEN household_demographics.hd_dep_count / household_demographics.hd_vehicle_count
         ELSE NULL
         END) > 1.2
    AND date_dim.d_year IN (1999, 1999 + 1, 1999 + 2)
    AND store.s_county IN
    ('Williamson County', 'Williamson County', 'Williamson County', 'Williamson County',
     'Williamson County', 'Williamson County', 'Williamson County', 'Williamson County')
  GROUP BY ss_ticket_number, ss_customer_sk) dn, customer
WHERE ss_customer_sk = c_customer_sk
  AND cnt BETWEEN 15 AND 20
ORDER BY
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag DESC,
  ss_ticket_number -- This order-by condition did not exist in TPCDS v1.4
WITH ws AS
(SELECT
    d_year AS ws_sold_year,
    ws_item_sk,
    ws_bill_customer_sk ws_customer_sk,
    sum(ws_quantity) ws_qty,
    sum(ws_wholesale_cost) ws_wc,
    sum(ws_sales_price) ws_sp
  FROM web_sales
    LEFT JOIN web_returns ON wr_order_number = ws_order_number AND ws_item_sk = wr_item_sk
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
  WHERE wr_order_number IS NULL
  GROUP BY d_year, ws_item_sk, ws_bill_customer_sk
),
    cs AS
  (SELECT
    d_year AS cs_sold_year,
    cs_item_sk,
    cs_bill_customer_sk cs_customer_sk,
    sum(cs_quantity) cs_qty,
    sum(cs_wholesale_cost) cs_wc,
    sum(cs_sales_price) cs_sp
  FROM catalog_sales
    LEFT JOIN catalog_returns ON cr_order_number = cs_order_number AND cs_item_sk = cr_item_sk
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
  WHERE cr_order_number IS NULL
  GROUP BY d_year, cs_item_sk, cs_bill_customer_sk
  ),
    ss AS
  (SELECT
    d_year AS ss_sold_year,
    ss_item_sk,
    ss_customer_sk,
    sum(ss_quantity) ss_qty,
    sum(ss_wholesale_cost) ss_wc,
    sum(ss_sales_price) ss_sp
  FROM store_sales
    LEFT JOIN store_returns ON sr_ticket_number = ss_ticket_number AND ss_item_sk = sr_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
  WHERE sr_ticket_number IS NULL
  GROUP BY d_year, ss_item_sk, ss_customer_sk
  )
SELECT
  round(ss_qty / (coalesce(ws_qty + cs_qty, 1)), 2) ratio,
  ss_qty store_qty,
  ss_wc store_wholesale_cost,
  ss_sp store_sales_price,
  coalesce(ws_qty, 0) + coalesce(cs_qty, 0) other_chan_qty,
  coalesce(ws_wc, 0) + coalesce(cs_wc, 0) other_chan_wholesale_cost,
  coalesce(ws_sp, 0) + coalesce(cs_sp, 0) other_chan_sales_price
FROM ss
  LEFT JOIN ws
    ON (ws_sold_year = ss_sold_year AND ws_item_sk = ss_item_sk AND ws_customer_sk = ss_customer_sk)
  LEFT JOIN cs
    ON (cs_sold_year = ss_sold_year AND cs_item_sk = ss_item_sk AND cs_customer_sk = ss_customer_sk)
WHERE coalesce(ws_qty, 0) > 0 AND coalesce(cs_qty, 0) > 0 AND ss_sold_year = 2000
ORDER BY
  -- order-by list of q78 in TPCDS v1.4 is below:
  -- ratio,
  -- ss_qty DESC, ss_wc DESC, ss_sp DESC,
  -- other_chan_qty,
  -- other_chan_wholesale_cost,
  -- other_chan_sales_price,
  -- round(ss_qty / (coalesce(ws_qty + cs_qty, 1)), 2)
  ss_sold_year,
  ss_item_sk,
  ss_customer_sk,
  ss_qty desc,
  ss_wc desc,
  ss_sp desc,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price,
  ratio
LIMIT 100
-- This is a new query in TPCDS v2.7
with results as (
    select
        i_item_id,
        s_state, 0 as g_state,
        ss_quantity agg1,
        ss_list_price agg2,
        ss_coupon_amt agg3,
        ss_sales_price agg4
    from
      store_sales, customer_demographics, date_dim, store, item
    where
      ss_sold_date_sk = d_date_sk
        and ss_item_sk = i_item_sk
        and ss_store_sk = s_store_sk
        and ss_cdemo_sk = cd_demo_sk
        and cd_gender = 'F'
        and cd_marital_status = 'W'
        and cd_education_status = 'Primary'
        and d_year = 1998
        and s_state in ('TN','TN', 'TN', 'TN', 'TN', 'TN'))
select
  i_item_id,
  s_state,
  g_state,
  agg1,
  agg2,
  agg3,
  agg4
from (
    select
      i_item_id,
      s_state,
      0 as g_state,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4
    from
      results
    group by
      i_item_id,
      s_state
    union all
    select
      i_item_id,
      NULL AS s_state,
      1 AS g_state,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4
    from results
    group by
      i_item_id
    union all
    select
      NULL AS i_item_id,
      NULL as s_state,
      1 as g_state,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4
    from
      results) foo
order by
  i_item_id,
  s_state
limit 100
-- This is a new query in TPCDS v2.7
select
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  count(*) cnt1,
  avg(cd_dep_count),
  max(cd_dep_count),
  sum(cd_dep_count),
  cd_dep_employed_count,
  count(*) cnt2,
  avg(cd_dep_employed_count),
  max(cd_dep_employed_count),
  sum(cd_dep_employed_count),
  cd_dep_college_count,
  count(*) cnt3,
  avg(cd_dep_college_count),
  max(cd_dep_college_count),
  sum(cd_dep_college_count)
from
  customer c, customer_address ca, customer_demographics
where
  c.c_current_addr_sk = ca.ca_address_sk
    and cd_demo_sk = c.c_current_cdemo_sk
    and exists (
        select *
        from store_sales, date_dim
        where c.c_customer_sk = ss_customer_sk
          and ss_sold_date_sk = d_date_sk
          and d_year = 1999
          and d_qoy < 4)
    and exists (
        select *
        from (
            select ws_bill_customer_sk customsk
            from web_sales, date_dim
            where ws_sold_date_sk = d_date_sk
              and d_year = 1999
              and d_qoy < 4
        union all
        select cs_ship_customer_sk customsk
        from catalog_sales, date_dim
        where cs_sold_date_sk = d_date_sk
          and d_year = 1999
          and d_qoy < 4) x
        where x.customsk = c.c_customer_sk)
group by
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
order by
  ca_state,
  cd_gender,
  cd_marital_status,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
limit 100
-- This is a new query in TPCDS v2.7
with results as (
    select
      i_item_id,
      ca_country,
      ca_state,
      ca_county,
      cast(cs_quantity as decimal(12,2)) agg1,
      cast(cs_list_price as decimal(12,2)) agg2,
      cast(cs_coupon_amt as decimal(12,2)) agg3,
      cast(cs_sales_price as decimal(12,2)) agg4,
      cast(cs_net_profit as decimal(12,2)) agg5,
      cast(c_birth_year as decimal(12,2)) agg6,
      cast(cd1.cd_dep_count as decimal(12,2)) agg7
    from
      catalog_sales, customer_demographics cd1, customer_demographics cd2, customer,
      customer_address, date_dim, item
    where
      cs_sold_date_sk = d_date_sk
        and cs_item_sk = i_item_sk
        and cs_bill_cdemo_sk = cd1.cd_demo_sk
        and cs_bill_customer_sk = c_customer_sk
        and cd1.cd_gender = 'M'
        and cd1.cd_education_status = 'College'
        and c_current_cdemo_sk = cd2.cd_demo_sk
        and c_current_addr_sk = ca_address_sk
        and c_birth_month in (9,5,12,4,1,10)
        and d_year = 2001
        and ca_state in ('ND','WI','AL','NC','OK','MS','TN'))
select
  i_item_id,
  ca_country,
  ca_state,
  ca_county,
  agg1,
  agg2,
  agg3,
  agg4,
  agg5,
  agg6,
  agg7
from (
    select
      i_item_id,
      ca_country,
      ca_state,
      ca_county,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4,
      avg(agg5) agg5,
      avg(agg6) agg6,
      avg(agg7) agg7
    from
      results
    group by
      i_item_id,
      ca_country,
      ca_state,
      ca_county
    union all
    select
      i_item_id,
      ca_country,
      ca_state,
      NULL as county,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4,
      avg(agg5) agg5,
      avg(agg6) agg6,
      avg(agg7) agg7
    from
      results
    group by
      i_item_id,
      ca_country,
      ca_state
    union all
    select
      i_item_id,
      ca_country,
      NULL as ca_state,
      NULL as county,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4,
      avg(agg5) agg5,
      avg(agg6) agg6,
      avg(agg7) agg7
    from results
    group by
      i_item_id,
      ca_country
    union all
    select
      i_item_id,
      NULL as ca_country,
      NULL as ca_state,
      NULL as county,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4,
      avg(agg5) agg5,
      avg(agg6) agg6,
      avg(agg7) agg7
    from results
    group by
      i_item_id
    union all
    select
      NULL AS i_item_id,
      NULL as ca_country,
      NULL as ca_state,
      NULL as county,
      avg(agg1) agg1,
      avg(agg2) agg2,
      avg(agg3) agg3,
      avg(agg4) agg4,
      avg(agg5) agg5,
      avg(agg6) agg6,
      avg(agg7) agg7
    from results) foo
order by
  ca_country,
  ca_state,
  ca_county,
  i_item_id
limit 100
-- This is a new query in TPCDS v2.7
WITH web_tv as (
    select
      ws_item_sk item_sk,
      d_date,
      sum(ws_sales_price) sumws,
      row_number() over (partition by ws_item_sk order by d_date) rk
    from
      web_sales, date_dim
    where
      ws_sold_date_sk=d_date_sk
        and d_month_seq between 1212 and 1212 + 11
        and ws_item_sk is not NULL
    group by
      ws_item_sk, d_date),
web_v1 as (
    select
      v1.item_sk,
      v1.d_date,
      v1.sumws,
      sum(v2.sumws) cume_sales
    from
      web_tv v1, web_tv v2
    where
      v1.item_sk = v2.item_sk
        and v1.rk >= v2.rk
    group by
      v1.item_sk,
      v1.d_date,
      v1.sumws),
store_tv as (
    select
      ss_item_sk item_sk,
      d_date,
      sum(ss_sales_price) sumss,
      row_number() over (partition by ss_item_sk order by d_date) rk
    from
      store_sales, date_dim
    where
      ss_sold_date_sk = d_date_sk
        and d_month_seq between 1212 and 1212 + 11
        and ss_item_sk is not NULL
    group by ss_item_sk, d_date),
store_v1 as (
    select
      v1.item_sk,
      v1.d_date,
      v1.sumss,
      sum(v2.sumss) cume_sales
    from
      store_tv v1, store_tv v2
    where
      v1.item_sk = v2.item_sk
        and v1.rk >= v2.rk
    group by
      v1.item_sk,
      v1.d_date,
      v1.sumss),
v as (
    select
      item_sk,
      d_date,
      web_sales,
      store_sales,
      row_number() over (partition by item_sk order by d_date) rk
    from (
        select
          case when web.item_sk is not null
            then web.item_sk
            else store.item_sk end item_sk,
          case when web.d_date is not null
            then web.d_date
            else store.d_date end d_date,
          web.cume_sales web_sales,
          store.cume_sales store_sales
        from
          web_v1 web full outer join store_v1 store
            on (web.item_sk = store.item_sk and web.d_date = store.d_date)))
select *
from (
    select
      v1.item_sk,
      v1.d_date,
      v1.web_sales,
      v1.store_sales,
      max(v2.web_sales) web_cumulative,
      max(v2.store_sales) store_cumulative
    from
      v v1, v v2
    where
      v1.item_sk = v2.item_sk
        and v1.rk >= v2.rk
    group by
      v1.item_sk,
      v1.d_date,
      v1.web_sales,
      v1.store_sales) x
where
  web_cumulative > store_cumulative
order by
  item_sk,
  d_date
limit 100
WITH year_total AS (
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    d_year AS year,
    sum(ss_net_paid) year_total,
    's' sale_type
  FROM
    customer, store_sales, date_dim
  WHERE c_customer_sk = ss_customer_sk
    AND ss_sold_date_sk = d_date_sk
    AND d_year IN (2001, 2001 + 1)
  GROUP BY
    c_customer_id, c_first_name, c_last_name, d_year
  UNION ALL
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    d_year AS year,
    sum(ws_net_paid) year_total,
    'w' sale_type
  FROM
    customer, web_sales, date_dim
  WHERE c_customer_sk = ws_bill_customer_sk
    AND ws_sold_date_sk = d_date_sk
    AND d_year IN (2001, 2001 + 1)
  GROUP BY
    c_customer_id, c_first_name, c_last_name, d_year)
SELECT
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name
FROM
  year_total t_s_firstyear, year_total t_s_secyear,
  year_total t_w_firstyear, year_total t_w_secyear
WHERE t_s_secyear.customer_id = t_s_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_w_secyear.customer_id
  AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
  AND t_s_firstyear.sale_type = 's'
  AND t_w_firstyear.sale_type = 'w'
  AND t_s_secyear.sale_type = 's'
  AND t_w_secyear.sale_type = 'w'
  AND t_s_firstyear.year = 2001
  AND t_s_secyear.year = 2001 + 1
  AND t_w_firstyear.year = 2001
  AND t_w_secyear.year = 2001 + 1
  AND t_s_firstyear.year_total > 0
  AND t_w_firstyear.year_total > 0
  AND CASE WHEN t_w_firstyear.year_total > 0
  THEN t_w_secyear.year_total / t_w_firstyear.year_total
      ELSE NULL END
  > CASE WHEN t_s_firstyear.year_total > 0
  THEN t_s_secyear.year_total / t_s_firstyear.year_total
    ELSE NULL END
-- order-by list of q74 in TPCDS v1.4 is below:
-- ORDER BY 1, 1, 1
ORDER BY 2, 1, 3
LIMIT 100
WITH year_total AS (
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum(ss_ext_list_price - ss_ext_discount_amt) year_total,
    's' sale_type
  FROM customer, store_sales, date_dim
  WHERE c_customer_sk = ss_customer_sk
    AND ss_sold_date_sk = d_date_sk
  GROUP BY c_customer_id
    , c_first_name
    , c_last_name
    , d_year
    , c_preferred_cust_flag
    , c_birth_country
    , c_login
    , c_email_address
    , d_year
  UNION ALL
  SELECT
    c_customer_id customer_id,
    c_first_name customer_first_name,
    c_last_name customer_last_name,
    c_preferred_cust_flag customer_preferred_cust_flag,
    c_birth_country customer_birth_country,
    c_login customer_login,
    c_email_address customer_email_address,
    d_year dyear,
    sum(ws_ext_list_price - ws_ext_discount_amt) year_total,
    'w' sale_type
  FROM customer, web_sales, date_dim
  WHERE c_customer_sk = ws_bill_customer_sk
    AND ws_sold_date_sk = d_date_sk
  GROUP BY
    c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country,
    c_login, c_email_address, d_year)
SELECT
  -- select list of q11 in TPCDS v1.4 is below:
  -- t_s_secyear.customer_preferred_cust_flag
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name,
  t_s_secyear.customer_email_address
FROM year_total t_s_firstyear
  , year_total t_s_secyear
  , year_total t_w_firstyear
  , year_total t_w_secyear
WHERE t_s_secyear.customer_id = t_s_firstyear.customer_id
  AND t_s_firstyear.customer_id = t_w_secyear.customer_id
  AND t_s_firstyear.customer_id = t_w_firstyear.customer_id
  AND t_s_firstyear.sale_type = 's'
  AND t_w_firstyear.sale_type = 'w'
  AND t_s_secyear.sale_type = 's'
  AND t_w_secyear.sale_type = 'w'
  AND t_s_firstyear.dyear = 2001
  AND t_s_secyear.dyear = 2001 + 1
  AND t_w_firstyear.dyear = 2001
  AND t_w_secyear.dyear = 2001 + 1
  AND t_s_firstyear.year_total > 0
  AND t_w_firstyear.year_total > 0
  AND CASE WHEN t_w_firstyear.year_total > 0
  THEN t_w_secyear.year_total / t_w_firstyear.year_total
  -- q11 in TPCDS v1.4 used NULL
  --     ELSE NULL END
      ELSE 0.0 END
  > CASE WHEN t_s_firstyear.year_total > 0
  THEN t_s_secyear.year_total / t_s_firstyear.year_total
  -- q11 in TPCDS v1.4 used NULL
  --   ELSE NULL END
    ELSE 0.0 END
ORDER BY
  -- order-by list of q11 in TPCDS v1.4 is below:
  -- t_s_secyear.customer_preferred_cust_flag
  t_s_secyear.customer_id,
  t_s_secyear.customer_first_name,
  t_s_secyear.customer_last_name,
  t_s_secyear.customer_email_address
LIMIT 100
-- This is a new query in TPCDS v2.7
select
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
from
  customer c,customer_address ca,customer_demographics
where
  c.c_current_addr_sk = ca.ca_address_sk
    and ca_county in ('Walker County', 'Richland County', 'Gaines County', 'Douglas County', 'Dona Ana County')
    and cd_demo_sk = c.c_current_cdemo_sk
    and exists (
        select *
        from store_sales,date_dim
        where c.c_customer_sk = ss_customer_sk
          and ss_sold_date_sk = d_date_sk
          and d_year = 2002
          and d_moy between 4 and 4 + 3)
    and exists (
        select *
        from (
            select
              ws_bill_customer_sk as customer_sk,
              d_year,
              d_moy
            from web_sales, date_dim
            where ws_sold_date_sk = d_date_sk
              and d_year = 2002
              and d_moy between 4 and 4 + 3
            union all
            select
              cs_ship_customer_sk as customer_sk,
              d_year,
              d_moy
            from catalog_sales, date_dim
            where cs_sold_date_sk = d_date_sk
              and d_year = 2002
              and d_moy between 4 and 4 + 3) x
    where c.c_customer_sk = customer_sk)
group by
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
order by
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
limit 100
-- start query 10 in stream 0 using template query10.tpl
with 
v1 as (
  select 
     ws_bill_customer_sk as customer_sk
  from web_sales,
       date_dim
  where ws_sold_date_sk = d_date_sk
  and d_year = 2002
  and d_moy between 4 and 4+3
  union all
  select 
    cs_ship_customer_sk as customer_sk
  from catalog_sales,
       date_dim 
  where cs_sold_date_sk = d_date_sk
  and d_year = 2002
  and d_moy between 4 and 4+3
),
v2 as (
  select 
    ss_customer_sk as customer_sk
  from store_sales,
       date_dim
  where ss_sold_date_sk = d_date_sk
  and d_year = 2002
  and d_moy between 4 and 4+3 
)
select
  cd_gender,
  cd_marital_status,
  cd_education_status,
  count(*) cnt1,
  cd_purchase_estimate,
  count(*) cnt2,
  cd_credit_rating,
  count(*) cnt3,
  cd_dep_count,
  count(*) cnt4,
  cd_dep_employed_count,
  count(*) cnt5,
  cd_dep_college_count,
  count(*) cnt6
from customer c
join customer_address ca on (c.c_current_addr_sk = ca.ca_address_sk)
join customer_demographics on (cd_demo_sk = c.c_current_cdemo_sk) 
left semi join v1 on (v1.customer_sk = c.c_customer_sk) 
left semi join v2 on (v2.customer_sk = c.c_customer_sk)
where 
  ca_county in ('Walker County','Richland County','Gaines County','Douglas County','Dona Ana County')
group by 
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
order by 
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
limit 100
-- end query 10 in stream 0 using template query10.tpl
-- start query 55 in stream 0 using template query55.tpl
select
  i_brand_id brand_id,
  i_brand brand,
  sum(ss_ext_sales_price) ext_price
from
  date_dim,
  store_sales,
  item
where
  d_date_sk = ss_sold_date_sk
  and ss_item_sk = i_item_sk
  and i_manager_id = 48
  and d_moy = 11
  and d_year = 2001
  and ss_sold_date_sk between 2452215 and 2452244
group by
  i_brand,
  i_brand_id
order by
  ext_price desc,
  i_brand_id
limit 100
-- end query 55 in stream 0 using template query55.tpl
-- start query 7 in stream 0 using template query7.tpl
select
  i_item_id,
  avg(ss_quantity) agg1,
  avg(ss_list_price) agg2,
  avg(ss_coupon_amt) agg3,
  avg(ss_sales_price) agg4
from
  store_sales,
  customer_demographics,
  date_dim,
  item,
  promotion
where
  ss_sold_date_sk = d_date_sk
  and ss_item_sk = i_item_sk
  and ss_cdemo_sk = cd_demo_sk
  and ss_promo_sk = p_promo_sk
  and cd_gender = 'F'
  and cd_marital_status = 'W'
  and cd_education_status = 'Primary'
  and (p_channel_email = 'N'
    or p_channel_event = 'N')
  and d_year = 1998
  and ss_sold_date_sk between 2450815 and 2451179 -- partition key filter
group by
  i_item_id
order by
  i_item_id
limit 100
-- end query 7 in stream 0 using template query7.tpl
-- start query 27 in stream 0 using template query27.tpl
 with results as
 (select i_item_id,
        s_state,
        ss_quantity agg1,
        ss_list_price agg2,
        ss_coupon_amt agg3,
        ss_sales_price agg4
        --0 as g_state,
        --avg(ss_quantity) agg1,
        --avg(ss_list_price) agg2,
        --avg(ss_coupon_amt) agg3,
        --avg(ss_sales_price) agg4
 from store_sales, customer_demographics, date_dim, store, item
 where ss_sold_date_sk = d_date_sk and
       ss_sold_date_sk between 2451545 and 2451910 and
       ss_item_sk = i_item_sk and
       ss_store_sk = s_store_sk and
       ss_cdemo_sk = cd_demo_sk and
       cd_gender = 'F' and
       cd_marital_status = 'D' and
       cd_education_status = 'Primary' and
       d_year = 2000 and
       s_state in ('TN','AL', 'SD', 'SD', 'SD', 'SD')
 --group by i_item_id, s_state
 )

 select i_item_id,
  s_state, g_state, agg1, agg2, agg3, agg4
   from (
        select i_item_id, s_state, 0 as g_state, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3, avg(agg4) agg4 from results
        group by i_item_id, s_state
         union all
        select i_item_id, NULL AS s_state, 1 AS g_state, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
         avg(agg4) agg4 from results
        group by i_item_id
         union all
        select NULL AS i_item_id, NULL as s_state, 1 as g_state, avg(agg1) agg1, avg(agg2) agg2, avg(agg3) agg3,
         avg(agg4) agg4 from results
        ) foo
  order by i_item_id, s_state
 limit 100
-- end query 27 in stream 0 using template query27.tpl
-- start query 42 in stream 0 using template query42.tpl
select
  dt.d_year,
  item.i_category_id,
  item.i_category,
  sum(ss_ext_sales_price)
from
  date_dim dt,
  store_sales,
  item
where
  dt.d_date_sk = store_sales.ss_sold_date_sk
  and store_sales.ss_item_sk = item.i_item_sk
  and item.i_manager_id = 1
  and dt.d_moy = 12
  and dt.d_year = 1998
  and ss_sold_date_sk between 2451149 and 2451179  -- partition key filter
group by
  dt.d_year,
  item.i_category_id,
  item.i_category
order by
  sum(ss_ext_sales_price) desc,
  dt.d_year,
  item.i_category_id,
  item.i_category
limit 100
-- end query 42 in stream 0 using template query42.tpl
-- start query 59 in stream 0 using template query59.tpl
with
  wss as
  (select
    d_week_seq,
    ss_store_sk,
    sum(case when (d_day_name = 'Sunday') then ss_sales_price else null end) sun_sales,
    sum(case when (d_day_name = 'Monday') then ss_sales_price else null end) mon_sales,
    sum(case when (d_day_name = 'Tuesday') then ss_sales_price else null end) tue_sales,
    sum(case when (d_day_name = 'Wednesday') then ss_sales_price else null end) wed_sales,
    sum(case when (d_day_name = 'Thursday') then ss_sales_price else null end) thu_sales,
    sum(case when (d_day_name = 'Friday') then ss_sales_price else null end) fri_sales,
    sum(case when (d_day_name = 'Saturday') then ss_sales_price else null end) sat_sales
  from
    store_sales,
    date_dim
  where
    d_date_sk = ss_sold_date_sk
  group by
    d_week_seq,
    ss_store_sk
  )
select
  s_store_name1,
  s_store_id1,
  d_week_seq1,
  sun_sales1 / sun_sales2,
  mon_sales1 / mon_sales2,
  tue_sales1 / tue_sales1,
  wed_sales1 / wed_sales2,
  thu_sales1 / thu_sales2,
  fri_sales1 / fri_sales2,
  sat_sales1 / sat_sales2
from
  (select
    s_store_name s_store_name1,
    wss.d_week_seq d_week_seq1,
    s_store_id s_store_id1,
    sun_sales sun_sales1,
    mon_sales mon_sales1,
    tue_sales tue_sales1,
    wed_sales wed_sales1,
    thu_sales thu_sales1,
    fri_sales fri_sales1,
    sat_sales sat_sales1
  from
    wss,
    store,
    date_dim d
  where
    d.d_week_seq = wss.d_week_seq
    and ss_store_sk = s_store_sk
    and d_month_seq between 1185 and 1185 + 11
  ) y,
  (select
    s_store_name s_store_name2,
    wss.d_week_seq d_week_seq2,
    s_store_id s_store_id2,
    sun_sales sun_sales2,
    mon_sales mon_sales2,
    tue_sales tue_sales2,
    wed_sales wed_sales2,
    thu_sales thu_sales2,
    fri_sales fri_sales2,
    sat_sales sat_sales2
  from
    wss,
    store,
    date_dim d
  where
    d.d_week_seq = wss.d_week_seq
    and ss_store_sk = s_store_sk
    and d_month_seq between 1185 + 12 and 1185 + 23
  ) x
where
  s_store_id1 = s_store_id2
  and d_week_seq1 = d_week_seq2 - 52
order by
  s_store_name1,
  s_store_id1,
  d_week_seq1
limit 100
-- end query 59 in stream 0 using template query59.tpl
-- start query 43 in stream 0 using template query43.tpl
select
  s_store_name,
  s_store_id,
  sum(case when (d_day_name = 'Sunday') then ss_sales_price else null end) sun_sales,
  sum(case when (d_day_name = 'Monday') then ss_sales_price else null end) mon_sales,
  sum(case when (d_day_name = 'Tuesday') then ss_sales_price else null end) tue_sales,
  sum(case when (d_day_name = 'Wednesday') then ss_sales_price else null end) wed_sales,
  sum(case when (d_day_name = 'Thursday') then ss_sales_price else null end) thu_sales,
  sum(case when (d_day_name = 'Friday') then ss_sales_price else null end) fri_sales,
  sum(case when (d_day_name = 'Saturday') then ss_sales_price else null end) sat_sales
from
  date_dim,
  store_sales,
  store
where
  d_date_sk = ss_sold_date_sk
  and s_store_sk = ss_store_sk
  and s_gmt_offset = -5
  and d_year = 1998
  and ss_sold_date_sk between 2450816 and 2451179  -- partition key filter
group by
  s_store_name,
  s_store_id
order by
  s_store_name,
  s_store_id,
  sun_sales,
  mon_sales,
  tue_sales,
  wed_sales,
  thu_sales,
  fri_sales,
  sat_sales
limit 100
-- end query 43 in stream 0 using template query43.tpl
-- start query 46 in stream 0 using template query46.tpl
select
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number,
  amt,
  profit
from
  (select
    ss_ticket_number,
    ss_customer_sk,
    ca_city bought_city,
    sum(ss_coupon_amt) amt,
    sum(ss_net_profit) profit
  from
    store_sales,
    date_dim,
    store,
    household_demographics,
    customer_address
  where
    store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and store_sales.ss_addr_sk = customer_address.ca_address_sk
    and (household_demographics.hd_dep_count = 5
      or household_demographics.hd_vehicle_count = 3)
    and date_dim.d_dow in (6, 0)
    and date_dim.d_year in (1999, 1999 + 1, 1999 + 2)
    and store.s_city in ('Midway', 'Concord', 'Spring Hill', 'Brownsville', 'Greenville')
    -- partition key filter
    and ss_sold_date_sk in (2451181, 2451182, 2451188, 2451189, 2451195, 2451196, 2451202, 2451203, 2451209, 2451210, 2451216, 2451217, 
                            2451223, 2451224, 2451230, 2451231, 2451237, 2451238, 2451244, 2451245, 2451251, 2451252, 2451258, 2451259, 
                            2451265, 2451266, 2451272, 2451273, 2451279, 2451280, 2451286, 2451287, 2451293, 2451294, 2451300, 2451301, 
                            2451307, 2451308, 2451314, 2451315, 2451321, 2451322, 2451328, 2451329, 2451335, 2451336, 2451342, 2451343, 
                            2451349, 2451350, 2451356, 2451357, 2451363, 2451364, 2451370, 2451371, 2451377, 2451378, 2451384, 2451385, 
                            2451391, 2451392, 2451398, 2451399, 2451405, 2451406, 2451412, 2451413, 2451419, 2451420, 2451426, 2451427, 
                            2451433, 2451434, 2451440, 2451441, 2451447, 2451448, 2451454, 2451455, 2451461, 2451462, 2451468, 2451469, 
                            2451475, 2451476, 2451482, 2451483, 2451489, 2451490, 2451496, 2451497, 2451503, 2451504, 2451510, 2451511, 
                            2451517, 2451518, 2451524, 2451525, 2451531, 2451532, 2451538, 2451539, 2451545, 2451546, 2451552, 2451553, 
                            2451559, 2451560, 2451566, 2451567, 2451573, 2451574, 2451580, 2451581, 2451587, 2451588, 2451594, 2451595, 
                            2451601, 2451602, 2451608, 2451609, 2451615, 2451616, 2451622, 2451623, 2451629, 2451630, 2451636, 2451637, 
                            2451643, 2451644, 2451650, 2451651, 2451657, 2451658, 2451664, 2451665, 2451671, 2451672, 2451678, 2451679, 
                            2451685, 2451686, 2451692, 2451693, 2451699, 2451700, 2451706, 2451707, 2451713, 2451714, 2451720, 2451721, 
                            2451727, 2451728, 2451734, 2451735, 2451741, 2451742, 2451748, 2451749, 2451755, 2451756, 2451762, 2451763, 
                            2451769, 2451770, 2451776, 2451777, 2451783, 2451784, 2451790, 2451791, 2451797, 2451798, 2451804, 2451805, 
                            2451811, 2451812, 2451818, 2451819, 2451825, 2451826, 2451832, 2451833, 2451839, 2451840, 2451846, 2451847, 
                            2451853, 2451854, 2451860, 2451861, 2451867, 2451868, 2451874, 2451875, 2451881, 2451882, 2451888, 2451889, 
                            2451895, 2451896, 2451902, 2451903, 2451909, 2451910, 2451916, 2451917, 2451923, 2451924, 2451930, 2451931, 
                            2451937, 2451938, 2451944, 2451945, 2451951, 2451952, 2451958, 2451959, 2451965, 2451966, 2451972, 2451973, 
                            2451979, 2451980, 2451986, 2451987, 2451993, 2451994, 2452000, 2452001, 2452007, 2452008, 2452014, 2452015, 
                            2452021, 2452022, 2452028, 2452029, 2452035, 2452036, 2452042, 2452043, 2452049, 2452050, 2452056, 2452057, 
                            2452063, 2452064, 2452070, 2452071, 2452077, 2452078, 2452084, 2452085, 2452091, 2452092, 2452098, 2452099, 
                            2452105, 2452106, 2452112, 2452113, 2452119, 2452120, 2452126, 2452127, 2452133, 2452134, 2452140, 2452141, 
                            2452147, 2452148, 2452154, 2452155, 2452161, 2452162, 2452168, 2452169, 2452175, 2452176, 2452182, 2452183, 
                            2452189, 2452190, 2452196, 2452197, 2452203, 2452204, 2452210, 2452211, 2452217, 2452218, 2452224, 2452225, 
                            2452231, 2452232, 2452238, 2452239, 2452245, 2452246, 2452252, 2452253, 2452259, 2452260, 2452266, 2452267, 
                            2452273, 2452274)
  group by
    ss_ticket_number,
    ss_customer_sk,
    ss_addr_sk,
    ca_city
  ) dn,
  customer,
  customer_address current_addr
where
  ss_customer_sk = c_customer_sk
  and customer.c_current_addr_sk = current_addr.ca_address_sk
  and current_addr.ca_city <> bought_city
order by
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number
limit 100
-- end query 46 in stream 0 using template query46.tpl
-- start query 53 in stream 0 using template query53.tpl
select
  *
from
  (select
    i_manufact_id,
    sum(ss_sales_price) sum_sales,
    avg(sum(ss_sales_price)) over (partition by i_manufact_id) avg_quarterly_sales
  from
    item,
    store_sales,
    date_dim,
    store
  where
    ss_item_sk = i_item_sk
    and ss_sold_date_sk = d_date_sk
    and ss_store_sk = s_store_sk
    and d_month_seq in (1212, 1212 + 1, 1212 + 2, 1212 + 3, 1212 + 4, 1212 + 5, 1212 + 6, 1212 + 7, 1212 + 8, 1212 + 9, 1212 + 10, 1212 + 11)
    and ((i_category in ('Books', 'Children', 'Electronics')
      and i_class in ('personal', 'portable', 'reference', 'self-help')
      and i_brand in ('scholaramalgamalg #14', 'scholaramalgamalg #7', 'exportiunivamalg #9', 'scholaramalgamalg #9'))
    or (i_category in ('Women', 'Music', 'Men')
      and i_class in ('accessories', 'classical', 'fragrances', 'pants')
      and i_brand in ('amalgimporto #1', 'edu packscholar #1', 'exportiimporto #1', 'importoamalg #1')))
    and ss_sold_date_sk between 2451911 and 2452275 -- partition key filter
  group by
    i_manufact_id,
    d_qoy
  ) tmp1
where
  case when avg_quarterly_sales > 0 then abs (sum_sales - avg_quarterly_sales) / avg_quarterly_sales else null end > 0.1
order by
  avg_quarterly_sales,
  sum_sales,
  i_manufact_id
limit 100
-- end query 53 in stream 0 using template query53.tpl
-- start query 65 in stream 0 using template query65.tpl
select
  s_store_name,
  i_item_desc,
  sc.revenue,
  i_current_price,
  i_wholesale_cost,
  i_brand
from
  store,
  item,
  (select
    ss_store_sk,
    avg(revenue) as ave
  from
    (select
      ss_store_sk,
      ss_item_sk,
      sum(ss_sales_price) as revenue
    from
      store_sales,
      date_dim
    where
      ss_sold_date_sk = d_date_sk
      and d_month_seq between 1212 and 1212 + 11
      and ss_sold_date_sk between 2451911 and 2452275  -- partition key filter
    group by
      ss_store_sk,
      ss_item_sk
    ) sa
  group by
    ss_store_sk
  ) sb,
  (select
    ss_store_sk,
    ss_item_sk,
    sum(ss_sales_price) as revenue
  from
    store_sales,
    date_dim
  where
    ss_sold_date_sk = d_date_sk
    and d_month_seq between 1212 and 1212 + 11
    and ss_sold_date_sk between 2451911 and 2452275  -- partition key filter
  group by
    ss_store_sk,
    ss_item_sk
  ) sc
where
  sb.ss_store_sk = sc.ss_store_sk
  and sc.revenue <= 0.1 * sb.ave
  and s_store_sk = sc.ss_store_sk
  and i_item_sk = sc.ss_item_sk
order by
  s_store_name,
  i_item_desc
limit 100
-- end query 65 in stream 0 using template query65.tpl
-- start query 3 in stream 0 using template query3.tpl
select
  dt.d_year,
  item.i_brand_id brand_id,
  item.i_brand brand,
  sum(ss_net_profit) sum_agg
from
  date_dim dt,
  store_sales,
  item
where
  dt.d_date_sk = store_sales.ss_sold_date_sk
  and store_sales.ss_item_sk = item.i_item_sk
  and item.i_manufact_id = 436
  and dt.d_moy = 12
  -- partition key filters
  and ( 
ss_sold_date_sk between 2415355 and 2415385
or ss_sold_date_sk between 2415720 and 2415750
or ss_sold_date_sk between 2416085 and 2416115
or ss_sold_date_sk between 2416450 and 2416480
or ss_sold_date_sk between 2416816 and 2416846
or ss_sold_date_sk between 2417181 and 2417211
or ss_sold_date_sk between 2417546 and 2417576
or ss_sold_date_sk between 2417911 and 2417941
or ss_sold_date_sk between 2418277 and 2418307
or ss_sold_date_sk between 2418642 and 2418672
or ss_sold_date_sk between 2419007 and 2419037
or ss_sold_date_sk between 2419372 and 2419402
or ss_sold_date_sk between 2419738 and 2419768
or ss_sold_date_sk between 2420103 and 2420133
or ss_sold_date_sk between 2420468 and 2420498
or ss_sold_date_sk between 2420833 and 2420863
or ss_sold_date_sk between 2421199 and 2421229
or ss_sold_date_sk between 2421564 and 2421594
or ss_sold_date_sk between 2421929 and 2421959
or ss_sold_date_sk between 2422294 and 2422324
or ss_sold_date_sk between 2422660 and 2422690
or ss_sold_date_sk between 2423025 and 2423055
or ss_sold_date_sk between 2423390 and 2423420
or ss_sold_date_sk between 2423755 and 2423785
or ss_sold_date_sk between 2424121 and 2424151
or ss_sold_date_sk between 2424486 and 2424516
or ss_sold_date_sk between 2424851 and 2424881
or ss_sold_date_sk between 2425216 and 2425246
or ss_sold_date_sk between 2425582 and 2425612
or ss_sold_date_sk between 2425947 and 2425977
or ss_sold_date_sk between 2426312 and 2426342
or ss_sold_date_sk between 2426677 and 2426707
or ss_sold_date_sk between 2427043 and 2427073
or ss_sold_date_sk between 2427408 and 2427438
or ss_sold_date_sk between 2427773 and 2427803
or ss_sold_date_sk between 2428138 and 2428168
or ss_sold_date_sk between 2428504 and 2428534
or ss_sold_date_sk between 2428869 and 2428899
or ss_sold_date_sk between 2429234 and 2429264
or ss_sold_date_sk between 2429599 and 2429629
or ss_sold_date_sk between 2429965 and 2429995
or ss_sold_date_sk between 2430330 and 2430360
or ss_sold_date_sk between 2430695 and 2430725
or ss_sold_date_sk between 2431060 and 2431090
or ss_sold_date_sk between 2431426 and 2431456
or ss_sold_date_sk between 2431791 and 2431821
or ss_sold_date_sk between 2432156 and 2432186
or ss_sold_date_sk between 2432521 and 2432551
or ss_sold_date_sk between 2432887 and 2432917
or ss_sold_date_sk between 2433252 and 2433282
or ss_sold_date_sk between 2433617 and 2433647
or ss_sold_date_sk between 2433982 and 2434012
or ss_sold_date_sk between 2434348 and 2434378
or ss_sold_date_sk between 2434713 and 2434743
or ss_sold_date_sk between 2435078 and 2435108
or ss_sold_date_sk between 2435443 and 2435473
or ss_sold_date_sk between 2435809 and 2435839
or ss_sold_date_sk between 2436174 and 2436204
or ss_sold_date_sk between 2436539 and 2436569
or ss_sold_date_sk between 2436904 and 2436934
or ss_sold_date_sk between 2437270 and 2437300
or ss_sold_date_sk between 2437635 and 2437665
or ss_sold_date_sk between 2438000 and 2438030
or ss_sold_date_sk between 2438365 and 2438395
or ss_sold_date_sk between 2438731 and 2438761
or ss_sold_date_sk between 2439096 and 2439126
or ss_sold_date_sk between 2439461 and 2439491
or ss_sold_date_sk between 2439826 and 2439856
or ss_sold_date_sk between 2440192 and 2440222
or ss_sold_date_sk between 2440557 and 2440587
or ss_sold_date_sk between 2440922 and 2440952
or ss_sold_date_sk between 2441287 and 2441317
or ss_sold_date_sk between 2441653 and 2441683
or ss_sold_date_sk between 2442018 and 2442048
or ss_sold_date_sk between 2442383 and 2442413
or ss_sold_date_sk between 2442748 and 2442778
or ss_sold_date_sk between 2443114 and 2443144
or ss_sold_date_sk between 2443479 and 2443509
or ss_sold_date_sk between 2443844 and 2443874
or ss_sold_date_sk between 2444209 and 2444239
or ss_sold_date_sk between 2444575 and 2444605
or ss_sold_date_sk between 2444940 and 2444970
or ss_sold_date_sk between 2445305 and 2445335
or ss_sold_date_sk between 2445670 and 2445700
or ss_sold_date_sk between 2446036 and 2446066
or ss_sold_date_sk between 2446401 and 2446431
or ss_sold_date_sk between 2446766 and 2446796
or ss_sold_date_sk between 2447131 and 2447161
or ss_sold_date_sk between 2447497 and 2447527
or ss_sold_date_sk between 2447862 and 2447892
or ss_sold_date_sk between 2448227 and 2448257
or ss_sold_date_sk between 2448592 and 2448622
or ss_sold_date_sk between 2448958 and 2448988
or ss_sold_date_sk between 2449323 and 2449353
or ss_sold_date_sk between 2449688 and 2449718
or ss_sold_date_sk between 2450053 and 2450083
or ss_sold_date_sk between 2450419 and 2450449
or ss_sold_date_sk between 2450784 and 2450814
or ss_sold_date_sk between 2451149 and 2451179
or ss_sold_date_sk between 2451514 and 2451544
or ss_sold_date_sk between 2451880 and 2451910
or ss_sold_date_sk between 2452245 and 2452275
or ss_sold_date_sk between 2452610 and 2452640
or ss_sold_date_sk between 2452975 and 2453005
or ss_sold_date_sk between 2453341 and 2453371
or ss_sold_date_sk between 2453706 and 2453736
or ss_sold_date_sk between 2454071 and 2454101
or ss_sold_date_sk between 2454436 and 2454466
or ss_sold_date_sk between 2454802 and 2454832
or ss_sold_date_sk between 2455167 and 2455197
or ss_sold_date_sk between 2455532 and 2455562
or ss_sold_date_sk between 2455897 and 2455927
or ss_sold_date_sk between 2456263 and 2456293
or ss_sold_date_sk between 2456628 and 2456658
or ss_sold_date_sk between 2456993 and 2457023
or ss_sold_date_sk between 2457358 and 2457388
or ss_sold_date_sk between 2457724 and 2457754
or ss_sold_date_sk between 2458089 and 2458119
or ss_sold_date_sk between 2458454 and 2458484
or ss_sold_date_sk between 2458819 and 2458849
or ss_sold_date_sk between 2459185 and 2459215
or ss_sold_date_sk between 2459550 and 2459580
or ss_sold_date_sk between 2459915 and 2459945
or ss_sold_date_sk between 2460280 and 2460310
or ss_sold_date_sk between 2460646 and 2460676
or ss_sold_date_sk between 2461011 and 2461041
or ss_sold_date_sk between 2461376 and 2461406
or ss_sold_date_sk between 2461741 and 2461771
or ss_sold_date_sk between 2462107 and 2462137
or ss_sold_date_sk between 2462472 and 2462502
or ss_sold_date_sk between 2462837 and 2462867
or ss_sold_date_sk between 2463202 and 2463232
or ss_sold_date_sk between 2463568 and 2463598
or ss_sold_date_sk between 2463933 and 2463963
or ss_sold_date_sk between 2464298 and 2464328
or ss_sold_date_sk between 2464663 and 2464693
or ss_sold_date_sk between 2465029 and 2465059
or ss_sold_date_sk between 2465394 and 2465424
or ss_sold_date_sk between 2465759 and 2465789
or ss_sold_date_sk between 2466124 and 2466154
or ss_sold_date_sk between 2466490 and 2466520
or ss_sold_date_sk between 2466855 and 2466885
or ss_sold_date_sk between 2467220 and 2467250
or ss_sold_date_sk between 2467585 and 2467615
or ss_sold_date_sk between 2467951 and 2467981
or ss_sold_date_sk between 2468316 and 2468346
or ss_sold_date_sk between 2468681 and 2468711
or ss_sold_date_sk between 2469046 and 2469076
or ss_sold_date_sk between 2469412 and 2469442
or ss_sold_date_sk between 2469777 and 2469807
or ss_sold_date_sk between 2470142 and 2470172
or ss_sold_date_sk between 2470507 and 2470537
or ss_sold_date_sk between 2470873 and 2470903
or ss_sold_date_sk between 2471238 and 2471268
or ss_sold_date_sk between 2471603 and 2471633
or ss_sold_date_sk between 2471968 and 2471998
or ss_sold_date_sk between 2472334 and 2472364
or ss_sold_date_sk between 2472699 and 2472729
or ss_sold_date_sk between 2473064 and 2473094
or ss_sold_date_sk between 2473429 and 2473459
or ss_sold_date_sk between 2473795 and 2473825
or ss_sold_date_sk between 2474160 and 2474190
or ss_sold_date_sk between 2474525 and 2474555
or ss_sold_date_sk between 2474890 and 2474920
or ss_sold_date_sk between 2475256 and 2475286
or ss_sold_date_sk between 2475621 and 2475651
or ss_sold_date_sk between 2475986 and 2476016
or ss_sold_date_sk between 2476351 and 2476381
or ss_sold_date_sk between 2476717 and 2476747
or ss_sold_date_sk between 2477082 and 2477112
or ss_sold_date_sk between 2477447 and 2477477
or ss_sold_date_sk between 2477812 and 2477842
or ss_sold_date_sk between 2478178 and 2478208
or ss_sold_date_sk between 2478543 and 2478573
or ss_sold_date_sk between 2478908 and 2478938
or ss_sold_date_sk between 2479273 and 2479303
or ss_sold_date_sk between 2479639 and 2479669
or ss_sold_date_sk between 2480004 and 2480034
or ss_sold_date_sk between 2480369 and 2480399
or ss_sold_date_sk between 2480734 and 2480764
or ss_sold_date_sk between 2481100 and 2481130
or ss_sold_date_sk between 2481465 and 2481495
or ss_sold_date_sk between 2481830 and 2481860
or ss_sold_date_sk between 2482195 and 2482225
or ss_sold_date_sk between 2482561 and 2482591
or ss_sold_date_sk between 2482926 and 2482956
or ss_sold_date_sk between 2483291 and 2483321
or ss_sold_date_sk between 2483656 and 2483686
or ss_sold_date_sk between 2484022 and 2484052
or ss_sold_date_sk between 2484387 and 2484417
or ss_sold_date_sk between 2484752 and 2484782
or ss_sold_date_sk between 2485117 and 2485147
or ss_sold_date_sk between 2485483 and 2485513
or ss_sold_date_sk between 2485848 and 2485878
or ss_sold_date_sk between 2486213 and 2486243
or ss_sold_date_sk between 2486578 and 2486608
or ss_sold_date_sk between 2486944 and 2486974
or ss_sold_date_sk between 2487309 and 2487339
or ss_sold_date_sk between 2487674 and 2487704
or ss_sold_date_sk between 2488039 and 2488069
)
group by
  dt.d_year,
  item.i_brand,
  item.i_brand_id
order by
  dt.d_year,
  sum_agg desc,
  brand_id
limit 100
-- end query 3 in stream 0 using template query3.tpl
-- start query 73 in stream 0 using template query73.tpl
select
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag,
  ss_ticket_number,
  cnt
from
  (select
    ss_ticket_number,
    ss_customer_sk,
    count(*) cnt
  from
    store_sales,
    date_dim,
    store,
    household_demographics
  where
    store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and date_dim.d_dom between 1 and 2
    and (household_demographics.hd_buy_potential = '>10000'
      or household_demographics.hd_buy_potential = 'Unknown')
    and household_demographics.hd_vehicle_count > 0
    and case when household_demographics.hd_vehicle_count > 0 then household_demographics.hd_dep_count / household_demographics.hd_vehicle_count else null end > 1
    and date_dim.d_year in (1998, 1998 + 1, 1998 + 2)
    and store.s_county in ('Fairfield County','Ziebach County','Bronx County','Barrow County')
    -- partition key filter
    and ss_sold_date_sk in (2450815, 2450816, 2450846, 2450847, 2450874, 2450875, 2450905, 2450906, 2450935, 2450936, 2450966, 2450967, 
                            2450996, 2450997, 2451027, 2451028, 2451058, 2451059, 2451088, 2451089, 2451119, 2451120, 2451149, 
                            2451150, 2451180, 2451181, 2451211, 2451212, 2451239, 2451240, 2451270, 2451271, 2451300, 2451301, 
                            2451331, 2451332, 2451361, 2451362, 2451392, 2451393, 2451423, 2451424, 2451453, 2451454, 2451484, 
                            2451485, 2451514, 2451515, 2451545, 2451546, 2451576, 2451577, 2451605, 2451606, 2451636, 2451637, 
                            2451666, 2451667, 2451697, 2451698, 2451727, 2451728, 2451758, 2451759, 2451789, 2451790, 2451819, 
                            2451820, 2451850, 2451851, 2451880, 2451881)    
    --and ss_sold_date_sk between 2451180 and 2451269 -- partition key filter (3 months)
  group by
    ss_ticket_number,
    ss_customer_sk
  ) dj,
  customer
where
  ss_customer_sk = c_customer_sk
  and cnt between 1 and 5
order by
  cnt desc
-- end query 73 in stream 0 using template query73.tpl
-- start query 19 in stream 0 using template query19.tpl
select
  i_brand_id brand_id,
  i_brand brand,
  i_manufact_id,
  i_manufact,
  sum(ss_ext_sales_price) ext_price
from
  date_dim,
  store_sales,
  item,
  customer,
  customer_address,
  store
where
  d_date_sk = ss_sold_date_sk
  and ss_item_sk = i_item_sk
  and i_manager_id = 7
  and d_moy = 11
  and d_year = 1999
  and ss_customer_sk = c_customer_sk
  and c_current_addr_sk = ca_address_sk
  and substr(ca_zip, 1, 5) <> substr(s_zip, 1, 5)
  and ss_store_sk = s_store_sk
  and ss_sold_date_sk between 2451484 and 2451513  -- partition key filter
group by
  i_brand,
  i_brand_id,
  i_manufact_id,
  i_manufact
order by
  ext_price desc,
  i_brand,
  i_brand_id,
  i_manufact_id,
  i_manufact
limit 100
-- end query 19 in stream 0 using template query19.tpl
-- start query 63 in stream 0 using template query63.tpl
select  * 
from (select i_manager_id
             ,sum(ss_sales_price) sum_sales
             ,avg(sum(ss_sales_price)) over (partition by i_manager_id) avg_monthly_sales
      from item
          ,store_sales
          ,date_dim
          ,store
      where ss_item_sk = i_item_sk
        and ss_sold_date_sk = d_date_sk
	and ss_sold_date_sk between 2452123 and	2452487
        and ss_store_sk = s_store_sk
        and d_month_seq in (1219,1219+1,1219+2,1219+3,1219+4,1219+5,1219+6,1219+7,1219+8,1219+9,1219+10,1219+11)
        and ((    i_category in ('Books','Children','Electronics')
              and i_class in ('personal','portable','reference','self-help')
              and i_brand in ('scholaramalgamalg #14','scholaramalgamalg #7',
		                  'exportiunivamalg #9','scholaramalgamalg #9'))
           or(    i_category in ('Women','Music','Men')
              and i_class in ('accessories','classical','fragrances','pants')
              and i_brand in ('amalgimporto #1','edu packscholar #1','exportiimporto #1',
		                 'importoamalg #1')))
group by i_manager_id, d_moy) tmp1
where case when avg_monthly_sales > 0 then abs (sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
order by i_manager_id
        ,avg_monthly_sales
        ,sum_sales
limit 100
-- end query 63 in stream 0 using template query63.tpl
select 
  count(*) as total,
  count(ss_sold_date_sk) as not_null_total,
  count(distinct ss_sold_date_sk) as unique_days,
  max(ss_sold_date_sk) as max_ss_sold_date_sk,
  max(ss_sold_time_sk) as max_ss_sold_time_sk,
  max(ss_item_sk) as max_ss_item_sk,
  max(ss_customer_sk) as max_ss_customer_sk,
  max(ss_cdemo_sk) as max_ss_cdemo_sk,
  max(ss_hdemo_sk) as max_ss_hdemo_sk,
  max(ss_addr_sk) as max_ss_addr_sk,
  max(ss_store_sk) as max_ss_store_sk,
  max(ss_promo_sk) as max_ss_promo_sk
from store_sales
-- start query 89 in stream 0 using template query89.tpl
select
  *
from
  (select
    i_category,
    i_class,
    i_brand,
    s_store_name,
    s_company_name,
    d_moy,
    sum(ss_sales_price) sum_sales,
    avg(sum(ss_sales_price)) over (partition by i_category, i_brand, s_store_name, s_company_name) avg_monthly_sales
  from
    item,
    store_sales,
    date_dim,
    store
  where
    ss_item_sk = i_item_sk
    and ss_sold_date_sk = d_date_sk
    and ss_store_sk = s_store_sk
    and d_year in (2000)
    and ((i_category in ('Home', 'Books', 'Electronics')
        and i_class in ('wallpaper', 'parenting', 'musical'))
      or (i_category in ('Shoes', 'Jewelry', 'Men')
        and i_class in ('womens', 'birdal', 'pants')))
    and ss_sold_date_sk between 2451545 and 2451910  -- partition key filter
  group by
    i_category,
    i_class,
    i_brand,
    s_store_name,
    s_company_name,
    d_moy
  ) tmp1
where
  case when (avg_monthly_sales <> 0) then (abs(sum_sales - avg_monthly_sales) / avg_monthly_sales) else null end > 0.1
order by
  sum_sales - avg_monthly_sales,
  s_store_name
limit 100
-- end query 89 in stream 0 using template query89.tpl
-- start query 98 in stream 0 using template query98.tpl
select
  i_item_desc,
  i_category,
  i_class,
  i_current_price,
  sum(ss_ext_sales_price) as itemrevenue,
  sum(ss_ext_sales_price) * 100 / sum(sum(ss_ext_sales_price)) over (partition by i_class) as revenueratio
from
  store_sales,
  item,
  date_dim
where
  ss_item_sk = i_item_sk
  and i_category in ('Jewelry', 'Sports', 'Books')
  and ss_sold_date_sk = d_date_sk
  and ss_sold_date_sk between 2451911 and 2451941  -- partition key filter (1 calendar month)
  and d_date between '2001-01-01' and '2001-01-31'
group by
  i_item_id,
  i_item_desc,
  i_category,
  i_class,
  i_current_price
order by
  i_category,
  i_class,
  i_item_id,
  i_item_desc,
  revenueratio
--limit 1000; -- added limit
-- end query 98 in stream 0 using template query98.tpl
-- start query 34 in stream 0 using template query34.tpl
select
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag,
  ss_ticket_number,
  cnt
from
  (select
    ss_ticket_number,
    ss_customer_sk,
    count(*) cnt
  from
    store_sales,
    date_dim,
    store,
    household_demographics
  where
    store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (date_dim.d_dom between 1 and 3
      or date_dim.d_dom between 25 and 28)
    and (household_demographics.hd_buy_potential = '>10000'
      or household_demographics.hd_buy_potential = 'Unknown')
    and household_demographics.hd_vehicle_count > 0
    and (case when household_demographics.hd_vehicle_count > 0 then household_demographics.hd_dep_count / household_demographics.hd_vehicle_count else null end) > 1.2
    and date_dim.d_year in (1998, 1998 + 1, 1998 + 2)
    and store.s_county in ('Saginaw County', 'Sumner County', 'Appanoose County', 'Daviess County', 'Fairfield County', 'Raleigh County', 'Ziebach County', 'Williamson County')
    and ss_sold_date_sk between 2450816 and 2451910 -- partition key filter
  group by
    ss_ticket_number,
    ss_customer_sk
  ) dn,
  customer
where
  ss_customer_sk = c_customer_sk
  and cnt between 15 and 20
order by
  c_last_name,
  c_first_name,
  c_salutation,
  c_preferred_cust_flag desc
-- end query 34 in stream 0 using template query34.tpl
-- start query 52 in stream 0 using template query52.tpl
select
  dt.d_year,
  item.i_brand_id brand_id,
  item.i_brand brand,
  sum(ss_ext_sales_price) ext_price
from
  date_dim dt,
  store_sales,
  item
where
  dt.d_date_sk = store_sales.ss_sold_date_sk
  and store_sales.ss_item_sk = item.i_item_sk
  and item.i_manager_id = 1
  and dt.d_moy = 12
  and dt.d_year = 1998
  and ss_sold_date_sk between 2451149 and 2451179 -- added for partition pruning
group by
  dt.d_year,
  item.i_brand,
  item.i_brand_id
order by
  dt.d_year,
  ext_price desc,
  brand_id
limit 100
-- end query 52 in stream 0 using template query52.tpl
-- start query 79 in stream 0 using template query79.tpl
select
  c_last_name,
  c_first_name,
  substr(s_city, 1, 30),
  ss_ticket_number,
  amt,
  profit
from
  (select
    ss_ticket_number,
    ss_customer_sk,
    store.s_city,
    sum(ss_coupon_amt) amt,
    sum(ss_net_profit) profit
  from
    store_sales,
    date_dim,
    store,
    household_demographics
  where
    store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (household_demographics.hd_dep_count = 8
      or household_demographics.hd_vehicle_count > 0)
    and date_dim.d_dow = 1
     and date_dim.d_year in (1998, 1998 + 1, 1998 + 2)
    and store.s_number_employees between 200 and 295
    and ss_sold_date_sk between 2450819 and 2451904
    -- partition key filter
    --and ss_sold_date_sk in (2450819, 2450826, 2450833, 2450840, 2450847, 2450854, 2450861, 2450868, 2450875, 2450882, 2450889,
    -- 2450896, 2450903, 2450910, 2450917, 2450924, 2450931, 2450938, 2450945, 2450952, 2450959, 2450966, 2450973, 2450980, 2450987,
    -- 2450994, 2451001, 2451008, 2451015, 2451022, 2451029, 2451036, 2451043, 2451050, 2451057, 2451064, 2451071, 2451078, 2451085,
    -- 2451092, 2451099, 2451106, 2451113, 2451120, 2451127, 2451134, 2451141, 2451148, 2451155, 2451162, 2451169, 2451176, 2451183,
    -- 2451190, 2451197, 2451204, 2451211, 2451218, 2451225, 2451232, 2451239, 2451246, 2451253, 2451260, 2451267, 2451274, 2451281,
    -- 2451288, 2451295, 2451302, 2451309, 2451316, 2451323, 2451330, 2451337, 2451344, 2451351, 2451358, 2451365, 2451372, 2451379,
    -- 2451386, 2451393, 2451400, 2451407, 2451414, 2451421, 2451428, 2451435, 2451442, 2451449, 2451456, 2451463, 2451470, 2451477,
    -- 2451484, 2451491, 2451498, 2451505, 2451512, 2451519, 2451526, 2451533, 2451540, 2451547, 2451554, 2451561, 2451568, 2451575,
    -- 2451582, 2451589, 2451596, 2451603, 2451610, 2451617, 2451624, 2451631, 2451638, 2451645, 2451652, 2451659, 2451666, 2451673,
    -- 2451680, 2451687, 2451694, 2451701, 2451708, 2451715, 2451722, 2451729, 2451736, 2451743, 2451750, 2451757, 2451764, 2451771,
    -- 2451778, 2451785, 2451792, 2451799, 2451806, 2451813, 2451820, 2451827, 2451834, 2451841, 2451848, 2451855, 2451862, 2451869,
    -- 2451876, 2451883, 2451890, 2451897, 2451904)    
  group by
    ss_ticket_number,
    ss_customer_sk,
    ss_addr_sk,
    store.s_city
  ) ms,
  customer
where
  ss_customer_sk = c_customer_sk
order by
  c_last_name,
  c_first_name,
  substr(s_city, 1, 30),
  profit 
  limit 100
-- end query 79 in stream 0 using template query79.tpl
-- start query 68 in stream 0 using template query68.tpl
-- changed to match exact same partitions in original query
select
  c_last_name,
  c_first_name,
  ca_city,
  bought_city,
  ss_ticket_number,
  extended_price,
  extended_tax,
  list_price
from
  (select
    ss_ticket_number,
    ss_customer_sk,
    ca_city bought_city,
    sum(ss_ext_sales_price) extended_price,
    sum(ss_ext_list_price) list_price,
    sum(ss_ext_tax) extended_tax
  from
    store_sales,
    date_dim,
    store,
    household_demographics,
    customer_address
  where
    store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and store_sales.ss_addr_sk = customer_address.ca_address_sk
    and date_dim.d_dom between 1 and 2
    and (household_demographics.hd_dep_count = 5
      or household_demographics.hd_vehicle_count = 3)
    and date_dim.d_year in (1999, 1999 + 1, 1999 + 2)
    and store.s_city in ('Midway', 'Fairview')
    -- partition key filter
    and ss_sold_date_sk in (2451180, 2451181, 2451211, 2451212, 2451239, 2451240, 2451270, 2451271, 2451300, 2451301, 2451331, 
                             2451332, 2451361, 2451362, 2451392, 2451393, 2451423, 2451424, 2451453, 2451454, 2451484, 2451485, 
                             2451514, 2451515, 2451545, 2451546, 2451576, 2451577, 2451605, 2451606, 2451636, 2451637, 2451666, 
                             2451667, 2451697, 2451698, 2451727, 2451728, 2451758, 2451759, 2451789, 2451790, 2451819, 2451820, 
                             2451850, 2451851, 2451880, 2451881, 2451911, 2451912, 2451942, 2451943, 2451970, 2451971, 2452001, 
                             2452002, 2452031, 2452032, 2452062, 2452063, 2452092, 2452093, 2452123, 2452124, 2452154, 2452155, 
                             2452184, 2452185, 2452215, 2452216, 2452245, 2452246) 
    --and ss_sold_date_sk between 2451180 and 2451269 -- partition key filter (3 months)
    --and d_date between '1999-01-01' and '1999-03-31'
  group by
    ss_ticket_number,
    ss_customer_sk,
    ss_addr_sk,
    ca_city
  ) dn,
  customer,
  customer_address current_addr
where
  ss_customer_sk = c_customer_sk
  and customer.c_current_addr_sk = current_addr.ca_address_sk
  and current_addr.ca_city <> bought_city
order by
  c_last_name,
  ss_ticket_number
limit 100
-- end query 68 in stream 0 using template query68.tpl
-- date time functions

-- [SPARK-16836] current_date and current_timestamp literals
select current_date = current_date(), current_timestamp = current_timestamp();

select to_date(null), to_date('2016-12-31'), to_date('2016-12-31', 'yyyy-MM-dd');

select to_timestamp(null), to_timestamp('2016-12-31 00:12:00'), to_timestamp('2016-12-31', 'yyyy-MM-dd');

select dayofweek('2007-02-03'), dayofweek('2009-07-30'), dayofweek('2017-05-27'), dayofweek(null), dayofweek('1582-10-15 13:10:15');

-- [SPARK-22333]: timeFunctionCall has conflicts with columnReference
create temporary view ttf1 as select * from values
  (1, 2),
  (2, 3)
  as ttf1(current_date, current_timestamp);
  
select current_date, current_timestamp from ttf1;

create temporary view ttf2 as select * from values
  (1, 2),
  (2, 3)
  as ttf2(a, b);
  
select current_date = current_date(), current_timestamp = current_timestamp(), a, b from ttf2;

select a, b from ttf2 order by a, current_date;

select weekday('2007-02-03'), weekday('2009-07-30'), weekday('2017-05-27'), weekday(null), weekday('1582-10-15 13:10:15');

select year('1500-01-01'), month('1500-01-01'), dayOfYear('1500-01-01');-- EqualTo
select 1 = 1;
select 1 = '1';
select 1.0 = '1';
select 1.5 = '1.51';

-- GreaterThan
select 1 > '1';
select 2 > '1.0';
select 2 > '2.0';
select 2 > '2.2';
select '1.5' > 0.5;
select to_date('2009-07-30 04:17:52') > to_date('2009-07-30 04:17:52');
select to_date('2009-07-30 04:17:52') > '2009-07-30 04:17:52';
 
-- GreaterThanOrEqual
select 1 >= '1';
select 2 >= '1.0';
select 2 >= '2.0';
select 2.0 >= '2.2';
select '1.5' >= 0.5;
select to_date('2009-07-30 04:17:52') >= to_date('2009-07-30 04:17:52');
select to_date('2009-07-30 04:17:52') >= '2009-07-30 04:17:52';
 
-- LessThan
select 1 < '1';
select 2 < '1.0';
select 2 < '2.0';
select 2.0 < '2.2';
select 0.5 < '1.5';
select to_date('2009-07-30 04:17:52') < to_date('2009-07-30 04:17:52');
select to_date('2009-07-30 04:17:52') < '2009-07-30 04:17:52';
 
-- LessThanOrEqual
select 1 <= '1';
select 2 <= '1.0';
select 2 <= '2.0';
select 2.0 <= '2.2';
select 0.5 <= '1.5';
select to_date('2009-07-30 04:17:52') <= to_date('2009-07-30 04:17:52');
select to_date('2009-07-30 04:17:52') <= '2009-07-30 04:17:52';

-- SPARK-23549: Cast to timestamp when comparing timestamp with date
select to_date('2017-03-01') = to_timestamp('2017-03-01 00:00:00');
select to_timestamp('2017-03-01 00:00:01') > to_date('2017-03-01');
select to_timestamp('2017-03-01 00:00:01') >= to_date('2017-03-01');
select to_date('2017-03-01') < to_timestamp('2017-03-01 00:00:01');
select to_date('2017-03-01') <= to_timestamp('2017-03-01 00:00:01');
CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES
(1, 1), (1, 2), (2, 1), (2, 2), (3, 1), (3, 2)
AS testData(a, b);

-- CUBE on overlapping columns
SELECT a + b, b, SUM(a - b) FROM testData GROUP BY a + b, b WITH CUBE;

SELECT a, b, SUM(b) FROM testData GROUP BY a, b WITH CUBE;

-- ROLLUP on overlapping columns
SELECT a + b, b, SUM(a - b) FROM testData GROUP BY a + b, b WITH ROLLUP;

SELECT a, b, SUM(b) FROM testData GROUP BY a, b WITH ROLLUP;

CREATE OR REPLACE TEMPORARY VIEW courseSales AS SELECT * FROM VALUES
("dotNET", 2012, 10000), ("Java", 2012, 20000), ("dotNET", 2012, 5000), ("dotNET", 2013, 48000), ("Java", 2013, 30000)
AS courseSales(course, year, earnings);

-- ROLLUP
SELECT course, year, SUM(earnings) FROM courseSales GROUP BY ROLLUP(course, year) ORDER BY course, year;

-- CUBE
SELECT course, year, SUM(earnings) FROM courseSales GROUP BY CUBE(course, year) ORDER BY course, year;

-- GROUPING SETS
SELECT course, year, SUM(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(course, year);
SELECT course, year, SUM(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(course);
SELECT course, year, SUM(earnings) FROM courseSales GROUP BY course, year GROUPING SETS(year);

-- GROUPING SETS with aggregate functions containing groupBy columns
SELECT course, SUM(earnings) AS sum FROM courseSales
GROUP BY course, earnings GROUPING SETS((), (course), (course, earnings)) ORDER BY course, sum;
SELECT course, SUM(earnings) AS sum, GROUPING_ID(course, earnings) FROM courseSales
GROUP BY course, earnings GROUPING SETS((), (course), (course, earnings)) ORDER BY course, sum;

-- GROUPING/GROUPING_ID
SELECT course, year, GROUPING(course), GROUPING(year), GROUPING_ID(course, year) FROM courseSales
GROUP BY CUBE(course, year);
SELECT course, year, GROUPING(course) FROM courseSales GROUP BY course, year;
SELECT course, year, GROUPING_ID(course, year) FROM courseSales GROUP BY course, year;
SELECT course, year, grouping__id FROM courseSales GROUP BY CUBE(course, year) ORDER BY grouping__id, course, year;

-- GROUPING/GROUPING_ID in having clause
SELECT course, year FROM courseSales GROUP BY CUBE(course, year)
HAVING GROUPING(year) = 1 AND GROUPING_ID(course, year) > 0 ORDER BY course, year;
SELECT course, year FROM courseSales GROUP BY course, year HAVING GROUPING(course) > 0;
SELECT course, year FROM courseSales GROUP BY course, year HAVING GROUPING_ID(course) > 0;
SELECT course, year FROM courseSales GROUP BY CUBE(course, year) HAVING grouping__id > 0;

-- GROUPING/GROUPING_ID in orderBy clause
SELECT course, year, GROUPING(course), GROUPING(year) FROM courseSales GROUP BY CUBE(course, year)
ORDER BY GROUPING(course), GROUPING(year), course, year;
SELECT course, year, GROUPING_ID(course, year) FROM courseSales GROUP BY CUBE(course, year)
ORDER BY GROUPING(course), GROUPING(year), course, year;
SELECT course, year FROM courseSales GROUP BY course, year ORDER BY GROUPING(course);
SELECT course, year FROM courseSales GROUP BY course, year ORDER BY GROUPING_ID(course);
SELECT course, year FROM courseSales GROUP BY CUBE(course, year) ORDER BY grouping__id, course, year;

-- Aliases in SELECT could be used in ROLLUP/CUBE/GROUPING SETS
SELECT a + b AS k1, b AS k2, SUM(a - b) FROM testData GROUP BY CUBE(k1, k2);
SELECT a + b AS k, b, SUM(a - b) FROM testData GROUP BY ROLLUP(k, b);
SELECT a + b, b AS k, SUM(a - b) FROM testData GROUP BY a + b, k GROUPING SETS(k)
CREATE OR REPLACE TEMPORARY VIEW tbl_a AS VALUES (1, 1), (2, 1), (3, 6) AS T(c1, c2);
CREATE OR REPLACE TEMPORARY VIEW tbl_b AS VALUES 1 AS T(c1);

-- SPARK-18597: Do not push down predicates to left hand side in an anti-join
SELECT *
FROM   tbl_a
       LEFT ANTI JOIN tbl_b ON ((tbl_a.c1 = tbl_a.c2) IS NULL OR tbl_a.c1 = tbl_a.c2);

-- SPARK-18614: Do not push down predicates on left table below ExistenceJoin
SELECT l.c1, l.c2
FROM   tbl_a l
WHERE  EXISTS (SELECT 1 FROM tbl_b r WHERE l.c1 = l.c2) OR l.c2 < 2;
CREATE TABLE table_with_comment (a STRING, b INT, c STRING, d STRING) USING parquet COMMENT 'added';

DESC FORMATTED table_with_comment;

-- ALTER TABLE BY MODIFYING COMMENT
ALTER TABLE table_with_comment SET TBLPROPERTIES("comment"= "modified comment", "type"= "parquet");

DESC FORMATTED table_with_comment;

-- DROP TEST TABLE
DROP TABLE table_with_comment;

-- CREATE TABLE WITHOUT COMMENT
CREATE TABLE table_comment (a STRING, b INT) USING parquet;

DESC FORMATTED table_comment;

-- ALTER TABLE BY ADDING COMMENT
ALTER TABLE table_comment SET TBLPROPERTIES(comment = "added comment");

DESC formatted table_comment;

-- ALTER UNSET PROPERTIES COMMENT
ALTER TABLE table_comment UNSET TBLPROPERTIES IF EXISTS ('comment');

DESC FORMATTED table_comment;

-- DROP TEST TABLE
DROP TABLE table_comment;

-- single row, without table and column alias
select * from values ("one", 1);

-- single row, without column alias
select * from values ("one", 1) as data;

-- single row
select * from values ("one", 1) as data(a, b);

-- single column multiple rows
select * from values 1, 2, 3 as data(a);

-- three rows
select * from values ("one", 1), ("two", 2), ("three", null) as data(a, b);

-- null type
select * from values ("one", null), ("two", null) as data(a, b);

-- int and long coercion
select * from values ("one", 1), ("two", 2L) as data(a, b);

-- foldable expressions
select * from values ("one", 1 + 0), ("two", 1 + 3L) as data(a, b);

-- complex types
select * from values ("one", array(0, 1)), ("two", array(2, 3)) as data(a, b);

-- decimal and double coercion
select * from values ("one", 2.0), ("two", 3.0D) as data(a, b);

-- error reporting: nondeterministic function rand
select * from values ("one", rand(5)), ("two", 3.0D) as data(a, b);

-- error reporting: different number of columns
select * from values ("one", 2.0), ("two") as data(a, b);

-- error reporting: types that are incompatible
select * from values ("one", array(0, 1)), ("two", struct(1, 2)) as data(a, b);

-- error reporting: number aliases different from number data values
select * from values ("one"), ("two") as data(a, b);

-- error reporting: unresolved expression
select * from values ("one", random_not_exist_func(1)), ("two", 2) as data(a, b);

-- error reporting: aggregate expression
select * from values ("one", count(1)), ("two", 2) as data(a, b);

-- string to timestamp
select * from values (timestamp('1991-12-06 00:00:00.0'), array(timestamp('1991-12-06 01:00:00.0'), timestamp('1991-12-06 12:00:00.0'))) as data(a, b);
-- List of configuration the test suite is run against:
--SET spark.sql.autoBroadcastJoinThreshold=10485760
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=false

create temporary view nt1 as select * from values
  ("one", 1),
  ("two", 2),
  ("three", 3)
  as nt1(k, v1);

create temporary view nt2 as select * from values
  ("one", 1),
  ("two", 22),
  ("one", 5)
  as nt2(k, v2);


SELECT * FROM nt1 natural join nt2 where k = "one";

SELECT * FROM nt1 natural left join nt2 order by v1, v2;

SELECT * FROM nt1 natural right join nt2 order by v1, v2;

SELECT count(*) FROM nt1 natural full outer join nt2;
-- binary type
select x'00' < x'0f';
select x'00' < x'ff';

-- limit on various data types
SELECT * FROM testdata LIMIT 2;
SELECT * FROM arraydata LIMIT 2;
SELECT * FROM mapdata LIMIT 2;

-- foldable non-literal in limit
SELECT * FROM testdata LIMIT 2 + 1;

SELECT * FROM testdata LIMIT CAST(1 AS int);

-- limit must be non-negative
SELECT * FROM testdata LIMIT -1;
SELECT * FROM testData TABLESAMPLE (-1 ROWS);


SELECT * FROM testdata LIMIT CAST(1 AS INT);
-- evaluated limit must not be null
SELECT * FROM testdata LIMIT CAST(NULL AS INT);

-- limit must be foldable
SELECT * FROM testdata LIMIT key > 3;

-- limit must be integer
SELECT * FROM testdata LIMIT true;
SELECT * FROM testdata LIMIT 'a';

-- limit within a subquery
SELECT * FROM (SELECT * FROM range(10) LIMIT 5) WHERE id > 3;

-- limit ALL
SELECT * FROM testdata WHERE key < 3 LIMIT ALL;
-- Test data.
CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES (1, 1), (1, 2), (2, 1) AS testData(a, b);

-- Table column aliases in FROM clause
SELECT * FROM testData AS t(col1, col2) WHERE col1 = 1;

SELECT * FROM testData AS t(col1, col2) WHERE col1 = 2;

SELECT col1 AS k, SUM(col2) FROM testData AS t(col1, col2) GROUP BY k;

-- Aliasing the wrong number of columns in the FROM clause
SELECT * FROM testData AS t(col1, col2, col3);

SELECT * FROM testData AS t(col1);

-- Check alias duplication
SELECT a AS col1, b AS col2 FROM testData AS t(c, d);

-- Subquery aliases in FROM clause
SELECT * FROM (SELECT 1 AS a, 1 AS b) t(col1, col2);

-- Aliases for join relations in FROM clause
CREATE OR REPLACE TEMPORARY VIEW src1 AS SELECT * FROM VALUES (1, "a"), (2, "b"), (3, "c") AS src1(id, v1);

CREATE OR REPLACE TEMPORARY VIEW src2 AS SELECT * FROM VALUES (2, 1.0), (3, 3.2), (1, 8.5) AS src2(id, v2);

SELECT * FROM (src1 s1 INNER JOIN src2 s2 ON s1.id = s2.id) dst(a, b, c, d);
CREATE TEMPORARY VIEW t AS select '2011-05-06 07:08:09.1234567' as c;

select extract(year from c) from t;

select extract(quarter from c) from t;

select extract(month from c) from t;

select extract(week from c) from t;

select extract(day from c) from t;

select extract(dayofweek from c) from t;

select extract(hour from c) from t;

select extract(minute from c) from t;

select extract(second from c) from t;

select extract(not_supported from c) from t;
CREATE DATABASE showdb;

USE showdb;

CREATE TABLE showcolumn1 (col1 int, `col 2` int) USING json;
CREATE TABLE showcolumn2 (price int, qty int, year int, month int) USING parquet partitioned by (year, month);
CREATE TEMPORARY VIEW showColumn3 (col3 int, `col 4` int) USING json;
CREATE GLOBAL TEMP VIEW showColumn4 AS SELECT 1 as col1, 'abc' as `col 5`;


-- only table name
SHOW COLUMNS IN showcolumn1;

-- qualified table name
SHOW COLUMNS IN showdb.showcolumn1;

-- table name and database name
SHOW COLUMNS IN showcolumn1 FROM showdb;

-- partitioned table
SHOW COLUMNS IN showcolumn2 IN showdb;

-- Non-existent table. Raise an error in this case
SHOW COLUMNS IN badtable FROM showdb;

-- database in table identifier and database name in different case
SHOW COLUMNS IN showdb.showcolumn1 from SHOWDB;

-- different database name in table identifier and database name.
-- Raise an error in this case.
SHOW COLUMNS IN showdb.showcolumn1 FROM baddb;

-- show column on temporary view
SHOW COLUMNS IN showcolumn3;

-- error temp view can't be qualified with a database
SHOW COLUMNS IN showdb.showcolumn3;

-- error temp view can't be qualified with a database
SHOW COLUMNS IN showcolumn3 FROM showdb;

-- error global temp view needs to be qualified
SHOW COLUMNS IN showcolumn4;

-- global temp view qualified with database
SHOW COLUMNS IN global_temp.showcolumn4;

-- global temp view qualified with database
SHOW COLUMNS IN showcolumn4 FROM global_temp;

DROP TABLE showcolumn1;
DROP TABLE showColumn2;
DROP VIEW  showcolumn3;
DROP VIEW  global_temp.showcolumn4;

use default;

DROP DATABASE showdb;
-- List of configuration the test suite is run against:
--SET spark.sql.autoBroadcastJoinThreshold=10485760
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=false

-- SPARK-17099: Incorrect result when HAVING clause is added to group by query
CREATE OR REPLACE TEMPORARY VIEW t1 AS SELECT * FROM VALUES
(-234), (145), (367), (975), (298)
as t1(int_col1);

CREATE OR REPLACE TEMPORARY VIEW t2 AS SELECT * FROM VALUES
(-769, -244), (-800, -409), (940, 86), (-507, 304), (-367, 158)
as t2(int_col0, int_col1);

SELECT
  (SUM(COALESCE(t1.int_col1, t2.int_col0))),
     ((COALESCE(t1.int_col1, t2.int_col0)) * 2)
FROM t1
RIGHT JOIN t2
  ON (t2.int_col0) = (t1.int_col1)
GROUP BY GREATEST(COALESCE(t2.int_col1, 109), COALESCE(t1.int_col1, -449)),
         COALESCE(t1.int_col1, t2.int_col0)
HAVING (SUM(COALESCE(t1.int_col1, t2.int_col0)))
            > ((COALESCE(t1.int_col1, t2.int_col0)) * 2);


-- SPARK-17120: Analyzer incorrectly optimizes plan to empty LocalRelation
CREATE OR REPLACE TEMPORARY VIEW t1 AS SELECT * FROM VALUES (97) as t1(int_col1);

CREATE OR REPLACE TEMPORARY VIEW t2 AS SELECT * FROM VALUES (0) as t2(int_col1);

-- Set the cross join enabled flag for the LEFT JOIN test since there's no join condition.
-- Ultimately the join should be optimized away.
set spark.sql.crossJoin.enabled = true;
SELECT *
FROM (
SELECT
    COALESCE(t2.int_col1, t1.int_col1) AS int_col
    FROM t1
    LEFT JOIN t2 ON false
) t where (t.int_col) is not null;
set spark.sql.crossJoin.enabled = false;


-- Cross join detection and error checking is done in JoinSuite since explain output is
-- used in the error message and the ids are not stable. Only positive cases are checked here.

create temporary view nt1 as select * from values
  ("one", 1),
  ("two", 2),
  ("three", 3)
  as nt1(k, v1);

create temporary view nt2 as select * from values
  ("one", 1),
  ("two", 22),
  ("one", 5)
  as nt2(k, v2);

-- Cross joins with and without predicates
SELECT * FROM nt1 cross join nt2;
SELECT * FROM nt1 cross join nt2 where nt1.k = nt2.k;
SELECT * FROM nt1 cross join nt2 on (nt1.k = nt2.k);
SELECT * FROM nt1 cross join nt2 where nt1.v1 = 1 and nt2.v2 = 22;

SELECT a.key, b.key FROM
(SELECT k key FROM nt1 WHERE v1 < 2) a
CROSS JOIN
(SELECT k key FROM nt2 WHERE v2 = 22) b;

-- Join reordering 
create temporary view A(a, va) as select * from nt1;
create temporary view B(b, vb) as select * from nt1;
create temporary view C(c, vc) as select * from nt1;
create temporary view D(d, vd) as select * from nt1;

-- Allowed since cross join with C is explicit
select * from ((A join B on (a = b)) cross join C) join D on (a = d);
-- Cross joins with non-equal predicates
SELECT * FROM nt1 CROSS JOIN nt2 ON (nt1.k > nt2.k);
-- order by and sort by ordinal positions

create temporary view data as select * from values
  (1, 1),
  (1, 2),
  (2, 1),
  (2, 2),
  (3, 1),
  (3, 2)
  as data(a, b);

select * from data order by 1 desc;

-- mix ordinal and column name
select * from data order by 1 desc, b desc;

-- order by multiple ordinals
select * from data order by 1 desc, 2 desc;

-- 1 + 0 is considered a constant (not an ordinal) and thus ignored
select * from data order by 1 + 0 desc, b desc;

-- negative cases: ordinal position out of range
select * from data order by 0;
select * from data order by -1;
select * from data order by 3;

-- sort by ordinal
select * from data sort by 1 desc;

-- turn off order by ordinal
set spark.sql.orderByOrdinal=false;

-- 0 is now a valid literal
select * from data order by 0;
select * from data sort by 0;
CREATE TABLE t (key STRING, value STRING, ds STRING, hr INT) USING parquet
    PARTITIONED BY (ds, hr);

INSERT INTO TABLE t PARTITION (ds='2017-08-01', hr=10)
VALUES ('k1', 100), ('k2', 200), ('k3', 300);

INSERT INTO TABLE t PARTITION (ds='2017-08-01', hr=11)
VALUES ('k1', 101), ('k2', 201), ('k3', 301), ('k4', 401);

INSERT INTO TABLE t PARTITION (ds='2017-09-01', hr=5)
VALUES ('k1', 102), ('k2', 202);

DESC EXTENDED t PARTITION (ds='2017-08-01', hr=10);

-- Collect stats for a single partition
ANALYZE TABLE t PARTITION (ds='2017-08-01', hr=10) COMPUTE STATISTICS;

DESC EXTENDED t PARTITION (ds='2017-08-01', hr=10);

-- Collect stats for 2 partitions
ANALYZE TABLE t PARTITION (ds='2017-08-01') COMPUTE STATISTICS;

DESC EXTENDED t PARTITION (ds='2017-08-01', hr=10);
DESC EXTENDED t PARTITION (ds='2017-08-01', hr=11);

-- Collect stats for all partitions
ANALYZE TABLE t PARTITION (ds, hr) COMPUTE STATISTICS;

DESC EXTENDED t PARTITION (ds='2017-08-01', hr=10);
DESC EXTENDED t PARTITION (ds='2017-08-01', hr=11);
DESC EXTENDED t PARTITION (ds='2017-09-01', hr=5);

-- DROP TEST TABLES/VIEWS
DROP TABLE t;
CREATE TEMPORARY VIEW tbl_x AS VALUES
  (1, NAMED_STRUCT('C', 'gamma', 'D', 'delta')),
  (2, NAMED_STRUCT('C', 'epsilon', 'D', 'eta')),
  (3, NAMED_STRUCT('C', 'theta', 'D', 'iota'))
  AS T(ID, ST);

-- Create a struct
SELECT STRUCT('alpha', 'beta') ST;

-- Create a struct with aliases
SELECT STRUCT('alpha' AS A, 'beta' AS B) ST;

-- Star expansion in a struct.
SELECT ID, STRUCT(ST.*) NST FROM tbl_x;

-- Append a column to a struct
SELECT ID, STRUCT(ST.*,CAST(ID AS STRING) AS E) NST FROM tbl_x;

-- Prepend a column to a struct
SELECT ID, STRUCT(CAST(ID AS STRING) AS AA, ST.*) NST FROM tbl_x;

-- Select a column from a struct
SELECT ID, STRUCT(ST.*).C NST FROM tbl_x;
SELECT ID, STRUCT(ST.C, ST.D).D NST FROM tbl_x;

-- Select an alias from a struct
SELECT ID, STRUCT(ST.C as STC, ST.D as STD).STD FROM tbl_x;CREATE TEMPORARY VIEW tab1 AS SELECT * FROM VALUES
    (1, 2), 
    (1, 2),
    (1, 3),
    (1, 3),
    (2, 3),
    (null, null),
    (null, null)
    AS tab1(k, v);
CREATE TEMPORARY VIEW tab2 AS SELECT * FROM VALUES
    (1, 2), 
    (1, 2), 
    (2, 3),
    (3, 4),
    (null, null),
    (null, null)
    AS tab2(k, v);

-- Basic INTERSECT ALL
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab2;

-- INTERSECT ALL same table in both branches
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab1 WHERE k = 1;

-- Empty left relation
SELECT * FROM tab1 WHERE k > 2
INTERSECT ALL
SELECT * FROM tab2;

-- Empty right relation
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab2 WHERE k > 3;

-- Type Coerced INTERSECT ALL
SELECT * FROM tab1
INTERSECT ALL
SELECT CAST(1 AS BIGINT), CAST(2 AS BIGINT);

-- Error as types of two side are not compatible
SELECT * FROM tab1
INTERSECT ALL
SELECT array(1), 2;

-- Mismatch on number of columns across both branches
SELECT k FROM tab1
INTERSECT ALL
SELECT k, v FROM tab2;

-- Basic
SELECT * FROM tab2
INTERSECT ALL
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab2;

-- Chain of different `set operations
SELECT * FROM tab1
EXCEPT
SELECT * FROM tab2
UNION ALL
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab2
;

-- Chain of different `set operations
SELECT * FROM tab1
EXCEPT
SELECT * FROM tab2
EXCEPT
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab2
;

-- test use parenthesis to control order of evaluation
(
  (
    (
      SELECT * FROM tab1
      EXCEPT
      SELECT * FROM tab2
    )
    EXCEPT
    SELECT * FROM tab1
  )
  INTERSECT ALL
  SELECT * FROM tab2
)
;

-- Join under intersect all
SELECT * 
FROM   (SELECT tab1.k, 
               tab2.v 
        FROM   tab1 
               JOIN tab2 
                 ON tab1.k = tab2.k)
INTERSECT ALL 
SELECT * 
FROM   (SELECT tab1.k, 
               tab2.v 
        FROM   tab1 
               JOIN tab2 
                 ON tab1.k = tab2.k);

-- Join under intersect all (2)
SELECT * 
FROM   (SELECT tab1.k, 
               tab2.v 
        FROM   tab1 
               JOIN tab2 
                 ON tab1.k = tab2.k) 
INTERSECT ALL 
SELECT * 
FROM   (SELECT tab2.v AS k, 
               tab1.k AS v 
        FROM   tab1 
               JOIN tab2 
                 ON tab1.k = tab2.k);

-- Group by under intersect all
SELECT v FROM tab1 GROUP BY v
INTERSECT ALL
SELECT k FROM tab2 GROUP BY k;

-- Test pre spark2.4 behaviour of set operation precedence
-- All the set operators are given equal precedence and are evaluated
-- from left to right as they appear in the query.

-- Set the property
SET spark.sql.legacy.setopsPrecedence.enabled= true;

SELECT * FROM tab1
EXCEPT
SELECT * FROM tab2
UNION ALL
SELECT * FROM tab1
INTERSECT ALL
SELECT * FROM tab2;

SELECT * FROM tab1
EXCEPT
SELECT * FROM tab2
UNION ALL
SELECT * FROM tab1
INTERSECT
SELECT * FROM tab2;

-- Restore the property
SET spark.sql.legacy.setopsPrecedence.enabled = false;

-- Clean-up 
DROP VIEW IF EXISTS tab1;
DROP VIEW IF EXISTS tab2;
-- List of configuration the test suite is run against:
--SET spark.sql.autoBroadcastJoinThreshold=10485760
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=false

CREATE TEMPORARY VIEW t1 AS SELECT * FROM VALUES (1) AS GROUPING(a);
CREATE TEMPORARY VIEW t2 AS SELECT * FROM VALUES (1) AS GROUPING(a);

CREATE TEMPORARY VIEW empty_table as SELECT a FROM t2 WHERE false;

SELECT * FROM t1 INNER JOIN empty_table;
SELECT * FROM t1 CROSS JOIN empty_table;
SELECT * FROM t1 LEFT OUTER JOIN empty_table;
SELECT * FROM t1 RIGHT OUTER JOIN empty_table;
SELECT * FROM t1 FULL OUTER JOIN empty_table;
SELECT * FROM t1 LEFT SEMI JOIN empty_table;
SELECT * FROM t1 LEFT ANTI JOIN empty_table;

SELECT * FROM empty_table INNER JOIN t1;
SELECT * FROM empty_table CROSS JOIN t1;
SELECT * FROM empty_table LEFT OUTER JOIN t1;
SELECT * FROM empty_table RIGHT OUTER JOIN t1;
SELECT * FROM empty_table FULL OUTER JOIN t1;
SELECT * FROM empty_table LEFT SEMI JOIN t1;
SELECT * FROM empty_table LEFT ANTI JOIN t1;

SELECT * FROM empty_table INNER JOIN empty_table;
SELECT * FROM empty_table CROSS JOIN empty_table;
SELECT * FROM empty_table LEFT OUTER JOIN empty_table;
SELECT * FROM empty_table RIGHT OUTER JOIN empty_table;
SELECT * FROM empty_table FULL OUTER JOIN empty_table;
SELECT * FROM empty_table LEFT SEMI JOIN empty_table;
SELECT * FROM empty_table LEFT ANTI JOIN empty_table;
create temporary view t as select * from values 0, 1, 2 as t(id);
create temporary view t2 as select * from values 0, 1 as t(id);

-- WITH clause should not fall into infinite loop by referencing self
WITH s AS (SELECT 1 FROM s) SELECT * FROM s;

-- WITH clause should reference the base table
WITH t AS (SELECT 1 FROM t) SELECT * FROM t;

-- WITH clause should not allow cross reference
WITH s1 AS (SELECT 1 FROM s2), s2 AS (SELECT 1 FROM s1) SELECT * FROM s1, s2;

-- WITH clause should reference the previous CTE
WITH t1 AS (SELECT * FROM t2), t2 AS (SELECT 2 FROM t1) SELECT * FROM t1 cross join t2;

-- SPARK-18609 CTE with self-join
WITH CTE1 AS (
  SELECT b.id AS id
  FROM   T2 a
         CROSS JOIN (SELECT id AS id FROM T2) b
)
SELECT t1.id AS c1,
       t2.id AS c2
FROM   CTE1 t1
       CROSS JOIN CTE1 t2;

-- Clean up
DROP VIEW IF EXISTS t;
DROP VIEW IF EXISTS t2;
-- Test temp table
CREATE TEMPORARY VIEW desc_col_temp_view (key int COMMENT 'column_comment') USING PARQUET;

DESC desc_col_temp_view key;

DESC EXTENDED desc_col_temp_view key;

DESC FORMATTED desc_col_temp_view key;

-- Describe a column with qualified name
DESC FORMATTED desc_col_temp_view desc_col_temp_view.key;

-- Describe a non-existent column
DESC desc_col_temp_view key1;

-- Test persistent table
CREATE TABLE desc_col_table (key int COMMENT 'column_comment') USING PARQUET;

ANALYZE TABLE desc_col_table COMPUTE STATISTICS FOR COLUMNS key;

DESC desc_col_table key;

DESC EXTENDED desc_col_table key;

DESC FORMATTED desc_col_table key;

-- Test complex columns
CREATE TABLE desc_complex_col_table (`a.b` int, col struct<x:int, y:string>) USING PARQUET;

DESC FORMATTED desc_complex_col_table `a.b`;

DESC FORMATTED desc_complex_col_table col;

-- Describe a nested column
DESC FORMATTED desc_complex_col_table col.x;

-- Test output for histogram statistics
SET spark.sql.statistics.histogram.enabled=true;
SET spark.sql.statistics.histogram.numBins=2;

INSERT INTO desc_col_table values 1, 2, 3, 4;

ANALYZE TABLE desc_col_table COMPUTE STATISTICS FOR COLUMNS key;

DESC EXTENDED desc_col_table key;

DROP VIEW desc_col_temp_view;

DROP TABLE desc_col_table;

DROP TABLE desc_complex_col_table;
-- Tests for qualified column names for the view code-path
-- Test scenario with Temporary view
CREATE OR REPLACE TEMPORARY VIEW view1 AS SELECT 2 AS i1;
SELECT view1.* FROM view1;
SELECT * FROM view1;
SELECT view1.i1 FROM view1;
SELECT i1 FROM view1;
SELECT a.i1 FROM view1 AS a;
SELECT i1 FROM view1 AS a;
-- cleanup
DROP VIEW view1;

-- Test scenario with Global Temp view
CREATE OR REPLACE GLOBAL TEMPORARY VIEW view1 as SELECT 1 as i1;
SELECT * FROM global_temp.view1;
SELECT global_temp.view1.* FROM global_temp.view1;
SELECT i1 FROM global_temp.view1;
SELECT global_temp.view1.i1 FROM global_temp.view1;
SELECT view1.i1 FROM global_temp.view1;
SELECT a.i1 FROM global_temp.view1 AS a;
SELECT i1 FROM global_temp.view1 AS a;
-- cleanup
DROP VIEW global_temp.view1;
-- cast string representing a valid fractional number to integral should truncate the number
SELECT CAST('1.23' AS int);
SELECT CAST('1.23' AS long);
SELECT CAST('-4.56' AS int);
SELECT CAST('-4.56' AS long);

-- cast string which are not numbers to integral should return null
SELECT CAST('abc' AS int);
SELECT CAST('abc' AS long);

-- cast string representing a very large number to integral should return null
SELECT CAST('1234567890123' AS int);
SELECT CAST('12345678901234567890123' AS long);

-- cast empty string to integral should return null
SELECT CAST('' AS int);
SELECT CAST('' AS long);

-- cast null to integral should return null
SELECT CAST(NULL AS int);
SELECT CAST(NULL AS long);

-- cast invalid decimal string to integral should return null
SELECT CAST('123.a' AS int);
SELECT CAST('123.a' AS long);

-- '-2147483648' is the smallest int value
SELECT CAST('-2147483648' AS int);
SELECT CAST('-2147483649' AS int);

-- '2147483647' is the largest int value
SELECT CAST('2147483647' AS int);
SELECT CAST('2147483648' AS int);

-- '-9223372036854775808' is the smallest long value
SELECT CAST('-9223372036854775808' AS long);
SELECT CAST('-9223372036854775809' AS long);

-- '9223372036854775807' is the largest long value
SELECT CAST('9223372036854775807' AS long);
SELECT CAST('9223372036854775808' AS long);

-- cast string to its binary representation
SELECT HEX(CAST('abc' AS binary));

-- cast integral values to their corresponding binary representation
SELECT HEX(CAST(CAST(123 AS byte) AS binary));
SELECT HEX(CAST(CAST(-123 AS byte) AS binary));
SELECT HEX(CAST(123S AS binary));
SELECT HEX(CAST(-123S AS binary));
SELECT HEX(CAST(123 AS binary));
SELECT HEX(CAST(-123 AS binary));
SELECT HEX(CAST(123L AS binary));
SELECT HEX(CAST(-123L AS binary));

DESC FUNCTION boolean;
DESC FUNCTION EXTENDED boolean;
-- TODO: migrate all cast tests here.
-- Turns on ANSI mode
SET spark.sql.parser.ansi.enabled=true;

select
  '1' second,
  2  seconds,
  '1' minute,
  2  minutes,
  '1' hour,
  2  hours,
  '1' day,
  2  days,
  '1' month,
  2  months,
  '1' year,
  2  years;

select
  interval '10-11' year to month,
  interval '10' year,
  interval '11' month;

select
  '10-11' year to month,
  '10' year,
  '11' month;

select
  interval '10 9:8:7.987654321' day to second,
  interval '10' day,
  interval '11' hour,
  interval '12' minute,
  interval '13' second,
  interval '13.123456789' second;

select
  '10 9:8:7.987654321' day to second,
  '10' day,
  '11' hour,
  '12' minute,
  '13' second,
  '13.123456789' second;

select map(1, interval 1 day, 2, interval 3 week);

select map(1, 1 day, 2, 3 week);

-- Interval year-month arithmetic

create temporary view interval_arithmetic as
  select CAST(dateval AS date), CAST(tsval AS timestamp) from values
    ('2012-01-01', '2012-01-01')
    as interval_arithmetic(dateval, tsval);

select
  dateval,
  dateval - interval '2-2' year to month,
  dateval - interval '-2-2' year to month,
  dateval + interval '2-2' year to month,
  dateval + interval '-2-2' year to month,
  - interval '2-2' year to month + dateval,
  interval '2-2' year to month + dateval
from interval_arithmetic;

select
  dateval,
  dateval - '2-2' year to month,
  dateval - '-2-2' year to month,
  dateval + '2-2' year to month,
  dateval + '-2-2' year to month,
  - '2-2' year to month + dateval,
  '2-2' year to month + dateval
from interval_arithmetic;

select
  tsval,
  tsval - interval '2-2' year to month,
  tsval - interval '-2-2' year to month,
  tsval + interval '2-2' year to month,
  tsval + interval '-2-2' year to month,
  - interval '2-2' year to month + tsval,
  interval '2-2' year to month + tsval
from interval_arithmetic;

select
  tsval,
  tsval - '2-2' year to month,
  tsval - '-2-2' year to month,
  tsval + '2-2' year to month,
  tsval + '-2-2' year to month,
  - '2-2' year to month + tsval,
  '2-2' year to month + tsval
from interval_arithmetic;

select
  interval '2-2' year to month + interval '3-3' year to month,
  interval '2-2' year to month - interval '3-3' year to month
from interval_arithmetic;

select
  '2-2' year to month + '3-3' year to month,
  '2-2' year to month - '3-3' year to month
from interval_arithmetic;

-- Interval day-time arithmetic

select
  dateval,
  dateval - interval '99 11:22:33.123456789' day to second,
  dateval - interval '-99 11:22:33.123456789' day to second,
  dateval + interval '99 11:22:33.123456789' day to second,
  dateval + interval '-99 11:22:33.123456789' day to second,
  -interval '99 11:22:33.123456789' day to second + dateval,
  interval '99 11:22:33.123456789' day to second + dateval
from interval_arithmetic;

select
  dateval,
  dateval - '99 11:22:33.123456789' day to second,
  dateval - '-99 11:22:33.123456789' day to second,
  dateval + '99 11:22:33.123456789' day to second,
  dateval + '-99 11:22:33.123456789' day to second,
  - '99 11:22:33.123456789' day to second + dateval,
  '99 11:22:33.123456789' day to second + dateval
from interval_arithmetic;

select
  tsval,
  tsval - interval '99 11:22:33.123456789' day to second,
  tsval - interval '-99 11:22:33.123456789' day to second,
  tsval + interval '99 11:22:33.123456789' day to second,
  tsval + interval '-99 11:22:33.123456789' day to second,
  -interval '99 11:22:33.123456789' day to second + tsval,
  interval '99 11:22:33.123456789' day to second + tsval
from interval_arithmetic;

select
  tsval,
  tsval - '99 11:22:33.123456789' day to second,
  tsval - '-99 11:22:33.123456789' day to second,
  tsval + '99 11:22:33.123456789' day to second,
  tsval + '-99 11:22:33.123456789' day to second,
  - '99 11:22:33.123456789' day to second + tsval,
  '99 11:22:33.123456789' day to second + tsval
from interval_arithmetic;

select
  interval '99 11:22:33.123456789' day to second + interval '10 9:8:7.123456789' day to second,
  interval '99 11:22:33.123456789' day to second - interval '10 9:8:7.123456789' day to second
from interval_arithmetic;

select
  '99 11:22:33.123456789' day to second + '10 9:8:7.123456789' day to second,
  '99 11:22:33.123456789' day to second - '10 9:8:7.123456789' day to second
from interval_arithmetic;

-- More tests for interval syntax alternatives

select 30 day;

select 30 day day;

select 30 day day day;

select date '2012-01-01' - 30 day;

select date '2012-01-01' - 30 day day;

select date '2012-01-01' - 30 day day day;

select date '2012-01-01' + '-30' day;

select date '2012-01-01' + interval '-30' day;

-- Unsupported syntax for intervals

select date '2012-01-01' + interval (-30) day;

select date '2012-01-01' + (-30) day;

create temporary view t as select * from values (1), (2) as t(a);

select date '2012-01-01' + interval (a + 1) day from t;

select date '2012-01-01' + (a + 1) day from t;

-- Turns off ANSI mode
SET spark.sql.parser.ansi.enabled=false;
-- Q1. testing window functions with order by
create table spark_10747(col1 int, col2 int, col3 int) using parquet;

-- Q2. insert to tables
INSERT INTO spark_10747 VALUES (6, 12, 10), (6, 11, 4), (6, 9, 10), (6, 15, 8),
(6, 15, 8), (6, 7, 4), (6, 7, 8), (6, 13, null), (6, 10, null);

-- Q3. windowing with order by DESC NULLS LAST
select col1, col2, col3, sum(col2)
    over (partition by col1
       order by col3 desc nulls last, col2
       rows between 2 preceding and 2 following ) as sum_col2
from spark_10747 where col1 = 6 order by sum_col2;

-- Q4. windowing with order by DESC NULLS FIRST
select col1, col2, col3, sum(col2)
    over (partition by col1
       order by col3 desc nulls first, col2
       rows between 2 preceding and 2 following ) as sum_col2
from spark_10747 where col1 = 6 order by sum_col2;

-- Q5. windowing with order by ASC NULLS LAST
select col1, col2, col3, sum(col2)
    over (partition by col1
       order by col3 asc nulls last, col2
       rows between 2 preceding and 2 following ) as sum_col2
from spark_10747 where col1 = 6 order by sum_col2;

-- Q6. windowing with order by ASC NULLS FIRST
select col1, col2, col3, sum(col2)
    over (partition by col1
       order by col3 asc nulls first, col2
       rows between 2 preceding and 2 following ) as sum_col2
from spark_10747 where col1 = 6 order by sum_col2;

-- Q7. Regular query with ORDER BY ASC NULLS FIRST
SELECT COL1, COL2, COL3 FROM spark_10747 ORDER BY COL3 ASC NULLS FIRST, COL2;

-- Q8. Regular query with ORDER BY ASC NULLS LAST
SELECT COL1, COL2, COL3 FROM spark_10747 ORDER BY COL3 NULLS LAST, COL2;

-- Q9. Regular query with ORDER BY DESC NULLS FIRST
SELECT COL1, COL2, COL3 FROM spark_10747 ORDER BY COL3 DESC NULLS FIRST, COL2;

-- Q10. Regular query with ORDER BY DESC NULLS LAST
SELECT COL1, COL2, COL3 FROM spark_10747 ORDER BY COL3 DESC NULLS LAST, COL2;

-- drop the test table
drop table spark_10747;

-- Q11. mix datatype for ORDER BY NULLS FIRST|LAST
create table spark_10747_mix(
col1 string,
col2 int,
col3 double,
col4 decimal(10,2),
col5 decimal(20,1))
using parquet;

-- Q12. Insert to the table
INSERT INTO spark_10747_mix VALUES
('b', 2, 1.0, 1.00, 10.0),
('d', 3, 2.0, 3.00, 0.0),
('c', 3, 2.0, 2.00, 15.1),
('d', 3, 0.0, 3.00, 1.0),
(null, 3, 0.0, 3.00, 1.0),
('d', 3, null, 4.00, 1.0),
('a', 1, 1.0, 1.00, null),
('c', 3, 2.0, 2.00, null);

-- Q13. Regular query with 2 NULLS LAST columns
select * from spark_10747_mix order by col1 nulls last, col5 nulls last;

-- Q14. Regular query with 2 NULLS FIRST columns
select * from spark_10747_mix order by col1 desc nulls first, col5 desc nulls first;

-- Q15. Regular query with mixed NULLS FIRST|LAST
select * from spark_10747_mix order by col5 desc nulls first, col3 desc nulls last;

-- drop the test table
drop table spark_10747_mix;


CREATE OR REPLACE TEMPORARY VIEW t1 AS SELECT * FROM VALUES
(1), (2), (3), (4)
as t1(int_col1);

CREATE FUNCTION myDoubleAvg AS 'test.org.apache.spark.sql.MyDoubleAvg';

SELECT default.myDoubleAvg(int_col1) as my_avg from t1;

SELECT default.myDoubleAvg(int_col1, 3) as my_avg from t1;

CREATE FUNCTION udaf1 AS 'test.non.existent.udaf';

SELECT default.udaf1(int_col1) as udaf1 from t1;

DROP FUNCTION myDoubleAvg;
DROP FUNCTION udaf1;
-- A test suite for functions added for compatibility with other databases such as Oracle, MSSQL.
-- These functions are typically implemented using the trait RuntimeReplaceable.

SELECT ifnull(null, 'x'), ifnull('y', 'x'), ifnull(null, null);
SELECT nullif('x', 'x'), nullif('x', 'y');
SELECT nvl(null, 'x'), nvl('y', 'x'), nvl(null, null);
SELECT nvl2(null, 'x', 'y'), nvl2('n', 'x', 'y'), nvl2(null, null, null);

-- type coercion
SELECT ifnull(1, 2.1d), ifnull(null, 2.1d);
SELECT nullif(1, 2.1d), nullif(1, 1.0d);
SELECT nvl(1, 2.1d), nvl(null, 2.1d);
SELECT nvl2(null, 1, 2.1d), nvl2('n', 1, 2.1d);

-- SPARK-16730 cast alias functions for Hive compatibility
SELECT boolean(1), tinyint(1), smallint(1), int(1), bigint(1);
SELECT float(1), double(1), decimal(1);
SELECT date("2014-04-04"), timestamp(date("2014-04-04"));
-- error handling: only one argument
SELECT string(1, 2);

-- SPARK-21555: RuntimeReplaceable used in group by
CREATE TEMPORARY VIEW tempView1 AS VALUES (1, NAMED_STRUCT('col1', 'gamma', 'col2', 'delta')) AS T(id, st);
SELECT nvl(st.col1, "value"), count(*) FROM from tempView1 GROUP BY nvl(st.col1, "value");
-- to_json
select to_json(named_struct('a', 1, 'b', 2));
select to_json(named_struct('time', to_timestamp('2015-08-26', 'yyyy-MM-dd')), map('timestampFormat', 'dd/MM/yyyy'));
select to_json(array(named_struct('a', 1, 'b', 2)));
select to_json(map(named_struct('a', 1, 'b', 2), named_struct('a', 1, 'b', 2)));
select to_json(map('a', named_struct('a', 1, 'b', 2)));
select to_json(map('a', 1));
select to_json(array(map('a',1)));
select to_json(array(map('a',1), map('b',2)));
-- Check if errors handled
select to_json(named_struct('a', 1, 'b', 2), named_struct('mode', 'PERMISSIVE'));
select to_json(named_struct('a', 1, 'b', 2), map('mode', 1));
select to_json();

-- from_json
select from_json('{"a":1}', 'a INT');
select from_json('{"time":"26/08/2015"}', 'time Timestamp', map('timestampFormat', 'dd/MM/yyyy'));
-- Check if errors handled
select from_json('{"a":1}', 1);
select from_json('{"a":1}', 'a InvalidType');
select from_json('{"a":1}', 'a INT', named_struct('mode', 'PERMISSIVE'));
select from_json('{"a":1}', 'a INT', map('mode', 1));
select from_json();
-- json_tuple
SELECT json_tuple('{"a" : 1, "b" : 2}', CAST(NULL AS STRING), 'b', CAST(NULL AS STRING), 'a');
CREATE TEMPORARY VIEW jsonTable(jsonField, a) AS SELECT * FROM VALUES ('{"a": 1, "b": 2}', 'a');
SELECT json_tuple(jsonField, 'b', CAST(NULL AS STRING), a) FROM jsonTable;
-- Clean up
DROP VIEW IF EXISTS jsonTable;

-- from_json - complex types
select from_json('{"a":1, "b":2}', 'map<string, int>');
select from_json('{"a":1, "b":"2"}', 'struct<a:int,b:string>');

-- infer schema of json literal
select schema_of_json('{"c1":0, "c2":[1]}');
select from_json('{"c1":[1, 2, 3]}', schema_of_json('{"c1":[0]}'));

-- from_json - array type
select from_json('[1, 2, 3]', 'array<int>');
select from_json('[1, "2", 3]', 'array<int>');
select from_json('[1, 2, null]', 'array<int>');

select from_json('[{"a": 1}, {"a":2}]', 'array<struct<a:int>>');
select from_json('{"a": 1}', 'array<struct<a:int>>');
select from_json('[null, {"a":2}]', 'array<struct<a:int>>');

select from_json('[{"a": 1}, {"b":2}]', 'array<map<string,int>>');
select from_json('[{"a": 1}, 2]', 'array<map<string,int>>');

-- to_json - array type
select to_json(array('1', '2', '3'));
select to_json(array(array(1, 2, 3), array(4)));

-- infer schema of json literal using options
select schema_of_json('{"c1":1}', map('primitivesAsString', 'true'));
select schema_of_json('{"c1":01, "c2":0.1}', map('allowNumericLeadingZeros', 'true', 'prefersDecimal', 'true'));
select schema_of_json(null);
CREATE TEMPORARY VIEW jsonTable(jsonField, a) AS SELECT * FROM VALUES ('{"a": 1, "b": 2}', 'a');
SELECT schema_of_json(jsonField) FROM jsonTable;
-- Clean up
DROP VIEW IF EXISTS jsonTable;
-- Test tables
CREATE table  desc_temp1 (key int COMMENT 'column_comment', val string) USING PARQUET;
CREATE table  desc_temp2 (key int, val string) USING PARQUET;

-- Simple Describe query
DESC SELECT key, key + 1 as plusone FROM desc_temp1;
DESC QUERY SELECT * FROM desc_temp2;
DESC SELECT key, COUNT(*) as count FROM desc_temp1 group by key;
DESC SELECT 10.00D as col1;
DESC QUERY SELECT key FROM desc_temp1 UNION ALL select CAST(1 AS DOUBLE);
DESC QUERY VALUES(1.00D, 'hello') as tab1(col1, col2);
DESC QUERY FROM desc_temp1 a SELECT *;
DESC WITH s AS (SELECT 'hello' as col1) SELECT * FROM s;
DESCRIBE QUERY WITH s AS (SELECT * from desc_temp1) SELECT * FROM s;
DESCRIBE SELECT * FROM (FROM desc_temp2 select * select *);

-- Error cases.
DESCRIBE INSERT INTO desc_temp1 values (1, 'val1');
DESCRIBE INSERT INTO desc_temp1 SELECT * FROM desc_temp2;
DESCRIBE
   FROM desc_temp1 a
     insert into desc_temp1 select *
     insert into desc_temp2 select *;

-- Explain
EXPLAIN DESC QUERY SELECT * FROM desc_temp2 WHERE key > 0;
EXPLAIN EXTENDED DESC WITH s AS (SELECT 'hello' as col1) SELECT * FROM s;

-- cleanup
DROP TABLE desc_temp1;
DROP TABLE desc_temp2;
set spark.sql.parser.quotedRegexColumnNames=false;

CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES
(1, "1", "11"), (2, "2", "22"), (3, "3", "33"), (4, "4", "44"), (5, "5", "55"), (6, "6", "66")
AS testData(key, value1, value2);

CREATE OR REPLACE TEMPORARY VIEW testData2 AS SELECT * FROM VALUES
(1, 1, 1, 2), (1, 2, 1, 2), (2, 1, 2, 3), (2, 2, 2, 3), (3, 1, 3, 4), (3, 2, 3, 4)
AS testData2(A, B, c, d);

-- AnalysisException
SELECT `(a)?+.+` FROM testData2 WHERE a = 1;
SELECT t.`(a)?+.+` FROM testData2 t WHERE a = 1;
SELECT `(a|b)` FROM testData2 WHERE a = 2;
SELECT `(a|b)?+.+` FROM testData2 WHERE a = 2;
SELECT SUM(`(a|b)?+.+`) FROM testData2;
SELECT SUM(`(a)`) FROM testData2;

set spark.sql.parser.quotedRegexColumnNames=true;

-- Regex columns
SELECT `(a)?+.+` FROM testData2 WHERE a = 1;
SELECT `(A)?+.+` FROM testData2 WHERE a = 1;
SELECT t.`(a)?+.+` FROM testData2 t WHERE a = 1;
SELECT t.`(A)?+.+` FROM testData2 t WHERE a = 1;
SELECT `(a|B)` FROM testData2 WHERE a = 2;
SELECT `(A|b)` FROM testData2 WHERE a = 2;
SELECT `(a|B)?+.+` FROM testData2 WHERE a = 2;
SELECT `(A|b)?+.+` FROM testData2 WHERE a = 2;
SELECT `(e|f)` FROM testData2;
SELECT t.`(e|f)` FROM testData2 t;
SELECT p.`(KEY)?+.+`, b, testdata2.`(b)?+.+` FROM testData p join testData2 ON p.key = testData2.a WHERE key < 3;
SELECT p.`(key)?+.+`, b, testdata2.`(b)?+.+` FROM testData p join testData2 ON p.key = testData2.a WHERE key < 3;

set spark.sql.caseSensitive=true;

CREATE OR REPLACE TEMPORARY VIEW testdata3 AS SELECT * FROM VALUES
(0, 1), (1, 2), (2, 3), (3, 4)
AS testdata3(a, b);

-- Regex columns
SELECT `(A)?+.+` FROM testdata3;
SELECT `(a)?+.+` FROM testdata3;
SELECT `(A)?+.+` FROM testdata3 WHERE a > 1;
SELECT `(a)?+.+` FROM testdata3 where `a` > 1;
SELECT SUM(`a`) FROM testdata3;
SELECT SUM(`(a)`) FROM testdata3;
SELECT SUM(`(a)?+.+`) FROM testdata3;
SELECT SUM(a) FROM testdata3 GROUP BY `a`;
-- AnalysisException
SELECT SUM(a) FROM testdata3 GROUP BY `(a)`;
SELECT SUM(a) FROM testdata3 GROUP BY `(a)?+.+`;
-- Test data.
CREATE DATABASE showdb;
USE showdb;
CREATE TABLE show_t1(a String, b Int, c String, d String) USING parquet PARTITIONED BY (c, d);
ALTER TABLE show_t1 ADD PARTITION (c='Us', d=1);
CREATE TABLE show_t2(b String, d Int) USING parquet;
CREATE TEMPORARY VIEW show_t3(e int) USING parquet;
CREATE GLOBAL TEMP VIEW show_t4 AS SELECT 1 as col1;

-- SHOW TABLES
SHOW TABLES;
SHOW TABLES IN showdb;

-- SHOW TABLES WITH wildcard match
SHOW TABLES 'show_t*';
SHOW TABLES LIKE 'show_t1*|show_t2*';
SHOW TABLES IN showdb 'show_t*';

-- SHOW TABLE EXTENDED
SHOW TABLE EXTENDED LIKE 'show_t*';
SHOW TABLE EXTENDED;

-- SHOW TABLE EXTENDED ... PARTITION
SHOW TABLE EXTENDED LIKE 'show_t1' PARTITION(c='Us', d=1);
-- Throw a ParseException if table name is not specified.
SHOW TABLE EXTENDED PARTITION(c='Us', d=1);
-- Don't support regular expression for table name if a partition specification is present.
SHOW TABLE EXTENDED LIKE 'show_t*' PARTITION(c='Us', d=1);
-- Partition specification is not complete.
SHOW TABLE EXTENDED LIKE 'show_t1' PARTITION(c='Us');
-- Partition specification is invalid.
SHOW TABLE EXTENDED LIKE 'show_t1' PARTITION(a='Us', d=1);
-- Partition specification doesn't exist.
SHOW TABLE EXTENDED LIKE 'show_t1' PARTITION(c='Ch', d=1);

-- Clean Up
DROP TABLE show_t1;
DROP TABLE show_t2;
DROP VIEW  show_t3;
DROP VIEW  global_temp.show_t4;
USE default;
DROP DATABASE showdb;
-- The test file contains negative test cases
-- of invalid queries where error messages are expected.

CREATE TEMPORARY VIEW t1 AS SELECT * FROM VALUES
  (1, 2, 3)
AS t1(t1a, t1b, t1c);

CREATE TEMPORARY VIEW t2 AS SELECT * FROM VALUES
  (1, 0, 1)
AS t2(t2a, t2b, t2c);

CREATE TEMPORARY VIEW t3 AS SELECT * FROM VALUES
  (3, 1, 2)
AS t3(t3a, t3b, t3c);

-- TC 01.01
-- The column t2b in the SELECT of the subquery is invalid
-- because it is neither an aggregate function nor a GROUP BY column.
SELECT t1a, t2b
FROM   t1, t2
WHERE  t1b = t2c
AND    t2b = (SELECT max(avg)
              FROM   (SELECT   t2b, avg(t2b) avg
                      FROM     t2
                      WHERE    t2a = t1.t1b
                     )
             )
;

-- TC 01.02
-- Invalid due to the column t2b not part of the output from table t2.
SELECT *
FROM   t1
WHERE  t1a IN (SELECT   min(t2a)
               FROM     t2
               GROUP BY t2c
               HAVING   t2c IN (SELECT   max(t3c)
                                FROM     t3
                                GROUP BY t3b
                                HAVING   t3b > t2b ))
;

-- TC 01.03
-- Invalid due to mixure of outer and local references under an AggegatedExpression 
-- in a correlated predicate
SELECT t1a 
FROM   t1
GROUP  BY 1
HAVING EXISTS (SELECT t2a
               FROM  t2
               GROUP BY 1
               HAVING t2a < min(t1a + t2a));

-- TC 01.04
-- Invalid due to mixure of outer and local references under an AggegatedExpression 
SELECT t1a 
FROM   t1
WHERE  t1a IN (SELECT t2a 
               FROM   t2
               WHERE  EXISTS (SELECT 1 
                              FROM   t3
                              GROUP BY 1
                              HAVING min(t2a + t3a) > 1));

-- TC 01.05
-- Invalid due to outer reference appearing in projection list
SELECT t1a 
FROM   t1
WHERE  t1a IN (SELECT t2a 
               FROM   t2
               WHERE  EXISTS (SELECT min(t2a) 
                              FROM   t3));

-- The test file contains negative test cases
-- of invalid queries where error messages are expected.

CREATE TEMPORARY VIEW t1 AS SELECT * FROM VALUES
  (1, 2, 3)
AS t1(t1a, t1b, t1c);

CREATE TEMPORARY VIEW t2 AS SELECT * FROM VALUES
  (1, 0, 1)
AS t2(t2a, t2b, t2c);

CREATE TEMPORARY VIEW t3 AS SELECT * FROM VALUES
  (3, 1, 2)
AS t3(t3a, t3b, t3c);

CREATE TEMPORARY VIEW t4 AS SELECT * FROM VALUES
  (CAST(1 AS DOUBLE), CAST(2 AS STRING), CAST(3 AS STRING))
AS t1(t4a, t4b, t4c);

CREATE TEMPORARY VIEW t5 AS SELECT * FROM VALUES
  (CAST(1 AS DECIMAL(18, 0)), CAST(2 AS STRING), CAST(3 AS BIGINT))
AS t1(t5a, t5b, t5c);

-- TC 01.01
SELECT 
  ( SELECT max(t2b), min(t2b) 
    FROM t2 
    WHERE t2.t2b = t1.t1b
    GROUP BY t2.t2b
  )
FROM t1;

-- TC 01.01
SELECT 
  ( SELECT max(t2b), min(t2b) 
    FROM t2 
    WHERE t2.t2b > 0
    GROUP BY t2.t2b
  )
FROM t1;

-- TC 01.03
SELECT * FROM t1
WHERE
t1a IN (SELECT t2a, t2b 
        FROM t2
        WHERE t1a = t2a);

-- TC 01.04
SELECT * FROM T1 
WHERE
(t1a, t1b) IN (SELECT t2a
               FROM t2
               WHERE t1a = t2a);
-- TC 01.05
SELECT * FROM t4
WHERE
(t4a, t4b, t4c) IN (SELECT t5a,
                           t5b,
                           t5c
                    FROM t5);
-- Unit tests for simple NOT IN predicate subquery across multiple columns.
--
-- See not-in-single-column-unit-tests.sql for an introduction.
--
-- Test cases for multi-column ``WHERE a NOT IN (SELECT c FROM r ...)'':
-- | # | does subquery include null?     | do filter columns contain null? | a = c? | b = d? | row included in result? |
-- | 1 | empty                           | *                               | *      | *      | yes                     |
-- | 2 | 1+ row has null for all columns | *                               | *      | *      | no                      |
-- | 3 | no row has null for all columns | (yes, yes)                      | *      | *      | no                      |
-- | 4 | no row has null for all columns | (no, yes)                       | yes    | *      | no                      |
-- | 5 | no row has null for all columns | (no, yes)                       | no     | *      | yes                     |
-- | 6 | no                              | (no, no)                        | yes    | yes    | no                      |
-- | 7 | no                              | (no, no)                        | _      | _      | yes                     |
--
-- This can be generalized to include more tests for more columns, but it covers the main cases
-- when there is more than one column.

CREATE TEMPORARY VIEW m AS SELECT * FROM VALUES
  (null, null),
  (null, 1.0),
  (2, 3.0),
  (4, 5.0)
  AS m(a, b);

CREATE TEMPORARY VIEW s AS SELECT * FROM VALUES
  (null, null),
  (0, 1.0),
  (2, 3.0),
  (4, null)
  AS s(c, d);

  -- Case 1
  -- (subquery is empty -> row is returned)
SELECT *
FROM   m
WHERE  (a, b) NOT IN (SELECT *
                      FROM   s
                      WHERE  d > 5.0) -- Matches no rows
;

  -- Case 2
  -- (subquery contains a row with null in all columns -> row not returned)
SELECT *
FROM   m
WHERE  (a, b) NOT IN (SELECT *
                      FROM s
                      WHERE c IS NULL AND d IS NULL) -- Matches only (null, null)
;

  -- Case 3
  -- (probe-side columns are all null -> row not returned)
SELECT *
FROM   m
WHERE  a IS NULL AND b IS NULL -- Matches only (null, null)
       AND (a, b) NOT IN (SELECT *
                          FROM s
                          WHERE c IS NOT NULL) -- Matches (0, 1.0), (2, 3.0), (4, null)
;

  -- Case 4
  -- (one column null, other column matches a row in the subquery result -> row not returned)
SELECT *
FROM   m
WHERE  b = 1.0 -- Matches (null, 1.0)
       AND (a, b) NOT IN (SELECT *
                          FROM s
                          WHERE c IS NOT NULL) -- Matches (0, 1.0), (2, 3.0), (4, null)
;

  -- Case 5
  -- (one null column with no match -> row is returned)
SELECT *
FROM   m
WHERE  b = 1.0 -- Matches (null, 1.0)
       AND (a, b) NOT IN (SELECT *
                          FROM s
                          WHERE c = 2) -- Matches (2, 3.0)
;

  -- Case 6
  -- (no null columns with match -> row not returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Matches (2, 3.0)
       AND (a, b) NOT IN (SELECT *
                          FROM s
                          WHERE c = 2) -- Matches (2, 3.0)
;

  -- Case 7
  -- (no null columns with no match -> row is returned)
SELECT *
FROM   m
WHERE  b = 5.0 -- Matches (4, 5.0)
       AND (a, b) NOT IN (SELECT *
                          FROM s
                          WHERE c = 2) -- Matches (2, 3.0)
;
-- A test suite for multiple columns in predicate in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- TC 01.01
SELECT t1a,
       t1b,
       t1h
FROM   t1
WHERE  ( t1a, t1h ) NOT IN (SELECT t2a,
                                   t2h
                            FROM   t2
                            WHERE  t2a = t1a
                            ORDER  BY t2a)
AND t1a = 'val1a';

-- TC 01.02
SELECT t1a,
       t1b,
       t1d
FROM   t1
WHERE  ( t1b, t1d ) IN (SELECT t2b,
                               t2d
                        FROM   t2
                        WHERE  t2i IN (SELECT t3i
                                       FROM   t3
                                       WHERE  t2b > t3b));

-- TC 01.03
SELECT t1a,
       t1b,
       t1d
FROM   t1
WHERE  ( t1b, t1d ) NOT IN (SELECT t2b,
                                   t2d
                            FROM   t2
                            WHERE  t2h IN (SELECT t3h
                                           FROM   t3
                                           WHERE  t2b > t3b))
AND t1a = 'val1a';

-- TC 01.04
SELECT t2a
FROM   (SELECT t2a
        FROM   t2
        WHERE  ( t2a, t2b ) IN (SELECT t1a,
                                       t1b
                                FROM   t1)
        UNION ALL
        SELECT t2a
        FROM   t2
        WHERE  ( t2a, t2b ) IN (SELECT t1a,
                                       t1b
                                FROM   t1)
        UNION DISTINCT
        SELECT t2a
        FROM   t2
        WHERE  ( t2a, t2b ) IN (SELECT t3a,
                                       t3b
                                FROM   t3)) AS t4;

-- TC 01.05
WITH cte1 AS
(
       SELECT t1a,
              t1b
       FROM   t1
       WHERE  (
                     t1b, t1d) IN
              (
                     SELECT t2b,
                            t2d
                     FROM   t2
                     WHERE  t1c = t2c))
SELECT *
FROM            (
                           SELECT     *
                           FROM       cte1
                           JOIN       cte1 cte2
                           on         cte1.t1b = cte2.t1b) s;

-- A test suite for NOT IN GROUP BY in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);


-- correlated IN subquery
-- GROUP BY in parent side
-- TC 01.01
SELECT t1a,
       Avg(t1b)
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2)
GROUP  BY t1a;

-- TC 01.02
SELECT t1a,
       Sum(DISTINCT( t1b ))
FROM   t1
WHERE  t1d NOT IN (SELECT t2d
                   FROM   t2
                   WHERE  t1h < t2h)
GROUP  BY t1a;

-- TC 01.03
SELECT Count(*)
FROM   (SELECT *
        FROM   t2
        WHERE  t2a NOT IN (SELECT t3a
                           FROM   t3
                           WHERE  t3h != t2h)) t2
WHERE  t2b NOT IN (SELECT Min(t2b)
                   FROM   t2
                   WHERE  t2b = t2b
                   GROUP  BY t2c);

-- TC 01.04
SELECT t1a,
       max(t1b)
FROM   t1
WHERE  t1c NOT IN (SELECT Max(t2b)
                   FROM   t2
                   WHERE  t1a = t2a
                   GROUP  BY t2a)
GROUP BY t1a;

-- TC 01.05
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2b
               FROM   t2
               WHERE  t2a NOT IN (SELECT Min(t3a)
                                  FROM   t3
                                  WHERE  t3a = t2a
                                  GROUP  BY t3b) order by t2a);
-- A test suite for not-in-joins in parent side, subquery, and both predicate subquery
-- It includes correlated cases.
-- List of configuration the test suite is run against:
--SET spark.sql.autoBroadcastJoinThreshold=10485760
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=false

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- different not JOIN in parent side
-- TC 01.01
SELECT t1a,
       t1b,
       t1c,
       t3a,
       t3b,
       t3c
FROM   t1
       JOIN t3
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2)
       AND t1b = t3b;

-- TC 01.02
SELECT          t1a,
                t1b,
                t1c,
                count(distinct(t3a)),
                t3b,
                t3c
FROM            t1
FULL OUTER JOIN t3 on t1b != t3b
RIGHT JOIN      t2 on t1c = t2c
where           t1a NOT IN
                (
                       SELECT t2a
                       FROM   t2
                       WHERE  t2c NOT IN
                              (
                                     SELECT t1c
                                     FROM   t1
                                     WHERE  t1a = t2a))
AND             t1b != t3b
AND             t1d = t2d
GROUP BY        t1a, t1b, t1c, t3a, t3b, t3c
HAVING          count(distinct(t3a)) >= 1
ORDER BY        t1a, t3b;

-- TC 01.03
SELECT t1a,
       t1b,
       t1c,
       t1d,
       t1h
FROM   t1
WHERE  t1a NOT IN
       (
                 SELECT    t2a
                 FROM      t2
                 LEFT JOIN t3 on t2b = t3b
                 WHERE t1d = t2d
                  )
AND    t1d NOT IN
       (
              SELECT t2d
              FROM   t2
              RIGHT JOIN t1 on t2e = t1e
              WHERE t1a = t2a);

-- TC 01.04
SELECT Count(DISTINCT( t1a )),
       t1b,
       t1c,
       t1d
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2
                   JOIN t1
                   WHERE  t2b <> t1b)
GROUP  BY t1b,
          t1c,
          t1d
HAVING t1d NOT IN (SELECT t2d
                   FROM   t2
                   WHERE  t1d = t2d)
ORDER BY t1b DESC;

-- TC 01.05
SELECT   COUNT(DISTINCT(t1a)),
         t1b,
         t1c,
         t1d
FROM     t1
WHERE    t1a NOT IN
         (
                SELECT t2a
                FROM   t2 INNER
                JOIN   t1 ON t1a = t2a)
GROUP BY t1b,
         t1c,
         t1d
HAVING   t1b < sum(t1c);

-- TC 01.06
SELECT   COUNT(DISTINCT(t1a)),
         t1b,
         t1c,
         t1d
FROM     t1
WHERE    t1a NOT IN
         (
                SELECT t2a
                FROM   t2 INNER
                JOIN   t1
                ON     t1a = t2a)
AND      t1d NOT IN
         (
                    SELECT     t2d
                    FROM       t2
                    INNER JOIN t3
                    ON         t2b = t3b )
GROUP BY t1b,
         t1c,
         t1d
HAVING   t1b < sum(t1c);

-- A test suite for GROUP BY in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("t1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("t1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("t1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("t1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("t1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("t1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("t1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("t1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("t1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("t1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("t1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("t1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("t2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("t1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("t1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("t1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("t1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("t2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("t1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("t1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("t1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("t1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("t1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("t1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("t1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("t3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("t3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("t1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("t3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("t3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("t1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("t1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("t3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- GROUP BY in parent side
-- TC 01.01
SELECT t1a,
       Avg(t1b)
FROM   t1
WHERE  t1a IN (SELECT t2a
               FROM   t2)
GROUP  BY t1a;

-- TC 01.02
SELECT t1a,
       Max(t1b)
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               WHERE  t1a = t2a)
GROUP  BY t1a,
          t1d;

-- TC 01.03
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a)
GROUP  BY t1a,
          t1b;

-- TC 01.04
SELECT t1a,
       Sum(DISTINCT( t1b ))
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a)
        OR t1c IN (SELECT t3c
                   FROM   t3
                   WHERE  t1a = t3a)
GROUP  BY t1a,
          t1c;

-- TC 01.05
SELECT t1a,
       Sum(DISTINCT( t1b ))
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a)
       AND t1c IN (SELECT t3c
                   FROM   t3
                   WHERE  t1a = t3a)
GROUP  BY t1a,
          t1c;

-- TC 01.06
SELECT t1a,
       Count(DISTINCT( t1b ))
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a)
GROUP  BY t1a,
          t1c
HAVING t1a = "t1b";

-- GROUP BY in subquery
-- TC 01.07
SELECT *
FROM   t1
WHERE  t1b IN (SELECT Max(t2b)
               FROM   t2
               GROUP  BY t2a);

-- TC 01.08
SELECT *
FROM   (SELECT t2a,
               t2b
        FROM   t2
        WHERE  t2a IN (SELECT t1a
                       FROM   t1
                       WHERE  t1b = t2b)
        GROUP  BY t2a,
                  t2b) t2;

-- TC 01.09
SELECT Count(DISTINCT( * ))
FROM   t1
WHERE  t1b IN (SELECT Min(t2b)
               FROM   t2
               WHERE  t1a = t2a
                      AND t1c = t2c
               GROUP  BY t2a);

-- TC 01.10
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT Max(t2c)
               FROM   t2
               WHERE  t1a = t2a
               GROUP  BY t2a,
                         t2c
               HAVING t2c > 8);

-- TC 01.11
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t2a IN (SELECT Min(t3a)
                              FROM   t3
                              WHERE  t3a = t2a
                              GROUP  BY t3b)
               GROUP  BY t2c);

-- GROUP BY in both
-- TC 01.12
SELECT t1a,
       Min(t1b)
FROM   t1
WHERE  t1c IN (SELECT Min(t2c)
               FROM   t2
               WHERE  t2b = t1b
               GROUP  BY t2a)
GROUP  BY t1a;

-- TC 01.13
SELECT t1a,
       Min(t1b)
FROM   t1
WHERE  t1c IN (SELECT Min(t2c)
               FROM   t2
               WHERE  t2b IN (SELECT Min(t3b)
                              FROM   t3
                              WHERE  t2a = t3a
                              GROUP  BY t3a)
               GROUP  BY t2c)
GROUP  BY t1a,
          t1d;

-- TC 01.14
SELECT t1a,
       Min(t1b)
FROM   t1
WHERE  t1c IN (SELECT Min(t2c)
               FROM   t2
               WHERE  t2b = t1b
               GROUP  BY t2a)
       AND t1d IN (SELECT t3d
                   FROM   t3
                   WHERE  t1c = t3c
                   GROUP  BY t3d)
GROUP  BY t1a;

-- TC 01.15
SELECT t1a,
       Min(t1b)
FROM   t1
WHERE  t1c IN (SELECT Min(t2c)
               FROM   t2
               WHERE  t2b = t1b
               GROUP  BY t2a)
        OR t1d IN (SELECT t3d
                   FROM   t3
                   WHERE  t1c = t3c
                   GROUP  BY t3d)
GROUP  BY t1a;

-- TC 01.16
SELECT t1a,
       Min(t1b)
FROM   t1
WHERE  t1c IN (SELECT Min(t2c)
               FROM   t2
               WHERE  t2b = t1b
               GROUP  BY t2a
               HAVING t2a > t1a)
        OR t1d IN (SELECT t3d
                   FROM   t3
                   WHERE  t1c = t3c
                   GROUP  BY t3d
                   HAVING t3d = t1d)
GROUP  BY t1a
HAVING Min(t1b) IS NOT NULL;



-- A test suite for simple IN predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("t1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("t1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("t1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("t1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("t1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("t1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("t1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("t1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("t1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("t1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("t1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("t1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("t2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("t1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("t1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("t1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("t1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("t2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("t1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("t1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("t1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("t1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("t1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("t1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("t1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("t3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("t3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("t1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("t3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("t3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("t1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("t1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("t3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("t3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- simple select
-- TC 01.01
SELECT *
FROM   t1
WHERE  t1a IN (SELECT t2a
               FROM   t2);

-- TC 01.02
SELECT *
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               WHERE  t1a = t2a);

-- TC 01.03
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2b
               FROM   t2
               WHERE  t1a != t2a);

-- TC 01.04
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2b
               FROM   t2
               WHERE  t1a = t2a
                       OR t1b > t2b);

-- TC 01.05
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2b
               FROM   t2
               WHERE  t2i IN (SELECT t3i
                              FROM   t3
                              WHERE  t2c = t3c));

-- TC 01.06
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2b
               FROM   t2
               WHERE  t2a IN (SELECT t3a
                              FROM   t3
                              WHERE  t2c = t3c
                                     AND t2b IS NOT NULL));

-- simple select for NOT IN
-- TC 01.07
SELECT DISTINCT( t1a ),
               t1b,
               t1h
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2);

-- DDLs
create temporary view a as select * from values
  (1, 1), (2, 1), (null, 1), (1, 3), (null, 3), (1, null), (null, 2)
  as a(a1, a2);

create temporary view b as select * from values
  (1, 1, 2), (null, 3, 2), (1, null, 2), (1, 2, null)
  as b(b1, b2, b3);

-- TC 02.01
SELECT a1, a2
FROM   a
WHERE  a1 NOT IN (SELECT b.b1
                  FROM   b
                  WHERE  a.a2 = b.b2)
;

-- TC 02.02
SELECT a1, a2
FROM   a
WHERE  a1 NOT IN (SELECT b.b1
                  FROM   b
                  WHERE  a.a2 = b.b2
                  AND    b.b3 > 1)
;
-- A test suite for in with cte in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- outside CTE
-- TC 01.01
WITH cte1
     AS (SELECT t1a,
                t1b
         FROM   t1
         WHERE  t1a = "val1a")
SELECT t1a,
       t1b,
       t1c,
       t1d,
       t1h
FROM   t1
WHERE  t1b IN (SELECT cte1.t1b
               FROM   cte1
               WHERE  cte1.t1b > 0);

-- TC 01.02
WITH cte1 AS
(
       SELECT t1a,
              t1b
       FROM   t1)
SELECT count(distinct(t1a)), t1b, t1c
FROM   t1
WHERE  t1b IN
       (
              SELECT cte1.t1b
              FROM   cte1
              WHERE  cte1.t1b > 0
              UNION
              SELECT cte1.t1b
              FROM   cte1
              WHERE  cte1.t1b > 5
              UNION ALL
              SELECT cte1.t1b
              FROM   cte1
              INTERSECT
              SELECT cte1.t1b
              FROM   cte1
              UNION
              SELECT cte1.t1b
              FROM   cte1 )
GROUP BY t1a, t1b, t1c
HAVING t1c IS NOT NULL;

-- TC 01.03
WITH cte1 AS
(
       SELECT t1a,
              t1b,
              t1c,
              t1d,
              t1e
       FROM   t1)
SELECT t1a,
       t1b,
       t1c,
       t1h
FROM   t1
WHERE  t1c IN
       (
              SELECT          cte1.t1c
              FROM            cte1
              JOIN            cte1 cte2
              on              cte1.t1b > cte2.t1b
              FULL OUTER JOIN cte1 cte3
              ON              cte1.t1c = cte3.t1c
              LEFT JOIN       cte1 cte4
              ON              cte1.t1d = cte4.t1d
              INNER JOIN  cte1 cte5
              ON              cte1.t1b < cte5.t1b
              LEFT OUTER JOIN  cte1 cte6
              ON              cte1.t1d > cte6.t1d);

-- CTE inside and outside
-- TC 01.04
WITH cte1
     AS (SELECT t1a,
                t1b
         FROM   t1
         WHERE  t1b IN (SELECT t2b
                        FROM   t2
                               RIGHT JOIN t1
                                       ON t1c = t2c
                               LEFT JOIN t3
                                      ON t2d = t3d)
                AND t1a = "val1b")
SELECT *
FROM   (SELECT *
        FROM   cte1
               JOIN cte1 cte2
                 ON cte1.t1b > 5
                    AND cte1.t1a = cte2.t1a
               FULL OUTER JOIN cte1 cte3
                            ON cte1.t1a = cte3.t1a
               INNER JOIN cte1 cte4
                       ON cte1.t1b = cte4.t1b) s;

-- TC 01.05
WITH cte1 AS
(
       SELECT t1a,
              t1b,
              t1h
       FROM   t1
       WHERE  t1a IN
              (
                     SELECT t2a
                     FROM   t2
                     WHERE  t1b < t2b))
SELECT   Count(DISTINCT t1a),
         t1b
FROM     (
                    SELECT     cte1.t1a,
                               cte1.t1b
                    FROM       cte1
                    JOIN       cte1 cte2
                    on         cte1.t1h >= cte2.t1h) s
WHERE    t1b IN
         (
                SELECT t1b
                FROM   t1)
GROUP BY t1b;

-- TC 01.06
WITH cte1 AS
(
       SELECT t1a,
              t1b,
              t1c
       FROM   t1
       WHERE  t1b IN
              (
                     SELECT t2b
                     FROM   t2 FULL OUTER JOIN T3 on t2a = t3a
                     WHERE  t1c = t2c) AND
              t1a = "val1b")
SELECT *
FROM            (
                       SELECT *
                       FROM   cte1
                       INNER JOIN   cte1 cte2 ON cte1.t1a = cte2.t1a
                       RIGHT OUTER JOIN cte1 cte3  ON cte1.t1b = cte3.t1b
                       LEFT OUTER JOIN cte1 cte4 ON cte1.t1c = cte4.t1c
                       ) s
;

-- TC 01.07
WITH cte1
     AS (SELECT t1a,
                t1b
         FROM   t1
         WHERE  t1b IN (SELECT t2b
                        FROM   t2
                        WHERE  t1c = t2c))
SELECT Count(DISTINCT( s.t1a )),
       s.t1b
FROM   (SELECT cte1.t1a,
               cte1.t1b
        FROM   cte1
               RIGHT OUTER JOIN cte1 cte2
                             ON cte1.t1a = cte2.t1a) s
GROUP  BY s.t1b;

-- TC 01.08
WITH cte1 AS
(
       SELECT t1a,
              t1b
       FROM   t1
       WHERE  t1b IN
              (
                     SELECT t2b
                     FROM   t2
                     WHERE  t1c = t2c))
SELECT DISTINCT(s.t1b)
FROM            (
                                SELECT          cte1.t1b
                                FROM            cte1
                                LEFT OUTER JOIN cte1 cte2
                                ON              cte1.t1b = cte2.t1b) s
WHERE           s.t1b IN
                (
                       SELECT t1.t1b
                       FROM   t1 INNER
                       JOIN   cte1
                       ON     t1.t1a = cte1.t1a);

-- CTE with NOT IN
-- TC 01.09
WITH cte1
     AS (SELECT t1a,
                t1b
         FROM   t1
         WHERE  t1a = "val1d")
SELECT t1a,
       t1b,
       t1c,
       t1h
FROM   t1
WHERE  t1b NOT IN (SELECT cte1.t1b
                   FROM   cte1
                   WHERE  cte1.t1b < 0) AND
       t1c > 10;

-- TC 01.10
WITH cte1 AS
(
       SELECT t1a,
              t1b,
              t1c,
              t1d,
              t1h
       FROM   t1
       WHERE  t1d NOT IN
              (
                              SELECT          t2d
                              FROM            t2
                              FULL OUTER JOIN t3 ON t2a = t3a
                              JOIN t1 on t1b = t2b))
SELECT   t1a,
         t1b,
         t1c,
         t1d,
         t1h
FROM     t1
WHERE    t1b NOT IN
         (
                    SELECT     cte1.t1b
                    FROM       cte1 INNER
                    JOIN       cte1 cte2 ON cte1.t1a = cte2.t1a
                    RIGHT JOIN cte1 cte3 ON cte1.t1b = cte3.t1b
                    JOIN cte1 cte4 ON cte1.t1c = cte4.t1c) AND
         t1c IS NOT NULL
ORDER BY t1c DESC;

-- A test suite for set-operations in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- UNION, UNION ALL, UNION DISTINCT, INTERSECT and EXCEPT in the parent
-- TC 01.01
SELECT t2a,
       t2b,
       t2c,
       t2h,
       t2i
FROM   (SELECT *
        FROM   t2
        WHERE  t2a IN (SELECT t1a
                       FROM   t1)
        UNION ALL
        SELECT *
        FROM   t3
        WHERE  t3a IN (SELECT t1a
                       FROM   t1)) AS t3
WHERE  t2i IS NOT NULL AND
       2 * t2b = t2c
ORDER  BY t2c DESC nulls first;

-- TC 01.02
SELECT t2a,
       t2b,
       t2d,
       Count(DISTINCT( t2h )),
       t2i
FROM   (SELECT *
        FROM   t2
        WHERE  t2a IN (SELECT t1a
                       FROM   t1
                       WHERE  t2b = t1b)
        UNION
        SELECT *
        FROM   t1
        WHERE  t1a IN (SELECT t3a
                       FROM   t3
                       WHERE  t1c = t3c)) AS t3
GROUP  BY t2a,
          t2b,
          t2d,
          t2i
ORDER  BY t2d DESC;

-- TC 01.03
SELECT t2a,
       t2b,
       t2c,
       Min(t2d)
FROM   t2
WHERE  t2a IN (SELECT t1a
               FROM   t1
               WHERE  t1b = t2b)
GROUP BY t2a, t2b, t2c
UNION ALL
SELECT t2a,
       t2b,
       t2c,
       Max(t2d)
FROM   t2
WHERE  t2a IN (SELECT t1a
               FROM   t1
               WHERE  t2c = t1c)
GROUP BY t2a, t2b, t2c
UNION
SELECT t3a,
       t3b,
       t3c,
       Min(t3d)
FROM   t3
WHERE  t3a IN (SELECT t2a
               FROM   t2
               WHERE  t3c = t2c)
GROUP BY t3a, t3b, t3c
UNION DISTINCT
SELECT t1a,
       t1b,
       t1c,
       Max(t1d)
FROM   t1
WHERE  t1a IN (SELECT t3a
               FROM   t3
               WHERE  t3d = t1d)
GROUP BY t1a, t1b, t1c;

-- TC 01.04
SELECT DISTINCT( t2a ),
               t2b,
               Count(t2c),
               t2d,
               t2h,
               t2i
FROM   t2
WHERE  t2a IN (SELECT t1a
               FROM   t1
               WHERE  t1b = t2b)
GROUP  BY t2a,
          t2b,
          t2c,
          t2d,
          t2h,
          t2i
UNION
SELECT DISTINCT( t2a ),
               t2b,
               Count(t2c),
               t2d,
               t2h,
               t2i
FROM   t2
WHERE  t2a IN (SELECT t1a
               FROM   t1
               WHERE  t2c = t1c)
GROUP  BY t2a,
          t2b,
          t2c,
          t2d,
          t2h,
          t2i
HAVING t2b IS NOT NULL;

-- TC 01.05
SELECT t2a,
               t2b,
               Count(t2c),
               t2d,
               t2h,
               t2i
FROM   t2
WHERE  t2a IN (SELECT DISTINCT(t1a)
               FROM   t1
               WHERE  t1b = t2b)
GROUP  BY t2a,
          t2b,
          t2c,
          t2d,
          t2h,
          t2i

UNION
SELECT DISTINCT( t2a ),
               t2b,
               Count(t2c),
               t2d,
               t2h,
               t2i
FROM   t2
WHERE  t2b IN (SELECT Max(t1b)
               FROM   t1
               WHERE  t2c = t1c)
GROUP  BY t2a,
          t2b,
          t2c,
          t2d,
          t2h,
          t2i
HAVING t2b IS NOT NULL
UNION DISTINCT
SELECT t2a,
       t2b,
       t2c,
       t2d,
       t2h,
       t2i
FROM   t2
WHERE  t2d IN (SELECT min(t1d)
               FROM   t1
               WHERE  t2c = t1c);

-- TC 01.06
SELECT t2a,
       t2b,
       t2c,
       t2d
FROM   t2
WHERE  t2a IN (SELECT t1a
               FROM   t1
               WHERE  t1b = t2b AND
                      t1d < t2d)
INTERSECT
SELECT t2a,
       t2b,
       t2c,
       t2d
FROM   t2
WHERE  t2b IN (SELECT Max(t1b)
               FROM   t1
               WHERE  t2c = t1c)
EXCEPT
SELECT t2a,
       t2b,
       t2c,
       t2d
FROM   t2
WHERE  t2d IN (SELECT Min(t3d)
               FROM   t3
               WHERE  t2c = t3c)
UNION ALL
SELECT t2a,
       t2b,
       t2c,
       t2d
FROM   t2
WHERE  t2c IN (SELECT Max(t1c)
               FROM   t1
               WHERE t1d = t2d);

-- UNION, UNION ALL, UNION DISTINCT, INTERSECT and EXCEPT in the subquery
-- TC 01.07
SELECT DISTINCT(t1a),
       t1b,
       t1c,
       t1d
FROM   t1
WHERE  t1a IN (SELECT t3a
               FROM   (SELECT t2a t3a
                       FROM   t2
                       UNION ALL
                       SELECT t2a t3a
                       FROM   t2) AS t3
               UNION
               SELECT t2a
               FROM   (SELECT t2a
                       FROM   t2
                       WHERE  t2b > 6
                       UNION
                       SELECT t2a
                       FROM   t2
                       WHERE  t2b > 6) AS t4
               UNION DISTINCT
               SELECT t2a
               FROM   (SELECT t2a
                       FROM   t2
                       WHERE  t2b > 6
                       UNION DISTINCT
                       SELECT t1a
                       FROM   t1
                       WHERE  t1b > 6) AS t5)
GROUP BY t1a, t1b, t1c, t1d
HAVING t1c IS NOT NULL AND t1b IS NOT NULL
ORDER BY t1c DESC, t1a DESC;

-- TC 01.08
SELECT t1a,
       t1b,
       t1c
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   (SELECT t2b
                       FROM   t2
                       WHERE  t2b > 6
                       INTERSECT
                       SELECT t1b
                       FROM   t1
                       WHERE  t1b > 6) AS t3
               WHERE  t2b = t1b);

-- TC 01.09
SELECT t1a,
       t1b,
       t1c
FROM   t1
WHERE  t1h IN (SELECT t2h
               FROM   (SELECT t2h
                       FROM   t2
                       EXCEPT
                       SELECT t3h
                       FROM   t3) AS t3)
ORDER BY t1b DESC NULLs first, t1c  DESC NULLs last;

-- UNION, UNION ALL, UNION DISTINCT, INTERSECT and EXCEPT in the parent and subquery
-- TC 01.10
SELECT t1a,
       t1b,
       t1c
FROM   t1
WHERE  t1b IN
       (
              SELECT t2b
              FROM   (
                            SELECT t2b
                            FROM   t2
                            WHERE  t2b > 6
                            INTERSECT
                            SELECT t1b
                            FROM   t1
                            WHERE  t1b > 6) AS t3)
UNION DISTINCT
SELECT t1a,
       t1b,
       t1c
FROM   t1
WHERE  t1b IN
       (
              SELECT t2b
              FROM   (
                            SELECT t2b
                            FROM   t2
                            WHERE  t2b > 6
                            EXCEPT
                            SELECT t1b
                            FROM   t1
                            WHERE  t1b > 6) AS t4
              WHERE  t2b = t1b)
ORDER BY t1c DESC NULLS last, t1a DESC;

-- TC 01.11
SELECT *
FROM   (SELECT *
        FROM   (SELECT *
                FROM   t2
                WHERE  t2h IN (SELECT t1h
                               FROM   t1
                               WHERE  t1a = t2a)
                UNION DISTINCT
                SELECT *
                FROM   t1
                WHERE  t1h IN (SELECT t3h
                               FROM   t3
                               UNION
                               SELECT t1h
                               FROM   t1)
                UNION
                SELECT *
                FROM   t3
                WHERE  t3a IN (SELECT t2a
                               FROM   t2
                               UNION ALL
                               SELECT t1a
                               FROM   t1
                               WHERE  t1b > 0)
               INTERSECT
               SELECT *
               FROM   T1
               WHERE  t1b IN (SELECT t3b
                              FROM   t3
                              UNION DISTINCT
                              SELECT t2b
                              FROM   t2
                               )
              EXCEPT
              SELECT *
              FROM   t2
              WHERE  t2h IN (SELECT t1i
                             FROM   t1)) t4
        WHERE  t4.t2b IN (SELECT Min(t3b)
                          FROM   t3
                          WHERE  t4.t2a = t3a));

-- UNION, UNION ALL, UNION DISTINCT, INTERSECT and EXCEPT for NOT IN
-- TC 01.12
SELECT t2a,
       t2b,
       t2c,
       t2i
FROM   (SELECT *
        FROM   t2
        WHERE  t2a NOT IN (SELECT t1a
                           FROM   t1
                           UNION
                           SELECT t3a
                           FROM   t3)
        UNION ALL
        SELECT *
        FROM   t2
        WHERE  t2a NOT IN (SELECT t1a
                           FROM   t1
                           INTERSECT
                           SELECT t2a
                           FROM   t2)) AS t3
WHERE  t3.t2a NOT IN (SELECT t1a
                      FROM   t1
                      INTERSECT
                      SELECT t2a
                      FROM   t2)
       AND t2c IS NOT NULL
ORDER  BY t2a;

-- TC 01.13
SELECT   Count(DISTINCT(t1a)),
         t1b,
         t1c,
         t1i
FROM     t1
WHERE    t1b NOT IN
         (
                SELECT t2b
                FROM   (
                              SELECT t2b
                              FROM   t2
                              WHERE  t2b NOT IN
                                     (
                                            SELECT t1b
                                            FROM   t1)
                              UNION
                              SELECT t1b
                              FROM   t1
                              WHERE  t1b NOT IN
                                     (
                                            SELECT t3b
                                            FROM   t3)
                              UNION
                                    distinct SELECT t3b
                              FROM   t3
                              WHERE  t3b NOT IN
                                     (
                                            SELECT t2b
                                            FROM   t2)) AS t3
                WHERE  t2b = t1b)
GROUP BY t1a,
         t1b,
         t1c,
         t1i
HAVING   t1b NOT IN
         (
                SELECT t2b
                FROM   t2
                WHERE  t2c IS NULL
                EXCEPT
                SELECT t3b
                FROM   t3)
ORDER BY t1c DESC NULLS LAST, t1i;

-- Unit tests for simple NOT IN with a literal expression of a single column
--
-- More information can be found in not-in-unit-tests-single-column.sql.
-- This file has the same test cases as not-in-unit-tests-single-column.sql with literals instead of
-- subqueries.

CREATE TEMPORARY VIEW m AS SELECT * FROM VALUES
  (null, 1.0),
  (2, 3.0),
  (4, 5.0)
  AS m(a, b);

  -- Uncorrelated NOT IN Subquery test cases
  -- Case 1 (not possible to write a literal with no rows, so we ignore it.)
  -- (empty subquery -> all rows returned)

  -- Case 2
  -- (subquery includes null -> no rows returned)
SELECT *
FROM   m
WHERE  a NOT IN (null);

  -- Case 3
  -- (probe column is null -> row not returned)
SELECT *
FROM   m
WHERE  b = 1.0 -- Only matches (null, 1.0)
       AND a NOT IN (2);

  -- Case 4
  -- (probe column matches subquery row -> row not returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Only matches (2, 3.0)
       AND a NOT IN (2);

  -- Case 5
  -- (probe column does not match subquery row -> row is returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Only matches (2, 3.0)
       AND a NOT IN (6);
-- Unit tests for simple NOT IN predicate subquery across a single column.
--
-- ``col NOT IN expr'' is quite difficult to reason about. There are many edge cases, some of the
-- rules are confusing to the uninitiated, and precedence and treatment of null values is plain
-- unintuitive. To make this simpler to understand, I've come up with a plain English way of
-- describing the expected behavior of this query.
--
-- - If the subquery is empty (i.e. returns no rows), the row should be returned, regardless of
--   whether the filtered columns include nulls.
-- - If the subquery contains a result with all columns null, then the row should not be returned.
-- - If for all non-null filter columns there exists a row in the subquery in which each column
--   either
--   1. is equal to the corresponding filter column or
--   2. is null
--   then the row should not be returned. (This includes the case where all filter columns are
--   null.)
-- - Otherwise, the row should be returned.
--
-- Using these rules, we can come up with a set of test cases for single-column and multi-column
-- NOT IN test cases.
--
-- Test cases for single-column ``WHERE a NOT IN (SELECT c FROM r ...)'':
-- | # | does subquery include null? | is a null? | a = c? | row with a included in result? |
-- | 1 | empty                       |            |        | yes                            |
-- | 2 | yes                         |            |        | no                             |
-- | 3 | no                          | yes        |        | no                             |
-- | 4 | no                          | no         | yes    | no                             |
-- | 5 | no                          | no         | no     | yes                            |
--
-- There are also some considerations around correlated subqueries. Correlated subqueries can
-- cause cases 2, 3, or 4 to be reduced to case 1 by limiting the number of rows returned by the
-- subquery, so the row from the parent table should always be included in the output.

CREATE TEMPORARY VIEW m AS SELECT * FROM VALUES
  (null, 1.0),
  (2, 3.0),
  (4, 5.0)
  AS m(a, b);

CREATE TEMPORARY VIEW s AS SELECT * FROM VALUES
  (null, 1.0),
  (2, 3.0),
  (6, 7.0)
  AS s(c, d);

  -- Uncorrelated NOT IN Subquery test cases
  -- Case 1
  -- (empty subquery -> all rows returned)
SELECT *
FROM   m
WHERE  a NOT IN (SELECT c
                 FROM   s
                 WHERE  d > 10.0) -- (empty subquery)
;

  -- Case 2
  -- (subquery includes null -> no rows returned)
SELECT *
FROM   m
WHERE  a NOT IN (SELECT c
                 FROM   s
                 WHERE  d = 1.0) -- Only matches (null, 1.0)
;

  -- Case 3
  -- (probe column is null -> row not returned)
SELECT *
FROM   m
WHERE  b = 1.0 -- Only matches (null, 1.0)
       AND a NOT IN (SELECT c
                     FROM   s
                     WHERE  d = 3.0) -- Matches (2, 3.0)
;

  -- Case 4
  -- (probe column matches subquery row -> row not returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Only matches (2, 3.0)
       AND a NOT IN (SELECT c
                     FROM   s
                     WHERE  d = 3.0) -- Matches (2, 3.0)
;

  -- Case 5
  -- (probe column does not match subquery row -> row is returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Only matches (2, 3.0)
       AND a NOT IN (SELECT c
                     FROM   s
                     WHERE  d = 7.0) -- Matches (6, 7.0)
;

  -- Correlated NOT IN subquery test cases
  -- Case 2->1
  -- (subquery had nulls but they are removed by correlated subquery -> all rows returned)
SELECT *
FROM   m
WHERE a NOT IN (SELECT c
                FROM   s
                WHERE  d = b + 10) -- Matches no row
;

  -- Case 3->1
  -- (probe column is null but subquery returns no rows -> row is returned)
SELECT *
FROM   m
WHERE  b = 1.0 -- Only matches (null, 1.0)
       AND a NOT IN (SELECT c
                     FROM   s
                     WHERE  d = b + 10) -- Matches no row
;

  -- Case 4->1
  -- (probe column matches row which is filtered out by correlated subquery -> row is returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Only matches (2, 3.0)
       AND a NOT IN (SELECT c
                     FROM   s
                     WHERE  d = b + 10) -- Matches no row
;
-- Unit tests for simple NOT IN predicate subquery across multiple columns.
--
-- See not-in-single-column-unit-tests.sql for an introduction.
-- This file has the same test cases as not-in-unit-tests-multi-column.sql with literals instead of
-- subqueries. Small changes have been made to the literals to make them typecheck.

CREATE TEMPORARY VIEW m AS SELECT * FROM VALUES
  (null, null),
  (null, 1.0),
  (2, 3.0),
  (4, 5.0)
  AS m(a, b);

-- Case 1 (not possible to write a literal with no rows, so we ignore it.)
-- (subquery is empty -> row is returned)

-- Cases 2, 3 and 4 are currently broken, so I have commented them out here.
-- Filed https://issues.apache.org/jira/browse/SPARK-24395 to fix and restore these test cases.

  -- Case 5
  -- (one null column with no match -> row is returned)
SELECT *
FROM   m
WHERE  b = 1.0 -- Matches (null, 1.0)
       AND (a, b) NOT IN ((2, 3.0));

  -- Case 6
  -- (no null columns with match -> row not returned)
SELECT *
FROM   m
WHERE  b = 3.0 -- Matches (2, 3.0)
       AND (a, b) NOT IN ((2, 3.0));

  -- Case 7
  -- (no null columns with no match -> row is returned)
SELECT *
FROM   m
WHERE  b = 5.0 -- Matches (4, 5.0)
       AND (a, b) NOT IN ((2, 3.0));
-- A test suite for IN JOINS in parent side, subquery, and both predicate subquery
-- It includes correlated cases.
-- List of configuration the test suite is run against:
--SET spark.sql.autoBroadcastJoinThreshold=10485760
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=false

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- different JOIN in parent side
-- TC 01.01
SELECT t1a, t1b, t1c, t3a, t3b, t3c
FROM   t1 natural JOIN t3
WHERE  t1a IN (SELECT t2a
               FROM   t2
               WHERE t1a = t2a)
       AND t1b = t3b
       AND t1a = t3a
ORDER  BY t1a,
          t1b,
          t1c DESC nulls first;

-- TC 01.02
SELECT    Count(DISTINCT(t1a)),
          t1b,
          t3a,
          t3b,
          t3c
FROM      t1 natural left JOIN t3
WHERE     t1a IN
          (
                 SELECT t2a
                 FROM   t2
                 WHERE t1d = t2d)
AND       t1b > t3b
GROUP BY  t1a,
          t1b,
          t3a,
          t3b,
          t3c
ORDER BY  t1a DESC, t3b DESC;

-- TC 01.03
SELECT     Count(DISTINCT(t1a))
FROM       t1 natural right JOIN t3
WHERE      t1a IN
           (
                  SELECT t2a
                  FROM   t2
                  WHERE  t1b = t2b)
AND        t1d IN
           (
                  SELECT t2d
                  FROM   t2
                  WHERE  t1c > t2c)
AND        t1a = t3a
GROUP BY   t1a
ORDER BY   t1a;

-- TC 01.04
SELECT          t1a,
                t1b,
                t1c,
                t3a,
                t3b,
                t3c
FROM            t1 FULL OUTER JOIN t3
where           t1a IN
                (
                       SELECT t2a
                       FROM   t2
                       WHERE t2c IS NOT NULL)
AND             t1b != t3b
AND             t1a = 'val1b'
ORDER BY        t1a;

-- TC 01.05
SELECT     Count(DISTINCT(t1a)),
           t1b
FROM       t1 RIGHT JOIN t3
where      t1a IN
           (
                  SELECT t2a
                  FROM   t2
                  WHERE  t2h > t3h)
AND        t3a IN
           (
                  SELECT t2a
                  FROM   t2
                  WHERE  t2c > t3c)
AND        t1h >= t3h
GROUP BY   t1a,
           t1b
HAVING     t1b > 8
ORDER BY   t1a;

-- TC 01.06
SELECT   Count(DISTINCT(t1a))
FROM     t1 LEFT OUTER
JOIN     t3
ON t1a = t3a
WHERE    t1a IN
         (
                SELECT t2a
                FROM   t2
                WHERE  t1h < t2h )
GROUP BY t1a
ORDER BY t1a;

-- TC 01.07
SELECT   Count(DISTINCT(t1a)),
         t1b
FROM     t1 INNER JOIN     t2
ON       t1a > t2a
WHERE    t1b IN
         (
                SELECT t2b
                FROM   t2
                WHERE  t2h > t1h)
OR       t1a IN
         (
                SELECT t2a
                FROM   t2
                WHERE  t2h < t1h)
GROUP BY t1b
HAVING   t1b > 6;

-- different JOIN in the subquery
-- TC 01.08
SELECT   Count(DISTINCT(t1a)),
         t1b
FROM     t1
WHERE    t1a IN
         (
                    SELECT     t2a
                    FROM       t2
                    JOIN t1
                    WHERE      t2b <> t1b)
AND      t1h IN
         (
                    SELECT     t2h
                    FROM       t2
                    RIGHT JOIN t3
                    where      t2b = t3b)
GROUP BY t1b
HAVING t1b > 8;

-- TC 01.09
SELECT   Count(DISTINCT(t1a)),
         t1b
FROM     t1
WHERE    t1a IN
         (
                    SELECT     t2a
                    FROM       t2
                    JOIN t1
                    WHERE      t2b <> t1b)
AND      t1h IN
         (
                    SELECT     t2h
                    FROM       t2
                    RIGHT JOIN t3
                    where      t2b = t3b)
AND       t1b IN
         (
                    SELECT     t2b
                    FROM       t2
                    FULL OUTER JOIN t3
                    where      t2b = t3b)

GROUP BY t1b
HAVING   t1b > 8;

-- JOIN in the parent and subquery
-- TC 01.10
SELECT     Count(DISTINCT(t1a)),
           t1b
FROM       t1
INNER JOIN t2 on t1b = t2b
RIGHT JOIN t3 ON t1a = t3a
where      t1a IN
           (
                           SELECT          t2a
                           FROM            t2
                           FULL OUTER JOIN t3
                           WHERE           t2b > t3b)
AND        t1c IN
           (
                           SELECT          t3c
                           FROM            t3
                           LEFT OUTER JOIN t2
                           ON              t3a = t2a )
AND        t1b IN
           (
                  SELECT t3b
                  FROM   t3 LEFT OUTER
                  JOIN   t1
                  WHERE  t3c = t1c)

AND        t1a = t2a
GROUP BY   t1b
ORDER BY   t1b DESC;

-- TC 01.11
SELECT    t1a,
          t1b,
          t1c,
          count(distinct(t2a)),
          t2b,
          t2c
FROM      t1
FULL JOIN t2  on t1a = t2a
RIGHT JOIN t3 on t1a = t3a
where     t1a IN
          (
                 SELECT t2a
                 FROM   t2 INNER
                 JOIN   t3
                 ON     t2b < t3b
                 WHERE  t2c IN
                        (
                               SELECT t1c
                               FROM   t1
                               WHERE  t1a = t2a))
and t1a = t2a
Group By t1a, t1b, t1c, t2a, t2b, t2c
HAVING t2c IS NOT NULL
ORDER By t2b DESC nulls last;

-- A test suite for IN LIMIT in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- LIMIT in parent side
-- TC 01.01
SELECT *
FROM   t1
WHERE  t1a IN (SELECT t2a
               FROM   t2
               WHERE  t1d = t2d)
LIMIT  2;

-- TC 01.02
SELECT *
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t2b >= 8
               LIMIT  2)
LIMIT 4;

-- TC 01.03
SELECT Count(DISTINCT( t1a )),
       t1b
FROM   t1
WHERE  t1d IN (SELECT t2d
               FROM   t2
               ORDER  BY t2c
               LIMIT 2)
GROUP  BY t1b
ORDER  BY t1b DESC NULLS FIRST
LIMIT  1;

-- LIMIT with NOT IN
-- TC 01.04
SELECT *
FROM   t1
WHERE  t1b NOT IN (SELECT t2b
                   FROM   t2
                   WHERE  t2b > 6
                   LIMIT  2);

-- TC 01.05
SELECT Count(DISTINCT( t1a )),
       t1b
FROM   t1
WHERE  t1d NOT IN (SELECT t2d
                   FROM   t2
                   ORDER  BY t2b DESC nulls first
                   LIMIT 1)
GROUP  BY t1b
ORDER BY t1b NULLS last
LIMIT  1;create temporary view tab_a as select * from values (1, 1) as tab_a(a1, b1);
create temporary view tab_b as select * from values (1, 1) as tab_b(a2, b2);
create temporary view struct_tab as select struct(col1 as a, col2 as b) as record from
 values (1, 1), (1, 2), (2, 1), (2, 2);

select 1 from tab_a where (a1, b1) not in (select a2, b2 from tab_b);
-- Invalid query, see SPARK-24341
select 1 from tab_a where (a1, b1) not in (select (a2, b2) from tab_b);

-- Aliasing is needed as a workaround for SPARK-24443
select count(*) from struct_tab where record in
  (select (a2 as a, b2 as b) from tab_b);
select count(*) from struct_tab where record not in
  (select (a2 as a, b2 as b) from tab_b);
-- A test suite for ORDER BY in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- ORDER BY in parent side
-- TC 01.01
SELECT *
FROM   t1
WHERE  t1a IN (SELECT t2a
               FROM   t2)
ORDER  BY t1a;

-- TC 01.02
SELECT t1a
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               WHERE  t1a = t2a)
ORDER  BY t1b DESC;

-- TC 01.03
SELECT t1a,
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a)
ORDER  BY 2 DESC nulls last;

-- TC 01.04
SELECT Count(DISTINCT( t1a ))
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               WHERE  t1a = t2a)
ORDER  BY Count(DISTINCT( t1a ));

-- ORDER BY in subquery
-- TC 01.05
SELECT *
FROM   t1
WHERE  t1b IN (SELECT t2c
               FROM   t2
               ORDER  BY t2d);

-- ORDER BY in BOTH
-- TC 01.06
SELECT *
FROM   t1
WHERE  t1b IN (SELECT Min(t2b)
               FROM   t2
               WHERE  t1b = t2b
               ORDER  BY Min(t2b))
ORDER BY t1c DESC nulls first;

-- TC 01.07
SELECT t1a,
       t1b,
       t1h
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a
               ORDER  BY t2b DESC nulls first)
        OR t1h IN (SELECT t2h
                   FROM   t2
                   WHERE  t1h > t2h)
ORDER  BY t1h DESC nulls last;

-- ORDER BY with NOT IN
-- TC 01.08
SELECT *
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2)
ORDER  BY t1a;

-- TC 01.09
SELECT t1a,
       t1b
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2
                   WHERE  t1a = t2a)
ORDER  BY t1b DESC nulls last;

-- TC 01.10
SELECT *
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2
                   ORDER  BY t2a DESC nulls first)
       and t1c IN (SELECT t2c
                   FROM   t2
                   ORDER  BY t2b DESC nulls last)
ORDER  BY t1c DESC nulls last;

-- GROUP BY and ORDER BY
-- TC 01.11
SELECT *
FROM   t1
WHERE  t1b IN (SELECT Min(t2b)
               FROM   t2
               GROUP  BY t2a
               ORDER  BY t2a DESC);

-- TC 01.12
SELECT t1a,
       Count(DISTINCT( t1b ))
FROM   t1
WHERE  t1b IN (SELECT Min(t2b)
               FROM   t2
               WHERE  t1a = t2a
               GROUP  BY t2a
               ORDER  BY t2a)
GROUP  BY t1a,
          t1h
ORDER BY t1a;

-- GROUP BY and ORDER BY with NOT IN
-- TC 01.13
SELECT *
FROM   t1
WHERE  t1b NOT IN (SELECT Min(t2b)
                   FROM   t2
                   GROUP  BY t2a
                   ORDER  BY t2a);

-- TC 01.14
SELECT t1a,
       Sum(DISTINCT( t1b ))
FROM   t1
WHERE  t1b NOT IN (SELECT Min(t2b)
                   FROM   t2
                   WHERE  t1a = t2a
                   GROUP  BY t2c
                   ORDER  BY t2c DESC nulls last)
GROUP  BY t1a;

-- TC 01.15
SELECT Count(DISTINCT( t1a )),
       t1b
FROM   t1
WHERE  t1h NOT IN (SELECT t2h
                   FROM   t2
                   where t1a = t2a
                   order by t2d DESC nulls first
                   )
GROUP  BY t1a,
          t1b
ORDER  BY t1b DESC nulls last;
-- A test suite for IN HAVING in parent side, subquery, and both predicate subquery
-- It includes correlated cases.

create temporary view t1 as select * from values
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:00:00.000', date '2014-04-04'),
  ("val1b", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1a", 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ("val1a", 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ("val1d", null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ("val1d", null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ("val1e", 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ("val1d", 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1a", 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ("val1e", 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ("val2a", 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ("val1c", 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ("val1b", null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ("val2e", 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1f", 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ("val1c", 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ("val1e", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ("val1f", 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ("val3a", 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ("val3a", 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val1b", 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ("val1b", 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ("val3c", 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ("val3c", 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ("val1b", null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ("val1b", null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ("val3b", 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ("val3b", 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- correlated IN subquery
-- HAVING in the subquery
-- TC 01.01
SELECT t1a,
       t1b,
       t1h
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               GROUP BY t2b
               HAVING t2b < 10);

-- TC 01.02
SELECT t1a,
       t1b,
       t1c
FROM   t1
WHERE  t1b IN (SELECT Min(t2b)
               FROM   t2
               WHERE  t1a = t2a
               GROUP  BY t2b
               HAVING t2b > 1);

-- HAVING in the parent
-- TC 01.03
SELECT t1a, t1b, t1c
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               WHERE t1c < t2c)
GROUP BY t1a, t1b, t1c
HAVING t1b < 10;

-- TC 01.04
SELECT t1a, t1b, t1c
FROM   t1
WHERE  t1b IN (SELECT t2b
               FROM   t2
               WHERE t1c = t2c)
GROUP BY t1a, t1b, t1c
HAVING COUNT (DISTINCT t1b) < 10;

-- BOTH
-- TC 01.05
SELECT Count(DISTINCT( t1a )),
       t1b
FROM   t1
WHERE  t1c IN (SELECT t2c
               FROM   t2
               WHERE  t1a = t2a
               GROUP BY t2c
               HAVING t2c > 10)
GROUP  BY t1b
HAVING t1b >= 8;

-- TC 01.06
SELECT t1a,
       Max(t1b)
FROM   t1
WHERE  t1b > 0
GROUP  BY t1a
HAVING t1a IN (SELECT t2a
               FROM   t2
               WHERE  t2b IN (SELECT t3b
                              FROM   t3
                              WHERE  t2c = t3c)
               );

-- HAVING clause with NOT IN
-- TC 01.07
SELECT t1a,
       t1c,
       Min(t1d)
FROM   t1
WHERE  t1a NOT IN (SELECT t2a
                   FROM   t2
                   GROUP BY t2a
                   HAVING t2a > 'val2a')
GROUP BY t1a, t1c
HAVING Min(t1d) > t1c;

-- TC 01.08
SELECT t1a,
       t1b
FROM   t1
WHERE  t1d NOT IN (SELECT t2d
                   FROM   t2
                   WHERE  t1a = t2a
                   GROUP BY t2c, t2d
                   HAVING t2c > 8)
GROUP  BY t1a, t1b
HAVING t1b < 10;

-- TC 01.09
SELECT t1a,
       Max(t1b)
FROM   t1
WHERE  t1b > 0
GROUP  BY t1a
HAVING t1a NOT IN (SELECT t2a
                   FROM   t2
                   WHERE  t2b > 3);

-- A test suite for scalar subquery in predicate context

CREATE OR REPLACE TEMPORARY VIEW p AS VALUES (1, 1) AS T(pk, pv);
CREATE OR REPLACE TEMPORARY VIEW c AS VALUES (1, 1) AS T(ck, cv);

-- SPARK-18814.1: Simplified version of TPCDS-Q32
SELECT pk, cv
FROM   p, c
WHERE  p.pk = c.ck
AND    c.cv = (SELECT avg(c1.cv)
               FROM   c c1
               WHERE  c1.ck = p.pk);

-- SPARK-18814.2: Adding stack of aggregates
SELECT pk, cv
FROM   p, c
WHERE  p.pk = c.ck
AND    c.cv = (SELECT max(avg)
               FROM   (SELECT   c1.cv, avg(c1.cv) avg
                       FROM     c c1
                       WHERE    c1.ck = p.pk
                       GROUP BY c1.cv));

create temporary view t1 as select * from values
  ('val1a', 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 00:00:00.000', date '2014-04-04'),
  ('val1b', 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ('val1a', 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ('val1a', 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ('val1c', 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ('val1d', null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ('val1d', null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ('val1e', 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ('val1e', 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ('val1d', 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ('val1a', 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ('val1e', 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ('val2a', 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ('val1b', 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ('val1b', 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ('val1c', 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ('val1b', null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ('val2e', 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ('val1f', 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ('val1b', 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ('val1b', 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ('val1c', 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ('val1e', 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ('val1f', 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ('val1b', null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ('val3a', 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ('val3a', 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val1b', 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val1b', 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val1b', 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ('val1b', 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ('val3c', 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ('val3c', 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ('val1b', null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ('val1b', null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ('val3b', 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val3b', 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- Group 1: scalar subquery in predicate context
--          no correlation
-- TC 01.01
SELECT t1a, t1b
FROM   t1
WHERE  t1c = (SELECT max(t2c)
              FROM   t2);

-- TC 01.02
SELECT t1a, t1d, t1f
FROM   t1
WHERE  t1c = (SELECT max(t2c)
              FROM   t2)
AND    t1b > (SELECT min(t3b)
              FROM   t3);

-- TC 01.03
SELECT t1a, t1h
FROM   t1
WHERE  t1c = (SELECT max(t2c)
              FROM   t2)
OR     t1b = (SELECT min(t3b)
              FROM   t3
              WHERE  t3b > 10);

-- TC 01.04
-- scalar subquery over outer join
SELECT t1a, t1b, t2d
FROM   t1 LEFT JOIN t2
       ON t1a = t2a
WHERE  t1b = (SELECT min(t3b)
              FROM   t3);

-- TC 01.05
-- test casting
SELECT t1a, t1b, t1g
FROM   t1
WHERE  t1c + 5 = (SELECT max(t2e)
                  FROM   t2);

-- TC 01.06
-- test casting
SELECT t1a, t1h
FROM   t1
WHERE  date(t1h) = (SELECT min(t2i)
                    FROM   t2);

-- TC 01.07
-- same table, expressions in scalar subquery
SELECT t2d, t1a
FROM   t1, t2
WHERE  t1b = t2b
AND    t2c + 1 = (SELECT max(t2c) + 1
                  FROM   t2, t1
                  WHERE  t2b = t1b);

-- TC 01.08
-- same table
SELECT DISTINCT t2a, max_t1g
FROM   t2, (SELECT   max(t1g) max_t1g, t1a
            FROM     t1
            GROUP BY t1a) t1
WHERE  t2a = t1a
AND    max_t1g = (SELECT max(t1g)
                  FROM   t1);

-- TC 01.09
-- more than one scalar subquery
SELECT t3b, t3c
FROM   t3
WHERE  (SELECT max(t3c)
        FROM   t3
        WHERE  t3b > 10) >=
       (SELECT min(t3b)
        FROM   t3
        WHERE  t3c > 0)
AND    (t3b is null or t3c is null);

-- Group 2: scalar subquery in predicate context
--          with correlation
-- TC 02.01
SELECT t1a
FROM   t1
WHERE  t1a < (SELECT   max(t2a)
              FROM     t2
              WHERE    t2c = t1c
              GROUP BY t2c);

-- TC 02.02
SELECT t1a, t1c
FROM   t1
WHERE  (SELECT   max(t2a)
        FROM     t2
        WHERE    t2c = t1c
        GROUP BY t2c) IS NULL;

-- TC 02.03
SELECT t1a
FROM   t1
WHERE  t1a = (SELECT   max(t2a)
              FROM     t2
              WHERE    t2c = t1c
              GROUP BY t2c
              HAVING   count(*) >= 0)
OR     t1i > '2014-12-31';

-- TC 02.03.01
SELECT t1a
FROM   t1
WHERE  t1a = (SELECT   max(t2a)
              FROM     t2
              WHERE    t2c = t1c
              GROUP BY t2c
              HAVING   count(*) >= 1)
OR     t1i > '2014-12-31';

-- TC 02.04
-- t1 on the right of an outer join
-- can be reduced to inner join
SELECT count(t1a)
FROM   t1 RIGHT JOIN t2
ON     t1d = t2d
WHERE  t1a < (SELECT   max(t2a)
              FROM     t2
              WHERE    t2c = t1c
              GROUP BY t2c);

-- TC 02.05
SELECT t1a
FROM   t1
WHERE  t1b <= (SELECT   max(t2b)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c)
AND    t1b >= (SELECT   min(t2b)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c);

-- TC 02.06
-- set op
SELECT t1a
FROM   t1
WHERE  t1a <= (SELECT   max(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c)
INTERSECT
SELECT t1a
FROM   t1
WHERE  t1a >= (SELECT   min(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c);

-- TC 02.07.01
-- set op
SELECT t1a
FROM   t1
WHERE  t1a <= (SELECT   max(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c)
UNION ALL
SELECT t1a
FROM   t1
WHERE  t1a >= (SELECT   min(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c);

-- TC 02.07.02
-- set op
SELECT t1a
FROM   t1
WHERE  t1a <= (SELECT   max(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c)
UNION DISTINCT
SELECT t1a
FROM   t1
WHERE  t1a >= (SELECT   min(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c);

-- TC 02.08
-- set op
SELECT t1a
FROM   t1
WHERE  t1a <= (SELECT   max(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c)
MINUS
SELECT t1a
FROM   t1
WHERE  t1a >= (SELECT   min(t2a)
               FROM     t2
               WHERE    t2c = t1c
               GROUP BY t2c);

-- TC 02.09
-- in HAVING clause
SELECT   t1a
FROM     t1
GROUP BY t1a, t1c
HAVING   max(t1b) <= (SELECT   max(t2b)
                      FROM     t2
                      WHERE    t2c = t1c
                      GROUP BY t2c);
-- A test suite for scalar subquery in SELECT clause

create temporary view t1 as select * from values
  ('val1a', 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 00:00:00.000', date '2014-04-04'),
  ('val1b', 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ('val1a', 16S, 12, 21L, float(15.0), 20D, 20E2, timestamp '2014-06-04 01:02:00.001', date '2014-06-04'),
  ('val1a', 16S, 12, 10L, float(15.0), 20D, 20E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ('val1c', 8S, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:02:00.001', date '2014-05-05'),
  ('val1d', null, 16, 22L, float(17.0), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', null),
  ('val1d', null, 16, 19L, float(17.0), 25D, 26E2, timestamp '2014-07-04 01:02:00.001', null),
  ('val1e', 10S, null, 25L, float(17.0), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-04'),
  ('val1e', 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-09-04 01:02:00.001', date '2014-09-04'),
  ('val1d', 10S, null, 12L, float(17.0), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ('val1a', 6S, 8, 10L, float(15.0), 20D, 20E2, timestamp '2014-04-04 01:02:00.001', date '2014-04-04'),
  ('val1e', 10S, null, 19L, float(17.0), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04')
  as t1(t1a, t1b, t1c, t1d, t1e, t1f, t1g, t1h, t1i);

create temporary view t2 as select * from values
  ('val2a', 6S, 12, 14L, float(15), 20D, 20E2, timestamp '2014-04-04 01:01:00.000', date '2014-04-04'),
  ('val1b', 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ('val1b', 8S, 16, 119L, float(17), 25D, 26E2, timestamp '2015-05-04 01:01:00.000', date '2015-05-04'),
  ('val1c', 12S, 16, 219L, float(17), 25D, 26E2, timestamp '2016-05-04 01:01:00.000', date '2016-05-04'),
  ('val1b', null, 16, 319L, float(17), 25D, 26E2, timestamp '2017-05-04 01:01:00.000', null),
  ('val2e', 8S, null, 419L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ('val1f', 19S, null, 519L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', date '2014-05-04'),
  ('val1b', 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-06-04 01:01:00.000', date '2014-06-04'),
  ('val1b', 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:01:00.000', date '2014-07-04'),
  ('val1c', 12S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-08-04 01:01:00.000', date '2014-08-05'),
  ('val1e', 8S, null, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:01:00.000', date '2014-09-04'),
  ('val1f', 19S, null, 19L, float(17), 25D, 26E2, timestamp '2014-10-04 01:01:00.000', date '2014-10-04'),
  ('val1b', null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:01:00.000', null)
  as t2(t2a, t2b, t2c, t2d, t2e, t2f, t2g, t2h, t2i);

create temporary view t3 as select * from values
  ('val3a', 6S, 12, 110L, float(15), 20D, 20E2, timestamp '2014-04-04 01:02:00.000', date '2014-04-04'),
  ('val3a', 6S, 12, 10L, float(15), 20D, 20E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val1b', 10S, 12, 219L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val1b', 10S, 12, 19L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val1b', 8S, 16, 319L, float(17), 25D, 26E2, timestamp '2014-06-04 01:02:00.000', date '2014-06-04'),
  ('val1b', 8S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-07-04 01:02:00.000', date '2014-07-04'),
  ('val3c', 17S, 16, 519L, float(17), 25D, 26E2, timestamp '2014-08-04 01:02:00.000', date '2014-08-04'),
  ('val3c', 17S, 16, 19L, float(17), 25D, 26E2, timestamp '2014-09-04 01:02:00.000', date '2014-09-05'),
  ('val1b', null, 16, 419L, float(17), 25D, 26E2, timestamp '2014-10-04 01:02:00.000', null),
  ('val1b', null, 16, 19L, float(17), 25D, 26E2, timestamp '2014-11-04 01:02:00.000', null),
  ('val3b', 8S, null, 719L, float(17), 25D, 26E2, timestamp '2014-05-04 01:02:00.000', date '2014-05-04'),
  ('val3b', 8S, null, 19L, float(17), 25D, 26E2, timestamp '2015-05-04 01:02:00.000', date '2015-05-04')
  as t3(t3a, t3b, t3c, t3d, t3e, t3f, t3g, t3h, t3i);

-- Group 1: scalar subquery in SELECT clause
--          no correlation
-- TC 01.01
-- more than one scalar subquery
SELECT (SELECT min(t3d) FROM t3) min_t3d,
       (SELECT max(t2h) FROM t2) max_t2h
FROM   t1
WHERE  t1a = 'val1c';

-- TC 01.02
-- scalar subquery in an IN subquery
SELECT   t1a, count(*)
FROM     t1
WHERE    t1c IN (SELECT   (SELECT min(t3c) FROM t3)
                 FROM     t2
                 GROUP BY t2g
                 HAVING   count(*) > 1)
GROUP BY t1a;

-- TC 01.03
-- under a set op
SELECT (SELECT min(t3d) FROM t3) min_t3d,
       null
FROM   t1
WHERE  t1a = 'val1c'
UNION
SELECT null,
       (SELECT max(t2h) FROM t2) max_t2h
FROM   t1
WHERE  t1a = 'val1c';

-- TC 01.04
SELECT (SELECT min(t3c) FROM t3) min_t3d
FROM   t1
WHERE  t1a = 'val1a'
INTERSECT
SELECT (SELECT min(t2c) FROM t2) min_t2d
FROM   t1
WHERE  t1a = 'val1d';

-- TC 01.05
SELECT q1.t1a, q2.t2a, q1.min_t3d, q2.avg_t3d
FROM   (SELECT t1a, (SELECT min(t3d) FROM t3) min_t3d
        FROM   t1
        WHERE  t1a IN ('val1e', 'val1c')) q1
       FULL OUTER JOIN
       (SELECT t2a, (SELECT avg(t3d) FROM t3) avg_t3d
        FROM   t2
        WHERE  t2a IN ('val1c', 'val2a')) q2
ON     q1.t1a = q2.t2a
AND    q1.min_t3d < q2.avg_t3d;

-- Group 2: scalar subquery in SELECT clause
--          with correlation
-- TC 02.01
SELECT (SELECT min(t3d) FROM t3 WHERE t3.t3a = t1.t1a) min_t3d,
       (SELECT max(t2h) FROM t2 WHERE t2.t2a = t1.t1a) max_t2h
FROM   t1
WHERE  t1a = 'val1b';

-- TC 02.02
SELECT (SELECT min(t3d) FROM t3 WHERE t3a = t1a) min_t3d
FROM   t1
WHERE  t1a = 'val1b'
MINUS
SELECT (SELECT min(t3d) FROM t3) abs_min_t3d
FROM   t1
WHERE  t1a = 'val1b';

-- TC 02.03
SELECT t1a, t1b
FROM   t1
WHERE  NOT EXISTS (SELECT (SELECT max(t2b)
                           FROM   t2 LEFT JOIN t1
                           ON     t2a = t1a
                           WHERE  t2c = t3c) dummy
                   FROM   t3
                   WHERE  t3b < (SELECT max(t2b)
                                 FROM   t2 LEFT JOIN t1
                                 ON     t2a = t1a
                                 WHERE  t2c = t3c)
                   AND    t3a = t1a);
-- Aliased subqueries in FROM clause
SELECT * FROM (SELECT * FROM testData) AS t WHERE key = 1;

FROM (SELECT * FROM testData WHERE key = 1) AS t SELECT *;

-- Optional `AS` keyword
SELECT * FROM (SELECT * FROM testData) t WHERE key = 1;

FROM (SELECT * FROM testData WHERE key = 1) t SELECT *;

-- Disallow unaliased subqueries in FROM clause
SELECT * FROM (SELECT * FROM testData) WHERE key = 1;

FROM (SELECT * FROM testData WHERE key = 1) SELECT *;
-- Tests EXISTS subquery support with ORDER BY and LIMIT clauses.

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);

-- order by in both outer and/or inner query block
-- TC.01.01
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_id 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id 
               ORDER  BY state) 
ORDER  BY hiredate; 

-- TC.01.02
SELECT id, 
       hiredate 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_id 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id 
               ORDER  BY state) 
ORDER  BY hiredate DESC; 

-- order by with not exists 
-- TC.01.03
SELECT * 
FROM   emp 
WHERE  NOT EXISTS (SELECT dept.dept_id 
                   FROM   dept 
                   WHERE  emp.dept_id = dept.dept_id 
                   ORDER  BY state) 
ORDER  BY hiredate; 

-- group by + order by with not exists
-- TC.01.04
SELECT emp_name 
FROM   emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) a 
                   FROM   dept 
                   WHERE  dept.dept_id = emp.dept_id 
                   GROUP  BY state 
                   ORDER  BY state);
-- TC.01.05
SELECT count(*) 
FROM   emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) a 
                   FROM   dept 
                   WHERE  dept.dept_id = emp.dept_id 
                   GROUP  BY dept_id 
                   ORDER  BY dept_id); 

-- limit in the exists subquery block.
-- TC.02.01
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   dept 
               WHERE  dept.dept_id > 10 
               LIMIT  1); 

-- limit in the exists subquery block with aggregate.
-- TC.02.02
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT max(dept.dept_id) 
               FROM   dept 
               GROUP  BY state 
               LIMIT  1); 

-- limit in the not exists subquery block.
-- TC.02.03
SELECT * 
FROM   emp 
WHERE  NOT EXISTS (SELECT dept.dept_name 
                   FROM   dept 
                   WHERE  dept.dept_id > 100 
                   LIMIT  1); 

-- limit in the not exists subquery block with aggregates.
-- TC.02.04
SELECT * 
FROM   emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) 
                   FROM   dept 
                   WHERE  dept.dept_id > 100 
                   GROUP  BY state 
                   LIMIT  1); 
-- Tests HAVING clause in subquery.

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);

-- simple having in subquery. 
-- TC.01.01
SELECT dept_id, count(*) 
FROM   emp 
GROUP  BY dept_id 
HAVING EXISTS (SELECT 1 
               FROM   bonus 
               WHERE  bonus_amt < min(emp.salary)); 

-- nested having in subquery
-- TC.01.02
SELECT * 
FROM   dept 
WHERE  EXISTS (SELECT dept_id, 
                      Count(*) 
               FROM   emp 
               GROUP  BY dept_id 
               HAVING EXISTS (SELECT 1 
                              FROM   bonus 
                              WHERE bonus_amt < Min(emp.salary)));

-- aggregation in outer and inner query block with having
-- TC.01.03
SELECT dept_id, 
       Max(salary) 
FROM   emp gp 
WHERE  EXISTS (SELECT dept_id, 
                      Count(*) 
               FROM   emp p
               GROUP  BY dept_id 
               HAVING EXISTS (SELECT 1 
                              FROM   bonus 
                              WHERE  bonus_amt < Min(p.salary))) 
GROUP  BY gp.dept_id;

-- more aggregate expressions in projection list of subquery
-- TC.01.04
SELECT * 
FROM   dept 
WHERE  EXISTS (SELECT dept_id, 
                        Count(*) 
                 FROM   emp 
                 GROUP  BY dept_id 
                 HAVING EXISTS (SELECT 1 
                                FROM   bonus 
                                WHERE  bonus_amt > Min(emp.salary)));

-- multiple aggregations in nested subquery
-- TC.01.05
SELECT * 
FROM   dept 
WHERE  EXISTS (SELECT dept_id, 
                      count(emp.dept_id)
               FROM   emp 
               WHERE  dept.dept_id = dept_id 
               GROUP  BY dept_id 
               HAVING EXISTS (SELECT 1 
                              FROM   bonus 
                              WHERE  ( bonus_amt > min(emp.salary) 
                                       AND count(emp.dept_id) > 1 )));
-- Tests aggregate expressions in outer query and EXISTS subquery.

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);

-- Aggregate in outer query block.
-- TC.01.01
SELECT emp.dept_id, 
       avg(salary),
       sum(salary)
FROM   emp 
WHERE  EXISTS (SELECT state 
               FROM   dept 
               WHERE  dept.dept_id = emp.dept_id) 
GROUP  BY dept_id; 

-- Aggregate in inner/subquery block
-- TC.01.02
SELECT emp_name 
FROM   emp 
WHERE  EXISTS (SELECT max(dept.dept_id) a 
               FROM   dept 
               WHERE  dept.dept_id = emp.dept_id 
               GROUP  BY dept.dept_id); 

-- Aggregate expression in both outer and inner query block.
-- TC.01.03
SELECT count(*) 
FROM   emp 
WHERE  EXISTS (SELECT max(dept.dept_id) a 
               FROM   dept 
               WHERE  dept.dept_id = emp.dept_id 
               GROUP  BY dept.dept_id); 

-- Nested exists with aggregate expression in inner most query block.
-- TC.01.04
SELECT * 
FROM   bonus 
WHERE  EXISTS (SELECT 1 
               FROM   emp 
               WHERE  emp.emp_name = bonus.emp_name 
                      AND EXISTS (SELECT max(dept.dept_id) 
                                  FROM   dept 
                                  WHERE  emp.dept_id = dept.dept_id 
                                  GROUP  BY dept.dept_id));

-- Not exists with Aggregate expression in outer
-- TC.01.05
SELECT emp.dept_id, 
       Avg(salary), 
       Sum(salary) 
FROM   emp 
WHERE  NOT EXISTS (SELECT state 
                   FROM   dept 
                   WHERE  dept.dept_id = emp.dept_id) 
GROUP  BY dept_id; 

-- Not exists with Aggregate expression in subquery block
-- TC.01.06
SELECT emp_name 
FROM   emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) a 
                   FROM   dept 
                   WHERE  dept.dept_id = emp.dept_id 
                   GROUP  BY dept.dept_id); 

-- Not exists with Aggregate expression in outer and subquery block
-- TC.01.07
SELECT count(*) 
FROM   emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) a 
                   FROM   dept 
                   WHERE  dept.dept_id = emp.dept_id 
                   GROUP  BY dept.dept_id); 

-- Nested not exists and exists with aggregate expression in inner most query block.
-- TC.01.08
SELECT * 
FROM   bonus 
WHERE  NOT EXISTS (SELECT 1 
                   FROM   emp 
                   WHERE  emp.emp_name = bonus.emp_name 
                          AND EXISTS (SELECT Max(dept.dept_id) 
                                      FROM   dept 
                                      WHERE  emp.dept_id = dept.dept_id 
                                      GROUP  BY dept.dept_id));
-- Tests EXISTS subquery support. Tests Exists subquery
-- used in Joins (Both when joins occurs in outer and suquery blocks)
-- List of configuration the test suite is run against:
--SET spark.sql.autoBroadcastJoinThreshold=10485760
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--SET spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=false

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);

-- Join in outer query block
-- TC.01.01
SELECT * 
FROM   emp, 
       dept 
WHERE  emp.dept_id = dept.dept_id 
       AND EXISTS (SELECT * 
                   FROM   bonus 
                   WHERE  bonus.emp_name = emp.emp_name); 

-- Join in outer query block with ON condition 
-- TC.01.02
SELECT * 
FROM   emp 
       JOIN dept 
         ON emp.dept_id = dept.dept_id 
WHERE  EXISTS (SELECT * 
               FROM   bonus 
               WHERE  bonus.emp_name = emp.emp_name);

-- Left join in outer query block with ON condition 
-- TC.01.03
SELECT * 
FROM   emp 
       LEFT JOIN dept 
              ON emp.dept_id = dept.dept_id 
WHERE  EXISTS (SELECT * 
               FROM   bonus 
               WHERE  bonus.emp_name = emp.emp_name); 

-- Join in outer query block + NOT EXISTS
-- TC.01.04
SELECT * 
FROM   emp, 
       dept 
WHERE  emp.dept_id = dept.dept_id 
       AND NOT EXISTS (SELECT * 
                       FROM   bonus 
                       WHERE  bonus.emp_name = emp.emp_name); 


-- inner join in subquery.
-- TC.01.05
SELECT * 
FROM   bonus 
WHERE  EXISTS (SELECT * 
                 FROM   emp 
                        JOIN dept 
                          ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name); 

-- right join in subquery
-- TC.01.06
SELECT * 
FROM   bonus 
WHERE  EXISTS (SELECT * 
                 FROM   emp 
                        RIGHT JOIN dept 
                                ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name); 


-- Aggregation and join in subquery
-- TC.01.07
SELECT * 
FROM   bonus 
WHERE  EXISTS (SELECT dept.dept_id, 
                        emp.emp_name, 
                        Max(salary), 
                        Count(*) 
                 FROM   emp 
                        JOIN dept 
                          ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name 
                 GROUP  BY dept.dept_id, 
                           emp.emp_name 
                 ORDER  BY emp.emp_name);

-- Aggregations in outer and subquery + join in subquery
-- TC.01.08
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   bonus 
WHERE  EXISTS (SELECT emp_name, 
                        Max(salary) 
                 FROM   emp 
                        JOIN dept 
                          ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name 
                 GROUP  BY emp_name 
                 HAVING Count(*) > 1 
                 ORDER  BY emp_name)
GROUP  BY emp_name; 

-- TC.01.09
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   bonus 
WHERE  NOT EXISTS (SELECT emp_name, 
                          Max(salary) 
                   FROM   emp 
                          JOIN dept 
                            ON dept.dept_id = emp.dept_id 
                   WHERE  bonus.emp_name = emp.emp_name 
                   GROUP  BY emp_name 
                   HAVING Count(*) > 1 
                   ORDER  BY emp_name) 
GROUP  BY emp_name;

-- Set operations along with EXISTS subquery
-- union
-- TC.02.01 
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT * 
               FROM   dept 
               WHERE  dept_id < 30 
               UNION 
               SELECT * 
               FROM   dept 
               WHERE  dept_id >= 30 
                      AND dept_id <= 50); 

-- intersect 
-- TC.02.02 
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT * 
                 FROM   dept 
                 WHERE  dept_id < 30 
                 INTERSECT 
                 SELECT * 
                 FROM   dept 
                 WHERE  dept_id >= 30 
                        AND dept_id <= 50);

-- intersect + not exists 
-- TC.02.03                
SELECT * 
FROM   emp 
WHERE  NOT EXISTS (SELECT * 
                     FROM   dept 
                     WHERE  dept_id < 30 
                     INTERSECT 
                     SELECT * 
                     FROM   dept 
                     WHERE  dept_id >= 30 
                            AND dept_id <= 50); 

-- Union all in outer query and except,intersect in subqueries. 
-- TC.02.04       
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT * 
                 FROM   dept 
                 EXCEPT 
                 SELECT * 
                 FROM   dept 
                 WHERE  dept_id > 50)
UNION ALL 
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT * 
                 FROM   dept 
                 WHERE  dept_id < 30 
                 INTERSECT 
                 SELECT * 
                 FROM   dept 
                 WHERE  dept_id >= 30 
                        AND dept_id <= 50);

-- Union in outer query and except,intersect in subqueries. 
-- TC.02.05       
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT * 
                 FROM   dept 
                 EXCEPT 
                 SELECT * 
                 FROM   dept 
                 WHERE  dept_id > 50)
UNION
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT * 
                 FROM   dept 
                 WHERE  dept_id < 30 
                 INTERSECT 
                 SELECT * 
                 FROM   dept 
                 WHERE  dept_id >= 30 
                        AND dept_id <= 50);

-- Tests EXISTS subquery support. Tests basic form 
-- of EXISTS subquery (both EXISTS and NOT EXISTS)

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);

-- uncorrelated exist query 
-- TC.01.01
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT 1 
               FROM   dept 
               WHERE  dept.dept_id > 10 
                      AND dept.dept_id < 30); 

-- simple correlated predicate in exist subquery
-- TC.01.02
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id); 

-- correlated outer isnull predicate
-- TC.01.03
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id 
                       OR emp.dept_id IS NULL);

-- Simple correlation with a local predicate in outer query
-- TC.01.04
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id) 
       AND emp.id > 200; 

-- Outer references (emp.id) should not be pruned from outer plan
-- TC.01.05
SELECT emp.emp_name 
FROM   emp 
WHERE  EXISTS (SELECT dept.state 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id) 
       AND emp.id > 200;

-- not exists with correlated predicate
-- TC.01.06
SELECT * 
FROM   dept 
WHERE  NOT EXISTS (SELECT emp_name 
                   FROM   emp 
                   WHERE  emp.dept_id = dept.dept_id);

-- not exists with correlated predicate + local predicate
-- TC.01.07
SELECT * 
FROM   dept 
WHERE  NOT EXISTS (SELECT emp_name 
                   FROM   emp 
                   WHERE  emp.dept_id = dept.dept_id 
                           OR state = 'NJ');

-- not exist both equal and greaterthan predicate
-- TC.01.08
SELECT * 
FROM   bonus 
WHERE  NOT EXISTS (SELECT * 
                   FROM   emp 
                   WHERE  emp.emp_name = emp_name 
                          AND bonus_amt > emp.salary); 

-- select employees who have not received any bonus
-- TC 01.09
SELECT emp.*
FROM   emp
WHERE  NOT EXISTS (SELECT NULL
                   FROM   bonus
                   WHERE  bonus.emp_name = emp.emp_name);

-- Nested exists
-- TC.01.10
SELECT * 
FROM   bonus 
WHERE  EXISTS (SELECT emp_name 
               FROM   emp 
               WHERE  bonus.emp_name = emp.emp_name 
                      AND EXISTS (SELECT state 
                                  FROM   dept 
                                  WHERE  dept.dept_id = emp.dept_id)); 
-- Tests EXISTS subquery support. Tests EXISTS 
-- subquery within a AND or OR expression.

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);


-- Or used in conjunction with exists - ExistenceJoin
-- TC.02.01
SELECT emp.emp_name 
FROM   emp 
WHERE  EXISTS (SELECT dept.state 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id) 
        OR emp.id > 200;

-- all records from emp including the null dept_id 
-- TC.02.02
SELECT * 
FROM   emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id) 
        OR emp.dept_id IS NULL; 

-- EXISTS subquery in both LHS and RHS of OR. 
-- TC.02.03
SELECT emp.emp_name 
FROM   emp 
WHERE  EXISTS (SELECT dept.state 
               FROM   dept 
               WHERE  emp.dept_id = dept.dept_id 
                      AND dept.dept_id = 20) 
        OR EXISTS (SELECT dept.state 
                   FROM   dept 
                   WHERE  emp.dept_id = dept.dept_id 
                          AND dept.dept_id = 30); 
;

-- not exists and exists predicate within OR
-- TC.02.04
SELECT * 
FROM   bonus 
WHERE  ( NOT EXISTS (SELECT * 
                     FROM   emp 
                     WHERE  emp.emp_name = emp_name 
                            AND bonus_amt > emp.salary) 
          OR EXISTS (SELECT * 
                     FROM   emp 
                     WHERE  emp.emp_name = emp_name 
                             OR bonus_amt < emp.salary) );

-- not exists and in predicate within AND
-- TC.02.05
SELECT * FROM bonus WHERE NOT EXISTS 
( 
       SELECT * 
       FROM   emp 
       WHERE  emp.emp_name = emp_name 
       AND    bonus_amt > emp.salary) 
AND 
emp_name IN 
( 
       SELECT emp_name 
       FROM   emp 
       WHERE  bonus_amt < emp.salary);

-- Tests EXISTS subquery used along with 
-- Common Table Expressions(CTE)

CREATE TEMPORARY VIEW EMP AS SELECT * FROM VALUES
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (100, "emp 1", date "2005-01-01", 100.00D, 10),
  (200, "emp 2", date "2003-01-01", 200.00D, 10),
  (300, "emp 3", date "2002-01-01", 300.00D, 20),
  (400, "emp 4", date "2005-01-01", 400.00D, 30),
  (500, "emp 5", date "2001-01-01", 400.00D, NULL),
  (600, "emp 6 - no dept", date "2001-01-01", 400.00D, 100),
  (700, "emp 7", date "2010-01-01", 400.00D, 100),
  (800, "emp 8", date "2016-01-01", 150.00D, 70)
AS EMP(id, emp_name, hiredate, salary, dept_id);

CREATE TEMPORARY VIEW DEPT AS SELECT * FROM VALUES
  (10, "dept 1", "CA"),
  (20, "dept 2", "NY"),
  (30, "dept 3", "TX"),
  (40, "dept 4 - unassigned", "OR"),
  (50, "dept 5 - unassigned", "NJ"),
  (70, "dept 7", "FL")
AS DEPT(dept_id, dept_name, state);

CREATE TEMPORARY VIEW BONUS AS SELECT * FROM VALUES
  ("emp 1", 10.00D),
  ("emp 1", 20.00D),
  ("emp 2", 300.00D),
  ("emp 2", 100.00D),
  ("emp 3", 300.00D),
  ("emp 4", 100.00D),
  ("emp 5", 1000.00D),
  ("emp 6 - no dept", 500.00D)
AS BONUS(emp_name, bonus_amt);

-- CTE used inside subquery with correlated condition 
-- TC.01.01 
WITH bonus_cte 
     AS (SELECT * 
         FROM   bonus 
         WHERE  EXISTS (SELECT dept.dept_id, 
                                 emp.emp_name, 
                                 Max(salary), 
                                 Count(*) 
                          FROM   emp 
                                 JOIN dept 
                                   ON dept.dept_id = emp.dept_id 
                          WHERE  bonus.emp_name = emp.emp_name 
                          GROUP  BY dept.dept_id, 
                                    emp.emp_name 
                          ORDER  BY emp.emp_name)) 
SELECT * 
FROM   bonus a 
WHERE  a.bonus_amt > 30 
       AND EXISTS (SELECT 1 
                   FROM   bonus_cte b 
                   WHERE  a.emp_name = b.emp_name); 

-- Inner join between two CTEs with correlated condition
-- TC.01.02
WITH emp_cte 
     AS (SELECT * 
         FROM   emp 
         WHERE  id >= 100 
                AND id <= 300), 
     dept_cte 
     AS (SELECT * 
         FROM   dept 
         WHERE  dept_id = 10) 
SELECT * 
FROM   bonus 
WHERE  EXISTS (SELECT * 
               FROM   emp_cte a 
                      JOIN dept_cte b 
                        ON a.dept_id = b.dept_id 
               WHERE  bonus.emp_name = a.emp_name); 

-- Left outer join between two CTEs with correlated condition
-- TC.01.03
WITH emp_cte 
     AS (SELECT * 
         FROM   emp 
         WHERE  id >= 100 
                AND id <= 300), 
     dept_cte 
     AS (SELECT * 
         FROM   dept 
         WHERE  dept_id = 10) 
SELECT DISTINCT b.emp_name, 
                b.bonus_amt 
FROM   bonus b, 
       emp_cte e, 
       dept d 
WHERE  e.dept_id = d.dept_id 
       AND e.emp_name = b.emp_name 
       AND EXISTS (SELECT * 
                   FROM   emp_cte a 
                          LEFT JOIN dept_cte b 
                                 ON a.dept_id = b.dept_id 
                   WHERE  e.emp_name = a.emp_name); 

-- Joins inside cte and aggregation on cte referenced subquery with correlated condition 
-- TC.01.04 
WITH empdept 
     AS (SELECT id, 
                salary, 
                emp_name, 
                dept.dept_id 
         FROM   emp 
                LEFT JOIN dept 
                       ON emp.dept_id = dept.dept_id 
         WHERE  emp.id IN ( 100, 200 )) 
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   bonus 
WHERE  EXISTS (SELECT dept_id, 
                      max(salary) 
               FROM   empdept 
               GROUP  BY dept_id 
               HAVING count(*) > 1) 
GROUP  BY emp_name; 

-- Using not exists 
-- TC.01.05      
WITH empdept 
     AS (SELECT id, 
                salary, 
                emp_name, 
                dept.dept_id 
         FROM   emp 
                LEFT JOIN dept 
                       ON emp.dept_id = dept.dept_id 
         WHERE  emp.id IN ( 100, 200 )) 
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   bonus 
WHERE  NOT EXISTS (SELECT dept_id, 
                          Max(salary) 
                   FROM   empdept 
                   GROUP  BY dept_id 
                   HAVING count(*) < 1) 
GROUP  BY emp_name; 
CREATE OR REPLACE TEMPORARY VIEW t1 AS VALUES (1, 'a'), (2, 'b') tbl(c1, c2);
CREATE OR REPLACE TEMPORARY VIEW t2 AS VALUES (1.0, 1), (2.0, 4) tbl(c1, c2);

-- Simple Union
SELECT *
FROM   (SELECT * FROM t1
        UNION ALL
        SELECT * FROM t1);

-- Type Coerced Union
SELECT *
FROM   (SELECT * FROM t1
        UNION ALL
        SELECT * FROM t2
        UNION ALL
        SELECT * FROM t2);

-- Regression test for SPARK-18622
SELECT a
FROM (SELECT 0 a, 0 b
      UNION ALL
      SELECT SUM(1) a, CAST(0 AS BIGINT) b
      UNION ALL SELECT 0 a, 0 b) T;

-- Regression test for SPARK-18841 Push project through union should not be broken by redundant alias removal.
CREATE OR REPLACE TEMPORARY VIEW p1 AS VALUES 1 T(col);
CREATE OR REPLACE TEMPORARY VIEW p2 AS VALUES 1 T(col);
CREATE OR REPLACE TEMPORARY VIEW p3 AS VALUES 1 T(col);
SELECT 1 AS x,
       col
FROM   (SELECT col AS col
        FROM (SELECT p1.col AS col
              FROM   p1 CROSS JOIN p2
              UNION ALL
              SELECT col
              FROM p3) T1) T2;

-- SPARK-24012 Union of map and other compatible columns.
SELECT map(1, 2), 'str'
UNION ALL
SELECT map(1, 2, 3, NULL), 1;

-- SPARK-24012 Union of array and other compatible columns.
SELECT array(1, 2), 'str'
UNION ALL
SELECT array(1, 2, 3, NULL), 1;


-- Clean-up
DROP VIEW IF EXISTS t1;
DROP VIEW IF EXISTS t2;
DROP VIEW IF EXISTS p1;
DROP VIEW IF EXISTS p2;
DROP VIEW IF EXISTS p3;
-- Argument number exception
select concat_ws();
select format_string();

-- A pipe operator for string concatenation
select 'a' || 'b' || 'c';

-- replace function
select replace('abc', 'b', '123');
select replace('abc', 'b');

-- uuid
select length(uuid()), (uuid() <> uuid());

-- position
select position('bar' in 'foobarbar'), position(null, 'foobarbar'), position('aaads', null);

-- left && right
select left("abcd", 2), left("abcd", 5), left("abcd", '2'), left("abcd", null);
select left(null, -2), left("abcd", -2), left("abcd", 0), left("abcd", 'a');
select right("abcd", 2), right("abcd", 5), right("abcd", '2'), right("abcd", null);
select right(null, -2), right("abcd", -2), right("abcd", 0), right("abcd", 'a');

-- split function
SELECT split('aa1cc2ee3', '[1-9]+');
SELECT split('aa1cc2ee3', '[1-9]+', 2);
CREATE TEMPORARY VIEW grouping AS SELECT * FROM VALUES
  ("1", "2", "3", 1),
  ("4", "5", "6", 1),
  ("7", "8", "9", 1)
  as grouping(a, b, c, d);

-- SPARK-17849: grouping set throws NPE #1
SELECT a, b, c, count(d) FROM grouping GROUP BY a, b, c GROUPING SETS (());

-- SPARK-17849: grouping set throws NPE #2
SELECT a, b, c, count(d) FROM grouping GROUP BY a, b, c GROUPING SETS ((a));

-- SPARK-17849: grouping set throws NPE #3
SELECT a, b, c, count(d) FROM grouping GROUP BY a, b, c GROUPING SETS ((c));

-- Group sets without explicit group by
SELECT c1, sum(c2) FROM (VALUES ('x', 10, 0), ('y', 20, 0)) AS t (c1, c2, c3) GROUP BY GROUPING SETS (c1);

-- Group sets without group by and with grouping
SELECT c1, sum(c2), grouping(c1) FROM (VALUES ('x', 10, 0), ('y', 20, 0)) AS t (c1, c2, c3) GROUP BY GROUPING SETS (c1);

-- Mutiple grouping within a grouping set
SELECT c1, c2, Sum(c3), grouping__id
FROM   (VALUES ('x', 'a', 10), ('y', 'b', 20) ) AS t (c1, c2, c3)
GROUP  BY GROUPING SETS ( ( c1 ), ( c2 ) )
HAVING GROUPING__ID > 1;

-- Group sets without explicit group by
SELECT grouping(c1) FROM (VALUES ('x', 'a', 10), ('y', 'b', 20)) AS t (c1, c2, c3) GROUP BY GROUPING SETS (c1,c2);

-- Mutiple grouping within a grouping set
SELECT -c1 AS c1 FROM (values (1,2), (3,2)) t(c1, c2) GROUP BY GROUPING SETS ((c1), (c1, c2));

-- complex expression in grouping sets
SELECT a + b, b, sum(c) FROM (VALUES (1,1,1),(2,2,2)) AS t(a,b,c) GROUP BY GROUPING SETS ( (a + b), (b));

-- complex expression in grouping sets
SELECT a + b, b, sum(c) FROM (VALUES (1,1,1),(2,2,2)) AS t(a,b,c) GROUP BY GROUPING SETS ( (a + b), (b + a), (b));

-- more query constructs with grouping sets
SELECT c1 AS col1, c2 AS col2
FROM   (VALUES (1, 2), (3, 2)) t(c1, c2)
GROUP  BY GROUPING SETS ( ( c1 ), ( c1, c2 ) )
HAVING col2 IS NOT NULL
ORDER  BY -col1;

-- negative tests - must have at least one grouping expression
SELECT a, b, c, count(d) FROM grouping GROUP BY WITH ROLLUP;

SELECT a, b, c, count(d) FROM grouping GROUP BY WITH CUBE;

SELECT c1 FROM (values (1,2), (3,2)) t(c1, c2) GROUP BY GROUPING SETS (());

CREATE TABLE t (a STRING, b INT, c STRING, d STRING) USING parquet
  OPTIONS (a '1', b '2')
  PARTITIONED BY (c, d) CLUSTERED BY (a) SORTED BY (b ASC) INTO 2 BUCKETS
  COMMENT 'table_comment'
  TBLPROPERTIES (t 'test');

CREATE TEMPORARY VIEW temp_v AS SELECT * FROM t;

CREATE TEMPORARY VIEW temp_Data_Source_View
  USING org.apache.spark.sql.sources.DDLScanSource
  OPTIONS (
    From '1',
    To '10',
    Table 'test1');

CREATE VIEW v AS SELECT * FROM t;

ALTER TABLE t SET TBLPROPERTIES (e = '3');

ALTER TABLE t ADD PARTITION (c='Us', d=1);

DESCRIBE t;

DESC default.t;

DESC TABLE t;

DESC FORMATTED t;

DESC EXTENDED t;

ALTER TABLE t UNSET TBLPROPERTIES (e);

DESC EXTENDED t;

ALTER TABLE t UNSET TBLPROPERTIES (comment);

DESC EXTENDED t;

DESC t PARTITION (c='Us', d=1);

DESC EXTENDED t PARTITION (c='Us', d=1);

DESC FORMATTED t PARTITION (c='Us', d=1);

-- NoSuchPartitionException: Partition not found in table
DESC t PARTITION (c='Us', d=2);

-- AnalysisException: Partition spec is invalid
DESC t PARTITION (c='Us');

-- ParseException: PARTITION specification is incomplete
DESC t PARTITION (c='Us', d);

-- DESC Temp View

DESC temp_v;

DESC TABLE temp_v;

DESC FORMATTED temp_v;

DESC EXTENDED temp_v;

DESC temp_Data_Source_View;

-- AnalysisException DESC PARTITION is not allowed on a temporary view
DESC temp_v PARTITION (c='Us', d=1);

-- DESC Persistent View

DESC v;

DESC TABLE v;

DESC FORMATTED v;

DESC EXTENDED v;

-- AnalysisException DESC PARTITION is not allowed on a view
DESC v PARTITION (c='Us', d=1);

-- Explain Describe Table
EXPLAIN DESC t;
EXPLAIN DESC EXTENDED t;
EXPLAIN EXTENDED DESC t;
EXPLAIN DESCRIBE t b;
EXPLAIN DESCRIBE t PARTITION (c='Us', d=2);

-- DROP TEST TABLES/VIEWS
DROP TABLE t;

DROP VIEW temp_v;

DROP VIEW temp_Data_Source_View;

DROP VIEW v;
-- simple
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet;

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- options
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
OPTIONS ('a' 1);

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- path option
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
OPTIONS ('path' '/path/to/table');

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- location
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
LOCATION '/path/to/table';

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- partition by
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
PARTITIONED BY (a);

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- clustered by
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
CLUSTERED BY (a) SORTED BY (b ASC) INTO 2 BUCKETS;

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- comment
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
COMMENT 'This is a comment';

SHOW CREATE TABLE tbl;
DROP TABLE tbl;


-- tblproperties
CREATE TABLE tbl (a INT, b STRING, c INT) USING parquet
TBLPROPERTIES ('a' = '1');

SHOW CREATE TABLE tbl;
DROP TABLE tbl;
-- Create the origin table
CREATE TABLE test_change(a INT, b STRING, c INT) using parquet;
DESC test_change;

-- Change column name (not supported yet)
ALTER TABLE test_change CHANGE a a1 INT;
DESC test_change;

-- Change column dataType (not supported yet)
ALTER TABLE test_change CHANGE a a STRING;
DESC test_change;

-- Change column position (not supported yet)
ALTER TABLE test_change CHANGE a a INT AFTER b;
ALTER TABLE test_change CHANGE b b STRING FIRST;
DESC test_change;

-- Change column comment
ALTER TABLE test_change CHANGE a a INT COMMENT 'this is column a';
ALTER TABLE test_change CHANGE b b STRING COMMENT '#*02?`';
ALTER TABLE test_change CHANGE c c INT COMMENT '';
DESC test_change;

-- Don't change anything.
ALTER TABLE test_change CHANGE a a INT COMMENT 'this is column a';
DESC test_change;

-- Change a invalid column
ALTER TABLE test_change CHANGE invalid_col invalid_col INT;
DESC test_change;

-- Change column name/dataType/position/comment together (not supported yet)
ALTER TABLE test_change CHANGE a a1 STRING COMMENT 'this is column a1' AFTER b;
DESC test_change;

-- Check the behavior with different values of CASE_SENSITIVE
SET spark.sql.caseSensitive=false;
ALTER TABLE test_change CHANGE a A INT COMMENT 'this is column A';
SET spark.sql.caseSensitive=true;
ALTER TABLE test_change CHANGE a A INT COMMENT 'this is column A1';
DESC test_change;

-- Change column can't apply to a temporary/global_temporary view
CREATE TEMPORARY VIEW temp_view(a, b) AS SELECT 1, "one";
ALTER TABLE temp_view CHANGE a a INT COMMENT 'this is column a';
CREATE GLOBAL TEMPORARY VIEW global_temp_view(a, b) AS SELECT 1, "one";
ALTER TABLE global_temp.global_temp_view CHANGE a a INT COMMENT 'this is column a';

-- Change column in partition spec (not supported yet)
CREATE TABLE partition_table(a INT, b STRING, c INT, d STRING) USING parquet PARTITIONED BY (c, d);
ALTER TABLE partition_table PARTITION (c = 1) CHANGE COLUMN a new_a INT;
ALTER TABLE partition_table CHANGE COLUMN c c INT COMMENT 'this is column C';

-- DROP TEST TABLE
DROP TABLE test_change;
DROP TABLE partition_table;
DROP VIEW global_temp.global_temp_view;
-- Literal parsing

-- null
select null, Null, nUll;

-- boolean
select true, tRue, false, fALse;

-- byte (tinyint)
select 1Y;
select 127Y, -128Y;

-- out of range byte
select 128Y;

-- short (smallint)
select 1S;
select 32767S, -32768S;

-- out of range short
select 32768S;

-- long (bigint)
select 1L, 2147483648L;
select 9223372036854775807L, -9223372036854775808L;

-- out of range long
select 9223372036854775808L;

-- integral parsing

-- parse int
select 1, -1;

-- parse int max and min value as int
select 2147483647, -2147483648;

-- parse long max and min value as long
select 9223372036854775807, -9223372036854775808;

-- parse as decimals (Long.MaxValue + 1, and Long.MinValue - 1)
select 9223372036854775808, -9223372036854775809;

-- out of range decimal numbers
select 1234567890123456789012345678901234567890;
select 1234567890123456789012345678901234567890.0;

-- double
select 1D, 1.2D, 1e10, 1.5e5, .10D, 0.10D, .1e5, .9e+2, 0.9e+2, 900e-1, 9.e+1;
select -1D, -1.2D, -1e10, -1.5e5, -.10D, -0.10D, -.1e5;
-- negative double
select .e3;
-- very large decimals (overflowing double).
select 1E309, -1E309;

-- decimal parsing
select 0.3, -0.8, .5, -.18, 0.1111, .1111;

-- super large scientific notation double literals should still be valid doubles
select 123456789012345678901234567890123456789e10d, 123456789012345678901234567890123456789.1e10d;

-- string
select "Hello Peter!", 'hello lee!';
-- multi string
select 'hello' 'world', 'hello' " " 'lee';
-- single quote within double quotes
select "hello 'peter'";
select 'pattern%', 'no-pattern\%', 'pattern\\%', 'pattern\\\%';
select '\'', '"', '\n', '\r', '\t', 'Z';
-- "Hello!" in octals
select '\110\145\154\154\157\041';
-- "World :)" in unicode
select '\u0057\u006F\u0072\u006C\u0064\u0020\u003A\u0029';

-- date
select dAte '2016-03-12';
-- invalid date
select date 'mar 11 2016';

-- timestamp
select tImEstAmp '2016-03-11 20:54:00.000';
-- invalid timestamp
select timestamp '2016-33-11 20:54:00.000';

-- interval
select interval 13.123456789 seconds, interval -13.123456789 second;
select interval 1 year 2 month 3 week 4 day 5 hour 6 minute 7 seconds 8 millisecond, 9 microsecond;
-- ns is not supported
select interval 10 nanoseconds;

-- unsupported data type
select GEO '(10,-6)';

-- big decimal parsing
select 90912830918230182310293801923652346786BD, 123.0E-28BD, 123.08BD;

-- out of range big decimal
select 1.20E-38BD;

-- hexadecimal binary literal
select x'2379ACFe';

-- invalid hexadecimal binary literal
select X'XuZ';

-- Hive literal_double test.
SELECT 3.14, -3.14, 3.14e8, 3.14e-8, -3.14e8, -3.14e-8, 3.14e+8, 3.14E8, 3.14E-8;

-- map + interval test
select map(1, interval 1 day, 2, interval 3 week);
-- group by ordinal positions

create temporary view data as select * from values
  (1, 1),
  (1, 2),
  (2, 1),
  (2, 2),
  (3, 1),
  (3, 2)
  as data(a, b);

-- basic case
select a, sum(b) from data group by 1;

-- constant case
select 1, 2, sum(b) from data group by 1, 2;

-- duplicate group by column
select a, 1, sum(b) from data group by a, 1;
select a, 1, sum(b) from data group by 1, 2;

-- group by a non-aggregate expression's ordinal
select a, b + 2, count(2) from data group by a, 2;

-- with alias
select a as aa, b + 2 as bb, count(2) from data group by 1, 2;

-- foldable non-literal: this should be the same as no grouping.
select sum(b) from data group by 1 + 0;

-- negative cases: ordinal out of range
select a, b from data group by -1;
select a, b from data group by 0;
select a, b from data group by 3;

-- negative case: position is an aggregate expression
select a, b, sum(b) from data group by 3;
select a, b, sum(b) + 2 from data group by 3;

-- negative case: nondeterministic expression
select a, rand(0), sum(b)
from 
(select /*+ REPARTITION(1) */ a, b from data) group by a, 2;

-- negative case: star
select * from data group by a, b, 1;

-- group by ordinal followed by order by
select a, count(a) from (select 1 as a) tmp group by 1 order by 1;

-- group by ordinal followed by having
select count(a), a from (select 1 as a) tmp group by 2 having a > 0;

-- mixed cases: group-by ordinals and aliases
select a, a AS k, count(b) from data group by k, 1;

-- turn off group by ordinal
set spark.sql.groupByOrdinal=false;

-- can now group by negative literal
select sum(b) from data group by -1;

-- count(null) should be 0
SELECT COUNT(NULL) FROM VALUES 1, 2, 3;
SELECT COUNT(1 + NULL) FROM VALUES 1, 2, 3;

-- count(null) on window should be 0
SELECT COUNT(NULL) OVER () FROM VALUES 1, 2, 3;
SELECT COUNT(1 + NULL) OVER () FROM VALUES 1, 2, 3;

-- unresolved function
select * from dummy(3);

-- range call with end
select * from range(6 + cos(3));

-- range call with start and end
select * from range(5, 10);

-- range call with step
select * from range(0, 10, 2);

-- range call with numPartitions
select * from range(0, 10, 1, 200);

-- range call error
select * from range(1, 1, 1, 1, 1);

-- range call with null
select * from range(1, null);

-- range call with a mixed-case function name
select * from RaNgE(2);
-- Tests covering different scenarios with qualified column names
-- Scenario: column resolution scenarios with datasource table
CREATE DATABASE mydb1;
USE mydb1;
CREATE TABLE t1 USING parquet AS SELECT 1 AS i1;

CREATE DATABASE mydb2;
USE mydb2;
CREATE TABLE t1 USING parquet AS SELECT 20 AS i1;

USE mydb1;
SELECT i1 FROM t1;
SELECT i1 FROM mydb1.t1;
SELECT t1.i1 FROM t1;
SELECT t1.i1 FROM mydb1.t1;

SELECT mydb1.t1.i1 FROM t1;
SELECT mydb1.t1.i1 FROM mydb1.t1;

USE mydb2;
SELECT i1 FROM t1;
SELECT i1 FROM mydb1.t1;
SELECT t1.i1 FROM t1;
SELECT t1.i1 FROM mydb1.t1;
SELECT mydb1.t1.i1 FROM mydb1.t1;

-- Scenario: resolve fully qualified table name in star expansion
USE mydb1;
SELECT t1.* FROM t1;
SELECT mydb1.t1.* FROM mydb1.t1;
SELECT t1.* FROM mydb1.t1;
USE mydb2;
SELECT t1.* FROM t1;
SELECT mydb1.t1.* FROM mydb1.t1;
SELECT t1.* FROM mydb1.t1;
SELECT a.* FROM mydb1.t1 AS a;

-- Scenario: resolve in case of subquery

USE mydb1;
CREATE TABLE t3 USING parquet AS SELECT * FROM VALUES (4,1), (3,1) AS t3(c1, c2);
CREATE TABLE t4 USING parquet AS SELECT * FROM VALUES (4,1), (2,1) AS t4(c2, c3);

SELECT * FROM t3 WHERE c1 IN (SELECT c2 FROM t4 WHERE t4.c3 = t3.c2);

SELECT * FROM mydb1.t3 WHERE c1 IN
  (SELECT mydb1.t4.c2 FROM mydb1.t4 WHERE mydb1.t4.c3 = mydb1.t3.c2);

-- Scenario: column resolution scenarios in join queries
SET spark.sql.crossJoin.enabled = true;

SELECT mydb1.t1.i1 FROM t1, mydb2.t1;

SELECT mydb1.t1.i1 FROM mydb1.t1, mydb2.t1;

USE mydb2;
SELECT mydb1.t1.i1 FROM t1, mydb1.t1;
SET spark.sql.crossJoin.enabled = false;

-- Scenario: Table with struct column
USE mydb1;
CREATE TABLE t5(i1 INT, t5 STRUCT<i1:INT, i2:INT>) USING parquet;
INSERT INTO t5 VALUES(1, (2, 3));
SELECT t5.i1 FROM t5;
SELECT t5.t5.i1 FROM t5;
SELECT t5.t5.i1 FROM mydb1.t5;
SELECT t5.i1 FROM mydb1.t5;
SELECT t5.* FROM mydb1.t5;
SELECT t5.t5.* FROM mydb1.t5;
SELECT mydb1.t5.t5.i1 FROM mydb1.t5;
SELECT mydb1.t5.t5.i2 FROM mydb1.t5;
SELECT mydb1.t5.* FROM mydb1.t5;
SELECT mydb1.t5.* FROM t5;

-- Cleanup and Reset
USE default;
DROP DATABASE mydb1 CASCADE;
DROP DATABASE mydb2 CASCADE;
set spark.sql.legacy.integralDivide.returnBigint=true;

select 5 div 2;
select 5 div 0;
select 5 div null;
select null div 5;

set spark.sql.legacy.integralDivide.returnBigint=false;

select 5 div 2;
select 5 div 0;
select 5 div null;
select null div 5;

create temporary view courseSales as select * from values
  ("dotNET", 2012, 10000),
  ("Java", 2012, 20000),
  ("dotNET", 2012, 5000),
  ("dotNET", 2013, 48000),
  ("Java", 2013, 30000)
  as courseSales(course, year, earnings);

create temporary view years as select * from values
  (2012, 1),
  (2013, 2)
  as years(y, s);

create temporary view yearsWithComplexTypes as select * from values
  (2012, array(1, 1), map('1', 1), struct(1, 'a')),
  (2013, array(2, 2), map('2', 2), struct(2, 'b'))
  as yearsWithComplexTypes(y, a, m, s);

-- pivot courses
SELECT * FROM (
  SELECT year, course, earnings FROM courseSales
)
PIVOT (
  sum(earnings)
  FOR course IN ('dotNET', 'Java')
);

-- pivot years with no subquery
SELECT * FROM courseSales
PIVOT (
  sum(earnings)
  FOR year IN (2012, 2013)
);

-- pivot courses with multiple aggregations
SELECT * FROM (
  SELECT year, course, earnings FROM courseSales
)
PIVOT (
  sum(earnings), avg(earnings)
  FOR course IN ('dotNET', 'Java')
);

-- pivot with no group by column
SELECT * FROM (
  SELECT course, earnings FROM courseSales
)
PIVOT (
  sum(earnings)
  FOR course IN ('dotNET', 'Java')
);

-- pivot with no group by column and with multiple aggregations on different columns
SELECT * FROM (
  SELECT year, course, earnings FROM courseSales
)
PIVOT (
  sum(earnings), min(year)
  FOR course IN ('dotNET', 'Java')
);

-- pivot on join query with multiple group by columns
SELECT * FROM (
  SELECT course, year, earnings, s
  FROM courseSales
  JOIN years ON year = y
)
PIVOT (
  sum(earnings)
  FOR s IN (1, 2)
);

-- pivot on join query with multiple aggregations on different columns
SELECT * FROM (
  SELECT course, year, earnings, s
  FROM courseSales
  JOIN years ON year = y
)
PIVOT (
  sum(earnings), min(s)
  FOR course IN ('dotNET', 'Java')
);

-- pivot on join query with multiple columns in one aggregation
SELECT * FROM (
  SELECT course, year, earnings, s
  FROM courseSales
  JOIN years ON year = y
)
PIVOT (
  sum(earnings * s)
  FOR course IN ('dotNET', 'Java')
);

-- pivot with aliases and projection
SELECT 2012_s, 2013_s, 2012_a, 2013_a, c FROM (
  SELECT year y, course c, earnings e FROM courseSales
)
PIVOT (
  sum(e) s, avg(e) a
  FOR y IN (2012, 2013)
);

-- pivot with projection and value aliases
SELECT firstYear_s, secondYear_s, firstYear_a, secondYear_a, c FROM (
  SELECT year y, course c, earnings e FROM courseSales
)
PIVOT (
  sum(e) s, avg(e) a
  FOR y IN (2012 as firstYear, 2013 secondYear)
);

-- pivot years with non-aggregate function
SELECT * FROM courseSales
PIVOT (
  abs(earnings)
  FOR year IN (2012, 2013)
);

-- pivot with one of the expressions as non-aggregate function
SELECT * FROM (
  SELECT year, course, earnings FROM courseSales
)
PIVOT (
  sum(earnings), year
  FOR course IN ('dotNET', 'Java')
);

-- pivot with unresolvable columns
SELECT * FROM (
  SELECT course, earnings FROM courseSales
)
PIVOT (
  sum(earnings)
  FOR year IN (2012, 2013)
);

-- pivot with complex aggregate expressions
SELECT * FROM (
  SELECT year, course, earnings FROM courseSales
)
PIVOT (
  ceil(sum(earnings)), avg(earnings) + 1 as a1
  FOR course IN ('dotNET', 'Java')
);

-- pivot with invalid arguments in aggregate expressions
SELECT * FROM (
  SELECT year, course, earnings FROM courseSales
)
PIVOT (
  sum(avg(earnings))
  FOR course IN ('dotNET', 'Java')
);

-- pivot on multiple pivot columns
SELECT * FROM (
  SELECT course, year, earnings, s
  FROM courseSales
  JOIN years ON year = y
)
PIVOT (
  sum(earnings)
  FOR (course, year) IN (('dotNET', 2012), ('Java', 2013))
);

-- pivot on multiple pivot columns with aliased values
SELECT * FROM (
  SELECT course, year, earnings, s
  FROM courseSales
  JOIN years ON year = y
)
PIVOT (
  sum(earnings)
  FOR (course, s) IN (('dotNET', 2) as c1, ('Java', 1) as c2)
);

-- pivot on multiple pivot columns with values of wrong data types
SELECT * FROM (
  SELECT course, year, earnings, s
  FROM courseSales
  JOIN years ON year = y
)
PIVOT (
  sum(earnings)
  FOR (course, year) IN ('dotNET', 'Java')
);

-- pivot with unresolvable values
SELECT * FROM courseSales
PIVOT (
  sum(earnings)
  FOR year IN (s, 2013)
);

-- pivot with non-literal values
SELECT * FROM courseSales
PIVOT (
  sum(earnings)
  FOR year IN (course, 2013)
);

-- pivot on join query with columns of complex data types
SELECT * FROM (
  SELECT course, year, a
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  min(a)
  FOR course IN ('dotNET', 'Java')
);

-- pivot on multiple pivot columns with agg columns of complex data types
SELECT * FROM (
  SELECT course, year, y, a
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  max(a)
  FOR (y, course) IN ((2012, 'dotNET'), (2013, 'Java'))
);

-- pivot on pivot column of array type
SELECT * FROM (
  SELECT earnings, year, a
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  sum(earnings)
  FOR a IN (array(1, 1), array(2, 2))
);

-- pivot on multiple pivot columns containing array type
SELECT * FROM (
  SELECT course, earnings, year, a
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  sum(earnings)
  FOR (course, a) IN (('dotNET', array(1, 1)), ('Java', array(2, 2)))
);

-- pivot on pivot column of struct type
SELECT * FROM (
  SELECT earnings, year, s
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  sum(earnings)
  FOR s IN ((1, 'a'), (2, 'b'))
);

-- pivot on multiple pivot columns containing struct type
SELECT * FROM (
  SELECT course, earnings, year, s
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  sum(earnings)
  FOR (course, s) IN (('dotNET', (1, 'a')), ('Java', (2, 'b')))
);

-- pivot on pivot column of map type
SELECT * FROM (
  SELECT earnings, year, m
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  sum(earnings)
  FOR m IN (map('1', 1), map('2', 2))
);

-- pivot on multiple pivot columns containing map type
SELECT * FROM (
  SELECT course, earnings, year, m
  FROM courseSales
  JOIN yearsWithComplexTypes ON year = y
)
PIVOT (
  sum(earnings)
  FOR (course, m) IN (('dotNET', map('1', 1)), ('Java', map('2', 2)))
);

-- grouping columns output in the same order as input
-- correctly handle pivot columns with different cases
SELECT * FROM (
  SELECT course, earnings, "a" as a, "z" as z, "b" as b, "y" as y, "c" as c, "x" as x, "d" as d, "w" as w
  FROM courseSales
)
PIVOT (
  sum(Earnings)
  FOR Course IN ('dotNET', 'Java')
);
CREATE TEMPORARY VIEW t1 AS SELECT * FROM VALUES (1) AS GROUPING(a);
CREATE TEMPORARY VIEW t2 AS SELECT * FROM VALUES (1) AS GROUPING(a);
CREATE TEMPORARY VIEW t3 AS SELECT * FROM VALUES (1), (1) AS GROUPING(a);
CREATE TEMPORARY VIEW t4 AS SELECT * FROM VALUES (1), (1) AS GROUPING(a);

CREATE TEMPORARY VIEW ta AS
SELECT a, 'a' AS tag FROM t1
UNION ALL
SELECT a, 'b' AS tag FROM t2;

CREATE TEMPORARY VIEW tb AS
SELECT a, 'a' AS tag FROM t3
UNION ALL
SELECT a, 'b' AS tag FROM t4;

-- SPARK-19766 Constant alias columns in INNER JOIN should not be folded by FoldablePropagation rule
SELECT tb.* FROM ta INNER JOIN tb ON ta.a = tb.a AND ta.tag = tb.tag;
-- Tests different scenarios of except operation
create temporary view t1 as select * from values
  ("one", 1),
  ("two", 2),
  ("three", 3),
  ("one", NULL)
  as t1(k, v);

create temporary view t2 as select * from values
  ("one", 1),
  ("two", 22),
  ("one", 5),
  ("one", NULL),
  (NULL, 5)
  as t2(k, v);


-- Except operation that will be replaced by left anti join
SELECT * FROM t1 EXCEPT SELECT * FROM t2;


-- Except operation that will be replaced by Filter: SPARK-22181
SELECT * FROM t1 EXCEPT SELECT * FROM t1 where v <> 1 and v <> 2;


-- Except operation that will be replaced by Filter: SPARK-22181
SELECT * FROM t1 where v <> 1 and v <> 22 EXCEPT SELECT * FROM t1 where v <> 2 and v >= 3;


-- Except operation that will be replaced by Filter: SPARK-22181
SELECT t1.* FROM t1, t2 where t1.k = t2.k
EXCEPT
SELECT t1.* FROM t1, t2 where t1.k = t2.k and t1.k != 'one';


-- Except operation that will be replaced by left anti join
SELECT * FROM t2 where v >= 1 and v <> 22 EXCEPT SELECT * FROM t1;


-- Except operation that will be replaced by left anti join
SELECT (SELECT min(k) FROM t2 WHERE t2.k = t1.k) min_t2 FROM t1
MINUS
SELECT (SELECT min(k) FROM t2) abs_min_t2 FROM t1 WHERE  t1.k = 'one';


-- Except operation that will be replaced by left anti join
SELECT t1.k
FROM   t1
WHERE  t1.v <= (SELECT   max(t2.v)
                FROM     t2
                WHERE    t2.k = t1.k)
MINUS
SELECT t1.k
FROM   t1
WHERE  t1.v >= (SELECT   min(t2.v)
                FROM     t2
                WHERE    t2.k = t1.k);
CREATE TEMPORARY VIEW tab1 AS SELECT * FROM VALUES
    (0), (1), (2), (2), (2), (2), (3), (null), (null) AS tab1(c1);
CREATE TEMPORARY VIEW tab2 AS SELECT * FROM VALUES
    (1), (2), (2), (3), (5), (5), (null) AS tab2(c1);
CREATE TEMPORARY VIEW tab3 AS SELECT * FROM VALUES
    (1, 2), 
    (1, 2),
    (1, 3),
    (2, 3),
    (2, 2)
    AS tab3(k, v);
CREATE TEMPORARY VIEW tab4 AS SELECT * FROM VALUES
    (1, 2), 
    (2, 3),
    (2, 2),
    (2, 2),
    (2, 20)
    AS tab4(k, v);

-- Basic EXCEPT ALL
SELECT * FROM tab1
EXCEPT ALL
SELECT * FROM tab2;

-- MINUS ALL (synonym for EXCEPT)
SELECT * FROM tab1
MINUS ALL
SELECT * FROM tab2;

-- EXCEPT ALL same table in both branches
SELECT * FROM tab1
EXCEPT ALL
SELECT * FROM tab2 WHERE c1 IS NOT NULL;

-- Empty left relation
SELECT * FROM tab1 WHERE c1 > 5
EXCEPT ALL
SELECT * FROM tab2;

-- Empty right relation
SELECT * FROM tab1
EXCEPT ALL
SELECT * FROM tab2 WHERE c1 > 6;

-- Type Coerced ExceptAll
SELECT * FROM tab1
EXCEPT ALL
SELECT CAST(1 AS BIGINT);

-- Error as types of two side are not compatible
SELECT * FROM tab1
EXCEPT ALL
SELECT array(1);

-- Basic
SELECT * FROM tab3
EXCEPT ALL
SELECT * FROM tab4;

-- Basic
SELECT * FROM tab4
EXCEPT ALL
SELECT * FROM tab3;

-- EXCEPT ALL + INTERSECT
SELECT * FROM tab4
EXCEPT ALL
SELECT * FROM tab3
INTERSECT DISTINCT
SELECT * FROM tab4;

-- EXCEPT ALL + EXCEPT
SELECT * FROM tab4
EXCEPT ALL
SELECT * FROM tab3
EXCEPT DISTINCT
SELECT * FROM tab4;

-- Chain of set operations
SELECT * FROM tab3
EXCEPT ALL
SELECT * FROM tab4
UNION ALL
SELECT * FROM tab3
EXCEPT DISTINCT
SELECT * FROM tab4;

-- Mismatch on number of columns across both branches
SELECT k FROM tab3
EXCEPT ALL
SELECT k, v FROM tab4;

-- Chain of set operations
SELECT * FROM tab3
EXCEPT ALL
SELECT * FROM tab4
UNION
SELECT * FROM tab3
EXCEPT DISTINCT
SELECT * FROM tab4;

-- Using MINUS ALL
SELECT * FROM tab3
MINUS ALL
SELECT * FROM tab4
UNION
SELECT * FROM tab3
MINUS DISTINCT
SELECT * FROM tab4;

-- Chain of set operations
SELECT * FROM tab3
EXCEPT ALL
SELECT * FROM tab4
EXCEPT DISTINCT
SELECT * FROM tab3
EXCEPT DISTINCT
SELECT * FROM tab4;

-- Join under except all. Should produce empty resultset since both left and right sets 
-- are same.
SELECT * 
FROM   (SELECT tab3.k, 
               tab4.v 
        FROM   tab3 
               JOIN tab4 
                 ON tab3.k = tab4.k)
EXCEPT ALL 
SELECT * 
FROM   (SELECT tab3.k, 
               tab4.v 
        FROM   tab3 
               JOIN tab4 
                 ON tab3.k = tab4.k);

-- Join under except all (2)
SELECT * 
FROM   (SELECT tab3.k, 
               tab4.v 
        FROM   tab3 
               JOIN tab4 
                 ON tab3.k = tab4.k) 
EXCEPT ALL 
SELECT * 
FROM   (SELECT tab4.v AS k, 
               tab3.k AS v 
        FROM   tab3 
               JOIN tab4 
                 ON tab3.k = tab4.k);

-- Group by under ExceptAll
SELECT v FROM tab3 GROUP BY v
EXCEPT ALL
SELECT k FROM tab4 GROUP BY k;

-- Clean-up 
DROP VIEW IF EXISTS tab1;
DROP VIEW IF EXISTS tab2;
DROP VIEW IF EXISTS tab3;
DROP VIEW IF EXISTS tab4;
-- Negative testcases for tablesample
CREATE DATABASE mydb1;
USE mydb1;
CREATE TABLE t1 USING parquet AS SELECT 1 AS i1;

-- Negative tests: negative percentage
SELECT mydb1.t1 FROM t1 TABLESAMPLE (-1 PERCENT);

-- Negative tests:  percentage over 100
-- The TABLESAMPLE clause samples without replacement, so the value of PERCENT must not exceed 100
SELECT mydb1.t1 FROM t1 TABLESAMPLE (101 PERCENT);

-- reset
DROP DATABASE mydb1 CASCADE;
-- from_csv
select from_csv('1, 3.14', 'a INT, f FLOAT');
select from_csv('26/08/2015', 'time Timestamp', map('timestampFormat', 'dd/MM/yyyy'));
-- Check if errors handled
select from_csv('1', 1);
select from_csv('1', 'a InvalidType');
select from_csv('1', 'a INT', named_struct('mode', 'PERMISSIVE'));
select from_csv('1', 'a INT', map('mode', 1));
select from_csv();
-- infer schema of json literal
select from_csv('1,abc', schema_of_csv('1,abc'));
select schema_of_csv('1|abc', map('delimiter', '|'));
select schema_of_csv(null);
CREATE TEMPORARY VIEW csvTable(csvField, a) AS SELECT * FROM VALUES ('1,abc', 'a');
SELECT schema_of_csv(csvField) FROM csvTable;
-- Clean up
DROP VIEW IF EXISTS csvTable;
-- to_csv
select to_csv(named_struct('a', 1, 'b', 2));
select to_csv(named_struct('time', to_timestamp('2015-08-26', 'yyyy-MM-dd')), map('timestampFormat', 'dd/MM/yyyy'));
-- Check if errors handled
select to_csv(named_struct('a', 1, 'b', 2), named_struct('mode', 'PERMISSIVE'));
select to_csv(named_struct('a', 1, 'b', 2), map('mode', 1));
create temporary view hav as select * from values
  ("one", 1),
  ("two", 2),
  ("three", 3),
  ("one", 5)
  as hav(k, v);

-- having clause
SELECT k, sum(v) FROM hav GROUP BY k HAVING sum(v) > 2;

-- having condition contains grouping column
SELECT count(k) FROM hav GROUP BY v + 1 HAVING v + 1 = 2;

-- SPARK-11032: resolve having correctly
SELECT MIN(t.v) FROM (SELECT * FROM hav WHERE v > 0) t HAVING(COUNT(1) > 0);

-- SPARK-20329: make sure we handle timezones correctly
SELECT a + b FROM VALUES (1L, 2), (3L, 4) AS T(a, b) GROUP BY a + b HAVING a + b > 1;
-- Test data.
CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES
(1, 1), (1, 2), (2, 1), (2, 2), (3, 1), (3, 2), (null, 1), (3, null), (null, null)
AS testData(a, b);

-- Aggregate with empty GroupBy expressions.
SELECT a, COUNT(b) FROM testData;
SELECT COUNT(a), COUNT(b) FROM testData;

-- Aggregate with non-empty GroupBy expressions.
SELECT a, COUNT(b) FROM testData GROUP BY a;
SELECT a, COUNT(b) FROM testData GROUP BY b;
SELECT COUNT(a), COUNT(b) FROM testData GROUP BY a;

-- Aggregate grouped by literals.
SELECT 'foo', COUNT(a) FROM testData GROUP BY 1;

-- Aggregate grouped by literals (whole stage code generation).
SELECT 'foo' FROM testData WHERE a = 0 GROUP BY 1;

-- Aggregate grouped by literals (hash aggregate).
SELECT 'foo', APPROX_COUNT_DISTINCT(a) FROM testData WHERE a = 0 GROUP BY 1;

-- Aggregate grouped by literals (sort aggregate).
SELECT 'foo', MAX(STRUCT(a)) FROM testData WHERE a = 0 GROUP BY 1;

-- Aggregate with complex GroupBy expressions.
SELECT a + b, COUNT(b) FROM testData GROUP BY a + b;
SELECT a + 2, COUNT(b) FROM testData GROUP BY a + 1;
SELECT a + 1 + 1, COUNT(b) FROM testData GROUP BY a + 1;

-- Aggregate with nulls.
SELECT SKEWNESS(a), KURTOSIS(a), MIN(a), MAX(a), AVG(a), VARIANCE(a), STDDEV(a), SUM(a), COUNT(a)
FROM testData;

-- Aggregate with foldable input and multiple distinct groups.
SELECT COUNT(DISTINCT b), COUNT(DISTINCT b, c) FROM (SELECT 1 AS a, 2 AS b, 3 AS c) GROUP BY a;

-- Aliases in SELECT could be used in GROUP BY
SELECT a AS k, COUNT(b) FROM testData GROUP BY k;
SELECT a AS k, COUNT(b) FROM testData GROUP BY k HAVING k > 1;

-- Aggregate functions cannot be used in GROUP BY
SELECT COUNT(b) AS k FROM testData GROUP BY k;

-- Test data.
CREATE OR REPLACE TEMPORARY VIEW testDataHasSameNameWithAlias AS SELECT * FROM VALUES
(1, 1, 3), (1, 2, 1) AS testDataHasSameNameWithAlias(k, a, v);
SELECT k AS a, COUNT(v) FROM testDataHasSameNameWithAlias GROUP BY a;

-- turn off group by aliases
set spark.sql.groupByAliases=false;

-- Check analysis exceptions
SELECT a AS k, COUNT(b) FROM testData GROUP BY k;

-- Aggregate with empty input and non-empty GroupBy expressions.
SELECT a, COUNT(1) FROM testData WHERE false GROUP BY a;

-- Aggregate with empty input and empty GroupBy expressions.
SELECT COUNT(1) FROM testData WHERE false;
SELECT 1 FROM (SELECT COUNT(1) FROM testData WHERE false) t;

-- Aggregate with empty GroupBy expressions and filter on top
SELECT 1 from (
  SELECT 1 AS z,
  MIN(a.x)
  FROM (select 1 as x) a
  WHERE false
) b
where b.z != b.z;

-- SPARK-24369 multiple distinct aggregations having the same argument set
SELECT corr(DISTINCT x, y), corr(DISTINCT y, x), count(*)
  FROM (VALUES (1, 1), (2, 2), (2, 2)) t(x, y);

-- SPARK-25708 HAVING without GROUP BY means global aggregate
SELECT 1 FROM range(10) HAVING true;

SELECT 1 FROM range(10) HAVING MAX(id) > 0;

SELECT id FROM range(10) HAVING id > 0;

-- Test data
CREATE OR REPLACE TEMPORARY VIEW test_agg AS SELECT * FROM VALUES
  (1, true), (1, false),
  (2, true),
  (3, false), (3, null),
  (4, null), (4, null),
  (5, null), (5, true), (5, false) AS test_agg(k, v);

-- empty table
SELECT every(v), some(v), any(v) FROM test_agg WHERE 1 = 0;

-- all null values
SELECT every(v), some(v), any(v) FROM test_agg WHERE k = 4;

-- aggregates are null Filtering
SELECT every(v), some(v), any(v) FROM test_agg WHERE k = 5;

-- group by
SELECT k, every(v), some(v), any(v) FROM test_agg GROUP BY k;

-- having
SELECT k, every(v) FROM test_agg GROUP BY k HAVING every(v) = false;
SELECT k, every(v) FROM test_agg GROUP BY k HAVING every(v) IS NULL;

-- basic subquery path to make sure rewrite happens in both parent and child plans.
SELECT k,
       Every(v) AS every
FROM   test_agg
WHERE  k = 2
       AND v IN (SELECT Any(v)
                 FROM   test_agg
                 WHERE  k = 1)
GROUP  BY k;

-- basic subquery path to make sure rewrite happens in both parent and child plans.
SELECT k,
       Every(v) AS every
FROM   test_agg
WHERE  k = 2
       AND v IN (SELECT Every(v)
                 FROM   test_agg
                 WHERE  k = 1)
GROUP  BY k;

-- input type checking Int
SELECT every(1);

-- input type checking Short
SELECT some(1S);

-- input type checking Long
SELECT any(1L);

-- input type checking String
SELECT every("true");

-- every/some/any aggregates are supported as windows expression.
SELECT k, v, every(v) OVER (PARTITION BY k ORDER BY v) FROM test_agg;
SELECT k, v, some(v) OVER (PARTITION BY k ORDER BY v) FROM test_agg;
SELECT k, v, any(v) OVER (PARTITION BY k ORDER BY v) FROM test_agg;

-- Having referencing aggregate expressions is ok.
SELECT count(*) FROM test_agg HAVING count(*) > 1L;
SELECT k, max(v) FROM test_agg GROUP BY k HAVING max(v) = true;

-- Aggrgate expressions can be referenced through an alias
SELECT * FROM (SELECT COUNT(*) AS cnt FROM test_agg) WHERE cnt > 1L;

-- Error when aggregate expressions are in where clause directly
SELECT count(*) FROM test_agg WHERE count(*) > 1L;
SELECT count(*) FROM test_agg WHERE count(*) + 1L > 1L;
SELECT count(*) FROM test_agg WHERE k = 1 or k = 2 or count(*) + 1L > 1L or max(k) > 1;

--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1.0 as a, 0.0 as b;

-- division, remainder and pmod by 0 return NULL
select a / b from t;
select a % b from t;
select pmod(a, b) from t;

-- tests for decimals handling in operations
create table decimals_test(id int, a decimal(38,18), b decimal(38,18)) using parquet;

insert into decimals_test values(1, 100.0, 999.0), (2, 12345.123, 12345.123),
  (3, 0.1234567891011, 1234.1), (4, 123456789123456789.0, 1.123456789123456789);

-- test decimal operations
select id, a+b, a-b, a*b, a/b from decimals_test order by id;

-- test operations between decimals and constants
select id, a*10, b/10 from decimals_test order by id;

-- test operations on constants
select 10.3 * 3.0;
select 10.3000 * 3.0;
select 10.30000 * 30.0;
select 10.300000000000000000 * 3.000000000000000000;
select 10.300000000000000000 * 3.0000000000000000000;
select 2.35E10 * 1.0;

-- arithmetic operations causing an overflow return NULL
select (5e36 + 0.1) + 5e36;
select (-4e36 - 0.1) - 7e36;
select 12345678901234567890.0 * 12345678901234567890.0;
select 1e35 / 0.1;
select 1.2345678901234567890E30 * 1.2345678901234567890E25;

-- arithmetic operations causing a precision loss are truncated
select 12345678912345678912345678912.1234567 + 9999999999999999999999999999999.12345;
select 123456789123456789.1234567890 * 1.123456789123456789;
select 12345678912345.123456789123 / 0.000000012345678;

-- return NULL instead of rounding, according to old Spark versions' behavior
set spark.sql.decimalOperations.allowPrecisionLoss=false;

-- test decimal operations
select id, a+b, a-b, a*b, a/b from decimals_test order by id;

-- test operations between decimals and constants
select id, a*10, b/10 from decimals_test order by id;

-- test operations on constants
select 10.3 * 3.0;
select 10.3000 * 3.0;
select 10.30000 * 30.0;
select 10.300000000000000000 * 3.000000000000000000;
select 10.300000000000000000 * 3.0000000000000000000;
select 2.35E10 * 1.0;

-- arithmetic operations causing an overflow return NULL
select (5e36 + 0.1) + 5e36;
select (-4e36 - 0.1) - 7e36;
select 12345678901234567890.0 * 12345678901234567890.0;
select 1e35 / 0.1;
select 1.2345678901234567890E30 * 1.2345678901234567890E25;

-- arithmetic operations causing a precision loss return NULL
select 12345678912345678912345678912.1234567 + 9999999999999999999999999999999.12345;
select 123456789123456789.1234567890 * 1.123456789123456789;
select 12345678912345.123456789123 / 0.000000012345678;

drop table decimals_test;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT IF(true, cast(1 as tinyint), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as tinyint), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as smallint), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as smallint), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as smallint), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as smallint), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as smallint), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as int), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as int), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as int), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as int), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as int), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as bigint), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as bigint), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as bigint), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as bigint), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as bigint), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as float), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as float), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as float), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as float), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as float), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as double), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as double), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as double), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as double), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as double), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as decimal(10, 0)), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as string), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as string), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as string), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as string), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as string), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast('1' as binary), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as smallint)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as int)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as bigint)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as float)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as double)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as string)) FROM t;
SELECT IF(true, cast('1' as binary), cast('2' as binary)) FROM t;
SELECT IF(true, cast('1' as binary), cast(2 as boolean)) FROM t;
SELECT IF(true, cast('1' as binary), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast('1' as binary), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast(1 as boolean), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as smallint)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as int)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as bigint)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as float)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as double)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as string)) FROM t;
SELECT IF(true, cast(1 as boolean), cast('2' as binary)) FROM t;
SELECT IF(true, cast(1 as boolean), cast(2 as boolean)) FROM t;
SELECT IF(true, cast(1 as boolean), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast(1 as boolean), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as smallint)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as int)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as bigint)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as float)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as double)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as string)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast('2' as binary)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast(2 as boolean)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00.0' as timestamp), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as tinyint)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as smallint)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as int)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as bigint)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as float)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as double)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as decimal(10, 0))) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as string)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast('2' as binary)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast(2 as boolean)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT IF(true, cast('2017-12-12 09:30:00' as date), cast('2017-12-11 09:30:00' as date)) FROM t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT cast(1 as tinyint) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) + cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) + cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) + cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  + cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  + cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) + cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) + cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) - cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) - cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) - cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  - cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  - cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) - cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) - cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017*12*11 09:30:00.0' as timestamp) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017*12*11 09:30:00.0' as timestamp) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017*12*11 09:30:00.0' as timestamp) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017*12*11 09:30:00.0' as timestamp) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017*12*11 09:30:00' as date) * cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017*12*11 09:30:00' as date) * cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017*12*11 09:30:00' as date) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017*12*11 09:30:00' as date) * cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast('2017*12*11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast('2017*12*11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast('2017*12*11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast('2017*12*11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  * cast('2017*12*11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  * cast('2017*12*11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) * cast('2017*12*11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) * cast('2017*12*11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017/12/11 09:30:00.0' as timestamp) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017/12/11 09:30:00.0' as timestamp) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017/12/11 09:30:00.0' as timestamp) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017/12/11 09:30:00.0' as timestamp) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017/12/11 09:30:00' as date) / cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017/12/11 09:30:00' as date) / cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017/12/11 09:30:00' as date) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017/12/11 09:30:00' as date) / cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast('2017/12/11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast('2017/12/11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast('2017/12/11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast('2017/12/11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  / cast('2017/12/11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  / cast('2017/12/11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast('2017/12/11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) / cast('2017/12/11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) % cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) % cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) % cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  % cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  % cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) % cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) % cast('2017-12-11 09:30:00' as date) FROM t;

SELECT pmod(cast(1 as tinyint), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as tinyint), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as tinyint), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as tinyint), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as smallint), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as smallint), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as smallint), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as smallint), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as int), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as int), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as int), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as int), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as bigint), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as bigint), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as bigint), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as bigint), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as float), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as float), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as float), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as float), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as double), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as double), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as double), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as double), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast('1' as binary), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast('1' as binary), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast('1' as binary), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast('1' as binary), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast('2017-12-11 09:30:00.0' as timestamp), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast('2017-12-11 09:30:00.0' as timestamp), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast('2017-12-11 09:30:00.0' as timestamp), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast('2017-12-11 09:30:00.0' as timestamp), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast('2017-12-11 09:30:00' as date), cast(1 as decimal(3, 0))) FROM t;
SELECT pmod(cast('2017-12-11 09:30:00' as date), cast(1 as decimal(5, 0))) FROM t;
SELECT pmod(cast('2017-12-11 09:30:00' as date), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast('2017-12-11 09:30:00' as date), cast(1 as decimal(20, 0))) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as tinyint)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as tinyint)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as tinyint)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as tinyint)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as smallint)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as smallint)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as smallint)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as smallint)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as int)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as int)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as int)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as int)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as bigint)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as bigint)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as bigint)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as bigint)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as float)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as float)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as float)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as float)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as double)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as double)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as double)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as double)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as decimal(10, 0))) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as decimal(10, 0))) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as string)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as string)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as string)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as string)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast('1' as binary)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast('1' as binary)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast('1' as binary)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast('1' as binary)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast(1 as boolean)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast(1 as boolean)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast(1 as boolean)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast(1 as boolean)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;

SELECT pmod(cast(1 as decimal(3, 0)) , cast('2017-12-11 09:30:00' as date)) FROM t;
SELECT pmod(cast(1 as decimal(5, 0)) , cast('2017-12-11 09:30:00' as date)) FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), cast('2017-12-11 09:30:00' as date)) FROM t;
SELECT pmod(cast(1 as decimal(20, 0)), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as tinyint) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) = cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) = cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) = cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  = cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  = cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) = cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) = cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) <=> cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <=> cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <=> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  <=> cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  <=> cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) <=> cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) <=> cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) < cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) < cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) < cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  < cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  < cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) < cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) <= cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <= cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  <= cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  <= cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) <= cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) > cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) > cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) > cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  > cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  > cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) > cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) >= cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) >= cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) >= cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  >= cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  >= cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) >= cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as tinyint) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as tinyint) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as smallint) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as smallint) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as smallint) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as int) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as int) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as int) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as bigint) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as bigint) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as bigint) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as float) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as float) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as float) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as double) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as double) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as double) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(10, 0)) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast('1' as binary) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast('1' as binary) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast('1' as binary) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) <> cast(1 as decimal(3, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <> cast(1 as decimal(5, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <> cast(1 as decimal(20, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as tinyint) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as smallint) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as int) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as int) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as int) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as bigint) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as float) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as float) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as float) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as double) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as double) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as double) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as decimal(10, 0)) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as string) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as string) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as string) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast('1' as binary) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast('1' as binary) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast('1' as binary) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast(1 as boolean) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;

SELECT cast(1 as decimal(3, 0))  <> cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(5, 0))  <> cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast('2017-12-11 09:30:00' as date) FROM t;
SELECT cast(1 as decimal(20, 0)) <> cast('2017-12-11 09:30:00' as date) FROM t;
-- Mixed inputs (output type is string)
SELECT elt(2, col1, col2, col3, col4, col5) col
FROM (
  SELECT
    'prefix_' col1,
    id col2,
    string(id + 1) col3,
    encode(string(id + 2), 'utf-8') col4,
    CAST(id AS DOUBLE) col5
  FROM range(10)
);

SELECT elt(3, col1, col2, col3, col4) col
FROM (
  SELECT
    string(id) col1,
    string(id + 1) col2,
    encode(string(id + 2), 'utf-8') col3,
    encode(string(id + 3), 'utf-8') col4
  FROM range(10)
);

-- turn on eltOutputAsString
set spark.sql.function.eltOutputAsString=true;

SELECT elt(1, col1, col2) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2
  FROM range(10)
);

-- turn off eltOutputAsString
set spark.sql.function.eltOutputAsString=false;

-- Elt binary inputs (output type is binary)
SELECT elt(2, col1, col2) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2
  FROM range(10)
);
CREATE TEMPORARY VIEW various_maps AS SELECT * FROM VALUES (
  map(true, false), map(false, true),
  map(1Y, 2Y), map(3Y, 4Y),
  map(1S, 2S), map(3S, 4S),
  map(4, 6), map(7, 8),
  map(6L, 7L), map(8L, 9L),
  map(9223372036854775809, 9223372036854775808), map(9223372036854775808, 9223372036854775809),  
  map(1.0D, 2.0D), map(3.0D, 4.0D),
  map(float(1.0D), float(2.0D)), map(float(3.0D), float(4.0D)),
  map(date '2016-03-14', date '2016-03-13'), map(date '2016-03-12', date '2016-03-11'),
  map(timestamp '2016-11-15 20:54:00.000', timestamp '2016-11-12 20:54:00.000'),
  map(timestamp '2016-11-11 20:54:00.000', timestamp '2016-11-09 20:54:00.000'),
  map('a', 'b'), map('c', 'd'),
  map(array('a', 'b'), array('c', 'd')), map(array('e'), array('f')),
  map(struct('a', 1), struct('b', 2)), map(struct('c', 3), struct('d', 4)),
  map('a', 1), map('c', 2),
  map(1, 'a'), map(2, 'c')
) AS various_maps (
  boolean_map1, boolean_map2,
  tinyint_map1, tinyint_map2,
  smallint_map1, smallint_map2,
  int_map1, int_map2,
  bigint_map1, bigint_map2,
  decimal_map1, decimal_map2,
  double_map1, double_map2,
  float_map1, float_map2,
  date_map1, date_map2,
  timestamp_map1,
  timestamp_map2,
  string_map1, string_map2,
  array_map1, array_map2,
  struct_map1, struct_map2,
  string_int_map1, string_int_map2,
  int_string_map1, int_string_map2
);

-- Concatenate maps of the same type
SELECT
    map_concat(boolean_map1, boolean_map2) boolean_map,
    map_concat(tinyint_map1, tinyint_map2) tinyint_map,
    map_concat(smallint_map1, smallint_map2) smallint_map,
    map_concat(int_map1, int_map2) int_map,
    map_concat(bigint_map1, bigint_map2) bigint_map,
    map_concat(decimal_map1, decimal_map2) decimal_map,
    map_concat(float_map1, float_map2) float_map,
    map_concat(double_map1, double_map2) double_map,
    map_concat(date_map1, date_map2) date_map,
    map_concat(timestamp_map1, timestamp_map2) timestamp_map,
    map_concat(string_map1, string_map2) string_map,
    map_concat(array_map1, array_map2) array_map,
    map_concat(struct_map1, struct_map2) struct_map,
    map_concat(string_int_map1, string_int_map2) string_int_map,
    map_concat(int_string_map1, int_string_map2) int_string_map
FROM various_maps;

-- Concatenate maps of different types
SELECT
    map_concat(tinyint_map1, smallint_map2) ts_map,
    map_concat(smallint_map1, int_map2) si_map,
    map_concat(int_map1, bigint_map2) ib_map,
    map_concat(bigint_map1, decimal_map2) bd_map,
    map_concat(decimal_map1, float_map2) df_map,
    map_concat(string_map1, date_map2) std_map,
    map_concat(timestamp_map1, string_map2) tst_map,
    map_concat(string_map1, int_map2) sti_map,
    map_concat(int_string_map1, tinyint_map2) istt_map
FROM various_maps;

-- Concatenate map of incompatible types 1
SELECT
    map_concat(tinyint_map1, array_map1) tm_map
FROM various_maps;

-- Concatenate map of incompatible types 2
SELECT
    map_concat(boolean_map1, int_map2) bi_map
FROM various_maps;

-- Concatenate map of incompatible types 3
SELECT
    map_concat(int_map1, struct_map2) is_map
FROM various_maps;

-- Concatenate map of incompatible types 4
SELECT
    map_concat(struct_map1, array_map2) ma_map
FROM various_maps;

-- Concatenate map of incompatible types 5
SELECT
    map_concat(int_map1, array_map2) ms_map
FROM various_maps;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

-- Binary arithmetic
SELECT '1' + cast(1 as tinyint)                         FROM t;
SELECT '1' + cast(1 as smallint)                        FROM t;
SELECT '1' + cast(1 as int)                             FROM t;
SELECT '1' + cast(1 as bigint)                          FROM t;
SELECT '1' + cast(1 as float)                           FROM t;
SELECT '1' + cast(1 as double)                          FROM t;
SELECT '1' + cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' + '1'                                        FROM t;
SELECT '1' + cast('1' as binary)                        FROM t;
SELECT '1' + cast(1 as boolean)                         FROM t;
SELECT '1' + cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' + cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' - cast(1 as tinyint)                         FROM t;
SELECT '1' - cast(1 as smallint)                        FROM t;
SELECT '1' - cast(1 as int)                             FROM t;
SELECT '1' - cast(1 as bigint)                          FROM t;
SELECT '1' - cast(1 as float)                           FROM t;
SELECT '1' - cast(1 as double)                          FROM t;
SELECT '1' - cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' - '1'                                        FROM t;
SELECT '1' - cast('1' as binary)                        FROM t;
SELECT '1' - cast(1 as boolean)                         FROM t;
SELECT '1' - cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' - cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' * cast(1 as tinyint)                         FROM t;
SELECT '1' * cast(1 as smallint)                        FROM t;
SELECT '1' * cast(1 as int)                             FROM t;
SELECT '1' * cast(1 as bigint)                          FROM t;
SELECT '1' * cast(1 as float)                           FROM t;
SELECT '1' * cast(1 as double)                          FROM t;
SELECT '1' * cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' * '1'                                        FROM t;
SELECT '1' * cast('1' as binary)                        FROM t;
SELECT '1' * cast(1 as boolean)                         FROM t;
SELECT '1' * cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' * cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' / cast(1 as tinyint)                         FROM t;
SELECT '1' / cast(1 as smallint)                        FROM t;
SELECT '1' / cast(1 as int)                             FROM t;
SELECT '1' / cast(1 as bigint)                          FROM t;
SELECT '1' / cast(1 as float)                           FROM t;
SELECT '1' / cast(1 as double)                          FROM t;
SELECT '1' / cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' / '1'                                        FROM t;
SELECT '1' / cast('1' as binary)                        FROM t;
SELECT '1' / cast(1 as boolean)                         FROM t;
SELECT '1' / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' / cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' % cast(1 as tinyint)                         FROM t;
SELECT '1' % cast(1 as smallint)                        FROM t;
SELECT '1' % cast(1 as int)                             FROM t;
SELECT '1' % cast(1 as bigint)                          FROM t;
SELECT '1' % cast(1 as float)                           FROM t;
SELECT '1' % cast(1 as double)                          FROM t;
SELECT '1' % cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' % '1'                                        FROM t;
SELECT '1' % cast('1' as binary)                        FROM t;
SELECT '1' % cast(1 as boolean)                         FROM t;
SELECT '1' % cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' % cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT pmod('1', cast(1 as tinyint))                         FROM t;
SELECT pmod('1', cast(1 as smallint))                        FROM t;
SELECT pmod('1', cast(1 as int))                             FROM t;
SELECT pmod('1', cast(1 as bigint))                          FROM t;
SELECT pmod('1', cast(1 as float))                           FROM t;
SELECT pmod('1', cast(1 as double))                          FROM t;
SELECT pmod('1', cast(1 as decimal(10, 0)))                  FROM t;
SELECT pmod('1', '1')                                        FROM t;
SELECT pmod('1', cast('1' as binary))                        FROM t;
SELECT pmod('1', cast(1 as boolean))                         FROM t;
SELECT pmod('1', cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT pmod('1', cast('2017-12-11 09:30:00' as date))        FROM t;

SELECT cast(1 as tinyint)                         + '1' FROM t;
SELECT cast(1 as smallint)                        + '1' FROM t;
SELECT cast(1 as int)                             + '1' FROM t;
SELECT cast(1 as bigint)                          + '1' FROM t;
SELECT cast(1 as float)                           + '1' FROM t;
SELECT cast(1 as double)                          + '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  + '1' FROM t;
SELECT cast('1' as binary)                        + '1' FROM t;
SELECT cast(1 as boolean)                         + '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) + '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        + '1' FROM t;

SELECT cast(1 as tinyint)                         - '1' FROM t;
SELECT cast(1 as smallint)                        - '1' FROM t;
SELECT cast(1 as int)                             - '1' FROM t;
SELECT cast(1 as bigint)                          - '1' FROM t;
SELECT cast(1 as float)                           - '1' FROM t;
SELECT cast(1 as double)                          - '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  - '1' FROM t;
SELECT cast('1' as binary)                        - '1' FROM t;
SELECT cast(1 as boolean)                         - '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) - '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        - '1' FROM t;

SELECT cast(1 as tinyint)                         * '1' FROM t;
SELECT cast(1 as smallint)                        * '1' FROM t;
SELECT cast(1 as int)                             * '1' FROM t;
SELECT cast(1 as bigint)                          * '1' FROM t;
SELECT cast(1 as float)                           * '1' FROM t;
SELECT cast(1 as double)                          * '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  * '1' FROM t;
SELECT cast('1' as binary)                        * '1' FROM t;
SELECT cast(1 as boolean)                         * '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) * '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        * '1' FROM t;

SELECT cast(1 as tinyint)                         / '1' FROM t;
SELECT cast(1 as smallint)                        / '1' FROM t;
SELECT cast(1 as int)                             / '1' FROM t;
SELECT cast(1 as bigint)                          / '1' FROM t;
SELECT cast(1 as float)                           / '1' FROM t;
SELECT cast(1 as double)                          / '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  / '1' FROM t;
SELECT cast('1' as binary)                        / '1' FROM t;
SELECT cast(1 as boolean)                         / '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        / '1' FROM t;

SELECT cast(1 as tinyint)                         % '1' FROM t;
SELECT cast(1 as smallint)                        % '1' FROM t;
SELECT cast(1 as int)                             % '1' FROM t;
SELECT cast(1 as bigint)                          % '1' FROM t;
SELECT cast(1 as float)                           % '1' FROM t;
SELECT cast(1 as double)                          % '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  % '1' FROM t;
SELECT cast('1' as binary)                        % '1' FROM t;
SELECT cast(1 as boolean)                         % '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) % '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        % '1' FROM t;

SELECT pmod(cast(1 as tinyint), '1')                         FROM t;
SELECT pmod(cast(1 as smallint), '1')                        FROM t;
SELECT pmod(cast(1 as int), '1')                             FROM t;
SELECT pmod(cast(1 as bigint), '1')                          FROM t;
SELECT pmod(cast(1 as float), '1')                           FROM t;
SELECT pmod(cast(1 as double), '1')                          FROM t;
SELECT pmod(cast(1 as decimal(10, 0)), '1')                  FROM t;
SELECT pmod(cast('1' as binary), '1')                        FROM t;
SELECT pmod(cast(1 as boolean), '1')                         FROM t;
SELECT pmod(cast('2017-12-11 09:30:00.0' as timestamp), '1') FROM t;
SELECT pmod(cast('2017-12-11 09:30:00' as date), '1')        FROM t;

-- Equality
SELECT '1' = cast(1 as tinyint)                         FROM t;
SELECT '1' = cast(1 as smallint)                        FROM t;
SELECT '1' = cast(1 as int)                             FROM t;
SELECT '1' = cast(1 as bigint)                          FROM t;
SELECT '1' = cast(1 as float)                           FROM t;
SELECT '1' = cast(1 as double)                          FROM t;
SELECT '1' = cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' = '1'                                        FROM t;
SELECT '1' = cast('1' as binary)                        FROM t;
SELECT '1' = cast(1 as boolean)                         FROM t;
SELECT '1' = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' = cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT cast(1 as tinyint)                         = '1' FROM t;
SELECT cast(1 as smallint)                        = '1' FROM t;
SELECT cast(1 as int)                             = '1' FROM t;
SELECT cast(1 as bigint)                          = '1' FROM t;
SELECT cast(1 as float)                           = '1' FROM t;
SELECT cast(1 as double)                          = '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  = '1' FROM t;
SELECT cast('1' as binary)                        = '1' FROM t;
SELECT cast(1 as boolean)                         = '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) = '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        = '1' FROM t;

SELECT '1' <=> cast(1 as tinyint)                         FROM t;
SELECT '1' <=> cast(1 as smallint)                        FROM t;
SELECT '1' <=> cast(1 as int)                             FROM t;
SELECT '1' <=> cast(1 as bigint)                          FROM t;
SELECT '1' <=> cast(1 as float)                           FROM t;
SELECT '1' <=> cast(1 as double)                          FROM t;
SELECT '1' <=> cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' <=> '1'                                        FROM t;
SELECT '1' <=> cast('1' as binary)                        FROM t;
SELECT '1' <=> cast(1 as boolean)                         FROM t;
SELECT '1' <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' <=> cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT cast(1 as tinyint)                         <=> '1' FROM t;
SELECT cast(1 as smallint)                        <=> '1' FROM t;
SELECT cast(1 as int)                             <=> '1' FROM t;
SELECT cast(1 as bigint)                          <=> '1' FROM t;
SELECT cast(1 as float)                           <=> '1' FROM t;
SELECT cast(1 as double)                          <=> '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  <=> '1' FROM t;
SELECT cast('1' as binary)                        <=> '1' FROM t;
SELECT cast(1 as boolean)                         <=> '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        <=> '1' FROM t;

-- Binary comparison
SELECT '1' < cast(1 as tinyint)                         FROM t;
SELECT '1' < cast(1 as smallint)                        FROM t;
SELECT '1' < cast(1 as int)                             FROM t;
SELECT '1' < cast(1 as bigint)                          FROM t;
SELECT '1' < cast(1 as float)                           FROM t;
SELECT '1' < cast(1 as double)                          FROM t;
SELECT '1' < cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' < '1'                                        FROM t;
SELECT '1' < cast('1' as binary)                        FROM t;
SELECT '1' < cast(1 as boolean)                         FROM t;
SELECT '1' < cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' < cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' <= cast(1 as tinyint)                         FROM t;
SELECT '1' <= cast(1 as smallint)                        FROM t;
SELECT '1' <= cast(1 as int)                             FROM t;
SELECT '1' <= cast(1 as bigint)                          FROM t;
SELECT '1' <= cast(1 as float)                           FROM t;
SELECT '1' <= cast(1 as double)                          FROM t;
SELECT '1' <= cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' <= '1'                                        FROM t;
SELECT '1' <= cast('1' as binary)                        FROM t;
SELECT '1' <= cast(1 as boolean)                         FROM t;
SELECT '1' <= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' <= cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' > cast(1 as tinyint)                         FROM t;
SELECT '1' > cast(1 as smallint)                        FROM t;
SELECT '1' > cast(1 as int)                             FROM t;
SELECT '1' > cast(1 as bigint)                          FROM t;
SELECT '1' > cast(1 as float)                           FROM t;
SELECT '1' > cast(1 as double)                          FROM t;
SELECT '1' > cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' > '1'                                        FROM t;
SELECT '1' > cast('1' as binary)                        FROM t;
SELECT '1' > cast(1 as boolean)                         FROM t;
SELECT '1' > cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' > cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' >= cast(1 as tinyint)                         FROM t;
SELECT '1' >= cast(1 as smallint)                        FROM t;
SELECT '1' >= cast(1 as int)                             FROM t;
SELECT '1' >= cast(1 as bigint)                          FROM t;
SELECT '1' >= cast(1 as float)                           FROM t;
SELECT '1' >= cast(1 as double)                          FROM t;
SELECT '1' >= cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' >= '1'                                        FROM t;
SELECT '1' >= cast('1' as binary)                        FROM t;
SELECT '1' >= cast(1 as boolean)                         FROM t;
SELECT '1' >= cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' >= cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT '1' <> cast(1 as tinyint)                         FROM t;
SELECT '1' <> cast(1 as smallint)                        FROM t;
SELECT '1' <> cast(1 as int)                             FROM t;
SELECT '1' <> cast(1 as bigint)                          FROM t;
SELECT '1' <> cast(1 as float)                           FROM t;
SELECT '1' <> cast(1 as double)                          FROM t;
SELECT '1' <> cast(1 as decimal(10, 0))                  FROM t;
SELECT '1' <> '1'                                        FROM t;
SELECT '1' <> cast('1' as binary)                        FROM t;
SELECT '1' <> cast(1 as boolean)                         FROM t;
SELECT '1' <> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT '1' <> cast('2017-12-11 09:30:00' as date)        FROM t;

SELECT cast(1 as tinyint)                         < '1' FROM t;
SELECT cast(1 as smallint)                        < '1' FROM t;
SELECT cast(1 as int)                             < '1' FROM t;
SELECT cast(1 as bigint)                          < '1' FROM t;
SELECT cast(1 as float)                           < '1' FROM t;
SELECT cast(1 as double)                          < '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  < '1' FROM t;
SELECT '1'                                        < '1' FROM t;
SELECT cast('1' as binary)                        < '1' FROM t;
SELECT cast(1 as boolean)                         < '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) < '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        < '1' FROM t;

SELECT cast(1 as tinyint)                         <= '1' FROM t;
SELECT cast(1 as smallint)                        <= '1' FROM t;
SELECT cast(1 as int)                             <= '1' FROM t;
SELECT cast(1 as bigint)                          <= '1' FROM t;
SELECT cast(1 as float)                           <= '1' FROM t;
SELECT cast(1 as double)                          <= '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  <= '1' FROM t;
SELECT '1'                                        <= '1' FROM t;
SELECT cast('1' as binary)                        <= '1' FROM t;
SELECT cast(1 as boolean)                         <= '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <= '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        <= '1' FROM t;

SELECT cast(1 as tinyint)                         > '1' FROM t;
SELECT cast(1 as smallint)                        > '1' FROM t;
SELECT cast(1 as int)                             > '1' FROM t;
SELECT cast(1 as bigint)                          > '1' FROM t;
SELECT cast(1 as float)                           > '1' FROM t;
SELECT cast(1 as double)                          > '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  > '1' FROM t;
SELECT '1'                                        > '1' FROM t;
SELECT cast('1' as binary)                        > '1' FROM t;
SELECT cast(1 as boolean)                         > '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) > '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        > '1' FROM t;

SELECT cast(1 as tinyint)                         >= '1' FROM t;
SELECT cast(1 as smallint)                        >= '1' FROM t;
SELECT cast(1 as int)                             >= '1' FROM t;
SELECT cast(1 as bigint)                          >= '1' FROM t;
SELECT cast(1 as float)                           >= '1' FROM t;
SELECT cast(1 as double)                          >= '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  >= '1' FROM t;
SELECT '1'                                        >= '1' FROM t;
SELECT cast('1' as binary)                        >= '1' FROM t;
SELECT cast(1 as boolean)                         >= '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) >= '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        >= '1' FROM t;

SELECT cast(1 as tinyint)                         <> '1' FROM t;
SELECT cast(1 as smallint)                        <> '1' FROM t;
SELECT cast(1 as int)                             <> '1' FROM t;
SELECT cast(1 as bigint)                          <> '1' FROM t;
SELECT cast(1 as float)                           <> '1' FROM t;
SELECT cast(1 as double)                          <> '1' FROM t;
SELECT cast(1 as decimal(10, 0))                  <> '1' FROM t;
SELECT '1'                                        <> '1' FROM t;
SELECT cast('1' as binary)                        <> '1' FROM t;
SELECT cast(1 as boolean)                         <> '1' FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <> '1' FROM t;
SELECT cast('2017-12-11 09:30:00' as date)        <> '1' FROM t;

-- Functions
SELECT abs('1') FROM t;
SELECT sum('1') FROM t;
SELECT avg('1') FROM t;
SELECT stddev_pop('1') FROM t;
SELECT stddev_samp('1') FROM t;
SELECT - '1' FROM t;
SELECT + '1' FROM t;
SELECT var_pop('1') FROM t;
SELECT var_samp('1') FROM t;
SELECT skewness('1') FROM t;
SELECT kurtosis('1') FROM t;
CREATE TEMPORARY VIEW various_maps AS SELECT * FROM VALUES (
  map(true, false),
  map(2Y, 1Y),
  map(2S, 1S),
  map(2, 1),
  map(2L, 1L),
  map(922337203685477897945456575809789456, 922337203685477897945456575809789456),
  map(9.22337203685477897945456575809789456, 9.22337203685477897945456575809789456),
  map(2.0D, 1.0D),
  map(float(2.0), float(1.0)),
  map(date '2016-03-14', date '2016-03-13'),
  map(timestamp '2016-11-15 20:54:00.000', timestamp '2016-11-12 20:54:00.000'),
  map('true', 'false', '2', '1'),
  map('2016-03-14', '2016-03-13'),
  map('2016-11-15 20:54:00.000', '2016-11-12 20:54:00.000'),
  map('922337203685477897945456575809789456', 'text'),
  map(array(1L, 2L), array(1L, 2L)), map(array(1, 2), array(1, 2)),
  map(struct(1S, 2L), struct(1S, 2L)), map(struct(1, 2), struct(1, 2))
) AS various_maps(
  boolean_map,
  tinyint_map,
  smallint_map,
  int_map,
  bigint_map,
  decimal_map1, decimal_map2,
  double_map,
  float_map,
  date_map,
  timestamp_map,
  string_map1, string_map2, string_map3, string_map4,
  array_map1, array_map2,
  struct_map1, struct_map2
);

SELECT map_zip_with(tinyint_map, smallint_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(smallint_map, int_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(int_map, bigint_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(double_map, float_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(decimal_map1, decimal_map2, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(decimal_map1, int_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(decimal_map1, double_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(decimal_map2, int_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(decimal_map2, double_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(string_map1, int_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(string_map2, date_map, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(timestamp_map, string_map3, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(decimal_map1, string_map4, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(array_map1, array_map2, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;

SELECT map_zip_with(struct_map1, struct_map2, (k, v1, v2) -> struct(k, v1, v2)) m
FROM various_maps;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

select cast(1 as tinyint) + interval 2 day;
select cast(1 as smallint) + interval 2 day;
select cast(1 as int) + interval 2 day;
select cast(1 as bigint) + interval 2 day;
select cast(1 as float) + interval 2 day;
select cast(1 as double) + interval 2 day;
select cast(1 as decimal(10, 0)) + interval 2 day;
select cast('2017-12-11' as string) + interval 2 day;
select cast('2017-12-11 09:30:00' as string) + interval 2 day;
select cast('1' as binary) + interval 2 day;
select cast(1 as boolean) + interval 2 day;
select cast('2017-12-11 09:30:00.0' as timestamp) + interval 2 day;
select cast('2017-12-11 09:30:00' as date) + interval 2 day;

select interval 2 day + cast(1 as tinyint);
select interval 2 day + cast(1 as smallint);
select interval 2 day + cast(1 as int);
select interval 2 day + cast(1 as bigint);
select interval 2 day + cast(1 as float);
select interval 2 day + cast(1 as double);
select interval 2 day + cast(1 as decimal(10, 0));
select interval 2 day + cast('2017-12-11' as string);
select interval 2 day + cast('2017-12-11 09:30:00' as string);
select interval 2 day + cast('1' as binary);
select interval 2 day + cast(1 as boolean);
select interval 2 day + cast('2017-12-11 09:30:00.0' as timestamp);
select interval 2 day + cast('2017-12-11 09:30:00' as date);

select cast(1 as tinyint) - interval 2 day;
select cast(1 as smallint) - interval 2 day;
select cast(1 as int) - interval 2 day;
select cast(1 as bigint) - interval 2 day;
select cast(1 as float) - interval 2 day;
select cast(1 as double) - interval 2 day;
select cast(1 as decimal(10, 0)) - interval 2 day;
select cast('2017-12-11' as string) - interval 2 day;
select cast('2017-12-11 09:30:00' as string) - interval 2 day;
select cast('1' as binary) - interval 2 day;
select cast(1 as boolean) - interval 2 day;
select cast('2017-12-11 09:30:00.0' as timestamp) - interval 2 day;
select cast('2017-12-11 09:30:00' as date) - interval 2 day;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as tinyint)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as smallint)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as int)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as bigint)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as float)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as double)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as decimal(10, 0))) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as string)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast('1' as binary)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as boolean)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as tinyint) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as smallint) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as int) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as bigint) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as float) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as double) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as decimal(10, 0)) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as string) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast('1' as binary) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast(1 as boolean) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast('2017-12-11 09:30:00.0' as timestamp) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
SELECT COUNT(*) OVER (PARTITION BY 1 ORDER BY cast('2017-12-11 09:30:00' as date) DESC RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM t;
-- Concatenate mixed inputs (output type is string)
SELECT (col1 || col2 || col3) col
FROM (
  SELECT
    id col1,
    string(id + 1) col2,
    encode(string(id + 2), 'utf-8') col3
  FROM range(10)
);

SELECT ((col1 || col2) || (col3 || col4) || col5) col
FROM (
  SELECT
    'prefix_' col1,
    id col2,
    string(id + 1) col3,
    encode(string(id + 2), 'utf-8') col4,
    CAST(id AS DOUBLE) col5
  FROM range(10)
);

SELECT ((col1 || col2) || (col3 || col4)) col
FROM (
  SELECT
    string(id) col1,
    string(id + 1) col2,
    encode(string(id + 2), 'utf-8') col3,
    encode(string(id + 3), 'utf-8') col4
  FROM range(10)
);

-- turn on concatBinaryAsString
set spark.sql.function.concatBinaryAsString=true;

SELECT (col1 || col2) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2
  FROM range(10)
);

SELECT (col1 || col2 || col3 || col4) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2,
    encode(string(id + 2), 'utf-8') col3,
    encode(string(id + 3), 'utf-8') col4
  FROM range(10)
);

SELECT ((col1 || col2) || (col3 || col4)) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2,
    encode(string(id + 2), 'utf-8') col3,
    encode(string(id + 3), 'utf-8') col4
  FROM range(10)
);

-- turn off concatBinaryAsString
set spark.sql.function.concatBinaryAsString=false;

-- Concatenate binary inputs (output type is binary)
SELECT (col1 || col2) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2
  FROM range(10)
);

SELECT (col1 || col2 || col3 || col4) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2,
    encode(string(id + 2), 'utf-8') col3,
    encode(string(id + 3), 'utf-8') col4
  FROM range(10)
);

SELECT ((col1 || col2) || (col3 || col4)) col
FROM (
  SELECT
    encode(string(id), 'utf-8') col1,
    encode(string(id + 1), 'utf-8') col2,
    encode(string(id + 2), 'utf-8') col3,
    encode(string(id + 3), 'utf-8') col4
  FROM range(10)
);

CREATE TEMPORARY VIEW various_arrays AS SELECT * FROM VALUES (
  array(true, false), array(true),
  array(2Y, 1Y), array(3Y, 4Y),
  array(2S, 1S), array(3S, 4S),
  array(2, 1), array(3, 4),
  array(2L, 1L), array(3L, 4L),
  array(9223372036854775809, 9223372036854775808), array(9223372036854775808, 9223372036854775809),
  array(2.0D, 1.0D), array(3.0D, 4.0D),
  array(float(2.0), float(1.0)), array(float(3.0), float(4.0)),
  array(date '2016-03-14', date '2016-03-13'), array(date '2016-03-12', date '2016-03-11'),
  array(timestamp '2016-11-15 20:54:00.000', timestamp '2016-11-12 20:54:00.000'),
  array(timestamp '2016-11-11 20:54:00.000'),
  array('a', 'b'), array('c', 'd'),
  array(array('a', 'b'), array('c', 'd')), array(array('e'), array('f')),
  array(struct('a', 1), struct('b', 2)), array(struct('c', 3), struct('d', 4)),
  array(map('a', 1), map('b', 2)), array(map('c', 3), map('d', 4))
) AS various_arrays(
  boolean_array1, boolean_array2,
  tinyint_array1, tinyint_array2,
  smallint_array1, smallint_array2,
  int_array1, int_array2,
  bigint_array1, bigint_array2,
  decimal_array1, decimal_array2,
  double_array1, double_array2,
  float_array1, float_array2,
  date_array1, data_array2,
  timestamp_array1, timestamp_array2,
  string_array1, string_array2,
  array_array1, array_array2,
  struct_array1, struct_array2,
  map_array1, map_array2
);

-- Concatenate arrays of the same type
SELECT
    (boolean_array1 || boolean_array2) boolean_array,
    (tinyint_array1 || tinyint_array2) tinyint_array,
    (smallint_array1 || smallint_array2) smallint_array,
    (int_array1 || int_array2) int_array,
    (bigint_array1 || bigint_array2) bigint_array,
    (decimal_array1 || decimal_array2) decimal_array,
    (double_array1 || double_array2) double_array,
    (float_array1 || float_array2) float_array,
    (date_array1 || data_array2) data_array,
    (timestamp_array1 || timestamp_array2) timestamp_array,
    (string_array1 || string_array2) string_array,
    (array_array1 || array_array2) array_array,
    (struct_array1 || struct_array2) struct_array,
    (map_array1 || map_array2) map_array
FROM various_arrays;

-- Concatenate arrays of different types
SELECT
    (tinyint_array1 || smallint_array2) ts_array,
    (smallint_array1 || int_array2) si_array,
    (int_array1 || bigint_array2) ib_array,
    (bigint_array1 || decimal_array2) bd_array,
    (decimal_array1 || double_array2) dd_array,
    (double_array1 || float_array2) df_array,
    (string_array1 || data_array2) std_array,
    (timestamp_array1 || string_array2) tst_array,
    (string_array1 || int_array2) sti_array
FROM various_arrays;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

-- ImplicitTypeCasts

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT 1 + '2' FROM t;
SELECT 1 - '2' FROM t;
SELECT 1 * '2' FROM t;
SELECT 4 / '2' FROM t;
SELECT 1.1 + '2' FROM t;
SELECT 1.1 - '2' FROM t;
SELECT 1.1 * '2' FROM t;
SELECT 4.4 / '2' FROM t;
SELECT 1.1 + '2.2' FROM t;
SELECT 1.1 - '2.2' FROM t;
SELECT 1.1 * '2.2' FROM t;
SELECT 4.4 / '2.2' FROM t;

-- concatenation
SELECT '$' || cast(1 as smallint) || '$' FROM t;
SELECT '$' || 1 || '$' FROM t;
SELECT '$' || cast(1 as bigint) || '$' FROM t;
SELECT '$' || cast(1.1 as float) || '$' FROM t;
SELECT '$' || cast(1.1 as double) || '$' FROM t;
SELECT '$' || 1.1 || '$' FROM t;
SELECT '$' || cast(1.1 as decimal(8,3)) || '$' FROM t;
SELECT '$' || 'abcd' || '$' FROM t;
SELECT '$' || date('1996-09-09') || '$' FROM t;
SELECT '$' || timestamp('1996-09-09 10:11:12.4' )|| '$' FROM t;

-- length functions
SELECT length(cast(1 as smallint)) FROM t;
SELECT length(cast(1 as int)) FROM t;
SELECT length(cast(1 as bigint)) FROM t;
SELECT length(cast(1.1 as float)) FROM t;
SELECT length(cast(1.1 as double)) FROM t;
SELECT length(1.1) FROM t;
SELECT length(cast(1.1 as decimal(8,3))) FROM t;
SELECT length('four') FROM t;
SELECT length(date('1996-09-10')) FROM t;
SELECT length(timestamp('1996-09-10 10:11:12.4')) FROM t;

-- extract
SELECT year( '1996-01-10') FROM t;
SELECT month( '1996-01-10') FROM t;
SELECT day( '1996-01-10') FROM t;
SELECT hour( '10:11:12') FROM t;
SELECT minute( '10:11:12') FROM t;
SELECT second( '10:11:12') FROM t;

-- like
select 1 like '%' FROM t;
select date('1996-09-10') like '19%' FROM t;
select '1' like 1 FROM t;
select '1 ' like 1 FROM t;
select '1996-09-10' like date('1996-09-10') FROM t;
SELECT array_join(array(true, false), ', ');
SELECT array_join(array(2Y, 1Y), ', ');
SELECT array_join(array(2S, 1S), ', ');
SELECT array_join(array(2, 1), ', ');
SELECT array_join(array(2L, 1L), ', ');
SELECT array_join(array(9223372036854775809, 9223372036854775808), ', ');
SELECT array_join(array(2.0D, 1.0D), ', ');
SELECT array_join(array(float(2.0), float(1.0)), ', ');
SELECT array_join(array(date '2016-03-14', date '2016-03-13'), ', ');
SELECT array_join(array(timestamp '2016-11-15 20:54:00.000', timestamp '2016-11-12 20:54:00.000'), ', ');
SELECT array_join(array('a', 'b'), ', ');
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

-- Binary Comparison

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT cast(1 as binary) = '1' FROM t;
SELECT cast(1 as binary) > '2' FROM t;
SELECT cast(1 as binary) >= '2' FROM t;
SELECT cast(1 as binary) < '2' FROM t;
SELECT cast(1 as binary) <= '2' FROM t;
SELECT cast(1 as binary) <> '2' FROM t;
SELECT cast(1 as binary) = cast(null as string) FROM t;
SELECT cast(1 as binary) > cast(null as string) FROM t;
SELECT cast(1 as binary) >= cast(null as string) FROM t;
SELECT cast(1 as binary) < cast(null as string) FROM t;
SELECT cast(1 as binary) <= cast(null as string) FROM t;
SELECT cast(1 as binary) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as binary) FROM t;
SELECT '2' > cast(1 as binary) FROM t;
SELECT '2' >= cast(1 as binary) FROM t;
SELECT '2' < cast(1 as binary) FROM t;
SELECT '2' <= cast(1 as binary) FROM t;
SELECT '2' <> cast(1 as binary) FROM t;
SELECT cast(null as string) = cast(1 as binary) FROM t;
SELECT cast(null as string) > cast(1 as binary) FROM t;
SELECT cast(null as string) >= cast(1 as binary) FROM t;
SELECT cast(null as string) < cast(1 as binary) FROM t;
SELECT cast(null as string) <= cast(1 as binary) FROM t;
SELECT cast(null as string) <> cast(1 as binary) FROM t;
SELECT cast(1 as tinyint) = '1' FROM t;
SELECT cast(1 as tinyint) > '2' FROM t;
SELECT cast(1 as tinyint) >= '2' FROM t;
SELECT cast(1 as tinyint) < '2' FROM t;
SELECT cast(1 as tinyint) <= '2' FROM t;
SELECT cast(1 as tinyint) <> '2' FROM t;
SELECT cast(1 as tinyint) = cast(null as string) FROM t;
SELECT cast(1 as tinyint) > cast(null as string) FROM t;
SELECT cast(1 as tinyint) >= cast(null as string) FROM t;
SELECT cast(1 as tinyint) < cast(null as string) FROM t;
SELECT cast(1 as tinyint) <= cast(null as string) FROM t;
SELECT cast(1 as tinyint) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as tinyint) FROM t;
SELECT '2' > cast(1 as tinyint) FROM t;
SELECT '2' >= cast(1 as tinyint) FROM t;
SELECT '2' < cast(1 as tinyint) FROM t;
SELECT '2' <= cast(1 as tinyint) FROM t;
SELECT '2' <> cast(1 as tinyint) FROM t;
SELECT cast(null as string) = cast(1 as tinyint) FROM t;
SELECT cast(null as string) > cast(1 as tinyint) FROM t;
SELECT cast(null as string) >= cast(1 as tinyint) FROM t;
SELECT cast(null as string) < cast(1 as tinyint) FROM t;
SELECT cast(null as string) <= cast(1 as tinyint) FROM t;
SELECT cast(null as string) <> cast(1 as tinyint) FROM t;
SELECT cast(1 as smallint) = '1' FROM t;
SELECT cast(1 as smallint) > '2' FROM t;
SELECT cast(1 as smallint) >= '2' FROM t;
SELECT cast(1 as smallint) < '2' FROM t;
SELECT cast(1 as smallint) <= '2' FROM t;
SELECT cast(1 as smallint) <> '2' FROM t;
SELECT cast(1 as smallint) = cast(null as string) FROM t;
SELECT cast(1 as smallint) > cast(null as string) FROM t;
SELECT cast(1 as smallint) >= cast(null as string) FROM t;
SELECT cast(1 as smallint) < cast(null as string) FROM t;
SELECT cast(1 as smallint) <= cast(null as string) FROM t;
SELECT cast(1 as smallint) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as smallint) FROM t;
SELECT '2' > cast(1 as smallint) FROM t;
SELECT '2' >= cast(1 as smallint) FROM t;
SELECT '2' < cast(1 as smallint) FROM t;
SELECT '2' <= cast(1 as smallint) FROM t;
SELECT '2' <> cast(1 as smallint) FROM t;
SELECT cast(null as string) = cast(1 as smallint) FROM t;
SELECT cast(null as string) > cast(1 as smallint) FROM t;
SELECT cast(null as string) >= cast(1 as smallint) FROM t;
SELECT cast(null as string) < cast(1 as smallint) FROM t;
SELECT cast(null as string) <= cast(1 as smallint) FROM t;
SELECT cast(null as string) <> cast(1 as smallint) FROM t;
SELECT cast(1 as int) = '1' FROM t;
SELECT cast(1 as int) > '2' FROM t;
SELECT cast(1 as int) >= '2' FROM t;
SELECT cast(1 as int) < '2' FROM t;
SELECT cast(1 as int) <= '2' FROM t;
SELECT cast(1 as int) <> '2' FROM t;
SELECT cast(1 as int) = cast(null as string) FROM t;
SELECT cast(1 as int) > cast(null as string) FROM t;
SELECT cast(1 as int) >= cast(null as string) FROM t;
SELECT cast(1 as int) < cast(null as string) FROM t;
SELECT cast(1 as int) <= cast(null as string) FROM t;
SELECT cast(1 as int) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as int) FROM t;
SELECT '2' > cast(1 as int) FROM t;
SELECT '2' >= cast(1 as int) FROM t;
SELECT '2' < cast(1 as int) FROM t;
SELECT '2' <> cast(1 as int) FROM t;
SELECT '2' <= cast(1 as int) FROM t;
SELECT cast(null as string) = cast(1 as int) FROM t;
SELECT cast(null as string) > cast(1 as int) FROM t;
SELECT cast(null as string) >= cast(1 as int) FROM t;
SELECT cast(null as string) < cast(1 as int) FROM t;
SELECT cast(null as string) <> cast(1 as int) FROM t;
SELECT cast(null as string) <= cast(1 as int) FROM t;
SELECT cast(1 as bigint) = '1' FROM t;
SELECT cast(1 as bigint) > '2' FROM t;
SELECT cast(1 as bigint) >= '2' FROM t;
SELECT cast(1 as bigint) < '2' FROM t;
SELECT cast(1 as bigint) <= '2' FROM t;
SELECT cast(1 as bigint) <> '2' FROM t;
SELECT cast(1 as bigint) = cast(null as string) FROM t;
SELECT cast(1 as bigint) > cast(null as string) FROM t;
SELECT cast(1 as bigint) >= cast(null as string) FROM t;
SELECT cast(1 as bigint) < cast(null as string) FROM t;
SELECT cast(1 as bigint) <= cast(null as string) FROM t;
SELECT cast(1 as bigint) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as bigint) FROM t;
SELECT '2' > cast(1 as bigint) FROM t;
SELECT '2' >= cast(1 as bigint) FROM t;
SELECT '2' < cast(1 as bigint) FROM t;
SELECT '2' <= cast(1 as bigint) FROM t;
SELECT '2' <> cast(1 as bigint) FROM t;
SELECT cast(null as string) = cast(1 as bigint) FROM t;
SELECT cast(null as string) > cast(1 as bigint) FROM t;
SELECT cast(null as string) >= cast(1 as bigint) FROM t;
SELECT cast(null as string) < cast(1 as bigint) FROM t;
SELECT cast(null as string) <= cast(1 as bigint) FROM t;
SELECT cast(null as string) <> cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) = '1' FROM t;
SELECT cast(1 as decimal(10, 0)) > '2' FROM t;
SELECT cast(1 as decimal(10, 0)) >= '2' FROM t;
SELECT cast(1 as decimal(10, 0)) < '2' FROM t;
SELECT cast(1 as decimal(10, 0)) <> '2' FROM t;
SELECT cast(1 as decimal(10, 0)) <= '2' FROM t;
SELECT cast(1 as decimal(10, 0)) = cast(null as string) FROM t;
SELECT cast(1 as decimal(10, 0)) > cast(null as string) FROM t;
SELECT cast(1 as decimal(10, 0)) >= cast(null as string) FROM t;
SELECT cast(1 as decimal(10, 0)) < cast(null as string) FROM t;
SELECT cast(1 as decimal(10, 0)) <> cast(null as string) FROM t;
SELECT cast(1 as decimal(10, 0)) <= cast(null as string) FROM t;
SELECT '1' = cast(1 as decimal(10, 0)) FROM t;
SELECT '2' > cast(1 as decimal(10, 0)) FROM t;
SELECT '2' >= cast(1 as decimal(10, 0)) FROM t;
SELECT '2' < cast(1 as decimal(10, 0)) FROM t;
SELECT '2' <= cast(1 as decimal(10, 0)) FROM t;
SELECT '2' <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(null as string) = cast(1 as decimal(10, 0)) FROM t;
SELECT cast(null as string) > cast(1 as decimal(10, 0)) FROM t;
SELECT cast(null as string) >= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(null as string) < cast(1 as decimal(10, 0)) FROM t;
SELECT cast(null as string) <= cast(1 as decimal(10, 0)) FROM t;
SELECT cast(null as string) <> cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) = '1' FROM t;
SELECT cast(1 as double) > '2' FROM t;
SELECT cast(1 as double) >= '2' FROM t;
SELECT cast(1 as double) < '2' FROM t;
SELECT cast(1 as double) <= '2' FROM t;
SELECT cast(1 as double) <> '2' FROM t;
SELECT cast(1 as double) = cast(null as string) FROM t;
SELECT cast(1 as double) > cast(null as string) FROM t;
SELECT cast(1 as double) >= cast(null as string) FROM t;
SELECT cast(1 as double) < cast(null as string) FROM t;
SELECT cast(1 as double) <= cast(null as string) FROM t;
SELECT cast(1 as double) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as double) FROM t;
SELECT '2' > cast(1 as double) FROM t;
SELECT '2' >= cast(1 as double) FROM t;
SELECT '2' < cast(1 as double) FROM t;
SELECT '2' <= cast(1 as double) FROM t;
SELECT '2' <> cast(1 as double) FROM t;
SELECT cast(null as string) = cast(1 as double) FROM t;
SELECT cast(null as string) > cast(1 as double) FROM t;
SELECT cast(null as string) >= cast(1 as double) FROM t;
SELECT cast(null as string) < cast(1 as double) FROM t;
SELECT cast(null as string) <= cast(1 as double) FROM t;
SELECT cast(null as string) <> cast(1 as double) FROM t;
SELECT cast(1 as float) = '1' FROM t;
SELECT cast(1 as float) > '2' FROM t;
SELECT cast(1 as float) >= '2' FROM t;
SELECT cast(1 as float) < '2' FROM t;
SELECT cast(1 as float) <= '2' FROM t;
SELECT cast(1 as float) <> '2' FROM t;
SELECT cast(1 as float) = cast(null as string) FROM t;
SELECT cast(1 as float) > cast(null as string) FROM t;
SELECT cast(1 as float) >= cast(null as string) FROM t;
SELECT cast(1 as float) < cast(null as string) FROM t;
SELECT cast(1 as float) <= cast(null as string) FROM t;
SELECT cast(1 as float) <> cast(null as string) FROM t;
SELECT '1' = cast(1 as float) FROM t;
SELECT '2' > cast(1 as float) FROM t;
SELECT '2' >= cast(1 as float) FROM t;
SELECT '2' < cast(1 as float) FROM t;
SELECT '2' <= cast(1 as float) FROM t;
SELECT '2' <> cast(1 as float) FROM t;
SELECT cast(null as string) = cast(1 as float) FROM t;
SELECT cast(null as string) > cast(1 as float) FROM t;
SELECT cast(null as string) >= cast(1 as float) FROM t;
SELECT cast(null as string) < cast(1 as float) FROM t;
SELECT cast(null as string) <= cast(1 as float) FROM t;
SELECT cast(null as string) <> cast(1 as float) FROM t;
-- the following queries return 1 if the search condition is satisfied
-- and returns nothing if the search condition is not satisfied
SELECT '1996-09-09' = date('1996-09-09') FROM t;
SELECT '1996-9-10' > date('1996-09-09') FROM t;
SELECT '1996-9-10' >= date('1996-09-09') FROM t;
SELECT '1996-9-10' < date('1996-09-09') FROM t;
SELECT '1996-9-10' <= date('1996-09-09') FROM t;
SELECT '1996-9-10' <> date('1996-09-09') FROM t;
SELECT cast(null as string) = date('1996-09-09') FROM t;
SELECT cast(null as string)> date('1996-09-09') FROM t;
SELECT cast(null as string)>= date('1996-09-09') FROM t;
SELECT cast(null as string)< date('1996-09-09') FROM t;
SELECT cast(null as string)<= date('1996-09-09') FROM t;
SELECT cast(null as string)<> date('1996-09-09') FROM t;
SELECT date('1996-09-09') = '1996-09-09' FROM t;
SELECT date('1996-9-10') > '1996-09-09' FROM t;
SELECT date('1996-9-10') >= '1996-09-09' FROM t;
SELECT date('1996-9-10') < '1996-09-09' FROM t;
SELECT date('1996-9-10') <= '1996-09-09' FROM t;
SELECT date('1996-9-10') <> '1996-09-09' FROM t;
SELECT date('1996-09-09') = cast(null as string) FROM t;
SELECT date('1996-9-10') > cast(null as string) FROM t;
SELECT date('1996-9-10') >= cast(null as string) FROM t;
SELECT date('1996-9-10') < cast(null as string) FROM t;
SELECT date('1996-9-10') <= cast(null as string) FROM t;
SELECT date('1996-9-10') <> cast(null as string) FROM t;
SELECT '1996-09-09 12:12:12.4' = timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT '1996-09-09 12:12:12.5' > timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT '1996-09-09 12:12:12.5' >= timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT '1996-09-09 12:12:12.5' < timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT '1996-09-09 12:12:12.5' <= timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT '1996-09-09 12:12:12.5' <> timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT cast(null as string) = timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT cast(null as string) > timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT cast(null as string) >= timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT cast(null as string) < timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT cast(null as string) <= timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT cast(null as string) <> timestamp('1996-09-09 12:12:12.4') FROM t;
SELECT timestamp('1996-09-09 12:12:12.4' )= '1996-09-09 12:12:12.4' FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )> '1996-09-09 12:12:12.4' FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )>= '1996-09-09 12:12:12.4' FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )< '1996-09-09 12:12:12.4' FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )<= '1996-09-09 12:12:12.4' FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )<> '1996-09-09 12:12:12.4' FROM t;
SELECT timestamp('1996-09-09 12:12:12.4' )= cast(null as string) FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )> cast(null as string) FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )>= cast(null as string) FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )< cast(null as string) FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )<= cast(null as string) FROM t;
SELECT timestamp('1996-09-09 12:12:12.5' )<> cast(null as string) FROM t;
SELECT ' ' = X'0020' FROM t;
SELECT ' ' > X'001F' FROM t;
SELECT ' ' >= X'001F' FROM t;
SELECT ' ' < X'001F' FROM t;
SELECT ' ' <= X'001F' FROM t;
SELECT ' ' <> X'001F' FROM t;
SELECT cast(null as string) = X'0020' FROM t;
SELECT cast(null as string) > X'001F' FROM t;
SELECT cast(null as string) >= X'001F' FROM t;
SELECT cast(null as string) < X'001F' FROM t;
SELECT cast(null as string) <= X'001F' FROM t;
SELECT cast(null as string) <> X'001F' FROM t;
SELECT X'0020' = ' ' FROM t;
SELECT X'001F' > ' ' FROM t;
SELECT X'001F' >= ' ' FROM t;
SELECT X'001F' < ' ' FROM t;
SELECT X'001F' <= ' ' FROM t;
SELECT X'001F' <> ' ' FROM t;
SELECT X'0020' = cast(null as string) FROM t;
SELECT X'001F' > cast(null as string) FROM t;
SELECT X'001F' >= cast(null as string) FROM t;
SELECT X'001F' < cast(null as string) FROM t;
SELECT X'001F' <= cast(null as string) FROM t;
SELECT X'001F' <> cast(null as string) FROM t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT true = cast(1 as tinyint) FROM t;
SELECT true = cast(1 as smallint) FROM t;
SELECT true = cast(1 as int) FROM t;
SELECT true = cast(1 as bigint) FROM t;
SELECT true = cast(1 as float) FROM t;
SELECT true = cast(1 as double) FROM t;
SELECT true = cast(1 as decimal(10, 0)) FROM t;
SELECT true = cast(1 as string) FROM t;
SELECT true = cast('1' as binary) FROM t;
SELECT true = cast(1 as boolean) FROM t;
SELECT true = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT true = cast('2017-12-11 09:30:00' as date) FROM t;

SELECT true <=> cast(1 as tinyint) FROM t;
SELECT true <=> cast(1 as smallint) FROM t;
SELECT true <=> cast(1 as int) FROM t;
SELECT true <=> cast(1 as bigint) FROM t;
SELECT true <=> cast(1 as float) FROM t;
SELECT true <=> cast(1 as double) FROM t;
SELECT true <=> cast(1 as decimal(10, 0)) FROM t;
SELECT true <=> cast(1 as string) FROM t;
SELECT true <=> cast('1' as binary) FROM t;
SELECT true <=> cast(1 as boolean) FROM t;
SELECT true <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT true <=> cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as tinyint) = true FROM t;
SELECT cast(1 as smallint) = true FROM t;
SELECT cast(1 as int) = true FROM t;
SELECT cast(1 as bigint) = true FROM t;
SELECT cast(1 as float) = true FROM t;
SELECT cast(1 as double) = true FROM t;
SELECT cast(1 as decimal(10, 0)) = true FROM t;
SELECT cast(1 as string) = true FROM t;
SELECT cast('1' as binary) = true FROM t;
SELECT cast(1 as boolean) = true FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) = true FROM t;
SELECT cast('2017-12-11 09:30:00' as date) = true FROM t;

SELECT cast(1 as tinyint) <=> true FROM t;
SELECT cast(1 as smallint) <=> true FROM t;
SELECT cast(1 as int) <=> true FROM t;
SELECT cast(1 as bigint) <=> true FROM t;
SELECT cast(1 as float) <=> true FROM t;
SELECT cast(1 as double) <=> true FROM t;
SELECT cast(1 as decimal(10, 0)) <=> true FROM t;
SELECT cast(1 as string) <=> true FROM t;
SELECT cast('1' as binary) <=> true FROM t;
SELECT cast(1 as boolean) <=> true FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> true FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <=> true FROM t;

SELECT false = cast(0 as tinyint) FROM t;
SELECT false = cast(0 as smallint) FROM t;
SELECT false = cast(0 as int) FROM t;
SELECT false = cast(0 as bigint) FROM t;
SELECT false = cast(0 as float) FROM t;
SELECT false = cast(0 as double) FROM t;
SELECT false = cast(0 as decimal(10, 0)) FROM t;
SELECT false = cast(0 as string) FROM t;
SELECT false = cast('0' as binary) FROM t;
SELECT false = cast(0 as boolean) FROM t;
SELECT false = cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT false = cast('2017-12-11 09:30:00' as date) FROM t;

SELECT false <=> cast(0 as tinyint) FROM t;
SELECT false <=> cast(0 as smallint) FROM t;
SELECT false <=> cast(0 as int) FROM t;
SELECT false <=> cast(0 as bigint) FROM t;
SELECT false <=> cast(0 as float) FROM t;
SELECT false <=> cast(0 as double) FROM t;
SELECT false <=> cast(0 as decimal(10, 0)) FROM t;
SELECT false <=> cast(0 as string) FROM t;
SELECT false <=> cast('0' as binary) FROM t;
SELECT false <=> cast(0 as boolean) FROM t;
SELECT false <=> cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT false <=> cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(0 as tinyint) = false FROM t;
SELECT cast(0 as smallint) = false FROM t;
SELECT cast(0 as int) = false FROM t;
SELECT cast(0 as bigint) = false FROM t;
SELECT cast(0 as float) = false FROM t;
SELECT cast(0 as double) = false FROM t;
SELECT cast(0 as decimal(10, 0)) = false FROM t;
SELECT cast(0 as string) = false FROM t;
SELECT cast('0' as binary) = false FROM t;
SELECT cast(0 as boolean) = false FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) = false FROM t;
SELECT cast('2017-12-11 09:30:00' as date) = false FROM t;

SELECT cast(0 as tinyint) <=> false FROM t;
SELECT cast(0 as smallint) <=> false FROM t;
SELECT cast(0 as int) <=> false FROM t;
SELECT cast(0 as bigint) <=> false FROM t;
SELECT cast(0 as float) <=> false FROM t;
SELECT cast(0 as double) <=> false FROM t;
SELECT cast(0 as decimal(10, 0)) <=> false FROM t;
SELECT cast(0 as string) <=> false FROM t;
SELECT cast('0' as binary) <=> false FROM t;
SELECT cast(0 as boolean) <=> false FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) <=> false FROM t;
SELECT cast('2017-12-11 09:30:00' as date) <=> false FROM t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT cast(1 as tinyint) / cast(1 as tinyint) FROM t;
SELECT cast(1 as tinyint) / cast(1 as smallint) FROM t;
SELECT cast(1 as tinyint) / cast(1 as int) FROM t;
SELECT cast(1 as tinyint) / cast(1 as bigint) FROM t;
SELECT cast(1 as tinyint) / cast(1 as float) FROM t;
SELECT cast(1 as tinyint) / cast(1 as double) FROM t;
SELECT cast(1 as tinyint) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) / cast(1 as string) FROM t;
SELECT cast(1 as tinyint) / cast('1' as binary) FROM t;
SELECT cast(1 as tinyint) / cast(1 as boolean) FROM t;
SELECT cast(1 as tinyint) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as tinyint) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as smallint) / cast(1 as tinyint) FROM t;
SELECT cast(1 as smallint) / cast(1 as smallint) FROM t;
SELECT cast(1 as smallint) / cast(1 as int) FROM t;
SELECT cast(1 as smallint) / cast(1 as bigint) FROM t;
SELECT cast(1 as smallint) / cast(1 as float) FROM t;
SELECT cast(1 as smallint) / cast(1 as double) FROM t;
SELECT cast(1 as smallint) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) / cast(1 as string) FROM t;
SELECT cast(1 as smallint) / cast('1' as binary) FROM t;
SELECT cast(1 as smallint) / cast(1 as boolean) FROM t;
SELECT cast(1 as smallint) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as smallint) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as int) / cast(1 as tinyint) FROM t;
SELECT cast(1 as int) / cast(1 as smallint) FROM t;
SELECT cast(1 as int) / cast(1 as int) FROM t;
SELECT cast(1 as int) / cast(1 as bigint) FROM t;
SELECT cast(1 as int) / cast(1 as float) FROM t;
SELECT cast(1 as int) / cast(1 as double) FROM t;
SELECT cast(1 as int) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) / cast(1 as string) FROM t;
SELECT cast(1 as int) / cast('1' as binary) FROM t;
SELECT cast(1 as int) / cast(1 as boolean) FROM t;
SELECT cast(1 as int) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as int) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as bigint) / cast(1 as tinyint) FROM t;
SELECT cast(1 as bigint) / cast(1 as smallint) FROM t;
SELECT cast(1 as bigint) / cast(1 as int) FROM t;
SELECT cast(1 as bigint) / cast(1 as bigint) FROM t;
SELECT cast(1 as bigint) / cast(1 as float) FROM t;
SELECT cast(1 as bigint) / cast(1 as double) FROM t;
SELECT cast(1 as bigint) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) / cast(1 as string) FROM t;
SELECT cast(1 as bigint) / cast('1' as binary) FROM t;
SELECT cast(1 as bigint) / cast(1 as boolean) FROM t;
SELECT cast(1 as bigint) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as bigint) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as float) / cast(1 as tinyint) FROM t;
SELECT cast(1 as float) / cast(1 as smallint) FROM t;
SELECT cast(1 as float) / cast(1 as int) FROM t;
SELECT cast(1 as float) / cast(1 as bigint) FROM t;
SELECT cast(1 as float) / cast(1 as float) FROM t;
SELECT cast(1 as float) / cast(1 as double) FROM t;
SELECT cast(1 as float) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) / cast(1 as string) FROM t;
SELECT cast(1 as float) / cast('1' as binary) FROM t;
SELECT cast(1 as float) / cast(1 as boolean) FROM t;
SELECT cast(1 as float) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as float) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as double) / cast(1 as tinyint) FROM t;
SELECT cast(1 as double) / cast(1 as smallint) FROM t;
SELECT cast(1 as double) / cast(1 as int) FROM t;
SELECT cast(1 as double) / cast(1 as bigint) FROM t;
SELECT cast(1 as double) / cast(1 as float) FROM t;
SELECT cast(1 as double) / cast(1 as double) FROM t;
SELECT cast(1 as double) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) / cast(1 as string) FROM t;
SELECT cast(1 as double) / cast('1' as binary) FROM t;
SELECT cast(1 as double) / cast(1 as boolean) FROM t;
SELECT cast(1 as double) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as double) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as decimal(10, 0)) / cast(1 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast('1' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast(1 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as string) / cast(1 as tinyint) FROM t;
SELECT cast(1 as string) / cast(1 as smallint) FROM t;
SELECT cast(1 as string) / cast(1 as int) FROM t;
SELECT cast(1 as string) / cast(1 as bigint) FROM t;
SELECT cast(1 as string) / cast(1 as float) FROM t;
SELECT cast(1 as string) / cast(1 as double) FROM t;
SELECT cast(1 as string) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as string) / cast(1 as string) FROM t;
SELECT cast(1 as string) / cast('1' as binary) FROM t;
SELECT cast(1 as string) / cast(1 as boolean) FROM t;
SELECT cast(1 as string) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as string) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast('1' as binary) / cast(1 as tinyint) FROM t;
SELECT cast('1' as binary) / cast(1 as smallint) FROM t;
SELECT cast('1' as binary) / cast(1 as int) FROM t;
SELECT cast('1' as binary) / cast(1 as bigint) FROM t;
SELECT cast('1' as binary) / cast(1 as float) FROM t;
SELECT cast('1' as binary) / cast(1 as double) FROM t;
SELECT cast('1' as binary) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) / cast(1 as string) FROM t;
SELECT cast('1' as binary) / cast('1' as binary) FROM t;
SELECT cast('1' as binary) / cast(1 as boolean) FROM t;
SELECT cast('1' as binary) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast('1' as binary) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as boolean) / cast(1 as tinyint) FROM t;
SELECT cast(1 as boolean) / cast(1 as smallint) FROM t;
SELECT cast(1 as boolean) / cast(1 as int) FROM t;
SELECT cast(1 as boolean) / cast(1 as bigint) FROM t;
SELECT cast(1 as boolean) / cast(1 as float) FROM t;
SELECT cast(1 as boolean) / cast(1 as double) FROM t;
SELECT cast(1 as boolean) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast(1 as boolean) / cast(1 as string) FROM t;
SELECT cast(1 as boolean) / cast('1' as binary) FROM t;
SELECT cast(1 as boolean) / cast(1 as boolean) FROM t;
SELECT cast(1 as boolean) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as boolean) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as tinyint) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as smallint) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as int) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as bigint) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as float) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as double) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as string) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast('1' as binary) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast(1 as boolean) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast('2017-12-11 09:30:00.0' as timestamp) / cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as tinyint) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as smallint) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as int) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as bigint) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as float) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as double) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as string) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast('1' as binary) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast(1 as boolean) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast('2017-12-11 09:30:00' as date) / cast('2017-12-11 09:30:00' as date) FROM t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as tinyint) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as smallint) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as int) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as bigint) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as float) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as double) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as decimal(10, 0)) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as string) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast('1' as binary) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast(1 as boolean) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00.0' as timestamp) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;

SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as tinyint) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as smallint) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as int) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as bigint) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as float) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as double) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as decimal(10, 0)) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as string) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast('2' as binary) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast(2 as boolean) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast('2017-12-11 09:30:00.0' as timestamp) END FROM t;
SELECT CASE WHEN true THEN cast('2017-12-12 09:30:00' as date) ELSE cast('2017-12-11 09:30:00' as date) END FROM t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 'aa' as a;

-- casting to data types which are unable to represent the string input returns NULL
select cast(a as byte) from t;
select cast(a as short) from t;
select cast(a as int) from t;
select cast(a as long) from t;
select cast(a as float) from t;
select cast(a as double) from t;
select cast(a as decimal) from t;
select cast(a as boolean) from t;
select cast(a as timestamp) from t;
select cast(a as date) from t;
-- casting to binary works correctly
select cast(a as binary) from t;
-- casting to array, struct or map throws exception
select cast(a as array<string>) from t;
select cast(a as struct<s:string>) from t;
select cast(a as map<string, string>) from t;

-- all timestamp/date expressions return NULL if bad input strings are provided
select to_timestamp(a) from t;
select to_timestamp('2018-01-01', a) from t;
select to_unix_timestamp(a) from t;
select to_unix_timestamp('2018-01-01', a) from t;
select unix_timestamp(a) from t;
select unix_timestamp('2018-01-01', a) from t;
select from_unixtime(a) from t;
select from_unixtime('2018-01-01', a) from t;
select next_day(a, 'MO') from t;
select next_day('2018-01-01', a) from t;
select trunc(a, 'MM') from t;
select trunc('2018-01-01', a) from t;

-- some functions return NULL if bad input is provided
select unhex('-123');
select sha2(a, a) from t;
select get_json_object(a, a) from t;
select json_tuple(a, a) from t;
select from_json(a, 'a INT') from t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

-- UNION
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as tinyint) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as smallint) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as int) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as int) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as bigint) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as float) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as float) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as double) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as double) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as decimal(10, 0)) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as string) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as string) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast('1' as binary) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast(1 as boolean) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;

SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as tinyint) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as smallint) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as int) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as bigint) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as float) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as double) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as decimal(10, 0)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as string) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast('2' as binary) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast(2 as boolean) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast('2017-12-11 09:30:00.0' as timestamp) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) FROM t UNION SELECT cast('2017-12-11 09:30:00' as date) FROM t;
--
--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--

CREATE TEMPORARY VIEW t AS SELECT 1;

SELECT cast(1 as tinyint) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as int)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as float)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as double)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as string)) FROM t;
SELECT cast(1 as tinyint) in (cast('1' as binary)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as tinyint) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as tinyint) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as smallint) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as int)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as float)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as double)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as smallint) in (cast(1 as string)) FROM t;
SELECT cast(1 as smallint) in (cast('1' as binary)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as smallint) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as smallint) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as int) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as int) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as int) in (cast(1 as int)) FROM t;
SELECT cast(1 as int) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as int) in (cast(1 as float)) FROM t;
SELECT cast(1 as int) in (cast(1 as double)) FROM t;
SELECT cast(1 as int) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as int) in (cast(1 as string)) FROM t;
SELECT cast(1 as int) in (cast('1' as binary)) FROM t;
SELECT cast(1 as int) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as int) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as int) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as bigint) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as int)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as float)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as double)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as bigint) in (cast(1 as string)) FROM t;
SELECT cast(1 as bigint) in (cast('1' as binary)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as bigint) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as bigint) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as float) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as float) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as float) in (cast(1 as int)) FROM t;
SELECT cast(1 as float) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as float) in (cast(1 as float)) FROM t;
SELECT cast(1 as float) in (cast(1 as double)) FROM t;
SELECT cast(1 as float) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as float) in (cast(1 as string)) FROM t;
SELECT cast(1 as float) in (cast('1' as binary)) FROM t;
SELECT cast(1 as float) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as float) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as float) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as double) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as double) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as double) in (cast(1 as int)) FROM t;
SELECT cast(1 as double) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as double) in (cast(1 as float)) FROM t;
SELECT cast(1 as double) in (cast(1 as double)) FROM t;
SELECT cast(1 as double) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as double) in (cast(1 as string)) FROM t;
SELECT cast(1 as double) in (cast('1' as binary)) FROM t;
SELECT cast(1 as double) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as double) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as double) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as decimal(10, 0)) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as int)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as float)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as double)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as string)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast('1' as binary)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as string) in (cast(1 as tinyint)) FROM t;
SELECT cast(1 as string) in (cast(1 as smallint)) FROM t;
SELECT cast(1 as string) in (cast(1 as int)) FROM t;
SELECT cast(1 as string) in (cast(1 as bigint)) FROM t;
SELECT cast(1 as string) in (cast(1 as float)) FROM t;
SELECT cast(1 as string) in (cast(1 as double)) FROM t;
SELECT cast(1 as string) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as string) in (cast(1 as string)) FROM t;
SELECT cast(1 as string) in (cast('1' as binary)) FROM t;
SELECT cast(1 as string) in (cast(1 as boolean)) FROM t;
SELECT cast(1 as string) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as string) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('1' as binary) in (cast(1 as tinyint)) FROM t;
SELECT cast('1' as binary) in (cast(1 as smallint)) FROM t;
SELECT cast('1' as binary) in (cast(1 as int)) FROM t;
SELECT cast('1' as binary) in (cast(1 as bigint)) FROM t;
SELECT cast('1' as binary) in (cast(1 as float)) FROM t;
SELECT cast('1' as binary) in (cast(1 as double)) FROM t;
SELECT cast('1' as binary) in (cast(1 as decimal(10, 0))) FROM t;
SELECT cast('1' as binary) in (cast(1 as string)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary)) FROM t;
SELECT cast('1' as binary) in (cast(1 as boolean)) FROM t;
SELECT cast('1' as binary) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('1' as binary) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT true in (cast(1 as tinyint)) FROM t;
SELECT true in (cast(1 as smallint)) FROM t;
SELECT true in (cast(1 as int)) FROM t;
SELECT true in (cast(1 as bigint)) FROM t;
SELECT true in (cast(1 as float)) FROM t;
SELECT true in (cast(1 as double)) FROM t;
SELECT true in (cast(1 as decimal(10, 0))) FROM t;
SELECT true in (cast(1 as string)) FROM t;
SELECT true in (cast('1' as binary)) FROM t;
SELECT true in (cast(1 as boolean)) FROM t;
SELECT true in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT true in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as tinyint)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as smallint)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as int)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as bigint)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as float)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as double)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as decimal(10, 0))) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as string)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2' as binary)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast(2 as boolean)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as tinyint)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as smallint)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as int)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as bigint)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as float)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as double)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as decimal(10, 0))) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as string)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2' as binary)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast(2 as boolean)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as tinyint)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as smallint)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as int)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as bigint)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as float)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as double)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as string)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast('1' as binary)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast(1 as boolean)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as tinyint) in (cast(1 as tinyint), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as tinyint)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as smallint)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as int)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as bigint)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as float)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as double)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as string)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast('1' as binary)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast(1 as boolean)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as smallint) in (cast(1 as smallint), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as int) in (cast(1 as int), cast(1 as tinyint)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as smallint)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as int)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as bigint)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as float)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as double)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as string)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast('1' as binary)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast(1 as boolean)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as int) in (cast(1 as int), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as tinyint)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as smallint)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as int)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as bigint)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as float)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as double)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as string)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast('1' as binary)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast(1 as boolean)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as bigint) in (cast(1 as bigint), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as float) in (cast(1 as float), cast(1 as tinyint)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as smallint)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as int)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as bigint)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as float)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as double)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as string)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast('1' as binary)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast(1 as boolean)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as float) in (cast(1 as float), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as double) in (cast(1 as double), cast(1 as tinyint)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as smallint)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as int)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as bigint)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as float)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as double)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as string)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast('1' as binary)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast(1 as boolean)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as double) in (cast(1 as double), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as tinyint)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as smallint)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as int)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as bigint)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as float)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as double)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as string)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast('1' as binary)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast(1 as boolean)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as decimal(10, 0)) in (cast(1 as decimal(10, 0)), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast(1 as string) in (cast(1 as string), cast(1 as tinyint)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as smallint)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as int)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as bigint)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as float)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as double)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as decimal(10, 0))) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as string)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast('1' as binary)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast(1 as boolean)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast(1 as string) in (cast(1 as string), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as tinyint)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as smallint)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as int)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as bigint)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as float)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as double)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as decimal(10, 0))) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as string)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast('1' as binary)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast(1 as boolean)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('1' as binary) in (cast('1' as binary), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as tinyint)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as smallint)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as int)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as bigint)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as float)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as double)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as decimal(10, 0))) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as string)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast('1' as binary)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast(1 as boolean)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('1' as boolean) in (cast('1' as boolean), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as tinyint)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as smallint)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as int)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as bigint)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as float)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as double)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as decimal(10, 0))) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as string)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast('1' as binary)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast(1 as boolean)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('2017-12-12 09:30:00.0' as timestamp) in (cast('2017-12-12 09:30:00.0' as timestamp), cast('2017-12-11 09:30:00' as date)) FROM t;

SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as tinyint)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as smallint)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as int)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as bigint)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as float)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as double)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as decimal(10, 0))) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as string)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast('1' as binary)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast(1 as boolean)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast('2017-12-11 09:30:00.0' as timestamp)) FROM t;
SELECT cast('2017-12-12 09:30:00' as date) in (cast('2017-12-12 09:30:00' as date), cast('2017-12-11 09:30:00' as date)) FROM t;
-- test cases for array functions

create temporary view data as select * from values
  ("one", array(11, 12, 13), array(array(111, 112, 113), array(121, 122, 123))),
  ("two", array(21, 22, 23), array(array(211, 212, 213), array(221, 222, 223)))
  as data(a, b, c);

select * from data;

-- index into array
select a, b[0], b[0] + b[1] from data;

-- index into array of arrays
select a, c[0][0] + c[0][0 + 1] from data;


create temporary view primitive_arrays as select * from values (
  array(true),
  array(2Y, 1Y),
  array(2S, 1S),
  array(2, 1),
  array(2L, 1L),
  array(9223372036854775809, 9223372036854775808),
  array(2.0D, 1.0D),
  array(float(2.0), float(1.0)),
  array(date '2016-03-14', date '2016-03-13'),
  array(timestamp '2016-11-15 20:54:00.000',  timestamp '2016-11-12 20:54:00.000')
) as primitive_arrays(
  boolean_array,
  tinyint_array,
  smallint_array,
  int_array,
  bigint_array,
  decimal_array,
  double_array,
  float_array,
  date_array,
  timestamp_array
);

select * from primitive_arrays;

-- array_contains on all primitive types: result should alternate between true and false
select
  array_contains(boolean_array, true), array_contains(boolean_array, false),
  array_contains(tinyint_array, 2Y), array_contains(tinyint_array, 0Y),
  array_contains(smallint_array, 2S), array_contains(smallint_array, 0S),
  array_contains(int_array, 2), array_contains(int_array, 0),
  array_contains(bigint_array, 2L), array_contains(bigint_array, 0L),
  array_contains(decimal_array, 9223372036854775809), array_contains(decimal_array, 1),
  array_contains(double_array, 2.0D), array_contains(double_array, 0.0D),
  array_contains(float_array, float(2.0)), array_contains(float_array, float(0.0)),
  array_contains(date_array, date '2016-03-14'), array_contains(date_array, date '2016-01-01'),
  array_contains(timestamp_array, timestamp '2016-11-15 20:54:00.000'), array_contains(timestamp_array, timestamp '2016-01-01 20:54:00.000')
from primitive_arrays;

-- array_contains on nested arrays
select array_contains(b, 11), array_contains(c, array(111, 112, 113)) from data;

-- sort_array
select
  sort_array(boolean_array),
  sort_array(tinyint_array),
  sort_array(smallint_array),
  sort_array(int_array),
  sort_array(bigint_array),
  sort_array(decimal_array),
  sort_array(double_array),
  sort_array(float_array),
  sort_array(date_array),
  sort_array(timestamp_array)
from primitive_arrays;

-- sort_array with an invalid string literal for the argument of sort order.
select sort_array(array('b', 'd'), '1');

-- sort_array with an invalid null literal casted as boolean for the argument of sort order.
select sort_array(array('b', 'd'), cast(NULL as boolean));

-- size
select
  size(boolean_array),
  size(tinyint_array),
  size(smallint_array),
  size(int_array),
  size(bigint_array),
  size(decimal_array),
  size(double_array),
  size(float_array),
  size(date_array),
  size(timestamp_array)
from primitive_arrays;
-- Create a test table with data
create table t1(a int, b int, c int) using parquet;
insert into t1 values(1,0,0);
insert into t1 values(2,0,1);
insert into t1 values(3,1,0);
insert into t1 values(4,1,1);
insert into t1 values(5,null,0);
insert into t1 values(6,null,1);
insert into t1 values(7,null,null);

-- Adding anything to null gives null
select a, b+c from t1;

-- Multiplying null by zero gives null
select a+10, b*0 from t1;

-- nulls are NOT distinct in SELECT DISTINCT
select distinct b from t1;

-- nulls are NOT distinct in UNION
select b from t1 union select b from t1;

-- CASE WHEN null THEN 1 ELSE 0 END is 0
select a+20, case b when c then 1 else 0 end from t1;
select a+30, case c when b then 1 else 0 end from t1;
select a+40, case when b<>0 then 1 else 0 end from t1;
select a+50, case when not b<>0 then 1 else 0 end from t1;
select a+60, case when b<>0 and c<>0 then 1 else 0 end from t1;

-- "not (null AND false)" is true
select a+70, case when not (b<>0 and c<>0) then 1 else 0 end from t1;

-- "null OR true" is true
select a+80, case when b<>0 or c<>0 then 1 else 0 end from t1;
select a+90, case when not (b<>0 or c<>0) then 1 else 0 end from t1;

-- null with aggregate operators
select count(*), count(b), sum(b), avg(b), min(b), max(b) from t1;

-- Check the behavior of NULLs in WHERE clauses
select a+100 from t1 where b<10;
select a+110 from t1 where not b>10;
select a+120 from t1 where b<10 OR c=1;
select a+130 from t1 where b<10 AND c=1;
select a+140 from t1 where not (b<10 AND c=1);
select a+150 from t1 where not (c=1 AND b<10);

drop table t1;
-- Test data.
CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES
(null, 1L, 1.0D, date("2017-08-01"), timestamp(1501545600), "a"),
(1, 1L, 1.0D, date("2017-08-01"), timestamp(1501545600), "a"),
(1, 2L, 2.5D, date("2017-08-02"), timestamp(1502000000), "a"),
(2, 2147483650L, 100.001D, date("2020-12-31"), timestamp(1609372800), "a"),
(1, null, 1.0D, date("2017-08-01"), timestamp(1501545600), "b"),
(2, 3L, 3.3D, date("2017-08-03"), timestamp(1503000000), "b"),
(3, 2147483650L, 100.001D, date("2020-12-31"), timestamp(1609372800), "b"),
(null, null, null, null, null, null),
(3, 1L, 1.0D, date("2017-08-01"), timestamp(1501545600), null)
AS testData(val, val_long, val_double, val_date, val_timestamp, cate);

-- RowsBetween
SELECT val, cate, count(val) OVER(PARTITION BY cate ORDER BY val ROWS CURRENT ROW) FROM testData
ORDER BY cate, val;
SELECT val, cate, sum(val) OVER(PARTITION BY cate ORDER BY val
ROWS BETWEEN UNBOUNDED PRECEDING AND 1 FOLLOWING) FROM testData ORDER BY cate, val;
SELECT val_long, cate, sum(val_long) OVER(PARTITION BY cate ORDER BY val_long
ROWS BETWEEN CURRENT ROW AND 2147483648 FOLLOWING) FROM testData ORDER BY cate, val_long;

-- RangeBetween
SELECT val, cate, count(val) OVER(PARTITION BY cate ORDER BY val RANGE 1 PRECEDING) FROM testData
ORDER BY cate, val;
SELECT val, cate, sum(val) OVER(PARTITION BY cate ORDER BY val
RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM testData ORDER BY cate, val;
SELECT val_long, cate, sum(val_long) OVER(PARTITION BY cate ORDER BY val_long
RANGE BETWEEN CURRENT ROW AND 2147483648 FOLLOWING) FROM testData ORDER BY cate, val_long;
SELECT val_double, cate, sum(val_double) OVER(PARTITION BY cate ORDER BY val_double
RANGE BETWEEN CURRENT ROW AND 2.5 FOLLOWING) FROM testData ORDER BY cate, val_double;
SELECT val_date, cate, max(val_date) OVER(PARTITION BY cate ORDER BY val_date
RANGE BETWEEN CURRENT ROW AND 2 FOLLOWING) FROM testData ORDER BY cate, val_date;
SELECT val_timestamp, cate, avg(val_timestamp) OVER(PARTITION BY cate ORDER BY val_timestamp
RANGE BETWEEN CURRENT ROW AND interval 23 days 4 hours FOLLOWING) FROM testData
ORDER BY cate, val_timestamp;

-- RangeBetween with reverse OrderBy
SELECT val, cate, sum(val) OVER(PARTITION BY cate ORDER BY val DESC
RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM testData ORDER BY cate, val;

-- Invalid window frame
SELECT val, cate, count(val) OVER(PARTITION BY cate
ROWS BETWEEN UNBOUNDED FOLLOWING AND 1 FOLLOWING) FROM testData ORDER BY cate, val;
SELECT val, cate, count(val) OVER(PARTITION BY cate
RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM testData ORDER BY cate, val;
SELECT val, cate, count(val) OVER(PARTITION BY cate ORDER BY val, cate
RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM testData ORDER BY cate, val;
SELECT val, cate, count(val) OVER(PARTITION BY cate ORDER BY current_timestamp
RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) FROM testData ORDER BY cate, val;
SELECT val, cate, count(val) OVER(PARTITION BY cate ORDER BY val
RANGE BETWEEN 1 FOLLOWING AND 1 PRECEDING) FROM testData ORDER BY cate, val;
SELECT val, cate, count(val) OVER(PARTITION BY cate ORDER BY val
RANGE BETWEEN CURRENT ROW AND current_date PRECEDING) FROM testData ORDER BY cate, val;


-- Window functions
SELECT val, cate,
max(val) OVER w AS max,
min(val) OVER w AS min,
min(val) OVER w AS min,
count(val) OVER w AS count,
sum(val) OVER w AS sum,
avg(val) OVER w AS avg,
stddev(val) OVER w AS stddev,
first_value(val) OVER w AS first_value,
first_value(val, true) OVER w AS first_value_ignore_null,
first_value(val, false) OVER w AS first_value_contain_null,
last_value(val) OVER w AS last_value,
last_value(val, true) OVER w AS last_value_ignore_null,
last_value(val, false) OVER w AS last_value_contain_null,
rank() OVER w AS rank,
dense_rank() OVER w AS dense_rank,
cume_dist() OVER w AS cume_dist,
percent_rank() OVER w AS percent_rank,
ntile(2) OVER w AS ntile,
row_number() OVER w AS row_number,
var_pop(val) OVER w AS var_pop,
var_samp(val) OVER w AS var_samp,
approx_count_distinct(val) OVER w AS approx_count_distinct,
covar_pop(val, val_long) OVER w AS covar_pop,
corr(val, val_long) OVER w AS corr,
stddev_samp(val) OVER w AS stddev_samp,
stddev_pop(val) OVER w AS stddev_pop,
collect_list(val) OVER w AS collect_list,
collect_set(val) OVER w AS collect_set,
skewness(val_double) OVER w AS skewness,
kurtosis(val_double) OVER w AS kurtosis
FROM testData
WINDOW w AS (PARTITION BY cate ORDER BY val)
ORDER BY cate, val;

-- Null inputs
SELECT val, cate, avg(null) OVER(PARTITION BY cate ORDER BY val) FROM testData ORDER BY cate, val;

-- OrderBy not specified
SELECT val, cate, row_number() OVER(PARTITION BY cate) FROM testData ORDER BY cate, val;

-- Over clause is empty
SELECT val, cate, sum(val) OVER(), avg(val) OVER() FROM testData ORDER BY cate, val;

-- first_value()/last_value() over ()
SELECT val, cate,
first_value(false) OVER w AS first_value,
first_value(true, true) OVER w AS first_value_ignore_null,
first_value(false, false) OVER w AS first_value_contain_null,
last_value(false) OVER w AS last_value,
last_value(true, true) OVER w AS last_value_ignore_null,
last_value(false, false) OVER w AS last_value_contain_null
FROM testData
WINDOW w AS ()
ORDER BY cate, val;

-- parentheses around window reference
SELECT cate, sum(val) OVER (w)
FROM testData
WHERE val is not null
WINDOW w AS (PARTITION BY cate ORDER BY val);
-- rand with the seed 0
SELECT rand(0);
SELECT rand(cast(3 / 7 AS int));
SELECT rand(NULL);
SELECT rand(cast(NULL AS int));

-- rand unsupported data type
SELECT rand(1.0);

-- randn with the seed 0
SELECT randn(0L);
SELECT randn(cast(3 / 7 AS long));
SELECT randn(NULL);
SELECT randn(cast(NULL AS long));

-- randn unsupported data type
SELECT rand('1')
-- This is a query file that has been blacklisted.
-- It includes a query that should crash Spark.
-- If the test case is run, the whole suite would fail.
some random not working query that should crash Spark.

-- unary minus and plus
select -100;
select +230;
select -5.2;
select +6.8e0;
select -key, +key from testdata where key = 2;
select -(key + 1), - key + 1, +(key + 5) from testdata where key = 1;
select -max(key), +max(key) from testdata;
select - (-10);
select + (-key) from testdata where key = 32;
select - (+max(key)) from testdata;
select - - 3;
select - + 20;
select + + 100;
select - - max(key) from testdata;
select + - key from testdata where key = 33;

-- division
select 5 / 2;
select 5 / 0;
select 5 / null;
select null / 5;

-- other arithmetics
select 1 + 2;
select 1 - 2;
select 2 * 5;
select 5 % 3;
select pmod(-7, 3);

-- math functions
select cot(1);
select cot(null);
select cot(0);
select cot(-1);

-- ceil and ceiling
select ceiling(0);
select ceiling(1);
select ceil(1234567890123456);
select ceiling(1234567890123456);
select ceil(0.01);
select ceiling(-0.10);

-- floor
select floor(0);
select floor(1);
select floor(1234567890123456);
select floor(0.01);
select floor(-0.10);

-- comparison operator
select 1 > 0.00001;

-- mod
select mod(7, 2), mod(7, 0), mod(0, 2), mod(7, null), mod(null, 2), mod(null, null);

-- length
select BIT_LENGTH('abc');
select CHAR_LENGTH('abc');
select CHARACTER_LENGTH('abc');
select OCTET_LENGTH('abc');

-- abs
select abs(-3.13), abs('-2.19');

-- positive/negative
select positive('-1.11'), positive(-1.11), negative('-1.11'), negative(-1.11);

-- pmod
select pmod(-7, 2), pmod(0, 2), pmod(7, 0), pmod(7, null), pmod(null, 2), pmod(null, null);
select pmod(cast(3.13 as decimal), cast(0 as decimal)), pmod(cast(2 as smallint), cast(0 as smallint));
-- Negative testcases for column resolution
CREATE DATABASE mydb1;
USE mydb1;
CREATE TABLE t1 USING parquet AS SELECT 1 AS i1;

CREATE DATABASE mydb2;
USE mydb2;
CREATE TABLE t1 USING parquet AS SELECT 20 AS i1;

-- Negative tests: column resolution scenarios with ambiguous cases in join queries
SET spark.sql.crossJoin.enabled = true;
USE mydb1;
SELECT i1 FROM t1, mydb1.t1;
SELECT t1.i1 FROM t1, mydb1.t1;
SELECT mydb1.t1.i1 FROM t1, mydb1.t1;
SELECT i1 FROM t1, mydb2.t1;
SELECT t1.i1 FROM t1, mydb2.t1;
USE mydb2;
SELECT i1 FROM t1, mydb1.t1;
SELECT t1.i1 FROM t1, mydb1.t1;
SELECT i1 FROM t1, mydb2.t1;
SELECT t1.i1 FROM t1, mydb2.t1;
SELECT db1.t1.i1 FROM t1, mydb2.t1;
SET spark.sql.crossJoin.enabled = false;

-- Negative tests
USE mydb1;
SELECT mydb1.t1 FROM t1;
SELECT t1.x.y.* FROM t1;
SELECT t1 FROM mydb1.t1;
USE mydb2;
SELECT mydb1.t1.i1 FROM t1;

-- reset
DROP DATABASE mydb1 CASCADE;
DROP DATABASE mydb2 CASCADE;
create or replace temporary view nested as values
  (1, array(32, 97), array(array(12, 99), array(123, 42), array(1))),
  (2, array(77, -76), array(array(6, 96, 65), array(-1, -2))),
  (3, array(12), array(array(17)))
  as t(x, ys, zs);

-- Only allow lambda's in higher order functions.
select upper(x -> x) as v;

-- Identity transform an array
select transform(zs, z -> z) as v from nested;

-- Transform an array
select transform(ys, y -> y * y) as v from nested;

-- Transform an array with index
select transform(ys, (y, i) -> y + i) as v from nested;

-- Transform an array with reference
select transform(zs, z -> concat(ys, z)) as v from nested;

-- Transform an array to an array of 0's
select transform(ys, 0) as v from nested;

-- Transform a null array
select transform(cast(null as array<int>), x -> x + 1) as v;

-- Filter.
select filter(ys, y -> y > 30) as v from nested;

-- Filter a null array
select filter(cast(null as array<int>), y -> true) as v;

-- Filter nested arrays
select transform(zs, z -> filter(z, zz -> zz > 50)) as v from nested;

-- Aggregate.
select aggregate(ys, 0, (y, a) -> y + a + x) as v from nested;

-- Aggregate average.
select aggregate(ys, (0 as sum, 0 as n), (acc, x) -> (acc.sum + x, acc.n + 1), acc -> acc.sum / acc.n) as v from nested;

-- Aggregate nested arrays
select transform(zs, z -> aggregate(z, 1, (acc, val) -> acc * val * size(z))) as v from nested;

-- Aggregate a null array
select aggregate(cast(null as array<int>), 0, (a, y) -> a + y + 1, a -> a + 2) as v;

-- Check for element existence
select exists(ys, y -> y > 30) as v from nested;

-- Check for element existence in a null array
select exists(cast(null as array<int>), y -> y > 30) as v;

-- Zip with array
select zip_with(ys, zs, (a, b) -> a + size(b)) as v from nested;

-- Zip with array with concat
select zip_with(array('a', 'b', 'c'), array('d', 'e', 'f'), (x, y) -> concat(x, y)) as v;

-- Zip with array coalesce
select zip_with(array('a'), array('d', null, 'f'), (x, y) -> coalesce(x, y)) as v;

create or replace temporary view nested as values
  (1, map(1, 1, 2, 2, 3, 3)),
  (2, map(4, 4, 5, 5, 6, 6))
  as t(x, ys);

-- Identity Transform Keys in a map
select transform_keys(ys, (k, v) -> k) as v from nested;

-- Transform Keys in a map by adding constant
select transform_keys(ys, (k, v) -> k + 1) as v from nested;

-- Transform Keys in a map using values
select transform_keys(ys, (k, v) -> k + v) as v from nested;

-- Identity Transform values in a map
select transform_values(ys, (k, v) -> v) as v from nested;

-- Transform values in a map by adding constant
select transform_values(ys, (k, v) -> v + 1) as v from nested;

-- Transform values in a map using values
select transform_values(ys, (k, v) -> k + v) as v from nested;
-- Test data.
CREATE OR REPLACE TEMPORARY VIEW testData AS SELECT * FROM VALUES
(1, 1), (1, 2), (2, 1), (1, 1), (null, 2), (1, null), (null, null)
AS testData(a, b);

-- count with single expression
SELECT
  count(*), count(1), count(null), count(a), count(b), count(a + b), count((a, b))
FROM testData;

-- distinct count with single expression
SELECT
  count(DISTINCT 1),
  count(DISTINCT null),
  count(DISTINCT a),
  count(DISTINCT b),
  count(DISTINCT (a + b)),
  count(DISTINCT (a, b))
FROM testData;

-- count with multiple expressions
SELECT count(a, b), count(b, a), count(testData.*) FROM testData;

-- distinct count with multiple expressions
SELECT
  count(DISTINCT a, b), count(DISTINCT b, a), count(DISTINCT *), count(DISTINCT testData.*)
FROM testData;
select sum(lo_extendedprice*lo_discount) as revenue
	from lineorder, date
	where lo_orderdate = d_datekey
		and d_year = 1993
		and lo_discount between 1 and 3
		and lo_quantity < 25
select d_year, c_nation, sum(lo_revenue-lo_supplycost) as profit1
	from date, customer, supplier, part, lineorder
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_partkey = p_partkey
		and lo_orderdate = d_datekey
		and c_region = 'AMERICA'
		and s_region = 'AMERICA'
		and (p_mfgr = 'MFGR#1' or p_mfgr = 'MFGR#2')
	group by d_year, c_nation
	order by d_year, c_nation
select c_city, s_city, d_year, sum(lo_revenue) as revenue
	from customer, lineorder, supplier, date
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_orderdate = d_datekey
		and c_nation = 'UNITED KINGDOM'
		and (c_city='UNITED KI1' or c_city='UNITED KI5')
		and (s_city='UNITED KI1' or s_city='UNITED KI5')
		and s_nation = 'UNITED KINGDOM'
		and d_yearmonth = 'Dec1997'
	group by c_city, s_city, d_year
	order by d_year asc, revenue desc
select sum(lo_extendedprice*lo_discount) as revenue
	from lineorder, date
	where lo_orderdate = d_datekey
		and d_yearmonthnum = 199401
		and lo_discount between 4 and 6
		and lo_quantity between 26 and 35
select sum(lo_extendedprice*lo_discount) as revenue
	from lineorder, date
	where lo_orderdate = d_datekey
		and d_weeknuminyear = 6 and d_year = 1994
		and lo_discount between 5 and 7
		and lo_quantity between 36 and 40
select sum(lo_revenue), d_year, p_brand1
	from lineorder, date, part, supplier
	where lo_orderdate = d_datekey
		and lo_partkey = p_partkey
		and lo_suppkey = s_suppkey
		and p_category = 'MFGR#12'
		and s_region = 'AMERICA'
	group by d_year, p_brand1
	order by d_year, p_brand1
select c_city, s_city, d_year, sum(lo_revenue) as revenue
	from customer, lineorder, supplier, date
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_orderdate = d_datekey
		and c_nation = 'UNITED KINGDOM'
		and (c_city='UNITED KI1' or c_city='UNITED KI5')
		and (s_city='UNITED KI1' or s_city='UNITED KI5')
		and s_nation = 'UNITED KINGDOM'
		and d_year >= 1992 and d_year <= 1997
	group by c_city, s_city, d_year
	order by d_year asc, revenue desc
select sum(lo_revenue), d_year, p_brand1
	from lineorder, date, part, supplier
	where lo_orderdate = d_datekey
		and lo_partkey = p_partkey
		and lo_suppkey = s_suppkey
		and p_brand1 between 'MFGR#2221' and 'MFGR#2228'
		and s_region = 'ASIA'
	group by d_year, p_brand1
	order by d_year, p_brand1
select d_year, s_city, p_brand1, sum(lo_revenue-lo_supplycost) as profit1
	from date, customer, supplier, part, lineorder
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_partkey = p_partkey
		and lo_orderdate = d_datekey
		and c_region = 'AMERICA'
		and s_nation = 'UNITED STATES'
		and (d_year = 1997 or d_year = 1998)
		and p_category = 'MFGR#14'
	group by d_year, s_city, p_brand1
	order by d_year, s_city, p_brand1
select c_city, s_city, d_year, sum(lo_revenue) as revenue
	from customer, lineorder, supplier, date
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_orderdate = d_datekey
		and c_nation = 'UNITED STATES'
		and s_nation = 'UNITED STATES'
		and d_year >= 1992 and d_year <= 1997
	group by c_city, s_city, d_year
	order by d_year asc, revenue desc
select d_year, s_nation, p_category, sum(lo_revenue-lo_supplycost) as profit1
	from date, customer, supplier, part, lineorder
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_partkey = p_partkey
		and lo_orderdate = d_datekey
		and c_region = 'AMERICA'
		and s_region = 'AMERICA'
		and (d_year = 1997 or d_year = 1998)
		and (p_mfgr = 'MFGR#1' or p_mfgr = 'MFGR#2')
	group by d_year, s_nation, p_category
	order by d_year, s_nation, p_category
select sum(lo_revenue), d_year, p_brand1
	from lineorder, date, part, supplier
	where lo_orderdate = d_datekey
		and lo_partkey = p_partkey
		and lo_suppkey = s_suppkey
		and p_brand1 = 'MFGR#2221'
		and s_region = 'EUROPE'
	group by d_year, p_brand1
	order by d_year, p_brand1
select c_nation, s_nation, d_year, sum(lo_revenue) as revenue
	from customer, lineorder, supplier, date
	where lo_custkey = c_custkey
		and lo_suppkey = s_suppkey
		and lo_orderdate = d_datekey
		and c_region = 'ASIA'
		and s_region = 'ASIA'
		and d_year >= 1992 and d_year <= 1997
	group by c_nation, s_nation, d_year
	order by d_year asc, revenue desc
-- using default substitutions

select
	c_custkey,
	c_name,
	sum(l_extendedprice * (1 - l_discount)) as revenue,
	c_acctbal,
	n_name,
	c_address,
	c_phone,
	c_comment
from
	customer,
	orders,
	lineitem,
	nation
where
	c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and o_orderdate >= date '1993-10-01'
	and o_orderdate < date '1993-10-01' + interval '3' month
	and l_returnflag = 'R'
	and c_nationkey = n_nationkey
group by
	c_custkey,
	c_name,
	c_acctbal,
	c_phone,
	n_name,
	c_address,
	c_comment
order by
	revenue desc
limit 20
-- using default substitutions

select
	c_count,
	count(*) as custdist
from
	(
		select
			c_custkey,
			count(o_orderkey) as c_count
		from
			customer left outer join orders on
				c_custkey = o_custkey
				and o_comment not like '%special%requests%'
		group by
			c_custkey
	) as c_orders
group by
	c_count
order by
	custdist desc,
	c_count desc
-- using default substitutions

select
	n_name,
	sum(l_extendedprice * (1 - l_discount)) as revenue
from
	customer,
	orders,
	lineitem,
	supplier,
	nation,
	region
where
	c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and l_suppkey = s_suppkey
	and c_nationkey = s_nationkey
	and s_nationkey = n_nationkey
	and n_regionkey = r_regionkey
	and r_name = 'ASIA'
	and o_orderdate >= date '1994-01-01'
	and o_orderdate < date '1994-01-01' + interval '1' year
group by
	n_name
order by
	revenue desc
-- using default substitutions

select
	s_name,
	count(*) as numwait
from
	supplier,
	lineitem l1,
	orders,
	nation
where
	s_suppkey = l1.l_suppkey
	and o_orderkey = l1.l_orderkey
	and o_orderstatus = 'F'
	and l1.l_receiptdate > l1.l_commitdate
	and exists (
		select
			*
		from
			lineitem l2
		where
			l2.l_orderkey = l1.l_orderkey
			and l2.l_suppkey <> l1.l_suppkey
	)
	and not exists (
		select
			*
		from
			lineitem l3
		where
			l3.l_orderkey = l1.l_orderkey
			and l3.l_suppkey <> l1.l_suppkey
			and l3.l_receiptdate > l3.l_commitdate
	)
	and s_nationkey = n_nationkey
	and n_name = 'SAUDI ARABIA'
group by
	s_name
order by
	numwait desc,
	s_name
limit 100-- using default substitutions

select
	l_returnflag,
	l_linestatus,
	sum(l_quantity) as sum_qty,
	sum(l_extendedprice) as sum_base_price,
	sum(l_extendedprice * (1 - l_discount)) as sum_disc_price,
	sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge,
	avg(l_quantity) as avg_qty,
	avg(l_extendedprice) as avg_price,
	avg(l_discount) as avg_disc,
	count(*) as count_order
from
	lineitem
where
	l_shipdate <= date '1998-12-01' - interval '90' day
group by
	l_returnflag,
	l_linestatus
order by
	l_returnflag,
	l_linestatus
-- using default substitutions

select
	supp_nation,
	cust_nation,
	l_year,
	sum(volume) as revenue
from
	(
		select
			n1.n_name as supp_nation,
			n2.n_name as cust_nation,
			year(l_shipdate) as l_year,
			l_extendedprice * (1 - l_discount) as volume
		from
			supplier,
			lineitem,
			orders,
			customer,
			nation n1,
			nation n2
		where
			s_suppkey = l_suppkey
			and o_orderkey = l_orderkey
			and c_custkey = o_custkey
			and s_nationkey = n1.n_nationkey
			and c_nationkey = n2.n_nationkey
			and (
				(n1.n_name = 'FRANCE' and n2.n_name = 'GERMANY')
				or (n1.n_name = 'GERMANY' and n2.n_name = 'FRANCE')
			)
			and l_shipdate between date '1995-01-01' and date '1996-12-31'
	) as shipping
group by
	supp_nation,
	cust_nation,
	l_year
order by
	supp_nation,
	cust_nation,
	l_year
-- using default substitutions

select
	nation,
	o_year,
	sum(amount) as sum_profit
from
	(
		select
			n_name as nation,
			year(o_orderdate) as o_year,
			l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity as amount
		from
			part,
			supplier,
			lineitem,
			partsupp,
			orders,
			nation
		where
			s_suppkey = l_suppkey
			and ps_suppkey = l_suppkey
			and ps_partkey = l_partkey
			and p_partkey = l_partkey
			and o_orderkey = l_orderkey
			and s_nationkey = n_nationkey
			and p_name like '%green%'
	) as profit
group by
	nation,
	o_year
order by
	nation,
	o_year desc
-- using default substitutions

select
	s_acctbal,
	s_name,
	n_name,
	p_partkey,
	p_mfgr,
	s_address,
	s_phone,
	s_comment
from
	part,
	supplier,
	partsupp,
	nation,
	region
where
	p_partkey = ps_partkey
	and s_suppkey = ps_suppkey
	and p_size = 15
	and p_type like '%BRASS'
	and s_nationkey = n_nationkey
	and n_regionkey = r_regionkey
	and r_name = 'EUROPE'
	and ps_supplycost = (
		select
			min(ps_supplycost)
		from
			partsupp,
			supplier,
			nation,
			region
		where
			p_partkey = ps_partkey
			and s_suppkey = ps_suppkey
			and s_nationkey = n_nationkey
			and n_regionkey = r_regionkey
			and r_name = 'EUROPE'
	)
order by
	s_acctbal desc,
	n_name,
	s_name,
	p_partkey
limit 100
-- using default substitutions

select
	o_year,
	sum(case
		when nation = 'BRAZIL' then volume
		else 0
	end) / sum(volume) as mkt_share
from
	(
		select
			year(o_orderdate) as o_year,
			l_extendedprice * (1 - l_discount) as volume,
			n2.n_name as nation
		from
			part,
			supplier,
			lineitem,
			orders,
			customer,
			nation n1,
			nation n2,
			region
		where
			p_partkey = l_partkey
			and s_suppkey = l_suppkey
			and l_orderkey = o_orderkey
			and o_custkey = c_custkey
			and c_nationkey = n1.n_nationkey
			and n1.n_regionkey = r_regionkey
			and r_name = 'AMERICA'
			and s_nationkey = n2.n_nationkey
			and o_orderdate between date '1995-01-01' and date '1996-12-31'
			and p_type = 'ECONOMY ANODIZED STEEL'
	) as all_nations
group by
	o_year
order by
	o_year
-- using default substitutions

select
	s_name,
	s_address
from
	supplier,
	nation
where
	s_suppkey in (
		select
			ps_suppkey
		from
			partsupp
		where
			ps_partkey in (
				select
					p_partkey
				from
					part
				where
					p_name like 'forest%'
			)
			and ps_availqty > (
				select
					0.5 * sum(l_quantity)
				from
					lineitem
				where
					l_partkey = ps_partkey
					and l_suppkey = ps_suppkey
					and l_shipdate >= date '1994-01-01'
					and l_shipdate < date '1994-01-01' + interval '1' year
			)
	)
	and s_nationkey = n_nationkey
	and n_name = 'CANADA'
order by
	s_name
-- using default substitutions

select
	cntrycode,
	count(*) as numcust,
	sum(c_acctbal) as totacctbal
from
	(
		select
			substring(c_phone, 1, 2) as cntrycode,
			c_acctbal
		from
			customer
		where
			substring(c_phone, 1, 2) in
				('13', '31', '23', '29', '30', '18', '17')
			and c_acctbal > (
				select
					avg(c_acctbal)
				from
					customer
				where
					c_acctbal > 0.00
					and substring(c_phone, 1, 2) in
						('13', '31', '23', '29', '30', '18', '17')
			)
			and not exists (
				select
					*
				from
					orders
				where
					o_custkey = c_custkey
			)
	) as custsale
group by
	cntrycode
order by
	cntrycode
-- using default substitutions

select
	o_orderpriority,
	count(*) as order_count
from
	orders
where
	o_orderdate >= date '1993-07-01'
	and o_orderdate < date '1993-07-01' + interval '3' month
	and exists (
		select
			*
		from
			lineitem
		where
			l_orderkey = o_orderkey
			and l_commitdate < l_receiptdate
	)
group by
	o_orderpriority
order by
	o_orderpriority
-- using default substitutions

with revenue0 as
	(select
		l_suppkey as supplier_no,
		sum(l_extendedprice * (1 - l_discount)) as total_revenue
	from
		lineitem
	where
		l_shipdate >= date '1996-01-01'
		and l_shipdate < date '1996-01-01' + interval '3' month
	group by
		l_suppkey)


select
	s_suppkey,
	s_name,
	s_address,
	s_phone,
	total_revenue
from
	supplier,
	revenue0
where
	s_suppkey = supplier_no
	and total_revenue = (
		select
			max(total_revenue)
		from
			revenue0
	)
order by
	s_suppkey

-- using default substitutions

select
	sum(l_extendedprice * l_discount) as revenue
from
	lineitem
where
	l_shipdate >= date '1994-01-01'
	and l_shipdate < date '1994-01-01' + interval '1' year
	and l_discount between .06 - 0.01 and .06 + 0.01
	and l_quantity < 24
-- using default substitutions

select
	l_shipmode,
	sum(case
		when o_orderpriority = '1-URGENT'
			or o_orderpriority = '2-HIGH'
			then 1
		else 0
	end) as high_line_count,
	sum(case
		when o_orderpriority <> '1-URGENT'
			and o_orderpriority <> '2-HIGH'
			then 1
		else 0
	end) as low_line_count
from
	orders,
	lineitem
where
	o_orderkey = l_orderkey
	and l_shipmode in ('MAIL', 'SHIP')
	and l_commitdate < l_receiptdate
	and l_shipdate < l_commitdate
	and l_receiptdate >= date '1994-01-01'
	and l_receiptdate < date '1994-01-01' + interval '1' year
group by
	l_shipmode
order by
	l_shipmode
-- using default substitutions

select
	l_orderkey,
	sum(l_extendedprice * (1 - l_discount)) as revenue,
	o_orderdate,
	o_shippriority
from
	customer,
	orders,
	lineitem
where
	c_mktsegment = 'BUILDING'
	and c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and o_orderdate < date '1995-03-15'
	and l_shipdate > date '1995-03-15'
group by
	l_orderkey,
	o_orderdate,
	o_shippriority
order by
	revenue desc,
	o_orderdate
limit 10
-- using default substitutions

select
	sum(l_extendedprice* (1 - l_discount)) as revenue
from
	lineitem,
	part
where
	(
		p_partkey = l_partkey
		and p_brand = 'Brand#12'
		and p_container in ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')
		and l_quantity >= 1 and l_quantity <= 1 + 10
		and p_size between 1 and 5
		and l_shipmode in ('AIR', 'AIR REG')
		and l_shipinstruct = 'DELIVER IN PERSON'
	)
	or
	(
		p_partkey = l_partkey
		and p_brand = 'Brand#23'
		and p_container in ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')
		and l_quantity >= 10 and l_quantity <= 10 + 10
		and p_size between 1 and 10
		and l_shipmode in ('AIR', 'AIR REG')
		and l_shipinstruct = 'DELIVER IN PERSON'
	)
	or
	(
		p_partkey = l_partkey
		and p_brand = 'Brand#34'
		and p_container in ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')
		and l_quantity >= 20 and l_quantity <= 20 + 10
		and p_size between 1 and 15
		and l_shipmode in ('AIR', 'AIR REG')
		and l_shipinstruct = 'DELIVER IN PERSON'
	)
-- using default substitutions

select
	100.00 * sum(case
		when p_type like 'PROMO%'
			then l_extendedprice * (1 - l_discount)
		else 0
	end) / sum(l_extendedprice * (1 - l_discount)) as promo_revenue
from
	lineitem,
	part
where
	l_partkey = p_partkey
	and l_shipdate >= date '1995-09-01'
	and l_shipdate < date '1995-09-01' + interval '1' month
-- using default substitutions

select
	sum(l_extendedprice) / 7.0 as avg_yearly
from
	lineitem,
	part
where
	p_partkey = l_partkey
	and p_brand = 'Brand#23'
	and p_container = 'MED BOX'
	and l_quantity < (
		select
			0.2 * avg(l_quantity)
		from
			lineitem
		where
			l_partkey = p_partkey
	)
-- using default substitutions

select
	c_name,
	c_custkey,
	o_orderkey,
	o_orderdate,
	o_totalprice,
	sum(l_quantity)
from
	customer,
	orders,
	lineitem
where
	o_orderkey in (
		select
			l_orderkey
		from
			lineitem
		group by
			l_orderkey having
				sum(l_quantity) > 300
	)
	and c_custkey = o_custkey
	and o_orderkey = l_orderkey
group by
	c_name,
	c_custkey,
	o_orderkey,
	o_orderdate,
	o_totalprice
order by
	o_totalprice desc,
	o_orderdate
limit 100-- using default substitutions

select
	p_brand,
	p_type,
	p_size,
	count(distinct ps_suppkey) as supplier_cnt
from
	partsupp,
	part
where
	p_partkey = ps_partkey
	and p_brand <> 'Brand#45'
	and p_type not like 'MEDIUM POLISHED%'
	and p_size in (49, 14, 23, 45, 19, 3, 36, 9)
	and ps_suppkey not in (
		select
			s_suppkey
		from
			supplier
		where
			s_comment like '%Customer%Complaints%'
	)
group by
	p_brand,
	p_type,
	p_size
order by
	supplier_cnt desc,
	p_brand,
	p_type,
	p_size
-- using default substitutions

select
	ps_partkey,
	sum(ps_supplycost * ps_availqty) as value
from
	partsupp,
	supplier,
	nation
where
	ps_suppkey = s_suppkey
	and s_nationkey = n_nationkey
	and n_name = 'GERMANY'
group by
	ps_partkey having
		sum(ps_supplycost * ps_availqty) > (
			select
				sum(ps_supplycost * ps_availqty) * 0.0001000000
			from
				partsupp,
				supplier,
				nation
			where
				ps_suppkey = s_suppkey
				and s_nationkey = n_nationkey
				and n_name = 'GERMANY'
		)
order by
	value desc
