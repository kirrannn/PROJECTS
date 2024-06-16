select *
FROM `portfolioproject-423807.COVID.COVID DEATHS`
where continent is not null
ORDER BY 3,4;

SELECT *
FROM `portfolioproject-423807.COVID.COVID VACCINATIONS`
ORDER BY 3,4;


--SELECTING DATA THAT WE'RE GONNA USE


SELECT location,date,total_cases,new_cases,total_deaths,population
from `portfolioproject-423807.COVID.COVID DEATHS`
where continent is not null
order by 1,2;

--looking total cases vs total deaths
--chances of dying from covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from `portfolioproject-423807.COVID.COVID DEATHS`
where location = 'India'
and continent is not null
order by 1,2;

--looking total_cases vs population
--shows the percentage of the popuation that is infected by covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as infected_percentage
from `portfolioproject-423807.COVID.COVID DEATHS`
where location = 'India'
and continent is not null
order by 1,2;

--looking at countries with highest infection rate compared to population

SELECT location,population,max(total_cases) as highest_infection_count,max((total_cases/population))*100 as infected_percentage
from `portfolioproject-423807.COVID.COVID DEATHS`
where continent is not null
group by location,population
order by infected_percentage desc;

--looking at countries with highest death count per population


SELECT location,max(cast(total_deaths as int)) as total_death_count
from `portfolioproject-423807.COVID.COVID DEATHS`
where continent is not null
group by location
order by total_death_count desc;


--breaking things down by continent
--showing continents with the highest death count per population

SELECT continent,max(cast(total_deaths as int)) as total_death_count
from `portfolioproject-423807.COVID.COVID DEATHS`
where continent is not null
group by continent
order by total_death_count desc;

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From `portfolioproject-423807.COVID.COVID DEATHS`
where continent is not null 
--Group By date
order by 1,2


--looking at total population vs vaccination


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
FROM `portfolioproject-423807.COVID.COVID DEATHS` AS DEA
INNER JOIN `portfolioproject-423807.COVID.COVID VACCINATIONS` AS VAC
  ON dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null 
order by 2,3;


--using cte to perform calculation on the previous query

WITH popvsvac AS (
  SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
  FROM 
    `portfolioproject-423807.COVID.COVID DEATHS` AS DEA
  INNER JOIN 
    `portfolioproject-423807.COVID.COVID VACCINATIONS` AS VAC
  ON 
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL 
)
SELECT *,(rolling_people_vaccinated/population)*100
FROM popvsvac;


create view `portfolioproject-423807.COVID.popvsvac` as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
FROM `portfolioproject-423807.COVID.COVID DEATHS` AS DEA
INNER JOIN `portfolioproject-423807.COVID.COVID VACCINATIONS` AS VAC
  ON dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null 
--order by 2,3;