
rem https://github.com/oracle/analytical-sql-examples/tree/c5e889d4c0df3d3c2b2b9c3dfac543ec31986a14/analytical-sql/Scripts


rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem  ****************************************************************
rem

rem  scripts to demonstrate how to use MATCH_RECOGNIZE
rem  clause for sql pattern matching
rem



/* Create required tables/views
*/


/*
Part 1 -
*/

SELECT * FROM Ticker
MATCH_RECOGNIZE
(PARTITION BY symbol
 ORDER BY tstamp
 MEASURES
   STRT.tstamp AS start_tstamp,
   FINAL LAST(DOWN.tstamp) AS bottom_tstamp,
   FINAL LAST(UP.tstamp) AS end_tstamp
 ALL ROW PER MATCH
 AFTER MATCH SKIP TO LAST UP
 PATTERN (STRT DOWN+ UP+)
 DEFINE
    DOWN AS DOWN.price < PREV(DOWN.price),
    UP AS UP.price > PREV(UP.price)) MR


rem  can I filter my results so I only see one ticker?
rem  Yes, note that we reference the MATCH_RECOGNIZE
rem  block with the suffice MR which allows us to interact
rem  the result set that is returned.

SELECT * FROM Ticker MATCH_RECOGNIZE
(PARTITION BY symbol
 ORDER BY tstamp
 MEASURES
    STRT.tstamp AS start_tstamp,
    FINAL LAST(DOWN.tstamp) AS bottom_tstamp,
    FINAL LAST(UP.tstamp) AS end_tstamp,
    MATCH_NUMBER() AS match_num,
    CLASSIFIER() AS var_match
 ONE ROW PER MATCH
 AFTER MATCH SKIP TO LAST UP
 PATTERN (STRT DOWN+ UP+)
 DEFINE
   DOWN AS DOWN.price < PREV(DOWN.price),
   UP AS UP.price > PREV(UP.price)) MR
WHERE symbol='ACME'
ORDER BY MR.symbol, MR.match_num, MR.tstamp;



/*
Part 2 -
*/

rem  lets build another example using sessionization
rem  where we define a sessions as containing group
rem  of clicks that are within 10 seconds of each other

SELECT *
FROM clickdata
MATCH_RECOGNIZE
(MEASURES
  userid as user_id,
  MATCH_NUMBER() AS session_id,
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,
  LAST(tstamp) - FIRST(tstamp) as sess_duration
 ALL ROWS PER MATCH
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));


rem  what is missing from the above statement?
rem  we need to add in the partition by clause
rem  so is this output correct?


SELECT *
FROM clickdata
MATCH_RECOGNIZE
(PARTITION BY userid
 MEASURES
  userid as user_id,
  MATCH_NUMBER() AS session_id,
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,
  LAST(tstamp) - FIRST(tstamp) as sess_duration
 ALL ROWS PER MATCH
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));


rem  what if we want a summary report?
rem

SELECT *
FROM clickdata
MATCH_RECOGNIZE
(PARTITION BY userid
 ORDER BY tstamp
 MEASURES
  userid as user_id,
  MATCH_NUMBER() AS session_id,
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,
  LAST(tstamp) - FIRST(tstamp) as sess_duration
 ONE ROW PER MATCH
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));




rem  can we find out how the pattern is being interpreted on each row?

SELECT *
FROM clickdata
MATCH_RECOGNIZE
(PARTITION BY userid
 ORDER BY tstamp
 MEASURES
  userid as user_id,
  MATCH_NUMBER() AS session_id,
  COUNT(*) as no_of_events,
  FIRST(tstamp) as start_time,
  LAST(tstamp) - FIRST(tstamp) as sess_duration
 ALL ROWsS PER MATCH
 PATTERN (strt s*)
 DEFINE
   s AS (s.tstamp - prev(s.tstamp) <=10));



rem  makes a little more sense if we go back to our ticker
rem  dataset as this has more variables within the pattern
rem
rem

SELECT * FROM Ticker MATCH_RECOGNIZE
(PARTITION BY symbol
 ORDER BY tstamp
 MEASURES
  STRT.tstamp AS start_tstamp,
  FINAL LAST(DOWN.tstamp) AS bottom_tstamp,
  FINAL LAST(UP.tstamp) AS end_tstamp,
  MATCH_NUMBER() AS match_num,
  CLASSIFIER() AS var_match
 ALL ROWS PER MATCH
 AFTER MATCH SKIP TO LAST UP
 PATTERN (STRT DOWN+ UP+)
 DEFINE
 DOWN AS DOWN.price < PREV(DOWN.price),
 UP AS UP.price > PREV(UP.price) ) MR
WHERE symbol='ACME'
ORDER BY MR.symbol, MR.match_num, MR.tstamp;


rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem
rem  ****************************************************************

/* Create required tables/views to support scripts
simplified view over sales fact table in sales_history schema
CREATE VIEW sales_view AS
SELECT country_name country,
prod_name product,
calendar_year year,
SUM(amount_sold) sales,
COUNT(amount_sold) cnt,
MAX(calendar_year) KEEP (DENSE_RANK FIRST ORDER BY SUM(amount_sold) DESC) OVER (PARTITION BY country_name, prod_name) best_year,
MAX(calendar_year) KEEP (DENSE_RANK LAST ORDER BY SUM(amount_sold) DESC) OVER (PARTITION BY country_name, prod_name) worst_year
FROM sales, times, customers, countries, products
WHERE sales.time_id = times.time_id
AND sales.prod_id = products.prod_id
AND sales.cust_id =customers.cust_id
AND customers.country_id=countries.country_id
GROUP BY country_name, prod_name, calendar_year;
CREATE TABLE mortgage_facts (customer VARCHAR2(20), fact VARCHAR2(20),
   amount  NUMBER(10,2));
INSERT INTO mortgage_facts  VALUES ('Smith', 'Loan', 100000);
INSERT INTO mortgage_facts  VALUES ('Smith', 'Annual_Interest', 12);
INSERT INTO mortgage_facts  VALUES ('Smith', 'Payments', 360);
INSERT INTO mortgage_facts  VALUES ('Smith', 'Payment', 0);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Loan', 200000);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Annual_Interest', 12);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Payments', 180);
INSERT INTO mortgage_facts  VALUES ('Jones', 'Payment', 0);
CREATE TABLE mortgage (customer VARCHAR2(20), pmt_num NUMBER(4),
   principalp NUMBER(10,2), interestp NUMBER(10,2), mort_balance NUMBER(10,2));
INSERT INTO mortgage VALUES ('Jones',0, 0, 0, 200000);
INSERT INTO mortgage VALUES ('Smith',0, 0, 0, 100000);
CREATE OR REPLACE VIEW sales_rollup_time AS
  SELECT
    country_name country, calendar_year year,
    calendar_quarter_desc quarter,
    grouping_id(calendar_year, calendar_quarter_desc) gid,
    sum(amount_sold) sale, count(amount_sold) cnt
  FROM sales, times, customers, countries
  WHERE sales.time_id = times.time_id and
        sales.cust_id = customers.cust_id and
        customers.country_id = countries.country_id
  GROUP BY country_name, calendar_year, ROLLUP(calendar_quarter_desc)
  ORDER BY gid, country, year, quarter;

rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem
rem  ****************************************************************
rem

rem  scripts to demonstrate how to use the MODEL clause
rem  to apply business rules to data sets
rem


/* Part 1 - complex example
*/

SELECT m+1 month,
            to_char(rem_loan, '99999999.00') rem_loan,
            to_char(loan_paid_tot, '99999999.00') loan_paid_tot,
            to_char(mon_int, '999999.00') mon_int,
            to_char(tot_int, '99999999.00') tot_int,
            to_char(mon_paym, '99999999.00') mon_paym,
            to_char(mon_paym_tot, '99999999.00') mon_paym_tot,
            to_char(grand_tot, '99999999.00') grand_tot
