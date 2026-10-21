-- USE practice

-- Deleting row which has flight duration of 5 minute
DELETE FROM flights
WHERE Duration = '5m';
-- 1. Find the month with most number of flights

SELECT month_name,COUNT(*) FROM (SELECT *, MONTHNAME(Date_of_journey) AS month_name FROM flights) AS t
GROUP BY month_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 2. Which week day has most costly flights

SELECT week_name,AVG(Price) FROM(SELECT *,DAYNAME(Date_of_journey) AS week_name FROM flights) AS t1
GROUP BY week_name
ORDER BY AVG(Price) DESC
LIMIT 1;


-- 3. Find number of indigo flights every month

SELECT Airline,month_name,COUNT(*) FROM(SELECT *,MONTHNAME(Date_of_journey) AS month_name FROM flights) AS t1
GROUP BY Airline,month_name
HAVING Airline = 'IndiGo';

-- 4. Find list of all flights that depart between 10AM and 2PM from Banglore to Delhi

SELECT * FROM(SELECT Source,Destination,Dep_Time,HOUR(STR_TO_DATE(Dep_Time, '%H: %i')) AS departure FROM flights) AS t1
WHERE (Source = 'Banglore' AND Destination = 'Delhi') AND departure BETWEEN 10 AND 14;

-- 5. Find the number of flights departing on weekends from Bangalore

SELECT COUNT(*) FROM(SELECT *,DAYNAME(Date_of_journey) AS day_name FROM flights) AS t1
WHERE day_name IN ('Saturday', 'Sunday') AND Source = 'Banglore';


-- Creating departure column

ALTER TABLE flights ADD COLUMN departure DATETIME;
UPDATE flights
SET departure = STR_TO_DATE(CONCAT(Date_of_journey,' ',Dep_Time),'%Y- %c- %d %H: %i');

-- Now creating a clm which will contain Duration time in minutes
ALTER TABLE flights ADD COLUMN duration_min INTEGER;
ALTER TABLE flights ADD COLUMN arrival DATETIME;

UPDATE flights
SET duration_min = ((REPLACE(SUBSTRING_INDEX(Duration,' ',1),'h',''))*60) +
CASE
	WHEN SUBSTRING_INDEX(Duration,' ',1) = SUBSTRING_INDEX(Duration,' ',-1) THEN 0
    ELSE REPLACE(SUBSTRING_INDEX(Duration,' ',-1),'m','')
END;

UPDATE flights
SET arrival = DATE_ADD(departure,INTERVAL duration_min MINUTE);


ALTER TABLE flights
DROP COLUMN Duration,
DROP COLUMN Date_of_journey,
DROP COLUMN Dep_Time;


-- 6. Calculate the arrival time for all flights by adding the duration to the departure time.
SELECT Airline,Source,Destination,departure,arrival,TIME(arrival) AS 'arrival_time' FROM flights;


-- 7. Calculate the arrival date for all the flights
SELECT Airline,Source,Destination,departure,arrival,DATE(arrival) AS 'arrival_date' FROM flights;


-- 8. Find the number of flights which travel on multiple dates.

SELECT DATE(departure),Airline,COUNT(*) AS 'number_of_times' FROM flights
GROUP BY DATE(departure),Airline;


-- 9.Calculate the average duration of flights between all city pairs and ans should be in hr min.
SELECT Source,Destination,
TIME_FORMAt(SEC_TO_TIME((AVG(duration_min))*60),'%h:%i') AS 'avg_duration_in_hr:min' FROM flights
GROUP BY Source,Destination;


-- 10.Find all flights which departed before midnight but arrived at their destination
-- after midnight having only 0 stops.
SELECT * FROM flights
WHERE Total_Stops = 'non-stop' AND DATE(arrival) > DATE(departure);


-- 11. Find quarter wise number of flights for each airline
with qtr AS (SELECT *, MONTHNAME(departure),CASE
									WHEN MONTHNAME(departure) ='January' OR MONTHNAME(departure) = 'February' OR MONTHNAME(departure) = 'March' THEN 'Q1'
                                    WHEN MONTHNAME(departure) ='May' OR MONTHNAME(departure) = 'June' OR MONTHNAME(departure) ='April' THEN 'Q2'
                                    WHEN MONTHNAME(departure) ='July' OR MONTHNAME(departure) = 'August' OR MONTHNAME(departure) = 'September' THEN 'Q3'
									WHEN MONTHNAME(departure) = 'October' OR MONTHNAME(departure) = 'November' OR MONTHNAME(departure) ='December' THEN 'Q4'
                                END AS 'quarter'
FROM flights) 
SELECT `quarter`,Airline,COUNT(*) FROM qtr
GROUP BY `quarter`,Airline
ORDER BY Airline;


-- 12. Find the longest flight distance(between cities in terms of time) in India

SELECT *,TIMESTAMPDIFF(HOUR,departure,arrival) AS 'time' FROM flights
ORDER BY TIMESTAMPDIFF(HOUR,departure,arrival) DESC
LIMIT 3;


-- 13. Average time duration for flights that have 1 stop vs more than 1 stops
SELECT stops,DATE_FORMAT(SEC_TO_TIME(AVG(duration_min) * 60), '%Hh %im') AS 'avg_dur',AVG(Price)  AS 'avg_price' FROM(SELECT *,
CASE
	WHEN Total_Stops = 'non-stop' THEN 'non-stop'
	WHEN Total_stops = '1 stop' THEN '1_stop'
    ELSE 'more than 1 stop'
END AS stops
FROM flights) AS t
GROUP BY stops;


-- 14. Find all Air India flights in a given date range originating from Delhi
-- lets say "1st Mar 2019 to 10th Mar 2019" 
SELECT * FROM flights
WHERE Source = 'Delhi' AND DATE(departure) BETWEEN '2019-03-01' AND '2019-03-10' ;


-- 15. Find the longest flight of each airline
WITH ranked_flights AS(SELECT Airline,Source,Destination,departure,arrival,TIMESTAMPDIFF(HOUR,departure,arrival) AS 'time_in_hr',
ROW_NUMBER() OVER(PARTITION BY Airline ORDER BY TIMESTAMPDIFF(HOUR,departure,arrival)) AS 'rank'
FROM flights)
SELECT * FROM ranked_flights
WHERE `rank` = 1
ORDER BY time_in_hr DESC;

-- 16. Find all the pair of cities having average time duration > 3 hours
SELECT Source,Destination,AVG(duration_min) FROM flights
GROUP BY Source, Destination
HAVING (AVG(duration_min)/60) >3;

-- 17. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi
SELECT DAYNAME(departure),
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM - 6AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM 12PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM - 6PM', 
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM - 12AM' 
FROM flights
WHERE Source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure);

-- 18. Make a weekday vs time grid showing avg flight price from Banglore and Delhi
SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM - 6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM 12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM - 6PM', 
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM - 12AM' 
FROM flights
WHERE Source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure);