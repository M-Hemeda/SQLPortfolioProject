SELECT *
FROM SQLPortfolioProject..CovidDeaths dth
WHERE continent is NOT NULL
ORDER BY 3, 4

SELECT *
FROM SQLPortfolioProject..CovidVaccinations vac
WHERE continent is NOT NULL
ORDER BY 3, 4

-- Select Important Columns

SELECT location country, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Total Deaths/Total Cases

SELECT location country, date, total_cases, total_deaths, 
       ROUND((total_deaths/total_cases)*100,4) DeathsPercentage
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE 'egypt'
ORDER BY 1,2

-- Total Cases/Population

SELECT location country, date, population, total_cases,  
       (total_cases/population)*100 CasesPerPopulation
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE 'egypt'
ORDER BY 1,2

-- Looking at countries of Highest Infecion Rate/Population

SELECT location country, population, Max(total_cases) HighestInfectionCount,  
       Max((total_cases/population))*100 HighestInfectionRate
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE 'egypt'
GROUP BY location, population
ORDER BY HighestInfectionRate DESC

-- Looking at countries of Highest Infecion Rate/Population BigCountries

SELECT location country, Max(total_cases/population)*100 HighestInfectionRate
FROM SQLPortfolioProject..CovidDeaths
WHERE population > 5000000 AND continent is NOT NULL
GROUP BY location
ORDER BY HighestInfectionRate DESC

-- Max Total Death Problem of Type (we need to change "Cast" 'nvarchar' as 'int')

SELECT location country, Max(cast(total_deaths as int)) HighestDeathCount
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE 'egypt'
GROUP BY location
ORDER BY HighestDeathCount DESC


-- Looking at countries of Highest Death Rate/Population

SELECT location country, Max(cast(total_deaths as int)) HighestDeathCount
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE 'egypt'
GROUP BY location
ORDER BY HighestDeathCount DESC


-- LET'S BREAK IT DOWN BY "CONTINENT"

-- Highest Cases Count/Continent

SELECT location, Max(total_cases) HighestCasesCount
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY HighestCasesCount DESC

-- Highest Cases Rate/Continent

SELECT location, Max((total_cases/population))*100 HighestInfectionRate
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY HighestInfectionRate DESC

-- Highest Death Count/Continent

SELECT location, Max(cast(total_deaths as int)) HighestDeathCount
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NULL AND location not like '%income%'
GROUP BY location
ORDER BY HighestDeathCount DESC

-- OR (Alex Way!!) (WRONG I GUESS)

SELECT continent, Max(cast(total_deaths as int)) HighestDeathCount
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBER 

-- Total Cases/Deaths per Day

SELECT date, SUM(new_cases) TotalNewCases, SUM(cast(new_deaths as int)) TotalNewDeaths, 
	   (SUM(cast(new_deaths as int))/SUM(new_cases))*100 DeathPercentage
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Total Cases/Deaths since the beginning of Covid

SELECT SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, 
	   (SUM(cast(new_deaths as int))/SUM(new_cases))*100 DeathPercentage
FROM SQLPortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1

-- Looking at Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
      , Sum(CAST(vac.new_vaccinations as bigint)) 
	   OVER (Partition by dea.location Order by dea.location, dea.date ) RollingVaccinationsSum
	  --, (RollingVaccinationsSum/population)*100 VaccinationsPercentage
FROM SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use RollingVaccinationsSum Column to get the VaccinationsPercentage with 

-- 'CTEs'

With cte_vaccination as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
      , Sum(CAST(vac.new_vaccinations as bigint)) 
	   OVER (Partition by dea.location Order by dea.location, dea.date ) RollingVaccinationsSum
	  --, (RollingVaccinationsSum/population)*100 VaccinationsPercentage
FROM SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *,(RollingVaccinationsSum/population)*100 VaccinationsPercentage
From cte_Vaccination
ORDER BY 2,3

-- TEMP TABLE

DROP Table if exists #VacPercentage
CREATE TABLE #VacPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationsSum  numeric
)

INSERT INTO #VacPercentage
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
      , Sum(CAST(vac.new_vaccinations as bigint)) 
	   OVER (Partition by dea.location Order by dea.location, dea.date ) RollingVaccinationsSum
	  --, (RollingVaccinationsSum/population)*100 VaccinationsPercentage
FROM SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

Select *,(RollingVaccinationsSum/population)*100 VaccinationsPercentage
FROM #VacPercentage
ORDER BY 2,3