FROM dual
MODEL
DIMENSION BY (-1 m)
MEASURES (&&rem_loan rem_loan,
  round(&&rem_loan*&&year_int_rate/100/12,2) mon_int,
  ceil(&&rem_loan/&&term*100)/100 mon_paym,
  (&&rem_loan/&&term*100)/100 loan_paid_tot,
  round(&&rem_loan*&&year_int_rate/12/100,2) tot_int,
  ceil(&&rem_loan/&&term*100)/100 + round(&&rem_loan*&&year_int_rate/100/12,2) mon_paym_tot,
  ceil(&&rem_loan/&&term*100)/100 + round(&&rem_loan*&&year_int_rate/100/12,2) grand_tot
)
RULES ITERATE (&&term) UNTIL (round(loan_paid_tot[iteration_number], 2) = &&rem_loan) (
  rem_loan[iteration_number] = rem_loan[iteration_number -1] - mon_paym[iteration_number - 1],
  mon_int[iteration_number] = round(rem_loan[iteration_number]*&&year_int_rate/100/12,2),
  mon_paym[iteration_number] = least(ceil(&&rem_loan/&&term*100)/100, rem_loan[iteration_number]),
  loan_paid_tot[iteration_number] = loan_paid_tot[iteration_number - 1] + mon_paym[iteration_number],
  tot_int[iteration_number] = tot_int[iteration_number - 1] + mon_int[iteration_number],
  mon_paym_tot[iteration_number] = mon_paym[iteration_number] + mon_int[iteration_number],
  grand_tot[iteration_number] = grand_tot[iteration_number - 1] + mon_paym_tot[iteration_number]);

rem  extracted from http://gplivna.blogspot.co.uk/2008/10/mortgage-calculator-using-sql-model.html because calculator in Oracle
rem  documentation is not working! Reported as bug.


/*
Part 2 - simple example
*/
rem  here is our source data from the sales history schema
rem

SELECT SUBSTR(country,1,20) country, SUBSTR(product,1,15) product, year, sales FROM sales_view
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box');


rem  this simple example shows two important points. The model clause allows us to:
rem
rem  1) over-write existing data points that are passed to the model
rem  clause and pushed into the array that is built in step 1 of the processing model
rem
rem  2) create new dimension values and data points - again these are added into the
rem  array and are not written into the source table.

SELECT
SUBSTR(country,1,20) country,
SUBSTR(product,1,15) product,
year,
sales
FROM sales_view
WHERE country in ('Italy', 'Japan')
MODEL
RETURN UPDATED ROWS
MAIN simple_model
PARTITION BY (country) DIMENSION BY (product, year) MEASURES (sales)
RULES
(sales['Bounce', 2001] = 1000,
sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000],
sales['Y Box', 2002] = sales['Y Box', 2001])
ORDER BY country, product, year;


rem  having overwritten the original sales value for Bounce in 2001 and then added a new year
rem  value of 2002 and calculated corresponding sales figures, let's check that the original data
rem  has not been modified...
SELECT SUBSTR(country,1,20) country, SUBSTR(product,1,15) product, year, sales FROM sales_view
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box');
rem  If we need to update or insert rows in the database tables then we can use
rem  the INSERT, UPDATE, or MERGE statements to achieve this.
rem  we can refine the model to show the existing sales, updated sales and the
rem  forecasted sales as follows:
SELECT
SUBSTR(country,1,20) country,
SUBSTR(product,1,15) product,
year,
sales,
upd_sales,
forecast
FROM sales_view
WHERE country in ('Italy', 'Japan')
MODEL
RETURN UPDATED ROWS
MAIN simple_model
PARTITION BY (country)
DIMENSION BY (product, year)
MEASURES (sales, 0 AS forecast, 0 AS upd_sales)
RULES
(upd_sales['Bounce', 2001] = 1000,
forecast['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000],
forecast['Y Box', 2002] = sales['Y Box', 2001])
ORDER BY country, product, year;
rem  The following example shows how to use expressions and aliases within the
rem  model clause:
SELECT
  country,
  p product,
  year,
  sales,
  profits
FROM sales_view
WHERE country IN ('Italy', 'Japan')
MODEL
RETURN UPDATED ROWS
PARTITION BY (SUBSTR(country,1,20) AS country) DIMENSION BY (product AS p, year)
MEASURES (sales, 0 AS profits) RULES
(profits['Bounce', 2001] = sales['Bounce', 2001] * 0.25,
 sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000],
 profits['Bounce', 2002] = sales['Bounce', 2002] * 0.35)
ORDER BY country, year;
rem  Note that the alias "0 AS profits" initializes all cells of the profits measure to 0.
rem  We can include window functions ont the righthand side of a rule such as to
rem  create a running total within a model. The cumulative sum window functions is evaluated over all
rem  rows qualified by the left side of the rule. In the above case, they are all the rows coming
rem  to the Model clause. as shown below:
rem
select *
FROM SALES_VIEW
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box')
MODEL
   PARTITION BY (product)
   DIMENSION BY (country, year)
   MEASURES (sales, 0 AS csum)
   RULES upsert
     (csum[ANY,ANY] = SUM(sales) OVER (PARTITION BY country ORDER BY year));

rem  Beacuse the MODEL clause is so flexible it is possible to use it instead
rem  of/as a replacement for existing SQL functions/features
rem
rem  We can use MODEL clause to calculate/derive totals/sub-totals in the same
rem  way that CUBE-ROLLUP work but in this case we need to directly
rem  specify the values that we want to compute and how they are
rem  computed
SELECT
  SUBSTR(country, 1, 20) country,
  SUBSTR(product, 1, 15) product,
  year,
  sales
FROM sales_view
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box')
MODEL
PARTITION BY (country) DIMENSION BY (product, year)
MEASURES (sales sales)
RULES
(sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000],
 sales['Y Box', 2002] = sales['Y Box', 2001],
 sales['All_Products', 2002] = sales['Bounce', 2002] + sales['Y Box', 2002])
ORDER BY country, product, year;
rem  one of the issues here is that you need to be careful with the ordering of the
rem  ouptut set. In this case the derived total for 'All Products' appears as the first product
rem  which may or may not be the correct position but the ordering is determined by the
rem  final ORDER BY clause.
rem  we can create a LAG calculation using the following syntax:
rem
SELECT
  SUBSTR(country, 1, 20) country,
  SUBSTR(product, 1, 15) product,
  year,
  sales,
  new_sales
FROM sales_view
WHERE country IN ('Italy', 'Japan')
AND product IN ('Bounce', 'Y Box')
MODEL
PARTITION BY (product) DIMENSION BY (country, year)
MEASURES (sales, 0 AS new_sales)
RULES
(new_sales[country IS ANY, year BETWEEN 2000 AND 2003] ORDER BY year = 1.05 * sales[CV(country), CV(year)-1])
ORDER BY country, product, year;

rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem
rem If you need to reset your buffer cache during this session, i.e.
rem when you are reviewing explain plans etc then you might find
rem this commmand usefyul:
rem
rem alter system flush buffer_cache;
rem

rem  the following query just introduces analytical SQL
rem  by creating a cumulative/running total for salary
rem  note the extension to the SUM() function using
rem  the OVER and ORDER BY key words
rem

rem Assumes that you have installed the sales history schema from the
rem examples CD. The following lines of code create all the required
rem additional views needed for this series of scripts on analytical
rem  SQL
rem


CREATE OR REPLACE VIEW PRODCAT_MONTHLY_SALES AS
  SELECT
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year,
 SUM(s.amount_sold) AS amount_sold
FROM sales s, products p, times t
WHERE s.prod_id=p.prod_id
AND s.time_id = t.time_id
GROUP BY p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year;


CREATE OR REPLACE VIEW CHAN_PRODCAT_MONTHLY_SALES AS
SELECT
 c.channel_id,
 c.channel_desc,
 c.channel_class_id,
 c.channel_class,
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year,
 SUM(s.amount_sold) AS amount_sold
FROM sales s, products p, times t, channels c
WHERE s.prod_id=p.prod_id
AND s.time_id = t.time_id
AND s.channel_id = c.channel_id
GROUP BY c.channel_id,
 c.channel_desc,
 c.channel_class_id,
 c.channel_class,
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year;

View for doing outer joins on times table to fill in missing values
so we have a dense time colum in our fact tables

CREATE OR REPLACE VIEW MONTHLY_TIMES AS
SELECT
 DISTINCT t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year
FROM times t;

NEEDS REBUILDING FROM THE SALES FACT TABLE

