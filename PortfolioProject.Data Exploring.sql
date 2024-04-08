SELECT *
FROM Portfolio..['Covid deaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT Location,date,total_cases,new_cases,total_deaths,population
--FROM Portfolio..['Covid deaths$']
--ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract covid in your country

SELECT Location,date, total_cases,total_deaths ,(CONVERT( float,total_deaths ) / NULLIF (CONVERT(float,total_cases ),0))*100 as Deathpercentage
FROM Portfolio..['Covid deaths$']
WHERE LOCATION LIKE '%INDIA%'
and continent IS NOT NULL
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

SELECT Location,date,population , total_cases,(CONVERT( float,population ) / NULLIF (CONVERT(float,total_cases ),0))*100 as percentageofinfected
FROM Portfolio..['Covid deaths$']
WHERE LOCATION LIKE '%INDIA%'
and continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rates compared to population

SELECT Location,population ,(total_cases) AS HighestInfectionCount,(CONVERT( float,population ) / NULLIF (CONVERT(float,total_cases ),0))*100 as perecentpopulationinfected
FROM Portfolio..['Covid deaths$']
--WHERE LOCATION LIKE '%INDIA%'
ORDER BY perecentpopulationinfected desc


SELECT Location,population ,(total_cases) AS HighestInfectionCount,(CONVERT( float,population ) / NULLIF (CONVERT(float,total_cases ),0))*100 as perecentpopulationinfected
FROM Portfolio..['Covid deaths$']
WHERE LOCATION LIKE '%INDIA%'
and continent IS NOT NULL
ORDER BY perecentpopulationinfected desc

--showing the countries with highest death count

SELECT Location, MAX(CAST (total_deaths AS INT)) as TotalDeathCount
FROM Portfolio..['Covid deaths$']
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT Location, (total_deaths) as TotalDeathCount
FROM Portfolio..['Covid deaths$']
--WHERE location LIKE '%INDIA%'
where continent is not null
ORDER BY TotalDeathCount DESC

--Breaking things down by continent

SELECT continent,  MAX(CAST (total_deaths AS INT)) as TotalDeathCount
FROM Portfolio..['Covid deaths$']
--WHERE location LIKE '%INDIA%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT continent,  MAX(CAST (total_deaths AS INT)) as TotalDeathCount
FROM Portfolio..['Covid deaths$']
--WHERE location LIKE '%INDIA%'
where continent is  null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT Location,date, total_cases,total_deaths ,(CONVERT( float,total_deaths ) / NULLIF (CONVERT(float,total_cases ),0))*100 as Deathpercentage
FROM Portfolio..['Covid deaths$']
--WHERE LOCATION LIKE '%INDIA%'
where continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT Date,sum(new_cases) AS Totalcases,sum(cast(new_deaths as int)) as Totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From Portfolio..['Covid deaths$']
where continent is not null
group by date
order by 1,2

SELECT sum(new_cases) AS Totalcases,sum(cast(new_deaths as int)) as Totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From Portfolio..['Covid deaths$']
where continent is not null
--group by date
order by 1,2

--Looking at total population vs total hospitalpatients

SELECT *
FROM Portfolio..['Covid vaccinations$']

--SELECT *
--FROM Portfolio..['Covid deaths$'] dea
--join Portfolio..['Covid vaccinations$'] vac
--     on dea.location=vac.location
--	 and dea.date=vac.date

SELECT dea.continent,dea.location,dea.date,dea.population,vac.hosp_patients
FROM Portfolio..['Covid deaths$'] dea
join Portfolio..['Covid vaccinations$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  vac.hosp_patients is not null
and dea.continent is not null
order by 1,2


SELECT dea.continent,dea.location,dea.date,dea.population,vac.hosp_patients,vac.icu_patients as ICUpatients,SUM(CONVERT(INT,vac.icu_patients))
OVER (Partition by dea.location) as newpatients
FROM Portfolio..['Covid deaths$'] dea
join Portfolio..['Covid vaccinations$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  vac.hosp_patients is not null
and dea.continent is not null
order by 1,2

--USE CTE

WITH PopvsVac (Continent,Location,Date,Population, hosp_patients,icu_patients,newpatients)
as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.hosp_patients,vac.icu_patients as ICUpatients,SUM(CONVERT(INT,vac.icu_patients))
OVER (Partition by dea.location) as newpatients
FROM Portfolio..['Covid deaths$'] dea
join Portfolio..['Covid vaccinations$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  vac.hosp_patients is not null
and dea.continent is not null
--order by 2,3
)
SELECT *,(newpatients/population)*100 as percentageofnewpatients
FROM PopvsVac

--TEMP TABLES
DROP TABLE IF EXISTS #percentpopulationhospitalised
Create table #percentpopulationhospitalised 
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
hosp_patients numeric,
icu_patients numeric,
newpatients numeric
)
INSERT INTO #percentpopulationhospitalised 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.hosp_patients,vac.icu_patients as ICUpatients,SUM(CONVERT(INT,vac.icu_patients))
OVER (Partition by dea.location) as newpatients
FROM Portfolio..['Covid deaths$'] dea
join Portfolio..['Covid vaccinations$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
--where  vac.hosp_patients is not null
--and dea.continent is not null
--order by 2,3

SELECT *,(newpatients/population)*100 as percentpopulationhospitalised
from #percentpopulationhospitalised
WHERE hosp_patients is not null
and icu_patients is not null
and newpatients is not null

--Creating view to store data for visualization
create view percentpopulationhospitalised as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.hosp_patients,vac.icu_patients as ICUpatients,SUM(CONVERT(INT,vac.icu_patients))
OVER (Partition by dea.location) as newpatients
FROM Portfolio..['Covid deaths$'] dea
join Portfolio..['Covid vaccinations$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  vac.hosp_patients is not null
and dea.continent is not null
--order by 2,3

select *
from #percentpopulationhospitalised








