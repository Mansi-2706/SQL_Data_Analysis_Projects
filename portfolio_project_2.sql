
select * from [dbo].[athlete_events$]
--columns = athlete_id, games, year, season, city, sport, event, medal

select * from [dbo].[athletes$]
--columns = id, name, sex, height, weight, team

--1 Which team has won the maximum gold medals over the years?

SELECT top 1 team, COUNT(DISTINCT event) AS cnt_events 
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal = 'Gold'
GROUP BY team
ORDER BY cnt_events DESC

/*
team	        cnt_events
United States	293
*/

--2 For each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

WITH CTE AS (
SELECT a.team, ae.year, COUNT(DISTINCT event) AS silver_medals ,
RANK() OVER(PARTITION BY team ORDER BY COUNT(DISTINCT event) DESC) AS rnk
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal = 'Silver'
GROUP BY a.team, ae.year
)
SELECT team, SUM(silver_medals) AS total_silver_medal, MAX(CASE WHEN rnk = 1 THEN year end) AS year_of_max_silver
FROM cte
GROUP BY team;

/*  team	     total_silver_medal	year_of_max_silver
	Algeria	            1				2008
	Argentina	        6				2012
	Armenia				1				2016
	Australasia			4				1908
	Australia			35				2016
	Austria				8				1924
	Azerbaijan			4				2012
	Bahamas				1				2008
	Belarus				3				2012
	Belgium				13				1920
	BLO Polo Club		2				1908
*/

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

WITH cte AS (
SELECT DISTINCT name , COUNT(1) AS total_gold_medals
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal NOT IN ('Silver','Bronze') AND medal = 'Gold'
GROUP BY name
), cte1 AS (
SELECT name, total_gold_medals, 
RANK() OVER(ORDER BY total_gold_medals DESC) AS rnk
FROM cte
)
SELECT name, total_gold_medals FROM cte1
WHERE rnk = 1

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

WITH cte AS (
SELECT ae.year, a.name, COUNT(1) as no_of_gold
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal = 'Gold'
GROUP BY ae.year, a.name
),
cte1 AS (
SELECT *, RANK() OVER(PARTITION BY year ORDER BY no_of_gold DESC) AS rnk
FROM cte
)
SELECT year, no_of_gold, STRING_AGG(name,',') AS player_name
FROM cte1
WHERE rnk = 1
GROUP BY year, no_of_gold;

/*
year no_of_gold	player_name
1932	1	    Andre Marguerite Blanche Brunet-Joly,Dallas Denver Bixler,Carmine R. "Carmen" Barth (DiBartolomeo-),Georges Eugne William "Go" Buchard,Gyrgy Brdy,Istvn Barta (Berger),Flix Pierre Victor Bailly,Frank Gerald Singlehurst Brewin,Edwin Yancey "Eddie" Argo,Edgar Allen "Ed" Ablowich,ke Carl Magnus Bergqvist,John Charles "Felix" Badcock,John Edward Biby, Jr.,John Franklin Anderson,Jack Beresford,Jakob Brendel,James Aloysius Bernard "Jim" Bausch,James Howard "Jim" Blair,Luigi Beccali,Lee Everett Blair,Lal Shah S. Bokhari,Paul Friedrich Peter Bauer,Nino Borsari,Olle Erik Curys kerlund,Sardar Mohammad Aslam,Richard James Allen,Ren Bougnol,Ren Henri Georges Bondoux,Pierre mile Ernest Brunet,Raymond Henry "Benny" Bass
1968	1	    Waldemar Romuald Baszanowski,Vladimir Pavlovich Belousov,Veniamin Veniaminovich Aleksandrov,Viktor Nikolayevich Blinov,Volodymyr Ivanovych Bieliaiev,Tore Berger,ura "urica" Bjedov,Tariq Aziz,Steinar Amundsen,Heinz-Jrgen Bothe,Inger Reidun Aufles (Dving-),Ivans Bugajenkovs,Istvn Bsti,Gilles Berolatti,Gulraiz Akhtar,Gunnar Henry Asmussen,Derek Swithin Allhusen,Gary Lee Anderson,Colette Besson (-Nogus),Catherine Northcutt "Catie" Ball (-Condon),Andrs Balcz,Amos Kipwabok Biwott,Ahmet Ayk,John Robert "Bob" Braithwaite,Jane Louise Barkman (-Brown),Jane Mary Elizabeth Bullen (-Holderness-Roddam),Mario Armano,Lyudmila Yevgenevna Belousova (-Protopopova),Lyudmila Stepanovna Buldakova (Meshcheryakova-),Mahmut Atalay,Margaret Ann Bailes (Johnson-),Klaus-Michael Bonsack,Ozren Bonai,Peter Jones Barrett,Oegs Antropovs,Michael Thomas "Mike" Barrett,Muhammad Ashfaq Ahmed,Roland Bse,Saeed Anwar,Robert "Bob" Beamon,Riaz Ahmed,Primo Baran
1896	2	    Conrad Helmut Fritz Bcker,John Mary Pius Boland
1900	2	    Charles Bennett,Albert Jean Louis Ayat,Gaston Achille Louis Aumoitte,Gaston Frdric Blanchy,Irving Knott "Irv" Baxter
1904	2	    George Philip "Phil" Bryant
1908	2	    Gaston Jules Louis Antoine Alibert
*/

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