CREATE OR REPLACE VIEW DENSE_CHAN_PRODCAT_MONTHLY_SALES AS
SELECT
 PROD_SUBCATEGORY_DESC,
 CHANNEL_DESC,
 calendar_QUARTER_DESC,
 CALENDAR_MONTH_DESC,
 AMOUNT_SOLD
FROM
(SELECT
 s.prod_subcategory_desc AS prod_subcategory,
 s.channel_desc AS channel_id,
 s.calendar_quarter_desc AS quarter_id,
 s.calendar_month_desc AS month_id,
 s.amount_sold AS sales
FROM CHAN_PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_id not in (2051, 2031)) v
PARTITION BY (v.prod_subcategory,v.channel_id)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id,
 t.calendar_month_desc AS calendar_month_desc
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.month_id = t.calendar_month_id AND v.quarter_id = t.calendar_quarter_id)
ORDER BY 1,2,3,4;


CREATE OR REPLACE VIEW DENSE_CAMERA_SALES AS
select
 v.prod_subcategory_desc AS prod_subcategory_desc,
 t.calendar_quarter_id AS calendar_quarter_desc,
 t.calendar_month_id AS calendar_month_desc,
 v.amount_sold AS amount_sold
from
(SELECT
 s.prod_subcategory_desc AS prod_subcategory_desc,
 s.calendar_quarter_desc AS calendar_quarter_desc,
 s.calendar_month_desc AS calendar_month_desc,
 s.amount_sold AS amount_sold
FROM PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_desc = 'Cameras') v
PARTITION BY (v.prod_subcategory_desc)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.calendar_month_desc = t.calendar_month_id AND v.calendar_quarter_desc = t.calendar_quarter_id);


Need this view to show the process for managing sparsity/nulls within moving average

CREATE OR REPLACE VIEW DENSE_PRODCAT_MONTHLY_SALES AS
SELECT
 PROD_SUBCATEGORY_DESC,
 calendar_QUARTER_DESC,
 CALENDAR_MONTH_DESC,
 AMOUNT_SOLD
FROM
(SELECT
 s.prod_subcategory_desc AS prod_subcategory,
 s.channel_desc AS channel_id,
 s.calendar_quarter_desc AS quarter_id,
 s.calendar_month_desc AS month_id,
 s.amount_sold AS sales
FROM CHAN_PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_id not in (2051, 2031)) v
PARTITION BY (v.prod_subcategory,v.channel_id)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id,
 t.calendar_month_desc AS calendar_month_desc
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.month_id = t.calendar_month_id AND v.quarter_id = t.calendar_quarter_id)
ORDER BY 1,2,3,4;


Need this view to show the process for managing duplicates within moving average

CREATE OR REPLACE VIEW DENSE_DUPLICATE_CAMERA_SALES AS
SELECT
 prod_subcategory_desc,
 calendar_quarter_desc,
 calendar_month_desc,
 amount_sold
FROM DENSE_CAMERA_SALES
UNION
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales
FROM DENSE_CAMERA_SALES
  MODEL RETURN UPDATED ROWS
     PARTITION BY (prod_subcategory_desc)
     DIMENSION BY (calendar_quarter_desc, calendar_month_desc)
     MEASURES (amount_sold amount_sold)
     RULES (amount_sold['1999-04', '1999-11'] = amount_sold['1999-01', '1999-01']);


view to create duplicate rows for ranking....

CREATE OR REPLACE VIEW DUPLICATE_RANK_ROWS AS
SELECT * FROM
(SELECT
 channel_class,
 prod_subcategory_desc,
 SUM(amount_sold) AS amount_sold
FROM channels c,
(SELECT *
FROM CHAN_PRODCAT_MONTHLY_SALES
MODEL RETURN UPDATED ROWS
     PARTITION BY (calendar_month_id, channel_id)
     DIMENSION BY (prod_subcategory_id)
     MEASURES (amount_sold, prod_subcategory_desc)
     RULES (amount_sold['9998'] = amount_sold['2044'],
            prod_subcategory_desc['9998'] = 'Tablet',
            amount_sold['9999'] = amount_sold['2044'],
            prod_subcategory_desc['9999'] = 'Smartphone')) n
WHERE n.channel_id = c.channel_id
GROUP BY  channel_class, prod_subcategory_desc
UNION
SELECT
 channel_class,
 prod_subcategory_desc,
 SUM(amount_sold) AS amount_sold
FROM CHAN_PRODCAT_MONTHLY_SALES
GROUP BY  channel_class, prod_subcategory_desc)
ORDER BY 3;

rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem
rem alter system flush buffer_cache;
pause press return



rem  the following query just introduces analytical SQL
rem  by creating a cumulative/running total for salary
rem  note the extension to the SUM() function using
rem  the OVER and ORDER BY key words

/*
Assumes that you have installed the sales history schema from the
examples CD.
*/

CREATE OR REPLACE VIEW PRODCAT_MONTHLY_SALES AS
  SELECT
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year,
 SUM(s.amount_sold) AS amount_sold
FROM sales s, products p, times t
WHERE s.prod_id=p.prod_id
AND s.time_id = t.time_id
GROUP BY p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year;


CREATE OR REPLACE VIEW CHAN_PRODCAT_MONTHLY_SALES AS
SELECT
 c.channel_id,
 c.channel_desc,
 c.channel_class_id,
 c.channel_class,
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year,
 SUM(s.amount_sold) AS amount_sold
FROM sales s, products p, times t, channels c
WHERE s.prod_id=p.prod_id
AND s.time_id = t.time_id
AND s.channel_id = c.channel_id
GROUP BY c.channel_id,
 c.channel_desc,
 c.channel_class_id,
 c.channel_class,
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year;

View for doing outer joins on times table to fill in missing values
so we have a dense time colum in our fact tables

CREATE OR REPLACE VIEW MONTHLY_TIMES AS
SELECT
 DISTINCT t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year
FROM times t;

NEEDS REBUILDING FROM THE SALES FACT TABLE

CREATE OR REPLACE VIEW DENSE_CHAN_PRODCAT_MTH_SALES AS
SELECT
 PROD_SUBCATEGORY,
 CHANNEL_ID,
 CALENDAR_QUARTER_ID,
 CALENDAR_MONTH_DESC,
 AMOUNT_SOLD
FROM
(SELECT
 s.prod_subcategory_desc AS prod_subcategory,
 s.channel_desc AS channel_id,
 s.calendar_quarter_desc AS quarter_id,
 s.calendar_month_desc AS month_id,
 s.amount_sold AS amount_sold
FROM CHAN_PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_id not in (2051, 2031)) v
PARTITION BY (v.prod_subcategory,v.channel_id)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id,
 t.calendar_month_desc AS calendar_month_desc
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.month_id = t.calendar_month_id AND v.quarter_id = t.calendar_quarter_id)
ORDER BY 1,2,3,4;


CREATE OR REPLACE VIEW DENSE_CAMERA_SALES AS
select
 v.prod_subcategory_desc AS prod_subcategory_desc,
 t.calendar_quarter_id AS calendar_quarter_desc,
 t.calendar_month_id AS calendar_month_desc,
 v.amount_sold AS amount_sold
from
(SELECT
 s.prod_subcategory_desc AS prod_subcategory_desc,
 s.calendar_quarter_desc AS calendar_quarter_desc,
 s.calendar_month_desc AS calendar_month_desc,
 s.amount_sold AS amount_sold
FROM PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_desc = 'Cameras') v
PARTITION BY (v.prod_subcategory_desc)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.calendar_month_desc = t.calendar_month_id AND v.calendar_quarter_desc = t.calendar_quarter_id);


Need this view to show the process for managing sparsity/nulls within moving average

CREATE OR REPLACE VIEW DENSE_PRODCAT_MONTHLY_SALES AS
SELECT
 PROD_SUBCATEGORY,
 QUARTER_ID,
 MONTH_ID,
 AMOUNT_SOLD
