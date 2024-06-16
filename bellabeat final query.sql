--data cleaning

--checking for null values in every coloumn


select *
from bellabeat..dailyActivity_merged
where ActivityDate is null

select *
from bellabeat..dailyActivity_merged
where TotalSteps is null;

select *
from bellabeat..dailyActivity_merged
where TotalDistance is null;

select *
from bellabeat..dailyActivity_merged
where TrackerDistance is null;

select *
from bellabeat..dailyActivity_merged
where LoggedActivitiesDistance is null;

select *
from bellabeat..dailyActivity_merged
where VeryActiveDistance is null;

select *
from bellabeat..dailyActivity_merged
where ModeratelyActiveDistance is null;

select *
from bellabeat..dailyActivity_merged
where LightActiveDistance is null;

select *
from bellabeat..dailyActivity_merged
where SedentaryActiveDistance is null;

select *
from bellabeat..dailyActivity_merged
where VeryActiveMinutes is null;

select *
from bellabeat..dailyActivity_merged
where FairlyActiveMinutes is null;

select *
from bellabeat..dailyActivity_merged
where LightlyActiveMinutes is null;

select *
from bellabeat..dailyActivity_merged
where SedentaryMinutes is null;

select *
from bellabeat..dailyActivity_merged
where Calories is null;

--there are no null values in this table

--chechking if there is any duplicates


select *,
ROW_NUMBER() OVER(
partition by id,ActivityDate,Totalsteps,totaldistance,trackerdistance order by id,activitydate) as row_num
from bellabeat..dailyActivity_merged

with duplicate_cte as(
select *,
ROW_NUMBER() OVER(
partition by id,ActivityDate,Totalsteps,totaldistance,trackerdistance order by id,activitydate) as row_num
from bellabeat..dailyActivity_merged
)
SELECT *
FROM duplicate_cte
where row_num>1

--there are no duplicate values in this table

--1.1)finding the number active days and non active days for each user

with useractivity as(
select
id,
activitydate,
case 
	when cast(veryactivedistance as float) > 0 or cast(moderatelyactivedistance as float)> 0 or cast(lightactivedistance as float) > 0 then 'active'
	else 'inactive'
	end as activity_status
from bellabeat..dailyActivity_merged
where id in (select top 33 id from bellabeat..dailyActivity_merged group by id)
)
select
id,
count(activitydate) as totaldays,
count(case when activity_status='active' then 1 end) as active_days,
count(case when activity_status='inactive' then 1 end) as inactive_days
from useractivity
group by id


--1.2)finding the total percentage of avtice days and inactice days
SELECT
    ROUND((SUM(CASE WHEN CAST(veryactivedistance AS FLOAT) > 0 OR CAST(moderatelyactivedistance AS FLOAT) > 0 OR CAST(lightactivedistance AS FLOAT) > 0 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS total_active_percentage,
    ROUND((SUM(CASE WHEN CAST(veryactivedistance AS FLOAT) = 0 AND CAST(moderatelyactivedistance AS FLOAT) = 0 AND CAST(lightactivedistance AS FLOAT) = 0 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS total_inactive_percentage
FROM
    bellabeat..dailyActivity_merged;


--2)finding the avg steps walked by each user 


with activity_summary as
(
select Id,ActivityDate,TotalSteps,TotalDistance,VeryActiveDistance,ModeratelyActiveDistance,
LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,
SedentaryMinutes,Calories
from bellabeat..dailyActivity_merged
)
select 
id,
avg(cast(totalsteps as int)) as avgtotalsteps
from activity_summary
group by id
order by
avgtotalsteps desc;

--finding the percentage of people who walked above 10k steps  and havent walked above 10k steps



with activity_summary as
(
select Id,ActivityDate,TotalSteps,TotalDistance,VeryActiveDistance,ModeratelyActiveDistance,
LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,
SedentaryMinutes,Calories
from bellabeat..dailyActivity_merged
)
select
case when avgtotalsteps>=10000 then 10000
else -1
end as sub_category,
count(*) as user_counts,
round(cast(count(*) as decimal)/(select count(distinct id) from activity_summary)*100,2) as percentage
from (
select 
id,
avg(cast(totalsteps as int)) as avgtotalsteps
from activity_summary
group by id) as avg_steps
group by
case when avgtotalsteps >=10000 then 10000
else -1
end
order by sub_category

--3)finding the activity level


with activity_summary as
(
select
sum(cast(veryactiveminutes as int)) as total_very_active_minutes,
sum(cast(fairlyactiveminutes as int)) as total_fairly_active_minutes,
sum(cast(lightlyactiveminutes as int)) as total_lightly_active_minutes,
sum(cast(sedentaryminutes as int)) as total_sedentary_active_minutes,
sum(cast(veryactiveminutes as int)+cast(fairlyactiveminutes as int)+cast(lightlyactiveminutes as int)+ cast(sedentaryminutes as int))as total_sum
from bellabeat..dailyActivity_merged
)
select
 round((total_very_active_minutes/cast(total_sum as float))*100,2) as percent_active_minutes,
 round((total_fairly_active_minutes/cast(total_sum as float))*100,2) as percent_fairly_active,
 round((total_lightly_active_minutes/cast(total_sum as float))*100,2) as percent_lightly_active,
 round((total_sedentary_active_minutes/cast(total_sum as float))*100,2) as percent_sedentary
 from activity_summary


 --4)activity vs calories

 select id,sum(cast(Calories as float)) as total_calories_burned,
sum(cast(totalsteps as float)) as total_steps_walked,
sum(cast(TotalDistance as float)) as total_distance,
sum(cast(VeryActiveDistance as float))as tot_very_active_dis,
sum(cast(ModeratelyActiveDistance as float))as tot_mod_active_dis,
sum(cast(LightActiveDistance as float))as tot_light_active_dis,
sum(cast(SedentaryActiveDistance as float))as tot_sedentary_dis
from bellabeat..dailyActivity_merged
group by id
order by total_calories_burned desc

--checking the table containg data about sleep

select avg(totalminutesasleep) as avg_sleep,id
from bellabeat..sleepDay_merged
group by id

--5)joning two tables to compare sleep and activity

select sleep.id,sum(cast(VeryActiveMinutes as float)) as tot_very_active_mins,sum(cast(FairlyActiveMinutes as float)) as tot_fairly_active,sum(cast(LightlyActiveMinutes as float)) as tot_lightly_active,sum(cast(SedentaryMinutes as float)) as tot_sedenetary_activity,avg(TotalMinutesAsleep) as avg_sleep
from bellabeat..dailyActivity_merged as activity
join bellabeat..sleepDay_merged as sleep
on activity.id = sleep.id
group by sleep.id
order by id