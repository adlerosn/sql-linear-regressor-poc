WITH R AS (
	select Year AS x, Weight AS y from athlete_events
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
INSERT INTO linear_regressions (tablename, field_x, field_y, slope, intercept)
select 'athlete_events' AS tablename, 'Year' AS field_x, 'Weight' AS field_y, slope, intercept from Tslope join Tintercept on (1=1)
