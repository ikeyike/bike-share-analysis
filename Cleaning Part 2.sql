--Make a table with null values in the start and end station names replaced with 'N/A'. The start/end station id columns will be removed as well.

DROP TABLE IF EXISTS tripdata_2021_to_2022.combined_tripdata2;
CREATE TABLE  tripdata_2021_to_2022.combined_tripdata2 AS (
  SELECT 
    DISTINCT ride_id,
    rideable_type,
    started_at,
    ended_at,
    IFNULL(start_station_name,'N/A') AS start_station_name,
    IFNULL(end_station_name,'N/A') AS end_station_name,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
  FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata`
);

-- Create a new temp table with all other null values removed.

DROP TABLE IF EXISTS tripdata_2021_to_2022.combined_tripdata_no_nulls;
CREATE TABLE tripdata_2021_to_2022.combined_tripdata_no_nulls AS (
  SELECT *
  FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata2`
  WHERE 
    start_station_name IS NOT NULL AND
    end_station_name IS NOT NULL AND
    start_lat IS NOT NULL AND
    start_lng IS NOT NULL AND
    end_lat IS NOT NULL AND
    end_lng IS NOT NULL   
);

--Now to make separate columns for the started_at date and calculate ride length in minutes

DROP TABLE IF EXISTS tripdata_2021_to_2022.combined_tripdata_date_ridelength;
CREATE TABLE tripdata_2021_to_2022.combined_tripdata_date_ridelength AS (
  SELECT 
    DISTINCT ride_id,
    rideable_type,
    started_at,
    ended_at,
    DATE_DIFF (ended_at, started_at, MINUTE) AS ride_length_minutes,
    start_station_name,
    end_station_name,
    CASE
      WHEN EXTRACT (DAYOFWEEK FROM started_at) = 1 THEN "Sun"
      WHEN EXTRACT (DAYOFWEEK FROM started_at) = 2 THEN "Mon"
      WHEN EXTRACT (DAYOFWEEK FROM started_at) = 3 THEN "Tues"
      WHEN EXTRACT (DAYOFWEEK FROM started_at) = 4 THEN "Wed"
      WHEN EXTRACT (DAYOFWEEK FROM started_at) = 5 THEN "Thur"
      WHEN EXTRACT (DAYOFWEEK FROM started_at) = 6 THEN "Fri"
      ELSE  "Sat"
    END AS day_of_week,
    CASE
      WHEN EXTRACT (MONTH FROM started_at) = 1 THEN "Jan"
      WHEN EXTRACT (MONTH FROM started_at) = 2 THEN "Feb"  
      WHEN EXTRACT (MONTH FROM started_at) = 3 THEN "Mar"  
      WHEN EXTRACT (MONTH FROM started_at) = 4 THEN "Apr"  
      WHEN EXTRACT (MONTH FROM started_at) = 5 THEN "May"  
      WHEN EXTRACT (MONTH FROM started_at) = 6 THEN "Jun"  
      WHEN EXTRACT (MONTH FROM started_at) = 7 THEN "Jul"  
      WHEN EXTRACT (MONTH FROM started_at) = 8 THEN "Aug"  
      WHEN EXTRACT (MONTH FROM started_at) = 9 THEN "Sep"  
      WHEN EXTRACT (MONTH FROM started_at) = 10 THEN "Oct"  
      WHEN EXTRACT (MONTH FROM started_at) = 11 THEN "Nov"
      ELSE "Dec"
    END AS month,
    EXTRACT(DAY FROM started_at) AS day,
    EXTRACT(YEAR FROM started_at) AS year,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual AS member_type
  FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata_no_nulls`
  
);

--Now to fully clean the data. Getting rid of rows with DIVVY CASSETTE REPAIR MOBILE STATION, Pawel Bialowas - Test- PBSC charging station, and values longner than 24 hours (1440 minutes), negative values, and 0 (less than a minute). 

DROP TABLE IF EXISTS tripdata_2021_to_2022.clean_combined_tripdata;
CREATE TABLE tripdata_2021_to_2022.clean_combined_tripdata AS (
SELECT *
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.combined_tripdata_date_ridelength`
WHERE
  start_station_name <> 'DIVVY CASSETTE REPAIR MOBILE STATION' AND
  start_station_name <> 'Pawel Bialowas - Test- PBSC charging station' AND
  end_station_name <> 'DIVVY CASSETTE REPAIR MOBILE STATION' AND
  end_station_name <> 'Pawel Bialowas - Test- PBSC charging station' AND
  ride_length_minutes >1 AND ride_length_minutes < 1440
);

--Data is clean. Now time for analysis and prep for data visualization

--type of ride for casuals vs members
SELECT 
  rideable_type,
  member_type,
  COUNT(*) AS amount_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
