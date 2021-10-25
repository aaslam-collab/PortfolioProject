SELECT * FROM PortfolioProject..CovidDeaths 
ORDER by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER by 3,4


-- Select data that we will be using
SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths & liklihood of dying in Canada 
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1, 2

-- Total Cases vs Population & Percentage of people getting COVID-19 in Canada
SELECT Location, Date, Population, total_cases, (total_cases/Population)*100 as Percentage_of_Positive_Cases
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1, 2

-- Highest Infection Rate vs Population
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/Population))*100 as Percentage_of_Positive_Cases
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'Canada'
GROUP BY Location, Population
-- HAVING Location = 'Canada'
ORDER BY Percentage_of_Positive_Cases DESC

-- Countries with the Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count DESC


-- Highest Death Count per Population and Grouped by Continent
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY Total_Death_Count DESC


-- Global Numbers 
SELECT Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.Location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE

WITH PopVsVax (Continent, Location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.Location order by dea.location, 
  dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopVsVax

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.Location order by dea.location, 
  dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 

CREATE VIEW	PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.Location order by dea.location, 
  dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
