Select *
From PorfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PorfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

--Select location, date, total_cases, new_cases, total_deaths, population 
--From PorfolioProject..CovidDeaths
--Order by 1, 2


-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where location like '%Malaysia%'
Order by 1,2


-- Looking at total cases vs population
--Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From PorfolioProject..CovidDeaths
Where location like '%Malaysia%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK THING DOWN BY CONTINENT

-- SHowing continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

--GLobal

Select SUM(new_cases) as total_cases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
where continent is not null 
--Group by date
Having SUM(new_deaths) <> 0
Order by 1,2


--Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac
Order by 2,3


-- showing max popvsvac
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select continent, location, population, MAX(RollingPeopleVaccinated), MAX((RollingPeopleVaccinated/population)*100)
From PopvsVac
Group by continent, location, population
Order by 1,2


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
Order by 2,3