FROM
(SELECT
 s.prod_subcategory_desc AS prod_subcategory,
 s.channel_desc AS channel_id,
 s.calendar_quarter_desc AS quarter_id,
 s.calendar_month_desc AS month_id,
 s.amount_sold AS amount_sold
FROM CHAN_PRODCAT_MONTHLY_SALES s
WHERE prod_subcategory_id not in (2051, 2031)) v
PARTITION BY (v.prod_subcategory,v.channel_id)
RIGHT OUTER JOIN
(SELECT DISTINCT
 t.calendar_quarter_desc AS calendar_quarter_id,
 t.calendar_month_desc AS calendar_month_id,
 t.calendar_month_desc AS calendar_month_desc
FROM MONTHLY_TIMES t
WHERE t.calendar_year_id ='1803') t
on (v.month_id = t.calendar_month_id AND v.quarter_id = t.calendar_quarter_id)
ORDER BY 1,2,3,4;


Need this view to show the process for managing duplicates within moving average

CREATE OR REPLACE VIEW DENSE_DUPLICATE_CAMERA_SALES AS
SELECT
 prod_subcategory_desc,
 calendar_quarter_desc,
 calendar_month_desc,
 amount_sold
FROM DENSE_CAMERA_SALES
UNION
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales
FROM DENSE_CAMERA_SALES
  MODEL RETURN UPDATED ROWS
     PARTITION BY (prod_subcategory_desc)
     DIMENSION BY (calendar_quarter_desc, calendar_month_desc)
     MEASURES (amount_sold amount_sold)
     RULES (amount_sold['1999-04', '1999-11'] = amount_sold['1999-01', '1999-01']);


view to create duplicate rows for ranking....

CREATE OR REPLACE VIEW DUPLICATE_RANK_ROWS AS
SELECT * FROM
(SELECT
 channel_class,
 prod_subcategory_desc,
 SUM(amount_sold) AS amount_sold
FROM channels c,
(SELECT *
FROM CHAN_PRODCAT_MONTHLY_SALES
MODEL RETURN UPDATED ROWS
     PARTITION BY (calendar_month_id, channel_id)
     DIMENSION BY (prod_subcategory_id)
     MEASURES (amount_sold, prod_subcategory_desc)
     RULES (amount_sold['9998'] = amount_sold['2044'],
            prod_subcategory_desc['9998'] = 'Tablet',
            amount_sold['9999'] = amount_sold['2044'],
            prod_subcategory_desc['9999'] = 'Smartphone')) n
WHERE n.channel_id = c.channel_id
GROUP BY  channel_class, prod_subcategory_desc
UNION
SELECT
 channel_class,
 prod_subcategory_desc,
 SUM(amount_sold) AS amount_sold
FROM CHAN_PRODCAT_MONTHLY_SALES
GROUP BY  channel_class, prod_subcategory_desc)
ORDER BY 3;


rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************

rem  scripts to demonstrate how to use the various rollup
rem  features to calculate hierarchical totals within a
rem  cube.
rem
rem  Create more detailed view at PRODUCT level

CREATE OR REPLACE VIEW PROD_MONTHLY_SALES
AS
SELECT
 p.prod_id,
 p.prod_desc,
 p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 t.calendar_month_id,
 t.calendar_month_desc,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_year_id,
 t.calendar_year,
 SUM(s.amount_sold) AS amount_sold
FROM channels c, products p, sales s, times t
WHERE t.time_id = s.time_id (+)
AND s.prod_id = p.prod_id
and s.channel_id = c.channel_id
GROUP BY p.prod_category_id,
 p.prod_category_desc,
 p.prod_subcategory_id,
 p.prod_subcategory_desc,
 p.prod_id,
 p.prod_desc,
 t.calendar_year_id,
 t.calendar_year,
 t.calendar_quarter_id,
 t.calendar_quarter_desc,
 t.calendar_month_id,
 t.calendar_month_desc;



rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Setup script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************

rem  new pivoting source views to make demonstration of pivoting features
rem  a lot easier
rem

CREATE OR REPLACE VIEW PIVOT_CHAN_PRODCAT_SALES AS
SELECT * FROM
(SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 channel_class AS channel,
 sum(amount_sold) AS sales
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc,
         prod_category_desc, channel_class)
PIVOT(sum(sales)
      FOR channel
      IN ('Direct', 'Indirect', 'Others'))
ORDER BY qtr, category;


rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem
rem If you need to reset your buffer cache during this session, i.e.
rem when you are reviewing explain plans etc then you might find
rem this commmand usefyul:
rem
rem alter system flush buffer_cache;
rem



rem  start with a basic report showing a running total for a specific product sub-category
rem  and for a specific year. The report will show the amount sold in each month
rem  and the final column will create a running total.

SELECT
 prod_subcategory_desc AS category,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (ORDER BY calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803';

rem  notice what happens to our running total if we extend
rem  the time range to cover more than one year....
rem  notice that the total does not reset when a new year
rem  starts!

SELECT
 prod_subcategory_desc AS category,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (ORDER BY calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id >='1803';


rem  although the report looks ok this is actually more by chance because
rem  the data happens to be in the correct order in our fact table.
rem  To make sure we always get the data back in the correct order
rem  it is important to include a final ORDER BY clause to ensure the running
rem  totals match up with the order in the final report.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (ORDER BY calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_month_id;


rem  now show what happens if we completely remove the ORDER BY clause - this controls the window
rem  that is used to frame our running total so if we remove the ORDER BY clause then we are
rem  the analytic function to revert to its default processing of using the whole
rem  set as the window.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER () AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_month_id;

rem  then I just get the grand total of all the sales which is similar
rem  to use a SUM() without a GROUP BY clause....the grand total, reported
rem  for each row and this is a useful feature because it
rem  allows us to do row-to-total comparisons.


rem  now let's see what happens if we remove the filter on subcategory description
rem  and view all subcategories?
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER
 (ORDER BY prod_subcategory_id, calendar_month_desc) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY calendar_month_id;
rem  Two points:
rem  1) now we see the importance of the ORDER BY clause both within the analytical
rem  function and the output for the report so what we need to do is extend the
rem  final ORDER BY clause
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER
 (ORDER BY prod_subcategory_id, calendar_month_desc) AS cum_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_id, calendar_month_id;
rem  2) We get a report that shows the running total over all product sub-categories
rem  but notice that there is no break/reset when the sub-category changes!
/*
Part 1b - running totals the hardway...using inline query
*/
rem  Can I create the same report showing cumulative sales without using analytical SQL?
rem  Yes but it can get very messy as we can see here.
rem  As an alternative we could use a view or an inline subquery with group by
rem  clause to generate the totals we need:
SELECT
 pms1.prod_subcategory_desc AS subcategory,
 pms1.calendar_month_desc AS month,
 pms1.amount_sold AS sales,
 (SELECT
   SUM(amount_sold)
  FROM PRODCAT_MONTHLY_SALES pms2
  WHERE calendar_year_id ='1803'
  AND prod_subcategory_desc ='Cameras'
  AND pms2.calendar_month_id <= pms1.calendar_month_id) AS cum_sales
FROM PRODCAT_MONTHLY_SALES pms1
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY pms1.calendar_month_id;
rem  worth looking at the explain plan for both queries as this highlights the additional
rem  simplicity. Performance of the analytic function is much better than the inline subquery
/*
PART 2 of demo script to show how to correctly use PARTITION BY clause.
*/
rem  now we want to use the PARTITION BY clause but without an ORDER BY
rem  clause....note that we have now modified by final ORDER BY clause
rem  to include deptno so that it matches the PARTITION BY clause
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold)
    OVER (PARTITION BY calendar_quarter_id) AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;
rem  so now I have the total sale within each quarter...
rem  As an alternative we could use a view or an inline subquery with group by
rem  clause to generate the quarterly totals we need:
SELECT
 pms1.prod_subcategory_desc AS subcategory,
 pms1.calendar_quarter_desc AS quarter,
 pms1.calendar_month_desc AS month,
 pms1.amount_sold AS sales,
 pms2.tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES pms1,
(SELECT
  calendar_quarter_id,
  SUM(amount_sold) as tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
GROUP BY calendar_quarter_id) pms2
WHERE pms1.prod_subcategory_desc ='Cameras'
AND pms1.calendar_year_id ='1803'
AND pms2.calendar_quarter_id = pms1.calendar_quarter_id
ORDER BY pms1.calendar_quarter_id, pms1.calendar_month_id;
rem  if we extend our analytical SQL SUM() function to include
rem  an ORDER BY clause then you can see in the explain plan
rem  that we do not incur an additional sort because we optimize
rem  and reduce the two ORDER BY clauses to a single SORT operation
rem
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold)
    OVER (PARTITION BY calendar_quarter_id ORDER BY calendar_month_id) AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;
