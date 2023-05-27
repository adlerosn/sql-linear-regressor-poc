# SQL Linear Regressor

This project is a Proof-of-Cocept that has the goal to demonstrate that SQL can be used to do really basic regression workloads that are barely useful for more complex scenarios, such as Linear Regression.

As linear regression technically counts as some very primitive sort of machine learning, this implies that pretty much every SQL database in production is able to do machine learning.

## Query template

```
WITH R AS (
	select <FIELD_X> AS x, <FIELD_Y> AS y from athlete_events
), T1 AS (
	select x, y from R where x is not null and y is not null
), Txx AS (
	select x*x AS xx from T1
), Txy AS (
	select x*y AS xy from T1
), Tsumxx AS (
	select SUM(xx) AS sumxx from Txx
), Tsumxy AS (
	select SUM(xy) AS sumxy from Txy
), Tsumx AS (
	select SUM(x) AS sumx from T1
), Tsumy AS (
	select SUM(y) AS sumy from T1
), Tcnt AS (
	select COUNT(1) AS cnt from T1
), Tslope AS (
	select ((cnt * sumxy) - (sumx * sumy)) / ((cnt * sumxx) - (sumx * sumx)) AS slope from Tcnt
	LEFT JOIN Tsumxx ON (1=1)
	LEFT JOIN Tsumxy ON (1=1)
	LEFT JOIN Tsumx ON (1=1)
	LEFT JOIN Tsumy ON (1=1)
), Tintercept AS (
	select (sumy - (slope * sumx)) / cnt  AS intercept from Tcnt
	LEFT JOIN Tsumx ON (1=1)
	LEFT JOIN Tsumy ON (1=1)
	LEFT JOIN Tslope ON (1=1)
)
select slope, intercept from Tslope join Tintercept on (1=1)
;
```

Replace `<FIELD_X>` and `<FIELD_Y>` with the desired fields of a table.

In case you forgot, the formula is `y = slope * x + intercept`, or `f(x) = slope * x + intercept`.

## Query performance complexity

It mainly depends on the number of lines in the table.

It calculates 5 "variables" at O(lines) cost, which can all be calculated in the same table scan if the query planner is competent enough, and then does some math (O(1) cost).

On SQLite, on my Ryzen 7900X with enough DDR5 3600 MT/s and BTRFS, timings were:

```
time sqlite3 db.sqlite3 < query1.sql

real    0m0.321s
user    0m0.048s
sys     0m0.029s
time sqlite3 db.sqlite3 < query2.sql

real    0m0.248s
user    0m0.053s
sys     0m0.027s
```

For the 271116 rows of the dataset.

## The sample code

It downloads a ZIP containing some olympics data, unzips a CSV, loads into a SQLite database, and correlates athletes' height and weight at a year to the year.

The output is the file `linear_regression.csv` that is expected to contain:
| tablename | field_x | field_y | slope | intercept |
|----------------|---------|---------|--------------------|------------------|
| athlete_events | Year | Height | 0.0234981604396816 | 128.605672884188 |
| athlete_events | Year | Weight | 0.013394127322599 | 44.0563484199918 |
