Dataset information

Columns:
  ride_id - text
  rideable_type - text
  started_at - text
  ended_at - text
  start_station_name - text
  start_station_id - double
  end_station_name - text
  end_station_id - double
  start_lat - double
  start_lng - double
  end_lat - double
  end_lng - double
  member_casual - text


with cbr as (
select *
from 2021_citi_bike_data.june_rides),


--Count the total number of rides in the dataset
select count(*)
from cbr
--2,723,972


-- Count the total number of start stations
select count(distinct start_station_id)
from cbr
-- 1,432


-- Count the total number of end stations
select count(distinct end_station_id)
from cbr
-- 1,433


-- What are the top 10 busiest docks and their count, ordered from most busy to least busy
popular_starts as (
  select 
	  start_station_name, 	
	  count(*) as n_starts
  from cbr
  group by 1
  order by 2 desc)
select
	start_station_name, 
    n_starts
from (
	select
		rank() over(order by n_starts desc) as rnk,
		start_station_name,
		n_starts
	from popular_starts) a
where rnk <= 10

'E 17 St & Broadway','12735' -- union square (subway? yes)
'W 21 St & 6 Ave','12404' -- 
'West St & Chambers St','12221'
'Broadway & W 25 St','11630'
'1 Ave & E 68 St','11140'
'7 Ave & Central Park South','10896'
'Broadway & W 60 St','10771'
'Central Park S & 6 Ave','10463'
'12 Ave & W 40 St','10049'
'West St & Liberty St', '9963'


-- What are the busiest hours of the day?

select extract(hour from started_at) as hour, count(*)
from cbr
group by 1
order by 2 desc

'18','246227'
'16','212630'
'15','198463'
'14','191697'
'19','188440'
'13','176051'
'12','161516'
'11','140810'
'8','136602'
'20','127895'
'10','121239'
'9','121073'
'7','89347'
'21','88151'
'22','71945'
'23','53290'
'6','47591'
'0','39243'
'1','20821'
'5','14881'
'2','12598'
'3','7573'
'4','6015'


-- Find distance of each ride

with cbr as (
select *
from 2021_citi_bike_data.june_rides)

SELECT 
ride_id,
start_lat, end_lat, start_lng, end_lng,
round(( 3960 * acos( cos( radians( start_lat ) ) *
  cos( radians( end_lat ) ) * cos( radians(  end_lng  ) - radians( start_lng ) ) +
  sin( radians( start_lat ) ) * sin( radians(  end_lat  ) ) ) ), 3) AS Distance
FROM cbr

-- What are the busiest days of the week?
select 
    dayofweek(started_at) as day_of_week,
    count(*)
from cbr
group by 1
order by 2 desc

7, 418120
5, 414842
2, 405765
3, 388947
6, 374267
1, 369690
4, 352341


-- What is the average ride time?


-- What is the average ride distance?
select avg(distance)
from (
SELECT *,
3960 * acos( cos( radians( start_lat ) ) *
  cos( radians( end_lat ) ) * cos( radians(  end_lng  ) - radians( start_lng ) ) +
  sin( radians( start_lat ) ) * sin( radians(  end_lat  ) ) )  as avg_distance
FROM cbr
where end_station_id != 0
-- some rides didn't have an end_station_id which impacted the average. Some rides has the same start and end station (0 miles) also impacting the avg distance

  
-- What is the most biked route (start_station to end_station)?
with cbr as (
select *
from 2021_citi_bike_data.june_rides)
select 
	concat(start_station_name , ' to ', end_station_name),
    count(*)
from cbr
where start_station_name <> end_station_name
group by 1
order by 2 desc
limit 10

'Picnic Point to Soissons Landing','705'
'Soissons Landing to Picnic Point','699'
'Soissons Landing to Yankee Ferry Terminal','619'
'Yankee Ferry Terminal to Soissons Landing','595'
'Roosevelt Island Tramway to Motorgate','557'
'Yankee Ferry Terminal to Picnic Point','553'
'Warren St & W Broadway to Centre St & Chambers St','539'
'Picnic Point to Yankee Ferry Terminal','539'
'W 21 St & 6 Ave to 9 Ave & W 22 St','527'
'1 Ave & E 62 St to 1 Ave & E 68 St','518'


-- What day of the week has the longest avg rides?







select 
	dayofweek(started_at), count(*) as n_rides
from cbr
where end_station_name in (
	select
	        end_station_name
	from(
		select 
	                end_station_name, 
                        count(*) as n_starts,
                        rank()over(order by count(end_station_name) desc) as rnk
		from cbr
	group by 1) a
	where rnk <= 10)
group by 1