rem  what happens if we have more than one product category?
rem  what do we expect to see? This report produces the total for each
rem  quarter across both product subcategories.
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold)
    OVER (PARTITION BY calendar_quarter_id)
    AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;
rem  what we really need to see is the quarterly total for each product subcategory
rem  as you can see here: if we change the ORDER BY clause to include product subcategory
rem  then the actual order of the rows within the report makes it very difficult to understatand
rem  the values in tot_qtr_sales because the totals apply to each quarter and
rem  are not linked to the product category.
rem
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold)
    OVER (PARTITION BY calendar_quarter_id)
    AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;
rem  what we actually need to do to create quarterly totals for each product subcategory
rem  is extend our PARTITION BY clause to include prod_subcategory_desc and then we need
rem  to include this column in the ORDER BY clause as well:
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold)
    OVER (PARTITION BY prod_subcategory_desc, calendar_quarter_id)
    AS tot_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;
rem  the point of this section was to show that sometimes it can be difficult to
rem  understand how the data being returned is computed. You need to examine it
rem  in detauil to fully understand the results. Therefore, you need to be very
rem  careful in terms of how you use the PARTITION BY and ORDER BY clauses
rem  as these can completely change the results
/*
PART 3 of demo script to show how to correctly use PARTITION BY and ORDER BY.
*/
rem  So now what happens now if we add back in the ORDER BY clause and sort by the
rem  calendar month?
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER
 (PARTITION BY prod_subcategory_desc, calendar_quarter_id ORDER BY calendar_month_id) AS cum_qtr_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;
rem  Now we get a running total within each quarter where the total resets at the boundary of each quarter
rem  What's next.....

rem  now we can extend the example to show the cumulative quarterly sales, total quarterly sales and
rem  total sales for our cameras subcategory.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id ORDER BY calendar_month_id) AS cum_qtr_sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id) AS tot_qtr_sales,
 SUM(amount_sold) OVER () AS tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc in ('Cameras','Camcorders')
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;

rem  once we have the various totals in place we can start using them in calculations
rem  but note that we cannot reference the analytical functions using a column alias
rem  we have to repeat the function to use in within a calculation as shown here:


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id ORDER BY calendar_month_id) AS cum_qtr_sales,
 SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id) AS tot_qtr_sales,
 SUM(amount_sold) OVER () AS tot_sales,
 TRUNC((amount_sold/SUM(amount_sold) OVER (PARTITION BY calendar_quarter_id))*100,2) AS contribution_qtr_sales,
 TRUNC((amount_sold/SUM(amount_sold) OVER ())*100,2) AS contribution_tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY calendar_quarter_id, calendar_month_id;




rem  Now lets extend the report to include a breakout by channel to create cumulative balances within each
rem  sub-category and channel. We can create a cumulative running total within each quarter by changing
rem  the PARTIION BY and ORDER BY clauses...
rem

rem  Due to the way the data is returned, it might not be clear but the totals are actually SELECT
 prod_subcategory_desc AS subcategory,
 channel_desc AS channel,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 SUM(amount_sold) OVER (PARTITION BY prod_subcategory_desc, channel_id, calendar_quarter_id ORDER BY calendar_month_id) AS cum_mnth_sales,
 SUM(amount_sold) OVER (PARTITION BY prod_subcategory_desc, channel_id  ORDER BY calendar_quarter_id) AS cum_qtr_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, channel_id, calendar_quarter_id, calendar_month_id;

rem  this now creates a running total within each quarter for each product subcategory and distribution
rem  channel


/*
PART 4 of demo script to show how to correctly use windows.
*/
rem  We are going to look at the concept of windows.
rem  In this example we are using a physical window to sum the sales of the current
rem  record with the sales from the previous two rows. This creates a 3-month moving
rem  total.

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY calendar_month_id ROWS 2 PRECEDING),0)
     AS "3m_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;



rem  this syntax actually requires a little more explanation because what we are actually stating
rem  is that we want the value in the current row added to the vaule in the preceding row but the
rem  syntax for analytic function simplifies this down to ROWS 2 PRECEDING.
rem

rem  what happens if we have a month with no sales? In this case we did not sell any cameras in
rem  November so if we have a dense time dimension we will end-up with a row for November with null
rem  sales. If we wrap the sales column in an NVL() then we can maintain the 3-month moving average
rem  calculation for December rather than it default to a moving average based on two months:

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(nvl(amount_sold,0))
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY calendar_month_desc ROWS 2 PRECEDING),0)
     AS "3m_mavg_sales"
FROM DENSE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;


rem  If we want to add the current value to the value in the next row then we have to use a slightly
rem  different syntax which does include the CURRENT ROW identifier along with the key word FOLLLOWING
rem  as shown here:


SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY calendar_month_id ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),0) AS "3m_fl_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  or we can use the PRECEDING AND FOLLLOWING keywords rather than CURRENT ROW and FOLLOWING keywords
rem  which allows you to create a centered moving average...

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,

 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY calendar_month_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),0)
     AS "3m_cmavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  ...and it all depends on the ORDER BY clause inside the analytic function
rem  which determines the output value so if you sort months in descending order
rem  the output is just like the prior statement where we now have a normal 3-month
rem

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY calendar_month_id desc ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),0) AS "3m_fl_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;

rem  now if you look at the explain plan you will see an additional final sort step that is linked
rem  to the analytical ORDER BY clause since we can no longer rely on the GROUP BY clause to
rem  order the data correctly for the analytical function.
rem
rem
rem  and of course we can include all the calculations within the same SQL statement:
rem

SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold) OVER (PARTITION BY prod_subcategory_desc ORDER BY calendar_month_id ROWS 2 PRECEDING),0) AS "3m_mavg_sales",
 TRUNC(AVG(amount_sold) OVER (PARTITION BY prod_subcategory_desc ORDER BY calendar_month_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),0) AS "3m_cmavg_sales",
 TRUNC(AVG(amount_sold) OVER (PARTITION BY prod_subcategory_desc ORDER BY calendar_month_id ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),0) AS "3m_fl_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;


rem  now we want to use a logical or range based window to find the 3 monthly average salary by using the
rem  RANGE keyword and defining the number of months within the range. This means that the analytic
rem  function will have to determine if the previous month is within 2 months of the current row's month
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING),0)
     AS "3m_mavg_sales"
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;
rem  this raises an interesting point about how missing rows are managed by analytical
rem  functions. Look at the last row for month 1999-12. The 3 month moving average for
rem  this row is actually month 10 + month 12 divided by 2 because month 11 did not record
rem  any sales. If you want to check what is being included in the calculation for each row
rem then we can use two additional functions: FIRST_VALUE and LAST_VALUE
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES",
 count(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS count_periods,
 FIRST_VALUE(calendar_month_desc)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS start_window,
 LAST_VALUE(calendar_month_desc)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS end_window
FROM PRODCAT_MONTHLY_SALES
WHERE prod_subcategory_desc ='Cameras'
AND calendar_year_id ='1803'
ORDER BY prod_subcategory_desc, calendar_quarter_id, calendar_month_id;
rem  so how do we deal with missing values? If we have a row showing null value -
rem  in this case November? If we wrap the sales column in an NVL() then we can maintain the 3-month moving average
rem  calculation for December rather than it default to a moving average based on two months:
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM')
     RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES"
FROM DENSE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;
rem  but what happens if we have two rows for November? This shows that we assign the same
rem  value to both rows that are labelled as November.
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM')
     RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES",
 count(amount_sold)
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM') RANGE INTERVAL '2' MONTH PRECEDING) AS count_periods,
FROM DENSE_DUPLICATE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;
rem  what happens if we have duplicate rows that contain data, i.e. there are no nulls?
rem  Then we find that the duplicate rows are taken into account when we compute the
rem  moving average. In this case the NULL value in November is now replaced by a zero
rem  so the moving average for November and December is based on 4 values and not 3!
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarter,
 calendar_month_desc AS month,
 amount_sold AS sales,
 TRUNC(AVG(nvl(amount_sold,0))
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM')
     RANGE INTERVAL '2' MONTH PRECEDING),0) AS "3M_MAVG_SALES",
 count(nvl(amount_sold,0))
     OVER (PARTITION BY prod_subcategory_desc
     ORDER BY TO_DATE(calendar_month_desc, 'YYYY-MM')
     RANGE INTERVAL '2' MONTH PRECEDING) AS count_periods
