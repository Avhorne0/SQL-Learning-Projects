
 SELECT date, location, population, total_cases, new_cases, total_deaths
 FROM CovidDeath.dbo.CovidDeaths
ORDER BY 2,1

--Looking at Total Case vs Total Deaths


SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as NUMERIC)/CAST (total_cases as NUMERIC))*10 as DeathPercentage
FROM CovidDeath.dbo.CovidVainations2
where location like '%states%'
ORDER BY 1,2

--Looking at total cases vs Population
-- Shows what percentage of population got Covid

------SELECT location, MAX(population) AS Population, MAX(Total_deaths) as TotalDeathCount
--------(max(population)/MAX(total_deaths))
------FROM dbo.CovidVainations2
------WHERE date like '2021-04-30'
------GROUP BY location
------ORDER BY 1,2

--Looking at Countries with Highest Infection rate compared to population.
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases as NUMERIC)/CAST (population as NUMERIC)))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--where location like '%states%'
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest DeathCount Per Population
SELECT location, max( cast (Total_deaths as int)) as TotalDeathCount
FROM CovidVainations2
where continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Break Things down by Location
SELECT location, max( cast (Total_deaths as int)) as TotalDeathCount
FROM CovidVainations2
where continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc 
---CORRECT WAY--MAYBE---

--Break Things down by CONTINENT
SELECT continent, max( cast (Total_deaths as int)) as TotalDeathCount
FROM CovidVainations2
where continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc 

SELECT date, sum(cast(total_cases as int)) as Total_Cases, sum(cast(total_deaths as int)) as Total_Death, MAX((CAST(total_deaths as NUMERIC)/CAST (total_cases as NUMERIC)))*10 as DeathPercentage
FROM CovidVainations2
--where location like '%states%'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

SELECT sum(cast(total_cases as NUMERIC)) as Total_Cases, sum(cast(total_deaths as NUMERIC)) as Total_Death, SUM((CAST(total_deaths as NUMERIC)/CAST (total_cases as NUMERIC)))*10 as DeathPercentage
FROM CovidVainations2
--where location like '%states%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vacinations
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  FROM CovidDeaths.dbo.CovidDeaths dea
  JOIN CovidDeaths.dbo.CovidVacination vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	order by 2,3

	  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacinated
  FROM CovidDeaths.dbo.CovidDeaths dea
  JOIN CovidDeaths.dbo.CovidVacination vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	order by 2,3


	WITH Popvsvac (Coninent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	AS
	(
		  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacinated
  FROM CovidDeaths.dbo.CovidDeaths dea
  JOIN CovidDeaths.dbo.CovidVacination vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--order by 2,3
	)
SELECT Population, RollingPeopleVaccinated, (CAST (RollingPeopleVaccinated AS numeric)/CAST (Population AS numeric))*100
FROM Popvsvac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacinated
  FROM CovidDeaths.dbo.CovidDeaths dea
  JOIN CovidDeaths.dbo.CovidVacination vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--WHERE dea.continent is not null
	--order by 2,3

SELECT *, (Rollingpeoplevaccinated/Population)*100
FROM PercentPopulationVaccinated
