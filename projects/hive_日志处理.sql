
CREATE TABLE u_data (
  userid INT,
  movieid INT,
  rating INT,
  unixtime STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
Then, download the data files from MovieLens 100k on the GroupLens datasets page (which also has a README.txt file and index of unzipped files):

wget http://files.grouplens.org/datasets/movielens/ml-100k.zip
or:

curl --remote-name http://files.grouplens.org/datasets/movielens/ml-100k.zip
Note:  If the link to GroupLens datasets does not work, please report it on HIVE-5341 or send a message to the user@hive.apache.org mailing list.

Unzip the data files:

unzip ml-100k.zip
And load u.data into the table that was just created:

LOAD DATA LOCAL INPATH '<path>/u.data'
OVERWRITE INTO TABLE u_data;
Count the number of rows in table u_data:

SELECT COUNT(*) FROM u_data;
Note that for older versions of Hive which don't include HIVE-287, you'll need to use COUNT(1) in place of COUNT(*).

Now we can do some complex data analysis on the table u_data:

Create weekday_mapper.py:

import sys
import datetime

for line in sys.stdin:
  line = line.strip()
  userid, movieid, rating, unixtime = line.split('\t')
  weekday = datetime.datetime.fromtimestamp(float(unixtime)).isoweekday()
  print '\t'.join([userid, movieid, rating, str(weekday)])
Use the mapper script:

CREATE TABLE u_data_new (
  userid INT,
  movieid INT,
  rating INT,
  weekday INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

add FILE weekday_mapper.py;

INSERT OVERWRITE TABLE u_data_new
SELECT
  TRANSFORM (userid, movieid, rating, unixtime)
  USING 'python weekday_mapper.py'
  AS (userid, movieid, rating, weekday)
FROM u_data;

SELECT weekday, COUNT(*)
FROM u_data_new
GROUP BY weekday;
Note that if you're using Hive 0.5.0 or earlier you will need to use COUNT(1) in place of COUNT(*).

Apache Weblog Data
The format of Apache weblog is customizable, while most webmasters use the default.
For default Apache weblog, we can create a table with the following command.

More about RegexSerDe can be found here in HIVE-662 and HIVE-1719.

CREATE TABLE apachelog (
  host STRING,
  identity STRING,
  user STRING,
  time STRING,
  request STRING,
  status STRING,
  size STRING,
  referer STRING,
  agent STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^]*) ([^]*) ([^]*) (-|\\[^\\]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\".*\") ([^ \"]*|\".*\"))?"
)
STORED AS TEXTFILE;