FROM DENSE_DUPLICATE_CAMERA_SALES
ORDER BY prod_subcategory_desc, calendar_quarter_desc, calendar_month_desc;
rem  Using analytical SQL to filter results. We want to find the months contributing > 10% of subcategory sales
rem  within product subcategories contributing > 10% total sales.  We can use the result set from analytical functions
rem  in the WHERE clause to apply the filtering
rem  Step 1: build the body of the query:
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (PARTITION BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803';
rem  Step 2: apply the filter to find the product subcategories contributing more than 10% of total sales

SELECT
 subcategory,
 quarters,
 months,
 TRUNC(sales,0) AS sales,
 TRUNC(psc_sales, 0) AS psc_sales,
 TRUNC(tot_sales, 0) AS tot_sales,
 TRUNC((sales/psc_sales)*100, 0) AS cont_psc_sales,
 TRUNC((psc_sales/tot_sales)*100, 0) AS cont_tot_sales
FROM
(SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 amount_sold AS sales,
 SUM (amount_sold) OVER (PARTITION BY prod_subcategory_desc) psc_sales,
 SUM (amount_sold) OVER () tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803')
WHERE psc_sales > 0.1 * tot_sales
ORDER BY subcategory, quarters, months;
rem  Step 3: apply the filter to find the rows where the monthly contribution is more than 10% of product subcategory
rem  total sales
SELECT
 subcategory,
 quarters,
 months,
 TRUNC(sales,0) AS sales,
 TRUNC(psc_sales, 0) AS psc_sales,
 TRUNC(tot_sales, 0) AS tot_sales,
 TRUNC((sales/psc_sales)*100, 0) AS cont_psc_sales,
 TRUNC((psc_sales/tot_sales)*100, 0) AS cont_tot_sales
FROM
(SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 amount_sold AS sales,
 SUM (amount_sold) OVER (PARTITION BY prod_subcategory_desc) psc_sales,
 SUM (amount_sold) OVER () tot_sales
FROM PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803')
WHERE psc_sales > 0.1 * tot_sales
AND sales > 0.1 * psc_sales
ORDER BY subcategory, quarters, months;
/*
PART 5 of demo script to show sort optimizations. Starting with this script which contains
one sort statement
*/
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_desc,
         calendar_quarter_desc,
         calendar_month_desc;
rem  now as we add more analytic functions that include ORDER BY clauses that we
rem start to incurr additional sort steps in the explain plan.
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY channel_class),0) c_psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY calendar_quarter_id, calendar_month_id),0) qm_psc_sales,
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_desc,
         calendar_quarter_desc,
         calendar_month_desc;

rem if we add another function that includes an ORDER BY clause we can see that the sort
rem  optimizations kick-in and we start reusing previous sorts...
SELECT
 prod_subcategory_desc AS subcategory,
 calendar_quarter_desc AS quarters,
 calendar_month_desc AS months,
 TRUNC(amount_sold,0) AS sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY prod_subcategory_desc),0) psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY channel_class),0) c_psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY calendar_quarter_id, calendar_month_id),0) qm_psc_sales,
 TRUNC(SUM (amount_sold) OVER (ORDER BY calendar_quarter_id),0) q_psc_sales,
 TRUNC(SUM (amount_sold) OVER (),0) tot_sales
FROM CHAN_PRODCAT_MONTHLY_SALES
WHERE calendar_year_id ='1803'
ORDER BY prod_subcategory_desc,
         calendar_quarter_desc,
         calendar_month_desc;



rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

/* Part 1 - Ranking data
*/

rem  ranking of data to find top 10 or bottom 10 is a common requirement.
rem  RANK() can be used in a similar way to other analytical aggregates
rem  such as SUM(), COUNT(), AVG() etc.
rem  We can create rankings across the whole data set or within each
rem  specific partition/group.


SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  SUM(amount_sold) AS sales,  RANK () OVER (ORDER BY SUM(amount_sold) DESC) as s_rank
FROM chan_prodcat_monthly_sales
GROUP BY channel_class, prod_subcategory_desc;


rem  in this script we create rankings within each channel
rem

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  SUM(amount_sold) AS sales,
  RANK () OVER (PARTITION BY channel_class ORDER BY SUM(amount_sold) DESC) as s_rank
FROM chan_prodcat_monthly_sales
GROUP BY channel_class, prod_subcategory_desc;

rem  so that we can select the top 5 product subcategories within each channel
rem  we can use the rank column to create an additional filter:

SELECT
*
FROM (SELECT
  channel_class AS channel_class,
  prod_subcategory_desc,
  SUM(amount_sold) AS amount_sold,
  RANK() OVER (PARTITION BY channel_class ORDER BY SUM(amount_sold) DESC) AS sales_rank
FROM chan_prodcat_monthly_sales
GROUP BY channel_class, prod_subcategory_desc)
WHERE sales_rank < 6;



rem  when creating a ranking need to consider what to do about ties since
rem  this will affect the rank number assigned to each row. Oracle provides
rem  two functions for ranking: RANK() and DENSE_RANK().
rem  The difference between RANK and DENSE_RANK is that DENSE_RANK leaves
rem  no gaps in ranking sequence when there are ties.

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  amount_sold AS sales,
  RANK () OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as s_rank,
  DENSE_RANK () OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as d_rank
FROM duplicate_rank_rows;




rem  another common requirement is know which rows make up 80% or the top 20%
rem  CUME_DIST. This function (defined as the inverse of percentile in some
rem  statistical books) computes the position of a specified value relative to a
rem  set of values. This makes it very easy to create pareto or 80:20 type reports
rem  and/or filters

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  amount_sold AS sales,
  RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as s_rank,
  DENSE_RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as d_rank,
  TRUNC(CUME_DIST() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC),2) as c_dist
FROM duplicate_rank_rows;



rem  there is another way to get a similar result set by using PERCENT_RANK. This is
rem  similar to CUME_DIST, but it uses rank values rather than row counts in its numerator.
rem  Therefore, it returns the percent rank of a value relative to a group of values.
rem  The calculation is based on the following forumula:
rem
rem  rank of row in its partition - 1) / (number of rows in the partition - 1)
rem
rem  The row(s) with a rank of 1 will have a PERCENT_RANK of zero so this will
rem  produce different results compared to CUME_DIST function() as shown below

SELECT
  channel_class AS channel,
  prod_subcategory_desc,
  TRUNC(amount_sold,0) AS sales,
  RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as s_rank,
  DENSE_RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC) as d_rank,
  TRUNC(CUME_DIST() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC),2) as c_dist,
  TRUNC(PERCENT_RANK() OVER (PARTITION BY channel_class ORDER BY amount_sold DESC),2) as p_rank
FROM duplicate_rank_rows;



/*
Part 2a - LAG + LEAD functions
*/
rem  using LAG and LEAD functions. Just to clarify, the values referenced in offset of the LAG/LEAD
rem  function have to be included in the result set, so for example the following statement
rem  returns null for the LAG() because the values for the prior year are not included in the
rem  resultset

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,
  LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS Lyr_sales
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';



SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,
  LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS sales_var
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';

rem  in this example offest for the lag is 12 prior rows. Offset is an optional parameter and defaults to 1.
rem  if offset falls outside the bounds of the table or partition, then there is an optional default parameter
rem  which provides the alternative value. BUT this is not the alternative OFFSET value but the actual an value
rem  that will be returned instead of the result of the normal LAG() processing.

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,
  LAG(amount_sold, 12, 2000) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  amount_sold - LAG(amount_sold, 12, 0) OVER (ORDER BY calendar_month_id) AS sales_var
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';


rem  we can use the lag to calculate sales variance comparing each month with the same month in the previous
rem  year...
rem

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,   LAG(amount_sold, 12,0) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  TRUNC(amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id,0)) AS sales_var,
  TRUNC(((amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))/LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))*100 , 0) AS var_pct
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';


