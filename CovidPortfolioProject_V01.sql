--COVID-19 data analytics porfolio project. The Dataset consists of Data from January 1, 2020 till February 7, 2022
SELECT
* 
FROM PortfolioProject..CovidDeaths$
--WHERE continent is not NULL
ORDER BY 3,4

--SELECT
--* 
--FROM PortfolioProject..CovidVactionations$
--ORDER BY 3,4

--select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
ORDER BY 1,2


-- Loking at the toatl cases vs total deaths for India
-- Predicting of the probability of death if a person living in Indaia encounters COVID-19 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Precent
FROM PortfolioProject..CovidDeaths$
WHERE location = 'India' AND continent is not NULL
ORDER BY 1,2


--Looking at total cases vs population
--Predicting the probability of getting infected by covid if you live in India
SELECT location, date, population, total_cases, (total_cases/population)*100 as Infection_Percentge
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'India'
WHERE continent is not NULL
ORDER BY 1,2




--Looking at countries with heighest infection rate as compared to population 
SELECT location, population, max( total_cases) as HighestInfectionCount, max((total_cases/population)*100) as Infection_Percentge
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'India'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY Infection_Percentge DESC


--Showing countries with heighest deaths count per population
SELECT location, max( cast(total_deaths as int)) as HighestDeathCount -- We are casting total_deaths as integer because it has varchar Datatype (see DB Schema)
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'India'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC


--Showing continents with heighest death count per ppopulation
SELECT continent,  max(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY HighestDeathCount DESC



-- Global Numbers
--Looking at total new cases, total new deaths, and death percentage on a perticular date
SELECT 
date, 
SUM(new_cases) as TotalNewCases, 
SUM( cast(new_deaths as int)) as TotalNewDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'India' AND 
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Global numbers
SELECT 
SUM(new_cases) as TotalNewCases, 
SUM( cast(new_deaths as int)) as TotalNewDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
ORDER BY 1,2




--**************************************************************************************************************************************************************

--Joining the two tables

SELECT *
FROM PortfolioProject..CovidDeaths$ dea        --dea is an alias for Portfolio..CovidDeaths$
join PortfolioProject..CovidVactionations$ vac --vac is an alias for portfolio..CovidVactionation$
 on dea.location = vac.location 
 AND dea.date=vac.date


 --Looinkg at total population vs vaccination
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea        --dea is an alias for Portfolio..CovidDeaths$
join PortfolioProject..CovidVactionations$ vac --vac is an alias for portfolio..CovidVactionation$
 on dea.location = vac.location 
 AND dea.date=vac.date
WHERE dea.continent is not null
 ORDER BY 2,3


 --We cannot use "RollingPeopleVaccinated" to calculate total Rolling people vaccinated percentage hence we use CTE
 --Using CTE (Common Table Expression) a temporary named result set that I can reference within a SELECT, INSERT, UPDATE, or DELETE statement
  
  WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
  as 
  (
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea        --dea is an alias for Portfolio..CovidDeaths$
join PortfolioProject..CovidVactionations$ vac --vac is an alias for portfolio..CovidVactionation$
 on dea.location = vac.location 
 AND dea.date=vac.date
WHERE dea.continent is not null
 --ORDER BY 2,3
 )
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--Performing above task uisng the concept of temp table
 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea        --dea is an alias for Portfolio..CovidDeaths$
join PortfolioProject..CovidVactionations$ vac --vac is an alias for portfolio..CovidVactionation$
 on dea.location = vac.location 
 AND dea.date=vac.date
--WHERE dea.continent is not null
 --ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




--Creating view for later data vizs

CREATE VIEW PercentPopulationVaccinated as 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea        --dea is an alias for Portfolio..CovidDeaths$
join PortfolioProject..CovidVactionations$ vac --vac is an alias for portfolio..CovidVactionation$
 on dea.location = vac.location 
 AND dea.date=vac.date
WHERE dea.continent is not null
 --ORDER BY 2,3


 SELECT *
 FROM PercentPopulationVaccinated