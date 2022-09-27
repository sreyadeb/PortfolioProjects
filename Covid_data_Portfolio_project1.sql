Select *
From PortfolioProject..CovidDeaths
where continent is not Null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not Null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows liklihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%desh%'
and continent is not Null
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPolulationInfected
From PortfolioProject..CovidDeaths
--where location like '%desh%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPolulationInfected
From PortfolioProject..CovidDeaths
--where location like '%desh%'
Group by Location, population
order by PercentPolulationInfected desc


-- Showing countries with highest death count per population

Select Location,max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%desh%'
where continent is not Null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continent with highest death count per population

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%desh%'
where continent is Null
Group by continent
order by TotalDeathCount desc



---Global Numbers

Select date, sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int)) /sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%desh%'
where continent is not Null
group by date
order by 1,2

--total cases around the world
Select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int)) /sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%desh%'
where continent is not Null
order by 1,2



--Looking at total polupation vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
order by 2,3

--Use CTE
with PopvsVac( continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not Null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null
--order by 2,3

select *
from PercentPopulationVaccinated