rem  now if we want to find all the months where we have a drop in year-on-year sales of more than 50% we can use the following:
rem

SELECT * FROM
(SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,
  LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  TRUNC(amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id,0)) AS sales_var,
  TRUNC(((amount_sold - LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))/LAG(amount_sold, 12) OVER (ORDER BY calendar_month_id))*100 , 0) AS var_pct
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras')
WHERE var_pct < -50;


rem  of course we can look forward as well as backwards...

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_month_desc as months,
  amount_sold as sales,
  LAG(amount_sold, 12, 0) OVER (ORDER BY calendar_month_id) AS Lyr_sales,
  LEAD(amount_sold, 12,0) OVER (ORDER BY calendar_month_id) AS Nyr_sales
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras';


/*
Part 2b - Ratio to report
*/
rem  ratio_to_report is another useful function. It computes the ratio of a value to the sum of a set of values.
rem  The PARTITION BY clause defines the groups on which the RATIO_TO_REPORT function is to be computed. If the PARTITION BY
rem  clause is absent, then the function is computed over the whole query result set. In this example the grouping
rem is based on quarters so you get each months value as ration of the total for the specific quarter.

SELECT
  prod_subcategory_desc AS subcategory,
  calendar_quarter_desc as quarters,
  calendar_month_desc as months,
  amount_sold as sales,
  TRUNC(RATIO_TO_REPORT(amount_sold) OVER (), 3)
    AS rtr_year,
  TRUNC(RATIO_TO_REPORT(amount_sold)
        OVER (PARTITION BY calendar_quarter_id), 2)
        AS rtr_qtr
FROM prodcat_monthly_sales
WHERE prod_subcategory_desc = 'Cameras'
AND calendar_year_id = '1803';

rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

/* Part 3 - Statistical Features
Included in Oracle 12c Database is a compelling array of statistical functions accessible from through SQL.
These include descriptive statistics, hypothesis testing, correlations analysis, test for distribution fit,
cross tabs with Chi-square statistics, and analysis of variance (ANOVA).
Below are some basic scripts that explain how to use these features:
*/

select
       prod_category_desc,
       min(prod_list_price)                                           "Min.",
       percentile_cont(0.25) within group (order by prod_list_price)  "1st Qu.",
       trunc(median(prod_list_price),2)                               "Median",
       trunc(avg(prod_list_price),2)                                  "Mean",
       percentile_cont(0.75) within group (order by prod_list_price)  "3rd Qu.",
       max(prod_list_price)                                           "Max.",
       count(*) - count(prod_list_price)                              "NA's"
from products
GROUP BY prod_category_desc;


select /*+ parallel(5) */
       prod_category_desc,
       min(prod_list_price)                                             "Min.",
       percentile_cont(0.25) within group (order by prod_list_price)    "1st Qu.",
       trunc(median(prod_list_price),2)                                 "Median",
       trunc(avg(prod_list_price),2)                                    "Mean",
       percentile_cont(0.75) within group (order by prod_list_price)    "3rd Qu.",
       max(prod_list_price)                                             "Max.",
       count(*) - count(prod_list_price)                                "NA's",
       min(prod_weight_class)                                           "Min.",
       percentile_cont(0.25) within group (order by prod_weight_class)  "1st Qu.",
       trunc(median(prod_weight_class),2)                               "Median",
       trunc(avg(prod_weight_class),2)                                  "Mean",
       percentile_cont(0.75) within group (order by prod_weight_class)  "3rd Qu.",
       max(prod_weight_class)                                           "Max.",
       count(*) - count(prod_weight_class)                              "NA's"
from products
GROUP BY prod_category_desc;


rem  The following example determines the significance of the difference between the average sales to men and women
rem  where the distributions are known to have significantly different (unpooled) variances:

SELECT
    SUBSTR(cust_income_level, 1, 22) income_level,
    TRUNC(AVG(DECODE(cust_gender, 'M', amount_sold, null)),2) sold_to_men,
    TRUNC(AVG(DECODE(cust_gender, 'F', amount_sold, null)),2) sold_to_women,
    TRUNC(STATS_T_TEST_INDEPU(cust_gender, amount_sold, 'STATISTIC', 'F'),4) t_observed,
    TRUNC(STATS_T_TEST_INDEPU(cust_gender, amount_sold),4) two_sided_p_value
FROM sh.customers c, sh.sales s
WHERE c.cust_id = s.cust_id
GROUP BY ROLLUP(cust_income_level)
ORDER BY income_level;

rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

rem  Let's start in simple way using the sales history schema. If we want to see a grid of total sales by quarters across
rem  channels we can start by creating the input query that will deliver our resultset into our PIVOT clause
rem  The query to build the resultset looks like this:

SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 channel_class AS channel,
 sum(amount_sold) AS sales
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc, prod_category_desc, channel_class
ORDER BY calendar_quarter_desc, prod_category_desc, channel_class;


rem  we can now pass this to the PVIOT clause to transpose the rows containing the departmemt ids into
rem  into columns the pre-PIVOT workaround is to use a CASE statement as follows:
rem

SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 SUM(CASE WHEN channel_class='Direct' THEN amount_sold ELSE NULL END) AS "Direct",
 SUM(CASE WHEN channel_class='Direct' THEN amount_sold ELSE NULL END) AS "Indirect",
 SUM(CASE WHEN channel_class='Direct' THEN amount_sold ELSE NULL END) AS "Others"
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc, prod_category_desc
ORDER BY calendar_quarter_desc, prod_category_desc;



rem  the pivot statements above provide a resultset that contains two row edges and
rem  and a single column edge. The following example creates a multi-column report which contains
rem  two column edges: quarters and channels
rem

SELECT *
FROM
(SELECT
 calendar_quarter_desc AS qtr,
 prod_category_desc AS category,
 channel_class AS channel,
 sum(amount_sold) AS sales
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY calendar_quarter_desc, prod_category_desc, channel_class)
PIVOT(sum(sales) FOR (qtr, channel)
                 IN (('1999-01', 'Direct'),
                    ('1999-02', 'Direct'),
                    ('1999-03', 'Direct'),
                    ('1999-04', 'Direct'),
                    ('1999-01', 'Indirect'),
                    ('1999-02', 'Indirect'),
                    ('1999-03', 'Indirect'),
                    ('1999-04', 'Indirect')))
ORDER BY category;


rem  now lets combine our window functions within the PIVOT operation
rem  by creating a report that shows each product category, its sales and
rem  its contribution.


SELECT * FROM
(SELECT
   quarter_id,
   prod_c_desc,
   sales,
   SUM(sales) OVER (PARTITION BY quarter_id) AS qtd_sales,
   (sales/SUM(sales) OVER (PARTITION BY quarter_id))*100 AS qtd_contribution
   FROM
(SELECT
   quarter_id AS quarter_id,
   prod_c_desc AS prod_c_desc,
   SUM(sales) AS sales
 FROM sh.prod_time_sales
 GROUP BY quarter_id, prod_c_desc)
ORDER BY quarter_id, prod_c_desc)
PIVOT (SUM(sales) AS sales,
      SUM(qtd_sales) AS qtd_sales,
      SUM(to_char(qtd_contribution, '99.99')) AS qtd_contribution
FOR quarter_id IN ('1998-01','1998-02','1998-03','1998-04'));



rem  XML query output for each product catwegories sales for 1998 Q1
rem  note that we are using the  xmlserialize function to output
rem  the results of the column containing the XML

SELECT
 prod_c_desc,
 xmlserialize(content quarter_id_xml) xml
FROM
(SELECT
  quarter_id,
  prod_c_desc,
  sales
FROM sh.prod_time_sales
WHERE year_id='1802')
PIVOT XML (SUM(sales) sales
FOR quarter_id IN (SELECT distinct quarter_id from sh.prod_time_sales where quarter_id='1998-01'));




rem  UNPIVOTING a data set is easy and takes us back to our original input data
rem  from the sales table.


SELECT *
FROM PIVOT_CHAN_PRODCAT_SALES
UNPIVOT (sales
        FOR channel_class IN ("'Direct'" as 'DIRECT',
                              "'Indirect'" AS 'INDIRECT',
                              "'Others'" AS 'OTHERS'));


