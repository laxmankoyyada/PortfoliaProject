select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select Location,date,total_cases,total_deaths,(total_deaths/total_Cases)*100 as deathspercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population got covid

select Location,date,total_cases,population,(total_cases/population)*100 as deathspercentage
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population

select Location,population,max(total_cases) as highestinfectioncount ,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
Group by Location,population
order by PercentPopulationInfected


-- Showing Countries with highest death count per population

select continent,max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

select location,max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where location is not null
Group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

select continent,max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_Cases ,sum(cast(new_deaths as int)) as total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100deathspercentage
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
-- group by date
order by 1,2


select *
from PortfolioProject..CovidVaccinations

-- Looking at total Population vs Vacctinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE

with PopvsVac (Continent,Location,date,population,new_vaccinations,rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(rollingpeoplevaccinated/population)*100
from  PopvsVac

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select * ,(rollingpeoplevaccinated/population)*100
from  #PercentPopulationVaccinated


-- CREATING VIEW TO STORE THE DATA FOR LATER VISUALIZATIONS

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select *
from PercentPopulationVaccinated