GROUP BY
  rideable_type,
  member_type
ORDER BY
  member_type,
  rideable_type;

--number of rides per month for casuals and members
SELECT 
  member_type,
  month,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
GROUP BY member_type, month
ORDER BY month;

--number of rides per day for casuals and members
SELECT
  member_type,
  day_of_week,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
GROUP BY member_type, day_of_week;

--number of rides per hour for casuals and members
SELECT
  member_type,
  EXTRACT(HOUR FROM started_at) AS time_of_day, COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
GROUP BY member_type, time_of_day;

--average length of ride per day for casuals and members
SELECT
  member_type,
  day_of_week,
  ROUND(AVG(ride_length_minutes),0) AS avg_ride_length_minutes,
  AVG(AVG(ride_length_minutes)) OVER(PARTITION BY member_type) AS combined_avg_ride_length
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
GROUP BY  member_type, day_of_week
ORDER BY day_of_week ASC;

--average length of ride per month for casuals and members

SELECT
  member_type,
  month,
  ROUND(AVG(ride_length_minutes),0) AS avg_ride_length_minutes,
  AVG(AVG(ride_length_minutes)) OVER(PARTITION BY member_type) AS combined_avg_ride_length
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
GROUP BY  member_type, month
ORDER BY month ASC;


--number of rides at starting stations for casuals
SELECT
  start_station_name,
  ROUND(AVG(start_lat),4) AS start_lat,
  ROUND(AVG(start_lng),4) AS start_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'casual' AND start_station_name <> "N/A"
GROUP BY start_station_name
ORDER BY num_of_rides DESC;

-- number of rides at starting stations for members
SELECT
  start_station_name,
  start_lat AS start_lat,
  start_lng AS start_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'member' AND start_station_name <> "N/A"
GROUP BY start_station_name, start_lat, start_lng
ORDER BY num_of_rides DESC;

-- number of rides at ending stations for casuals
SELECT
  end_station_name,
  ROUND(AVG(end_lat),4) AS end_lat,
  ROUND(AVG(end_lng),4) AS end_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE 
  member_type = 'casual' AND end_station_name <> "N/A"
GROUP BY end_station_name
ORDER BY num_of_rides DESC;

--number of rides at ending stations for members
SELECT
  end_station_name,
  ROUND(AVG(end_lat),4) AS end_lat,
  ROUND(AVG(end_lng),4) AS end_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE 
  member_type = 'member' AND end_station_name <> "N/A"
GROUP BY end_station_name
ORDER BY num_of_rides DESC;

SELECT
  ROUND(AVG(start_lat),4) AS start_lat,
  ROUND(AVG(start_lng),4) AS start_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'casual' AND start_station_name = "N/A"
GROUP BY start_station_name;

SELECT
  ROUND(AVG(start_lat),4) AS start_lat,
  ROUND(AVG(start_lng),4) AS start_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'member' AND start_station_name = "N/A"
GROUP BY start_station_name;

-- ending 'N/A' location for casuals
SELECT
  end_lat,
  end_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'casual' AND start_station_name = "N/A"
GROUP BY end_lat, end_lng
ORDER BY num_of_rides DESC;

-- ending 'N/A' location for members:
SELECT
  end_lat,
  end_lng,
  COUNT(*) AS num_of_rides
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'casual' AND start_station_name = "N/A"
GROUP BY end_lat, end_lng
ORDER BY num_of_rides DESC;


--Finding most popular routes for casual members
SELECT
  member_type,
  CONCAT(start_station_name, " to " , end_station_name) AS route,
  COUNT(*) AS num_trips,
  ROUND(AVG(ride_length_minutes),2) AS duration_minutes
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = "casual" AND start_station_name <> "N/A" AND end_station_name <> "N/A"
GROUP BY start_station_name, end_station_name, member_type
ORDER BY num_trips DESC;

--Finding most popular routes for members
SELECT
  member_type,
  CONCAT(start_station_name, ' to ', end_station_name) AS route,
  COUNT(*) AS num_trips,
  ROUND(AVG(ride_length_minutes), 2) AS duration_minutes
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = "member" AND start_station_name <> "N/A" AND end_station_name <> "N/A"
GROUP BY start_station_name, end_station_name, member_type
ORDER BY num_trips DESC;

--Want to see what bike types casuals use
SELECT
  member_type,
  rideable_type,
  COUNT(*) AS amount
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'casual'
GROUP BY
  member_type, rideable_type;

--Want to see what bike types members use
SELECT
  member_type,
  rideable_type,
  COUNT(*) AS amount
FROM `utilitarian-mix-369005.tripdata_2021_to_2022.clean_combined_tripdata`
WHERE
  member_type = 'member'
GROUP BY
  member_type, rideable_type;