rem  the non-unpivot workaround would be to use the following SQL:
rem

SELECT qtr AS calendar_quarter_desc,
       category AS prod_category_desc,
      'DIRECT' As channel_class,
      "'Direct'" AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES
UNION ALL
SELECT qtr AS calendar_quarter_desc,
       category AS prod_category_desc,
      'INDIRECT' As channel_class,
      "'Indirect'" AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES
UNION ALL
SELECT qtr AS calendar_quarter_desc,
       category AS prod_category_desc,
      'OTHERS' As channel_class,
      "'Others'" AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES;



rem  There is also another way of doing this using the DECODE method as follows:
SELECT
  qtr AS calendar_quarter_desc,
  category AS prod_category_desc,
 DECODE(unpivot_row, 1, 'DIRECT',
                     2, 'INDIRECT',
                     3, 'OTHERS',
                     'N/A') AS channel_class,
 DECODE(unpivot_row, 1, "'Direct'",
                     2, "'Indirect'",
                     3, "'Others'",
                     'N/A') AS amount_sold
FROM PIVOT_CHAN_PRODCAT_SALES,
       (SELECT level AS unpivot_row FROM dual CONNECT BY level <= 3)
ORDER BY 1,2,3;


rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

rem  contains the code for running TOP-N queries as follows
rem  against the tables/views in the SH schema. There are no
rem  additional tables/views to create for this set of examples

rem  this shows my the rows that make up the worst 20% of my
rem  product sales during 1999...

SELECT
  prod_subcategory_desc,
  sum(amount_sold) AS "1999_SALES"
FROM prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY prod_subcategory_desc
ORDER BY "1999_SALES" ASC
FETCH FIRST 20 percent ROWS ONLY;


rem  the code above gets rewritten as follows:
rem

SELECT
  prod_subcategory_desc,
  SALES
FROM
(SELECT
  prod_subcategory_desc,
  sum(amount_sold) AS SALES,
  ROW_NUMBER() over (ORDER BY sum(AMOUNT_SOLD)) rn,
  COUNT(*) over () total_rows
FROM prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY prod_subcategory_desc
ORDER BY SALES ASC)
WHERE rn <= CEIL(total_rows * 20/100);

rem  what is interesting is when you include the analytical functions
rem  within your SQL as shown here:


SELECT
  channel_class,
  prod_subcategory_desc,
  sum(amount_sold) AS "1999_SALES"
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY channel_class, prod_subcategory_desc
ORDER BY channel_class, "1999_SALES" ASC
FETCH FIRST 25 percent ROWS ONLY;


rem  the only problem with TOP-N is that you cannot apply it
rem  within a partition so you need to use an alternative approach

SELECT *
FROM (
SELECT
  channel_class,
  prod_subcategory_desc,
  SUM(amount_sold) AS "1999_SALES",
  DENSE_RANK() OVER (PARTITION BY channel_class ORDER BY sum(amount_sold) ASC) rnk
FROM chan_prodcat_monthly_sales
WHERE calendar_year_id = '1803'
GROUP BY channel_class, prod_subcategory_desc
ORDER BY channel_class, "1999_SALES" ASC)
WHERE rnk <= 5;

rem  ****************************************************************
rem  Version 1.0 Dec 7, 2014
rem  Script for demonstrating the features of analytical SQL
rem  Author Keith Laker, Snr Principal Product Manager, Oracle
rem
rem  ****************************************************************
rem

rem  scripts to demonstrate how to use the various rollup
rem  features to calculate hierarchical totals within a
rem  cube.
rem

/*
Part 1 - cube/rollup features
*/

rem  Start with a standard GROUP BY clause to calculate
rem  totals at Year Category level


SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY calendar_year, prod_category_desc
ORDER BY calendar_year, prod_category_desc;


rem  now extend the basic totalling by using the ROLLUP()
rem  feature as follows

SELECT
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY ROLLUP
   (calendar_year,
   calendar_quarter_desc,
   calendar_month_desc)
ORDER BY
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc;


rem  and we can extend this to compute the totals across the time periods
rem  for all our product categories

SELECT
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc,
  prod_category_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY prod_category_desc,
ROLLUP
 (calendar_year,
  calendar_quarter_desc,
  calendar_month_desc)
ORDER BY
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc;



rem  now we switch to CUBE to automatically generate totals for all
rem categories and all years along with a final total

SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc)
ORDER BY calendar_year, prod_category_desc;



/*
Part 2 - more sophisticated aggregations...
*/

rem  now calculating totals for specific groupings of levels within in
rem  each dimension

SELECT
  calendar_year,
  calendar_quarter_desc,
  prod_category_desc,
  prod_subcategory_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY GROUPING SETS ((calendar_year, prod_category_desc),
                        (calendar_quarter_desc, prod_subcategory_desc))
ORDER BY calendar_year, calendar_quarter_desc, prod_category_desc, prod_subcategory_desc;


rem  now using a combination of GROUP BY and GROUPING ID to calculate totals
rem  within our cube

SELECT
  calendar_month_desc,
  prod_category_desc,
  prod_subcategory_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY calendar_month_desc,
GROUPING SETS(prod_category_desc, prod_subcategory_desc)
ORDER BY calendar_month_desc, prod_category_desc, prod_subcategory_desc;

rem  computing the whole cube....
rem
SELECT
  calendar_year,
  calendar_quarter_desc,
  calendar_month_desc,
  prod_desc,
  prod_category_desc,
  prod_subcategory_desc,
  SUM(amount_sold)
FROM prod_monthly_sales
GROUP BY
GROUPING SETS (calendar_year, calendar_quarter_desc, calendar_month_desc),
GROUPING SETS (prod_category_desc,prod_subcategory_desc,prod_desc)
ORDER BY calendar_year, calendar_quarter_desc, calendar_month_desc, prod_category_desc, prod_subcategory_desc, prod_desc;

rem  working out which lines are computed by the GROUP BY clause and which lines are aggregated
rem  based on the GROUP BY extension clauses: CUBE-ROLLUP-GROUPING etc....
SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold),
  GROUPING(calendar_year) AS t_tot_id,
  GROUPING(prod_category_desc) AS p_tot_id
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc);

rem  now fill in missing values for dimension descriptions...
rem
SELECT
  DECODE(GROUPING(calendar_year), 1, 'All Years', calendar_year) AS years,
  DECODE(GROUPING(prod_category_desc), 1, 'All Products', prod_category_desc) as products,
  SUM(amount_sold),
  GROUPING(calendar_year) AS t_tot_id,
  GROUPING(prod_category_desc) AS p_tot_id
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc);


rem  now using the more sophisticated GROUPING_ID column to list
rem  all the required vectors within a single column
rem
SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold),
  GROUPING(calendar_year) AS t_tot_id,
  GROUPING(prod_category_desc) AS p_tot_id,
  GROUPING_ID(calendar_year, prod_category_desc) AS t_tot_id
FROM prod_monthly_sales
GROUP BY CUBE (calendar_year, prod_category_desc);


rem  using CUBE and PIVOT together can cause problems...
rem

SELECT
*
FROM
(SELECT
  calendar_year,
  prod_category_desc,
  SUM(amount_sold) AS amount_sold
FROM prod_monthly_sales
WHERE prod_category_desc IN ('Photo', 'Hardware')
AND calendar_year_id IN ('1803', '1804')
GROUP BY CUBE (calendar_year, prod_category_desc))
PIVOT (SUM(amount_sold)
       FOR calendar_year
       IN ('1999', '2000', NULL));

rem  actually needs the following to work correctly:

SELECT
*
FROM
(SELECT
  DECODE(GROUPING(calendar_year), 1, 'All Years'
        , calendar_year) AS calendar_year,
   DECODE(GROUPING(prod_category_desc), 1, 'All Products', prod_category_desc) as prod_category_desc,
  SUM(amount_sold) AS amount_sold
FROM prod_monthly_sales
WHERE prod_category_desc IN ('Photo', 'Hardware')
AND calendar_year_id IN ('1803', '1804')
GROUP BY CUBE (calendar_year, prod_category_desc))
PIVOT (SUM(amount_sold)
       FOR calendar_year
       IN ('1999', '2000', 'All Years'));
