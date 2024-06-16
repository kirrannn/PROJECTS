--combining all the tables as one usuing union all

select *
from PROJECTPORTFOLIO..april_2021
UNION ALL
select *
from PROJECTPORTFOLIO..may_2021
UNION ALL
select *
from PROJECTPORTFOLIO..june_2021
UNION ALL
select *
from PROJECTPORTFOLIO..july_2021
UNION ALL
select *
from PROJECTPORTFOLIO..august_2021
UNION ALL
select *
from PROJECTPORTFOLIO..september_2021
UNION ALL
select *
from PROJECTPORTFOLIO..october_2021
UNION ALL
select *
from PROJECTPORTFOLIO..november_2021
UNION ALL
select *
from PROJECTPORTFOLIO..december_2021
UNION ALL
select *
from PROJECTPORTFOLIO..january_2022
UNION ALL
select *
from PROJECTPORTFOLIO..february_2022
UNION ALL
select *
from PROJECTPORTFOLIO..march_2022

select *
into oneyear
from 
(
select *
from PROJECTPORTFOLIO..april_2021
UNION ALL
select *
from PROJECTPORTFOLIO..may_2021
UNION ALL
select *
from PROJECTPORTFOLIO..june_2021
UNION ALL
select *
from PROJECTPORTFOLIO..july_2021
UNION ALL
select *
from PROJECTPORTFOLIO..august_2021
UNION ALL
select *
from PROJECTPORTFOLIO..september_2021
UNION ALL
select *
from PROJECTPORTFOLIO..october_2021
UNION ALL
select *
from PROJECTPORTFOLIO..november_2021
UNION ALL
select *
from PROJECTPORTFOLIO..december_2021
UNION ALL
select *
from PROJECTPORTFOLIO..january_2022
UNION ALL
select *
from PROJECTPORTFOLIO..february_2022
UNION ALL
select *
from PROJECTPORTFOLIO..march_2022
)
as oneyear;

--data cleaning

--checking if there is any wrong data

select *
from oneyear
where ended_at<=started_at

--deleting these incorrect entires

delete from oneyear
where ended_at<started_at

--finding null values

select *
from oneyear
where end_station_name is null

select *
from oneyear
where end_station_id is null

select *
from oneyear
where start_station_name is null

select *
from oneyear
where start_station_id is null

--there is a huge amount of null values present
--decided to keep the data as its mostly in start_staion_name and id and end statoin name and id because we wont be using that coloumns 


select ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual
from oneyear

--checking for duplicates


select *,
row_number() over(
partition by ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual order by ride_id) as row_number
from oneyear;
with duplicate_year as
(
select *,
row_number() over(
partition by ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual order by ride_id) as row_number
from oneyear
)
select *
from duplicate_year
where row_number >1

--from this we can say there are no duplicates 

--calculating the ride length

select ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual,
datediff(SECOND,started_at,ended_at)/60 as ride_length_mins
from oneyear

alter table oneyear
add ride_length_mins float;

update oneyear
set ride_length_mins=datediff(SECOND,started_at,ended_at)/60

--find the day of week 

select ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual,
datename(dw,started_at) as day_of_week
from oneyear

-- finding the total count of rides per each day

select day_of_week, count(*) as total_rides
from
(
select ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual,
datename(dw,started_at) as day_of_week
from oneyear
) as rides
group by day_of_week
order by total_rides desc

--1.1)total rides by causal member on each day

select day_of_week, count(*) as total_rides_casual
from
(
select ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual,
datename(dw,started_at) as day_of_week
from oneyear
) as rides
where member_casual= 'casual'
group by day_of_week
order by total_rides_casual desc

--1.2)total rides by annual member on each day

select day_of_week, count(*) as total_rides_member
from
(
select ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,member_casual,
datename(dw,started_at) as day_of_week
from oneyear
) as rides
where member_casual= 'member'
group by day_of_week
order by total_rides_member desc

--total number of rides in each month

select datename(month,started_at) as month_number,
count(*) as total_rides
from oneyear
group by datename(month,started_at)
order by month_number

--2.1)total number of rides in each month by member members

select datename(month,started_at) as month_number,
count(*) as total_rides_annual
from oneyear
where member_casual='member'
group by datename(month,started_at)
order by month_number

--2.2)total number of rides in each month by casual member

select datename(month,started_at) as month_number,
count(*) as total_rides_casual
from oneyear
where member_casual='casual'
group by datename(month,started_at)
order by month_number

--3)finding the avg time spent by causal and annual member on each day

select member_casual,
DATENAME(dw,started_at) as day_of_week,
round(avg(ride_length_mins),2) as avg_time
from oneyear
group by member_casual,
DATENAME(dw,started_at)

--4)finding the the number of time each type of bike was used

select member_casual,rideable_type,count(*) as bike_count
from oneyear
group by member_casual,rideable_type
order by member_casual,rideable_type

--5)finding the number of rides by each type of user

select member_casual,count(*) as total_rides,
round((count(*)*100)/sum(count(*)) over(),2) as percentage_total_rides
from oneyear
group by member_casual


--6)finding the avg ride length by each type of user

select DATEname(weekday,started_at) as day_of_week,
avg(case when member_casual = 'casual' then datediff(SECOND,started_at,ended_at)end) as avg_ride_length_casual_sec,
avg(case when member_casual = 'member' then datediff(SECOND,started_at,ended_at)end) as avg_ride_length_member_sec
from oneyear
group by datename(weekday,started_at)



