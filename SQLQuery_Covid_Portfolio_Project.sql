SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%india%'
and continent is not null
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases / population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%india%'
and continent is not null
ORDER BY 1,2

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases / population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations Vac
ON dea.location = Vac.location
and dea.date = Vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations Vac
ON dea.location = Vac.location
and dea.date = Vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) *100
FROM PopvsVac

--Temp Table

DROP TABLE if exists #PersonPopulationVaccinated
CREATE TABLE #PersonPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
RollingPeopleVaccinated bigint
)

INSERT INTO #PersonPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(cast(Vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations Vac
ON dea.location = Vac.location
and dea.date = Vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) *100
FROM #PersonPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(cast(Vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations Vac
ON dea.location = Vac.location
and dea.date = Vac.date
WHERE dea.continent is not null
--ORDER BY 2,3