SELECT DISTINCT * FROM (
SELECT ae.year, ae.event AS sport, ae.medal, 
RANK() OVER(PARTITION BY event ORDER BY year) AS rnk
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE team = 'India' AND medal != 'NA'
) A WHERE rnk = 1

/*
year	       sport	                          medal	 rnk
1928	Hockey Men's Hockey	                       Gold	  1
2008	Shooting Men's Air Rifle, 10 metres	       Gold	  1
*/

--6 find players who won gold medal in summer and winter olympics both.

SELECT a.name
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal = 'Gold'
GROUP BY a.name
HAVING COUNT(DISTINCT season) = 2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

SELECT a.name, ae.year
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal != 'NA'
GROUP BY a.name, ae.year
HAVING COUNT(DISTINCT medal) = 3;

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

WITH cte AS (
SELECT a.name, ae.event, ae.year
FROM [dbo].[athlete_events$] AS ae INNER JOIN [dbo].[athletes$] AS a
ON ae.athlete_id = a.id
WHERE medal = 'Gold' AND year >= 2000 AND season = 'Summer'
GROUP BY a.name, ae.event, ae.year)

SELECT * FROM (
SELECT *, LAG(year,1) OVER(PARTITION BY name,event ORDER BY year ) as prev_year,
LEAD(year,1) OVER(PARTITION BY name,event ORDER BY year ) as next_year
FROM cte) A
WHERE year = prev_year+4 AND year = next_year-4

/*
name	                            event								year	prev_year	next_year
Carmelo Kyan Anthony	   Basketball Men's Basketball					2012	  2008	       2016
Kristin Ann Armstrong      Cycling Women's Individual Time Trial		2012	  2008	       2016
Pter Biros				   Water Polo Men's Water Polo					2004	  2000	       2008
Seimone Delicia Augustus   Basketball Women's Basketball				2012	  2008	       2016
Shannon Leigh Boxx	       Football Women's Football	                2008	  2004	       2012
Suzanne Brigit "Sue" Bird  Basketball Women's Basketball	            2008	  2004	       2012
Suzanne Brigit "Sue" Bird  Basketball Women's Basketball	            2012	  2008	       2016
Tibor Benedek	           Water Polo Men's Water Polo	                2004	  2000	       2008
Usain St. Leo Bolt	       Athletics Men's 100 metres					2012	  2008	       2016
Usain St. Leo Bolt	       Athletics Men's 200 metres					2012	  2008	       2016
*/