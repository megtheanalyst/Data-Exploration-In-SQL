-- Create database SQLProject

CREATE DATABASE SQLProject;

-- Use SQLProject DB

USE SQLProject;

-- Count Rows for each Table

select COUNT(*)Num_rows
from CovidVaccinations;--- contain 307,887 rows


select COUNT(*) Num_rows
from CovidDeaths;--- contain 307,887 rows

---view tables

select *
from CovidDeaths
order by 3,4;

select *
from CovidVaccinations
order by 3,4;

--- extract location,date, total cases, new cases, total deaths and population fro coviddeaths table

select location, date, new_cases, total_cases, total_deaths, population
from CovidDeaths
order by 1,2;

-- death percentage per location

SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100  deathpercentage
FROM CovidDeaths
ORDER BY 1, 2;


-- death percentage in Nigeria
--- shows likelihood of dying if one contacts covid in Nigeria

SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100  deathpercentage
FROM CovidDeaths
WHERE location LIKE 'Nigeria'
ORDER BY 1, 2;

-- Total cases vs Population

SELECT location, date, population,total_cases, 
       (CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100  PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE 'Nigeria'
ORDER BY 1, 2;


--- countries with the Highest infection Rate compared to population

SELECT location, population, MAX(CAST(total_cases AS FLOAT)) HighestInfectionCount,
       MAX((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0))) * 100  PercentPopulationInfected
FROM CovidDeaths
WHERE continent is null
Group by location, population
ORDER BY 4 DESC;


-- countries with Highest death count per Population

SELECT location,population, MAX(CAST(total_deaths AS FLOAT))TotalDeathCount
       --MAX((CAST(total_deaths AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0))) * 100  PercentPopulationInfected
FROM CovidDeaths
WHERE continent is NULL
Group by location, population
ORDER BY 2 DESC;


-- Total death count by continent

SELECT continent, MAX(CAST(total_deaths AS FLOAT))TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
Group by continent
ORDER BY 2 DESC;

--- Global number

SELECT SUM(new_cases) total_cases, SUM(CAST(new_deaths AS FLOAT))total_deaths, 
        SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases) * 100 DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2;

-- total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on ( dea.location = vac.location
     and dea.date = vac.date)
where dea.continent is not null
order by 2,3;



-- use CTE to get percentage of rolling people vaccinated


WITH PopVSVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on ( dea.location = vac.location
     and dea.date = vac.date)
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population) * 100 PercentageOfPeopleVac
from PopVSVac;


-- create a temp table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on ( dea.location = vac.location
     and dea.date = vac.date)
--where dea.continent is not null


SELECT *, (RollingPeopleVaccinated/population) * 100 PercentageOfPeopleVac
from #PercentagePopulationVaccinated


-- create view

create view PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on ( dea.location = vac.location
     and dea.date = vac.date)
where dea.continent is not null;

-- use select all to view the created view

select *
from PercentagePopulationVaccinated







