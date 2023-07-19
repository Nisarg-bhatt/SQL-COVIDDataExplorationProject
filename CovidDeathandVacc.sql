SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3, 4

-- Select Dat that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying based if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'India'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of population that got Covid
SELECT Location, date, total_cases, total_deaths, (total_cases/population)*100 as TotalcasesPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compare to Population
SELECT Location, population, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population)*100) as PercentagePopluationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentagePopluationInfected desc

-- Lets break things down by Continent
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing Contries with the Highest Death count per Population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing Continents with the Highest Death Count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc
	
-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.location = vac.location
AND Dea.date = Vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.location = vac.location
AND Dea.date = Vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLW

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.location = vac.location
AND Dea.date = Vac.date
-- WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated



-- Creating view to store data for later visualizations
DROP VIEW IF EXISTS PercentagePopulationVaccinated

USE PortfolioProject
GO
CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
ON dea.location = vac.location
AND Dea.date = Vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentagePopulationVaccinated