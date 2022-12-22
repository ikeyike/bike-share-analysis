--First, combine the 12 monthly bike trip data from Nov 1, 2021 to Oct 31, 2022 into one table

DROP TABLE IF EXISTS tripdata_2021_to_2022.combined_tripdata;
CREATE TABLE tripdata_2021_to_2022.combined_tripdata AS 
SELECT *
FROM (
 
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.11_2021`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.12_2021` 
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.1_2022`  
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.2_2022`  
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.3_2022`  
  UNION ALL
  SELECT * FROM  `utilitarian-mix-369005.tripdata_2021_to_2022.4_2022`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.5_2022`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.6_2022`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.7_2022`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.8_2022`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.9_2022`
  UNION ALL
  SELECT * FROM `utilitarian-mix-369005.tripdata_2021_to_2022.10_2022`
);

--This query returned 4,517,370 rows, which equalled the sum of the 12 monthly tripdata sets--

SELECT *
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`;


--Check how many rows have null values starting from left to right
SELECT  
  COUNT(*)
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE ride_id IS NULL OR rideable_type IS NULL OR started_at IS NULL OR ended_at IS NULL OR start_station_name IS NULL OR start_station_id IS NULL OR end_station_name IS NULL OR end_station_id IS NULL OR start_lat IS NULL OR start_lng IS NULL OR end_lat IS NULL OR end_lng IS NULL OR member_casual IS NULL;

-- There are 916572 rows that have null values in them. Let's take a look at the columns themselves. Rows that have null values will be removed.
SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE ride_id IS NULL;

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE rideable_type IS NULL;

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE started_at IS NULL;

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE ended_at IS NULL;

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE start_station_name IS NULL OR end_station_name IS NULL;

--There are 916,572 rows that have either a null start_station_name or end_station_name.

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE start_station_id IS NULL OR end_station_id IS NULL;

--There are 916,572 rows that have a null start_station_id or end_station_id.

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE start_lat IS NULL;

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE start_lng IS NULL;

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE end_lat IS NULL;

--There are 3,599 rows that have a null end_lat.--

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE end_lng IS NULL;

--There are 3,599 rows that have a null end_lng.--

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE member_casual IS NULL;

--Will filter based on rideable_type and with the columns that had null values--

SELECT ride_id AS null_ride_id, rideable_type
FROM (
  SELECT ride_id, start_station_name, start_station_id, end_station_name, end_station_id,rideable_type
  FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
  WHERE rideable_type = 'electric_bike'
)
WHERE start_station_name IS NULL OR start_station_id IS NULL OR end_station_name IS NULL OR end_station_id IS NULL;

--There are 911,934 rows of electric bikes with the criteria in the filter. Will run a check of the count of electric, classic, and docked bikes to make sure this number isn't significant. 

SELECT rideable_type, COUNT(*) AS num_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
GROUP BY rideable_type;

--There are 2,212,817 eletric bikes. 911,934 of them have null start/end station names and ids. In other words, 41.2 % would be unusable. 
--I would contact Cyclistic for more information as to why some electric bikes have null values in the start and end station columns and others don't. For the purposes of this analysis, I will include these null values, as I can't contact Cyclistic, and I don't want to skew the business question of how casuals and members use the bikes.
--Will check the classic_bike and docked_bike with the same filters.

SELECT ride_id AS null_ride_id, rideable_type
FROM (
  SELECT ride_id, start_station_name, start_station_id, end_station_name, end_station_id, rideable_type
  FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
  WHERE rideable_type = 'classic_bike' OR rideable_type= "docked_bike"
)
WHERE start_station_name IS NULL OR start_station_id IS NULL OR end_station_name IS NULL OR end_station_id IS NULL;

--There are 4,638 rows that we will not use with the criteria classic bike and docked bike. An expection will be made for the 911,934 rows of electric bikes. However I will not use them for analysis of the station start/end names, only to see the relationship between casuals and members.

--Will now check for null values in the start/end longitude/latitude columns. Rows that have null values will be removed--

SELECT *
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE 
  start_lat IS NULL OR
  start_lng IS NULL OR
  end_lat IS NULL OR
  end_lng IS NULL;

--A summary count of nulls in start_station_name, end_station_name, start_station_id, end_station_id colums, and the start/end lng and lat

SELECT rideable_type, COUNT(*) as num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE start_station_name IS NULL AND start_station_id IS NULL OR end_station_name IS NULL AND end_station_id IS NULL OR start_lat IS NULL OR start_lng IS NULL OR end_lat IS NULL OR end_lng IS NULL
GROUP BY rideable_type;

--Checking length of ride_id. There are other ride_id's of varying lengths. I would contact Cyclistic if they had ride_id's that were less than 16 characters in a real world setting. Since this is practice, I will include all the ride_id's in my analysis.

SELECT LENGTH(ride_id) AS ride_id,
COUNT(*)
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
GROUP BY LENGTH(ride_id);

--Now going to check for duplicate values. There are 5 duplicate values. They will be removed
SELECT COUNT (DISTINCT ride_id)
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`;

--Now going to check if there are indeed 3 rideable_types.

SELECT DISTINCT rideable_type 
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`;

--Will find the ride length in mintues between the started_at and ended_at columns. Will order them by ascending and descending order to find outliers.

SELECT DATE_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
ORDER BY ride_length_minutes;

SELECT DATE_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
ORDER BY ride_length_minutes DESC;

-- We have values longner than 24 hours (1440 minutes), negative values, and 0 (less than a minute). For this analysis, a valid trip is going to be considered longer than a minute, and less than 24 hours.

SELECT*
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
WHERE TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <=1 OR TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >=1440;

--Look at the start_station_name and end_station_name for naming inconsistencies. I decided that I will not be using the start_station_id and end_station_id columns. start_station_name and end_station_name are the most relevant to our analysis and easier to understand.

SELECT start_station_name, COUNT(*) AS num_trips
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
GROUP BY start_station_name
ORDER BY start_station_name; 

SELECT end_station_name, COUNT(*) AS num_trips
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
GROUP BY end_station_name
ORDER BY end_station_name; 

--Some interesting things. Found starting/end station names with DIVVY CASSETTE REPAIR MOBILE STATION, Pawel Bialowas - Test- PBSC charging station. Those will be deleted .
--Found start/end station names with "(Temp)"", and those with a "*"". I would contact Cyclistic about why some start/end station names have "(Temp)" and "*". I will keep start/end station names with those values, so as to not mess up any interanal naming conventions Cyclistic may have, since I can't contact them in ths setting.

SELECT 
COUNT(DISTINCT (start_station_name)) AS start_station_name,
COUNT(DISTINCT (end_station_name)) AS end_station_name,
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`;

--Will check the last column to ensure that there are 2 values in the member_casual column, member and casual.

SELECT DISTINCT member_casual 
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`;

--Looks good! There are in fact only 2 member types.
