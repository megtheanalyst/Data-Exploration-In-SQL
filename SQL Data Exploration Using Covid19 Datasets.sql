select *
from PortfolioProject..CovidDeaths
where continent is not Null
order by 3,4


select *
from PortfolioProject..CovidVaccinations
order by 3,4


-- select Data that I will be using for this project

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases Vs Total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

-- As at 15/07/2015, total cases in Nigeria was 258,934,total Deaths of 3,144 and Death percentage of 1%
-- shows the likelihood of dying if one contract covid in Nigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Nigeria'
order by 1,2

-- Looking at the Total cases vs Population
-- shows what percentage of population contracted covid in Nigeria

select location, date, population,  total_cases, (total_cases/population)* 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location like 'Nigeria'
order by 1,2

-- Looking at countries with Highest infection rate compared to Population

select location, population,  MAX(total_cases) as HigestInfectionCount, MAX(total_cases/population)* 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'Nigeria'
Group by location, population
order by PercentagePopulationInfected desc

-- showing Countries with Highest Death Count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not Null
Group by location
order by TotalDeathCount desc

-- United States has the Highest Total Death Count.

-- Breaking It down by Continent

-- showing the continents with Highest death count per popupaltion

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not Null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not Null
Group by date
order by 1,2

-- Global death Vs Cases

select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not Null
--Group by date
order by 1,2

-- Looking ate Total population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
order by 2,3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location, dea.date) 
as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3
)
select *, (RollingPeopleVaccination/Population)*100
from PopvsVac 



-- TEMP TABLE
Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not Null
--order by 2,3

select *, (RollingPeopleVaccination/Population)*100
from PopvsVac


-- creating view to store data for visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3

Select *
from PercentPopulationVaccinated







