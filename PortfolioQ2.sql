
--Original before nullingg--

Select * 
From PortfolioProject..CovidDeaths
Order By 3,4



Select * 
From PortfolioProject..CovidDeaths
where continent is not null
Order By 3,4

Select * 
From PortfolioProject..CovidVaccinations
Order By 3,4

---- Selecting Data Begin Used (Data Exploration) --

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases VS Total Deaths -- 


Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases VS Total Deaths (United States) -- 


Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Shows % of population who got covid --


Select location, date, total_cases,Population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0)) * 100 AS PopulationPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Countries with highest death count per population --

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking data down by continent --

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers --

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Nullif(Sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2

--Joins -- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


-- use CTE -- 
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

--DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view for visualizations in Tableau

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated